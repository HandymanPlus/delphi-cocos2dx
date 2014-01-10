unit Cocos2dx.CCPlatformMacros;

interface
uses
  Cocos2dx.CCObject;

procedure CCAssert(cond: Boolean; msg: string);

procedure CC_SAFE_DELETE(p: CCObject);
procedure CC_SAFE_DELETE_ARRAY(p: CCObject);
procedure CC_SAFE_FREE(p: CCObject);
procedure CC_SAFE_RELEASE(p: CCObject);
procedure CC_SAFE_RELEASE_NULL(var p: CCObject);
procedure CC_SAFE_RETAIN(p: CCObject);

procedure CC_SAFE_FREE_POINTER(p: Pointer);
procedure CC_SAFE_FREE_POINTER_NULL(var p: Pointer);


implementation

procedure CCAssert(cond: Boolean; msg: string);
begin
  Assert(cond, msg);
end;

procedure CC_SAFE_DELETE(p: CCObject);
begin
  if p <> nil then
    p.Free;
  //p := nil;
end;

procedure CC_SAFE_DELETE_ARRAY(p: CCObject);
begin
  if p <> nil then
    p.Free;
  //p := nil;
end;

procedure CC_SAFE_FREE(p: CCObject);
begin
  if p <> nil then
    p.Free;
  //p := nil;
end;

procedure CC_SAFE_RELEASE(p: CCObject);
begin
  if p <> nil then
    p.release();
end;

procedure CC_SAFE_RELEASE_NULL(var p: CCObject);
var
  isSingleReference: Boolean;
begin
  if p <> nil then
  begin
    isSingleReference := p.isSingleReference;

    p.release();

    if isSingleReference then
      p := nil;
  end;
end;

procedure CC_SAFE_RETAIN(p: CCObject);
begin
  if p <> nil then
    p.retain();
end;

procedure CC_SAFE_FREE_POINTER(p: Pointer);
begin
  if p <> nil then
    FreeMem(p);
end;

procedure CC_SAFE_FREE_POINTER_NULL(var p: Pointer);
begin
  if p <> nil then
  begin
    FreeMem(p);
    p := nil;
  end;
end;  

end.
