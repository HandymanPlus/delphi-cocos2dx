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

(*
 *
 * IMPORTANT       IMPORTANT        IMPORTANT        IMPORTANT
 *
 *
 * LEGACY FUNCTIONS
 *
 * USE CCDrawNode instead
 *
 *)

unit Cocos2dx.CCDrawingPrimitives;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCTypes, Cocos2dx.CCMacros, Cocos2dx.CCGeometry;

procedure ccDrawPoint(const point: CCPoint);
procedure ccDrawPoints(const points: ptCCPoint; numberOfPoints: Cardinal);
procedure ccDrawLine(const origin: CCPoint; const destination: CCPoint);
procedure ccDrawRect(origin, destination: CCPoint);
procedure ccDrawSoldRect(origin, destination: CCPoint; color: ccColor4F);
procedure ccDrawPoly(const vertices: ptCCPoint; numOfVertices: Cardinal; closePolygon: Boolean);
procedure ccDrawSolidPoly(const poli: ptCCPoint; numberOfPoints: Cardinal; color: ccColor4F);
procedure ccDrawCircle(const center: CCPoint; radius: Single; angle: Single; segments: Cardinal; drawLineToCenter: Boolean; scaleX, scaleY: Single); overload;
procedure ccDrawCircle(const center: CCPoint; radius: Single; angle: Single; segments: Cardinal; drawLineToCenter: Boolean); overload;
procedure ccDrawQuadBezier(const origin: CCPoint; const control: CCPoint; const destination: CCPoint; segments: Cardinal);
procedure ccDrawCubicBezier(const origin: CCPoint; const control1, control2: CCPoint; const destination: CCPoint; segments: Cardinal);
//procedure ccDrawCatmullRom(arrayofControlPoints:);
// ccDrawCardinalSpline
procedure ccDrawColor4B(r, g, b, a: GLubyte);
procedure ccDrawColor4F(r, g, b, a: GLfloat);
procedure ccPointSize(pointSize: GLfloat);

implementation
uses
  Math,
  Cocos2dx.CCGLStateCache, Cocos2dx.CCGLProgram, Cocos2dx.CCShaderCache, Cocos2dx.CCPointExtension;

var s_bInitialized: Boolean = False;
var s_pShader: CCGLProgram;
var s_nColorLocation: Integer = -1;
var s_tColor: ccColor4F = (r: 1.0; g: 1.0; b: 1.0; a: 1.0);
var s_nPointSizeLocation: Integer = -1;
var s_fPointSize: GLfloat = 1.0;

procedure lazy_init();
begin
  if not s_bInitialized then
  begin
    s_pShader := CCShaderCache.sharedShaderCache().programForKey(kCCShader_Position_uColor);
    s_nColorLocation := glGetUniformLocation(s_pShader.getProgram(), 'u_color');
    s_nPointSizeLocation := glGetUniformLocation(s_pShader.getProgram(), 'u_pointSize');
    s_bInitialized := True;
  end;  
end;  

procedure ccDrawPoint(const point: CCPoint);
var
  p: ccVertex2F;
begin
  lazy_init();

  p.x := point.x;
  p.y := point.y;

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
  s_pShader.use();
  s_pShader.setUniformsForBuiltins();

  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@s_tColor), 1);
  s_pShader.setUniformLocationWith1f(s_nPointSizeLocation, s_fPointSize);

  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @p);

  glDrawArrays(GL_POINTS, 0, 1);
end;
{$HINTS OFF}
procedure ccDrawPoints(const points: ptCCPoint; numberOfPoints: Cardinal);
var
  newPoints: array of ccVertex2F;
  i: Cardinal; //why?
begin
  lazy_init();

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
  s_pShader.use();
  s_pShader.setUniformsForBuiltins();
  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@s_tColor.r), 1);
  s_pShader.setUniformLocationWith1f(s_nPointSizeLocation, s_fPointSize);

  if SizeOf(CCPoint) = SizeOf(ccVertex2F) then
  begin
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @points[0]);
  end else
  begin
    SetLength(newPoints, numberOfPoints);
    for i := 0 to numberOfPoints-1 do
    begin
      newPoints[i].x := points[i].x;
      newPoints[i].y := points[i].y;
    end;
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @newPoints[0]);
  end;
  glDrawArrays(GL_POINTS, 0, numberOfPoints);

  newPoints := nil;
end;
{$HINTS ON}
procedure ccDrawLine(const origin: CCPoint; const destination: CCPoint);
var
  vertices: array [0..1] of ccVertex2F;
begin
  lazy_init();

  vertices[0].x := origin.x; vertices[0].y := origin.y;
  vertices[1].x := destination.x; vertices[1].y := destination.y;

  s_pShader.use();
  CHECK_GL_ERROR_DEBUG();

  s_pShader.setUniformsForBuiltins();
  CHECK_GL_ERROR_DEBUG();
  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@s_tColor.r), 1);
  CHECK_GL_ERROR_DEBUG();

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
  CHECK_GL_ERROR_DEBUG();
  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);
  CHECK_GL_ERROR_DEBUG();

  glDrawArrays(GL_LINES, 0, 2);
end;

procedure ccDrawRect(origin, destination: CCPoint);
begin
  ccDrawLine(CCPointMake(origin.x, origin.y), CCPointMake(destination.x, origin.y));
  ccDrawLine(CCPointMake(destination.x, origin.y), CCPointMake(destination.x, destination.y));
  ccDrawLine(CCPointMake(destination.x, destination.y), CCPointMake(origin.x, destination.y));
  ccDrawLine(CCPointMake(origin.x, destination.y), CCPointMake(origin.x, origin.y));
end;

procedure ccDrawSoldRect(origin, destination: CCPoint; color: ccColor4F);
var
  vertices: array [0..3] of CCPoint;
begin
  vertices[0] := origin;
  vertices[1] := ccp(destination.x, origin.y);
  vertices[2] := destination;
  vertices[3] := ccp(origin.x, destination.y);

  ccDrawSolidPoly(@vertices[0], 4, color);
end;
{$HINTS OFF}
procedure ccDrawPoly(const vertices: ptCCPoint; numOfVertices: Cardinal; closePolygon: Boolean);
var
  newPoli: array of ccVertex2F;
  i: Cardinal;
begin
  lazy_init();

  s_pShader.use();
  s_pShader.setUniformsForBuiltins();
  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@s_tColor.r), 1);

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);

  if SizeOf(CCPoint) = SizeOf(ccVertex2F) then
  begin
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);
    if closePolygon then
      glDrawArrays(GL_LINE_LOOP, 0, numOfVertices)
    else
      glDrawArrays(GL_LINE_STRIP, 0, numOfVertices);
  end else
  begin
    SetLength(newPoli, numOfVertices);

    for i := 0 to numOfVertices-1 do
    begin
      newPoli[i].x := vertices[i].x;
      newPoli[i].y := vertices[i].y;
    end;

    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @newPoli[0]);

    if closePolygon then
      glDrawArrays(GL_LINE_LOOP, 0, numOfVertices)
    else
      glDrawArrays(GL_LINE_STRIP, 0, numOfVertices);

    newPoli := nil;
  end;
end;
{$HINTS ON}
{$HINTS OFF}
procedure ccDrawSolidPoly(const poli: ptCCPoint; numberOfPoints: Cardinal; color: ccColor4F);
var
  newPoli: array of ccVertex2F;
  i: Cardinal;
begin
  lazy_init();

  s_pShader.use();
  s_pShader.setUniformsForBuiltins();
  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@color.r), 1);

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);

  if SizeOf(CCPoint) = SizeOf(ccVertex2F) then
  begin
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @poli[0]);
  end else
  begin
    SetLength(newPoli, numberOfPoints);
    for i := 0 to numberOfPoints-1 do
      newPoli[i] := vertex2(poli[i].x, poli[i].y);

    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @newPoli[0]);
  end;

  glDrawArrays(GL_TRIANGLE_FAN, 0, numberOfPoints);

  newPoli := nil;
end;
{$HINTS ON}
procedure ccDrawCircle(const center: CCPoint; radius: Single; angle: Single; segments: Cardinal; drawLineToCenter: Boolean; scaleX, scaleY: Single);
var
  additionalSegment: Cardinal;
  coef: Single;
  vertices: array of GLfloat;
  i: Cardinal;
  rads, j, k: Single;
begin
  lazy_init();

  additionalSegment := 1;

  if drawLineToCenter then
    Inc(additionalSegment);

  coef := 2.0* Pi / segments;

  SetLength(vertices, 2*(segments+2));

  for i := 0 to segments do
  begin
    rads := i*coef;
    j := radius*Cos(rads+angle)*scaleX + center.x;
    k := radius*Sin(rads+angle)*scaleY + center.y;

    vertices[i*2] := j;
    vertices[i*2+1] := k;
  end;

  vertices[(segments+1)*2] := center.x;
  vertices[(segments+1)*2+1] := center.y;

  s_pShader.use();
  s_pShader.setUniformsForBuiltins();
  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@s_tColor.r), 1);

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);

  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);
  glDrawArrays(GL_LINE_STRIP, 0, segments+additionalSegment);

  vertices := nil;
end;

procedure ccDrawCircle(const center: CCPoint; radius: Single; angle: Single; segments: Cardinal; drawLineToCenter: Boolean);
begin
  ccDrawCircle(center, radius, angle, segments, drawLineToCenter, 1.0, 1.0);
end;

procedure ccDrawQuadBezier(const origin: CCPoint; const control: CCPoint; const destination: CCPoint; segments: Cardinal);
var
  vertices: array of ccVertex2F;
  t: Single;
  i: Cardinal;
begin
  lazy_init();
  SetLength(vertices, segments+1);
  t := 0.0;

  for i := 0 to segments-1 do
  begin
    vertices[i].x := Power(1-t, 2) * origin.x + 2.0 * (1 - t) * t * control.x + t * t * destination.x;
    vertices[i].y := Power(1-t, 2) * origin.y + 2.0 * (1 - t) * t * control.y + t * t * destination.y;
    t := t + 1.0/segments;
  end;
  vertices[segments].x := destination.x;
  vertices[segments].y := destination.y;

  s_pShader.use();
  s_pShader.setUniformsForBuiltins();
  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@s_tColor.r), 1);

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);

  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);

  glDrawArrays(GL_LINE_STRIP, 0, segments + 1);

  vertices := nil;
end;

procedure ccDrawCubicBezier(const origin: CCPoint; const control1, control2: CCPoint; const destination: CCPoint; segments: Cardinal);
var
  vertices: array of ccVertex2F;
  t: Single;
  i: Cardinal;
begin
  lazy_init();

  SetLength(vertices, segments+1);

  t := 0;
  for i := 0 to segments-1 do
  begin
    vertices[i].x := Power(1-t, 3) * origin.x + 3.0 * Power(1-t, 2) * t * control1.x + 3.0 * (1 - t) * t * t * control2.x + t * t * t * destination.x;
    vertices[i].y := Power(1-t, 3) * origin.y + 3.0 * Power(1-t, 2) * t * control1.y + 3.0 * (1 - t) * t * t * control2.y + t * t * t * destination.y;
    t := t + 1.0/segments;
  end;
  vertices[segments].x := destination.x;
  vertices[segments].y := destination.y;

  s_pShader.use();
  s_pShader.setUniformsForBuiltins();
  s_pShader.setUniformLocationWith4fv(s_nColorLocation, PGLfloat(@s_tColor.r), 1);

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @vertices[0]);
  glDrawArrays(GL_LINE_STRIP, 0, segments+1);

  vertices := nil;
end;

//procedure ccDrawCatmullRom(arrayofControlPoints:);

// ccDrawCardinalSpline

procedure ccDrawColor4B(r, g, b, a: GLubyte);
begin
  s_tColor.r := r/255.0;
  s_tColor.g := g/255.0;
  s_tColor.b := b/255.0;
  s_tColor.a := a/255.0;
end;

procedure ccDrawColor4F(r, g, b, a: GLfloat);
begin
  s_tColor.r := r;
  s_tColor.g := g;
  s_tColor.b := b;
  s_tColor.a := a;
end;

procedure ccPointSize(pointSize: GLfloat);
begin
  s_fPointSize := pointSize * CC_CONTENT_SCALE_FACTOR();
end;  

end.
