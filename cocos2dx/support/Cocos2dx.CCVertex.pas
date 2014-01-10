(****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2011 ForzeField Studios S.L

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

unit Cocos2dx.CCVertex;

interface
uses
  Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

//** converts a line to a polygon */
procedure ccVertexLineToPolygon(points: ptCCPoint; stroke: Single; vertices: ptccVertex2F; offset: Cardinal; nuPoints: Cardinal);
//** returns whether or not the line intersects */
function ccVertexLineIntersect(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy: Single; var T: Single): Boolean;

implementation
uses
  Math,
  Cocos2dx.CCPointExtension, Cocos2dx.CCMacros;

procedure ccVertexLineToPolygon(points: ptCCPoint; stroke: Single; vertices: ptccVertex2F; offset: Cardinal; nuPoints: Cardinal);
var
  idx, nuPointsMinus, i: Cardinal;
  p1, perpVerctor, p0, p2, p2p1, p0p1: CCPoint;
  angle: Single;
  idx1: Cardinal;
  s: Single;
  fixVertex: Boolean;
  v1, v2, v3, v4: ccVertex2F;
begin
  nuPoints := nuPoints + offset;
  if nuPoints <= 1 then
    Exit;

  stroke := stroke * 0.5;
  nuPointsMinus := nuPoints - 1;

  if nuPoints > 0 then
    for i := offset to nuPoints-1 do
    begin
      idx := i * 2;
      p1 := points[i];

      if i = 0 then
        perpVerctor := ccpPerp(ccpNormalize(ccpSub(p1, points[i + 1])))
      else if i = nuPointsMinus then
        perpVerctor := ccpPerp(ccpNormalize(ccpSub(points[i - 1], p1)))
      else
      begin
        p2 := points[i + 1];
        p0 := points[i - 1];

        p2p1 := ccpNormalize(ccpSub(p2, p1));
        p0p1 := ccpNormalize(ccpSub(p0, p1));

        angle := ArcCos(ccpDot(p2p1, p0p1));

        if angle < CC_DEGREES_TO_RADIANS(70) then
          perpVerctor := ccpPerp(ccpNormalize(ccpMidpoint(p2p1, p0p1)))
        else if angle < CC_DEGREES_TO_RADIANS(170) then
          perpVerctor := ccpNormalize(ccpMidpoint(p2p1, p0p1))
        else
          perpVerctor := ccpPerp(ccpNormalize(ccpSub(p2, p0)));
      end;
      perpVerctor := ccpMult(perpVerctor, stroke);

      vertices[idx] := vertex2(p1.x + perpVerctor.x, p1.y + perpVerctor.y);
      vertices[idx + 1] := vertex2(p1.x - perpVerctor.x, p1.y - perpVerctor.y);
    end;

  if offset <> 0 then
    offset := offset - 1;

  if nuPointsMinus > 0 then
    for i := offset to nuPointsMinus-1 do
    begin
      idx := i * 2;
      idx1 := idx + 2;

      v1 := vertices[idx];
      v2 := vertices[idx + 1];
      v3 := vertices[idx1];
      v4 := vertices[idx1 + 1];

      fixVertex := not ccVertexLineIntersect(v1.x, v1.y, v4.x, v4.y, v2.x, v2.y, v3.x, v3.y, s);
      if not fixVertex then
      begin
        if (s < 0.0) or (s > 1.0) then
          fixVertex := True
      end;

      if fixVertex then
      begin
        vertices[idx1] := v4;
        vertices[idx1 + 1] := v3;
      end;  
    end;  
end;
  
function ccVertexLineIntersect(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy: Single; var T: Single): Boolean;
var
  distAB, theCos, theSin, newX: Single;
begin
  if ((Ax = Bx) and (Ay = By)) or ((Cx = Dx) and (Cy = Dy)) then
  begin
    Result := False;
    Exit;
  end;

  Bx := Bx - Ax; By := By - Ay;
  Cx := Cx - Ax; Cy := Cy - Ay;
  Dx := Dx - Ax; Dy := Dy - Ay;

  distAB := Sqrt(Bx*Bx + By*By);

  theCos := Bx/distAB;
  theSin := By/distAB;

  newX := Cx*theCos + Cy*theSin;
  Cy := Cy*theCos - Cx*theSin; Cx := newX;
  newX := Dx*theCos + Dy*theSin;
  Dy := Dy*theCos - Dx*theSin; Dx := newX;

  if Cy = Dy then
  begin
    Result := False;
    Exit;
  end;

  T := (Dx + (Cx - Dx)/(Dy - Cy))/distAB;

  Result := True;
end;

end.
