unit ActionsEaseTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSprite, Cocos2dx.CCNode;

type
  ActionsEaseTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  ActionsEaseDemo = class(CCLayer)
  protected
    m_strTitle: string;
    m_grossini, m_tamara, m_kathia: CCSprite;
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; dynamic;
    procedure positionForTwo();
    procedure onEnter(); override;
    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  end;

  SpriteEase = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    procedure testStopAction(dt: Single);
  end;

  SpriteEaseInOut = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseExponential = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseExponentialInOut = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseSine = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseSineInOut = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseElastic = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseElasticInOut = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseBounce = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseBounceInOut = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseBack = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpriteEaseBackInOut = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
  end;

  SpeedTest = class(ActionsEaseDemo)
  public
    procedure onEnter(); override;
    function title(): string; override;
    procedure altertime(dt: Single);
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCActionEase,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, testResource,
  Cocos2dx.CCAction, Cocos2dx.CCActionInterval, Cocos2dx.CCActionCamera;


var s_nActionIdx: Integer = -1;
const ACTION_LAYER_COUNT = 13;

function CreateLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := SpriteEase.Create;
    1: bRet := SpriteEaseInOut.Create;
    2: bRet := SpriteEaseExponential.Create;
    3: bRet := SpriteEaseExponentialInOut.Create;
    4: bRet := SpriteEaseSine.Create;
    5: bRet := SpriteEaseSineInOut.Create;
    6: bRet := SpriteEaseElastic.Create;
    7: bRet := SpriteEaseElasticInOut.Create;
    8: bRet := SpriteEaseBounce.Create;
    9: bRet := SpriteEaseBounceInOut.Create;
    10: bRet := SpriteEaseBack.Create;
    11: bRet := SpriteEaseBackInOut.Create;
    12: bRet := SpeedTest.Create;
  end;

  Result := bRet;
end;  

function NextAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(s_nActionIdx);
  s_nActionIdx := s_nActionIdx mod ACTION_LAYER_COUNT;

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
  total := ACTION_LAYER_COUNT;
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

{ ActionsEaseTestScene }

procedure ActionsEaseTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := NextAction();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ ActionsEaseDemo }

procedure ActionsEaseDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionsEaseTestScene.Create();
  s.addChild(BackAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor ActionsEaseDemo.Create;
begin
  inherited Create();
  Randomize();
end;

destructor ActionsEaseDemo.Destroy;
begin
  m_grossini.release();
  m_tamara.release();
  m_kathia.release();
  inherited;
end;

procedure ActionsEaseDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionsEaseTestScene.Create();
  s.addChild(NextAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure ActionsEaseDemo.onEnter;
var
  s: CCSize;
  label1: CCLabelTTF;
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

  addChild(m_grossini, 3);
  addChild(m_tamara, 1);
  addChild(m_kathia, 2);

  m_grossini.setPosition( CCPointMake(60, 1*s.height/5) );
  m_kathia.setPosition( CCPointMake(60, 2.5*s.height/5) );
  m_tamara.setPosition( CCPointMake(60, 4*s.height/5) );

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

procedure ActionsEaseDemo.positionForTwo;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();

  m_grossini.setPosition( CCPointMake(60, s.height / 5) );
  m_tamara.setPosition( CCPointMake(60, s.height * 4 / 5) );
  m_kathia.setVisible(False);
end;

procedure ActionsEaseDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ActionsEaseTestScene.Create();
  s.addChild(RestartAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function ActionsEaseDemo.title: string;
begin
  Result := 'No title';
end;

{ SpriteEase }

procedure SpriteEase.onEnter;
var
  s: CCSize;
  move, move_back, move_ease_in, move_ease_in_back,
  move_ease_out, move_ease_out_back: CCFiniteTimeAction;
  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  a, a1, a2: CCAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease_in := CCEaseIn._create(  CCActionInterval(move.copy.autorelease), 2.5 );
  move_ease_in_back := move_ease_in.reverse();

  move_ease_out := CCEaseOut._create(  CCActionInterval(move.copy.autorelease), 2.5  ) ;
  move_ease_out_back := move_ease_out.reverse();

  delay := CCDelayTime._create(0.25);
  seq1 := CCSequence._create([move, delay, move_back]);
  seq2 := CCSequence._create([move_ease_in, CCFiniteTimeAction(delay.copy.autorelease), move_ease_in_back, CCFiniteTimeAction(delay.copy.autorelease)]);
  seq3 := CCSequence._create([move_ease_out, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back, CCFiniteTimeAction(delay.copy.autorelease)]);

  a2 := m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq1)));
  a2.setTag(1);
  a1 := m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq2)));
  a1.setTag(1);
  a := m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
  a.setTag(1);

  schedule(testStopAction, 6.25);
end;

procedure SpriteEase.testStopAction(dt: Single);
begin
  unschedule(testStopAction);
  m_tamara.stopActionByTag(1);
  m_kathia.stopActionByTag(1);
  m_grossini.stopActionByTag(1);
end;

function SpriteEase.title: string;
begin
  Result := 'EaseIn - EaseOut - Stop';
end;

{ SpriteEaseInOut }

procedure SpriteEaseInOut.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  move: CCFiniteTimeAction;
  move_ease_inout1, move_ease_inout_back1: CCFiniteTimeAction;
  move_ease_inout2, move_ease_inout_back2: CCFiniteTimeAction;
  move_ease_inout3, move_ease_inout_back3: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));

  move_ease_inout1 := CCEaseInOut._create(  CCActionInterval(move.copy.autorelease), 0.65 );
  move_ease_inout_back1 := move_ease_inout1.reverse();

  move_ease_inout2 := CCEaseInOut._create(  CCActionInterval(move.copy.autorelease), 1.35  ) ;
  move_ease_inout_back2 := move_ease_inout2.reverse();

  move_ease_inout3 := CCEaseInOut._create(  CCActionInterval(move.copy.autorelease), 1.0  ) ;
  move_ease_inout_back3 := move_ease_inout3.reverse();

  delay := CCDelayTime._create(0.25);
  seq1 := CCSequence._create([move_ease_inout1, delay, move_ease_inout_back1, CCFiniteTimeAction(delay.copy.autorelease)]);
  seq2 := CCSequence._create([move_ease_inout2, CCFiniteTimeAction(delay.copy.autorelease), move_ease_inout_back2, CCFiniteTimeAction(delay.copy.autorelease)]);
  seq3 := CCSequence._create([move_ease_inout3, CCFiniteTimeAction(delay.copy.autorelease), move_ease_inout_back3, CCFiniteTimeAction(delay.copy.autorelease)]);

  m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq3)));

  m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq1)));

  m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq2)));

end;

function SpriteEaseInOut.title: string;
begin
  Result := 'EaseInOut and rates';
end;

{ SpriteEaseExponential }

procedure SpriteEaseExponential.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease_in, move_ease_in_back: CCFiniteTimeAction;
  move_ease_out, move_ease_out_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease_in := CCEaseExponentialIn._create( CCActionInterval(move.copy.autorelease) );
  move_ease_in_back := move_ease_in.reverse();

  move_ease_out := CCEaseExponentialOut._create( CCActionInterval(move.copy.autorelease) );
  move_ease_out_back := move_ease_out.reverse();

  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([  move, delay, move_back,  CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq2 := CCSequence._create([  move_ease_in, CCFiniteTimeAction(delay.copy.autorelease), move_ease_in_back, CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq3 := CCSequence._create([  move_ease_out, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back, CCFiniteTimeAction(delay.copy.autorelease) ]);



  m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq1)));
  m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq2)));
  m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
end;

function SpriteEaseExponential.title: string;
begin
  Result := 'ExpIn - ExpOut actions';
end;

{ SpriteEaseExponentialInOut }

procedure SpriteEaseExponentialInOut.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease, move_ease_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease := CCEaseExponentialInOut._create(CCActionInterval(move.copy.autorelease));
  move_ease_back := move_ease.reverse();
  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([move, delay, move_back, CCFiniteTimeAction(delay.copy.autorelease)]);
  seq2 := CCSequence._create([move_ease, delay, move_ease_back, CCFiniteTimeAction(delay.copy.autorelease)]);

  positionForTwo;

  m_grossini.runAction( CCRepeatForever._create(CCActionInterval(seq1)) );
  m_tamara.runAction( CCRepeatForever._create(CCActionInterval(seq2)) );
end;

function SpriteEaseExponentialInOut.title: string;
begin
  Result := 'EaseExponentialInOut action';
end;

{ SpriteEaseSine }

procedure SpriteEaseSine.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease_in, move_ease_in_back: CCFiniteTimeAction;
  move_ease_out, move_ease_out_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease_in := CCEaseSineIn._create( CCActionInterval(move.copy.autorelease) );
  move_ease_in_back := move_ease_in.reverse();

  move_ease_out := CCEaseSineOut._create( CCActionInterval(move.copy.autorelease) );
  move_ease_out_back := move_ease_out.reverse();

  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([  move, delay, move_back,  CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq2 := CCSequence._create([  move_ease_in, CCFiniteTimeAction(delay.copy.autorelease), move_ease_in_back, CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq3 := CCSequence._create([  move_ease_out, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back, CCFiniteTimeAction(delay.copy.autorelease) ]);



  m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq1)));
  m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq2)));
  m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
end;

function SpriteEaseSine.title: string;
begin
  Result := 'EaseSineIn - EaseSineOut';
end;

{ SpriteEaseSineInOut }

procedure SpriteEaseSineInOut.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease, move_ease_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease := CCEaseSineInOut._create(CCActionInterval(move.copy.autorelease));
  move_ease_back := move_ease.reverse();
  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([move, delay, move_back, CCFiniteTimeAction(delay.copy.autorelease)]);
  seq2 := CCSequence._create([move_ease, delay, move_ease_back, CCFiniteTimeAction(delay.copy.autorelease)]);

  positionForTwo;

  m_grossini.runAction( CCRepeatForever._create(CCActionInterval(seq1)) );
  m_tamara.runAction( CCRepeatForever._create(CCActionInterval(seq2)) );
end;

function SpriteEaseSineInOut.title: string;
begin
  Result := 'EaseSineInOut action';
end;

{ SpriteEaseElastic }

procedure SpriteEaseElastic.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease_in, move_ease_in_back: CCFiniteTimeAction;
  move_ease_out, move_ease_out_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease_in := CCEaseElasticIn._create( CCActionInterval(move.copy.autorelease) );
  move_ease_in_back := move_ease_in.reverse();

  move_ease_out := CCEaseElasticOut._create( CCActionInterval(move.copy.autorelease) );
  move_ease_out_back := move_ease_out.reverse();

  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([  move, delay, move_back,  CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq2 := CCSequence._create([  move_ease_in, CCFiniteTimeAction(delay.copy.autorelease), move_ease_in_back, CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq3 := CCSequence._create([  move_ease_out, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back, CCFiniteTimeAction(delay.copy.autorelease) ]);



  m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq1)));
  m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq2)));
  m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
end;

function SpriteEaseElastic.title: string;
begin
  Result := 'Elastic In - Out actions';
end;

{ SpriteEaseElasticInOut }

procedure SpriteEaseElasticInOut.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  move: CCFiniteTimeAction;
  move_ease_in, move_ease_in_back: CCFiniteTimeAction;
  move_ease_out, move_ease_out_back: CCFiniteTimeAction;
  move_ease_out2, move_ease_out_back2: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));

  move_ease_in := CCEaseElasticInOut._create( CCActionInterval(move.copy.autorelease), 0.3 );
  move_ease_in_back := move_ease_in.reverse();

  move_ease_out := CCEaseElasticInOut._create( CCActionInterval(move.copy.autorelease), 0.45 );
  move_ease_out_back := move_ease_out.reverse();

  move_ease_out2 := CCEaseElasticInOut._create( CCActionInterval(move.copy.autorelease), 0.6 );
  move_ease_out_back2 := move_ease_out2.reverse();

  delay := CCDelayTime._create(0.25);


  seq1 := CCSequence._create([  move_ease_in, CCFiniteTimeAction(delay.copy.autorelease), move_ease_in_back, CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq2 := CCSequence._create([  move_ease_out, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back, CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq3 := CCSequence._create([  move_ease_out2, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back2, CCFiniteTimeAction(delay.copy.autorelease) ]);



  m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
  m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq1)));
  m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq2)));
end;

function SpriteEaseElasticInOut.title: string;
begin
  Result := 'EaseElasticInOut action';
end;

{ SpriteEaseBounce }

procedure SpriteEaseBounce.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease_in, move_ease_in_back: CCFiniteTimeAction;
  move_ease_out, move_ease_out_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease_in := CCEaseBounceIn._create( CCActionInterval(move.copy.autorelease) );
  move_ease_in_back := move_ease_in.reverse();

  move_ease_out := CCEaseBounceOut._create( CCActionInterval(move.copy.autorelease) );
  move_ease_out_back := move_ease_out.reverse();

  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([  move, delay, move_back,  CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq2 := CCSequence._create([  move_ease_in, CCFiniteTimeAction(delay.copy.autorelease), move_ease_in_back, CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq3 := CCSequence._create([  move_ease_out, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back, CCFiniteTimeAction(delay.copy.autorelease) ]);



  m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq1)));
  m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq2)));
  m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
end;

function SpriteEaseBounce.title: string;
begin
  Result := 'Bounce In - Out actions';
end;

{ SpriteEaseBounceInOut }

procedure SpriteEaseBounceInOut.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease, move_ease_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease := CCEaseBounceInOut._create(CCActionInterval(move.copy.autorelease));
  move_ease_back := move_ease.reverse();
  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([move, delay, move_back, CCFiniteTimeAction(delay.copy.autorelease)]);
  seq2 := CCSequence._create([move_ease, delay, move_ease_back, CCFiniteTimeAction(delay.copy.autorelease)]);

  positionForTwo;

  m_grossini.runAction( CCRepeatForever._create(CCActionInterval(seq1)) );
  m_tamara.runAction( CCRepeatForever._create(CCActionInterval(seq2)) );
end;

function SpriteEaseBounceInOut.title: string;
begin
  Result := 'EaseBounceInOut action';
end;

{ SpriteEaseBack }

procedure SpriteEaseBack.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2, seq3: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease_in, move_ease_in_back: CCFiniteTimeAction;
  move_ease_out, move_ease_out_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease_in := CCEaseBackIn._create( CCActionInterval(move.copy.autorelease) );
  move_ease_in_back := move_ease_in.reverse();

  move_ease_out := CCEaseBackOut._create( CCActionInterval(move.copy.autorelease) );
  move_ease_out_back := move_ease_out.reverse();

  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([  move, delay, move_back,  CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq2 := CCSequence._create([  move_ease_in, CCFiniteTimeAction(delay.copy.autorelease), move_ease_in_back, CCFiniteTimeAction(delay.copy.autorelease) ]);
  seq3 := CCSequence._create([  move_ease_out, CCFiniteTimeAction(delay.copy.autorelease), move_ease_out_back, CCFiniteTimeAction(delay.copy.autorelease) ]);



  m_grossini.runAction(CCRepeatForever._create(CCActionInterval(seq1)));
  m_tamara.runAction(CCRepeatForever._create(CCActionInterval(seq2)));
  m_kathia.runAction(CCRepeatForever._create(CCActionInterval(seq3)));
end;

function SpriteEaseBack.title: string;
begin
  Result := 'Back In - Out actions';
end;

{ SpriteEaseBackInOut }

procedure SpriteEaseBackInOut.onEnter;
var
  s: CCSize;

  delay: CCDelayTime;
  seq1, seq2: CCFiniteTimeAction;
  move, move_back: CCFiniteTimeAction;
  move_ease, move_ease_back: CCFiniteTimeAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();
  move := CCMoveBy._create(3, CCPointMake(s.width-130, 0));
  move_back := move.reverse();

  move_ease := CCEaseBackInOut._create(CCActionInterval(move.copy.autorelease));
  move_ease_back := move_ease.reverse();
  delay := CCDelayTime._create(0.25);

  seq1 := CCSequence._create([move, delay, move_back, CCFiniteTimeAction(delay.copy.autorelease)]);
  seq2 := CCSequence._create([move_ease, delay, move_ease_back, CCFiniteTimeAction(delay.copy.autorelease)]);

  positionForTwo;

  m_grossini.runAction( CCRepeatForever._create(CCActionInterval(seq1)) );
  m_tamara.runAction( CCRepeatForever._create(CCActionInterval(seq2)) );
end;

function SpriteEaseBackInOut.title: string;
begin
  Result := 'EaseBackInOut action';
end;

{ SpeedTest }

const    kTagAction1 = 1;
const    kTagAction2 = 2;
const    kTagSlider = 1;

procedure SpeedTest.altertime(dt: Single);
var
  action1, action2, action3: CCSpeed;
begin
  action1 := CCSpeed(m_grossini.getActionByTag(kTagAction1));
  action2 := CCSpeed(m_tamara.getActionByTag(kTagAction1));
  action3 := CCSpeed(m_kathia.getActionByTag(kTagAction1));

  action1.setSpeed(Random*2);
  action2.setSpeed(Random*2);
  action3.setSpeed(Random*2);
end;

procedure SpeedTest.onEnter;
var
  jump1, jump2, rot1, rot2: CCFiniteTimeAction;
  seq3_1, seq3_2, spawn: CCFiniteTimeAction;
  action: CCSpeed;
  s: CCSize;
  action2, action3: CCAction;
begin
  inherited;
  s := CCDirector.sharedDirector().getWinSize();

  jump1 := CCJumpBy._create(4, CCPointMake(-s.width + 80, 0), 100, 4);
  jump2 := jump1.reverse();
  rot1 := CCRotateBy._create(4, 360*2);
  rot2 := rot1.reverse();

  seq3_1 := CCSequence._create([jump2, jump1]);
  seq3_2 := CCSequence._create([rot1, rot2]);
  spawn := CCSpawn._create([seq3_1, seq3_2]);
  action := CCSpeed._create(CCRepeatForever._create(CCActionInterval(spawn)), 1);
  action.setTag(kTagAction1);

  action2 := CCAction(action.copy.autorelease);
  action3 := CCAction(action.copy.autorelease);

  action2.setTag(kTagAction1);
  action3.setTag(kTagAction1);

  m_grossini.runAction(action2);
  m_tamara.runAction(action3);
  m_kathia.runAction(action);

  schedule(altertime, 1);
end;

function SpeedTest.title: string;
begin
  Result := 'Speed action';
end;

end.
