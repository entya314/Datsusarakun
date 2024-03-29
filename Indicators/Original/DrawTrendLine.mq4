//+------------------------------------------------------------------+
//|                                                DrawTrendLine.mq4 |
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
#property indicator_buffers 6
//１本目の色と太さ
#property indicator_color1 clrRed
#property indicator_width1 2
//2本目の色と太さ
#property indicator_color2 clrBlue
#property indicator_width2 2
//１本目の色と太さ
#property indicator_color3 clrRed
#property indicator_width3 1
//２本目の色と太さ
#property indicator_color4 clrBlue
#property indicator_width4 1

//テスト用(指定箇所に印をつける）
#property  indicator_color5 clrPink   
#property  indicator_width5 3          
//テスト用(指定箇所に印をつける）
#property  indicator_color6 clrPink   
#property  indicator_width6 3          

//取引状態
string symbol = "";
string indicatorName = "DrawTrendLine";

//線を格納する配列
double Trend_High_Line[];
double Trend_Low_Line[];
double Trend_High_Line_BK[];
double Trend_Low_Line_BK[];

double Debug_Sign[];
double Debug_Sign2[];

//チャート間隔
int ChartRange;
int CheckInterval;

//現状の最大、最小バーを格納
int highBar;
int lowBar;
//二番目の点
int secondHighOfHighBar,secondLowOfHighBar,secondHighOfLowBar,secondLowOfLowBar;

//それぞれの傾きと切片
double a[4],b[4];
//計算用配列
double calcBar[];

//定数指定値
int const UP_TREND_HIGH_PATTERN = 0;
int const UP_TREND_LOW_PATTERN = 1;
int const DOWN_TREND_HIGH_PATTERN = 2;
int const DOWN_TREND_LOW_PATTERN = 3;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   //線の指定と線種指定
   SetIndexBuffer(0, Trend_High_Line);
   SetIndexStyle(0, DRAW_LINE);

   SetIndexBuffer(1, Trend_Low_Line);
   SetIndexStyle(1, DRAW_LINE);

   SetIndexBuffer(2, Trend_High_Line_BK);
   SetIndexStyle(2, DRAW_LINE);

   SetIndexBuffer(3, Trend_Low_Line_BK);
   SetIndexStyle(3, DRAW_LINE);

   SetIndexBuffer(4, Debug_Sign);
   SetIndexStyle(4,DRAW_ARROW);        
   SetIndexArrow(4,SYMBOL_CHECKSIGN);

   SetIndexBuffer(5, Debug_Sign2);
   SetIndexStyle(5,DRAW_ARROW);        
   SetIndexArrow(5,SYMBOL_CHECKSIGN);
   
   //インジケータ設定
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhiteSmoke);

   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);
   ChartSetInteger(0, CHART_COLOR_GRID, clrBlack);

   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrRed);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrRed);

   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrBlack); 
   
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlue);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlue);

   ChartSetInteger(0, CHART_COLOR_ASK, clrRed);

   //パラメータ代入   
   ChartRange = 120;
   CheckInterval = 9;
//---
   //計算用配列を動的に指定
   ArrayResize(calcBar,ChartRange+1);

   return(INIT_SUCCEEDED);
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
    //範囲内で最大、最小レートを取得
SetPath();
   //*********** 初回実行の場合 ********************
   if (prev_calculated == 0){
      ArrayInitialize(Debug_Sign,0); 
      ArrayInitialize(Debug_Sign2,0);          
      printf("初回実行");

      //※Highライン
      //計算用配列初期化
      ArrayInitialize(calcBar,9999.99);
      //ラインを引くためのバーを取得しCalcBarに格納
      DrowDivideLine(10,ChartRange,0,high,1);
      //最小二乗法により表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_High_Line,0);
      //求めた傾きを参考に＋方向に差異がある点２点を取得
      Get2Points(calcBar,a[0] ,b[0] ,ChartRange , 0,1);
      //再度最小二乗法より再表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_High_Line,0);

      //★Lowライン
      //計算用配列初期化
      ArrayInitialize(calcBar,9999.99);
      //ラインを引くためのバーを取得しCalcBarに格納
      DrowDivideLine(10,ChartRange,0,low,-1);
      //最小二乗法により表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_Low_Line,1);
      //求めた傾きを参考に＋方向に差異がある点２点を取得
      Get2Points(calcBar,a[1] ,b[1] ,ChartRange , 0,-1);
      //再度最小二乗法より再表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_Low_Line,1);
   }
   else if(rates_total != prev_calculated)
   {
   //*********** ２回目以降の場合 ********************
   //バーが追加されたときに呼び出される   
   //グラフをずらす
     b[0] = b[0] - a[0];
     b[1] = b[1] - a[1];

   //線を伸ばす
   Trend_High_Line[0] = b[0];
   Trend_Low_Line[0] = b[1];   

   //トレンド変更チェック
   if(ChkTrendLine(Trend_High_Line,11,1,low,1))
   {
      //※Highライン
      //計算用配列初期化
      ArrayInitialize(calcBar,9999.99);
      //ラインを引くためのバーを取得しCalcBarに格納
      DrowDivideLine(10,ChartRange,0,high,1);
      //最小二乗法により表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_High_Line,0);
      //求めた傾きを参考に＋方向に差異がある点２点を取得
      Get2Points(calcBar,a[0] ,b[0] ,ChartRange , 0,1);
      //再度最小二乗法より再表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_High_Line,0);
   }

   //トレンド変更チェック
   if(ChkTrendLine(Trend_Low_Line,11,1,high,-1))
   {
      //★Lowライン
      //計算用配列初期化
      ArrayInitialize(calcBar,9999.99);
      //ラインを引くためのバーを取得しCalcBarに格納
      DrowDivideLine(10,ChartRange,0,low,-1);
      //最小二乗法により表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_Low_Line,1);
      //求めた傾きを参考に＋方向に差異がある点２点を取得
      Get2Points(calcBar,a[1] ,b[1] ,ChartRange , 0,-1);
      //再度最小二乗法より再表示
      LeastSquaresMethod(calcBar,ChartRange,0,Trend_Low_Line,1);
   }
   }
       Comment(Trend_High_Line[0]);

   //--- return value of prev_calculated for next call
   return(rates_total);
  
   }

bool ChkTrendLine(double &chkBar[], int fromBar , int toBar , const double &baseBar[] , int MaxOrMin)
{
   //チェック１
   int i,chkCount;
   chkCount = 0;
   for(i = fromBar-1 ; i >= toBar ; i--)
   {
      if(MaxOrMin * chkBar[i] < MaxOrMin * baseBar[i])
      {
         chkCount = chkCount + 1 ;
      }
   }

   if(chkCount > (fromBar - toBar)*0.8 )
   {
      return true;      
   }

   //チェック２
   chkCount = 0;
   for(i = fromBar-1 ; i >= toBar ; i--)
   {
      if(MaxOrMin * ( chkBar[i] - baseBar[i]) > 0.1)
      {
         chkCount = chkCount + 1 ;
      }
   }

   if(chkCount > (fromBar - toBar)*0.8 )
   {
      return true;      
   }

   return false;
}

void Get2Points(double &ccalcBar[], const double aa ,const double bb ,int fromBar ,int toBar, int MaxOrMin)
{
   int firstBar,secondBar,i;
   firstBar = 999;
   secondBar = 999;

   //２点取得
   for(i = fromBar-1 ; i >= toBar ; i--)
   {
      //値が入っていないものは飛ばす
      if(ccalcBar[i] >=9000.0){continue;}

      //1番目取得
      if(firstBar == 999)
      {
         firstBar = i;
         secondBar = i;
      }
      
      if(MaxOrMin*(ccalcBar[i] - (aa*i + bb)) > MaxOrMin*(ccalcBar[firstBar] - (aa*firstBar + bb))) 
      {     
         secondBar = firstBar;
         firstBar = i;         
      }else if(secondBar == firstBar || MaxOrMin*(ccalcBar[i] - (aa*i + bb)) > MaxOrMin*(ccalcBar[secondBar] - (aa*secondBar + bb))) 
      {
         secondBar = i;   
      }
   }

   //calcBar再設定
   for(i = fromBar-1 ; i >= toBar ; i--)
   {
      if(!(i == firstBar || i == secondBar))
      {
         ccalcBar[i] = 9999.99;
      }
   }
         Debug_Sign[firstBar] = ccalcBar[firstBar];
         Debug_Sign[secondBar] = ccalcBar[secondBar];

}

void DrowDivideLine(int chartMinutes ,int fromBar , int toBar, const double &baseBar[], int MaxOrMin)
{
   //初期値設定
   int barCount,groupCount ,startBar,retBar;
   //範囲内で最大、もしくは最小のバーを取得
   string HighOrLow;
   if(MaxOrMin == 1 )
   {
      HighOrLow = "High";
   }else
   {
      HighOrLow = "Low";
   }

//   startBar = GetLargestBar(HighOrLow,fromBar,toBar,baseBar);

   //ループ開始 
   barCount = fromBar;
   while(barCount > toBar)
   {
      //入れ子ループ用初期値
      groupCount = 0;
      retBar = barCount;
      
      //〇分速毎で最大値、最小値を求める。
      while(groupCount < chartMinutes && barCount >= 0)
      {
         //最大値、最小値更新
         if(MaxOrMin * baseBar[barCount] > MaxOrMin * baseBar[retBar])
         {
               retBar = barCount;
         }       
         //カウント
         groupCount = groupCount + 1;
         barCount = barCount - 1;         
      }
      //最大値、最小値を格納
      calcBar[retBar] = baseBar[retBar];

      //格納したところからプラスする
      barCount = retBar - chartMinutes;
   }
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

   //+------------------------------------------------------------------+
//| パス設定
//+------------------------------------------------------------------+
void SetPath()
{
    // 相対ファイルアドレスセット
   string RelativeFileAddress;
    RelativeFileAddress = StringFormat(
                   "%s\\%s" ,
                   "data" , 
                   "order.csv"
               );

      printf(RelativeFileAddress);
    int filehandle;                    // ファイルハンドラ

    // 書き込むファイルを開く(存在しなければ作成される)
    filehandle = FileOpen(
            RelativeFileAddress,    // ファイル名
            FILE_WRITE | FILE_CSV,  // ファイル操作モードフラグ
            ','                     // セパレート文字コード
    );

    if ( filehandle == INVALID_HANDLE ) { // ファイルオープンエラー
        printf( "[%d]ファイルオープンエラー：%s" , __LINE__ , RelativeFileAddress );
    } else {
        WriteData(filehandle);      // ファイル書き出し
        FileClose(filehandle);      // ファイルハンドラクローズ(絶対に忘れない事)
        // FileCloseを忘れると開いたMT4以外で対象ファイルが操作出来なくなります
    }

}


//+------------------------------------------------------------------+
//| データ書き出し
//+------------------------------------------------------------------+
void WriteData( int in_filehandle ,BuyOrSell,position,price,value){
    
    FileWrite( in_filehandle , "test1" );
    
}