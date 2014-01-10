(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada

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

unit Cocos2dx.CCProtocols;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCTypes, Cocos2dx.CCTexture2D;

type
  (**
   * RGBA protocol that affects CCNode's color and opacity
   * @js NA
   *)
  CCRGBAProtocol = interface
    (**
     * Changes the color with R,G,B bytes
     *
     * @param color Example: ccc3(255,100,0) means R=255, G=100, B=0
     *)
    procedure setColor(const color: ccColor3B);
    (**
     * Returns color that is currently used.
     *
     * @return The ccColor3B contains R,G,B bytes.
     *)
    function getColor(): ccColor3B;
    (**
     * Returns the displayed color.
     *
     * @return The ccColor3B contains R,G,B bytes.
     *)
    function getDisplayColor(): ccColor3B;
    (**
     * Returns the displayed opacity.
     *
     * @return  The opacity of sprite, from 0 ~ 255
     *)
    function getDisplayOpacity(): GLubyte;
    (**
     * Returns the opacity.
     *
     * The opacity which indicates how transparent or opaque this node is.
     * 0 indicates fully transparent and 255 is fully opaque.
     *
     * @return  The opacity of sprite, from 0 ~ 255
     *)
    function getOpacity(): GLubyte;
    (**
     * Changes the opacity.
     *
     * @param   value   Goes from 0 to 255, where 255 means fully opaque and 0 means fully transparent.
     *)
    procedure setOpacity(opacity: GLubyte);
    (**
     * Changes the OpacityModifyRGB property.
     * If thie property is set to true, then the rendered color will be affected by opacity.
     * Normally, r = r * opacity/255, g = g * opacity/255, b = b * opacity/255.
     *
     * @param   bValue  true then the opacity will be applied as: glColor(R,G,B,opacity);
     *                  false then the opacity will be applied as: glColor(opacity, opacity, opacity, opacity);
     *)
    procedure setOpacityModifyRGB(bValue: Boolean);
    (**
     * Returns whether or not the opacity will be applied using glColor(R,G,B,opacity)
     * or glColor(opacity, opacity, opacity, opacity)
     *
     * @return  Returns opacity modify flag.
     *)
    function isOpacityModifyRGB(): Boolean;
    (**
     *  whether or not color should be propagated to its children.
     *)
    function isCascadeColorEnabled(): Boolean;
    procedure setCascadeColorEnabled(cascadeColorEnabled: Boolean);
    (**
     *  recursive method that updates display color
     *)
    procedure updateDisplayedColor(const color: ccColor3B);
    (**
     *  whether or not opacity should be propagated to its children.
     *)
    function isCascadeOpacityEnabled(): Boolean;
    procedure setCascadeOpacityEnabled(cascadeOpacityEnabled: Boolean);
    (**
     *  recursive method that updates the displayed opacity.
     *)
    procedure updateDisplayedOpacity(opacity: GLubyte);
  end;

  (**
   * Specify the blending function according glBlendFunc
   * Please refer to glBlendFunc in OpenGL ES Manual
   * http://www.khronos.org/opengles/sdk/docs/man/xhtml/glBlendFunc.xml for more details.
   * @js NA
   * @lua NA
   *)
  CCBlendProtocol = interface
    (**
     * Sets the source blending function.
     *
     * @param blendFunc A structure with source and destination factor to specify pixel arithmetic,
     *                  e.g. {GL_ONE, GL_ONE}, {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}.
     *
     *)
    procedure setBlendFunc(blendFunc: ccBlendFunc);
    (**
     * Returns the blending function that is currently being used.
     *
     * @return A ccBlendFunc structure with source and destination factor which specified pixel arithmetic.
     *)
    function getBlendFunc(): ccBlendFunc;
  end;

  (**
   * CCNode objects that uses a CCTexture2D to render the images.
   * The texture can have a blending function.
   * If the texture has alpha premultiplied the default blending function is:
   *   src=GL_ONE dst= GL_ONE_MINUS_SRC_ALPHA
   * else
   *   src=GL_SRC_ALPHA dst= GL_ONE_MINUS_SRC_ALPHA
   * But you can change the blending function at any time.
   * @js NA
   *)
  CCTextureProtocol = interface(CCBlendProtocol)
    (**
     * Returns the currently used texture
     *
     * @return  The texture that is currenlty being used.
     * @lua NA
     *)
    function getTexture(): CCTexture2D;
    (**
     * Sets a new texuture. It will be retained.
     *
     * @param   texture A valid CCTexture2D object, which will be applied to this sprite object.
     * @lua NA
     *)
    procedure setTexture(texture: CCTexture2D);
  end;

  CCLabelProtocol = interface
    procedure setString(const slabel: string);
    function getString(): string;
  end;

  CCDirectorDelegate = class
    procedure updateProjection(); virtual; abstract;
  end;

  //added by myself
  CCInterface = class(CCObject, CCRGBAProtocol, CCTextureProtocol, CCLabelProtocol)
  public
    //
    procedure setString(const slabel: string); dynamic;
    function getString(): string; dynamic;
    //
    function getTexture(): CCTexture2D; dynamic;
    procedure setTexture(texture: CCTexture2D); dynamic;
    //
    procedure setBlendFunc(blendFunc: ccBlendFunc); dynamic;
    function getBlendFunc(): ccBlendFunc; dynamic;
    //
    procedure setColor(const color: ccColor3B); dynamic;
    function getColor(): ccColor3B; dynamic;
    function getOpacity(): GLubyte; dynamic;
    procedure setOpacity(opacity: GLubyte); dynamic;
    procedure setOpacityModifyRGB(bValue: Boolean); dynamic;
    function isOpacityModifyRGB(): Boolean; dynamic;
    function getDisplayColor(): ccColor3B; dynamic;
    function getDisplayOpacity(): GLubyte; dynamic;
    function isCascadeColorEnabled(): Boolean; dynamic;
    procedure setCascadeColorEnabled(cascadeColorEnabled: Boolean); dynamic;
    procedure updateDisplayedColor(const color: ccColor3B); dynamic;
    function isCascadeOpacityEnabled(): Boolean; dynamic;
    procedure setCascadeOpacityEnabled(cascadeOpacityEnabled: Boolean); dynamic;
    procedure updateDisplayedOpacity(opacity: GLubyte); dynamic;
  end;


implementation
uses
  Cocos2dx.CCMacros;

{ CCInterface }

function CCInterface.getBlendFunc: ccBlendFunc;
begin
  Result.src := CC_BLEND_SRC;
  Result.dst := CC_BLEND_DST;
end;

function CCInterface.getColor: ccColor3B;
begin
  Result := ccWHITE;
end;

function CCInterface.getDisplayColor: ccColor3B;
begin
  Result.r := 0;
  Result.g := 0;
  Result.b := 0;
end;

function CCInterface.getDisplayOpacity: GLubyte;
begin
  Result := 0;
end;

function CCInterface.getOpacity: GLubyte;
begin
  Result := 0;
end;

function CCInterface.getString: string;
begin
  Result := '';
end;

function CCInterface.getTexture: CCTexture2D;
begin
  Result := nil;
end;

function CCInterface.isCascadeColorEnabled: Boolean;
begin
  Result := False;
end;

function CCInterface.isCascadeOpacityEnabled: Boolean;
begin
  Result := False;
end;

function CCInterface.isOpacityModifyRGB: Boolean;
begin
  Result := False;
end;

procedure CCInterface.setBlendFunc(blendFunc: ccBlendFunc);
begin

end;

procedure CCInterface.setCascadeColorEnabled(cascadeColorEnabled: Boolean);
begin

end;

procedure CCInterface.setCascadeOpacityEnabled(
  cascadeOpacityEnabled: Boolean);
begin

end;

procedure CCInterface.setColor(const color: ccColor3B);
begin

end;

procedure CCInterface.setOpacity(opacity: GLubyte);
begin

end;

procedure CCInterface.setOpacityModifyRGB(bValue: Boolean);
begin

end;

procedure CCInterface.setString(const slabel: string);
begin

end;

procedure CCInterface.setTexture(texture: CCTexture2D);
begin

end;

procedure CCInterface.updateDisplayedColor(const color: ccColor3B);
begin

end;

procedure CCInterface.updateDisplayedOpacity(opacity: GLubyte);
begin

end;

end.
