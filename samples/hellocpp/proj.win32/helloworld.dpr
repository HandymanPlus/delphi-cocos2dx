program helloworld;


uses
  AppMacros in '..\Classes\AppMacros.pas',
  cAppDelegate in '..\Classes\cAppDelegate.pas',
  HelloWorldScene in '..\Classes\HelloWorldScene.pas',
  Cocos2dx.CCEGLView,
  Cocos2dx.CCApplication;

var
  app: AppDelegate;
  eglView: CCEGLView;
begin
  app := AppDelegate.Create();
  eglView := CCEGLView.sharedOpenGLView();
  eglView.setViewName('HelloCpp');
  eglView.setFrameSize(1024, 768);
  eglView.setFrameZoomFactor(0.4);
  CCApplication.sharedApplication().run();
  app.Free;
end.
