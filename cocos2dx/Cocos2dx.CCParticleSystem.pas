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

unit Cocos2dx.CCParticleSystem;

interface

{$I config.inc}

uses                      
  Cocos2dx.CCTypes, Cocos2dx.CCGeometry, Cocos2dx.CCTexture2D, Cocos2dx.CCNode,
  Cocos2dx.CCObject, Cocos2dx.CCDictionary;

    //** The Particle emitter lives forever */
const    kCCParticleDurationInfinity = -1;
    //** The starting size of the particle is equal to the ending size */
const    kCCParticleStartSizeEqualToEndSize = -1;
    //** The starting radius of the particle is equal to the ending radius */
const    kCCParticleStartRadiusEqualToEndRadius = -1;
    // backward compatible
const    kParticleStartSizeEqualToEndSize = kCCParticleStartSizeEqualToEndSize;
const    kParticleDurationInfinity = kCCParticleDurationInfinity;



    //** Gravity mode (A mode) */
const    kCCParticleModeGravity = 0;
    //** Radius mode (B mode) */
const    kCCParticleModeRadius = 1;

type
  tCCPositionType = (
    //** Living particles are attached to the world and are unaffected by emitter repositioning. */
    kCCPositionTypeFree,

    (** Living particles are attached to the world but will follow the emitter repositioning.
    Use case: Attach an emitter to an sprite, and you want that the emitter follows the sprite.
    *)
    kCCPositionTypeRelative,

    //** Living particles are attached to the emitter and are translated along with it. */
    kCCPositionTypeGrouped
  );

const    kPositionTypeFree = Ord(kCCPositionTypeFree);
const    kPositionTypeGrouped = Ord(kCCPositionTypeGrouped);

type
  (**
    Structure that contains the values of each particle
    *)
  sCCParticle = record
    pos: CCPoint;
    startPos: CCPoint;

    color: ccColor4F;
    deltaColor: ccColor4F;

    size: Single;
    deltaSize: Single;

    rotation: Single;
    deltaRotation: Single;

    timeToLive: Single;

    atlasIndex: Cardinal;

    //! Mode A: gravity, direction, radial accel, tangential accel
    modeA: record
      dir: CCPoint;
      radialAccel: Single;
      tangentialAccel: Single;
    end;

    //! Mode B: radius mode
    modeB: record
      angle: Single;
      degressPerSecond: Single;
      radius: Single;
      deltaRadius: Single;
    end;
  end;
  tCCParticle = sCCParticle;
  pCCParticle = ^tCCParticle;
  tCCParticleArray = array [0..MaxInt div SizeOf(tCCParticle) - 1] of tCCParticle;
  pCCParticleArray = ^tCCParticleArray;

  //! Mode A:Gravity + Tangential Accel + Radial Accel
  TParticleSystemInnerModeA = record
    gravity: CCPoint;            //** Gravity value. Only available in 'Gravity' mode. */
    speed: Single;               //** speed of each particle. Only available in 'Gravity' mode.  */
    speedVar: Single;            //** speed variance of each particle. Only available in 'Gravity' mode. */
    tangentialAccel: Single;     //** tangential acceleration of each particle. Only available in 'Gravity' mode. */
    tangentialAccelVar: Single;  //** tangential acceleration variance of each particle. Only available in 'Gravity' mode. */
    radialAccel: Single;         //** radial acceleration of each particle. Only available in 'Gravity' mode. */
    radialAccelVar: Single;      //** radial acceleration variance of each particle. Only available in 'Gravity' mode. */
    rotationIsDir: Boolean;      //** set the rotation of each particle to its direction Only available in 'Gravity' mode. */
  end;

  //! Mode B: circular movement (gravity, radial accel and tangential accel don't are not used in this mode)
  TParticleSystemInnerModeB = record
    startRadius: Single;        //** The starting radius of the particles. Only available in 'Radius' mode. */
    startRadiusVar: Single;     //** The starting radius variance of the particles. Only available in 'Radius' mode. */
    endRadius: Single;          //** The ending radius of the particles. Only available in 'Radius' mode. */
    endRadiusVar: Single;       //** The ending radius variance of the particles. Only available in 'Radius' mode. */
    rotatePerSecond: Single;    //** Number of degrees to rotate a particle around the source pos per second. Only available in 'Radius' mode. */
    rotatePerSecondVar: Single; //** Variance in degrees for rotatePerSecond. Only available in 'Radius' mode. */
  end;

type
  (** @brief Particle System base class.
    Attributes of a Particle System:
    - emission rate of the particles
    - Gravity Mode (Mode A):
    - gravity
    - direction
    - speed +-  variance
    - tangential acceleration +- variance
    - radial acceleration +- variance
    - Radius Mode (Mode B):
    - startRadius +- variance
    - endRadius +- variance
    - rotate +- variance
    - Properties common to all modes:
    - life +- life variance
    - start spin +- variance
    - end spin +- variance
    - start size +- variance
    - end size +- variance
    - start color +- variance
    - end color +- variance
    - life +- variance
    - blending function
    - texture

    cocos2d also supports particles generated by Particle Designer (http://particledesigner.71squared.com/).
    'Radius Mode' in Particle Designer uses a fixed emit rate of 30 hz. Since that can't be guaranteed in cocos2d,
    cocos2d uses a another approach, but the results are almost identical. 

    cocos2d supports all the variables used by Particle Designer plus a bit more:
    - spinning particles (supported when using CCParticleSystemQuad)
    - tangential acceleration (Gravity mode)
    - radial acceleration (Gravity mode)
    - radius direction (Radius mode) (Particle Designer supports outwards to inwards direction only)

    It is possible to customize any of the above mentioned properties in runtime. Example:

    @code
    emitter.radialAccel = 15;
    emitter.startSpin = 0;
    @endcode

    *)
  CCParticleSystem = class(CCNode)
  protected
    procedure setBatchNode(const Value: CCObject); virtual;
    procedure setTotalParticles(const Value: Cardinal); virtual;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(const plistFile: string): CCParticleSystem;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleSystem;
    function init(): Boolean; override;
    function initWithFile(const plistFile: string): Boolean;
    function initWithDictionary(dict: CCDictionary): Boolean; overload;
    function initWithDictionary(dict: CCDictionary; const dirname: string): Boolean; overload;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; virtual;
    function addParticle(): Boolean;
    procedure initParticle(particle: pCCParticle);
    procedure stopSystem();
    procedure resetSystem();
    function isFull(): Boolean;
    procedure updateQuadWithParticle(particle: pCCParticle; const newPosition: CCPoint); virtual;
    procedure postStep(); virtual;
    procedure updateWithNoTime(); virtual;
  protected
    m_sPlistFile: string;
    m_fElapsed: Single;
    modeB: TParticleSystemInnerModeB;
    modeA: TParticleSystemInnerModeA;
    m_pParticles: pCCParticleArray;
    m_fEmitCounter: Single;
    m_uParticleIdx: Cardinal;
    m_bTransformSystemDirty: Boolean;
    m_uAllocatedParticles: Cardinal;
    m_bIsActive: Boolean;
    m_nEmitterMode: Integer;
    m_ePositionType: tCCPositionType;
    m_bOpacityModifyRGB: Boolean;
    m_tBlendFunc: ccBlendFunc;
    m_pTexture: CCTexture2D;
    m_uTotalParticles: Cardinal;
    m_fEmissionRate: Single;
    m_fEndSpinVar: Single;
    m_fEndSpin: Single;
    m_fStartSpinVar: Single;
    m_fStartSpin: Single;
    m_tEndColorVar: ccColor4F;
    m_tEndColor: ccColor4F;
    m_tStartColorVar: ccColor4F;
    m_tStartColor: ccColor4F;
    m_fEndSize: Single;
    m_fEndSizeVar: Single;
    m_fStartSizeVar: Single;
    m_fStartSize: Single;
    m_fAngleVar: Single;
    m_fAngle: Single;
    m_fLifeVar: Single;
    m_fLife: Single;
    m_tPosVar: CCPoint;
    m_tSourcePosition: CCPoint;
    m_fDuration: Single;
    m_uParticleCount: Cardinal;
    m_uAtlasIndex: Cardinal;
    m_pBatchNode: CCObject;{CCParticleBatchNode}
    m_bIsAutoRemoveOnFinish: Boolean;
    procedure updateBlendFunc(); virtual;
  public
    m_bIsBlendAdditive: Boolean;
    //mode a
    function getGravity(): CCPoint; virtual;
    procedure setGravity(const g: CCPoint); virtual;
    function getSpeed(): Single; virtual;
    procedure setSpeed(speed: Single); virtual;
    function getSpeedVar(): Single; virtual;
    procedure setSpeedVar(speed: Single); virtual;
    function getTangentialAccel(): Single; virtual;
    procedure setTangentialAccel(t: Single); virtual;
    function getTangentialAccelVar(): Single; virtual;
    procedure setTangentialAccelVar(t: Single); virtual;
    function getRadialAccel(): Single; virtual;
    procedure setRadialAccel(t: Single); virtual;
    function getRadialAccelVar(): Single; virtual;
    procedure setRadialAccelVar(t: Single); virtual;
    function getRotationIsDir(): Boolean; virtual;
    procedure setRotationisDir(t: Boolean); virtual;
    //mode b
    function getStartRadius(): Single; virtual;
    procedure setStartRadius(startRadius: Single); virtual;
    function getStartRadiusVar(): Single; virtual;
    procedure setStartRadiusVar(startRadiusVar: Single); virtual;
    function getEndRadius(): Single; virtual;
    procedure setEndRadius(endRadius: Single); virtual;
    function getEndRadiusVar(): Single; virtual;
    procedure setEndRadiusVar(endRadiusVar: Single); virtual;
    function getRotatePerSecond(): Single; virtual;
    procedure setRotatePerSecond(degrees: Single); virtual;
    function getRotatePerSecondVar(): Single; virtual;
    procedure setRotatePerSecondVar(degrees: Single); virtual;

    function isActive(): Boolean; virtual;
    function isBlendAdditive(): Boolean; virtual;
    procedure setBlendAdditive(value: Boolean); virtual;

    function isAutoRemoveOnFinish(): Boolean; virtual;
    procedure setAutoRemoveOnFinish(value: Boolean); virtual;

    procedure setRotation(const Value: Single); override;
    procedure setScaleX(const Value: Single); override;
    procedure setScaleY(const Value: Single); override;
    procedure setScale(scale: Single); override;
    procedure update(time: Single); override;
    //interface
    //
    function getTexture(): CCTexture2D; override;
    procedure setTexture(texture: CCTexture2D); override;
    //
    procedure setBlendFunc(blendFunc: ccBlendFunc); override;
    function getBlendFunc(): ccBlendFunc; override;
  public
    function getAngle: Single;
    function getAngleVar: Single;
    function getAtlasIndex: Cardinal;
    function getBatchNode: CCObject;
    function getDuration: Single;
    function getEmissionRate: Single;
    function getEmitterMode: Integer;
    function getEndColor: ccColor4F;
    function getEndColorVar: ccColor4F;
    function getEndSize: Single;
    function getEndSizeVar: Single;
    function getEndSpin: Single;
    function getEndSpinVar: Single;
    function getLife: Single;
    function getLifeVar: Single;
    function getParticleCount: Cardinal;
    function getPositionType: tCCPositionType;
    function getPosVar: CCPoint;
    function getSourcePosition: CCPoint;
    function getStartColor: ccColor4F;
    function getStartColorVar: ccColor4F;
    function getStartSize: Single;
    function getStartSizeVar: Single;
    function getStartSpin: Single;
    function getStartSpinVar: Single;
    function getTotalParticles: Cardinal;
    procedure setAngle(const Value: Single);
    procedure setAngleVar(const Value: Single);
    procedure setAtlasIndex(const Value: Cardinal);
    procedure setDuration(const Value: Single);
    procedure setEmissionRate(const Value: Single);
    procedure setEmitterMode(const Value: Integer);
    procedure setEndColor(const Value: ccColor4F);
    procedure setEndColorVar(const Value: ccColor4F);
    procedure setEndSize(const Value: Single);
    procedure setEndSizeVar(const Value: Single);
    procedure setEndSpin(const Value: Single);
    procedure setEndSpinVar(const Value: Single);
    procedure setLife(const Value: Single);
    procedure setLifeVar(const Value: Single);
    procedure setPositionType(const Value: tCCPositionType);
    procedure setPosVar(const Value: CCPoint);
    procedure setSourcePosition(const Value: CCPoint);
    procedure setStartColor(const Value: ccColor4F);
    procedure setStartColorVar(const Value: ccColor4F);
    procedure setStartSize(const Value: Single);
    procedure setStartSizeVar(const Value: Single);
    procedure setStartSpin(const Value: Single);
    procedure setStartSpinVar(const Value: Single);
    function _isOpacityModifyRGB: Boolean;
    procedure _setOpacityModifyRGB(const Value: Boolean);
  public
    property OpacityModifyRGB: Boolean read _isOpacityModifyRGB write _setOpacityModifyRGB;
    property BatchNode: CCObject read getBatchNode write setBatchNode;
    property AtlasIndex: Cardinal read getAtlasIndex write setAtlasIndex;
    property ParticleCount: Cardinal read getParticleCount;
    property Duration: Single read getDuration write setDuration;
    property SourcePosition: CCPoint read getSourcePosition write setSourcePosition;
    property PosVar: CCPoint read getPosVar write setPosVar;
    property Life: Single read getLife write setLife;
    property LifeVar: Single read getLifeVar write setLifeVar;
    property Angle: Single read getAngle write setAngle;
    property AngleVar: Single read getAngleVar write setAngleVar;
    property StartSize: Single read getStartSize write setStartSize;
    property StartSizeVar: Single read getStartSizeVar write setStartSizeVar;
    property EndSize: Single read getEndSize write setEndSize;
    property EndSizeVar: Single read getEndSizeVar write setEndSizeVar;
    property StartColor: ccColor4F read getStartColor write setStartColor;
    property StartColorVar: ccColor4F read getStartColorVar write setStartColorVar;
    property EndColor: ccColor4F read getEndColor write setEndColor;
    property EndColorVar: ccColor4F read getEndColorVar write setEndColorVar;
    property StartSpin: Single read getStartSpin write setStartSpin;
    property StartSpinVar: Single read getStartSpinVar write setStartSpinVar;
    property EndSpin: Single read getEndSpin write setEndSpin;
    property EndSpinVar: Single read getEndSpinVar write setEndSpinVar;
    property EmissionRate: Single read getEmissionRate write setEmissionRate;
    property TotalParticles: Cardinal read getTotalParticles write setTotalParticles;
    property PositionType: tCCPositionType read getPositionType write setPositionType;
    property EmitterMode: Integer read getEmitterMode write setEmitterMode;
  end;

implementation
uses
  {$if defined(CrossPlatform) or defined(Delphi7Up)}
  ZLib,
  {$else}
  ZLibEx,
  {$ifend}
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils, Math, Classes, Cocos2dx.CCStrUtils,
  Cocos2dx.CCFileUtils, Cocos2dx.CCImage, Cocos2dx.CCPointExtension, base64,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCCommon, Cocos2dx.CCMacros, 
  Cocos2dx.CCTextureCache, Cocos2dx.CCParticleBatchNode;

{$if defined(CrossPlatform) or defined(Delphi7Up)}
//moved from ZLibEx
procedure ZInternalDecompress(zstream: TZStreamRec; const inBuffer: Pointer;
  inSize: Integer; out outBuffer: Pointer; out outSize: Integer;
  outEstimate: Integer);
var
  delta: Integer;
begin
  delta := (inSize + 255) and not 255;

  if outEstimate = 0 then outSize := delta
  else outSize := outEstimate;

  GetMem(outBuffer,outSize);

  try
    try
      zstream.next_in := inBuffer;
      zstream.avail_in := inSize;
      zstream.next_out := outBuffer;
      zstream.avail_out := outSize;

      while inflate(zstream,Z_NO_FLUSH) <> Z_STREAM_END do
      begin
        Inc(outSize,delta);
        ReallocMem(outBuffer,outSize);

        zstream.next_out := Pointer(Cardinal(outBuffer) + zstream.total_out);
        zstream.avail_out := delta;
      end;
    finally
      inflateEnd(zstream);
    end;

    ReallocMem(outBuffer,zstream.total_out);
    outSize := zstream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

procedure ZDecompress2(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; windowBits: Integer;
  outEstimate: Integer = 0);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  inflateInit2_(zstream, windowBits, ZLIB_VERSION,SizeOf(TZStreamRec));

  ZInternalDecompress(zstream,inBuffer,inSize,outBuffer,outSize,outEstimate);
end;
{$ifend}
  
{ CCParticleSystem }

class function CCParticleSystem._create(
  const plistFile: string): CCParticleSystem;
var
  pRet: CCParticleSystem;
begin
  pRet := CCParticleSystem.Create();
  if (pRet <> nil) and pRet.initWithFile(plistFile) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleSystem.addParticle: Boolean;
var
  particle: pCCParticle;
begin
  if isFull then
  begin
    Result := False;
    Exit;
  end;

  particle := @m_pParticles^[m_uParticleCount];
  initParticle(particle);
  Inc(m_uParticleCount);
  
  Result := True;
end;

constructor CCParticleSystem.Create;
begin
  inherited Create();
  m_bIsActive := True;
  m_ePositionType := kCCPositionTypeFree;
  m_nEmitterMode := kCCParticleModeGravity;
  m_tBlendFunc.src := CC_BLEND_SRC;
  m_tBlendFunc.dst := CC_BLEND_DST;
end;

class function CCParticleSystem.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleSystem;
var
  pRet: CCParticleSystem;
begin
  pRet := CCParticleSystem.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCParticleSystem.Destroy;
begin
  //unscheduleUpdate();
  CC_SAFE_FREE_POINTER(m_pParticles);
  CC_SAFE_RELEASE(m_pTexture);
  inherited;
end;

function CCParticleSystem.getAngle: Single;
begin
  Result := m_fAngle;
end;

function CCParticleSystem.getAngleVar: Single;
begin
  Result := m_fAngleVar;
end;

function CCParticleSystem.getAtlasIndex: Cardinal;
begin
  Result := m_uAtlasIndex;
end;

function CCParticleSystem.getBatchNode: CCObject;
begin
  Result := m_pBatchNode;
end;

function CCParticleSystem.getDuration: Single;
begin
  Result := m_fDuration;
end;

function CCParticleSystem.getEmissionRate: Single;
begin
  Result := m_fEmissionRate;
end;

function CCParticleSystem.getEmitterMode: Integer;
begin
  Result := m_nEmitterMode;
end;

function CCParticleSystem.getEndColor: ccColor4F;
begin
  Result := m_tEndColor;
end;

function CCParticleSystem.getEndColorVar: ccColor4F;
begin
  Result := m_tEndColorVar;
end;

function CCParticleSystem.getEndRadius: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    Result := modeB.endRadius;
end;

function CCParticleSystem.getEndRadiusVar: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    Result := modeB.endRadiusVar;
end;

function CCParticleSystem.getEndSize: Single;
begin
  Result := m_fEndSize;
end;

function CCParticleSystem.getEndSizeVar: Single;
begin
  Result := m_fEndSizeVar;
end;

function CCParticleSystem.getEndSpin: Single;
begin
  Result := m_fEndSpin;
end;

function CCParticleSystem.getEndSpinVar: Single;
begin
  Result := m_fEndSpinVar;
end;

function CCParticleSystem.getGravity: CCPoint;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    Result := modeA.gravity;
end;

function CCParticleSystem.getLife: Single;
begin
  Result := m_fLife;
end;

function CCParticleSystem.getLifeVar: Single;
begin
  Result := m_fLifeVar;
end;

function CCParticleSystem.getParticleCount: Cardinal;
begin
  Result := m_uParticleCount;
end;

function CCParticleSystem.getPositionType: tCCPositionType;
begin
  Result := m_ePositionType;
end;

function CCParticleSystem.getPosVar: CCPoint;
begin
  Result := m_tPosVar;
end;

function CCParticleSystem.getRadialAccel: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    Result := modeA.radialAccel;
end;

function CCParticleSystem.getRadialAccelVar: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    Result := modeA.radialAccelVar;
end;

function CCParticleSystem.getRotatePerSecond: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    Result := modeB.rotatePerSecond;
end;

function CCParticleSystem.getRotatePerSecondVar: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    Result := modeB.rotatePerSecondVar;
end;

function CCParticleSystem.getSourcePosition: CCPoint;
begin
  Result := m_tSourcePosition;
end;

function CCParticleSystem.getSpeed: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    Result := modeA.speed;
end;

function CCParticleSystem.getSpeedVar: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    Result := modeA.speedVar;
end;

function CCParticleSystem.getStartColor: ccColor4F;
begin
  Result := m_tStartColor;
end;

function CCParticleSystem.getStartColorVar: ccColor4F;
begin
  Result := m_tStartColorVar;
end;

function CCParticleSystem.getStartRadius: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    Result := modeB.startRadius;
end;

function CCParticleSystem.getStartRadiusVar: Single;
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    Result := modeB.startRadiusVar;
end;

function CCParticleSystem.getStartSize: Single;
begin
  Result := m_fStartSize;
end;

function CCParticleSystem.getStartSizeVar: Single;
begin
  Result := m_fStartSizeVar;
end;

function CCParticleSystem.getStartSpin: Single;
begin
  Result := m_fStartSpin;
end;

function CCParticleSystem.getStartSpinVar: Single;
begin
  Result := m_fStartSpinVar;
end;

function CCParticleSystem.getTangentialAccel: Single;
begin
  CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
  Result := modeA.tangentialAccel;
end;

function CCParticleSystem.getTangentialAccelVar: Single;
begin
  CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
  Result := modeA.tangentialAccelVar;
end;

function CCParticleSystem.getTotalParticles: Cardinal;
begin
  Result := m_uTotalParticles;
end;

function CCParticleSystem.init: Boolean;
begin
  Result := initWithTotalParticles(150);
end;

procedure CCParticleSystem.initParticle(particle: pCCParticle);
var
  start, _end: ccColor4F;
  startS, endS: Single;
  startA, endA: Single;
  a, s: Single;
  v: CCPoint;
  startRadius, endRadius: Single;
begin
  particle^.timeToLive := m_fLife + m_fLifeVar * CCRANDOM_MINUS1_1();
  particle^.timeToLive := Max(0, Particle^.timeToLive);

  particle^.pos.x := m_tSourcePosition.x + m_tPosVar.x * CCRANDOM_MINUS1_1();
  particle^.pos.y := m_tSourcePosition.y + m_tPosVar.y * CCRANDOM_MINUS1_1();

  start.r := clampf(m_tStartColor.r + m_tStartColorVar.r * CCRANDOM_MINUS1_1(), 0, 1);
  start.g := clampf(m_tStartColor.g + m_tStartColorVar.g * CCRANDOM_MINUS1_1(), 0, 1);
  start.b := clampf(m_tStartColor.b + m_tStartColorVar.b * CCRANDOM_MINUS1_1(), 0, 1);
  start.a := clampf(m_tStartColor.a + m_tStartColorVar.a * CCRANDOM_MINUS1_1(), 0, 1);

  _end.r := clampf(m_tEndColor.r + m_tEndColor.r * CCRANDOM_MINUS1_1(), 0, 1);
  _end.g := clampf(m_tEndColor.g + m_tEndColor.g * CCRANDOM_MINUS1_1(), 0, 1);
  _end.b := clampf(m_tEndColor.b + m_tEndColor.b * CCRANDOM_MINUS1_1(), 0, 1);
  _end.a := clampf(m_tEndColor.a + m_tEndColor.a * CCRANDOM_MINUS1_1(), 0, 1);

  particle^.color := start;
  particle^.deltaColor.r := (_end.r - start.r) / particle^.timeToLive;
  particle^.deltaColor.g := (_end.g - start.g) / particle^.timeToLive;
  particle^.deltaColor.b := (_end.b - start.b) / particle^.timeToLive;
  particle^.deltaColor.a := (_end.a - start.a) / particle^.timeToLive;

  startS := m_fStartSize + m_fStartSizeVar * CCRANDOM_MINUS1_1();
  startS := Max(0, startS);

  particle^.size := startS;

  if m_fEndSize = kCCParticleStartSizeEqualToEndSize then
  begin
    particle^.deltaSize := 0;
  end else
  begin
    endS := m_fEndSize + m_fEndSizeVar * CCRANDOM_MINUS1_1();
    endS := Max(0, endS);
    particle^.deltaSize := (endS - startS) / particle^.timeToLive;
  end;

  startA := m_fStartSpin + m_fStartSpinVar * CCRANDOM_MINUS1_1();
  endA := m_fEndSpin + m_fEndSpinVar * CCRANDOM_MINUS1_1();
  particle^.rotation := startA;
  particle^.deltaRotation := (endA - startA) / particle^.timeToLive;

  if m_ePositionType = kCCPositionTypeFree then
    particle.startPos := convertToWorldSpace(CCPointZero)
  else
    particle.startPos := m_obPosition;

  a := CC_DEGREES_TO_RADIANS(m_fAngle + m_fAngleVar * CCRANDOM_MINUS1_1());

  if m_nEmitterMode = kCCParticleModeGravity then
  begin
    v.x := Cos(a); v.y := Sin(a);
    s := modeA.speed + modeA.speedVar * CCRANDOM_MINUS1_1();

    particle^.modeA.dir := ccpMult(v, s);

    particle^.modeA.radialAccel := modeA.radialAccel + modeA.radialAccelVar * CCRANDOM_MINUS1_1();

    particle^.modeA.tangentialAccel := modeA.tangentialAccel + modeA.tangentialAccelVar * CCRANDOM_MINUS1_1();

    if modeA.rotationIsDir then
      particle.rotation := -CC_RADIANS_TO_DEGREES(ccpToAngle(particle.modeA.dir));

  end else
  begin
    startRadius := modeB.startRadius + modeB.startRadiusVar * CCRANDOM_MINUS1_1();
    endRadius := modeB.endRadius + modeB.endRadiusVar * CCRANDOM_MINUS1_1();

    particle^.modeB.radius := startRadius;

    if modeB.endRadius = kCCParticleStartRadiusEqualToEndRadius then
      particle^.modeB.deltaRadius := 0
    else
      particle^.modeB.deltaRadius := (endRadius - startRadius) / particle^.timeToLive;

    particle^.modeB.angle := a;
    particle^.modeB.degressPerSecond := CC_DEGREES_TO_RADIANS(modeB.rotatePerSecond + modeB.rotatePerSecondVar * CCRANDOM_MINUS1_1());
  end;  
end;

function CCParticleSystem.initWithDictionary(dict: CCDictionary): Boolean;
begin
  Result := initWithDictionary(dict, '');
end;

function CCParticleSystem.initWithDictionary(dict: CCDictionary; const dirname: string): Boolean;
var
  bRet: Boolean;
  deflatedLen: Integer;
  buffer: PByte;
  deflated: Pointer;
  image: CCImage;
  maxParticles: Integer;
  x, y: Single;
  textureName: string;
  tex: CCTexture2D;
  bNotify: Boolean;
  textureData: string;
  dataLen, decodeLen: Integer;
  isOK: Boolean;
  rPos: Integer;
  textureDir: string;
begin
  deflated := nil;
  buffer := nil;
  bRet := False;

  repeat

    maxParticles := dict.valueForKey('maxParticles').intValue();
    if initWithTotalParticles(maxParticles) then
    begin
      m_fAngle := dict.valueForKey('angle').floatValue();
      m_fAngleVar := dict.valueForKey('angleVariance').floatValue();

      m_fDuration := dict.valueForKey('duration').floatValue();

      m_tBlendFunc.src := dict.valueForKey('blendFuncSource').intValue();
      m_tBlendFunc.dst := dict.valueForKey('blendFuncDestination').intValue();

      // color
      m_tStartColor.r := dict.valueForKey('startColorRed').floatValue();
      m_tStartColor.g := dict.valueForKey('startColorGreen').floatValue();
      m_tStartColor.b := dict.valueForKey('startColorBlue').floatValue();
      m_tStartColor.a := dict.valueForKey('startColorAlpha').floatValue();

      m_tStartColorVar.r := dict.valueForKey('startColorVarianceRed').floatValue();
      m_tStartColorVar.g := dict.valueForKey('startColorVarianceGreen').floatValue();
      m_tStartColorVar.b := dict.valueForKey('startColorVarianceBlue').floatValue();
      m_tStartColorVar.a := dict.valueForKey('startColorVarianceAlpha').floatValue();

      m_tEndColor.r := dict.valueForKey('finishColorRed').floatValue();
      m_tEndColor.g := dict.valueForKey('finishColorGreen').floatValue();
      m_tEndColor.b := dict.valueForKey('finishColorBlue').floatValue();
      m_tEndColor.a := dict.valueForKey('finishColorAlpha').floatValue();

      m_tEndColorVar.r := dict.valueForKey('finishColorVarianceRed').floatValue();
      m_tEndColorVar.g := dict.valueForKey('finishColorVarianceGreen').floatValue();
      m_tEndColorVar.b := dict.valueForKey('finishColorVarianceBlue').floatValue();
      m_tEndColorVar.a := dict.valueForKey('finishColorVarianceAlpha').floatValue();

      // particle size
      m_fStartSize := dict.valueForKey('startParticleSize').floatValue();
      m_fStartSizeVar := dict.valueForKey('startParticleSizeVariance').floatValue();
      m_fEndSize := dict.valueForKey('finishParticleSize').floatValue();
      m_fEndSizeVar := dict.valueForKey('finishParticleSizeVariance').floatValue();

      // position
      x := dict.valueForKey('sourcePositionx').floatValue();
      y := dict.valueForKey('sourcePositiony').floatValue();
      setPosition( ccp(x,y) );
      m_tPosVar.x := dict.valueForKey('sourcePositionVariancex').floatValue();
      m_tPosVar.y := dict.valueForKey('sourcePositionVariancey').floatValue();

      // Spinning
      m_fStartSpin := dict.valueForKey('rotationStart').floatValue();
      m_fStartSpinVar := dict.valueForKey('rotationStartVariance').floatValue();
      m_fEndSpin := dict.valueForKey('rotationEnd').floatValue();
      m_fEndSpinVar := dict.valueForKey('rotationEndVariance').floatValue();

      m_nEmitterMode := dict.valueForKey('emitterType').intValue();

      if m_nEmitterMode = kCCParticleModeGravity then
      begin
        // gravity
        modeA.gravity.x := dict.valueForKey('gravityx').floatValue();
        modeA.gravity.y := dict.valueForKey('gravityy').floatValue();

        // speed
        modeA.speed := dict.valueForKey('speed').floatValue();
        modeA.speedVar := dict.valueForKey('speedVariance').floatValue();

        // radial acceleration
        modeA.radialAccel := dict.valueForKey('radialAcceleration').floatValue();
        modeA.radialAccelVar := dict.valueForKey('radialAccelVariance').floatValue();

        // tangential acceleration
        modeA.tangentialAccel := dict.valueForKey('tangentialAcceleration').floatValue();
        modeA.tangentialAccelVar := dict.valueForKey('tangentialAccelVariance').floatValue();

        //rotation is dir
        modeA.rotationIsDir := dict.valueForKey('rotationIsDir').boolValue();
        
      end else if m_nEmitterMode = kCCParticleModeRadius then
      begin
        modeB.startRadius := dict.valueForKey('maxRadius').floatValue();
        modeB.startRadiusVar := dict.valueForKey('maxRadiusVariance').floatValue();
        modeB.endRadius := dict.valueForKey('minRadius').floatValue();
        modeB.endRadiusVar := 0.0;
        modeB.rotatePerSecond := dict.valueForKey('rotatePerSecond').floatValue();
        modeB.rotatePerSecondVar := dict.valueForKey('rotatePerSecondVariance').floatValue();
      end else
      begin
        CCAssert(False, 'Invalid emitterType in config file');
        Break;
      end;

      m_fLife := dict.valueForKey('particleLifespan').floatValue();
      m_fLifeVar := dict.valueForKey('particleLifespanVariance').floatValue();

      m_fEmissionRate := m_uTotalParticles / m_fLife;

      if m_pBatchNode = nil then
      begin
        m_bOpacityModifyRGB := False;

        textureName := dict.valueForKey('textureFileName').m_sString;
        rPos := stringRfind('/', textureName);
        if rPos > 0 then
        begin
          textureDir := stringSubstr(1, rPos, textureName);
          if (dirname <> '') and (textureDir <> '') then
          begin
            textureName := stringSubstr(rPos + 1, textureName);
            textureName := dirname + textureName;
          end;  
        end else
        begin
          if dirname <> '' then
          begin
            textureName := dirname + textureName;
          end;  
        end;  

        tex := nil;
        if textureName <> '' then
        begin
          bNotify := CCFileUtils.sharedFileUtils().isPopupNotify();
          CCFileUtils.sharedFileUtils().setPopupNotify(False);
          tex := CCTextureCache.sharedTextureCache().addImage(textureName);

          CCFileUtils.sharedFileUtils().setPopupNotify(bNotify);
        end;

        if tex <> nil then
        begin
          setTexture(tex);
        end else
        begin
          textureData := dict.valueForKey('textureImageData').m_sString;
          CCAssert(textureData <> '', '');

          if textureData <> '' then
          begin
            dataLen := Length(textureData);
            {$ifdef IOS}
            decodeLen := base64Decode(textureData, dataLen, buffer);
            {$else}
            decodeLen := base64Decode(PChar(textureData), dataLen, buffer);
            {$endif}
            CCAssert(buffer <> nil, 'CCParticleSystem: error decoding textureImageData');
            if buffer = nil then
              Break;

            ZDecompress2(buffer, decodeLen, deflated, deflatedLen, 15 + 32);

            CCAssert(deflated <> nil, 'CCParticleSystem: error ungzipping textureImageData');
            if deflated = nil then
              Break;

            image := CCImage.Create();
            isOK := image.initWithImageData(deflated, deflatedLen);
            CCAssert(isOK, 'CCParticleSystem: error init image with Data');
            if not isOK then
            begin
              image.release();
              Break;
            end;

            setTexture(CCTextureCache.sharedTextureCache().addUIImage(image, textureName));

            image.release();
          end;  
        end;
        CCAssert(m_pTexture <> nil, 'CCParticleSystem: error loading the texture');
      end;
      bRet := True;
    end;

  until True;

  CC_SAFE_FREE_POINTER(buffer);
  CC_SAFE_FREE_POINTER(deflated);

  Result := bRet;
end;

function CCParticleSystem.initWithFile(const plistFile: string): Boolean;
var
  bRet: Boolean;
  dict: CCDictionary;
  listFilePath: string;
begin
  m_sPlistFile := CCFileUtils.sharedFileUtils().fullPathForFilename(plistFile);
  dict := CCDictionary.createWithContentsOfFileThreadSafe(m_sPlistFile);

  CCAssert(dict <> nil, 'Particles: file not found');

  listFilePath := plistFile;
  if Pos('/', listFilePath) > 0 then
  begin
    listFilePath := stringSubstr(1, stringRfind('/', listFilePath), listFilePath);
    bRet := initWithDictionary(dict, listFilePath);
  end else
  begin
    bRet := initWithDictionary(dict, '');
  end;

  dict.release();

  Result := bRet;
end;

function CCParticleSystem.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  i: Integer;
begin
  m_uTotalParticles := numberOfParticles;
  CC_SAFE_FREE_POINTER(m_pParticles);

  m_pParticles := AllocMem(SizeOf(tCCParticle) * m_uTotalParticles);
  if m_pParticles = nil then
  begin
    CCLog('Particle system: not enough memory', []);
    Self.release();
    Result := False;
    Exit;
  end;

  m_uAllocatedParticles := numberOfParticles;

  if m_pBatchNode <> nil then
  begin
    if m_uTotalParticles > 0 then
      for i := 0 to m_uTotalParticles-1 do
      begin
        m_pParticles^[i].atlasIndex := i;
      end;
  end;

  m_bIsActive := True;

  m_tBlendFunc.src := CC_BLEND_SRC;
  m_tBlendFunc.dst := CC_BLEND_DST;

  m_ePositionType := kCCPositionTypeFree;

  m_nEmitterMode := kCCParticleModeGravity;

  m_bIsAutoRemoveOnFinish := False;

  m_bTransformSystemDirty := False;

  scheduleUpdateWithPriority(1);

  Result := True;
end;

function CCParticleSystem.isActive: Boolean;
begin
  Result := m_bIsActive;
end;

function CCParticleSystem.isAutoRemoveOnFinish: Boolean;
begin
  Result := m_bIsAutoRemoveOnFinish;
end;

function CCParticleSystem.isBlendAdditive: Boolean;
begin
  Result := (m_tBlendFunc.src = GL_SRC_ALPHA) and (m_tBlendFunc.dst = GL_ONE);
end;

function CCParticleSystem.isFull: Boolean;
begin
  Result := m_uParticleCount = m_uTotalParticles;
end;

procedure CCParticleSystem.postStep;
begin
  //should be overridden
end;

procedure CCParticleSystem.resetSystem;
var
  p: pCCParticle;
  i: Integer;
begin
  m_bIsActive := True;
  m_fElapsed := 0;
  m_uParticleIdx := 0;

  if m_uParticleCount > 0 then
  begin
    for i := 0 to m_uParticleCount-1 do
    begin
      p := @m_pParticles^[i];
      p^.timeToLive := 0;
    end;
    
    m_uParticleIdx := m_uParticleCount-1;
  end;
end;

procedure CCParticleSystem.setAngle(const Value: Single);
begin
  m_fAngle := Value;
end;

procedure CCParticleSystem.setAngleVar(const Value: Single);
begin
  m_fAngleVar := Value;
end;

procedure CCParticleSystem.setAtlasIndex(const Value: Cardinal);
begin
  m_uAtlasIndex := Value;
end;

procedure CCParticleSystem.setAutoRemoveOnFinish(value: Boolean);
begin
  m_bIsAutoRemoveOnFinish := value;
end;

procedure CCParticleSystem.setBatchNode(const Value: CCObject);
var
  i: Cardinal;
begin
  if m_pBatchNode <> Value then
  begin
    m_pBatchNode := Value;
    if Value <> nil then
    begin
      if m_uTotalParticles > 0 then
        for i := 0 to m_uTotalParticles-1 do
        begin
          m_pParticles^[i].atlasIndex := i;
        end;  
    end;  
  end;  
end;

procedure CCParticleSystem.setBlendAdditive(value: Boolean);
begin
  if value then
  begin
    m_tBlendFunc.src := GL_SRC_ALPHA;
    m_tBlendFunc.dst := GL_ONE;
  end else
  begin
    if (m_pTexture <> nil) and not m_pTexture.hasPremultipliedAlpha() then
    begin
      m_tBlendFunc.src := GL_SRC_ALPHA;
      m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
    end else
    begin
      m_tBlendFunc.src := CC_BLEND_SRC;
      m_tBlendFunc.dst := CC_BLEND_DST;
    end;    
  end;    
end;

procedure CCParticleSystem.setDuration(const Value: Single);
begin
  m_fDuration := Value;
end;

procedure CCParticleSystem.setEmissionRate(const Value: Single);
begin
  m_fEmissionRate := Value;
end;

procedure CCParticleSystem.setEmitterMode(const Value: Integer);
begin
  m_nEmitterMode := Value;
end;

procedure CCParticleSystem.setEndColor(const Value: ccColor4F);
begin
  m_tEndColor := Value;
end;

procedure CCParticleSystem.setEndColorVar(const Value: ccColor4F);
begin
  m_tEndColorVar := Value;
end;

procedure CCParticleSystem.setEndRadius(endRadius: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    modeB.endRadius := endRadius;
end;

procedure CCParticleSystem.setEndRadiusVar(endRadiusVar: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    modeB.endRadiusVar := endRadiusVar;
end;

procedure CCParticleSystem.setEndSize(const Value: Single);
begin
  m_fEndSize := Value;
end;

procedure CCParticleSystem.setEndSizeVar(const Value: Single);
begin
  m_fEndSizeVar := Value;
end;

procedure CCParticleSystem.setEndSpin(const Value: Single);
begin
  m_fEndSpin := Value;
end;

procedure CCParticleSystem.setEndSpinVar(const Value: Single);
begin
  m_fEndSpinVar := Value;
end;

procedure CCParticleSystem.setGravity(const g: CCPoint);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    modeA.gravity := g;
end;

procedure CCParticleSystem.setLife(const Value: Single);
begin
  m_fLife := Value;
end;

procedure CCParticleSystem.setLifeVar(const Value: Single);
begin
  m_fLifeVar := Value;
end;

procedure CCParticleSystem.setPositionType(const Value: tCCPositionType);
begin
  m_ePositionType := Value;
end;

procedure CCParticleSystem.setPosVar(const Value: CCPoint);
begin
  m_tPosVar := Value;
end;

procedure CCParticleSystem.setRadialAccel(t: Single);
begin
  CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
  modeA.radialAccel := t;
end;

procedure CCParticleSystem.setRadialAccelVar(t: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    modeA.radialAccelVar := t;
end;

procedure CCParticleSystem.setRotatePerSecond(degrees: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    modeB.rotatePerSecond := degrees;
end;

procedure CCParticleSystem.setRotatePerSecondVar(degrees: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    modeB.rotatePerSecondVar := degrees;
end;

procedure CCParticleSystem.setRotation(const Value: Single);
begin
  m_bTransformSystemDirty := True;
  inherited setRotation(Value);
end;

procedure CCParticleSystem.setScale(scale: Single);
begin
  m_bTransformSystemDirty := True;
  inherited setScale(scale);
end;

procedure CCParticleSystem.setScaleX(const Value: Single);
begin
  m_bTransformSystemDirty := True;
  inherited setScaleX(Value);
end;

procedure CCParticleSystem.setScaleY(const Value: Single);
begin
  m_bTransformSystemDirty := True;
  inherited setScaleY(Value);
end;

procedure CCParticleSystem.setSourcePosition(const Value: CCPoint);
begin
  m_tSourcePosition := Value;
end;

procedure CCParticleSystem.setSpeed(speed: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    modeA.speed := speed;
end;

procedure CCParticleSystem.setSpeedVar(speed: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
    modeA.speedVar := speed;
end;

procedure CCParticleSystem.setStartColor(const Value: ccColor4F);
begin
  m_tStartColor := Value;
end;

procedure CCParticleSystem.setStartColorVar(const Value: ccColor4F);
begin
  m_tStartColorVar := Value;
end;

procedure CCParticleSystem.setStartRadius(startRadius: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    modeB.startRadius := startRadius;
end;

procedure CCParticleSystem.setStartRadiusVar(startRadiusVar: Single);
begin
    CCAssert( m_nEmitterMode = kCCParticleModeRadius, 'Particle Mode should be Radius');
    modeB.startRadiusVar := startRadiusVar;
end;

procedure CCParticleSystem.setStartSize(const Value: Single);
begin
  m_fStartSize := Value;
end;

procedure CCParticleSystem.setStartSizeVar(const Value: Single);
begin
  m_fStartSizeVar := Value;
end;

procedure CCParticleSystem.setStartSpin(const Value: Single);
begin
  m_fStartSpin := Value;
end;

procedure CCParticleSystem.setStartSpinVar(const Value: Single);
begin
  m_fStartSpinVar := Value;
end;

procedure CCParticleSystem.setTangentialAccel(t: Single);
begin
  CCAssert(m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
  modeA.tangentialAccel := t;
end;

procedure CCParticleSystem.setTangentialAccelVar(t: Single);
begin
  CCAssert( m_nEmitterMode = kCCParticleModeGravity, 'Particle Mode should be Gravity');
  modeA.tangentialAccelVar := t;
end;

procedure CCParticleSystem.setTotalParticles(const Value: Cardinal);
begin
  CCAssert( Value <= m_uAllocatedParticles, 'Particle: resizing particle array only supported for quads');
  m_uTotalParticles := Value;
end;

procedure CCParticleSystem.stopSystem;
begin
  m_bIsActive := False;
  m_fElapsed := m_fDuration;
  m_fEmitCounter := 0;
end;

procedure CCParticleSystem.update(time: Single);
var
  rate, newY: Single;
  currentPosition, tmp, radial, tangential, newPos, diff: CCPoint;
  p: pCCParticle;
  currentIndex: Cardinal;
begin

  if m_bIsActive and not IsZero(m_fEmissionRate) then
  begin
    rate := 1.0 / m_fEmissionRate;

    if m_uParticleCount < m_uTotalParticles then
    begin
      m_fEmitCounter := m_fEmitCounter + time;
    end;

    while (m_uParticleCount < m_uTotalParticles) and (m_fEmitCounter > rate) do
    begin
      addParticle();
      m_fEmitCounter := m_fEmitCounter - rate;
    end;

    m_fElapsed := m_fElapsed + time;
    if (m_fDuration <> -1) and (m_fDuration < m_fElapsed) then
      stopSystem();
  end;

  m_uParticleIdx := 0;
  
  currentPosition := CCPointZero;
  if m_ePositionType = kCCPositionTypeFree then
    currentPosition := convertToWorldSpace(CCPointZero)
  else if m_ePositionType = kCCPositionTypeRelative then
    currentPosition := m_obPosition;

  if m_bVisible then
  begin
    while m_uParticleIdx < m_uParticleCount do
    begin
      p := @m_pParticles^[m_uParticleIdx];

      p^.timeToLive := p^.timeToLive - time;
      if p^.timeToLive > 0 then
      begin
        if m_nEmitterMode = kCCParticleModeGravity then
        begin
          radial := CCPointZero;

          if not ( IsZero(p^.pos.x) and IsZero(p^.pos.y) ) then
          begin
            radial := ccpNormalize(p^.pos)
          end;

          tangential := radial;
          radial := ccpMult(radial, p^.modeA.radialAccel);

          newY := tangential.x;
          tangential.x := -tangential.y;
          tangential.y := newY;
          tangential := ccpMult(tangential, p^.modeA.tangentialAccel);

          tmp := ccpAdd(ccpAdd(radial, tangential), modeA.gravity);
          tmp := ccpMult(tmp, time);
          p^.modeA.dir := ccpAdd(p^.modeA.dir, tmp);
          tmp := ccpMult(p^.modeA.dir, time);
          p^.pos := ccpAdd(p^.pos, tmp);
        end else
        begin
          p^.modeB.angle := p^.modeB.angle + p^.modeB.degressPerSecond * time;
          p^.modeB.radius := p^.modeB.radius + p^.modeB.deltaRadius * time;

          p^.pos.x := -Cos(p^.modeB.angle) * p^.modeB.radius;
          p^.pos.y := -Sin(p^.modeB.angle) * p^.modeB.radius;
        end;

        p^.color.r := p^.color.r + p^.deltaColor.r * time;
        p^.color.g := p^.color.g + p^.deltaColor.g * time;
        p^.color.b := p^.color.b + p^.deltaColor.b * time;
        p^.color.a := p^.color.a + p^.deltaColor.a * time;

        p^.size := p^.size + p^.deltaSize * time;
        p^.size := Max(0, p^.size);

        p^.rotation := p^.rotation + p^.deltaRotation * time;

        if (m_ePositionType = kCCPositionTypeFree) or (m_ePositionType = kCCPositionTypeRelative) then
        begin
          diff := ccpSub(currentPosition, p^.startPos);
          newPos := ccpSub(p^.pos, diff);
        end else
        begin
          newPos := p^.pos;
        end;

        if m_pBatchNode <> nil then
        begin
          newPos.x := newPos.x + m_obPosition.x;
          newPos.y := newPos.y + m_obPosition.y;
        end;

        updateQuadWithParticle(p, newPos);

        Inc(m_uParticleIdx);
      end else
      begin
        currentIndex := p^.atlasIndex;
        if m_uParticleIdx <> (m_uParticleCount - 1) then
        begin
          m_pParticles^[m_uParticleIdx] := m_pParticles^[m_uParticleCount - 1];
        end;

        if m_pBatchNode <> nil then
        begin
          CCParticleBatchNode(m_pBatchNode).disableParticle(m_uAtlasIndex + currentIndex);

          m_pParticles^[m_uParticleCount - 1].atlasIndex := currentIndex;
        end;

        Dec(m_uParticleCount);

        if (m_uParticleCount = 0) and m_bIsAutoRemoveOnFinish then
        begin
          unscheduleUpdate();
          m_pParent.removeChild(Self, True);
          Exit;
        end;  
      end;  
    end;
    m_bTransformSystemDirty := False;
  end;

  if m_pBatchNode = nil then
  begin
    postStep();
  end;
end;

procedure CCParticleSystem.updateBlendFunc;
var
  premultiplied: Boolean;
begin
  CCAssert(m_pBatchNode = nil, 'Can not change blending functions when the particle is being batched');

  if m_pTexture <> nil then
  begin
    premultiplied := m_pTexture.hasPremultipliedAlpha();
    m_bOpacityModifyRGB := False;
    if (m_pTexture <> nil) and ( (m_tBlendFunc.src = CC_BLEND_SRC) and (m_tBlendFunc.dst = CC_BLEND_DST) ) then
    begin
      if premultiplied then
      begin
        m_bOpacityModifyRGB := True;
      end else
      begin
        m_tBlendFunc.src := GL_SRC_ALPHA;
        m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
      end;    
    end;  
  end;  
end;

procedure CCParticleSystem.updateQuadWithParticle(particle: pCCParticle;
  const newPosition: CCPoint);
begin
  // should be overridden
end;

procedure CCParticleSystem.updateWithNoTime;
begin
  update(0.0);
end;

function CCParticleSystem.getBlendFunc: ccBlendFunc;
begin
  Result := m_tBlendFunc;
end;

function CCParticleSystem.getTexture: CCTexture2D;
begin
  Result := m_pTexture;
end;

procedure CCParticleSystem.setBlendFunc(blendFunc: ccBlendFunc);
begin
  if (m_tBlendFunc.src <> blendFunc.src) or (m_tBlendFunc.dst <> blendFunc.dst) then
  begin
    m_tBlendFunc := blendFunc;
    updateBlendFunc();
  end;
end;

procedure CCParticleSystem.setTexture(texture: CCTexture2D);
begin
  if m_pTexture <> texture then
  begin
    CC_SAFE_RETAIN(texture);
    CC_SAFE_RELEASE(m_pTexture);
    m_pTexture := texture;
    updateBlendFunc();
  end;
end;

function CCParticleSystem._isOpacityModifyRGB: Boolean;
begin
  Result := m_bOpacityModifyRGB;
end;

procedure CCParticleSystem._setOpacityModifyRGB(const Value: Boolean);
begin
  m_bOpacityModifyRGB := Value;
end;

function CCParticleSystem.getRotationIsDir: Boolean;
begin
  Result := modeA.rotationIsDir;
end;

procedure CCParticleSystem.setRotationisDir(t: Boolean);
begin
  modeA.rotationIsDir := t;
end;

end.
