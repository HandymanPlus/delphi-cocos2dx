unit utility;

interface

type
  kmScalar = Single;
  pkmScalar = ^kmScalar;
  kmBool = Boolean;
  kmEnum = Cardinal;
  kmGLEnum = Cardinal;

const
  kmPI = 3.141592;
  kmPIOver180 = 0.017453;
  kmPIUnder180 = 57.295779;
  kmEpsilon = 1.0/64.0;
  KM_FALSE = 0;
  KM_TRUE = 1;

type
  {$A-}
  kmVec2 = record
    x, y: kmScalar;
  end;
  {$A+}
  pkmVec2 = ^kmVec2;

  {$A-}
  kmVec3 = record
    x, y, z: kmScalar;
  end;
  {$A+}
  pkmVec3 = ^kmVec3;

  {$A-}
  kmVec4 = record
    x, y, z, w: kmScalar;
  end;
  {$A+}
  pkmVec4 = ^kmVec4;

  kmRay2 = record
    start, dir: kmVec2;
  end;
  pkmRay2 = ^kmRay2;

  kmMat3 = record
    mat: array [0..8] of kmScalar;
  end;
  pkmMat3 = ^kmMat3;
(*
A 4x4 matrix

        | 0   4   8  12 |
mat =   | 1   5   9  13 |
        | 2   6  10  14 |
        | 3   7  11  15 |
*)
  kmMat4 = record
    mat: array [0..15] of kmScalar;
  end;
  pkmMat4 = ^kmMat4;

  kmAABB = record
    min: kmVec3;
    max: kmVec3;
  end;
  pkmAABB = ^kmAABB;

const KM_PLANE_LEFT   = 0;
const KM_PLANE_RIGHT  = 1;
const KM_PLANE_BOTTOM = 2;
const KM_PLANE_TOP    = 3;
const KM_PLANE_NEAR   = 4;
const KM_PLANE_FAR    = 5;

type
  kmPlane = record
    a, b, c, d: kmScalar;
  end;
  pkmPlane = ^kmPlane;

  POINT_CLASSIFICATION =
  (
    POINT_INFRONT_OF_PLANE,
    POINT_BEHIND_PLANE,
    POINT_ON_PLANE
  );

function kmSQR(s: kmScalar): kmScalar;
function kmDegreesToRadians(degrees: kmScalar): kmScalar;
function kmRadiansToDegrees(radians: kmScalar): kmScalar;

function kmMin(lhs, rhs: kmScalar): kmScalar;
function kmMax(lhs, rhs: kmScalar): kmScalar;
function kmAlmostEqual(lhs, rhs: kmScalar): kmBool;

implementation
uses
  Math;

function kmSQR(s: kmScalar): kmScalar;
begin
  Result := s*s;
end;

function kmDegreesToRadians(degrees: kmScalar): kmScalar;
begin
  Result := degrees * kmPIOver180;
end;

function kmRadiansToDegrees(radians: kmScalar): kmScalar;
begin
  Result := radians * kmPIUnder180;
end;

function kmMin(lhs, rhs: kmScalar): kmScalar;
begin
  Result := IfThen(lhs < rhs, lhs, rhs);
end;

function kmMax(lhs, rhs: kmScalar): kmScalar;
begin
  Result := IfThen(lhs > rhs, lhs, rhs);
end;

function kmAlmostEqual(lhs, rhs: kmScalar): kmBool;
begin
  Result := ((lhs + kmEpsilon) > rhs)  and ((lhs - kmEpsilon) < rhs);
end;
 
end.
