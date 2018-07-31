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
int period = PERIOD_H1;
int magic;
double tb;
double ts;

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
      for(int i=1; i<=OrdersTotal(); i++) {
         if(OrderSelect(i, SELECT_BY_POS)==true)
            int magic;
            magic = OrderMagicNumber();
            autoTrailStops(0.50, magic, 1.0);
            //if(OrderType()==OP_BUY) {tb = NormalizeDouble((OrderTakeProfit() - OrderOpenPrice()) * 0.75,4); trailStops(tb, magic, 1.0);}
            //if(OrderType()==OP_SELL) {ts = NormalizeDouble((OrderOpenPrice() - OrderTakeProfit()) * 0.75,4); trailStops(ts, magic, 1.0);}
         }
   static datetime tmp;

   if (tmp!=Time[0])
   {
      tmp = Time[0];
      double current_ma = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1);
      double previous_1 = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,2);
      double previous_2 = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,3);
      if((current_ma > previous_1) && (previous_2 > previous_1))
      {
         double vecinput[39];
         vecinput[0] =  iATR(pair,period,1,1);
         vecinput[1] =  iATR(pair,period,2,1);
         vecinput[2] =  iBearsPower(pair,period,1,4,1);
         vecinput[3] =  iBullsPower(pair,period,1,4,1);
         vecinput[4] =  iBullsPower(pair,period,2,4,1);
         vecinput[5] =  iBullsPower(pair,period,3,4,1);
         vecinput[6] =  iBullsPower(pair,period,89,4,1) - iBullsPower(pair,period,89,4,1+1);
         vecinput[7] =  iRSI(pair,period,89,PRICE_MEDIAN,1) - iRSI(pair,period,89,PRICE_MEDIAN,1+1);
         vecinput[8] =  iOpen(pair,period,1) - iClose(pair,period,1);
         vecinput[9] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[10] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+2) - iClose(pair,period,1+2));
         vecinput[11] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+3) - iClose(pair,period,1+3));
         vecinput[12] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+4) - iClose(pair,period,1+4));
         vecinput[13] =  iClose(pair,period,1) - iLow(pair,period,1);
         vecinput[14] =  iClose(pair,period,1) - iLow(pair,period,1) - (iClose(pair,period,1+1) - iLow(pair,period,1+1));
         vecinput[15] =  iClose(pair,period,1) - iLow(pair,period,1) - (iClose(pair,period,1+2) - iLow(pair,period,1+2));
         vecinput[16] =  iClose(pair,period,1) - iLow(pair,period,1) - (iClose(pair,period,1+3) - iLow(pair,period,1+3));
         vecinput[17] =  iClose(pair,period,1) - iLow(pair,period,1) - (iClose(pair,period,1+4) - iLow(pair,period,1+4));
         vecinput[18] =  iClose(pair,period,1) - iLow(pair,period,1) - (iClose(pair,period,1+5) - iLow(pair,period,1+5));
         vecinput[19] =  iClose(pair,period,1) - iLow(pair,period,1) - (iClose(pair,period,1+6) - iLow(pair,period,1+6));
         vecinput[20] =  iOpen(pair,period,1) - iClose(pair,period,1) + (iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[21] =  iOpen(pair,period,1) - iClose(pair,period,1) + (iOpen(pair,period,1+1) - iClose(pair,period,1+1)) + (iOpen(pair,period,1+2) - iClose(pair,period,1+2));
         vecinput[22] =  iClose(pair,period,1) - iLow(pair,period,1) + (iClose(pair,period,1+1) - iLow(pair,period,1+1));
         vecinput[23] =  iClose(pair,period,1) - iLow(pair,period,1) + (iClose(pair,period,1+1) - iLow(pair,period,1+1)) + (iClose(pair,period,1+2) - iLow(pair,period,1+2));
         vecinput[24] =  iClose(pair,period,1) - iLow(pair,period,1) + (iClose(pair,period,1+1) - iLow(pair,period,1+1)) + (iClose(pair,period,1+2) - iLow(pair,period,1+2)) + (iClose(pair,period,1+3) - iLow(pair,period,1+3));
         vecinput[25] =  iClose(pair,period,1) - iLow(pair,period,1) + (iClose(pair,period,1+1) - iLow(pair,period,1+1)) + (iClose(pair,period,1+2) - iLow(pair,period,1+2)) + (iClose(pair,period,1+3) - iLow(pair,period,1+3)) + (iClose(pair,period,1+4) - iLow(pair,period,1+4));
         vecinput[26] =  iBearsPower(pair,period,3,0,1);
         vecinput[27] = (MathAbs(iBearsPower(pair,period,3,0,1)) - MathAbs(iBullsPower(pair,period,3,0,1))) - (iBearsPower(pair,period,3,0,1) - iBullsPower(pair,period,3,0,1));
         vecinput[28] =  iBearsPower(pair,period,3,0,1) - iBullsPower(pair,period,3,0,1);
         vecinput[29] =  iBearsPower(pair,period,7,0,1) - iBullsPower(pair,period,7,0,1);
         vecinput[30] =  MathAbs(iOpen(pair,period,1) - iClose(pair,period,1)) - ((iHigh(pair,period,1) - MathMax(iOpen(pair,period,1),iClose(pair,period,1))) + (MathMin(iOpen(pair,period,1),iClose(pair,period,1)) - iLow(pair,period,1)));
         vecinput[31] =  (MathAbs(iOpen(pair,period,1) - iClose(pair,period,1))) - (MathAbs(iOpen(pair,period,1+1) - iClose(pair,period,1+1)));
         vecinput[32] =  iClose(pair,period,1) - iClose(pair,PERIOD_H4,iBarShift(pair,PERIOD_H4,iTime(pair,period,1))+1);
         vecinput[33] =  iHigh(pair,period,1) - iLow(pair,period,1+1);
         vecinput[34] =  iHigh(pair,period,1) - iLow(pair,period,1+2);
         vecinput[35] =  (iOpen(pair,period,1) - iClose(pair,period,1)) - (iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[36] =  MathAbs(iOpen(pair,period,1) - iClose(pair,period,1)) - MathAbs(iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[37] =  (iHigh(pair,period,1) - MathMax(iOpen(pair,period,1), iClose(pair,period,1))) - MathAbs(iOpen(pair,period,1) - iClose(pair,period,1));
         vecinput[38] =  (MathMin(iOpen(pair,period,1), iClose(pair,period,1)) - iLow(pair,period,1)) - MathAbs(iOpen(pair,period,1) - iClose(pair,period,1));
         
         // Run data through model
         RAssignVector(rhandle, "params",vecinput, ArraySize(vecinput));   
         double action_bst;
         RExecute(rhandle, "p <- predict(xgmodel, newdata=as.data.frame(t(as.numeric(as.character(params)))))");
         action_bst = RGetDouble(rhandle, "as.numeric(as.character(getPredictionResponse(p)))");
         Print(action_bst);

            if(action_bst == 1)
            {
               double prev_low = iLow(pair,period,2);
               double stop_loss_pips = (Ask - iLow(pair,period,1))*10000;
               double risk = AccountBalance() * 0.01;
               double vol = NormalizeDouble(((risk/stop_loss_pips) / 0.0001)/100000, 1);
               
               int ticket = OrderSend(
                  Symbol()
                  , OP_BUY
                  , vol
                  , Ask
                  , 1
                  , prev_low
                  , Ask + (1.255 * (stop_loss_pips/10000))
               );
               if (ticket < 0 ) {Print("Buy order failed with error #", GetLastError());}
               else Print("Buy order placed!!");   
               //SendNotification("buy order placed");
            }
         }

      if((current_ma < previous_1) && (previous_2 < previous_1))
      {
         double vecinput[60];
         vecinput[0] =  iATR(pair,period,1,1);
         vecinput[1] =  iATR(pair,period,2,1);
         vecinput[2] =  iATR(pair,period,3,1);
         vecinput[3] =  iATR(pair,period,1,1+1);
         vecinput[4] =  iATR(pair,period,8,1) - iATR(pair,period,8,1+1);
         vecinput[5] =  iATR(pair,period,13,1) -  iATR(pair,period,13,1+1);
         vecinput[6] =  iATR(pair,period,55,1) - iATR(pair,period,55,1+1);
         vecinput[7] =  iATR(pair,period,5,1) - iATR(pair,period,5,1+2);
         vecinput[8] =  iATR(pair,period,8,1) - iATR(pair,period,8,1+2);
         vecinput[9] =  iBearsPower(pair,period,1,4,1);
         vecinput[10] =  iBearsPower(pair,period,2,4,1);
         vecinput[11] =  iBearsPower(pair,period,3,4,1);
         vecinput[12] =  iBearsPower(pair,period,1,4,1+1);
         vecinput[13] =  iBearsPower(pair,period,3,4,1) - iBearsPower(pair,period,3,4,1+1);
         vecinput[14] =  iBearsPower(pair,period,5,4,1) - iBearsPower(pair,period,5,4,1+1);
         vecinput[15] =  iBearsPower(pair,period,8,4,1) - iBearsPower(pair,period,8,4,1+1);
         vecinput[16] =  iBearsPower(pair,period,13,4,1) - iBearsPower(pair,period,13,4,1+1);
         vecinput[17] =  iBearsPower(pair,period,21,4,1) - iBearsPower(pair,period,21,4,1+1);
         vecinput[18] =  iBearsPower(pair,period,34,4,1) - iBearsPower(pair,period,34,4,1+1);
         vecinput[19] =  iBearsPower(pair,period,55,4,1) - iBearsPower(pair,period,55,4,1+1);
         vecinput[20] =  iBearsPower(pair,period,89,4,1) - iBearsPower(pair,period,89,4,1+1);
         vecinput[21] =  iBullsPower(pair,period,1,4,1);
         vecinput[22] =  iBullsPower(pair,period,1,4,1+1);
         vecinput[23] =  iRSI(pair,period,21,PRICE_MEDIAN,1) - iRSI(pair,period,21,PRICE_MEDIAN,1+1);
         vecinput[24] =  iRSI(pair,period,34,PRICE_MEDIAN,1) - iRSI(pair,period,34,PRICE_MEDIAN,1+1);
         vecinput[25] =  iRSI(pair,period,55,PRICE_MEDIAN,1) - iRSI(pair,period,55,PRICE_MEDIAN,1+1);
         vecinput[26] =  iRSI(pair,period,89,PRICE_MEDIAN,1) - iRSI(pair,period,89,PRICE_MEDIAN,1+1);
         vecinput[27] =  iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1+1);
         vecinput[28] =  iOpen(pair,period,1) - iClose(pair,period,1);
         vecinput[29] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[30] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+2) - iClose(pair,period,1+2));
         vecinput[31] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+4) - iClose(pair,period,1+4));
         vecinput[32] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+5) - iClose(pair,period,1+5));
         vecinput[33] =  iOpen(pair,period,1) - iClose(pair,period,1) - (iOpen(pair,period,1+6) - iClose(pair,period,1+6));
         vecinput[34] =  iOpen(pair,period,1) - iClose(pair,period,1) + (iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[35] =  iOpen(pair,period,1) - iClose(pair,period,1) + (iOpen(pair,period,1+1) - iClose(pair,period,1+1)) + (iOpen(pair,period,1+2) - iClose(pair,period,1+2));
         vecinput[36] =  iOpen(pair,period,1) - iClose(pair,period,1) + (iOpen(pair,period,1+1) - iClose(pair,period,1+1)) + (iOpen(pair,period,1+2) - iClose(pair,period,1+2)) + (iOpen(pair,period,1+3) - iClose(pair,period,1+3));
         vecinput[37] =  iBearsPower(pair,period,17,0,1) - iBearsPower(pair,period,17,0,1+1);
         vecinput[38] =  iBearsPower(pair,period,28,0,1) - iBearsPower(pair,period,28,0,1+1);
         vecinput[39] =  iBearsPower(pair,period,25,0,1) - iBearsPower(pair,period,25,0,1+1);
         vecinput[40] =  iBearsPower(pair,period,32,0,1) - iBearsPower(pair,period,32,0,1+1);
         vecinput[41] =  iBullsPower(pair,period,3,0,1);
         vecinput[42] =  iBearsPower(pair,period,3,0,1) - iBullsPower(pair,period,3,0,1);
         vecinput[43] =  iBearsPower(pair,period,7,0,1) - iBullsPower(pair,period,7,0,1);
         vecinput[44] =  iHigh(pair,period,1+1) - iLow(pair,period,1+1);
         vecinput[45] =  iMomentum(pair,period,3,0,1) - iMomentum(pair,period,3,0,1+1);
         vecinput[46] =  iHigh(pair,period,1) - iClose(pair,period,1);
         vecinput[47] =  iOpen(pair,period,1) - iLow(pair,period,1);
         vecinput[48] =  MathAbs(iOpen(pair,period,1) - iClose(pair,period,1)) - ((iHigh(pair,period,1) - MathMax(iOpen(pair,period,1),iClose(pair,period,1))) + (MathMin(iOpen(pair,period,1),iClose(pair,period,1)) - iLow(pair,period,1)));
         vecinput[49] =  (iMA(pair,period,3,0,MODE_EMA,PRICE_MEDIAN,1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1)) - (iMA(pair,period,3,0,MODE_EMA,PRICE_MEDIAN,1+1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1+1));
         vecinput[50] =  (MathAbs(iOpen(pair,period,1) - iClose(pair,period,1))) - (MathAbs(iOpen(pair,period,1+1) - iClose(pair,period,1+1)));
         vecinput[51] =  iClose(pair,period,1) - iClose(pair,PERIOD_H4,iBarShift(pair,PERIOD_H4,iTime(pair,period,1))+1);
         vecinput[52] =  iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,1+1);
         vecinput[53] =  iHigh(pair,period,1+1) - iLow(pair,period,1);
         vecinput[54] =  iLow(pair,period,1) - iLow(pair,period,1+1);
         vecinput[55] =  iLow(pair,period,1) - iLow(pair,period,1+2);
         vecinput[56] =  (iOpen(pair,period,1) - iClose(pair,period,1)) - (iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[57] =  MathAbs(iOpen(pair,period,1) - iClose(pair,period,1)) - MathAbs(iOpen(pair,period,1+1) - iClose(pair,period,1+1));
         vecinput[58] =  (iHigh(pair,period,1) - MathMax(iOpen(pair,period,1), iClose(pair,period,1))) - MathAbs(iOpen(pair,period,1) - iClose(pair,period,1));
         vecinput[59] =  (MathMin(iOpen(pair,period,1), iClose(pair,period,1)) - iLow(pair,period,1)) - MathAbs(iOpen(pair,period,1) - iClose(pair,period,1));

         // Run data through model
         RAssignVector(rhandle, "params",vecinput, ArraySize(vecinput));   
         double action_bst;
         RExecute(rhandle, "p <- predict(xgmodel_sell, newdata=as.data.frame(t(as.numeric(as.character(params)))))");
         action_bst = RGetDouble(rhandle, "as.numeric(as.character(getPredictionResponse(p)))");
         Print(action_bst);

            if(action_bst == 1)
            {
               double prev_high = iHigh(pair,period,2);
               double stop_loss_pips = (iHigh(pair,period,1) - Bid)*10000;
               double risk = AccountBalance() * 0.01;
               double vol = NormalizeDouble(((risk/stop_loss_pips) / 0.0001)/100000, 1);
               int ticket = OrderSend(
                  Symbol()
                  , OP_SELL
                  , vol
                  , Bid
                  , 1
                  , prev_high
                  , Bid - (1.25 * (stop_loss_pips/10000))
               );
               if (ticket < 0 ) {Print("Buy order failed with error #", GetLastError());}
               else Print("Sell order placed!!");   
               //SendNotification("buy order placed");
            }
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
