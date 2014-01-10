(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009-2010 Ricardo Quesada
Copyright (C) 2009      Matt Oswald
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

unit Cocos2dx.CCSpriteBatchNode;

interface

{$I config.inc}

uses
  Cocos2dx.CCObject, Cocos2dx.CCNode, Cocos2dx.CCTypes, Cocos2dx.CCTexture2D,
  Cocos2dx.CCTextureAtlas, Cocos2dx.CCArray;

const kDefaultSpriteBatchCapacity = 29;

type
  (** CCSpriteBatchNode is like a batch node: if it contains children, it will draw them in 1 single OpenGL call
    * (often known as "batch draw").
    *
    * A CCSpriteBatchNode can reference one and only one texture (one image file, one texture atlas).
    * Only the CCSprites that are contained in that texture can be added to the CCSpriteBatchNode.
    * All CCSprites added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call.
    * If the CCSprites are not added to a CCSpriteBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient.
    *
    *
    * Limitations:
    *  - The only object that is accepted as child (or grandchild, grand-grandchild, etc...) is CCSprite or any subclass of CCSprite. eg: particles, labels and layer can't be added to a CCSpriteBatchNode.
    *  - Either all its children are Aliased or Antialiased. It can't be a mix. This is because "alias" is a property of the texture, and all the sprites share the same texture.
    *
    * @since v0.7.1
    *)
  CCSpriteBatchNode = class(CCNode{, CCTextureProtocol})
  protected
    m_pobTextureAtlas: CCTextureAtlas;
    m_pobDescendants: CCArray;
    m_blendFunc: ccBlendFunc;
    procedure updateAtlasIndex(sprite: CCNode{CCSprite}; curIndex: PInteger);
    procedure swap(oldIndex, newIndex: Integer);
    procedure updateBlendFunc();

    (** Inserts a quad at a certain index into the texture atlas. The CCSprite won't be added into the children array.
     This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
     For example: a tile map (CCTMXMap) or a label with lots of characters (CCLabelBMFont)
     *)
    procedure insertQuadFromSprite(sprite: CCNode{CCSprite}; index: Cardinal);

    (* This is the opposite of "addQuadFromSprite.
    It add the sprite to the children and descendants array, but it doesn't update add it to the texture atlas
    *)
    function addSpriteWithoutQuad(child: CCNode{CCSprite}; z: Cardinal; aTag: Integer): CCSpriteBatchNode;

    (** Updates a quad at a certain index into the texture atlas. The CCSprite won't be added into the children array.
     This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
     For example: a tile map (CCTMXMap) or a label with lots of characters (CCLabelBMFont)
     *)
    procedure updateQuadFromSprite(sprite: CCNode; index: Cardinal);
  public
    destructor Destroy(); override;
    class function createWithTexture(tex: CCTexture2D; capacity: Cardinal): CCSpriteBatchNode; overload;
    class function createWithTexture(tex: CCTexture2D): CCSpriteBatchNode; overload;
    class function _create(const fileImage: string; capacity: Cardinal): CCSpriteBatchNode; overload;
    class function _create(const fileImage: string): CCSpriteBatchNode; overload;

    (** initializes a CCSpriteBatchNode with a texture2d and capacity of children.
    The capacity will be increased in 33% in runtime if it run out of space.
    *)
    function initWithTexture(tex: CCTexture2D; capacity: Cardinal): Boolean;

    (** initializes a CCSpriteBatchNode with a file image (.png, .jpeg, .pvr, etc) and a capacity of children.
    The capacity will be increased in 33% in runtime if it run out of space.
    The file will be loaded using the TextureMgr.
    *)
    function initWithFile(const fileImage: string; capacity: Cardinal): Boolean;
    function init(): Boolean; override;
    procedure increaseAtlasCapacity();

    (** removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
    @warning Removing a child from a CCSpriteBatchNode is very slow
    *)
    procedure removeChildAtIndex(index: Cardinal; doCleanup: Boolean);
    procedure insertChild(child: CCNode{CCSprite}; index: Cardinal);
    procedure appendChild(sprite: CCNode{CCSprite});
    procedure removeSpriteFromAtlas(sprite: CCNode{CCSprite});
    function rebuildIndexInOrder(parent: CCNode{CCSprite}; index: Cardinal): Cardinal;
    function highestAtlasIndexInChild(sprite: CCNode{CCSprite}): Cardinal;
    function lowestAtlasIndexInChild(sprite: CCNode{CCSprite}): Cardinal;
    function atlasIndexForChild(sprite: CCNode{CCSprite}; z: Integer): Cardinal;
    procedure reorderBatch(reorder: Boolean);

    function getTextureAtlas(): CCTextureAtlas;
    procedure setTextureAtlas(textureAtlas: CCTextureAtlas);
    function getDescendants(): CCArray;

    procedure visit(); override;
    procedure addChild(child: CCNode); overload; override;
    procedure addChild(child: CCNode; zOrder: Integer); overload; override;
    procedure addChild(child: CCNode; zOrder: Integer; tag: Integer); overload; override;
    procedure reorderChild(child: CCNode; zOrder: Integer); override;
    procedure removeChild(child: CCNode; cleanup: Boolean); override;
    procedure removeAllChildrenWithCleanup(cleanup: Boolean); override;
    procedure sortAllChildren(); override;
    procedure draw(); override;
  public
    //interface
    procedure setBlendFunc(blendFunc: ccBlendFunc); override;
    function getBlendFunc(): ccBlendFunc; override;

    function getTexture(): CCTexture2D; override;
    procedure setTexture(texture: CCTexture2D); override;
  end;

implementation
uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCMacros, Cocos2dx.CCShaderCache,
  Cocos2dx.CCGLProgram, Cocos2dx.CCTextureCache, matrix, Cocos2dx.CCSprite,
  Cocos2dx.cCCArray, Cocos2dx.CCGLStateCache, Cocos2dx.CCCommon;

{ CCSpriteBatchNode }

class function CCSpriteBatchNode.createWithTexture(tex: CCTexture2D;
  capacity: Cardinal): CCSpriteBatchNode;
var
  batchNode: CCSpriteBatchNode;
begin
  batchNode := CCSpriteBatchNode.Create();
  batchNode.initWithTexture(tex, capacity);
  batchNode.autorelease();
  Result := batchNode;
end;

procedure CCSpriteBatchNode.addChild(child: CCNode);
begin
  inherited addChild(child);
end;

procedure CCSpriteBatchNode.addChild(child: CCNode; zOrder: Integer);
begin
  inherited addChild(child, zOrder);
end;

procedure CCSpriteBatchNode.addChild(child: CCNode; zOrder, tag: Integer);
var
  pSprite: CCSprite;
begin
  CCAssert(child <> nil, 'child should not be null');
  CCAssert(child is CCSprite , 'CCSpriteBatchNode only supports CCSprites as children');
  pSprite := CCSprite(child);
  CCAssert(pSprite.getTexture().Name = m_pobTextureAtlas.Texture.Name, 'CCSprite is not using the same texture id');

  inherited addChild(child, zOrder, tag);
  appendChild(child);
end;

procedure CCSpriteBatchNode.insertQuadFromSprite(sprite: CCNode{CCSprite};
  index: Cardinal);
var
  pSprite: CCSprite;
  quad: ccV3F_C4B_T2F_Quad;
begin
  CCAssert( sprite <> nil, 'Argument must be non-NULL');
  CCAssert( sprite is CCSprite, 'CCSpriteBatchNode only supports CCSprites as children');

  while (index >= m_pobTextureAtlas.Capacity) or (m_pobTextureAtlas.Capacity = m_pobTextureAtlas.TotalQuads) do
  begin
    Self.increaseAtlasCapacity();
  end;

  pSprite := CCSprite(sprite);
  pSprite.setBatchNode(Self);
  pSprite.setAtlasIndex(index);

  quad := pSprite.getQuad();
  m_pobTextureAtlas.insertQuad(@quad, index);

  pSprite.setDirty(True);
  pSprite.updateTransform();
end;

function CCSpriteBatchNode.addSpriteWithoutQuad(child: CCNode{CCSprite};
  z: Cardinal; aTag: Integer): CCSpriteBatchNode;
var
  pSprite, pChild: CCSprite;
  i, j: Cardinal;
begin
  CCAssert( child <> nil, 'Argument must be non-NULL');
  CCAssert( child is CCSprite, 'CCSpriteBatchNode only supports CCSprites as children');

  pSprite := CCSprite(child);
  pSprite.setAtlasIndex(z);

  i := 0;

  if (m_pobDescendants <> nil) and (m_pobDescendants.count() > 0) then
  begin
    for j := 0 to m_pobDescendants.count()-1 do
    begin
      pChild := CCSprite(m_pobDescendants.objectAtIndex(j));
      if (pChild <> nil) and (pChild.getAtlasIndex() >= z) then
        Inc(i);
    end;  
  end;

  m_pobDescendants.insertObject(child, i);
  inherited addChild(child, z, aTag);
  reorderBatch(False);

  Result := Self;
end;

procedure CCSpriteBatchNode.appendChild(sprite: CCNode{CCSprite});
var
  pSprite, child: CCSprite;
  descendantsData: p_ccArray;
  index, i: Cardinal;
  quad: ccV3F_C4B_T2F_Quad;
  pArray: CCArray;
begin
  m_bReorderChildDirty := True;
  pSprite := CCSprite(sprite);
  pSprite.setBatchNode(Self);
  pSprite.setDirty(True);

  if m_pobTextureAtlas.TotalQuads = m_pobTextureAtlas.Capacity then
  begin
    increaseAtlasCapacity();
  end;

  descendantsData := m_pobDescendants.data;
  ccArrayAppendObjectWithResize(descendantsData, pSprite);

  index := descendantsData.num-1;

  pSprite.setAtlasIndex(index);

  quad := pSprite.getQuad;
  m_pobTextureAtlas.insertQuad(@quad, index);

  pArray := pSprite.Children;
  if (pArray <> nil) and (pArray.count() > 0) then
  begin
    for i := 0 to pArray.count()-1 do
    begin
      child := CCSprite(pArray.objectAtIndex(i));
      appendChild(child);
    end;  
  end;
end;

function CCSpriteBatchNode.atlasIndexForChild(sprite: CCNode{CCSprite};
  z: Integer): Cardinal;
var
  pBrothers: CCArray;
  uChildIndex: Cardinal;
  bIgnoreParent: Boolean;
  pPrevious, p: CCSprite;
begin
  pBrothers := sprite.Parent.Children;
  uChildIndex := pBrothers.indexOfObject(sprite);
  bIgnoreParent := sprite.Parent = Self;
  pPrevious := nil;

  if (uChildIndex > 0) and (uChildIndex < $FFFFFFFF) then
  begin
    pPrevious := CCSprite(pBrothers.objectAtIndex(uChildIndex-1));
  end;

  if bIgnoreParent then
  begin
    if uChildIndex = 0 then
    begin
      Result := 0;
      Exit;
    end;

    Result := highestAtlasIndexInChild(pPrevious) + 1;
    Exit;
  end;

  if uChildIndex = 0 then
  begin
    p := CCSprite(sprite.Parent);
    if z < 0 then
    begin
      Result := p.getAtlasIndex();
      Exit;
    end else
    begin
      Result := p.getAtlasIndex() + 1;
      Exit;
    end;    
  end else
  begin
    if ( (pPrevious.ZOrder < 0) and (z < 0) ) or ( (pPrevious.ZOrder >= 0) and (z >= 0) ) then
    begin
      Result := highestAtlasIndexInChild(pPrevious) + 1;
      Exit;
    end;

    p := CCSprite(sprite.Parent);
    Result := p.getAtlasIndex() + 1;
    Exit;
  end;
  
  CCAssert(False, 'should not run here');
  Result := 0;
end;

class function CCSpriteBatchNode.createWithTexture(
  tex: CCTexture2D): CCSpriteBatchNode;
begin
  Result := createWithTexture(tex, kDefaultSpriteBatchCapacity);
end;

destructor CCSpriteBatchNode.Destroy;
begin
  CC_SAFE_RELEASE(m_pobTextureAtlas);
  CC_SAFE_RELEASE(m_pobDescendants);
  inherited;
end;

procedure CCSpriteBatchNode.draw;
var
  pSprite: CCSprite;
  i: Integer;
begin
  if m_pobTextureAtlas.TotalQuads = 0 then
    Exit;

  CC_NODE_DRAW_SETUP();

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pSprite := CCSprite(m_pChildren.objectAtIndex(i));
      pSprite.updateTransform();
    end;
  end;

  ccGLBlendFunc(m_blendFunc.src, m_blendFunc.dst);

  m_pobTextureAtlas.drawQuads();
end;

function CCSpriteBatchNode.getBlendFunc: ccBlendFunc;
begin
  Result := m_blendFunc;
end;

function CCSpriteBatchNode.getDescendants: CCArray;
begin
  Result := m_pobDescendants;
end;

function CCSpriteBatchNode.getTexture: CCTexture2D;
begin
  Result := m_pobTextureAtlas.Texture;
end;

function CCSpriteBatchNode.getTextureAtlas: CCTextureAtlas;
begin
  Result := m_pobTextureAtlas;
end;

function CCSpriteBatchNode.highestAtlasIndexInChild(
  sprite: CCNode{CCSprite}): Cardinal;
var
  pChildren: CCArray;
begin
  pChildren := sprite.Children;
  if (pChildren = nil) or (pChildren.count() = 0) then
  begin
    Result := CCSprite(sprite).getAtlasIndex();
  end else
  begin
    Result := highestAtlasIndexInChild(CCNode(pChildren.lastObject()));
  end;    
end;

procedure CCSpriteBatchNode.increaseAtlasCapacity;
var
  quantity: Cardinal;
begin
  quantity := Round((m_pobTextureAtlas.Capacity + 1) * 4 / 3);
  CCLOG('cocos2d: CCSpriteBatchNode: resizing TextureAtlas capacity from [%d] to [%d].',
        [m_pobTextureAtlas.Capacity, quantity]);
  if not m_pobTextureAtlas.resizeCapacity(quantity) then
  begin
    // serious problems
    //CCLOGWARN("cocos2d: WARNING: Not enough memory to resize the atlas");
    CCAssert(false, 'Not enough memory to resize the atlas');
  end;  
end;

function CCSpriteBatchNode.init: Boolean;
var
  texture: CCTexture2D;
begin
  texture := CCTexture2D.Create();
  texture.autorelease();
  Result := Self.initWithTexture(texture, 0);
end;

function CCSpriteBatchNode.initWithFile(const fileImage: string;
  capacity: Cardinal): Boolean;
var
  pTexture2D: CCTexture2D;
begin
  pTexture2D := CCTextureCache.sharedTextureCache().addImage(fileImage);
  Result := Self.initWithTexture(pTexture2D, capacity);
end;

function CCSpriteBatchNode.initWithTexture(tex: CCTexture2D;
  capacity: Cardinal): Boolean;
begin
  m_blendFunc.src := CC_BLEND_SRC;
  m_blendFunc.dst := CC_BLEND_DST;
  m_pobTextureAtlas := CCTextureAtlas.Create();

  if capacity = 0 then
  begin
    capacity := kDefaultSpriteBatchCapacity;
  end;

  m_pobTextureAtlas.initWithTexture(tex, capacity);

  updateBlendFunc();

  m_pChildren := CCArray.Create();
  m_pChildren.initWithCapacity(capacity);

  m_pobDescendants := CCArray.Create();
  m_pobDescendants.initWithCapacity(capacity);

  Self.ShaderProgram := CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColor);

  Result := True;
end;

procedure CCSpriteBatchNode.insertChild(child: CCNode{CCSprite}; index: Cardinal);
var
  pSprite, pChild: CCSprite;
  quad: ccV3F_C4B_T2F_Quad;
  descendantsData: p_ccArray;
  i, idx: Cardinal;
  pArray: CCArray;
begin
  pSprite := CCSprite(child);
  pSprite.setBatchNode(Self);
  pSprite.setAtlasIndex(index);
  pSprite.setDirty(True);

  if m_pobTextureAtlas.TotalQuads = m_pobTextureAtlas.Capacity then
  begin
    increaseAtlasCapacity();
  end;

  quad := pSprite.getQuad();
  m_pobTextureAtlas.insertQuad(@quad, index);

  descendantsData := m_pobDescendants.data;

  ccArrayInsertObjectAtIndex(descendantsData, pSprite, index);

  i := index + 1;
  while i < descendantsData^.num do
  begin
    pChild := CCSprite(descendantsData^.arr[i]);
    pChild.setAtlasIndex(pChild.getAtlasIndex() + 1);
  end;

  pArray := pSprite.Children;
  if (pArray <> nil) and (pArray.count() > 0) then
  begin
    for i := 0 to pArray.count()-1 do
    begin
      pChild := CCSprite(pArray.objectAtIndex(i));
      idx := atlasIndexForChild(pChild, pChild.ZOrder);
      insertChild(pChild, idx);
    end;  
  end;
end;

function CCSpriteBatchNode.lowestAtlasIndexInChild(
  sprite: CCNode{CCSprite}): Cardinal;
var
  pChildren: CCArray;
begin
  pChildren := sprite.Children;
  if (pChildren = nil) or (pChildren.count() = 0) then
  begin
    Result := CCSprite(sprite).getAtlasIndex();
  end else
  begin
    Result := lowestAtlasIndexInChild(CCNode(pChildren.objectAtIndex(0)));
  end;  
end;

function CCSpriteBatchNode.rebuildIndexInOrder(parent: CCNode{CCSprite};
  index: Cardinal): Cardinal;
var
  pChildren: CCArray;
  pChild: CCSprite;
  i: Integer;
begin
  pChildren := parent.Children;
  if (pChildren <> nil) and (pChildren.count() > 0) then
  begin
    for i := 0 to pChildren.count()-1 do
    begin
      pChild := CCSprite(pChildren.objectAtIndex(i));
      if (pChild <> nil) and (pChild.ZOrder < 0) then
      begin
        index := rebuildIndexInOrder(pChild, index);
      end;
    end;
  end;

  if not parent.isEqual(Self) then
  begin
    CCSprite(parent).setAtlasIndex(index);
    Inc(index);
  end;

  if (pChildren <> nil) and (pChildren.count() > 0) then
  begin
    for i := 0 to pChildren.count()-1 do
    begin
      pChild := CCSprite(pChildren.objectAtIndex(i));
      if (pChild <> nil) and (pChild.ZOrder >= 0) then
      begin
        index := rebuildIndexInOrder(pChild, index);
      end;
    end;
  end;

  Result := index;
end;

procedure CCSpriteBatchNode.removeAllChildrenWithCleanup(cleanup: Boolean);
var
  i: Integer;
  pSprite: CCSprite;
begin
  if (m_pChildren <> nil) and (m_pChildren.count > 0) then
  begin
    for i := 0 to m_pChildren.count-1 do
    begin
      pSprite := CCSprite(m_pChildren.objectAtIndex(i));
      if pSprite <> nil then
      begin
        pSprite.setBatchNode(nil);
      end;  
    end;
  end;

  inherited removeAllChildrenWithCleanup(cleanup);

  m_pobDescendants.removeAllObjects();
  m_pobTextureAtlas.removeAllQuads();
end;

procedure CCSpriteBatchNode.removeChild(child: CCNode; cleanup: Boolean);
begin
  if child = nil then
    Exit;

  CCAssert(m_pChildren.containsObject(child), 'sprite batch node should contain the child');

  removeSpriteFromAtlas(child);

  inherited removeChild(child, cleanup);

end;

procedure CCSpriteBatchNode.removeChildAtIndex(index: Cardinal;
  doCleanup: Boolean);
begin
  removeChild(CCNode(m_pChildren.objectAtIndex(index)), doCleanup);
end;

procedure CCSpriteBatchNode.removeSpriteFromAtlas(sprite: CCNode{CCSprite});
var
  uIndex, count, i: Cardinal;
  pSprite, s, pChild: CCSprite;
  pChildren: CCArray;
begin
  pSprite := CCSprite(sprite);
  m_pobTextureAtlas.removeQuadAtIndex(pSprite.getAtlasIndex());
  pSprite.setBatchNode(nil);

  uIndex := m_pobDescendants.indexOfObject(sprite);
  if uIndex <> $FFFFFFFF then
  begin
    m_pobDescendants.removeObjectAtIndex(uIndex);

    count := m_pobDescendants.count();
    while uIndex < count do
    begin
      s := CCSprite(m_pobDescendants.objectAtIndex(uIndex));
      s.setAtlasIndex(s.getAtlasIndex()-1);
      Inc(uIndex);
    end;  
  end;

  pChildren := pSprite.Children;
  if (pChildren <> nil) and (pChildren.count() > 0) then
  begin
    for i := 0 to pChildren.count()-1 do
    begin
      pChild := CCSprite(pChildren.objectAtIndex(i));
      if pChild <> nil then
        removeSpriteFromAtlas(pChild);
    end;
  end;  
end;

procedure CCSpriteBatchNode.reorderBatch(reorder: Boolean);
begin
  m_bReorderChildDirty := reorder;
end;

procedure CCSpriteBatchNode.reorderChild(child: CCNode; zOrder: Integer);
begin
  CCAssert(child <> nil, 'the child should not be null');
  CCAssert(m_pChildren.containsObject(child), 'Child does not belong to Sprite');

  if zOrder = child.ZOrder then
    Exit;

  inherited reorderChild(child, zOrder);
end;

procedure CCSpriteBatchNode.setBlendFunc(blendFunc: ccBlendFunc);
begin
  m_blendFunc := blendFunc;
end;

procedure CCSpriteBatchNode.setTexture(texture: CCTexture2D);
begin
  m_pobTextureAtlas.Texture := texture;
  updateBlendFunc();
end;

procedure CCSpriteBatchNode.setTextureAtlas(textureAtlas: CCTextureAtlas);
begin
  if textureAtlas <> m_pobTextureAtlas then
  begin
    CC_SAFE_RETAIN(textureAtlas);
    CC_SAFE_RELEASE(m_pobTextureAtlas);
    m_pobTextureAtlas := textureAtlas;
  end;  
end;

class function CCSpriteBatchNode._create(const fileImage: string;
  capacity: Cardinal): CCSpriteBatchNode;
var
  batchNode: CCSpriteBatchNode;
begin
  batchNode := CCSpriteBatchNode.Create();
  batchNode.initWithFile(fileImage, capacity);
  batchNode.autorelease();

  Result := batchNode;
end;

procedure CCSpriteBatchNode.sortAllChildren;
var
  i, j, len, index: Integer;
  x: PCCObectAry;
  tempItem, jNode: CCNode;
  pSprite: CCSprite;
begin
  if m_bReorderChildDirty then
  begin
    len := m_pChildren.data.num;
    x := m_pChildren.data.arr;

    for i := 1 to len-1 do
    begin
      tempItem := CCNode(x[i]);
      j := i - 1;
      jNode := CCNode(x[j]);

      while (j >= 0) and ( (tempItem.ZOrder < jNode.ZOrder) or  ( (tempItem.ZOrder = jNode.ZOrder)  and (tempItem.OrderOfArrival < jNode.OrderOfArrival) ) ) do
      begin
        x[j+1] := x[j];
        Dec(j);

        if j >= 0 then
          jNode := CCNode(x[j]);
      end;

      x[j+1] := tempItem;
    end;

    if m_pChildren.count() > 0 then
    begin
      for i := 0 to m_pChildren.count()-1 do
      begin
        pSprite := CCSprite(m_pChildren.objectAtIndex(i));
        if pSprite = nil then
          Continue;

        pSprite.sortAllChildren();
      end;

      index := 0;
      for i := 0 to m_pChildren.count()-1 do
      begin
        pSprite := CCSprite(m_pChildren.objectAtIndex(i));
        if pSprite = nil then
          Continue;

        updateAtlasIndex(pSprite, @index);
      end;
    end;
    m_bReorderChildDirty := False;
  end;
end;

procedure CCSpriteBatchNode.swap(oldIndex, newIndex: Integer);
var
  x: PCCObectAry;
  quads: pccV3F_C4B_T2F_Quad;
  tempItem: CCObject;
  tempItemQuad: ccV3F_C4B_T2F_Quad;
begin
  x := m_pobDescendants.data.arr;
  quads := m_pobTextureAtlas.Quads;

  tempItem := x[oldIndex];
  tempItemQuad := ptccV3F_C4B_T2F_Quad(quads)[oldIndex];

  CCSprite(x[newIndex]).setAtlasIndex(oldIndex);

  x[oldIndex] := x[newIndex];
  ptccV3F_C4B_T2F_Quad(quads)[oldIndex] := ptccV3F_C4B_T2F_Quad(quads)[newIndex];
  x[newIndex] := tempItem;
  ptccV3F_C4B_T2F_Quad(quads)[newIndex] := tempItemQuad;
end;

procedure CCSpriteBatchNode.updateAtlasIndex(sprite: CCNode{CCSprite};
  curIndex: PInteger);
var
  count: Cardinal;
  pArray: CCArray;
  oldIndex, i: Integer;
  pSprite, child: CCSprite;
  needNewIndex: Boolean;
begin
  pSprite := CCSprite(sprite);
  pArray := pSprite.Children;

  count := 0;
  if pArray <> nil then
  begin
    count := pArray.count();
  end;

  if count = 0 then
  begin
    oldIndex := pSprite.getAtlasIndex();
    pSprite.setAtlasIndex(curIndex^);
    pSprite.OrderOfArrival := 0;
    if oldIndex <> curIndex^ then
    begin
      swap(oldIndex, curIndex^);
    end;
    Inc(curIndex^);
  end else
  begin
    needNewIndex := True;

    if CCSprite(pArray.data.arr[0]).ZOrder >= 0 then
    begin
      oldIndex := pSprite.getAtlasIndex();
      pSprite.setAtlasIndex(curIndex^);
      pSprite.OrderOfArrival := 0;
      if oldIndex <> curIndex^ then
      begin
        swap(oldIndex, curIndex^);
      end;
      Inc(curIndex^);
      needNewIndex := False;
    end;

    if (pArray <> nil) and (pArray.count() > 0) then
    begin
      for i := 0 to pArray.count()-1 do
      begin
        child := CCSprite(pArray.objectAtIndex(i));

        if needNewIndex and (child.ZOrder >= 0) then
        begin
          oldIndex := pSprite.getAtlasIndex();
          pSprite.setAtlasIndex(curIndex^);
          pSprite.OrderOfArrival := 0;
          if oldIndex <> curIndex^ then
          begin
            Self.swap(oldIndex, curIndex^);
          end;
          Inc(curIndex^);
          needNewIndex := False;
        end;
        updateAtlasIndex(child, curIndex);
      end;
    end;

    if needNewIndex then
    begin
      oldIndex := pSprite.getAtlasIndex();
      pSprite.setAtlasIndex(curIndex^);
      pSprite.OrderOfArrival := 0;
      if oldIndex <> curIndex^ then
      begin
        swap(oldIndex, curIndex^);
      end;
      Inc(curIndex^);
    end;
  end;
end;

procedure CCSpriteBatchNode.updateBlendFunc;
begin
  if not m_pobTextureAtlas.Texture.hasPremultipliedAlpha() then
  begin
    m_blendFunc.src := GL_SRC_ALPHA;
    m_blendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
  end;  
end;

procedure CCSpriteBatchNode.visit;
begin
  if not m_bVisible then
    Exit;

  kmGLPushMatrix();

  //m_pGrid

  sortAllChildren();
  transform();

  draw();
  //
  kmGLPopMatrix();

  OrderOfArrival := 0;
end;

class function CCSpriteBatchNode._create(
  const fileImage: string): CCSpriteBatchNode;
begin
  Result := _create(fileImage, kDefaultSpriteBatchCapacity);
end;

procedure CCSpriteBatchNode.updateQuadFromSprite(sprite: CCNode;
  index: Cardinal);
begin
  while (index >= m_pobTextureAtlas.getCapacity()) or
    (m_pobTextureAtlas.getCapacity() = m_pobTextureAtlas.getTotalQuads()) do
  begin
    increaseAtlasCapacity();
  end;

  CCSprite(sprite).setBatchNode(Self);
  CCSprite(sprite).setAtlasIndex(index);
  CCSprite(sprite).setDirty(True);
  CCSprite(sprite).updateTransform();
end;

end.
