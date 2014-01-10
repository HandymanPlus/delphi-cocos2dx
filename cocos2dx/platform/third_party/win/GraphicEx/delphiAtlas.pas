unit delphiAtlas;

interface

const
  soFromBeginning = 0;
  soFromCurrent = 1;
  soFromEnd = 2;

type
  {Base class for all streams}
  TStream = class
  protected
    {Returning/setting size}
    function GetSize: Longint; virtual;
    procedure SetSize(const Value: Longint); virtual; abstract;
    {Returns/set position}
    function GetPosition: Longint; virtual;
    procedure SetPosition(const Value: Longint); virtual;
  public
    {Returns/sets current position}
    property Position: Longint read GetPosition write SetPosition;
    {Property returns/sets size}
    property Size: Longint read GetSize write SetSize;
    {Allows reading/writing data}
    function Read(var Buffer; Count: Longint): Cardinal; virtual; abstract;
    function Write(const Buffer; Count: Longint): Cardinal; virtual; abstract;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    {Copies from another Stream}
    function CopyFrom(Source: TStream;
      Count: Cardinal): Cardinal; virtual;
    {Seeks a stream position}
    function Seek(Offset: Longint; Origin: Word): Longint; virtual; abstract;
  end;

  TFileStream = class(TStream)
  private
  protected
    procedure SetSize(const Value: Longint); override;
  public
    constructor Create(Filename: string; Mode: Integer);
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Read(var Buffer; Count: Longint): Cardinal; override;
    function Write(const Buffer; Count: Longint): Cardinal; override;
    destructor Destroy; override;
  end;

  TMemoryStream = class(TStream)
  private
    fCurrent: Longint;
    fSize: Longint;
    m_pData: PByte;
  protected
    procedure SetSize(const Value: Longint); override;
  public
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Read(var Buffer; Count: Longint): Cardinal; override;
    function Write(const Buffer; Count: Longint): Cardinal; override;
    constructor Create(pData: PByte; nSize: Longint);
    destructor Destroy; override;
  end;

implementation
uses
  Classes;

{ TStream }

function TStream.CopyFrom(Source: TStream; Count: Cardinal): Cardinal;
const
  MaxBytes = $f000;
var
  Buffer:  PAnsiChar;
  BufSize, N: Cardinal;
begin
  {If count is zero, copy everything from Source}
  if Count = 0 then
  begin
    Source.Seek(0, soFromBeginning);
    Count := Source.Size;
  end;

  Result := Count; {Returns the number of bytes readed}
  {Allocates memory}
  if Count > MaxBytes then BufSize := MaxBytes else BufSize := Count;
  GetMem(Buffer, BufSize);

  {Copy memory}
  while Count > 0 do
  begin
    if Count > BufSize then N := BufSize else N := Count;
    Source.Read(Buffer^, N);
    Write(Buffer^, N);
    dec(Count, N);
  end;

  {Deallocates memory}
  FreeMem(Buffer, BufSize);
end;

function TStream.GetPosition: Longint;
begin
  Result := Seek(0, soFromCurrent);
end;

function TStream.GetSize: Longint;
var
  Pos: Cardinal;
begin
  Pos := Seek(0, soFromCurrent);
  Result := Seek(0, soFromEnd);
  Seek(Pos, soFromCurrent);
end;

procedure TStream.ReadBuffer(var Buffer; Count: Integer);
begin
  Read(Buffer, Count);
end;

procedure TStream.SetPosition(const Value: Integer);
begin
  Seek(Value, soFromBeginning);
end;

procedure TStream.WriteBuffer(const Buffer; Count: Integer);
begin
  Write(Buffer, Count);
end;

{ TFileStream }

constructor TFileStream.Create(Filename: string; Mode: Integer);
begin

end;

destructor TFileStream.Destroy;
begin

  inherited;
end;

function TFileStream.Read(var Buffer; Count: Integer): Cardinal;
begin
  Result := 0;
end;

function TFileStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  Result := 0;
end;

procedure TFileStream.SetSize(const Value: Integer);
begin
  inherited;

end;

function TFileStream.Write(const Buffer; Count: Integer): Cardinal;
begin
  Result := 0;
end;

{ TMemoryStream }

constructor TMemoryStream.Create(pData: PByte; nSize: Integer);
begin
  inherited Create();
  m_pData := pData;
  fSize := nSize;
  fCurrent := 0;
end;

destructor TMemoryStream.Destroy;
begin
  m_pData := nil;
  fSize := 0;
  fCurrent := 0;
  inherited;
end;

function TMemoryStream.Read(var Buffer; Count: Integer): Cardinal;
begin
  if fCurrent + Count <= fSize then
  begin
    Move(pByte(Cardinal(m_pData) + Cardinal(fCurrent))^, Buffer, Count);
    Inc(fCurrent, Count);
    Result := Count;
  end else
  begin
    Result := 0;
  end;
end;

function TMemoryStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  {Move depending on the origin}
  case Origin of
    soFromBeginning: fCurrent := Offset;
    soFromCurrent: inc(fCurrent, Offset);
    soFromEnd: Position := fSize + Offset;
  end;

  {Returns the current position}
  Result := fCurrent;
end;

procedure TMemoryStream.SetSize(const Value: Integer);
begin
  inherited;

end;

function TMemoryStream.Write(const Buffer; Count: Integer): Cardinal;
begin
  if fCurrent + Count <= fSize then
  begin
    Move(Buffer, pByte(Cardinal(m_pData) + Cardinal(fCurrent))^, Count);
    Inc(fCurrent, Count);
    Result := Count;
  end else
  begin
    Result := 0;
  end;
end;

end.
