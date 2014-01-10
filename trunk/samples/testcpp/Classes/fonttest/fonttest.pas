unit fonttest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCNode, Cocos2dx.CCLabelTTF, Cocos2dx.CCTypes;

type
  FontTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  FontTestDemo = class(CCLayer)
  public
    constructor Create();
    procedure showFont(const pFont: string);
    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);
    function title(): string; dynamic;
    class function _create(): FontTestDemo;
  end;

implementation
uses
  SysUtils, 
  Cocos2dx.CCDirector, Cocos2dx.CCPointExtension, Cocos2dx.CCMenuItem,
  Cocos2dx.CCMenu, Cocos2dx.CCDirectorProjection;

const    kTagLabel1 = 0;
const    kTagLabel2 = 1;
const    kTagLabel3 = 2;
const    kTagLabel4 = 3;

var fontList: array [0..5] of string = (
    'fonts/A Damn Mess.ttf',
    'fonts/Abberancy.ttf',
    'fonts/Abduction.ttf',
    'fonts/Paint Boy.ttf',
    'fonts/Schwarzwald Regular.ttf',
    'fonts/Scissor Cuts.ttf'
);

var fontIdx: Integer = 0;
var fontcount: Integer = 6;
var vAlignIdx: Integer;
var verticalAlignment: array [0..2] of CCVerticalTextAlignment = (
    kCCVerticalTextAlignmentTop,
    kCCVerticalTextAlignmentCenter,
    kCCVerticalTextAlignmentBottom
);
var vAlignCount: Integer = 3;

function nextAction(): string;
begin
  Inc(fontIdx);
  if fontIdx >= fontcount then
  begin
    fontIdx := 0;
    vAlignIdx := (vAlignIdx + 1) mod vAlignCount;
  end;
  Result := fontList[fontIdx];
end;

function backAction(): string;
begin
  Dec(fontIdx);
  if fontIdx < 0 then
  begin
    fontIdx := fontcount - 1;
    Dec(vAlignIdx);
    if vAlignIdx < 0 then
      vAlignIdx := vAlignIdx - 1;
  end;
  Result := fontlist[fontIdx];
end;

function restartAction(): string;
begin
  Result := fontList[fontIdx];
end;  

{ FontTestScene }

procedure FontTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := FontTestDemo._create;
  addChild(pLayer);
  CCDirector.sharedDirector.replaceScene(Self);
end;

{ FontTest }

class function FontTestDemo._create: FontTestDemo;
begin
  Result := FontTestDemo.Create;
  Result.autorelease;
end;

procedure FontTestDemo.backCallback(pObj: CCObject);
begin
  showFont(backAction);
end;

constructor FontTestDemo.Create;
var
  s: CCSize;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
begin
  inherited;
  s := CCDirector.sharedDirector.getWinSize;
  
  item1 := CCMenuItemImage._create('Images/b1.png', 'Images/b2.png', Self, backCallback);
  item2 := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, restartCallback);
  item3 := CCMenuItemImage._create('Images/f1.png', 'Images/f2.png', Self, nextCallback);

  menu := CCMenu._create([item1, item2, item3]);
  menu.setPosition(CCPointZero);
  item1.setPosition(ccp( s.width/2 - item2.ContentSize.width*2, item2.ContentSize.height/2 ));
  item2.setPosition(ccp( s.width/2, item2.ContentSize.height/2 ));
  item3.setPosition(ccp( s.width/2 + item2.ContentSize.width * 2, item2.ContentSize.height/2 ));

  addChild(menu, 1);

  showfont(restartAction);
end;

procedure FontTestDemo.nextCallback(pObj: CCObject);
begin
  showFont(nextAction);
end;

procedure FontTestDemo.restartCallback(pObj: CCObject);
begin
  showFont(restartAction);
end;

procedure FontTestDemo.showFont(const pFont: string);
var
  s, blockSize: CCSize;
  fontSize: Single;
  top, left, center, right: CCLabelTTF;
  leftcolor, centercolor, rightcolor: CCLayerColor;
begin
  s := CCDirector.sharedDirector.getWinSize;
  blockSize := CCSizeMake(s.width/3, 200);
  fontSize := 26;

  removeChildByTag(kTagLabel1, True);
  removeChildByTag(kTagLabel2, True);
  removeChildByTag(kTagLabel3, True);
  removeChildByTag(kTagLabel4, True);

  top := CCLabelTTF._create(pFont, pFont, 24);
  left := CCLabelTTF._create('alignment left', pFont, fontSize, blockSize, kCCTextAlignmentLeft, verticalAlignment[vAlignIdx]);
  center := CCLabelTTF._create('alignment center', pFont, fontSize, blockSize, kCCTextAlignmentCenter, verticalAlignment[vAlignIdx]);
  right := CCLabelTTF._create('alignment right', pFont, fontSize, blockSize, kCCTextAlignmentRight, verticalAlignment[vAlignIdx]);

  leftcolor := CCLayerColor._create(ccc4(100, 100, 100, 255), blockSize.width, blockSize.height);
  centercolor := CCLayerColor._create(ccc4(200, 100, 100, 255), blockSize.width, blockSize.height);
  rightcolor := CCLayerColor._create(ccc4(100, 100, 200, 255), blockSize.width, blockSize.height);

  leftcolor.ignoreAnchorPointForPosition(False);
  centercolor.ignoreAnchorPointForPosition(False);
  rightcolor.ignoreAnchorPointForPosition(False);

  top.AnchorPoint := ccp(0.5, 1);
  left.AnchorPoint := ccp(0, 0.5);
  leftcolor.AnchorPoint := ccp(0, 0.5);
  center.AnchorPoint := ccp(0, 0.5);
  centercolor.AnchorPoint := ccp(0, 0.5);
  right.AnchorPoint := ccp(0, 0.5);;
  rightcolor.AnchorPoint := ccp(0, 0.5);

  top.setPosition(s.width/2, s.height - 20);
  left.setPosition(0, s.height/2);
  leftcolor.setPosition(left.getPosition);
  center.setPosition(blockSize.width, s.height/2);
  centercolor.setPosition(center.getPosition);
  right.setPosition(blockSize.width*2, s.height/2);
  rightcolor.setPosition(right.getPosition);

  addChild(leftcolor, -1);
  addChild(left, 0, kTagLabel1);
  addChild(rightcolor, -1);
  addChild(right, 0, kTagLabel2);
  addChild(centercolor, -1);
  addChild(center, 0, kTagLabel3);
  addChild(top, 0, kTagLabel4);
end;

function FontTestDemo.title: string;
begin
  Result := 'Font test';
end;

end.
