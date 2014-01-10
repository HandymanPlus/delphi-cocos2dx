(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada

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

unit Cocos2dx.CCMenu;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCMenuItem, Cocos2dx.CCTypes,
  Cocos2dx.CCArray, Cocos2dx.CCNode, Cocos2dx.CCTouch;

//* priority used by the menu for the event handler
const kCCMenuHandlerPriority = -128;

type
  tCCMenuState =
  (
    kCCMenuStateWaiting,
    kCCMenuStateTrackingTouch
  );

  (** @brief A CCMenu
    *
    * Features and Limitation:
    *  - You can add MenuItem objects in runtime using addChild:
    *  - But the only accepted children are MenuItem objects
    *)
  CCMenu = class(CCLayerRGBA)
  protected
    m_eState: tCCMenuState;
    m_pSelectedItem: CCMenuItem;
    function itemForTouch(touch: CCTouch): CCMenuItem;
  public
    m_bEnabled: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    class function _create(): CCMenu; overload;
    class function _create(items: array of CCMenuItem): CCMenu; overload;
    class function _create(pArrayOfItems: CCArray): CCMenu; overload;
    class function createWithItem(item: CCMenuItem): CCMenu;
    function init(): Boolean; override;
    function initWithItems(items: array of CCMenuItem): Boolean;
    function initWithArray(pArrayOfItems: CCArray): Boolean;
    procedure alignItemsVertically();
    procedure alignItemsVerticallyWithPadding(padding: Single);
    procedure alignItemsHorizontally();
    procedure alignItemsHorizontallyWithPadding(padding: Single);
    procedure alignItemsInColumns(columns: array of Cardinal);
    procedure alignItemsInRows(rows: array of Cardinal);

    procedure setHandlerPriority(newPriority: Integer);

    procedure addChild(child: CCNode); override;
    procedure addChild(child: CCNode; zOrder: Integer); override;
    procedure addChild(child: CCNode; zOrder: Integer; tag: Integer); override;
    procedure registerWithTouchDispatcher(); override;
    procedure removeChild(child: CCNode; cleanup: Boolean); override;

    function ccTouchBegan(pTouch: CCTouch; pEvent: CCEvent): Boolean; override;
    procedure ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent); override;
    procedure ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent); override;
    procedure ccTouchCancelled(pTouch: CCTouch; pEvent: CCEvent); override;

    procedure onExit(); override;
    function isEnabled(): Boolean; virtual;
    procedure setEnabled(value: Boolean); virtual;

    //interface
    procedure setOpacityModifyRGB(bValue: Boolean); override;
    function isOpacityModifyRGB(): Boolean; override;
  public

  end;

implementation
uses
  Math,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCGeometry, Cocos2dx.CCDirector,
  Cocos2dx.CCPointExtension, Cocos2dx.CCTouchDispatcher,
  Cocos2dx.CCVector, Cocos2dx.CCSprite;

{ CCMenu }

const kDefaultPadding = 5;

class function CCMenu._create(items: array of CCMenuItem): CCMenu;
var
  pRet: CCMenu;
begin
  pRet := CCMenu.Create();
  if (pRet <> nil) and pRet.initWithItems(items) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCMenu._create: CCMenu;
var
  pRet: CCMenu;
begin
  pRet := CCMenu.Create();
  if (pRet <> nil) and pRet.initWithItems([]) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCMenu._create(pArrayOfItems: CCArray): CCMenu;
var
  pRet: CCMenu;
begin
  pRet := CCMenu.Create;
  if (pRet <> nil) and pRet.initWithArray(pArrayOfItems) then
  begin
    pRet.autorelease();
  end else
  begin
    CC_SAFE_DELETE(pRet);
  end;
  
  Result := pRet;
end;

procedure CCMenu.addChild(child: CCNode);
begin
  inherited addChild(child);
end;

procedure CCMenu.addChild(child: CCNode; zOrder, tag: Integer);
begin
  CCAssert(child is CCMenuItem, 'Menu only supports MenuItem objects as children');
  inherited addChild(child, zOrder, tag);
end;

procedure CCMenu.addChild(child: CCNode; zOrder: Integer);
begin
  inherited addChild(child, zOrder);
end;

procedure CCMenu.alignItemsHorizontally;
begin
  Self.alignItemsHorizontallyWithPadding(kDefaultPadding);
end;

procedure CCMenu.alignItemsHorizontallyWithPadding(padding: Single);
var
  width, x: Single;
  pNode: CCNode;
  i: Integer;
begin
  width := -padding;
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        width := width + pNode.ContentSize.width * pNode.ScaleX + padding;
      end;
    end;
  end;

  x := -width/2.0;
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        pNode.setPosition(ccp( x + pNode.ContentSize.width * pNode.ScaleX / 2.0, 0 ));
        x := x + pNode.ContentSize.width * pNode.ScaleX + padding;
      end;
    end;
  end;
end;

procedure CCMenu.alignItemsInColumns(columns: array of Cardinal);
var
  rows: TVectorInt;
  columnsCount, i: Integer;
  height: Integer;
  row, rowHeight, columnsOccupied, rowColumns: Integer;
  pChild: CCNode;
  tmp: Single;
  winSize: CCSize;
  x, y, w: Single;
begin
  columnsCount := Length(columns);
  if columnsCount < 1 then
    Exit;

  rows := TVectorInt.Create;

  for i := 0 to columnsCount-1 do
  begin
    rows.push_back(columns[i]);
  end;

  height := -5;
  row := 0; rowHeight := 0; columnsOccupied := 0;
  
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pChild := CCNode(m_pChildren.objectAtIndex(i));
      if pChild <> nil then
      begin
        //CCAssert(row < rows.size(), '');

        rowColumns := rows[row];
        tmp := pChild.ContentSize.height;

        if (rowHeight < tmp) or not IsNan(tmp) then
          rowHeight := Round(tmp);

        Inc(columnsOccupied);
        if columnsOccupied >= rowColumns then
        begin
          height := height + rowHeight + 5;
          columnsOccupied := 0;
          rowHeight := 0;
          Inc(row);
        end;  
      end;
    end;  
  end;

  winSize := CCDirector.sharedDirector().getWinSize();
  row := 0;
  rowHeight := 0;
  rowColumns := 0;
  w := 0.0;
  x := 0.0;
  y := height/2.0;

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pChild := CCNode(m_pChildren.objectAtIndex(i));
      if pChild <> nil then
      begin
        if rowColumns = 0 then
        begin
          rowColumns := rows[row];
          w := winSize.width/(1+rowColumns);
          x := w;
        end;

        tmp := pChild.ContentSize.height;
        if (rowHeight < tmp) or not IsNan(tmp) then
          rowHeight := Round(tmp);

        pChild.setPosition(ccp(x-winSize.width/2.0, y - pChild.ContentSize.height/2.0));
        x := x + w;
        Inc(columnsOccupied);

        if columnsOccupied >= rowColumns then
        begin
          y := y - rowHeight - 5;
          columnsOccupied := 0;
          rowColumns := 0;
          rowHeight := 0;
          Inc(row);
        end;  
      end;
    end;
  end;

  rows.Free;
end;

procedure CCMenu.alignItemsInRows(rows: array of Cardinal);
var
  columns, columnWidths, columnHeights: TVectorInt;
  rowsCount, i: Integer;
  width, columnHeight: Integer;
  column, columnWidth, rowsOccupied, columnRows: Integer;
  pChild: CCNode;
  tmp: Single;
  winSize: CCSize;
  x, y: Single;
begin
  rowsCount := Length(rows);
  if rowsCount < 1 then
    Exit;

  columns := TVectorInt.Create;
  columnWidths := TVectorInt.Create;
  columnHeights := TVectorInt.Create;

  for i := 0 to rowsCount-1 do
  begin
    columns.push_back(rows[i]);
  end;

  width := -10;
  columnHeight := -5;
  column := 0; columnWidth := 0; rowsOccupied := 0;

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pChild := CCNode(m_pChildren.objectAtIndex(i));
      if pChild <> nil then
      begin
        columnRows := columns[column];
        tmp := pChild.ContentSize.width;
        if columnWidth < tmp then
          columnWidth := Round(tmp);

        columnHeight := columnHeight + Round(pChild.ContentSize.height + 5);
        Inc(rowsOccupied);

        if rowsOccupied >= columnRows then
        begin
          columnWidths.push_back(columnWidth);
          columnHeights.push_back(columnHeight);
          width := width + columnWidth + 10;

          rowsOccupied := 0;
          columnWidth := 0;
          columnHeight := -5;
          Inc(column);
        end;
      end;
    end;
  end;

  winSize := CCDirector.sharedDirector().getWinSize();
  column := 0; columnWidth := 0; columnRows := 0;
  x := -width/2.0;
  y := 0.0;

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pChild := CCNode(m_pChildren.objectAtIndex(i));
      if pChild <> nil then
      begin
        if columnRows = 0 then
        begin
          columnRows := columns[column];
          y := columnHeights[column];
        end;  

        tmp := pChild.ContentSize.width;
        if columnWidth < tmp then
          columnWidth := Round(tmp);

        pChild.setPosition(ccp( x + columnWidths[column]/2.0, y -winSize.height / 2.0 ));
        y := y - pChild.ContentSize.height - 10;
        Inc(rowsOccupied);

        if rowsOccupied >= columnRows then
        begin
          x := x + columnWidth + 5;

          rowsOccupied := 0;
          columnRows := 0;
          columnWidth := 0;
          Inc(column);
        end;
      end;
    end;
  end;

  columns.Free;
  columnWidths.Free;
  columnHeights.Free;
end;

procedure CCMenu.alignItemsVertically;
begin
  Self.alignItemsVerticallyWithPadding(kDefaultPadding);
end;

procedure CCMenu.alignItemsVerticallyWithPadding(padding: Single);
var
  height, y: Single;
  i: Integer;
  pNode: CCNode;
begin
  height := -padding;
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        height := height + pNode.ContentSize.height * pNode.ScaleY + padding;
      end;
    end;
  end;

  y := height/2.0;
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        pNode.setPosition(ccp( 0, y - pNode.ContentSize.height * pNode.ScaleY / 2.0 ));
        y := y - pNode.ContentSize.height * pNode.ScaleY - padding;
      end;
    end;
  end;
end;

function CCMenu.ccTouchBegan(pTouch: CCTouch; pEvent: CCEvent): Boolean;
var
  c: CCNode;
begin
  if (m_eState <> kCCMenuStateWaiting) or (not m_bVisible) or (not m_bEnabled) then
  begin
    Result := False;
    Exit;
  end;

  c := Self.Parent;
  while c <> nil do
  begin
    if not c.isVisible() then
    begin
      Result := False;
      Exit;
    end;  
    c := c.Parent;
  end;

  m_pSelectedItem := Self.itemForTouch(pTouch);
  if m_pSelectedItem <> nil then
  begin
    m_eState := kCCMenuStateTrackingTouch;
    m_pSelectedItem.selected();
    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure CCMenu.ccTouchCancelled(pTouch: CCTouch; pEvent: CCEvent);
begin
  CCAssert(m_eState = kCCMenuStateTrackingTouch, '[Menu ccTouchCancelled] -- invalid state');
  if m_pSelectedItem <> nil then
  begin
    m_pSelectedItem.unselected();
  end;
  m_eState := kCCMenuStateWaiting;
end;

procedure CCMenu.ccTouchEnded(pTouch: CCTouch; pEvent: CCEvent);
begin
  CCAssert(m_eState = kCCMenuStateTrackingTouch, '[Menu ccTouchEnded] -- invalid state');
  if m_pSelectedItem <> nil then
  begin
    m_pSelectedItem.unselected();
    m_pSelectedItem.activate();
  end;
  m_eState := kCCMenuStateWaiting;
end;

procedure CCMenu.ccTouchMoved(pTouch: CCTouch; pEvent: CCEvent);
var
  currentItem: CCMenuItem;
begin
  CCAssert(m_eState = kCCMenuStateTrackingTouch, '[Menu ccTouchMoved] -- invalid state');
  currentItem := Self.itemForTouch(pTouch);
  if currentItem <> m_pSelectedItem then
  begin
    if m_pSelectedItem <> nil then
    begin
      m_pSelectedItem.unselected();
    end;
    m_pSelectedItem := currentItem;
    if m_pSelectedItem <> nil then
    begin
      m_pSelectedItem.selected();
    end;  
  end;
end;

constructor CCMenu.Create;
begin
  inherited Create();
  m_pSelectedItem := nil;
end;

class function CCMenu.createWithItem(item: CCMenuItem): CCMenu;
var
  pRet: CCMenu;
begin
  pRet := CCMenu.Create();
  if (pRet <> nil) and pRet.initWithItems([item]) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

destructor CCMenu.Destroy;
begin

  inherited;
end;

function CCMenu.init: Boolean;
begin
  Result := initWithArray(nil);
end;

function CCMenu.initWithArray(pArrayOfItems: CCArray): Boolean;
var
  s: CCSize;
  z, i: Integer;
  item: CCMenuItem;
begin
  if inherited init() then
  begin
    setTouchPriority(kCCMenuHandlerPriority);
    setTouchMode(kCCTouchesOneByOne);
    setTouchEnabled(True);

    m_bEnabled := True;

    s := CCDirector.sharedDirector().getWinSize();

    Self.ignoreAnchorPointForPosition(True);
    AnchorPoint := ccp(0.5, 0.5);
    Self.setContentSize(s);

    setPosition(ccp(s.width/2, s.height/2));

    if pArrayOfItems <> nil then
    begin
      z := 0;

      if pArrayOfItems.count() > 0 then
        for i := 0 to pArrayOfItems.count()-1 do
        begin
          item := CCMenuItem(pArrayOfItems.objectAtIndex(i));
          Self.addChild(item, z);
          Inc(z);
        end;
    end;

    m_pSelectedItem := nil;
    m_eState := kCCMenuStateWaiting;

    setCascadeColorEnabled(True);
    setCascadeOpacityEnabled(True);

    Result := True;
    Exit;
  end;
  
  Result := False;
end;

function CCMenu.initWithItems(items: array of CCMenuItem): Boolean;
var
  i, nCount: Integer;
  pArray: CCArray;
begin
  nCount := Length(items);

  pArray := nil;

  if nCount > 0 then
  begin
    pArray := CCArray._Create();

    for i := 0 to nCount-1 do
    begin
      pArray.addObject(items[i]);
    end;
  end;

  Result := Self.initWithArray(pArray);
end;

function CCMenu.isEnabled: Boolean;
begin
  Result := m_bEnabled;
end;

function CCMenu.isOpacityModifyRGB: Boolean;
begin
  {.$MESSAGE 'no implementation'}
  Result := False;
end;

function CCMenu.itemForTouch(touch: CCTouch): CCMenuItem;
var
  pChild: CCNode;
  pItem: CCMenuItem;
  i: Integer;
  touchLocation: CCPoint;
  local: CCPoint;
  r: CCRect;
begin
  touchLocation := touch.getLocation();

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pChild := CCNode(m_pChildren.objectAtIndex(i));
      if (pChild <> nil) and (pChild is CCMenuItem) then
      begin
        pItem := CCMenuItem(pChild);
        if pItem.isVisible() and pItem.isEnabled() then
        begin
          local := pItem.convertToNodeSpace(touchLocation);
          r := pItem.rect();
          r.origin := CCPointZero;

          if r.containsPoint(local) then
          begin
            Result := pItem;
            Exit;
          end;
        end;
      end;
    end;  
  end;
  Result := nil;
end;

procedure CCMenu.onExit;
begin
  if m_eState = kCCMenuStateTrackingTouch then
  begin
    if m_pSelectedItem <> nil then
    begin
      m_pSelectedItem.unselected();
      m_pSelectedItem := nil;
    end;
    m_eState := kCCMenuStateWaiting;
  end;  
  inherited onExit();
end;

procedure CCMenu.registerWithTouchDispatcher;
var
  pDirector: CCDirector;
begin
  pDirector := CCDirector.sharedDirector();
  pDirector.TouchDispatcher.addTargetedDelegate(Self, getTouchPriority(), True);
end;

procedure CCMenu.setEnabled(value: Boolean);
begin
  m_bEnabled := value;
end;

procedure CCMenu.setOpacityModifyRGB(bValue: Boolean);
begin
//nothing
end;

procedure CCMenu.setHandlerPriority(newPriority: Integer);
var
  pDispatcher: CCTouchDispatcher;
begin
  pDispatcher := CCDirector.sharedDirector().TouchDispatcher;
  pDispatcher.setPriority(newPriority, Self);
end;

procedure CCMenu.removeChild(child: CCNode; cleanup: Boolean);
begin
  CCAssert(child is CCMenuItem, 'Menu only supports MenuItem objects as children');
  if m_pSelectedItem <> child then
  begin
    m_pSelectedItem := nil;
  end;
  inherited removeChild(child, cleanup);
end;

end.
