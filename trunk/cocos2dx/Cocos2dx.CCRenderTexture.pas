(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Jason Booth

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

unit Cocos2dx.CCRenderTexture;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCNode, Cocos2dx.CCSprite, Cocos2dx.CCTexture2D, Cocos2dx.CCImage, mat4, Cocos2dx.CCTypes;

type
  tCCImageFormat = (kCCImageFormatJPEG, kCCImageFormatPNG);

  (**
  @brief CCRenderTexture is a generic rendering target. To render things into it,
  simply construct a render target, call begin on it, call visit on any cocos
  scenes or objects to render them, and call end. For convenience, render texture
  adds a sprite as it's display child with the results, so you can simply add
  the render texture to your scene and treat it like any other CocosNode.
  There are also functions for saving the render texture to disk in PNG or JPG format.

  @since v0.8.1
  *)
  CCRenderTexture = class(CCNode)
  private
    procedure beginWithClear(r, g, b, a, depthValue: Single; stencilValue: Integer; flags: GLbitfield); overload;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(w, h: Integer; eFormat: CCTexture2DPixelFormat; uDepthStencilFormat: GLuint): CCRenderTexture; overload;
    class function _create(w, h: Integer; eFormat: CCTexture2DPixelFormat): CCRenderTexture; overload;
    class function _create(w, h: Integer): CCRenderTexture; overload;
    function initWithWidthAndHeight(w, h: Integer; eFormat: CCTexture2DPixelFormat): Boolean; overload;
    function initWithWidthAndHeight(w, h: Integer; eFormat: CCTexture2DPixelFormat; uDepthStencilFormat: GLuint): Boolean; overload;
    procedure _begin();
    procedure _end();
    procedure draw(); override;
    procedure visit(); override;
    procedure beginWithClear(r, g, b, a: Single); overload;
    procedure beginWithClear(r, g, b, a, depthValue: Single); overload;
    procedure beginWithClear(r, g, b, a, depthValue: Single; stencilValue: Integer); overload;
    procedure clear(r, g, b, a: Single);
    procedure clearDepth(depthValue: Single);
    procedure clearStencil(stencilValue: Integer);
    function newCCImage(flipImage: Boolean = True): CCImage;
    function saveToFile(const szFilePath: string): Boolean; overload;
    function saveToFile(const name: string; iformat: tCCImageFormat): Boolean; overload;
    procedure listenToBackground(pObj: CCObject);
    procedure listenForeground(pObj: CCObject);
    function getClearFlags(): Cardinal;
    procedure setClearFlags(uClearFlags: Cardinal);
    function getClearColor(): ccColor4F;
    procedure setClearColor(const clearColor: ccColor4F);
    function getClearDepth(): Single;
    procedure setClearDepth(fClearDepth: Single);
    function getClearStencil(): Integer;
    procedure setClearStencil(fClearStencil: Single);
    function isAutoDraw(): Boolean;
    procedure setAutoDraw(bAutoDraw: Boolean);
    function getSprite: CCSprite;
    procedure setSprite(const Value: CCSprite);
  protected
    m_uFBO: GLuint;
    m_uDepthRenderBuffer: GLuint;
    m_nOldFBO: GLint;
    m_pTexture: CCTexture2D;
    m_pTextureCopy: CCTexture2D;
    m_pUITextureImage: CCImage;
    m_ePixelFormat: GLenum;
    m_pSprite: CCSprite;
    m_uClearFlags: GLbitfield;
    m_sClearColor: ccColor4F;
    m_fClearDepth: GLclampf;
    m_nClearStencil: GLint;
    m_bAutoDraw: Boolean;
  public
    (** The CCSprite being used.
    The sprite, by default, will use the following blending function: GL_ONE, GL_ONE_MINUS_SRC_ALPHA.
    The blending function can be changed in runtime by calling:
    - [[renderTexture sprite] setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
    *)
    property Sprite: CCSprite read getSprite write setSprite;
  end;

implementation
uses
  SysUtils, Cocos2dx.CCDirector,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCMacros, Cocos2dx.CCConfiguration, Cocos2dx.CCUtils, Cocos2dx.CCGeometry,
  matrix, utility, Cocos2dx.CCFileUtils, Cocos2dx.CCDirectorProjection;


{$ifdef IOS}
const CC_GL_DEPTH24_STENCIL8 = GL_DEPTH24_STENCIL8_OES;
{$else}
const CC_GL_DEPTH24_STENCIL8 = GL_DEPTH24_STENCIL8;
{$endif}

{ CCRenderTexture }

procedure CCRenderTexture._begin;
var
  director: CCDirector;
  texSize, size: CCSize;
  widthRatio, heightRatio: Single;
  orthoMatrix: kmMat4;
begin
  kmGLMatrixMode(KM_GL_PROJECTION);
  kmGLPushMatrix();
  kmGLMatrixMode(KM_GL_MODELVIEW);
  kmGLPushMatrix();

  director := CCDirector.sharedDirector();
  director.setProjection(director.getProjection());
  
  texSize := m_pTexture.getContentSizeInPixels();
  size := director.getWinSizeInPixels();
  widthRatio := size.width/texSize.width;
  heightRatio := size.height/texSize.height;

  glViewport(0, 0, Round(texSize.width), Round(texSize.height));

  kmMat4OrthographicProjection(@orthoMatrix, -1.0/widthRatio, 1.0/widthRatio, -1.0/heightRatio,
    1.0/heightRatio, -1, 1);
  kmGLMultMatrix(@orthoMatrix);

  glGetIntegerv(GL_FRAMEBUFFER_BINDING, @m_nOldFBO);
  glBindFramebuffer(GL_FRAMEBUFFER, m_uFBO);

  if CCConfiguration.sharedConfiguration().checkForGLExtension('GL_QCOM') then
  begin
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_pTextureCopy.Name, 0);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_pTexture.Name, 0);
  end;  
end;

class function CCRenderTexture._create(w, h: Integer): CCRenderTexture;
var
  pRet: CCRenderTexture;
begin
  pRet := CCRenderTexture.Create();
  if (pRet <> nil) and pRet.initWithWidthAndHeight(w, h, kCCTexture2DPixelFormat_RGBA8888, 0) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCRenderTexture._create(w, h: Integer;
  eFormat: CCTexture2DPixelFormat): CCRenderTexture;
var
  pRet: CCRenderTexture;
begin
  pRet := CCRenderTexture.Create();
  if (pRet <> nil) and pRet.initWithWidthAndHeight(w, h, eFormat) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCRenderTexture._create(w, h: Integer;
  eFormat: CCTexture2DPixelFormat;
  uDepthStencilFormat: GLuint): CCRenderTexture;
var
  pRet: CCRenderTexture;
begin
  pRet := CCRenderTexture.Create();
  if (pRet <> nil) and pRet.initWithWidthAndHeight(w, h, eFormat, uDepthStencilFormat) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCRenderTexture._end;
var
  director: CCDirector;
begin
  director := CCDirector.sharedDirector();
  glBindFramebuffer(GL_FRAMEBUFFER, m_nOldFBO);
  director.setViewport();

  kmGLMatrixMode(KM_GL_PROJECTION);
  kmGLPopMatrix();
  kmGLMatrixMode(KM_GL_MODELVIEW);
  kmGLPopMatrix();
end;

procedure CCRenderTexture.beginWithClear(r, g, b, a, depthValue: Single;
  stencilValue: Integer; flags: GLbitfield);
var
  clearColor: array [0..3] of GLfloat;
  depthClearValue: GLfloat;
  stencilClearValue: Integer;
begin
  Self._begin();

  if flags and GL_COLOR_BUFFER_BIT > 0 then
  begin
    glGetFloatv(GL_COLOR_CLEAR_VALUE, @clearColor[0]);
    glClearColor(r, g, b, a);
  end;

  if flags and GL_DEPTH_BUFFER_BIT > 0 then
  begin
    glGetFloatv(GL_DEPTH_CLEAR_VALUE, @depthClearValue);
    {$IFDEF IOS}
    glClearDepthf(depthValue);
    {$ELSE}
    glClearDepth(depthValue);
    {$ENDIF}
  end;

  if flags and GL_STENCIL_BUFFER_BIT > 0 then
  begin
    glGetIntegerv(GL_STENCIL_CLEAR_VALUE, @stencilClearValue);
    glClearStencil(stencilValue);
  end;

  glClear(flags);

  if flags and GL_COLOR_BUFFER_BIT > 0 then
  begin
    glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);
  end;

  if flags and GL_DEPTH_BUFFER_BIT > 0 then
  begin
    {$IFDEF IOS}
    glClearDepthf(depthValue);
    {$ELSE}
    glClearDepth(depthValue);
    {$ENDIF}
  end;

  if flags and GL_STENCIL_BUFFER_BIT > 0 then
  begin
    glClearStencil(stencilClearValue);
  end;
end;

procedure CCRenderTexture.beginWithClear(r, g, b, a, depthValue: Single);
begin
  beginWithClear(r, g, b, a, depthValue, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;

procedure CCRenderTexture.beginWithClear(r, g, b, a, depthValue: Single;
  stencilValue: Integer);
begin
  beginWithClear(r, g, b, a, depthValue, stencilValue, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
end;

procedure CCRenderTexture.beginWithClear(r, g, b, a: Single);
begin
  beginWithClear(r, g, b, a, 0, 0, GL_COLOR_BUFFER_BIT);
end;

procedure CCRenderTexture.clear(r, g, b, a: Single);
begin
  Self.beginWithClear(r, g, b, a);
  Self._end();
end;

procedure CCRenderTexture.clearDepth(depthValue: Single);
var
  depthClearValue: GLfloat;
begin
  Self._begin();
  glGetFloatv(GL_DEPTH_CLEAR_VALUE, @depthClearValue);
  {$ifdef IOS}
  glClearDepthf(depthValue);
  {$else}
  glClearDepth(depthValue);
  {$endif}
  glClear(GL_DEPTH_BUFFER_BIT);
  {$ifdef IOS}
  glClearDepthf(depthClearValue);
  {$else}
  glClearDepth(depthClearValue);
  {$endif}
  Self._end();
end;

procedure CCRenderTexture.clearStencil(stencilValue: Integer);
var
  stencilClearValue: Integer;
begin
  glGetIntegerv(GL_STENCIL_CLEAR_VALUE, @stencilClearValue);
  glClearStencil(stencilValue);
  glClear(GL_STENCIL_BUFFER_BIT);
  glClearStencil(stencilClearValue);
end;

constructor CCRenderTexture.Create;
begin
  inherited Create();
  m_ePixelFormat := Ord(kCCTexture2DPixelFormat_RGBA8888);
end;

destructor CCRenderTexture.Destroy;
begin
  CC_SAFE_RELEASE(m_pSprite);
  CC_SAFE_RELEASE(m_pTextureCopy);
  glDeleteFramebuffers(1, @m_uFBO);
  if m_uDepthRenderBuffer > 0 then
  begin
    glDeleteRenderbuffers(1, @m_uDepthRenderBuffer);
  end;
  CC_SAFE_DELETE(m_pUITextureImage);
  inherited;
end;

function CCRenderTexture.getSprite: CCSprite;
begin
  Result := m_pSprite;
end;

function CCRenderTexture.initWithWidthAndHeight(w, h: Integer;
  eFormat: CCTexture2DPixelFormat; uDepthStencilFormat: GLuint): Boolean;
var
  bRet: Boolean;
  powW, powH: Cardinal;
  data: Pointer;
  oldRBO: GLint;
  tBlendFunc: ccBlendFunc;
begin
  CCAssert(eFormat <> kCCTexture2DPixelFormat_A8, 'only RGB and RGBA formats are valid for a render texture');

  data := nil;
  bRet := False;
  repeat

    w := Round(w * CC_CONTENT_SCALE_FACTOR());
    h := Round(h * CC_CONTENT_SCALE_FACTOR());

    glGetIntegerv(GL_FRAMEBUFFER_BINDING, @m_nOldFBO);

    if CCConfiguration.sharedConfiguration().supportsNPOT() then
    begin
      powW := w; powH := h;
    end else
    begin
      powW := ccNextPOT(w); powH := ccNextPOT(h);
    end;

    data := AllocMem(powW * powH * 4);
    if data = nil then
      Break;

    m_ePixelFormat := Ord(eFormat);

    m_pTexture := CCTexture2D.Create();
    if m_pTexture <> nil then
    begin
      m_pTexture.initWithData(data, CCTexture2DPixelFormat(m_ePixelFormat), powW, powH, CCSizeMake(w, h));
    end else
    begin
      Break;
    end;

    glGetIntegerv(GL_RENDERBUFFER_BINDING, @oldRBO);
    if CCConfiguration.sharedConfiguration().checkForGLExtension('GL_QCOM') then
    begin
      m_pTextureCopy := CCTexture2D.Create;
      if m_pTextureCopy <> nil then
      begin
        m_pTextureCopy.initWithData(data, CCTexture2DPixelFormat(m_ePixelFormat), powW, powH, CCSizeMake(w, h));
      end else
      begin
        Break;
      end;    
    end;  

    glGenFramebuffers(1, @m_uFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, m_uFBO);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_pTexture.Name, 0);

    if uDepthStencilFormat <> 0 then
    begin
      glGenRenderbuffers(1, @m_uDepthRenderBuffer);
      glBindRenderbuffer(GL_RENDERBUFFER, m_uDepthRenderBuffer);
      glRenderbufferStorage(GL_RENDERBUFFER, uDepthStencilFormat, powW, powH);
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_uDepthRenderBuffer);

      if uDepthStencilFormat = CC_GL_DEPTH24_STENCIL8 then
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, m_uDepthRenderBuffer);
    end;

    m_pTexture.setAntiAliasTexParameters();
    setSprite(CCSprite.createWithTexture(m_pTexture));

    m_pTexture.release();
    m_pSprite.ScaleY := -1;

    tBlendFunc.src := GL_ONE; tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
    m_pSprite.setBlendFunc(tBlendFunc);

    glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
    glBindFramebuffer(GL_FRAMEBUFFER, m_nOldFBO);

    m_bAutoDraw := False;
    addChild(m_pSprite);

    bRet := True;

  until True;
  
  FreeMem(data);

  Result := bRet;
end;

function CCRenderTexture.initWithWidthAndHeight(w, h: Integer;
  eFormat: CCTexture2DPixelFormat): Boolean;
begin
  Result := initWithWidthAndHeight(w, h, eFormat, 0);
end;

procedure CCRenderTexture.listenToBackground(pObj: CCObject);
begin
(*
#if CC_ENABLE_CACHE_TEXTURE_DATA
    
    CC_SAFE_DELETE(m_pUITextureImage);
    
    // to get the rendered texture data
    m_pUITextureImage = newCCImage();


    if (m_pUITextureImage)
    {
        const CCSize& s = m_pTexture->getContentSizeInPixels();
        VolatileTexture::addDataTexture(m_pTexture, m_pUITextureImage->getData(), kTexture2DPixelFormat_RGBA8888, s);
    } 
    else
    {
        CCLOG("Cache rendertexture failed!");
    }
#endif
*)
end;

function CCRenderTexture.newCCImage(flipImage: Boolean): CCImage;
var
  s: CCSize;
  nSavedBufferWidth, nSavedBufferHeight: Integer;
  pBuffer, pTempData, pSrc, pDst: PGLubyte;
  pImage: CCImage;
  i: Integer;
begin
  CCAssert(m_ePixelFormat = Cardinal(Ord(kCCTexture2DPixelFormat_RGBA8888)), 'only RBGA8888 can be saved as image');

  if m_pTexture = nil then
  begin
    Result := nil;
    Exit;
  end;

  s := m_pTexture.getContentSizeInPixels();
  nSavedBufferWidth := Round(s.width);
  nSavedBufferHeight := Round(s.height);

  //pBuffer := nil;
  pTempData := nil;
  pImage := nil;

  repeat
    pBuffer := AllocMem(nSavedBufferWidth * nSavedBufferHeight * 4);
    if pBuffer = nil then
      Break;

    pTempData := AllocMem(nSavedBufferWidth * nSavedBufferHeight * 4);
    if pTempData = nil then
    begin
      FreeMem(pBuffer);
      pBuffer := nil;
      Break;
    end;

    Self._begin();
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0, 0, nSavedBufferWidth, nSavedBufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, pTempData);
    Self._end();

    if flipImage then
    begin
      for i := 0 to nSavedBufferHeight-1 do
      begin
        pSrc := PGLubyte(Integer(pTempData) + (nSavedBufferHeight - i - 1) * nSavedBufferWidth * 4);
        pDst := PGLubyte(Integer(pBuffer) + i * nSavedBufferWidth * 4);
        Move(pSrc^, pDst^, nSavedBufferWidth * 4);
      end;
      pImage.initWithImageData(pBuffer, nSavedBufferWidth * nSavedBufferHeight * 4, kFmtRawData, nSavedBufferWidth, nSavedBufferHeight, 8);
    end else
    begin
      pImage.initWithImageData(pTempData, nSavedBufferWidth * nSavedBufferHeight * 4, kFmtRawData, nSavedBufferWidth, nSavedBufferHeight, 8);
    end;  



  until True;

  FreeMem(pBuffer);
  FreeMem(pTempData);

  Result := pImage;
end;

function CCRenderTexture.saveToFile(const szFilePath: string): Boolean;
var
  bRet: Boolean;
  pImage: CCImage;
begin
  bRet := False;
  pImage := newCCImage();
  if pImage <> nil then
    bRet := pImage.saveToFile(szFilePath);
  CC_SAFE_DELETE(pImage);
  Result := bRet;
end;

function CCRenderTexture.saveToFile(const name: string;
  iformat: tCCImageFormat): Boolean;
var
  bRet: Boolean;
  pImage: CCImage;
  fullpath: string;
begin
  bRet := False;
  CCAssert((iformat = kCCImageFormatJPEG) or (iformat = kCCImageFormatPNG), 'the image can only be saved as JPG or PNG format');

  pImage := newCCImage();
  if pImage <> nil then
  begin
    fullpath := CCFileUtils.sharedFileUtils().getWritablePath() + name;
    bRet := pImage.saveToFile(fullpath);
  end;
  CC_SAFE_DELETE(pImage);
  Result := bRet;
end;

procedure CCRenderTexture.setSprite(const Value: CCSprite);
begin
  CC_SAFE_RELEASE(m_pSprite);
  m_pSprite := Value;
  CC_SAFE_RETAIN(m_pSprite);
end;

procedure CCRenderTexture.draw;
var
  oldClearColor: array [0..3] of GLfloat;
  oldDepthClearValue: GLfloat;
  oldStencilClearValue: GLint;
  pNode: CCNode;
  i: Integer;
begin
  if m_bAutoDraw then
  begin
    _begin();

    if m_uClearFlags > 0 then
    begin
      if m_uClearFlags and GL_COLOR_BUFFER_BIT > 0 then
      begin
        glGetFloatv(GL_COLOR_CLEAR_VALUE, @oldClearColor[0]);
        glClearColor(m_sClearColor.r, m_sClearColor.g, m_sClearColor.b, m_sClearColor.a);
      end;

      if m_uClearFlags and GL_DEPTH_BUFFER_BIT > 0 then
      begin
        glGetFloatv(GL_DEPTH_CLEAR_VALUE, @oldDepthClearValue);
        {$IFDEF IOS}
        glClearDepthf(m_fClearDepth);
        {$ELSE}
        glClearDepth(m_fClearDepth);
        {$ENDIF}
      end;

      if m_uClearFlags and GL_STENCIL_BUFFER_BIT > 0 then
      begin
        glGetIntegerv(GL_STENCIL_CLEAR_VALUE, @oldStencilClearValue);
        glClearStencil(m_nClearStencil);
      end;

      glClear(m_uClearFlags);

      if m_uClearFlags and GL_COLOR_BUFFER_BIT > 0 then
      begin
        glClearColor(oldClearColor[0], oldClearColor[1], oldClearColor[2], oldClearColor[3]);
      end;

      if m_uClearFlags and GL_DEPTH_BUFFER_BIT > 0 then
      begin
        {$IFDEF IOS}
        glClearDepthf(oldDepthClearValue);
        {$ELSE}
        glClearDepth(oldDepthClearValue);
        {$ENDIF}
      end;

      if m_uClearFlags and GL_STENCIL_BUFFER_BIT > 0 then
      begin
        glClearStencil(oldStencilClearValue);
      end;  
    end;

    sortAllChildren();

    if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    begin
      for i := 0 to m_pChildren.count()-1 do
      begin
        pNode := CCNode(m_pChildren.objectAtIndex(i));
        if pNode <> nil then
          pNode.visit();
      end;  
    end;

    _end();
  end;
end;

function CCRenderTexture.getClearColor: ccColor4F;
begin
  Result := m_sClearColor;
end;

function CCRenderTexture.getClearDepth: Single;
begin
  Result := m_fClearDepth;
end;

function CCRenderTexture.getClearFlags: Cardinal;
begin
  Result := m_uClearFlags;
end;

function CCRenderTexture.getClearStencil: Integer;
begin
  Result := m_nClearStencil;
end;

function CCRenderTexture.isAutoDraw: Boolean;
begin
  Result := m_bAutoDraw;
end;

procedure CCRenderTexture.listenForeground(pObj: CCObject);
begin

end;

procedure CCRenderTexture.setAutoDraw(bAutoDraw: Boolean);
begin

end;

procedure CCRenderTexture.setClearColor(const clearColor: ccColor4F);
begin
  m_sClearColor := clearColor;
end;

procedure CCRenderTexture.setClearDepth(fClearDepth: Single);
begin
  m_fClearDepth := fClearDepth;
end;

procedure CCRenderTexture.setClearFlags(uClearFlags: Cardinal);
begin
  m_uClearFlags := uClearFlags;
end;

procedure CCRenderTexture.setClearStencil(fClearStencil: Single);
begin
  m_nClearStencil := Round(fClearStencil);
end;

procedure CCRenderTexture.visit;
begin
  if not m_bVisible then
    Exit;

  kmGLPushMatrix();

  if (m_pGrid <> nil) and m_pGrid.isActive() then
  begin
    m_pGrid.beforeDraw();
    transformAncestors();
  end;

  transform();
  m_pSprite.visit();
  draw();

  if (m_pGrid <> nil) and m_pGrid.isActive() then
  begin
    m_pGrid.afterDraw(Self);
  end;

  kmGLPopMatrix();

  m_uOrderOfArrival := 0;
end;

end.
