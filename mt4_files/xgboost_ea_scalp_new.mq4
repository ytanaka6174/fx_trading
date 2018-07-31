//+------------------------------------------------------------------+
//|                                           boost_price_action.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <mt4R.mqh> 
#include <common_functions.mqh>

extern string R_command = "C:\Program Files\R\R-3.4.1\bin\i386\Rterm.exe --no-save";
extern int R_debuglevel = 2; // debug level for Rinit
int rhandle;
string pair = "EURUSD";
int period = PERIOD_M1;
int magic;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   rhandle = RInit(R_command, R_debuglevel);
      RExecute(rhandle, "library(xgboost)");
      RExecute(rhandle, "library(mlr)");
      RExecute(rhandle, "library(ParamHelpers)");
      Print("libraries loaded");
      RExecute(rhandle, "setwd(\"C:/Users/Yoshizo/Desktop/fx_trading/R_files\")");           
      RExecute(rhandle, "load(\"xgmodel_buy.rda\")");
      RExecute(rhandle, "load(\"xgmodel_sell.rda\")");  
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(OrdersTotal() > 0)
      for(int i =1; i<=OrdersTotal(); i++) {
         if(OrderSelect(i, SELECT_BY_POS)==true)
         int magic;
         magic = OrderMagicNumber();
         double sp = Ask - Bid;
         trailStops(.0002, magic, 1.1);
         }
   static datetime tmp;   
   if (tmp!=Time[0])
   {
      tmp = Time[0];
      double vecinput[62];
      vecinput[0] = iAC(pair, period, 1) - iAC(pair, period, 2);
      vecinput[1] = iAO(pair, period, 1) - iAO(pair, period, 2);
      vecinput[2] = iBearsPower(pair,period,3,0,1);
      vecinput[3] = iBearsPower(pair,period,3,0,1) - iBearsPower(pair,period,3,0,2);
      vecinput[4] = iBearsPower(pair,period,3,0,1) / iBearsPower(pair,period,3,0,2);
      vecinput[5] = iBearsPower(pair,period,5,0,1);
      vecinput[6] = iBearsPower(pair,period,5,0,1) - iBearsPower(pair,period,5,0,2);
      vecinput[7] = iBearsPower(pair,period,5,0,1) / iBearsPower(pair,period,5,0,2);
      vecinput[8] = iBearsPower(pair,period,7,0,1);
      vecinput[9] = iBearsPower(pair,period,7,0,1) - iBearsPower(pair,period,7,0,2);
      vecinput[10] = iBearsPower(pair,period,7,0,1) / iBearsPower(pair,period,7,0,2)                     ;
      vecinput[11] = iBearsPower(pair,period,13,0,1);
      vecinput[12] = iBearsPower(pair,period,13,0,1) - iBearsPower(pair,period,13,0,2);
      vecinput[13] = iBearsPower(pair,period,17,0,1);
      vecinput[14] = iBearsPower(pair,period,17,0,1) - iBearsPower(pair,period,17,0,2);
      vecinput[15] = iBullsPower(pair,period,3,0,1);
      vecinput[16] = iBullsPower(pair,period,3,0,1) - iBullsPower(pair,period,3,0,2);
      vecinput[17] = iBullsPower(pair,period,3,0,1) / iBullsPower(pair,period,3,0,2)                     ;
      vecinput[18] = iBullsPower(pair,period,5,0,1);
      vecinput[19] = iBullsPower(pair,period,5,0,1) - iBullsPower(pair,period,5,0,2);
      
      vecinput[20] = iBullsPower(pair,period,5,0,1) / iBullsPower(pair,period,5,0,2);
      vecinput[21] = iBullsPower(pair,period,7,0,1) ;
      vecinput[22] = iBullsPower(pair,period,7,0,1) - iBullsPower(pair,period,7,0,2);
      vecinput[23] = iBullsPower(pair,period,7,0,1) / iBullsPower(pair,period,7,0,2)                                         ;
      vecinput[24] = iBullsPower(pair,period,13,0,1);
      vecinput[25] = iBullsPower(pair,period,13,0,1) - iBullsPower(pair,period,13,0,2);
      vecinput[26] = iBullsPower(pair,period,17,0,1);
      vecinput[27] = iBullsPower(pair,period,17,0,1) - iBullsPower(pair,period,17,0,2);
      vecinput[28] = iBullsPower(pair,period,25,0,1);
      vecinput[29] = (MathAbs(iBearsPower(pair,period,5,0,1)) - MathAbs(iBullsPower(pair,period,5,0,1))) - (iBearsPower(pair,period,5,0,1) - iBullsPower(pair,period,5,0,1));
      vecinput[30] = MathAbs(iBearsPower(pair,period,5,0,1)) - MathAbs(iBullsPower(pair,period,5,0,1));
      vecinput[31] = iBearsPower(pair,period,5,0,1) + iBullsPower(pair,period,5,0,1);
      vecinput[32] = (iBearsPower(pair,period,5,0,1) + iBullsPower(pair,period,5,0,1)) - (iBearsPower(pair,period,5,0,2) + iBullsPower(pair,period,5,0,2));
      vecinput[33] = (MathAbs(iBearsPower(pair,period,3,0,1)) - MathAbs(iBullsPower(pair,period,3,0,1))) - (iBearsPower(pair,period,3,0,1) - iBullsPower(pair,period,3,0,1));
      vecinput[34] = MathAbs(iBearsPower(pair,period,3,0,1)) - MathAbs(iBullsPower(pair,period,3,0,1));
      vecinput[35] = iBearsPower(pair,period,3,0,1) + iBullsPower(pair,period,3,0,1);
      vecinput[36] = (iBearsPower(pair,period,5,0,1) + iBullsPower(pair,period,5,0,1)) - (iBearsPower(pair,period,5,0,2) + iBullsPower(pair,period,5,0,2));
      vecinput[37] = (MathAbs(iBearsPower(pair,period,7,0,1)) - MathAbs(iBullsPower(pair,period,7,0,1))) - (iBearsPower(pair,period,7,0,1) - iBullsPower(pair,period,7,0,1));
      vecinput[38] = MathAbs(iBearsPower(pair,period,7,0,1)) - MathAbs(iBullsPower(pair,period,7,0,1));
      vecinput[39] = iBearsPower(pair,period,7,0,1) + iBullsPower(pair,period,7,0,1);
      vecinput[40] = (iBearsPower(pair,period,7,0,1) + iBullsPower(pair,period,7,0,1)) - (iBearsPower(pair,period,7,0,2) + iBullsPower(pair,period,7,0,2))                     ;
      vecinput[41] = ((MathAbs(iBearsPower(pair,period,5,0,1)) - MathAbs(iBearsPower(pair,period,5,0,2))) - (iBearsPower(pair,period,5,0,1) - iBearsPower(pair,period,5,0,2))) - ((MathAbs(iBullsPower(pair,period,5,0,1)) - MathAbs(iBullsPower(pair,period,5,0,2))) - (iBullsPower(pair,period,5,0,1) - iBullsPower(pair,period,5,0,2)));
      vecinput[42] = ((MathAbs(iBearsPower(pair,period,5,0,1)) - MathAbs(iBearsPower(pair,period,5,0,3))) - (iBearsPower(pair,period,5,0,1) - iBearsPower(pair,period,5,0,3))) - ((MathAbs(iBullsPower(pair,period,5,0,1)) - MathAbs(iBullsPower(pair,period,5,0,3))) - (iBullsPower(pair,period,5,0,1) - iBullsPower(pair,period,5,0,3)));
      vecinput[43] = iSAR(pair,period,.02,.2,1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1);
      vecinput[44] = iBearsPower(pair,period,5,0,1) - iBearsPower(pair,period,5,0,iBarShift(pair,PERIOD_M5,iTime(pair,period,1))+1);
      vecinput[45] = iBullsPower(pair,period,5,0,1) - iBullsPower(pair,period,5,0,iBarShift(pair,PERIOD_M5,iTime(pair,period,1))+1);
      vecinput[46] = iADX(pair,period,7,PRICE_MEDIAN,MODE_MAIN,1) - iADX(pair,period,7,PRICE_MEDIAN,MODE_MINUSDI,1);
      vecinput[47] = iOpen(pair,period,2) - iClose(pair,period,2);
      vecinput[48] = iMomentum(pair,period,3,0,1)            ;
      vecinput[49] = iMomentum(pair,period,5,0,1)       ;
      vecinput[50] = iMomentum(pair,period,7,0,1);
      vecinput[51] = iLow(pair,period,1) - iLow(pair,PERIOD_M5,iBarShift(pair,PERIOD_M5,iTime(pair,period,1))+1);
      vecinput[52] = iLow(pair,period,1) - iLow(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,1))+1);
      vecinput[53] = iHigh(pair,period,1) - iHigh(pair,PERIOD_M5,iBarShift(pair,PERIOD_M5,iTime(pair,period,1))+1);
      vecinput[54] = iHigh(pair,period,1) - iHigh(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,1))+1);
      vecinput[55] = iClose(pair,period,1) - iClose(pair,PERIOD_M5,iBarShift(pair,PERIOD_M5,iTime(pair,period,1))+1);
      vecinput[56] = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,2);
      vecinput[57] = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,3);
      vecinput[58] = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,4);
      vecinput[59] = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,2) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,3);
      vecinput[60] = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1) < iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,2) ? 1 : 0;
      vecinput[61] = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1) > iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,2) ? 1 : 0;

      RAssignVector(rhandle, "params",vecinput, ArraySize(vecinput));   
      double buy_signal;
      double sell_signal;      
      RExecute(rhandle, "p_buy <- predict(xgmodel_buy, newdata=as.data.frame(t(as.numeric(as.character(params)))))");
      RExecute(rhandle, "p_sell <- predict(xgmodel_sell, newdata=as.data.frame(t(as.numeric(as.character(params)))))");
      buy_signal = RGetDouble(rhandle, "as.numeric(as.character(getPredictionResponse(p_buy)))");
      sell_signal = RGetDouble(rhandle, "as.numeric(as.character(getPredictionResponse(p_sell)))");
      Print(StringConcatenate(buy_signal, sell_signal));
      double spread = Ask - Bid;
      double arr[8];
      arr[0] = iATR(pair,period,3,1);
      arr[1] = iATR(pair,period,7,1);
      arr[2] = iATR(pair,period,14,1);
      arr[3] = iATR(pair,period,21,1);
      arr[4] = iATR(pair,period,28,1);
      arr[5] = iATR(pair,period,35,1);
      arr[6] = iATR(pair,period,42,1);
      arr[7] = iATR(pair,period,49,1);
      double buystoploss = /*Bid - spread - 0.001;*/Bid - arr[ArrayMaximum(arr)] - spread;
      double buytakeprofit = Ask + 0.0008;
      double sellstoploss = /*Ask + spread + 0.001;*/Ask + arr[ArrayMaximum(arr)] + spread;
      double selltakeprofit = Bid - 0.0008;
      if(buy_signal == 1 && sell_signal == 0 && OrdersTotal()< 1)
      {
         double free_margin;     
         free_margin = AccountFreeMargin();
         double vol;
         vol = ((free_margin/1.5)*AccountLeverage())/(Bid*100000);
         int ticket = OrderSend(
            Symbol()
            , OP_BUY
            , vol
            , Ask
            , 1
            , buystoploss
            , buytakeprofit
            );
         if (ticket < 0 ) {Print("Buy order failed with error #", GetLastError());}
         else Print("Buy order placed!!");   
         //SendNotification("buy order placed");
      }
      else if(buy_signal == 0 && sell_signal == 1 && OrdersTotal()< 1)
      {
         double free_margin;     
         free_margin = AccountFreeMargin();
         double vol;
         vol = ((free_margin/1.5)*AccountLeverage())/(Bid*100000);
         int ticket = OrderSend(
            Symbol()
            , OP_SELL
            , vol
            , Bid
            , 1
            , sellstoploss
            , selltakeprofit
            );
         if (ticket < 0 ) {Print("Sell order failed with error #", GetLastError());}
         else Print("Sell order placed!!");   
         //SendNotification("sell order placed");
      }
   }   
   return;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{ 
   RDeinit(rhandle);
}
