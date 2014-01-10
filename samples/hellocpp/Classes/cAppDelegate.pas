unit cAppDelegate;

interface
uses
  Cocos2dx.CCApplication, Cocos2dx.CCDirector, Cocos2dx.CCEGLView, Cocos2dx.CCScene;

type
  AppDelegate = class(CCApplication)
  public
    constructor Create();
    destructor Destroy(); override;

    function applicationDidFinishLaunching(): Boolean; override;
    procedure applicationDidEnterBackground(); override;
    procedure applicationWillEnterForeground(); override;
  end;

implementation
uses
  Math,
  HelloWorldScene, Cocos2dx.CCApplicationProtocol, Cocos2dx.CCFileUtils,
  Cocos2dx.CCLayer, Cocos2dx.CCEGLViewProtocol,
  AppMacros, Cocos2dx.CCGeometry, Cocos2dx.CCVector;

{ AppDelegate }

function AppDelegate.applicationDidFinishLaunching: Boolean;
var
  pDirector: CCDirector;
  pEGLView: CCEGLView;
  frameSize: CCSize;
  searchPath: TVectorString;
  pScene: CCScene;
begin
  pDirector := CCDirector.sharedDirector;
  pEGLView := CCEGLView.sharedOpenGLView;

  pDirector.setOpenGLView(pEGLView);
  frameSize := pEGLView.getFrameSize;

  pEGLView.setDesignResolutionSize(designResolutionSize.width, designResolutionSize.height, kResolutionNoBorder);

  searchPath := TVectorString.Create;

  if frameSize.height > mediumResource.size.height then
  begin
    searchPath.push_back(largeResource.directory);
    pDirector.setContentScaleFactor(Min(largeResource.size.height/designResolutionSize.height, largeResource.size.width/designResolutionSize.width));

  end else if frameSize.height > smallResource.size.height then
  begin
    searchPath.push_back(mediumResource.directory);
    pDirector.setContentScaleFactor(Min(mediumResource.size.height/designResolutionSize.height, mediumResource.size.width/designResolutionSize.width));
  end else
  begin
    searchPath.push_back(smallResource.directory);
    pDirector.setContentScaleFactor(Min(smallResource.size.height/designResolutionSize.height, smallResource.size.width/designResolutionSize.width));
  end;
  CCFileUtils.sharedFileUtils.setSearchPaths(searchPath);
  pDirector.setDisplayStats(True);
  pDirector.setAnimationInterval(1/60);

  searchPath.Free;

  pScene := HelloWorld.scene;
  pDirector.runWithScene(pScene);
  Result := True;
end;

procedure AppDelegate.applicationWillEnterForeground;
begin
  CCDirector.sharedDirector().startAnimation();
end;

procedure AppDelegate.applicationDidEnterBackground;
begin
  CCDirector.sharedDirector().stopAnimation();
end;

constructor AppDelegate.Create;
begin
  inherited Create();
end;

destructor AppDelegate.Destroy;
begin

  inherited;
end;

end.
