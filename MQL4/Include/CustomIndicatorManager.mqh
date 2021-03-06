//+------------------------------------------------------------------+
//|                                                  CashManeger.mq4 |
//|                                                         by Lorne |
//|                                                   www@luotao.net |
//+------------------------------------------------------------------+
#property copyright "Lorne"
#property link      "www@luotao.net"

//蓝变白变黄 -10
//黄变白变蓝  10
//黄变白 3
//白变黄 -3
//白变蓝 7
//蓝变白 -7
//一直蓝 5
//一直黄 -5
//一直白 0
int GetTrendLine(int timeframe,int shift,string symbol,int magaperiod)
{
   //参数40,5,3,0,
   
   for(int i=1;i<200;i++)
   {
      double white1=iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 0, i+0);//趋势线 shift=0
      double white2=iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 0, i+1);//趋势线 shift=1
      double white3=iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 0, i+2);//趋势线 shift=2
      
      
      //死叉
      if(white3<white2 && white2>white1)
      {
         //Print(DoubleToStr(white3)," ",DoubleToStr(white2)," ",DoubleToStr(white1));
         //Print("Return="+(0-i));
         //break;
         return(0-i);
      }
      if(white3>white2 && white2<white1)
      {
         //Print(DoubleToStr(white3)," ",white2," ",white1);
         //Print("Return="+i);
         //break;
         return(i);  
      }
   }
   
   
   
   double gold1 = EMPTY_VALUE;
   gold1 = iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 1, shift+0);//黄色趋势线 shift1
   double gold2 = EMPTY_VALUE;
   gold2 = iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 1, shift+1);//黄色趋势线 shift2
   double gold3 = EMPTY_VALUE;
   gold3 = iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 1, shift+2);//黄色趋势线 shift2
         
   double blue1 = EMPTY_VALUE;
   blue1 = iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 2, shift+0);//蓝色趋势线 shift1
   double blue2 = EMPTY_VALUE;
   blue2 = iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 2, shift+1);//蓝色趋势线 shift2
   double blue3 = EMPTY_VALUE;
   blue3 = iCustom(symbol, timeframe, "Golden Tendency String V2",magaperiod,5,3,0, 2, shift+2);//蓝色趋势线 shift2
   
   
   
   //Print("gold1="+gold1+",gold2="+gold2+",gold3="+gold3);
   //Print("blue1="+blue1+",blue2="+blue2+",blue3="+blue3);
   //Print("white1="+white1+",white2="+white2+",white3="+white3);
   
   if(gold1==EMPTY_VALUE && gold2==EMPTY_VALUE && blue1==EMPTY_VALUE && blue2==EMPTY_VALUE)
      return(0);
   if(gold1!=EMPTY_VALUE && blue2!=EMPTY_VALUE)//蓝变白变黄 -10
      return(-10);
   if(gold1!=EMPTY_VALUE &&  gold2==EMPTY_VALUE)//蓝变白变黄 -10
      return(-10);
   if(gold1!=EMPTY_VALUE && gold2!=EMPTY_VALUE && blue3!=EMPTY_VALUE)//蓝变白变黄黄 -7
      return(-7);
   if(gold2!=EMPTY_VALUE && blue1!=EMPTY_VALUE)//黄变白变蓝  10
      return(10);
   if(blue2==EMPTY_VALUE && blue1!=EMPTY_VALUE)//黄变白变蓝  10
      return(10);
   if(gold3!=EMPTY_VALUE && blue2!=EMPTY_VALUE && blue1!=EMPTY_VALUE)//黄白变蓝蓝 7
      return(7);
   if(gold1==EMPTY_VALUE && gold2!=EMPTY_VALUE && blue1==EMPTY_VALUE)//黄变白 3
      return(3);
   if(gold1!=EMPTY_VALUE && gold2==EMPTY_VALUE && blue2==EMPTY_VALUE)//白变黄 -3
      return(3);
   if(blue1==EMPTY_VALUE && blue2!=EMPTY_VALUE && gold1==EMPTY_VALUE)//蓝变白 -7
      return(-7);
   if(blue1!=EMPTY_VALUE && blue2==EMPTY_VALUE && gold2==EMPTY_VALUE)//白变蓝 7
      return(-7);


   if(gold1!=EMPTY_VALUE && gold2!=EMPTY_VALUE && blue1==EMPTY_VALUE && blue2==EMPTY_VALUE)//一直黄 -5
      return(-5);
   if(blue1!=EMPTY_VALUE && blue2!=EMPTY_VALUE && gold1==EMPTY_VALUE && gold2==EMPTY_VALUE )//一直蓝
      return(5);
   else
      return(0);
}

struct TrendVariable
{
   int Buy;
   int Sell;
}; 

//叉、方块、带叉方块3个指标
//1个指标指示多 1
//2个指标指示多 2
//3个指标指示多 3
//1个指标指示空 -1
//2个指标指示空 -2
//3个指标指示空 -3
void GetTrendVariableCount(int timeframe,int shift,string symbol,TrendVariable& tv)
{
   //int result; 
   //参数5,15,1,1,8,17,9,14,14,14,14,14,
   double fork1_1 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 2, shift+0);//青色 叉形 shift1
   //double fork1_2 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 2, shift+1);//青色 叉形 shift2
   double fork2_1 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 3, shift+0);//黄色 叉形 shift1
   //double fork2_2 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 3, shift+1);//黄色 叉形 shift2

   double square1_1 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 4, shift+0);//青色 方形 shift1
   //double square1_2 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 5, shift+1);//青色 方形 shift2   
   double square2_1 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 5, shift+0);//黄色 方形 shift1
   //double square2_2 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 4, shift+1);//黄色 方形 shift2
   
   double forksquare1_1 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 0, shift+0);//蓝色 叉方形 shift1
   //double forksquare1_2 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 0, shift+1);//蓝色 叉方形 shift2
   double forksquare2_1 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 1, shift+0);//红色 叉方形 shift1
   //double forksquare2_2 = iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 1, shift+1);//红色 叉方形 shift2
   
   int buycount=0;
   int sellcount=0;
   
   //g_Comment=g_Comment+"fork1_1="+fork1_1+" fork2_1="+fork2_1+" square1_1="+square1_1+" square2_1="+square2_1+" forksquare1_1="+forksquare1_1+" forksquare2_1="+forksquare2_1+"\n";
   
   if(fork1_1>0 && fork2_1==0) buycount++;
   if(fork2_1>0 && fork1_1==0) sellcount++;
   
   if(square1_1>0 && square2_1==0) buycount++;
   if(square2_1>0 && square1_1==0) sellcount++;
   
   if(forksquare1_1>0 && forksquare2_1==0) buycount++;
   if(forksquare2_1>0 && forksquare1_1==0) sellcount++;
   
   //Print("fork="+fork1_1," | ",fork2_1);
   //Print("square="+square1_1," | ",square2_1);
   //Print("forksquare="+forksquare1_1," | ",forksquare2_1);
   //Print("shitf="+shift+" "+buycount+"="+sellcount);
   //Print(fork1_1+"+"+square1_1+"+"+forksquare1_1+" | "+fork2_1+"+"+square2_1+"+"+forksquare2_1);
   
   tv.Buy=buycount;
   tv.Sell=0-sellcount;

   //return(result);
}

// 蓝色 黄色箭头区域,近n个K线中出现箭头，向上返回n，向下返回-n
int GetGoldenArrow(string symbol,int timeframe=PERIOD_H1)
{
   for(int i=1;i<200;i++)
   {
      double finger_buy=iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 6, i);
      double finger_sell=iCustom(symbol, timeframe, "Golden Varitey",5,15,1,1,8,17,9,14,14,14,14,14, 7, i);
      
      if(finger_buy>0)
      {
         return(i);
      }
      if(finger_sell>0)
      {
         return(0-i);
      }
   }
   return(0);
}

// 蓝色 黄色圆点,近n个K线中出现圆点，向上返回n，向下返回-n
int GetGoldenFinger(string symbol,int timeframe=PERIOD_H1)
{
   for(int i=1;i<200;i++)
   {
      double finger_buy=iCustom(symbol, timeframe, "Golden Finger",6,false, 0, i);
      double finger_sell=iCustom(symbol, timeframe, "Golden Finger",6,false, 1, i);
      
      if(finger_buy>0)
      {
         return(i);
      }
      if(finger_sell>0)
      {
         return(0-i);
      }
   }
   return(0);
}

//MACD的方向指示
//正数表示往前第多少个柱发生金叉，负数表示往前第多少个柱发生死叉
int GetMACDDirection(int timeframe,string symbol)
{
   //从已经落下的第一根柱起
   for(int i=1;i<100;i++)
   {
      double macd0 = iCustom(symbol, timeframe, "Golden MACD",5,34,5, 4, i);//MACD 灰柱 0
      double macd1 = iCustom(symbol, timeframe, "Golden MACD",5,34,5, 4, i+1);//MACD 灰柱 1
      double macd2 = iCustom(symbol, timeframe, "Golden MACD",5,34,5, 4, i+2);//MACD 灰柱 2
      
      //Print(DoubleToStr(macd2)," ",macd1," ",macd0);
      if(macd2<macd1 && macd1>macd0)
      {
         return(0-i);
      }
      if(macd2>macd1 && macd1<macd0)
      {
         return(i);
      }
   }
   return(0);
}

//MACD的趋势
int GetMACDTrend(int timeframe,string symbol)
{
   double macd_buy0 = iCustom(symbol, timeframe, "Golden MACD",5,34,5, 1, 0);//MACD 蓝柱 0
   double macd_sell0 = iCustom(symbol, timeframe, "Golden MACD",5,34,5, 2, 0);//MACD 蓝柱 0
   int index=1;
   if (macd_buy0>0 && macd_sell0==0) index=1;
   else if (macd_buy0==0 && macd_sell0<0) index=2;
   else return(0);
   
   for(int i=0;i<100;i++)
   {
      double macd = iCustom(symbol, timeframe, "Golden MACD",5,34,5, index, i);//MACD
      if(macd==0)
      {
         if (macd_buy0>0)
            return(i);
         else if(macd_sell0<0)
            return(0-i);
      }
   }
   return(0);
}

//红变蓝 做多 10
//蓝变红 做空 -10
//一直红 -5
//一直蓝 5
int GetSuperK(string symbol,int timeframe,int shift)
{
   double redhigh0 = iCustom(Symbol(), timeframe, "Golden Super k", 0, 0);//红柱 0
   double redhigh1 = iCustom(Symbol(), timeframe, "Golden Super k", 0, 1);//红柱 1
   double redhigh2 = iCustom(Symbol(), timeframe, "Golden Super k", 0, 2);//红柱 2
   double redlow0 = iCustom(Symbol(), timeframe, "Golden Super k", 2, 0);//红柱 0
   double redlow1 = iCustom(Symbol(), timeframe, "Golden Super k", 2, 1);//红柱 1
   double redlow2 = iCustom(Symbol(), timeframe, "Golden Super k", 2, 2);//红柱 2
   
   double bluehigh0 = iCustom(Symbol(), timeframe, "Golden Super k", 1, 0);//蓝柱 0
   double bluehigh1 = iCustom(Symbol(), timeframe, "Golden Super k", 1, 1);//蓝柱 1
   double bluehigh2 = iCustom(Symbol(), timeframe, "Golden Super k", 1, 2);//蓝柱 2
   double bluelow0 = iCustom(Symbol(), timeframe, "Golden Super k", 3, 0);//蓝柱 0
   double bluelow1 = iCustom(Symbol(), timeframe, "Golden Super k", 3, 1);//蓝柱 1
   double bluelow2 = iCustom(Symbol(), timeframe, "Golden Super k", 3, 2);//蓝柱 2

   int result;
   if(redhigh0==redlow0 && bluehigh0!=bluelow0 && redhigh1!=redlow1 && bluehigh1==bluelow1) result=10;
   if(redhigh0!=redlow0 && bluehigh0==bluelow0 && redhigh1==redlow1 && bluehigh1!=bluelow1) result=-10;
   if(redhigh0!=redlow0 && bluehigh0==bluelow0 && redhigh1!=redlow1 && bluehigh1==bluelow1) result=-5;
   if(redhigh0==redlow0 && bluehigh0!=bluelow0 && redhigh1==redlow1 && bluehigh1!=bluelow1) result=5;
   if(result==0)
   {
      Print("sdgwetwet"+redhigh0+" "+redhigh1+" "+bluehigh0+" "+bluelow0+" "+redhigh1+" "+redlow1+" "+bluehigh1+" "+bluelow1);
   }
   return(result);
}