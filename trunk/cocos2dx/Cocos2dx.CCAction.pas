(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2011      Zynga Inc.

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

unit Cocos2dx.CCAction;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCPlatformMacros, Cocos2dx.CCGeometry;

const kCCActionTagInvalid = -1;

type
  CCAction = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    
    //! return true if the action has finished
    function isDone(): Boolean; virtual;

    //! called before the action start. It will also set the target.
    procedure startWithTarget(pTarget: CCObject{CCNode}); virtual;

    (**
    called after the action has finished. It will set the 'target' to nil.
    IMPORTANT: You should never call "[action stop]" manually. Instead, use: "target->stopAction(action);"
    *)
    procedure stop(); virtual;

    //! called every frame with it's delta time. DON'T override unless you know what you are doing.
    procedure step(dt: Single); virtual;
    (**
    called once per frame. time a value between 0 and 1

    For example:
    - 0 means that the action just started
    - 0.5 means that the action is in the middle
    - 1 means that the action is over
    *)
    procedure update(time: Single); override;

    function getTarget(): CCObject;
    procedure setTarget(pTarget: CCObject);
    function getOriginalTarget(): CCObject;

    (** Set the original target, since target can be nil.
    Is the target that were used to run the action. Unless you are doing something complex, like CCActionManager, you should NOT call this method.
    The target is 'assigned', it is not 'retained'.
    @since v0.8.2
    *)
    procedure setOriginalTarget(pOriginalTarget: CCObject);

    function getTag(): Integer;
    procedure setTag(nTag: Integer);
    class function _create(): CCAction;
  protected
    m_pOriginalTarget: CCObject;

    (** The "target".
    The target will be set with the 'startWithTarget' method.
    When the 'stop' method is called, target will be set to nil.
    The target is 'assigned', it is not 'retained'.
    *)
    m_pTarget: CCObject;

    //** The action tag. An identifier of the action */
    m_nTag: Integer;
  public
  end;

  CCFiniteTimeAction = class(CCAction)
  public
    constructor Create();
    destructor Destroy(); override;
    function getDuration(): Single;
    procedure setDuration(duration: Single);
    function reverse(): CCFiniteTimeAction; virtual;
  protected
    m_fDuration: Single;
  end;

  (**
  @brief An interval action is an action that takes place within a certain period of time.
  It has an start time, and a finish time. The finish time is the parameter
  duration plus the start time.

  These CCActionInterval actions have some interesting properties, like:
  - They can run normally (default)
  - They can run reversed with the reverse method
  - They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.

  For example, you can simulate a Ping Pong effect running the action normally and
  then running it again in Reverse mode.

  Example:

  CCAction *pingPongAction = CCSequence::actions(action, action->reverse(), NULL);
  *)
  CCActionInterval = class(CCFiniteTimeAction)
  public
    class function _create(d: Single): CCActionInterval;
    function getElapsed(): Single;
    function initWithDuration(d: Single): Boolean;
    function isDone(): Boolean; override;
    procedure step(dt: Single); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    procedure setAmplitudeRate(amp: Single);
    function getAmplitudeRate(): Single;
  protected
    m_elapsed: Single;
    m_bFirstTick: Boolean;
  end;

  (**
  @brief Changes the speed of an action, making it take longer (speed>1)
  or less (speed<1) time.
  Useful to simulate 'slow motion' or 'fast forward' effect.
  @warning This action can't be Sequenceable because it is not an CCIntervalAction
  *)
  CCSpeed = class(CCAction)
  public
    constructor Create();
    destructor Destroy(); override;
    function getSpeed(): Single;
    procedure setSpeed(fSpeed: Single);
    function initWithAction(pAction: CCActionInterval; fSpeed: Single): Boolean;

    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure stop(); override;
    procedure step(dt: Single); override;
    function isDone(): Boolean; override;
    function reverse(): CCActionInterval; virtual;
    procedure setInnerAction(pAction: CCActionInterval);
    function getInnerAction(): CCActionInterval;
    class function _create(pAction: CCActionInterval; fSpeed: Single): CCSpeed;
  protected
    m_fSpeed: Single;
    m_pInnerAction: CCActionInterval;
  end;

  (**
  @brief CCFollow is an action that "follows" a node.

  Eg:
  layer->runAction(CCFollow::actionWithTarget(hero));

  Instead of using CCCamera as a "follower", use this action instead.
  @since v0.99.2
  *)
  CCFollow = class(CCAction)
  public
    constructor Create();
    destructor Destroy(); override;
    function isBoundarySet(): Boolean;
    procedure setBoundarySet(bValue: Boolean);
    function initWithTarget(pFollowedNode: CCObject{CCNode}; const rect: CCRect): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure stop(); override;
    procedure step(dt: Single); override;
    function isDone(): Boolean; override;

    (** creates the action with a set boundary,
    It will work with no boundary if @param rect is equal to CCRectZero.
    *)
    class function _create(pFollowNode: CCObject{CCNode}; const rect: CCRect): CCFollow;
  protected
    // node to follow
    m_pobFollowedNode: CCObject{CCNode};

    // whether camera should be limited to certain area
    m_bBoundarySet: Boolean;

    // if screen size is bigger than the boundary - update not needed
    m_bBoundaryFullyCovered: Boolean;
    m_obHalfScreenSize: CCPoint;
    m_obFullScreenSize: CCPoint;

    // world boundaries
    m_fLeftBoundary: Single;
    m_fRightBoundary: Single;
    m_fTopBoundary: Single;
    m_fBottomBoundary: Single;
  end;

implementation
uses
  Math,
  Cocos2dx.CCNode, Cocos2dx.CCCommon, Cocos2dx.CCDirector, Cocos2dx.CCPointExtension;

{ CCAction }

const NearToZero = 0.00000001;

class function CCAction._create: CCAction;
var
  pRet: CCAction;
begin
  pRet := CCAction.Create();
  pRet.autorelease();
  Result := pRet;
end;

function CCAction.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCAction;
begin
  pNewZone := nil;
  
  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCAction(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCAction.Create();
    pNewZone := CCZone.Create(pRet);
  end;
  pRet.m_nTag := m_nTag;
  pNewZone.Free;
  
  Result := pRet;
end;

constructor CCAction.Create;
begin
  inherited Create();

  m_pOriginalTarget := nil;
  m_pTarget := nil;
  m_nTag := kCCActionTagInvalid;
end;

destructor CCAction.Destroy;
begin

  inherited;
end;

function CCAction.getOriginalTarget: CCObject;
begin
  Result := m_pOriginalTarget;
end;

function CCAction.getTag: Integer;
begin
  Result := m_nTag;
end;

function CCAction.getTarget: CCObject;
begin
  Result := m_pTarget;
end;

function CCAction.isDone: Boolean;
begin
  Result := True;
end;

procedure CCAction.setOriginalTarget(pOriginalTarget: CCObject);
begin
  m_pOriginalTarget := pOriginalTarget;
end;

procedure CCAction.setTag(nTag: Integer);
begin
  m_nTag := nTag;
end;

procedure CCAction.setTarget(pTarget: CCObject);
begin
  m_pTarget := pTarget;
end;

procedure CCAction.startWithTarget(pTarget: CCObject);
begin
  CCAssert(pTarget is CCNode, 'pTarget is not CCNode');
  
  m_pOriginalTarget := pTarget;
  m_pTarget := pTarget;
end;

procedure CCAction.step(dt: Single);
begin
//override me
end;

procedure CCAction.stop;
begin
  m_pTarget := nil;
end;

procedure CCAction.update(time: Single);
begin
//override me
end;

{ CCFiniteTimeAction }

constructor CCFiniteTimeAction.Create;
begin
  inherited Create();
  m_fDuration := 0.0;
end;

destructor CCFiniteTimeAction.Destroy;
begin

  inherited;
end;

function CCFiniteTimeAction.getDuration: Single;
begin
  Result := m_fDuration;
end;

function CCFiniteTimeAction.reverse: CCFiniteTimeAction;
begin
  CCLog('cocos2d: FiniteTimeAction#reverse: Implement me', []);
  Result := nil;
end;

procedure CCFiniteTimeAction.setDuration(duration: Single);
begin
  m_fDuration := duration;
end;

{ CCActionInterval }

class function CCActionInterval._create(d: Single): CCActionInterval;
var
  pRet: CCActionInterval;
begin
  pRet := CCActionInterval.Create();
  pRet.initWithDuration(d);
  pRet.autorelease();
  Result := pRet;
end;

function CCActionInterval.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCActionInterval;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCActionInterval(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCActionInterval.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration);

  pNewZone.Free;

  Result := pRet;
end;

function CCActionInterval.getAmplitudeRate: Single;
begin
  Result := 0.0;
end;

function CCActionInterval.getElapsed: Single;
begin
  Result := m_elapsed;
end;

function CCActionInterval.initWithDuration(d: Single): Boolean;
begin
  m_fDuration := d;
  // prevent division by 0
  // This comparison could be in step:, but it might decrease the performance
  // by 3% in heavy based action games.
  if m_fDuration = 0 then
    m_fDuration := NearToZero;
  m_elapsed := 0;
  m_bFirstTick := True;
  Result := True;
end;

function CCActionInterval.isDone: Boolean;
begin
  Result := m_elapsed >= m_fDuration;
end;

function CCActionInterval.reverse: CCFiniteTimeAction;
begin
{    CCAssert(false, "CCIntervalAction: reverse not implemented.");
    return NULL;}
  Result := nil;
end;

procedure CCActionInterval.setAmplitudeRate(amp: Single);
begin
{    CC_UNUSED_PARAM(amp);
    // Abstract class needs implementation
    CCAssert(0, "");
}
end;

procedure CCActionInterval.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_elapsed := 0.0;
  m_bFirstTick := True;
end;

procedure CCActionInterval.step(dt: Single);
begin
  if m_bFirstTick then
  begin
    m_bFirstTick := False;
    m_elapsed := 0;
  end else
  begin
    m_elapsed := m_elapsed + dt;
  end;

  Self.update(  Max(0,
                      Min(1, m_elapsed / Max(m_fDuration, NearToZero)
                         )
                   )
             );
end;

{ CCSpeed }

class function CCSpeed._create(pAction: CCActionInterval;
  fSpeed: Single): CCSpeed;
var
  pRet: CCSpeed;
begin
  pRet := CCSpeed.Create();
  if (pRet <> nil) and (pRet.initWithAction(pAction, fSpeed)) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCSpeed.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCSpeed;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCSpeed(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCSpeed.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithAction(CCActionInterval(m_pInnerAction.copy().autorelease()), m_fSpeed);

  pNewZone.Free;

  Result := pRet;
end;

constructor CCSpeed.Create;
begin
  inherited Create();

  m_fSpeed := 0.0;
  m_pInnerAction := nil;
end;

destructor CCSpeed.Destroy;
begin
  CC_SAFE_RELEASE(m_pInnerAction);
  inherited;
end;

function CCSpeed.getInnerAction: CCActionInterval;
begin
  Result := m_pInnerAction;
end;

function CCSpeed.getSpeed: Single;
begin
  Result := m_fSpeed;
end;

function CCSpeed.initWithAction(pAction: CCActionInterval;
  fSpeed: Single): Boolean;
begin
  CCAssert(pAction <> nil, '');
  pAction.retain();
  m_pInnerAction := pAction;
  m_fSpeed := fSpeed;
  Result := True;
end;

function CCSpeed.isDone: Boolean;
begin
  Result := m_pInnerAction.isDone();
end;

function CCSpeed.reverse: CCActionInterval;
begin
  Result := CCActionInterval(CCSpeed._create(CCActionInterval(m_pInnerAction.reverse()), m_fSpeed));
end;

procedure CCSpeed.setInnerAction(pAction: CCActionInterval);
begin
  if m_pInnerAction <> pAction then
  begin
    CC_SAFE_RETAIN(pAction);
    CC_SAFE_RELEASE(m_pInnerAction);
    m_pInnerAction := pAction;
  end;  
end;

procedure CCSpeed.setSpeed(fSpeed: Single);
begin
  m_fSpeed := fSpeed;
end;

procedure CCSpeed.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pInnerAction.startWithTarget(pTarget);
end;

procedure CCSpeed.step(dt: Single);
begin
  m_pInnerAction.step(dt * m_fSpeed);
end;

procedure CCSpeed.stop;
begin
  m_pInnerAction.stop();
  inherited stop();
end;

{ CCFollow }

class function CCFollow._create(pFollowNode: CCObject;
  const rect: CCRect): CCFollow;
var
  pRet: CCFollow;
begin
  pRet := CCFollow.Create;
  if (pRet <> nil) and (pRet.initWithTarget(pFollowNode, rect)) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_RELEASE(pRet);
  Result := nil;
end;

function CCFollow.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFollow;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFollow(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFollow.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.m_nTag := m_nTag;

  pNewZone.Free;

  Result := pRet;
end;

constructor CCFollow.Create;
begin
  inherited Create();
end;

destructor CCFollow.Destroy;
begin
  CC_SAFE_RELEASE(m_pobFollowedNode);
  inherited;
end;

function CCFollow.initWithTarget(pFollowedNode: CCObject;
  const rect: CCRect): Boolean;
var
  winSize: CCSize;
begin
  CCAssert(pFollowedNode <> nil, '');

  pFollowedNode.retain();
  m_pobFollowedNode := pFollowedNode;
  if rect.equals(CCRectZero) then
    m_bBoundarySet := False
  else
    m_bBoundarySet := True;

  m_bBoundaryFullyCovered := False;

  winSize := CCDirector.sharedDirector().getWinSize();
  m_obFullScreenSize := CCPointMake(winSize.width, winSize.height);
  m_obHalfScreenSize := ccpMult(m_obFullScreenSize, 0.5);

  if m_bBoundarySet then
  begin
    m_fLeftBoundary := -(rect.origin.x + rect.size.width - m_obFullScreenSize.x);
    m_fRightBoundary := -rect.origin.x;
    m_fTopBoundary := -rect.origin.y;
    m_fBottomBoundary := -(rect.origin.y + rect.size.height - m_obFullScreenSize.y);

    if m_fRightBoundary < m_fLeftBoundary then
    begin
      m_fLeftBoundary := (m_fLeftBoundary + m_fRightBoundary) / 2;
      m_fRightBoundary := m_fLeftBoundary;
    end;
    if m_fTopBoundary < m_fBottomBoundary then
    begin
      m_fBottomBoundary := (m_fTopBoundary + m_fBottomBoundary) / 2;
      m_fTopBoundary := m_fBottomBoundary;
    end;
    if (m_fTopBoundary = m_fBottomBoundary) and (m_fLeftBoundary = m_fRightBoundary) then
    begin
      m_bBoundaryFullyCovered := True;
    end;  
  end;

  Result := True;
end;

function CCFollow.isBoundarySet: Boolean;
begin
  Result := m_bBoundarySet;
end;

function CCFollow.isDone: Boolean;
begin
  Result := not CCNode(m_pobFollowedNode).isRunning();
end;

procedure CCFollow.setBoundarySet(bValue: Boolean);
begin
  m_bBoundarySet := bValue;
end;

procedure CCFollow.step(dt: Single);
var
  tempPos: CCPoint;
begin
  if m_bBoundarySet then
  begin
    // whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
    if m_bBoundaryFullyCovered then
      Exit;

    tempPos := ccpSub(m_obHalfScreenSize, CCNode(m_pobFollowedNode).getPosition());
    CCNode(m_pTarget).setPosition( ccp(clampf(tempPos.x, m_fLeftBoundary, m_fRightBoundary), clampf(tempPos.y, m_fBottomBoundary, m_fTopBoundary)) );
  end else
  begin
    CCNode(m_pTarget).setPosition(ccpSub(m_obHalfScreenSize, CCNode(m_pobFollowedNode).getPosition() ));
  end;   
end;

procedure CCFollow.stop;
begin
  m_pTarget := nil;
  inherited stop();
end;

end.
