//+------------------------------------------------------------------+
//|                                                     TESTPrac.mq4 |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property version   "1.00"
#property strict
//メインウィンドウに記載
#property indicator_chart_window
//線の本数指定
#property indicator_buffers 2
//１本目の色と太さ
#property indicator_color1 clrRed
#property indicator_width1 2
//2本目の色と太さ
#property indicator_color2 clrYellow
#property indicator_width2 3
//線を格納する配列
double highLine[];
double lowLine[];
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
//---
   int i,j;
   int limit;
   //初期の場合
   if (prev_calculated == 0){
      limit = rates_total - 1;
   }else{
   //更新する場合
      limit = rates_total - prev_calculated;
   }
   
   for (i=limit; i>=0; i--)               // limit本前から現在のローソク足を処理
   {
      if (i + SMA_Period - 1 <= Bars - 1)
      {
         // buf[i]を０に初期化して
         buf[i] = 0;
         // Close[i+0] ～ Close[i+SMA_Period]の一つ手前までを足していき
         for (j=0; j<SMA_Period; j++) buf[i] += Close[i+j];
         // SMA_Periodで割る
         buf[i] /= SMA_Period;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
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
