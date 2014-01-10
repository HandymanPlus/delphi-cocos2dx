unit mat3;

interface
uses
  utility;

function kmMat3Fill(pOut: pkmMat3; const pMat: pkmScalar): pkmMat3;
function kmMat3Adjugate(pOut: pkmMat3; const pIn: pkmMat3): pkmMat3;
function kmMat3Identity(pOut: pkmMat3): pkmMat3;
function kmMat3Inverse(pOut: pkmMat3; const pDeterminate: kmScalar; const pM: pkmMat3): pkmMat3;
function kmMat3IsIdentity(const pIn: pkmMat3): Integer;
function kmMat3Transpose(pOut: pkmMat3; const pIn: pkmMat3): pkmMat3;
function kmMat3Determinant(const pIn: pkmMat3): kmScalar;
function kmMat3Multiply(pOut: pkmMat3; const pM1, pM2: pkmMat3): pkmMat3;
function kmMat3ScalarMultiply(pOut: pkmMat3; const pM: pkmMat3; const pFactor: kmScalar): pkmMat3;
function kmMat3RotationAxisAngle(pOut: pkmMat3; const axis: pkmVec3; radians: kmScalar): pkmMat3;
function kmMat3RotationToAxisAngle(pAxis: pkmVec3; radians: pkmScalar; const pIn: pkmMat3): pkmVec3;
function kmMat3Assign(pOut: pkmMat3; const pIn: pkmMat3): pkmMat3;
function kmMat3AreEqual(const pM1, pM2: pkmMat3): Integer;
function kmMat3RotationX(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
function kmMat3RotationY(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
function kmMat3RotationZ(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
function kmMat3Rotation(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
function kmMat3Scaling(pOut: pkmMat3; const x, y: kmScalar): pkmMat3;
function kmMat3Translation(pOut: pkmMat3; const x, y: kmScalar): pkmMat3;
//function kmMat3RotationQuaternion(pOut: pkmMat3; const pIn:): pkmMat3;

implementation

function kmMat3Fill(pOut: pkmMat3; const pMat: pkmScalar): pkmMat3;
begin
  Move(pMat^, pOut^, SizeOf(kmScalar)*9);
  Result := pOut;
end;

function kmMat3Adjugate(pOut: pkmMat3; const pIn: pkmMat3): pkmMat3;
begin
  pOut^.mat[0] := pIn^.mat[4] * pIn^.mat[8] - pIn^.mat[5] * pIn^.mat[7];
  pOut^.mat[1] := pIn^.mat[2] * pIn^.mat[7] - pIn^.mat[1] * pIn^.mat[8];
  pOut^.mat[2] := pIn^.mat[1] * pIn^.mat[5] - pIn^.mat[2] * pIn^.mat[4];
  pOut^.mat[3] := pIn^.mat[5] * pIn^.mat[6] - pIn^.mat[3] * pIn^.mat[8];
  pOut^.mat[4] := pIn^.mat[0] * pIn^.mat[8] - pIn^.mat[2] * pIn^.mat[6];
  pOut^.mat[5] := pIn^.mat[2] * pIn^.mat[3] - pIn^.mat[0] * pIn^.mat[5];
  pOut^.mat[6] := pIn^.mat[3] * pIn^.mat[7] - pIn^.mat[4] * pIn^.mat[6];

  pOut^.mat[8] := pIn^.mat[0] * pIn^.mat[4] - pIn.mat[1] * pIn.mat[3];

  Result := pOut;
end;

function kmMat3Identity(pOut: pkmMat3): pkmMat3;
begin
  FillChar(pOut^.mat, 0, SizeOf(Single)*9);
  pOut^.mat[0] := 1.0;
  pOut^.mat[4] := 1.0;
  pOut^.mat[8] := 1.0;

  Result := pOut;
end;

function kmMat3Inverse(pOut: pkmMat3; const pDeterminate: kmScalar; const pM: pkmMat3): pkmMat3;
var
  detInv: kmScalar;
  adjugate: kmMat3;
begin
  if pDeterminate = 0.0 then
  begin
    Result := nil;
    Exit;
  end;

  detInv := 1.0/pDeterminate;
  kmMat3Adjugate(@adjugate, pM);
  kmMat3ScalarMultiply(pOut, @adjugate, detInv);

  Result := pOut;
end;

function kmMat3IsIdentity(const pIn: pkmMat3): Integer;
const identity: array [0..8] of Single = (1.0, 0.0, 0.0,
                                          0.0, 1.0, 0.0,
                                          0.0, 0.0, 1.0);
var
  i: Integer;
begin
  for i := 0 to 8 do
  begin
    if pIn^.mat[i] <> identity[i] then
    begin
      Result := 0;
      Exit;
    end;
  end;
  Result := 1;
end;

function kmMat3Transpose(pOut: pkmMat3; const pIn: pkmMat3): pkmMat3;
var
  x, z: Integer;
begin
  for z := 0 to 2 do
  begin
    for x := 0 to 2 do
      pOut^.mat[z*3 + x] := pIn^.mat[x*3 + z];
  end;
  Result := pOut;
end;

function kmMat3Determinant(const pIn: pkmMat3): kmScalar;
var
  output: kmScalar;
begin
  output := pIn^.mat[0] * pIn^.mat[4] * pIn^.mat[8] +pIn^.mat[1] * pIn^.mat[5] * pIn^.mat[6] +
    pIn^.mat[2] * pIn^.mat[3] * pIn^.mat[7];
  output := output - (pIn^.mat[2] * pIn^.mat[4] * pIn^.mat[6] +pIn^.mat[0] * pIn^.mat[5] * pIn^.mat[7] +
    pIn^.mat[1] * pIn^.mat[3] * pIn^.mat[8]);
  Result := output;
end;

function kmMat3Multiply(pOut: pkmMat3; const pM1, pM2: pkmMat3): pkmMat3;
var
  mat, m1, m2: array [0..8] of Single;
begin
  Move(pM1^.mat, m1, SizeOf(m1));
  Move(pM2^.mat, m2, SizeOf(m2));

  mat[0] := m1[0] * m2[0] + m1[3] * m2[1] + m1[6] * m2[2];
  mat[1] := m1[1] * m2[0] + m1[4] * m2[1] + m1[7] * m2[2];
  mat[2] := m1[2] * m2[0] + m1[5] * m2[1] + m1[8] * m2[2];

  mat[3] := m1[0] * m2[3] + m1[3] * m2[4] + m1[6] * m2[5];
  mat[4] := m1[1] * m2[3] + m1[4] * m2[4] + m1[7] * m2[5];
  mat[5] := m1[2] * m2[3] + m1[5] * m2[4] + m1[8] * m2[5];

  mat[6] := m1[0] * m2[6] + m1[3] * m2[7] + m1[6] * m2[8];
  mat[7] := m1[1] * m2[6] + m1[4] * m2[7] + m1[7] * m2[8];
  mat[8] := m1[2] * m2[6] + m1[5] * m2[7] + m1[8] * m2[8];

  Move(mat, pOut^.mat, SizeOf(mat));

  Result := pOut;
end;

function kmMat3ScalarMultiply(pOut: pkmMat3; const pM: pkmMat3; const pFactor: kmScalar): pkmMat3;
var
  mat: array [0..8] of Single;
  i: Integer;
begin
  for i := 0 to 8 do
    mat[i] := pM^.mat[i] * pFactor;
  Move(mat, pOut^.mat, SizeOf(mat));

  Result := pOut;
end;

function kmMat3RotationAxisAngle(pOut: pkmMat3; const axis: pkmVec3; radians: kmScalar): pkmMat3;
var
  rcos, rsin: Single;
begin
  rcos := Cos(radians);
  rsin := Sin(radians);
  pOut^.mat[0] := rcos + axis^.x * axis^.x * (1 - rcos);
  pOut^.mat[1] := axis^.z * rsin + axis^.y * axis^.x * (1 - rcos);
  pOut^.mat[2] := -axis^.y * rsin + axis^.z * axis^.x * (1 - rcos);

  pOut^.mat[3] := -axis^.z * rsin + axis^.x * axis^.y * (1 - rcos);
  pOut^.mat[4] := rcos + axis^.y * axis^.y * (1 - rcos);
  pOut^.mat[5] := axis^.x * rsin + axis^.z * axis^.y * (1 - rcos);

  pOut^.mat[6] := axis^.y * rsin + axis^.x * axis^.z * (1 - rcos);
  pOut^.mat[7] := -axis^.x * rsin + axis^.y * axis^.z * (1 - rcos);
  pOut^.mat[8] := rcos + axis^.z * axis^.z * (1 - rcos);

  Result := pOut;
end;

function kmMat3RotationToAxisAngle(pAxis: pkmVec3; radians: pkmScalar; const pIn: pkmMat3): pkmVec3;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function kmMat3Assign(pOut: pkmMat3; const pIn: pkmMat3): pkmMat3;
begin
  Move(pIn^.mat, pOut^.mat, SizeOf(Single)*9);
  Result := pOut;
end;

function kmMat3AreEqual(const pM1, pM2: pkmMat3): Integer;
var
  i: Integer;
begin
  if pM1 = pM2 then
  begin
    Result := Integer(KM_TRUE);
    Exit;
  end;

  for i := 0 to 8 do
  begin
    if
    ((pM1^.mat[i] + kmEpsilon) > pM2^.mat[i]) and
    ((pM1^.mat[i] - kmEpsilon) < pM2^.mat[i]) then
    begin
      Result := Integer(KM_FALSE);
      Exit;
    end;
  end;

  Result := Integer(KM_TRUE);
end;

function kmMat3RotationX(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
begin
  pOut^.mat[0] := 1.0;
  pOut^.mat[1] := 0.0;
  pOut^.mat[2] := 0.0;

  pOut^.mat[3] := 0.0;
  pOut^.mat[4] := Cos(radians);
  pOut^.mat[5] := Sin(radians);

  pOut^.mat[6] := 0.0;
  pOut^.mat[7] := -Sin(radians);
  pOut^.mat[8] := Cos(radians);

  Result := pOut;
end;

function kmMat3RotationY(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
begin
  pOut^.mat[0] := Cos(radians);
  pOut^.mat[1] := 0.0;
  pOut^.mat[2] := -Sin(radians);

  pOut^.mat[3] := 0.0;
  pOut^.mat[4] := 1.0;
  pOut^.mat[5] := 0.0;

  pOut^.mat[6] := Sin(radians);
  pOut^.mat[7] := 0.0;
  pOut^.mat[8] := Cos(radians);

  Result := pOut;
end;

function kmMat3RotationZ(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
begin
  pOut^.mat[0] := Cos(radians);
  pOut^.mat[1] := -Sin(radians);
  pOut^.mat[2] := 0.0;

  pOut^.mat[3] := Sin(radians);
  pOut^.mat[4] := Cos(radians);
  pOut^.mat[5] := 0.0;

  pOut^.mat[6] := 0.0;
  pOut^.mat[7] := 0.0;
  pOut^.mat[8] := 1.0;

  Result := pOut;
end;

function kmMat3Rotation(pOut: pkmMat3; const radians: kmScalar): pkmMat3;
begin
  pOut^.mat[0] := Cos(radians);
  pOut^.mat[1] := Sin(radians);
  pOut^.mat[2] := 0.0;

  pOut^.mat[3] := -Sin(radians);
  pOut^.mat[4] := Cos(radians);
  pOut^.mat[5] := 0.0;

  pOut^.mat[6] := 0.0;
  pOut^.mat[7] := 0.0;
  pOut^.mat[8] := 1.0;

  Result := pOut;
end;

function kmMat3Scaling(pOut: pkmMat3; const x, y: kmScalar): pkmMat3;
begin
  kmMat3Identity(pOut);
  pOut^.mat[0] := x;
  pOut^.mat[4] := y;

  Result := pOut;
end;

function kmMat3Translation(pOut: pkmMat3; const x, y: kmScalar): pkmMat3;
begin
  kmMat3Identity(pOut);
  pOut^.mat[6] := x;
  pOut^.mat[7] := y;

  Result := pOut;
end;

//function kmMat3RotationQuaternion(pOut: pkmMat3; const pIn:): pkmMat3;


end.
