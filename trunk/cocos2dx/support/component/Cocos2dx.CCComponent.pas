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

unit Cocos2dx.CCComponent;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCNode;

type
  CCComponent = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(): CCComponent;
    function init(): Boolean; virtual;
    procedure onEnter(); virtual;
    procedure onExit(); virtual;
    procedure serialize(r: Pointer); virtual;
    function isEnabled(): Boolean; virtual;
    procedure setEnabled(b: Boolean); virtual;
    function getNode(): CCNode; virtual;
    procedure setNode(pNode: CCNode); virtual;
    function getName(): string;
    procedure setName(const pName: string);
    procedure setOwner(pOwner: CCNode);
    function getOwner(): CCNode;
  protected
    m_pOwner: CCNode;
    m_strName: string;
    m_bEnabled: Boolean;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCComponent }

class function CCComponent._create: CCComponent;
var
  pRet: CCComponent;
begin
  pRet := CCComponent.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCComponent.Create;
begin

end;

destructor CCComponent.Destroy;
begin

  inherited;
end;

function CCComponent.getName: string;
begin
  Result := m_strName;
end;

function CCComponent.getNode: CCNode;
begin
  Result := nil;
end;

function CCComponent.getOwner: CCNode;
begin
  Result := m_pOwner;
end;

function CCComponent.init: Boolean;
begin
  Result := True;
end;

procedure CCComponent.onEnter;
begin

end;

procedure CCComponent.onExit;
begin

end;

procedure CCComponent.serialize(r: Pointer);
begin

end;

procedure CCComponent.setEnabled(b: Boolean);
begin
  m_bEnabled := b;
end;

procedure CCComponent.setName(const pName: string);
begin
  m_strName := pName;
end;

procedure CCComponent.setNode(pNode: CCNode);
begin

end;

procedure CCComponent.setOwner(pOwner: CCNode);
begin
  m_pOwner := pOwner;
end;

function CCComponent.isEnabled: Boolean;
begin
  Result := m_bEnabled;
end;

end.
