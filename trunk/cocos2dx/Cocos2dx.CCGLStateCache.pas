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

unit Cocos2dx.CCGLStateCache;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES; {$else} dglOpenGL; {$endif}



//** vertex attrib flags */
const    kCCVertexAttribFlag_None         = 0;
const    kCCVertexAttribFlag_Position     = 1 shl 0;
const    kCCVertexAttribFlag_Color        = 1 shl 1;
const    kCCVertexAttribFlag_TexCoords    = 1 shl 2;
const    kCCVertexAttribFlag_PosColorTex  = ( kCCVertexAttribFlag_Position or kCCVertexAttribFlag_Color or kCCVertexAttribFlag_TexCoords );

type
  ccGLServerState =
  (
    //CC_GL_BLEND = 1 shl 3,
    //CC_GL_ALL   = CC_GL_BLEND
    CC_GL_ALL = 0
  );

(** Invalidates the GL state cache.
 If CC_ENABLE_GL_STATE_CACHE it will reset the GL state cache.
 @since v2.0.0
 *)
procedure ccGLInvalidateStateCache();

(** Uses the GL program in case program is different than the current one.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will the glUseProgram() directly.
 @since v2.0.0
 *)
procedure ccGLUseProgram(glprogram: GLuint);

(** Deletes the GL program. If it is the one that is being used, it invalidates it.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will the glDeleteProgram() directly.
 @since v2.0.0
 *)
procedure ccGLDeleteProgram(glprogram: GLuint);

(** Uses a blending function in case it not already used.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will the glBlendFunc() directly.
 @since v2.0.0
 *)
procedure ccGLBlendFunc(sfactor, dfactor: GLenum);

(** sets the projection matrix as dirty
 @since v2.0.0
 *)
procedure ccSetProjectionMatrixDirty();

(** Will enable the vertex attribs that are passed as flags.
 Possible flags:

    * kCCVertexAttribFlag_Position
    * kCCVertexAttribFlag_Color
    * kCCVertexAttribFlag_TexCoords

 These flags can be ORed. The flags that are not present, will be disabled.

 @since v2.0.0
 *)
procedure ccGLEnableVertexAttribs(flags: Cardinal);

(** If the texture is not already bound to texture unit 0, it binds it.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will call glBindTexture() directly.
 @since v2.0.0
 *)
procedure ccGLBindTexture2D(textureId: GLuint);

(** If the texture is not already bound to a given unit, it binds it.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will call glBindTexture() directly.
 @since v2.1.0
 *)
procedure ccGLBindTexture2DN(textureUnit: GLuint; textureId: GLuint);

(** It will delete a given texture. If the texture was bound, it will invalidate the cached for the given texture unit.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will call glDeleteTextures() directly.
 @since v2.1.0
 *)
procedure ccGLDeleteTextureN(textureUnit, textureId: GLuint);

(** It will delete a given texture. If the texture was bound, it will invalidate the cached.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will call glDeleteTextures() directly.
 @since v2.0.0
 *)
procedure ccGLDeleteTexture(textureId: GLuint);

(** It will enable / disable the server side GL states.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will call glEnable() directly.
 @since v2.0.0
 *)
procedure ccGLEnable(flags: ccGLServerState);

(** If the vertex array is not already bound, it binds it.
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will call glBindVertexArray() directly.
 @since v2.0.0
 *)
procedure ccGLBindVAO(vaoId: GLuint);

(** Resets the blending mode back to the cached state in case you used glBlendFuncSeparate() or glBlendEquation().
 If CC_ENABLE_GL_STATE_CACHE is disabled, it will just set the default blending mode using GL_FUNC_ADD.
 @since v2.0.0
 *)
procedure ccGLBlendResetToCache();

implementation

uses
  matrix, Cocos2dx.CCGLProgram, Cocos2dx.CCPlatformMacros;

var s_uCurrentProjectionMatrix: GLuint = $FFFFFFFF;
var s_bVertexAttribPosition: Boolean = False;
var s_bVertexAttribColor: Boolean = False;
var s_bVertexAttribTexCoords: Boolean = False;

{$IFDEF CC_ENABLE_GL_STATE_CACHE}
const kCCMaxActiveTexture = 16;
var s_uCurrentShaderProgram: GLuint = $FFFFFFFF;
var s_uCurrentBoundTexture: array [0..kCCMaxActiveTexture-1] of GLuint =
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF,
     $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF);
var s_eBlendingSource: GLenum = $FFFFFFFF;
var s_eBlendingDest: GLenum = $FFFFFFFF;
var s_eGLServerState: Integer = 0;

{$IFDEF CC_TEXTURE_ATLAS_USE_VAO}
var s_uVAO: GLuint;
{$ENDIF}

{$ENDIF}

procedure ccGLInvalidateStateCache();
var
  i: Integer;
begin
  kmGLFreeAll();
  s_uCurrentProjectionMatrix := $FFFFFFFF;
  s_bVertexAttribPosition := False;
  s_bVertexAttribColor := False;
  s_bVertexAttribTexCoords := False;
  {$IFDEF CC_ENABLE_GL_STATE_CACHE}
  s_uCurrentShaderProgram := $FFFFFFFF;
  for i := 0 to kCCMaxActiveTexture-1 do
  begin
    s_uCurrentBoundTexture[i] := $FFFFFFFF;
  end;

  s_eBlendingSource := $FFFFFFFF;
  s_eBlendingDest := $FFFFFFFF;
  s_eGLServerState := 0;
  {$IFDEF CC_TEXTURE_ATLAS_USE_VAO}
  s_uVAO := 0;
  {$ENDIF}
  {$ENDIF}
end;

procedure ccGLUseProgram(glprogram: GLuint);
begin
  {$IFDEF CC_ENABLE_GL_STATE_CACHE}
  if glprogram <> s_uCurrentShaderProgram then
  begin
    s_uCurrentShaderProgram := glprogram;
    glUseProgram(glprogram);
  end;
  {$ELSE}
  glUseProgram(glprogram);
  {$ENDIF}
end;

procedure setBlending(sfactor, dfactor: GLenum);
begin
  if (sfactor = GL_ONE) and (dfactor = GL_ZERO) then
  begin
    glDisable(GL_BLEND);
  end else
  begin
    glEnable(GL_BLEND);
    glBlendFunc(sfactor, dfactor);
  end;    
end;  

procedure ccGLDeleteProgram(glprogram: GLuint);
begin
  {$IFDEF CC_ENABLE_GL_STATE_CACHE}
  if glprogram = s_uCurrentShaderProgram then
    s_uCurrentShaderProgram := $FFFFFFFF;
  {$ENDIF}
  glDeleteProgram(glprogram);
end;

procedure ccGLBlendFunc(sfactor, dfactor: GLenum);
begin
  {$IFDEF CC_ENABLE_GL_STATE_CACHE}
  if (sfactor <> s_eBlendingSource) or (dfactor <> s_eBlendingDest) then
  begin
    s_eBlendingSource := sfactor;
    s_eBlendingDest := dfactor;
    setBlending(sfactor, dfactor);
  end;  
  {$ELSE}
  setBlending(sfactor, dfactor);
  {$ENDIF}
end;

procedure ccSetProjectionMatrixDirty();
begin
  s_uCurrentProjectionMatrix := $FFFFFFFF;
end;

procedure ccGLEnableVertexAttribs(flags: Cardinal);
var
  enablePosition, enableColor, enableTexCoords: Boolean;
begin
  ccGLBindVAO(0);
  enablePosition := Boolean(flags and kCCVertexAttribFlag_Position);

  if enablePosition <> s_bVertexAttribPosition then
  begin
    if enablePosition then
      glEnableVertexAttribArray(kCCVertexAttrib_Position)
    else
      glDisableVertexAttribArray(kCCVertexAttrib_Position);

    s_bVertexAttribPosition := enablePosition;
  end;

  if (flags and kCCVertexAttribFlag_Color) <> 0 then
    enableColor := True
  else
    enableColor := False;

  if enableColor <> s_bVertexAttribColor then
  begin
    if enableColor then
      glEnableVertexAttribArray(kCCVertexAttrib_Color)
    else
      glDisableVertexAttribArray(kCCVertexAttrib_Color);

    s_bVertexAttribColor := enableColor;
  end;

  if (flags and kCCVertexAttribFlag_TexCoords) <> 0  then
    enableTexCoords := True
  else
    enableTexCoords := False;

  if enableTexCoords <> s_bVertexAttribTexCoords then
  begin
    if enableTexCoords then
      glEnableVertexAttribArray(kCCVertexAttrib_TexCoords)
    else
      glDisableVertexAttribArray(kCCVertexAttrib_TexCoords);

    s_bVertexAttribTexCoords := enableTexCoords;
  end;  
end;

procedure ccGLBindTexture2DN(textureUnit: GLuint; textureId: GLuint);
begin
{$IFDEF CC_ENABLE_GL_STATE_CACHE}
  CCAssert(textureUnit < kCCMaxActiveTexture, 'textureUnit is too big');
  if s_uCurrentBoundTexture[textureUnit] <> textureId then
  begin
    s_uCurrentBoundTexture[textureUnit] := textureId;
    glActiveTexture(GL_TEXTURE0 + textureUnit);
    glBindTexture(GL_TEXTURE_2D, textureId);
  end;  
{$ELSE}
  glActiveTexture(GL_TEXTURE0 + textureUnit);
  glBindTexture(GL_TEXTURE_2D, textureId);
{$ENDIF}
end;  

procedure ccGLBindTexture2D(textureId: GLuint);
begin
  ccGLBindTexture2DN(0, textureId);
end;

procedure ccGLDeleteTextureN(textureUnit, textureId: GLuint);
begin
{$IFDEF CC_ENABLE_GL_STATE_CACHE}
  if s_uCurrentBoundTexture[textureUnit] = textureId then
  begin
    s_uCurrentBoundTexture[textureUnit] := GLuint(-1);
  end;  
{$ENDIF}
  glDeleteTextures(1, @textureId);
end;  

procedure ccGLDeleteTexture(textureId: GLuint);
begin
  ccGLDeleteTextureN(0, textureId);
end;

procedure ccGLEnable(flags: ccGLServerState);
begin

end;

procedure ccGLBindVAO(vaoId: GLuint);
begin
{$IFDEF CC_TEXTURE_ATLAS_USE_VAO}
{$IFDEF CC_ENABLE_GL_STATE_CACHE}
  if s_uVAO <> vaoId then
  begin
    s_uVAO := vaoId;
    glBindVertexArray(vaoId);
  end;
{$ELSE}
  glBindVertexArray(vaoId);
{$ENDIF}
{$ENDIF}
end;

procedure ccGLBlendResetToCache();
begin
  glBlendEquation(GL_FUNC_ADD);
{$IFDEF CC_ENABLE_GL_STATE_CACHE}
  setBlending(s_eBlendingSource, s_eBlendingDest);
{$ELSE}
  setBlending(CC_BLEND_SRC, CC_BLEND_DST);
{$ENDIF}
end;  

end.
