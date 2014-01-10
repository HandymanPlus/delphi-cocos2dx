(****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2011 Zynga Inc.

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

unit Cocos2dx.CCActionInstant;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCAction, Cocos2dx.CCGeometry, Cocos2dx.CCTypeInfo;

type
  CCActionInstant = class(CCFiniteTimeAction)
  public
    constructor Create();
    destructor Destroy(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function isDone(): Boolean; override;
    function reverse(): CCFiniteTimeAction; override;
    procedure step(dt: Single); override;
  end;

  CCFlipX = class(CCActionInstant)
  public
    destructor Destroy(); override;
    class function _create(x: Boolean): CCFlipX;
    function initWithFlipX(x: Boolean): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
  protected
    m_bFlipX: Boolean;
  end;

  CCFlipY = class(CCActionInstant)
  public
    destructor Destroy(); override;
    class function _create(y: Boolean): CCFlipY;
    function initWithFlipY(y: Boolean): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
  protected
    m_bFlipY: Boolean;
  end;

  CCPlace = class(CCActionInstant)
  public
    class function _create(const pos: CCPoint): CCPlace;
    function initWithPosition(const pos: CCPoint): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
  protected
    m_tPosition: CCPoint;
  end;

  CCShow = class(CCActionInstant)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(): CCShow;
  end;

  CCHide = class(CCActionInstant)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(): CCHide;
  end;

  CCToggleVisibility = class(CCActionInstant)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(): CCToggleVisibility;
  end;

  CCCallFunc = class(CCActionInstant)
  public
    destructor Destroy(); override;
    class function _create(pSelectorTarget: CCObject; selector: SEL_CallFunc): CCCallFunc; overload;
    class function _create(nHandler: Integer): CCCallFunc; overload;
    procedure update(time: Single); override;
    function initWithTarget(pSelectorTarget: CCObject): Boolean;
    procedure execute(); virtual;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function getTargetCallback(): CCObject;
    procedure setTargetCallback(pSel: CCObject);
    function getScriptHandler(): Integer;
  protected
    m_pSelectorTarget: CCObject;
    m_nSciptHandler: Integer;

    m_pCallFunc: SEL_CallFunc;
  end;

  CCCallFuncN = class(CCCallFunc, TypeInfo)
  public
    function getClassTypeInfo(): Cardinal; dynamic;
    class function _create(pSelectorTarget: CCObject; selector: SEL_CallFuncN): CCCallFuncN;
    function initWithTarget(pSelectorTarget: CCObject; selector: SEL_CallFuncN): Boolean;
    procedure execute(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
  protected
    m_pCallFuncN: SEL_CallFuncN;
  end;

  CCCallFuncND = class(CCCallFuncN)
  public
    //function getClassTypeInfo(): Cardinal; override;
    class function _create(pSelectorTarget: CCObject; selector: SEL_CallFuncND; d: Pointer): CCCallFuncND;
    function initWithTarget(pSelectorTarget: CCObject; selector: SEL_CallFuncND; d: Pointer): Boolean;
    procedure execute(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
  protected
    m_pCallFuncND: SEL_CallFuncND;
    m_pData: Pointer;
  end;

  CCCallFuncO = class(CCCallFuncN)
  public
    destructor Destroy(); override;
    //function getClassTypeInfo(): Cardinal; override;
    class function _create(pSelectorTarget: CCObject; selector: SEL_CallFuncO; pObject: CCObject): CCCallFuncO;
    function initWithTarget(pSelectorTarget: CCObject; selector: SEL_CallFuncO; pObject: CCObject): Boolean;
    procedure execute(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function getObject(): CCObject;
    procedure setObject(pObj: CCObject);
  protected
    m_pCallFunco: SEL_CallFuncO;
    m_pObject: CCObject;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCSprite, Cocos2dx.CCNode;

{ CCActionInstant }

function CCActionInstant.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCActionInstant;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCActionInstant(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCActionInstant.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pNewZone.Free;

  Result := pRet;
end;

constructor CCActionInstant.Create;
begin
  inherited Create();
end;

destructor CCActionInstant.Destroy;
begin

  inherited;
end;

function CCActionInstant.isDone: Boolean;
begin
  Result := True;
end;

function CCActionInstant.reverse: CCFiniteTimeAction;
begin
  Result := CCFiniteTimeAction(Copy().autorelease);
end;

procedure CCActionInstant.step(dt: Single);
begin
  update(1);
end;

procedure CCActionInstant.update(time: Single);
begin
  //nothing
end;

{ CCFlipX }

class function CCFlipX._create(x: Boolean): CCFlipX;
var
  pRet: CCFlipX;
begin
  pRet := CCFlipX.Create();
  if (pRet <> nil) and pRet.initWithFlipX(x) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFlipX.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFlipX;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFlipX(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFlipX.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithFlipX(m_bFlipX);

  pNewZone.Free;

  Result := pRet;
end;

destructor CCFlipX.Destroy;
begin

  inherited;
end;

function CCFlipX.initWithFlipX(x: Boolean): Boolean;
begin
  m_bFlipX := x;
  Result := True;
end;

function CCFlipX.reverse: CCFiniteTimeAction;
begin
  Result := _create(not m_bFlipX);
end;

procedure CCFlipX.update(time: Single);
begin
  CCSprite(m_pTarget).setFlipX(m_bFlipX);
end;

{ CCFlipY }

class function CCFlipY._create(y: Boolean): CCFlipY;
var
  pRet: CCFlipY;
begin
  pRet := CCFlipY.Create();
  if (pRet <> nil) and pRet.initWithFlipY(y) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFlipY.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFlipY;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFlipY(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFlipY.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithFlipY(m_bFlipY);

  pNewZone.Free;

  Result := pRet;
end;

destructor CCFlipY.Destroy;
begin

  inherited;
end;

function CCFlipY.initWithFlipY(y: Boolean): Boolean;
begin
  m_bFlipY := y;
  Result := True;
end;

function CCFlipY.reverse: CCFiniteTimeAction;
begin
  Result := _create(not m_bFlipY);
end;

procedure CCFlipY.update(time: Single);
begin
  CCSprite(m_pTarget).setFlipY(m_bFlipY);
end;

{ CCPlace }

class function CCPlace._create(const pos: CCPoint): CCPlace;
var
  pRet: CCPlace;
begin
  pRet := CCPlace.Create;
  if (pRet <> nil) and (pRet.initWithPosition(pos)) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCPlace.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCPlace;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCPlace(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCPlace.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithPosition(m_tPosition);

  pNewZone.Free;

  Result := pRet;
end;

function CCPlace.initWithPosition(const pos: CCPoint): Boolean;
begin
  m_tPosition := pos;
  Result := True;
end;

procedure CCPlace.update(time: Single);
begin
  CCNode(m_pTarget).setPosition(m_tPosition);
end;

{ CCShow }

class function CCShow._create: CCShow;
var
  pRet: CCShow;
begin
  pRet := CCShow.Create;
  if pRet <> nil then
    pRet.autorelease();
  Result := pRet;
end;

function CCShow.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCShow;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCShow(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCShow.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pNewZone.Free;

  Result := pRet;
end;

function CCShow.reverse: CCFiniteTimeAction;
begin
  Result := CCHide._create();
end;

procedure CCShow.update(time: Single);
begin
  CCNode(m_pTarget).setVisible(True);
end;

{ CCHide }

class function CCHide._create: CCHide;
var
  pRet: CCHide;
begin
  pRet := CCHide.Create;
  if pRet <> nil then
    pRet.autorelease();
  Result := pRet;
end;

function CCHide.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCHide;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCHide(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCHide.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pNewZone.Free;

  Result := pRet;
end;

function CCHide.reverse: CCFiniteTimeAction;
begin
  Result := CCShow._create();
end;

procedure CCHide.update(time: Single);
begin
  CCNode(m_pTarget).setVisible(False);
end;

{ CCToggleVisibility }

class function CCToggleVisibility._create: CCToggleVisibility;
var
  pRet: CCToggleVisibility;
begin
  pRet := CCToggleVisibility.Create;
  if pRet <> nil then
    pRet.autorelease();
  Result := pRet;
end;

function CCToggleVisibility.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCToggleVisibility;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCToggleVisibility(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCToggleVisibility.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pNewZone.Free;

  Result := pRet;
end;

procedure CCToggleVisibility.update(time: Single);
begin
  CCNode(m_pTarget).setVisible(not CCNode(m_pTarget).isVisible() );
end;

{ CCCallFunc }

class function CCCallFunc._create(nHandler: Integer): CCCallFunc;
begin
//script
Result := nil;
end;

class function CCCallFunc._create(pSelectorTarget: CCObject;
  selector: SEL_CallFunc): CCCallFunc;
var
  pRet: CCCallFunc;
begin
  pRet := CCCallFunc.Create;
  if (pRet <> nil) and pRet.initWithTarget(pSelectorTarget) then
  begin
    pRet.m_pCallFunc := selector;
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCCallFunc.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCCallFunc;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCCallFunc(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCCallFunc.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithTarget(m_pSelectorTarget);
  pRet.m_pCallFunc := m_pCallFunc;

  pNewZone.Free;

  Result := pRet;
end;

destructor CCCallFunc.Destroy;
begin
  CC_SAFE_RELEASE(m_pSelectorTarget);
  inherited;
end;

procedure CCCallFunc.execute;
begin
  if (m_pSelectorTarget <> nil) and (@m_pCallFunc <> nil) then
    m_pCallFunc();
end;

function CCCallFunc.getScriptHandler: Integer;
begin
  Result := m_nSciptHandler;
end;

function CCCallFunc.getTargetCallback: CCObject;
begin
  Result := m_pSelectorTarget;
end;

function CCCallFunc.initWithTarget(pSelectorTarget: CCObject): Boolean;
begin
  if pSelectorTarget <> nil then
    pSelectorTarget.retain();
  if m_pSelectorTarget <> nil then
    m_pSelectorTarget.release();
  m_pSelectorTarget := pSelectorTarget;
  Result := True;
end;

procedure CCCallFunc.setTargetCallback(pSel: CCObject);
begin
  if m_pSelectorTarget <> pSel then
  begin
    CC_SAFE_RETAIN(pSel);
    CC_SAFE_RELEASE(m_pSelectorTarget);
    m_pSelectorTarget := pSel;
  end;  
end;

procedure CCCallFunc.update(time: Single);
begin
  Self.execute();
end;

{ CCCallFuncN }

class function CCCallFuncN._create(pSelectorTarget: CCObject;
  selector: SEL_CallFuncN): CCCallFuncN;
var
  pRet: CCCallFuncN;
begin
  pRet := CCCallFuncN.Create;
  if (pRet <> nil) and pRet.initWithTarget(pSelectorTarget, selector) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCCallFuncN.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCCallFuncN;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCCallFuncN(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCCallFuncN.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithTarget(m_pSelectorTarget, m_pCallFuncN);

  pNewZone.Free;

  Result := pRet;
end;

procedure CCCallFuncN.execute;
begin
  if (m_pSelectorTarget <> nil) and (@m_pCallFuncN <> nil) then
    m_pCallFuncN(m_pTarget);
end;

function CCCallFuncN.getClassTypeInfo: Cardinal;
begin
  Result := getHashCodeByString(Self.ClassName);
end;

function CCCallFuncN.initWithTarget(pSelectorTarget: CCObject;
  selector: SEL_CallFuncN): Boolean;
begin
  if inherited initWithTarget(pSelectorTarget) then
  begin
    m_pCallFuncN := selector;
    Result := True;
    Exit;
  end;
  Result := False;
end;

{ CCCallFuncND }

class function CCCallFuncND._create(pSelectorTarget: CCObject;
  selector: SEL_CallFuncND; d: Pointer): CCCallFuncND;
var
  pRet: CCCallFuncND;
begin
  pRet := CCCallFuncND.Create;
  if (pRet <> nil) and pRet.initWithTarget(pSelectorTarget, selector, d) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCCallFuncND.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCCallFuncND;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCCallFuncND(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCCallFuncND.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithTarget(m_pSelectorTarget, m_pCallFuncND, m_pData);

  pNewZone.Free;

  Result := pRet;
end;

procedure CCCallFuncND.execute;
begin
  if (m_pSelectorTarget <> nil) and (@m_pCallFuncND <> nil) then
    m_pCallFuncND(m_pTarget, m_pData);
end;

function CCCallFuncND.initWithTarget(pSelectorTarget: CCObject;
  selector: SEL_CallFuncND; d: Pointer): Boolean;
begin
  if inherited initWithTarget(pSelectorTarget, nil) then
  begin
    m_pData := d;
    m_pCallFuncND := selector;
    Result := True;
    Exit;
  end;
  Result := False;
end;

{ CCCallFuncO }

class function CCCallFuncO._create(pSelectorTarget: CCObject;
  selector: SEL_CallFuncO; pObject: CCObject): CCCallFuncO;
var
  pRet: CCCallFuncO;
begin
  pRet := CCCallFuncO.Create;
  if (pRet <> nil) and pRet.initWithTarget(pSelectorTarget, selector, pObject) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := pRet;
end;

function CCCallFuncO.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCCallFuncO;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCCallFuncO(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCCallFuncO.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithTarget(m_pSelectorTarget, m_pCallFunco, m_pObject);

  pNewZone.Free;

  Result := pRet;
end;

procedure CCCallFuncO.execute;
begin
  if (m_pSelectorTarget <> nil) and (@m_pCallFunco <> nil) then
    m_pCallFunco(m_pObject);
end;

function CCCallFuncO.getObject: CCObject;
begin
  Result := m_pObject;
end;

function CCCallFuncO.initWithTarget(pSelectorTarget: CCObject;
  selector: SEL_CallFuncO; pObject: CCObject): Boolean;
begin
  if inherited initWithTarget(pSelectorTarget, nil) then
  begin
    m_pObject := pObject;
    CC_SAFE_RETAIN(m_pObject);
    m_pCallFunco := selector;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCCallFuncO.setObject(pObj: CCObject);
begin
  if m_pObject <> pObj then
  begin
    CC_SAFE_RETAIN(pObj);
    CC_SAFE_RELEASE(m_pObject);
    m_pObject := pObj;
  end;  
end;

destructor CCCallFuncO.Destroy;
begin
  CC_SAFE_RELEASE(m_pObject);
  inherited;
end;

end.
