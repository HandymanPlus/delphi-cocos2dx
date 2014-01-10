(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Valentin Milea

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

unit Cocos2dx.CCTouchHandler;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCTouchDelegateProtocol, Cocos2dx.CCSet;

type
  CCTouchHandler = class(CCObject)
  protected
    m_pDelegate: CCTouchDelegate;
    m_nPriority: Integer;
    m_nEnabledSelectors: Integer;
  public
    destructor Destroy(); override;
    function getDelegate(): CCTouchDelegate;
    procedure setDelegate(pDelegate: CCTouchDelegate);
    function getPriority(): Integer;
    procedure setPriority(nPriority: Integer);
    function getEnabledSelectors(): Integer;
    procedure setEnabledSelectors(nValue: Integer);
    function initWithDelegate(pDelegate: CCTouchDelegate; nPriority: Integer): Boolean; virtual;
  public
    class function handerWithDelegate(pDelegate: CCTouchDelegate; nPriority: Integer): CCTouchHandler;
  end;

  CCStandardTouchHandler = class(CCTouchHandler)
  public
    function initWithDelegate(pDelegate: CCTouchDelegate; nPriority: Integer): Boolean; override;
    class function handlerWithDelegate(pDelegate: CCTouchDelegate; nPriority: Integer): CCStandardTouchHandler;
  end;

  CCTargetedTouchHandler = class(CCTouchHandler)
  private
    m_bSwallowsTouches: Boolean;
    m_pClaimedTouches: CCSet;
  public
    destructor Destroy(); override;
    function isSwallowsTouches(): Boolean;
    procedure setSwallowsTouches(bSwallowsTouches: Boolean);
    function getClaimedTouches(): CCSet;
    function initWithDelegate(pDelegate: CCTouchDelegate; nPriority: Integer; bSwallow: Boolean): Boolean; reintroduce;
    class function handlerWithDelegate(pDelegate: CCTouchDelegate; nPriority: Integer; bSwallow: Boolean): CCTargetedTouchHandler;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCTouchHandler }

destructor CCTouchHandler.Destroy;
begin
  if m_pDelegate <> nil then
    m_pDelegate.release();
  inherited;
end;

function CCTouchHandler.getDelegate: CCTouchDelegate;
begin
  Result := m_pDelegate;
end;

function CCTouchHandler.getEnabledSelectors: Integer;
begin
  Result := m_nEnabledSelectors;
end;

function CCTouchHandler.getPriority: Integer;
begin
  Result := m_nPriority;
end;

class function CCTouchHandler.handerWithDelegate(
  pDelegate: CCTouchDelegate; nPriority: Integer): CCTouchHandler;
var
  pHandler: CCTouchHandler;
begin
  pHandler := CCTouchHandler.Create();
  if pHandler <> nil then
  begin
    if pHandler.initWithDelegate(pDelegate, nPriority) then
      pHandler.autorelease()
    else
      CC_SAFE_RELEASE_NULL(CCObject(pHandler));
  end;

  Result := pHandler;
end;

function CCTouchHandler.initWithDelegate(pDelegate: CCTouchDelegate;
  nPriority: Integer): Boolean;
begin
  CCAssert(pDelegate <> nil, 'touch delegate should not be null');
  m_pDelegate := pDelegate;

  pDelegate.retain();

  m_nPriority := nPriority;
  m_nEnabledSelectors := 0;

  Result := True;
end;

procedure CCTouchHandler.setDelegate(pDelegate: CCTouchDelegate);
begin
  if pDelegate <> nil then
  begin
    pDelegate.retain();
  end;

  if m_pDelegate <> nil then
  begin
    m_pDelegate.release();
  end;

  m_pDelegate := pDelegate;
end;

procedure CCTouchHandler.setEnabledSelectors(nValue: Integer);
begin
  m_nEnabledSelectors := nValue;
end;

procedure CCTouchHandler.setPriority(nPriority: Integer);
begin
  m_nPriority := nPriority;
end;

{ CCTargetedTouchHandler }

destructor CCTargetedTouchHandler.Destroy;
begin
  CC_SAFE_RELEASE(m_pClaimedTouches);
  inherited;
end;

function CCTargetedTouchHandler.getClaimedTouches: CCSet;
begin
  Result := m_pClaimedTouches;
end;

class function CCTargetedTouchHandler.handlerWithDelegate(
  pDelegate: CCTouchDelegate; nPriority: Integer;
  bSwallow: Boolean): CCTargetedTouchHandler;
var
  pHandler: CCTargetedTouchHandler;
begin
  pHandler := CCTargetedTouchHandler.Create();
  if pHandler <> nil then
  begin
    if pHandler.initWithDelegate(pDelegate, nPriority, bSwallow) then
      pHandler.autorelease()
    else
      CC_SAFE_RELEASE_NULL(CCObject(pHandler));
  end;

  Result := pHandler;
end;

function CCTargetedTouchHandler.initWithDelegate(
  pDelegate: CCTouchDelegate; nPriority: Integer;
  bSwallow: Boolean): Boolean;
begin
  if inherited initWithDelegate(pDelegate, nPriority) then
  begin
    m_pClaimedTouches := CCSet.Create();
    m_bSwallowsTouches := bSwallow;

    Result := True;
    Exit;
  end;
  
  Result := False;
end;

function CCTargetedTouchHandler.isSwallowsTouches: Boolean;
begin
  Result := m_bSwallowsTouches;
end;

procedure CCTargetedTouchHandler.setSwallowsTouches(
  bSwallowsTouches: Boolean);
begin
  m_bSwallowsTouches := bSwallowsTouches;
end;

{ CCStandardTouchHandler }

class function CCStandardTouchHandler.handlerWithDelegate(
  pDelegate: CCTouchDelegate; nPriority: Integer): CCStandardTouchHandler;
var
  pHandler: CCStandardTouchHandler;
begin
  pHandler := CCStandardTouchHandler.Create();
  if pHandler <> nil then
  begin
    if pHandler.initWithDelegate(pDelegate, nPriority) then
      pHandler.autorelease()
    else
      CC_SAFE_RELEASE_NULL(CCObject(pHandler));
  end;
  
  Result := pHandler;
end;

function CCStandardTouchHandler.initWithDelegate(
  pDelegate: CCTouchDelegate; nPriority: Integer): Boolean;
begin
  Result := inherited initWithDelegate(pDelegate, nPriority);
end;

end.
