unit rendertexturetest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCTouch, Cocos2dx.CCSet, Cocos2dx.CCTexture2D, Cocos2dx.CCSprite,
  Cocos2dx.CCSpriteBatchNode, Cocos2dx.CCNode, Cocos2dx.CCRenderTexture;

type
  rendertextureTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  rendertextureTestDemo = class(CCLayer)
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

  RenderTextureSave = class(rendertextureTestDemo)
  public
    constructor Create();
    destructor Destroy(); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent); override;
    procedure clearImage(pSender: CCObject);
    procedure saveImage(pSender: CCObject);
  private
    m_pTarget: CCRenderTexture;
    m_pBrush: CCSprite;
  end;

  RenderTextureIssue937 = class(rendertextureTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

  RenderTextureZbuffer = class(rendertextureTestDemo)
  public
    constructor Create();
    procedure ccTouchesBegan(pTouches: CCSet; pEvent: CCEvent); override;
    procedure ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent); override;
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
    function title(): string; override;
    function subtitle(): string; override;
    procedure renderScreenShot();
  private
    mgr: CCSpriteBatchNode;
    sp1: CCSprite;
    sp2: CCSprite;
    sp3: CCSprite;
    sp4: CCSprite;
    sp5: CCSprite;
    sp6: CCSprite;
    sp7: CCSprite;
    sp8: CCSprite;
    sp9: CCSprite;
  end;

  RenderTextureTestDepthStencil = class(rendertextureTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
  end;

implementation
uses
  SysUtils, dglOpenGL,
  Cocos2dx.CCActionInstant,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension, Cocos2dx.CCMenuItem,
  Cocos2dx.CCMenu,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCTextureCache,
  Cocos2dx.CCTypes, Cocos2dx.CCActionInterval;

var
  sceneIdx: Integer = -1;
const
  MAX_LAYER = 4;

function createTestLayer(nIndex: Integer): CCLayer;
var
  bRet: CCLayer;
begin
  bRet := nil;
  case nIndex of
    0: bRet := RenderTextureSave.Create;
    1: bRet := RenderTextureIssue937.Create;
    2: bRet := RenderTextureZbuffer.Create;
    3: bRet := RenderTextureTestDepthStencil.Create;
  end;

  Result := bRet;
end;  

function nextTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;

  pLayer := createTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function backTestAction(): CCLayer;
var
  pLayer: CCLayer;
  total: Integer;
begin
  Dec(sceneIdx);
  total := MAX_LAYER;
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + total;

  pLayer := createTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

function restartTestAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createTestLayer(sceneIdx);
  pLayer.autorelease();

  Result := pLayer;
end;

{ rendertextureTestScene }

procedure rendertextureTestScene.runThisTest;
begin
    addChild(nextTestAction());
    CCDirector.sharedDirector().replaceScene(Self);

end;

{ rendertextureTestDemo }

procedure rendertextureTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := rendertextureTestScene.Create();
  s.addChild(backTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

constructor rendertextureTestDemo.Create;
begin
inherited;
end;

destructor rendertextureTestDemo.Destroy;
begin

  inherited;
end;

procedure rendertextureTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := rendertextureTestScene.Create();
  s.addChild(nextTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

procedure rendertextureTestDemo.onEnter;
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

procedure rendertextureTestDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := rendertextureTestScene.Create();
  s.addChild(restartTestAction());
  CCDirector.sharedDirector.replaceScene(s);
  s.release();
end;

function rendertextureTestDemo.subtitle: string;
begin
  Result := '';
end;

function rendertextureTestDemo.title: string;
begin
  Result := 'No title';
end;

{ RenderTextureSave }

procedure RenderTextureSave.ccTouchesMoved(pTouches: CCSet;
  pEvent: CCEvent);
var
  touch: CCTouch;
  start, _end: CCPoint;
  distance: Single;
  d: Integer;
  i: Integer;
  difx, dify, delta{, r}: Single;
begin
  touch := CCTouch(pTouches.anyObject());
  start := touch.getLocation;
  _end := touch.GetPreviousLocation;

  m_pTarget._begin();
  distance := ccpDistance(start, _end);
  if distance > 1 then
  begin
    d := Round(distance);
    for i := 0 to d-1 do
    begin
      difx := _end.x - start.x;
      dify := _end.y - start.y;
      delta := i/distance;

      m_pBrush.setPosition(ccp(start.x+(difx*delta), start.y + (dify*delta)));
      //m_pBrush.setRotation(Random/360);

      //m_pBrush.Scale := 1;
      m_pBrush.setColor(ccc3(128, 255, 255));
      m_pBrush.visit;
    end;  
  end;
  m_pTarget._end();
end;

procedure RenderTextureSave.clearImage(pSender: CCObject);
begin
  m_pTarget.clear(Random, Random, Random, Random);
end;

constructor RenderTextureSave.Create;
var
  s: CCSize;
  item1, item2: CCMenuItem;
  menu: CCMenu;
begin
  inherited Create();

  s := CCDirector.sharedDirector().getWinSize();

  m_pTarget := CCRenderTexture._create(Round(s.width), Round(s.height), kCCTexture2DPixelFormat_RGBA8888);
  m_pTarget.retain();
  m_pTarget.setPosition(ccp(s.width/2, s.height/2));

  Self.addChild(m_pTarget, -1);

  m_pBrush := CCSprite._create('Images/fire.png');
  m_pBrush.retain();
  m_pBrush.setColor( ccRED);
  m_pBrush.setOpacity(20);
  Self.setTouchEnabled(True);

  CCMenuItemFont.setFontSize(16);
  item1 := CCMenuItemFont._create('Save Image', Self, saveImage);
  item2 := CCMenuItemFont._create('Clear', Self, clearImage);
  menu := CCMenu._create([item1, item2]);
  Self.addChild(menu);
  menu.alignItemsVertically();
  menu.setPosition(ccp(s.width - 80, s.height - 30));

  Randomize;
end;

destructor RenderTextureSave.Destroy;
begin
  CC_SAFE_RELEASE(m_pBrush);
  CC_SAFE_RELEASE(m_pTarget);
  CCTextureCache.sharedTextureCache().removeUnusedTextures();
  inherited;
end;

procedure RenderTextureSave.saveImage(pSender: CCObject);
begin

end;

function RenderTextureSave.subtitle: string;
begin
  Result := 'Press "Save Image" to create an snapshot of the render texture';
end;

function RenderTextureSave.title: string;
begin
  Result := 'Touch the screen';
end;

{ RenderTextureIssue937 }

constructor RenderTextureIssue937.Create;
var
  background: CCLayerColor;
  spr_premulti, spr_nonpremulti: CCSprite;
  rend: CCRenderTexture;
  s: CCSize;
begin
  inherited;

  background := CCLayerColor._create(ccc4(200, 200, 200, 255));
  addChild(background);

  spr_premulti := CCSprite._create('Images/fire.png');
  spr_premulti.setPosition(ccp(16, 48));

  spr_nonpremulti := CCSprite._create('Images/fire.png');
  spr_nonpremulti.setPosition(ccp(16, 16));

  rend := CCRenderTexture._create(32, 64, kCCTexture2DPixelFormat_RGBA8888);
  if rend = nil then
    Exit;

  rend._begin();
  spr_premulti.visit();
  spr_nonpremulti.visit();
  rend._end();

  s := CCDirector.sharedDirector().getWinSize();
  spr_premulti.setPosition(ccp(s.width/2-16, s.height/2+16));
  spr_nonpremulti.setPosition(ccp(s.width/2-16, s.height/2-16));
  rend.setPosition(ccp(s.width/2+16, s.height/2));

  addChild(spr_nonpremulti);
  addChild(spr_premulti);
  addChild(rend);
end;

function RenderTextureIssue937.subtitle: string;
begin
  Result := 'All images should be equal...';
end;

function RenderTextureIssue937.title: string;
begin
  Result := 'Testing issue #937';
end;

{ RenderTextureZbuffer }

procedure RenderTextureZbuffer.ccTouchesBegan(pTouches: CCSet;
  pEvent: CCEvent);
var
  i: Integer;
  touch: CCTouch;
  location: CCPoint;
begin
  for i := 0 to pTouches.count()-1 do
  begin
    touch := CCTouch(pTouches.getObject(i));
    location := touch.getLocation;

    sp1.setPosition(location);
    sp2.setPosition(location);
    sp3.setPosition(location);
    sp4.setPosition(location);
    sp5.setPosition(location);
    sp6.setPosition(location);
    sp7.setPosition(location);
    sp8.setPosition(location);
    sp9.setPosition(location);
  end;  
end;

procedure RenderTextureZbuffer.ccTouchesEnded(pTouches: CCSet;
  pEvent: CCEvent);
begin
  Self.renderScreenShot();
end;

procedure RenderTextureZbuffer.ccTouchesMoved(pTouches: CCSet;
  pEvent: CCEvent);
var
  i: Integer;
  touch: CCTouch;
  location: CCPoint;
begin
  for i := 0 to pTouches.count()-1 do
  begin
    touch := CCTouch(pTouches.getObject(i));
    location := touch.getLocation;

    sp1.setPosition(location);
    sp2.setPosition(location);
    sp3.setPosition(location);
    sp4.setPosition(location);
    sp5.setPosition(location);
    sp6.setPosition(location);
    sp7.setPosition(location);
    sp8.setPosition(location);
    sp9.setPosition(location);
  end;
end;

constructor RenderTextureZbuffer.Create;
var
  size: CCSize;
  label1, label2, label3: CCLabelTTF;
begin
  inherited;
  Self.setTouchEnabled(True);
  size := CCDirector.sharedDirector().getWinSize();
  label1 := CCLabelTTF._create('vertexZ = 50', 'Marker Felt', 64);
  label1.setPosition(ccp(size.width/2, size.height * 0.25));
  addChild(label1);

  label2 := CCLabelTTF._create('vertexZ = 0', 'Marker Felt', 64);
  label2.setPosition(ccp(size.width/2, size.height * 0.5));
  addChild(label2);

  label3 := CCLabelTTF._create('vertexZ = -50', 'Marker Felt', 64);
  label3.setPosition(ccp(size.width/2, size.height * 0.75));
  addChild(label3);

  label1.setVerteZ(50);
  label2.setVerteZ(0);
  label3.setVerteZ(-50);

  //CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile('');
  mgr := CCSpriteBatchNode._create('Images/bugs/circle.png', 9);
  Self.addChild(mgr);
  sp1 := CCSprite.createWithTexture(mgr.getTexture());
  sp2 := CCSprite.createWithTexture(mgr.getTexture());
  sp3 := CCSprite.createWithTexture(mgr.getTexture());
  sp4 := CCSprite.createWithTexture(mgr.getTexture());
  sp5 := CCSprite.createWithTexture(mgr.getTexture());
  sp6 := CCSprite.createWithTexture(mgr.getTexture());
  sp7 := CCSprite.createWithTexture(mgr.getTexture());
  sp8 := CCSprite.createWithTexture(mgr.getTexture());
  sp9 := CCSprite.createWithTexture(mgr.getTexture());

  mgr.addChild(sp1, 9);
  mgr.addChild(sp2, 8);
  mgr.addChild(sp3, 7);
  mgr.addChild(sp4, 6);
  mgr.addChild(sp5, 5);
  mgr.addChild(sp6, 4);
  mgr.addChild(sp7, 3);
  mgr.addChild(sp8, 2);
  mgr.addChild(sp9, 1);

  sp1.setVerteZ(400);
  sp2.setVerteZ(300);
  sp3.setVerteZ(200);
  sp4.setVerteZ(100);
  sp5.setVerteZ(0);
  sp6.setVerteZ(-100);
  sp7.setVerteZ(-200);
  sp8.setVerteZ(-300);
  sp9.setVerteZ(-400);

  sp9.Scale := 2;
  sp9.setColor(ccYELLOW);
end;

procedure RenderTextureZbuffer.renderScreenShot;
var
  texture: CCRenderTexture;
  sprite: CCSprite;
begin
  texture := CCRenderTexture._create(512, 512);
  if texture = nil then
    Exit;

  texture.AnchorPoint := CCPointZero;
  texture._begin();
  Self.visit();
  texture._end();

  sprite := CCSprite.createWithTexture(texture.Sprite.getTexture());

  sprite.setPosition(ccp(256, 256));
  sprite.setOpacity(182);
  sprite.setFlipY(True);
  addChild(sprite, 999999);
  sprite.setColor(ccGREEN);
  sprite.runAction(CCSequence._create([ CCFadeTo._create(2, 0), CCHide._create() ]));
end;

function RenderTextureZbuffer.subtitle: string;
begin
  Result := 'Touch screen. It should be green';
end;

function RenderTextureZbuffer.title: string;
begin
  Result := 'Testing Z Buffer in Render Texture';
end;

{ RenderTextureTestDepthStencil }

constructor RenderTextureTestDepthStencil.Create;
var
  s: CCSize;
  sprite: CCSprite;
  rend: CCRenderTexture;
begin
  inherited Create;
  s := CCDirector.sharedDirector().getWinSize();
  sprite := CCSprite._create('Images/fire.png');
  sprite.setPosition(ccp(s.width*0.25, 0));
  sprite.Scale := 10;

  rend := CCRenderTexture._create(Round(s.width), Round(s.height), kCCTexture2DPixelFormat_RGBA4444, GL_DEPTH24_STENCIL8);
  glStencilMask($FF);
  rend.beginWithClear(0, 0, 0, 0, 0, 0);

  glEnable(GL_STENCIL_TEST);
  glStencilFunc(GL_ALWAYS, 1, $FF);
  glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
  glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
  sprite.visit();

  sprite.setPosition(ccpAdd(sprite.getPosition(), ccpMult(ccp(sprite.ContentSize.width * sprite.Scale, sprite.ContentSize.height * sprite.Scale), 0.5)));
  glStencilFunc(GL_NOTEQUAL, 1, $FF);
  glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
  sprite.visit();
  rend._end;

  glDisable(GL_STENCIL_TEST);
  rend.setPosition(ccp(s.width*0.5, s.height * 0.5));
  addChild(rend);
end;

function RenderTextureTestDepthStencil.subtitle: string;
begin
  Result := 'Circle should be missing 1/4 of its region';
end;

function RenderTextureTestDepthStencil.title: string;
begin
  Result := 'Testing depthStencil attachment';
end;

end.
