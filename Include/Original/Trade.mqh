//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#include <stdlib.mqh>          // ライブラリインクルード
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property version   "1.00"
#property strict
#include <Original/Account.mqh>
#include <Original/TradeMethod.mqh>

class Trade
{
   //データ変数
   public: string NEW_ORDER_PATTERN;
   public: string PAYMENT_ORDER_PATTERN;
   //アカウントクラス
   public: Account account;
   //取引手法クラス
   public: TradeMethod method;
   
   public:
   Trade::Trade(string newOrderPattern , string paymentOrderPattern)
   {
      NEW_ORDER_PATTERN =newOrderPattern;
      PAYMENT_ORDER_PATTERN = paymentOrderPattern;

      //取引手法クラスをインスタンス化
      method  = new TradeMethod();
      //アカウント情報をインスタンス化   
      account = new Account();
   };

//新規注文を行う
public:
bool NewOrder(string symbol , double lots)
{

   //トレード実行チェック
   while(IsTradeContextBusy())Sleep(10);

   int ret ;
   ret = method.Order_Method(symbol,NEW_ORDER_PATTERN);

      int type;
      if(ret > 0)
      {
         type = OP_BUY;
      }else if(ret < 0){
         type = OP_SELL;
      }else{
         return true;
      }

      //トレード
      if(MarketOrder(symbol,type,lots))
         { 
             //成功でログに記載
             return true; 
        }
         else
        { 
             //失敗でログに記載
             return true; 
        }

} 

//決済注文を行う
public:
bool PaymentOrder()
{
   //建玉数を取得
   int order_history_num = OrdersTotal();

   //ポジション数だけループ
    int ret,i,osel ;
       ret = 0;
   
   double payment_lot;
   for(i = order_history_num -1 ; i >= 0  ; i=i-1)
   {

      //トレード実行チェック
      while(IsTradeContextBusy())Sleep(10);

      //チケット番号から建玉情報取得
      osel = OrderSelect( i , SELECT_BY_POS , MODE_TRADES);

      ret = method.Payment_Method(i,PAYMENT_ORDER_PATTERN);

      //決済しないならCONTINUE
      if( ret == 0)
      {
          continue;   
      }
      

      if (ret == 100 )
      {
        payment_lot = OrderLots();
      }else{
         payment_lot = OrderLots() * (double)ret /100.0;     
      }
      //決済注文
      // レートのリフレッシュ
      RefreshRates();      
      if(OrderClose( OrderTicket(), payment_lot,OrderClosePrice(),20,clrBlue))
      { 
               //成功でログに記載
               //トレード実行スレッドが終わるまで待つ。
      }
      else
      { 
               //失敗でログに記載
                printf("エラーコード:%d , 詳細:%s ",GetLastError() , ErrorDescription(GetLastError()));
               //再実行(n回失敗で return false;)
      }
}
return true;
} 

//+------------------------------------------------------------------+
//| 成行注文を行う
//+------------------------------------------------------------------+
public:
int MarketOrder(string symbol , int type , double lots)
{
   //プライスレート用変数
   int ticket_num;
   double price;
   
   // レートのリフレッシュ
   RefreshRates();

   if(type == OP_BUY)
   {
      price = Ask;
   }else{
      price = Bid;
   }
   //トレード
   ticket_num = OrderSend(   // 新規エントリー注文
                   symbol,   // 通貨ペア
                   type,     // オーダータイプ[OP_BUY / OP_SELL]
                   lots,     // ロット[0.01単位]
                   price,    // オーダープライスレート
                   20,       // スリップ上限    (int)[分解能 0.1pips]
                   0,        // ストップレート
                   0,        // リミットレート
                   "",       // オーダーコメント
                   001,       // マジックナンバー(識別用)
                   0,                        // オーダーリミット時間
                   clrRed                   // オーダーアイコンカラー
                   );
        
   // オーダーエラー
   if ( ticket_num == -1) {         
                printf("エラーコード:%d , 詳細:%s ",GetLastError() , ErrorDescription(GetLastError()));
                return -1 ;
   }
   return ticket_num;
}

//+------------------------------------------------------------------+
//| 全決済注文を行う　　　　　　　　　　　　　　　　　                                |
//+------------------------------------------------------------------+
public:
int AllOrderClose()
{
   int order_history_num = OrdersTotal();
   int i;
   bool ret,osel;
   for(i = order_history_num -1 ; i >= 0  ; i--){
      osel = OrderSelect( i , SELECT_BY_POS , MODE_TRADES);
      // レートのリフレッシュ
//      RefreshRates();      
      ret = OrderClose( OrderTicket(), OrderLots(),OrderClosePrice(),20,Red);
   //5秒まつ
   Sleep(5000);
   if ( ret == false) {         
                printf("エラーコード:%d , 詳細:%s ",GetLastError() , ErrorDescription(GetLastError()));
   }
      printf("#####");

   }
   return 0;
}

//+------------------------------------------------------------------+
//| 単一の決済注文を行う　　　　　　　　　　　　　　　　　                                |
//+------------------------------------------------------------------+
public:
int OnceOrderClose()
{
   bool ret,osel;
   osel = OrderSelect( 0 , SELECT_BY_POS , MODE_TRADES);
   ret = OrderClose( OrderTicket(), OrderLots(),OrderClosePrice(),20,Red);
   if ( ret == false) {         
                printf("エラーコード:%d , 詳細:%s ",GetLastError() , ErrorDescription(GetLastError()));
   }
   return 0;
}
};
