(****************************************************************************
Copyright (c) 2012 - 2013 cocos2d-x.org

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

unit Cocos2dx.CCDictionary;

interface
uses
  SysUtils,
  Cocos2dx.CCObject, Cocos2dx.CCArray, Cocos2dx.CCString, tdHashChain;

type
  CCDictType =
  (
        kCCDictUnknown = 0,
        kCCDictStr,
        kCCDictInt
  );

  //**
  // *  CCDictionary is a class like NSDictionary in Obj-C .
  // *
  // *  @note Only the pointer of CCObject or its subclass can be inserted to CCDictionary.
  // *  @code
  // *  // Create a dictionary, return an autorelease object.
  // *  CCDictionary* pDict = CCDictionary::create();
  // *
  // *  // Insert objects to dictionary
  // *  CCString* pValue1 = CCString::create("100");
  // *  CCString* pValue2 = CCString::create("120");
  // *  CCInteger* pValue3 = CCInteger::create(200);
  // *  pDict->setObject(pValue1, "key1");
  // *  pDict->setObject(pValue2, "key2");
  // *  pDict->setObject(pValue3, "key3");
  // *
  // *  // Get the object for key
  // *  CCString* pStr1 = (CCString*)pDict->objectForKey("key1");
  // *  CCLog("{ key1: %s }", pStr1->getCString());
  // *  CCInteger* pInteger = (CCInteger*)pDict->objectForKey("key3");
  // *  CCLog("{ key3: %d }", pInteger->getValue());
  // *  @endcode
  // *  @js NA
  // *
  // *
  CCDictionary = class(CCObject)
  private
    m_eDictType, m_eOldDictType: CCDictType;
    m_pHashChain: TtdHashTableChain;
    procedure setObjectUnSafe(pObj: CCObject; const key: string); overload;
    procedure setObjectUnSafe(pObj: CCObject; key: Integer); overload;
  public
    m_pElement: CCDictElement;
  public
    constructor Create();
    destructor Destroy(); override;
    function count(): Integer;

    (**
     *  Return all keys of elements.
     *
     *  @return  The array contains all keys of elements. It's an autorelease object yet.
     *)
    function allKeys(): CCArray;

    (** 
     *  Get all keys according to the specified object.
     *  @warning  We use '==' to compare two objects
     *  @return   The array contains all keys for the specified object. It's an autorelease object yet.
     *)
    function allKeysForObject(pObj: CCObject): CCArray;

    //**
    //*  Get the object according to the specified string key.
    //*
    //*  @note The dictionary needs to use string as key. If integer is passed, an assert will appear.
    //*  @param key  The string key for searching.
    //*  @return The object matches the key. You need to force convert it to the type you know.
    //*  @code
    //*     // Assume that the elements are CCString* pointers. Convert it by following code.
    //*     CCString* pStr = (CCString*)pDict->objectForKey("key1");
    //*     // Do something about pStr.
    //*     // If you don't know the object type, properly you need to use dynamic_cast<SomeType*> to check it.
    //*     CCString* pStr2 = dynamic_cast<CCString*>(pDict->objectForKey("key1"));
    //*     if (pStr2 != NULL) {
    //*          // Do something about pStr2
    //*     }
    //*  @endcode
    //*  @see objectForKey(intptr_t)
    //*
    function objectForKey(const key: string): CCObject; overload;

    (**
     *  Get the object according to the specified integer key.
     *
     *  @note The dictionary needs to use integer as key. If string is passed, an assert will appear.
     *  @param key  The integer key for searching.
     *  @return The object matches the key.
     *  @see objectForKey(const std::string&)
     *)
    function objectForKey(key: Integer): CCObject; overload;

    (** Get the value according to the specified string key.
     *
     *  @note Be careful to use this function since it assumes the objects in the dictionary are CCString pointer.
     *  @param key  The string key for searching
     *  @return An instance of CCString.
     *          It will return an empty string if the objects aren't CCString pointer or the key wasn't found.
     *  @see valueForKey(intptr_t)
     *)
    function valueForKey(const key: string): CCString; overload;

    (** Get the value according to the specified integer key.
     *
     *  @note Be careful to use this function since it assumes the objects in the dictionary are CCString pointer.
     *  @param key  The string key for searching.
     *  @return An instance of CCString.
     *          It will return an empty string if the objects aren't CCString pointer or the key wasn't found.
     *  @see valueForKey(intptr_t)
     *)
    function valueForKey(key: Integer): CCString; overload;

    (** Insert an object to dictionary, and match it with the specified string key.
     *
     *  @note Whe the first time this method is invoked, the key type will be set to string.
     *        After that you can't setObject with an integer key.
     *        If the dictionary contains the key you passed, the object matching the key will be released and removed from dictionary.
     *        Then the new object will be inserted after that.
     *
     *  @param pObject  The Object to be inserted.
     *  @param key      The string key for searching.
     *  @see setObject(CCObject*, intptr_t)
     *)
    procedure setObject(pObj: CCObject; const key: string); overload;

    (** Insert an object to dictionary, and match it with the specified string key.
     *
     *  @note Then the first time this method is invoked, the key type will be set to string.
     *        After that you can't setObject with an integer key.
     *        If the dictionary contains the key you passed, the object matching the key will be released and removed from dictionary.
     *        Then the new object will be inserted after that.
     *  @param pObject  The Object to be inserted.
     *  @param key      The string key for searching.
     *  @see setObject(CCObject*, const std::string&)
     *)
    procedure setObject(pObj: CCObject; key: Integer); overload;

    {**
     *  Remove an object by the specified string key.
     *
     *  @param key  The string key for searching.
     *  @see removeObjectForKey(intptr_t), removeObjectsForKeys(CCArray*),
     *       removeObjectForElememt(CCDictElement*), removeAllObjects().
     *}
    procedure removeObjectForKey(const key: string); overload;

    {**
     *  Remove an object by the specified integer key.
     *
     *  @param key  The integer key for searching.
     *  @see removeObjectForKey(const std::string&), removeObjectsForKeys(CCArray*),
     *       removeObjectForElememt(CCDictElement*), removeAllObjects().
     *}
    procedure removeObjectForKey(key: Integer); overload;

    {**
     *  Remove objects by an array of keys.
     *
     *  @param pKeyArray  The array contains keys to be removed.
     *  @see removeObjectForKey(const std::string&), removeObjectForKey(intptr_t),
     *       removeObjectForElememt(CCDictElement*), removeAllObjects().
     *}
    procedure removeObjectsForKeys(pKeyArray: CCArray); overload;
    procedure removeObjectForElement(pElement: CCDictElement); overload;

    {**
     *  Remove all objects in the dictionary.
     *
     *  @see removeObjectForKey(const std::string&), removeObjectForKey(intptr_t),
     *       removeObjectsForKeys(CCArray*), removeObjectForElememt(CCDictElement*).
     *}
    procedure removeAllObjects();
    function copyWithZone(pZone: CCZone): CCObject; override;

    (**
     *  Return a random object in the dictionary.
     *
     *  @return The random object.
     *  @see objectForKey(intptr_t), objectForKey(const std::string&)
     *  @lua NA
     *)
    function randomObject(): CCObject;

    {**
     *  Write a dictionary to a plist file.
     *  @param fullPath The full path of the plist file. You can get writeable path by getWritablePath()
     *  @return true if successed, false if failed
     *  @lua NA
     *}
    function writeToFile(const fullPath: string): Boolean;
    function First(): CCDictElement;
    function Next(): CCDictElement;
    class function _create(): CCDictionary;

    {**
     *  Create a dictionary with an existing dictionary.
     *
     *  @param srcDict The exist dictionary.
     *  @return A dictionary which is an autorelease object.
     *  @see create(), createWithContentsOfFile(const char*), createWithContentsOfFileThreadSafe(const char*).
     *}
    class function createWithDictionary(srcDict: CCDictionary): CCDictionary;

    {**
     *  Create a dictionary with a plist file.
     *  @param  pFileName  The name of the plist file.
     *  @return A dictionary which is an autorelease object.
     *  @see create(), createWithDictionary(CCDictionary*), createWithContentsOfFileThreadSafe(const char*).
     *}
    class function createWithContentsOfFile(const pFilename: string): CCDictionary;
    class function createWithContentsOfFileThreadSafe(const pFilename: string): CCDictionary;
  end;

implementation
uses
  Cocos2dx.CCInteger, Cocos2dx.CCPlatformMacros, Cocos2dx.CCFileUtilsCommon, Cocos2dx.CCFileUtils;


procedure removeElement(HashElement: THashElement);
begin
  CCObject(HashElement.pObj).release();
  HashElement.Free;
end;  


{ CCDictionary }

class function CCDictionary._create: CCDictionary;
var
  pRet: CCDictionary;
begin
  pRet := CCDictionary.Create;
  if pRet <> nil then
  begin
    pRet.autorelease();
  end;
  Result := pRet;
end;

function CCDictionary.allKeys: CCArray;
var
  iKeyCount: Integer;
  pArray: CCArray;
  pElement: CCDictElement;
  pStrKey: CCString;
  PIntKey: CCInteger;
begin
  iKeyCount := Self.count();
  if iKeyCount < 1 then
  begin
    Result := nil;
    Exit;
  end;

  pArray := CCArray.createWithCapacity(iKeyCount);
  if m_eDictType = kCCDictStr then
  begin
    pElement := m_pHashChain.First();
    while pElement <> nil do
    begin
      pStrKey := CCString.Create(pElement.strKey);
      pArray.addObject(pStrKey);
      CC_SAFE_RELEASE(pStrKey);
      pElement := m_pHashChain.Next();
    end;
  end else if m_eDictType = kCCDictInt then
  begin
    pElement := m_pHashChain.First();
    while pElement <> nil do
    begin
      PIntKey := CCInteger.Create(pElement.nKey);
      pArray.addObject(PIntKey);
      CC_SAFE_RELEASE(PIntKey);
      pElement := m_pHashChain.Next();
    end;
  end;  

  Result := pArray;
end;

function CCDictionary.allKeysForObject(pObj: CCObject): CCArray;
var
  iKeyCount: Integer;
  pArray: CCArray;
  pElement: CCDictElement;
  pStrKey: CCString;
  PIntKey: CCInteger;
begin
  iKeyCount := Self.count();
  if iKeyCount < 1 then
  begin
    Result := nil;
    Exit;
  end;

  pArray := CCArray._Create();
  if m_eDictType = kCCDictStr then
  begin
    pElement := m_pHashChain.First();
    while pElement <> nil do
    begin
      if pElement.pObj = pObj then
      begin
        pStrKey := CCString.Create(pElement.strKey);
        pArray.addObject(pStrKey);
        CC_SAFE_RELEASE(pStrKey);
      end;

      pElement := m_pHashChain.Next();
    end;
  end else if m_eDictType = kCCDictInt then
  begin
    pElement := m_pHashChain.First();
    while pElement <> nil do
    begin
      if pElement.pObj = pObj then
      begin
        PIntKey := CCInteger.Create(pElement.nKey);
        pArray.addObject(PIntKey);
        CC_SAFE_RELEASE(PIntKey);
      end;

      pElement := m_pHashChain.Next();
    end;
  end;    

  Result := pArray;
end;

function CCDictionary.copyWithZone(pZone: CCZone): CCObject;
var
  pNewDict: CCDictionary;
  pTmpObj: CCObject;
  pElement: THashElement;
begin
  CCAssert(pZone = nil, 'CCDictionary should not be inherited.');

  pNewDict := CCDictionary.Create();

  if m_eDictType = kCCDictInt then
  begin
    pElement := m_pHashChain.First();
    while pElement <> nil do
    begin
      pTmpObj := CCObject(pElement.pObj).copy();
      pNewDict.setObject(pTmpObj, pElement.nKey);
      pTmpObj.release();

      pElement := m_pHashChain.Next();
    end;
  end else if m_eDictType = kCCDictStr then
  begin
    pElement := m_pHashChain.First();
    while pElement <> nil do
    begin
      pTmpObj := CCObject(pElement.pObj).copy();
      pNewDict.setObject(pTmpObj, pElement.strKey);
      pTmpObj.release();

      pElement := m_pHashChain.Next();
    end;
  end;

  Result := pNewDict;
end;

function CCDictionary.count: Integer;
begin
  Result := m_pHashChain.Count();
end;

constructor CCDictionary.Create;
begin
  inherited Create();
  m_eDictType := kCCDictUnknown;
  m_eOldDictType := kCCDictUnknown;
  m_pHashChain := TtdHashTableChain.Create(1000, removeElement);
end;

class function CCDictionary.createWithContentsOfFile(
  const pFilename: string): CCDictionary;
var
  pRet: CCDictionary;
begin
  pRet := createWithContentsOfFileThreadSafe(pFilename);
  pRet.autorelease();
  Result := pRet;
end;

class function CCDictionary.createWithContentsOfFileThreadSafe(
  const pFilename: string): CCDictionary;
begin
  Result := ccFileUtils_dictionaryWithContentsOfFileThreadSafe(pFilename);

  {.$MESSAGE 'here'}
end;

class function CCDictionary.createWithDictionary(
  srcDict: CCDictionary): CCDictionary;
var
  pNewDict: CCDictionary;
begin
  pNewDict := CCDictionary(srcDict.copy());
  pNewDict.autorelease();
  Result := pNewDict;
end;

destructor CCDictionary.Destroy;
begin
  m_pHashChain.Free;
  inherited;
end;

function CCDictionary.objectForKey(key: Integer): CCObject;
var
  pRetObject: CCObject;
  HashElement: THashElement;
begin
  if (m_eDictType = kCCDictUnknown) then
  begin
    Result := nil;
    Exit;
  end;

  CCAssert(m_eDictType = kCCDictInt, 'this dictionary does not use int as key.');

  pRetObject := nil;
  HashElement := m_pHashChain.FindElementByInteger(key);
  if HashElement <> nil then
  begin                          
    pRetObject := CCObject(HashElement.pObj);
  end;
  Result := pRetObject;
end;

function CCDictionary.objectForKey(const key: string): CCObject;
var
  pRetObject: CCObject;
  HashElement: THashElement;
begin
  if (m_eDictType = kCCDictUnknown) then
  begin
    Result := nil;
    Exit;
  end;

  CCAssert(m_eDictType = kCCDictStr, 'this dictionary does not use string as key.');

  pRetObject := nil;
  HashElement := m_pHashChain.FindElementByString(key);
  if HashElement <> nil then
  begin
    pRetObject := CCObject(HashElement.pObj);
  end;
  Result := pRetObject;
end;

procedure CCDictionary.removeAllObjects;
begin
  m_pHashChain.RemoveAllElements();
end;

procedure CCDictionary.removeObjectForKey(const key: string);
var
  pElement: THashElement;
begin
  if m_eDictType = kCCDictUnknown then
    Exit;

  CCAssert(m_eDictType = kCCDictStr, 'this dictionary does not use string as its key');
  CCAssert(Length(key) > 0, 'Invalid Argument!');

  pElement := m_pHashChain.FindElementByString(key);
  removeObjectForElement(pElement);
end;

procedure CCDictionary.removeObjectForKey(key: Integer);
var
  pElement: THashElement;
begin
  if m_eDictType = kCCDictUnknown then
    Exit;

  CCAssert(m_eDictType = kCCDictInt, 'this dictionary does not use string as its key');

  pElement := m_pHashChain.FindElementByInteger(key);
  removeObjectForElement(pElement);
end;

procedure CCDictionary.removeObjectSForKeys(pKeyArray: CCArray);
var
  i: Integer;
  pStr: CCString;
begin
  for i := 0 to pKeyArray.count()-1 do
  begin
    pStr := CCString(pKeyArray.objectAtIndex(i));
    removeObjectForKey(pStr.m_sString);
  end;
end;

procedure CCDictionary.setObject(pObj: CCObject; const key: string);
var
  pElement: THashElement;
  pTmpObj: CCObject;
begin
  CCAssert((Length(key) > 0) and (pObj <> nil), 'Invalid Argument!');
  if m_eOldDictType = kCCDictUnknown then
  begin
      m_eOldDictType := kCCDictStr;
  end;
  m_eDictType := kCCDictStr;
  CCAssert(m_eDictType = kCCDictStr, 'this dictionary does not use string as key.');

  pElement := m_pHashChain.FindElementByString(key);
  if pElement = nil then
  begin
    setObjectUnSafe(pObj, key);
  end else if pElement.pObj <> pObj then
  begin
    pTmpObj := CCObject(pElement.pObj);
    pTmpObj.retain();
    m_pHashChain.DelElement(pElement);
    setObjectUnSafe(pObj, key);
    pTmpObj.release();
  end;
end;

procedure CCDictionary.setObject(pObj: CCObject; key: Integer);
var
  pElement: THashElement;
  pTmpObj: CCObject;
begin
  CCAssert((pObj <> nil), 'Invalid Argument!');
  if m_eOldDictType = kCCDictUnknown then
  begin
      m_eOldDictType := kCCDictInt;
  end;
  m_eDictType := kCCDictInt;
  CCAssert(m_eDictType = kCCDictInt, 'this dictionary does not use int as key.');

  pElement := m_pHashChain.FindElementByInteger(key);
  if pElement = nil then
  begin
    setObjectUnSafe(pObj, key);
  end else if pElement.pObj <> pObj then
  begin
    pTmpObj := CCObject(pElement.pObj);
    pTmpObj.retain();
    m_pHashChain.DelElement(pElement);
    setObjectUnSafe(pObj, key);
    pTmpObj.release();
  end;
end;

procedure CCDictionary.setObjectUnSafe(pObj: CCObject; const key: string);
var
  pElement: THashElement;
begin
  pObj.retain();
  pElement := THashElement.Create(key, pObj);
  m_pHashChain.AddElement(pElement);
end;

procedure CCDictionary.setObjectUnSafe(pObj: CCObject; key: Integer);
var
  pElement: THashElement;
begin
  pObj.retain();
  pElement := THashElement.Create(key, pObj);
  m_pHashChain.AddElement(pElement);
end;

function CCDictionary.valueForKey(key: Integer): CCString;
var
  pObj: CCObject;
begin
  pObj := objectForKey(key);
  if pObj is CCString then
  begin
    Result := CCString(pObj);
    Exit;
  end;

  Result := CCString._create('');
end;

function CCDictionary.valueForKey(const key: string): CCString;
var
  pObj: CCObject;
begin
  pObj := objectForKey(key);
  if pObj is CCString then
  begin
    Result := CCString(pObj);
    Exit;
  end;

  Result := CCString._create('');
end;

procedure CCDictionary.removeObjectForElement(pElement: CCDictElement);
begin
  if pElement <> nil then
  begin
    m_pHashChain.DelElement(pElement);
    CCObject(pElement.pObj).release();
    pElement.Free;
  end;  
end;

function CCDictionary.First: CCDictElement;
begin
  Result := m_pHashChain.First();
end;

function CCDictionary.Next: CCDictElement;
begin
  Result := m_pHashChain.Next();
end;

function CCDictionary.randomObject: CCObject;
var
  key: CCObject;
begin
  if m_eDictType = kCCDictUnknown then
  begin
    Result := nil;
    Exit;
  end;

  key := allKeys.randomObject();
  if m_eDictType = kCCDictInt then
    Result := objectForKey(CCInteger(key).getValue())
  else if m_eDictType = kCCDictStr then
    Result := objectForKey(CCString(key).m_sString)
  else
    Result := nil;
end;

function CCDictionary.writeToFile(const fullPath: string): Boolean;
begin
  {.$MESSAGE 'here'}
  Result := False;
end;

end.
