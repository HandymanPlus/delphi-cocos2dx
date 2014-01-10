unit Cocos2dx.CCPointerArray;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES; {$else} dglOpenGL; {$endif}

type
  TGLvoidArray = array [0..MaxInt div SizeOf(GLvoid) - 1] of GLvoid;
  PGLvoidArray = ^TGLvoidArray;

  TGLfloatArray = array [0..MaxInt div SizeOf(GLfloat) - 1] of GLfloat;
  PGLfloatArray = ^TGLfloatArray;

  TGLushortArray = array [0..MaxInt div SizeOf(GLushort) - 1] of GLushort;
  PGLushortArray = ^TGLushortArray;

  TIntArray = array [0..MaxInt div SizeOf(Integer) - 1] of Integer;
  PIntArray = ^TIntArray;

  TUIntArray = array [0..MaxInt div SizeOf(Cardinal) - 1] of Cardinal;
  PUIntArray = ^TUIntArray;

  TByteArray = array [0..MaxInt div SizeOf(Byte) - 1] of Byte;
  PByteArray = ^TByteArray;

  TFloatArray = array [0..MaxInt div SizeOf(Single) - 1] of Single;
  PFloatArray = ^TFloatArray;

implementation

end.
