//+------------------------------------------------------------------+
//|                                                       Wallet.mqh |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property strict

class Account{
   public:
   Account::Account(void)
   {

   };

   //+------------------------------------------------------------------+
   //| 現在アカウントのロットを返す
   //+------------------------------------------------------------------+
   public:
   double GetAccountMaxLots(string symbol,int leverage)
   {
      double ret;
      // レートのリフレッシュ
      RefreshRates();      
      ret = int(AccountBalance()*leverage/(Ask*100000.0)*100.0)/100.0;
      return ret;
   }

   //+------------------------------------------------------------------+
   //| 現在アカウントの口座残高を返す
   //+------------------------------------------------------------------+
   public:
   double GetAccountBarance()
   {
      return AccountBalance();
   }
};