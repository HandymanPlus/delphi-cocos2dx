unit vec3;

interface
uses
  utility;

function kmVec3Fill(pOut: pkmVec3; x, y, z: kmScalar): pkmVec3;
function kmVec3Length(const pIn: pkmVec3): kmScalar; //** Returns the length of the vector */
function kmVec3LengthSq(const pIn: pkmVec3): kmScalar; //** Returns the square of the length of the vector */
function kmVec3Normalize(pOut: pkmVec3; const pIn: pkmVec3): pkmVec3; //** Returns the vector passed in set to unit length */
function kmVec3Cross(pOut: pkmVec3; const pV1, pV2: pkmVec3): pkmVec3; //** Returns a vector perpendicular to 2 other vectors */
function kmVec3Dot(const pV1, pV2: pkmVec3): kmScalar; //** Returns the cosine of the angle between 2 vectors */
function kmVec3Add(pOut: pkmVec3; const pV1, pV2: pkmVec3): pkmVec3; //** Adds 2 vectors and returns the result */
function kmVec3Subtract(pOut: pkmVec3; const pV1, pV2: pkmVec3): pkmVec3; //** Subtracts 2 vectors and returns the result */
function kmVec3Transform(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3; //** Transforms a vector (assuming w=1) by a given matrix */
function kmVec3TransformNormal(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3;//**Transforms a 3D normal by a given matrix */
function kmVec3TransformCoord(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3; //**Transforms a 3D vector by a given matrix, projecting the result back into w = 1. */
function kmVec3Scale(pOut: pkmVec3; const pIn: pkmVec3; const s: kmScalar): pkmVec3; //** Scales a vector to length s */
function kmVec3AreEqual(const p1, p2: pkmVec3): Integer;
function kmVec3InverseTransform(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3;
function kmVec3InverseTransformNormal(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3;
function kmVec3Assign(pOut: pkmVec3; const pIn: pkmVec3): pkmVec3;
function kmVec3Zero(pOut: pkmVec3): pkmVec3;

implementation
uses
  vec4;

function kmVec3Fill(pOut: pkmVec3; x, y, z: kmScalar): pkmVec3;
begin
  pOut^.x := x;
  pOut^.y := y;
  pOut^.z := z;

  Result := pOut;
end;

function kmVec3Length(const pIn: pkmVec3): kmScalar; //** Returns the length of the vector */
begin
  Result := Sqrt(kmSQR(pIn^.x) + kmSQR(pIn^.y) + kmSQR(pIn^.z));
end;

function kmVec3LengthSq(const pIn: pkmVec3): kmScalar; //** Returns the square of the length of the vector */
begin
  Result := kmSQR(pIn^.x) + kmSQR(pIn^.y) + kmSQR(pIn^.z);
end;

function kmVec3Normalize(pOut: pkmVec3; const pIn: pkmVec3): pkmVec3; //** Returns the vector passed in set to unit length */
var
  l: kmScalar;
  v: kmVec3;
begin
  l := 1.0/kmVec3Length(pIn);

  v.x := pIn^.x * l;
  v.y := pIn^.y * l;
  v.z := pIn^.z * l;

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;

  Result := pOut;
end;

function kmVec3Cross(pOut: pkmVec3; const pV1, pV2: pkmVec3): pkmVec3; //** Returns a vector perpendicular to 2 other vectors */
var
  v: kmVec3;
begin
  v.x := (pV1.y * pV2.z) - (pV1.z * pV2.y);
  v.y := (pV1.z * pV2.x) - (pV1.x * pV2.z);
  v.z := (pV1.x * pV2.y) - (pV1.y * pV2.x);

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;

  Result := pOut;
end;

function kmVec3Dot(const pV1, pV2: pkmVec3): kmScalar; //** Returns the cosine of the angle between 2 vectors */
begin
  Result := pV1.x * pV2.x + pV1.y * pV2.y + pV1.z * pV2.z;
end;

function kmVec3Add(pOut: pkmVec3; const pV1, pV2: pkmVec3): pkmVec3; //** Adds 2 vectors and returns the result */
var
  v: kmVec3;
begin
  v.x := pV1.x + pV2.x;
  v.y := pV1.y + pV2.y;
  v.z := pV1.z + pV2.z;

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;

  Result := pOut;
end;

function kmVec3Subtract(pOut: pkmVec3; const pV1, pV2: pkmVec3): pkmVec3; //** Subtracts 2 vectors and returns the result */
var
  v: kmVec3;
begin
  v.x := pV1.x - pV2.x;
  v.y := pV1.y - pV2.y;
  v.z := pV1.z - pV2.z;

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;

  Result := pOut;
end;

function kmVec3Transform(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3; //** Transforms a vector (assuming w=1) by a given matrix */
var
  v: kmVec3;
begin
  v.x := pV^.x * pM^.mat[0] + pV^.y * pM^.mat[4] + pV^.z * pM^.mat[8] + pM.mat[12];
  v.y := pV^.x * pM^.mat[1] + pV^.y * pM^.mat[5] + pV^.z * pM^.mat[9] + pM.mat[13];
  v.z := pV^.x * pM^.mat[2] + pV^.y * pM^.mat[6] + pV^.z * pM^.mat[10] + pM.mat[14];

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;

  Result := pOut;
end;

function kmVec3TransformNormal(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3;//**Transforms a 3D normal by a given matrix */
var
  v: kmVec3;
begin
  v.x := pV^.x * pM^.mat[0] + pV^.y * pM^.mat[4] + pV.z * pM^.mat[8];
  v.y := pV^.x * pM^.mat[1] + pV^.y * pM^.mat[5] + pV.z * pM^.mat[9];
  v.z := pV^.x * pM^.mat[2] + pV^.y * pM^.mat[6] + pV.z * pM^.mat[10];

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;

  Result := pOut;
end;

function kmVec3TransformCoord(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3; //**Transforms a 3D vector by a given matrix, projecting the result back into w = 1. */
var
  v, inV: kmVec4;
begin
  kmVec4Fill(@inV, pV^.x, pV^.y, pV^.z, 1.0);
  kmVec4Transform(@v, @inV, pM);

  pOut^.x := v.x/v.w;
  pOut^.y := v.y/v.w;
  pOut^.z := v.z/v.w;

  Result := pOut;
end;  

function kmVec3Scale(pOut: pkmVec3; const pIn: pkmVec3; const s: kmScalar): pkmVec3; //** Scales a vector to length s */
begin
  pOut^.x := pIn^.x * s;
  pOut^.y := pIn^.y * s;
  pOut^.z := pIn^.z * s;

  Result := pOut;
end;

function kmVec3AreEqual(const p1, p2: pkmVec3): Integer;
var
  bRet: Boolean;
begin
  bRet :=
    (
        (p1^.x < p2^.x + kmEpsilon) and (p1^.x > p2^.x - kmEpsilon) and
        (p1^.y < p2^.y + kmEpsilon) and (p1^.y > p2^.y - kmEpsilon) and
        (p1^.z < p2^.z + kmEpsilon) and (p1^.z > p2^.z - kmEpsilon)
    );
  Result := Integer(bRet);
end;

function kmVec3InverseTransform(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3;
var
  v1, v2: kmVec3;
begin
  v1.x := pV^.x - pM^.mat[12];
  v1.y := pV^.y - pM^.mat[13];
  v1.z := pV^.z - pM^.mat[14];

  v2.x := v1.x * pM^.mat[0] + v1.y * pM.mat[1] + v1.z * pM.mat[2];
  v2.y := v1.x * pM^.mat[4] + v1.y * pM.mat[5] + v1.z * pM.mat[6];
  v2.z := v1.x * pM^.mat[8] + v1.y * pM.mat[9] + v1.z * pM.mat[10];

  pOut^.x := v2.x;
  pOut^.y := v2.y;
  pOut^.z := v2.z;

  Result := pOut;
end;

function kmVec3InverseTransformNormal(pOut: pkmVec3; const pV: pkmVec3; const pM: pkmMat4): pkmVec3;
var
  v: kmVec3;
begin
  v.x := pV^.x * pM.mat[0] + pV^.y * pM^.mat[1] + pV^.z * pM^.mat[2];
  v.y := pV^.x * pM.mat[4] + pV^.y * pM^.mat[5] + pV^.z * pM^.mat[6];
  v.z := pV^.x * pM.mat[8] + pV^.y * pM^.mat[9] + pV^.z * pM^.mat[10];

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;

  Result := pOut;
end;

function kmVec3Assign(pOut: pkmVec3; const pIn: pkmVec3): pkmVec3;
begin
  if pOut = pIn then
  begin
    Result := pOut;
    Exit;
  end;

  pOut^.x := pIn^.x;
  pOut^.y := pIn^.y;
  pOut^.z := pIn^.z;

  Result := pOut;
end;

function kmVec3Zero(pOut: pkmVec3): pkmVec3;
begin
  pOut^.x := 0.0;
  pOut^.y := 0.0;
  pOut^.z := 0.0;

  Result := pOut;
end;
  
end.
