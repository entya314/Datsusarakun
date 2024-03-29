//+------------------------------------------------------------------+
//|                                                     TESTPrac.mq4 |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldops.com"
#property version   "1.00"
#property strict
//メインウィンドウに記載
#property indicator_chart_window
//線の本数指定
#property indicator_buffers 4
//１本目の色と太さ
#property indicator_color1 clrRed
#property indicator_width1 1
//2本目の色と太さ
#property indicator_color2 clrGreen
#property indicator_width2 1
//3本目の色と太さ
#property indicator_color3 clrBlue
#property indicator_width3 1
//4本目の色と太さ
#property indicator_color4 clrYellow
#property indicator_width4 1


//線を格納する配列
double MaxHighLine[];
double MaxLowLine[];

double MinHighLine[];
double MinLowLine[];

//チャート間隔
int ChartRange;
int CheckInterval;

//現状の最大、最小バーを格納
int highBar;
int lowBar;

bool trendFlg;
int ObjectId;
//二番目の点
int secondHighOfHighBar,secondLowOfHighBar,secondHighOfLowBar,secondLowOfLowBar;

//それぞれの傾きと切片
double a[4],b[4];
//計算用配列
double calcBar[];

//定数指定値
int const MAX_HIGH_PATTERN = 0;
int const MAX_MIN_PATTERN = 1;
int const MIN_HIGH_PATTERN = 2;
int const MIN_LOW_PATTERN = 3;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   //線の指定と線種指定
   SetIndexBuffer(0, MaxHighLine);
   SetIndexStyle(0, DRAW_LINE);

   SetIndexBuffer(1, MaxLowLine);
   SetIndexStyle(1, DRAW_LINE);

   SetIndexBuffer(2, MinHighLine);
   SetIndexStyle(2, DRAW_LINE);

   SetIndexBuffer(3, MinLowLine);
   SetIndexStyle(3, DRAW_LINE);

   ChartRange = 80;
   CheckInterval = 9;
//---
   //計算用配列を動的に指定
   ArrayResize(calcBar,ChartRange+1);

   
   trendFlg = false;

   
   return(INIT_SUCCEEDED);
  }
  
void CalcDrawLine(int pattern,
                const double &high[],
                const double &low[])
{
   //初期値9999.99を設定     
   ArrayInitialize(calcBar,9999.99);

   //最大、最小のバーを取得
   highBar = GetLargestBar("High",ChartRange,1,high);
   lowBar = GetLargestBar("Low",ChartRange,1,low);

   if(highBar > lowBar)
   {//ダウントレンド

      //補助線をひくための最大、最小の傾きを取得　急steep,なだらかgentle
      secondHighOfHighBar = GetSecondLergeestBar("Gentle",highBar , CheckInterval , 1 ,high);

      
      //値を代入
      calcBar[highBar] = high[highBar];
      calcBar[secondHighOfHighBar] = high[secondHighOfHighBar];
      //線を引く
      LeastSquaresMethod(calcBar,highBar,0,MaxHighLine,MAX_HIGH_PATTERN);  

      //リセット
      ArrayInitialize(calcBar,9999.99);
      //値を代入
      calcBar[highBar] = low[highBar];
      calcBar[secondHighOfLowBar] = low[secondHighOfLowBar];
      //線を引く
      LeastSquaresMethod(calcBar,highBar,0,MaxLowLine,MAX_MIN_PATTERN);      
   }

}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{

      //範囲内で現在の最大値、最小値のバーを判定する
      highBar = GetLargestBar("High",ChartRange,1,high);
      lowBar = GetLargestBar("Low",ChartRange,1,low);
      //現在時刻を取得
      
      datetime time01 = Time[0];

      if(highBar > lowBar )
      {
         if(trendFlg == false)
         {
            trendFlg = true;   
            ObjectId = ObjectId + 1;      
            ObjectCreate((string)ObjectId,OBJ_VLINE,0,time01,0);
            ObjectSet((string)ObjectId,OBJPROP_COLOR,Blue);
            ObjectSet((string)ObjectId,OBJPROP_WIDTH,1);
            Comment("下降トレンド");
         }
      }
      else if(highBar < lowBar)
      {
         if(trendFlg == true)
         {
            trendFlg = false;         
            ObjectId = ObjectId + 1;
            ObjectCreate((string)ObjectId,OBJ_VLINE,0,time01,0);
            ObjectSet((string)ObjectId,OBJPROP_COLOR,Red);
            ObjectSet((string)ObjectId,OBJPROP_WIDTH,1);
            Comment("上昇トレンド");
         }
      }
      else
      {
         Comment("トレンド不明");
      }      
   if (prev_calculated == 0){
      printf("初回実行");
   }




   //--- return value of prev_calculated for next call
   return(rates_total);
}
  
int GetLargestBar(string HighOrLow,int FromBar , int ToBar , const double &chkBar[])
{
   int i,retBar,sign;
   double retRate;
   
   if(HighOrLow == "High")
   {
      sign = 1;
   }else if(HighOrLow == "Low")
   {
      sign = -1;
   }else
   {
      sign = 0;
      printf("引数が間違っていますSteepかGengtleを記載してください");
   }  


   retBar = FromBar;
   retRate = chkBar[FromBar];
   for(i = FromBar-1 ; i >= ToBar ; i--)
   {
      if(sign *retRate < sign*chkBar[i])
      {
         retBar = i;
         retRate = chkBar[i];
      }
   }
   return retBar;
}

bool ChangeCheck(double target_value , double check_value)
{
   if(MathAbs(1.0 - (check_value/target_value)) >= 0.0001)
   {
      return true;
   }

   return false;
}

int GetSecondLergeestBar(string SteepOrGentle,int FromBar ,int Interval , int ToBar , const double &chkBar[])
{
   int i,retBar,sign;
   double retInclination;

   if(SteepOrGentle == "Steep")
   {
      sign = 1;
   }else if(SteepOrGentle == "Gentle")
   {
      sign = -1;
   }else
   {
      sign = 0;
      printf("引数が間違っていますSteepかGengtleを記載してください");
   }  

   if(FromBar <= 1 || ToBar >= FromBar || FromBar - Interval <= 1)
   {
      return 0;
   }

   retBar = FromBar - Interval;
   
   retInclination = (chkBar[FromBar]- chkBar[FromBar - Interval])/(Interval);

   for(i = FromBar - Interval ; i >= ToBar ; i--)
   {
      if(sign * retInclination < sign*(chkBar[FromBar]- chkBar[i])/(FromBar - i))
      {
         retBar = i;
         retInclination = (chkBar[FromBar]- chkBar[i])/(FromBar - i);
      }
   }
   return retBar;
}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
  //最小二乗法（参照渡しに注意）
   void LeastSquaresMethod(double &rates[], int fromBar ,int toBar , double &ret_rate[],int magic=0)
   {   
      //平均を算出
      double rate_average;
      double x_average;
      int  NumCount = 0;
      rate_average = 0.0;
      x_average = 0.0;
      int i;
      //平均値を導出
      for (i= fromBar ; i >= toBar ; i--)
      {
         if(rates[i] <= 1000){
            rate_average = rate_average + rates[i];
            x_average = x_average + i;
            NumCount = NumCount +1 ;
         }
      }
      
      printf(NumCount);

      if( NumCount == 0)
      {
         return ;
      }
      //平均値を算出
      rate_average = rate_average / NumCount;
      x_average = x_average / NumCount;

      //傾きと切片の計算
      double cal1,cal2,slope_a,intercept_b;
      cal1 = 0.0;
      cal2 = 0.0;

     for (i= fromBar ; i >= toBar ; i--)
      {
         if(rates[i] <= 1000){
              cal1 = cal1 + (i - x_average)*(rates[i] -rate_average);
              cal2 = cal2 + (i - x_average)*(i - x_average);
         }
      }
      slope_a = 0;
      if (cal2 != 0)
      {
         slope_a = cal1/cal2;
      }
      intercept_b = rate_average - slope_a*x_average;

      //配列に結果を格納する
      for (i=fromBar; i>=toBar; i--)
      {
         ret_rate[i] = slope_a * i + intercept_b;
      }

      //マジックナンバーで値を格納   
      a[magic] = slope_a;
      b[magic] = intercept_b;

      return;
   }