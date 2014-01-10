(****************************************************************************
Copyright (c) 2010-2013 cocos2d-x.org

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

unit Cocos2dx.CCFileUtils;

interface

{$I config.inc}

uses
  {$ifdef MSWINDOWS} Windows, {$else} iOSapi.Foundation, {$endif}
  StrUtils, SysUtils, Cocos2dx.CCObject, Cocos2dx.CCDictionary,
  Cocos2dx.CCTypeInfo, Cocos2dx.CCVector, Cocos2dx.CCArray,
  Hashes;

type
  CCFileUtils = class(TInterfaceObjectNull, TypeInfo)
  private
    m_obDirectory: string{array [0..MAX_PATH-1] of Char};
  protected
    m_pFilenameLookupDict: CCDictionary;
    m_searchResolutionsOrderArray: TVectorString;
    m_searchPathArray: TVectorString;
    m_fullPathCache: TStringHash;
    m_strDefaultResRootPath: string;

    function init(): Boolean; virtual;
    function getNewFilename(const pszFileName: string): string; virtual;
    function getPathForFilename(const filename, resolutionDirectory, searchPath: string): string; virtual;
    function getFullPathForDirectoryAndFilename(const strDirectory, strFilename: string): string; virtual;
    function createCCDictionaryWithContentsOfFile(const filename: string): CCDictionary; virtual;
    function writeToFile(dict: CCDictionary; const fullPath: string): Boolean; virtual;
    function createCCArrayWithContentsOfFile(const filename: string): CCArray; virtual;
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedFileUtils(): CCFileUtils;
    class procedure purgeFileUtils();
    function getClassTypeInfo(): Cardinal;
    (**
     *  Purges the file searching cache.
     *
     *  @note It should be invoked after the resources were updated.
     *        For instance, in the CocosPlayer sample, every time you run application from CocosBuilder,
     *        All the resources will be downloaded to the writable folder, before new js app launchs,
     *        this method should be invoked to clean the file search cache.
     *)
    procedure purgeCachedEntries(); virtual;
    (**
     *  Gets resource file data
     *
     *  @param[in]  pszFileName The resource file name which contains the path.
     *  @param[in]  pszMode The read mode of the file.
     *  @param[out] pSize If the file read operation succeeds, it will be the data size, otherwise 0.
     *  @return Upon success, a pointer to the data is returned, otherwise NULL.
     *  @warning Recall: you are responsible for calling delete[] on any Non-NULL pointer returned.
     *  @js NA
     *)
    function getFileData(const pszFilename: string; pszMode: Cardinal; pSize: PCardinal): PByte; virtual;
    (**
     *  Gets resource file data from a zip file.
     *
     *  @param[in]  pszFileName The resource file name which contains the relative path of the zip file.
     *  @param[out] pSize If the file read operation succeeds, it will be the data size, otherwise 0.
     *  @return Upon success, a pointer to the data is returned, otherwise NULL.
     *  @warning Recall: you are responsible for calling delete[] on any Non-NULL pointer returned.
     *  @js NA
     *)
    function getFileDataFromZip(const pszFilepath, pszFilename: string; pSize: PCardinal): PByte; virtual;
    (**
     *  Gets full path from a file name and the path of the reletive file.
     *  @param pszFilename The file name.
     *  @param pszRelativeFile The path of the relative file.
     *  @return The full path.
     *          e.g. pszFilename: hello.png, pszRelativeFile: /User/path1/path2/hello.plist
     *               Return: /User/path1/path2/hello.pvr (If there a a key(hello.png)-value(hello.pvr) in FilenameLookup dictionary. )
     *
     *)
    function fullPathFromRelativeFile(const pszFilename: string; pszRelativeFile: string): string; virtual;
    procedure setResourceDirectory(const pszDirectoryName: string);
    function getResourceDirectory(): string;

    procedure setPopupNotify(bNotify: Boolean); virtual;
    function isPopupNotify(): Boolean; virtual;
    (** Returns the fullpath for a given filename.
     
     First it will try to get a new filename from the "filenameLookup" dictionary.
     If a new filename can't be found on the dictionary, it will use the original filename.
     Then it will try to obtain the full path of the filename using the CCFileUtils search rules: resolutions, and search paths.
     The file search is based on the array element order of search paths and resolution directories.
     
     For instance:

     	We set two elements("/mnt/sdcard/", "internal_dir/") to search paths vector by setSearchPaths,
     	and set three elements("resources-ipadhd/", "resources-ipad/", "resources-iphonehd")
     	to resolutions vector by setSearchResolutionsOrder. The "internal_dir" is relative to "Resources/".

		If we have a file named 'sprite.png', the mapping in fileLookup dictionary contains `key: sprite.png -> value: sprite.pvr.gz`.
     	Firstly, it will replace 'sprite.png' with 'sprite.pvr.gz', then searching the file sprite.pvr.gz as follows:

     	    /mnt/sdcard/resources-ipadhd/sprite.pvr.gz      (if not found, search next)
     	    /mnt/sdcard/resources-ipad/sprite.pvr.gz        (if not found, search next)
     	    /mnt/sdcard/resources-iphonehd/sprite.pvr.gz    (if not found, search next)
     	    /mnt/sdcard/sprite.pvr.gz                       (if not found, search next)
     	    internal_dir/resources-ipadhd/sprite.pvr.gz     (if not found, search next)
     	    internal_dir/resources-ipad/sprite.pvr.gz       (if not found, search next)
     	    internal_dir/resources-iphonehd/sprite.pvr.gz   (if not found, search next)
     	    internal_dir/sprite.pvr.gz                      (if not found, return "sprite.png")

        If the filename contains relative path like "gamescene/uilayer/sprite.png",
        and the mapping in fileLookup dictionary contains `key: gamescene/uilayer/sprite.png -> value: gamescene/uilayer/sprite.pvr.gz`.
        The file search order will be:

     	    /mnt/sdcard/gamescene/uilayer/resources-ipadhd/sprite.pvr.gz      (if not found, search next)
     	    /mnt/sdcard/gamescene/uilayer/resources-ipad/sprite.pvr.gz        (if not found, search next)
     	    /mnt/sdcard/gamescene/uilayer/resources-iphonehd/sprite.pvr.gz    (if not found, search next)
     	    /mnt/sdcard/gamescene/uilayer/sprite.pvr.gz                       (if not found, search next)
     	    internal_dir/gamescene/uilayer/resources-ipadhd/sprite.pvr.gz     (if not found, search next)
     	    internal_dir/gamescene/uilayer/resources-ipad/sprite.pvr.gz       (if not found, search next)
     	    internal_dir/gamescene/uilayer/resources-iphonehd/sprite.pvr.gz   (if not found, search next)
     	    internal_dir/gamescene/uilayer/sprite.pvr.gz                      (if not found, return "gamescene/uilayer/sprite.png")

     If the new file can't be found on the file system, it will return the parameter pszFileName directly.
     
     This method was added to simplify multiplatform support. Whether you are using cocos2d-js or any cross-compilation toolchain like StellaSDK or Apportable,
     you might need to load different resources for a given file in the different platforms.

     @since v2.1
     *)
    function fullPathForFilename(const pszFileName: string): string; virtual;
    (**
     * Loads the filenameLookup dictionary from the contents of a filename.
     * 
     * @note The plist file name should follow the format below:
     * 
     * @code
     * <?xml version="1.0" encoding="UTF-8"?>
     * <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     * <plist version="1.0">
     * <dict>
     *     <key>filenames</key>
     *     <dict>
     *         <key>sounds/click.wav</key>
     *         <string>sounds/click.caf</string>
     *         <key>sounds/endgame.wav</key>
     *         <string>sounds/endgame.caf</string>
     *         <key>sounds/gem-0.wav</key>
     *         <string>sounds/gem-0.caf</string>
     *     </dict>
     *     <key>metadata</key>
     *     <dict>
     *         <key>version</key>
     *         <integer>1</integer>
     *     </dict>
     * </dict>
     * </plist>
     * @endcode
     * @param filename The plist file name.
     *
     * @since v2.1
     * @loadFilenameLookup
     *)
    procedure loadFilenameLookupDictionaryFromFile(const filename: string); virtual;
    (**
     *  Sets the filenameLookup dictionary.
     *
     *  @param pFilenameLookupDict The dictionary for replacing filename.
     *  @since v2.1
     *  @lua NA
     *)
    procedure setFilenameLookupDictionary(pFilenameLookupDict: CCDictionary); virtual;
    {**
     *  Sets the array that contains the search order of the resources.
     *
     *  @param searchResolutionsOrder The source array that contains the search order of the resources.
     *  @see getSearchResolutionsOrder(void), fullPathForFilename(const char*).
     *  @since v2.1
     *  @js NA
     *  @lua NA
     *}
    procedure setSearchResolutionsOrder(searchResolutionsOrder: TVectorString); virtual;
    (**
      * Append search order of the resources.
      *
      * @see setSearchResolutionsOrder(), fullPathForFilename().
      * @since v2.1
      *)
    procedure addSearchResolutionsOrder(const order: string); virtual;
    {**
     *  Gets the array that contains the search order of the resources.
     *
     *  @see setSearchResolutionsOrder(const std::vector<std::string>&), fullPathForFilename(const char*).
     *  @since v2.1
     *  @js NA
     *  @lua NA
     *}
    function getSearchResolutionsOrder(): TVectorString; virtual;
    {** 
     *  Sets the array of search paths.
     *
     *  You can use this array to modify the search path of the resources.
     *  If you want to use "themes" or search resources in the "cache", you can do it easily by adding new entries in this array.
     *
     *  @note This method could access relative path and absolute path.
     *        If the relative path was passed to the vector, CCFileUtils will add the default resource directory before the relative path.
     *        For instance:
     *        	On Android, the default resource root path is "assets/".
     *        	If "/mnt/sdcard/" and "resources-large" were set to the search paths vector,
     *        	"resources-large" will be converted to "assets/resources-large" since it was a relative path.
     *
     *  @param searchPaths The array contains search paths.
     *  @see fullPathForFilename(const char*)
     *  @since v2.1
     *  @js NA
     *  @lua NA
     *}
    procedure setSearchPaths(const searchPaths: TVectorString); virtual;
    procedure addSearchPath(const path_: string); virtual;
    procedure removeSearchPath(const path_: string); virtual;
    procedure removeAllPaths();
    function getSearchPaths(): TVectorString; virtual;
    (**
     *  Checks whether the path is an absolute path.
     *
     *  @note On Android, if the parameter passed in is relative to "assets/", this method will treat it as an absolute path.
     *        Also on Blackberry, path starts with "app/native/Resources/" is treated as an absolute path.
     *
     *  @param strPath The path that needs to be checked.
     *  @return true if it's an absolute path, otherwise it will return false.
     *  @lua NA
     *)
    function isAbsolutePath(const strPath: string): Boolean; virtual;
    {**
     *  Checks whether a file exists.
     *
     *  @note If a relative path was passed in, it will be inserted a default root path at the beginning.
     *  @param strFilePath The path of the file, it could be a relative or absolute path.
     *  @return true if the file exists, otherwise it will return false.
     *  @lua NA
     *}
    function isFileExist(const strFilePath: string): Boolean; virtual; abstract;
    (**
     *  Gets the writable path.
     *  @return  The path that can be write/read a file in
     *  @lua NA
     *)
    function getWritablePath(): string; virtual; abstract;
  end;

implementation
uses
  Cocos2dx.CCCommon, Cocos2dx.CCApplication, Cocos2dx.CCString,
  Cocos2dx.CCStrUtils, Cocos2dx.CCPlatformMacros;

var s_bPopupNotify: Boolean = True;
var s_sharedFileUtils: CCFileUtils;

{$ifdef IOS}
type
  CCFileUtilsIOS = class(CCFileUtils)
  private
    s_fileManager: NSFileManager;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure addSearchPath(const path_: string); override;
    function isAbsolutePath(const strPath: string): Boolean; override;
    function getFullPathForDirectoryAndFilename(const strDirectory, strFilename: string): string; override;
    function createCCDictionaryWithContentsOfFile(const filename: string): CCDictionary; override;
    function writeToFile(dict: CCDictionary; const fullPath: string): Boolean; override;
    function createCCArrayWithContentsOfFile(const filename: string): CCArray; override;
    function isFileExist(const strFilePath: string): Boolean; override;
    function getWritablePath(): string; override;
  end;

{ CCFileUtilsIOS }

procedure CCFileUtilsIOS.addSearchPath(const path_: string);
begin
  inherited;
end;

constructor CCFileUtilsIOS.Create;
begin
  inherited Create();
  s_fileManager := TNSFileManager.Wrap(TNSFileManager.OCClass.defaultManager);
end;

destructor CCFileUtilsIOS.Destroy;
begin
  s_fileManager := nil;
  inherited;
end;

function CCFileUtilsIOS.createCCArrayWithContentsOfFile(
  const filename: string): CCArray;
begin
  Result := nil;
end;

function CCFileUtilsIOS.createCCDictionaryWithContentsOfFile(
  const filename: string): CCDictionary;
begin
  Result := nil;
end;

function CCFileUtilsIOS.getFullPathForDirectoryAndFilename(
  const strDirectory, strFilename: string): string;
var
  nfullpath: NSString;
  fullpath: string;
begin
  if strDirectory[0] <> '/' then
  begin
    nfullpath := TNSBundle.Wrap(TNSBundle.OCClass.mainBundle).pathForResource(NSSTR(strFilename), nil, NSSTR(strDirectory));
    if nfullpath <> nil then
    begin
      Result := UTF8ToString(nfullpath.UTF8String);
      Exit;
    end;
  end else
  begin
    fullpath := strDirectory + strFilename;
    if s_fileManager.fileExistsAtPath(NSSTR(fullpath)) then
    begin
      Result := fullpath;
      Exit;
    end;
  end;

  Result := '';
end;

function CCFileUtilsIOS.getWritablePath: string;
var
  paths: NSArray;
  documentsDirectory: NSString;
  strRet: string;
begin
  paths := TNSArray.Wrap(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, True));
  documentsDirectory := TNSString.Wrap(paths.objectAtIndex(0));
  strRet := UTF8ToString(documentsDirectory.UTF8String);
  strRet := strRet + '/';
  Result := strRet;
end;

function CCFileUtilsIOS.isAbsolutePath(const strPath: string): Boolean;
var
  path: NSString;
begin
  path := NSSTR(strPath);
  Result := path.isAbsolutePath;
end;

function CCFileUtilsIOS.isFileExist(const strFilePath: string): Boolean;
var
  bRet: Boolean;
  spath, sfile: string;
  pos: Integer;
  fullpath: NSString;
begin
  if strFilePath = '' then
  begin
    Result := False;
    Exit;
  end;

  bRet := False;
  if strFilePath[0] <> '/' then
  begin
    pos := find_last_of('/', strFilePath);
    if pos <> 0 then
    begin
      sfile := stringSubstr(pos + 1, strFilePath);
      spath := stringSubstr(1, pos, strFilePath);
    end else
    begin
      sfile := strFilePath;
    end;

    fullpath := TNSBundle.Wrap(TNSBundle.OCClass.mainBundle).pathForResource(NSSTR(sfile), nil, NSSTR(spath));
    if fullpath <> nil then
      bRet := True;
  end else
  begin
    if s_fileManager.fileExistsAtPath(NSSTR(strFilePath)) then
      bRet := True;
  end;

  Result := bRet;
end;

function CCFileUtilsIOS.writeToFile(dict: CCDictionary;
  const fullPath: string): Boolean;
begin
  Result := False;
end;
{$ENDIF}

{$ifdef MSWINDOWS}
var s_pszResourcePath: array [0..MAX_PATH-1] of Char;

type
  CCFileUtilsWin32 = class(CCFileUtils)
  public
    constructor Create();
    function init(): Boolean; override;
    function getPathForFilename(const filename, resolutionDirectory, searchPath: string): string; override;
    function fullPathForFilename(const pszFileName: string): string; override;
    procedure removeSearchPath(const path_: string); override;
    procedure addSearchPath(const path_: string); override;
    function isAbsolutePath(const strPath: string): Boolean; override;
    function isFileExist(const strFilePath: string): Boolean; override;
    function getWritablePath(): string; override;
  end;

{ CCFileUtilsWin32 }

procedure _CheckPath();
var
  nNum: Integer;
begin
  if s_pszResourcePath[0] = #0 then
  begin
    nNum := GetCurrentDirectory(MAX_PATH, s_pszResourcePath);
    s_pszResourcePath[nNum] := '\';
  end;
end;

procedure CCFileUtilsWin32.addSearchPath(const path_: string);
begin
  inherited addSearchPath(path_);
end;

constructor CCFileUtilsWin32.Create;
begin
  inherited Create();
end;

function CCFileUtilsWin32.fullPathForFilename(
  const pszFileName: string): string;
begin
  Result := inherited fullPathForFilename(pszFileName);
end;

function CCFileUtilsWin32.getPathForFilename(const filename,
  resolutionDirectory, searchPath: string): string;
begin
  Result := inherited getPathForFilename(filename, resolutionDirectory, searchPath);
end;

function CCFileUtilsWin32.getWritablePath: string;
var
  full_path: array [0..MAX_PATH] of Char;
  sRet: string;
begin
  GetModuleFileName(0, @full_path[0], MAX_PATH+1);
  sRet := full_path;
  sRet := stringSubstr(1, stringRfind('\', sRet), sRet);
  Result := sRet;
end;

function CCFileUtilsWin32.init: Boolean;
begin
  _CheckPath();
  m_strDefaultResRootPath := s_pszResourcePath;
  Result := inherited init();
end;

function CCFileUtilsWin32.isAbsolutePath(const strPath: string): Boolean;
begin
  if (Length(strPath) > 2) and (strPath[2] = ':') then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCFileUtilsWin32.isFileExist(const strFilePath: string): Boolean;
var
  strPath: string;
begin
  strPath := strFilePath;

  if strFilePath = '' then
  begin
    Result := False;
    Exit;
  end;

  if not isAbsolutePath(strPath) then
  begin
    strPath := m_strDefaultResRootPath + strPath;
  end;
  Result := GetFileAttributes(PChar(strPath)) <> Cardinal(-1);
end;

procedure CCFileUtilsWin32.removeSearchPath(const path_: string);
begin
  inherited removeSearchPath(path_);
end;
{$ENDIF}

{ CCFileUtils }

procedure CCFileUtils.addSearchPath(const path_: string);
var
  strPrefix, path: string;
begin
  path := path_;
  if not isAbsolutePath(path) then
    strPrefix := m_strDefaultResRootPath;

  path := strPrefix + path_;

  if (Length(path) > 0) and (path[Length(path)] <> '/') then
    path := path + '/';

  m_searchPathArray.push_back(path);
end;

procedure CCFileUtils.addSearchResolutionsOrder(const order: string);
begin
  m_searchResolutionsOrderArray.push_back(order);
end;

constructor CCFileUtils.Create;
begin
  m_searchResolutionsOrderArray := TVectorString.Create;
  m_searchPathArray := TVectorString.Create;
  m_fullPathCache := TStringHash.Create;
end;

function CCFileUtils.createCCArrayWithContentsOfFile(
  const filename: string): CCArray;
begin
  Result := nil;
end;

function CCFileUtils.createCCDictionaryWithContentsOfFile(
  const filename: string): CCDictionary;
begin
  Result := nil;
end;

destructor CCFileUtils.Destroy;
begin
  CC_SAFE_RELEASE(m_pFilenameLookupDict);
  m_searchResolutionsOrderArray.Free;
  m_searchPathArray.Free;
  m_fullPathCache.Free;
  inherited;
end;

function CCFileUtils.fullPathForFilename(
  const pszFileName: string): string;
var
  strFileName, newFilename, fullPath: string;
  i, j: Integer;
  strSearch, strResorder: string;
begin
  strFileName := pszFileName;
  if isAbsolutePath(pszFileName) then
  begin
    Result := pszFileName;
    Exit;
  end;

  if m_fullPathCache.Exists(pszFileName) then
  begin
    Result := m_fullPathCache.Items[pszFileName];
    Exit;
  end;

  newFilename := getNewFilename(pszFileName);

  if m_searchPathArray.count() > 0 then
    for i := 0 to m_searchPathArray.count()-1 do
    begin
      strSearch := m_searchPathArray.Items[i];
      if m_searchResolutionsOrderArray.count() > 0 then
        for j := 0 to m_searchResolutionsOrderArray.count()-1 do
        begin
          strResorder := m_searchResolutionsOrderArray.Items[j];
          fullPath := getPathForFilename(newFilename, strResorder, strSearch);
          if Length(fullPath) > 0 then
          begin
            m_fullPathCache.Items[pszFileName] := fullPath;
            Result := fullPath;
            Exit;
          end;  
        end;
    end;  

  Result := pszFileName;
end;

function CCFileUtils.fullPathFromRelativeFile(const pszFilename: string;
  pszRelativeFile: string): string;
var
  relativeFile: string;
  pRet: CCString;
begin
  relativeFile := pszRelativeFile;
  pRet := CCString.Create('');
  pRet.m_sString := stringSubstr(1, stringRfind('/', relativeFile), relativeFile);
  pRet.m_sString := pRet.m_sString + getNewFilename(pszFilename);
  Result := pRet.m_sString;
end;

function CCFileUtils.getClassTypeInfo: Cardinal;
begin
  Result := 0;
end;

function CCFileUtils.getFileData(const pszFilename: string; pszMode: Cardinal;
  pSize: PCardinal): PByte;
const
  title: PChar = 'Notification';
var
  pBuffer: PByte;
  fp: THandle;
  msg: string;
  fullPath: string;
begin
  pBuffer := nil;
  pSize^ := 0;

  repeat

    fullPath := fullPathForFilename(pszFilename);
    fp := FileOpen(fullPath, pszMode);
    if fp = INVALID_HANDLE_VALUE then
      Break;

    pSize^ := FileSeek(fp, 0, 2);
    FileSeek(fp, 0, 0);
    pBuffer := AllocMem(pSize^);
    pSize^ := FileRead(fp, pBuffer^, pSize^);
    FileClose(fp);


  until True;


  if (pBuffer = nil) and isPopupNotify() then
  begin
    msg := 'Get data from file(' + pszFilename + ') failed';
    CCMessageBox(msg, title);
  end;

  Result := pBuffer;
end;

function CCFileUtils.getFileDataFromZip(const pszFilepath,
  pszFilename: string; pSize: PCardinal): PByte;
begin
  {.$MESSAGE 'no implementation'}
  Result := nil;
end;

function CCFileUtils.getFullPathForDirectoryAndFilename(const strDirectory,
  strFilename: string): string;
var
  ret: string;
begin
  ret := strDirectory + strFilename;
  if not isFileExist(ret) then
    ret := '';
  Result := ret;
end;

function CCFileUtils.getNewFilename(const pszFileName: string): string;
var
  fileNameFound: CCString;
  pszNewFileName: string;
begin
  fileNameFound := nil;
  if m_pFilenameLookupDict <> nil then
    fileNameFound := CCString(m_pFilenameLookupDict.objectForKey(pszFileName));

  if (fileNameFound = nil) or (fileNameFound.Size = 0) then
    pszNewFileName := pszFileName
  else
    pszNewFileName := fileNameFound.m_sString;

  Result := pszNewFileName;
end;

function CCFileUtils.getPathForFilename(const filename,
  resolutionDirectory, searchPath: string): string;
var
  sfile, file_path, path: string;
  pos: Integer;
begin
  sfile := filename;
  file_path := '';
  pos := find_last_of('/', filename);
  if pos <> 0 then
  begin
    file_path := stringSubstr(1, pos, filename);
    sfile := stringSubstr(pos + 1, filename);
  end;

  path := Format('%s%s%s', [searchPath, file_path, resolutionDirectory]);
  path := getFullPathForDirectoryAndFilename(path, sfile);

  Result := path;
end;

function CCFileUtils.getResourceDirectory: string;
begin
  Result := m_obDirectory;
end;

function CCFileUtils.getSearchPaths: TVectorString;
begin
  Result := m_searchPathArray;
end;

function CCFileUtils.getSearchResolutionsOrder: TVectorString;
begin
  Result := m_searchResolutionsOrderArray;
end;

function CCFileUtils.init: Boolean;
begin
  m_searchPathArray.push_back(m_strDefaultResRootPath);
  m_searchResolutionsOrderArray.push_back('');
  Result := True;
end;

function CCFileUtils.isAbsolutePath(const strPath: string): Boolean;
begin
  Result := strPath[1] = '/';
end;

function CCFileUtils.isPopupNotify: Boolean;
begin
  Result := s_bPopupNotify;
end;

procedure CCFileUtils.loadFilenameLookupDictionaryFromFile(
  const filename: string);
var
  fullPath: string;
  pDict, pMetadata: CCDictionary;
  version: Integer;
begin
  fullPath := fullPathForFilename(filename);
  if fullPath <> '' then
  begin
    pDict := CCDictionary.createWithContentsOfFile(fullPath);
    if pDict <> nil then
    begin
      pMetadata := CCDictionary(pDict.objectForKey('metadata'));
      version := CCString(pMetadata.objectForKey('version')).intValue();
      if version <> 1 then
      begin
        CCLog('cocos2d: ERROR: Invalid filenameLookup dictionary version: %d. Filename: %s', [version, filename]);
        Exit;
      end;

      setFilenameLookupDictionary(CCDictionary(pDict.objectForKey('filenames')));
    end;  
  end;  
end;

procedure CCFileUtils.purgeCachedEntries;
begin
  m_fullPathCache.Clear();
end;

class procedure CCFileUtils.purgeFileUtils;
begin
  s_sharedFileUtils.Free;
end;

procedure CCFileUtils.removeAllPaths;
begin
  m_searchPathArray.clear();
end;

procedure CCFileUtils.removeSearchPath(const path_: string);
var
  strPrefix: string;
  path: string;
begin
  path := path_;
  if not isAbsolutePath(path) then
    strPrefix := m_strDefaultResRootPath;
  path := strPrefix + path;
  if (Length(path) > 0) and (path[Length(path)] <> '/') then
    path := path + '/';

  m_searchPathArray.erase(path);
end;

procedure CCFileUtils.setFilenameLookupDictionary(
  pFilenameLookupDict: CCDictionary);
begin
  m_fullPathCache.Clear();
  CC_SAFE_RELEASE(m_pFilenameLookupDict);
  m_pFilenameLookupDict := pFilenameLookupDict;
  CC_SAFE_RETAIN(m_pFilenameLookupDict);
end;

procedure CCFileUtils.setPopupNotify(bNotify: Boolean);
begin
  s_bPopupNotify := bNotify;
end;

procedure CCFileUtils.setResourceDirectory(const pszDirectoryName: string);
var
  nLen: Integer;
begin
  m_obDirectory := pszDirectoryName;
  nLen := Length(m_obDirectory);
  if (nLen > 0) and (m_obDirectory[nLen] <> '/') then
  begin
    m_obDirectory := m_obDirectory + '/';
  end;
end;

procedure CCFileUtils.setSearchPaths(const searchPaths: TVectorString);
var
  bExistDefaultRootPath: Boolean;
  i: Integer;
  strPrefix, path, iter: string;
begin
  bExistDefaultRootPath := False;
  
  m_fullPathCache.Clear();
  m_searchPathArray.clear();

  if searchPaths.count() > 0 then
    for i := 0 to searchPaths.count()-1 do
    begin
      iter := searchPaths.Items[i];
      if not isAbsolutePath(iter) then
        strPrefix := m_strDefaultResRootPath;

      path := strPrefix + iter;
      if (Length(path) > 0) and (path[Length(path)] <> '/') then
        path := path + '/';

      if not bExistDefaultRootPath and (path = m_strDefaultResRootPath) then
        bExistDefaultRootPath := True;

      m_searchPathArray.push_back(path);
    end;

  if not bExistDefaultRootPath then
    m_searchPathArray.push_back(m_strDefaultResRootPath);
end;

procedure CCFileUtils.setSearchResolutionsOrder(
  searchResolutionsOrder: TVectorString);
var
  bExistDefault: Boolean;
  i: Integer;
  resolutionDirectory: string;
begin
  bExistDefault := False;
  m_fullPathCache.clear();
  m_searchResolutionsOrderArray.clear();
  
  if searchResolutionsOrder.count() > 0 then
    for i := 0 to searchResolutionsOrder.count()-1 do
    begin
      resolutionDirectory := searchResolutionsOrder.Items[i];
      if not bExistDefault and (resolutionDirectory = '') then
      begin
        bExistDefault := True;
      end;

      if (Length(resolutionDirectory) > 0) and (resolutionDirectory[Length(resolutionDirectory)] <> '/') then
        resolutionDirectory := resolutionDirectory + '/';

      m_searchResolutionsOrderArray.push_back(resolutionDirectory);
    end;

  if not bExistDefault then
    m_searchResolutionsOrderArray.push_back('');
end;

class function CCFileUtils.sharedFileUtils: CCFileUtils;
begin
  if s_sharedFileUtils = nil then
  begin
    {$ifdef MSWINDOWS}
    s_sharedFileUtils := CCFileUtilsWin32.Create;
    {$ENDIF}
    {$IFDEF IOS}
    s_sharedFileUtils := CCFileUtilsIOS.Create;
    {$ENDIF}
    s_sharedFileUtils.init();
  end;
  Result := s_sharedFileUtils;
end;

function CCFileUtils.writeToFile(dict: CCDictionary;
  const fullPath: string): Boolean;
begin
  Result := False;
end;


end.
