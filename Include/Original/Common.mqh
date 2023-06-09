//+------------------------------------------------------------------+
//|                                                       Common.mqh |
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
//トレードするpipsを計算する。

double GetTradeLots(int type ,int amountJPY,double parcent)
{
   double price,minlot;
   int lotsize;
   
   if(type == OP_BUY)
   {
      price = Ask;
   }else{
      price = Bid;
   }
   
   //最小ロット値を取得
   minlot =  MarketInfo(Symbol(),MODE_MINLOT);
   //ロットサイズ(基軸通貨)を取得
   lotsize  =(int)MarketInfo(Symbol(),MODE_LOTSIZE);

   return int(amountJPY * 25.0 * parcent/  (lotsize * price )/minlot)*minlot;

}