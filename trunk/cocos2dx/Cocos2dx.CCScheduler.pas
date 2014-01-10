(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2011      Zynga Inc.

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

unit Cocos2dx.CCScheduler;

interface
uses                               
  Cocos2dx.CCObject, Cocos2dx.CCSet, tdHashChain, Cocos2dx.CCArray, Cocos2dx.cCCArray;

// Priority level reserved for system services.
const kCCPrioritySystem = Low(Integer);

// Minimum priority level for user scheduling.
const kCCPriorityNonSystemMin = kCCPrioritySystem + 1;

type
  CCTimer = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    function getInterval(): Single;
    procedure setInterval(fInterval: Single);
    function getSelector(): SEL_SCHEDULE;
    function initWithTarget(pTarget: CCObject; pfnSelector: SEL_SCHEDULE): Boolean; overload;
    function initWithTarget(pTarget: CCObject; pfnSelector: SEL_SCHEDULE; fSeconds: Single; nRepeat: Cardinal; fDelay: Single): Boolean; overload;
    //function initWithScriptHandler
    procedure update(dt: Single); override;
  public
    class function timeWithTarget(pTarget: CCObject; pfnSelector: SEL_SCHEDULE): CCTimer; overload;
    class function timeWithTarget(pTarget: CCObject; pfnSelector: SEL_SCHEDULE; fSeconds: Single): CCTimer; overload;
  protected
    m_pTarget: CCObject;
    m_fElapsed: Single;
    m_bRunForever: Boolean;
    m_bUseDelay: Boolean;
    m_uTimesExecuted: Cardinal;
    m_uRepeat: Cardinal;
    m_fDelay: Single;
    m_fInterval: Single;
    m_pfnSelector: SEL_SCHEDULE;
  end;

  pListEntry = ^tListEntry;
  tListEntry = record
    prev: pListEntry;
    next: pListEntry;
    target: CCObject;
    priority: Integer;
    paused: Boolean;
    markedForDeletion: Boolean;
  end;

  //tpListEntry = array [0..0] of pListEntry;
  ppListEntry = ^pListEntry;

  tHashUpdateEntry = record
    list: ppListEntry;
    entry: pListEntry;
    target: CCObject;
  end;
  pHashUpdateEntry = ^tHashUpdateEntry;

  tHashTimerEntry = record
    timers: p_ccArray;
    target: CCObject;
    timerIndex: Cardinal;
    currentTimer: CCTimer;
    currentTimerSalvaged: Boolean;
    paused: Boolean;
  end;
  PHashTimerEntry = ^tHashTimerEntry;

  (** @brief Scheduler is responsible for triggering the scheduled callbacks.
    You should not use NSTimer. Instead use this class.

    There are 2 different types of callbacks (selectors):

    - update selector: the 'update' selector will be called every frame. You can customize the priority.
    - custom selector: A custom selector will be called every frame, or with a custom interval of time

    The 'custom selectors' should be avoided when possible. It is faster, and consumes less memory to use the 'update selector'.

    *)
  CCScheduler = class(CCObject)
  private
    procedure removeHashElement(var pElement: PHashTimerEntry); overload;
    procedure removeHashElement(pElement: THashElement); overload;
    procedure removeUpdateFromHash(entry: pListEntry); overload;
    procedure removeUpdateFromHash(pHashElement: THashElement); overload;
    procedure priorityIn(pplist: ppListEntry; pTarget: CCObject; nPriority: Integer; bPaused: Boolean);
    procedure appendIn(pplist: ppListEntry; pTarget: CCObject; bPaused: Boolean);
  protected
    m_fTimeScale: Single;
    m_pUpdatesNegList: pListEntry;
    m_pUpdates0List: pListEntry;
    m_pUpdatesPosList: pListEntry;
    m_pHashForUpdates: TtdHashTableChain;
    m_pHashForTimers: TtdHashTableChain;
    m_pCurrentTarget: PHashTimerEntry;
    m_bCurrentTargetSalvaged: Boolean;
    m_bUpdateHashLocked: Boolean;
    m_pScriptHandlerEntries: CCArray;
  public
    constructor Create();
    destructor Destroy(); override;
    function getTimeScale(): Single;

    (** Modifies the time of all scheduled callbacks.
    You can use this property to create a 'slow motion' or 'fast forward' effect.
    Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
    To create a 'fast forward' effect, use values higher than 1.0.
    @since v0.8
    @warning It will affect EVERY scheduled selector / action.
    *)
    procedure setTimeScale(fTimeScale: Single);

    procedure update(dt: Single); override;

    (** The scheduled method will be called every 'interval' seconds.
     If paused is YES, then it won't be called until it is resumed.
     If 'interval' is 0, it will be called every frame, but if so, it's recommended to use 'scheduleUpdateForTarget:' instead.
     If the selector is already scheduled, then only the interval parameter will be updated without re-scheduling it again.
     repeat let the action be repeated repeat + 1 times, use kCCRepeatForever to let the action run continuously
     delay is the amount of time the action will wait before it'll start

     @since v0.99.3, repeat and delay added in v1.1
     @js  NA
     @lua NA
     *)
    procedure scheduleSelector(pfnSelector: SEL_SCHEDULE; pTarget: CCObject; fInterval: Single;
      nRepeat: Cardinal; delay: Single; bPaused: Boolean); overload;

    (** calls scheduleSelector with kCCRepeatForever and a 0 delay
     *  @js NA
     *  @lua NA
     *)
    procedure scheduleSelector(pfnSelector: SEL_SCHEDULE; pTarget: CCObject; fInterval: Single; bPaused: Boolean); overload;

    (** Schedules the 'update' selector for a given target with a given priority.
     The 'update' selector will be called every frame.
     The lower the priority, the earlier it is called.
     @since v0.99.3
     @lua NA
     *)
    procedure scheduleUpdateForTarget(pTarget: CCObject; nPriority: Integer; bPaused: Boolean);

    (** Unschedule a selector for a given target.
     If you want to unschedule the "update", use unscheudleUpdateForTarget.
     @since v0.99.3
     @lua NA
     *)
    procedure unscheduleSelector(pfnSelector: SEL_SCHEDULE; pTarget: CCObject);

    (** Unschedules the update selector for a given target
     @since v0.99.3
     @lua NA
     *)
    procedure unscheduleUpdateForTarget(const pTarget: CCObject);

    (** Unschedules all selectors for a given target.
     This also includes the "update" selector.
     @since v0.99.3
     @js  unscheduleCallbackForTarget
     @lua NA
     *)
    procedure unscheduleAllForTarget(pTarget: CCObject);

    (** Unschedules all selectors from all targets.
     You should NEVER call this method, unless you know what you are doing.

     @since v0.99.3
     @js unscheduleAllCallbacks
     @lua NA
     *)
    procedure unscheduleAll();

    (** Unschedules all selectors from all targets with a minimum priority.
      You should only call this with kCCPriorityNonSystemMin or higher.
      @since v2.0.0
      @js unscheduleAllCallbacksWithMinPriority
      @lua NA
      *)
    procedure unscheduleAllWithMinPriority(nMinPriority: Integer);

    (** Pauses the target.
     All scheduled selectors/update for a given target won't be 'ticked' until the target is resumed.
     If the target is not present, nothing happens.
     @since v0.99.3
     @lua NA
     *)
    procedure pauseTarget(pTarget: CCObject);

    (** Resumes the target.
     The 'target' will be unpaused, so all schedule selectors/update will be 'ticked' again.
     If the target is not present, nothing happens.
     @since v0.99.3
     @lua NA
     *)
    procedure resumeTarget(pTarget: CCObject);

    (** Returns whether or not the target is paused
     @since v1.0.0
     @lua NA
     *)
    function isTargetPaused(pTarget: CCObject): Boolean;

    (** Pause all selectors from all targets.
     You should NEVER call this method, unless you know what you are doing.
     @since v2.0.0
     @lua NA
     *)
    function pauseAllTargets(): CCSet;

    (** Pause all selectors from all targets with a minimum priority.
     You should only call this with kCCPriorityNonSystemMin or higher.
     @since v2.0.0
     @lua NA
     *)
    function pauseAllTargetsWithMinPriority(nMinPriority: Integer): CCSet;

    (** Resume selectors on a set of targets.
     This can be useful for undoing a call to pauseAllSelectors.
     @since v2.0.0
     @lua NA
     *)
    procedure resumeTargets(targetsToResume: CCSet);
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCMacros, Cocos2dx.CCPlatformMacros, Cocos2dx.CCDirector, Cocos2dx.CCCommon;

procedure DL_APPEND(var head: pListEntry; add: pListEntry);
begin
  if head <> nil then
  begin
    add^.prev := head^.prev;
    head^.prev^.next := add;
    head^.prev := add;
    add^.next := nil;
  end else
  begin
    head := add;
    head^.prev := head;
    head^.next := nil;
  end;   
end;

procedure DL_PREPEND(var head: pListEntry; add: pListEntry);
begin
  add^.next := head;
  if head <> nil then
  begin
    add^.prev := head^.prev;
    head^.prev := add;
  end else
  begin
    add^.prev := add;
  end;
  
  head := add;
end;

procedure DL_DELETE(var head: pListEntry; del: pListEntry);
begin
  if del^.prev = del then
  begin
    head := nil;
  end else if del = head then
  begin
    del^.next^.prev := del^.prev;
    head := del^.next;
  end else
  begin
    del^.prev^.next := del^.next;
    if del^.next <> nil then
    begin
      del^.next^.prev := del^.prev;
    end else
    begin
      head^.prev := del^.prev;
    end;    
  end;      
end;

{ CCTimer }

constructor CCTimer.Create;
begin
  inherited Create();
  {m_pfnSelector := nil;
  m_fInterval := 0.0;
  m_pTarget := nil;
  m_fElapsed := 0.0;
  m_bRunForever := False;
  m_bUseDelay := False;
  m_uTimesExecuted := 0;
  m_uRepeat := 0;
  m_fDelay := 0.0;}
end;

destructor CCTimer.Destroy;
begin

  inherited;
end;

function CCTimer.getInterval: Single;
begin
  Result := m_fInterval;
end;

function CCTimer.getSelector: SEL_SCHEDULE;
begin
  Result := m_pfnSelector;
end;

function CCTimer.initWithTarget(pTarget: CCObject;
  pfnSelector: SEL_SCHEDULE; fSeconds: Single; nRepeat: Cardinal;
  fDelay: Single): Boolean;
begin
  m_pTarget := pTarget;
  m_pfnSelector := pfnSelector;
  m_fElapsed := -1;
  m_fInterval := fSeconds;
  m_uRepeat := nRepeat;
  m_fDelay := fDelay;
  m_uTimesExecuted := 0;
  if fDelay > 0.0 then
    m_bUseDelay := True
  else
    m_bUseDelay := False;
  m_bRunForever := nRepeat = kCCRepeatForever;
  Result := True;
end;

function CCTimer.initWithTarget(pTarget: CCObject;
  pfnSelector: SEL_SCHEDULE): Boolean;
begin
  Result := initWithTarget(pTarget, pfnSelector, 0, kCCRepeatForever, 0.0);
end;

procedure CCTimer.setInterval(fInterval: Single);
begin
  m_fInterval := fInterval;
end;

class function CCTimer.timeWithTarget(pTarget: CCObject;
  pfnSelector: SEL_SCHEDULE; fSeconds: Single): CCTimer;
var
  pTimer: CCTimer;
begin
  pTimer := CCTimer.Create();
  pTimer.initWithTarget(pTarget, pfnSelector, fSeconds, kCCRepeatForever, 0.0);
  pTimer.autorelease();
  Result := pTimer;
end;

class function CCTimer.timeWithTarget(pTarget: CCObject;
  pfnSelector: SEL_SCHEDULE): CCTimer;
var
  pTimer: CCTimer;
begin
  pTimer := CCTimer.Create();
  pTimer.initWithTarget(pTarget, pfnSelector, 0.0, kCCRepeatForever, 0.0);
  pTimer.autorelease();
  Result := pTimer;
end;

procedure CCTimer.update(dt: Single);
begin
  if m_fElapsed = -1 then
  begin
    m_fElapsed := 0;
    m_uTimesExecuted := 0;
  end else
  begin
    if m_bRunForever and not m_bUseDelay then
    begin
      m_fElapsed := m_fElapsed + dt;
      if m_fElapsed >= m_fInterval then
      begin
        if (m_pTarget <> nil) and (@m_pfnSelector <> nil) then
        begin
          m_pfnSelector(m_fElapsed);
        end;

        m_fElapsed := 0;
      end;
    end else
    begin
      m_fElapsed := m_fElapsed + dt;
      if m_bUseDelay then
      begin
        if m_fElapsed >= m_fDelay then
        begin
          if (m_pTarget <> nil) and (@m_pfnSelector <> nil) then
          begin
            m_pfnSelector(m_fElapsed);
          end;

          m_fElapsed := m_fElapsed - m_fDelay;
          Inc(m_uTimesExecuted);
          m_bUseDelay := False; 
        end;
      end else
      begin
        if m_fElapsed >= m_fInterval then
        begin
          if (m_pTarget <> nil) and (@m_pfnSelector <> nil) then
          begin
            m_pfnSelector(m_fElapsed);
          end;
          m_fElapsed := 0;
          Inc(m_uTimesExecuted);
        end;  
      end;
      if not m_bRunForever and (m_uTimesExecuted > m_uRepeat) then
      begin
        CCDirector.sharedDirector().Scheduler.unscheduleSelector(m_pfnSelector, m_pTarget);
      end;   
    end;    
  end;
end;

{ CCScheduler }

procedure CCScheduler.appendIn(pplist: ppListEntry; pTarget: CCObject;
  bPaused: Boolean);
var
  pListElement: pListEntry;
  pHashData: pHashUpdateEntry;
  pHashElement: THashElement;
begin
  pListElement := AllocMem(SizeOf(tListEntry));
  pListElement^.target := pTarget;
  pListElement^.paused := bPaused;
  pListElement^.markedForDeletion := False;

  DL_APPEND(ppList^, pListElement);

  pHashData := AllocMem(SizeOf(tHashUpdateEntry));
  pHashData^.target := pTarget;
  pTarget.retain();
  pHashData^.list := pplist;
  pHashData^.entry := pListElement;

  pHashElement := THashElement.Create(Cardinal(pTarget), pHashData);
  m_pHashForUpdates.AddElement(pHashElement);
end;

procedure removeUpdatesElement(HashElement: THashElement);
var
  pHashData: pHashUpdateEntry;
begin
  pHashData := pHashUpdateEntry(HashElement.pValue);
  
  DL_DELETE(pHashData^.list^, pHashData^.entry);
  FreeMem(pHashData^.entry);
  CCObject(pHashData^.target).release();
  FreeMem(pHashData);

  HashElement.Free;
end;

procedure removeSelectorsElement(HashElement: THashElement);
var
  pHashData: PHashTimerEntry;
begin
  pHashData := PHashTimerEntry(HashElement.pValue);
  ccArrayFree(pHashData^.timers);
  CC_SAFE_RELEASE(pHashData^.currentTimer);
  CC_SAFE_RELEASE(pHashData^.target);
  FreeMem(pHashData);

  HashElement.Free;
end;

constructor CCScheduler.Create;
begin
  inherited Create();
  m_pHashForUpdates := TtdHashTableChain.Create(100, removeUpdatesElement);
  m_pHashForTimers := TtdHashTableChain.Create(100, removeSelectorsElement);
  m_fTimeScale := 1.0;
end;

destructor CCScheduler.Destroy;
begin
  unscheduleAll();
  m_pHashForTimers.Free;
  m_pHashForUpdates.Free;
  CC_SAFE_RELEASE(m_pScriptHandlerEntries);
  inherited;
end;

function CCScheduler.getTimeScale: Single;
begin
  Result := m_fTimeScale;
end;

function CCScheduler.isTargetPaused(pTarget: CCObject): Boolean;
var
  pHashElement: THashElement;
begin
  pHashElement := m_pHashForTimers.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    Result := PHashTimerEntry(pHashElement.pValue)^.paused;
    Exit;
  end;

  pHashElement := m_pHashForUpdates.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    Result := PHashTimerEntry(pHashElement.pValue)^.paused;
    Exit;
  end;

  Result := False;
end;

function CCScheduler.pauseAllTargets: CCSet;
begin
  Result := pauseAllTargetsWithMinPriority(kCCPrioritySystem);
end;

function CCScheduler.pauseAllTargetsWithMinPriority(
  nMinPriority: Integer): CCSet;
var
  idsWithSelectors: CCSet;
  pHashElement: THashElement;
  pEntry: pListEntry;
begin
  idsWithSelectors := CCSet.Create;
  idsWithSelectors.autorelease();

  pHashElement := m_pHashForTimers.First();
  while pHashElement <> nil do
  begin
    PHashTimerEntry(pHashElement.pValue)^.paused := True;
    idsWithSelectors.addObject(PHashTimerEntry(pHashElement.pValue)^.target);

    pHashElement := m_pHashForTimers.Next();
  end;

  if nMinPriority < 0 then
  begin

    pEntry := m_pUpdatesNegList;

    while (pEntry <> nil) do
    begin
      if pEntry^.priority >= nMinPriority then
      begin
        pEntry^.paused := True;
        idsWithSelectors.addObject(pEntry^.target);
      end;

      pEntry := pEntry^.next;
    end;
  end;

  if nMinPriority <= 0 then
  begin

    pEntry := m_pUpdates0List;

    while (pEntry <> nil) do
    begin
      pEntry^.paused := True;
      idsWithSelectors.addObject(pEntry^.target);

      pEntry := pEntry^.next;
    end;
  end;


  pEntry := m_pUpdatesPosList;

  while (pEntry <> nil) do
  begin
    if pEntry^.priority >= nMinPriority then
    begin
      pEntry^.paused := True;
      idsWithSelectors.addObject(pEntry^.target);
    end;

    pEntry := pEntry^.next;
  end;

  Result := idsWithSelectors;
end;

procedure CCScheduler.pauseTarget(pTarget: CCObject);
var
  pHashElement: THashElement;

begin
  pHashElement := m_pHashForTimers.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    PHashTimerEntry(pHashElement.pValue)^.paused := True;
  end;

  pHashElement := m_pHashForUpdates.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    CCAssert(pHashUpdateEntry(pHashElement.pValue)^.entry <> nil, '');
    pHashUpdateEntry(pHashElement.pValue)^.entry^.paused := True;
  end;
end;

procedure CCScheduler.priorityIn(pplist: ppListEntry; pTarget: CCObject;
  nPriority: Integer; bPaused: Boolean);
var
  pListElement, pElement: pListEntry;
  bAdded: Boolean;
  pHashDat: pHashUpdateEntry;
  pHashElement: THashElement;
begin
  pListElement := AllocMem(SizeOf(tListEntry));
  pListElement^.target := pTarget;
  pListElement^.priority := nPriority;
  pListElement^.paused := bPaused;
  pListElement^.next := nil;
  pListElement^.prev := nil;
  pListElement^.markedForDeletion := False;

  if pplist^ = nil then
  begin
    DL_APPEND(ppList^, pListElement);
  end else
  begin
    bAdded := False;
    pElement := ppList^;
    while pElement <> nil do
    begin
      if nPriority < pElement^.priority then
      begin
        if pElement = pplist^ then
        begin
          DL_PREPEND(ppList^, pListElement);
        end else
        begin
          pListElement^.next := pElement;
          pListElement^.prev := pElement^.prev;

          pElement^.prev^.next := pListElement;
          pElement^.prev := pListElement;
        end;

        bAdded := True;
        Break;
      end;
      pElement := pElement^.next;
    end;
    if not bAdded then
    begin
      DL_APPEND(ppList^, pListElement);
    end;
  end;

  pHashDat := AllocMem(SizeOf(tHashUpdateEntry));
  pHashDat^.target := pTarget;
  pTarget.retain();
  pHashDat^.list := pplist;
  pHashDat^.entry := pListElement;

  pHashElement := THashElement.Create(Cardinal(pTarget), pHashDat);
  m_pHashForUpdates.AddElement(pHashElement);
end;

procedure CCScheduler.removeHashElement(var pElement: PHashTimerEntry);
var
  pHashElement: THashElement;
  target: CCObject;
begin
  pHashElement := m_pHashForTimers.FindElementByInteger(Cardinal(pElement.target));
  if (pHashElement <> nil) and (PHashTimerEntry(pHashElement.pValue) = pElement) then
  begin
    ccArrayFree(pElement^.timers);

    target := pElement.target;

    FreeMem(pElement);
    pElement := nil;

    m_pHashForTimers.DelElement(pHashElement);
    pHashElement.Free;

    target.release();
  end;
end;

procedure CCScheduler.removeHashElement(pElement: THashElement);
var
  pHashData: PHashTimerEntry;
begin
  if pElement <> nil then
  begin
    pHashData := PHashTimerEntry(pElement.pValue);
    if pHashData <> nil then
    begin
      ccArrayFree(pHashData^.timers);
      pHashData^.target.release();
      pHashData^.target := nil;
      FreeMem(pHashData);
    end;
    m_pHashForTimers.DelElement(pElement);
    pElement.Free;
  end;
end;

procedure CCScheduler.removeUpdateFromHash(entry: pListEntry);
var
  pHashElement: THashElement;
  pHashData: pHashUpdateEntry;
  pTarget: CCObject;
begin
  pHashElement := m_pHashForUpdates.FindElementByInteger(Cardinal(entry^.target));
  if pHashElement <> nil then
  begin
    pHashData := pHashUpdateEntry(pHashElement.pValue);
    DL_DELETE(pHashData^.list^, pHashData^.entry);
    FreeMem(pHashData^.entry);

    pTarget := pHashData^.target;

    FreeMem(pHashData);
    m_pHashForUpdates.DelElement(pHashElement);
    pHashElement.Free;
    pTarget.release();
  end;
end;

procedure CCScheduler.removeUpdateFromHash(pHashElement: THashElement);
var
  pHashData: pHashUpdateEntry;
  pTarget: CCObject;
begin
  if pHashElement <> nil then
  begin
    pHashData := pHashUpdateEntry(pHashElement.pValue);
    DL_DELETE(pHashData^.list^, pHashData^.entry);
    FreeMem(pHashData^.entry);

    pTarget := pHashData^.target;

    FreeMem(pHashData);
    m_pHashForUpdates.DelElement(pHashElement);
    pHashElement.Free;
    pTarget.release();
  end;
end;

procedure CCScheduler.resumeTarget(pTarget: CCObject);
var
  pHashElement: THashElement;
begin
  pHashElement := m_pHashForTimers.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    PHashTimerEntry(pHashElement.pValue)^.paused := False;
  end;

  pHashElement := m_pHashForUpdates.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    CCAssert(pHashUpdateEntry(pHashElement.pValue)^.entry <> nil, '');
    pHashUpdateEntry(pHashElement.pValue)^.entry^.paused := False;
  end;
end;

procedure CCScheduler.resumeTargets(targetsToResume: CCSet);
var
  i: Integer;
begin
  for i := 0 to targetsToResume.count()-1 do
  begin
    resumeTarget(targetsToResume.getObject(i));
  end;
end;

procedure CCScheduler.scheduleSelector(pfnSelector: SEL_SCHEDULE;
  pTarget: CCObject; fInterval: Single; bPaused: Boolean);
begin
  Self.scheduleSelector(pfnSelector, pTarget, fInterval, kCCRepeatForever, 0.0, bPaused);
end;

procedure CCScheduler.scheduleSelector(pfnSelector: SEL_SCHEDULE;
  pTarget: CCObject; fInterval: Single; nRepeat: Cardinal;
  delay: Single; bPaused: Boolean);
var
  pHashElement: THashElement;
  pHashData: PHashTimerEntry;
  i: Integer;
  timer, pTimer: CCTimer;
begin
  CCAssert(@pfnSelector <> nil, 'Argument selector must be non-NULL');
  CCAssert(pTarget <> nil, 'Argument target must be non-NULL');

  pHashElement := m_pHashForTimers.FindElementByInteger(Cardinal(pTarget));
  if pHashElement = nil then
  begin
    pHashData := AllocMem(SizeOf(tHashTimerEntry));
    pHashData^.target := pTarget;
    if pTarget <> nil then
    begin
      pTarget.retain();
    end;
    pHashData^.paused := bPaused;

    pHashElement := THashElement.Create(Cardinal(pTarget), pHashData);
    m_pHashForTimers.AddElement(pHashElement);
  end else
  begin
    CCAssert(PHashTimerEntry(pHashElement.pValue).paused = bPaused, '');
  end;

  pHashData := PHashTimerEntry(pHashElement.pValue);
  if pHashData^.timers = nil then
  begin
    pHashData^.timers := ccArrayNew(10);
  end else
  begin
    for i := 0 to pHashData^.timers.num-1 do
    begin
      timer := CCTimer(pHashData^.timers^.arr[i]);
      if @pfnSelector = @timer.getSelector() then
      begin
        CCLOG('CCScheduler#scheduleSelector. Selector already scheduled. Updating interval from: %.4f to %.4f', [timer.getInterval(), fInterval]);
        timer.setInterval(fInterval);
        Exit;
      end;  
    end;
    ccArrayEnsureExtraCapacity(pHashData^.timers, 1); 
  end;

  pTimer := CCTimer.Create;
  pTimer.initWithTarget(pTarget, pfnSelector, fInterval, nRepeat, delay);
  ccArrayAppendObject(pHashData^.timers, pTimer);
  pTimer.release();
end;

procedure CCScheduler.scheduleUpdateForTarget(pTarget: CCObject;
  nPriority: Integer; bPaused: Boolean);
var
  pHashElement: THashElement;
begin
  pHashElement := m_pHashForUpdates.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    pHashUpdateEntry(pHashElement.pValue)^.entry^.markedForDeletion := False;
    Exit;
  end;

  if nPriority = 0 then
  begin
    appendIn(@m_pUpdates0List, pTarget, bPaused);
  end else if nPriority < 0 then
  begin
    priorityIn(@m_pUpdatesNegList, pTarget, nPriority, bPaused);
  end else
  begin
    priorityIn(@m_pUpdatesPosList, pTarget, nPriority, bPaused);
  end;      
end;

procedure CCScheduler.setTimeScale(fTimeScale: Single);
begin
  m_fTimeScale := fTimeScale;
end;

procedure CCScheduler.unscheduleAll;
begin
  unscheduleAllWithMinPriority(kCCPrioritySystem);
end;

procedure CCScheduler.unscheduleAllForTarget(pTarget: CCObject);
var
  pHashElement: THashElement;
  pHashData: PHashTimerEntry;
begin
  if pTarget = nil then
    Exit;

  pHashElement := m_pHashForTimers.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    pHashData := PHashTimerEntry(pHashElement.pValue);
    if ccArrayContainsObject(pHashData^.timers, pHashData^.currentTimer) and
       (not pHashData^.currentTimerSalvaged) then
    begin
      pHashData^.currentTimer.retain();
      pHashData^.currentTimerSalvaged := True;
    end;
    ccArrayRemoveAllObjects(pHashData^.timers);

    if m_pCurrentTarget = pHashData then
    begin
      m_bCurrentTargetSalvaged := True;
    end else
    begin
      removeHashElement(pHashElement);
    end;    
  end;

  unscheduleUpdateForTarget(pTarget);
end;

procedure CCScheduler.unscheduleAllWithMinPriority(
  nMinPriority: Integer);
var
  pHashElement: THashElement;
  pEntry, pTmp: pListEntry;
begin
  pHashElement := m_pHashForTimers.First();
  while pHashElement <> nil do
  begin
    unscheduleAllForTarget(PHashTimerEntry(pHashElement.pValue)^.target);
    pHashElement := m_pHashForTimers.Next();
  end;

  (*#define DL_FOREACH_SAFE(head,el,tmp)
  for((el)=(head);(el) && (tmp = (el)->next, 1); (el) = tmp)*)
  if nMinPriority < 0 then
  begin
    pEntry := m_pUpdatesNegList;

    while (pEntry <> nil) do
    begin
      pTmp := pEntry^.next;

      if pEntry^.priority >= nMinPriority then
        unscheduleUpdateForTarget(pEntry^.target);

      pEntry := pTmp;
    end;
  end;


  if nMinPriority <= 0 then
  begin
    pEntry := m_pUpdates0List;

    while (pEntry <> nil) do
    begin
      pTmp := pEntry^.next;

      unscheduleUpdateForTarget(pEntry^.target);

      pEntry := pTmp;
    end;
  end;

  pEntry := m_pUpdatesPosList;

  while (pEntry <> nil) do
  begin
    pTmp := pEntry^.next;
    
    if pEntry^.priority >= nMinPriority then
      unscheduleUpdateForTarget(pEntry^.target);

    pEntry := pTmp;
  end;
end;

procedure CCScheduler.unscheduleSelector(pfnSelector: SEL_SCHEDULE;
  pTarget: CCObject);
var
  pHashElement: THashElement;
  pHashData: PHashTimerEntry;
  i: Cardinal;
  pTimer: CCTimer;
begin
  if (pTarget = nil) or (@pfnSelector = nil) then
    Exit;

  pHashElement := m_pHashForTimers.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    pHashData := PHashTimerEntry(pHashElement.pValue);

    if pHashData^.timers^.num < 1 then
      Exit;

    for i := 0 to pHashData^.timers^.num-1 do
    begin
      pTimer := CCTimer(pHashData^.timers^.arr[i]);

      if @pfnSelector = @pTimer.getSelector() then
      begin
        if (pTimer = pHashData^.currentTimer) and (not pHashData^.currentTimerSalvaged) then
        begin
          pHashData^.currentTimer.retain();
          pHashData^.currentTimerSalvaged := True;
        end;

        ccArrayRemoveObjectAtIndex(pHashData^.timers, i, True);

        if pHashData^.timerIndex >= i then
        begin
          Dec(pHashData^.timerIndex);
        end;

        if pHashData^.timers^.num = 0 then
        begin
          if m_pCurrentTarget = pHashData then
          begin
            m_bCurrentTargetSalvaged := True;
          end else
          begin
            removeHashElement(pHashElement);
          end;    
        end;

        Exit;
      end;
    end;
  end;
end;

procedure CCScheduler.unscheduleUpdateForTarget(const pTarget: CCObject);
var
  pHashElement: THashElement;
begin
  if pTarget = nil then
    Exit;

  pHashElement := m_pHashForUpdates.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    if m_bUpdateHashLocked then
    begin
      pHashUpdateEntry(pHashElement.pValue)^.entry^.markedForDeletion := True;
    end else
    begin
      Self.removeUpdateFromHash(pHashElement);
    end;    
  end;
end;

procedure CCScheduler.update(dt: Single);

  procedure dealSelectorEntry(pHashElement: THashElement);
  var
    pSelectorData: PHashTimerEntry;
  begin
    pSelectorData := PHashTimerEntry(pHashElement.pValue);

    m_pCurrentTarget := pSelectorData;
    m_bCurrentTargetSalvaged := False;

    if not m_pCurrentTarget^.paused then
    begin
      pSelectorData^.timerIndex := 0;
      while pSelectorData^.timerIndex < pSelectorData^.timers^.num do
      begin
        pSelectorData^.currentTimer := CCTimer(pSelectorData^.timers^.arr[pSelectorData^.timerIndex]);
        pSelectorData^.currentTimerSalvaged := False;
        pSelectorData^.currentTimer.update(dt);

        if pSelectorData^.currentTimerSalvaged then
          pSelectorData^.currentTimer.release();

        pSelectorData^.currentTimer := nil;

        Inc(pSelectorData^.timerIndex);
      end;  
    end;

    if m_bCurrentTargetSalvaged and (m_pCurrentTarget.timers^.num = 0) then
    begin
      removeHashElement(pHashElement);
    end;  
  end;

  procedure updateTarget(list: pListEntry);
  var
    pEntry, pTmp: pListEntry;
  begin
    pEntry := list;
    while pEntry <> nil do
    begin
      pTmp := pEntry^.next;

      if (not pEntry^.paused) and (not pEntry^.markedForDeletion) then
        pEntry^.target.update(dt);

      pEntry := pTmp;
    end;
  end;

  procedure removeTarget(list: pListEntry);
  var
    pEntry, pTmp: pListEntry;
  begin
    pEntry := list;
    while pEntry <> nil do
    begin
      pTmp := pEntry^.next;

      if pEntry^.markedForDeletion then
        Self.removeUpdateFromHash(pEntry);

      pEntry := pTmp;
    end;
  end;  


var
  pHashElement: THashElement;
begin
  m_bUpdateHashLocked := True;
  
  if m_fTimeScale <> 1.0 then
  begin
    dt := dt * m_fTimeScale;
  end;

  updateTarget(m_pUpdatesNegList);
  updateTarget(m_pUpdates0List);
  updateTarget(m_pUpdatesPosList);

  pHashElement := m_pHashForTimers.First();
  while pHashElement <> nil do
  begin
    dealSelectorEntry(pHashElement);
    pHashElement := m_pHashForTimers.Next();
  end;

  removeTarget(m_pUpdatesNegList);
  removeTarget(m_pUpdates0List);
  removeTarget(m_pUpdatesPosList);

  m_bUpdateHashLocked := False;
  m_pCurrentTarget := nil;
end;

end.
