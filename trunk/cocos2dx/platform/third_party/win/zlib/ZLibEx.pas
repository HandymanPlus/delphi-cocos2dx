{*****************************************************************************
*  ZLibEx.pas                                                                *
*                                                                            *
*  copyright (c) 2000-2009 base2 technologies                                *
*  copyright (c) 1995-2002 Borland Software Corporation                      *
*                                                                            *
*  revision history                                                          *
*    2009.04.14  added overloaded string routines for AnsiString and         *
*                  UnicodeString                                             *
*    2009.01.28  updated for delphi 2009 String (UnicodeString)              *
*    2008.05.15  added TStreamPos type Stream.Position variants              *
*                added TCustomZStream.Stream* methods                        *
*    2007.08.17  modified TZCompressionStream.Write to use Write instead of  *
*                  WriteBuffer                                               *
*    2007.03.15  moved gzip routines to separate unit (ZLibExGZ.pas)         *
*    2006.10.07  fixed EZLibError constructor for c++ builder compatibility  *
*    2006.03.28  moved Z_DEFLATED to interface section                       *
*                added custom compression levels zcLevel1 thru zcLevel9      *
*    2006.03.27  added ZCompressStreamWeb                                    *
*    2006.03.24  added ZAdler32 and ZCrc32                                   *
*    2005.11.29  changed FStreamPos to Int64 for delphi 6+                   *
*    2005.07.25  updated to zlib version 1.2.3                               *
*    2005.03.04  modified ZInternalCompressStream loops                      *
*                modified ZInternalDecompressStream loops                    *
*    2005.02.07  fixed ZInternalCompressStream loop conditions               *
*                fixed ZInternalDecompressStream loop conditions             *
*    2005.01.11  updated to zlib version 1.2.2                               *
*                added ZCompressStrWeb                                       *
*    2004.01.06  updated to zlib version 1.2.1                               *
*    2003.04.14  added ZCompress2 and ZDecompress2                           *
*                added ZCompressStr2 and ZDecompressStr2                     *
*                added ZCompressStream2 and ZDecompressStream2               *
*                added overloaded T*Stream constructors to support           *
*                  InflateInit2 and DeflateInit2                             *
*                fixed ZDecompressStream to use ZDecompressCheck instead of  *
*                  ZCompressCheck                                            *
*    2002.03.15  updated to zlib version 1.1.4                               *
*    2001.11.27  enhanced TZDecompressionStream.Read to adjust source        *
*                  stream position upon end of compression data              *
*                fixed endless loop in TZDecompressionStream.Read when       *
*                  destination count was greater than uncompressed data      *
*    2001.10.26  renamed unit to integrate "nicely" with delphi 6            *
*    2000.11.24  added soFromEnd condition to TZDecompressionStream.Seek     *
*                added ZCompressStream and ZDecompressStream                 *
*    2000.06.13  optimized, fixed, rewrote, and enhanced the zlib.pas unit   *
*                  included on the delphi cd (zlib version 1.1.3)            *
*                                                                            *
*  acknowledgments                                                           *
*    erik turner                                                             *
*      2001.10.26  Z*Stream routines                                         *
*                                                                            *
*    david bennion                                                           *
*      2001.11.27  finding the nastly little endless loop quirk with the     *
*                    TZDecompressionStream.Read method                       *
*                                                                            *
*    burak kalayci                                                           *
*      2002.03.15  informing me about the zlib 1.1.4 update                  *
*      2004.01.06  informing me about the zlib 1.2.1 update                  *
*                                                                            *
*    vicente sánchez-alarcos                                                 *
*      2005.01.11  informing me about the zlib 1.2.2 update                  *
*                                                                            *
*    luigi sandon                                                            *
*      2005.02.07  pointing out the missing loop condition (Z_STREAM_END)    *
*                    in ZInternalCompressStream and                          *
*                    ZInternalDecompressStream                               *
*                                                                            *
*    ferry van genderen                                                      *
*      2005.03.04  assisting me fine tune and beta test                      *
*                    ZInternalCompressStream and ZInternalDecompressStream   *
*                                                                            *
*    mathijs van veluw                                                       *
*      2005.07.25  informing me about the zlib 1.2.3 update                  *
*                                                                            *
*    j. rathlev                                                              *
*      2005.11.28  pointing out the FStreamPos and TStream.Position type     *
*                    inconsistency                                           *
*                                                                            *
*    anders johansen                                                         *
*      2006.10.07  pointing out the ELibError constructor incompatibility    *
*                    with c++ builder                                        *
*                                                                            *
*    marcin szafrański                                                       *
*      2009.01.28  beta testing the delphi 2009 changes                      *
*                                                                            *
*    iztok kacin                                                             *
*      2009.04.14  assisting me design and further improve support for       *
*                    delphi 2009                                             *
*****************************************************************************}

unit ZLibEx;

interface

{$I ZLibEx.inc}

uses
  SysUtils, Classes;

const
  {** version ids ***********************************************************}

  ZLIB_VERSION   = '1.2.3';
  ZLIB_VERNUM    = $1230;

  {** compression methods ***************************************************}

  Z_DEFLATED = 8;

  {** information flags ****************************************************}

  Z_INFO_FLAG_SIZE  = $1;
  Z_INFO_FLAG_CRC   = $2;
  Z_INFO_FLAG_ADLER = $4;

  Z_INFO_NONE       = 0;
  Z_INFO_DEFAULT    = Z_INFO_FLAG_SIZE or Z_INFO_FLAG_CRC;

type

{$ifndef UNICODE}

  RawByteString = AnsiString;

  UnicodeString = WideString;
  UnicodeChar = WideChar;

{$endif}

  TStreamPos = {$ifdef Version6Plus} Int64 {$else} Longint {$endif};

  TZAlloc = function (opaque: Pointer; items, size: Integer): Pointer;
  TZFree  = procedure (opaque, block: Pointer);

  TZCompressionLevel = (
    zcNone,
    zcFastest,
    zcDefault,
    zcMax,
    zcLevel1,
    zcLevel2,
    zcLevel3,
    zcLevel4,
    zcLevel5,
    zcLevel6,
    zcLevel7,
    zcLevel8,
    zcLevel9
  );

  // **: Define old enum for compression level
  TCompressionLevel = (clNone = Integer(zcNone), clFastest, clDefault, clMax);

  TZStrategy = (
    zsDefault,
    zsFiltered,
    zsHuffman,
    zsRLE,
    zsFixed
  );

  TZError = (
    zeError,
    zeStreamError,
    zeDataError,
    zeMemoryError,
    zeBufferError,
    zeVersionError
  );

  {** TZStreamRec ***********************************************************}

  TZStreamRec = packed record
    next_in  : Pointer;   // next input byte
    avail_in : Longint;   // number of bytes available at next_in
    total_in : Longint;   // total nb of input bytes read so far

    next_out : Pointer;   // next output byte should be put here
    avail_out: Longint;   // remaining free space at next_out
    total_out: Longint;   // total nb of bytes output so far

    msg      : Pointer;   // last error message, NULL if no error
    state    : Pointer;   // not visible by applications

    zalloc   : TZAlloc;   // used to allocate the internal state
    zfree    : TZFree;    // used to free the internal state
    opaque   : Pointer;   // private data object passed to zalloc and zfree

    data_type: Integer;   // best guess about the data type: ascii or binary
    adler    : Longint;   // adler32 value of the uncompressed data
    reserved : Longint;   // reserved for future use
  end;

//  {** TZInformation *********************************************************}
//
//  TZInformation = packed record
//    CompressedFlags  : Longint;
//    CompressedSize   : TStreamPos;
//    CompressedCrc    : Longint;
//    CompressedAdler  : Longint;
//
//    UncompressedFlags: Longint;
//    UncompressedSize : TStreamPos;
//    UncompressedCrc  : Longint;
//    UncompressedAdler: Longint;
//  end;

  {** TCustomZStream ********************************************************}

  TCustomZStream = class(TStream)
  private
    FStream    : TStream;
    FStreamPos : TStreamPos;
    FOnProgress: TNotifyEvent;

    FZStream   : TZStreamRec;
    FBuffer    : Array [Word] of Byte;

    function  GetStreamPosition: TStreamPos;
    procedure SetStreamPosition(value: TStreamPos);
  protected
    constructor Create(stream: TStream);

    function  StreamRead(var buffer; count: Longint): Longint;
    function  StreamWrite(const buffer; count: Longint): Longint;
    function  StreamSeek(offset: Longint; origin: Word): Longint;

    procedure StreamReadBuffer(var buffer; count: Longint);
    procedure StreamWriteBuffer(const buffer; count: Longint);

    procedure DoProgress; dynamic;

    property StreamPosition: TStreamPos read GetStreamPosition write SetStreamPosition;

    property OnProgress: TNotifyEvent read FOnProgress write FOnProgress;
  end;

  // **: Add alias of classname to old Zlib classname
  TCustomZLibStream = TCustomZStream;

  {** TZCompressionStream ***************************************************}

  TZCompressionStream = class(TCustomZStream)
  private
    function GetCompressionRate: Single;
  public
    constructor Create(dest: TStream;
      compressionLevel: TZCompressionLevel = zcDefault); overload;

    constructor Create(dest: TStream; compressionLevel: TZCompressionLevel;
      windowBits, memLevel: Integer; strategy: TZStrategy); overload;

    // **: Add overloaded constructor for old parameter type and order
    constructor Create(compressionLevel: TCompressionLevel; dest: TStream); overload;

    destructor  Destroy; override;

    function  Read(var buffer; count: Longint): Longint; override;
    function  Write(const buffer; count: Longint): Longint; override;
    function  Seek(offset: Longint; origin: Word): Longint; override;

    property CompressionRate: Single read GetCompressionRate;
    property OnProgress;
  end;

  // **: Add alias of classname to old Zlib classname
  TCompressionStream = TZCompressionStream;

  {** TZDecompressionStream *************************************************}

  TZDecompressionStream = class(TCustomZStream)
  public
    constructor Create(source: TStream); overload;
    constructor Create(source: TStream; windowBits: Integer); overload;

    destructor  Destroy; override;

    function  Read(var buffer; count: Longint): Longint; override;
    function  Write(const buffer; count: Longint): Longint; override;
    function  Seek(offset: Longint; origin: Word): Longint; override;

    property OnProgress;
  end;

  // **: Add alias of classname to old Zlib classname
  TDecompressionStream = TZDecompressionStream;

{** zlib public routines ****************************************************}

{*****************************************************************************
*  ZCompress                                                                 *
*                                                                            *
*  pre-conditions                                                            *
*    inBuffer  = pointer to uncompressed data                                *
*    inSize    = size of inBuffer (bytes)                                    *
*    outBuffer = pointer (unallocated)                                       *
*    level     = compression level                                           *
*                                                                            *
*  post-conditions                                                           *
*    outBuffer = pointer to compressed data (allocated)                      *
*    outSize   = size of outBuffer (bytes)                                   *
*****************************************************************************}

procedure ZCompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer;
  level: TZCompressionLevel = zcDefault); overload;

// **: Add overload to take old enum type
procedure ZCompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer;
  level: TCompressionLevel); overload;

{*****************************************************************************
*  ZCompress2                                                                *
*                                                                            *
*  pre-conditions                                                            *
*    inBuffer   = pointer to uncompressed data                               *
*    inSize     = size of inBuffer (bytes)                                   *
*    outBuffer  = pointer (unallocated)                                      *
*    level      = compression level                                          *
*    method     = compression method                                         *
*    windowBits = window bits                                                *
*    memLevel   = memory level                                               *
*    strategy   = compression strategy                                       *
*                                                                            *
*  post-conditions                                                           *
*    outBuffer = pointer to compressed data (allocated)                      *
*    outSize   = size of outBuffer (bytes)                                   *
*****************************************************************************}

procedure ZCompress2(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; level: TZCompressionLevel;
  windowBits, memLevel: Integer; strategy: TZStrategy = zsDefault); overload;

// **: Add overload to take old enum type
procedure ZCompress2(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; level: TCompressionLevel;
  windowBits, memLevel: Integer); overload;

{*****************************************************************************
*  ZDecompress                                                               *
*                                                                            *
*  pre-conditions                                                            *
*    inBuffer    = pointer to compressed data                                *
*    inSize      = size of inBuffer (bytes)                                  *
*    outBuffer   = pointer (unallocated)                                     *
*    outEstimate = estimated size of uncompressed data (bytes)               *
*                                                                            *
*  post-conditions                                                           *
*    outBuffer = pointer to decompressed data (allocated)                    *
*    outSize   = size of outBuffer (bytes)                                   *
*****************************************************************************}

procedure ZDecompress(const inBuffer: Pointer; inSize: Integer;
 out outBuffer: Pointer; out outSize: Integer; outEstimate: Integer = 0);

{*****************************************************************************
*  ZDecompress2                                                              *
*                                                                            *
*  pre-conditions                                                            *
*    inBuffer    = pointer to compressed data                                *
*    inSize      = size of inBuffer (bytes)                                  *
*    outBuffer   = pointer (unallocated)                                     *
*    windowBits  = window bits                                               *
*    outEstimate = estimated size of uncompressed data (bytes)               *
*                                                                            *
*  post-conditions                                                           *
*    outBuffer = pointer to decompressed data (allocated)                    *
*    outSize   = size of outBuffer (bytes)                                   *
*****************************************************************************}

procedure ZDecompress2(const inBuffer: Pointer; inSize: Integer;
 out outBuffer: Pointer; out outSize: Integer; windowBits: Integer;
 outEstimate: Integer = 0);

{** string routines *********************************************************}

{*****************************************************************************
*  ZCompressStr                                                              *
*                                                                            *
*  pre-conditions                                                            *
*    s     = uncompressed data string                                        *
*    level = compression level                                               *
*                                                                            *
*  return                                                                    *
*    compressed data string                                                  *
*****************************************************************************}

function  ZCompressStr(const s: AnsiString;
  level: TZCompressionLevel = zcDefault): AnsiString; overload;

// **: Add overload to take old enum type
function ZCompressStr(const s: string; level: TCompressionLevel): AnsiString; overload;

procedure ZCompressString(var result: RawByteString; const s: AnsiString;
  level: TZCompressionLevel = zcDefault); overload;

procedure ZCompressString(var result: RawByteString; const s: UnicodeString;
  level: TZCompressionLevel = zcDefault); overload;

{*****************************************************************************
*  ZCompressStrEx                                                            *
*                                                                            *
*  pre-conditions                                                            *
*    s     = uncompressed data string                                        *
*    level = compression level                                               *
*                                                                            *
*  return                                                                    *
*    compressed data string with 4 byte (integer) header indicating          *
*    original uncompressed data length                                       *
*****************************************************************************}

function  ZCompressStrEx(const s: AnsiString;
  level: TZCompressionLevel = zcDefault): AnsiString; overload;

// **: Add overload to take old enum type
function  ZCompressStrEx(const s: AnsiString;
  level: TCompressionLevel = clNone): AnsiString; overload;

procedure ZCompressStringEx(var result: RawByteString; const s: AnsiString;
  level: TZCompressionLevel = zcDefault); overload;

procedure ZCompressStringEx(var result: RawByteString; const s: UnicodeString;
  level: TZCompressionLevel = zcDefault); overload;

{*****************************************************************************
*  ZCompressStr2                                                             *
*                                                                            *
*  pre-conditions                                                            *
*    s          = uncompressed data string                                   *
*    level      = compression level                                          *
*    windowBits = window bits                                                *
*    memLevel   = memory level                                               *
*    strategy   = compression strategy                                       *
*                                                                            *
*  return                                                                    *
*    compressed data string                                                  *
*****************************************************************************}

function  ZCompressStr2(const s: AnsiString; level: TZCompressionLevel;
  windowBits, memLevel: Integer; strategy: TZStrategy): AnsiString;

procedure ZCompressString2(var result: RawByteString; const s: AnsiString;
  level: TZCompressionLevel; windowBits, memLevel: Integer;
  strategy: TZStrategy); overload;

procedure ZCompressString2(var result: RawByteString; const s: UnicodeString;
  level: TZCompressionLevel; windowBits, memLevel: Integer;
  strategy: TZStrategy); overload;

{*****************************************************************************
*  ZCompressStrWeb                                                           *
*                                                                            *
*  pre-conditions                                                            *
*    s = uncompressed data string                                            *
*                                                                            *
*  return                                                                    *
*    compressed data string                                                  *
*****************************************************************************}

function  ZCompressStrWeb(const s: AnsiString): AnsiString;

procedure ZCompressStringWeb(var result: RawByteString; const s: AnsiString);
  overload;

procedure  ZCompressStringWeb(var result: RawByteString;
  const s: UnicodeString); overload;

{*****************************************************************************
*  ZDecompressStr                                                            *
*                                                                            *
*  pre-conditions                                                            *
*    s = compressed data string                                              *
*                                                                            *
*  return                                                                    *
*    uncompressed data string                                                *
*****************************************************************************}

function  ZDecompressStr(const s: AnsiString): AnsiString;

procedure ZDecompressString(var result: AnsiString; const s: RawByteString);
  overload;

procedure ZDecompressString(var result: UnicodeString;
  const s: RawByteString); overload;

{*****************************************************************************
*  ZDecompressStrEx                                                          *
*                                                                            *
*  pre-conditions                                                            *
*    s = compressed data string with 4 byte (integer) header indicating      *
*        original uncompressed data length                                   *
*                                                                            *
*  return                                                                    *
*    uncompressed data string                                                *
*****************************************************************************}

function  ZDecompressStrEx(const s: AnsiString): AnsiString;

procedure ZDecompressStringEx(var result: AnsiString; const s: RawByteString);
  overload;

procedure ZDecompressStringEx(var result: UnicodeString;
  const s: RawByteString); overload;

{*****************************************************************************
*  ZDecompressStr2                                                           *
*                                                                            *
*  pre-conditions                                                            *
*    s          = compressed data string                                     *
*    windowBits = window bits                                                *
*                                                                            *
*  return                                                                    *
*    uncompressed data string                                                *
*****************************************************************************}

function  ZDecompressStr2(const s: AnsiString;
  windowBits: Integer): AnsiString;

procedure ZDecompressString2(var result: AnsiString; const s: RawByteString;
  windowBits: Integer); overload;

procedure ZDecompressString2(var result: UnicodeString;
  const s: RawByteString; windowBits: Integer); overload;

{** stream routines *********************************************************}

procedure ZCompressStream(inStream, outStream: TStream;
  level: TZCompressionLevel = zcDefault); overload;

// **: Add overload to take old enum type
procedure ZCompressStream(inStream, outStream: TStream;
  level: TCompressionLevel = clNone); overload;

procedure ZCompressStream2(inStream, outStream: TStream;
  level: TZCompressionLevel; windowBits, memLevel: Integer;
  strategy: TZStrategy);

procedure ZCompressStreamWeb(inStream, outStream: TStream);

procedure ZDecompressStream(inStream, outStream: TStream);

procedure ZDecompressStream2(inStream, outStream: TStream;
  windowBits: Integer);

// **: Routines from old version of ZLib required for  backwards compatability

{ CompressBuf compresses data, buffer to buffer, in one call.
   In: InBuf = ptr to compressed data
       InBytes = number of bytes in InBuf
  Out: OutBuf = ptr to newly allocated buffer containing decompressed data
       OutBytes = number of bytes in OutBuf   }
procedure CompressBuf(const InBuf: Pointer; InBytes: Integer;
                      out OutBuf: Pointer; out OutBytes: Integer);


{ DecompressBuf decompresses data, buffer to buffer, in one call.
   In: InBuf = ptr to compressed data
       InBytes = number of bytes in InBuf
       OutEstimate = zero, or est. size of the decompressed data
  Out: OutBuf = ptr to newly allocated buffer containing decompressed data
       OutBytes = number of bytes in OutBuf   }
procedure DecompressBuf(const InBuf: Pointer; InBytes: Integer;
 OutEstimate: Integer; out OutBuf: Pointer; out OutBytes: Integer);

{ DecompressToUserBuf decompresses data, buffer to buffer, in one call.
   In: InBuf = ptr to compressed data
       InBytes = number of bytes in InBuf
  Out: OutBuf = ptr to user-allocated buffer to contain decompressed data
       BufSize = number of bytes in OutBuf   }
procedure DecompressToUserBuf(const InBuf: Pointer; InBytes: Integer;
  const OutBuf: Pointer; BufSize: Integer);

// Direct ZLib access

function zlibAllocMem(AppData: Pointer; Items, Size: Integer): Pointer;
procedure zlibFreeMem(AppData, Block: Pointer);
function deflateInit_(var strm: TZStreamRec; level: Integer; version: PChar;
  recsize: Integer): Integer;
function deflate(var strm: TZStreamRec; flush: Integer): Integer;
function deflateEnd(var strm: TZStreamRec): Integer;
function inflateInit_(var strm: TZStreamRec; version: PChar;
  recsize: Integer): Integer; 
function inflate(var strm: TZStreamRec; flush: Integer): Integer;
function inflateEnd(var strm: TZStreamRec): Integer;
function inflateReset(var strm: TZStreamRec): Integer;

{** checksum routines *******************************************************}

function  ZAdler32(adler: Longint; const buffer; size: Integer): Longint;
function  ZCrc32(crc: Longint; const buffer; size: Integer): Longint;

{****************************************************************************}

type
  EZLibErrorClass = class of EZlibError;

  EZLibError = class(Exception)
  private
    FErrorCode: Integer;
  public
    constructor Create(code: Integer; const dummy: String = ''); overload;
    constructor Create(error: TZError; const dummy: String = ''); overload;

    property ErrorCode: Integer read FErrorCode write FErrorCode;
  end;

  EZCompressionError = class(EZLibError);
  EZDecompressionError = class(EZLibError);


const
  {** flush constants *******************************************************}

  Z_NO_FLUSH      = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH    = 2;
  Z_FULL_FLUSH    = 3;
  Z_FINISH        = 4;
  Z_BLOCK         = 5;

  {** return codes **********************************************************}

  Z_OK            = 0;
  Z_STREAM_END    = 1;
  Z_NEED_DICT     = 2;
  Z_ERRNO         = (-1);
  Z_STREAM_ERROR  = (-2);
  Z_DATA_ERROR    = (-3);
  Z_MEM_ERROR     = (-4);
  Z_BUF_ERROR     = (-5);
  Z_VERSION_ERROR = (-6);

  {** compression levels ****************************************************}

  Z_NO_COMPRESSION       =   0;
  Z_BEST_SPEED           =   1;
  Z_BEST_COMPRESSION     =   9;
  Z_DEFAULT_COMPRESSION  = (-1);

  {** compression strategies ************************************************}

  Z_FILTERED            = 1;
  Z_HUFFMAN_ONLY        = 2;
  Z_RLE                 = 3;
  Z_FIXED               = 4;
  Z_DEFAULT_STRATEGY    = 0;

  {** data types ************************************************************}

  Z_BINARY   = 0;
  Z_ASCII    = 1;
  Z_TEXT     = Z_ASCII;
  Z_UNKNOWN  = 2;

implementation

{*****************************************************************************
*  link zlib code                                                            *
*                                                                            *
*  bcc32 flags                                                               *
*    -c -6 -O2 -Ve -X- -pr -a8 -b -d -k- -vi -tWM                               *
*                                                                            *
*  note: do not reorder the following -- doing so will result in external    *
*  functions being undefined                                                 *
*****************************************************************************}

{$L deflate.obj}
{$L inflate.obj}
{$L inftrees.obj}
{$L infback.obj}
{$L inffast.obj}
{$L trees.obj}
{$L compress.obj}
{$L adler32.obj}
{$L crc32.obj}

{****************************************************************************}

const
  {** return code messages **************************************************}

  _z_errmsg: Array [0..9] of String = (
    'Need dictionary',      // Z_NEED_DICT      (2)
    'Stream end',           // Z_STREAM_END     (1)
    'OK',                   // Z_OK             (0)
    'File error',           // Z_ERRNO          (-1)
    'Stream error',         // Z_STREAM_ERROR   (-2)
    'Data error',           // Z_DATA_ERROR     (-3)
    'Insufficient memory',  // Z_MEM_ERROR      (-4)
    'Buffer error',         // Z_BUF_ERROR      (-5)
    'Incompatible version', // Z_VERSION_ERROR  (-6)
    ''
  );

  ZLevels: Array [TZCompressionLevel] of Shortint = (
    Z_NO_COMPRESSION,       // zcNone
    Z_BEST_SPEED,           // zcFastest
    Z_DEFAULT_COMPRESSION,  // zcDefault
    Z_BEST_COMPRESSION,     // zcMax
    1,                      // zcLevel1
    2,                      // zcLevel2
    3,                      // zcLevel3
    4,                      // zcLevel4
    5,                      // zcLevel5
    6,                      // zcLevel6
    7,                      // zcLevel7
    8,                      // zcLevel8
    9                       // zcLevel9
  );

  ZStrategies: Array [TZStrategy] of Shortint = (
    Z_DEFAULT_STRATEGY,     // zsDefault
    Z_FILTERED,             // zsFiltered
    Z_HUFFMAN_ONLY,         // zsHuffman
    Z_RLE,                  // zsRLE
    Z_FIXED                 // zsFixed
  );

  ZErrors: Array [TZError] of Shortint = (
    Z_ERRNO,                // zeError
    Z_STREAM_ERROR,         // zeStreamError
    Z_DATA_ERROR,           // zeDataError
    Z_MEM_ERROR,            // zeMemoryError
    Z_BUF_ERROR,            // zeBufferError
    Z_VERSION_ERROR         // zeVersionError
  );

  SZInvalid = 'Invalid ZStream operation!';

{** deflate routines ********************************************************}

function deflateInit_(var strm: TZStreamRec; level: Integer;
  version: PAnsiChar; recsize: Integer): Integer;
  external;

function deflateInit2_(var strm: TZStreamRec; level, method, windowBits,
  memLevel, strategy: Integer; version: PAnsiChar; recsize: Integer): Integer;
  external;

function deflate(var strm: TZStreamRec; flush: Integer): Integer;
  external;

function deflateEnd(var strm: TZStreamRec): Integer;
  external;

{** inflate routines ********************************************************}

function inflateInit_(var strm: TZStreamRec; version: PAnsiChar;
  recsize: Integer): Integer;
  external;

function inflateInit2_(var strm: TZStreamRec; windowBits: Integer;
  version: PAnsiChar; recsize: Integer): Integer;
  external;

function inflate(var strm: TZStreamRec; flush: Integer): Integer;
  external;

function inflateEnd(var strm: TZStreamRec): Integer;
  external;

function inflateReset(var strm: TZStreamRec): Integer;
  external;

{** checksum routines *******************************************************}

function adler32(adler: Longint; const buf; len: Integer): Longint;
  external;

function crc32(crc: Longint; const buf; len: Integer): Longint;
  external;

{** zlib function implementations *******************************************}

function zcalloc(opaque: Pointer; items, size: Integer): Pointer;
begin
  GetMem(result,items * size);
end;

procedure zcfree(opaque, block: Pointer);
begin
  FreeMem(block);
end;

{** c function implementations **********************************************}

procedure _memset(p: Pointer; b: Byte; count: Integer); cdecl;
begin
  FillChar(p^,count,b);
end;

procedure _memcpy(dest, source: Pointer; count: Integer); cdecl;
begin
  Move(source^,dest^,count);
end;

{** custom zlib routines ****************************************************}

function DeflateInit(var stream: TZStreamRec; level: Integer): Integer;
begin
  result := deflateInit_(stream,level,ZLIB_VERSION,SizeOf(TZStreamRec));
end;

function DeflateInit2(var stream: TZStreamRec; level, method, windowBits,
  memLevel, strategy: Integer): Integer;
begin
  result := deflateInit2_(stream,level,method,windowBits,memLevel,strategy,
    ZLIB_VERSION,SizeOf(TZStreamRec));
end;

function InflateInit(var stream: TZStreamRec): Integer;
begin
  result := inflateInit_(stream,ZLIB_VERSION,SizeOf(TZStreamRec));
end;

function InflateInit2(var stream: TZStreamRec; windowBits: Integer): Integer;
begin
  result := inflateInit2_(stream,windowBits,ZLIB_VERSION,SizeOf(TZStreamRec));
end;

{****************************************************************************}

function ZCompressCheck(code: Integer): Integer;
begin
  result := code;

  if code < 0 then
  begin
    raise EZCompressionError.Create(code);
  end;
end;

function ZDecompressCheck(code: Integer): Integer;
begin
  Result := code;

  if code < 0 then
  begin
    raise EZDecompressionError.Create(code);
  end;
end;

procedure ZInternalCompress(var zstream: TZStreamRec; const inBuffer: Pointer;
  inSize: Integer; out outBuffer: Pointer; out outSize: Integer);
const
  delta = 256;
begin
  outSize := ((inSize + (inSize div 10) + 12) + 255) and not 255;
  GetMem(outBuffer,outSize);

  try
    try
      zstream.next_in := inBuffer;
      zstream.avail_in := inSize;
      zstream.next_out := outBuffer;
      zstream.avail_out := outSize;

      while ZCompressCheck(deflate(zstream,Z_FINISH)) <> Z_STREAM_END do
      begin
        Inc(outSize,delta);
        ReallocMem(outBuffer,outSize);

        zstream.next_out := Pointer(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := delta;
      end;
    finally
      ZCompressCheck(deflateEnd(zstream));
    end;

    ReallocMem(outBuffer,zstream.total_out);
    outSize := zstream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

procedure ZInternalDecompress(zstream: TZStreamRec; const inBuffer: Pointer;
  inSize: Integer; out outBuffer: Pointer; out outSize: Integer;
  outEstimate: Integer);
var
  delta: Integer;
begin
  delta := (inSize + 255) and not 255;

  if outEstimate = 0 then outSize := delta
  else outSize := outEstimate;

  GetMem(outBuffer,outSize);

  try
    try
      zstream.next_in := inBuffer;
      zstream.avail_in := inSize;
      zstream.next_out := outBuffer;
      zstream.avail_out := outSize;

      while ZDecompressCheck(inflate(zstream,Z_NO_FLUSH)) <> Z_STREAM_END do
      begin
        Inc(outSize,delta);
        ReallocMem(outBuffer,outSize);

        zstream.next_out := Pointer(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := delta;
      end;
    finally
      ZDecompressCheck(inflateEnd(zstream));
    end;

    ReallocMem(outBuffer,zstream.total_out);
    outSize := zstream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

procedure ZCompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer;
  level: TZCompressionLevel);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZCompressCheck(DeflateInit(zstream,ZLevels[level]));

  ZInternalCompress(zstream,inBuffer,inSize,outBuffer,outSize);
end;

procedure ZCompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer;
  level: TCompressionLevel);
begin
  ZCompress(inBuffer, inSize, outBuffer, outSize, TZCompressionLevel(Integer(level)));
end;

procedure ZCompress2(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; level: TZCompressionLevel;
  windowBits, memLevel: Integer; strategy: TZStrategy);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZCompressCheck(DeflateInit2(zstream,ZLevels[level],Z_DEFLATED,windowBits,
    memLevel,ZStrategies[strategy]));

  ZInternalCompress(zstream,inBuffer,inSize,outBuffer,outSize);
end;

procedure ZCompress2(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; level: TCompressionLevel;
  windowBits, memLevel: Integer);
begin
  ZCompress2(inBuffer, inSize, outBuffer, outSize, TZCompressionLevel(Integer(level))
   , windowBits, memLevel );
end;

procedure ZDecompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; outEstimate: Integer);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZDecompressCheck(InflateInit(zstream));

  ZInternalDecompress(zstream,inBuffer,inSize,outBuffer,outSize,outEstimate);
end;

procedure ZDecompress2(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; windowBits: Integer;
  outEstimate: Integer);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZDecompressCheck(InflateInit2(zstream,windowBits));

  ZInternalDecompress(zstream,inBuffer,inSize,outBuffer,outSize,outEstimate);
end;

{** string routines *********************************************************}

function ZCompressStr(const s: AnsiString;
  level: TZCompressionLevel): AnsiString;
begin
  ZCompressString(result, s, level);
end;

function ZCompressStr(const s: string; level: TCompressionLevel): AnsiString;
begin
  Result := ZCompressStr(s, TZCompressionLevel(Integer(level)));
end;

procedure ZCompressString(var result: RawByteString; const s: AnsiString;
  level: TZCompressionLevel);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZCompress(Pointer(s), Length(s), buffer, size, level);

  SetLength(result, size);

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

procedure ZCompressString(var result: RawByteString; const s: UnicodeString;
  level: TZCompressionLevel);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZCompress(Pointer(s), Length(s) * SizeOf(UnicodeChar), buffer, size, level);

  SetLength(result, size);

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

function ZCompressStrEx(const s: AnsiString;
  level: TZCompressionLevel): AnsiString;
begin
  ZCompressStringEx(result, s, level);
end;

function  ZCompressStrEx(const s: AnsiString;
  level: TCompressionLevel = clNone): AnsiString; 
begin
  Result := ZCompressStrEx(s, TZCompressionLevel(Integer(level)));
end;

procedure ZCompressStringEx(var result: RawByteString; const s: AnsiString;
  level: TZCompressionLevel);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZCompress(Pointer(s), Length(s), buffer, size, level);

  SetLength(result, size + SizeOf(Integer));

  Move(buffer^, result[5], size);

  size := Length(s);

  Move(size, result[1], SizeOf(Integer));

  FreeMem(buffer);
end;

procedure ZCompressStringEx(var result: RawByteString; const s: UnicodeString;
  level: TZCompressionLevel);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZCompress(Pointer(s), Length(s) * SizeOf(UnicodeChar), buffer, size, level);

  SetLength(result, size + SizeOf(Integer));

  Move(buffer^, result[5], size);

  size := Length(s) * SizeOf(UnicodeChar);

  Move(size, result[1], SizeOf(Integer));

  FreeMem(buffer);
end;

function ZCompressStr2(const s: AnsiString; level: TZCompressionLevel;
  windowBits, memLevel: Integer; strategy: TZStrategy): AnsiString;
begin
  ZCompressString2(result, s, level, windowBits, memLevel, strategy);
end;

procedure ZCompressString2(var result: RawByteString; const s: AnsiString;
  level: TZCompressionLevel; windowBits, memLevel: Integer;
  strategy: TZStrategy);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZCompress2(Pointer(s), Length(s), buffer, size, level, windowBits,
    memLevel, strategy);

  SetLength(result, size);

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

procedure ZCompressString2(var result: RawByteString; const s: UnicodeString;
  level: TZCompressionLevel; windowBits, memLevel: Integer;
  strategy: TZStrategy);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZCompress2(Pointer(s), Length(s) * SizeOf(UnicodeChar), buffer, size,
    level, windowBits, memLevel, strategy);

  SetLength(result, size);

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

function ZCompressStrWeb(const s: AnsiString): AnsiString;
begin
  ZCompressStringWeb(result, s);
end;

procedure ZCompressStringWeb(var result: RawByteString; const s: AnsiString);
begin
  ZCompressString2(result, s, zcFastest, -15, 9, zsDefault);
end;

procedure ZCompressStringWeb(var result: RawBytestring;
  const s: UnicodeString);
begin
  ZCompressString2(result, s, zcFastest, -15, 9, zsDefault);
end;

function ZDecompressStr(const s: AnsiString): AnsiString;
begin
  ZDecompressString(result, s);
end;

procedure ZDecompressString(var result: AnsiString;
  const s: RawByteString);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZDecompress(Pointer(s), Length(s), buffer, size);

  SetLength(result, size);

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

procedure ZDecompressString(var result: UnicodeString;
  const s: RawByteString);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZDecompress(Pointer(s), Length(s), buffer, size);

  SetLength(result, size div SizeOf(UnicodeChar));

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

function ZDecompressStrEx(const s: AnsiString): AnsiString;
begin
  ZDecompressStringEx(result, s);
end;

procedure ZDecompressStringEx(var result: AnsiString; const s: RawByteString);
var
  buffer  : Pointer;
  size    : Integer;
  data    : AnsiString;
  dataSize: Integer;
begin
  Move(s[1], size, SizeOf(Integer));

  dataSize := Length(s) - SizeOf(Integer);

  SetLength(data, dataSize);

  Move(s[5], data[1], dataSize);

  ZDecompress(Pointer(data), dataSize, buffer, size, size);

  SetLength(result, size);

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

procedure ZDecompressStringEx(var result: UnicodeString;
  const s: RawByteString);
var
  buffer  : Pointer;
  size    : Integer;
  data    : AnsiString;
  dataSize: Integer;
begin
  Move(s[1], size, SizeOf(Integer));

  dataSize := Length(s) - SizeOf(Integer);

  SetLength(data, dataSize);

  Move(s[5], data[1], dataSize);

  ZDecompress(Pointer(data), dataSize, buffer, size, size);

  SetLength(result, size div SizeOf(UnicodeChar));

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

function ZDecompressStr2(const s: AnsiString;
  windowBits: Integer): AnsiString;
begin
  ZDecompressString2(result, s, windowBits);
end;

procedure ZDecompressString2(var result: AnsiString; const s: RawByteString;
  windowBits: Integer);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZDecompress2(Pointer(s), Length(s), buffer, size, windowBits);

  SetLength(result, size);

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

procedure ZDecompressString2(var result: UnicodeString;
  const s: RawByteString; windowBits: Integer);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZDecompress2(Pointer(s), Length(s), buffer, size, windowBits);

  SetLength(result, size div SizeOf(UnicodeChar));

  Move(buffer^, result[1], size);

  FreeMem(buffer);
end;

{** stream routines *********************************************************}

procedure ZInternalCompressStream(zstream: TZStreamRec; inStream,
  outStream: TStream);
const
  bufferSize = 32768;
var
  zresult  : Integer;
  inBuffer : Array [0..bufferSize-1] of Byte;
  outBuffer: Array [0..bufferSize-1] of Byte;
  outSize  : Integer;
begin
  zresult := Z_STREAM_END;

  zstream.avail_in := inStream.Read(inBuffer, bufferSize);

  while zstream.avail_in > 0 do
  begin
    zstream.next_in := @inBuffer;

    repeat
      zstream.next_out := @outBuffer;
      zstream.avail_out := bufferSize;

      zresult := ZCompressCheck(deflate(zstream, Z_NO_FLUSH));

      outSize := bufferSize - zstream.avail_out;

      outStream.Write(outBuffer, outSize);
    until (zresult = Z_STREAM_END) or (zstream.avail_in = 0);

    zstream.avail_in := inStream.Read(inBuffer, bufferSize);
  end;

  while zresult <> Z_STREAM_END do
  begin
    zstream.next_out := @outBuffer;
    zstream.avail_out := bufferSize;

    zresult := ZCompressCheck(deflate(zstream,Z_FINISH));

    outSize := bufferSize - zstream.avail_out;

    outStream.Write(outBuffer, outSize);
  end;

  ZCompressCheck(deflateEnd(zstream));
end;

procedure ZInternalDecompressStream(zstream: TZStreamRec; inStream,
  outStream: TStream);
const
  bufferSize = 32768;
var
  zresult  : Integer;
  inBuffer : Array [0..bufferSize-1] of Byte;
  outBuffer: Array [0..bufferSize-1] of Byte;
  outSize  : Integer;
begin
  zresult := Z_STREAM_END;

  zstream.avail_in := inStream.Read(inBuffer, bufferSize);

  while zstream.avail_in > 0 do
  begin
    zstream.next_in := @inBuffer;

    repeat
      zstream.next_out := @outBuffer;
      zstream.avail_out := bufferSize;

      zresult := ZDecompressCheck(inflate(zstream, Z_NO_FLUSH));

      outSize := bufferSize - zstream.avail_out;

      outStream.Write(outBuffer, outSize);
    until (zresult = Z_STREAM_END) or (zstream.avail_in = 0);

    if zresult <> Z_STREAM_END then
    begin
      zstream.avail_in := inStream.Read(inBuffer, bufferSize);
    end
    else if zstream.avail_in > 0 then
    begin
      inStream.Position := inStream.Position - zstream.avail_in;
      zstream.avail_in := 0;
    end;
  end;

  while zresult <> Z_STREAM_END do
  begin
    zstream.next_out := @outBuffer;
    zstream.avail_out := bufferSize;

    zresult := ZDecompressCheck(inflate(zstream,Z_FINISH));

    outSize := bufferSize - zstream.avail_out;

    outStream.Write(outBuffer, outSize);
  end;

  ZDecompressCheck(inflateEnd(zstream));
end;

procedure ZCompressStream(inStream, outStream: TStream;
  level: TZCompressionLevel);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZCompressCheck(DeflateInit(zstream,ZLevels[level]));

  ZInternalCompressStream(zstream,inStream,outStream);
end;

procedure ZCompressStream(inStream, outStream: TStream;
  level: TCompressionLevel);
begin
  ZCompressStream(inStream, outStream, TZCompressionLevel(Integer(level)));
end;  

procedure ZCompressStream2(inStream, outStream: TStream;
  level: TZCompressionLevel; windowBits, memLevel: Integer;
  strategy: TZStrategy);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZCompressCheck(DeflateInit2(zstream,ZLevels[level],Z_DEFLATED,windowBits,
    memLevel,ZStrategies[strategy]));

  ZInternalCompressStream(zstream,inStream,outStream);
end;

procedure ZCompressStreamWeb(inStream, outStream: TStream);
begin
  ZCompressStream2(inStream,outStream,zcFastest,-15,9,zsDefault);
end;

procedure ZDecompressStream(inStream, outStream: TStream);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZDecompressCheck(InflateInit(zstream));

  ZInternalDecompressStream(zstream,inStream,outStream);
end;

procedure ZDecompressStream2(inStream, outStream: TStream;
  windowBits: Integer);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream,SizeOf(TZStreamRec),0);

  ZDecompressCheck(InflateInit2(zstream,windowBits));

  ZInternalDecompressStream(zstream,inStream,outStream);
end;

{** checksum routines *******************************************************}

function ZAdler32(adler: Longint; const buffer; size: Integer): Longint;
begin
  result := adler32(adler,buffer,size);
end;

function ZCrc32(crc: Longint; const buffer; size: Integer): Longint;
begin
  result := crc32(crc,buffer,size);
end;

{** TCustomZStream **********************************************************}

constructor TCustomZStream.Create(stream: TStream);
begin
  inherited Create;

  FStream := stream;
  FStreamPos := stream.Position;
end;

function TCustomZStream.StreamRead(var buffer; count: Longint): Longint;
begin
  if FStream.Position <> FStreamPos then FStream.Position := FStreamPos;

  result := FStream.Read(buffer,count);

  FStreamPos := FStreamPos + result;
end;

function TCustomZStream.StreamWrite(const buffer; count: Longint): Longint;
begin
  if FStream.Position <> FStreamPos then FStream.Position := FStreamPos;

  result := FStream.Write(buffer,count);

  FStreamPos := FStreamPos + result;
end;

function TCustomZStream.StreamSeek(offset: Longint; origin: Word): Longint;
begin
  if FStream.Position <> FStreamPos then FStream.Position := FStreamPos;

  result := FStream.Seek(offset,origin);

  FStreamPos := FStream.Position;
end;

procedure TCustomZStream.StreamReadBuffer(var buffer; count: Longint);
begin
  if FStream.Position <> FStreamPos then FStream.Position := FStreamPos;

  FStream.ReadBuffer(buffer,count);

  FStreamPos := FStreamPos + count;
end;

procedure TCustomZStream.StreamWriteBuffer(const buffer; count: Longint);
begin
  if FStream.Position <> FStreamPos then FStream.Position := FStreamPos;

  FStream.WriteBuffer(buffer,count);

  FStreamPos := FStreamPos + count;
end;

procedure TCustomZStream.DoProgress;
begin
  if Assigned(FOnProgress) then FOnProgress(Self);
end;

function TCustomZStream.GetStreamPosition: TStreamPos;
begin
  result := FStream.Position;
end;

procedure TCustomZStream.SetStreamPosition(value: TStreamPos);
begin
  FStream.Position := value;
  FStreamPos := FStream.Position;
end;

{** TZCompressionStream *****************************************************}

constructor TZCompressionStream.Create(dest: TStream;
  compressionLevel: TZCompressionLevel);
begin
  inherited Create(dest);

  FZStream.next_out := @FBuffer;
  FZStream.avail_out := SizeOf(FBuffer);

  ZCompressCheck(DeflateInit(FZStream, ZLevels[compressionLevel]));
end;

constructor TZCompressionStream.Create(dest: TStream;
  compressionLevel: TZCompressionLevel; windowBits, memLevel: Integer;
  strategy: TZStrategy);
begin
  inherited Create(dest);

  FZStream.next_out := @FBuffer;
  FZStream.avail_out := SizeOf(FBuffer);

  ZCompressCheck(DeflateInit2(FZStream, ZLevels[compressionLevel], Z_DEFLATED,
    windowBits, memLevel, ZStrategies[strategy]));
end;

constructor TZCompressionStream.Create(compressionLevel: TCompressionLevel;
  dest: TStream);
begin
  Create(dest, TZCompressionLevel(Byte(compressionLevel)));
end;

destructor TZCompressionStream.Destroy;
begin
  FZStream.next_in := Nil;
  FZStream.avail_in := 0;

  try
    while ZCompressCheck(deflate(FZStream,Z_FINISH)) <> Z_STREAM_END do
    begin
      StreamWriteBuffer(FBuffer, SizeOf(FBuffer) - FZStream.avail_out);

      FZStream.next_out := @FBuffer;
      FZStream.avail_out := SizeOf(FBuffer);
    end;

    if FZStream.avail_out < SizeOf(FBuffer) then
    begin
      StreamWriteBuffer(FBuffer, SizeOf(FBuffer) - FZStream.avail_out);
    end;
  finally
    deflateEnd(FZStream);
  end;

  inherited Destroy;
end;

function TZCompressionStream.Read(var buffer; count: Longint): Longint;
begin
  raise EZCompressionError.Create(SZInvalid);
end;

function TZCompressionStream.Write(const buffer; count: Longint): Longint;
var
  writeCount: Longint;
begin
  result := count;

  FZStream.next_in := @buffer;
  FZStream.avail_in := count;

  while FZStream.avail_in > 0 do
  begin
    ZCompressCheck(deflate(FZStream,Z_NO_FLUSH));

    if FZStream.avail_out = 0 then
    begin
      writeCount := StreamWrite(FBuffer,SizeOf(FBuffer));

      if writeCount = SizeOf(FBuffer) then
      begin
        FZStream.next_out := @FBuffer;
        FZStream.avail_out := SizeOf(FBuffer);

        DoProgress;
      end
      else
      begin
        StreamPosition := StreamPosition - writeCount;

        result := count - FZStream.avail_in;

        FZStream.avail_in := 0;
      end;
    end;
  end;
end;

function TZCompressionStream.Seek(offset: Longint; origin: Word): Longint;
begin
  if (offset = 0) and (origin = soFromCurrent) then
  begin
    result := FZStream.total_in;
  end
  else raise EZCompressionError.Create(SZInvalid);
end;

function TZCompressionStream.GetCompressionRate: Single;
begin
  if FZStream.total_in = 0 then result := 0
  else result := (1.0 - (FZStream.total_out / FZStream.total_in)) * 100.0;
end;

{** TZDecompressionStream ***************************************************}

constructor TZDecompressionStream.Create(source: TStream);
begin
  inherited Create(source);

  FZStream.next_in := @FBuffer;
  FZStream.avail_in := 0;

  ZDecompressCheck(InflateInit(FZStream));
end;

constructor TZDecompressionStream.Create(source: TStream;
  windowBits: Integer);
begin
  inherited Create(source);

  FZStream.next_in := @FBuffer;
  FZStream.avail_in := 0;

  ZDecompressCheck(InflateInit2(FZStream,windowBits));
end;

destructor TZDecompressionStream.Destroy;
begin
  inflateEnd(FZStream);

  inherited Destroy;
end;

function TZDecompressionStream.Read(var buffer; count: Longint): Longint;
var
  zresult: Integer;
begin
  FZStream.next_out := @buffer;
  FZStream.avail_out := count;

  zresult := Z_OK;

  while (FZStream.avail_out > 0) and (zresult <> Z_STREAM_END) do
  begin
    if FZStream.avail_in = 0 then
    begin
      FZStream.avail_in := StreamRead(FBuffer,SizeOf(FBuffer));

      if FZStream.avail_in = 0 then
      begin
        result := count - FZStream.avail_out;

        Exit;
      end;

      FZStream.next_in := @FBuffer;

      DoProgress;
    end;

    zresult := ZDecompressCheck(inflate(FZStream,Z_NO_FLUSH));
  end;

  if (zresult = Z_STREAM_END) and (FZStream.avail_in > 0) then
  begin
    StreamPosition := StreamPosition - FZStream.avail_in;

    FZStream.avail_in := 0;
  end;

  result := count - FZStream.avail_out;
end;

function TZDecompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
  raise EZDecompressionError.Create(SZInvalid);
end;

function TZDecompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
var
  buf: Array [0..8191] of Byte;
  i  : Integer;
begin
  if (offset = 0) and (origin = soFromBeginning) then
  begin
    ZDecompressCheck(inflateReset(FZStream));

    FZStream.next_in := @FBuffer;
    FZStream.avail_in := 0;

    StreamPosition := 0;
  end
  else if ((offset >= 0) and (origin = soFromCurrent)) or
          (((offset - FZStream.total_out) > 0) and (origin = soFromBeginning)) then
  begin
    if origin = soFromBeginning then Dec(offset, FZStream.total_out);

    if offset > 0 then
    begin
      for i := 1 to offset div SizeOf(buf) do ReadBuffer(buf, SizeOf(buf));
      ReadBuffer(buf, offset mod SizeOf(buf));
    end;
  end
  else if (offset = 0) and (origin = soFromEnd) then
  begin
    while Read(buf, SizeOf(buf)) > 0 do ;
  end
  else raise EZDecompressionError.Create(SZInvalid);

  result := FZStream.total_out;
end;

{** EZLibError **************************************************************}

constructor EZLibError.Create(code: Integer; const dummy: String);
begin
  inherited Create(_z_errmsg[2 - code]);

  FErrorCode := code;
end;

constructor EZLibError.Create(error: TZError; const dummy: String);
begin
  Create(ZErrors[error],dummy);
end;

procedure CompressBuf(const InBuf: Pointer; InBytes: Integer;
                      out OutBuf: Pointer; out OutBytes: Integer);
begin
  ZCompress(InBuf, InBytes, OutBuf, OutBytes);
end;

procedure DecompressBuf(const InBuf: Pointer; InBytes: Integer;
  OutEstimate: Integer; out OutBuf: Pointer; out OutBytes: Integer);
begin
  ZDecompress(InBuf, InBytes, OutBuf, OutBytes, OutEstimate);
end;

resourcestring
 sTargetBufferTooSmall = 'ZLib error: target buffer may be too small';

procedure DecompressToUserBuf(const InBuf: Pointer; InBytes: Integer;
  const OutBuf: Pointer; BufSize: Integer);
var
  strm: TZStreamRec;
begin
  FillChar(strm, sizeof(strm), 0);
  strm.zalloc := zlibAllocMem;
  strm.zfree := zlibFreeMem;
  strm.next_in := InBuf;
  strm.avail_in := InBytes;
  strm.next_out := OutBuf;
  strm.avail_out := BufSize;
  ZCompressCheck(inflateInit_(strm, zlib_version, sizeof(strm)));
  try
    if ZCompressCheck(inflate(strm, Z_FINISH)) <> Z_STREAM_END then
      raise EZlibError.CreateRes(@sTargetBufferTooSmall);
  finally
    ZCompressCheck(inflateEnd(strm));
  end;
end;

function zlibAllocMem(AppData: Pointer; Items, Size: Integer): Pointer;
begin
  Result := AllocMem(Items * Size);
end;

procedure zlibFreeMem(AppData, Block: Pointer);
begin
  FreeMem(Block);
end;

end.
