unit vec2;

interface
uses
  utility;

function kmVec2Fill(pOut: pkmVec2; x, y: kmScalar): pkmVec2;
function kmVec2Length(const pIn: pkmVec2): kmScalar;
function kmVec2LengthSq(const pIn: pkmVec2): kmScalar;
function kmVec2Normalize(pOut, pIn: pkmVec2): pkmVec2;
function kmVec2Add(pOut: pkmVec2; const pV1, pV2: pkmVec2): pkmVec2;
function kmVec2Dot(const pV1, pV2: pkmVec2): kmScalar;
function kmVec2Subtract(pOut: pkmVec2; const pV1, pV2: pkmVec2): pkmVec2;
function kmVec2Transform(pOut: pkmVec2; const pV: pkmVec2; const pM: pkmMat3): pkmVec2;
function kmVec2TransformCoord(pOut: pkmVec2; const pV: pkmVec2; const pM: pkmMat3): pkmVec2;
function kmVec2Scale(pOut: pkmVec2; const pIn: pkmVec2; const s: kmScalar): pkmVec2;
function kmVec2AreEqual(const p1, p2: pkmVec2): Integer;

implementation

function kmVec2Fill(pOut: pkmVec2; x, y: kmScalar): pkmVec2;
begin
  pOut^.x := x;
  pOut^.y := y;
  Result := pOut;
end;

function kmVec2Length(const pIn: pkmVec2): kmScalar;
begin
  Result := Sqrt(kmSQR(pIn^.x) + kmSQR(pIn^.y));
end;

function kmVec2LengthSq(const pIn: pkmVec2): kmScalar;
begin
  Result := kmSQR(pIn^.x) + kmSQR(pIn^.y);
end;

function kmVec2Normalize(pOut, pIn: pkmVec2): pkmVec2;
var
  l: kmScalar;
  v: kmVec2;
begin
  l := 1.0/kmVec2Length(pIn);

  v.x := pIn^.x * l;
  v.y := pIn^.y * l;

  pOut^.x := v.x;
  pOut^.y := v.y;

  Result := pOut;
end;

function kmVec2Add(pOut: pkmVec2; const pV1, pV2: pkmVec2): pkmVec2;
begin
  pOut^.x := pV1^.x + pV2^.x;
  pOut^.y := pV1^.y + pV2^.y;

  Result := pOut;
end;

function kmVec2Dot(const pV1, pV2: pkmVec2): kmScalar;
begin
  Result := pV1^.x * pV2.x + pV1.y * pV2.y;
end;

function kmVec2Subtract(pOut: pkmVec2; const pV1, pV2: pkmVec2): pkmVec2;
begin
  pOut^.x := pV1^.x - pV2^.x;
  pOut^.y := pV1^.y- pV2^.y;

  Result := pOut;
end;

function kmVec2Scale(pOut: pkmVec2; const pIn: pkmVec2; const s: kmScalar): pkmVec2;
begin
  pOut^.x := pIn^.x * s;
  pOut^.y := pIn^.y * s;
  
  Result := pOut;
end;

function kmVec2Transform(pOut: pkmVec2; const pV: pkmVec2; const pM: pkmMat3): pkmVec2;
var
  v: kmVec2;
begin
  v.x := pV^.x * pM^.mat[0] + pV^.y * pM^.mat[3] + pM^.mat[6];
  v.x := pV^.x * pM^.mat[1] + pV^.y * pM^.mat[4] + pM^.mat[7];

  pOut^.x := v.x;
  pOut^.y := v.y;

  Result := pOut;
end;
  
function kmVec2TransformCoord(pOut: pkmVec2; const pV: pkmVec2; const pM: pkmMat3): pkmVec2;
begin
  Result := nil;
end;

function kmVec2AreEqual(const p1, p2: pkmVec2): Integer;
begin
  {.$MESSAGE 'no implementation'}
  Result := 0;
end;

end.
