//+------------------------------------------------------------------+
//|                                                 TradeContext.mq4 |
//|                                                        komposter |
//|                                             komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "komposter"
#property link      "komposterius@mail.ru"


extern int StopLoss = 20;  //ֹ�����
extern double TakeProfit = 130;
extern double Lot=0.1;
extern int TrailingStop = 20;//����ֹ�����
extern int Slip=3;

string comment="DefaultEA";

color buyColor=Red;
color sellColor=Lime;


//+------------------------------������������------------------------------------+
//�������У��ض�magic����������
int GetExistOrder(int magic)
{
int result;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic) result++;
      }
   }
   return(result);
}
//+------------------------------//������������------------------------------------+

//+------------------------------ʱ�������------------------------------------+



//+------------------------------//ʱ�������------------------------------------+

//+------------------------------�µ���������------------------------------------+
//���µ����޸�ֹ��ֹӯ
int OpenOrderNow(string symbol,int orderType,double lot,int slip,int stopPoint,int profitPoint,string comment,int magic,color c)
{
   int ticket;
   RefreshRates();
   if(orderType==OP_BUY)
      ticket=OrderSend(Symbol(),orderType,lot,Ask,slip,0,0,comment,magic,0,c);
   else if(orderType==1)
      ticket=OrderSend(Symbol(),orderType,lot,Bid,slip,0,0,comment,magic,0,c);

   if (ticket<0)
   {
      Alert("OrderSend failed:"+GetLastError());
      return(0);
   }else if(ticket>0){
      if(OrderSelect(ticket, SELECT_BY_TICKET))
      {
         double point=MarketInfo(OrderSymbol(),MODE_POINT);
         double StopLossPrice;
         double TakeProfitPrice;
         if(stopPoint==0)
            StopLossPrice=0;
         else if(stopPoint>0)
         {
            if(orderType==0)
            {
               StopLossPrice=OrderOpenPrice()-stopPoint*10*point;
            }
            else if(orderType==1)
            {
               StopLossPrice=OrderOpenPrice()+stopPoint*10*point;
            }
         }
         if(profitPoint==0)
            TakeProfitPrice=0;
         else if(profitPoint>0)
         {
            if(orderType==0)
            {
               TakeProfitPrice=OrderOpenPrice()+profitPoint*10*point;
            }else if(orderType==1)
            {
               TakeProfitPrice=OrderOpenPrice()-profitPoint*10*point;
            }
         }
            
         if(!OrderModify(ticket,OrderOpenPrice(),StopLossPrice,TakeProfitPrice,0,c))
            Alert("OrderModify failed:"+GetLastError());
      }
   }
}


//ƽ��
int OrderCloseNow(int magic,int ordertype)
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic)
         {
            if(OrderType()==OP_BUY && ordertype==OP_BUY)//�൥
               OrderClose(OrderTicket(),OrderLots(),Bid,Slip,buyColor);
               
            else if (OrderType()==OP_SELL && ordertype==OP_SELL)//�յ�
               OrderClose(OrderTicket(),OrderLots(),Ask,Slip,sellColor);
         }
      }
   }
}



//+------------------------------//�µ���������------------------------------------+



//+------------------------------����ָ�겿��------------------------------------+
 
/*
���߽���
-10����
-7���м�ǿ
-3���м���
10���
7���м�ǿ
3���м���
*/
int CheckMACross(string symbol,int timeframe,int period1,int period2,int mode,int shift)
{
   double Ma1latter=iMA(symbol,timeframe,period1,0,mode,PRICE_CLOSE,1+shift);
   double Ma1former=iMA(symbol,timeframe,period1,0,mode,PRICE_CLOSE,2+shift); 
   double Ma2latter=iMA(symbol,timeframe,period2,0,mode,PRICE_CLOSE,1+shift);
   double Ma2former=iMA(symbol,timeframe,period2,0,mode,PRICE_CLOSE,2+shift);
 
   if (Ma1former>Ma2former && Ma1latter<Ma2latter)//����
   {
      return(-10);
   }
   if (Ma1former<Ma2former && Ma1latter>Ma2latter)//���
   {
      return(10);
   }
   if (Ma1former>Ma2former && Ma1latter>Ma2latter)//��������
   {
      if(Ma1latter-Ma2latter>Ma1former-Ma2former)
         return(7);
      else
         return(3);
   }
   if (Ma1former<Ma2former && Ma1latter<Ma2latter)//�½�����
   {
      if(Ma2latter-Ma1latter>Ma2former-Ma1former)
         return(-7);
      else
         return(-3);
   }
   return(0);
}

/*
MACD����
-10����
-7��λ����
-5������ǿ
-3���м���
10���
7��λ���
5������ǿ
3���м���
*/
int CheckMACDCross(string symbol,int timeframe,int shift)
{
   int fastEMA=12;
   int slowEMA=26;
   int signalSMA=9;
   double     ind_buffer1[];
   double     ind_buffer2[];
   for(int i=0; i<50; i++)
      ind_buffer1[i]=iMA(symbol,timeframe,fastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(symbol,timeframe,slowEMA,0,MODE_EMA,PRICE_CLOSE,i);
   for(i=0; i<50; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,signalSMA,0,MODE_SMA,i);
   //buffer1����
   //buffer2����
   if(ind_buffer1[0+shift]>ind_buffer2[0+shift] && ind_buffer1[1+shift]<ind_buffer2[1+shift])//MACD���
   {
      if(ind_buffer2[0]<0)//���ߴ���0�·�
         return(10);
      else
         return(7);
   }
   if(ind_buffer1[0+shift]<ind_buffer2[0+shift] && ind_buffer1[1+shift]>ind_buffer2[1+shift])//MACD����
   {
      if(ind_buffer2[0]>0)//���ߴ���0�Ϸ�
         return(-10);
      else
         return(-7);
   }
   if(ind_buffer1[0+shift]>ind_buffer2[0+shift] && ind_buffer1[1+shift]>ind_buffer2[1+shift])//��������
   {
      if(ind_buffer1[0+shift]-ind_buffer2[0+shift] > ind_buffer1[1+shift]-ind_buffer2[1+shift])//������ǿ
         return(5);
      else//��������
         return(3);
   }
   if(ind_buffer1[0+shift]<ind_buffer2[0+shift] && ind_buffer1[1+shift]<ind_buffer2[1+shift])//�½�����
   {
      if(ind_buffer2[0+shift]-ind_buffer1[0+shift] > ind_buffer2[1+shift]-ind_buffer1[1+shift])//�½���ǿ
         return(-5);
      else//�½�����
         return(-3);
   }
   return(0);
}
 
/*
�۸�Խ����  
10�ϴ� 
-10�´�
*/
int PriceCrossMA(string symbol,int timeframe,int maperiod,int mode,int shift)
{
   double ma=iMA(symbol,timeframe,maperiod,0,mode,PRICE_CLOSE,1+shift);
   double array1[][6];
   ArrayCopyRates(array1,symbol, timeframe);
   
   double latteropen=array1[0+shift][1];
   double formerclose=array1[1+shift][1];
   
   if((latteropen<ma)&&(formerclose>ma))//�´�����
      return(-10);
   if((latteropen>ma)&&(formerclose<ma))//�ϴ�����
      return(10);
   return(0);
}

//+------------------------------//����ָ�겿��------------------------------------+


