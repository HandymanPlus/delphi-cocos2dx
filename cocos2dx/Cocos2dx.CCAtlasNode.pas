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

unit Cocos2dx.CCAtlasNode;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCNode, Cocos2dx.CCTypes, Cocos2dx.CCTextureAtlas, Cocos2dx.CCTexture2D;

type
  (** @brief CCAtlasNode is a subclass of CCNode that implements the CCRGBAProtocol and CCTextureProtocol protocol

  It knows how to render a TextureAtlas object.
  If you are going to render a TextureAtlas consider subclassing CCAtlasNode (or a subclass of CCAtlasNode)

  All features from CCNode are valid, plus the following features:
  - opacity and RGB colors
  *)
  CCAtlasNode = class(CCNodeRGBA{CCTextureProtocol})
  private
    m_tBlendFunc: ccBlendFunc;
    m_uQuadsToDraw: Cardinal;
    procedure calculateMaxItems();
    procedure updateBlendFunc();
    procedure updateOpacityModifyRGB();
    function getQuadsToDraw: Cardinal;
    procedure setQuadsToDraw(const Value: Cardinal);
    function getTextureAtlas: CCTextureAtlas;
    procedure setTextureAtlas(const Value: CCTextureAtlas);
    //procedure setIgnoreContentScaleFactor(bIgnoreContentScaleFactor: Boolean);
  protected
    m_pTextureAtlas: CCTextureAtlas;
    m_uItemsPerRow: Cardinal;
    m_uItemsPerColumn: Cardinal;
    m_uItemWidth: Cardinal;
    m_uItemHeight: Cardinal;
    m_tColorUnmodified: ccColor3B;
    m_bIsOpacityModifyRGB: Boolean;
    m_nUniformColor: GLint;
    m_tColor: ccColor3B;
    m_cOpacity: GLubyte;
    // This varible is only used for CCLabelAtlas FPS display. So plz don't modify its value.
    m_bIgnoreContentScaleFactor: Boolean;
  public
    function getTexture(): CCTexture2D; override;
    procedure setTexture(texture: CCTexture2D); override;
    //interface
    function isOpacityModifyRGB(): Boolean; override;
    procedure setOpacityModifyRGB(bValue: Boolean); override;
    function getColor(): ccColor3B; override;
    procedure setColor(const color: ccColor3B); override;
    procedure setOpacity(opacity: GLubyte); override;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(const tile: string; tileWidth, tileHeight, itemsToRender: Cardinal): CCAtlasNode;
    function initWithTileFile(const tile: string; tileWidth, tileHeight, itemsToRender: Cardinal): Boolean;
    function initWithTexture(texture: CCTexture2D; tileWidth, tileHeight, itemsToRender: Cardinal): Boolean;
    procedure updateAtlasValues(); virtual;
    procedure draw(); override;

    property QuadsToDraw: Cardinal read getQuadsToDraw write setQuadsToDraw;
    property TextureAtlas: CCTextureAtlas read getTextureAtlas write setTextureAtlas;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCMacros, Cocos2dx.CCShaderCache, Cocos2dx.CCGLProgram,
  Cocos2dx.CCGeometry, Cocos2dx.CCGLStateCache, Cocos2dx.CCCommon, Cocos2dx.CCTextureCache;

{ CCAtlasNode }

class function CCAtlasNode._create(const tile: string; tileWidth,
  tileHeight, itemsToRender: Cardinal): CCAtlasNode;
var
  pRet: CCAtlasNode;
begin
  pRet := CCAtlasNode.Create;
  if (pRet <> nil) and pRet.initWithTileFile(tile, tileWidth, tileHeight, itemsToRender) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCAtlasNode.calculateMaxItems;
var
  s: CCSize;
begin
  s := m_pTextureAtlas.Texture.getContentSize();
  if m_bIgnoreContentScaleFactor then
  begin
    s := m_pTextureAtlas.Texture.getContentSizeInPixels();
  end;  
  m_uItemsPerColumn := Round(s.height/m_uItemHeight);
  m_uItemsPerRow := Round(s.width/m_uItemWidth);
end;

constructor CCAtlasNode.Create;
begin
  inherited Create();
end;

destructor CCAtlasNode.Destroy;
begin
  CC_SAFE_RELEASE(m_pTextureAtlas);
  inherited;
end;

procedure CCAtlasNode.draw;
var
  colors: array [0..3] of GLfloat;
begin
  CC_NODE_DRAW_SETUP();
  
  ccGLBlendFunc(m_tBlendFunc.src, m_tBlendFunc.dst);

  colors[0] := _displayedColor.r/255.0;
  colors[1] := _displayedColor.g/255.0;
  colors[2] := _displayedColor.b/255.0;
  colors[3] := _displayedOpacity/255.0;
  ShaderProgram.setUniformLocationWith4fv(m_nUniformColor, @colors[0], 1);
  m_pTextureAtlas.drawNumberOfQuads(m_uQuadsToDraw, 0);
end;

function CCAtlasNode.getColor: ccColor3B;
begin
  if m_bIsOpacityModifyRGB then
  begin
    Result := m_tColorUnmodified;
    Exit;
  end;
  Result := inherited getColor();
end;

function CCAtlasNode.getQuadsToDraw: Cardinal;
begin
  Result := m_uQuadsToDraw;
end;

function CCAtlasNode.getTexture: CCTexture2D;
begin
  Result := m_pTextureAtlas.Texture;
end;

function CCAtlasNode.initWithTileFile(const tile: string; tileWidth,
  tileHeight, itemsToRender: Cardinal): Boolean;
var
  texture: CCTexture2D;
begin
  CCAssert(tile <> '', 'title should not be null');
  texture := CCTextureCache.sharedTextureCache().addImage(tile);
  Result := initWithTexture(texture, tileWidth, tileHeight, itemsToRender);
end;

function CCAtlasNode.isOpacityModifyRGB: Boolean;
begin
  Result := m_bIsOpacityModifyRGB;
end;

procedure CCAtlasNode.setColor(const color: ccColor3B);
var
  tmp: ccColor3B;
begin
  tmp := color;
  m_tColorUnmodified := color;

  if m_bIsOpacityModifyRGB then
  begin
    tmp.r := (tmp.r * _displayedOpacity div 255);
    tmp.g := (tmp.g * _displayedOpacity div 255);
    tmp.b := (tmp.b * _displayedOpacity div 255);
  end;
  inherited setColor(tmp);
end;

procedure CCAtlasNode.setOpacity(opacity: GLubyte);
begin
  inherited setOpacity(opacity);
  if m_bIsOpacityModifyRGB then
    Self.setColor(m_tColorUnmodified);
end;

procedure CCAtlasNode.setOpacityModifyRGB(bValue: Boolean);
var
  oldColor: ccColor3B;
begin
  oldColor := getColor();
  m_bIsOpacityModifyRGB := bValue;
  setColor(oldColor);
end;

procedure CCAtlasNode.setQuadsToDraw(const Value: Cardinal);
begin
  m_uQuadsToDraw := Value;
end;

procedure CCAtlasNode.setTexture(texture: CCTexture2D);
begin
  m_pTextureAtlas.Texture := texture;
  updateBlendFunc();
  updateOpacityModifyRGB();
end;

procedure CCAtlasNode.updateAtlasValues;
begin
  CCAssert(false, 'CCAtlasNode:Abstract updateAtlasValue not overridden');
end;

procedure CCAtlasNode.updateBlendFunc;
begin
  if not m_pTextureAtlas.Texture.hasPremultipliedAlpha then
  begin
    m_tBlendFunc.src := GL_SRC_ALPHA;
    m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
  end;  
end;

procedure CCAtlasNode.updateOpacityModifyRGB;
begin
  m_bIsOpacityModifyRGB := m_pTextureAtlas.Texture.hasPremultipliedAlpha();
end;

function CCAtlasNode.getTextureAtlas: CCTextureAtlas;
begin
  Result := m_pTextureAtlas;
end;

procedure CCAtlasNode.setTextureAtlas(const Value: CCTextureAtlas);
begin
  if m_pTextureAtlas <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pTextureAtlas);
    m_pTextureAtlas := Value;
  end;
end;

function CCAtlasNode.initWithTexture(texture: CCTexture2D; tileWidth,
  tileHeight, itemsToRender: Cardinal): Boolean;
begin
  m_uItemWidth := tileWidth;
  m_uItemHeight := tileHeight;

  m_tColorUnmodified := ccWHITE;
  m_bIsOpacityModifyRGB := True;

  m_tBlendFunc.src := CC_BLEND_SRC;
  m_tBlendFunc.dst := CC_BLEND_DST;


  m_pTextureAtlas := CCTextureAtlas.Create();
  m_pTextureAtlas.initWithTexture(texture, itemsToRender);


  if m_pTextureAtlas = nil then
  begin
    CCLOG('cocos2d: Could not initialize CCAtlasNode. Invalid Texture.', []);
    Result := False;
    Exit;
  end;

  Self.updateBlendFunc();
  Self.updateOpacityModifyRGB();
  Self.calculateMaxItems();

  m_uQuadsToDraw := itemsToRender;

  setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTexture_uColor));
  m_nUniformColor := glGetUniformLocation(ShaderProgram.getProgram(), 'u_color');
  Result := True;
end;

{procedure CCAtlasNode.setIgnoreContentScaleFactor(
  bIgnoreContentScaleFactor: Boolean);
begin
  m_bIgnoreContentScaleFactor := bIgnoreContentScaleFactor;
end;}

end.
