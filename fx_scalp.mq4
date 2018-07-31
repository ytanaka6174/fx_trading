//+------------------------------------------------------------------+
//|                                                  fx_combined.mq4 |
//|                                                  Yoshizou Tanaka |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Yoshizou Tanaka"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+

// Currency and Period
string pair = "EURUSD";
int period = PERIOD_M30;
int ma_applied_price = 4; //PRICE_MEDIAN;

// Number of features (not including signal)
int feature_num = 51;

// Start and End bars
int bar_start = iBarShift(pair,period,"2016.01.01 00:00");
int bar_end = iBarShift(pair,period,"2017.11.30 00:00");
int bar_num = bar_start - bar_end;

// Script Begin
void OnStart(){
//int signal[]; //signal vector
double signal[];
ArrayResize(signal,bar_num);

//+------------------------------------------------------------------+
//| SIGNAL                                                           |
//+------------------------------------------------------------------+
//for(int i=0; i<bar_num; i++) {
//   double ma_current = iMA(pair,period,1,0,MODE_SMA,ma_applied_price,bar_start - i);
//   double ma_previous = iMA(pair,period,1,0,MODE_SMA,ma_applied_price,bar_start - i + 1);
//   double pip_threshold = 0.0010;
//   if (ma_current < ma_previous){
//      for (int j=0; j<60; j++){
//         if (iMA(pair,period,1,0,MODE_SMA,ma_applied_price,bar_start-i-j-1) < ma_current) {break;}
//         if (iMA(pair,period,1,0,MODE_SMA,ma_applied_price,bar_start-i-j-1) - ma_current >= pip_threshold) {signal[i] = 1; break;}
//         else{continue;}
//      }
//   }
//   else if (ma_current > ma_previous){
//      for (int j=0; j<60; j++){
//         if (iMA(pair,period,1,0,MODE_SMA,ma_applied_price,bar_start-i-j-1) > ma_current) {break;}
//         if (ma_current - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,bar_start-i-j-1) >= pip_threshold) {signal[i] = 2; break;}
//         else{continue;}
//      }      
//   }
//   else {signal[i] = 0;}
//}

for(int i=0; i<bar_num; i++) {
signal[i] = iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i-1);
}

//for(int i=0; i<bar_num; i++) {   
//   //BUY SIGNAL
//   if (
//       //iLow(pair, period, bar_start - i + 1) > iLow(pair, period, bar_start - i)
//       //&& iLow(pair, period, bar_start - i + 2) > iLow(pair, period, bar_start - i + 1)
//       //iLow(pair, period, bar_start - i - 1) > iLow(pair, period, bar_start -i)
//       //&& iLow(pair, period, bar_start - i -2) > iLow(pair, period, bar_start -i -1)
//       iHigh(pair,period,bar_start-i-1) - iClose(pair,period,bar_start-i) >= 0.0002
//       && iClose(pair,period,bar_start-i) >= iLow(pair,period,bar_start-i-1)
//       )
//      {signal[i] = 1;}
//
//   // SELL SIGNAL
//   else if (
//       //iHigh(pair, period, bar_start - i + 1) < iHigh(pair, period, bar_start - i)
//       //&& iHigh(pair, period, bar_start - i + 2) < iHigh(pair, period, bar_start - i + 1)
//       //iHigh(pair, period, bar_start - i - 1) < iHigh(pair, period, bar_start -i)
//       //&& iHigh(pair, period, bar_start - i -2) < iHigh(pair, period, bar_start -i -1)
//       iClose(pair,period,bar_start-i) - iLow(pair,period,bar_start-i-1) >= 0.0002
//       && iClose(pair,period,bar_start-i) <= iHigh(pair,period,bar_start-i-1)
//      )
//      {signal[i] = 2;}
//
//   // NO ACTION SIGNAL
//   else
//      {signal[i] = 0;}
//}


//double high_prices[2];
//double low_prices[2];
//for(int i=0; i<bar_num; i++) {
//   for (int j=0; j<2; j++){
//      high_prices[j] = iHigh(pair,period,bar_start-i-j-1);
//      low_prices[j] = iLow(pair,period,bar_start-i-j-1);
//   }
//   if (iLow(pair,period,bar_start-i) < low_prices[ArrayMinimum(low_prices)] && high_prices[ArrayMaximum(high_prices)] - iLow(pair,period,bar_start-i) >= 0.0004)
//      {signal[i] = 1;}
//   else if (iHigh(pair,period,bar_start-i) > high_prices[ArrayMaximum(high_prices)] && iHigh(pair,period,bar_start-i) - low_prices[ArrayMinimum(low_prices)] >= 0.0004)
//      {signal[i] = 2;}
//   else
//      {signal[i] = 0;}
//}

//+------------------------------------------------------------------+
//| FEATURES                                                         |
//+------------------------------------------------------------------+

   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
   string filename=terminal_data_path+"\\MQL4\\Files\\"+"fx_scalp.csv";
   int filehandle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV,',');
   filehandle=FileOpen("fx_scalp.csv",FILE_READ|FILE_WRITE|FILE_CSV,',');
   if(filehandle!=INVALID_HANDLE){
      //Naming features and signal by integers for simplicity (starting names at feature_1)
      //Also remember MQL4 can only export 64 columns of data at once
      string names[];
      ArrayResize(names, feature_num);
         for(int i = 0; i < feature_num; i++){
            if(i == 0) { names[i] = "feature_" + (i+1);}
            else names[i] = names[i-1] + "," + "feature_" + (i+1);
         }
      FileWrite(filehandle, names[feature_num - 1], "signal");
      
      //Write features
      for(int i=bar_start; i>bar_end; i--) {
         FileWrite(filehandle
                     //, TimeToString(iTime(pair,period,i),TIME_DATE|TIME_MINUTES)
                     //, iAC(pair, period, i) - iAC(pair, period, i+1)
                     //, iAC(pair,period, i) - iAC(pair,PERIOD_M5,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1)
                     //, iAC(pair,period, i) - iAC(pair,period,i+2)
                     //, iAC(pair,period,i)
                     //, iAO(pair, period, i) - iAO(pair, period, i+1)
                     //, iAO(pair,period, i) - iAO(pair,PERIOD_M5,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1)
                     //, iAO(pair,period, i) - iAO(pair,period, i+2)
                     //, iATR(pair,period,3,i)
                     //, iATR(pair,period,5,i)
                     //, iATR(pair,period,7,i)
                     //, iATR(pair,period,10,i)
                     //, iATR(pair,period,13,i)
                     //, iATR(pair,period,17,i)
                     //, iATR(pair,period,25,i)
                     //, iATR(pair,period,30,i)                     
                     //, iATR(pair,period,35,i)
                     //, iATR(pair,period,40,i)
                     //, iBearsPower(pair,period,3,0,i)
                     //, iBearsPower(pair,period,3,0,i) - iBearsPower(pair,period,3,0,i+1)
                     //, iBearsPower(pair,period,3,0,i) / iBearsPower(pair,period,3,0,i+1)
                     //, iBearsPower(pair,period,5,0,i)
                     //, iBearsPower(pair,period,5,0,i) - iBearsPower(pair,period,5,0,i+1)
                     //, iBearsPower(pair,period,5,0,i) / iBearsPower(pair,period,5,0,i+1)
                     //, iBearsPower(pair,period,7,0,i)
                     //, iBearsPower(pair,period,7,0,i) - iBearsPower(pair,period,7,0,i+1)
                     //, iBearsPower(pair,period,7,0,i) / iBearsPower(pair,period,7,0,i+1)                     
                     //, iBearsPower(pair,period,13,0,i)
                     //, iBearsPower(pair,period,13,0,i) - iBearsPower(pair,period,13,0,i+1)
                     //, iBearsPower(pair,period,13,0,i) / iBearsPower(pair,period,13,0,i+1) 
                     //, iBearsPower(pair,period,17,0,i)
                     //, iBearsPower(pair,period,17,0,i) - iBearsPower(pair,period,17,0,i+1)
                     //, iBearsPower(pair,period,28,0,i) - iBearsPower(pair,period,28,0,i+1)                      
                     //, iBearsPower(pair,period,25,0,i)
                     //, iBearsPower(pair,period,25,0,i) - iBearsPower(pair,period,25,0,i+1)
                     //, iBearsPower(pair,period,32,0,i) - iBearsPower(pair,period,32,0,i+1)                         
                     //, iBullsPower(pair,period,3,0,i)
                     //, iBullsPower(pair,period,3,0,i) - iBullsPower(pair,period,3,0,i+1)
                     //, iBullsPower(pair,period,3,0,i) / iBullsPower(pair,period,3,0,i+1)                     
                     //, iBullsPower(pair,period,5,0,i)
                     //, iBullsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,i+1)
                     //, iBullsPower(pair,period,5,0,i) / iBullsPower(pair,period,5,0,i+1)
                     //, iBullsPower(pair,period,7,0,i) 
                     //, iBullsPower(pair,period,7,0,i) - iBullsPower(pair,period,7,0,i+1)
                     //, iBullsPower(pair,period,7,0,i) / iBullsPower(pair,period,7,0,i+1)                                         
                     //, iBullsPower(pair,period,13,0,i)
                     //, iBullsPower(pair,period,13,0,i) - iBullsPower(pair,period,13,0,i+1)
                     //, iBullsPower(pair,period,13,0,i) / iBullsPower(pair,period,13,0,i+1)                     
                     //, iBullsPower(pair,period,17,0,i)
                     //, iBullsPower(pair,period,17,0,i) - iBullsPower(pair,period,17,0,i+1)
                     //, iBullsPower(pair,period,28,0,i) - iBullsPower(pair,period,28,0,i+1)                           
                     //, iBullsPower(pair,period,25,0,i)
                     //, iBullsPower(pair,period,25,0,i) - iBullsPower(pair,period,25,0,i+1)
                     //, iBullsPower(pair,period,32,0,i) - iBullsPower(pair,period,32,0,i+1)                         
                     //,(MathAbs(iBearsPower(pair,period,5,0,i)) - MathAbs(iBullsPower(pair,period,5,0,i))) - (iBearsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,i))
                     //, MathAbs(iBearsPower(pair,period,5,0,i)) - MathAbs(iBullsPower(pair,period,5,0,i))
                     //, iBearsPower(pair,period,5,0,i) + iBullsPower(pair,period,5,0,i)
                     //,(MathAbs(iBearsPower(pair,period,5,0,i)) - MathAbs(iBearsPower(pair,period,5,0,i+1))) - (iBullsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,i+1))
                     //,(MathAbs(iBearsPower(pair,period,3,0,i)) - MathAbs(iBullsPower(pair,period,3,0,i))) - (iBearsPower(pair,period,3,0,i) - iBullsPower(pair,period,3,0,i))
                     //, MathAbs(iBearsPower(pair,period,3,0,i)) - MathAbs(iBullsPower(pair,period,3,0,i))
                     //, iBearsPower(pair,period,3,0,i) + iBullsPower(pair,period,3,0,i)
                     //, (iBearsPower(pair,period,5,0,i) + iBullsPower(pair,period,5,0,i)) - (iBearsPower(pair,period,5,0,i+1) + iBullsPower(pair,period,5,0,i+1))
                     //, iBearsPower(pair,period,3,0,i) - iBullsPower(pair,period,3,0,i)
                     //,(MathAbs(iBearsPower(pair,period,7,0,i)) - MathAbs(iBullsPower(pair,period,7,0,i))) - (iBearsPower(pair,period,7,0,i) - iBullsPower(pair,period,7,0,i))
                     //, MathAbs(iBearsPower(pair,period,7,0,i)) - MathAbs(iBullsPower(pair,period,7,0,i))
                     //, iBearsPower(pair,period,7,0,i) + iBullsPower(pair,period,7,0,i)
                     //, (iBearsPower(pair,period,7,0,i) + iBullsPower(pair,period,7,0,i)) - (iBearsPower(pair,period,7,0,i+1) + iBullsPower(pair,period,7,0,i+1))                     
                     //, iBearsPower(pair,period,7,0,i) - iBullsPower(pair,period,7,0,i)
                     //,(MathAbs(iBearsPower(pair,period,8,0,i)) - MathAbs(iBearsPower(pair,period,8,0,i+1))) - (iBullsPower(pair,period,8,0,i) - iBullsPower(pair,period,8,0,i+1))
                     //,((MathAbs(iBearsPower(pair,period,5,0,i)) - MathAbs(iBearsPower(pair,period,5,0,i+1))) - (iBearsPower(pair,period,5,0,i) - iBearsPower(pair,period,5,0,i+1))) - ((MathAbs(iBullsPower(pair,period,5,0,i)) - MathAbs(iBullsPower(pair,period,5,0,i+1))) - (iBullsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,i+1)))
                     //,(iBearsPower(pair,period,5,0,i) - iBearsPower(pair,period,5,0,i+1)) - (iBullsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,i+1))
                     //,((MathAbs(iBearsPower(pair,period,5,0,i)) - MathAbs(iBearsPower(pair,period,5,0,i+2))) - (iBearsPower(pair,period,5,0,i) - iBearsPower(pair,period,5,0,i+2))) - ((MathAbs(iBullsPower(pair,period,5,0,i)) - MathAbs(iBullsPower(pair,period,5,0,i+2))) - (iBullsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,i+2)))
                     //, (iBearsPower(pair,period,5,0,i) - iBearsPower(pair,period,5,0,i+2)) - (iBullsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,i+2))
                     //, iSAR(pair,period,.02,.2,i) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i)
                     //, iSAR(pair,PERIOD_M5,0.02,.2,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i)
                     //, iBearsPower(pair,period,5,0,i) - iBearsPower(pair,period,5,0,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1)
                     //, iBullsPower(pair,period,5,0,i) - iBullsPower(pair,period,5,0,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1)
                     //, iADX(pair,period,7,PRICE_MEDIAN,MODE_MAIN,i) - iADX(pair,period,7,PRICE_MEDIAN,MODE_PLUSDI,i)
                     //, iADX(pair,period,7,ma_applied_price,MODE_MAIN,i) - iADX(pair,period,7,ma_applied_price,MODE_MINUSDI,i)
                     //, iOpen(pair,period,i+1) - iClose(pair,period,i+1)                 
                     //, iHigh(pair,period,i+1) - iLow(pair,period,i+1)                 
                     //, iMA(pair,period,5,0,0,4,i) - iMA(pair,period,5,0,0,4,i+1)
                     //, iMA(pair,period,5,0,0,4,i) - iMA(pair,period,5,0,0,4,i+2)
                     //, iMA(pair,period,13,0,0,4,i) - iMA(pair,period,13,0,0,4,i+1)
                     //, iMA(pair,period,13,0,0,4,i) - iMA(pair,period,13,0,0,4,i+2)                                   
                     //, iMomentum(pair,period,3,0,i) - iMomentum(pair,period,3,0,i+1)      
                     //, (iMomentum(pair,period,5,0,i) - iMomentum(pair,period,5,0,i+1)) - (iMomentum(pair,period,5,0,i+1) - iMomentum(pair,period,5,0,i+2))
                     //, iMomentum(pair,period,7,0,i)
                     //, iMomentum(pair,period,13,0,i)
                     //, iMomentum(pair,period,17,0,i)
                     //, iMomentum(pair,period,25,0,i)                     
                     //, iOsMA(pair,period,12,26,8,0,i)
                     //, iStdDev(pair,period,15,0,0,0,i)              
                     //, iStdDev(pair,period,25,0,0,0,i)                     
                     //, iHigh(pair,period,i) - iClose(pair,period,i)
                     //, iHigh(pair,period,i) - iOpen(pair,period,i)
                     //, iOpen(pair,period,i) - iClose(pair,period,i)
                     //, iClose(pair,period,i) - iLow(pair,period,i)
                     //, iOpen(pair,period,i) - iLow(pair,period,i)
                     //, MathAbs(iOpen(pair,period,i) - iClose(pair,period,i))//body
                     //, iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i)) //top wick
                     //, MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i) //bottom wick
                     //, (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) - (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i)) //top bottom wick diff
                     //, (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) + (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i)) //total wick
                     //, MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) - ((iHigh(pair,period,i) - MathMax(iOpen(pair,period,i),iClose(pair,period,i))) + (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i))) //body wick diff
                     //, MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) != 0 ? (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) + (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i)) / MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) : 0//total wick to body ratio
                     //, MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) != 0 ? (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) / MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) : 0 //top wick to body ratio
                     //, MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) != 0 ? (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i)) / MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) : 0 //bottom wick to body ratio
                     //, (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) - (iHigh(pair,period,i+1) - MathMax(iOpen(pair,period,i+1), iClose(pair,period,i+1)))
                     //, (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) - (iHigh(pair,period,i+2) - MathMax(iOpen(pair,period,i+2), iClose(pair,period,i+2)))
                     //, (iHigh(pair,period,i+1) - MathMax(iOpen(pair,period,i+1), iClose(pair,period,i+1))) - (iHigh(pair,period,i+2) - MathMax(iOpen(pair,period,i+2), iClose(pair,period,i+2)))
                     //, ( (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) - (iHigh(pair,period,i+1) - MathMax(iOpen(pair,period,i+1), iClose(pair,period,i+1)))) - ((iHigh(pair,period,i+1) - MathMax(iOpen(pair,period,i+1), iClose(pair,period,i+1))) - (iHigh(pair,period,i+2) - MathMax(iOpen(pair,period,i+2), iClose(pair,period,i+2))))
                     //, iMA(pair,period,3,0,MODE_EMA,PRICE_MEDIAN,i) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i)
                     //, (iMA(pair,period,3,0,MODE_EMA,PRICE_MEDIAN,i) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i)) - (iMA(pair,period,3,0,MODE_EMA,PRICE_MEDIAN,i+1) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+1))
                     //, (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i)) - (MathMin(iOpen(pair,period,i+1),iClose(pair,period,i+1)) - iLow(pair,period,i+1))
                     //, (MathAbs(iOpen(pair,period,i) - iClose(pair,period,i))) - (MathAbs(iOpen(pair,period,i+1) - iClose(pair,period,i+1)))                     
                     //, iLow(pair,period,i) - iLow(pair,PERIOD_H4,iBarShift(pair,PERIOD_H4,iTime(pair,period,i))+1)
                     //, iLow(pair,period,i) - iLow(pair,PERIOD_D1,iBarShift(pair,PERIOD_D1,iTime(pair,period,i))+1)
                     //, iHigh(pair,period,i) - iHigh(pair,PERIOD_H4,iBarShift(pair,PERIOD_H4,iTime(pair,period,i))+1)
                     //, iHigh(pair,period,i) - iHigh(pair,PERIOD_D1,iBarShift(pair,PERIOD_D1,iTime(pair,period,i))+1)
                     //, iOpen(pair,period,i) - iOpen(pair,PERIOD_M5,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1)
                     //, iClose(pair,period,i) - iClose(pair,PERIOD_H4,iBarShift(pair,PERIOD_H4,iTime(pair,period,i))+1)
                     //, iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+1)
                     //, iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+2)
                     //, iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+3)
                     , iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+1) - iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+2)
                     , iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i) < iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+1) ? 1 : 0
                     , iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i) > iMA(pair,period,1,0,MODE_SMA,ma_applied_price,i+1) ? 1 : 0
                     , iBullsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE)+1)
                     , iBullsPower(pair,PERIOD_M5,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i),TRUE)+1)
                     , iBullsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE)+1) - iBullsPower(pair,PERIOD_M5,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i),TRUE)+1)
                     , iBullsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE))
                     , iBullsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE)) - iBullsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE)+1)
                     , iBearsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE)+1)
                     , iBearsPower(pair,PERIOD_M5,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i),TRUE)+1)
                     , iBearsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE)+1) - iBearsPower(pair,PERIOD_M5,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i),TRUE)+1)
                     , iBearsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE))
                     , iBearsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i),TRUE)) - iBearsPower(pair,PERIOD_M15,5,PRICE_MEDIAN,iBarShift(pair,period,iTime(pair,period,i),TRUE)+1)
                     , MathAbs(iOpen(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1) - iClose(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1))//body
                     , iHigh(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1) - MathMax(iOpen(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1), iClose(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1)) //top wick
                     , MathMin(iOpen(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1),iClose(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1)) - iLow(pair,PERIOD_M15,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1) //bottom wick
                     , iMA(pair,PERIOD_M15,1,0,MODE_SMA,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))) - iMA(pair,PERIOD_M15,1,0,MODE_SMA,PRICE_MEDIAN,iBarShift(pair,PERIOD_M15,iTime(pair,period,i))+1)
                     , iMA(pair,PERIOD_M5,1,0,MODE_SMA,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))) - iMA(pair,PERIOD_M5,1,0,MODE_SMA,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1)
                     , iMA(pair,PERIOD_M5,1,0,MODE_SMA,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))) - iMA(pair,PERIOD_M5,1,0,MODE_SMA,PRICE_MEDIAN,iBarShift(pair,PERIOD_M5,iTime(pair,period,i))+1)
                     , iOsMA(pair,period,12,26,9,PRICE_MEDIAN,i)
                     , iOsMA(pair,period,12,26,9,PRICE_MEDIAN,i) - iOsMA(pair,period,12,26,9,PRICE_MEDIAN,i+5)
                     , iMFI(pair,period,14,i) - iMFI(pair,period,7,i)
                     , iHigh(pair,period,i) - iLow(pair,period,i+1)
                     , iHigh(pair,period,i) - iHigh(pair,period,i+1)
                     , iHigh(pair,period,i+1) - iLow(pair,period,i)
                     , iHigh(pair,period,i+1) - iHigh(pair,period,i)
                     , iHigh(pair,period,i) - iLow(pair,period,i+2)
                     , iHigh(pair,period,i) - iHigh(pair,period,i+2)
                     , iHigh(pair,period,i) - iLow(pair,period,i+3)
                     , iHigh(pair,period,i) - iHigh(pair,period,i+3)
                     , iHigh(pair,period,i) - iLow(pair,period,i+4)
                     , iHigh(pair,period,i) - iHigh(pair,period,i+4)
                     , (iHigh(pair,period,i) - iLow(pair,period,i+1)) - (iHigh(pair,period,i) - iLow(pair,period,i+2))
                     , (iHigh(pair,period,i) - iHigh(pair,period,i+1)) - (iHigh(pair,period,i) - iHigh(pair,period,i+2))
                     , iLow(pair,period,i) - iLow(pair,period,i+1)
                     , iLow(pair,period,i) - iLow(pair,period,i+2)
                     , iLow(pair,period,i) - iLow(pair,period,i+3)
                     , (iHigh(pair,period,i) - iHigh(pair,period,i+1)) - (iLow(pair,period,i) - iLow(pair,period,i+1))
                     , MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i) != 0 ? (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) / (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i)) : 0 //top wick to bottom wick ratio
                     , iOpen(pair,period,i) - iClose(pair,period,i) != 0 ? (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) + (MathMin(iOpen(pair,period,i),iClose(pair,period,i)) - iLow(pair,period,i)) / (iOpen(pair,period,i) - iClose(pair,period,i)) : 0//total wick to body ratio non abs
                     , (iOpen(pair,period,i) - iClose(pair,period,i)) - (iOpen(pair,period,i+1) - iClose(pair,period,i+1))
                     , (iHigh(pair,period,i) - iLow(pair,period,i)) - (iHigh(pair,period,i+1) - iLow(pair,period,i+1))
                     , iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i+1) > iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i) ? 1:0
                     , iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i+2) > iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i+1) ? 1:0
                     , MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) - MathAbs(iOpen(pair,period,i+1) - iClose(pair,period,i+1))
                     , (iHigh(pair,period,i) - MathMax(iOpen(pair,period,i), iClose(pair,period,i))) - MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) //top wick body diff
                     , (MathMin(iOpen(pair,period,i), iClose(pair,period,i)) - iLow(pair,period,i)) - MathAbs(iOpen(pair,period,i) - iClose(pair,period,i)) //top wick body diff
                     , iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i) - iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i+1)
                     , iMA(pair,period,1,0,MODE_SMA,PRICE_MEDIAN,i)
                     , iHigh(pair,period,i)
                     , iLow(pair,period,i)
                     , signal[bar_start - i]
                     );
         }
      FileClose(filehandle);
      Print("FileOpen OK");
     }
   else Print("Operation FileOpen failed, error ",GetLastError());

// Script End
}     
