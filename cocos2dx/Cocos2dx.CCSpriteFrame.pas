(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2011 Ricardo Quesada
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

unit Cocos2dx.CCSpriteFrame;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCTexture2D, Cocos2dx.CCGeometry, Cocos2dx.CCProtocols;

type
  (** @brief A CCSpriteFrame has:
      - texture: A CCTexture2D that will be used by the CCSprite
      - rectangle: A rectangle of the texture


   You can modify the frame of a CCSprite by doing:

      CCSpriteFrame *frame = CCSpriteFrame::frameWithTexture(texture, rect, offset);
      sprite->setDisplayFrame(frame);
   *)
  CCSpriteFrame = class(CCObject)
  private
    m_bRotated: Boolean;
    m_obOriginalSizeInPixels: CCSize;
    m_obRect: CCRect;
    m_obRectInPixels: CCRect;
    m_obOffset: CCPoint;
    m_obOriginalSize: CCSize;
    m_obOffsetInPixels: CCPoint;
    m_pobTexture: CCTexture2D;
    m_strTextureFilename: string;
  public
    constructor Create();
    destructor Destroy(); override;
    function copyWithZone(pZone: CCZone): CCObject; override;
    class function createWithTexture(pobTexture: CCTexture2D; const rect: CCRect): CCSpriteFrame; overload;
    class function createWithTexture(pobTexture: CCTexture2D; const rect: CCRect; rotated: Boolean; const offset: CCPoint; const originalSize: CCSize): CCSpriteFrame; overload;
    class function _create(const filename: string; const rect: CCRect): CCSpriteFrame; overload;
    class function _create(const filename: string; const rect: CCRect; rotated: Boolean; const offset: CCPoint; const originalSize: CCSize): CCSpriteFrame; overload;

    function initWithTexture(pobTexture: CCTexture2D; const rect: CCRect): Boolean; overload;
    function initWithTextureFilename(const filename: string; const rect: CCRect): Boolean; overload;
    function initWithTexture(pobTexture: CCTexture2D; const rect: CCRect; rotated: Boolean; const offset: CCPoint; const originalSize: CCSize): Boolean; overload;
    function initWithTextureFilename(const filename: string; const rect: CCRect; rotated: Boolean; const offset: CCPoint; const originalSize: CCSize): Boolean; overload;

    function getRectInPixels(): CCRect;
    procedure setRectInPixels(const rectInPixels: CCRect);

    function isRotated(): Boolean;
    procedure serRotated(bRotated: Boolean);

    function getRect(): CCRect;
    procedure setRect(const rect: CCRect);

    function getOffsetInPixels(): CCPoint;
    procedure setOffsetInPixels(const offsetInPixels: CCPoint);

    function getOriginalSizeInPixels(): CCSize;
    procedure setOriginalSizeInPixels(const sizeInPixels: CCSize);

    function getOriginalSize(): CCSize;
    procedure setOriginalSize(const sizeInPixels: CCSize);

    function getTexture(): CCTexture2D;
    procedure setTexture(pobTexture: CCTexture2D);

    function getOffset(): CCPoint;
    procedure setOffset(const offsets: CCPoint);
  end;

implementation
uses
  Cocos2dx.CCMacros, Cocos2dx.CCPlatformMacros, Cocos2dx.CCTextureCache;

{ CCSpriteFrame }

function CCSpriteFrame.copyWithZone(pZone: CCZone): CCObject;
var
  pCopy: CCSpriteFrame;
begin
  pCopy := CCSpriteFrame.Create();
  pCopy.initWithTextureFilename(m_strTextureFilename, m_obRectInPixels, m_bRotated, m_obOffsetInPixels, m_obOriginalSizeInPixels);
  pCopy.setTexture(m_pobTexture);

  Result := pCopy;
end;

constructor CCSpriteFrame.Create;
begin
  inherited Create();
end;

class function CCSpriteFrame.createWithTexture(pobTexture: CCTexture2D;
  const rect: CCRect): CCSpriteFrame;
var
  pSpriteFrame: CCSpriteFrame;
begin
  pSpriteFrame := CCSpriteFrame.Create();
  pSpriteFrame.initWithTexture(pobTexture, rect);
  pSpriteFrame.autorelease();
  Result := pSpriteFrame;
end;

class function CCSpriteFrame.createWithTexture(pobTexture: CCTexture2D;
  const rect: CCRect; rotated: Boolean; const offset: CCPoint;
  const originalSize: CCSize): CCSpriteFrame;
var
  pSpriteFrame: CCSpriteFrame;
begin
  pSpriteFrame := CCSpriteFrame.Create();
  pSpriteFrame.initWithTexture(pobTexture, rect, rotated, offset, originalSize);
  pSpriteFrame.autorelease();

  Result := pSpriteFrame;
end;

destructor CCSpriteFrame.Destroy;
begin
  CC_SAFE_RELEASE(m_pobTexture);
  inherited;
end;

function CCSpriteFrame.getOffset: CCPoint;
begin
  Result := m_obOffset;
end;

function CCSpriteFrame.getOffsetInPixels: CCPoint;
begin
  Result := m_obOffsetInPixels;
end;

function CCSpriteFrame.getOriginalSize: CCSize;
begin
  Result := m_obOriginalSize;
end;

function CCSpriteFrame.getOriginalSizeInPixels: CCSize;
begin
  Result := m_obOriginalSizeInPixels;
end;

function CCSpriteFrame.getRect: CCRect;
begin
  Result := m_obRect;
end;

function CCSpriteFrame.getRectInPixels: CCRect;
begin
  Result := m_obRectInPixels;
end;

function CCSpriteFrame.getTexture: CCTexture2D;
begin
  if m_pobTexture <> nil then
  begin
    Result := m_pobTexture;
    Exit;
  end;

  if Length(m_strTextureFilename) > 0 then
  begin
    Result := CCTextureCache.sharedTextureCache().addImage(m_strTextureFilename);
    Exit;
  end;

  Result := nil;
end;

function CCSpriteFrame.initWithTexture(pobTexture: CCTexture2D;
  const rect: CCRect; rotated: Boolean; const offset: CCPoint;
  const originalSize: CCSize): Boolean;
begin
  m_pobTexture := pobTexture;

  if pobTexture <> nil then
  begin
    pobTexture.retain();
  end;

  m_obRectInPixels := rect;
  m_obRect := CC_RECT_POINTS_TO_PIXELS(rect);
  m_obOffsetInPixels := offset;
  m_obOffset := CC_POINT_PIXELS_TO_POINTS(m_obOffsetInPixels);
  m_obOriginalSizeInPixels := originalSize;
  m_obOriginalSize := CC_SIZE_PIXELS_TO_POINTS(m_obOriginalSizeInPixels);
  m_bRotated := rotated;

  Result := True; 
end;

function CCSpriteFrame.initWithTexture(pobTexture: CCTexture2D;
  const rect: CCRect): Boolean;
var
  rectInPixels: CCRect;
begin
  rectInPixels := CC_RECT_POINTS_TO_PIXELS(rect);
  Result := initWithTexture(pobTexture, rectInPixels, False, CCPointZero, rectInPixels.size);
end;

function CCSpriteFrame.initWithTextureFilename(const filename: string;
  const rect: CCRect): Boolean;
var
  rectInPixels: CCRect;
begin
  rectInPixels := CC_RECT_POINTS_TO_PIXELS(rect);
  Result := initWithTextureFilename(filename, rectInPixels, False, CCPointZero, rectInPixels.size)
end;

function CCSpriteFrame.initWithTextureFilename(const filename: string;
  const rect: CCRect; rotated: Boolean; const offset: CCPoint;
  const originalSize: CCSize): Boolean;
begin
  m_pobTexture := nil;
  m_strTextureFilename := filename;
  m_obRectInPixels := rect;
  m_obRect := CC_RECT_PIXELS_TO_POINTS(rect);
  m_obOffsetInPixels := offset;
  m_obOffset := CC_POINT_PIXELS_TO_POINTS(m_obOffsetInPixels);
  m_obOriginalSizeInPixels := originalSize;
  m_obOriginalSize := CC_SIZE_PIXELS_TO_POINTS(m_obOriginalSizeInPixels);
  m_bRotated := rotated;

  Result := True;
end;

function CCSpriteFrame.isRotated: Boolean;
begin
  Result := m_bRotated;
end;

procedure CCSpriteFrame.serRotated(bRotated: Boolean);
begin
  m_bRotated := bRotated;
end;

procedure CCSpriteFrame.setOffset(const offsets: CCPoint);
begin
  m_obOffset := offsets;
  m_obOffsetInPixels := CC_POINT_PIXELS_TO_POINTS(m_obOffset);
end;

procedure CCSpriteFrame.setOffsetInPixels(const offsetInPixels: CCPoint);
begin
  m_obOffsetInPixels := offsetInPixels;
  m_obOffset := CC_POINT_PIXELS_TO_POINTS(m_obOffsetInPixels);
end;

procedure CCSpriteFrame.setOriginalSize(const sizeInPixels: CCSize);
begin
  m_obOriginalSize := sizeInPixels;
end;

procedure CCSpriteFrame.setOriginalSizeInPixels(
  const sizeInPixels: CCSize);
begin
  m_obOriginalSizeInPixels := sizeInPixels;
end;

procedure CCSpriteFrame.setRect(const rect: CCRect);
begin
  m_obRect := rect;
  m_obRectInPixels := CC_RECT_POINTS_TO_PIXELS(m_obRect);
end;

procedure CCSpriteFrame.setRectInPixels(const rectInPixels: CCRect);
begin
  m_obRectInPixels := rectInPixels;
  m_obRect := CC_RECT_PIXELS_TO_POINTS(rectInPixels);
end;

class function CCSpriteFrame._create(const filename: string;
  const rect: CCRect; rotated: Boolean; const offset: CCPoint;
  const originalSize: CCSize): CCSpriteFrame;
var
  pSpriteFrame: CCSpriteFrame;
begin
  pSpriteFrame := CCSpriteFrame.Create();
  pSpriteFrame.initWithTextureFilename(filename, rect, rotated, offset, originalSize);
  pSpriteFrame.autorelease();

  Result := pSpriteFrame;
end;

class function CCSpriteFrame._create(const filename: string;
  const rect: CCRect): CCSpriteFrame;
var
  pSpriteFrame: CCSpriteFrame;
begin
  pSpriteFrame := CCSpriteFrame.Create();
  pSpriteFrame.initWithTextureFilename(filename, rect);
  pSpriteFrame.autorelease();

  Result := pSpriteFrame;
end;

procedure CCSpriteFrame.setTexture(pobTexture: CCTexture2D);
begin
  if m_pobTexture <> pobTexture then
  begin
    CC_SAFE_RETAIN(pobTexture);
    CC_SAFE_RELEASE(m_pobTexture);
    m_pobTexture := pobTexture;
  end;  
end;

end.
