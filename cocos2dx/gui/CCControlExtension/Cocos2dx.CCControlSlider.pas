(*
 * Copyright (c) 2012 cocos2d-x.org
 * http://www.cocos2d-x.org
 *
 * Copyright 2011 Yannick Loriot. All rights reserved.
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

unit Cocos2dx.CCControlSlider;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCControl, Cocos2dx.CCTouch, Cocos2dx.CCGeometry,
  Cocos2dx.CCSprite;

type
  CCControlSlider = class(CCControl)
  public
    function getBackgroundSprite: CCSprite;
    function getMaximumAllowedValue: Single;
    function getMaximumValue: Single;
    function getMinimumAllowedValue: Single;
    function getMinimumValue: Single;
    function getProgressSprite: CCSprite;
    function getThumbSprite: CCSprite;
    function getValue: Single;
    procedure setBackgroundSprite(const Value: CCSprite);
    procedure setMaximumAllowedValue(const Value: Single);
    procedure setMinimumAllowedValue(const Value: Single);
    procedure setProgressSprite(const Value: CCSprite);
    procedure setThumbSprite(const Value: CCSprite);
  public
    constructor Create();
    destructor Destroy(); override;
    function initWithSprites(backgroundSprite, progressSprite, thumbSprite: CCSprite): Boolean;
    class function _create(const bgFile, progressFile, thumbFile: string): CCControlSlider; overload;
    class function _create(backgroundSprite, progressSprite, thumbSprite: CCSprite): CCControlSlider; overload;

    procedure setValue(val: Single); virtual;
    procedure setMinimumValue(val: Single); virtual;
    procedure setMaximumValue(val: Single); virtual;
    procedure setEnabled(bEnabled: Boolean); override;
    function isTouchInside(touch: CCTouch): Boolean; override;
    procedure needsLayout(); override;
    function ccTouchBegan(pTouch: CCTouch; pEvent: CCEvent): Boolean; override;
    procedure ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent); override;
    procedure ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent); override;
    function valueForLocation(location: CCPoint): Single;
    function locationFromTouch(touch: CCTouch): CCPoint;
  protected
    m_value: Single;
    m_minimumValue: Single;
    m_maximumValue: Single;
    m_minimumAllowedValue: Single;
    m_maximumAllowedValue: Single;
    m_thumbSprite, m_progressSprite, m_backgroundSprite: CCSprite;
    procedure sliderBegan(location: CCPoint);
    procedure sliderMoved(location: CCPoint);
    procedure sliderEnded(location: CCPoint);
  public
    property Value: Single read getValue;
    property MinimumValue: Single read getMinimumValue;
    property MaximumValue: Single read getMaximumValue;
    property MinimumAllowedValue: Single read getMinimumAllowedValue write setMinimumAllowedValue;
    property MaximumAllowedValue: Single read getMaximumAllowedValue write setMaximumAllowedValue;
    property ThumbSprite: CCSprite read getThumbSprite write setThumbSprite;
    property ProgressSprite: CCSprite read getProgressSprite write setProgressSprite;
    property BackgroundSprite: CCSprite read getBackgroundSprite write setBackgroundSprite;
  end;

implementation
uses
  Math,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCControlUtils, Cocos2dx.CCTypes;

{ CCControlSlider }

class function CCControlSlider._create(backgroundSprite, progressSprite,
  thumbSprite: CCSprite): CCControlSlider;
var
  pRet: CCControlSlider;
begin
  pRet := CCControlSlider.Create();
  pRet.initWithSprites(backgroundSprite, progressSprite, thumbSprite);
  pRet.autorelease();
  Result := pRet;
end;

class function CCControlSlider._create(const bgFile, progressFile,
  thumbFile: string): CCControlSlider;
var
  backgroundSprite, progressSprite, thumbSprite: CCSprite;
begin
  backgroundSprite := CCSprite._create(bgFile);
  progressSprite := CCSprite._create(progressFile);
  thumbSprite := CCSprite._create(thumbFile);
  Result := Self._create(backgroundSprite, progressSprite, thumbSprite);
end;

function CCControlSlider.ccTouchBegan(pTouch: CCTouch;
  pEvent: CCEvent): Boolean;
var
  location: CCPoint;
begin
  if not isTouchInside(pTouch) or not isEnabled() then
  begin
    Result := False;
    Exit;
  end;
  location := locationFromTouch(pTouch);
  sliderBegan(location);
  Result := True;
end;

procedure CCControlSlider.ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent);
begin
  sliderEnded(CCPointZero);
end;

procedure CCControlSlider.ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent);
var
  location: CCPoint;
begin
  location := locationFromTouch(pTouch);
  sliderMoved(location);
end;

constructor CCControlSlider.Create;
begin
  inherited Create();
end;

destructor CCControlSlider.Destroy;
begin
  CC_SAFE_RELEASE(m_thumbSprite);
  CC_SAFE_RELEASE(m_progressSprite);
  CC_SAFE_RELEASE(m_backgroundSprite);
  inherited;
end;

function CCControlSlider.getBackgroundSprite: CCSprite;
begin
  Result := m_backgroundSprite;
end;

function CCControlSlider.getMaximumAllowedValue: Single;
begin
  Result := m_maximumAllowedValue;
end;

function CCControlSlider.getMaximumValue: Single;
begin
  Result := m_maximumValue;
end;

function CCControlSlider.getMinimumAllowedValue: Single;
begin
  Result := m_minimumAllowedValue;
end;

function CCControlSlider.getMinimumValue: Single;
begin
  Result := m_minimumValue;
end;

function CCControlSlider.getProgressSprite: CCSprite;
begin
  Result := m_progressSprite;
end;

function CCControlSlider.getThumbSprite: CCSprite;
begin
  Result := m_thumbSprite;
end;

function CCControlSlider.getValue: Single;
begin
  Result := m_value;
end;

function CCControlSlider.initWithSprites(backgroundSprite, progressSprite,
  thumbSprite: CCSprite): Boolean;
var
  maxRect: CCRect;
begin
  if inherited init() then
  begin
    CCAssert(backgroundSprite <> nil, 'Background sprite must be not nil');
    CCAssert(progressSprite <> nil, 'Progress sprite must be not nil');
    CCAssert(thumbSprite <> nil, 'Thumb sprite must be not nil');

    ignoreAnchorPointForPosition(False);
    setTouchEnabled(True);

    setBackgroundSprite(backgroundSprite);
    setProgressSprite(progressSprite);
    setThumbSprite(thumbSprite);

    maxRect := CCControlUtils.CCRectUnion(backgroundSprite.boundingBox(), thumbSprite.boundingBox());
    setContentSize(CCSizeMake(maxRect.size.width, maxRect.size.height));

    m_backgroundSprite.setAnchorPoint(CCPointMake(0.5, 0.5));
    m_backgroundSprite.setPosition(Self.ContentSize.width / 2, Self.ContentSize.height / 2);
    addChild(m_backgroundSprite);

    m_progressSprite.setAnchorPoint(CCPointMake(0.0, 0.5));
    m_progressSprite.setPosition(0, Self.ContentSize.height / 2);
    addChild(m_progressSprite);

    m_thumbSprite.setPosition(0, Self.ContentSize.height / 2);
    addChild(m_thumbSprite);

    m_minimumValue := 0;
    m_maximumValue := 1;

    Result := True;
    Exit;
  end;

  Result := False;
end;

function CCControlSlider.isTouchInside(touch: CCTouch): Boolean;
var
  touchLocation: CCPoint;
  rect: CCRect;
begin
  touchLocation := touch.getLocation();
  touchLocation := Self.Parent.convertToNodeSpace(touchLocation);
  rect := Self.boundingBox();
  rect.size.width := rect.size.width + m_thumbSprite.ContentSize.width;
  rect.origin.x := rect.origin.x - m_thumbSprite.ContentSize.width / 2;

  Result := rect.containsPoint(touchLocation);
end;

function CCControlSlider.locationFromTouch(touch: CCTouch): CCPoint;
var
  touchLocation: CCPoint;
begin
  touchLocation := touch.getLocation();
  touchLocation := convertToNodeSpace(touchLocation);

  if touchLocation.x < 0 then
  begin
    touchLocation.x := 0;
  end else if touchLocation.x > m_backgroundSprite.ContentSize.width then
  begin
    touchLocation.x := m_backgroundSprite.ContentSize.width;
  end;

  Result := touchLocation;
end;

procedure CCControlSlider.needsLayout;
var
  percent: Single;
  pos: CCPoint;
  textureRect: CCRect;
begin
  if (m_thumbSprite = nil) or (m_backgroundSprite = nil) or (m_progressSprite = nil) then
    Exit;

  percent := (m_value - m_minimumValue) / (m_maximumValue - m_minimumValue);
  pos := m_thumbSprite.getPosition();
  pos.x := percent * m_backgroundSprite.ContentSize.width;
  m_thumbSprite.setPosition(pos);

  textureRect := m_progressSprite.getTextureRect();
  textureRect := CCRectMake(textureRect.origin.x, textureRect.origin.y, pos.x, textureRect.size.height);
  m_progressSprite.setTextureRect(textureRect, m_progressSprite.isTextureRectRotated(), textureRect.size);
end;

procedure CCControlSlider.setBackgroundSprite(const Value: CCSprite);
begin
  if m_backgroundSprite <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_backgroundSprite);
    m_backgroundSprite := Value;
  end;  
end;

procedure CCControlSlider.setEnabled(bEnabled: Boolean);
begin
  inherited setEnabled(bEnabled);
  if m_thumbSprite <> nil then
  begin
    if bEnabled then
      m_thumbSprite.setOpacity(255)
    else
      m_thumbSprite.setOpacity(128);
  end;
end;

procedure CCControlSlider.setMaximumAllowedValue(const Value: Single);
begin
  m_maximumAllowedValue := Value;
end;

procedure CCControlSlider.setMaximumValue(val: Single);
begin
  m_maximumValue := val;
  m_maximumAllowedValue := val;
  if m_maximumValue <= m_minimumValue then
  begin
    m_minimumValue := m_maximumValue - 1.0;
  end;
  setValue(m_value);
end;

procedure CCControlSlider.setMinimumAllowedValue(const Value: Single);
begin
  m_minimumAllowedValue := Value;
end;

procedure CCControlSlider.setMinimumValue(val: Single);
begin
  m_minimumValue := val;
  m_minimumAllowedValue := val;
  if m_minimumValue >= m_maximumValue then
  begin
    m_maximumValue := m_minimumValue + 1.0;
  end;
  setValue(m_value);
end;

procedure CCControlSlider.setProgressSprite(const Value: CCSprite);
begin
  if m_progressSprite <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_progressSprite);
    m_progressSprite := Value;
  end;  
end;

procedure CCControlSlider.setThumbSprite(const Value: CCSprite);
begin
  if m_thumbSprite <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_thumbSprite);
    m_thumbSprite := Value;
  end;  
end;

procedure CCControlSlider.setValue(val: Single);
begin
  if val < m_minimumValue then
    val := m_minimumValue;

  if val > m_maximumValue then
    val := m_maximumValue;

  m_value := val;
  needsLayout();
  sendActionsForControlEvents(CCControlEventValueChanged);
end;

procedure CCControlSlider.sliderBegan(location: CCPoint);
begin
  setSelected(True);
  getThumbSprite().setColor(ccGRAY);
  setValue(valueForLocation(location));
end;

procedure CCControlSlider.sliderEnded(location: CCPoint);
begin
  if isSelected() then
  begin
    setValue(valueForLocation(m_thumbSprite.getPosition()));
  end;
  getThumbSprite().setColor(ccWHITE);
  setSelected(False);
end;

procedure CCControlSlider.sliderMoved(location: CCPoint);
begin
  setValue(valueForLocation(location));
end;

function CCControlSlider.valueForLocation(location: CCPoint): Single;
var
  percent: Single;
begin
  percent := location.x / m_backgroundSprite.ContentSize.width;
  Result := Max( Min(m_minimumValue + percent * (m_maximumValue - m_minimumValue), m_maximumAllowedValue), m_minimumValue );
end;

end.
