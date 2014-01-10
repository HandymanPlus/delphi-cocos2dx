unit mat4stack;

interface
uses
  SysUtils,
  utility;

type
  tkmMat4Ary = array [0..0] of kmMat4;
  pkmMat4Ary = ^tkmMat4Ary;

  km_mat4_stack = record
    capacity: Integer;
    item_count: Integer;
    top: pkmMat4;
    stack: pkmMat4Ary;
  end;
  pkm_mat4_stack = ^km_mat4_stack;

procedure km_mat4_stack_initialize(stack: pkm_mat4_stack);
procedure km_mat4_stack_push(stack: pkm_mat4_stack; const item: pkmMat4);
procedure km_mat4_stack_pop(stack: pkm_mat4_stack; pOut: pkmMat4);
procedure km_mat4_stack_release(stack: pkm_mat4_stack);

implementation
uses
  mat4;

const INITIAL_SIZE = 30;
const INCREMENT = 50;

procedure km_mat4_stack_initialize(stack: pkm_mat4_stack);
begin
  stack^.stack := AllocMem(SizeOf(kmMat4)*INITIAL_SIZE);
  stack^.capacity := INITIAL_SIZE;
  stack^.top := nil;
  stack^.item_count := 0;
end;

procedure km_mat4_stack_push(stack: pkm_mat4_stack; const item: pkmMat4);
var
  temp: pkmMat4;
begin
  stack^.top := @stack^.stack[stack^.item_Count];
  kmMat4Assign(stack^.top, item);
  Inc(stack^.item_count);

  if stack^.item_count >= stack^.capacity then
  begin
    Inc(stack^.capacity, INCREMENT);
    temp := @stack^.stack[0];
    stack^.stack := AllocMem(SizeOf(kmMat4)*stack^.capacity);
    Move(temp^, stack^.stack[0],SizeOf(kmMat4)*(stack.capacity - INCREMENT));
    FreeMem(temp);
    stack^.top := @stack^.stack[stack^.item_count - 1];
  end;
end;

procedure km_mat4_stack_pop(stack: pkm_mat4_stack; pOut: pkmMat4);
begin
  Dec(stack^.item_count);
  stack^.top := @stack^.stack[stack^.item_count - 1];
end;

procedure km_mat4_stack_release(stack: pkm_mat4_stack);
begin
  FreeMem(stack^.stack);
  stack^.top := nil;
  stack^.item_count := 0;
  stack^.capacity := 0;
end;

end.
