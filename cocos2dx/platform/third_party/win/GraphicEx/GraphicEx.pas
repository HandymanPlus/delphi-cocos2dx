unit GraphicEx;

// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The original code is GraphicColor.pas, released November 1, 1999.
//
// The initial developer of the original code is Dipl. Ing. Mike Lischke (Pleißa, Germany, www.delphi-gems.com),
//
// Portions created by Dipl. Ing. Mike Lischke are Copyright
// (C) 1999-2003 Dipl. Ing. Mike Lischke. All Rights Reserved.
//----------------------------------------------------------------------------------------------------------------------
//
// GraphicEx -
//   This unit is an addendum to Graphics.pas, in order to enable your application
//   to import many common graphic files.
//
// See help file for a description of supported image types. Additionally, there is a resample routine
// (Stretch) based on code from Anders Melander (http://www.melander.dk/delphi/resampler/index.html)
// which has been optimized quite a lot to work faster and bug fixed.
//
// version - 9.9
//
// 03-SEP-2000 ml:
//   EPS with alpha channel, workaround for TIFs with wrong alpha channel indication,
//   workaround for bad packbits compressed (TIF) images
// 28-AUG-2000 ml:
//   small bugfixes
// 27-AUG-2000 ml:
//   changed all FreeMemory(P) calls back to ... if Assigned(P) then FreeMem(P); ...
// 24-AUG-2000 ml:
//   small bug in LZ77 decoder removed
// 18-AUG-2000 ml:
//   TIF deflate decoding scheme
// 15-AUG-2000 ml:
//   workaround for TIF images without compression, but prediction scheme set (which is not really used in this case)
// 12-AUG-2000 ml:
//   small changes
//
// For older history please look into the help file.
//
// Note: The library provides usually only load support for the listed image formats but will perhaps be enhanced
//       in the future to save those types too. It can be compiled with Delphi 4 or newer versions.
//
//----------------------------------------------------------------------------------------------------------------------

interface

{$DEFINE NoUseDelphi}

uses
  Windows,
  {$IFNDEF NoUseDelphi}Classes, Graphics, SysUtils,{$ELSE} delphiAtlas, {$ENDIF}
  GraphicCompression, GraphicStrings, GraphicColor;

type
  TCardinalArray = array of Cardinal;
  TByteArray = array of Byte;
  TFloatArray = array of Single;

  TImageOptions = set of (
    ioTiled, // image consists of tiles not strips (TIF)
    ioBigEndian, // byte order in values >= words is reversed (TIF, RLA, SGI)
    ioMinIsWhite, // minimum value in grayscale palette is white not black (TIF)
    ioReversed, // bit order in bytes is reveresed (TIF)
    ioUseGamma // gamma correction is used
    );

  // describes the compression used in the image file
  TCompressionType = (
    ctUnknown, // compression type is unknown
    ctNone, // no compression at all
    ctRLE, // run length encoding
    ctPackedBits, // Macintosh packed bits
    ctLZW, // Lempel-Zif-Welch
    ctFax3, // CCITT T.4 (1d), also known as fax group 3
    ctFaxRLE, // modified Huffman (CCITT T.4 derivative)
    ctFax4, // CCITT T.6, also known as fax group 4
    ctFaxRLEW, // CCITT T.4 with word alignment
    ctLZ77, // Hufman inflate/deflate
    ctJPEG, // TIF JPEG compression (new version)
    ctOJPEG, // TIF JPEG compression (old version)
    ctThunderscan, // TIF thunderscan compression
    ctNext,
    ctIT8CTPAD,
    ctIT8LW,
    ctIT8MP,
    ctIT8BL,
    ctPixarFilm,
    ctPixarLog,
    ctDCS,
    ctJBIG,
    ctPCDHuffmann // PhotoCD Hufman compression
    );

  // properties of a particular image which are set while loading an image or when
  // they are explicitly requested via ReadImageProperties
  PImageProperties = ^TImageProperties;
  TImageProperties = record
    Version: Cardinal; // TIF, PSP, GIF
    Options: TImageOptions; // all images
    Width, // all images
    Height: Cardinal; // all images
    ColorScheme: TColorScheme; // all images
    BitsPerSample, // all Images
    SamplesPerPixel, // all images
    BitsPerPixel: Byte; // all images
    Compression: TCompressionType; // all images
    FileGamma: Single; // RLA, PNG
    XResolution,
    YResolution: Single; // given in dpi (TIF, PCX, PSP)
    Interlaced, // GIF, PNG
    HasAlpha: Boolean; // TIF, PNG
    // informational data, used internally and/or by decoders
    // TIF
    FirstIFD,
    PlanarConfig, // most of this data is needed in the JPG decoder
    CurrentRow,
    TileWidth,
    TileLength,
    BytesPerLine: Cardinal;
    RowsPerStrip: TCardinalArray;
    YCbCrSubSampling,
    JPEGTables: TByteArray;
    JPEGColorMode,
    JPEGTablesMode: Cardinal;
    CurrentStrip,
    StripCount,
    Predictor: Integer;
    // PCD
    Overview: Boolean; // true if image is an overview image
    Rotate: Byte; // describes how the image is rotated (aka landscape vs. portrait image)
    ImageCount: Word; // number of subimages if this is an overview image
    // GIF
    LocalColorTable: Boolean; // image uses an own color palette instead of the global one
    // RLA
    BottomUp: Boolean; // images is bottom to top
    // PSD
    Channels: Byte; // up to 24 channels per image
    // PNG
    FilterMode: Byte;
  end;

  {$IFDEF NoUseDelphi}
  TProgressStage = (psStarting, psRunning, psEnding);
  TProgressEvent = procedure (Sender: TObject; Stage: TProgressStage;
    PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string) of object;

  HPALETTE = Cardinal;

  TBitmap = class
  public
    fData: PByte;
  private
    fWidth, fHeight: Cardinal;
    fPixelFormat: TPixelFormat;
    fTransparent: Boolean;
    fBytesPerRow: Cardinal;
    fPixelBitCount: Cardinal;
    function GetEmpty: Boolean;
    function getHeight: Integer;
    function GetPixelFormat: TPixelFormat;
    function GetScanLine(Row: Integer): Pointer;
    function GetTransparent: Boolean;
    function getWidth: Integer;
    procedure setHeight(const Value: Integer);
    procedure SetPixelFormat(const Value: TPixelFormat);
    procedure SetTransparent(const Value: Boolean);
    procedure setWidth(const Value: Integer);
    procedure CreateMemory();
    function getHasAlpha: Boolean;
    function getPixelBitCount: Integer;
  protected
    Handle: Cardinal;
    Palette: HPALETTE;
    procedure Progress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte;  RedrawNow: Boolean; const R: TRect; const Msg: string); dynamic;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure LoadFromFile(Filename: string);
    procedure SaveToFile(Filename: string);
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
  public
    property Width: Integer read getWidth write setWidth;
    property Height: Integer read getHeight write setHeight;
    property PixelFormat: TPixelFormat read GetPixelFormat write SetPixelFormat;
    property ScanLine[Row: Integer]: Pointer read GetScanLine;
    property Transparent: Boolean read GetTransparent write SetTransparent;
    property Empty: Boolean read GetEmpty;
    property HasAlpha: Boolean read getHasAlpha;
    property PixelBitCount: Integer read getPixelBitCount;
  end;
  {$ENDIF}

  // This is the general base class for all image types implemented in GraphicEx.
  // It contains some generally used class/data.
  TGraphicExGraphic = class(TBitmap)
  private
    FColorManager: TColorManager;
    FImageProperties: TImageProperties;
    FBasePosition: Cardinal; // stream start position
    //FStream: TStream; // used for local references of the stream the class is currently loading from
    //FProgressRect: TRect;
  public
    constructor Create; override;
    destructor Destroy; override;

    class function CanLoad(const FileName: string): Boolean; overload; virtual;
    class function CanLoad(Stream: TStream): Boolean; overload; virtual;
    {$IFNDEF NoUseDelphi}
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromResourceName(Instance: THandle; const ResName: string);
    procedure LoadFromResourceID(Instance: THandle; ResID: Integer);
    {$ENDIF}

    function ReadImageProperties(Stream: TStream; ImageIndex: Cardinal): Boolean; virtual;

    property ColorManager: TColorManager read FColorManager;
    property ImageProperties: TImageProperties read FImageProperties write FImageProperties;
  end;

  TTargaGraphic = class(TGraphicExGraphic)
  public
    class function CanLoad(Stream: TStream): Boolean; override;
    procedure LoadFromStream(Stream: TStream); override;
    function ReadImageProperties(Stream: TStream; ImageIndex: Cardinal): Boolean; override;
    procedure SaveToStream(Stream: TStream); overload; override;
    procedure SaveToStream(Stream: TStream; Compressed: Boolean); reintroduce; overload;
  end;

  TIFDEntry = packed record
    Tag: Word;
    DataType: Word;
    DataLength: Cardinal;
    Offset: Cardinal;
  end;

  TTIFFPalette = array[0..787] of Word;

  TTIFFGraphic = class(TGraphicExGraphic)
  private
    FIFD: array of TIFDEntry; // the tags of one image file directory
    FPalette: TTIFFPalette;
    FYCbCrPositioning: Cardinal;
    FYCbCrCoefficients: TFloatArray;
    function FindTag(Tag: Cardinal; var Index: Cardinal): Boolean;
    procedure GetValueList(Stream: TStream; Tag: Cardinal; var Values: TByteArray); overload;
    procedure GetValueList(Stream: TStream; Tag: Cardinal; var Values: TCardinalArray); overload;
    procedure GetValueList(Stream: TStream; Tag: Cardinal; var Values: TFloatArray); overload;
    function GetValue(Stream: TStream; Tag: Cardinal; Default: Single = 0): Single; overload;
    function GetValue(Tag: Cardinal; Default: Cardinal = 0): Cardinal; overload;
    function GetValue(Tag: Cardinal; var Size: Cardinal; Default: Cardinal = 0): Cardinal; overload;
    procedure SortIFD;
    procedure SwapIFD;
  public
    class function CanLoad(Stream: TStream): Boolean; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    function ReadImageProperties(Stream: TStream; ImageIndex: Cardinal): Boolean; override;
  end;

  TGraphicExGraphicClass = class of TGraphicExGraphic;

implementation
uses
  {$IFDEF NoUseDelphi} RTLConsts, SysConst, {$ENDIF} MZLib;

procedure GraphicExError(ErrorString: string); overload;
begin
  //raise EInvalidGraphic.Create(ErrorString);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure GraphicExError(ErrorString: string; Args: array of const); overload;
begin
  //raise EInvalidGraphic.CreateFmt(ErrorString, Args);
end;

//----------------- support functions for image loading ----------------------------------------------------------------

procedure SwapShort(P: PWord; Count: Cardinal);
// swaps high and low byte of 16 bit values
// EAX contains P, EDX contains Count
asm
@@Loop:
              MOV CX, [EAX]
              XCHG CH, CL
              MOV [EAX], CX
              ADD EAX, 2
              DEC EDX
              JNZ @@Loop
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SwapLong(P: PInteger; Count: Cardinal); overload;
// swaps high and low bytes of 32 bit values
// EAX contains P, EDX contains Count
asm
@@Loop:
              MOV ECX, [EAX]
              BSWAP ECX
              MOV [EAX], ECX
              ADD EAX, 4
              DEC EDX
              JNZ @@Loop
end;

//----------------------------------------------------------------------------------------------------------------------

function SwapLong(Value: Cardinal): Cardinal; overload;
// swaps high and low bytes of the given 32 bit value
asm
              BSWAP EAX
end;

//----------------- various conversion routines ------------------------------------------------------------------------

procedure Depredict1(P: Pointer; Count: Cardinal);
// EAX contains P and EDX Count
asm
@@1:
              MOV CL, [EAX]
              ADD [EAX + 1], CL
              INC EAX
              DEC EDX
              JNZ @@1
end;

//----------------------------------------------------------------------------------------------------------------------

procedure Depredict3(P: Pointer; Count: Cardinal);
// EAX contains P and EDX Count
asm
              MOV ECX, EDX
              SHL ECX, 1
              ADD ECX, EDX         // 3 * Count
@@1:
              MOV DL, [EAX]
              ADD [EAX + 3], DL
              INC EAX
              DEC ECX
              JNZ @@1
end;

//----------------------------------------------------------------------------------------------------------------------

procedure Depredict4(P: Pointer; Count: Cardinal);
// EAX contains P and EDX Count
asm
              SHL EDX, 2          // 4 * Count
@@1:
              MOV CL, [EAX]
              ADD [EAX + 4], CL
              INC EAX
              DEC EDX
              JNZ @@1
end;

{TGraphicExGraphic}

constructor TGraphicExGraphic.Create;
begin
  inherited;
  FColorManager := TColorManager.Create;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TGraphicExGraphic.Destroy;
begin
  FColorManager.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

class function TGraphicExGraphic.CanLoad(const FileName: string): Boolean;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, 0);
  try
    Result := CanLoad(Stream);
  finally
    Stream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

class function TGraphicExGraphic.CanLoad(Stream: TStream): Boolean;
// Descentants have to override this method and return True if they consider the data in Stream
// as loadable by the particular class.
// Note: Make sure the stream position is the same on exit as it was on enter!
begin
  Result := False;
end;

{$IFNDEF NoUseDelphi}
procedure TGraphicExGraphic.Assign(Source: TPersistent);
begin
  if Source is TGraphicExGraphic then FImageProperties := TGraphicExGraphic(Source).FImageProperties;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TGraphicExGraphic.LoadFromResourceID(Instance: THandle; ResID: Integer);
var
  Stream: TResourceStream;
begin
  Stream := TResourceStream.CreateFromID(Instance, ResID, RT_RCDATA);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TGraphicExGraphic.LoadFromResourceName(Instance: THandle; const ResName: string);
var
  Stream: TResourceStream;
begin
  Stream := TResourceStream.Create(Instance, ResName, RT_RCDATA);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;
{$ENDIF}
//----------------------------------------------------------------------------------------------------------------------

function TGraphicExGraphic.ReadImageProperties(Stream: TStream; ImageIndex: Cardinal): Boolean;
// Initializes the internal image properties structure.
// Descentants must override this method to fill in the actual values.
// Result is always False to show there is no image to load.
begin
  Finalize(FImageProperties);
  ZeroMemory(@FImageProperties, SizeOf(FImageProperties));
  FImageProperties.FileGamma := 1;
  Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

//----------------- TTargaGraphic --------------------------------------------------------------------------------------

{.$IFDEF TargaGraphic}

//  FILE STRUCTURE FOR THE ORIGINAL TRUEVISION TGA FILE
//    FIELD 1: NUMBER OF CHARACTERS IN ID FIELD (1 BYTES)
//    FIELD 2: COLOR MAP TYPE (1 BYTES)
//    FIELD 3: IMAGE TYPE CODE (1 BYTES)
//      = 0  NO IMAGE DATA INCLUDED
//      = 1  UNCOMPRESSED, COLOR-MAPPED IMAGE
//      = 2  UNCOMPRESSED, TRUE-COLOR IMAGE
//      = 3  UNCOMPRESSED, BLACK AND WHITE IMAGE (black and white is actually grayscale)
//      = 9  RUN-LENGTH ENCODED COLOR-MAPPED IMAGE
//      = 10 RUN-LENGTH ENCODED TRUE-COLOR IMAGE
//      = 11 RUN-LENGTH ENCODED BLACK AND WHITE IMAGE
//    FIELD 4: COLOR MAP SPECIFICATION (5 BYTES)
//      4.1: COLOR MAP ORIGIN (2 BYTES)
//      4.2: COLOR MAP LENGTH (2 BYTES)
//      4.3: COLOR MAP ENTRY SIZE (1 BYTES)
//    FIELD 5:IMAGE SPECIFICATION (10 BYTES)
//      5.1: X-ORIGIN OF IMAGE (2 BYTES)
//      5.2: Y-ORIGIN OF IMAGE (2 BYTES)
//      5.3: WIDTH OF IMAGE (2 BYTES)
//      5.4: HEIGHT OF IMAGE (2 BYTES)
//      5.5: IMAGE PIXEL SIZE (1 BYTE)
//      5.6: IMAGE DESCRIPTOR BYTE (1 BYTE)
//        bit 0..3: attribute bits per pixel
//        bit 4..5: image orientation:
//          0: bottom left
//          1: bottom right
//          2: top left
//          3: top right
//        bit 6..7: interleaved flag
//          0: two way (even-odd) interleave (e.g. IBM Graphics Card Adapter), obsolete
//          1: four way interleave (e.g. AT&T 6300 High Resolution), obsolete
//    FIELD 6: IMAGE ID FIELD (LENGTH SPECIFIED BY FIELD 1)
//    FIELD 7: COLOR MAP DATA (BIT WIDTH SPECIFIED BY FIELD 4.3 AND
//             NUMBER OF COLOR MAP ENTRIES SPECIFIED IN FIELD 4.2)
//    FIELD 8: IMAGE DATA FIELD (WIDTH AND HEIGHT SPECIFIED IN FIELD 5.3 AND 5.4)

const
  TARGA_NO_COLORMAP = 0;
  TARGA_COLORMAP = 1;

  TARGA_EMPTY_IMAGE = 0;
  TARGA_INDEXED_IMAGE = 1;
  TARGA_TRUECOLOR_IMAGE = 2;
  TARGA_BW_IMAGE = 3;
  TARGA_INDEXED_RLE_IMAGE = 9;
  TARGA_TRUECOLOR_RLE_IMAGE = 10;
  TARGA_BW_RLE_IMAGE = 11;

type
  TTargaHeader = packed record
    IDLength,
    ColorMapType,
    ImageType: Byte;
    ColorMapOrigin,
    ColorMapSize: Word;
    ColorMapEntrySize: Byte;
    XOrigin,
    YOrigin,
    Width,
    Height: Word;
    PixelSize: Byte;
    ImageDescriptor: Byte;
  end;


  //----------------------------------------------------------------------------------------------------------------------

class function TTargaGraphic.CanLoad(Stream: TStream): Boolean;

var
  Header: TTargaHeader;
  LastPosition: Cardinal;

begin
  with Stream do
  begin
    LastPosition := Position;
    Result := (Size - Position) > SizeOf(Header);
    if Result then
    begin
      ReadBuffer(Header, SizeOf(Header));
      // Targa images are hard to determine because there is no magic id or something like that.
      // Hence all we can do is to check if all values from the header are within correct limits.
      Result := (Header.ImageType in [TARGA_EMPTY_IMAGE, TARGA_INDEXED_IMAGE, TARGA_TRUECOLOR_IMAGE, TARGA_BW_IMAGE,
        TARGA_INDEXED_RLE_IMAGE, TARGA_TRUECOLOR_RLE_IMAGE, TARGA_BW_RLE_IMAGE]) and
        (Header.ColorMapType in [TARGA_NO_COLORMAP, TARGA_COLORMAP]) and
        (Header.ColorMapEntrySize in [15, 16, 24, 32]) and
        (Header.PixelSize in [8, 15, 16, 24, 32]);
    end;
    Position := LastPosition;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.LoadFromStream(Stream: TStream);
var
  Run, RLEBuffer: PAnsiChar;
  I: Integer;
  LineSize: Integer;
  LineBuffer: Pointer;
  ReadLength: Integer;
  LogPalette: TMaxLogPalette;
  Color16: Word;
  Header: TTargaHeader;
  FlipV: Boolean;
  Decoder: TTargaRLEDecoder;
begin
  Handle := 0;
  FBasePosition := Stream.Position;
  if ReadImageProperties(Stream, 0) then
    with Stream, FImageProperties do
    begin
      Stream.Position := FBasePosition;

      //FProgressRect := Rect(0, 0, Width, 1);
      //Progress(Self, psStarting, 0, False, FProgressRect, gesPreparing);

      Stream.Read(Header, SizeOf(Header));
      FlipV := (Header.ImageDescriptor and $20) <> 0;
      Header.ImageDescriptor := Header.ImageDescriptor and $F;

      // skip image ID
      Seek(Header.IDLength, soFromCurrent);

      with ColorManager do
      begin
        SourceSamplesPerPixel := SamplesPerPixel;
        TargetSamplesPerPixel := SamplesPerPixel;
        SourceColorScheme := ColorScheme;
        SourceOptions := [];
        TargetColorScheme := csBGR;
        SourceBitsPerSample := BitsPerSample;
        TargetBitsPerSample := BitsPerSample;
        PixelFormat := TargetPixelFormat;
      end;

      if (Header.ColorMapType = TARGA_COLORMAP) or
        (Header.ImageType in [TARGA_BW_IMAGE, TARGA_BW_RLE_IMAGE]) then
      begin
        if Header.ImageType in [TARGA_BW_IMAGE, TARGA_BW_RLE_IMAGE] then
          Palette := ColorManager.CreateGrayscalePalette(False)
        else
        begin
          LineSize := (Header.ColorMapEntrySize div 8) * Header.ColorMapSize;
          GetMem(LineBuffer, LineSize);
          try
            ReadBuffer(LineBuffer^, LineSize);
            case Header.ColorMapEntrySize of
              32:
                Palette := ColorManager.CreateColorPalette([LineBuffer], pfInterlaced8Quad, Header.ColorMapSize, True);
              24:
                Palette := ColorManager.CreateColorPalette([LineBuffer], pfInterlaced8Triple, Header.ColorMapSize, True);
            else
              with LogPalette do
              begin
                // read palette entries and create a palette
                ZeroMemory(@LogPalette, SizeOf(LogPalette));
                palVersion := $300;
                palNumEntries := Header.ColorMapSize;

                // 15 and 16 bits per color map entry (handle both like 555 color format
                // but make 8 bit from 5 bit per color component)
                for I := 0 to Header.ColorMapSize - 1 do
                begin
                  Stream.Read(Color16, 2);
                  palPalEntry[I].peBlue := (Color16 and $1F) shl 3;
                  palPalEntry[I].peGreen := (Color16 and $3E0) shr 2;
                  palPalEntry[I].peRed := (Color16 and $7C00) shr 7;
                end;
                Palette := CreatePalette(PLogPalette(@LogPalette)^);
              end;
            end;
          finally
            if Assigned(LineBuffer) then FreeMem(LineBuffer);
          end;
        end;
      end;

      Self.Width := Header.Width;
      Self.Height := Header.Height;

      LineSize := Width * (Header.PixelSize div 8);
      //Progress(Self, psEnding, 0, False, FProgressRect, '');

      //Progress(Self, psStarting, 0, False, FProgressRect, gesTransfering);
      case Header.ImageType of
        TARGA_EMPTY_IMAGE: // nothing to do here
          ;
        TARGA_BW_IMAGE,
          TARGA_INDEXED_IMAGE,
          TARGA_TRUECOLOR_IMAGE:
          begin
            for I := 0 to Height - 1 do
            begin
              if FlipV then LineBuffer := ScanLine[I]
              else LineBuffer := ScanLine[Header.Height - (I + 1)];
              ReadBuffer(LineBuffer^, LineSize);
              //Progress(Self, psRunning, MulDiv(I, 100, Height), True, FProgressRect, '');
              //OffsetRect(FProgressRect, 0, 1);
            end;
          end;
        TARGA_BW_RLE_IMAGE,
          TARGA_INDEXED_RLE_IMAGE,
          TARGA_TRUECOLOR_RLE_IMAGE:
          begin
            RLEBuffer := nil;
            Decoder := TTargaRLEDecoder.Create(Header.PixelSize);
            try
              GetMem(RLEBuffer, 2 * LineSize);
              for I := 0 to Height - 1 do
              begin
                if FlipV then LineBuffer := ScanLine[I]
                else LineBuffer := ScanLine[Header.Height - (I + 1)];
                ReadLength := Stream.Read(RLEBuffer^, 2 * LineSize);
                Run := RLEBuffer;
                Decoder.Decode(Pointer(Run), LineBuffer, 2 * LineSize, Width);
                Stream.Position := Stream.Position - ReadLength + (Run - RLEBuffer);
                //Progress(Self, psRunning, MulDiv(I, 100, Height), True, FProgressRect, '');
                //OffsetRect(FProgressRect, 0, 1);
              end;
            finally
              if Assigned(RLEBuffer) then FreeMem(RLEBuffer);
              Decoder.Free;
            end;
          end;
      end;
      //Progress(Self, psEnding, 0, False, FProgressRect, '');
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTargaGraphic.ReadImageProperties(Stream: TStream; ImageIndex: Cardinal): Boolean;

var
  Header: TTargaHeader;

begin
  inherited ReadImageProperties(Stream, ImageIndex);
  with Stream, FImageProperties do
  begin
    ReadBuffer(Header, SizeOf(Header));
    Header.ImageDescriptor := Header.ImageDescriptor and $F;

    Width := Header.Width;
    Height := Header.Height;
    BitsPerSample := 8;

    case Header.PixelSize of
      8:
        begin
          if Header.ImageType in [TARGA_BW_IMAGE, TARGA_BW_RLE_IMAGE] then ColorScheme := csG
          else ColorScheme := csIndexed;
          SamplesPerPixel := 1;
        end;
      15,
        16: // actually, 16 bit are meant being 15 bit
        begin
          ColorScheme := csRGB;
          BitsPerSample := 5;
          SamplesPerPixel := 3;
        end;
      24:
        begin
          ColorScheme := csRGB;
          SamplesPerPixel := 3;
        end;
      32:
        begin
          ColorScheme := csRGBA;
          SamplesPerPixel := 4;
        end;
    end;

    BitsPerPixel := SamplesPerPixel * BitsPerSample;
    if Header.ImageType in [TARGA_BW_RLE_IMAGE, TARGA_INDEXED_RLE_IMAGE, TARGA_TRUECOLOR_RLE_IMAGE]
      then Compression := ctRLE
    else Compression := ctNone;

    Width := Header.Width;
    Height := Header.Height;
    Result := True;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.SaveToStream(Stream: TStream);

begin
  SaveToStream(Stream, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.SaveToStream(Stream: TStream; Compressed: Boolean);

// The format of the image to be saved depends on the current properties of the bitmap not
// on the values which may be set in the header during a former load.

var
  RLEBuffer: Pointer;
  I: Integer;
  LineSize: Integer;
  WriteLength: Cardinal;
  LogPalette: TMaxLogPalette;
  BPP: Byte;
  Header: TTargaHeader;
  Encoder: TTargaRLEDecoder;

begin
  //FProgressRect := Rect(0, 0, Width, 1);
  //Progress(Self, psStarting, 0, False, FProgressRect, gesPreparing);
  // prepare color depth
  case PixelFormat of
    pf1Bit,
      pf4Bit: // Note: 1 bit and 4 bits per pixel are not supported in the Targa format, an image
      //       with one of these pixel formats is implicitly converted to 256 colors.
      begin
        PixelFormat := pf8Bit;
        BPP := 1;
      end;
    pf8Bit:
      BPP := 1;
    pf15Bit,
      pf16Bit:
      BPP := 2;
    pf24Bit:
      BPP := 3;
    pf32Bit:
      BPP := 4;
  else
    BPP := 3;//BPP := GetDeviceCaps(Canvas.Handle, BITSPIXEL) div 8;
  end;

  if not Empty then
  begin
    with Header do
    begin
      IDLength := 0;
      if BPP = 1 then ColorMapType := 1
      else ColorMapType := 0;
      if not Compressed then
        // can't distinct between a B&W and an color indexed image here, so I use always the latter
        if BPP = 1 then ImageType := TARGA_INDEXED_IMAGE
        else ImageType := TARGA_TRUECOLOR_IMAGE
      else
        if BPP = 1 then ImageType := TARGA_INDEXED_RLE_IMAGE
        else ImageType := TARGA_TRUECOLOR_RLE_IMAGE;

      ColorMapOrigin := 0;
      // always save entire palette
      ColorMapSize := 256;
      // always save complete color information
      ColorMapEntrySize := 24;
      XOrigin := 0;
      YOrigin := 0;
      Width := Self.Width;
      Height := Self.Height;
      PixelSize := 8 * BPP;
      // if the image is a bottom-up DIB then indicate this in the image descriptor
      if Cardinal(ScanLine[0]) > Cardinal(ScanLine[1]) then ImageDescriptor := $20
      else ImageDescriptor := 0;
    end;

    Stream.Write(Header, SizeOf(Header));

    // store color palette if necessary
    if Header.ColorMapType = 1 then
      with LogPalette do
      begin
        // read palette entries
        GetPaletteEntries(Palette, 0, 256, palPalEntry);
        for I := 0 to 255 do
        begin
          Stream.Write(palPalEntry[I].peBlue, 1);
          Stream.Write(palPalEntry[I].peGreen, 1);
          Stream.Write(palPalEntry[I].peRed, 1);
        end;
      end;

    LineSize := Width * (Header.PixelSize div 8);
    //Progress(Self, psEnding, 0, False, FProgressRect, '');

    //Progress(Self, psStarting, 0, False, FProgressRect, gesTransfering);
    // finally write image data
    if Compressed then
    begin
      RLEBuffer := nil;
      Encoder := TTargaRLEDecoder.Create(Header.PixelSize);
      try
        GetMem(RLEBuffer, 2 * LineSize);
        for I := 0 to Height - 1 do
        begin
          Encoder.Encode(ScanLine[I], RLEBuffer, Width, WriteLength);
          Stream.WriteBuffer(RLEBuffer^, WriteLength);

          //Progress(Self, psRunning, 0, False, FProgressRect, '');
          //OffsetRect(FProgressRect, 0, 1);
        end;
      finally
        if Assigned(RLEBuffer) then FreeMem(RLEBuffer);
        Encoder.Free;
      end;
    end
    else
    begin
      for I := 0 to Height - 1 do
      begin
        Stream.WriteBuffer(ScanLine[I]^, LineSize);

        //Progress(Self, psRunning, 0, False, FProgressRect, '');
        //OffsetRect(FProgressRect, 0, 1);
      end;
    end;

    //Progress(Self, psEnding, 0, False, FProgressRect, '');
  end;
end;

//---------------------------------------------------------------------------------------------
//----------------- TTIFFGraphic ---------------------------------------------------------------------------------------

{.$IFDEF TIFFGraphic}

const // TIFF tags
  TIFFTAG_SUBFILETYPE = 254; // subfile data descriptor
  FILETYPE_REDUCEDIMAGE = $1; // reduced resolution version
  FILETYPE_PAGE = $2; // one page of many
  FILETYPE_MASK = $4; // transparency mask
  TIFFTAG_OSUBFILETYPE = 255; // kind of data in subfile (obsolete by revision 5.0)
  OFILETYPE_IMAGE = 1; // full resolution image data
  OFILETYPE_REDUCEDIMAGE = 2; // reduced size image data
  OFILETYPE_PAGE = 3; // one page of many
  TIFFTAG_IMAGEWIDTH = 256; // image width in pixels
  TIFFTAG_IMAGELENGTH = 257; // image height in pixels
  TIFFTAG_BITSPERSAMPLE = 258; // bits per channel (sample)
  TIFFTAG_COMPRESSION = 259; // data compression technique
  COMPRESSION_NONE = 1; // dump mode
  COMPRESSION_CCITTRLE = 2; // CCITT modified Huffman RLE
  COMPRESSION_CCITTFAX3 = 3; // CCITT Group 3 fax encoding
  COMPRESSION_CCITTFAX4 = 4; // CCITT Group 4 fax encoding
  COMPRESSION_LZW = 5; // Lempel-Ziv & Welch
  COMPRESSION_OJPEG = 6; // 6.0 JPEG (old version)
  COMPRESSION_JPEG = 7; // JPEG DCT compression (new version)
  COMPRESSION_ADOBE_DEFLATE = 8; // new id but same as COMPRESSION_DEFLATE
  COMPRESSION_NEXT = 32766; // next 2-bit RLE
  COMPRESSION_CCITTRLEW = 32771; // modified Huffman with word alignment
  COMPRESSION_PACKBITS = 32773; // Macintosh RLE
  COMPRESSION_THUNDERSCAN = 32809; // ThunderScan RLE
  // codes 32895-32898 are reserved for ANSI IT8 TIFF/IT <dkelly@etsinc.com)
  COMPRESSION_IT8CTPAD = 32895; // IT8 CT w/padding
  COMPRESSION_IT8LW = 32896; // IT8 Linework RLE
  COMPRESSION_IT8MP = 32897; // IT8 Monochrome picture
  COMPRESSION_IT8BL = 32898; // IT8 Binary line art
  // compression codes 32908-32911 are reserved for Pixar
  COMPRESSION_PIXARFILM = 32908; // Pixar companded 10bit LZW
  COMPRESSION_PIXARLOG = 32909; // Pixar companded 11bit ZIP
  COMPRESSION_DEFLATE = 32946; // Deflate compression (LZ77)
  // compression code 32947 is reserved for Oceana Matrix <dev@oceana.com>
  COMPRESSION_DCS = 32947; // Kodak DCS encoding
  COMPRESSION_JBIG = 34661; // ISO JBIG
  TIFFTAG_PHOTOMETRIC = 262; // photometric interpretation
  PHOTOMETRIC_MINISWHITE = 0; // min value is white
  PHOTOMETRIC_MINISBLACK = 1; // min value is black
  PHOTOMETRIC_RGB = 2; // RGB color model
  PHOTOMETRIC_PALETTE = 3; // color map indexed
  PHOTOMETRIC_MASK = 4; // holdout mask
  PHOTOMETRIC_SEPARATED = 5; // color separations
  PHOTOMETRIC_YCBCR = 6; // CCIR 601
  PHOTOMETRIC_CIELAB = 8; // 1976 CIE L*a*b*
  TIFFTAG_THRESHHOLDING = 263; // thresholding used on data (obsolete by revision 5.0)
  THRESHHOLD_BILEVEL = 1; // b&w art scan
  THRESHHOLD_HALFTONE = 2; // or dithered scan
  THRESHHOLD_ERRORDIFFUSE = 3; // usually floyd-steinberg
  TIFFTAG_CELLWIDTH = 264; // dithering matrix width (obsolete by revision 5.0)
  TIFFTAG_CELLLENGTH = 265; // dithering matrix height (obsolete by revision 5.0)
  TIFFTAG_FILLORDER = 266; // data order within a Byte
  FILLORDER_MSB2LSB = 1; // most significant -> least
  FILLORDER_LSB2MSB = 2; // least significant -> most
  TIFFTAG_DOCUMENTNAME = 269; // name of doc. image is from
  TIFFTAG_IMAGEDESCRIPTION = 270; // info about image
  TIFFTAG_MAKE = 271; // scanner manufacturer name
  TIFFTAG_MODEL = 272; // scanner model name/number
  TIFFTAG_STRIPOFFSETS = 273; // Offsets to data strips
  TIFFTAG_ORIENTATION = 274; // image FOrientation (obsolete by revision 5.0)
  ORIENTATION_TOPLEFT = 1; // row 0 top, col 0 lhs
  ORIENTATION_TOPRIGHT = 2; // row 0 top, col 0 rhs
  ORIENTATION_BOTRIGHT = 3; // row 0 bottom, col 0 rhs
  ORIENTATION_BOTLEFT = 4; // row 0 bottom, col 0 lhs
  ORIENTATION_LEFTTOP = 5; // row 0 lhs, col 0 top
  ORIENTATION_RIGHTTOP = 6; // row 0 rhs, col 0 top
  ORIENTATION_RIGHTBOT = 7; // row 0 rhs, col 0 bottom
  ORIENTATION_LEFTBOT = 8; // row 0 lhs, col 0 bottom
  TIFFTAG_SAMPLESPERPIXEL = 277; // samples per pixel
  TIFFTAG_ROWSPERSTRIP = 278; // rows per strip of data
  TIFFTAG_STRIPBYTECOUNTS = 279; // bytes counts for strips
  TIFFTAG_MINSAMPLEVALUE = 280; // minimum sample value (obsolete by revision 5.0)
  TIFFTAG_MAXSAMPLEVALUE = 281; // maximum sample value (obsolete by revision 5.0)
  TIFFTAG_XRESOLUTION = 282; // pixels/resolution in x
  TIFFTAG_YRESOLUTION = 283; // pixels/resolution in y
  TIFFTAG_PLANARCONFIG = 284; // storage organization
  PLANARCONFIG_CONTIG = 1; // single image plane
  PLANARCONFIG_SEPARATE = 2; // separate planes of data
  TIFFTAG_PAGENAME = 285; // page name image is from
  TIFFTAG_XPOSITION = 286; // x page offset of image lhs
  TIFFTAG_YPOSITION = 287; // y page offset of image lhs
  TIFFTAG_FREEOFFSETS = 288; // byte offset to free block (obsolete by revision 5.0)
  TIFFTAG_FREEBYTECOUNTS = 289; // sizes of free blocks (obsolete by revision 5.0)
  TIFFTAG_GRAYRESPONSEUNIT = 290; // gray scale curve accuracy
  GRAYRESPONSEUNIT_10S = 1; // tenths of a unit
  GRAYRESPONSEUNIT_100S = 2; // hundredths of a unit
  GRAYRESPONSEUNIT_1000S = 3; // thousandths of a unit
  GRAYRESPONSEUNIT_10000S = 4; // ten-thousandths of a unit
  GRAYRESPONSEUNIT_100000S = 5; // hundred-thousandths
  TIFFTAG_GRAYRESPONSECURVE = 291; // gray scale response curve
  TIFFTAG_GROUP3OPTIONS = 292; // 32 flag bits
  GROUP3OPT_2DENCODING = $1; // 2-dimensional coding
  GROUP3OPT_UNCOMPRESSED = $2; // data not compressed
  GROUP3OPT_FILLBITS = $4; // fill to byte boundary
  TIFFTAG_GROUP4OPTIONS = 293; // 32 flag bits
  GROUP4OPT_UNCOMPRESSED = $2; // data not compressed
  TIFFTAG_RESOLUTIONUNIT = 296; // units of resolutions
  RESUNIT_NONE = 1; // no meaningful units
  RESUNIT_INCH = 2; // english
  RESUNIT_CENTIMETER = 3; // metric
  TIFFTAG_PAGENUMBER = 297; // page numbers of multi-page
  TIFFTAG_COLORRESPONSEUNIT = 300; // color curve accuracy
  COLORRESPONSEUNIT_10S = 1; // tenths of a unit
  COLORRESPONSEUNIT_100S = 2; // hundredths of a unit
  COLORRESPONSEUNIT_1000S = 3; // thousandths of a unit
  COLORRESPONSEUNIT_10000S = 4; // ten-thousandths of a unit
  COLORRESPONSEUNIT_100000S = 5; // hundred-thousandths
  TIFFTAG_TRANSFERFUNCTION = 301; // colorimetry info
  TIFFTAG_SOFTWARE = 305; // name & release
  TIFFTAG_DATETIME = 306; // creation date and time
  TIFFTAG_ARTIST = 315; // creator of image
  TIFFTAG_HOSTCOMPUTER = 316; // machine where created
  TIFFTAG_PREDICTOR = 317; // prediction scheme w/ LZW
  PREDICTION_NONE = 1; // no prediction scheme used before coding
  PREDICTION_HORZ_DIFFERENCING = 2; // horizontal differencing prediction scheme used
  TIFFTAG_WHITEPOINT = 318; // image white point
  TIFFTAG_PRIMARYCHROMATICITIES = 319; // primary chromaticities
  TIFFTAG_COLORMAP = 320; // RGB map for pallette image
  TIFFTAG_HALFTONEHINTS = 321; // highlight+shadow info
  TIFFTAG_TILEWIDTH = 322; // rows/data tile
  TIFFTAG_TILELENGTH = 323; // cols/data tile
  TIFFTAG_TILEOFFSETS = 324; // offsets to data tiles
  TIFFTAG_TILEBYTECOUNTS = 325; // Byte counts for tiles
  TIFFTAG_BADFAXLINES = 326; // lines w/ wrong pixel count
  TIFFTAG_CLEANFAXDATA = 327; // regenerated line info
  CLEANFAXDATA_CLEAN = 0; // no errors detected
  CLEANFAXDATA_REGENERATED = 1; // receiver regenerated lines
  CLEANFAXDATA_UNCLEAN = 2; // uncorrected errors exist
  TIFFTAG_CONSECUTIVEBADFAXLINES = 328; // max consecutive bad lines
  TIFFTAG_SUBIFD = 330; // subimage descriptors
  TIFFTAG_INKSET = 332; // inks in separated image
  INKSET_CMYK = 1; // cyan-magenta-yellow-black
  TIFFTAG_INKNAMES = 333; // ascii names of inks
  TIFFTAG_DOTRANGE = 336; // 0% and 100% dot codes
  TIFFTAG_TARGETPRINTER = 337; // separation target
  TIFFTAG_EXTRASAMPLES = 338; // info about extra samples
  EXTRASAMPLE_UNSPECIFIED = 0; // unspecified data
  EXTRASAMPLE_ASSOCALPHA = 1; // associated alpha data
  EXTRASAMPLE_UNASSALPHA = 2; // unassociated alpha data
  TIFFTAG_SAMPLEFORMAT = 339; // data sample format
  SAMPLEFORMAT_UINT = 1; // unsigned integer data
  SAMPLEFORMAT_INT = 2; // signed integer data
  SAMPLEFORMAT_IEEEFP = 3; // IEEE floating point data
  SAMPLEFORMAT_VOID = 4; // untyped data
  TIFFTAG_SMINSAMPLEVALUE = 340; // variable MinSampleValue
  TIFFTAG_SMAXSAMPLEVALUE = 341; // variable MaxSampleValue
  TIFFTAG_JPEGTABLES = 347; // JPEG table stream

  // Tags 512-521 are obsoleted by Technical Note #2 which specifies a revised JPEG-in-TIFF scheme.

  TIFFTAG_JPEGPROC = 512; // JPEG processing algorithm
  JPEGPROC_BASELINE = 1; // baseline sequential
  JPEGPROC_LOSSLESS = 14; // Huffman coded lossless
  TIFFTAG_JPEGIFOFFSET = 513; // Pointer to SOI marker
  TIFFTAG_JPEGIFBYTECOUNT = 514; // JFIF stream length
  TIFFTAG_JPEGRESTARTINTERVAL = 515; // restart interval length
  TIFFTAG_JPEGLOSSLESSPREDICTORS = 517; // lossless proc predictor
  TIFFTAG_JPEGPOINTTRANSFORM = 518; // lossless point transform
  TIFFTAG_JPEGQTABLES = 519; // Q matrice offsets
  TIFFTAG_JPEGDCTABLES = 520; // DCT table offsets
  TIFFTAG_JPEGACTABLES = 521; // AC coefficient offsets
  TIFFTAG_YCBCRCOEFFICIENTS = 529; // RGB -> YCbCr transform
  TIFFTAG_YCBCRSUBSAMPLING = 530; // YCbCr subsampling factors
  TIFFTAG_YCBCRPOSITIONING = 531; // subsample positioning
  YCBCRPOSITION_CENTERED = 1; // as in PostScript Level 2
  YCBCRPOSITION_COSITED = 2; // as in CCIR 601-1
  TIFFTAG_REFERENCEBLACKWHITE = 532; // colorimetry info
  // tags 32952-32956 are private tags registered to Island Graphics
  TIFFTAG_REFPTS = 32953; // image reference points
  TIFFTAG_REGIONTACKPOINT = 32954; // region-xform tack point
  TIFFTAG_REGIONWARPCORNERS = 32955; // warp quadrilateral
  TIFFTAG_REGIONAFFINE = 32956; // affine transformation mat
  // tags 32995-32999 are private tags registered to SGI
  TIFFTAG_MATTEING = 32995; // use ExtraSamples
  TIFFTAG_DATATYPE = 32996; // use SampleFormat
  TIFFTAG_IMAGEDEPTH = 32997; // z depth of image
  TIFFTAG_TILEDEPTH = 32998; // z depth/data tile

  // tags 33300-33309 are private tags registered to Pixar
  //
  // TIFFTAG_PIXAR_IMAGEFULLWIDTH and TIFFTAG_PIXAR_IMAGEFULLLENGTH
  // are set when an image has been cropped out of a larger image.
  // They reflect the size of the original uncropped image.
  // The TIFFTAG_XPOSITION and TIFFTAG_YPOSITION can be used
  // to determine the position of the smaller image in the larger one.

  TIFFTAG_PIXAR_IMAGEFULLWIDTH = 33300; // full image size in x
  TIFFTAG_PIXAR_IMAGEFULLLENGTH = 33301; // full image size in y
  // tag 33405 is a private tag registered to Eastman Kodak
  TIFFTAG_WRITERSERIALNUMBER = 33405; // device serial number
  // tag 33432 is listed in the 6.0 spec w/ unknown ownership
  TIFFTAG_COPYRIGHT = 33432; // copyright string
  // 34016-34029 are reserved for ANSI IT8 TIFF/IT <dkelly@etsinc.com)
  TIFFTAG_IT8SITE = 34016; // site name
  TIFFTAG_IT8COLORSEQUENCE = 34017; // color seq. [RGB,CMYK,etc]
  TIFFTAG_IT8HEADER = 34018; // DDES Header
  TIFFTAG_IT8RASTERPADDING = 34019; // raster scanline padding
  TIFFTAG_IT8BITSPERRUNLENGTH = 34020; // # of bits in short run
  TIFFTAG_IT8BITSPEREXTENDEDRUNLENGTH = 34021; // # of bits in long run
  TIFFTAG_IT8COLORTABLE = 34022; // LW colortable
  TIFFTAG_IT8IMAGECOLORINDICATOR = 34023; // BP/BL image color switch
  TIFFTAG_IT8BKGCOLORINDICATOR = 34024; // BP/BL bg color switch
  TIFFTAG_IT8IMAGECOLORVALUE = 34025; // BP/BL image color value
  TIFFTAG_IT8BKGCOLORVALUE = 34026; // BP/BL bg color value
  TIFFTAG_IT8PIXELINTENSITYRANGE = 34027; // MP pixel intensity value
  TIFFTAG_IT8TRANSPARENCYINDICATOR = 34028; // HC transparency switch
  TIFFTAG_IT8COLORCHARACTERIZATION = 34029; // color character. table
  // tags 34232-34236 are private tags registered to Texas Instruments
  TIFFTAG_FRAMECOUNT = 34232; // Sequence Frame Count
  // tag 34750 is a private tag registered to Pixel Magic
  TIFFTAG_JBIGOPTIONS = 34750; // JBIG options
  // tags 34908-34914 are private tags registered to SGI
  TIFFTAG_FAXRECVPARAMS = 34908; // encoded class 2 ses. parms
  TIFFTAG_FAXSUBADDRESS = 34909; // received SubAddr string
  TIFFTAG_FAXRECVTIME = 34910; // receive time (secs)
  // tag 65535 is an undefined tag used by Eastman Kodak
  TIFFTAG_DCSHUESHIFTVALUES = 65535; // hue shift correction data

  // The following are 'pseudo tags' that can be used to control codec-specific functionality.
  // These tags are not written to file.  Note that these values start at $FFFF + 1 so that they'll
  // never collide with Aldus-assigned tags.

  TIFFTAG_FAXMODE = 65536; // Group 3/4 format control
  FAXMODE_CLASSIC = $0000; // default, include RTC
  FAXMODE_NORTC = $0001; // no RTC at end of data
  FAXMODE_NOEOL = $0002; // no EOL code at end of row
  FAXMODE_BYTEALIGN = $0004; // Byte align row
  FAXMODE_WORDALIGN = $0008; // Word align row
  FAXMODE_CLASSF = FAXMODE_NORTC; // TIFF class F
  TIFFTAG_JPEGQUALITY = 65537; // compression quality level
  // Note: quality level is on the IJG 0-100 scale.  Default value is 75
  TIFFTAG_JPEGCOLORMODE = 65538; // Auto RGB<=>YCbCr convert?
  JPEGCOLORMODE_RAW = $0000; // no conversion (default)
  JPEGCOLORMODE_RGB = $0001; // do auto conversion
  TIFFTAG_JPEGTABLESMODE = 65539; // What to put in JPEGTables
  JPEGTABLESMODE_QUANT = $0001; // include quantization tbls
  JPEGTABLESMODE_HUFF = $0002; // include Huffman tbls
  // Note: default is JPEGTABLESMODE_QUANT or JPEGTABLESMODE_HUFF
  TIFFTAG_FAXFILLFUNC = 65540; // G3/G4 fill function
  TIFFTAG_PIXARLOGDATAFMT = 65549; // PixarLogCodec I/O data sz
  PIXARLOGDATAFMT_8BIT = 0; // regular u_char samples
  PIXARLOGDATAFMT_8BITABGR = 1; // ABGR-order u_chars
  PIXARLOGDATAFMT_11BITLOG = 2; // 11-bit log-encoded (raw)
  PIXARLOGDATAFMT_12BITPICIO = 3; // as per PICIO (1.0==2048)
  PIXARLOGDATAFMT_16BIT = 4; // signed short samples
  PIXARLOGDATAFMT_FLOAT = 5; // IEEE float samples
  // 65550-65556 are allocated to Oceana Matrix <dev@oceana.com>
  TIFFTAG_DCSIMAGERTYPE = 65550; // imager model & filter
  DCSIMAGERMODEL_M3 = 0; // M3 chip (1280 x 1024)
  DCSIMAGERMODEL_M5 = 1; // M5 chip (1536 x 1024)
  DCSIMAGERMODEL_M6 = 2; // M6 chip (3072 x 2048)
  DCSIMAGERFILTER_IR = 0; // infrared filter
  DCSIMAGERFILTER_MONO = 1; // monochrome filter
  DCSIMAGERFILTER_CFA = 2; // color filter array
  DCSIMAGERFILTER_OTHER = 3; // other filter
  TIFFTAG_DCSINTERPMODE = 65551; // interpolation mode
  DCSINTERPMODE_NORMAL = $0; // whole image, default
  DCSINTERPMODE_PREVIEW = $1; // preview of image (384x256)
  TIFFTAG_DCSBALANCEARRAY = 65552; // color balance values
  TIFFTAG_DCSCORRECTMATRIX = 65553; // color correction values
  TIFFTAG_DCSGAMMA = 65554; // gamma value
  TIFFTAG_DCSTOESHOULDERPTS = 65555; // toe & shoulder points
  TIFFTAG_DCSCALIBRATIONFD = 65556; // calibration file desc
  // Note: quality level is on the ZLIB 1-9 scale. Default value is -1
  TIFFTAG_ZIPQUALITY = 65557; // compression quality level
  TIFFTAG_PIXARLOGQUALITY = 65558; // PixarLog uses same scale

  // TIFF data types
  TIFF_NOTYPE = 0; // placeholder
  TIFF_BYTE = 1; // 8-bit unsigned integer
  TIFF_ASCII = 2; // 8-bit bytes w/ last byte null
  TIFF_SHORT = 3; // 16-bit unsigned integer
  TIFF_LONG = 4; // 32-bit unsigned integer
  TIFF_RATIONAL = 5; // 64-bit unsigned fraction
  TIFF_SBYTE = 6; // 8-bit signed integer
  TIFF_UNDEFINED = 7; // 8-bit untyped data
  TIFF_SSHORT = 8; // 16-bit signed integer
  TIFF_SLONG = 9; // 32-bit signed integer
  TIFF_SRATIONAL = 10; // 64-bit signed fraction
  TIFF_FLOAT = 11; // 32-bit IEEE floating point
  TIFF_DOUBLE = 12; // 64-bit IEEE floating point

  TIFF_BIGENDIAN = $4D4D;
  TIFF_LITTLEENDIAN = $4949;

  TIFF_VERSION = 42;

type
  TTIFFHeader = packed record
    ByteOrder: Word;
    Version: Word;
    FirstIFD: Cardinal;
  end;

  //----------------------------------------------------------------------------------------------------------------------

class function TTIFFGraphic.CanLoad(Stream: TStream): Boolean;

var
  Header: TTIFFHeader;
  LastPosition: Cardinal;

begin
  with Stream do
  begin
    Result := (Size - Position) > SizeOf(Header);
    if Result then
    begin
      LastPosition := Position;

      Stream.ReadBuffer(Header, SizeOf(Header));
      Result := (Header.ByteOrder = TIFF_BIGENDIAN) or
        (Header.ByteOrder = TIFF_LITTLEENDIAN);
      if Result then
      begin
        if Header.ByteOrder = TIFF_BIGENDIAN then
        begin
          Header.Version := Swap(Header.Version);
          Header.FirstIFD := SwapLong(Header.FirstIFD);
        end;

        Result := (Header.Version = TIFF_VERSION) and (Integer(Header.FirstIFD) < (Size - Integer(LastPosition)));
      end;
      Position := LastPosition;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTIFFGraphic.FindTag(Tag: Cardinal; var Index: Cardinal): Boolean;

// looks through the currently loaded IFD for the entry indicated by Tag;
// returns True and the index of the entry in Index if the entry is there
// otherwise the result is False and Index undefined
// Note: The IFD is sorted so we can use a binary search here.

var
  L, H, I, C: Integer;

begin
  Result := False;
  L := 0;
  H := High(FIFD);
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Integer(FIFD[I].Tag) - Integer(Tag);
    if C < 0 then L := I + 1
    else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;
  Index := L;
end;

//----------------------------------------------------------------------------------------------------------------------

const
  DataTypeToSize: array[TIFF_NOTYPE..TIFF_SLONG] of Byte = (0, 1, 1, 2, 4, 8, 1, 1, 2, 4);

procedure TTIFFGraphic.GetValueList(Stream: TStream; Tag: Cardinal; var Values: TByteArray);

// returns the values of the IFD entry indicated by Tag

var
  Index,
    Value,
    Shift: Cardinal;
  I: Integer;

begin
  Values := nil;
  if FindTag(Tag, Index) and
    (FIFD[Index].DataLength > 0) then
  begin
    // prepare value list
    SetLength(Values, FIFD[Index].DataLength);

    // determine whether the data fits into 4 bytes
    Value := DataTypeToSize[FIFD[Index].DataType] * FIFD[Index].DataLength;

    // data fits into one cardinal -> extract it
    if Value <= 4 then
    begin
      Shift := DataTypeToSize[FIFD[Index].DataType] * 8;
      Value := FIFD[Index].Offset;
      for I := 0 to FIFD[Index].DataLength - 1 do
      begin
        case FIFD[Index].DataType of
          TIFF_BYTE:
            Values[I] := Byte(Value);
          TIFF_SHORT,
            TIFF_SSHORT:
            // no byte swap needed here because values in the IFD are already swapped
            // (if necessary at all)
            Values[I] := Word(Value);
          TIFF_LONG,
            TIFF_SLONG:
            Values[I] := Value;
        end;
        Value := Value shr Shift;
      end;
    end
    else
    begin
      // data of this tag does not fit into one 32 bits value
      Stream.Position := FBasePosition + FIFD[Index].Offset;
      // bytes sized data can be read directly instead of looping through the array
      if FIFD[Index].DataType in [TIFF_BYTE, TIFF_ASCII, TIFF_SBYTE, TIFF_UNDEFINED]
        then Stream.Read(Values[0], Value)
      else
      begin
        for I := 0 to High(Values) do
        begin
          Stream.Read(Value, DataTypeToSize[FIFD[Index].DataType]);
          case FIFD[Index].DataType of
            TIFF_BYTE:
              Value := Byte(Value);
            TIFF_SHORT,
              TIFF_SSHORT:
              begin
                if ioBigEndian in FImageProperties.Options then Value := Swap(Word(Value))
                else Value := Word(Value);
              end;
            TIFF_LONG,
              TIFF_SLONG:
              if ioBigEndian in FImageProperties.Options then Value := SwapLong(Value);
          end;
          Values[I] := Value;
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.GetValueList(Stream: TStream; Tag: Cardinal; var Values: TCardinalArray);

// returns the values of the IFD entry indicated by Tag

var
  Index,
    Value,
    Shift: Cardinal;
  I: Integer;

begin
  Values := nil;
  if FindTag(Tag, Index) and
    (FIFD[Index].DataLength > 0) then
  begin
    // prepare value list
    SetLength(Values, FIFD[Index].DataLength);

    // determine whether the data fits into 4 bytes
    Value := DataTypeToSize[FIFD[Index].DataType] * FIFD[Index].DataLength;

    // data fits into one cardinal -> extract it
    if Value <= 4 then
    begin
      Shift := DataTypeToSize[FIFD[Index].DataType] * 8;
      Value := FIFD[Index].Offset;
      for I := 0 to FIFD[Index].DataLength - 1 do
      begin
        case FIFD[Index].DataType of
          TIFF_BYTE,
            TIFF_ASCII,
            TIFF_SBYTE,
            TIFF_UNDEFINED:
            Values[I] := Byte(Value);
          TIFF_SHORT,
            TIFF_SSHORT:
            // no byte swap needed here because values in the IFD are already swapped
            // (if necessary at all)
            Values[I] := Word(Value);
          TIFF_LONG,
            TIFF_SLONG:
            Values[I] := Value;
        end;
        Value := Value shr Shift;
      end;
    end
    else
    begin
      // data of this tag does not fit into one 32 bits value
      Stream.Position := FBasePosition + FIFD[Index].Offset;
      // even bytes sized data must be read by the loop as it is expanded to cardinals
      for I := 0 to High(Values) do
      begin
        Stream.Read(Value, DataTypeToSize[FIFD[Index].DataType]);
        case FIFD[Index].DataType of
          TIFF_BYTE:
            Value := Byte(Value);
          TIFF_SHORT,
            TIFF_SSHORT:
            begin
              if ioBigEndian in FImageProperties.Options then Value := Swap(Word(Value))
              else Value := Word(Value);
            end;
          TIFF_LONG,
            TIFF_SLONG:
            if ioBigEndian in FImageProperties.Options then Value := SwapLong(Value);
        end;
        Values[I] := Value;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.GetValueList(Stream: TStream; Tag: Cardinal; var Values: TFloatArray);

// returns the values of the IFD entry indicated by Tag

var
  Index,
    Shift,
    IntValue: Cardinal;
  Value: Single;
  I: Integer;
  IntNominator,
    IntDenominator: Cardinal;
  FloatNominator,
    FloatDenominator: Cardinal;

begin
  Values := nil;
  if FindTag(Tag, Index) and
    (FIFD[Index].DataLength > 0) then
  begin
    // prepare value list
    SetLength(Values, FIFD[Index].DataLength);

    // determine whether the data fits into 4 bytes
    Value := DataTypeToSize[FIFD[Index].DataType] * FIFD[Index].DataLength;

    // data fits into one cardinal -> extract it
    if Value <= 4 then
    begin
      Shift := DataTypeToSize[FIFD[Index].DataType] * 8;
      IntValue := FIFD[Index].Offset;
      for I := 0 to FIFD[Index].DataLength - 1 do
      begin
        case FIFD[Index].DataType of
          TIFF_BYTE,
            TIFF_ASCII,
            TIFF_SBYTE,
            TIFF_UNDEFINED:
            Values[I] := Byte(IntValue);
          TIFF_SHORT,
            TIFF_SSHORT:
            // no byte swap needed here because values in the IFD are already swapped
            // (if necessary at all)
            Values[I] := Word(IntValue);
          TIFF_LONG,
            TIFF_SLONG:
            Values[I] := IntValue;
        end;
        IntValue := IntValue shr Shift;
      end;
    end
    else
    begin
      // data of this tag does not fit into one 32 bits value
      Stream.Position := FBasePosition + FIFD[Index].Offset;
      // even bytes sized data must be read by the loop as it is expanded to Single
      for I := 0 to High(Values) do
      begin
        case FIFD[Index].DataType of
          TIFF_BYTE:
            begin
              Stream.Read(IntValue, DataTypeToSize[FIFD[Index].DataType]);
              Value := Byte(IntValue);
            end;
          TIFF_SHORT,
            TIFF_SSHORT:
            begin
              Stream.Read(IntValue, DataTypeToSize[FIFD[Index].DataType]);
              if ioBigEndian in FImageProperties.Options then Value := Swap(Word(IntValue))
              else Value := Word(IntValue);
            end;
          TIFF_LONG,
            TIFF_SLONG:
            begin
              Stream.Read(IntValue, DataTypeToSize[FIFD[Index].DataType]);
              if ioBigEndian in FImageProperties.Options then Value := SwapLong(IntValue);
            end;
          TIFF_RATIONAL,
            TIFF_SRATIONAL:
            begin
              Stream.ReadBuffer(FloatNominator, SizeOf(FloatNominator));
              Stream.ReadBuffer(FloatDenominator, SizeOf(FloatDenominator));
              if ioBigEndian in FImageProperties.Options then
              begin
                FloatNominator := SwapLong(Cardinal(FloatNominator));
                FloatDenominator := SwapLong(Cardinal(FloatDenominator));
              end;
              Value := FloatNominator / FloatDenominator;
            end;
          TIFF_FLOAT:
            begin
              Stream.ReadBuffer(IntNominator, SizeOf(IntNominator));
              Stream.ReadBuffer(IntDenominator, SizeOf(IntDenominator));
              if ioBigEndian in FImageProperties.Options then
              begin
                IntNominator := SwapLong(IntNominator);
                IntDenominator := SwapLong(IntDenominator);
              end;
              Value := IntNominator / IntDenominator;
            end;
        end;
        Values[I] := Value;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTIFFGraphic.GetValue(Stream: TStream; Tag: Cardinal; Default: Single = 0): Single;

// returns the value of the IFD entry indicated by Tag or the default value if the entry is not there

var
  Index: Cardinal;
  IntNominator,
    IntDenominator: Cardinal;
  FloatNominator,
    FloatDenominator: Cardinal;

begin
  Result := Default;
  if FindTag(Tag, Index) then
  begin
    // if the data length is > 1 then Offset is a real offset into the stream,
    // otherwise it is the value itself and must be shortend depending on the data type
    if FIFD[Index].DataLength = 1 then
    begin
      case FIFD[Index].DataType of
        TIFF_BYTE:
          Result := Byte(FIFD[Index].Offset);
        TIFF_SHORT,
          TIFF_SSHORT:
          Result := Word(FIFD[Index].Offset);
        TIFF_LONG,
          TIFF_SLONG: // nothing to do
          Result := FIFD[Index].Offset;
        TIFF_RATIONAL,
          TIFF_SRATIONAL:
          begin
            Stream.Position := FBasePosition + FIFD[Index].Offset;
            Stream.ReadBuffer(FloatNominator, SizeOf(FloatNominator));
            Stream.ReadBuffer(FloatDenominator, SizeOf(FloatDenominator));
            if ioBigEndian in FImageProperties.Options then
            begin
              FloatNominator := SwapLong(Cardinal(FloatNominator));
              FloatDenominator := SwapLong(Cardinal(FloatDenominator));
            end;
            Result := FloatNominator / FloatDenominator;
          end;
        TIFF_FLOAT:
          begin
            Stream.Position := FBasePosition + FIFD[Index].Offset;
            Stream.ReadBuffer(IntNominator, SizeOf(IntNominator));
            Stream.ReadBuffer(IntDenominator, SizeOf(IntDenominator));
            if ioBigEndian in FImageProperties.Options then
            begin
              IntNominator := SwapLong(IntNominator);
              IntDenominator := SwapLong(IntDenominator);
            end;
            Result := IntNominator / IntDenominator;
          end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTIFFGraphic.GetValue(Tag: Cardinal; Default: Cardinal = 0): Cardinal;

// returns the value of the IFD entry indicated by Tag or the default value if the entry is not there

var
  Index: Cardinal;

begin
  if not FindTag(Tag, Index) then Result := Default
  else
  begin
    Result := FIFD[Index].Offset;
    // if the data length is > 1 then Offset is a real offset into the stream,
    // otherwise it is the value itself and must be shortend depending on the data type
    if FIFD[Index].DataLength = 1 then
    begin
      case FIFD[Index].DataType of
        TIFF_BYTE:
          Result := Byte(Result);
        TIFF_SHORT,
          TIFF_SSHORT:
          Result := Word(Result);
        TIFF_LONG,
          TIFF_SLONG: // nothing to do
          ;
      else
        Result := Default;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTIFFGraphic.GetValue(Tag: Cardinal; var Size: Cardinal; Default: Cardinal): Cardinal;

// Returns the value of the IFD entry indicated by Tag or the default value if the entry is not there.
// If the tag exists then also the data size is returned.

var
  Index: Cardinal;

begin
  if not FindTag(Tag, Index) then
  begin
    Result := Default;
    Size := 0;
  end
  else
  begin
    Result := FIFD[Index].Offset;
    Size := FIFD[Index].DataLength;
    // if the data length is > 1 then Offset is a real offset into the stream,
    // otherwise it is the value itself and must be shortend depending on the data type
    if FIFD[Index].DataLength = 1 then
    begin
      case FIFD[Index].DataType of
        TIFF_BYTE:
          Result := Byte(Result);
        TIFF_SHORT,
          TIFF_SSHORT:
          Result := Word(Result);
        TIFF_LONG,
          TIFF_SLONG: // nothing to do
          ;
      else
        Result := Default;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.SortIFD;

// Although all entries in the IFD should be sorted there are still files where this is not the case.
// Because the lookup for certain tags in the IFD uses binary search it must be made sure the IFD is
// sorted (what we do here).

  //--------------- local function --------------------------------------------

  procedure QuickSort(L, R: Integer);

  var
    I, J, M: Integer;
    T: TIFDEntry;

  begin
    repeat
      I := L;
      J := R;
      M := (L + R) shr 1;
      repeat
        while FIFD[I].Tag < FIFD[M].Tag do Inc(I);
        while FIFD[J].Tag > FIFD[M].Tag do Dec(J);
        if I <= J then
        begin
          T := FIFD[I];
          FIFD[I] := FIFD[J];
          FIFD[J] := T;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then QuickSort(L, J);
      L := I;
    until I >= R;
  end;

  //--------------- end local functions ---------------------------------------

begin
  QuickSort(0, High(FIFD));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.SwapIFD;

// swap the member fields of all entries of the currently loaded IFD from big endian to little endian

var
  I: Integer;
  Size: Cardinal;

begin
  for I := 0 to High(FIFD) do
    with FIFD[I] do
    begin
      Tag := Swap(Tag);
      DataType := Swap(DataType);
      DataLength := SwapLong(DataLength);

      // determine whether the data fits into 4 bytes
      Size := DataTypeToSize[FIFD[I].DataType] * FIFD[I].DataLength;
      if Size >= 4 then Offset := SwapLong(Offset)
      else
        case DataType of
          TIFF_SHORT,
            TIFF_SSHORT:
            if DataLength > 1 then Offset := SwapLong(Offset)
            else Offset := Swap(Word(Offset));
        end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.LoadFromStream(Stream: TStream);
var
  IFDCount: Word;
  Buffer: Pointer;
  Run: PAnsiChar;
  Pixels, EncodedData, DataPointerCopy: Pointer;
  Offsets, ByteCounts: TCardinalArray;
  ColorMap: Cardinal;

  StripSize: Cardinal;
  Decoder: TDecoder;

  // dynamically assigned handler
  Deprediction: procedure(P: Pointer; Count: Cardinal);
begin
  Handle := 0;
  Deprediction := nil;
  Decoder := nil;

  // we need to keep the current stream position because all position information
  // are relative to this one
  FBasePosition := Stream.Position;
  if ReadImageProperties(Stream, 0) then
  begin
    with FImageProperties do
    try
      // tiled images aren't supported
      if ioTiled in Options then Exit;

      //FProgressRect := Rect(0, 0, 0, 1);
      //Progress(Self, psStarting, 0, False, FProgressRect, gesPreparing);

      // read data of the first image file directory (IFD)
      Stream.Position := FBasePosition + FirstIFD;
      Stream.ReadBuffer(IFDCount, SizeOf(IFDCount));
      if ioBigEndian in Options then IFDCount := Swap(IFDCount);
      SetLength(FIFD, IFDCount);
      Stream.ReadBuffer(FIFD[0], IFDCount * SizeOf(TIFDEntry));
      if ioBigEndian in Options then SwapIFD;
      SortIFD;

      // --- read the data of the directory which are needed to actually load the image:

      // data organization
      GetValueList(Stream, TIFFTAG_STRIPOFFSETS, Offsets);
      GetValueList(Stream, TIFFTAG_STRIPBYTECOUNTS, ByteCounts);

      // retrive additional tile data if necessary
      if ioTiled in Options then
      begin
        GetValueList(Stream, TIFFTAG_TILEOFFSETS, Offsets);
        GetValueList(Stream, TIFFTAG_TILEBYTECOUNTS, ByteCounts);
      end;

      // determine pixelformat and setup color conversion
      with ColorManager do
      begin
        if ioBigEndian in Options then SourceOptions := [coNeedByteSwap]
        else SourceOptions := [];
        SourceBitsPerSample := BitsPerSample;
        if SourceBitsPerSample = 16 then TargetBitsPerSample := 8
        else TargetBitsPerSample := SourceBitsPerSample;

        // the JPEG lib does internally a conversion to RGB
        if Compression in [ctOJPEG, ctJPEG] then SourceColorScheme := csBGR
        else SourceColorScheme := ColorScheme;

        case SourceColorScheme of
          csRGBA:
            TargetColorScheme := csBGRA;
          csRGB:
            TargetColorScheme := csBGR;
          csCMY,
            csCMYK,
            csCIELab,
            csYCbCr:
            TargetColorScheme := csBGR;
          csIndexed:
            begin
              if HasAlpha then SourceColorScheme := csGA; // fake indexed images with alpha (used in EPS)
              // as being grayscale with alpha
              TargetColorScheme := csIndexed;
            end;
        else
          TargetColorScheme := SourceColorScheme;
        end;

        SourceSamplesPerPixel := SamplesPerPixel;
        if SourceColorScheme = csCMYK then TargetSamplesPerPixel := 3
        else TargetSamplesPerPixel := SamplesPerPixel;
        if SourceColorScheme = csCIELab then SourceOptions := SourceOptions + [coLabByteRange];

        if SourceColorScheme = csGA then PixelFormat := pf8Bit
        else PixelFormat := TargetPixelFormat;
      end;

      // now that the pixel format is set we can also set the (possibly large) image dimensions
      Self.Width := Width;
      Self.Height := Height;
      if (Width = 0) or (Height = 0) then GraphicExError(gesInvalidImage, ['TIF/TIFF']);

      //FProgressRect.Right := Width;
      if ColorManager.TargetColorScheme in [csIndexed, csG, csGA] then
      begin
        // load palette data and build palette
        if ColorManager.TargetColorScheme = csIndexed then
        begin
          ColorMap := GetValue(TIFFTAG_COLORMAP, StripSize, 0);
          if StripSize > 0 then
          begin
            Stream.Position := FBasePosition + ColorMap;
            // number of palette entries is also given by the color map tag
            // (3 components each (r,g,b) and two bytes per component)
            Stream.ReadBuffer(FPalette[0], 2 * StripSize);
            Palette := ColorManager.CreateColorPalette([@FPalette[0], @FPalette[StripSize div 3],
              @FPalette[2 * StripSize div 3]], pfPlane16Triple, StripSize, False);
          end;
        end
        else Palette := ColorManager.CreateGrayscalePalette(ioMinIsWhite in Options);
      end
      else
        if ColorManager.SourceColorScheme = csYCbCr then
          ColorManager.SetYCbCrParameters(FYCbCrCoefficients, YCbCrSubSampling[0], YCbCrSubSampling[1]);

      // intermediate buffer for data
      BytesPerLine := (BitsPerPixel * Width + 7) div 8;

      // determine prediction scheme
      if Compression <> ctNone then
      begin
        // Prediction without compression makes no sense at all (as it is to improve
        // compression ratios). Appearently there are image which are uncompressed but still
        // have a prediction scheme set. Hence we must check for it.
        case Predictor of
          PREDICTION_HORZ_DIFFERENCING: // currently only one prediction scheme is defined
            case SamplesPerPixel of
              4:
                Deprediction := Depredict4;
              3:
                Deprediction := Depredict3;
            else
              Deprediction := Depredict1;
            end;
        end;
      end;

      // create decompressor for the image
      case Compression of
        ctNone:
          ;
{$IFDEF UseLZW}
        ctLZW:
          Decoder := TTIFFLZWDecoder.Create;
{$ENDIF}
        ctPackedBits:
          Decoder := TPackbitsRLEDecoder.Create;
        ctFaxRLE,
          ctFaxRLEW:
          Decoder := TCCITTMHDecoder.Create(GetValue(TIFFTAG_GROUP3OPTIONS),
            ioReversed in Options,
            Compression = ctFaxRLEW,
            Width);
        ctFax3:
          Decoder := TCCITTFax3Decoder.Create(GetValue(TIFFTAG_GROUP3OPTIONS), ioReversed in Options, False, Width);
        ctJPEG:
          begin
            // some extra work is needed for JPEG
            GetValueList(Stream, TIFFTAG_JPEGTABLES, JPEGTables);

            Decoder := TTIFFJPEGDecoder.Create(@FImageProperties);
          end;
        ctThunderscan:
          Decoder := TThunderDecoder.Create(Width);
        ctLZ77:
          Decoder := TLZ77Decoder.Create(Z_PARTIAL_FLUSH, True);
      else
        {
        COMPRESSION_OJPEG,
        COMPRESSION_CCITTFAX4
        COMPRESSION_NEXT
        COMPRESSION_IT8CTPAD
        COMPRESSION_IT8LW
        COMPRESSION_IT8MP
        COMPRESSION_IT8BL
        COMPRESSION_PIXARFILM
        COMPRESSION_PIXARLOG
        COMPRESSION_DCS
        COMPRESSION_JBIG}
        GraphicExError(gesUnsupportedFeature, [gesCompressionScheme, 'TIF/TIFF']);
      end;

      if Assigned(Decoder) then Decoder.DecodeInit;
      //Progress(Self, psEnding, 0, False, FProgressRect, '');

      //Progress(Self, psStarting, 0, False, FProgressRect, gesTransfering);
      // go for each strip in the image (which might contain more than one line)
      CurrentRow := 0;
      CurrentStrip := 0;
      StripCount := Length(Offsets);
      while CurrentStrip < StripCount do
      begin
        Stream.Position := FBasePosition + Offsets[CurrentStrip];
        if CurrentStrip < Length(RowsPerStrip) then StripSize := BytesPerLine * RowsPerStrip[CurrentStrip]
        else StripSize := BytesPerLine * RowsPerStrip[High(RowsPerStrip)];

        GetMem(Buffer, StripSize);
        Run := Buffer;
        try
          // decompress strip if necessary
          if Assigned(Decoder) then
          begin
            GetMem(EncodedData, ByteCounts[CurrentStrip]);
            try
              DataPointerCopy := EncodedData;
              Stream.Read(EncodedData^, ByteCounts[CurrentStrip]);
              // need pointer copies here because they could get modified
              // while decoding
              Decoder.Decode(DataPointerCopy, Pointer(Run), ByteCounts[CurrentStrip], StripSize);
            finally
              if Assigned(EncodedData) then FreeMem(EncodedData);
            end;
          end
          else
          begin
            Stream.Read(Buffer^, StripSize);
          end;

          Run := Buffer;
          // go for each line (row) in the strip
          while (CurrentRow < Height) and ((Run - Buffer) < Integer(StripSize)) do
          begin
            Pixels := ScanLine[CurrentRow];
            // depredict strip if necessary
            if Assigned(Deprediction) then Deprediction(Run, Width - 1);
            // any color conversion comes last
            ColorManager.ConvertRow([Run], Pixels, Width, $FF);
            Inc(PAnsiChar(Run), BytesPerLine);
            Inc(CurrentRow);

            //Progress(Self, psRunning, MulDiv(CurrentRow, 100, Height), True, FProgressRect, '');
            //OffsetRect(FProgressRect, 0, 1);
          end;

        finally
          if Assigned(Buffer) then FreeMem(Buffer);
        end;

        Inc(CurrentStrip);
      end;
    finally
      //Progress(Self, psEnding, 0, False, FProgressRect, '');

      if Assigned(Decoder) then Decoder.DecodeEnd;
      Decoder.Free;
    end;
  end
  else GraphicExError(gesInvalidImage, ['TIF/TIFF']);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.SaveToStream(Stream: TStream);

begin
end;

//----------------------------------------------------------------------------------------------------------------------

function TTIFFGraphic.ReadImageProperties(Stream: TStream; ImageIndex: Cardinal): Boolean;

// Reads all relevant TIF properties of the image of index ImageIndex (zero based).
// Returns True if the image ImageIndex could be read, otherwise False.

const
  PhotometricToColorScheme: array[PHOTOMETRIC_MINISWHITE..PHOTOMETRIC_CIELAB] of TColorScheme = (
    csG,
    csG,
    csRGBA,
    csIndexed,
    csUnknown,
    csCMYK,
    csYCbCr,
    csUnknown,
    csCIELab
    );

var
  IFDCount: Word;
  ExtraSamples: TCardinalArray;
  PhotometricInterpretation: Byte;
  TIFCompression: Word;
  Index: Cardinal;

  IFDOffset: Cardinal;
  Header: TTIFFHeader;
  LocalBitsPerSample: TCardinalArray;

begin
  // clear image properties
  Result := inherited ReadImageProperties(Stream, ImageIndex);

  with FImageProperties do
  begin
    // rewind stream to header position
    Stream.Position := FBasePosition;

    Stream.ReadBuffer(Header, SizeOf(Header));
    if Header.ByteOrder = TIFF_BIGENDIAN then
    begin
      Options := Options + [ioBigEndian];
      Header.Version := Swap(Header.Version);
      Header.FirstIFD := SwapLong(Header.FirstIFD);
    end;

    Version := Header.Version;
    FirstIFD := Header.FirstIFD;
    if Version = TIFF_VERSION then
    begin
      IFDOffset := Header.FirstIFD;
      // advance to next IFD until we have the desired one
      repeat
        Stream.Position := FBasePosition + IFDOffset;
        // number of entries in this directory
        Stream.ReadBuffer(IFDCount, SizeOf(IFDCount));
        if Header.ByteOrder = TIFF_BIGENDIAN then IFDCount := Swap(IFDCount);

        // if we already have the desired image then get out of here
        if ImageIndex = 0 then Break;

        Dec(ImageIndex);
        // advance to offset for next IFD
        Stream.Seek(IFDCount * SizeOf(TIFDEntry), soFromCurrent);
        Stream.ReadBuffer(IFDOffset, SizeOf(IFDOffset));
        // no further image available, but the required index is still not found
        if IFDOffset = 0 then Exit;
      until False;

      SetLength(FIFD, IFDCount);
      Stream.ReadBuffer(FIFD[0], IFDCount * SizeOf(TIFDEntry));
      if Header.ByteOrder = TIFF_BIGENDIAN then SwapIFD;
      SortIFD;

      Width := GetValue(TIFFTAG_IMAGEWIDTH);
      Height := GetValue(TIFFTAG_IMAGELENGTH);
      if (Width = 0) or (Height = 0) then Exit;

      // data organization
      GetValueList(Stream, TIFFTAG_ROWSPERSTRIP, RowsPerStrip);
      // some images rely on the default size ($FFFFFFFF) if only one stripe is in the image,
      // make sure there's a valid value also in this case
      if (Length(RowsPerStrip) = 0) or (RowsPerStrip[0] = $FFFFFFFF) then
      begin
        SetLength(RowsPerStrip, 1);
        RowsPerStrip[0] := Height;
      end;

      // number of color components per pixel (1 for b&w, 16 and 256 colors, 3 for RGB, 4 for CMYK etc.)
      SamplesPerPixel := GetValue(TIFFTAG_SAMPLESPERPIXEL, 1);

      // number of bits per color component
      GetValueList(Stream, TIFFTAG_BITSPERSAMPLE, LocalBitsPerSample);
      if Length(LocalBitsPerSample) = 0 then BitsPerSample := 1
      else BitsPerSample := LocalBitsPerSample[0];

      // determine whether image is tiled and retrive tile data if necessary
      TileWidth := GetValue(TIFFTAG_TILEWIDTH, 0);
      TileLength := GetValue(TIFFTAG_TILELENGTH, 0);
      if (TileWidth > 0) and (TileLength > 0) then Include(Options, ioTiled);

      // photometric interpretation determines the color space
      PhotometricInterpretation := GetValue(TIFFTAG_PHOTOMETRIC);
      // type of extra information for additional samples per pixel
      GetValueList(Stream, TIFFTAG_EXTRASAMPLES, ExtraSamples);

      // determine whether extra samples must be considered
      HasAlpha := Length(ExtraSamples) > 0;
      // if any of the extra sample contains an invalid value then consider
      // it as being not existant to avoid wrong interpretation for badly
      // written images
      if HasAlpha then
      begin
        for Index := 0 to High(ExtraSamples) do
          if ExtraSamples[Index] > EXTRASAMPLE_UNASSALPHA then
          begin
            HasAlpha := False;
            Break;
          end;
      end;

      // currently all bits per sample values are equal
      BitsPerPixel := BitsPerSample * SamplesPerPixel;

      // create decompressor for the image
      TIFCompression := GetValue(TIFFTAG_COMPRESSION);
      case TIFCompression of
        COMPRESSION_NONE:
          Compression := ctNone;
        COMPRESSION_LZW:
          Compression := ctLZW;
        COMPRESSION_PACKBITS:
          Compression := ctPackedBits;
        COMPRESSION_CCITTRLE:
          Compression := ctFaxRLE;
        COMPRESSION_CCITTRLEW:
          Compression := ctFaxRLEW;
        COMPRESSION_CCITTFAX3:
          Compression := ctFax3;
        COMPRESSION_OJPEG:
          Compression := ctOJPEG;
        COMPRESSION_JPEG:
          Compression := ctJPEG;
        COMPRESSION_CCITTFAX4:
          Compression := ctFax4;
        COMPRESSION_NEXT:
          Compression := ctNext;
        COMPRESSION_THUNDERSCAN:
          Compression := ctThunderscan;
        COMPRESSION_IT8CTPAD:
          Compression := ctIT8CTPAD;
        COMPRESSION_IT8LW:
          Compression := ctIT8LW;
        COMPRESSION_IT8MP:
          Compression := ctIT8MP;
        COMPRESSION_IT8BL:
          Compression := ctIT8BL;
        COMPRESSION_PIXARFILM:
          Compression := ctPixarFilm;
        COMPRESSION_PIXARLOG: // also a LZ77 clone
          Compression := ctPixarLog;
        COMPRESSION_ADOBE_DEFLATE,
          COMPRESSION_DEFLATE:
          Compression := ctLZ77;
        COMPRESSION_DCS:
          Compression := ctDCS;
        COMPRESSION_JBIG:
          Compression := ctJBIG;
      else
        Compression := ctUnknown;
      end;

      if PhotometricInterpretation in [PHOTOMETRIC_MINISWHITE..PHOTOMETRIC_CIELAB] then
      begin
        ColorScheme := PhotometricToColorScheme[PhotometricInterpretation];
        if (PhotometricInterpretation = PHOTOMETRIC_RGB) and (SamplesPerPixel < 4) then ColorScheme := csRGB;
        if PhotometricInterpretation = PHOTOMETRIC_MINISWHITE then Include(Options, ioMinIsWhite);

        // extra work necessary for YCbCr
        if PhotometricInterpretation = PHOTOMETRIC_YCBCR then
        begin
          if FindTag(TIFFTAG_YCBCRSUBSAMPLING, Index)
            then GetValueList(Stream, TIFFTAG_YCBCRSUBSAMPLING, YCbCrSubSampling)
          else
          begin
            // initialize default values if nothing is given in the file
            SetLength(YCbCrSubSampling, 2);
            YCbCrSubSampling[0] := 2;
            YCbCrSubSampling[1] := 2;
          end;
          if FindTag(TIFFTAG_YCBCRPOSITIONING, Index) then FYCbCrPositioning := GetValue(TIFFTAG_YCBCRPOSITIONING)
          else FYCbCrPositioning := YCBCRPOSITION_CENTERED;

          if FindTag(TIFFTAG_YCBCRCOEFFICIENTS, Index)
            then GetValueList(Stream, TIFFTAG_YCBCRCOEFFICIENTS, FYCbCrCoefficients)
          else
          begin
            // defaults are from CCIR recommendation 601-1
            SetLength(FYCbCrCoefficients, 3);
            FYCbCrCoefficients[0] := 0.299;
            FYCbCrCoefficients[1] := 0.587;
            FYCbCrCoefficients[2] := 0.114;
          end;
        end;
      end
      else ColorScheme := csUnknown;

      JPEGColorMode := GetValue(TIFFTAG_JPEGCOLORMODE, JPEGCOLORMODE_RAW);
      JPEGTablesMode := GetValue(TIFFTAG_JPEGTABLESMODE, JPEGTABLESMODE_QUANT or JPEGTABLESMODE_HUFF);

      PlanarConfig := GetValue(TIFFTAG_PLANARCONFIG);
      // other image properties
      XResolution := GetValue(Stream, TIFFTAG_XRESOLUTION);
      YResolution := GetValue(Stream, TIFFTAG_YRESOLUTION);
      if GetValue(TIFFTAG_RESOLUTIONUNIT, RESUNIT_INCH) = RESUNIT_CENTIMETER then
      begin
        // Resolution is given in centimeters.
        // Although I personally prefer the metric system over the old english one :-)
        // I still convert to inches because it is an unwritten rule to give image resolutions in dpi.
        XResolution := XResolution * 2.54;
        YResolution := YResolution * 2.54;
      end;

      // determine prediction scheme
      Predictor := GetValue(TIFFTAG_PREDICTOR);

      // determine fill order in bytes
      if GetValue(TIFFTAG_FILLORDER, FILLORDER_MSB2LSB) = FILLORDER_LSB2MSB then Include(Options, ioReversed);

      // finally show that we found and read an image
      Result := True;
    end;
  end;
end;

























{$IFDEF NoUseDelphi}
{ TBitmap }

constructor TBitmap.Create;
begin
  inherited Create();
  fPixelFormat := pfNone;
  fPixelBitCount := 24;
end;

procedure TBitmap.CreateMemory;
begin
  if (fWidth > 0) and (fHeight > 0) and (fPixelFormat <> pfNone) then
  begin
    case fPixelFormat of
      pf1bit, pf4bit, pf8bit:
        begin
          fPixelBitCount := 8;
          fBytesPerRow := (((8 * fWidth + 31) and not 31) div 8);
        end;
      pf15bit, pf16bit:
        begin
          fPixelBitCount := 16;
          fBytesPerRow := (((16 * fWidth + 31) and not 31) div 8);
        end;
      pf24bit:
        begin
          fPixelBitCount := 24;
          fBytesPerRow := (((24 * fWidth + 31) and not 31) div 8);
        end;
      pf32bit:
        begin
          fPixelBitCount := 32;
          fBytesPerRow := (((32 * fWidth + 31) and not 31) div 8);
        end;
      pfDevice, pfCustom:
        begin
          fPixelBitCount := 24;
          fBytesPerRow := (((24 * fWidth + 31) and not 31) div 8);
        end;
    else
        Exit;
    end;

    if fData <> nil then
      FreeMem(fData);

    fData := GetMemory(fBytesPerRow * fHeight);
    FillChar(fData^, fBytesPerRow * fHeight, 0);
  end;  
end;

destructor TBitmap.Destroy;
begin
  if fData <> nil then
    FreeMem(fData);
  inherited;
end;

function TBitmap.GetEmpty: Boolean;
begin
  if (fWidth > 0) and (fHeight > 0) and (fData <> nil) then
    Result := False
  else
    Result := True;
end;

function TBitmap.getHasAlpha: Boolean;
begin
  if fPixelFormat = pf32bit then
    Result := True
  else
    Result := False;
end;

function TBitmap.getHeight: Integer;
begin
  Result := fHeight;
end;

function TBitmap.getPixelBitCount: Integer;
begin
  Result := fPixelBitCount;    
end;

function TBitmap.GetPixelFormat: TPixelFormat;
begin
  Result := fPixelFormat;
end;

function TBitmap.GetScanLine(Row: Integer): Pointer;
begin
  if Empty then
    Result := nil
  else
  begin
    if (0 <= Row) and (Cardinal(Row) < fHeight) then
      Result := Pointer( Cardinal(fData) + fBytesPerRow * Cardinal(Row))
    else
      Result := nil;
  end;
end;

function TBitmap.GetTransparent: Boolean;
begin
  Result := fTransparent;
end;

function TBitmap.getWidth: Integer;
begin
  Result := fWidth;
end;

procedure TBitmap.LoadFromFile(Filename: string);
begin

end;

procedure TBitmap.LoadFromStream(Stream: TStream);
begin

end;

procedure TBitmap.Progress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect;
  const Msg: string);
begin

end;

procedure TBitmap.SaveToFile(Filename: string);
begin

end;

procedure TBitmap.SaveToStream(Stream: TStream);
begin

end;

procedure TBitmap.setHeight(const Value: Integer);
begin
  fHeight := Value;
  CreateMemory();
end;

procedure TBitmap.SetPixelFormat(const Value: TPixelFormat);
begin
  fPixelFormat := Value;
  CreateMemory();
end;

procedure TBitmap.SetTransparent(const Value: Boolean);
begin
  fTransparent := Value;
end;

procedure TBitmap.setWidth(const Value: Integer);
begin
  fWidth := Value;
  CreateMemory();
end;
{$ENDIF}


end.

