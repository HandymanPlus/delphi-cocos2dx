(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2007      Scott Lembcke
Copyright (c) 2010      Lam Pham

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

(**
 @file
 CCPoint extensions based on Chipmunk's cpVect file.
 These extensions work both with CCPoint and cpVect.

 The "ccp" prefix means: "CoCos2d Point"

 Examples:
  - ccpAdd( ccp(1,1), ccp(2,2) ); // preferred cocos2d way
  - ccpAdd( CCPointMake(1,1), CCPointMake(2,2) ); // also ok but more verbose

  - cpvadd( cpv(1,1), cpv(2,2) ); // way of the chipmunk
  - ccpAdd( cpv(1,1), cpv(2,2) ); // mixing chipmunk and cocos2d (avoid)
  - cpvadd( CCPointMake(1,1), CCPointMake(2,2) ); // mixing chipmunk and CG (avoid)
 *)

unit Cocos2dx.CCPointExtension;

interface
uses
  Math, Cocos2dx.CCGeometry;

type
  TopFunc = function (x: Single): Single;

const kCCPointEpsilon: Single = 1.192092896E-5;

function ccp(x, y: Single): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpNeg(const v: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpAdd(const v1, v2: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpSub(const v1, v2: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpMult(const v: CCPoint; const s: Single): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpMidpoint(const v1, v2: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpDot(const v1, v2: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpCross(const v1, v2: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpPerp(const v: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpRPerp(const v: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpProject(const v1, v2: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpRotate(const v1, v2: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpUnrotate(const v1, v2: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpLengthSQ(const v: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpDistanceSQ(const p1, p2: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}

function ccpLength(const v: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpDistance(const v1, v2: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpNormalize(const v: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpForAngle(const a: Single): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpToAngle(const v: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function clampf(value, min_inclusive, max_inclusive: Single): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpClamp(const p, from, _to: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpFromSize(const s: CCSize): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpCompOp(const p: CCPoint; opFunc: TopFunc): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpLerp(const a, b: CCPoint; alpha: Single): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpFuzzyEqual(const a, b: CCPoint; variance: Single): Boolean; {$ifdef Inline} inline; {$ENDIF}
function ccpCompMult(const a, b: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpAngleSigned(const a, b: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpAngle(const a, b: CCPoint): Single; {$ifdef Inline} inline; {$ENDIF}
function ccpRotateByAngle(const v, pivot: CCPoint; angle: Single): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function ccpLineIntersect(const p1, p2, p3, p4: CCPoint; s, t: PSingle): Boolean; {$ifdef Inline} inline; {$ENDIF}
function ccpSegmentIntersect(const A, B, C, D: CCPoint): Boolean; {$ifdef Inline} inline; {$ENDIF}
function ccpIntersectPoint(const A, B, C, D: CCPoint): CCPoint; {$ifdef Inline} inline; {$ENDIF}

implementation

function ccp(x, y: Single): CCPoint;
begin
  Result := CCPointMake(x, y);
end;

function ccpNeg(const v: CCPoint): CCPoint;
begin
  Result := ccp(-v.x, -v.y);
end;

function ccpAdd(const v1, v2: CCPoint): CCPoint;
begin
  Result := ccp(v1.x+v2.x, v1.y+v2.y);
end;

function ccpSub(const v1, v2: CCPoint): CCPoint;
begin
  Result := ccp(v1.x-v2.x, v1.y-v2.y);
end;

function ccpMult(const v: CCPoint; const s: Single): CCPoint;
begin
  Result := ccp(v.x*s, v.y*s);
end;

function ccpMidpoint(const v1, v2: CCPoint): CCPoint;
begin
  Result := ccpMult(ccpAdd(v1, v2), 0.5);
end;

function ccpDot(const v1, v2: CCPoint): Single;
begin
  Result := v1.x*v2.x + v1.y*v2.y;
end;

function ccpCross(const v1, v2: CCPoint): Single;
begin
  Result := v1.x*v2.y - v1.y*v2.x;
end;

function ccpPerp(const v: CCPoint): CCPoint;
begin
  Result := ccp(-v.y, v.x);
end;

function ccpRPerp(const v: CCPoint): CCPoint;
begin
  Result := ccp(v.y, -v.x);
end;

function ccpProject(const v1, v2: CCPoint): CCPoint;
begin
  Result := ccpMult(v2, ccpDot(v1, v2)/ccpDot(v2, v2));
end;

function ccpRotate(const v1, v2: CCPoint): CCPoint;
begin
  Result := ccp(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y+v1.y*v2.x);
end;

function ccpUnrotate(const v1, v2: CCPoint): CCPoint;
begin
  Result := ccp(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x-v1.x*v2.y);
end;

function ccpLengthSQ(const v: CCPoint): Single;
begin
  Result := ccpDot(v, v);
end;

function ccpDistanceSQ(const p1, p2: CCPoint): Single;
begin
  Result := ccpLengthSQ(ccpSub(p1, p2));
end;

function ccpLength(const v: CCPoint): Single;
begin
  Result := Sqrt(ccpLengthSQ(v));
end;

function ccpDistance(const v1, v2: CCPoint): Single;
begin
  Result := ccpLength(ccpSub(v1, v2));
end;

function ccpNormalize(const v: CCPoint): CCPoint;
begin
  Result := ccpMult(v, 1.0/ccpLength(v));
end;

function ccpForAngle(const a: Single): CCPoint;
begin
  Result := ccp(Cos(a), Sin(a));
end;

function ccpToAngle(const v: CCPoint): Single;
begin
  Result := ArcTan2(v.y, v.x);
end;

function clampf(value, min_inclusive, max_inclusive: Single): Single;
var
  tmp: Single;
begin
  if min_inclusive > max_inclusive then
  begin
    tmp := min_inclusive;
    min_inclusive := max_inclusive;
    max_inclusive := tmp;
  end;

  if value < min_inclusive then
    Result := min_inclusive
  else
  begin
    if value < max_inclusive then
      Result := value
    else
      Result := max_inclusive;
  end;
end;

function ccpClamp(const p, from, _to: CCPoint): CCPoint;
begin
  Result := ccp(clampf(p.x, from.x, _to.x), clampf(p.y, from.y, _to.y));
end;

function ccpFromSize(const s: CCSize): CCPoint;
begin
  Result := ccp(s.width, s.height);
end;

function ccpCompOp(const p: CCPoint; opFunc: TopFunc): CCPoint;
begin
  Result := ccp(opFunc(p.x), opFunc(p.y));
end;

function ccpLerp(const a, b: CCPoint; alpha: Single): CCPoint;
begin
  Result := ccpAdd(ccpMult(a, 1.0-alpha), ccpMult(b, alpha));
end;

function ccpFuzzyEqual(const a, b: CCPoint; variance: Single): Boolean;
begin
  if (a.x - variance <= b.x) and (b.x <= a.x + variance) then
    if (a.y - variance <= b.y) and (b.y <= a.y + variance) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function ccpCompMult(const a, b: CCPoint): CCPoint;
begin
  Result := ccp(a.x*b.x, a.y*b.y);
end;

function ccpAngleSigned(const a, b: CCPoint): Single;
var
  a2, b2: CCPoint;
  angle: Single;
begin
  a2 := ccpNormalize(a);
  b2 := ccpNormalize(b);
  angle := ArcTan2(a2.x * b2.y - a2.y * b2.x, ccpDot(a2, b2));
  if IsZero(angle, kCCPointEpsilon) then
  begin
    Result := 0.0;
    Exit;
  end;
  Result := angle;
end;

function ccpAngle(const a, b: CCPoint): Single;
var
  angle: Single;
begin
  angle := ArcCos(ccpDot(ccpNormalize(a), ccpNormalize(b)));
  if IsZero(angle, kCCPointEpsilon) then
  begin
    Result := 0.0;
    Exit;
  end;
  Result := angle;
end;

function ccpRotateByAngle(const v, pivot: CCPoint; angle: Single): CCPoint;
var
  r: CCPoint;
  cosa, sina: Single;
  t: Single;
begin
  r := ccpSub(v, pivot);
  cosa := Cos(angle); sina := Sin(angle);
  t := r.x;
  r.x := t*cosa - r.y*sina + pivot.x;
  r.y := t*sina + r.y*cosa + pivot.y;
  Result := r;
end;

function ccpLineIntersect(const p1, p2, p3, p4: CCPoint; s, t: PSingle): Boolean;
var
  BAx, BAy, DCx, DCy, ACx, ACy: Single;
  denom: Single;
begin
  if ((p1.x = p2.x) and (p1.y = p2.y)) or ((p3.x = p4.x) and (p3.y = p4.y)) then
  begin
    Result := False;
    Exit;
  end;

  BAx := p2.x - p1.x;
  BAy := p2.y - p1.y;
  DCx := p4.x - p3.x;
  DCy := p4.y - p3.y;
  ACx := p1.x - p3.x;
  ACy := p1.y - p3.y;

  denom := DCy*BAx - DCx*BAy;
  S^ := DCx*ACy - DCy*ACx;
  T^ := BAx*ACy - BAy*ACx;

  if denom = 0.0 then
  begin
    if (S^ = 0) or (T^ = 0) then
    begin
      Result := True;
      Exit;
    end;
    Result := False;
    Exit;
  end;
  S^ := S^/denom;
  T^ := T^/denom;
  Result := True;
end;

function ccpSegmentIntersect(const A, B, C, D: CCPoint): Boolean;
var
  S, T: Single;
begin
  if ccpLineIntersect(A, B, C, D, @S, @T) and
     ((S >= 0.0) and (S <= 1.0) and (T >= 0.0) and (T <= 1.0)) then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;

function ccpIntersectPoint(const A, B, C, D: CCPoint): CCPoint;
var
  S, T: Single;
  p: CCPoint;
begin
  p := ccp(0.0, 0.0);
  if ccpLineIntersect(A, B, C, D, @S, @T) then
  begin
    p.x := A.x + S*(B.x - A.x);
    p.y := A.y + S*(B.y - A.y);
    Result := p;
    Exit;
  end;
  Result := p;
end;

end.
