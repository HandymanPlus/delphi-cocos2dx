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
  Cocos2dx.CCApplicationProtocol, Cocos2dx.CCFileUtils, controller, Cocos2dx.CCLayer;

{ AppDelegate }

function AppDelegate.applicationDidFinishLaunching: Boolean;
var
  pDirector: CCDirector;
  pScene: CCScene;
  target: TargetPlatform;
  pLayer: CCLayer;
begin
  pDirector := CCDirector.sharedDirector();
  pDirector.setOpenGLView(CCEGLView.sharedOpenGLView());
  pDirector.setDisplayStats(True);
  target := getTargetPlatform();

  if target = kTargetIpad then
  begin
    if pDirector.enableRetinaDisplay(True) then
    begin
      CCFileUtils.sharedFileUtils().setResourceDirectory('ipadhd');
    end else
    begin
      CCFileUtils.sharedFileUtils().setResourceDirectory('ipad');
    end;
  end else if target = kTargetIphone then
  begin
    if pDirector.enableRetinaDisplay(True) then
      CCFileUtils.sharedFileUtils().setResourceDirectory('hd');
  end;    

  pDirector.setAnimationInterval(1.0/60);
  pScene := CCScene._create();
  pLayer := TestController.Create();
  pLayer.autorelease();
  pScene.addChild(pLayer);

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
