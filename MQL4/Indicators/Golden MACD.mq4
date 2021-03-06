/*
   Generated by EX4-TO-MQ4 decompiler V4.0.224.1 []
   Website: http://purebeam.biz
   E-mail : purebeam@gmail.com
*/
#property copyright "GOLDEN "
#property link      "zx815@126.com "

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DarkGray
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 DarkOrange
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2

extern int FastEMA = 5;
extern int SlowEMA = 34;
extern int SignalSMA = 5;
double g_ibuf_88[];
double g_ibuf_92[];
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
int gi_unused_108 = 0;

int init() {
   IndicatorBuffers(5);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, g_ibuf_88);
   SetIndexBuffer(1, g_ibuf_92);
   SetIndexBuffer(2, g_ibuf_96);
   SetIndexBuffer(3, g_ibuf_100);
   SetIndexBuffer(4, g_ibuf_104);
   IndicatorShortName("Golden MACD(" + FastEMA + "," + SlowEMA + "," + SignalSMA + ")");
   SetIndexLabel(0, "MACD=");
   SetIndexLabel(1, "MACD+");
   SetIndexLabel(2, "MACD-");
   SetIndexLabel(3, "Signal");
   //SetIndexLabel(4, "MACD");
   return (0);
}

int start() {
   int li_4 = IndicatorCounted();
   if (li_4 > 0) li_4--;
   int li_0 = Bars - li_4;
   for (int li_8 = 0; li_8 < li_0; li_8++) g_ibuf_104[li_8] = iMA(NULL, 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, li_8) - iMA(NULL, 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, li_8);
   for (li_8 = 0; li_8 < li_0; li_8++) g_ibuf_100[li_8] = iMAOnArray(g_ibuf_104, Bars, SignalSMA, 0, MODE_SMA, li_8);
   for (li_8 = 0; li_8 < li_0; li_8++) {
      if (g_ibuf_104[li_8] > 0.0 && g_ibuf_104[li_8] >= g_ibuf_100[li_8]) {
         g_ibuf_92[li_8] = g_ibuf_104[li_8];
         g_ibuf_96[li_8] = 0;
         g_ibuf_88[li_8] = 0;
      }
      if (g_ibuf_104[li_8] < 0.0 && g_ibuf_104[li_8] <= g_ibuf_100[li_8]) {
         g_ibuf_96[li_8] = g_ibuf_104[li_8];
         g_ibuf_92[li_8] = 0;
         g_ibuf_88[li_8] = 0;
      }
      if ((g_ibuf_104[li_8] > 0.0 && g_ibuf_104[li_8] < g_ibuf_100[li_8]) || (g_ibuf_104[li_8] < 0.0 && g_ibuf_104[li_8] > g_ibuf_100[li_8])) {
         g_ibuf_88[li_8] = g_ibuf_104[li_8];
         g_ibuf_92[li_8] = 0;
         g_ibuf_96[li_8] = 0;
      }
   }
   return (0);
}