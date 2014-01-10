unit Cocos2dx.CCESRenderer2;

interface
uses
  System.TypInfo, Cocos2dx.CCObject,
  Macapi.ObjectiveC, iOSapi.CocoaTypes, iOSapi.OpenGLES, iOSapi.QuartzCore,
  iOSapi.CoreGraphics;

type
  CCES2Renderer = class
  private
    backingWidth_: GLint;
    backingHeight_: GLint;
    samplesToUse_: Cardinal;
    multiSampling_: Boolean;
    depthFormat_: Cardinal;
    pixelFormat_: Cardinal;
    defaultFramebuffer_: GLuint;
    colorRenderbuffer_: GLuint;
    depthBuffer_: GLuint;
    msaaFramebuffer_: GLuint;
    msaaColorbuffer_: GLuint;
    context_: EAGLContext;
  public
    constructor Create();
    destructor Destroy(); override;
    class function CreateWithDepthFormat(depthFormat: Cardinal; pixelFormat: Cardinal; sharegroup: EAGLSharegroup;
      multiSampling: Boolean; requestedSamples: Cardinal): CCES2Renderer;
    function initWithDepthFormat(depthFormat: Cardinal; pixelFormat: Cardinal; sharegroup: EAGLSharegroup;
      multiSampling: Boolean; requestedSamples: Cardinal): Boolean;

    function resizeFromLayer(layer: CAEAGLLayer): Boolean;
    function backingSize(): CGSize;

    property colorRenderBuffer: Cardinal read colorRenderbuffer_;
    property defaultFrameBuffer: Cardinal read defaultFramebuffer_;
    property msaaFrameBuffer: Cardinal read msaaFramebuffer_;
    property msaaColorBuffer: Cardinal read msaaColorbuffer_;
    property context: EAGLContext read context_;
  end;

implementation
uses
  System.SysUtils,
  System.Math, iOSapi.Foundation,
  Cocos2dx.CCCommon, Cocos2dx.CCPlatformMacros;

{ CCES2Renderer }

function CCES2Renderer.backingSize: CGSize;
begin
  Result := CGSizeMake(backingWidth_, backingHeight_);
end;

constructor CCES2Renderer.Create;
begin
  inherited Create();
end;

class function CCES2Renderer.CreateWithDepthFormat(depthFormat, pixelFormat: Cardinal;
  sharegroup: EAGLSharegroup; multiSampling: Boolean;
  requestedSamples: Cardinal): CCES2Renderer;
var
  pRet: CCES2Renderer;
begin
  pRet := CCES2Renderer.Create();
  if (pRet <> nil) and pRet.initWithDepthFormat(depthFormat, pixelFormat, sharegroup, multiSampling, requestedSamples) then
  begin
    Result := pRet;
    Exit;
  end;
  pRet.Free;
  Result := nil;
end;

destructor CCES2Renderer.Destroy;
begin
  if defaultFramebuffer_ > 0 then
  begin
    glDeleteFramebuffers(1, @defaultFramebuffer_);
    defaultFramebuffer_ := 0;
  end;
  if colorRenderbuffer_ > 0 then
  begin
    glDeleteRenderbuffers(1, @colorRenderbuffer_);
    colorRenderbuffer_ := 0;
  end;
  if depthBuffer_ > 0 then
  begin
    glDeleteRenderbuffers(1, @depthBuffer_);
    depthBuffer_ := 0;
  end;
  if msaaColorbuffer_ > 0 then
  begin
    glDeleteRenderbuffers(1, @msaaColorbuffer_);
    msaaColorbuffer_ := 0;
  end;
  if msaaFramebuffer_ > 0 then
  begin
    glDeleteRenderbuffers(1, @msaaFramebuffer_);
    msaaFramebuffer_ := 0;
  end;

  if TEAGLContext.OCClass.currentContext = (context_ as ILocalObject).GetObjectID then
    TEAGLContext.OCClass.setCurrentContext(nil);

  context_ := nil;
  inherited;
end;

function CCES2Renderer.initWithDepthFormat(depthFormat, pixelFormat: Cardinal;
  sharegroup: EAGLSharegroup; multiSampling: Boolean;
  requestedSamples: Cardinal): Boolean;
var
  bRet: Boolean;
  maxSamplesAllowed: GLint;
begin
  bRet := False;

  repeat

    if sharegroup = nil then
      context_ := TEAGLContext.Wrap(TEAGLContext.Create.initWithAPI(kEAGLRenderingAPIOpenGLES2))
    else
      context_ := TEAGLContext.Wrap(TEAGLContext.Create.initWithAPI(kEAGLRenderingAPIOpenGLES2, sharegroup));

    if (context_ = nil) or not TEAGLContext.OCClass.setCurrentContext(context_) then
      Break;

    depthFormat_ := depthFormat;
    pixelFormat_ := pixelFormat;
    multiSampling_ := multiSampling;

    glGenFramebuffers(1, @defaultFramebuffer_);
    if defaultFramebuffer_ = 0 then
      Break;

    glGenRenderbuffers(1, @colorRenderbuffer_);
    if colorRenderbuffer_ = 0 then
      Break;

    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer_);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer_);

    if multiSampling_ then
    begin
      glGetIntegerv(GL_MAX_SAMPLES_APPLE, @maxSamplesAllowed);
      samplesToUse_ := Min(maxSamplesAllowed, requestedSamples);

      glGenFramebuffers(1, @msaaFramebuffer_);
      if msaaFramebuffer_ = 0 then
        Break;

      glBindFramebuffer(GL_FRAMEBUFFER, msaaFramebuffer_);
    end;

    bRet := True;

  until True;

  Result := bRet;
end;

function CCES2Renderer.resizeFromLayer(layer: CAEAGLLayer): Boolean;
var
  error: GLenum;
begin
  glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);
  if not context_.renderbufferStorage(GL_RENDERBUFFER, (layer as ILocalObject).GetObjectID) then
  begin
    CCLog('failed to call context', []);
  end;
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, @backingWidth_);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, @backingHeight_);

  CCLog('cocos2d: surface size: %dx%d', [Round(backingWidth_), Round(backingHeight_)]);

  if multiSampling_ then
  begin
    if msaaColorbuffer_ > 0 then
    begin
      glDeleteRenderbuffers(1, @msaaColorbuffer_);
      msaaColorbuffer_ := 0;
    end;

    glBindFramebuffer(GL_FRAMEBUFFER, msaaFramebuffer_);
    glGenRenderbuffers(1, @msaaColorbuffer_);

    glBindRenderbuffer(GL_RENDERBUFFER, msaaColorbuffer_);

    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samplesToUse_, pixelFormat_, backingWidth_, backingHeight_);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, msaaColorbuffer_);

    error := glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if error <> GL_FRAMEBUFFER_COMPLETE then
    begin
      CCLog('Failed to make complete framebuffer object 0x%X', [error]);
      Exit(False);
    end;
  end;

  if depthFormat_ > 0 then
  begin
    if depthBuffer_ = 0 then
    begin
      glGenRenderbuffers(1, @depthBuffer_);
    end;
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer_);

    if multiSampling_ then
      glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samplesToUse_, depthFormat_, backingWidth_, backingHeight_)
    else
      glRenderbufferStorage(GL_RENDERBUFFER, depthFormat_, backingWidth_, backingHeight_);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer_);

    if depthFormat_ = GL_DEPTH24_STENCIL8_OES then
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthBuffer_);

    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);
  end;

  error := glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if error <> GL_FRAMEBUFFER_COMPLETE then
  begin
    CCLog('Failed to make complete framebuffer object 0x%X', [error]);
    Exit(False);
  end;

  Result := True;
end;

end.
