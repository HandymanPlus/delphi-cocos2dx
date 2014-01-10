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

unit Cocos2dx.CCTypes;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCGeometry;

type
  (** RGB color composed of bytes 3 bytes
    @since v0.8
    *)
  ccColor3B = record
    r: GLubyte;
    g: GLubyte;
    b: GLubyte;
  end;
  pccColor3B = ^ccColor3B;

const ccWHITE:   ccColor3B = (r:255; g:255; b:255);
const ccYELLOW:  ccColor3B = (r:255; g:255; b:0);
const ccBLUE:    ccColor3B = (r:0;   g:0;   b:255);
const ccGREEN:   ccColor3B = (r:0;   g:255; b:0);
const ccRED:     ccColor3B = (r:255; g:0;   b:0);
const ccMAGENTA: ccColor3B = (r:255; g:0;   b:255);
const ccBLACK:   ccColor3B = (r:0;   g:0;   b:0);
const ccORANGE:  ccColor3B = (r:255; g:127; b:0);
const ccGRAY:    ccColor3B = (r:166; g:166; b:166);

function ccc3(const r, g, b: GLubyte): ccColor3B; {$ifdef Inline} inline; {$ENDIF}
function ccc3BEqual(const col1, col2: ccColor3B): Boolean; {$ifdef Inline} inline; {$ENDIF}

type
  ccColor4B = record
    r: GLubyte;
    g: GLubyte;
    b: GLubyte;
    a: GLubyte;
  end;

function ccc4(const r, g, b, o: GLubyte): ccColor4B; {$ifdef Inline} inline; {$ENDIF}

type
  ccColor4F = record
    r: GLfloat;
    g: GLfloat;
    b: GLfloat;
    a: GLfloat;
  end;

function ccc4Fromccc3B(c: ccColor3B): ccColor4F; {$ifdef Inline} inline; {$ENDIF}
function ccc4F(r, g, b, a: GLfloat): ccColor4F; {$ifdef Inline} inline; {$ENDIF}
function ccc4FFromccc4B(c: ccColor4B): ccColor4F; {$ifdef Inline} inline; {$ENDIF}
function ccc4BFromccc4F(c: ccColor4F): ccColor4B; {$ifdef Inline} inline; {$ENDIF}
function ccc4FEqual(a, b: ccColor4F): Boolean; {$ifdef Inline} inline; {$ENDIF}

type
  ccVertex2F = record
    x: GLfloat;
    y: GLfloat;
  end;
  tccVertex2F = array [0..MaxInt div SizeOf(ccVertex2F) - 1] of ccVertex2F;
  ptccVertex2F = ^tccVertex2F;

function vertex2(const x, y: Single): ccVertex2F; {$ifdef Inline} inline; {$ENDIF}

type
  ccVertex3F = record
    x: GLfloat;
    y: GLfloat;
    z: GLfloat;
  end;

function vertex3(const x, y, z: Single): ccVertex3F; {$ifdef Inline} inline; {$ENDIF}

type
  ccTex2F = record
    u: GLfloat;
    v: GLfloat;
  end;

function tex2(const u, v: Single): ccTex2F; {$ifdef Inline} inline; {$ENDIF}

type
  ccPointSprite = record
    pos: ccVertex2F;
    color: ccColor4B;
    size: GLfloat;
  end;

  ccQuad2 = record
    tl: ccVertex2F;
    tr: ccVertex2F;
    bl: ccVertex2F;
    br: ccVertex2F;
  end;

  ccQuad3 = record
    bl: ccVertex3F;
    br: ccVertex3F;
    tl: ccVertex3F;
    tr: ccVertex3F;
  end;

type
  //! a Point with a vertex point, a tex coord point and a color 4B
  ccV2F_C4B_T2F = record
    vertices: ccVertex2F;
    colors: ccColor4B;
    texCoords: ccTex2F;
  end;
  pccV2F_C4B_T2F = ^ccV2F_C4B_T2F;
  tccV2F_C4B_T2F = array [0..MaxInt div SizeOf(ccV2F_C4B_T2F)-1] of ccV2F_C4B_T2F;
  ptccV2F_C4B_T2F = ^tccV2F_C4B_T2F;

  ccV2F_C4F_T2F = record
    vertices: ccVertex2F;
    colors: ccColor4F;
    texCoords: ccTex2F;
  end;

  ccV3F_C4B_T2F = record
    vertices: ccVertex3F;
    colors: ccColor4B;
    texCoords: ccTex2F;
  end;

  ccV2F_C4B_T2F_Quad = record
    bl: ccV2F_C4B_T2F;
    br: ccV2F_C4B_T2F;
    tl: ccV2F_C4B_T2F;
    tr: ccV2F_C4B_T2F
  end;

  //! 4 ccVertex3FTex2FColor4B
  ccV3F_C4B_T2F_Quad = record
    tl: ccV3F_C4B_T2F;  //! top left
    bl: ccV3F_C4B_T2F;  //! bottom left
    tr: ccV3F_C4B_T2F;  //! top right
    br: ccV3F_C4B_T2F;  //! bottom right
  end;
  pccV3F_C4B_T2F_Quad = ^ccV3F_C4B_T2F_Quad;
  tccV3F_C4B_T2F_Quad = array [0..MaxInt div SizeOf(ccV3F_C4B_T2F_Quad) - 1] of ccV3F_C4B_T2F_Quad;
  ptccV3F_C4B_T2F_Quad = ^tccV3F_C4B_T2F_Quad;

  ccV2F_C4F_T2F_Quad = record
    bl: ccV2F_C4F_T2F;
    br: ccV2F_C4F_T2F;
    tl: ccV2F_C4F_T2F;
    tr: ccV2F_C4F_T2F;
  end;

  ccV2F_C4B_T2F_Triangle = record
    a: ccV2F_C4B_T2F;
    b: ccV2F_C4B_T2F;
    c: ccV2F_C4B_T2F;
  end;

  ccBlendFunc = record
    src: GLenum;
    dst: GLenum;
  end;

  // XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
  //! Vertical text alignment type
  CCVerticalTextAlignment = (
    kCCVerticalTextAlignmentTop,
    kCCVerticalTextAlignmentCenter,
    kCCVerticalTextAlignmentBottom);

  // XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
  //! Horizontal text alignment type
  CCTextAlignment = (
    kCCTextAlignmentLeft,
    kCCTextAlignmentCenter,
    kCCTextAlignmentRight);

  ccT2F_Quad = record
    bl: ccTex2F;
    br: ccTex2F;
    tl: ccTex2F;
    tr: ccTex2F;
  end;

  ccAnimationFrameData = record
    texCoords: ccT2F_Quad;
    delay: Single;
    size: CCSize;
  end;

  ccFontShadow = record
    m_shadowEnabled: Boolean;
    m_shadowoffset: CCSize;
    m_shadowBlur: Single;
    m_shadowopacity: Single;
  end;

  ccFontStroke = record
    m_strokeEnabled: Boolean;
    m_strokeColor: ccColor3B;
    m_strokeSize: Single;
  end;

  ccFontDefinition = {$ifdef RecordExt} record {$ELSE} object {$ENDIF}
    m_fontName: string;
    m_fontsize: Integer;
    m_alignment: CCTextAlignment;
    m_vertAlignment: CCVerticalTextAlignment;
    m_dimensions: CCSize;
    m_fontFillColor: ccColor3B;
    m_shadow: ccFontShadow;
    m_stroke: ccFontStroke;
    procedure Create();
  end;
  pccFontDefinition = ^ccFontDefinition;

procedure get_ccV3F_C4B_T2F_dif(var vDiff, cDiff, tDiff: Cardinal); {$ifdef Inline} inline; {$ENDIF}

const kCCBlendFuncDisable: ccBlendFunc = (src: GL_ONE; dst: GL_ZERO);

implementation

function ccc3(const r, g, b: GLubyte): ccColor3B;
var
  c: ccColor3B;
begin
  c.r := r;
  c.g := g;
  c.b := b;
  Result := c;
end;

function ccc3BEqual(const col1, col2: ccColor3B): Boolean;
begin
  Result := (col1.r = col2.r) and (col1.g = col2.g) and (col1.b = col2.b);
end;

function ccc4(const r, g, b, o: GLubyte): ccColor4B;
var
  c: ccColor4B;
begin
  c.r := r;
  c.g := g;
  c.b := b;
  c.a := o;
  Result := c;
end;

function ccc4Fromccc3B(c: ccColor3B): ccColor4F;
var
  c4: ccColor4F;
begin
  c4.r := c.r/255.0;
  c4.g := c.g/255.0;
  c4.b := c.b/255.0;
  c4.a := 1.0;
  Result := c4;
end;

function ccc4F(r, g, b, a: GLfloat): ccColor4F;
var
  c4: ccColor4F;
begin
  c4.r := r;
  c4.g := g;
  c4.b := b;
  c4.a := a;

  Result := c4;
end;

function ccc4FFromccc4B(c: ccColor4B): ccColor4F;
var
  c4: ccColor4F;
begin
  c4.r := c.r/255.0;
  c4.g := c.g/255.0;
  c4.b := c.b/255.0;
  c4.a := c.a/255.0;

  Result := c4;
end;

function ccc4BFromccc4F(c: ccColor4F): ccColor4B;
begin
  Result.r := Round(c.r * 255);
  Result.g := Round(c.g * 255);
  Result.b := Round(c.b * 255);
  Result.a := Round(c.a * 255);
end;

function ccc4FEqual(a, b: ccColor4F): Boolean;
begin
  Result := (a.r=b.r) and (a.g=b.g) and (a.b=b.b) and (a.a=b.a);
end;

function vertex2(const x, y: Single): ccVertex2F;
var
  c: ccVertex2F;
begin
  c.x := x;
  c.y := y;
  Result := c;
end;

function vertex3(const x, y, z: Single): ccVertex3F;
var
  c: ccVertex3F;
begin
  c.x := x;
  c.y := y;
  c.z := z;

  Result := c;
end;

function tex2(const u, v: Single): ccTex2F;
var
  t: ccTex2F;
begin
  t.u := u;
  t.v := v;
  Result := t;
end;

procedure get_ccV3F_C4B_T2F_dif(var vDiff, cDiff, tDiff: Cardinal);
var
  vct: ccV3F_C4B_T2F;
begin
  vDiff := Cardinal(@vct.vertices) - Cardinal(@vct);
  cDiff := Cardinal(@vct.colors) - Cardinal(@vct);
  tDiff := Cardinal(@vct.texCoords) - Cardinal(@vct);
end;

procedure ccFontDefinition.Create;
begin
  m_alignment := kCCTextAlignmentCenter;
  m_vertAlignment := kCCVerticalTextAlignmentTop;
  m_fontFillColor := ccWHITE;
  m_dimensions := CCSizeMake(0, 0);
end;  

end.
