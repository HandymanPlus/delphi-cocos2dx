unit clickandmovetest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCTouch, Cocos2dx.CCSet, Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCTextureAtlas;

type
  ClickAndMoveTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  MainLayer = class(CCLayer)
  public
    constructor Create();
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCDirector, testResource,
  Cocos2dx.CCTypes, Cocos2dx.CCAction, Cocos2dx.CCActionInterval, Cocos2dx.CCMacros;


const    kTagSprite = 1;


{ ClickAndMoveTestScene }

procedure ClickAndMoveTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := MainLayer.Create();
  pLayer.autorelease();

  addChild(pLayer);
  CCDirector.sharedDirector().replaceScene(Self);
end;

{ MainLayer }

procedure MainLayer.ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent);
var
  pTouch: CCTouch;
  location: CCPoint;
  s: CCNode;
  o, a, at: Single;
begin
  inherited;

  pTouch := CCTouch(pTouches.getObject(0));

  location := pTouch.getLocation();

  s := getChildByTag(kTagSprite);
  s.stopAllActions();
  s.runAction( CCMoveTo._create(1, CCPointMake(location.x, location.y))  );

  o := location.x - s.getPosition().x;
  a := location.y - s.getPosition().y;
  at := CC_RADIANS_TO_DEGREES(ArcTan(o/a));

  if a <0 then
  begin
    if o < 0 then
      at := 180 + Abs(at)
    else
      at := 180 - Abs(at);
  end;

  s.runAction( CCRotateTo._create(1, at) );
end;

constructor MainLayer.Create;
var
  sprite: CCSprite;
  layer: CCLayer;
begin
  inherited;
  setTouchEnabled(True);

  sprite := CCSprite._create(s_pPathGrossini);

  layer := CCLayerColor._create(ccc4(255, 255, 0, 255));
  addChild(layer, -1);

  addChild(sprite, 0, kTagSprite);
  sprite.setPosition(CCPointMake(20, 150));

  sprite.runAction( CCJumpTo._create(4, CCPointMake(300, 48), 100, 4 ));
  layer.runAction( CCRepeatForever._create(
      CCActionInterval(CCSequence._create([CCFadeIn._create(1),
      CCFadeOut._create(1)   ]))
      )
    )
end;

end.
