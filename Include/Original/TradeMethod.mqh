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
      if (methodName == "Order_AverageMoving")
       {   ret = Order_AverageMoving(symbol);}
       else if(methodName == "Order_Ichimoku")
       {   ret = Order_Ichimoku(symbol);}
       return ret;

}

public:
int Payment_Method(int ticket,string methodName)
{
            int ret;
      ret = 0;
      if (methodName == "Payment_AverageMoving")
         {ret = Payment_AverageMoving(ticket);}
      else if(methodName == "Payment_Ichimoku")
         { ret = Payment_Ichimoku(ticket);}
      return ret;
}
//平均移動曲線を用いた新規オーダー
private:
int Order_AverageMoving(string symbol)
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

//平均移動曲線を用いた決済トレード
private:
int Payment_AverageMoving(int ticket)
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
int Order_Ichimoku(string symbol)
{

   //一目均衡表のゴールデンクロスデッドクロスを取得
      double now_tenkansen = iIchimoku(
                                symbol,               // 通貨ペア
                                PERIOD_M5,                   // 時間軸
                                9,                   // 転換線期間
                                26,                  // 基準線期間
                                52,                  // 先行スパン期間
                                MODE_TENKANSEN,    // ラインインデックス
                                0                    // シフト
                               ); 
      double before_tenkansen = iIchimoku(symbol, PERIOD_M5,  9,26,52,  MODE_TENKANSEN, 1 ); 
      double now_kijyunsen  = iIchimoku(symbol, PERIOD_M5,  9,26,52,  MODE_KIJUNSEN, 0 ); 
      double before_kijyunsen  = iIchimoku(symbol, PERIOD_M5,  9,26,52,  MODE_KIJUNSEN, 1 ); 
        
      if(now_tenkansen >= now_kijyunsen && before_tenkansen < before_kijyunsen && TimeCurrent()-4000 >= tradeTime)
      {
         printf("買い");
         tradeTime = TimeCurrent();
         return 100;
      }

      if(now_tenkansen <= now_kijyunsen && before_tenkansen > before_kijyunsen &&  TimeCurrent()-4000 >= tradeTime)
      {
         printf("売り");
         tradeTime = TimeCurrent();
         return -100;
      }

   return 0;
}

//パターン2_決済
private:
int Payment_Ichimoku(int ticket)
{
   bool osel;
   osel = OrderSelect( ticket , SELECT_BY_POS , MODE_TRADES);
   
   // レートのリフレッシュ
   RefreshRates();    
   
   double oprofit;
   oprofit = OrderProfit();

   //平均移動戦を取得
   //一目均衡表のゴールデンクロスデッドクロスを取得
      double now_tenkansen = iIchimoku(
                                OrderSymbol(),               // 通貨ペア
                                PERIOD_M5,                   // 時間軸
                                9,                   // 転換線期間
                                26,                  // 基準線期間
                                52,                  // 先行スパン期間
                                MODE_TENKANSEN,    // ラインインデックス
                                0                    // シフト
                               ); 

      double before_tenkansen = iIchimoku(OrderSymbol(), PERIOD_M5,  9,26,52,  MODE_TENKANSEN, 1 ); 
      double now_kijyunsen  = iIchimoku(OrderSymbol(), PERIOD_M5,  9,26,52,  MODE_KIJUNSEN, 0 ); 
      double before_kijyunsen  = iIchimoku(OrderSymbol(), PERIOD_M5,  9,26,52,  MODE_KIJUNSEN, 1 ); 

      if(now_tenkansen <= now_kijyunsen && before_tenkansen >= before_kijyunsen &&  TimeCurrent()-4000 >= tradeTime )
   {
   
      return 100;
   }

   if(now_tenkansen >= now_kijyunsen && before_tenkansen <= before_kijyunsen && TimeCurrent()-4000 >= tradeTime )
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

