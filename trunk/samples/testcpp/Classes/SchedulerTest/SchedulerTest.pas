unit SchedulerTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSet, Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCString, Cocos2dx.CCControlSlider, Cocos2dx.CCInvocation,
  Cocos2dx.CCScheduler, Cocos2dx.CCActionManager;

type
  SchedulerTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  SchedulerTestLayer = class(CCLayer)
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

  SchedulerAutoremove = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure autoremove(dt: Single);
    procedure tick(dt: Single);
  private
    accum: Single;
  end;

  SchedulerPauseResume = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure tick1(dt: Single);
    procedure tick2(dt: Single);
    procedure pause(dt: Single);
  end;

  SchedulerPauseResumeAll = class(SchedulerTestLayer)
  public
    constructor Create();
    destructor Destroy(); override;

    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;

    procedure tick1(dt: Single);
    procedure tick2(dt: Single);
    procedure pause(dt: Single);
    procedure resume(dt: Single);
  private
    m_pPausedTargets: CCSet;
  end;

  SchedulerUnscheduleAll = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure tick1(dt: Single);
    procedure tick2(dt: Single);
    procedure tick3(dt: Single);
    procedure tick4(dt: Single);
    procedure unscheduleAll(dt: Single);
  end;

  SchedulerUnscheduleAllHard = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;

    procedure tick1(dt: Single);
    procedure tick2(dt: Single);
    procedure tick3(dt: Single);
    procedure tick4(dt: Single);
    procedure unscheduleAll(dt: Single);
  private
    m_bActionManagerActive: Boolean;
  end;

  SchedulerUnscheduleAllUserLevel = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure tick1(dt: Single);
    procedure tick2(dt: Single);
    procedure tick3(dt: Single);
    procedure tick4(dt: Single);
    procedure unscheduleAll(dt: Single);
  end;

  SchedulerSchedulesAndRemove = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure tick1(dt: Single);
    procedure tick2(dt: Single);
    procedure tick3(dt: Single);
    procedure tick4(dt: Single);
    procedure scheduleAndUnschedule(dt: Single);
  end;

  SchedulerUpdate = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure removeUpdates(dt: Single);
  end;

  TestNode = class(CCNode)
  public
    destructor Destroy(); override;
    procedure initWithString(pStr: CCString; priority: Integer);
  private
    m_pString: CCString;
  end;

  SchedulerDelayAndRepeat = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure update(dt: Single); override;
  end;

  SchedulerUpdateAndCustom = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure update(dt: Single); override;
    procedure tick(dt: Single);
    procedure stopSelectors(dt: Single);
  end;

  SchedulerUpdateFromCustom = class(SchedulerTestLayer)
  public
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;

    procedure update(dt: Single); override;
    procedure schedUpdate(dt: Single);
    procedure stopUpdate(dt: Single);
  end;

  SchedulerTimeScale = class(SchedulerTestLayer)
  public
    m_pSliderCtl: CCControlSlider;
    function sliderCtl(): CCControlSlider;
    procedure sliderAction(pSender: CCObject; controlEvent: CCControlEvent);
    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
    procedure onExit(); override;
  end;

  TwoSchedulers = class(SchedulerTestLayer)
  public
    sliderCtl1, sliderCtl2: CCControlSlider;
    sched1, sched2: CCScheduler;
    actionManager1, actionManager2: CCActionManager;


    destructor Destroy(); override;

    function sliderCtl(): CCControlSlider;
    procedure sliderAction(pSender: CCObject; controlEvent: CCControlEvent);

    function title(): string; override;
    function subtitle(): string; override;
    procedure onEnter(); override;
  end;

implementation
uses
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCMenuItem, Cocos2dx.CCMenu,
  Cocos2dx.CCPointExtension, Cocos2dx.CCCommon, testResource,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCArray, Cocos2dx.CCAction, Cocos2dx.CCActionInterval,
  Cocos2dx.CCParticleSystem, Cocos2dx.CCTextureCache, Cocos2dx.CCParticleExamples, Cocos2dx.CCControl;


const
    IDC_NEXT = 100;
    IDC_BACK = 101;
    IDC_RESTART = 102;

var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 13;

function createSchedulerTest(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := SchedulerDelayAndRepeat.Create;
    1: bRet := SchedulerTimeScale.Create;
    2: bRet := TwoSchedulers.Create;
    3: bRet := SchedulerAutoremove.Create;
    4: bRet := SchedulerPauseResume.Create;
    5: bret := SchedulerPauseResumeAll.Create;
    6: bRet := SchedulerUnscheduleAll.Create;
    7: bRet := SchedulerUnscheduleAllHard.Create;
    8: bRet := SchedulerUnscheduleAllUserLevel.Create;
    9: bRet := SchedulerSchedulesAndRemove.Create;
    10: bRet := SchedulerUpdate.Create;
    11: bRet := SchedulerUpdateAndCustom.Create;
    12: bRet := SchedulerUpdateFromCustom.Create;
  end;

  Result := bRet;
end;

function nextSchedulerTest(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createSchedulerTest(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backSchedulerTest(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createSchedulerTest(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartSchedulerTest(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createSchedulerTest(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ SchedulerTestScene }

procedure SchedulerTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := nextSchedulerTest();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ SchedulerTestLayer }

procedure SchedulerTestLayer.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := SchedulerTestScene.Create();
  s.addChild(backSchedulerTest());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor SchedulerTestLayer.Create;
begin
  inherited Create();
end;

destructor SchedulerTestLayer.Destroy;
begin

  inherited;
end;

procedure SchedulerTestLayer.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := SchedulerTestScene.Create();
  s.addChild(nextSchedulerTest());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure SchedulerTestLayer.onEnter;
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

procedure SchedulerTestLayer.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := SchedulerTestScene.Create();
  s.addChild(restartSchedulerTest());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function SchedulerTestLayer.subtitle: string;
begin
  Result := '';
end;

function SchedulerTestLayer.title: string;
begin
  Result := 'No title';
end;

{ SchedulerAutoremove }

procedure SchedulerAutoremove.autoremove(dt: Single);
begin
  accum := accum + dt;
  CCLog('Time: %f', [accum]);

  if accum > 3 then
  begin
    unschedule(autoremove);
    CCLog('scheduler removed', []);
  end;  
end;

procedure SchedulerAutoremove.onEnter;
begin
  inherited onEnter();
  schedule(autoremove, 0.5);
  schedule(tick, 0.5);
  accum := 0;
end;

function SchedulerAutoremove.subtitle: string;
begin
  Result := '1 scheduler will be autoremoved in 3 seconds. See console';
end;

procedure SchedulerAutoremove.tick(dt: Single);
begin
  CCLOG('This scheduler should not be removed', []);
end;

function SchedulerAutoremove.title: string;
begin
  Result := 'Self-remove an scheduler';
end;

{ SchedulerPauseResume }

procedure SchedulerPauseResume.onEnter;
begin
  inherited onEnter();
  schedule(tick1, 0.5);
  schedule(tick2, 0.5);
  schedule(pause, 0.5);
end;

procedure SchedulerPauseResume.pause(dt: Single);
begin
  CCDirector.sharedDirector().Scheduler.pauseTarget(Self);
end;

function SchedulerPauseResume.subtitle: string;
begin
  Result := 'Scheduler should be paused after 3 seconds. See console';
end;

procedure SchedulerPauseResume.tick1(dt: Single);
begin
  CCLog('tick1 ', []);
end;

procedure SchedulerPauseResume.tick2(dt: Single);
begin
  CCLog('tick2 ', []);
end;

function SchedulerPauseResume.title: string;
begin
  Result := 'Pause / Resume';
end;

{ SchedulerPauseResumeAll }

constructor SchedulerPauseResumeAll.Create;
begin
  inherited Create();
  m_pPausedTargets := nil;
end;

destructor SchedulerPauseResumeAll.Destroy;
begin
  CC_SAFE_RELEASE(m_pPausedTargets);
  inherited;
end;

procedure SchedulerPauseResumeAll.onEnter;
var
  s: CCSize;
  sprite: CCSprite;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize();

  sprite := CCSprite._create('Images/grossinis_sister1.png');
  sprite.setPosition(ccp(s.width/2, s.height/2));
  Self.addChild(sprite);
  sprite.runAction(CCRepeatForever._create(CCRotateBy._create(3, 360)));

  schedule(tick1, 0.5);
  schedule(tick2, 1.0);
  schedule(pause, 3.0, 0, 0);
end;

procedure SchedulerPauseResumeAll.onExit;
begin
  if m_pPausedTargets <> nil then
  begin
    CCDirector.sharedDirector().Scheduler.resumeTargets(m_pPausedTargets);
    CC_SAFE_RELEASE_NULL(CCObject(m_pPausedTargets));
  end;
  inherited;
end;

procedure SchedulerPauseResumeAll.pause(dt: Single);
var
  pDirector: CCDirector;
begin
  CCLog('Pausing ', []);
  pDirector := CCDirector.sharedDirector();

  m_pPausedTargets := pDirector.Scheduler.pauseAllTargets();
  CC_SAFE_RETAIN(m_pPausedTargets);
end;

procedure SchedulerPauseResumeAll.resume(dt: Single);
var
  pDirector: CCDirector;
begin
  CCLog('Resuming ', []);
  pDirector := CCDirector.sharedDirector();
  pDirector.Scheduler.resumeTarget(m_pPausedTargets);
  CC_SAFE_RELEASE_NULL(CCObject(m_pPausedTargets));
end;

function SchedulerPauseResumeAll.subtitle: string;
begin
  Result := 'Everything will pause after 3s, then resume at 5s. See console';
end;

procedure SchedulerPauseResumeAll.tick1(dt: Single);
begin
  CCLog('tick1 ', []);
end;

procedure SchedulerPauseResumeAll.tick2(dt: Single);
begin
  CCLog('tick2 ', []);
end;

function SchedulerPauseResumeAll.title: string;
begin
  Result := 'Pause / Resume';
end;

{ SchedulerUnscheduleAll }

procedure SchedulerUnscheduleAll.onEnter;
begin
  inherited onEnter();

  schedule(tick1, 0.5);
  schedule(tick2, 1.0);
  schedule(tick3, 1.5);
  schedule(tick4, 1.5);
  schedule(unscheduleAll, 4);
end;

function SchedulerUnscheduleAll.subtitle: string;
begin
  Result := 'All scheduled selectors will be unscheduled in 4 seconds. See console';
end;

procedure SchedulerUnscheduleAll.tick1(dt: Single);
begin
  CCLog('tick1', []);
end;

procedure SchedulerUnscheduleAll.tick2(dt: Single);
begin
  CCLog('tick2', []);
end;

procedure SchedulerUnscheduleAll.tick3(dt: Single);
begin
  CCLog('tick3', []);
end;

procedure SchedulerUnscheduleAll.tick4(dt: Single);
begin
  CCLog('tick4', []);
end;

function SchedulerUnscheduleAll.title: string;
begin
  Result := 'Unschedule All selectors';
end;

procedure SchedulerUnscheduleAll.unscheduleAll(dt: Single);
begin
  unscheduleAllSelectors();
end;

{ SchedulerUnscheduleAllHard }

procedure SchedulerUnscheduleAllHard.onEnter;
var
  s: CCSize;
  sprite: CCSprite;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize();
  sprite := CCSprite._create('Images/grossinis_sister1.png');
  sprite.setPosition( ccp(s.width/2, s.height/2 ) );
  Self.addChild(sprite);
  sprite.runAction(CCRepeatForever._create(CCRotateBy._create(3, 360)));

  m_bActionManagerActive := True;

  schedule(tick1, 0.5);
  schedule(tick2, 1.0);
  schedule(tick3, 1.5);
  schedule(tick4, 1.5);
  schedule(unscheduleAll, 4);
end;

procedure SchedulerUnscheduleAllHard.onExit;
var
  director: CCDirector;
begin
  if not m_bActionManagerActive then
  begin
    director := CCDirector.sharedDirector();
    director.Scheduler.scheduleUpdateForTarget(director.ActionManager, kCCPrioritySystem, False);
  end;
  inherited;
end;

function SchedulerUnscheduleAllHard.subtitle: string;
begin
  Result := 'Unschedules all user selectors after 4s. Action will stop. See console';
end;

procedure SchedulerUnscheduleAllHard.tick1(dt: Single);
begin
  CCLog('tick1', []);
end;

procedure SchedulerUnscheduleAllHard.tick2(dt: Single);
begin
  CCLog('tick2', []);
end;

procedure SchedulerUnscheduleAllHard.tick3(dt: Single);
begin
  CCLog('tick3', []);
end;

procedure SchedulerUnscheduleAllHard.tick4(dt: Single);
begin
  CCLog('tick4', []);
end;

function SchedulerUnscheduleAllHard.title: string;
begin
  Result := 'Unschedule All selectors (HARD)';
end;

procedure SchedulerUnscheduleAllHard.unscheduleAll(dt: Single);
begin
  CCDirector.sharedDirector().Scheduler.unscheduleAll();
  m_bActionManagerActive := False;
end;

{ SchedulerUnscheduleAllUserLevel }

procedure SchedulerUnscheduleAllUserLevel.onEnter;
var
  s: CCSize;
  sprite: CCSprite;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize();
  sprite := CCSprite._create('Images/grossinis_sister1.png');
  sprite.setPosition( ccp(s.width/2, s.height/2 ) );
  Self.addChild(sprite);
  sprite.runAction(CCRepeatForever._create(CCRotateBy._create(3, 360)));

  schedule(tick1, 0.5);
  schedule(tick2, 1.0);
  schedule(tick3, 1.5);
  schedule(tick4, 1.5);
  schedule(unscheduleAll, 4);
end;

function SchedulerUnscheduleAllUserLevel.subtitle: string;
begin
  Result := 'Unschedules all user selectors after 4s. Action should not stop. See console';
end;

procedure SchedulerUnscheduleAllUserLevel.tick1(dt: Single);
begin
  CCLog('tick1', []);
end;

procedure SchedulerUnscheduleAllUserLevel.tick2(dt: Single);
begin
  CCLog('tick2', []);
end;

procedure SchedulerUnscheduleAllUserLevel.tick3(dt: Single);
begin
  CCLog('tick3', []);
end;

procedure SchedulerUnscheduleAllUserLevel.tick4(dt: Single);
begin
  CCLog('tick4', []);
end;

function SchedulerUnscheduleAllUserLevel.title: string;
begin
  Result := 'Unschedule All user selectors';
end;

procedure SchedulerUnscheduleAllUserLevel.unscheduleAll(dt: Single);
begin
  CCDirector.sharedDirector().Scheduler.unscheduleAllWithMinPriority(kCCPriorityNonSystemMin);
end;

{ SchedulerSchedulesAndRemove }

procedure SchedulerSchedulesAndRemove.onEnter;
begin
  inherited onEnter();
  schedule(tick1, 0.5);
  schedule(tick2, 1.0);
  schedule(scheduleAndUnschedule, 4.0);
end;

procedure SchedulerSchedulesAndRemove.scheduleAndUnschedule(
  dt: Single);
begin
  unschedule(tick1);
  unschedule(tick2);
  unschedule(scheduleAndUnschedule);

  schedule(tick3, 1.0);
  schedule(tick4, 1.0);
end;

function SchedulerSchedulesAndRemove.subtitle: string;
begin
  Result := 'Will unschedule and schedule selectors in 4s. See console';
end;

procedure SchedulerSchedulesAndRemove.tick1(dt: Single);
begin
  CCLog('tick1', []);
end;

procedure SchedulerSchedulesAndRemove.tick2(dt: Single);
begin
  CCLog('tick2', []);
end;

procedure SchedulerSchedulesAndRemove.tick3(dt: Single);
begin
  CCLog('tick3', []);
end;

procedure SchedulerSchedulesAndRemove.tick4(dt: Single);
begin
  CCLog('tick4', []);
end;

function SchedulerSchedulesAndRemove.title: string;
begin
  Result := 'Schedule from Schedule';
end;

{ TestNode }

destructor TestNode.Destroy;
begin
  m_pString.release();
  inherited;
end;

procedure TestNode.initWithString(pStr: CCString; priority: Integer);
begin
  m_pString := pStr;
  m_pString.retain();
  scheduleUpdateWithPriority(priority);
end;

{ SchedulerUpdate }

procedure SchedulerUpdate.onEnter;
var
  a, b, c, d, e, f: TestNode;
  pStr: CCString;
begin
  inherited onEnter();

  d := TestNode.Create();
  pStr := CCString.Create('---');
  d.initWithString(pStr, 50);
  pStr.release();
  addChild(d);
  d.release();

  b := TestNode.Create();
  pStr := CCString.Create('3rd');
  b.initWithString(pStr, 0);
  pStr.release();
  addChild(b);
  b.release();

  a := TestNode.Create();
  pStr := CCString.Create('1st');
  a.initWithString(pStr, -10);
  pStr.release();
  addChild(a);
  a.release();

  c := TestNode.Create();
  pStr := CCString.Create('4th');
  c.initWithString(pStr, 10);
  pStr.release();
  addChild(c);
  c.release();

  e := TestNode.Create();
  pStr := CCString.Create('5th');
  e.initWithString(pStr, 20);
  pStr.release();
  addChild(e);
  e.release();

  f := TestNode.Create();
  pStr := CCString.Create('2nd');
  f.initWithString(pStr, -5);
  pStr.release();
  addChild(f);
  f.release();

  schedule(removeUpdates, 4.0);
end;

procedure SchedulerUpdate.removeUpdates(dt: Single);
var
  pArray: CCArray;
  pNode: CCNode;
  i: Integer;
begin
  pArray := Children;
  if (pArray <> nil) and (pArray.count() > 0) then
  begin
    for i := 0 to pArray.count()-1 do
    begin
      pNode := CCNode(pArray.objectAtIndex(i));
      if pNode = nil then
        Break;

      pNode.unscheduleAllSelectors();
    end;  
  end;
end;

function SchedulerUpdate.subtitle: string;
begin
  Result := '3 scheduled updates. Priority should work. Stops in 4s. See console';
end;

function SchedulerUpdate.title: string;
begin
  Result := 'Schedule update with priority';
end;

{ SchedulerDelayAndRepeat }

procedure SchedulerDelayAndRepeat.onEnter;
begin
  inherited onEnter();
  schedule(update, 0, 4, 3.0);
  CCLog('update is scheduled should begin after 3 seconds', []);
end;

function SchedulerDelayAndRepeat.subtitle: string;
begin
  Result := 'After 5 x executed, method unscheduled. See console';
end;

function SchedulerDelayAndRepeat.title: string;
begin
  Result := 'Schedule with delay of 3 sec, repeat 4 times';
end;

procedure SchedulerDelayAndRepeat.update(dt: Single);
begin
  CCLog('update called:%f', [dt]);
end;

{ SchedulerUpdateAndCustom }

procedure SchedulerUpdateAndCustom.onEnter;
begin
  inherited onEnter();

  scheduleUpdate();
  schedule(tick);
  schedule(stopSelectors, 0.4);
end;

procedure SchedulerUpdateAndCustom.stopSelectors(dt: Single);
begin
  unscheduleAllSelectors();
end;

function SchedulerUpdateAndCustom.subtitle: string;
begin
  Result := 'Update + custom selector at the same time. Stops in 4s. See console';
end;

procedure SchedulerUpdateAndCustom.update(dt: Single);
begin
  CCLOG('update called:%f', [dt]);
end;

procedure SchedulerUpdateAndCustom.tick(dt: Single);
begin
  CCLOG('custom selector called:%f', [dt]);
end;

function SchedulerUpdateAndCustom.title: string;
begin
  Result := 'Schedule Update + custom selector';
end;

{ SchedulerUpdateFromCustom }

procedure SchedulerUpdateFromCustom.onEnter;
begin
  inherited onEnter();
  schedule(schedUpdate, 2.0);
end;

procedure SchedulerUpdateFromCustom.schedUpdate(dt: Single);
begin
  unschedule(schedUpdate);
  scheduleUpdate();
  schedule(stopUpdate, 2.0);
end;

procedure SchedulerUpdateFromCustom.stopUpdate(dt: Single);
begin
  unscheduleUpdate();
  unschedule(stopUpdate);
end;

function SchedulerUpdateFromCustom.subtitle: string;
begin
  Result := 'Update schedules in 2 secs. Stops 2 sec later. See console';
end;

function SchedulerUpdateFromCustom.title: string;
begin
  Result := 'Schedule Update in 2 sec';
end;

procedure SchedulerUpdateFromCustom.update(dt: Single);
begin
  CCLOG('update called:%f', [dt]);
end;

{ SchedulerTimeScale }

procedure SchedulerTimeScale.onEnter;
var
  s: CCSize;
  jump1, jump2, rot1, rot2: CCFiniteTimeAction;
  seq3_1, seq3_2, spawn: CCFiniteTimeAction;
  action, action2, action3: CCRepeat;
  grossini, tamara, kathia: CCSprite;
  emitter: CCParticleSystem;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  
  jump1 := CCJumpBy._create(4, ccp(-s.width+80, 0), 100, 4);
  jump2 := jump1.reverse;
  rot1 := CCRotateBy._create(4, 720);
  rot2 := rot1.reverse;

  seq3_1 := CCSequence._create([jump2, jump1]);
  seq3_2 := CCSequence._create([rot1, rot2]);
  spawn := CCSpawn._create([seq3_1, seq3_2]);

  action := CCRepeat._create(spawn, 50);
  action2 := CCRepeat(action.copy.autorelease);
  action3 := CCRepeat(action.copy.autorelease);

  grossini := CCSprite._create('Images/grossini.png');
  tamara := CCSprite._create('Images/grossinis_sister1.png');
  kathia := CCSprite._create('Images/grossinis_sister2.png');

  grossini.setPosition(40, 80);
  tamara.setPosition(40, 80);
  kathia.setPosition(40, 80);

  addChild(grossini);
  addChild(tamara);
  addChild(kathia);

  grossini.runAction(CCSpeed._create(action, 0.5));
  tamara.runAction(CCSpeed._create(action2, 1.5));
  kathia.runAction(CCSpeed._create(action3, 1));

  emitter := CCParticleFireworks._create;
  emitter.setTexture(CCTextureCache.sharedTextureCache.addImage(s_stars1));
  addChild(emitter);

  m_pSliderCtl := sliderCtl;
  m_pSliderCtl.setPosition(s.width/2, s.height/3);

  addChild(m_pSliderCtl);
end;

procedure SchedulerTimeScale.onExit;
begin
  CCDirector.sharedDirector.Scheduler.setTimeScale(1);
  inherited;
end;

procedure SchedulerTimeScale.sliderAction(pSender: CCObject;
  controlEvent: CCControlEvent);
var
  pSliderCtl: CCControlSlider;
  scale: Single;
begin
  pSliderCtl := CCControlSlider(pSender);
  scale := pSliderCtl.Value;
  CCDirector.sharedDirector.Scheduler.setTimeScale(scale);
end;

function SchedulerTimeScale.sliderCtl: CCControlSlider;
var
  slider: CCControlSlider;
begin
  slider := CCControlSlider._create('extensions/sliderTrack2.png', 'extensions/sliderProgress2.png', 'extensions/sliderThumb.png');
  slider.addTargetWithActionForControlEvents(Self, sliderAction, CCControlEventValueChanged);
  slider.setMinimumValue(-3);
  slider.setMaximumValue(3);
  slider.setValue(1);
  Result := slider;
end;

function SchedulerTimeScale.subtitle: string;
begin
  Result := 'Fast-forward and rewind using scheduler.timeScale';
end;

function SchedulerTimeScale.title: string;
begin
  Result := 'Scheduler timeScale Test';
end;

{ TwoSchedulers }

destructor TwoSchedulers.Destroy;
var
  defaultScheduler: CCScheduler;
begin
  defaultScheduler := CCDirector.sharedDirector.Scheduler;
  defaultScheduler.unscheduleAllForTarget(sched1);
  defaultScheduler.unscheduleAllForTarget(sched2);
  sliderCtl1.release;
  sliderCtl2.release;
  sched1.release;
  sched2.release;
  actionManager1.release;
  actionManager2.release;
  inherited;
end;

procedure TwoSchedulers.onEnter;
var
  s: CCSize;
  jump1, jump2, seq: CCFiniteTimeAction;
  action: CCRepeatForever;
  grossini: CCSprite;
  defaultScheduler: CCScheduler;
  i: Integer;
  sprite: CCSprite;
begin
  inherited;

  s := CCDirector.sharedDirector.getWinSize;

  jump1 := CCJumpBy._create(4, ccp(0, 0), 100, 4);
  jump2 := jump1.reverse;

  seq := CCSequence._create([jump2, jump1]);
  action := CCRepeatForever._create(CCActionInterval(seq));

  grossini := CCSprite._create('Images/grossini.png');
  addChild(grossini);
  grossini.setPosition(s.width/2, 100);
  grossini.runAction(CCAction(action.copy.autorelease));

  defaultScheduler := CCDirector.sharedDirector.Scheduler;

  sched1 := CCScheduler.Create;
  defaultScheduler.scheduleUpdateForTarget(sched1, 0, False);

  actionManager1 := CCActionManager.Create;
  sched1.scheduleUpdateForTarget(actionManager1, 0, False);

  for i := 0 to 9 do
  begin
    sprite := CCSprite._create('Images/grossinis_sister1.png');
    sprite.ActionManager := actionManager1;
    addChild(sprite);
    sprite.setPosition(30+15*i, 100);
    sprite.runAction(CCAction(action.copy.autorelease));
  end;

  sched2 := CCScheduler.Create;
  defaultScheduler.scheduleUpdateForTarget(sched2, 0, False);

  actionManager2 := CCActionManager.Create;
  sched2.scheduleUpdateForTarget(actionManager2, 0, False);

  for i := 0 to 9 do
  begin
    sprite := CCSprite._create('Images/grossinis_sister2.png');
    sprite.ActionManager := actionManager2;
    addChild(sprite);
    sprite.setPosition(s.width-30-15*i, 100);
    sprite.runAction(CCAction(action.copy.autorelease));
  end;

  sliderCtl1 := sliderCtl();
  addChild(sliderCtl1);
  sliderCtl1.retain;
  sliderCtl1.setPosition(s.width/4, s.height-20);

  sliderCtl2 := sliderCtl();
  addChild(sliderCtl2);
  sliderCtl2.retain;
  sliderCtl2.setPosition(s.width/4*3, s.height-20);
end;

procedure TwoSchedulers.sliderAction(pSender: CCObject;
  controlEvent: CCControlEvent);
var
  scale: Single;
  slider: CCControlSlider;
begin
  slider := CCControlSlider(pSender);
  scale := slider.Value;

  if pSender = sliderCtl1 then
    sched1.setTimeScale(scale)
  else
    sched2.setTimeScale(scale);
end;

function TwoSchedulers.sliderCtl: CCControlSlider;
var
  slider: CCControlSlider;
begin
  slider := CCControlSlider._create('extensions/sliderTrack2.png', 'extensions/sliderProgress2.png', 'extensions/sliderThumb.png');
  slider.addTargetWithActionForControlEvents(Self, sliderAction, CCControlEventValueChanged);
  slider.setMinimumValue(0);
  slider.setMaximumValue(2);
  slider.setValue(1);
  Result := slider;
end;

function TwoSchedulers.subtitle: string;
begin
  Result := 'Three schedulers. 2 custom + 1 default. Two different time scales';
end;

function TwoSchedulers.title: string;
begin
  Result := 'Two custom schedulers';
end;

end.
