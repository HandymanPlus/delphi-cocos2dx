(****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      On-Core

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

unit Cocos2dx.CCGrabber;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCTexture2D;

type
  CCGrabber = class(CCObject)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure grab(pTexture: CCTexture2D);
    procedure beforeRender(pTexture: CCTexture2D);
    procedure afterRender(pTexture: CCTexture2D);
  protected
    m_FBO: GLuint;
    m_oldFBO: GLint;
    m_oldClearColor: array [0..3] of GLfloat;
  end;

implementation
uses
  Cocos2dx.CCPlatformMacros, Cocos2dx.CCCommon;

{ CCGrabber }

procedure CCGrabber.afterRender(pTexture: CCTexture2D);
begin
  glBindFramebuffer(GL_FRAMEBUFFER, m_oldFBO);
  glClearColor(m_oldClearColor[0], m_oldClearColor[1], m_oldClearColor[2], m_oldClearColor[3]);
end;

procedure CCGrabber.beforeRender(pTexture: CCTexture2D);
begin
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, @m_oldFBO);
  glBindFramebuffer(GL_FRAMEBUFFER, m_FBO);
  glGetFloatv(GL_COLOR_CLEAR_VALUE, @m_oldClearColor[0]);
  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;

constructor CCGrabber.Create;
begin
  inherited Create();
  glGenFramebuffers(1, @m_FBO);
end;

destructor CCGrabber.Destroy;
begin
  glDeleteFramebuffers(1, @m_fbo);
  inherited;
end;

procedure CCGrabber.grab(pTexture: CCTexture2D);
var
  status: GLuint;
begin
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, @m_oldFBO);
  glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, pTexture.Name, 0);
  status := glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if status <> GL_FRAMEBUFFER_COMPLETE then
  begin
    CCAssert(False, 'Frame Grabber: could not attach texture to framebuffer');
  end;
  glBindFramebuffer(GL_FRAMEBUFFER, m_oldFBO);
end;

end.
