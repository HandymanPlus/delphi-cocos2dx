unit Cocos2dx.CCFileUtilsCommon;

interface

{$I config.inc}

uses
  SysUtils, Cocos2dx.CCDictionary;

function ccFileUtils_dictionaryWithContentsOfFileThreadSafe(const pFilename: string): CCDictionary;

implementation
uses
  Cocos2dx.CCObject, Cocos2dx.CCString, Cocos2dx.CCArray, NativeXml;

type
  CCSAXState = (
    SAX_NONE,
    SAX_KEY,
    SAX_DICT,
    SAX_INT,
    SAX_REAL,
    SAX_STRING,
    SAX_ARRAY
  );

  CCSAXResult = (
    SAX_RESULT_NONE,
    SAX_RESULT_DICT,
    SAX_RESULT_ARRAY
  );

  TCCObjectArray = array [0..MaxInt div SizeOf(CCObject) - 1] of CCObject;
  PCCObjectArray = ^TCCObjectArray;

  TVectorCCObject = class
  private
    m_pCCObjectArray: PCCObjectArray;
    m_nCount: Integer;
    m_nCapacity: Integer;
  protected
    function getItem(nIdx: Integer): CCObject;
  public
    constructor Create();
    destructor Destroy(); override;
    function count(): Cardinal;
    function size(): Cardinal;
    procedure push_back(const pValue: CCObject);
    function pop(): CCObject;
    function top(): CCObject;
    function isEmpty(): Boolean;
    property Items[nIdx: Integer]: CCObject read getItem; default;
  end;

  TVectorDict = class(TVectorCCObject)
  protected
    function getItem(nIdx: Integer): CCDictionary;
  public
    function pop(): CCDictionary;
    function top(): CCDictionary;
    property Items[nIdx: Integer]: CCDictionary read getItem; default;
  end;

  TVectorCCArray = class(TVectorCCObject)
  protected
    function getItem(nIdx: Integer): CCArray;
  public
    function pop(): CCArray;
    function top(): CCArray;
    property Items[nIdx: Integer]: CCArray read getItem; default;
  end;

  TCCSAXStateArray = array [0..MaxInt div SizeOf(CCSAXState) - 1] of CCSAXState;
  PCCSAXStateArray = ^TCCSAXStateArray;

  TVectorCCSAXState = class
  private
    m_pCCSAXStateArray: PCCSAXStateArray;
    m_nCount: Integer;
    m_nCapacity: Integer;
    function getItem(nIdx: Integer): CCSAXState;
  public
    constructor Create();
    destructor Destroy(); override;
    function count(): Cardinal;
    function size(): Cardinal;
    procedure push_back(const stateValue: CCSAXState);
    function pop(): CCSAXState;
    function top(): CCSAXState;
    function isEmpty(): Boolean;
    property Items[nIdx: Integer]: CCSAXState read getItem; default;
  end;

  CCDictMaker = class
  public
    m_eResultType: CCSAXResult;
    m_pRootArray: CCArray;
    m_pRootDict: CCDictionary;
    m_pCurDict: CCDictionary;
    m_sCurKey: string;
    m_sCurValue: string;
    m_tState: CCSAXState;
    m_pArray: CCArray;
    m_tDictStack: TVectorDict;
    m_tArrayStack: TVectorCCArray;
    m_tStateStack: TVectorCCSAXState;
    procedure DoNodeNew(Sender: TObject; Node: TXmlNode);
    procedure DoNodeLoaded(Sender: TObject; Node: TXmlNode);
  public
    constructor Create();
    destructor Destroy(); override;
    function dictionaryWithContentsOfFile(const pFilename: string): CCDictionary;
    function arrayWithContentsOfFile(const pFilename: string): CCArray;
  end;

function ccFileUtils_dictionaryWithContentsOfFileThreadSafe(const pFilename: string): CCDictionary;
var
  DictMaker: CCDictMaker;
begin
  DictMaker := CCDictMaker.Create();
  Result := DictMaker.dictionaryWithContentsOfFile(pFilename);
  DictMaker.Free;
end;

{ TVectorCCObject }

function TVectorCCObject.count: Cardinal;
begin
  Result := m_nCount;
end;

constructor TVectorCCObject.Create;
begin
  m_nCount := 0;
  m_nCapacity := 10;
  m_pCCObjectArray := AllocMem(SizeOf(CCObject)*m_nCapacity);
end;

destructor TVectorCCObject.Destroy;
begin
  FreeMem(m_pCCObjectArray);
  inherited;
end;

function TVectorCCObject.getItem(nIdx: Integer): CCObject;
begin
  Assert((nIdx >= 0) and (nIdx < m_nCount), '');
  
  Result := m_pCCObjectArray^[nIdx];
end;

function TVectorCCObject.isEmpty: Boolean;
begin
  Result := m_nCount < 1;
end;

function TVectorCCObject.pop: CCObject;
begin
  Assert(m_nCount > 0, '');

  Dec(m_nCount);
  Result := m_pCCObjectArray^[m_nCount];
end;

procedure TVectorCCObject.push_back(const pValue: CCObject);
var
  pObjArray: PCCObjectArray;
  i: Integer;
begin
  if m_nCount < m_nCapacity then
  begin
    m_pCCObjectArray^[m_nCount] := pValue;
    Inc(m_nCount);
  end else
  begin
    m_nCapacity := m_nCapacity * 2;

    pObjArray := AllocMem(SizeOf(CCObject)*m_nCapacity);

    for i := 0 to m_nCount-1 do
    begin
      pObjArray^[i] := m_pCCObjectArray^[i];
    end;

    FreeMem(m_pCCObjectArray);

    m_pCCObjectArray := pObjArray;

    m_pCCObjectArray^[m_nCount] := pValue;
    Inc(m_nCount);
  end;
end;

function TVectorCCObject.size: Cardinal;
begin
  Result := m_nCount;
end;

function TVectorCCObject.top: CCObject;
begin
  Assert(m_nCount > 0, '');

  Result := m_pCCObjectArray^[m_nCount - 1];
end;

{ TVectorDict }

function TVectorDict.getItem(nIdx: Integer): CCDictionary;
begin
  Result := CCDictionary(inherited getItem(nIdx));
end;

function TVectorDict.pop: CCDictionary;
begin
  Result := CCDictionary(inherited pop());
end;

function TVectorDict.top: CCDictionary;
begin
  Result := CCDictionary(inherited top());
end;

{ TVectorCCArray }

function TVectorCCArray.getItem(nIdx: Integer): CCArray;
begin
  Result := CCArray(inherited getItem(nIdx));
end;

function TVectorCCArray.pop: CCArray;
begin
  Result := CCArray(inherited pop());
end;

function TVectorCCArray.top: CCArray;
begin
  Result := CCArray(inherited top());
end;

{ TVectorCCSAXState }

function TVectorCCSAXState.count: Cardinal;
begin
  Result := m_nCount;
end;

constructor TVectorCCSAXState.Create;
begin
  m_nCount := 0;
  m_nCapacity := 10;
  m_pCCSAXStateArray := AllocMem(SizeOf(CCSAXState)*m_nCapacity);
end;

destructor TVectorCCSAXState.Destroy;
begin
  FreeMem(m_pCCSAXStateArray);
  inherited;
end;

function TVectorCCSAXState.getItem(nIdx: Integer): CCSAXState;
begin
  Assert((nIdx >= 0) and (nIdx < m_nCount), '');
  
  Result := m_pCCSAXStateArray^[nIdx];
end;

function TVectorCCSAXState.isEmpty: Boolean;
begin
  Result := m_nCount < 1;
end;

function TVectorCCSAXState.pop: CCSAXState;
begin
  Assert(m_nCount > 0, '');

  Dec(m_nCount);
  Result := m_pCCSAXStateArray^[m_nCount];
end;

procedure TVectorCCSAXState.push_back(const stateValue: CCSAXState);
var
  pStateArray: PCCSAXStateArray;
  i: Integer;
begin
  if m_nCount < m_nCapacity then
  begin
    m_pCCSAXStateArray^[m_nCount] := stateValue;
    Inc(m_nCount);
  end else
  begin
    m_nCapacity := m_nCapacity * 2;

    pStateArray := AllocMem(SizeOf(Integer)*m_nCapacity);

    for i := 0 to m_nCount-1 do
    begin
      pStateArray^[i] := m_pCCSAXStateArray^[i];
    end;

    FreeMem(m_pCCSAXStateArray);

    m_pCCSAXStateArray := pStateArray;

    m_pCCSAXStateArray^[m_nCount] := stateValue;
    Inc(m_nCount);
  end;
end;

function TVectorCCSAXState.size: Cardinal;
begin
  Result := m_nCount;
end;

function TVectorCCSAXState.top: CCSAXState;
begin
  Assert(m_nCount > 0, '');

  Result := m_pCCSAXStateArray^[m_nCount - 1];
end;

{ CCDictMaker }

function CCDictMaker.arrayWithContentsOfFile(
  const pFilename: string): CCArray;
var
  xml: TNativeXml;
begin
  m_eResultType := SAX_RESULT_ARRAY;

{$ifdef IOS}
  xml := TNativeXml.Create();
{$else}
  xml := TNativeXml.Create(nil);
{$endif}

  //xml.Utf8Encoded := True;
  xml.OnNodeNew := DoNodeNew;
  xml.OnNodeLoaded := DoNodeLoaded;
  xml.LoadFromFile(pFilename);
  xml.Free;

  Assert(m_tArrayStack.size() = 0, 'Wrong!!!');

  Result := m_pRootArray;
end;

constructor CCDictMaker.Create;
begin
  m_eResultType := SAX_RESULT_NONE;
  m_tDictStack  := TVectorDict.Create();
  m_tArrayStack := TVectorCCArray.Create();
  m_tStateStack := TVectorCCSAXState.Create();
end;

destructor CCDictMaker.Destroy;
begin
  m_tStateStack.Free;
  m_tArrayStack.Free;
  m_tDictStack.Free;
  inherited;
end;

function CCDictMaker.dictionaryWithContentsOfFile(
  const pFilename: string): CCDictionary;
var
  xml: TNativeXml;
begin
  m_eResultType := SAX_RESULT_DICT;

{$ifdef IOS}
  xml := TNativeXml.Create();
{$else}
  xml := TNativeXml.Create(nil);
{$endif}
  xml.OnNodeNew := DoNodeNew;
  xml.OnNodeLoaded := DoNodeLoaded;
  xml.LoadFromFile(pFilename);
  xml.Free;

  Assert(m_tDictStack.size() = 0, 'Wrong!!!');

  Result := m_pRootDict;
end;

procedure CCDictMaker.DoNodeLoaded(Sender: TObject; Node: TXmlNode);
var
  pCString: CCString;
  prevState: CCSAXState;
  nodeValue, nodeName: string;
begin
  nodeName := Node.Name;
{$ifdef IOS}
  nodeValue := Node.ValueAsString;
{$else}
  nodeValue := Node.Value;
{$endif}


  if nodeName= 'key' then
  begin

    m_sCurKey := nodeValue;

  end else if (nodeName = 'integer') or (nodeName = 'real') or (nodeName = 'string') then
  begin

    pCString := CCString.Create(nodeValue);

    prevState := m_tStateStack.top();
    if prevState = SAX_DICT then
      m_pCurDict.setObject(pCString, m_sCurKey)
    else if prevState = SAX_ARRAY then
      m_pArray.addObject(pCString)
    else
    begin

    end;

    pCString.release();

  end else if nodeName = 'false' then
  begin

    pCString := CCString.Create('0');

    prevState := m_tStateStack.top();
    if prevState = SAX_DICT then
      m_pCurDict.setObject(pCString, m_sCurKey)
    else if prevState = SAX_ARRAY then
      m_pArray.addObject(pCString)
    else
    begin

    end;

    pCString.release();

  end else if nodeName = 'true' then
  begin

    pCString := CCString.Create('1');

    prevState := m_tStateStack.top();
    if prevState = SAX_DICT then
      m_pCurDict.setObject(pCString, m_sCurKey)
    else if prevState = SAX_ARRAY then
      m_pArray.addObject(pCString)
    else
    begin

    end;

    pCString.release();

  end else
  begin

    // </dict> </array> 
    if (nodeName = 'dict') and (nodeValue = '') then
    begin
        prevState := SAX_NONE;
        if not m_tStateStack.isEmpty then
          prevState := m_tStateStack.top();

        if prevState in [SAX_DICT, SAX_ARRAY] then
        begin

          //</dict>
          m_tDictStack.pop(); 
          m_tStateStack.pop();

        end;

    end;

    if (nodeName = 'array') and (nodeValue = '') then
    begin

        prevState := SAX_NONE;
        if not m_tStateStack.isEmpty then
          prevState := m_tStateStack.top();

        if prevState in [SAX_DICT, SAX_ARRAY] then
        begin

          //</array>
          m_tArrayStack.pop();
          m_tStateStack.pop();

        end;

    end;  
  end;
end;

procedure CCDictMaker.DoNodeNew(Sender: TObject; Node: TXmlNode);
var
  prevState: CCSAXState;
  prevDict: CCDictionary;
  prevArray: CCArray;
  nodeName: string;
begin
  nodeName := Node.Name;

  // <dict> <array> 
  if nodeName = 'dict' then
  begin

    m_pCurDict := CCDictionary.Create();
    if (m_eResultType = SAX_RESULT_DICT) and (m_pRootDict = nil) then
    begin
      m_pRootDict := m_pCurDict;
    end;

    prevState := SAX_NONE;
    if not m_tStateStack.isEmpty then
      prevState := m_tStateStack.top();

    if prevState = SAX_DICT then
    begin
      if m_tDictStack.count() > 0 then
      begin
        prevDict := m_tDictStack.top();
        if prevDict <> nil then
        begin
          prevDict.setObject(m_pCurDict, m_sCurKey);
          m_pCurDict.release();
        end;
      end;
    end else if prevState = SAX_ARRAY then
    begin
      if m_tArrayStack.count() > 0 then
      begin
        prevArray := m_tArrayStack.top();
        if prevArray <> nil then
        begin
          prevArray.addObject(m_pCurDict);
          m_pCurDict.release();
        end;
      end;
    end;

    m_tStateStack.push_back(SAX_DICT);
    m_tDictStack.push_back(m_pCurDict);

  end else if nodeName = 'array' then
  begin
  
    m_pArray := CCArray.Create();
    if (m_eResultType = SAX_RESULT_ARRAY) and (m_pRootArray = nil) then
    begin
      m_pRootArray := m_pArray;
    end;  

    prevState := SAX_NONE;
    if not m_tStateStack.isEmpty then
      prevState := m_tStateStack.top();

    if prevState = SAX_DICT then
    begin
      if m_tDictStack.count() > 0 then
      begin
        prevDict := m_tDictStack.top();
        if prevDict <> nil then
        begin
          prevDict.setObject(m_pArray, m_sCurKey);
          m_pArray.release();
        end;
      end;
    end else if prevState = SAX_ARRAY then
    begin
      if m_tArrayStack.count() > 0 then
      begin
        prevArray := m_tArrayStack.top();
        if prevArray <> nil then
        begin
          prevArray.addObject(m_pArray);
          m_pArray.release();
        end;
      end;
    end;

    m_tStateStack.push_back(SAX_ARRAY);
    m_tArrayStack.push_back(m_pArray);
  end;
end;

end.
