unit box2dtest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCTouch, Cocos2dx.CCSet, Cocos2dx.CCTexture2D, Cocos2dx.CCSprite,
  Cocos2dx.CCSpriteBatchNode, Cocos2dx.CCNode, UPhysics2D, Cocos2dx.CCAffineTransform;

type
  PhusicsSprite = class(CCSprite)
  public
    constructor Create();
    procedure setPhysicsBody(body: Tb2Body);
    function isDirty(): Boolean; override;
    function nodeToParentTransform(): CCAffineTransform; override;
  private
    m_pBody: Tb2Body;
  end;

  Box2dTestLayer = class(CCLayer)
  public
    m_pSpriteTexture: CCTexture2D;
    world: Tb2World;
    constructor Create();
    destructor Destroy(); override;
    procedure initPhysics();
    procedure createResetButton();
    procedure reset(sender: CCObject);
    procedure draw(); override;
    procedure addNewSpriteAtPosition(p: CCPoint);
    procedure update(dt: Single); override;
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); override;
  end;

  Box2dTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

implementation
uses
  SysUtils, UPhysics2DTypes,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension,
  Cocos2dx.CCMenuItem, Cocos2dx.CCMenu,
  Cocos2dx.CCTypes, Cocos2dx.CCActionInterval;

const kTagParentNode = 1;
const PTM_RATIO = 32;

{ Box2dTestScene }

procedure Box2dTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := Box2dTestLayer.Create();
  addChild(pLayer);
  pLayer.release();
  CCDirector.sharedDirector().replaceScene(Self);
end;

{ PhusicsSprite }

constructor PhusicsSprite.Create;
begin
  inherited;
end;

function PhusicsSprite.isDirty: Boolean;
begin
  Result := True;
end;

function PhusicsSprite.nodeToParentTransform: CCAffineTransform;
var
  pos: TVector2;
  x, y: Single;
  radians, c, s: Single;
begin
  pos := m_pBody.GetPosition;
  x := pos.x * PTM_RATIO;
  y := pos.y * PTM_RATIO;

  if isIgnoreAnchorPointForPosition then
  begin
    x := x + m_obAnchorPointInPoints.x;
    y := y + m_obAnchorPointInPoints.y;
  end;

  radians := m_pBody.GetAngle;
  c := Cos(radians);
  s := Sin(radians);

  if not m_obAnchorPointInPoints.equal(CCPointZero) then
  begin
    x := x - m_obAnchorPointInPoints.x * c + m_obAnchorPointInPoints.y * s;
    y := y - m_obAnchorPointInPoints.x * s - m_obAnchorPointInPoints.y * c;
  end;

  m_sTransform := CCAffineTransformMake(c, s, -s, c, x, y);
  Result := m_sTransform;
  
end;

procedure PhusicsSprite.setPhysicsBody(body: Tb2Body);
begin
  m_pBody := body;
end;

{ Box2dTestLayer }

procedure Box2dTestLayer.addNewSpriteAtPosition(p: CCPoint);
var
  pparent: CCNode;
  idx, idy: Integer;
  sprite: PhusicsSprite;
  bodyDef: Tb2BodyDef;
  body: Tb2Body;
  dynamicBox: Tb2PolygonShape;
  fixtureDef: Tb2FixtureDef;
  fran: Single;
begin
  pparent := getChildByTag(kTagParentNode);

  fran := Random;
  if fran > 0.5 then
    idx := 0
  else
    idx := 1;

  fran := Random;
  if fran > 0.5 then
    idy := 0
  else
    idy := 1;

  sprite := PhusicsSprite.Create;
  sprite.initWithTexture(m_pSpriteTexture, CCRectMake(32*idx, 32*idy, 32, 32));
  sprite.autorelease();

  pparent.addChild(sprite);
  sprite.setPosition(CCPointMake(p.x, p.y));

  bodyDef := Tb2BodyDef.Create;
  bodyDef.bodyType := b2_dynamicBody;
  bodyDef.position.x := p.x/PTM_RATIO; bodyDef.position.y := p.y/PTM_RATIO;
  body := world.CreateBody(bodyDef);

  dynamicBox := Tb2PolygonShape.Create;
  dynamicBox.SetAsBox(0.5, 0.5);

  fixtureDef := Tb2FixtureDef.Create;
  fixtureDef.shape := dynamicBox;
  fixtureDef.density := 1.0;
  fixtureDef.friction := 0.3;
  body.CreateFixture(fixtureDef);

  sprite.setPhysicsBody(body);
end;

procedure Box2dTestLayer.ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent);
var
  i: Integer;
  pTouch: CCTouch;
  location: CCPoint;
begin
  inherited;
  for i := 0 to pTouches.count()-1 do
  begin
    pTouch := CCTouch(pTouches.getObject(i));
    if pTouch = nil then
      Break;

    location := pTouch.getLocation();
    addNewSpriteAtPosition(location);
  end;
end;

constructor Box2dTestLayer.Create;
var
  s: CCSize;
  pparent: CCSpriteBatchNode;
  pLabel: CCLabelTTF;
begin
  inherited Create();
  setTouchEnabled(True);
  s := CCDirector.sharedDirector().getWinSize();
  Self.initPhysics();
  Self.createResetButton();

  pparent := CCSpriteBatchNode._create('Images/blocks.png', 100);
  m_pSpriteTexture := pparent.getTexture();

  addChild(pparent, 0, kTagParentNode);
  addNewSpriteAtPosition(ccp(s.width/2, s.height/2));

  pLabel := CCLabelTTF._create('Tap screen', 'Marker Felt', 32);
  addChild(pLabel, 0);
  pLabel.setColor(ccc3(0, 0, 255));
  pLabel.setPosition(ccp(s.width/2, s.height-50));

  scheduleUpdate();

  Randomize();
end;

procedure Box2dTestLayer.createResetButton;
var
  preset: CCMenuItemImage;
  menu: CCMenu;
  s: CCSize;
begin
  preset := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, reset);
  menu := CCMenu._create([preset]);
  s := CCDirector.sharedDirector().getWinSize();

  menu.setPosition(ccp(s.width/2, 30));
  Self.addChild(menu, -1);
end;

destructor Box2dTestLayer.Destroy;
begin
  world.Free;
  world := nil;
  inherited;
end;

procedure Box2dTestLayer.draw;
begin
  inherited;
  {ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
  kmGLPushMatrix();
  world.DrawDebugData();
  kmGLPopMatrix(); }
end;

procedure Box2dTestLayer.initPhysics;
var
  s: CCSize;
  gravity: TVector2;
  //flags: Cardinal;
  groundBodyDef: Tb2BodyDef;
  groundBody: Tb2Body;
  groundBox: Tb2EdgeShape;
begin
  s := CCDirector.sharedDirector().getWinSize();
  gravity.x := 0; gravity.y := -10;

  world := Tb2World.Create(gravity);
  world.AllowSleeping := True;
  world.ContinuousPhysics := True;

  groundBodyDef := Tb2BodyDef.Create;
  groundBodyDef.position.x := 0;
  groundBodyDef.position.y := 0;

  groundBody := world.CreateBody(groundBodyDef);

  groundBox := Tb2EdgeShape.Create;

  groundBox.SetVertices(MakeVector(0, 0), MakeVector(s.width/PTM_RATIO, 0));
  groundBody.CreateFixture(groundBox, 0, False, False);

  groundBox.SetVertices(MakeVector(0, s.height/PTM_RATIO), MakeVector(s.width/PTM_RATIO, s.height/PTM_RATIO));
  groundBody.CreateFixture(groundBox, 0, False, False);

  groundBox.SetVertices(MakeVector(0, s.height/PTM_RATIO), MakeVector(0, 0));
  groundBody.CreateFixture(groundBox, 0, False, False);

  groundBox.SetVertices(MakeVector(s.width/PTM_RATIO, s.height/PTM_RATIO), MakeVector(s.width/PTM_RATIO, 0));
  groundBody.CreateFixture(groundBox, 0);
end;

procedure Box2dTestLayer.reset(sender: CCObject);
var
  s: CCScene;
  child: Box2dTestLayer;
begin
  s := Box2dTestScene.Create();
  child := Box2dTestLayer.Create;
  s.addChild(child);
  child.release();
  CCDirector.sharedDirector().replaceScene(s);
  s.release();
end;

procedure Box2dTestLayer.update(dt: Single);
begin
  world.Step(dt, 8, 1);
end;

end.
