unit Cocos2dx.CCEGLView;

interface
uses
  Cocos2dx.CCEGLViewProtocol, Cocos2dx.CCCommon;

type
  CCEGLView = class(CCEGLViewProtocol)
  public
    constructor Create();
    destructor Destroy(); override;
    class function sharedOpenGLView(): CCEGLView;

    procedure _end(); override;
    function isOpenGLReady(): Boolean; override;
    procedure swapBuffers(); override;
    procedure setIMEKeyboardState(bOpen: Boolean); override;

    function setContentScaleFactor(contentScaleFactor: Single): Boolean;
  end;

implementation
uses
  iOSapi.UIKit, iOSapi.GLKit,
  Cocos2dx.CCEAGLView, Cocos2dx.CCDirectorCaller;

var _CCEGLView: CCEGLView;

{ CCEGLView }

constructor CCEGLView.Create;
begin
  inherited Create();
  m_obScreenSize.width := TEAGLView.sharedEAGLView.width;
  m_obScreenSize.height := TEAGLView.sharedEAGLView.height;

  //m_obScreenSize.width := TView3d.sharedEAGLView.width;
  //m_obScreenSize.height := TView3d.sharedEAGLView.height;
end;

destructor CCEGLView.Destroy;
begin

  inherited;
end;


function CCEGLView.isOpenGLReady: Boolean;
begin
  //Result := TView3d.sharedEAGLView <> nil;
  Result := TEAGLView.sharedEAGLView <> nil;
end;

function CCEGLView.setContentScaleFactor(contentScaleFactor: Single): Boolean;
var
  view: UIView;
begin
  m_fScaleX := contentScaleFactor;
  m_fScaleY := m_fScaleX;

  //view := TView3d.sharedEAGLView.getView;
  view := TEAGLView.sharedEAGLView.getView;
  view.setNeedsLayout();
  Result := True;
end;

procedure CCEGLView.setIMEKeyboardState(bOpen: Boolean);
begin

end;

class function CCEGLView.sharedOpenGLView: CCEGLView;
begin
  if _CCEGLView = nil then
    _CCEGLView := CCEGLView.Create;
  Result := _CCEGLView;
end;

procedure CCEGLView.swapBuffers;
begin
  //TView3d.sharedEAGLView.swapBuffers;
  TEAGLView.sharedEAGLView.swapBuffers;
end;

procedure CCEGLView._end;
begin
  TEAGLView.purgeEAGLView;
end;

end.
