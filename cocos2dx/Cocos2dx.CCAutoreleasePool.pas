(****************************************************************************
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

unit Cocos2dx.CCAutoreleasePool;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCArray;

type
  CCAutoreleasePool = class(CCObject)
  private
    m_pManagedObjectArray: CCArray;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure addObject(pObject: CCObject);
    procedure removeObject(pObject: CCObject);
    procedure clear();
  end;

  CCPoolManager = class
  private
    m_pReleasePoolStack: CCArray;
    m_pCurReleasePool: CCAutoreleasePool;
    function getCurReleasePool(): CCAutoreleasePool;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure finalize();
    procedure push();
    procedure pop();
    procedure removeObject(pObject: CCObject);
    procedure addObject(pObject: CCObject);
    class function sharedPoolManager(): CCPoolManager;
    class procedure purgePoolManager();
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

var s_pPoolManager: CCPoolManager = nil;

{ CCAutoreleasePool }

procedure CCAutoreleasePool.addObject(pObject: CCObject);
begin
  m_pManagedObjectArray.addObject(pObject);
  CCAssert(pObject.m_uReference > 1, 'reference count should be greater than 1');
  Inc(pObject.m_uAutoReleaseCount);
  pObject.release(); // no ref count, in this case autorelease pool added.
end;

procedure CCAutoreleasePool.clear;
var
  pObj: CCObject;
  i: Integer;
begin
  if m_pManagedObjectArray.count() > 0 then
  begin
    for i := 0 to m_pManagedObjectArray.count()-1 do
    begin
      pObj := m_pManagedObjectArray.objectAtIndex(i);
      if pObj = nil then
        Break;
      Dec(pObj.m_uAutoReleaseCount);
    end;
    m_pManagedObjectArray.removeAllObjects();
  end;  
end;

constructor CCAutoreleasePool.Create;
begin
  inherited Create();
  m_pManagedObjectArray := CCArray.Create();
  //m_pManagedObjectArray.init();
end;

destructor CCAutoreleasePool.Destroy;
begin
  CC_SAFE_DELETE(m_pManagedObjectArray);
  inherited;
end;

procedure CCAutoreleasePool.removeObject(pObject: CCObject);
var
  i: Cardinal;
begin
  if pObject.m_uAutoReleaseCount > 0 then
    for i := 0 to pObject.m_uAutoReleaseCount-1 do
      m_pManagedObjectArray.removeObject(pObject, False);
end;

{ CCPoolManager }

procedure CCPoolManager.addObject(pObject: CCObject);
begin
  getCurReleasePool().addObject(pObject);
end;

constructor CCPoolManager.Create;
begin
  inherited Create();
  m_pReleasePoolStack := CCArray.Create();
  //m_pReleasePoolStack.init();
  m_pCurReleasePool := nil;
end;

destructor CCPoolManager.Destroy;
begin
  finalize();

  // we only release the last autorelease pool here 
  m_pCurReleasePool := nil;
  m_pReleasePoolStack.removeObjectAtIndex(0);
  CC_SAFE_DELETE(m_pReleasePoolStack);
  inherited;
end;

procedure CCPoolManager.finalize;
var
  pPool: CCAutoreleasePool;
  i: Integer;
begin
  if m_pReleasePoolStack.count() > 0 then
  begin
    for i := 0 to m_pReleasePoolStack.count()-1 do
    begin
      pPool := CCAutoreleasePool(m_pReleasePoolStack.objectAtIndex(i));
      if pPool = nil then
        Break;
      pPool.clear();
    end;  
  end;  
end;

function CCPoolManager.getCurReleasePool: CCAutoreleasePool;
begin
  if m_pCurReleasePool = nil then
    push();

  CCAssert(m_pCurReleasePool <> nil, 'current auto release pool should not be null');
  Result := m_pCurReleasePool;
end;

procedure CCPoolManager.pop;
var
  nCount: Integer;
begin
  if m_pCurReleasePool = nil then
    Exit;

  nCount := m_pReleasePoolStack.count();
  m_pCurReleasePool.clear();
  if nCount > 1 then
  begin
    m_pReleasePoolStack.removeObjectAtIndex(nCount-1);
    m_pCurReleasePool := CCAutoreleasePool(m_pReleasePoolStack.objectAtIndex(nCount-2));
  end;  
end;

class procedure CCPoolManager.purgePoolManager;
begin
  s_pPoolManager.Free;
end;

procedure CCPoolManager.push;
var
  pPool: CCAutoreleasePool;
begin
  pPool := CCAutoreleasePool.Create();   //ref = 1
  m_pCurReleasePool := pPool;
  m_pReleasePoolStack.addObject(pPool);  //ref = 2

  pPool.release();                       //ref = 1
end;

procedure CCPoolManager.removeObject(pObject: CCObject);
begin
  CCAssert(m_pCurReleasePool <> nil, 'current auto release pool should not be null');
  m_pCurReleasePool.removeObject(pObject);
end;

class function CCPoolManager.sharedPoolManager: CCPoolManager;
begin
  if s_pPoolManager = nil then
    s_pPoolManager := CCPoolManager.Create();
  Result := s_pPoolManager;
end;

end.
