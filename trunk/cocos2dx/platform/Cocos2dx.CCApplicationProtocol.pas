(****************************************************************************
Copyright (c) 2010-2013 cocos2d-x.org
Copyright (c) Microsoft Open Technologies, Inc.

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

unit Cocos2dx.CCApplicationProtocol;

interface
uses
  Cocos2dx.CCCommon;

type
  TargetPlatform = (
    kTargetWindows,
    kTargetLinux,
    kTargetMacOS,
    kTargetAndroid,
    kTargetIphone,
    kTargetIpad,
    kTargetBlackBerry,
    kTargetNaCl,
    kTargetEmscripten,
    kTargetTizen,
    kTargetWinRT,
    kTargetWP8
  );

  CCApplicationProtocol = class
  public
    (**
    @brief    Implement CCDirector and CCScene init code here.
    @return true    Initialize success, app continue.
    @return false   Initialize failed, app terminate.
    *)
    function applicationDidFinishLaunching(): Boolean; virtual; abstract;
    (**
    @brief  The function be called when the application enter background
    @param  the pointer of the application
    *)
    procedure applicationDidEnterBackground(); virtual; abstract;
    (**
    @brief  The function be called when the application enter foreground
    @param  the pointer of the application
    *)
    procedure applicationWillEnterForeground(); virtual; abstract;
    (**
    @brief    Callback by CCDirector for limit FPS.
    @interval       The time, expressed in seconds, between current frame and next.
    *)
    procedure setAnimationInterval(interval: Double); virtual; abstract;
    (**
    @brief Get current language config
    @return Current language config
    *)
    function getCurrentLanguage(): ccLanguageType; virtual; abstract;
    (**
     @brief Get target platform
     *)
    function getTargetPlatform(): TargetPlatform; virtual; abstract;
  end;

implementation

end.
