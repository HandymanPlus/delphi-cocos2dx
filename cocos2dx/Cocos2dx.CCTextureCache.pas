unit Cocos2dx.CCTextureCache;

interface
uses
  SysUtils,
  Cocos2dx.CCObject, Cocos2dx.CCDictionary, Cocos2dx.CCTexture2D, Cocos2dx.CCImage;

type
  CCTextureCache = class(CCObject)
  private
    //procedure addImageAsynCallBack(dt: Single);
  protected
    m_pTextures: CCDictionary;
  public
    constructor Create();
    destructor Destroy(); override;
    function snapshotTextures(): CCDictionary;
    class function sharedTextureCache(): CCTextureCache;
    class procedure purgeSharedTextureCache();
    function addImage(const fileimage: string): CCTexture2D;
    procedure addImageAsync(const path: string; target: CCObject; selector: SEL_CallFuncO);
    function addUIImage(image: CCImage; const key: string): CCTexture2D;
    function textureForKey(const key: string): CCTexture2D;
    procedure removeAllTextures();
    procedure removeUnusedTextures();
    procedure removeTexture(texture: CCTexture2D);
    procedure removeTextureForKey(const textureKeyName: string);
    procedure dumpCachedTextureInfo();
    function addPVRImage(const filename: string): CCTexture2D;
    function addETCImage(const filename: string): CCTexture2D;
    class procedure reloadAllTextures();
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCFileUtils, Cocos2dx.CCArray, Cocos2dx.CCCommon;

{ CCTextureCache }

var g_sharedTextureCache: CCTextureCache = nil;
var need_quit: Boolean = False;

function CCTextureCache.addETCImage(const filename: string): CCTexture2D;
begin
  Result := nil;
end;

function CCTextureCache.addImage(const fileimage: string): CCTexture2D;
var
  texture: CCTexture2D;
  pathKey, fullpath, lowercase: string;
  ImageFormat: EImageFormat;
  image: CCImage;
  nSize: Cardinal;
  pBuffer: PByte;
begin
  CCAssert(fileimage <> '', 'TextureCache: fileimage MUST not be NULL');
  pathKey := CCFileUtils.sharedFileUtils().fullPathForFilename(fileimage);
  texture := CCTexture2D(m_pTextures.objectForKey(pathKey));
  fullpath := pathKey;
  if texture = nil then
  begin
    lowercase := AnsiLowerCase(fileimage);
    ImageFormat := CCImage.computeImageFormatType(lowercase);

    repeat
      if ImageFormat = kFmtRawData then
      begin
        texture := Self.addPVRImage(fullpath);
      end else
      begin
        image := CCImage.Create;
        pBuffer := CCFileUtils.sharedFileUtils().getFileData(fullpath, 0, @nSize);
        if not image.initWithImageData(pBuffer, nSize, ImageFormat) then
        begin
          FreeMem(pBuffer);
          image.release();
          Break;
        end else
        begin
          FreeMem(pBuffer);
        end;

        texture := CCTexture2D.Create;
        if (texture <> nil) and texture.initWithImage(image) then
        begin
          m_pTextures.setObject(texture, pathKey);
          texture.release();
        end else
        begin
          CCLOG('cocos2d: Couldn not add image:%s in CCTextureCache', [fileimage]);
        end;
        image.release();
      end;
    until True;
  end;
  Result := texture;
end;

procedure CCTextureCache.addImageAsync(const path: string; target: CCObject;
  selector: SEL_CallFuncO);
begin

end;

(*procedure CCTextureCache.addImageAsynCallBack(dt: Single);
begin
  {.$MESSAGE 'no implementation'}
end;*)

function CCTextureCache.addPVRImage(const filename: string): CCTexture2D;
begin
  Result := nil;
end;

function CCTextureCache.addUIImage(image: CCImage;
  const key: string): CCTexture2D;
var
  texture: CCTexture2D;
  forkey: string;
begin
  CCAssert(image <> nil, 'TextureCache: image MUST not be nil');
  if key <> '' then
  begin
    forkey := CCFileUtils.sharedFileUtils().fullPathForFilename(key);
  end;

  texture := CCTexture2D(m_pTextures.objectForKey(forkey));
  if (key <> '') and (texture <> nil) then
  begin
    Result := texture;
    Exit;
  end;

  texture := CCTexture2D.Create;
  texture.initWithImage(image);

  if (key <> '') and (texture <> nil) then
  begin
    m_pTextures.setObject(texture, forkey);
    texture.autorelease();
  end else
  begin
    CCLOG('cocos2d: Couldn not add UIImage in CCTextureCache', []);
  end;
  
  Result := texture;
end;

constructor CCTextureCache.Create;
begin
  CCAssert(g_sharedTextureCache = nil, 'Attempted to allocate a second instance of a singleton.');
  inherited Create();
  m_pTextures := CCDictionary.Create;
end;

destructor CCTextureCache.Destroy;
begin
  need_quit := True;
  CC_SAFE_RELEASE(m_pTextures);
  inherited;
end;

procedure CCTextureCache.dumpCachedTextureInfo;
begin

end;

class procedure CCTextureCache.purgeSharedTextureCache;
begin
  CC_SAFE_RELEASE_NULL(CCObject(g_sharedTextureCache));
end;

class procedure CCTextureCache.reloadAllTextures;
begin

end;

procedure CCTextureCache.removeAllTextures;
begin
  m_pTextures.removeAllObjects();
end;

procedure CCTextureCache.removeTexture(texture: CCTexture2D);
var
  keys: CCArray;
begin
  if texture = nil then
    Exit;

  keys := m_pTextures.allKeysForObject(texture);
  m_pTextures.removeObjectsForKeys(keys);
end;

procedure CCTextureCache.removeTextureForKey(const textureKeyName: string);
var
  fullPath: string;
begin
  if textureKeyName = '' then
    Exit;

  fullPath := CCFileUtils.sharedFileUtils().fullPathForFilename(textureKeyName);
  m_pTextures.removeObjectForKey(fullPath);
end;

procedure CCTextureCache.removeUnusedTextures;
begin
  if m_pTextures.count() > 0 then
  begin
    
  end;  
end;

class function CCTextureCache.sharedTextureCache: CCTextureCache;
begin
  if g_sharedTextureCache = nil then
    g_sharedTextureCache := CCTextureCache.Create();
  Result := g_sharedTextureCache;
end;

function CCTextureCache.snapshotTextures: CCDictionary;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function CCTextureCache.textureForKey(const key: string): CCTexture2D;
begin
  Result := CCTexture2D(m_pTextures.objectForKey(CCFileUtils.sharedFileUtils().fullPathForFilename(key)));
end;

end.
