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



//共通
//随時逆指値を更新していくプログラム
//引数：チケット番号、パーセンテージ
//建玉値100.00、現在値101.00 80％なら100.80に逆指値を置く
//startProfit 利益がn％
public:
bool Stop_Order_Update(double startProfit, string flg ,double value)
{
   if(value == 0){
      return true;
   }

   //インデックス番号の取得
   bool osel,modify_ret;
   int orderType,paymentType,errorcode;
   double stopLoss,openPrice,price,stopPrice;
   modify_ret = true;

   //建玉数を取得
   int order_history_num = OrdersTotal();

   //ポジション数だけループ
   int ret,i ;
   ret = 0;
   
   for(i = order_history_num -1 ; i >= 0  ; i=i-1)
   {
      //トレード実行チェック
      while(IsTradeContextBusy())Sleep(10);
      osel = OrderSelect( i , SELECT_BY_POS , MODE_TRADES);

      orderType = OrderType();  
      openPrice = OrderOpenPrice();
      stopLoss = OrderStopLoss()  ;
   
      if (orderType == OP_BUY || orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP){
         paymentType = MODE_BID;
      }else if(orderType == OP_SELL || orderType == OP_SELLLIMIT || orderType == OP_SELLSTOP){
         paymentType = MODE_ASK;
      }else{
         printf("ErrorStop_Order_Update");
         return false;
      }

      //現在の通貨金額を取得
      price = MarketInfo(OrderSymbol(),paymentType);
      stopPrice = 0;
      if(paymentType == MODE_BID && openPrice + startProfit < price){   //買建玉のストップロス算出
         //ストップロスレートの算出
         if(flg == "PRECENT"){
            stopPrice = openPrice + (price -openPrice)* (value/100.0);
         }else if(flg =="RATE"){
            stopPrice = openPrice - value;
         }
      }   
      else if(paymentType == MODE_ASK && openPrice - startProfit > price){   //売建玉の時のストップロス算出   
         //ストップロスレートの算出
         if(flg == "PRECENT"){
            stopPrice = openPrice + (price -openPrice)* (value/100.0);
         }else if(flg =="RATE"){
            stopPrice = openPrice + value;
         }
      }else{
         continue;
      }


      if((paymentType == MODE_BID && stopPrice > stopLoss) ||(paymentType == MODE_ASK && stopPrice < stopLoss) || stopLoss ==0.0 ){
         //指値変更
         modify_ret = OrderModify(
                        OrderTicket(),      // チケットNo
                        OrderOpenPrice(),  // 注文価格
                        stopPrice,            // ストップロス価格
                        OrderTakeProfit(),           // リミット価格
                        OrderExpiration(), // 有効期限
                        clrBrown               // 色
                     );

         if ( modify_ret == false ) {             // 注文変更拒否
            errorcode = GetLastError();        // エラーコード取得
            printf(ErrorDescription(errorcode));
         }
      }
   } 
   return modify_ret;
}


//+------------------------------------------------------------------+
//| 成行注文を行う
//+------------------------------------------------------------------+
public:
int MarketOrder(string symbol , int type , double lots)
{
   //プライスレート用変数
   int ticket_num;
   int chart_clr;
   double price;
   
   // レートのリフレッシュ
   RefreshRates();

   if(type == OP_BUY)
   {
      price = Ask;
      chart_clr = clrRed;
   }else{
      price = Bid;
      chart_clr = clrBlue;
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
                   chart_clr                   // オーダーアイコンカラー
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
