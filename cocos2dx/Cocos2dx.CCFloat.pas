(****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org

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

unit Cocos2dx.CCFloat;

interface
uses
  Cocos2dx.CCObject;

type
  CCFloat = class(CCObject)
  private
    m_fValue: Single;
  public
    constructor Create(v: Single);
    destructor Destroy(); override;
    function getValue(): Single;
    class function _create(v: Single): CCFloat;
  end;

implementation

{ CCFloat }

class function CCFloat._create(v: Single): CCFloat;
var
  pRet: CCFloat;
begin
  pRet := CCFloat.Create(v);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCFloat.Create(v: Single);
begin
  inherited Create();
  m_fValue := v;
end;

destructor CCFloat.Destroy;
begin

  inherited;
end;

function CCFloat.getValue: Single;
begin
  Result := m_fValue;
end;

end.
