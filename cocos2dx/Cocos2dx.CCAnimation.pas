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

unit Cocos2dx.CCAnimation;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCSpriteFrame, Cocos2dx.CCTexture2D,
  Cocos2dx.CCDictionary, Cocos2dx.CCArray, Cocos2dx.CCGeometry;

type
  (** CCAnimationFrame
   A frame of the animation. It contains information like:
      - sprite frame name
      - # of delay units.
      - offset

   @since v2.0
   *)
  CCAnimationFrame = class(CCObject)
  private
    m_pSpriteFrame: CCSpriteFrame;
    m_fDelays: Single;
    m_pUserInfo: CCDictionary;
    function getDelayUnits: Single;
    function getSpriteFrame: CCSpriteFrame;
    function getUserInfo: CCDictionary;
    procedure setDelayUnits(const Value: Single);
    procedure setSpriteFrame(const Value: CCSpriteFrame);
    procedure setUserInfo(const Value: CCDictionary);
  public
    constructor Create();
    destructor Destroy(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function initWithSpriteFrame(spriteFrame: CCSpriteFrame; delayUnits: Single; userInfo: CCDictionary): Boolean;
    property SpriteFrame: CCSpriteFrame read getSpriteFrame write setSpriteFrame;
    property DelayUnits: Single read getDelayUnits write setDelayUnits;
    property UserInfo: CCDictionary read getUserInfo write setUserInfo;
  end;

  (** A CCAnimation object is used to perform animations on the CCSprite objects.

  The CCAnimation object contains CCAnimationFrame objects, and a possible delay between the frames.
  You can animate a CCAnimation object by using the CCAnimate action. Example:

  [sprite runAction:[CCAnimate actionWithAnimation:animation]];
  *)
  CCAnimation = class(CCObject)
  private
    m_uLoops: Cardinal;
    m_bRestoreOriginalFrame: Boolean;
    m_pFrames: CCArray;
    m_fDuration: Single;
    m_fTotalDelayUnits: Single;
    m_fDelayPerUnit: Single;
  public
    function getDelayPerUnit: Single;
    function getDuration: Single;
    function getFrames: CCArray;
    function getLoops: Cardinal;
    function getRestoreOriginalFrame: Boolean;
    function getTotalDelayUnits: Single;
    procedure setDelayPerUnit(const Value: Single);
    procedure setFrames(const Value: CCArray);
    procedure setLoops(const Value: Cardinal);
    procedure setRestoreOriginalFrame(const Value: Boolean);
  public
    constructor Create();
    destructor Destroy(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    class function _create(): CCAnimation; overload;

    (* Creates an animation with an array of CCSpriteFrame and a delay between frames in seconds.
     The frames will be added with one "delay unit".
     @since v0.99.5
     @js create
    *)
    class function createWithSpriteFrames(arrayOfSpriteFrameNames: CCArray; delay: Single = 0.0): CCAnimation;

    (* Creates an animation with an array of CCAnimationFrame, the delay per units in seconds and and how many times it should be executed.
     @since v2.0
     *)
    class function _create(arrayOfAnimationFrameNames: CCArray; delayPerUnit: Single; loops: Cardinal): CCAnimation; overload;
    class function _create(arrayOfAnimationFrameNames: CCArray; delayPerUnit: Single): CCAnimation; overload;

    (** Adds a CCSpriteFrame to a CCAnimation.
     The frame will be added with one "delay unit".
    *)
    procedure addSpriteFrame(pFrame: CCSpriteFrame);

    (** Adds a frame with an image filename. Internally it will create a CCSpriteFrame and it will add it.
     The frame will be added with one "delay unit".
     Added to facilitate the migration from v0.8 to v0.9.
     * @js addSpriteFrameWithFile
     *)
    procedure addSpriteFrameWithFileName(const pszFilename: string);

    (** Adds a frame with a texture and a rect. Internally it will create a CCSpriteFrame and it will add it.
     The frame will be added with one "delay unit".
     Added to facilitate the migration from v0.8 to v0.9.
     *)
    procedure addSpriteFrameWithTexture(pobTexture: CCTexture2D; const rect: CCRect);
    function init(): Boolean;
    function initWithSpriteFrames(pFrames: CCArray; delay: Single = 0.0): Boolean;
    function initWithAnimationFrames(arrayOfAnimationFrames: CCArray; delayPerUnit: Single; loops: Cardinal): Boolean;
    property TotalDelayUnits: Single read getTotalDelayUnits;
    property DelayPerUnit: Single read getDelayPerUnit write setDelayPerUnit;
    property Duration: Single read getDuration;
    property Frames: CCArray read getFrames write setFrames;
    property RestoreOriginalFrame: Boolean read getRestoreOriginalFrame write setRestoreOriginalFrame;
    property Loops: Cardinal read getLoops write setLoops;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCTextureCache;

{ CCAnimationFrame }

function CCAnimationFrame.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pCopy: CCAnimationFrame;
begin
  pNewZone := nil;
  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pCopy := CCAnimationFrame(pZone.m_pCopyObject);
  end else
  begin
    pCopy := CCAnimationFrame.Create();
    pNewZone := CCZone.Create(pCopy);
  end;

  if m_pUserInfo <> nil then
    pCopy.initWithSpriteFrame(CCSpriteFrame(m_pSpriteFrame.copy().autorelease()), m_fDelays,
      CCDictionary(m_pUserInfo.copy().autorelease()))
  else
    pCopy.initWithSpriteFrame(CCSpriteFrame(m_pSpriteFrame.copy().autorelease()), m_fDelays, nil);

  pNewZone.Free;

  Result := pCopy;
end;

constructor CCAnimationFrame.Create;
begin
  inherited Create();
  m_pSpriteFrame := nil;
  m_fDelays := 0.0;
  m_pUserInfo := nil;
end;

destructor CCAnimationFrame.Destroy;
begin
  CC_SAFE_RELEASE(m_pSpriteFrame);
  CC_SAFE_RELEASE(m_pUserInfo);
  inherited;
end;

function CCAnimationFrame.getDelayUnits: Single;
begin
  Result := m_fDelays;
end;

function CCAnimationFrame.getSpriteFrame: CCSpriteFrame;
begin
  Result := m_pSpriteFrame;
end;

function CCAnimationFrame.getUserInfo: CCDictionary;
begin
  Result := m_pUserInfo;
end;

function CCAnimationFrame.initWithSpriteFrame(spriteFrame: CCSpriteFrame;
  delayUnits: Single; userInfo: CCDictionary): Boolean;
begin
  setSpriteFrame(spriteFrame);
  setDelayUnits(delayUnits);
  setUserInfo(userInfo);

  Result := True;
end;

procedure CCAnimationFrame.setDelayUnits(const Value: Single);
begin
  m_fDelays := Value;
end;

procedure CCAnimationFrame.setSpriteFrame(const Value: CCSpriteFrame);
begin
  if m_pSpriteFrame <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pSpriteFrame);
    m_pSpriteFrame := Value;
  end;
end;

procedure CCAnimationFrame.setUserInfo(const Value: CCDictionary);
begin
  if m_pUserInfo <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pUserInfo);
    m_pUserInfo := Value;
  end;
end;

{ CCAnimation }

class function CCAnimation._create(arrayOfAnimationFrameNames: CCArray;
  delayPerUnit: Single; loops: Cardinal): CCAnimation;
var
  pAnimation: CCAnimation;
begin
  pAnimation := CCAnimation.Create;
  pAnimation.initWithAnimationFrames(arrayOfAnimationFrameNames, delayPerUnit, loops);
  pAnimation.autorelease();

  Result := pAnimation;
end;

class function CCAnimation._create: CCAnimation;
var
  pAnimation: CCAnimation;
begin
  pAnimation := CCAnimation.Create();
  pAnimation.init();
  pAnimation.autorelease();

  Result := pAnimation;
end;

class function CCAnimation._create(arrayOfAnimationFrameNames: CCArray;
  delayPerUnit: Single): CCAnimation;
var
  pAnimation: CCAnimation;
begin
  pAnimation := CCAnimation.Create;
  pAnimation.initWithSpriteFrames(arrayOfAnimationFrameNames, delayPerUnit);
  pAnimation.autorelease();

  Result := pAnimation;
end;

procedure CCAnimation.addSpriteFrame(pFrame: CCSpriteFrame);
var
  animFrame: CCAnimationFrame;
begin
  animFrame := CCAnimationFrame.Create;
  animFrame.initWithSpriteFrame(pFrame, 1.0, nil);
  m_pFrames.addObject(animFrame);
  animFrame.release();

  m_fTotalDelayUnits := m_fTotalDelayUnits + 1;
end;

procedure CCAnimation.addSpriteFrameWithFileName(const pszFilename: string);
var
  pTexture: CCTexture2D;
  rect: CCRect;
  pFrame: CCSpriteFrame;
begin
  pTexture := CCTextureCache.sharedTextureCache().addImage(pszFilename);
  rect := CCRectZero;
  rect.size := pTexture.getContentSize();
  pFrame := CCSpriteFrame.createWithTexture(pTexture, rect);
  addSpriteFrame(pFrame);
end;

procedure CCAnimation.addSpriteFrameWithTexture(pobTexture: CCTexture2D;
  const rect: CCRect);
var
  pFrame: CCSpriteFrame;
begin
  pFrame := CCSpriteFrame.createWithTexture(pobTexture, rect);
  addSpriteFrame(pFrame);
end;

constructor CCAnimation.Create;
begin
  inherited Create();

  m_fTotalDelayUnits := 0.0;
  m_fDelayPerUnit := 0.0;
  m_fDuration := 0.0;
  m_pFrames := nil;
  m_uLoops := 0;
  m_bRestoreOriginalFrame := False;
end;

class function CCAnimation.createWithSpriteFrames(
  arrayOfSpriteFrameNames: CCArray; delay: Single): CCAnimation;
var
  pAnimation: CCAnimation;
begin
  pAnimation := CCAnimation.Create();
  pAnimation.initWithSpriteFrames(arrayOfSpriteFrameNames, delay);
  pAnimation.autorelease();

  Result := pAnimation;
end;

destructor CCAnimation.Destroy;
begin
  CC_SAFE_RELEASE(m_pFrames);
  inherited;
end;

function CCAnimation.getDelayPerUnit: Single;
begin
  Result := m_fDelayPerUnit;
end;

function CCAnimation.getDuration: Single;
begin
  Result := m_fTotalDelayUnits * m_fDelayPerUnit;
end;

function CCAnimation.getFrames: CCArray;
begin
  Result := m_pFrames;
end;

function CCAnimation.getLoops: Cardinal;
begin
  Result := m_uLoops;
end;

function CCAnimation.getRestoreOriginalFrame: Boolean;
begin
  Result := m_bRestoreOriginalFrame;
end;

function CCAnimation.getTotalDelayUnits: Single;
begin
  Result := m_fTotalDelayUnits;
end;

function CCAnimation.init: Boolean;
begin
  Result := Self.initWithSpriteFrames(nil);
end;

function CCAnimation.initWithAnimationFrames(
  arrayOfAnimationFrames: CCArray; delayPerUnit: Single;
  loops: Cardinal): Boolean;
var
  animFrame: CCAnimationFrame;
  i: Integer;
begin
  m_fDelayPerUnit := delayPerUnit;
  m_uLoops := loops;

  setFrames(CCArray.createWithArray(arrayOfAnimationFrames));

  for i := 0 to m_pFrames.count()-1 do
  begin
    animFrame := CCAnimationFrame(m_pFrames.objectAtIndex(i));
    m_fTotalDelayUnits := m_fTotalDelayUnits + animFrame.getDelayUnits();
  end;

  Result := True;
end;

function CCAnimation.initWithSpriteFrames(pFrames: CCArray;
  delay: Single): Boolean;
var
  pTmpFrames: CCArray;
  frame: CCSpriteFrame;
  i: Integer;
  animFrame: CCAnimationFrame;
begin
  //CCARRAY_VERIFY_TYPE(pFrames, CCSpriteFrame*);
  m_uLoops := 1;
  m_fDelayPerUnit := delay;

  pTmpFrames := CCArray._Create();
  setFrames(pTmpFrames);

  if (pFrames <> nil) and (pFrames.count() > 0) then
    for i := 0 to pFrames.count()-1 do
    begin
      frame := CCSpriteFrame(pFrames.objectAtIndex(i));
      animFrame := CCAnimationFrame.Create();
      animFrame.initWithSpriteFrame(frame, 1, nil);
      m_pFrames.addObject(animFrame);
      animFrame.release();

      m_fTotalDelayUnits := m_fTotalDelayUnits + 1;
    end;

  Result := True;
end;

procedure CCAnimation.setDelayPerUnit(const Value: Single);
begin
  m_fDelayPerUnit := Value;
end;

procedure CCAnimation.setFrames(const Value: CCArray);
begin
  if m_pFrames <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pFrames);
    m_pFrames := Value;
  end;  
end;

procedure CCAnimation.setLoops(const Value: Cardinal);
begin
  m_uLoops := Value;
end;

procedure CCAnimation.setRestoreOriginalFrame(const Value: Boolean);
begin
  m_bRestoreOriginalFrame := Value;
end;

function CCAnimation.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pCopy: CCAnimation;
begin
  pNewZone := nil;
  
  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pCopy := CCAnimation(pZone.m_pCopyObject);
  end else
  begin
    pCopy := CCAnimation.Create();
    pNewZone := CCZone.Create(pCopy);
  end;

  pCopy.initWithAnimationFrames(m_pFrames, m_fDelayPerUnit, m_uLoops);
  pCopy.setRestoreOriginalFrame(m_bRestoreOriginalFrame);

  pNewZone.Free;
  Result := pCopy;
end;

end.
