//+------------------------------------------------------------------+
//|                                                        TradeMethod.mqh |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#include <stdlib.mqh>          // ライブラリインクルード
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property version   "1.00"
#property strict

class TradeMethod
{
   //取引フラグ 
   private: datetime tradeTime; 
   
   public:
   TradeMethod::TradeMethod(void)
   {
      tradeTime = TimeCurrent();
   };


public:
int Order_Method(string symbol,string methodName)
{
      int ret;
      ret = 0;
      if (methodName == "NewOrder_Pattern1")
       {   ret = Order_Pattern1(symbol);}
       else if(methodName == "NewOrder_Pattern2")
       {   ret = Order_Pattern2(symbol);}
       return ret;

}

public:
int Payment_Method(int ticket,string methodName)
{
            int ret;
      ret = 0;
      if (methodName == "Payment_Pattern1")
         {ret = Payment_Pattern1(ticket);}
      else if(methodName == "NewOrder_Pattern2")
         { ret = Payment_Pattern2(ticket);}
      return ret;
}
//パターン１_新規
private:
int Order_Pattern1(string symbol)
{
   //平均移動戦を取得
   double sma14 = iMA(symbol,PERIOD_M5,14,0,MODE_SMA,PRICE_MEDIAN,0);
   double sma28 = iMA(symbol,PERIOD_M5,28,0,MODE_SMA,PRICE_MEDIAN,0);

   double sma14_o = iMA(symbol,PERIOD_M5,14,0,MODE_SMA,PRICE_MEDIAN,1);
   double sma28_o = iMA(symbol,PERIOD_M5,28,0,MODE_SMA,PRICE_MEDIAN,1);

   
   if(sma14 > sma28 && sma14_o < sma28_o && TimeCurrent()-1000 >= tradeTime)
   {
      printf("買い");
      tradeTime = TimeCurrent();
      return 100;
   }

   if(sma14 < sma28 && sma14_o > sma28_o && TimeCurrent()-1000 >= tradeTime)
   {
      printf("売り");
      tradeTime = TimeCurrent();
      return -100;
   }

   return 0;
}

//パターン１_決済
private:
int Payment_Pattern1(int ticket)
{
   bool osel;
   osel = OrderSelect( ticket , SELECT_BY_POS , MODE_TRADES);
   
   // レートのリフレッシュ
   RefreshRates();    
   
   double oprofit;
   oprofit = OrderProfit();

   //平均移動戦を取得
   double sma14 = iMA(OrderSymbol(),PERIOD_M5,14,0,MODE_SMA,PRICE_MEDIAN,0);
   double sma28 = iMA(OrderSymbol(),PERIOD_M5,28,0,MODE_SMA,PRICE_MEDIAN,0);

   double sma14_o = iMA(OrderSymbol(),PERIOD_M5,14,0,MODE_SMA,PRICE_MEDIAN,1);
   double sma28_o = iMA(OrderSymbol(),PERIOD_M5,28,0,MODE_SMA,PRICE_MEDIAN,1);

      if(sma14 > sma28 && sma14_o < sma28_o && TimeCurrent()-1000 >= tradeTime && (oprofit >1 || oprofit < -10000))
   {
   
      return 100;
   }

   if(sma14 < sma28 && sma14_o > sma28_o && TimeCurrent()-1000 >= tradeTime && (oprofit >1 || oprofit < -10000))
   {
      return 100;
   }
   
   return 0;
}


//パターン2_新規注文
private:
int Order_Pattern2(string symbol)
{

   return 100;
}

//パターン2_決済
private:
int Payment_Pattern2(int ticket)
{
   return 100;
}
};