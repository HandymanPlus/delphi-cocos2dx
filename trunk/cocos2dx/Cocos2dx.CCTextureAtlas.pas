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

unit Cocos2dx.CCTextureAtlas;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils, Math,
  Cocos2dx.CCPointerArray, Cocos2dx.CCObject, Cocos2dx.CCTypes, Cocos2dx.CCTexture2D;

type
  (** @brief A class that implements a Texture Atlas.
    Supported features:
    * The atlas file can be a PVRTC, PNG or any other format supported by Texture2D
    * Quads can be updated in runtime
    * Quads can be added in runtime
    * Quads can be removed in runtime
    * Quads can be re-ordered in runtime
    * The TextureAtlas capacity can be increased or decreased in runtime
    * OpenGL component: V3F, C4B, T2F.
    The quads are rendered using an OpenGL ES VBO.
    To render the quads using an interleaved vertex array list, you should modify the ccConfig.h file
    *)
  CCTextureAtlas = class(CCObject)
  private
    procedure setupIndices();
    procedure mapBuffers();
    procedure setupVBO();
  protected
    m_pIndices: PGLushortArray;
    m_pBuffersVBO: array [0..1] of GLuint;
    m_bDirty: Boolean;
    m_uTotalQuads: Cardinal;
    m_uCapacity: Cardinal;
    m_pTexture: CCTexture2D;
    m_pQuads: ptccV3F_C4B_T2F_Quad;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(const filename: string; capacity: Cardinal): CCTextureAtlas;
    function initWithFile(const filename: string; capacity: Cardinal): Boolean;
    class function createWithTexture(texture: CCTexture2D; capacity: Cardinal): CCTextureAtlas;

    (** initializes a TextureAtlas with a previously initialized Texture2D object, and
    * with an initial capacity for Quads.
    * The TextureAtlas capacity can be increased in runtime.
    *
    * WARNING: Do not reinitialize the TextureAtlas because it will leak memory (issue #706)
    *)
    function initWithTexture(texture: CCTexture2D; capacity: Cardinal): Boolean;

    (** updates a Quad (texture, vertex and color) at a certain index
    * index must be between 0 and the atlas capacity - 1
    @since v0.8
    *)
    procedure updateQuad(quad: pccV3F_C4B_T2F_Quad; index: Cardinal);

    (** Inserts a Quad (texture, vertex and color) at a certain index
    index must be between 0 and the atlas capacity - 1
    @since v0.8
    *)
    procedure insertQuad(quad: pccV3F_C4B_T2F_Quad; index: Cardinal); overload;

    (** Inserts a c array of quads at a given index
     index must be between 0 and the atlas capacity - 1
     this method doesn't enlarge the array when amount + index > totalQuads
     @since v1.1
    *)
    procedure insertQuads(quad: pccV3F_C4B_T2F_Quad; index, amount: Cardinal); overload;

    (** Removes the quad that is located at a certain index and inserts it at a new index
    This operation is faster than removing and inserting in a quad in 2 different steps
    @since v0.7.2
    *)
    procedure insertQuadFromIndex(oldIndex, newIndex: Cardinal);

    (** removes a quad at a given index number.
    The capacity remains the same, but the total number of quads to be drawn is reduced in 1
    @since v0.7.2
    *)
    procedure removeQuadAtIndex(index: Cardinal); overload;

    (** removes a amount of quads starting from index
        @since 1.1
     *)
    procedure removeQuadAtIndex(index: Cardinal; amount: Cardinal); overload;

    (** removes all Quads.
    The TextureAtlas capacity remains untouched. No memory is freed.
    The total number of quads to be drawn will be 0
    @since v0.7.2
    *)
    procedure removeAllQuads();

    (** resize the capacity of the CCTextureAtlas.
    * The new capacity can be lower or higher than the current one
    * It returns YES if the resize was successful.
    * If it fails to resize the capacity it will return NO with a new capacity of 0.
    *)
    function resizeCapacity(newCapacity: Cardinal): Boolean;

    (**
     Used internally by CCParticleBatchNode
     don't use this unless you know what you're doing
     @since 1.1
    *)
    procedure increaseTotalQuadsWith(amount: Cardinal);

    (** Moves an amount of quads from oldIndex at newIndex
     @since v1.1
     *)
    procedure moveQuadsFromIndex(oldIndex, amount, newIndex: Cardinal); overload;

    (**
     Moves quads from index till totalQuads to the newIndex
     Used internally by CCParticleBatchNode
     This method doesn't enlarge the array if newIndex + quads to be moved > capacity
     @since 1.1
    *)
    procedure moveQuadsFromIndex(index, newIndex: Cardinal); overload;

    (**
     Ensures that after a realloc quads are still empty
     Used internally by CCParticleBatchNode
     @since 1.1
    *)
    procedure fillWithEmptyQuadsFromIndex(index, amount: Cardinal);

    (** draws n quads
    * n can't be greater than the capacity of the Atlas
    *)
    procedure drawNumberOfQuads(n: Cardinal); overload;

    (** draws n quads from an index (offset).
    n + start can't be greater than the capacity of the atlas

    @since v1.0
    *)
    procedure drawNumberOfQuads(n, start: Cardinal); overload;

    (** draws all the Atlas's Quads
    *)
    procedure drawQuads();
    procedure listenBackToForeground(obj: CCObject);
    function description(): string;
    function getCapacity: Cardinal;
    function getQuads: pccV3F_C4B_T2F_Quad;
    function getTexture: CCTexture2D;
    function getTotalQuads: Cardinal;
    procedure setQuads(const Value: pccV3F_C4B_T2F_Quad);
    procedure setTexture(const Value: CCTexture2D);
    function isDirty(): Boolean;
    procedure setDirty(bDirty: Boolean);
  public
    //** quantity of quads that are going to be drawn */
    property TotalQuads: Cardinal read getTotalQuads;
    //** quantity of quads that can be stored with the current texture atlas size */
    property Capacity: Cardinal read getCapacity;
    //** Texture of the texture atlas */
    property Texture: CCTexture2D read getTexture write setTexture;
    //** Quads that are going to be rendered */
    property Quads: pccV3F_C4B_T2F_Quad read getQuads write setQuads;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCTextureCache, Cocos2dx.CCCommon,
  Cocos2dx.CCGLStateCache, Cocos2dx.CCGLProgram, Cocos2dx.CCString,
  Cocos2dx.CCMacros;

{ CCTextureAtlas }

class function CCTextureAtlas._create(const filename: string;
  capacity: Cardinal): CCTextureAtlas;
var
  pTextureAtlas: CCTextureAtlas;
begin
  pTextureAtlas := CCTextureAtlas.Create;
  if (pTextureAtlas <> nil) and pTextureAtlas.initWithFile(filename, capacity) then
  begin
    pTextureAtlas.autorelease();
    Result := pTextureAtlas;
    Exit;
  end;
  CC_SAFE_DELETE(pTextureAtlas);
  Result := nil;
end;

constructor CCTextureAtlas.Create;
begin
  inherited Create();
end;

class function CCTextureAtlas.createWithTexture(texture: CCTexture2D;
  capacity: Cardinal): CCTextureAtlas;
var
  pTextureAtlas: CCTextureAtlas;
begin
  pTextureAtlas := CCTextureAtlas.Create;
  if (pTextureAtlas <> nil) and pTextureAtlas.initWithTexture(texture, capacity) then
  begin
    pTextureAtlas.autorelease();
    Result := pTextureAtlas;
    Exit;
  end;
  CC_SAFE_DELETE(pTextureAtlas);
  Result := nil;
end;

destructor CCTextureAtlas.Destroy;
begin
  CC_SAFE_FREE_POINTER(m_pQuads);
  CC_SAFE_FREE_POINTER(m_pIndices);
  glDeleteBuffers(2, @m_pBuffersVBO[0]);
  CC_SAFE_RELEASE(m_pTexture);

  inherited;
end;

procedure CCTextureAtlas.drawNumberOfQuads(n: Cardinal);
begin
  Self.drawNumberOfQuads(n, 0);
end;

procedure CCTextureAtlas.drawNumberOfQuads(n, start: Cardinal);
var
  kQuadSize: Cardinal;
  vDiff, tDiff, cDiff: Cardinal;
  offset: GLint;
  size: GLsizei;
begin
  if 0 = n then
    Exit;

  ccGLBindTexture2D(m_pTexture.Name);

  kQuadSize := SizeOf(m_pQuads[0].bl);
  glBindBuffer(GL_ARRAY_BUFFER, m_pBuffersVBO[0]);

  if m_bDirty then
  begin
    offset := SizeOf(ccV3F_C4B_T2F_Quad)*start;
    size := SizeOf(ccV3F_C4B_T2F_Quad) * n;
    {$ifdef IOS}
    glBufferSubData(GL_ARRAY_BUFFER, @offset, @size, @m_pQuads^[start]);
    {$else}
    glBufferSubData(GL_ARRAY_BUFFER, offset, size, @m_pQuads^[start]);
    {$endif}
    m_bDirty := False;
  end;

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);

  get_ccV3F_C4B_T2F_dif(vDiff, cDiff, tDiff);

  glVertexAttribPointer(kCCVertexAttrib_Position,  3, GL_FLOAT, GL_FALSE, kQuadSize, BUFFER_OFFSET(vDiff));
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, BUFFER_OFFSET(tDiff));
  glVertexAttribPointer(kCCVertexAttrib_Color,     4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, BUFFER_OFFSET(cDiff));

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_pBuffersVBO[1]);
  glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, BUFFER_OFFSET(start*6*SizeOf(GLushort)));
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

  CC_INCREMENT_GL_DRAWS(1);
end;

procedure CCTextureAtlas.drawQuads;
begin
  Self.drawNumberOfQuads(m_uTotalQuads, 0);
end;

procedure CCTextureAtlas.fillWithEmptyQuadsFromIndex(index,
  amount: Cardinal);
var
  quad: ccV3F_C4B_T2F_Quad;
  i, _to: Cardinal;
begin
  FillChar(quad, SizeOf(quad), 0);

  _to := index + amount;
  for i := index to _to-1 do
  begin
    m_pQuads^[i] := quad;
  end;
end;

function CCTextureAtlas.getCapacity: Cardinal;
begin
  Result := m_uCapacity;
end;

function CCTextureAtlas.getQuads: pccV3F_C4B_T2F_Quad;
begin
  m_bDirty := True;
  Result := @m_pQuads[0];
end;

function CCTextureAtlas.getTexture: CCTexture2D;
begin
  Result := m_pTexture;
end;

function CCTextureAtlas.getTotalQuads: Cardinal;
begin
  Result := m_uTotalQuads;
end;

procedure CCTextureAtlas.increaseTotalQuadsWith(amount: Cardinal);
begin
  m_uTotalQuads := m_uTotalQuads + amount;
end;

function CCTextureAtlas.initWithFile(const filename: string;
  capacity: Cardinal): Boolean;
var
  texture: CCTexture2D;
begin
  texture := CCTextureCache.sharedTextureCache().addImage(filename);
  if texture <> nil then
  begin
    Result := initWithTexture(texture, capacity);
  end else
  begin
    CCLOG('cocos2d: Could not open file: %s', [filename]);
    Result := False;
  end;  
end;

function CCTextureAtlas.initWithTexture(texture: CCTexture2D;
  capacity: Cardinal): Boolean;
begin
  m_uCapacity := capacity;
  m_uTotalQuads := 0;

  Self.m_pTexture := texture;
  CC_SAFE_RETAIN(m_pTexture);

  // Re-initialization is not allowed
  CCAssert((m_pQuads = nil) and (m_pIndices = nil), '');

  m_pQuads := AllocMem(SizeOf(ccV3F_C4B_T2F_Quad) * m_uCapacity);
  m_pIndices := AllocMem(SizeOf(GLuShort) * 6 * m_uCapacity);

  if ((m_pQuads = nil) or (m_pIndices = nil)) and (m_uCapacity > 0) then
  begin
    CC_SAFE_FREE_POINTER(m_pQuads);
    CC_SAFE_FREE_POINTER(m_pIndices);
    CC_SAFE_RELEASE_NULL(CCObject(m_pTexture));
    Result := False;
    Exit;
  end;

  setupIndices();
  setupVBO();
  m_bDirty := True;
  Result := True;
end;

procedure CCTextureAtlas.insertQuads(quad: pccV3F_C4B_T2F_Quad; index,
  amount: Cardinal);
var
  remaining: Integer;
  max, j, i: Cardinal;
begin
  CCAssert(index + amount <= m_uCapacity, 'insertQuadWithTexture: Invalid index + amount');

  m_uTotalQuads := m_uTotalQuads + amount;

  CCAssert( m_uTotalQuads <= m_uCapacity, 'invalid totalQuads');

  remaining := (m_uTotalQuads-1) - index - amount;
  if remaining > 0 then
  begin
    Move(m_pQuads^[index], m_pQuads^[index + amount], SizeOf(ccV3F_C4B_T2F_Quad) * remaining);
  end;

  max := index + amount;
  j := 0;
  for i := index to max-1 do
  begin
    m_pQuads^[index] := ptccV3F_C4B_T2F_Quad(quad)^[j];
    Inc(index);
    Inc(j);
  end;
  m_bDirty := True;
end;

procedure CCTextureAtlas.insertQuad(quad: pccV3F_C4B_T2F_Quad;
  index: Cardinal);
var
  remaining: Cardinal;
begin
  CCAssert( index < m_uCapacity, 'insertQuadWithTexture: Invalid index');

  Inc(m_uTotalQuads);
  CCAssert( m_uTotalQuads <= m_uCapacity, 'invalid totalQuads');
  
  remaining := (m_uTotalQuads-1) - index;
  if remaining > 0 then
  begin
    Move(m_pQuads[index], m_pQuads[index+1], SizeOf(ccV3F_C4B_T2F_Quad) * remaining);
  end;
  
  m_pQuads[index] := quad^;
  m_bDirty := True;
end;

procedure CCTextureAtlas.insertQuadFromIndex(oldIndex,
  newIndex: Cardinal);
var
  howMany, dst, src: Cardinal;
  quadsBackup: ccV3F_C4B_T2F_Quad;
begin
  CCAssert( {(newIndex >= 0) and} (newIndex < m_uTotalQuads), 'insertQuadFromIndex:atIndex: Invalid index');
  CCAssert( {(oldIndex >= 0) and} (oldIndex < m_uTotalQuads), 'insertQuadFromIndex:atIndex: Invalid index');

  if oldIndex = newIndex then
    Exit;

  if oldIndex - newIndex > 0 then
    howMany := oldIndex - newIndex
  else
    howMany := newIndex - oldIndex;

  dst := oldIndex;
  src := oldIndex + 1;

  if oldIndex > newIndex then
  begin
    dst := newIndex + 1;
    src := newIndex;
  end;

  quadsBackup := m_pQuads^[oldIndex];
  Move(m_pQuads^[src], m_pQuads^[dst], SizeOf(ccV3F_C4B_T2F_Quad) * howMany);
  m_pQuads^[newIndex] := quadsBackup;

  m_bDirty := True;
end;

procedure CCTextureAtlas.listenBackToForeground(obj: CCObject);
begin
  {$IFDEF CC_TEXTURE_ATLAS_USE_VAO}
  setupVBOandVAO();
  {$ELSE}
  setupVBO();
  {$ENDIF}
  m_bDirty := True;
end;

procedure CCTextureAtlas.mapBuffers;
var
  size: GLsizei;
begin
  glBindBuffer(GL_ARRAY_BUFFER, m_pBuffersVBO[0]);
  size := SizeOf(ccV3F_C4B_T2F_Quad) * m_uCapacity;
  {$ifdef IOS}
  glBufferData(GL_ARRAY_BUFFER, @size, m_pQuads, GL_DYNAMIC_DRAW);
  {$else}
  glBufferData(GL_ARRAY_BUFFER, size, m_pQuads, GL_DYNAMIC_DRAW);
  {$endif}
  glBindBuffer(GL_ARRAY_BUFFER, 0);

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_pBuffersVBO[1]);
  size := SizeOf(GLushort) * m_uCapacity * 6;
  {$ifdef IOS}
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, @size, m_pIndices, GL_STATIC_DRAW);
  {$else}
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, m_pIndices, GL_STATIC_DRAW);
  {$endif}
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
end;

procedure CCTextureAtlas.moveQuadsFromIndex(index, newIndex: Cardinal);
begin
  CCAssert(newIndex + (m_uTotalQuads - index) <= m_uCapacity, 'moveQuadsFromIndex move is out of bounds');
  Move(m_pQuads^[index], m_pQuads^[newIndex], (m_uTotalQuads-index)*SizeOf(ccV3F_C4B_T2F_Quad));
end;

procedure CCTextureAtlas.moveQuadsFromIndex(oldIndex, amount,
  newIndex: Cardinal);
var
  quadSize: Cardinal;
  tempQuads: pccV3F_C4B_T2F_Quad;
begin
  CCAssert(newIndex + amount <= m_uTotalQuads, 'insertQuadFromIndex:atIndex: Invalid index');
  CCAssert(oldIndex < m_uTotalQuads, 'insertQuadFromIndex:atIndex: Invalid index');

  if oldIndex = newIndex then
    Exit;

  quadSize := SizeOf(ccV3F_C4B_T2F_Quad);
  tempQuads := AllocMem(quadSize*amount);
  Move(m_pQuads^[oldIndex], tempQuads^, amount*quadSize);
  if newIndex < oldIndex then
  begin
    Move(m_pQuads^[newIndex+amount], m_pQuads^[newIndex], (oldIndex-newIndex)*quadSize);
  end else
  begin
    Move(m_pQuads^[oldIndex+amount], m_pQuads^[oldIndex], (newIndex-oldIndex)*quadSize);
  end;
  Move(tempQuads^, m_pQuads^[newIndex], amount*quadSize);

  FreeMem(tempQuads);

  m_bDirty := True;
end;

procedure CCTextureAtlas.removeAllQuads;
begin
  m_uTotalQuads := 0;
end;

procedure CCTextureAtlas.removeQuadAtIndex(index, amount: Cardinal);
var
  remaining: Cardinal;
begin
  CCAssert(index + amount <= m_uTotalQuads, 'removeQuadAtIndex: index + amount out of bounds');

  remaining := m_uTotalQuads - (index+amount);
  m_uTotalQuads := m_uTotalQuads - amount;

  if remaining > 0 then
  begin
    Move(m_pQuads^[index + amount], m_pQuads^[index], SizeOf(ccV3F_C4B_T2F_Quad) * remaining);
  end;
  m_bDirty := True;
end;

procedure CCTextureAtlas.removeQuadAtIndex(index: Cardinal);
var
  remaining: Cardinal;
begin
  CCAssert( index < m_uTotalQuads, 'removeQuadAtIndex: Invalid index');

  remaining := (m_uTotalQuads-1) - index;
  if remaining > 0 then
  begin
    Move(m_pQuads^[index+1], m_pQuads^[index], SizeOf(ccV3F_C4B_T2F_Quad) * remaining);
  end;
  Dec(m_uTotalQuads);
  m_bDirty := True;
end;

function CCTextureAtlas.resizeCapacity(newCapacity: Cardinal): Boolean;
begin
  if newCapacity = m_uCapacity then
  begin
    Result := True;
    Exit;
  end;

  m_uTotalQuads := Min(m_uTotalQuads, newCapacity);
  m_uCapacity := newCapacity;


  if m_pQuads = nil then
  begin
    m_pQuads := AllocMem(SizeOf(ccV3F_C4B_T2F_Quad) * m_uCapacity);
  end else
  begin
    ReallocMem(m_pQuads, SizeOf(ccV3F_C4B_T2F_Quad) * m_uCapacity);
  end;

  if m_pIndices = nil then
  begin
    m_pIndices := AllocMem(SizeOf(GLshort) * m_uCapacity * 6);
  end else
  begin
    ReallocMem(m_pIndices, SizeOf(GLshort) * m_uCapacity * 6);
  end;

  if (m_pIndices = nil) or (m_pQuads = nil) then
  begin
    FreeMem(m_pQuads);
    FreeMem(m_pIndices);
    m_uCapacity := 0;
    m_uTotalQuads := 0;
    Result := False;
    Exit;
  end;  

  setupIndices();
  mapBuffers();

  m_bDirty := True;

  Result := True;
end;

procedure CCTextureAtlas.setQuads(const Value: pccV3F_C4B_T2F_Quad);
begin
  m_pQuads := ptccV3F_C4B_T2F_Quad(Value);
end;

procedure CCTextureAtlas.setTexture(const Value: CCTexture2D);
begin
  if m_pTexture <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pTexture);
    m_pTexture := Value;
  end;
end;

procedure CCTextureAtlas.setupIndices;
var
  i: Integer;
begin
  if m_uCapacity < 1 then
    Exit;

  for i := 0 to m_uCapacity-1 do
  begin
    m_pIndices^[i*6+0] := i*4+0;
    m_pIndices^[i*6+1] := i*4+1;
    m_pIndices^[i*6+2] := i*4+2;

    m_pIndices^[i*6+3] := i*4+3;
    m_pIndices^[i*6+4] := i*4+2;
    m_pIndices^[i*6+5] := i*4+1;
  end;  
end;

procedure CCTextureAtlas.setupVBO;
begin
  glGenBuffers(2, @m_pBuffersVBO[0]);
  mapBuffers();
end;

procedure CCTextureAtlas.updateQuad(quad: pccV3F_C4B_T2F_Quad;
  index: Cardinal);
begin
  CCAssert( {(index >= 0) and }(index < m_uCapacity), 'updateQuadWithTexture: Invalid index');
  m_uTotalQuads := Max(index + 1, m_uTotalQuads);
  m_pQuads[index] := quad^;
  m_bDirty := True;
end;

function CCTextureAtlas.description: string;
begin
  Result := CCString.createWithFormat('<CCTextureAtlas | totalQuads = %d>', [m_uTotalQuads]).m_sString;
end;

function CCTextureAtlas.isDirty: Boolean;
begin
  Result := m_bDirty;
end;

procedure CCTextureAtlas.setDirty(bDirty: Boolean);
begin
  m_bDirty := bDirty;
end;

end.
