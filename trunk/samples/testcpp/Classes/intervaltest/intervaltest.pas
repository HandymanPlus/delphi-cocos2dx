unit intervaltest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSprite, Cocos2dx.CCNode, Cocos2dx.CCLabelTTF;

type
  IntervalTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  IntervalLayer = class(CCLayer)
  protected
    m_label0: CCLabelTTF;
    m_label1: CCLabelTTF;
    m_label2: CCLabelTTF;
    m_label3: CCLabelTTF;
    m_label4: CCLabelTTF;
    m_time0, m_time1, m_time2, m_time3, m_time4: Single;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure onPause(pSender: CCObject);
    procedure step1(dt: Single);
    procedure step2(dt: Single);
    procedure step3(dt: Single);
    procedure step4(dt: Single);
    procedure update(time: Single); override;
  end;

implementation
uses
  Cocos2dx.CCDirector, SysUtils, Cocos2dx.CCParticleExamples, Cocos2dx.CCTextureCache,
  Cocos2dx.CCActionInterval,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, testResource, Cocos2dx.CCAction, Cocos2dx.CCCommon;

const SID_STEP1  =  100;
const SID_STEP2  =  101;
const SID_STEP3  =  102;
const IDC_PAUSE  =  200;

{ IntervalTestScene }

procedure IntervalTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := IntervalLayer.Create;
  addChild(pLayer);
  pLayer.release;
  CCDirector.sharedDirector.replaceScene(Self);
end;

{ IntervalLayer }

constructor IntervalLayer.Create;
var
  s: CCSize;
  sun: CCParticleSun;
  sprite: CCSprite;
  jump: CCJumpBy;
  item1: CCMenuItem;
  menu: CCMenu;
begin
  inherited;

  s := CCDirector.sharedDirector.getWinSize;
  

  sun := CCParticleSun._create;
  sun.setTexture(CCTextureCache.sharedTextureCache.addImage('Images/fire.png'));
  sun.setPosition(CCPointMake(s.width-32, s.height-32));

  sun.setTotalParticles(130);
  sun.Life := 0.6;
  addChild(sun);

  m_label0 := CCLabelTTF._create('', 'Arial', 24);
  m_label1 := CCLabelTTF._create('', 'Arial', 24);
  m_label2 := CCLabelTTF._create('', 'Arial', 24);
  m_label3 := CCLabelTTF._create('', 'Arial', 24);
  m_label4 := CCLabelTTF._create('', 'Arial', 24);

  scheduleUpdate;
  schedule(step1);
  schedule(step2, 0);
  schedule(step3, 1);
  schedule(step4, 2);

  m_label0.setPosition(s.width*1/6, s.height/2);
  m_label1.setPosition(s.width*2/6, s.height/2);
  m_label2.setPosition(s.width*3/6, s.height/2);
  m_label3.setPosition(s.width*4/6, s.height/2);
  m_label4.setPosition(s.width*5/6, s.height/2);

  addChild(m_label0);
  addChild(m_label1);
  addChild(m_label2);
  addChild(m_label3);
  addChild(m_label4);

  sprite := CCSprite._create(s_pPathGrossini);
  sprite.setPosition(40, 50);
  jump := CCJumpBy._create(3, CCPointMake(s.width-80, 0), 50, 4);
  addChild(sprite);
  sprite.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([jump, jump.reverse]))));

  item1 := CCMenuItemFont._create('Pause', Self, onPause);
  menu := CCMenu._create([item1]);
  menu.setPosition(s.width/2, s.height-50);
  addChild(menu);
end;

destructor IntervalLayer.Destroy;
begin
  if CCDirector.sharedDirector.isPaused then
    CCDirector.sharedDirector.resume;
  inherited;
end;

procedure IntervalLayer.onPause(pSender: CCObject);
begin
  if CCDirector.sharedDirector.isPaused then
    CCDirector.sharedDirector.resume
  else
    CCDirector.sharedDirector.pause;
end;

procedure IntervalLayer.step1(dt: Single);
var
  str: string;
begin
  m_time1 := m_time1 + dt;
  str := Format('%2.1f', [m_time1]);
  m_label1.setString(str);
end;

procedure IntervalLayer.step2(dt: Single);
var
  str: string;
begin
  m_time2 := m_time2 + dt;
  str := Format('%2.1f', [m_time2]);
  m_label2.setString(str);
end;

procedure IntervalLayer.step3(dt: Single);
var
  str: string;
begin
  m_time3 := m_time3 + dt;
  str := Format('%2.1f', [m_time3]);
  m_label3.setString(str);
end;

procedure IntervalLayer.step4(dt: Single);
var
  str: string;
begin
  m_time4 := m_time4 + dt;
  str := Format('%2.1f', [m_time4]);
  m_label4.setString(str);
  //CCLog('%s', [str]);
end;

procedure IntervalLayer.update(time: Single);
var
  str: string;
begin
  m_time0 := m_time0 + time;
  str := Format('%2.1f', [m_time0]);
  m_label0.setString(str);
end;

end.
