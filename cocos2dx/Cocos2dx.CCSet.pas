(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************)

unit Cocos2dx.CCSet;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.cCCArray;

type
  CCSet = class(CCObject)
  private
    data: PCCObectAry;
    m_nNum: Cardinal;
    m_nCapacity: Cardinal;
    procedure releaseObject();
    procedure ensureExtraCapacity();
  public
    constructor Create(); overload;
    constructor Create(const rSetObject: CCSet); overload;
    destructor Destroy(); override;
    class function _create(): CCSet;
    function Copy(): CCSet;
    function mutableCopy(): CCSet;
    function count(): Integer;
    procedure addObject(pObject: CCObject);
    procedure removeObject(pObject: CCObject);
    procedure removeAllObjects();
    function ContainsObject(pObject: CCObject): Boolean;
    function anyObject(): CCObject;
    function getObject(const nIdx: Cardinal): CCObject;
  end;

implementation
uses
  SysUtils;

{ CCSet }

procedure CCSet.addObject(pObject: CCObject);
begin
  ensureExtraCapacity();
  pObject.retain();
  data[m_nNum] := pObject;
  Inc(m_nNum);
end;

function CCSet.anyObject: CCObject;
var
  i: Integer;
  pObj: CCObject;
begin
  if m_nNum < 1 then
  begin
    Result := nil;
    Exit;
  end;

  pObj := nil;
  for i := 0 to m_nNum-1 do
  begin
    pObj := data[i];
    if pObj <> nil then
      Break;
  end;
  
  Result := pObj;
end;

function CCSet.ContainsObject(pObject: CCObject): Boolean;
var
  i: Integer;
  pObj: CCObject;
begin
  if m_nNum < 1 then
  begin
    Result := False;
    Exit;
  end;

  for i := 0 to m_nNum-1 do
  begin
    pObj := data[i];
    if (pObject = pObj) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function CCSet.Copy: CCSet;
begin
  Result := CCSet.Create(Self);
end;

function CCSet.count: Integer;
begin
  Result := m_nNum;
end;

constructor CCSet.Create(const rSetObject: CCSet);
var
  i: Integer;
begin
  inherited Create();

  m_nNum := rSetObject.m_nNum;
  m_nCapacity := rSetObject.m_nCapacity;
  data := AllocMem(SizeOf(CCObject) * m_nCapacity);

  if m_nNum > 0 then
    for i := 0 to m_nNum-1 do
    begin
      data[i] := rSetObject.data[i];
      data[i].retain();
    end;
end;

constructor CCSet.Create;
begin
  inherited Create();

  m_nNum := 0;
  m_nCapacity := 5;
  data := AllocMem(SizeOf(CCObject) * m_nCapacity);
end;

destructor CCSet.Destroy;
begin
  releaseObject();
  FreeMem(data);
  inherited;
end;

procedure CCSet.ensureExtraCapacity;
var
  copyData: PCCObectAry;
  i: Integer;
begin
  if m_nNum < m_nCapacity then
    Exit;

  m_nCapacity := m_nCapacity * 2;
  copyData := AllocMem(SizeOf(CCObject) * m_nCapacity);
  for i := 0 to m_nNum-1 do
  begin
    copyData[i] := data[i];
  end;

  FreeMem(data);
  data := copyData;
end;

function CCSet.getObject(const nIdx: Cardinal): CCObject;
begin
  if (m_nNum < 1) or (nIdx >= m_nNum) then
  begin
    Result := nil;
    Exit;
  end;

  Result := data[nIdx];
end;

function CCSet.mutableCopy: CCSet;
begin
  Result := Copy();
end;

procedure CCSet.releaseObject;
var
  i: Integer;
  pObj: CCObject;
begin
  if m_nNum > 0 then
    for i := 0 to m_nNum-1 do
    begin
      pObj := data[i];
      if pObj <> nil then
        pObj.release();
    end;
end;

procedure CCSet.removeAllObjects;
begin
  releaseObject();
  m_nNum := 0;
end;

procedure CCSet.removeObject(pObject: CCObject);
var
  i: Integer;
  nIdx: Cardinal;
  pObj: CCObject;
  bFind: Boolean;
begin
  if m_nNum < 1 then
    Exit;

  nIdx := 0;
  bFind := False;
  for i := 0 to m_nNum-1 do
  begin
    pObj := data[i];
    if (pObject = pObj) then
    begin
      bFind := True;
      nIdx := i;
      Break;
    end;
  end;

  if bFind then
  begin
    data[nIdx].release();
    if nIdx <> (m_nNum-1) then
    begin
      Move(data[nIdx+1], data[nIdx], SizeOf(CCObject) * (m_nNum - nIdx - 1));
    end;
    data[m_nNum-1] := nil;
    Dec(m_nNum);
  end;
end;

class function CCSet._create: CCSet;
var
  pRet: CCSet;
begin
  pRet := CCSet.Create();
  if pRet <> nil then
    pRet.autorelease();
  Result := pRet;
end;

end.
