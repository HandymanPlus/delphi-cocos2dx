unit TransitionsTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSprite, Cocos2dx.CCNode;

type
  TransitionsTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  TestLayer1 = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;

    procedure onEnter(); override;
    procedure onEnterTransitionDidFinish(); override;
    procedure onExitTransitionDidStart(); override;
    procedure onExit(); override;

    procedure step(dt: Single);

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  end;

  TestLayer2 = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;

    procedure onEnter(); override;
    procedure onEnterTransitionDidFinish(); override;
    procedure onExitTransitionDidStart(); override;
    procedure onExit(); override;

    procedure step(dt: Single);

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, Cocos2dx.CCCommon, testResource,
  Cocos2dx.CCTypes, Cocos2dx.CCTransition, Cocos2dx.CCTransitionProgress,
  Cocos2dx.CCTransitionPageTurn;


var s_nSceneIdx: Integer = 0;
const TRANSITION_DURATION = 1.2;
const MAX_LAYER  =  41;
const transitions: array [0..MAX_LAYER-1] of string =
  (
    'CCTransitionJumpZoom',

    'CCTransitionProgressRadialCCW',
    'CCTransitionProgressRadialCW',
    'CCTransitionProgressHorizontal',
    'CCTransitionProgressVertical',
    'CCTransitionProgressInOut',
    'CCTransitionProgressOutIn',

    'CCTransitionCrossFade',



    'CCTransitionFade',
    'FadeWhiteTransition',

    'FlipXLeftOver',
    'FlipXRightOver',
    'FlipYUpOver',
    'FlipYDownOver',
    'FlipAngularLeftOver',
    'FlipAngularRightOver',

    'ZoomFlipXLeftOver',
    'ZoomFlipXRightOver',
    'ZoomFlipYUpOver',
    'ZoomFlipYDownOver',
    'ZoomFlipAngularLeftOver',
    'ZoomFlipAngularRightOver',

    'CCTransitionShrinkGrow',
    'CCTransitionRotoZoom',

    'CCTransitionMoveInL',
    'CCTransitionMoveInR',
    'CCTransitionMoveInT',
    'CCTransitionMoveInB',
    'CCTransitionSlideInL',
    'CCTransitionSlideInR',
    'CCTransitionSlideInT',
    'CCTransitionSlideInB',

    'TransitionPageForward',
    'TransitionPageBackward',
    'CCTransitionFadeTR',
    'CCTransitionFadeBL',
    'CCTransitionFadeUp',
    'CCTransitionFadeDown',
    'CCTransitionTurnOffTiles',
    'CCTransitionSplitRows',
    'CCTransitionSplitCols'
  );

type
  FadeWhiteTransition = class(CCTransitionFade)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  FlipXLeftOver = class(CCTransitionFlipX)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  FlipXRightOver = class(CCTransitionFlipX)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  FlipYUpOver = class(CCTransitionFlipY)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  FlipYDownOver = class(CCTransitionFlipY)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  FlipAngularLeftOver = class(CCTransitionFlipAngular)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  FlipAngularRightOver = class(CCTransitionFlipAngular)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  ZoomFlipXLeftOver = class(CCTransitionZoomFlipX)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  ZoomFlipXRightOver = class(CCTransitionZoomFlipX)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  ZoomFlipYUpOver = class(CCTransitionZoomFlipY)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  ZoomFlipYDownOver = class(CCTransitionZoomFlipY)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  ZoomFlipAngularLeftOver = class(CCTransitionZoomFlipAngular)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  ZoomFlipAngularRightOver = class(CCTransitionZoomFlipAngular)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  PageTransitionForward = class(CCTransitionPageTurn)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;

  PageTransitionBackward = class(CCTransitionPageTurn)
  public
    class function _create(t: Single; s: CCScene): CCTransitionScene;
  end;







function createTransition(nIndex: Integer; t: Single; s: CCScene): CCTransitionScene;
var
  pRet: CCTransitionScene;
begin
  CCDirector.sharedDirector().setDepthTest(False);

  pRet := nil;
  case nIndex of
    0: pRet := CCTransitionJumpZoom._create(t, s);
    1: pRet := CCTransitionProgressRadialCCW._create(t, s);
    2: pRet := CCTransitionProgressRadialCW._create(t, s);
    3: pRet := CCTransitionProgressHorizontal._create(t, s);
    4: pRet := CCTransitionProgressVertical._create(t, s);
    5: pRet := CCTransitionProgressInOut._create(t, s);
    6: pRet := CCTransitionProgressOutIn._create(t, s);
    7: pRet := CCTransitionCrossFade._create(t, s);

    8: pRet := CCTransitionFade._create(t, s);
    9: pRet := FadeWhiteTransition._create(t, s);

    10: pRet := FlipXLeftOver._create(t, s);
    11: pRet := FlipXRightOver._create(t, s);
    12: pRet := FlipYUpOver._create(t, s);
    13: pRet := FlipYDownOver._create(t, s);
    14: pRet := FlipAngularLeftOver._create(t, s);
    15: pRet := FlipAngularRightOver._create(t, s);

    16: pRet := ZoomFlipXLeftOver._create(t, s);
    17: pRet := ZoomFlipXRightOver._create(t, s);
    18: pRet := ZoomFlipYUpOver._create(t, s);
    19: pRet := ZoomFlipYDownOver._create(t, s);
    20: pRet := ZoomFlipAngularLeftOver._create(t, s);
    21: pRet := ZoomFlipAngularRightOver._create(t, s);

    22: pRet := CCTransitionShrinkGrow._create(t, s);
    23: pRet := CCTransitionRotoZoom._create(t, s);

    24: pRet := CCTransitionMoveInL._create(t, s);
    25: pRet := CCTransitionMoveInR._create(t, s);
    26: pRet := CCTransitionMoveInT._create(t, s);
    27: pRet := CCTransitionMoveInB._create(t, s);
    
    28: pRet := CCTransitionSlideInL._create(t, s);
    29: pRet := CCTransitionSlideInR._create(t, s);
    30: pRet := CCTransitionSlideInT._create(t, s);
    31: pRet := CCTransitionSlideInB._create(t, s);

    32: pRet := PageTransitionForward._create(t, s);
    33: pRet := PageTransitionBackward._create(t, s);
    34: pRet := CCTransitionFadeTR._create(t, s);
    35: pRet := CCTransitionFadeBL._create(t, s);
    36: pRet := CCTransitionFadeUp._create(t, s);
    37: pRet := CCTransitionFadeDown._create(t, s);
    38: pRet := CCTransitionTurnOffTiles._create(t, s);
    39: pRet := CCTransitionSplitRows._create(t, s);
    40: pRet := CCTransitionSplitCols._create(t, s);
  end;

  Result := pRet;
end;  


{ TransitionsTestScene }

procedure TransitionsTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := TestLayer1.Create;
  addChild(pLayer);
  pLayer.release();
  CCDirector.sharedDirector().replaceScene(Self);
end;

{ TestLayer1 }

procedure TestLayer1.backCallback(pObj: CCObject);
var
  s: CCScene;
  pLayer: CCLayer;
  pScene: CCScene;
  total: Integer;
begin
  Dec(s_nSceneIdx);
  total := MAX_LAYER;
  if s_nSceneIdx < 0 then
    s_nSceneIdx := s_nSceneIdx + total;

  s := TransitionsTestScene.Create();
  pLayer := TestLayer2.Create;
  s.addChild(pLayer);

  pScene := createTransition(s_nSceneIdx, TRANSITION_DURATION, s);
  s.release();
  pLayer.release();
  if pScene <> nil then
    CCDirector.sharedDirector().replaceScene(pScene);
end;

constructor TestLayer1.Create;
var
  s: CCSize;
  title, pLabel: CCLabelTTF;

  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;

  bg1: CCSprite;
begin
  inherited Create();

  s := CCDirector.sharedDirector().getWinSize;

  bg1 := CCSprite._create(s_back1);
  bg1.setPosition( CCPointMake(s.width/2, s.height/2) );
  addChild(bg1, -1);

  title := CCLabelTTF._create(transitions[s_nSceneIdx], 'Thonburi', 32);
  addChild(title);
  title.setColor(ccc3(255, 32, 32));
  title.setPosition(ccp(s.width/2, s.height-100));

  pLabel := CCLabelTTF._create('SCENE 1', 'Marker Felt', 38);
  addChild(pLabel);
  pLabel.setColor(ccc3(16, 16, 255));
  pLabel.setPosition(ccp(s.width/2, s.height/2));


  item1 := CCMenuItemImage._create('Images/b1.png', 'Images/b2.png', Self, backCallback);
  item2 := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, restartCallback);
  item3 := CCMenuItemImage._create('Images/f1.png', 'Images/f2.png', Self, nextCallback);

  menu := CCMenu._create([item1, item2, item3]);
  menu.setPosition(CCPointZero);
  item1.setPosition(ccp( s.width/2 - item2.ContentSize.width*2, item2.ContentSize.height/2 ));
  item2.setPosition(ccp( s.width/2, item2.ContentSize.height/2 ));
  item3.setPosition(ccp( s.width/2 + item2.ContentSize.width * 2, item2.ContentSize.height/2 ));

  addChild(menu, 1);

  schedule(step, 1.0);
end;

destructor TestLayer1.Destroy;
begin

  inherited;
end;

procedure TestLayer1.nextCallback(pObj: CCObject);
var
  s: CCScene;
  pLayer: CCLayer;
  pScene: CCScene;
begin
  Inc(s_nSceneIdx);
  s_nSceneIdx := s_nSceneIdx mod MAX_LAYER;

  s := TransitionsTestScene.Create();
  pLayer := TestLayer2.Create;
  s.addChild(pLayer);

  pScene := createTransition(s_nSceneIdx, TRANSITION_DURATION, s);
  s.release();
  pLayer.release();
  if pScene <> nil then
    CCDirector.sharedDirector().replaceScene(pScene);
end;

procedure TestLayer1.onEnter;
begin
  inherited;
  CCLog('Scene 1 onEnter', []);
end;

procedure TestLayer1.onEnterTransitionDidFinish;
begin
  inherited;
  CCLog('Scene 1 onEnterTransitionDidFinish', []);
end;

procedure TestLayer1.onExit;
begin
  inherited;
  CCLog('Scene 1 onExit', []);
end;

procedure TestLayer1.onExitTransitionDidStart;
begin
  inherited;
  CCLog('Scene 1 onExitTransitionDidStart', []);
end;

procedure TestLayer1.restartCallback(pObj: CCObject);
var
  s: CCScene;
  pLayer: CCLayer;
  pScene: CCScene;
begin
  s := TransitionsTestScene.Create();
  pLayer := TestLayer2.Create;
  s.addChild(pLayer);

  pScene := createTransition(s_nSceneIdx, TRANSITION_DURATION, s);
  s.release();
  pLayer.release();
  if pScene <> nil then
    CCDirector.sharedDirector().replaceScene(pScene);
end;

procedure TestLayer1.step(dt: Single);
begin

end;

{ TestLayer2 }

procedure TestLayer2.backCallback(pObj: CCObject);
var
  s: CCScene;
  pLayer: CCLayer;
  pScene: CCScene;
  total: Integer;
begin
  Dec(s_nSceneIdx);
  total := MAX_LAYER;
  if s_nSceneIdx < 0 then
    s_nSceneIdx := s_nSceneIdx + total;

  s := TransitionsTestScene.Create();
  pLayer := TestLayer1.Create;
  s.addChild(pLayer);

  pScene := createTransition(s_nSceneIdx, TRANSITION_DURATION, s);
  s.release();
  pLayer.release();
  if pScene <> nil then
    CCDirector.sharedDirector().replaceScene(pScene);
end;

constructor TestLayer2.Create;
var
  s: CCSize;
  title, pLabel: CCLabelTTF;

  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;

  bg1: CCSprite;
begin
  inherited Create();

  s := CCDirector.sharedDirector().getWinSize;

  bg1 := CCSprite._create(s_back2);
  bg1.setPosition( CCPointMake(s.width/2, s.height/2) );
  addChild(bg1, -1);

  title := CCLabelTTF._create(transitions[s_nSceneIdx], 'Thonburi', 32);
  addChild(title);
  title.setColor(ccc3(255, 32, 32));
  title.setPosition(ccp(s.width/2, s.height-100));

  pLabel := CCLabelTTF._create('SCENE 2', 'Marker Felt', 38);
  addChild(pLabel);
  pLabel.setColor(ccc3(16, 16, 255));
  pLabel.setPosition(ccp(s.width/2, s.height/2));


  item1 := CCMenuItemImage._create('Images/b1.png', 'Images/b2.png', Self, backCallback);
  item2 := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, restartCallback);
  item3 := CCMenuItemImage._create('Images/f1.png', 'Images/f2.png', Self, nextCallback);

  menu := CCMenu._create([item1, item2, item3]);
  menu.setPosition(CCPointZero);
  item1.setPosition(ccp( s.width/2 - item2.ContentSize.width*2, item2.ContentSize.height/2 ));
  item2.setPosition(ccp( s.width/2, item2.ContentSize.height/2 ));
  item3.setPosition(ccp( s.width/2 + item2.ContentSize.width * 2, item2.ContentSize.height/2 ));

  addChild(menu, 1);

  schedule(step, 1.0);
end;

destructor TestLayer2.Destroy;
begin

  inherited;
end;

procedure TestLayer2.nextCallback(pObj: CCObject);
var
  s: CCScene;
  pLayer: CCLayer;
  pScene: CCScene;
begin
  Inc(s_nSceneIdx);
  s_nSceneIdx := s_nSceneIdx mod MAX_LAYER;

  s := TransitionsTestScene.Create();
  pLayer := TestLayer1.Create;
  s.addChild(pLayer);

  pScene := createTransition(s_nSceneIdx, TRANSITION_DURATION, s);
  s.release();
  pLayer.release();
  if pScene <> nil then
    CCDirector.sharedDirector().replaceScene(pScene);
end;

procedure TestLayer2.onEnter;
begin
  inherited;
  CCLog('Scene 2 onEnter', []);
end;

procedure TestLayer2.onEnterTransitionDidFinish;
begin
  inherited;
  CCLog('Scene 2 onEnterTransitionDidFinish', []);
end;

procedure TestLayer2.onExit;
begin
  inherited;
  CCLog('Scene 2 onExit', []);
end;

procedure TestLayer2.onExitTransitionDidStart;
begin
  inherited;
  CCLog('Scene 2 onExitTransitionDidStart', []);
end;

procedure TestLayer2.restartCallback(pObj: CCObject);
var
  s: CCScene;
  pLayer: CCLayer;
  pScene: CCScene;
begin
  s := TransitionsTestScene.Create();
  pLayer := TestLayer1.Create;
  s.addChild(pLayer);

  pScene := createTransition(s_nSceneIdx, TRANSITION_DURATION, s);
  s.release();
  pLayer.release();
  if pScene <> nil then
    CCDirector.sharedDirector().replaceScene(pScene);
end;

procedure TestLayer2.step(dt: Single);
begin

end;

{ FadeWhiteTransition }

class function FadeWhiteTransition._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionFade._create(t, s, ccWHITE);
end;

{ FlipXLeftOver }

class function FlipXLeftOver._create(t: Single; s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionFlipX._create(t, s, kCCTransitionOrientationLeftOver);
end;

{ FlipXRightOver }

class function FlipXRightOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionFlipX._create(t, s, kCCTransitionOrientationRightOver);
end;

{ FlipYUpOver }

class function FlipYUpOver._create(t: Single; s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionFlipY._create(t, s, kCCTransitionOrientationUpOver);
end;

{ FlipYDownOver }

class function FlipYDownOver._create(t: Single; s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionFlipY._create(t, s, kCCTransitionOrientationDownOver);
end;

{ FlipAngularLeftOver }

class function FlipAngularLeftOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionFlipAngular._create(t, s, kCCTransitionOrientationLeftOver);
end;

{ FlipAngularRightOver }

class function FlipAngularRightOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionFlipAngular._create(t, s, kCCTransitionOrientationRightOver);
end;

{ ZoomFlipXLeftOver }

class function ZoomFlipXLeftOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionZoomFlipX._create(t, s, kCCTransitionOrientationLeftOver);
end;

{ ZoomFlipXRightOver }

class function ZoomFlipXRightOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionZoomFlipX._create(t, s, kCCTransitionOrientationRightOver);
end;

{ ZoomFlipYUpOver }

class function ZoomFlipYUpOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionZoomFlipY._create(t, s, kCCTransitionOrientationUpOver);
end;

{ ZoomFlipYDownOver }

class function ZoomFlipYDownOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionZoomFlipY._create(t, s, kCCTransitionOrientationDownOver);
end;

{ ZoomFlipAngularLeftOver }

class function ZoomFlipAngularLeftOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionZoomFlipAngular._create(t, s, kCCTransitionOrientationLeftOver);
end;

{ ZoomFlipAngularRightOver }

class function ZoomFlipAngularRightOver._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  Result := CCTransitionZoomFlipAngular._create(t, s, kCCTransitionOrientationRightOver);
end;

{ PageTransitionForward }

class function PageTransitionForward._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  CCDirector.sharedDirector.setDepthTest(True);
  Result := CCTransitionPageTurn._create(t, s, False);
end;

{ PageTransitionBackward }

class function PageTransitionBackward._create(t: Single;
  s: CCScene): CCTransitionScene;
begin
  CCDirector.sharedDirector.setDepthTest(True);
  Result := CCTransitionPageTurn._create(t, s, True);
end;

end.
