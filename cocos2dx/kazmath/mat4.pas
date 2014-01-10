unit mat4;

interface
uses
  utility;

function kmMat4Fill(pOut: pkmMat4; const pMat: pkmScalar): pkmMat4;
function kmMat4Identity(pOut: pkmMat4): pkmMat4;
function kmMat4Inverse(pOut: pkmMat4; const pM: pkmMat4): pkmMat4;
function kmMat4IsIdentity(const pIn: pkmMat4): Integer;
function kmMat4Transpose(pOut: pkmMat4; const pIn: pkmMat4): pkmMat4;
function kmMat4Multiply(pOut: pkmMat4; const pM1, pM2: pkmMat4): pkmMat4;
function kmMat4Assign(pOut: pkmMat4; const pIn: pkmMat4): pkmMat4;
function kmMat4AreEqual(const pM1, pM2: pkmMat4): Integer;
function kmMat4RotationX(pOut: pkmMat4; const radians: kmScalar): pkmMat4;
function kmMat4RotationY(pOut: pkmMat4; const radians: kmScalar): pkmMat4;
function kmMat4RotationZ(pOut: pkmMat4; const radians: kmScalar): pkmMat4;
function kmMat4RotationPitchYawRoll(pOut: pkmMat4; const pitch, yaw, roll: kmScalar): pkmMat4;
//function kmMat4RotationQuaternion
function kmMat4RotationTranslation(pOut: pkmMat4; const rotation: pkmMat3; const translation: pkmVec3): pkmMat4;
function kmMat4Scaling(pOut: pkmMat4; const x, y, z: kmScalar): pkmMat4;
function kmMat4Translation(pOut: pkmMat4; const x, y, z: kmScalar): pkmMat4;
function kmMat4GetUpVec3(pOut: pkmVec3; const pIn: pkmMat4): pkmVec3;
function kmMat4GetRightVec3(pOut: pkmVec3; const pIn: pkmMat4): pkmVec3;
function kmMat4GetFowardVec3(pOut: pkmVec3; const pIn: pkmMat4): pkmVec3;
function kmMat4PerspectiveProjection(pOut: pkmMat4; fovY, aspect, zNear, zFar: kmScalar): pkmMat4;
function kmMat4OrthographicProjection(pOut: pkmMat4; left, right, bottom, top, nearVal, farVal: kmScalar): pkmMat4;
function kmMat4LookAt(pOut: pkmMat4; pEye, pCenter, pUp: pkmVec3): pkmMat4;
function kmMat4RotationAxisAngle(pOut: pkmMat4; const axis: pkmVec3; radians: kmScalar): pkmMat4;
function kmMat4ExtractRotation(pOut: pkmMat3; const pIn: pkmMat4): pkmMat3;
//function kmMat4ExtractPlane
function kmMat4RotationToAxisAngle(pAxis: pkmVec3; radians: pkmScalar; const pIn: pkmMat4): pkmVec3;


implementation
uses
  Math,
  vec3;

function get(const pIn: pkmMat4; row, col: Integer): Single;
begin
  Result := pIn^.mat[row + 4*col];
end;

procedure _set(pIn: pkmMat4; row, col: Integer; value: Single);
begin
  pIn^.mat[row + 4*col] := value;
end;

procedure swap(pIn: pkmMat4; r1, c1, r2, c2: Integer);
var
  tmp: Single;
begin
  tmp := get(pIn, r1, c1);
  _set(pIn, r1, c1, get(pIn, r2, c2));
  _set(pIn, r2, c2, tmp);
end;

function gaussj(a, b: pkmMat4): Integer;
var
  i, icol, irow, j, k, l, ll, n, m: Integer;
  big, dum, pivinv: Single;
  indxc, indxr, ipiv: array [0..3] of Integer;
begin
  icol := 0; irow := 0; n := 4; m := 4;

  for j := 0 to n-1 do
  begin
    indxc[j] := 0;
    indxr[j] := 0;
    ipiv[j] := 0;
  end;

  for i := 0 to n-1 do
  begin
    big := 0.0;
    for j := 0 to n-1 do
    begin
      if ipiv[j] <> 1 then
      begin
        for k := 0 to n-1 do
        begin
          if ipiv[k] = 0 then
          begin
            if Abs(get(a, j, k)) >= big then
            begin
              big := Floor(Abs(get(a, j, k)));
              irow := j;
              icol := k;
            end;
          end;
        end;
      end;
    end;
    Inc(ipiv[icol]);

    if irow <> icol then
    begin
      for l := 0 to n-1 do
        swap(a, irow, l, icol, l);
      for l := 0 to m-1 do
        swap(b, irow, l, icol, l);
    end;
    indxr[i] := irow;
    indxc[i] := icol;
    if get(a, icol, icol) = 0.0 then
    begin
      Result := KM_FALSE;
      Exit;
    end;
    pivinv := 1.0/get(a, icol, icol);
    _set(a, icol, icol, 1.0);
    for l := 0 to n-1 do
      _set(a, icol, l, get(a, icol, l)*pivinv);
    for l := 0 to m-1 do
      _set(b, icol, l, get(b, icol, l)*pivinv);

    for ll := 0 to n-1 do
    begin
      if ll <> icol then
      begin
        dum := get(a, ll, icol);
        _set(a, ll, icol, 0.0);
        for l := 0 to n-1 do
          _set(a, ll, l, get(a, ll, l) - get(a, icol, l) *dum );
        for l := 0 to m-1 do
          _set(b, ll, l, get(a, ll, l) - get(b, icol, l) * dum);
      end;  
    end;  
  end;

  for l := n-1 downto 0 do
  begin
    if indxr[l] <> indxc[l] then
    begin
      for k := 0 to n-1 do
        swap(a, k, indxr[l], k, indxc[l]);
    end;  
  end;

  Result := KM_TRUE;
end;

function kmMat4Fill(pOut: pkmMat4; const pMat: pkmScalar): pkmMat4;
begin
  Move(pMat^, pOut^.mat, SizeOf(kmScalar)*16);
  Result := pOut;
end;

function kmMat4Identity(pOut: pkmMat4): pkmMat4;
begin
  FillChar(pOut^.mat, SizeOf(Single)*16, 0);
  pOut^.mat[0] := 1.0;
  pOut^.mat[5] := 1.0;
  pOut^.mat[10] := 1.0;
  pOut^.mat[15] := 1.0;
  Result := pOut;
end;

function kmMat4Inverse(pOut: pkmMat4; const pM: pkmMat4): pkmMat4;
var
  inv, tmp: kmMat4;
begin
  kmMat4Assign(@inv, pM);
  kmMat4Identity(@tmp);
  if gaussj(@inv, @tmp) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  kmMat4Assign(pOut, @inv);
  Result := pOut;
end;

function kmMat4IsIdentity(const pIn: pkmMat4): Integer;
const
  identity: array [0..15] of Single =
  (
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
  );
var
  i: Integer;
begin
  for i := 0 to 15 do
    if pIn^.mat[i] <> identity[i] then
    begin
      Result := 0;
      Exit;
    end;
  Result := 1;
end;

function kmMat4Transpose(pOut: pkmMat4; const pIn: pkmMat4): pkmMat4;
var
  x, z: Integer;
begin
  for z := 0 to 3 do
    for x := 0 to 3 do
      pOut^.mat[z*4 + x] := pIn^.mat[x*4 + z];

  Result := pOut;
end;

function kmMat4Multiply(pOut: pkmMat4; const pM1, pM2: pkmMat4): pkmMat4;
var
  mat, m1, m2: array [0..15] of Single;
begin
  Move(pM1^.mat, m1, SizeOf(m1));
  Move(pM2^.mat, m2, SizeOf(m2));

  mat[0] := m1[0] * m2[0] + m1[4] * m2[1] + m1[8] * m2[2] + m1[12] * m2[3];
  mat[1] := m1[1] * m2[0] + m1[5] * m2[1] + m1[9] * m2[2] + m1[13] * m2[3];
  mat[2] := m1[2] * m2[0] + m1[6] * m2[1] + m1[10] * m2[2] + m1[14] * m2[3];
  mat[3] := m1[3] * m2[0] + m1[7] * m2[1] + m1[11] * m2[2] + m1[15] * m2[3];

  mat[4] := m1[0] * m2[4] + m1[4] * m2[5] + m1[8] * m2[6] + m1[12] * m2[7];
  mat[5] := m1[1] * m2[4] + m1[5] * m2[5] + m1[9] * m2[6] + m1[13] * m2[7];
  mat[6] := m1[2] * m2[4] + m1[6] * m2[5] + m1[10] * m2[6] + m1[14] * m2[7];
  mat[7] := m1[3] * m2[4] + m1[7] * m2[5] + m1[11] * m2[6] + m1[15] * m2[7];

  mat[8] := m1[0] * m2[8] + m1[4] * m2[9] + m1[8] * m2[10] + m1[12] * m2[11];
  mat[9] := m1[1] * m2[8] + m1[5] * m2[9] + m1[9] * m2[10] + m1[13] * m2[11];
  mat[10] := m1[2] * m2[8] + m1[6] * m2[9] + m1[10] * m2[10] + m1[14] * m2[11];
  mat[11] := m1[3] * m2[8] + m1[7] * m2[9] + m1[11] * m2[10] + m1[15] * m2[11];

  mat[12] := m1[0] * m2[12] + m1[4] * m2[13] + m1[8] * m2[14] + m1[12] * m2[15];
  mat[13] := m1[1] * m2[12] + m1[5] * m2[13] + m1[9] * m2[14] + m1[13] * m2[15];
  mat[14] := m1[2] * m2[12] + m1[6] * m2[13] + m1[10] * m2[14] + m1[14] * m2[15];
  mat[15] := m1[3] * m2[12] + m1[7] * m2[13] + m1[11] * m2[14] + m1[15] * m2[15];

  Move(mat, pOut^.mat, SizeOf(mat));
  Result := pOut;
end;

function kmMat4Assign(pOut: pkmMat4; const pIn: pkmMat4): pkmMat4;
begin
  Move(pIn^.mat, pOut^.mat, SizeOf(Single)*16);
  Result := pOut;
end;

function kmMat4AreEqual(const pM1, pM2: pkmMat4): Integer;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    if
    (((pM1^.mat[i] + kmEpsilon) > pM2^.mat[i]) and
    ((pM1^.mat[i] - kmEpsilon) < pM2^.mat[i])) then
    begin
      Result := Integer(KM_FALSE);
      Exit;
    end;
  end;
  Result := Integer(KM_TRUE);
end;

function kmMat4RotationX(pOut: pkmMat4; const radians: kmScalar): pkmMat4;
begin
    pOut^.mat[0] := 1.0;
    pOut^.mat[1] := 0.0;
    pOut^.mat[2] := 0.0;
    pOut^.mat[3] := 0.0;

    pOut^.mat[4] := 0.0;
    pOut^.mat[5] := Cos(radians);
    pOut^.mat[6] := Sin(radians);
    pOut^.mat[7] := 0.0;

    pOut^.mat[8] := 0.0;
    pOut^.mat[9] := -Sin(radians);
    pOut^.mat[10] := Cos(radians);
    pOut^.mat[11] := 0.0;

    pOut^.mat[12] := 0.0;
    pOut^.mat[13] := 0.0;
    pOut^.mat[14] := 0.0;
    pOut^.mat[15] := 1.0;

    Result := pOut;
end;

function kmMat4RotationY(pOut: pkmMat4; const radians: kmScalar): pkmMat4;
begin
    pOut^.mat[0] := Cos(radians);
    pOut^.mat[1] := 0.0;
    pOut^.mat[2] := -Sin(radians);
    pOut^.mat[3] := 0.0;

    pOut^.mat[4] := 0.0;
    pOut^.mat[5] := 1.0;
    pOut^.mat[6] := 0.0;
    pOut^.mat[7] := 0.0;

    pOut^.mat[8] := Sin(radians);
    pOut^.mat[9] := 0.0;
    pOut^.mat[10] := Cos(radians);
    pOut^.mat[11] := 0.0;

    pOut^.mat[12] := 0.0;
    pOut^.mat[13] := 0.0;
    pOut^.mat[14] := 0.0;
    pOut^.mat[15] := 1.0;

    Result := pOut;
end;

function kmMat4RotationZ(pOut: pkmMat4; const radians: kmScalar): pkmMat4;
begin
    pOut^.mat[0] := cos(radians);
    pOut^.mat[1] := sin(radians);
    pOut^.mat[2] := 0.0;
    pOut^.mat[3] := 0.0;

    pOut^.mat[4] := -sin(radians);;
    pOut^.mat[5] := cos(radians);
    pOut^.mat[6] := 0.0;
    pOut^.mat[7] := 0.0;

    pOut^.mat[8] := 0.0;
    pOut^.mat[9] := 0.0;
    pOut^.mat[10] := 1.0;
    pOut^.mat[11] := 0.0;

    pOut^.mat[12] := 0.0;
    pOut^.mat[13] := 0.0;
    pOut^.mat[14] := 0.0;
    pOut^.mat[15] := 1.0;

    Result := pOut;
end;

function kmMat4RotationPitchYawRoll(pOut: pkmMat4; const pitch, yaw, roll: kmScalar): pkmMat4;
var
  cr, sr, cp, sp, cy, sy, srsp, crsp: Double;
begin
  cr := Cos(pitch);
  sr := Sin(pitch);
  cp := Cos(yaw);
  sp := Sin(yaw);
  cy := Cos(roll);
  sy := Sin(roll);
  srsp := sr * sp;
  crsp := cr * sp;

    pOut^.mat[0] :=  cp * cy;
    pOut^.mat[4] :=  cp * sy;
    pOut^.mat[8] :=  - sp;

    pOut^.mat[1] :=  srsp * cy - cr * sy;
    pOut^.mat[5] :=  srsp * sy + cr * cy;
    pOut^.mat[9] :=  sr * cp;

    pOut^.mat[2] :=  crsp * cy + sr * sy;
    pOut^.mat[6] :=  crsp * sy - sr * cy;
    pOut^.mat[10] :=  cr * cp;

    pOut^.mat[3] := 0.0;
    pOut^.mat[7] := 0.0;
    pOut^.mat[11] := 0.0;
    pOut^.mat[15] := 1.0;

    Result := pOut;
end;

//function kmMat4RotationQuaternion
//begin

//end;

function kmMat4RotationTranslation(pOut: pkmMat4; const rotation: pkmMat3; const translation: pkmVec3): pkmMat4;
begin
    pOut^.mat[0] := rotation^.mat[0];
    pOut^.mat[1] := rotation^.mat[1];
    pOut^.mat[2] := rotation^.mat[2];
    pOut^.mat[3] := 0.0;

    pOut^.mat[4] := rotation^.mat[3];
    pOut^.mat[5] := rotation^.mat[4];
    pOut^.mat[6] := rotation^.mat[5];
    pOut^.mat[7] := 0.0;

    pOut^.mat[8] := rotation^.mat[6];
    pOut^.mat[9] := rotation^.mat[7];
    pOut^.mat[10] := rotation^.mat[8];
    pOut^.mat[11] := 0.0;

    pOut^.mat[12] := translation^.x;
    pOut^.mat[13] := translation^.y;
    pOut^.mat[14] := translation^.z;
    pOut^.mat[15] := 1.0;

    Result := pOut;
end;

function kmMat4Scaling(pOut: pkmMat4; const x, y, z: kmScalar): pkmMat4;
begin
  FillChar(pOut^.mat, SizeOf(Single)*16, 0);
  pOut^.mat[0] := x;
  pOut^.mat[5] := y;
  pOut^.mat[10] := z;
  pOut^.mat[15] := 1.0;

  Result := pOut;
end;

function kmMat4Translation(pOut: pkmMat4; const x, y, z: kmScalar): pkmMat4;
begin
  FillChar(pOut^.mat, SizeOf(Single)*16, 0);

  pOut^.mat[0] := 1.0;
  pOut^.mat[5] := 1.0;
  pOut^.mat[10] := 1.0;


  pOut^.mat[12] := x;
  pOut^.mat[13] := y;
  pOut^.mat[14] := z;
  pOut^.mat[15] := 1.0;


  Result := pOut;
end;

function kmMat4GetUpVec3(pOut: pkmVec3; const pIn: pkmMat4): pkmVec3;
begin
  pOut^.x := pIn^.mat[4];
  pOut^.y := pIn^.mat[5];
  pOut^.z := pIn^.mat[6];

  kmVec3Normalize(pOut, pOut);

  Result := pOut;
end;

function kmMat4GetRightVec3(pOut: pkmVec3; const pIn: pkmMat4): pkmVec3;
begin
  pOut^.x := pIn^.mat[0];
  pOut^.y := pIn^.mat[1];
  pOut^.z := pIn^.mat[2];

  kmVec3Normalize(pOut, pOut);

  Result := pOut;
end;

function kmMat4GetFowardVec3(pOut: pkmVec3; const pIn: pkmMat4): pkmVec3;
begin
  pOut^.x := pIn^.mat[8];
  pOut^.y := pIn^.mat[9];
  pOut^.z := pIn^.mat[10];

  kmVec3Normalize(pOut, pOut);

  Result := pOut;
end;

function kmMat4PerspectiveProjection(pOut: pkmMat4; fovY, aspect, zNear, zFar: kmScalar): pkmMat4;
var
  r, deltaZ, s, cotangent: kmScalar;
begin
  r := kmDegreesToRadians(fovY/2);
  deltaZ := zFar - zNear;
  s := Sin(r);

  if (deltaZ = 0) or (s = 0) or (aspect = 0) then
  begin
    Result := nil;
    Exit;
  end;

  cotangent := Cos(r)/s;

  kmMat4Identity(pOut);
  pOut^.mat[0] := cotangent/aspect;
  pOut^.mat[5] := cotangent;
  pOut^.mat[10] := -(zFar + zNear)/deltaZ;
  pOut^.mat[11] := -1;
  pOut^.mat[14] := -2*zNear*zFar/deltaZ;
  pOut^.mat[15] := 0;

  Result := pOut;
end;

function kmMat4OrthographicProjection(pOut: pkmMat4; left, right, bottom, top, nearVal, farVal: kmScalar): pkmMat4;
var
  tx, ty, tz: kmScalar;
begin
  tx := -((right + left)/(right - left));
  ty := -((top + bottom)/(top - bottom));
  tz := -((farVal + nearVal)/(farVal - nearVal));

  kmMat4Identity(pOut);
  pOut^.mat[0] := 2/(right - left);
  pOut^.mat[5] := 2/(top - bottom);
  pOut^.mat[10] := -2/(farVal - nearVal);
  pOut^.mat[12] := tx;
  pOut^.mat[13] := ty;
  pOut^.mat[14] := tz;

  Result := pOut;
end;

function kmMat4LookAt(pOut: pkmMat4; pEye, pCenter, pUp: pkmVec3): pkmMat4;
var
  f, up, s, u: kmVec3;
  translate: kmMat4;
begin
  kmVec3Subtract(@f, pCenter, pEye);
  kmVec3Normalize(@f, @f);

  kmVec3Assign(@up, pUp);
  kmVec3Normalize(@up, @up);

  kmVec3Cross(@s, @f, @up);
  kmVec3Normalize(@s, @s);

  kmVec3Cross(@u, @s, @f);
  kmVec3Normalize(@s, @s);

  kmMat4Identity(pOut);

  pOut^.mat[0]  := s.x;
  pOut^.mat[4]  := s.y;
  pOut^.mat[8]  := s.z;

  pOut^.mat[1]  := u.x;
  pOut^.mat[5]  := u.y;
  pOut^.mat[9]  := u.z;

  pOut^.mat[2]  := -f.x;
  pOut^.mat[6]  := -f.y;
  pOut^.mat[10] := -f.z;

  kmMat4Translation(@translate, -pEye^.x, -pEye^.y, -pEye^.z);
  kmMat4Multiply(pOut, pOut, @translate);

  Result := pOut;
end;

function kmMat4RotationAxisAngle(pOut: pkmMat4; const axis: pkmVec3; radians: kmScalar): pkmMat4;
var
  rcos, rsin: Single;
  normalizeAxis: kmVec3;
begin
  rcos := Cos(radians); rsin := Sin(radians);
  kmVec3Normalize(@normalizeAxis, axis);

  pOut^.mat[0] := rcos + normalizeAxis.x * normalizeAxis.x * (1 - rcos);
  pOut^.mat[1] := normalizeAxis.z * rsin + normalizeAxis.y * normalizeAxis.x * (1 - rcos);
  pOut^.mat[2] := -normalizeAxis.y * rsin + normalizeAxis.z * normalizeAxis.x * (1- rcos);
  pOut^.mat[3] := 0.0;

  pOut^.mat[4] := -normalizeAxis.z * rsin + normalizeAxis.x * normalizeAxis.y * (1 - rcos);
  pOut^.mat[5] := rcos + normalizeAxis.y * normalizeAxis.y * (1 - rcos);
  pOut^.mat[6] := normalizeAxis.x * rsin + normalizeAxis.z * normalizeAxis.y * (1 - rcos);
  pOut^.mat[7] := 0.0;

  pOut^.mat[8] := normalizeAxis.y * rsin + normalizeAxis.x * normalizeAxis.z * (1 - rcos);
  pOut^.mat[9] := -normalizeAxis.x * rsin + normalizeAxis.y * normalizeAxis.z * (1 - rcos);
  pOut^.mat[10] := rcos + normalizeAxis.z * normalizeAxis.z * (1 - rcos);
  pOut^.mat[11] := 0.0;

  pOut^.mat[12] := 0.0;
  pOut^.mat[13] := 0.0;
  pOut^.mat[14] := 0.0;
  pOut^.mat[15] := 0.0;

  Result := pOut;
end;

function kmMat4ExtractRotation(pOut: pkmMat3; const pIn: pkmMat4): pkmMat3;
begin
    pOut^.mat[0] := pIn^.mat[0];
    pOut^.mat[1] := pIn^.mat[1];
    pOut^.mat[2] := pIn^.mat[2];

    pOut^.mat[3] := pIn^.mat[4];
    pOut^.mat[4] := pIn^.mat[5];
    pOut^.mat[5] := pIn^.mat[6];

    pOut^.mat[6] := pIn^.mat[8];
    pOut^.mat[7] := pIn^.mat[9];
    pOut^.mat[8] := pIn^.mat[10];

    Result := pOut;
end;

//function kmMat4ExtractPlane

function kmMat4RotationToAxisAngle(pAxis: pkmVec3; radians: pkmScalar; const pIn: pkmMat4): pkmVec3;
//var
//  temp: kmQuaternion;
//  rotation: kmMat3;
begin
    //*Surely not this easy?*/
//    kmMat4ExtractRotation(@rotation, pIn);
//    kmQuaternionRotationMatrix(@temp, @rotation);
//    kmQuaternionToAxisAngle(@temp, pAxis, radians);
    Result := pAxis;
end;


end.
