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

unit Cocos2dx.CCIMEDelegate;

interface
uses
  cGeometry;

type
  CCIMEKeyboardNotificationInfo = record
    _begin: CCRect;   // the soft keyboard rectangle when animation begins
    _end: CCRect;     // the soft keyboard rectangle when animation ends
    duration: Single; // the soft keyboard animation duration
  end;

  CCIMEDelegate = interface
    function attachWithIME(): Boolean;
    function detachWithIME(): Boolean;

    (**
    @brief    Decide if the delegate instance is ready to receive an IME message.

    Called by CCIMEDispatcher.
    *)
    function canAttachWithIME(): Boolean;

    (**
    @brief    When the delegate detaches from the IME, this method is called by CCIMEDispatcher.
    *)
    procedure didAttachWithIME();

    (**
    @brief    Decide if the delegate instance can stop receiving IME messages.
    *)
    function canDetachWithIME(): Boolean;

    (**
    @brief    When the delegate detaches from the IME, this method is called by CCIMEDispatcher.
    *)
    procedure didDetachWithIME();

    (**
    @brief    Called by CCIMEDispatcher when text input received from the IME.
    *)
    procedure insertText(const text: string; len: Integer);

    (**
    @brief    Called by CCIMEDispatcher after the user clicks the backward key.
    *)
    procedure deleteBackward();

    (**
    @brief    Called by CCIMEDispatcher for text stored in delegate.
    *)
    function getContentText(): string;

    //////////////////////////////////////////////////////////////////////////
    // keyboard show/hide notification
    //////////////////////////////////////////////////////////////////////////
    procedure keyboardWillShow(var info: CCIMEKeyboardNotificationInfo);
    procedure keyboardDidShow(var info: CCIMEKeyboardNotificationInfo);
    procedure keyboardWillHide(var info: CCIMEKeyboardNotificationInfo);
    procedure keyboardDidHide(var info: CCIMEKeyboardNotificationInfo);
  end;

implementation


end.
