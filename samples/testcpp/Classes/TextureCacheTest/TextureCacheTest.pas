unit TextureCacheTest;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCLayer, testBasic, Cocos2dx.CCLabelTTF;

type
  CTextureCacheTest = class(CCLayer)
  public
    constructor Create();
    procedure addSprite();
    procedure loadingCallBack(obj: CCObject);
  private
    m_pLabelLoading, m_pLabelPercent: CCLabelTTF;
    m_nNumberOfSprites, m_nNumberOfLoadedSprites: Integer;
  end;

  TextureCacheTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

implementation
uses
  Cocos2dx.CCDirector, Cocos2dx.CCGeometry, Cocos2dx.CCTextureCache;

{ TextureCacheTest }

procedure CTextureCacheTest.addSprite;
begin

end;

constructor CTextureCacheTest.Create;
var
  size: CCSize;
begin
  m_nNumberOfSprites := 20;
  m_nNumberOfLoadedSprites := 0;

  size := CCDirector.sharedDirector().getWinSize();

  m_pLabelLoading := CCLabelTTF._create('loading...', 'Arial', 15);
  m_pLabelPercent := CCLabelTTF._create('%0', 'Arial', 15);

  m_pLabelLoading.setPosition(CCPointMake(size.width/2, size.height/2 - 20));
  m_pLabelPercent.setPosition(CCPointMake(size.width/2, size.height/2 + 20));

  addChild(m_pLabelLoading);
  addChild(m_pLabelPercent);

  //CCTextureCache.sharedTextureCache().addImage('',)
end;

procedure CTextureCacheTest.loadingCallBack(obj: CCObject);
begin

end;

{ TextureCacheTestScene }

procedure TextureCacheTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := CTextureCacheTest.Create();
  addChild(pLayer);

  CCDirector.sharedDirector().replaceScene(Self);
  pLayer.release();
end;

end.
