unit Cocos2dx.Platform;

interface

type
  cc_timeval = record
    tv_sec: Single;
    tv_usec: Single;
  end;
  p_cc_timeval = ^cc_timeval;

  CCTime = class
  public
    class function gettimeofdayCocos2d(tp: p_cc_timeval; tzp: Pointer): Integer;
    class function timersubCocos2d(start: p_cc_timeval; _end: p_cc_timeval): Double;
  end;

implementation
uses
  Cocos2dx.CCStdC;

{ CCTime }

class function CCTime.gettimeofdayCocos2d(tp: p_cc_timeval;
  tzp: Pointer): Integer;
begin
  if tp <> nil then
  begin
    gettimeofday(tp, nil);
  end;
  Result := 0;
end;

class function CCTime.timersubCocos2d(start, _end: p_cc_timeval): Double;
begin
  if (start = nil) or (_end = nil) then
  begin
    Result := 0;
    Exit;
  end;

  Result := ((_end^.tv_sec*1000.0+_end^.tv_usec/1000.0) - (start^.tv_sec*1000.0+start^.tv_usec/1000.0));
end;

end.
