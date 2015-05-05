//+------------------------------------------------------------------+
//|                                                    Publisher.mq4 |
//|                                                       Greatshore |
//|                                               greatshore@live.cn |
//+------------------------------------------------------------------+
#property copyright "Greatshore"
#property link      "greatshore@live.cn"

#define GVARUP        "Publisher_UpdateTime"        // ����ʱ��ȫ�ֱ�����
#define GVARHASH      "Publisher_LastOrdersHash"    // ��һ�γֲֵ�Hash
#define DATAPATH      "Publisher\\"                 // �����ļ�Ŀ¼
#define VARPREFIX     "<!!-"                        // �滻����ǰ׺
#define VARSUFFIX     "--->"                        // �滻������׺
#define REALSTR       "$"                           // ��ʾ��ʵֵ���

//---- input parameters
extern int     UpdatePeriod   = 0;                           // �������ڣ����ӣ�����5���ӣ�0��ʾ�ֲ��б仯������
extern int     HistoryNum     = 0;                           // ��ʷ���׵�������Ŀ
extern int     HistoryPeriod  = 0;                           // ��ʷ���׵����ڵ�λ��0-����1-��,2-�ܣ�3-��
extern bool    ShowPending    = true;                        // �Ƿ���ʾ�ҵ���Ϣ
extern int     TZOffset       = 6;                           // ������ʱ������
extern string  TZComment      = "Beijing Time:";             // ʱ���ע
extern string  FTPPath        = "/forexbot";                 // �ϴ�����������Ŀ¼
extern string  WebFileName    = "state.htm";                 // �ϴ������������ļ���
extern string  TemplateName   = "Publisher.template.htm";    // ����ҳ��ʹ�õ�ģ���ļ���
extern string  ShowAccount    = "*****";                     // ��ʾ���˻��ţ�$��ʾʵ���˻�
extern string  ShowName       = "abui";                      // ��ʾ���˻�����$��ʾʵ���˻���
extern string  ShowBroker     = "$";                         // ��ʾ�Ĺ�˾����$��ʾʵ�ʹ�˾��
extern bool    ShowTicket     = true;                        // �Ƿ���ʾ������
extern bool    ShowOpenTime   = true;                        // �Ƿ���ʾ����ʱ��
extern bool    ShowSize       = true;                        // �Ƿ���ʾ����
extern bool    ShowTPSL       = true;                        // �Ƿ���ʾ����ֹ���
extern bool    ShowSwap       = true;                        // �Ƿ���ʾ��ҹ��Ϣ
extern int     ShowProfitType = 2;                           // ��ʾ������ʽ��0-����ʾ��1-������2-��ֵ
extern bool    ShowComment    = false;                       // �Ƿ���ʾע����
extern bool    ShowEquity     = true;                        // �Ƿ���ʾ�˻���ֵ
extern bool    ShowFreeMargin = true;                        // �Ƿ���ʾ���ɱ�֤����
extern string  HiddenText     = "---";                       // ����ֵ��ʾ�ַ�

string OpStr[] = {"buy", "sell", "buy limit", "sell limit", "buy stop", "sell stop"};

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
  if (!ShowSize) // �������ʾ�ֲ����������ҹ��Ϣ�ͻ�����������ʾ
  {
    ShowSwap = false;
    if (ShowProfitType == 2)
      ShowProfitType = 1;
  }
  
  if ((UpdatePeriod < 5) && (UpdatePeriod > 0))
    UpdatePeriod = 5;

  return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
  GlobalVariableDel(GVARUP);
  GlobalVariableDel(GVARHASH);

  return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
  datetime LastUpdate, CurrentTime;
  bool NeedUpdate;
  
  CurrentTime = TimeCurrent();
  LastUpdate  = GlobalVariableGet(GVARUP);
  if (UpdatePeriod == 0)
    NeedUpdate = CheckOrderChange();
  else
    NeedUpdate = (CurrentTime - LastUpdate) / 60 >= UpdatePeriod;
  if (NeedUpdate)
  {
    GlobalVariableSet(GVARUP, CurrentTime);
    GeneratePage(DATAPATH + WebFileName);
//    Print("Updating statement finished.");
    SendFTP(DATAPATH + WebFileName, FTPPath);
    FileDelete(DATAPATH + WebFileName);
  }
  
  return(0);
}

//+------------------------------------------------------------------+

// ===== ���ɳֱֲ���ҳ�� =====
void GeneratePage(string FileName)
{
  int fin, fout, i, j;
  string linestr;
  
  fin  = FileOpen(DATAPATH + TemplateName, FILE_READ  | FILE_BIN);
  if (fin < 0)
    Print("Error in reading template file.");
  else
  {
    fout = FileOpen(DATAPATH + WebFileName,  FILE_WRITE | FILE_CSV, ' ');
    while (!FileIsEnding(fin))
    {
      linestr = GetOneLine(fin);
      if (StringLen(linestr) > 0)
      {
        i = StringFind(linestr, VARPREFIX);
        if (i >= 0)
          ReplaceVarStr(fout, linestr, i);
        else
          FileWrite(fout, linestr);
      }
    }
    FileClose(fin);
    FileClose(fout);
  }  
}

// ===== ���ļ��ж�ȡһ�� =====
string GetOneLine(int InFile)
{
  int i, j;
  string ret, char;
  
  ret = "";
  while (!FileIsEnding(InFile))
  {
    char = FileReadString(InFile, 1);
    if ((char == "\r") || (char == "\n"))
      break;
    else
      ret = ret + char;
  }
  return(ret);
}

// ===== �滻�����ַ��������� =====
void ReplaceVarStr(int OutFile, string linestr, int start)
{
  string VarName, LeftStr, RightStr, MidStr;
  int end, i;
  
  end = StringFind(linestr, VARSUFFIX, start);
  i = start + StringLen(VARPREFIX);
  if (start > 0)
    LeftStr  = StringSubstr(linestr, 0, start);
  RightStr = StringSubstr(linestr, end + StringLen(VARSUFFIX));
  MidStr   = "";
  VarName  = StringSubstr(linestr, i, end - i);
  if (VarName == "ACCOUNTNUM")         // �˻�����
  {    
    if (ShowAccount == REALSTR)
      MidStr = AccountNumber();
    else
      MidStr = ShowAccount;
  }
  else if (VarName == "ACCOUNTNAME")   // �˻�����
  {
    if (ShowName == REALSTR)
      MidStr = AccountName();
    else
      MidStr = ShowName;
  }
  else if (VarName == "BROKER")        // ��˾��
  {
    if (ShowBroker == REALSTR)
      MidStr = AccountCompany();
    else
      MidStr = ShowBroker;
  }
  else if (VarName == "CURRENCY")      // �˻�����
    MidStr = AccountCurrency();
  else if (VarName == "EQUITY")        // �˻���ֵ
  {
    if (ShowEquity)
      MidStr = DoubleToStr(AccountEquity(), 2);
    else
      MidStr = HiddenText;
  }
  else if (VarName == "FREEMARGIN")    // ���ñ�֤��
  {
    if (ShowFreeMargin)
      MidStr = DoubleToStr(AccountFreeMargin(), 2);
    else
      MidStr = HiddenText;
  }
  else if (VarName == "UPDATETIME")    // ����ʱ��
  {
    MidStr = TimeToStr(TimeCurrent());
    if ((TZOffset != 0) && (StringLen(TZComment) > 0))
    MidStr = MidStr + " [" + TZComment +  TimeToStr(TimeCurrent() + TZOffset * 3600) + "]";
  }
  else if (VarName == "HOLDINGORDERS")    // �ֲ��б�
    WriteHoldingOrders(OutFile);
  else if ((VarName == "PENDINGORDERS") && ShowPending)    // �ҵ��б�
    WritePendingOrders(OutFile);
  else
    MidStr = HiddenText;
  
  FileWrite(OutFile, LeftStr+ MidStr + RightStr);
}

// ===== д��ֲ��б� =====
void WriteHoldingOrders(int OutFile)
{
  int i, j, c, op;
  string symb;
  
  for (i = 0, c = 0; i < OrdersTotal(); i++)
  {
    OrderSelect(i, SELECT_BY_POS);
    op = OrderType();
    if (op < 2)
    {
      symb = OrderSymbol();
      c++;
      WriteLeftColums(OutFile, c, op, symb, MarketInfo(symb, MODE_DIGITS));
      WriteLeftSwapProfit(OutFile, op, symb);
      WriteLeftComment(OutFile);
      FileWrite(OutFile, "</tr>");
    }
  }
}

// ===== д��ҵ��б� =====
void WritePendingOrders(int OutFile)
{
  int i, j, c, op;
  string symb, str = "";
  datetime exp;
  
  for (i = 0, c = 0; i < OrdersTotal(); i++)
  {
    OrderSelect(i, SELECT_BY_POS);
    op = OrderType();
    if (op > 1)
    {
      symb = OrderSymbol();
      c++;
      WriteLeftColums(OutFile, c, op, symb, MarketInfo(symb, MODE_DIGITS));
      exp = OrderExpiration();  // ����ʱ��
      if (exp > 0)
        str = TimeToStr(exp);
      FileWrite(OutFile, "<td class=msdate nowrap>" + str + "</td>");
      WriteLeftComment(OutFile);
      FileWrite(OutFile, "</tr>");
    }
  }
}

// ===== д��ǰ�벿�� =====
void WriteLeftColums(int OutFile, int c, int op, string symb, int d)
{
  string str, str2, fmt;
  int i;

  // ��һ�У��б���ɫ
  if (c % 2 == 1)
    str = ">";
  else
    str = " bgcolor=#E0E0E0>";
  FileWrite(OutFile, "<tr align=right" + str);
      
  // Ticket
  if (ShowTicket)
    str = OrderTicket();
  else
    str = HiddenText;
  FileWrite(OutFile, "<td>" + str + "</td>");
     
  // ����ʱ��
  if (ShowOpenTime)
    str = TimeToStr(OrderOpenTime());
  else
    str = HiddenText;
  FileWrite(OutFile, "<td class=msdate nowrap>" + str + "</td>");

  // ���ַ���
  FileWrite(OutFile, "<td>" + OpStr[op] + "</td>");

  // ��������
  if (ShowSize)
    str = DoubleToStr(OrderLots(), 2);
  else
    str = HiddenText;
  FileWrite(OutFile, "<td class=mspt>" + str + "</td>");

  // ���׻��ҶԺͿ��ּ�
  FileWrite(OutFile, "<td>" + symb + "</td>");
  fmt = "<td style=\"mso-number-format:0\.";
  for (i = 0; i < d; i++)
    fmt = fmt + "0";
  FileWrite(OutFile, fmt + ";\">" + DoubleToStr(OrderOpenPrice(), d) + "</td>");

  // ����ֹ���
  if (ShowTPSL)
  {
    str  = DoubleToStr(OrderTakeProfit(), d);
    str2 = DoubleToStr(OrderStopLoss(), d);
  }
  else
  {
    str  = HiddenText;
    str2 = HiddenText;
  }
  FileWrite(OutFile, fmt + ";\">" + str  + "</td>");
  FileWrite(OutFile, fmt + ";\">" + str2 + "</td>");
}

// ===== д����Ϣ�ͻ��� =====
void WriteLeftSwapProfit(int OutFile, int op, string symb)
{
  double cp;
  string str;
  
  // ��ҹ��Ϣ
  if (ShowSwap)
    str = DoubleToStr(OrderSwap(), 2);
  else
    str = HiddenText;
  FileWrite(OutFile, "<td class=mspt>" + str + "</td>");
  
  // ����
  switch (ShowProfitType)
  {
    case 0 :
         str =  ">" + HiddenText;
         break;
    case 1 :
         if (op == OP_BUY)
           cp = MarketInfo(symb, MODE_BID);
         else
           cp = MarketInfo(symb, MODE_ASK);
         str = ">" + DoubleToStr((cp - OrderOpenPrice()) / MarketInfo(symb, MODE_POINT), 0) + "p";
         break;
    case 2 :
         str = " class=mspt>" + DoubleToStr(OrderProfit(), 2);
  }
  FileWrite(OutFile, "<td" + str + "</td>");
}

// ===== д��ע�� =====
void WriteLeftComment(int OutFile)
{
  string str;

  str = OrderComment();
  if (!ShowComment && (StringLen(str) > 0))
    str = HiddenText;
  FileWrite(OutFile, "<td>" + str  + "</td>");
}

// ===== ���ֲ���û�б仯 =====
bool CheckOrderChange()
{
  int LastOrdersHash, CurrnetOrdersHash;
  
  LastOrdersHash    = GlobalVariableGet(GVARHASH);
  CurrnetOrdersHash = GetOrdersHash(OrdersTotal());
  if (CurrnetOrdersHash != LastOrdersHash)
  {
    GlobalVariableSet(GVARHASH, CurrnetOrdersHash);
    return(true);
  }
  else
    return(false);
}

// ===== ���㵱ǰ�ֲֵ�Hash =====
int GetOrdersHash(int OrdersCount)
{
  int Orders[][6], i, j, k, Hash;
  string OrderSymb, str;

  ArrayResize(Orders, OrdersCount);
  
  // ���ֲ�ת��������
  for (i = 0; i < OrdersCount; i++)
  {
    OrderSelect(i, SELECT_BY_POS);
    OrderSymb = OrderSymbol();
    
    Orders[i][0] = OrderTicket();
    Orders[i][1] = SymbolToInt(OrderSymb);
    Orders[i][2] = OrderType();
    Orders[i][3] = OrderLots() * 100;
    Orders[i][4] = OrderOpenPrice() / MarketInfo(OrderSymb, MODE_POINT);
    Orders[i][5] = OrderSwap() * 100;
  }
  if (OrdersCount > 0)
  {
    ArraySort(Orders);
    // ����Hashֵ
    for (Hash = 0, i = 0; i < OrdersCount; i++)
      for (j = 0; j < 6; j++)
      {
        str = IntToStr(Orders[i][j]);
        for (k = 0; k < 4; k++)
          Hash += (Hash << 5) + StringGetChar(str, k);
      }
  }
  
  return(Hash);
}

// ===== �ѻ��Ҷ�ת�������� =====
int SymbolToInt(string Symb)
{
  int i, r;
  
  for (r = 0, i = 0; i < StringLen(Symb); i++)
    r += r << 5 + StringGetChar(Symb, i);
  return(r);
}

// ===== ������ת�����ַ��� =====
string IntToStr(int num)
{
  string r = "    ";
  int i, b;
  
  for (i = 3; i >= 0; i--)
  {
    b = num & 0xFF;
    if (b == 0)
      b = 95;
    StringSetChar(r, i, b);
    num = num >> 8;
  }
  return(r);
}