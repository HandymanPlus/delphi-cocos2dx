(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (C) 2008      Apple Inc. All Rights Reserved.

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

unit Cocos2dx.CCTexture2D;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils,
  Cocos2dx.CCObject, Cocos2dx.CCImage, Cocos2dx.CCGLProgram, Cocos2dx.CCGeometry,
  Cocos2dx.CCTypes;

type
  CCTexture2DPixelFormat =
  (
    //! 32-bit texture: RGBA8888
    kCCTexture2DPixelFormat_RGBA8888,
    //! 24-bit texture: RGBA888
    kCCTexture2DPixelFormat_RGB888,
    //! 16-bit texture without Alpha channel
    kCCTexture2DPixelFormat_RGB565,
    //! 8-bit textures used as masks
    kCCTexture2DPixelFormat_A8,
    //! 8-bit intensity texture
    kCCTexture2DPixelFormat_I8,
    //! 16-bit textures used as masks
    kCCTexture2DPixelFormat_AI88,
    //! 16-bit textures: RGBA4444
    kCCTexture2DPixelFormat_RGBA4444,
    //! 16-bit textures: RGB5A1
    kCCTexture2DPixelFormat_RGB5A1,    
    //! 4-bit PVRTC-compressed texture: PVRTC4
    kCCTexture2DPixelFormat_PVRTC4,
    //! 2-bit PVRTC-compressed texture: PVRTC2
    kCCTexture2DPixelFormat_PVRTC2,

    //! Default texture format: RGBA8888
    kCCTexture2DPixelFormat_Default = kCCTexture2DPixelFormat_RGBA8888,

    // backward compatibility stuff
    kTexture2DPixelFormat_RGBA8888  = kCCTexture2DPixelFormat_RGBA8888,
    kTexture2DPixelFormat_RGB888    = kCCTexture2DPixelFormat_RGB888,
    kTexture2DPixelFormat_RGB565    = kCCTexture2DPixelFormat_RGB565,
    kTexture2DPixelFormat_A8        = kCCTexture2DPixelFormat_A8,
    kTexture2DPixelFormat_RGBA4444  = kCCTexture2DPixelFormat_RGBA4444,
    kTexture2DPixelFormat_RGB5A1    = kCCTexture2DPixelFormat_RGB5A1,
    kTexture2DPixelFormat_Default   = kCCTexture2DPixelFormat_Default
  );

  //Extension to set the Min / Mag filter
  ccTexParams = record
    minFilter: GLuint;
    magFilter: GLuint;
    wrapS: GLuint;
    wrapT: GLuint;
  end;
  pccTexParams = ^ccTexParams;

  (** @brief CCTexture2D class.
    * This class allows to easily create OpenGL 2D textures from images, text or raw data.
    * The created CCTexture2D object will always have power-of-two dimensions.
    * Depending on how you create the CCTexture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
    * Be aware that the content of the generated textures will be upside-down!
    *)
  CCTexture2D = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    function description(): string;
    procedure releaseData(data: Pointer);
    function keepData(data: Pointer; length: Cardinal): Pointer;
    function initWithData(data: Pointer; pixelFormat: CCTexture2DPixelFormat; pixelswide, pixelsHigh: Cardinal; contentSize: CCSize): Boolean;
    procedure drawAtPoint(const point: CCPoint);
    procedure drawInRect(const rect: CCRect);
    function initWithImage(uiImage: CCImage): Boolean;
    function initWithString(const text, fontName: string; fontSize: Single; const dimensions: CCSize;
      hAlignment: CCTextAlignment; vAlignment: CCVerticalTextAlignment): Boolean; overload;
    function initWithString(const text: string; const fontName: string; fontSize: Single): Boolean; overload;
    function initWithString(const text: string; textDefinition: pccFontDefinition): Boolean; overload;
    function initWithPVRFile(const pfile: string): Boolean;
    function initWithETCFile(const fileName: string): Boolean;
    procedure setTexParameters(texParams: pccTexParams);
    procedure setAntiAliasTexParameters();
    procedure setAliasTexParameters();
    procedure generateMipmap();
    function stringForFormat(): string;
    function bitsPerPixelForFormat(): Integer; overload;
    function bitsPerPixelForFormat(format: CCTexture2DPixelFormat): Cardinal; overload;
    class procedure setDefaultAlphaPixelFormat(format: CCTexture2DPixelFormat);
    function defaultAlphaPixelFormat(): CCTexture2DPixelFormat;
    class procedure PVRImagesHavePremultipliedAlpha(haveAlphaPremultiplied: Boolean);
    function getContentSizeInPixels(): CCSize;
    function hasPremultipliedAlpha(): Boolean;
    function hasMipmaps(): Boolean;
    function getContentSize: CCSize;
  private
    m_bHasPremultipliedAlpha: Boolean;
    m_bHasMipmaps: Boolean;
    m_fMaxS, m_fMaxT: GLfloat;
    m_tContentSize: CCSize;
    m_uName: GLuint;
    m_uPixelsWide: Cardinal;
    m_uPixelsHigh: Cardinal;
    m_ePixelFormat: CCTexture2DPixelFormat;
    m_pShaderProgram: CCGLProgram;
    m_bPVRHaveAlphaPremultiplied: Boolean;
    function initPremultipliedATextureWithImage(image: CCImage; width, height: Cardinal): Boolean;
  public
    function getMaxs: GLfloat;
    function getMaxT: GLfloat;
    function getName: GLuint;
    function getPixelFormat: CCTexture2DPixelFormat;
    function getPixelsHigh: Cardinal;
    function getPixelsWide: Cardinal;
    function getShaderProgram: CCGLProgram;
    procedure setMaxs(const maxS: GLfloat);
    procedure setMaxT(const maxT: GLfloat);
    procedure setShaderProgram(const pShaderProgram: CCGLProgram);
  public
    property PixelFormat: CCTexture2DPixelFormat read getPixelFormat;
    property PixelsWide: Cardinal read getPixelsWide;
    property PixelsHigh: Cardinal read getPixelsHigh;
    property Name: GLuint read getName;
    property MaxS: GLfloat read getMaxs write setMaxs;
    property MaxT: GLfloat read getMaxT write setMaxT;
    property ContentSize: CCSize read getContentSize;
    property ShaderProgram: CCGLProgram read getShaderProgram write setShaderProgram;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCGLStateCache, Cocos2dx.CCDirector,
  Cocos2dx.CCUtils, Cocos2dx.CCShaderCache, Cocos2dx.CCConfiguration,
  Cocos2dx.CCCommon, Cocos2dx.CCString, Cocos2dx.CCTexturePVR, Cocos2dx.CCTextureETC;

{ CCTexture2D }

var g_defaultAlphaPixelFormat: CCTexture2DPixelFormat = kCCTexture2DPixelFormat_Default;
var PVRHaveAlphaPremultiplied_: Boolean = False;

function CCTexture2D.bitsPerPixelForFormat(
  format: CCTexture2DPixelFormat): Cardinal;
var
  ret: Cardinal;
begin
	case format of
		 kCCTexture2DPixelFormat_RGBA8888:
			ret := 32;
		 kCCTexture2DPixelFormat_RGB888:
			// It is 32 and not 24, since its internal representation uses 32 bits.
			ret := 32;
		 kCCTexture2DPixelFormat_RGB565:
			ret := 16;
		 kCCTexture2DPixelFormat_RGBA4444:
			ret := 16;
		 kCCTexture2DPixelFormat_RGB5A1:
			ret := 16;
		 kCCTexture2DPixelFormat_AI88:
			ret := 16;
		 kCCTexture2DPixelFormat_A8:
			ret := 8;
		 kCCTexture2DPixelFormat_I8:
			ret := 8;
		 kCCTexture2DPixelFormat_PVRTC4:
			ret := 4;
		 kCCTexture2DPixelFormat_PVRTC2:
			ret := 2;
  else
    begin
			ret := $FFFFFFFF;
			CCAssert(false , 'unrecognized pixel format');
			CCLOG('bitsPerPixelForFormat: %d, cannot give useful result', [Cardinal(format)]);
    end;  
  end;
	Result := ret;
end;

function CCTexture2D.bitsPerPixelForFormat: Integer;
begin
  Result := bitsPerPixelForFormat(m_ePixelFormat);
end;

constructor CCTexture2D.Create;
begin
  inherited Create();
  {m_uPixelsWide := 0;
  m_uPixelsHigh := 0;
  m_uName := 0;
  m_fMaxS := 0.0;
  m_fMaxT := 0.0;
  m_bHasPremultipliedAlpha := False;
  m_bHasMipmaps := False;
  m_pShaderProgram := nil;}
  m_bPVRHaveAlphaPremultiplied := True;
end;

function CCTexture2D.defaultAlphaPixelFormat: CCTexture2DPixelFormat;
begin
  Result := g_defaultAlphaPixelFormat;
end;

function CCTexture2D.description: string;
begin
  Result := CCString.createWithFormat('<CCTexture2D | Name = %d | Dimensions = %d x %d | Coordinates = (%.2f, %.2f)>',
    [m_uName, m_uPixelsWide, m_uPixelsHigh, m_fMaxS, m_fMaxT]).m_sString;
end;

destructor CCTexture2D.Destroy;
begin
  CC_SAFE_RELEASE(m_pShaderProgram);
  if m_uName > 0 then
    ccGLDeleteTexture(m_uName);
  inherited;
end;

procedure CCTexture2D.drawAtPoint(const point: CCPoint);
var
  coordinates, vertices: array [0..7] of GLfloat;
  width, height: GLfloat;
begin
  coordinates[0] := 0.0;     coordinates[1] := m_fMaxT;
  coordinates[2] := m_fMaxS; coordinates[3] := m_fMaxT;
  coordinates[4] := 0.0;     coordinates[5] := 0.0;
  coordinates[6] := m_fMaxS; coordinates[7] := 0.0;

  width := m_uPixelsWide*m_fMaxS;
  height := m_uPixelsHigh*m_fMaxT;

  vertices[0] := point.x;        vertices[1] := point.y;
  vertices[2] := width+ point.x; vertices[3] := point.y;
  vertices[4] := point.x;        vertices[5] := height+point.y;
  vertices[6] := width+ point.x; vertices[7] := height+point.y;

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position or kCCVertexAttribFlag_TexCoords);
  m_pShaderProgram.use();
  m_pShaderProgram.setUniformsForBuiltins();

  ccGLBindTexture2D(m_uName);

  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, @coordinates[0]);

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
end;

procedure CCTexture2D.drawInRect(const rect: CCRect);
var
  coordinates, vertices: array [0..8] of GLfloat;
begin
  coordinates[0] := 0.0;     coordinates[1] := m_fMaxT;
  coordinates[2] := m_fMaxS; coordinates[3] := m_fMaxT;
  coordinates[0] := 0.0;     coordinates[1] := 0.0;
  coordinates[2] := m_fMaxS; coordinates[3] := 0.0;

  vertices[0] := rect.origin.x;                    vertices[1] := rect.origin.y;
  vertices[2] := rect.origin.x + rect.size.width;  vertices[3] := rect.origin.y;
  vertices[4] := rect.origin.x;                    vertices[5] := rect.origin.y + rect.size.height;
  vertices[6] := rect.origin.x + rect.size.width;  vertices[7] := rect.origin.y + rect.size.height;

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position or kCCVertexAttribFlag_TexCoords);
  m_pShaderProgram.use();
  m_pShaderProgram.setUniformsForBuiltins();

  ccGLBindTexture2D(m_uName);

  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, @coordinates[0]);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
end;

procedure CCTexture2D.generateMipmap;
begin
  ccGLBindTexture2D(m_uName);
  glGenerateMipmap(GL_TEXTURE_2D);
  m_bHasMipmaps := True;
end;

function CCTexture2D.getContentSize: CCSize;
var
  ret: CCSize;
begin
  ret.width := m_tContentSize.width/(CCDirector.sharedDirector().getContentScaleFactor());
  ret.height := m_tContentSize.height/(CCDirector.sharedDirector().getContentScaleFactor());
  Result := ret;
end;

function CCTexture2D.getContentSizeInPixels: CCSize;
begin
  Result := m_tContentSize;
end;

function CCTexture2D.getMaxs: GLfloat;
begin
  Result := m_fMaxS;
end;

function CCTexture2D.getMaxT: GLfloat;
begin
  Result := m_fMaxT;
end;

function CCTexture2D.getName: GLuint;
begin
  Result := m_uName;
end;

function CCTexture2D.getPixelFormat: CCTexture2DPixelFormat;
begin
  Result := m_ePixelFormat;
end;

function CCTexture2D.getPixelsHigh: Cardinal;
begin
  Result := m_uPixelsHigh;
end;

function CCTexture2D.getPixelsWide: Cardinal;
begin
  Result := m_uPixelsWide;
end;

function CCTexture2D.getShaderProgram: CCGLProgram;
begin
  Result := m_pShaderProgram;
end;

function CCTexture2D.hasMipmaps: Boolean;
begin
  Result := m_bHasMipmaps;
end;

function CCTexture2D.hasPremultipliedAlpha: Boolean;
begin
  Result := m_bHasPremultipliedAlpha;
end;

function CCTexture2D.initPremultipliedATextureWithImage(image: CCImage;
  width, height: Cardinal): Boolean;
var
  tempData: PByte;
  inPixel32: PCardinal;
  inPixel8: PByte;
  outPixel16: PWord;
  outPixel8: PByte;
  hasAlpha: Boolean;
  imageSize: CCSize;
  pixelFormat: CCTexture2DPixelFormat;
  bpp: Integer;
  length, i: Cardinal;
begin
  tempData := image.getData;
  //inPixel32 := nil;
  //inPixel8 := nil;
  //outPixel16 := nil;
  hasAlpha := image.hasAlpha();
  imageSize := CCSizeMake(image.Width, image.Height);
  bpp := image.BitsPerComponent;

  if hasAlpha then
  begin
    pixelFormat := g_defaultAlphaPixelFormat;
  end else
  begin
    if bpp >= 8 then
    begin
      pixelFormat := kCCTexture2DPixelFormat_RGB888;
    end else
    begin
      pixelFormat := kCCTexture2DPixelFormat_RGB565;
    end;  
  end;

  length := width * height;

  if pixelFormat = kCCTexture2DPixelFormat_RGB565 then
  begin
    if hasAlpha then
    begin
      tempData := AllocMem(height*width*2);
      outPixel16 := PWord(tempData);
      inPixel32 := PCardinal(image.getData());

      for i := 0 to length-1 do
      begin
        outPixel16^ :=
          ((((inPixel32^ shr 0)  and $FF) shr 3) shl 11) or
          ((((inPixel32^ shr 8)  and $FF) shr 2) shl 5) or
          ((((inPixel32^ shr 16) and $FF) shr 3) shl 0);
        Inc(outPixel16);
      end;
    end else
    begin
      tempData := AllocMem(height*width*2);
      outPixel16 := PWord(tempData);
      inPixel8 := PByte(image.getData());

      for i := 0 to length-1 do
      begin
        outPixel16^ :=
          ((((inPixel8^ shr 0)  and $FF) shr 3) shl 11) or
          ((((inPixel8^ shr 8)  and $FF) shr 2) shl 5) or
          ((((inPixel8^ shr 16) and $FF) shr 3) shl 0);
        Inc(inPixel8);
      end;
    end;    
  end else if pixelFormat = kCCTexture2DPixelFormat_RGBA4444 then
  begin
    tempData := AllocMem(height*width*2);
    outPixel16 := PWord(tempData);
    inPixel32 := PCardinal(image.getData());

    for i := 0 to length-1 do
    begin
      outPixel16^ :=
        ((((inPixel32^ shr 0)  and $FF) shr 4) shl 12) or
        ((((inPixel32^ shr 8)  and $FF) shr 4) shl 8) or
        ((((inPixel32^ shr 16) and $FF) shr 4) shl 4) or
        ((((inPixel32^ shr 24) and $FF) shr 4) shl 0);
      Inc(outPixel16);
    end;
  end else if pixelFormat = kCCTexture2DPixelFormat_RGB5A1 then
  begin
    tempData := AllocMem(height*width*2);
    outPixel16 := PWord(tempData);
    inPixel32 := PCardinal(image.getData());

    for i := 0 to length-1 do
    begin
      outPixel16^ :=
        ((((inPixel32^ shr 0)  and $FF) shr 3) shl 11) or
        ((((inPixel32^ shr 8)  and $FF) shr 3) shl 6) or
        ((((inPixel32^ shr 16) and $FF) shr 3) shl 1) or
        ((((inPixel32^ shr 24) and $FF) shr 7) shl 0);
      Inc(outPixel16);
    end;
  end else if pixelFormat = kCCTexture2DPixelFormat_A8 then
  begin
    tempData := AllocMem(height*width);
    outPixel8 := PByte(tempData);
    inPixel32 := PCardinal(image.getData());

    for i := 0 to length-1 do
    begin
      outPixel8^ := ((inPixel32^ shr 24) and $FF);
      Inc(outPixel8);
    end;
  end;

  if hasAlpha and (pixelFormat = kCCTexture2DPixelFormat_RGB888) then
  begin
    inPixel32 := PCardinal(image.getData());
    tempData := AllocMem(height*width*3);
    outPixel8 := PByte(tempData);

    for i := 0 to length-1 do
    begin
      outPixel8^ := (inPixel32^ shr 0) and $FF; Inc(outPixel8);
      outPixel8^ := (inPixel32^ shr 8) and $FF; Inc(outPixel8);
      outPixel8^ := (inPixel32^ shr 16) and $FF; Inc(outPixel8);
    end;  
  end;

  initWithData(tempData, pixelFormat, width, height, imageSize);

  if tempData <> image.getData() then
  begin
    FreeMem(tempData);
  end;

  m_bHasPremultipliedAlpha := image.isPremultipliedAlpha();
  Result := True;
end;

function CCTexture2D.initWithData(data: Pointer;
  pixelFormat: CCTexture2DPixelFormat; pixelswide, pixelsHigh: Cardinal;
  contentSize: CCSize): Boolean;
var
  bitsPerPixel: Cardinal;
  bytesPerRow: Cardinal;
begin
  if pixelFormat = kCCTexture2DPixelFormat_RGB888 then
  begin
    bitsPerPixel := 24;
  end else
  begin
    bitsPerPixel := bitsPerPixelForFormat(pixelFormat);
  end;

  bytesPerRow := pixelswide * bitsPerPixel div 8;

  if bytesPerRow mod 8 = 0 then
  begin
    glPixelStorei(GL_UNPACK_ALIGNMENT, 8);
  end else if bytesPerRow mod 4 = 0 then
  begin
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
  end else if bytesPerRow mod 2 = 0 then
  begin
    glPixelStorei(GL_UNPACK_ALIGNMENT, 2);
  end else
  begin
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  end;     

  
  glGenTextures(1, @m_uName);
  ccGLBindTexture2D(m_uName);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  case pixelFormat of
    kCCTexture2DPixelFormat_RGBA8888:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pixelswide, pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    kCCTexture2DPixelFormat_RGB888:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, pixelswide, pixelsHigh, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
    kCCTexture2DPixelFormat_RGBA4444:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pixelswide, pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
    kCCTexture2DPixelFormat_RGB5A1:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pixelswide, pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
    kCCTexture2DPixelFormat_RGB565:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, pixelswide, pixelsHigh, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
    kCCTexture2DPixelFormat_AI88:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, pixelswide, pixelsHigh, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
    kCCTexture2DPixelFormat_A8:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, pixelswide, pixelsHigh, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
    kCCTexture2DPixelFormat_I8:
      glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, pixelswide, pixelsHigh, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
  else
    begin
      CCAssert(False, 'NSInternalInconsistencyException');
    end;  
  end;

  m_tContentSize := contentSize;
  m_uPixelsWide := pixelswide;
  m_uPixelsHigh := pixelsHigh;
  m_ePixelFormat := pixelFormat;
  m_fMaxS := contentSize.width/pixelsWide;
  m_fMaxT := contentSize.height/pixelsHigh;

  m_bHasPremultipliedAlpha := False;
  m_bHasMipmaps := False;

  setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTexture));

  Result := True;
end;

function CCTexture2D.initWithETCFile(const fileName: string): Boolean;
var
  bRet: Boolean;
  etc: CCTextureETC;
begin
  etc := CCTextureETC.Create;
  bRet := etc.initWithFile(fileName);
  if bRet then
  begin
    m_uName := etc.getName();
    m_fMaxS := 1.0;
    m_fMaxT := 1.0;
    m_uPixelsWide := etc.getWidth();
    m_uPixelsHigh := etc.getHeight();
    m_tContentSize := CCSizeMake(m_uPixelsWide, m_uPixelsHigh);
    m_bHasPremultipliedAlpha := True;
    etc.release();
  end else
  begin
    CCLog('cocos2d: Couldn not load ETC image %s', [fileName]);
  end;

  Result := bRet; 
end;

function CCTexture2D.initWithImage(uiImage: CCImage): Boolean;
var
  imageWidth, imageHeight: Cardinal;
  conf: CCConfiguration;
  maxTextureSize: Cardinal;
begin
  if uiImage = nil then
  begin
    CCLOG('cocos2d: CCTexture2D. Can not create Texture. UIImage is nil', []);
    Result := False;
    Exit;
  end;

  imageWidth := uiImage.Width;
  imageHeight := uiImage.Height;

  conf := CCConfiguration.sharedConfiguration();
  maxTextureSize := conf.getMaxTextureSize();
  if (imageWidth > maxTextureSize) or (imageHeight > maxTextureSize) then
  begin
    CCLOG('cocos2d: WARNING: Image (%d x %d) is bigger than the supported %d x %d', [imageWidth, imageHeight, maxTextureSize, maxTextureSize]);
    Result := False;
    Exit;
  end;

  Result := initPremultipliedATextureWithImage(uiImage, imageWidth, imageHeight);
end;

function CCTexture2D.initWithPVRFile(const pfile: string): Boolean;
var
  bRet: Boolean;
  pvr: CCTexturePVR;
begin
  pvr := CCTexturePVR.Create;
  bRet := pvr.initWithContentsOfFile(pfile);
  if bRet then
  begin
    pvr.setRetainName(True);
    m_uName := pvr.getName();
    m_fMaxS := 1.0;
    m_fMaxT := 1.0;
    m_uPixelsWide := pvr.getWidth();
    m_uPixelsHigh := pvr.getHeight();
    m_tContentSize := CCSizeMake(m_uPixelsWide, m_uPixelsHigh);
    m_bHasPremultipliedAlpha := PVRHaveAlphaPremultiplied_;
    m_ePixelFormat := pvr.getFormat();
    m_bHasMipmaps := pvr.getNumberOfMipmaps() > 1;

    pvr.release();
  end else
  begin
    CCLog('cocos2d: Couldn not load PVR image %s', [pfile]);
  end;
  
  Result := bRet;
end;

function CCTexture2D.initWithString(const text, fontName: string;
  fontSize: Single): Boolean;
begin
  Result := initWithString(text, fontName, fontSize, CCSizeMake(0, 0),
    kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop);
end;

function CCTexture2D.initWithString(const text: string;
  textDefinition: pccFontDefinition): Boolean;
begin
  Result := False;
end;

function CCTexture2D.initWithString(const text, fontName: string; fontSize: Single;
  const dimensions: CCSize; hAlignment: CCTextAlignment;
  vAlignment: CCVerticalTextAlignment): Boolean;
var
  image: CCImage;
  eAlign: ETextAlign;
  bRet: Boolean;
begin
  {$IFDEF IOS}
  {$ENDIF}
  
  if vAlignment = kCCVerticalTextAlignmentTop then
  begin
    if kCCTextAlignmentCenter = hAlignment then
      eAlign := kAlignTop
    else
    begin
      if kCCTextAlignmentLeft = hAlignment then
        eAlign := kAlignTopLeft
      else
        eAlign := kAlignTopRight;
    end;
  end else if kCCVerticalTextAlignmentCenter = vAlignment then
  begin
    if kCCTextAlignmentCenter = hAlignment then
      eAlign := kAlignCenter
    else
    begin
      if kCCTextAlignmentLeft = hAlignment then
        eAlign := kAlignLeft
      else
        eAlign := kAlignRight;
    end;
  end else if kCCVerticalTextAlignmentBottom = vAlignment then
  begin
    if kCCTextAlignmentCenter = hAlignment then
      eAlign := kAlignBottom
    else
    begin
      if kCCTextAlignmentLeft = hAlignment then
        eAlign := kAlignBottomLeft
      else
        eAlign := kAlignBottomRight;
    end;
  end else
  begin
    CCAssert(False, 'Not supported alignment format!');
    Result := False;
    Exit;
  end;


  bRet := False;
  repeat
    image := CCImage.Create();
    if image = nil then
      Break;

    bRet := image.initWithString(text, Round(dimensions.width),
      Round(dimensions.height), eAlign, fontName, Round(fontsize));
    if not bRet then
    begin
      CC_SAFE_RELEASE(image);
      Break;
    end;

    bRet := initWithImage(image);
    CC_SAFE_RELEASE(image);

  until True;

  Result := bRet;
end;

function CCTexture2D.keepData(data: Pointer; length: Cardinal): Pointer;
begin
  Result := data;
end;

class procedure CCTexture2D.PVRImagesHavePremultipliedAlpha(
  haveAlphaPremultiplied: Boolean);
begin

end;

procedure CCTexture2D.releaseData(data: Pointer);
begin
  FreeMem(data);
end;

procedure CCTexture2D.setAliasTexParameters;
begin
  ccGLBindTexture2D(m_uName);
  if not m_bHasMipmaps then
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
  else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
end;

procedure CCTexture2D.setAntiAliasTexParameters;
begin
  ccGLBindTexture2D(m_uName);
  if not m_bHasMipmaps then
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);

  glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
end;

class procedure CCTexture2D.setDefaultAlphaPixelFormat(
  format: CCTexture2DPixelFormat);
begin
  g_defaultAlphaPixelFormat := format;
end;

procedure CCTexture2D.setMaxs(const maxS: GLfloat);
begin
  m_fMaxS := maxS;
end;

procedure CCTexture2D.setMaxT(const maxT: GLfloat);
begin
  m_fMaxT := maxT;
end;

procedure CCTexture2D.setShaderProgram(const pShaderProgram: CCGLProgram);
begin
  CC_SAFE_RETAIN(pShaderProgram);
  CC_SAFE_RELEASE(m_pShaderProgram);
  m_pShaderProgram := pShaderProgram;
end;

procedure CCTexture2D.setTexParameters(texParams: pccTexParams);
begin
  ccGLBindTexture2D(m_uName);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, texParams^.minFilter );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, texParams^.magFilter );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParams^.wrapS );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParams^.wrapT );
end;

function CCTexture2D.stringForFormat: string;
begin
  Result := '';
	case m_ePixelFormat of
		 kCCTexture2DPixelFormat_RGBA8888:  Result :=  'RGBA8888';
		 kCCTexture2DPixelFormat_RGB888:    Result :=  'RGB888';
		 kCCTexture2DPixelFormat_RGB565:    Result :=  'RGB565';
		 kCCTexture2DPixelFormat_RGBA4444:  Result :=  'RGBA4444';
		 kCCTexture2DPixelFormat_RGB5A1:    Result :=  'RGB5A1';
		 kCCTexture2DPixelFormat_AI88:      Result :=  'AI88';
		 kCCTexture2DPixelFormat_A8:        Result :=  'A8';
		 kCCTexture2DPixelFormat_I8:        Result :=  'I8';
		 kCCTexture2DPixelFormat_PVRTC4:    Result :=  'PVRTC4';
		 kCCTexture2DPixelFormat_PVRTC2:    Result :=  'PVRTC2';
  else
    begin
			CCAssert(False , 'unrecognized pixel format');
			CCLOG('stringForFormat: %d, cannot give useful result', [Cardinal(m_ePixelFormat)]);
    end;
  end;
end;

end.
