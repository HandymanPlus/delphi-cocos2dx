unit Cocos2dx.CCEAGLView;

interface
uses
  System.TypInfo,
  Macapi.ObjectiveC, iOSapi.CocoaTypes, iOSapi.OpenGLES, iOSapi.QuartzCore,
  iOSapi.CoreGraphics, iOSapi.UIKit, iOSapi.Foundation, iOSapi.GLKit,
  Cocos2dx.CCESRenderer2;

type
  EAGLView = interface(UIView)
    ['{705DD209-EA47-4EE1-BBBE-FD4592823303}']
    //UIView
    function initWithFrame(frame: CGRect): Pointer; cdecl;
    procedure layoutSubviews; cdecl;
    //UIResponder
    procedure touchesBegan(touches: NSSet; withEvent: UIEvent); cdecl;
    procedure touchesCancelled(touches: NSSet; withEvent: UIEvent); cdecl;
    procedure touchesEnded(touches: NSSet; withEvent: UIEvent); cdecl;
    procedure touchesMoved(touches: NSSet; withEvent: UIEvent); cdecl;
  end;

  TEAGLView = class(TOCLocal)
  private
    _pixelformat: NSString;
    _depthFormat: GLuint;
    _preserveBackbuffer: Boolean;
    _multisampling: Boolean;
    _requestedSamples: Cardinal;
    _context: EAGLContext;
    _renderer: CCES2Renderer;
    _size: CGSize;
    //_discardFramebufferSupported: Boolean;

    function setupSurfaceWithSharegroup(sharegroup: EAGLSharegroup): Boolean;
    function convertPixelFormat(pixelFormat: NSString): Cardinal;
    function getHeight: Integer;
    function getWidth: Integer;
  public
    constructor Create();
    destructor Destroy(); override;
    function GetObjectiveCClass: PTypeInfo; override;

    class function createWithFrame(frame: CGRect): TEAGLView; overload;
    class function createWithFrame(frame: CGRect; format: NSString): TEAGLView; overload;
    class function createWithFrame(frame: CGRect; format: NSString; depth: GLuint; retained: boolean;
      sharegroup: EAGLSharegroup; sampling: Boolean; nSamples: Cardinal): TEAGLView;  overload;

    function _initWithFrame(frame: CGRect): Boolean; overload;
    function _initWithFrame(frame: CGRect; format: NSString): Boolean; overload;
    function _initWithFrame(frame: CGRect; format: NSString; depth: GLuint; retained: boolean;
      sharegroup: EAGLSharegroup; sampling: Boolean; nSamples: Cardinal): Boolean; overload;

    procedure swapBuffers();

    function convertPointFromViewToSurface(point: CGPoint): CGPoint; cdecl;
    function convertRectFromViewToSurface(rect: CGRect): CGRect; cdecl;
    function getView(): UIView;

    class function sharedEAGLView(): TEAGLView; static;
    class procedure purgeEAGLView(); static;
  public
    property surfaceSize: CGSize read _size;
    property pixelFormat: NSString read _pixelformat;
    property depthFormat: GLuint read _depthFormat;
    property context: EAGLContext read _context;
    property multiSampling: Boolean read _multisampling;
    property width: Integer read getWidth;
    property height: Integer read getHeight;
    property Super;
  public
    //UIView
    function initWithFrame(frame: CGRect): Pointer; cdecl;
    procedure layoutSubviews; cdecl;
    //UIResponder
    procedure touchesBegan(touches: NSSet; withEvent: UIEvent); cdecl;
    procedure touchesCancelled(touches: NSSet; withEvent: UIEvent); cdecl;
    procedure touchesEnded(touches: NSSet; withEvent: UIEvent); cdecl;
    procedure touchesMoved(touches: NSSet; withEvent: UIEvent); cdecl;
  end;

  View3D = interface(GLKView)
    ['{C2E761A0-3F68-42F4-9F58-27E3CB82E0A8}']
  end;

  TView3d = class(TOCLocal)
  private
    _renderer: CCES2Renderer;
    function getHeight: Integer;
    function getWidth: Integer;
  public
    class function sharedEAGLView(): TView3d; static;
    class procedure purgeEAGLView(); static;
    procedure swapBuffers();
    constructor Create(AFRameRect: NSRect);
    function GetObjectiveCClass: PTypeInfo; override;
    function getView(): GLKView;
    property width: Integer read getWidth;
    property height: Integer read getHeight;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCGeometry, Cocos2dx.CCDirector, Cocos2dx.CCEGLView, Cocos2dx.CCCommon;

var  _EAGLView: TEAGLView;
var gView3d: TView3d;
const IOS_MAX_TOUCHES_COUNT   =  10;


{ TEAGLView }

function TEAGLView.convertPixelFormat(pixelFormat: NSString): Cardinal;
var
  pFormat: GLenum;
begin
  if pixelFormat.isEqualToString(NSSTR('EAGLColorFormat565')) then
    pFormat := GL_RGB565
  else
    pFormat := GL_RGBA8_OES;
  Result := pFormat;
end;

function TEAGLView.convertPointFromViewToSurface(point: CGPoint): CGPoint;
var
  bounds: CGRect;
begin
  bounds := UIView(Super).bounds;
  Result := CGPointMake((point.x - bounds.origin.x) / bounds.size.width * _size.width,
    (point.y - bounds.origin.y) / bounds.size.height * _size.height);
end;

function TEAGLView.convertRectFromViewToSurface(rect: CGRect): CGRect;
var
  bounds: CGRect;
begin
  bounds := UIView(Super).bounds;
  Result := CGRectMake(
    (rect.origin.x - bounds.origin.x) / bounds.size.width * _size.width,
    (rect.origin.y - bounds.origin.y) / bounds.size.height * _size.height,
    rect.size.width / bounds.size.width * _size.width,
    rect.size.height / bounds.size.height * _size.height);
end;

constructor TEAGLView.Create;
begin
  inherited Create();
end;

class function TEAGLView.createWithFrame(frame: CGRect): TEAGLView;
var
  pRet: TEAGLView;
begin
  pRet := TEAGLView.Create();
  if (pRet <> nil) and pRet._initWithFrame(frame) then
  begin
    Result := pRet;
    Exit;
  end;

  pRet.Free;
  Result := nil;
end;

class function TEAGLView.createWithFrame(frame: CGRect;
  format: NSString): TEAGLView;
var
  pRet: TEAGLView;
begin
  pRet := TEAGLView.Create();
  if (pRet <> nil) and pRet._initWithFrame(frame, format) then
  begin
    Result := pRet;
    Exit;
  end;

  pRet.Free;
  Result := nil;
end;

class function TEAGLView.createWithFrame(frame: CGRect; format: NSString;
  depth: GLuint; retained: boolean; sharegroup: EAGLSharegroup;
  sampling: Boolean; nSamples: Cardinal): TEAGLView;
var
  pRet: TEAGLView;
begin
  pRet := TEAGLView.Create();
  if (pRet <> nil) and pRet._initWithFrame(frame, format, depth, retained, sharegroup, sampling, nSamples) then
  begin
    Result := pRet;
    Exit;
  end;

  pRet.Free;
  Result := nil;
end;

destructor TEAGLView.Destroy;
begin
  _renderer.Free;
  UIView(Super).removeFromSuperview;
  _EAGLView := nil;
  inherited;
end;

function TEAGLView.getHeight: Integer;
var
  bound: CGSize;
begin
  bound := UIView(Super).bounds.size;
  Result := Round(bound.height * UIView(Super).contentScaleFactor);
end;

function TEAGLView.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(EAGLView);
end;

function TEAGLView.getView: UIView;
begin
  Result := UIView(Super);
end;

function TEAGLView.getWidth: Integer;
var
  bound: CGSize;
begin
  bound := UIView(Super).bounds.size;
  Result := Round(bound.width * UIView(Super).contentScaleFactor);
end;

function TEAGLView.initWithFrame(frame: CGRect): Pointer;
begin
  Result := UIView(Super).initWithFrame(frame);
  if GetObjectID <> Result  then
    UpdateObjectID(Result);
end;

procedure TEAGLView.layoutSubviews;
var
  view: UIView;
  size: CCSize;
begin
  view := UIView(super);

  _renderer.resizeFromLayer(CAEAGLLayer(view.layer));
  _size := _renderer.backingSize;

  size.width := _size.width;
  size.height := _size.height;


  CCDirector.sharedDirector().drawScene();
end;

class procedure TEAGLView.purgeEAGLView;
begin
  _EAGLView.Free;
end;

function TEAGLView.setupSurfaceWithSharegroup(
  sharegroup: EAGLSharegroup): Boolean;
var
  eaglLayer: CAEAGLLayer;
  view: UIView;
begin
  view := UIView(super);

  eaglLayer := CAEAGLLayer(view.layer);
  eaglLayer.setOpaque(True);
  //eaglLayer.setDrawableProperties(TNSDictionary.Wrap(TNSDictionary.OCClass.dictionaryWithObjectsAndKeys()));
  _renderer := CCES2Renderer.Create();
  if not _renderer.initWithDepthFormat(_depthFormat, convertPixelFormat(_pixelformat),
                                       sharegroup, _multiSampling, _requestedSamples) then
  begin
    Exit(False);
  end;

  _context := _renderer.context;
  //_discardFramebufferSupported
  Result := True;
end;

class function TEAGLView.sharedEAGLView: TEAGLView;
begin
  Result := _EAGLView;
end;

procedure TEAGLView.swapBuffers;
{$IFDEF __IPHONE_4_0}
var
  attachments: array [0..1] of GLenum;
  attachment: GLenum;
{$ENDIF}
begin
  {$IFDEF __IPHONE_4_0}
  if _multiSampling then
  begin
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _renderer.msaaFrameBuffer);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _renderer.defaultFrameBuffer);
    glResolveMultisampleFramebufferAPPLE();
  end;

  if _discardFramebufferSupported then
  begin
    if _multiSampling then
    begin
      if _depthFormat > 0 then
      begin
        attachments[0] := GL_COLOR_ATTACHMENT0;
        attachments[1] := GL_DEPTH_ATTACHMENT;
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, @attachments[0]);
      end else
      begin
        attachment := GL_COLOR_ATTACHMENT0;
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, @attachment);
      end;
      glBindRenderbuffer(GL_RENDERBUFFER, _renderer.colorRenderBuffer);
    end else if _depthFormat > 0 then
    begin
      attachment := GL_DEPTH_ATTACHMENT;
      glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, @attachment);
    end;
  end;
  {$ENDIF}

  if not _context.presentRenderbuffer(GL_RENDERBUFFER) then
  begin
    CCLog('error!!!', []);
  end;

  if _multiSampling then
    glBindFramebuffer(GL_FRAMEBUFFER, _renderer.msaaFrameBuffer);
end;

procedure TEAGLView.touchesBegan(touches: NSSet; withEvent: UIEvent);
var
  ids: array [0..IOS_MAX_TOUCHES_COUNT-1] of Integer;
  xs, ys: array [0..IOS_MAX_TOUCHES_COUNT-1] of single;
  i, count: Integer;
  touch: UITouch;
  ary: NSArray;
begin
(*    if (isKeyboardShown_)
    {
        [self handleTouchesAfterKeyboardShow];
        return;
    }*)
  count := 0;
  ary := touches.allObjects;
  if ary <> nil then
    count := ary.count;

  if count > 0 then
  begin
    for i := 0 to count-1 do
    begin
      touch := TUITouch.Wrap(ary.objectAtIndex(i));
      ids[i] := i;
      xs[i] := touch.locationInView(touch.view).x * UIView(super).contentScaleFactor;
      ys[i] := touch.locationInView(touch.view).y * UIView(super).contentScaleFactor;
    end;

    CCEGLView.sharedOpenGLView.handleTouchesBegin(count, ids, xs, ys);
  end;
end;

procedure TEAGLView.touchesCancelled(touches: NSSet; withEvent: UIEvent);
var
  ids: array [0..IOS_MAX_TOUCHES_COUNT-1] of Integer;
  xs, ys: array [0..IOS_MAX_TOUCHES_COUNT-1] of single;
  i, count: Integer;
  touch: UITouch;
  ary: NSArray;
begin
(*    if (isKeyboardShown_)
    {
        return;
    }*)
  count := 0;
  ary := touches.allObjects;
  if ary <> nil then
    count := ary.count;

  if count > 0 then
  begin
    for i := 0 to count-1 do
    begin
      touch := TUITouch.Wrap(ary.objectAtIndex(i));
      ids[i] := i;
      xs[i] := touch.locationInView(touch.view).x * UIView(super).contentScaleFactor;
      ys[i] := touch.locationInView(touch.view).y * UIView(super).contentScaleFactor;
    end;

    CCEGLView.sharedOpenGLView.handleTouchesCancel(count, ids, xs, ys);
  end;
end;

procedure TEAGLView.touchesEnded(touches: NSSet; withEvent: UIEvent);
var
  ids: array [0..IOS_MAX_TOUCHES_COUNT-1] of Integer;
  xs, ys: array [0..IOS_MAX_TOUCHES_COUNT-1] of single;
  i, count: Integer;
  touch: UITouch;
  ary: NSArray;
begin
(*    if (isKeyboardShown_)
    {
        return;
    }*)
  count := 0;
  ary := touches.allObjects;
  if ary <> nil then
    count := ary.count;

  if count > 0 then
  begin
    for i := 0 to count-1 do
    begin
      touch := TUITouch.Wrap(ary.objectAtIndex(i));
      ids[i] := i;
      xs[i] := touch.locationInView(touch.view).x * UIView(super).contentScaleFactor;
      ys[i] := touch.locationInView(touch.view).y * UIView(super).contentScaleFactor;
    end;

    CCEGLView.sharedOpenGLView.handleTouchesEnd(count, ids, xs, ys);
  end;
end;

procedure TEAGLView.touchesMoved(touches: NSSet; withEvent: UIEvent);
var
  ids: array [0..IOS_MAX_TOUCHES_COUNT-1] of Integer;
  xs, ys: array [0..IOS_MAX_TOUCHES_COUNT-1] of single;
  i, count: Integer;
  touch: UITouch;
  ary: NSArray;
begin
(*    if (isKeyboardShown_)
    {
        return;
    }*)
  count := 0;
  ary := touches.allObjects;
  if ary <> nil then
    count := ary.count;

  if count > 0 then
  begin
    for i := 0 to count-1 do
    begin
      touch := TUITouch.Wrap(ary.objectAtIndex(i));
      ids[i] := i;
      xs[i] := touch.locationInView(touch.view).x * UIView(super).contentScaleFactor;
      ys[i] := touch.locationInView(touch.view).y * UIView(super).contentScaleFactor;
    end;

    CCEGLView.sharedOpenGLView.handleTouchesMove(count, ids, xs, ys);
  end;
end;

function TEAGLView._initWithFrame(frame: CGRect; format: NSString;
  depth: GLuint; retained: boolean; sharegroup: EAGLSharegroup;
  sampling: Boolean; nSamples: Cardinal): Boolean;
var
  view: Pointer;
begin
  view := initWithFrame(frame);
  if view <> nil then
  begin
    _pixelformat := format;
    _depthFormat := depth;
    _multiSampling := sampling;
    _requestedSamples := nSamples;
    _preserveBackbuffer := retained;
    Result := setupSurfaceWithSharegroup(sharegroup);
    if Result then
      _EAGLView := Self;

    Exit(True);
  end;

  Result := False;
end;

function TEAGLView._initWithFrame(frame: CGRect; format: NSString): Boolean;
begin
  Result := _initWithFrame(frame, format, 0, False, nil, False, 0);
end;

function TEAGLView._initWithFrame(frame: CGRect): Boolean;
var
  kEAGLColorFormatRGB565: NSString;
begin
  kEAGLColorFormatRGB565 := NSSTR('EAGLColorFormatRGB565');
  Result := _initWithFrame(frame, kEAGLColorFormatRGB565, 0, False, nil, False, 0);
end;

{ TView3d }

var
  GLKitMod: HMODULE;
constructor TView3d.Create(AFRameRect: NSRect);
var
  V: Pointer;
begin
  GLKitMod := LoadLibrary(PWideChar(libGLKit));
  inherited Create();

  _renderer := CCES2Renderer.Create();
  if not _renderer.initWithDepthFormat(GL_DEPTH_COMPONENT16, GL_RGBA8_OES, nil,
                                       False, 0) then
  begin

  end;

  V := GLKView(Super).initWithFrame(AFrameRect, _renderer.context);
  GLKView(Super).setContentScaleFactor(TUIScreen.Wrap(TUIScreen.OCClass.mainScreen).scale);
  GLKView(Super).setDrawableDepthFormat(GLKViewDrawableDepthFormat24);
  GLKView(Super).setDrawableStencilFormat(GLKViewDrawableStencilFormat8);
  if V <> GetObjectID then
    UpdateObjectID(V);

  gView3d := Self;
end;

function TView3d.getHeight: Integer;
var
  bound: CGSize;
begin
  bound := GLKView(Super).bounds.size;
  Result := Round(bound.height * UIView(Super).contentScaleFactor);
end;

function TView3d.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(View3D);
end;

function TView3d.getView: GLKView;
begin
  Result := GLKView(Super);
end;

function TView3d.getWidth: Integer;
var
  bound: CGSize;
begin
  bound := GLKView(Super).bounds.size;
  Result := Round(bound.width * UIView(Super).contentScaleFactor);
end;

class procedure TView3d.purgeEAGLView;
begin

end;

class function TView3d.sharedEAGLView: TView3d;
begin
  Result := gView3d;
end;

procedure TView3d.swapBuffers;
begin

end;

end.
