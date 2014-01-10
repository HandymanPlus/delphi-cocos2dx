(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (C) 2010      Lam Pham

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

unit Cocos2dx.CCActionProgressTimer;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCAction;

type
  CCProgressTo = class(CCActionInterval)
  public
    function initWithDuration(duration, fPercent: Single): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    class function _create(duration, fPercent: Single): CCProgressTo;
  protected
    m_fTo, m_fFrom: Single;
  end;

  CCProgressFromTo = class(CCActionInterval)
  public
    function initWithDuration(duration, fFromPercentage, fToPercentage: Single): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(duration, fFromPercentage, fToPercentage: Single): CCProgressFromTo;
  protected
    m_fTo, m_fFrom: Single;
  end;

implementation
uses
  Cocos2dx.CCProgressTimer;

{ CCProgressTo }

class function CCProgressTo._create(duration,
  fPercent: Single): CCProgressTo;
var
  pRet: CCProgressTo;
begin
  pRet := CCProgressTo.Create;
  pRet.initWithDuration(duration, fPercent);
  pRet.autorelease();
  Result := pRet;
end;

function CCProgressTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCProgressTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCProgressTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCProgressTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fTo);

  pNewZone.Free;

  Result := pRet;
end;

function CCProgressTo.initWithDuration(duration,
  fPercent: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fTo := fPercent;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCProgressTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_fFrom := CCProgressTimer(pTarget).getPercentage();
  if m_fFrom = 100 then
    m_fFrom := 0;
end;

procedure CCProgressTo.update(time: Single);
begin
  CCProgressTimer(m_pTarget).setPercentage(m_fFrom + (m_fTo - m_fFrom) * time);
end;

{ CCProgressFromTo }

function CCProgressFromTo.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCProgressFromTo;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCProgressFromTo(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCProgressFromTo.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);
  pRet.initWithDuration(m_fDuration, m_fFrom, m_fTo);

  pNewZone.Free;

  Result := pRet;
end;

function CCProgressFromTo.initWithDuration(duration, fFromPercentage,
  fToPercentage: Single): Boolean;
begin
  if inherited initWithDuration(duration) then
  begin
    m_fTo := fToPercentage;
    m_fFrom := fFromPercentage;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCProgressFromTo.reverse: CCFiniteTimeAction;
begin
  Result := _create(m_fDuration, m_fTo, m_fFrom);
end;

procedure CCProgressFromTo.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
end;

procedure CCProgressFromTo.update(time: Single);
begin
  CCProgressTimer(m_pTarget).setPercentage(m_fFrom + (m_fTo - m_fFrom) * time);
end;

class function CCProgressFromTo._create(duration, fFromPercentage,
  fToPercentage: Single): CCProgressFromTo;
var
  pRet: CCProgressFromTo;
begin
  pRet := CCProgressFromTo.Create;
  pRet.initWithDuration(duration, fFromPercentage, fToPercentage);
  pRet.autorelease();

  Result := pRet;
end;

end.
