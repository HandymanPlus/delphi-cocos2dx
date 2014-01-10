unit Cocos2dx.CCEGLViewProtocol;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Math,
  Cocos2dx.CCGeometry, Cocos2dx.CCTouchDispatcher, Cocos2dx.CCSet, Cocos2dx.CCTouch,
  Cocos2dx.CCInteger, Cocos2dx.CCPlatformMacros, Cocos2dx.CCCommon,
  Cocos2dx.CCDictionary;

type
  ResolutionPolicy =
  (
    // The entire application is visible in the specified area without trying to preserve the original aspect ratio.
    // Distortion can occur, and the application may appear stretched or compressed.
    kResolutionExactFit,
    // The entire application fills the specified area, without distortion but possibly with some cropping,
    // while maintaining the original aspect ratio of the application.
    kResolutionNoBorder,
    // The entire application is visible in the specified area without distortion while maintaining the original
    // aspect ratio of the application. Borders can appear on two sides of the application.
    kResolutionShowAll,
    // The application takes the height of the design resolution size and modifies the width of the internal
    // canvas so that it fits the aspect ratio of the device
    // no distortion will occur however you must make sure your application works on different
    // aspect ratios
    kResolutionFixedHeight,
    // The application takes the width of the design resolution size and modifies the height of the internal
    // canvas so that it fits the aspect ratio of the device
    // no distortion will occur however you must make sure your application works on different
    // aspect ratios
    kResolutionFixedWidth,

    kResolutionUnKnown
  );

const CC_MAX_TOUCHES = 5;

type
  CCEGLViewProtocol = class
  public
    constructor Create();
    destructor Destroy(); override;
    procedure _end(); virtual; abstract;
    function isOpenGLReady(): Boolean; virtual; abstract;
    procedure swapBuffers(); virtual; abstract;
    procedure setIMEKeyboardState(bOpen: Boolean); virtual; abstract;
    function getFrameSize(): CCSize; virtual;
    procedure setFrameSize(width, height: Single); virtual;
    function getVisibleSize(): CCSize; virtual;
    function getVisibleOrigin(): CCPoint; virtual;
    (**
     * Set the design resolution size.
     * @param width Design resolution width.
     * @param height Design resolution height.
     * @param resolutionPolicy The resolution policy desired, you may choose:
     *                         [1] kResolutionExactFit Fill screen by stretch-to-fit: if the design resolution ratio of width to height is different from the screen resolution ratio, your game view will be stretched.
     *                         [2] kResolutionNoBorder Full screen without black border: if the design resolution ratio of width to height is different from the screen resolution ratio, two areas of your game view will be cut.
     *                         [3] kResolutionShowAll  Full screen with black border: if the design resolution ratio of width to height is different from the screen resolution ratio, two black borders will be shown.
     *)
    procedure setDesignResolutionSize(width, height: Single; resoult: ResolutionPolicy); virtual;
    function getDesignResolutionSize(): CCSize; virtual;
    procedure setTouchDelegate(pDelegate: EGLTouchDelegate); virtual;
    procedure setViewPortInPoints(x, y, w, h: Single); virtual;
    procedure setScissorInPoints(x, y, w, h: Single); virtual;
    function isScissorEnabled(): Boolean; virtual;
    function getScissorRect(): CCRect; virtual;
    procedure setViewName(const pszViewName: string); virtual;
    function getViewName(): string; 
    procedure handleTouchesBegin(num: Integer; ids: array of Integer; xs, ys: array of Single);
    procedure handleTouchesMove(num: Integer; ids: array of Integer; xs, ys: array of Single);
    procedure handleTouchesEnd(num: Integer; ids: array of Integer; xs, ys: array of Single);
    procedure handleTouchesCancel(num: Integer; ids: array of Integer; xs, ys: array of Single);
    function getViewPortRect(): CCRect;
    function getScaleX(): Single;
    function getScaleY(): Single;
  private
    s_TouchesIntergerDict: CCDictionary;
    procedure getSetOfTouchesEndOrCancel(aset: CCSet; num: Integer; ids: array of Integer;
      xs, ys: array of Single);
  protected
    m_pDelegate: EGLTouchDelegate;
    m_obScreenSize: CCSize;
    m_obDesignResolutionSize: CCSize;
    m_obViewPortRect: CCRect;
    m_szViewName: string;
    m_fScaleX: Single;
    m_fScaleY: Single;
    m_eResolutionPolicy: ResolutionPolicy;
  end;

implementation
uses
  SysUtils,
  Cocos2dx.CCDirector;

{ CCEGLViewProtocol }

type
  TChildCCDirector = class(CCDirector);

var s_pTouches: array [0..CC_MAX_TOUCHES-1] of CCTouch;
var s_indexBitsUsed: Cardinal = 0;

function getUnUsedIndex(): Integer;
var
  i, temp: Integer;
begin
  temp := s_indexBitsUsed;
  for i := 0 to CC_MAX_TOUCHES-1 do
  begin
    if temp and $00000001 = 0 then
    begin
      s_indexBitsUsed := s_indexBitsUsed or (1 shl i);
      Result := i;
      Exit;
    end;
    temp := temp shr 1;
  end;
  Result := -1;
end;

procedure removeUsedIndexBit(nindex: Integer);
var
  temp: Cardinal;
begin
  if (nindex < 0) or (nindex >= CC_MAX_TOUCHES) then
    Exit;

  temp := 1 shl nindex;
  temp := not temp;
  s_indexBitsUsed := s_indexBitsUsed and temp;
end;

constructor CCEGLViewProtocol.Create;
begin
  m_pDelegate := nil;
  m_fScaleY := 1.0;
  m_fScaleX := 1.0;
  m_eResolutionPolicy := kResolutionUnKnown;
  s_TouchesIntergerDict := CCDictionary.Create;
end;

destructor CCEGLViewProtocol.Destroy;
begin
  s_TouchesIntergerDict.Free;
  inherited;
end;

function CCEGLViewProtocol.getDesignResolutionSize: CCSize;
begin
  Result := m_obDesignResolutionSize;
end;

function CCEGLViewProtocol.getFrameSize: CCSize;
begin
  Result := m_obScreenSize;
end;

function CCEGLViewProtocol.getScaleX: Single;
begin
  Result := m_fScaleX;
end;

function CCEGLViewProtocol.getScaleY: Single;
begin
  Result := m_fScaleY;
end;

function CCEGLViewProtocol.getScissorRect: CCRect;
var
  params: array [0..3] of GLfloat;
  x, y, w, h: Single;
begin
  glGetFloatv(GL_SCISSOR_BOX, @params[0]);
  x := (params[0] - m_obViewPortRect.origin.x) / m_fScaleX;
  y := (params[1] - m_obViewPortRect.origin.y) / m_fScaleY;
  w := params[2] / m_fScaleX;
  h := params[3] / m_fScaleY;
  Result := CCRectMake(x, y, w, h);
end;

procedure CCEGLViewProtocol.getSetOfTouchesEndOrCancel(aset: CCSet;
  num: Integer; ids: array of Integer; xs, ys: array of Single);
var
  i: Integer;
  id: Integer;
  x, y: Single;
  pIndex: CCInteger;
  pTouch: CCTouch;
begin
  for i := 0 to num-1 do
  begin
    id := ids[i];
    x := xs[i];
    y := ys[i];

    pIndex := CCInteger(s_TouchesIntergerDict.objectForKey(id));
    if pIndex = nil then
    begin
      CCLOG('if the index does not exist, it is an error', []);
      Continue;
    end;

    pTouch := s_pTouches[pIndex.getValue()];
    if pTouch <> nil then
    begin
      CCLOG('Ending touches with id: %d, x=%f, y=%f', [id, x, y]);


      pTouch.setTouchInfo(pIndex.getValue(), (x-m_obViewPortRect.origin.x)/m_fScaleX,
          (y-m_obViewPortRect.origin.y)/m_fScaleY);

      aset.addObject(pTouch);
      pTouch.release();
      s_pTouches[pIndex.getValue()] := nil;
      removeUsedIndexBit(pIndex.getValue());
      s_TouchesIntergerDict.removeObjectForKey(id);
    end else
    begin
      CCLOG('Ending touches with id: %d error', [id]);
      Exit;
    end;   
  end;

  if aset.count() = 0 then
  begin
    CCLOG('touchesEnded or touchesCancel: count = 0', []);
    Exit;
  end;  
end;

function CCEGLViewProtocol.getViewName: string;
begin

end;

function CCEGLViewProtocol.getViewPortRect: CCRect;
begin
  Result := m_obViewPortRect;
end;

function CCEGLViewProtocol.getVisibleOrigin: CCPoint;
begin
  if m_eResolutionPolicy = kResolutionNoBorder then
    Result := CCPointMake((m_obDesignResolutionSize.width-m_obScreenSize.width/m_fScaleX)/2.0,
                          (m_obDesignResolutionSize.height-m_obScreenSize.height/m_fScaleY)/2.0)
  else
    Result := CCPointZero;
end;

function CCEGLViewProtocol.getVisibleSize: CCSize;
begin
  if m_eResolutionPolicy = kResolutionNoBorder then
    Result := CCSizeMake(m_obScreenSize.width/m_fScaleX, m_obScreenSize.height/m_fScaleY)
  else
    Result := m_obDesignResolutionSize;
end;

procedure CCEGLViewProtocol.handleTouchesBegin(num: Integer;
  ids: array of Integer; xs, ys: array of Single);
var
  aset: CCSet;
  i, nUnusedIndex, id: Integer;
  pIndex, pInterObj: CCInteger;
  x, y: Single;
  pTouch: CCTouch;
begin
  aset := CCSet.Create;
  for i := 0 to num-1 do
  begin
    id := ids[i];
    x := xs[i];
    y := ys[i];

    pIndex := CCInteger(s_TouchesIntergerDict.objectForKey(id));
    if pIndex = nil then
    begin
      nUnusedIndex := getUnUsedIndex();

      if nUnusedIndex = -1 then
      begin
        CCLOG('The touches is more than MAX_TOUCHES, nUnusedIndex = %d', [nUnusedIndex]);
        continue;
      end;  

      pTouch := CCTouch.Create;
      s_pTouches[nUnusedIndex] := pTouch;


      pTouch.setTouchInfo(nUnusedIndex, (x - m_obViewPortRect.origin.x)/m_fScaleX,
          (y - m_obViewPortRect.origin.y)/m_fScaleY);


      pInterObj := CCInteger.Create(nUnusedIndex);
      s_TouchesIntergerDict.setObject(pInterObj, id);
      aset.addObject(pTouch);

      pInterObj.release();
    end;
  end;

  if aset.count() = 0 then
  begin
    CCLOG('touchesBegan: count = 0', []);
    aset.Free;
    Exit;
  end;

  m_pDelegate.touchesBegan(aset, nil);
  aset.Free;
end;

procedure CCEGLViewProtocol.handleTouchesCancel(num: Integer;
  ids: array of Integer; xs, ys: array of Single);
var
  aset: CCSet;
begin
  aset := CCSet.Create;
  getSetOfTouchesEndOrCancel(aset, num, ids, xs, ys);
  m_pDelegate.touchesCancelled(aset, nil);
  aset.Free;
end;

procedure CCEGLViewProtocol.handleTouchesEnd(num: Integer;
  ids: array of Integer; xs, ys: array of Single);
var
  aset: CCSet;
begin
  aset := CCSet.Create;
  getSetOfTouchesEndOrCancel(aset, num, ids, xs, ys);
  m_pDelegate.touchesEnded(aset, nil);
  aset.Free;
end;

procedure CCEGLViewProtocol.handleTouchesMove(num: Integer;
  ids: array of Integer; xs, ys: array of Single);
var
  aset: CCSet;
  i, id: Integer;
  x, y: Single;
  pIndex: CCInteger;
  pTouch: CCTouch;
begin
  aset := CCSet.Create;
  for i:= 0 to num-1 do
  begin
    id := ids[i];
    x := xs[i];
    y := ys[i];

    pIndex := CCInteger(s_TouchesIntergerDict.objectForKey(id));
    if pIndex = nil then
    begin
      CCLOG('if the index does not exist, it is an error', []);
      Continue;
    end;

    pTouch := s_pTouches[pIndex.getValue()];
    if pTouch <> nil then
    begin

      pTouch.setTouchInfo(pIndex.getValue(), (x - m_obViewPortRect.origin.x)/m_fScaleX,
          (y - m_obViewPortRect.origin.y)/m_fScaleY);

      aset.addObject(pTouch);
    end else
    begin

      Exit;
    end;
  end;

  if aset.count() = 0 then
  begin

    Exit;
  end;

  m_pDelegate.touchesMoved(aset, nil);
  aset.Free;
end;

function CCEGLViewProtocol.isScissorEnabled: Boolean;
begin
  Result := glIsEnabled(GL_SCISSOR_TEST) = GL_TRUE;
end;

procedure CCEGLViewProtocol.setDesignResolutionSize(width, height: Single;
  resoult: ResolutionPolicy);
var
  viewPortW, viewPortH: Single;
begin
  CCAssert(resoult <> kResolutionUnKnown, 'should set resolutionPolicy');
  if (width = 0.0) or (height = 0.0) then
    Exit;

  m_obDesignResolutionSize.setSize(width, height);
  m_fScaleX := m_obScreenSize.width/m_obDesignResolutionSize.width;
  m_fScaleY := m_obScreenSize.height/m_obDesignResolutionSize.height;

  if resoult = kResolutionNoBorder then
  begin
    m_fScaleX := Max(m_fScaleX, m_fScaleY);
    m_fScaleY := m_fScaleX;
  end;

  if resoult = kResolutionShowAll then
  begin
    m_fScaleX := Min(m_fScaleX, m_fScaleY);
    m_fScaleY := m_fScaleX;
  end;

  if resoult = kResolutionFixedHeight then
  begin
    m_fScaleX := m_fScaleY;
    m_obDesignResolutionSize.width := Ceil(m_obScreenSize.width/m_fScaleX);
  end;

  if resoult = kResolutionFixedWidth then
  begin
    m_fScaleY := m_fScaleX;
    m_obDesignResolutionSize.height := Ceil(m_obScreenSize.height/m_fScaleY);
  end;

  viewPortW := m_obDesignResolutionSize.width*m_fScaleX;
  viewPortH := m_obDesignResolutionSize.height*m_fScaleY;

  m_obViewPortRect.setRect((m_obScreenSize.width-viewPortW)/2.0, (m_obScreenSize.height-viewPortH)/2.0,
    viewPortW, viewPortH);
  m_eResolutionPolicy := resoult;

  TChildCCDirector(CCDirector.sharedDirector()).m_obWinSizeInPoints := getDesignResolutionSize();
  //TChildCCDirector(CCDirector.sharedDirector()).createStatsLabel();
  CCDirector.sharedDirector().setGLDefaultValues();
end;

procedure CCEGLViewProtocol.setFrameSize(width, height: Single);
begin
  m_obDesignResolutionSize := CCSizeMake(width, height);
  m_obScreenSize := m_obDesignResolutionSize;
end;

procedure CCEGLViewProtocol.setScissorInPoints(x, y, w, h: Single);
begin
  glScissor(Round(x*m_fScaleX + m_obViewPortRect.origin.x),
            Round(y*m_fScaleY + m_obViewPortRect.origin.y),
            Round(w*m_fScaleX),
            Round(h*m_fScaleY));
end;

procedure CCEGLViewProtocol.setTouchDelegate(pDelegate: EGLTouchDelegate);
begin
  m_pDelegate := pDelegate;
end;

procedure CCEGLViewProtocol.setViewName(const pszViewName: string);
begin
  if pszViewName <> '' then
    m_szViewName := pszViewName;
end;

procedure CCEGLViewProtocol.setViewPortInPoints(x, y, w, h: Single);
begin
  glViewport(Round(x*m_fScaleX + m_obViewPortRect.origin.x),
             Round(y*m_fScaleY + m_obViewPortRect.origin.y),
             Round(w*m_fScaleX),
             Round(h*m_fScaleY));
end;

end.
