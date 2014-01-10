(****************************************************************************
 Copyright (c) 2013 cocos2d-x.org

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

unit Cocos2dx.CCTextureETC;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject;

type
  CCTextureETC = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    function initWithFile(const fileName: string): Boolean;
    function getName(): Cardinal;
    function getWidth(): Cardinal;
    function getHeight(): Cardinal;
  private
    _name: GLuint;
    _width, _height: Cardinal;
    //function loadTexture(const fileName: string): Boolean;
  end;

implementation
uses
  Cocos2dx.CCFileUtils;

{ CCTextureETC }

constructor CCTextureETC.Create;
begin
  inherited Create();
end;

destructor CCTextureETC.Destroy;
begin

  inherited;
end;

function CCTextureETC.getHeight: Cardinal;
begin
  Result := _height;
end;

function CCTextureETC.getName: Cardinal;
begin
  Result := _name;
end;

function CCTextureETC.getWidth: Cardinal;
begin
  Result := _width;
end;

function CCTextureETC.initWithFile(const fileName: string): Boolean;
begin
  {$IFDEF android}
  Result := loadTexture(CCFileUtils.sharedFileUtils().fullPathForFilename(fileName));
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

{function CCTextureETC.loadTexture(const fileName: string): Boolean;
begin
  Result := False;
end;}

end.
