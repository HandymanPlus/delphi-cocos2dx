(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2010      Lam Pham

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

unit Cocos2dx.CCProgressTimer;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCNode, Cocos2dx.CCSprite, Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

type
  CCProgressTimerType = (kCCProgressTimerTypeRadial, kCCProgressTimerTypeBar);

  (**
   @brief CCProgressTimer is a subclass of CCNode.
   It renders the inner sprite according to the percentage.
   The progress can be Radial, Horizontal or vertical.
   @since v0.99.1
   *)
  CCProgressTimer = class(CCNodeRGBA)
  public
    constructor Create();
    destructor Destroy(); override;
    function getType(): CCProgressTimerType;
    function getPercentage(): Single;
    function getSprite(): CCSprite;
    function initWithSprite(sp: CCSprite): Boolean;
    procedure setPercentage(fPercentage: Single);
    procedure setSprite(pSprite: CCSprite);
    procedure setType(_type: CCProgressTimerType);
    procedure setReverseProgress(reverse: Boolean);
    procedure draw(); override;
    procedure setAnchorPoint(const Value: CCPoint); override;

    procedure setColor(const color: ccColor3B); override;
    function getColor(): ccColor3B; override;
    function getOpacity(): GLubyte; override;
    procedure setOpacity(opacity: GLubyte); override;

    function isReverseDirection(): Boolean;
    procedure setReverseDirection(value: Boolean);

    function getBarChangeRate: CCPoint;
    function getMidpoint: CCPoint;
    procedure setBarChangeRate(const Value: CCPoint);
    procedure setMidpoint(const midPoint: CCPoint);

    class function _create(sp: CCSprite): CCProgressTimer;
  protected
    function textureCoordFromAlphaPoint(alpha: CCPoint): ccTex2F;
    function vertexFromAlphaPoint(alpha: CCPoint): ccVertex2F;
    procedure updateProgress();
    procedure updateBar();
    procedure updateRadial();
    procedure updateColor();
    function boundaryTexCoord(index: Byte): CCPoint;
  protected
    m_eType: CCProgressTimerType;
    m_fPercentage: Single;
    m_pSprite: CCSprite;
    m_nVertexDataCount: Integer;
    m_pVertexData: ptccV2F_C4B_T2F;
    m_bReverseDirection: Boolean;
    m_tMidpoint: CCPoint;
    m_tBarChangeRate: CCPoint;
  public
    (**
     *    Midpoint is used to modify the progress start position.
     *    If you're using radials type then the midpoint changes the center point
     *    If you're using bar type the the midpoint changes the bar growth
     *        it expands from the center but clamps to the sprites edge so:
     *        you want a left to right then set the midpoint all the way to ccp(0,y)
     *        you want a right to left then set the midpoint all the way to ccp(1,y)
     *        you want a bottom to top then set the midpoint all the way to ccp(x,0)
     *        you want a top to bottom then set the midpoint all the way to ccp(x,1)
     *)
    property Midpoint: CCPoint read getMidpoint write setMidpoint;
    (**
     *    This allows the bar type to move the component at a specific rate
     *    Set the component to 0 to make sure it stays at 100%.
     *    For example you want a left to right bar but not have the height stay 100%
     *    Set the rate to be ccp(0,1); and set the midpoint to = ccp(0,.5f);
     *)
    property BarChangeRate: CCPoint read getBarChangeRate write setBarChangeRate;
  end;

implementation
uses
  SysUtils, Math,
  Cocos2dx.CCMacros, Cocos2dx.CCPointExtension, Cocos2dx.CCGLProgram,
  Cocos2dx.CCGLStateCache, Cocos2dx.CCShaderCache, Cocos2dx.CCPlatformMacros;


const kProgressTextureCoordsCount = 4;
const kCCProgressTextureCoords = $4B;

{ CCProgressTimer }

class function CCProgressTimer._create(sp: CCSprite): CCProgressTimer;
var
  pRet: CCProgressTimer;
begin
  pRet := CCProgressTimer.Create();
  if pRet.initWithSprite(sp) then
  begin
    pRet.autorelease();
  end else
  begin
    pRet.Free;
    pRet := nil;
  end;
  Result := pRet;
end;

function CCProgressTimer.boundaryTexCoord(index: Byte): CCPoint;
begin
  Result := CCPointZero;
  if index < kProgressTextureCoordsCount then
  begin
    if m_bReverseDirection then
    begin
      Result :=
                ccp((kCCProgressTextureCoords shr (7 - (index shl 1))) and $1,
                    (kCCProgressTextureCoords shr (7 - ((index shl 1) + 1))) and $1);
    end else
    begin
      Result :=
                ccp((kCCProgressTextureCoords shr ((index shl 1) + 1)) and 1,
                    (kCCProgressTextureCoords shr (index shl 1)) and $1);
    end;
  end;
end;

constructor CCProgressTimer.Create;
begin
  inherited Create();
  m_eType := kCCProgressTimerTypeRadial;
end;

destructor CCProgressTimer.Destroy;
begin
  CC_SAFE_FREE_POINTER(m_pVertexData);
  CC_SAFE_RELEASE(m_pSprite);
  inherited;
end;

procedure CCProgressTimer.draw;
begin
  if (m_pVertexData = nil) or (m_pSprite = nil) then
    Exit;

  CC_NODE_DRAW_SETUP();
  ccGLBlendFunc(m_pSprite.getBlendFunc().src, m_pSprite.getBlendFunc().dst);
  ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
  ccGLBindTexture2D(m_pSprite.getTexture().Name);

  glVertexAttribPointer( kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(m_pVertexData[0]) , @m_pVertexData[0].vertices);
  glVertexAttribPointer( kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(m_pVertexData[0]), @m_pVertexData[0].texCoords);
  glVertexAttribPointer( kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(m_pVertexData[0]), @m_pVertexData[0].colors);

  if m_eType = kCCProgressTimerTypeRadial then
  begin
    glDrawArrays(GL_TRIANGLE_FAN, 0, m_nVertexDataCount);
  end else if m_eType = kCCProgressTimerTypeBar then
  begin
    if not m_bReverseDirection then
    begin
      glDrawArrays(GL_TRIANGLE_STRIP, 0, m_nVertexDataCount);
    end else
    begin
      glDrawArrays(GL_TRIANGLE_STRIP, 0, m_nVertexDataCount div 2);
      glDrawArrays(GL_TRIANGLE_STRIP, 4, m_nVertexDataCount div 2);
      CC_INCREMENT_GL_DRAWS(1);
    end;
  end;
  CC_INCREMENT_GL_DRAWS(1);
end;

function CCProgressTimer.getBarChangeRate: CCPoint;
begin
  Result := m_tBarChangeRate;
end;

function CCProgressTimer.getColor: ccColor3B;
begin
  Result := m_pSprite.getColor();
end;

function CCProgressTimer.getMidpoint: CCPoint;
begin
  Result := m_tMidpoint;
end;

function CCProgressTimer.getOpacity: GLubyte;
begin
  Result := m_pSprite.getOpacity();
end;

function CCProgressTimer.getPercentage: Single;
begin
  Result := m_fPercentage;
end;

function CCProgressTimer.getSprite: CCSprite;
begin
  Result := m_pSprite;
end;

function CCProgressTimer.getType: CCProgressTimerType;
begin
  Result := m_eType;
end;

function CCProgressTimer.initWithSprite(sp: CCSprite): Boolean;
begin
  setPercentage(0);
  m_pVertexData := nil;
  m_nVertexDataCount := 0;

  setAnchorPoint(ccp(0.5, 0.5));
  m_eType := kCCProgressTimerTypeRadial;
  m_bReverseDirection := False;
  setMidpoint(ccp(0.5, 0.5));
  setBarChangeRate(ccp(1, 1));
  setSprite(sp);
  setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(kCCShader_PositionTextureColor));
  Result := True;  
end;

function CCProgressTimer.isReverseDirection: Boolean;
begin
  Result := m_bReverseDirection;
end;

procedure CCProgressTimer.setAnchorPoint(const Value: CCPoint);
begin
  inherited setAnchorPoint(Value);
end;

procedure CCProgressTimer.setBarChangeRate(const Value: CCPoint);
begin
  m_tBarChangeRate := Value;
end;

procedure CCProgressTimer.setColor(const color: ccColor3B);
begin
  m_pSprite.setColor(color);
  updateColor();
end;

procedure CCProgressTimer.setMidpoint(const midPoint: CCPoint);
begin
  m_tMidpoint := ccpClamp(midPoint, CCPointZero, ccp(1, 1));
end;

procedure CCProgressTimer.setOpacity(opacity: GLubyte);
begin
  m_pSprite.setOpacity(opacity);
  updateColor();
end;

procedure CCProgressTimer.setPercentage(fPercentage: Single);
begin
  if m_fPercentage <> fPercentage then
  begin
    m_fPercentage := clampf(fPercentage, 0, 100);
    updateProgress();
  end;  
end;

procedure CCProgressTimer.setReverseDirection(value: Boolean);
begin
  m_bReverseDirection := value;
end;

procedure CCProgressTimer.setReverseProgress(reverse: Boolean);
begin
  if m_bReverseDirection <> reverse then
  begin
    m_bReverseDirection := reverse;
    CC_SAFE_FREE_POINTER_NULL(Pointer(m_pVertexData));
    m_nVertexDataCount := 0;
  end;  
end;

procedure CCProgressTimer.setSprite(pSprite: CCSprite);
begin
  if m_pSprite <> pSprite then
  begin
    CC_SAFE_RETAIN(pSprite);
    CC_SAFE_RELEASE(m_pSprite);
    m_pSprite := pSprite;
    setContentSize(m_pSprite.ContentSize);

    if m_pVertexData <> nil then
    begin
      CC_SAFE_FREE_POINTER_NULL(Pointer(m_pVertexData));
      m_nVertexDataCount := 0;
    end;  
  end;  
end;

procedure CCProgressTimer.setType(_type: CCProgressTimerType);
begin
  if _type <> m_eType then
  begin
    if m_pVertexData <> nil then
    begin
      CC_SAFE_FREE_POINTER_NULL(Pointer(m_pVertexData));
      m_nVertexDataCount := 0;
    end;
    m_eType := _type;
  end;  
end;

function CCProgressTimer.textureCoordFromAlphaPoint(
  alpha: CCPoint): ccTex2F;
var
  ret: ccTex2F;
  quad: ccV3F_C4B_T2F_Quad;
  min, max: CCPoint;
  temp: Single;
begin
  ret.u := 0; ret.v := 0;

  quad := m_pSprite.getQuad();
  min := ccp(quad.bl.texCoords.u, quad.bl.texCoords.v);
  max := ccp(quad.tr.texCoords.u, quad.tr.texCoords.v);

  if m_pSprite.isTextureRectRotated() then
  begin
    temp := alpha.x;
    alpha.x := alpha.y;
    alpha.y := temp;
  end;

  Result := tex2(min.x * (1.0 - alpha.x) + max.x * alpha.x, min.y * (1.0 - alpha.y) + max.y * alpha.y );
end;

procedure CCProgressTimer.updateBar;
var
  alpha: Single;
  alphaOffset, min, max: CCPoint;
begin
  if m_pSprite = nil then
    Exit;

  alpha := m_fPercentage/100.0;
  alphaOffset := ccpMult( ccp(1.0 * (1.0 - m_tBarChangeRate.x) + alpha * m_tBarChangeRate.x, 1.0 * (1.0 - m_tBarChangeRate.y) + alpha * m_tBarChangeRate.y ), 0.5 );
  min := ccpSub(m_tMidpoint, alphaOffset);
  max := ccpAdd(m_tMidpoint, alphaOffset);

  if min.x < 0 then
  begin
    max.x := max.x - min.x;
    min.x := 0.0;
  end;

  if max.x > 1 then
  begin
    min.x := min.x - (max.x - 1.0);
    max.x := 1.0;
  end;

  if min.y < 0 then
  begin
    max.y := max.y - min.y;
    min.y := 0.0;
  end;

  if max.y > 1 then
  begin
    min.y := min.y - (max.y - 1.0);
    max.y := 1.0;
  end;

  if not m_bReverseDirection then
  begin
    if m_pVertexData = nil then
    begin
      m_nVertexDataCount := 4;
      m_pVertexData := AllocMem(SizeOf(ccV2F_C4B_T2F) * m_nVertexDataCount);
    end;

    m_pVertexData[0].texCoords := textureCoordFromAlphaPoint(ccp(min.x, max.y));
    m_pVertexData[0].vertices := vertexFromAlphaPoint(ccp(min.x, max.y));

    m_pVertexData[1].texCoords := textureCoordFromAlphaPoint(ccp(min.x, min.y));
    m_pVertexData[1].vertices := vertexFromAlphaPoint(ccp(min.x, min.y));

    m_pVertexData[2].texCoords := textureCoordFromAlphaPoint(ccp(max.x, max.y));
    m_pVertexData[2].vertices := vertexFromAlphaPoint(ccp(max.x, max.y));

    m_pVertexData[3].texCoords := textureCoordFromAlphaPoint(ccp(max.x, min.y));
    m_pVertexData[3].vertices := vertexFromAlphaPoint(ccp(max.x, min.y));
  end else
  begin
    if m_pVertexData = nil then
    begin
      m_nVertexDataCount := 8;
      m_pVertexData := AllocMem(SizeOf(ccV2F_C4B_T2F) * m_nVertexDataCount);

      m_pVertexData[0].texCoords := textureCoordFromAlphaPoint(ccp(0, 1));
      m_pVertexData[0].vertices := vertexFromAlphaPoint(ccp(0, 1));

      m_pVertexData[1].texCoords := textureCoordFromAlphaPoint(ccp(0, 0));
      m_pVertexData[1].vertices := vertexFromAlphaPoint(ccp(0, 0));

      m_pVertexData[6].texCoords := textureCoordFromAlphaPoint(ccp(1, 1));
      m_pVertexData[6].vertices := vertexFromAlphaPoint(ccp(1, 1));

      m_pVertexData[7].texCoords := textureCoordFromAlphaPoint(ccp(1, 0));
      m_pVertexData[7].vertices := vertexFromAlphaPoint(ccp(1, 0));
    end;

    m_pVertexData[2].texCoords := textureCoordFromAlphaPoint(ccp(min.x, max.y));
    m_pVertexData[2].vertices := vertexFromAlphaPoint(ccp(min.x, max.y));

    m_pVertexData[3].texCoords := textureCoordFromAlphaPoint(ccp(min.x, min.y));
    m_pVertexData[3].vertices := vertexFromAlphaPoint(ccp(min.x, min.y));

    m_pVertexData[4].texCoords := textureCoordFromAlphaPoint(ccp(max.x, max.y));
    m_pVertexData[4].vertices := vertexFromAlphaPoint(ccp(max.x, max.y));

    m_pVertexData[5].texCoords := textureCoordFromAlphaPoint(ccp(max.x, min.y));
    m_pVertexData[5].vertices := vertexFromAlphaPoint(ccp(max.x, min.y));
  end;
  updateColor();
end;

procedure CCProgressTimer.updateColor;
var
  sc: ccColor4B;
  i: Integer;
begin
  if m_pSprite = nil then
    Exit;

  if (m_pVertexData <> nil) and (m_nVertexDataCount > 0) then
  begin
    sc := m_pSprite.getQuad().tl.colors;
    for i := 0 to m_nVertexDataCount-1 do
    begin
      m_pVertexData[i].colors := sc;
    end;  
  end;
end;

procedure CCProgressTimer.updateProgress;
begin
  case m_eType of
    kCCProgressTimerTypeRadial: updateRadial();
    kCCProgressTimerTypeBar:    updateBar();
  end;
end;

procedure CCProgressTimer.updateRadial;
var
  alpha, angle, min_t, s, t: Single;
  topMid, hit, percentagePt, edgePtA, edgePtB, alphaPoint: CCPoint;
  index, i, pIndex: Integer;
  sameIndexCount: Boolean;
begin
  if m_pSprite = nil then
    Exit;

  alpha := m_fPercentage/100.0;
  if m_bReverseDirection then
    angle := 2.0 * Pi * alpha
  else
    angle := 2.0 * pi * (1.0 - alpha);

  topMid := ccp(m_tMidpoint.x, 1.0);
  percentagePt := ccpRotateByAngle(topMid, m_tMidpoint, angle);

  hit := CCPointZero;
  index := 0;

  if IsZero(alpha) then
  begin
    hit := topMid;
    index := 0;
  end else if alpha = 1.0 then
  begin
    hit := topMid;
    index := 4;
  end else
  begin
    min_t := MaxSingle;
    for i := 0 to kProgressTextureCoordsCount do
    begin
      pIndex := (i + kProgressTextureCoordsCount - 1) mod kProgressTextureCoordsCount;

      edgePtA := boundaryTexCoord(i mod kProgressTextureCoordsCount);
      edgePtB := boundaryTexCoord(pIndex);

      if i = 0 then
        edgePtB := ccpLerp(edgePtA, edgePtB, 1 - m_tMidpoint.x)
      else if i = 4 then
        edgePtA := ccpLerp(edgePtA, edgePtB, 1 - m_tMidpoint.x);

      s := 0; t := 0;
      if ccpLineIntersect(edgePtA, edgePtB, m_tMidpoint, percentagePt, @s, @t) then
      begin
        if (i = 0) or (i = 4) then
        begin
          if not ( (0.0 <= s) and (s <= 1.0) ) then
            Continue;
        end;

        if t >= 0.0 then
        begin
          if t < min_t then
          begin
            min_t := t;
            index := i;
          end;
        end;
      end;
    end;
    hit := ccpAdd(m_tMidpoint, ccpMult(ccpSub(percentagePt, m_tMidpoint), min_t ));
  end;

  sameIndexCount := True;
  if m_nVertexDataCount <> index + 3 then
  begin
    sameIndexCount := False;
    CC_SAFE_FREE_POINTER_NULL(Pointer(m_pVertexData));
    m_nVertexDataCount := 0;
  end;

  if m_pVertexData = nil then
  begin
    m_nVertexDataCount := index + 3;
    m_pVertexData := AllocMem(SizeOf(ccV2F_C4B_T2F) * m_nVertexDataCount);
  end;
  updateColor();

  if not sameIndexCount then
  begin
    m_pVertexData[0].texCoords := textureCoordFromAlphaPoint(m_tMidpoint);
    m_pVertexData[0].vertices := vertexFromAlphaPoint(m_tMidpoint);

    m_pVertexData[1].texCoords := textureCoordFromAlphaPoint(topMid);
    m_pVertexData[1].vertices := vertexFromAlphaPoint(topMid);

    for i := 0 to index-1 do
    begin
      alphaPoint := boundaryTexCoord(i);
      m_pVertexData[i+2].texCoords := textureCoordFromAlphaPoint(alphaPoint);
      m_pVertexData[i+2].vertices := vertexFromAlphaPoint(alphaPoint);
    end;  
  end;
  m_pVertexData[m_nVertexDataCount-1].texCoords := textureCoordFromAlphaPoint(hit);
  m_pVertexData[m_nVertexDataCount-1].vertices := vertexFromAlphaPoint(hit);
end;

function CCProgressTimer.vertexFromAlphaPoint(alpha: CCPoint): ccVertex2F;
var
  ret: ccVertex2F;
  quad: ccV3F_C4B_T2F_Quad;
  min, max: CCPoint;
begin
  ret.x := 0; ret.y := 0;
  quad := m_pSprite.getQuad();
  min := ccp(quad.bl.vertices.x, quad.bl.vertices.y);
  max := ccp(quad.tr.vertices.x, quad.tr.vertices.y);
  ret.x := min.x * (1 - alpha.x) + max.x * alpha.x;
  ret.y := min.y * (1 - alpha.y) + max.y * alpha.y;
  Result := ret;
end;

end.
