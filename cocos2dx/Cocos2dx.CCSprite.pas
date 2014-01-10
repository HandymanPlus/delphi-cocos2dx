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

unit Cocos2dx.CCSprite;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils,
  Cocos2dx.CCNode, Cocos2dx.CCTypes, Cocos2dx.CCTexture2D, Cocos2dx.CCGeometry, Cocos2dx.CCAffineTransform,
  Cocos2dx.CCSpriteBatchNode, Cocos2dx.CCTextureAtlas, Cocos2dx.CCSpriteFrame;

const CCSpriteIndexNotInitialized = $FFFFFFFF;  // CCSprite invalid index on the CCSpriteBatchNode

type
  (**
   * CCSprite is a 2d image ( http://en.wikipedia.org/wiki/Sprite_(computer_graphics) )
   *
   * CCSprite can be created with an image, or with a sub-rectangle of an image.
   *
   * If the parent or any of its ancestors is a CCSpriteBatchNode then the following features/limitations are valid
   *    - Features when the parent is a CCBatchNode:
   *        - MUCH faster rendering, specially if the CCSpriteBatchNode has many children. All the children will be drawn in a single batch.
   *
   *    - Limitations
   *        - Camera is not supported yet (eg: CCOrbitCamera action doesn't work)
   *        - GridBase actions are not supported (eg: CCLens, CCRipple, CCTwirl)
   *        - The Alias/Antialias property belongs to CCSpriteBatchNode, so you can't individually set the aliased property.
   *        - The Blending function property belongs to CCSpriteBatchNode, so you can't individually set the blending function property.
   *        - Parallax scroller is not supported, but can be simulated with a "proxy" sprite.
   *
   *  If the parent is an standard CCNode, then CCSprite behaves like any other CCNode:
   *    - It supports blending functions
   *    - It supports aliasing / antialiasing
   *    - But the rendering will be slower: 1 draw per children.
   *
   * The default anchorPoint in CCSprite is (0.5, 0.5).
   *)
  CCSprite = class(CCNodeRGBA{, CCTextureProtocol})
  protected
    m_bDirty: Boolean;
    m_bRecursiveDirty: Boolean;
    m_bHasChildren: Boolean;
    m_bShouldBeHidden: Boolean;
    m_transformToBatch: CCAffineTransform;
    m_sBlendFunc: ccBlendFunc;
    m_pobTexture: CCTexture2D;
    m_obRect: CCRect;
    m_bRectRotated: Boolean;
    m_obOffsetPosition: CCPoint;
    m_obUnflippedOffsetPositionFromCenter: CCPoint;
    m_sQuad: ccV3F_C4B_T2F_Quad;

    m_bOpacityModifyRGB: Boolean;
    m_bFlipX: Boolean;
    m_bFlipY: Boolean;
    m_nOpacity: GLubyte;
    m_sColor: ccColor3B;
    m_uAtlasIndex: Cardinal;
    m_pobBatchNode: CCSpriteBatchNode;
    m_pobTextureAtlas: CCTextureAtlas;

    procedure setTextureCoords(rect: CCRect); virtual;
    procedure updateBlendFunc(); virtual;
    procedure setReorderChildDirtyRecursively(); virtual;
    procedure SET_DIRTY_RECURSIVELY();
  public
    constructor Create();
    destructor Destroy(); override;
    function init(): Boolean; override;
    procedure removeChild(child: CCNode; cleanup: Boolean); override;
    procedure removeAllChildrenWithCleanup(bCleanup: Boolean); override;
    procedure reorderChild(child: CCNode; zOrder: Integer); override;
    procedure addChild(child: CCNode); override;
    procedure addChild(child: CCNode; zOrder: Integer); override;
    procedure addChild(child: CCNode; zOrder: Integer; tag: Integer); override;
    procedure sortAllChildren(); override;

    procedure setDirtyRecursively(bValue: Boolean);
    procedure setPosition(const newPosition: CCPoint); override;
    procedure setRotation(const newRotation: Single); override;
    procedure setRotationX(const fRotationX: Single); override;
    procedure setRotationY(const fRotationY: Single); override;
    procedure setSkewX(const newSkewX: Single); override;
    procedure setSkewY(const newSkewY: Single); override;
    procedure setScaleX(const newScaleX: Single); override;
    procedure setScaleY(const newScaleY: Single); override;
    procedure setScale(scale: Single); override;
    procedure setVerteZ(const Value: Single); override;
    procedure setAnchorPoint(const point: CCPoint); override;
    procedure ignoreAnchorPointForPosition(newValue: Boolean); override;
    procedure setVisible(visible: Boolean); override;
    procedure setFlipX(bFlip: Boolean);
    procedure setFlipY(bFlip: Boolean);

    (** 
     * Returns the flag which indicates whether the sprite is flipped horizontally or not.
     *
     * It only flips the texture of the sprite, and not the texture of the sprite's children.
     * Also, flipping the texture doesn't alter the anchorPoint.
     * If you want to flip the anchorPoint too, and/or to flip the children too use:
     * sprite->setScaleX(sprite->getScaleX() * -1);
     *
     * @return true if the sprite is flipped horizaontally, false otherwise.
     * @js isFlippedX
     *)
    function isFlipX(): Boolean;
    function isFlipY(): Boolean;
    procedure updateColor();
  public
    //CCRGBAProtocol
    procedure setColor(const color: ccColor3B); override;
    function getOpacity(): GLubyte; override;
    procedure setOpacity(opacity: GLubyte); override;
    procedure setOpacityModifyRGB(bValue: Boolean); override;
    function isOpacityModifyRGB(): Boolean; override;
    procedure updateDisplayedColor(const color: ccColor3B); override;
    procedure updateDisplayedOpacity(opacity: GLubyte); override;
    //CCBlendProtocol
    procedure setBlendFunc(blendFunc: ccBlendFunc); override;
    function getBlendFunc(): ccBlendFunc; override;
    //CCTextureProtocol
    function getTexture(): CCTexture2D; override;
    procedure setTexture(texture: CCTexture2D); override;
    //
    function initWithTexture(pTexture: CCTexture2D): Boolean; overload; virtual;
    function initWithTexture(pTexture: CCTexture2D; const rect: CCRect): Boolean; overload; virtual;
    function initWithTexture(pTexture: CCTexture2D; const rect: CCRect; rotated: Boolean): Boolean; overload; virtual;

    function initWithSpriteFrame(pSpriteFrame: CCSpriteFrame): Boolean; virtual;
    function initWithSpriteFrameName(const pszSpriteName: string): Boolean; virtual;
    function initWithFile(const pszFilename: string): Boolean; overload;virtual;
    function initWithFile(const pszFilename: string; const rect: CCRect): Boolean; overload; virtual;

    (**
     * Updates the quad according the rotation, position, scale values.
     *)
    procedure updateTransform(); override;

    (**
     * Changes the display frame with animation name and index.
     * The animation name will be get from the CCAnimationCache
     *)
    procedure setDisplayFrameWithAnimationName(const animationName: string; frameIndex: Integer); virtual;

    (**
     * Updates the texture rect of the CCSprite in points.
     * It will call setTextureRect:rotated:untrimmedSize with rotated = NO, and utrimmedSize = rect.size.
     *)
    procedure setTextureRect(const rect: CCRect); overload; virtual;

    (**
     * Sets the texture rect, rectRotated and untrimmed size of the CCSprite in points.
     * It will update the texture coordinates and the vertex rectangle.
     *)
    procedure setTextureRect(const rect: CCRect; rotated: Boolean; const untimmedSize: CCSize); overload; virtual;

    (**
     * Sets the vertex rect.
     * It will be called internally by setTextureRect.
     * Useful if you want to create 2x images from SD images in Retina Display.
     * Do not call it manually. Use setTextureRect instead.
     *)
    procedure setVertexRect(const rect: CCRect); virtual;

    (**
     * Sets the batch node to sprite
     * @warning This method is not recommended for game developers. Sample code for using batch node
     * @code
     * CCSpriteBatchNode *batch = CCSpriteBatchNode::create("Images/grossini_dance_atlas.png", 15);
     * CCSprite *sprite = CCSprite::createWithTexture(batch->getTexture(), CCRectMake(0, 0, 57, 57));
     * batch->addChild(sprite);
     * layer->addChild(batch);
     * @endcode
     *)
    procedure setBatchNode(pobSpriteBatchNode: CCSpriteBatchNode); virtual;

    procedure setDisplayFrame(pNewFrame: CCSpriteFrame); virtual;
    function isFrameDisplayed(pFrame: CCSpriteFrame): Boolean; virtual;
    function displayFrame(): CCSpriteFrame;

    procedure draw(); override;
    function isDirty(): Boolean; virtual;
    procedure setDirty(bDirty: Boolean); virtual;
    function getQuad(): ccV3F_C4B_T2F_Quad;
    function isTextureRectRotated(): Boolean;
    function getAtlasIndex(): Cardinal;
    procedure setAtlasIndex(uAtlasIndex: Cardinal);
    function getTextureRect(): CCRect;
    function getTextureAtlas(): CCTextureAtlas;
    procedure setTextureAtlas(pobTextureAtlas: CCTextureAtlas);

    (**
     * Returns the batch node object if this sprite is rendered by CCSpriteBatchNode
     *
     * @return The CCSpriteBatchNode object if this sprite is rendered by CCSpriteBatchNode,
     *         NULL if the sprite isn't used batch node.
     *)
    function getBatchNode(): CCSpriteBatchNode; virtual;
    function getOffsetPosition(): CCPoint;

    (**
     * Creates a sprite with an exsiting texture contained in a CCTexture2D object
     * After creation, the rect will be the size of the texture, and the offset will be (0,0).
     *
     * @param   pTexture    A pointer to a CCTexture2D object.
     * @return  A valid sprite object that is marked as autoreleased.
     *)
    class function createWithTexture(pTexture: CCTexture2D): CCSprite; overload;

    (**
     * Creates a sprite with a texture and a rect.
     *
     * After creation, the offset will be (0,0).
     *
     * @param   pTexture    A pointer to an existing CCTexture2D object.
     *                      You can use a CCTexture2D object for many sprites.
     * @param   rect        Only the contents inside the rect of this texture will be applied for this sprite.
     * @return  A valid sprite object that is marked as autoreleased.
     *)
    class function createWithTexture(pTexture: CCTexture2D; const rect: CCRect): CCSprite; overload;

    (**
     * Creates a sprite with an sprite frame.
     *
     * @param   pSpriteFrame    A sprite frame which involves a texture and a rect
     * @return  A valid sprite object that is marked as autoreleased.
     *)
    class function createWithSpriteFrame(pSpriteFrame: CCSpriteFrame): CCSprite;

    (**
     * Creates a sprite with an sprite frame name.
     *
     * A CCSpriteFrame will be fetched from the CCSpriteFrameCache by pszSpriteFrameName param.
     * If the CCSpriteFrame doesn't exist it will raise an exception.
     *
     * @param   pszSpriteFrameName A null terminated string which indicates the sprite frame name.
     * @return  A valid sprite object that is marked as autoreleased.
     *)
    class function createWithSpriteFrameName(const pszSpriteFrameName: string): CCSprite;

    (**
     * Creates a sprite with an image filename.
     *
     * After creation, the rect of sprite will be the size of the image,
     * and the offset will be (0,0).
     *
     * @param   pszFileName The string which indicates a path to image file, e.g., "scene1/monster.png".
     * @return  A valid sprite object that is marked as autoreleased.
     *)
    class function _create(const pszFilename: string): CCSprite; overload;

    (**
     * Creates a sprite with an image filename and a rect.
     *
     * @param   pszFileName The string wich indicates a path to image file, e.g., "scene1/monster.png"
     * @param   rect        Only the contents inside rect of pszFileName's texture will be applied for this sprite.
     * @return  A valid sprite object that is marked as autoreleased.
     *)
    class function _create(const pszFilename: string; const rect: CCRect): CCSprite; overload;

    (**
     * Creates an empty sprite without texture. You can call setTexture method subsequently.
     *
     * @return An empty sprite object that is marked as autoreleased.
     *)
    class function _create(): CCSprite; overload;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCShaderCache, Cocos2dx.CCGLProgram,
  Cocos2dx.CCMacros, Cocos2dx.CCPointExtension, Cocos2dx.CCTextureCache,
  Cocos2dx.CCGLStateCache, Cocos2dx.cCCArray, Cocos2dx.CCObject, Cocos2dx.CCImage,
  Cocos2dx.CCSpriteFrameCache, Cocos2dx.CCAnimation, Cocos2dx.CCAnimationCache;

{ CCSprite }

procedure CCSprite.addChild(child: CCNode);
begin
  inherited addChild(child);

end;

procedure CCSprite.addChild(child: CCNode; zOrder: Integer);
begin
  inherited addChild(child, zOrder);

end;

procedure CCSprite.addChild(child: CCNode; zOrder, tag: Integer);
var
  pChildSprite: CCSprite;
begin
  CCAssert(child <> nil, 'Argument must be non-NULL');
  if m_pobBatchNode <> nil then
  begin
    pChildSprite := CCSprite(child);
    //CCAssert( pChildSprite, 'CCSprite only supports CCSprites as children when using CCSpriteBatchNode');
    CCAssert(pChildSprite.getTexture().Name = m_pobTextureAtlas.Texture.Name, '');
    m_pobBatchNode.appendChild(pChildSprite);

    if not m_bReorderChildDirty then
    begin
      setReorderChildDirtyRecursively();
    end;  
  end;
    
  inherited addChild(child, zOrder, tag);
  m_bHasChildren := True;
end;

constructor CCSprite.Create;
begin
  inherited Create();
  m_pobTexture := nil;
  m_bShouldBeHidden := False;
end;

class function CCSprite.createWithSpriteFrameName(
  const pszSpriteFrameName: string): CCSprite;
var
  pFrame: CCSpriteFrame;
  {$IFDEF COCOS2D_DEBUG}
  msg: string;
  {$ENDIF}
begin
  pFrame := CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName(pszSpriteFrameName);

  {$IFDEF COCOS2D_DEBUG}
  msg := Format('Invalid spriteFrameName: %s', [pszSpriteFrameName]);
  CCAssert(pFrame <> nil, msg);
  {$ENDIF}

  Result := createWithSpriteFrame(pFrame);
end;

class function CCSprite.createWithTexture(pTexture: CCTexture2D;
  const rect: CCRect): CCSprite;
var
  pobSprite: CCSprite;
begin
  pobSprite := CCSprite.Create;
  if (pobSprite <> nil) and pobSprite.initWithTexture(pTexture, rect) then
  begin
    pobSprite.autorelease();
    Result := pobSprite;
    Exit;
  end;
  CC_SAFE_DELETE(pobSprite);
  Result := nil;
end;

class function CCSprite.createWithTexture(pTexture: CCTexture2D): CCSprite;
var
  pobSprite: CCSprite;
begin
  pobSprite := CCSprite.Create;
  if (pobSprite <> nil) and pobSprite.initWithTexture(pTexture) then
  begin
    pobSprite.autorelease();
    Result := pobSprite;
    Exit;
  end;
  CC_SAFE_DELETE(pobSprite);
  Result := nil;
end;

destructor CCSprite.Destroy;
begin
  CC_SAFE_RELEASE(m_pobTexture);
  inherited;
end;

procedure CCSprite.draw;
var
  offset: Cardinal;
  kQuadSize: Cardinal;
  vDiff, tDiff, cDiff: Cardinal;
  {$IF Defined(CC_SPRITE_DEBUG_DRAW)}
  vertices: array [0..3] of CCPoint;
  s: CCSize;
  offsetPix: CCPoint;
  {$IFEND}
begin
  CCAssert(m_pobBatchNode = nil, 'If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called');

  CC_NODE_DRAW_SETUP();
  ccGLBlendFunc(m_sBlendFunc.src, m_sBlendFunc.dst);

  if m_pobTexture <> nil then
  begin
    ccGLBindTexture2D(m_pobTexture.Name);
  end else
  begin
    ccGLBindTexture2D(0);
  end;

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);

  kQuadSize := SizeOf(m_sQuad.bl);
  offset := Cardinal(@m_sQuad);

  get_ccV3F_C4B_T2F_dif(vDiff, cDiff, tDiff);

  glVertexAttribPointer(kCCVertexAttrib_Position,  3, GL_FLOAT, GL_FALSE, kQuadSize, Pointer(offset+vDiff));
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, Pointer(offset+tDiff));
  glVertexAttribPointer(kCCVertexAttrib_Color,     4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, Pointer(offset+cDiff));

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  //CHECK_GL_ERROR_DEBUG();

  {$IFDEF CC_SPRITE_DEBUG_DRAW}
  s := getTextureRect().size;
  offsetPix := getOffsetPosition();
  vertices[0] := ccp(offsetPix.x, offsetPix.y);
  vertices[1] := ccp(offsetPix.x + s.width, offsetPix.y);
  vertices[2] := ccp(offsetPix.x + s.width, offsetPix.y + s.height);
  vertices[3] := ccp(offsetPix.x, offsetPix.y + s.height);
  ccDrawPoly(vertices, 4, True);
  {$ENDIF}

  CC_INCREMENT_GL_DRAWS(1);
end;

function CCSprite.getAtlasIndex: Cardinal;
begin
  Result := m_uAtlasIndex;
end;

function CCSprite.getBlendFunc: ccBlendFunc;
begin
  Result := m_sBlendFunc;
end;

function CCSprite.getOffsetPosition: CCPoint;
begin
  Result := m_obOffsetPosition;
end;

function CCSprite.getOpacity: GLubyte;
begin
  Result := m_nOpacity;
end;

function CCSprite.getQuad: ccV3F_C4B_T2F_Quad;
begin
  Result := m_sQuad;
end;

function CCSprite.getTexture: CCTexture2D;
begin
  Result := m_pobTexture;
end;

function CCSprite.init: Boolean;
begin
  Result := Self.initWithTexture(nil, CCRectZero);
end;

function CCSprite.isDirty: Boolean;
begin
  Result := m_bDirty;
end;

function CCSprite.isOpacityModifyRGB: Boolean;
begin
  Result := m_bOpacityModifyRGB;
end;

function CCSprite.isTextureRectRotated: Boolean;
begin
  Result := m_bRectRotated;
end;

procedure CCSprite.removeAllChildrenWithCleanup(bCleanup: Boolean);
var
  i: Integer;
  pChild: CCNode;
begin
  if m_pobBatchNode <> nil then
  begin
    if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    begin
      for i := 0 to m_pChildren.count()-1 do
      begin
        pChild := CCNode(m_pChildren.objectAtIndex(i));
        if pChild <> nil then
          m_pobBatchNode.removeSpriteFromAtlas(pChild);
      end;
    end;  
  end;
  inherited removeAllChildrenWithCleanup(bCleanup);
  m_bHasChildren := False;
end;

procedure CCSprite.removeChild(child: CCNode; cleanup: Boolean);
begin
  if m_pobBatchNode <> nil then
  begin
    m_pobBatchNode.removeSpriteFromAtlas(child);
  end;
  inherited removeChild(child, cleanup);
end;

procedure CCSprite.reorderChild(child: CCNode; zOrder: Integer);
begin
  if zOrder = child.ZOrder then
    Exit;

  if (m_pobBatchNode <> nil) and not m_bReorderChildDirty then
  begin
    setReorderChildDirtyRecursively();
    m_pobBatchNode.reorderBatch(True);
  end;  

  inherited reorderChild(child, zOrder);
end;

procedure CCSprite.setAtlasIndex(uAtlasIndex: Cardinal);
begin
  m_uAtlasIndex := uAtlasIndex;
end;

procedure CCSprite.setBlendFunc(blendFunc: ccBlendFunc);
begin
  m_sBlendFunc := blendFunc;
end;

procedure CCSprite.setDirty(bDirty: Boolean);
begin
  m_bDirty := bDirty;
end;

procedure CCSprite.setDirtyRecursively(bValue: Boolean);
var
  pObject: CCSprite;
  i: Integer;
begin
  m_bRecursiveDirty := bValue;
  setDirty(bValue);

  if m_bHasChildren then
  begin
    for i := 0 to Children.count()-1 do
    begin
      pObject := CCSprite(Children.objectAtIndex(i));
      if pObject <> nil then
      begin
        pObject.setDirtyRecursively(True);
      end;  
    end;
  end;
end;

procedure CCSprite.setOpacity(opacity: GLubyte);
begin
  inherited setOpacity(opacity);
  updateColor();
end;

procedure CCSprite.setOpacityModifyRGB(bValue: Boolean);
begin
  if m_bOpacityModifyRGB <> bValue then
  begin
    m_bOpacityModifyRGB := bValue;
    updateColor();
  end;
end;

const cc_2x2_white_image: array [0..15] of Byte = (
    // RGBA8888
    $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF
);

const CC_2x2_WHITE_IMAGE_KEY = 'cc_2x2_white_image';

procedure CCSprite.setTexture(texture: CCTexture2D);
var
  image: CCImage;
  isOK: Boolean;
begin
  if texture = nil then
  begin
    texture := CCTextureCache.sharedTextureCache().textureForKey(CC_2x2_WHITE_IMAGE_KEY);
    if texture = nil then
    begin
      image := CCImage.Create;
      isOK := image.initWithImageData(@cc_2x2_white_image[0], SizeOf(cc_2x2_white_image), kFmtRawData, 2, 2, 8);
      CCAssert(isOK, 'The 2x2 empty texture was created unsuccessfully.');

      texture := CCTextureCache.sharedTextureCache().addUIImage(image, CC_2x2_WHITE_IMAGE_KEY);
      CC_SAFE_RELEASE(image);
    end;
  end;

  if (m_pobBatchNode = nil) and (m_pobTexture <> texture) then
  begin
    CC_SAFE_RETAIN(texture);
    CC_SAFE_RELEASE(m_pobTexture);
    m_pobTexture := texture;
    updateBlendFunc();
  end;  
end;

class function CCSprite._create(const pszFilename: string;
  const rect: CCRect): CCSprite;
var
  pobSprite: CCSprite;
begin
  pobSprite := CCSprite.Create;
  if (pobSprite <> nil) and pobSprite.initWithFile(pszFilename, rect) then
  begin
    pobSprite.autorelease();
    Result := pobSprite;
    Exit;
  end;
  CC_SAFE_DELETE(pobSprite);
  Result := nil;
end;

class function CCSprite._create: CCSprite;
var
  pSprite: CCSprite;
begin
  pSprite := CCSprite.Create;
  if (pSprite <> nil) and pSprite.init() then
  begin
    pSprite.autorelease();
    Result := pSprite;
    Exit;
  end;
  CC_SAFE_DELETE(pSprite);
  Result := nil;
end;

class function CCSprite._create(const pszFilename: string): CCSprite;
var
  pobSprite: CCSprite;
begin
  pobSprite := CCSprite.Create;
  if (pobSprite <> nil) and pobSprite.initWithFile(pszFilename) then
  begin
    pobSprite.autorelease();
    Result := pobSprite;
    Exit;
  end;
  CC_SAFE_DELETE(pobSprite);
  Result := nil;
end;

procedure CCSprite.sortAllChildren;
var
  i, j, len: Integer;
  tempItem, pNodej: CCNode;
  x: PCCObectAry;
begin
  if m_bReorderChildDirty then
  begin
    len := Children.data.num;
    x := Children.data.arr;

    for i := 1 to len-1 do
    begin
      tempItem := CCNode(x[i]);
      j := i - 1;
      pNodej := CCNode(x[j]);

      while (j >= 0) and ( (tempItem.ZOrder < pNodej.ZOrder) or ( (tempItem.ZOrder = pNodej.ZOrder) and (tempItem.OrderOfArrival < pNodej.OrderOfArrival) )) do
      begin
        x[j+1] := x[j];
        j := j - 1;

        if j >= 0 then
          pNodej := CCNode(x[j]);
      end;
      x[j+1] := tempItem;
    end;

    m_bReorderChildDirty := False;
  end;
end;

procedure CCSprite.setPosition(const newPosition: CCPoint);
begin
  inherited setPosition(newPosition);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.ignoreAnchorPointForPosition(newValue: Boolean);
begin
  CCAssert(m_pobBatchNode = nil, 'ignoreAnchorPointForPosition is invalid in CCSprite');
  inherited ignoreAnchorPointForPosition(newValue);
end;

procedure CCSprite.setAnchorPoint(const point: CCPoint);
begin
  inherited setAnchorPoint(point);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setRotation(const newRotation: Single);
begin
  inherited setRotation(newRotation);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setScale(scale: Single);
begin
  inherited setScale(scale);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setScaleX(const newScaleX: Single);
begin
  inherited setScaleX(newScaleX);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setScaleY(const newScaleY: Single);
begin
  inherited setScaleY(newScaleY);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setSkewX(const newSkewX: Single);
begin
  inherited setSkewX(newSkewX);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setSkewY(const newSkewY: Single);
begin
  inherited setSkewY(newSkewY);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setVerteZ(const Value: Single);
begin
  inherited setVerteZ(Value);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setVisible(visible: Boolean);
begin
  inherited setVisible(visible);
  SET_DIRTY_RECURSIVELY();
end;

function CCSprite.isFlipX: Boolean;
begin
  Result := m_bFlipX;
end;

function CCSprite.isFlipY: Boolean;
begin
  Result := m_bFlipY;
end;

procedure CCSprite.setFlipX(bFlip: Boolean);
begin
  if m_bFlipX <> bFlip then
  begin
    m_bFlipX := bFlip;
    setTextureRect(m_obRect, m_bRectRotated, m_obContentSize);
  end;
end;

procedure CCSprite.setFlipY(bFlip: Boolean);
begin
  if m_bFlipY <> bFlip then
  begin
    m_bFlipY := bFlip;
    setTextureRect(m_obRect, m_bRectRotated, m_obContentSize);
  end;
end;

function CCSprite.initWithFile(const pszFilename: string): Boolean;
var
  pTexture: CCTexture2D;
  rect: CCRect;
begin
  pTexture := CCTextureCache.sharedTextureCache().addImage(pszFilename);
  if pTexture <> nil then
  begin
    rect := CCRectZero;
    rect.size := pTexture.getContentSize();
    Result := Self.initWithTexture(pTexture, rect);
    Exit;
  end;
  Result := False;
end;

function CCSprite.initWithFile(const pszFilename: string;
  const rect: CCRect): Boolean;
var
  pTexture: CCTexture2D;
begin
  pTexture := CCTextureCache.sharedTextureCache().addImage(pszFilename);
  if pTexture <> nil then
  begin
    Result := Self.initWithTexture(pTexture, rect);
    Exit;
  end;
  Result := False;
end;

function CCSprite.initWithSpriteFrameName(
  const pszSpriteName: string): Boolean;
begin
  Result := False;
end;

function CCSprite.initWithTexture(pTexture: CCTexture2D;
  const rect: CCRect; rotated: Boolean): Boolean;
const
  tmpColor: ccColor4B = (r: 255; g: 255; b: 255; a: 255);
begin
  if inherited init() then
  begin
    m_pobBatchNode := nil;

    m_bReorderChildDirty := False;
    setDirty(False);

    m_sBlendFunc.src := CC_BLEND_SRC;
    m_sBlendFunc.dst := CC_BLEND_DST;

    m_bFlipX := False; m_bFlipY := False;

    setAnchorPoint(ccp(0.5, 0.5));
    m_obOffsetPosition := CCPointZero;

    m_bHasChildren := False;

    FillChar(m_sQuad, SizeOf(m_sQuad), 0);
    m_sQuad.bl.colors := tmpColor;
    m_sQuad.br.colors := tmpColor;
    m_sQuad.tl.colors := tmpColor;
    m_sQuad.tr.colors := tmpColor;

    setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColor));

    setTexture(pTexture);
    setTextureRect(rect, rotated, rect.size);

    setBatchNode(nil);

    Result := True;
    Exit;
  end;

  Result := False;
end;

function CCSprite.initWithTexture(pTexture: CCTexture2D): Boolean;
var
  rect: CCRect;
begin
  rect := CCRectZero;
  rect.size := pTexture.getContentSize();
  Result := Self.initWithTexture(pTexture, rect);
end;

function CCSprite.initWithTexture(pTexture: CCTexture2D;
  const rect: CCRect): Boolean;
begin
  Result := Self.initWithTexture(pTexture, rect, False);
end;

procedure CCSprite.setTextureRect(const rect: CCRect; rotated: Boolean;
  const untimmedSize: CCSize);
var
  relativeOffset: CCPoint;
  x1, y1, x2, y2: Single;
begin
  m_bRectRotated := rotated;
  setContentSize(untimmedSize);
  setVertexRect(rect);
  setTextureCoords(rect);

  relativeOffset := m_obUnflippedOffsetPositionFromCenter;

  if m_bFlipX then
    relativeOffset.x := -relativeOffset.x;
  if m_bFlipY then
    relativeOffset.y := -relativeOffset.y;

  m_obOffsetPosition.x := relativeOffset.x + (m_obContentSize.width - m_obRect.size.width)/2;
  m_obOffsetPosition.y := relativeOffset.y + (m_obContentSize.height - m_obRect.size.height)/2;

  if m_pobBatchNode <> nil then
  begin
    setDirty(True);
  end else
  begin
    x1 := 0  + m_obOffsetPosition.x;
    y1 := 0  + m_obOffsetPosition.y;
    x2 := x1 + m_obRect.size.width;
    y2 := y1 + m_obRect.size.height;

    m_sQuad.bl.vertices := vertex3(x1, y1, 0);
    m_sQuad.br.vertices := vertex3(x2, y1, 0);
    m_sQuad.tl.vertices := vertex3(x1, y2, 0);
    m_sQuad.tr.vertices := vertex3(x2, y2, 0);
  end;
end;

procedure CCSprite.setTextureRect(const rect: CCRect);
begin
  setTextureRect(rect, False, rect.size);
end;

procedure CCSprite.setVertexRect(const rect: CCRect);
begin
  m_obRect := rect;
end;

procedure CCSprite.updateTransform;
const ve3zero: ccVertex3F = (x: 0; y: 0; z: 0);
var
  size: CCSize;
  x1, y1, x2, y2, x, y, cr, sr, cr2, sr2, ax, ay, bx, by, cx, cy, dx, dy: Single;
begin
  CCAssert(m_pobBatchNode <> nil, 'updateTransform is only valid when CCSprite is being rendered using an CCSpriteBatchNode');

  if isDirty() then
  begin
    if (not m_bVisible) or ( (Parent <> nil) and (Parent <> m_pobBatchNode) and CCSprite(Parent).m_bShouldBeHidden  ) then
    begin
      m_sQuad.br.vertices := ve3zero;
      m_sQuad.tl.vertices := ve3zero;
      m_sQuad.tr.vertices := ve3zero;
      m_sQuad.bl.vertices := ve3zero;

      m_bShouldBeHidden := True;
    end else
    begin
      m_bShouldBeHidden := False;

      if (Parent = nil) or (Parent = m_pobBatchNode) then
      begin
        m_transformToBatch := nodeToParentTransform();
      end else
      begin
        m_transformToBatch := CCAffineTransformConcat(nodeToParentTransform(), CCSprite(Parent).m_transformToBatch)
      end;

      size := m_obRect.size;
      x1 := m_obOffsetPosition.x;
      y1 := m_obOffsetPosition.y;

      x2 := x1 + size.width;
      y2 := y1 + size.height;
      x := m_transformToBatch.tx;
      y := m_transformToBatch.ty;

      cr :=   m_transformToBatch.a;
      sr :=   m_transformToBatch.b;
      cr2 :=  m_transformToBatch.d;
      sr2 := -m_transformToBatch.c; //-(!!!)m_transformToBatch.c
      ax := x1*cr - y1*sr2 + x;
      ay := x1*sr + y1*cr2 + y;

      bx := x2*cr - y1*sr2 + x;
      by := x2*sr + y1*cr2 + y;

      cx := x2*cr - y2*sr2 + x;
      cy := x2*sr + y2*cr2 + y;

      dx := x1*cr - y2*sr2 + x;
      dy := x1*sr + y2*cr2 + y;

      m_sQuad.bl.vertices := vertex3(ax, ay, VertexZ);
      m_sQuad.br.vertices := vertex3(bx, by, VertexZ);
      m_sQuad.tl.vertices := vertex3(dx, dy, VertexZ);
      m_sQuad.tr.vertices := vertex3(cx, cy, VertexZ);
    end;

    if m_pobTextureAtlas <> nil then
      m_pobTextureAtlas.updateQuad(@m_sQuad, m_uAtlasIndex);
      
    m_bRecursiveDirty := False;
    setDirty(False);
  end;

  (*if m_bHasChildren then
  begin
    if (Children <> nil) and (Children.count() > 0) then
    begin
      for i := 0 to Children.count()-1 do
      begin
        pSprite := CCSprite(Children.objectAtIndex(i));
        pSprite.updateTransform();
      end;
    end;
  end;*)
  inherited updateTransform();
end;

procedure CCSprite.setDisplayFrameWithAnimationName(
  const animationName: string; frameIndex: Integer);
var
  a: CCAnimation;
  frame: CCAnimationFrame;
begin
  CCAssert(animationName = '', 'CCSprite#setDisplayFrameWithAnimationName. animationName must not be NULL');

  a := CCAnimationCache.sharedAnimationCache().animationByName(animationName);
  CCAssert(a = nil, 'CCSprite#setDisplayFrameWithAnimationName: Frame not found');

  frame := CCAnimationFrame(a.Frames.objectAtIndex(frameIndex));
  CCAssert(frame = nil, 'CCSprite#setDisplayFrame. Invalid frame');

  setDisplayFrame(frame.SpriteFrame);
end;

procedure CCSprite.setReorderChildDirtyRecursively;
var
  pNode: CCNode;
begin
  if not m_bReorderChildDirty then
  begin
    m_bReorderChildDirty := True;
    pNode := Parent;

    while (pNode <> nil) and (pNode <> m_pobBatchNode)  do
    begin
      CCSprite(pNode).setReorderChildDirtyRecursively();
      pNode := pNode.Parent;
    end;  
  end;
end;

procedure CCSprite.setTextureCoords(rect: CCRect);
var
  tex: CCTexture2D;
  atlasWidth, atlasHeight, left, right, top, bottom, temp: Single;
begin
  rect := CC_RECT_POINTS_TO_PIXELS(rect);

  if m_pobBatchNode <> nil then
    tex := m_pobTextureAtlas.Texture
  else
    tex := m_pobTexture;

  if tex = nil then
  begin
    Exit;
  end;

  atlasWidth := tex.PixelsWide;
  atlasHeight := tex.PixelsHigh;

  if m_bRectRotated then
  begin
    left   :=  rect.origin.x/atlasWidth;
    right  := (rect.origin.x + rect.size.height)/atlasWidth;
    top    :=  rect.origin.y/atlasHeight;
    bottom := (rect.origin.y + rect.size.width)/atlasHeight;

    if m_bFlipX then
    begin
      temp := top; top := bottom; bottom := temp;
    end;

    if m_bFlipY then
    begin
      temp := right; right := left; left := temp;
    end;

    m_sQuad.bl.texCoords.u := left;
    m_sQuad.bl.texCoords.v := top;
    m_sQuad.br.texCoords.u := left;
    m_sQuad.br.texCoords.v := bottom;

    m_sQuad.tl.texCoords.u := right;
    m_sQuad.tl.texCoords.v := top;
    m_sQuad.tr.texCoords.u := right;
    m_sQuad.tr.texCoords.v := bottom;
  end else
  begin
    left   :=  rect.origin.x/atlasWidth;
    right  := (rect.origin.x + rect.size.width)/atlasWidth;
    top    :=  rect.origin.y/atlasHeight;
    bottom := (rect.origin.y + rect.size.height)/atlasHeight;

    if m_bFlipY then
    begin
      temp := top; top := bottom; bottom := temp;
    end;

    if m_bFlipX then
    begin
      temp := right; right := left; left := temp;
    end;

    m_sQuad.bl.texCoords.u := left;
    m_sQuad.bl.texCoords.v := bottom;
    m_sQuad.br.texCoords.u := right;
    m_sQuad.br.texCoords.v := bottom;

    m_sQuad.tl.texCoords.u := left;
    m_sQuad.tl.texCoords.v := top;
    m_sQuad.tr.texCoords.u := right;
    m_sQuad.tr.texCoords.v := top;
  end;   
end;

procedure CCSprite.updateBlendFunc;
begin
  if (m_pobTexture = nil) or not m_pobTexture.hasPremultipliedAlpha() then
  begin
    m_sBlendFunc.src := GL_SRC_ALPHA;
    m_sBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
    setOpacityModifyRGB(False);
  end else
  begin
    m_sBlendFunc.src := CC_BLEND_SRC;
    m_sBlendFunc.dst := CC_BLEND_DST;
    setOpacityModifyRGB(True);
  end;
end;

procedure CCSprite.updateColor;
var
  color4: ccColor4B;
begin
  color4.r := _displayedColor.r; color4.g := _displayedColor.g; color4.b := _displayedColor.b; color4.a := _displayedOpacity;

  if m_bOpacityModifyRGB then
  begin
    color4.r := color4.r * _displayedOpacity div 255;
    color4.g := color4.g * _displayedOpacity div 255;
    color4.b := color4.b * _displayedOpacity div 255;
  end;  

  m_sQuad.bl.colors := color4;
  m_sQuad.br.colors := color4;
  m_sQuad.tl.colors := color4;
  m_sQuad.tr.colors := color4;

  if m_pobBatchNode <> nil then
  begin
    if m_uAtlasIndex <> CCSpriteIndexNotInitialized then
    begin
      m_pobTextureAtlas.updateQuad(@m_sQuad, m_uAtlasIndex);
    end else
    begin
      setDirty(True);
    end;  
  end;
end;

procedure CCSprite.setBatchNode(pobSpriteBatchNode: CCSpriteBatchNode);
var
  x1, y1, x2, y2: Single;
begin
  m_pobBatchNode := pobSpriteBatchNode;

  if m_pobBatchNode = nil then
  begin
    m_uAtlasIndex := CCSpriteIndexNotInitialized;
    setTextureAtlas(nil);
    m_bRecursiveDirty := False;
    setDirty(False);

    x1 := m_obOffsetPosition.x;
    y1 := m_obOffsetPosition.y;
    x2 := x1 + m_obRect.size.width;
    y2 := y1 + m_obRect.size.height;

    m_sQuad.bl.vertices := vertex3(x1, y1, 0);
    m_sQuad.br.vertices := vertex3(x2, y1, 0);
    m_sQuad.tl.vertices := vertex3(x1, y2, 0);
    m_sQuad.tr.vertices := vertex3(x2, y2, 0);
  end else
  begin
    m_transformToBatch := CCAffineTransformMakeIdentity();
    setTextureAtlas(m_pobBatchNode.getTextureAtlas());
  end;    
end;

function CCSprite.getTextureAtlas: CCTextureAtlas;
begin
  Result := m_pobTextureAtlas;
end;

procedure CCSprite.setTextureAtlas(pobTextureAtlas: CCTextureAtlas);
begin
  m_pobTextureAtlas := pobTextureAtlas;
end;

function CCSprite.getTextureRect: CCRect;
begin
  Result := m_obRect;
end;

function CCSprite.getBatchNode: CCSpriteBatchNode;
begin
  Result := m_pobBatchNode;
end;

procedure CCSprite.SET_DIRTY_RECURSIVELY;
begin
  if (m_pobBatchNode <> nil) and not m_bRecursiveDirty then
  begin
    m_bRecursiveDirty := True;
    setDirty(True);
    if m_bHasChildren then
      setDirtyRecursively(True);
  end;  
end;

class function CCSprite.createWithSpriteFrame(
  pSpriteFrame: CCSpriteFrame): CCSprite;
var
  pobSprite: CCSprite;
begin
  pobSprite := CCSprite.Create();
  if (pSpriteFrame <> nil) and (pobSprite <> nil) and pobSprite.initWithSpriteFrame(pSpriteFrame) then
  begin
    pobSprite.autorelease();
    Result := pobSprite;
    Exit;
  end;

  CC_SAFE_DELETE(pobSprite);
  Result := nil;
end;

function CCSprite.initWithSpriteFrame(
  pSpriteFrame: CCSpriteFrame): Boolean;
var
  bRet: Boolean;
begin
  CCAssert(pSpriteFrame <> nil, '');

  bRet := initWithTexture(pSpriteFrame.getTexture(), pSpriteFrame.getRect());
  setDisplayFrame(pSpriteFrame);

  Result := bRet;
end;

function CCSprite.displayFrame: CCSpriteFrame;
begin
  Result := CCSpriteFrame.createWithTexture(m_pobTexture,
    CC_RECT_POINTS_TO_PIXELS(m_obRect),
    m_bRectRotated,
    CC_POINT_POINTS_TO_PIXELS(m_obUnflippedOffsetPositionFromCenter),
    CC_SIZE_POINTS_TO_PIXELS(m_obContentSize));
end;

function CCSprite.isFrameDisplayed(pFrame: CCSpriteFrame): Boolean;
var
  r: CCRect;
begin
  r := pFrame.getRect();
  Result := (r.equals(m_obRect)) and (pFrame.getTexture().Name = m_pobTexture.Name) and
    (pFrame.getOffset().equal(m_obUnflippedOffsetPositionFromCenter));
end;

procedure CCSprite.setDisplayFrame(pNewFrame: CCSpriteFrame);
var
  pNewTexture: CCTexture2D;
begin
  m_obUnflippedOffsetPositionFromCenter := pNewFrame.getOffset();

  pNewTexture := pNewFrame.getTexture();
  if pNewTexture <> m_pobTexture then
  begin
    setTexture(pNewTexture);
  end;  

  m_bRectRotated := pNewFrame.isRotated();
  setTextureRect(pNewFrame.getRect(), m_bRectRotated, pNewFrame.getOriginalSize());
end;

procedure CCSprite.setRotationX(const fRotationX: Single);
begin
  inherited setRotationX(fRotationX);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.setRotationY(const fRotationY: Single);
begin
  inherited setRotationY(fRotationY);
  SET_DIRTY_RECURSIVELY();
end;

procedure CCSprite.updateDisplayedColor(const color: ccColor3B);
begin
  inherited updateDisplayedColor(color);
  updateColor();
end;

procedure CCSprite.updateDisplayedOpacity(opacity: GLubyte);
begin
  inherited updateDisplayedOpacity(opacity);
  updateColor();
end;

procedure CCSprite.setColor(const color: ccColor3B);
begin
  inherited setColor(color);
  updateColor();
end;

end.
