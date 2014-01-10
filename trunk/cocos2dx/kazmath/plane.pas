unit plane;

interface
uses
  utility;

function kmPlaneDot(const pP: pkmPlane; pV: pkmVec4): kmScalar;
function kmPlaneDotCoord(const pP: pkmPlane; pV: pkmVec3): kmScalar;
function kmPlaneDotNormal(const pP: pkmPlane; pV: pkmVec3): kmScalar;
function kmPlaneFromPointNormal(pOut: pkmPlane; const pPoint, pNormal: pkmVec3): pkmPlane;
function kmPlaneFromPoints(pOut: pkmPlane; const p1, p2, p3: pkmVec3): pkmPlane;
function kmPlaneIntersectLine(pOut: pkmVec3; const pP: pkmPlane; const pV1, pV2: pkmVec3): pkmVec3;
function kmPlaneNormalize(pOut: pkmPlane; const pP: pkmPlane): pkmPlane;
function kmPlaneScale(pOut: pkmPlane; const pP: pkmPlane; s: kmScalar): pkmPlane;
function kmPlaneClassifyPoint(const pIn: pkmPlane; const pP: pkmVec3): POINT_CLASSIFICATION;

implementation

function kmPlaneDot(const pP: pkmPlane; pV: pkmVec4): kmScalar;
begin
  {.$MESSAGE 'no implementation'}
  Result := 0.0;
end;

function kmPlaneDotCoord(const pP: pkmPlane; pV: pkmVec3): kmScalar;
begin
  {.$MESSAGE 'no implementation'}
  Result := 0.0;
end;

function kmPlaneDotNormal(const pP: pkmPlane; pV: pkmVec3): kmScalar;
begin
  {.$MESSAGE 'no implementation'}
  Result := 0.0;
end;

function kmPlaneFromPointNormal(pOut: pkmPlane; const pPoint, pNormal: pkmVec3): pkmPlane;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function kmPlaneFromPoints(pOut: pkmPlane; const p1, p2, p3: pkmVec3): pkmPlane;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function kmPlaneIntersectLine(pOut: pkmVec3; const pP: pkmPlane; const pV1, pV2: pkmVec3): pkmVec3;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function kmPlaneNormalize(pOut: pkmPlane; const pP: pkmPlane): pkmPlane;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function kmPlaneScale(pOut: pkmPlane; const pP: pkmPlane; s: kmScalar): pkmPlane;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function kmPlaneClassifyPoint(const pIn: pkmPlane; const pP: pkmVec3): POINT_CLASSIFICATION;
begin
  {.$MESSAGE 'no implementation'}
  Result := POINT_INFRONT_OF_PLANE;
end;

end.
