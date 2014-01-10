(*
 * Copyright (c) 2012 cocos2d-x.org
 * http://www.cocos2d-x.org
 *
 *
 * Copyright 2012 Stewart Hamilton-Arrandale.
 * http://creativewax.co.uk
 *
 * Modified by Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * Converted to c++ / cocos2d-x by Angus C
 *)

unit Cocos2dx.CCControlUtils;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCNode, Cocos2dx.CCSprite, Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

type
  RGBA = record
    r, g, b, a: Single;
  end;

  HSV = record
    h, s, v: Single;
  end;

  CCColor3bObject = class(CCObject)
  public
    value: ccColor3B;
    constructor Create(s_value: ccColor3B);
  end;

  CCControlUtils = class
  public
    class function addSpriteToTargetWithPosAndAnchor(const spriteName: string; target: CCNode; pos, anchor: CCPoint): CCSprite;
    class function HSVfromRGB(value: RGBA): HSV;
    class function RGBfromHSV(value: HSV): RGBA;
    class function CCRectUnion(const src1, src2: CCRect): CCRect;
  end;

implementation
uses
  Math;

{ CCColor3bObject }

constructor CCColor3bObject.Create(s_value: ccColor3B);
begin
  inherited Create();
  value := s_value;
end;

{ CCControlUtils }

class function CCControlUtils.addSpriteToTargetWithPosAndAnchor(
  const spriteName: string; target: CCNode; pos,
  anchor: CCPoint): CCSprite;
var
  sprite: CCSprite;
begin
  sprite := CCSprite.createWithSpriteFrameName(spriteName);
  if sprite = nil then
  begin
    Result := nil;
    Exit;
  end;

  sprite.setPosition(pos);
  sprite.AnchorPoint := anchor;
  target.addChild(sprite);

  Result := sprite;
end;

class function CCControlUtils.CCRectUnion(const src1,
  src2: CCRect): CCRect;
var
  ret: CCRect;
  x1, y1, x2, y2: Single;
begin
  x1 := Min(src1.getMinX(), src2.getMinX());
  y1 := Min(src1.getMinY(), src2.getMinY());
  x2 := Max(src1.getMaxX(), src2.getMaxX());
  y2 := Max(src1.getMaxY(), src2.getMaxY());

  ret.origin := CCPointMake(x1, x2);
  ret.size := CCSizeMake(x2 - x1, y2 - y1);
  Result := ret;
end;

class function CCControlUtils.HSVfromRGB(value: RGBA): HSV;
var
  ret: HSV;
  min, max, delta: Single;
begin
  if value.r < value.g then
    min := value.r
  else
    min := value.g;

  if min > value.b then
    min := value.b;

  if value.r > value.g then
    max := value.r
  else
    max := value.g;

  if max < value.b then
    max := value.b;

  ret.v := max;
  delta := max - min;

  if max > 0.0 then
  begin
    ret.s := delta / max;
  end else
  begin
    ret.s := 0.0;
    ret.h := -1;

    Result := ret;
    Exit;
  end;

  if value.r >= max then
  begin
    ret.h := (value.g - value.b) / delta;
  end else
  begin
    if value.g >= max then
      ret.h := 2.0 + (value.b - value.r) / delta
    else
      ret.h := 4.0 + (value.r - value.g) / delta;
  end;

  ret.h := ret.h * 60.0;
  if ret.h < 0.0 then
    ret.h := ret.h + 360.0;

  Result := ret;
end;

class function CCControlUtils.RGBfromHSV(value: HSV): RGBA;
var
  hh, p, q, t, ff: Single;
  i: Cardinal;
  ret: RGBA;
begin
  ret.a := 1;

  if value.s <= 0.0 then
  begin
    if IsNan(value.h) then
    begin
      ret.r := value.v;
      ret.g := value.v;
      ret.b := value.v;

      Result := ret;
      Exit;
    end;

    ret.r := 0.0;
    ret.g := 0.0;
    ret.b := 0.0;

    Result := ret;
    Exit;
  end;

  hh := value.h;
  if hh >= 360.0 then
    hh := 0.0;

  i := Round(hh);
  ff := hh - i;
  p := value.v * (1.0 - value.s);
  q := value.v * (1.0 - (value.s * ff));
  t := value.v * (1.0 - (value.s * (1.0 - ff)));

  case i of
    0:
      begin
        ret.r := value.v;
        ret.g := t;
        ret.b := p;
      end;
    1:
      begin
        ret.r := q;
        ret.g := value.v;
        ret.b := p;
      end;
    2:
      begin
        ret.r := p;
        ret.g := value.v;
        ret.b := t;
      end;
    3:
      begin
        ret.r := p;
        ret.g := q;
        ret.b := value.v;
      end;
    4:
      begin
        ret.r := t;
        ret.g := p;
        ret.b := value.v;
      end;
  else
      begin
        ret.r := value.v;
        ret.g := p;
        ret.b := q;
      end;
  end;

  Result := ret;
end;

end.
