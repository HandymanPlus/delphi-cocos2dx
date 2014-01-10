unit ParticleTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCTouch, Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCParticleSystem, Cocos2dx.CCParticleBatchNode;

type
  ParticleTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  ParticleTestDemo = class(CCLayerColor)
  protected
    m_emitter: CCParticleSystem;
    m_background: CCSprite;
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; dynamic;
    function subtitle(): string; dynamic;

    procedure onEnter(); override;
    procedure update(time: Single); override;
    procedure registerWithTouchDispatcher(); override;
    function ccTouchBegan(pTouch: CCTouch; pEvent: CCEvent): Boolean; override;
    procedure ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent); override;
    procedure ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent); override;

    procedure setEmitterPosition();

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
    procedure toggleCallback(pObj: CCObject);
  end;

  DemoFire = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoFirework = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoSun = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoGalaxy = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoFlower = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoBigFlower = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoRotFlower = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoMeteor = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoSpiral = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoExplosion = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoSmoke = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoSnow = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoRain = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  Issue870 = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure updateQuads(dt: Single);
  private
    m_nIndex: Integer;
  end;

  DemoParticleFromFile = class(ParticleTestDemo)
  public
    m_title: string;
    constructor Create(filename: string);
    procedure onEnter(); override;
    function title(): string; override;
  end;

  ParticleReorder = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    procedure reorderParticles(dt: Single);
    function title(): string; override;
    function subtitle(): string; override;
  private
    m_nOrder: Cardinal;
  end;

  ParticleBatchHybrid = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    procedure switchRender(dt: Single);
    function title(): string; override;
    function subtitle(): string; override;
  private
    m_pParent1, m_pParent2: CCNode;
  end;

  ParticleBatchMultipleEmitters = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  MultipleParticleSystems = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure update(time: Single); override;
  end;

  MultipleParticleSystemsBatched = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure update(time: Single); override;
  private
    //m_pBatchNode: CCParticleBatchNode;
  end;

  AddAndDeleteParticleSystems = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure update(time: Single); override;
    procedure removeSystem(dt: Single);
  private
    m_pBatchNode: CCParticleBatchNode;
  end;

  ReorderParticleSystems = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure update(time: Single); override;
    procedure reorderSystem(dt: Single);
  private
    m_pBatchNode: CCParticleBatchNode;
  end;

  PremultipliedAlphaTest = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  PremultipliedAlphaTest2 = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  RadiusMode1 = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  RadiusMode2 = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  Issue1201 = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  Issue704 = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  DemoRing = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  DemoModernArt = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  ParallaxParticle = class(ParticleTestDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

implementation
uses
  SysUtils, dglOpenGL, Cocos2dx.CCAction, testResource, Cocos2dx.CCArray,
  Cocos2dx.CCLabelAtlas, Math,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCTextureCache, Cocos2dx.CCParticleExamples,
  Cocos2dx.CCTypes, Cocos2dx.CCActionInterval, Cocos2dx.CCParticleSystemQuad;

var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 43;
  kTagParticleCount = 1;

function createTestLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := ParticleReorder.Create;
    1: bRet := ParticleBatchHybrid.Create;
    2: bRet := ParticleBatchMultipleEmitters.Create;
    3: bRet := DemoFlower.Create;
    4: bRet := DemoGalaxy.Create;
    5: bRet := DemoFirework.Create;
    6: bRet := DemoSpiral.Create;
    7: bRet := DemoSun.Create;
    8: bRet := DemoMeteor.Create;
    9: bRet := DemoFire.Create;
    10: bRet := DemoSmoke.Create;
    11: bRet := DemoExplosion.Create;
    12: bRet := DemoSnow.Create;
    13: bRet := DemoRain.Create;
    14: bRet := DemoBigFlower.Create;
    15: bRet := DemoRotFlower.Create;
    16: bRet := DemoModernArt.Create;
    17: bRet := DemoRing.Create;
    18: bRet := ParallaxParticle.Create;
    19: bRet := DemoParticleFromFile.Create('BoilingFoam');
    20: bRet := DemoParticleFromFile.Create('BurstPipe');
    21: bRet := DemoParticleFromFile.Create('Comet');
    22: bRet := DemoParticleFromFile.Create('debian');
    23: bRet := DemoParticleFromFile.Create('ExplodingRing');
    24: bRet := DemoParticleFromFile.Create('LavaFlow');
    25: bRet := DemoParticleFromFile.Create('SpinningPeas');
    26: bRet := DemoParticleFromFile.Create('SpookyPeas');
    27: bRet := DemoParticleFromFile.Create('Upsidedown');
    28: bRet := DemoParticleFromFile.Create('Flower');
    29: bRet := DemoParticleFromFile.Create('Spiral');
    30: bRet := DemoParticleFromFile.Create('Galaxy');
    31: bRet := DemoParticleFromFile.Create('Phoenix');
    32: bRet := RadiusMode1.Create;
    33: bRet := RadiusMode2.Create;
    34: bRet := Issue704.Create;
    35: bRet := Issue870.Create;
    36: bRet := Issue1201.Create;
    37: bRet := MultipleParticleSystems.Create;
    38: bRet := MultipleParticleSystemsBatched.Create;
    39: bRet := AddAndDeleteParticleSystems.Create;
    40: bRet := ReorderParticleSystems.Create;
    41: bRet := PremultipliedAlphaTest.Create;
    42: bRet := PremultipliedAlphaTest2.Create;
  end;

  Result := bRet;
end;  

function nextTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backTestAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ ParticleTestScene }

procedure ParticleTestScene.runThisTest;
begin
    addChild(nextTestAction());
    CCDirector.sharedDirector().replaceScene(Self);

end;

{ ParticleTestDemo }

procedure ParticleTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ParticleTestScene.Create();
  s.addChild(backTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function ParticleTestDemo.ccTouchBegan(pTouch: CCTouch;
  pEvent: CCEvent): Boolean;
begin
  Result := True;
end;

procedure ParticleTestDemo.ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent);
var
  location, pos: CCPoint;
begin
  location := pTouch.getLocation;
  pos := CCPointZero;
  if m_background <> nil then
    pos := m_background.convertToWorldSpace(CCPointZero);

  if m_emitter <> nil then
    m_emitter.setPosition(ccpSub(location, pos));
end;

procedure ParticleTestDemo.ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent);
begin
  ccTouchEnded(pTouch, pEvent);
end;

constructor ParticleTestDemo.Create;
begin
  inherited;
end;

destructor ParticleTestDemo.Destroy;
begin
  CC_SAFE_RELEASE(m_emitter);
  inherited;
end;

procedure ParticleTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ParticleTestScene.Create();
  s.addChild(nextTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure ParticleTestDemo.onEnter;
var
  s: CCSize;
  plabel: CCLabelTTF;
  sub: CCLabelTTF;
  item1, item2, item3: CCMenuItemImage;
  item4: CCMenuItemToggle;
  menu: CCMenu;
  labelAtlas: CCLabelAtlas;
  move, move_back: CCFiniteTimeAction;
  seq: CCActionInterval;
begin
  inherited;

  initWithColor(ccc4(127, 127, 127, 255));
  m_emitter := nil;
  setTouchEnabled(True);

  s := CCDirector.sharedDirector.getWinSize;
  
  plabel := CCLabelTTF._create(title, 'Arial', 28);
  addChild(plabel, 100, 1000);
  plabel.setPosition(CCPointMake(s.width/2, s.height-50));

  sub := CCLabelTTF._create(subtitle, 'Arial', 16);
  addChild(sub, 100);
  sub.setPosition(ccp(s.width/2, s.height - 80));

  item1 := CCMenuItemImage._create('Images/b1.png', 'Images/b2.png', Self, backCallback);
  item2 := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, restartCallback);
  item3 := CCMenuItemImage._create('Images/f1.png', 'Images/f2.png', Self, nextCallback);
  item4 := CCMenuItemToggle.createWithTarget(Self, toggleCallback,
    [CCMenuItemFont._create('Free Movement'), CCMenuItemFont._create('Relative Movement'), CCMenuItemFont._create('Grouped Movement')  ]);

  menu := CCMenu._create([item1, item2, item3, item4]);

  menu.setPosition(CCPointZero);
  item1.setPosition(ccp( s.width/2 - item2.ContentSize.width*2, item2.ContentSize.height/2 ));
  item2.setPosition(ccp( s.width/2, item2.ContentSize.height/2 ));
  item3.setPosition(ccp( s.width/2 + item2.ContentSize.width * 2, item2.ContentSize.height/2 ));
  item4.setPosition(ccp(0, 100));
  item4.AnchorPoint := CCPointZero;

  addChild(menu, 100);

  labelAtlas := CCLabelAtlas._create('0000', 'fps_images.png', 12, 32, Byte('.'));
  addChild(labelAtlas, 100, kTagParticleCount);
  labelAtlas.setPosition(ccp(s.width-60, 50));

  m_background := CCSprite._create(s_back3);
  addChild(m_background, 5);
  m_background.setPosition(ccp(s.width/2, s.height-180));

  move := CCMoveBy._create(4, ccp(300, 0));
  move_back := move.reverse;
  seq := CCActionInterval(CCSequence._create([move, move_back]));
  m_background.runAction(CCRepeatForever._create(seq));

  scheduleUpdate;
end;

procedure ParticleTestDemo.registerWithTouchDispatcher;
begin
  CCDirector.sharedDirector.TouchDispatcher.addTargetedDelegate(Self, 0, False);
end;

procedure ParticleTestDemo.restartCallback(pObj: CCObject);
begin
  if m_emitter <> nil then
    m_emitter.resetSystem();
end;

procedure ParticleTestDemo.setEmitterPosition;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector.getWinSize;
  if m_emitter <> nil then
    m_emitter.setPosition(ccp(s.width/2, s.height/2));
end;

function ParticleTestDemo.subtitle: string;
begin
  Result := '';
end;

function ParticleTestDemo.title: string;
begin
  Result := 'No title';
end;

procedure ParticleTestDemo.toggleCallback(pObj: CCObject);
begin
  if m_emitter <> nil then
  begin
    if m_emitter.PositionType = kCCPositionTypeGrouped then
      m_emitter.PositionType := kCCPositionTypeFree
    else if m_emitter.PositionType = kCCPositionTypeFree then
      m_emitter.PositionType := kCCPositionTypeRelative
    else if m_emitter.PositionType = kCCPositionTypeRelative then
      m_emitter.PositionType := kCCPositionTypeGrouped;
  end;  
end;

procedure ParticleTestDemo.update(time: Single);
var
  atlas: CCLabelAtlas;
  str: string;
begin
  if m_emitter <> nil then
  begin
    atlas := CCLabelAtlas(getChildByTag(kTagParticleCount));
    str := Format('%.4d', [m_emitter.ParticleCount]);
    atlas.setString(str);
  end;  
end;

{ DemoFire }

procedure DemoFire.onEnter;
var
  p: CCPoint;
begin
  inherited;

  m_emitter := CCParticleFire._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);

  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));
  p := m_emitter.getPosition;
  m_emitter.setPosition(ccp(p.x, 100));

  setEmitterPosition();
end;

function DemoFire.title: string;
begin
  Result := 'ParticleFire';
end;

{ DemoFirework }

procedure DemoFirework.onEnter;
begin
  inherited;

  m_emitter := CCParticleFireworks._create;
  m_emitter.retain();
  m_background.addChild(m_emitter, 10);

  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_stars1));

  setEmitterPosition();
end;

function DemoFirework.title: string;
begin
  Result := 'ParticleFireworks';
end;

{ DemoSun }

procedure DemoSun.onEnter;
begin
  inherited;

  m_emitter := CCParticleSun._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);

  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));

  setEmitterPosition();
end;

function DemoSun.title: string;
begin
  Result := 'ParticleSun';
end;

{ DemoGalaxy }

procedure DemoGalaxy.onEnter;
begin
  inherited;

  m_emitter := CCParticleGalaxy._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);

  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));

  setEmitterPosition();
end;

function DemoGalaxy.title: string;
begin
  Result := 'ParticleGalaxy';
end;

{ DemoFlower }

procedure DemoFlower.onEnter;
begin
  inherited;

  m_emitter := CCParticleFlower._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_stars1));

  setEmitterPosition;
end;

function DemoFlower.title: string;
begin
  Result := 'ParticleFlower';
end;

{ DemoBigFlower }

procedure DemoBigFlower.onEnter;
var
  startColor, startColorVar: ccColor4F;
  endColor, endColorVar: ccColor4F;
begin
  inherited;

  m_emitter := CCParticleSystemQuad.Create;
  m_emitter.initWithTotalParticles(50);

  m_background.addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_stars1));
  m_emitter.Duration := -1;
  m_emitter.setGravity(CCPointZero);
  m_emitter.Angle := 90;
  m_emitter.AngleVar := 360;
  m_emitter.setSpeed(160);
  m_emitter.setSpeedVar(20);
  m_emitter.setRadialAccel(-120);
  m_emitter.setRadialAccelVar(0);

  m_emitter.setTangentialAccel(30);
  m_emitter.setTangentialAccelVar(0);

  m_emitter.setPosition(ccp(160, 240));
  m_emitter.PosVar := CCPointZero;

  m_emitter.Life := 4;
  m_emitter.LifeVar := 1;
  m_emitter.StartSpin := 0;
  m_emitter.StartSizeVar := 0;
  m_emitter.EndSpin := 0;
  m_emitter.EndSpinVar := 0;

  startColor.r := 0.5; startColor.g := 0.5; startColor.b := 0.5; startColor.a := 0.5;
  m_emitter.StartColor := startColor;
  startColorVar.r := 0.5; startColorVar.g := 0.5; startColorVar.b := 0.5; startColorVar.a := 0.5;
  m_emitter.StartColorVar := startColorVar;

  endColor.r := 0.1; endColor.g := 0.1; endColor.b := 0.1; endColor.a := 0.1;
  m_emitter.EndColor := endColor;
  endColorVar.r := 0.1; endColorVar.g := 0.1; endColorVar.b := 0.1; endColorVar.a := 0.1;
  m_emitter.EndColorVar := endColorVar;

  m_emitter.StartSize := 80;
  m_emitter.StartSizeVar := 40;
  m_emitter.EndSize := kParticleStartSizeEqualToEndSize;

  m_emitter.EmissionRate := m_emitter.TotalParticles/m_emitter.Life;
  m_emitter.setBlendAdditive(True);
  setEmitterPosition();
end;

function DemoBigFlower.title: string;
begin
  Result := 'ParticleBigFlower';
end;

{ DemoRotFlower }

procedure DemoRotFlower.onEnter;
var
  startColor, startColorVar: ccColor4F;
  endColor, endColorVar: ccColor4F;
begin
  inherited;

  m_emitter := CCParticleSystemQuad.Create;
  m_emitter.initWithTotalParticles(300);

  m_background.addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_stars2));

  m_emitter.Duration := -1;
  m_emitter.setGravity(CCPointZero);
  m_emitter.Angle := 90;
  m_emitter.AngleVar := 360;
  m_emitter.setSpeed(160);
  m_emitter.setSpeedVar(20);
  m_emitter.setRadialAccel(-120);
  m_emitter.setRadialAccelVar(0);
  m_emitter.setTangentialAccel(30);
  m_emitter.setTangentialAccelVar(0);
  m_emitter.setPosition(ccp(160, 240));
  m_emitter.PosVar := CCPointZero;
  m_emitter.Life := 3;
  m_emitter.LifeVar := 1;
  m_emitter.StartSpin := 0;
  m_emitter.StartSpinVar := 0;
  m_emitter.EndSpin := 0;
  m_emitter.EndSpinVar := 2000;

  startColor.r := 0.5; startColor.g := 0.5; startColor.b := 0.5; startColor.a := 1;
  m_emitter.StartColor := startColor;
  startColorVar.r := 0.5; startColorVar.g := 0.5; startColorVar.b := 0.5; startColorVar.a := 1;
  m_emitter.StartColorVar := startColorVar;

  endColor.r := 0.1; endColor.g := 0.1; endColor.b := 0.1; endColor.a := 0.2;
  m_emitter.EndColor := endColor;
  endColorVar.r := 0.1; endColorVar.g := 0.1; endColorVar.b := 0.1; endColorVar.a := 0.2;
  m_emitter.EndColorVar := endColorVar;

  m_emitter.StartSize := 30;
  m_emitter.StartSizeVar := 0;
  m_emitter.EndSize := kParticleStartSizeEqualToEndSize;
  m_emitter.EmissionRate := m_emitter.TotalParticles/m_emitter.Life;
  m_emitter.setBlendAdditive(False);
  setEmitterPosition();
end;

function DemoRotFlower.title: string;
begin
  Result := 'ParticleRotFlower';
end;

{ DemoMeteor }

procedure DemoMeteor.onEnter;
begin
  inherited;
  m_emitter := CCParticleMeteor._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));

  setEmitterPosition;
end;

function DemoMeteor.title: string;
begin
  Result := 'ParticleMeteor';
end;

{ DemoSpiral }

procedure DemoSpiral.onEnter;
begin
  inherited;
  m_emitter := CCParticleSpiral._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));

  setEmitterPosition;
end;

function DemoSpiral.title: string;
begin
  Result := 'ParticleSpiral';
end;

{ DemoExplosion }

procedure DemoExplosion.onEnter;
begin
  inherited;
  m_emitter := CCParticleExplosion._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));
  m_emitter.setAutoRemoveOnFinish(True);

  setEmitterPosition;
end;

function DemoExplosion.title: string;
begin
  Result := 'ParticleExplosion';
end;

{ DemoSmoke }

procedure DemoSmoke.onEnter;
var
  p: CCPoint;
begin
  inherited;
  m_emitter := CCParticleSmoke._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));

  p := m_emitter.getPosition;
  m_emitter.setPosition(CCPointMake(p.x, 100));

  setEmitterPosition;
end;

function DemoSmoke.title: string;
begin
  Result := 'ParticleSmoke';
end;

{ DemoSnow }

procedure DemoSnow.onEnter;
var
  p: CCPoint;
  startColor, startColorVar: ccColor4F;
begin
  inherited;

  m_emitter := CCParticleSnow._create;
  m_emitter.retain;
  m_background.addChild(m_emitter);

  p := m_emitter.getPosition;
  m_emitter.setPosition(ccp(p.x, p.y-110));
  m_emitter.Life := 3;
  m_emitter.LifeVar := 1;

  m_emitter.setGravity(ccp(0, -10));

  m_emitter.setSpeed(130);
  m_emitter.setSpeedVar(30);

  startColor := m_emitter.StartColor;
  startColor.r := 0.9;
  startColor.g := 0.9;
  startColor.b := 0.9;
  m_emitter.StartColor := startColor;

  startColorVar := m_emitter.StartColorVar;
  startColorVar.b := 0.1;
  m_emitter.StartColorVar := startColorVar;

  m_emitter.EmissionRate := m_emitter.TotalParticles/m_emitter.Life;
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_snow));
  setEmitterPosition;
end;

function DemoSnow.title: string;
begin
  Result := 'ParticleSnow';
end;

{ DemoRain }

procedure DemoRain.onEnter;
var
  p: CCPoint;
begin
  inherited;
  m_emitter := CCParticleRain._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);

  p := m_emitter.getPosition;
  m_emitter.setPosition(ccp(p.x, p.y-100));
  m_emitter.Life := 4;
  
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));

  setEmitterPosition;
end;

function DemoRain.title: string;
begin
  Result := 'ParticleRain';
end;

{ Issue870 }

procedure Issue870.onEnter;
var
  pSys: CCParticleSystemQuad;
begin
  inherited;

  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  pSys := CCParticleSystemQuad.Create;
  pSys.initWithFile('Particles/SpinningPeas.plist');
  pSys.setTextureWithRect(CCTextureCache.sharedTextureCache().addImage('Images/particles.png'), CCRectMake(0, 0, 32, 32));
  addChild(pSys, 10);
  m_emitter := pSys;

  m_nIndex := 0;
  schedule(updateQuads, 2);
end;

function Issue870.subtitle: string;
begin
  Result := 'Every 2 seconds the particle should change';
end;

function Issue870.title: string;
begin
  Result := 'Issue 870. SubRect';
end;

procedure Issue870.updateQuads(dt: Single);
var
  rect: CCRect;
  pSys: CCParticleSystemQuad;
begin
  m_nIndex := (m_nIndex + 1) mod 4;
  rect := CCRectMake(m_nIndex * 32, 0, 32, 32);
  pSys := CCParticleSystemQuad(m_emitter);
  pSys.setTextureWithRect(m_emitter.getTexture, rect);
end;

{ DemoParticleFromFile }

constructor DemoParticleFromFile.Create(filename: string);
begin
  inherited Create();
  m_title := filename;
end;

procedure DemoParticleFromFile.onEnter;
var
  filename: string;
begin
  inherited;

  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_emitter := CCParticleSystemQuad.Create;
  filename := 'Particles/' + m_title + '.plist';
  m_emitter.initWithFile(filename);
  addChild(m_emitter, 10);

  setEmitterPosition();
end;

function DemoParticleFromFile.title: string;
begin
  Result := m_title;
end;

{ ParticleReorder }

procedure ParticleReorder.onEnter;
var
  ignore: CCParticleSystem;
  parent1, parent2, parent: CCNode;
  i: Cardinal;
  emitter1, emitter2, emitter3: CCParticleSystemQuad;
  s: CCSize;
  neg: Integer;
begin
  inherited;
  m_nOrder := 0;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  ignore := CCParticleSystemQuad._create('Particles/SmallSun.plist');
  parent1 := CCNode._create;
  parent2 := CCParticleBatchNode.createWithTexture(ignore.getTexture);
  ignore.unscheduleUpdate;

  for i := 0 to 1 do
  begin
    if i = 0 then
      parent := parent1
    else
      parent := parent2;

    emitter1 := CCParticleSystemQuad._create('Particles/SmallSun.plist');
    emitter1.StartColor := ccc4F(1, 0, 0, 1);
    emitter1.setBlendAdditive(False);

    emitter2 := CCParticleSystemQuad._create('Particles/SmallSun.plist');
    emitter2.StartColor := ccc4F(0, 1, 0, 1);
    emitter2.setBlendAdditive(False);

    emitter3 := CCParticleSystemQuad._create('Particles/SmallSun.plist');
    emitter3.StartColor := ccc4F(0, 0, 1, 1);
    emitter3.setBlendAdditive(False);

    s := CCDirector.sharedDirector.getWinSize;

    if i = 0 then
      neg := 1
    else
      neg := -1;

    emitter1.setPosition( ccp(s.width/2-30, s.height/2 + 60*neg) );
    emitter2.setPosition( ccp(s.width/2, s.height/2 + 60*neg) );
    emitter3.setPosition( ccp(s.width/2+30, s.height/2 + 60*neg) );

    parent.addChild(emitter1, 0, 1);
    parent.addChild(emitter2, 0, 2);
    parent.addChild(emitter3, 0, 3);

    addChild(parent, 10, 1000+i);
  end;
  schedule(reorderParticles, 1);
end;

procedure ParticleReorder.reorderParticles(dt: Single);
var
  i: Integer;
  parent, child1, child2, child3: CCNode;
begin
  for i := 0 to 1 do
  begin
    parent := getChildByTag(1000+i);

    child1 := parent.getChildByTag(1);
    child2 := parent.getChildByTag(2);
    child3 := parent.getChildByTag(3);

    if m_nOrder mod 3 = 0 then
    begin
      parent.reorderChild(child1, 1);
      parent.reorderChild(child2, 2);
      parent.reorderChild(child3, 3);
    end else if m_nOrder mod 3 = 1 then
    begin
      parent.reorderChild(child1, 3);
      parent.reorderChild(child2, 1);
      parent.reorderChild(child3, 2);
    end else if m_nOrder mod 3 = 2 then
    begin
      parent.reorderChild(child1, 2);
      parent.reorderChild(child2, 3);
      parent.reorderChild(child3, 1);
    end;      
  end;
  Inc(m_nOrder); 
end;

function ParticleReorder.subtitle: string;
begin
  Result := 'Reordering particles with and without batches batches';
end;

function ParticleReorder.title: string;
begin
  Result := 'Reordering particles';
end;

{ ParticleBatchHybrid }

procedure ParticleBatchHybrid.onEnter;
var
  batch: CCParticleBatchNode;
  node: CCNode;
begin
  inherited;

  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_emitter := CCParticleSystemQuad._create('Particles/LavaFlow.plist');
  m_emitter.retain;
  batch := CCParticleBatchNode.createWithTexture(m_emitter.getTexture);

  batch.addChild(m_emitter);

  addChild(batch, 10);

  schedule(switchRender, 2);

  node := CCNode._create;
  addChild(node);

  m_pParent1 := batch;
  m_pParent2 := node;
end;

function ParticleBatchHybrid.subtitle: string;
begin
  Result := 'Hybrid: batched and non batched every 2 seconds';
end;

procedure ParticleBatchHybrid.switchRender(dt: Single);
var
  usingBatch: Boolean;
  newParent: CCNode;
begin
  usingBatch := m_emitter.BatchNode <> nil;
  m_emitter.removeFromParentAndCleanup(False);

  if usingBatch then
    newParent := m_pParent2
  else
    newParent := m_pParent1;

  newParent.addChild(m_emitter);
end;

function ParticleBatchHybrid.title: string;
begin
  Result := 'Paticle Batch';
end;

{ ParticleBatchMultipleEmitters }

procedure ParticleBatchMultipleEmitters.onEnter;
var
  emitter1, emitter2, emitter3: CCParticleSystemQuad;
  s: CCSize;
  batch: CCParticleBatchNode;
begin
  inherited;

  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  emitter1 := CCParticleSystemQuad._create('Particles/LavaFlow.plist');
  emitter1.StartColor := ccc4F(1, 0, 0, 1);
  emitter2 := CCParticleSystemQuad._create('Particles/LavaFlow.plist');
  emitter2.StartColor := ccc4F(0, 1, 0, 1);
  emitter3 := CCParticleSystemQuad._create('Particles/LavaFlow.plist');
  emitter3.StartColor := ccc4F(0, 0, 1, 1);

  s := CCDirector.sharedDirector.getWinSize;

  emitter1.setPosition(s.width/1.25, s.height/1.25);
  emitter2.setPosition(s.width/2, s.height/2);
  emitter3.setPosition(s.width/4, s.height/4);

  batch := CCParticleBatchNode.createWithTexture(emitter1.getTexture);

  batch.addChild(emitter1, 0);
  batch.addChild(emitter2, 0);
  batch.addChild(emitter3, 0);

  addChild(batch, 10);
end;

function ParticleBatchMultipleEmitters.subtitle: string;
begin
  Result := 'Multiple emitters. One Batch';
end;

function ParticleBatchMultipleEmitters.title: string;
begin
  Result := 'Paticle Batch';
end;

{ MultipleParticleSystems }

procedure MultipleParticleSystems.onEnter;
var
  pSys: CCParticleSystemQuad;
  i: Integer;
begin
  inherited;

  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  CCTextureCache.sharedTextureCache.addImage('Images/particles.png');
  for i := 0 to 4 do
  begin
    pSys := CCParticleSystemQuad._create('Particles/SpinningPeas.plist');
    pSys.setPosition(i*50, i*50);
    pSys.PositionType := kCCPositionTypeGrouped;
    addChild(pSys);
  end;

  m_emitter := nil;
end;

function MultipleParticleSystems.subtitle: string;
begin
  Result := 'v1.1 test: FPS should be lower than next test';
end;

function MultipleParticleSystems.title: string;
begin
  Result := 'Multiple particle systems';
end;

procedure MultipleParticleSystems.update(time: Single);
var
  atlas: CCLabelAtlas;
  item: CCParticleSystem;
  pObj: CCObject;
  i, count: Cardinal;
  str: string;
begin
  atlas := CCLabelAtlas(getChildByTag(kTagParticleCount));
  count := 0;
  if (m_pChildren <> nil) and (m_pChildren.count > 0) then
    for i := 0 to m_pChildren.count-1 do
    begin
      pObj := m_pChildren.objectAtIndex(i);
      if pObj is CCParticleSystem then
      begin
        item := CCParticleSystem(pObj);
        count := count + item.ParticleCount;
      end;
    end;

  str := Format('%.4d', [count]);
  atlas.setString(str);
end;

{ MultipleParticleSystemsBatched }

procedure MultipleParticleSystemsBatched.onEnter;
var
  batchNode: CCParticleBatchNode;
  i: Integer;
  pPSysQuad: CCParticleSystemQuad;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  batchNode := CCParticleBatchNode.Create;
  batchNode.initWithTexture(nil, 3000);

  addChild(batchNode, 1, 2);

  for i := 0 to 4 do
  begin
    pPSysQuad := CCParticleSystemQuad._create('Particles/SpinningPeas.plist');
    pPSysQuad.PositionType := kCCPositionTypeGrouped;
    pPSysQuad.setPosition(i*50, i*50);

    batchNode.setTexture(pPSysQuad.getTexture);
    batchNode.addChild(pPSysQuad);
  end;
  batchNode.release;
  m_emitter := nil;
end;

function MultipleParticleSystemsBatched.subtitle: string;
begin
  Result := 'v1.1 test: should perform better than previous test';
end;

function MultipleParticleSystemsBatched.title: string;
begin
  Result := 'Multiple particle systems batched';
end;

procedure MultipleParticleSystemsBatched.update(time: Single);
var
  atlas: CCLabelAtlas;
  batchNode: CCNode;
  pObj: CCObject;
  //item: CCParticleSystem;
  count, i: Cardinal;
  str: string;
  pAry: CCArray;
begin
  inherited;
  atlas := CCLabelAtlas(getChildByTag(kTagParticleCount));
  count := 0;
  batchNode := getChildByTag(2);
  pAry := batchNode.Children;
  if (pAry <> nil) and (pAry.count > 0) then
    for i := 0 to pAry.count-1 do
    begin
      pObj := pAry.objectAtIndex(i);
      if pObj is CCParticleSystem then
      begin
        count := count + CCParticleSystem(pObj).ParticleCount;
      end;  
    end;

  str := Format('%.4d', [count]);
  atlas.setString(str);
end;

{ AddAndDeleteParticleSystems }

procedure AddAndDeleteParticleSystems.onEnter;
var
  i: Integer;
  pSysQuad: CCParticleSystemQuad;
  randZ: Integer;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_pBatchNode := CCParticleBatchNode.createWithTexture(nil, 16000);
  addChild(m_pBatchNode, 1, 2);

  for i := 0 to 5 do
  begin
    pSysQuad := CCParticleSystemQuad._create('Particles/Spiral.plist');
    m_pBatchNode.setTexture(pSysQuad.getTexture);

    pSysQuad.PositionType := kCCPositionTypeGrouped;
    pSysQuad.TotalParticles := 200;

    pSysQuad.setPosition(i*15+100, i*15+100);

    randZ := RandomRange(0, 99);
    m_pBatchNode.addChild(pSysQuad, randZ, -1);
  end;

  schedule(removeSystem, 0.5);
  m_emitter := nil;
end;

procedure AddAndDeleteParticleSystems.removeSystem(dt: Single);
var
  nchildrencount: Integer;
  urand: Integer;
  pSysQuad: CCParticleSystemQuad;
  randZ: Integer;
begin
  nchildrencount := m_pBatchNode.Children.count;
  if nchildrencount > 0 then
  begin
    urand := RandomRange(0, nchildrencount-2);
    m_pBatchNode.removeChild(CCNode(m_pBatchNode.Children.objectAtIndex(urand)), True);
    pSysQuad := CCParticleSystemQuad._create('Particles/Spiral.plist');
    pSysQuad.PositionType := kCCPositionTypeGrouped;
    pSysQuad.TotalParticles := 200;
    pSysQuad.setPosition(RandomRange(0, 299), RandomRange(0, 399));
    randZ := RandomRange(0, 99);
    m_pBatchNode.addChild(pSysQuad, randZ, -1);
  end;  
end;

function AddAndDeleteParticleSystems.subtitle: string;
begin
  Result := 'v1.1 test: every 2 sec 1 system disappear, 1 appears';
end;

function AddAndDeleteParticleSystems.title: string;
begin
  Result := 'Add and remove Particle System';
end;

procedure AddAndDeleteParticleSystems.update(time: Single);
var
  atlas: CCLabelAtlas;
  batchNode: CCNode;
  pObj: CCObject;
  //item: CCParticleSystem;
  count, i: Cardinal;
  str: string;
  pAry: CCArray;
begin
  inherited;
  atlas := CCLabelAtlas(getChildByTag(kTagParticleCount));
  count := 0;
  batchNode := getChildByTag(2);
  pAry := batchNode.Children;
  if (pAry <> nil) and (pAry.count > 0) then
    for i := 0 to pAry.count-1 do
    begin
      pObj := pAry.objectAtIndex(i);
      if pObj is CCParticleSystem then
      begin
        count := count + CCParticleSystem(pObj).ParticleCount;
      end;  
    end;

  str := Format('%.4d', [count]);
  atlas.setString(str);
end;

{ ReorderParticleSystems }

procedure ReorderParticleSystems.onEnter;
var
  i: Integer;
  psys: CCParticleSystemQuad;
  color: array [0..2] of Single;
  startcolor, startcolorvar: ccColor4F;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_pBatchNode := CCParticleBatchNode._create('Images/stars-grayscale.png', 3000);
  addChild(m_pBatchNode, 1, 2);
  for i := 0 to 2 do
  begin
    psys := CCParticleSystemQuad.Create;
    psys.initWithTotalParticles(200);
    psys.setTexture(m_pBatchNode.getTexture);
    psys.Duration := kCCParticleDurationInfinity;
    psys.EmitterMode := kCCParticleModeRadius;
    psys.setStartRadius(100);
    psys.setStartRadiusVar(0);
    psys.setEndRadius(kCCParticleStartRadiusEqualToEndRadius);
    psys.setEndRadiusVar(0);
    psys.setRotatePerSecond(45);
    psys.setRotatePerSecondVar(0);
    psys.Angle := 90;
    psys.AngleVar := 0;
    psys.PosVar := CCPointZero;
    psys.Life := 4;
    psys.LifeVar := 0;
    psys.StartSpin := 0;
    psys.StartSpinVar := 0;
    psys.EndSpin := 0;
    psys.EndSpinVar := 0;

    color[0] := 0; color[1] := 0; color[2] := 0;
    color[i] := 1;
    startcolor.r := color[0]; startcolor.g := color[1]; startcolor.b := color[2]; startcolor.a := 1;
    psys.StartColor := startcolor;

    startcolorvar.r := 0; startcolorvar.g := 0; startcolorvar.b := 0; startcolorvar.a := 0;
    psys.StartColorVar := startcolorvar;

    psys.EndColor := startcolor;
    psys.EndColorVar := startcolorvar;

    psys.StartSize := 32;
    psys.StartSizeVar := 0;
    psys.EndSize := kCCParticleStartSizeEqualToEndSize;

    psys.EmissionRate := psys.TotalParticles/psys.Life;
    psys.setPosition(i*10+120, 200);

    m_pBatchNode.addChild(psys);
    psys.PositionType := kCCPositionTypeFree;
    psys.release;
  end;

  schedule(reorderSystem, 2);
  m_emitter := nil;
end;

procedure ReorderParticleSystems.reorderSystem(dt: Single);
var
  psys: CCParticleSystem;
begin
  psys := CCParticleSystem(m_pBatchNode.Children.objectAtIndex(1));
  m_pBatchNode.reorderChild(psys, psys.ZOrder-1);
end;

function ReorderParticleSystems.subtitle: string;
begin
  Result := 'changes every 2 seconds';
end;

function ReorderParticleSystems.title: string;
begin
  Result := 'reorder systems';
end;

procedure ReorderParticleSystems.update(time: Single);
var
  atlas: CCLabelAtlas;
  batchNode: CCNode;
  pObj: CCObject;
  //item: CCParticleSystem;
  count, i: Cardinal;
  str: string;
  pAry: CCArray;
begin
  inherited;
  atlas := CCLabelAtlas(getChildByTag(kTagParticleCount));
  count := 0;
  batchNode := getChildByTag(2);
  pAry := batchNode.Children;
  if (pAry <> nil) and (pAry.count > 0) then
    for i := 0 to pAry.count-1 do
    begin
      pObj := pAry.objectAtIndex(i);
      if pObj is CCParticleSystem then
      begin
        count := count + CCParticleSystem(pObj).ParticleCount;
      end;  
    end;

  str := Format('%.4d', [count]);
  atlas.setString(str);
end;

{ PremultipliedAlphaTest }

procedure PremultipliedAlphaTest.onEnter;
var
  tBlendFunc: ccBlendFunc;
begin
  inherited;
  setColor(ccBLUE);
  removeChild(m_background, True);
  m_background := nil;

  m_emitter := CCParticleSystemQuad._create('Particles/BoilingFoam.plist');
  m_emitter.retain;

  tBlendFunc.src := GL_ONE; tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
  m_emitter.setBlendFunc(tBlendFunc);

  m_emitter.StartColor := ccc4F(1, 1, 1, 1);
  m_emitter.EndColor := ccc4F(1, 1, 1, 0);
  m_emitter.StartColorVar := ccc4F(0, 0, 0, 0);
  m_emitter.EndColorVar := ccc4F(0, 0, 0, 0);

  addChild(m_emitter, 10);
end;

function PremultipliedAlphaTest.subtitle: string;
begin
  Result := 'no black halo, particles should fade out';
end;

function PremultipliedAlphaTest.title: string;
begin
  Result := 'premultiplied alpha';
end;

{ PremultipliedAlphaTest2 }

procedure PremultipliedAlphaTest2.onEnter;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_emitter := CCParticleSystemQuad._create('Particles/TestPremultipliedAlpha.plist');
  m_emitter.retain;
  addChild(m_emitter, 10);
end;

function PremultipliedAlphaTest2.subtitle: string;
begin
  Result := 'Arrows should be faded';
end;

function PremultipliedAlphaTest2.title: string;
begin
  Result := 'premultiplied alpha 2';
end;

{ RadiusMode1 }

procedure RadiusMode1.onEnter;
var
  s: CCSize;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_emitter := CCParticleSystemQuad.Create;
  m_emitter.initWithTotalParticles(200);
  addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/stars-grayscale.png'));

  m_emitter.Duration := kCCParticleDurationInfinity;
  m_emitter.EmitterMode := kCCParticleModeRadius;
  m_emitter.setStartRadius(0);
  m_emitter.setStartRadiusVar(0);
  m_emitter.setEndRadius(160);
  m_emitter.setEndRadiusVar(0);
  m_emitter.setRotatePerSecond(180);
  m_emitter.setRotatePerSecondVar(0);

  m_emitter.Angle := 90;
  m_emitter.AngleVar := 0;

  s := CCDirector.sharedDirector.getWinSize;
  m_emitter.setPosition(s.width/2, s.height/2);
  m_emitter.PosVar := CCPointZero;

  m_emitter.Life := 5;
  m_emitter.LifeVar := 0;

  m_emitter.StartSpin := 0;
  m_emitter.StartSpinVar := 0;
  m_emitter.EndSpin := 0;
  m_emitter.EndSpinVar := 0;

  m_emitter.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  m_emitter.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  m_emitter.StartSize := 32;
  m_emitter.StartSizeVar := 0;
  m_emitter.EndSize := kCCParticleStartSizeEqualToEndSize;

  m_emitter.EmissionRate := m_emitter.TotalParticles/m_emitter.Life;
  m_emitter.setBlendAdditive(False);
end;

function RadiusMode1.title: string;
begin
  Result := 'Radius Mode: Spiral';
end;

{ RadiusMode2 }

procedure RadiusMode2.onEnter;
var
  s: CCSize;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_emitter := CCParticleSystemQuad.Create;
  m_emitter.initWithTotalParticles(200);
  addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/stars-grayscale.png'));

  m_emitter.Duration := kCCParticleDurationInfinity;
  m_emitter.EmitterMode := kCCParticleModeRadius;
  m_emitter.setStartRadius(100);
  m_emitter.setStartRadiusVar(0);
  m_emitter.setEndRadius(kCCParticleStartRadiusEqualToEndRadius);
  m_emitter.setEndRadiusVar(0);
  m_emitter.setRotatePerSecond(45);
  m_emitter.setRotatePerSecondVar(0);

  m_emitter.Angle := 90;
  m_emitter.AngleVar := 0;

  s := CCDirector.sharedDirector.getWinSize;
  m_emitter.setPosition(s.width/2, s.height/2);
  m_emitter.PosVar := CCPointZero;

  m_emitter.Life := 4;
  m_emitter.LifeVar := 0;

  m_emitter.StartSpin := 0;
  m_emitter.StartSpinVar := 0;
  m_emitter.EndSpin := 0;
  m_emitter.EndSpinVar := 0;

  m_emitter.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  m_emitter.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  m_emitter.StartSize := 32;
  m_emitter.StartSizeVar := 0;
  m_emitter.EndSize := kCCParticleStartSizeEqualToEndSize;

  m_emitter.EmissionRate := m_emitter.TotalParticles/m_emitter.Life;
  m_emitter.setBlendAdditive(False);
end;

function RadiusMode2.title: string;
begin
  Result := 'Radius Mode: Semi Circle';
end;

{ Issue1201 }

type
  RainbowEffect = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    procedure update(time: Single); override;
  end;

procedure Issue1201.onEnter;
var
  particle: RainbowEffect;
  s: CCSize;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  particle := RainbowEffect.Create;
  particle.initWithTotalParticles(50);
  addChild(particle);

  s := CCDirector.sharedDirector.getWinSize;
  particle.setPosition(s.width/2, s.height/2);
  m_emitter := particle;
end;

function Issue1201.subtitle: string;
begin
  Result := 'Unfinished test. Ignore it';
end;

function Issue1201.title: string;
begin
  Result := 'Issue 1201. Unfinished';
end;

{ Issue704 }

procedure Issue704.onEnter;
var
  s: CCSize;
  rot: CCRotateBy;
begin
  inherited;
  setColor(ccBLACK);
  removeChild(m_background, True);
  m_background := nil;

  m_emitter := CCParticleSystemQuad.Create;
  m_emitter.initWithTotalParticles(100);
  addChild(m_emitter, 10);
  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));

  m_emitter.Duration := kCCParticleDurationInfinity;
  m_emitter.EmitterMode := kCCParticleModeRadius;
  m_emitter.setStartRadius(50);
  m_emitter.setStartRadiusVar(0);
  m_emitter.setEndRadius(kCCParticleStartRadiusEqualToEndRadius);
  m_emitter.setEndRadiusVar(0);
  m_emitter.setRotatePerSecond(0);
  m_emitter.setRotatePerSecondVar(0);

  m_emitter.Angle := 90;
  m_emitter.AngleVar := 0;

  s := CCDirector.sharedDirector.getWinSize;
  m_emitter.setPosition(s.width/2, s.height/2);
  m_emitter.PosVar := CCPointZero;

  m_emitter.Life := 5;
  m_emitter.LifeVar := 0;

  m_emitter.StartSpin := 0;
  m_emitter.StartSpinVar := 0;
  m_emitter.EndSpin := 0;
  m_emitter.EndSpinVar := 0;

  m_emitter.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  m_emitter.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  m_emitter.StartSize := 16;
  m_emitter.StartSizeVar := 0;
  m_emitter.EndSize := kCCParticleStartSizeEqualToEndSize;

  m_emitter.EmissionRate := m_emitter.TotalParticles/m_emitter.Life;
  m_emitter.setBlendAdditive(False);

  rot := CCRotateBy._create(16, 360);
  m_emitter.runAction(CCRepeatForever._create(rot));
end;

function Issue704.subtitle: string;
begin
  Result := 'Emitted particles should not rotate';
end;

function Issue704.title: string;
begin
  Result := 'Issue 704. Free + Rot';
end;

{ RainbowEffect }

function RainbowEffect.init: Boolean;
begin
  Result := initWithTotalParticles(150);
end;

function RainbowEffect.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    m_fDuration := kCCParticleDurationInfinity;
    m_nEmitterMode := kCCParticleModeGravity;
    modeA.gravity := ccp(0, 0);
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 0;
    modeA.speed := 120;
    modeA.speedVar := 0;
    m_fAngle := 180;
    m_fAngleVar := 0;

    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, 60));
    m_tPosVar := ccp(40, 20);

    // life of particles
    m_fLife := 0.5;
    m_fLifeVar := 0;


    // size, in pixels
    m_fStartSize := 25.0;
    m_fStartSizeVar := 0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per frame
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.76;
    m_tStartColor.g := 0.25;
    m_tStartColor.b := 0.12;
    m_tStartColor.a := 0.0;
    m_tStartColorVar.r := 0.0;
    m_tStartColorVar.g := 0.0;
    m_tStartColorVar.b := 0.0;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.0;
    m_tEndColor.g := 0.0;
    m_tEndColor.b := 0.0;
    m_tEndColor.a := 0.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    setBlendAdditive(False);
    setTexture(CCTextureCache.sharedTextureCache.addImage('Images/particles.png')); 

    Result := True;
    Exit;
  end;
  
  Result := False;

end;

procedure RainbowEffect.update(time: Single);
begin
  m_fEmitCounter := 0;
  inherited update(time);
end;

{ DemoRing }

procedure DemoRing.onEnter;
begin
  inherited;
  m_emitter := CCParticleFlower._create;
  m_emitter.retain;
  m_background.addChild(m_emitter, 10);

  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_stars1));
  m_emitter.LifeVar := 0;
  m_emitter.Life := 10;
  m_emitter.setSpeed(100);
  m_emitter.setSpeedVar(0);
  m_emitter.EmissionRate := 10000;
  setEmitterPosition();  
end;

function DemoRing.title: string;
begin
  Result := 'Ring Demo';
end;

{ DemoModernArt }

procedure DemoModernArt.onEnter;
var
  s: CCSize;
begin
  inherited;


  m_emitter := CCParticleSystemQuad.Create;
  m_emitter.initWithTotalParticles(1000);
  m_background.addChild(m_emitter, 10);

  m_emitter.Duration := kCCParticleDurationInfinity;
  m_emitter.setGravity(CCPointZero);

  m_emitter.Angle := 0;
  m_emitter.AngleVar := 360;

  m_emitter.setRadialAccel(70);
  m_emitter.setRadialAccelVar(10);

  m_emitter.setTangentialAccel(80);
  m_emitter.setTangentialAccelVar(0);

  m_emitter.setSpeed(50);
  m_emitter.setSpeedVar(10);

  s := CCDirector.sharedDirector.getWinSize;
  m_emitter.setPosition(s.width/2, s.height/2);
  m_emitter.PosVar := CCPointZero;

  m_emitter.Life := 2;
  m_emitter.LifeVar := 0.3;

  m_emitter.EmissionRate := m_emitter.TotalParticles/m_emitter.Life;

  m_emitter.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  m_emitter.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  m_emitter.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  m_emitter.StartSize := 1;
  m_emitter.StartSizeVar := 1;
  m_emitter.EndSize := 32;
  m_emitter.EndSizeVar := 8;

  m_emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_fire));
end;

function DemoModernArt.title: string;
begin
  Result := 'Varying size';
end;

{ ParallaxParticle }

procedure ParallaxParticle.onEnter;
begin
  inherited;

end;

function ParallaxParticle.title: string;
begin
  Result := 'no implementation';
end;

end.
