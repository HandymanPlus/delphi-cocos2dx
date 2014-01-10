unit layertest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCTouch, Cocos2dx.CCSprite, Cocos2dx.CCNode, Cocos2dx.CCSet;

type
  LayerTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  LayerTestDemo = class(CCLayer)
  protected
    m_strTitle: string;
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

  LayerTest1 = class(LayerTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    procedure registerWithTouchDispatcher(); override;
    procedure updateSize(touchLocation: CCPoint);

    function ccTouchBegan(pTouch: CCTouch; pEvent: CCEvent): Boolean; override;
    procedure ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent); override;
    procedure ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent); override;
  end;

  LayerTest2 = class(LayerTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  LayerTestBlend = class(LayerTestDemo)
  public
    constructor Create();
    procedure newBlend(dt: Single);
    function title(): string; override;
  end;

  LayerIgnoreAnchorPointPos = class(LayerTestDemo)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure onToggle(pObject: CCObject);
  end;

  LayerIgnoreAnchorPointRot = class(LayerTestDemo)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure onToggle(pObject: CCObject);
  end;

  LayerIgnoreAnchorPointScale = class(LayerTestDemo)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure onToggle(pObject: CCObject);
  end;

  LayerGradient = class(LayerTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    procedure toggleItem(pSender: CCObject);
    procedure ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent); override;
  end;


implementation
uses
  SysUtils,
  dglOpenGL, testResource,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu,
  Cocos2dx.CCTypes, Cocos2dx.CCAction, Cocos2dx.CCActionInterval;

const kTagLayer = 1;
const kLayerIgnoreAnchorPoint = 1000;
var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 6;//7;

function createLayerTestLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := LayerTest1.Create();
    1: bRet := LayerTest2.Create();
    2: bRet := LayerTestBlend.Create();
    3: bRet := LayerGradient.Create;
    4: bRet := LayerIgnoreAnchorPointPos.Create();
    5: bRet := LayerIgnoreAnchorPointRot.Create();
    6: bRet := LayerIgnoreAnchorPointScale.Create();
  end;

  Result := bRet;
end;  

function nextLayerTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createLayerTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backLayerTestAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createLayerTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartLayerTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createLayerTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ LayerTestScene }

procedure LayerTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := nextLayerTestAction();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ LayerTestDemo }

procedure LayerTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := LayerTestScene.Create();
  s.addChild(backLayerTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor LayerTestDemo.Create;
begin
  inherited Create();
end;

destructor LayerTestDemo.Destroy;
begin

  inherited;
end;

procedure LayerTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := LayerTestScene.Create();
  s.addChild(nextLayerTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure LayerTestDemo.onEnter;
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

procedure LayerTestDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := LayerTestScene.Create();
  s.addChild(restartLayerTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function LayerTestDemo.subtitle: string;
begin
  Result := '';
end;

function LayerTestDemo.title: string;
begin
  Result := 'No title';
end;

{ LayerTest1 }

function LayerTest1.ccTouchBegan(pTouch: CCTouch;
  pEvent: CCEvent): Boolean;
var
  tl: CCPoint;
begin
  tl := pTouch.getLocation();
  updateSize(tl);
  Result := True;
end;

procedure LayerTest1.ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent);
var
  tl: CCPoint;
begin
  tl := pTouch.getLocation();
  updateSize(tl);
end;

procedure LayerTest1.ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent);
var
  tl: CCPoint;
begin
  tl := pTouch.getLocation();
  updateSize(tl);
end;

procedure LayerTest1.onEnter;
var
  s: CCSize;
  pLayer: CCLayerColor;
begin
  inherited;
  setTouchEnabled(True);
  s := CCDirector.sharedDirector().getWinSize();
  pLayer := CCLayerColor._create(ccc4($FF, 0, 0, $80), 200, 200);
  pLayer.ignoreAnchorPointForPosition(False);
  pLayer.setPosition(CCPointMake(s.width/2, s.height/2));
  addChild(pLayer, 1, kTagLayer);
end;

procedure LayerTest1.registerWithTouchDispatcher;
var
  pDirector: CCDirector;
begin
  pDirector := CCDirector.sharedDirector();
  pDirector.TouchDispatcher.addTargetedDelegate(Self, kCCMenuHandlerPriority+1, True);
end;

function LayerTest1.title: string;
begin
  Result := 'ColorLayer resize (tap & move)';
end;

procedure LayerTest1.updateSize(touchLocation: CCPoint);
var
  s, newSize: CCSize;
  pL: CCLayerColor;
begin
  s := CCDirector.sharedDirector().getWinSize();
  newSize := CCSizeMake( Abs(touchLocation.x - s.width/2)*2, Abs(touchLocation.y - s.height/2)*2 );
  pL := CCLayerColor(getChildByTag(kTagLayer));
  pL.setContentSize(newSize);
end;

{ LayerTest2 }

procedure LayerTest2.onEnter;
var
  s: CCSize;
  pl1, pl2: CCLayerColor;
  actionTint, actionTintBack, seq1: CCFiniteTimeAction;
  actionFade, actionFadeBack, seq2: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  pl1 := CCLayerColor._create(ccc4(255, 255, 0, 80), 100, 300);
  pl1.setPosition(CCPointMake(s.width/3, s.height/2));
  pl1.ignoreAnchorPointForPosition(False);
  addChild(pl1, 1);

  pl2 := CCLayerColor._create(ccc4(0, 0, 255, 255), 100, 300);
  pl2.setPosition(CCPointMake(2*s.width/3, s.height/2));
  pl2.ignoreAnchorPointForPosition(False);
  addChild(pl2, 1);

  actionTint := CCTintBy._create(2, -255, -127, 0);
  actionTintBack := actionTint.reverse();
  seq1 := CCSequence._create([actionTint, actionTintBack]);
  pl1.runAction(seq1);

  actionFade := CCFadeOut._create(2.0);
  actionFadeBack := actionFade.reverse();
  seq2 := CCSequence._create([ actionFade, actionFadeBack ]);
  pl2.runAction(seq2);
end;

function LayerTest2.title: string;
begin
  Result := 'ColorLayer: fade and tint';
end;

{ LayerTestBlend }

constructor LayerTestBlend.Create;
var
  s: CCSize;
  pL1: CCLayerColor;
  sister1, sister2: CCSprite;
begin
  inherited;

  s := CCDirector.sharedDirector().getWinSize();
  pL1 := CCLayerColor._create(ccc4(255, 255, 255, 80));

  sister1 := CCSprite._create(s_pPathSister1);
  sister2 := CCSprite._create(s_pPathSister2);

  addChild(sister1); addChild(sister2);
  addChild(pL1, 100, kTagLayer);

  sister1.setPosition( CCPointMake(160, s.height/2) );
  sister2.setPosition( CCPointMake(320, s.height/2) );

  schedule(newBlend, 1);
end;

procedure LayerTestBlend.newBlend(dt: Single);
var
  pL: CCLayerColor;
  src, dst: GLenum;
  bf: ccBlendFunc;
begin
  pL := CCLayerColor(getChildByTag(kTagLayer));

  if pL.getBlendFunc().dst = GL_ZERO then
  begin
    src := GL_SRC_ALPHA;
    dst := GL_ONE_MINUS_SRC_ALPHA;
  end else
  begin
    src := GL_ONE_MINUS_DST_COLOR;
    dst := GL_ZERO;
  end;
  bf.src := src; bf.dst := dst;
  pL.setBlendFunc(bf);
end;

function LayerTestBlend.title: string;
begin
  Result := 'ColorLayer: blend';
end;

{ LayerIgnoreAnchorPointPos }

procedure LayerIgnoreAnchorPointPos.onEnter;
var
  s: CCSize;
  pl: CCLayerColor;
  move: CCMoveBy;
  back: CCMoveBy;
  seq: CCFiniteTimeAction;
  child: CCSprite;
  lsize: CCSize;
  item: CCMenuItemFont;
  menu: CCMenu;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  pl := CCLayerColor._create(ccc4(255, 0, 0, 255), 150, 150);
  pl.AnchorPoint := ccp(0.5, 0.5);
  pl.setPosition(ccp(s.width/2, s.height/2));

  move := CCMoveBy._create(2, ccp(100, 2));
  back := CCMoveBy(move.reverse());
  seq := CCSequence._create([move, back]) ;
  pl.runAction( CCRepeatForever._create(CCActionInterval(seq)) );
  Self.addChild(pl, 0, kLayerIgnoreAnchorPoint);

  child := CCSprite._create('Images/grossini.png');
  pl.addChild(child);
  lsize := pl.ContentSize;
  child.setPosition(ccp(lsize.width/2, lsize.height/2));

  item := CCMenuItemFont._create('Toogle ignore anchor point', Self, onToggle);

  menu := CCMenu._create([item]);
  Self.addChild(menu);

  menu.setPosition(ccp(s.width/2, s.height/2));
end;

procedure LayerIgnoreAnchorPointPos.onToggle(pObject: CCObject);
var
  pL: CCNode;
  ignore: Boolean;
begin
  pL := Self.getChildByTag(kLayerIgnoreAnchorPoint);
  ignore := pL.isIgnoreAnchorPointForPosition();
  pL.ignoreAnchorPointForPosition(not ignore);
end;

function LayerIgnoreAnchorPointPos.subtitle: string;
begin
  Result := 'Ignoring Anchor Point for position';
end;

function LayerIgnoreAnchorPointPos.title: string;
begin
  Result := 'IgnoreAnchorPoint - Position';
end;

{ LayerIgnoreAnchorPointRot }

procedure LayerIgnoreAnchorPointRot.onEnter;
var
  s: CCSize;
  pl: CCLayerColor;
  rot: CCRotateBy;
  child: CCSprite;
  lsize: CCSize;
  item: CCMenuItemFont;
  menu: CCMenu;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  pl := CCLayerColor._create(ccc4(255, 0, 0, 255), 150, 150);
  pl.AnchorPoint := ccp(0.5, 0.5);
  pl.setPosition(ccp(s.width/2, s.height/2));

  rot := CCRotateBy._create(2, 360);
  pl.runAction( CCRepeatForever._create(CCActionInterval(rot)) );
  Self.addChild(pl, 0, kLayerIgnoreAnchorPoint);

  child := CCSprite._create('Images/grossini.png');
  pl.addChild(child);
  lsize := pl.ContentSize;
  child.setPosition(ccp(lsize.width/2, lsize.height/2));

  item := CCMenuItemFont._create('Toogle ignore anchor point', Self, onToggle);

  menu := CCMenu._create([item]);
  Self.addChild(menu);

  menu.setPosition(ccp(s.width/2, s.height/2));
end;

procedure LayerIgnoreAnchorPointRot.onToggle(pObject: CCObject);
var
  pL: CCNode;
  ignore: Boolean;
begin
  pL := Self.getChildByTag(kLayerIgnoreAnchorPoint);
  ignore := pL.isIgnoreAnchorPointForPosition();
  pL.ignoreAnchorPointForPosition(not ignore);
end;

function LayerIgnoreAnchorPointRot.subtitle: string;
begin
  Result := 'Ignoring Anchor Point for rotations';
end;

function LayerIgnoreAnchorPointRot.title: string;
begin
  Result := 'IgnoreAnchorPoint - Rotation';
end;

{ LayerIgnoreAnchorPointScale }

procedure LayerIgnoreAnchorPointScale.onEnter;
var
  s: CCSize;
  pl: CCLayerColor;
  scale, back: CCScaleBy;
  seq: CCFiniteTimeAction;
  child: CCSprite;
  lsize: CCSize;
  item: CCMenuItemFont;
  menu: CCMenu;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  pl := CCLayerColor._create(ccc4(255, 0, 0, 255), 150, 150);
  pl.AnchorPoint := ccp(0.5, 0.5);
  pl.setPosition(ccp(s.width/2, s.height/2));

  scale := CCScaleBy._create(2, 2);
  back := CCScaleBy(scale.reverse());
  seq := CCSequence._create([scale, back]);
  pl.runAction( CCRepeatForever._create(CCActionInterval(seq)) );
  Self.addChild(pl, 0, kLayerIgnoreAnchorPoint);

  child := CCSprite._create('Images/grossini.png');
  pl.addChild(child);
  lsize := pl.ContentSize;
  child.setPosition(ccp(lsize.width/2, lsize.height/2));

  item := CCMenuItemFont._create('Toogle ignore anchor point', Self, onToggle);

  menu := CCMenu._create([item]);
  Self.addChild(menu);

  menu.setPosition(ccp(s.width/2, s.height/2));
end;

procedure LayerIgnoreAnchorPointScale.onToggle(pObject: CCObject);
var
  pL: CCNode;
  ignore: Boolean;
begin
  pL := Self.getChildByTag(kLayerIgnoreAnchorPoint);
  ignore := pL.isIgnoreAnchorPointForPosition();
  pL.ignoreAnchorPointForPosition(not ignore);
end;

function LayerIgnoreAnchorPointScale.subtitle: string;
begin
  Result := 'Ignoring Anchor Point for scale';
end;

function LayerIgnoreAnchorPointScale.title: string;
begin
  Result := 'IgnoreAnchorPoint - Scale';
end;

{ LayerGradient }

procedure LayerGradient.ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent);
var
  s: CCSize;
  touch: CCTouch;
  start, diff: CCPoint;
  gradient: CCLayerGradient;
begin
  s := CCDirector.sharedDirector.getWinSize;
  touch := CCTouch(pTouches.getObject(0));
  start := touch.getLocation;
  diff := ccpSub(ccp(s.width/2, s.height/2), start);
  diff := ccpNormalize(diff);

  gradient := CCLayerGradient(getChildByTag(1));
  gradient.setVector(diff);
end;

constructor LayerGradient.Create;
var
  layer1: CCLayerGradient;
  label1, label2: CCLabelTTF;
  item1, item2: CCMenuItemLabel;
  item: CCMenuItemToggle;
  menu: CCMenu;
  s: CCSize;
begin
  inherited;
  layer1 := CCLayerGradient._create(ccc4(255, 0, 0, 255), ccc4(0, 255, 0, 255), ccp(0.9, 0.9));
  addChild(layer1, 0, kTagLayer);
  setTouchEnabled(True);

  label1 := CCLabelTTF._create('Compressed Interpolation: Enabled', 'Marker Felt', 26);
  label2 := CCLabelTTF._create('Compressed Interpolation: Disabled', 'Marker Felt', 26);
  item1 := CCMenuItemLabel._create(label1);
  item2 := CCMenuItemLabel._create(label2);
  item := CCMenuItemToggle.createWithTarget(Self, toggleItem, [item1, item2]);

  menu := CCMenu._create([item]);
  addChild(menu);
  s := CCDirector.sharedDirector.getWinSize;
  menu.setPosition(s.width/2, 100);
end;

function LayerGradient.subtitle: string;
begin
  Result := 'Touch the screen and move your finger';
end;

function LayerGradient.title: string;
begin
  Result := 'LayerGradient';
end;

procedure LayerGradient.toggleItem(pSender: CCObject);
begin

end;

end.
