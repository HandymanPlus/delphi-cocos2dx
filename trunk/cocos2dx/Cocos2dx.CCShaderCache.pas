(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Ricardo Quesada
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

unit Cocos2dx.CCShaderCache;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCDictionary, Cocos2dx.CCGLProgram;

type
  CCShaderCache = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedShaderCache(): CCShaderCache;
    class procedure purgeSharedShaderCache();
    procedure loadDefaultShaders();
    procedure reloadDefaultShaders();
    function programForKey(const key: string): CCGLProgram;
    procedure addProgram(pro: CCGLProgram; const key: string);
  private
    m_pPrograms: CCDictionary;
    function init(): Boolean;
    procedure loadDefaultShader(p: CCGLProgram; _type: Integer);
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCShaders, Cocos2dx.CCMacros, Cocos2dx.CCCommon;

{ CCShaderCache }

const kCCShaderType_PositionTextureColor           =      0;
const kCCShaderType_PositionTextureColorAlphaTest  =      1;
const kCCShaderType_PositionColor                  =      2;
const kCCShaderType_PositionTexture                =      3;
const kCCShaderType_PositionTexture_uColor         =      4;
const kCCShaderType_PositionTextureA8Color         =      5;
const kCCShaderType_Position_uColor                =      6;
const kCCShaderType_PositionLengthTexureColor      =      7;
const kCCShaderType_MAX                            =      8;

var _sharedShaderCache: CCShaderCache = nil;

procedure CCShaderCache.addProgram(pro: CCGLProgram; const key: string);
begin
  m_pPrograms.setObject(pro, key);
end;

constructor CCShaderCache.Create;
begin
  inherited Create();
  m_pPrograms := nil;
end;

destructor CCShaderCache.Destroy;
begin
  m_pPrograms.release();
  inherited;
end;

function CCShaderCache.init: Boolean;
begin
  m_pPrograms := CCDictionary.Create;
  loadDefaultShaders();
  Result := True;
end;

procedure CCShaderCache.loadDefaultShader(p: CCGLProgram;
  _type: Integer);
begin
  case _type of
    kCCShaderType_PositionTextureColor:
      begin
        p.initWithVertexShaderByteArray(ccPositionTextureColor_vert, ccPositionTextureColor_frag);

        p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p.addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
        p.addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
      end;
    kCCShaderType_PositionTextureColorAlphaTest:
      begin
        p.initWithVertexShaderByteArray(ccPositionTextureColor_vert, ccPositionTextureColorAlphaTest_frag);

        p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p.addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
        p.addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
      end;
    kCCShaderType_PositionColor:
      begin
        p.initWithVertexShaderByteArray(ccPositionColor_vert ,ccPositionColor_frag);

        p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p.addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
      end;
    kCCShaderType_PositionTexture:
      begin
        p.initWithVertexShaderByteArray(ccPositionTexture_vert ,ccPositionTexture_frag);

        p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p.addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
      end;
    kCCShaderType_PositionTexture_uColor:
      begin
        p.initWithVertexShaderByteArray(ccPositionTexture_uColor_vert, ccPositionTexture_uColor_frag);

        p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p.addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
      end;
    kCCShaderType_PositionTextureA8Color:
      begin
        p.initWithVertexShaderByteArray(ccPositionTextureA8Color_vert, ccPositionTextureA8Color_frag);

        p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p.addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
        p.addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
      end;
    kCCShaderType_Position_uColor:
      begin
        p.initWithVertexShaderByteArray(ccPosition_uColor_vert, ccPosition_uColor_frag);

        p.addAttribute('aVertex', kCCVertexAttrib_Position);
      end;
    kCCShaderType_PositionLengthTexureColor:
      begin
        p.initWithVertexShaderByteArray(ccPositionColorLengthTexture_vert, ccPositionColorLengthTexture_frag);

        p.addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        p.addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
        p.addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
      end;
  else
    CCLOG('cocos2d: error shader type', []);
    Exit;
  end;

  p.link();
  p.updateUniforms();

  CHECK_GL_ERROR_DEBUG();
end;

procedure CCShaderCache.loadDefaultShaders;
var
  p: CCGLProgram;
begin
  // Position Texture Color shader
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_PositionTextureColor);
  m_pPrograms.setObject(p, kCCShader_PositionTextureColor);
  p.release();

  // Position Texture Color alpha test
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_PositionTextureColorAlphaTest);
  m_pPrograms.setObject(p, kCCShader_PositionTextureColorAlphaTest);
  p.release();

  // Position, Color shader
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_PositionColor);
  m_pPrograms.setObject(p, kCCShader_PositionColor);
  p.release();

  // Position Texture shader
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_PositionTexture);
  m_pPrograms.setObject(p, kCCShader_PositionTexture);
  p.release();

  // Position, Texture attribs, 1 Color as uniform shader
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_PositionTexture_uColor);
  m_pPrograms.setObject(p, kCCShader_PositionTexture_uColor);
  p.release();

  // Position Texture A8 Color shader
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_PositionTextureA8Color);
  m_pPrograms.setObject(p, kCCShader_PositionTextureA8Color);
  p.release();

  // Position and 1 color passed as a uniform (to simulate glColor4ub )
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_Position_uColor);
  m_pPrograms.setObject(p, kCCShader_Position_uColor);
  p.release();

  // Position, Legth(TexCoords, Color (used by Draw Node basically )
  p := CCGLProgram.Create;
  loadDefaultShader(p, kCCShaderType_PositionLengthTexureColor);
  m_pPrograms.setObject(p, kCCShader_PositionLengthTexureColor);
  p.release();
end;

function CCShaderCache.programForKey(const key: string): CCGLProgram;
begin
  Result := CCGLProgram(m_pPrograms.objectForKey(key));
end;

class procedure CCShaderCache.purgeSharedShaderCache;
begin
  CC_SAFE_RELEASE_NULL(CCObject(_sharedShaderCache));
end;

procedure CCShaderCache.reloadDefaultShaders;
var
  p: CCGLProgram;
begin
  // reset all programs and reload them

  // Position Texture Color shader
  p := programForKey(kCCShader_PositionTextureColor);
  p.reset();
  loadDefaultShader(p, kCCShaderType_PositionTextureColor);

  // Position Texture Color alpha test
  p := programForKey(kCCShader_PositionTextureColorAlphaTest);
  p.reset();
  loadDefaultShader(p, kCCShaderType_PositionTextureColorAlphaTest);

  //
  // Position, Color shader
  //
  p := programForKey(kCCShader_PositionColor);
  p.reset();
  loadDefaultShader(p, kCCShaderType_PositionColor);

  //
  // Position Texture shader
  //
  p := programForKey(kCCShader_PositionTexture);
  p.reset();
  loadDefaultShader(p, kCCShaderType_PositionTexture);

  //
  // Position, Texture attribs, 1 Color as uniform shader
  //
  p := programForKey(kCCShader_PositionTexture_uColor);
  p.reset();
  loadDefaultShader(p, kCCShaderType_PositionTexture_uColor);

  //
  // Position Texture A8 Color shader
  //
  p := programForKey(kCCShader_PositionTextureA8Color);
  p.reset();
  loadDefaultShader(p, kCCShaderType_PositionTextureA8Color);

  //
  // Position and 1 color passed as a uniform (to simulate glColor4ub )
  //
  p := programForKey(kCCShader_Position_uColor);
  p.reset();
  loadDefaultShader(p, kCCShaderType_Position_uColor);
  //
	// Position, Legth(TexCoords, Color (used by Draw Node basically )
	//
  p := programForKey(kCCShader_PositionLengthTexureColor);
  p.reset();
  loadDefaultShader(p, kCCShaderType_PositionLengthTexureColor);
end;

class function CCShaderCache.sharedShaderCache: CCShaderCache;
begin
  if _sharedShaderCache = nil then
  begin
    _sharedShaderCache := CCShaderCache.Create;
    if not _sharedShaderCache.init() then
      CC_SAFE_DELETE(_sharedShaderCache);
  end;
  Result := _sharedShaderCache;
end;

end.
