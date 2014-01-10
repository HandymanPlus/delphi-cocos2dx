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

unit Cocos2dx.CCKeypadDispatcher;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCArray, Cocos2dx.CCKeypadDelegate, Cocos2dx.cCCArray;

type
  ccKeypadMSGType =
  (
    kTypeBackClicked = 1,
    kTypeMenuClicked
  );

  CCKeypadDispatcher = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure addDelegate(pDelegate: CCKeypadDelegate);
    procedure removeDelegate(pDelegate: CCKeypadDelegate);
    procedure forceAddDelegate(pDelegate: CCKeypadDelegate);
    procedure forceRemoveDelegate(pDelegate: CCKeypadDelegate);
    function dispatchKeypadMSG(nMsgType: ccKeypadMSGType): Boolean;
  protected
    m_pDelegates: CCArray;
    m_bLocked: Boolean;
    m_bToAdd: Boolean;
    m_bToRemove: Boolean;
    m_pHandlersToAdd: p_ccCArray;
    m_pHandlersToRemove: p_ccCArray;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCKeypadDispatcher }

procedure CCKeypadDispatcher.addDelegate(pDelegate: CCKeypadDelegate);
begin
  if pDelegate = nil then
    Exit;

  if not m_bLocked then
  begin
    forceAddDelegate(pDelegate);
  end else
  begin
    ccCArrayAppendValue(m_pHandlersToAdd, Pointer(pDelegate));
    m_bToAdd := True;
  end;    
end;

constructor CCKeypadDispatcher.Create;
begin
  inherited Create();
  m_bLocked := False;
  m_bToAdd := False;
  m_bToRemove := False;

  m_pDelegates := CCArray._Create();
  m_pDelegates.retain();

  m_pHandlersToAdd := ccCArrayNew(8);
  m_pHandlersToRemove := ccCArrayNew(8);
end;

destructor CCKeypadDispatcher.Destroy;
begin
  CC_SAFE_RELEASE(m_pDelegates);
  if m_pHandlersToAdd <> nil then
    ccCArrayFree(m_pHandlersToAdd);
  if m_pHandlersToRemove <> nil then
    ccCArrayFree(m_pHandlersToRemove);
  inherited;
end;

function CCKeypadDispatcher.dispatchKeypadMSG(
  nMsgType: ccKeypadMSGType): Boolean;
var
  pHandler: CCKeypadHandler;
  pDelegate: CCKeypadDelegate;
  pObj: CCObject;
  i: Integer;
begin
  m_bLocked := True;
  if m_pDelegates.count() > 0 then
  begin
    for i := 0 to m_pDelegates.count()-1 do
    begin
      pObj := m_pDelegates.objectAtIndex(i);
      if pObj = nil then
        Break;

      pHandler := CCKeypadHandler(pObj);
      pDelegate := pHandler.getDelegate();

      case nMsgType of
        kTypeBackClicked: pDelegate.keyBackClicked();
        kTypeMenuClicked: pDelegate.keyMenuClicked();
      end;
    end;  
  end;

  m_bLocked := False;
  if m_bToRemove then
  begin
    m_bToRemove := False;
    if m_pHandlersToRemove^.num > 0 then
      for i := 0 to m_pHandlersToRemove^.num-1 do
        forceRemoveDelegate(CCKeypadDelegate(m_pHandlersToRemove.arr[i]));
    ccCArrayRemoveAllValues(m_pHandlersToRemove);
  end;

  if m_bToAdd then
  begin
    m_bToAdd := False;
    if m_pHandlersToAdd^.num > 0 then
      for i := 0 to m_pHandlersToAdd^.num-1 do
        forceRemoveDelegate(CCKeypadDelegate(m_pHandlersToAdd.arr[i]));
    ccCArrayRemoveAllValues(m_pHandlersToAdd);
  end;

  Result := True;
end;

procedure CCKeypadDispatcher.forceAddDelegate(pDelegate: CCKeypadDelegate);
var
  pHandler: CCKeypadHandler;
begin
  pHandler := CCKeypadHandler.handlerWithDelegate(pDelegate);
  if pHandler <> nil then
  begin
    m_pDelegates.addObject(pHandler);
  end;  
end;

procedure CCKeypadDispatcher.forceRemoveDelegate(
  pDelegate: CCKeypadDelegate);
var
  i: Integer;
  pHandler: CCKeypadHandler;
begin
  if (m_pDelegates <> nil) and (m_pDelegates.count() > 0) then
  begin
    for i := 0 to m_pDelegates.count()-1 do
    begin
      pHandler := CCKeypadHandler(m_pDelegates.objectAtIndex(i));
      if (pHandler <> nil) and (pHandler.getDelegate() = pDelegate) then
      begin
        m_pDelegates.removeObject(pHandler);
        Break;
      end;  
    end;
  end;
end;

procedure CCKeypadDispatcher.removeDelegate(pDelegate: CCKeypadDelegate);
begin
  if pDelegate = nil then
    Exit;

  if not m_bLocked then
  begin
    forceRemoveDelegate(pDelegate);
  end else
  begin
    ccCArrayAppendValue(m_pHandlersToRemove, Pointer(pDelegate));
    m_bToRemove := True;
  end;  
end;

end.
