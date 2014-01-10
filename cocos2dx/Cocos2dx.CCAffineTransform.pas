(****************************************************************************
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

unit Cocos2dx.CCAffineTransform;

interface
uses
  Cocos2dx.CCGeometry;

type
  CCAffineTransform = record
    a, b, c, d: Single;
    tx, ty: Single;
  end;
  PCCAffineTransform = ^CCAffineTransform;

function CCAffineTransformMake(a, b, c, d, tx, ty: Single): CCAffineTransform;
function CCPointApplyAffineTransform(const point: CCPoint; const t: CCAffineTransform): CCPoint;
function CCSizeApplyAffineTransform(const size: CCSize; const t: CCAffineTransform):CCSize;
function CCAffineTransformMakeIdentity(): CCAffineTransform;
function CCRectApplyAffineTransform(const rect: CCRect; anAffineTransform: CCAffineTransform): CCRect;
function CCAffineTransformTranslate(const t: CCAffineTransform; tx, ty: Single): CCAffineTransform;
function CCAffineTransformRotate(const t: CCAffineTransform; anAngle: Single): CCAffineTransform;
function CCAffineTransformScale(const t: CCAffineTransform; sx, sy: Single): CCAffineTransform;
function CCAffineTransformConcat(const t1, t2: CCAffineTransform): CCAffineTransform;
function CCAffineTransformEqualToTransform(const t1, t2: CCAffineTransform): Boolean;
function CCAffineTransformInvert(const t: CCAffineTransform): CCAffineTransform;

implementation
uses
  Math;

function CCAffineTransformMake(a, b, c, d, tx, ty: Single): CCAffineTransform;
var
  t: CCAffineTransform;
begin
  t.a := a;
  t.b := b;
  t.c := c;
  t.d := d;
  t.tx := tx;
  t.ty := ty;
  
  Result := t;
end;

function CCPointApplyAffineTransform(const point: CCPoint; const t: CCAffineTransform): CCPoint;
var
  p: CCPoint;
begin
  p.x := t.a*point.x + t.c*point.y + t.tx;
  p.y := t.b*point.x + t.d*point.y + t.ty;
  Result := p;
end;

function CCSizeApplyAffineTransform(const size: CCSize; const t: CCAffineTransform):CCSize;
var
  s: CCSize;
begin
  s.width := t.a*size.width + t.c*size.height;
  s.height := t.b*size.width + t.d*size.height;
  Result := s;
end;

function CCAffineTransformMakeIdentity(): CCAffineTransform;
begin
  Result := CCAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
end;

function CCRectApplyAffineTransform(const rect: CCRect; anAffineTransform: CCAffineTransform): CCRect;
var
  top, left, right, bottom: Single;
  topleft, topright, bottomleft, bottomright, tmpPoint: CCPoint;
  minX, maxX, minY, maxY: Single;
begin
  top := rect.GetMinY();
  left := rect.getMinX();
  right := rect.GetMaxX();
  bottom := rect.GetMaxY();

  tmpPoint := CCPointMake(left, top);
  topleft := CCPointApplyAffineTransform(tmpPoint, anAffineTransform);

  tmpPoint := CCPointMake(right, top);
  topright := CCPointApplyAffineTransform(tmpPoint, anAffineTransform);

  tmpPoint := CCPointMake(left, bottom);
  bottomleft := CCPointApplyAffineTransform(tmpPoint, anAffineTransform);

  tmpPoint := CCPointMake(right, bottom);
  bottomright := CCPointApplyAffineTransform(tmpPoint, anAffineTransform);

  minX := min(min(topLeft.x, topRight.x), min(bottomLeft.x, bottomRight.x));
  maxX := max(max(topLeft.x, topRight.x), max(bottomLeft.x, bottomRight.x));
  minY := min(min(topLeft.y, topRight.y), min(bottomLeft.y, bottomRight.y));
  maxY := max(max(topLeft.y, topRight.y), max(bottomLeft.y, bottomRight.y));

  Result.Create(minX, minY, maxX- minX, maxY - minY);
end;

function CCAffineTransformTranslate(const t: CCAffineTransform; tx, ty: Single): CCAffineTransform;
begin
  Result := CCAffineTransformMake(t.a, t.b, t.c, t.d, t.tx+t.a*tx+t.c*ty, t.ty+t.b*tx+t.d*ty);
end;

function CCAffineTransformRotate(const t: CCAffineTransform; anAngle: Single): CCAffineTransform;
var
  fSin, fCos: Single;
begin
  fSin := Sin(anAngle);
  fCos := Cos(anAngle);
  Result := CCAffineTransformMake(t.a*fCos + t.c*fSin,
    t.b*fCos + t.d*fSin,
    t.c*fCos - t.a*fSin,
    t.d*fCos - t.b*fSin,
    t.tx,
    t.ty);
end;

function CCAffineTransformScale(const t: CCAffineTransform; sx, sy: Single): CCAffineTransform;
begin
  Result := CCAffineTransformMake(t.a*sx, t.b*sx, t.c*sy, t.d*sy, t.tx, t.ty);
end;

(* Concatenate `t2' to `t1' and return the result:
     t' = t1 * t2 *)
function CCAffineTransformConcat(const t1, t2: CCAffineTransform): CCAffineTransform;
begin
  Result := CCAffineTransformMake(
    t1.a*t2.a + t1.b*t2.c, t1.a*t2.b + t1.b*t2.d,
    t1.c*t2.a + t1.d*t2.c, t1.c*t2.b + t1.d*t2.d,
    t1.tx*t2.a + t1.ty*t2.c + t2.tx,
    t1.tx*t2.b + t1.ty*t2.d + t2.ty);
end;

(* Return true if `t1' and `t2' are equal, false otherwise. *)
function CCAffineTransformEqualToTransform(const t1, t2: CCAffineTransform): Boolean;
begin
  Result := (t1.a = t2.a) and
            (t1.b = t2.b) and
            (t1.c = t2.c) and
            (t1.d = t2.d) and
            (t1.tx = t2.tx) and
            (t1.ty = t2.ty);
end;

function CCAffineTransformInvert(const t: CCAffineTransform): CCAffineTransform;
var
  determinant: Single;
begin
  determinant := 1/(t.a*t.d - t.b*t.c);
  Result := CCAffineTransformMake(determinant*t.d, -determinant*t.b,
    -determinant*t.c, determinant*t.a, determinant*(t.c*t.ty - t.d*t.tx),
    determinant*(t.b*t.tx - t.a*t.ty));
end;

end.
