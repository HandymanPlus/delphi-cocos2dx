(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2010      Ricardo Quesada
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

unit Cocos2dx.CCAnimationCache;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCAnimation, Cocos2dx.CCDictionary;

type
  (** Singleton that manages the Animations.
  It saves in a cache the animations. You should use this class if you want to save your animations in a cache.

  Before v0.99.5, the recommend way was to save them on the CCSprite. Since v0.99.5, you should use this class instead.

  @since v0.99.5
  *)
  CCAnimationCache = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedAnimationCache(): CCAnimationCache;
    class procedure purgeSharedAnimationCache();
    procedure addAnimation(animation: CCAnimation; const name: string);
    procedure removeAnimationByName(const name: string);

    (** Returns a CCAnimation that was previously added.
    If the name is not found it will return nil.
    You should retain the returned copy if you are going to use it.
    @js getAnimation
    *)
    function animationByName(const name: string): CCAnimation;

    (** Adds an animation from an NSDictionary
     Make sure that the frames were previously loaded in the CCSpriteFrameCache.
     @since v1.1
     *)
    procedure addAnimationsWithDictionary(dictionary: CCDictionary);
    procedure addAnimationsWithFile(const plist: string);
    function init(): Boolean;
  private
    m_pAnimations: CCDictionary;
    procedure parseVersion1(animations: CCDictionary);
    procedure parseVersion2(animations: CCDictionary);
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCSpriteFrameCache, tdHashChain, Cocos2dx.CCArray,
  Cocos2dx.CCCommon, Cocos2dx.CCString, Cocos2dx.CCSpriteFrame, Cocos2dx.CCFileUtils;

{ CCAnimationCache }

var s_pSharedAnimationCache: CCAnimationCache = nil;

procedure CCAnimationCache.addAnimation(animation: CCAnimation;
  const name: string);
begin
  m_pAnimations.setObject(animation, name);
end;

procedure CCAnimationCache.addAnimationsWithDictionary(
  dictionary: CCDictionary);
var
  animations: CCDictionary;
  version: Cardinal;
  properties: CCDictionary;
  spritesheets: CCArray;
  pObj: CCString;
  i: Integer;
begin
  animations := CCDictionary(dictionary.objectForKey('animations'));
  if animations = nil then
  begin
    CCLog('cocos2d: CCAnimationCache: No animations were found in provided dictionary.', []);
    Exit;
  end;

  version := 1;
  properties := CCDictionary(dictionary.objectForKey('properties'));
  if properties <> nil then
  begin
    version := properties.valueForKey('format').intValue();
    spritesheets := CCArray(properties.objectForKey('spritesheets'));

    for i := 0 to spritesheets.count()-1 do
    begin
      pObj := CCString(spritesheets.objectAtIndex(i));
      if pObj <> nil then
        CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile(pObj.m_sString);
    end;
  end;

  case version of
    1: parseVersion1(animations);
    2: parseVersion2(animations);
  else
    CCAssert(False, 'Invalid animation format');
  end;
end;

procedure CCAnimationCache.addAnimationsWithFile(const plist: string);
var
  path: string;
  dict: CCDictionary;
begin
  CCAssert( plist <> '', 'Invalid texture file name');

  path := CCFileUtils.sharedFileUtils().fullPathForFilename(plist);
  dict := CCDictionary.createWithContentsOfFile(path);

  CCAssert( dict <> nil, 'CCAnimationCache: File could not be found');

  addAnimationsWithDictionary(dict);
end;

function CCAnimationCache.animationByName(const name: string): CCAnimation;
begin
  Result := CCAnimation(m_pAnimations.objectForKey(name));
end;

constructor CCAnimationCache.Create;
begin
  inherited Create();
  m_pAnimations := nil;
end;

destructor CCAnimationCache.Destroy;
begin
  CC_SAFE_RELEASE(m_pAnimations);
  inherited;
end;

function CCAnimationCache.init: Boolean;
begin
  m_pAnimations := CCDictionary.Create();
  Result := True;
end;

procedure CCAnimationCache.parseVersion1(animations: CCDictionary);
var
  frameCache: CCSpriteFrameCache;

  procedure dealParse(pElement: CCDictElement);
  var
    animationDict: CCDictionary;
    frameNames, frames: CCArray;
    delay: Single;
    animation: CCAnimation;
    pObj: CCString;
    i: Integer;
    spriteFrame: CCSpriteFrame;
    animFrame: CCAnimationFrame;
  begin
    animationDict := CCDictionary(pElement.pObj);
    frameNames := CCArray(animationDict.objectForKey('frames'));
    delay := animationDict.valueForKey('delay').floatValue();

    if frameNames = nil then
    begin
      CCLog('cocos2d: CCAnimationCache: Animation %s found in dictionary without any frames - cannot add to animation cache.', [pElement.strKey]);
      Exit;
    end;

    frames := CCArray.createWithCapacity(frameNames.count());
    frames.retain();

    if (frameNames <> nil) and (frameNames.count() > 0) then
    begin
      for i := 0 to frameNames.count()-1 do
      begin
        pObj := CCString(frameNames.objectAtIndex(i));
        spriteFrame := frameCache.spriteFrameByName(pObj.m_sString);

        if spriteFrame = nil then
        begin
          CCLog('cocos2d: CCAnimationCache: Animation %s refers to frame %s which is not currently in the CCSpriteFrameCache. This frame will not be added to the animation.', [pElement.strKey, pObj.m_sString]);
          Continue;
        end;

        animFrame := CCAnimationFrame.Create();
        animFrame.initWithSpriteFrame(spriteFrame, 1, nil);
        frames.addObject(animFrame);
        animFrame.release();
      end;
    end;

    if frames.count() = 0 then
    begin
      CCLOG('cocos2d: CCAnimationCache: None of the frames for animation %s were found in the CCSpriteFrameCache. Animation is not being added to the Animation Cache.', [pElement.strKey]);
      Exit;
    end else if frames.count() <> frameNames.count() then
    begin
      CCLOG('cocos2d: CCAnimationCache: An animation in your dictionary refers to a frame which is not in the CCSpriteFrameCache. Some or all of the frames for the animation %s may be missing.', [pElement.strKey]);
    end;  

    animation := CCAnimation._create(frames, delay, 1);
    CCAnimationCache.sharedAnimationCache().addAnimation(animation, pElement.strKey);
    frames.release();
  end;


var
  pElement: CCDictElement;
begin
  frameCache := CCSpriteFrameCache.sharedSpriteFrameCache();
  pElement := animations.First();
  while pElement <> nil do
  begin
    dealParse(pElement);
    pElement := animations.Next();
  end;
end;

procedure CCAnimationCache.parseVersion2(animations: CCDictionary);
var
  frameCache: CCSpriteFrameCache;

  procedure dealParse(pElement: CCDictElement);
  var
    name: string;
    animationDict: CCDictionary;
    loops: CCString;
    restoreOriginalFrame: Boolean;
    frameArray, ary: CCArray;
    i: Integer;
    entry: CCDictionary;
    spriteFrameName: string;
    spriteFrame: CCSpriteFrame;
    delayUnits, delayPerUnit: Single;
    userInfo: CCDictionary;
    animFrame: CCAnimationFrame;
    animation: CCAnimation;
  begin
    name := pElement.strKey;
    animationDict := CCDictionary(pElement.pObj);

    loops := animationDict.valueForKey('loops');
    restoreOriginalFrame := animationDict.valueForKey('restoreOriginalFrame').boolValue();

    frameArray := CCArray(animationDict.objectForKey('frames'));
    if frameArray = nil then
    begin
      CCLOG('cocos2d: CCAnimationCache: Animation %s found in dictionary without any frames - cannot add to animation cache.', [name]);
      Exit;
    end;

    ary := CCArray.createWithCapacity(frameArray.count());
    ary.retain();


    for i := 0 to frameArray.count()-1 do
    begin
      entry := CCDictionary(frameArray.objectAtIndex(i));

      spriteFrameName := entry.valueForKey('spriteframe').m_sString;
      spriteFrame := frameCache.spriteFrameByName(spriteFrameName);
      if spriteFrame = nil then
      begin
        CCLOG('cocos2d: CCAnimationCache: Animation %s refers to frame %s which is not currently in the CCSpriteFrameCache. This frame will not be added to the animation.', [name, spriteFrameName]);
        Continue;
      end;

      delayUnits := entry.valueForKey('delayUnits').floatValue();
      userInfo := CCDictionary(entry.objectForKey('notification'));

      animFrame := CCAnimationFrame.Create();
      animFrame.initWithSpriteFrame(spriteFrame, delayUnits, userInfo);

      ary.addObject(animFrame);
      animFrame.release();
    end;


    delayPerUnit := animationDict.valueForKey('delayPerUnit').floatValue();
    animation := CCAnimation.Create();
    if loops.Size() > 0 then
      animation.initWithAnimationFrames(ary, delayPerUnit, loops.Size())
    else
      animation.initWithAnimationFrames(ary, delayPerUnit, 1);
    ary.release();

    animation.RestoreOriginalFrame := restoreOriginalFrame;

    CCAnimationCache.sharedAnimationCache().addAnimation(animation, name);
    animation.release();
  end;


var
  pElement: CCDictElement;
begin
  frameCache := CCSpriteFrameCache.sharedSpriteFrameCache();
  pElement := animations.First();
  while pElement <> nil do
  begin
    dealParse(pElement);
    pElement := animations.Next();
  end;
end;

class procedure CCAnimationCache.purgeSharedAnimationCache;
begin
  CC_SAFE_RELEASE_NULL(CCObject(s_pSharedAnimationCache));
end;

procedure CCAnimationCache.removeAnimationByName(const name: string);
begin
  if name = '' then
    Exit;

  m_pAnimations.removeObjectForKey(name);
end;

class function CCAnimationCache.sharedAnimationCache: CCAnimationCache;
begin
  if s_pSharedAnimationCache = nil then
  begin
    s_pSharedAnimationCache := CCAnimationCache.Create();
    s_pSharedAnimationCache.init();
  end;
  Result := s_pSharedAnimationCache;
end;

end.
