unit Cocos2dx.CCCommon;

interface
uses
  Windows, SysUtils;

const
  kMaxLogLen = 16*1024;
type
  ccLanguageType = (
    kLanguageEnglish = 0,
    kLanguageChinese,
    kLanguageFrench,
    kLanguageItalian,
    kLanguageGerman,
    kLanguageSpanish,
    kLanguageRussian,
    kLanguageKorean,
    kLanguageJapanese,
    kLanguageHungarian,
    kLanguagePortuguese,
    kLanguageArabic
  );

procedure CCLog(const sFormat: string; const Args: array of const);
procedure CCMessageBox(const pszMsg, pszTitle: string);
procedure CCLuaLog(const pszMsg: PChar);

implementation

const MAX_LEN = kMaxLogLen;

procedure CCLog(const sFormat: string; const Args: array of const);
var
  outStr: string;
begin
  outStr := Format(sFormat, Args);
  OutputDebugString(PChar(outStr));
end;

procedure CCMessageBox(const pszMsg, pszTitle: string);
begin
  MessageBox(0, PChar(pszTitle), PChar(pszMsg), MB_OK);
end;

procedure CCLuaLog(const pszMsg: PChar);
begin

end;

end.
