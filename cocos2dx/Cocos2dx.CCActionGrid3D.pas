(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      On-Core

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

unit Cocos2dx.CCActionGrid3D;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCActionGrid, Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

type
  CCWave3D = class(CCGrid3DAction)
  public
    function getAmplitude(): Single;
    procedure setAmplitude(fAmplitude: Single);
    function getAmplitudeRate(): Single;
    procedure setAmplitudeRate(fAmplitudeRate: Single);
    function initWithDuration(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single): Boolean;

    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single): CCWave3D;
  protected
    m_nWaves: Cardinal;
    m_fAmplitude: Single;
    m_fAmplitudeRate: Single;
  end;

  CCFlipX3D = class(CCGrid3DAction)
  public
    function initWithDuration(duration: Single): Boolean;
    function initWithSize(const gridSize: CCSize; duration: Single): Boolean; virtual;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single): CCFlipX3D;
  end;

  CCFlipY3D = class(CCFlipX3D)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single): CCFlipY3D;
  end;

  CCLens3D = class(CCGrid3DAction)
  public
    function getLensEffect(): Single;
    procedure setLensEffect(fLensEffect: Single);
    function getPosition(): CCPoint;
    procedure setPosition(const position: CCPoint);
    procedure setConcave(bConcave: Boolean);
    function initWithDuration(duration: Single; const gridSize: CCSize; const position: CCPoint; radius: Single): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; const position: CCPoint; radius: Single): CCLens3D;
  protected
    m_position: CCPoint;
    m_fRadius: Single;
    m_fLensEffect: Single;
    m_bDirty: Boolean;
    m_bConcave: Boolean;
  end;

  CCRipple3D = class(CCGrid3DAction)
  public
    function getPosition(): CCPoint;
    procedure setPosition(const position: CCPoint);
    function getAmplitude(): Single;
    procedure setAmplitude(fAmplitude: Single);
    function getAmplitudeRate(): Single;
    procedure setAmplitudeRate(fAmplitudeRate: Single);
    function initWithDuration(duration: Single; const gridSize: CCSize; const position: CCPoint; radius: Single; waves: Cardinal; amplitude: Single): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; const position: CCPoint; radius: Single; waves: Cardinal; amplitude: Single): CCRipple3D;
  protected
    m_position: CCPoint;
    m_fRadius: Single;
    m_nWaves: Cardinal;
    m_fAmplitude: Single;
    m_fAmplitudeRate: Single;
  end;

  CCShaky3D = class(CCGrid3DAction)
  public
    function initWithDuration(duration: Single; const gridSize: CCSize; range: Integer; shakeZ: Boolean): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; range: Integer; shakeZ: Boolean): CCShaky3D;
  protected
    m_nRandrange: Integer;
    m_bShakeZ: Boolean;
  end;

  CCLiquid = class(CCGrid3DAction)
  public
    function getAmplitude(): Single;
    procedure setAmplitude(fAmplitude: Single);
    function getAmplitudeRate(): Single;
    procedure setAmplitudeRate(fAmplitudeRate: Single);
    function initWithDuration(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single): CCLiquid;
  protected
    m_nWaves: Cardinal;
    m_fAmplitude: Single;
    m_fAmplitudeRate: Single;
  end;

  CCWaves = class(CCGrid3DAction)
  public
    function getAmplitude(): Single;
    procedure setAmplitude(fAmplitude: Single);
    function getAmplitudeRate(): Single;
    procedure setAmplitudeRate(fAmplitudeRate: Single);
    function initWithDuration(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single; horizontal, vertical: Boolean): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single; horizontal, vertical: Boolean): CCWaves;
  protected
    m_nWaves: Cardinal;
    m_fAmplitude: Single;
    m_fAmplitudeRate: Single;
    m_bVertical: Boolean;
    m_bHorizontal: Boolean;
  end;

  CCTwirl = class(CCGrid3DAction)
  public
    function getPosition(): CCPoint;
    procedure setPosition(const position: CCPoint);
    function getAmplitude(): Single;
    procedure setAmplitude(fAmplitude: Single);
    function getAmplitudeRate(): Single;
    procedure setAmplitudeRate(fAmplitudeRate: Single);
    function initWithDuration(duration: Single; const gridSize: CCSize; position: CCPoint; twirls: Cardinal; amplitude: Single): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; position: CCPoint; twirls: Cardinal; amplitude: Single): CCTwirl;
  protected
    m_position: CCPoint;
    m_nTwirls: Integer;
    m_fAmplitude: Single;
    m_fAmplitudeRate: Single;
  end;

implementation
uses
  Math,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCPointExtension, Cocos2dx.CCMacros;

{ CCWave3D }

class function CCWave3D._create(duration: Single; const gridSize: CCSize;
  waves: Cardinal; amplitude: Single): CCWave3D;
var
  pRet: CCWave3D;
begin
  pRet := CCWave3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, waves, amplitude) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCWave3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCWave3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCWave3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCWave3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nWaves, m_fAmplitude);

  pNewZone.Free;

  Result := pRet;
end;

function CCWave3D.getAmplitude: Single;
begin
  Result := m_fAmplitude;
end;

function CCWave3D.getAmplitudeRate: Single;
begin
  Result := m_fAmplitudeRate;
end;

function CCWave3D.initWithDuration(duration: Single; const gridSize: CCSize;
  waves: Cardinal; amplitude: Single): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nWaves := waves;
    m_fAmplitude := amplitude;
    m_fAmplitudeRate := 1.0;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCWave3D.setAmplitude(fAmplitude: Single);
begin
  m_fAmplitude := fAmplitude;
end;

procedure CCWave3D.setAmplitudeRate(fAmplitudeRate: Single);
begin
  m_fAmplitudeRate := fAmplitudeRate;
end;

procedure CCWave3D.update(time: Single);
var
  i, j: Integer;
  v: ccVertex3F;
begin
  for i := 0 to Floor(m_sGridSize.width) do
  begin
    for j := 0 to Floor(m_sGridSize.height) do
    begin
      v := originalVertex(ccp(i, j));
      v.z := v.z + sin(Pi * time * m_nWaves * 2 + (v.y + v.x) * 0.01) * m_fAmplitude * m_fAmplitudeRate;
      setVertex(ccp(i, j), v);
    end;
  end;
end;

{ CCFlipX3D }

class function CCFlipX3D._create(duration: Single): CCFlipX3D;
var
  pRet: CCFlipX3D;
begin
  pRet := CCFlipX3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFlipX3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFlipX3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFlipX3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFlipX3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithSize(m_sGridSize, m_fDuration);

  pNewZone.Free;

  Result := pRet;
end;

function CCFlipX3D.initWithDuration(duration: Single): Boolean;
begin
  Result := inherited initWithDuration(duration, CCSizeMake(1, 1));
end;

function CCFlipX3D.initWithSize(const gridSize: CCSize;
  duration: Single): Boolean;
begin
  if (gridSize.width <> 1) or (gridSize.height <> 1) then
  begin
    CCAssert(False, 'Grid size must be (1,1)');
    Result := False;
    Exit;
  end;
  Result := inherited initWithDuration(duration, gridSize);
end;

procedure CCFlipX3D.update(time: Single);
var
  angle, mz, mx: Single;
  v0, v1, v, diff: ccVertex3F;
  x0, x1, x: Single;
  a, b, c, d: CCPoint;
begin
  angle := Pi * time;
  mz := Sin(angle);
  angle := angle * 0.5;
  mx := Cos(angle);

  v0 := originalVertex(ccp(1, 1));
  v1 := originalVertex(ccp(0, 0));

  x0 := v0.x; x1 := v1.x;

  if x0 > x1 then
  begin
    a := ccp(0, 0);
    b := ccp(0, 1);
    c := ccp(1, 0);
    d := ccp(1, 1);
    x := x0;
  end else
  begin
    c := ccp(0, 0);
    d := ccp(0, 1);
    a := ccp(1, 0);
    b := ccp(1, 1);
    x := x1;
  end;

  diff.x := (x - x * mx);
  diff.z := Abs( Floor(x * mz / 4.0) );

  v := originalVertex(a);
  v.x := diff.x;
  v.z := v.z + diff.z;
  setVertex(a, v);

  v := originalVertex(b);
  v.x := diff.x;
  v.z := v.z + diff.z;
  setVertex(b, v);

  v := originalVertex(c);
  v.x := v.x - diff.x;
  v.z := v.z - diff.z;
  setVertex(c, v);

  v := originalVertex(d);
  v.x := v.x - diff.x;
  v.z := v.z - diff.z;
  setVertex(d, v);
end;

{ CCFlipY3D }

class function CCFlipY3D._create(duration: Single): CCFlipY3D;
var
  pRet: CCFlipY3D;
begin
  pRet := CCFlipY3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFlipY3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCFlipY3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCFlipY3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCFlipY3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithSize(m_sGridSize, m_fDuration);

  pNewZone.Free;

  Result := pRet;
end;

procedure CCFlipY3D.update(time: Single);
var
  angle, mz, my: Single;
  v0, v1, v, diff: ccVertex3F;
  y0, y1, y: Single;
  a, b, c, d: CCPoint;
begin
  angle := Pi * time;
  mz := Sin(angle);
  angle := angle * 0.5;
  my := Cos(angle);

  v0 := originalVertex(ccp(1, 1));
  v1 := originalVertex(ccp(0, 0));

  y0 := v0.y; y1 := v1.y;
  if y0 > y1 then
  begin
    a := ccp(0, 0);
    b := ccp(0, 1);
    c := ccp(1, 0);
    d := ccp(1, 1);
    y := y0;
  end else
  begin
    b := ccp(0, 0);
    a := ccp(0, 1);
    d := ccp(1, 0);
    c := ccp(1, 1);
    y := y1;
  end;

  diff.y := y - y * my;
  diff.z := Abs( Floor(y * mz * 0.25) );

  v := originalVertex(a);
  v.y := diff.y;
  v.z := v.z + diff.z;
  setVertex(a, v);

  v := originalVertex(b);
  v.y := v.y - diff.y;
  v.z := v.z - diff.z;
  setVertex(b, v);

  v := originalVertex(c);
  v.y := diff.y;
  v.z := v.z + diff.z;
  setVertex(c, v);

  v := originalVertex(d);
  v.y := v.y - diff.y;
  v.z := v.z - diff.z;
  setVertex(d, v);
end;

{ CCLens3D }

class function CCLens3D._create(duration: Single; const gridSize: CCSize;
  const position: CCPoint; radius: Single): CCLens3D;
var
  pRet: CCLens3D;
begin
  pRet := CCLens3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, position, radius) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCLens3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCLens3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCLens3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCLens3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_position, m_fRadius);

  pNewZone.Free;

  Result := pRet;
end;

function CCLens3D.getLensEffect: Single;
begin
  Result := m_fLensEffect;
end;

function CCLens3D.getPosition: CCPoint;
begin
  Result := m_position;
end;

function CCLens3D.initWithDuration(duration: Single; const gridSize: CCSize;
  const position: CCPoint; radius: Single): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_position := ccp(-1, -1);
    setPosition(position);
    m_fRadius := radius;
    m_fLensEffect := 0.7;
    m_bConcave := False;
    m_bDirty := True;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCLens3D.setLensEffect(fLensEffect: Single);
begin
  m_fLensEffect := fLensEffect;
end;

procedure CCLens3D.setPosition(const position: CCPoint);
begin
  m_position := position;
end;

procedure CCLens3D.update(time: Single);
var
  i, j: Integer;
  v: ccVertex3F;
  vect, new_vect: CCPoint;
  r: Single;
  pre_log: Single;
  l, new_r: Single;
begin
  if m_bDirty then
  begin
    for i := 0 to Round(m_sGridSize.width) do
    begin
      for j := 0 to Round(m_sGridSize.height) do
      begin
        v := originalVertex(ccp(i, j));
        vect := ccpSub(m_position, ccp(v.x, v.y));
        r := ccpLength(vect);

        if r < m_fRadius then
        begin
          r := m_fRadius - r;
          pre_log := r / m_fRadius;
          if IsZero(pre_log) then
          begin
            pre_log := 0.001;
          end;

          l := Log2(pre_log) * m_fLensEffect;
          new_r := Exp(l) * m_fRadius;

          if ccpLength(vect) > 0 then
          begin
            vect := ccpNormalize(vect);
            new_vect := ccpMult(vect, new_r);
            if m_bConcave then
              v.z := v.z - ccpLength(new_vect) * m_fLensEffect
            else
              v.z := v.z + ccpLength(new_vect) * m_fLensEffect;
          end;  
        end;
        setVertex(ccp(i, j), v);
      end;  
    end;
    m_bDirty := False;
  end;  
end;

procedure CCLens3D.setConcave(bConcave: Boolean);
begin
  m_bConcave := bConcave;
end;

{ CCRipple3D }

class function CCRipple3D._create(duration: Single; const gridSize: CCSize;
  const position: CCPoint; radius: Single; waves: Cardinal;
  amplitude: Single): CCRipple3D;
var
  pRet: CCRipple3D;
begin
  pRet := CCRipple3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, position, radius, waves, amplitude) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCRipple3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCRipple3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCRipple3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCRipple3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_position, m_fRadius, m_nWaves, m_fAmplitude);

  pNewZone.Free;

  Result := pRet;
end;

function CCRipple3D.getAmplitude: Single;
begin
  Result := m_fAmplitude;
end;

function CCRipple3D.getAmplitudeRate: Single;
begin
  Result := m_fAmplitudeRate;
end;

function CCRipple3D.getPosition: CCPoint;
begin
  Result := m_position;
end;

function CCRipple3D.initWithDuration(duration: Single; const gridSize: CCSize;
  const position: CCPoint; radius: Single; waves: Cardinal;
  amplitude: Single): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    setPosition(position);
    m_fRadius := radius;
    m_nWaves := waves;
    m_fAmplitude := amplitude;
    m_fAmplitudeRate := 1.0;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCRipple3D.setAmplitude(fAmplitude: Single);
begin
  m_fAmplitude := fAmplitude;
end;

procedure CCRipple3D.setAmplitudeRate(fAmplitudeRate: Single);
begin
  m_fAmplitudeRate := fAmplitudeRate;
end;

procedure CCRipple3D.setPosition(const position: CCPoint);
begin
  m_position := position;
end;

procedure CCRipple3D.update(time: Single);
var
  i, j: Integer;
  v: ccVertex3F;
  vect: CCPoint;
  r, rate: Single;
begin
  for i := 0 to Floor(m_sGridSize.width) do
  begin
    for j := 0 to Floor(m_sGridSize.height) do
    begin
      v := originalVertex(ccp(i, j));
      vect := ccpSub(m_position, ccp(v.x, v.y));
      r := ccpLength(vect);

      if r < m_fRadius then
      begin
        r := m_fRadius - r;
        rate := Power(r / m_fRadius, 2);
        v.z := v.z + Sin(time * Pi * m_nWaves * 2 + r * 0.1) * m_fAmplitude * m_fAmplitudeRate * rate;
      end;
      setVertex(ccp(i, j), v);
    end;
  end;
end;

{ CCShaky3D }

class function CCShaky3D._create(duration: Single; const gridSize: CCSize;
  range: Integer; shakeZ: Boolean): CCShaky3D;
var
  pRet: CCShaky3D;
begin
  pRet := CCShaky3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, range, shakeZ) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCShaky3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCShaky3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCShaky3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCShaky3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nRandrange, m_bShakeZ);

  pNewZone.Free;

  Result := pRet;
end;

function CCShaky3D.initWithDuration(duration: Single; const gridSize: CCSize;
  range: Integer; shakeZ: Boolean): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nRandrange := range;
    m_bShakeZ := shakeZ;
    Result := True;

    Randomize();
    Exit;
  end;
  Result := False;
end;

procedure CCShaky3D.update(time: Single);
var
  i, j: Integer;
  v: ccVertex3F;
begin
  for i := 0 to Floor(m_sGridSize.width) do
  begin
    for j := 0 to Floor(m_sGridSize.height) do
    begin
      v := originalVertex(ccp(i, j));

      v.x := v.x + (RandomRange(0, m_nRandrange * 2) mod (m_nRandrange * 2)) - m_nRandrange;
      v.y := v.y + (RandomRange(0, m_nRandrange * 2) mod (m_nRandrange * 2)) - m_nRandrange;

      if m_bShakeZ then
      begin
        v.z := v.z + (RandomRange(0, m_nRandrange * 2) mod (m_nRandrange * 2)) - m_nRandrange;
      end;

      setVertex(ccp(i, j), v);
    end;
  end;  
end;

{ CCLiquid }

class function CCLiquid._create(duration: Single; const gridSize: CCSize;
  waves: Cardinal; amplitude: Single): CCLiquid;
var
  pRet: CCLiquid;
begin
  pRet := CCLiquid.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, waves, amplitude) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCLiquid.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCLiquid;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCLiquid(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCLiquid.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nWaves, m_fAmplitude);

  pNewZone.Free;

  Result := pRet;
end;

function CCLiquid.getAmplitude: Single;
begin
  Result := m_fAmplitude;
end;

function CCLiquid.getAmplitudeRate: Single;
begin
  Result := m_fAmplitudeRate;
end;

function CCLiquid.initWithDuration(duration: Single; const gridSize: CCSize;
  waves: Cardinal; amplitude: Single): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nWaves := waves;
    m_fAmplitude := amplitude;
    m_fAmplitudeRate := 1.0;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCLiquid.setAmplitude(fAmplitude: Single);
begin
  m_fAmplitude := fAmplitude;
end;

procedure CCLiquid.setAmplitudeRate(fAmplitudeRate: Single);
begin
  m_fAmplitudeRate := fAmplitudeRate;
end;

procedure CCLiquid.update(time: Single);
var
  i, j: Integer;
  v: ccVertex3F;
begin
  for i := 1 to Floor(m_sGridSize.width)-1 do
  begin
    for j := 1 to Floor(m_sGridSize.height)-1 do
    begin
      v := originalVertex(ccp(i, j));
      v.x := v.x + Sin(time * Pi * m_nWaves * 2 + v.x * 0.01) * m_fAmplitude * m_fAmplitudeRate;
      v.y := v.y + Sin(time * Pi * m_nWaves * 2 + v.y * 0.01) * m_fAmplitude * m_fAmplitudeRate;
      setVertex(ccp(i, j), v);
    end;  
  end;  
end;

{ CCWaves }

class function CCWaves._create(duration: Single; const gridSize: CCSize;
  waves: Cardinal; amplitude: Single;
  horizontal, vertical: Boolean): CCWaves;
var
  pRet: CCWaves;
begin
  pRet := CCWaves.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, waves, amplitude, horizontal, vertical) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCWaves.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCWaves;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCWaves(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCWaves.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nWaves, m_fAmplitude, m_bHorizontal, m_bVertical);

  pNewZone.Free;

  Result := pRet;
end;

function CCWaves.getAmplitude: Single;
begin
  Result := m_fAmplitude;
end;

function CCWaves.getAmplitudeRate: Single;
begin
  Result := m_fAmplitudeRate;
end;

function CCWaves.initWithDuration(duration: Single; const gridSize: CCSize;
  waves: Cardinal; amplitude: Single;
  horizontal, vertical: Boolean): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nWaves := waves;
    m_fAmplitude := amplitude;
    m_fAmplitudeRate := 1.0;
    m_bHorizontal := horizontal;
    m_bVertical := vertical;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCWaves.setAmplitude(fAmplitude: Single);
begin
  m_fAmplitude := fAmplitude;
end;

procedure CCWaves.setAmplitudeRate(fAmplitudeRate: Single);
begin
  m_fAmplitudeRate := fAmplitudeRate;
end;

procedure CCWaves.update(time: Single);
var
  i, j: Integer;
  v: ccVertex3F;
begin
  for i := 0 to Floor(m_sGridSize.width) do
  begin
    for j := 0 to Floor(m_sGridSize.height) do
    begin
      v := originalVertex(ccp(i, j));
      
      if m_bVertical then
        v.x := v.x + Sin(time * Pi * m_nWaves * 2 + v.y * 0.01) * m_fAmplitude * m_fAmplitudeRate;

      if m_bHorizontal then
        v.y := v.y + Sin(time * Pi * m_nWaves * 2 + v.x * 0.01) * m_fAmplitude * m_fAmplitudeRate;

      setVertex(ccp(i, j), v);
    end;  
  end;  
end;

{ CCTwirl }

class function CCTwirl._create(duration: Single; const gridSize: CCSize;
  position: CCPoint; twirls: Cardinal; amplitude: Single): CCTwirl;
var
  pRet: CCTwirl;
begin
  pRet := CCTwirl.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, position, twirls, amplitude) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTwirl.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCTwirl;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCTwirl(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCTwirl.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_position, m_nTwirls, m_fAmplitude);

  pNewZone.Free;

  Result := pRet;
end;

function CCTwirl.getAmplitude: Single;
begin
  Result := m_fAmplitude;
end;

function CCTwirl.getAmplitudeRate: Single;
begin
  Result := m_fAmplitudeRate;
end;

function CCTwirl.getPosition: CCPoint;
begin
  Result := m_position;
end;

function CCTwirl.initWithDuration(duration: Single; const gridSize: CCSize;
  position: CCPoint; twirls: Cardinal; amplitude: Single): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    setPosition(position);
    m_nTwirls := twirls;
    m_fAmplitude := amplitude;
    m_fAmplitudeRate := 1.0;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCTwirl.setAmplitude(fAmplitude: Single);
begin
  m_fAmplitude := fAmplitude;
end;

procedure CCTwirl.setAmplitudeRate(fAmplitudeRate: Single);
begin
  m_fAmplitudeRate := fAmplitudeRate;
end;

procedure CCTwirl.setPosition(const position: CCPoint);
begin
  m_position := position;
end;

procedure CCTwirl.update(time: Single);
var
  i, j: Integer;
  v: ccVertex3F;
  c, avg, d: CCPoint;
  amp, a, r: Single;
begin
  c := m_position;
  for i := 0 to Floor(m_sGridSize.width) do
  begin
    for j := 0 to Floor(m_sGridSize.height) do
    begin
      v := originalVertex(ccp(i, j));

      avg := ccp(i - m_sGridSize.width * 0.5, j - m_sGridSize.height * 0.5);
      r := ccpLength(avg);

      amp := 0.1 * m_fAmplitude * m_fAmplitudeRate;
      a := r * Cos(Pi * 0.5 + time * Pi * m_nTwirls * 2) * amp;

      d := ccp(
        Sin(a) * (v.y - c.y) + Cos(a) * (v.x - c.x),
        Cos(a) * (v.y - c.y) - Sin(a) * (v.x - c.x)
        );

      v.x := c.x + d.x;
      v.y := c.y + d.y;

      setVertex(ccp(i, j), v);
    end;
  end;
end;

end.
