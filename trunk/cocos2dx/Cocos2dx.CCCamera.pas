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

unit Cocos2dx.CCCamera;

interface
uses
  Cocos2dx.CCObject, utility, mat4;

type
  (**
  A CCCamera is used in every CCNode.
  Useful to look at the object from different views.
  The OpenGL gluLookAt() function is used to locate the
  camera.

  If the object is transformed by any of the scale, rotation or
  position attributes, then they will override the camera.

  IMPORTANT: Either your use the camera or the rotation/scale/position properties. You can't use both.
  World coordinates won't work if you use the camera.

  Limitations:

  - Some nodes, like CCParallaxNode, CCParticle uses world node coordinates, and they won't work properly if you move them (or any of their ancestors)
  using the camera.

  - It doesn't work on batched nodes like CCSprite objects when they are parented to a CCSpriteBatchNode object.

  - It is recommended to use it ONLY if you are going to create 3D effects. For 2D effects, use the action CCFollow or position/scale/rotate.

  *)
  CCCamera = class(CCObject)
  protected
    m_fEyeX, m_fEyeY, m_fEyeZ: Single;
    m_fCenterX, m_fCenterY, m_fCenterZ: Single;
    m_fUpX, m_fUpY, m_fUpZ: Single;
    m_bDirty: Boolean;
    m_lookupMatrix: kmMat4;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure init();
    function description(): string;
    procedure setDirty(bValue: Boolean);
    function isDirty(): Boolean;
    procedure restore();
    procedure locate();
    procedure setEyeXYZ(fEyeX, fEyeY, fEyeZ: Single);
    procedure setCenterXYZ(fCenterX, fCenterY, fCenterZ: Single);
    procedure setUpXYZ(fUpX, fUpY, fUpZ: Single);
    procedure getEyeXYZ(var pEyeX, pEyeY, pEyeZ: Single);
    procedure getCenterXYZ(var pCenterX, pCenterY, pCenterZ: Single);
    procedure getUpXYZ(var fUpX, fUpY, fUpZ: Single);
    class function getZEye(): Single;
  end;

implementation
uses
  Cocos2dx.CCString,  vec3, matrix, Cocos2dx.CCMacros;

{ CCCamera }

constructor CCCamera.Create;
begin
  inherited Create();
  init();
end;

function CCCamera.description: string;
begin
  Result := CCString.createWithFormat('<CCCamera | center = (%.2f,%.2f,%.2f)>', [m_fCenterX, m_fCenterY, m_fCenterZ]).m_sString;
end;

destructor CCCamera.Destroy;
begin

  inherited;
end;

procedure CCCamera.getCenterXYZ(var pCenterX, pCenterY, pCenterZ: Single);
begin
  pCenterX := m_fCenterX;
  pCenterY := m_fCenterY;
  pCenterZ := m_fCenterZ;
end;

function CCCamera.isDirty: Boolean;
begin
  Result := m_bDirty;
end;

procedure CCCamera.getEyeXYZ(var pEyeX, pEyeY, pEyeZ: Single);
begin
  pEyeX := m_fEyeX;
  pEyeY := m_fEyeY;
  pEyeZ := m_fEyeZ;
end;

procedure CCCamera.getUpXYZ(var fUpX, fUpY, fUpZ: Single);
begin
  fUpX := m_fUpX;
  fUpY := m_fUpY;
  fUpZ := m_fUpZ;
end;

class function CCCamera.getZEye: Single;
begin
  Result := FLT_EPSILON;
end;

procedure CCCamera.init;
begin
  restore();
end;

procedure CCCamera.locate;
var
  eye, center, up: kmVec3;
begin
  if m_bDirty then
  begin
    kmVec3Fill(@eye, m_fEyeX, m_fEyeY, m_fEyeZ);
    kmVec3Fill(@center, m_fCenterX, m_fCenterY, m_fCenterZ);

    kmVec3Fill(@up, m_fUpX, m_fUpY, m_fUpZ);
    kmMat4LookAt(@m_lookupMatrix, @eye, @center, @up);

    m_bDirty := False;
  end;
  kmGLMultMatrix(@m_lookupMatrix);
end;

procedure CCCamera.restore;
begin
  m_fEyeX := 0.0; m_fEyeY := 0.0;
  m_fEyeZ := getZEye();

  m_fCenterX := 0.0; m_fCenterY := 0.0; m_fCenterZ := 0.0;

  m_fUpX := 0.0; m_fUpY := 1.0; m_fUpZ := 0.0;

  kmMat4Identity(@m_lookupMatrix);

  m_bDirty := False;
end;

procedure CCCamera.setCenterXYZ(fCenterX, fCenterY, fCenterZ: Single);
begin
  m_fCenterX := fCenterX;
  m_fCenterY := fCenterY;
  m_fCenterZ := fCenterZ;

  m_bDirty := True;
end;

procedure CCCamera.setDirty(bValue: Boolean);
begin
  m_bDirty := bValue;
end;

procedure CCCamera.setEyeXYZ(fEyeX, fEyeY, fEyeZ: Single);
begin
  m_fEyeX := fEyeX;
  m_fEyeY := fEyeY;
  m_fEyeZ := fEyeZ;

  m_bDirty := True;
end;

procedure CCCamera.setUpXYZ(fUpX, fUpY, fUpZ: Single);
begin
  m_fUpX := fUpX;
  m_fUpY := fUpY;
  m_fUpZ := fUpZ;

  m_bDirty := True;
end;

end.
