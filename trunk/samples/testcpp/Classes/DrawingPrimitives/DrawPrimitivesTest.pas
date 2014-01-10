unit DrawPrimitivesTest;

interface
uses
  dglOpenGL, 
  Cocos2dx.CCObject, Cocos2dx.CCLayer, Cocos2dx.CCScene, testBasic, Cocos2dx.CCGeometry,
  Cocos2dx.CCNode, Cocos2dx.CCTypes;

type
  DrawPrimitivesTestScene = class(TestScene)
  public
    procedure runThisTest(); override;
  end;

  DrawPrimitivesDemo = class(CCLayer)
  public
    constructor Create();
    procedure draw(); override;
  end;

implementation
uses
  Cocos2dx.CCDirector, Cocos2dx.CCDrawingPrimitives,
  Cocos2dx.CCPointExtension, Cocos2dx.CCMacros;

{ DrawPrimitivesTestScene }

procedure DrawPrimitivesTestScene.runThisTest;
var
  pLayer: CCLayer;
begin
  pLayer := DrawPrimitivesDemo.Create;
  addChild(pLayer);
  pLayer.release;
  CCDirector.sharedDirector.replaceScene(Self);
end;

{ DrawPrimitivesDemo }

constructor DrawPrimitivesDemo.Create;
begin
  inherited;
end;

procedure DrawPrimitivesDemo.draw;
var
  s: CCSize;
  points, vertices3: array [0..3] of CCPoint;
  filledVertices, vertices: array [0..4] of CCPoint;
  vertices2: array [0..2] of CCPoint;
begin
  s := CCDirector.sharedDirector.getWinSize;

  ccDrawLine(ccp(0, 0), ccp(s.width, s.height));

  glLineWidth(5);
  ccDrawColor4B(255, 0, 0, 255);
  ccDrawLine(ccp(0, s.height), ccp(s.width, 0));

  ccPointSize(64);
  ccDrawColor4B(0, 0, 255, 128);
  ccDrawPoint(ccp(s.width/2, s.height/2));

  points[0] := ccp(60, 60);
  points[1] := ccp(70, 70);
  points[2] := ccp(60, 70);
  points[3] := ccp(70, 60);
  ccPointSize(4);
  ccDrawColor4B(0, 255, 255, 255);
  ccDrawPoints(@points[0], 4);

  glLineWidth(16);
  ccDrawColor4B(0, 255, 0, 255);
  ccDrawCircle(ccp(s.width/2, s.height/2), 100, 0, 10, False);

  glLineWidth(2);
  ccDrawColor4B(0, 255, 255, 255);
  ccDrawCircle(ccp(s.width/2, s.height/2), 50, CC_DEGREES_TO_RADIANS(90), 50, True);

  ccDrawColor4B(255, 255, 0, 255);
  glLineWidth(10);
  vertices[0] := ccp(0, 0);
  vertices[1] := ccp(50, 50);
  vertices[2] := ccp(100, 50);
  vertices[3] := ccp(100, 100);
  vertices[4] := ccp(50, 100);
  ccDrawPoly(@vertices[0], 5, False);

  glLineWidth(1);
  filledVertices[0] := ccp(0, 120);
  filledVertices[1] := ccp(50, 120);
  filledVertices[2] := ccp(50, 170);
  filledVertices[3] := ccp(25, 200);
  filledVertices[4] := ccp(0, 170);
  ccDrawSolidPoly(@filledVertices[0], 5, ccc4F(0.5, 0.5, 1, 1));

  ccDrawColor4B(255, 0, 255, 255);
  glLineWidth(2);
  vertices2[0] := ccp(30, 130);
  vertices2[1] := ccp(30, 230);
  vertices2[2] := ccp(50, 200);
  ccDrawPoly(@vertices2[0], 3, True);

  ccDrawQuadBezier(ccp(0, s.height), ccp(s.width/2, s.height/2), ccp(s.width, s.height), 50);

  ccDrawCubicBezier(ccp(s.width/2, s.height/2), ccp(s.width/2+30,s.height/2+50), ccp(s.width/2+60,s.height/2-50),ccp(s.width, s.height/2),100);


  vertices3[0] := ccp(60, 160);
  vertices3[1] := ccp(70, 190);
  vertices3[2] := ccp(100, 190);
  vertices3[3] := ccp(90, 160);
  ccDrawSolidPoly(@vertices3[0], 4, ccc4F(1, 1, 0, 1));

  glLineWidth(1);
  ccDrawColor4B(255, 255, 255, 255);
  ccPointSize(1);
end;

end.
