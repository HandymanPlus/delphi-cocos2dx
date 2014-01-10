unit rotateworldtest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSprite, Cocos2dx.CCNode;

type
  RotateWorldTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  SpriteLayer = class(CCLayer)
  public
    procedure onEnter(); override;
    class function _create(): SpriteLayer;
  end;

  TestLayer = class(CCLayer)
  public
    procedure onEnter(); override;
    class function _create(): TestLayer;
  end;

  RotateWorldMainLayer = class(CCLayer)
  public
    procedure onEnter(); override;
    class function _create(): RotateWorldMainLayer;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension, testResource,
  Cocos2dx.CCTypes, Cocos2dx.CCAction, Cocos2dx.CCActionInterval;

{ RotateWorldTestScene }

procedure RotateWorldTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := RotateWorldMainLayer._create();
  addChild(pLayer);
  runAction(CCRotateBy._create(4, -360));

  CCDirector.sharedDirector().replaceScene(Self);
end;

{ SpriteLayer }

class function SpriteLayer._create: SpriteLayer;
var
  pRet: SpriteLayer;
begin
  pRet := SpriteLayer.Create;
  pRet.init();
  pRet.autorelease();
  Result := pRet;
end;

procedure SpriteLayer.onEnter;
var
  x, y: Single;
  size: CCSize;
  sprite, spritesister1, spritesister2: CCSprite;
  rot: CCAction;
  jump1, jump2: CCFiniteTimeAction;
  rot1, rot2: CCFiniteTimeAction;
begin
  inherited;
  size := CCDirector.sharedDirector().getWinSize();
  x := size.width;
  y := size.height;

  sprite := CCSprite._create(s_pPathGrossini);
  spritesister1 := CCSprite._create(s_pPathSister1);
  spritesister2 := CCSprite._create(s_pPathSister2);

  sprite.Scale := 1.5;
  spritesister1.Scale := 1.5;
  spritesister2.Scale := 1.5;

  sprite.setPosition(CCPointMake(x/2, y/2));
  spritesister1.setPosition(CCPointMake(40, y/2));
  spritesister2.setPosition(CCPointMake(x-40, y/2));

  rot := CCRotateBy._create(16, -3600);

  addChild(sprite); addChild(spritesister1); addChild(spritesister2);

  sprite.runAction(rot);

  jump1 := CCJumpBy._create(4, CCPointMake(-400, 0), 100, 4);
  jump2 := jump1.reverse();

  rot1 := CCRotateBy._create(4, 360*2);
  rot2 := rot1.reverse();

  spritesister1.runAction( CCRepeat._create( CCSequence._create([jump2, jump1]), 5) );
  spritesister2.runAction( CCRepeat._create( CCSequence._create([CCFiniteTimeAction(jump1.copy().autorelease()), CCFiniteTimeAction(jump2.copy().autorelease())]),5 ));
  spritesister1.runAction(CCRepeat._create(CCSequence._create([rot1, rot2]), 5));
  spritesister2.runAction(CCRepeat._create(CCSequence._create([ CCFiniteTimeAction(rot2.copy().autorelease()),  CCFiniteTimeAction(rot1.copy().autorelease()) ]), 5));
end;

{ TestLayer }

class function TestLayer._create: TestLayer;
var
  pRet: TestLayer;
begin
  pRet := TestLayer.Create;
  pRet.init();
  pRet.autorelease();
  Result := pRet;
end;

procedure TestLayer.onEnter;
var
  x, y: Single;
  size: CCSize;
  pLabel: CCLabelTTF;
begin
  inherited;
  size := CCDirector.sharedDirector().getWinSize();
  x := size.width;
  y := size.height;
  pLabel := CCLabelTTF._create('cocos2d', 'Tahoma', 64);
  pLabel.setPosition(CCPointMake(x/2, y/2));
  addChild(pLabel);
end;

{ RotateWorldMainLayer }

class function RotateWorldMainLayer._create: RotateWorldMainLayer;
var
  pRet: RotateWorldMainLayer;
begin
  pRet := RotateWorldMainLayer.Create;
  pRet.init;
  pRet.autorelease();
  Result := pRet;
end;

procedure RotateWorldMainLayer.onEnter;
var
  x, y: Single;
  size: CCSize;
  blue, red, green, white: CCNode;
  rot: CCAction;
begin
  inherited;
  size := CCDirector.sharedDirector().getWinSize();
  x := size.width; y := size.height;

  blue := CCLayerColor._create(ccc4(0, 0, 255, 255));
  red := CCLayerColor._create(ccc4(255, 0, 0, 255));
  green := CCLayerColor._create(ccc4(0, 255, 0, 255));
  white := CCLayerColor._create(ccc4(255, 255, 255, 255));

  blue.Scale := 0.5;
  blue.setPosition(CCPointMake(-x/4, -y/4));
  blue.addChild(SpriteLayer._create);

  red.Scale := 0.5;
  red.setPosition(CCPointMake(x/4, -y/4));

  green.Scale := 0.5;
  green.setPosition(CCPointMake(-x/4, y/4));
  green.addChild(TestLayer._create);

  white.Scale := 0.5;
  white.setPosition(ccp(x/4, y/4));
  white.ignoreAnchorPointForPosition(False);
  white.setPosition(ccp(x/4*3, y/4*3));

  addChild(blue, -1); addChild(white); addChild(green); addChild(red);

  rot := CCRotateBy._create(8, 720);
  blue.runAction(rot);
  red.runAction(CCAction(rot.copy.autorelease));
  green.runAction(CCAction(rot.copy.autorelease));
  white.runAction(CCAction(rot.copy.autorelease));
end;

end.
