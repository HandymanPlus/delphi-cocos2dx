unit Cocos2dx.CCApplication;

interface
uses
  Windows, Messages, 
  Cocos2dx.CCApplicationProtocol, Cocos2dx.CCCommon, Cocos2dx.CCGeometry;

type
  CCApplication = class(CCApplicationProtocol)
  private
    m_hInstance: Cardinal;
    m_hAccelTable: HACCEL;
    m_nAnimationInterval: LARGE_INTEGER;
    m_startupScriptFilename: string;
  public
    constructor Create();
    destructor Destroy(); override;
    (**
    @brief    Get current applicaiton instance.
    @return Current application instance pointer.
    *)
    class function sharedApplication(): CCApplication;
    (**
    @brief    Run the message loop.
    *)
    function run(): Integer; virtual;
    (* override functions *)
    procedure setAnimationInterval(interval: Double); override;
    function getCurrentLanguage(): ccLanguageType; override;
    (**
     @brief Get target platform
     *)
    function getTargetPlatform(): TargetPlatform; override;

    procedure setStartupScriptFilename(const startupScriptFile: string);
    function getStartupScriptFilename(): string;
  end;

implementation
uses
  Cocos2dx.CCEGLView, Cocos2dx.CCDirector, Cocos2dx.CCPlatformMacros;

(**
@brief    This function change the PVRFrame show/hide setting in register.
@param  bEnable If true show the PVRFrame window, otherwise hide.
*)
procedure PVRFrameEnableControlWindow(bEnable: Boolean);
const wszValue = 'hide_gui';
const wszYNewData = 'YES';
const wszNNewData = 'NO';
const ERROR_FILE_NO_FOUND = 2;
var
  _hKey: HKEY;
  wszOldData, wszNewData: array [Byte] of Char;
  dwSize: Cardinal;
  status: Integer;
begin
  _hKey := 0;

  // Open PVRFrame control key, if not exist create it.
  if RegCreateKeyEx(HKEY_CURRENT_USER,
      'Software\Imagination Technologies\PVRVFRame\STARTUP\',
      0, nil, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS,
      nil, _hKey, nil) <> ERROR_SUCCESS then
    Exit;

  if bEnable then
    wszNewData := wszNNewData
  else
    wszNewData := wszYNewData;

  dwSize := SizeOf(wszOldData);
  status := RegQueryValueEx(_hKey, wszValue, nil, nil, @wszOldData[0], @dwSize);
  if (ERROR_FILE_NO_FOUND = status) or (ERROR_SUCCESS = status) and
     (lstrcmp(wszOldData, wszNewData) <> 0) then
  begin
    dwSize := SizeOf(Char) * (lstrlen(wszNNewData) + 1);
    RegSetValueEx(_hKey, wszValue, 0, REG_SZ, @wszNewData[0], dwSize);
  end;
  RegCloseKey(_hKey);
end;  

{ CCApplication }

var sm_pSharedApplication: CCApplication = nil;

constructor CCApplication.Create;
begin
  m_hInstance := GetModuleHandle(nil);
  m_hAccelTable := 0;
  m_nAnimationInterval.QuadPart := 0;
  sm_pSharedApplication := Self;
end;

destructor CCApplication.Destroy;
begin
  CCAssert(Self = sm_pSharedApplication, '');
  sm_pSharedApplication := nil;
  inherited;
end;

function CCApplication.getCurrentLanguage: ccLanguageType;
var
  ret: ccLanguageType;
  localID: LCID;
  primaryLanuageID: Byte;
begin
  ret := kLanguageEnglish;
  localID := GetUserDefaultLCID();
  primaryLanuageID := localID and $FF;

  case primaryLanuageID of
    LANG_CHINESE:   ret := kLanguageChinese;
    LANG_ENGLISH:   ret := kLanguageEnglish;
    LANG_FRENCH:    ret := kLanguageFrench;
    LANG_ITALIAN:   ret := kLanguageItalian;
    LANG_GERMAN:    ret := kLanguageGerman;
    LANG_SPANISH:   ret := kLanguageSpanish;
    LANG_RUSSIAN:   ret := kLanguageRussian;
    LANG_KOREAN:    ret := kLanguageKorean;
    LANG_JAPANESE:  ret := kLanguageJapanese;
    LANG_HUNGARIAN: ret := kLanguageHungarian;
    LANG_PORTUGUESE:ret := kLanguagePortuguese;
    LANG_ARABIC:    ret := kLanguageArabic;
  end;

  Result := ret;
end;

function CCApplication.getStartupScriptFilename: string;
begin
  Result := m_startupScriptFilename;
end;

function CCApplication.getTargetPlatform: TargetPlatform;
begin
  Result := kTargetWindows;
end;

function CCApplication.run: Integer;
var
  msg: TMsg;
  nFreq, nLast, nNow: LARGE_INTEGER;
  pMainWnd: CCEGLView;
begin
  PVRFrameEnableControlWindow(False);
  
  QueryPerformanceFrequency(nFreq.QuadPart);
  QueryPerformanceCounter(nLast.QuadPart);

  // Initialize instance and cocos2d.
  if not applicationDidFinishLaunching() then
  begin
    Result := 0;
    Exit;
  end;

  pMainWnd := CCEGLView.sharedOpenGLView();
  pMainWnd.centerWindow();
  ShowWindow(pMainWnd.getHWnd(), SW_SHOW);

  while True do
  begin
    if not PeekMessage(msg, 0, 0, 0, PM_REMOVE) then
    begin
      // Get current time tick.
      QueryPerformanceCounter(nNow.QuadPart);

      // If it's the time to draw next frame, draw it, else sleep a while.
      if nNow.QuadPart - nLast.QuadPart > m_nAnimationInterval.QuadPart then
      begin
        nLast.QuadPart := nNow.QuadPart;
        CCDirector.sharedDirector().mainLoop();
      end else
      begin
        Sleep(0);
      end;
      Continue;  
    end;

    if WM_QUIT = msg.message then
    begin
      // Quit message loop.
      Break;
    end;

    // Deal with windows message.
    if (m_hAccelTable = 0) or (TranslateAccelerator(msg.hwnd, m_hAccelTable, msg) = 0) then
    begin
      TranslateMessage(msg);
      DispatchMessage(msg);
    end;  
  end;

  Result := msg.wParam;
end;

procedure CCApplication.setAnimationInterval(interval: Double);
var
  nFreq: LARGE_INTEGER;
begin
  QueryPerformanceFrequency(nFreq.QuadPart);
  m_nAnimationInterval.QuadPart := Round(interval*nFreq.QuadPart);
end;

procedure CCApplication.setStartupScriptFilename(
  const startupScriptFile: string);
begin

end;

class function CCApplication.sharedApplication: CCApplication;
begin
  CCAssert(sm_pSharedApplication <> nil, 'sm_pSharedApplication is nil');
  Result := sm_pSharedApplication;
end;

end.
