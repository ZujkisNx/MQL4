//+------------------------------------------------------------------+
//|                                                      Template.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define Magic 34643245

#include <TemplateParameter.mqh>
#include <SystemManager.mqh>
#include <TimeManager.mqh>
#include <OrderManager.mqh>
#include <CashManager.mqh>
#include <IndicatorManager.mqh>
#include <CustomIndicatorManager.mqh>



//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   SystemInit();
//----
   DebugInterval=5;

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   SystemDeinit();
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
   CommentStr="CurrentTime="+TimeToStr(TimeCurrent())+"\n";
   CommentStr=CommentStr+"IsEARuning="+IsEARuning+"\n";
   bool canRunStart=(TimeDistance(LastRunStartTime,RunStartInterval) && IsEARuning);
   if(!canRunStart)
   {
      return(0);
   }
   LastRunStartTime=TimeCurrent();
   
   DailyStat();

   
   //���ͼ���ϵ�ʱ�����Ƿ��EA�Ƽ���ʱ����һ��
   if(MainTimeFrame!=Period())
      CommentStr="Warning:Timeframe of chart is not "+MainTimeFrame+" minute!\n";
      
//--------------------------------------------------------------------------   
   //�����ϴν��ײ���X��ʱ���ܵ�ʱ��
   int interal=6;
   bool canOpenOrder=IsInTradeTime() && TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60);
   if(!TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough";
      
   //���ڽ���ʱ���ڲ���
   if(!IsInTradeTime())
      CommentStr=CommentStr+"IsInTradeTime=False\n";

//--------------------------------------------------------------------------   
   //�������е�������ֹ��ȡ�����ڹҵ�
   OpenOrderCount=GetExistOrderCount(Magic);
   if(OpenOrderCount>0)
      DealExistOrder(Symbol(),Magic);
   else
   {
      LastLots=0;
      LastOpenPrice=0;
   }
   ClearSignal();
   GetSignal(Signal);
   
   if(!TimeDistance(LastOpenOrderTime,MainTimeFrame*4*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough";

   //ƽ�ֲ���
   if(Signal[7]==10)//ƽ�յ�
   {
      if(OrderCloseNow(Magic,OP_SELL)>0) 
      {
         LastLots=0;
         LastOpenPrice=0;
      }
   }
   if(Signal[6]==10)//ƽ�൥
   {
      if(OrderCloseNow(Magic,OP_BUY)>0)
      {
         LastLots=0;//�ϴο�������
         LastOpenPrice=0;//�ϴο�����λ
      }
   }

   //����������ƽ�ֲ����������жϿ���ǰ�ٻ�ȡһ��Ŀǰ�Ѿ�����������
   OpenOrderCount=GetExistOrderCount(Magic);
   
   if(Signal[0]>0 && canOpenOrder)//ȷ���ź� ����  && LastSignalDirection==1
   {
      LastLots=Lot*Signal[0]/10;
      LastOpenPrice=Ask;
      int ss=OpenOrderNow(Symbol(),OP_BUY,LastLots,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,BuyColor,0);
      LastOpenOrderTime=TimeCurrent();
   }

   if(Signal[1]>0 && canOpenOrder)//ȷ���ź� ����  && LastSignalDirection==-1
   {
      LastLots=Lot*Signal[1]/10;
      LastOpenPrice=Bid;
      OpenOrderNow(Symbol(),OP_SELL,LastLots,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,SellColor,0);
      LastOpenOrderTime=TimeCurrent();
   }
   

//----
   ShowComment();
   return(0);
  }
//+------------------------------------------------------------------+



int GetSignal(int& Signal[])
{


   //ƽ��
   if(OpenOrderCount>0 && ) Signal[7]=10;
   //ƽ��
   if(OpenOrderCount>0 &&) Signal[6]=10;
      
   //����
   if(OpenOrderCount==0 && )
   {
      MainDirection=-1;
      Signal[1]=10;
      //Print(Histogam[1]+" sell at "+Histogam[0]+" "+OpenOrderCount);
   }
   //����
   if(OpenOrderCount==0 && )
   {
      MainDirection=1;
      Signal[0]=10;
      //Print(Histogam[1]+"buy at"+Histogam[0]+" "+OpenOrderCount);
   }
   
   if(IsDebug && IsInTradeTime()
      && TimeDistance(LastPrintDebugTime,DebugInterval*60))// && HourIsBetween(2,4) 
   {
      Print(
      "Order="+OpenOrderCount+
      " buy="+Signal[0]+" sell="+Signal[1]+" abuy="+Signal[2]+" asell="+Signal[3]+" sbuy="+Signal[4]+
      " ssell="+Signal[5]+" cbuy="+Signal[6]+" csell="+Signal[7]+"\n");
      LastPrintDebugTime=TimeCurrent();
   }
}



/*=======================================================================================*/

//�������еĵ� ��Ҫ�ǵ����ƶ�ֹ��ֹӯ �Լ�һЩ�쳣����ʱ��ƽ��
int DealExistOrder(string symbol,int magic)
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && OrderSymbol()==symbol)
         {
            if(OrderType()<2)//OP_SELL or OP_BUY
               StepTrailingStopOrder(OrderTicket(),TrailingStop,TrailingStopStep);
            else if (OrderType()>1)//STOP or LIMIT
               if(TimeDistance(OrderOpenTime(),ClearHangOrderTime)) OrderDelete(OrderTicket());
         }
      }
   }
}