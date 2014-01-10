unit scenetest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic,
  Cocos2dx.CCNode, Cocos2dx.CCRenderTexture;

type
  SceneTestLayer1 = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;

    procedure onEnter(); override;
    procedure onEnterTransitionDidFinish(); override;

    procedure testDealloc(dt: Single);
    procedure onPushScene(pSender: CCObject);
    procedure onPushSceneTran(pSender: CCObject);
    procedure onQuit(pSender: CCObject);
  end;

  SceneTestLayer2 = class(CCLayer)
  public
    m_timeCounter: Single;
    constructor Create();
    procedure testDealloc(dt: Single);
    procedure onGoBack(pSender: CCObject);
    procedure onReplaceScene(pSender: CCObject);
    procedure onReplaceSceneTran(pSender: CCObject);
  end;

  SceneTestLayer3 = class(CCLayerColor)
  public
    class function _create(): SceneTestLayer3;
    constructor Create();
    function init(): Boolean; override;
    procedure testDealloc(dt: Single);
    procedure item0Clicked(pSender: CCObject);
    procedure item1Clicked(pSender: CCObject);
    procedure item2Clicked(pSender: CCObject);
  end;

  SceneTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

implementation
uses
  Cocos2dx.CCDirector, Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, Cocos2dx.CCTypes,
  Cocos2dx.CCGeometry, Cocos2dx.CCSprite, Cocos2dx.CCAction,
  Cocos2dx.CCActionInterval, testResource, Cocos2dx.CCCommon, Cocos2dx.CCTransition;

{ SceneTestScene }

procedure SceneTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := SceneTestLayer1.Create;
  addChild(pLayer);
  pLayer.release;
  CCDirector.sharedDirector.replaceScene(Self);
end;

{ SceneTestLayer1 }

constructor SceneTestLayer1.Create;
var
  item1, item2, item3: CCMenuItemFont;
  menu: CCMenu;
  s: CCSize;
  sprite: CCSprite;
  rotate: CCActionInterval;
  rep: CCAction;
begin
  inherited;

  item1 := CCMenuItemFont._create('Test pushScene', Self, onPushScene);
  item2 := CCMenuItemFont._create('Test pushScene w/transition', Self, onPushSceneTran);
  item3 := CCMenuItemFont._create('Quit', Self, onQuit);
  menu := CCMenu._create([item1, item2, item3]);
  menu.alignItemsVertically();
  addChild(menu);

  s := CCDirector.sharedDirector().getWinSize();
  sprite := CCSprite._create(s_pPathGrossini);
  addChild(sprite);
  sprite.setPosition(CCPointMake(s.width-40, s.height/2));

  rotate := CCRotateBy._create(2, 360);
  rep := CCRepeatForever._create(rotate);
  sprite.runAction(rep);

  schedule(testDealloc);
end;

destructor SceneTestLayer1.Destroy;
begin

  inherited;
end;

procedure SceneTestLayer1.onEnter;
begin
  CCLOG('SceneTestLayer1#onEnter', []);
  inherited;
end;

procedure SceneTestLayer1.onEnterTransitionDidFinish;
begin
  CCLOG('SceneTestLayer1#onEnterTransitionDidFinish', []);
  inherited;
end;

procedure SceneTestLayer1.onPushScene(pSender: CCObject);
var
  scene: CCScene;
  pLayer: CCLayer;
begin
  scene := SceneTestScene.Create();
  pLayer := SceneTestLayer2.Create;
  scene.addChild(pLayer, 0);
  CCDirector.sharedDirector.pushScene(scene);
  scene.release;
  pLayer.release;
end;

procedure SceneTestLayer1.onPushSceneTran(pSender: CCObject);
var
  scene: CCScene;
  pLayer: CCLayer;
begin
  scene := SceneTestScene.Create();
  pLayer := SceneTestLayer2.Create;
  scene.addChild(pLayer, 0);
  CCDirector.sharedDirector.pushScene(CCTransitionSlideInT._create(1, scene));
  scene.release;
  pLayer.release;
end;

procedure SceneTestLayer1.onQuit(pSender: CCObject);
begin
    //getCocosApp()->exit();
    //CCDirector::sharedDirector()->popScene();

    //// HA HA... no more terminate on sdk v3.0
    //// http://developer.apple.com/iphone/library/qa/qa2008/qa1561.html
    //if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
    //    [[UIApplication sharedApplication] performSelector:@selector(terminate)];
end;

procedure SceneTestLayer1.testDealloc(dt: Single);
begin
//UXLOG("SceneTestLayer1:testDealloc");
end;

{ SceneTestLayer2 }

constructor SceneTestLayer2.Create;
var
  item1, item2, item3: CCMenuItemFont;
  menu: CCMenu;
  s: CCSize;
  sprite: CCSprite;
  rotate: CCActionInterval;
  rep: CCAction;
begin
  inherited;

  item1 := CCMenuItemFont._create('replaceScene', Self, onReplaceScene);
  item2 := CCMenuItemFont._create('replaceScene w/transition', Self, onReplaceSceneTran);
  item3 := CCMenuItemFont._create('Go Back', Self, onGoBack);
  menu := CCMenu._create([item1, item2, item3]);
  menu.alignItemsVertically();
  addChild(menu);

  s := CCDirector.sharedDirector().getWinSize();
  sprite := CCSprite._create(s_pPathSister1);
  addChild(sprite);
  sprite.setPosition(CCPointMake(s.width-40, s.height/2));
  rotate := CCRotateBy._create(2, 360);
  rep := CCRepeatForever._create(rotate);
  sprite.runAction(rep);

  schedule(testDealloc);
end;

procedure SceneTestLayer2.onGoBack(pSender: CCObject);
begin
  CCDirector.sharedDirector().popScene();
end;

procedure SceneTestLayer2.onReplaceScene(pSender: CCObject);
var
  pScene: CCScene;
  pLayer: CCLayer;
begin
  pScene := SceneTestScene.Create();
  pLayer := SceneTestLayer3._create;
  pScene.addChild(pLayer, 0);
  CCDirector.sharedDirector.replaceScene(pScene);
  pScene.release;
end;

procedure SceneTestLayer2.onReplaceSceneTran(pSender: CCObject);
var
  pScene: CCScene;
  pLayer: CCLayer;
begin
  pScene := SceneTestScene.Create();
  pLayer := SceneTestLayer3._create;
  pScene.addChild(pLayer, 0);
  CCDirector.sharedDirector.replaceScene(CCTransitionFlipX._create(2, pScene));
  pScene.release;
end;

procedure SceneTestLayer2.testDealloc(dt: Single);
begin
    //m_timeCounter += dt;
    //if( m_timeCounter > 10 )
    //    onReplaceScene(this);
end;

{ SceneTestLayer3 }

constructor SceneTestLayer3.Create;
begin
inherited;
end;

function SceneTestLayer3.init: Boolean;
var
  item1, item2, item3: CCMenuItemFont;
  menu: CCMenu;
  s: CCSize;
  sprite: CCSprite;
  rotate: CCActionInterval;
  rep: CCAction;
begin
  if inherited initWithColor(ccc4(0, 0, 255, 255)) then
  begin
    item1 := CCMenuItemFont._create('Touch to pushScene (self)', Self, item0Clicked);
    item2 := CCMenuItemFont._create('Touch to popScene', Self, item1Clicked);
    item3 := CCMenuItemFont._create('Touch to popToRootScene', Self, item2Clicked);
    menu := CCMenu._create([item1, item2, item3]);
    menu.alignItemsVertically();
    addChild(menu);

    s := CCDirector.sharedDirector().getWinSize();
    sprite := CCSprite._create(s_pPathSister2);
    addChild(sprite);
    sprite.setPosition(CCPointMake(s.width/2, 40));

    rotate := CCRotateBy._create(2, 360);
    rep := CCRepeatForever._create(rotate);
    sprite.runAction(rep);

    schedule(testDealloc);

    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure SceneTestLayer3.item0Clicked(pSender: CCObject);
var
  newScene: CCScene;
begin
  newScene := CCScene._create;
  newScene.addChild(SceneTestLayer3._create);
  CCDirector.sharedDirector.pushScene(CCTransitionFade._create(0.5, newScene, ccc3(0, 255, 255)));
end;

procedure SceneTestLayer3.item1Clicked(pSender: CCObject);
begin
  CCDirector.sharedDirector.popScene;
end;

procedure SceneTestLayer3.item2Clicked(pSender: CCObject);
begin
  CCDirector.sharedDirector.popToRootScene;
end;

procedure SceneTestLayer3.testDealloc(dt: Single);
begin
  CCLog('Layer3:testDealloc', []);
end;

class function SceneTestLayer3._create: SceneTestLayer3;
var
  pRet: SceneTestLayer3;
begin
  pRet := SceneTestLayer3.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  pRet.Free;
  Result := nil;
end;

end.
