program helloworld;

uses
  AppMacros in '..\Classes\AppMacros.pas',
  cAppDelegate in '..\Classes\cAppDelegate.pas',
  HelloWorldScene in '..\Classes\HelloWorldScene.pas',
  Cocos2dx.CCApplication;

begin
  sm_pSharedApplication := AppDelegate.Create();
  IOSRun();
end.
