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

unit Cocos2dx.CCGeometry;

interface

{$I config.inc}

type
  CCPoint = {$ifdef RecordExt} record {$ELSE} object {$ENDIF}
    x, y: Single;
    procedure create(); overload;
    procedure create(ax, ay: Single); overload;
    procedure create(const other: CCPoint); overload;
    procedure setPoint(ax, ay: Single);
    function equal(const target: CCPoint): Boolean;
  end;
  tCCPoint = array [0..MaxInt div SizeOf(CCPoint) - 1] of CCPoint;
  ptCCPoint = ^tCCPoint;

  CCSize = {$ifdef RecordExt} record {$ELSE} object {$ENDIF}
    width, height: Single;
    procedure create(); overload;
    procedure create(w, h: Single); overload;
    procedure create(const other: CCSize); overload;
    procedure setSize(w, h: Single);
    function equal(const target: CCSize): Boolean;
  end;

  CCRect = {$ifdef RecordExt} record {$ELSE} object {$ENDIF}
    origin: CCPoint;
    size: CCSize;
    procedure create(); overload;
    procedure create(x, y: Single; width, height: Single); overload;
    procedure create(const other: CCRect); overload;
    procedure setRect(x, y: Single; width, height: Single);
    function getMinX(): Single;
    function getMidX(): Single;
    function getMaxX(): Single;
    function getMinY(): Single;
    function getMidY(): Single;
    function getMaxY(): Single;
    function equals(const rect: CCRect): Boolean;
    function containsPoint(const point: CCPoint): Boolean;
    function intersectsRect(const rect: CCRect): Boolean;
  end;

function CCPointMake(x, y: Single): CCPoint; {$ifdef Inline} inline; {$ENDIF}
function CCSizeMake(width, height: Single): CCSize; {$ifdef Inline} inline; {$ENDIF}
function CCRectMake(x, y, width, height: Single): CCRect; {$ifdef Inline} inline; {$ENDIF}

const CCPointZero: CCPoint = (x: 0.0; y: 0.0);
const CCSizeZero: CCSize = (width: 0.0; height: 0.0);
const CCRectZero: CCRect = (origin: (x: 0.0; y: 0.0); size: (width: 0.0; height: 0.0));

implementation

function CCPointMake(x, y: Single): CCPoint;
begin
  Result.Create(x, y);
end;

function CCSizeMake(width, height: Single): CCSize;
begin
  Result.Create(width, height);
end;

function CCRectMake(x, y, width, height: Single): CCRect;
begin
  Result.Create(x, y, width, height);
end;

{ CCPoint }

procedure CCPoint.create(ax, ay: Single);
begin
  setPoint(ax, ay);
end;

procedure CCPoint.create;
begin
  setPoint(0, 0);
end;

procedure CCPoint.create(const other: CCPoint);
begin
  setPoint(other.x, other.y);
end;

function CCPoint.equal(const target: CCPoint): Boolean;
begin
  Result := (x = target.x) and (y = target.y);
end;

procedure CCPoint.setPoint(ax, ay: Single);
begin
  x := ax;
  y := ay;
end;

{ CCSize }

procedure CCSize.create;
begin
  setSize(0, 0);
end;

procedure CCSize.create(w, h: Single);
begin
  setSize(w, h);
end;

procedure CCSize.create(const other: CCSize);
begin
  setSize(other.width, other.height);
end;

function CCSize.equal(const target: CCSize): Boolean;
begin
  Result := (width = target.width) and (height = target.height);
end;

procedure CCSize.setSize(w, h: Single);
begin
  width := w;
  height := h;
end;

{ CCRect }

function CCRect.containsPoint(const point: CCPoint): Boolean;
var
  bRet: Boolean;
begin
  bRet := False;
  if (point.x >= getMinX()) and (point.x <= getMaxX()) and
     (point.y >= getMinY()) and (point.y <= getMaxY()) then
    bRet := True;
  Result := bRet;
end;

procedure CCRect.create;
begin
  setRect(0.0, 0.0, 0.0, 0.0);
end;

procedure CCRect.create(const other: CCRect);
begin
  setRect(other.origin.x, other.origin.y, other.size.width, other.size.height);
end;

procedure CCRect.create(x, y, width, height: Single);
begin
  setRect(x, y, width, height);
end;

function CCRect.equals(const rect: CCRect): Boolean;
begin
  Result := origin.equal(rect.origin) and size.equal(rect.size);
end;

function CCRect.getMaxX: Single;
begin
  Result := origin.x + size.width;
end;

function CCRect.getMaxY: Single;
begin
  Result := origin.y + size.height;
end;

function CCRect.getMidX: Single;
begin
  Result := origin.x + size.width/2.0;
end;

function CCRect.getMidY: Single;
begin
  Result := origin.y + size.height/2.0;
end;

function CCRect.getMinX: Single;
begin
  Result := origin.x;
end;

function CCRect.getMinY: Single;
begin
  Result := origin.y;
end;

function CCRect.intersectsRect(const rect: CCRect): Boolean;
begin
  Result := not ((GetMaxX() < rect.getMinX()) or
                 (rect.GetMaxX() < getMinX()) or
                 (GetMaxY() < rect.getMinY()) or
                 (rect.GetMaxY() < getMinY()));
end;

procedure CCRect.setRect(x, y, width, height: Single);
begin
  origin.x := x;
  origin.y := y;
  size.width := width;
  size.height := height;
end;

end.
