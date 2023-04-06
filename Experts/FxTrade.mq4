//+------------------------------------------------------------------+
//|                                                      FxTrade.mq4 |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#include <Original/Trade.mqh>
#include <Original/ChartInfo.mqh>
#include <Original/Account.mqh>
#include <Original/Common.mqh>
#include <Original/FxConfig.mqh>

#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property version   "1.00"
#property strict

//クラス変数追加
FxConfig conf;
Trade *td;
ChartInfo *ci;
Account account;

//初期設定
int OnInit(){
  //コンフィグクラスをインスタンス化
  conf = FxConfig();

  //ファイル変数を設定
  if (!conf.InitConfig()){
    return -1;
  }

  //OnTimer頻度を設定
  EventSetTimer(conf.EVENT_SET_TIMER);
    
  //アカウント情報をインスタンス化   
  account = new Account();

  //取引クラスをインスタンス化
  td = new Trade(conf.NEW_ORDER_PATTERN,conf.PAYMENT_ORDER_PATTERN);

  //チャート情報取得クラスをインスタンス化
  ci = new ChartInfo(conf.SYMBOL);
    
  return 0;
}

void OnDeinit(const int reason){
  //--- destroy timer
  EventKillTimer();
}

void OnTick()
{
   //Print(ci.GetRate(MODE_ASK));   
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
  double lots = account.GetAccountMaxLots(conf.SYMBOL,conf.MAX_LEVERAGE);
  //決済取引チェック
  if(!td.PaymentOrder()){
    //エラーログ吐く
  }

  int order_history_num = OrdersTotal();
  
  if(order_history_num < conf.MAX_POSITION_NUM){
    //新規取引チェック
    if(!td.NewOrder(conf.SYMBOL,lots)){
          //エラーログ吐く
    }
  } 
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){
  
}
