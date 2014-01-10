unit matrix;

interface
uses
  utility, mat4, vec3, mat4stack;

const KM_GL_MODELVIEW  = $1700;
const KM_GL_PROJECTION = $1701;
const KM_GL_TEXTURE    = $1702;

procedure kmGLFreeAll();
procedure kmGLPushMatrix();
procedure kmGLPopMatrix();
procedure kmGLMatrixMode(mode: kmGLEnum);
procedure kmGLLoadIdentity();
procedure kmGLLoadMatrix(const pIn: pkmMat4);
procedure kmGLMultMatrix(const pIn: pkmMat4);
procedure kmGLTranslatef(x, y, z: Single);
procedure kmGLRotatef(angle, x, y, z: Single);
procedure kmGLScalef(x, y, z: Single);
procedure kmGLGetMatrix(mode :kmGLEnum; pOut: pkmMat4);

implementation

var modelview_matrix_stack: km_mat4_stack;
var projection_matrix_stack: km_mat4_stack;
var texture_matrix_stack: km_mat4_stack;

var current_stack: pkm_mat4_stack;
var initialized: Byte = 0;

procedure lazyInitialize();
var
  identity: kmMat4;
begin
  if initialized = 0 then
  begin
    km_mat4_stack_initialize(@modelview_matrix_stack);
    km_mat4_stack_initialize(@projection_matrix_stack);
    km_mat4_stack_initialize(@texture_matrix_stack);

    current_stack := @modelview_matrix_stack;

    initialized := 1;

    kmMat4Identity(@identity);

    //Make sure that each stack has the identity matrix
    km_mat4_stack_push(@modelview_matrix_stack, @identity);
    km_mat4_stack_push(@projection_matrix_stack, @identity);
    km_mat4_stack_push(@texture_matrix_stack, @identity);
  end;
end;

procedure kmGLFreeAll();
begin
    //Clear the matrix stacks
    km_mat4_stack_release(@modelview_matrix_stack);
    km_mat4_stack_release(@projection_matrix_stack);
    km_mat4_stack_release(@texture_matrix_stack);

    //Delete the matrices
    initialized := 0; //Set to uninitialized

    current_stack := nil; //Set the current stack to point nowhere
end;

procedure kmGLPushMatrix();
var
  top: kmMat4;
begin
  lazyInitialize();
  kmMat4Assign(@top, current_stack^.top);
  km_mat4_stack_push(current_stack, @top);
end;

procedure kmGLPopMatrix();
begin
  km_mat4_stack_pop(current_stack, nil);
end;

procedure kmGLMatrixMode(mode: kmGLEnum);
begin
  lazyInitialize();

  case mode of
    KM_GL_MODELVIEW: current_stack := @modelview_matrix_stack;
    KM_GL_PROJECTION: current_stack := @projection_matrix_stack;
    KM_GL_TEXTURE: current_stack := @texture_matrix_stack;
  end;
end;

procedure kmGLLoadIdentity();
begin
  lazyInitialize();
  kmMat4Identity(current_stack^.top);
end;

procedure kmGLLoadMatrix(const pIn: pkmMat4);
begin
  lazyInitialize();
  kmMat4Assign(current_stack^.top, pIn);
end;

procedure kmGLMultMatrix(const pIn: pkmMat4);
begin
  lazyInitialize();
  kmMat4Multiply(current_stack^.top, current_stack^.top, pIn);
end;

procedure kmGLTranslatef(x, y, z: Single);
var
  translation: kmMat4;
begin
    //Create a rotation matrix using the axis and the angle
    kmMat4Translation(@translation,x,y,z);

    //Multiply the rotation matrix by the current matrix
    kmMat4Multiply(current_stack^.top, current_stack^.top, @translation);
end;

procedure kmGLRotatef(angle, x, y, z: Single);
var
  axis: kmVec3;
  rotation: kmMat4;
begin
  kmVec3Fill(@axis, x, y, z);
  kmMat4RotationAxisAngle(@rotation, @axis, kmDegreesToRadians(angle));
  kmMat4Multiply(current_stack^.top, current_stack^.top, @rotation);
end;

procedure kmGLScalef(x, y, z: Single);
var
  scaling: kmMat4;
begin
  kmMat4Scaling(@scaling, x, y, z);
  kmMat4Multiply(current_stack^.top, current_stack^.top, @scaling);
end;

procedure kmGLGetMatrix(mode :kmGLEnum; pOut: pkmMat4);
begin
    lazyInitialize();

    case mode of
      KM_GL_MODELVIEW :
            kmMat4Assign(pOut, modelview_matrix_stack.top);
      KM_GL_PROJECTION:
            kmMat4Assign(pOut, projection_matrix_stack.top);
      KM_GL_TEXTURE:
            kmMat4Assign(pOut, texture_matrix_stack.top);
    end;
end;

end.
