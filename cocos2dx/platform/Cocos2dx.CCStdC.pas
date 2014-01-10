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

unit Cocos2dx.CCStdC;

interface

{$I config.inc}

type
  timezone = record
    tz_minuteswest: Integer;
    tz_dsttime: Integer;
  end;
  ptimezone = ^timezone;

function gettimeofday(_timeval, _timezone: Pointer): Integer;

implementation
uses
  {$IFDEF MSWINDOWS} Windows, {$ENDIF MSWINDOWS}
  {$IFDEF POSIX} Posix.SysTime, {$ENDIF POSIX}
  SysUtils, Cocos2dx.platform;

function gettimeofday(_timeval, _timezone: Pointer): Integer;
{$IFDEF MSWINDOWS}
var
  liTime, liFreq: LARGE_INTEGER;
  timeval: cc_timeval;
{$ENDIF MSWINDOWS}

{$IFDEF POSIX}
var
  TV: timeval;
{$ENDIF POSIX}
begin
{$IFDEF MSWINDOWS}
  if _timeval <> nil then
  begin
    QueryPerformanceFrequency(liFreq.QuadPart);
    QueryPerformanceCounter(liTime.QuadPart);
    timeval.tv_sec  := liTime.QuadPart/liFreq.QuadPart;
    timeval.tv_usec := liTime.QuadPart*1000000.0/liFreq.QuadPart - timeval.tv_sec*1000000.0;

    p_cc_timeval(_timeval)^ := timeval;
  end;
{$ENDIF MSWINDOWS}

{$IFDEF POSIX}
  Posix.SysTime.gettimeofday(TV, nil);
  p_cc_timeval(_timeval)^.tv_sec := TV.tv_sec;
  p_cc_timeval(_timeval)^.tv_usec := TV.tv_usec;
{$ENDIF POSIX}

  Result := 0;
end;

end.
