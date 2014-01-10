unit ActionsProgressTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSprite, Cocos2dx.CCNode;

type
  ProgressTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  ProgressTestDemo = class(CCLayer)
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

  SpriteProgressToRadial = class(ProgressTestDemo)
  public
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;

  SpriteProgressToHorizontal = class(ProgressTestDemo)
  public
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;

  SpriteProgressToVertical = class(ProgressTestDemo)
  public
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;

  SpriteProgressToRadialMidpointChanged = class(ProgressTestDemo)
  public
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;

  SpriteProgressBarVarious = class(ProgressTestDemo)
  public
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;

  SpriteProgressBarTintAndFade = class(ProgressTestDemo)
  public
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;

  SpriteProgressWithSpriteFrame = class(ProgressTestDemo)
  public
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;


implementation
uses
  SysUtils, Cocos2dx.CCProgressTimer, Cocos2dx.CCActionProgressTimer,
  Cocos2dx.CCSpriteFrameCache,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension, Cocos2dx.CCMenuItem,
  Cocos2dx.CCMenu, testResource,
  Cocos2dx.CCTypes, Cocos2dx.CCAction, Cocos2dx.CCActionInterval;

var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 7;

function createProgressTestLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := SpriteProgressToRadial.Create;
    1: bRet := SpriteProgressToHorizontal.Create;
    2: bRet := SpriteProgressToVertical.Create;
    3: bRet := SpriteProgressToRadialMidpointChanged.Create;
    4: bRet := SpriteProgressBarVarious.Create;
    5: bRet := SpriteProgressBarTintAndFade.Create;
    6: bRet := SpriteProgressWithSpriteFrame.Create;
  end;

  Result := bRet;
end;  

function nextProgressTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createProgressTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backProgressTestAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createProgressTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartProgressTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createProgressTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ ProgressTestScene }

procedure ProgressTestScene.runThisTest;
begin
    addChild(nextProgressTestAction());
    CCDirector.sharedDirector().replaceScene(Self);

end;

{ ProgressTestDemo }

procedure ProgressTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ProgressTestScene.Create();
  s.addChild(backProgressTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor ProgressTestDemo.Create;
begin
  inherited Create();
end;

destructor ProgressTestDemo.Destroy;
begin

  inherited;
end;

procedure ProgressTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ProgressTestScene.Create();
  s.addChild(nextProgressTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure ProgressTestDemo.onEnter;
var
  s: CCSize;
  label1, label2: CCLabelTTF;
  strSubtitle: string;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
  background: CCLayerColor;
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

  background := CCLayerColor._create(ccc4(255, 0, 0, 255));
  addChild(background, -10);
end;

procedure ProgressTestDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ProgressTestScene.Create();
  s.addChild(restartProgressTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function ProgressTestDemo.subtitle: string;
begin
  Result := '';
end;

function ProgressTestDemo.title: string;
begin
  Result := 'ActionsProgressTest';
end;

{ SpriteProgressToRadial }

procedure SpriteProgressToRadial.onEnter;
var
  s: CCSize;
  to1, to2: CCProgressTo;
  left, right: CCProgressTimer;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  to1 := CCProgressTo._create(2, 100);
  to2 := CCProgressTo._create(2, 100);

  left := CCProgressTimer._create(CCSprite._create(s_pPathSister1));
  left.setType(kCCProgressTimerTypeRadial);
  addChild(left);
  left.setPosition(CCPointMake(100, s.height/2));
  left.runAction(CCRepeatForever._create(to1));

  right := CCProgressTimer._create(CCSprite._create(s_pPathBlock));
  right.setType(kCCProgressTimerTypeRadial);
  right.setReverseProgress(True);
  addChild(right);
  right.setPosition(CCPointMake(s.width-100, s.height/2));
  right.runAction(CCRepeatForever._create(to2));
end;

function SpriteProgressToRadial.subtitle: string;
begin
  Result := 'ProgressTo Radial';
end;

{ SpriteProgressToHorizontal }

procedure SpriteProgressToHorizontal.onEnter;
var
  s: CCSize;
  to1, to2: CCProgressTo;
  left, right: CCProgressTimer;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  to1 := CCProgressTo._create(2, 100);
  to2 := CCProgressTo._create(2, 100);

  left := CCProgressTimer._create(CCSprite._create(s_pPathSister1));
  left.setType(kCCProgressTimerTypeBar);
  left.Midpoint := CCPointZero;
  left.BarChangeRate := ccp(1, 0);
  addChild(left);
  left.setPosition(CCPointMake(100, s.height/2));
  left.runAction(CCRepeatForever._create(to1));

  right := CCProgressTimer._create(CCSprite._create(s_pPathSister2));
  right.setType(kCCProgressTimerTypeBar);
  right.Midpoint := ccp(1, 0);
  right.BarChangeRate := ccp(1, 0);
  addChild(right);
  right.setPosition(CCPointMake(s.width-100, s.height/2));
  right.runAction(CCRepeatForever._create(to2));
end;

function SpriteProgressToHorizontal.subtitle: string;
begin
  Result := 'ProgressTo Horizontal';
end;

{ SpriteProgressToVertical }

procedure SpriteProgressToVertical.onEnter;
var
  s: CCSize;
  to1, to2: CCProgressTo;
  left, right: CCProgressTimer;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  to1 := CCProgressTo._create(2, 100);
  to2 := CCProgressTo._create(2, 100);

  left := CCProgressTimer._create(CCSprite._create(s_pPathSister1));
  left.setType(kCCProgressTimerTypeBar);
  left.Midpoint := CCPointZero;
  left.BarChangeRate := ccp(0, 1);
  addChild(left);
  left.setPosition(CCPointMake(100, s.height/2));
  left.runAction(CCRepeatForever._create(to1));

  right := CCProgressTimer._create(CCSprite._create(s_pPathSister2));
  right.setType(kCCProgressTimerTypeBar);
  right.Midpoint := ccp(0, 1);
  right.BarChangeRate := ccp(0, 1);
  addChild(right);
  right.setPosition(CCPointMake(s.width-100, s.height/2));
  right.runAction(CCRepeatForever._create(to2));
end;

function SpriteProgressToVertical.subtitle: string;
begin
  Result := 'ProgressTo Vertical';
end;

{ SpriteProgressToRadialMidpointChanged }

procedure SpriteProgressToRadialMidpointChanged.onEnter;
var
  s: CCSize;
  action: CCProgressTo;
  left, right: CCProgressTimer;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  action := CCProgressTo._create(2, 100);

  left := CCProgressTimer._create(CCSprite._create(s_pPathBlock));
  left.setType(kCCProgressTimerTypeRadial);
  addChild(left);
  left.Midpoint := ccp(0.25, 0.75);
  left.setPosition(CCPointMake(100, s.height/2));
  left.runAction(CCRepeatForever._create( CCActionInterval(action.copy.autorelease) ));

  right := CCProgressTimer._create(CCSprite._create(s_pPathBlock));
  right.setType(kCCProgressTimerTypeRadial);
  right.Midpoint := ccp(0.75, 0.25);
  addChild(right);
  right.setPosition(CCPointMake(s.width-100, s.height/2));
  right.runAction(CCRepeatForever._create(CCActionInterval(action.copy.autorelease) ));
end;

function SpriteProgressToRadialMidpointChanged.subtitle: string;
begin
  Result := 'Radial w/ Different Midpoints';
end;

{ SpriteProgressBarVarious }

procedure SpriteProgressBarVarious.onEnter;
var
  s: CCSize;
  action: CCProgressTo;
  left, right, middle: CCProgressTimer;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  action := CCProgressTo._create(2, 100);

  left := CCProgressTimer._create(CCSprite._create(s_pPathSister1));
  left.setType(kCCProgressTimerTypeBar);
  left.Midpoint := ccp(0.5, 0.5);
  left.BarChangeRate := ccp(1, 0);
  addChild(left);
  left.setPosition(CCPointMake(100, s.height/2));
  left.runAction(CCRepeatForever._create(CCActionInterval(action.copy.autorelease) ));

  middle := CCProgressTimer._create(CCSprite._create(s_pPathSister2));
  middle.setType(kCCProgressTimerTypeBar);
  middle.Midpoint := ccp(0.5, 0.5);
  middle.BarChangeRate := ccp(1, 1);
  addChild(middle);
  middle.setPosition(CCPointMake(s.width/2, s.height/2));
  middle.runAction(CCRepeatForever._create( CCActionInterval(action.copy.autorelease) ));

  right := CCProgressTimer._create(CCSprite._create(s_pPathSister2));
  right.setType(kCCProgressTimerTypeBar);
  right.Midpoint := ccp(0.5, 0.5);
  right.BarChangeRate := ccp(0, 1);
  addChild(right);
  right.setPosition(CCPointMake(s.width-100, s.height/2));
  right.runAction(CCRepeatForever._create(CCActionInterval(action.copy.autorelease) ));
end;

function SpriteProgressBarVarious.subtitle: string;
begin
  Result := 'ProgressTo Bar Mid';
end;

{ SpriteProgressBarTintAndFade }

procedure SpriteProgressBarTintAndFade.onEnter;
var
  s: CCSize;
  action: CCProgressTo;
  left, right, middle: CCProgressTimer;
  tint, fade: CCAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  action := CCProgressTo._create(6, 100);
  tint := CCSequence._create([ CCTintTo._create(1, 255, 0, 0), CCTintTo._create(1, 0, 255, 0), CCTintTo._create(1, 0, 0, 255) ]);
  fade := CCSequence._create([ CCFadeTo._create(1, 0), CCFadeTo._create(1, 255) ]);

  left := CCProgressTimer._create(CCSprite._create(s_pPathSister1));
  left.setType(kCCProgressTimerTypeBar);
  left.Midpoint := ccp(0.5, 0.5);
  left.BarChangeRate := ccp(1, 0);
  addChild(left);
  left.setPosition(CCPointMake(100, s.height/2));
  left.runAction(CCRepeatForever._create(CCActionInterval(action.copy.autorelease) ));
  left.runAction(CCRepeatForever._create(CCActionInterval(tint.copy.autorelease)  ));

  left.addChild(CCLabelTTF._create('Tint', 'Marker Felt', 20));

  middle := CCProgressTimer._create(CCSprite._create(s_pPathSister2));
  middle.setType(kCCProgressTimerTypeBar);
  middle.Midpoint := ccp(0.5, 0.5);
  middle.BarChangeRate := ccp(1, 1);
  addChild(middle);
  middle.setPosition(CCPointMake(s.width/2, s.height/2));
  middle.runAction(CCRepeatForever._create( CCActionInterval(action.copy.autorelease) ));
  middle.runAction(CCRepeatForever._create( CCActionInterval(fade.copy.autorelease) ));

  middle.addChild(CCLabelTTF._create('Fade', 'Marker Felt', 20));

  right := CCProgressTimer._create(CCSprite._create(s_pPathSister2));
  right.setType(kCCProgressTimerTypeBar);
  right.Midpoint := ccp(0.5, 0.5);
  right.BarChangeRate := ccp(0, 1);
  addChild(right);
  right.setPosition(CCPointMake(s.width-100, s.height/2));
  right.runAction(CCRepeatForever._create(CCActionInterval(action.copy.autorelease) ));
  right.runAction(CCRepeatForever._create(CCActionInterval(tint.copy.autorelease) ));
  right.runAction(CCRepeatForever._create(CCActionInterval(fade.copy.autorelease) ));

  right.addChild(CCLabelTTF._create('Tint and Fade', 'Marker Felt', 20));
end;

function SpriteProgressBarTintAndFade.subtitle: string;
begin
  Result := 'ProgressTo Bar Mid';
end;

{ SpriteProgressWithSpriteFrame }

procedure SpriteProgressWithSpriteFrame.onEnter;
var
  s: CCSize;
  _to: CCProgressTo;
  left, middle, right: CCProgressTimer;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  _to := CCProgressTo._create(6, 100);
  CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile('zwoptex/grossini.plist');

  left := CCProgressTimer._create(CCSprite.createWithSpriteFrameName('grossini_dance_01.png'));
  left.setType(kCCProgressTimerTypeBar);
  left.Midpoint := ccp(0.5, 0.5);
  left.BarChangeRate := ccp(1, 0);
  addChild(left);
  left.setPosition(100, s.height/2);
  left.runAction(CCRepeatForever._create( CCActionInterval(_to.copy.autorelease) ));

  middle := CCProgressTimer._create(CCSprite.createWithSpriteFrameName('grossini_dance_02.png'));
  middle.setType(kCCProgressTimerTypeBar);
  middle.Midpoint := ccp(0.5, 0.5);
  middle.BarChangeRate := ccp(1, 1);
  addChild(middle);
  middle.setPosition(s.width/2, s.height/2);
  middle.runAction(CCRepeatForever._create( CCActionInterval(_to.copy.autorelease) ));

  right := CCProgressTimer._create(CCSprite.createWithSpriteFrameName('grossini_dance_03.png'));
  right.setType(kCCProgressTimerTypeRadial);
  right.Midpoint := ccp(0.5, 0.5);
  right.BarChangeRate := ccp(0, 1);
  addChild(right);
  right.setPosition(s.width-100, s.height/2);
  right.runAction(CCRepeatForever._create( CCActionInterval(_to.copy.autorelease) ));
end;

function SpriteProgressWithSpriteFrame.subtitle: string;
begin
  Result := 'Progress With Sprite Frame';
end;

end.
