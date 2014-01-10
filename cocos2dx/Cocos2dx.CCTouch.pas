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

unit Cocos2dx.CCTouch;

interface
uses
  Cocos2dx.CCObject, Cocos2dx.CCGeometry;

type
  CCTouch = class(CCObject)
  private
    m_nId: Integer;
    m_point: CCPoint;
    m_prevPoint, m_startPoint: CCPoint;
    m_startPointCaptured: Boolean;
  public
    constructor Create();
    //** returns the current touch location in OpenGL coordinates */
    function getLocation(): CCPoint;
    //** returns the previous touch location in OpenGL coordinates */
    function GetPreviousLocation(): CCPoint;
    //** returns the delta of 2 current touches locations in screen coordinates */
    function getDelta(): CCPoint;
    //** returns the current touch location in screen coordinates */
    function getLocationInView(): CCPoint;
    //** returns the previous touch location in screen coordinates */
    function getPreviousLocationInView(): CCPoint;
    procedure setTouchInfo(id: Integer; x, y: Double);
    function getID(): Integer;
    //** returns the start touch location in OpenGL coordinates */
    function getStartLocation(): CCPoint;
    //** returns the start touch location in screen coordinates */
    function getStartLocationInView(): CCPoint;
  end;

implementation
uses
  Cocos2dx.CCDirector, Cocos2dx.CCPointExtension;

{ CCTouch }

constructor CCTouch.Create;
begin
  inherited Create();
end;

function CCTouch.getDelta: CCPoint;
begin
  Result := ccpSub(getLocation(), GetPreviousLocation());
end;

function CCTouch.getID: Integer;
begin
  Result := m_nId;
end;

function CCTouch.getLocation: CCPoint;
begin
  Result := CCDirector.sharedDirector().convertToGL(m_point);
end;

function CCTouch.getLocationInView: CCPoint;
begin
  Result := m_point;
end;

function CCTouch.GetPreviousLocation: CCPoint;
begin
  Result := CCDirector.sharedDirector().convertToGL(m_prevPoint);
end;

function CCTouch.getPreviousLocationInView: CCPoint;
begin
  Result := m_prevPoint;
end;

function CCTouch.getStartLocation: CCPoint;
begin
  Result := CCDirector.sharedDirector().convertToGL(m_startPoint);
end;

function CCTouch.getStartLocationInView: CCPoint;
begin
  Result := m_startPoint;
end;

procedure CCTouch.setTouchInfo(id: Integer; x, y: Double);
begin
  m_nId := id;
  m_prevPoint := m_point;
  m_point.x := x;
  m_point.y := y;
  if not m_startPointCaptured then
  begin
    m_startPoint := m_point;
    m_startPointCaptured := True;
  end;  
end;

end.
