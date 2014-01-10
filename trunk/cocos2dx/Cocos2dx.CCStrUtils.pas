unit Cocos2dx.CCStrUtils;

interface
uses
  StrUtils;

function find_last_of(const subStr: string; const str: string): Integer;
function eraseAtPosition(const startPos: Integer; const str: string): string;
function stringSubstr(const startPos, nLen: Cardinal; const str: string): string; overload;
function stringSubstr(const startPos: Cardinal; const str: string): string; overload;
function stringRfind(const subStr: string; const str: string): Integer;

implementation

function find_last_of(const subStr: string; const str: string): Integer;
var
  nRet, nStart: Integer;
begin
  nStart := 1;
  nRet := PosEx(subStr, str, nStart);
  while nRet <> 0 do
  begin
    nStart := nRet + 1;
    nRet := PosEx(subStr, str, nStart);
    if nRet = 0 then
    begin
      nRet := nStart - 1;
      Break;
    end;
  end;

  Result := nRet;
end;

function eraseAtPosition(const startPos: Integer; const str: string): string;
begin
  Result := Copy(str, 1, startPos-1);
end;

function stringSubstr(const startPos, nLen: Cardinal; const str: string): string; overload;
begin
  //Result := str;
  Result := Copy(str, startPos, nLen);
end;

function stringSubstr(const startPos: Cardinal; const str: string): string; overload;
var
  nLen: Cardinal;
begin
  nLen := Cardinal(Length(str)) - startPos + 1;
  Result := Copy(str, startPos, nLen);
end;

function stringRfind(const subStr: string; const str: string): Integer;
var
  nRet, nStart: Integer;
begin
  nStart := 1;
  nRet := PosEx(subStr, str, nStart);
  while nRet <> 0 do
  begin
    nStart := nRet + 1;
    nRet := PosEx(subStr, str, nStart);
    if nRet = 0 then
    begin
      nRet := nStart - 1;
      Break;
    end;
  end;

  Result := nRet;
end;  
  
end.
