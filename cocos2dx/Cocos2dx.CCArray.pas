(****************************************************************************
Copyright (c) 2010 ForzeField Studios S.L. http://forzefield.com
Copyright (c) 2010 cocos2d-x.org

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

unit Cocos2dx.CCArray;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.cCCArray;

type
  CCArray = class(CCObject)
  public
    data: p_ccArray;
  public
    constructor Create(); overload;
    constructor Create(capacity: Cardinal); overload;
    destructor Destroy(); override;
    class function _Create(): CCArray; overload;
    class function _Create(pObjects: array of CCObject): CCArray; overload;
    class function createWithObject(pObject: CCObject): CCArray;
    class function createWithCapacity(capacity: Cardinal): CCArray;
    class function createWithArray(otherArray: CCArray): CCArray;
    class function createWithContentsOfFile(const pFilename: string): CCArray;
    class function createWithContentsOfFileThreadSafe(const pFilename: string): CCArray;
    function init(): Boolean;
    function initWithObject(pObject: CCObject): Boolean;
    function initWithObjects(pObjects: array of CCObject): Boolean;
    function initWithCapacity(capacity: Cardinal): Boolean;
    function initWithArray(otherArray: CCArray): Boolean;
    function count(): Cardinal;
    function capacity(): Cardinal;
    function indexOfObject(pObject: CCObject): Cardinal;
    function objectAtIndex(nindex: Cardinal): CCObject;
    function lastObject(): CCObject;
    function randomObject(): CCObject;
    function containsObject(pObject: CCObject): Boolean;
    function isEqualToArray(pOtherArray: CCArray): Boolean;
    procedure addObject(pObject: CCObject);
    procedure addObjectsFromArray(otherArray: CCArray);
    procedure insertObject(pObject: CCObject; nindex: Cardinal);
    procedure removeLastObject(bReleaseObj: Boolean = True);
    procedure removeObject(pObject: CCObject; bReleaseObj: Boolean = True);
    procedure removeObjectAtIndex(nindex: Cardinal; bReleaseObj: Boolean = True);
    procedure removeObjectsInArray(otherArray: CCArray);
    procedure removeAllObjects();
    procedure fastRemoveObject(pObject: CCObject);
    procedure fastRemoveObjectAtIndex(nindex: Cardinal);
    procedure exchangeObject(object1, object2: CCObject);
    procedure exchangeObjectAtIndex(index1, index2: Cardinal);
    procedure replaceObjectAtIndex(uIndex: Cardinal; pObject: CCObject; bReleaseObj: Boolean = True);
    procedure reverseObjects();
    procedure reduceMemoryFootprint();
    function copyWithZone(pZone: CCZone): CCObject; override;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCArray }

class function CCArray._Create: CCArray;
var
  pArray: CCArray;
begin
  pArray := CCArray.Create();
  if (pArray <> nil) and pArray.init() then
    pArray.autorelease()
  else
    CC_SAFE_DELETE(pArray);

  Result := pArray;
end;

class function CCArray._Create(pObjects: array of CCObject): CCArray;
var
  pArray: CCArray;
  i: Integer;
begin
  pArray := CCArray.Create();
  if (pArray <> nil) then
  begin
    for i := Low(pObjects) to High(pObjects) do
      pArray.addObject(pObjects[i]);
    pArray.autorelease();
  end
  else
    CC_SAFE_DELETE(pArray);

  Result := pArray;
end;

procedure CCArray.addObject(pObject: CCObject);
begin
  ccArrayAppendObjectWithResize(data, pObject);
end;

procedure CCArray.addObjectsFromArray(otherArray: CCArray);
begin
  ccArrayAppendArrayWithResize(data, otherArray.data);
end;

function CCArray.capacity: Cardinal;
begin
  Result := data^.max;
end;

function CCArray.containsObject(pObject: CCObject): Boolean;
begin
  Result := ccArrayContainsObject(data, pObject);
end;

function CCArray.copyWithZone(pZone: CCZone): CCObject;
var
  pObj, pTmpObj: CCObject;
  pArray: CCArray;
  i: Integer;
begin
  pArray := CCArray.Create();
  if Self.data^.num > 0 then
    pArray.initWithCapacity(Self.data^.num)
  else
    pArray.initWithCapacity(1);

  for i := 0 to data^.num-1 do
  begin
    pObj := data^.arr[i];
    pTmpObj := pObj.copy();
    pArray.addObject(pTmpObj);
    pTmpObj.release();
  end;

  Result := pArray;
end;

function CCArray.count: Cardinal;
begin
  Result := data^.num;
end;

constructor CCArray.Create(capacity: Cardinal);
begin
  inherited Create();
  data := nil;
  initWithCapacity(capacity);
end;

constructor CCArray.Create;
begin
  inherited Create();
  data := nil;
  init();
end;

class function CCArray.createWithArray(otherArray: CCArray): CCArray;
var
  pRet: CCArray;
begin
  pRet := CCArray(otherArray.copy());
  pRet.autorelease();
  Result := pRet;
end;

class function CCArray.createWithCapacity(capacity: Cardinal): CCArray;
var
  pArray: CCArray;
begin
  pArray := cCArray.Create();
  if (pArray <> nil) and pArray.initWithCapacity(capacity) then
    pArray.autorelease()
  else
    CC_SAFE_DELETE(pArray);

  Result := pArray;
end;

class function CCArray.createWithContentsOfFile(
  const pFilename: string): CCArray;
var
  pRet: CCArray;
begin
  pRet := cCArray.createWithContentsOfFile(pFilename);
  if pRet <> nil then
    pRet.autorelease();
  Result := pRet;
end;

class function CCArray.createWithContentsOfFileThreadSafe(
  const pFilename: string): CCArray;
begin
  Result := nil;
end;

class function CCArray.createWithObject(pObject: CCObject): CCArray;
var
  pArray: CCArray;
begin
  pArray := CCArray.Create();
  if (pArray <> nil) and pArray.initWithObject(pObject) then
    pArray.autorelease()
  else
    CC_SAFE_DELETE(pArray);

  Result := pArray;
end;

destructor CCArray.Destroy;
begin
  ccArrayFree(data);
  inherited;
end;

procedure CCArray.exchangeObject(object1, object2: CCObject);
var
  index1, index2: Cardinal;
begin
  index1 := ccArrayGetIndexOfObject(data, object1);
  if index1 = CC_INVALID_INDEX then
    Exit;

  index2 := ccArrayGetIndexOfObject(data, object2);
  if index2 = CC_INVALID_INDEX then
    Exit;

  ccArraySwapObjectsAtIndexes(data, index1, index2);
end;

procedure CCArray.exchangeObjectAtIndex(index1, index2: Cardinal);
begin
  ccArraySwapObjectsAtIndexes(data, index1, index2);
end;

procedure CCArray.fastRemoveObject(pObject: CCObject);
begin
  ccArrayFastRemoveObject(data, pObject);
end;

procedure CCArray.fastRemoveObjectAtIndex(nindex: Cardinal);
begin
  ccArrayFastRemoveObjectAtIndex(data, nindex);
end;

function CCArray.indexOfObject(pObject: CCObject): Cardinal;
begin
  Result := ccArrayGetIndexOfObject(data, pObject);
end;

function CCArray.init: Boolean;
begin
  Result := initWithCapacity(1);
end;

function CCArray.initWithArray(otherArray: CCArray): Boolean;
var
  bRet: Boolean;
begin
  ccArrayFree(data);
  bRet := False;
  if initWithCapacity(otherArray.data^.num) then
  begin
    addObjectsFromArray(otherArray);
    bRet := True;
  end;
  Result := bRet;
end;

function CCArray.initWithCapacity(capacity: Cardinal): Boolean;
begin
  ccArrayFree(data);
  data := ccArrayNew(capacity);
  Result := True;
end;

function CCArray.initWithObject(pObject: CCObject): Boolean;
var
  bRet: Boolean;
begin
  ccArrayFree(data);
  bRet := False;
  if bRet then
    addObject(pObject);
  Result := bRet;
end;

function CCArray.initWithObjects(pObjects: array of CCObject): Boolean;
var
  bRet: Boolean;
  pArray: CCArray;
  i: Integer;
begin
  ccArrayFree(data);
  bRet := False;

  pArray := CCArray.Create();
  if pArray <> nil then
  begin
    for i := Low(pObjects) to High(pObjects) do
      pArray.addObject(pObjects[i]);
    bRet := True;
  end else
  begin
    CC_SAFE_DELETE(pArray);
  end;

  Result := bRet;
end;

procedure CCArray.insertObject(pObject: CCObject; nindex: Cardinal);
begin
  ccArrayInsertObjectAtIndex(data, pObject, nindex);
end;

function CCArray.isEqualToArray(pOtherArray: CCArray): Boolean;
var
  i: Cardinal;
begin
  for i := 0 to Self.count()-1 do
  begin
    if Self.objectAtIndex(i).isEqual(pOtherArray.objectAtIndex(i)) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

function CCArray.lastObject: CCObject;
begin
  if data^.num > 0 then
  begin
    Result := data^.arr[data^.num-1];
    Exit;
  end;
  Result := nil;
end;

function CCArray.objectAtIndex(nindex: Cardinal): CCObject;
begin
  Result := data^.arr[nIndex];
end;

function CCArray.randomObject: CCObject;
var
  r: Double;
begin
  if data^.num = 0 then
  begin
    Result := nil;
    Exit;
  end;
  Randomize();
  r := Random;
  if r = 1 then
  begin
    r := 0;
  end;
  Result := data^.arr[Round(data^.num*r)];
end;

procedure CCArray.reduceMemoryFootprint;
begin
  ccArrayShrink(data);
end;

procedure CCArray.removeAllObjects;
begin
  ccArrayRemoveAllObjects(data);
end;

procedure CCArray.removeLastObject(bReleaseObj: Boolean);
begin
  ccArrayRemoveObjectAtIndex(data, data^.num-1, bReleaseObj);
end;

procedure CCArray.removeObject(pObject: CCObject; bReleaseObj: Boolean);
begin
  ccArrayRemoveObject(data, pObject, bReleaseObj);
end;

procedure CCArray.removeObjectAtIndex(nindex: Cardinal;
  bReleaseObj: Boolean);
begin
  ccArrayRemoveObjectAtIndex(data, nindex, bReleaseObj);
end;

procedure CCArray.removeObjectsInArray(otherArray: CCArray);
begin
  ccArrayRemoveArray(data, otherArray.data);
end;

procedure CCArray.replaceObjectAtIndex(uIndex: Cardinal; pObject: CCObject;
  bReleaseObj: Boolean);
begin
  ccArrayInsertObjectAtIndex(data, pObject, uIndex);
  ccArrayRemoveObjectAtIndex(data, uIndex+1);
end;

procedure CCArray.reverseObjects;
var
  count, i: Integer;
  maxIndex: Cardinal;
begin
  if data^.num > 1 then
  begin
    count := Round(data^.num/2.0);
    maxIndex := data^.num-1;
    for i := 0 to count-1 do
    begin
      ccArraySwapObjectsAtIndexes(data, i, maxIndex);
      Dec(maxIndex);
    end;  
  end;  
end;

end.
