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
unit Cocos2dx.CCNS;

interface
uses
  Classes, StrUtils, SysUtils, Cocos2dx.CCGeometry;

(**
 * @addtogroup data_structures
 * @{
 *)

(**
@brief Returns a Core Graphics rectangle structure corresponding to the data in a given string.
@param pszContent   A string object whose contents are of the form "{{x,y},{w, h}}",
                    where x is the x coordinate, y is the y coordinate, w is the width, and h is the height.
                    These components can represent integer or float values.
                    An example of a valid string is "{{3,2},{4,5}}".
                    The string is not localized, so items are always separated with a comma.
@return A Core Graphics structure that represents a rectangle.
        If the string is not well-formed, the function returns CCRectZero.
*)
function CCRectFromString(const pszContent: string): CCRect;

(**
@brief Returns a Core Graphics point structure corresponding to the data in a given string.
@param pszContent   A string object whose contents are of the form "{x,y}",
                    where x is the x coordinate and y is the y coordinate.
                    The x and y values can represent integer or float values.
                    An example of a valid string is "{3.0,2.5}".
                    The string is not localized, so items are always separated with a comma.
@return A Core Graphics structure that represents a point.
        If the string is not well-formed, the function returns CCPointZero.
*)
function CCPointFromString(const pszContent: string): CCPoint;

(**
@brief Returns a Core Graphics size structure corresponding to the data in a given string.
@param pszContent   A string object whose contents are of the form "{w, h}",
                    where w is the width and h is the height.
                    The w and h values can be integer or float values.
                    An example of a valid string is "{3.0,2.5}".
                    The string is not localized, so items are always separated with a comma.
@return A Core Graphics structure that represents a size.
        If the string is not well-formed, the function returns CCSizeZero.
*)
function CCSizeFromString(const pszContent: string): CCSize;

implementation
uses
  Cocos2dx.CCStrUtils;

// string toolkit
procedure split(src: string; const token: string; vect: TStringList);
var
  nend, nbegin: Integer;
  sData: string;
begin
  nend := 1; nbegin := 1;

  while nend <> 0 do
  begin
    nend := PosEx(token, src, nbegin);
    if nend = 0 then
      sData := Copy(src, nbegin, Length(src) - nbegin + 1)
    else
      sData := Copy(src, nbegin, nend - nbegin);
    vect.Add(sData);
    nbegin := nend + Length(token);
  end;  
end;

// first, judge whether the form of the string like this: {x,y}
// if the form is right,the string will be split into the parameter strs;
// or the parameter strs will be empty.
// if the form is right return true,else return false.
function splitWithForm(const pStr: string; strs: TStringList): Boolean;
var
  bRet: Boolean;
  content, pointStr: string;
  nPosLeft, nPosRight: Integer;
  nPos1, nPos2: Integer;
begin
  bRet := False;

  repeat
    content := pStr;
    if Length(content) = 0 then
      Break;

    nPosLeft := Pos('{', content);
    nPosRight := Pos('}', content);
    if (nPosLeft = 0) or (nPosRight = 0) then
      Break;

    if nPosLeft > nPosRight then
      Break;

    pointStr := Copy(content, nPosLeft+1, nPosRight-nPosLeft-1);
    if Length(pointStr) = 0 then
      Break;

    nPos1 := Pos('{', pointStr);
    nPos2 := Pos('}', pointStr);
    if (nPos1 <> 0) or (nPos2 <> 0) then
      Break;

    split(pointStr, ',', strs);

    bRet := True;
  until True;

  Result := bRet;
end;  

function CCRectFromString(const pszContent: string): CCRect;
var
  ret: CCRect;
  content, pointStr, sizeStr: string;
  nPosLeft, nPosRight: Integer;
  nPointEnd: Integer;
  //i: Integer;
  x, y, width, height: Single;
  sizeInfo, pointInfo: TStringList;
begin
  ret := CCRectZero;

  repeat

    content := pszContent;
    nPosLeft := Pos('{', content);
    nPosRight := find_last_of('}', content);

    if (nPosLeft = 0) or (nPosRight = 0) then
      Break;

    content := Copy(content, nPosLeft+1, nPosRight-nPosLeft-1);

    nPointEnd := Pos('}', content);
    if nPointEnd = 0 then
      Break;

    nPointEnd := PosEx(',', content, nPointEnd);
    if nPointEnd = 0 then
      Break;

    pointStr := Copy(content, 1, nPointEnd-1);
    sizeStr := Copy(content, nPointEnd+1, Length(content)-nPointEnd);

    pointInfo := TStringList.Create;
    if not splitWithForm(pointStr, pointInfo) then
    begin
      pointInfo.Free;
      Break;
    end;

    sizeInfo := TStringList.Create;
    if not splitWithForm(sizeStr, sizeInfo) then
    begin
      pointInfo.Free;
      sizeInfo.Free;
      Break;
    end;

    x := StrToFloat(pointInfo[0]);
    y := StrToFloat(pointInfo[1]);
    width := StrToFloat(sizeInfo[0]);
    height := StrToFloat(sizeInfo[1]);

    ret := CCRectMake(x, y, width, height);

    pointInfo.Free;
    sizeInfo.Free;

  until True;

  Result := ret;
end;

function CCPointFromString(const pszContent: string): CCPoint;
var
  ret: CCPoint;
  strs: TStringList;
  x, y: Single;
begin
  ret := CCPointZero;

  repeat

    strs := TStringList.Create;

    if not splitWithForm(pszContent, strs) then
    begin
      strs.Free;
      Break;
    end;

    x := StrToFloat(strs[0]);
    y := StrToFloat(strs[1]);

    ret := CCPointMake(x, y);

    strs.Free;

  until True;

  Result := ret;
end;

function CCSizeFromString(const pszContent: string): CCSize;
var
  ret: CCSize;
  strs: TStringList;
  width, height: Single;
begin
  ret := CCSizeZero;

  repeat

    strs := TStringList.Create;

    if not splitWithForm(pszContent, strs) then
    begin
      strs.Free;
      Break;
    end;

    width := StrToFloat(strs[0]);
    height := StrToFloat(strs[1]);

    ret := CCSizeMake(width, height);

    strs.Free;

  until True;

  Result := ret;
end;  

end.
