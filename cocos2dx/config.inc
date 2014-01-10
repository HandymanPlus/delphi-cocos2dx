{$define WIN32}
{.$define WIN64}
{.$define IOS}
{.$define ANDROID}
{.$define MACOS}
{.$define LINUX}


{$define CC_ENABLE_GL_STATE_CACHE}

{$IF (DEFINED(CPUX64) or DEFINED(CPUARM))}
{$DEFINE PUREPASCAL}
{$IFEND}

{$ifdef VER150}
//delphi7
{$endif}
{$ifdef VER160}
//delphi8
{$endif}
{$ifdef VER170}
//delphi2005
{$endif}
{$ifdef VER180}
//delphi2006
{$endif}
{$ifdef VER185}
//delphi2007
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$endif}
{$ifdef VER190}
//delphi2007 
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$endif}
{$ifdef VER200}
//delphi2009
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$endif}
{$ifdef VER210}
//delphi2010
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$define Generics}
{$endif}
{$ifdef VER220}
//delphiXE1
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$define Generics}
{$endif}
{$ifdef VER230}
//delphiXE2
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$define Generics}
{$endif}
{$ifdef VER240}
//delphiXE3
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$define Generics}
{$endif}
{$ifdef VER250}
//delphiXE4
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$define Generics}
{$endif}
{$ifdef VER260}
//delphiXE5
{$define Delphi7Up}
{$define RecordExt}
{$define Inline}
{$define Generics}
{$define CrossPlatform}
{$endif}

{$ifndef CrossPlatform}
{$define WIN32}
{$undef WIN64}
{$undef IOS}
{$undef ANDROID}
{$undef MACOS}
{$undef LINUX}
{$endif}
