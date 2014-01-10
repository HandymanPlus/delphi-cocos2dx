unit PerformanceParticleTest;

interface
uses
  Cocos2dx.CCLayer, Cocos2dx.CCNode, Cocos2dx.CCObject, PerformanceTest, Cocos2dx.CCScene;

type
  ParticleMenuLayer = class(PerformBasicLayer)
  public
    constructor Create(bControlMenuVisible: Boolean; nMaxCased: Integer = 0; nCurCase: Integer = 0);
    procedure showCurrentTest(); override;
  end;

  ParticleMainScene = class(CCScene)
  public
    function title(): string; dynamic;
    procedure initWithSubTest(nSubTest, nNodes: Integer);
    procedure step(dt: Single);
    procedure createParticleSystem();
    procedure testNCallback(pSender: CCObject);
    procedure onIncrease(pSender: CCObject);
    procedure onDecrease(pSender: CCObject);
    procedure updateQuantityLabel();
    function getSubTestNum(): Integer;
    function getParticlesNum(): Integer;
    procedure doTest(); dynamic; abstract;
  protected
    lastRenderedCount: Integer;
    quantituParticles: Integer;
    subtestNumber: Integer;
  end;

  ParticlePerformTest1 = class(ParticleMainScene)
  public
    procedure doTest(); override;
    function title(): string; override;
  end;

  ParticlePerformTest2 = class(ParticleMainScene)
  public
    procedure doTest(); override;
    function title(): string; override;
  end;

  ParticlePerformTest3 = class(ParticleMainScene)
  public
    procedure doTest(); override;
    function title(): string; override;
  end;

  ParticlePerformTest4 = class(ParticleMainScene)
  public
    procedure doTest(); override;
    function title(): string; override;
  end;

procedure runParticleTest();

implementation
uses
  SysUtils, Cocos2dx.CCMenu, Cocos2dx.CCMenuItem, Cocos2dx.CCLabelTTF,
  Cocos2dx.CCDirector, Cocos2dx.CCTextureCache, Cocos2dx.CCTexture2D,
  Cocos2dx.CCGeometry, Cocos2dx.CCTypes,
  Cocos2dx.CCLabelAtlas, Cocos2dx.CCParticleSystem, Cocos2dx.CCParticleSystemQuad,
  Cocos2dx.CCPointExtension;

const    kTagInfoLayer = 1;
const    kTagMainLayer = 2;
const    kTagParticleSystem = 3;
const    kTagLabelAtlas = 4;
const    kTagMenuLayer = 1000;
const    TEST_COUNT = 4;

const    kMaxParticles = 14000;
const    kNodesIncrease = 500;

var s_nParCurIdx: Integer;


procedure runParticleTest();
var
  pScene: ParticleMainScene;
begin
  pScene := ParticlePerformTest1.Create;
  pScene.initWithSubTest(1, kNodesIncrease);
  CCDirector.sharedDirector.replaceScene(pScene);
  pScene.release;
end;  

{ ParticleMenuLayer }

constructor ParticleMenuLayer.Create(bControlMenuVisible: Boolean;
  nMaxCased, nCurCase: Integer);
begin
  inherited Create(bControlMenuVisible, nMaxCased, nCurCase);
end;

procedure ParticleMenuLayer.showCurrentTest;
var
  pScene, pNewScene: ParticleMainScene;
  subTest, parNum: Integer;
begin
  pScene := ParticleMainScene(getParent);
  subTest := pScene.getSubTestNum;
  parNum := pScene.getParticlesNum;

  pNewScene := nil;
  case m_nCurCase of
    0: pNewScene := ParticlePerformTest1.Create;
    1: pNewScene := ParticlePerformTest2.Create;
    2: pNewScene := ParticlePerformTest3.Create;
    3: pNewScene := ParticlePerformTest4.Create;
  end;

  s_nParCurIdx := m_nCurCase;
  if pNewScene <> nil then
  begin
    pNewScene.initWithSubTest(subTest, parNum);
    CCDirector.sharedDirector.replaceScene(pNewScene);
    pNewScene.release;
  end;  
end;

{ ParticleMainScene }

procedure ParticleMainScene.createParticleSystem;
var
  particleSystem: CCParticleSystem;
  texture: CCTexture2D;
begin
  removeChildByTag(kTagParticleSystem, True);
  texture := CCTextureCache.sharedTextureCache().addImage('Images/fire.png');
  CCTextureCache.sharedTextureCache.removeTexture(texture);
  particleSystem := CCParticleSystemQuad.Create;

  case subtestNumber of
    1:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
        particleSystem.initWithTotalParticles(quantituParticles);
        particleSystem.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
      end;
    2:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
        particleSystem.initWithTotalParticles(quantituParticles);
        particleSystem.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
      end;
    3:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_A8);
        particleSystem.initWithTotalParticles(quantituParticles);
        particleSystem.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
      end;
    4:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
        particleSystem.initWithTotalParticles(quantituParticles);
        particleSystem.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
      end;
    5:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
        particleSystem.initWithTotalParticles(quantituParticles);
        particleSystem.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
      end;
    6:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_A8);
        particleSystem.initWithTotalParticles(quantituParticles);
        particleSystem.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
      end;
  end;
  addChild(particleSystem, 0, kTagParticleSystem);
  particleSystem.release;
  doTest();

  CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
end;

function ParticleMainScene.getParticlesNum: Integer;
begin
  Result := quantituParticles;
end;

function ParticleMainScene.getSubTestNum: Integer;
begin
  Result := subtestNumber;
end;

procedure ParticleMainScene.initWithSubTest(nSubTest, nNodes: Integer);
var
  s: CCSize;
  decrease, increase, itemFont: CCMenuItemFont;
  menu, pSubMenu: CCMenu;
  infoLabel: CCLabelTTF;
  labelAtlas: CCLabelAtlas;
  pMenu: ParticleMenuLayer;
  i: Integer;
  plabel: CCLabelTTF;
begin
  subtestNumber := nSubTest;
  s := CCDirector.sharedDirector.getWinSize;
  lastRenderedCount := 0;
  quantituParticles := nNodes;

  CCMenuItemFont.setFontSize(65);
  decrease := CCMenuItemFont._create('-', Self, onDecrease);
  decrease.setColor(ccc3(0, 200, 20));
  increase := CCMenuItemFont._create('+', Self, onIncrease);
  increase.setColor(ccc3(0, 200, 20));

  menu := CCMenu._create([decrease, increase]);
  menu.alignItemsHorizontally;
  menu.setPosition(s.width/2, s.height/2+15);
  addChild(menu, 1);

  infoLabel := CCLabelTTF._create('0 nodes', 'Marker Felt', 30);
  infoLabel.setColor(ccc3(0, 200, 20));
  infoLabel.setPosition(s.width/2, s.height - 90);
  addChild(infoLabel, 1, kTagInfoLayer);

  labelAtlas := CCLabelAtlas._create('0000', 'fps_images.png', 12, 32, Ord('.'));
  addChild(labelAtlas, 0, kTagLabelAtlas);
  labelAtlas.setPosition(s.width-66, 50);

  pMenu := ParticleMenuLayer.Create(True, TEST_COUNT, s_nParCurIdx);
  addChild(pMenu, 1, kTagMenuLayer);
  pMenu.release;

  CCMenuItemFont.setFontSize(40);
  pSubMenu := CCMenu._create;
  for i := 1 to 6 do
  begin
    itemFont := CCMenuItemFont._create(IntToStr(i), Self, testNCallback);
    itemFont.Tag := i;
    pSubMenu.addChild(itemFont, 10);

    if i <= 3 then
      itemFont.setColor(ccc3(200, 20, 20))
    else
      itemFont.setColor(ccc3(0, 200, 20));
  end;
  pSubMenu.alignItemsHorizontally;
  pSubMenu.setPosition(s.width/2, 80);
  addChild(pSubMenu, 2);

  plabel := CCLabelTTF._create(title, 'Arial', 40);
  addChild(plabel, 1);
  plabel.setPosition(s.width/2, s.height-32);
  plabel.setColor(ccc3(255, 255, 40));
  updateQuantityLabel;
  createParticleSystem;
  schedule(step);
end;

procedure ParticleMainScene.onDecrease(pSender: CCObject);
begin
  quantituParticles := quantituParticles - kNodesIncrease;
  if quantituParticles < 0 then
    quantituParticles := 0;
  updateQuantityLabel;
  createParticleSystem;
end;

procedure ParticleMainScene.onIncrease(pSender: CCObject);
begin
  quantituParticles := quantituParticles + kNodesIncrease;
  if quantituParticles > kMaxParticles then
    quantituParticles := kMaxParticles;
  updateQuantityLabel;
  createParticleSystem;
end;

procedure ParticleMainScene.step(dt: Single);
var
  atlas: CCLabelAtlas;
  emitter: CCParticleSystem;
  str: string;
begin
  atlas := CCLabelAtlas(getChildByTag(kTagLabelAtlas));
  emitter := CCParticleSystem(getChildByTag(kTagParticleSystem));
  str := Format('%.4d', [emitter.ParticleCount]);
  atlas.setString(str);
end;

procedure ParticleMainScene.testNCallback(pSender: CCObject);
var
  pMenu: ParticleMenuLayer;
begin
  subtestNumber := CCNode(pSender).getTag;
  pMenu := ParticleMenuLayer(getChildByTag(kTagMenuLayer));
  pMenu.restartCallback(pSender);
end;

function ParticleMainScene.title: string;
begin
  Result := 'no title';
end;

procedure ParticleMainScene.updateQuantityLabel;
var
  infoLabel: CCLabelTTF;
begin
  if quantituParticles <> lastRenderedCount then
  begin
    infoLabel := CCLabelTTF(getChildByTag(kTagInfoLayer));
    infoLabel.setString(Format('%d particles', [quantituParticles]));
    lastRenderedCount := quantituParticles;
  end;
end;

{ ParticlePerformTest1 }

procedure ParticlePerformTest1.doTest;
var
  s: CCSize;
  particleSystem: CCParticleSystem;
begin
  s := CCDirector.sharedDirector.getWinSize;
  particleSystem := CCParticleSystem(getChildByTag(kTagParticleSystem));

  particleSystem.Duration := -1;
  particleSystem.setGravity(ccp(0, -90));
  particleSystem.Angle := 90;
  particleSystem.AngleVar := 0;

  particleSystem.setRadialAccel( 0);
  particleSystem.setRadialAccelVar(0);

  particleSystem.setSpeed(180);
  particleSystem.setSpeedVar(50);

  particleSystem.setPosition(s.width/2, 100);
  particleSystem.PosVar := ccp(s.width/2, 0);
  particleSystem.Life := 2;
  particleSystem.LifeVar := 1;

  particleSystem.EmissionRate := particleSystem.TotalParticles/particleSystem.Life;

  particleSystem.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  particleSystem.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  particleSystem.EndSize := 4;
  particleSystem.StartSize := 4;
  particleSystem.EndSizeVar := 0;
  particleSystem.StartSizeVar := 0;

  particleSystem.setBlendAdditive(False);
end;

function ParticlePerformTest1.title: string;
begin
  Result := Format('A (%d) size=4', [subtestNumber])
end;

{ ParticlePerformTest2 }

procedure ParticlePerformTest2.doTest;
var
  s: CCSize;
  particleSystem: CCParticleSystem;
begin
  s := CCDirector.sharedDirector.getWinSize;
  particleSystem := CCParticleSystem(getChildByTag(kTagParticleSystem));

  particleSystem.Duration := -1;
  particleSystem.setGravity(ccp(0, -90));
  particleSystem.Angle := 90;
  particleSystem.AngleVar := 0;

  particleSystem.setRadialAccel( 0);
  particleSystem.setRadialAccelVar(0);

  particleSystem.setSpeed(180);
  particleSystem.setSpeedVar(50);

  particleSystem.setPosition(s.width/2, 100);
  particleSystem.PosVar := ccp(s.width/2, 0);
  particleSystem.Life := 2;
  particleSystem.LifeVar := 1;

  particleSystem.EmissionRate := particleSystem.TotalParticles/particleSystem.Life;

  particleSystem.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  particleSystem.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  particleSystem.EndSize := 8;
  particleSystem.StartSize := 8;
  particleSystem.EndSizeVar := 0;
  particleSystem.StartSizeVar := 0;

  particleSystem.setBlendAdditive(False);
end;

function ParticlePerformTest2.title: string;
begin
  Result := Format('B (%d) size=8', [subtestNumber])
end;

{ ParticlePerformTest3 }

procedure ParticlePerformTest3.doTest;
var
  s: CCSize;
  particleSystem: CCParticleSystem;
begin
  s := CCDirector.sharedDirector.getWinSize;
  particleSystem := CCParticleSystem(getChildByTag(kTagParticleSystem));

  particleSystem.Duration := -1;
  particleSystem.setGravity(ccp(0, -90));
  particleSystem.Angle := 90;
  particleSystem.AngleVar := 0;

  particleSystem.setRadialAccel( 0);
  particleSystem.setRadialAccelVar(0);

  particleSystem.setSpeed(180);
  particleSystem.setSpeedVar(50);

  particleSystem.setPosition(s.width/2, 100);
  particleSystem.PosVar := ccp(s.width/2, 0);
  particleSystem.Life := 2;
  particleSystem.LifeVar := 1;

  particleSystem.EmissionRate := particleSystem.TotalParticles/particleSystem.Life;

  particleSystem.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  particleSystem.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  particleSystem.EndSize := 32;
  particleSystem.StartSize := 32;
  particleSystem.EndSizeVar := 0;
  particleSystem.StartSizeVar := 0;

  particleSystem.setBlendAdditive(False);
end;

function ParticlePerformTest3.title: string;
begin
  Result := Format('C (%d) size=32', [subtestNumber])
end;

{ ParticlePerformTest4 }

procedure ParticlePerformTest4.doTest;
var
  s: CCSize;
  particleSystem: CCParticleSystem;
begin
  s := CCDirector.sharedDirector.getWinSize;
  particleSystem := CCParticleSystem(getChildByTag(kTagParticleSystem));

  particleSystem.Duration := -1;
  particleSystem.setGravity(ccp(0, -90));
  particleSystem.Angle := 90;
  particleSystem.AngleVar := 0;

  particleSystem.setRadialAccel( 0);
  particleSystem.setRadialAccelVar(0);

  particleSystem.setSpeed(180);
  particleSystem.setSpeedVar(50);

  particleSystem.setPosition(s.width/2, 100);
  particleSystem.PosVar := ccp(s.width/2, 0);
  particleSystem.Life := 2;
  particleSystem.LifeVar := 1;

  particleSystem.EmissionRate := particleSystem.TotalParticles/particleSystem.Life;

  particleSystem.StartColor := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.StartColorVar := ccc4F(0.5, 0.5, 0.5, 1);
  particleSystem.EndColor := ccc4F(0.1, 0.1, 0.1, 0.2);
  particleSystem.EndColorVar := ccc4F(0.1, 0.1, 0.1, 0.2);

  particleSystem.EndSize := 64;
  particleSystem.StartSize := 64;
  particleSystem.EndSizeVar := 0;
  particleSystem.StartSizeVar := 0;

  particleSystem.setBlendAdditive(False);

end;

function ParticlePerformTest4.title: string;
begin
  Result := Format('D (%d) size=64', [subtestNumber])
end;

end.
