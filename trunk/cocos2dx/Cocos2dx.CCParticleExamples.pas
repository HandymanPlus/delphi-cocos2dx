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

unit Cocos2dx.CCParticleExamples;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCParticleSystemQuad;

type
  CCParticleFire = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleFire;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleFire;
  end;

  CCParticleFireworks = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleFireworks;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleFireworks;
  end;

  CCParticleSun = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleSun;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleSun;
  end;

  CCParticleGalaxy = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleGalaxy;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleGalaxy;
  end;

  CCParticleFlower = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleFlower;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleFlower;
  end;

  CCParticleMeteor = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleMeteor;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleMeteor;
  end;

  CCParticleSpiral = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleSpiral;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleSpiral;
  end;

  CCParticleExplosion = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleExplosion;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleExplosion;
  end;

  CCParticleSmoke = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleSmoke;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleSmoke;
  end;

  CCParticleSnow = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleSnow;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleSnow;
  end;

  CCParticleRain = class(CCParticleSystemQuad)
  public
    function init(): Boolean; override;
    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    class function _create(): CCParticleRain;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleRain;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCParticleSystem, Cocos2dx.CCPointExtension,
  Cocos2dx.CCGeometry, Cocos2dx.CCDirector, Cocos2dx.CCTexture2D, Cocos2dx.CCImage,
  Cocos2dx.CCTextureCache;

{$INCLUDE firePngData.h}

function getDefaultTexture(): CCTexture2D;
var
  pTexture: CCTexture2D;
  pImage: CCImage;
  bRet: Boolean;
  key: string;
begin
  pImage := nil;

  repeat

    key := '__firePngData';
    pTexture := CCTextureCache.sharedTextureCache().textureForKey(key);
    if pTexture <> nil then
      Break;

    pImage := CCImage.Create;
    if pImage = nil then
      Break;

    bRet := pImage.initWithImageData(@__firePngData[0], SizeOf(__firePngData), kFmtPng);
    if not bRet then
      Break;

    pTexture := CCTextureCache.sharedTextureCache().addUIImage(pImage, key);

  until True;

  CC_SAFE_RELEASE(pImage);

  Result := pTexture;
end;  

{ CCParticleFire }

class function CCParticleFire._create: CCParticleFire;
var
  pRet: CCParticleFire;
begin
  pRet := CCParticleFire.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleFire.init: Boolean;
begin
  Result := initWithTotalParticles(250);
end;

function CCParticleFire.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    m_fDuration := kCCParticleDurationInfinity;
    m_nEmitterMode := kCCParticleModeGravity;
    modeA.gravity := ccp(0, 0);
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 0;
    modeA.speed := 60;
    modeA.speedVar := 20;
    m_fAngle := 90;
    m_fAngleVar := 10;

    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, 60));
    m_tPosVar := ccp(40, 20);

    // life of particles
    m_fLife := 3;
    m_fLifeVar := 0.25;


    // size, in pixels
    m_fStartSize := 54.0;
    m_fStartSizeVar := 10.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per frame
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.76;
    m_tStartColor.g := 0.25;
    m_tStartColor.b := 0.12;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.0;
    m_tStartColorVar.g := 0.0;
    m_tStartColorVar.b := 0.0;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.0;
    m_tEndColor.g := 0.0;
    m_tEndColor.b := 0.0;
    m_tEndColor.a := 1.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    setBlendAdditive(True);

    Result := True;
    Exit;
  end;
  
  Result := False;
end;

class function CCParticleFire.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleFire;
var
  pRet: CCParticleFire;
begin
  pRet := CCParticleFire.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleFireworks }

class function CCParticleFireworks._create: CCParticleFireworks;
var
  pRet: CCParticleFireworks;
begin
  pRet := CCParticleFireworks.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleFireworks.init: Boolean;
begin
  Result := initWithTotalParticles(1500);
end;

function CCParticleFireworks.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // Gravity Mode
    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,-90);

    // Gravity Mode:  radial
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 0;

    //  Gravity Mode: speed of particles
    modeA.speed := 180;
    modeA.speedVar := 50;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height/2));

    // angle
    m_fAngle := 90;
    m_fAngleVar := 20;

    // life of particles
    m_fLife := 3.5;
    m_fLifeVar := 1;

    // emits per frame
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.5;
    m_tStartColor.g := 0.5;
    m_tStartColor.b := 0.5;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.5;
    m_tStartColorVar.g := 0.5;
    m_tStartColorVar.b := 0.5;
    m_tStartColorVar.a := 0.1;
    m_tEndColor.r := 0.1;
    m_tEndColor.g := 0.1;
    m_tEndColor.b := 0.1;
    m_tEndColor.a := 0.2;
    m_tEndColorVar.r := 0.1;
    m_tEndColorVar.g := 0.1;
    m_tEndColorVar.b := 0.1;
    m_tEndColorVar.a := 0.2;

    // size, in pixels
    m_fStartSize := 8.0;
    m_fStartSizeVar := 2.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(false);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleFireworks.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleFireworks;
var
  pRet: CCParticleFireworks;
begin
  pRet := CCParticleFireworks.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleSun }

class function CCParticleSun._create: CCParticleSun;
var
  pRet: CCParticleSun;
begin
  pRet := CCParticleSun.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleSun.init: Boolean;
begin
  Result := initWithTotalParticles(350);
end;

function CCParticleSun.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // additive
    setBlendAdditive(true);

    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // Gravity Mode
    m_nEmitterMode := kCCParticleModeGravity;  

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,0);

    // Gravity mode: radial acceleration
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 0;

    // Gravity mode: speed of particles
    modeA.speed := 20;
    modeA.speedVar := 5;


    // angle
    m_fAngle := 90;
    m_fAngleVar := 360;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height/2));
    m_tPosVar := CCPointZero;

    // life of particles
    m_fLife := 1;
    m_fLifeVar := 0.5;

    // size, in pixels
    m_fStartSize := 30.0;
    m_fStartSizeVar := 10.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per seconds
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.76;
    m_tStartColor.g := 0.25;
    m_tStartColor.b := 0.12;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.0;
    m_tStartColorVar.g := 0.0;
    m_tStartColorVar.b := 0.0;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.0;
    m_tEndColor.g := 0.0;
    m_tEndColor.b := 0.0;
    m_tEndColor.a := 1.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleSun.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleSun;
var
  pRet: CCParticleSun;
begin
  pRet := CCParticleSun.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleGalaxy }

class function CCParticleGalaxy._create: CCParticleGalaxy;
var
  pRet: CCParticleGalaxy;
begin
  pRet := CCParticleGalaxy.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleGalaxy.init: Boolean;
begin
  Result := initWithTotalParticles(200);
end;

function CCParticleGalaxy.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // Gravity Mode
    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,0);

    // Gravity Mode: speed of particles
    modeA.speed := 60;
    modeA.speedVar := 10;

    // Gravity Mode: radial
    modeA.radialAccel := -80;
    modeA.radialAccelVar := 0;

    // Gravity Mode: tangential
    modeA.tangentialAccel := 80;
    modeA.tangentialAccelVar := 0;

    // angle
    m_fAngle := 90;
    m_fAngleVar := 360;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height/2));
    m_tPosVar := CCPointZero;

    // life of particles
    m_fLife := 4;
    m_fLifeVar := 1;

    // size, in pixels
    m_fStartSize := 37.0;
    m_fStartSizeVar := 10.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per second
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.12;
    m_tStartColor.g := 0.25;
    m_tStartColor.b := 0.76;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.0;
    m_tStartColorVar.g := 0.0;
    m_tStartColorVar.b := 0.0;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.0;
    m_tEndColor.g := 0.0;
    m_tEndColor.b := 0.0;
    m_tEndColor.a := 1.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);
      
    setBlendAdditive(True);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleGalaxy.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleGalaxy;
var
  pRet: CCParticleGalaxy;
begin
  pRet := CCParticleGalaxy.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleFlower }

class function CCParticleFlower._create: CCParticleFlower;
var
  pRet: CCParticleFlower;
begin
  pRet := CCParticleFlower.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleFlower.init: Boolean;
begin
  Result := initWithTotalParticles(250);
end;

function CCParticleFlower.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // Gravity Mode
    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,0);

    // Gravity Mode: speed of particles
    modeA.speed := 80;
    modeA.speedVar := 10;

    // Gravity Mode: radial
    modeA.radialAccel := -60;
    modeA.radialAccelVar := 0;

    // Gravity Mode: tangential
    modeA.tangentialAccel := 15;
    modeA.tangentialAccelVar := 0;

    // angle
    m_fAngle := 90;
    m_fAngleVar := 360;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height/2));
    m_tPosVar := CCPointZero;

    // life of particles
    m_fLife := 4;
    m_fLifeVar := 1;

    // size, in pixels
    m_fStartSize := 30.0;
    m_fStartSizeVar := 10.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per second
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.50;
    m_tStartColor.g := 0.50;
    m_tStartColor.b := 0.50;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.5;
    m_tStartColorVar.g := 0.5;
    m_tStartColorVar.b := 0.5;
    m_tStartColorVar.a := 0.5;
    m_tEndColor.r := 0.0;
    m_tEndColor.g := 0.0;
    m_tEndColor.b := 0.0;
    m_tEndColor.a := 1.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(True);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleFlower.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleFlower;
var
  pRet: CCParticleFlower;
begin
  pRet := CCParticleFlower.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleMeteor }

class function CCParticleMeteor._create: CCParticleMeteor;
var
  pRet: CCParticleMeteor;
begin
  pRet := CCParticleMeteor.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleMeteor.init: Boolean;
begin
  Result := initWithTotalParticles(150);
end;

function CCParticleMeteor.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // Gravity Mode
    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(-200,200);

    // Gravity Mode: speed of particles
    modeA.speed := 15;
    modeA.speedVar := 5;

    // Gravity Mode: radial
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 0;

    // Gravity Mode: tangential
    modeA.tangentialAccel := 0;
    modeA.tangentialAccelVar := 0;

    // angle
    m_fAngle := 90;
    m_fAngleVar := 360;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height/2));
    m_tPosVar := CCPointZero;

    // life of particles
    m_fLife := 2;
    m_fLifeVar := 1;

    // size, in pixels
    m_fStartSize := 60.0;
    m_fStartSizeVar := 10.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per second
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.2;
    m_tStartColor.g := 0.4;
    m_tStartColor.b := 0.7;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.0;
    m_tStartColorVar.g := 0.0;
    m_tStartColorVar.b := 0.2;
    m_tStartColorVar.a := 0.1;
    m_tEndColor.r := 0.0;
    m_tEndColor.g := 0.0;
    m_tEndColor.b := 0.0;
    m_tEndColor.a := 1.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(true);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleMeteor.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleMeteor;
var
  pRet: CCParticleMeteor;
begin
  pRet := CCParticleMeteor.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleSpiral }

class function CCParticleSpiral._create: CCParticleSpiral;
var
  pRet: CCParticleSpiral;
begin
  pRet := CCParticleSpiral.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleSpiral.init: Boolean;
begin
  Result := initWithTotalParticles(500);
end;

function CCParticleSpiral.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // Gravity Mode
    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,0);

    // Gravity Mode: speed of particles
    modeA.speed := 150;
    modeA.speedVar := 0;

    // Gravity Mode: radial
    modeA.radialAccel := -380;
    modeA.radialAccelVar := 0;

    // Gravity Mode: tangential
    modeA.tangentialAccel := 45;
    modeA.tangentialAccelVar := 0;

    // angle
    m_fAngle := 90;
    m_fAngleVar := 0;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height/2));
    m_tPosVar := CCPointZero;

    // life of particles
    m_fLife := 12;
    m_fLifeVar := 0;

    // size, in pixels
    m_fStartSize := 20.0;
    m_fStartSizeVar := 0.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per second
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.5;
    m_tStartColor.g := 0.5;
    m_tStartColor.b := 0.5;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.5;
    m_tStartColorVar.g := 0.5;
    m_tStartColorVar.b := 0.5;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.5;
    m_tEndColor.g := 0.5;
    m_tEndColor.b := 0.5;
    m_tEndColor.a := 1.0;
    m_tEndColorVar.r := 0.5;
    m_tEndColorVar.g := 0.5;
    m_tEndColorVar.b := 0.5;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(False);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleSpiral.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleSpiral;
var
  pRet: CCParticleSpiral;
begin
  pRet := CCParticleSpiral.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleExplosion }

class function CCParticleExplosion._create: CCParticleExplosion;
var
  pRet: CCParticleExplosion;
begin
  pRet := CCParticleExplosion.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleExplosion.init: Boolean;
begin
  Result := initWithTotalParticles(700);
end;

function CCParticleExplosion.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := 0.1;

    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,0);

    // Gravity Mode: speed of particles
    modeA.speed := 70;
    modeA.speedVar := 40;

    // Gravity Mode: radial
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 0;

    // Gravity Mode: tangential
    modeA.tangentialAccel := 0;
    modeA.tangentialAccelVar := 0;

    // angle
    m_fAngle := 90;
    m_fAngleVar := 360;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height/2));
    m_tPosVar := CCPointZero;

    // life of particles
    m_fLife := 5.0;
    m_fLifeVar := 2;

    // size, in pixels
    m_fStartSize := 15.0;
    m_fStartSizeVar := 10.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per second
    m_fEmissionRate := m_uTotalParticles/m_fDuration;

    // color of particles
    m_tStartColor.r := 0.7;
    m_tStartColor.g := 0.1;
    m_tStartColor.b := 0.2;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.5;
    m_tStartColorVar.g := 0.5;
    m_tStartColorVar.b := 0.5;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.5;
    m_tEndColor.g := 0.5;
    m_tEndColor.b := 0.5;
    m_tEndColor.a := 0.0;
    m_tEndColorVar.r := 0.5;
    m_tEndColorVar.g := 0.5;
    m_tEndColorVar.b := 0.5;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(false);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleExplosion.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleExplosion;
var
  pRet: CCParticleExplosion;
begin
  pRet := CCParticleExplosion.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleSmoke }

class function CCParticleSmoke._create: CCParticleSmoke;
var
  pRet: CCParticleSmoke;
begin
  pRet := CCParticleSmoke.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleSmoke.init: Boolean;
begin
  Result := initWithTotalParticles(200);
end;

function CCParticleSmoke.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // Emitter mode: Gravity Mode
    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,0);

    // Gravity Mode: radial acceleration
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 0;

    // Gravity Mode: speed of particles
    modeA.speed := 25;
    modeA.speedVar := 10;

    // angle
    m_fAngle := 90;
    m_fAngleVar := 5;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, 0));
    m_tPosVar := ccp(20, 0);

    // life of particles
    m_fLife := 4;
    m_fLifeVar := 1;

    // size, in pixels
    m_fStartSize := 60.0;
    m_fStartSizeVar := 10.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per frame
    m_fEmissionRate := m_uTotalParticles/m_fLife;

    // color of particles
    m_tStartColor.r := 0.8;
    m_tStartColor.g := 0.8;
    m_tStartColor.b := 0.8;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.02;
    m_tStartColorVar.g := 0.02;
    m_tStartColorVar.b := 0.02;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.0;
    m_tEndColor.g := 0.0;
    m_tEndColor.b := 0.0;
    m_tEndColor.a := 1.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(false);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleSmoke.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleSmoke;
var
  pRet: CCParticleSmoke;
begin
  pRet := CCParticleSmoke.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleSnow }

class function CCParticleSnow._create: CCParticleSnow;
var
  pRet: CCParticleSnow;
begin
  pRet := CCParticleSnow.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleSnow.init: Boolean;
begin
  Result := initWithTotalParticles(700);
end;

function CCParticleSnow.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    // set gravity mode.
    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(0,-1);

    // Gravity Mode: speed of particles
    modeA.speed := 5;
    modeA.speedVar := 1;

    // Gravity Mode: radial
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 1;

    // Gravity mode: tangential
    modeA.tangentialAccel := 0;
    modeA.tangentialAccelVar := 1;

    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height + 10));
    m_tPosVar := ccp( winSize.width/2, 0 );

    // angle
    m_fAngle := -90;
    m_fAngleVar := 5;

    // life of particles
    m_fLife := 45;
    m_fLifeVar := 15;

    // size, in pixels
    m_fStartSize := 10.0;
    m_fStartSizeVar := 5.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per second
    m_fEmissionRate := 10;

    // color of particles
    m_tStartColor.r := 1.0;
    m_tStartColor.g := 1.0;
    m_tStartColor.b := 1.0;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.0;
    m_tStartColorVar.g := 0.0;
    m_tStartColorVar.b := 0.0;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 1.0;
    m_tEndColor.g := 1.0;
    m_tEndColor.b := 1.0;
    m_tEndColor.a := 0.0;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(false);

    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleSnow.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleSnow;
var
  pRet: CCParticleSnow;
begin
  pRet := CCParticleSnow.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

{ CCParticleRain }

class function CCParticleRain._create: CCParticleRain;
var
  pRet: CCParticleRain;
begin
  pRet := CCParticleRain.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleRain.init: Boolean;
begin
  Result := initWithTotalParticles(1000);
end;

function CCParticleRain.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
var
  winSize: CCSize;
  pTexture: CCTexture2D;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    // duration
    m_fDuration := kCCParticleDurationInfinity;

    m_nEmitterMode := kCCParticleModeGravity;

    // Gravity Mode: gravity
    modeA.gravity := ccp(10,-10);

    // Gravity Mode: radial
    modeA.radialAccel := 0;
    modeA.radialAccelVar := 1;

    // Gravity Mode: tangential
    modeA.tangentialAccel := 0;
    modeA.tangentialAccelVar := 1;

    // Gravity Mode: speed of particles
    modeA.speed := 130;
    modeA.speedVar := 30;

    // angle
    m_fAngle := -90;
    m_fAngleVar := 5;


    // emitter position
    winSize := CCDirector.sharedDirector().getWinSize();
    setPosition(ccp(winSize.width/2, winSize.height));
    m_tPosVar := ccp( winSize.width/2, 0 );

    // life of particles
    m_fLife := 4.5;
    m_fLifeVar := 0;

    // size, in pixels
    m_fStartSize := 4.0;
    m_fStartSizeVar := 2.0;
    m_fEndSize := kCCParticleStartSizeEqualToEndSize;

    // emits per second
    m_fEmissionRate := 20;

    // color of particles
    m_tStartColor.r := 0.7;
    m_tStartColor.g := 0.8;
    m_tStartColor.b := 1.0;
    m_tStartColor.a := 1.0;
    m_tStartColorVar.r := 0.0;
    m_tStartColorVar.g := 0.0;
    m_tStartColorVar.b := 0.0;
    m_tStartColorVar.a := 0.0;
    m_tEndColor.r := 0.7;
    m_tEndColor.g := 0.8;
    m_tEndColor.b := 1.0;
    m_tEndColor.a := 0.5;
    m_tEndColorVar.r := 0.0;
    m_tEndColorVar.g := 0.0;
    m_tEndColorVar.b := 0.0;
    m_tEndColorVar.a := 0.0;

    pTexture := getDefaultTexture();
    if pTexture <> nil then
      setTexture(pTexture);

    // additive
    setBlendAdditive(false);


    Result := True;
    Exit;
  end;

  Result := False;
end;

class function CCParticleRain.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleRain;
var
  pRet: CCParticleRain;
begin
  pRet := CCParticleRain.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

end.
