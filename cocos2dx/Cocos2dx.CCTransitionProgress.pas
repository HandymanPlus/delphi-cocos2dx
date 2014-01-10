(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009 Lam Pham
Copyright (c) 2012 Ricardo Quesada

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

unit Cocos2dx.CCTransitionProgress;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCScene, Cocos2dx.CCTransition, Cocos2dx.CCProgressTimer,
  Cocos2dx.CCRenderTexture;

type
  CCTransitionProgress = class(CCTransitionScene)
  public
    constructor Create();
    procedure onEnter(); override;
    procedure onExit(); override;
    class function _create(t: Single; scene: CCScene): CCTransitionProgress;
  protected
    function progressTimerNodeWithRenderTexture(texture: CCRenderTexture): CCProgressTimer; virtual;
    procedure setupTransition(); virtual;
    procedure sceneOrder(); override;
  protected
    m_fTo, m_fFrom: Single;
    m_pSceneToBeModified: CCScene;
  end;

  CCTransitionProgressRadialCCW = class(CCTransitionProgress)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionProgressRadialCCW;
  protected
    function progressTimerNodeWithRenderTexture(texture: CCRenderTexture): CCProgressTimer; override;
  end;

  CCTransitionProgressRadialCW = class(CCTransitionProgress)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionProgressRadialCW;
  protected
    function progressTimerNodeWithRenderTexture(texture: CCRenderTexture): CCProgressTimer; override;
  end;

  CCTransitionProgressHorizontal = class(CCTransitionProgress)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionProgressHorizontal;
  protected
    function progressTimerNodeWithRenderTexture(texture: CCRenderTexture): CCProgressTimer; override;
  end;

  CCTransitionProgressVertical = class(CCTransitionProgress)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionProgressVertical;
  protected
    function progressTimerNodeWithRenderTexture(texture: CCRenderTexture): CCProgressTimer; override;
  end;

  CCTransitionProgressInOut = class(CCTransitionProgress)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionProgressInOut;
  protected
    function progressTimerNodeWithRenderTexture(texture: CCRenderTexture): CCProgressTimer; override;
    procedure setupTransition(); override;
    procedure sceneOrder(); override;
  end;

  CCTransitionProgressOutIn = class(CCTransitionProgress)
  public
    class function _create(t: Single; scene: CCScene): CCTransitionProgressOutIn;
  protected
    function progressTimerNodeWithRenderTexture(texture: CCRenderTexture): CCProgressTimer; override;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCDirector, Cocos2dx.CCGeometry,
  Cocos2dx.CCPointExtension, Cocos2dx.CCAction, Cocos2dx.CCActionInterval,
  Cocos2dx.CCActionInstant, Cocos2dx.CCActionProgressTimer;


const kCCSceneRadial = $c001;

{ CCTransitionProgress }

class function CCTransitionProgress._create(t: Single;
  scene: CCScene): CCTransitionProgress;
var
  pRet: CCTransitionProgress;
begin
  pRet := CCTransitionProgress.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCTransitionProgress.Create;
begin
  inherited Create();
end;

procedure CCTransitionProgress.onEnter;
var
  size: CCSize;
  texture: CCRenderTexture;
  pNode: CCProgressTimer;
  layerAtion: CCFiniteTimeAction;
begin
  inherited onEnter();
  setupTransition();

  size := CCDirector.sharedDirector().getWinSize();
  texture := CCRenderTexture._create(Round(size.width), Round(size.height));
  texture.Sprite.setAnchorPoint( ccp(0.5, 0.5) );
  texture.setPosition( ccp(size.width/2, size.height/2) );
  texture.AnchorPoint := ccp(0.5, 0.5);

  texture.clear(0, 0, 0, 1);
  texture._begin();
  m_pSceneToBeModified.visit();
  texture._end();

  if m_pSceneToBeModified = m_pOutScene then
  begin
    hideOutShowIn();
  end;

  pNode := progressTimerNodeWithRenderTexture(texture);

  layerAtion := CCSequence._create([ CCProgressFromTo._create(m_fDuration, m_fFrom, m_fTo), CCCallFunc._create(Self, finish) ]);
  pNode.runAction(layerAtion);

  addChild(pNode, 2, kCCSceneRadial);
end;

procedure CCTransitionProgress.onExit;
begin
  removeChildByTag(kCCSceneRadial, True);
  inherited onExit();
end;

function CCTransitionProgress.progressTimerNodeWithRenderTexture(
  texture: CCRenderTexture): CCProgressTimer;
begin
  Result := nil;
end;

procedure CCTransitionProgress.sceneOrder;
begin
  m_bIsInSceneOnTop := False;
end;

procedure CCTransitionProgress.setupTransition;
begin
  m_pSceneToBeModified := m_pOutScene;
  m_fFrom := 100;
  m_fTo := 0;
end;

{ CCTransitionProgressRadialCCW }

class function CCTransitionProgressRadialCCW._create(t: Single;
  scene: CCScene): CCTransitionProgressRadialCCW;
var
  pRet: CCTransitionProgressRadialCCW;
begin
  pRet := CCTransitionProgressRadialCCW.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionProgressRadialCCW.progressTimerNodeWithRenderTexture(
  texture: CCRenderTexture): CCProgressTimer;
var
  size: CCSize;
  pNode: CCProgressTimer;
begin
  size := CCDirector.sharedDirector().getWinSize();
  pNode := CCProgressTimer._create(texture.Sprite);
  pNode.getSprite().setFlipY(True);
  pNode.setType(kCCProgressTimerTypeRadial);

  pNode.setReverseDirection(False);
  pNode.setPercentage(100);
  pNode.setPosition(ccp(size.width/2, size.height/2));
  pNode.AnchorPoint := ccp(0.5, 0.5);

  Result := pNode;
end;

{ CCTransitionProgressRadialCW }

class function CCTransitionProgressRadialCW._create(t: Single;
  scene: CCScene): CCTransitionProgressRadialCW;
var
  pRet: CCTransitionProgressRadialCW;
begin
  pRet := CCTransitionProgressRadialCW.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionProgressRadialCW.progressTimerNodeWithRenderTexture(
  texture: CCRenderTexture): CCProgressTimer;
var
  size: CCSize;
  pNode: CCProgressTimer;
begin
  size := CCDirector.sharedDirector().getWinSize();
  pNode := CCProgressTimer._create(texture.Sprite);
  pNode.getSprite().setFlipY(True);
  pNode.setType(kCCProgressTimerTypeRadial);

  pNode.setReverseDirection(True);
  pNode.setPercentage(100);
  pNode.setPosition(ccp(size.width/2, size.height/2));
  pNode.AnchorPoint := ccp(0.5, 0.5);

  Result := pNode;
end;

{ CCTransitionProgressHorizontal }

class function CCTransitionProgressHorizontal._create(t: Single;
  scene: CCScene): CCTransitionProgressHorizontal;
var
  pRet: CCTransitionProgressHorizontal;
begin
  pRet := CCTransitionProgressHorizontal.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionProgressHorizontal.progressTimerNodeWithRenderTexture(
  texture: CCRenderTexture): CCProgressTimer;
var
  size: CCSize;
  pNode: CCProgressTimer;
begin
  size := CCDirector.sharedDirector().getWinSize();
  pNode := CCProgressTimer._create(texture.Sprite);
  pNode.getSprite().setFlipY(True);
  pNode.setType(kCCProgressTimerTypeBar);
  pNode.Midpoint := ccp(1, 0);
  pNode.BarChangeRate := ccp(1, 0);

  pNode.setPercentage(100);
  pNode.setPosition(ccp(size.width/2, size.height/2));
  pNode.AnchorPoint := ccp(0.5, 0.5);

  Result := pNode;
end;

{ CCTransitionProgressVertical }

class function CCTransitionProgressVertical._create(t: Single;
  scene: CCScene): CCTransitionProgressVertical;
var
  pRet: CCTransitionProgressVertical;
begin
  pRet := CCTransitionProgressVertical.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionProgressVertical.progressTimerNodeWithRenderTexture(
  texture: CCRenderTexture): CCProgressTimer;
var
  size: CCSize;
  pNode: CCProgressTimer;
begin
  size := CCDirector.sharedDirector().getWinSize();
  pNode := CCProgressTimer._create(texture.Sprite);
  pNode.getSprite().setFlipY(True);
  pNode.setType(kCCProgressTimerTypeBar);
  pNode.Midpoint := ccp(0, 0);
  pNode.BarChangeRate := ccp(0, 1);

  pNode.setPercentage(100);
  pNode.setPosition(ccp(size.width/2, size.height/2));
  pNode.AnchorPoint := ccp(0.5, 0.5);

  Result := pNode;
end;

{ CCTransitionProgressInOut }

class function CCTransitionProgressInOut._create(t: Single;
  scene: CCScene): CCTransitionProgressInOut;
var
  pRet: CCTransitionProgressInOut;
begin
  pRet := CCTransitionProgressInOut.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionProgressInOut.progressTimerNodeWithRenderTexture(
  texture: CCRenderTexture): CCProgressTimer;
var
  size: CCSize;
  pNode: CCProgressTimer;
begin
  size := CCDirector.sharedDirector().getWinSize();
  pNode := CCProgressTimer._create(texture.Sprite);

  pNode.getSprite.setFlipY(True);
  pNode.setType(kCCProgressTimerTypeBar);
  pNode.Midpoint := ccp(0.5, 0.5);
  pNode.BarChangeRate := ccp(1, 1);

  pNode.setPercentage(0);
  pNode.setPosition(ccp(size.width/2, size.height/2));
  pNode.AnchorPoint := ccp(0.5, 0.5);

  Result := pNode;
end;

procedure CCTransitionProgressInOut.sceneOrder;
begin
  m_bIsInSceneOnTop := False;
end;

procedure CCTransitionProgressInOut.setupTransition;
begin
  m_pSceneToBeModified := m_pInScene;
  m_fFrom := 0;
  m_fTo := 100;
end;

{ CCTransitionProgressOutIn }

class function CCTransitionProgressOutIn._create(t: Single;
  scene: CCScene): CCTransitionProgressOutIn;
var
  pRet: CCTransitionProgressOutIn;
begin
  pRet := CCTransitionProgressOutIn.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionProgressOutIn.progressTimerNodeWithRenderTexture(
  texture: CCRenderTexture): CCProgressTimer;
var
  size: CCSize;
  pNode: CCProgressTimer;
begin
  size := CCDirector.sharedDirector().getWinSize();
  pNode := CCProgressTimer._create(texture.Sprite);

  pNode.getSprite.setFlipY(True);
  pNode.setType(kCCProgressTimerTypeBar);
  pNode.Midpoint := ccp(0.5, 0.5);
  pNode.BarChangeRate := ccp(1, 1);

  pNode.setPercentage(100);
  pNode.setPosition(ccp(size.width/2, size.height/2));
  pNode.AnchorPoint := ccp(0.5, 0.5);

  Result := pNode;
end;

end.
