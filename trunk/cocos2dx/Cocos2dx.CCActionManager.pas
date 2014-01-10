(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2009      Valentin Milea
Copyright (c) 2011      Zynga Inc.

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

unit Cocos2dx.CCActionManager;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCAction, Cocos2dx.CCSet, Cocos2dx.cCCArray, tdHashChain;

type
  tHashItem = record
    actions: p_ccArray;
    target: CCObject;
    actionIndex: Cardinal;
    currentAction: CCAction;
    currentActionSalvaged: Boolean;
    paused: Boolean;
  end;
  pHashItem = ^tHashItem;


  (**
   @brief CCActionManager is a singleton that manages all the actions.
   Normally you won't need to use this singleton directly. 99% of the cases you will use the CCNode interface,
   which uses this singleton.
   But there are some cases where you might need to use this singleton.
   Examples:
      - When you want to run an action where the target is different from a CCNode.
      - When you want to pause / resume the actions

   @since v0.8
   *)
  CCActionManager = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure update(dt: Single); override;

    (** Adds an action with a target.
     If the target is already present, then the action will be added to the existing target.
     If the target is not present, a new instance of this target will be created either paused or not, and the action will be added to the newly created target.
     When the target is paused, the queued actions won't be 'ticked'.
     *)
    procedure addAction(pAction: CCAction; pTarget: CCObject{CCNode}; paused: Boolean);

    (** Removes all actions from all the targets.
    *)
    procedure removeAllActions();

    (** Removes all actions from a certain target.
     All the actions that belongs to the target will be removed.
     *)
    procedure removeAllActionsFromTarget(pTarget: CCObject);
    procedure removeAction(pAction: CCAction);
    procedure removeActionByTag(tag: Integer; pTarget: CCObject);
    function getActionByTag(tag: Integer; pTarget: CCObject): CCAction;

    (** Returns the numbers of actions that are running in a certain target. 
     * Composable actions are counted as 1 action. Example:
     * - If you are running 1 Sequence of 7 actions, it will return 1.
     * - If you are running 7 Sequences of 2 actions, it will return 7.
     *)
    function numberOfRunningActionsInTarget(pTarget: CCObject): Cardinal;
    procedure pauseTarget(pTarget: CCObject);
    procedure resumeTarget(pTarget: CCObject);
    function pauseAllRunningActions(): CCSet;
    procedure resumeTargets(targetsToResume: CCSet);
  protected
    m_bCurrentTargetSalvaged: Boolean;
    m_pTargets: TtdHashTableChain;
    m_pCurrentTarget: pHashItem;
    procedure removeActionAtIndex(uIndex: Cardinal; pElement: pHashItem);
    procedure deletehashElement(pElement: pHashItem);
    procedure actionAllocWithHashElement(pElement: pHashItem);
  end;

implementation
uses
  SysUtils, Cocos2dx.CCPlatformMacros;

{ CCActionManager }

procedure freeElement(HashElement: THashElement);
var
  pHashData: pHashItem;
begin
  pHashData := pHashItem(HashElement.pValue);
  if pHashData <> nil then
  begin
    ccArrayFree(pHashData^.actions);
    pHashData^.target.release();
    FreeMem(pHashData);
  end;
  HashElement.Free;
end;

procedure CCActionManager.actionAllocWithHashElement(
  pElement: pHashItem);
begin
  // 4 actions per Node by default
  if pElement^.actions = nil then
  begin
    pElement^.actions := ccArrayNew(4);
  end else if pElement^.actions^.num = pElement^.actions^.max then
  begin
    ccArrayDoubleCapacity(pElement^.actions);
  end;
end;

procedure CCActionManager.addAction(pAction: CCAction; pTarget: CCObject; paused: Boolean);
var
  pHashElement: THashElement;
  pHashData: pHashItem;
begin
  CCAssert(pAction <> nil, '');
  CCAssert(pTarget <> nil, '');

  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement = nil then
  begin
    pHashData := AllocMem(SizeOf(THashItem));
    pHashData^.paused := paused;
    pTarget.retain();
    pHashData^.target := pTarget;

    pHashElement := THashElement.Create(Cardinal(pTarget), pHashData);
    m_pTargets.AddElement(pHashElement);
  end else
  begin
    pHashData := pHashItem(pHashElement.pValue);
  end;  

  actionAllocWithHashElement(pHashData);

  CCAssert( ccArrayContainsObject(pHashData^.actions, pAction) = False, '' );
  ccArrayAppendObject(pHashData^.actions, pAction);

  pAction.startWithTarget(pTarget);
end;

constructor CCActionManager.Create;
begin
  inherited Create();
  m_bCurrentTargetSalvaged := False;
  m_pCurrentTarget := nil;
  m_pTargets := TtdHashTableChain.Create(200, freeElement);
end;

procedure CCActionManager.deletehashElement(pElement: pHashItem);
var
  pHashElement: THashElement;
begin
  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pElement^.target));
  if pHashElement <> nil then
  begin
    m_pTargets.DelElement(pHashElement);

    ccArrayFree(pElement^.actions);
    pElement^.target.release();
    FreeMem(pElement);

    pHashElement.Free;
  end;  
end;

destructor CCActionManager.Destroy;
begin
  removeAllActions();
  m_pTargets.Free;
  inherited;
end;

function CCActionManager.getActionByTag(tag: Integer;
  pTarget: CCObject): CCAction;
var
  pHashElement: THashElement;
  pHashData: pHashItem;
  limit, i: Cardinal;
  pAction: CCAction;
begin
  //CCAssert(tag <> kCCActionTagInvalid, '');

  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    pHashData := pHashItem(pHashElement.pValue);
    if pHashData^.actions <> nil then
    begin
      limit := pHashData^.actions^.num;
      for i := 0 to limit-1 do
      begin
        pAction := CCAction(pHashData^.actions^.arr[i]);
        if pAction.getTag() = tag then
        begin
          Result := pAction;
          Exit;
        end;  
      end;
    end;
  end else
  begin
    //
  end;
  
  Result := nil;
end;

function CCActionManager.numberOfRunningActionsInTarget(
  pTarget: CCObject): Cardinal;
var
  pHashElement: THashElement;
begin
  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    if pHashItem(pHashElement.pValue)^.actions <> nil then
      Result := pHashItem(pHashElement.pValue)^.actions^.num
    else
      Result := 0;

    Exit;
  end;

  Result := 0;
end;

function CCActionManager.pauseAllRunningActions: CCSet;
var
  idsWithActions: CCSet;
  pHashElement: THashElement;
begin
  idsWithActions := CCSet.Create();
  idsWithActions.autorelease();

  pHashElement := m_pTargets.First();
  while pHashElement <> nil do
  begin
    if not pHashItem(pHashElement.pValue)^.paused then
    begin
      pHashItem(pHashElement.pValue)^.paused := True;
      idsWithActions.addObject(pHashItem(pHashElement.pValue)^.target);
    end;

    pHashElement := m_pTargets.Next();
  end;

  Result := idsWithActions;
end;

procedure CCActionManager.pauseTarget(pTarget: CCObject);
var
  pHashElement: THashElement;
begin
  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
    pHashItem(pHashElement.pValue)^.paused := True;
end;

procedure CCActionManager.removeAction(pAction: CCAction);
var
  pTarget: CCObject;
  pHashElement: THashElement;
  pHashData: pHashItem;
  i: Cardinal;
begin
  if pAction = nil then
    Exit;

  pTarget := pAction.getOriginalTarget();
  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    pHashData := pHashItem(pHashElement.pValue);
    i := ccArrayGetIndexOfObject(pHashData^.actions, pAction);
    if i <> $FFFFFFFF then
      removeActionAtIndex(i, pHashData);
  end else
  begin
    // not found
  end;   
end;

procedure CCActionManager.removeActionAtIndex(uIndex: Cardinal;
  pElement: pHashItem);
var
  pAction: CCAction;
begin
  pAction := CCAction(pElement^.actions^.arr[uIndex]);

  if (pAction = pElement^.currentAction) and (not pElement^.currentActionSalvaged) then
  begin
    pElement^.currentAction.retain();
    pElement^.currentActionSalvaged := True;
  end;

  ccArrayRemoveObjectAtIndex(pElement^.actions, uIndex, True);

  // update actionIndex in case we are in tick. looping over the actions
  if pElement^.actionIndex >= uIndex then
  begin
    Dec(pElement^.actionIndex);
  end;

  if pElement^.actions^.num = 0 then
  begin
    if m_pCurrentTarget = pElement then
      m_bCurrentTargetSalvaged := True
    else
      deletehashElement(pElement);
  end;  
end;

procedure CCActionManager.removeActionByTag(tag: Integer;
  pTarget: CCObject);
var
  pHashElement: THashElement;
  limit, i: Cardinal;
  pHashData: pHashItem;
  pAction: CCAction;
begin
  //CCAssert(tag <> kCCActionTagInvalid, '');
  CCAssert(pTarget <> nil, '');

  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    pHashData := pHashItem(pHashElement.pValue);
    limit := pHashData^.actions^.num;
    if limit > 0 then
      for i := 0 to limit-1 do
      begin
        pAction := CCAction(pHashData^.actions^.arr[i]);

        if (pAction.getTag() = tag) and (pAction.getOriginalTarget() = pTarget) then
        begin
          removeActionAtIndex(i, pHashData);
          Break;
        end;
      end;
  end;
end;

procedure CCActionManager.removeAllActions;
var
  pHashElement: THashElement;
  pTarget: CCObject;
begin
  pHashElement := m_pTargets.First();
  while pHashElement <> nil do
  begin
    pTarget := pHashItem(pHashElement.pValue)^.target;
    removeAllActionsFromTarget(pTarget);

    pHashElement := m_pTargets.Next();
  end;
end;

procedure CCActionManager.removeAllActionsFromTarget(pTarget: CCObject);
var
  pHashElement: THashElement;
  pHashData: pHashItem;
begin
  if pTarget = nil then
    Exit;

  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
  begin
    pHashData := pHashItem(pHashElement.pValue);
    if ccArrayContainsObject(pHashData^.actions, pHashData^.currentAction) and (not pHashData^.currentActionSalvaged) then
    begin
      pHashData^.currentAction.retain();
      pHashData^.currentActionSalvaged := True;
    end;

    ccArrayRemoveAllObjects(pHashData^.actions);
    if m_pCurrentTarget = pHashData then
      m_bCurrentTargetSalvaged := True
    else
      deletehashElement(pHashData);
  end else
  begin
    // not found
  end;   
end;

procedure CCActionManager.resumeTarget(pTarget: CCObject);
var
  pHashElement: THashElement;
begin
  pHashElement := m_pTargets.FindElementByInteger(Cardinal(pTarget));
  if pHashElement <> nil then
    pHashItem(pHashElement.pValue)^.paused := False;
end;

procedure CCActionManager.resumeTargets(targetsToResume: CCSet);
var
  i: Integer;
  pObj: CCObject;
begin
  for i := 0 to targetsToResume.count()-1 do
  begin
    pObj := targetsToResume.getObject(i);
    if pObj <> nil then
      resumeTarget(pObj);
  end;  
end;

procedure CCActionManager.update(dt: Single);
var
  pHashElement: THashElement;
  pHashData: pHashItem;
  pAction: CCAction;
begin
  pHashElement := m_pTargets.First();
  while pHashElement <> nil do
  begin
    pHashData := pHashItem(pHashElement.pValue);
    m_pCurrentTarget := pHashData;
    m_bCurrentTargetSalvaged := False;

    if not m_pCurrentTarget^.paused then
    begin
      m_pCurrentTarget^.actionIndex := 0;
      while m_pCurrentTarget^.actionIndex < m_pCurrentTarget^.actions^.num do
      begin
        m_pCurrentTarget^.currentAction := CCAction(m_pCurrentTarget^.actions^.arr[m_pCurrentTarget^.actionIndex]);
        if m_pCurrentTarget^.currentAction = nil then
        begin
          Inc(m_pCurrentTarget^.actionIndex);
          Continue;
        end;

        m_pCurrentTarget^.currentActionSalvaged := False;

        m_pCurrentTarget^.currentAction.step(dt);

        if m_pCurrentTarget^.currentActionSalvaged then
        begin
          // The currentAction told the node to remove it. To prevent the action from
          // accidentally deallocating itself before finishing its step, we retained
          // it. Now that step is done, it's safe to release it.
          m_pCurrentTarget^.currentAction.release();
        end else if m_pCurrentTarget^.currentAction.isDone() then
        begin
          m_pCurrentTarget^.currentAction.stop();
          pAction := m_pCurrentTarget^.currentAction;
          // Make currentAction nil to prevent removeAction from salvaging it.
          m_pCurrentTarget^.currentAction := nil;
          removeAction(pAction);
        end;

        m_pCurrentTarget^.currentAction := nil;

        Inc(m_pCurrentTarget^.actionIndex);
      end;
    end;

    pHashElement := m_pTargets.Next();

    // only delete currentTarget if no actions were scheduled during the cycle (issue #481)
    if m_bCurrentTargetSalvaged and (m_pCurrentTarget^.actions^.num = 0) then
    begin
      deletehashElement(m_pCurrentTarget);
    end;  
  end;

  m_pCurrentTarget := nil;
end;

end.
