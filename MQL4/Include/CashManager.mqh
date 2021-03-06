//+------------------------------------------------------------------+
//|                                                  CashManeger.mq4 |
//|                                                         by Lorne |
//|                                                   www@luotao.net |
//+------------------------------------------------------------------+
#property copyright "Lorne"
#property link      "www@luotao.net"


//开仓不超过总资金的5%
bool CheckUsePercent()
{
   if((AccountBalance()-AccountFreeMargin())/AccountBalance()<0.05)
      return(true);
   else
      return(false);
}

//最大亏损超过总资金的10%自动斩掉所有仓位
bool CheckAbandonPercent()
{
   //亏损超过一半
   if(AccountEquity( ) <=0.5* AccountBalance( ) )
      return(true);
   if((AccountFreeMargin()-AccountBalance())/AccountBalance()>0.1)
      return(true);
   else
      return(false);
}

//
int GetOrderProfit(int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET))
   {
      return(OrderProfit()/OrderLots()/10);
   }
   else 
      return(EMPTY_VALUE);
}



/*========================================================*/
/*

if(HourIsBetween(8,11)&&TimeDistance(g_LastPrintDebug,5*60))
{

   g_LastPrintDebug=TimeCurrent();
}

 if(HourIsBetween(10,11)&&TimeDistance(g_LastPrintDebug,5*60))
   {
      Print(trendLine+" "+trendVariableCount+" "+g_OpenOrderCount +" "+
      Price2Point(Ask-lastOpenPrice)+" "+g_AddLotProfit+" "+trendLine_smaller);
      g_LastPrintDebug=TimeCurrent();
   }


MarketInfo(Symbol(), MODE_MINLOT)




void Log(string as_0) {
   if (as_0 == "") FileWrite(as_0, TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + ": " + as_0);
}




*/