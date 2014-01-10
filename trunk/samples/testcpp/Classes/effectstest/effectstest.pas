unit effectstest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCSprite,
  Cocos2dx.CCNode, Cocos2dx.CCActionGrid3D, Cocos2dx.CCAction, Cocos2dx.CCActionTiledGrid,
  Cocos2dx.CCActionPageTurn3D;

type
  EffectTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  EffectTestDemo = class(CCLayerColor)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure checkAnim(dt: Single);
    procedure newScene();
    procedure onEnter(); override;

    procedure restartCallback(pObj: CCObject);
    procedure nextCallback(pObj: CCObject);
    procedure backCallback(pObj: CCObject);

    class function _create(): EffectTestDemo;
  protected
  end;

  Waves3DDemo = class(CCWave3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  FlipX3DDemo = class(CCFlipX3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  FlipY3DDemo = class(CCFlipY3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  Lens3DDemo = class(CCLens3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  Ripple3DDemo = class(CCRipple3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  Shaky3DDemo = class(CCShaky3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  LiquidDemo = class(CCLiquid)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  WavesDemo = class(CCWaves)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  TwirlDemo = class(CCTwirl)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  ShakyTiles3DDemo = class(CCShakyTiles3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  ShatteredTiles3DDemo = class(CCShatteredTiles3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  ShuffleTilesDemo = class(CCShuffleTiles)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  FadeOutTRTilesDemo = class(CCFadeOutTRTiles)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  FadeOutBLTilesDemo = class(CCFadeOutBLTiles)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  FadeOutUpTilesDemo = class(CCFadeOutUpTiles)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  FadeOutDownTilesDemo = class(CCFadeOutDownTiles)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  TurnOffTilesDemo = class(CCTurnOffTiles)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  WavesTiles3DDemo = class(CCWavesTiles3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  JumpTiles3DDemo = class(CCJumpTiles3D)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  SplitRowsDemo = class(CCSplitRows)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  SplitColsDemo = class(CCSplitCols)
  public
    class function _create(t: Single): CCActionInterval;
  end;

  PageTurn3DDemo = class(CCSplitCols)
  public
    class function _create(t: Single): CCActionInterval;
  end;


implementation
uses
  SysUtils, testResource,
  Cocos2dx.CCDirector, Cocos2dx.CCLabelTTF, Cocos2dx.CCPointExtension, Cocos2dx.CCMenuItem,
  Cocos2dx.CCMenu,
  Cocos2dx.CCTypes, Cocos2dx.CCActionInterval;

var      actionIdx: Integer = 0;
const    MAX_LAYER = 22;

const    kTagTextLayer = 1;
const    kTagBackground = 1;
const    kTagLabel = 2;

var
effectsList: array [0..MAX_LAYER-1] of string =
(
    'Shaky3D',
    'Waves3D',
    'FlipX3D',
    'FlipY3D',
    'Lens3D',
    'Ripple3D',
    'Liquid',
    'Waves',
    'Twirl',
    'ShakyTiles3D',
    'ShatteredTiles3D',
    'ShuffleTiles',
    'FadeOutTRTiles',
    'FadeOutBLTiles',
    'FadeOutUpTiles',
    'FadeOutDownTiles',
    'TurnOffTiles',
    'WavesTiles3D',
    'JumpTiles3D',
    'SplitRows',
    'SplitCols',
    'PageTurn3D'
);

function createEffect(nindex: Integer; t: Single): CCActionInterval;
var
  pRet: CCActionInterval;
begin
  CCDirector.sharedDirector.setDepthTest(False);

  pRet := nil;
  case nindex of
    0: pRet := Shaky3DDemo._create(t);
    1: pRet := Waves3DDemo._create(t);
    2: pRet := FlipX3DDemo._create(t);
    3: pRet := FlipY3DDemo._create(t);
    4: pRet := Lens3DDemo._create(t);
    5: pRet := Ripple3DDemo._create(t);
    6: pRet := LiquidDemo._create(t);
    7: pRet := WavesDemo._create(t);
    8: pRet := TwirlDemo._create(t);
    9: pRet := ShakyTiles3DDemo._create(t);
    10: pRet := ShatteredTiles3DDemo._create(t);
    11: pRet := ShuffleTilesDemo._create(t);
    12: pRet := FadeOutTRTilesDemo._create(t);
    13: pRet := FadeOutBLTilesDemo._create(t);
    14: pRet := FadeOutUpTilesDemo._create(t);
    15: pRet := FadeOutDownTilesDemo._create(t);
    16: pRet := TurnOffTilesDemo._create(t);
    17: pRet := WavesTiles3DDemo._create(t);
    18: pRet := JumpTiles3DDemo._create(t);
    19: pRet := SplitRowsDemo._create(t);
    20: pRet := SplitColsDemo._create(t);
    21: pRet := PageTurn3DDemo._create(t);
  end;
  Result := pRet;
end;

function getAction(): CCActionInterval;
begin
  Result := createEffect(actionIdx, 3);
end;  

{ EffectTestScene }

procedure EffectTestScene.runThisTest;
begin
  addChild(EffectTestDemo._create);
  CCDirector.sharedDirector.replaceScene(Self);
end;

{ EffectTestDemo }

class function EffectTestDemo._create: EffectTestDemo;
var
  pLayer: EffectTestDemo;
begin
  pLayer := EffectTestDemo.Create;
  pLayer.autorelease;
  Result := pLayer;
end;

procedure EffectTestDemo.backCallback(pObj: CCObject);
var
  total: Integer;
begin
  Dec(actionIdx);
  total := MAX_LAYER;
  if actionIdx < 0 then
    actionIdx := actionIdx + total;
  newScene();
end;

procedure EffectTestDemo.checkAnim(dt: Single);
var
  s2: CCNode;
begin
  s2 := getChildByTag(kTagBackground);
  if (s2.numberOfRunningActions = 0) and (s2.Grid <> nil) then
    s2.Grid := nil;
end;

constructor EffectTestDemo.Create;
var
  x, y: Single;
  s: CCSize;
  node: CCNode;
  effect: CCActionInterval;
  bg, grossini, tamara: CCSprite;
  sc, sc_back: CCFiniteTimeAction;
  sc2, sc2_back: CCFiniteTimeAction;

  label1: CCLabelTTF;
  item1, item2, item3: CCMenuItemImage;
  menu: CCMenu;
begin
  inherited;
  initWithColor(ccc4(32, 128, 32, 255));
  s := CCDirector.sharedDirector.getWinSize;
  x := s.width;
  y := s.height;

  node := CCNode._create;
  effect := getAction;
  node.runAction(effect);
  addChild(node, 0, kTagBackground);

  bg := CCSprite._create(s_back3);
  node.addChild(bg, 0);
  bg.setPosition(ccp(s.width/2, s.height/2));

  grossini := CCSprite._create(s_pPathSister2);
  node.addChild(grossini, 1);
  grossini.setPosition(ccp(x/3, y/2));
  sc := CCScaleBy._create(2, 5);
  sc_back := sc.reverse;
  grossini.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([sc, sc_back]))));

  tamara := CCSprite._create(s_pPathSister1);
  node.addChild(tamara, 1);
  tamara.setPosition(ccp(2*x/3, y/2));
  sc2 := CCScaleBy._create(2, 5);
  sc2_back := sc2.reverse;
  tamara.runAction(CCRepeatForever._create(CCActionInterval(CCSequence._create([sc2, sc2_back]))));

  label1 := CCLabelTTF._create(effectsList[actionIdx], 'Marker Felt', 32);
  addChild(label1);
  label1.setPosition(ccp(s.width/2, s.height-80));
  label1.Tag := kTagLabel;

  item1 := CCMenuItemImage._create('Images/b1.png', 'Images/b2.png', Self, backCallback);
  item2 := CCMenuItemImage._create('Images/r1.png', 'Images/r2.png', Self, restartCallback);
  item3 := CCMenuItemImage._create('Images/f1.png', 'Images/f2.png', Self, nextCallback);

  menu := CCMenu._create([item1, item2, item3]);
  menu.setPosition(CCPointZero);
  item1.setPosition(ccp( s.width/2 - item2.ContentSize.width*2, item2.ContentSize.height/2 ));
  item2.setPosition(ccp( s.width/2, item2.ContentSize.height/2 ));
  item3.setPosition(ccp( s.width/2 + item2.ContentSize.width * 2, item2.ContentSize.height/2 ));

  addChild(menu, 1);

  schedule(checkAnim);
end;

destructor EffectTestDemo.Destroy;
begin

  inherited;
end;

procedure EffectTestDemo.newScene;
var
  s: CCScene;
  child: CCNode;
begin
  s := EffectTestScene.Create();
  child := EffectTestDemo._create;
  s.addChild(child);
  CCDirector.sharedDirector.replaceScene(s);
  s.release;
end;

procedure EffectTestDemo.nextCallback(pObj: CCObject);
begin
  inc(actionIdx);
  actionIdx := actionIdx mod MAX_LAYER;
  newScene;
end;

procedure EffectTestDemo.onEnter;
begin
  inherited;

end;

procedure EffectTestDemo.restartCallback(pObj: CCObject);
begin
newScene;
end;

{ Waves3DDemo }

class function Waves3DDemo._create(t: Single): CCActionInterval;
begin
  Result := CCWave3D._create(t, CCSizeMake(15,10), 5, 40)
end;

{ Flip3DDemo }

class function FlipX3DDemo._create(t: Single): CCActionInterval;
var
  flipx: CCFlipX3D;
  flipx_back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  flipx := CCFlipX3D._create(t);
  flipx_back := flipx.reverse;
  delay := CCDelayTime._create(2);
  Result := CCActionInterval(CCSequence._create([flipx, delay, flipx_back]));
end;

class function FlipY3DDemo._create(t: Single): CCActionInterval;
var
  flipy: CCFlipY3D;
  flipy_back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  flipy := CCFlipY3D._create(t);
  flipy_back := flipy.reverse;
  delay := CCDelayTime._create(2);
  Result := CCActionInterval(CCSequence._create([flipy, delay, flipy_back]));
end;

{ Lens3DDemo }

class function Lens3DDemo._create(t: Single): CCActionInterval;
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector().getWinSize();
  Result := CCLens3D._create(t, CCSizeMake(15,10), ccp(size.width/2,size.height/2), 240);
end;

{ Ripple3DDemo }

class function Ripple3DDemo._create(t: Single): CCActionInterval;
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector.getWinSize;
  Result := CCRipple3D._create(t, CCSizeMake(32,24), ccp(size.width/2,size.height/2), 240, 4, 160);
end;

{ Shaky3DDemo }

class function Shaky3DDemo._create(t: Single): CCActionInterval;
begin
  Result := CCShaky3D._create(t, CCSizeMake(15,10), 5, false);
end;

{ LiquidDemo }

class function LiquidDemo._create(t: Single): CCActionInterval;
begin
  Result := CCLiquid._create(t, CCSizeMake(16,12), 4, 20);
end;

{ WavesDemo }

class function WavesDemo._create(t: Single): CCActionInterval;
begin
  Result := CCWaves._create(t, CCSizeMake(16,12), 4, 20, true, true);
end;

{ TwirlDemo }

class function TwirlDemo._create(t: Single): CCActionInterval;
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector.getWinSize;
  Result := CCTwirl._create(t, CCSizeMake(12,8), ccp(size.width/2, size.height/2), 1, 2.5);
end;

{ ShakyTiles3DDemo }

class function ShakyTiles3DDemo._create(t: Single): CCActionInterval;
begin
  Result := CCShakyTiles3D._create(t, CCSizeMake(16,12), 5, false);
end;

{ ShatteredTiles3DDemo }

class function ShatteredTiles3DDemo._create(t: Single): CCActionInterval;
begin
  Result := CCShatteredTiles3D._create(t, CCSizeMake(16,12), 5, false);
end;

{ ShuffleTilesDemo }

class function ShuffleTilesDemo._create(t: Single): CCActionInterval;
var
  shuffle: CCShuffleTiles;
  shuffle_back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  shuffle := CCShuffleTiles._create(t, CCSizeMake(16,12), 25);
  shuffle_back := shuffle.reverse();
  delay := CCDelayTime._create(2);

  Result := CCActionInterval(CCSequence._create([shuffle, delay, shuffle_back]));
end;

{ FadeOutTRTilesDemo }

class function FadeOutTRTilesDemo._create(t: Single): CCActionInterval;
var
  fadeout: CCFadeOutTRTiles;
  back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  fadeout := CCFadeOutTRTiles._create(t, CCSizeMake(16,12));
  back := fadeout.reverse;
  delay := CCDelayTime._create(0.5);
  Result := CCActionInterval(CCSequence._create([fadeout, delay, back]));
end;

{ FadeOutBLTilesDemo }

class function FadeOutBLTilesDemo._create(t: Single): CCActionInterval;
var
  fadeout: CCFadeOutBLTiles;
  back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  fadeout := CCFadeOutBLTiles._create(t, CCSizeMake(16,12));
  back := fadeout.reverse;
  delay := CCDelayTime._create(0.5);
  Result := CCActionInterval(CCSequence._create([fadeout, delay, back]));
end;

{ FadeOutUpTilesDemo }

class function FadeOutUpTilesDemo._create(t: Single): CCActionInterval;
var
  fadeout: CCFadeOutUpTiles;
  back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  fadeout := CCFadeOutUpTiles._create(t, CCSizeMake(16,12));
  back := fadeout.reverse;
  delay := CCDelayTime._create(0.5);
  Result := CCActionInterval(CCSequence._create([fadeout, delay, back]));
end;

{ FadeOutDownTilesDemo }

class function FadeOutDownTilesDemo._create(t: Single): CCActionInterval;
var
  fadeout: CCFadeOutDownTiles;
  back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  fadeout := CCFadeOutDownTiles._create(t, CCSizeMake(16,12));
  back := fadeout.reverse;
  delay := CCDelayTime._create(0.5);
  Result := CCActionInterval(CCSequence._create([fadeout, delay, back]));
end;

{ TurnOffTilesDemo }

class function TurnOffTilesDemo._create(t: Single): CCActionInterval;
var
  fadeout: CCTurnOffTiles;
  back: CCFiniteTimeAction;
  delay: CCDelayTime;
begin
  fadeout := CCTurnOffTiles._create(t, CCSizeMake(48,32), 25);
  back := fadeout.reverse;
  delay := CCDelayTime._create(0.5);
  Result := CCActionInterval(CCSequence._create([fadeout, delay, back]));
end;

{ WavesTiles3DDemo }

class function WavesTiles3DDemo._create(t: Single): CCActionInterval;
begin
  Result := CCWavesTiles3D._create(t, CCSizeMake(15,10), 4, 120);
end;

{ JumpTiles3DDemo }

class function JumpTiles3DDemo._create(t: Single): CCActionInterval;
var
  size: CCSize;
begin
  size := CCDirector.sharedDirector.getWinSize;
  Result := CCJumpTiles3D._create(t, CCSizeMake(15,10), 2, 30);
end;

{ SplitRowsDemo }

class function SplitRowsDemo._create(t: Single): CCActionInterval;
begin
  Result := CCSplitRows._create(t, 9);
end;

{ SplitColsDemo }

class function SplitColsDemo._create(t: Single): CCActionInterval;
begin
  Result := CCSplitCols._create(t, 9);
end;

{ PageTurn3DDemo }

class function PageTurn3DDemo._create(t: Single): CCActionInterval;
begin
  CCDirector.sharedDirector.setDepthTest(True);
  Result := CCPageTurn3D._create(t, CCSizeMake(15,10));
end;

end.
