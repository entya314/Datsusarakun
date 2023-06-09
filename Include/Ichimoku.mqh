//+------------------------------------------------------------------+
//|                                                     Ichimoku.mqh |
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

double GetIchimoku(string symbol, int timeframe ,int mode,int shift)
{
   //MODE_TENKANSEN	1	転換線
   //MODE_KIJUNSEN	2	基準線
   //MODE_SENKOUSPANA	3	先行スパンA
   //MODE_SENKOUSPANB	4	先行スパンB
   //MODE_CHIKOUSPAN	5	遅行線

   return iIchimoku(symbol,timeframe,9,26,52,mode,shift);
}