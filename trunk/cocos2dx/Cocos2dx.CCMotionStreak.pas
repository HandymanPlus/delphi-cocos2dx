(****************************************************************************
Copyright (c) 2010-2012  cocos2d-x.org
Copyright (c) 2011 ForzeField Studios S.L.

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

unit Cocos2dx.CCMotionStreak;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCNode, Cocos2dx.CCTexture2D, Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

type
  CCMotionStreak = class(CCNodeRGBA)
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(fade, minSeg, stroke: Single; const color: ccColor3B; const path: string): CCMotionStreak; overload;
    class function _create(fade, minSeg, stroke: Single; const color: ccColor3B; texture: CCTexture2D): CCMotionStreak; overload;
    function initWithFade(fade, minSeg, stroke: Single; const color: ccColor3B; const path: string): Boolean; overload;
    function initWithFade(fade, minSeg, stroke: Single; const color: ccColor3B; texture: CCTexture2D): Boolean; overload;
    procedure tintWithColor(colors: ccColor3B);
    procedure reset();
    procedure update(time: Single); override;
    procedure draw(); override;
    procedure setPosition(const newPosition: CCPoint); override;

    function getTexture(): CCTexture2D; override;
    procedure setTexture(texture: CCTexture2D); override;
    //
    procedure setBlendFunc(blendFunc: ccBlendFunc); override;
    function getBlendFunc(): ccBlendFunc; override;

    function isFastMode(): Boolean;
    procedure setFastMode(bFastMode: Boolean);

    function isStartingPositionInitialized(): Boolean;
    procedure setStartingPositionInitialized(bStartingPositionInitialized: Boolean);
  protected
    m_bFastMode: Boolean;
    m_bStartingPositionInitialized: Boolean;
  private
    m_pTexture: CCTexture2D;
    m_tBlendFunc: ccBlendFunc;
    m_tPositionR: CCPoint;

    m_fStroke: Single;
    m_fFadeDelta: Single;
    m_fMinSeg: Single;

    m_uMaxPoints: Cardinal;
    m_uNuPoints: Cardinal;
    m_uPerviousNuPoints: Cardinal;

    m_pPointVertexes: array of CCPoint;
    m_pPointState: array of Single;

    m_pVertices: array of ccVertex2F;
    m_pColorPointer: array of GLubyte;
    m_pTexCoords: array of ccTex2F;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCTextureCache, Cocos2dx.CCGLProgram, Cocos2dx.CCShaderCache,
  Cocos2dx.CCPointExtension, Cocos2dx.CCVertex, Cocos2dx.CCGLStateCache, Cocos2dx.CCMacros;

{ CCMotionStreak }

class function CCMotionStreak._create(fade, minSeg, stroke: Single;
  const color: ccColor3B; texture: CCTexture2D): CCMotionStreak;
var
  pRet: CCMotionStreak;
begin
  pRet := CCMotionStreak.Create();
  if (pRet <> nil) and pRet.initWithFade(fade, minSeg, stroke, color, texture) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCMotionStreak._create(fade, minSeg, stroke: Single;
  const color: ccColor3B; const path: string): CCMotionStreak;
var
  pRet: CCMotionStreak;
begin
  pRet := CCMotionStreak.Create();
  if (pRet <> nil) and pRet.initWithFade(fade, minSeg, stroke, color, path) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCMotionStreak.Create;
begin
  inherited Create();
  m_tBlendFunc.src := GL_SRC_ALPHA;
  m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;
end;

destructor CCMotionStreak.Destroy;
begin
  CC_SAFE_RELEASE(m_pTexture);
  m_pPointState := nil;
  m_pPointVertexes := nil;
  m_pVertices := nil;
  m_pColorPointer := nil;
  m_pTexCoords := nil;
  inherited;
end;

procedure CCMotionStreak.draw;
begin
  if m_uNuPoints <= 1 then
    Exit;

  CC_NODE_DRAW_SETUP();

  ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
  ccGLBlendFunc(m_tBlendFunc.src, m_tBlendFunc.dst);

  ccGLBindTexture2D(m_pTexture.Name);

  glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, @m_pVertices[0]);
  glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, @m_pTexCoords[0]);
  glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, @m_pColorPointer[0]);

  glDrawArrays(GL_TRIANGLE_STRIP, 0, m_uNuPoints * 2);

  CC_INCREMENT_GL_DRAWS(1);
end;

function CCMotionStreak.getBlendFunc: ccBlendFunc;
begin
  Result := m_tBlendFunc;
end;

function CCMotionStreak.getTexture: CCTexture2D;
begin
  Result := m_pTexture;
end;

function CCMotionStreak.initWithFade(fade, minSeg, stroke: Single;
  const color: ccColor3B; const path: string): Boolean;
var
  texture: CCTexture2D;
begin
  CCAssert(path <> '', 'Invalid filename');
  texture := CCTextureCache.sharedTextureCache().addImage(path);
  Result := initWithFade(fade, minSeg, stroke, color, texture);
end;

function CCMotionStreak.initWithFade(fade, minSeg, stroke: Single;
  const color: ccColor3B; texture: CCTexture2D): Boolean;
begin
  setPosition(CCPointZero);
  setAnchorPoint(CCPointZero);
  ignoreAnchorPointForPosition(True);
  m_bStartingPositionInitialized := False;

  m_tPositionR := CCPointZero;
  m_bFastMode := True;
  if minSeg = -1.0 then
    m_fMinSeg := stroke/5.0
  else
    m_fMinSeg := minSeg;
  m_fMinSeg := m_fMinSeg * m_fMinSeg;

  m_fStroke := stroke;
  m_fFadeDelta := 1.0/fade;

  m_uMaxPoints := Round(fade * 60.0) + 2;
  m_uNuPoints := 0;
  SetLength(m_pPointState, m_uMaxPoints);
  SetLength(m_pPointVertexes, m_uMaxPoints);

  SetLength(m_pVertices, m_uMaxPoints * 2);
  SetLength(m_pTexCoords, m_uMaxPoints * 2);
  SetLength(m_pColorPointer, m_uMaxPoints * 2 * 4);

  m_tBlendFunc.src := GL_SRC_ALPHA;
  m_tBlendFunc.dst := GL_ONE_MINUS_SRC_ALPHA;

  setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColor));

  setTexture(texture);
  setColor(color);
  scheduleUpdate();

  Result := True;
end;

function CCMotionStreak.isStartingPositionInitialized: Boolean;
begin
  Result := m_bStartingPositionInitialized;
end;

procedure CCMotionStreak.reset;
begin
  m_uNuPoints := 0;
end;

procedure CCMotionStreak.setBlendFunc(blendFunc: ccBlendFunc);
begin
  m_tBlendFunc := blendFunc;
end;

procedure CCMotionStreak.setPosition(const newPosition: CCPoint);
begin
  m_bStartingPositionInitialized := True;
  m_tPositionR := newPosition;
end;

procedure CCMotionStreak.setStartingPositionInitialized(
  bStartingPositionInitialized: Boolean);
begin
  m_bStartingPositionInitialized := bStartingPositionInitialized;
end;

procedure CCMotionStreak.setTexture(texture: CCTexture2D);
begin
  if m_pTexture <> texture then
  begin
    CC_SAFE_RETAIN(texture);
    CC_SAFE_RELEASE(m_pTexture);
    m_pTexture := texture;
  end;  
end;

procedure CCMotionStreak.tintWithColor(colors: ccColor3B);
var
  i: Cardinal;
begin
  setColor(colors);
  if m_uNuPoints > 0 then
    for i := 0 to m_uNuPoints*2 - 1 do
      pccColor3B(@m_pColorPointer[i*4])^ := colors;
end;

procedure CCMotionStreak.update(time: Single);
var
  newIdx, newIdx2, i, i2: Cardinal;
  mov: Cardinal;
  op: GLubyte;
  appendNewPoint: Boolean;
  a1, a2: Boolean;
  offset: Cardinal;
  texDelta: Single;
begin
  if not m_bStartingPositionInitialized then
    Exit;

  time := time * m_fFadeDelta;
  mov := 0;
  
  if m_uNuPoints > 0 then
    for i := 0 to m_uNuPoints-1 do
    begin
      m_pPointState[i] := m_pPointState[i] - time;
      if m_pPointState[i] <= 0 then
      begin
        Inc(mov);
      end else
      begin
        newIdx := i - mov;
        if mov > 0 then
        begin
          m_pPointState[newIdx] := m_pPointState[i];

          m_pPointVertexes[newIdx] := m_pPointVertexes[i];

          i2 := i * 2;
          newIdx2 := newIdx * 2;
          m_pVertices[newIdx2] := m_pVertices[i2];
          m_pVertices[newIdx2 + 1] := m_pVertices[i2 + 1];

          i2 := i2 * 4;
          newIdx2 := newIdx2 * 4;
          m_pColorPointer[newIdx2 + 0] := m_pColorPointer[i2 + 0];
          m_pColorPointer[newIdx2 + 1] := m_pColorPointer[i2 + 1];
          m_pColorPointer[newIdx2 + 2] := m_pColorPointer[i2 + 2];
          m_pColorPointer[newIdx2 + 4] := m_pColorPointer[i2 + 4];
          m_pColorPointer[newIdx2 + 5] := m_pColorPointer[i2 + 5];
          m_pColorPointer[newIdx2 + 6] := m_pColorPointer[i2 + 6];
        end else
        begin
          newIdx2 := newIdx * 8;
        end;

        op := Round(m_pPointState[newIdx] * 255.0);
        m_pColorPointer[newIdx2 + 3] := op;
        m_pColorPointer[newIdx2 + 7] := op;
      end;    
    end;

  m_uNuPoints := m_uNuPoints - mov;
  appendNewPoint := True;
  if m_uNuPoints >= m_uMaxPoints then
  begin
    appendNewPoint := False;
  end else if m_uNuPoints > 0 then
  begin
    a1 := ccpDistanceSQ(m_pPointVertexes[m_uNuPoints - 1], m_tPositionR) < m_fMinSeg;
    if m_uNuPoints = 1 then
      a2 := False
    else
      a2 := ccpDistanceSQ(m_pPointVertexes[m_uNuPoints - 2], m_tPositionR) < (m_fMinSeg * 2.0);

    if a1 or a2 then
    begin
      appendNewPoint := False;
    end;  
  end;

  if appendNewPoint then
  begin
    m_pPointVertexes[m_uNuPoints] := m_tPositionR;
    m_pPointState[m_uNuPoints] := 1.0;

    offset := m_uNuPoints * 8;
    pccColor3B(@m_pColorPointer[offset])^ := _displayedColor;
    pccColor3B(@m_pColorPointer[offset + 4])^ := _displayedColor;

    m_pColorPointer[offset + 3] := 255;
    m_pColorPointer[offset + 7] := 255;

    if (m_uNuPoints > 0) and m_bFastMode then
    begin
      if m_uNuPoints > 1 then
        ccVertexLineToPolygon(@m_pPointVertexes[0], m_fStroke, @m_pVertices[0], m_uNuPoints, 1)
      else
        ccVertexLineToPolygon(@m_pPointVertexes[0], m_fStroke, @m_pVertices[0], 0, 2);
    end;
    Inc(m_uNuPoints); 
  end;

  if not m_bFastMode then
  begin
    ccVertexLineToPolygon(@m_pPointVertexes[0], m_fStroke, @m_pVertices[0], 0, m_uNuPoints);
  end;

  if (m_uNuPoints > 0) and (m_uPerviousNuPoints <> m_uNuPoints) then
  begin
    texDelta := 1.0/m_uNuPoints;
    for i := 0 to m_uNuPoints-1 do
    begin
      m_pTexCoords[i * 2] := tex2(0, texDelta * i);
      m_pTexCoords[i * 2 + 1] := tex2(1, texDelta * i);
    end;
    m_uPerviousNuPoints := m_uNuPoints;
  end;  
end;

function CCMotionStreak.isFastMode: Boolean;
begin
  Result := m_bFastMode;
end;

procedure CCMotionStreak.setFastMode(bFastMode: Boolean);
begin
  m_bFastMode := bFastMode;
end;

end.
