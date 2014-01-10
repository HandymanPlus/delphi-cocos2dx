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

unit Cocos2dx.CCIMEDispatcher;

interface
uses
  cObject, Cocos2dX.CCIMEDelegate;

type
  Impl = class;

  CCIMEDispatcher = class(TInterfaceObjectNull)
  private
    m_pImpl: Impl;
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedDispatcher(): CCIMEDispatcher;
    procedure dispatchInsertText(const pText: string; nLen: Integer);
    procedure dispatchDeleteBackward();
    function getContentText(): string;
    procedure dispatchkeyboardWillShow(var info: CCIMEKeyboardNotificationInfo);
    procedure dispatchkeyboardDidShow(var info: CCIMEKeyboardNotificationInfo);
    procedure dispatchkeyboardWillHide(var info: CCIMEKeyboardNotificationInfo);
    procedure dispatchkeyboardDidHide(var info: CCIMEKeyboardNotificationInfo);
  public
    procedure addDelegate(pDelegate: CCIMEDelegate);
    function attachDelegateWithIME(pDelegate: CCIMEDelegate): Boolean;
    function detachDelegateWithIME(pDelegate: CCIMEDelegate): Boolean;
    procedure removeDelegate(pDelegate: CCIMEDelegate);
  end;

  Impl = class
  private
    //m_pDelegateWithIme: CCIMEDelegate;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure init();
  end;
  
implementation



{ CCIMEDispatcher }

procedure CCIMEDispatcher.addDelegate(pDelegate: CCIMEDelegate);
begin

end;

function CCIMEDispatcher.attachDelegateWithIME(
  pDelegate: CCIMEDelegate): Boolean;
begin
Result := False;
end;

constructor CCIMEDispatcher.Create;
begin
  inherited Create();
  m_pImpl := Impl.Create;
end;

destructor CCIMEDispatcher.Destroy;
begin
  m_pImpl.Free;
  inherited;
end;

function CCIMEDispatcher.detachDelegateWithIME(
  pDelegate: CCIMEDelegate): Boolean;
begin
Result := False;
end;

procedure CCIMEDispatcher.dispatchDeleteBackward;
begin

end;

procedure CCIMEDispatcher.dispatchInsertText(const pText: string;
  nLen: Integer);
begin

end;

procedure CCIMEDispatcher.dispatchkeyboardDidHide(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

procedure CCIMEDispatcher.dispatchkeyboardDidShow(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

procedure CCIMEDispatcher.dispatchkeyboardWillHide(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

procedure CCIMEDispatcher.dispatchkeyboardWillShow(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

function CCIMEDispatcher.getContentText: string;
begin
Result := '';
end;

procedure CCIMEDispatcher.removeDelegate(pDelegate: CCIMEDelegate);
begin

end;

class function CCIMEDispatcher.sharedDispatcher: CCIMEDispatcher;
begin
Result := nil;
end;

{ Impl }

constructor Impl.Create;
begin

end;

destructor Impl.Destroy;
begin

  inherited;
end;

procedure Impl.init;
begin

end;

end.
