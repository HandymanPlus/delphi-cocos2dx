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

unit Cocos2dx.CCActionInterval;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCAction, Cocos2dx.CCArray, Cocos2dx.CCGeometry,
  Cocos2dx.CCTypes, Cocos2dx.CCAnimation, Cocos2dx.CCSpriteFrame, Cocos2dx.CCVector;

type
  CCSequence = class(CCActionInterval)
  public
    destructor Destroy(); override;
    function initWithTwoActions(pActionOne, pActionTwo: CCFiniteTimeAction): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure stop(); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pActions: array of CCFiniteTimeAction): CCFiniteTimeAction; overload;
    class function _create(arrayOfActions: CCArray): CCFiniteTimeAction; overload;
    class function createWithTwoActions(pActionOne, pActionTwo: CCFiniteTimeAction): CCSequence;
  protected
    m_pActions: array [0..1] of CCFiniteTimeAction;
    m_split: Single;
    m_last: Integer;
  end;

  CCRepeat = class(CCActionInterval)
  public
    destructor Destroy(); override;
    function initWithAction(pAction: CCFiniteTimeAction; times: Cardinal): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure stop(); override;
    procedure update(time: Single); override;
    function isDone(): Boolean; override;
    function reverse(): CCFiniteTimeAction; override;
    procedure setInnerAction(pAction: CCFiniteTimeAction);
    function getInnerAction(): CCFiniteTimeAction;
    class function _create(pAction: CCFiniteTimeAction; times: Cardinal): CCRepeat;
  protected
    m_uTimes, m_uTotal: Cardinal;
    m_fNextDt: Single;
    m_bActionInstant: Boolean;
    m_pInnerAction: CCFiniteTimeAction;
  end;

  CCRepeatForever = class(CCActionInterval)
  public
    destructor Destroy(); override;
    function initWithAction(pAction: CCActionInterval): Boolean;
    function isDone(): Boolean; override;
    procedure step(dt: Single); override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure setInnerAction(pAction: CCActionInterval);
    function getInnerAction(): CCActionInterval;
    class function _create(pAction: CCActionInterval): CCRepeatForever;
  protected
    m_pInnerAction: CCActionInterval;
  end;

  CCRotateTo = class(CCActionInterval)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    class function _create(duration: Single; fDeltaAngle: Single): CCRotateTo; overload;
    class function _create(duration: Single; fDeltaAngleX, fDeltaAngleY: Single): CCRotateTo; overload;
    function initWithDuration(duration: Single; fDeltaAngleX, fDeltaAngleY: Single): Boolean; overload;
    function initWithDuration(duration: Single; fDeltaAngle: Single): Boolean; overload;
  protected
    m_fDstAngleX, m_fStartAngleX, m_fDiffAngleX: Single;
    m_fDstAngleY, m_fStartAngleY, m_fDiffAngleY: Single;
  end;

  CCRotateBy = class(CCActionInterval)
  public

    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(duration: Single; fDeltaAngle: Single): CCRotateBy; overload;
    function initWithDuration(duration: Single; fDeltaAngle: Single): Boolean; overload;
    class function _create(duration: Single; fDeltaAngleX, fDeltaAngleY: Single): CCRotateBy; overload;
    function initWithDuration(duration: Single; fDeltaAngleX, fDeltaAngleY: Single): Boolean; overload;
  protected
    m_fAngleX, m_fStartAngleX: Single;
    m_fAngleY, m_fStartAngleY: Single;
  end;

  (**  Moves a CCNode object x,y pixels by modifying it's position attribute.
   x and y are relative to the position of the object.
   Several CCMoveBy actions can be concurrently called, and the resulting
   movement will be the sum of individual movements.
   @since v2.1beta2-custom
   *)
  CCMoveBy = class(CCActionInterval)
  protected
    m_positionDelta, m_startPosition, m_previousPosition: CCPoint;
  public
    function initWithDuration(duration: Single; const deltaPosition: CCPoint): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(duration: Single; const deltaPosition: CCPoint): CCMoveBy;
  end;

  (** Moves a CCNode object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
   Several CCMoveTo actions can be concurrently called, and the resulting
   movement will be the sum of individual movements.
   @since v2.1beta2-custom
   *)
  CCMoveTo = class(CCMoveBy)
  protected
    m_endPosition: CCPoint;
  public
    function initWithDuration(duration: Single; const position: CCPoint): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    class function _create(duration: Single; const position: CCPoint): CCMoveTo;
  end;

  CCJumpBy = class(CCActionInterval)
  public
    function initWithDuration(duration: Single; const position: CCPoint; height: Single; jumps: Cardinal): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(duration: Single; const position: CCPoint; height: Single; jumps: Cardinal): CCJumpBy;
  protected
    m_startPosition: CCPoint;
    m_delta: CCPoint;
    m_height: Single;
    m_nJumps: Cardinal;
    m_previousPos: CCPoint;
  end;

  CCJumpTo = class(CCJumpBy)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    class function _create(duration: Single; const position: CCPoint; height: Single; jumps: Cardinal): CCJumpTo;
  end;

  CCScaleTo = class(CCActionInterval)
  public
    function initWithDuration(duration: Single; s: Single): Boolean; overload;
    function initWithDuration(duration: Single; sx, sy: Single): Boolean; overload;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    class function _create(duration: Single; s: Single): CCScaleTo; overload;
    class function _create(duration: Single; sx, sy: Single): CCScaleTo; overload;
  protected
    m_fScaleX, m_fScaleY: Single;
    m_fStartScaleX, m_fStartScaleY: Single;
    m_fEndScaleX, m_fEndScaleY: Single;
    m_fDeltaX, m_fDeltaY: Single;
  end;

  CCScaleBy = class(CCScaleTo)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(duration: Single; s: Single): CCScaleBy; overload;
    class function _create(duration: Single; sx, sy: Single): CCScaleBy; overload;
  end;

  CCBlink = class(CCActionInterval)
  public
    function initWithDuration(duration: Single; uBlinks: Cardinal): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure stop(); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(duration: Single; uBlinks: Cardinal): CCBlink;
  protected
    m_nTimes: Cardinal;
    m_bOriginalState: Boolean;
  end;

  CCFadeIn = class(CCActionInterval)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(d: Single): CCFadeIn;
  end;

  CCFadeOut = class(CCActionInterval)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(d: Single): CCFadeOut;
  end;

  CCFadeTo = class(CCActionInterval)
  public
    function initWithDuration(duration: Single; opacity: GLubyte): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    class function _create(duration: Single; opacity: GLubyte): CCFadeTo;
  protected
    m_toOpacity: GLubyte;
    m_fromOpacity: GLubyte;
  end;

  CCTintTo = class(CCActionInterval)
  public
    function initWithDuration(duration: Single; red, green, blue: GLubyte): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    class function _create(duration: Single; red, green, blue: GLubyte): CCTintTo;
  protected
    m_to, m_from: ccColor3B;
  end;

  CCTintBy = class(CCActionInterval)
  public
    function initWithDuration(duration: Single; deltaRed, deltaGreen, deltaBlue: GLshort): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(duration: Single; deltaRed, deltaGreen, deltaBlue: GLshort): CCTintBy;
  protected
    m_deltaR, m_deltaG, m_deltaB: GLshort;
    m_fromR, m_fromG, m_fromB: GLshort;
  end;

  CCDelayTime = class(CCActionInterval)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(d: Single): CCDelayTime;
  end;

  CCTargetedAction = class(CCActionInterval)
  private
    function getForcedTarget: CCObject;
    procedure setForcedTarget(const Value: CCObject);
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(pTarget: CCObject{CCNode}; pAction: CCFiniteTimeAction): CCTargetedAction;
    function initWithTarget(pTarget: CCObject{CCNode}; pAction: CCFiniteTimeAction): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    procedure stop(); override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    property ForcedTarget: CCObject{CCNode} read getForcedTarget write setForcedTarget;
  protected
    m_pAction: CCFiniteTimeAction;
    m_pForcedTarget: CCObject{CCNode};
  end;

  CCSkewTo = class(CCActionInterval)
  public
    constructor Create();
    function initWithDuration(t, sx, sy: Single): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    class function _create(t, sx, sy: Single): CCSkewTo;
  protected
    m_fSkewX, m_fSkewY: Single;
    m_fStartSkewX, m_fStartSkewY: Single;
    m_fEndSkewX, m_fEndSkewY: Single;
    m_fDeltaX, m_fDeltaY: Single;
  end;

  CCSkewBy = class(CCSkewTo)
  public
    function initWithDuration(t, sx, sy: Single): Boolean;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(t, sx, sy: Single): CCSkewBy;
  end;

  CCSpawn = class(CCActionInterval)
  public
    destructor Destroy(); override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    procedure stop(); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pActions: array of CCFiniteTimeAction): CCFiniteTimeAction; overload;
    class function _create(arrayOfActions: CCArray): CCFiniteTimeAction; overload;
    class function createWithTwoActions(pAction1, pAction2: CCFiniteTimeAction): CCSpawn;
    function initWithTwoActions(pAction1, pAction2: CCFiniteTimeAction): Boolean;
  protected
    m_pOne, m_pTwo: CCFiniteTimeAction;
  end;

  ccBezierConfig = record
    endPosition: CCPoint;
    controlPoint_1: CCPoint;
    controlPoint_2: CCPoint;
  end;

  CCBezierBy = class(CCActionInterval)
  public
    function initWithDuration(t: Single; const c: ccBezierConfig): Boolean;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(t: Single; const c: ccBezierConfig): CCBezierBy;
  protected
    m_sConfig: ccBezierConfig;
    m_startPosition: CCPoint;
    m_previousPosition: CCPoint;
  end;

  CCBezierTo = class(CCBezierBy)
  protected
    m_sToConfig: ccBezierConfig;
  public
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    class function _create(t: Single; const c: ccBezierConfig): CCBezierTo;
    function initWithDuration(t: Single; const c: ccBezierConfig): Boolean;
  end;

  CCReverseTime = class(CCActionInterval)
  public
    constructor Create();
    destructor Destroy(); override;
    function initWithAction(pAction: CCFiniteTimeAction): Boolean;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure stop(); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCFiniteTimeAction): CCReverseTime;
  protected
    m_pOther: CCFiniteTimeAction;
  end;

  CCAnimate = class(CCActionInterval)
  public
    constructor Create();
    destructor Destroy(); override;
    function initWithAnimation(pAnimation: CCAnimation): Boolean;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure stop(); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAnimation: CCAnimation): CCAnimate;
    function getAnimation(): CCAnimation;
    procedure setAnimation(pValue: CCAnimation);
  protected
    m_nNextFrame: Integer;
    m_pOrigFrame: CCSpriteFrame;
    m_uExectureLoops: Cardinal;
    m_pAnimation: CCAnimation;
    m_pSplitTimes: TVectorFloat;
  end;

implementation
uses
  Math,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCNode, Cocos2dx.CCPointExtension,
  Cocos2dx.CCSprite, Cocos2dx.CCDictionary, Cocos2dx.CCActionInstant;

function fmodf(fSource: Single; fLimit: Single): Single;
var
  temp: Single;
  isNeg: Boolean;
begin
  fLimit := Abs(fLimit);

  if (fSource <= fLimit) and (fSource >= -fLimit) then
  begin
    Result := fSource;
  end else
  begin
    temp := fSource;
    fSource := Abs(fSource);
    isNeg := temp <> fSource;

    while fSource > fLimit do
    begin
      fSource := fSource - fLimit;
    end;

    if isNeg then
      Result := -fSource
    else
      Result := fSource;
  end;
end;  

{ CCSequence }

class function CCSequence._create(arrayOfActions: CCArray): CCFiniteTimeAction;
var
  i, nCount: Integer;
  prev: CCFiniteTimeAction;
begin
  nCount := arrayOfActions.count();
  if nCount < 1 then
  begin
    Result := nil;
    Exit;
  end;

  prev := CCFiniteTimeAction(arrayOfActions.objectAtIndex(0));

  for i := 1 to nCount-1 do
  begin
    prev := createWithTwoActions(prev, CCFiniteTimeAction(arrayOfActions.objectAtIndex(i)));
  end;

  Result := prev;
end;

class function CCSequence._create(
  pActions: array of CCFiniteTimeAction): CCFiniteTimeAction;
var
  i, nCount: Integer;
  prev: CCFiniteTimeAction;
begin
  nCount := Length(pActions);
  if nCount < 1 then
  begin
    Result := nil;
    Exit;
  end;

  prev := pActions[0];
  for i := 1 to nCount-1 do
  begin
    prev := createWithTwoActions(prev, pActions[i]);
  end;

  Result := prev;
end;

function CCSequence.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCSequence;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCSequence(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCSequence.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithTwoActions(CCFiniteTimeAction(m_pActions[0].copy().autorelease()),
    CCFiniteTimeAction(m_pActions[1].copy().autorelease()));

  pNewZone.Free;

  Result := pRet;
end;

class function CCSequence.createWithTwoActions(pActionOne,
  pActionTwo: CCFiniteTimeAction): CCSequence;
var
  pRet: CCSequence;
begin
  pRet := CCSequence.Create();
  pRet.initWithTwoActions(pActionOne, pActionTwo);
  pRet.autorelease();
  Result := pRet;
end;

destructor CCSequence.Destroy;
begin
  CC_SAFE_RELEASE(m_pActions[0]);
  CC_SAFE_RELEASE(m_pActions[1]);
  inherited;
end;

function CCSequence.initWithTwoActions(pActionOne,
  pActionTwo: CCFiniteTimeAction): Boolean;
var
  d: Single;
begin
  CCAssert(pActionOne <> nil, '');
  CCAssert(pActionTwo <> nil, '');

  d := pActionOne.getDuration() + pActionTwo.getDuration();
  inherited initWithDuration(d);

  m_pActions[0] := pActionOne;
  pActionOne.retain();

  m_pActions[1] := pActionTwo;
  pActionTwo.retain();

  Result := True;
end;

function CCSequence.reverse: CCFiniteTimeAction;
begin
  Result := createWithTwoActions(m_pActions[1].reverse(), m_pActions[0].reverse());
end;

procedure CCSequence.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_split := m_pActions[0].getDuration() / m_fDuration;
  m_last := -1;
end;

procedure CCSequence.stop;
begin
  if m_last <> -1 then
  begin
    m_pActions[m_last].stop();
  end;  
  inherited stop();
end;

procedure CCSequence.update(time: Single);
var
  found: Integer;
  new_t: Single;
begin
  if time < m_split then
  begin
    found := 0;
    if m_split <> 0 then
      new_t := time / m_split
    else
      new_t := 1;
  end else
  begin
    found := 1;
    if m_split = 1 then
      new_t := 1
    else
      new_t := (time - m_split) / (1 - m_split);
  end;

  if found = 1 then
  begin
    if m_last= -1 then
    begin
      m_pActions[0].startWithTarget(m_pTarget);
      m_pActions[0].update(1.0);
      m_pActions[0].stop();
    end else if m_last = 0 then
    begin
      m_pActions[0].update(1.0);
      m_pActions[0].stop();
    end;    
  end;

  if (found = m_last) and m_pActions[found].isDone() then
    Exit;

  if found <> m_last then
  begin
    m_pActions[found].startWithTarget(m_pTarget);
  end;

  m_pActions[found].update(new_t);
  m_last := found;
end;

{ CCRepeatForever }

class function CCRepeatForever._create(
  pAction: CCActionInterval): CCRepeatForever;
var
  pRet: CCRepeatForever;
begin
  pRet := CCRepeatForever.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCRepeatForever.Destroy;
begin
  CC_SAFE_RELEASE(m_pInnerAction);
  inherited;
end;

function CCRepeatForever.getInnerAction: CCActionInterval;
begin
  Result := m_pInnerAction;
end;

function CCRepeatForever.initWithAction(pAction: CCActionInterval): Boolean;
begin
  CCAssert(pAction <> nil, '');
  pAction.retain();
  m_pInnerAction := pAction;
  Result := True;
end;

function CCRepeatForever.isDone: Boolean;
begin
  Result := False;
end;

function CCRepeatForever.reverse: CCFiniteTimeAction;
begin
  Result := CCActionInterval(CCRepeatForever._create(CCActionInterval(m_pInnerAction.reverse())));
end;

procedure CCRepeatForever.setInnerAction(pAction: CCActionInterval);
begin
  if m_pInnerAction <> pAction then
  begin
    CC_SAFE_RETAIN(pAction);
    CC_SAFE_RELEASE(m_pInnerAction);
    m_pInnerAction := pAction;
  end;  
end;

procedure CCRepeatForever.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pInnerAction.startWithTarget(pTarget);
end;

procedure CCRepeatForever.step(dt: Single);
var
  diff: Single;
begin
  m_pInnerAction.step(dt);
  if m_pInnerAction.isDone() then
  begin
    diff := m_pInnerAction.getElapsed() - m_pInnerAction.getDuration();
    m_pInnerAction.startWithTarget(m_pTarget);
    m_pInnerAction.step(0.0);
    m_pInnerAction.step(diff);
  end;
end;

function CCRepeatForever.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCRepeatForever;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCRepeatForever(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCRepeatForever.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithAction(CCActionInterval(m_pInnerAction.copy().autorelease()));

  pNewZone.Free;

  Result := pRet;
end;

{ CCRotateTo }

class function CCRotateTo._create(duration,
  fDeltaAngle: Single): CCRotateTo;
var
  pRotateTo: CCRotateTo;
begin
  pRotateTo := CCRotateTo.Create();
  pRotateTo.initWithDuration(duration, fDeltaAngle);
  pRotateTo.autorelease();
  Result := pRotateTo;
end;

function CCRotateTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCRotateTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCRotateTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCRotateTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fDstAngleX, m_fDstAngleY);

  pNewZone.Free;

  Result := pRet;
end;

function CCRotateTo.initWithDuration(duration,
  fDeltaAngle: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fDstAngleX := fDeltaAngle;
    m_fDstAngleY := fDeltaAngle;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCRotateTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_fStartAngleX := CCNode(pTarget).getRotationX();
  if m_fStartAngleX > 0 then
  begin
    m_fStartAngleX := fmodf(m_fStartAngleX, 360.0);
  end else
  begin
    m_fStartAngleX := fmodf(m_fStartAngleX, -360.0);
  end;

  m_fDiffAngleX := m_fDstAngleX - m_fStartAngleX;
  if m_fDiffAngleX > 180 then
    m_fDiffAngleX := m_fDiffAngleX - 360;

  if m_fDiffAngleX < -180 then
    m_fDiffAngleX := m_fDiffAngleX + 360;

  m_fStartAngleY := CCNode(pTarget).getRotationY();
  if m_fStartAngleY > 0 then
  begin
    m_fStartAngleY := fmodf(m_fStartAngleY, 360.0);
  end else
  begin
    m_fStartAngleY := fmodf(m_fStartAngleY, -360.0);
  end;

  m_fDiffAngleY := m_fDstAngleY - m_fStartAngleY;
  if m_fDiffAngleY > 180 then
    m_fDiffAngleY := m_fDiffAngleY - 360;

  if m_fDiffAngleY < -180 then
    m_fDiffAngleY := m_fDiffAngleY + 360;
end;

procedure CCRotateTo.update(time: Single);
begin
  if m_pTarget <> nil then
  begin
    CCNode(m_pTarget).setRotationX(m_fStartAngleX + m_fDiffAngleX * time);
    CCNode(m_pTarget).setRotationY(m_fStartAngleY + m_fDiffAngleY * time);
  end;
end;

class function CCRotateTo._create(duration, fDeltaAngleX,
  fDeltaAngleY: Single): CCRotateTo;
var
  pRotateTo: CCRotateTo;
begin
  pRotateTo := CCRotateTo.Create();
  pRotateTo.initWithDuration(duration, fDeltaAngleX, fDeltaAngleY);
  pRotateTo.autorelease();
  Result := pRotateTo;
end;

function CCRotateTo.initWithDuration(duration, fDeltaAngleX,
  fDeltaAngleY: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fDstAngleX := fDeltaAngleX;
    m_fDstAngleY := fDeltaAngleY;
    Result := True;
    Exit;
  end;
  Result := False;
end;

{ CCRotateBy }

class function CCRotateBy._create(duration,
  fDeltaAngle: Single): CCRotateBy;
var
  pRotateBy: CCRotateBy;
begin
  pRotateBy := CCRotateBy.Create();
  pRotateBy.initWithDuration(duration, fDeltaAngle);
  pRotateBy.autorelease();
  Result := pRotateBy;
end;

function CCRotateBy.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCRotateBy;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCRotateBy(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCRotateBy.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fAngleX, m_fAngleY);

  pNewZone.Free;

  Result := pRet;
end;

function CCRotateBy.initWithDuration(duration,
  fDeltaAngle: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fAngleX := fDeltaAngle;
    m_fAngleY := fDeltaAngle;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCRotateBy.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, -m_fAngleX, -m_fAngleY);
end;

procedure CCRotateBy.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_fStartAngleX := CCNode(pTarget).getRotationX();
  m_fStartAngleY := CCNode(pTarget).getRotationY();
end;

procedure CCRotateBy.update(time: Single);
begin
  if m_pTarget <> nil then
  begin
    CCNode(m_pTarget).setRotationX(m_fStartAngleX + m_fAngleX * time);
    CCNode(m_pTarget).setRotationY(m_fStartAngleY + m_fAngleY * time);
  end;
end;

class function CCRotateBy._create(duration, fDeltaAngleX,
  fDeltaAngleY: Single): CCRotateBy;
var
  pRotateBy: CCRotateBy;
begin
  pRotateBy := CCRotateBy.Create();
  pRotateBy.initWithDuration(duration, fDeltaAngleX, fDeltaAngleY);
  pRotateBy.autorelease();
  Result := pRotateBy;
end;

function CCRotateBy.initWithDuration(duration, fDeltaAngleX,
  fDeltaAngleY: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fAngleX := fDeltaAngleX;
    m_fAngleY := fDeltaAngleY;
    Result := True;
    Exit;
  end;
  Result := False;
end;

{ CCMoveTo }

class function CCMoveTo._create(duration: Single;
  const position: CCPoint): CCMoveTo;
var
  pRet: CCMoveTo;
begin
  pRet := CCMoveTo.Create();
  pRet.initWithDuration(duration, position);
  pRet.autorelease();
  Result := pRet;
end;

function CCMoveTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCMoveTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCMoveTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCMoveTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_endPosition);

  pNewZone.Free;

  Result := pRet;
end;

function CCMoveTo.initWithDuration(duration: Single;
  const position: CCPoint): Boolean;
begin
  if inherited initWithDuration(duration, position) then
  begin
    m_endPosition := position;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCMoveTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_startPosition := CCNode(pTarget).getPosition();
  m_positionDelta := ccpSub(m_endPosition, m_startPosition);
end;

{ CCMoveBy }

class function CCMoveBy._create(duration: Single;
  const deltaPosition: CCPoint): CCMoveBy;
var
  pRet: CCMoveBy;
begin
  pRet := CCMoveBy.Create();
  pRet.initWithDuration(duration, deltaPosition);
  pRet.autorelease();
  Result := pRet;
end;

function CCMoveBy.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCMoveBy;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCMoveBy(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCMoveBy.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_positionDelta);

  pNewZone.Free;

  Result := pRet;
end;

function CCMoveBy.initWithDuration(duration: Single;
  const deltaPosition: CCPoint): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_positionDelta := deltaPosition;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCMoveBy.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, ccp(-m_positionDelta.x, -m_positionDelta.y));
end;

procedure CCMoveBy.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_previousPosition := CCNode(pTarget).getPosition();
  m_startPosition := m_previousPosition;
end;

procedure CCMoveBy.update(time: Single);
begin
  CCNode(m_pTarget).setPosition(ccpAdd(m_startPosition, ccpMult(m_positionDelta, time)));
end;

{ CCJumpBy }

class function CCJumpBy._create(duration: Single; const position: CCPoint;
  height: Single; jumps: Cardinal): CCJumpBy;
var
  pRet: CCJumpBy;
begin
  pRet := CCJumpBy.Create();
  pRet.initWithDuration(duration, position, height, jumps);
  pRet.autorelease();
  Result := pRet;
end;

function CCJumpBy.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCJumpBy;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCJumpBy(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCJumpBy.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_delta, m_height, m_nJumps);

  pNewZone.Free;

  Result := pRet;
end;

function CCJumpBy.initWithDuration(duration: Single;
  const position: CCPoint; height: Single; jumps: Cardinal): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_delta := position;
    m_height := height;
    m_nJumps := jumps;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCJumpBy.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, ccp(-m_delta.x, -m_delta.y), m_height, m_nJumps);
end;

procedure CCJumpBy.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_startPosition := CCNode(pTarget).getPosition();
  m_previousPos := m_startPosition;
end;

procedure CCJumpBy.update(time: Single);
var
  frac, y, x: Single;
begin
  if m_pTarget <> nil then
  begin
    frac := fmodf(time * m_nJumps, 1.0);
    y := m_height * 4 * frac * (1 - frac);
    y := y + m_delta.y * time;
    x := m_delta.x * time;
    CCNode(m_pTarget).setPosition( ccpAdd(m_startPosition, ccp(x, y) ) );
  end;  
end;

{ CCJumpTo }

class function CCJumpTo._create(duration: Single; const position: CCPoint;
  height: Single; jumps: Cardinal): CCJumpTo;
var
  pRet: CCJumpTo;
begin
  pRet := CCJumpTo.Create();
  pRet.initWithDuration(duration, position, height, jumps);
  pRet.autorelease();
  Result := pRet;
end;

function CCJumpTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCJumpTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCJumpTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCJumpTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_delta, m_height, m_nJumps);

  pNewZone.Free;

  Result := pRet;
end;

procedure CCJumpTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_delta := ccp( m_delta.x - m_startPosition.x, m_delta.y - m_startPosition.y );
end;

{ CCScaleTo }

class function CCScaleTo._create(duration, s: Single): CCScaleTo;
var
  pRet: CCScaleTo;
begin
  pRet := CCScaleTo.Create();
  pRet.initWithDuration(duration, s);
  pRet.autorelease();
  Result := pRet;
end;

class function CCScaleTo._create(duration, sx, sy: Single): CCScaleTo;
var
  pRet: CCScaleTo;
begin
  pRet := CCScaleTo.Create();
  pRet.initWithDuration(duration, sx, sy);
  pRet.autorelease();
  Result := pRet;
end;

function CCScaleTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCScaleTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCScaleTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCScaleTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fEndScaleX, m_fEndScaleY);

  pNewZone.Free;

  Result := pRet;
end;

function CCScaleTo.initWithDuration(duration, sx, sy: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fEndScaleX := sx;
    m_fEndScaleY := sy;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCScaleTo.initWithDuration(duration, s: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fEndScaleX := s;
    m_fEndScaleY := s;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCScaleTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_fStartScaleX := CCNode(pTarget).ScaleX;
  m_fStartScaleY := CCNode(pTarget).ScaleY;
  m_fDeltaX := m_fEndScaleX - m_fStartScaleX;
  m_fDeltaY := m_fEndScaleY - m_fStartScaleY;
end;

procedure CCScaleTo.update(time: Single);
begin
  if m_pTarget <> nil then
  begin
    CCNode(m_pTarget).ScaleX := m_fStartScaleX + m_fDeltaX * time;
    CCNode(m_pTarget).ScaleY := m_fStartScaleY + m_fDeltaY * time;
  end;  
end;

{ CCScaleBy }

class function CCScaleBy._create(duration, s: Single): CCScaleBy;
var
  pRet: CCScaleBy;
begin
  pRet := CCScaleBy.Create();
  pRet.initWithDuration(duration, s);
  pRet.autorelease();
  Result := pRet;
end;

class function CCScaleBy._create(duration, sx, sy: Single): CCScaleBy;
var
  pRet: CCScaleBy;
begin
  pRet := CCScaleBy.Create();
  pRet.initWithDuration(duration, sx, sy);
  pRet.autorelease();
  Result := pRet;
end;

function CCScaleBy.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCScaleBy;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCScaleBy(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCScaleBy.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fEndScaleX, m_fEndScaleY);

  pNewZone.Free;

  Result := pRet;
end;

function CCScaleBy.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, 1/m_fEndScaleX, 1/m_fEndScaleY);
end;

procedure CCScaleBy.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_fDeltaX := m_fStartScaleX * m_fEndScaleX - m_fStartScaleX;
  m_fDeltaY := m_fStartScaleY * m_fEndScaleY - m_fStartScaleY;
end;

{ CCBlink }

class function CCBlink._create(duration: Single;
  uBlinks: Cardinal): CCBlink;
var
  pRet: CCBlink;
begin
  pRet := CCBlink.Create();
  pRet.initWithDuration(duration, uBlinks);
  pRet.autorelease();
  Result := pRet;
end;

function CCBlink.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCBlink;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCBlink(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCBlink.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_nTimes);

  pNewZone.Free;

  Result := pRet;
end;

function CCBlink.initWithDuration(duration: Single;
  uBlinks: Cardinal): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_nTimes := uBlinks;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCBlink.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, m_nTimes);
end;

procedure CCBlink.update(time: Single);
var
  slice, m: Single;
begin
  if (m_pTarget <> nil) and (not isDone()) then
  begin
    slice := 1.0/m_nTimes;
    m := fmodf(time, slice);

    if m > slice/2 then
      CCNode(m_pTarget).setVisible(True)
    else
      CCNode(m_pTarget).setVisible(False);
  end;
end;

procedure CCBlink.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_bOriginalState := CCNode(pTarget).isVisible();
end;

procedure CCBlink.stop;
begin
  CCNode(m_pTarget).setVisible(m_bOriginalState);
  inherited stop();
end;

{ CCFadeIn }

class function CCFadeIn._create(d: Single): CCFadeIn;
var
  pRet: CCFadeIn;
begin
  pRet := CCFadeIn.Create();
  pRet.initWithDuration(d);
  pRet.autorelease();
  Result := pRet;
end;

function CCFadeIn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFadeIn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFadeIn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFadeIn.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pNewZone.Free;

  Result := pRet;
end;

function CCFadeIn.reverse: CCFiniteTimeAction;
begin
  Result := CCFadeOut._create(m_fDuration);
end;

procedure CCFadeIn.update(time: Single);
begin
  if m_pTarget <> nil then
  begin
    CCNode(m_pTarget).setOpacity(Round(255 * time));
  end;
end;

{ CCFadeOut }

class function CCFadeOut._create(d: Single): CCFadeOut;
var
  pRet: CCFadeOut;
begin
  pRet := CCFadeOut.Create();
  pRet.initWithDuration(d);
  pRet.autorelease();
  Result := pRet;
end;

function CCFadeOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFadeOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFadeOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFadeOut.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pNewZone.Free;

  Result := pRet;
end;

function CCFadeOut.reverse: CCFiniteTimeAction;
begin
  Result := CCFadeIn._create(m_fDuration);
end;

procedure CCFadeOut.update(time: Single);
begin
  if m_pTarget <> nil then
  begin
    CCNode(m_pTarget).setOpacity(Round(255 * (1-time) ));
  end;
end;

{ CCFadeTo }

class function CCFadeTo._create(duration: Single;
  opacity: GLubyte): CCFadeTo;
var
  pRet: CCFadeTo;
begin
  pRet := CCFadeTo.Create();
  pRet.initWithDuration(duration, opacity);
  pRet.autorelease();
  Result := pRet;
end;

function CCFadeTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFadeTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFadeTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFadeTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_toOpacity);

  pNewZone.Free;

  Result := pRet;
end;

function CCFadeTo.initWithDuration(duration: Single;
  opacity: GLubyte): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_toOpacity := opacity;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCFadeTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  if pTarget <> nil then
    m_fromOpacity := CCNode(pTarget).getOpacity();
end;

procedure CCFadeTo.update(time: Single);
begin
  if m_pTarget <> nil then
    CCNode(m_pTarget).setOpacity(Round(m_fromOpacity + (m_toOpacity - m_fromOpacity) * time));
end;

{ CCTintTo }

class function CCTintTo._create(duration: Single; red, green,
  blue: GLubyte): CCTintTo;
var
  pRet: CCTintTo;
begin
  pRet := CCTintTo.Create();
  pRet.initWithDuration(duration, red, green, blue);
  pRet.autorelease();
  Result := pRet;
end;

function CCTintTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCTintTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCTintTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCTintTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_to.r, m_to.g, m_to.b);

  pNewZone.Free;

  Result := pRet;
end;

function CCTintTo.initWithDuration(duration: Single; red, green,
  blue: GLubyte): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_to := ccc3(red, green, blue);
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCTintTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  if m_pTarget <> nil then
    m_from := CCNode(m_pTarget).getColor();
end;

procedure CCTintTo.update(time: Single);
begin
  if m_pTarget <> nil then
    CCNode(m_pTarget).setColor( ccc3(
        Round( m_from.r + (m_to.r - m_from.r) * time ),
        Round( m_from.g + (m_to.g - m_from.g) * time ),
        Round( m_from.b + (m_to.b - m_from.b) * time )
        )
      );
end;

{ CCTintBy }

class function CCTintBy._create(duration: Single; deltaRed, deltaGreen,
  deltaBlue: GLshort): CCTintBy;
var
  pRet: CCTintBy;
begin
  pRet := CCTintBy.Create();
  pRet.initWithDuration(duration, deltaRed, deltaGreen, deltaBlue);
  pRet.autorelease();
  Result := pRet;
end;

function CCTintBy.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCTintBy;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCTintBy(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCTintBy.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_deltaR, m_deltaG, m_deltaB);

  pNewZone.Free;

  Result := pRet;
end;

function CCTintBy.initWithDuration(duration: Single; deltaRed, deltaGreen,
  deltaBlue: GLshort): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_deltaR := deltaRed;
    m_deltaG := deltaGreen;
    m_deltaB := deltaBlue;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCTintBy.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, -m_deltaR, -m_deltaG, -m_deltaB);
end;

procedure CCTintBy.startWithTarget(pTarget: CCObject);
var
  color: ccColor3B;
begin
  inherited startWithTarget(pTarget);
  if pTarget <> nil then
  begin
    color := CCNode(pTarget).getColor();
    m_fromR := color.r;
    m_fromG := color.g;
    m_fromB := color.b;
  end;
end;

procedure CCTintBy.update(time: Single);
begin
  if m_pTarget <> nil then
  begin
    CCNode(m_pTarget).setColor( ccc3(
        Round(m_fromR + m_deltaR * time),
        Round(m_fromG + m_deltaG * time),
        Round(m_fromB + m_deltaB * time)
        )
      );
  end;  
end;

{ CCRepeat }

class function CCRepeat._create(pAction: CCFiniteTimeAction;
  times: Cardinal): CCRepeat;
var
  pRet: CCRepeat;
begin
  pRet := CCRepeat.Create;
  pRet.initWithAction(pAction, times);
  pRet.autorelease();
  Result := pRet;
end;

function CCRepeat.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCRepeat;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCRepeat(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCRepeat.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithAction(CCFiniteTimeAction(m_pInnerAction.copy().autorelease()), m_uTimes);  

  pNewZone.Free;

  Result := pRet;
end;

destructor CCRepeat.Destroy;
begin
  CC_SAFE_RELEASE(m_pInnerAction);
  inherited;
end;

function CCRepeat.getInnerAction: CCFiniteTimeAction;
begin
  Result := m_pInnerAction;
end;

function CCRepeat.initWithAction(pAction: CCFiniteTimeAction;
  times: Cardinal): Boolean;
var
  d: Single;
begin
  d := pAction.getDuration() * times;
  if inherited initWithDuration(d) then
  begin
    m_uTimes := times;
    m_pInnerAction := pAction;
    pAction.retain();
    m_bActionInstant := pAction is CCActionInstant;
    if m_bActionInstant then
    begin
      m_uTimes := m_uTimes - 1;
    end;
    m_uTotal := 0;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCRepeat.isDone: Boolean;
begin
  Result := m_uTotal = m_uTimes;
end;

function CCRepeat.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_pInnerAction.reverse(), m_uTimes);
end;

procedure CCRepeat.setInnerAction(pAction: CCFiniteTimeAction);
begin
  if m_pInnerAction <> pAction then
  begin
    CC_SAFE_RETAIN(pAction);
    CC_SAFE_RELEASE(m_pInnerAction);
    m_pInnerAction := pAction;
  end;  
end;

procedure CCRepeat.startWithTarget(pTarget: CCObject);
begin
  m_uTotal := 0;
  m_fNextDt := m_pInnerAction.getDuration()/m_fDuration;
  inherited startWithTarget(pTarget);
  m_pInnerAction.startWithTarget(pTarget);
end;

procedure CCRepeat.stop;
begin
  m_pInnerAction.stop();
  inherited stop();
end;

procedure CCRepeat.update(time: Single);
begin
  if time >= m_fNextDt then
  begin
    while (time > m_fNextDt) and (m_uTotal < m_uTimes) do
    begin
      m_pInnerAction.update(1.0);
      Inc(m_uTotal);

      m_pInnerAction.stop();
      m_pInnerAction.startWithTarget(m_pTarget);
      m_fNextDt := m_fNextDt + m_pInnerAction.getDuration()/m_fDuration;
    end;

    if (time >= 1.0) and (m_uTotal < m_uTimes) then
      Inc(m_uTotal);

    if not m_bActionInstant then
    begin
      if m_uTotal = m_uTimes then
      begin
        m_pInnerAction.update(1);
        m_pInnerAction.stop();
      end else
      begin
        m_pInnerAction.update( time - (m_fNextDt - m_pInnerAction.getDuration()/m_fDuration) );
      end;    
    end;  
  end else
  begin
    m_pInnerAction.update(fmodf(time*m_uTimes, 1.0));
  end;    
end;

{ CCDelayTime }

class function CCDelayTime._create(d: Single): CCDelayTime;
var
  pRet: CCDelayTime;
begin
  pRet := CCDelayTime.Create;
  pRet.initWithDuration(d);
  pRet.autorelease();
  Result := pRet;
end;

function CCDelayTime.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCDelayTime;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCDelayTime(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCDelayTime.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pNewZone.Free;

  Result := pRet;
end;

function CCDelayTime.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration);
end;

procedure CCDelayTime.update(time: Single);
begin

end;

{ CCTargetedAction }

class function CCTargetedAction._create(pTarget: CCObject;
  pAction: CCFiniteTimeAction): CCTargetedAction;
var
  pRet: CCTargetedAction;
begin
  pRet := CCTargetedAction.Create;
  pRet.initWithTarget(pTarget, pAction);
  pRet.autorelease();
  Result := pRet;
end;

function CCTargetedAction.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCTargetedAction;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCTargetedAction(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCTargetedAction.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithTarget(m_pForcedTarget, CCFiniteTimeAction(m_pAction.copy().autorelease()));

  pNewZone.Free;

  Result := pRet;
end;

constructor CCTargetedAction.Create;
begin
  inherited Create();
end;

destructor CCTargetedAction.Destroy;
begin
  CC_SAFE_RELEASE(m_pForcedTarget);
  CC_SAFE_RELEASE(m_pAction);
  inherited;
end;

function CCTargetedAction.initWithTarget(pTarget: CCObject;
  pAction: CCFiniteTimeAction): Boolean;
begin
  if inherited initWithDuration(pAction.getDuration()) then
  begin
    CC_SAFE_RETAIN(pTarget);
    m_pForcedTarget := pTarget;
    CC_SAFE_RETAIN(pAction);
    m_pAction := pAction;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCTargetedAction.stop;
begin
  m_pAction.stop();
end;

procedure CCTargetedAction.update(time: Single);
begin
  m_pAction.update(time);
end;

function CCTargetedAction.getForcedTarget: CCObject;
begin
  Result := m_pForcedTarget;
end;

procedure CCTargetedAction.setForcedTarget(const Value: CCObject);
begin
  if m_pForcedTarget <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pForcedTarget);
    m_pForcedTarget := Value;
  end;  
end;

procedure CCTargetedAction.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pAction.startWithTarget(m_pForcedTarget);
end;

{ CCSkewTo }

class function CCSkewTo._create(t, sx, sy: Single): CCSkewTo;
var
  pRet: CCSkewTo;
begin
  pRet := CCSkewTo.Create();
  if pRet <> nil then
  begin
    if pRet.initWithDuration(t, sx, sy) then
      pRet.autorelease()
    else
      CC_SAFE_DELETE(pRet);
  end;
  Result := pRet;
end;

function CCSkewTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCSkewTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCSkewTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCSkewTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fEndSkewX, m_fEndSkewY);   

  pNewZone.Free;

  Result := pRet;
end;

constructor CCSkewTo.Create;
begin
  inherited Create();
end;

function CCSkewTo.initWithDuration(t, sx, sy: Single): Boolean;
var
  bRet: Boolean;
begin
  bRet := False;
  if inherited initWithDuration(t) then
  begin
    m_fEndSkewX := sx;
    m_fEndSkewY := sy;
    bRet := True;
  end;
  Result := bRet;
end;

procedure CCSkewTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_fStartSkewX := CCNode(pTarget).SkewX;

  if m_fStartSkewX > 0 then
  begin
    m_fStartSkewX := fmodf(m_fStartSkewX, 180.0);
  end else
  begin
    m_fStartSkewX := fmodf(m_fStartSkewX, -180.0);
  end;

  m_fDeltaX := m_fEndSkewX - m_fStartSkewX;

  if m_fDeltaX > 180.0 then
    m_fDeltaX := m_fDeltaX - 360;
  if m_fDeltaX < -180.0 then
    m_fDeltaX := m_fDeltaX + 360;

  m_fStartSkewY := CCNode(pTarget).SkewY;
  if m_fStartSkewY > 0 then
  begin
    m_fStartSkewY := fmodf(m_fStartSkewY, 360.0)
  end else
  begin
    m_fStartSkewY := fmodf(m_fStartSkewY, -360.0)
  end;

  m_fDeltaY := m_fEndSkewY - m_fStartSkewY;

  if m_fDeltaY > 180.0 then
    m_fDeltaY := m_fDeltaY - 360;
  if m_fDeltaY < -180.0 then
    m_fDeltaY := m_fDeltaY + 360;
end;

procedure CCSkewTo.update(time: Single);
begin
  CCNode(m_pTarget).SkewX := m_fStartSkewX + m_fDeltaX * time;
  CCNode(m_pTarget).SkewY := m_fStartSkewY + m_fDeltaY * time;
end;

{ CCSkewBy }

class function CCSkewBy._create(t, sx, sy: Single): CCSkewBy;
var
  pRet: CCSkewBy;
begin
  pRet := CCSkewBy.Create();
  if pRet <> nil then
  begin
    if pRet.initWithDuration(t, sx, sy) then
      pRet.autorelease()
    else
      CC_SAFE_DELETE(pRet);
  end;
  Result := pRet;
end;

function CCSkewBy.initWithDuration(t, sx, sy: Single): Boolean;
var
  bRet: Boolean;
begin
  bRet := False;
  if inherited initWithDuration(t, sx, sy) then
  begin
    m_fSkewX := sx;
    m_fSkewY := sy;
    bRet := True;
  end;
  Result := bRet;
end;

function CCSkewBy.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, -m_fSkewX, -m_fSkewY);
end;

procedure CCSkewBy.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_fDeltaX := m_fSkewX;
  m_fDeltaY := m_fSkewY;
  m_fEndSkewX := m_fStartSkewX + m_fDeltaX;
  m_fEndSkewY := m_fStartSkewY + m_fDeltaY;
end;

{ CCSpawn }

class function CCSpawn._create(arrayOfActions: CCArray): CCFiniteTimeAction;
var
  prev: CCFiniteTimeAction;
  nCount, i: Integer;
begin
  nCount := arrayOfActions.count();
  if nCount < 1 then
  begin
    Result := nil;
    Exit;
  end;

  prev := CCFiniteTimeAction(arrayOfActions.objectAtIndex(0));
  for i := 1 to nCount-1 do
  begin
    prev := createWithTwoActions(prev, CCFiniteTimeAction(arrayOfActions.objectAtIndex(i)));
  end;
  Result := prev;
end;

class function CCSpawn._create(
  pActions: array of CCFiniteTimeAction): CCFiniteTimeAction;
var
  prev: CCFiniteTimeAction;
  nCount, i: Integer;
begin
  nCount := Length(pActions);
  if nCount < 1 then
  begin
    Result := nil;
    Exit;
  end;

  prev := pActions[0];
  for i := 1 to nCount-1 do
  begin
    prev := createWithTwoActions(prev, pActions[i]);
  end;
  Result := prev;
end;

function CCSpawn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCSpawn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCSpawn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCSpawn.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithTwoActions(CCFiniteTimeAction(m_pOne.copy().autorelease()),
    CCFiniteTimeAction(m_pTwo.copy().autorelease()));       

  pNewZone.Free;

  Result := pRet;
end;

class function CCSpawn.createWithTwoActions(pAction1,
  pAction2: CCFiniteTimeAction): CCSpawn;
var
  pSpawn: CCSpawn;
begin
  pSpawn := CCSpawn.Create();
  pSpawn.initWithTwoActions(pAction1, pAction2);
  pSpawn.autorelease();
  Result := pSpawn;
end;

destructor CCSpawn.Destroy;
begin
  CC_SAFE_RELEASE(m_pOne);
  CC_SAFE_RELEASE(m_pTwo);
  inherited;
end;

function CCSpawn.reverse: CCFiniteTimeAction;
begin
  Result := createWithTwoActions(m_pOne.reverse(), m_pTwo.reverse());
end;

procedure CCSpawn.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pOne.startWithTarget(pTarget);
  m_pTwo.startWithTarget(pTarget);
end;

procedure CCSpawn.stop;
begin
  m_pOne.stop();
  m_pTwo.stop();
  inherited stop();
end;

procedure CCSpawn.update(time: Single);
begin
  if m_pOne <> nil then
    m_pOne.update(time);
  if m_pTwo <> nil then
    m_pTwo.update(time);
end;

function CCSpawn.initWithTwoActions(pAction1,
  pAction2: CCFiniteTimeAction): Boolean;
var
  bRet: Boolean;
  d1, d2: Single;
begin
  CCAssert(pAction1 <> nil, '');
  CCAssert(pAction2 <> nil, '');

  bRet := False;
  d1 := pAction1.getDuration();
  d2 := pAction2.getDuration();

  if inherited initWithDuration(Max(d1, d2)) then
  begin
    m_pOne := pAction1;
    m_pTwo := pAction2;

    if d1 > d2 then
      m_pTwo := CCSequence._create([pAction2, CCDelayTime._create(d1 - d2)])
    else if d1 < d2 then
      m_pOne := CCSequence._create([pAction1, CCDelayTime._create(d2 - d1)]);

    m_pOne.retain();
    m_pTwo.retain();

    bRet := True;
  end;

  Result := bRet;
end;

{ CCBezierBy }

function bezierat(a, b, c, d, t: Single): Single;
begin
  Result := Power(1-t, 3) * a +
            3*t*Power(1-t, 2)*b +
            3*Power(t, 2)*(1-t)*c +
            Power(t, 3)*d;
end;  

class function CCBezierBy._create(t: Single;
  const c: ccBezierConfig): CCBezierBy;
var
  pRet: CCBezierBy;
begin
  pRet := CCBezierBy.Create();
  pRet.initWithDuration(t, c);
  pRet.autorelease();
  Result := pRet;
end;

function CCBezierBy.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCBezierBy;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCBezierBy(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCBezierBy.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_sConfig);

  pNewZone.Free;

  Result := pRet;
end;

function CCBezierBy.initWithDuration(t: Single;
  const c: ccBezierConfig): Boolean;
begin
  if inherited initWithDuration(t) then
  begin
    m_sConfig := c;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCBezierBy.reverse: CCFiniteTimeAction;
var
  r: ccBezierConfig;
  pAction: CCBezierBy;
begin
  r.endPosition := ccpNeg(m_sConfig.endPosition);
  r.controlPoint_1 := ccpAdd(m_sConfig.controlPoint_2, ccpNeg(m_sConfig.endPosition));
  r.controlPoint_2 := ccpAdd(m_sConfig.controlPoint_1, ccpNeg(m_sConfig.endPosition));

  pAction := CCBezierBy._create(m_fDuration, r);
  Result := pAction;
end;

procedure CCBezierBy.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_startPosition := CCNode(pTarget).getPosition();
  m_previousPosition := m_startPosition;
end;

procedure CCBezierBy.update(time: Single);
var
  xa, xb, xc, xd: Single;
  ya, yb, yc, yd: Single;
  x, y: Single;
begin
  if m_pTarget <> nil then
  begin
    xa := 0;
    xb := m_sConfig.controlPoint_1.x;
    xc := m_sConfig.controlPoint_2.x;
    xd := m_sConfig.endPosition.x;

    ya := 0;
    yb := m_sConfig.controlPoint_1.y;
    yc := m_sConfig.controlPoint_2.y;
    yd := m_sConfig.endPosition.y;

    x := bezierat(xa, xb, xc, xd, time);
    y := bezierat(ya, yb, yc, yd, time);
    CCNode(m_pTarget).setPosition(ccpAdd(m_startPosition, ccp(x, y)));
  end;
end;

{ CCBezierTo }

class function CCBezierTo._create(t: Single;
  const c: ccBezierConfig): CCBezierTo;
var
  pRet: CCBezierTo;
begin
  pRet := CCBezierTo.Create;
  pRet.initWithDuration(t, c);
  pRet.autorelease();
  Result := pRet;
end;

function CCBezierTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCBezierTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCBezierTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCBezierTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_sConfig);

  pNewZone.Free;

  Result := pRet;
end;

procedure CCBezierTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_sConfig.controlPoint_1 := ccpSub(m_sToConfig.controlPoint_1, m_startPosition);
  m_sConfig.controlPoint_2 := ccpSub(m_sToConfig.controlPoint_2, m_startPosition);
  m_sConfig.endPosition := ccpSub(m_sToConfig.endPosition, m_startPosition);
end;

function CCBezierTo.initWithDuration(t: Single;
  const c: ccBezierConfig): Boolean;
var
  bRet: Boolean;
begin
  bRet := True;
  if inherited initWithDuration(t, c) then
  begin
    m_sToConfig := c;
    bRet := True;
  end;
  Result := bRet;
end;

{ CCReverseTime }

class function CCReverseTime._create(
  pAction: CCFiniteTimeAction): CCReverseTime;
var
  pRet: CCReverseTime;
begin
  pRet := CCReverseTime.Create;
  pRet.initWithAction(pAction);
  pRet.autorelease();
  Result := pRet;
end;

function CCReverseTime.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCReverseTime;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCReverseTime(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCReverseTime.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithAction(CCFiniteTimeAction(m_pOther.copy().autorelease()));            

  pNewZone.Free;

  Result := pRet;
end;

constructor CCReverseTime.Create;
begin
  inherited Create();
end;

destructor CCReverseTime.Destroy;
begin
  CC_SAFE_RELEASE(m_pOther);
  inherited;
end;

function CCReverseTime.initWithAction(
  pAction: CCFiniteTimeAction): Boolean;
begin
  if inherited initWithDuration(pAction.getDuration()) then
  begin
    CC_SAFE_RETAIN(pAction);
    CC_SAFE_RELEASE(m_pOther);
    m_pOther := pAction;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCReverseTime.reverse: CCFiniteTimeAction;
begin
  Result := CCFiniteTimeAction(m_pOther.copy().autorelease());
end;

procedure CCReverseTime.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pOther.startWithTarget(pTarget);
end;

procedure CCReverseTime.stop;
begin
  m_pOther.stop();
  inherited stop();
end;

procedure CCReverseTime.update(time: Single);
begin
  if m_pOther <> nil then
  begin
    m_pOther.update(1 - time);
  end;
end;

{ CCAnimate }

class function CCAnimate._create(pAnimation: CCAnimation): CCAnimate;
var
  pRet: CCAnimate;
begin
  pRet := CCAnimate.Create();
  if (pRet <> nil) and pRet.initWithAnimation(pAnimation) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCAnimate.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCAnimate;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCAnimate(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCAnimate.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithAnimation(CCAnimation(m_pAnimation.copy().autorelease()));          

  pNewZone.Free;

  Result := pRet;
end;

function CCAnimate.getAnimation: CCAnimation;
begin
  Result := m_pAnimation;
end;

function CCAnimate.initWithAnimation(pAnimation: CCAnimation): Boolean;
var
  singleDuration, accumUnitsOfTime, newUnitOfTimeValue, value: Single;
  pFrames: CCArray;
  frame: CCAnimationFrame;
  i: Integer;
begin
  CCAssert( pAnimation<>nil, 'Animate: argument Animation must be non-NULL');

  singleDuration := pAnimation.Duration;
  if inherited initWithDuration(singleDuration * pAnimation.Loops) then
  begin
    m_nNextFrame := 0;
    setAnimation(pAnimation);
    m_pOrigFrame := nil;
    m_uExectureLoops := 0;

    m_pSplitTimes.reserve(pAnimation.Frames.count());

    accumUnitsOfTime := 0;
    newUnitOfTimeValue := singleDuration / pAnimation.TotalDelayUnits;

    pFrames := pAnimation.Frames;
    if (pFrames <> nil) and (pFrames.count() > 0) then
    begin
      for i := 0 to pFrames.Count()-1 do
      begin
        frame := CCAnimationFrame(pFrames.objectAtIndex(i));
        value := accumUnitsOfTime * newUnitOfTimeValue / singleDuration;
        accumUnitsOfTime := accumUnitsOfTime + frame.DelayUnits;
        m_pSplitTimes.push_back(value);
      end;
    end;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCAnimate.reverse: CCFiniteTimeAction;
var
  pOldArray, pNewArray: CCArray;
  pAniFrame: CCAnimationFrame;
  i: Cardinal;
  newAnim: CCAnimation;
begin
  pOldArray := m_pAnimation.Frames;
  pNewArray := CCArray.createWithCapacity(pOldArray.count());

  //CCARRAY_VERIFY_TYPE(pOldArray, CCAnimationFrame*);
  if pOldArray.count() > 0 then
  begin
    for i := 0 to pOldArray.count() - 1 do
    begin
      pAniFrame := CCAnimationFrame(pOldArray.objectAtIndex(i));
      if pAniFrame = nil then
        Break;

      pNewArray.addObject(CCAnimationFrame(pAniFrame.copy().autorelease()));
    end;
  end;

  newAnim := CCAnimation._create(pNewArray, m_pAnimation.DelayPerUnit, m_pAnimation.Loops);
  newAnim.RestoreOriginalFrame := m_pAnimation.RestoreOriginalFrame;
  Result := _create(newAnim);
end;

procedure CCAnimate.setAnimation(pValue: CCAnimation);
begin
  if m_pAnimation <> pValue then
  begin
    CC_SAFE_RETAIN(pValue);
    CC_SAFE_RELEASE(m_pAnimation);
    m_pAnimation := pValue;
  end;  
end;

procedure CCAnimate.startWithTarget(pTarget: CCObject);
var
  pSprite: CCSprite;
begin
  inherited startWithTarget(pTarget);
  pSprite := CCSprite(pTarget);
  CC_SAFE_RELEASE(m_pOrigFrame);

  if m_pAnimation.RestoreOriginalFrame then
  begin
    m_pOrigFrame := pSprite.displayFrame();
    m_pOrigFrame.retain();
  end;

  m_nNextFrame := 0;
  m_uExectureLoops := 0;
end;

procedure CCAnimate.stop;
begin
  if m_pAnimation.RestoreOriginalFrame and (m_pTarget <> nil) then
  begin
    CCSprite(m_pTarget).setDisplayFrame(m_pOrigFrame);
  end;  
  inherited stop();
end;

procedure CCAnimate.update(time: Single);
var
  loopNumber: Cardinal;
  frames: CCArray;
  numberofFrame: Cardinal;
  frameToDisplay: CCSpriteFrame;
  i: Cardinal;
  splitTime: Single;
  frame: CCAnimationFrame;
  dict: CCDictionary;
begin
  if time < 1.0 then
  begin
    time := time * m_pAnimation.Loops;
    loopNumber := Floor(time);
    if loopNumber > m_uExectureLoops then
    begin
      m_nNextFrame := 0;
      Inc(m_uExectureLoops);
    end;
    time := fmodf(time, 1.0);
  end;

  frames := m_pAnimation.Frames;
  numberofFrame := frames.count();

  for i := m_nNextFrame to numberofFrame - 1 do
  begin
    splitTime := m_pSplitTimes.Items[i];

    if splitTime <= time then
    begin
      frame := CCAnimationFrame(frames.objectAtIndex(i));
      frameToDisplay := frame.SpriteFrame;
      CCSprite(m_pTarget).setDisplayFrame(frameToDisplay);

      dict := frame.UserInfo;
      if dict <> nil then
      begin
      //nothing
      end;
      m_nNextFrame := i + 1;
    end else
    begin
      Break;
    end;  
  end;  
end;

constructor CCAnimate.Create;
begin
  inherited Create();
  m_pSplitTimes := TVectorFloat.Create;
end;

destructor CCAnimate.Destroy;
begin
  m_pSplitTimes.Free;
  CC_SAFE_RELEASE(m_pAnimation);
  CC_SAFE_RELEASE(m_pOrigFrame);
  inherited;
end;

end.
