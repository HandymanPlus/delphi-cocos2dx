(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2009      Jason Booth
Copyright (c) 2009      Robert J Payne
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

(*
 * To create sprite frames and texture atlas, use this tool:
 * http://zwoptex.zwopple.com/
 *)

unit Cocos2dx.CCSpriteFrameCache;

interface
uses
  Classes,
  Cocos2dx.CCObject, Cocos2dx.CCDictionary, Cocos2dx.CCTexture2D, Cocos2dx.CCSpriteFrame;

type
  CCSpriteFrameCache = class(CCObject)
  private
    m_pSpriteFrames, m_pSpriteFramesAliases: CCDictionary;
    m_pLoadedFileNames: TStringList;
    procedure addSpriteFramesWithDictionary(pobDictionary: CCDictionary; pobTexture: CCTexture2D);
    procedure removeSpriteFramesFromDictionary(dictionary: CCDictionary);
  public
    constructor Create();
    destructor Destroy(); override;
    function init(): Boolean;

    (** Adds multiple Sprite Frames from a plist file.
     * A texture will be loaded automatically. The texture name will composed by replacing the .plist suffix with .png
     * If you want to use another texture, you should use the addSpriteFramesWithFile:texture method.
     * @js addSpriteFrames
     *)
    procedure addSpriteFramesWithFile(const pszPlist: string); overload;

    (** Adds multiple Sprite Frames from a plist file. The texture will be associated with the created sprite frames.
     @since v0.99.5
     @js addSpriteFrames
     *)
    procedure addSpriteFramesWithFile(const pszPlist: string; const textureFilename: string); overload;

    (** Adds multiple Sprite Frames from a plist file. The texture will be associated with the created sprite frames.
     * @js addSpriteFrames
     *)
    procedure addSpriteFramesWithFile(const pszPlist: string; pobTexture: CCTexture2D); overload;

    (** Adds an sprite frame with a given name.
     If the name already exists, then the contents of the old name will be replaced with the new one.
     *)
    procedure addSpriteFrame(pobFrame: CCSpriteFrame; const pszFrameName: string);

    (** Purges the dictionary of loaded sprite frames.
     * Call this method if you receive the "Memory Warning".
     * In the short term: it will free some resources preventing your app from being killed.
     * In the medium term: it will allocate more resources.
     * In the long term: it will be the same.
     *)
    procedure removeSpriteFrames();

    (** Removes unused sprite frames.
     * Sprite Frames that have a retain count of 1 will be deleted.
     * It is convenient to call this method after when starting a new Scene.
     *)
    procedure removeUnusedSpriteFrames();

    procedure removeSpriteFrameByName(const pszName: string);

    procedure removeSpriteFramesFromFile(const plist: string);

    procedure removeSpriteFramesFromTexture(texture: CCTexture2D);

    function spriteFrameByName(const pszName: string): CCSpriteFrame;

    class function sharedSpriteFrameCache(): CCSpriteFrameCache;

    class procedure purgeSharedSpriteFrameCache();
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCString, Cocos2dx.CCCommon,
  Cocos2dx.CCTextureCache, Cocos2dx.CCFileUtils, tdHashChain,
  Cocos2dx.CCGeometry, Cocos2dx.CCNS, Cocos2dx.CCArray, Cocos2dx.CCStrUtils;

{ CCSpriteFrameCache }

var pSharedSpriteFrameCache: CCSpriteFrameCache = nil;

procedure CCSpriteFrameCache.addSpriteFrame(pobFrame: CCSpriteFrame;
  const pszFrameName: string);
begin
  m_pSpriteFrames.setObject(pobFrame, pszFrameName);
end;

procedure CCSpriteFrameCache.addSpriteFramesWithDictionary(
  pobDictionary: CCDictionary; pobTexture: CCTexture2D);

  procedure dealFrameDict(pElement: CCDictElement; format: Integer);
  var
    spriteFrameName: string;
    spriteFrame: CCSpriteFrame;
    frameDict: CCDictionary;
    x, y, w, h, ox, oy, ow, oh: Single;
    frame: CCRect;
    rotated: Boolean;
    offset: CCPoint;
    sourceSize: CCSize;
    spriteSize, spriteSourceSize: CCSize;
    spriteOffset: CCPoint;
    textureRect: CCRect;
    textureRotated: Boolean;
    aliases: CCArray;
    frameKey: CCString;
    i: Cardinal;
    pObject: CCObject;
    oneAlias: string;
  begin
    frameDict := CCDictionary(pElement.pObj);
    spriteFrameName := pElement.strKey;
    spriteFrame := CCSpriteFrame(m_pSpriteFrames.objectForKey(spriteFrameName));
    if spriteFrame <> nil then
      Exit;

    if format = 0 then
    begin
      x := frameDict.valueForKey('x').floatValue();
      y := frameDict.valueForKey('y').floatValue();
      w := frameDict.valueForKey('width').floatValue();
      h := frameDict.valueForKey('height').floatValue();
      ox := frameDict.valueForKey('offsetX').floatValue();
      oy := frameDict.valueForKey('offsetY').floatValue();
      ow := frameDict.valueForKey('originalWidth').floatValue();
      oh := frameDict.valueForKey('originalHeight').floatValue();

      if (ow = 0.0) or (oh = 0.0) then
      begin
        CCLog('cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won not work as expected. Regenrate the .plist', []);
      end;

      ow := Abs(ow);
      oh := Abs(oh);

      spriteFrame := CCSpriteFrame.Create();
      spriteFrame.initWithTexture(pobTexture, CCRectMake(x, y, w, h), False,
        CCPointMake(ox, oy), CCSizeMake(ow, oh));
    end else if (format = 1) or (format = 2) then
    begin
      frame := CCRectFromString(frameDict.valueForKey('frame').m_sString);
      rotated := False;

      if format = 2 then
        rotated := frameDict.valueForKey('rotated').boolValue();

      offset := CCPointFromString(frameDict.valueForKey('offset').m_sString);
      sourceSize := CCSizeFromString(frameDict.valueForKey('sourceSize').m_sString);

      spriteFrame := CCSpriteFrame.Create();
      spriteFrame.initWithTexture(pobTexture, frame, rotated, offset, sourceSize);
    end else if format = 3 then
    begin
      spriteSize := CCSizeFromString(frameDict.valueForKey('spriteSize').m_sString);
      spriteOffset := CCPointFromString(frameDict.valueForKey('spriteOffset').m_sString);
      spriteSourceSize := CCSizeFromString(frameDict.valueForKey('spriteSourceSize').m_sString);
      textureRect := CCRectFromString(frameDict.valueForKey('textureRect').m_sString);
      textureRotated := frameDict.valueForKey('textureRotated').boolValue();

      aliases := CCArray(frameDict.objectForKey('aliases'));
      frameKey := CCString.Create(spriteFrameName);

      if aliases.count() > 0 then
      begin
        for i := 0 to aliases.count()-1 do
        begin
          pObject := aliases.objectAtIndex(i);
          if pObject = nil then
            Continue;

          oneAlias := CCString(pObject).m_sString;
          if m_pSpriteFramesAliases.objectForKey(oneAlias) <> nil then
          begin
            CCLog('cocos2d: WARNING: an alias with name %s already exists', [oneAlias]);
          end;

          m_pSpriteFramesAliases.setObject(frameKey, oneAlias);
        end;  
      end;

      frameKey.release();

      spriteFrame := CCSpriteFrame.Create();
      spriteFrame.initWithTexture(pobTexture,
        CCRectMake(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height),
        textureRotated,
        spriteOffset,
        spriteSourceSize);
    end;

    m_pSpriteFrames.setObject(spriteFrame, spriteFrameName);
    spriteFrame.release(); 
  end;


var
  metadataDict, framesDict: CCDictionary;
  pElement: CCDictElement;
  format: Integer;
begin
  metadataDict := CCDictionary(pobDictionary.objectForKey('metadata'));
  framesDict := CCDictionary(pobDictionary.objectForKey('frames'));

  format := 0;
  if metadataDict <> nil then
  begin
    format := metadataDict.valueForKey('format').intValue();
  end;

  CCAssert((format >=0) and (format <= 3), 'format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:textureFilename:');

  pElement := framesDict.First();
  while pElement <> nil do
  begin
    dealFrameDict(pElement, format);
    pElement := framesDict.Next();
  end;  

end;

procedure CCSpriteFrameCache.addSpriteFramesWithFile(const pszPlist: string;
  pobTexture: CCTexture2D);
var
  fullPath: string;
  dict: CCDictionary;
begin
  fullPath := CCFileUtils.sharedFileUtils().fullPathForFilename(pszPlist);
  dict := CCDictionary.createWithContentsOfFileThreadSafe(fullPath);
  addSpriteFramesWithDictionary(dict, pobTexture);
  dict.release();
end;

procedure CCSpriteFrameCache.addSpriteFramesWithFile(const pszPlist,
  textureFilename: string);
var
  texture: CCTexture2D;
begin
  CCAssert(textureFileName <> '', 'texture name should not be null');

  texture := CCTextureCache.sharedTextureCache().addImage(textureFilename);
  if texture <> nil then
  begin
    addSpriteFramesWithFile(pszPlist, texture);
  end else
  begin
    CCLOG('cocos2d: CCSpriteFrameCache: could not load texture file. File not found %s', [textureFileName]);
  end;    
end;

procedure CCSpriteFrameCache.addSpriteFramesWithFile(
  const pszPlist: string);
var
  fullPath: string;
  dict: CCDictionary;
  texturePath: string;
  metadataDict: CCDictionary;
  startPos: Integer;
  pTexture: CCTexture2D;
begin
  CCAssert(pszPlist <> '', 'plist filename should not be NULL');

  if m_pLoadedFileNames.IndexOf(pszPlist) = -1 then
  begin
    fullPath := CCFileUtils.sharedFileUtils().fullPathForFilename(pszPlist);
    dict := CCDictionary.createWithContentsOfFileThreadSafe(fullPath);

    texturePath := '';

    metadataDict := CCDictionary(dict.objectForKey('metadata'));
    if metadataDict <> nil then
    begin
      texturePath := metadataDict.valueForKey('textureFileName').m_sString;
    end;

    if texturePath <> '' then
    begin
      texturePath := CCFileUtils.sharedFileUtils().fullPathFromRelativeFile(texturePath, pszPlist);
    end else
    begin
      texturePath := pszPlist;
      startPos := find_last_of('.', texturePath);
      texturePath := eraseAtPosition(startPos, texturePath);

      texturePath := texturePath + '.png';

      CCLog('cocos2d: CCSpriteFrameCache: Trying to use file %s as texture', [texturePath]);
    end;

    pTexture := CCTextureCache.sharedTextureCache().addImage(texturePath);
    if pTexture <> nil then
    begin
      addSpriteFramesWithDictionary(dict, pTexture);
      m_pLoadedFileNames.Insert(0, pszPlist);
    end else
    begin
      CCLOG('cocos2d: CCSpriteFrameCache: Could not load texture', []);
    end;

    dict.release();
  end;
end;

constructor CCSpriteFrameCache.Create;
begin
  inherited Create();
end;

destructor CCSpriteFrameCache.Destroy;
begin
  CC_SAFE_RELEASE(m_pSpriteFrames);
  CC_SAFE_RELEASE(m_pSpriteFramesAliases);
  m_pLoadedFileNames.Free;
  inherited;
end;

function CCSpriteFrameCache.init: Boolean;
begin
  m_pSpriteFrames := CCDictionary.Create;
  m_pSpriteFramesAliases := CCDictionary.Create;
  m_pLoadedFileNames := TStringList.Create;
  Result := True;
end;

class procedure CCSpriteFrameCache.purgeSharedSpriteFrameCache;
begin
  CC_SAFE_RELEASE_NULL(CCObject(pSharedSpriteFrameCache));
end;

procedure CCSpriteFrameCache.removeSpriteFrameByName(const pszName: string);
var
  key: CCString;
begin
  if pszName = '' then
    Exit;

  key := CCString(m_pSpriteFramesAliases.objectForKey(pszName));
  if key <> nil then
  begin
    m_pSpriteFrames.removeObjectForKey(key.m_sString);
    m_pSpriteFramesAliases.removeObjectForKey(key.m_sString);
  end else
  begin
    m_pSpriteFrames.removeObjectForKey(pszName);
  end;
  m_pLoadedFileNames.Clear();
end;

procedure CCSpriteFrameCache.removeSpriteFrames;
begin
  m_pSpriteFrames.removeAllObjects();
  m_pSpriteFramesAliases.removeAllObjects();
  m_pLoadedFileNames.Clear();
end;

procedure CCSpriteFrameCache.removeSpriteFramesFromDictionary(
  dictionary: CCDictionary);
var
  keysToRemove: CCArray;

  procedure dealRemoveSpriteFrames(pElement: CCDictElement);
  begin
    if m_pSpriteFrames.objectForKey(pElement.strKey) <> nil then
      keysToRemove.addObject(CCString._create(pElement.strKey));
  end;

var
  framesDict: CCDictionary;
  pElement: CCDictElement;
begin
  framesDict := CCDictionary(dictionary.objectForKey('frames'));
  keysToRemove := CCArray._Create();

  pElement := framesDict.First();
  while pElement <> nil do
  begin
    dealRemoveSpriteFrames(pElement);
    pElement := framesDict.Next();
  end;

  m_pSpriteFrames.removeObjectsForKeys(keysToRemove);
end;

procedure CCSpriteFrameCache.removeSpriteFramesFromFile(
  const plist: string);
var
  fullPath: string;
  dict: CCDictionary;
  nPos: Integer;
begin
  fullPath := CCFileUtils.sharedFileUtils().fullPathForFilename(plist);
  dict := CCDictionary.createWithContentsOfFileThreadSafe(fullPath);

  removeSpriteFramesFromDictionary(dict);

  nPos := m_pLoadedFileNames.IndexOf(plist);
  if nPos <> -1 then
    m_pLoadedFileNames.Delete(nPos);

  dict.release();
end;

procedure CCSpriteFrameCache.removeSpriteFramesFromTexture(
  texture: CCTexture2D);
var
  keysToRemove: CCArray;

  procedure dealRemoveTexture(pElement: CCDictElement);
  var
    key: string;
    frame: CCSpriteFrame;
  begin
    key := pElement.strKey;
    frame := CCSpriteFrame(m_pSpriteFrames.objectForKey(key));
    if (frame <> nil) and (frame.getTexture() = texture) then
    begin
      keysToRemove.addObject(CCString._create(pElement.strKey));
    end;  
  end;  

var
  pElement: CCDictElement;
begin
  keysToRemove := CCArray._Create();
  pElement := m_pSpriteFrames.First();
  while pElement <> nil do
  begin
    dealRemoveTexture(pElement);
    pElement := m_pSpriteFrames.Next();
  end;

  m_pSpriteFrames.removeObjectsForKeys(keysToRemove);
end;

procedure CCSpriteFrameCache.removeUnusedSpriteFrames;
var
  bRemoved: Boolean;

  procedure dealUnused(pElement: CCDictElement);
  var
    spriteFrame: CCSpriteFrame;
  begin
    spriteFrame := CCSpriteFrame(pElement.pObj);
    if spriteFrame.retainCount() = 1 then
    begin
      CCLog('cocos2d: CCSpriteFrameCache: removing unused frame: %s', [pElement.strKey]);
      m_pSpriteFrames.removeObjectForElement(pElement);
      bRemoved := True;
    end;
  end;

var
  pElement: CCDictElement;
begin
  pElement := m_pSpriteFrames.First();
  while pElement <> nil do
  begin
    dealUnused(pElement);
    pElement := m_pSpriteFrames.Next();
  end;

  if bRemoved then
  begin
    m_pLoadedFileNames.Clear();
  end;  
end;

class function CCSpriteFrameCache.sharedSpriteFrameCache: CCSpriteFrameCache;
begin
  if pSharedSpriteFrameCache = nil then
  begin
    pSharedSpriteFrameCache := CCSpriteFrameCache.Create();
    pSharedSpriteFrameCache.init();
  end;
  Result := pSharedSpriteFrameCache;
end;

function CCSpriteFrameCache.spriteFrameByName(
  const pszName: string): CCSpriteFrame;
var
  frame: CCSpriteFrame;
  key: CCString;
begin
  frame := CCSpriteFrame(m_pSpriteFrames.objectForKey(pszName));
  if frame = nil then
  begin
    key := CCString(m_pSpriteFramesAliases.objectForKey(pszName));
    if key <> nil then
    begin
      frame := CCSpriteFrame(m_pSpriteFrames.objectForKey(key.m_sString));
      if frame = nil then
      begin
        CCLOG('cocos2d: CCSpriteFrameCache: Frame %s not found', [pszName]);
      end;  
    end;
  end;

  Result := frame;
end;

end.
