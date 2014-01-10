(*
 * Copyright (c) 2012 cocos2d-x.org
 * http://www.cocos2d-x.org
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * Converted to c++ / cocos2d-x by Angus C
 *)
(*
 *
 * Helper class to store targets and selectors (and eventually, params?) in the same CCMutableArray. Basically a very crude form of a NSInvocation
 *)

unit Cocos2dx.CCInvocation;

interface
uses
  Cocos2dx.CCObject;

type
  CCControlEvent = Cardinal;
  SEL_CCControlHandler = procedure (pSender: CCObject; event: CCControlEvent) of object;

  CCInvocation = class(CCObject)
  private
    m_action: SEL_CCControlHandler;
    m_target: CCObject;
    m_controlEvent: CCControlEvent;
  public
    constructor Create(target: CCObject; action: SEL_CCControlHandler; controlEvent: CCControlEvent);
    class function _create(target: CCObject; action: SEL_CCControlHandler; controlEvent: CCControlEvent): CCInvocation;
    procedure invoke(pSender: CCObject);
    function GetAction: SEL_CCControlHandler;
    function getControlEvent: CCControlEvent;
    function getObject: CCObject;
  public
    property Action: SEL_CCControlHandler read GetAction;
    property Target: CCObject read getObject;
    property ControlEvent: CCControlEvent read getControlEvent;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCInvocation }

class function CCInvocation._create(target: CCObject;
  action: SEL_CCControlHandler;
  controlEvent: CCControlEvent): CCInvocation;
var
  pRet: CCInvocation;
begin
  pRet := CCInvocation.Create(target, action, controlEvent);
  if pRet <> nil then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCInvocation.Create(target: CCObject;
  action: SEL_CCControlHandler; controlEvent: CCControlEvent);
begin
  inherited Create();
  m_target := target;
  m_action := action;
  m_controlEvent := controlEvent;
end;

function CCInvocation.GetAction: SEL_CCControlHandler;
begin
  Result := m_action;
end;

function CCInvocation.getControlEvent: CCControlEvent;
begin
  Result := m_controlEvent;
end;

function CCInvocation.getObject: CCObject;
begin
  Result := m_target;
end;

procedure CCInvocation.invoke(pSender: CCObject);
begin
  if (m_target <> nil) and (@m_action <> nil) then
    m_action(pSender, m_controlEvent);
end;

end.
