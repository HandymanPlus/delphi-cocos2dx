(****************************************************************************
Copyright (c) 2013 cocos2d-x.org

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

unit Cocos2dx.CCComponentContainer;

interface
uses
  Cocos2dx.CCNode, Cocos2dx.CCDictionary, Cocos2dx.CCComponent;

type
  CCComponentContainer = class
  public
    constructor Create(pNode: CCNode);
    destructor Destroy(); override;
    function get(const pName: string): CCComponent; virtual;
    function add(pCom: CCComponent): Boolean; virtual;
    function remove(const pName: string): Boolean; virtual;
    procedure removeAll(); virtual;
    procedure visit(fDelta: Single); virtual;
    function isEmpty(): Boolean;
  private
    //procedure alloc();
  private
    m_pComponents: CCDictionary;
    m_pOwner: CCNode;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCObject, tdHashChain;

{ CCComponentContainer }

function CCComponentContainer.add(pCom: CCComponent): Boolean;
var
  bRet: Boolean;
  pComponent: CCComponent;
begin
  bRet := False;
  CCAssert(pCom <> nil, 'Argument must be non-nil');
  CCAssert(pCom.getOwner() = nil, 'Component already added. It can not be added again');
  repeat
    if m_pComponents = nil then
    begin
      m_pComponents := CCDictionary._create();
      m_pComponents.retain();
      m_pOwner.scheduleUpdate();
    end;

    pComponent := CCComponent(m_pComponents.objectForKey(pCom.getName()));
    CCAssert(pComponent = nil, 'Component already added. It can not be added again');
    if pComponent <> nil then
      Break;
    pCom.setOwner(m_pOwner);
    m_pComponents.setObject(pCom, pCom.getName());
    pCom.onEnter();
    bRet := True;
  until True;
  
  Result := bRet;
end;

{procedure CCComponentContainer.alloc;
begin
  m_pComponents := CCDictionary._create();
  m_pComponents.retain();
end;}

constructor CCComponentContainer.Create(pNode: CCNode);
begin
  m_pOwner := pNode;
end;

destructor CCComponentContainer.Destroy;
begin
  CC_SAFE_RELEASE(m_pComponents);
  inherited;
end;

function CCComponentContainer.get(const pName: string): CCComponent;
var
  pRet: CCComponent;
begin
  pRet := nil;
  CCAssert(pName <> '', 'Argument must be non-nil');
  repeat
    if pName = '' then
      Break;
    if m_pComponents = nil then
      Break;
    pRet := CCComponent(m_pComponents.objectForKey(pName));
  until True;
  Result := pRet;
end;

function CCComponentContainer.isEmpty: Boolean;
begin
  Result := not ((m_pComponents <> nil) and (m_pComponents.count() > 0));
end;

function CCComponentContainer.remove(const pName: string): Boolean;
var
  bRet: Boolean;
  pRetObject: CCObject;
  com: CCComponent;
begin
  bRet := False;
  CCAssert(pName <> '', 'Argument must be non-nil');
  repeat
    if m_pComponents = nil then
      Break;
    pRetObject := m_pComponents.objectForKey(pName);
    if pRetObject = nil then
      Break;
    com := CCComponent(pRetObject);
    com.onExit();
    com.setOwner(nil);
    m_pComponents.removeObjectForKey(pName);
    bRet := True;
  until True;

  Result := bRet;
end;

procedure CCComponentContainer.removeAll;
var
  pElement: THashElement;
begin
  if m_pComponents <> nil then
  begin
    pElement := m_pComponents.First();
    while pElement <> nil do
    begin
      CCComponent(pElement.pObj).onExit();
      CCComponent(pElement.pObj).setOwner(nil);
      m_pComponents.removeObjectForElement(pElement);
      pElement := m_pComponents.Next();
    end;

    m_pOwner.unscheduleUpdate();
  end;  
end;

procedure CCComponentContainer.visit(fDelta: Single);
var
  pElement: THashElement;
begin
  if m_pComponents <> nil then
  begin
    pElement := m_pComponents.First();
    while pElement <> nil do
    begin
      CCObject(pElement.pObj).update(fDelta);
      pElement := m_pComponents.Next();
    end;  
  end;  
end;

end.
