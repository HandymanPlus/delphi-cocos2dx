unit aabb;

interface
uses
  utility;

function kmAABBContainsPoint(const pPoint: pkmVec3; const pBox: pkmAABB): Integer;
function kmAABBAssign(pOut: pkmAABB; const pIn: pkmAABB): pkmAABB;
function kmAABBScale(pOut: pkmAABB; const pIn: pkmAABB; const s: kmScalar): pkmAABB;

implementation

function kmAABBContainsPoint(const pPoint: pkmVec3; const pBox: pkmAABB): Integer;
begin
  {.$MESSAGE 'no implementation'}
  Result := 0;
end;

function kmAABBAssign(pOut: pkmAABB; const pIn: pkmAABB): pkmAABB;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function kmAABBScale(pOut: pkmAABB; const pIn: pkmAABB; const s: kmScalar): pkmAABB;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

end.
