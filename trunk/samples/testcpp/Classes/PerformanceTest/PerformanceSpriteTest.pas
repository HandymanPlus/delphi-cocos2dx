unit PerformanceSpriteTest;

interface
uses
  Cocos2dx.CCLayer, Cocos2dx.CCSprite, Cocos2dx.CCSpriteBatchNode, Cocos2dx.CCNode,
  Cocos2dx.CCObject, PerformanceTest, Cocos2dx.CCScene;

type
  SubTest = class
  public
    destructor Destroy(); override;
    procedure removeByTag(tag: Integer);
    function createSpriteWithTag(tag: Integer): CCSprite;
    procedure initWithSubTest(nSubTest: Integer; p: CCNode);
  protected
    subtestNumber: Integer;
    batchNode: CCSpriteBatchNode;
    parent: CCNode;
  end;

  SpriteMenuLayer = class(PerformBasicLayer)
  public
    constructor Create(bControlMenuVisible: Boolean; nMaxCased: Integer = 0; nCurCase: Integer = 0);
    procedure showCurrentTest(); override;
  end;

  SpriteMainScene = class(CCScene)
  public
    destructor Destroy(); override;
    function title(): string; dynamic;
    procedure initWithSubTest(nSubTest, nNodes: Integer);
    procedure updateNodes();

    procedure testNCallback(pSender: CCObject);
    procedure onIncrease(pSender: CCObject);
    procedure onDecrease(pSender: CCObject);
    procedure doTest(sprite: CCSprite); dynamic; abstract;

    function getSubTestNum(): Integer;
    function getNodesNum(): Integer;
  protected
    lastRenderedCount: Integer;
    quantituNodes: Integer;
    m_pSubTest: SubTest;
    subtestNumber: Integer;
  end;

  SpritePerformTest1 = class(SpriteMainScene)
  public
    procedure doTest(sprite: CCSprite); override;
    function title(): string; override;
  end;

  SpritePerformTest2 = class(SpriteMainScene)
  public
    procedure doTest(sprite: CCSprite); override;
    function title(): string; override;
  end;

  SpritePerformTest3 = class(SpriteMainScene)
  public
    procedure doTest(sprite: CCSprite); override;
    function title(): string; override;
  end;

  SpritePerformTest4 = class(SpriteMainScene)
  public
    procedure doTest(sprite: CCSprite); override;
    function title(): string; override;
  end;

  SpritePerformTest5 = class(SpriteMainScene)
  public
    procedure doTest(sprite: CCSprite); override;
    function title(): string; override;
  end;

  SpritePerformTest6 = class(SpriteMainScene)
  public
    procedure doTest(sprite: CCSprite); override;
    function title(): string; override;
  end;

  SpritePerformTest7 = class(SpriteMainScene)
  public
    procedure doTest(sprite: CCSprite); override;
    function title(): string; override;
  end;

procedure runSpriteTest();

implementation
uses
  SysUtils, Cocos2dx.CCMenu, Cocos2dx.CCMenuItem, Cocos2dx.CCLabelTTF, Cocos2dx.CCActionInterval,
  Cocos2dx.CCAction, Math,
  Cocos2dx.CCDirector, Cocos2dx.CCTextureCache, Cocos2dx.CCTexture2D,
  Cocos2dx.CCGeometry, Cocos2dx.CCTypes, Cocos2dx.CCMacros;

const    kMaxNodes = 50000;
const    kNodesIncrease = 250;
const    TEST_COUNT = 7;

const    kTagInfoLayer = 1;
const    kTagMainLayer = 2;
const    kTagMenuLayer = (kMaxNodes + 1000);

var s_nSpriteCurCase: Integer;


procedure runSpriteTest();
var
  pScene: SpriteMainScene;
begin
  pScene := SpritePerformTest1.Create;
  pScene.initWithSubTest(1, 50);
  CCDirector.sharedDirector.replaceScene(pScene);
  pScene.release;
end;

procedure performanceActions(pSprite: CCSprite);
var
  size: CCSize;
  period: Single;
  growDuration: Single;
  grow: CCFiniteTimeAction;
  rot, rot_back, permanentRotation, permanentScaleLoop: CCFiniteTimeAction;
begin
  size := CCDirector.sharedDirector.getWinSize;
  pSprite.setPosition( RandomRange(0, Round(size.width)), RandomRange(0, Round(size.height)) );

  period := 0.5 + Random * 2;
  rot := CCRotateBy._create(period, 360 * CCRANDOM_MINUS1_1());
  rot_back := rot.reverse;
  permanentRotation := CCRepeatForever._create(CCActionInterval(CCSequence._create([rot, rot_back])));
  pSprite.runAction(permanentRotation);

  growDuration := 0.5 + Random * 2;
  grow := CCScaleBy._create(growDuration, 0.5, 0.5);
  permanentScaleLoop := CCRepeatForever._create(CCActionInterval(CCSequence._create([grow, grow.reverse])));
  pSprite.runAction(permanentScaleLoop);
end;

procedure performanceActions20(pSprite: CCSprite);
var
  size: CCSize;
  period, growDuration: Single;
  rot, rot_back, permanenRotateion, grow, permanentScaleLoop: CCFiniteTimeAction;
begin
  size := CCDirector.sharedDirector.getWinSize;
  if CCRANDOM_MINUS1_1 < 0.2 then
    pSprite.setPosition( RandomRange(0, Round(size.width)), RandomRange(0, Round(size.height)) )
  else
    pSprite.setPosition(-1000, -1000);

  period := 0.5 + Random * 2;
  rot := CCRotateBy._create(period, 360 * Random);
  rot_back := rot.reverse;
  permanenRotateion := CCRepeatForever._create(CCActionInterval(CCSequence._create([rot, rot_back])));
  pSprite.runAction(permanenRotateion);

  growDuration := 0.5 + Random * 2;
  grow := CCScaleBy._create(growDuration, 0.5, 0.5);
  permanentScaleLoop := CCRepeatForever._create(CCActionInterval(CCSequence._create([grow, grow.reverse])));
  pSprite.runAction(permanentScaleLoop);
end;

procedure performanceRotationScale(pSprite: CCSprite);
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector.getWinSize;
  pSprite.setPosition(RandomRange(0, Round(size.width)), RandomRange(0, Round(size.height)) );
  pSprite.setRotation(Random * 360);
  pSprite.setScale(Random * 2);
end;

procedure performancePosition(pSprite: CCSprite);
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector.getWinSize;
  pSprite.setPosition(RandomRange(0, Round(size.width)), RandomRange(0, Round(size.height)));
end;

procedure performanceout20(pSprite: CCSprite);
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector.getWinSize;
  if Random < 0.2 then
    pSprite.setPosition(RandomRange(0, Round(size.width)), RandomRange(0, Round(size.height)))
  else
    pSprite.setPosition(-1000, -1000);
end;

procedure performanceOut100(pSprite: CCSprite);
begin
  pSprite.setPosition(-1000, -1000);
end;

procedure performanceScale(pSprite: CCSprite);
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector.getWinSize;
  pSprite.setPosition(RandomRange(0, Round(size.width)), RandomRange(0, Round(size.height)));
  pSprite.setScale(Random * 2);
end;
  
{ SubTest }

function SubTest.createSpriteWithTag(tag: Integer): CCSprite;
var
  sprite: CCSprite;
  idx: Integer;
  str: string;
  x, y, r: Integer;
begin
  CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
  sprite := nil;

  case subtestNumber of
    1:
      begin
        sprite := CCSprite._create('Images/grossinis_sister1.png');
        parent.addChild(sprite, 0, tag + 100);
      end;
    2, 3:
      begin
        sprite := CCSprite.createWithTexture(batchNode.getTexture, CCRectMake(0, 0, 52, 139));
        batchNode.addChild(sprite, 0, tag + 100);
      end;
    4:
      begin
        idx := Round(CCRANDOM_MINUS1_1() * 1400 / 100) + 1;
        str := Format('Images/grossini_dance_%.2d.png', [idx]);
        sprite := CCSprite._create(str);
        parent.addChild(sprite, 0, tag+100);
      end;
    5, 6:
      begin
        r := Round(CCRANDOM_MINUS1_1() * 1400 / 100);

        y := r div 5;
        x := r mod 5;

        x := x * 85;
        y := y * 121;

        sprite := CCSprite.createWithTexture(batchNode.getTexture, CCRectMake(x, y, 85, 121));
        batchNode.addChild(sprite, 0, tag+100);
      end;
    7:
      begin
        r := Round(CCRANDOM_MINUS1_1() * 6400 / 100);

        y := r div 8;
        x := r mod 8;

        str := Format('Images/sprites_test/sprite-%d-%d.png', [x, y]);
        sprite := CCSprite._create(str);
        parent.addChild(sprite, 0, tag+100);
      end;
    8, 9:
      begin
        r := Round(CCRANDOM_MINUS1_1() * 6400 / 100);

        y := r div 8;
        x := r mod 8;

        x := x * 32;
        y := y * 32;

        sprite := CCSprite.createWithTexture(batchNode.getTexture, CCRectMake(x, y, 32, 32));
        batchNode.addChild(sprite, 0, tag+100);
      end;  
  end;

  CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_Default);
  Result := sprite;
end;

destructor SubTest.Destroy;
begin
  if batchNode <> nil then
  begin
    batchNode.release;
    batchNode := nil;
  end;  
  inherited;
end;

procedure SubTest.initWithSubTest(nSubTest: Integer; p: CCNode);
var
  mgr: CCTextureCache;
begin
  subtestNumber := nSubTest;
  self.parent := p;
  batchNode := nil;

  mgr := CCTextureCache.sharedTextureCache;
  mgr.removeTexture(mgr.addImage('Images/grossinis_sister1.png'));
  mgr.removeTexture(mgr.addImage('Images/grossini_dance_atlas.png'));
  mgr.removeTexture(mgr.addImage('Images/spritesheet1.png'));

  case subtestNumber of
    1, 4, 7: ;
    2:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
        batchNode := CCSpriteBatchNode._create('Images/grossinis_sister1.png', 100);
        p.addChild(batchNode, 0);
      end;
    3:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
        batchNode := CCSpriteBatchNode._create('Images/grossinis_sister1.png', 100);
        p.addChild(batchNode, 0);
      end;
    5:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
        batchNode := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 100);
        p.addChild(batchNode, 0);
      end;
    6:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
        batchNode := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 100);
        p.addChild(batchNode, 0);
      end;
    8:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
        batchNode := CCSpriteBatchNode._create('Images/spritesheet1.png', 100);
        p.addChild(batchNode, 0);
      end;
    9:
      begin
        CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
        batchNode := CCSpriteBatchNode._create('Images/spritesheet1.png', 100);
        p.addChild(batchNode, 0);
      end;  
  end;

  if batchNode <> nil then
    batchNode.retain;

  CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_Default);
end;

procedure SubTest.removeByTag(tag: Integer);
begin
  case subtestNumber of
    1, 4, 7:
      begin
        parent.removeChildByTag(tag+100, True);
      end;
    2, 3, 5, 6, 8, 9:
      begin
        batchNode.removeChildAtIndex(tag, True);
      end;  
  end;
end;

{ SpriteMenuLayer }

constructor SpriteMenuLayer.Create(bControlMenuVisible: Boolean; nMaxCased,
  nCurCase: Integer);
begin
  inherited Create(bControlMenuVisible, nMaxCased, nCurCase);
end;

procedure SpriteMenuLayer.showCurrentTest;
var
  pScene, pPreScene: SpriteMainScene;
  nSubTest, nNodes: Integer;
begin
  pPreScene := SpriteMainScene(getParent);
  nSubTest := pPreScene.getSubTestNum;
  nNodes := pPreScene.getNodesNum;

  pScene := nil;
  case m_nCurCase of
    0: pScene := SpritePerformTest1.Create;
    1: pScene := SpritePerformTest2.Create;
    2: pScene := SpritePerformTest3.Create;
    3: pScene := SpritePerformTest4.Create;
    4: pScene := SpritePerformTest5.Create;
    5: pScene := SpritePerformTest6.Create;
    6: pScene := SpritePerformTest7.Create;
  end;

  s_nSpriteCurCase := m_nCurCase;
  if pScene <> nil then
  begin
    pScene.initWithSubTest(nSubTest, nNodes);
    CCDirector.sharedDirector.replaceScene(pScene);
    pScene.release;
  end;  
end;

{ SpriteMainScene }

destructor SpriteMainScene.Destroy;
begin
  m_pSubTest.Free;
  m_pSubTest := nil;
  inherited;
end;

function SpriteMainScene.getNodesNum: Integer;
begin
  Result := quantituNodes;
end;

function SpriteMainScene.getSubTestNum: Integer;
begin
  Result := subtestNumber;
end;

procedure SpriteMainScene.initWithSubTest(nSubTest, nNodes: Integer);
var
  s: CCSize;
  decrease, increase: CCMenuItemFont;
  menu, pSubMenu: CCMenu;
  infoLabel, pLabel: CCLabelTTF;
  pMenu: SpriteMenuLayer;
  i: Integer;
  str: string;
  itemFont: CCMenuItemFont;
begin
  subtestNumber := nSubTest;
  m_pSubTest := SubTest.Create;
  m_pSubTest.initWithSubTest(nSubTest, Self);

  s := CCDirector.sharedDirector.getWinSize;

  lastRenderedCount := 0;
  quantituNodes := 0;

  CCMenuItemFont.setFontSize(65);
  decrease := CCMenuItemFont._create('-', Self, onDecrease);
  decrease.setColor(ccc3(0, 200, 20));
  increase := CCMenuItemFont._create('+', Self, onIncrease);
  increase.setColor(ccc3(0, 200, 20));

  menu := CCMenu._create([decrease, increase]);
  menu.alignItemsHorizontally;
  menu.setPosition(s.width/2, s.height - 65);
  addChild(menu, 1);

  infoLabel := CCLabelTTF._create('0 nodes', 'Marker Felt', 30);
  infoLabel.setColor(ccc3(0, 200, 20));
  infoLabel.setPosition(s.width/2, s.height-90);
  addChild(infoLabel, 1, kTagInfoLayer);

  pMenu := SpriteMenuLayer.Create(True, TEST_COUNT, s_nSpriteCurCase);
  addChild(pMenu, 1, kTagMenuLayer);
  pMenu.release;

  CCMenuItemFont.setFontSize(32);
  pSubMenu := CCMenu._create;
  for i := 1 to 9 do
  begin
    str := IntToStr(i);
    itemFont := CCMenuItemFont._create(str, Self, testNCallback);
    itemFont.Tag := i;
    pSubMenu.addChild(itemFont, 10);

    if i <= 3 then
      itemFont.setColor(ccc3(200, 20, 20))
    else if i <= 6 then
      itemFont.setColor(ccc3(0, 200, 20))
    else
      itemFont.setColor(ccc3(0, 20, 200));
  end;

  pSubMenu.alignItemsHorizontally;
  pSubMenu.setPosition(s.width/2, 80);
  addChild(pSubMenu, 2);

  pLabel := CCLabelTTF._create(title, 'Arial', 40);
  addChild(pLabel, 1);
  pLabel.setPosition(s.width/2, s.height - 32);
  pLabel.setColor(ccc3(255, 255, 40));

  while quantituNodes < nNodes do
    onIncrease(Self);
end;

procedure SpriteMainScene.onDecrease(pSender: CCObject);
var
  i: Integer;
begin
  if quantituNodes <= 0 then
    Exit;

  for i := 0 to kNodesIncrease-1 do
  begin
    Dec(quantituNodes);
    m_pSubTest.removeByTag(quantituNodes);
  end;
  updateNodes();
end;

procedure SpriteMainScene.onIncrease(pSender: CCObject);
var
  i: Integer;
  sprite: CCSprite;
begin
  if quantituNodes >= kMaxNodes then
    Exit;

  for i := 0 to kNodesIncrease-1 do
  begin
    sprite := m_pSubTest.createSpriteWithTag(quantituNodes);
    doTest(sprite);
    Inc(quantituNodes);
  end;
  updateNodes();
end;

procedure SpriteMainScene.testNCallback(pSender: CCObject);
var
  pMenu: SpriteMenuLayer;
begin
  subtestNumber := CCMenuItemFont(pSender).getTag;
  pMenu := SpriteMenuLayer(getChildByTag(kTagMenuLayer));
  pMenu.restartCallback(pSender);
end;

function SpriteMainScene.title: string;
begin
  Result := 'no title';
end;

procedure SpriteMainScene.updateNodes;
var
  str: string;
  infoLabel: CCLabelTTF;
begin
  if quantituNodes <> lastRenderedCount then
  begin
    infoLabel := CCLabelTTF(getChildByTag(kTagInfoLayer));
    str := Format('%d nodes', [quantituNodes]);
    infoLabel.setString(str);
    lastRenderedCount := quantituNodes;
  end;
end;

{ SpritePerformTest1 }

procedure SpritePerformTest1.doTest(sprite: CCSprite);
begin
  performancePosition(sprite);
end;

function SpritePerformTest1.title: string;
var
  str: string;
begin
  str := Format('A (%d) position', [subtestNumber]);
  Result := str;
end;

{ SpritePerformTest2 }

procedure SpritePerformTest2.doTest(sprite: CCSprite);
begin
  performanceScale(sprite);
end;

function SpritePerformTest2.title: string;
var
  str: string;
begin
  str := Format('B (%d) scale', [subtestNumber]);
  Result := str;
end;

{ SpritePerformTest3 }

procedure SpritePerformTest3.doTest(sprite: CCSprite);
begin
  performanceRotationScale(sprite);
end;

function SpritePerformTest3.title: string;
var
  str: string;
begin
  str := Format('C (%d) scale + rot', [subtestNumber]);
  Result := str;
end;

{ SpritePerformTest4 }

procedure SpritePerformTest4.doTest(sprite: CCSprite);
begin
  performanceOut100(sprite);
end;

function SpritePerformTest4.title: string;
var
  str: string;
begin
  str := Format('D (%d) out', [subtestNumber]);
  Result := str;
end;

{ SpritePerformTest5 }

procedure SpritePerformTest5.doTest(sprite: CCSprite);
begin
  performanceout20(sprite);
end;

function SpritePerformTest5.title: string;
var
  str: string;
begin
  str := Format('E (%d) 80%% out', [subtestNumber]);
  Result := str;
end;

{ SpritePerformTest6 }

procedure SpritePerformTest6.doTest(sprite: CCSprite);
begin
  performanceActions(sprite);
end;

function SpritePerformTest6.title: string;
var
  str: string;
begin
  str := Format('F (%d) actions', [subtestNumber]);
  Result := str;
end;

{ SpritePerformTest7 }

procedure SpritePerformTest7.doTest(sprite: CCSprite);
begin
  performanceActions20(sprite);
end;

function SpritePerformTest7.title: string;
var
  str: string;
begin
  str := Format('G (%d) actions 80%% out', [subtestNumber]);
  Result := str;
end;

end.
