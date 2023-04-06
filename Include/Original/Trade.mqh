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

class Trade
{
   //データ変数
   public: string NEW_ORDER_PATTERN;
   public: string PAYMENT_ORDER_PATTERN;

   public:
   Trade::Trade(string newOrderPattern , string paymentOrderPattern)
   {
      NEW_ORDER_PATTERN =newOrderPattern;
      PAYMENT_ORDER_PATTERN = paymentOrderPattern;
   };
//+------------------------------------------------------------------+
//| 成行注文を行う　　　　　　　　　　　　　　　　　                                |
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
                   001       // マジックナンバー(識別用)
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
   Print(order_history_num);
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

//+------------------------------------------------------------------+
//| 注文情報の取得　　　　　　　　　　　　　　　　　                                |
//+------------------------------------------------------------------+
void GetOrder(){

          // アカウント履歴の任意の注文を選択
           OrderSelect( 0 , SELECT_BY_POS , MODE_TRADES);
            Print("選択した注文のチケット番号    ：" ,OrderTicket()      );
            Print("選択した注文の注文時間        ：" ,OrderOpenTime()   );
            Print("選択した注文の注文価格        ：" ,OrderOpenPrice()  );
            Print("選択した注文の注文タイプ      ：" ,OrderType()        );
            Print("選択した注文のロット数        ：" ,OrderLots()        );
            Print("選択した注文の通貨ペア        ：" ,OrderSymbol()      );
            Print("選択した注文のストップロス価格：" ,OrderStopLoss()   );
            Print("選択した注文のリミット価格    ：" ,OrderTakeProfit() );
            Print("選択した注文の決済時間        ：" ,OrderCloseTime()  );
            Print("選択した注文の決済価格        ：" ,OrderClosePrice() );
            Print("選択した注文の手数料          ：" ,OrderCommission() );
            Print("選択した注文の保留有効期限    ：" ,OrderExpiration() );
            Print("選択した注文のスワップ        ：" ,OrderSwap()        );
            Print("選択した注文の損益            ：" ,OrderProfit()      );
            Print("選択した注文のコメント        ：" ,OrderComment()     );
            Print("選択した注文のマジックナンバー：" ,OrderMagicNumber());
}

//新規注文を行う
public:
bool NewOrder(string symbol , double lots)
{

   //トレード実行チェック
   while(IsTradeContextBusy())Sleep(10);

   int ret ;
       ret = 0;
      if (NEW_ORDER_PATTERN == "NewOrder_Pattern1")
       {   ret = Order_Pattern1(symbol);}
       else if(NEW_ORDER_PATTERN == "NewOrder_Pattern2")
       {   ret = Order_Pattern2(symbol);}

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

      if (PAYMENT_ORDER_PATTERN == "Payment_Pattern1")
         {ret =Payment_Pattern1(i);}
       else
         { ret =   Payment_Pattern2(i);}

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
      if(OrderClose( OrderTicket(), payment_lot,OrderClosePrice(),20,Red))
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

//パターン１_新規
private:
int Order_Pattern1(string symbol)
{

   return 100;
}

//パターン2_新規注文
private:
int Order_Pattern2(string symbol)
{

   return 100;
}


//パターン１_決済
private:
int Payment_Pattern1(int ticket)
{
   bool osel;
   osel = OrderSelect( ticket , SELECT_BY_POS , MODE_TRADES);

   // レートのリフレッシュ
   RefreshRates();    
   if(   OrderOpenPrice() < Bid)
   {
      return 100;
   } 
   return 0;
}

//パターン2_決済
private:
int Payment_Pattern2(int ticket)
{
   return 100;
}
};
