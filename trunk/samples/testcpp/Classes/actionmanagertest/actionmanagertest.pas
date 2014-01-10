unit actionmanagertest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic,
  Cocos2dx.CCGeometry, Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCTextureAtlas;

type
  ActionManagerTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  ActionManagerDemo = class(CCLayer)
  protected
    m_atlas: CCTextureAtlas;
    m_strTitle: string;
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; dynamic;

    procedure onEnter(); override;

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  end;

  CrashTest = class(ActionManagerDemo)
  public
    function title(): string; override;
    procedure onEnter(); override;
    procedure removeThis();
  end;

  LogicTest = class(ActionManagerDemo)
  public
    function title(): string; override;
    procedure onEnter(); override;
    procedure bugMe(node: CCObject);
  end;

  PauseTest = class(ActionManagerDemo)
  public
    function title(): string; override;
    procedure onEnter(); override;
    procedure unpause(dt: Single);
  end;

  RemoveTest = class(ActionManagerDemo)
  public
    function title(): string; override;
    procedure onEnter(); override;
    procedure stopAction();
  end;

  ResumeTest = class(ActionManagerDemo)
  public
    function title(): string; override;
    procedure onEnter(); override;
    procedure resumeGrossini(time: Single);
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, testResource,
  Cocos2dx.CCAction, Cocos2dx.CCActionInterval,
  Cocos2dx.CCActionInstant, Cocos2dx.CCActionCamera;

var s_nActionIdx: Integer = -1;
const MAX_LAYER = 5;

const kTagNode = 0;
const    kTagGrossini = 1;
const    kTagSequence = 2;

function CreateLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := CrashTest.Create();
    1: bRet := LogicTest.Create();
    2: bRet := PauseTest.Create();
    3: bRet := RemoveTest.Create();
    4: bRet := ResumeTest.Create();
  end;

  Result := bRet;
end;  

function NextAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(s_nActionIdx);
  s_nActionIdx := s_nActionIdx mod MAX_LAYER;

  pLayer := CreateLayer(s_nActionIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function BackAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(s_nActionIdx);
  total := MAX_LAYER;
  if s_nActionIdx < 0 then
    s_nActionIdx := s_nActionIdx + total;

  pLayer := CreateLayer(s_nActionIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function RestartAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := CreateLayer(s_nActionIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ ActionManagerTestScene }

procedure ActionManagerTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := NextAction();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ ActionManagerDemo }

procedure ActionManagerDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionManagerTestScene.Create();
  s.addChild(BackAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor ActionManagerDemo.Create;
begin
  inherited Create();
end;

destructor ActionManagerDemo.Destroy;
begin

  inherited;
end;

procedure ActionManagerDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionManagerTestScene.Create();
  s.addChild(NextAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure ActionManagerDemo.onEnter;
var
  s: CCSize;
  label1: CCLabelTTF;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize;

  label1 := CCLabelTTF._create(title(), 'Arial', 28);
  addChild(label1, 1);
  label1.setPosition(ccp(s.width/2, s.height-50));

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

procedure ActionManagerDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionManagerTestScene.Create();
  s.addChild(RestartAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function ActionManagerDemo.title: string;
begin
  Result := 'No title';
end;

{ CrashTest }

procedure CrashTest.onEnter;
var
  child: CCSprite;
begin
  inherited;

  child := CCSprite._create(s_pPathGrossini);
  child.setPosition( CCPointMake(200, 200) );
  addChild(child, 1);

  child.runAction( CCRotateBy._create(1.5, 90) );
  child.runAction( CCSequence._create( [CCDelayTime._create(1.4), CCFadeOut._create(1.1)] ) );
  runAction( CCSequence._create([ CCDelayTime._create(1.4), CCCallFunc._create(Self, removeThis) ]) );
end;

procedure CrashTest.removeThis;
begin
  Parent.removeChild(Self, True);
  nextCallback(Self);
end;

function CrashTest.title: string;
begin
  Result := 'Test 1. Should not crash';
end;

{ LogicTest }

procedure LogicTest.bugMe(node: CCObject);
begin
  CCNode(node).stopAllActions();
  CCNode(node).runAction( CCScaleTo._create(2, 2) );
end;

procedure LogicTest.onEnter;
var
  grossini: CCSprite;
begin
  inherited;
  grossini := CCSprite._create(s_pPathGrossini);
  addChild(grossini, 0, 2);
  grossini.setPosition( CCPointMake(200, 200) );
  grossini.runAction( CCSequence._create([CCMoveBy._create(1, CCPointMake(150, 0)),
    CCCallFuncN._create(Self, bugme)  ])  );
end;

function LogicTest.title: string;
begin
  Result := 'Logic test';
end;

{ PauseTest }

procedure PauseTest.onEnter;
var
  s: CCSize;
  plabel: CCLabelTTF;
  grossini: CCSprite;
  action: CCAction;
  pDirector: CCDirector;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  plabel := CCLabelTTF._create('After 5 seconds grossini should move', 'Thonburi', 16);
  addChild(plabel);
  plabel.setPosition( CCPointMake(s.width/2, 245) );

  grossini := CCSprite._create(s_pPathGrossini);
  addChild(grossini, 0, kTagGrossini);
  grossini.setPosition( CCPointMake(200, 200) );

  action := CCMoveBy._create(1, CCPointMake(150, 0));
  pDirector := CCDirector.sharedDirector();

  pDirector.ActionManager.addAction(action, grossini, True);

  schedule(unpause, 3);
end;

function PauseTest.title: string;
begin
  Result := 'Pause Test';
end;

procedure PauseTest.unpause(dt: Single);
var
  node: CCNode;
  pDirector: CCDirector;
begin
  unschedule(unpause);
  node := getChildByTag(kTagGrossini);

  pDirector := CCDirector.sharedDirector();
  pDirector.ActionManager.resumeTarget(node);
end;

{ RemoveTest }

procedure RemoveTest.onEnter;
var
  s: CCSize;
  pLabel: CCLabelTTF;
  pMove: CCMoveBy;
  pCallback: CCCallFunc;
  pSeq: CCActionInterval;

  pChild: CCSprite;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  pLabel := CCLabelTTF._create('Should not crash', 'Thonburi', 16);
  addChild(pLabel);
  pLabel.setPosition( CCPointMake(s.width/2, 245) );

  pMove := CCMoveBy._create(2, CCPointMake(200, 0));
  pCallback := CCCallFunc._create(Self, stopAction);

  pSeq := CCActionInterval(CCSequence._create([ pMove, pCallback ]));
  pSeq.setTag(kTagSequence);

  pChild := CCSprite._create(s_pPathGrossini);
  pChild.setPosition( CCPointMake(200, 200) );

  addChild(pChild, 1, kTagGrossini);
  pChild.runAction(pSeq);
end;

procedure RemoveTest.stopAction;
var
  pSprite: CCNode;
begin
  pSprite := getChildByTag(kTagGrossini);
  pSprite.stopActionByTag(kTagSequence);
end;

function RemoveTest.title: string;
begin
  Result := 'Remove Test';
end;

{ ResumeTest }

procedure ResumeTest.onEnter;
var
  s: CCSize;
  plabel: CCLabelTTF;
  pGrosini: CCSprite;
  pDirector: CCDirector;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  plabel := CCLabelTTF._create('Grossini only rotate/scale in 3 seconds', 'Thonburi', 16);
  addChild(plabel);
  plabel.setPosition( CCPointMake(s.width/2, 245) );

  pGrosini := CCSprite._create(s_pPathGrossini);
  addChild(pGrosini, 0, kTagGrossini);
  pGrosini.setPosition( CCPointMake(s.width/2, s.height/2) );

  pGrosini.runAction( CCScaleBy._create(2, 2) );

  pDirector := CCDirector.sharedDirector();
  pDirector.ActionManager.pauseTarget(pGrosini);
  pGrosini.runAction( CCRotateBy._create(2, 360) );

  schedule(resumeGrossini, 3.0);
end;

procedure ResumeTest.resumeGrossini(time: Single);
var
  pGrossini: CCNode;
  pDirector: CCDirector;
begin
  Self.unschedule(resumeGrossini);
  pGrossini := getChildByTag(kTagGrossini);
  pDirector := CCDirector.sharedDirector();
  pDirector.ActionManager.resumeTarget(pGrossini);
end;

function ResumeTest.title: string;
begin
  Result := 'Resume Test';
end;

end.
