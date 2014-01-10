(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      On-Core

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

unit Cocos2dx.CCGrid;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCCamera, Cocos2dx.CCTypes, Cocos2dx.CCTexture2D,
  Cocos2dx.CCDirectorProjection, mat4, utility, Cocos2dx.CCGrabber,
  Cocos2dx.CCGLProgram, Cocos2dx.CCGeometry, Cocos2dx.CCPointerArray;

type
  CCGridBase = class(CCObject)
  public
    destructor Destroy(); override;
    function isActive(): Boolean;
    procedure setActive(bActive: Boolean);
    function getReuseGrid(): Integer;
    procedure setReuseGrid(nReuseGrid: Integer);
    function getGridSize(): CCSize;
    procedure setGridSize(const gridSize: CCSize);
    function getStep(): CCPoint;
    procedure setStep(const step: CCPoint);
    function isTextureFlipped(): Boolean;
    procedure setTextureFlipped(bFlipped: Boolean);
    function initWithSize(const gridSize: CCSize; pTexture: CCTexture2D; bFlipped: Boolean): Boolean; overload;
    function initWithSize(const gridSize: CCSize): Boolean; overload;
    procedure beforeDraw();
    procedure afterDraw(pTarget: CCObject{CCNode});
    procedure blit(); virtual;
    procedure reuse(); virtual;
    procedure calculateVertexPoints(); virtual;
    class function _create(const gridSize: CCSize; pTexture: CCTexture2D; bFlipped: Boolean): CCGridBase; overload;
    class function _create(const gridSize: CCSize): CCGridBase; overload;
    procedure set2DProjection();
  protected
    m_bActive: Boolean;
    m_nReuseGrid: Integer;
    m_sGridSize: CCSize;
    m_pTexture: CCTexture2D;
    m_obStep: CCPoint;
    m_pGrabber: CCGrabber;
    m_bIsTextureFlipped: Boolean;
    m_pShaderProgram: CCGLProgram;
    m_directorProjection: ccDirectorProjection;
  end;

  (**
   CCGrid3D is a 3D grid implementation. Each vertex has 3 dimensions: x,y,z
   @js NA
   @lua NA
   *)
  CCGrid3D = class(CCGridBase)
  public
    constructor Create();
    destructor Destroy(); override;
    //** returns the vertex at a given position */
    function vertex(const pos: CCPoint): ccVertex3F;
    //** returns the original (non-transformed) vertex at a given position */
    function originalVertex(const pos: CCPoint): ccVertex3F;
    //** sets a new vertex at a given position */
    procedure setVertex(const pos: CCPoint; const vertex: ccVertex3F);
    procedure blit(); override;
    procedure reuse(); override;
    procedure calculateVertexPoints(); override;
    class function _create(const gridSize: CCSize; pTexture: CCTexture2D; bFlipped: Boolean): CCGridBase; overload;
    class function _create(const gridSize: CCSize): CCGridBase; overload;
  protected
    m_pTexCoordinates: PGLvoidArray;
    m_pVertices: PGLvoidArray;
    m_pOriginalVertices: PGLvoidArray;
    m_pIndices: PGLushortArray;
  end;

  (**
   CCTiledGrid3D is a 3D grid implementation. It differs from Grid3D in that
   the tiles can be separated from the grid.
   @js NA
   @lua NA
  *)
  CCTiledGrid3D = class(CCGridBase)
  public
    constructor Create();
    destructor Destroy(); override;
    //** returns the tile at the given position */
    function tile(const pos: CCPoint): ccQuad3;
    //** returns the original tile (untransformed) at the given position */
    function originalTile(const pos: CCPoint): ccQuad3;
    //** sets a new tile */
    procedure setTile(const pos: CCPoint; const coords: ccQuad3);
    procedure blit(); override;
    procedure reuse(); override;
    procedure calculateVertexPoints(); override;
    class function _create(const gridSize: CCSize; pTexture: CCTexture2D; bFlipped: Boolean): CCTiledGrid3D; overload;
    class function _create(const gridSize: CCSize): CCTiledGrid3D; overload;
  protected
    m_pTexCoordinates: PGLvoidArray;
    m_pVertices: PGLvoidArray;
    m_pOriginalVertices: PGLvoidArray;
    m_pIndices: PGLushortArray;
  end;

implementation
uses
  SysUtils, Math,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCCommon, Cocos2dx.CCShaderCache,
  Cocos2dx.CCUtils, Cocos2dx.CCMacros, matrix, Cocos2dx.CCGLStateCache,
  Cocos2dx.CCPointExtension, Cocos2dx.CCNode, Cocos2dx.CCDirector;

{ CCGridBase }

class function CCGridBase._create(const gridSize: CCSize): CCGridBase;
var
  pRet: CCGridBase;
begin
  pRet := CCGridBase.Create();
  if (pRet <> nil) and pRet.initWithSize(gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := pRet;
end;

class function CCGridBase._create(const gridSize: CCSize;
  pTexture: CCTexture2D; bFlipped: Boolean): CCGridBase;
var
  pRet: CCGridBase;
begin
  pRet := CCGridBase.Create();
  if (pRet <> nil) and pRet.initWithSize(gridSize, pTexture, bFlipped) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := pRet;
end;

procedure CCGridBase.afterDraw(pTarget: CCObject);
var
  director: CCDirector;
  offset: CCPoint;
begin
  m_pGrabber.afterRender(m_pTexture);

  director := CCDirector.sharedDirector();
  director.setProjection(m_directorProjection);

  if CCNode(pTarget).Camera.isDirty() then
  begin
    offset := CCNode(pTarget).AnchorPointInPoints;

    kmGLTranslatef(offset.x, offset.y, 0);
    CCNode(pTarget).Camera.locate();
    kmGLTranslatef(-offset.x, -offset.y, 0);
  end;

  ccGLBindTexture2D(m_pTexture.Name);

  blit();
end;

procedure CCGridBase.beforeDraw;
var
  director: CCDirector;
begin
  director := CCDirector.sharedDirector();
  m_directorProjection := director.getProjection();

  set2DProjection();
  m_pGrabber.beforeRender(m_pTexture);
end;

procedure CCGridBase.blit;
begin
//nothing
end;

procedure CCGridBase.calculateVertexPoints;
begin
//nothing
end;

destructor CCGridBase.Destroy;
begin
  CC_SAFE_RELEASE(m_pTexture);
  CC_SAFE_RELEASE(m_pGrabber);
  inherited;
end;

function CCGridBase.getGridSize: CCSize;
begin
  Result := m_sGridSize;
end;

function CCGridBase.getReuseGrid: Integer;
begin
  Result := m_nReuseGrid;
end;

function CCGridBase.getStep: CCPoint;
begin
  Result := m_obStep;
end;

function CCGridBase.initWithSize(const gridSize: CCSize;
  pTexture: CCTexture2D; bFlipped: Boolean): Boolean;
var
  bRet: Boolean;
  texSize: CCSize;
begin
  bRet := True;
  m_bActive := False;
  m_nReuseGrid := 0;
  m_sGridSize := gridSize;

  m_pTexture := pTexture;
  CC_SAFE_RETAIN(m_pTexture);
  m_bIsTextureFlipped := bFlipped;

  texSize := m_pTexture.ContentSize;
  m_obStep.x := texSize.width / m_sGridSize.width;
  m_obStep.y := texSize.height / m_sGridSize.height;

  m_pGrabber := CCGrabber.Create();
  if m_pGrabber <> nil then
  begin
    m_pGrabber.grab(m_pTexture);
  end else
  begin
    bRet := False;
  end;

  m_pShaderProgram := CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTexture);
  calculateVertexPoints();

  Result := bRet;
end;

function CCGridBase.initWithSize(const gridSize: CCSize): Boolean;
var
  pDirector: CCDirector;
  s: CCSize;
  POTWide, POTHigh: Cardinal;
  format: CCTexture2DPixelFormat;
  data: Pointer;
  pTexture: CCTexture2D;
begin
  pDirector := CCDirector.sharedDirector();
  s := pDirector.getWinSizeInPixels();

  POTWide := ccNextPOT(Round(s.width));
  POTHigh := ccNextPOT(Round(s.height));

  // we only use rgba8888
  format := kCCTexture2DPixelFormat_RGBA8888;
  data := AllocMem(POTWide * POTHigh * 4);
  if data = nil then
  begin
    CCLog('cocos2d: CCGrid: not enough memory.', []);
    Self.release();
    Result := False;
    Exit;
  end;

  pTexture := CCTexture2D.Create();
  pTexture.initWithData(data, format, POTWide, POTHigh, s);
  FreeMem(data);

  if pTexture = nil then
  begin
    CCLog('cocos2d: CCGrid: error creating texture', []);
    Result := False;
    Exit;
  end;

  initWithSize(gridSize, pTexture, False);
  pTexture.release();

  Result := True;
end;

function CCGridBase.isActive: Boolean;
begin
  Result := m_bActive;
end;

function CCGridBase.isTextureFlipped: Boolean;
begin
  Result := m_bIsTextureFlipped;
end;

procedure CCGridBase.reuse;
begin
//nothing
end;

procedure CCGridBase.set2DProjection;
var
  director: CCDirector;
  size: CCSize;
  orthoMatrix: kmMat4;
begin
  director := CCDirector.sharedDirector();
  size := director.getWinSizeInPixels();

  glViewport(0, 0, Round(size.width * CC_CONTENT_SCALE_FACTOR()), Round(size.height * CC_CONTENT_SCALE_FACTOR()));
  kmGLMatrixMode(KM_GL_PROJECTION);
  kmGLLoadIdentity();

  kmMat4OrthographicProjection(@orthoMatrix, 0, size.width * CC_CONTENT_SCALE_FACTOR(), 0, size.height * CC_CONTENT_SCALE_FACTOR(), -1, 1);
  kmGLMultMatrix(@orthoMatrix);

  kmGLMatrixMode(KM_GL_MODELVIEW);
  kmGLLoadIdentity();

  ccSetProjectionMatrixDirty();
end;

procedure CCGridBase.setActive(bActive: Boolean);
var
  pDirector: CCDirector;
  proj: ccDirectorProjection;
begin
  m_bActive := bActive;
  if not bActive then
  begin
    pDirector := CCDirector.sharedDirector();

    //what means
    proj := pDirector.getProjection();
    pDirector.setProjection(proj);
  end;  
end;

procedure CCGridBase.setGridSize(const gridSize: CCSize);
begin
  m_sGridSize := gridSize;
end;

procedure CCGridBase.setReuseGrid(nReuseGrid: Integer);
begin
  m_nReuseGrid := nReuseGrid;
end;

procedure CCGridBase.setStep(const step: CCPoint);
begin
  m_obStep := step;
end;

procedure CCGridBase.setTextureFlipped(bFlipped: Boolean);
begin
  if m_bIsTextureFlipped <> bFlipped then
  begin
    m_bIsTextureFlipped := bFlipped;
    calculateVertexPoints();
  end;
end;

{ CCGrid3D }

class function CCGrid3D._create(const gridSize: CCSize): CCGridBase;
var
  pRet: CCGrid3D;
begin
  pRet := CCGrid3D.Create();
  if (pRet <> nil) and pRet.initWithSize(gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCGrid3D._create(const gridSize: CCSize;
  pTexture: CCTexture2D; bFlipped: Boolean): CCGridBase;
var
  pRet: CCGrid3D;
begin
  pRet := CCGrid3D.Create();
  if (pRet <> nil) and pRet.initWithSize(gridSize, pTexture, bFlipped) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCGrid3D.blit;
var
  n: Integer;
begin
  n := Round(m_sGridSize.width * m_sGridSize.height);

  ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position or kCCVertexAttribFlag_TexCoords );
  m_pShaderProgram.use();
  m_pShaderProgram.setUniformsForBuiltins();

  // Attributes
  //

  // position
  glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, m_pVertices);

  // texCoords
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, m_pTexCoordinates);

  glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, m_pIndices);
  CC_INCREMENT_GL_DRAWS(1);
end;

procedure CCGrid3D.calculateVertexPoints;
var
  width, height, imageH: Single;
  x, y, i, idx: Integer;
  numOfPoints: Cardinal;
  vertArray, texArray: PGLfloatArray;
  idxArray: PGLushortArray;
  x1, x2, y1, y2: GLfloat;
  a, b, c, d: GLushort;
  tempidx: array [0..5] of GLushort;
  l1: array [0..3] of Integer;
  e, f, g, h: ccVertex3F;
  l2: array [0..3] of ccVertex3F;
  tex2: array [0..3] of CCPoint;
  tex1: array [0..3] of Integer;
begin
  width := m_pTexture.PixelsWide;
  height := m_pTexture.PixelsHigh;
  imageH := m_pTexture.getContentSizeInPixels().height;

  CC_SAFE_FREE_POINTER(m_pTexCoordinates);
  CC_SAFE_FREE_POINTER(m_pVertices);
  CC_SAFE_FREE_POINTER(m_pIndices);
  CC_SAFE_FREE_POINTER(m_pOriginalVertices);

  numOfPoints := Round((m_sGridSize.width + 1) * (m_sGridSize.height + 1));

  m_pVertices := AllocMem(numOfPoints * SizeOf(ccVertex3F));
  m_pOriginalVertices := AllocMem(numOfPoints * SizeOf(ccVertex3F));
  m_pTexCoordinates := AllocMem(numOfPoints * SizeOf(ccVertex2F));
  m_pIndices := AllocMem(Round(m_sGridSize.width * m_sGridSize.height * SizeOf(GLushort) * 6));

  vertArray := PGLfloatArray(m_pVertices);
  texArray := PGLfloatArray(m_pTexCoordinates);
  idxArray := m_pIndices;

  for x := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for y := 0 to Floor(m_sGridSize.height)-1 do
    begin
      idx := Round(y * m_sGridSize.width + x);

      x1 := x * m_obStep.x;
      x2 := x1 + m_obStep.x;
      y1 := y * m_obStep.y;
      y2 := y1 + m_obStep.y;

      a := Round(x * (m_sGridSize.height + 1) + y);
      b := Round((x + 1) * (m_sGridSize.height + 1) + y);
      c := Round((x + 1) * (m_sGridSize.height + 1) + (y + 1));
      d := Round(x * (m_sGridSize.height + 1) + (y + 1));

      tempidx[0] := a; tempidx[1] := b; tempidx[2] := d;
      tempidx[3] := b; tempidx[4] := c; tempidx[5] := d;

      Move(tempidx, idxArray[6*idx], 6*SizeOf(GLushort));

      l1[0] := a*3; l1[1] := b*3; l1[2] := c*3; l1[3] := d*3;
      e := vertex3(x1, y1, 0);
      f := vertex3(x2, y1, 0);
      g := vertex3(x2, y2, 0);
      h := vertex3(x1, y2, 0);

      l2[0] := e; l2[1] := f; l2[2] := g; l2[3] := h;
      tex1[0] := a*2; tex1[1] := b*2; tex1[2] := c*2; tex1[3] := d*2;

      tex2[0] := ccp(x1, y1); tex2[1] := ccp(x2, y1);
      tex2[2] := ccp(x2, y2); tex2[3] := ccp(x1, y2);

      for i := 0 to 3 do
      begin
        vertArray[l1[i]] := l2[i].x;
        vertArray[l1[i] + 1] := l2[i].y;
        vertArray[l1[i] + 2] := l2[i].z;

        texArray[tex1[i]] := tex2[i].x/width;

        if m_bIsTextureFlipped then
        begin
          texArray[tex1[i] + 1] := (imageH - tex2[i].y)/height;
        end else
        begin
          texArray[tex1[i] + 1] := tex2[i].y/height;
        end;    
      end;  
    end;  
  end;

  Move(m_pVertices^, m_pOriginalVertices^, SizeOf(ccVertex3F) * Round((m_sGridSize.width + 1) * (m_sGridSize.height + 1)));
end;

constructor CCGrid3D.Create;
begin
  inherited Create();
end;

destructor CCGrid3D.Destroy;
begin
  CC_SAFE_FREE_POINTER(m_pTexCoordinates);
  CC_SAFE_FREE_POINTER(m_pVertices);
  CC_SAFE_FREE_POINTER(m_pIndices);
  CC_SAFE_FREE_POINTER(m_pOriginalVertices);
  inherited;
end;

function CCGrid3D.originalVertex(const pos: CCPoint): ccVertex3F;
var
  index: Integer;
  vertArray: PGLfloatArray;
  vert: ccVertex3F;
begin
  index := Round((pos.x * (m_sGridSize.height + 1) + pos.y) * 3);
  vertArray := PGLfloatArray(m_pOriginalVertices);
  vert := vertex3(vertArray[index], vertArray[index + 1], vertArray[index + 2]);
  Result := vert;
end;

procedure CCGrid3D.reuse;
begin
  if m_nReuseGrid > 0 then
  begin
    Move(m_pVertices^, m_pOriginalVertices^, Round((m_sGridSize.width + 1) * (m_sGridSize.height + 1)) * SizeOf(ccVertex3f));
    Dec(m_nReuseGrid);
  end;
end;

procedure CCGrid3D.setVertex(const pos: CCPoint;
  const vertex: ccVertex3F);
var
  index: Integer;
  vertArray: PGLfloatArray;
begin
  index := Round((pos.x * (m_sGridSize.height + 1) + pos.y) * 3);
  vertArray := PGLfloatArray(m_pVertices);
  vertArray[index] := vertex.x;
  vertArray[index + 1] := vertex.y;
  vertArray[index + 2] := vertex.z;
end;

function CCGrid3D.vertex(const pos: CCPoint): ccVertex3F;
var
  index: Integer;
  vertArray: PGLfloatArray;
  vert: ccVertex3F;
begin
  index := Round((pos.x * (m_sGridSize.height + 1) + pos.y) * 3);
  vertArray := PGLfloatArray(m_pVertices);
  vert := vertex3(vertArray[index], vertArray[index + 1], vertArray[index + 2]);
  Result := vert;
end;

{ CCTiledGrid3D }

class function CCTiledGrid3D._create(const gridSize: CCSize;
  pTexture: CCTexture2D; bFlipped: Boolean): CCTiledGrid3D;
var
  pRet: CCTiledGrid3D;
begin
  pRet := CCTiledGrid3D.Create();
  if (pRet <> nil) and pRet.initWithSize(gridSize, pTexture, bFlipped) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCTiledGrid3D._create(
  const gridSize: CCSize): CCTiledGrid3D;
var
  pRet: CCTiledGrid3D;
begin
  pRet := CCTiledGrid3D.Create();
  if (pRet <> nil) and pRet.initWithSize(gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCTiledGrid3D.blit;
var
  n: Integer;
begin
  n := Floor(m_sGridSize.width * m_sGridSize.height);


  m_pShaderProgram.use();
  m_pShaderProgram.setUniformsForBuiltins();

  //
  // Attributes
  //
  ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position or kCCVertexAttribFlag_TexCoords );
  // position
  glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, m_pVertices);

  // texCoords
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, m_pTexCoordinates);

  glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, m_pIndices);

  CC_INCREMENT_GL_DRAWS(1);
end;

procedure CCTiledGrid3D.calculateVertexPoints;
var
  width, height, imageH: Single;
  numQuads: Integer;
  vertArray, texArray: PGLfloatArray;
  idxArray: PGLushortArray;
  x, y, vertIdx, texIdx: Integer;
  x1, y1, x2, y2: Single;
  newY1, newY2: Single;
begin
  width := m_pTexture.PixelsWide;
  height := m_pTexture.PixelsHigh;
  imageH := m_pTexture.getContentSizeInPixels().height;

  numQuads := Floor(m_sGridSize.width * m_sGridSize.height);

  CC_SAFE_FREE_POINTER(m_pTexCoordinates);
  CC_SAFE_FREE_POINTER(m_pVertices);
  CC_SAFE_FREE_POINTER(m_pIndices);
  CC_SAFE_FREE_POINTER(m_pOriginalVertices);

  m_pVertices := AllocMem(SizeOf(ccVertex3f) * numQuads * 4);
  m_pOriginalVertices := AllocMem(SizeOf(ccVertex3f) * numQuads * 4);
  m_pTexCoordinates := AllocMem(SizeOf(ccVertex2f) * numQuads * 4);
  m_pIndices := AllocMem(SizeOf(GLushort) * numQuads * 6);

  vertArray := PGLfloatArray(m_pVertices);
  texArray := PGLfloatArray(m_pTexCoordinates);
  idxArray := m_pIndices;

  vertIdx := 0;
  texIdx := 0;
  for x := 0 to Floor(m_sGridSize.width)-1 do
  begin
    for y := 0 to Floor(m_sGridSize.height)-1 do
    begin
      x1 := x * m_obStep.x;
      x2 := x1 + m_obStep.x;
      y1 := y * m_obStep.y;
      y2 := y1 + m_obStep.y;

      vertArray[vertIdx + 0]  := x1;
      vertArray[vertIdx + 1]  := y1;
      vertArray[vertIdx + 2]  := 0;
      vertArray[vertIdx + 3]  := x2;
      vertArray[vertIdx + 4]  := y1;
      vertArray[vertIdx + 5]  := 0;
      vertArray[vertIdx + 6]  := x1;
      vertArray[vertIdx + 7]  := y2;
      vertArray[vertIdx + 8]  := 0;
      vertArray[vertIdx + 9]  := x2;
      vertArray[vertIdx + 10] := y2;
      vertArray[vertIdx + 11] := 0;

      Inc(vertIdx, 12);

      newY1 := y1;
      newY2 := y2;

      if m_bIsTextureFlipped then
      begin
        newY1 := imageH - y1;
        newY2 := imageH - y2;
      end;

      texArray[texIdx + 0] := x1/width;
      texArray[texIdx + 1] := newY1/height;
      texArray[texIdx + 2] := x2/width;
      texArray[texIdx + 3] := newY1/height;
      texArray[texIdx + 4] := x1/width;
      texArray[texIdx + 5] := newY2/height;
      texArray[texIdx + 6] := x2/width;
      texArray[texIdx + 7] := newY2/height;

      Inc(texIdx, 8);
    end;  
  end;

  for x := 0 to numQuads-1 do
  begin
    idxArray[x*6 + 0] := x * 4 + 0;
    idxArray[x*6 + 1] := x * 4 + 1;
    idxArray[x*6 + 2] := x * 4 + 2;

    idxArray[x*6 + 3] := x * 4 + 1;
    idxArray[x*6 + 4] := x * 4 + 2;
    idxArray[x*6 + 5] := x * 4 + 3;
  end;

  Move(m_pVertices^, m_pOriginalVertices^, numQuads * 12 * SizeOf(GLfloat));
end;

constructor CCTiledGrid3D.Create;
begin
  inherited Create();
end;

destructor CCTiledGrid3D.Destroy;
begin
  CC_SAFE_FREE_POINTER(m_pTexCoordinates);
  CC_SAFE_FREE_POINTER(m_pVertices);
  CC_SAFE_FREE_POINTER(m_pIndices);
  CC_SAFE_FREE_POINTER(m_pOriginalVertices);
  inherited;
end;

function CCTiledGrid3D.originalTile(const pos: CCPoint): ccQuad3;
var
  idx: Integer;
  vertArray: PGLfloatArray;
  ret: ccQuad3;
begin
  idx := Round((m_sGridSize.height * pos.x + pos.y) * 4 * 3);
  vertArray := PGLfloatArray(m_pOriginalVertices);
  Move(vertArray[idx], ret, SizeOf(ccQuad3));
  Result := ret;
end;

procedure CCTiledGrid3D.reuse;
var
  numQuads: Integer;
begin
  if m_nReuseGrid > 0 then
  begin
    numQuads := Floor(m_sGridSize.width * m_sGridSize.height);
    Move(m_pVertices^, m_pOriginalVertices^, numQuads * 12 * SizeOf(GLfloat));
    Dec(m_nReuseGrid);
  end;  
end;

procedure CCTiledGrid3D.setTile(const pos: CCPoint;
  const coords: ccQuad3);
var
  idx: Integer;
  vertArray: PGLfloatArray;
begin
  idx := Round((m_sGridSize.height * pos.x + pos.y) * 4 * 3);
  vertArray := PGLfloatArray(m_pVertices);
  Move(coords, vertArray[idx], SizeOf(ccQuad3));
end;

function CCTiledGrid3D.tile(const pos: CCPoint): ccQuad3;
var
  idx: Integer;
  vertArray: PGLfloatArray;
  ret: ccQuad3;
begin
  idx := Round((m_sGridSize.height * pos.x + pos.y) * 4 * 3);
  vertArray := PGLfloatArray(m_pVertices);
  Move(vertArray[idx], ret, SizeOf(ccQuad3));
  Result := ret;
end;

end.
