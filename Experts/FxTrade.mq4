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
  //設定したチャートを取得
  if(!ci.SetChart())
  {
    printf("Error");
  }else{
   printf("OK");
  }
  
  return 0;
}

void OnDeinit(const int reason){
  //--- destroy timer
  EventKillTimer();
}

void OnTimer()
{

}

void OnTick()
{
  double lots = account.GetAccountMaxLots(conf.SYMBOL,conf.MAX_LEVERAGE);
  //決済取引チェック
  if(!td.PaymentOrder()){
   
    //エラーログ吐く
      printf("決済しません");
 
  }

  int order_history_num = OrdersTotal();
  
  //建玉数が最大建玉数より多い場合新規注文を行わない。
  if(order_history_num >= conf.MAX_POSITION_NUM){
      printf("建玉オーバー");
      return;
  }

  //現在資産が過去最大資産のX％以下の場合取引を行わない
  if(account.GetAccountBarance() <= conf.MAX_BALANCE*conf.SAVING_BALANCE){
      printf("資産少ない");
      return;
  }

  //新規取引チェック
  if(!td.NewOrder(conf.SYMBOL,lots)){
          //エラーログ吐く
      printf("新規しません");

  }


} 

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){
  
}

