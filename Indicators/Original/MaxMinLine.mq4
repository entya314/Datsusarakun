//+------------------------------------------------------------------+
//|                                                   MaxMinLine.mq4 |
//|                                      Copyright 2023, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//線の本数指定
#property indicator_buffers 4
//１本目（Max線）の色と太さ
#property indicator_color1 clrRed
#property indicator_width1 1
//2本目(Min線)の色と太さ
#property indicator_color2 clrMediumBlue
#property indicator_width2 1
//3本目(Average線)の色と太さ
#property indicator_color3 clrLawnGreen
#property indicator_width3 1
//テスト用(指定箇所に印をつける）
#property  indicator_color4 clrYellow   
#property  indicator_width4 1              
//線を格納する配列
double highLine[];
double lowLine[];
double aveLine[];
//描画ライン数を動的に変化させる。
int activeDrawNum;
//テスト用
double testChkRates[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   //線の指定と線種指定
   SetIndexBuffer(0, highLine);
   SetIndexStyle(0, DRAW_LINE);
   //線の指定と線種指定
   SetIndexBuffer(1, lowLine);
   SetIndexStyle(1, DRAW_LINE);
   //線の指定と線種指定
   SetIndexBuffer(2, aveLine);
   SetIndexStyle(2, DRAW_LINE);
   //テスト用(指定箇所に印をつける）
    SetIndexBuffer(3,testChkRates);   
    SetIndexStyle(3,DRAW_ARROW);        
    SetIndexArrow(3,SYMBOL_CHECKSIGN);
    
    //初回描画数の記述
    activeDrawNum = 10;
//---
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

   //初回計算時処理
   if (prev_calculated == 0){ 
      //初期範囲内で描画を行う
      DrawLineNoTrendLine(activeDrawNum);
   }

   //バーが追加されたときに呼び出される
   if(rates_total != prev_calculated)
   {
      bool trendBreakFlg;
      activeDrawNum = activeDrawNum + 1 ;
      //更新前にトレンドブレイクチェック
      trendBreakFlg = ChkBreakTrendLine(0);
      if(trendBreakFlg)
      {
         activeDrawNum = 1;
      }
      
      //初期範囲内で描画を行う
      DrawLineNoTrendLine(activeDrawNum);
      //トレンドをひけるならひく
      DrowMaxLowLine(activeDrawNum,0);
   }


//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
//トレンドラインが確定していないときに、平均値線から暫定で結ぶプログラム
void DrawLineNoTrendLine(int barNum)
{
   //最小二乗法により平均値を作成(区分分け)
   DrowAverageLine(barNum,0);

   //最大値、最小値を取得し、平均線の平行移動を行う。
   DrowMaxMinLineForAverageLine(barNum,0);
}

//最大値、最小値を取得し、平均線の平行移動を行う。
void DrowMaxMinLineForAverageLine(int fromBar , int toBar)
{
   double LowDiff,HighDiff;
   int i;
   LowDiff = 0.0;
   HighDiff = 0.0;
  
   //範囲内の最大値、最小値を取得
   for (i= fromBar ; i >= toBar ; i--)
   {
      //最小値更新
      if(LowDiff < aveLine[i] - Low[i])
      {
         LowDiff = aveLine[i] - Low[i];
      }
      //最大値更新
      if(HighDiff < High[i] - aveLine[i])
      {
         HighDiff = High[i] - aveLine[i];
      }
   }   

   //更新されていない場合エラー
   if ((int)LowDiff == 0.0 || (int)HighDiff == 0.0 )
   {
      printf("ERROR:DrowMaxMinLineForAverageLine");
   }

   //HighLineを平均線の平行移動から作成。
   for (i= fromBar ; i >= toBar ; i--)
   {
            highLine[i] = aveLine[i] + HighDiff;
            lowLine[i] = aveLine[i] - LowDiff;
   }
}

//更新に合わせてトレンドラインを描画する
void UpadateTrendLine()
{
   //最小二乗法により平均値を作成(区分分け)
   //DrowAverageLine(10,0);
} 

//トレンドが崩壊したか確認
bool ChkBreakTrendLine(int barNum)
{
   //一個前と新しいレートのチェック
   if(High[barNum]/highLine[barNum+1] > 1.03)
   {
      testChkRates[barNum] = High[barNum];
      return true;   
   }

   if(Low[barNum]/lowLine[barNum+1] < 0.96)
   {
      testChkRates[barNum] = Low[barNum];
      return true;   
   }

return false;
}
  
//ライン描画
void DrawLine(int fromBar , int toBar)
{
   //最小二乗法により平均値を作成(区分分け)
   DrowAverageLine(fromBar,toBar);
   //High&Lowライン作成
   DrowMaxLowLine(fromBar,toBar);

  }
//最大値のラインを平均値ラインから作成
void DrowMaxLowLine(int fromBar , int toBar)
{
   int i,beforeFlg,bk_i;
   int highCount,lowCount;
   double Maxhigh,MinLow;
   //初期値格納
   Maxhigh = 0.0;
   MinLow = 10000;
   
   highCount = 0;
   lowCount = 0;
   //初期状態
   for (i= fromBar ; i >= toBar ; i--)
   {   
      //平均線がローとハイの間にある場合計算除外
      if((Low[i] < aveLine[i]) && (aveLine[i] < High[i]))
      {
         beforeFlg =0 ;
        // testChkRates[i] = (High[i] + Low[i])/2;
         continue;
      }

      //最大値計算
      if(aveLine[i] < High[i] && Maxhigh < High[i])
      {
         //変動時配列格納
         if(beforeFlg != 1)
         {
            if((int)MinLow != 10000)
            {
               lowLine[bk_i] = MinLow;
               testChkRates[bk_i]=MinLow;
               lowCount = lowCount +1 ;
            }
            MinLow = 10000;
         }
         Maxhigh = High[i];
         bk_i = i;

         beforeFlg = 1;
      }

      else if(Low[i] < aveLine[i] && MinLow > Low[i])      //最小値計算
      {
         //変動時配列格納
         if(beforeFlg != -1)
         {
            if((int)Maxhigh != 0.0)
            {
               highLine[bk_i] = Maxhigh;
               testChkRates[bk_i]=Maxhigh;
               highCount = highCount +1 ;
            }
            Maxhigh = 0.0;
         }
         MinLow = Low[i];
         bk_i = i;

         beforeFlg = -1;
      }
   }

   //最小二乗法より値作成
   if (highCount >= 2){
   LeastSquaresMethod(highLine , fromBar ,toBar ,highLine);
   }
   if (lowCount >= 2){
   LeastSquaresMethod(lowLine , fromBar ,toBar ,lowLine);
   }
  }

//平均値作成
void DrowAverageLine(int fromBar , int toBar)
{
    double calcBars[];  
    int i,array_num;

   //算術用配列の格納数を動的に設定（引数は格納数）
   array_num = ArrayResize(calcBars,fromBar + 1);   

   //計算を行うライン数とラインを取得
   for (i= fromBar ; i >= toBar ; i--)
   {
      calcBars[i] = (High[i] + Low[i])/2.0;
   }

   //最小二乗法により計算し、描画を行う
   LeastSquaresMethod(calcBars , fromBar ,toBar ,aveLine);
   

}
   //最小二乗法（参照渡しに注意）
   void LeastSquaresMethod(double &rates[], int fromBar ,int toBar , double &ret_rate[])
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
         
      return;
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
