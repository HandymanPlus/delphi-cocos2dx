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

unit Cocos2dx.CCKeypadDelegate;

interface
uses
  Cocos2dx.CCObject;

type
  CCKeypadDelegate = interface
    procedure keyBackClicked();
    procedure keyMenuClicked();
  end;

  CCKeypadHandler = class(CCObject)
  public
    destructor Destroy(); override;
    function getDelegate(): CCKeypadDelegate;
    procedure setDelegate(pDelegate: CCKeypadDelegate);
    function initWithDelegate(pDelegate: CCKeypadDelegate): Boolean;
    class function handlerWithDelegate(pDelegate: CCKeypadDelegate): CCKeypadHandler;
  protected
    m_pDelegate: CCKeypadDelegate;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCKeypadHandler }

destructor CCKeypadHandler.Destroy;
begin
  if m_pDelegate <> nil then
    CCObject(m_pDelegate).release();
  inherited;
end;

function CCKeypadHandler.getDelegate: CCKeypadDelegate;
begin
  Result := m_pDelegate;
end;

class function CCKeypadHandler.handlerWithDelegate(
  pDelegate: CCKeypadDelegate): CCKeypadHandler;
var
  pHandler: CCKeypadHandler;
begin
  pHandler := CCKeypadHandler.Create;
  if pHandler <> nil then
  begin
    if pHandler.initWithDelegate(pDelegate) then
    begin
      pHandler.autorelease();
    end else
    begin
      CC_SAFE_RELEASE_NULL(CCObject(pHandler));
    end;
  end;
  Result := pHandler;
end;

function CCKeypadHandler.initWithDelegate(
  pDelegate: CCKeypadDelegate): Boolean;
begin
  CCAssert(pDelegate <> nil, 'It is a wrong delegate!');
  m_pDelegate := pDelegate;
  CCObject(pDelegate).retain();
  Result := True;
end;

procedure CCKeypadHandler.setDelegate(pDelegate: CCKeypadDelegate);
begin
  if pDelegate <> nil then
    CCObject(pDelegate).retain();
  if m_pDelegate <> nil then
    CCObject(m_pDelegate).release();

  m_pDelegate := pDelegate;
end;

end.
