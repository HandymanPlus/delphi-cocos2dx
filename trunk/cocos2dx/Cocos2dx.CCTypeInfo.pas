unit Cocos2dx.CCTypeInfo;

interface
uses
  SysUtils;

type
  TypeInfo = interface
    function getClassTypeInfo(): Cardinal;
  end;

function getHashCodeByString(const key: string): Cardinal;

implementation

function getHashCodeByString(const key: string): Cardinal;
var
  len: Cardinal;
  hash, i: Cardinal;
  uKey: string;
begin
  uKey := UpperCase(key);
  len := Length(uKey);
  hash := 0;
  for i := 1 to len do
  begin
    hash := hash * 16777619;
    hash := hash xor Byte(uKey[i]);
  end;
  Result := hash;
end;

end.
