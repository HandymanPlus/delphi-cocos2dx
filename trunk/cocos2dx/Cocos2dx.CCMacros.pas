(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
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

unit Cocos2dx.CCMacros;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCGeometry;

const kCCRepeatForever = High(Cardinal)-1;
const FLT_EPSILON = 1.192092896e-07;
const CC_BLEND_SRC = GL_ONE;
const CC_BLEND_DST = GL_ONE_MINUS_SRC_ALPHA;

function CC_DEGREES_TO_RADIANS(const angle: Single): Single; {$ifdef Inline} inline; {$ENDIF}
function CC_RADIANS_TO_DEGREES(const angle: Single): Single; {$ifdef Inline} inline; {$ENDIF}
function CC_RECT_POINTS_TO_PIXELS(const rect: CCRect): CCRect; {$ifdef Inline} inline; {$ENDIF}
function CC_POINT_PIXELS_TO_POINTS(const pt: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function CC_SIZE_PIXELS_TO_POINTS(const size: CCSize): CCSize; {$ifdef Inline} inline; {$ENDIF}
function CC_RECT_PIXELS_TO_POINTS(const rc: CCRect): CCRect; {$ifdef Inline} inline; {$ENDIF}
function CC_SIZE_POINTS_TO_PIXELS(const size: CCSize): CCSize; {$ifdef Inline} inline; {$ENDIF}
function CC_POINT_POINTS_TO_PIXELS(const pt: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function CC_CONTENT_SCALE_FACTOR(): Single;
procedure CHECK_GL_ERROR_DEBUG();
procedure CC_INCREMENT_GL_DRAWS(const nAdd: Cardinal);
function CCRANDOM_MINUS1_1(): Single;
function BUFFER_OFFSET(I: Cardinal): Pointer;

var g_uNumberOfDraws: Cardinal;

implementation
uses
  Cocos2dx.CCDirector, Cocos2dx.CCCommon;

function CC_DEGREES_TO_RADIANS(const angle: Single): Single;
begin
  Result := angle*0.01745329252;
end;

function CC_RADIANS_TO_DEGREES(const angle: Single): Single;
begin
  //function RadToDeg(const Radians: Extended): Extended;
  Result := angle * 57.29577951;
end;  

function CC_RECT_POINTS_TO_PIXELS(const rect: CCRect): CCRect;
begin
  Result := CCRectMake(rect.origin.x*CC_CONTENT_SCALE_FACTOR, rect.origin.y*CC_CONTENT_SCALE_FACTOR,
                  rect.size.width*CC_CONTENT_SCALE_FACTOR, rect.size.height*CC_CONTENT_SCALE_FACTOR);
end;

function CC_POINT_PIXELS_TO_POINTS(const pt: CCPoint): CCPoint;
begin
  Result := CCPointMake(pt.x/CC_CONTENT_SCALE_FACTOR, pt.y/CC_CONTENT_SCALE_FACTOR);
end;

function CC_SIZE_PIXELS_TO_POINTS(const size: CCSize): CCSize;
begin
  Result := CCSizeMake(size.width*CC_CONTENT_SCALE_FACTOR, size.height*CC_CONTENT_SCALE_FACTOR);
end;

function CC_RECT_PIXELS_TO_POINTS(const rc: CCRect): CCRect;
begin
  Result := CCRectMake(
    rc.origin.x/CC_CONTENT_SCALE_FACTOR,
    rc.origin.y/CC_CONTENT_SCALE_FACTOR,
    rc.size.width/CC_CONTENT_SCALE_FACTOR,
    rc.size.height/CC_CONTENT_SCALE_FACTOR);
end;

function CC_SIZE_POINTS_TO_PIXELS(const size: CCSize): CCSize;
begin
  Result := CCSizeMake(size.width*CC_CONTENT_SCALE_FACTOR, size.height*CC_CONTENT_SCALE_FACTOR);
end;

function CC_POINT_POINTS_TO_PIXELS(const pt: CCPoint): CCPoint;
begin
  Result := CCPointMake(pt.x*CC_CONTENT_SCALE_FACTOR, pt.y*CC_CONTENT_SCALE_FACTOR);
end;  

function CC_CONTENT_SCALE_FACTOR(): Single;
begin
  Result := CCDirector.sharedDirector().getContentScaleFactor();
end;

procedure CHECK_GL_ERROR_DEBUG();
var
  error: GLenum;
begin
  error := glGetError();
  CCLog('OpenGL error 0x%04X', [error]);
end;

procedure CC_INCREMENT_GL_DRAWS(const nAdd: Cardinal);
begin
  Inc(g_uNumberOfDraws, nAdd);
end;

function CCRANDOM_MINUS1_1(): Single;
begin
  Result := Random * 2.0 - 1.0;
end;

function BUFFER_OFFSET(I: Cardinal): Pointer;
var
  Ptr: Pointer absolute I;
begin
  Result := Ptr;
end;

end.
