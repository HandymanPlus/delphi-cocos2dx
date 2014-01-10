unit EffectAdvanceTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry, Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCLabelTTF, Cocos2dx.CCTextureAtlas;

type
  EffectAdvanceScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  EffectAdvanceTextLayer = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; dynamic;
    function subtitle(): string; dynamic;
    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  protected
    m_atlas: CCTextureAtlas;
    m_strTitle: string;
  end;

  Effect1 = class(EffectAdvanceTextLayer)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  Effect2 = class(EffectAdvanceTextLayer)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  Effect3 = class(EffectAdvanceTextLayer)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  Effect4 = class(EffectAdvanceTextLayer)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  Effect5 = class(EffectAdvanceTextLayer)
  public
    procedure onEnter(); override;
    procedure onExit(); override;
    function title(): string; override;
  end;

  Issue631 = class(EffectAdvanceTextLayer)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

implementation
uses
  dglOpenGL,
  SysUtils, 
  Cocos2dx.CCDirector, Cocos2dx.CCPointExtension, Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, Cocos2dx.CCActionGrid,
  Cocos2dx.CCTypes, Cocos2dx.CCAction, Cocos2dx.CCActionInterval, Cocos2dx.CCActionGrid3D,
  Cocos2dx.CCActionTiledGrid, Cocos2dx.CCActionCamera, Cocos2dx.CCDirectorProjection;

const IDC_NEXT = 100;
const IDC_BACK = 101;
const IDC_RESTART = 102;

var sceneIdx: Integer = -1;
const    kTagTextLayer = 1;
const    kTagSprite1 = 1;
const    kTagSprite2 = 2;
const    kTagBackground = 1;
const    kTagLabel = 2;

const MAX_LAYER = 6;

function createEffectAdvanceLayer(nIndex: Integer): CCLayer;
begin
  Result := nil;
  case nIndex of
    0: Result := Effect3.Create;
    1: Result := Effect2.Create;
    2: Result := Effect1.Create;
    3: Result := Effect4.Create;
    4: Result := Effect5.Create;
    5: Result := Issue631.Create;
  end;
end;

function nextEffectAdvanceAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createEffectAdvanceLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backEffectAdvanceAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Dec(sceneIdx);
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + MAX_LAYER;

  pLayer := createEffectAdvanceLayer(sceneIdx);
  pLayer.autorelease;

  Result := pLayer;
end;

function restartEffectAdvanceAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createEffectAdvanceLayer(sceneIdx);
  pLayer.autorelease;
  Result := pLayer;
end;  


{ EffectAdvanceScene }

procedure EffectAdvanceScene.runThisTest;
begin
  addChild(nextEffectAdvanceAction);
  CCDirector.sharedDirector.replaceScene(Self);
end;

{ EffectAdvanceTextLayer }

procedure EffectAdvanceTextLayer.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := EffectAdvanceScene.Create();
  s.addChild(backEffectAdvanceAction);
  CCDirector.sharedDirector.replaceScene(s);
  s.release;
end;

constructor EffectAdvanceTextLayer.Create;
var
  s: CCSize;
  label1, label2: CCLabelTTF;
  strSubtitle: string;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
  bg, grossini, tamara: CCSprite;
  sc, sc_back, sc2, sc2_back: CCFiniteTimeAction;
begin
  inherited;

  s := CCDirector.sharedDirector().getWinSize;

  bg := CCSprite._create('Images/background3.png');
  addChild(bg, 0, kTagBackground);
  bg.setPosition(s.width/2, s.height/2);

  grossini := CCSprite._create('Images/grossinis_sister2.png');
  bg.addChild(grossini, 1, kTagSprite1);
  grossini.setPosition(s.width/3, 200);
  sc := CCScaleBy._create(2, 5);
  sc_back := sc.reverse;
  grossini.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([sc, sc_back]))));


  tamara := CCSprite._create('Images/grossinis_sister1.png');
  bg.addChild(tamara, 1, kTagSprite2);
  tamara.setPosition(2*s.width/3, 200);
  sc2 := CCScaleBy._create(2, 5);
  sc2_back := sc.reverse;
  tamara.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([sc2, sc2_back]))));


  label1 := CCLabelTTF._create(title(), 'Arial', 28);
  addChild(label1, 1);
  label1.setPosition(ccp(s.width/2, s.height-80));
  label1.Tag := ktagLabel;

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

destructor EffectAdvanceTextLayer.Destroy;
begin

  inherited;
end;

procedure EffectAdvanceTextLayer.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := EffectAdvanceScene.Create();
  s.addChild(nextEffectAdvanceAction);
  CCDirector.sharedDirector.replaceScene(s);
  s.release;
end;

procedure EffectAdvanceTextLayer.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := EffectAdvanceScene.Create();
  s.addChild(restartEffectAdvanceAction);
  CCDirector.sharedDirector.replaceScene(s);
  s.release;
end;

function EffectAdvanceTextLayer.subtitle: string;
begin
  Result := '';
end;

function EffectAdvanceTextLayer.title: string;
begin
  Result := 'No title';
end;

{ Effect1 }

procedure Effect1.onEnter;
var
  target: CCNode;
  s: CCSize;
  lens, waves, reuse, delay, orbit, orbit_back: CCFiniteTimeAction;
begin
  inherited;
  target := getChildByTag(kTagBackground);
  s := CCDirector.sharedDirector.getWinSize;
  lens := CCLens3D._create(0.0, CCSizeMake(15,10), ccp(s.width/2,s.height/2), 240);
  waves := CCWave3D._create(10, CCSizeMake(15,10), 18, 15);
  reuse := CCReuseGrid._create(1);
  delay := CCDelayTime._create(8);
  orbit := CCOrbitCamera._create(5, 1, 2, 0, 180, 0, -90);
  orbit_back := orbit.reverse;

  target.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([orbit, orbit_back]))));
  target.runAction(CCSequence._create([lens, delay, reuse, waves]));
end;

function Effect1.title: string;
begin
  Result := 'Lens + Waves3d and OrbitCamera';
end;

{ Effect2 }

procedure Effect2.onEnter;
var
  target: CCNode;
  shaky, shuffle, turnoff, turnon, reuse, delay: CCFiniteTimeAction;
begin
  inherited;
  target := getChildByTag(kTagBackground);

  shaky := CCShakyTiles3D._create(5, CCSizeMake(15,10), 4, false);
  shuffle := CCShuffleTiles._create(0, CCSizeMake(15, 10), 3);
  turnoff := CCTurnOffTiles._create(0, CCSizeMake(15, 10), 3);
  turnon := turnoff.reverse;

  reuse := CCReuseGrid._create(2);
  delay := CCDelayTime._create(1);

  target.runAction(CCSequence._create([shaky, delay, reuse, shuffle, CCActionInterval(delay.copy.autorelease), turnoff, turnon]))
end;

function Effect2.title: string;
begin
  Result := 'ShakyTiles + ShuffleTiles + TurnOffTiles';
end;

{ Effect3 }

procedure Effect3.onEnter;
var
  bg, target1, target2: CCNode;
  waves, shaky: CCActionInterval;
  move: CCFiniteTimeAction;
begin
  inherited;
  bg := getChildByTag(kTagBackground);
  target1 := bg.getChildByTag(kTagSprite1);
  target2 := bg.getChildByTag(kTagSprite2);
  waves := CCWaves._create(5, CCSizeMake(15,10), 5, 20, true, false);
  shaky := CCShaky3D._create(5, CCSizeMake(15,10), 4, false);

  target1.runAction(CCRepeatForever._create(waves));
  target2.runAction(CCRepeatForever._create(shaky));

  move := CCMoveBy._create(3, ccp(200, 0));
  bg.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([move, move.reverse]))));
end;

function Effect3.title: string;
begin
  Result := 'Effects on 2 sprites';
end;

{ Effect4 }

type
  Lens3DTarget = class(CCNode)
  private
    m_pLens3D: CCLens3D;
  public
    procedure setPosition(const newPosition: CCPoint); override;
    class function _create(pAction: CCLens3D): Lens3DTarget;
    destructor Destroy(); override;
  end;

procedure Effect4.onEnter;
var
  lens: CCLens3D;
  move, move_back: CCFiniteTimeAction;
  seq: CCActionInterval;
  pTarget: CCNode;
begin
  inherited;
  lens := CCLens3D._create(10, CCSizeMake(32,24), ccp(100,180), 150);
  move := CCJumpBy._create(5, ccp(380, 0), 100, 4);
  move_back := move.reverse;
  seq := CCActionInterval(CCSequence._create([move, move_back]));

  pTarget := Lens3DTarget._create(lens);
  addChild(pTarget);
  CCDirector.sharedDirector.ActionManager.addAction(seq, pTarget, False);
  runAction(lens);
end;

function Effect4.title: string;
begin
  Result := 'Jumpy Lens3D';
end;

{ Effect5 }

procedure Effect5.onEnter;
var
  effect, stopEffect: CCFiniteTimeAction;
  bg: CCNode;
begin
  inherited;
  effect := CCLiquid._create(2, CCSizeMake(32,24), 1, 20);
  stopEffect := CCSequence._create([effect, CCDelayTime._create(2), CCStopGrid._create() ]);
  bg := getChildByTag(kTagBackground);
  bg.runAction(stopEffect);
end;

procedure Effect5.onExit;
begin
  inherited;
  CCDirector.sharedDirector.setProjection(kCCDirectorProjection3D);
end;

function Effect5.title: string;
begin
  Result := 'Test Stop-Copy-Restar';
end;

{ Issue631 }

procedure Issue631.onEnter;
var
  effect: CCFiniteTimeAction;
  bg: CCNode;
  layer, layer2: CCLayerColor;
  sprite, fog: CCSprite;
  bf: ccBlendFunc;
begin
  inherited;
  effect := CCSequence._create([ CCDelayTime._create(2), CCShaky3D._create(5.0, CCSizeMake(5, 5), 16, false) ]);
  bg := getChildByTag(kTagBackground);
  removeChild(bg, True);
  layer := CCLayerColor._create(ccc4(255, 0, 0, 255));
  addChild(layer, -10);
  sprite := CCSprite._create('Images/grossini.png');
  sprite.setPosition(50, 80);
  layer.addChild(sprite, 10);

  layer2 := CCLayerColor._create(ccc4(0, 255, 0, 255));
  fog := CCSprite._create('Images/Fog.png');

  bf.src := GL_SRC_ALPHA; bf.dst := GL_ONE_MINUS_SRC_ALPHA;
  fog.setBlendFunc(bf);
  layer2.addChild(fog, 1);
  addChild(layer2, 1);

  layer2.runAction(CCRepeatForever._create(CCActionInterval(effect)));
end;

function Issue631.subtitle: string;
begin
  Result := 'Effect image should be 100% opaque. Testing issue #631';
end;

function Issue631.title: string;
begin
  Result := 'Testing Opacity';
end;

{ Lens3DTarget }

class function Lens3DTarget._create(pAction: CCLens3D): Lens3DTarget;
var
  pRet: Lens3DTarget;
begin
  pRet := Lens3DTarget.Create;
  pRet.m_pLens3D := pAction;
  pRet.m_pLens3D.retain;
  pRet.autorelease;
  Result := pRet;
end;

procedure Lens3DTarget.setPosition(const newPosition: CCPoint);
begin
  m_pLens3D.setPosition(newPosition);
end;

destructor Lens3DTarget.Destroy;
begin
  m_pLens3D.release;
  inherited;
end;

end.
