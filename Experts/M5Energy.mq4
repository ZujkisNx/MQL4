//+------------------------------------------------------------------+
//|                                                     M5Energy.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define Magic 23521
#define Magic2 23521


/*===================================TimeManager===============================================*/
extern string ______="==================ʱ�����==================";
extern int MainTimeFrame=PERIOD_M5;
extern int GmtOffset=12;
extern int TradeBeginHour=14;
extern int TradeEndHour=24;
datetime LastOpenOrderTime;//��һ�ο���ʱ�䣬��������EA����Ҫ
datetime ClearHangOrderTime=300;//�ҵ�ָ��ʱ��δ������ȡ��

int OpenOrderPriceShift=5;//�ҵ���SHIFT����
extern int StopLoss = 30;  //ֹ�����
extern double TakeProfit = 0;
extern double Lot=0.1;//������������
extern int Slip=3;//����ƫ�Ƶ���
extern int TrailingStop = 20;//����ֹ�����

int MainDirection=0;//ָʾ������ 1�� -1�� 1ʱ������ -1������
int OpenOrderCount=0;//��ǰ�ѿ�����
bool IsEnableTrade=true;


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
   DebugInterval=300;

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
   //���ͼ���ϵ�ʱ�����Ƿ��EA�Ƽ���ʱ����һ��
   if(MainTimeFrame!=Period())
      CommentStr="Warning:Timeframe of chart is not "+MainTimeFrame+" minute!\n";
   CommentStr="CurrentTime="+TimeToStr(TimeCurrent())+"\n";
   CommentStr=CommentStr+"IsEARuning="+IsEARuning+"\n";
   if(!IsEARuning)
   {
      ShowComment();
      return(0);
   }
   DailyStat();
    
//--------------------------------------------------------------------------   
    
   //���ڽ���ʱ���ڲ���
   if(!IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour))
      CommentStr=CommentStr+"IsInTradeTime=False\n";

   //�����ϴν��ײ���X��ʱ���ܵ�ʱ��
   int interal=6;
   bool canOpenOrder=IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour) && TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60);
   if(!TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough";
      
//--------------------------------------------------------------------------   
   //�������е�������ֹ��ȡ�����ڹҵ�
   OpenOrderCount=GetExistOrderCount(Magic);
   if(OpenOrderCount>0)
      DealExistOrder(Symbol(),Magic);
   else
   {
   }
   ClearSignal();
   GetSignal(Signal);
   


   //ƽ�ֲ���
   if(Signal[7]==10)//ƽ�յ�
   {
      if(OrderCloseNow(Magic,OP_SELL)>0) 
      {
      }
   }
   if(Signal[6]==10)//ƽ�൥
   {
      if(OrderCloseNow(Magic,OP_BUY)>0)
      {
      }
   }

   //����������ƽ�ֲ����������жϿ���ǰ�ٻ�ȡһ��Ŀǰ�Ѿ�����������
   OpenOrderCount=GetExistOrderCount(Magic);
   double lot;
   if(Signal[0]>0 && canOpenOrder)//ȷ���ź� ����  && LastSignalDirection==1
   {
      lot=Lot*0.5;
      int ss=OpenOrderNow(Symbol(),OP_BUYSTOP,lot,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,BuyColor,OpenOrderPriceShift);
      OpenOrderNow(Symbol(),OP_BUYSTOP,lot,Slip,StopLoss,StopLoss,OrderCommentStr+"2",Magic2,BuyColor,OpenOrderPriceShift);
      LastOpenOrderTime=TimeCurrent();
   }

   if(Signal[1]>0 && canOpenOrder)//ȷ���ź� ����  && LastSignalDirection==-1
   {
      lot=Lot*0.5;
      Print(lot);
      OpenOrderNow(Symbol(),OP_SELLSTOP,lot,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,SellColor,OpenOrderPriceShift);
      OpenOrderNow(Symbol(),OP_SELLSTOP,lot,Slip,StopLoss,StopLoss,OrderCommentStr+"2",Magic2,SellColor,OpenOrderPriceShift);
      LastOpenOrderTime=TimeCurrent();
   }
   

//----
   ShowComment();
   return(0);
  }
//+------------------------------------------------------------------+


double CloseOrderPriceGap=18;
int GetSignal(int& Signal[])
{
   double Histogam[];
   int cnt=7;
   GetMACDHistogam(Histogam,Symbol(),MainTimeFrame,12,26,cnt,0);
   int MACDCrossZero=GetArrCorssValue(Histogam,1,0);//�Ƿ�0��
   
   double price[][6];
   double PriceArr[],EMAArr[];
   ArrayResize(price,cnt);
   ArrayResize(PriceArr,cnt);
   ArrayResize(EMAArr,cnt);
   ArrayCopyRates(price,Symbol(),MainTimeFrame);
   for(int i=0;i<cnt;i++)
   {
      PriceArr[i]=price[i][4];
      EMAArr[i]=iMA(Symbol(),MainTimeFrame,20,0,MODE_EMA,PRICE_CLOSE,i);
   }
   int PriceCrossEMA20=GetArrCorssArr(PriceArr,EMAArr,1);

   int PriceSubEMA=Price2Point(Close[0]-iMA(Symbol(),MainTimeFrame,20,0,MODE_EMA,PRICE_CLOSE,1));
   
   //ƽ��
   if(OpenOrderCount>0 && PriceSubEMA>=CloseOrderPriceGap) Signal[7]=10;
   //ƽ��
   if(OpenOrderCount>0 && PriceSubEMA+CloseOrderPriceGap<=0) Signal[6]=10;
      
   //����
   if(OpenOrderCount==0 && Histogam[1]<0 && Histogam[2]>0 && PriceCrossEMA20==-10)
   {
      MainDirection=-1;
      Signal[1]=10;
      //Print(Histogam[1]+" sell at "+Histogam[0]+" "+OpenOrderCount);
   }
   //����
   if(OpenOrderCount==0 && Histogam[1]>0 && Histogam[2]<0 && PriceCrossEMA20==10)
   {
      MainDirection=1;
      Signal[0]=10;
      //Print(Histogam[1]+"buy at"+Histogam[0]+" "+OpenOrderCount);
   }
   
   if(IsDebug && IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour)
      && TimeDistance(LastPrintDebugTime,DebugInterval))// && HourIsBetween(2,4) 
   {
      Print("MACDCrossZero="+MACDCrossZero+" PriceCrossEMA20="+PriceCrossEMA20+" PriceSubEMA="+PriceSubEMA+
      " Order="+OpenOrderCount+
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
               CustomStepTrailingStopOrder(OrderTicket(),StopLoss,50,70,90);
            else if (OrderType()>1)//STOP or LIMIT
               if(TimeDistance(OrderOpenTime(),ClearHangOrderTime)) OrderDelete(OrderTicket());
         }
      }
   }
}