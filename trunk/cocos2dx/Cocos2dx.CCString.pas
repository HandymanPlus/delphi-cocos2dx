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

unit Cocos2dx.CCString;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils,
  Cocos2dx.CCObject;

type
  CCString = class(CCObject)
  public
    m_sString: string;
  public
    constructor Create(); overload;
    constructor Create(const str: string); overload;
    constructor Create(const str: CCString); overload;
    destructor Destroy(); override;

    function initWithFormat(const strFormat: string; const Args: array of const): Boolean;
    function intValue(): Integer;
    function uintValue(): Cardinal;
    function floatValue(): Single;
    function doubleValue(): Double;
    function boolValue(): Boolean;
    function getCString(): PGLchar;
    function Size(): Cardinal;
    function compare(const c: string): Integer;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function isEqual(pObject: CCObject): Boolean; override;
    class function _create(const str: string): CCString;
    class function createWithFormat(const strFormat: string; const Args: array of const): CCString;
    class function createWithData(const pData: PByte; nLen: Cardinal): CCString;
    class function createWithContentsOfFile(const pszFilename: string): CCString;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCFileUtils;

{ CCString }

class function CCString._create(const str: string): CCString;
var
  pRet: CCString;
begin
  pRet := CCString.Create(str);
  pRet.autorelease();
  Result := pRet;
end;

function CCString.boolValue: Boolean;
begin
  if m_sString = '' then
  begin
    Result := False;
    Exit;
  end;  
  Result := StrToBool(m_sString);
end;

function CCString.compare(const c: string): Integer;
begin
  Result := CompareText(m_sString, c);
end;

function CCString.copyWithZone(pZone: CCZone): CCObject;
var
  pStr: CCString;
begin
  CCAssert(pZone = nil, 'CCString should not be inherited.');
  pStr := CCString.Create(m_sString);
  Result := pStr;
end;

constructor CCString.Create;
begin
  inherited Create();
  m_sString := '';
end;

constructor CCString.Create(const str: CCString);
begin
  inherited Create();
  m_sString := str.m_sString;
end;

constructor CCString.Create(const str: string);
begin
  inherited Create();
  m_sString := str;
end;

class function CCString.createWithContentsOfFile(
  const pszFilename: string): CCString;
var
  size: Cardinal;
  pData: PByte;
  pRet: CCString;
begin
  pData := CCFileUtils.sharedFileUtils().getFileData(pszFilename, 0, @size);
  pRet := CCString.createWithData(pData, size);
  FreeMem(pData);
  Result := pRet;
end;

class function CCString.createWithData(const pData: PByte;
  nLen: Cardinal): CCString;
var
  pRet: CCString;
  pStr: PChar;
  s: string;
begin
  pRet := nil;

  if pData <> nil then
  begin
    pStr := AllocMem(nLen+1);
    if pStr <> nil then
    begin
      pStr[nLen] := #0;
      if nLen > 0 then
        Move(pData^, pStr^, nLen);
    end;
    s := StrPas(pStr);
    pRet := CCString._create(s);
    FreeMem(pStr);
  end;
  Result := pRet;
end;

class function CCString.createWithFormat(const strFormat: string;
  const Args: array of const): CCString;
var
  pRet: CCString;
begin
  pRet := CCString.Create();
  pRet.initWithFormat(strFormat, Args);
  pRet.autorelease();
  Result := pRet;
end;

destructor CCString.Destroy;
begin

  inherited;
end;

function CCString.doubleValue: Double;
begin
  if Size() > 0 then
    Result := StrToFloatDef(m_sString, 0)
  else
    Result := 0;
end;

function CCString.floatValue: Single;
begin
  if Size() > 0 then
    Result := StrToFloatDef(m_sString, 0)
  else
    Result := 0;
end;

function CCString.getCString:PGLchar;
begin
  {$ifdef IOS}
  Result := MarshaledAString(TMarshal.AsAnsi(m_sString))
  {$else}
  Result := PGLchar(AnsiString(m_sString));
  {$endif}
end;

function CCString.initWithFormat(const strFormat: string;
  const Args: array of const): Boolean;
begin
  m_sString := Format(strFormat, Args);
  Result := True;
end;

function CCString.intValue: Integer;
begin
  if Size() > 0 then
    Result := StrToIntDef(m_sString, 0)
  else
    Result := 0;
end;

function CCString.isEqual(pObject: CCObject): Boolean;
var
  pOther: CCString;
begin
  pOther := CCString(pObject);
  Result := CompareText(m_sString, pOther.m_sString) = 0;
end;

function CCString.Size: Cardinal;
begin
  Result := Length(m_sString);
end;

function CCString.uintValue: Cardinal;
begin
  if Size() > 0 then
    Result := StrToIntDef(m_sString, 0)
  else
    Result := 0;
end;

end.
