unit testBasic;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCScene;

type
  TestScene = class(CCScene)
  public
    constructor Create(bPortrait: Boolean = False);
    procedure onEnter(); override;
    procedure runThisTest(); dynamic; abstract;
    procedure MainMenuCallback(pObj: CCObject);
  end;

implementation
uses
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, Cocos2dx.CCLabelTTF, Cocos2dx.CCLayer,
  Cocos2dx.CCGeometry, Cocos2dx.CCDirector, controller;

{ TestScene }

constructor TestScene.Create(bPortrait: Boolean);
begin
  inherited Create();
  inherited init();
end;

procedure TestScene.MainMenuCallback(pObj: CCObject);
var
  pScene: CCScene;
  pLayer: CCLayer;
begin
  pScene := CCScene._create();
  pLayer := TestController.Create();
  pLayer.autorelease();

  pScene.addChild(pLayer);
  CCDirector.sharedDirector().replaceScene(pScene);
end;

procedure TestScene.onEnter;
var
  pLabel: CCLabelTTF;
  pMenuItem: CCMenuItemLabel;
  pMenu: CCMenu;
  s: CCSize;
begin
  inherited onEnter();

  pLabel := CCLabelTTF._create('MainMenu', 'Arial', 20);
  pMenuItem := CCMenuItemLabel._create(pLabel, Self, MainMenuCallback);

  pMenu := CCMenu._create([pMenuItem]);
  s := CCDirector.sharedDirector().getWinSize();
  pMenu.setPosition(CCPointZero);
  pMenuItem.setPosition(CCPointMake(s.width-50, 25));

  addChild(pMenu, 1);
end;

end.
