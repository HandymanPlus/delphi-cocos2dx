(****************************************************************************
Copyright 2012 cocos2d-x.org
Copyright 2011 Jeff Lamarche
Copyright 2012 Goffredo Marocchi
Copyright 2012 Ricardo Quesada

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

unit Cocos2dx.CCGLProgram;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils,
  Cocos2dx.CCObject, tdHashChain;

const kCCVertexAttrib_Position  =  0;
const kCCVertexAttrib_Color     =  1;
const kCCVertexAttrib_TexCoords =  2;
const kCCVertexAttrib_MAX       =  3;

const kCCUniformPMatrix       =  0;
const kCCUniformMVMatrix      =  1;
const	kCCUniformMVPMatrix     =  2;
const	kCCUniformTime          =  3;
const	kCCUniformSinTime       =  4;
const	kCCUniformCosTime       =  5;
const	kCCUniformRandom01      =  6;
const kCCUniformSampler       =  7;
const kCCUniform_MAX          =  8;

const kCCShader_PositionTextureColor          =   'ShaderPositionTextureColor';
const kCCShader_PositionTextureColorAlphaTest =   'ShaderPositionTextureColorAlphaTest';
const kCCShader_PositionColor                 =   'ShaderPositionColor';
const kCCShader_PositionTexture               =   'ShaderPositionTexture';
const kCCShader_PositionTexture_uColor        =   'ShaderPositionTexture_uColor';
const kCCShader_PositionTextureA8Color        =   'ShaderPositionTextureA8Color';
const kCCShader_Position_uColor               =   'ShaderPosition_uColor';
const kCCShader_PositionLengthTexureColor     =   'ShaderPositionLengthTextureColor';

// uniform names
const kCCUniformPMatrix_s			 =	'CC_PMatrix';
const kCCUniformMVMatrix_s		 =	'CC_MVMatrix';
const kCCUniformMVPMatrix_s		 =	'CC_MVPMatrix';
const kCCUniformTime_s				 =  'CC_Time';
const kCCUniformSinTime_s			 =	'CC_SinTime';
const kCCUniformCosTime_s			 =	'CC_CosTime';
const kCCUniformRandom01_s		 =	'CC_Random01';
const kCCUniformSampler_s			 =	'CC_Texture0';
const kCCUniformAlphaTestValue =	'CC_alpha_value';

// Attribute names
const kCCAttributeNameColor      =     'a_color';
const kCCAttributeNamePosition   =     'a_position';
const kCCAttributeNameTexCoord   =     'a_texCoord';

type
  GLInfoFunction = procedure (pro: GLuint; pname: GLenum; params: PGLint);
  GLLogFunction  = procedure (pro: GLuint; bufsize: GLsizei; len: PGLsizei; infolog: PGLchar);

  ptHashUniformEntry = ^tHashUniformEntry;
  tHashUniformEntry = record
    value: PGLvoid;
    location: Cardinal;
  end;

  CCGLProgram = class(CCObject)
  private
    m_uProgram: GLuint;
    m_uVertShader: GLuint;
    m_uFragShader: GLuint;
    m_bUsesTime: Boolean;
    m_uUniforms: array [0..kCCUniform_MAX-1] of GLint;
    m_pHashForUniforms: ptHashUniformEntry;
    m_pHashChain: TtdHashTableChain;
  public
    constructor Create();
    destructor Destroy(); override;

    (** Initializes the CCGLProgram with a vertex and fragment with bytes array
     * @js  initWithString
     * @lua NA
     *)
    function initWithVertexShaderByteArray(const vShaderByteArray: PGLchar; const fShaderByteArray: PGLchar): Boolean;

    (** Initializes the CCGLProgram with a vertex and fragment with contents of filenames
     * @js  init
     * @lua NA
     *)
    function initWithVertexShaderFilename(const vShaderFilename, fShaderFilename: string): Boolean;

    (**  It will add a new attribute to the shader
     * @lua NA
     *)
    procedure addAttribute(const attributeName: PGLchar; index: GLuint);

    (** links the glProgram 
     * @lua NA
     *)
    function link(): Boolean;

    (** it will call glUseProgram()
     * @lua NA
     *)
    procedure use();

    (** calls retrieves the named uniform location for this shader program. 
     * @lua NA
     *)
    function getUniformLocationForName(const name: PGLchar): GLint;

    (** It will create 4 uniforms:
        - kCCUniformPMatrix
        - kCCUniformMVMatrix
        - kCCUniformMVPMatrix
        - kCCUniformSampler

     And it will bind "kCCUniformSampler" to 0
     * @lua NA
     *)
    procedure updateUniforms();
    
    procedure setUniformLocationWith1i(location: GLint; i1: GLint);
    procedure setUniformLocationWith2i(location: GLint; i1,i2: GLint);
    procedure setUniformLocationWith3i(location: GLint; i1, i2, i3: GLint);
    procedure setUniformLocationWith4i(location: GLint; i1,i2, i3, i4: GLint);
    procedure setUniformLocationWith2iv(location: GLint; ints: PGLint; numberOfArrays: Cardinal);
    procedure setUniformLocationWith3iv(location: GLint; ints: PGLint; numberOfArrays: Cardinal);
    procedure setUniformLocationWith4iv(location: GLint; ints: PGLint; numberOfArrays: Cardinal);


    procedure setUniformLocationWith1f(location: GLint; f1: GLfloat);
    procedure setUniformLocationWith2f(location: GLint; f1, f2: GLfloat);
    procedure setUniformLocationWith3f(location: GLint; f1, f2, f3: GLfloat);
    procedure setUniformLocationWith4f(location: GLint; f1, f2, f3, f4: GLfloat);
    procedure setUniformLocationWith2fv(location: GLint; floats: PGLfloat; numberOfArrays: Cardinal);
    procedure setUniformLocationWith3fv(location: GLint; floats: PGLfloat; numberOfArrays: Cardinal);
    procedure setUniformLocationWith4fv(location: GLint; floats: PGLfloat; numberOfArrays: Cardinal);
    procedure setUniformLocationWithMatrix4fv(location: GLint; matrixArray: PGLfloat; numberOfMatrices: Cardinal);

    (** will update the builtin uniforms if they are different than the previous call for this same shader program. 
     *  @lua NA
     *)
    procedure setUniformsForBuiltins();
    function vertexShaderLog():string;
    function fragmentShaderLog(): string;
    function programLog(): PGLchar;
    function getProgram(): GLuint;
    procedure reset();
  private
    function updateUniformLocation(location: GLint; data: PGLvoid; bytes: Cardinal): Boolean;
    //function description(): PChar;
    function compileShader(shader: PGLuint; _type: GLenum; const source: PGLchar): Boolean;
    function logForOpenGLObject(obj: GLuint; infoFunc: GLInfoFunction; logFunc: GLLogFunction): PGLchar;
  end;

implementation
uses
  Cocos2dx.CCGLStateCache, Cocos2dx.CCString, Cocos2dx.CCFileUtils,
  utility, mat4, matrix, Cocos2dx.CCMacros, Cocos2dx.CCCommon,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCDirector;

{ CCGLProgram }

procedure freeElement(HashElement: THashElement);
begin
  FreeMem(ptHashUniformEntry(HashElement.pValue)^.value);
  FreeMem(ptHashUniformEntry(HashElement.pValue));
  HashElement.Free;
end;  

procedure CCGLProgram.addAttribute(const attributeName: PGLchar;
  index: GLuint);
begin
  glBindAttribLocation(m_uProgram,
                       index,
                       attributeName);
end;

function CCGLProgram.compileShader(shader: PGLuint; _type: GLenum;
  const source: PGLchar): Boolean;
const
  sourcescount = 3;
var
  status, len: GLint;
  sources: array [0..sourcescount-1] of PGLchar;
  length: GLsizei;
  src: PGLchar;
  buf: array [0..255] of Char;
  sbuf: string;
begin
  if source = nil then
  begin
    Result := False;
    Exit;
  end;

  {$ifdef IOS}
  if _type = GL_VERTEX_SHADER then
    sources[0] := 'precision highp float;'     + #$D#$A
  else
    sources[0] := 'precision mediump float;'   + #$D#$A;
  {$else}
    sources[0] := ' ' + #$D#$A;
  {$endif}

  sources[1] :=   'uniform mat4 CC_PMatrix;'   + #$D#$A +
                  'uniform mat4 CC_MVMatrix;'  + #$D#$A +
                  'uniform mat4 CC_MVPMatrix;' + #$D#$A +
                  'uniform vec4 CC_Time;'      + #$D#$A +
                  'uniform vec4 CC_SinTime;'   + #$D#$A +
                  'uniform vec4 CC_CosTime;'   + #$D#$A +
                  'uniform vec4 CC_Random01;'  + #$D#$A;

  sources[2] := source;

  shader^ := glCreateShader(_type);

  glShaderSource(shader^, sourcescount, @sources[0], nil);

  glCompileShader(shader^);

  glGetShaderiv(shader^, GL_COMPILE_STATUS, @status);

  if status = 0 then
  begin
    glGetShaderiv(shader^, GL_SHADER_SOURCE_LENGTH, @length);
    src := AllocMem(SizeOf(Char) * length);

    len := 0;
    {$IFDEF IOS}
    glGetShaderSource(shader^, length, @len, src);
    {$ELSE}
    glGetShaderSource(shader^, length, len, src);
    {$ENDIF}
    CCLog('cocos2d: ERROR: Failed to compile shader:%s', [src]);

    {$IFDEF IOS}
    len := 0;
    if _type = GL_VERTEX_SHADER then
      glGetShaderInfoLog(m_uVertShader, 256, @len, @buf[0])
    else
      glGetShaderInfoLog(m_uFragShader, 256, @len, @buf[0]);
    {$ELSE}
    if _type = GL_VERTEX_SHADER then
      glGetShaderInfoLog(m_uVertShader, 256, len, @buf[0])
    else
      glGetShaderInfoLog(m_uFragShader, 256, len, @buf[0]);
    {$ENDIF}

    if len > 0 then
    begin
      sbuf := buf;
    end else
    begin
      sbuf := '';
    end;

    if _type = GL_VERTEX_SHADER then
      CCLog('cocos2d: %s', [sbuf])
    else
      CCLog('cocos2d: %s', [sbuf]);

    FreeMem(src);
  end;  

  Result := status = GL_TRUE;
end;

constructor CCGLProgram.Create;
begin
  inherited Create();
  {m_uProgram := 0;
  m_uVertShader := 0;
  m_uFragShader := 0;
  m_bUsesTime := False;}
  //FillChar(m_uUniforms, SizeOf(m_uUniforms), 0);
  m_pHashChain := TtdHashTableChain.Create(100, freeElement);
end;

{function CCGLProgram.description: PChar;
begin
  Result := CCString.createWithFormat('<CCGLProgram = %d | Program = %d, VertexShader = %d, FragmentShader = %d>', [Cardinal(Self), m_uProgram, m_uVertShader, m_uFragShader]).getCString();
end;}

destructor CCGLProgram.Destroy;
begin
  CCLog('cocos2d: deallocing 0x%X', [Cardinal(Self)]);

  // there is no need to delete the shaders. They should have been already deleted.
  CCAssert( m_uVertShader = 0, 'Vertex Shaders should have been already deleted');
  CCAssert( m_uFragShader = 0, 'Fragment Shaders should have been already deleted');

  if m_uProgram > 0 then
    ccGLDeleteProgram(m_uProgram);
  m_pHashChain.Free;
  inherited;
end;

function CCGLProgram.fragmentShaderLog: string;
var
  pRet: PGLchar;
begin
  pRet := Self.logForOpenGLObject(m_uFragShader, GLInfoFunction(@glGetShaderiv),
    GLLogFunction(@glGetShaderInfoLog));
  if pRet = nil then
    Result := ''
  else
    Result := pRet;
end;

function CCGLProgram.getProgram: GLuint;
begin
  Result := m_uProgram;
end;

function CCGLProgram.getUniformLocationForName(const name: PGLchar): GLint;
begin
  CCAssert(name <> nil, 'Invalid uniform name');
  CCAssert(m_uProgram <> 0, 'Invalid operation. Cannot get uniform location when program is not initialized');
  Result := glGetUniformLocation(m_uProgram, name);
end;

function CCGLProgram.initWithVertexShaderByteArray(const vShaderByteArray,
  fShaderByteArray: PGLchar): Boolean;
begin
  m_uProgram := glCreateProgram();
  CHECK_GL_ERROR_DEBUG();

  m_uVertShader := 0; m_uFragShader := 0;

  if vShaderByteArray <> nil then
  begin
    if not compileShader(@m_uVertShader, GL_VERTEX_SHADER, vShaderByteArray) then
    begin
      CCLog('cocos2d: ERROR: Failed to compile vertex shader', []);
    end;  
  end;

  if fShaderByteArray <> nil then
  begin
    if not compileShader(@m_uFragShader, GL_FRAGMENT_SHADER, fShaderByteArray) then
    begin
      CCLog('cocos2d: ERROR: Failed to compile fragment shader', []);
    end;  
  end;

  if m_uVertShader > 0 then
    glAttachShader(m_uProgram, m_uVertShader);

  CHECK_GL_ERROR_DEBUG();

  if m_uFragShader > 0 then
    glAttachShader(m_uProgram, m_uFragShader);

  m_pHashForUniforms := nil;

  CHECK_GL_ERROR_DEBUG();

  Result := True;
end;

function CCGLProgram.initWithVertexShaderFilename(const vShaderFilename,
  fShaderFilename: string): Boolean;
var
  vertexSource, fragmentSource: PGLchar;
begin
  vertexSource := CCString.createWithContentsOfFile(CCFileUtils.sharedFileUtils().fullPathForFilename(vShaderFilename)).getCString();
  fragmentSource := CCString.createWithContentsOfFile(CCFileUtils.sharedFileUtils().fullPathForFilename(fShaderFilename)).getCString();
  Result := initWithVertexShaderByteArray(vertexSource, fragmentSource);
end;

function CCGLProgram.link: Boolean;
var
  status: GLint;
begin
  CCAssert(m_uProgram <> 0, 'Can not link invalid program');
  status := GL_TRUE;
  glLinkProgram(m_uProgram);

  if m_uVertShader > 0 then
    glDeleteShader(m_uVertShader);

  if m_uFragShader > 0 then
    glDeleteShader(m_uFragShader);

  m_uVertShader := 0;
  m_uFragShader := 0;

  {$IFDEF DEBUG}
  glGetProgramiv(m_uProgram, GL_LINK_STATUS, @status);
  if status = GL_FALSE then
  begin
    CCLog('cocos2d: ERROR: Failed to link program: %d', [m_uProgram]);
    ccGLDeleteProgram(m_uProgram);
    m_uProgram := 0;
  end;  
  {$ENDIF}

  Result := status = GL_TRUE;
end;

function CCGLProgram.logForOpenGLObject(obj: GLuint;
  infoFunc: GLInfoFunction; logFunc: GLLogFunction): PGLchar;
var
  logLength, charsWritten: GLint;
  logBytes: PGLchar;
  log: CCString;
begin
  logLength := 0; charsWritten := 0;
  infoFunc(obj, GL_INFO_LOG_LENGTH, @logLength);
  if logLength < 1 then
  begin
    Result := nil;
    Exit;
  end;

  logBytes := AllocMem(logLength);
  logFunc(obj, logLength, @charsWritten, logBytes);

  log := CCString._create(PChar(logBytes));
  FreeMem(logBytes);
  Result := log.getCString();
end;

function CCGLProgram.programLog: PGLchar;
begin
  Result := Self.logForOpenGLObject(m_uProgram, GLInfoFunction(@glGetProgramiv),
    GLLogFunction(@glGetProgramInfoLog));
end;

procedure CCGLProgram.reset;
begin
  m_uVertShader := 0; m_uFragShader := 0;
  FillChar(m_uUniforms, SizeOf(m_uUniforms), 0);

  m_uProgram := 0;

  m_pHashChain.Visit(freeElement);
  m_pHashForUniforms := nil
end;

procedure CCGLProgram.setUniformsForBuiltins;
var
  matrixP, matrixMV, matrixMVP: kmMat4;
  director: CCDirector;
  time: Single;
begin
  kmGLGetMatrix(KM_GL_PROJECTION, @matrixP);
  kmGLGetMatrix(KM_GL_MODELVIEW, @matrixMV);
  kmMat4Multiply(@matrixMVP, @matrixP, @matrixMV);

  setUniformLocationWithMatrix4fv(m_uUniforms[kCCUniformPMatrix], @matrixP.mat[0], 1);
  setUniformLocationWithMatrix4fv(m_uUniforms[kCCUniformMVMatrix], @matrixMV.mat[0], 1);
  setUniformLocationWithMatrix4fv(m_uUniforms[kCCUniformMVPMatrix], @matrixMVP.mat[0], 1);

  if m_bUsesTime then
  begin
    director := CCDirector.sharedDirector();
    // This doesn't give the most accurate global time value.
		// Cocos2D doesn't store a high precision time value, so this will have to do.
		// Getting Mach time per frame per shader using time could be extremely expensive.
    time := director.getTotalFrames() * director.getAnimationInterval();

    setUniformLocationWith4f(m_uUniforms[kCCUniformTime], time/10.0, time, time * 2, time * 4);
    setUniformLocationWith4f(m_uUniforms[kCCUniformSinTime], time/8.0, time/4.0, time/2.0, Sin(time));
    setUniformLocationWith4f(m_uUniforms[kCCUniformCosTime], time/8.0, time/4.0, time/2.0, Cos(time));
  end;

  if m_uUniforms[kCCUniformRandom01] <> -1 then
  begin
    setUniformLocationWith4f(m_uUniforms[kCCUniformRandom01], Random, Random, Random, Random);
  end;  
end;

procedure CCGLProgram.setUniformLocationWith1f(location: GLint;
  f1: GLfloat);
var
  update: Boolean;
begin
  update := updateUniformLocation(location, @f1, SizeOf(f1)*1);
  if update then
    glUniform1f(location, f1);
end;

procedure CCGLProgram.setUniformLocationWith1i(location: GLint;
  i1: GLint);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, @i1, SizeOf(i1)*1);
  if updated then
    glUniform1i(location, i1);
end;

procedure CCGLProgram.setUniformLocationWith2f(location: GLint; f1,
  f2: GLfloat);
var
  floats: array [0..1] of GLfloat;
  updated: Boolean;
begin
  floats[0] := f1;
  floats[1] := f2;

  updated := updateUniformLocation(location, @floats[0], SizeOf(floats));
  if updated then
    glUniform2f(location, f1, f2);
end;

procedure CCGLProgram.setUniformLocationWith2fv(location: GLint;
  floats: PGLfloat; numberOfArrays: Cardinal);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, floats, SizeOf(Single)*2*numberOfArrays);
  if updated then
    glUniform2fv(location, numberOfArrays, floats);
end;

procedure CCGLProgram.setUniformLocationWith2i(location, i1, i2: GLint);
var
  ints: array [0..1] of GLint;
  updated: Boolean;
begin
  ints[0] := i1; ints[1] := i2;
  updated := updateUniformLocation(location, @ints[0], SizeOf(ints));
  if updated then
  begin
    glUniform2i(location, i1, i2);
  end;  
end;

procedure CCGLProgram.setUniformLocationWith2iv(location: GLint;
  ints: PGLint; numberOfArrays: Cardinal);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, ints, SizeOf(GLint) * 2 * numberOfArrays);
  if updated then
  begin
    glUniform2iv(location, numberOfArrays, ints);
  end;
end;

procedure CCGLProgram.setUniformLocationWith3f(location: GLint; f1, f2,
  f3: GLfloat);
var
  floats: array [0..2] of GLfloat;
  updated: Boolean;
begin
  floats[0] := f1;
  floats[1] := f2;
  floats[2] := f3;

  updated := updateUniformLocation(location, @floats[0], SizeOf(floats));
  if updated then
    glUniform3f(location, f1, f2, f3);
end;

procedure CCGLProgram.setUniformLocationWith3fv(location: GLint;
  floats: PGLfloat; numberOfArrays: Cardinal);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, floats, SizeOf(Single)*3*numberOfArrays);
  if updated then
    glUniform3fv(location, numberOfArrays, floats);
end;

procedure CCGLProgram.setUniformLocationWith3i(location, i1, i2,
  i3: GLint);
var
  updated: Boolean;
  ints: array [0..2] of GLint;
begin
  ints[0] := i1; ints[1] := i2; ints[2] := i3;
  updated := updateUniformLocation(location, @ints[0], SizeOf(ints));
  if updated then
  begin
    glUniform3i(location, i1, i2, i3);
  end;  
end;

procedure CCGLProgram.setUniformLocationWith3iv(location: GLint;
  ints: PGLint; numberOfArrays: Cardinal);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, ints, SizeOf(GLint)*3*numberOfArrays);
  if updated then
    glUniform3iv(location, numberOfArrays, ints);
end;

procedure CCGLProgram.setUniformLocationWith4f(location: GLint; f1, f2,
  f3, f4: GLfloat);
var
  floats: array [0..3] of GLfloat;
  updated: Boolean;
begin
  floats[0] := f1;
  floats[1] := f2;
  floats[2] := f3;
  floats[3] := f4;

  updated := updateUniformLocation(location, @floats[0], SizeOf(floats));
  if updated then
    glUniform4f(location, f1, f2, f3, f4);
end;

procedure CCGLProgram.setUniformLocationWith4fv(location: GLint;
  floats: PGLfloat; numberOfArrays: Cardinal);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, floats, SizeOf(Single)*4*numberOfArrays);
  if updated then
    glUniform4fv(location, numberOfArrays, floats);
end;

procedure CCGLProgram.setUniformLocationWith4i(location, i1, i2, i3,
  i4: GLint);
var
  updated: Boolean;
  ints: array [0..3] of GLint;
begin
  ints[0] := i1; ints[1] := i2; ints[2] := i3; ints[3] := i4;
  updated := updateUniformLocation(location, @ints[0], SizeOf(ints));
  if updated then
  begin
    glUniform4i(location, i1, i2, i3, i4);
  end;
end;

procedure CCGLProgram.setUniformLocationWith4iv(location: GLint;
  ints: PGLint; numberOfArrays: Cardinal);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, ints, SizeOf(GLint)*4*numberOfArrays);
  if updated then
    glUniform4iv(location, numberOfArrays, ints);
end;

procedure CCGLProgram.setUniformLocationWithMatrix4fv(location: GLint;
  matrixArray: PGLfloat; numberOfMatrices: Cardinal);
var
  updated: Boolean;
begin
  updated := updateUniformLocation(location, matrixArray, SizeOf(Single)*16*numberOfMatrices);
  if updated then
    glUniformMatrix4fv(location, numberOfMatrices, GL_FALSE, matrixArray);
end;

function CCGLProgram.updateUniformLocation(location: GLint;
  data: PGLvoid; bytes: Cardinal): Boolean;
var
  updated: Boolean;
  element: CCDictElement;
  pValue: ptHashUniformEntry;
begin
  if location < 0 then
  begin
    Result := False;
    Exit;
  end;
  
  updated := True;
  element := m_pHashChain.FindElementByInteger(location);
  if element = nil then
  begin
    pValue := AllocMem(SizeOf(tHashUniformEntry));
    pValue^.location := location;
    pValue^.value := AllocMem(bytes);
    Move(data^, pValue^.value^, bytes);

    element := CCDictElement.Create(location, pValue);
    m_pHashChain.AddElement(element);
  end else
  begin
    if CompareMem(ptHashUniformEntry(element.pValue)^.value, data, bytes) then
      updated := False
    else
      Move(data^, ptHashUniformEntry(element.pValue)^.value^, bytes);
  end;

  Result := updated;
end;

procedure CCGLProgram.updateUniforms;
begin
  m_uUniforms[kCCUniformPMatrix]   := glGetUniformLocation(m_uProgram, kCCUniformPMatrix_s);
	m_uUniforms[kCCUniformMVMatrix]  := glGetUniformLocation(m_uProgram, kCCUniformMVMatrix_s);
	m_uUniforms[kCCUniformMVPMatrix] := glGetUniformLocation(m_uProgram, kCCUniformMVPMatrix_s);

	m_uUniforms[kCCUniformTime]      := glGetUniformLocation(m_uProgram, kCCUniformTime_s);
	m_uUniforms[kCCUniformSinTime]   := glGetUniformLocation(m_uProgram, kCCUniformSinTime_s);
	m_uUniforms[kCCUniformCosTime]   := glGetUniformLocation(m_uProgram, kCCUniformCosTime_s);

  m_uUniforms[kCCUniformRandom01]  := glGetUniformLocation(m_uProgram, kCCUniformRandom01_s);
  m_uUniforms[kCCUniformSampler]   := glGetUniformLocation(m_uProgram, kCCUniformSampler_s);

  m_bUsesTime := (m_uUniforms[kCCUniformTime]    <> -1) or
                 (m_uUniforms[kCCUniformSinTime] <> -1) or
                 (m_uUniforms[kCCUniformCosTime] <> -1);

  Self.use();
  Self.setUniformLocationWith1i(m_uUniforms[kCCUniformSampler], 0);
end;

procedure CCGLProgram.use;
begin
  ccGLUseProgram(m_uProgram);
end;

function CCGLProgram.vertexShaderLog: string;
var
  pRet: PGLchar;
begin
  pRet := Self.logForOpenGLObject(m_uVertShader, GLInfoFunction(@glGetShaderiv),
    GLLogFunction(@glGetShaderInfoLog));
  if pRet = nil then
    Result := ''
  else
    Result := pRet;
end;

end.
