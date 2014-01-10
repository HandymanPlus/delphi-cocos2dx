unit ray2;

interface
uses
  utility;

procedure kmRay2Fill(ray: pkmRay2; px, py, vx, vy: kmScalar);
function kmRay2IntersectLineSegment(const ray: kmRay2; const p1, p2: pkmVec2; intersection: pkmVec2): kmBool;
function kmRay2IntersectTriangle(const ray: pkmRay2; const p1, p2, p3: pkmVec2; intersection: pkmVec2; normal_out: pkmVec2): kmBool;
function kmRay2IntersectCircle(const ray: pkmRay2; const center: pkmVec2; const radius: kmScalar; intersection: pkmVec2): kmBool;

implementation

procedure kmRay2Fill(ray: pkmRay2; px, py, vx, vy: kmScalar);
begin

end;

function kmRay2IntersectLineSegment(const ray: kmRay2; const p1, p2: pkmVec2; intersection: pkmVec2): kmBool;
begin
  {.$MESSAGE 'no implementation'}
  Result := False;
end;

function kmRay2IntersectTriangle(const ray: pkmRay2; const p1, p2, p3: pkmVec2; intersection: pkmVec2; normal_out: pkmVec2): kmBool;
begin
  {.$MESSAGE 'no implementation'}
  Result := False;
end;

function kmRay2IntersectCircle(const ray: pkmRay2; const center: pkmVec2; const radius: kmScalar; intersection: pkmVec2): kmBool;
begin
  {.$MESSAGE 'no implementation'}
  Result := False;
end;
end.
