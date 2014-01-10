(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2007      Scott Lembcke

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

(**
 @file
 based on Chipmunk cpArray.
 ccArray is a faster alternative to NSMutableArray, it does pretty much the
 same thing (stores NSObjects and retains/releases them appropriately). It's
 faster because:
 - it uses a plain C interface so it doesn't incur Objective-c messaging overhead
 - it assumes you know what you're doing, so it doesn't spend time on safety checks
 (index out of bounds, required capacity etc.)
 - comparisons are done using pointer equality instead of isEqual

 There are 2 kind of functions:
 - ccArray functions that manipulates objective-c objects (retain and release are performed)
 - ccCArray functions that manipulates values like if they were standard C structures (no retain/release is performed)
 *)

unit Cocos2dx.cCCArray;

interface
uses
  SysUtils, Cocos2dx.CCObject;

const CC_INVALID_INDEX = $ffffffff;

type
  TCCObectAry = array [0..0] of CCObject;
  PCCObectAry = ^TCCObectAry;
  _ccArray = record
    num: Cardinal;
    max: Cardinal;
    arr: PCCObectAry;
  end;
  p_ccArray = ^_ccArray;

  TCompare = function (const p1, p2: CCObject): Integer;

function ccArrayNew(capacity: Cardinal): p_ccArray;
procedure ccArrayFree(var arr: p_ccArray);
procedure ccArrayDoubleCapacity(arr: p_ccArray);
procedure ccArrayEnsureExtraCapacity(arr: p_ccArray; extra: Cardinal);
procedure ccArrayShrink(arr: p_ccArray);
function ccArrayGetIndexOfObject(arr: p_ccArray; pObject: CCObject): Cardinal;
function ccArrayContainsObject(arr: p_ccArray; pObject: CCObject): Boolean;
procedure ccArrayAppendObject(arr: p_ccArray; pObject: CCObject);
procedure ccArrayAppendObjectWithResize(arr: p_ccArray; pObject: CCObject);
procedure ccArrayAppendArray(arr: p_ccArray; plusArr: p_ccArray);
procedure ccArrayAppendArrayWithResize(arr: p_ccArray; plusArr: p_ccArray);
procedure ccArrayInsertObjectAtIndex(arr: p_ccArray; pObject: CCObject; nindex: Cardinal);
procedure ccArraySwapObjectsAtIndexes(arr: p_ccArray; index1: Cardinal; index2: Cardinal);
procedure ccArrayRemoveAllObjects(arr: p_ccArray);
procedure ccArrayRemoveObjectAtIndex(arr: p_ccArray; nindex: Cardinal; bReleaseObj: Boolean = True);
procedure ccArrayFastRemoveObjectAtIndex(arr: p_ccArray; nindex: Cardinal);
procedure ccArrayFastRemoveObject(arr: p_ccArray; pObject: CCObject);
procedure ccArrayRemoveObject(arr: p_ccArray; pObject: CCObject; bReleaseObj: Boolean = True);
procedure ccArrayRemoveArray(arr: p_ccArray; minusArr: p_ccArray);
procedure ccArrayFullRemoveArray(arr: p_ccArray; minusArr: p_ccArray);
procedure ccArraySort(arr: p_ccArray; compare: TCompare);

type
  TPointerAry = array [0..0] of Pointer;
  PPointerAry = ^TPointerAry;
  _ccCArray = record
    num: Cardinal;
    max: Cardinal;
    arr: PPointerAry;
  end;
  p_ccCArray = ^_ccCArray;

function ccCArrayNew(capacity: Cardinal): p_ccCArray;
procedure ccCArrayFree(arr: p_ccCArray);
procedure ccCArrayDoubleCapacity(arr: p_ccCArray);
procedure ccCArrayEnsureExtraCapacity(arr: p_ccCArray; extra: Cardinal);
function ccCArrayGetIndexOfValue(arr: p_ccCArray; value: Pointer): Cardinal;
function ccCArrayContainsValue(arr: p_ccCArray; value: Pointer): Boolean;
procedure ccCArrayInsertValueAtIndex(arr: p_ccCArray; value: Pointer; nindex: Cardinal);
procedure ccCArrayAppendValue(arr: p_ccCArray; value: Pointer);
procedure ccCArrayAppendValueWithResize(arr: p_ccCArray; value: Pointer);
procedure ccCArrayAppendArray(arr: p_ccCArray; plusArr: p_ccCArray);
procedure ccCArrayAppendArrayWithResize(arr: p_ccCArray; plusArr: p_ccCArray);
procedure ccCArrayRemoveAllValues(arr: p_ccCArray);
procedure ccCArrayRemoveValueAtIndex(arr: p_ccCArray; nindex: Cardinal);
procedure ccCArrayFastRemoveValueAtIndex(arr: p_ccCArray; nindex: Cardinal);
procedure ccCArrayRemoveValue(arr: p_ccCArray; value: Pointer);
procedure ccCArrayRemoveArray(arr: p_ccCArray; minusArr: p_ccCArray);
procedure ccCArrayFullRemoveArray(arr: p_ccCArray; minusArr: p_ccCArray);

implementation
uses
  Cocos2dx.CCPlatformMacros;

function ccArrayNew(capacity: Cardinal): p_ccArray;
var
  arr: p_ccArray;
begin
  if capacity = 0 then
    capacity := 1;

  arr := AllocMem(SizeOf(_ccArray));
  arr^.num := 0;
  arr^.arr := AllocMem(capacity*SizeOf(CCObject));
  arr^.max := capacity;

  Result := arr;
end;

procedure ccArrayFree(var arr: p_ccArray);
begin
  if arr = nil then
    Exit;

  ccArrayRemoveAllObjects(arr);
  FreeMem(arr^.arr);
  FreeMem(arr);

  arr := nil;
end;

procedure ccArrayDoubleCapacity(arr: p_ccArray);
begin
  arr^.max := arr^.max*2;
  ReallocMem(arr^.arr, arr^.max*SizeOf(CCObject));
end;

procedure ccArrayEnsureExtraCapacity(arr: p_ccArray; extra: Cardinal);
begin
  while arr^.max < arr^.num + extra do
  begin
    ccArrayDoubleCapacity(arr);
  end;  
end;

procedure ccArrayShrink(arr: p_ccArray);
var
  newsize: Cardinal;
begin
  if (arr^.max > arr^.num) and not((arr^.num = 0) and (arr^.max = 1)) then
  begin
    if arr^.num <> 0 then
    begin
      newsize := arr^.num;
      arr^.max := arr^.num;
    end else
    begin
      newsize := 1;
      arr^.max := 1;
    end;

    ReallocMem(arr^.arr, newsize*SizeOf(CCObject));
  end;
end;

function ccArrayGetIndexOfObject(arr: p_ccArray; pObject: CCObject): Cardinal;
var
  i: Integer;
begin
  for i := 0 to arr^.num-1 do
  begin
    if arr^.arr[i] = pObject then
    begin
      Result := i;
      Exit;
    end;
  end;
  
  Result := CC_INVALID_INDEX;
end;

function ccArrayContainsObject(arr: p_ccArray; pObject: CCObject): Boolean;
begin
  Result := ccArrayGetIndexOfObject(arr, pObject) <> CC_INVALID_INDEX;
end;

procedure ccArrayAppendObject(arr: p_ccArray; pObject: CCObject);
begin
  CCAssert(pObject <> nil, 'Invalid parameter!');
  pObject.retain();
  arr^.arr[arr^.num] := pObject;
  Inc(arr^.num);
end;

procedure ccArrayAppendObjectWithResize(arr: p_ccArray; pObject: CCObject);
begin
	ccArrayEnsureExtraCapacity(arr, 1);
	ccArrayAppendObject(arr, pObject);
end;

procedure ccArrayAppendArray(arr: p_ccArray; plusArr: p_ccArray);
var
  i: Integer;
begin
  for i := 0 to plusArr^.num-1 do
  begin
    ccArrayAppendObject(arr, plusArr^.arr[i]);
  end;  
end;

procedure ccArrayAppendArrayWithResize(arr: p_ccArray; plusArr: p_ccArray);
begin
	ccArrayEnsureExtraCapacity(arr, plusArr^.num);
	ccArrayAppendArray(arr, plusArr);
end;

procedure ccArrayInsertObjectAtIndex(arr: p_ccArray; pObject: CCObject; nindex: Cardinal);
var
  remaining: Cardinal;
begin
  CCAssert(nindex <= arr^.num, 'Invalid index. Out of bounds');
	CCAssert(pObject <> nil, 'Invalid parameter!');
  
  ccArrayEnsureExtraCapacity(arr, 1);
  
  remaining := arr^.num - nindex;
  if remaining > 0 then
  begin   
    Move(arr^.arr[nindex], arr^.arr[nindex+1], SizeOf(CCObject)*remaining);
  end;
  
  pObject.retain();
  arr^.arr[nindex] := pObject;
  Inc(arr^.num);
end;

procedure ccArraySwapObjectsAtIndexes(arr: p_ccArray; index1: Cardinal; index2: Cardinal);
var
  object1: CCObject;
begin
  object1 := arr^.arr[index1];
  arr^.arr[index1] := arr^.arr[index2];
  arr^.arr[index2] := object1;
end;

procedure ccArrayRemoveAllObjects(arr: p_ccArray);
begin
  while arr^.num > 0 do
  begin
    Dec(arr^.num);
    arr^.arr[arr^.num].release();
  end;  
end;

procedure ccArrayRemoveObjectAtIndex(arr: p_ccArray; nindex: Cardinal; bReleaseObj: Boolean = True);
var
  remaining: Cardinal;
begin
  CCAssert((arr <> nil) and (arr^.num > 0) and (nindex < arr^.num), 'Invalid index. Out of bounds');

  if bReleaseObj then
  begin
    CC_SAFE_RELEASE(arr^.arr[nindex]);
  end;
  Dec(arr^.num);

  remaining := arr^.num - nindex;
  if remaining > 0 then
  begin
    Move(arr^.arr[nindex+1], arr^.arr[nindex], remaining*SizeOf(CCObject));
  end;  
end;

procedure ccArrayFastRemoveObjectAtIndex(arr: p_ccArray; nindex: Cardinal);
begin
  CC_SAFE_RELEASE(arr^.arr[nindex]);
  Dec(arr^.num);
  arr^.arr[nindex] := arr^.arr[arr^.num];
end;

procedure ccArrayFastRemoveObject(arr: p_ccArray; pObject: CCObject);
var
  n: Cardinal;
begin
  n := ccArrayGetIndexOfObject(arr, pObject);
  if n <> CC_INVALID_INDEX then
  begin
    ccArrayFastRemoveObjectAtIndex(arr, n);
  end;  
end;

procedure ccArrayRemoveObject(arr: p_ccArray; pObject: CCObject; bReleaseObj: Boolean = True);
var
  n: Cardinal;
begin
  n := ccArrayGetIndexOfObject(arr, pObject);
  if n <> CC_INVALID_INDEX then
  begin
    ccArrayRemoveObjectAtIndex(arr, n, bReleaseObj);
  end;
end;

procedure ccArrayRemoveArray(arr: p_ccArray; minusArr: p_ccArray);
var
  i: Integer;
begin
  for i := 0 to minusArr^.num-1 do
  begin
    ccArrayRemoveObject(arr, minusArr^.arr[i]);
  end;  
end;

procedure ccArrayFullRemoveArray(arr: p_ccArray; minusArr: p_ccArray);
var
  i, back: Cardinal;
begin
  back := 0;
  for i := 0 to arr^.num-1 do
  begin
    if ccArrayContainsObject(minusArr, arr^.arr[i]) then
    begin
      CC_SAFE_RELEASE(arr^.arr[i]);
      Inc(back);
    end else
    begin
      arr^.arr[i-back] := arr^.arr[i];
    end;
  end;
  arr^.num := arr^.num - back;
end;

//Tlist sort
procedure ccArraySort(arr: p_ccArray; compare: TCompare);

  procedure QuickSort(SortList: PCCObectAry; L, R: Integer);
  var
    I, J: Integer;
    P, T: CCObject;
  begin
    repeat
      I := L;
      J := R;
      P := SortList^[(L + R) shr 1];
      repeat
        while compare(SortList^[I], P) < 0 do
          Inc(I);
        while compare(SortList^[J], P) > 0 do
          Dec(J);
        if I <= J then
        begin
          T := SortList^[I];
          SortList^[I] := SortList^[J];
          SortList^[J] := T;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        QuickSort(SortList, L, J);
      L := I;
    until I >= R;
  end;  

begin
  if arr^.num < 2 then
    Exit;

  QuickSort(arr^.arr, 0, arr^.num-1);
end;  

//
function ccCArrayNew(capacity: Cardinal): p_ccCArray;
var
  arr: p_ccCArray;
begin
  if capacity = 0 then
    capacity := 1;

  arr := AllocMem(SizeOf(_ccCArray));
  arr^.num := 0;
  arr^.arr := AllocMem(capacity * SizeOf(Pointer));
  arr^.max := capacity;

  Result := arr;
end;

procedure ccCArrayFree(arr: p_ccCArray);
begin
  if arr = nil then
    Exit;

  ccCArrayRemoveAllValues(arr);
  FreeMem(arr^.arr);
  FreeMem(arr);
end;

procedure ccCArrayDoubleCapacity(arr: p_ccCArray);
begin
  ccArrayDoubleCapacity(p_ccArray(arr));
end;

procedure ccCArrayEnsureExtraCapacity(arr: p_ccCArray; extra: Cardinal);
begin
  ccArrayEnsureExtraCapacity(p_ccArray(arr), extra);
end;

function ccCArrayGetIndexOfValue(arr: p_ccCArray; value: Pointer): Cardinal;
var
  i: Cardinal;
begin
  for i := 0 to arr^.num-1 do
  begin
    if arr^.arr[i] = value then
    begin
      Result := i;
      Exit;
    end;  
  end;
  Result := CC_INVALID_INDEX;
end;

function ccCArrayContainsValue(arr: p_ccCArray; value: Pointer): Boolean;
begin
  Result := ccCArrayGetIndexOfValue(arr, value) <> CC_INVALID_INDEX;
end;

procedure ccCArrayInsertValueAtIndex(arr: p_ccCArray; value: Pointer; nindex: Cardinal);
var
  remaining: Cardinal;
begin
  remaining := arr^.num - nindex;
  if arr^.num + 1 = arr^.max then
  begin
    ccCArrayDoubleCapacity(arr);
  end;
  if remaining > 0 then
    Move(arr^.arr[nindex], arr^.arr[nindex+1], SizeOf(Pointer)*remaining);

  Inc(arr^.num);
  arr^.arr[nindex] := value;
end;

procedure ccCArrayAppendValue(arr: p_ccCArray; value: Pointer);
begin
  arr^.arr[arr^.num] := value;
  Inc(arr^.num);

  if arr^.num >= arr^.max then
  begin
    ccCArrayDoubleCapacity(arr);
  end;  
end;

procedure ccCArrayAppendValueWithResize(arr: p_ccCArray; value: Pointer);
begin
	ccCArrayEnsureExtraCapacity(arr, 1);
	ccCArrayAppendValue(arr, value);
end;

procedure ccCArrayAppendArray(arr: p_ccCArray; plusArr: p_ccCArray);
var
  i: Cardinal;
begin
  for i := 0 to plusArr^.num-1 do
    ccCArrayAppendValue(arr, plusArr^.arr[i]);
end;

procedure ccCArrayAppendArrayWithResize(arr: p_ccCArray; plusArr: p_ccCArray);
begin
	ccCArrayEnsureExtraCapacity(arr, plusArr^.num);
	ccCArrayAppendArray(arr, plusArr);
end;

procedure ccCArrayRemoveAllValues(arr: p_ccCArray);
begin
  arr^.num := 0;
end;

procedure ccCArrayRemoveValueAtIndex(arr: p_ccCArray; nindex: Cardinal);
var
  last: Cardinal;
begin
  Dec(arr^.num);
  last := arr^.num;

  while nindex < last do
  begin
    arr^.arr[nindex] := arr^.arr[nindex+1];
    Inc(nindex);
  end;
end;

procedure ccCArrayFastRemoveValueAtIndex(arr: p_ccCArray; nindex: Cardinal);
begin
  Dec(arr^.num);
  arr^.arr[nindex] := arr^.arr[arr^.num];
end;

procedure ccCArrayRemoveValue(arr: p_ccCArray; value: Pointer);
var
  i: Cardinal;
begin
  i := ccCArrayGetIndexOfValue(arr, value);
  if i <> CC_INVALID_INDEX then
    ccCArrayRemoveValueAtIndex(arr, i);
end;

procedure ccCArrayRemoveArray(arr: p_ccCArray; minusArr: p_ccCArray);
var
  i: Cardinal;
begin
  for i := 0 to minusArr^.num-1 do
    ccCArrayRemoveValue(arr, minusArr^.arr[i]);
end;

procedure ccCArrayFullRemoveArray(arr: p_ccCArray; minusArr: p_ccCArray);
var
  i, back: Cardinal;
begin
  back := 0;
  for i := 0 to arr^.num-1 do
  begin
    if ccCArrayContainsValue(minusArr, arr^.arr[i]) then
      Inc(back)
    else
      arr^.arr[i-back] := arr^.arr[i];
  end;
  arr^.num := arr^.num - back;
end;

end.
