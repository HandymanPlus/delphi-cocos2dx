(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Erawppa
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

unit Cocos2dx.CCNotificationCenter;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCArray;

type
  CCNotificationCenter = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedNotificationCenter(): CCNotificationCenter;
    class procedure purgeNotificationCenter();
    (** @brief Adds an observer for the specified target.
     *  @param target The target which wants to observe notification events.
     *  @param selector The callback function which will be invoked when the specified notification event was posted.
     *  @param name The name of this notification.
     *  @param obj The extra parameter which will be passed to the callback function.
     *)
    procedure addObserver(target: CCObject; selector: SEL_CallFuncO;
      const name: string; obj: CCObject);
    procedure removeObserver(target: CCObject; const name: string);
    procedure registerScriptObserver(target: CCObject; handler: Integer; const name: string);
    procedure unregisterScriptObserver(target: CCObject; const name: string);
    function removeAllObservers(target: CCObject): Integer;

    procedure postNotification(const name: string); overload;
    procedure postNotification(const name: string; pObject: CCObject); overload;
    function getScriptHandler(): Integer;
    function getObserverHandlerByName(const name: string): Integer;
  private
    m_observers: CCArray;
    m_scriptHandler: Integer;
    function observerExisted(target: CCObject; const name: string): Boolean;
  end;

  CCNotificationObserver = class(CCObject)
  private
    m_target: CCObject;
    m_selector: SEL_CallFuncO;
    m_name: string;
    m_object: CCObject;
    m_nHandler: Integer;
    function getName: string;
    function getObject: CCObject;
    function getSelector: SEL_CallFuncO;
    function getTarget: CCObject;
    function getHandler: Integer;
    procedure setHandler(const Value: Integer);
  public
    constructor Create(target: CCObject; selector: SEL_CallFuncO;
      const name: string; obj: CCObject);
    destructor Destroy(); override;
    procedure performSelector(obj: CCObject);
    property Target: CCObject read getTarget;
    property Selector: SEL_CallFuncO read getSelector;
    property Name: string read getName;
    property Obj: CCObject read getObject;
    property Handler: Integer read getHandler write setHandler;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCPlatformMacros;

{ CCNotificationCenter }

var s_sharedNotifCenter: CCNotificationCenter = nil;

procedure CCNotificationCenter.addObserver(target: CCObject;
  selector: SEL_CallFuncO; const name: string; obj: CCObject);
var
  observer: CCNotificationObserver;
begin
  if observerExisted(target, name) then
    Exit;

  observer := CCNotificationObserver.Create(target, selector, name, obj);
  if observer = nil then
    Exit;

  observer.autorelease();
  m_observers.addObject(observer);
end;

constructor CCNotificationCenter.Create;
begin
  m_scriptHandler := 0;
  m_observers := CCArray.createWithCapacity(3);
  m_observers.retain();
end;

destructor CCNotificationCenter.Destroy;
begin
  m_observers.release();
  inherited;
end;

function CCNotificationCenter.getObserverHandlerByName(
  const name: string): Integer;
var
  i: Integer;
  observer: CCNotificationObserver;
begin
  if name <> '' then
  begin
    Result := -1;
    Exit;
  end;

  if (m_observers <> nil) and (m_observers.count() > 0) then
  begin
    for i := 0 to m_observers.count()-1 do
    begin
      observer := CCNotificationObserver(m_observers.objectAtIndex(i));
      if observer = nil then
        Continue;

      if CompareText(observer.getName(), name) = 0 then
      begin
        Result := observer.getHandler();
        Exit;
      end;  
    end;  
  end;

  Result := -1;
end;

function CCNotificationCenter.getScriptHandler: Integer;
begin
  Result := m_scriptHandler;
end;

function CCNotificationCenter.observerExisted(target: CCObject;
  const name: string): Boolean;
var
  pObj: CCNotificationObserver;
  i: Integer;
begin
  if m_observers.count() > 0 then
  begin
    for i := 0 to m_observers.count()-1 do
    begin
      pObj := CCNotificationObserver(m_observers.objectAtIndex(i));
      if pObj = nil then
        Continue;

      if (CompareText(pObj.getName(), name) = 0) and (pObj.getTarget() = target) then
      begin
        Result := True;
        Exit;
      end;  
    end;
  end;
  
  Result := False;
end;

procedure CCNotificationCenter.postNotification(const name: string;
  pObject: CCObject);
var
  pObserver: CCNotificationObserver;
  i: Integer;
  ObserversCopy: CCArray;
begin
  ObserversCopy := CCArray.createWithCapacity(m_observers.count());
  ObserversCopy.addObjectsFromArray(m_observers);

  for i := 0 to ObserversCopy.count()-1 do
  begin
    pObserver := CCNotificationObserver(ObserversCopy.objectAtIndex(i));
    if pObserver = nil then
      Continue;

    if (CompareText(pObserver.getName(), name) = 0) and ( (pObserver.getObject = pObserver) or (pObserver.getObject() = nil) or (pObject = nil) ) then
    begin
      if pObserver.getHandler() <> 0 then
      begin

      end else
      begin
        pObserver.performSelector(pObject);
      end;    
    end;
  end;
end;

procedure CCNotificationCenter.postNotification(const name: string);
begin
  Self.postNotification(name, nil);
end;

class procedure CCNotificationCenter.purgeNotificationCenter;
begin
  CC_SAFE_RELEASE_NULL(CCObject(s_sharedNotifCenter));
end;

procedure CCNotificationCenter.registerScriptObserver(target: CCObject;
  handler: Integer; const name: string);
var
  observer: CCNotificationObserver;
begin
  if observerExisted(target, name) then
    Exit;

  observer := CCNotificationObserver.Create(target, nil, name, nil);
  if observer = nil then
    Exit;

  observer.setHandler(handler);
  observer.autorelease();
  m_observers.addObject(observer);
end;

function CCNotificationCenter.removeAllObservers(
  target: CCObject): Integer;
var
  toRemove: CCArray;
  observer: CCNotificationObserver;
  i: Cardinal;
begin
  toRemove := CCArray._Create();
  if (m_observers <> nil) and (m_observers.count() > 0) then
    for i := 0 to m_observers.count()-1 do
    begin
      observer := CCNotificationObserver(m_observers.objectAtIndex(i));
      if observer = nil then
        Continue;

      if observer.getTarget() = target then
        toRemove.addObject(observer);
    end;

  m_observers.removeObjectsInArray(toRemove);
  Result := toRemove.count();
end;

procedure CCNotificationCenter.removeObserver(target: CCObject;
  const name: string);
var
  pObserver: CCNotificationObserver;
  i: Integer;
begin
  for i := 0 to m_observers.count()-1 do
  begin
    pObserver := CCNotificationObserver(m_observers.objectAtIndex(i));
    if pObserver = nil then
      Continue;

    if (CompareText(pObserver.getName(), name) = 0) and (pObserver.getTarget() = target) then
    begin
      m_observers.removeObject(pObserver);
      Exit;
    end;  
  end;
end;

class function CCNotificationCenter.sharedNotificationCenter: CCNotificationCenter;
begin
  if s_sharedNotifCenter = nil then
    s_sharedNotifCenter := CCNotificationCenter.Create();
  Result := s_sharedNotifCenter;
end;

procedure CCNotificationCenter.unregisterScriptObserver(target: CCObject;
  const name: string);
var
  observer: CCNotificationObserver;
  i: Integer;
begin
  if (m_observers <> nil) and (m_observers.count() > 0) then
  begin
    for i := 0 to m_observers.count()-1 do
    begin
      observer := CCNotificationObserver(m_observers.objectAtIndex(i));
      if observer = nil then
        Continue;

      if (CompareText(observer.getName(), name) <> 0) and (observer.getTarget() = target) then
      begin
        m_observers.removeObject(observer);
      end;  
    end;  
  end;  
end;

{ CCNotificationObserver }

constructor CCNotificationObserver.Create(target: CCObject;
  selector: SEL_CallFuncO; const name: string; obj: CCObject);
begin
  m_target := target;
  m_selector := selector;
  m_object := obj;

  m_name := name;
end;

destructor CCNotificationObserver.Destroy;
begin

  inherited;
end;

function CCNotificationObserver.getHandler: Integer;
begin
  Result := m_nHandler;
end;

function CCNotificationObserver.getName: string;
begin
  Result := m_name;
end;

function CCNotificationObserver.getObject: CCObject;
begin
  Result := m_object;
end;

function CCNotificationObserver.getSelector: SEL_CallFuncO;
begin
  Result := m_selector;
end;

function CCNotificationObserver.getTarget: CCObject;
begin
  Result := m_target;
end;

procedure CCNotificationObserver.performSelector(obj: CCObject);
begin
  if m_target <> nil then
  begin
    if obj <> nil then
      m_selector(obj)
    else
      m_selector(m_object);
  end;  
end;

procedure CCNotificationObserver.setHandler(const Value: Integer);
begin
  m_nHandler := Value;
end;

end.
