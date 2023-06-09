//+------------------------------------------------------------------+
//|                                                     Datusara.mq4 |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| 初期処理                             |
//+------------------------------------------------------------------+
int OnInit()
  {
  Print("初期化処理");
//--- OnTimerが呼び出される時間間隔を設定[s]
   EventSetTimer(10);
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| 初期化解除時処理  
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
  Print("初期化解除処理");
   //タイマーを無効化
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| EventSetTimerで指定した時間間隔で呼び出される             
//+------------------------------------------------------------------+
void OnTimer(){
  Print("一定時間処理");
   string symbol;
   int cmd;
   double volume;
   double price;
   int slippage;
   double stoploss;
   double takeprofit;
   string comment=NULL;
   int magic=0;
   datetime expiration=0;
   color arrow_color=clrNONE;

// 一定時間毎に実行したい処理を書く
    int filehandle;                    // ファイルハンドラ
    // 書き込むファイルを開く
    filehandle = FileOpen(
            "receive//order.csv",    // ファイル名
             FILE_CSV,  // ファイル操作モードフラグ
            ","                     // セパレート文字コード
    );

    if ( filehandle == INVALID_HANDLE ) { // ファイルオープンエラー
         Print("ファイルが存在しません");
    } else {
        //ファイル内容
        symbol = FileReadString(filehandle);
        cmd = (int)FileReadString(filehandle);
        volume = (double)FileReadString(filehandle);
        price = (double)FileReadString(filehandle);
        slippage = (int)FileReadString(filehandle);
        stoploss = (double)FileReadString(filehandle);
        takeprofit = (double)FileReadString(filehandle);
        comment = FileReadString(filehandle);
        magic = (int)FileReadString(filehandle);
        
        int ticket = 0;
        if(cmd == OP_BUY){       
            ticket = OrderSend(symbol,cmd,volume,Ask,slippage,stoploss,takeprofit,comment,magic,0,clrRed);
        }else if(cmd == OP_SELL){
            ticket = OrderSend(symbol,cmd,volume,Bid,slippage,stoploss,takeprofit,comment,magic,0,clrBlue);
        }
        if ( ticket == -1) {    
            PrintFormat("Error! Code = %d",GetLastError());
        }
       //OrderSendError
       PrintFormat("Error! Code = %d",GetLastError());

        FileClose(filehandle);      // ファイルハンドラクローズ
        if(FileMove("receive//order.csv",0,"backup//order_"+GetDateTimeToStr()+".csv",FILE_READ))
        {
            Print("バックアップに移動しました");
        }else{
            PrintFormat("Error! Code = %d",GetLastError());
        }
    }
}
//+------------------------------------------------------------------+
//| 現在時刻YYYYMMDDHHMMSSを文字列形式で返却する      
//+------------------------------------------------------------------+
string GetDateTimeToStr(){
    datetime now = TimeLocal();
    string strNow = StringFormat("%4d%02d%02d%02d%02d%02d",
      TimeYear(now),
      TimeMonth(now),
      TimeDay(now),
      TimeHour(now),
      TimeMinute(now),
      TimeSeconds(now));
    return strNow;
}
