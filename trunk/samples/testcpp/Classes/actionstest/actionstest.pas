unit actionstest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSet, Cocos2dx.CCSprite, Cocos2dx.CCNode;

type
  ActionsTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  ActionsDemo = class(CCLayer)
  protected
    m_strTitle: string;
    m_grossini, m_tamara, m_kathia: CCSprite;
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; dynamic;
    function subtitle(): string; dynamic;

    procedure centerSprites(numberOfSprites: Cardinal);
    procedure alignSpritesLeft(numberOfSprites: Cardinal);

    procedure onExit(); override;
    procedure onEnter(); override;

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  end;

  ActionManual = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionMove = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionBlink = class(ActionsDemo)
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionScale = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionRotate = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionJump = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionSequence = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionSequence2 = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;

    procedure callback1();
    procedure callback2(sender: CCObject);
    procedure callback3(sender: CCObject; data: Pointer);
  end;

  ActionReverse = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionRepeat = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionReverseSequence = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionReverseSequence2 = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionRotateToRepeat = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionRotateJerk = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionFollow = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionBezier = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionSkew = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionSkewRotateScale = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionSpawn = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionDelayTime = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionOrbit = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionTint = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionFade = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
  end;

  ActionTargeted = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
    function title(): string; override;
  end;

  Issue1288 = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
    function title(): string; override;
  end;

  Issue1288_2 = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
    function title(): string; override;
  end;

  ActionAnimate = class(ActionsDemo)
  public
    procedure onEnter(); override;
    procedure onExit(); override;
    function subtitle(): string; override;
    function title(): string; override;
  end;

  PauseResumeActions = class(ActionsDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure onEnter(); override;
    function subtitle(): string; override;
    function title(): string; override;
    procedure pause(dt: Single);
    procedure resume(dt: Single);
  private
    m_pPausedTargets: CCSet;
  end;

  ActionCallFunc = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;

    procedure callback1();
    procedure callback2(pTarget: CCObject);
    procedure callback3(pTarget: CCObject; data: Pointer);
  end;

  ActionCallFuncND = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
    function title(): string; override;
    procedure removeFromParentAndCleanup(pNode: CCObject; data: Pointer);
  end;

  ActionRepeatForever = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function subtitle(): string; override;
    procedure repeatforever(pNode: CCObject);
  end;

  Issue1305 = class(ActionsDemo)
  public
    procedure onEnter(); override;
    procedure onExit(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure addSprite(dt: Single);
    procedure log(pSender: CCObject);
  private
    m_pSpriteTmp: CCSprite;
  end;

  Issue1305_2 = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure log1();
    procedure log2();
    procedure log3();
    procedure log4();
  end;

  Issue1327 = class(ActionsDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure logSprRotation(pSender: CCObject);
  end;

  ActionCardinalSpline = class(ActionsDemo)
  public
    function title(): string; override;
  end;

  ActionCatmullRom = class(ActionsDemo)
  public
    function title(): string; override;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCTypes, Cocos2dx.CCAnimation, Cocos2dx.CCAnimationCache,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, Cocos2dx.CCCommon, testResource,
  Cocos2dx.CCPlatformMacros,
  Cocos2dx.CCAction, Cocos2dx.CCActionInterval,
  Cocos2dx.CCActionInstant, Cocos2dx.CCActionCamera;

var s_nActionIdx: Integer = -1;
const ACTION_LAYER_COUNT = 36;

type actiontype =
(
	ACTION_ORBIT_LAYER,
	ACTION_TINT_LAYER,
	ACTION_FADE_LAYER,
    ACTION_MANUAL_LAYER,
	ACTION_CALLFUNCND_LAYER,
    ACTION_MOVE_LAYER,
    ACTION_SCALE_LAYER,
    ACTION_ROTATE_LAYER,
    ACTION_SKEW_LAYER,
    ACTION_SKEWROTATE_LAYER,
    ACTION_JUMP_LAYER,
    ACTION_CARDINALSPLINE_LAYER,
    ACTION_CATMULLROM_LAYER,
    ACTION_BEZIER_LAYER,
    ACTION_BLINK_LAYER,
    ACTION_ANIMATE_LAYER,
    ACTION_SEQUENCE_LAYER,
    ACTION_SEQUENCE2_LAYER,
    ACTION_SPAWN_LAYER,
    ACTION_REVERSE,
    ACTION_DELAYTIME_LAYER,
    ACTION_REPEAT_LAYER,
    ACTION_REPEATEFOREVER_LAYER,
    ACTION_ROTATETOREPEATE_LAYER,
    ACTION_ROTATEJERK_LAYER,
    ACTION_CALLFUNC_LAYER,
    ACTION_REVERSESEQUENCE_LAYER,
    ACTION_REVERSESEQUENCE2_LAYER,
    ACTION_FLLOW_LAYER,
    ACTION_TARGETED_LAYER,
    PAUSERESUMEACTIONS_LAYER,
    ACTION_ISSUE1305_LAYER,
    ACTION_ISSUE1305_2_LAYER,
    ACTION_ISSUE1288_LAYER,
    ACTION_ISSUE1288_2_LAYER,
    ACTION_ISSUE1327_LAYER
);

function CreateLayer(nIndex: actiontype): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    ACTION_MANUAL_LAYER: bRet := ActionManual.Create;
    ACTION_MOVE_LAYER: bRet := ActionMove.Create;
    ACTION_SCALE_LAYER: bRet := ActionScale.Create;
    ACTION_ROTATE_LAYER: bret := ActionRotate.Create;
    ACTION_SKEW_LAYER: bRet := ActionSkew.Create;
    ACTION_SKEWROTATE_LAYER: bRet := ActionSkewRotateScale.Create;
    ACTION_JUMP_LAYER: bRet := ActionJump.Create;
    ACTION_BEZIER_LAYER: bRet := ActionBezier.Create;
    ACTION_BLINK_LAYER: bRet := ActionBlink.Create;
    ACTION_FADE_LAYER: bRet := ActionFade.Create;
    ACTION_TINT_LAYER: bRet := ActionTint.Create;
    ACTION_ANIMATE_LAYER: bRet := ActionAnimate.Create;
    ACTION_SEQUENCE_LAYER: bRet := ActionSequence.Create;
    ACTION_SEQUENCE2_LAYER: bRet := ActionSequence2.Create;
    ACTION_SPAWN_LAYER: bRet := ActionSpawn.Create;
    ACTION_REVERSE: bRet := ActionReverse.Create;
    ACTION_DELAYTIME_LAYER: bRet := ActionDelayTime.Create;
    ACTION_REPEAT_LAYER: bRet := ActionRepeat.Create;
    ACTION_REPEATEFOREVER_LAYER: bRet := ActionRepeatForever.Create;
    ACTION_ROTATETOREPEATE_LAYER: bRet := ActionRotateToRepeat.Create;
    ACTION_ROTATEJERK_LAYER: bRet := ActionRotateJerk.Create;
    ACTION_CALLFUNC_LAYER: bRet := ActionCallFunc.Create;
    ACTION_CALLFUNCND_LAYER: bRet := ActionCallFuncND.Create;
    ACTION_REVERSESEQUENCE_LAYER: bRet := ActionReverseSequence.Create;
    ACTION_REVERSESEQUENCE2_LAYER: bRet := ActionReverseSequence2.Create;
    ACTION_ORBIT_LAYER: bRet := ActionOrbit.Create;
    ACTION_FLLOW_LAYER: bRet := ActionFollow.Create;
    ACTION_TARGETED_LAYER: bRet := ActionTargeted.Create;
    ACTION_ISSUE1305_LAYER: bRet := Issue1305.Create;

    ACTION_ISSUE1305_2_LAYER: bRet := Issue1305_2.Create;
    ACTION_ISSUE1288_LAYER: bRet := Issue1288.Create;
    ACTION_ISSUE1288_2_LAYER: bRet := Issue1288_2.Create;
    ACTION_ISSUE1327_LAYER: bRet := Issue1327.Create;
    ACTION_CARDINALSPLINE_LAYER: bRet := ActionCardinalSpline.Create;
    ACTION_CATMULLROM_LAYER: bRet := ActionCatmullRom.Create;
    PAUSERESUMEACTIONS_LAYER: bRet := PauseResumeActions.Create;
  end;

  Result := bRet;
end;

function NextAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(s_nActionIdx);
  s_nActionIdx := s_nActionIdx mod ACTION_LAYER_COUNT;

  pLayer := CreateLayer(actiontype(s_nActionIdx));
  pLayer.autorelease();

  Result := pLayer;
end;

function BackAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(s_nActionIdx);
  total := ACTION_LAYER_COUNT;
  if s_nActionIdx < 0 then
    s_nActionIdx := s_nActionIdx + total;

  pLayer := CreateLayer(actiontype(s_nActionIdx));
  pLayer.autorelease();

  Result := pLayer;
end;

function RestartAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := CreateLayer(actiontype(s_nActionIdx));
  pLayer.autorelease();

  Result := pLayer;
end;

{ ActionsTestScene }

procedure ActionsTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := NextAction();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ ActionsDemo }

procedure ActionsDemo.alignSpritesLeft(numberOfSprites: Cardinal);
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();

    if numberOfSprites = 1 then
    begin
        m_tamara.setVisible(false);
        m_kathia.setVisible(false);
        m_grossini.setPosition(CCPointMake(60, s.height/2));
    end else if numberOfSprites = 2 then
    begin
        m_kathia.setPosition( CCPointMake(60, s.height/3));
        m_tamara.setPosition( CCPointMake(60, 2*s.height/3));
        m_grossini.setVisible( false );
    end else if numberOfSprites = 3 then
    begin
        m_grossini.setPosition( CCPointMake(60, s.height/2));
        m_tamara.setPosition( CCPointMake(60, 2*s.height/3));
        m_kathia.setPosition( CCPointMake(60, s.height/3));
    end;
end;

procedure ActionsDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionsTestScene.Create();
  s.addChild(BackAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure ActionsDemo.centerSprites(numberOfSprites: Cardinal);
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();

  if numberOfSprites = 0 then
  begin
    m_tamara.setVisible(False);
    m_kathia.setVisible(False);
    m_grossini.setVisible(False);
  end else if numberOfSprites = 1 then
  begin
    m_tamara.setVisible(False);
    m_kathia.setVisible(False);
    m_grossini.setPosition( CCPointMake(s.width/2, s.height/2) );
  end else if numberOfSprites = 2 then
  begin
    m_tamara.setPosition( CCPointMake(2*s.width/3, s.height/2) );
    m_kathia.setPosition( CCPointMake(s.width/3, s.height/2) );
    m_grossini.setVisible(False);
  end else if numberOfSprites = 3 then
  begin
    m_grossini.setPosition( CCPointMake(s.width/2, s.height/2));
    m_tamara.setPosition( CCPointMake(s.width/4, s.height/2));
    m_kathia.setPosition( CCPointMake(3 * s.width/4, s.height/2));
  end;     
end;

constructor ActionsDemo.Create;
begin
  inherited Create();
end;

destructor ActionsDemo.Destroy;
begin

  inherited;
end;

procedure ActionsDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionsTestScene.Create();
  s.addChild(NextAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure ActionsDemo.onEnter;
var
  s: CCSize;
  label1, label2: CCLabelTTF;
  strSubtitle: string;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize;

  m_grossini := CCSprite._create(s_pPathGrossini);
  m_grossini.retain();

  m_tamara := CCSprite._create(s_pPathSister1);
  m_tamara.retain();

  m_kathia := CCSprite._create(s_pPathSister2);
  m_kathia.retain();

  addChild(m_grossini, 1);
  addChild(m_tamara, 2);
  addChild(m_kathia, 3);

  m_grossini.setPosition( CCPointMake(s.width/2, s.height/3) );
  m_tamara.setPosition( CCPointMake(s.width/2, 2*s.height/3) );
  m_kathia.setPosition( CCPointMake(s.width/2, s.height/2) );

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

procedure ActionsDemo.onExit;
begin
  m_grossini.release();
  m_tamara.release();
  m_kathia.release();
  inherited;
end;

procedure ActionsDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionsTestScene.Create();
  s.addChild(RestartAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function ActionsDemo.subtitle: string;
begin
  Result := '';
end;

function ActionsDemo.title: string;
begin
  Result := 'ActionsTest';
end;

{ ActionManual }

procedure ActionManual.onEnter;
var
  s: CCSize;
begin
  inherited;

  s := CCDirector.sharedDirector().getWinSize();

  m_tamara.ScaleX := 2.5;
  m_tamara.ScaleY := -1;
  m_tamara.setPosition(100, 70);
  m_tamara.setOpacity(128);

  m_grossini.setRotation(120);
  m_grossini.setPosition(s.width/2, s.height/2);
  m_grossini.setColor(ccc3(255, 0, 0));

  m_kathia.setPosition(s.width-100, s.height/2);
  m_kathia.setColor(ccBLUE);
end;

function ActionManual.subtitle: string;
begin
  Result := 'Manual Transformation';
end;

{ ActionMove }

procedure ActionMove.onEnter;
var
  actionTo, actionBy: CCActionInterval;
  actionbyBack: CCFiniteTimeAction;
  s: CCSize;
begin
  inherited;
  centerSprites(3);

  s := CCDirector.sharedDirector().getWinSize();

  actionTo := CCMoveTo._create(2, CCPointMake(s.width-40, s.height-40));
  actionBy := CCMoveBy._create(2, CCPointMake(80, 80));
  actionbyBack := actionBy.reverse();

  m_tamara.runAction(actionTo);
  m_grossini.runAction(CCSequence._create([actionBy, actionbyBack]));
  m_kathia.runAction(CCMoveTo._create(1, CCPointMake(40, 40)));
end;

function ActionMove.subtitle: string;
begin
  Result := 'MoveTo / MoveBy';
end;

{ ActionScale }

procedure ActionScale.onEnter;
var
  actionTo, actionBy, actionBy2: CCActionInterval;
begin
  inherited;
  centerSprites(3);

  actionTo := CCScaleTo._create(2.0, 0.5);
  actionBy := CCScaleBy._create(2.0, 1.0, 10.0);
  actionBy2 := CCScaleBy._create(2.0, 5.0, 1.0);

  m_grossini.runAction(actionTo);
  m_tamara.runAction(CCSequence._create([actionBy, actionBy.reverse()]));
  m_kathia.runAction(CCSequence._create([actionBy2, actionBy2.reverse()]));
end;

function ActionScale.subtitle: string;
begin
  Result := 'ScaleTo / ScaleBy';
end;

{ ActionRotate }

procedure ActionRotate.onEnter;
var
  actionTo, actionTo2, actionTo0, actionBy: CCActionInterval;
  actionByBack: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(3);

  actionTo := CCRotateTo._create(2, 45);
  actionTo2 := CCRotateTo._create(2, -45);
  actionTo0 := CCRotateTo._create(2, 0);
  m_tamara.runAction(CCSequence._create([actionTo, actionTo0]));

  actionBy := CCRotateBy._create(2, 360);
  actionByBack := actionBy.reverse();
  m_grossini.runAction(CCSequence._create([actionBy, actionByBack]));

  m_kathia.runAction(CCSequence._create([actionTo2,CCActionInterval(actionTo0.copy().autorelease())]));
end;

function ActionRotate.subtitle: string;
begin
  Result := 'RotateTo / RotateBy';
end;

{ ActionJump }

procedure ActionJump.onEnter;
var
  actionTo, actionBy, actionUp: CCActionInterval;
  actionByBack: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(3);

  actionTo := CCJumpTo._create(2, CCPointMake(300, 300), 50, 4);
  actionBy := CCJumpBy._create(2, CCPointMake(300, 0), 50, 4);
  actionUp := CCJumpBy._create(2, CCPointMake(0, 0), 80, 4);
  actionByBack := actionBy.reverse();

  m_tamara.runAction(actionTo);
  m_grossini.runAction(CCSequence._create([actionBy, actionByBack]));
  m_kathia.runAction(CCRepeatForever._create(actionUp));
end;

function ActionJump.subtitle: string;
begin
  Result := 'JumpTo / JumpBy';
end;

{ ActionSequence }

procedure ActionSequence.onEnter;
var
  action: CCFiniteTimeAction;
begin
  inherited;
  alignSpritesLeft(1);

  action := CCSequence._create([CCMoveBy._create(2, CCPointMake(240, 0)),
    CCRotateBy._create(2, 540)]);
  m_grossini.runAction(action);
end;

function ActionSequence.subtitle: string;
begin
  Result := 'Sequence: Move + Rotate';
end;

{ ActionReverse }

procedure ActionReverse.onEnter;
var
  jump: CCActionInterval;
  action: CCFiniteTimeAction;
begin
  inherited;
  alignSpritesLeft(1);
  jump := CCJumpBy._create(2, CCPointMake(300, 0), 50, 4);
  action := CCSequence._create([jump, jump.reverse()]);
  m_grossini.runAction(action);
end;

function ActionReverse.subtitle: string;
begin
  Result := 'Reverse an action';
end;

{ ActionRepeat }

procedure ActionRepeat.onEnter;
var
  a1, action1: CCActionInterval;
  action2: CCAction;
begin
  inherited;
  alignSpritesLeft(2);

  a1 := CCMoveBy._create(1, CCPointMake(150, 0));
  action1 := CCRepeat._create( CCSequence._create( [CCPlace._create(CCPointMake(60, 60)), a1] ), 3 );
  action2 := CCRepeatForever._create( CCActionInterval(CCSequence._create( [CCActionInterval(a1.copy().autorelease()), a1.reverse()] )));
  m_kathia.runAction(action1);
  m_tamara.runAction(action2);
end;

function ActionRepeat.subtitle: string;
begin
  Result := 'Repeat / RepeatForever actions';
end;

{ ActionReverseSequence }

procedure ActionReverseSequence.onEnter;
var
  move1, move2: CCActionInterval;
  action: CCFiniteTimeAction;
  seq: CCFiniteTimeAction;
begin
  inherited;
  alignSpritesLeft(1);
  move1 := CCMoveBy._create(1, CCPointMake(250, 0));
  move2 := CCMoveBy._create(1, CCPointMake(0, 50));
  seq := CCSequence._create([move1, move2, move1.reverse()]);
  action := CCSequence._create([seq, seq.reverse]);
  m_grossini.runAction(action);
end;

function ActionReverseSequence.subtitle: string;
begin
  Result := 'Reverse a sequence';
end;

{ ActionRotateToRepeat }

procedure ActionRotateToRepeat.onEnter;
var
  act1, act2, seq: CCActionInterval;
  rep1: CCAction;
  rep2: CCActionInterval;
begin
  inherited;
  centerSprites(2);
  act1 := CCRotateTo._create(1, 90);
  act2 := CCRotateTo._create(1, 0);
  seq := CCActionInterval(CCSequence._create([act1, act2]));
  rep1 := CCRepeatForever._create(seq);
  rep2 := CCRepeat._create(CCFiniteTimeAction(seq.copy().autorelease()), 10);

  m_tamara.runAction(rep1);
  m_kathia.runAction(rep2);
end;

function ActionRotateToRepeat.subtitle: string;
begin
  Result := 'Repeat/RepeatForever + RotateTo';
end;

{ ActionRotateJerk }

procedure ActionRotateJerk.onEnter;
var
  seq: CCFiniteTimeAction;
  rep1: CCActionInterval;
  rep2: CCAction;
begin
  inherited;
  centerSprites(2);

  seq := CCSequence._create([CCRotateTo._create(0.5, -20), CCRotateTo._create(0.5, 20)]);
  rep1 := CCRepeat._create(seq, 10);
  rep2 := CCRepeatForever._create(CCActionInterval(seq.copy().autorelease()));

  m_tamara.runAction(rep1);
  m_kathia.runAction(rep2);
end;

function ActionRotateJerk.subtitle: string;
begin
  Result := 'RepeatForever / Repeat + Rotate';
end;

{ ActionFollow }

procedure ActionFollow.onEnter;
var
  s: CCSize;
  move: CCActionInterval;
  seq, move_back: CCFiniteTimeAction;
  rep: CCAction;
begin
  inherited;
  centerSprites(1);

  s := CCDirector.sharedDirector().getWinSize();

  m_grossini.setPosition( CCPointMake(-200, s.height/2));
  move := CCMoveBy._create(2, CCPointMake(s.width*3, 0));
  move_back := move.reverse();
  seq := CCSequence._create([move, move_back]);
  rep := CCRepeatForever._create(CCActionInterval(seq));

  m_grossini.runAction(rep);

  Self.runAction(CCFollow._create(m_grossini, CCRectMake(0, 0, s.width*2 - 100, s.height)));
end;

function ActionFollow.subtitle: string;
begin
  Result := 'Follow action';
end;

{ Issue1288 }

procedure Issue1288.onEnter;
var
  spr: CCSprite;
  act1, act2: CCMoveBy;
  act3: CCFiniteTimeAction;
  act4: CCRepeat;
begin
  inherited;
  centerSprites(0);

  spr := CCSprite._create('Images/grossini.png');
  spr.setPosition( ccp(100, 100));
  addChild(spr);

  act1 := CCMoveBy._create(0.5, ccp(100, 0));
  act2 := CCMoveBy(act1.reverse());
  act3 := CCSequence._create([act1, act2]);
  act4 := CCRepeat._create(act3, 2);

  spr.runAction(act4);
end;

function Issue1288.subtitle: string;
begin
  Result := 'Sprite should end at the position where it started.';
end;

function Issue1288.title: string;
begin
  Result := 'Issue 1288';
end;

{ Issue1288_2 }

procedure Issue1288_2.onEnter;
var
  spr: CCSprite;
  act1: CCMoveBy;
begin
  inherited;
  centerSprites(0);

  spr := CCSprite._create('Images/grossini.png');
  spr.setPosition(ccp(100, 100));
  addChild(spr);

  act1 := CCMoveBy._create(0.5, ccp(100, 0));
  spr.runAction(CCRepeat._create(act1, 1));
end;

function Issue1288_2.subtitle: string;
begin
  Result := 'Sprite should move 100 pixels, and stay there';
end;

function Issue1288_2.title: string;
begin
  Result := 'Issue 1288 #2';
end;

{ PauseResumeActions }

constructor PauseResumeActions.Create;
begin
  inherited;
end;

destructor PauseResumeActions.Destroy;
begin
  CC_SAFE_RELEASE(m_pPausedTargets);
  inherited;
end;

procedure PauseResumeActions.onEnter;
begin
  inherited;
  centerSprites(2);

  m_tamara.runAction(CCRepeatForever._create(CCRotateBy._create(3, 360)));
  m_grossini.runAction(CCRepeatForever._create(CCRotateBy._create(3, -360)));
  m_kathia.runAction(CCRepeatForever._create(CCRotateBy._create(3, 360)));

  schedule(pause, 3, 0, 0);
  schedule(resume, 5, 1, 0);
end;

procedure PauseResumeActions.pause(dt: Single);
var
  director: CCDirector;
begin
  CCLog('pausing', []);
  director := CCDirector.sharedDirector();

  CC_SAFE_RELEASE(m_pPausedTargets);
  m_pPausedTargets := director.ActionManager.pauseAllRunningActions();
  CC_SAFE_RETAIN(m_pPausedTargets);
end;

procedure PauseResumeActions.resume(dt: Single);
begin
  CCLog('resuming', []);
  CCDirector.sharedDirector().ActionManager.resumeTargets(m_pPausedTargets);
end;

function PauseResumeActions.subtitle: string;
begin
  Result := 'All actions pause at 3s and resume at 5s';
end;

function PauseResumeActions.title: string;
begin
  Result := 'PauseResumeActions';
end;

{ ActionBezier }

procedure ActionBezier.onEnter;
var
  s: CCSize;
  bezier, bezier2: ccBezierConfig;
  bezierForward, bezierBack: CCFiniteTimeAction;
  rep: CCAction;

  bezierTo1, bezierTo2: CCActionInterval;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  centerSprites(3);

  bezier.controlPoint_1 := CCPointMake(0, s.height/2);
  bezier.controlPoint_2 := CCPointMake(300, -s.height/2);
  bezier.endPosition := CCPointMake(300, 100);

  bezierForward := CCBezierBy._create(3, bezier);
  bezierBack := bezierForward.reverse();
  rep := CCRepeatForever._create(  CCActionInterval(CCSequence._create(  [bezierForward, bezierBack] )) );

  m_tamara.setPosition(CCPointMake(80, 160));
  bezier2.controlPoint_1 := CCPointMake(100, s.height/2);
  bezier2.controlPoint_2 := CCPointMake(200, -s.height/2);
  bezier2.endPosition := CCPointMake(240, 160);

  bezierTo1 := CCBezierTo._create(2, bezier2);

  m_kathia.setPosition(CCPointMake(400, 160));
  bezierTo2 := CCBezierTo._create(2, bezier2);

  m_grossini.runAction(rep);
  m_tamara.runAction(bezierTo1);
  m_kathia.runAction(bezierTo2);
end;

function ActionBezier.subtitle: string;
begin
  Result := 'BezierBy / BezierTo';
end;

{ ActionSkew }

procedure ActionSkew.onEnter;
var
  actionTo, actionToBack, actionBy, actionBy2, actionByBack: CCActionInterval;
begin
  inherited;

  centerSprites(3);

  actionTo := CCSkewTo._create(2, 37.2, -37.2);
  actionToBack := CCSkewTo._create(2, 0, 0);
  actionBy := CCSkewBy._create(2, 0, -90);
  actionBy2 := CCSkewBy._create(2, 45, 45);
  actionByBack := CCActionInterval(actionBy.reverse());

  m_tamara.runAction( CCSequence._create([actionTo, actionToBack ]) );
  m_grossini.runAction( CCSequence._create([actionBy, actionByBack ]) );
  m_kathia.runAction( CCSequence._create([actionBy2, actionBy2.reverse()]) );
end;

function ActionSkew.subtitle: string;
begin
  Result := 'SkewTo / SkewBy';
end;

{ ActionSpawn }

procedure ActionSpawn.onEnter;
var
  action: CCAction;
begin
  inherited;
  alignSpritesLeft(1);

  action := CCSpawn._create( [CCJumpBy._create(2, CCPointMake(300, 0), 50, 4),
                              CCRotateBy._create(2, 720) ] );
  m_grossini.runAction(action);
end;

function ActionSpawn.subtitle: string;
begin
  Result := 'Spawn: Jump + Rotate';
end;

{ ActionTargeted }

procedure ActionTargeted.onEnter;
var
  jump1, jump2: CCJumpBy;
  rot1, rot2: CCRotateBy;
  t1, t2: CCTargetedAction;
  seq: CCSequence;
  always: CCRepeatForever;
begin
  inherited;
  centerSprites(2);

  jump1 := CCJumpBy._create(2, CCPointZero, 100, 3);
  jump2 := CCJumpBy(jump1.copy().autorelease());
  rot1 := CCRotateBy._create(1, 360);
  rot2 := CCRotateBy(rot1.copy().autorelease());

  t1 := CCTargetedAction._create(m_kathia, jump2);
  t2 := CCTargetedAction._create(m_kathia, rot2);

  seq := CCSequence(CCSequence._create( [jump1, t1, rot1, t2] ));
  always := CCRepeatForever._create(seq);

  m_tamara.runAction(always);
end;

function ActionTargeted.subtitle: string;
begin
  Result := 'Action that runs on another target. Useful for sequences';
end;

function ActionTargeted.title: string;
begin
  Result := 'ActionTargeted';
end;

{ ActionSkewRotateScale }

procedure ActionSkewRotateScale.onEnter;
var
  boxsize: CCSize;
  box, ul, ur: CCLayerColor;
  markrside: Single;
  actionTo, rotateTo, actionScaleTo, actionScaleToBack, rotateToBack, actionToBack: CCFiniteTimeAction;
begin
  inherited;
  m_tamara.removeFromParentAndCleanup(True);
  m_grossini.removeFromParentAndCleanup(True);
  m_kathia.removeFromParentAndCleanup(True);

  boxsize := CCSizeMake(100, 100);

  box := CCLayerColor._create(ccc4(255, 255, 0, 255));
  box.AnchorPoint := CCPointZero;
  box.setPosition(190, 110);
  box.ContentSize := boxsize;

  markrside := 10;
  ul := CCLayerColor._create(ccc4(255, 0, 0, 255));
  box.addChild(ul);
  ul.ContentSize := CCSizeMake(markrside, markrside);
  ul.setPosition(0, boxsize.height-markrside);
  ul.AnchorPoint := CCPointZero;

  uR := CCLayerColor._create(ccc4(0, 0, 255, 255));
  box.addChild(uR);
  uR.ContentSize := CCSizeMake(markrside, markrside);
  uR.setPosition(boxsize.width - markrside, boxsize.height-markrside);
  uR.AnchorPoint := CCPointZero;
  addChild(box);

  actionTo := CCSkewTo._create(2, 0, 2);
  rotateTo := CCRotateTo._create(2, 61);
  actionScaleTo := CCScaleTo._create(2, -0.44, 0.47);

  actionScaleToBack := CCScaleTo._create(2, 1, 1);
  rotateToBack := CCRotateTo._create(2, 0);
  actionToBack := CCSkewTo._create(2, 0, 0);

  box.runAction(CCSequence._create([actionTo, actionToBack]));
  box.runAction(CCSequence._create([rotateTo, rotateToBack]));
  box.runAction(CCSequence._create([actionScaleTo, actionScaleToBack]));
end;

function ActionSkewRotateScale.subtitle: string;
begin
  Result := 'Skew + Rotate + Scale';
end;

{ ActionDelayTime }

procedure ActionDelayTime.onEnter;
var
  move: CCActionInterval;
  action: CCFiniteTimeAction;
begin
  inherited;
  alignSpritesLeft(1);
  move := CCMoveBy._create(1, CCPointMake(150, 0));
  action := CCSequence._create([move, CCDelayTime._create(2), move]);
  m_grossini.runAction(action);
end;

function ActionDelayTime.subtitle: string;
begin
  Result := 'DelayTime: m + delay + m';
end;

{ ActionReverseSequence2 }

procedure ActionReverseSequence2.onEnter;
var
  move1, move2: CCActionInterval;
  tog1, tog2: CCToggleVisibility;
  seq: CCFiniteTimeAction;
  action: CCActionInterval;
  move_tamara,   move_tamara2: CCFiniteTimeAction;
  hide: CCActionInstant;
  seq_tamara, seq_back: CCFiniteTimeAction;
begin
  inherited;
  alignSpritesLeft(2);

  move1 := CCMoveBy._create(1, CCPointMake(250, 0));
  move2 := CCMoveBy._create(1, CCPointMake(0, 50));
  tog1 := CCToggleVisibility.Create;
  tog2 := CCToggleVisibility.Create;
  tog1.autorelease();
  tog2.autorelease();

  seq := CCSequence._create([move1, tog1, move2, move1.reverse()]);
  action := CCRepeat._create( CCSequence._create([seq, seq.reverse()]), 3 );

  m_kathia.runAction(action);

  move_tamara := CCMoveBy._create(1, CCPointMake(100, 0));
  move_tamara2 := CCMoveBy._create(1, CCPointMake(50, 0));
  hide := CCHide.Create;
  hide.autorelease;
  seq_tamara := CCSequence._create([move_tamara, hide, move_tamara2]);
  seq_back := seq_tamara.reverse();
  m_tamara.runAction( CCSequence._create([seq_tamara, seq_back]) );
end;

function ActionReverseSequence2.subtitle: string;
begin
  Result := 'Reverse sequence 2';
end;

{ ActionOrbit }

procedure ActionOrbit.onEnter;
var
  orbit1, orbit2, orbit3: CCActionInterval;
  action1, action2, action3, seq: CCFiniteTimeAction;
  move, move_back: CCActionInterval;
  rfe: CCAction;
begin
  inherited;
  centerSprites(3);

  orbit1 := CCOrbitCamera._create(2, 1, 0, 0, 180, 0, 0);
  action1 := CCSequence._create([orbit1, orbit1.reverse()]);

  orbit2 := CCOrbitCamera._create(2, 1, 0, 0, 180, -45, 0);
  action2 := CCSequence._create([orbit2, orbit2.reverse()]);

  orbit3 := CCOrbitCamera._create(2, 1, 0, 0, 180, 90, 0);
  action3 := CCSequence._create([orbit3, orbit3.reverse()]);

  m_kathia.runAction( CCRepeatForever._create( CCActionInterval(action1) ) );
  m_tamara.runAction( CCRepeatForever._create( CCActionInterval(action2) ) );
  m_grossini.runAction( CCRepeatForever._create( CCActionInterval(action3) ) );

  move := CCMoveBy._create(3, CCPointMake(100, -100));
  move_back := CCActionInterval(move.reverse());

  seq := CCSequence._create([move, move_back]);
  rfe := CCRepeatForever._create(CCActionInterval(seq));
  m_kathia.runAction(rfe);
  m_tamara.runAction(CCAction(rfe.copy().autorelease()));
  m_grossini.runAction(CCAction(rfe.copy().autorelease()));
end;

function ActionOrbit.subtitle: string;
begin
  Result := 'OrbitCamera action';
end;

{ ActionCallFunc }

procedure ActionCallFunc.callback1;
var
  s: CCSize;
  pLabel: CCLabelTTF;
begin
  s := CCDirector.sharedDirector().getWinSize();
  pLabel := CCLabelTTF._create('callback 1 called', 'Marker Felt', 16);
  pLabel.setPosition( CCPointMake(s.width/4*1, s.height/2) );
  addChild(pLabel);
end;

procedure ActionCallFunc.callback2(pTarget: CCObject);
var
  s: CCSize;
  pLabel: CCLabelTTF;
begin
  s := CCDirector.sharedDirector().getWinSize();
  pLabel := CCLabelTTF._create('callback 2 called', 'Marker Felt', 16);
  pLabel.setPosition( CCPointMake(s.width/4*2, s.height/2) );
  addChild(pLabel);
end;

procedure ActionCallFunc.callback3(pTarget: CCObject; data: Pointer);
var
  s: CCSize;
  pLabel: CCLabelTTF;
begin
  s := CCDirector.sharedDirector().getWinSize();
  pLabel := CCLabelTTF._create('callback 3 called', 'Marker Felt', 16);
  pLabel.setPosition( CCPointMake(s.width/4*3, s.height/2) );
  addChild(pLabel);
end;

procedure ActionCallFunc.onEnter;
var
  action, action2, action3: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(3);

  action := CCSequence._create( [CCMoveBy._create(2, CCPointMake(200, 0)),
    CCCallFunc._create(Self, callback1)  ]  );
  action2 := CCSequence._create( [CCScaleBy._create(3, 2),
    CCFadeOut._create(2),
    CCCallFuncN._create(Self, callback2) ] );
  action3 := CCSequence._create( [CCRotateBy._create(4, 360),
    CCFadeOut._create(2),
    CCCallFuncND._create(Self, callback3, Pointer(Self))  ] );

  m_grossini.runAction(action);
  m_tamara.runAction(action2);
  m_kathia.runAction(action3);
end;

function ActionCallFunc.subtitle: string;
begin
  Result := 'Callbacks: CallFunc and friends';
end;

{ ActionCallFuncND }

procedure ActionCallFuncND.onEnter;
var
  action: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(1);

  action := CCSequence._create([CCMoveBy._create(2.0, ccp(200, 0)),
    CCCallFuncND._create(Self, removeFromParentAndCleanup, Pointer(Self))  ]);

  m_grossini.runAction(action);
end;

procedure ActionCallFuncND.removeFromParentAndCleanup(pNode: CCObject;
  data: Pointer);
var
  bCleanUp: Boolean;
begin
  bCleanUp := data <> nil;
  m_grossini.removeFromParentAndCleanup(bCleanUp);
end;

function ActionCallFuncND.subtitle: string;
begin
  Result := 'CallFuncND + removeFromParentAndCleanup. Grossini dissapears in 2s';
end;

function ActionCallFuncND.title: string;
begin
  Result := 'CallFuncND + auto remove';
end;

{ ActionBlink }

procedure ActionBlink.onEnter;
var
  action1, action2: CCActionInterval;
begin
  inherited;
  centerSprites(2);
  
  action1 := CCBlink._create(2, 10);
  action2 := CCBlink._create(2, 5);

  m_tamara.runAction(action1);
  m_kathia.runAction(action2);
end;

function ActionBlink.subtitle: string;
begin
  Result := 'Blink';
end;

{ ActionFade }

procedure ActionFade.onEnter;
var
  action1, action1back: CCFiniteTimeAction;
  action2, action2back: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(2);

  m_tamara.setOpacity(0);
  action1 := CCFadeIn._create(1.0);
  action1back := CCFiniteTimeAction(action1.reverse());

  action2 := CCFadeOut._create(1.0);
  action2back := CCFiniteTimeAction(action2.reverse());

  m_tamara.runAction( CCSequence._create([action1, action1back]) );
  m_kathia.runAction( CCSequence._create([action2, action2back]) );
end;

function ActionFade.subtitle: string;
begin
  Result := 'FadeIn / FadeOut';
end;

{ ActionTint }

procedure ActionTint.onEnter;
var
  action1, action2, action2back: CCActionInterval;
begin
  inherited;
  centerSprites(2);

  action1 := CCTintTo._create(2, 255, 0, 255);
  action2 := CCTintBy._create(2, -127, -255, -127);
  action2back := CCActionInterval(action2.reverse() );

  m_tamara.runAction(action1);
  m_kathia.runAction( CCSequence._create([action2, action2back]) );
end;

function ActionTint.subtitle: string;
begin
  Result := 'TintTo / TintBy';
end;

{ ActionAnimate }

procedure ActionAnimate.onEnter;
var
  animation, animation2, animation3: CCAnimation;
  i: Integer;
  str: string;
  action, action2, action3: CCAnimate;
  cache: CCAnimationCache;
begin
  inherited;
  centerSprites(3);

  animation := CCAnimation._create;
  for i := 1 to 14 do
  begin
    str := Format('Images/grossini_dance_%.2d.png', [i]);
    animation.addSpriteFrameWithFileName(str);
  end;
  animation.DelayPerUnit := 2.8/14;
  animation.RestoreOriginalFrame := True;

  action := CCAnimate._create(animation);
  m_grossini.runAction(CCSequence._create([action, action.reverse]));

  cache := CCAnimationCache.sharedAnimationCache;
  cache.addAnimationsWithFile('animations/animations-2.plist');
  animation2 := cache.animationByName('dance_1');

  action2 := CCAnimate._create(animation2);
  m_tamara.runAction(CCSequence._create([action2, action2.reverse]));

  animation3 := CCAnimation(animation2.copy.autorelease);
  animation3.Loops := 4;

  action3 := CCAnimate._create(animation3);
  m_kathia.runAction(action3);
end;

procedure ActionAnimate.onExit;
begin
  inherited;

end;

function ActionAnimate.subtitle: string;
begin
  Result := 'Center: Manual animation. Border: using file format animation';
end;

function ActionAnimate.title: string;
begin
  Result := 'Animation';
end;

{ ActionSequence2 }

procedure ActionSequence2.callback1;
var
  s: CCSize;
  plabel1: CCLabelTTF;
begin
  s := CCDirector.sharedDirector.getWinSize;
  plabel1 := CCLabelTTF._create('callback 1 called', 'Marker Felt', 16);
  plabel1.setPosition(s.width/4*1, s.height/2);
  addChild(plabel1);
end;

procedure ActionSequence2.callback2(sender: CCObject);
var
  s: CCSize;
  plabel1: CCLabelTTF;
begin
  s := CCDirector.sharedDirector.getWinSize;
  plabel1 := CCLabelTTF._create('callback 2 called', 'Marker Felt', 16);
  plabel1.setPosition(s.width/4*2, s.height/2);
  addChild(plabel1);
end;

procedure ActionSequence2.callback3(sender: CCObject; data: Pointer);
var
  s: CCSize;
  plabel1: CCLabelTTF;
begin
  s := CCDirector.sharedDirector.getWinSize;
  plabel1 := CCLabelTTF._create('callback 3 called', 'Marker Felt', 16);
  plabel1.setPosition(s.width/4*3, s.height/2);
  addChild(plabel1);
end;

procedure ActionSequence2.onEnter;
var
  action: CCFiniteTimeAction;
begin
  inherited;
  alignSpritesLeft(1);

  action := CCSequence._create([
            CCPlace._create(ccp(200, 200)),
            CCShow._create(),
            CCMoveBy._create(1, ccp(100, 0)),
            CCCallFunc._create(Self, callback1),
            CCCallFuncN._create(Self, callback2),
            CCCallFuncND._create(Self, callback3, Self) ]);

  m_grossini.runAction(action);
end;

function ActionSequence2.subtitle: string;
begin
  Result := 'Sequence of InstantActions';
end;

{ ActionRepeatForever }

procedure ActionRepeatForever.onEnter;
var
  action: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(1);

  action := CCSequence._create([CCDelayTime._create(1), CCCallFuncN._create(Self, repeatforever) ]);
  m_grossini.runAction(action);
end;

procedure ActionRepeatForever.repeatforever(pNode: CCObject);
var
  rep: CCRepeatForever;
begin
  rep := CCRepeatForever._create(CCRotateBy._create(1, 360));
  CCNode(pNode).runAction(rep);
end;

function ActionRepeatForever.subtitle: string;
begin
  Result := 'CallFuncN + RepeatForever';
end;

{ Issue1305 }

procedure Issue1305.addSprite(dt: Single);
begin
  m_pSpriteTmp.setPosition(250, 250);
  addChild(m_pSpriteTmp);

end;

procedure Issue1305.log(pSender: CCObject);
begin
  CCLog('This message SHALL ONLY appear when the sprite is added to the scene, NOT BEFORE', []);
end;

procedure Issue1305.onEnter;
begin
  inherited;
  centerSprites(0);
  m_pSpriteTmp := CCSprite._create('Images/grossini.png');
  m_pSpriteTmp.runAction(CCCallFuncN._create(Self, log));
  m_pSpriteTmp.retain;
  {.$MESSAGE '这个测试用例有问题，当事件并没有完成，就是addSprite这个事件并没有被触发的时候就关闭程序，程序就会有内存泄露，}
  {实际上把 m_pSpriteTmp.runAction(CCCallFuncN._create(Self, log)); 这行注释掉就， 即使没有触发addSprite也没有问题}
  {估计是 CCCallFuncN 这个类的问题'}
  {原C++程序也是如此}
  scheduleOnce(addSprite, 2);
end;

procedure Issue1305.onExit;
begin
  m_pSpriteTmp.release;
  inherited;
end;

function Issue1305.subtitle: string;
begin
  Result := 'In two seconds you should see a message on the console. NOT BEFORE.';
end;

function Issue1305.title: string;
begin
  Result := 'Issue 1305';
end;

{ Issue1305_2 }

procedure Issue1305_2.log1;
begin
  CCLog('1st block', []);
end;

procedure Issue1305_2.log2;
begin
   CCLog('and block', []);
end;

procedure Issue1305_2.log3;
begin
   CCLog('3rd block', []);
end;

procedure Issue1305_2.log4;
begin
     CCLog('4th block', []);
end;

procedure Issue1305_2.onEnter;
var
  spr: CCSprite;
  act1: CCMoveBy;
  act2: CCCallFunc;
  act3: CCMoveBy;
  act4: CCCallFunc;
  act5: CCMoveBy;
  act6: CCCallFunc;
  act7: CCMoveBy;
  act8: CCCallFunc;
  actf: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(0);
  spr := CCSprite._create('Images/grossini.png');
  spr.setPosition(200, 200);
  addChild(spr);

  act1 := CCMoveBy._create(2, ccp(0, 100));
  act2 := CCCallFunc._create(Self, log1);
  act3 := CCMoveBy._create(2, ccp(0, -100));
  act4 := CCCallFunc._create(Self, log2);
  act5 := CCMoveBy._create(2, ccp(100, -100));
  act6 := CCCallFunc._create(Self, log3);
  act7 := CCMoveBy._create(2, ccp(-100, 0));
  act8 := CCCallFunc._create(Self, log4);

  actf := CCSequence._create([act1, act2, act3, act4, act5, act6, act7, act8]);
  CCDirector.sharedDirector.ActionManager.addAction(actf, spr, False);
end;

function Issue1305_2.subtitle: string;
begin
  Result := 'See console. You should only see one message for each block';
end;

function Issue1305_2.title: string;
begin
  Result := 'Issue 1305 #2';
end;

{ Issue1327 }

procedure Issue1327.logSprRotation(pSender: CCObject);
begin
  CCLog('%f', [CCSprite(pSender).Rotation]);
end;

procedure Issue1327.onEnter;
var
  act1, act2, act3, act4, act5, act6, act7, act8, act9: CCFiniteTimeAction;
  spr: CCSprite;
  actf: CCFiniteTimeAction;
begin
  inherited;
  centerSprites(0);

  spr := CCSprite._create('Images/grossini.png');
  spr.setPosition(100, 100);
  addChild(spr);

  act1 := CCCallFuncN._create(Self, logSprRotation);
  act2 := CCRotateBy._create(0.25, 45);
  act3 := CCCallFuncN._create(Self, logSprRotation);
  act4 := CCRotateBy._create(0.25, 45);
  act5 := CCCallFuncN._create(Self, logSprRotation);
  act6 := CCRotateBy._create(0.25, 45);
  act7 := CCCallFuncN._create(Self, logSprRotation);
  act8 := CCRotateBy._create(0.25, 45);
  act9 := CCCallFuncN._create(Self, logSprRotation);
  actf := CCSequence._create([act1, act2, act3, act4, act5, act6, act7, act8, act9]);
  spr.runAction(actf);
end;

function Issue1327.subtitle: string;
begin
  Result := 'See console: You should see: 0, 45, 90, 135, 180';
end;

function Issue1327.title: string;
begin
  Result := 'Issue 1327';
end;

{ ActionCardinalSpline }

function ActionCardinalSpline.title: string;
begin
  Result := 'no implementation';
end;

{ ActionCatmullRom }

function ActionCatmullRom.title: string;
begin
  Result := 'no implementation';
end;

end.
