(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2009      Leonardo Kasperavi?ius
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

unit Cocos2dx.CCParticleSystemQuad;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCNode, Cocos2dx.CCSpriteFrame, Cocos2dx.CCTypes,
  Cocos2dx.CCParticleSystem, Cocos2dx.CCPointerArray, Cocos2dx.CCGeometry,
  Cocos2dx.CCTexture2D;

type
  (** @brief CCParticleSystemQuad is a subclass of CCParticleSystem

      It includes all the features of ParticleSystem.

      Special features and Limitations:
      - Particle size can be any float number.
      - The system can be scaled
      - The particles can be rotated
      - It supports subrects
      - It supports batched rendering since 1.1
      @since v0.8
  *)
  CCParticleSystemQuad = class(CCParticleSystem)
  protected
    m_pQuads: ptccV3F_C4B_T2F_Quad;
    m_pIndices: PGLushortArray;
    m_pBuffersVBO: array [0..1] of GLuint;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure initIndices();
    procedure initTexCoordsWithRect(const pointRect: CCRect);
    procedure setDisplayFrame(spriteFrame: CCSpriteFrame);
    procedure setTextureWithRect(texture: CCTexture2D; const rect: CCRect);

    function initWithTotalParticles(numberOfParticles: Cardinal): Boolean; override;
    procedure setTexture(texture: CCTexture2D); override;
    procedure updateQuadWithParticle(particle: pCCParticle; const newPosition: CCPoint); override;
    procedure postStep(); override;
    procedure draw(); override;
    procedure setBatchNode(const Value: CCObject); override;
    procedure setTotalParticles(const tp: Cardinal); override;

    procedure listenBackToForeground(obj: CCObject);

    class function _create(const plistFile: string): CCParticleSystemQuad; overload;
    class function _create(): CCParticleSystemQuad; overload;
    class function createWithTotalParticles(numberOfParticles: Cardinal): CCParticleSystemQuad;
  private
    procedure setupVBO();
    function allocMemory(): Boolean;
  end;

implementation
uses
  Math, SysUtils,
  Cocos2dx.CCParticleBatchNode, Cocos2dx.CCTextureAtlas, Cocos2dx.CCShaderCache, Cocos2dx.CCPlatformMacros,
  Cocos2dx.CCGLStateCache, Cocos2dx.CCGLProgram, Cocos2dx.CCCommon,
  Cocos2dx.CCMacros;

{ CCParticleSystemQuad }

class function CCParticleSystemQuad._create: CCParticleSystemQuad;
var
  pRet: CCParticleSystemQuad;
begin
  pRet := CCParticleSystemQuad.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCParticleSystemQuad._create(
  const plistFile: string): CCParticleSystemQuad;
var
  pRet: CCParticleSystemQuad;
begin
  pRet := CCParticleSystemQuad.Create();
  if (pRet <> nil) and pRet.initWithFile(plistFile) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCParticleSystemQuad.allocMemory: Boolean;
begin
  CCAssert((m_pQuads = nil) and (m_pIndices = nil), 'Memory already alloced');
  CCAssert(m_pBatchNode = nil, 'Memory should not be alloced when not using batchNode');

  CC_SAFE_FREE_POINTER_NULL(Pointer(m_pQuads));
  CC_SAFE_FREE_POINTER_NULL(Pointer(m_pIndices));

  m_pQuads := AllocMem(m_uTotalParticles * SizeOf(ccV3F_C4B_T2F_Quad));
  m_pIndices := AllocMem(m_uTotalParticles * 6 * SizeOf(GLushort));

  if (m_pQuads = nil) or (m_pIndices = nil) then
  begin
    CCLog('cocos2d: Particle system: not enough memory', []);
    CC_SAFE_FREE_POINTER_NULL(Pointer(m_pQuads));
    CC_SAFE_FREE_POINTER_NULL(Pointer(m_pIndices));
    Result := False;
    Exit;
  end;
  
  Result := True;
end;

constructor CCParticleSystemQuad.Create;
begin
  inherited Create();
  FillChar(m_pBuffersVBO, SizeOf(m_pBuffersVBO), 0);
end;

class function CCParticleSystemQuad.createWithTotalParticles(
  numberOfParticles: Cardinal): CCParticleSystemQuad;
var
  pRet: CCParticleSystemQuad;
begin
  pRet := CCParticleSystemQuad.Create();
  if (pRet <> nil) and pRet.initWithTotalParticles(numberOfParticles) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCParticleSystemQuad.Destroy;
begin
  if m_pBatchNode = nil then
  begin
    CC_SAFE_FREE_POINTER(m_pQuads);
    CC_SAFE_FREE_POINTER(m_pIndices);
    glDeleteBuffers(2, @m_pBuffersVBO[0]);
  end;  
  inherited;
end;

procedure CCParticleSystemQuad.draw;
var
  kQuadSize: Cardinal;
  vDiff, tDiff, cDiff: Cardinal;
begin
  if m_pTexture = nil then
    Exit;
    
  CC_NODE_DRAW_SETUP();

  ccGLBindTexture2D(m_pTexture.Name);
  ccGLBlendFunc(m_tBlendFunc.src, m_tBlendFunc.dst);

  CCAssert(m_uParticleIdx = m_uParticleCount, 'Abnormal error in particle quad');

  kQuadSize := SizeOf(m_pQuads[0].bl);
  ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);

  glBindBuffer(GL_ARRAY_BUFFER, m_pBuffersVBO[0]);

  get_ccV3F_C4B_T2F_dif(vDiff, cDiff, tDiff);

  glVertexAttribPointer(kCCVertexAttrib_Position,  3, GL_FLOAT, GL_FALSE, kQuadSize, BUFFER_OFFSET(vDiff));
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, BUFFER_OFFSET(tDiff));
  glVertexAttribPointer(kCCVertexAttrib_Color,     4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, BUFFER_OFFSET(cDiff));

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_pBuffersVBO[1]);
  glDrawElements(GL_TRIANGLES, m_uParticleIdx*6, GL_UNSIGNED_SHORT, nil);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

  CC_INCREMENT_GL_DRAWS(1);
end;

procedure CCParticleSystemQuad.initTexCoordsWithRect(const pointRect: CCRect);
var
  rect: CCRect;
  width, height: GLfloat;
  left, right, top, bottom, tmp: Single;
  start, _end, i: Cardinal;
  quads: ptccV3F_C4B_T2F_Quad;
begin
  rect := CCRectMake(
    pointRect.origin.x * CC_CONTENT_SCALE_FACTOR(),
    pointRect.origin.y * CC_CONTENT_SCALE_FACTOR(),
    pointRect.size.width * CC_CONTENT_SCALE_FACTOR(),
    pointRect.size.height * CC_CONTENT_SCALE_FACTOR()
  );

  width := pointRect.size.width;
  height := pointRect.size.height;

  if m_pTexture <> nil then
  begin
    width := m_pTexture.PixelsWide;
    height := m_pTexture.PixelsHigh;
  end;

  left := rect.origin.x / width;
  bottom := rect.origin.y / height;
  right := left + rect.size.width / width;
  top := bottom + rect.size.height / height;

  tmp := top; top := bottom; bottom := tmp;

  if m_pBatchNode <> nil then
  begin
    quads := ptccV3F_C4B_T2F_Quad(CCParticleBatchNode(m_pBatchNode).getTextureAtlas().Quads);
    start := m_uAtlasIndex;
    _end := m_uAtlasIndex + m_uTotalParticles;
  end else
  begin
    quads := m_pQuads;
    start := 0;
    _end := m_uTotalParticles;
  end;

  if _end > 0 then
    for i := start to _end - 1 do
    begin
      quads^[i].bl.texCoords.u := left;
      quads^[i].bl.texCoords.v := bottom;

      quads^[i].br.texCoords.u := right;
      quads^[i].br.texCoords.v := bottom;

      quads^[i].tl.texCoords.u := left;
      quads^[i].tl.texCoords.v := top;

      quads^[i].tr.texCoords.u := right;
      quads^[i].tr.texCoords.v := top;
    end;

end;

function CCParticleSystemQuad.initWithTotalParticles(
  numberOfParticles: Cardinal): Boolean;
begin
  if inherited initWithTotalParticles(numberOfParticles) then
  begin
    if not allocMemory() then
    begin
      Self.release();
      Result := False;
      Exit;
    end;

    initIndices();
    setupVBO();

    setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColor));

    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure CCParticleSystemQuad.listenBackToForeground(obj: CCObject);
begin
  setupVBO();
end;

procedure CCParticleSystemQuad.postStep;
var
  offset: GLint;
  size: GLsizei;
begin
  glBindBuffer(GL_ARRAY_BUFFER, m_pBuffersVBO[0]);
  offset := 0;
  size := SizeOf(ccV3F_C4B_T2F_Quad) * m_uTotalParticles;
  {$ifdef IOS}
  glBufferSubData(GL_ARRAY_BUFFER, @offset, @size, m_pQuads);
  {$else}
  glBufferSubData(GL_ARRAY_BUFFER, offset, size, m_pQuads);
  {$endif}
  glBindBuffer(GL_ARRAY_BUFFER, 0);
end;

procedure CCParticleSystemQuad.setBatchNode(const Value: CCObject);
var
  oldBatch: CCParticleBatchNode;
  pbatchQuads: ptccV3F_C4B_T2F_Quad;
  quad: pccV3F_C4B_T2F_Quad;
begin
  if m_pBatchNode <> Value then
  begin
    oldBatch := CCParticleBatchNode(m_pBatchNode);
    inherited setBatchNode(Value);

    if Value = nil then
    begin
      allocMemory();
      initIndices();
      setTexture(oldBatch.getTexture());
      setupVBO();
    end else if oldBatch = nil then
    begin
      pbatchQuads := ptccV3F_C4B_T2F_Quad( CCParticleBatchNode(m_pBatchNode).getTextureAtlas().Quads );
      quad := @pbatchQuads^[m_uAtlasIndex];
      Move(m_pQuads^, quad^, m_uTotalParticles * SizeOf(ccV3F_C4B_T2F_Quad));

      CC_SAFE_FREE_POINTER_NULL(Pointer(m_pQuads));
      CC_SAFE_FREE_POINTER_NULL(Pointer(m_pIndices));

      glDeleteBuffers(2, @m_pBuffersVBO[0]);
      FillChar(m_pBuffersVBO, SizeOf(m_pBuffersVBO), 0);
    end;
  end;  
end;

procedure CCParticleSystemQuad.setDisplayFrame(spriteFrame: CCSpriteFrame);
begin
  CCAssert(spriteFrame.getOffsetInPixels().equal(CCPointZero), 'QuadParticle only supports SpriteFrames with no offsets');
  if (m_pTexture = nil) or (spriteFrame.getTexture().Name <> m_pTexture.Name) then
  begin
    setTexture(spriteFrame.getTexture());
  end;  
end;

procedure CCParticleSystemQuad.setTexture(texture: CCTexture2D);
var
  s: CCSize;
begin
  s := texture.ContentSize;
  setTextureWithRect(texture, CCRectMake(0, 0, s.width, s.height));
end;

procedure CCParticleSystemQuad.setTextureWithRect(texture: CCTexture2D;
  const rect: CCRect);
begin
  if (m_pTexture = nil) or (texture.Name <> m_pTexture.Name) then
  begin
    inherited setTexture(texture);
  end;
  initTexCoordsWithRect(rect);
end;

procedure CCParticleSystemQuad.setTotalParticles(const tp: Cardinal);
var
  particlesSize, quadSize, indicesSize: Cardinal;
  particlesNew: pCCParticleArray;
  quadsNew: ptccV3F_C4B_T2F_Quad;
  indicesNew: PGLushortArray;
  i: Cardinal;
begin
  if tp > m_uAllocatedParticles then
  begin
    particlesSize := tp * SizeOf(tccParticle);
    quadSize := SizeOf(ccV3F_C4B_T2F_Quad) * tp * 1;
    indicesSize := SizeOf(GLushort) * tp * 6 * 1;

    particlesNew := AllocMem(particlesSize);
    quadsNew := AllocMem(quadSize);
    indicesNew := AllocMem(indicesSize);

    if (particlesNew <> nil) and (quadsNew <> nil) and (indicesNew <> nil) then
    begin
      m_pParticles := particlesNew;
      m_pQuads := quadsNew;
      m_pIndices := indicesNew;

      m_uAllocatedParticles := tp;
    end else
    begin
      if particlesNew <> nil then
        m_pParticles := particlesNew;
      if quadsNew <> nil then
        m_pQuads := quadsNew;
      if indicesNew <> nil then
        m_pIndices := indicesNew;

      CCLog('Particle system: out of memory', []);
      Exit;
    end;

    m_uTotalParticles := tp;

    if m_pBatchNode <> nil then
    begin
      if m_uTotalParticles > 0 then
        for i := 0 to m_uTotalParticles-1 do
        begin
          m_pParticles^[i].atlasIndex := i;
        end;
    end;

    initIndices();
    setupVBO();
  end else
  begin
    m_uTotalParticles := tp;
  end;

  resetSystem();
end;

procedure CCParticleSystemQuad.initIndices;
var
  i: Cardinal;
  i6, i4: Cardinal;
begin
  if m_uTotalParticles < 1 then
    Exit;

  for i := 0 to m_uTotalParticles-1 do
  begin
    i6 := i * 6;
    i4 := i * 4;

    m_pIndices[i6 + 0] := i4 + 0;
    m_pIndices[i6 + 1] := i4 + 1;
    m_pIndices[i6 + 2] := i4 + 2;

    m_pIndices[i6 + 5] := i4 + 1;
    m_pIndices[i6 + 4] := i4 + 2;
    m_pIndices[i6 + 3] := i4 + 3;
  end;  
end;

procedure CCParticleSystemQuad.setupVBO;
var
  size: GLsizei;
begin
  glDeleteBuffers(2, @m_pBuffersVBO[0]);
  
  glGenBuffers(2, @m_pBuffersVBO[0]);

  glBindBuffer(GL_ARRAY_BUFFER, m_pBuffersVBO[0]);

  size := SizeOf(ccV3F_C4B_T2F_Quad) * m_uTotalParticles;
  {$ifdef IOS}
  glBufferData(GL_ARRAY_BUFFER, @size, m_pQuads, GL_DYNAMIC_DRAW);
  {$else}
  glBufferData(GL_ARRAY_BUFFER, size, m_pQuads, GL_DYNAMIC_DRAW);
  {$endif}

  glBindBuffer(GL_ARRAY_BUFFER, 0);

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_pBuffersVBO[1]);
  size := SizeOf(m_pIndices^[0]) * m_uTotalParticles * 6; 
  {$ifdef IOS}
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, @size, m_pIndices, GL_STATIC_DRAW);
  {$else}
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, m_pIndices, GL_STATIC_DRAW);
  {$endif}
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

  CHECK_GL_ERROR_DEBUG();
end;

procedure CCParticleSystemQuad.updateQuadWithParticle(
  particle: pCCParticle; const newPosition: CCPoint);
var
  quad: pccV3F_C4B_T2F_Quad;
  color: ccColor4B;
  size_2: GLfloat;
  pbatchQuads: ptccV3F_C4B_T2F_Quad;
  x1, y1, x2, y2, x, y, r, cr, sr, ax, ay, bx, by, cx, cy, dx, dy: GLfloat;
begin
  if m_pBatchNode <> nil then
  begin
    pbatchQuads := ptccV3F_C4B_T2F_Quad(CCParticleBatchNode(m_pBatchNode).getTextureAtlas().Quads);
    quad := @pbatchQuads^[m_uAtlasIndex + particle^.atlasIndex];
  end else
  begin
    quad := @m_pQuads^[m_uParticleIdx];
  end;

  if m_bOpacityModifyRGB then
    color := ccc4(Round(particle^.color.r * particle^.color.a * 255),
                  Round(particle^.color.g * particle^.color.a * 255),
                  Round(particle^.color.b * particle^.color.a * 255),
                  Round(particle^.color.a * 255))
  else
    color := ccc4(Round(particle^.color.r * 255),
                  Round(particle^.color.g * 255),
                  Round(particle^.color.b * 255),
                  Round(particle^.color.a * 255));

  quad.bl.colors := color;
  quad.br.colors := color;
  quad.tl.colors := color;
  quad.tr.colors := color;

  size_2 := particle^.size * 0.5;
  if not IsZero(particle^.rotation) then
  begin
    x1 := -size_2;
    y1 := -size_2;

    x2 := size_2;
    y2 := size_2;
    x := newPosition.x;
    y := newPosition.y;

    r := -CC_DEGREES_TO_RADIANS(particle^.rotation);
    cr := Cos(r);
    sr := Sin(r);
    ax := x1 * cr - y1 * sr + x;
    ay := x1 * sr + y1 * cr + y;
    bx := x2 * cr - y1 * sr + x;
    by := x2 * sr + y1 * cr + y;
    cx := x2 * cr - y2 * sr + x;
    cy := x2 * sr + y2 * cr + y;
    dx := x1 * cr - y2 * sr + x;
    dy := x1 * sr + y2 * cr + y;

    quad.bl.vertices.x := ax;
    quad.bl.vertices.y := ay;

    quad.br.vertices.x := bx;
    quad.br.vertices.y := by;

    quad.tl.vertices.x := dx;
    quad.tl.vertices.y := dy;

    quad.tr.vertices.x := cx;
    quad.tr.vertices.y := cy;
  end else
  begin
    quad.bl.vertices.x := newPosition.x - size_2;
    quad.bl.vertices.y := newPosition.y - size_2;

    quad.br.vertices.x := newPosition.x + size_2;
    quad.br.vertices.y := newPosition.y - size_2;

    quad.tl.vertices.x := newPosition.x - size_2;
    quad.tl.vertices.y := newPosition.y + size_2;

    quad.tr.vertices.x := newPosition.x + size_2;
    quad.tr.vertices.y := newPosition.y + size_2;
  end;    
end;

end.
