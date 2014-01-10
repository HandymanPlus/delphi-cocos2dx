unit spritetest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic,
  Cocos2dx.CCGeometry, Cocos2dx.CCTouch, Cocos2dx.CCSet, Cocos2dx.CCTexture2D,
  Cocos2dx.CCSprite, Cocos2dx.CCSpriteBatchNode, Cocos2dx.CCNode;

type
  SpriteTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  SpriteTestDemo = class(CCLayer)
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

  Sprite1 = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure addNewSpriteWithCoords(p: CCPoint);
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
  end;

  SpriteAnchorPoint = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
  end;

  SpriteBatchNode1 = class(SpriteTestDemo)
  public
    constructor Create();
    procedure addNewSpriteWithCoords(p: CCPoint);
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
    function title(): string; override;
  end;

  SpriteFlip = class(SpriteTestDemo)
  public
    constructor Create();
    procedure flipSprites(dt: Single);
    function title(): string; override;
  end;

  SpriteBatchNodeFlip = class(SpriteTestDemo)
  public
    constructor Create();
    procedure flipSprites(dt: Single);
    function title(): string; override;
  end;

  SpriteBatchNodeReorder = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteBatchNodeReorderIssue744 = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteZVertex = class(SpriteTestDemo)
  public
    m_dir: Integer;
    m_time: Single;
    procedure onEnter(); override;
    procedure onExit(); override;
    constructor Create();
    function title(): string; override;
  end;

  SpriteBatchNodeZVertex = class(SpriteTestDemo)
  public
    m_dir: Integer;
    m_time: Single;
    procedure onEnter(); override;
    procedure onExit(); override;
    constructor Create();
    function title(): string; override;
  end;

  SpriteBatchNodeAnchorPoint = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
  end;

  SpriteAliased = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;
  end;

  SpriteBatchNodeAliased = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;
  end;

  SpriteNewTexture = class(SpriteTestDemo)
  public
    m_usingTexture1: Boolean;
    m_texture1, m_texture2: CCTexture2D;
    constructor Create();
    destructor Destroy(); override;
    procedure addNewSprite();
    function title(): string; override;
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
  end;

  SpriteBatchNodeNewTexture = class(SpriteTestDemo)
  public
    m_usingTexture1: Boolean;
    m_texture1, m_texture2: CCTexture2D;
    constructor Create();
    destructor Destroy(); override;
    procedure addNewSprite();
    function title(): string; override;
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
  end;
  
  SpriteFrameTest = class(SpriteTestDemo)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;
    procedure startIn05Secs(dt: Single);
    procedure flipSprites(dt: Single);
  private
    m_pSprite1, m_pSprite2: CCSprite;
    m_nCounter: Integer;
  end;

  SpriteZOrder = class(SpriteTestDemo)
  public
    m_dir: Integer;
    constructor Create();
    procedure reorderSprite(dt: Single);
    function title(): string; override;
  end;

  SpriteBatchNodeZOrder = class(SpriteTestDemo)
  public
    m_dir: Integer;
    constructor Create();
    procedure reorderSprite(dt: Single);
    function title(): string; override;
  end;

  SpriteBatchNodeReorderIssue766 = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    procedure reorderSprite(dt: Single);
    function makeSpriteZ(az: Integer): CCSprite;
  private
    batchNode: CCSpriteBatchNode;
    sprite1, sprite2, sprite3: CCSprite;
  end;

  SpriteBatchNodeReorderIssue767 = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    procedure reorderSprites(dt: Single);
  end;

  SpriteNilTexture = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteSubclass = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteBatchBug1217 = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  NodeSort = class(SpriteTestDemo)
  private
    m_pNode: CCNode;
    m_pSprite1, m_pSprite2, m_pSprite3, m_pSprite4, m_pSprite5: CCSprite;
  public
    constructor Create();
    procedure reorderSprite(dt: Single);
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteBatchNodeReorderSameIndex = class(SpriteTestDemo)
  public
    constructor Create();
    procedure reorderSprite(dt: Single);
    function title(): string; override;
    function subtitle(): string; override;
  private
    m_pBatchNode: CCSpriteBatchNode;
    m_pSprite1, m_pSprite2, m_pSprite3, m_pSprite4, m_pSprite5: CCSprite;
  end;

  Sprite6 = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
  end;

  SpriteColorOpacity = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure removeAndAddSprite(dt: Single);
  end;

  SpriteBatchNodeColorOpacity = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure removeAndAddSprite(dt: Single);
  end;

  SpriteAnimationSplit = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteFrameAliasNameTest = class(SpriteTestDemo)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onExit(); override;
    procedure onEnter(); override;
  end;

  SpriteOffsetAnchorRotation = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteBatchNodeOffsetAnchorRotation = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteOffsetAnchorScale = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteBatchNodeOffsetAnchorScale = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteHybrid = class(SpriteTestDemo)
  public
    m_usingSpriteBatchNode: Boolean;
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
    procedure reparentSprite(dt: Single);
  end;

  SpriteBatchNodeChildren = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteBatchNodeChildrenZ = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteChildrenVisibility = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteChildrenVisibilityIssue665 = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    procedure onExit(); override;
  end;

  SpriteChildrenAnchorPoint = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure onExit(); override;
  end;

  SpriteBatchNodeChildrenAnchorPoint = class(SpriteTestDemo)
  public
    constructor Create();
    procedure onExit(); override;
    function title(): string; override;
  end;

  SpriteBatchNodeChildrenScale = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
  end;

  SpriteChildrenChildren = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
  end;

  SpriteBatchNodeChildrenChildren = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
  end;

  AnimationCache = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteOffsetAnchorSkew = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
  end;

  SpriteBatchNodeOffsetAnchorSkew = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
  end;

  SpriteOffsetAnchorSkewScale = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
  end;

  SpriteBatchNodeOffsetAnchorSkewScale = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
  end;

  SpriteOffsetAnchorFlip = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteBatchNodeOffsetAnchorFlip = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteSkewNegativeScaleChildren = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteBatchNodeSkewNegativeScaleChildren = class(SpriteTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteDoubleResolution = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  AnimationCacheFile = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  SpriteBatchNodeReorderOneChild = class(SpriteTestDemo)
  public
    constructor Create();
    function title(): string; override;
    procedure reordersprite(dt: Single);
  private
    m_pBatchNode: CCSpriteBatchNode;
    m_pReorderSprite: CCSprite;
  end;





implementation
uses
  SysUtils, Math, Cocos2dx.CCAnimationCache, Cocos2dx.CCMacros, Cocos2dx.CCActionCamera,
  dglOpenGL, Cocos2dx.CCDirectorProjection, Cocos2dx.CCSpriteFrame, Cocos2dx.CCAnimation,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension, Cocos2dx.CCMenuItem,
  Cocos2dx.CCMenu, Cocos2dx.CCCommon,
  Cocos2dx.CCArray, Cocos2dx.CCPlatformMacros, Cocos2dx.CCGLProgram, Cocos2dx.CCShaderCache,
  Cocos2dx.CCTextureCache,
  Cocos2dx.CCSpriteFrameCache, Cocos2dx.CCTypes, Cocos2dx.CCAction, Cocos2dx.CCActionInterval,
  Cocos2dx.CCActionInstant;

const
  kTagTileMap = 1;
  kTagSpriteBatchNode = 1;
  kTagNode = 2;
  kTagAnimation1 = 1;
  kTagSpriteLeft = 2;
  kTagSpriteRight = 3;

const
  kTagSprite1 = 0;
  kTagSprite2 = 1;
  kTagSprite3 = 2;
  kTagSprite4 = 3;
  kTagSprite5 = 4;
  kTagSprite6 = 5;
  kTagSprite7 = 6;
  kTagSprite8 = 7;

const
  IDC_NEXT = 100;
  IDC_BACK = 101;
  IDC_RESTART = 102;

var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 55;

function createSpriteTestLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := SpriteZOrder.Create;
    1: bRet := SpriteBatchNode1.Create;
    2: bRet := SpriteFrameTest.Create;
    3: bRet := SpriteFrameAliasNameTest.Create;
    4: bRet := SpriteAnchorPoint.Create;
    5: bRet := SpriteBatchNodeAnchorPoint.Create;
    6: bRet := SpriteOffsetAnchorRotation.Create;
    7: bRet := SpriteBatchNodeOffsetAnchorRotation.Create;
    8: bRet := SpriteOffsetAnchorScale.Create;
    9: bRet := SpriteBatchNodeOffsetAnchorScale.Create;
    10: bRet := SpriteAnimationSplit.Create;
    11: bRet := SpriteColorOpacity.Create;
    12: bRet := SpriteBatchNodeColorOpacity.Create;
    13: bRet := Sprite1.Create;
    14: bRet := SpriteBatchNodeZOrder.Create;
    15: bRet := SpriteBatchNodeReorder.Create;
    16: bRet := SpriteBatchNodeReorderIssue744.Create;
    17: bRet := SpriteBatchNodeReorderIssue766.Create;
    18: bRet := SpriteBatchNodeReorderIssue767.Create;
    19: bRet := SpriteZVertex.Create;
    20: bRet := SpriteBatchNodeZVertex.Create;
    21: bRet := Sprite6.Create;
    22: bRet := SpriteFlip.Create;
    23: bRet := SpriteBatchNodeFlip.Create;
    24: bRet := SpriteAliased.Create;
    25: bRet := SpriteBatchNodeAliased.Create;
    26: bRet := SpriteNewTexture.Create;
    27: bRet := SpriteBatchNodeNewTexture.Create;
    28: bRet := SpriteHybrid.Create;
    29: bRet := SpriteBatchNodeChildren.Create;
    30: bRet := SpriteBatchNodeChildrenZ.Create;
    31: bRet := SpriteChildrenVisibility.Create;
    32: bRet := SpriteChildrenVisibilityIssue665.Create;
    33: bRet := SpriteChildrenAnchorPoint.Create;
    34: bRet := SpriteBatchNodeChildrenAnchorPoint.Create;
    35: bRet := SpriteBatchNodeChildrenScale.Create;
    36: bRet := SpriteChildrenChildren.Create;
    37: bRet := SpriteBatchNodeChildrenChildren.Create;
    38: bRet := SpriteNilTexture.Create;
    39: bRet := SpriteSubclass.Create;
    40: bRet := AnimationCache.Create;
    41: bRet := SpriteOffsetAnchorSkew.Create;
    42: bRet := SpriteBatchNodeOffsetAnchorSkew.Create;
    43: bRet := SpriteOffsetAnchorSkewScale.Create;
    44: bRet := SpriteBatchNodeOffsetAnchorSkewScale.Create;
    45: bRet := SpriteOffsetAnchorFlip.Create;
    46: bRet := SpriteBatchNodeOffsetAnchorFlip.Create;
    47: bRet := SpriteBatchNodeReorderSameIndex.Create;
    48: bRet := SpriteBatchNodeReorderOneChild.Create;
    49: bRet := NodeSort.Create;
    50: bRet := SpriteSkewNegativeScaleChildren.Create;
    51: bRet := SpriteBatchNodeSkewNegativeScaleChildren.Create;
    52: bRet := SpriteDoubleResolution.Create;
    53: bRet := SpriteBatchBug1217.Create;
    54: bRet := AnimationCacheFile.Create;
  end;

  Result := bRet;
end;

function nextSpriteTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createSpriteTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backSpriteTestAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createSpriteTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartSpriteTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createSpriteTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ SpriteTestDemo }

procedure SpriteTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := SpriteTestScene.Create();
  s.addChild(backSpriteTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor SpriteTestDemo.Create;
begin
  inherited Create();
end;

destructor SpriteTestDemo.Destroy;
begin

  inherited;
end;

procedure SpriteTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := SpriteTestScene.Create();
  s.addChild(nextSpriteTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure SpriteTestDemo.onEnter;
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
  label1.setPosition(ccp(s.width / 2, s.height - 50));

  strSubtitle := subtitle();
  if strSubtitle <> '' then
  begin
    label2 := CCLabelTTF._create(strSubtitle, 'Thonburi', 16);
    addChild(label2, 1);
    label2.setPosition(ccp(s.width / 2, s.height - 80));
  end;

  item1 := CCMenuItemImage._create('Images/b1.png', 'Images/b2.png', Self, backCallback);
  item2 := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, restartCallback);
  item3 := CCMenuItemImage._create('Images/f1.png', 'Images/f2.png', Self, nextCallback);

  menu := CCMenu._create([item1, item2, item3]);
  menu.setPosition(CCPointZero);
  item1.setPosition(ccp(s.width / 2 - item2.ContentSize.width * 2, item2.ContentSize.height / 2));
  item2.setPosition(ccp(s.width / 2, item2.ContentSize.height / 2));
  item3.setPosition(ccp(s.width / 2 + item2.ContentSize.width * 2, item2.ContentSize.height / 2));

  addChild(menu, 1);
end;

procedure SpriteTestDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := SpriteTestScene.Create();
  s.addChild(restartSpriteTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function SpriteTestDemo.subtitle: string;
begin
  Result := '';
end;

function SpriteTestDemo.title: string;
begin
  Result := 'No title';
end;

{ SpriteTestScene }

procedure SpriteTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := nextSpriteTestAction();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ Sprite1 }

procedure Sprite1.addNewSpriteWithCoords(p: CCPoint);
var
  idx: Integer;
  x, y: Integer;
  s: CCSize;
  sprite: CCSprite;
  action, action_back, seq: CCActionInterval;
  frandom: Single;
begin
  s := CCDirector.sharedDirector.getWinSize;
  idx := Round(Random * 1400.0 / 100.0);
  x := (idx mod 5) * 85;
  y := (idx mod 3) * 121;

  sprite := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(x, y, 85, 121));
  addChild(sprite);
  sprite.setPosition(ccp(p.x, p.y));

  frandom := Random;

  if frandom < 0.2 then
    action := CCScaleBy._create(3, 2)
  else if frandom < 0.4 then
    action := CCRotateBy._create(3, 360)
  else if frandom < 0.6 then
    action := CCRotateBy._create(1, 3)
  else if frandom < 0.8 then
    action := CCTintBy._create(2, 0, -255, -255)
  else
    action := CCFadeOut._create(2);

  action_back := CCActionInterval(action.reverse());
  seq := CCActionInterval(CCSequence._create([action, action_back]));
  sprite.runAction(CCRepeatForever._create(seq));
end;

procedure Sprite1.ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent);
var
  touch: CCTouch;
  location: CCPoint;
begin
  touch := CCTouch(pTouches.anyObject());
  if touch <> nil then
  begin
    location := touch.getLocation();
    addNewSpriteWithCoords(location);
  end;
end;

constructor Sprite1.Create;
var
  s: CCSize;
begin
  inherited Create();
  setTouchEnabled(True);

  Randomize();

  s := CCDirector.sharedDirector.getWinSize();
  addNewSpriteWithCoords(ccp(s.width / 2, s.height / 2));
end;

function Sprite1.title: string;
begin
  Result := 'Sprite (tap screen)';
end;

{ SpriteAnchorPoint }

constructor SpriteAnchorPoint.Create;
var
  s: CCSize;
  i: Integer;
  sprite, point: CCSprite;
  action, pCopy: CCAction;
  rotate: CCActionInterval;
begin
  inherited Create();
  s := CCDirector.sharedDirector().getWinSize();
  rotate := CCRotateBy._create(10, 360);
  action := CCRepeatForever._create(rotate);

  for i := 0 to 2 do
  begin
    sprite := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * i, 121 * 1, 85, 121));
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));

    point := CCSprite._create('Images/r1.png');
    point.setScale(0.25);
    point.setPosition(sprite.getPosition());
    addChild(point, 10);

    case i of
      0: sprite.setAnchorPoint(CCPointZero);
      1: sprite.setAnchorPoint(ccp(0.5, 0.5));
      2: sprite.setAnchorPoint(ccp(1, 1));
    end;

    point.setPosition(sprite.getPosition());

    pCopy := CCAction(action.copy().autorelease());
    sprite.runAction(pCopy);

    addChild(sprite, i);
  end;
end;

function SpriteAnchorPoint.title: string;
begin
  Result := 'Sprite: anchor point';
end;

{ SpriteBatchNode1 }

procedure SpriteBatchNode1.addNewSpriteWithCoords(p: CCPoint);
var
  batchNode: CCSpriteBatchNode;
  idx, x, y: Integer;
  sprite: CCSprite;
  action, action_back, seq: CCActionInterval;
  frandom: Single;
begin
  batchNode := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));

  idx := Round(Random * 1400 / 100);
  x := (idx mod 5) * 85;
  y := (idx mod 3) * 121;

  sprite := CCSprite.createWithTexture(batchNode.getTexture(), CCRectMake(x, y, 85, 121));
  batchNode.addChild(sprite);

  sprite.setPosition(ccp(p.x, p.y));

  frandom := Random;

  if frandom < 0.2 then
    action := CCScaleBy._create(3, 2)
  else if frandom < 0.4 then
    action := CCRotateBy._create(3, 360)
  else if frandom < 0.6 then
    action := CCBlink._create(1, 3)
  else if frandom < 0.8 then
    action := CCTintBy._create(2, 0, -255, -255)
  else
    action := CCFadeOut._create(2);

  action_back := CCActionInterval(action.reverse());
  seq := CCActionInterval(CCSequence._create([action, action_back]));
  sprite.runAction(CCRepeatForever._create(seq));
end;

procedure SpriteBatchNode1.ccTouchesEnded(pTouches: CCSet;
  pEvent: CCEvent);
var
  touch: CCTouch;
  i: Integer;
  location: CCPoint;
begin
  for i := 0 to pTouches.count() - 1 do
  begin
    touch := CCTouch(pTouches.getObject(i));
    if touch = nil then
      Break;

    location := touch.getLocation();
    addNewSpriteWithCoords(location);
  end;
end;

constructor SpriteBatchNode1.Create;
var
  batchNode: CCSpriteBatchNode;
  s: CCSize;
begin
  inherited Create();
  setTouchEnabled(True);

  batchNode := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 50);
  addChild(batchNode, 0, kTagSpriteBatchNode);

  Randomize();

  s := CCDirector.sharedDirector().getWinSize();
  addNewSpriteWithCoords(ccp(s.width / 2, s.height / 2));
end;

function SpriteBatchNode1.title: string;
begin
  Result := 'SpriteBatchNode (tap screen)';
end;

{ SpriteFlip }

constructor SpriteFlip.Create;
var
  s: CCSize;
  sprite1, sprite2: CCSprite;
begin
  inherited Create();
  s := CCDirector.sharedDirector().getWinSize();

  sprite1 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite1.setPosition(ccp(s.width / 2 - 100, s.height / 2));
  addChild(sprite1, 0, kTagSprite1);
  sprite2 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite2.setPosition(ccp(s.width / 2 + 100, s.height / 2));
  addChild(sprite2, 0, kTagSprite2);

  schedule(flipSprites, 1);
end;

procedure SpriteFlip.flipSprites(dt: Single);
var
  sprite1, sprite2: CCSprite;
  x, y: Boolean;
begin
  sprite1 := CCSprite(getChildByTag(kTagSprite1));
  sprite2 := CCSprite(getChildByTag(kTagSprite2));

  x := sprite1.isFlipX();
  y := sprite2.isFlipY();

  sprite1.setFlipX(not x);
  sprite2.setFlipY(not y);
end;

function SpriteFlip.title: string;
begin
  Result := 'Sprite Flip X & Y';
end;

{ SpriteBatchNodeReorder }

constructor SpriteBatchNodeReorder.Create;
var
  a, children, sChildren: CCArray;
  asmtest: CCSpriteBatchNode;
  i: Integer;
  s1, child: CCSprite;
  prev, currentIndex: Integer;
begin
  inherited Create();

  a := CCArray.createWithCapacity(10);
  asmtest := CCSpriteBatchNode._create('animations/ghosts.png');

  for i := 0 to 10 - 1 do
  begin
    s1 := CCSprite.createWithTexture(asmtest.getTexture(), CCRectMake(0, 0, 50, 50));
    a.addObject(s1);
    asmtest.addChild(s1, 10);
  end;

  for i := 0 to 10 - 1 do
  begin
    if i <> 5 then
      asmtest.reorderChild(CCNode(a.objectAtIndex(i)), 9);
  end;

  prev := -1;
  children := asmtest.Children;
  if (children <> nil) and (children.count() > 0) then
  begin
    for i := 0 to children.count() - 1 do
    begin
      child := CCSprite(children.objectAtIndex(i));
      if child = nil then
        Break;

      currentIndex := child.getAtlasIndex();
      CCAssert(prev = currentIndex - 1, 'Child order failed');
      prev := currentIndex;
    end;
  end;

  prev := -1;
  sChildren := asmtest.getDescendants();
  if (sChildren <> nil) and (sChildren.count() > 0) then
  begin
    for i := 0 to sChildren.count() - 1 do
    begin
      child := CCSprite(sChildren.objectAtIndex(i));
      if child = nil then
        Break;

      currentIndex := child.getAtlasIndex();
      CCAssert(prev = currentIndex - 1, 'Child order failed');
      prev := currentIndex;
    end;
  end;
end;

function SpriteBatchNodeReorder.subtitle: string;
begin
  Result := 'SpriteBatchNode: reorder #1';
end;

function SpriteBatchNodeReorder.title: string;
begin
  Result := 'Should not crash';
end;

{ SpriteBatchNodeReorderIssue744 }

constructor SpriteBatchNodeReorderIssue744.Create;
var
  s: CCSize;
  batch: CCSpriteBatchNode;
  sprite: CCSprite;
begin
  inherited Create();

  s := CCDirector.sharedDirector().getWinSize();

  // Testing issue #744
  // http://code.google.com/p/cocos2d-iphone/issues/detail?id=744
  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 15);
  addChild(batch, 0, kTagSpriteBatchNode);

  sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(0, 0, 85, 121));
  sprite.setPosition(ccp(s.width / 2, s.height / 2));
  batch.addChild(sprite, 3);
  batch.reorderChild(sprite, 1);
end;

function SpriteBatchNodeReorderIssue744.subtitle: string;
begin
  Result := 'SpriteBatchNode: reorder issue #744';
end;

function SpriteBatchNodeReorderIssue744.title: string;
begin
  Result := 'Should not crash';
end;

{ SpriteZVertex }

constructor SpriteZVertex.Create;
var
  alphaTestShader: CCGLProgram;
  alphaValueLocation: GLint;
  s: CCSize;
  step: Single;
  node: CCNode;
  i: Integer;
  sprite: CCSprite;
begin
  inherited Create();

  alphaTestShader := CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColorAlphaTest);
  alphaValueLocation := glGetUniformLocation(alphaTestShader.getProgram(), kCCUniformAlphaTestValue);

  if ShaderProgram <> nil then
  begin
    ShaderProgram.setUniformLocationWith1f(alphaValueLocation, 0.0);
  end;

  m_dir := 1; m_time := 0;
  s := CCDirector.sharedDirector().getWinSize();
  step := s.width / 12;

  node := CCNode._create();
  node.setContentSize(CCSizeMake(s.width, s.height));
  node.AnchorPoint := ccp(0.5, 0.5);
  node.setPosition(ccp(s.width / 2, s.height / 2));

  addChild(node, 0);

  for i := 0 to 5 - 1 do
  begin
    sprite := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 0, 121 * 1, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    sprite.setVerteZ(10 + i * 40);
    sprite.ShaderProgram := alphaTestShader;
    node.addChild(sprite, 0);
  end;

  for i := 5 to 11 - 1 do
  begin
    sprite := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 0, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    sprite.setVerteZ(10 + (10 - i) * 40);
    sprite.ShaderProgram := alphaTestShader;
    node.addChild(sprite, 0);
  end;

  node.runAction(CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 0));
end;

procedure SpriteZVertex.onEnter;
begin
  inherited onEnter();
  CCDirector.sharedDirector().setProjection(kCCDirectorProjection3D);
end;

procedure SpriteZVertex.onExit;
begin
  CCDirector.sharedDirector().setProjection(kCCDirectorProjection2D);
  inherited onExit();
end;

function SpriteZVertex.title: string;
begin
  Result := 'Sprite: openGL Z vertex';
end;

{ SpriteBatchNodeZVertex }

constructor SpriteBatchNodeZVertex.Create;
var
  alphaTestShader: CCGLProgram;
  alphaValueLocation: GLint;
  s: CCSize;
  step: Single;
  i: Integer;
  sprite: CCSprite;
  batch: CCSpriteBatchNode;
begin
  inherited Create();

    //
    // This test tests z-order
    // If you are going to use it is better to use a 3D projection
    //
    // WARNING:
    // The developer is resposible for ordering its sprites according to its Z if the sprite has
    // transparent parts.
    //
    //
    // Configure shader to mimic glAlphaTest
    //
  alphaTestShader := CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColorAlphaTest);
  alphaValueLocation := glGetUniformLocation(alphaTestShader.getProgram(), kCCUniformAlphaTestValue);

  if ShaderProgram <> nil then
  begin
    ShaderProgram.setUniformLocationWith1f(alphaValueLocation, 0.0);
  end;

  s := CCDirector.sharedDirector().getWinSize();
  step := s.width / 12;

  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 1);
  batch.setContentSize(CCSizeMake(s.width, s.height));
  batch.AnchorPoint := ccp(0.5, 0.5);
  batch.setPosition(ccp(s.width / 2, s.height / 2));
  batch.ShaderProgram := alphaTestShader;
  addChild(batch, 0, kTagSpriteBatchNode);

  for i := 0 to 5 - 1 do
  begin
    sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 0, 121 * 1, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    sprite.setVerteZ(10 + i * 40);
    batch.addChild(sprite, 0);
  end;

  for i := 5 to 11 - 1 do
  begin
    sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 0, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    sprite.setVerteZ(10 + (10 - i) * 40);
    batch.addChild(sprite, 0);
  end;

  batch.runAction(CCOrbitCamera._create(10, 1, 0, 0, 360, 0, 0));
end;

procedure SpriteBatchNodeZVertex.onEnter;
begin
  inherited onEnter();
  CCDirector.sharedDirector().setProjection(kCCDirectorProjection3D);
end;

procedure SpriteBatchNodeZVertex.onExit;
begin
  CCDirector.sharedDirector().setProjection(kCCDirectorProjection2D);
  inherited onExit();
end;

function SpriteBatchNodeZVertex.title: string;
begin
  Result := 'SpriteBatchNode: openGL Z vertex';
end;

{ SpriteBatchNodeAnchorPoint }

constructor SpriteBatchNodeAnchorPoint.Create;
var
  batch: CCSpriteBatchNode;
  s: CCSize;
  i: Integer;
  sprite, point: CCSprite;
  rotate: CCActionInterval;
  action, copy: CCAction;
begin
  inherited Create();

  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 1);
  addChild(batch, 0, kTagSpriteBatchNode);

  s := CCDirector.sharedDirector().getWinSize();

  rotate := CCRotateBy._create(10, 360);
  action := CCRepeatForever._create(rotate);

  for i := 0 to 3 - 1 do
  begin
    sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * i, 121 * 1, 85, 121));
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));

    point := CCSprite._create('Images/r1.png');
    point.setScale(0.25);
    point.setPosition(sprite.getPosition());
    addChild(point, 1);

    case i of
      0: sprite.setAnchorPoint(CCPointZero);
      1: sprite.setAnchorPoint(ccp(0.5, 0.5));
      2: sprite.setAnchorPoint(ccp(1, 1));
    end;

    point.setPosition(sprite.getPosition());
    copy := CCAction(action.copy().autorelease());
    sprite.runAction(copy);

    batch.addChild(sprite, i);
  end;
end;

function SpriteBatchNodeAnchorPoint.title: string;
begin
  Result := 'SpriteBatchNode: anchor point';
end;

{ SpriteAliased }

constructor SpriteAliased.Create;
var
  s: CCSize;
  sprite1, sprite2: CCSprite;
  scale, scale_back, seq: CCActionInterval;
  repeat1, repeat2: CCAction;
begin
  inherited Create();
  s := CCDirector.sharedDirector().getWinSize();

  sprite1 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite1.setPosition(ccp(s.width / 2 - 100, s.height / 2));
  addChild(sprite1, 0, kTagSprite1);

  sprite2 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite2.setPosition(ccp(s.width / 2 + 100, s.height / 2));
  addChild(sprite2, 0, kTagSprite2);

  scale := CCScaleBy._create(2, 5);
  scale_back := CCActionInterval(scale.reverse());
  seq := CCActionInterval(CCSequence._create([scale, scale_back]));
  repeat1 := CCRepeatForever._create(seq);
  repeat2 := CCAction(repeat1.copy().autorelease());

  sprite1.runAction(repeat1);
  sprite2.runAction(repeat2);
end;

procedure SpriteAliased.onEnter;
var
  sprite: CCSprite;
begin
  inherited onEnter;
  sprite := CCSprite(getChildByTag(kTagSprite1));
  sprite.getTexture().setAliasTexParameters();
end;

procedure SpriteAliased.onExit;
var
  sprite: CCSprite;
begin
  sprite := CCSprite(getChildByTag(kTagSprite1));
  sprite.getTexture().setAntiAliasTexParameters();
  inherited onExit();
end;

function SpriteAliased.title: string;
begin
  Result := 'Sprite Aliased';
end;

{ SpriteBatchNodeAliased }

constructor SpriteBatchNodeAliased.Create;
var
  batch: CCSpriteBatchNode;
  s: CCSize;
  sprite1, sprite2: CCSprite;
  scale, scale_back, seq: CCFiniteTimeAction;
  rep, rep2: CCAction;
begin
  inherited Create();
  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 10);
  addChild(batch, 0, kTagSpriteBatchNode);

  s := CCDirector.sharedDirector().getWinSize();

  sprite1 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite1.setPosition(ccp(s.width / 2 - 100, s.height / 2));
  batch.addChild(sprite1, 0, kTagSprite1);

  sprite2 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite2.setPosition(ccp(s.width / 2 + 100, s.height / 2));
  batch.addChild(sprite2, 0, kTagSprite2);

  scale := CCScaleBy._create(2, 5);
  scale_back := scale.reverse();
  seq := CCSequence._create([scale, scale_back]);
  rep := CCRepeatForever._create(CCActionInterval(seq));
  rep2 := CCAction(rep.copy().autorelease());

  sprite1.runAction(rep);
  sprite2.runAction(rep2);
end;

procedure SpriteBatchNodeAliased.onEnter;
var
  batch: CCSpriteBatchNode;
begin
  batch := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));
  batch.getTexture().setAliasTexParameters();
  inherited onEnter();
end;

procedure SpriteBatchNodeAliased.onExit;
var
  batch: CCSpriteBatchNode;
begin
  batch := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));
  batch.getTexture().setAntiAliasTexParameters();
  inherited onExit();
end;

function SpriteBatchNodeAliased.title: string;
begin
  Result := 'SpriteBatchNode Aliased';
end;

{ SpriteNewTexture }

procedure SpriteNewTexture.addNewSprite;
var
  s: CCSize;
  p: CCPoint;
  idx, x, y: Integer;
  node: CCNode;
  sprite: CCSprite;
  frandom: Single;
  action: CCActionInterval;
  action_back, seq: CCFiniteTimeAction;
begin
  s := CCDirector.sharedDirector().getWinSize();

  p := ccp(Random * s.width, Random * s.height);

  idx := Round(Random * 1400 / 100);
  x := (idx mod 5) * 85;
  y := (idx mod 3) * 121;

  node := getChildByTag(kTagSpriteBatchNode);
  sprite := CCSprite.createWithTexture(m_texture1, CCRectMake(x, y, 85, 121));
  node.addChild(sprite);

  sprite.setPosition(ccp(p.x, p.y));

  frandom := Random;
  if frandom < 0.2 then
    action := CCScaleBy._create(2, 2)
  else if frandom < 0.4 then
    action := CCRotateBy._create(3, 360)
  else if frandom < 0.6 then
    action := CCBlink._create(1, 3)
  else if frandom < 0.8 then
    action := CCTintBy._create(2, 0, -255, -255)
  else
    action := CCFadeOut._create(2);

  action_back := action.reverse;
  seq := CCSequence._create([action, action_back]);
  sprite.runAction(CCRepeatForever._create(CCActionInterval(seq)));
end;

procedure SpriteNewTexture.ccTouchesEnded(pTouches: CCSet;
  pEvent: CCEvent);
var
  node: CCNode;
  children: CCArray;
  i: Integer;
  sprite: CCSprite;
begin
  node := getChildByTag(kTagSpriteBatchNode);
  children := node.Children;

  if m_usingTexture1 then
  begin
    if (children <> nil) and (children.count() > 0) then
    begin
      for i := 0 to children.count() - 1 do
      begin
        sprite := CCSprite(children.objectAtIndex(i));
        if sprite = nil then
          Break;

        sprite.setTexture(m_texture2);
      end;
    end;
    m_usingTexture1 := False;
  end else
  begin
    if (children <> nil) and (children.count() > 0) then
    begin
      for i := 0 to children.count() - 1 do
      begin
        sprite := CCSprite(children.objectAtIndex(i));
        if sprite = nil then
          Break;

        sprite.setTexture(m_texture1);
      end;
    end;
    m_usingTexture1 := True;
  end;
end;

constructor SpriteNewTexture.Create;
var
  node: CCNode;
  i: Integer;
begin
  inherited Create();
  setTouchEnabled(True);

  node := CCNode._create();
  addChild(node, 0, kTagSpriteBatchNode);

  m_texture1 := CCTextureCache.sharedTextureCache().addImage('Images/grossini_dance_atlas.png');
  m_texture1.retain();
  m_texture2 := CCTextureCache.sharedTextureCache().addImage('Images/grossini_dance_atlas-mono.png');
  m_texture2.retain();

  m_usingTexture1 := True;

  Randomize();

  for i := 0 to 30 - 1 do
    addNewSprite();
end;

destructor SpriteNewTexture.Destroy;
begin
  m_texture1.release();
  m_texture2.release();
  inherited;
end;

function SpriteNewTexture.title: string;
begin
  Result := 'Sprite New texture (tap)';
end;

{ SpriteBatchNodeNewTexture }

procedure SpriteBatchNodeNewTexture.addNewSprite;
var
  s: CCSize;
  p: CCPoint;
  batch: CCSpriteBatchNode;
  idx, x, y: Integer;
  sprite: CCSprite;
  frandom: Single;
  action: CCActionInterval;
  action_back, seq: CCFiniteTimeAction;
begin
  s := CCDirector.sharedDirector().getWinSize();
  p := ccp(Random * s.width, Random * s.height);

  batch := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));

  idx := Round(Random * 1400 / 100);
  x := (idx mod 5) * 85;
  y := (idx mod 3) * 121;

  sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(x, y, 85, 121));
  batch.addChild(sprite);

  sprite.setPosition(ccp(p.x, p.y));

  frandom := Random;
  if frandom < 0.2 then
    action := CCScaleBy._create(2, 2)
  else if frandom < 0.4 then
    action := CCRotateBy._create(3, 360)
  else if frandom < 0.6 then
    action := CCBlink._create(1, 3)
  else if frandom < 0.8 then
    action := CCTintBy._create(2, 0, -255, -255)
  else
    action := CCFadeOut._create(2);

  action_back := action.reverse;
  seq := CCSequence._create([action, action_back]);
  sprite.runAction(CCRepeatForever._create(CCActionInterval(seq)));
end;

procedure SpriteBatchNodeNewTexture.ccTouchesEnded(pTouches: CCSet;
  pEvent: CCEvent);
var
  batch: CCSpriteBatchNode;
begin
  batch := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));
  if batch.getTexture() = m_texture1 then
    batch.setTexture(m_texture2)
  else
    batch.setTexture(m_texture1);
end;

constructor SpriteBatchNodeNewTexture.Create;
var
  batch: CCSpriteBatchNode;
  i: Integer;
begin
  inherited Create();

  setTouchEnabled(True);
  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 50);
  addChild(batch, 0, kTagSpriteBatchNode);

  m_texture1 := batch.getTexture(); m_texture1.retain();
  m_texture2 := CCTextureCache.sharedTextureCache().addImage('Images/grossini_dance_atlas-mono.png');
  m_texture2.retain();

  Randomize();

  for i := 0 to 30 - 1 do
    addNewSprite();
end;

destructor SpriteBatchNodeNewTexture.Destroy;
begin
  m_texture1.release();
  m_texture2.release();
  inherited;
end;

function SpriteBatchNodeNewTexture.title: string;
begin
  Result := 'SpriteBatchNode new texture (tap)';
end;

{ SpriteFrameTest }

procedure SpriteFrameTest.flipSprites(dt: Single);
var
  fx, fy: Boolean;
  i: Integer;
begin
  Inc(m_nCounter);

  fx := False; fy := False;
  i := m_nCounter mod 4;

  case i of
    0: begin fx := False; fy := False; end;
    1: begin fx := True; fy := False; end;
    2: begin fx := False; fy := True; end;
    3: begin fx := True; fy := True; end;
  end;

  m_pSprite1.setFlipX(fx);
  m_pSprite1.setFlipY(fy);
  m_pSprite2.setFlipX(fx);
  m_pSprite2.setFlipY(fy);
end;

procedure SpriteFrameTest.onEnter;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  spritebatch: CCSpriteBatchNode;
  animFrames, moreFrames: CCArray;
  animation: CCAnimation;
  i: Integer;
  frame: CCSpriteFrame;
  animMixed: CCAnimation;
  str: string;
begin
  inherited onEnter();
  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  cache.addSpriteFramesWithFile('animations/grossini_blue.plist', 'animations/grossini_blue.png');

  m_pSprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  m_pSprite1.setPosition(ccp(s.width / 2 - 80, s.height / 2));

  spritebatch := CCSpriteBatchNode._create('animations/grossini.png');
  spritebatch.addChild(m_pSprite1);
  addChild(spritebatch);

  animFrames := CCArray.createWithCapacity(15);
  for i := 1 to 15 - 1 do
  begin
    str := Format('grossini_dance_%.2d.png', [i]);
    frame := cache.spriteFrameByName(str);
    animFrames.addObject(frame);
  end;

  animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
  m_pSprite1.runAction(CCRepeatForever._create(CCAnimate._create(animation)));

  m_pSprite1.setFlipX(False);
  m_pSprite1.setFlipY(False);

  m_pSprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  m_pSprite2.setPosition(ccp(s.width / 2 + 80, s.height / 2));
  addChild(m_pSprite2);

  moreFrames := CCArray.createWithCapacity(20);
  for i := 1 to 15 - 1 do
  begin
    str := Format('grossini_dance_gray_%.2d.png', [i]);
    frame := cache.spriteFrameByName(str);
    moreFrames.addObject(frame);
  end;

  for i := 1 to 5 - 1 do
  begin
    str := Format('grossini_blue_%.2d.png', [i]);
    frame := cache.spriteFrameByName(str);
    moreFrames.addObject(frame);
  end;

  moreFrames.addObjectsFromArray(animFrames);
  animMixed := CCAnimation.createWithSpriteFrames(moreFrames, 0.3);

  m_pSprite2.runAction(CCRepeatForever._create(CCAnimate._create(animMixed)));

  m_pSprite2.setFlipX(False);
  m_pSprite2.setFlipY(False);

  schedule(startIn05Secs, 0.5);

  m_nCounter := 0;
end;

procedure SpriteFrameTest.onExit;
var
  cache: CCSpriteFrameCache;
begin
  inherited onExit();
  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_blue.plist');
end;

procedure SpriteFrameTest.startIn05Secs(dt: Single);
begin
  unschedule(startIn05Secs);
  schedule(flipSprites, 1);
end;

function SpriteFrameTest.subtitle: string;
begin
  Result := 'Testing issue #792';
end;

function SpriteFrameTest.title: string;
begin
  Result := 'Sprite vs. SpriteBatchNode animation';
end;

{ SpriteZOrder }

constructor SpriteZOrder.Create;
var
  s: CCSize;
  sprite: CCSprite;
  step: Single;
  i: Integer;
begin
  inherited Create();

  s := CCDirector.sharedDirector().getWinSize();

  m_dir := 1;
  step := s.width / 11;
  for i := 0 to 5 - 1 do
  begin
    sprite := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 0, 121 * 1, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    addChild(sprite, i);
  end;

  for i := 5 to 10 - 1 do
  begin
    sprite := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 0, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    addChild(sprite, 14 - i);
  end;

  sprite := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 3, 121 * 0, 85, 121));
  sprite.setPosition(ccp(s.width / 2, s.height / 2 - 20));
  sprite.setScaleX(6);
  sprite.setColor(ccRED);
  addChild(sprite, -1, kTagSprite1);

  schedule(reorderSprite, 1);
end;

procedure SpriteZOrder.reorderSprite(dt: Single);
var
  sprite: CCSprite;
  z: Integer;
begin
  sprite := CCSprite(getChildByTag(kTagSprite1));

  z := sprite.ZOrder;

  if z < -1 then
    m_dir := 1;
  if z > 10 then
    m_dir := -1;

  z := z + m_dir * 3;

  reorderChild(sprite, z);
end;

function SpriteZOrder.title: string;
begin
  Result := 'Sprite: Z order';
end;

{ SpriteBatchNodeZOrder }

constructor SpriteBatchNodeZOrder.Create;
var
  s: CCSize;
  sprite: CCSprite;
  step: Single;
  i: Integer;
  batch: CCSpriteBatchNode;
begin
  inherited Create();

  s := CCDirector.sharedDirector().getWinSize();

  m_dir := 1;
  step := s.width / 11;
  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 1);
  addChild(batch, 0, kTagSpriteBatchNode);

  for i := 0 to 5 - 1 do
  begin
    sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 0, 121 * 1, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    batch.addChild(sprite, i);
  end;

  for i := 5 to 10 - 1 do
  begin
    sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 0, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));
    batch.addChild(sprite, 14 - i);
  end;

  sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 3, 121 * 0, 85, 121));
  sprite.setPosition(ccp(s.width / 2, s.height / 2 - 20));
  sprite.setScaleX(6);
  sprite.setColor(ccRED);
  batch.addChild(sprite, -1, kTagSprite1);

  schedule(reorderSprite, 1);
end;

procedure SpriteBatchNodeZOrder.reorderSprite(dt: Single);
var
  batch: CCSpriteBatchNode;
  sprite: CCSprite;
  z: Integer;
begin
  batch := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));
  sprite := CCSprite(batch.getChildByTag(kTagSprite1));
  z := sprite.ZOrder;

  if z < -1 then
    m_dir := 1;
  if z > 10 then
    m_dir := -1;

  z := z + m_dir * 3;

  batch.reorderChild(sprite, z);
end;

function SpriteBatchNodeZOrder.title: string;
begin
  Result := 'SpriteBatchNode: Z order';
end;

{ SpriteBatchNodeReorderIssue766 }

constructor SpriteBatchNodeReorderIssue766.Create;
begin
  inherited Create();

  batchNode := CCSpriteBatchNode._create('Images/piece.png', 15);
  addChild(batchNode, 1, 0);

  sprite1 := makeSpriteZ(2);
  sprite1.setPosition(CCPointMake(200, 160));

  sprite2 := makeSpriteZ(3);
  sprite2.setPosition(CCPointMake(264, 160));

  sprite3 := makeSpriteZ(4);
  sprite3.setPosition(CCPointMake(328, 160));

  schedule(reorderSprite, 2);
end;

function SpriteBatchNodeReorderIssue766.makeSpriteZ(az: Integer): CCSprite;
var
  sprite, spriteShadow, spriteTop: CCSprite;
begin
  sprite := CCSprite.createWithTexture(batchNode.getTexture(), CCRectMake(128, 0, 64, 64));
  batchNode.addChild(sprite, az + 1, 0);

  spriteShadow := CCSprite.createWithTexture(batchNode.getTexture(), CCRectMake(0, 0, 64, 64));
  spriteShadow.setOpacity(128);
  sprite.addChild(spriteShadow, az, 3);

  spriteTop := CCSprite.createWithTexture(batchNode.getTexture(), CCRectMake(64, 0, 64, 64));
  sprite.addChild(spriteTop, az + 2, 3);

  Result := sprite;
end;

procedure SpriteBatchNodeReorderIssue766.reorderSprite(dt: Single);
begin
  unschedule(reorderSprite);
  batchNode.reorderChild(sprite1, 4);
end;

function SpriteBatchNodeReorderIssue766.subtitle: string;
begin
  Result := 'In 2 seconds 1 sprite will be reordered';
end;

function SpriteBatchNodeReorderIssue766.title: string;
begin
  Result := 'SpriteBatchNode: reorder issue #766';
end;

{ SpriteBatchNodeReorderIssue767 }

constructor SpriteBatchNodeReorderIssue767.Create;
var
  s: CCSize;
  aParent: CCNode;
  l1, l2a, l2b, l3a1, l3a2, l3b1, l3b2: CCSprite;
  l1size, l2asize, l2bsize: CCSize;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile('animations/ghosts.plist', 'animations/ghosts.png');

  aParent := CCSpriteBatchNode._create('animations/ghosts.png');
  addChild(aParent, 0, kTagSprite1);

  l1 := CCSprite.createWithSpriteFrameName('father.gif');
  l1.setPosition(ccp(s.width / 2, s.height / 2));
  aParent.addChild(l1, 0, kTagSprite2);
  l1size := l1.ContentSize;

  l2a := CCSprite.createWithSpriteFrameName('sister1.gif');
  l2a.setPosition(ccp(-25 + l1size.width / 2, 0 + l1size.height / 2));
  l1.addChild(l2a, -1, kTagSpriteLeft);
  l2asize := l2a.ContentSize;

  l2b := CCSprite.createWithSpriteFrameName('sister2.gif');
  l2b.setPosition(ccp(25 + l1size.width / 2, 0 + l1size.height / 2));
  l1.addChild(l2b, 1, kTagSpriteRight);
  l2bsize := l2a.ContentSize;

  l3a1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a1.Scale := 0.65;
  l3a1.setPosition(ccp(0 + l2asize.width / 2, -50 + l2asize.height / 2));
  l2a.addChild(l3a1, -1);

  l3a2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a2.Scale := 0.65;
  l3a2.setPosition(ccp(0 + l2asize.width / 2, 50 + l2asize.height / 2));
  l2a.addChild(l3a2, 1);

  l3b1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b1.Scale := 0.65;
  l3b1.setPosition(ccp(0 + l2bsize.width / 2, -50 + l2bsize.height / 2));
  l2b.addChild(l3b1, -1);

  l3b2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b2.Scale := 0.65;
  l3b2.setPosition(ccp(0 + l2bsize.width / 2, 50 + l2bsize.height / 2));
  l2b.addChild(l3b2, 1);

  schedule(reorderSprites, 1);
end;

procedure SpriteBatchNodeReorderIssue767.reorderSprites(dt: Single);
var
  spriteBatch: CCSpriteBatchNode;
  father, left, right: CCSprite;
  newZLeft: Integer;
begin
  spriteBatch := CCSpriteBatchNode(getChildByTag(kTagSprite1));
  father := CCSprite(spriteBatch.getChildByTag(kTagSprite2));
  left := CCSprite(father.getChildByTag(kTagSpriteLeft));
  right := CCSprite(father.getChildByTag(kTagSpriteRight));

  newZLeft := 1;

  if left.ZOrder = 1 then
    newZLeft := -1;

  father.reorderChild(left, newZLeft);
  father.reorderChild(right, -newZLeft);
end;

function SpriteBatchNodeReorderIssue767.subtitle: string;
begin
  Result := 'SpriteBatchNode: reorder issue #767';
end;

function SpriteBatchNodeReorderIssue767.title: string;
begin
  Result := 'Should not crash';
end;

{ SpriteBatchNodeFlip }

constructor SpriteBatchNodeFlip.Create;
var
  batch: CCSpriteBatchNode;
  s: CCSize;
  sprite1, sprite2: CCSprite;
begin
  inherited Create();

  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 10);
  addChild(batch, 0, kTagSpriteBatchNode);

  s := CCDirector.sharedDirector().getWinSize();

  sprite1 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite1.setPosition(ccp(s.width / 2 - 100, s.height / 2));
  batch.addChild(sprite1, 0, kTagSprite1);

  sprite2 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite2.setPosition(ccp(s.width / 2 + 100, s.height / 2));
  batch.addChild(sprite2, 0, kTagSprite2);

  schedule(flipSprites, 1);
end;

procedure SpriteBatchNodeFlip.flipSprites(dt: Single);
var
  batch: CCSpriteBatchNode;
  sprite1, sprite2: CCSprite;
  x, y: Boolean;
begin
  batch := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));
  sprite1 := CCSprite(batch.getChildByTag(kTagSprite1));
  sprite2 := CCSprite(batch.getChildByTag(kTagSprite2));

  x := sprite1.isFlipX();
  y := sprite2.isFlipY();

  sprite1.setFlipX(not x);
  sprite2.setFlipY(not y);
end;

function SpriteBatchNodeFlip.title: string;
begin
  Result := 'SpriteBatchNode Flip X & Y';
end;

{ SpriteNilTexture }

constructor SpriteNilTexture.Create;
var
  s: CCSize;
  sprite: CCSprite;
begin
  inherited Create();

  s := CCDirector.sharedDirector().getWinSize();

  sprite := CCSprite.Create();
  sprite.init();
  sprite.setTextureRect(CCRectMake(0, 0, 300, 300));
  sprite.setColor(ccRED);
  sprite.setOpacity(128);
  sprite.setPosition(ccp(3 * s.width / 4, s.height / 2));
  addChild(sprite, 100);
  sprite.release();

  sprite := CCSprite.Create();
  sprite.init();
  sprite.setTextureRect(CCRectMake(0, 0, 300, 300));
  sprite.setColor(ccBLUE);
  sprite.setOpacity(128);
  sprite.setPosition(ccp(1 * s.width / 4, s.height / 2));
  addChild(sprite, 100);
  sprite.release();
end;

function SpriteNilTexture.subtitle: string;
begin
  Result := 'opacity and color should work';
end;

function SpriteNilTexture.title: string;
begin
  Result := 'Sprite without texture';
end;

{ SpriteBatchBug1217 }

constructor SpriteBatchBug1217.Create;
var
  bn: CCSpriteBatchNode;
  s1, s2, s3: CCSprite;
begin
  inherited Create();

  bn := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 15);

  s1 := CCSprite.createWithTexture(bn.getTexture(), CCRectMake(0, 0, 57, 57));
  s2 := CCSprite.createWithTexture(bn.getTexture(), CCRectMake(0, 0, 57, 57));
  s3 := CCSprite.createWithTexture(bn.getTexture(), CCRectMake(0, 0, 57, 57));

  s1.setColor(ccc3(255, 0, 0));
  s2.setColor(ccc3(0, 255, 0));
  s3.setColor(ccc3(0, 0, 255));

  s1.setPosition(ccp(20, 200));
  s2.setPosition(ccp(100, 0));
  s3.setPosition(ccp(100, 0));

  bn.setPosition(ccp(0, 0));

  s1.addChild(s2);
  s2.addChild(s3);
  bn.addChild(s1);

  addChild(bn);
end;

function SpriteBatchBug1217.subtitle: string;
begin
  Result := 'Adding big family to spritebatch. You shall see 3 heads';
end;

function SpriteBatchBug1217.title: string;
begin
  Result := 'SpriteBatch - Bug 1217';
end;

{ NodeSort }

constructor NodeSort.Create;
begin
  inherited Create();

  m_pNode := CCNode._create();
  addChild(m_pNode, 0, 0);

  m_pSprite1 := CCSprite._create('Images/piece.png', CCRectMake(128, 0, 64, 64));
  m_pSprite1.setPosition(CCPointMake(100, 160));
  m_pNode.addChild(m_pSprite1, -6, 1);

  m_pSprite2 := CCSprite._create('Images/piece.png', CCRectMake(128, 0, 64, 64));
  m_pSprite2.setPosition(CCPointMake(164, 160));
  m_pNode.addChild(m_pSprite2, -6, 2);

  m_pSprite3 := CCSprite._create('Images/piece.png', CCRectMake(128, 0, 64, 64));
  m_pSprite3.setPosition(CCPointMake(228, 160));
  m_pNode.addChild(m_pSprite3, -4, 3);

  m_pSprite4 := CCSprite._create('Images/piece.png', CCRectMake(128, 0, 64, 64));
  m_pSprite4.setPosition(CCPointMake(292, 160));
  m_pNode.addChild(m_pSprite4, -3, 4);

  m_pSprite5 := CCSprite._create('Images/piece.png', CCRectMake(128, 0, 64, 64));
  m_pSprite5.setPosition(CCPointMake(356, 160));
  m_pNode.addChild(m_pSprite5, -3, 5);

  schedule(reorderSprite);
end;

procedure NodeSort.reorderSprite(dt: Single);
var
  child: CCSprite;
  i: Integer;
  children: CCArray;
begin
  unschedule(reorderSprite);

  CCLog('Before reorder', []);

  children := m_pNode.Children;
  if (children <> nil) and (children.count() > 0) then
  begin
    for i := 0 to children.count() - 1 do
    begin
      child := CCSprite(children.objectAtIndex(i));
      CCLog('tag %d z %d', [child.Tag, child.ZOrder]);
    end;
  end;

  m_pNode.reorderChild(CCNode(children.objectAtIndex(0)), -6);
  m_pNode.sortAllChildren();
  CCLog('After reorder', []);

  if (children <> nil) and (children.count() > 0) then
  begin
    for i := 0 to children.count() - 1 do
    begin
      child := CCSprite(children.objectAtIndex(i));
      CCLog('tag %d z %d', [child.Tag, child.ZOrder]);
    end;
  end;
end;

function NodeSort.subtitle: string;
begin
  Result := 'node sort same index';
end;

function NodeSort.title: string;
begin
  Result := 'tag order in console should be 2,1,3,4,5';
end;

{ SpriteBatchNodeReorderSameIndex }

constructor SpriteBatchNodeReorderSameIndex.Create;
begin
  inherited Create();

  m_pBatchNode := CCSpriteBatchNode._create('Images/piece.png', 15);
  addChild(m_pBatchNode, 1, 0);

  m_pSprite1 := CCSprite.createWithTexture(m_pBatchNode.getTexture(), CCRectMake(128, 0, 64, 64));
  m_pSprite1.setPosition(CCPointMake(100, 160));
  m_pBatchNode.addChild(m_pSprite1, 3, 1);

  m_pSprite2 := CCSprite.createWithTexture(m_pBatchNode.getTexture(), CCRectMake(128, 0, 64, 64));
  m_pSprite2.setPosition(CCPointMake(164, 160));
  m_pBatchNode.addChild(m_pSprite2, 4, 2);

  m_pSprite3 := CCSprite.createWithTexture(m_pBatchNode.getTexture(), CCRectMake(128, 0, 64, 64));
  m_pSprite3.setPosition(CCPointMake(228, 160));
  m_pBatchNode.addChild(m_pSprite3, 4, 3);

  m_pSprite4 := CCSprite.createWithTexture(m_pBatchNode.getTexture(), CCRectMake(128, 0, 64, 64));
  m_pSprite4.setPosition(CCPointMake(292, 160));
  m_pBatchNode.addChild(m_pSprite4, 5, 4);

  m_pSprite5 := CCSprite.createWithTexture(m_pBatchNode.getTexture(), CCRectMake(128, 0, 64, 64));
  m_pSprite5.setPosition(CCPointMake(356, 160));
  m_pBatchNode.addChild(m_pSprite5, 6, 5);

  scheduleOnce(reorderSprite, 2);
end;

procedure SpriteBatchNodeReorderSameIndex.reorderSprite(dt: Single);
var
  pArray: CCArray;
  i: Integer;
  child: CCSprite;
begin
  m_pBatchNode.reorderChild(m_pSprite4, 4);
  m_pBatchNode.reorderChild(m_pSprite5, 4);
  m_pBatchNode.reorderChild(m_pSprite1, 4);

  m_pBatchNode.sortAllChildren();

  pArray := m_pBatchNode.getDescendants();

  if (pArray <> nil) and (pArray.count() > 0) then
  begin
    for i := 0 to pArray.count() - 1 do
    begin
      child := CCSprite(pArray.objectAtIndex(i));
      CCLog('tag %d', [child.Tag]);
    end;
  end;
end;

function SpriteBatchNodeReorderSameIndex.subtitle: string;
begin
  Result := 'tag order in console should be 2,3,4,5,1';
end;

function SpriteBatchNodeReorderSameIndex.title: string;
begin
  Result := 'SpriteBatchNodeReorder same index';
end;

{ Sprite6 }

constructor Sprite6.Create;
var
  batch: CCSpriteBatchNode;
  s: CCSize;
  rotate: CCActionInterval;
  action: CCAction;
  rotate_back: CCActionInterval;
  rotate_seq: CCFiniteTimeAction;
  rotate_forever: CCAction;
  scale, scale_seq: CCActionInterval;
  scale_back: CCFiniteTimeAction;
  scale_forever: CCAction;
  sprite: CCSprite;
  step: Single;
  i: Integer;
begin
  inherited Create();

  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 1);
  addChild(batch, 0, kTagSpriteBatchNode);
  batch.ignoreAnchorPointForPosition(True);

  s := CCDirector.sharedDirector().getWinSize();

  batch.AnchorPoint := ccp(0.5, 0.5);
  batch.setContentSize(CCSizeMake(s.width, s.height));

  rotate := CCRotateBy._create(5, 360);
  action := CCRepeatForever._create(rotate);

  rotate_back := CCActionInterval(rotate.reverse());
  rotate_seq := CCSequence._create([rotate, rotate_back]);
  rotate_forever := CCRepeatForever._create(CCActionInterval(rotate_seq));

  scale := CCScaleBy._create(5, 1.5);
  scale_back := scale.reverse();
  scale_seq := CCActionInterval(CCSequence._create([scale, scale_back]));
  scale_forever := CCRepeatForever._create(scale_seq);

  step := s.width / 4;
  for i := 0 to 2 do
  begin
    sprite := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * i, 121 * 1, 85, 121));
    sprite.setPosition(ccp((i + 1) * step, s.height / 2));

    sprite.runAction(CCAction(action.copy().autorelease()));
    batch.addChild(sprite, i);
  end;

  batch.runAction(scale_forever);
  batch.runAction(rotate_forever);
end;

function Sprite6.title: string;
begin
  Result := 'SpriteBatchNode transformation';
end;

{ SpriteColorOpacity }

constructor SpriteColorOpacity.Create;
var
  sprite1, sprite2, sprite3, sprite4, sprite5, sprite6, sprite8, sprite7: CCSprite;
  s: CCSize;
  action, action_back, fade: CCFiniteTimeAction;
  tintred, tintred_back, red: CCFiniteTimeAction;
  tintgreen, tintgreen_back, green: CCFiniteTimeAction;
  tintblue, tintblue_back, blue: CCFiniteTimeAction;
begin
  inherited;
  sprite1 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 0, 121 * 1, 85, 121));
  sprite2 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite3 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 2, 121 * 1, 85, 121));
  sprite4 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 3, 121 * 1, 85, 121));
  sprite5 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 0, 121 * 1, 85, 121));
  sprite6 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite7 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 2, 121 * 1, 85, 121));
  sprite8 := CCSprite._create('Images/grossini_dance_atlas.png', CCRectMake(85 * 3, 121 * 1, 85, 121));

  s := CCDirector.sharedDirector().getWinSize();

  sprite1.setPosition(ccp((s.width / 5) * 1, (s.height / 3) * 1));
  sprite2.setPosition(ccp((s.width / 5) * 2, (s.height / 3) * 1));
  sprite3.setPosition(ccp((s.width / 5) * 3, (s.height / 3) * 1));
  sprite4.setPosition(ccp((s.width / 5) * 4, (s.height / 3) * 1));
  sprite5.setPosition(ccp((s.width / 5) * 1, (s.height / 3) * 2));
  sprite6.setPosition(ccp((s.width / 5) * 2, (s.height / 3) * 2));
  sprite7.setPosition(ccp((s.width / 5) * 3, (s.height / 3) * 2));
  sprite8.setPosition(ccp((s.width / 5) * 4, (s.height / 3) * 2));

  action := CCFadeIn._create(2);
  action_back := action.reverse();
  fade := CCRepeatForever._create(CCActionInterval(CCSequence._create([action, action_back])));

  tintred := CCTintBy._create(2, 0, -255, -255);
  tintred_back := tintred.reverse();
  red := CCRepeatForever._create(CCActionInterval(CCSequence._create([tintred, tintred_back])));

  tintgreen := CCTintBy._create(2, -255, 0, -255);
  tintgreen_back := tintgreen.reverse();
  green := CCRepeatForever._create(CCActionInterval(CCSequence._create([tintgreen, tintgreen_back])));

  tintblue := CCTintBy._create(2, -255, -255, 0);
  tintblue_back := tintblue.reverse();
  blue := CCRepeatForever._create(CCActionInterval(CCSequence._create([tintblue, tintblue_back])));

  sprite5.runAction(red);
  sprite6.runAction(green);
  sprite7.runAction(blue);
  sprite8.runAction(fade);

  addChild(sprite1, 0, kTagSprite1);
  addChild(sprite2, 0, kTagSprite2);
  addChild(sprite3, 0, kTagSprite3);
  addChild(sprite4, 0, kTagSprite4);
  addChild(sprite5, 0, kTagSprite5);
  addChild(sprite6, 0, kTagSprite6);
  addChild(sprite7, 0, kTagSprite7);
  addChild(sprite8, 0, kTagSprite8);

  schedule(removeAndAddSprite, 2);
end;

procedure SpriteColorOpacity.removeAndAddSprite(dt: Single);
var
  sprite: CCSprite;
begin
  sprite := CCSprite(getChildByTag(kTagSprite5));
  sprite.retain();
  removeChild(sprite, False);
  addChild(sprite, 0, kTagSprite5);
  sprite.release();
end;

function SpriteColorOpacity.title: string;
begin
  Result := 'Sprite: Color & Opacity';
end;

{ SpriteBatchNodeColorOpacity }

constructor SpriteBatchNodeColorOpacity.Create;
var
  sprite1, sprite2, sprite3, sprite4, sprite5, sprite6, sprite8, sprite7: CCSprite;
  s: CCSize;
  action, action_back, fade: CCFiniteTimeAction;
  tintred, tintred_back, red: CCFiniteTimeAction;
  tintgreen, tintgreen_back, green: CCFiniteTimeAction;
  tintblue, tintblue_back, blue: CCFiniteTimeAction;
  batch: CCSpriteBatchNode;
begin
  inherited;
  batch := CCSpriteBatchNode._create('Images/grossini_dance_atlas.png', 1);
  addChild(batch, 0, kTagSpriteBatchNode);

  sprite1 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 0, 121 * 1, 85, 121));
  sprite2 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite3 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 2, 121 * 1, 85, 121));
  sprite4 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 3, 121 * 1, 85, 121));
  sprite5 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 0, 121 * 1, 85, 121));
  sprite6 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 1, 121 * 1, 85, 121));
  sprite7 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 2, 121 * 1, 85, 121));
  sprite8 := CCSprite.createWithTexture(batch.getTexture(), CCRectMake(85 * 3, 121 * 1, 85, 121));

  s := CCDirector.sharedDirector().getWinSize();

  sprite1.setPosition(ccp((s.width / 5) * 1, (s.height / 3) * 1));
  sprite2.setPosition(ccp((s.width / 5) * 2, (s.height / 3) * 1));
  sprite3.setPosition(ccp((s.width / 5) * 3, (s.height / 3) * 1));
  sprite4.setPosition(ccp((s.width / 5) * 4, (s.height / 3) * 1));
  sprite5.setPosition(ccp((s.width / 5) * 1, (s.height / 3) * 2));
  sprite6.setPosition(ccp((s.width / 5) * 2, (s.height / 3) * 2));
  sprite7.setPosition(ccp((s.width / 5) * 3, (s.height / 3) * 2));
  sprite8.setPosition(ccp((s.width / 5) * 4, (s.height / 3) * 2));

  action := CCFadeIn._create(2);
  action_back := action.reverse();
  fade := CCRepeatForever._create(CCActionInterval(CCSequence._create([action, action_back])));

  tintred := CCTintBy._create(2, 0, -255, -255);
  tintred_back := tintred.reverse();
  red := CCRepeatForever._create(CCActionInterval(CCSequence._create([tintred, tintred_back])));

  tintgreen := CCTintBy._create(2, -255, 0, -255);
  tintgreen_back := tintgreen.reverse();
  green := CCRepeatForever._create(CCActionInterval(CCSequence._create([tintgreen, tintgreen_back])));

  tintblue := CCTintBy._create(2, -255, -255, 0);
  tintblue_back := tintblue.reverse();
  blue := CCRepeatForever._create(CCActionInterval(CCSequence._create([tintblue, tintblue_back])));

  sprite5.runAction(red);
  sprite6.runAction(green);
  sprite7.runAction(blue);
  sprite8.runAction(fade);

  batch.addChild(sprite1, 0, kTagSprite1);
  batch.addChild(sprite2, 0, kTagSprite2);
  batch.addChild(sprite3, 0, kTagSprite3);
  batch.addChild(sprite4, 0, kTagSprite4);
  batch.addChild(sprite5, 0, kTagSprite5);
  batch.addChild(sprite6, 0, kTagSprite6);
  batch.addChild(sprite7, 0, kTagSprite7);
  batch.addChild(sprite8, 0, kTagSprite8);

  schedule(removeAndAddSprite, 2);
end;

procedure SpriteBatchNodeColorOpacity.removeAndAddSprite(dt: Single);
var
  sprite: CCSprite;
  batch: CCSpriteBatchNode;
begin
  batch := CCSpriteBatchNode(getChildByTag(kTagSpriteBatchNode));
  sprite := CCSprite(batch.getChildByTag(kTagSprite5));
  sprite.retain();
  batch.removeChild(sprite, False);
  batch.addChild(sprite, 0, kTagSprite5);
  sprite.release();
end;

function SpriteBatchNodeColorOpacity.title: string;
begin
  Result := 'SpriteBatchNode: Color & Opacity';
end;

{ SpriteAnimationSplit }

constructor SpriteAnimationSplit.Create;
var
  s: CCSize;
  texture: CCTexture2D;
  frame0, frame1, frame2, frame3, frame4, frame5: CCSpriteFrame;
  sprite: CCSprite;
  animFrames: CCArray;
  animation: CCAnimation;
  animate: CCAnimate;
  seq: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  texture := CCTextureCache.sharedTextureCache.addImage('animations/dragon_animation.png');

  frame0 := CCSpriteFrame.createWithTexture(texture, CCRectMake(132 * 0, 132 * 0, 132, 132));
  frame1 := CCSpriteFrame.createWithTexture(texture, CCRectMake(132 * 1, 132 * 0, 132, 132));
  frame2 := CCSpriteFrame.createWithTexture(texture, CCRectMake(132 * 2, 132 * 0, 132, 132));
  frame3 := CCSpriteFrame.createWithTexture(texture, CCRectMake(132 * 3, 132 * 0, 132, 132));
  frame4 := CCSpriteFrame.createWithTexture(texture, CCRectMake(132 * 0, 132 * 1, 132, 132));
  frame5 := CCSpriteFrame.createWithTexture(texture, CCRectMake(132 * 1, 132 * 1, 132, 132));

  sprite := CCSprite.createWithSpriteFrame(frame0);
  sprite.setPosition(ccp(s.width / 2 - 80, s.height / 2));
  addChild(sprite);

  animFrames := CCArray.createWithCapacity(6);
  animFrames.addObject(frame0);
  animFrames.addObject(frame1);
  animFrames.addObject(frame2);
  animFrames.addObject(frame3);
  animFrames.addObject(frame4);
  animFrames.addObject(frame5);

  animation := CCAnimation.createWithSpriteFrames(animFrames, 0.2);
  animate := CCAnimate._create(animation);
  seq := CCSequence._create([
    animate,
      CCFlipX._create(True),
      CCFiniteTimeAction(animate.copy.autorelease),
      CCFlipX._create(False)]);
  sprite.runAction(CCRepeatForever._create(CCActionInterval(seq)));
end;

procedure SpriteAnimationSplit.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeUnusedSpriteFrames();
end;

function SpriteAnimationSplit.title: string;
begin
  Result := 'Sprite: Animation + flip';
end;

{ SpriteFrameAliasNameTest }

procedure SpriteFrameAliasNameTest.onEnter;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  sprite: CCSprite;
  spriteBatch: CCSpriteBatchNode;
  animFrames: CCArray;
  str: string;
  i: Integer;
  frame: CCSpriteFrame;
  animation: CCAnimation;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.addSpriteFramesWithFile('animations/grossini-aliases.plist', 'animations/grossini-aliases.png');
  sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite.setPosition(ccp(s.width * 0.5, s.height * 0.5));

  spriteBatch := CCSpriteBatchNode._create('animations/grossini-aliases.png');
  spriteBatch.addChild(sprite);
  addChild(spriteBatch);

  animFrames := CCArray.createWithCapacity(15);
  for i := 1 to 15 - 1 do
  begin
    str := Format('dance_%.2d', [i]);
    frame := cache.spriteFrameByName(str);
    animFrames.addObject(frame);
  end;

  animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
  sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
end;

procedure SpriteFrameAliasNameTest.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeSpriteFramesFromFile('animations/grossini-aliases.plist');
end;

function SpriteFrameAliasNameTest.subtitle: string;
begin
  Result := 'SpriteFrames are obtained using the alias name';
end;

function SpriteFrameAliasNameTest.title: string;
begin
  Result := 'SpriteFrame Alias Name';
end;

{ SpriteOffsetAnchorRotation }

constructor SpriteOffsetAnchorRotation.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite: CCSprite;
  point: CCSprite;
  animFrames: CCArray;
  str: string;
  animation: CCAnimation;
  frame: CCSpriteFrame;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');

  for i := 0 to 2 do
  begin
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));

    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition);
    addChild(point, 1);

    case i of
      0: sprite.AnchorPoint := CCPointZero;
      1: sprite.AnchorPoint := ccp(0.5, 0.5);
      2: sprite.AnchorPoint := ccp(1, 1);
    end;

    point.setPosition(sprite.getPosition);

    animFrames := CCArray.createWithCapacity(14);
    for j := 0 to 14 - 1 do
    begin
      str := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(str);
      animFrames.addObject(frame);
    end;

    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    sprite.runAction(CCRepeatForever._create(CCRotateBy._create(10, 360)));

    addChild(sprite, 0);
  end;
end;

procedure SpriteOffsetAnchorRotation.onExit;
var
  cache: CCSpriteFrameCache;
begin
  inherited;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
end;

function SpriteOffsetAnchorRotation.title: string;
begin
  Result := 'Sprite offset + anchor + rot';
end;

{ SpriteBatchNodeOffsetAnchorRotation }

constructor SpriteBatchNodeOffsetAnchorRotation.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite: CCSprite;
  point: CCSprite;
  animFrames: CCArray;
  str: string;
  animation: CCAnimation;
  frame: CCSpriteFrame;
  spritebatch: CCSpriteBatchNode;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');

  spritebatch := CCSpriteBatchNode._create('animations/grossini.png');
  addChild(spritebatch);

  for i := 0 to 2 do
  begin
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));

    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition);
    addChild(point, 200);

    case i of
      0: sprite.AnchorPoint := CCPointZero;
      1: sprite.AnchorPoint := ccp(0.5, 0.5);
      2: sprite.AnchorPoint := ccp(1, 1);
    end;

    point.setPosition(sprite.getPosition);

    animFrames := CCArray.createWithCapacity(14);
    for j := 0 to 14 - 1 do
    begin
      str := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(str);
      animFrames.addObject(frame);
    end;

    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    sprite.runAction(CCRepeatForever._create(CCRotateBy._create(10, 360)));

    spritebatch.addChild(sprite, i);
  end;
end;

procedure SpriteBatchNodeOffsetAnchorRotation.onExit;
var
  cache: CCSpriteFrameCache;
begin
  inherited;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
end;

function SpriteBatchNodeOffsetAnchorRotation.title: string;
begin
  Result := 'SpriteBatchNode offset + anchor + rot';
end;

{ SpriteOffsetAnchorScale }

constructor SpriteOffsetAnchorScale.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite: CCSprite;
  point: CCSprite;
  animFrames: CCArray;
  str: string;
  animation: CCAnimation;
  frame: CCSpriteFrame;
  scale, scale_back, seq: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');

  for i := 0 to 2 do
  begin
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));

    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition);
    addChild(point, 1);

    case i of
      0: sprite.AnchorPoint := CCPointZero;
      1: sprite.AnchorPoint := ccp(0.5, 0.5);
      2: sprite.AnchorPoint := ccp(1, 1);
    end;

    point.setPosition(sprite.getPosition);

    animFrames := CCArray.createWithCapacity(14);
    for j := 0 to 14 - 1 do
    begin
      str := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(str);
      animFrames.addObject(frame);
    end;

    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));

    scale := CCScaleBy._create(2, 2);
    scale_back := scale.reverse();
    seq := CCSequence._create([scale, scale_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq)));

    addChild(sprite, 0);
  end;
end;

procedure SpriteOffsetAnchorScale.onExit;
var
  cache: CCSpriteFrameCache;
begin
  inherited;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
end;

function SpriteOffsetAnchorScale.title: string;
begin
  Result := 'Sprite offset + anchor + scale';
end;

{ SpriteBatchNodeOffsetAnchorScale }

constructor SpriteBatchNodeOffsetAnchorScale.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite: CCSprite;
  point: CCSprite;
  animFrames: CCArray;
  str: string;
  animation: CCAnimation;
  frame: CCSpriteFrame;
  scale, scale_back, seq: CCFiniteTimeAction;
  spritesheet: CCSpriteBatchNode;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');

  spritesheet := CCSpriteBatchNode._create('animations/grossini.png');
  addChild(spritesheet);

  for i := 0 to 2 do
  begin
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));

    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition);
    addChild(point, 200);

    case i of
      0: sprite.AnchorPoint := CCPointZero;
      1: sprite.AnchorPoint := ccp(0.5, 0.5);
      2: sprite.AnchorPoint := ccp(1, 1);
    end;

    point.setPosition(sprite.getPosition);

    animFrames := CCArray.createWithCapacity(14);
    for j := 0 to 14 - 1 do
    begin
      str := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(str);
      animFrames.addObject(frame);
    end;

    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));

    scale := CCScaleBy._create(2, 2);
    scale_back := scale.reverse();
    seq := CCSequence._create([scale, scale_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq)));

    spritesheet.addChild(sprite, i);
  end;
end;

procedure SpriteBatchNodeOffsetAnchorScale.onExit;
var
  cache: CCSpriteFrameCache;
begin
  inherited;
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
end;

function SpriteBatchNodeOffsetAnchorScale.title: string;
begin
  Result := 'SpriteBatchNode offset + anchor + scale';
end;

{ SpriteHybrid }

constructor SpriteHybrid.Create;
var
  s: CCSize;
  parent1: CCNode;
  parent2: CCSpriteBatchNode;
  i: Integer;
  spriteidx: Integer;
  str: string;
  frame: CCSpriteFrame;
  sprite: CCSprite;
  x, y: Single;
  action: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  parent1 := CCNode._create;
  parent2 := CCSpriteBatchNode._create('animations/grossini.png', 50);

  addChild(parent1, 0, kTagNode);
  addChild(parent2, 0, kTagSpriteBatchNode);

  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('animations/grossini.plist');

  Randomize;
  for i := 0 to 250 - 1 do
  begin
    spriteidx := RandomRange(1, 14);
    str := Format('grossini_dance_%.2d.png', [spriteidx]);
    frame := CCSpriteFrameCache.sharedSpriteFrameCache.spriteFrameByName(str);
    sprite := CCSprite.createWithSpriteFrame(frame);
    parent1.addChild(sprite, i, i);

    x := -1000;
    y := -1000;
    if Random < 0.2 then
    begin
      x := Random * s.width;
      y := Random * s.height;
    end;

    sprite.setPosition(ccp(x, y));

    action := CCRotateBy._create(4, 360);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(action)));
  end;
  m_usingSpriteBatchNode := False;
  schedule(reparentSprite, 2);
end;

procedure SpriteHybrid.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeSpriteFramesFromFile('animations/grossini.plist');
end;

procedure SpriteHybrid.reparentSprite(dt: Single);
var
  p1, p2, temp, node: CCNode;
  retArray, children: CCArray;
  i: Integer;
begin
  p1 := getChildByTag(kTagNode);
  p2 := getChildByTag(kTagSpriteBatchNode);

  retArray := CCArray.createWithCapacity(250);

  if m_usingSpriteBatchNode then
  begin
    temp := p1;
    p1 := p2;
    p2 := temp;
  end;

  children := p1.Children;
  if (children <> nil) and (children.count > 0) then
  begin
    for i := 0 to children.count - 1 do
    begin
      node := CCNode(children.objectAtIndex(i));
      if node = nil then
        Break;

      retArray.addObject(node);
    end;
  end;

  p1.removeAllChildrenWithCleanup(False);

  if (retArray <> nil) and (retArray.count > 0) then
  begin
    for i := 0 to retArray.count - 1 do
    begin
      node := CCNode(retArray.objectAtIndex(i));
      if node = nil then
        Break;

      p2.addChild(node, i, i);
    end;
  end;

  m_usingSpriteBatchNode := not m_usingSpriteBatchNode;
end;

function SpriteHybrid.title: string;
begin
  Result := 'HybrCCSprite* sprite Test';
end;

{ SpriteBatchNodeChildren }

constructor SpriteBatchNodeChildren.Create;
var
  s: CCSize;
  batch: CCSpriteBatchNode;
  sprite1, sprite2, sprite3: CCSprite;
  animFrames: CCArray;
  i: Integer;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  action, action_back, action_rot, action_s, action_s_back: CCFiniteTimeAction;
  seq2: CCFiniteTimeAction;
  str: string;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  batch := CCSpriteBatchNode._create('animations/grossini.png', 50);
  addChild(batch, 0, kTagSpriteBatchNode);
  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('animations/grossini.plist');

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(s.width / 3, s.height / 2));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(50, 50));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-50, -50));

  batch.addChild(sprite1);
  sprite1.addChild(sprite2);
  sprite1.addChild(sprite3);

  animFrames := CCArray._Create;
  for i := 1 to 14 do
  begin
    str := Format('grossini_dance_%.2d.png', [i]);
    frame := CCSpriteFrameCache.sharedSpriteFrameCache.spriteFrameByName(str);
    animFrames.addObject(frame);
  end;

  animation := CCAnimation._create(animFrames, 0.2);
  sprite1.runAction(CCRepeatForever._create(CCAnimate._create(animation)));

  action := CCMoveBy._create(2, ccp(200, 0));
  action_back := action.reverse;
  action_rot := CCRotateBy._create(2, 360);
  action_s := CCScaleBy._create(2, 2);
  action_s_back := action_s.reverse;

  seq2 := action_rot.reverse;

  sprite2.runAction(CCRepeatForever._create(CCActionInterval(seq2)));

  sprite1.runAction(CCRepeatForever._create(CCActionInterval(action_rot)));
  sprite1.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([action, action_back]))));
  sprite1.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([action_s, action_s_back]))));
end;

procedure SpriteBatchNodeChildren.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeUnusedSpriteFrames;
end;

function SpriteBatchNodeChildren.title: string;
begin
  Result := 'SpriteBatchNode Grand Children';
end;

{ SpriteBatchNodeChildrenZ }

constructor SpriteBatchNodeChildrenZ.Create;
var
  sprite1, sprite2, sprite3: CCSprite;
  batch: CCSpriteBatchNode;
  s: CCSize;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;

  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('animations/grossini.plist');

  batch := CCSpriteBatchNode._create('animations/grossini.png', 50);
  addChild(batch, 0, kTagSpriteBatchNode);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(s.width / 3, s.height / 2));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-20, 30));

  batch.addChild(sprite1);
  sprite1.addChild(sprite2, 2);
  sprite1.addChild(sprite3, -2);


  batch := CCSpriteBatchNode._create('animations/grossini.png', 50);
  addChild(batch, 0, kTagSpriteBatchNode);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(2 * s.width / 3, s.height / 2));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-20, 30));

  batch.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, 2);


  batch := CCSpriteBatchNode._create('animations/grossini.png', 50);
  addChild(batch, 0, kTagSpriteBatchNode);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(s.width / 2 - 90, s.height / 4));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(s.width / 2 - 60, s.height / 4));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(s.width / 2 - 30, s.height / 4));

  batch.addChild(sprite1, 10);
  batch.addChild(sprite2, -10);
  batch.addChild(sprite3, -5);


  batch := CCSpriteBatchNode._create('animations/grossini.png', 50);
  addChild(batch, 0, kTagSpriteBatchNode);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(s.width / 2 + 30, s.height / 4));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(s.width / 2 + 60, s.height / 4));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(s.width / 2 + 90, s.height / 4));

  batch.addChild(sprite1, -10);
  batch.addChild(sprite2, -5);
  batch.addChild(sprite3, -2);
end;

procedure SpriteBatchNodeChildrenZ.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeUnusedSpriteFrames;
end;

function SpriteBatchNodeChildrenZ.title: string;
begin
  Result := 'SpriteBatchNode Children Z';
end;

{ SpriteChildrenVisibility }

constructor SpriteChildrenVisibility.Create;
var
  sprite1, sprite2, sprite3: CCSprite;
  s: CCSize;
  aParent: CCNode;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;

  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('animations/grossini.plist');

  aParent := CCSpriteBatchNode._create('animations/grossini.png', 50);
  aParent.setPosition(ccp(s.width / 3, s.height / 2));
  addChild(aParent, 0);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(0, 0));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-20, 30));

  aParent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, 2);

  sprite1.runAction(CCBlink._create(5, 10));




  aParent := CCNode._create;
  aParent.setPosition(ccp(2 * s.width / 3, s.height / 2));
  addChild(aParent, 0);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(0, 0));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-20, 30));

  aParent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, 2);

  sprite1.runAction(CCBlink._create(5, 10));
end;

procedure SpriteChildrenVisibility.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeUnusedSpriteFrames;
end;

function SpriteChildrenVisibility.title: string;
begin
  Result := 'Sprite & SpriteBatchNode Visibility';
end;

{ SpriteChildrenVisibilityIssue665 }

constructor SpriteChildrenVisibilityIssue665.Create;
var
  sprite1, sprite2, sprite3: CCSprite;
  s: CCSize;
  aParent: CCNode;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;

  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('animations/grossini.plist');

  aParent := CCSpriteBatchNode._create('animations/grossini.png', 50);
  aParent.setPosition(ccp(s.width / 3, s.height / 2));
  addChild(aParent);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(0, 0));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite3.setPosition(ccp(-20, 30));

  sprite1.Visible := False;

  aParent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, 2);



  aParent := CCNode._create;
  aParent.setPosition(ccp(2 * s.width / 3, s.height / 2));
  addChild(aParent);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
  sprite1.setPosition(ccp(0, 0));

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite3.setPosition(ccp(-20, 30));

  sprite1.Visible := False;

  aParent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, 2);
end;

procedure SpriteChildrenVisibilityIssue665.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeUnusedSpriteFrames;
end;

function SpriteChildrenVisibilityIssue665.subtitle: string;
begin
  Result := 'No sprites should be visible';
end;

function SpriteChildrenVisibilityIssue665.title: string;
begin
  Result := 'Sprite & SpriteBatchNode Visibility';
end;

{ SpriteChildrenAnchorPoint }

constructor SpriteChildrenAnchorPoint.Create;
var
  sprite1, sprite2, sprite3, sprite4, point: CCSprite;
  s: CCSize;
  aParent: CCNode;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;

  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('animations/grossini.plist');

  aParent := CCNode._create;
  addChild(aParent, 0);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_08.png');
  sprite1.setPosition(ccp(s.width / 4, s.height / 2));
  sprite1.AnchorPoint := ccp(0, 0);

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-20, 30));

  sprite4 := CCSprite.createWithSpriteFrameName('grossini_dance_04.png');
  sprite4.setPosition(ccp(0, 0));
  sprite4.Scale := 0.5;

  aParent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, -2);
  sprite1.addChild(sprite4, 3);

  point := CCSprite._create('images/r1.png');
  point.Scale := 0.25;
  point.setPosition(sprite1.getPosition);
  addChild(point, 10);



  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_08.png');
  sprite1.setPosition(ccp(s.width / 2, s.height / 2));
  sprite1.AnchorPoint := ccp(0.5, 0.5);

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-20, 30));

  sprite4 := CCSprite.createWithSpriteFrameName('grossini_dance_04.png');
  sprite4.setPosition(ccp(0, 0));
  sprite4.Scale := 0.5;

  aParent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, -2);
  sprite1.addChild(sprite4, 3);

  point := CCSprite._create('images/r1.png');
  point.Scale := 0.25;
  point.setPosition(sprite1.getPosition);
  addChild(point, 10);





  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_08.png');
  sprite1.setPosition(ccp(s.width / 4 + s.width / 2, s.height / 2));
  sprite1.AnchorPoint := ccp(1, 1);

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(ccp(20, 30));

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(ccp(-20, 30));

  sprite4 := CCSprite.createWithSpriteFrameName('grossini_dance_04.png');
  sprite4.setPosition(ccp(0, 0));
  sprite4.Scale := 0.5;

  aParent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, -2);
  sprite1.addChild(sprite4, 3);

  point := CCSprite._create('images/r1.png');
  point.Scale := 0.25;
  point.setPosition(sprite1.getPosition);
  addChild(point, 10);
end;

procedure SpriteChildrenAnchorPoint.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeUnusedSpriteFrames;
end;

function SpriteChildrenAnchorPoint.title: string;
begin
  Result := 'Sprite: children + anchor';
end;

{ SpriteBatchNodeChildrenAnchorPoint }

constructor SpriteBatchNodeChildrenAnchorPoint.Create;
var
  s: CCSize;
  sprite1, sprite2, sprite3, sprite4, point: CCSprite;
  aparent: CCNode;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile('animations/grossini.plist');

  aparent := CCSpriteBatchNode._create('animations/grossini.png', 50);
  addChild(aparent, 0);

  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_08.png');
  sprite1.setPosition(s.width / 4, s.height / 2);
  sprite1.AnchorPoint := CCPointZero;

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(20, 30);

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(-20, 30);

  sprite4 := CCSprite.createWithSpriteFrameName('grossini_dance_04.png');
  sprite4.setPosition(0, 0);
  sprite4.Scale := 0.5;

  aparent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, -2);
  sprite1.addChild(sprite4, 3);

  point := CCSprite._create('Images/r1.png');
  point.Scale := 0.25;
  point.setPosition(sprite1.getPosition);
  addChild(point, 10);




  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_08.png');
  sprite1.setPosition(s.width / 2, s.height / 2);
  sprite1.AnchorPoint := ccp(0.5, 0.5);

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(20, 30);

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(-20, 30);

  sprite4 := CCSprite.createWithSpriteFrameName('grossini_dance_04.png');
  sprite4.setPosition(0, 0);
  sprite4.Scale := 0.5;

  aparent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, -2);
  sprite1.addChild(sprite4, 3);

  point := CCSprite._create('Images/r1.png');
  point.Scale := 0.25;
  point.setPosition(sprite1.getPosition);
  addChild(point, 10);



  sprite1 := CCSprite.createWithSpriteFrameName('grossini_dance_08.png');
  sprite1.setPosition(s.width / 2 + s.width / 4, s.height / 2);
  sprite1.AnchorPoint := ccp(1, 1);

  sprite2 := CCSprite.createWithSpriteFrameName('grossini_dance_02.png');
  sprite2.setPosition(20, 30);

  sprite3 := CCSprite.createWithSpriteFrameName('grossini_dance_03.png');
  sprite3.setPosition(-20, 30);

  sprite4 := CCSprite.createWithSpriteFrameName('grossini_dance_04.png');
  sprite4.setPosition(0, 0);
  sprite4.Scale := 0.5;

  aparent.addChild(sprite1);
  sprite1.addChild(sprite2, -2);
  sprite1.addChild(sprite3, -2);
  sprite1.addChild(sprite4, 3);

  point := CCSprite._create('Images/r1.png');
  point.Scale := 0.25;
  point.setPosition(sprite1.getPosition);
  addChild(point, 10);
end;

procedure SpriteBatchNodeChildrenAnchorPoint.onExit;
begin
  inherited;
  CCSpriteFrameCache.sharedSpriteFrameCache.removeUnusedSpriteFrames;
end;

function SpriteBatchNodeChildrenAnchorPoint.title: string;
begin
  Result := 'SpriteBatchNode: children + anchor';
end;

{ SpriteBatchNodeChildrenScale }

constructor SpriteBatchNodeChildrenScale.Create;
var
  s: CCSize;
  aparent: CCNode;
  sprite1, sprite2: CCSprite;
  rot: CCActionInterval;
  seq: CCAction;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('animations/grossini_family.plist');

  rot := CCRotateBy._create(10, 360);
  seq := CCRepeatForever._create(rot);

  aparent := CCNode._create;
  sprite1 := CCSprite.createWithSpriteFrameName('grossinis_sister1.png');
  sprite1.setPosition(s.width / 4, s.height / 4);
  sprite1.setScaleX(-0.5);
  sprite1.setScaleY(2);
  sprite1.runAction(seq);

  sprite2 := CCSprite.createWithSpriteFrameName('grossinis_sister2.png');
  sprite2.setPosition(50, 0);

  addChild(aparent);
  aparent.addChild(sprite1);
  sprite1.addChild(sprite2);



  aparent := CCSpriteBatchNode._create('animations/grossini_family.png');
  sprite1 := CCSprite.createWithSpriteFrameName('grossinis_sister1.png');
  sprite1.setPosition(3 * s.width / 4, s.height / 4);
  sprite1.setScaleX(-0.5);
  sprite1.setScaleY(2);
  sprite1.runAction(CCAction(seq.copy.autorelease));

  sprite2 := CCSprite.createWithSpriteFrameName('grossinis_sister2.png');
  sprite2.setPosition(50, 0);

  addChild(aparent);
  aparent.addChild(sprite1);
  sprite1.addChild(sprite2);



  aparent := CCNode._create;
  sprite1 := CCSprite.createWithSpriteFrameName('grossinis_sister1.png');
  sprite1.setPosition(s.width / 4, 2 * s.height / 3);
  sprite1.setScaleX(1.5);
  sprite1.setScaleY(-0.5);
  sprite1.runAction(CCAction(seq.copy.autorelease));

  sprite2 := CCSprite.createWithSpriteFrameName('grossinis_sister2.png');
  sprite2.setPosition(50, 0);

  addChild(aparent);
  aparent.addChild(sprite1);
  sprite1.addChild(sprite2);




  aparent := CCSpriteBatchNode._create('animations/grossini_family.png');
  sprite1 := CCSprite.createWithSpriteFrameName('grossinis_sister1.png');
  sprite1.setPosition(3 * s.width / 4, 2 * s.height / 3);
  sprite1.setScaleX(1.5);
  sprite1.setScaleY(-0.5);
  sprite1.runAction(CCAction(seq.copy.autorelease));

  sprite2 := CCSprite.createWithSpriteFrameName('grossinis_sister2.png');
  sprite2.setPosition(50, 0);

  addChild(aparent);
  aparent.addChild(sprite1);
  sprite1.addChild(sprite2);
end;

function SpriteBatchNodeChildrenScale.title: string;
begin
  Result := 'Sprite/BatchNode + child + scale + rot';
end;

{ SpriteChildrenChildren }

constructor SpriteChildrenChildren.Create;
var
  s, l1size, l2asize, l2bsize: CCSize;
  aparent: CCNode;
  l1, l2a, l2b, l3a1, l3a2, l3b1, l3b2: CCSprite;
  rot: CCActionInterval;
  seq: CCAction;
  rot_back: CCFiniteTimeAction;
  rot_back_fe: CCAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile('animations/ghosts.plist');
  rot := CCRotateBy._create(10, 360);
  seq := CCRepeatForever._create(rot);
  rot_back := rot.reverse();
  rot_back_fe := CCRepeatForever._create(CCActionInterval(rot_back));
    //
    // SpriteBatchNode: 3 levels of children
    //

  aParent := CCNode._create();
  addChild(aParent);
    // parent
  l1 := CCSprite.createWithSpriteFrameName('father.gif');
  l1.setPosition(ccp(s.width / 2, s.height / 2));
  l1.runAction(CCAction(seq.copy().autorelease()));
  aParent.addChild(l1);
  l1Size := l1.ContentSize;

    // child left
  l2a := CCSprite.createWithSpriteFrameName('sister1.gif');
  l2a.setPosition(ccp(-50 + l1Size.width / 2, 0 + l1Size.height / 2));
  l2a.runAction(CCAction(rot_back_fe.copy().autorelease()));
  l1.addChild(l2a);
  l2aSize := l2a.ContentSize;

    // child right
  l2b := CCSprite.createWithSpriteFrameName('sister2.gif');
  l2b.setPosition(ccp(+50 + l1Size.width / 2, 0 + l1Size.height / 2));
  l2b.runAction(CCAction(rot_back_fe.copy().autorelease()));
  l1.addChild(l2b);
  l2bSize := l2a.ContentSize;


    // child left bottom
  l3a1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a1.Scale := (0.45);
  l3a1.setPosition(ccp(0 + l2aSize.width / 2, -100 + l2aSize.height / 2));
  l2a.addChild(l3a1);

    // child left top
  l3a2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a2.Scale := (0.45);
  l3a1.setPosition(ccp(0 + l2aSize.width / 2, +100 + l2aSize.height / 2));
  l2a.addChild(l3a2);

    // child right bottom
  l3b1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b1.Scale := (0.45);
  l3b1.setFlipY(true);
  l3b1.setPosition(ccp(0 + l2bSize.width / 2, -100 + l2bSize.height / 2));
  l2b.addChild(l3b1);

    // child right top
  l3b2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b2.Scale := (0.45);
  l3b2.setFlipY(true);
  l3b1.setPosition(ccp(0 + l2bSize.width / 2, +100 + l2bSize.height / 2));
  l2b.addChild(l3b2);
end;

function SpriteChildrenChildren.title: string;
begin
  Result := 'Sprite multiple levels of children';
end;

{ SpriteBatchNodeChildrenChildren }

constructor SpriteBatchNodeChildrenChildren.Create;
var
  s, l1size, l2asize, l2bsize: CCSize;
  aparent: CCSpriteBatchNode;
  l1, l2a, l2b, l3a1, l3a2, l3b1, l3b2: CCSprite;
  rot: CCActionInterval;
  seq: CCAction;
  rot_back: CCFiniteTimeAction;
  rot_back_fe: CCAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile('animations/ghosts.plist');
  rot := CCRotateBy._create(10, 360);
  seq := CCRepeatForever._create(rot);

  rot_back := rot.reverse();
  rot_back_fe := CCRepeatForever._create(CCActionInterval(rot_back));

    //
    // SpriteBatchNode: 3 levels of children
    //

  aParent := CCSpriteBatchNode._create('animations/ghosts.png');
  aParent.getTexture().generateMipmap();
  addChild(aParent);

    // parent
  l1 := CCSprite.createWithSpriteFrameName('father.gif');
  l1.setPosition(ccp(s.width / 2, s.height / 2));
  l1.runAction(CCAction(seq.copy().autorelease()));
  aParent.addChild(l1);
  l1Size := l1.ContentSize;
    // child left
  l2a := CCSprite.createWithSpriteFrameName('sister1.gif');
  l2a.setPosition(ccp(-50 + l1Size.width / 2, 0 + l1Size.height / 2));
  l2a.runAction(CCAction(rot_back_fe.copy().autorelease()));
  l1.addChild(l2a);
  l2aSize := l2a.ContentSize;

    // child right
  l2b := CCSprite.createWithSpriteFrameName('sister2.gif');
  l2b.setPosition(ccp(+50 + l1Size.width / 2, 0 + l1Size.height / 2));
  l2b.runAction(CCAction(rot_back_fe.copy().autorelease()));
  l1.addChild(l2b);
  l2bSize := l2a.ContentSize;

    // child left bottom
  l3a1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a1.setScale(0.45);
  l3a1.setPosition(ccp(0 + l2aSize.width / 2, -100 + l2aSize.height / 2));
  l2a.addChild(l3a1);

    // child left top
  l3a2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a2.setScale(0.45);
  l3a1.setPosition(ccp(0 + l2aSize.width / 2, +100 + l2aSize.height / 2));
  l2a.addChild(l3a2);

    // child right bottom
  l3b1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b1.setScale(0.45);
  l3b1.setFlipY(true);
  l3b1.setPosition(ccp(0 + l2bSize.width / 2, -100 + l2bSize.height / 2));
  l2b.addChild(l3b1);
    // child right top
  l3b2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b2.setScale(0.45);
  l3b2.setFlipY(true);
  l3b1.setPosition(ccp(0 + l2bSize.width / 2, +100 + l2bSize.height / 2));
  l2b.addChild(l3b2);
end;

function SpriteBatchNodeChildrenChildren.title: string;
begin
  Result := 'SpriteBatchNode multiple levels of children';
end;

{ SpriteSubclass }
type
  MySprite2 = class(CCSprite)
  public
    ivar: Integer;
    constructor Create();
    class function _create(pszname: string): MySprite2;
  end;

  MySprite1 = class(CCSprite)
  public
    ivar: Integer;
    constructor Create();
    class function createWithSpriteFrameName(const pszName: string): MySprite1;
  end;

constructor SpriteSubclass.Create;
var
  sprite, sprite2: CCSprite;
  s: CCSize;
  aparent: CCSpriteBatchNode;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile('animations/ghosts.plist');
  aParent := CCSpriteBatchNode._create('animations/ghosts.png');
    // MySprite1
  sprite := MySprite1.createWithSpriteFrameName('father.gif');
  sprite.setPosition(ccp(s.width / 4 * 1, s.height / 2));
  aParent.addChild(sprite);
  addChild(aParent);
    // MySprite2
  sprite2 := MySprite2._create('Images/grossini.png');
  addChild(sprite2);
  sprite2.setPosition(ccp(s.width / 4 * 3, s.height / 2));
end;

function SpriteSubclass.subtitle: string;
begin
  Result := 'Testing initWithTexture:rect method';
end;

function SpriteSubclass.title: string;
begin
  Result := 'Sprite subclass';
end;

{ MySprite2 }

class function MySprite2._create(pszname: string): MySprite2;
var
  pret: MySprite2;
begin
  pret := MySprite2.Create;
  pret.initWithFile(pszname);
  pret.autorelease;
  Result := pret;
end;

constructor MySprite2.Create;
begin
  inherited;
  ivar := 10;
end;

{ MySprite1 }

constructor MySprite1.Create;
begin
  inherited;
  ivar := 10;
end;

class function MySprite1.createWithSpriteFrameName(
  const pszName: string): MySprite1;
var
  pret: MySprite1;
begin
  pret := MySprite1.Create;
  pret.initWithSpriteFrame(CCSpriteFrameCache.sharedSpriteFrameCache.spriteFrameByName(pszName));
  pret.autorelease;
  Result := pret;
end;

{ AnimationCache }

constructor AnimationCache.Create;
var
  frameCache: CCSpriteFrameCache;
  animFrames: CCArray;
  str: string;
  i: Integer;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  animCache: CCAnimationCache;
  normal, dance_grey, dance_blue: CCAnimation;
  animN, animG, animB: CCAnimate;
  seq: CCFiniteTimeAction;
  winSize: CCSize;
  grossini: CCSprite;
begin
  inherited;

  frameCache := CCSpriteFrameCache.sharedSpriteFrameCache();
  frameCache.addSpriteFramesWithFile('animations/grossini.plist');
  frameCache.addSpriteFramesWithFile('animations/grossini_gray.plist');
  frameCache.addSpriteFramesWithFile('animations/grossini_blue.plist');
    //
    // create animation "dance"
    //
  animFrames := CCArray.createWithCapacity(15);
  for i := 1 to 14 do
  begin
    str := Format('grossini_dance_%.2d.png', [i]);
    frame := frameCache.spriteFrameByName(str);
    animFrames.addObject(frame);
  end;

  animation := CCAnimation.createWithSpriteFrames(animFrames, 0.2);
    // Add an animation to the Cache
  CCAnimationCache.sharedAnimationCache().addAnimation(animation, 'dance');
    //
    // create animation "dance gray"
    //
  animFrames.removeAllObjects();
  for i := 1 to 14 do
  begin
    str := Format('grossini_dance_gray_%.2d.png', [i]);
    frame := frameCache.spriteFrameByName(str);
    animFrames.addObject(frame);
  end;

  animation := CCAnimation.createWithSpriteFrames(animFrames, 0.2);
    // Add an animation to the Cache
  CCAnimationCache.sharedAnimationCache().addAnimation(animation, 'dance_gray');
    //
    // create animation "dance blue"
    //
  animFrames.removeAllObjects();
  for i := 1 to 3 do
  begin
    str := Format('grossini_blue_%.2d.png', [i]);
    frame := frameCache.spriteFrameByName(str);
    animFrames.addObject(frame);
  end;

  animation := CCAnimation.createWithSpriteFrames(animFrames, 0.2);
    // Add an animation to the Cache
  CCAnimationCache.sharedAnimationCache().addAnimation(animation, 'dance_blue');

  animCache := CCAnimationCache.sharedAnimationCache();
  normal := animCache.animationByName('dance');
  normal.RestoreOriginalFrame := true;
  dance_grey := animCache.animationByName('dance_gray');
  dance_grey.RestoreOriginalFrame := true;
  dance_blue := animCache.animationByName('dance_blue');
  dance_blue.RestoreOriginalFrame := true;
  animN := CCAnimate._create(normal);
  animG := CCAnimate._create(dance_grey);
  animB := CCAnimate._create(dance_blue);
  seq := CCSequence._create([animN, animG, animB]);
    // create an sprite without texture
  grossini := CCSprite._create();
  frame := frameCache.spriteFrameByName('grossini_dance_01.png');
  grossini.setDisplayFrame(frame);
  winSize := CCDirector.sharedDirector().getWinSize();
  grossini.setPosition(ccp(winSize.width / 2, winSize.height / 2));
  addChild(grossini);
    // run the animation
  grossini.runAction(seq);
end;

function AnimationCache.subtitle: string;
begin
  Result := 'Sprite should be animated';
end;

function AnimationCache.title: string;
begin
  Result := 'AnimationCache';
end;

{ SpriteOffsetAnchorSkew }

constructor SpriteOffsetAnchorSkew.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite, point: CCSprite;
  animFrames: CCArray;
  tmp: string;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  skewX, skewY: CCSkewBy;
  skewX_back, skewY_back, seq_skew: CCFiniteTimeAction;
begin
  inherited;


  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  for i := 0 to 2 do
  begin
        //
        // Animation using Sprite batch
        //
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition());
    addChild(point, 1);
    case i of
      0:
        sprite.AnchorPoint := CCPointZero;
      1:
        sprite.AnchorPoint := ccp(0.5, 0.5);
      2:
        sprite.AnchorPoint := ccp(1, 1);
    end;
    point.setPosition(sprite.getPosition());
    animFrames := CCArray._create();
    for j := 0 to 13 do
    begin
      tmp := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(tmp);
      animFrames.addObject(frame);
    end;
    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    skewX := CCSkewBy._create(2, 45, 0);
    skewX_back := skewX.reverse();
    skewY := CCSkewBy._create(2, 0, 45);
    skewY_back := skewY.reverse();
    seq_skew := CCSequence._create([skewX, skewX_back, skewY, skewY_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_skew)));
    addChild(sprite, 0);
  end;
end;

destructor SpriteOffsetAnchorSkew.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteOffsetAnchorSkew.title: string;
begin
  Result := 'Sprite offset + anchor + scale';
end;

{ SpriteBatchNodeOffsetAnchorSkew }

constructor SpriteBatchNodeOffsetAnchorSkew.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite, point: CCSprite;
  animFrames: CCArray;
  tmp: string;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  skewX, skewY: CCSkewBy;
  skewX_back, skewY_back, seq_skew: CCFiniteTimeAction;
  spritebatch: CCSpriteBatchNode;
begin
  inherited;


  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  spritebatch := CCSpriteBatchNode._create('animations/grossini.png');
  addChild(spritebatch);
  for i := 0 to 2 do
  begin
        //
        // Animation using Sprite batch
        //
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition());
    addChild(point, 1);
    case i of
      0:
        sprite.AnchorPoint := CCPointZero;
      1:
        sprite.AnchorPoint := ccp(0.5, 0.5);
      2:
        sprite.AnchorPoint := ccp(1, 1);
    end;
    point.setPosition(sprite.getPosition());
    animFrames := CCArray._create();
    for j := 0 to 13 do
    begin
      tmp := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(tmp);
      animFrames.addObject(frame);
    end;
    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    skewX := CCSkewBy._create(2, 45, 0);
    skewX_back := skewX.reverse();
    skewY := CCSkewBy._create(2, 0, 45);
    skewY_back := skewY.reverse();
    seq_skew := CCSequence._create([skewX, skewX_back, skewY, skewY_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_skew)));
    spritebatch.addChild(sprite, 0);
  end;
end;

destructor SpriteBatchNodeOffsetAnchorSkew.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteBatchNodeOffsetAnchorSkew.title: string;
begin
  Result := 'SpriteBatchNode offset + anchor + skew';
end;

{ SpriteOffsetAnchorSkewScale }

constructor SpriteOffsetAnchorSkewScale.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite, point: CCSprite;
  animFrames: CCArray;
  tmp: string;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  skewX, skewY: CCSkewBy;
  skewX_back, skewY_back, seq_skew: CCFiniteTimeAction;
  scale, scale_back, seq_scale: CCFiniteTimeAction;
begin
  inherited;


  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  for i := 0 to 2 do
  begin
        //
        // Animation using Sprite batch
        //
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition());
    addChild(point, 1);
    case i of
      0:
        sprite.AnchorPoint := CCPointZero;
      1:
        sprite.AnchorPoint := ccp(0.5, 0.5);
      2:
        sprite.AnchorPoint := ccp(1, 1);
    end;
    point.setPosition(sprite.getPosition());
    animFrames := CCArray._create();
    for j := 0 to 13 do
    begin
      tmp := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(tmp);
      animFrames.addObject(frame);
    end;
    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    skewX := CCSkewBy._create(2, 45, 0);
    skewX_back := skewX.reverse();
    skewY := CCSkewBy._create(2, 0, 45);
    skewY_back := skewY.reverse();
    seq_skew := CCSequence._create([skewX, skewX_back, skewY, skewY_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_skew)));
    scale := CCScaleBy._create(2, 2);
    scale_back := scale.reverse;
    seq_scale := CCSequence._create([scale, scale_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_scale)));
    addChild(sprite, 0);
  end;
end;

destructor SpriteOffsetAnchorSkewScale.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteOffsetAnchorSkewScale.title: string;
begin
  Result := 'Sprite anchor + skew + scale';
end;

{ SpriteBatchNodeOffsetAnchorSkewScale }

constructor SpriteBatchNodeOffsetAnchorSkewScale.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite, point: CCSprite;
  animFrames: CCArray;
  tmp: string;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  skewX, skewY: CCSkewBy;
  skewX_back, skewY_back, seq_skew: CCFiniteTimeAction;
  scale, scale_back, seq_scale: CCFiniteTimeAction;
  spritebatch: CCSpriteBatchNode;
begin
  inherited;


  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  spritebatch := CCSpriteBatchNode._create('animations/grossini.png');
  addChild(spritebatch);
  for i := 0 to 2 do
  begin
        //
        // Animation using Sprite batch
        //
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition());
    addChild(point, 1);
    case i of
      0:
        sprite.AnchorPoint := CCPointZero;
      1:
        sprite.AnchorPoint := ccp(0.5, 0.5);
      2:
        sprite.AnchorPoint := ccp(1, 1);
    end;
    point.setPosition(sprite.getPosition());
    animFrames := CCArray._create();
    for j := 0 to 13 do
    begin
      tmp := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(tmp);
      animFrames.addObject(frame);
    end;
    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    skewX := CCSkewBy._create(2, 45, 0);
    skewX_back := skewX.reverse();
    skewY := CCSkewBy._create(2, 0, 45);
    skewY_back := skewY.reverse();
    seq_skew := CCSequence._create([skewX, skewX_back, skewY, skewY_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_skew)));
    scale := CCScaleBy._create(2, 2);
    scale_back := scale.reverse;
    seq_scale := CCSequence._create([scale, scale_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_scale)));
    spritebatch.addChild(sprite, 0);
  end;
end;

destructor SpriteBatchNodeOffsetAnchorSkewScale.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteBatchNodeOffsetAnchorSkewScale.title: string;
begin
  Result := 'SpriteBatchNode anchor + skew + scale';
end;

{ SpriteOffsetAnchorFlip }

constructor SpriteOffsetAnchorFlip.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite, point: CCSprite;
  animFrames: CCArray;
  tmp: string;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  flip, flip_back: CCFiniteTimeAction;
  delay: CCDelayTime;
  seq: CCFiniteTimeAction;
begin
  inherited;


  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  for i := 0 to 2 do
  begin
        //
        // Animation using Sprite batch
        //
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition());
    addChild(point, 1);
    case i of
      0:
        sprite.AnchorPoint := CCPointZero;
      1:
        sprite.AnchorPoint := ccp(0.5, 0.5);
      2:
        sprite.AnchorPoint := ccp(1, 1);
    end;
    point.setPosition(sprite.getPosition());
    animFrames := CCArray._create();
    for j := 0 to 13 do
    begin
      tmp := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(tmp);
      animFrames.addObject(frame);
    end;
    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    flip := CCFlipY._create(True);
    flip_back := CCFlipY._create(False);
    delay := CCDelayTime._create(1);
    seq := CCSequence._create([delay, flip, CCFiniteTimeAction(delay.copy.autorelease), flip_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq)));
    addChild(sprite, 0);
  end;
end;

destructor SpriteOffsetAnchorFlip.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteOffsetAnchorFlip.subtitle: string;
begin
  Result := 'issue #1078';
end;

function SpriteOffsetAnchorFlip.title: string;
begin
  Result := 'Sprite offset + anchor + flip';
end;

{ SpriteBatchNodeOffsetAnchorFlip }

constructor SpriteBatchNodeOffsetAnchorFlip.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i, j: Integer;
  sprite, point: CCSprite;
  animFrames: CCArray;
  tmp: string;
  frame: CCSpriteFrame;
  animation: CCAnimation;
  flip, flip_back: CCFiniteTimeAction;
  delay: CCDelayTime;
  seq: CCFiniteTimeAction;
  spritebatch: CCSpriteBatchNode;
begin
  inherited;


  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  spritebatch := CCSpriteBatchNode._create('animations/grossini.png');
  addChild(spritebatch);
  for i := 0 to 2 do
  begin
        //
        // Animation using Sprite batch
        //
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
    point := CCSprite._create('Images/r1.png');
    point.Scale := 0.25;
    point.setPosition(sprite.getPosition());
    addChild(point, 200);
    case i of
      0:
        sprite.AnchorPoint := CCPointZero;
      1:
        sprite.AnchorPoint := ccp(0.5, 0.5);
      2:
        sprite.AnchorPoint := ccp(1, 1);
    end;
    point.setPosition(sprite.getPosition());
    animFrames := CCArray._Create;
    for j := 0 to 13 do
    begin
      tmp := Format('grossini_dance_%.2d.png', [j + 1]);
      frame := cache.spriteFrameByName(tmp);
      animFrames.addObject(frame);
    end;
    animation := CCAnimation.createWithSpriteFrames(animFrames, 0.3);
    sprite.runAction(CCRepeatForever._create(CCAnimate._create(animation)));
    flip := CCFlipY._create(True);
    flip_back := CCFlipY._create(False);
    delay := CCDelayTime._create(1);
    seq := CCSequence._create([delay, flip, CCFiniteTimeAction(delay.copy.autorelease), flip_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq)));
    spritebatch.addChild(sprite, i);
  end;
end;

destructor SpriteBatchNodeOffsetAnchorFlip.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteBatchNodeOffsetAnchorFlip.subtitle: string;
begin
  Result := 'issue #1078';
end;

function SpriteBatchNodeOffsetAnchorFlip.title: string;
begin
  Result := 'SpriteBatchNode Sprite offset + anchor + flip';
end;

{ SpriteBatchNodeReorderOneChild }

constructor SpriteBatchNodeReorderOneChild.Create;
var
  s, l1Size, l2aSize, l2bSize: CCSize;
  aparent: CCSpriteBatchNode;
  l1, l2a, l2b, l3a1, l3a2, l3b1, l3b2: CCSprite;
begin
  inherited;

  s := CCDirector.sharedDirector().getWinSize();

  CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile('animations/ghosts.plist');

    //
    // SpriteBatchNode: 3 levels of children
    //
  aParent := CCSpriteBatchNode._create('animations/ghosts.png');
  m_pBatchNode := aParent;
    //[[aParent texture] generateMipmap];
  addChild(aParent);
    // parent
  l1 := CCSprite.createWithSpriteFrameName('father.gif');
  l1.setPosition(ccp(s.width / 2, s.height / 2));
  aParent.addChild(l1);
  l1Size := l1.ContentSize;
    // child left
  l2a := CCSprite.createWithSpriteFrameName('sister1.gif');
  l2a.setPosition(ccp(-10 + l1Size.width / 2, 0 + l1Size.height / 2));
  l1.addChild(l2a, 1);
  l2aSize := l2a.ContentSize;

    // child right
  l2b := CCSprite.createWithSpriteFrameName('sister2.gif');
  l2b.setPosition(ccp(+50 + l1Size.width / 2, 0 + l1Size.height / 2));
  l1.addChild(l2b, 2);
  l2bSize := l2a.ContentSize;

    // child left bottom
  l3a1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a1.scale := 0.45;
  l3a1.setPosition(ccp(0 + l2aSize.width / 2, -50 + l2aSize.height / 2));
  l2a.addChild(l3a1, 1);
    // child left top
  l3a2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3a2.scale := 0.45;
  l3a2.setPosition(ccp(0 + l2aSize.width / 2, +50 + l2aSize.height / 2));
  l2a.addChild(l3a2, 2);
  m_pReorderSprite := l2a;
    // child right bottom
  l3b1 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b1.scale := 0.45;
  l3b1.setFlipY(true);
  l3b1.setPosition(ccp(0 + l2bSize.width / 2, -50 + l2bSize.height / 2));
  l2b.addChild(l3b1);
    // child right top
  l3b2 := CCSprite.createWithSpriteFrameName('child1.gif');
  l3b2.scale := 0.45;
  l3b2.setFlipY(true);
  l3b2.setPosition(ccp(0 + l2bSize.width / 2, +50 + l2bSize.height / 2));
  l2b.addChild(l3b2);

  scheduleOnce(reordersprite, 2);
end;

procedure SpriteBatchNodeReorderOneChild.reordersprite(dt: Single);
begin
  m_pReorderSprite.Parent.reorderChild(m_pReorderSprite, -1);
  m_pBatchNode.sortAllChildren;
end;

function SpriteBatchNodeReorderOneChild.title: string;
begin
  Result := 'SpriteBatchNode reorder 1 child';
end;

{ SpriteSkewNegativeScaleChildren }

constructor SpriteSkewNegativeScaleChildren.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  parent: CCNode;
  i: Integer;
  sprite: CCSprite;
  skewX, skewX_back, skewY, skewY_back: CCFiniteTimeAction;
  seq_skew: CCFiniteTimeAction;
  child1: CCSprite;
begin
  inherited;

  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  parent := CCNode._create();
  addChild(parent);
  for i := 0 to 1 do
  begin
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
        // Skew
    skewX := CCSkewBy._create(2, 45, 0);
    skewX_back := skewX.reverse();
    skewY := CCSkewBy._create(2, 0, 45);
    skewY_back := skewY.reverse();
    if i = 1 then
      sprite.setScale(-1.0);

    seq_skew := CCSequence._create([skewX, skewX_back, skewY, skewY_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_skew)));
    child1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    child1.setPosition(ccp(sprite.ContentSize.width / 2.0, sprite.ContentSize.height / 2.0));
    sprite.addChild(child1);
    child1.Scale := 0.8;
    parent.addChild(sprite, i);
  end;
end;

destructor SpriteSkewNegativeScaleChildren.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteSkewNegativeScaleChildren.subtitle: string;
begin
  Result := 'Sprite skew + negative scale with children';
end;

function SpriteSkewNegativeScaleChildren.title: string;
begin
  Result := 'Sprite + children + skew';
end;

{ SpriteBatchNodeSkewNegativeScaleChildren }

constructor SpriteBatchNodeSkewNegativeScaleChildren.Create;
var
  s: CCSize;
  cache: CCSpriteFrameCache;
  i: Integer;
  sprite: CCSprite;
  skewX, skewX_back, skewY, skewY_back: CCFiniteTimeAction;
  seq_skew: CCFiniteTimeAction;
  child1: CCSprite;
  spritebatch: CCSpriteBatchNode;
begin
  inherited;

  s := CCDirector.sharedDirector().getWinSize();

  cache := CCSpriteFrameCache.sharedSpriteFrameCache();
  cache.addSpriteFramesWithFile('animations/grossini.plist');
  cache.addSpriteFramesWithFile('animations/grossini_gray.plist', 'animations/grossini_gray.png');
  spritebatch := CCSpriteBatchNode._create('animations/grossini.png');
  addChild(spritebatch);
  for i := 0 to 1 do
  begin
    sprite := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    sprite.setPosition(ccp(s.width / 4 * (i + 1), s.height / 2));
        // Skew
    skewX := CCSkewBy._create(2, 45, 0);
    skewX_back := skewX.reverse();
    skewY := CCSkewBy._create(2, 0, 45);
    skewY_back := skewY.reverse();
    if i = 1 then
      sprite.setScale(-1.0);

    seq_skew := CCSequence._create([skewX, skewX_back, skewY, skewY_back]);
    sprite.runAction(CCRepeatForever._create(CCActionInterval(seq_skew)));
    child1 := CCSprite.createWithSpriteFrameName('grossini_dance_01.png');
    child1.setPosition(ccp(sprite.ContentSize.width / 2.0, sprite.ContentSize.height / 2.0));
    child1.setScale(0.8);
    sprite.addChild(child1);
    spritebatch.addChild(sprite, i);
  end;
end;

destructor SpriteBatchNodeSkewNegativeScaleChildren.Destroy;
var
  cache: CCSpriteFrameCache;
begin
  cache := CCSpriteFrameCache.sharedSpriteFrameCache;
  cache.removeSpriteFramesFromFile('animations/grossini.plist');
  cache.removeSpriteFramesFromFile('animations/grossini_gray.plist');
  inherited;
end;

function SpriteBatchNodeSkewNegativeScaleChildren.subtitle: string;
begin
  Result := 'SpriteBatchNode skew + negative scale with children';
end;

function SpriteBatchNodeSkewNegativeScaleChildren.title: string;
begin
  Result := 'SpriteBatchNode + children + skew';
end;

{ SpriteDoubleResolution }
type
  DoubleSprite = class(CCSprite)
  public
    m_bHD: Boolean;
    class function _create(const pszFilename: string): DoubleSprite;
    function initWithTexture(pTexture: CCTexture2D; const rect: CCRect): Boolean; override;
    procedure setVertexRect(const rect: CCRect); override;
    procedure setContentSize(const Value: CCSize); override;
  end;

constructor SpriteDoubleResolution.Create;
var
  s: CCSize;
  spriteSD: DoubleSprite;
  child1_left, child1_right, child2_left, child2_right, spriteHD: CCSprite;
  scale: CCScaleBy;
  scale_back, seq, seq_copy: CCFiniteTimeAction;
begin
  inherited;

  s := CCDirector.sharedDirector().getWinSize();

    //
    // LEFT: SD sprite
    //
    // there is no HD resolution file of grossini_dance_08.
  spriteSD := DoubleSprite._create('Images/grossini_dance_08.png');
  addChild(spriteSD);
  spriteSD.setPosition(ccp(s.width / 4 * 1, s.height / 2));
  child1_left := DoubleSprite._create('Images/grossini_dance_08.png');
  spriteSD.addChild(child1_left);
  child1_left.setPosition(ccp(-30, 0));
  child1_right := CCSprite._create('Images/grossini.png');
  spriteSD.addChild(child1_right);
  child1_left.setPosition(ccp(spriteSD.getContentSize().height, 0));

    //
    // RIGHT: HD sprite
    //
    // there is an HD version of grossini.png
  spriteHD := CCSprite._create('Images/grossini.png');
  addChild(spriteHD);
  spriteHD.setPosition(ccp(s.width / 4 * 3, s.height / 2));
  child2_left := DoubleSprite._create('Images/grossini_dance_08.png');
  spriteHD.addChild(child2_left);
  child2_left.setPosition(ccp(-30, 0));
  child2_right := CCSprite._create('Images/grossini.png');
  spriteHD.addChild(child2_right);
  child2_left.setPosition(ccp(spriteHD.getContentSize().height, 0));

    // Actions
  scale := CCScaleBy._create(2, 0.5);
  scale_back := scale.reverse();
  seq := CCSequence._create([scale, scale_back]);
  seq_copy := CCFiniteTimeAction(seq.copy().autorelease());
  spriteSD.runAction(seq);
  spriteHD.runAction(seq_copy);
end;

function SpriteDoubleResolution.subtitle: string;
begin
  Result := 'Retina Display. SD (left) should be equal to HD (right)';
end;

function SpriteDoubleResolution.title: string;
begin
  Result := 'Sprite Double resolution';
end;

{ DoubleSprite }

class function DoubleSprite._create(
  const pszFilename: string): DoubleSprite;
var
  pRet: DoubleSprite;
begin
  pRet := DoubleSprite.Create;
  pRet.initWithFile(pszFilename);
  pRet.autorelease;
  Result := pRet;
end;

function DoubleSprite.initWithTexture(pTexture: CCTexture2D;
  const rect: CCRect): Boolean;
begin
  Result := inherited initWithTexture(pTexture, rect);
end;

procedure DoubleSprite.setContentSize(const Value: CCSize);
var
  s: CCSize;
begin
  s := Value;
  if (CC_CONTENT_SCALE_FACTOR() = 2) and not m_bHD then
  begin
    s.width := s.width * 2;
    s.height := s.height * 2;
  end;
  inherited setContentSize(s);
end;

procedure DoubleSprite.setVertexRect(const rect: CCRect);
var
  nr: CCRect;
begin
  nr := rect;
  if (CC_CONTENT_SCALE_FACTOR = 2) and not m_bHD then
  begin
    nr.size.width := rect.size.width * 2;
    nr.size.height := rect.size.height * 2;
  end;
  inherited setVertexRect(nr);
end;

{ AnimationCacheFile }

constructor AnimationCacheFile.Create;
var
  frameCache: CCSpriteFrameCache;
  animCache: CCAnimationCache;
  normal, dance_grey, dance_blue: CCAnimation;
  animN, animG, animB: CCAnimate;
  seq: CCFiniteTimeAction;
  grossini: CCSprite;
  winsize: CCSize;
  frame: CCSpriteFrame;
begin
  inherited;

  frameCache := CCSpriteFrameCache.sharedSpriteFrameCache();
  frameCache.addSpriteFramesWithFile('animations/grossini.plist');
  frameCache.addSpriteFramesWithFile('animations/grossini_gray.plist');
  frameCache.addSpriteFramesWithFile('animations/grossini_blue.plist');

    // Purge previously loaded animation
  CCAnimationCache.purgeSharedAnimationCache();
  animCache := CCAnimationCache.sharedAnimationCache();
    // Add an animation to the Cache
  animCache.addAnimationsWithFile('animations/animations.plist');

  normal := animCache.animationByName('dance_1');
  normal.setRestoreOriginalFrame(true);
  dance_grey := animCache.animationByName('dance_2');
  dance_grey.setRestoreOriginalFrame(true);
  dance_blue := animCache.animationByName('dance_3');
  dance_blue.setRestoreOriginalFrame(true);
  animN := CCAnimate._create(normal);
  animG := CCAnimate._create(dance_grey);
  animB := CCAnimate._create(dance_blue);
  seq := CCSequence._create([animN, animG, animB]);
    // create an sprite without texture
  grossini := CCSprite._create();
  frame := frameCache.spriteFrameByName('grossini_dance_01.png');
  grossini.setDisplayFrame(frame);
  winSize := CCDirector.sharedDirector().getWinSize();
  grossini.setPosition(ccp(winSize.width / 2, winSize.height / 2));
  addChild(grossini);

    // run the animation
  grossini.runAction(seq);
end;

function AnimationCacheFile.subtitle: string;
begin
  Result := 'Sprite should be animated';
end;

function AnimationCacheFile.title: string;
begin
  Result := 'AnimationCache - Load file';
end;

end.

