//+------------------------------------------------------------------+
//|                                                 TradeContext.mq4 |
//|                                                        komposter |
//|                                             komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "komposter"
#property link      "komposterius@mail.ru"

/////////////////////////////////////////////////////////////////////////////////
/**/ int _IsTradeAllowed( int MaxWaiting_sec = 30 )
/////////////////////////////////////////////////////////////////////////////////
// ������ҵ��״ָ̬�����������ش��룺
//  1 - ������ҵ���У����Խ���
//  0 - ������ҵ�ոտ��С����г���Ϣ���º���Խ��ס�
// -1 - ������ҵæ���ȴ�(��ͼ����ɾ�����ܽ���, �ر��ն�, 
// 	  �ı�ʱ������/ͼ����Ҷ�, ... )
// -2 - ������ҵæ,���ȴ�ʱ��(MaxWaiting_sec)���������ܽ��׽�ֹ����
// 	   (�����ܽ�����֮��ѡ��"������"ѡ�.
//
// MaxWaiting_sec -ʱ�� (���ӣ�, �����ʱ���ڽ�����ҵ������ȴ����� (�����ҵæ�� 
//  Ĭ��ֵ = 30.
/////////////////////////////////////////////////////////////////////////////////
{
	// ��⽻����ҵ�Ƿ����
	if ( !IsTradeAllowed() )
	{
		int StartWaitingTime = GetTickCount();
		Print( "������ҵæ���ȴ�����..." );
		// ����ѭ��
		while ( true )
		{
			// ������ܽ��ױ��û���ϣ�ֹͣ����
			if ( IsStopped() ) { Print( "���ܽ��ױ��û����!" ); return(-1); }
			// ����ȴ�ʱ�䳬�����ȴ�ʱ��MaxWaiting_sec, ͬ��ֹͣ����
			if ( GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000 ) { Print( "���ȴ��޶� (" + MaxWaiting_sec + " ��֧�.)!" ); return(-2); }
			// ���������ҵ����
			if ( IsTradeAllowed() )
			{
				Print( "������ҵ����!" );
				return(0);
			}
			// ����������ж�ѭ��, "�ȴ�" 0,1 �벢���¿�ʼ���
			Sleep(100);
		}
	}
	else
	{
		Print( "������ҵ����!" );
		return(1);
	}
}
/*
���ܽ���ģ�� , ʹ�ú��� _IsTradeAllowed:
int start()
{
	// ȷ�������г�
	...
	// ����ֹ��Ӯ���ͱ�׼����
	...
	// ��⽻����ҵ�Ƿ����
	int TradeAllow = _IsTradeAllowed();
	if ( TradeAllow < 0 ) { return(-1); }
	if ( TradeAllow == 0 )
	{
		RefreshRates();
		// ���¼���ֹ���Ӯ��ˮƽ
		...
	}
	// ����
	OrderSend(.....);
return(0);
}
*/

/////////////////////////////////////////////////////////////////////////////////
/**/ int TradeIsBusy ( int MaxWaiting_sec = 30 )
/////////////////////////////////////////////////////////////////////////////////
// �����ı��������TradeIsBusy 0 �� 1.
// �����ʼ TradeIsBusy = 1, �����ȴ�, ��ʱ TradeIsBusy  = 0, ���ı�.
// ����������TradeIsBusy�����ڣ������ᴴ��
// ���ش���:
//  1 - �ɹ���ɡ� �������TradeIsBusy ֵΪ 1
// -1 - ��ʼ���� TradeIsBusy = 1, ������ҵæ���ȴ�(��ͼ����ɾ�����ܽ���, �ر��ն�, 
// 	  �ı�ʱ������/ͼ����Ҷ�, ... )
// -2 -��ʼ����TradeIsBusy = 1,���ȴ�����(MaxWaiting_sec)
/////////////////////////////////////////////////////////////////////////////////
{
	// ���ڽ�����ҵ�Ĳ��� - ֻ�ǽ�����������
	if ( IsTesting() ) { return(1); }
	int _GetLastError = 0, StartWaitingTime = GetTickCount();

	//+------------------------------------------------------------------+
	//| �������Ƿ���ڡ����û�У�������
	//+------------------------------------------------------------------+
	while( true )
	{
		//  ������ܽ��ױ��û���ϣ�ֹͣ����
		if ( IsStopped() ) { Print( "���ܽ��ױ��û����!" ); return(-1); }
		// ����ȴ�ʱ�䳬�����ȴ�ʱ��MaxWaiting_sec, ͬ��ֹͣ����
		if ( GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000 ) { Print( "���ȴ��޶� (" + MaxWaiting_sec + " ��֧�.)!" ); return(-2); }
		// �������Ƿ����
		if ( GlobalVariableCheck( "TradeIsBusy" ) )
		// ��������Ƴ�ѭ��ģʽ�����иı� TradeIsBusyֵ
		{ break; }
		else
		// ���GlobalVariableCheck ���� FALSE,��ζ�ű��������ڻ������ɴ���
		{
			_GetLastError = GetLastError();
			// ����������ɣ���ʾ��Ϣ���ȴ� 0,1�벢���¿�ʼ
			if ( _GetLastError != 0 )
			{
				Print( "TradeIsBusy() - GlobalVariableCheck ( \"TradeIsBusy\" ) - Error #", _GetLastError );
				Sleep(100);
				continue;
			}
		}

		// ���û�д���˵��û��������������Դ���
		if ( GlobalVariableSet ( "TradeIsBusy", 1.0 ) > 0 )
		//���GlobalVariableSet > 0,˵����������ɹ��������˳�������
		{ return(1); }
		else
		// ���GlobalVariableSet ����ֵ<= 0, ˵���������������ɴ���
		{
			_GetLastError = GetLastError();
			//��ʵ��Ϣ, �ȴ� 0,1 �벢���¿�ʼ
			if ( _GetLastError != 0 )
			{
				Print( "TradeIsBusy() - GlobalVariableSet ( \"TradeIsBusy\", 0.0 ) - Error #", _GetLastError );
				Sleep(100);
				continue;
			}
		}
	}

	//+------------------------------------------------------------------+
	//| �������ִ�е���˵㣬˵�������������
	//| �ȴ�TradeIsBusy��Ϊ0 ���� TradeIsBusyֵ�� 0 �ı�Ϊ 1
	//+------------------------------------------------------------------+
	while( true )
	{
		// ������ܽ��ױ��û���ϣ�ֹͣ����
		if ( IsStopped() ) { Print( "���ܽ��ױ��û���ֹ!" ); return(-1); }
		// ����ȴ�ʱ�䳬�����ȴ�ʱ��MaxWaiting_sec, ͬ��ֹͣ����
		if ( GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000 ) { Print( "���ȴ��޶�(" + MaxWaiting_sec + " ��֧�.)!" ); return(-2); }
		// ���Ըı�TradeIsBusy ֵ��0�� 1
		if ( GlobalVariableSetOnCondition( "TradeIsBusy", 1.0, 0.0 ) )
		// ����ɹ�, ��ʵ��Ϣ,���� 1 - "�ɹ����"
		{ return(1); }
		else
		//���û�п��ܴ�������ԭ��: TradeIsBusy = 1 (��Ҫ�ȴ�)�����ɴ��� (����Ҫ���)
		{
			_GetLastError = GetLastError();
			// ������ɴ�����ʾ��Ϣ������
			if ( _GetLastError != 0 )
			{
				Print( "TradeIsBusy() - GlobalVariableSetOnCondition ( \"TradeIsBusy\", 1.0, 0.0 ) - Error #", _GetLastError );
				continue;
			}
		}

		// ������󲻴��ڣ�˵�� TradeIsBusy = 1 (�������ܽ����ڽ�����) -��ʽ��Ϣ���ȴ�...
		Comment ( "�ȴ����������ܽ����ڽ�����.." );
		Sleep(1000);
	}
}

/////////////////////////////////////////////////////////////////////////////////
/**/ void TradeIsNotBusy ()
/////////////////////////////////////////////////////////////////////////////////
// ������װ���������TradeIsBusy = 0.
// ����������TradeIsBusy �����ڣ�����������
// ��û�����������ǰ,��������ֹͣ���С�
/////////////////////////////////////////////////////////////////////////////////
{
	// ���ڽ�����ҵ�Ĳ��� - ֻ�ǽ�����������
	if ( IsTesting() ) { return(0); }
	int _GetLastError;

	while( true )
	{
		// ���԰�װ�������ֵ= 0 (�򴴽��������)
		if ( GlobalVariableSet( "TradeIsBusy", 0.0 ) > 0 )
		//���GlobalVariableSet ����ֵ > 0, ˵���ɹ���ɡ���ʾ��Ϣ
		{ return(1); }
		else
		// ���GlobalVariableSet ����ֵ<= 0, ˵�����ɴ�����ʾ��Ϣ�� �ȴ�������
		{
			_GetLastError = GetLastError();
			if ( _GetLastError != 0 )
			{ Print( "TradeIsNotBusy() - GlobalVariableSet ( \"TradeIsBusy\", 0.0 ) - Error #", _GetLastError ); }
		}
		Sleep(100);
	}
}

/*
���ܽ���ģ��ʹ�ú��� TradeIsBusy()�� TradeIsNotBusy():

#include <TradeContext.mqh>

int start()
{
	//  ȷ�������г�
	...
	//����ֹ��Ӯ���ͱ�׼����
	...
	// �ȴ��г����в�ռ��(������ɴ����˳�)
	if ( TradeIsBusy() < 0 ) { return(-1); }
	//��ʾ�г���Ϣ
	RefreshRates();
	//  ���¼���ֹ���Ӯ��ˮƽ
	...
	// ����
	OrderSend(.....);
	// ������ҵ����
	TradeIsNotBusy();
return(0);
}
*/