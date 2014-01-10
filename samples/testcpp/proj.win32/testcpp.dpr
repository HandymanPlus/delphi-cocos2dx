 program testcpp;


uses
  Cocos2dx.CCEGLView,
  Cocos2dx.CCApplication,
  cAppDelegate in '..\Classes\cAppDelegate.pas',
  controller in '..\Classes\controller.pas',
  testBasic in '..\Classes\testBasic.pas',
  testResource in '..\Classes\testResource.pas',
  tests in '..\Classes\tests.pas',
  actionmanagertest in '..\Classes\actionmanagertest\actionmanagertest.pas',
  ActionsProgressTest in '..\Classes\actionprogresstest\ActionsProgressTest.pas',
  ActionsEaseTest in '..\Classes\ActionsEaseTest\ActionsEaseTest.pas',
  actionstest in '..\Classes\actionstest\actionstest.pas',
  box2dtest in '..\Classes\box2dtest\box2dtest.pas',
  clickandmovetest in '..\Classes\ClickAndMoveTest\clickandmovetest.pas',
  DrawPrimitivesTest in '..\Classes\DrawingPrimitives\DrawPrimitivesTest.pas',
  EffectAdvanceTest in '..\Classes\EffectAdvancetest\EffectAdvanceTest.pas',
  effectstest in '..\Classes\effectstest\effectstest.pas',
  fonttest in '..\Classes\fonttest\fonttest.pas',
  intervaltest in '..\Classes\intervaltest\intervaltest.pas',
  layertest in '..\Classes\layertest\layertest.pas',
  MotionStreakTest in '..\Classes\MotionStreakTest\MotionStreakTest.pas',
  nodetest in '..\Classes\nodetest\nodetest.pas',
  ParticleTest in '..\Classes\ParticleTest\ParticleTest.pas',
  PerformanceParticleTest in '..\Classes\PerformanceTest\PerformanceParticleTest.pas',
  PerformanceSpriteTest in '..\Classes\PerformanceTest\PerformanceSpriteTest.pas',
  PerformanceTest in '..\Classes\PerformanceTest\PerformanceTest.pas',
  rendertexturetest in '..\Classes\rendertexturetest\rendertexturetest.pas',
  rotateworldtest in '..\Classes\rotateworldtest\rotateworldtest.pas',
  scenetest in '..\Classes\scenetest\scenetest.pas',
  SchedulerTest in '..\Classes\SchedulerTest\SchedulerTest.pas',
  shadertest in '..\Classes\shadertest\shadertest.pas',
  spritetest in '..\Classes\spritetest\spritetest.pas',
  TextureCacheTest in '..\Classes\TextureCacheTest\TextureCacheTest.pas',
  TransitionsTest in '..\Classes\TransitionsTest\TransitionsTest.pas';

var
  app: AppDelegate;
  eglView: CCEGLView;
begin
  app := AppDelegate.Create();
  eglView := CCEGLView.sharedOpenGLView();
  eglView.setFrameSize(480, 320);
  CCApplication.sharedApplication().run();
  app.Free;
end.
