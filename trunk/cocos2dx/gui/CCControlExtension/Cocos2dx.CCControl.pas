(*
 * Copyright (c) 2012 cocos2d-x.org
 * http://www.cocos2d-x.org
 *
 * Copyright 2011 Yannick Loriot.
 * http://yannickloriot.com
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
 * Converted to c++ / cocos2d-x by Angus C
 *)

unit Cocos2dx.CCControl;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCDictionary, Cocos2dx.CCInvocation,
  Cocos2dx.CCTouch, Cocos2dx.CCGeometry, Cocos2dx.CCArray, Cocos2dx.CCTypes;

//** Number of kinds of control event. */
const kControlEventTotalNumber = 9;

const    CCControlEventTouchDown           = 1 shl 0;    // A touch-down event in the control.
const    CCControlEventTouchDragInside     = 1 shl 1;    // An event where a finger is dragged inside the bounds of the control.
const    CCControlEventTouchDragOutside    = 1 shl 2;    // An event where a finger is dragged just outside the bounds of the control.
const    CCControlEventTouchDragEnter      = 1 shl 3;    // An event where a finger is dragged into the bounds of the control.
const    CCControlEventTouchDragExit       = 1 shl 4;    // An event where a finger is dragged from within a control to outside its bounds.
const    CCControlEventTouchUpInside       = 1 shl 5;    // A touch-up event in the control where the finger is inside the bounds of the control.
const    CCControlEventTouchUpOutside      = 1 shl 6;    // A touch-up event in the control where the finger is outside the bounds of the control.
const    CCControlEventTouchCancel         = 1 shl 7;    // A system event canceling the current touches for the control.
const    CCControlEventValueChanged        = 1 shl 8;      // A touch dragging or otherwise manipulating a control, causing it to emit a series of different values.


const    CCControlStateNormal       = 1 shl 0; // The normal, or default state of a control¡ªthat is, enabled but neither selected nor highlighted.
const    CCControlStateHighlighted  = 1 shl 1; // Highlighted state of a control. A control enters this state when a touch down, drag inside or drag enter is performed. You can retrieve and set this value through the highlighted property.
const    CCControlStateDisabled     = 1 shl 2; // Disabled state of a control. This state indicates that the control is currently disabled. You can retrieve and set this value through the enabled property.
const    CCControlStateSelected     = 1 shl 3;  // Selected state of a control. This state indicates that the control is currently selected. You can retrieve and set this value through the selected property.

type
  CCControlState = Cardinal;

  (*
   * @class
   * CCControl is inspired by the UIControl API class from the UIKit library of
   * CocoaTouch. It provides a base class for control CCSprites such as CCButton
   * or CCSlider that convey user intent to the application.
   *
   * The goal of CCControl is to define an interface and base implementation for
   * preparing action messages and initially dispatching them to their targets when
   * certain events occur.
   *
   * To use the CCControl you have to subclass it.
   *)
  CCControl = class(CCLayer)
  private
    function getDefaultTouchPriority: Integer;
    function getState: CCControlState;
    procedure setDefaultTouchPriority(const Value: Integer);
  public
    procedure setColor(const color: ccColor3B); override;
    function getColor(): ccColor3B; override;
    function getOpacity(): GLubyte; override;
    procedure setOpacity(opacity: GLubyte); override;
    procedure setOpacityModifyRGB(bValue: Boolean); override;
    function isOpacityModifyRGB(): Boolean; override;

    procedure setEnabled(bEnabled: Boolean); virtual;
    function isEnabled(): Boolean; virtual;
    procedure setSelected(bSelected: Boolean); virtual;
    function isSelected(): Boolean; virtual;
    procedure setHighlighted(bHighlighted: Boolean); virtual;
    function isHighlighted(): Boolean; virtual;
    function hasVisibleParents(): Boolean;
    procedure needsLayout(); virtual;

    property State: CCControlState read getState;
    property DefaultTouchPriority: Integer read getDefaultTouchPriority write setDefaultTouchPriority;
  protected
    m_hasVisibleParents: Boolean;
    m_nDefaultTouchPriority: Integer;
    m_eState: CCControlState;
    m_tColor: ccColor3B;
    m_cOpacity: GLubyte;
    m_bEnabled: Boolean;
    m_bSelected: Boolean;
    m_bHighlighted: Boolean;
    m_pDispatchTable: CCDictionary;
    m_bIsOpacityModifyRGB: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    function init(): Boolean; override;

    procedure onEnter(); override;
    procedure onExit(); override;
    procedure registerWithTouchDispatcher(); override;

    (**
     * Sends action messages for the given control events.
     *
     * @param controlEvents A bitmask whose set flags specify the control events for
     * which action messages are sent. See "CCControlEvent" for bitmask constants.
     *)
    procedure sendActionsForControlEvents(controlEvents: CCControlEvent); virtual;
    (**
    * Adds a target and action for a particular event (or events) to an internal
    * dispatch table.
    * The action message may optionnaly include the sender and the event as
    * parameters, in that order.
    * When you call this method, target is not retained.
    *
    * @param target The target object that is, the object to which the action
    * message is sent. It cannot be nil. The target is not retained.
    * @param action A selector identifying an action message. It cannot be NULL.
    * @param controlEvents A bitmask specifying the control events for which the
    * action message is sent. See "CCControlEvent" for bitmask constants.
    *)
    procedure addTargetWithActionForControlEvents(target: CCObject; action: SEL_CCControlHandler; controlEvents: CCControlEvent); virtual;
    (**
    * Removes a target and action for a particular event (or events) from an
    * internal dispatch table.
    *
    * @param target The target object—that is, the object to which the action
    * message is sent. Pass nil to remove all targets paired with action and the
    * specified control events.
    * @param action A selector identifying an action message. Pass NULL to remove
    * all action messages paired with target.
    * @param controlEvents A bitmask specifying the control events associated with
    * target and action. See "CCControlEvent" for bitmask constants.
    *)
    procedure removeTargetWithActionForControlEvents(target: CCObject; action: SEL_CCControlHandler; controlEvents: CCControlEvent); virtual;
    (**
    * Returns a point corresponding to the touh location converted into the
    * control space coordinates.
    * @param touch A CCTouch object that represents a touch.
    *)
    function getTouchLocation(touch: CCTouch): CCPoint; virtual;
    (**
    * Returns a boolean value that indicates whether a touch is inside the bounds
    * of the receiver. The given touch must be relative to the world.
    *
    * @param touch A CCTouch object that represents a touch.
    *
    * @return YES whether a touch is inside the receiver¡¯s rect.
    *)
    function isTouchInside(touch: CCTouch): Boolean; virtual;
  protected
    //function invocationWithTargetAndActionForControlEvent(target: CCObject; action: SEL_CCControlHandler; controlEvent: CCControlEvent): CCInvocation;
    (**
    * Returns the CCInvocation list for the given control event. If the list does
    * not exist, it'll create an empty array before returning it.
    *
    * @param controlEvent A control events for which the action message is sent.
    * See "CCControlEvent" for constants.
    *
    * @return the CCInvocation list for the given control event.
    *)
    function dispatchListforControlEvent(controlEvent: CCControlEvent): CCArray;
    (**
     * Adds a target and action for a particular event to an internal dispatch
     * table.
     * The action message may optionnaly include the sender and the event as
     * parameters, in that order.
     * When you call this method, target is not retained.
     *
     * @param target The target object¡ªthat is, the object to which the action
     * message is sent. It cannot be nil. The target is not retained.
     * @param action A selector identifying an action message. It cannot be NULL.
     * @param controlEvent A control event for which the action message is sent.
     * See "CCControlEvent" for constants.
     *)
    procedure addTargetWithActionForControlEvent(target: CCObject; action: SEL_CCControlHandler; controlEvents: CCControlEvent);
    (**
     * Removes a target and action for a particular event from an internal dispatch
     * table.
     *
     * @param target The target object¡ªthat is, the object to which the action
     * message is sent. Pass nil to remove all targets paired with action and the
     * specified control events.
     * @param action A selector identifying an action message. Pass NULL to remove
     * all action messages paired with target.
     * @param controlEvent A control event for which the action message is sent.
     * See "CCControlEvent" for constants.
     *)
    procedure removeTargetWithActionForControlEvent(target: CCObject; action: SEL_CCControlHandler; controlEvents: CCControlEvent);
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCDirector, Cocos2dx.CCNode;

{ CCControl }

procedure CCControl.addTargetWithActionForControlEvent(target: CCObject;
  action: SEL_CCControlHandler; controlEvents: CCControlEvent);
var
  pInv: CCInvocation;
  eventInvocationList: CCArray;
begin
  pInv := CCInvocation._create(target, action, controlEvents);
  eventInvocationList := dispatchListforControlEvent(controlEvents);
  eventInvocationList.addObject(pInv);
end;

procedure CCControl.addTargetWithActionForControlEvents(target: CCObject;
  action: SEL_CCControlHandler; controlEvents: CCControlEvent);
var
  i: Integer;
begin
  for i := 0 to kControlEventTotalNumber-1 do
  begin
    if (controlEvents and (1 shl i)) <> 0 then
      addTargetWithActionForControlEvent(target, action, 1 shl i);
  end;
end;

constructor CCControl.Create;
begin
  inherited Create();
  m_tColor := ccBLACK;
  m_eState := CCControlStateNormal;
end;

destructor CCControl.Destroy;
begin
  CC_SAFE_RELEASE(m_pDispatchTable);
  inherited;
end;

function CCControl.dispatchListforControlEvent(
  controlEvent: CCControlEvent): CCArray;
var
  invocationList: CCArray;
begin
  invocationList := CCArray(m_pDispatchTable.objectForKey(controlEvent));
  if invocationList = nil then
  begin
    invocationList := CCArray.createWithCapacity(1);
    m_pDispatchTable.setObject(invocationList, controlEvent);
  end;
  Result := invocationList;
end;

function CCControl.getColor: ccColor3B;
begin
  Result := m_tColor;
end;

function CCControl.getDefaultTouchPriority: Integer;
begin
  Result := m_nDefaultTouchPriority;
end;

function CCControl.getOpacity: GLubyte;
begin
  Result := m_cOpacity;
end;

function CCControl.getState: CCControlState;
begin
  Result := m_eState;
end;

function CCControl.getTouchLocation(touch: CCTouch): CCPoint;
var
  touchLocation: CCPoint;
begin
  touchLocation := touch.getLocation();
  touchLocation := convertToNodeSpace(touchLocation);
  Result := touchLocation;
end;

function CCControl.hasVisibleParents: Boolean;
var
  pParent: CCNode;
begin
  pParent := Self.Parent;
  while pParent <> nil do
  begin
    if not pParent.isVisible() then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

function CCControl.init: Boolean;
begin
  if inherited init() then
  begin
    m_eState := CCControlStateNormal;
    setEnabled(True);
    setSelected(False);
    setHighlighted(False);
    setDefaultTouchPriority(m_nDefaultTouchPriority);
    m_pDispatchTable := CCDictionary.Create;
    Result := True;
    Exit;
  end;
  
  Result := False;
end;

{function CCControl.invocationWithTargetAndActionForControlEvent(
  target: CCObject; action: SEL_CCControlHandler;
  controlEvent: CCControlEvent): CCInvocation;
begin

end;}

function CCControl.isEnabled: Boolean;
begin
  Result := m_bEnabled;
end;

function CCControl.isHighlighted: Boolean;
begin
  Result := m_bHighlighted;
end;

function CCControl.isOpacityModifyRGB: Boolean;
begin
  Result := m_bIsOpacityModifyRGB;
end;

function CCControl.isSelected: Boolean;
begin
  Result := m_bSelected;
end;

function CCControl.isTouchInside(touch: CCTouch): Boolean;
var
  touchLocation: CCPoint;
  bBox: CCRect;
begin
  touchLocation := touch.getLocation();
  touchLocation := Self.Parent.convertToNodeSpace(touchLocation);
  bBox := boundingBox();
  Result := bBox.containsPoint(touchLocation);
end;

procedure CCControl.needsLayout;
begin
  //override me 
end;

procedure CCControl.onEnter;
begin
  inherited onEnter();
end;

procedure CCControl.onExit;
begin
  inherited onExit();
end;

procedure CCControl.registerWithTouchDispatcher;
begin
  CCDirector.sharedDirector().TouchDispatcher.addTargetedDelegate(Self, m_nDefaultTouchPriority, True);
end;

procedure CCControl.removeTargetWithActionForControlEvent(target: CCObject;
  action: SEL_CCControlHandler; controlEvents: CCControlEvent);
var
  eventInvocationList: CCArray;
  bDeleteObjects: Boolean;
  i: Integer;
  pInv: CCInvocation;
  shouldBeRemoved: Boolean;
begin
  eventInvocationList := dispatchListforControlEvent(controlEvents);
  bDeleteObjects := True;

  if (target = nil) or (@action = nil) then
  begin
    eventInvocationList.removeAllObjects();
  end else
  begin
    if (eventInvocationList <> nil) and (eventInvocationList.count() > 0) then
      for i := 0 to eventInvocationList.count()-1 do
      begin
        pInv := CCInvocation(eventInvocationList.objectAtIndex(i));
        shouldBeRemoved := True;
        if pInv <> nil then
        begin
          if target <> nil then
            shouldBeRemoved := target = pInv.Target;
          if @action <> nil then
            shouldBeRemoved := shouldBeRemoved and (@action = @pInv.Action);

          if shouldBeRemoved then
            eventInvocationList.removeObject(pInv, bDeleteObjects);
        end;  
      end;  
  end;
end;

procedure CCControl.removeTargetWithActionForControlEvents(
  target: CCObject; action: SEL_CCControlHandler;
  controlEvents: CCControlEvent);
var
  i: Integer;
begin
  for i := 0 to kControlEventTotalNumber-1 do
  begin
    if (controlEvents and (1 shl i)) <> 0 then
    begin
      removeTargetWithActionForControlEvent(target, action, 1 shl i);
    end;
  end;
end;

procedure CCControl.sendActionsForControlEvents(
  controlEvents: CCControlEvent);
var
  i, j: Integer;
  pInv: CCInvocation;
  invocationList: CCArray;
begin
  for i := 0 to kControlEventTotalNumber-1 do
  begin
    if (controlEvents and (1 shl i)) <> 0 then
    begin
      invocationList := dispatchListforControlEvent(1 shl i);
      if (invocationList <> nil) and (invocationList.count() > 0) then
        for j := 0 to invocationList.count()-1 do
        begin
          pInv := CCInvocation(invocationList.objectAtIndex(j));
          if pInv = nil then
            Continue;

          pInv.invoke(Self);
        end;
    end;
  end;  
end;

procedure CCControl.setColor(const color: ccColor3B);
var
  i: Integer;
  pNode: CCNode;
  children: CCArray;
begin
  m_tColor := color;
  children := Self.Children;
  if (children <> nil) and (children.count() > 0) then
    for i := 0 to children.count()-1 do
    begin
      pNode := CCNode(children.objectAtIndex(i));
      if pNode <> nil then
        pNode.setColor(m_tColor);
    end;
end;

procedure CCControl.setDefaultTouchPriority(const Value: Integer);
begin
  m_nDefaultTouchPriority := Value;
end;

procedure CCControl.setEnabled(bEnabled: Boolean);
begin
  m_bEnabled := bEnabled;
  if m_bEnabled then
    m_eState := CCControlStateNormal
  else
    m_eState := CCControlStateDisabled;

  needsLayout();
end;

procedure CCControl.setHighlighted(bHighlighted: Boolean);
begin
  m_bHighlighted := bHighlighted;
  needsLayout();
end;

procedure CCControl.setOpacity(opacity: GLubyte);
var
  i: Integer;
  pNode: CCNode;
  children: CCArray;
begin
  m_cOpacity := opacity;
  children := Self.Children;
  if (children <> nil) and (children.count() > 0) then
    for i := 0 to children.count()-1 do
    begin
      pNode := CCNode(children.objectAtIndex(i));
      if pNode <> nil then
        pNode.setOpacity(opacity);
    end;
end;

procedure CCControl.setOpacityModifyRGB(bValue: Boolean);
var
  i: Integer;
  pNode: CCNode;
  children: CCArray;
begin
  m_bIsOpacityModifyRGB := bValue;
  children := Self.Children;
  if (children <> nil) and (children.count() > 0) then
    for i := 0 to children.count()-1 do
    begin
      pNode := CCNode(children.objectAtIndex(i));
      if pNode <> nil then
        pNode.setOpacityModifyRGB(bValue);
    end;
end;

procedure CCControl.setSelected(bSelected: Boolean);
begin
  m_bSelected := bSelected;
  needsLayout();
end;

end.
