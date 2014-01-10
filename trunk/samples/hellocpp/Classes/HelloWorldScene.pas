unit HelloWorldScene;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, Cocos2dx.CCPlatformMacros,
  Cocos2dx.CCSprite, Cocos2dx.CCSet;

type
  HelloWorld = class(CCLayer)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure onEnter(); override;
    function init(): Boolean; override;
    //procedure draw(); override;
    class function scene(): CCScene;
    class function _create(): HelloWorld;
    procedure closeCallback(pObj: CCObject);
  end;

implementation
uses
  Cocos2dx.CCGeometry, Cocos2dx.CCDirector, Cocos2dx.CCPointExtension,
  Cocos2dx.CCDrawingPrimitives,Cocos2dx.CCMacros, Cocos2dx.CCTypes,
  Cocos2dx.CCLabelTTF, Cocos2dx.CCMenuItem, Cocos2dx.CCMenu,
  Cocos2dx.CCActionInterval;

{ HelloWorld }

class function HelloWorld._create: HelloWorld;
var
  pRet: HelloWorld;
begin
  pRet := HelloWorld.Create();
  if (pRet <> nil) and pRet.init() then
    pRet.autorelease()
  else
    CC_SAFE_DELETE(pRet);

  Result := pRet;
end;

constructor HelloWorld.Create;
begin
  inherited Create();
end;

function HelloWorld.init: Boolean;
begin

  Result := True;
end;

class function HelloWorld.scene: CCScene;
var
  scene: CCScene;
  layer: HelloWorld;
begin
  scene := CCScene._Create();
  if scene = nil then
  begin
    Result := nil;
    Exit;
  end;
  layer := HelloWorld._create();
  if layer = nil then
  begin
    Result := nil;
    Exit;
  end;

  scene.addChild(layer);

  Result := scene;
end;


procedure HelloWorld.closeCallback(pObj: CCObject);
begin
  CCDirector.sharedDirector()._end();
end;

destructor HelloWorld.Destroy;
begin

  inherited;
end;

{procedure HelloWorld.draw;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector.getVisibleSize;
  ccDrawLine(ccp(0, 0), ccp(s.width, s.height));
end;}

procedure HelloWorld.onEnter;
var
  visibleSize: CCSize;
  origin: CCPoint;
  pSprite: CCSprite;
  pCloseItem: CCMenuItemImage;
  pMenu: CCMenu;
begin
  inherited;
  //在IOS平台上，程序还跑不起来，把下面的代码注释掉，用上面的draw代码调试.并注释掉Cocos2dx.CCDirector中的所有createStatsLabel函数
  visibleSize := CCDirector.sharedDirector().getVisibleSize();
  origin := CCDirector.sharedDirector.getVisibleOrigin;

  pSprite := CCSprite._create('HelloWorld.png');
  pSprite.setPosition(ccp(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));
  addChild(pSprite);

  pCloseItem := CCMenuItemImage._create('CloseNormal.png', 'CloseSelected.png', Self, closeCallback);
  pCloseItem.setPosition(ccp(origin.x + visibleSize.width - pCloseItem.ContentSize.width/2,
                             origin.y + pCloseItem.ContentSize.height/2));
  pMenu := CCMenu._create([pCloseItem]);
  pMenu.setPosition(CCPointZero);
  addChild(pMenu, 1);
end;

end.
