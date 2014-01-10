unit nodetest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCTouch, Cocos2dx.CCSet, Cocos2dx.CCSprite, Cocos2dx.CCNode;

type
  NodeTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  NodeTestDemo = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; dynamic;
    function subtitle(): string; dynamic;
    procedure onEnter(); override;

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  end;

  Test2 = class(NodeTestDemo)
  public
    function title(): string; override;
    procedure onEnter(); override;
  end;

  Test4 = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure delay2(dt: Single);
    procedure delay4(dt: Single);
  end;

  Test5 = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure addAndRemove(dt: Single);
  end;

  Test6 = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure addAndRemove(dt: Single);
  end;

  SchedulerTest1 = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure doSomething(dt: Single);
  end;

  NodeToWorld = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
  end;

  ConvertToNode = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
  end;

  NodeOpaqueTest = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  NodeNonOpaqueTest = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  CareraZoomTest = class(NodeTestDemo)
  public
    m_z: Single;
    constructor Create();
    procedure update(dt: Single); override;
    function title(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;
  end;

  CameraCenterTest = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  StressTest1 = class(NodeTestDemo)
  public
    procedure shouldNotCrash(dt: Single);
    procedure removeMe(node: CCObject);
    constructor Create();
    function title(): string; override;
  end;

  StressTest2 = class(NodeTestDemo)
  public
    procedure shouldNotLeak(dt: Single);
    constructor Create();
    function title(): string; override;
  end;

  CameraOrbitTest = class(NodeTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;
  end;


implementation
uses
  SysUtils, dglOpenGL,
  Cocos2dx.CCGLStateCache, Cocos2dx.CCCamera, Cocos2dx.CCActionCamera,
  Cocos2dx.CCParticleExamples, Cocos2dx.CCTextureCache,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, Cocos2dx.CCCommon, testResource,
  Cocos2dx.CCDirectorProjection, Cocos2dx.CCTypes, Cocos2dx.CCActionInstant,
  Cocos2dx.CCActionEase, Cocos2dx.CCAction, Cocos2dx.CCActionInterval;


const          kTagSprite1 = 1;
const          kTagSprite2 = 2;
const          kTagSprite3 = 3;
const          kTagSlider = 4;

var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 14;

function createNodeTestLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := CameraCenterTest.Create;
    1: bRet := Test2.Create;
    2: bRet := Test4.Create;
    3: bRet := Test5.Create;
    4: bRet := Test6.Create;
    5: bRet := StressTest1.Create;
    6: bRet := StressTest2.Create;
    7: bRet := NodeToWorld.Create;
    8: bRet := SchedulerTest1.Create;
    9: bRet := CameraOrbitTest.Create;
    10: bRet := CareraZoomTest.Create();
    11: bRet := ConvertToNode.Create;
    12: bRet := NodeOpaqueTest.Create;
    13: bRet := NodeNonOpaqueTest.Create;
  end;

  Result := bRet;
end;  

function nextNodeTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createNodeTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backNodeTestAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createNodeTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartNodeTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createNodeTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ NodeTestScene }

procedure NodeTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := nextNodeTestAction();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ NodeTestDemo }

procedure NodeTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := nodeTestScene.Create();
  s.addChild(backnodeTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor NodeTestDemo.Create;
begin
  inherited Create();
end;

destructor NodeTestDemo.Destroy;
begin

  inherited;
end;

procedure NodeTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := nodeTestScene.Create();
  s.addChild(nextnodeTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure NodeTestDemo.onEnter;
var
  s: CCSize;
  label1, label2: CCLabelTTF;
  strSubtitle: string;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize;

  label1 := CCLabelTTF._create(title(), 'Arial', 28);
  addChild(label1, 1);
  label1.setPosition(ccp(s.width/2, s.height-50));

  strSubtitle := subtitle();
  if strSubtitle <> '' then
  begin
    label2 := CCLabelTTF._create(strSubtitle, 'Thonburi', 16);
    addChild(label2, 1);
    label2.setPosition(ccp(s.width/2, s.height-80));
  end;

  item1 := CCMenuItemImage._create('Images/b1.png', 'Images/b2.png', Self, backCallback);
  item2 := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, restartCallback);
  item3 := CCMenuItemImage._create('Images/f1.png', 'Images/f2.png', Self, nextCallback);

  menu := CCMenu._create([item1, item2, item3]);
  menu.setPosition(CCPointZero);
  item1.setPosition(ccp( s.width/2 - item2.ContentSize.width*2, item2.ContentSize.height/2 ));
  item2.setPosition(ccp( s.width/2, item2.ContentSize.height/2 ));
  item3.setPosition(ccp( s.width/2 + item2.ContentSize.width * 2, item2.ContentSize.height/2 ));

  addChild(menu, 1);
end;

procedure NodeTestDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := nodeTestScene.Create();
  s.addChild(restartnodeTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function NodeTestDemo.subtitle: string;
begin
  Result := '';
end;

function NodeTestDemo.title: string;
begin
  Result := 'No title';
end;

{ Test2 }

procedure Test2.onEnter;
var
  s: CCSize;
  sp1, sp2, sp3, sp4: CCSprite;
  a1, a2: CCFiniteTimeAction;
  action1, action2: CCAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  sp1 := CCSprite._create(s_pPathSister1);
  sp2 := CCSprite._create(s_pPathSister2);
  sp3 := CCSprite._create(s_pPathSister1);
  sp4 := CCSprite._create(s_pPathSister2);

  sp1.setPosition( CCPointMake(100, s.height/2) );
  sp2.setPosition( CCPointMake(380, s.height/2) );

  addChild(sp1); addChild(sp2);
  sp3.Scale := 0.25; sp4.Scale := 0.25;

  sp1.addChild(sp3); sp2.addChild(sp4);

  a1 := CCRotateBy._create(2, 360);
  a2 := CCScaleBy._create(2, 2);
  action1 := CCRepeatForever._create(CCActionInterval(CCSequence._create([a1, a2, a2.reverse()])));
  action2 := CCRepeatForever._create(CCActionInterval(CCSequence._create([CCFiniteTimeAction(a1.copy().autorelease()),
    CCFiniteTimeAction(a2.copy().autorelease()), a2.reverse()])));
  sp2.setAnchorPoint(CCPointMake(0, 0));

  sp1.runAction(action1);
  sp2.runAction(action2);
end;

function Test2.title: string;
begin
  Result := 'anchorPoint and children';
end;

{ Test4 }

constructor Test4.Create;
var
  sp1, sp2: CCSprite;
begin
  inherited;
  sp1 := CCSprite._create(s_pPathSister1);
  sp2 := CCSprite._create(s_pPathSister2);

  sp1.setPosition( CCPointMake(100, 160) );
  sp2.setPosition( CCPointMake(380, 160) );

  addChild(sp1, 0, 2);
  addChild(sp2, 0, 3);

  schedule(delay2, 2);
  schedule(delay4, 4);
end;

procedure Test4.delay2(dt: Single);
var
  node: CCSprite;
  action1: CCAction;
begin
  node := CCSprite(getChildByTag(2));
  action1 := CCRotateBy._create(1, 360);
  node.runAction(action1);
end;

procedure Test4.delay4(dt: Single);
begin
  unschedule(delay4);
  removeChildByTag(3, False);
end;

function Test4.title: string;
begin
  Result := 'tags';
end;

{ Test5 }

procedure Test5.addAndRemove(dt: Single);
var
  sp1, sp2: CCNode;
begin
  sp1 := getChildByTag(kTagSprite1);
  sp2 := getChildByTag(kTagSprite2);

  sp1.retain(); sp2.retain();
  removeChild(sp1, False); removeChild(sp2, True);

  addChild(sp1, 0, kTagSprite1);
  addChild(sp2, 0, kTagSprite2);

  sp1.release(); sp2.release();
end;

constructor Test5.Create;
var
  sp1, sp2: CCSprite;
  rot: CCRotateBy;
  rot_back: CCFiniteTimeAction;
  forever, forever2: CCAction;
begin
  inherited;

  sp1 := CCSprite._create(s_pPathSister1);
  sp2 := CCSprite._create(s_pPathSister2);

  sp1.setPosition(CCPointMake(100, 160));
  sp2.setPosition(CCPointMake(380, 160));

  rot := CCRotateBy._create(2, 360);
  rot_back := rot.reverse();
  forever := CCRepeatForever._create(CCActionInterval(CCSequence._create([rot, rot_back])));

  forever2 := CCAction(forever.copy().autorelease());
  forever.setTag(101);
  forever2.setTag(102);

  addChild(sp1, 0, kTagSprite1);
  addChild(sp2, 0, kTagSprite2);

  sp1.runAction(forever);
  sp2.runAction(forever2);

  schedule(addAndRemove, 2.0);
end;

function Test5.title: string;
begin
  Result := 'remove and cleanup';
end;

{ Test6 }

procedure Test6.addAndRemove(dt: Single);
var
  sp1, sp2: CCNode;
begin
  sp1 := getChildByTag(kTagSprite1);
  sp2 := getChildByTag(kTagSprite2);

  sp1.retain();
  sp2.retain();

  removeChild(sp1, False);
  removeChild(sp2, True);

  addChild(sp1, 0, kTagSprite1);
  addChild(sp2, 0, kTagSprite2);

  sp1.release(); sp2.release();
end;

constructor Test6.Create;
var
  sp1, sp11, sp2, sp21: CCSprite;
  rot, rot_back: CCFiniteTimeAction;
  forever1, forever11, forever2, forever21: CCAction;
begin
  inherited;
  sp1 := CCSprite._create(s_pPathSister1);
  sp11 := CCSprite._create(s_pPathSister1);

  sp2 := CCSprite._create(s_pPathSister2);
  sp21 := CCSprite._create(s_pPathSister2);

  sp1.setPosition(CCPointMake(100, 160));
  sp2.setPosition(CCPointMake(380, 160));

  rot := CCRotateBy._create(2, 360);
  rot_back := rot.reverse();
  forever1 := CCRepeatForever( CCActionInterval(CCSequence._create([ rot, rot_back ])) );
  forever11 := CCAction(forever1.copy().autorelease());

  forever2 := CCAction(forever1.copy().autorelease());
  forever21 := CCAction(forever1.copy().autorelease());

  addChild(sp1, 0, kTagSprite1);
  sp1.addChild(sp11);
  addChild(sp2, 0, kTagSprite2);
  sp2.addChild(sp21);

  sp1.runAction(forever1);
  sp11.runAction(forever11);
  sp2.runAction(forever2);
  sp21.runAction(forever21);

  schedule(addAndRemove, 2);
end;

function Test6.title: string;
begin
  Result := 'remove/cleanup with children';
end;

{ SchedulerTest1 }

constructor SchedulerTest1.Create;
var
  layer: CCLayer;
begin
  inherited;
  layer := CCLayer._create;
  addChild(layer, 0);
  layer.schedule(doSomething);
  layer.unschedule(doSomething);
end;

procedure SchedulerTest1.doSomething(dt: Single);
begin

end;

function SchedulerTest1.title: string;
begin
  Result := 'cocosnode scheduler test #1';
end;

{ NodeToWorld }

constructor NodeToWorld.Create;
var
  back: CCSprite;
  backsize: CCSize;
  item: CCMenuItem;
  menu: CCMenu;
  rot: CCFiniteTimeAction;
  fe: CCAction;
  move, move_back, seq: CCFiniteTimeAction;
  fe2: CCAction;
begin
  inherited;

  back := CCSprite._create(s_back3);
  addChild(back, -10);
  back.setAnchorPoint(CCPointZero);
  backsize := back.ContentSize;

  item := CCMenuItemImage._create(s_PlayNormal, s_PlaySelect);
  menu := CCMenu._create([item]);
  menu.alignItemsVertically();
  menu.setPosition(CCPointMake(backsize.width/2, backsize.height/2));
  back.addChild(menu);

  rot := CCRotateBy._create(5, 360);
  fe := CCRepeatForever._create(CCActionInterval(rot));
  item.runAction(fe);

  move := CCMoveBy._create(3, CCPointMake(200, 0));
  move_back := move.reverse();
  seq := CCSequence._create([move, move_back]);
  fe2 := CCRepeatForever._create(CCActionInterval(seq));

  back.runAction(fe2);
end;

function NodeToWorld.title: string;
begin
  Result := 'nodeToParent transform';
end;

{ ConvertToNode }

procedure ConvertToNode.ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent);
var
  i, j: Integer;
  touch: CCTouch;
  location: CCPoint;
  node: CCNode;
  p1, p2: CCPoint;
begin
  for i := 0 to pTouches.count()-1 do
  begin
    touch := CCTouch(pTouches.getObject(i));
    location := touch.getLocation();      
    for j := 0 to 2 do
    begin
      node := getChildByTag(100+j);
      p1 := node.convertToNodeSpaceAR(location);
      p2 := node.convertToNodeSpace(location);

      CCLog('AR: x=%.2f, y=%.2f -- Not AR: x=%.2f, y=%.2f', [p1.x, p1.y, p2.x, p2.y]);
    end;
  end;
end;

constructor ConvertToNode.Create;
var
  s: CCSize;
  rotate: CCRotateBy;
  action: CCRepeatForever;
  i: Integer;
  sprite: CCSprite;
  point: CCSprite;
  copy: CCRepeatForever;
begin
  inherited;
  setTouchEnabled(True);
  s := CCDirector.sharedDirector().getWinSize();
  rotate := CCRotateBy._create(10, 360);
  action := CCRepeatForever._create(rotate);
  for i := 0 to 2 do
  begin
    sprite := CCSprite._create('Images/grossini.png');
    sprite.setPosition(ccp(s.width/4*(i+1), s.height/2));

    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition());
    addChild(point, 10, 100+i);

    case i of
      0: sprite.setAnchorPoint(CCPointZero);
      1: sprite.setAnchorPoint(ccp(0.5, 0.5));
      2: sprite.setAnchorPoint(ccp(1, 1));
    end;

    point.setPosition(sprite.getPosition());

    copy := CCRepeatForever(action.copy());
    copy.autorelease();
    sprite.runAction(copy);
    addChild(sprite, i);
  end;  
end;

function ConvertToNode.subtitle: string;
begin
  Result := 'testing convertToNodeSpace / AR. Touch and see console';
end;

function ConvertToNode.title: string;
begin
  Result := 'Convert To Node Space';
end;

{ NodeOpaqueTest }

constructor NodeOpaqueTest.Create;
var
  i: Integer;
  background: CCSprite;
  blendFunc: ccBlendFunc;
begin
  inherited;
  for i := 0 to 50-1 do
  begin
    background := CCSprite._create('Images/background1.png');
    blendFunc.src := GL_ONE;
    blendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
    background.setBlendFunc(blendFunc);
    background.setAnchorPoint(CCPointZero);
    addChild(background);
  end;
end;

function NodeOpaqueTest.subtitle: string;
begin
  Result := 'Node rendered with GL_BLEND disabled';
end;

function NodeOpaqueTest.title: string;
begin
  Result := 'Node Opaque Test';
end;

{ NodeNonOpaqueTest }

constructor NodeNonOpaqueTest.Create;
var
  i: Integer;
  background: CCSprite;
begin
  inherited;
  for i := 0 to 50-1 do
  begin
    background := CCSprite._create('Images/background1.jpg');
    background.setBlendFunc(kCCBlendFuncDisable);
    background.setAnchorPoint(CCPointZero);
    addChild(background);
  end;
end;

function NodeNonOpaqueTest.subtitle: string;
begin
  Result := 'Node rendered with GL_BLEND enabled';
end;

function NodeNonOpaqueTest.title: string;
begin
  Result := 'Node Non Opaque Test';
end;

{ CareraZoomTest }

constructor CareraZoomTest.Create;
var
  s: CCSize;
  sprite: CCSprite;
  cam: CCCamera;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  sprite := CCSprite._create(s_pPathGrossini);
  addChild(sprite, 0);
  sprite.setPosition(CCPointMake(s.width/4*1, s.height/2));
  cam := sprite.Camera;
  cam.setEyeXYZ(0, 0, 415/2);
  cam.setCenterXYZ(0, 0, 0);

  sprite := CCSprite._create(s_pPathGrossini);
  addChild(sprite, 0, 40);
  sprite.setPosition(CCPointMake(s.width/4*2, s.height/2));

  sprite := CCSprite._create(s_pPathGrossini);
  addChild(sprite, 0, 20);
  sprite.setPosition(CCPointMake(s.width/4*3, s.height/2));

  m_z := 0;
  scheduleUpdate();
end;

procedure CareraZoomTest.onEnter;
begin
  inherited;
  CCDirector.sharedDirector().setProjection(kCCDirectorProjection3D);
end;

procedure CareraZoomTest.onExit;
begin
  CCDirector.sharedDirector().setProjection(kCCDirectorProjection2D);
  inherited;
end;

function CareraZoomTest.title: string;
begin
  Result := 'Camera Zoom test';
end;

procedure CareraZoomTest.update(dt: Single);
var
  sprite: CCNode;
  cam: CCCamera;
begin
  m_z := m_z + dt * 100;
  sprite := getChildByTag(20);
  cam := sprite.Camera;
  cam.setEyeXYZ(0, 0, m_z);

  sprite := getChildByTag(40);
  cam := sprite.Camera;
  cam.setEyeXYZ(0, 0, -M_z);
end;

{ CameraCenterTest }

constructor CameraCenterTest.Create;
var
  orbit: CCOrbitCamera;
  sprite: CCSprite;
  s: CCSize;
begin
  inherited;

  s := CCDirector.sharedDirector.getWinSize;

  sprite := CCSprite._create('Images/white-512x512.png');
  addChild(sprite, 0);
  sprite.setPosition(s.width/5*1, s.height/5*1);
  sprite.setColor(ccred);
  sprite.setTextureRect(CCRectMake(0, 0, 120, 50));
  orbit := CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 0);
  sprite.runAction(CCRepeatForever._create(orbit));

  sprite := CCSprite._create('Images/white-512x512.png');
  addChild(sprite, 0, 40);
  sprite.setPosition(s.width/5*1, s.height/5*4);
  sprite.setColor(ccBLUE);
  sprite.setTextureRect(CCRectMake(0, 0, 120, 50));
  orbit := CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 0);
  sprite.runAction(CCRepeatForever._create(orbit));

  sprite := CCSprite._create('Images/white-512x512.png');
  addChild(sprite, 0);
  sprite.setPosition(s.width/5*4, s.height/5*1);
  sprite.setColor(ccYELLOW);
  sprite.setTextureRect(CCRectMake(0, 0, 120, 50));
  orbit := CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 0);
  sprite.runAction(CCRepeatForever._create(orbit));

  sprite := CCSprite._create('Images/white-512x512.png');
  addChild(sprite, 0, 40);
  sprite.setPosition(s.width/5*4, s.height/5*4);
  sprite.setColor(ccGREEN);
  sprite.setTextureRect(CCRectMake(0, 0, 120, 50));
  orbit := CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 0);
  sprite.runAction(CCRepeatForever._create(orbit));

  sprite := CCSprite._create('Images/white-512x512.png');
  addChild(sprite, 0, 40);
  sprite.setPosition(s.width/2, s.height/2);
  sprite.setColor(ccWHITE);
  sprite.setTextureRect(CCRectMake(0, 0, 120, 50));
  orbit := CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 0);
  sprite.runAction(CCRepeatForever._create(orbit));
end;

function CameraCenterTest.subtitle: string;
begin
  Result := 'Sprites should rotate at the same speed';
end;

function CameraCenterTest.title: string;
begin
  Result := 'Camera Center test';
end;

{ StressTest1 }

constructor StressTest1.Create;
var
  s: CCSize;
  sp1: CCSprite;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  sp1 := CCSprite._create(s_pPathSister1);
  addChild(sp1, 0, kTagSprite1);

  sp1.setPosition(s.width/2, s.height/2);
  schedule(shouldNotCrash, 1);
end;

procedure StressTest1.removeMe(node: CCObject);
begin
  Parent.removeChild(CCNode(node), True);
  nextCallback(Self);
end;

procedure StressTest1.shouldNotCrash(dt: Single);
var
  s: CCSize;
  explosion: CCNode;
begin
  unschedule(shouldNotCrash);
  s := CCDirector.sharedDirector.getWinSize;
  explosion := CCParticleSun._create;
  CCParticleSun(explosion).setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
  explosion.setPosition(s.width/2, s.height/2);

  runAction(CCSequence._create([ CCRotateBy._create(2, 360),  CCCallFuncN._create(Self, removeme) ]));

  addChild(explosion);
end;

function StressTest1.title: string;
begin
  Result := 'stress test #1: no crashes';
end;

{ StressTest2 }

constructor StressTest2.Create;
var
  s: CCSize;
  subLayer: CCLayer;
  sp1: CCSprite;
  move_copy: CCActionInterval;
  move, move_ease_inout3, move_ease_inout_back3: CCFiniteTimeAction;
  seq3: CCFiniteTimeAction;
  fire: CCParticleFire;
  copy_seq3: CCActionInterval;
begin
  inherited;
  s :=CCDirector.sharedDirector.getWinSize;
  subLayer := CCLayer._create;
  sp1 := CCSprite._create(s_pPathSister1);
  sp1.setPosition(80, s.height/2);

  move := CCMoveBy._create(3, ccp(350, 0));
  move_copy := CCActionInterval(move.copy.autorelease);

  move_ease_inout3 := CCEaseInOut._create(CCActionInterval(move_copy), 2);

  move_ease_inout_back3 := move_ease_inout3.reverse;

  seq3 := CCSequence._create([move_ease_inout3, move_ease_inout_back3]);

  sp1.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
  subLayer.addChild(sp1, 1);

  fire := CCParticleFire._create;
  fire.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
  fire.setPosition(80, s.height/2-50);

  copy_seq3 :=  CCActionInterval(seq3.copy.autorelease);

  fire.runAction(CCRepeatForever._create(copy_seq3));
  subLayer.addChild(fire, 2);

  addChild(subLayer, 0, kTagSprite1);

  schedule(shouldNotLeak, 6);
end;

procedure StressTest2.shouldNotLeak(dt: Single);
var
  subLayer: CCLayer;
begin
  unschedule(shouldNotLeak);
  subLayer :=  CCLayer(getChildByTag(kTagSprite1));
  subLayer.removeAllChildrenWithCleanup(True);
end;

function StressTest2.title: string;
begin
  Result := 'stress test #2: no leaks';
end;

{ CameraOrbitTest }

constructor CameraOrbitTest.Create;
var
  s: CCSize;
  p: CCSprite;
  sprite: CCSprite;
  orbit: CCOrbitCamera;
  //cam: CCCamera;
  ss: CCSize;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  p := CCSprite._create(s_back3);
  addChild(p, 0);
  p.setPosition(s.width/2, s.height/2);
  p.setOpacity(128);

  s := p.ContentSize;
  sprite := CCSprite._create(s_pPathGrossini);
  sprite.Scale := 0.5;
  p.addChild(sprite, 0);
  sprite.setPosition(s.width/4*1, s.height/2);
  //cam := sprite.Camera;
  orbit := CCOrbitCamera._create(2, 1, 0, 0, 360, 0, 0);
  sprite.runAction(CCRepeatForever._create(orbit));

  sprite := CCSprite._create(s_pPathGrossini);
  sprite.Scale := 1;
  p.addChild(sprite, 0);
  sprite.setPosition(s.width/4*2, s.height/2);
  orbit := CCOrbitCamera._create(2, 1, 0, 0, 360, 45, 0);
  sprite.runAction(CCRepeatForever._create(orbit));

  sprite := CCSprite._create(s_pPathGrossini);
  sprite.Scale := 2;
  p.addChild(sprite, 0);
  sprite.setPosition(s.width/4*3, s.height/2);
  ss := sprite.ContentSize;
  orbit := CCOrbitCamera._create(2, 1, 0, 0, 360, 90, -45);
  sprite.runAction(CCRepeatForever._create(orbit));

  orbit := CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 90);
  p.runAction(CCRepeatForever._create(orbit));
  Scale := 1;
end;

procedure CameraOrbitTest.onEnter;
begin
  inherited;
  CCDirector.sharedDirector.setProjection(kCCDirectorProjection3D);
end;

procedure CameraOrbitTest.onExit;
begin
  CCDirector.sharedDirector.setProjection(kCCDirectorProjection2D);
  inherited;
end;

function CameraOrbitTest.title: string;
begin
  Result := 'Camera Orbit test';
end;

end.
