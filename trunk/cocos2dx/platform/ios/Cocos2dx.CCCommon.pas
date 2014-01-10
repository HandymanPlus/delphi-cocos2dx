unit Cocos2dx.CCCommon;

interface

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

implementation
uses
  System.SysUtils,
  Macapi.ObjectiveC,
  iOSapi.Foundation;

procedure CCLog(const sFormat: string; const Args: array of const);
var
  buf: string;
begin
  buf := Format(sFormat, Args);
  NSLog((NSSTR(buf) as ILocalObject).GetObjectID);
end;

procedure CCMessageBox(const pszMsg, pszTitle: string);
begin

end;

end.
