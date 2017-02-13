//+------------------------------------------------------------------+
//|                                             PauseBeforeTrade.mq4 |
//|                       Copyright ?2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern int PauseBeforeTrade = 10; // ����֮���ͣ��(����Ϊ��λ)
 
/////////////////////////////////////////////////////////////////////////////////
// int _PauseBeforeTrade()
//
// �����������LastTradeTime�����趨�ط�ʱ��ֵ .
// ����˿̿����ĵط�ʱ��ֵС��LastTradeTime + 
// PauseBeforeTrade ֵ,���������еȴ���
// �������û���������LastTradeTime, ���������д���.
// ���ش���:
//  1 - �ɹ�����
// -1 - ���ܽ��ױ��û����(���ܽ��״�ͼ����ɾ��, 
//      �ն˹ر�, ͼ����ҶԻ�ʱ�����ڸı䣬�ȵȡ�)
/////////////////////////////////////////////////////////////////////////////////
int _PauseBeforeTrade()
 {
  // �ڲ���ִ���ڼ�û��ͣ�� - ֻ���ն˺���
  if(IsTesting()) 
    return(1); 
  int _GetLastError = 0;
  int _LastTradeTime, RealPauseBeforeTrade;
 
  //+------------------------------------------------------------------+
  //| �����������Ƿ���ڡ���������ڣ����д���                       |
  //+------------------------------------------------------------------+
  while(true)
   {
    // ������ܽ��ױ��û���ϣ�ֹͣ����
    if(IsStopped()) 
     { 
      Print("���ܽ��ױ��û���ֹ!"); 
      return(-1); 
     }
    // �����������Ƿ����
    // ������ڣ�ѭ���ȴ�
    if(GlobalVariableCheck("LastTradeTime")) 
      break;
    else
     // ���GlobalVariableCheck����FALSE, ˵��û���κ�����������ڣ�
     // �����ڼ������г����˴���
     {
      _GetLastError = GetLastError();
      // �����Ȼ���ڴ�����ʾ��Ϣ���ȴ�0.1�룬 
      // ��ʼ���¼��
      if(_GetLastError != 0)
       {
        Print("_PauseBeforeTrade()-GlobalVariableCheck(\"LastTradeTime\")-Error #",
              _GetLastError );
        Sleep(100);
        continue;
       }
     }
    // ���û�д�������,˵��û��������������Դ���
    // ���GlobalVariableSet > 0, ˵����������ɹ�����. 
    // �˳�����
    if(GlobalVariableSet("LastTradeTime", LocalTime() ) > 0) 
      return(1);
    else
     // ���GlobalVariableSet ����ֵ<= 0, ˵���ڱ��������ڼ����ɴ���
     {
      _GetLastError = GetLastError();
      // ��ʾ��Ϣ,�ȴ�0.1�룬���¿�ʼ���� 
      if(_GetLastError != 0)
       {
        Print("_PauseBeforeTrade()-GlobalVariableSet(\"LastTradeTime\", ", 
              LocalTime(), ") - Error #", _GetLastError );
        Sleep(100);
        continue;
       }
     }
   }
  //+--------------------------------------------------------------------------------+
  //| �������ִ�дﵽ�˵�,���������������                                          |
  //|                                                                                |
  //| �ȴ�LocalTime() ֵ> LastTradeTime + PauseBeforeTrade                           |
  //+--------------------------------------------------------------------------------+
  while(true)
   {
    // ������ܽ��ױ��û���ϣ�ֹͣ����
    if(IsStopped()) 
     { 
      Print("���ܽ��ױ��û���ֹ!"); 
      return(-1); 
     }
    // ��ȡ�������ֵ 
    _LastTradeTime = GlobalVariableGet("LastTradeTime");
    // �����ʱ���ɴ�����ʾ��Ϣ���ȴ�0.1�룬 
    // �����ڴ˳���
    _GetLastError = GetLastError();
    if(_GetLastError != 0)
     {
      Print("_PauseBeforeTrade()-GlobalVariableGet(\"LastTradeTime\")-Error #", 
            _GetLastError );
      continue;
     }
    // ����Ϊ��λ����������׽�����ȥ��ʱ��
    RealPauseBeforeTrade = LocalTime() - _LastTradeTime;
    // �������PauseBeforeTrade������ʱ���ȥ��
    if(RealPauseBeforeTrade < PauseBeforeTrade)
     {
      // ��ʾ��Ϣ���ȴ�һ�룬���¼���
      Comment("Pause between trades. Remaining time: ", 
               PauseBeforeTrade - RealPauseBeforeTrade, " sec" );
      Sleep(1000);
      continue;
     }
    // �����ȥʱ�䳬��PauseBeforeTrade������ֹͣѭ��
    else
      break;
   }
  //+--------------------------------------------------------------------------------+
  //| �������ִ�е���˵㣬˵������������ڲ��ҵط�ʱ�䳬��                         |
  //|LastTradeTime + PauseBeforeTrade                                                |
  //|                                                                                |
  //| ���������LastTradeTime ���õط�ʱ��ֵ                                         |
  //+--------------------------------------------------------------------------------+
  while(true)
   {
    // ������ܽ��ױ��û���ϣ�ֹͣ����
    if(IsStopped()) 
     { 
      Print("���ܽ��ױ��û���ֹ!"); 
      return(-1);
     }

    // ���������LastTradeTime���õط�ʱ��ֵ��
    // �ɹ���������˳�
    if(GlobalVariableSet( "LastTradeTime", LocalTime() ) > 0) 
     { 
      Comment(""); 
      return(1); 
     }
    else
    // ���GlobalVariableSet ����ֵ<= 0, ˵����������
     {
      _GetLastError = GetLastError();
      // ��ʾ��Ϣ���ȴ�0.1 �룬�������¿�ʼ����
      if(_GetLastError != 0)
       {
        Print("_PauseBeforeTrade()-GlobalVariableSet(\"LastTradeTime\", ", 
              LocalTime(), " ) - Error #", _GetLastError );
        Sleep(100);
        continue;
       }
     }
   }
 }