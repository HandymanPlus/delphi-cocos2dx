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

unit Cocos2dx.CCLabelAtlas;

interface
uses
  Cocos2dx.CCAtlasNode, Cocos2dx.CCProtocols, Cocos2dx.CCTexture2D;

type
  (** @brief CCLabelAtlas is a subclass of CCAtlasNode.

  It can be as a replacement of CCLabel since it is MUCH faster.

  CCLabelAtlas versus CCLabel:
  - CCLabelAtlas is MUCH faster than CCLabel
  - CCLabelAtlas "characters" have a fixed height and width
  - CCLabelAtlas "characters" can be anything you want since they are taken from an image file

  A more flexible class is CCLabelBMFont. It supports variable width characters and it also has a nice editor.
  *)
  CCLabelAtlas = class(CCAtlasNode{, CCLabelProtocol})
  private
    m_sString: string;
    m_uMapStartChar: Cardinal;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(const str: string; charMapFile: string; itemWidth, itemHeight, startCharMap: Cardinal): CCLabelAtlas; overload;
    class function _create(const str: string; const fntFile: string): CCLabelAtlas; overload;
    function initWithString(const str: string; const charMapFile: string; itemWidth, itemHeight, startCharMap: Cardinal): Boolean; overload;
    function initWithString(const str: string; const fntFile: string): Boolean; overload;
    function initWithString(const str: string; texture: CCTexture2D; itemWidth, itemHeight, startCharMap: Cardinal): Boolean; overload;
    procedure updateAtlasValues(); override;
    procedure setString(const slabel: string); override;
    function getString(): string; override;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCGeometry, Cocos2dx.CCString, Cocos2dx.CCDictionary,
  Cocos2dx.CCFileUtils, Cocos2dx.CCMacros, Cocos2dx.CCObject,
  Cocos2dx.CCTypes, Cocos2dx.CCTextureCache, Cocos2dx.CCStrUtils;

{ CCLabelAtlas }

class function CCLabelAtlas._create(const str,
  fntFile: string): CCLabelAtlas;
var
  pRet: CCLabelAtlas;
begin
  pRet := CCLabelAtlas.Create();
  if pRet <> nil then
  begin
    if pRet.initWithString(str, fntFile) then
    begin
      pRet.autorelease();
    end else
    begin
      CC_SAFE_RELEASE_NULL(CCObject(pRet));
    end;
  end;
  Result := pRet;
end;

class function CCLabelAtlas._create(const str: string; charMapFile: string;
  itemWidth, itemHeight, startCharMap: Cardinal): CCLabelAtlas;
var
  pRet: CCLabelAtlas;
begin
  pRet := CCLabelAtlas.Create();
  if (pRet <> nil) and pRet.initWithString(str, charMapFile, itemWidth, itemHeight, startCharMap) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCLabelAtlas.Create;
begin
  inherited Create();
  m_sString := '';
end;

destructor CCLabelAtlas.Destroy;
begin

  inherited;
end;

function CCLabelAtlas.getString: string;
begin
  Result := m_sString;
end;

function CCLabelAtlas.initWithString(const str, fntFile: string): Boolean;
var
  dict: CCDictionary;
  width, height, startChar: Cardinal;
  textureFilename: CCString;
  pathStr, relPathStr, texturePathStr: string;
begin
  pathStr := CCFileUtils.sharedFileUtils().fullPathForFilename(fntFile);
  relPathStr := stringSubstr(1, find_last_of('/', pathStr), pathStr) + '/';
  dict := CCDictionary.createWithContentsOfFile(pathStr);

  CCAssert(CCString(dict.objectForKey('version')).intValue() = 1, 'Unsupported version. Upgrade cocos2d version');

  texturePathStr := relPathStr + CCString(dict.objectForKey('textureFilename')).m_sString;

  textureFilename := CCString._create(texturePathStr);

  width := Round(CCString(dict.objectForKey('itemWidth')).intValue/CC_CONTENT_SCALE_FACTOR());
  height := Round(CCString(dict.objectForKey('itemHeight')).intValue/CC_CONTENT_SCALE_FACTOR());
  startChar := CCString(dict.objectForKey('firstChar')).intValue;

  Self.initWithString(str, textureFilename.m_sString, width, height, startChar);
  Result := True;
end;

function CCLabelAtlas.initWithString(const str, charMapFile: string;
  itemWidth, itemHeight, startCharMap: Cardinal): Boolean;
var
  texture: CCTexture2D;
begin
  texture := CCTextureCache.sharedTextureCache().addImage(charMapFile);
  Result := initWithString(str, texture, itemWidth, itemHeight, startCharMap);
end;

procedure CCLabelAtlas.setString(const slabel: string);
var
  len: Cardinal;
  s: CCSize;
begin
  len := Length(slabel);
  if len > TextureAtlas.TotalQuads then
  begin
    TextureAtlas.resizeCapacity(len);
  end;

  m_sString := slabel;
  Self.updateAtlasValues();
  s := CCSizeMake(len*m_uItemWidth, m_uItemHeight);
  Self.setContentSize(s);
  QuadsToDraw := len;
end;

procedure CCLabelAtlas.updateAtlasValues;
var
  n: Cardinal;
  s: string;
  texture: CCTexture2D;
  quads: ptccV3F_C4B_T2F_Quad;
  textureWide, textureHigh, itemWidthInPixels, itemHeightInPixels: Single;
  i: Cardinal;
  a: Byte;
  row, col: Single;
  left, right, top, bottom: Single;
  c: ccColor4B;
  totalQuads: Cardinal;
begin
  n := Length(m_sString);
  s := m_sString;

  texture := TextureAtlas.Texture;
  textureWide := texture.PixelsWide;
  textureHigh := texture.PixelsHigh;
  itemWidthInPixels := m_uItemWidth * CC_CONTENT_SCALE_FACTOR();
  itemHeightInPixels := m_uItemHeight * CC_CONTENT_SCALE_FACTOR();

  if m_bIgnoreContentScaleFactor then
  begin
    itemWidthInPixels := m_uItemWidth;
    itemHeightInPixels := m_uItemHeight;
  end;

  CCAssert( n <= m_pTextureAtlas.getCapacity(), 'updateAtlasValues: Invalid String length');
  quads := ptccV3F_C4B_T2F_Quad(m_pTextureAtlas.getQuads());

  if n > 0 then
  begin
    for i := 0 to n-1 do
    begin
      a := Ord(s[i+1]) - m_uMapStartChar;
      row := a mod m_uItemsPerRow;
      col := a div m_uItemsPerRow;

      left := row * itemWidthInPixels / textureWide;
      right := left + itemWidthInPixels / textureWide;
      top := col * itemHeightInPixels / textureHigh;
      bottom := top + itemHeightInPixels / textureHigh;

      quads[i].tl.texCoords.u := left;
      quads[i].tl.texCoords.v := top;
      quads[i].tr.texCoords.u := right;
      quads[i].tr.texCoords.v := top;
      quads[i].bl.texCoords.u := left;
      quads[i].bl.texCoords.v := bottom;
      quads[i].br.texCoords.u := right;
      quads[i].br.texCoords.v := bottom;

      quads[i].bl.vertices.x := i * m_uItemWidth;
      quads[i].bl.vertices.y := 0.0;
      quads[i].bl.vertices.z := 0.0;
      quads[i].br.vertices.x := i * m_uItemWidth + m_uItemWidth;
      quads[i].br.vertices.y := 0.0;
      quads[i].br.vertices.z := 0.0;
      quads[i].tl.vertices.x := i * m_uItemWidth;
      quads[i].tl.vertices.y := m_uItemHeight;
      quads[i].tl.vertices.z := 0.0;
      quads[i].tr.vertices.x := i * m_uItemWidth + m_uItemWidth;
      quads[i].tr.vertices.y := m_uItemHeight;
      quads[i].tr.vertices.z := 0.0;

      c.r := _displayedColor.r; c.g := _displayedColor.g; c.b := _displayedColor.b; c.a := _displayedOpacity;
      quads[i].tl.colors := c;
      quads[i].tr.colors := c;
      quads[i].bl.colors := c;
      quads[i].br.colors := c;
    end;

    m_pTextureAtlas.setDirty(True);
    totalQuads := m_pTextureAtlas.getTotalQuads();
    if n > totalQuads then
      m_pTextureAtlas.increaseTotalQuadsWith(n - totalQuads);
  end;
end;

function CCLabelAtlas.initWithString(const str: string;
  texture: CCTexture2D; itemWidth, itemHeight,
  startCharMap: Cardinal): Boolean;
begin
  CCAssert(str <> '', '');
  if inherited initWithTexture(texture, itemWidth, itemHeight, Length(str)) then
  begin
    m_uMapStartChar := startCharMap;
    setString(str);
    Result := True;
    Exit;
  end;

  Result := False;
end;

end.
