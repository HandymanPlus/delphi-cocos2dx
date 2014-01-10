(****************************************************************************
Copyright (c) 2010 cocos2d-x.org

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

unit Cocos2dx.CCEGLView;

interface
uses
  Windows, SysUtils, ShellAPI, Messages, Cocos2dx.CCEGLViewProtocol, Cocos2dx.CCGeometry,
  Cocos2dx.CCApplication;

type
  CUSTOM_WND_PROC = function (msg: UINT; wParam: WPARAM; lParam: LPARAM; bProcessed: PBoolean): LRESULT; stdcall;
  CCEGLView = class(CCEGLViewProtocol)
  private
    m_bCaptured: Boolean;
    m_hWnd: HWND;
    m_hDC: HDC;
    m_hRC: HGLRC;
    m_menu: string;
    m_wndproc: CUSTOM_WND_PROC;
  private
    function initGL(): Boolean;
    procedure destroyGL();
  protected
    m_fFrameZoomFactor: Single;
    function _Create(): Boolean; virtual;
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedOpenGLView(): CCEGLView;

    function isOpenGLReady(): Boolean; override;
    procedure _end(); override;
    procedure swapBuffers(); override;
    procedure setFrameSize(width, height: Single); override;
    procedure setIMEKeyboardState(bOpen: Boolean); override;
    procedure setEditorFrameSize(width, height: Single; hWnd: HWND); virtual;
    procedure setMenuResource(menu: string);
    procedure setWndProc(proc: CUSTOM_WND_PROC);
  public
    function WindowProc(msg: Cardinal; wParam: WPARAM; lParam: LPARAM): LRESULT; virtual;
    function getHWnd(): HWND;
    procedure setHWnd(hWnd: HWND);
    procedure resize(width, height: Integer); virtual;
    (*
     * Set zoom factor for frame. This method is for debugging big resolution (e.g.new ipad) app on desktop.
     *)
    procedure setFrameZoomFactor(fZoomFactor: Single);
    function getFrameZoomFactor(): Single;
    procedure centerWindow(); virtual;
    procedure setViewPortInPoints(x, y, w, h: Single); override;
    procedure setScissorInPoints(x, y, w, h: Single); override;
    //procedure setAccelerometerKeyHook()
  end;

implementation
uses
  dglOpenGL,
  Cocos2dx.CCDirector, Cocos2dx.CCCommon, Cocos2dx.CCMacros, Cocos2dx.CCPointExtension;

{ CCEGLView }

var s_pMainWindow: CCEGLView;
var s_pEglView: CCEGLView = nil;
const kWindowClassName: PChar = 'Cocos2dxWin32';

function _WindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  if (s_pMainWindow <> nil) and (s_pMainWindow.getHWnd = hWnd) then
  begin
    Result := s_pMainWindow.WindowProc(uMsg, wParam, lParam);
  end else
  begin
    Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
  end;    
end;  

function CCEGLView._Create(): Boolean;
var
  bRet: Boolean;
  wc: TWndClass;
  hInstance: Cardinal;
  rcDesktop: TRect;
  wszBuf: array [0..50-1] of Char;
begin
  bRet := False;
  repeat
    if m_hWnd <> 0 then
      Break;

    hInstance := GetModuleHandle(nil);
    FillChar(wc, SizeOf(wc), 0);

    wc.style := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
    wc.lpfnWndProc := @_WindowProc;
    wc.cbClsExtra := 0;
    wc.cbWndExtra := 0;
    wc.hInstance := hInstance;
    wc.hIcon := LoadIcon(0, IDI_WINLOGO);
    wc.hCursor := LoadCursor(0, IDC_ARROW);
    wc.hbrBackground := 0;
    wc.lpszMenuName := PChar(m_menu);
    wc.lpszClassName := kWindowClassName;

    if (RegisterClass(wc) = 0) and (GetLastError() <> 1410) then
      Break;

    GetWindowRect(GetDesktopWindow(), rcDesktop);
    StrPLCopy(@wszBuf[0], m_szViewName, Length(m_szViewName));
    m_hWnd := CreateWindowEx(WS_EX_APPWINDOW or WS_EX_WINDOWEDGE,
      kWindowClassName,
      @wszBuf[0],
      WS_CAPTION or WS_POPUPWINDOW or WS_MINIMIZEBOX,
      0, 0,
      //TODO: Initializing width with a large value to avoid getting a wrong client area by 'GetClientRect' function.
      1000,
      1000,
      0,
      0,
      hInstance,
      nil);

    if m_hWnd = 0 then
      Break;

    bRet := initGL();
    if not bRet then
    begin
      destroyGL();
      Break;
    end;

    s_pMainWindow := Self;

    bRet := True;

  until True;

  Result := bRet;
end;

procedure CCEGLView._end;
begin
  if m_hWnd <> 0 then
  begin
    DestroyWindow(m_hWnd);
    m_hWnd := 0;
  end;
  s_pMainWindow := nil;
  UnregisterClass(kWindowClassName, GetModuleHandle(nil));
  Self.Free;
end;

procedure CCEGLView.centerWindow;
var
  rcDesktop, rcWindow: TRect;
  hTaskBar: HWND;
  abd: TAppBarData;
  offsetX, offsetY: Integer;
begin
  if m_hWnd = 0 then
    Exit;

  GetWindowRect(GetDesktopWindow(), rcDesktop);
  hTaskBar := FindWindow('Shell_TrayWnd', nil);
  if hTaskBar <> 0 then
  begin
    abd.cbSize := SizeOf(TAppBarData);
    abd.hWnd := hTaskBar;
    SHAppBarMessage(ABM_GETTASKBARPOS, abd);
    SubtractRect(rcDesktop, rcDesktop, abd.rc);
  end;
  GetWindowRect(m_hWnd, rcWindow);

  offsetX := rcDesktop.Left + (rcDesktop.Right - rcDesktop.Left - (rcWindow.Right - rcWindow.Left)) div 2;
  if offsetX <= 0 then
    offsetX := rcDesktop.Left;

  offsetY := rcDesktop.Top + (rcDesktop.Bottom - rcDesktop.Top - (rcWindow.Bottom - rcWindow.Top)) div 2;
  if offsetY <= 0 then
    offsetY := rcDesktop.Top;

  SetWindowPos(m_hWnd, 0, offsetX, offsetY, 0, 0, SWP_NOCOPYBITS or SWP_NOSIZE or SWP_NOOWNERZORDER or SWP_NOZORDER);
end;

constructor CCEGLView.Create;
begin
  inherited Create();
  {m_bCaptured := False;
  m_hWnd := 0;
  m_hDC := 0;
  m_hRC := 0;
  m_menu := '';
  m_wndproc := nil;
  m_windowWidth := 0;
  m_windowHeight := 0;}
  m_fFrameZoomFactor := 1.0;
  m_szViewName := 'Cocos2dxWin32';
end;

destructor CCEGLView.Destroy;
begin

  inherited;
end;

procedure CCEGLView.destroyGL;
begin
  if (m_hDC <> 0) and (m_hRC <> 0) then
  begin
    wglMakeCurrent(m_hDC, 0);
    wglDeleteContext(m_hRC);
  end;  
end;

function CCEGLView.getHWnd: HWND;
begin
  Result := m_hWnd;
end;

function CCEGLView.initGL: Boolean;
var
  glVersion: PGLchar;
  strComplain: string;
begin
  m_hDC := GetDC(m_hWnd);
  m_hRC := CreateRenderingContext(m_hDC, [opDoubleBuffered], 32, 24, 8, 0, 0, 0);
  ActivateRenderingContext(m_hDC, m_hRC);

  glVersion := glGetString(GL_VERSION);
  CCLOG('OpenGL version = %s', [glVersion]);

  if not GL_VERSION_1_5 then
  begin
    strComplain := Format('OpenGL 1.5 or higher is required (your version is %s). Please upgrade the driver of your video card.', [glVersion]);
    CCMessageBox(strComplain, 'OpenGL version too old');
    Result := False;
    Exit;
  end;

  if GL_ARB_vertex_shader and GL_ARB_fragment_shader then
  begin
    CCLog('Ready for GLSL', []);
  end else
  begin
    CCLog('Not totally ready :(', []);
  end;

  if GL_VERSION_2_0 then
  begin
    CCLog('Ready for OpenGL 2.0', []);
  end else
  begin
    CCLog('OpenGL 2.0 not supported', []);
  end;

  glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);

  Result := True;
end;

function CCEGLView.isOpenGLReady: Boolean;
begin
  Result := (m_hDC <> 0) and (m_hRC <> 0);
end;

procedure CCEGLView.resize(width, height: Integer);
var
  rcWindow, rcClient: TRect;
  ptDiff: TPoint;
  buff: string;
  frameSize: CCSize;
begin
  if m_hWnd = 0 then
    Exit;

  GetWindowRect(m_hWnd, rcWindow);
  GetClientRect(m_hWnd, rcClient);

  ptDiff.X := (rcWindow.Right - rcWindow.Left) - rcClient.Right;
  ptDiff.Y := (rcWindow.Bottom - rcWindow.Top) - rcClient.Bottom;
  rcClient.Right := rcClient.Left + width;
  rcClient.Bottom := rcClient.Top + height;

  frameSize := getFrameSize();
  if (frameSize.width > 0) then
  begin
    buff := Format('%s - %0.0fx%0.0f - %0.2f', [m_szViewName, frameSize.width, frameSize.height, m_fFrameZoomFactor]);
    SetWindowText(m_hWnd, PChar(buff));
  end;
  AdjustWindowRectEx(rcClient, GetWindowLongW(m_hWnd, GWL_STYLE), False, GetWindowLongW(m_hWnd, GWL_EXSTYLE));
  SetWindowPos(m_hWnd, 0, 0, 0, width + ptDiff.X, height + ptDiff.Y,
    SWP_NOCOPYBITS or SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOZORDER);
end;

procedure CCEGLView.setFrameSize(width, height: Single);
begin
  _Create();
  inherited setFrameSize(width, height);
  resize(Round(width), Round(height));
  centerWindow();
end;

procedure CCEGLView.setIMEKeyboardState(bOpen: Boolean);
begin
  inherited;

end;

procedure CCEGLView.setMenuResource(menu: string);
var
  _hMenu: HMENU;
begin
  m_menu := menu;
  if m_hWnd <> 0 then
  begin
    _hMenu := LoadMenu(GetModuleHandle(nil), PChar(menu));
    SetMenu(m_hWnd, _hMenu);
  end;  
end;

procedure CCEGLView.swapBuffers;
begin
  if m_hDC <> 0 then
  begin
    Windows.SwapBuffers(m_hDC);
  end;  
end;

function CCEGLView.WindowProc(msg: Cardinal; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
var
  bProcessed: Boolean;
  point: TPoint;
  pt, tmp: CCPoint;
  id: Integer;
  ps: TPaintStruct;
begin
  bProcessed := False;

  case msg of
    WM_LBUTTONDOWN:
      begin
        if (m_pDelegate <> nil) and (MK_LBUTTON = wParam) then
        begin
          point.X := Word(lParam); point.Y := HiWord(lParam);
          pt.Create(point.X/m_fFrameZoomFactor, point.Y/m_fFrameZoomFactor);
          tmp.create(ccp(pt.x, m_obScreenSize.height - pt.y));
          if (m_obViewPortRect.equals(CCRectZero)) or (m_obViewPortRect.containsPoint(tmp)) then
          begin
            m_bCaptured := True;
            SetCapture(m_hWnd);
            id := 0;

            handleTouchesBegin(1, [id], [pt.x], [pt.y]);
          end;  
        end;  
      end;
    WM_MOUSEMOVE:
      begin
        if (MK_LBUTTON = wParam) and m_bCaptured then
        begin
          point.X := Word(lParam); point.Y := HiWord(lParam);
          pt.Create(point.X/m_fFrameZoomFactor, point.Y/m_fFrameZoomFactor);
          id := 0;

          handleTouchesMove(1, [id], [pt.x], [pt.y]);
        end;  
      end;
    WM_LBUTTONUP:
      begin
        if m_bCaptured then
        begin
          point.X := Word(lParam); point.Y := HiWord(lParam);
          pt.Create(point.X/m_fFrameZoomFactor, point.Y/m_fFrameZoomFactor);
          id := 0;

          handleTouchesEnd(1, [id], [pt.x], [pt.y]);

          ReleaseCapture();
          m_bCaptured := False;
        end;
      end;
    WM_SIZE:
      begin
        case  wParam of
          SIZE_RESTORED: CCApplication.sharedApplication().applicationWillEnterForeground();
          SIZE_MINIMIZED: CCApplication.sharedApplication().applicationDidEnterBackground();
        end;
      end;
    WM_KEYDOWN:
      begin

      end;
    WM_KEYUP:
      begin

      end;
    WM_CHAR:
      begin

      end;
    WM_PAINT:
      begin
        BeginPaint(m_hWnd, ps);
        EndPaint(m_hWnd, ps);
      end;
    WM_CLOSE:
      begin
        CCDirector.sharedDirector()._end();
      end;
    WM_DESTROY:
      begin
        destroyGL();
        PostQuitMessage(0);
      end;
  else
      begin
        if @m_wndproc <> nil then
        begin
          m_wndproc(msg, wParam, lParam, @bProcessed);
          if bProcessed then
          begin
            Result := 0;
            Exit;
          end;  
        end;
      end;
      Result := DefWindowProc(m_hWnd, msg, wParam, lParam);
      Exit;
  end;

  if (@m_wndproc <> nil) and (not bProcessed) then
    m_wndproc(msg, wParam, lParam, @bProcessed);

  Result := 0;
end;

procedure CCEGLView.setWndProc(proc: CUSTOM_WND_PROC);
begin
  m_wndproc := proc;
end;

class function CCEGLView.sharedOpenGLView: CCEGLView;
begin
  if s_pEglView = nil then
  begin
    s_pEglView := CCEGLView.Create;
    if not s_pEglView._Create() then
    begin
      s_pEglView.Free;
      s_pEglView := nil;
    end;
  end;
  Result := s_pEglView;
end;

function CCEGLView.getFrameZoomFactor: Single;
begin
  Result := m_fFrameZoomFactor;
end;

procedure CCEGLView.setEditorFrameSize(width, height: Single; hWnd: HWND);
begin
  m_hWnd := hWnd;

  resize(Round(width), Round(height));
  if initGL() then
    s_pMainWindow := Self;

  inherited setFrameSize(width, height);
end;

procedure CCEGLView.setFrameZoomFactor(fZoomFactor: Single);
begin
  m_fFrameZoomFactor := fZoomFactor;
  resize(Round(m_obScreenSize.width * fZoomFactor), Round(m_obScreenSize.height * fZoomFactor));
  centerWindow();
  CCDirector.sharedDirector().setProjection(CCDirector.sharedDirector().getProjection());
end;

procedure CCEGLView.setHWnd(hWnd: HWND);
begin
  m_hWnd := hWnd;
end;

procedure CCEGLView.setScissorInPoints(x, y, w, h: Single);
begin
    glScissor(
        Round(x * m_fScaleX * m_fFrameZoomFactor + m_obViewPortRect.origin.x * m_fFrameZoomFactor),
        Round(y * m_fScaleY * m_fFrameZoomFactor + m_obViewPortRect.origin.y * m_fFrameZoomFactor),
        Round(w * m_fScaleX * m_fFrameZoomFactor),
        Round(h * m_fScaleY * m_fFrameZoomFactor));

end;

procedure CCEGLView.setViewPortInPoints(x, y, w, h: Single);
begin
    glViewport(
        Round(x * m_fScaleX * m_fFrameZoomFactor + m_obViewPortRect.origin.x * m_fFrameZoomFactor),
        Round(y * m_fScaleY  * m_fFrameZoomFactor + m_obViewPortRect.origin.y * m_fFrameZoomFactor),
        Round(w * m_fScaleX * m_fFrameZoomFactor),
        Round(h * m_fScaleY * m_fFrameZoomFactor));
end;

end.
