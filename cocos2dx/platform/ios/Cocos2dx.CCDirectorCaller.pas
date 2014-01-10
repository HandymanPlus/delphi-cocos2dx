unit Cocos2dx.CCDirectorCaller;

interface
uses
  System.TypInfo,
  Macapi.ObjectiveC,
  iOSapi.CocoaTypes, iOSapi.QuartzCore, iOSapi.Foundation;

type
  DirectorCaller = interface(NSObject)
    ['{A0862DB1-6E5D-4CB2-A9B6-32063A018374}']
    procedure doCaller(sender: Pointer); cdecl;
  end;

  CCDirectorCaller = class(TOCLocal)
  private
    interval: Integer;
    displayLink: CADisplayLink;
  public
    constructor Create();
    destructor Destroy(); override;
    function GetObjectiveCClass: PTypeInfo; override;
    procedure startMainLoop();
    procedure setAnimationInterval(intervalNew: Double);
    procedure doCaller(sender: Pointer); cdecl;
    class function sharedDirectorCaller(): CCDirectorCaller; static;
    class procedure purgeDirectorCaller(); static;
  end;

implementation
uses
  Macapi.ObjCRuntime, Cocos2dx.CCDirector;

type
  TTimerProc = procedure of object;

  Cocos2dxTimer = interface(NSObject)
    ['{4AAD1334-CC15-45FE-8DDC-1C7019CD690B}']
    procedure timerEvent; cdecl;
  end;

  TCocos2dxTimer = class(TOCLocal)
  private
    FFunc : TTimerProc;
    FTimer: NSTimer;
  public
    function GetObjectiveCClass: PTypeInfo; override;
    procedure timerEvent; cdecl;
    procedure SetTimerFunc(AFunc: TTimerProc);
  end;

{ CCDirectorCaller }

var s_sharedDirectorCaller: CCDirectorCaller;
var timer: TCocos2dxTimer;

constructor CCDirectorCaller.Create;
begin
  inherited;
  interval := 10; //设置时间值
  timer := TCocos2dxTimer.Create;
  timer.SetTimerFunc(startMainLoop);
  timer.FTimer := TNSTimer.Wrap(TNSTimer.OCClass.scheduledTimerWithTimeInterval(interval,
        timer.GetObjectID, sel_getUid('timerEvent'), timer.GetObjectID, True));
  NSObject(timer.Super).release;
end;

destructor CCDirectorCaller.Destroy;
begin
  //displayLink.removeFromRunLoop( TNSRunLoop.Wrap(TNSRunLoop.OCClass.currentRunLoop), NSDefaultRunLoopMode );
  //displayLink := nil;
  timer := nil;
  s_sharedDirectorCaller := nil;
  inherited;
end;

procedure CCDirectorCaller.doCaller(sender: Pointer);
begin
  CCDirector.sharedDirector().mainLoop();
end;

function CCDirectorCaller.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(DirectorCaller);
end;

class procedure CCDirectorCaller.purgeDirectorCaller;
begin
  s_sharedDirectorCaller.Free;
end;

procedure CCDirectorCaller.setAnimationInterval(intervalNew: Double);
begin
  {displayLink := nil;
  displayLink := TCADisplayLink.Wrap(TCADisplayLink.OCClass.displayLinkWithTarget(Self.GetObjectID, sel_getUid('doCaller')));

  interval := Round(60 * intervalNew);
  displayLink.setFrameInterval(interval);
  displayLink.addToRunLoop( TNSRunLoop.Wrap(TNSRunLoop.OCClass.currentRunLoop), NSDefaultRunLoopMode );}
end;

class function CCDirectorCaller.sharedDirectorCaller: CCDirectorCaller;
begin
  if s_sharedDirectorCaller = nil then
    s_sharedDirectorCaller := CCDirectorCaller.Create();
  Result := s_sharedDirectorCaller;
end;

procedure CCDirectorCaller.startMainLoop;
begin
  CCDirector.sharedDirector().mainLoop();
  {displayLink := nil;
  displayLink := TCADisplayLink.Wrap(TCADisplayLink.OCClass.displayLinkWithTarget(Self.GetObjectID, sel_getUid('doCaller')));

  displayLink.setFrameInterval(interval);
  displayLink.addToRunLoop( TNSRunLoop.Wrap(TNSRunLoop.OCClass.currentRunLoop), NSDefaultRunLoopMode );}
end;

{ TCocos2dxTimer }

function TCocos2dxTimer.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(Cocos2dxTimer);
end;

procedure TCocos2dxTimer.SetTimerFunc(AFunc: TTimerProc);
begin
  FFunc := AFunc;
end;

procedure TCocos2dxTimer.timerEvent;
begin
  if Assigned(@FFunc) then
  try
    FFunc;
  except

  end;
end;

end.
