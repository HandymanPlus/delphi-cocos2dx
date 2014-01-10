(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Valentin Milea

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

unit Cocos2dx.CCTouchDispatcher;

interface
uses                                         
  Cocos2dx.CCObject, Cocos2dx.CCSet, Cocos2dx.CCTouch, Cocos2dx.CCTouchDelegateProtocol,
  Cocos2dx.CCTouchHandler, Cocos2dx.CCArray, Cocos2dx.cCCArray;

//type
//  ccTouchSelectorFlag = (
const    ccTouchSelectorBeganBit     = 1 shl 0;
const    ccTouchSelectorMovedBit     = 1 shl 1;
const    ccTouchSelectorEndedBit     = 1 shl 2;
const    ccTouchSelectorCancelledBit = 1 shl 3;
const    ccTouchSelectorAllBits      = ( ccTouchSelectorBeganBit or ccTouchSelectorMovedBit or ccTouchSelectorEndedBit or ccTouchSelectorCancelledBit);
//  );

const CCTOUCHBEGAN     = 0;
const CCTOUCHMOVED     = 1;
const CCTOUCHENDED     = 2;
const CCTOUCHCANCELLED = 3;
const ccTouchMax       = 4;

type
  ccTouchHandlerHelperData = record
    m_type: Integer;
  end;

  EGLTouchDelegate = interface
    procedure touchesBegan(touches: CCSet; pEvent: CCEvent);
    procedure touchesMoved(touches: CCSet; pEvent: CCEvent);
    procedure touchesEnded(touches: CCSet; pEvent: CCEvent);
    procedure touchesCancelled(touches: CCSet; pEvent: CCEvent);
  end;

  (** @brief CCTouchDispatcher.
       Singleton that handles all the touch events.
       The dispatcher dispatches events to the registered TouchHandlers.
       There are 2 different type of touch handlers:
         - Standard Touch Handlers
         - Targeted Touch Handlers

       The Standard Touch Handlers work like the CocoaTouch touch handler: a set of touches is passed to the delegate.
       On the other hand, the Targeted Touch Handlers only receive 1 touch at the time, and they can "swallow" touches (avoid the propagation of the event).

       Firstly, the dispatcher sends the received touches to the targeted touches.
       These touches can be swallowed by the Targeted Touch Handlers. If there are still remaining touches, then the remaining touches will be sent
       to the Standard Touch Handlers.

       @since v0.8.0
       @js NA
       *)
  CCTouchDispatcher = class(CCObject, EGLTouchDelegate)
  protected
    m_pTargetedHandlers: CCArray;
    m_pStandardHandlers: CCArray;
    m_pHandlersToAdd: CCArray;
    m_pHandlersToRemove: p_ccCArray;
    m_bLocked: Boolean;
    m_bToAdd: Boolean;
    m_bToRemove: Boolean;
    m_bToQuit: Boolean;
    m_bDispatchEvents: Boolean;
    m_sHandlerHelperData: array [0..ccTouchMax-1] of ccTouchHandlerHelperData;
    procedure forceRemoveDelegate(pDelegate: CCTouchDelegate);
    procedure forceAddHandler(pHandler: CCTouchHandler; pArray: CCArray);
    procedure forceRemoveAllDelegates();
    procedure rearrangeHandlers(pArray: CCArray);
    function findHandler(pArray: CCArray; pDelegate: CCTouchDelegate): CCTouchHandler; overload;
  public
    constructor Create();
    destructor Destroy(); override;
    //** Whether or not the events are going to be dispatched. Default: true */
    function isDispatchEvents(): Boolean;
    procedure setDispatchEvents(bDispatchEvents: Boolean);

    (** Adds a standard touch delegate to the dispatcher's list.
     * See StandardTouchDelegate description.
     * IMPORTANT: The delegate will be retained.
     * @lua NA
     *)
    procedure addStandardDelegate(pDelegate: CCTouchDelegate; nPriority: Integer);

    (** Adds a targeted touch delegate to the dispatcher's list.
     * See TargetedTouchDelegate description.
     * IMPORTANT: The delegate will be retained.
     * @lua NA
     *)
    procedure addTargetedDelegate(pDelegate: CCTouchDelegate; nPriority: Integer; bSwallowsTouches: Boolean);

    (** Removes a touch delegate.
     * The delegate will be released
     * @lua NA
     *)
    procedure removeDelegate(pDelegate: CCTouchDelegate);

    (** Removes all touch delegates, releasing all the delegates
     * @lua NA
     *)
    procedure removeAllDelegates();

    (** Changes the priority of a previously added delegate. The lower the number,
     * the higher the priority
     * @lua NA
     *)
    procedure setPriority(nPriority: Integer; pDelegate: CCTouchDelegate);
    procedure touches(pTouches: CCSet; pEvent: CCEvent; uIndex: Cardinal);
    function findHandler(pDelegate: CCTouchDelegate): CCTouchHandler; overload;
    function init(): Boolean;
    procedure touchesBegan(touches: CCSet; pEvent: CCEvent);
    procedure touchesMoved(touches: CCSet; pEvent: CCEvent);
    procedure touchesEnded(touches: CCSet; pEvent: CCEvent);
    procedure touchesCancelled(touches: CCSet; pEvent: CCEvent);
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCTouchDispatcher }

function less(const p1, p2: CCObject): Integer;
begin
  Result := CCTouchHandler(p1).getPriority() - CCTouchHandler(p2).getPriority();
end;  

procedure CCTouchDispatcher.addStandardDelegate(pDelegate: CCTouchDelegate;
  nPriority: Integer);
var
  pHandler: CCTouchHandler;
begin
  pHandler := CCStandardTouchHandler.handlerWithDelegate(pDelegate, nPriority);
  if not m_bLocked then
  begin
    forceAddHandler(pHandler, m_pStandardHandlers);
  end else
  begin
    if ccCArrayContainsValue(m_pHandlersToRemove, Pointer(pDelegate)) then
    begin
      ccCArrayRemoveValue(m_pHandlersToRemove, Pointer(pDelegate));
      Exit;
    end;

    m_pHandlersToAdd.addObject(pHandler);
    m_bToAdd := True;
  end;  
end;

procedure CCTouchDispatcher.addTargetedDelegate(pDelegate: CCTouchDelegate;
  nPriority: Integer; bSwallowsTouches: Boolean);
var
  pHandler: CCTouchHandler;
begin
  pHandler := CCTargetedTouchHandler.handlerWithDelegate(pDelegate, nPriority, bSwallowsTouches);
  if not m_bLocked then
  begin
    forceAddHandler(pHandler, m_pTargetedHandlers);
  end else
  begin
    if ccCArrayContainsValue(m_pHandlersToRemove, Pointer(pDelegate)) then
    begin
      ccCArrayRemoveValue(m_pHandlersToRemove, Pointer(pDelegate));
      Exit;
    end;

    m_pHandlersToAdd.addObject(pHandler);
    m_bToAdd := True;
  end;
end;

constructor CCTouchDispatcher.Create;
begin
  inherited Create();
end;

destructor CCTouchDispatcher.Destroy;
begin
  CC_SAFE_RELEASE(m_pTargetedHandlers);
  CC_SAFE_RELEASE(m_pStandardHandlers);
  CC_SAFE_RELEASE(m_pHandlersToAdd);

  ccCArrayFree(m_pHandlersToRemove);
  m_pHandlersToRemove := nil;
  inherited;
end;

function CCTouchDispatcher.findHandler(
  pDelegate: CCTouchDelegate): CCTouchHandler;
var
  i: Integer;
  pHandler: CCTouchHandler;
begin
  if (m_pTargetedHandlers <> nil) and (m_pTargetedHandlers.count() > 0) then
  begin
    for i := 0 to m_pTargetedHandlers.count()-1 do
    begin
      pHandler := CCTouchHandler(m_pTargetedHandlers.objectAtIndex(i));
      if (pHandler <> nil) and (pHandler.getDelegate() = pDelegate) then
      begin
        Result := pHandler;
        Exit;
      end;
    end;
  end;

  if (m_pStandardHandlers <> nil) and (m_pStandardHandlers.count() > 0) then
  begin
    for i := 0 to m_pStandardHandlers.count()-1 do
    begin
      pHandler := CCTouchHandler(m_pStandardHandlers.objectAtIndex(i));
      if (pHandler <> nil) and (pHandler.getDelegate() = pDelegate) then
      begin
        Result := pHandler;
        Exit;
      end;
    end;
  end;

  Result := nil;
end;

function CCTouchDispatcher.findHandler(pArray: CCArray;
  pDelegate: CCTouchDelegate): CCTouchHandler;
var
  pHandler: CCTouchHandler;
  i: Integer;
begin
  CCAssert((pArray <> nil) and (pDelegate <> nil), '');

  if (pArray <> nil) and (pArray.count() > 0) then
  begin
    for i := 0 to pArray.count()-1 do
    begin
      pHandler := CCTouchHandler(pArray.objectAtIndex(i));
      if (pHandler <> nil) and (pHandler.getDelegate() = pDelegate) then
      begin
        Result := pHandler;
        Exit;
      end;  
    end;  
  end;

  Result := nil;
end;

procedure CCTouchDispatcher.forceAddHandler(pHandler: CCTouchHandler;
  pArray: CCArray);
var
  u: Cardinal;
  h: CCTouchHandler;
  i: Integer;
begin
  u := 0;
  if (pArray <> nil) and (pArray.count() > 0) then
  begin
    for i := 0 to pArray.count()-1 do
    begin
      h := CCTouchHandler(pArray.objectAtIndex(i));
      if h <> nil then
      begin
        if h.getPriority() < pHandler.getPriority() then
          Inc(u);

        if h.getDelegate() = pHandler.getDelegate() then
        begin
          CCAssert(False, '');
          Exit;
        end;  
      end;
    end;
  end;
  pArray.insertObject(pHandler, u);
end;

procedure CCTouchDispatcher.forceRemoveAllDelegates;
begin
  m_pStandardHandlers.removeAllObjects();
  m_pTargetedHandlers.removeAllObjects();
end;

procedure CCTouchDispatcher.forceRemoveDelegate(
  pDelegate: CCTouchDelegate);
var
  pHandler: CCTouchHandler;
  i: Integer;
begin
  if (m_pStandardHandlers <> nil) and (m_pStandardHandlers.count() > 0) then
  begin
    for i := 0 to m_pStandardHandlers.count()-1 do
    begin
      pHandler := CCTouchHandler(m_pStandardHandlers.objectAtIndex(i));
      if (pHandler <> nil) and (pHandler.getDelegate() = pDelegate) then
      begin
        m_pStandardHandlers.removeObject(pHandler);
        Break;
      end;
    end;
  end;

  if (m_pTargetedHandlers <> nil) and (m_pTargetedHandlers.count() > 0) then
  begin
    for i := 0 to m_pTargetedHandlers.count()-1 do
    begin
      pHandler := CCTouchHandler(m_pTargetedHandlers.objectAtIndex(i));
      if (pHandler <> nil) and (pHandler.getDelegate() = pDelegate) then
      begin
        m_pTargetedHandlers.removeObject(pHandler);
        Break;
      end;
    end;
  end;
end;

function CCTouchDispatcher.init: Boolean;
begin
  m_bDispatchEvents := True;
  m_pTargetedHandlers := CCArray.createWithCapacity(8);
  m_pTargetedHandlers.retain();
  m_pStandardHandlers := CCArray.createWithCapacity(4);
  m_pStandardHandlers.retain();
  m_pHandlersToAdd := CCArray.createWithCapacity(8);
  m_pHandlersToAdd.retain();

  m_pHandlersToRemove := ccCArrayNew(8);

  m_bToRemove := False;
  m_bToAdd := False;
  m_bToQuit := False;
  m_bLocked := False;

  m_sHandlerHelperData[CCTOUCHBEGAN].m_type := CCTOUCHBEGAN;
  m_sHandlerHelperData[CCTOUCHMOVED].m_type := CCTOUCHMOVED;
  m_sHandlerHelperData[CCTOUCHENDED].m_type := CCTOUCHENDED;
  m_sHandlerHelperData[CCTOUCHCANCELLED].m_type := CCTOUCHCANCELLED;

  Result := True;
end;

function CCTouchDispatcher.isDispatchEvents: Boolean;
begin
  Result := m_bDispatchEvents;
end;

procedure CCTouchDispatcher.rearrangeHandlers(pArray: CCArray);
begin
  ccArraySort(pArray.data, less);
end;

procedure CCTouchDispatcher.removeAllDelegates;
begin
  if not m_bLocked then
    forceRemoveAllDelegates()
  else
    m_bToQuit := True;
end;

procedure CCTouchDispatcher.removeDelegate(pDelegate: CCTouchDelegate);
var
  pHandler: CCTouchHandler;
begin
  if pDelegate = nil then
    Exit;

  if not m_bLocked then
  begin
    forceRemoveDelegate(pDelegate);
  end else
  begin
    pHandler := findHandler(m_pHandlersToAdd, pDelegate);
    if pHandler <> nil then
    begin
      m_pHandlersToAdd.removeObject(pHandler);
      Exit;
    end;
    ccCArrayAppendValue(m_pHandlersToRemove, Pointer(pDelegate));
    m_bToRemove := True;
  end;  
end;

procedure CCTouchDispatcher.setDispatchEvents(bDispatchEvents: Boolean);
begin
  m_bDispatchEvents := bDispatchEvents;
end;

procedure CCTouchDispatcher.setPriority(nPriority: Integer;
  pDelegate: CCTouchDelegate);
var
  handler: CCTouchHandler;
begin
  CCAssert(pDelegate <> nil, '');
  handler := Self.findHandler(pDelegate);
  CCAssert(handler <> nil, '');

  if handler.getPriority() <> nPriority then
  begin
    handler.setPriority(nPriority);
    Self.rearrangeHandlers(m_pTargetedHandlers);
    Self.rearrangeHandlers(m_pStandardHandlers);
  end;  
end;

procedure CCTouchDispatcher.touches(pTouches: CCSet; pEvent: CCEvent;
  uIndex: Cardinal);
var
  pMutableTouches: CCSet;
  uTargetedHandlersCount, uStandardHandlersCount: Cardinal;
  bNeedsMutableSet: Boolean;
  sHelper: ccTouchHandlerHelperData;
  pTouch: CCTouch;
  i, j: Integer;
  pHandler: CCTargetedTouchHandler;
  pStandardHandler: CCStandardTouchHandler;
  bClaimed: Boolean;
  pTouchHandler: CCTouchHandler;
begin
  CCAssert((uIndex < 4), '');

  m_bLocked := True;
  uTargetedHandlersCount := m_pTargetedHandlers.count();
  uStandardHandlersCount := m_pStandardHandlers.count();

  bNeedsMutableSet := (uTargetedHandlersCount > 0) and (uStandardHandlersCount > 0);
  if bNeedsMutableSet then
    pMutableTouches := pTouches.mutableCopy()
  else
    pMutableTouches := pTouches;

  sHelper := m_sHandlerHelperData[uIndex];

  if uTargetedHandlersCount > 0 then
  begin
    for i := 0 to pTouches.count()-1 do
    begin
      pTouch := CCTouch(pTouches.getObject(i));

      if (m_pTargetedHandlers <> nil) and (m_pTargetedHandlers.count() > 0) then
      begin
        for j := 0 to m_pTargetedHandlers.count()-1 do
        begin
          pHandler := CCTargetedTouchHandler(m_pTargetedHandlers.objectAtIndex(j));
          if pHandler = nil then
            Break;

          bClaimed := False;
          if uIndex = CCTOUCHBEGAN then
          begin
            bClaimed := pHandler.getDelegate().ccTouchBegan(pTouch, pEvent);

            if bClaimed then
            begin
              pHandler.getClaimedTouches().addObject(pTouch);
            end;  
          end else if pHandler.getClaimedTouches().ContainsObject(pTouch) then
          begin
            bClaimed := True;

            case sHelper.m_type of
              CCTOUCHMOVED:
                begin
                  pHandler.getDelegate().ccTouchMoved(pTouch, pEvent);
                end;
              CCTOUCHENDED:
                begin
                  pHandler.getDelegate().ccTouchEnded(pTouch, pEvent);
                  pHandler.getClaimedTouches().removeObject(pTouch);
                end;
              CCTOUCHCANCELLED:
                begin
                  pHandler.getDelegate().ccTouchCancelled(pTouch, pEvent);
                  pHandler.getClaimedTouches().removeObject(pTouch);
                end;
            end;
          end;

          if bClaimed and pHandler.isSwallowsTouches() then
          begin
            if bNeedsMutableSet then
            begin
              pMutableTouches.removeObject(pTouch);
            end;

            Break;
          end;
        end;
      end;
    end;
  end;

  if (uStandardHandlersCount > 0) and (pMutableTouches.count() > 0) then
  begin
    if (m_pStandardHandlers <> nil) and (m_pStandardHandlers.count() > 0) then
    begin
      for i := 0 to m_pStandardHandlers.count()-1 do
      begin
        pStandardHandler := CCStandardTouchHandler(m_pStandardHandlers.objectAtIndex(i));

        if pStandardHandler = nil then
          Break;

        case sHelper.m_type of
          CCTOUCHBEGAN: pStandardHandler.getDelegate().ccTouchesBegan(pMutableTouches, pEvent);
          CCTOUCHMOVED: pStandardHandler.getDelegate().ccTouchesMoved(pMutableTouches, pEvent);
          CCTOUCHENDED: pStandardHandler.getDelegate().ccTouchesEnded(pMutableTouches, pEvent);
          CCTOUCHCANCELLED: pStandardHandler.getDelegate().ccTouchesCancelled(pMutableTouches, pEvent);
        end;
      end;  
    end;  
  end;

  if bNeedsMutableSet then
    pMutableTouches.release();

  m_bLocked := False;
  if m_bToRemove then
  begin
    m_bToRemove := False;
    for i := 0 to m_pHandlersToRemove^.num-1 do
    begin
      forceRemoveDelegate(CCTouchDelegate(m_pHandlersToRemove.arr[i]));
    end;
    ccCArrayRemoveAllValues(m_pHandlersToRemove);
  end;

  if m_bToAdd then
  begin
    m_bToAdd := False;

    if (m_pHandlersToAdd <> nil) and (m_pHandlersToAdd.count() > 0) then
    begin
      for i := 0 to m_pHandlersToAdd.count()-1 do
      begin
        pTouchHandler := CCTouchHandler(m_pHandlersToAdd.objectAtIndex(i));

        if pTouchHandler = nil then
          Break;

        if pTouchHandler is CCTargetedTouchHandler then
        begin
          forceAddHandler(pTouchHandler, m_pTargetedHandlers);
        end else
        begin
          forceAddHandler(pTouchHandler, m_pStandardHandlers);
        end;
      end;
    end;

    m_pHandlersToAdd.removeAllObjects();
  end;

  if m_bToQuit then
  begin
    m_bToQuit := False;
    forceRemoveAllDelegates();
  end;  
end;

procedure CCTouchDispatcher.touchesBegan(touches: CCSet; pEvent: CCEvent);
begin
  if m_bDispatchEvents then
  begin
    Self.touches(touches, pEvent, CCTOUCHBEGAN);
  end;
end;

procedure CCTouchDispatcher.touchesCancelled(touches: CCSet;
  pEvent: CCEvent);
begin
  if m_bDispatchEvents then
  begin
    Self.touches(touches, pEvent, CCTOUCHCANCELLED);
  end;
end;

procedure CCTouchDispatcher.touchesEnded(touches: CCSet; pEvent: CCEvent);
begin
  if m_bDispatchEvents then
  begin
    Self.touches(touches, pEvent, CCTOUCHENDED);
  end;
end;

procedure CCTouchDispatcher.touchesMoved(touches: CCSet; pEvent: CCEvent);
begin
  if m_bDispatchEvents then
  begin
    Self.touches(touches, pEvent, CCTOUCHMOVED);
  end;
end;

end.
