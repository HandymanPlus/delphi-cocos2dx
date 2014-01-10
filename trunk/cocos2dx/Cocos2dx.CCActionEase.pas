(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2009 Jason Booth

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

(*
 * Elastic, Back and Bounce actions based on code from:
 * http://github.com/NikhilK/silverlightfx/
 *
 * by http://github.com/NikhilK
 *)

unit Cocos2dx.CCActionEase;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCAction, Cocos2dx.CCActionInterval;

type
  CCActionEase = class(CCActionInterval)
  public
    destructor Destroy(); override;

    function initWithAction(pAction: CCActionInterval): Boolean;

    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure startWithTarget(pTarget: CCObject{CCNode}); override;
    procedure stop(); override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;

    class function _create(pAction: CCActionInterval): CCActionEase;
    function getInnerAction(): CCActionInterval; virtual;
  protected
    m_pInner: CCActionInterval;
  end;

  CCEaseRateAction = class(CCActionEase)
  public
    destructor Destroy(); override;
    procedure setRate(rate: Single);
    function getRate(): Single;
    function initWithAction(pAction: CCActionInterval; fRate: Single): Boolean;

    function copyWithZone(pZone: CCZone): CCObject; override;
    function reverse(): CCFiniteTimeAction; override;

    class function _create(pAction: CCActionInterval; fRate: Single): CCEaseRateAction;
  protected
    m_fRate: Single;
  end;

  CCEaseOut = class(CCEaseRateAction)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval; fRate: Single): CCEaseOut;
  end;

  CCEaseIn = class(CCEaseRateAction)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval; fRate: Single): CCEaseIn;
  end;

  CCEaseInOut = class(CCEaseRateAction)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval; fRate: Single): CCEaseInOut;
  end;

  CCEaseExponentialIn = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseExponentialIn;
  end;

  CCEaseExponentialOut = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseExponentialOut;
  end;

  CCEaseExponentialInOut = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseExponentialInOut;
  end;

  CCEaseSineIn = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseSineIn;
  end;

  CCEaseSineOut = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseSineOut;
  end;

  CCEaseSineInOut = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseSineInOut;
  end;

  CCEaseElastic = class(CCActionEase)
  public
    function getPeriod(): Single;
    procedure setPeriod(fPeriod: Single);
    function initWithAction(pAction: CCActionInterval; fPeriod: Single = 0.3): Boolean;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseElastic; overload;
    class function _create(pAction: CCActionInterval; fPeriod: Single): CCEaseElastic; overload;
  protected
    m_fPeriod: Single;
  end;

  CCEaseElasticIn = class(CCEaseElastic)
  public
    procedure update(time: Single); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseElasticIn; overload;
    class function _create(pAction: CCActionInterval; fPeriod: Single): CCEaseElasticIn; overload;
  end;

  CCEaseElasticOut = class(CCEaseElastic)
  public
    procedure update(time: Single); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseElasticOut; overload;
    class function _create(pAction: CCActionInterval; fPeriod: Single): CCEaseElasticOut; overload;
  end;

  CCEaseElasticInOut = class(CCEaseElastic)
  public
    procedure update(time: Single); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseElasticInOut; overload;
    class function _create(pAction: CCActionInterval; fPeriod: Single): CCEaseElasticInOut; overload;
  end;

  CCEaseBounce = class(CCActionEase)
  public
    function bounceTime(time: Single): Single;
    function copyWithZone(pZone: CCZone): CCObject; override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseBounce;
  end;

  CCEaseBounceIn = class(CCEaseBounce)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseBounceIn;
  end;

  CCEaseBounceOut = class(CCEaseBounce)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseBounceOut;
  end;

  CCEaseBounceInOut = class(CCEaseBounce)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseBounceInOut;
  end;

  CCEaseBackIn = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseBackIn;
  end;

  CCEaseBackOut = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseBackOut;
  end;

  CCEaseBackInOut = class(CCActionEase)
  public
    function copyWithZone(pZone: CCZone): CCObject; override;
    procedure update(time: Single); override;
    function reverse(): CCFiniteTimeAction; override;
    class function _create(pAction: CCActionInterval): CCEaseBackInOut;
  end;

implementation
uses
  Math,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCCommon;

{ CCActionEase }

class function CCActionEase._create(
  pAction: CCActionInterval): CCActionEase;
var
  pRet: CCActionEase;
begin
  pRet := CCActionEase.Create;
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := pRet;
end;

function CCActionEase.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCActionEase;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCActionEase(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCActionEase.Create();
    pNewZone := CCZone.Create(pRet);
    pZone := pNewZone;
  end;

  inherited copyWithZone(pZone);

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

destructor CCActionEase.Destroy;
begin
  CC_SAFE_RELEASE(m_pInner);
  inherited;
end;

function CCActionEase.getInnerAction: CCActionInterval;
begin
  Result := m_pInner;
end;

function CCActionEase.initWithAction(pAction: CCActionInterval): Boolean;
begin
  CCAssert(pAction <> nil, '');
  if inherited initWithDuration(pAction.getDuration()) then
  begin
    m_pInner := pAction;
    pAction.retain();
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCActionEase.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCActionEase.startWithTarget(pTarget: CCObject);
begin
  inherited startWithTarget(pTarget);
  m_pInner.startWithTarget(m_pTarget);
end;

procedure CCActionEase.stop;
begin
  m_pInner.stop();
  inherited stop();
end;

procedure CCActionEase.update(time: Single);
begin
  m_pInner.update(time);
end;

{ CCEaseRateAction }

class function CCEaseRateAction._create(pAction: CCActionInterval;
  fRate: Single): CCEaseRateAction;
var
  pRet: CCEaseRateAction;
begin
  pRet := CCEaseRateAction.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fRate) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseRateAction.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseRateAction;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseRateAction(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseRateAction.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  //inherited copyWithZone(pZone);

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fRate );

  pNewZone.Free;

  Result := pRet;
end;

destructor CCEaseRateAction.Destroy;
begin

  inherited;
end;

function CCEaseRateAction.getRate: Single;
begin
  Result := m_fRate;
end;

function CCEaseRateAction.initWithAction(pAction: CCActionInterval;
  fRate: Single): Boolean;
begin
  if inherited initWithAction(pAction) then
  begin
    m_fRate := fRate;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCEaseRateAction.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()), 1/m_fRate);
end;

procedure CCEaseRateAction.setRate(rate: Single);
begin
  m_fRate := rate;
end;

{ CCEaseOut }

class function CCEaseOut._create(pAction: CCActionInterval;
  fRate: Single): CCEaseOut;
var
  pRet: CCEaseOut;
begin
  pRet := CCEaseOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fRate) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fRate );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseOut.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()), 1/m_fRate);
end;

procedure CCEaseOut.update(time: Single);
begin
  m_pInner.update(Power(time, 1/m_fRate));
end;

{ CCEaseIn }

class function CCEaseIn._create(pAction: CCActionInterval;
  fRate: Single): CCEaseIn;
var
  pRet: CCEaseIn;
begin
  pRet := CCEaseIn.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fRate) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseIn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseIn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseIn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseIn.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fRate );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseIn.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()), 1/m_fRate);
end;

procedure CCEaseIn.update(time: Single);
begin
  m_pInner.update(Power(time, m_fRate));
end;

{ CCEaseInOut }

class function CCEaseInOut._create(pAction: CCActionInterval;
  fRate: Single): CCEaseInOut;
var
  pRet: CCEaseInOut;
begin
  pRet := CCEaseInOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fRate) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseInOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseInOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseInOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseInOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fRate );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseInOut.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()), m_fRate);
end;

procedure CCEaseInOut.update(time: Single);
begin
  time := time * 2;
  if time < 1 then
    m_pInner.update(0.5 * Power(time, m_fRate))
  else
    m_pInner.update(1.0 - 0.5 * Power(2 - time, m_fRate))
end;

{ CCEaseExponentialIn }

class function CCEaseExponentialIn._create(
  pAction: CCActionInterval): CCEaseExponentialIn;
var
  pRet: CCEaseExponentialIn;
begin
  pRet := CCEaseExponentialIn.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseExponentialIn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseExponentialIn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseExponentialIn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseExponentialIn.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseExponentialIn.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseExponentialOut._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseExponentialIn.update(time: Single);
begin
  if time = 0 then
    m_pInner.update(0)
  else
    m_pInner.update(Power(2, 10 * (time/1 - 1)) - 1 * 0.001);
end;

{ CCEaseExponentialOut }

class function CCEaseExponentialOut._create(
  pAction: CCActionInterval): CCEaseExponentialOut;
var
  pRet: CCEaseExponentialOut;
begin
  pRet := CCEaseExponentialOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseExponentialOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseExponentialOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseExponentialOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseExponentialOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseExponentialOut.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseExponentialIn._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseExponentialOut.update(time: Single);
begin
  if time = 1 then
    m_pInner.update(1)
  else
    m_pInner.update( -Power(2, -10 * time / 1) + 1 );
end;

{ CCEaseExponentialInOut }

class function CCEaseExponentialInOut._create(
  pAction: CCActionInterval): CCEaseExponentialInOut;
var
  pRet: CCEaseExponentialInOut;
begin
  pRet := CCEaseExponentialInOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseExponentialInOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseExponentialInOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseExponentialInOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseExponentialInOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseExponentialInOut.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseExponentialInOut.update(time: Single);
begin
  time := time/0.5;
  if time < 1 then
    time := 0.5 * Power(2, 10 * (time - 1))
  else
    time := 0.5 * (-Power(2, -10 * (time - 1)) + 2);

  m_pInner.update(time);
end;

{ CCEaseSineIn }

class function CCEaseSineIn._create(
  pAction: CCActionInterval): CCEaseSineIn;
var
  pRet: CCEaseSineIn;
begin
  pRet := CCEaseSineIn.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseSineIn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseSineIn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseSineIn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseSineIn.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseSineIn.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseSineOut._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseSineIn.update(time: Single);
begin
  m_pInner.update(-1 * Cos(time * Pi / 2) + 1);
end;

{ CCEaseSineOut }

class function CCEaseSineOut._create(
  pAction: CCActionInterval): CCEaseSineOut;
var
  pRet: CCEaseSineOut;
begin
  pRet := CCEaseSineOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseSineOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseSineOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseSineOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseSineOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseSineOut.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseSineIn._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseSineOut.update(time: Single);
begin
  m_pInner.update(Sin(time * Pi / 2));
end;

{ CCEaseSineInOut }

class function CCEaseSineInOut._create(
  pAction: CCActionInterval): CCEaseSineInOut;
var
  pRet: CCEaseSineInOut;
begin
  pRet := CCEaseSineInOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseSineInOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseSineInOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseSineInOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseSineInOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseSineInOut.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseSineInOut.update(time: Single);
begin
  m_pInner.update(-0.5 * (Cos(Pi * time) - 1 ));
end;

{ CCEaseElastic }

class function CCEaseElastic._create(pAction: CCActionInterval;
  fPeriod: Single): CCEaseElastic;
var
  pRet: CCEaseElastic;
begin
  pRet := CCEaseElastic.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fPeriod) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCEaseElastic._create(
  pAction: CCActionInterval): CCEaseElastic;
begin
  Result := Self._create(pAction, 0.3);
end;

function CCEaseElastic.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseElastic;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseElastic(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseElastic.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fPeriod );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseElastic.getPeriod: Single;
begin
  Result := m_fPeriod;
end;

function CCEaseElastic.initWithAction(pAction: CCActionInterval;
  fPeriod: Single): Boolean;
begin
  if inherited initWithAction(pAction) then
  begin
    m_fPeriod := fPeriod;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function CCEaseElastic.reverse: CCFiniteTimeAction;
begin
  Result := nil; // override me
end;

procedure CCEaseElastic.setPeriod(fPeriod: Single);
begin
  m_fPeriod := fPeriod;
end;

{ CCEaseElasticIn }

class function CCEaseElasticIn._create(
  pAction: CCActionInterval): CCEaseElasticIn;
begin
  Result := Self._create(pAction, 0.3);
end;

class function CCEaseElasticIn._create(pAction: CCActionInterval;
  fPeriod: Single): CCEaseElasticIn;
var
  pRet: CCEaseElasticIn;
begin
  pRet := CCEaseElasticIn.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fPeriod) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseElasticIn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseElasticIn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseElasticIn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseElasticIn.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fPeriod );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseElasticIn.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseElasticOut._create(CCActionInterval(m_pInner.reverse()), m_fPeriod);
end;

procedure CCEaseElasticIn.update(time: Single);
var
  newT, s: Single;
begin
  if (time = 0) or (time = 1) then
  begin
    newT := time;
  end else
  begin
    s := m_fPeriod / 4;
    time := time - 1;
    newT := -Power(2, 10 * time) * Sin( (time - s) * Pi * 2 / m_fPeriod );
  end;
  m_pInner.update(newT);
end;

{ CCEaseElasticOut }

class function CCEaseElasticOut._create(
  pAction: CCActionInterval): CCEaseElasticOut;
begin
  Result := Self._create(pAction, 0.3);
end;

class function CCEaseElasticOut._create(pAction: CCActionInterval;
  fPeriod: Single): CCEaseElasticOut;
var
  pRet: CCEaseElasticOut;
begin
  pRet := CCEaseElasticOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fPeriod) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseElasticOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseElasticOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseElasticOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseElasticOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fPeriod );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseElasticOut.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseElasticIn._create(CCActionInterval(m_pInner.reverse()), m_fPeriod);
end;

procedure CCEaseElasticOut.update(time: Single);
var
  newT, s: Single;
begin
  if (time = 0) or (time = 1) then
  begin
    newT := time;
  end else
  begin
    s := m_fPeriod / 4;
    newT := Power(2, -10 * time) * Sin( (time - s) * Pi * 2 / m_fPeriod ) + 1;
  end;
  m_pInner.update(newT);
end;

{ CCEaseElasticInOut }

class function CCEaseElasticInOut._create(
  pAction: CCActionInterval): CCEaseElasticInOut;
begin
  Result := Self._create(pAction, 0.3);
end;

class function CCEaseElasticInOut._create(pAction: CCActionInterval;
  fPeriod: Single): CCEaseElasticInOut;
var
  pRet: CCEaseElasticInOut;
begin
  pRet := CCEaseElasticInOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction, fPeriod) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseElasticInOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseElasticInOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseElasticInOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseElasticInOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()), m_fPeriod );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseElasticInOut.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()), m_fPeriod);
end;

procedure CCEaseElasticInOut.update(time: Single);
var
  newT, s: Single;
begin
  if (time = 0) or (time = 1) then
  begin
    newT := time;
  end else
  begin
    time := time * 2;
    if IsZero(m_fPeriod) then
    begin
      m_fPeriod := 0.3 * 1.5;
    end;

    s := m_fPeriod / 4;

    time := time - 1;
    if time < 0 then
    begin
      newT := -0.5 * Power(2, 10 * time) * Sin( (time - s) * Pi * 2 / m_fPeriod );
    end else
    begin
      newT := Power(2, -10 * time) * Sin((time - s) * Pi * 2 / m_fPeriod) * 0.5 + 1;
    end;
  end;
  m_pInner.update(newT);
end;

{ CCEaseBounce }

class function CCEaseBounce._create(
  pAction: CCActionInterval): CCEaseBounce;
var
  pRet: CCEaseBounce;
begin
  pRet := CCEaseBounce.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseBounce.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseBounce;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseBounce(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseBounce.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseBounce.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()));
end;

function CCEaseBounce.bounceTime(time: Single): Single;
begin
  if time < 1 / 2.75 then
  begin
    Result := 7.5625 * time * time;
  end else if time < 2 / 2.75 then
  begin
    time := time - 1.5 / 2.75;
    Result := 7.5625 * time * time + 0.75;
  end else if time < 2.5 / 2.75 then
  begin
    time := time - 2.25 / 2.75;
    Result := 7.5625 * time * time + 0.9375;
  end else
  begin
    time := time - 2.625 / 2.75;
    Result := 7.5625 * time * time + 0.984375;
  end;  
end;

{ CCEaseBounceIn }

class function CCEaseBounceIn._create(
  pAction: CCActionInterval): CCEaseBounceIn;
var
  pRet: CCEaseBounceIn;
begin
  pRet := CCEaseBounceIn.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseBounceIn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseBounceIn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseBounceIn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseBounceIn.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseBounceIn.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseBounceOut._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseBounceIn.update(time: Single);
var
  newT: Single;
begin
  newT := 1 - bounceTime(1 - time);
  m_pInner.update(newT);
end;

{ CCEaseBounceOut }

class function CCEaseBounceOut._create(
  pAction: CCActionInterval): CCEaseBounceOut;
var
  pRet: CCEaseBounceOut;
begin
  pRet := CCEaseBounceOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseBounceOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseBounceOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseBounceOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseBounceOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseBounceOut.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseBounceIn._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseBounceOut.update(time: Single);
var
  newT: Single;
begin
  newT := bounceTime(time);
  m_pInner.update(newT);
end;

{ CCEaseBounceInOut }

class function CCEaseBounceInOut._create(
  pAction: CCActionInterval): CCEaseBounceInOut;
var
  pRet: CCEaseBounceInOut;
begin
  pRet := CCEaseBounceInOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseBounceInOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseBounceInOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseBounceInOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseBounceInOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseBounceInOut.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseBounceInOut.update(time: Single);
var
  newT: Single;
begin
  if time < 0.5 then
  begin
    time := time * 2;
    newT := (1 - bounceTime(1 - time)) * 0.5
  end else
  begin
    newT := bounceTime(time * 2 - 1) * 0.5 + 0.5;
  end;
  m_pInner.update(newT);
end;

{ CCEaseBackIn }

class function CCEaseBackIn._create(
  pAction: CCActionInterval): CCEaseBackIn;
var
  pRet: CCEaseBackIn;
begin
  pRet := CCEaseBackIn.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseBackIn.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseBackIn;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseBackIn(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseBackIn.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseBackIn.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseBackOut._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseBackIn.update(time: Single);
var
  overshoot: Single;
begin
  overshoot := 1.70158;
  m_pInner.update(time * time * ((overshoot + 1) * time - overshoot) );
end;

{ CCEaseBackOut }

class function CCEaseBackOut._create(
  pAction: CCActionInterval): CCEaseBackOut;
var
  pRet: CCEaseBackOut;
begin
  pRet := CCEaseBackOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseBackOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseBackOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseBackOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseBackOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseBackOut.reverse: CCFiniteTimeAction;
begin
  Result := CCEaseBackIn._create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseBackOut.update(time: Single);
var
  overshoot: Single;
begin
  overshoot := 1.70158;
  time := time - 1;
  m_pInner.update(time * time * ((overshoot + 1) * time + overshoot) + 1 );
end;

{ CCEaseBackInOut }

class function CCEaseBackInOut._create(
  pAction: CCActionInterval): CCEaseBackInOut;
var
  pRet: CCEaseBackInOut;
begin
  pRet := CCEaseBackInOut.Create();
  if (pRet <> nil) and pRet.initWithAction(pAction) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCEaseBackInOut.copyWithZone(pZone: CCZone): CCObject;
var
  pNewZone: CCZone;
  pRet: CCEaseBackInOut;
begin
  pNewZone := nil;

  if (pZone <> nil) and (pZone.m_pCopyObject <> nil) then
  begin
    pRet := CCEaseBackInOut(pZone.m_pCopyObject);
  end else
  begin
    pRet := CCEaseBackInOut.Create();
    pNewZone := CCZone.Create(pRet);
  end;

  pRet.initWithAction( CCActionInterval(m_pInner.copy().autorelease()) );

  pNewZone.Free;

  Result := pRet;
end;

function CCEaseBackInOut.reverse: CCFiniteTimeAction;
begin
  Result := _create(CCActionInterval(m_pInner.reverse()));
end;

procedure CCEaseBackInOut.update(time: Single);
var
  overshoot: Single;
begin
  overshoot := 1.70158 * 1.525;
  time := time * 2;
  if time < 1 then
  begin
    m_pInner.update((time * time * ((overshoot + 1) * time - overshoot)) / 2);
  end else
  begin
    time := time - 2;
    m_pInner.update((time * time * ((overshoot + 1) * time + overshoot)) / 2 + 1);
  end;  
end;

end.
