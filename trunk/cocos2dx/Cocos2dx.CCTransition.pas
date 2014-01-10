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

unit Cocos2dx.CCTransition;

interface

{$I config.inc}

uses
  Cocos2dx.CCObject, Cocos2dx.CCScene, Cocos2dx.CCAction, Cocos2dx.CCActionInterval,
  Cocos2dx.CCActionInstant, Cocos2dx.CCGeometry, Cocos2dx.CCTypes;

type
  CCTransitionEaseScene = interface
    function easeActionWithAction(action: CCActionInterval): CCActionInterval;
  end;

  tOrientation =
  (
    kCCTransitionOrientationLeftOver = 0,
    /// An horizontal orientation where the Right is nearer
    kCCTransitionOrientationRightOver = 1,
    /// A vertical orientation where the Up is nearer
    kCCTransitionOrientationUpOver = 0,
    /// A vertical orientation where the Bottom is nearer
    kCCTransitionOrientationDownOver = 1
  );

  CCTransitionScene = class(CCScene)
  protected
    m_pInScene: CCScene;
    m_pOutScene: CCScene;
    m_fDuration: Single;
    m_bIsInSceneOnTop: Boolean;
    m_bIsSendCleanupToScene: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure draw(); override;
    procedure onEnter(); override;
    procedure onExit(); override;
    procedure cleanup(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionScene;
    function initWithDuration(t: Single; scene: CCScene): Boolean;
    procedure finish();
    procedure hideOutShowIn();
  protected
    procedure sceneOrder(); virtual;
  private
    procedure setNewScene(dt: Single);
  end;

  CCTransitionSceneOriented = class(CCTransitionScene)
  protected
    m_eOrientation: tOrientation;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(t: Single; scene: CCScene; orientation: tOrientation): CCTransitionSceneOriented;
    function initWithDuration(t: Single; scene: CCScene; orientation: tOrientation): Boolean;
  end;

  CCTransitionRotoZoom = class(CCTransitionScene)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionRotoZoom;
  end;

  CCTransitionJumpZoom = class(CCTransitionScene)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionJumpZoom;
  end;

  CCTransitionMoveInL = class(CCTransitionScene, CCTransitionEaseScene)
  public
    constructor Create();
    destructor Destroy(); override;
    function easeActionWithAction(action: CCActionInterval): CCActionInterval;
    procedure initScenes(); virtual;
    function action(): CCActionInterval; virtual;
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionMoveInL;
  end;

  CCTransitionMoveInR = class(CCTransitionMoveInL)
  public
    procedure initScenes(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionMoveInR;
  end;

  CCTransitionMoveInT = class(CCTransitionMoveInL)
  public
    procedure initScenes(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionMoveInT;
  end;

  CCTransitionMoveInB = class(CCTransitionMoveInL)
  public
    procedure initScenes(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionMoveInB;
  end;

  CCTransitionSlideInL = class(CCTransitionScene, CCTransitionEaseScene)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionSlideInL;
    function easeActionWithAction(action: CCActionInterval): CCActionInterval;
    procedure onEnter(); override;
    procedure initScenes(); virtual;
    function action(): CCActionInterval; virtual;
  protected
    procedure sceneOrder(); override;
  end;

  CCTransitionSlideInR = class(CCTransitionSlideInL)
  public
    procedure initScenes(); override;
    function action(): CCActionInterval; override;
    class function _create(t: Single; scene: CCScene): CCTransitionSlideInR;
  protected
    procedure sceneOrder(); override;
  end;

  CCTransitionSlideInB = class(CCTransitionSlideInL)
  public
    procedure initScenes(); override;
    function action(): CCActionInterval; override;
    class function _create(t: Single; scene: CCScene): CCTransitionSlideInB;
  protected
    procedure sceneOrder(); override;
  end;

  CCTransitionSlideInT = class(CCTransitionSlideInL)
  public
    procedure initScenes(); override;
    function action(): CCActionInterval; override;
    class function _create(t: Single; scene: CCScene): CCTransitionSlideInT;
  protected
    procedure sceneOrder(); override;
  end;

  CCTransitionShrinkGrow = class(CCTransitionScene, CCTransitionEaseScene)
  public
    function easeActionWithAction(action: CCActionInterval): CCActionInterval;
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionShrinkGrow;
  end;

  CCTransitionFlipX = class(CCTransitionSceneOriented)
  public
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionFlipX; overload;
    class function _create(t: Single; scene: CCScene; o: tOrientation): CCTransitionFlipX; overload;
  end;

  CCTransitionFlipY = class(CCTransitionSceneOriented)
  public
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionFlipY; overload;
    class function _create(t: Single; scene: CCScene; o: tOrientation): CCTransitionFlipY; overload;
  end;

  CCTransitionFlipAngular = class(CCTransitionSceneOriented)
  public
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionFlipAngular; overload;
    class function _create(t: Single; scene: CCScene; o: tOrientation): CCTransitionFlipAngular; overload;
  end;

  CCTransitionZoomFlipX = class(CCTransitionSceneOriented)
  public
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionZoomFlipX; overload;
    class function _create(t: Single; scene: CCScene; o: tOrientation): CCTransitionZoomFlipX; overload;
  end;

  CCTransitionZoomFlipY = class(CCTransitionSceneOriented)
  public
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionZoomFlipY; overload;
    class function _create(t: Single; scene: CCScene; o: tOrientation): CCTransitionZoomFlipY; overload;
  end;

  CCTransitionZoomFlipAngular = class(CCTransitionSceneOriented)
  public
    procedure onEnter(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionZoomFlipAngular; overload;
    class function _create(t: Single; scene: CCScene; o: tOrientation): CCTransitionZoomFlipAngular; overload;
  end;

  CCTransitionFade = class(CCTransitionScene)
  public
    class function _create(t: Single; scene: CCScene; const color: ccColor3B): CCTransitionFade; overload;
    class function _create(t: Single; scene: CCScene): CCTransitionFade; overload;
    function initWithDuration(t: Single; scene: CCScene): Boolean; overload;
    function initWithDuration(t: Single; scene: CCScene; const color: ccColor3B): Boolean; overload;
    procedure onEnter(); override;
    procedure onExit(); override;
  protected
    m_tColor: ccColor4B;
  end;

  CCTransitionCrossFade = class(CCTransitionScene)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionCrossFade;
    procedure onEnter(); override;
    procedure onExit(); override;
    procedure draw(); override;
  end;

  CCTransitionTurnOffTiles = class(CCTransitionScene, CCTransitionEaseScene)
  public
    procedure onEnter(); override;
    function easeActionWithAction(action: CCActionInterval): CCActionInterval;
    procedure sceneOrder(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionTurnOffTiles;
  end;

  CCTransitionSplitCols = class(CCTransitionScene, CCTransitionEaseScene)
  public
    procedure onEnter(); override;
    function action(): CCActionInterval; virtual;
    function easeActionWithAction(action: CCActionInterval): CCActionInterval;
    class function _create(t: Single; scene: CCScene): CCTransitionSplitCols;
  end;

  CCTransitionSplitRows = class(CCTransitionSplitCols)
  public
    function action(): CCActionInterval; override;
    class function _create(t: Single; scene: CCScene): CCTransitionSplitRows;
  end;

  CCTransitionFadeTR = class(CCTransitionScene, CCTransitionEaseScene)
  public
    procedure onEnter(); override;
    function actionWithSize(const size: CCSize): CCActionInterval; virtual;
    function easeActionWithAction(action: CCActionInterval): CCActionInterval;
    class function _create(t: Single; scene: CCScene): CCTransitionFadeTR;
    procedure sceneOrder(); override;
  end;

  CCTransitionFadeBL = class(CCTransitionFadeTR)
  public
    function actionWithSize(const size: CCSize): CCActionInterval; override;
    class function _create(t: Single; scene: CCScene): CCTransitionFadeBL;
  end;

  CCTransitionFadeUp = class(CCTransitionFadeTR)
  public
    function actionWithSize(const size: CCSize): CCActionInterval; override;
    class function _create(t: Single; scene: CCScene): CCTransitionFadeUp;
  end;

  CCTransitionFadeDown = class(CCTransitionFadeTR)
  public
    function actionWithSize(const size: CCSize): CCActionInterval; override;
    class function _create(t: Single; scene: CCScene): CCTransitionFadeDown;
  end;


implementation
uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCPointExtension, Cocos2dx.CCDirector, Cocos2dx.CCTouchDispatcher,
  Cocos2dx.CCLayer, Cocos2dx.CCRenderTexture, Cocos2dx.CCPlatformMacros,
  Cocos2dx.CCActionEase, Cocos2dx.CCActionCamera, Cocos2dx.CCNode,
  Cocos2dx.CCActionTiledGrid, Cocos2dx.CCActionGrid;


const kSceneFade = $FADE;

{ CCTransitionScene }

class function CCTransitionScene._create(t: Single;
  scene: CCScene): CCTransitionScene;
var
  pRet: CCTransitionScene;
begin
  pRet := CCTransitionScene.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCTransitionScene.cleanup;
begin
  inherited cleanup();
  if m_bIsSendCleanupToScene then
    m_pOutScene.cleanup();
end;

constructor CCTransitionScene.Create;
begin
  inherited Create();
end;

destructor CCTransitionScene.Destroy;
begin
  m_pInScene.release();
  m_pOutScene.release();
  inherited;
end;

procedure CCTransitionScene.draw;
begin
  inherited draw();
  if m_bIsInSceneOnTop then
  begin
    m_pOutScene.visit();
    m_pInScene.visit();
  end else
  begin
    m_pInScene.visit();
    m_pOutScene.visit();
  end;    
end;

procedure CCTransitionScene.finish;
begin
  m_pInScene.setVisible(True);
  m_pInScene.setPosition(ccp(0, 0));
  m_pInScene.Scale := 1.0;
  m_pInScene.Rotation := 0.0;
  m_pInScene.Camera.restore();

  m_pOutScene.setVisible(False);
  m_pOutScene.setPosition(ccp(0, 0));
  m_pOutScene.Scale := 1.0;
  m_pOutScene.Rotation := 0.0;
  m_pOutScene.Camera.restore();

  schedule(setNewScene, 0);
end;

procedure CCTransitionScene.hideOutShowIn;
begin
  m_pInScene.setVisible(True);
  m_pOutScene.setVisible(False);
end;

function CCTransitionScene.initWithDuration(t: Single;
  scene: CCScene): Boolean;
begin
  CCAssert(scene <> nil, 'Argument scene must be non-nil');
  if inherited init() then
  begin
    m_fDuration := t;

    m_pInScene := scene;
    m_pInScene.retain();
    m_pOutScene := CCDirector.sharedDirector().getRunningScene();
    if m_pOutScene = nil then
    begin
      m_pOutScene := CCScene._create();
      m_pOutScene.init();
    end;
    m_pOutScene.retain();

    CCAssert(m_pInScene <> m_pOutScene, 'Incoming scene must be different from the outgoing scene');

    sceneOrder();
    
    Result := True;
    Exit;
  end;  
  Result := False;
end;

procedure CCTransitionScene.onEnter;
begin
  inherited onEnter();
  CCDirector.sharedDirector().TouchDispatcher.setDispatchEvents(False);
  m_pOutScene.onExitTransitionDidStart();
  m_pInScene.onEnter();
end;

procedure CCTransitionScene.onExit;
begin
  inherited onExit();
  CCDirector.sharedDirector().TouchDispatcher.setDispatchEvents(True);
  m_pOutScene.onExit();
  m_pInScene.onEnterTransitionDidFinish();
end;

procedure CCTransitionScene.sceneOrder;
begin
  m_bIsInSceneOnTop := True;
end;

procedure CCTransitionScene.setNewScene(dt: Single);
var
  director: CCDirector;
begin
  unschedule(setNewScene);
  director := CCDirector.sharedDirector();
  m_bIsSendCleanupToScene := director.isSendCleanupToScene();
  director.replaceScene(m_pInScene);
  m_pOutScene.setVisible(True);
end;

{ CCTransitionSceneOriented }

class function CCTransitionSceneOriented._create(t: Single; scene: CCScene;
  orientation: tOrientation): CCTransitionSceneOriented;
var
  pRet: CCTransitionSceneOriented;
begin
  pRet := CCTransitionSceneOriented.Create();
  pRet.initWithDuration(t, scene, orientation);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCTransitionSceneOriented.Create;
begin
  inherited Create();
end;

destructor CCTransitionSceneOriented.Destroy;
begin

  inherited;
end;

function CCTransitionSceneOriented.initWithDuration(t: Single;
  scene: CCScene; orientation: tOrientation): Boolean;
begin
  if inherited initWithDuration(t, scene) then
    m_eOrientation := orientation;
  Result := True;
end;

{ CCTransitionRotoZoom }

class function CCTransitionRotoZoom._create(t: Single;
  scene: CCScene): CCTransitionRotoZoom;
var
  pRet: CCTransitionRotoZoom;
begin
  pRet := CCTransitionRotoZoom.Create();
  pRet.initWithDuration(t, scene);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCTransitionRotoZoom.Create;
begin
  inherited Create();
end;

destructor CCTransitionRotoZoom.Destroy;
begin

  inherited;
end;

procedure CCTransitionRotoZoom.onEnter;
var
  rotozoom: CCFiniteTimeAction;
begin
  inherited onEnter();

  m_pInScene.Scale := 0.001;
  m_pOutScene.Scale := 1.0;

  m_pInScene.AnchorPoint := ccp(0.5, 0.5);
  m_pOutScene.AnchorPoint := ccp(0.5, 0.5);

  rotozoom := CCSequence._create([
      CCSpawn._create([CCScaleBy._create(m_fDuration/2.0, 0.001),
                       CCRotateBy._create(m_fDuration/2, 360*2) ]),
      CCDelayTime._create(m_fDuration/2) ]);
  m_pOutScene.runAction(rotozoom);

  m_pInScene.runAction( CCSequence._create([rotozoom.reverse(),
                                           CCCallFunc._create(Self, finish)]) );
end;

{ CCTransitionJumpZoom }

class function CCTransitionJumpZoom._create(t: Single;
  scene: CCScene): CCTransitionJumpZoom;
var
  pRet: CCTransitionJumpZoom;
begin
  pRet := CCTransitionJumpZoom.Create();
  pRet.initWithDuration(t, scene);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCTransitionJumpZoom.Create;
begin
  inherited Create();
end;

destructor CCTransitionJumpZoom.Destroy;
begin

  inherited;
end;

procedure CCTransitionJumpZoom.onEnter;
var
  s: CCSize;
  jump, scalIn, scaleOut, jumpZoomOut, jumpZoomIn, delay: CCFiniteTimeAction;
begin
  inherited onEnter();
  s := CCDirector.sharedDirector().getWinSize();

  m_pInScene.Scale := 0.5;
  m_pInScene.setPosition(ccp(s.width, 0));
  m_pInScene.AnchorPoint := ccp(0.5, 0.5);
  m_pOutScene.AnchorPoint := ccp(0.5, 0.5);

  jump := CCJumpBy._create(m_fDuration/4, ccp(-s.width, 0), s.width/4, 2);
  scalIn := CCScaleTo._create(m_fDuration/4, 1.0);
  scaleOut := CCScaleTo._create(m_fDuration/4, 0.5);

  jumpZoomOut := CCSequence._create([scaleOut, jump]);
  jumpZoomIn := CCSequence._create([jump, scalIn]);

  delay := CCDelayTime._create(m_fDuration/2);

  m_pOutScene.runAction(jumpZoomOut);
  m_pInScene.runAction( CCSequence._create([delay, jumpZoomIn, CCCallFunc._create(Self, finish)]) );
end;

{ CCTransitionMoveInL }

class function CCTransitionMoveInL._create(t: Single;
  scene: CCScene): CCTransitionMoveInL;
var
  pRet: CCTransitionMoveInL;
begin
  pRet := CCTransitionMoveInL.Create();
  pRet.initWithDuration(t, scene);
  pRet.autorelease();
  Result := pRet;
end;

function CCTransitionMoveInL.action: CCActionInterval;
begin
  Result := CCMoveTo._create(m_fDuration, ccp(0, 0));
end;

constructor CCTransitionMoveInL.Create;
begin
  inherited Create();
end;

destructor CCTransitionMoveInL.Destroy;
begin

  inherited;
end;

function CCTransitionMoveInL.easeActionWithAction(
  action: CCActionInterval): CCActionInterval;
begin
  Result := CCEaseOut._create(action, 2.0);
end;

procedure CCTransitionMoveInL.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition(ccp(-s.width, 0));
end;

procedure CCTransitionMoveInL.onEnter;
var
  a: CCActionInterval;
begin
  inherited onEnter();
  Self.initScenes();

  a := Self.action();
  m_pInScene.runAction( CCSequence._create([Self.easeActionWithAction(a), CCCallFunc._create(Self, finish)]) );
end;

{ CCTransitionMoveInR }

class function CCTransitionMoveInR._create(t: Single;
  scene: CCScene): CCTransitionMoveInR;
var
  pRet: CCTransitionMoveInR;
begin
  pRet := CCTransitionMoveInR.Create();
  pRet.initWithDuration(t, scene);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionMoveInR.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition(ccp(s.width, 0));
end;

{ CCTransitionMoveInT }

class function CCTransitionMoveInT._create(t: Single;
  scene: CCScene): CCTransitionMoveInT;
var
  pRet: CCTransitionMoveInT;
begin
  pRet := CCTransitionMoveInT.Create();
  pRet.initWithDuration(t, scene);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionMoveInT.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition(ccp(0, s.height));
end;

{ CCTransitionMoveInB }

class function CCTransitionMoveInB._create(t: Single;
  scene: CCScene): CCTransitionMoveInB;
var
  pRet: CCTransitionMoveInB;
begin
  pRet := CCTransitionMoveInB.Create();
  pRet.initWithDuration(t, scene);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionMoveInB.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition(ccp(0, -s.height));
end;

{ CCTransitionSlideInL }

const ADJUST_FACTOR = 0.5;

class function CCTransitionSlideInL._create(t: Single;
  scene: CCScene): CCTransitionSlideInL;
var
  pRet: CCTransitionSlideInL;
begin
  pRet := CCTransitionSlideInL.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionSlideInL.action: CCActionInterval;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  Result := CCMoveBy._create(m_fDuration, ccp(s.width - ADJUST_FACTOR, 0));
end;

function CCTransitionSlideInL.easeActionWithAction(
  action: CCActionInterval): CCActionInterval;
begin
  Result := CCEaseOut._create(action, 2.0);
end;

procedure CCTransitionSlideInL.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition( ccp( -(s.width - ADJUST_FACTOR), 0 ) );
end;

procedure CCTransitionSlideInL.onEnter;
var
  _in, _out: CCActionInterval;
  inAction, outAction: CCActionInterval;
begin
  inherited onEnter();
  Self.initScenes();
  _in := Self.action();
  _out := Self.action();

  inAction := easeActionWithAction(_in);
  outAction := CCActionInterval(CCSequence._create([easeActionWithAction(_out), CCCallFunc._create(Self, finish) ]));

  m_pInScene.runAction(inAction);
  m_pOutScene.runAction(outAction);
end;

procedure CCTransitionSlideInL.sceneOrder;
begin
  m_bIsInSceneOnTop := False;
end;

{ CCTransitionSlideInR }

class function CCTransitionSlideInR._create(t: Single;
  scene: CCScene): CCTransitionSlideInR;
var
  pRet: CCTransitionSlideInR;
begin
  pRet := CCTransitionSlideInR.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionSlideInR.action: CCActionInterval;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  Result := CCMoveBy._create(m_fDuration, ccp(-(s.width - ADJUST_FACTOR), 0));
end;

procedure CCTransitionSlideInR.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition( ccp( (s.width - ADJUST_FACTOR), 0 ) );
end;

procedure CCTransitionSlideInR.sceneOrder;
begin
  m_bIsInSceneOnTop := True;
end;

{ CCTransitionSlideInB }

class function CCTransitionSlideInB._create(t: Single;
  scene: CCScene): CCTransitionSlideInB;
var
  pRet: CCTransitionSlideInB;
begin
  pRet := CCTransitionSlideInB.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionSlideInB.action: CCActionInterval;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  Result := CCMoveBy._create(m_fDuration, ccp(0, s.height - ADJUST_FACTOR));
end;

procedure CCTransitionSlideInB.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition( ccp(0,  -(s.height - ADJUST_FACTOR)) );
end;

procedure CCTransitionSlideInB.sceneOrder;
begin
  m_bIsInSceneOnTop := True;
end;

{ CCTransitionSlideInT }

class function CCTransitionSlideInT._create(t: Single;
  scene: CCScene): CCTransitionSlideInT;
var
  pRet: CCTransitionSlideInT;
begin
  pRet := CCTransitionSlideInT.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionSlideInT.action: CCActionInterval;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  Result := CCMoveBy._create(m_fDuration, ccp(0, -(s.height - ADJUST_FACTOR)));
end;

procedure CCTransitionSlideInT.initScenes;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  m_pInScene.setPosition( ccp(0,  s.height - ADJUST_FACTOR) );
end;

procedure CCTransitionSlideInT.sceneOrder;
begin
  m_bIsInSceneOnTop := True;
end;

{ CCTransitionShrinkGrow }

class function CCTransitionShrinkGrow._create(t: Single;
  scene: CCScene): CCTransitionShrinkGrow;
var
  pRet: CCTransitionShrinkGrow;
begin
  pRet := CCTransitionShrinkGrow.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionShrinkGrow.easeActionWithAction(
  action: CCActionInterval): CCActionInterval;
begin
  Result := CCEaseOut._create(action, 2.0);
end;

procedure CCTransitionShrinkGrow.onEnter;
var
  scaleOut, scaleIn: CCFiniteTimeAction;
begin
  inherited onEnter();

  m_pInScene.Scale := 0.001;
  m_pOutScene.Scale := 1.0;

  m_pInScene.AnchorPoint := ccp(2/3, 0.5);
  m_pOutScene.AnchorPoint := ccp(1/3, 0.5);

  scaleOut := CCScaleTo._create(m_fDuration, 0.01);
  scaleIn := CCScaleTo._create(m_fDuration, 1.0);

  m_pInScene.runAction(Self.easeActionWithAction(CCActionInterval(scaleIn)));
  m_pOutScene.runAction( CCSequence._create([Self.easeActionWithAction(CCActionInterval(scaleOut)),
                                             CCCallFunc._create(Self, finish)]) );
end;

{ CCTransitionFlipX }

class function CCTransitionFlipX._create(t: Single;
  scene: CCScene): CCTransitionFlipX;
begin
  Result := Self._create(t, scene, kCCTransitionOrientationRightOver);
end;

class function CCTransitionFlipX._create(t: Single; scene: CCScene;
  o: tOrientation): CCTransitionFlipX;
var
  pRet: CCTransitionFlipX;
begin
  pRet := CCTransitionFlipX.Create();
  pRet.initWithDuration(t, scene, o);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionFlipX.onEnter;
var
  inA, outA: CCFiniteTimeAction;
  inDeltaZ, inAngleZ, outDeltaZ, outAngleZ: Single;
begin
  inherited onEnter();

  m_pInScene.setVisible(False);

  if m_eOrientation = kCCTransitionOrientationRightOver then
  begin
    inDeltaZ := 90;
    inAngleZ := 270;
    outDeltaZ := 90;
    outAngleZ := 0;
  end else
  begin
    inDeltaZ := -90;
    inAngleZ := 90;
    outDeltaZ := -90;
    outAngleZ := 0;
  end;

  inA := CCSequence._create([
    CCDelayTime._create(m_fDuration/2),
    CCShow._create(),
    CCOrbitCamera._create(m_fDuration/2, 1, 0, inAngleZ, inDeltaZ, 0, 0),
    CCCallFunc._create(Self, finish)
    ]);
  outA := CCSequence._create([
    CCOrbitCamera._create(m_fDuration/2, 1, 0, outAngleZ, outDeltaZ, 0, 0),
    CCHide._create(),
    CCDelayTime._create(m_fDuration/2)
    ]);

  m_pInScene.runAction(inA);
  m_pOutScene.runAction(outA);
end;

{ CCTransitionFlipY }

class function CCTransitionFlipY._create(t: Single;
  scene: CCScene): CCTransitionFlipY;
begin
  Result := Self._create(t, scene, kCCTransitionOrientationUpOver);
end;

class function CCTransitionFlipY._create(t: Single; scene: CCScene;
  o: tOrientation): CCTransitionFlipY;
var
  pRet: CCTransitionFlipY;
begin
  pRet := CCTransitionFlipY.Create();
  pRet.initWithDuration(t, scene, o);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionFlipY.onEnter;
var
  inA, outA: CCFiniteTimeAction;
  inDeltaZ, inAngleZ, outDeltaZ, outAngleZ: Single;
begin
  inherited onEnter();
  m_pInScene.Visible := False;

  if m_eOrientation = kCCTransitionOrientationUpOver then
  begin
    inDeltaZ := 90;
    inAngleZ := 270;
    outDeltaZ := 90;
    outAngleZ := 0;
  end else
  begin
    inDeltaZ := -90;
    inAngleZ := 90;
    outDeltaZ := -90;
    outAngleZ := 0;
  end;

  inA := CCSequence._create([
                    CCDelayTime._create(m_fDuration/2),
                    CCShow._create(),
                    CCOrbitCamera._create(m_fDuration/2, 1, 0, inAngleZ, inDeltaZ, 90, 0),
                    CCCallFunc._create(Self, finish) ]);
  outA := CCSequence._create([
                    CCOrbitCamera._create(m_fDuration/2, 1, 0, outAngleZ, outDeltaZ, 90, 0),
                    CCHide._create(),
                    CCDelayTime._create(m_fDuration/2) ]);

  m_pInScene.runAction(inA);
  m_pOutScene.runAction(outA);
end;

{ CCTransitionFlipAngular }

class function CCTransitionFlipAngular._create(t: Single;
  scene: CCScene): CCTransitionFlipAngular;
begin
  Result := Self._create(t, scene, kCCTransitionOrientationRightOver);
end;

class function CCTransitionFlipAngular._create(t: Single; scene: CCScene;
  o: tOrientation): CCTransitionFlipAngular;
var
  pRet: CCTransitionFlipAngular;
begin
  pRet := CCTransitionFlipAngular.Create();
  pRet.initWithDuration(t, scene, o);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionFlipAngular.onEnter;
var
  inA, outA: CCFiniteTimeAction;
  inDeltaZ, inAngleZ, outDeltaZ, outAngleZ: Single;
begin
  inherited onEnter();
  m_pInScene.Visible := False;

  if m_eOrientation = kCCTransitionOrientationRightOver then
  begin
    inDeltaZ := 90;
    inAngleZ := 270;
    outDeltaZ := 90;
    outAngleZ := 0;
  end else
  begin
    inDeltaZ := -90;
    inAngleZ := 90;
    outDeltaZ := -90;
    outAngleZ := 0;
  end;

  inA := CCSequence._create([
                    CCDelayTime._create(m_fDuration/2),
                    CCShow._create(),
                    CCOrbitCamera._create(m_fDuration/2, 1, 0, inAngleZ, inDeltaZ, -45, 0),
                    CCCallFunc._create(Self, finish) ]);
  outA := CCSequence._create([
                    CCOrbitCamera._create(m_fDuration/2, 1, 0, outAngleZ, outDeltaZ, 45, 0),
                    CCHide._create(),
                    CCDelayTime._create(m_fDuration/2) ]);
  m_pInScene.runAction(inA);
  m_pOutScene.runAction(outA);
end;

{ CCTransitionZoomFlipX }

class function CCTransitionZoomFlipX._create(t: Single;
  scene: CCScene): CCTransitionZoomFlipX;
begin
  Result := Self._create(t, scene, kCCTransitionOrientationRightOver);
end;

class function CCTransitionZoomFlipX._create(t: Single; scene: CCScene;
  o: tOrientation): CCTransitionZoomFlipX;
var
  pRet: CCTransitionZoomFlipX;
begin
  pRet := CCTransitionZoomFlipX.Create();
  pRet.initWithDuration(t, scene, o);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionZoomFlipX.onEnter;
var
  inA, outA: CCFiniteTimeAction;
  inDeltaZ, inAngleZ, outDeltaZ, outAngleZ: Single;
begin
  inherited onEnter();

  m_pInScene.Visible := False;
  if m_eOrientation = kCCTransitionOrientationRightOver then
  begin
    inDeltaZ := 90;
    inAngleZ := 270;
    outDeltaZ := 90;
    outAngleZ := 0;
  end else
  begin
    inDeltaZ := -90;
    inAngleZ := 90;
    outDeltaZ := -90;
    outAngleZ := 0;
  end;

  inA := CCSequence._create([
                    CCDelayTime._create(m_fDuration/2),
                    CCSpawn._create([
                            CCOrbitCamera._create(m_fDuration/2, 1, 0, inAngleZ, inDeltaZ, 0, 0),
                            CCScaleTo._create(m_fDuration/2, 1),
                            CCShow._create() ]),
                    CCCallFunc._create(Self, finish) ]);
  outA := CCSequence._create([
                    CCSpawn._create([
                            CCOrbitCamera._create(m_fDuration/2, 1, 0, outAngleZ, outDeltaZ, 0, 0),
                            CCScaleTo._create(m_fDuration/2, 0.5) ]),
                    CCHide._create(),
                    CCDelayTime._create(m_fDuration/2) ]);

  m_pInScene.Scale := 0.5;
  m_pInScene.runAction(inA);
  m_pOutScene.runAction(outA);
end;

{ CCTransitionZoomFlipY }

class function CCTransitionZoomFlipY._create(t: Single;
  scene: CCScene): CCTransitionZoomFlipY;
begin
  Result := Self._create(t, scene, kCCTransitionOrientationUpOver);
end;

class function CCTransitionZoomFlipY._create(t: Single; scene: CCScene;
  o: tOrientation): CCTransitionZoomFlipY;
var
  pRet: CCTransitionZoomFlipY;
begin
  pRet := CCTransitionZoomFlipY.Create();
  pRet.initWithDuration(t, scene, o);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionZoomFlipY.onEnter;
var
  inA, outA: CCFiniteTimeAction;
  inDeltaZ, inAngleZ, outDeltaZ, outAngleZ: Single;
begin
  inherited onEnter();

  m_pInScene.Visible := False;
  if m_eOrientation = kCCTransitionOrientationUpOver then
  begin
    inDeltaZ := 90;
    inAngleZ := 270;
    outDeltaZ := 90;
    outAngleZ := 0;
  end else
  begin
    inDeltaZ := -90;
    inAngleZ := 90;
    outDeltaZ := -90;
    outAngleZ := 0;
  end;

  inA := CCSequence._create([
                    CCDelayTime._create(m_fDuration/2),
                    CCSpawn._create([
                            CCOrbitCamera._create(m_fDuration/2, 1, 0, inAngleZ, inDeltaZ, 90, 0),
                            CCScaleTo._create(m_fDuration/2, 1),
                            CCShow._create() ]),
                    CCCallFunc._create(Self, finish) ]);
  outA := CCSequence._create([
                    CCSpawn._create([
                            CCOrbitCamera._create(m_fDuration/2, 1, 0, outAngleZ, outDeltaZ, 90, 0),
                            CCScaleTo._create(m_fDuration/2, 0.5) ]),
                    CCHide._create(),
                    CCDelayTime._create(m_fDuration/2) ]);

  m_pInScene.Scale := 0.5;
  m_pInScene.runAction(inA);
  m_pOutScene.runAction(outA);
end;

{ CCTransitionZoomFlipAngular }

class function CCTransitionZoomFlipAngular._create(t: Single;
  scene: CCScene): CCTransitionZoomFlipAngular;
begin
  Result := Self._create(t, scene, kCCTransitionOrientationRightOver);
end;

class function CCTransitionZoomFlipAngular._create(t: Single;
  scene: CCScene; o: tOrientation): CCTransitionZoomFlipAngular;
var
  pRet: CCTransitionZoomFlipAngular;
begin
  pRet := CCTransitionZoomFlipAngular.Create();
  pRet.initWithDuration(t, scene, o);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCTransitionZoomFlipAngular.onEnter;
var
  inA, outA: CCFiniteTimeAction;
  inDeltaZ, inAngleZ, outDeltaZ, outAngleZ: Single;
begin
  inherited onEnter();
  m_pInScene.Visible := False;

  if m_eOrientation = kCCTransitionOrientationRightOver then
  begin
    inDeltaZ := 90;
    inAngleZ := 270;
    outDeltaZ := 90;
    outAngleZ := 0;
  end else
  begin
    inDeltaZ := -90;
    inAngleZ := 90;
    outDeltaZ := -90;
    outAngleZ := 0;
  end;

  inA := CCSequence._create([
                    CCDelayTime._create(m_fDuration/2),
                    CCSpawn._create([
                            CCOrbitCamera._create(m_fDuration/2, 1, 0, inAngleZ, inDeltaZ, -45, 0),
                            CCScaleTo._create(m_fDuration/2),
                            CCShow._create() ]),
                    CCShow._create(),
                    CCCallFunc._create(Self, finish) ]);
  outA := CCSequence._create([
                    CCSpawn._create([
                            CCOrbitCamera._create(m_fDuration/2, 1, 0, outAngleZ, outDeltaZ, 45, 0),
                            CCScaleTo._create(m_fDuration/2, 0.5) ]),
                    CCHide._create(),
                    CCDelayTime._create(m_fDuration/2) ]);

  m_pInScene.Scale := 0.5;
  m_pInScene.runAction(inA);
  m_pOutScene.runAction(outA);
end;

{ CCTransitionFade }

class function CCTransitionFade._create(t: Single;
  scene: CCScene): CCTransitionFade;
begin
  Result := Self._create(t, scene, ccBLACK);
end;

class function CCTransitionFade._create(t: Single; scene: CCScene;
  const color: ccColor3B): CCTransitionFade;
var
  pRet: CCTransitionFade;
begin
  pRet := CCTransitionFade.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene, color) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionFade.initWithDuration(t: Single;
  scene: CCScene): Boolean;
begin
  Result := initWithDuration(t, scene, ccBLACK);
end;

function CCTransitionFade.initWithDuration(t: Single; scene: CCScene;
  const color: ccColor3B): Boolean;
begin
  if inherited initWithDuration(t, scene) then
  begin
    m_tColor.r := color.r;
    m_tColor.g := color.g;
    m_tColor.b := color.b;
    m_tColor.a := 0;
  end;
  Result := True;
end;

procedure CCTransitionFade.onEnter;
var
  l: CCLayerColor;
  f: CCNode;
  a: CCFiniteTimeAction;
begin
  inherited onEnter();

  l := CCLayerColor._create(m_tColor);
  m_pInScene.Visible := False;

  addChild(l, 2, kSceneFade);
  f := getChildByTag(kSceneFade);

  a := CCSequence._create([
                  CCFadeIn._create(m_fDuration/2),
                  CCCallFunc._create(Self, hideOutShowIn),
                  CCFadeOut._create(m_fDuration/2),
                  CCCallFunc._create(Self, finish) ]);
  f.runAction(a);
end;

procedure CCTransitionFade.onExit;
begin
  inherited onExit();
  Self.removeChildByTag(kSceneFade, False);
end;

{ CCTransitionCrossFade }

class function CCTransitionCrossFade._create(t: Single;
  scene: CCScene): CCTransitionCrossFade;
var
  pRet: CCTransitionCrossFade;
begin
  pRet := CCTransitionCrossFade.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCTransitionCrossFade.draw;
begin
// override draw since both scenes (textures) are rendered in 1 scene
end;

procedure CCTransitionCrossFade.onEnter;
var
  size: CCSize;
  color: ccColor4B;
  layer: CCLayerColor;
  inTexture, outTexture: CCRenderTexture;
  blend1, blend2: ccBlendFunc;
  layerAction: CCAction;
begin
  inherited onEnter();
  color.r := 0; color.g := 0; color.b := 0; color.a := 0;
  size := CCDirector.sharedDirector().getWinSize();
  layer := CCLayerColor._create(color);

  inTexture := CCRenderTexture._create(Round(size.width), Round(size.height));
  if inTexture = nil then
    Exit;

  inTexture.Sprite.AnchorPoint := ccp(0.5, 0.5);
  inTexture.setPosition(ccp(size.width/2, size.height/2));
  inTexture.AnchorPoint := ccp(0.5, 0.5);

  inTexture._begin();
  inTexture.visit();
  inTexture._end();

  outTexture := CCRenderTexture._create(Round(size.width), Round(size.height));
  outTexture.Sprite.AnchorPoint := ccp(0.5, 0.5);
  outTexture.setPosition(ccp(size.width/2, size.height/2));
  outTexture.AnchorPoint := ccp(0.5, 0.5);

  outTexture._begin();
  m_pOutScene.visit();
  outTexture._end();

  blend1.src := GL_ONE; blend1.dst := GL_ONE;
  blend2.src := GL_SRC_ALPHA; blend2.dst := GL_ONE_MINUS_SRC_ALPHA;

  inTexture.Sprite.setBlendFunc(blend1);
  outTexture.Sprite.setBlendFunc(blend2);

  layer.addChild(inTexture);
  layer.addChild(outTexture);

  inTexture.Sprite.setOpacity(255);
  outTexture.Sprite.setOpacity(255);

  layerAction := CCSequence._create([
                            CCFadeTo._create(m_fDuration, 0),
                            CCCallFunc._create(Self, hideOutShowIn),
                            CCCallFunc._create(Self, finish) ]);

  outTexture.Sprite.runAction(layerAction);
  addChild(layer, 2, kSceneFade);
end;

procedure CCTransitionCrossFade.onExit;
begin
  Self.removeChildByTag(kSceneFade, False);
  inherited onExit();
end;

{ CCTransitionTurnOffTiles }

class function CCTransitionTurnOffTiles._create(t: Single;
  scene: CCScene): CCTransitionTurnOffTiles;
var
  pRet: CCTransitionTurnOffTiles;
begin
  pRet := CCTransitionTurnOffTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionTurnOffTiles.easeActionWithAction(
  action: CCActionInterval): CCActionInterval;
begin
  Result := action;
end;

procedure CCTransitionTurnOffTiles.onEnter;
var
  s: CCSize;
  aspect: Single;
  x, y: Integer;
  toff: CCTurnOffTiles;
  action: CCActionInterval;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize();
  aspect := s.width / s.height;
  x := Round(12 * aspect);
  y := 12;

  toff := CCTurnOffTiles._create(m_fDuration, CCSizeMake(x, y));
  action := easeActionWithAction(toff);
  m_pOutScene.runAction(
    CCSequence._create([
            action,
            CCCallFunc._create(Self, finish),
            CCStopGrid._create() ]));
end;

procedure CCTransitionTurnOffTiles.sceneOrder;
begin
  m_bIsInSceneOnTop := False;
end;

{ CCTransitionSplitCols }

class function CCTransitionSplitCols._create(t: Single;
  scene: CCScene): CCTransitionSplitCols;
var
  pRet: CCTransitionSplitCols;
begin
  pRet := CCTransitionSplitCols.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionSplitCols.action: CCActionInterval;
begin
  Result := CCSplitCols._create(m_fDuration * 0.5, 3);
end;

function CCTransitionSplitCols.easeActionWithAction(
  action: CCActionInterval): CCActionInterval;
begin
  Result := CCEaseInOut._create(action, 3.0);
end;

procedure CCTransitionSplitCols.onEnter;
var
  split: CCActionInterval;
  seq: CCFiniteTimeAction;
begin
  inherited onEnter();

  m_pInScene.Visible := False;
  split := action();
  seq := CCSequence._create([
        split,
        CCCallFunc._create(Self, hideOutShowIn),
        split.reverse() ]);

  Self.runAction(CCSequence._create([
        easeActionWithAction(CCActionInterval(seq)),
        CCCallFunc._create(Self, finish),
        CCStopGrid._create() ]))
end;

{ CCTransitionSplitRows }

class function CCTransitionSplitRows._create(t: Single;
  scene: CCScene): CCTransitionSplitRows;
var
  pRet: CCTransitionSplitRows;
begin
  pRet := CCTransitionSplitRows.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionSplitRows.action: CCActionInterval;
begin
  Result := CCSplitRows._create(m_fDuration * 0.5, 3);
end;

{ CCTransitionFadeTR }

class function CCTransitionFadeTR._create(t: Single;
  scene: CCScene): CCTransitionFadeTR;
var
  pRet: CCTransitionFadeTR;
begin
  pRet := CCTransitionFadeTR.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionFadeTR.actionWithSize(
  const size: CCSize): CCActionInterval;
begin
  Result := CCFadeOutTRTiles._create(m_fDuration, size);
end;

function CCTransitionFadeTR.easeActionWithAction(
  action: CCActionInterval): CCActionInterval;
begin
  Result := action;
end;

procedure CCTransitionFadeTR.onEnter;
var
  s: CCSize;
  aspect: Single;
  x, y: Integer;
  action: CCActionInterval;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize();
  aspect := s.width / s.height;
  x := Round(12 * aspect);
  y := 12;

  action := actionWithSize(CCSizeMake(x, y));

  m_pOutScene.runAction(CCSequence._create([
          easeActionWithAction(action),
          CCCallFunc._create(Self, finish),
          CCStopGrid._create() ]));
end;

procedure CCTransitionFadeTR.sceneOrder;
begin
  m_bIsInSceneOnTop := False;
end;

{ CCTransitionFadeBL }

class function CCTransitionFadeBL._create(t: Single;
  scene: CCScene): CCTransitionFadeBL;
var
  pRet: CCTransitionFadeBL;
begin
  pRet := CCTransitionFadeBL.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionFadeBL.actionWithSize(
  const size: CCSize): CCActionInterval;
begin
  Result := CCFadeOutBLTiles._create(m_fDuration, size);
end;

{ CCTransitionFadeUp }

class function CCTransitionFadeUp._create(t: Single;
  scene: CCScene): CCTransitionFadeUp;
var
  pRet: CCTransitionFadeUp;
begin
  pRet := CCTransitionFadeUp.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionFadeUp.actionWithSize(
  const size: CCSize): CCActionInterval;
begin
  Result := CCFadeOutUpTiles._create(m_fDuration, size);
end;

{ CCTransitionFadeDown }

class function CCTransitionFadeDown._create(t: Single;
  scene: CCScene): CCTransitionFadeDown;
var
  pRet: CCTransitionFadeDown;
begin
  pRet := CCTransitionFadeDown.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionFadeDown.actionWithSize(
  const size: CCSize): CCActionInterval;
begin
  Result := CCFadeOutDownTiles._create(m_fDuration, size);
end;

end.
