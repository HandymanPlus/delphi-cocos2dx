unit Cocos2dx.CCImage;

interface
uses
  iOSapi.Foundation, iOSapi.UIKit, iOSapi.CoreGraphics,
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
    //function _initWithPngData(pData: Pointer; nDataLen: Integer): Boolean;
    //function _initWithJpgData(pData: Pointer; nDataLen: Integer): Boolean;
    //function _initWithTgaData(pData: Pointer; nDataLen: Integer): Boolean;
    //function _initWithTiffData(pData: Pointer; nDataLen: Integer): Boolean;
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
  System.SysUtils,
  Macapi.CoreFoundation, Macapi.ObjectiveC,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCFileUtils, Cocos2dx.CCPointerArray;

type
  tImageInfo = record
    height: Cardinal;
    width: Cardinal;
    bitsPerComponent: Integer;
    hasAlpha: Boolean;
    isPremultipliedAlpha: Boolean;
    hasShadow: Boolean;
    shadowOffset: CGSize;
    shadowBlur: single;
    shadowOpacity: single;
    hasStroke: Boolean;
    strokeColorR: single;
    strokeColorG: single;
    strokeColorB: single;
    strokeSize: single;
    tintColorR: single;
    tintColorG: single;
    tintColorB: single;
    data: PByte;
  end;
  PtImageInfo = ^tImageInfo;

function _initWithImage(cgImage: CGImageRef; pImageInfo: PtImageInfo): Boolean;
var
  info: CGImageAlphaInfo;
  systemVersion: single;
  colorSpace: CGColorSpaceRef;
  context: CGContextRef;
begin
  if cgImage = nil then
    Exit(False);

  pImageInfo^.width := CGImageGetWidth(cgImage);
  pImageInfo^.height := CGImageGetHeight(cgImage);

  info := CGImageGetAlphaInfo(cgImage);
  pImageInfo^.hasAlpha := (info = kCGImageAlphaPremultipliedLast) or
                          (info = kCGImageAlphaPremultipliedFirst) or
                          (info = kCGImageAlphaLast) or
                          (info = kCGImageAlphaFirst);

  systemVersion := TUIDevice.Wrap(TUIDevice.OCClass.currentDevice).systemVersion.floatValue;
  if systemVersion < 5.0 then
  begin
    pImageInfo^.hasAlpha := (pImageInfo^.hasAlpha) or (info = kCGImageAlphaNoneSkipLast);
  end;

  colorSpace := CGImageGetColorSpace(cgImage);
  if colorSpace <> nil then
  begin
    if pImageInfo^.hasAlpha then
    begin
      info := kCGImageAlphaPremultipliedLast;
      pImageInfo^.isPremultipliedAlpha := True;
    end else
    begin
      info := kCGImageAlphaNoneSkipLast;
      pImageInfo^.isPremultipliedAlpha := False;
    end;
  end else
  begin
    Exit(False);
  end;

  pImageInfo^.hasAlpha := True;
  pImageInfo^.bitsPerComponent := 8;
  pImageInfo^.data := AllocMem(pImageInfo^.width * pImageInfo^.height * 4);
  colorSpace := CGColorSpaceCreateDeviceRGB();

  context := CGBitmapContextCreate(pImageInfo^.data,
                                   pImageInfo^.width,
                                   pImageInfo^.height,
                                   8,
                                   4 * pImageInfo^.width,
                                   colorSpace,
                                   info or kCGBitmapByteOrder32Big);
  CGContextClearRect(context, CGRectMake(0, 0, pImageInfo^.width, pImageInfo^.height));
  CGContextDrawImage(context, CGRectMake(0, 0, pImageInfo^.width, pImageInfo^.height), cgImage);
  CGContextRelease(context);
  CFRelease(colorSpace);

  Result := True;
end;

function _initWithFile(const path: string; pImageInfo: PtImageInfo): Boolean;
var
  CGImage: CGImageRef;
  jpg, png: UIImage;
  ret: Boolean;
  fullPath: NSString;
begin
  fullPath := NSSTR(path);//TNSString.Wrap(TNSString.OCClass.stringWithUTF8String(MarshaledAString(path)));
  jpg := TUIImage.Alloc;
  jpg.initWithContentsOfFile(fullPath);
  png := TUIImage.Alloc;
  png.initWithData( TNSData.Wrap(UIImagePNGRepresentation((jpg as ILocalObject).GetObjectID)));
  CGImage := png.CGImage;

  ret := _initWithImage(CGImage, pImageInfO);

  png.release;
  jpg.release;

  Result := ret;
end;

function _initWithData(pBuffer: Pointer; length: Integer; pImageInfo: PtImageInfo): Boolean;
var
  bRet: Boolean;
  CGImage: CGImageRef;
  data: NSData;
begin
  bRet := False;
  if pBuffer <> nil then
  begin
    data := TNSData.Wrap(TNSData.OCClass.dataWithBytes(pBuffer, length));
    CGImage := TUIImage.Wrap(TUIImage.OCClass.imageWithData(data)).CGImage;

    bRet := _initWithImage(CGImage, pImageInfo);
  end;

  Result := bRet;
end;

function _calculateStringSize(str: NSString; font: Pointer; var constrainSize: CGSize): CGSize;
begin
  Result.width := 0;
  Result.height := 0;
end;

function _initWithString(pText: string; eAlign: ETextAlign; pFontName: string; nSize: Integer; pInfo: PtImageInfo): Boolean;
begin
  Result := False;
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
end;

destructor CCImage.Destroy;
begin
  CC_SAFE_FREE_POINTER(m_pData);
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
  eFmt: EImageFormat; nWidth, nHeight, nBitsPerComponent: Integer): Boolean;
var
  bRet: Boolean;
  info: tImageInfo;
begin
  bRet := False;

  repeat

    if (pData = nil) and (nDataLen < 1) then
      Break;

    if eFmt = kFmtRawData then
    begin
      bRet := _initWithRawData(pData, nDataLen, nWidth, nHeight, nBitsPerComponent);
    end else
    begin
      bRet := _initWithData(pData, nDataLen, @info);
      if bRet then
      begin
        m_nHeight := info.height;
        m_nWidth := info.width;
        m_nBitsPerComponent := info.bitsPerComponent;
        m_bHasAlpha := info.hasAlpha;
        m_bPreMulti := info.isPremultipliedAlpha;
        m_pData := info.data;
      end;
    end;

  until True;

  Result := bRet;
end;

function CCImage.initWithImageFile(const strPath: string;
  imageType: EImageFormat): Boolean;
var
  bRet: Boolean;
  nSize: Cardinal;
  pBuffer: PByte;
  fullPath: string;
begin
  bRet := False;
  nSize := 0;

  fullPath := CCFileUtils.sharedFileUtils.fullPathForFilename(strPath);
  pBuffer := CCFileUtils.sharedFileUtils.getFileData(fullPath, 0, @nSize);
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
  bRet: Boolean;
  nSize: Cardinal;
  pBuffer: PByte;
begin
  bRet := False;
  nSize := 0;

  pBuffer := CCFileUtils.sharedFileUtils.getFileData(fullpath, 0, @nSize);
  if (pBuffer <> nil) and (nSize > 0) then
  begin
    bRet := initWithImageData(pBuffer, nSize, imageType);
  end;

  CC_SAFE_FREE_POINTER(pBuffer);
  Result := bRet;
end;

function CCImage.initWithString(const pText: string; nWidth, nHeight: Integer;
  eAlignMask: ETextAlign; const pFontName: string; nSize: Integer): Boolean;
var
  info: tImageInfo;
begin
  info.width := nWidth;
  info.height := nHeight;

  if not _initWithString(pText, eAlignMask, pFontName, nSize, @info) then
    Exit(False);

  m_nHeight := info.height;
  m_nWidth := info.width;
  m_nBitsPerComponent := info.bitsPerComponent;
  m_bHasAlpha := info.hasAlpha;
  m_bPreMulti := info.isPremultipliedAlpha;
  m_pData := info.data;

  Result := True;
end;

function CCImage.isPremultipliedAlpha: Boolean;
begin
  Result := m_bPreMulti;
end;

function CCImage.saveToFile(const pszFilePath: string;
  bIsToRGB: Boolean): Boolean;
var
  saveToPNG: Boolean;
  needToCopyPixels: Boolean;
  filePath: string;
  bitsPerComponent, bitsPerPixel: Cardinal;
  bytesPerRow, myDataLength: Cardinal;
  pixels, pSource: PByteArray;
  i, j: Cardinal;
  bitmapInfo: CGBitmapInfo;
  provider: CGDataProviderRef;
  colorSpaceRef: CGColorSpaceRef;
  iref: CGImageRef;
  image: UIImage;
  data: NSData;
begin
  saveToPng := False;
  needToCopyPixels := False;
  filePath := pszFilePath;
  if filePath.Contains('.png') then
  begin
    saveToPNG := True;
  end;

  bitsPerComponent := 8;
  if m_bHasAlpha then
    bitsPerPixel := 32
  else
    bitsPerPixel := 24;

  if (not saveToPNG) or bIsToRGB then
    bitsPerPixel := 24;

  bytesPerRow := (bitsPerPixel div 8) * m_nWidth;
  myDataLength := bytesPerRow * m_nHeight;
  pixels := PByteArray(m_pData);

  if (saveToPNG and m_bHasAlpha and bIsToRGB) or (not saveToPNG) then
  begin
    pSource := PByteArray(m_pData);
    pixels := AllocMem(myDataLength);

    for i := 0 to m_nHeight-1 do
    begin
      for j := 0 to m_nWidth-1 do
      begin
        pixels[(i * m_nWidth + j) * 3 + 0] := pSource[(i * m_nWidth + j) * 4 + 0];
        pixels[(i * m_nWidth + j) * 3 + 1] := pSource[(i * m_nWidth + j) * 4 + 1];
        pixels[(i * m_nWidth + j) * 3 + 2] := pSource[(i * m_nWidth + j) * 4 + 2];
      end;
    end;
    needToCopyPixels := True;
  end;

  bitmapinfo := kCGBitmapByteOrderDefault;
  if saveToPng and m_bHasAlpha and not bIsToRGB then
    bitmapInfo := bitmapInfo or kCGImageAlphaPremultipliedLast;

  provider := CGDataProviderCreateWithData(nil, pixels, myDataLength, nil);
  colorSpaceRef := CGColorSpaceCreateDeviceRGB();
  iref := CGImageCreate(m_nWidth, m_nHeight, bitsPerComponent, bitsPerPixel, bytesPerRow,
                        colorSpaceRef, bitmapInfo, provider, nil, 0, kCGRenderingIntentDefault);
  image := TUIImage.Wrap(TUIImage.Alloc.initWithCGImage(iref));

  CGImageRelease(iref);
  CGColorSpaceRelease(colorSpaceRef);
  CGDataProviderRelease(provider);

  if saveToPNG then
    data := TNSData.Wrap(UIImagePNGRepresentation((image as ILocalObject).GetObjectID))
  else
    data := TNSData.Wrap(UIImageJPEGRepresentation((image as ILocalObject).GetObjectID, 1));

  data.writeToFile(NSSTR(pszFilePath), True);
  image.release;

  if needToCopyPixels then
  begin
    FreeMem(pixels);
  end;

  Result := True;
end;

function CCImage._initWithRawData(pData: Pointer; nDataLen, nWidth, nHeight,
  nBitsPerComponent: Integer): Boolean;
var
  bRet: Boolean;
  nBytesPerComponent, nSize: Integer;
begin
  bRet := False;
  repeat

    if (nWidth < 1) or (nHeight < 1) then
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

(*function CCImage._initWithTgaData(pData: Pointer; nDataLen: Integer): Boolean;
begin
  Result := False;
end;

function CCImage._initWithTiffData(pData: Pointer; nDataLen: Integer): Boolean;
begin
  Result := False;
end;

function CCImage._initWithJpgData(pData: Pointer; nDataLen: Integer): Boolean;
begin
  Result := False;
end;

function CCImage._initWithPngData(pData: Pointer; nDataLen: Integer): Boolean;
begin
  Result := False;
end;*)

end.
