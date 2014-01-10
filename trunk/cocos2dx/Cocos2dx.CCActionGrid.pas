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

unit Cocos2dx.CCActionGrid;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCGrid, Cocos2dx.CCAction, Cocos2dx.CCActionInterval,
  Cocos2dx.CCActionInstant, Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

type
  CCGridAction = class(CCActionInterval)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    function initWithDuration(duration: Single; const gridSize: CCSize): Boolean; 
    function getGrid(): CCGridBase; virtual;
    class function _create(duration: Single; const gridSize: CCSize): CCGridAction;
  protected
    m_sGridSize: CCSize;
  end;

  CCGrid3DAction = class(CCGridAction)
  public
    function getGrid(): CCGridBase; override;
    function vertex(const position: CCPoint): ccVertex3F;
    function originalVertex(const position: CCPoint): ccVertex3F;
    procedure setVertex(const position: CCPoint; const vertex: ccVertex3F);
    class function _create(duration: Single; const gridSize: CCSize): CCGrid3DAction;
  end;

  CCTiledGrid3DAction = class(CCGridAction)
  public
    function tile(const position: CCPoint): ccQuad3;
    function originalTile(const position: CCPoint): ccQuad3;
    procedure setTile(const position: CCPoint; const coords: ccQuad3);
    function getGrid(): CCGridBase; override;
    class function _create(duration: Single; const gridSize: CCSize): CCTiledGrid3DAction;
  end;

  CCAccelDeccelAmplitude = class(CCActionInterval)
  public
    destructor Destroy(); override;
    function initWithAction(pAction: CCAction; duration: Single): Boolean;

    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    procedure update(time: Single); override;

    function getRate(): Single;
    procedure setRate(fRate: Single);

    class function _create(pAction: CCAction; duration: Single): CCAccelDeccelAmplitude;
  protected
    m_fRate: Single;
    m_pOther: CCActionInterval;
  end;

  CCAccelAmplitude = class(CCActionInterval)
  public
    destructor Destroy(); override;
    function initWithAction(pAction: CCAction; duration: Single): Boolean;

    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    procedure update(time: Single); override;

    function getRate(): Single;
    procedure setRate(fRate: Single);

    class function _create(pAction: CCAction; duration: Single): CCAccelAmplitude;
  protected
    m_fRate: Single;
    m_pOther: CCActionInterval;
  end;

  CCDeccelAmplitude = class(CCActionInterval)
  public
    destructor Destroy(); override;
    function initWithAction(pAction: CCAction; duration: Single): Boolean;

    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function reverse(): CCFiniteTimeAction; override;
    procedure update(time: Single); override;

    function getRate(): Single;
    procedure setRate(fRate: Single);

    class function _create(pAction: CCAction; duration: Single): CCDeccelAmplitude;
  protected
    m_fRate: Single;
    m_pOther: CCActionInterval;
  end;

  CCStopGrid = class(CCActionInstant)
  public
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    class function _create(): CCStopGrid;
  end;

  CCReuseGrid = class(CCActionInstant)
  public
    function initWithTimes(times: Integer): Boolean;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    class function _create(times: Integer): CCReuseGrid;
  protected
    m_nTimes: Integer;
  end;

implementation
uses
  Math,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCNode;

{ CCGridAction }

class function CCGridAction._create(duration: Single;
  const gridSize: CCSize): CCGridAction;
var
  pRet: CCGridAction;
begin
  pRet := CCGridAction.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCGridAction.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCGridAction;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCGridAction(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCGridAction.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize);

  pNewZone.Free;

  Result := pRet;
end;

function CCGridAction.getGrid: CCGridBase;
begin
  Result := nil; //override
end;

function CCGridAction.initWithDuration(duration: Single;
  const gridSize: CCSize): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_sGridSize := gridSize;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCGridAction.reverse: CCFiniteTimeAction;
begin
  Result := CCReverseTime._create(Self);
end;

procedure CCGridAction.startWithTarget(pTarget: CCObject);
var
  newGrid, targetGrid: CCGridBase;
  t: CCNode;
begin
  inherited startWithTarget(pTarget);

  newGrid := Self.getGrid();
  t := CCNode(pTarget);
  targetGrid := t.Grid;

  if (targetGrid <> nil) and (targetGrid.getReuseGrid() > 0) then
  begin
    if targetGrid.isActive() and (targetGrid.getGridSize().width = m_sGridSize.width) and
       (targetGrid.getGridSize().height = m_sGridSize.height) then
    begin
      targetGrid.reuse();
    end else
    begin
      CCAssert(False, '');
    end;
  end else
  begin
    if (targetGrid <> nil) and targetGrid.isActive() then
    begin
      targetGrid.setActive(False);
    end;
    t.Grid := newGrid;
    t.Grid.setActive(True);
  end;    
end;

{ CCGrid3DAction }

class function CCGrid3DAction._create(duration: Single;
  const gridSize: CCSize): CCGrid3DAction;
var
  pRet: CCGrid3DAction;
begin
  pRet := CCGrid3DAction.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := pRet;
end;

function CCGrid3DAction.getGrid: CCGridBase;
begin
  Result := CCGrid3D._create(m_sGridSize);
end;

function CCGrid3DAction.originalVertex(const position: CCPoint): ccVertex3F;
var
  g: CCGrid3D;
begin
  g := CCGrid3D(CCNode(m_pTarget).Grid);
  Result := g.originalVertex(position);
end;

procedure CCGrid3DAction.setVertex(const position: CCPoint;
  const vertex: ccVertex3F);
var
  g: CCGrid3D;
begin
  g := CCGrid3D(CCNode(m_pTarget).Grid);
  g.setVertex(position, vertex);
end;

function CCGrid3DAction.vertex(const position: CCPoint): ccVertex3F;
var
  g: CCGrid3D;
begin
  g := CCGrid3D(CCNode(m_pTarget).Grid);
  Result := g.vertex(position);
end;

{ CCTiledGrid3DAction }

class function CCTiledGrid3DAction._create(duration: Single;
  const gridSize: CCSize): CCTiledGrid3DAction;
var
  pRet: CCTiledGrid3DAction;
begin
  pRet := CCTiledGrid3DAction.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := pRet;
end;

function CCTiledGrid3DAction.getGrid: CCGridBase;
begin
  Result := CCTiledGrid3D._create(m_sGridSize);
end;

function CCTiledGrid3DAction.originalTile(const position: CCPoint): ccQuad3;
var
  g: CCTiledGrid3D;
begin
  g := CCTiledGrid3D(CCNode(m_pTarget).Grid);
  Result := g.originalTile(position);
end;

procedure CCTiledGrid3DAction.setTile(const position: CCPoint;
  const coords: ccQuad3);
var
  g: CCTiledGrid3D;
begin
  g := CCTiledGrid3D(CCNode(m_pTarget).Grid);
  g.setTile(position, coords);
end;

function CCTiledGrid3DAction.tile(const position: CCPoint): ccQuad3;
var
  g: CCTiledGrid3D;
begin
  g := CCTiledGrid3D(CCNode(m_pTarget).Grid);
  Result := g.tile(position);
end;

{ CCAccelDeccelAmplitude }

class function CCAccelDeccelAmplitude._create(pAction: CCAction;
  duration: Single): CCAccelDeccelAmplitude;
var
  pRet: CCAccelDeccelAmplitude;
begin
  pRet := CCAccelDeccelAmplitude.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, duration) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCAccelDeccelAmplitude.Destroy;
begin
  CC_SAFE_RELEASE(m_pOther);
  inherited;
end;

function CCAccelDeccelAmplitude.getRate: Single;
begin
  Result := m_fRate;
end;

function CCAccelDeccelAmplitude.initWithAction(pAction: CCAction;
  duration: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fRate := 1.0;
    m_pOther := CCActionInterval(pAction);
    pAction.retain();
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCAccelDeccelAmplitude.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_pOther.reverse(), m_fDuration);
end;

procedure CCAccelDeccelAmplitude.setRate(fRate: Single);
begin
  m_fRate := fRate;
end;

procedure CCAccelDeccelAmplitude.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pOther.startWithTarget(pTarget);
end;

procedure CCAccelDeccelAmplitude.update(time: Single);
var
  f: Single;
begin
  f := time * 2;
  if f > 1 then
  begin
    f := f - 1;
    f := 1 - f;
  end;
  CCAccelDeccelAmplitude(m_pOther).setAmplitudeRate(Power(f, m_fRate));
end;

{ CCAccelAmplitude }

class function CCAccelAmplitude._create(pAction: CCAction;
  duration: Single): CCAccelAmplitude;
var
  pRet: CCAccelAmplitude;
begin
  pRet := CCAccelAmplitude.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, duration) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCAccelAmplitude.Destroy;
begin
  CC_SAFE_RELEASE(m_pOther);
  inherited;
end;

function CCAccelAmplitude.getRate: Single;
begin
  Result := m_fRate;
end;

function CCAccelAmplitude.initWithAction(pAction: CCAction;
  duration: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fRate := 1.0;
    m_pOther := CCActionInterval(pAction);
    pAction.retain();
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCAccelAmplitude.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_pOther.reverse(), m_fDuration);
end;

procedure CCAccelAmplitude.setRate(fRate: Single);
begin
  m_fRate := fRate;
end;

procedure CCAccelAmplitude.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pOther.startWithTarget(pTarget);
end;

procedure CCAccelAmplitude.update(time: Single);
begin
  CCAccelAmplitude(m_pOther).setAmplitudeRate(Power(time, m_fRate));
  m_pOther.update(time);
end;

{ CCDeccelAmplitude }

class function CCDeccelAmplitude._create(pAction: CCAction;
  duration: Single): CCDeccelAmplitude;
var
  pRet: CCDeccelAmplitude;
begin
  pRet := CCDeccelAmplitude.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, duration) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCDeccelAmplitude.Destroy;
begin
  CC_SAFE_RELEASE(m_pOther);
  inherited;
end;

function CCDeccelAmplitude.getRate: Single;
begin
  Result := m_fRate;
end;

function CCDeccelAmplitude.initWithAction(pAction: CCAction;
  duration: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fRate := 1.0;
    m_pOther := CCActionInterval(pAction);
    pAction.retain();
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCDeccelAmplitude.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_pOther.reverse(), m_fDuration);
end;

procedure CCDeccelAmplitude.setRate(fRate: Single);
begin
  m_fRate := fRate;
end;

procedure CCDeccelAmplitude.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pOther.startWithTarget(pTarget);
end;

procedure CCDeccelAmplitude.update(time: Single);
begin
  CCDeccelAmplitude(m_pOther).setAmplitudeRate(Power(1 - time, m_fRate));
  m_pOther.update(time);
end;

{ CCStopGrid }

class function CCStopGrid._create: CCStopGrid;
var
  pRet: CCStopGrid;
begin
  pRet := CCStopGrid.Create();
  if (pRet <> nil) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCStopGrid.startWithTarget(pTarget: CCObject);
var
  pGrid: CCGridBase;
begin
  inherited startWithTarget(pTarget);
  pGrid := CCNode(m_pTarget).Grid;
  if (pGrid <> nil) and pGrid.isActive() then
  begin
    pGrid.setActive(False);
  end;  
end;

{ CCReuseGrid }

class function CCReuseGrid._create(times: Integer): CCReuseGrid;
var
  pRet: CCReuseGrid;
begin
  pRet := CCReuseGrid.Create();
  if (pRet <> nil) and pRet.initWithTimes(times)  then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCReuseGrid.initWithTimes(times: Integer): Boolean;
begin
  m_nTimes := times;
  Result := True;
end;

procedure CCReuseGrid.startWithTarget(pTarget: CCObject);
var
  pGrid: CCGridBase;
begin
  inherited startWithTarget(pTarget);
  pGrid := CCNode(m_pTarget).Grid;
  if (pGrid <> nil) and pGrid.isActive() then
  begin
    pGrid.setReuseGrid(pGrid.getReuseGrid() + m_nTimes);
  end;  
end;

end.
