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

unit Cocos2dx.CCObject;

interface

{$I config.inc}

type
  CCObject = class;

  CCZone = class
  public
    m_pCopyObject: CCObject;
    constructor Create(pObject: CCObject = nil);
  end;

  TInterfaceObjectNull = class(TObject, IInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  CCCopying = class(TInterfaceObjectNull)
  public
    function copyWithZone(pZone: CCZone): CCObject; virtual;
  end;

  IObjectFunc = interface
    procedure release();
    procedure retain();
    function isSingleReference(): Boolean;
    function retainCount(): Integer;
  end;

  CCObject = class(CCCopying, IObjectFunc)
  public
    m_uID: Cardinal;
    m_nLuaID: Integer;
  public
    m_uReference: Cardinal;
    m_uAutoReleaseCount: Cardinal;
    //m_strName: string;
  public
    procedure release();
    procedure retain();
    function isSingleReference(): Boolean;
    function retainCount(): Integer;
  public
    constructor Create();
    destructor Destroy(); override;
    function autorelease(): CCObject;
    function copy(): CCObject;
    function isEqual(pObject: CCObject): Boolean; virtual;
    procedure update(dt: Single); virtual;
  end;
  
  CCEvent = class(CCObject)
  end;

  SEL_SCHEDULE = procedure (dt: Single) of object;
  SEL_CallFunc = procedure () of object;
  SEL_CallFuncN = procedure (pNode: CCObject{CCNode}) of object;
  SEL_CallFuncND = procedure (pNode: CCObject{CCNode}; data: Pointer) of object;
  SEL_CallFuncO = procedure (pObj: CCObject) of object;
  SEL_MenuHandler = procedure (pObj: CCObject) of object;
  SEL_EventHandler = procedure (pEvent: CCEvent) of object;
  SEL_Compare = function (pObj: CCObject): Integer of object;

implementation
uses
  Cocos2dx.CCAutoreleasePool, Cocos2dx.CCPlatformMacros;

var uObjectCount: Cardinal = 0;

{ CCZone }

constructor CCZone.Create(pObject: CCObject);
begin
  m_pCopyObject := pObject;
end;

{ CCCopying }

function CCCopying.copyWithZone(pZone: CCZone): CCObject;
begin
  Result := nil;
end;

{ CCObject }

function CCObject.autorelease: CCObject;
begin
  {$ifdef IOS}
  {$else}
  CCPoolManager.sharedPoolManager.addObject(Self);
  {$endif}
  Result := Self;
end;

function CCObject.copy: CCObject;
begin
  Result := copyWithZone(nil);
end;

constructor CCObject.Create;
begin
  inherited Create();
  Inc(uObjectCount);
  m_uID := uObjectCount;
  m_nLuaID := 0;
  m_uReference := 1; // when the object is created, the reference count of it is 1
  m_uAutoReleaseCount := 0;
end;

destructor CCObject.Destroy;
begin
  // if the object is managed, we should remove it
  // from pool manager
  if m_uAutoReleaseCount > 0 then
  begin
    CCPoolManager.sharedPoolManager().removeObject(Self);
  end;

  if m_nLuaID > 0 then
  begin

  end else
  begin

  end;      
  inherited;
end;

function CCObject.isEqual(pObject: CCObject): Boolean;
begin
  Result := pObject = Self;
end;

function CCObject.isSingleReference: Boolean;
begin
  Result := m_uReference = 1;
end;

procedure CCObject.release;
begin
  CCAssert(m_uReference > 0, 'reference count should greater than 0');
  Dec(m_uReference);
  if m_uReference < 1 then
  {$ifdef IOS} DisposeOf; {$else} Free; {$endif}
end;

procedure CCObject.retain;
begin
  CCAssert(m_uReference > 0, 'reference count should greater than 0');
  Inc(m_uReference);
end;

function CCObject.retainCount: Integer;
begin
  Result := m_uReference;
end;

procedure CCObject.update(dt: Single);
begin
//nothing
end;

{ TInterfaceObjectNull }

function TInterfaceObjectNull._AddRef: Integer;
begin
  Result := -1;
end;

function TInterfaceObjectNull._Release: Integer;
begin
  Result := -1;
end;

function TInterfaceObjectNull.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

end.
