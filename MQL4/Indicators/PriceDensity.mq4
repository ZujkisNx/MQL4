//+------------------------------------------------------------------+
//|                                                        Price.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <Dict.mqh>
Dict *table;
datetime lastTime=0;

extern color histcolor = C'50,50,50';  //柱线颜色
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   table = new Dict();
   Print("IndicatorCounted = "+IndicatorCounted());
   
   
//---
   return(INIT_SUCCEEDED);
  }


int deinit() {
   ObjectsDeleteAll(0, OBJ_TREND);
   delete table;
   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
      
      
   //Print("IndicatorCounted = "+IndicatorCounted());
   //Print("Bars = "+Bars);
   
   double max= high[1];
   double min= low[1];
   
   bool flag=false;
   int ratio=1000;
   if(Close[0]<10)
      ratio=1000;
   else if(Close[0]>10&&Close[0]<100)
      ratio=10;
   else if(Close[0]>100&&Close[0]<1000)
      ratio=10;
   else if(Close[0]>1000)
      ratio=1;
   
   for (int i=IndicatorCounted();i>0;i--)
   {
      if(time[i]>lastTime)
      {
         //Print(time[i]+" > "+lastTime);
         int maxint=NormalizeDouble(high[i],3)*ratio;
         int minint=NormalizeDouble(low[i],3)*ratio;
         for (int j=minint;j<maxint;j++)
         {
            table.set(j,table.get(j)+1);
         }
         lastTime=time[i];
         flag=true;
      }
   }
   
   if(flag){
      //table.debug();
      Print(int(max*ratio)+" = "+table.get(int(max*ratio)));
      ObjectsDeleteAll(0, OBJ_TREND);
      
      for(int i=0;i<table.count;i++)
      {
         int key=table.keys[i];
         int value=table.values[i];
         double price=NormalizeDouble(table.keys[i]/float(ratio),3);
         int width=1;
         if(Period()<=PERIOD_H1)
            width=5;
         else if(Period()==PERIOD_H4)
            width=3;
         else if(Period()>PERIOD_H4)
            width=1;
         creatTL(IntegerToString(key),time[value-1],price,time[0],histcolor,width);
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
void creatTL(string a_name_0, int a_datetime_8, double a_price_12, int a_datetime_20, color a_color_24, int a_width_28) {
   ObjectDelete(a_name_0);
   ObjectCreate(a_name_0, OBJ_TREND, 0, a_datetime_8, a_price_12, a_datetime_20, a_price_12);
   ObjectSet(a_name_0, OBJPROP_BACK, TRUE);
   ObjectSet(a_name_0, OBJPROP_COLOR, a_color_24);
   ObjectSet(a_name_0, OBJPROP_WIDTH, a_width_28);
   ObjectSet(a_name_0,OBJPROP_BACK,true);
   ObjectSet(a_name_0,OBJPROP_RAY_LEFT,false);
   ObjectSet(a_name_0,OBJPROP_RAY_RIGHT,false);
   ObjectSet(a_name_0,OBJPROP_HIDDEN,true);
   //ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(a_name_0, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+


   /*
   //Print("high = "+h+" "+high[h]);
   //Print("low = "+l+" "+low[l]);
   
   int maxint=NormalizeDouble(max,3)*1000;
   int minint=NormalizeDouble(min,3)*1000;
   
   for (int i=minint;i<maxint;i++)
   {
      table.set(i,table.get(i)+1);
   }
   table.set(1500,12);
   table.debug();
   
   float v= NormalizeDouble(1.5555,3);
   Print("v = "+v);
   */
   
   
   