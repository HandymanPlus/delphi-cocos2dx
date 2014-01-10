(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2011      Zynga Inc.

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

unit Cocos2dx.CCDirector;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  SysUtils, Math,
  Cocos2dx.CCObject, Cocos2dx.CCTypeInfo, Cocos2dx.CCScene, Cocos2dx.CCEGLView,
  Cocos2dx.CCNode, Cocos2dx.CCGeometry, Cocos2dx.CCArray, Cocos2dx.Platform,
  Cocos2dx.CCProtocols, Cocos2dx.CCApplication, Cocos2dx.CCAutoreleasePool,
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCPointExtension, Cocos2dx.CCActionManager,
  Cocos2dx.CCScheduler, Cocos2dx.CCTouchDispatcher, Cocos2dx.CCLabelTTF,
  Cocos2dx.CCAccelerometer, Cocos2dx.CCKeypadDispatcher,
  Cocos2dx.CCDirectorProjection;

type
  (**
  @brief Class that creates and handle the main Window and manages how
  and when to execute the Scenes.

   The CCDirector is also responsible for:
    - initializing the OpenGL context
    - setting the OpenGL pixel format (default on is RGB565)
    - setting the OpenGL buffer depth (default one is 0-bit)
    - setting the projection (default one is 3D)
    - setting the orientation (default one is Portrait)

   Since the CCDirector is a singleton, the standard way to use it is by calling:
    _ CCDirector::sharedDirector()->methodName();

   The CCDirector also sets the default OpenGL context:
    - GL_TEXTURE_2D is enabled
    - GL_VERTEX_ARRAY is enabled
    - GL_COLOR_ARRAY is enabled
    - GL_TEXTURE_COORD_ARRAY is enabled
  *)
  CCDirector = class(CCObject, TypeInfo)
  private
    m_pFPSLabel: CCLabelTTF;
    m_pSPFLabel: CCLabelTTF;
    m_pDrawsLabel: CCLabelTTF;
    m_pAccelerometer: CCAccelerometer;
    m_pKeypadDispatcher: CCKeypadDispatcher;
    m_pActionManager: CCActionManager;
    m_pScheduler: CCScheduler;

    function getActionManager: CCActionManager;
    procedure setActionManager(const Value: CCActionManager);
    function getScheduler: CCScheduler;
    procedure setScheduler(const Value: CCScheduler);
    function getTouchDispatcher: CCTouchDispatcher;
    procedure setTouchDispatcher(const Value: CCTouchDispatcher);
    function getAccelerometer: CCAccelerometer;
    function getKeypadDispather: CCKeypadDispatcher;
    procedure setAccelerometer(const Value: CCAccelerometer);
    procedure setKeypadDispather(const Value: CCKeypadDispatcher);
    function getDeltaTime: Single;
    procedure setDeltaTime(const Value: Single);
  public
    procedure stopAnimation(); virtual; abstract;
    procedure startAnimation(); virtual; abstract;
    procedure setAnimationInterval(dValue: Single); virtual; abstract;
    procedure mainLoop(); virtual; abstract;
  public
    constructor Create();
    destructor Destroy(); override;
    function init(): Boolean; virtual;
    function getClassTypeInfo(): Cardinal;
    function getRunningScene(): CCScene;
    function getAnimationInterval(): Single;
    function isDisplayStats(): Boolean;
    procedure setDisplayStats(bDisplayStats: Boolean);
    function getSecondsPerFrame(): Single;
    function getOpenGLView(): CCEGLView;
    procedure setOpenGLView(pobOpenGLView: CCEGLView);
    function isNextDeltaTimeZero(): Boolean;
    procedure setNextDeltaTimeZero(bNextDeltaTimeZero: Boolean);
    function isPaused(): Boolean;
    function getTotalFrames(): Cardinal;
    function getProjection(): ccDirectorProjection;
    procedure setProjection(kProjection: ccDirectorProjection);

    (** Whether or not the replaced scene will receive the cleanup message.
     If the new scene is pushed, then the old scene won't receive the "cleanup" message.
     If the new scene replaces the old one, the it will receive the "cleanup" message.
     @since v0.99.0
     *)
    function isSendCleanupToScene(): Boolean;
    function getNotificationNode(): CCNode;
    procedure setNotificationNode(node: CCNode);
    function enableRetinaDisplay(bEnableRetina: Boolean): Boolean;

    (** returns the size of the OpenGL view in points.
    *)
    function getWinSize(): CCSize;

    (** returns the size of the OpenGL view in pixels.
    *)
    function getWinSizeInPixels(): CCSize;

    (** returns visible size of the OpenGL view in points.
     *  the value is equal to getWinSize if don't invoke
     *  CCEGLView::setDesignResolutionSize()
     *)
    function getVisibleSize(): CCSize;

    //** returns visible origin of the OpenGL view in points.
    function getVisibleOrigin(): CCPoint;
    procedure reshapeProjection(const newWindowSize: CCSize);
    procedure setViewport();

    (** CCDirector delegate. It shall implemente the CCDirectorDelegate protocol
     @since v0.99.5
     *)
    function getDelegate(): CCDirectorDelegate;
    procedure setDelegate(pDelegate: CCDirectorDelegate);

    (** sets the default values based on the CCConfiguration info *)
    procedure setDefaultValues();

    (** converts a UIKit coordinate to an OpenGL coordinate
     Useful to convert (multi) touch coordinates to the current layout (portrait or landscape)
     *)
    function convertToGL(const uiPoint: CCPoint): CCPoint;
    (** converts an OpenGL coordinate to a UIKit coordinate
     Useful to convert node points to window points for calls such as glScissor
     *)
    function convertToUI(const glPoint: CCPoint): CCPoint;
    function getZEye(): Single;

    (** Enters the Director's main loop with the given Scene.
     * Call it to run only your FIRST scene.
     * Don't call it if there is already a running scene.
     *
     * It will call pushScene: and then it will call startAnimation
     *)
    procedure runWithScene(pScene: CCScene);

    (** Suspends the execution of the running scene, pushing it on the stack of suspended scenes.
     * The new scene will be executed.
     * Try to avoid big stacks of pushed scenes to reduce memory allocation. 
     * ONLY call it if there is a running scene.
     *)
    procedure pushScene(pScene: CCScene);

    (** Pops out a scene from the queue.
     * This scene will replace the running one.
     * The running scene will be deleted. If there are no more scenes in the stack the execution is terminated.
     * ONLY call it if there is a running scene.
     *)
    procedure popScene();

    (** Pops out all scenes from the queue until the root scene in the queue.
     * This scene will replace the running one.
     * Internally it will call `popToSceneStackLevel(1)`
     *)
    procedure popToRootScene();

    (** Pops out all scenes from the queue until it reaches `level`.
     If level is 0, it will end the director.
     If level is 1, it will pop all scenes until it reaches to root scene.
     If level is <= than the current stack level, it won't do anything.
     *)
    procedure popToSceneStackLevel(level: Integer);

    (** Replaces the running scene with a new one. The running scene is terminated.
     * ONLY call it if there is a running scene.
     *)
    procedure replaceScene(pScene: CCScene);

    (** Ends the execution, releases the running scene.
     It doesn't remove the OpenGL view from its parent. You have to do it manually.
     *)
    procedure _end();

    (** Pauses the running scene.
     The running scene will be _drawed_ but all scheduled timers will be paused
     While paused, the draw rate will be 4 FPS to reduce CPU consumption
     *)
    procedure pause();

    (** Resumes the paused scene
     The scheduled timers will be activated again.
     The "delta time" will be 0 (as if the game wasn't paused)
     *)
    procedure resume();

    (** Draw the scene.
    This method is called every frame. Don't call it manually.
    *)
    procedure drawScene();

    (** Removes cached all cocos2d cached data.
     It will purge the CCTextureCache, CCSpriteFrameCache, CCLabelBMFont cache
     @since v0.99.3
     *)
    procedure purgeCachedData();

    (** sets the OpenGL default values *)
    procedure setGLDefaultValues();

    (** enables/disables OpenGL alpha blending *)
    procedure setAlphaBlending(bOn: Boolean);

    (** enables/disables OpenGL depth test *)
    procedure setDepthTest(bOn: Boolean);

    (** The size in pixels of the surface. It could be different than the screen size.
    High-res devices might have a higher surface size than the screen size.
    Only available when compiled using SDK >= 4.0.
    @since v0.99.4
    *)
    procedure setContentScaleFactor(scaleFactor: Single);
    function getContentScaleFactor(): Single;
    class function sharedDirector(): CCDirector;
  protected
    m_bPurgeDirectorInNextLoop: Boolean;
    m_pTouchDispatcher: CCTouchDispatcher;
    procedure purgeDirector();
    procedure setNextScene();
    procedure showStats();
    procedure createStatsLabel();
    procedure calculateMPF();

    (** calculates delta time since last time it was called *)
    procedure calculateDeltaTime();
  protected
    m_pobOpenGLView: CCEGLView;
    m_dAnimationInterval: Single;
    m_dOldAnimationInterval: Single;
    m_bLandscape: Boolean;
    m_bDisplayStats: Boolean;
    m_fAccumDt: Single;
    m_fFrameRate: Single;
    m_bPaused: Boolean;

    (* How many frames were called since the director started *)
    m_uTotalFrames: Cardinal;
    m_uFrames: Cardinal;
    m_fSecondsFrame: Single;
    m_pRunningScene: CCScene;
    m_pNextScene: CCScene;
    m_bSendCleanupToScene: Boolean;
    m_pobScenesStack: CCArray;
    m_pLastUpdate: cc_timeval;
    m_fDeltaTime: Single;
    m_bNextDeltaTimeZero: Boolean;
    m_eProjection: ccDirectorProjection;
    m_obWinSizeInPoints: CCSize;
    m_fContentScaleFactor: Single;
    m_pszFPS: string;
    m_pNotificationNode: CCNode;
    m_pProjectionDelegate: CCDirectorDelegate;
    m_bIsContentScaleSupported: Boolean;
  public
    property ActionManager: CCActionManager read getActionManager write setActionManager;
    property Scheduler: CCScheduler read getScheduler write setScheduler;
    property TouchDispatcher: CCTouchDispatcher read getTouchDispatcher write setTouchDispatcher;
    property Accelerometer: CCAccelerometer read getAccelerometer write setAccelerometer;
    property KeypadDispather: CCKeypadDispatcher read getKeypadDispather write setKeypadDispather;
    property DeltaTime: Single read getDeltaTime write setDeltaTime;
  end;

  (**
   @brief DisplayLinkDirector is a Director that synchronizes timers with the refresh rate of the display.

   Features and Limitations:
    - Scheduled timers & drawing are synchronizes with the refresh rate of the display
    - Only supports animation intervals of 1/60 1/30 & 1/15

   @since v0.8.2
   @js NA
   @lua NA
   *)
  CCDisplayLinkDirector = class(CCDirector)
  private
    m_bInvalid: Boolean;
  public
    constructor Create();
    procedure stopAnimation(); override;
    procedure startAnimation(); override;
    procedure setAnimationInterval(dValue: Single); override;
    procedure mainLoop(); override;
  end;

function CC_DIRECTOR_STATS_POSITION(): CCPoint;

implementation
uses
  matrix, mat4, utility, Cocos2dx.CCMacros, vec3, Cocos2dx.CCGLStateCache,
  Cocos2dx.CCTextureCache, Cocos2dx.CCFileUtils, Cocos2dx.CCShaderCache,
  Cocos2dx.CCConfiguration, Cocos2dx.CCCommon, cocos2d, Cocos2dx.CCAnimationCache,
  Cocos2dx.CCSpriteFrameCache, Cocos2dx.CCTransition, Cocos2dx.CCTexture2D;

function CC_DIRECTOR_STATS_POSITION(): CCPoint;
begin
  Result := CCDirector.sharedDirector().getVisibleOrigin();
end;

{ CCDirector }

const kDefaultFPS = 60;

var s_SharedDirector: CCDisplayLinkDirector;

class function CCDirector.sharedDirector: CCDirector;
begin
  if s_SharedDirector = nil then
  begin
    s_SharedDirector := CCDisplayLinkDirector.Create();
    s_SharedDirector.init();
  end;
  Result := s_SharedDirector;
end;

procedure CCDirector.calculateDeltaTime;
var
  now: cc_timeval;
begin
  if CCTime.gettimeofdayCocos2d(@now, nil) <> 0 then
  begin
    CCLog('error in gettimeofday', []);
    m_fDeltaTime := 0;
    Exit;
  end;

  if m_bNextDeltaTimeZero then
  begin
    m_fDeltaTime := 0;
    m_bNextDeltaTimeZero := False;
  end else
  begin
    m_fDeltaTime := (now.tv_sec - m_pLastUpdate.tv_sec) + (now.tv_usec - m_pLastUpdate.tv_usec)/1000000.0;
    m_fDeltaTime := Max(0.0, m_fDeltaTime);
  end;

  m_pLastUpdate := now;
end;

procedure CCDirector.calculateMPF;
var
  now: cc_timeval;
begin
  CCTime.gettimeofdayCocos2d(@now, nil);
  m_fSecondsFrame := (now.tv_sec - m_pLastUpdate.tv_sec) + (now.tv_usec - m_pLastUpdate.tv_usec)/1000000.0;
end;

procedure GLToClipTransform(transformOut: pkmMat4);
var
  projection, modelview: kmMat4;
begin
  kmGLGetMatrix(KM_GL_PROJECTION, @projection);
  kmGLGetMatrix(KM_GL_MODELVIEW, @modelview);
  kmMat4Multiply(transformOut, @projection, @modelview);
end;  

function CCDirector.convertToGL(const uiPoint: CCPoint): CCPoint;
var
  zClip: kmScalar;
  glSize: CCSize;
  clipCoord, glCoord: kmVec3;
  transform, transformInv: kmMat4;
begin
  GLToClipTransform(@transform);
  kmMat4Inverse(@transformInv, @transform);
  zClip := transform.mat[14]/transform.mat[15];
  glSize := m_pobOpenGLView.getDesignResolutionSize();

  clipCoord.x := 2 * uiPoint.x / glSize.width - 1;
  clipCoord.y := 1 - 2 * uiPoint.y/ glSize.height;
  clipCoord.z := zClip;

  kmVec3TransformCoord(@glCoord, @clipCoord, @transformInv);

  Result := ccp(glCoord.x, glCoord.y);
end;

function CCDirector.convertToUI(const glPoint: CCPoint): CCPoint;
var
  transform: kmMat4;
  clipCoord, glCoord: kmVec3;
  glSize: CCSize;
begin
  GLToClipTransform(@transform);

  glCoord.x := glPoint.x;
  glCoord.y := glPoint.y;
  glCoord.z := 0;
  kmVec3TransformCoord(@clipCoord, @glCoord, @transform);

  glSize := m_pobOpenGLView.getDesignResolutionSize();
  Result := ccp(glSize.width * (clipCoord.x * 0.5 + 0.5), glSize.height * (-clipCoord.y * 0.5 + 0.5) );
end;

constructor CCDirector.Create;
begin
  inherited Create();
end;

procedure CCDirector.createStatsLabel;
var
  contentSize: CCSize;
begin
  if (m_pFPSLabel <> nil) and (m_pSPFLabel <> nil) and (m_pDrawsLabel <> nil) then
  begin
    CC_SAFE_RELEASE_NULL(CCObject(m_pFPSLabel));
    CC_SAFE_RELEASE_NULL(CCObject(m_pSPFLabel));
    CC_SAFE_RELEASE_NULL(CCObject(m_pDrawsLabel));

    CCFileUtils.sharedFileUtils().purgeCachedEntries();
  end;

  m_pFPSLabel := CCLabelTTF._create('00.0', 'Arial', 24);
  m_pFPSLabel.retain();
  m_pSPFLabel := CCLabelTTF._create('0.000', 'Arial', 24);
  m_pSPFLabel.retain();
  m_pDrawsLabel := CCLabelTTF._create('000', 'Arial', 24);
  m_pDrawsLabel.retain();

  contentSize := m_pDrawsLabel.ContentSize;
  m_pDrawsLabel.setPosition(ccpAdd(ccp(contentSize.width/2, contentSize.height/2 + 40), CC_DIRECTOR_STATS_POSITION));
  contentSize := m_pSPFLabel.ContentSize;
  m_pSPFLabel.setPosition(ccpAdd(ccp(contentSize.width/2, contentSize.height/2 + 20), CC_DIRECTOR_STATS_POSITION));
  contentSize := m_pFPSLabel.ContentSize;
  m_pFPSLabel.setPosition(ccpAdd(ccp(contentSize.width/2, contentSize.height/2), CC_DIRECTOR_STATS_POSITION));
end;

destructor CCDirector.Destroy;
begin
  CCLOG('cocos2d: deallocing %d', [Cardinal(Self)]);

  CC_SAFE_RELEASE(m_pFPSLabel);
  CC_SAFE_RELEASE(m_pSPFLabel);
  CC_SAFE_RELEASE(m_pDrawsLabel);

  CC_SAFE_RELEASE(m_pRunningScene);
  CC_SAFE_RELEASE(m_pNotificationNode);
  CC_SAFE_RELEASE(m_pobScenesStack);
  CC_SAFE_RELEASE(m_pScheduler);
  CC_SAFE_RELEASE(m_pActionManager);
  CC_SAFE_RELEASE(m_pTouchDispatcher);
  CC_SAFE_RELEASE(m_pKeypadDispatcher);
  m_pAccelerometer.Free;

  CCPoolManager.sharedPoolManager().pop();
  CCPoolManager.purgePoolManager();

  s_SharedDirector := nil;

  inherited;
end;

procedure CCDirector.drawScene;
begin
  calculateDeltaTime();
  if not m_bPaused then
  begin
    m_pScheduler.update(m_fDeltaTime);
  end;

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  if m_pNextScene <> nil then
  begin
    setNextScene();
  end;

  kmGLPushMatrix();

  if m_pRunningScene <> nil then
    m_pRunningScene.visit();

  if m_pNotificationNode <> nil then
    m_pNotificationNode.visit();

  if m_bDisplayStats then
  begin
    showStats();
  end;

  kmGLPopMatrix();

  Inc(m_uTotalFrames);

  if m_pobOpenGLView <> nil then
  begin
    m_pobOpenGLView.swapBuffers();
  end;

  if m_bDisplayStats then
  begin
    calculateMPF();
  end;  
end;

function CCDirector.enableRetinaDisplay(bEnableRetina: Boolean): Boolean;
var
  newScale: Single;
begin
  if bEnableRetina and (m_fContentScaleFactor = 2) then
  begin
    Result := True;
    Exit;
  end;

  if not bEnableRetina and (m_fContentScaleFactor = 1) then
  begin
    Result := False;
    Exit;
  end;


  if bEnableRetina then
    newScale := 2
  else
    newScale := 1;

  setContentScaleFactor(newScale);

  //createStatsLabel();

  Result := True;
end;

function CCDirector.getAnimationInterval: Single;
begin
  Result := m_dAnimationInterval;
end;

function CCDirector.getClassTypeInfo: Cardinal;
begin
  Result := getHashCodeByString(Self.ClassName);
end;

function CCDirector.getContentScaleFactor: Single;
begin
  Result := m_fContentScaleFactor;
end;

function CCDirector.getNotificationNode: CCNode;
begin
  Result := m_pNotificationNode;
end;

function CCDirector.getOpenGLView: CCEGLView;
begin
  Result := m_pobOpenGLView;
end;

function CCDirector.getProjection: ccDirectorProjection;
begin
  Result := m_eProjection;
end;

function CCDirector.getRunningScene: CCScene;
begin
  Result := m_pRunningScene;
end;

function CCDirector.getSecondsPerFrame: Single;
begin
  Result := m_fSecondsFrame;
end;

function CCDirector.getTotalFrames: Cardinal;
begin
  Result := m_uTotalFrames;
end;

function CCDirector.getVisibleOrigin: CCPoint;
begin
  if m_pobOpenGLView <> nil then
    Result := m_pobOpenGLView.getVisibleOrigin()
  else
    Result := CCPointZero;
end;

function CCDirector.getVisibleSize: CCSize;
begin
  if m_pobOpenGLView <> nil then
    Result := m_pobOpenGLView.getVisibleSize()
  else
    Result := CCSizeZero;
end;

function CCDirector.getWinSize: CCSize;
begin
  Result := m_obWinSizeInPoints;
end;

function CCDirector.getWinSizeInPixels: CCSize;
begin
  Result := CCSizeMake(m_obWinSizeInPoints.width * m_fContentScaleFactor, m_obWinSizeInPoints.height * m_fContentScaleFactor);
end;

function CCDirector.getZEye: Single;
begin
  Result := m_obWinSizeInPoints.height/1.1566;
end;

function CCDirector.init: Boolean;
begin
  setDefaultValues();
  
  {m_pRunningScene := nil;
  m_pNextScene := nil;
  m_pNotificationNode := nil;
  m_pProjectionDelegate := nil;
  m_fAccumDt := 0.0;
  m_fFrameRate := 0.0;
  m_pFPSLabel := nil;
  m_pSPFLabel := nil;
  m_pDrawsLabel := nil;
  m_uTotalFrames := 0;
  m_uFrames := 0;
  m_bPaused := False;
  m_bPurgeDirectorInNextLoop := False;
  m_obWinSizeInPoints := CCSizeZero;
  m_pobOpenGLView := nil;}

  m_pobScenesStack := CCArray.Create();

  m_fContentScaleFactor := 1.0;

  m_pScheduler := CCScheduler.Create();
  m_pActionManager := CCActionManager.Create();
  m_pScheduler.scheduleUpdateForTarget(m_pActionManager, kCCPrioritySystem, False);

  m_pTouchDispatcher := CCTouchDispatcher.Create;
  m_pTouchDispatcher.init();

  m_pKeypadDispatcher := CCKeypadDispatcher.Create;
  m_pAccelerometer := CCAccelerometer.Create;


  CCPoolManager.sharedPoolManager().push();

  Result := True;
end;

procedure CCDirector._end;
begin
  m_bPurgeDirectorInNextLoop := True;
end;

function CCDirector.isDisplayStats: Boolean;
begin
  Result := m_bDisplayStats;
end;

function CCDirector.isNextDeltaTimeZero: Boolean;
begin
  Result := m_bNextDeltaTimeZero;
end;

function CCDirector.isPaused: Boolean;
begin
  Result := m_bPaused;
end;

function CCDirector.isSendCleanupToScene: Boolean;
begin
  Result := m_bSendCleanupToScene;
end;

procedure CCDirector.pause;
begin
  if m_bPaused then
    Exit;

  m_dOldAnimationInterval := m_dAnimationInterval;

  setAnimationInterval(1.0/4.0);
  m_bPaused := True;
end;

procedure CCDirector.popScene;
var
  c: Cardinal;
begin
  CCAssert(m_pRunningScene <> nil, 'running scene should not null');
  m_pobScenesStack.removeLastObject();
  c := m_pobScenesStack.count();
  if c < 1 then
  begin
    _end();
  end else
  begin
    m_bSendCleanupToScene := True;
    m_pNextScene := CCScene(m_pobScenesStack.objectAtIndex(c-1));
  end;
end;

procedure CCDirector.popToRootScene;
begin
  popToSceneStackLevel(1);
end;

procedure CCDirector.purgeCachedData;
begin
  if s_SharedDirector.getOpenGLView() <> nil then
    CCTextureCache.sharedTextureCache().removeUnusedTextures();
  CCFileUtils.sharedFileUtils().purgeCachedEntries();
end;

procedure CCDirector.purgeDirector;
var
  i: Cardinal;
  prevScene: CCScene;
begin
  // cleanup scheduler
  getScheduler().unscheduleAll();
  // don't release the event handlers
  // They are needed in case the director is run again
  m_pTouchDispatcher.removeAllDelegates();

  if m_pRunningScene <> nil then
  begin
    m_pRunningScene.onExitTransitionDidStart();
    m_pRunningScene.onExit();
    m_pRunningScene.cleanup();
    m_pRunningScene.release();
  end;
  m_pRunningScene := nil;
  m_pNextScene := nil;

  //----------------------------------------------------------------
  //added by myself
  if m_pobScenesStack.count() > 1 then
  begin
    for i := 0 to m_pobScenesStack.count()-2 do
    begin
      prevScene := CCScene(m_pobScenesStack.objectAtIndex(i));
      if prevScene <> nil then
        prevScene.cleanup();
    end;  
  end;  
  //----------------------------------------------------------------
  
  // remove all objects, but don't release it.
  // runWithScene might be executed after 'end'.
  m_pobScenesStack.removeAllObjects();

  stopAnimation();

  CC_SAFE_RELEASE_NULL(CCObject(m_pFPSLabel));
  CC_SAFE_RELEASE_NULL(CCObject(m_pSPFLabel));
  CC_SAFE_RELEASE_NULL(CCObject(m_pDrawsLabel));

  //ccDrawFree();
  CCAnimationCache.purgeSharedAnimationCache();
  CCSpriteFrameCache.purgeSharedSpriteFrameCache();
  CCTextureCache.purgeSharedTextureCache();
  CCShaderCache.purgeSharedShaderCache();
  CCFileUtils.purgeFileUtils();
  CCConfiguration.purgeConfiguration();

  ccGLInvalidateStateCache();

  m_pobOpenGLView._end();
  m_pobOpenGLView := nil;

  release();
end;

procedure CCDirector.pushScene(pScene: CCScene);
begin
  CCAssert(pScene <> nil, 'the scene should not null');
  m_bSendCleanupToScene := False;
  m_pobScenesStack.addObject(pScene);
  m_pNextScene := pScene;
end;

procedure CCDirector.replaceScene(pScene: CCScene);
var
  nindex: Cardinal;
begin
  CCAssert(pScene <> nil, 'the scene should not be null');

  nindex := m_pobScenesStack.count();
  m_bSendCleanupToScene := True;
  m_pobScenesStack.replaceObjectAtIndex(nindex - 1, pScene);
  m_pNextScene := pScene;
end;

procedure CCDirector.reshapeProjection(const newWindowSize: CCSize);
begin
  if m_pobOpenGLView <> nil then
  begin
    m_obWinSizeInPoints := CCSizeMake(newWindowSize.width * m_fContentScaleFactor,
      newWindowSize.height * m_fContentScaleFactor);

    setProjection(m_eProjection);
  end;  
end;

procedure CCDirector.resume;
begin
  if not m_bPaused then
    Exit;

  setAnimationInterval(m_dOldAnimationInterval);

  if CCTime.gettimeofdayCocos2d(@m_pLastUpdate, nil) <> 0 then
  begin
    CCLOG('cocos2d: Director: Error in gettimeofday', []);
  end;

  m_bPaused := False;
  m_fDeltaTime := 0;
end;

procedure CCDirector.runWithScene(pScene: CCScene);
begin
  CCAssert(pScene <> nil, 'This command can only be used to start the CCDirector. There is already a scene present.');
  CCAssert(m_pRunningScene = nil, 'm_pRunningScene should be null');

  pushScene(pScene);
  startAnimation();
end;

procedure CCDirector.setAlphaBlending(bOn: Boolean);
begin
  if bOn then
  begin
    ccGLBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
  end else
  begin
    ccGLBlendFunc(GL_ONE, GL_ZERO);
  end;    
end;

procedure CCDirector.setContentScaleFactor(scaleFactor: Single);
begin
  if scaleFactor <> m_fContentScaleFactor then
  begin
    m_fContentScaleFactor := scaleFactor;

    //createStatsLabel();
  end;  
end;

procedure CCDirector.setDepthTest(bOn: Boolean);
begin
  if bOn then
  begin
    {$ifdef IOS}
    glClearDepthf(1.0);
    {$else}
    glClearDepth(1.0);
    {$endif}
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
  end else
  begin
    glDisable(GL_DEPTH_TEST);
  end;    
end;

procedure CCDirector.setDisplayStats(bDisplayStats: Boolean);
begin
  m_bDisplayStats := bDisplayStats;
end;

procedure CCDirector.setGLDefaultValues;
begin
  CCAssert(m_pobOpenGLView <> nil, 'opengl view should not be null');
  setAlphaBlending(True);
  setDepthTest(False);
  setProjection(m_eProjection);
  glClearColor(0.0, 0.0, 0.0, 1.0);
end;

procedure CCDirector.setNextDeltaTimeZero(bNextDeltaTimeZero: Boolean);
begin
  m_bNextDeltaTimeZero := bNextDeltaTimeZero;
end;

procedure CCDirector.setNextScene;
var
  runningIsTransition, newIsTransition: Boolean;
begin
  runningIsTransition := (m_pRunningScene <> nil) and (m_pRunningScene is CCTransitionScene);
  newIsTransition := (m_pNextScene <> nil) and (m_pNextScene is CCTransitionScene);
  if not newIsTransition then
  begin
    if m_pRunningScene <> nil then
    begin
      m_pRunningScene.onExitTransitionDidStart();
      m_pRunningScene.onExit();
    end;

    if m_bSendCleanupToScene and (m_pRunningScene <> nil) then
    begin
      m_pRunningScene.cleanup();
    end;  
  end;

  if m_pRunningScene <> nil then
    m_pRunningScene.release();

  m_pRunningScene := m_pNextScene;
  m_pNextScene.retain();
  m_pNextScene := nil;

  if not runningIsTransition and (m_pRunningScene <> nil) then
  begin
    m_pRunningScene.onEnter();
    m_pRunningScene.onEnterTransitionDidFinish();
  end;  
end;

procedure CCDirector.setNotificationNode(node: CCNode);
begin
  CC_SAFE_RELEASE(m_pNotificationNode);
  m_pNotificationNode := node;
  CC_SAFE_RETAIN(m_pNotificationNode);
end;

procedure CCDirector.setOpenGLView(pobOpenGLView: CCEGLView);
var
  conf: CCConfiguration;
begin
  CCAssert(pobOpenGLView <> nil, 'opengl view should not be null');
  if m_pobOpenGLView <> pobOpenGLView then
  begin
    conf := CCConfiguration.sharedConfiguration();
    conf.gatherGPUInfo();
    conf.dumpInfo();

    m_pobOpenGLView.Free;
    m_pobOpenGLView := pobOpenGLView;

    m_obWinSizeInPoints := m_pobOpenGLView.getDesignResolutionSize();

    createStatsLabel();

    if m_pobOpenGLView <> nil then
    begin
      setGLDefaultValues();
    end;
                          
    m_pobOpenGLView.setTouchDelegate(m_pTouchDispatcher);
    m_pTouchDispatcher.setDispatchEvents(True);
  end;
end;

procedure CCDirector.setProjection(kProjection: ccDirectorProjection);
var
  size: CCSize;
  orthoMatrix, matrixPerspective, matrixLookup: kmMat4;
  eye, center, up: kmVec3;
  zeye: Single;
begin
  size := m_obWinSizeInPoints;

  setViewport();

  case kProjection of
    kCCDirectorProjection2D:
      begin
        kmGLMatrixMode(KM_GL_PROJECTION);
        kmGLLoadIdentity();
        kmMat4OrthographicProjection(@orthoMatrix, 0, size.width, 0, size.height, -1024, 1024);
        kmGLMultMatrix(@orthoMatrix);
        kmGLMatrixMode(KM_GL_MODELVIEW);
        kmGLLoadIdentity();
      end;
    kCCDirectorProjection3D:
      begin
        zeye := getZEye();
        kmGLMatrixMode(KM_GL_PROJECTION);
        kmGLLoadIdentity();
        kmMat4PerspectiveProjection(@matrixPerspective, 60, size.width/size.height, 0.1, zeye*2);
        kmGLMultMatrix(@matrixPerspective);

        kmGLMatrixMode(KM_GL_MODELVIEW);
        kmGLLoadIdentity();

        kmVec3Fill(@eye, size.width/2.0, size.height/2.0, zeye);
        kmVec3Fill(@center, size.width/2.0, size.height/2.0, 0.0);
        kmVec3Fill(@up, 0.0, 1.0, 0.0);
        kmMat4LookAt(@matrixLookup, @eye, @center, @up);
        kmGLMultMatrix(@matrixLookup);
      end;
    kCCDirectorProjectionCustom:
      begin
        m_pProjectionDelegate.updateProjection();
      end;
  else
      begin
        CCLog('cocos2d: Director: unrecognized projection', []);
      end;  
  end;
  m_eProjection := kProjection;
  ccSetProjectionMatrixDirty();
end;

procedure CCDirector.showStats;
(** @def CC_DIRECTOR_FPS_INTERVAL
 Seconds between FPS updates.
 0.5 seconds, means that the FPS number will be updated every 0.5 seconds.
 Having a bigger number means a more reliable FPS
 
 Default value: 0.5f
 *)
const CC_DIRECTOR_STATS_INTERVAL: Single = 0.5;

begin
  Inc(m_uFrames);
  m_fAccumDt := m_fAccumDt + m_fDeltaTime;

  if m_bDisplayStats then
  begin
    if (m_pFPSLabel <> nil) and (m_pSPFLabel <> nil) and (m_pDrawsLabel <> nil) then
    begin
      if m_fAccumDt > CC_DIRECTOR_STATS_INTERVAL then
      begin
        m_pszFPS := Format('%.3f', [m_fSecondsFrame]);
        m_pSPFLabel.setString(m_pszFPS);

        m_fFrameRate := m_uFrames/m_fAccumDt;
        m_uFrames := 0;
        m_fAccumDt := 0;

        m_pszFPS := Format('%.1f', [m_fFrameRate]);
        m_pFPSLabel.setString(m_pszFPS);

        m_pszFPS := Format('%d', [g_uNumberOfDraws]);
        m_pDrawsLabel.setString(m_pszFPS);
      end;

      m_pDrawsLabel.visit();
      m_pFPSLabel.visit();
      m_pSPFLabel.visit();
    end;  
  end;
  g_uNumberOfDraws := 0;
end;

function CCDirector.getActionManager: CCActionManager;
begin
  Result := m_pActionManager;
end;

procedure CCDirector.setActionManager(const Value: CCActionManager);
begin
  if m_pActionManager <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pActionManager);
    m_pActionManager := Value;
  end;  
end;

function CCDirector.getScheduler: CCScheduler;
begin
  Result := m_pScheduler;
end;
                                                        
procedure CCDirector.setScheduler(const Value: CCScheduler);
begin
  if m_pScheduler <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pScheduler);
    m_pScheduler := Value;
  end;  
end;

function CCDirector.getTouchDispatcher: CCTouchDispatcher;
begin
  Result := m_pTouchDispatcher;
end;

procedure CCDirector.setTouchDispatcher(const Value: CCTouchDispatcher);
begin
  if m_pTouchDispatcher <> Value then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pTouchDispatcher);
    m_pTouchDispatcher := Value;
  end;  
end;

function CCDirector.getAccelerometer: CCAccelerometer;
begin
  Result := m_pAccelerometer;
end;

function CCDirector.getKeypadDispather: CCKeypadDispatcher;
begin
  Result := m_pKeypadDispatcher;
end;

procedure CCDirector.setAccelerometer(const Value: CCAccelerometer);
begin
  if m_pAccelerometer <> Value then
  begin
    m_pAccelerometer.Free;
    m_pAccelerometer := Value;
  end;  
end;

procedure CCDirector.setKeypadDispather(const Value: CCKeypadDispatcher);
begin
  CC_SAFE_RETAIN(Value);
  CC_SAFE_RELEASE(m_pKeypadDispatcher);
  m_pKeypadDispatcher := Value;
end;

procedure CCDirector.setViewport;
begin
  if m_pobOpenGLView <> nil then
    m_pobOpenGLView.setViewPortInPoints(0, 0, m_obWinSizeInPoints.width, m_obWinSizeInPoints.height);
end;

function CCDirector.getDelegate: CCDirectorDelegate;
begin
  Result := m_pProjectionDelegate;
end;

procedure CCDirector.setDelegate(pDelegate: CCDirectorDelegate);
begin
  m_pProjectionDelegate := pDelegate;
end;

procedure CCDirector.popToSceneStackLevel(level: Integer);
var
  c: Integer;
  current: CCScene;
begin
  c := m_pobScenesStack.count();
  if level = 0 then
  begin
    _end();
    Exit;
  end;

  if level >= c then
    Exit;

  while c > level do
  begin
    current := CCScene(m_pobScenesStack.lastObject);
    if current.isRunning() then
    begin
      current.onExitTransitionDidStart();
      current.onExit();
    end;

    current.cleanup();

    m_pobScenesStack.removeLastObject();
    Dec(c);
  end;

  m_pNextScene := CCScene(m_pobScenesStack.lastObject());
  m_bSendCleanupToScene := False;
end;

procedure CCDirector.setDefaultValues;
var
  conf: CCConfiguration;
  fps: Double;
  projection, pixel_format: string;
  pvr_alpha_premultipled: Boolean;
begin
  conf := CCConfiguration.sharedConfiguration();

  fps := conf.getNumber('cocos2d.x.fps', kDefaultFPS);
  m_dOldAnimationInterval := 1.0/fps;
  m_dAnimationInterval := m_dOldAnimationInterval;

  m_bDisplayStats := conf.getBool('cocos2d.x.display_fps', False);

  projection := conf.getCString('cocos2d.x.gl.projection', '3d');
  if Pos('3d', projection) > 0 then
    m_eProjection := kCCDirectorProjection3D
  else if Pos('2d', projection) > 0 then
    m_eProjection := kCCDirectorProjection2D
  else if Pos('custom', projection) > 0 then
    m_eProjection := kCCDirectorProjectionCustom
  else
    CCAssert(False, 'Invalid projection value');

  pixel_format := conf.getCString('cocos2d.x.texture.pixel_format_for_png', 'rgba8888');
  if Pos('rgba8888', pixel_format) > 0 then
  begin
    CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
  end else if Pos('rgba4444', pixel_format) > 0 then
  begin
    CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
  end else if Pos('rgba5551', pixel_format) > 0 then
  begin
    CCTexture2D.setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB5A1);
  end;

  pvr_alpha_premultipled := conf.getBool('cocos2d.x.texture.pvrv2_has_alpha_premultiplied', False);
  CCTexture2D.PVRImagesHavePremultipliedAlpha(pvr_alpha_premultipled);
end;

function CCDirector.getDeltaTime: Single;
begin
  Result := m_fDeltaTime;
end;

procedure CCDirector.setDeltaTime(const Value: Single);
begin
  m_fDeltaTime := Value;
end;

{ CCDisplayLinkDirector }

constructor CCDisplayLinkDirector.Create;
begin
  inherited Create();
  m_bInvalid := False;
end;

procedure CCDisplayLinkDirector.mainLoop;
begin
  if m_bPurgeDirectorInNextLoop then
  begin
    m_bPurgeDirectorInNextLoop := False;
    purgeDirector();
  end else if not m_bInvalid then
  begin
    drawScene();
    CCPoolManager.sharedPoolManager().pop();
  end;  
end;

procedure CCDisplayLinkDirector.setAnimationInterval(dValue: Single);
begin
  m_dAnimationInterval := dValue;
  if not m_bInvalid then
  begin
    stopAnimation();
    startAnimation();
  end;  
end;

procedure CCDisplayLinkDirector.startAnimation;
begin
  if CCTime.gettimeofdayCocos2d(@m_pLastUpdate, nil) <> 0 then
  begin
    CCLOG('cocos2d: DisplayLinkDirector: Error on gettimeofday', []);
  end;
  m_bInvalid := False;
  CCApplication.sharedApplication().setAnimationInterval(m_dAnimationInterval);
end;

procedure CCDisplayLinkDirector.stopAnimation;
begin
  m_bInvalid := True;
end;

end.
