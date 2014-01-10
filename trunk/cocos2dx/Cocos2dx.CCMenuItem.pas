(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2011 Ricardo Quesada
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

unit Cocos2dx.CCMenuItem;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCNode, Cocos2dx.CCLabelTTF, Cocos2dx.CCSprite,
  Cocos2dx.CCSpriteFrame, Cocos2dx.CCGeometry, Cocos2dx.CCTypes, Cocos2dx.CCArray;

const kCCItemSize = 32;

type
  (** @brief CCMenuItem base class
   *
   *  Subclass CCMenuItem (or any subclass) to create your custom CCMenuItem objects.
   *)
  CCMenuItem = class(CCNodeRGBA)
  protected
    m_bSelected: Boolean;
    m_bEnabled: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(): CCMenuItem; overload;
    class function _create(rec: CCObject; selector: SEL_MenuHandler): CCMenuItem; overload;
    function initWithTarget(rec: CCObject; selector: SEL_MenuHandler): Boolean;
    function rect(): CCRect;
    procedure activate(); virtual;
    //** The item was selected (not activated), similar to "mouse-over" */
    procedure selected(); virtual;
    procedure unselected(); virtual;
    function isEnabled(): Boolean; virtual;
    procedure setEnabled(value: Boolean); virtual;
    function isSelected(): Boolean; virtual;
    procedure setTarget(rec: CCObject; selector: SEL_MenuHandler);
  protected
    m_pListener: CCObject;
    m_pfnSelector: SEL_MenuHandler;
  end;

  (** @brief CCMenuItemSprite accepts CCNode<CCRGBAProtocol> objects as items.
     The images has 3 different states:
     - unselected image
     - selected image
     - disabled image

     @since v0.8.0
     *)
  CCMenuItemSprite = class(CCMenuItem)
  protected
    m_pNormalImage, m_pSelectedImage, m_pDisabledImage: CCNode;
    procedure updateImagesVisibility(); virtual;
  public
    constructor Create();
    destructor Destroy(); override;

    function getDisabledImage: CCNode;
    function getNormalImage: CCNode;
    function getSelectedImage: CCNode;
    procedure setDisabledImage(const Value: CCNode);
    procedure setNormalImage(const Value: CCNode);
    procedure setSelectedImage(const Value: CCNode);
  public
    class function _create(normalSprite: CCNode; selectedSprite: CCNode; disabledSprite: CCNode = nil): CCMenuItemSprite; overload;
    class function _create(normalSprite: CCNode; selectedSprite: CCNode; target: CCObject; selector: SEL_MenuHandler): CCMenuItemSprite; overload;
    class function _create(normalSprite: CCNode; selectedSprite: CCNode; disabledSprite: CCNode; target: CCObject; selector: SEL_MenuHandler): CCMenuItemSprite; overload;
    function initWithNormalSprite(normalSprite: CCNode; selectedSprite: CCNode; disabledSprite: CCNode; target: CCObject; selector: SEL_MenuHandler): Boolean;
    procedure selected(); override;
    procedure unselected(); override;
    procedure setEnabled(value: Boolean); override;
    //
    property NormalImage: CCNode read getNormalImage write setNormalImage;
    property SelectedImage: CCNode read getSelectedImage write setSelectedImage;
    property DisabledImage: CCNode read getDisabledImage write setDisabledImage;
  end;

  (** @brief CCMenuItemImage accepts images as items.
     The images has 3 different states:
     - unselected image
     - selected image
     - disabled image

     For best results try that all images are of the same size
     *)
  CCMenuItemImage = class(CCMenuItemSprite)
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(): CCMenuItemImage; overload;
    class function _create(const normalImage: string; const selectedImage: string): CCMenuItemImage; overload;
    class function _create(const normalImage: string; const selectedImage: string; const disabledImage: string): CCMenuItemImage; overload;
    class function _create(const normalImage: string; const selectedImage: string; target: CCObject; selector: SEL_MenuHandler): CCMenuItemImage; overload;
    class function _create(const normalImage: string; const selectedImage: string; const disabledImage: string; target: CCObject; selector: SEL_MenuHandler): CCMenuItemImage; overload;
    function init(): Boolean; override;
    function initWithNormalImage(const normalImage, selectedImage, disabledImage: string; target: CCObject; selector: SEL_MenuHandler): Boolean;
    procedure setNormalSpriteFrame(frame: CCSpriteFrame);
    procedure setSelectedSpriteFrame(frame: CCSpriteFrame);
    procedure setDisabledSpriteFrame(frame: CCSpriteFrame);
  end;

  (** @brief An abstract class for "label" CCMenuItemLabel items
     Any CCNode that supports the CCLabelProtocol protocol can be added.
     Supported nodes:
     - CCBitmapFontAtlas
     - CCLabelAtlas
     - CCLabelTTF
     *)
  CCMenuItemLabel = class(CCMenuItem)
  private
    m_tColorBackup: ccColor3B;
    m_tDisabledColor: ccColor3B;
    m_pLabel: CCNode;
    m_fOriginalScale: Single;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(pLabel: CCNode; target: CCObject; selector: SEL_MenuHandler): CCMenuItemLabel; overload;
    class function _create(pLabel: CCNode): CCMenuItemLabel; overload;
    function initWithLabel(pLabel: CCNode; target: CCObject; selector: SEL_MenuHandler): Boolean;
    procedure activate(); override;
    procedure selected(); override;
    procedure unselected(); override;
    procedure setEnabled(value: Boolean); override;
    function get_Label: CCNode;
    function getDisabledColor: ccColor3B;
    procedure setLabel(const Value: CCNode);
    procedure setDisabledColor(const Value: ccColor3B);
  public
    //interface
    procedure setString(const slabel: string); override;
    //
    property DisabledColor: ccColor3B read getDisabledColor write setDisabledColor;
    property _Label: CCNode read get_Label write setLabel;
  end;

  (** @brief A CCMenuItemAtlasFont
   Helper class that creates a MenuItemLabel class with a LabelAtlas
   *)
  CCMenuItemAtlasFont = class(CCMenuItemLabel)
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(const value: string; const charMapFile: string; itemWidth, itemHeight: Integer; startCharMap: Char): CCMenuItemAtlasFont; overload;
    class function _create(const value: string; const charMapFile: string; itemWidth, itemHeight: Integer; startCharMap: Char; target: CCObject; selector: SEL_MenuHandler): CCMenuItemAtlasFont; overload;
    function initWithString(const value: string; const charMapFile: string; itemWidth, itemHeight: Integer; startCharMap: Char; target: CCObject; selector: SEL_MenuHandler): Boolean;
  end;

  CCMenuItemFont = class(CCMenuItemLabel)
  public
    constructor Create();
    destructor Destroy(); override;
    class procedure setFontSize(s: Cardinal);
    class function fontSize(): Cardinal;
    class procedure setFontName(const name: string);
    class function fontName(): string;
    class function _create(const value: string): CCMenuItemFont; overload;
    class function _create(const value: string; target: CCObject; selector: SEL_MenuHandler): CCMenuItemFont; overload;
    function initWithString(const value: string; target: CCObject; selector: SEL_MenuHandler): Boolean;
    procedure setFontSizeObj(s: Cardinal);
    function fontSizeObj(): Cardinal;
    procedure setFontNameObj(const name: string);
    function fontNameObj(): string;
  protected
    m_uFontSize: Cardinal;
    m_strFontName: string;
    procedure recreateLabel();
  end;

  (** @brief A CCMenuItemToggle
     A simple container class that "toggles" it's inner items
     The inner items can be any MenuItem
     *)
  //modified by myself
  CCMenuItemToggle = class(CCMenuItem)
  public
    constructor Create();
    destructor Destroy(); override;
    class function createWithTarget(target: CCObject; selector: SEL_MenuHandler; items: array of CCMenuItem): CCMenuItemToggle;
    class function _create(): CCMenuItemToggle; overload;
    class function _create(item: CCMenuItem): CCMenuItemToggle; overload;
    function initWithTarget(target: CCObject; selector: SEL_MenuHandler; items: array of CCMenuItem): Boolean;
    function initWithItem(item: CCMenuItem): Boolean;
    procedure addSubItem(item: CCMenuItem);
    function selectedItem(): CCMenuItem;
    procedure activate(); override;
    procedure selected(); override;
    procedure unselected(); override;
    procedure setEnabled(enabled: Boolean); override;

    function getSelectedIndex: Cardinal;
    function getSubItems: CCArray;
    procedure setSelectedIndex(const Value: Cardinal);
    procedure setSubItems(const Value: CCArray);
  public
    property SelectedIndex: Cardinal read getSelectedIndex write setSelectedIndex;
    property SubItems: CCArray read getSubItems write setSubItems;
  private
    m_uSelectedIndex: Cardinal;
    m_pSubItems: CCArray;
  end;

implementation
uses
  Cocos2dx.CCPointExtension, Cocos2dx.CCPlatformMacros, Cocos2dx.CCAction,
  Cocos2dx.CCLabelAtlas, Cocos2dx.CCActionInterval;

var _globalFontSize: Cardinal = kCCItemSize;
var _globalFontName: string = 'Marker Felt';
var _globalFontNameRelease: Boolean = false;

const kCurrentItem: Integer = $c0c051;//$c0c05001
const kZoomActionTag = $c0c052;//c0c05002

const kNormalTag = $1;
const kSelectedTag = $2;
const kDisableTag = $3;

{ CCMenuItem }

class function CCMenuItem._create(rec: CCObject;
  selector: SEL_MenuHandler): CCMenuItem;
var
  pRet: CCMenuItem;
begin
  pRet := CCMenuItem.Create();
  pRet.initWithTarget(rec, selector);
  pRet.autorelease();
  Result := pRet;
end;

class function CCMenuItem._create: CCMenuItem;
var
  pRet: CCMenuItem;
begin
  pRet := CCMenuItem.Create();
  pRet.initWithTarget(nil, nil);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCMenuItem.activate;
begin
  if m_bEnabled then
  begin
    if (m_pListener <> nil) and (@m_pfnSelector <> nil) then
      m_pfnSelector(Self);
  end;  
end;

constructor CCMenuItem.Create;
begin
  inherited Create();
  {m_bIsSelected := False;
  m_bIsEnabled := False;
  m_pListener := nil;
  m_pfnSelector := nil;}
end;

destructor CCMenuItem.Destroy;
begin

  inherited;
end;

function CCMenuItem.initWithTarget(rec: CCObject;
  selector: SEL_MenuHandler): Boolean;
begin
  setAnchorPoint(ccp(0.5, 0.5));
  m_pListener := rec;
  m_pfnSelector := selector;
  m_bEnabled := True;
  m_bSelected := False;
  Result := True;
end;

function CCMenuItem.isEnabled: Boolean;
begin
  Result := m_bEnabled;
end;

function CCMenuItem.isSelected: Boolean;
begin
  Result := m_bSelected;
end;

function CCMenuItem.rect: CCRect;
begin
  Result := CCRectMake(m_obPosition.x - m_obContentSize.width * m_obAnchorPoint.x,
    m_obPosition.y - m_obContentSize.height * m_obAnchorPoint.y,
    m_obContentSize.width, m_obContentSize.height);
end;

procedure CCMenuItem.selected;
begin
  m_bSelected := True;
end;

procedure CCMenuItem.setEnabled(value: Boolean);
begin
  m_bEnabled := value;
end;

procedure CCMenuItem.setTarget(rec: CCObject; selector: SEL_MenuHandler);
begin
  m_pListener := rec;
  m_pfnSelector := selector;
end;

procedure CCMenuItem.unselected;
begin
  m_bSelected := False;
end;

{ CCMenuItemSprite }

class function CCMenuItemSprite._create(normalSprite,
  selectedSprite: CCNode; target: CCObject;
  selector: SEL_MenuHandler): CCMenuItemSprite;
var
  pRet: CCMenuItemSprite;
begin
  pRet := CCMenuItemSprite.Create();
  pRet.initWithNormalSprite(normalSprite, selectedSprite, nil, target, selector);
  pRet.autorelease();
  Result := pRet;
end;

class function CCMenuItemSprite._create(normalSprite, selectedSprite,
  disabledSprite: CCNode): CCMenuItemSprite;
var
  pRet: CCMenuItemSprite;
begin
  pRet := CCMenuItemSprite.Create();
  pRet.initWithNormalSprite(normalSprite, selectedSprite, disabledSprite, nil, nil);
  pRet.autorelease();
  Result := pRet;
end;

class function CCMenuItemSprite._create(normalSprite, selectedSprite,
  disabledSprite: CCNode; target: CCObject;
  selector: SEL_MenuHandler): CCMenuItemSprite;
var
  pRet: CCMenuItemSprite;
begin
  pRet := CCMenuItemSprite.Create();
  pRet.initWithNormalSprite(normalSprite, selectedSprite, disabledSprite, target, selector);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCMenuItemSprite.Create;
begin
  inherited Create();
end;

destructor CCMenuItemSprite.Destroy;
begin

  inherited;
end;

function CCMenuItemSprite.getDisabledImage: CCNode;
begin
  Result := m_pDisabledImage;
end;

function CCMenuItemSprite.getNormalImage: CCNode;
begin
  Result := m_pNormalImage;
end;

function CCMenuItemSprite.getSelectedImage: CCNode;
begin
  Result := m_pSelectedImage;
end;

function CCMenuItemSprite.initWithNormalSprite(normalSprite,
  selectedSprite, disabledSprite: CCNode; target: CCObject;
  selector: SEL_MenuHandler): Boolean;
begin
  inherited initWithTarget(target, selector);
  setNormalImage(normalSprite);
  setSelectedImage(selectedSprite);
  setDisabledImage(disabledSprite);
  if m_pNormalImage <> nil then
    setContentSize(m_pNormalImage.ContentSize);

  setCascadeColorEnabled(True);
  setCascadeOpacityEnabled(True);

  Result := True;
end;

procedure CCMenuItemSprite.selected;
begin
  inherited selected();

  if m_pNormalImage <> nil then
  begin
    if m_pDisabledImage <> nil then
    begin
      m_pDisabledImage.setVisible(False);
    end;
    if m_pSelectedImage <> nil then
    begin
      m_pNormalImage.setVisible(False);
      m_pSelectedImage.setVisible(True);
    end else
    begin
      m_pNormalImage.setVisible(True);
    end;    
  end;
end;

procedure CCMenuItemSprite.setDisabledImage(const Value: CCNode);
begin
  if Value <> m_pNormalImage then
  begin
    if Value <> nil then
    begin
      addChild(Value, 0, kDisableTag);
      Value.AnchorPoint := ccp(0, 0);
    end;

    if m_pDisabledImage <> nil then
      removeChild(m_pDisabledImage, True);

    m_pDisabledImage := Value;

    Self.updateImagesVisibility();
  end;
end;

procedure CCMenuItemSprite.setEnabled(value: Boolean);
begin
  if m_bEnabled <> value then
  begin
    inherited setEnabled(value);
    Self.updateImagesVisibility();
  end;  
end;

procedure CCMenuItemSprite.setNormalImage(const Value: CCNode);
begin
  if Value <> m_pNormalImage then
  begin
    if Value <> nil then
    begin
      addChild(Value, 0, kNormalTag);
      Value.AnchorPoint := ccp(0, 0);
    end;

    if m_pNormalImage <> nil then
      removeChild(m_pNormalImage, True);

    m_pNormalImage := Value;

    Self.setContentSize(m_pNormalImage.ContentSize);
    Self.updateImagesVisibility();
  end;  
end;

procedure CCMenuItemSprite.setSelectedImage(const Value: CCNode);
begin
  if Value <> m_pNormalImage then
  begin
    if Value <> nil then
    begin
      addChild(Value, 0, kSelectedTag);
      Value.AnchorPoint := ccp(0, 0);
    end;

    if m_pSelectedImage <> nil then
      removeChild(m_pSelectedImage, True);

    m_pSelectedImage := Value;

    Self.updateImagesVisibility();
  end;
end;

procedure CCMenuItemSprite.unselected;
begin
  inherited unselected();
  if m_pNormalImage <> nil then
  begin
    m_pNormalImage.setVisible(True);

    if m_pSelectedImage <> nil then
    begin
      m_pSelectedImage.setVisible(False);
    end;

    if m_pDisabledImage <> nil then
    begin
      m_pDisabledImage.setVisible(False);
    end;  
  end;  
end;

procedure CCMenuItemSprite.updateImagesVisibility;
begin
  if m_bEnabled then
  begin
    if m_pNormalImage <> nil then m_pNormalImage.setVisible(True);
    if m_pSelectedImage <> nil then m_pSelectedImage.setVisible(False);
    if m_pDisabledImage <> nil then m_pDisabledImage.setVisible(False);
  end else
  begin
    if m_pDisabledImage <> nil then
    begin
      if m_pNormalImage <> nil then m_pNormalImage.setVisible(False);
      if m_pSelectedImage <> nil then m_pSelectedImage.setVisible(False);
      if m_pDisabledImage <> nil then m_pDisabledImage.setVisible(True);
    end else
    begin
      if m_pNormalImage <> nil then m_pNormalImage.setVisible(True);
      if m_pSelectedImage <> nil then m_pSelectedImage.setVisible(False);
      if m_pDisabledImage <> nil then m_pDisabledImage.setVisible(False);
    end;    
  end;   
end;

{ CCMenuItemImage }

class function CCMenuItemImage._create(const normalImage,
  selectedImage: string; target: CCObject;
  selector: SEL_MenuHandler): CCMenuItemImage;
var
  pRet: CCMenuItemImage;
begin
  pRet := CCMenuItemImage.Create();
  if (pRet <> nil) and pRet.initWithNormalImage(normalImage, selectedImage, '', target, selector) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCMenuItemImage._create(const normalImage, selectedImage,
  disabledImage: string; target: CCObject;
  selector: SEL_MenuHandler): CCMenuItemImage;
var
  pRet: CCMenuItemImage;
begin
  pRet := CCMenuItemImage.Create();
  if (pRet <> nil) and pRet.initWithNormalImage(normalImage, selectedImage, disabledImage, target, selector) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCMenuItemImage._create(const normalImage, selectedImage,
  disabledImage: string): CCMenuItemImage;
var
  pRet: CCMenuItemImage;
begin
  pRet := CCMenuItemImage.Create();
  if (pRet <> nil) and pRet.initWithNormalImage(normalImage, selectedImage, disabledImage, nil, nil) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCMenuItemImage._create: CCMenuItemImage;
var
  pRet: CCMenuItemImage;
begin
  pRet := CCMenuItemImage.Create();
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCMenuItemImage._create(const normalImage,
  selectedImage: string): CCMenuItemImage;
var
  pRet: CCMenuItemImage;
begin
  pRet := CCMenuItemImage.Create();
  if (pRet <> nil) and pRet.initWithNormalImage(normalImage, selectedImage, '', nil, nil) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCMenuItemImage.Create;
begin
  inherited Create();
end;

destructor CCMenuItemImage.Destroy;
begin

  inherited;
end;

function CCMenuItemImage.init: Boolean;
begin
  Result := Self.initWithNormalImage('', '', '', nil, nil);
end;

function CCMenuItemImage.initWithNormalImage(const normalImage,
  selectedImage, disabledImage: string; target: CCObject;
  selector: SEL_MenuHandler): Boolean;
var
  normalSprite, selectedSprite, disabledSprite: CCNode;
begin
  normalSprite := nil;
  selectedSprite := nil;
  disabledSprite := nil;

  if normalImage <> '' then
  begin
    normalSprite := CCSprite._create(normalImage);
  end;
  if selectedImage <> '' then
  begin
    selectedSprite := CCSprite._create(selectedImage);
  end;
  if disabledImage <> '' then
  begin
    disabledSprite := CCSprite._create(disabledImage);
  end;

  Result := initWithNormalSprite(normalSprite, selectedSprite, disabledSprite, target, selector);
end;

procedure CCMenuItemImage.setDisabledSpriteFrame(frame: CCSpriteFrame);
begin
  setDisabledImage(CCSprite.createWithSpriteFrame(frame));
end;

procedure CCMenuItemImage.setNormalSpriteFrame(frame: CCSpriteFrame);
begin
  setNormalImage(CCSprite.createWithSpriteFrame(frame));
end;

procedure CCMenuItemImage.setSelectedSpriteFrame(frame: CCSpriteFrame);
begin
  setSelectedImage(CCSprite.createWithSpriteFrame(frame));
end;

{ CCMenuItemLabel }

class function CCMenuItemLabel._create(pLabel: CCNode; target: CCObject;
  selector: SEL_MenuHandler): CCMenuItemLabel;
var
  pRet: CCMenuItemLabel;
begin
  pRet := CCMenuItemLabel.Create();
  pRet.initWithLabel(pLabel, target, selector);
  pRet.autorelease();
  Result := pRet;
end;

class function CCMenuItemLabel._create(
  pLabel: CCNode): CCMenuItemLabel;
var
  pRet: CCMenuItemLabel;
begin
  pRet := CCMenuItemLabel.Create();
  pRet.initWithLabel(pLabel, nil, nil);
  pRet.autorelease();
  Result := pRet;
end;

procedure CCMenuItemLabel.activate;
begin
  if m_bEnabled then
  begin
    Self.stopAllActions();
    Self.setScale(m_fOriginalScale);
    inherited activate();
  end;
end;

constructor CCMenuItemLabel.Create;
begin
  inherited Create();
  m_pLabel := nil;
  m_fOriginalScale := 0.0;
end;

destructor CCMenuItemLabel.Destroy;
begin

  inherited;
end;

function CCMenuItemLabel.get_Label: CCNode;
begin
  Result := m_pLabel;
end;

function CCMenuItemLabel.getDisabledColor: ccColor3B;
begin
  Result := m_tDisabledColor;
end;

function CCMenuItemLabel.initWithLabel(pLabel: CCNode; target: CCObject;
  selector: SEL_MenuHandler): Boolean;
begin
  inherited initWithTarget(target, selector);
  m_fOriginalScale := 1.0;
  m_tColorBackup := ccWHITE;
  m_tDisabledColor := ccc3(126 ,126, 126);
  Self.setLabel(pLabel);

  setCascadeColorEnabled(True);
  setCascadeOpacityEnabled(True);

  Result := True;
end;

procedure CCMenuItemLabel.selected;
var
  action, zoomAction: CCAction;
begin
  if m_bEnabled then
  begin
    inherited selected();

    action := getActionByTag(kZoomActionTag);
    if action <> nil then
    begin
      Self.stopAction(action);
    end else
    begin
      m_fOriginalScale := Self.Scale;
    end;

    zoomAction := CCScaleTo._create(0.1, m_fOriginalScale * 1.2);
    zoomAction.setTag(kZoomActionTag);
    Self.runAction(zoomAction);
  end;  
end;

procedure CCMenuItemLabel.setLabel(const Value: CCNode);
begin
  if Value <> nil then
  begin
    addChild(Value);
    Value.AnchorPoint := ccp(0, 0);
    setContentSize(Value.ContentSize);
  end;

  if m_pLabel <> nil then
  begin
    removeChild(m_pLabel, True);
  end;

  m_pLabel := Value;
end;

procedure CCMenuItemLabel.setDisabledColor(const Value: ccColor3B);
begin
  m_tDisabledColor := Value;
end;

procedure CCMenuItemLabel.setString(const slabel: string);
begin
  m_pLabel.setString(slabel);
  Self.setContentSize(m_pLabel.ContentSize);
end;

procedure CCMenuItemLabel.unselected;
var
  zoomAction: CCAction;
begin
  if m_bEnabled then
  begin
    inherited unselected();
    Self.stopActionByTag(kZoomActionTag);
    zoomAction := CCScaleTo._create(0.1, m_fOriginalScale);
    zoomAction.setTag(kZoomActionTag);
    Self.runAction(zoomAction);
  end;  
end;

procedure CCMenuItemLabel.setEnabled(value: Boolean);
begin
  if m_bEnabled <> value then
  begin
    if not value then
    begin
      m_tColorBackup := m_pLabel.getColor();
      m_pLabel.setColor(m_tDisabledColor);
    end else
    begin
      m_pLabel.setColor(m_tColorBackup);
    end;
  end;
  inherited setEnabled(value);
end;

{ CCMenuItemAtlasFont }

class function CCMenuItemAtlasFont._create(const value,
  charMapFile: string; itemWidth, itemHeight: Integer;
  startCharMap: Char): CCMenuItemAtlasFont;
var
  pRet: CCMenuItemAtlasFont;
begin
  pRet := CCMenuItemAtlasFont.Create();
  pRet.initWithString(value, charMapFile, itemWidth, itemHeight, startCharMap, nil, nil);
  pRet.autorelease();
  Result := pRet;
end;

class function CCMenuItemAtlasFont._create(const value,
  charMapFile: string; itemWidth, itemHeight: Integer; startCharMap: Char;
  target: CCObject; selector: SEL_MenuHandler): CCMenuItemAtlasFont;
var
  pRet: CCMenuItemAtlasFont;
begin
  pRet := CCMenuItemAtlasFont.Create();
  pRet.initWithString(value, charMapFile, itemWidth, itemHeight, startCharMap, target, selector);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCMenuItemAtlasFont.Create;
begin
  inherited Create();
end;

destructor CCMenuItemAtlasFont.Destroy;
begin

  inherited;
end;

function CCMenuItemAtlasFont.initWithString(const value,
  charMapFile: string; itemWidth, itemHeight: Integer; startCharMap: Char;
  target: CCObject; selector: SEL_MenuHandler): Boolean;
var
  plabel: CCLabelAtlas;
begin
  plabel := CCLabelAtlas.Create();
  plabel.initWithString(value, charMapFile, itemWidth, itemHeight, Cardinal(startCharMap));
  plabel.autorelease();
  if initWithLabel(plabel, target, selector) then
  begin

  end;
  Result := True;  
end;

{ CCMenuItemFont }

class function CCMenuItemFont._create(const value: string;
  target: CCObject; selector: SEL_MenuHandler): CCMenuItemFont;
var
  pRet: CCMenuItemFont;
begin
  pRet := CCMenuItemFont.Create;
  pRet.initWithString(value, target, selector);
  pRet.autorelease();
  Result := pRet;
end;

class function CCMenuItemFont._create(const value: string): CCMenuItemFont;
var
  pRet: CCMenuItemFont;
begin
  pRet := CCMenuItemFont.Create();
  pRet.initWithString(value, nil, nil);
  pRet.autorelease();
  Result := pRet;
end;

constructor CCMenuItemFont.Create;
begin
  inherited Create();
end;

destructor CCMenuItemFont.Destroy;
begin

  inherited;
end;

class function CCMenuItemFont.fontName: string;
begin
  Result := _globalFontName;
end;

function CCMenuItemFont.fontNameObj: string;
begin
  Result := m_strFontName;
end;

class function CCMenuItemFont.fontSize: Cardinal;
begin
  Result := _globalFontSize;
end;

function CCMenuItemFont.fontSizeObj: Cardinal;
begin
  Result := m_uFontSize;
end;

function CCMenuItemFont.initWithString(const value: string;
  target: CCObject; selector: SEL_MenuHandler): Boolean;
var
  pLabel: CCLabelTTF;
begin
  CCAssert( (value <> ''), 'Value length must be greater than 0');

  m_strFontName := _globalFontName;
  m_uFontSize := _globalFontSize;

  pLabel := CCLabelTTF._create(value, m_strFontName, m_uFontSize);
  if initWithLabel(pLabel, target, selector) then
  begin
    // do something ?
  end;
  Result := True;  
end;

procedure CCMenuItemFont.recreateLabel;
var
  pLabel: CCLabelTTF;
begin
  pLabel := CCLabelTTF._create(m_pLabel.getString(), m_strFontName, m_uFontSize);
  setLabel(pLabel);
end;

class procedure CCMenuItemFont.setFontName(const name: string);
begin
  if _globalFontNameRelease then
  begin
    _globalFontName := '';
  end;
  _globalFontName := name;
  _globalFontNameRelease := True;
end;

procedure CCMenuItemFont.setFontNameObj(const name: string);
begin
  m_strFontName := name;
  recreateLabel();
end;

class procedure CCMenuItemFont.setFontSize(s: Cardinal);
begin
  _globalFontSize := s;
end;

procedure CCMenuItemFont.setFontSizeObj(s: Cardinal);
begin
  m_uFontSize := s;
  recreateLabel();
end;

{ CCMenuItemToggle }

class function CCMenuItemToggle._create(
  item: CCMenuItem): CCMenuItemToggle;
var
  pRet: CCMenuItemToggle;
begin
  pRet := CCMenuItemToggle.Create;
  pRet.initWithItem(item);
  pRet.autorelease();
  Result := pRet;
end;

class function CCMenuItemToggle._create: CCMenuItemToggle;
var
  pRet: CCMenuItemToggle;
begin
  pRet := CCMenuItemToggle.Create;
  pRet.initWithItem(nil);
  pRet.autorelease();

  Result := pRet;
end;

procedure CCMenuItemToggle.activate;
var
  newIndex: Cardinal;
begin
  if m_bEnabled then
  begin
    newIndex := (m_uSelectedIndex + 1) mod m_pSubItems.count();
    Self.setSelectedIndex(newIndex);
  end;  
  inherited activate();
end;

procedure CCMenuItemToggle.addSubItem(item: CCMenuItem);
begin
  m_pSubItems.addObject(item);
end;

constructor CCMenuItemToggle.Create;
begin
  inherited Create();
  {m_cOpacity := 0;
  m_uSelectedIndex := 0;
  m_pSubItems := nil;}
end;

class function CCMenuItemToggle.createWithTarget(target: CCObject;
  selector: SEL_MenuHandler; items: array of CCMenuItem): CCMenuItemToggle;
var
  pRet: CCMenuItemToggle;
begin
  pRet := CCMenuItemToggle.Create;
  pRet.initWithTarget(target, selector, items);
  pRet.autorelease();
  Result := pRet;
end;

destructor CCMenuItemToggle.Destroy;
begin
  CC_SAFE_RELEASE(m_pSubItems);
  inherited;
end;

function CCMenuItemToggle.getSelectedIndex: Cardinal;
begin
  Result := m_uSelectedIndex;
end;

function CCMenuItemToggle.getSubItems: CCArray;
begin
  Result := m_pSubItems;
end;

function CCMenuItemToggle.initWithItem(item: CCMenuItem): Boolean;
begin
  inherited initWithTarget(nil, nil);
  setSubItems(CCArray._Create());

  if item <> nil then
    m_pSubItems.addObject(item);
  m_uSelectedIndex := High(Cardinal);
  Self.setSelectedIndex(0);

  setCascadeColorEnabled(True);
  setCascadeOpacityEnabled(True);

  Result := True;
end;

function CCMenuItemToggle.initWithTarget(target: CCObject;
  selector: SEL_MenuHandler; items: array of CCMenuItem): Boolean;
var
  n: Integer;
  nCount: Integer;
begin
  inherited initWithTarget(target, selector);
  Self.m_pSubItems := CCArray._Create();
  Self.m_pSubItems.retain();

  nCount := Length(items);
  if nCount > 0 then
  begin
    for n := 0 to nCount-1 do
    begin
      m_pSubItems.addObject(items[n]);
    end;  
  end;

  m_uSelectedIndex := High(Cardinal);
  Self.setSelectedIndex(0);
  Result := True;
end;

procedure CCMenuItemToggle.selected;
begin
  inherited selected();
  CCMenuItem(m_pSubItems.objectAtIndex(m_uSelectedIndex)).selected();
end;

function CCMenuItemToggle.selectedItem: CCMenuItem;
begin
  Result := CCMenuItem(m_pSubItems.objectAtIndex(m_uSelectedIndex));
end;

procedure CCMenuItemToggle.setEnabled(enabled: Boolean);
var
  i: Integer;
  pItem: CCMenuItem;
begin
  if m_bEnabled <> enabled then
  begin
    inherited setEnabled(enabled);

    if (m_pSubItems <> nil) and (m_pSubItems.count() > 0) then
    begin
      for i := 0 to m_pSubItems.count()-1 do
      begin
        pItem := CCMenuItem(m_pSubItems.objectAtIndex(i));
        pItem.setEnabled(enabled);
      end;  
    end;
  end;
end;

procedure CCMenuItemToggle.setSelectedIndex(const Value: Cardinal);
var
  currentItem, item: CCMenuItem;
  s: CCSize;
begin
  if (Value <> m_uSelectedIndex) and (m_pSubItems.count() > 0) then
  begin
    currentItem := nil;
    if m_uSelectedIndex <> High(Cardinal) then
      currentItem := CCMenuItem(getChildByTag(m_uSelectedIndex));
    if currentItem <> nil then
      currentItem.Visible := False;
    m_uSelectedIndex := Value;

    item := CCMenuItem(getChildByTag(m_uSelectedIndex));
    if item = nil then
    begin
      item := CCMenuItem(m_pSubItems.objectAtIndex(m_uSelectedIndex));
      Self.addChild(item, 0, m_uSelectedIndex);
    end;

    s := item.ContentSize;
    Self.setContentSize(s);
    item.setPosition( ccp(s.width/2, s.height/2) );
    item.Visible := True;
  end;
end;

procedure CCMenuItemToggle.setSubItems(const Value: CCArray);
begin
  CC_SAFE_RETAIN(Value);
  CC_SAFE_RELEASE(m_pSubItems);
  m_pSubItems := Value;
end;

procedure CCMenuItemToggle.unselected;
begin
  inherited unselected();
  CCMenuItem(m_pSubItems.objectAtIndex(m_uSelectedIndex)).unselected();
end;

end.
