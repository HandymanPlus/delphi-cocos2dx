unit Cocos2dx.CCVector;

interface
uses
  SysUtils, Cocos2dx.CCPointerArray;

type
  TVectorInt = class
  private
    m_pIntArray: PIntegerArray;
    m_nCount: Integer;
    m_nCapacity: Integer;
    function getItem(nIdx: Integer): Integer;
  public
    constructor Create();
    destructor Destroy(); override;
    function count(): Cardinal;
    function size(): Cardinal;
    procedure push_back(const nValue: Integer);
    function pop(): Integer;
    property Items[nIdx: Integer]: Integer read getItem; default;
  end;

  TVectorFloat = class
  private
    m_pFloatArray: PFloatArray;
    m_nCount: Integer;
    m_nCapacity: Integer;
    function getItem(nIdx: Integer): Single;
  public
    constructor Create();
    destructor Destroy(); override;
    function count(): Cardinal;
    function size(): Cardinal;
    procedure push_back(const fValue: Single);
    function pop(): Single;
    procedure reserve(nCount: Cardinal);
    property Items[nIdx: Integer]: Single read getItem; default;
  end;

  TStringArray = array [0..MaxInt div SizeOf(string) - 1] of string;
  PStringArray = ^TStringArray;

  TVectorString = class
  private
    m_pStringArray: array of string;
    m_nCount: Integer;
    m_nCapacity: Integer;
    function getItem(nIdx: Integer): string;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure clear();
    function count(): Cardinal;
    function size(): Cardinal;
    procedure push_back(const sValue: string);
    function pop(): string;
    procedure reserve(nCount: Cardinal);
    function find(sValue: string): Boolean;
    procedure erase(sValue: string);
    property Items[nIdx: Integer]: string read getItem; default;
  end;

implementation

{ TVectorInt }

function TVectorInt.count: Cardinal;
begin
  Result := m_nCount;
end;

constructor TVectorInt.Create;
begin
  m_nCount := 0;
  m_nCapacity := 10;
  m_pIntArray := AllocMem(SizeOf(Integer)*m_nCapacity);
end;

destructor TVectorInt.Destroy;
begin
  FreeMem(m_pIntArray);
  inherited;
end;

function TVectorInt.getItem(nIdx: Integer): Integer;
begin
  Assert((nIdx >= 0) and (nIdx < m_nCount), '');
  
  Result := m_pIntArray^[nIdx];
end;

function TVectorInt.pop: Integer;
begin
  Assert(m_nCount > 0, '');

  Dec(m_nCount);
  Result := m_pIntArray^[m_nCount];
end;

procedure TVectorInt.push_back(const nValue: Integer);
var
  pIntArray: PIntegerArray;
  i: Integer;
begin
  if m_nCount < m_nCapacity then
  begin
    m_pIntArray^[m_nCount] := nValue;
    Inc(m_nCount);
  end else
  begin
    m_nCapacity := m_nCapacity * 2;

    pIntArray := AllocMem(SizeOf(Integer)*m_nCapacity);

    for i := 0 to m_nCount-1 do
    begin
      pIntArray^[i] := m_pIntArray^[i];
    end;

    FreeMem(m_pIntArray);

    m_pIntArray := pIntArray;

    m_pIntArray^[m_nCount] := nValue;
    Inc(m_nCount);
  end;
end;

function TVectorInt.size: Cardinal;
begin
  Result := m_nCount;
end;

{ TVectorFloat }

function TVectorFloat.count: Cardinal;
begin
  Result := m_nCount;
end;

constructor TVectorFloat.Create;
begin
  m_nCount := 0;
  m_nCapacity := 10;
  m_pFloatArray := AllocMem(SizeOf(Single)*m_nCapacity);
end;

destructor TVectorFloat.Destroy;
begin
  FreeMem(m_pFloatArray);
  inherited;
end;

function TVectorFloat.getItem(nIdx: Integer): Single;
begin
  Assert((nIdx >= 0) and (nIdx < m_nCount), '');

  Result := m_pFloatArray^[nIdx];
end;

function TVectorFloat.pop: Single;
begin
  Assert(m_nCount > 0, '');

  Dec(m_nCount);
  Result := m_pFloatArray^[m_nCount];
end;

procedure TVectorFloat.push_back(const fValue: Single);
var
  pFloatAry: PFloatArray;
  i: Integer;
begin
  if m_nCount < m_nCapacity then
  begin
    m_pFloatArray^[m_nCount] := fValue;
    Inc(m_nCount);
  end else
  begin
    m_nCapacity := m_nCapacity * 2;

    pFloatAry := AllocMem(SizeOf(Integer)*m_nCapacity);

    for i := 0 to m_nCount-1 do
    begin
      pFloatAry^[i] := m_pFloatArray^[i];
    end;

    FreeMem(m_pFloatArray);

    m_pFloatArray := pFloatAry;

    m_pFloatArray^[m_nCount] := fValue;
    Inc(m_nCount);
  end;
end;

procedure TVectorFloat.reserve(nCount: Cardinal);
var
  pAry: PFloatArray;
  i: Cardinal;
begin
  if (nCount < 1) or (m_nCount < 1) then
    Exit;
  if nCount > Cardinal(m_nCount) then
    nCount := m_nCount;

  pAry := AllocMem(SizeOf(Single) * nCount);

  for i := 0 to nCount-1 do
    pAry^[i] := m_pFloatArray^[nCount - 1 - i];

  for i := 0 to nCount-1 do
  begin
    m_pFloatArray[i] := pAry^[i];
  end;

  FreeMem(pAry);
end;

function TVectorFloat.size: Cardinal;
begin
  Result := m_nCount;
end;

{ TVectorString }

procedure TVectorString.clear;
var
  i: Integer;
begin
  if size > 0 then
  begin
    for i := 0 to size - 1 do
      m_pStringArray[i] := '';
    m_nCount := 0;
  end;
end;

function TVectorString.count: Cardinal;
begin
  Result := m_nCount;
end;

constructor TVectorString.Create;
var
  i: Integer;
begin
  m_nCount := 0;
  m_nCapacity := 10;
  SetLength(m_pStringArray, m_nCapacity);
  for i := 0 to m_nCapacity-1 do
    m_pStringArray[i] := '';
end;

destructor TVectorString.Destroy;
var
  i: Integer;
begin
  if size > 0 then
  begin
    for i := 0 to size - 1 do
      m_pStringArray[i] := '';
  end;  
  m_pStringArray := nil;
  inherited;
end;

procedure TVectorString.erase(sValue: string);
var
  i: Integer;
  nRet: Integer;
begin
  nRet := -1;

  for i := 0 to m_nCount-1 do
  begin
    if CompareText(m_pStringArray[i], sValue) = 0 then
    begin
      nRet := i;
      Break;
    end;  
  end;

  if nRet <> -1 then
  begin
    for i := nRet to m_nCount-2 do
    begin
      m_pStringArray[i] := m_pStringArray[i + 1];
    end;

    Dec(m_nCount);
  end;
end;

function TVectorString.find(sValue: string): Boolean;
var
  i: Integer;
  nRet: Integer;
begin
  nRet := -1;

  for i := 0 to m_nCount-1 do
  begin
    if CompareText(m_pStringArray[i], sValue) = 0 then
    begin
      nRet := i;
      Break;
    end;  
  end;

  Result := nRet <> -1;
end;

function TVectorString.getItem(nIdx: Integer): string;
begin
  Assert((nIdx >= 0) and (nIdx < m_nCount), '');

  Result := m_pStringArray[nIdx];
end;

function TVectorString.pop: string;
begin
  Assert(m_nCount > 0, '');

  Dec(m_nCount);
  Result := m_pStringArray[m_nCount];
end;

procedure TVectorString.push_back(const sValue: string);
begin
  if m_nCount < m_nCapacity then
  begin
    m_pStringArray[m_nCount] := sValue;
    Inc(m_nCount);
  end else
  begin
    m_nCapacity := m_nCapacity * 2;
    SetLength(m_pStringArray, m_nCapacity);
    m_pStringArray[m_nCount] := sValue;
    Inc(m_nCount);
  end;
end;

procedure TVectorString.reserve(nCount: Cardinal);
begin

end;

function TVectorString.size: Cardinal;
begin
  Result := m_nCount;
end;

end.
