unit PerformanceTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, testBasic;

type
  PerformanceMainLayer = class(CCLayer)
  public
    procedure onEnter(); override;
    procedure menuCallback(pSender: CCObject);
  end;

  PerformBasicLayer = class(CCLayer)
  public
    constructor Create(bControlMenuVisible: Boolean; nMaxCased: Integer = 0; nCurCase: Integer = 0);
    procedure onEnter(); override;
    procedure restartCallback(pSender: CCObject);
    procedure nextCallback(pSender: CCObject);
    procedure backCallback(pSender: CCObject);
    procedure toMainLayer(pSender: CCObject);
    procedure showCurrentTest(); dynamic; abstract;
  protected
    m_bControlMenuVisible: Boolean;
    m_nMaxCases: Integer;
    m_nCurCase: Integer;
  end;

  PerformanceTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

implementation
uses
  testResource, Cocos2dx.CCScene, PerformanceParticleTest,
  Cocos2dx.CCDirector, Cocos2dx.CCGeometry, Cocos2dx.CCMenu,
  Cocos2dx.CCMenuItem, PerformanceSpriteTest;

const    MAX_COUNT = 5;
const    LINE_SPACE = 40;
const    kItemTagBasic = 1000;

const testsName: array [0..MAX_COUNT-1] of string = (
    'PerformanceNodeChildrenTest',
    'PerformanceParticleTest',
    'PerformanceSpriteTest',
    'PerformanceTextureTest',
    'PerformanceTouchesTest'
);

{ PerformanceMainLayer }

procedure PerformanceMainLayer.menuCallback(pSender: CCObject);
var
  pItem: CCMenuItemFont;
  nIndex: Integer;
begin
  pItem := CCMenuItemFont(pSender);
  nIndex := pItem.getZOrder - kItemTagBasic;

  case nIndex of
    0: ;
    1: runParticleTest;
    2: runSpriteTest;
    3: ;
    4: ;
  end;
end;

procedure PerformanceMainLayer.onEnter;
var
  s: CCSize;
  pMenu: CCMenu;
  i: Integer;
  pItem: CCMenuItemFont;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  pMenu := CCMenu._create;
  pMenu.setPosition(CCPointZero);
  CCMenuItemFont.setFontName('Arial');
  CCMenuItemFont.setFontSize(24);
  for i := 0 to MAX_COUNT-1 do
  begin
    pItem := CCMenuItemFont._create(testsName[i], Self, menuCallback);
    pItem.setPosition(s.width/2, s.height - (i + 1) * LINE_SPACE);
    pMenu.addChild(pItem, kItemTagBasic + i);
  end;
  addChild(pMenu);
end;

{ PerformBasicLayer }

procedure PerformBasicLayer.backCallback(pSender: CCObject);
begin
  Dec(m_nCurCase);
  if m_nCurCase < 0 then
    m_nCurCase := m_nCurCase + m_nMaxCases;
  showCurrentTest;
end;

constructor PerformBasicLayer.Create(bControlMenuVisible: Boolean;
  nMaxCased, nCurCase: Integer);
begin
  inherited Create();
  m_bControlMenuVisible := bControlMenuVisible;
  m_nMaxCases := nMaxCased;
  m_nCurCase := nCurCase;
end;

procedure PerformBasicLayer.nextCallback(pSender: CCObject);
begin
  Inc(m_nCurCase);
  m_nCurCase := m_nCurCase mod m_nMaxCases;
  showCurrentTest;
end;

procedure PerformBasicLayer.onEnter;
var
  s: CCSize;
  pMenu: CCMenu;
  pMainItem: CCMenuItem;
  item1, item2, item3: CCMenuItemImage;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  CCMenuItemFont.setFontName('Arial');
  CCMenuItemFont.setFontSize(24);
  pMainItem := CCMenuItemFont._create('Back', Self, toMainLayer);
  pMainItem.setPosition(s.width-50, 25);
  pMenu := CCMenu._create([pMainItem]);
  pMenu.setPosition(CCPointZero);

  if m_bControlMenuVisible then
  begin
    item1 := CCMenuItemImage._create(s_pPathB1, s_pPathB2, Self, backCallback);
    item2 := CCMenuItemImage._create(s_pPathR1, s_pPathR2, Self, restartCallback);
    item3 := CCMenuItemImage._create(s_pPathF1, s_pPathF2, Self, nextCallback);

    item1.setPosition(s.width/2-100, 30);
    item2.setPosition(s.width/2, 30);
    item3.setPosition(s.width/2+100, 30);

    pMenu.addChild(item1, kItemTagBasic);
    pMenu.addChild(item2, kItemTagBasic);
    pMenu.addChild(item3, kItemTagBasic);
  end;
  addChild(pMenu);
end;

procedure PerformBasicLayer.restartCallback(pSender: CCObject);
begin
  showCurrentTest;
end;

procedure PerformBasicLayer.toMainLayer(pSender: CCObject);
var
  pScen: PerformanceTestScene;
begin
  pScen := PerformanceTestScene.Create();
  pScen.runThisTest;
  pScen.release;
end;

{ PerformanceTestScene }

procedure PerformanceTestScene.runThisTest;
var
  player: CCLayer;
begin
  player := PerformanceMainLayer.Create;
  addChild(player);
  player.release;
  CCDirector.sharedDirector.replaceScene(Self);
end;

end.
