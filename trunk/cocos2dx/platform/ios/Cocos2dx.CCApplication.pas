unit Cocos2dx.CCApplication;

interface
uses
  Cocos2dx.CCApplicationProtocol, Cocos2dx.CCCommon;

type
  CCApplication = class(CCApplicationProtocol)
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedApplication(): CCApplication;
    function run(): Integer;
    procedure setAnimationInterval(interval: Double); override;
    function getCurrentLanguage(): ccLanguageType; override;
    function getTargetPlatform(): TargetPlatform; override;
  end;

procedure IOSRun();

var sm_pSharedApplication: CCApplication;

implementation
uses
  System.SysUtils, System.TypInfo, Macapi.ObjectiveC, Macapi.ObjCRuntime, Macapi.CoreFoundation,
  iOSapi.CoreGraphics, iOSapi.CocoaTypes, iOSapi.UIKit, iOSapi.Foundation, iOSapi.GLKit, iOSapi.OpenGLES,
  Cocos2dx.CCEAGLView, Cocos2dx.CCDirectorCaller, Cocos2dx.CCDirector;

{ CCApplication }

constructor CCApplication.Create;
begin
  inherited Create();
  sm_pSharedApplication := Self;
end;

destructor CCApplication.Destroy;
begin
  sm_pSharedApplication := nil;
  CCDirectorCaller.purgeDirectorCaller;
  inherited;
end;

function CCApplication.getCurrentLanguage: ccLanguageType;
var
  defaults: NSUserDefaults;
  languages: NSArray;
  currentLanguage, languageCode: NSString;
  temp: NSDictionary;
  ret: ccLanguageType;
begin
  defaults := TNSUserDefaults.Wrap(TNSUserDefaults.OCClass.standardUserDefaults);
  languages := TNSArray.Wrap(defaults.objectForKey(NSSTR('AppleLanguages')));
  currentLanguage := TNSString.Wrap(languages.objectAtIndex(0));

  temp := TNSLocale.OCClass.componentsFromLocaleIdentifier(currentLanguage);
  languageCode := TNSString.Wrap(temp.objectForKey( (NSLocaleLanguageCode as ILocalObject).GetObjectID ));

  ret := kLanguageEnglish;
  if languageCode.isEqualToString(NSSTR('zh')) then
  begin
    ret := kLanguageChinese;
  end else if languageCode.isEqualToString(NSSTR('en')) then
  begin
    ret := kLanguageEnglish;
  end else if languageCode.isEqualToString(NSSTR('fr')) then
  begin
    ret := kLanguageFrench;
  end else if languageCode.isEqualToString(NSSTR('it')) then
  begin
    ret := kLanguageItalian;
  end else if languageCode.isEqualToString(NSSTR('de')) then
  begin
    ret := kLanguageGerman;
  end else if languageCode.isEqualToString(NSSTR('es')) then
  begin
    ret := kLanguageSpanish;
  end else if languageCode.isEqualToString(NSSTR('ru')) then
  begin
    ret := kLanguageKorean;
  end else if languageCode.isEqualToString(NSSTR('ja')) then
  begin
    ret := kLanguageJapanese;
  end else if languageCode.isEqualToString(NSSTR('hu')) then
  begin
    ret := kLanguageHungarian;
  end else if languageCode.isEqualToString(NSSTR('pt')) then
  begin
    ret := kLanguagePortuguese;
  end else if languageCode.isEqualToString(NSSTR('ar')) then
  begin
    ret := kLanguageArabic;
  end;

  Result := ret;
end;

function CCApplication.getTargetPlatform: TargetPlatform;
var
  deviceModel: string;
begin
  deviceModel := UTF8ToString(TUIDevice.Wrap(TUIDevice.OCClass.currentDevice).model.UTF8String);
  if Pos(UpperCase(deviceModel), 'IPAD') > 0 then
    Result := kTargetIpad
  else
    Result := kTargetIphone;
end;

function CCApplication.run: Integer;
begin
  if applicationDidFinishLaunching() then
  begin
    CCDirectorCaller.sharedDirectorCaller().startMainLoop();
  end;

  Result := 0;
end;

procedure CCApplication.setAnimationInterval(interval: Double);
begin
  CCDirectorCaller.sharedDirectorCaller().setAnimationInterval(interval);
end;

class function CCApplication.sharedApplication: CCApplication;
begin
  Result := sm_pSharedApplication;
end;

//---------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
//ios平台相关的代码
type
  Cocos2dxViewController = interface(UIViewController)
    ['{FB1283E6-B1AB-419F-B331-160096B10C62}']
    function shouldAutorotateToInterfaceOrientation(AinterfaceOrientation: UIInterfaceOrientation): Boolean; cdecl;
    function shouldAutorotate: Boolean; cdecl;
    function supportedInterfaceOrientations: NSUInteger; cdecl;
    procedure didReceiveMemoryWarning; cdecl;
    procedure didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation); cdecl;
    procedure viewDidAppear(animated: Boolean); cdecl;
    procedure viewWillAppear(animated: Boolean); cdecl;
    procedure viewWillDisappear(animated: Boolean); cdecl;
    procedure viewDidLayoutSubviews; cdecl;
    procedure willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation; duration: NSTimeInterval); cdecl;
  end;

  TCocos2dxViewController = class(TOCLocal)
  protected
    function GetObjectiveCClass: PTypeInfo; override;
  public
    constructor Create;
    function shouldAutorotateToInterfaceOrientation(AinterfaceOrientation: UIInterfaceOrientation): Boolean; cdecl;
    function shouldAutorotate: Boolean; cdecl;
    function supportedInterfaceOrientations: NSUInteger; cdecl;
    procedure didReceiveMemoryWarning; cdecl;
    procedure didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation); cdecl;
    procedure viewDidAppear(animated: Boolean); cdecl;
    procedure viewWillAppear(animated: Boolean); cdecl;
    procedure viewWillDisappear(animated: Boolean); cdecl;
    procedure viewDidLayoutSubviews; cdecl;
    procedure willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation; duration: NSTimeInterval); cdecl;
  end;

  Cocos2dxWindow = interface(UIWindow)
    ['{F593AAFD-C4C0-4761-A886-98BE8DC68096}']
  end;

  TCocos2dxWindow = class(TOCLocal)
  protected
    function GetObjectiveCClass: PTypeInfo; override;
  public
    Text: UITextField;
    constructor Create(const ABounds: NSRect); overload;
  end;

  IAppFunc = interface
    procedure run();
  end;

  TApplicationDelegate = class(TInterfacedObject, IAppFunc)
  private
    //UIApp: UIApplication;
    //FMainScreen: UIScreen;
    //FCurrentDevice: UIDevice;
    FMainWindow: TCocos2dxWindow;
    FViewController: TCocos2dxViewController;
  public
    constructor Create;
    destructor Destroy; override;
    procedure run();
    function application(Sender: UIApplication; didFinishLaunchingWithOptions: NSDictionary): Boolean; overload; cdecl;
    procedure applicationDidReceiveMemoryWarning(Sender: UIApplication); cdecl;
    procedure applicationWillEnterForeground(Sender: UIApplication); cdecl;
    procedure applicationDidEnterBackground(const Sender: UIApplication); cdecl;
    procedure applicationWillTerminate(Sender: UIApplication); cdecl;
    procedure applicationDidBecomeActive(const Sender: UIApplication); cdecl;
    procedure applicationWillResignActive(Sender: UIApplication); cdecl;
  end;

var
  ApplicationDelegate: TApplicationDelegate;

function SharedApp(): IAppFunc;
begin
  if ApplicationDelegate = nil then
    ApplicationDelegate := TApplicationDelegate.Create;
  Result := ApplicationDelegate;
end;

//--------------------------------------------------------------------------------------------------
type
  id = Pointer;
  SEL = Pointer;
  PUIApplication = Pointer;
  PNSDictionary = Pointer;

function applicationDidFinishLaunchingWithOptions(self: id; _cmd: SEL;
  application: PUIApplication; options: PNSDictionary): Boolean; cdecl;
begin
  Result := ApplicationDelegate.application( TUIApplication.Wrap(application), TNSDictionary.Wrap(options) );
end;

procedure applicationDidReceiveMemoryWarning(self: id; _cmd: SEL; application: PUIApplication); cdecl;
begin
  ApplicationDelegate.applicationDidReceiveMemoryWarning(TUIApplication.Wrap(application));
end;

procedure applicationWillEnterForeground(self: id; _cmd: SEL; application: PUIApplication); cdecl;
begin
  ApplicationDelegate.applicationWillEnterForeground(TUIApplication.Wrap(application));
end;

procedure applicationDidEnterBackground(self: id; _cmd: SEL; application: PUIApplication); cdecl;
begin
  // This is called.
  ApplicationDelegate.applicationDidEnterBackground(TUIApplication.Wrap(application));
end;

procedure applicationWillTerminate(self: id; _cmd: SEL; application: PUIApplication); cdecl;
begin
  ApplicationDelegate.applicationWillTerminate(TUIApplication.Wrap(application));
end;

procedure applicationDidBecomeActive(self: id; _cmd: SEL; application: PUIApplication); cdecl;
begin
  ApplicationDelegate.applicationDidBecomeActive(TUIApplication.Wrap(application));
end;

procedure applicationWillResignActive(self: id; _cmd: SEL; application: PUIApplication); cdecl;
begin
  // This seems not to be called.
end;

(*procedure setWindow(self: id; _cmd: SEL; window: Pointer); cdecl;
begin

end;

function window(self: id; _cmd: SEL): Pointer; cdecl;
begin
  Result := nil;
end;

procedure applicationDidChangeStatusBarFrame(self: id; _cmd: SEL; application: PUIApplication;
  frame: CGRect); cdecl;
begin

end;

procedure applicationdidChangeStatusBarOrientation(self: id; _cmd: SEL; application: PUIApplication;
  orientation: UIInterfaceOrientation); cdecl;
begin

end;

procedure applicationDidReceiveLocalNotification(self: id; _cmd: SEL; application: PUIApplication;
  notification: Pointer); cdecl;
begin

end;*)
//--------------------------------------------------------------------------------------------------

{ TCocos2dxViewController }

constructor TCocos2dxViewController.Create;
var
  V: Pointer;
begin
  inherited;
  V := UIViewController(Super).initWithNibName(nil, nil);
  if GetObjectID <> V then
    UpdateObjectID(V);
end;

procedure TCocos2dxViewController.didReceiveMemoryWarning;
begin
  UIViewController(Super).didReceiveMemoryWarning;
end;

procedure TCocos2dxViewController.didRotateFromInterfaceOrientation(
  fromInterfaceOrientation: UIInterfaceOrientation);
begin
  UIViewController(Super).didRotateFromInterfaceOrientation(fromInterfaceOrientation);
end;

function TCocos2dxViewController.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(Cocos2dxViewController);
end;

function TCocos2dxViewController.shouldAutorotate: Boolean;
begin
   Result := True;
end;

function TCocos2dxViewController.shouldAutorotateToInterfaceOrientation(
  AinterfaceOrientation: UIInterfaceOrientation): Boolean;
begin
  Result := False;
  if UIInterfaceOrientationMaskLandscapeLeft = AinterfaceOrientation then
    Result := True;
end;

function TCocos2dxViewController.supportedInterfaceOrientations: NSUInteger;
begin
  Result := 0;
  Result := Result or UIInterfaceOrientationMaskLandscapeLeft;
  //UIInterfaceOrientationMaskLandscapeRight
  //UIInterfaceOrientationMaskPortrait
  //UIInterfaceOrientationMaskPortraitUpsideDown
  //设置ios设备支持的方向
end;

procedure TCocos2dxViewController.viewDidAppear(animated: Boolean);
begin
  UIViewController(Super).viewDidAppear(animated);
end;

procedure TCocos2dxViewController.viewDidLayoutSubviews;
begin
  UIViewController(Super).viewDidLayoutSubviews;
end;

procedure TCocos2dxViewController.viewWillAppear(animated: Boolean);
begin
  UIViewController(Super).viewWillAppear(animated);
end;

procedure TCocos2dxViewController.viewWillDisappear(animated: Boolean);
begin
  UIViewController(Super).viewWillDisappear(animated);
end;

procedure TCocos2dxViewController.willAnimateRotationToInterfaceOrientation(
  toInterfaceOrientation: UIInterfaceOrientation; duration: NSTimeInterval);
begin
  UIViewController(Super).willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration);
end;

{ TCocos2dxWindow }

constructor TCocos2dxWindow.Create(const ABounds: NSRect);
var
  V: Pointer;
begin
  inherited Create;
  V :=  UIWindow(Super).initWithFrame(ABounds);
  if GetObjectID <> V then
    UpdateObjectID(V);
end;

function TCocos2dxWindow.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(Cocos2dxWindow);
end;

{ TApplicationDelegate }

function TApplicationDelegate.application(Sender: UIApplication;
  didFinishLaunchingWithOptions: NSDictionary): Boolean;
var
  UIWin: UIWindow;
  LBounds: NSRect;
  _glView: TEAGLView;
  //_View3d: TView3d;
  ViewController: UIViewController;
begin
  //UIApp := Sender;

  FMainWindow := TCocos2dxWindow.Create(TUIScreen.Wrap(TUIScreen.OCClass.mainScreen).bounds);
  UIWin := UIWindow(FMainWindow.Super);


  LBounds := UIWin.bounds;

  //_View3d := TView3d.Create(LBounds);

  _glView := TEAGLView.createWithFrame(LBounds, NSSTR('EAGLColorFormatRGBA8'), GL_DEPTH_COMPONENT16,
                                       False, nil, False, 0);

  FViewController := TCocos2dxViewController.Create;
  ViewController := UIViewController(FViewController.Super);
  ViewController.setWantsFullScreenLayout(False);
  ViewController.setView(_glView.getView);
  //viewController.setView(_view3D.getView);

  if TUIDevice.Wrap(TUIDevice.OCClass.currentDevice).systemVersion.floatValue < 6.0 then
  begin
    UIWin.addSubview(ViewController.view);
  end else
  begin
    UIWin.setRootViewController(viewController);
  end;

  //UIWin.setAutoresizesSubviews(True);
  UIWin.makeKeyAndVisible();

  TUIApplication.Wrap(TUIApplication.OCClass.sharedApplication).setStatusBarHidden(False);

  CCApplication.sharedApplication().run();

  Result := True;
end;

procedure TApplicationDelegate.applicationDidBecomeActive(
  const Sender: UIApplication);
begin
  CCDirector.sharedDirector.resume;
end;

procedure TApplicationDelegate.applicationDidEnterBackground(
  const Sender: UIApplication);
begin
  CCApplication.sharedApplication().applicationDidEnterBackground();
end;

procedure TApplicationDelegate.applicationDidReceiveMemoryWarning(
  Sender: UIApplication);
begin

end;

procedure TApplicationDelegate.applicationWillEnterForeground(
  Sender: UIApplication);
begin
  CCApplication.sharedApplication.applicationWillEnterForeground();
end;

procedure TApplicationDelegate.applicationWillResignActive(
  Sender: UIApplication);
begin
  CCDirector.sharedDirector.pause;
end;

procedure TApplicationDelegate.applicationWillTerminate(Sender: UIApplication);
begin

end;

constructor TApplicationDelegate.Create;
var
  appDelegateClass: Pointer;
begin
  appDelegateClass := objc_allocateClassPair(objc_getClass('NSObject'), 'cocos2dxDelegate', 0);
  class_addProtocol(appDelegateClass, objc_getProtocol('UIApplicationDelegate'));
  // Add the "finish launching" delegate method
  class_addMethod(appDelegateClass, sel_getUid('application:didFinishLaunchingWithOptions:'),
    @Cocos2dx.CCApplication.applicationDidFinishLaunchingWithOptions, 'v@:@@');
  // Add additional application delegate methods
  class_addMethod(appDelegateClass, sel_getUid('applicationDidEnterBackground:'),
    @Cocos2dx.CCApplication.applicationDidEnterBackground, 'v@:@');
  class_addMethod(appDelegateClass, sel_getUid('applicationWillEnterForeground:'),
    @Cocos2dx.CCApplication.applicationWillEnterForeground, 'v@:@');
  class_addMethod(appDelegateClass, sel_getUid('applicationWillTerminate:'),
    @Cocos2dx.CCApplication.applicationWillTerminate, 'v@:@');
  class_addMethod(appDelegateClass, sel_getUid('applicationDidReceiveMemoryWarning:'),
    @Cocos2dx.CCApplication.applicationDidReceiveMemoryWarning, 'v@:@');
  class_addMethod(appDelegateClass, sel_getUid('applicationWillResignActive:'),
    @Cocos2dx.CCApplication.applicationWillResignActive, 'v@:@');
  class_addMethod(appDelegateClass, sel_getUid('applicationDidBecomeActive:'),
    @Cocos2dx.CCApplication.applicationDidBecomeActive, 'v@:@');
  (*class_addMethod(appDelegateClass, sel_getUid('setWindow:'), @Cocos2dx.CCApplication.setWindow, 'v@:@');
  class_addMethod(appDelegateClass, sel_getUid('window'), @Cocos2dx.CCApplication.window, '@@:'); // this mangling may not be right
  class_addMethod(appDelegateClass, sel_getUid('application:didReceiveLocalNotification:'),
    @Cocos2dx.CCApplication.applicationDidReceiveLocalNotification, 'v@:@@');
  class_addMethod(appDelegateClass, sel_getUid('application:didChangeStatusBarFrame:'),
    @Cocos2dx.CCApplication.applicationDidChangeStatusBarFrame, 'v@:@{CGRect={CGPoint=ff}{CGSize=ff}}');
  class_addMethod(appDelegateClass, sel_getUid('application:didChangeStatusBarOrientation:'),
    @Cocos2dx.CCApplication.applicationdidChangeStatusBarOrientation, 'v@:@l');*)

  // Register the delegate class
  objc_registerClassPair(appDelegateClass);
end;

destructor TApplicationDelegate.Destroy;
begin
  sm_pSharedApplication.Free;
  inherited;
end;

procedure TApplicationDelegate.run;
var
  pool: NSAutoreleasePool;
begin
{$WARN SYMBOL_PLATFORM OFF}
  pool := TNSAutoreleasePool.Alloc;
  pool.init;
  ExitCode := UIApplicationMain(System.ArgCount, System.ArgValues, nil,
                                (NSSTR('cocos2dxDelegate') as ILocalObject).GetObjectID);
  pool.release;
{$WARN SYMBOL_PLATFORM ON}
end;

procedure IOSRun();
begin
  SharedApp().run();
end;

end.
