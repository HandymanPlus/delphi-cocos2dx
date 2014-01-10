unit Cocos2dx.CCGLBufferedNode;

interface

{$I cConfig.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES; {$else} dglOpenGL; {$endif}

const BUFFER_SLOTS = 4;

type
  CCGLBufferedNode = class
  public
    m_bufferObject, m_bufferSize, m_indexBufferObject, m_indexBufferSize: array [0..BUFFER_SLOTS-1] of GLuint;
  public
    constructor Create();
    procedure setGLBufferData(buf: Pointer; bufSize: GLuint; slot: Integer);
    procedure setGLIndexData(buf: Pointer; bufSize: GLuint; slot: Integer);
  end;

implementation

{ CCGLBufferedNode }

constructor CCGLBufferedNode.Create;
begin

end;

procedure CCGLBufferedNode.setGLBufferData(buf: Pointer; bufSize: GLuint;
  slot: Integer);
begin
  if m_bufferSize[slot] < bufSize then
  begin
    if m_bufferObject[slot] > 0 then
      glDeleteBuffers(1, @m_bufferObject[slot]);
    glGenBuffers(1, @m_bufferObject[slot]);
    m_bufferSize[slot] := bufSize;

    glBindBuffer(GL_ARRAY_BUFFER, m_bufferObject[slot]);
    glBufferData(GL_ARRAY_BUFFER, bufSize, buf, GL_DYNAMIC_DRAW);
  end else
  begin
    glBindBuffer(GL_ARRAY_BUFFER, m_bufferObject[slot]);
    glBufferSubData(GL_ARRAY_BUFFER, 0, bufSize, buf);
  end;
end;

procedure CCGLBufferedNode.setGLIndexData(buf: Pointer; bufSize: GLuint;
  slot: Integer);
begin
  if m_indexBufferSize[slot] < bufSize then
  begin
    if m_indexBufferObject[slot] > 0 then
      glDeleteBuffers(1, @m_indexBufferObject[slot]);
    glGenBuffers(1, @m_indexBufferObject[slot]);
    m_indexBufferSize[slot] := bufSize;

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferObject[slot]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, bufSize, buf, GL_DYNAMIC_DRAW);
  end else
  begin
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferObject[slot]);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, bufSize, buf);
  end;
end;

end.
