(********************************************************************)
(* Tomes of Delphi: Algorithms and Data Structures                  *)
(* Source code copyright (c) Julian M Bucknall, 1999-2001           *)
(* All rights reserved                                              *)
(*------------------------------------------------------------------*)
unit tdHashlinear;

interface
uses
  SysUtils;

type
  TtdHashTableLinear = class
  private
    m_nCapacity: Cardinal;
    m_nCount: Integer;
    m_pData: PChar;
    function IndexOf(const key: string; var pSlot: Pointer): Integer; overload;
    function IndexOf(const key: Cardinal; var pSlot: Pointer): Integer; overload;
    procedure deleteByIndex(const nIndex: Integer);
  public
    constructor Create(tableCount: Cardinal);
    destructor Destroy(); override;
    function Insert(const key: string;  pValue: Pointer): Boolean; overload;
    function Insert(const key: Cardinal; pValue: Pointer): Boolean; overload;
    function Insert(const key: string; pObj: TObject): Boolean; overload;
    function Insert(const key: Cardinal; pObj: TObject): Boolean; overload;
    function Insert(pValue: Pointer): Boolean; overload;
    function Insert(pObj: TObject): Boolean; overload;
    function removePointer(const key: string): Pointer; overload;
    function removePointer(const key: Cardinal): Pointer; overload;
    function removePointer(const p: Pointer): Pointer; overload;
    function removeObject(const key: string): TObject; overload;
    function removeObject(const key: Cardinal): TObject; overload;
    function removeObject(const p: TObject): TObject; overload;
    procedure removeAll();
    function Find(const key: string; var pValue: Pointer): Integer; overload;
    function Find(const key: string; var pObj: TObject): Integer; overload;
    function Find(const key: Integer; var pObj: TObject): Integer; overload;
    function Find(const key: Integer; var pValue: Pointer): Integer; overload;
    function Find(const key: Pointer): Integer; overload;
    function Find(const key: TObject): Integer; overload;
    function Count(): Cardinal;
    function Capacity(): Cardinal;
  end;

implementation
uses
  tdHashBase;

{ TtdHashTableLinear }

const MAX_KEY_LEN = 256;

type
  PHashSlot = ^THashSlot;
  THashSlot = packed record
    key: array [0..MAX_KEY_LEN-1] of Char;
    pValue: Pointer;
    pObj: TObject;
    bUsed: Boolean;
  end;

const HashSlotSize = SizeOf(THashSlot);

procedure zeroHashSlot(pSlot: PHashSlot);
begin
  pSlot^.key[0] := #0;
  pSlot^.pValue := nil;
  pSlot^.pObj := nil;
  pSlot^.bUsed := False;
end;  

function TtdHashTableLinear.Count: Cardinal;
begin
  Result := m_nCount;
end;

constructor TtdHashTableLinear.Create(tableCount: Cardinal);
begin
  inherited Create();
  m_nCapacity := getClosestPrime(tableCount);
  m_pData := AllocMem(HashSlotSize*m_nCapacity);
end;

destructor TtdHashTableLinear.Destroy;
begin
  FreeMem(m_pData);
  inherited;
end;

function TtdHashTableLinear.Find(const key: string;
  var pValue: Pointer): Integer;
var
  pSlot: Pointer;
  bFind: Boolean;
begin
  Result := IndexOf(key, pSlot);
  bFind := Result <> -1;
  if bFind then
  begin
    if pSlot <> nil then
      pValue := PHashSlot(pSlot)^.pValue
    else
      pValue := nil;
  end else
  begin
    pValue := nil;
  end;
end;

function TtdHashTableLinear.Find(const key: Integer;
  var pObj: TObject): Integer;
var
  pSlot: Pointer;
  bFind: Boolean;
begin
  Result := IndexOf(key, pSlot);
  bFind := Result <> -1;
  if bFind then
  begin
    if pSlot <> nil then
      pObj := PHashSlot(pSlot)^.pObj
    else
      pObj := nil;
  end else
  begin
    pObj := nil;
  end;
end;

function TtdHashTableLinear.Find(const key: Integer;
  var pValue: Pointer): Integer;
var
  pSlot: Pointer;
  bFind: Boolean;
begin
  Result := IndexOf(key, pSlot);
  bFind := Result <> -1;
  if bFind then
  begin
    if pSlot <> nil then
      pValue := PHashSlot(pSlot)^.pValue
    else
      pValue := nil;
  end else
  begin
    pValue := nil;
  end;
end;

function TtdHashTableLinear.Find(const key: string;
  var pObj: TObject): Integer;
var
  pSlot: Pointer;
  bFind: Boolean;
begin
  Result := IndexOf(key, pSlot);
  bFind := Result <> -1;
  if bFind then
  begin
    if pSlot <> nil then
      pObj := PHashSlot(pSlot)^.pObj
    else
      pObj := nil;
  end else
  begin
    pObj := nil;
  end;
end;

function TtdHashTableLinear.Insert(const key: Cardinal;
  pObj: TObject): Boolean;
var
  pSlot: Pointer;
begin
  //已经存在
  if IndexOf(key, pSlot) <> -1 then
  begin
    Result := False;
    Exit;
  end;
  //已经满了
  if pSlot = nil then
  begin
    Result := False;
    Exit;
  end;  

  PHashSlot(pSlot)^.key[0] := #0;
  pHashSlot(pSlot)^.pValue := nil;
  pHashSlot(pSlot)^.pObj := pObj;
  pHashSlot(pSlot)^.bUsed := True;

  Inc(m_nCount);
  Result := True;
end;

function TtdHashTableLinear.Insert(const key: Cardinal;
  pValue: Pointer): Boolean;
var
  pSlot: Pointer;
begin
  //已经存在
  if IndexOf(key, pSlot) <> -1 then
  begin
    Result := False;
    Exit;
  end;
  //已经满了
  if pSlot = nil then
  begin
    Result := False;
    Exit;
  end;

  PHashSlot(pSlot)^.key[0] := #0;
  pHashSlot(pSlot)^.pValue := pValue;
  pHashSlot(pSlot)^.pObj := nil;
  pHashSlot(pSlot)^.bUsed := True;

  Inc(m_nCount);
  Result := True;
end;

function TtdHashTableLinear.Insert(const key: string;
  pValue: Pointer): Boolean;
var
  pSlot: Pointer;
begin
  //已经存在
  if IndexOf(key, pSlot) <> -1 then
  begin
    Result := False;
    Exit;
  end;
  //已经满了
  if pSlot = nil then
  begin
    Result := False;
    Exit;
  end;

  PHashSlot(pSlot)^.key[MAX_KEY_LEN-1] := #0;
  StrPLCopy(@PHashSlot(pSlot)^.key[0], key, MAX_KEY_LEN-1);
  pHashSlot(pSlot)^.pValue := pValue;
  pHashSlot(pSlot)^.pObj := nil;
  pHashSlot(pSlot)^.bUsed := True;

  Inc(m_nCount);
  Result := True;
end;

function TtdHashTableLinear.Insert(const key: string;
  pObj: TObject): Boolean;
var
  pSlot: Pointer;
begin
  //已经存在
  if IndexOf(key, pSlot) <> -1 then
  begin
    Result := False;
    Exit;
  end;
  //已经满了
  if pSlot = nil then
  begin
    Result := False;
    Exit;
  end;

  PHashSlot(pSlot)^.key[MAX_KEY_LEN-1] := #0;
  StrPLCopy(@PHashSlot(pSlot)^.key[0], key, MAX_KEY_LEN-1);
  pHashSlot(pSlot)^.pValue := nil;
  pHashSlot(pSlot)^.pObj := pObj;
  pHashSlot(pSlot)^.bUsed := True;

  Inc(m_nCount);
  Result := True;
end;

function TtdHashTableLinear.Insert(pObj: TObject): Boolean;
begin
  Result := Insert(Cardinal(pObj), pObj);
end;

function TtdHashTableLinear.Insert(pValue: Pointer): Boolean;
begin
  Result := Insert(Cardinal(pValue), pValue);
end;

function TtdHashTableLinear.IndexOf(const key: string;
  var pSlot: Pointer): Integer;
var
  nIndex, nFirstIndex: Cardinal;
  pCurrentSlot: PHashSlot;
  strKey: string;
begin
  nIndex := PJWHash(key, m_nCapacity);
  nFirstIndex := nIndex;

  while True do
  begin
    pCurrentSlot := PHashSlot(@m_pData[nIndex*HashSlotSize]);
    if not pCurrentSlot^.bUsed then
    begin
      pSlot := pCurrentSlot;
      Result := -1;
      Exit;
    end else
    begin
      strKey := StrPas(@pCurrentSlot^.key[0]);
      if CompareStr(strKey, key) = 0 then
      begin
        pSlot := pCurrentSlot;
        Result := nIndex;
        Exit;
      end;  
    end;

    Inc(nIndex);
    if nIndex = m_nCapacity then
      nIndex := 0;
    if nIndex = nFirstIndex then
    begin
      pSlot := nil;
      Result := -1;
      Exit;
    end;
  end;
end;

function TtdHashTableLinear.IndexOf(const key: Cardinal;
  var pSlot: Pointer): Integer;
var
  nIndex: Integer;
  pCurrentSlot: PHashSlot;
begin
  nIndex := key mod m_nCapacity;
  pCurrentSlot := PHashSlot(@m_pData[nIndex*HashSlotSize]);
  if pCurrentSlot^.bUsed then
  begin
    Result := -1;
    pSlot := nil;
  end else
  begin
    Result := nIndex;
    pSlot := pCurrentSlot;
  end;    
end;

function TtdHashTableLinear.Capacity: Cardinal;
begin
  Result := m_nCapacity;
end;

function TtdHashTableLinear.removeObject(const key: string): TObject;
var
  pRet: TObject;
  nIndex: Integer;
begin
  nIndex := Find(key, pRet);
  if nIndex <> -1  then
  begin
    Result := pRet;
    deleteByIndex(nIndex);
  end else
  begin
    Result := nil;
  end;
end;

function TtdHashTableLinear.removeObject(const key: Cardinal): TObject;
var
  pRet: TObject;
  nIndex: Integer;
begin
  nIndex := Find(key, pRet);
  if nIndex <> -1  then
  begin
    Result := pRet;
    deleteByIndex(nIndex);
  end else
  begin
    Result := nil;
  end;
end;

function TtdHashTableLinear.removeObject(const p: TObject): TObject;
var
  pRet: TObject;
  nIndex: Integer;
begin
  nIndex := Find(Cardinal(p), pRet);
  if nIndex <> -1  then
  begin
    Result := pRet;
    deleteByIndex(nIndex);
  end else
  begin
    Result := nil;
  end;
end;

function TtdHashTableLinear.removePointer(const key: string): Pointer;
var
  pRet: Pointer;
  nIndex: Integer;
begin
  nIndex := Find(key, pRet);
  if nIndex <> -1  then
  begin
    Result := pRet;
    deleteByIndex(nIndex);
  end else
  begin
    Result := nil;
  end;
end;

function TtdHashTableLinear.removePointer(const key: Cardinal): Pointer;
var
  pRet: Pointer;
  nIndex: Integer;
begin
  nIndex := Find(key, pRet);
  if nIndex <> -1  then
  begin
    Result := pRet;
    deleteByIndex(nIndex);
  end else
  begin
    Result := nil;
  end;
end;

function TtdHashTableLinear.removePointer(const p: Pointer): Pointer;
var
  pRet: TObject;
  nIndex: Integer;
begin
  nIndex := Find(Cardinal(p), pRet);
  if nIndex <> -1  then
  begin
    Result := pRet;
    deleteByIndex(nIndex);
  end else
  begin
    Result := nil;
  end;
end;

procedure TtdHashTableLinear.deleteByIndex(const nIndex: Integer);
var
  pCurrentSlot: PHashSlot;
begin
  pCurrentSlot := PHashSlot(@m_pData[nIndex*HashSlotSize]);
  Dec(m_nCount);
  zeroHashSlot(pCurrentSlot);
end;

function TtdHashTableLinear.Find(const key: Pointer): Integer;
var
  pValue: Pointer;
begin
  Result := Find(Cardinal(key), pValue);
end;

function TtdHashTableLinear.Find(const key: TObject): Integer;
var
  pValue: TObject;
begin
  Result := Find(Cardinal(key), pValue);
end;

procedure TtdHashTableLinear.removeAll;
begin
  FillChar(m_pData^, m_nCapacity, 0);
end;

end.
