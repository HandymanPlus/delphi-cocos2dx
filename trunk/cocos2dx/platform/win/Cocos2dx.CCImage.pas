(****************************************************************************
Copyright (c) 2010 cocos2d-x.org

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

unit Cocos2dx.CCImage;

interface
uses      
  Cocos2dx.CCObject;

type
  EImageFormat =
  (
        kFmtJpg = 0,
        kFmtPng,
        kFmtTiff,
        kFmtTga,
        kFmtRawData,
        kFmtUnKnown
  );
  
  ETextAlign =
  (
        kAlignCenter        = $33, ///< Horizontal center and vertical center.
        kAlignTop           = $13, ///< Horizontal center and vertical top.
        kAlignTopRight      = $12, ///< Horizontal right and vertical top.
        kAlignRight         = $32, ///< Horizontal right and vertical center.
        kAlignBottomRight   = $22, ///< Horizontal right and vertical bottom.
        kAlignBottom        = $23, ///< Horizontal center and vertical bottom.
        kAlignBottomLeft    = $21, ///< Horizontal left and vertical bottom.
        kAlignLeft          = $31, ///< Horizontal left and vertical center.
        kAlignTopLeft       = $11 ///< Horizontal left and vertical top.
  );

  CCImage = class(CCObject)
  private
    m_pData: PByte;
    m_bHasAlpha: Boolean;
    m_bPreMulti: Boolean;
    m_nWidth: Cardinal;
    m_nHeight: Cardinal;
    m_nBitsPerComponent: Cardinal;
    function getBitsPerComponent: Integer;
    function getHeight: Integer;
    function getWidth: Integer;
  private
    function _initWithPngData(pData: Pointer; nDataLen: Integer): Boolean;
    function _initWithJpgData(pData: Pointer; nDataLen: Integer): Boolean;
    function _initWithTgaData(pData: Pointer; nDataLen: Integer): Boolean;
    function _initWithTiffData(pData: Pointer; nDataLen: Integer): Boolean;
    function _initWithRawData(pData: Pointer; nDataLen: Integer; nWidth, nHeight: Integer; nBitsPerComponent: Integer): Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    class function computeImageFormatType(const filename: string): EImageFormat;
    function initWithImageFile(const strPath: string; imageType: EImageFormat = kFmtPng): Boolean;
    function initWithImageFileThreadSafe(const fullpath: string; imageType: EImageFormat = kFmtPng): Boolean;
    function initWithImageData(pData: Pointer; nDataLen: Integer; eFmt: EImageFormat = kFmtUnKnown; nWidth: Integer = 0; nHeight: Integer = 0; nBitsPerComponent: Integer = 8): Boolean;
    function initWithString(const pText: string; nWidth: Integer = 0; nHeight: Integer = 0; eAlignMask: ETextAlign = kAlignCenter; const pFontName: string = ''; nSize: Integer = 0): Boolean;
    function getData(): PByte;
    function getDataLen(): Integer;
    function hasAlpha(): Boolean;
    function isPremultipliedAlpha(): Boolean;
    function saveToFile(const pszFilePath: string; bIsToRGB: Boolean = True): Boolean;
  public
    property Width: Integer read getWidth;
    property Height: Integer read getHeight;
    property BitsPerComponent: Integer read getBitsPerComponent;
  end;

implementation
uses
  Windows, SysUtils, Messages, Classes, pngimage, GraphicEx, delphiAtlas, JPG,
  Cocos2dx.CCCommon, Cocos2dx.CCFileUtils, Cocos2dx.CCStrUtils, Cocos2dx.CCPointerArray,
  Cocos2dx.CCPlatformMacros;


type
  BitmapDC = class
  private
    m_hWnd: HWND;
    m_hDC: HDC;
    m_hFont: HFONT;
    m_curFontPath: string;
    m_hBmp: HBITMAP;
    function getBitmap: HBITMAP;
    function getDC: HDC;
  public
    constructor Create(hw: HWND);
    destructor Destroy(); override;
    function setFont(const pFontName: string = ''; nSize: Integer = 0): Boolean;
    function sizeWithText(const pszText: string; nLen: Integer; dwFmt: Cardinal; nWidthLimit: Cardinal): TSize;
    function prepareBitmap(nWidth, nHeight: Integer): Boolean;
    function drawText(const pszText: string; var Size: TSize; eAlign: ETextAlign): Integer;
    property DC: HDC read getDC;
    property Bitmap: HBITMAP read getBitmap;
  end;

var s_BmpDC: BitmapDC;

function sharedBitmapDC(): BitmapDC;
begin
  if s_BmpDC = nil then
    s_BmpDC := BitmapDC.Create(0);
  Result := s_BmpDC;
end;  


{ CCImage }

class function CCImage.computeImageFormatType(
  const filename: string): EImageFormat;
const extArray: array [0..6] of string = ('.pvr', '.png', '.jpg', '.jpeg', '.tif', '.tiff', '.tga');
begin
  if (Pos(extArray[0], filename) > 0) then
  begin
    Result := kFmtRawData;
  end else if (Pos(extArray[1], filename) > 0) then
  begin
    Result := kFmtPng;
  end else if (Pos(extArray[2], filename) > 0) or (Pos(extArray[3], filename) > 0) then
  begin
    Result := kFmtJpg;
  end else if (Pos(extArray[4], filename) > 0) or (Pos(extArray[5], filename) > 0) then
  begin
    Result := kFmtTiff;
  end else if (Pos(extArray[6], filename) > 0) then
  begin
    Result := kFmtTga;
  end else
  begin
    Result := kFmtUnKnown;
  end;  
end;

constructor CCImage.Create;
begin
  inherited Create();
  {m_nWidth := 0;
  m_nHeight := 0;
  m_nBitsPerComponent := 0;
  m_pData := nil;
  m_bHasAlpha := False;
  m_bPreMulti := False;}
end;

destructor CCImage.Destroy;
begin
  if m_pData <> nil then
  begin
    FreeMem(m_pData);
    m_pData := nil;
  end;
  inherited;
end;

function CCImage.getBitsPerComponent: Integer;
begin
  Result := m_nBitsPerComponent;
end;

function CCImage.getData: PByte;
begin
  Result := m_pData;
end;

function CCImage.getDataLen: Integer;
begin
  Result := m_nWidth * m_nHeight;
end;

function CCImage.getHeight: Integer;
begin
  Result := m_nHeight;
end;

function CCImage.getWidth: Integer;
begin
  Result := m_nWidth;
end;

function CCImage.hasAlpha: Boolean;
begin
  Result := m_bHasAlpha;
end;

function CCImage.initWithImageData(pData: Pointer; nDataLen: Integer;
  eFmt: EImageFormat; nWidth, nHeight,
  nBitsPerComponent: Integer): Boolean;
var
  bRet: Boolean;
  pHead: PByteArray;
begin
  bRet := False;

  repeat

    if (pData = nil) or (nDataLen < 1) then
      Break;

    if eFmt = kFmtPng then
    begin
      bRet := _initWithPngData(pData, nDataLen);
      Break;
    end else if eFmt = kFmtJpg then
    begin
      bRet := _initWithJpgData(pData, nDataLen);
      Break;
    end else if eFmt = kFmtTiff then
    begin
      bRet := _initWithTiffData(pData, nDataLen);
      Break;
    end else if eFmt = kFmtRawData then
    begin
      bRet := _initWithRawData(pData, nDataLen, nWidth, nHeight, nBitsPerComponent);
      Break;
    end else if eFmt = kFmtTga then
    begin
      bRet := _initWithTgaData(pData, nDataLen);
      Break;
    end else
    begin
      if nDataLen > 8 then
      begin
        pHead := PByteArray(pData);
        if ( (pHead[0] = $89) and
             (pHead[1] = $50) and
             (pHead[2] = $4E) and
             (pHead[3] = $47) and
             (pHead[4] = $0D) and
             (pHead[5] = $0A) and
             (pHead[6] = $1A) and
             (pHead[7] = $0A) ) then
        begin
          bRet := _initWithPngData(pData, nDataLen);
          Break;
        end;
      end;

      if nDataLen > 2 then
      begin
        pHead := PByteArray(pData);
        if ( (pHead[0] = $49) and (pHead[1] = $49) ) or
           ( (pHead[0] = $4d) and (pHead[1] = $4d) ) then
        begin
          bRet := _initWithTiffData(pData, nDataLen);
          Break;
        end;
      end;  

      if nDataLen > 2 then
      begin
        pHead := PByteArray(pData);
        if (pHead[0] = $FF) and (pHead[1] = $D8) then
        begin
          bRet := _initWithJpgData(pData, nDataLen);
          Break;
        end;
      end;
    end;  

    
  until True;

  Result := bRet;
end;

function CCImage.initWithImageFile(const strPath: string;
  imageType: EImageFormat): Boolean;
var
  pBuffer: PByte;
  nSize: Cardinal;
  bRet: Boolean;
begin
  bRet := False;
  pBuffer := CCFileUtils.sharedFileUtils().getFileData(CCFileUtils.sharedFileUtils().fullPathForFilename(strPath), 0, @nSize);
  if (pBuffer <> nil) and (nSize > 0) then
  begin
    bRet := initWithImageData(pBuffer, nSize, imageType);
  end;
  CC_SAFE_FREE_POINTER(pBuffer);
  Result := bRet;
end;

function CCImage.initWithImageFileThreadSafe(const fullpath: string;
  imageType: EImageFormat): Boolean;
var
  pBuffer: PByte;
  nSize: Cardinal;
  bRet: Boolean;
begin
  bRet := False;
  pBuffer := CCFileUtils.sharedFileUtils().getFileData(fullpath, 0, @nSize);
  if (pBuffer <> nil) and (nSize > 0) then
  begin
    bRet := initWithImageData(pBuffer, nSize, imageType);
  end;
  CC_SAFE_FREE_POINTER(pBuffer);
  Result := bRet;
end;

function CCImage.initWithString(const pText: string; nWidth,
  nHeight: Integer; eAlignMask: ETextAlign; const pFontName: string;
  nSize: Integer): Boolean;
var
  bRet: Boolean;
  pImageData: PByte;
  pImageDataArray: PByteArray;
  dc: BitmapDC;
  size: TSize;

  bi: TBitmapInfo;
  pPixel: ^COLORREF;
  x, y: Cardinal;
  clr: COLORREF;
begin
  bRet := False;
  repeat
    if pText = '' then
      Break;

    dc := sharedBitmapDC();
    if not dc.setFont(pFontName, nSize) then
    begin
      CCLog('Can not found font(%s), use system default', [pFontName]);
    end;

    size.cx := nWidth; size.cy := nHeight;

    if dc.drawText(pText, size, eAlignMask) = 0 then
      Break;

    pImageData := AllocMem(size.cx * size.cy * 4);
    if pImageData = nil then
      Break;


    FillChar(bi, SizeOf(bi), 0);
    bi.bmiHeader.biSize := SizeOf(bi.bmiHeader);
    if GetDIBits(dc.getDC, dc.getBitmap, 0, 0, nil, bi, DIB_RGB_COLORS) = 0 then
      Break;

    m_nWidth := size.cx;
    m_nHeight := size.cy;
    m_bHasAlpha := True;
    m_bPreMulti := False;
    m_pData := pImageData;
    //pImageData := nil;
    m_nBitsPerComponent := 8;

    if bi.bmiHeader.biHeight > 0 then
      bi.bmiHeader.biHeight := -bi.bmiHeader.biHeight;

    GetDIBits(dc.getDC, dc.getBitmap, 0, m_nHeight, m_pData, bi, DIB_RGB_COLORS);

    pImageDataArray := PByteArray(m_pData);
    for y := 0 to m_nHeight-1 do
    begin
      pPixel := @pImageDataArray[y*m_nWidth*SizeOf(Cardinal)];
      for x := 0 to m_nWidth-1 do
      begin
        clr := pPixel^;
        if (GetRValue(clr) > 0) or (GetGValue(clr) > 0) or (GetBValue(clr) > 0) then
        begin
          pPixel^ := pPixel^ or $FF000000;
        end;
        Inc(pPixel);
      end;
    end;

    bRet := True;
  until True;

  Result := bRet;
end;

function CCImage.isPremultipliedAlpha: Boolean;
begin
  Result := m_bPreMulti;
end;

function CCImage.saveToFile(const pszFilePath: string;
  bIsToRGB: Boolean): Boolean;
begin
  Result := False;
end;

function CCImage._initWithJpgData(pData: Pointer;
  nDataLen: Integer): Boolean;
var
  bRet: Boolean;
  cinfo: jpeg_decompress_struct;
  jerr: jpeg_error_mgr;
  row_pointer: PByteArray;
  location, i: Cardinal;
  mms: Classes.TMemoryStream;
begin
  bRet := False;

  repeat

    mms := Classes.TMemoryStream.Create();
    mms.Write(pData^, nDataLen);
    mms.Position := 0;

    try
      jerr := jpeg_std_error;  // use local var for thread isolation
      cinfo.common.err := @jerr;
      jpeg_CreateDecompress(@cinfo, JPEG_LIB_VERSION, SizeOf(cinfo));

      jpeg_stdio_src(@cinfo, mms);
      jpeg_read_header(@cinfo, True);
      if cinfo.jpeg_color_space <> JCS_RGB then
      begin
        if (cinfo.jpeg_color_space = JCS_GRAYSCALE) or (cinfo.jpeg_color_space = JCS_YCbCr) then
        begin
          cinfo.out_color_space := JCS_RGB;
        end;
      end else
      begin
        Break;
      end;

      jpeg_start_decompress(@cinfo);

      m_nWidth := cinfo.image_width;
      m_nHeight := cinfo.image_height;
      m_bHasAlpha := False;
      m_bPreMulti := False;
      m_nBitsPerComponent := 8;

      if (m_nWidth < 1) or (m_nHeight < 1) then
        Break;

      row_pointer := AllocMem(cinfo.output_width * Cardinal(cinfo.output_components));
      if row_pointer = nil then
        Break;

      m_pData := AllocMem(cinfo.output_width * cinfo.output_height * Cardinal(cinfo.output_components));
      if m_pData = nil then
        Break;

      location := 0;
      while cinfo.output_scanline < cinfo.image_height do
      begin
        jpeg_read_scanlines(@cinfo, @row_pointer, 1);
        for i := 0 to cinfo.image_width * Cardinal(cinfo.output_components)-1 do
        begin
          PByte(Cardinal(m_pData) + location)^ := row_pointer[i];
          Inc(location);
        end;
      end;

      jpeg_finish_decompress(@cinfo);
      jpeg_destroy_decompress(@cinfo);
    finally
      mms.Free;
    end;

    bRet := True;
  until True;

  CC_SAFE_FREE_POINTER(row_pointer);
  Result := bRet;
end;

function CCImage._initWithPngData(pData: Pointer;
  nDataLen: Integer): Boolean;
var
  pngImage: TPngImage;
  bRet: Boolean;
  bytesPerRow: Cardinal;
  x, y: Cardinal;
  pSrcRGB, pDstRGB: PRGBTriple;
  SrcRGBA: TRGBQuad;
  colorType: Byte;
  ByteData: Byte;
  DataDepth: Byte;
  r, g, b, a: Byte;
  ChunkPLTE: TChunkPLTE;
  pIntData: pCardinal;
  //mms: Classes.TMemoryStream;
begin
  bRet := False;

  repeat

    pngimage := TPngImage.Create;
    try
      //mms := Classes.TMemoryStream.Create();
      //mms.Write(pData, nDataLen);
      //mms.Position := 0;
      //pngimage.LoadFromStream(mms);
      pngImage.LoadFromMemory(pData, nDataLen);
      //mms.Free;

      if pngimage.Empty then
        Break;

      m_nWidth := pngimage.Width;
      m_nHeight := pngimage.Height;
      m_nBitsPerComponent := 8;//pngimage.Header.BitDepth;
      colorType := pngImage.Header.ColorType;
      if colorType in [COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA] then
      begin
        m_bHasAlpha := True;
        m_bPreMulti := True;
      end;  

      if (m_nWidth < 1) or (m_nHeight < 1) then
        Break;

      if colorType in [COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA] then
        bytesPerRow := (((32{RGBA} * pngimage.Width + 31) and not 31) div 8)
      else
        bytesPerRow := (((24{RGB} * pngimage.Width + 31) and not 31) div 8);
        
      m_pData := AllocMem(bytesPerRow * m_nHeight);

      case colorType of
        COLOR_RGB:
          begin
            for y := 0 to m_nHeight - 1 do
            begin
              for x := 0 to m_nWidth - 1 do
              begin
                pSrcRGB := @pRGBLine(pngimage.Scanline[y])^[x];
                pDstRGB := PRGBTriple(  Cardinal(m_pData) + bytesPerRow * y + SizeOf(TRGBTriple) * x );

                pDstRGB^.rgbtBlue := pSrcRGB^.rgbtRed;
                pDstRGB^.rgbtGreen := pSrcRGB^.rgbtGreen;
                pDstRGB^.rgbtRed := pSrcRGB^.rgbtBlue;
              end;
            end;
            bRet := True;
          end;
        COLOR_PALETTE:
          begin
            ChunkPLTE := TChunkPLTE(pngImage.Chunks.ItemFromClass(TChunkPLTE));

            DataDepth := pngimage.Header.BitDepth;
            if DataDepth > 8 then
              DataDepth := 8;

            for y := 0 to m_nHeight-1 do
            begin
              for x := 0 to m_nWidth-1 do
              begin
                ByteData := pByteArray(pngimage.Scanline[y])^[x div (8 div DataDepth)];
                {$WARNINGS OFF}
                ByteData := (ByteData shr ((8 - DataDepth) - (X mod (8 div DataDepth)) * DataDepth));
                {$WARNINGS ON}
                ByteData:= ByteData and ($FF shr (8 - DataDepth));

                pDstRGB := PRGBTriple(  Cardinal(m_pData) + bytesPerRow * y + SizeOf(TRGBTriple) * x );
                SrcRGBA := ChunkPLTE.Item[ByteData];
                pDstRGB^.rgbtBlue  := pngImage.GammaTable[SrcRGBA.rgbRed];
                pDstRGB^.rgbtGreen := pngImage.GammaTable[SrcRGBA.rgbGreen];
                pDstRGB^.rgbtRed   := pngImage.GammaTable[SrcRGBA.rgbBlue];
              end;  
            end;

            bRet := True;
          end;
        COLOR_RGBALPHA:
          begin
            for y := 0 to m_nHeight - 1 do
            begin
              for x := 0 to m_nWidth - 1 do
              begin
                pSrcRGB := @pRGBLine(pngimage.Scanline[y])^[x];
                pIntData := PCardinal(  Cardinal(m_pData) + bytesPerRow * y + SizeOf(Cardinal) * x );

                r := pSrcRGB^.rgbtRed;
                g := pSrcRGB^.rgbtGreen;
                b := pSrcRGB^.rgbtBlue;
                a := pngImage.AlphaScanline[y][x];

                pIntData^ := ((  r * (a + 1) ) shr 8 ) or
                             ((( g * (a + 1) ) shr 8 ) shl 8) or
                             ((( b * (a + 1) ) shr 8 ) shl 16) or
                             (   a shl 24);
              end;
            end;

            bRet := True;
          end;
        COLOR_GRAYSCALE:
          begin
            DataDepth := pngimage.Header.BitDepth;
            if DataDepth > 8 then
              DataDepth := 8;

            for y := 0 to m_nHeight-1 do
            begin
              for x := 0 to m_nWidth-1 do
              begin
                ByteData := pByteArray(pngimage.Scanline[y])^[x div (8 div DataDepth)];
                {$WARNINGS OFF}
                ByteData := (ByteData shr ((8 - DataDepth) - (X mod (8 div DataDepth)) * DataDepth));
                {$WARNINGS ON}
                ByteData:= ByteData and ($FF shr (8 - DataDepth));

                if pngimage.Header.BitDepth = 1 then
                  ByteData := pngimage.GammaTable[Byte(ByteData * 255)]
                else
                  ByteData := pngimage.GammaTable[ByteData * ((1 shl DataDepth) + 1)];

                pDstRGB := PRGBTriple(  Cardinal(m_pData) + bytesPerRow * y + SizeOf(TRGBTriple) * x );
                pDstRGB^.rgbtBlue  := ByteData;
                pDstRGB^.rgbtGreen := ByteData;
                pDstRGB^.rgbtRed   := ByteData;
              end;  
            end;

            bRet := True;
          end;
        COLOR_GRAYSCALEALPHA:
          begin
            for y := 0 to m_nHeight-1 do
            begin
              for x := 0 to m_nWidth-1 do
              begin
                ByteData := pByteArray(pngimage.Scanline[y])^[x];

                pIntData := PCardinal(  Cardinal(m_pData) + bytesPerRow * y + SizeOf(Cardinal) * x );

                r := ByteData;
                g := ByteData;
                b := ByteData;
                a := pngImage.AlphaScanline[y][x];

                pIntData^ := ((  r * (a + 1) ) shr 8 ) or
                             ((( g * (a + 1) ) shr 8 ) shl 8) or
                             ((( b * (a + 1) ) shr 8 ) shl 16) or
                             (   a shl 24);
              end;
            end;

            bRet := True;
          end;
      end;
    finally
      pngimage.Free;
    end;

  until True;

  Result := bRet;
end;

function CCImage._initWithRawData(pData: Pointer; nDataLen, nWidth,
  nHeight, nBitsPerComponent: Integer): Boolean;
var
  bRet: Boolean;
  nBytesPerComponent, nSize: Integer;
begin
  bRet := False;

  repeat

    if (nWidth = 0) or (nHeight = 0) then
      Break;

    m_nBitsPerComponent := nBitsPerComponent;
    m_nHeight := nHeight;
    m_nWidth := nWidth;
    m_bHasAlpha := True;

    nBytesPerComponent := 4;
    nSize := nHeight * nWidth * nBytesPerComponent;
    m_pData := AllocMem(nSize);
    if m_pData = nil then
      Break;

    Move(pData^, m_pData^, nSize);

    bRet := True;
    
  until True;

  Result := bRet;
end;

function CCImage._initWithTgaData(pData: Pointer;
  nDataLen: Integer): Boolean;
var
  tga: TTargaGraphic;
  mms: TMemoryStream;
  BytesPerRow: Cardinal;
begin
  mms := TMemoryStream.Create(pData, nDataLen);
  tga := TTargaGraphic.Create;
  try
    tga.LoadFromStream(mms);

    m_nWidth := tga.Width;
    m_nHeight := tga.Height;
    m_nBitsPerComponent := 8;
    m_bHasAlpha := tga.HasAlpha;
    if tga.PixelBitCount = 24 then
    begin
      BytesPerRow := (((24 * m_nWidth + 31) and not 31) div 8);
      m_pData := AllocMem(BytesPerRow * m_nHeight);
      Move(tga.fData^, m_pData^, BytesPerRow * m_nHeight);
    end;

    Result := True;
  finally
    tga.Free;
    mms.Free;
  end;
end;

function CCImage._initWithTiffData(pData: Pointer;
  nDataLen: Integer): Boolean;
var
  tif: TTIFFGraphic;
  mms: TMemoryStream;
  BytesPerRow: Cardinal;
  x, y: Cardinal;
  pSrcRGBA, pDstRGBA: PRGBQuad;
begin
  mms := TMemoryStream.Create(pData, nDataLen);
  tif := TTIFFGraphic.Create;
  try
    tif.LoadFromStream(mms);

    m_nWidth := tif.Width;
    m_nHeight := tif.Height;
    m_nBitsPerComponent := 8;
    m_bHasAlpha := tif.HasAlpha;
    if tif.PixelBitCount = 24 then
    begin
      BytesPerRow := (((24 * m_nWidth + 31) and not 31) div 8);
      m_pData := AllocMem(BytesPerRow * m_nHeight);
      Move(tif.fData^, m_pData^, BytesPerRow * m_nHeight);
    end else if tif.PixelBitCount = 32 then
    begin
      BytesPerRow := (((32 * m_nWidth + 31) and not 31) div 8);
      m_pData := AllocMem(BytesPerRow * m_nHeight);

      for y := 0 to m_nHeight-1 do
      begin
        pSrcRGBA := tif.ScanLine[y];
        for x := 0 to m_nWidth-1 do
        begin
          pDstRGBA := PRGBQuad(Cardinal(m_pData) + BytesPerRow * y + x * 4);

          pDstRGBA^.rgbBlue := pSrcRGBA^.rgbRed;
          pDstRGBA^.rgbGreen := pSrcRGBA^.rgbGreen;
          pDstRGBA^.rgbRed := pSrcRGBA^.rgbBlue;
          pDstRGBA^.rgbReserved := pSrcRGBA^.rgbReserved;

          Inc(pSrcRGBA);
        end;  
      end;
    end;  

    Result := True;
  finally
    tif.Free;
    mms.Free;
  end;
end;

{ BitmapDC }

constructor BitmapDC.Create(hw: HWND);
var
  dc:HDC;
begin
  m_hWnd := hw;
  dc := Windows.GetDC(hw);
  m_hDC := CreateCompatibleDC(dc);
  m_hFont := GetStockObject(DEFAULT_GUI_FONT);
  ReleaseDC(hw, dc)
end;

destructor BitmapDC.Destroy;
var
  hDefFont: HFONT;
//  pwszBuffer: PWChar;
begin
  prepareBitmap(0, 0);
  if m_hDC > 0 then
    DeleteDC(m_hDC);

  hDefFont := GetStockObject(DEFAULT_GUI_FONT);
  if hDefFont <> m_hFont then
  begin
    DeleteObject(m_hFont);
    m_hFont := hDefFont;
  end;

  if Length(m_curFontPath) > 0 then
  begin
    //pwszBuffer := utf8ToUtf16(m_curFontPath);
    //if pwszBuffer <> nil then
    begin
      RemoveFontResource(PChar(m_curFontPath));
      SendMessage(m_hWnd, WM_FONTCHANGE, 0, 0);
    end;
  end;

  inherited;
end;

function BitmapDC.drawText(const pszText: string; var Size: TSize;
  eAlign: ETextAlign): Integer;
var
  nRet, nLen: Integer;
  dwFmt, dwHoriFlag, dwVertFlag: Cardinal;
  newSize: TSize;
  rcText: TRect;
  offsetX, offsetY: Cardinal;
  hOldFont, hOldBmp: HGDIOBJ;
begin
  nRet := 0;
  repeat
    if pszText = '' then
      Break;

    dwFmt := DT_WORDBREAK;
    dwHoriFlag := Byte(eAlign) and $0F;
    dwVertFlag := (Byte(eAlign) and $F0) shr 4;

    case dwHoriFlag of
      1: dwFmt := dwFmt or DT_LEFT;
      2: dwFmt := dwFmt or DT_RIGHT;
      3: dwFmt := dwFmt or DT_CENTER;
    end;

    nLen := Length(pszText);
    newSize := sizeWithText(pszText, nLen, dwFmt, Size.cx);

    rcText.Left := 0; rcText.Right := 0; rcText.Top := 0; rcText.Bottom := 0;
    if Size.cx < 1 then
    begin
      Size := newSize;
      rcText.Right := newSize.cx;
      rcText.Bottom := newSize.cy;
    end else
    begin
      offsetX := 0; offsetY := 0;
      rcText.Right := newSize.cx;

      if (dwHoriFlag <> 1) and (newSize.cx < Size.cx) then
      begin
        if dwHoriFlag = 2 then
          offsetX := Size.cx - newSize.cx
        else
          offsetX := (Size.cx - newSize.cx) div 2;
      end;

      if Size.cy < 1 then
      begin
        Size.cy := newSize.cy;
        dwFmt := dwFmt or DT_NOCLIP;
        rcText.Bottom := newSize.cy;
      end else if Size.cy < newSize.cy then
      begin
        rcText.Bottom := Size.cy;
      end else
      begin
        rcText.Bottom := newSize.cy;
        dwFmt := dwFmt or DT_NOCLIP;

        if dwVertFlag = 2 then
          offsetY := Size.cy - newSize.cy
        else
        begin
          if dwVertFlag = 3 then
            offsetY := (Size.cy - newSize.cy) div 2
          else
            offsetY := 0;
        end;  
      end;

      if (offsetX = 0) or (offsetY = 0) then
      begin
        OffsetRect(rcText, offsetX, offsetY)
      end;  
    end;

    if not prepareBitmap(Size.cx, Size.cy) then
      Break;

    hOldFont := SelectObject(m_hDC, m_hFont);
    hOldBmp := SelectObject(m_hDC, m_hBmp);

    SetBkMode(m_hDC, TRANSPARENT);
    SetTextColor(m_hDC, RGB(255, 255, 255));

    nRet := Windows.DrawText(m_hDC, PChar(pszText), nLen, rcText, dwFmt);

    SelectObject(m_hDC, hOldBmp);
    SelectObject(m_hDC, hOldFont);

  until True;

  Result := nRet;
end;

function BitmapDC.getBitmap: HBITMAP;
begin
  Result := m_hBmp;
end;

function BitmapDC.getDC: HDC;
begin
  Result := m_hDC;
end;

function BitmapDC.prepareBitmap(nWidth, nHeight: Integer): Boolean;
begin
  if m_hBmp > 0 then
  begin
    DeleteObject(m_hBmp);
    m_hBmp := 0;
  end;

  if (nWidth > 0) and (nHeight > 0) then
  begin
    m_hBmp := CreateBitmap(nWidth, nHeight, 1, 32, nil);
    if m_hBmp = 0 then
    begin
      Result := False;
      Exit;
    end;  
  end;
  Result := True;
end;

function BitmapDC.setFont(const pFontName: string; nSize: Integer): Boolean;
var
  bRet: Boolean;
  fontName: string;
  fontPath: string;
  hDefFont: HFONT;
  tNewFont, tOldFont: TLogFont;
  nFindttf, _nFindTTF: Integer;
  nFindPos: Integer;
begin
  bRet := False;

  repeat
    fontName := pFontName;
    hDefFont := GetStockObject(DEFAULT_GUI_FONT);
    GetObject(hDefFont, SizeOf(tNewFont), @tNewFont);
    if Length(fontName) > 0 then
    begin
      nFindttf := Pos('.ttf', fontName);
      _nFindTTF := Pos('.TTF', fontName);

      if (nFindttf > 0) or (_nFindTTF > 0)  then
      begin
        fontPath := CCFileUtils.sharedFileUtils().fullPathForFilename(fontName);
        nFindPos := find_last_of('\', fontName);
        if nFindPos = 0 then
          nFindPos := find_last_of('/', fontName);
        if nFindPos <> 0 then
          fontName := Copy(fontName, nFindPos + 1, Length(fontName) - nFindPos);
      end;
      tNewFont.lfCharSet := DEFAULT_CHARSET;
      StrPLCopy(@tNewFont.lfFaceName[0], fontName, LF_FACESIZE);
    end;

    if nSize > 0 then
    begin
      tNewFont.lfHeight := -nSize;
    end;

    GetObject(m_hFont, SizeOf(tOldFont), @tOldFont);

    if (tOldFont.lfHeight = tNewFont.lfHeight) and (StrComp(tOldFont.lfFaceName, tNewFont.lfFaceName) = 0) then
    begin
      bRet := True;
      Break;
    end;

    if m_hFont <> hDefFont then
    begin
      DeleteObject(m_hFont);
      if Length(m_curFontPath) > 0 then
      begin
        if RemoveFontResource(PChar(m_curFontPath)) then
          SendMessage(m_hWnd, WM_FONTCHANGE, 0, 0);
      end;

      if Length(fontPath) > 0 then
        m_curFontPath := fontPath
      else
        m_curFontPath := '';


      if Length(m_curFontPath) > 0 then
      begin
        if AddFontResource(PChar(m_curFontPath)) > 0 then
        begin
          SendMessage(m_hWnd, WM_FONTCHANGE, 0, 0);
        end;  
      end;
    end;

    m_hFont := 0;

    tNewFont.lfQuality := ANTIALIASED_QUALITY;

    m_hFont := CreateFontIndirect(tNewFont);
    if m_hFont = 0 then
    begin
      m_hFont := hDefFont;
      Break;
    end;

    bRet := True;
  until True;

  Result := bRet;
end;

function BitmapDC.sizeWithText(const pszText: string; nLen: Integer; dwFmt,
  nWidthLimit: Cardinal): TSize;
var
  tRet: TSize;
  rc: TRect;
  dwCalcFmt: Cardinal;
  hOld: HGDIOBJ;
begin
  tRet.cx := 0; tRet.cy := 0;

  repeat
    if (pszText = '') or (nLen < 1) then
      Break;


    rc.Left := 0; rc.Right := 0; rc.Top := 0; rc.Bottom := 0;
    dwCalcFmt := DT_CALCRECT;

    if nWidthLimit > 0 then
    begin
      rc.Right := nWidthLimit;
      dwCalcFmt := dwCalcFmt or DT_WORDBREAK or (dwFmt and DT_CENTER) or (dwFmt and DT_RIGHT);
    end;  

    hOld := SelectObject(m_hDC, m_hFont);

    Windows.DrawText(m_hDC, PChar(pszText), nLen, rc, dwCalcFmt);
    SelectObject(m_hDC, hOld);

    tRet.cx := rc.Right;
    tRet.cy := rc.Bottom;

  until True;

  Result := tRet;
end;

initialization
finalization
  if s_BmpDC <> nil then
    s_BmpDC.Free;

end.
