unit vec4;

interface
uses
  utility;

function kmVec4Fill(pOut: pkmVec4; x, y, z, w: kmScalar): pkmVec4;
function kmVec4Add(pOut: pkmVec4;const pV1, pV2: pkmVec4): pkmVec4;
function kmVec4Dot(const pV1, pV2: pkmVec4): kmScalar;
function kmVec4Length(const pIn: pkmVec4): kmScalar;
function kmVec4LengthSq(const pIn: pkmVec4): kmScalar;
function kmVec4Lerp(pOut: pkmVec4; const pV1, pV2: pkmVec4; const s: kmScalar): pkmVec4;
function kmVec4Normalize(pOut: pkmVec4; const pIn: pkmVec4): pkmVec4;
function kmVec4Scale(pOut: pkmVec4; const pIn: pkmVec4; const s: kmScalar): pkmVec4;
function kmVec4Subtract(pOut: pkmVec4; const pV1, pV2: pkmVec4): pkmVec4;

function kmVec4Transform(pOut: pkmVec4; const pV: pkmVec4; const pM: pkmMat4): pkmVec4;
function kmVec4TransformArray(pOut: pkmVec4; outStride: Cardinal; const pV: pkmVec4; vStride: Cardinal;
  const pM: pkmMat4; count: Cardinal): pkmVec4;

function kmVec4AreEqual(const p1, p2: pkmVec4): Integer;
function kmVec4Assign(pOut: pkmVec4; const pIn: pkmVec4): pkmVec4;

implementation

function kmVec4Fill(pOut: pkmVec4; x, y, z, w: kmScalar): pkmVec4;
begin
  pOut^.x := x;
  pOut^.y := y;
  pOut^.z := z;
  pOut^.w := w;

  Result := pOut;
end;

function kmVec4Add(pOut: pkmVec4;const pV1, pV2: pkmVec4): pkmVec4;
begin
  pOut^.x := pV1^.x + pV2^.x;
  pOut^.y := pV1^.y + pV2^.y;
  pOut^.z := pV1^.z + pV2^.z;
  pOut^.w := pV1^.w + pV2^.w;

  Result := pOut;
end;

function kmVec4Dot(const pV1, pV2: pkmVec4): kmScalar;
begin
  Result := pV1.x * pV2.x +
            pV1.y * pV2.y +
            pV1.z * pV2.z +
            pV1.w * pV2.w;
end;

function kmVec4Length(const pIn: pkmVec4): kmScalar;
begin
  Result := Sqrt(kmSQR(pIn^.x) + kmSQR(pIn^.y) + kmSQR(pIn^.z) + kmSQR(pIn^.w));
end;

function kmVec4LengthSq(const pIn: pkmVec4): kmScalar;
begin
  Result := kmSQR(pIn^.x) + kmSQR(pIn^.y) + kmSQR(pIn^.z) + kmSQR(pIn^.w);
end;

function kmVec4Lerp(pOut: pkmVec4; const pV1, pV2: pkmVec4; const s: kmScalar): pkmVec4;
begin
  Result := pOut;
end;

function kmVec4Normalize(pOut: pkmVec4; const pIn: pkmVec4): pkmVec4;
var
  l: kmScalar;
  v: kmVec4;
begin
  l := 1.0/kmVec4Length(pIn);

  v.x := pIn^.x * l;
  v.y := pIn^.y * l;
  v.z := pIn^.z * l;
  v.w := pIn^.w * l;

  pOut^.x := v.x;
  pOut^.y := v.y;
  pOut^.z := v.z;
  pOut^.w := v.w;

  Result := pOut;
end;

function kmVec4Scale(pOut: pkmVec4; const pIn: pkmVec4; const s: kmScalar): pkmVec4;
begin
  kmVec4Normalize(pOut, pIn);

  pOut^.x := pOut^.x * s;
  pOut^.y := pOut^.y * s;
  pOut^.z := pOut^.z * s;
  pOut^.w := pOut^.w * s;

  Result := pOut;
end;

function kmVec4Subtract(pOut: pkmVec4; const pV1, pV2: pkmVec4): pkmVec4;
begin
  pOut^.x := pV1^.x - pV2^.x;
  pOut^.y := pV1^.y - pV2^.y;
  pOut^.z := pV1^.z - pV2^.z;
  pOut^.w := pV1^.w - pV2^.w;

  Result := pOut;
end;

function kmVec4Transform(pOut: pkmVec4; const pV: pkmVec4; const pM: pkmMat4): pkmVec4;
begin
  pOut^.x := pV^.x * pM^.mat[0] + pV^.y * pM^.mat[4] + pV^.z * pM^.mat[8] + pV^.w * pM^.mat[12];
  pOut^.y := pV^.x * pM^.mat[1] + pV^.y * pM^.mat[5] + pV^.z * pM^.mat[9] + pV^.w * pM^.mat[13];
  pOut^.z := pV^.x * pM^.mat[2] + pV^.y * pM^.mat[6] + pV^.z * pM^.mat[10] + pV^.w * pM^.mat[14];
  pOut^.w := pV^.x * pM^.mat[3] + pV^.y * pM^.mat[7] + pV^.z * pM^.mat[11] + pV^.w * pM^.mat[15];

  Result := pOut;
end;
  
function kmVec4TransformArray(pOut: pkmVec4; outStride: Cardinal; const pV: pkmVec4; vStride: Cardinal;
  const pM: pkmMat4; count: Cardinal): pkmVec4;
var
  i: Cardinal;
  _In, _Out: pkmVec4;
begin
  i := 0;
  while i < count do
  begin
    _In := pkmVec4(Cardinal(pV) + (i * vStride) * SizeOf(kmVec4));
    _Out := pkmVec4(Cardinal(pOut) + (i * outStride) * SizeOf(kmVec4));
    kmVec4Transform(_Out, _In, pM);
    Inc(i);
  end;
  Result := pOut;
end;

function kmVec4AreEqual(const p1, p2: pkmVec4): Integer;
var
  bRet: Boolean;
begin
  bRet :=
    (
        (p1^.x < p2^.x + kmEpsilon) and (p1^.x > p2^.x - kmEpsilon) and
        (p1^.y < p2^.y + kmEpsilon) and (p1^.y > p2^.y - kmEpsilon) and
        (p1^.z < p2^.z + kmEpsilon) and (p1^.z > p2^.z - kmEpsilon) and
        (p1^.w < p2^.w + kmEpsilon) and (p1^.w > p2^.w - kmEpsilon)
    );
  Result := Integer(bRet);
end;

function kmVec4Assign(pOut: pkmVec4; const pIn: pkmVec4): pkmVec4;
begin
  Move(pIn^, pOut^, SizeOf(Single)*4);
  Result := pOut;
end;

end.
