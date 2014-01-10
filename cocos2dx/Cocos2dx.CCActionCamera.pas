(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2011      Zynga Inc.

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

unit Cocos2dx.CCActionCamera;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCCamera, Cocos2dx.CCAction, Cocos2dx.CCActionInterval;

type
  CCActionCamera = class(CCActionInterval)
  public
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
  protected
    m_fCenterXOrig, m_fCenterYOrig, m_fCenterZOrig: Single;
    m_fEyeXOrig, m_fEyeYOrig, m_fEyeZOrig: Single;
    m_fUpXOrig, m_fUpYOrig, m_fUpZOrig: Single;
  end;

  (**
  @brief CCOrbitCamera action
  Orbits the camera around the center of the screen using spherical coordinates
  @ingroup Actions
  *)
  CCOrbitCamera = class(CCActionCamera)
  public
    class function _create(t, radius, deltaRadius, angleZ, deltaAngleZ, angleX, deltaAngleX: Single): CCOrbitCamera;
    function initWithDuration(t, radius, deltaRadius, angleZ, deltaAngleZ, angleX, deltaAngleX: Single): Boolean;
    procedure sphericalRadius(newRadius, zenith, azimuth: PSingle);
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
  protected
    m_fRadius,
    m_fDeltaRadius,
    m_fAngleZ,
    m_fDeltaAngleZ,
    m_fAngleX,
    m_fDeltaAngleX,

    m_fRadZ,
    m_fRadDeltaZ,
    m_fRadX,
    m_fRadDeltaX: Single;
  end;

implementation
uses
  Math,
  Cocos2dx.CCNode, Cocos2dx.CCPlatformMacros, Cocos2dx.CCMacros;

{ CCActionCamera }

function CCActionCamera.reverse: CCFiniteTimeAction;
begin
  Result := CCReverseTime._create(Self);
end;

procedure CCActionCamera.startWithTarget(pTarget: CCObject);
var
  camera: CCCamera;
begin
  inherited startWithTarget(pTarget);

  camera := CCNode(pTarget).Camera;
  camera.getCenterXYZ(m_fCenterXOrig, m_fCenterYOrig, m_fCenterZOrig);
  camera.getEyeXYZ(m_fEyeXOrig, m_fEyeYOrig, m_fEyeZOrig);
  camera.getUpXYZ(m_fUpXOrig, m_fUpYOrig, m_fUpZOrig);
end;

{ CCOrbitCamera }

class function CCOrbitCamera._create(t, radius, deltaRadius, angleZ,
  deltaAngleZ, angleX, deltaAngleX: Single): CCOrbitCamera;
var
  pRet: CCOrbitCamera;
begin
  pRet := CCOrbitCamera.Create;
  if pRet.initWithDuration(t, radius, deltaRadius, angleZ, deltaAngleZ, angleX, deltaAngleX) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCOrbitCamera.initWithDuration(t, radius, deltaRadius, angleZ,
  deltaAngleZ, angleX, deltaAngleX: Single): Boolean;
begin
  if inherited initWithDuration(t) then
  begin
    m_fRadius := radius;
    m_fDeltaRadius := deltaRadius;
    m_fAngleZ := angleZ;
    m_fDeltaAngleZ := deltaAngleZ;
    m_fAngleX := angleX;
    m_fDeltaAngleX := deltaAngleX;

    m_fRadDeltaZ := CC_DEGREES_TO_RADIANS(deltaAngleZ);
    m_fRadDeltaX := CC_DEGREES_TO_RADIANS(deltaAngleX);

    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCOrbitCamera.sphericalRadius(newRadius, zenith, azimuth: PSingle);
var
  ex, ey, ez, cx, cy, cz, x, y, z: Single;
  r, s: Single;
  pCamera: CCCamera;
begin
  pCamera := CCNode(m_pTarget).Camera;
  pCamera.getEyeXYZ(ex, ey, ez);
  pCamera.getCenterXYZ(cx, cy, cz);

  x := ex - cx;
  y := ey - cy;
  z := ez - cz;

  r := Sqrt( Power(x, 2) + Power(y, 2) + Power(z, 2) );
  s := Sqrt( Power(x, 2) + Power(y, 2) );
  
  if IsZero(s) then
    s := FLT_EPSILON;
  if IsZero(r) then
    r := FLT_EPSILON;

  zenith^ := ArcCos(z/r);
  if x < 0 then
    azimuth^ := Pi - ArcSin(y/s)
  else
    azimuth^ := ArcSin(y/s);

  newRadius^ := r / CCCamera.getZEye();
end;

procedure CCOrbitCamera.startWithTarget(pTarget: CCObject);
var
  r, zenith, azimuth: Single;
begin
  inherited startWithTarget(pTarget);

  Self.sphericalRadius(@r, @zenith, @azimuth);
  if IsNan(m_fRadius) then
    m_fRadius := r;
  if IsNan(m_fAngleZ) then
    m_fAngleZ := CC_RADIANS_TO_DEGREES(zenith);
  if IsNan(m_fAngleX) then
    m_fAngleX := CC_RADIANS_TO_DEGREES(azimuth);

  m_fRadZ := CC_DEGREES_TO_RADIANS(m_fAngleZ);
  m_fRadX := CC_DEGREES_TO_RADIANS(m_fAngleX);
end;

procedure CCOrbitCamera.update(time: Single);
var
  r, za, xa, j, i, k: Single;
begin
  r := (m_fRadius + m_fDeltaRadius * time) * CCCamera.getZEye();
  za := m_fRadZ + m_fRadDeltaZ * time;
  xa := m_fRadX + m_fRadDeltaX * time;

  i := Sin(za) * Cos(xa) * r + m_fCenterXOrig;
  j := Sin(za) * Sin(xa) * r + m_fCenterYOrig;
  k := Cos(za) * r + m_fCenterZOrig;

  CCNode(m_pTarget).Camera.setEyeXYZ(i, j, k);
end;

function CCOrbitCamera.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCOrbitCamera;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCOrbitCamera(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCOrbitCamera.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fRadius, m_fDeltaRadius, m_fAngleZ, m_fDeltaAngleZ, m_fAngleX, m_fDeltaAngleX);

  pNewZone.Free;

  Result := pRet;
end;

end.
