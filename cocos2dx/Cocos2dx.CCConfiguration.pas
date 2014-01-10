(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2010      Ricardo Quesada

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

unit Cocos2dx.CCConfiguration;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils,
  Cocos2dx.CCObject, Cocos2dx.CCString, Cocos2dx.CCDictionary;

type
  ccConfigurationType = (
    ConfigurationError,
    ConfigurationString,
    ConfigurationInt,
    ConfigurationDouble,
    ConfigurationBoolean
  );

  CCConfiguration = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedConfiguration(): CCConfiguration;
    class procedure purgeConfiguration();

    //** OpenGL Max texture size. */
    function getMaxTextureSize(): Integer;

    //** OpenGL Max Modelview Stack Depth. */
    function getMaxModelviewStackDepth(): Integer;
    (** returns the maximum texture units
     @since v2.0.0
     *)
    function getMaxTextureUnits(): Integer;

    (** Whether or not the GPU supports NPOT (Non Power Of Two) textures.
     OpenGL ES 2.0 already supports NPOT (iOS).
     
     @since v0.99.2
     *)
    function supportsNPOT(): Boolean;

    //** Whether or not PVR Texture Compressed is supported */
    function supportsPVRTC(): Boolean;

    (** Whether or not BGRA8888 textures are supported.
     @since v0.99.2
     *)
    function supportsBGRA8888(): Boolean;

    (** Whether or not glDiscardFramebufferEXT is supported
     @since v0.99.2
     *)
    function supportsDiscardFrameBuffer(): Boolean;

    (** Whether or not shareable VAOs are supported.
     @since v2.0.0
     *)
    function supportsShaderableVAO(): Boolean;
    function supportsShareableVAO(): Boolean;
    function getCString(const key: string; const default_value: string = ''): string;
    function getBool(const key: string; default_value: Boolean = False): Boolean;
    function getNumber(const key: string; default_value: Double): Double;
    function getObject(const key: string): CCObject;
    procedure setObject(const key: string; value: CCObject);
    procedure dumpInfo();
    procedure gatherGPUInfo();

    (** Loads a config file. If the keys are already present, then they are going to be replaced.
      Otherwise the new keys are added. *)
    procedure loadConfigFile(const filename: string);
    {$ifdef IOS}
    function checkForGLExtension(const searchName: string): Boolean;
    {$else}
    function checkForGLExtension(const searchName: AnsiString): Boolean;
    {$endif}
    function init(): Boolean;
  protected
    m_nmaxTextureSize: GLuint;
    m_nMaxModelviewStackDepth: GLint;
    m_bSupportsPVRTC: Boolean;
    m_bSupportsNPOT: Boolean;
    m_bSupportsBGRA8888: Boolean;
    m_bSupportsDiscardFramebuffer: Boolean;
    m_bSupportsShareableVAO: Boolean;
    m_nMaxSamplesAllowed: GLint;
    m_nMaxTextureUnits: GLint;
    m_pValueDict: CCDictionary;
    {$ifdef IOS}
    m_pGlExtensions: PGLubyte;
    {$else}
    m_pGlExtensions: PGLchar;
    {$endif}
  end;

implementation
uses
  StrUtils, tdHashChain, Cocos2dx.CCDirector, Cocos2dx.CCPlatformMacros, Cocos2dx.CCCommon,
  Cocos2dx.CCInteger, Cocos2dx.CCBool, Cocos2dx.CCFileUtils, cocos2d, Cocos2dx.CCDouble;

{ CCConfiguration }

var s_gSharedConfiguration: CCConfiguration = nil;

{$ifdef IOS}
function CCConfiguration.checkForGLExtension(
  const searchName: string): Boolean;
var
  bRet: Boolean;
  ExtList: string;
begin
  bRet := False;
  ExtList := string(MarshaledAString(m_pGlExtensions));
  if (m_pGlExtensions <> nil) and (Pos(searchName, ExtList) > 0) then
  begin
    bRet := True;
  end;
  Result := bRet;
end;
{$else}
function CCConfiguration.checkForGLExtension(
  const searchName: AnsiString): Boolean;
var
  bRet: Boolean;
  kSearchName: array [0..255] of AnsiChar;
begin
  StrPCopy(kSearchName, searchName);

  bRet := False;
  if (m_pGlExtensions <> nil) and (StrPos(m_pGlExtensions, kSearchName) <> nil) then
  begin
    bRet := True;
  end;
  Result := bRet;
end;
{$endif}

constructor CCConfiguration.Create;
begin
  inherited Create();
  {m_nmaxTextureSize := 0;
  m_nMaxModelviewStackDepth := 0;
  m_nMaxTextureUnits := 0;
  m_bSupportsPVRTC := False;
  m_bSupportsNPOT := False;
  m_bSupportsBGRA8888 := False;
  m_bSupportsShareableVAO := False;
  m_bSupportsDiscardFramebuffer := False;
  m_nMaxSamplesAllowed := 0;
  m_pGlExtensions := nil;}
end;

destructor CCConfiguration.Destroy;
begin
  m_pValueDict.release();
  inherited;
end;

procedure CCConfiguration.dumpInfo;
begin

end;

procedure CCConfiguration.gatherGPUInfo;
begin
  {$IFDEF IOS}
  {$WARNINGS OFF}
  m_pValueDict.setObject(CCString._create(MarshaledAString(glGetString(GL_VENDOR))), 'gl.vendor');
  m_pValueDict.setObject(CCString._create(MarshaledAString(glGetString(GL_RENDERER))), 'gl.renderer');
  m_pValueDict.setObject(CCString._create(MarshaledAString(glGetString(GL_VERSION))), 'gl.version');
  {$WARNINGS ON}
  {$ELSE}
  m_pValueDict.setObject(CCString._create(glGetString(GL_VENDOR)), 'gl.vendor');
  m_pValueDict.setObject(CCString._create(glGetString(GL_RENDERER)), 'gl.renderer');
  m_pValueDict.setObject(CCString._create(glGetString(GL_VERSION)), 'gl.version');
  {$ENDIF}
  m_pGlExtensions := glGetString(GL_EXTENSIONS);

  glGetIntegerv(GL_MAX_TEXTURE_SIZE, @m_nMaxTextureSize);
  m_pValueDict.setObject(CCInteger._create(m_nmaxTextureSize), 'gl.max_texture_size');

  glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, @m_nMaxTextureUnits);
  m_pValueDict.setObject(CCInteger._create(m_nMaxTextureUnits), 'gl.max_texture_units');

  {$IFDEF IOS}
  glGetIntegerv(GL_MAX_SAMPLES_APPLE, @m_nMaxSamplesAllowed);
  m_pValueDict.setObject(CCInteger._create(m_nMaxSamplesAllowed), 'gl.max_samples_allowed');
  {$ENDIF}

  m_bSupportsPVRTC := checkForGLExtension('GL_IMG_texture_compression_pvrtc');
  m_pValueDict.setObject(CCBool._create(m_bSupportsPVRTC), 'gl.supports_PVRTC');

  m_bSupportsNPOT := True;
  m_pValueDict.setObject(CCBool._create(m_bSupportsNPOT), 'gl.supports_NPOT');

  m_bSupportsBGRA8888 := checkForGLExtension('GL_IMG_texture_format_BGRA888');
  m_pValueDict.setObject(CCBool._create(m_bSupportsBGRA8888), 'gl.supports_BGRA8888');

  m_bSupportsDiscardFramebuffer := checkForGLExtension('GL_EXT_discard_framebuffer');
  m_pValueDict.setObject(CCBool._create(m_bSupportsDiscardFramebuffer), 'gl.supports_discard_framebuffer');

  m_bSupportsShareableVAO := checkForGLExtension('vertex_array_object');
  m_pValueDict.setObject(CCBool._create(m_bSupportsShareableVAO), 'gl.supports_vertex_array_object');
end;

function CCConfiguration.getBool(const key: string;
  default_value: Boolean): Boolean;
var
  ret: CCObject;
begin
  ret := m_pValueDict.objectForKey(key);
  if ret <> nil then
  begin
    if ret is CCBool then
    begin
      Result := CCBool(ret).getValue();
      Exit;
    end;  
  end;
  Result := default_value;
end;

function CCConfiguration.getCString(const key,
  default_value: string): string;
var
  ret: CCObject;
begin
  ret := m_pValueDict.objectForKey(key);
  if ret <> nil then
  begin
    if ret is CCString then
    begin
      Result := CCString(ret).m_sString;
      Exit;
    end;  
  end;
  Result := default_value;
end;

function CCConfiguration.getMaxModelviewStackDepth: Integer;
begin
  Result := m_nMaxModelviewStackDepth;
end;

function CCConfiguration.getMaxTextureSize: Integer;
begin
  Result := m_nmaxTextureSize;
end;

function CCConfiguration.getMaxTextureUnits: Integer;
begin
  Result := m_nMaxTextureUnits;
end;

function CCConfiguration.getNumber(const key: string;
  default_value: Double): Double;
var
  ret: CCObject;
begin
  ret := m_pValueDict.objectForKey(key);
  if ret <> nil then
  begin
    if ret is CCDouble then
    begin
      Result := CCDouble(ret).getValue();
      Exit;
    end;  
  end;
  Result := default_value;
end;

function CCConfiguration.getObject(const key: string): CCObject;
begin
  Result := m_pValueDict.objectForKey(key);
end;

function CCConfiguration.init: Boolean;
begin
  m_pValueDict := CCDictionary._create();
  m_pValueDict.retain();
  m_pValueDict.setObject(CCString._create(cocos2dVersion()), 'cocos2d.x.version');
{$IFDEF CC_ENABLE_PROFILERS}
  m_pValueDict.setObject(CCBool._create(True), 'cocos2d.x.compiled_with_profiler');
{$ELSE}
  m_pValueDict.setObject(CCBool._create(False), 'cocos2d.x.compiled_with_profiler');
{$ENDIF}
{$IFDEF CC_ENABLE_GL_STATE_CACHE}
  m_pValueDict.setObject(CCBool._create(False), 'cocos2d.x.compiled_with_gl_state_cache');
{$ELSE}
  m_pValueDict.setObject(CCBool._create(True), 'cocos2d.x.compiled_with_gl_state_cache');
{$ENDIF}
  Result := True;
end;

procedure CCConfiguration.loadConfigFile(const filename: string);
var
  dict, data_dict: CCDictionary;
  metadata_ok: Boolean;
  metadata, data: CCObject;
  format_o: CCObject;
  format: Integer;
  Element: CCDictElement;
begin
  metadata_ok := False;
  dict := CCDictionary.createWithContentsOfFile(filename);

  metadata := dict.objectForKey('metadata');
  if (metadata <> nil) and (metadata is CCDictionary) then
  begin
    format_o := CCDictionary(metadata).objectForkey('format');
    if (format_o <> nil) and (format_o is CCString) then
    begin
      format := CCString(format_o).intValue();
      if format = 1 then
        metadata_ok := True;
    end;  
  end;

  if not metadata_ok then
  begin
    CCLog('Invalid config format for file: %s', [filename]);
    Exit;
  end;

  data := dict.objectForKey('data');
  if (data = nil) and not (data is CCDictionary) then
  begin
    CCLog('Expected "data" dict, but not found. Config file: %s', [filename]);
    Exit;
  end;

  data_dict := CCDictionary(data);
  Element := data_dict.First();
  while Element <> nil do
  begin
    if m_pValueDict.objectForKey(Element.strKey) = nil then
      m_pValueDict.setObject(CCObject(Element.pObj), Element.strKey)
    else
      CCLog('Key already present. Ignoring %s', [Element.strKey]);
  end;

  CCDirector.sharedDirector().setDefaultValues();
end;

class procedure CCConfiguration.purgeConfiguration;
begin
  CC_SAFE_RELEASE_NULL(CCObject(s_gSharedConfiguration));
end;

procedure CCConfiguration.setObject(const key: string; value: CCObject);
begin
  m_pValueDict.setObject(value, key);
end;

class function CCConfiguration.sharedConfiguration: CCConfiguration;
begin
  if s_gSharedConfiguration = nil then
  begin
    s_gSharedConfiguration := CCConfiguration.Create();
    s_gSharedConfiguration.init();
  end;
  Result := s_gSharedConfiguration;
end;

function CCConfiguration.supportsBGRA8888: Boolean;
begin
  Result := m_bSupportsBGRA8888;
end;

function CCConfiguration.supportsDiscardFrameBuffer: Boolean;
begin
  Result := m_bSupportsDiscardFramebuffer;
end;

function CCConfiguration.supportsNPOT: Boolean;
begin
  Result := m_bSupportsNPOT;
end;

function CCConfiguration.supportsPVRTC: Boolean;
begin
  Result := m_bSupportsPVRTC;
end;

function CCConfiguration.supportsShaderableVAO: Boolean;
begin
  Result := m_bSupportsShareableVAO;
end;

function CCConfiguration.supportsShareableVAO: Boolean;
begin
  Result := m_bSupportsShareableVAO;
end;

end.
