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

unit Cocos2dx.CCInteger;

interface
uses
  Cocos2dx.CCObject;

type
  CCInteger = class(CCObject)
  private
    m_nValue: Integer;
  public
    constructor Create(v: Integer);
    destructor Destroy(); override;
    function getValue(): Integer;
    class function _create(v: Integer): CCInteger;
  end;

implementation

{ CCInteger }

class function CCInteger._create(v: Integer): CCInteger;
var
  pRet: CCInteger;
begin
  pRet := CCInteger.Create(v);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCInteger.Create(v: Integer);
begin
  inherited Create();
  m_nValue := v;
end;

destructor CCInteger.Destroy;
begin

  inherited;
end;

function CCInteger.getValue: Integer;
begin
  Result := m_nValue;
end;

end.
