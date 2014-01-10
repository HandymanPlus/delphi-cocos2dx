(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2011      Zynga Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************)

unit Cocos2dx.CCLayer;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCArray, Cocos2dx.CCNode, Cocos2dx.CCPlatformMacros,
  Cocos2dx.CCTouchDelegateProtocol, Cocos2dx.CCAccelerometerDelegate,
  Cocos2dx.CCKeypadDelegate, Cocos2dx.CCSet, Cocos2dx.CCTouch,
  Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

type
  ccTouchesMode = (
  	kCCTouchesAllAtOnce,
  	kCCTouchesOneByOne
  );

  (** @brief CCLayer is a subclass of CCNode that implements the TouchEventsDelegate protocol.

    All features from CCNode are valid, plus the following new features:
    - It can receive iPhone Touches
    - It can receive Accelerometer input
    *)
  CCLayer = class(CCNode, CCTouchDelegate, CCAccelerometerDelegate, CCKeypadDelegate)
  private
    m_nTouchPriority: Integer;
    m_eTouchMode: ccTouchesMode;
  protected
    m_bTouchEnabled: Boolean;
    m_bAccelerometerEnabled: Boolean;
    m_bKeypadEnabled: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    function init(): Boolean; override;
    class function _create(): CCLayer;
    procedure onExit(); override;
    procedure onEnter(); override;
    procedure onEnterTransitionDidFinish(); override;
    (** If isTouchEnabled, this method is called onEnter. Override it to change the
    way CCLayer receives touch events.
    ( Default: CCTouchDispatcher::sharedDispatcher()->addStandardDelegate(this,0); )
    Example:
    void CCLayer::registerWithTouchDispatcher()
    {
    CCTouchDispatcher::sharedDispatcher()->addTargetedDelegate(this,INT_MIN+1,true);
    }
    @since v0.8.0
    *)
    procedure registerWithTouchDispatcher(); virtual;
    (** whether or not it will receive Touch events.
    You can enable / disable touch events with this property.
    Only the touches of this node will be affected. This "method" is not propagated to it's children.
    @since v0.8.1
    *)
    function isTouchEnabled(): Boolean; virtual;
    procedure setTouchEnabled(value: Boolean); virtual;
    procedure setTouchMode(mode: ccTouchesMode); virtual;
    function getTouchMode(): ccTouchesMode; virtual;
    procedure setTouchPriority(priority: Integer); virtual;
    function getTouchPriority(): Integer; virtual;
    function isAccelerometerEnabled(): Boolean; virtual;
    procedure setAccelerometerEnabled(value: Boolean); virtual;
    procedure setAccelerometerInterval(interval: Single); virtual;
    function isKeypadEnabled(): Boolean; virtual;
    procedure setKeypadEnabled(value: Boolean); virtual;
    procedure keyBackClicked(); virtual;
    procedure keyMenuClicked(); virtual;
  public
    //interface
    function ccTouchBegan(pTouch: CCTouch; pEvent: CCEvent): Boolean; virtual;
    procedure ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent); virtual;
    procedure ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent); virtual;
    procedure ccTouchCancelled(pTouch: CCTouch; pEvent: CCEvent); virtual;

    procedure ccTouchesBegan(pTouches: CCSet; pEvent: CCEvent); virtual;
    procedure ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent); virtual;
    procedure ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent); virtual;
    procedure ccTouchesCancelled(pTouches: CCSet; pEvent: CCEvent); virtual;
    //
    procedure didAccelerate(pAccelerationValue: PCCAcceleration);
  end;

  (** CCLayerRGBA is a subclass of CCLayer that implements the CCRGBAProtocol protocol using a solid color as the background.

   All features from CCLayer are valid, plus the following new features that propagate into children that conform to the CCRGBAProtocol:
   - opacity
   - RGB colors
   @since 2.1
   *)
  CCLayerRGBA = class(CCLayer{CCRGBAProtocol})
  protected
    _displayedOpacity, _realOpacity: GLubyte;
    _displayedColor, _realColor: ccColor3B;
    _cascadeOpacityEnabled, _cascadeColorEnabled: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(): CCLayerRGBA;
    function init(): Boolean; override;

    //interface
    procedure setColor(const color: ccColor3B); override;
    function getColor(): ccColor3B; override;
    function getDisplayColor(): ccColor3B; override;
    function getDisplayOpacity(): GLubyte; override;
    function getOpacity(): GLubyte; override;
    procedure setOpacity(opacity: GLubyte); override;
    function isCascadeColorEnabled(): Boolean; override;
    procedure setCascadeColorEnabled(cascadeColorEnabled: Boolean); override;
    procedure updateDisplayedColor(const color: ccColor3B); override;
    function isCascadeOpacityEnabled(): Boolean; override;
    procedure setCascadeOpacityEnabled(cascadeOpacityEnabled: Boolean); override;
    procedure updateDisplayedOpacity(opacity: GLubyte); override;
  end;

  (** @brief CCLayerColor is a subclass of CCLayer that implements the CCRGBAProtocol protocol.

    All features from CCLayer are valid, plus the following new features:
    - opacity
    - RGB colors
    *)
  CCLayerColor = class(CCLayerRGBA{CCBlendProtocol})
  protected
    m_pSquareVertices: array [0..3] of ccVertex2F;
    m_pSquareColors: array [0..3] of ccColor4F;
    m_tBlendFunc: ccBlendFunc;
    procedure updateColor(); virtual;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure draw(); override;
    procedure setContentSize(const val: CCSize); override;
    class function _create(): CCLayerColor; overload;
    class function _create(const color: ccColor4B; width, height: GLfloat): CCLayerColor; overload;
    class function _create(const color: ccColor4B): CCLayerColor; overload;
    function init(): Boolean; override;
    function initWithColor(const color: ccColor4B; width, height: GLfloat): Boolean; overload;
    function initWithColor(const color: ccColor4B): Boolean; overload;
    procedure changeWidth(w: GLfloat);
    procedure changeHeight(h: GLfloat);
    procedure changeWidthAndHeight(w, h: GLfloat);
    //
    procedure setColor(const color: ccColor3B); override;
    procedure setOpacity(opacity: GLubyte); override;

    procedure setBlendFunc(blendFunc: ccBlendFunc); override;
    function getBlendFunc(): ccBlendFunc; override;
  end;

  (** @brief CCLayerGradient is a subclass of CCLayerColor that draws gradients across the background.

    All features from CCLayerColor are valid, plus the following new features:
    - direction
    - final color
    - interpolation mode

    Color is interpolated between the startColor and endColor along the given
    vector (starting at the origin, ending at the terminus).  If no vector is
    supplied, it defaults to (0, -1) -- a fade from top to bottom.

    If 'compressedInterpolation' is disabled, you will not see either the start or end color for
    non-cardinal vectors; a smooth gradient implying both end points will be still
    be drawn, however.

    If ' compressedInterpolation' is enabled (default mode) you will see both the start and end colors of the gradient.

    @since v0.99.5
    *)
  CCLayerGradient = class(CCLayerColor)
  private
    m_endColor: ccColor3B;
    m_cStartOpacity: GLubyte;
    m_cEndOpacity: GLubyte;
    m_AlongVector: CCPoint;
  protected
    m_bCompressedInterpolation: Boolean;
    procedure updateColor(); override;
  public
    class function _create(): CCLayerGradient; overload;
    class function _create(const start, _end: ccColor4B): CCLayerGradient; overload;
    class function _create(const start, _end: ccColor4B; const v: CCPoint): CCLayerGradient; overload;
    function initWithColor(const start, _end: ccColor4B): Boolean; overload;
    function init(): Boolean; override;
    function initWithColor(const start, _end: ccColor4B; const v: CCPoint): Boolean; overload;
    procedure setCompressedInterpolation(bCompressedInterpolation: Boolean); virtual;
    function isCompressedInterpolation(): Boolean; virtual;
    function getEndColor: ccColor3B;
    function getEndOpacity: GLubyte;
    function getStartColor: ccColor3B;
    function getStartOpacity: GLubyte;
    function getVector: CCPoint;
    procedure setEndOpacity(const Value: GLubyte);
    procedure setStartColor(const Value: ccColor3B);
    procedure setEndColor(const Value: ccColor3B);
    procedure setStartOpacity(const Value: GLubyte);
    procedure setVector(const Value: CCPoint);
    property StartColor: ccColor3B read getStartColor write setStartColor;
    property EndColor: ccColor3B read getEndColor write setEndColor;
    property StartOpacity: GLubyte read getStartOpacity write setStartOpacity;
    property EndOpacity: GLubyte read getEndOpacity write setEndOpacity;
    property Vector: CCPoint read getVector write setVector;
  end;

  (** @brief CCMultipleLayer is a CCLayer with the ability to multiplex it's children.
    Features:
    - It supports one or more children
    - Only one children will be active a time
    *)
  CCLayerMultiplex = class(CCLayer)
  protected
    m_nEnabledLayer: Cardinal;
    m_pLayers: CCArray;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(): CCLayerMultiplex; overload;
    class function _create(pLayers: array of CCLayer): CCLayerMultiplex; overload;
    class function createWithLayer(pLayer: CCLayer): CCLayerMultiplex;
    class function createWithArray(arrayOfLayers: CCArray): CCLayerMultiplex;
    procedure addLayer(pLayer: CCLayer);
    function initWithLayers(pLayers: array of CCLayer): Boolean;
    function initWithArray(arrayOfLayers: CCArray): Boolean;
    procedure switchTo(n: Cardinal);
    procedure switchToAndReleaseMe(n: Cardinal);
  end;

implementation
uses
  Cocos2dx.CCDirector, Cocos2dx.CCPointExtension, Cocos2dx.CCTouchDispatcher,
  Cocos2dx.CCCommon, Cocos2dx.CCMacros, Cocos2dx.CCShaderCache,
  Cocos2dx.CCGLProgram, Cocos2dx.CCGLStateCache;

{ CCLayer }

constructor CCLayer.Create;
begin
  inherited Create();
  {m_bIsTouchEnabled := False;
  m_bIsAccelerometerEnabled := False;
  m_bIsKeypadEnabled := False;}
  AnchorPoint := ccp(0.5, 0.5);
  m_bIgnoreAnchorPointForPosition := True;
end;

destructor CCLayer.Destroy;
begin
  CCLog('CCLayer Destroy: %d', [Cardinal(Self)]);
  inherited;
end;

class function CCLayer._create: CCLayer;
var
  pRet: CCLayer;
begin
  pRet := CCLayer.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
  end else
  begin
    CC_SAFE_DELETE(pRet);
    Result := nil;
  end;    
end;

function CCLayer.init: Boolean;
var
  pDirector: CCDirector;
begin
  pDirector := CCDirector.sharedDirector();
  ContentSize := pDirector.getWinSize();
  m_bTouchEnabled := False;
  m_bAccelerometerEnabled := False;
  Result := True;
end;

function CCLayer.ccTouchBegan(pTouch: CCTouch; pEvent: CCEvent): Boolean;
begin
  Result := True;
end;

procedure CCLayer.ccTouchCancelled(pTouch: CCTouch; pEvent: CCEvent);
begin

end;

procedure CCLayer.ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent);
begin

end;

procedure CCLayer.ccTouchesBegan(pTouches: CCSet; pEvent: CCEvent);
begin

end;

procedure CCLayer.ccTouchesCancelled(pTouches: CCSet; pEvent: CCEvent);
begin

end;

procedure CCLayer.ccTouchesEnded(pTouches: CCSet; pEvent: CCEvent);
begin

end;

procedure CCLayer.ccTouchesMoved(pTouches: CCSet; pEvent: CCEvent);
begin

end;

procedure CCLayer.ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent);
begin

end;

procedure CCLayer.didAccelerate(pAccelerationValue: PCCAcceleration);
begin

end;

procedure CCLayer.keyBackClicked;
begin

end;

procedure CCLayer.keyMenuClicked;
begin

end;

procedure CCLayer.onEnter;
var
  pDirector: CCDirector;
begin
  pDirector := CCDirector.sharedDirector();
  if m_bTouchEnabled then
  begin
    Self.registerWithTouchDispatcher();
  end;

  inherited onEnter();

  if m_bAccelerometerEnabled then
  begin
    pDirector.Accelerometer.setDelegate(Self);
  end;

  if m_bKeypadEnabled then
  begin
    pDirector.KeypadDispather.addDelegate(Self);
  end;  
end;

procedure CCLayer.onEnterTransitionDidFinish;
var
  pDirector: CCDirector;
begin
  if m_bAccelerometerEnabled then
  begin
    pDirector := CCDirector.sharedDirector();
    pDirector.Accelerometer.setDelegate(Self);
  end;

  inherited onEnterTransitionDidFinish();
end;

procedure CCLayer.onExit;
var
  pDirector: CCDirector;
begin
  pDirector := CCDirector.sharedDirector();
  if m_bTouchEnabled then
  begin
    pDirector.TouchDispatcher.removeDelegate(Self);
  end;

  if m_bAccelerometerEnabled then
  begin
    pDirector.Accelerometer.setDelegate(nil);
  end;

  if m_bKeypadEnabled then
  begin
    pDirector.KeypadDispather.removeDelegate(Self);
  end;  

  inherited onExit();
end;

function CCLayer.isAccelerometerEnabled: Boolean;
begin
  Result := m_bAccelerometerEnabled;
end;

function CCLayer.isKeypadEnabled: Boolean;
begin
  Result := m_bKeypadEnabled;
end;

function CCLayer.isTouchEnabled: Boolean;
begin
  Result := m_bTouchEnabled;
end;

procedure CCLayer.registerWithTouchDispatcher;
var
  pDispatcher: CCTouchDispatcher;
begin
  pDispatcher := CCDirector.sharedDirector().TouchDispatcher;
  if m_eTouchMode = kCCTouchesAllAtOnce then
    pDispatcher.addStandardDelegate(Self, 0)
  else
    pDispatcher.addTargetedDelegate(Self, m_nTouchPriority, True);
end;

procedure CCLayer.setAccelerometerEnabled(value: Boolean);
var
  pDirector: CCDirector;
begin
  if value <> m_bAccelerometerEnabled then
  begin
    m_bAccelerometerEnabled := value;

    if m_bRunning then
    begin
      pDirector := CCDirector.sharedDirector();
      if value then
      begin
        pDirector.Accelerometer.setDelegate(Self);
      end else
      begin
        pDirector.Accelerometer.setDelegate(nil);
      end;
    end;
  end;
end;

procedure CCLayer.setKeypadEnabled(value: Boolean);
var
  pDirector: CCDirector;
begin
  if value <> m_bKeypadEnabled then
  begin
    m_bKeypadEnabled := value;

    if m_bRunning then
    begin
      pDirector := CCDirector.sharedDirector();
      if value then
      begin
        pDirector.KeypadDispather.addDelegate(Self);
      end else
      begin
        pDirector.KeypadDispather.addDelegate(nil);
      end;    
    end;
  end;
end;

procedure CCLayer.setTouchEnabled(value: Boolean);
begin
  if m_bTouchEnabled <> value then
  begin
    m_bTouchEnabled := value;
    if m_bRunning then
    begin
      if value then
      begin
        Self.registerWithTouchDispatcher();
      end else
      begin
        CCDirector.sharedDirector().TouchDispatcher.removeDelegate(Self);
      end;  
    end;  
  end;  
end;

function CCLayer.getTouchMode: ccTouchesMode;
begin
  Result := m_eTouchMode;
end;

function CCLayer.getTouchPriority: Integer;
begin
  Result := m_nTouchPriority;
end;

procedure CCLayer.setTouchMode(mode: ccTouchesMode);
begin
  if m_eTouchMode <> mode then
  begin
    m_eTouchMode := mode;
    if m_bTouchEnabled then
    begin
      setTouchEnabled(False);
      setTouchEnabled(True);
    end;  
  end;  
end;

procedure CCLayer.setTouchPriority(priority: Integer);
begin
  if m_nTouchPriority <> priority then
  begin
    m_nTouchPriority := priority;
    if m_bTouchEnabled then
    begin
      setTouchEnabled(False);
      setTouchEnabled(True);
    end;  
  end;  
end;

procedure CCLayer.setAccelerometerInterval(interval: Single);
begin
  if m_bAccelerometerEnabled then
  begin
    if m_bRunning then
    begin
      CCDirector.sharedDirector().Accelerometer.setAccelerometerInterval(interval);
    end;  
  end;  
end;

{ CCLayerColor }

class function CCLayerColor._create(const color: ccColor4B): CCLayerColor;
var
  pRet: CCLayerColor;
begin
  pRet := CCLayerColor.Create;
  if (pRet <> nil) and pRet.initWithColor(color) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCLayerColor._create(const color: ccColor4B; width,
  height: GLfloat): CCLayerColor;
var
  pRet: CCLayerColor;
begin
  pRet := CCLayerColor.Create;
  if (pRet <> nil) and pRet.initWithColor(color, width, height) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCLayerColor.changeHeight(h: GLfloat);
begin
  Self.setContentSize(CCSizeMake(m_obContentSize.width, h));
end;

procedure CCLayerColor.changeWidth(w: GLfloat);
begin
  Self.setContentSize(CCSizeMake(w, m_obContentSize.height));
end;

procedure CCLayerColor.changeWidthAndHeight(w, h: GLfloat);
begin
  Self.setContentSize(CCSizeMake(w, h));
end;

constructor CCLayerColor.Create;
begin
  inherited Create();
  m_tBlendFunc.src := CC_BLEND_SRC;
  m_tBlendFunc.dst := CC_BLEND_DST;
end;

destructor CCLayerColor.Destroy;
begin
  inherited;  
end;

procedure CCLayerColor.draw;
begin
  CC_NODE_DRAW_SETUP();

  ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position or kCCVertexAttribFlag_Color );

  //
  // Attributes
  //
  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @m_pSquareVertices[0]);
  glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, @m_pSquareColors[0]);

  ccGLBlendFunc( m_tBlendFunc.src, m_tBlendFunc.dst );

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  CC_INCREMENT_GL_DRAWS(1);
end;

function CCLayerColor.getBlendFunc: ccBlendFunc;
begin
  Result := m_tBlendFunc;
end;

function CCLayerColor.init: Boolean;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  Result := initWithColor(ccc4(0, 0, 0, 0), s.width, s.height);
end;

function CCLayerColor.initWithColor(const color: ccColor4B; width,
  height: GLfloat): Boolean;
var
  i: Integer;
begin
  if inherited init() then
  begin
    m_tBlendFunc.src := GL_SRC_ALPHA;
    m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;

    _realColor.r := color.r;
    _realColor.g := color.g;
    _realColor.b := color.b;
    _realOpacity := color.a;

    _displayedColor.r := color.r;
    _displayedColor.g := color.g;
    _displayedColor.b := color.b;
    _displayedOpacity := color.a;


    for i := 0 to SizeOf(m_pSquareVertices) div SizeOf(m_pSquareVertices[0]) - 1 do
    begin
      m_pSquareVertices[i].x := 0.0;
      m_pSquareVertices[i].y := 0.0;
    end;

    updateColor();
    setContentSize(CCSizeMake(width, height));
    setShaderProgram( CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionColor) );
  end;
  Result := True;
end;

function CCLayerColor.initWithColor(const color: ccColor4B): Boolean;
var
  s: CCSize;
begin
  s := CCDirector.sharedDirector().getWinSize();
  Self.initWithColor(color, s.width, s.height);
  Result := True;
end;

procedure CCLayerColor.setBlendFunc(blendFunc: ccBlendFunc);
begin
  m_tBlendFunc := blendFunc;
end;

procedure CCLayerColor.setColor(const color: ccColor3B);
begin
  inherited setColor(color);
  updateColor();
end;

procedure CCLayerColor.setContentSize(const val: CCSize);
begin
  m_pSquareVertices[1].x := val.width;
  m_pSquareVertices[2].y := val.height;
  m_pSquareVertices[3].x := val.width;
  m_pSquareVertices[3].y := val.height;

  inherited setContentSize(val);
end;

procedure CCLayerColor.setOpacity(opacity: GLubyte);
begin
  inherited setOpacity(opacity);
  updateColor();
end;

procedure CCLayerColor.updateColor;
var
  i: Integer;
begin
  for i := 0 to 3 do
  begin
    m_pSquareColors[i].r := _displayedColor.r / 255;
    m_pSquareColors[i].g := _displayedColor.g / 255;
    m_pSquareColors[i].b := _displayedColor.b / 255;
    m_pSquareColors[i].a := _displayedOpacity / 255;
  end;  
end;

class function CCLayerColor._create: CCLayerColor;
var
  pRet: CCLayerColor;
begin
  pRet := CCLayerColor.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := pRet;
end;

{ CCLayerGradient }

class function CCLayerGradient._create(const start,
  _end: ccColor4B): CCLayerGradient;
var
  pRet: CCLayerGradient;
begin
  pRet := CCLayerGradient.Create;
  if (pRet <> nil) and pRet.initWithColor(start, _end) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCLayerGradient._create(const start, _end: ccColor4B;
  const v: CCPoint): CCLayerGradient;
var
  pRet: CCLayerGradient;
begin
  pRet := CCLayerGradient.Create;
  if (pRet <> nil) and pRet.initWithColor(start, _end, v) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCLayerGradient.getEndColor: ccColor3B;
begin
  Result := m_endColor;
end;

function CCLayerGradient.getEndOpacity: GLubyte;
begin
  Result := m_cEndOpacity;
end;

function CCLayerGradient.getStartColor: ccColor3B;
begin
  Result := _realColor;
end;

function CCLayerGradient.getStartOpacity: GLubyte;
begin
  Result := m_cStartOpacity;
end;

function CCLayerGradient.getVector: CCPoint;
begin
  Result := m_AlongVector;
end;

function CCLayerGradient.initWithColor(const start, _end: ccColor4B;
  const v: CCPoint): Boolean;
begin
  m_endColor.r := _end.r;
  m_endColor.g := _end.g;
  m_endColor.b := _end.b;

  m_cEndOpacity := _end.a;
  m_cStartOpacity := start.a;
  m_AlongVector := v;

  m_bCompressedInterpolation := True;

  Result := inherited initWithColor(ccc4(start.r, start.g, start.b, 255));
end;

function CCLayerGradient.initWithColor(const start,
  _end: ccColor4B): Boolean;
begin
  Result := initWithColor(start, _end, ccp(0, -1));
end;

function CCLayerGradient.isCompressedInterpolation: Boolean;
begin
  Result := m_bCompressedInterpolation;
end;

procedure CCLayerGradient.setCompressedInterpolation(
  bCompressedInterpolation: Boolean);
begin
  m_bCompressedInterpolation := bCompressedInterpolation;
  updateColor();
end;

procedure CCLayerGradient.setEndOpacity(const Value: GLubyte);
begin
  m_cEndOpacity := Value;
  updateColor();
end;

procedure CCLayerGradient.setStartColor(const Value: ccColor3B);
begin
  setColor(Value);
end;

procedure CCLayerGradient.setStartOpacity(const Value: GLubyte);
begin
  m_cStartOpacity := Value;
  updateColor();
end;

procedure CCLayerGradient.setVector(const Value: CCPoint);
begin
  m_AlongVector := Value;
  updateColor();
end;

procedure CCLayerGradient.updateColor;
var
  h, c, h2, opacityf: Single;
  u: CCPoint;
  S, E: ccColor4F;
begin
  inherited updateColor();

  h := ccpLength(m_AlongVector);
  if h = 0 then
    Exit;

  c := Sqrt(2.0);
  u := ccp(m_AlongVector.x / h, m_AlongVector.y / h);

  if m_bCompressedInterpolation then
  begin
    h2 := 1 / (Abs(u.x) + Abs(u.y));
    u := ccpMult(u, h2 * c);
  end;

  opacityf := _displayedOpacity / 255.0;

  S.r := _displayedColor.r / 255.0;
  S.g := _displayedColor.g / 255.0;
  S.b := _displayedColor.b / 255.0;
  S.a := m_cStartOpacity * opacityf / 255.0;

  E.r := m_endColor.r / 255.0;
  E.g := m_endColor.g / 255.0;
  E.b := m_endColor.b / 255.0;
  E.a := m_cEndOpacity * opacityf / 255.0;

  m_pSquareColors[0].r := E.r + (S.r - E.r) * ( (c + u.x + u.y) / (2.0 * c) );
  m_pSquareColors[0].g := E.g + (S.g - E.g) * ( (c + u.x + u.y) / (2.0 * c) );
  m_pSquareColors[0].b := E.b + (S.b - E.b) * ( (c + u.x + u.y) / (2.0 * c) );
  m_pSquareColors[0].a := E.a + (S.a - E.a) * ( (c + u.x + u.y) / (2.0 * c) );

  m_pSquareColors[1].r := E.r + (S.r - E.r) * ( (c - u.x + u.y) / (2.0 * c) );
  m_pSquareColors[1].g := E.g + (S.g - E.g) * ( (c - u.x + u.y) / (2.0 * c) );
  m_pSquareColors[1].b := E.b + (S.b - E.b) * ( (c - u.x + u.y) / (2.0 * c) );
  m_pSquareColors[1].a := E.a + (S.a - E.a) * ( (c - u.x + u.y) / (2.0 * c) );

  m_pSquareColors[2].r := E.r + (S.r - E.r) * ( (c + u.x - u.y) / (2.0 * c) );
  m_pSquareColors[2].g := E.g + (S.g - E.g) * ( (c + u.x - u.y) / (2.0 * c) );
  m_pSquareColors[2].b := E.b + (S.b - E.b) * ( (c + u.x - u.y) / (2.0 * c) );
  m_pSquareColors[2].a := E.a + (S.a - E.a) * ( (c + u.x - u.y) / (2.0 * c) );

  m_pSquareColors[3].r := E.r + (S.r - E.r) * ( (c - u.x - u.y) / (2.0 * c) );
  m_pSquareColors[3].g := E.g + (S.g - E.g) * ( (c - u.x - u.y) / (2.0 * c) );
  m_pSquareColors[3].b := E.b + (S.b - E.b) * ( (c - u.x - u.y) / (2.0 * c) );
  m_pSquareColors[3].a := E.a + (S.a - E.a) * ( (c - u.x - u.y) / (2.0 * c) );
end;

procedure CCLayerGradient.setEndColor(const Value: ccColor3B);
begin
  m_endColor := Value;
  updateColor();
end;

function CCLayerGradient.init: Boolean;
begin
  Result := initWithColor(ccc4(0, 0, 0, 255), ccc4(0, 0, 0, 255));
end;

class function CCLayerGradient._create: CCLayerGradient;
var
  pRet: CCLayerGradient;
begin
  pRet := CCLayerGradient.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCLayerMultiplex }

class function CCLayerMultiplex._create(
  pLayers: array of CCLayer): CCLayerMultiplex;
var
  pRet: CCLayerMultiplex;
begin
  pRet := CCLayerMultiplex.Create;
  if (pRet <> nil) and pRet.initWithLayers(pLayers) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCLayerMultiplex.createWithLayer(
  pLayer: CCLayer): CCLayerMultiplex;
begin
  Result := Self._create([pLayer]);
end;

procedure CCLayerMultiplex.addLayer(pLayer: CCLayer);
begin
  m_pLayers.addObject(pLayer);
end;

constructor CCLayerMultiplex.Create;
begin
  inherited;
end;

destructor CCLayerMultiplex.Destroy;
begin
  CC_SAFE_RELEASE(m_pLayers);
  inherited;
end;

function CCLayerMultiplex.initWithLayers(
  pLayers: array of CCLayer): Boolean;
var
  nCount, i: Cardinal;
begin
  if inherited init() then
  begin
    m_pLayers := CCArray.createWithCapacity(5);
    m_pLayers.retain();

    nCount := Length(pLayers);
    if nCount > 0 then
      for  i:= 0 to nCount-1 do
      begin
        m_pLayers.addObject(pLayers[i]);
      end;

    m_nEnabledLayer := 0;
    addChild(CCNode(m_pLayers.objectAtIndex(m_nEnabledLayer)));

    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure CCLayerMultiplex.switchTo(n: Cardinal);
begin
  CCAssert(n < m_pLayers.count(), 'Invalid index in MultiplexLayer switchTo message');

  removeChild(CCNode(m_pLayers.objectAtIndex(m_nEnabledLayer)), True);

  m_nEnabledLayer := n;

  addChild(CCNode(m_pLayers.objectAtIndex(n)));
end;

procedure CCLayerMultiplex.switchToAndReleaseMe(n: Cardinal);
begin
  CCAssert(n < m_pLayers.count(), 'Invalid index in MultiplexLayer switchTo message');

  removeChild(CCNode(m_pLayers.objectAtIndex(m_nEnabledLayer)), True);

  m_pLayers.replaceObjectAtIndex(m_nEnabledLayer, nil);

  m_nEnabledLayer := n;

  addChild(CCNode(m_pLayers.objectAtIndex(n)));
end;

class function CCLayerMultiplex._create: CCLayerMultiplex;
var
  pRet: CCLayerMultiplex;
begin
  pRet := CCLayerMultiplex.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCLayerMultiplex.createWithArray(
  arrayOfLayers: CCArray): CCLayerMultiplex;
var
  pRet: CCLayerMultiplex;
begin
  pRet := CCLayerMultiplex.Create;
  if (pRet <> nil) and pRet.initWithArray(arrayOfLayers) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCLayerMultiplex.initWithArray(arrayOfLayers: CCArray): Boolean;
begin
  if inherited init() then
  begin
    m_pLayers := CCArray.createWithCapacity(arrayOfLayers.count());
    m_pLayers.addObjectsFromArray(arrayOfLayers);
    m_pLayers.retain();

    m_nEnabledLayer := 0;
    addChild(CCNode(m_pLayers.objectAtIndex(m_nEnabledLayer)));

    Result := True;
    Exit;
  end;

  Result := False;  
end;

{ CCLayerRGBA }

class function CCLayerRGBA._create: CCLayerRGBA;
var
  pRet: CCLayerRGBA;
begin
  pRet := CCLayerRGBA.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCLayerRGBA.Create;
begin
  inherited Create();
  _displayedOpacity := 255;
  _realOpacity := 255;
  _displayedColor := ccWHITE;
  _realColor := ccWHITE;
end;

destructor CCLayerRGBA.Destroy;
begin

  inherited;
end;

function CCLayerRGBA.getColor: ccColor3B;
begin
  Result := _realColor;
end;

function CCLayerRGBA.getDisplayColor: ccColor3B;
begin
  Result := _displayedColor;
end;

function CCLayerRGBA.getDisplayOpacity: GLubyte;
begin
  Result := _displayedOpacity;
end;

function CCLayerRGBA.getOpacity: GLubyte;
begin
  Result := _realOpacity;
end;

function CCLayerRGBA.init: Boolean;
begin
  if inherited init() then
  begin
    _displayedOpacity := 255;
    _realOpacity := 255;
    _displayedColor := ccWHITE;
    _realColor := ccWHITE;

    Result := True;
    Exit;
  end;

  Result := False;
end;

function CCLayerRGBA.isCascadeColorEnabled: Boolean;
begin
  Result := _cascadeColorEnabled;
end;

function CCLayerRGBA.isCascadeOpacityEnabled: Boolean;
begin
  Result := _cascadeOpacityEnabled;
end;

procedure CCLayerRGBA.setCascadeColorEnabled(cascadeColorEnabled: Boolean);
begin
  _cascadeColorEnabled := cascadeColorEnabled;
end;

procedure CCLayerRGBA.setCascadeOpacityEnabled(
  cascadeOpacityEnabled: Boolean);
begin
  _cascadeOpacityEnabled := cascadeOpacityEnabled;
end;

procedure CCLayerRGBA.setColor(const color: ccColor3B);
var
  parentColor: ccColor3B;
  parent: CCNode;
begin
  _displayedColor := color;
  _realColor := color;
  if _cascadeColorEnabled then
  begin
    parentColor := ccWHITE;
    parent := m_pParent;
    if (parent <> nil) and parent.isCascadeColorEnabled() then
      parentColor := parent.getDisplayColor();
    updateDisplayedColor(parentColor);
  end;  
end;

procedure CCLayerRGBA.setOpacity(opacity: GLubyte);
var
  parentOpacity: GLubyte;
  parent: CCNode;
begin
  _displayedOpacity := opacity;
  _realOpacity := opacity;
  if _cascadeOpacityEnabled then
  begin
    parentOpacity := 255;
    parent := m_pParent;
    if (parent <> nil) and parent.isCascadeOpacityEnabled() then
      parentOpacity := parent.getDisplayOpacity();
    updateDisplayedOpacity(parentOpacity);
  end;  
end;

procedure CCLayerRGBA.updateDisplayedColor(const color: ccColor3B);
var
  i: Integer;
  item: CCNode;
begin
  _displayedColor.r := _realColor.r * color.r div 255;
  _displayedColor.g := _realColor.g * color.g div 255;
  _displayedColor.b := _realColor.b * color.b div 255;

  if _cascadeColorEnabled then
  begin
    if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
      for i := 0 to m_pChildren.count()-1 do
      begin
        item := CCNode(m_pChildren.objectAtIndex(i));
        if item <> nil then
          item.updateDisplayedColor(_displayedColor);
      end;
  end;  
end;

procedure CCLayerRGBA.updateDisplayedOpacity(opacity: GLubyte);
var
  i: Integer;
  item: CCNode;
begin
  _displayedOpacity := opacity div 255;
  _realOpacity := _displayedOpacity;

  if _cascadeOpacityEnabled then
  begin
    if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
      for i := 0 to m_pChildren.count()-1 do
      begin
        item := CCNode(m_pChildren.objectAtIndex(i));
        if item <> nil then
          item.updateDisplayedOpacity(_displayedOpacity);
      end;
  end;  
end;

end.
