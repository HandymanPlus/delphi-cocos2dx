unit Cocos2dx.CCTextFieldTTF;

interface
uses
  cLabelTTF, cTouchDelegateProtocol, cGeometry, cTypes, Cocos2dX.CCIMEDelegate;

type
  CCTextFieldTTF = class;

  CCTextFieldDelegate = interface
    function onTextFieldAttachWithIME(sender: CCTextFieldTTF): Boolean;
    function onTextFieldDetachWithIME(sender: CCTextFieldTTF): Boolean;
    function onTextFieldInsertText(sender: CCTextFieldTTF; const text: string; nLen: Integer): Boolean;
    function onTextFieldDeleteBackward(sender: CCTextFieldTTF; const delText: string; nLen: Integer): Boolean;
    function onDraw(sender: CCTextFieldTTF): Boolean;
  end;

  CCTextFieldTTF = class(CCLabelTTF, CCIMEDelegate)
  private
    m_pDelegate: CCTextFieldDelegate;
    m_nCharCount: Integer;
    m_ColorSpaceHolder: ccColor3B;
  protected
    m_pInputText: string;
    m_pPlaceHolder: string;
  public
    property Delegate: CCTextFieldDelegate read m_pDelegate write m_pDelegate;
    property CharCount: Integer read m_nCharCount;
    property ColorSpaceHolder: ccColor3B read m_ColorSpaceHolder write m_ColorSpaceHolder;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure draw(); override;
    class function textFieldWithPlaceHolder(const placeholder: string; const dimensions: CCSize; alignment: CCTextAlignment; const fontName: string; fontSize: Single): CCTextFieldTTF; overload;
    class function textFieldWithPlaceHolder(const placeholder: string; const fontName: string; fontSize: Single): CCTextFieldTTF; overload;
    function initWithPlaceHolder(const placeholder: string; const dimensions: CCSize; alignment: CCTextAlignment; const fontName: string; fontSize: Single): Boolean; overload;
    function initWithPlaceHolder(const placeholder: string; const fontName: string; fontSize: Single): Boolean; overload;
    procedure setPlaceHolder(const text: string); virtual;
    function getPlaceHolder(): string; virtual;
    //interface
    procedure setString(const slabel: string); override;
    function getString(): string; override;
  public
    function attachWithIME(): Boolean;
    function detachWithIME(): Boolean;
    function canAttachWithIME(): Boolean;
    procedure didAttachWithIME();
    function canDetachWithIME(): Boolean;
    procedure didDetachWithIME();
    procedure insertText(const text: string; len: Integer);
    procedure deleteBackward();
    function getContentText(): string;
    procedure keyboardWillShow(var info: CCIMEKeyboardNotificationInfo);
    procedure keyboardDidShow(var info: CCIMEKeyboardNotificationInfo);
    procedure keyboardWillHide(var info: CCIMEKeyboardNotificationInfo);
    procedure keyboardDidHide(var info: CCIMEKeyboardNotificationInfo);
  end;

implementation
uses
  cPlatformMacros, cDirector, cEGLView, Cocos2dX.CCIMEDispatcher;

function _calcCharCount(const pszText: string): Integer;
begin
  Result := 0;
end;  

{ CCTextFieldTTF }

function CCTextFieldTTF.attachWithIME: Boolean;
var
  bRet: Boolean;
  pGLView: CCEGLView;
begin
  bRet := CCIMEDispatcher.sharedDispatcher().attachDelegateWithIME(Self);
  if bRet then
  begin
    pGLView := CCDirector.sharedDirector().getOpenGLView();
    if pGLView <> nil then
    begin
      pGLView.setIMEKeyboardState(True);
    end;  
  end;  
  Result := bRet;
end;

function CCTextFieldTTF.canAttachWithIME: Boolean;
begin
  if m_pDelegate <> nil then
    Result := m_pDelegate.onTextFieldAttachWithIME(Self)
  else
    Result := True;
end;

function CCTextFieldTTF.canDetachWithIME: Boolean;
begin
  if m_pDelegate <> nil then
    Result := m_pDelegate.onTextFieldDetachWithIME(Self)
  else
    Result := True;
end;

constructor CCTextFieldTTF.Create;
begin
  inherited Create();
  m_ColorSpaceHolder.r := 127;
  m_ColorSpaceHolder.g := 127;
  m_ColorSpaceHolder.b := 127;
end;

procedure CCTextFieldTTF.deleteBackward;
begin

end;

destructor CCTextFieldTTF.Destroy;
begin

  inherited;
end;

function CCTextFieldTTF.detachWithIME: Boolean;
var
  bRet: Boolean;
  pGLView: CCEGLView;
begin
  bRet := CCIMEDispatcher.sharedDispatcher().attachDelegateWithIME(Self);
  if bRet then
  begin
    pGLView := CCDirector.sharedDirector().getOpenGLView();
    if pGLView <> nil then
    begin
      pGLView.setIMEKeyboardState(False);
    end;
  end;
  Result := bRet;
end;

procedure CCTextFieldTTF.didAttachWithIME;
begin

end;

procedure CCTextFieldTTF.didDetachWithIME;
begin

end;

procedure CCTextFieldTTF.draw;
var
  color: ccColor3B;
begin
  if (m_pDelegate <> nil) and m_pDelegate.onDraw(Self) then
    Exit;

  if Length(m_pInputText) > 0 then
  begin
    inherited draw();
    Exit;
  end;

  color := getColor();
  setColor(m_ColorSpaceHolder);
  inherited draw();
  setColor(color);
end;

function CCTextFieldTTF.getContentText: string;
begin
  Result := m_pInputText;
end;

function CCTextFieldTTF.getPlaceHolder: string;
begin
  Result := m_pPlaceHolder;
end;

function CCTextFieldTTF.initWithPlaceHolder(const placeholder: string;
  const dimensions: CCSize; alignment: CCTextAlignment;
  const fontName: string; fontSize: Single): Boolean;
begin
  if placeholder <> '' then
    m_pPlaceHolder := placeholder;
  Result := initWithString(m_pPlaceHolder, fontName, fontSize, dimensions, alignment);
end;

function CCTextFieldTTF.getString: string;
begin
  Result := m_pInputText;
end;

function CCTextFieldTTF.initWithPlaceHolder(const placeholder,
  fontName: string; fontSize: Single): Boolean;
begin
  if placeholder <> '' then
    m_pPlaceHolder := placeholder;
  Result := initWithString(m_pPlaceHolder, fontName, fontSize);
end;

procedure CCTextFieldTTF.insertText(const text: string; len: Integer);
begin

end;

procedure CCTextFieldTTF.keyboardDidHide(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

procedure CCTextFieldTTF.keyboardDidShow(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

procedure CCTextFieldTTF.keyboardWillHide(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

procedure CCTextFieldTTF.keyboardWillShow(
  var info: CCIMEKeyboardNotificationInfo);
begin

end;

procedure CCTextFieldTTF.setPlaceHolder(const text: string);
begin
  m_pPlaceHolder := text;
  if m_pInputText = '' then
    inherited setString(m_pPlaceHolder);
end;

procedure CCTextFieldTTF.setString(const slabel: string);
begin
  m_pInputText := slabel;
  if Length(m_pInputText) = 0 then
  begin
    inherited setString(m_pPlaceHolder);
  end else
  begin
    inherited setString(m_pInputText);
  end;
  m_nCharCount := _calcCharCount(m_pInputText);
end;

class function CCTextFieldTTF.textFieldWithPlaceHolder(const placeholder,
  fontName: string; fontSize: Single): CCTextFieldTTF;
var
  pRet: CCTextFieldTTF;
begin
  pRet := CCTextFieldTTF.Create();
  if (pRet <> nil) and pRet.initWithPlaceHolder('', fontName, fontSize) then
  begin
    pRet.autorelease();
    if placeholder <> '' then
    begin
      pRet.setPlaceHolder(placeholder);
    end;
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

class function CCTextFieldTTF.textFieldWithPlaceHolder(
  const placeholder: string; const dimensions: CCSize;
  alignment: CCTextAlignment; const fontName: string;
  fontSize: Single): CCTextFieldTTF;
var
  pRet: CCTextFieldTTF;
begin
  pRet := CCTextFieldTTF.Create();
  if (pRet <> nil) and pRet.initWithPlaceHolder('', dimensions, alignment, fontName, fontSize) then
  begin
    pRet.autorelease();
    if placeholder <> '' then
    begin
      pRet.setPlaceHolder(placeholder);
    end;
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

end.
