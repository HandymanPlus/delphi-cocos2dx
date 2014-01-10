unit shadertest;

interface
uses
  dglOpenGL, Cocos2dx.CCControlSlider, Cocos2dx.CCTexture2D, Cocos2dx.CCInvocation, Cocos2dx.CCControl,
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry, Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCLabelTTF, Cocos2dx.CCTypes;

type
  ShaderTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  ShaderTestDemo = class(CCLayer)
  public
    constructor Create();
    class function _create(): ShaderTestDemo;
    function title(): string; dynamic;
    function subtitle(): string; dynamic;
    function init(): Boolean; override;

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
  end;

  ShaderMonjori = class(ShaderTestDemo)
  public
    constructor Create();
    //class function _create(): ShaderTestDemo;
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
  end;

  ShaderMandelbrot = class(ShaderTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
  end;

  ShaderJulia = class(ShaderTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
  end;

  ShaderHeart = class(ShaderTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
  end;

  ShaderFlower = class(ShaderTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
  end;

  ShaderPlasma = class(ShaderTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
  end;

  ShaderRetroEffect = class(ShaderTestDemo)
  public
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
    procedure update(time: Single); override;
  protected
    m_pLabel: CCLabelTTF;
    m_fAccum: Single;
  end;

  ShaderNode = class(CCNode)
  public
    constructor Create();
    function initWithVertex(const vert, frag: string): Boolean;
    procedure loadShaderVertex(const vert, frag: string);
    procedure update(time: Single); override;
    procedure setPosition(const newPosition: CCPoint); override;
    procedure draw(); override;
    class function shaderNodeWithVertex(const vert, frag: string): ShaderNode;
  private
    m_center: ccVertex2F;
    m_resoulution: ccVertex2F;
    m_time: Single;
    m_uniformCenter, m_uniformResolution, m_uniformTime: Cardinal;
  end;

  SpriteBlur = class(CCSprite)
  public
    blur_: CCPoint;
    sub_: array [0..3] of GLfloat;
    blurLocation, subLocation: GLuint;
    procedure setBlurSize(r: Single);
    function initWithTexture(pTexture: CCTexture2D; const rect: CCRect): Boolean; override;
    procedure draw(); override;
    class function _create(const pszFilename: string): SpriteBlur;
  end;

  ShaderBlur = class(ShaderTestDemo)
  protected
    m_pBlurSprite: SpriteBlur;
    m_pSliderCtl: CCControlSlider;
  public
    function createSliderCtl(): CCControlSlider;
    procedure sliderAction(pSender: CCObject; controlEvent: CCControlEvent);
    constructor Create();
    function title(): string; override;
    function subtitle(): string; override;
    function init(): Boolean; override;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCMacros, Cocos2dx.CCGLStateCache, Cocos2dx.CCString, Cocos2dx.CCFileUtils, Cocos2dx.CCShaders,
  Cocos2dx.CCDirector, Cocos2dx.CCPointExtension, Cocos2dx.CCMenuItem, Cocos2dx.CCMenu, Cocos2dx.CCGLProgram;

var sceneIdx: Integer = -1;
const MAX_LAYER = 8;

function createShaderLayer(nIndex: Integer): CCLayer;
begin
  Result := nil;
  case nIndex of
    0: Result := ShaderMonjori.Create;
    1: Result := ShaderMandelbrot.Create;
    2: Result := ShaderJulia.Create;
    3: Result := ShaderHeart.Create;
    4: Result := ShaderFlower.Create;
    5: Result := ShaderPlasma.Create;
    6: Result := ShaderBlur.Create;
    7: Result := ShaderRetroEffect.Create;
  end;
end;

function nextAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Inc(sceneIdx);
  sceneIdx := sceneIdx mod MAX_LAYER;
  pLayer := createShaderLayer(sceneIdx);
  pLayer.autorelease;
  Result := pLayer;
end;

function backAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  Dec(sceneIdx);
  if sceneIdx < 0 then
    sceneIdx := sceneIdx + MAX_LAYER;
  pLayer := createShaderLayer(sceneIdx);
  pLayer.autorelease;
  Result := pLayer;
end;

function restartAction(): CCLayer;
var
  pLayer: CCLayer;
begin
  pLayer := createShaderLayer(sceneIdx);
  pLayer.autorelease;
  Result := pLayer;
end;  

{ ShaderTestScene }

procedure ShaderTestScene.runThisTest;
begin
  sceneIdx := -1;
  addChild(nextAction);
  CCDirector.sharedDirector.replaceScene(Self);
end;

{ ShaderTestDemo }

procedure ShaderTestDemo.backCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ShaderTestScene.Create();
  s.addChild(backAction);
  CCDirector.sharedDirector.replaceScene(s);
  s.release;
end;

constructor ShaderTestDemo.Create;
begin
  inherited;
end;

function ShaderTestDemo.init: Boolean;
var
  s: CCSize;
  label1, label2: CCLabelTTF;
  strSubtitle: string;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
begin
  s := CCDirector.sharedDirector().getWinSize;

  label1 := CCLabelTTF._create(title(), 'Arial', 28);
  addChild(label1, 1);
  label1.setPosition(ccp(s.width/2, s.height-50));
  label1.setColor(ccRED);

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

  result := True;
end;

procedure ShaderTestDemo.nextCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ShaderTestScene.Create();
  s.addChild(nextAction);
  CCDirector.sharedDirector.replaceScene(s);
  s.release;
end;

procedure ShaderTestDemo.restartCallback(pObj: CCObject);
var
  s: CCScene;
begin
  s := ShaderTestScene.Create();
  s.addChild(restartAction);
  CCDirector.sharedDirector.replaceScene(s);
  s.release;
end;

function ShaderTestDemo.subtitle: string;
begin
  Result := '';
end;

function ShaderTestDemo.title: string;
begin
  Result := 'No title';
end;

class function ShaderTestDemo._create: ShaderTestDemo;
var
  pret: ShaderTestDemo;
begin
  pret := ShaderTestDemo.Create;
  pret.init;
  pret.autorelease;
  Result := pret;
end;

{ ShaderMonjori }

constructor ShaderMonjori.Create;
begin
  inherited;
  init();
end;

function ShaderMonjori.init: Boolean;
var
  sn: ShaderNode;
  s: CCSize;
begin
  if inherited init() then
  begin
    sn := ShaderNode.shaderNodeWithVertex('Shaders/example_Monjori.vsh', 'Shaders/example_Monjori.fsh');
    s := CCDirector.sharedDirector.getWinSize;
    sn.setPosition(s.width/2, s.height/2);
    addChild(sn);
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ShaderMonjori.subtitle: string;
begin
  Result := 'Monjori plane deformations';
end;

function ShaderMonjori.title: string;
begin
  Result := 'Shader: Frag shader';
end;

{ ShaderMandelbrot }

constructor ShaderMandelbrot.Create;
begin
  inherited;
  init();
end;

function ShaderMandelbrot.init: Boolean;
var
  sn: ShaderNode;
  s: CCSize;
begin
  if inherited init() then
  begin
    sn := ShaderNode.shaderNodeWithVertex('Shaders/example_Mandelbrot.vsh', 'Shaders/example_Mandelbrot.fsh');
    s := CCDirector.sharedDirector.getWinSize;
    sn.setPosition(s.width/2, s.height/2);
    addChild(sn);
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ShaderMandelbrot.subtitle: string;
begin
  Result := 'Mandelbrot shader with Zoom';
end;

function ShaderMandelbrot.title: string;
begin
  Result := 'Shader: Frag shader';
end;

{ ShaderJulia }

constructor ShaderJulia.Create;
begin
  inherited;
  init();
end;

function ShaderJulia.init: Boolean;
var
  sn: ShaderNode;
  s: CCSize;
begin
  if inherited init() then
  begin
    sn := ShaderNode.shaderNodeWithVertex('Shaders/example_Julia.vsh', 'Shaders/example_Julia.fsh');
    s := CCDirector.sharedDirector.getWinSize;
    sn.setPosition(s.width/2, s.height/2);
    addChild(sn);
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ShaderJulia.subtitle: string;
begin
  Result := 'Julia shader';
end;

function ShaderJulia.title: string;
begin
  Result := 'Shader: Frag shader';
end;

{ ShaderHeart }

constructor ShaderHeart.Create;
begin
  inherited;
  init();
end;

function ShaderHeart.init: Boolean;
var
  sn: ShaderNode;
  s: CCSize;
begin
  if inherited init() then
  begin
    sn := ShaderNode.shaderNodeWithVertex('Shaders/example_Heart.vsh', 'Shaders/example_Heart.fsh');
    s := CCDirector.sharedDirector.getWinSize;
    sn.setPosition(s.width/2, s.height/2);
    addChild(sn);
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ShaderHeart.subtitle: string;
begin
  Result := 'Shader: Frag shader';
end;

function ShaderHeart.title: string;
begin
  Result := 'Heart';
end;

{ ShaderFlower }

constructor ShaderFlower.Create;
begin
  inherited;
  init();
end;

function ShaderFlower.init: Boolean;
var
  sn: ShaderNode;
  s: CCSize;
begin
  if inherited init() then
  begin
    sn := ShaderNode.shaderNodeWithVertex('Shaders/example_Flower.vsh', 'Shaders/example_Flower.fsh');
    s := CCDirector.sharedDirector.getWinSize;
    sn.setPosition(s.width/2, s.height/2);
    addChild(sn);
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ShaderFlower.subtitle: string;
begin
  Result := 'Flower';
end;

function ShaderFlower.title: string;
begin
  Result := 'Shader: Frag shader';
end;

{ ShaderPlasma }

constructor ShaderPlasma.Create;
begin
  inherited;
  init();
end;

function ShaderPlasma.init: Boolean;
var
  sn: ShaderNode;
  s: CCSize;
begin
  if inherited init() then
  begin
    sn := ShaderNode.shaderNodeWithVertex('Shaders/example_Plasma.vsh', 'Shaders/example_Plasma.fsh');
    s := CCDirector.sharedDirector.getWinSize;
    sn.setPosition(s.width/2, s.height/2);
    addChild(sn);
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ShaderPlasma.subtitle: string;
begin
  Result := 'Plasma';
end;

function ShaderPlasma.title: string;
begin
  Result := 'Shader: Frag shader';
end;

{ ShaderRetroEffect }

constructor ShaderRetroEffect.Create;
begin
  inherited;
  init();
end;

function ShaderRetroEffect.init: Boolean;
{var
  fragSource: PGLchar;
  p: CCGLProgram;
  director: CCDirector;
  s: CCSize;}
begin
  if inherited init() then
  begin
    {fragSource := CCString.createWithContentsOfFile(CCFileUtils.sharedFileUtils.fullPathFromRelativePath('Shaders/example_HorizontalColor.fsh')).getCString;
    p := CCGLProgram.Create;
    p.initWithVertexShaderByteArray(ccPositionTexture_vert, fragSource);
    p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
    p.addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
    p.link;
    p.updateUniforms;

    director := CCDirector.sharedDirector;
    s := director.getWinSize;

    m_pLabel := CCLabelTTF._create('RETRO EFFECT', 'Arial', 32);
    m_pLabel.setPosition(s.width/2, s.height/2);
    addChild(m_pLabel);
    scheduleUpdate;}
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ShaderRetroEffect.subtitle: string;
begin
  Result := 'sin() effect with moving colors';
end;

function ShaderRetroEffect.title: string;
begin
  Result := 'Shader: Retro test';
end;

procedure ShaderRetroEffect.update(time: Single);
begin
  inherited;

end;

{ ShaderNode }
const SIZE_X = 256;
const SIZE_Y = 256;

constructor ShaderNode.Create;
begin
  inherited;
end;

procedure ShaderNode.draw;
const  w = size_x;
const  h = size_y;
const
  vertices: array [0..11] of GLfloat = (0, 0, w, 0, w, h, 0, 0, 0, h, w, h);
begin
  CC_NODE_DRAW_SETUP;

  getShaderProgram.setUniformLocationWith2f(m_uniformCenter, m_center.x, m_center.y);
  getShaderProgram.setUniformLocationWith2f(m_uniformResolution, m_resoulution.x, m_resoulution.y);

  glUniform1f(m_uniformTime, m_time);

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);

  glDrawArrays(GL_TRIANGLES, 0, 6);

  CC_INCREMENT_GL_DRAWS(1);
end;

function ShaderNode.initWithVertex(const vert, frag: string): Boolean;
begin
  loadShaderVertex(vert, frag);
  m_time := 0;
  m_resoulution := vertex2(SIZE_X, SIZE_Y);
  scheduleUpdate();
  setContentSize(CCSizeMake(SIZE_X, SIZE_Y));
  setAnchorPoint(ccp(0.5, 0.5));

  Result := True;
end;

procedure ShaderNode.loadShaderVertex(const vert, frag: string);
var
  shader: CCGLProgram;
begin
  shader := CCGLProgram.Create;
  shader.initWithVertexShaderFilename(vert, frag);
  shader.addAttribute('aVertex', kCCVertexAttrib_Position);
  shader.link;
  shader.updateUniforms;
  m_uniformCenter := glGetUniformLocation(shader.getProgram, 'center');
  m_uniformResolution := glGetUniformLocation(shader.getProgram, 'resolution');
  m_uniformTime := glGetUniformLocation(shader.getProgram, 'time');
  setShaderProgram(shader);
  shader.release;
end;

procedure ShaderNode.setPosition(const newPosition: CCPoint);
var
  position: CCPoint;
begin
  inherited;
  position := getPosition;
  m_center := vertex2(position.x * CC_CONTENT_SCALE_FACTOR(), position.y * CC_CONTENT_SCALE_FACTOR());
end;

class function ShaderNode.shaderNodeWithVertex(const vert,
  frag: string): ShaderNode;
var
  node: ShaderNode;
begin
  node := ShaderNode.Create;
  node.initWithVertex(vert, frag);
  node.autorelease;
  Result := node;
end;

procedure ShaderNode.update(time: Single);
begin
  m_time := m_time + time;
end;

{ SpriteBlur }

class function SpriteBlur._create(const pszFilename: string): SpriteBlur;
var
  pRet: SpriteBlur;
begin
  pRet := SpriteBlur.Create;
  pRet.initWithFile(pszFilename);
  pRet.autorelease;
  Result := pRet;
end;

procedure SpriteBlur.draw;
var
  offset: Cardinal;
  kQuadSize: Cardinal;
  vDiff, tDiff, cDiff: Cardinal;
  blend: ccBlendFunc;
begin
  ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
  blend := getBlendFunc();
  ccGLBlendFunc(blend.src, blend.dst);

  getShaderProgram.use;
  getShaderProgram.setUniformsForBuiltins;
  getShaderProgram.setUniformLocationWith2f(blurLocation, blur_.x, blur_.y);
  getShaderProgram.setUniformLocationWith4fv(subLocation, @sub_[0], 1);

  ccGLBindTexture2D(gettexture.Name);

  kQuadSize := SizeOf(m_sQuad.bl);
  offset := Cardinal(@m_sQuad);
  get_ccV3F_C4B_T2F_dif(vDiff, cDiff, tDiff);

  glVertexAttribPointer(kCCVertexAttrib_Position,  3, GL_FLOAT, GL_FALSE, kQuadSize, Pointer(offset+vDiff));
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, Pointer(offset+tDiff));
  glVertexAttribPointer(kCCVertexAttrib_Color,     4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, Pointer(offset+cDiff));

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  CC_INCREMENT_GL_DRAWS(1);
end;

function SpriteBlur.initWithTexture(pTexture: CCTexture2D;
  const rect: CCRect): Boolean;
var
  s: CCSize;
  fragSource: PGLchar;
  pProgram: CCGLProgram;
begin
  if inherited initWithTexture(ptexture, rect) then
  begin
    s := Self.getTexture.getContentSizeInPixels;
    blur_ := ccp(1/s.width, 1/s.height);
    sub_[0] := 0; sub_[1] := 0; sub_[2] := 0; sub_[3] := 0;

    fragSource := CCString.createWithContentsOfFile(CCFileUtils.sharedFileUtils.fullPathForFilename('Shaders/example_Blur.fsh')).getCString;
    pProgram := CCGLProgram.Create;
    pProgram.initWithVertexShaderByteArray(ccPositionTextureColor_vert, fragSource);
    setShaderProgram(pProgram);
    pProgram.release;

    getShaderProgram().addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
    getShaderProgram().addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
    getShaderProgram().addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);

    getShaderProgram.link;
    getShaderProgram.updateUniforms;

    subLocation := glGetUniformLocation( getShaderProgram().getProgram(), 'substract');
    blurLocation := glGetUniformLocation( getShaderProgram().getProgram(), 'blurSize');

    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure SpriteBlur.setBlurSize(r: Single);
var
  s: CCSize;
begin
  s := getTexture.getContentSize;
  blur_ := ccp(1/s.width, 1/s.height);
  blur_ := ccpMult(blur_, r);
end;

{ ShaderBlur }

constructor ShaderBlur.Create;
begin
  inherited;
  init();
end;

function ShaderBlur.createSliderCtl: CCControlSlider;
var
  screenSize: CCSize;
  slider: CCControlSlider;
begin
  screenSize := CCDirector.sharedDirector.getWinSize;
  slider := CCControlSlider._create('extensions/sliderTrack.png', 'extensions/sliderProgress.png', 'extensions/sliderThumb.png');
  slider.AnchorPoint := ccp(0.5, 1);
  slider.setMinimumValue(0);
  slider.setMaximumValue(3);
  slider.setValue(1);
  slider.setPosition(screenSize.width/2, screenSize.height/3);
  slider.addTargetWithActionForControlEvents(Self, sliderAction, CCControlEventValueChanged);
  Result := slider;
end;

function ShaderBlur.init: Boolean;
var
  sprite: CCSprite;
  s: CCSize;
begin
  if inherited init() then
  begin
    m_pBlurSprite := SpriteBlur._create('Images/grossini.png');
    sprite := CCSprite._create('Images/grossini.png');
    s := CCDirector.sharedDirector.getWinSize;
    m_pBlurSprite.setPosition(s.width/3, s.height/2);
    sprite.setPosition(2*s.width/3, s.height/2);
    addChild(m_pBlurSprite);
    addChild(sprite);
    m_pSliderCtl := createSliderCtl;
    addChild(m_pSliderCtl);
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure ShaderBlur.sliderAction(pSender: CCObject;
  controlEvent: CCControlEvent);
begin
  m_pBlurSprite.setBlurSize(  CCControlSlider(pSender).Value  );
end;

function ShaderBlur.subtitle: string;
begin
  Result := 'Gaussian blur';
end;

function ShaderBlur.title: string;
begin
  Result := 'Shader: Frag shader';
end;

end.
