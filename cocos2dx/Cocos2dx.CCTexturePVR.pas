(****************************************************************************
Copyright (c) 2011 Jirka Fajfr for cocos2d-x
Copyright (c) 2010 cocos2d-x.org

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

unit Cocos2dx.CCTexturePVR;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCTexture2D;

(**
 @brief Determine how many mipmaps can we have.
 Its same as define but it respects namespaces
*)
const CC_PVRMIPMAP_MAX = 16;

type
  CCPVRMipmap = record
    address: PByte;
    len: Cardinal;
  end;

  ccPVRTexturePixelFormatInfo = record
    internalFormat: GLenum;
    format: GLenum;
    _type: GLenum;
    bpp: Cardinal;
    compressed: Boolean;
    alpha: Boolean;
    ccPixelFormat: CCTexture2DPixelFormat;
  end;
  pccPVRTexturePixelFormatInfo = ^ccPVRTexturePixelFormatInfo;

  (** CCTexturePVR

     Object that loads PVR images.

     Supported PVR formats:
        - RGBA8888
        - BGRA8888
        - RGBA4444
        - RGBA5551
        - RGB565
        - A8
        - I8
        - AI88
        - PVRTC 4BPP
        - PVRTC 2BPP

     Limitations:
        Pre-generated mipmaps, such as PVR textures with mipmap levels embedded in file,
        are only supported if all individual sprites are of _square_ size.
        To use mipmaps with non-square textures, instead call CCTexture2D#generateMipmap on the sheet texture itself
        (and to save space, save the PVR sprite sheet without mip maps included).
     @js NA
     @lua NA
    *)
  CCTexturePVR = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(const path: string): CCTexturePVR;
    function initWithContentsOfFile(const path: string): Boolean;
    function getName(): Cardinal;
    function getWidth(): Cardinal;
    function getHeight(): Cardinal;
    function hasAlpha(): Boolean;
    function hasPremultipliedAlpha(): Boolean;
    function getNumberOfMipmaps(): Cardinal;
    function isRetainName(): Boolean;
    function getFormat(): CCTexture2DPixelFormat;
    procedure setRetainName(retainName: Boolean);
  protected
    m_asMipmaps: array [0..CC_PVRMIPMAP_MAX-1] of CCPVRMipmap;
    m_eFormat: CCTexture2DPixelFormat;
    m_uNumberOfMipmaps: Cardinal;
    m_uWidth, m_uHeight: Cardinal;
    m_uName: GLuint;
    m_bHasAlpha: Boolean;
    m_hHashPremultipliedAlpha: Boolean;
    m_bForcePremultipliedAlpha: Boolean;
    m_bRetainName: Boolean;
    m_pPixelFormatInfo: pccPVRTexturePixelFormatInfo;
  private
    //function unpackPVRv2Data(data: PByte; len: Cardinal): Boolean;
    //function unpackPVRv3Data(dataPointer: PByte; dataLength: Cardinal): Boolean;
    //function createGLTexture(): Boolean;
  end;


implementation
uses
  Cocos2dx.CCConfiguration, Cocos2dx.CCFileUtils, Cocos2dx.CCGLStateCache,
  Cocos2dx.CCMacros, Cocos2dx.CCPlatformMacros;

const PVR_TEXTURE_FLAG_TYPE_MASK = $FF;

const PVRTableFormats: array [0..{$IFDEF GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG} 12 {$ELSE} 8 {$ENDIF}] of ccPVRTexturePixelFormatInfo = (
  (internalFormat: GL_RGBA; format: GL_BGRA; _type: GL_UNSIGNED_BYTE; bpp: 32; compressed: False; alpha: True; ccPixelFormat: kCCTexture2DPixelFormat_RGBA8888),
  (internalFormat: GL_RGBA; format: GL_RGBA; _type: GL_UNSIGNED_BYTE; bpp: 32; compressed: False; alpha: True; ccPixelFormat: kCCTexture2DPixelFormat_RGBA8888),
  (internalFormat: GL_RGBA; format: GL_RGBA; _type: GL_UNSIGNED_SHORT_4_4_4_4; bpp: 16; compressed: False; alpha: True; ccPixelFormat: kCCTexture2DPixelFormat_RGBA4444),
  (internalFormat: GL_RGBA; format: GL_RGBA; _type: GL_UNSIGNED_SHORT_5_5_5_1; bpp: 16; compressed: False; alpha: True; ccPixelFormat: kCCTexture2dPixelFormat_RGB5A1),
  (internalFormat: GL_RGB; format: GL_RGB; _type: GL_UNSIGNED_SHORT_5_6_5; bpp: 16; compressed: False; alpha: False; ccPixelFormat: kCCTexture2DPixelFormat_RGB565),
  (internalFormat: GL_RGB; format: GL_RGB; _type: GL_UNSIGNED_BYTE; bpp: 24; compressed: False; alpha: False; ccPixelFormat: kCCTexture2DPixelFormat_RGB888),
  (internalFormat: GL_ALPHA; format: GL_ALPHA; _type: GL_UNSIGNED_BYTE; bpp: 8; compressed: False; alpha: False; ccPixelFormat: kCCTexture2DPixelFormat_A8),
  (internalFormat: GL_LUMINANCE; format: GL_LUMINANCE; _type: GL_UNSIGNED_BYTE; bpp: 8; compressed: False; alpha: False; ccPixelFormat: kCCTexture2DPixelFormat_I8),
  (internalFormat: GL_LUMINANCE_ALPHA; format: GL_LUMINANCE_ALPHA; _type: GL_UNSIGNED_BYTE; bpp: 16; compressed: False; alpha: True; ccPixelFormat: kCCTexture2DPixelFormat_AI88)
  {$IFDEF GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG}
  ,
  (internalFormat: GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG; format: $FFFFFFFF; _type: $FFFFFFFF; bpp: 2; compressed: True; alpha: False; ccPixelFormat: kCCTexture2DPixelFormat_PVRTC2),
  (internalFormat: GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG; format: $FFFFFFFF; _type: $FFFFFFFF; bpp: 2; compressed: True; alpha: True; ccPixelFormat: kCCTexture2DPixelFormat_PVRTC2),
  (internalFormat: GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG; format: $FFFFFFFF; _type: $FFFFFFFF; bpp: 4; compressed: True; alpha: False; ccPixelFormat: kCCTexture2DPixelFormat_PVRTC4),
  (internalFormat: GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG; format: $FFFFFFFF; _type: $FFFFFFFF; bpp: 4; compressed: True; alpha: True; ccPixelFormat: kCCTexture2DPixelFormat_PVRTC4)
  {$ENDIF}
);

const    kPVR2TextureFlagMipmap         = (1 shl 8);        // has mip map levels
const    kPVR2TextureFlagTwiddle        = (1 shl 9);        // is twiddled
const    kPVR2TextureFlagBumpmap        = (1 shl 10);       // has normals encoded for a bump map
const    kPVR2TextureFlagTiling         = (1 shl 11);       // is bordered for tiled pvr
const    kPVR2TextureFlagCubemap        = (1 shl 12);       // is a cubemap/skybox
const    kPVR2TextureFlagFalseMipCol    = (1 shl 13);       // are there false colored MIP levels
const    kPVR2TextureFlagVolume         = (1 shl 14);       // is this a volume texture
const    kPVR2TextureFlagAlpha          = (1 shl 15);       // v2.1 is there transparency info in the texture
const    kPVR2TextureFlagVerticalFlip   = (1 shl 16);       // v2.1 is the texture vertically flipped


const kPVR3TextureFlagPremultipliedAlpha = (1 shl 1);

const gPVRTexIdentifier: string = 'PVR!';


// v3
//* supported predefined formats */
const kPVR3TexturePixelFormat_PVRTC_2BPP_RGB  = 0;
const kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA = 1;
const kPVR3TexturePixelFormat_PVRTC_4BPP_RGB  = 2;
const kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA = 3;

//* supported channel type formats */
const kPVR3TexturePixelFormat_BGRA_8888 = $0808080861726762;
const kPVR3TexturePixelFormat_RGBA_8888 = $0808080861626772;
const kPVR3TexturePixelFormat_RGBA_4444 = $0404040461626772;
const kPVR3TexturePixelFormat_RGBA_5551 = $0105050561626772;
const kPVR3TexturePixelFormat_RGB_565   = $0005060500626772;
const kPVR3TexturePixelFormat_RGB_888   = $0008080800626772;
const kPVR3TexturePixelFormat_A_8       = $0000000800000061;
const kPVR3TexturePixelFormat_L_8       = $000000080000006c;
const kPVR3TexturePixelFormat_LA_88     = $000008080000616c;


type
  ccPVR2TexturePixelFormat = (
      kPVR2TexturePixelFormat_RGBA_4444= $10,
      kPVR2TexturePixelFormat_RGBA_5551,
      kPVR2TexturePixelFormat_RGBA_8888,
      kPVR2TexturePixelFormat_RGB_565,
      kPVR2TexturePixelFormat_RGB_555,				// unsupported
      kPVR2TexturePixelFormat_RGB_888,
      kPVR2TexturePixelFormat_I_8,
      kPVR2TexturePixelFormat_AI_88,
      kPVR2TexturePixelFormat_PVRTC_2BPP_RGBA,
      kPVR2TexturePixelFormat_PVRTC_4BPP_RGBA,
      kPVR2TexturePixelFormat_BGRA_8888,
      kPVR2TexturePixelFormat_A_8
  );

  _pixel_formathash = record
    pixelFormat: Int64;
    pixelFormatInfo: pccPVRTexturePixelFormatInfo;
  end;

const PVR2_MAX_TABLE_ELEMENTS = {$IFDEF GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG} 11; {$ELSE} 9; {$ENDIF}

const v2_pixel_formathash: array [0..PVR2_MAX_TABLE_ELEMENTS-1] of _pixel_formathash = (
  (pixelFormat: Ord(kPVR2TexturePixelFormat_BGRA_8888); pixelFormatInfo: @PVRTableFormats[0]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_BGRA_8888); pixelFormatInfo: @PVRTableFormats[1]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGBA_4444); pixelFormatInfo: @PVRTableFormats[2]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGBA_5551); pixelFormatInfo: @PVRTableFormats[3]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGB_565); pixelFormatInfo: @PVRTableFormats[4]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGB_888); pixelFormatInfo: @PVRTableFormats[5]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_A_8); pixelFormatInfo: @PVRTableFormats[6]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_I_8); pixelFormatInfo: @PVRTableFormats[7]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_AI_88); pixelFormatInfo: @PVRTableFormats[8])
  {$IFDEF GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG}
  ,
  (pixelFormat: Ord(kPVR2TexturePixelFormat_PVRTC_2BPP_RGBA); pixelFormatInfo: @PVRTableFormats[10]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_PVRTC_4BPP_RGBA); pixelFormatInfo: @PVRTableFormats[12])
  {$ENDIF}
);

const PVR3_MAX_TABLE_ELEMENTS = {$IFDEF GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG} 13; {$ELSE} 9; {$ENDIF}

const v3_pixel_formathash: array [0..PVR3_MAX_TABLE_ELEMENTS-1] of _pixel_formathash = (
  (pixelFormat: Ord(kPVR2TexturePixelFormat_BGRA_8888); pixelFormatInfo: @PVRTableFormats[0]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_BGRA_8888); pixelFormatInfo: @PVRTableFormats[1]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGBA_4444); pixelFormatInfo: @PVRTableFormats[2]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGBA_5551); pixelFormatInfo: @PVRTableFormats[3]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGB_565); pixelFormatInfo: @PVRTableFormats[4]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_RGB_888); pixelFormatInfo: @PVRTableFormats[5]),
  (pixelFormat: Ord(kPVR2TexturePixelFormat_A_8); pixelFormatInfo: @PVRTableFormats[6]),
  (pixelFormat: kPVR3TexturePixelFormat_L_8; pixelFormatInfo: @PVRTableFormats[7]),
  (pixelFormat: kPVR3TexturePixelFormat_LA_88; pixelFormatInfo: @PVRTableFormats[8])
  {$IFDEF GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG}
  ,
  (pixelFormat: kPVR3TexturePixelFormat_PVRTC_2BPP_RGB; pixelFormatInfo: @PVRTableFormats[9]),
  (pixelFormat: kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA; pixelFormatInfo: @PVRTableFormats[10]),
  (pixelFormat: kPVR3TexturePixelFormat_PVRTC_4BPP_RGB; pixelFormatInfo: @PVRTableFormats[11]),
  (pixelFormat: kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA; pixelFormatInfo: @PVRTableFormats[12])
  {$ENDIF}
);

type
  ccPVRv2TexHeader = record
    headerLength: Cardinal;
    height: Cardinal;
    width: Cardinal;
    numMipmaps: Cardinal;
    flags: Cardinal;
    dataLength: Cardinal;
    bpp: Cardinal;
    bitmaskRed: Cardinal;
    bitmaskGreen: Cardinal;
    bitmaskBlue: Cardinal;
    bitmaskAlpha: Cardinal;
    pvrTag: Cardinal;
    numSurfs: Cardinal;
  end;

{ CCTexturePVR }

class function CCTexturePVR._create(const path: string): CCTexturePVR;
begin
  Result := nil;
end;

constructor CCTexturePVR.Create;
begin

end;

{function CCTexturePVR.createGLTexture: Boolean;
begin
  Result := False;
end;}

destructor CCTexturePVR.Destroy;
begin

  inherited;
end;

function CCTexturePVR.getHeight: Cardinal;
begin
  Result := 0;
end;

function CCTexturePVR.getName: Cardinal;
begin
  Result := 0;
end;

function CCTexturePVR.getNumberOfMipmaps: Cardinal;
begin
  Result := 0;
end;

function CCTexturePVR.getWidth: Cardinal;
begin
  Result := 0;
end;

function CCTexturePVR.hasAlpha: Boolean;
begin
  Result := False;
end;

function CCTexturePVR.hasPremultipliedAlpha: Boolean;
begin
  Result := False;
end;

function CCTexturePVR.initWithContentsOfFile(const path: string): Boolean;
begin
  Result := False;
end;

function CCTexturePVR.isRetainName: Boolean;
begin
  Result := False;
end;

procedure CCTexturePVR.setRetainName(retainName: Boolean);
begin

end;

{function CCTexturePVR.unpackPVRv2Data(data: PByte; len: Cardinal): Boolean;
begin
  Result := False;
end;}

{function CCTexturePVR.unpackPVRv3Data(dataPointer: PByte;
  dataLength: Cardinal): Boolean;
begin
  Result := False;
end;}

function CCTexturePVR.getFormat: CCTexture2DPixelFormat;
begin
  Result := m_eFormat;
end;

end.
