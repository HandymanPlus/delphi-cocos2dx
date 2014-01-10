unit controller;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCTouch, Cocos2dx.CCSet,
  Cocos2dx.CCGeometry, Cocos2dx.CCMenu;

type
  TestController = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;
    //procedure draw(); override;
    procedure menuCallback(pObj: CCObject);
    procedure closeCallback(pObj: CCObject);
    procedure ccTouchesBegan(pTouches: CCSet; pEvent: CCEvent); override;
    procedure ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent); override;
  private
    m_tBeginPos: CCPoint;
    m_pItemMenu: CCMenu;
  end;

implementation
uses
  Cocos2dx.CCPointExtension, testBasic, Cocos2dx.CCDirector, tests, Cocos2dx.CCMenuItem,
  testResource, Cocos2dx.CCLabelTTF,
  spritetest, SchedulerTest, actionstest, actionmanagertest,
  clickandmovetest, layertest, nodetest, rotateworldtest, box2dtest, ActionsProgressTest,
  TransitionsTest, ActionsEaseTest, MotionStreakTest, scenetest, rendertexturetest,
  effectstest, ParticleTest, shadertest, EffectAdvanceTest, fonttest, intervaltest,
  DrawPrimitivesTest, PerformanceTest;

const LINE_SPACE = 40;
var s_tCurPos: CCPoint {= CCPointZero};


function CreateTestScene(nIdx: TTestType): TestScene;
var
  pScene: TestScene;
begin
  CCDirector.sharedDirector().purgeCachedData();

  pScene := nil;

  case nIdx of
    TEST_SPRITE:
      begin
        pScene := SpriteTestScene.Create();
      end;
    TEST_SCHEDULER:
      begin
        pScene := SchedulerTestScene.Create();
      end;
    TEST_ACTIONS:
      begin
        pScene := ActionsTestScene.Create();
      end;
    TEST_ACTION_MANAGER:
      begin
        pScene := ActionManagerTestScene.Create();
      end;
    TEST_CLICK_AND_MOVE:
      begin
        pScene := ClickAndMoveTestScene.Create();
      end;
    TEST_LAYER:
      begin
        pScene := LayerTestScene.Create();
      end;
    TEST_COCOSNODE:
      begin
        pScene := NodeTestScene.Create();
      end;
    TEST_ROTATE_WORLD:
      begin
        pScene := RotateWorldTestScene.Create();
      end;
    TEST_BOX2D:
      begin
        pScene := Box2dTestScene.Create();
      end;
    TEST_PROGRESS_ACTIONS:
      begin
        pScene := ProgressTestScene.Create();
      end;
    TEST_TRANSITIONS:
      begin
        pScene := TransitionsTestScene.Create();
      end;
    TEST_EASE_ACTIONS:
      begin
        pScene := ActionsEaseTestScene.Create();
      end;
    TEST_MOTION_STREAK:
      begin
        pScene := MotionTestScene.Create();
      end;
    TEST_SCENE:
      begin
        pScene := SceneTestScene.Create();
      end;
    TEST_RENDERTEXTURE:
      begin
        pScene := rendertextureTestScene.Create();
      end;
    TEST_EFFECTS:
      begin
        pScene := EffectTestScene.Create();
      end;
    TEST_PARTICLE:
      begin
        pScene := ParticleTestScene.Create();
      end;
    TEST_SHADER:
      begin
        pScene := ShaderTestScene.Create();
      end;
    TEST_EFFECT_ADVANCE:
      begin
        pScene := EffectAdvanceScene.Create();
      end;
    TEST_FONTS:
      begin
        pScene := FontTestScene.Create();
      end;
    TEST_INTERVAL:
      begin
        pScene := IntervalTestScene.Create();
      end;
    TEST_DRAW_PRIMITIVES:
      begin
        pScene := DrawPrimitivesTestScene.Create();
      end;
    TEST_PERFORMANCE:
      begin
        pScene := PerformanceTestScene.Create();
      end;  
  end;

  Result := pScene;
end;

{ TestController }

procedure TestController.ccTouchesBegan(pTouches: CCSet; pEvent: CCEvent);
var
  pTouch: CCTouch;
begin
  pTouch := CCTouch(pTouches.getObject(0));
  m_tBeginPos := pTouch.getLocation();
end;

procedure TestController.ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent);
var
  pTouch: CCTouch;
  nMoveY: Single;
  touchLocation: CCPoint;
  curPos, nextPos: CCPoint;
  winSize: CCSize;

begin
  pTouch := CCTouch(pTouches.getObject(0));
  touchLocation := pTouch.getLocation();

  nMoveY := touchLocation.y - m_tBeginPos.y;

  curPos := m_pItemMenu.getPosition();
  nextPos := ccp(curPos.x, curPos.y + nMoveY);
  winSize := CCDirector.sharedDirector().getWinSize();
  if nextPos.y < 0.0 then
  begin
    m_pItemMenu.setPosition(CCPointZero);
    Exit;
  end;

  if nextPos.y > ( (Ord(TESTS_COUNT) + 1 )*LINE_SPACE -winSize.height ) then
  begin
    m_pItemMenu.setPosition(ccp(0, (Ord(TESTS_COUNT) + 1)*LINE_SPACE - winSize.height ));
    Exit;
  end;

  m_pItemMenu.setPosition(nextPos);
  m_tBeginPos := touchLocation;
  s_tCurPos := nextPos;
end;

procedure TestController.closeCallback(pObj: CCObject);
begin
  CCDirector.sharedDirector()._end();
end;

constructor TestController.Create;
var
  pCloseItem: CCMenuItem;
  pMenu: CCMenu;
  s: CCSize;
  i: Integer;
  pLabel: CCLabelTTF;
  pMenuItem: CCMenuItemLabel;
begin
  inherited Create();

  m_tBeginPos := CCPointZero;
  s := CCDirector.sharedDirector().getWinSize();

  pCloseItem := CCMenuItemImage._create(s_pPathClose, s_pPathClose, Self, closeCallback);
  pMenu := CCMenu._create([pCloseItem]);

  pMenu.setPosition(CCPointZero);
  pCloseItem.setPosition(CCPointMake(s.width-30, s.height-30));
  addChild(pMenu, 1);

  m_pItemMenu := CCMenu._create();

  for i := 0 to Ord(TESTS_COUNT)-1 do
  begin
    pLabel := CCLabelTTF._create(g_aTestNames[i], 'Arial', 24);
    pMenuItem := CCMenuItemLabel._create(pLabel, Self, menuCallback);

    m_pItemMenu.addChild(pMenuItem, i + 10000);
    pMenuItem.setPosition(CCPointMake(s.width/2, (s.height - (i+1)* LINE_SPACE)));
  end;

  m_pItemMenu.setContentSize(CCSizeMake(s.width, (Ord(TESTS_COUNT)+1)*LINE_SPACE   ));
  m_pItemMenu.setPosition(s_tCurPos);
  addChild(m_pItemMenu);

  setTouchEnabled(True);
end;

destructor TestController.Destroy;
begin

  inherited;
end;

(*procedure TestController.draw;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();

  ccDrawLine(ccp(0, 0,), ccp(s.width, s.height));
end;*)

procedure TestController.menuCallback(pObj: CCObject);
var
  pMenuItem: CCMenuItem;
  nIdx: Integer;
  pScene: TestScene;
begin
  pMenuItem := CCMenuItem(pObj);
  nIdx := pMenuItem.ZOrder - 10000;

  pScene := CreateTestScene(TTestType(nIdx));
  if pScene <> nil then
  begin
    pScene.runThisTest();
    pScene.release();
  end;
end;

end.
