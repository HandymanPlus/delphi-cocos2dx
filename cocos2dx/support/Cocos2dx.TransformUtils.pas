(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Valentin Milea

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

unit Cocos2dx.TransformUtils;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCAffineTransform;

procedure CGAffineToGL(const t: PCCAffineTransform; m: PGLfloat);
procedure GLToCGAffine(const m: PGLfloat; t: PCCAffineTransform);

implementation

type
  TGLfloatAry = array [0..15] of GLfloat;
  PGLFloatAry = ^TGLfloatAry;

procedure CGAffineToGL(const t: PCCAffineTransform; m: PGLfloat);
begin
    // | m[0] m[4] m[8]  m[12] |     | m11 m21 m31 m41 |     | a c 0 tx |
    // | m[1] m[5] m[9]  m[13] |     | m12 m22 m32 m42 |     | b d 0 ty |
    // | m[2] m[6] m[10] m[14] | <=> | m13 m23 m33 m43 | <=> | 0 0 1  0 |
    // | m[3] m[7] m[11] m[15] |     | m14 m24 m34 m44 |     | 0 0 0  1 |
    
  PGLFloatAry(m)[2]   := 0.0;
  PGLFloatAry(m)[3]   := 0.0;
  PGLFloatAry(m)[6]   := 0.0;
  PGLFloatAry(m)[7]   := 0.0;
  PGLFloatAry(m)[8]   := 0.0;
  PGLFloatAry(m)[9]   := 0.0;
  PGLFloatAry(m)[11]  := 0.0;
  PGLFloatAry(m)[14]  := 0.0;

  PGLFloatAry(m)[10]  := 1.0;
  PGLFloatAry(m)[15]  := 1.0;

  PGLFloatAry(m)[0]   := t^.a;
  PGLFloatAry(m)[4]   := t^.c;
  PGLFloatAry(m)[12]  := t^.tx;
  PGLFloatAry(m)[1]   := t^.b;
  PGLFloatAry(m)[5]   := t^.d;
  PGLFloatAry(m)[13]  := t^.ty;
end;
  
procedure GLToCGAffine(const m: PGLfloat; t: PCCAffineTransform);
begin
  t^.a := PGLFloatAry(m)[0]; t^.c := PGLFloatAry(m)[4]; t^.tx := PGLFloatAry(m)[12];
  t^.b := PGLFloatAry(m)[1]; t^.d := PGLFloatAry(m)[5]; t^.ty := PGLFloatAry(m)[13];
end;

end.
