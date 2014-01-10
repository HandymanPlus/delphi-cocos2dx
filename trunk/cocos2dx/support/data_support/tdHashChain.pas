unit tdHashChain;

interface
uses
  SysUtils, Classes;

//const MAX_KEY_LEN = 256;

type
  THashKeyType = (hkString, hkInteger);

  THashElement = class
  private
    pNext: THashElement;
    pPrev: THashElement;
  public
    hkType: THashKeyType;
    strKey: string;
    nKey: Cardinal;
    pValue: Pointer;
    pObj: TObject;
  public
    constructor Create(const strKey: string; pObj: TObject); overload;
    constructor Create(const nKey: Integer; pObj: TObject); overload;
    constructor Create(const strKey: string; pValue: Pointer); overload;
    constructor Create(const nKey: Integer; pValue: Pointer); overload;
  end;

  CCDictElement = THashElement;

  TVisitElement = procedure (HashElement: THashElement);

  TIterator = record
    x, y: Integer;
  end;

  THashElementArray = array [0..0] of THashElement;
  PHashElementArray = ^THashElementArray;
  
  TtdHashTableChain = class
  private
    m_nCapacity: Cardinal;
    m_nCount: Cardinal;
    m_pData: PHashElementArray;
    m_pFreeProc: TVisitElement;
    m_Iterator: TIterator;
  public
    constructor Create(const tableCount: Cardinal; freeProc: TVisitElement = nil);
    destructor Destroy(); override;
    function FindElementByString(const strKey: string): THashElement;
    function FindElementByInteger(const nKey: Cardinal): THashElement;
    function AddElement(const HashElement: THashElement): Boolean;
    function DelElement(const HashElement: THashElement): Boolean;
    function Count(): Cardinal;
    procedure RemoveAllElements();
    procedure Visit(VisitElement: TVisitElement);
    function First(): THashElement;
    function Next(): THashElement;
  end;

implementation
uses
  tdHashBase;

{ THashElement }

constructor THashElement.Create(const strKey: string; pObj: TObject);
begin
  Self.strKey := strKey;
  Self.pObj := pObj;
  hkType := hkString;
end;

constructor THashElement.Create(const nKey: Integer; pObj: TObject);
begin
  Self.nKey := nKey;
  Self.pObj := pObj;
  hkType := hkInteger;
end;

constructor THashElement.Create(const strKey: string; pValue: Pointer);
begin
  Self.strKey := strKey;
  Self.pValue := pValue;
  hkType := hkString;
end;

constructor THashElement.Create(const nKey: Integer; pValue: Pointer);
begin
  Self.nKey := nKey;
  Self.pValue := pValue;
  hkType := hkInteger;
end;

{ TtdHashTableChain }

function TtdHashTableChain.AddElement(
  const HashElement: THashElement): Boolean;
var
  nIndex: Integer;
  pHead, pCurrent: THashElement;
begin
  if HashElement.hkType = hkInteger then
    nIndex := HashElement.nKey mod m_nCapacity
  else
  begin
    nIndex := PJWHash(HashElement.strKey, m_nCapacity);
  end;

  pHead := m_pData[nIndex];
  if pHead = nil then
  begin
    m_pData[nIndex] := HashElement;
    Inc(m_nCount);
    Result := True;
    Exit;
  end;

  Result := False;
  pCurrent := pHead;
  while pCurrent <> nil do
  begin
    if pCurrent.hkType = HashElement.hkType then
    begin
      if HashElement.hkType = hkInteger then
      begin
        if pCurrent.nKey = HashElement.nKey then
          Exit;
      end else
      begin
        if CompareStr(pCurrent.strKey, HashElement.strKey) = 0 then
          Exit;
      end;  
    end;

    if pCurrent.pNext = nil then
    begin
      pCurrent.pNext := HashElement;
      HashElement.pPrev := pCurrent;
      Inc(m_nCount);
      Result := True;
      Exit;
    end;

    pCurrent := pCurrent.pNext; 
  end;
end;

function TtdHashTableChain.Count: Cardinal;
begin
  Result := m_nCount;
end;

constructor TtdHashTableChain.Create(const tableCount: Cardinal; freeProc: TVisitElement);
begin
  inherited Create();
  m_nCapacity := getClosestPrime(tableCount);
  m_pData := AllocMem(SizeOf(THashElement)*m_nCapacity);
  m_pFreeProc := freeProc;
end;

function TtdHashTableChain.DelElement(
  const HashElement: THashElement): Boolean;
var
  nIndex: Integer;
  pHead, pCurrent, pNext, pPrev: THashElement;
  bFind: Boolean;
begin
  if HashElement.hkType = hkInteger then
    nIndex := HashElement.nKey mod m_nCapacity
  else
  begin
    nIndex := PJWHash(HashElement.strKey, m_nCapacity);
  end;

  Result := False;

  pHead := m_pData[nIndex];
  if pHead = nil then
    Exit;

  bFind := False;
  pCurrent := pHead;
  while pCurrent <> nil do
  begin
    if pCurrent.hkType = HashElement.hkType then
    begin
      if HashElement.hkType = hkInteger then
      begin
        if pCurrent.nKey = HashElement.nKey then
          bFind := True;
      end else
      begin
        if CompareStr(pCurrent.strKey, HashElement.strKey) = 0 then
          bFind := True;
      end;

      if bFind then
      begin
        pPrev := pCurrent.pPrev;
        pNext := pCurrent.pNext;

        
        if pPrev = nil then
        begin
          if pNext = nil then
            m_pData[nIndex] := nil
          else
          begin
            m_pData[nIndex] := pNext;
            m_pData[nIndex].pPrev := nil;
          end;  
        end else
        begin
          pPrev.pNext := pNext;
          if pNext <> nil then
            pNext.pPrev := pPrev;
        end;    

        Dec(m_nCount);
        Result := True;
        Exit;
      end;  
    end;

    pCurrent := pCurrent.pNext; 
  end;
end;

destructor TtdHashTableChain.Destroy;
begin
  RemoveAllElements();
  FreeMem(m_pData);
  inherited;
end;

function TtdHashTableChain.FindElementByInteger(
  const nKey: Cardinal): THashElement;
var
  nIndex: Integer;
  pHead, pCurrent: THashElement;
begin
  nIndex := nKey mod m_nCapacity;

  Result := nil;
  pHead := m_pData[nIndex];
  if pHead = nil then
    Exit;

  pCurrent := pHead;
  while pCurrent <> nil do
  begin
    if pCurrent.hkType = hkInteger then
    begin
      if pCurrent.nKey = nKey then
      begin
        Result := pCurrent;
        Exit;
      end;
    end;

    pCurrent := pCurrent.pNext; 
  end;
end;

function TtdHashTableChain.FindElementByString(
  const strKey: string): THashElement;
var
  nIndex: Integer;
  pHead, pCurrent: THashElement;
begin
  nIndex := PJWHash(strKey, m_nCapacity);

  Result := nil;
  pHead := m_pData[nIndex];
  if pHead = nil then
    Exit;

  pCurrent := pHead;
  while pCurrent <> nil do
  begin
    if pCurrent.hkType = hkString then
    begin
      if CompareStr(pCurrent.strKey, strKey) = 0 then
      begin
        Result := pCurrent;
        Exit;
      end;
    end;

    pCurrent := pCurrent.pNext;
  end;
end;

function TtdHashTableChain.First: THashElement;
var
  i: Cardinal;
  pHead: THashElement;
begin
  m_Iterator.x := -1;
  m_Iterator.y := -1;

  Result := nil;

  i := 0;
  while i < m_nCapacity do
  begin

    pHead := m_pData[i];
    if pHead = nil then
    begin
      Inc(i);
      Continue;
    end;

    m_Iterator.x := i;
    m_Iterator.y := 0;

    Result := pHead;
    Exit;
  end;
end;

function TtdHashTableChain.Next: THashElement;
var
  i, j: Integer;
  pHead, pCurrent: THashElement;
begin
  Result := nil;

  i := m_Iterator.x;
  while Cardinal(i) < m_nCapacity do
  begin

    pHead := m_pData[i];
    if pHead = nil then
    begin
      Inc(i);
      Continue;
    end;

    if i > m_Iterator.x then
    begin
      m_Iterator.x := i;
      m_Iterator.y := 0;

      Result := pHead;
      Exit;
    end;  

    j := -1;
    pCurrent := pHead;
    while pCurrent <> nil do
    begin
      Inc(j);

      if j = m_Iterator.y then
      begin
        if pCurrent.pNext <> nil then
        begin
          Inc(m_Iterator.y);

          Result := pCurrent.pNext;

          Exit;
        end;
      end;
      
      pCurrent := pCurrent.pNext;
    end;

    Inc(i);
  end;
end;

procedure TtdHashTableChain.RemoveAllElements;
var
  i: Cardinal;
  pHead, pCurrent, pTemp: THashElement;
begin
  i := 0;
  while i < m_nCapacity do
  begin
    pHead := m_pData[i];
    if pHead = nil then
    begin
      Inc(i);
      Continue;
    end;

    pCurrent := pHead;
    while pCurrent <> nil do
    begin
      pTemp := pCurrent;
      pCurrent := pCurrent.pNext;

      if Assigned(m_pFreeProc) then
        m_pFreeProc(pTemp);
    end;
    Inc(i);
  end;
end;

procedure TtdHashTableChain.Visit(VisitElement: TVisitElement);
var
  i: Cardinal;
  pHead, pCurrent, pTemp: THashElement;
begin
  i := 0;
  while i < m_nCapacity do
  begin
    pHead := m_pData[i];
    if pHead = nil then
    begin
      Inc(i);
      Continue;
    end;

    pCurrent := pHead;
    while pCurrent <> nil do
    begin
      pTemp := pCurrent;
      pCurrent := pCurrent.pNext;

      if Assigned(VisitElement) then
        VisitElement(pTemp);
    end;
    Inc(i);
  end;
end;

end.
