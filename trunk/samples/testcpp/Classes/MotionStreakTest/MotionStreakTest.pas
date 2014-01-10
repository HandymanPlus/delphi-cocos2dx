unit MotionStreakTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCTouch, Cocos2dx.CCSet, Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCMotionStreak;

type
  MotionTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  MotionTestDemo = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; dynamic;
    function subtitle(): string; dynamic;
    procedure onEnter(); override;

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
    procedure modeCallback(pObj: CCObject);
  protected
    streak: CCMotionStreak;
  end;

  MotionStreakTest1 = class(MotionTestDemo)
  public
    m_root: CCNode;
    m_target: CCNode;
    procedure onEnter(); override;
    function title(): string; override;
    procedure onUpdate(delta: Single);
  end;

  MotionStreakTest2 = class(MotionTestDemo)
  public
    m_root: CCNode;
    m_target: CCNode;
    procedure onEnter(); override;
    function title(): string; override;
    procedure ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent); override;
  end;

  Issue1358 = class(MotionTestDemo)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure update(time: Single); override;
  private
    m_center: CCPoint;
    m_fRadius: Single;
    m_fAngle: Single;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, testResource,
  Cocos2dx.CCTypes, Cocos2dx.CCAction, Cocos2dx.CCActionInterval;

var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 3;
const
  kTagLabel = 1;

function createMotionTestLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := MotionStreakTest1.Create;
    1: bRet := MotionStreakTest2.Create;
    2: bRet := Issue1358.Create;
  end;

  Result := bRet;
end;  

function nextMotionTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createMotionTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backMotionTestAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createMotionTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartMotionTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createMotionTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ MotionTestScene }

procedure MotionTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := nextMotionTestAction();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ MotionTestDemo }

procedure MotionTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := MotionTestScene.Create();
  s.addChild(backMotionTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor MotionTestDemo.Create;
begin
  inherited;
end;

destructor MotionTestDemo.Destroy;
begin

  inherited;
end;

procedure MotionTestDemo.modeCallback(pObj: CCObject);
begin
  streak.setFastMode(not streak.isFastMode());
end;

procedure MotionTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := MotionTestScene.Create();
  s.addChild(nextMotionTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure MotionTestDemo.onEnter;
var
  s: CCSize;
  label1, label2: CCLabelTTF;
  strSubtitle: string;
  item1, item2, item3: CCMenuItemImage;
  itemMode: CCMenuItemToggle;
  menu, menuMode: CCMenu;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize;

  label1 := CCLabelTTF._create(title(), 'Arial', 28);
  addChild(label1, kTagLabel);
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

  itemMode := CCMenuItemToggle.createWithTarget(Self, modeCallback,
    [CCMenuItemFont._create('Use High Quality Mode'),
     CCMenuItemFont._create('Use Fast Mode')]);
  menuMode := CCMenu._create([itemMode]);
  addChild(menuMode);

  menuMode.setPosition(s.width/2, s.height/4);
end;

procedure MotionTestDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := MotionTestScene.Create();
  s.addChild(restartMotionTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function MotionTestDemo.subtitle: string;
begin
  Result := '';
end;

function MotionTestDemo.title: string;
begin
  Result := 'No title';
end;

{ MotionStreakTest1 }

procedure MotionStreakTest1.onEnter;
var
  s: CCSize;
  a1: CCFiniteTimeAction;
  action1: CCAction;
  motion: CCFiniteTimeAction;
  colorAction: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  m_root := CCSprite._create(s_pPathR1);
  addChild(m_root, 1);
  m_root.setPosition(ccp(s.width/2, s.height/2));

  m_target := CCSprite._create(s_pPathR1);
  m_root.addChild(m_target);
  m_target.setPosition(ccp(s.width/4, 0));

  streak := CCMotionStreak._create(2, 3, 32, ccGREEN, s_streak);
  addChild(streak);

  schedule(onUpdate);

  a1 := CCRotateBy._create(2, 360);
  action1 := CCRepeatForever._create(CCActionInterval(a1));
  motion := CCMoveBy._create(2, CCPointMake(100, 0));
  m_root.runAction(  CCRepeatForever._create( CCActionInterval(CCSequence._create([motion, motion.reverse()])) )  );
  m_root.runAction(action1);

  colorAction := CCRepeatForever._create(CCActionInterval(CCSequence._create([
    CCTintTo._create(0.2, 255, 0, 0),
    CCTintTo._create(0.2, 0, 255, 0),
    CCTintTo._create(0.2, 0, 0, 255),
    CCTintTo._create(0.2, 0, 255, 255),
    CCTintTo._create(0.2, 255, 255, 0),
    CCTintTo._create(0.2, 255, 0, 255),
    CCTintTo._create(0.2, 255, 255, 255)
    ])
  ));
  streak.runAction(colorAction);
end;

procedure MotionStreakTest1.onUpdate(delta: Single);
begin
  streak.setPosition(m_target.convertToWorldSpace(CCPointZero));
end;

function MotionStreakTest1.title: string;
begin
  Result := 'MotionStreak test 1';
end;

{ MotionStreakTest2 }

procedure MotionStreakTest2.ccTouchesMoved(pTouches: CCSet;
  pEvent: CCEvent);
var
  touch: CCTouch;
  touchLocation: CCPoint;
begin
  touch := CCTouch(pTouches.getObject(0));
  touchLocation := touch.getLocation();
  streak.setPosition(touchLocation);
end;

procedure MotionStreakTest2.onEnter;
var
  s: CCSize;
begin
  inherited;
  setTouchEnabled(True);
  s := CCDirector.sharedDirector().getWinSize();
  streak := CCMotionStreak._create(3, 3, 64, ccWHITE, s_streak);
  addChild(streak);
  streak.setPosition(CCPointMake(s.width/2, s.height/2));
end;

function MotionStreakTest2.title: string;
begin
  Result := 'MotionStreak test';
end;

{ Issue1358 }

procedure Issue1358.onEnter;
var
  s: CCSize;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize();
  streak := CCMotionStreak._create(2, 1, 50, ccc3(255, 255, 0), 'Images/Icon.png');
  addChild(streak);
  
  m_center := ccp(s.width/2, s.height/2);
  m_fRadius := s.width/3;
  m_fAngle := 0;

  schedule(update, 0);
end;

function Issue1358.subtitle: string;
begin
  Result := 'The tail should use the texture';
end;

function Issue1358.title: string;
begin
  Result := 'Issue 1358';
end;

procedure Issue1358.update(time: Single);
begin
  m_fAngle := m_fAngle + 1;
  streak.setPosition( ccp(m_center.x + Cos(m_fAngle/180*pi)*m_fradius,
    m_center.y + Sin(m_fAngle/180*pi)*m_fradius) );

end;

end.
