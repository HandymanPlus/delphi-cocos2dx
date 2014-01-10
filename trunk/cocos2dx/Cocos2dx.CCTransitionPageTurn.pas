(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Sindesso Pty Ltd http://www.sindesso.com/

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

unit Cocos2dx.CCTransitionPageTurn;

interface
uses
  Cocos2dx.CCTransition, Cocos2dx.CCScene, Cocos2dx.CCAction, Cocos2dx.CCTypes,
  Cocos2dx.CCGeometry;

type
  (**
    @brief A transition which peels back the bottom right hand corner of a scene
    to transition to the scene beneath it simulating a page turn.

    This uses a 3DAction so it's strongly recommended that depth buffering
    is turned on in CCDirector using:

     CCDirector::sharedDirector()->setDepthBufferFormat(kDepthBuffer16);

     @since v0.8.2
    *)
  CCTransitionPageTurn = class(CCTransitionScene)
  protected
    m_bBack: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(t: Single; scene: CCScene; backwards: Boolean): CCTransitionPageTurn;
    function initWithDuration(t: Single; scene: CCScene; backwards: Boolean): Boolean;
    function actionWithSize(const vector: CCSize): CCActionInterval;
    procedure onEnter(); override;
  protected
    procedure sceneOrder(); override;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCActionInterval, Cocos2dx.CCActionPageTurn3D,
  Cocos2dx.CCDirector, Cocos2dx.CCActionInstant, Cocos2dx.CCActionGrid;

{ CCTransitionPageTurn }

class function CCTransitionPageTurn._create(t: Single; scene: CCScene;
  backwards: Boolean): CCTransitionPageTurn;
var
  pRet: CCTransitionPageTurn;
begin
  pRet := CCTransitionPageTurn.Create();
  if (pRet <> nil) and pRet.initWithDuration(t, scene, backwards) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

function CCTransitionPageTurn.actionWithSize(
  const vector: CCSize): CCActionInterval;
begin
  if m_bBack then
  begin
    Result := CCReverseTime._create(CCPageTurn3D._create(m_fDuration, vector));
  end else
  begin
    Result := CCPageTurn3D._create(m_fDuration, vector);
  end;    
end;

constructor CCTransitionPageTurn.Create;
begin
  inherited;
end;

destructor CCTransitionPageTurn.Destroy;
begin

  inherited;
end;

function CCTransitionPageTurn.initWithDuration(t: Single; scene: CCScene;
  backwards: Boolean): Boolean;
begin
  m_bBack := backwards; 
  if inherited initWithDuration(t, scene) then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure CCTransitionPageTurn.onEnter;
var
  s: CCSize;
  x, y: Integer;
  action: CCActionInterval;
begin
  inherited onEnter();

  s := CCDirector.sharedDirector().getWinSize();
  if s.width > s.height then
  begin
    x := 16; y := 12;
  end else
  begin
    x := 12; y := 16;
  end;

  action := actionWithSize(CCSizeMake(x, y));
  if not m_bBack then
  begin
    m_pOutScene.runAction(CCSequence._create([
            action,
            CCCallFunc._create(Self, finish),
            CCStopGrid._create() ]));
  end else
  begin
    m_pInScene.setVisible(False);
    m_pInScene.runAction(CCSequence._create([
            CCShow._create(),
            action,
            CCCallFunc._create(Self, finish),
            CCStopGrid._create() ]));
  end;
end;

procedure CCTransitionPageTurn.sceneOrder;
begin
  m_bIsInSceneOnTop := m_bBack;
end;

end.
