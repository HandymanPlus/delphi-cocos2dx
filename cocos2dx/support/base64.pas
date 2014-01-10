unit base64;

interface

{$I config.inc}

{$ifdef IOS}
function base64Decode(input: string; inLength: Cardinal; var output: PByte): Integer;
{$else}
function base64Decode(input: PChar; inLength: Cardinal; var output: PByte): Integer;
{$endif}

implementation
{$ifdef IOS} uses System.SysUtils; {$endif}

const  tabSize = 64;

{$ifdef IOS}

var
  alphabet: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function _base64Decode(input: string; input_len: Cardinal; var output: PByte; var output_len: Cardinal): Integer;
var
  inalphabet, decoder: array [0..255] of Byte;
  i, bits, c, char_count, errors: Integer;
  input_idx, output_idx: Cardinal;
  strBuilder1, strBuilder2: TStringBuilder;
begin
  strBuilder1 := TStringBuilder.Create;
  strBuilder1.Append(alphabet);
  strBuilder2 := TStringBuilder.Create;
  strBuilder2.Append(input);

  for i := tabSize-1 downto 0 do
  begin
    inalphabet[Byte(strBuilder1.Chars[i])] := 1;
    decoder[Byte(strBuilder1.Chars[i])] := i;
  end;

  c := 0;
  errors := 0;
  char_count := 0;
  bits := 0;
  output_idx := 0;
  for input_idx := 0 to input_len-1 do
  begin
    c := Integer(strBuilder2.Chars[input_idx]);
    if c = Integer('=') then
      Break;
    if (c > 255) or (Byte(strBuilder1.Chars[c]) = 0) then
      Continue;
    bits := bits + decoder[c];
    Inc(char_count);
    if char_count = 4 then
    begin
      PByte(Cardinal(output) + output_idx + 0)^ :=  bits shr 16;
      PByte(Cardinal(output) + output_idx + 1)^ := (bits shr 8) and $FF;
      PByte(Cardinal(output) + output_idx + 2)^ :=  bits and $FF;
      Inc(output_idx, 3);
      bits := 0;
      char_count := 0;
    end else
    begin
      bits := bits shl 6;
    end;
  end;

  if c = Byte('=') then
  begin
    case char_count of
      1:
        begin
          Inc(errors);
        end;
      2:
        begin
          PByte(Cardinal(output) + output_idx + 0)^ := bits shr 10;
          Inc(output_idx);
        end;
      3:
        begin
          PByte(Cardinal(output) + output_idx + 0)^ :=  bits shr 16;
          PByte(Cardinal(output) + output_idx + 1)^ := (bits shr 8) and $FF;
          Inc(output_idx, 2);
        end;
    end;
  end else if input_idx < input_len then
  begin
    if char_count > 0 then
      Inc(errors);
  end;

  strBuilder1.Free;
  strBuilder2.Free;

  output_len := output_idx;
  Result := errors;
end;

function base64Decode(input: string; inLength: Cardinal; var output: PByte): Integer;
var
  outLength: Cardinal;
  ret: Integer;
begin
  outLength := 0;
  output := GetMemory(Round(inLength * 3 / 4 + 1));
  if output <> nil then
  begin
    ret := _base64Decode(input, inLength, output, outLength);
    if ret > 0 then
    begin
      FreeMem(output);
      output := nil;
      outLength := 0;
    end;
  end;
  Result := outLength;
end;

{$else}

var
  alphabet: array [0..tabSize-1] of AnsiChar = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/');

function _base64Decode(input: PChar; input_len: Cardinal; var output: PByte; var output_len: Cardinal): Integer;
var
  inalphabet, decoder: array [0..255] of Byte;
  i, bits, c, char_count, errors: Integer;
  input_idx, output_idx: Cardinal;
begin
  for i := tabSize-1 downto 0 do
  begin
    inalphabet[Byte(alphabet[i])] := 1;
    decoder[Byte(alphabet[i])] := i;
  end;

  c := 0;
  errors := 0;
  char_count := 0;
  bits := 0;
  output_idx := 0;
  for input_idx := 0 to input_len-1 do
  begin
    c := Integer(input[input_idx]);
    if c = Integer('=') then
      Break;
    if (c > 255) or (inalphabet[c] = 0) then
      Continue;
    bits := bits + decoder[c];
    Inc(char_count);
    if char_count = 4 then
    begin
      PByte(Cardinal(output) + output_idx + 0)^ :=  bits shr 16;
      PByte(Cardinal(output) + output_idx + 1)^ := (bits shr 8) and $FF;
      PByte(Cardinal(output) + output_idx + 2)^ :=  bits and $FF;
      Inc(output_idx, 3);
      bits := 0;
      char_count := 0;
    end else
    begin
      bits := bits shl 6;
    end;
  end;

  if c = Byte('=') then
  begin
    case char_count of
      1:
        begin
          Inc(errors);
        end;
      2:
        begin
          PByte(Cardinal(output) + output_idx + 0)^ := bits shr 10;
          Inc(output_idx);
        end;
      3:
        begin
          PByte(Cardinal(output) + output_idx + 0)^ :=  bits shr 16;
          PByte(Cardinal(output) + output_idx + 1)^ := (bits shr 8) and $FF;
          Inc(output_idx, 2);
        end;
    end;
  end else if input_idx < input_len then
  begin
    if char_count > 0 then
      Inc(errors);
  end;

  output_len := output_idx;
  Result := errors;
end;

function base64Decode(input: PChar; inLength: Cardinal; var output: PByte): Integer;
var
  outLength: Cardinal;
  ret: Integer;
begin
  outLength := 0;
  output := GetMemory(Round(inLength * 3 / 4 + 1));
  if output <> nil then
  begin
    ret := _base64Decode(input, inLength, output, outLength);
    if ret > 0 then
    begin
      FreeMem(output);
      output := nil;
      outLength := 0;
    end;
  end;
  Result := outLength;
end;

{$endif}

end.
