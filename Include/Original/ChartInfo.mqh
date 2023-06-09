//+------------------------------------------------------------------+
//|                                                    ChartInfo.mqh |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

class ChartInfo{

public: string symbol;

public:
   ChartInfo::ChartInfo(string sy)
   {
      symbol = sy;
   };

//+------------------------------------------------------------------+
//| 今のレートを取得                       |
//+------------------------------------------------------------------+
public:
double GetRate( int type )
{
   double ret;
   if (!(type == MODE_ASK || type == MODE_BID))
   {
      return -1;
   }
   ret = MarketInfo(symbol,type);
   return ret;
}

//+------------------------------------------------------------------+
//| 指定したインジケータを表示                       |
//+------------------------------------------------------------------+
public:
bool SetChart()
{
   bool ret ;
   ret = false;
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

   ret = true;
   return ret;
}


};