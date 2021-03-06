#property copyright "Lorne"
#property link      "www@luotao.net"

//#include <SystemManager.mqh>

//确认信号参数
double LastSignalPrice;//信号刚出现的价位
int LastSignalDrection;//方向 1多 -1空
datetime LastSignalTime;//时间
//double LastSignalLot;
datetime ConfirmSignalTime=10;//信号发出后持续这个时间，确认。单位分钟
int ConfirmSignalPoint=10;//信号发出后继续移动超过这个点数

//=========================================================================================


//交易信号持续了1/4个时间框架，即信号发出要持续1/4当前时间框架才认为有效
bool SignalStandingTime()
{
   if((TimeCurrent()-LastSignalTime)>(Period()*60/4))
      return(true);
   else
      return(false);
}

//信号确认
//方式一：信号持续ConfirmSignalTime秒
//方式二：价格延信号方向移动ConfirmSignalPoint点以上
//返回值：1确认 0还需等待
int ConfirmSignal(int direction)
{
   //Print("buy="+signal[0]+"  sell="+signal[1]+"  addbuy="+signal[2]+"  addsell="+signal[3]+"  subbuy="+signal[4]+"  subsell="+signal[5]+"  closebuy="+signal[6]+"  closesell="+signal[7]+"\n");
   double price;
   if(direction==1) price=Ask;
   else price=Bid;
   if(LastSignalDrection==direction)
   {
      double pricemove;
      if(direction==1) pricemove=Price2Point(price-LastSignalPrice);
      else pricemove=Price2Point(LastSignalPrice-price);

      if(TimeDistance(LastSignalTime,ConfirmSignalTime*60+240))//超过5分钟，重新确认信号
      {
         Print("过滤一个做"+direction+"信号");
         ClearConfirmSignal();
      }
      else if(TimeDistance(LastSignalTime,ConfirmSignalTime*60) || pricemove>ConfirmSignalPoint)//
      {
         Print("确认一个做"+direction+"信号");
         ClearConfirmSignal();
         return(1);
      }
      else return(0);
   }

   return(0);
}

//信号没有得到确认，清除确认信号所用的参数
void ClearConfirmSignal()
{
   LastSignalPrice=0;
   LastSignalDrection=0;
   LastSignalTime=0;
}







