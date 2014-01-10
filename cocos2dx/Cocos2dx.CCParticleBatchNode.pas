(*
 * Copyright (c) 2010-2012 cocos2d-x.org
 * Copyright (C) 2009 Matt Oswald
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2011 Marco Tillemans
 *
 * http://www.cocos2d-x.org
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *)

unit Cocos2dx.CCParticleBatchNode;

interface

{$I config.inc}

uses
  Cocos2dx.CCObject, Cocos2dx.CCNode, Cocos2dx.CCTexture2D, Cocos2dx.CCTextureAtlas,
  Cocos2dx.CCTypes, Cocos2dx.CCParticleSystem;

const kCCParticleDefaultCapacity = 500;

type
  (** CCParticleBatchNode is like a batch node: if it contains children, it will draw them in 1 single OpenGL call
   * (often known as "batch draw").
   *
   * A CCParticleBatchNode can reference one and only one texture (one image file, one texture atlas).
   * Only the CCParticleSystems that are contained in that texture can be added to the CCSpriteBatchNode.
   * All CCParticleSystems added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call.
   * If the CCParticleSystems are not added to a CCParticleBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient.
   *
   *
   * Limitations:
   * - At the moment only CCParticleSystemQuad is supported
   * - All systems need to be drawn with the same parameters, blend function, aliasing, texture
   *
   * Most efficient usage
   * - Initialize the ParticleBatchNode with the texture and enough capacity for all the particle systems
   * - Initialize all particle systems and add them as child to the batch node
   * @since v1.1
   *)
  CCParticleBatchNode = class(CCNode)
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(const fileImage: string; capacity: Cardinal = kCCParticleDefaultCapacity): CCParticleBatchNode;
    class function createWithTexture(tex: CCTexture2D; capacity: Cardinal = kCCParticleDefaultCapacity): CCParticleBatchNode;
    function initWithTexture(tex: CCTexture2D; capacity: Cardinal): Boolean;
    function initWithFile(const fileImage: string; capacity: Cardinal): Boolean;

    //override
    procedure addChild(child: CCNode); overload; override;
    procedure addChild(child: CCNode; zOrder: Integer); overload; override;
    procedure addChild(child: CCNode; zOrder: Integer; tag: Integer); overload; override;
    procedure removeChild(child: CCNode; cleanup: Boolean); override;
    procedure reorderChild(child: CCNode; zOrder: Integer); override;
    procedure removeAllChildrenWithCleanup(cleanup: Boolean); override;
    procedure draw(); override;
    procedure visit(); override;

    //interface
    function getTexture(): CCTexture2D; override;
    procedure setTexture(texture: CCTexture2D); override;
    procedure setBlendFunc(blendFunc: ccBlendFunc); override;
    function getBlendFunc(): ccBlendFunc; override;

    procedure insertChild(pSystem: CCParticleSystem; index: Cardinal);
    procedure removeChildAtIndex(index: Cardinal; doCleanup: Boolean);
    procedure disableParticle(particleIndex: Cardinal);
    function getTextureAtlas(): CCTextureAtlas;
    procedure setTextureAtlas(pValue: CCTextureAtlas);
  private
    procedure updateAllAtlasIndexes();
    procedure increaseAtlasCapacityTo(quantity: Cardinal);
    function searchNewPositionInChildrenForZ(z: Integer): Cardinal;
    procedure getCurrentIndex(var oldIndex, newIndex: Integer; child: CCNode; z: Integer);
    function addChildHelper(child: CCParticleSystem; z: Integer; aTag: Integer): Cardinal;
    //procedure updateBlendFunc();
  private
    m_tBlendFunc: ccBlendFunc;
    m_pTextureAtlas: CCTextureAtlas;
  end;

implementation
uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCArray, Cocos2dx.CCCommon, Cocos2dx.CCMacros,
  Cocos2dx.CCShaderCache, Cocos2dx.CCGLProgram, Cocos2dx.CCGLStateCache,
  Cocos2dx.CCTextureCache, matrix;

{ CCParticleBatchNode }

class function CCParticleBatchNode._create(const fileImage: string;
  capacity: Cardinal): CCParticleBatchNode;
var
  pRet: CCParticleBatchNode;
begin
  pRet := CCParticleBatchNode.Create();
  if (pRet <> nil) and pRet.initWithFile(fileImage, capacity) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCParticleBatchNode.addChild(child: CCNode; zOrder: Integer);
begin
  inherited addChild(child, zOrder);
end;

procedure CCParticleBatchNode.addChild(child: CCNode);
begin
  inherited addChild(child);
end;

procedure CCParticleBatchNode.addChild(child: CCNode; zOrder,
  tag: Integer);
var
  pChild, p: CCParticleSystem;
  atlasIndex, pos: Cardinal;
begin
  CCAssert(child <> nil, 'Argument must be non-NULL');
  CCAssert(child is CCParticleSystem, 'CCParticleBatchNode only supports CCQuadParticleSystems as children');
  pChild := CCParticleSystem(child);
  CCAssert(pChild.getTexture().Name = m_pTextureAtlas.Texture.Name, 'CCParticleSystem is not using the same texture id');

  // If this is the 1st children, then copy blending function
  if m_pChildren.count() = 0 then
  begin
    setBlendFunc(pChild.getBlendFunc());
  end;

  CCAssert((m_tBlendFunc.src = pChild.getBlendFunc().src) and (m_tBlendFunc.dst = pChild.getBlendFunc().dst), 'Can not add a PaticleSystem that uses a different blending function');

  //no lazy sorting, so don't call super addChild, call helper instead
  pos := addChildHelper(pChild, zOrder, tag);

  if pos <> 0 then
  begin
    p := CCParticleSystem(m_pChildren.objectAtIndex(pos-1));
    atlasIndex := p.AtlasIndex + p.TotalParticles;
  end else
  begin
    atlasIndex := 0;
  end;

  insertChild(pChild, atlasIndex);

  pChild.BatchNode := Self;
end;

constructor CCParticleBatchNode.Create;
begin
  inherited Create();
  m_pTextureAtlas := nil;
end;

class function CCParticleBatchNode.createWithTexture(tex: CCTexture2D;
  capacity: Cardinal): CCParticleBatchNode;
var
  pRet: CCParticleBatchNode;
begin
  pRet := CCParticleBatchNode.Create();
  if (pRet <> nil) and pRet.initWithTexture(tex, capacity) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCParticleBatchNode.Destroy;
begin
  CC_SAFE_RELEASE(m_pTextureAtlas);
  inherited;
end;

procedure CCParticleBatchNode.disableParticle(particleIndex: Cardinal);
var
  quad: pccV3F_C4B_T2F_Quad;
begin
  quad := @ptccV3F_C4B_T2F_Quad(m_pTextureAtlas.Quads)^[particleIndex];

  quad^.tl.vertices.x := 0;
  quad^.tl.vertices.y := 0;

  quad^.bl.vertices.x := 0;
  quad^.bl.vertices.y := 0;

  quad^.tr.vertices.x := 0;
  quad^.tr.vertices.y := 0;

  quad^.br.vertices.x := 0;
  quad^.br.vertices.y := 0;
end;

procedure CCParticleBatchNode.draw;
begin
  if m_pTextureAtlas.TotalQuads = 0 then
    Exit;
    
  CC_NODE_DRAW_SETUP();
  ccGLBlendFunc(m_tBlendFunc.src, m_tBlendFunc.dst);
  m_pTextureAtlas.drawQuads();
end;

function CCParticleBatchNode.getBlendFunc: ccBlendFunc;
begin
  Result := m_tBlendFunc;
end;

procedure CCParticleBatchNode.getCurrentIndex(var oldIndex, newIndex: Integer;
  child: CCNode; z: Integer);
var
  foundCurrentIdx, foundNewIdx: Boolean;
  minusOne: Integer;
  count: Cardinal;
  i: Cardinal;
  pNode: CCNode;
begin
  foundCurrentIdx := False;
  foundNewIdx := False;
  minusOne := 0;
  
  count := m_pChildren.count();

  if count > 0 then
    for i := 0 to count-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if (pNode.ZOrder > z) and not foundNewIdx then
      begin
        newIndex := i;
        foundNewIdx := True;

        if foundCurrentIdx and foundNewIdx then
          Break;
      end;

      if child = pNode then
      begin
        oldIndex := i;
        foundCurrentIdx := True;

        if not foundNewIdx then
          minusOne := -1;

        if foundCurrentIdx and foundNewIdx then
          Break;
      end;  
    end;

  if not foundNewIdx then
  begin
    newIndex := count;
  end;

  newIndex := newIndex + minusOne;
end;

function CCParticleBatchNode.getTexture: CCTexture2D;
begin
  Result := m_pTextureAtlas.Texture;
end;

function CCParticleBatchNode.getTextureAtlas: CCTextureAtlas;
begin
  Result := m_pTextureAtlas;
end;

procedure CCParticleBatchNode.increaseAtlasCapacityTo(quantity: Cardinal);
begin
  CCLog('cocos2d: CCParticleBatchNode: resizing TextureAtlas capacity from [%d] to [%d].', [m_pTextureAtlas.Capacity, quantity]);

  if not m_pTextureAtlas.resizeCapacity(quantity) then
  begin
    CCLog('cocos2d: WARNING: Not enough memory to resize the atlas', []);
    CCAssert(False, 'XXX: CCParticleBatchNode #increaseAtlasCapacity SHALL handle this assert');
  end;  
end;

function CCParticleBatchNode.initWithFile(const fileImage: string;
  capacity: Cardinal): Boolean;
var
  tex: CCTexture2D;
begin
  tex := CCTextureCache.sharedTextureCache().addImage(fileImage);
  Result := initWithTexture(tex, capacity);
end;

function CCParticleBatchNode.initWithTexture(tex: CCTexture2D;
  capacity: Cardinal): Boolean;
begin
  m_pTextureAtlas := CCTextureAtlas.Create();
  m_pTextureAtlas.initWithTexture(tex, capacity);

  m_pChildren := CCArray.Create();
  m_pChildren.initWithCapacity(capacity);

  m_tBlendFunc.src := CC_BLEND_SRC;
  m_tBlendFunc.dst := CC_BLEND_DST;

  setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColor));

  Result := True;
end;

procedure CCParticleBatchNode.removeAllChildrenWithCleanup(
  cleanup: Boolean);
var
  i: Cardinal;
  p: CCParticleSystem;
begin
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      p := CCParticleSystem(m_pChildren.objectAtIndex(i));
      if p = nil then
        Continue;

      p.BatchNode := nil;
    end;  
  end;  
  inherited removeAllChildrenWithCleanup(cleanup);
  m_pTextureAtlas.removeAllQuads();
end;

procedure CCParticleBatchNode.removeChild(child: CCNode; cleanup: Boolean);
var
  pChild: CCParticleSystem;
begin
  if child = nil then
    Exit;

  CCAssert(child is CCParticleSystem, 'CCParticleBatchNode only supports CCQuadParticleSystems as children');
  CCAssert(m_pChildren.containsObject(child), 'CCParticleBatchNode does not contain the sprite. Cann ot remove it');

  pChild := CCParticleSystem(child);
  inherited removeChild(child, cleanup);

  m_pTextureAtlas.removeQuadAtIndex(pChild.AtlasIndex, pChild.TotalParticles);
  m_pTextureAtlas.fillWithEmptyQuadsFromIndex(m_pTextureAtlas.TotalQuads, pChild.TotalParticles);

  pChild.BatchNode := nil;

  updateAllAtlasIndexes();
end;

procedure CCParticleBatchNode.removeChildAtIndex(index: Cardinal;
  doCleanup: Boolean);
begin
  removeChild(CCNode(m_pChildren.objectAtIndex(index)), doCleanup);
end;

procedure CCParticleBatchNode.reorderChild(child: CCNode; zOrder: Integer);
var
  pChild, pNode: CCParticleSystem;
  newIndex, oldIndex: Integer;
  oldAtlasIndex, newAtlasIndex: Cardinal;
  i: Cardinal;
begin
  CCAssert(child <> nil, 'Child must be non-NULL');
  CCAssert(child is CCParticleSystem, 'CCParticleBatchNode only supports CCQuadParticleSystems as children');
  CCAssert(m_pChildren.containsObject(child), 'Child doesn not belong to batch');

  pChild := CCParticleSystem(child);

  if zOrder = child.ZOrder then
    Exit;

  if m_pChildren.count() > 1 then
  begin
    getCurrentIndex(oldIndex, newIndex, pChild, zOrder);

    if oldIndex <> newIndex then
    begin
      pChild.retain();
      m_pChildren.removeObjectAtIndex(oldIndex);
      m_pChildren.insertObject(pChild, newIndex);
      pChild.release();

      oldAtlasIndex := pChild.AtlasIndex;

      updateAllAtlasIndexes();

      newAtlasIndex := 0;

      if m_pChildren.count() > 0 then
        for  i := 0 to m_pChildren.count()-1 do
        begin
          pNode := CCParticleSystem(m_pChildren.objectAtIndex(i));
          if pNode = pChild then
          begin
            newAtlasIndex := pChild.AtlasIndex;
            Break;
          end;  
        end;

      m_pTextureAtlas.moveQuadsFromIndex(oldAtlasIndex, pChild.TotalParticles, newAtlasIndex);
      pChild.updateWithNoTime();
    end;  
  end;

  pChild._setZOrder(zOrder);
end;

function CCParticleBatchNode.searchNewPositionInChildrenForZ(
  z: Integer): Cardinal;
var
  i, count: Cardinal;
  child: CCNode;
begin
  count := m_pChildren.count();

  if count > 0 then
    for i := 0 to count-1 do
    begin
      child := CCNode(m_pChildren.objectAtIndex(i));
      if child.ZOrder > z then
      begin
        Result := i;
        Exit;
      end;  
    end;

  Result := count;
end;

procedure CCParticleBatchNode.setBlendFunc(blendFunc: ccBlendFunc);
begin
  m_tBlendFunc := blendFunc;
end;

procedure CCParticleBatchNode.setTexture(texture: CCTexture2D);
begin
  m_pTextureAtlas.Texture := texture;

  if (texture <> nil) and (not texture.hasPremultipliedAlpha() ) and ( (m_tBlendFunc.src = CC_BLEND_SRC) and (m_tBlendFunc.dst = CC_BLEND_DST) ) then
  begin
    m_tBlendFunc.src := GL_SRC_ALPHA;
    m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
  end;  
end;

procedure CCParticleBatchNode.setTextureAtlas(pValue: CCTextureAtlas);
begin
  m_pTextureAtlas := pValue;
end;

procedure CCParticleBatchNode.updateAllAtlasIndexes;
var
  pChild: CCParticleSystem;
  index, i: Cardinal;
begin
  index := 0;
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    for i := 0 to m_pChildren.count()-1 do
    begin
      pChild := CCParticleSystem(m_pChildren.objectAtIndex(i));
      if pChild = nil then
        Continue;

      pChild.AtlasIndex := index;

      Inc(index, pChild.TotalParticles);
    end;
end;

{procedure CCParticleBatchNode.updateBlendFunc;
begin
  if not m_pTextureAtlas.Texture.hasPremultipliedAlpha then
  begin
    m_tBlendFunc.src := GL_SRC_ALPHA;
    m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
  end;  
end;}

procedure CCParticleBatchNode.visit;
begin
  // CAREFUL:
  // This visit is almost identical to CCNode#visit
  // with the exception that it doesn't call visit on it's children
  //
  // The alternative is to have a void CCSprite#visit, but
  // although this is less maintainable, is faster
  //
  if not m_bVisible then
    Exit;

  kmGLPushMatrix();

  if (m_pGrid <> nil) and m_pGrid.isActive() then
  begin
    m_pGrid.beforeDraw();
    transformAncestors();
  end;

  transform();

  draw();

  if (m_pGrid <> nil) and m_pGrid.isActive() then
  begin
    m_pGrid.afterDraw(Self);
  end;

  kmGLPopMatrix();
end;

// don't use lazy sorting, reordering the particle systems quads afterwards would be too complex
// XXX research whether lazy sorting + freeing current quads and calloc a new block with size of capacity would be faster
// XXX or possibly using vertexZ for reordering, that would be fastest
// this helper is almost equivalent to CCNode's addChild, but doesn't make use of the lazy sorting
function CCParticleBatchNode.addChildHelper(child: CCParticleSystem; z,
  aTag: Integer): Cardinal;
var
  pos: Cardinal;
begin
  CCAssert(child <> nil, 'Argument must be non-nil');
  CCAssert(child.Parent = nil, 'child already added. It can not be added again');

  if m_pChildren = nil then
  begin
    m_pChildren := CCArray.Create();
    m_pChildren.initWithCapacity(4);
  end;

  pos := searchNewPositionInChildrenForZ(z);

  m_pChildren.insertObject(child, pos);

  child.Tag := aTag;
  child._setZOrder(z);

  child.Parent := Self;

  if m_bRunning then
  begin
    child.onEnter();
    child.onEnterTransitionDidFinish();
  end;

  Result := pos;
end;

procedure CCParticleBatchNode.insertChild(pSystem: CCParticleSystem;
  index: Cardinal);
begin
  pSystem.AtlasIndex := index;

  if m_pTextureAtlas.TotalQuads + pSystem.TotalParticles > m_pTextureAtlas.Capacity then
  begin
    increaseAtlasCapacityTo(m_pTextureAtlas.TotalQuads + pSystem.TotalParticles);
    m_pTextureAtlas.fillWithEmptyQuadsFromIndex(m_pTextureAtlas.Capacity - pSystem.TotalParticles, pSystem.TotalParticles);
  end;

  if pSystem.AtlasIndex + pSystem.TotalParticles <> m_pTextureAtlas.TotalQuads then
  begin
    m_pTextureAtlas.moveQuadsFromIndex(index, index + pSystem.TotalParticles);
  end;

  m_pTextureAtlas.increaseTotalQuadsWith(pSystem.TotalParticles);

  updateAllAtlasIndexes();
end;

end.
