(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada

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

unit Cocos2dx.CCLabelTTF;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCSprite, Cocos2dx.CCGeometry, Cocos2dx.CCTypes;

type
  (** @brief CCLabelTTF is a subclass of CCTextureNode that knows how to render text labels
   *
   * All features from CCTextureNode are valid in CCLabelTTF
   *
   * CCLabelTTF objects are slow. Consider using CCLabelAtlas or CCLabelBMFont instead.
   *
   * Custom ttf file can be put in assets/ or external storage that the Application can access.
   * @code
   * CCLabelTTF *label1 = CCLabelTTF::create("alignment left", "A Damn Mess", fontSize, blockSize,
   *                                          kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter);
   * CCLabelTTF *label2 = CCLabelTTF::create("alignment right", "/mnt/sdcard/Scissor Cuts.ttf", fontSize, blockSize,
   *                                          kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter);
   * @endcode
   *
   *)
  CCLabelTTF = class(CCSprite{, CCLabelProtocol})
  private
    function updateTexture(): Boolean;
  protected
    m_shadowEnabled: Boolean;
    m_shadowoffset: CCSize;
    m_shadowOpacity: Single;
    m_shadowBlur: Single;
    m_strokeEnabled: Boolean;
    m_strokeColor: ccColor3B;
    m_strokeSize: Single;
    m_textFillColor: ccColor3B;
    m_tDimensions: CCSize;
    m_hAlignment: CCTextAlignment;
    m_vAlignment: CCVerticalTextAlignment;
    m_fFontSize: Single;
    m_string: string;
    m_pFontName: string;
    procedure _updateWithTextDefinition(const textDefinition: ccFontDefinition;
      mustUpdateTexture: Boolean = True);
    function _prepareTextDefinition(adjustForResolution: Boolean = False): ccFontDefinition;
  public
    constructor Create();
    destructor Destroy(); override;
    //interface
    (** changes the string to render
    * @warning Changing the string is as expensive as creating a new CCLabelTTF. To obtain better performance use CCLabelAtlas
    *)
    procedure setString(const slabel: string); override;
    function getString(): string; override;
    //
    function description(): string;
    class function _create(): CCLabelTTF; overload;
    class function _create(const str: string; const fontName: string; fontSize: Single): CCLabelTTF; overload;
    class function _create(const str: string; const fontName: string; fontSize: Single;
      const dimensions: CCSize; hAlignment: CCTextAlignment): CCLabelTTF; overload;
    class function _create(const str: string; const fontName: string; fontSize: Single;
      const dimensions: CCSize; hAlignment: CCTextAlignment;
      vAlignment: CCVerticalTextAlignment): CCLabelTTF; overload;
    class function createWithFontDefinition(const str: string; const textDefinition: ccFontDefinition): CCLabelTTF;
    function initWithString(const str: string; const fontName: string; fontSize: Single): Boolean; overload;
    function initWithString(const str: string; const fontName: string; fontSize: Single;
      const dimensions: CCSize; hAlignment: CCTextAlignment): Boolean; overload;
    function initWithString(const str: string; const fontName: string; fontSize: Single;
      const dimensions: CCSize; hAlignment: CCTextAlignment;
      vAlignment: CCVerticalTextAlignment): Boolean; overload;
    function initWithStringAndTextDefinition(const str: string; const textDefinition: ccFontDefinition): Boolean;
    procedure setTextDefinition(theDefinition: pccFontDefinition);
    function getTextDefinition(): pccFontDefinition;
    function init(): Boolean; override;

    function getHorizontalAlignment(): CCTextAlignment;
    procedure setHorizontalAlignment(alignment: CCTextAlignment);

    function getVerticalAlignment(): CCVerticalTextAlignment;
    procedure setVerticalAlignment(verticalAlignment: CCVerticalTextAlignment);

    function getDimensions(): CCSize;
    procedure setDimensions(const dim: CCSize);

    function getFontSize(): Single;
    procedure setFontSize(fontSize: Single);

    function getFontName(): string;
    procedure setFontName(const fontName: string);

    procedure enableShadow(const shadowOffset: CCSize; shadowOpacity: Single; shadowBlur: Single; mustUpdateTexture: Boolean = True);
    procedure disableShadow(mustUpdateTexture: Boolean = True);

    procedure enableStroke(const strokeColor: ccColor3B; strokeSize: Single; mustUpdateTexture: Boolean = True);
    procedure disableStroke(mustUpdateTexture: Boolean = True);

    procedure setFontFillColor(const tintColor: ccColor3B; mustUpdateTexture: Boolean = True);
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCShaderCache, Cocos2dx.CCGLProgram,
  Cocos2dx.CCString, Cocos2dx.CCTexture2D, Cocos2dx.CCMacros;

{ CCLabelTTF }

const SHADER_PROGRAM = kCCShader_PositionTextureColor;

constructor CCLabelTTF.Create;
begin
  inherited Create();
  m_hAlignment := kCCTextAlignmentCenter;
  m_vAlignment := kCCVerticalTextAlignmentTop;
  m_textFillColor := ccWHITE;
  {m_pFontName := '';
  m_fFontSize := 0;
  m_string := '';}
end;

function CCLabelTTF.description: string;
begin
  Result :=  CCString.createWithFormat('<CCLabelTTF | FontName = %s, FontSize = %.1f>', [m_pFontName, m_fFontSize]).m_sString;
end;

destructor CCLabelTTF.Destroy;
begin

  inherited;
end;

function CCLabelTTF.getDimensions: CCSize;
begin
  Result := m_tDimensions;
end;

function CCLabelTTF.getFontName: string;
begin
  Result := m_pFontName;
end;

function CCLabelTTF.getFontSize: Single;
begin
  Result := m_fFontSize;
end;

function CCLabelTTF.getHorizontalAlignment: CCTextAlignment;
begin
  Result := m_hAlignment;
end;

function CCLabelTTF.getString: string;
begin
  Result := m_string;
end;

function CCLabelTTF.getVerticalAlignment: CCVerticalTextAlignment;
begin
  Result := m_vAlignment;
end;

function CCLabelTTF.init: Boolean;
begin
  Result := Self.initWithString('', 'Helvetica', 12);
end;

function CCLabelTTF.initWithString(const str, fontName: string;
  fontSize: Single; const dimensions: CCSize;
  hAlignment: CCTextAlignment): Boolean;
begin
  Result := Self.initWithString(str, fontName, fontSize, dimensions, hAlignment, kCCVerticalTextAlignmentTop);
end;

function CCLabelTTF.initWithString(const str, fontName: string;
  fontSize: Single; const dimensions: CCSize; hAlignment: CCTextAlignment;
  vAlignment: CCVerticalTextAlignment): Boolean;
begin
  if inherited init() then
  begin
    Self.setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(SHADER_PROGRAM));

    m_tDimensions := CCSizeMake(dimensions.width, dimensions.height);
    m_hAlignment := hAlignment;
    m_vAlignment := vAlignment;
    m_pFontName := fontName;
    m_fFontSize := fontSize;
    Self.setString(str);

    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCLabelTTF.initWithString(const str, fontName: string;
  fontSize: Single): Boolean;
begin
  Result := Self.initWithString(str, fontName, fontSize, CCSizeZero,
    kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop);
end;

procedure CCLabelTTF.setDimensions(const dim: CCSize);
begin
  if (dim.width <> m_tDimensions.width) or (dim.height <> m_tDimensions.height) then
  begin
    m_tDimensions := dim;
    if Length(m_string) > 0 then
      Self.updateTexture();
  end;  
end;

procedure CCLabelTTF.setFontName(const fontName: string);
begin
  if m_pFontName <> fontName then
  begin
    m_pFontName := fontName;
    if Length(m_string) > 0 then
      Self.updateTexture();
  end;  
end;

procedure CCLabelTTF.setFontSize(fontSize: Single);
begin
  if m_fFontSize <> fontSize then
  begin
    m_fFontSize := fontSize;
    if Length(m_string) > 0 then
      Self.updateTexture();
  end;  
end;

procedure CCLabelTTF.setHorizontalAlignment(alignment: CCTextAlignment);
begin
  if alignment <> m_hAlignment then
  begin
    m_hAlignment := alignment;

    if Length(m_string) > 0 then
      Self.updateTexture();
  end;  
end;

procedure CCLabelTTF.setString(const slabel: string);
begin
  m_string := slabel;
  Self.updateTexture();
end;

class function CCLabelTTF._create: CCLabelTTF;
var
  pRet: CCLabelTTF;
begin
  pRet := CCLabelTTF.Create();
  if (pRet <> nil) and pRet.init() then
    pRet.autorelease()
  else
    CC_SAFE_DELETE(pRet);

  Result := pRet;
end;

class function CCLabelTTF._create(const str, fontName: string;
  fontSize: Single; const dimensions: CCSize;
  hAlignment: CCTextAlignment): CCLabelTTF;
begin
  Result := Self._create(str, fontName, fontSize, dimensions, hAlignment, kCCVerticalTextAlignmentTop);
end;

class function CCLabelTTF._create(const str, fontName: string;
  fontSize: Single; const dimensions: CCSize; hAlignment: CCTextAlignment;
  vAlignment: CCVerticalTextAlignment): CCLabelTTF;
var
  pRet: CCLabelTTF;
begin
  pRet := CCLabelTTF.Create();
  if (pRet <> nil) and pRet.initWithString(str, fontName, fontSize, dimensions, hAlignment, vAlignment) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCLabelTTF._create(const str, fontName: string;
  fontSize: Single): CCLabelTTF;
begin
  Result := Self._create(str, fontName, fontSize, CCSizeZero, kCCTextAlignmentCenter,
    kCCVerticalTextAlignmentTop);
end;

procedure CCLabelTTF.setVerticalAlignment(
  verticalAlignment: CCVerticalTextAlignment);
begin
  if m_vAlignment <> verticalAlignment then
  begin
    m_vAlignment := verticalAlignment;

    if Length(m_string) > 0 then
      Self.updateTexture();
  end;  
end;

function CCLabelTTF.updateTexture: Boolean;
var
  tex: CCTexture2D;
  rect: CCRect;
begin
  tex := CCTexture2D.Create;
  if tex = nil then
  begin
    Result := False;
    Exit;
  end;

  tex.initWithString(m_string, m_pFontName, m_fFontSize*CC_CONTENT_SCALE_FACTOR(),
    CC_SIZE_POINTS_TO_PIXELS(m_tDimensions), m_hAlignment, m_vAlignment);

  Self.setTexture(tex);
  tex.release();

  rect := CCRectZero;
  rect.size := m_pobTexture.getContentSize();
  Self.setTextureRect(rect);

  Result := True;
end;

function CCLabelTTF._prepareTextDefinition(
  adjustForResolution: Boolean): ccFontDefinition;
var
  texDef: ccFontDefinition;
begin
  if adjustForResolution then
    texDef.m_fontsize := Round(m_fFontSize * CC_CONTENT_SCALE_FACTOR())
  else
    texDef.m_fontsize := Round(m_fFontSize);

  texDef.m_fontName := m_pFontName;
  texDef.m_alignment := m_hAlignment;
  texDef.m_vertAlignment := m_vAlignment;

  if adjustForResolution then
    texDef.m_dimensions := CC_SIZE_POINTS_TO_PIXELS(m_tDimensions)
  else
    texDef.m_dimensions := m_tDimensions;

  if m_strokeEnabled then
  begin
    texDef.m_stroke.m_strokeEnabled := True;
    texDef.m_stroke.m_strokeColor := m_strokeColor;

    if adjustForResolution then
      texDef.m_stroke.m_strokeSize := m_strokeSize * CC_CONTENT_SCALE_FACTOR()
    else
      texDef.m_stroke.m_strokeSize := m_strokeSize;
  end else
  begin
    texDef.m_stroke.m_strokeEnabled := False;
  end;

  if m_shadowEnabled then
  begin
    texDef.m_shadow.m_shadowEnabled := True;
    texDef.m_shadow.m_shadowBlur := m_shadowBlur;
    texDef.m_shadow.m_shadowopacity := m_shadowOpacity;

    if adjustForResolution then
      texDef.m_shadow.m_shadowoffset := CC_SIZE_POINTS_TO_PIXELS(m_shadowoffset)
    else
      texDef.m_shadow.m_shadowoffset := m_shadowoffset;
  end else
  begin
    texDef.m_shadow.m_shadowEnabled := False;
  end;

  texDef.m_fontFillColor := m_textFillColor;

  Result := texDef;
end;

procedure CCLabelTTF._updateWithTextDefinition(
  const textDefinition: ccFontDefinition; mustUpdateTexture: Boolean);
begin
  m_tDimensions := CCSizeMake(textDefinition.m_dimensions.width, textDefinition.m_dimensions.height);
  m_hAlignment := textDefinition.m_alignment;
  m_vAlignment := textDefinition.m_vertAlignment;

  m_pFontName := textDefinition.m_fontName;
  m_fFontSize := textDefinition.m_fontsize;

  if textDefinition.m_shadow.m_shadowEnabled then
  begin
    enableShadow(textDefinition.m_shadow.m_shadowoffset, textDefinition.m_shadow.m_shadowopacity,
      textDefinition.m_shadow.m_shadowBlur, False);
  end;

  if textDefinition.m_stroke.m_strokeEnabled then
  begin
    enableStroke(textDefinition.m_stroke.m_strokeColor, textDefinition.m_stroke.m_strokeSize, False);
  end;

  setFontFillColor(textDefinition.m_fontFillColor, False);

  if mustUpdateTexture then
  begin
    updateTexture();
  end;  
end;

class function CCLabelTTF.createWithFontDefinition(const str: string;
  const textDefinition: ccFontDefinition): CCLabelTTF;
var
  pRet: CCLabelTTF;
begin
  pRet := CCLabelTTF.Create;
  if (pRet <> nil) and pRet.initWithStringAndTextDefinition(str, textDefinition) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCLabelTTF.disableShadow(mustUpdateTexture: Boolean);
begin

end;

procedure CCLabelTTF.disableStroke(mustUpdateTexture: Boolean);
begin

end;

procedure CCLabelTTF.enableShadow(const shadowOffset: CCSize;
  shadowOpacity, shadowBlur: Single; mustUpdateTexture: Boolean);
begin

end;

procedure CCLabelTTF.enableStroke(const strokeColor: ccColor3B;
  strokeSize: Single; mustUpdateTexture: Boolean);
begin

end;

function CCLabelTTF.getTextDefinition: pccFontDefinition;
var
  tempDefinition: pccFontDefinition;
begin
  tempDefinition := AllocMem(SizeOf(ccFontDefinition));
  tempDefinition^ := _prepareTextDefinition(False);
  Result := tempDefinition;
end;

function CCLabelTTF.initWithStringAndTextDefinition(const str: string;
  const textDefinition: ccFontDefinition): Boolean;
begin
  if inherited init() then
  begin
    setShaderProgram(CCShaderCache.sharedShaderCache().programForKey(SHADER_PROGRAM));
    _updateWithTextDefinition(textDefinition, False);
    setString(str);
    Result := True;
    Exit;
  end;
  
  Result := False;
end;

procedure CCLabelTTF.setFontFillColor(const tintColor: ccColor3B;
  mustUpdateTexture: Boolean);
begin

end;

procedure CCLabelTTF.setTextDefinition(theDefinition: pccFontDefinition);
begin
  if theDefinition <> nil then
  begin
    _updateWithTextDefinition(theDefinition^, True);
  end;  
end;

end.
