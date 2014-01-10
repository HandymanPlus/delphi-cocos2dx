(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright 2009 lhunath (Maarten Billemont)

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

unit Cocos2dx.CCActionTween;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCAction;

type
  CCActionTweenDelegate = class
  public
    procedure updateTweenAction(value: Single; const key: string); virtual; abstract;
  end;

  (** CCActionTween

   CCActionTween is an action that lets you update any property of an object.
   For example, if you want to modify the "width" property of a target from 200 to 300 in 2 seconds, then:

      id modifyWidth = [CCActionTween actionWithDuration:2 key:@"width" from:200 to:300];
      [target runAction:modifyWidth];


   Another example: CCScaleTo action could be rewritten using CCPropertyAction:

      // scaleA and scaleB are equivalents
      id scaleA = [CCScaleTo actionWithDuration:2 scale:3];
      id scaleB = [CCActionTween actionWithDuration:2 key:@"scale" from:1 to:3];


   @since v0.99.2
   *)
  CCActionTween = class(CCActionInterval)
  public
    class function _create(aDuration: Single; const key: string; from, _to: Single): CCActionTween;
    function initWithDuration(aDuration: Single; const key: string; from, _to: Single): Boolean;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
  public
    m_strKey: string;
    m_fFrom, m_fTo: Single;
    m_fDelta: Single;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros;

{ CCActionTween }

class function CCActionTween._create(aDuration: Single; const key: string;
  from, _to: Single): CCActionTween;
var
  pRet: CCActionTween;
begin
  pRet := CCActionTween.Create;
  if (pRet <> nil) and pRet.initWithDuration(aDuration, key, from, _to) then
    pRet.autorelease()
  else
    CC_SAFE_DELETE(pRet);
  Result := pRet;

end;

function CCActionTween.initWithDuration(aDuration: Single;
  const key: string; from, _to: Single): Boolean;
begin
  if inherited initWithDuration(aDuration) then
  begin
    m_strKey := key;
    m_fTo := _to;
    m_fFrom := from;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCActionTween.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, m_strKey, m_fTo, m_fFrom);
end;

procedure CCActionTween.startWithTarget(pTarget: CCObject);
begin
  //CCAssert(pTarget is CCActionTweenDelegate, 'target must implement CCActionTweenDelegate');
  inherited startWithTarget(pTarget);
  m_fDelta := m_fTo - m_fFrom;
end;

procedure CCActionTween.update(time: Single);
begin
  CCActionTweenDelegate(m_pTarget).updateTweenAction(m_fTo - m_fDelta * (1 - time), m_strKey);
end;

end.
