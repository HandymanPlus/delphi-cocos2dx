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

unit Cocos2dx.CCActionTiledGrid;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCActionGrid, Cocos2dx.CCGrid, Cocos2dx.CCTypes,
  Cocos2dx.CCPointerArray, Cocos2dx.CCGeometry;

type
  CCShakyTiles3D = class(CCTiledGrid3DAction)
  public
    function initWithDuration(duration: Single; const gridSize: CCSize; nRange: Integer; bShakeZ: Boolean): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; nRange: Integer; bShakeZ: Boolean): CCShakyTiles3D;
  protected
    m_nRandrange: Integer;
    m_bShakeZ: Boolean;
  end;

  CCShatteredTiles3D = class(CCTiledGrid3DAction)
  public
    function initWithDuration(duration: Single; const gridSize: CCSize; nRange: Integer; bShatterZ: Boolean): Boolean;
    class function _create(duration: Single; const gridSize: CCSize; nRange: Integer; bShatterZ: Boolean): CCShatteredTiles3D;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
  protected
    m_nRandrange: Integer;
    m_bOnce: Boolean;
    m_bShatterZ: Boolean;
  end;

  TTile = record
    position: CCPoint;
    startPosition: CCPoint;
    delta: CCSize;
  end;
  PTTile = ^TTile;
  TTileArray = array [0..MaxInt div SizeOf(TTile) - 1] of TTile;
  PTTileArray = ^TTileArray;

  CCShuffleTiles = class(CCTiledGrid3DAction)
  public
    destructor Destroy(); override;
    function initWithDuration(duration: Single; const gridSize: CCSize; seed: Cardinal): Boolean;
    procedure shuffle(pArray: PUIntArray; nLen: Cardinal);
    function getDelta(const pos: CCSize): CCSize;
    procedure placeTile(const pos: CCPoint; t: PTTile);

    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;

    class function _create(duration: Single; const gridSize: CCSize; seed: Cardinal): CCShuffleTiles;
  protected
    m_nSeed: Cardinal;
    m_nTilesCount: Cardinal;
    m_pTilesOrder: PUIntArray;
    m_pTiles: PTTile;
  end;

  CCFadeOutTRTiles = class(CCTiledGrid3DAction)
  public
    function tesFunc(const pos: CCSize; time: Single): Single; virtual;
    procedure turnOnTile(const pos: CCPoint);
    procedure turnOffTile(const pos: CCPoint);
    procedure transformTile(const pos: CCPoint; distance: Single); virtual;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize): CCFadeoutTRTiles;
  end;

  CCFadeOutBLTiles = class(CCFadeOutTRTiles)
  public
    function tesFunc(const pos: CCSize; time: Single): Single; override;
    class function _create(duration: Single; const gridSize: CCSize): CCFadeOutBLTiles;
  end;

  CCFadeOutUpTiles = class(CCFadeOutTRTiles)
  public
    function tesFunc(const pos: CCSize; time: Single): Single; override;
    procedure transformTile(const pos: CCPoint; distance: Single); override;
    class function _create(duration: Single; const gridSize: CCSize): CCFadeOutUpTiles;
  end;

  CCFadeOutDownTiles = class(CCFadeOutUpTiles)
  public
    function tesFunc(const pos: CCSize; time: Single): Single; override;
    class function _create(duration: Single; const gridSize: CCSize): CCFadeOutDownTiles;
  end;

  CCTurnOffTiles = class(CCTiledGrid3DAction)
  public
    destructor Destroy(); override;
    function initWithDuration(duration: Single; const gridSize: CCSize; seed: Cardinal): Boolean;
    procedure shuffle(pArray: PUIntArray; nLen: Cardinal);
    procedure turnOnTile(const pos: CCPoint);
    procedure turnOffTile(const pos: CCPoint);

    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;

    class function _create(duration: Single; const gridSize: CCSize): CCTurnOffTiles; overload;
    class function _create(duration: Single; const gridSize: CCSize; seed: Cardinal): CCTurnOffTiles; overload;
  protected
    m_nSeed: Cardinal;
    m_nTilesCount: Cardinal;
    m_pTilesOrder: PUIntArray;
  end;

  CCWavesTiles3D = class(CCTiledGrid3DAction)
  public
    function getAmplitude(): Single;
    procedure setAmplitude(fAmplitude: Single);
    function getAmplitudeRate(): Single;
    procedure setAmplitudeRate(fAmplitudeRate: Single);
    function initWithDuration(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single): Boolean;

    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; waves: Cardinal; amplitude: Single): CCWavesTiles3D;
  protected
    m_nWaves: Cardinal;
    m_fAmplitude: Single;
    m_fAmplitudeRate: Single;
  end;

  CCJumpTiles3D = class(CCTiledGrid3DAction)
  public
    function getAmplitude(): Single;
    procedure setAmplitude(fAmplitude: Single);
    function getAmplitudeRate(): Single;
    procedure setAmplitudeRate(fAmplitudeRate: Single);

    function initWithDuration(duration: Single; const gridSize: CCSize; numberOfJumps: Cardinal; amplitude: Single): Boolean;

    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize; numberOfJumps: Cardinal; amplitude: Single): CCJumpTiles3D;
  protected
    m_nJumps: Cardinal;
    m_fAmplitude: Single;
    m_fAmplitudeRate: Single;
  end;

  CCSplitRows = class(CCTiledGrid3DAction)
  public
    function initWithDuration(duration: Single; nRows: Cardinal): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    class function _create(duration: Single; nRows: Cardinal): CCSplitRows;
  protected
    m_nRows: Cardinal;
    m_winSize: CCSize;
  end;

  CCSplitCols = class(CCTiledGrid3DAction)
  public
    function initWithDuration(duration: Single; nCols: Cardinal): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    class function _create(duration: Single; nCols: Cardinal): CCSplitCols;
  protected
    m_nCols: Cardinal;
    m_winSize: CCSize;
  end;

implementation
uses
  SysUtils, Math,
  Cocos2dx.CCDirector, Cocos2dx.CCPlatformMacros, Cocos2dx.CCNode, Cocos2dx.CCPointExtension;

{ CCShakyTiles3D }

class function CCShakyTiles3D._create(duration: Single; const gridSize: CCSize;
  nRange: Integer; bShakeZ: Boolean): CCShakyTiles3D;
var
  pRet: CCShakyTiles3D;
begin
  pRet := CCShakyTiles3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, nRange, bShakeZ) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCShakyTiles3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCShakyTiles3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCShakyTiles3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCShakyTiles3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nRandrange, m_bShakeZ);

  pNewZone.Free;

  Result := pRet;
end;

function CCShakyTiles3D.initWithDuration(duration: Single; const gridSize: CCSize;
  nRange: Integer; bShakeZ: Boolean): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nRandrange := nRange;
    m_bShakeZ := bShakeZ;
    Result := True;

    Randomize();
    Exit;
  end;
  Result := False;
end;

procedure CCShakyTiles3D.update(time: Single);
var
  i, j: Integer;
  coords: ccQuad3;
begin
  for i := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for j := 0 to Floor(m_sGridSize.height)-1 do
    begin
      coords := originalTile(ccp(i, j));

      coords.bl.x := coords.bl.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
      coords.br.x := coords.br.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
      coords.tl.x := coords.tl.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
      coords.tr.x := coords.tr.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;

      coords.bl.y := coords.bl.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
      coords.br.y := coords.br.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
      coords.tl.y := coords.tl.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
      coords.tr.y := coords.tr.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;

      if m_bShakeZ then
      begin
        coords.bl.z := coords.bl.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.br.z := coords.br.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.tl.z := coords.tl.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.tr.z := coords.tr.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
      end;

      setTile(ccp(i, j), coords);
    end;
  end;  
end;

{ CCShatteredTiles3D }

class function CCShatteredTiles3D._create(duration: Single;
  const gridSize: CCSize; nRange: Integer;
  bShatterZ: Boolean): CCShatteredTiles3D;
var
  pRet: CCShatteredTiles3D;
begin
  pRet := CCShatteredTiles3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, nRange, bShatterZ) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCShatteredTiles3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCShatteredTiles3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCShatteredTiles3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCShatteredTiles3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nRandrange, m_bShatterZ);

  pNewZone.Free;

  Result := pRet;
end;

function CCShatteredTiles3D.initWithDuration(duration: Single;
  const gridSize: CCSize; nRange: Integer;
  bShatterZ: Boolean): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_bOnce := False;
    m_nRandrange := nRange;
    m_bShatterZ := bShatterZ;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCShatteredTiles3D.update(time: Single);
var
  i, j: Integer;
  coords: ccQuad3;
begin
  if not m_bOnce then
  begin
    for i := 0 to Floor(m_sGridSize.width)-1 do
    begin
      for j := 0 to Floor(m_sGridSize.height)-1 do
      begin
        coords := originalTile(ccp(i, j));

        coords.bl.x := coords.bl.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.br.x := coords.br.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.tl.x := coords.tl.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.tr.x := coords.tr.x + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;

        coords.bl.y := coords.bl.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.br.y := coords.br.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.tl.y := coords.tl.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        coords.tr.y := coords.tr.y + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;

        if m_bShatterZ then
        begin
          coords.bl.z := coords.bl.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
          coords.br.z := coords.br.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
          coords.tl.z := coords.tl.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
          coords.tr.z := coords.tr.z + RandomRange(0, m_nRandrange * 2 - 1) - m_nRandrange;
        end;

        setTile(ccp(i, j), coords);
      end;
    end;
    
    m_bOnce := True;
  end;
end;

{ CCShuffleTiles }

class function CCShuffleTiles._create(duration: Single; const gridSize: CCSize;
  seed: Cardinal): CCShuffleTiles;
var
  pRet: CCShuffleTiles;
begin
  pRet := CCShuffleTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, seed) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCShuffleTiles.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCShuffleTiles;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCShuffleTiles(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCShuffleTiles.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nSeed);

  pNewZone.Free;

  Result := pRet;
end;

destructor CCShuffleTiles.Destroy;
begin
  CC_SAFE_FREE_POINTER(m_pTilesOrder);
  CC_SAFE_FREE_POINTER(m_pTiles);
  inherited;
end;

function CCShuffleTiles.getDelta(const pos: CCSize): CCSize;
var
  pos2: CCPoint;
  idx: Cardinal;
begin
  idx := Floor(pos.width * m_sGridSize.height + pos.height);

  pos2.x := m_pTilesOrder[idx] / m_sGridSize.height;
  pos2.y := m_pTilesOrder[idx] mod Round(m_sGridSize.height);

  Result := CCSizeMake(Round(pos2.x - pos.width), Round(pos2.y - pos.height));
end;

function CCShuffleTiles.initWithDuration(duration: Single; const gridSize: CCSize;
  seed: Cardinal): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nSeed := seed;
    m_pTilesOrder := nil;
    m_pTiles := nil;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCShuffleTiles.placeTile(const pos: CCPoint; t: PTTile);
var
  coords: ccQuad3;
  step: CCPoint;
begin
  coords := originalTile(pos);

  step := CCNode(m_pTarget).Grid.getStep();
  coords.bl.x := coords.bl.x + t.position.x * step.x;
  coords.bl.y := coords.bl.y + t.position.y * step.y;

  coords.br.x := coords.br.x + t.position.x * step.x;
  coords.br.y := coords.br.y + t.position.y * step.y;

  coords.tl.x := coords.tl.x + t.position.x * step.x;
  coords.tl.y := coords.tl.y + t.position.y * step.y;

  coords.tr.x := coords.tr.x + t.position.x * step.x;
  coords.tr.y := coords.tr.y + t.position.y * step.y;

  setTile(pos, coords);
end;

procedure CCShuffleTiles.shuffle(pArray: PUIntArray; nLen: Cardinal);
var
  i, v: Integer;
  j: Cardinal;
begin
  for i := nLen-1 downto 0 do
  begin
    j := RandomRange(0, i);
    v := pArray[i];
    pArray[i] := pArray[j];
    pArray[j] := v;
  end;  
end;

procedure CCShuffleTiles.startWithTarget(pTarget: CCObject);
var
  i, j: Integer;
  k: Cardinal;
  tileArray: PTTile;
begin
  inherited startWithTarget(pTarget);

  if m_nSeed <> Cardinal(-1) then
  begin
    Randomize();
  end;

  m_nTilesCount := Round(m_sGridSize.width * m_sGridSize.height);
  if m_pTilesOrder = nil then  //added by myself
    m_pTilesOrder := AllocMem(SizeOf(Integer) * m_nTilesCount);

  for k := 0 to m_nTilesCount - 1 do
  begin
    m_pTilesOrder[k] := k;
  end;

  shuffle(m_pTilesOrder, m_nTilesCount);

  if m_pTiles = nil then  //added by myself
    m_pTiles := AllocMem(SizeOf(TTile) * m_nTilesCount);
  tileArray := m_pTiles;

  for i := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for j := 0 to Floor(m_sGridSize.height)-1 do
    begin
      tileArray^.position := ccp(i, j);
      tileArray^.startPosition := ccp(i, j);
      tileArray^.delta := getDelta(CCSizeMake(i, j));
      Inc(tileArray);
    end;  
  end;  
end;

procedure CCShuffleTiles.update(time: Single);
var
  i, j: Integer;
  tileArray: PTTile;
begin
  tileArray := m_pTiles;
  for i := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for j := 0 to Floor(m_sGridSize.height)-1 do
    begin
      tileArray^.position := ccpMult( ccp(tileArray^.delta.width, tileArray^.delta.height), time );
      placeTile(ccp(i, j), tileArray);
      Inc(tileArray);
    end;
  end;
end;

{ CCFadeOutTRTiles }

class function CCFadeOutTRTiles._create(duration: Single;
  const gridSize: CCSize): CCFadeoutTRTiles;
var
  pRet: CCFadeOutTRTiles;
begin
  pRet := CCFadeOutTRTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFadeOutTRTiles.tesFunc(const pos: CCSize; time: Single): Single;
var
  n: CCPoint;
begin
  n := ccpMult( ccp(m_sGridSize.width, m_sGridSize.height), time );
  if IsZero(n.x + n.y) then
  begin
    Result := 1.0;
    Exit;
  end;
  Result := Power((pos.width + pos.height)/(n.x + n.y), 6);
end;

procedure CCFadeOutTRTiles.transformTile(const pos: CCPoint;
  distance: Single);
var
  coords: ccQuad3;
  step: CCPoint;
begin
  coords := originalTile(pos);
  step := CCNode(m_pTarget).Grid.getStep();

  coords.bl.x := coords.bl.x + (step.x * 0.5) * (1.0 - distance);
  coords.bl.y := coords.bl.y + (step.y * 0.5) * (1.0 - distance);

  coords.br.x := coords.br.x - (step.x * 0.5) * (1.0 - distance);
  coords.br.y := coords.br.y + (step.y * 0.5) * (1.0 - distance);

  coords.tl.x := coords.tl.x + (step.x * 0.5) * (1.0 - distance);
  coords.tl.y := coords.tl.y - (step.y * 0.5) * (1.0 - distance);

  coords.tr.x := coords.tr.x - (step.x * 0.5) * (1.0 - distance);
  coords.tr.y := coords.tr.y - (step.y * 0.5) * (1.0 - distance);

  setTile(pos, coords);
end;

procedure CCFadeOutTRTiles.turnOffTile(const pos: CCPoint);
var
  coords: ccQuad3;
begin
  FillChar(coords, SizeOf(coords), 0);
  setTile(pos, coords);
end;

procedure CCFadeOutTRTiles.turnOnTile(const pos: CCPoint);
begin
  setTile(pos, originalTile(pos));
end;

procedure CCFadeOutTRTiles.update(time: Single);
var
  i, j: Integer;
  distance: Single;
begin
  for i := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for j := 0 to Floor(m_sGridSize.height)-1 do
    begin
      distance := tesFunc(CCSizeMake(i, j), time);
      if IsZero(distance) then
      begin
        turnOffTile(ccp(i, j));
      end else if distance < 1 then
      begin
        transformTile(ccp(i, j), distance);
      end else
      begin
        turnOnTile(ccp(i, j));
      end;      
    end;  
  end;  
end;

{ CCFadeOutBLTiles }

class function CCFadeOutBLTiles._create(duration: Single;
  const gridSize: CCSize): CCFadeOutBLTiles;
var
  pRet: CCFadeOutBLTiles;
begin
  pRet := CCFadeOutBLTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFadeOutBLTiles.tesFunc(const pos: CCSize;
  time: Single): Single;
var
  n: CCPoint;
begin
  n := ccpMult(ccp(m_sGridSize.width, m_sGridSize.height), 1.0 - time);
  if IsZero(pos.width + pos.height) then
  begin
    Result := 1.0;
    Exit;
  end;
  Result := Power((n.x + n.y) / (pos.width + pos.height), 6);
end;

{ CCFadeOutUpTiles }

class function CCFadeOutUpTiles._create(duration: Single;
  const gridSize: CCSize): CCFadeOutUpTiles;
var
  pRet: CCFadeOutUpTiles;
begin
  pRet := CCFadeOutUpTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFadeOutUpTiles.tesFunc(const pos: CCSize;
  time: Single): Single;
var
  n: CCPoint;
begin
  n := ccpMult(ccp(m_sGridSize.width, m_sGridSize.height), time);
  if IsZero(n.y) then
  begin
    Result := 1.0;
    Exit;
  end;
  Result := Power(pos.height / n.y, 6);
end;

procedure CCFadeOutUpTiles.transformTile(const pos: CCPoint;
  distance: Single);
var
  coords: ccQuad3;
  step: CCPoint;
begin
  coords := originalTile(pos);
  step := CCNode(m_pTarget).Grid.getStep();

  coords.bl.y := coords.bl.y + (step.y * 0.5) * (1.0 - distance);
  coords.br.y := coords.br.y + (step.y * 0.5) * (1.0 - distance);
  coords.tl.y := coords.tl.y - (step.y * 0.5) * (1.0 - distance);
  coords.tr.y := coords.tr.y - (step.y * 0.5) * (1.0 - distance);

  setTile(pos, coords);
end;

{ CCFadeOutDownTiles }

class function CCFadeOutDownTiles._create(duration: Single;
  const gridSize: CCSize): CCFadeOutDownTiles;
var
  pRet: CCFadeOutDownTiles;
begin
  pRet := CCFadeOutDownTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCFadeOutDownTiles.tesFunc(const pos: CCSize;
  time: Single): Single;
var
  n: CCPoint;
begin
  n := ccpMult(ccp(m_sGridSize.width, m_sGridSize.height), 1.0 - time);
  if IsZero(pos.height) then
  begin
    Result := 1.0;
    Exit;
  end;
  Result := Power(n.y / pos.height, 6);
end;

{ CCTurnOffTiles }

class function CCTurnOffTiles._create(duration: Single; const gridSize: CCSize): CCTurnOffTiles;
var
  pRet: CCTurnOffTiles;
begin
  pRet := CCTurnOffTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, 0) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCTurnOffTiles._create(duration: Single; const gridSize: CCSize;
  seed: Cardinal): CCTurnOffTiles;
var
  pRet: CCTurnOffTiles;
begin
  pRet := CCTurnOffTiles.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, seed) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTurnOffTiles.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCTurnOffTiles;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCTurnOffTiles(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCTurnOffTiles.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nSeed );

  pNewZone.Free;

  Result := pRet;
end;

destructor CCTurnOffTiles.Destroy;
begin
  CC_SAFE_FREE_POINTER(m_pTilesOrder);
  inherited;
end;

function CCTurnOffTiles.initWithDuration(duration: Single; const gridSize: CCSize;
  seed: Cardinal): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nSeed := seed;
    m_pTilesOrder := nil;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCTurnOffTiles.shuffle(pArray: PUIntArray; nLen: Cardinal);
var
  i, v: Cardinal;
  j: Cardinal;
begin
  for i := nLen-1 downto 0 do
  begin
    j := RandomRange(0, i);
    v := pArray[i];
    pArray[i] := pArray[j];
    pArray[j] := v;
  end;  
end;

procedure CCTurnOffTiles.startWithTarget(pTarget: CCObject);
var
  i: Cardinal;
begin
  inherited startWithTarget(pTarget);

  if m_nSeed <> Cardinal(-1) then
  begin
    Randomize();
  end;

  m_nTilesCount := Round(m_sGridSize.width * m_sGridSize.height);
  if m_pTilesOrder = nil then  //added by myself
    m_pTilesOrder := AllocMem(SizeOf(Cardinal) * m_nTilesCount);

  for i := 0 to m_nTilesCount-1 do
  begin
    m_pTilesOrder[i] := i;
  end;

  shuffle(m_pTilesOrder, m_nTilesCount);
end;

procedure CCTurnOffTiles.turnOffTile(const pos: CCPoint);
var
  coords: ccQuad3;
begin
  FillChar(coords, SizeOf(coords), 0);
  setTile(pos, coords);
end;

procedure CCTurnOffTiles.turnOnTile(const pos: CCPoint);
begin
  setTile(pos, originalTile(pos));
end;

procedure CCTurnOffTiles.update(time: Single);
var
  i, l, t: Integer;
  tilePos: CCPoint;
begin
  l := Round(time * m_nTilesCount);

  for i := 0 to m_nTilesCount-1 do
  begin
    t := m_pTilesOrder[i];
    tilePos := ccp(t div Round(m_sGridSize.height), t mod Round(m_sGridSize.height));

    if i < l then
      turnOffTile(tilePos)
    else
      turnOnTile(tilePos);
  end;
end;

{ CCWavesTiles3D }

class function CCWavesTiles3D._create(duration: Single; const gridSize: CCSize;
  waves: Cardinal; amplitude: Single): CCWavesTiles3D;
var
  pRet: CCWavesTiles3D;
begin
  pRet := CCWavesTiles3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, waves, amplitude) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCWavesTiles3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCWavesTiles3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCWavesTiles3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCWavesTiles3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nWaves, m_fAmplitude);

  pNewZone.Free;

  Result := pRet;
end;

function CCWavesTiles3D.getAmplitude: Single;
begin
  Result := m_fAmplitude;
end;

function CCWavesTiles3D.getAmplitudeRate: Single;
begin
  Result := m_fAmplitudeRate;
end;

function CCWavesTiles3D.initWithDuration(duration: Single; const gridSize: CCSize;
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

procedure CCWavesTiles3D.setAmplitude(fAmplitude: Single);
begin
  m_fAmplitude := fAmplitude;
end;

procedure CCWavesTiles3D.setAmplitudeRate(fAmplitudeRate: Single);
begin
  m_fAmplitudeRate := fAmplitudeRate;
end;

procedure CCWavesTiles3D.update(time: Single);
var
  i, j: Integer;
  coors: ccQuad3;
begin
  for i := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for j := 0 to Floor(m_sGridSize.height)-1 do
    begin
      coors := originalTile(ccp(i, j));

      coors.bl.z := Sin(time * Pi * m_nWaves * 2 + (coors.bl.y + coors.bl.x) * 0.01) * m_fAmplitude * m_fAmplitudeRate;
      coors.br.z := coors.bl.z;
      coors.tl.z := coors.bl.z;
      coors.tr.z := coors.bl.z;

      setTile(ccp(i, j), coors);
    end;  
  end;  
end;

{ CCJumpTiles3D }

class function CCJumpTiles3D._create(duration: Single; const gridSize: CCSize;
  numberOfJumps: Cardinal; amplitude: Single): CCJumpTiles3D;
var
  pRet: CCJumpTiles3D;
begin
  pRet := CCJumpTiles3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize, numberOfJumps, amplitude) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCJumpTiles3D.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCJumpTiles3D;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCJumpTiles3D(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCJumpTiles3D.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_sGridSize, m_nJumps, m_fAmplitude);

  pNewZone.Free;

  Result := pRet;
end;

function CCJumpTiles3D.getAmplitude: Single;
begin
  Result := m_fAmplitude;
end;

function CCJumpTiles3D.getAmplitudeRate: Single;
begin
  Result := m_fAmplitudeRate;
end;

function CCJumpTiles3D.initWithDuration(duration: Single; const gridSize: CCSize;
  numberOfJumps: Cardinal; amplitude: Single): Boolean;
begin
  if inherited initWithDuration(duration, gridSize) then
  begin
    m_nJumps := numberOfJumps;
    m_fAmplitude := amplitude;
    m_fAmplitudeRate := 1.0;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCJumpTiles3D.setAmplitude(fAmplitude: Single);
begin
  m_fAmplitude := fAmplitude;
end;

procedure CCJumpTiles3D.setAmplitudeRate(fAmplitudeRate: Single);
begin
  m_fAmplitudeRate := fAmplitudeRate;
end;

procedure CCJumpTiles3D.update(time: Single);
var
  i, j: Integer;
  sinz, sinz2: Single;
  coords: ccQuad3;
begin
  sinz := Sin(Pi * time * m_nJumps * 2) * m_fAmplitude * m_fAmplitudeRate;
  sinz2 := Sin(Pi * (time * m_nJumps * 2 + 1)) * m_fAmplitude * m_fAmplitudeRate;
  for i := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for j := 0 to Floor(m_sGridSize.height)-1 do
    begin
      coords := originalTile(ccp(i, j));
      if (i + j) mod 2 = 0 then
      begin
        coords.bl.z := coords.bl.z + sinz;
        coords.br.z := coords.br.z + sinz;
        coords.tl.z := coords.tl.z + sinz;
        coords.tr.z := coords.tr.z + sinz;
      end else
      begin
        coords.bl.z := coords.bl.z + sinz2;
        coords.br.z := coords.br.z + sinz2;
        coords.tl.z := coords.tl.z + sinz2;
        coords.tr.z := coords.tr.z + sinz2;
      end;
      setTile(ccp(i, j), coords);
    end;  
  end;  
end;

{ CCSplitRows }

class function CCSplitRows._create(duration: Single; nRows: Cardinal): CCSplitRows;
var
  pRet: CCSplitRows;
begin
  pRet := CCSplitRows.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, nRows) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCSplitRows.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCSplitRows;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCSplitRows(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCSplitRows.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_nRows);

  pNewZone.Free;

  Result := pRet;
end;

function CCSplitRows.initWithDuration(duration: Single; nRows: Cardinal): Boolean;
begin
  m_nRows := nRows;
  Result := inherited initWithDuration(duration, CCSizeMake(1, nRows));
end;

procedure CCSplitRows.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_winSize := CCDirector.sharedDirector().getWinSizeInPixels();
end;

procedure CCSplitRows.update(time: Single);
var
  j: Integer;
  coords: ccQuad3;
  direction: Single;
begin
  for j := 0 to Floor(m_sGridSize.height)-1 do
  begin
    coords := originalTile(ccp(0, j));
    direction := 1;

    if j mod 2 = 0 then
      direction := -1;

    coords.bl.x := coords.bl.x + direction * m_winSize.width * time;
    coords.br.x := coords.br.x + direction * m_winSize.width * time;
    coords.tl.x := coords.tl.x + direction * m_winSize.width * time;
    coords.tr.x := coords.tr.x + direction * m_winSize.width * time;

    setTile(ccp(0, j), coords);
  end;
end;

{ CCSplitCols }

class function CCSplitCols._create(duration: Single; nCols: Cardinal): CCSplitCols;
var
  pRet: CCSplitCols;
begin
  pRet := CCSplitCols.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, nCols) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCSplitCols.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCSplitCols;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCSplitCols(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCSplitCols.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_nCols);

  pNewZone.Free;

  Result := pRet;
end;

function CCSplitCols.initWithDuration(duration: Single; nCols: Cardinal): Boolean;
begin
  m_nCols := nCols;
  Result := inherited initWithDuration(duration, CCSizeMake(nCols, 1));
end;

procedure CCSplitCols.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_winSize := CCDirector.sharedDirector().getWinSizeInPixels();
end;

procedure CCSplitCols.update(time: Single);
var
  i: Integer;
  coords: ccQuad3;
  direction: Single;
begin
  for i := 0 to Floor(m_sGridSize.width)-1 do
  begin
    coords := originalTile(ccp(i, 0));
    direction := 1;

    if i mod 2 = 0 then
      direction := -1;

    coords.bl.y := coords.bl.y + direction * m_winSize.height * time;
    coords.br.y := coords.br.y + direction * m_winSize.height * time;
    coords.tl.y := coords.tl.y + direction * m_winSize.height * time;
    coords.tr.y := coords.tr.y + direction * m_winSize.height * time;

    setTile(ccp(i, 0), coords);
  end;  
end;

end.
