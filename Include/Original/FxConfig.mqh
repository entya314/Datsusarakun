//+------------------------------------------------------------------+
//|                                                       Config.mqh |
//|                                      Copyright 2021, PastelDrops |
//|                                          https://pasteldrops.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PastelDrops"
#property link      "https://pasteldrops.com"
#property strict

class FxConfig{

//インスタンス
public:
   FxConfig::FxConfig(void)
   {
   
   };

//CSVデータ変数
 public: int EVENT_SET_TIMER;
 public: string SYMBOL;
 public: double SAVING_BALANCE;
 public: int MAX_POSITION_NUM;
 public: string NEW_ORDER_PATTERN;
 public: string PAYMENT_ORDER_PATTERN;
 public: int MAX_LEVERAGE;
//CSVデータから変数登録を行う
public:
bool InitConfig()
{
    GetConfig();
    GetData();
    return true;
}

//CSVデータから変数登録を行う
private:
bool GetConfig()
{
   //ファイルハンドラ
   int filehandle;
   //ファイルを開く
   filehandle = FileOpen(
            "FxTradeConfig.csv",  // ファイル名
            FILE_READ,            // ファイル操作モードフラグ
            ','                   // セパレート文字コード
    );
    
    
    if ( filehandle == INVALID_HANDLE ) { 
      // ファイルオープンエラー
      printf( "ファイルオープンエラー1");
      return false;
    } else {
      //GetFile
         EVENT_SET_TIMER = (int)ReadData(filehandle);
         SYMBOL = ReadData(filehandle);
         SAVING_BALANCE = (double)ReadData(filehandle);
         MAX_POSITION_NUM = (int)ReadData(filehandle);
         NEW_ORDER_PATTERN = ReadData(filehandle);
         PAYMENT_ORDER_PATTERN = ReadData(filehandle);
         MAX_LEVERAGE = (int)ReadData(filehandle);
         FileClose(filehandle);      // ファイルハンドラクローズ
         return true;
    }
}

//CSVデータ変数
 public: double MAX_BALANCE;

//CSVデータから変数登録を行う
private:
bool GetData()
{
   //ファイルハンドラ
   int filehandle;
   //ファイルを開く
   filehandle = FileOpen(
            "FxTradeData.csv",  // ファイル名
            FILE_READ,            // ファイル操作モードフラグ
            ','                   // セパレート文字コード
    );
    
    
    if ( filehandle == INVALID_HANDLE ) { 
      // ファイルオープンエラー
      printf( "ファイルオープンエラー2");
      return false;
    } else {
      //GetFile
         MAX_BALANCE = (double)ReadData(filehandle);
         FileClose(filehandle);      // ファイルハンドラクローズ
         return true;
    }
}

//CSVデータから変数登録を行う
public:
bool SetData()
{
   //ファイルハンドラ
   int filehandle;
   //ファイルを開く
   filehandle = FileOpen(
            "FxTradeData.csv",  // ファイル名
            FILE_WRITE,            // ファイル操作モードフラグ
            ','                   // セパレート文字コード
    );
    
    
    if ( filehandle == INVALID_HANDLE ) { 
      // ファイルオープンエラー
      printf( "ファイルオープンエラー");
      return false;
    } else {
      //GetFile
         FileWrite( filehandle , MAX_BALANCE );
         FileClose(filehandle);      // ファイルハンドラクローズ
         return true;
    }
}

//CSVデータから変数登録を行う
public:
bool SetLogData(int state , string msg)
{
   //ファイルハンドラ
   int filehandle;
   //ファイルを開く
   filehandle = FileOpen(
            "FxTradeLog.csv",  // ファイル名
            FILE_WRITE,            // ファイル操作モードフラグ
            ','                   // セパレート文字コード
    );
    
    
    if ( filehandle == INVALID_HANDLE ) { 
      // ファイルオープンエラー
      printf( "ファイルオープンエラー");
      return false;
    } else {
      //GetFile
         FileWrite( filehandle , MAX_BALANCE );
         FileClose(filehandle);      // ファイルハンドラクローズ
         return true;
    }
}



//+------------------------------------------------------------------+
//| データ読み取り
//+------------------------------------------------------------------+
private:
string ReadData( int in_filehandle ){    
    return FileReadString( in_filehandle );    
  }
};
