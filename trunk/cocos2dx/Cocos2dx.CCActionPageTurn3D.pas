(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Sindesso Pty Ltd http://www.sindesso.com/

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

unit Cocos2dx.CCActionPageTurn3D;

interface
uses
  Cocos2dx.CCActionGrid, Cocos2dx.CCTypes, Cocos2dx.CCGeometry;

(**
 * @addtogroup actions
 * @{
 *)

(**
 @brief This action simulates a page turn from the bottom right hand corner of the screen.
 It's not much use by itself but is used by the PageTurnTransition.
 
 Based on an original paper by L Hong et al.
 http://www.parc.com/publication/1638/turning-pages-of-3d-electronic-books.html
  
 @since v0.8.2
 *)

type
  CCPageTurn3D = class(CCGrid3DAction)
  public
    procedure update(time: Single); override;
    class function _create(duration: Single; const gridSize: CCSize): CCPageTurn3D;
  end;

implementation
uses
  Math, Cocos2dx.CCPlatformMacros, Cocos2dx.CCPointExtension;

{ CCPageTurn3D }

class function CCPageTurn3D._create(duration: Single;
  const gridSize: CCSize): CCPageTurn3D;
var
  pRet: CCPageTurn3D;
begin
  pRet := CCPageTurn3D.Create();
  if (pRet <> nil) and pRet.initWithDuration(duration, gridSize) then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCPageTurn3D.update(time: Single);
var
  tt, deltaAy, ay, deltaTheta, theta, sinTheta, cosThea: Single;
  i, j: Integer;
  p: ccVertex3F;
  bigR, smallR, alpha, beta, cosBeta: Single;
begin
  tt := Max(0, time - 0.25);
  deltaAy := tt * tt * 500;
  ay := -100 - deltaAy;

  deltaTheta := -Pi * 0.5 * Sqrt(time);
  theta := Pi * 0.5 + deltaTheta;

  sinTheta := Sin(theta);
  cosThea := Cos(theta);

  for i := 0 to Floor(m_sGridSize.width) do
  begin
    for j := 0 to Floor(m_sGridSize.height) do
    begin
      p := originalVertex(ccp(i, j));

      bigR := Sqrt( p.x * p.x + (p.y - ay) * (p.y - ay) );
      smallR := bigR * sinTheta;
      alpha := ArcSin(p.x / bigR);
      beta := alpha / sinTheta;
      cosBeta := Cos(beta);

      // If beta > PI then we've wrapped around the cone
      // Reduce the radius to stop these points interfering with others
      if beta <= Pi then
      begin
        p.x := smallR * Sin(beta);
      end else
      begin
        // Force X = 0 to stop wrapped
        // points
        p.x := 0;
      end;

      p.y := bigR + ay - smallR * (1 - cosBeta) * sinTheta;

      // We scale z here to avoid the animation being
      // too much bigger than the screen due to perspective transform
      p.z := smallR * (1 - cosBeta) * cosThea / 7; // "100" didn't work for

      //    Stop z coord from dropping beneath underlying page in a transition
      // issue #751
      if p.z < 0.5 then
      begin
        p.z := 0.5;
      end;

      setVertex(ccp(i, j), p);
    end;  
  end;  
end;

end.
