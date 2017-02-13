//+------------------------------------------------------------------+
//|                                                 AutostopLoss.mq4 |
//|                                                 Power by Leandro |
//|                               ��BUG���и����뷨����ϵ QQ:99451121|
//+------------------------------------------------------------------+

#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>

extern bool EAEnabled = true;//�Ƿ���������EA
/*
ӯ���ﵽProfitProtectLevel_x_Pips���ڵ�ǰӯ���ٷ�֮ProfitProtectLevel_x_Percen��λ������ֹ��
����
ProfitProtectLevel_0_Pips   = 20;
ProfitProtectLevel_0_Percen = 0;
��˼��ӯ���ﵽ20��ʱ��ֹ���λ�Ƶ����ּ�
*/
extern double       Protect   = 20;
extern double       Trailing = 30;


datetime LastRunTime=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (!EAEnabled)
   {
     return(0);
   }
   
   if (TimeCurrent()-LastRunTime<5)
   {
     return(0);
   }
   
   double ProfitNow;
   double StopLossNow;
   
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      
      if(OrderSelect(i,SELECT_BY_POS))
      {       
         
         double ask=MarketInfo(OrderSymbol(),MODE_ASK);
         double bid=MarketInfo(OrderSymbol(),MODE_BID);
         double point=MarketInfo(OrderSymbol(),MODE_POINT);
         
         double TrailingPoint=Trailing*10*MarketInfo(OrderSymbol(),MODE_POINT);
         double ProtectPoint=Protect*10*MarketInfo(OrderSymbol(),MODE_POINT);
         
         if(OrderType() == OP_BUY)
         {
            ProfitNow=MarketInfo(OrderSymbol(), MODE_BID)-OrderOpenPrice();
            StopLossNow=OrderOpenPrice()-OrderStopLoss();
         }else if(OrderType() == OP_SELL)
         {
            ProfitNow=OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK);
            if(OrderStopLoss()==0)
               StopLossNow=OrderOpenPrice();
            else
               StopLossNow=OrderStopLoss()-OrderOpenPrice();
         }
         /*
         Print(OrderSymbol()+"|"+MarketInfo(OrderSymbol(),MODE_POINT));continue;
         StopLossNow=OrderProfit();
         Print(OrderSymbol()+"|"+MarketInfo(OrderSymbol(),MODE_POINT)
            +"|ProfitNow: "+DoubleToStr(ProfitNow,5)
            +"|OpenAsLossPoint: "+DoubleToStr(OpenAsLossPoint,5)
            +"|StopLossNow: "+DoubleToStr(StopLossNow,5)
            +"|OrderOpenPrice: "+DoubleToStr(OrderOpenPrice(),5)
            +"|OrderStopLoss: "+DoubleToStr(OrderStopLoss(),5)
            );
            if(OrderSymbol()=="EURGBP") 
               {
               Print(ProfitNow+"="+MarketInfo(OrderSymbol(), MODE_BID)+"-"+OrderOpenPrice()+"|"+ProtectPoint+"|"+j);
               OrderPrint();
               Print(OrderSymbol()+"|"+OrderStopLoss()+"<"+StopLossPoint);
               }
               
               
         */
         
         //OrderPrint();
         //5�����ε�ֹ��
         //Print(OrderSymbol()+"|"+ProfitNow+">"+ProfitProtectLevel_4_PipsPoint);
         //Print(ProfitNow);
         if(ProfitNow > ProtectPoint)
         {
            int j=ProfitNow/ProtectPoint;
            double StopLossPoint;
            if(OrderType() == OP_BUY)
            {
               StopLossPoint=OrderOpenPrice()+(j-1)*TrailingPoint;
               
               
               if(OrderStopLoss()<StopLossPoint)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),StopLossPoint,bid+2*TrailingPoint,0,CLR_NONE);
               }
            }else if(OrderType() == OP_SELL)
            {

               StopLossPoint=OrderOpenPrice()-(j-1)*TrailingPoint;
               
               if(OrderStopLoss()==0||OrderStopLoss()>StopLossPoint)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),StopLossPoint,ask-2*TrailingPoint,0,CLR_NONE);
               }
            }
         }
      }else{
         
      }
      
   }
   LastRunTime=TimeCurrent();

//----
   return(0);
  }
//+------------------------------------------------------------------+