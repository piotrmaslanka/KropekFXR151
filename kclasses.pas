unit KClasses;

{$mode objfpc}{$H+}
{$DEFINE DEBUG}

interface

uses
  KTypes, gl{$IFDEF DEBUG},KDebug{$ENDIF};

type
    KRefCounter = class                         { class that can be reference counted }
        counter: ubMW;
        procedure Inc;
        procedure Dec;
        function inUse: bool;                        { true on counter>0 }
        constructor Create();
    end;

    KPositionable = class                       { something that has a position }
    protected
      _pos: r3dp;
      _previous_position: r3dp;
    public
      procedure StackUp;     { puts current position on storage }{ Stack* are used on collision detection, ya know }
      procedure StackDown;     { loads current position on storage }
      procedure Zero;
      constructor Create();
      procedure SetPosition(x,y,z: float); overload;
      procedure SetPosition(p: r3dp); overload;
      property Position: r3dp read _pos write SetPosition;
    end;

    KRotatable = class (KPositionable)          { something that has a position and you can rotate it }
    protected
       _crm: glmatrix;
       _previous_crm: glmatrix;
       function GetUp: r3dp;
       function GetForward: r3dp;
       procedure SetUp(a: r3dp);
       procedure SetForward(a: r3dp);
       procedure SetLookat(a: r3dp);
    public
       procedure StackUp;
       procedure StackDown;
       constructor Create();
       procedure Zero;
       property Up: r3dp read GetUp write SetUp;
       property Forward: r3dp read GetForward write SetForward;
       property Lookat: r3dp write SetLookat;
       procedure moveForward(n: float);
       procedure moveBack(n: float);
       procedure moveUp(n: float);
       procedure moveDown(n: float);
       procedure applyRotation(a: float; axis: r3dp);
    end;

implementation
{ ---------------------------------------- KRefCounter }
constructor KRefCounter.Create();
begin
     self.counter := 0;
end;
procedure KRefCounter.Inc;
begin
     self.counter += 1;
end;
procedure KRefCounter.Dec;
begin
     self.counter -= 1;
end;
function KRefCounter.inUse: bool;
begin
     result := (self.counter>0);
end;
{ ---------------------------------------- KPositionable }
procedure KPositionable.StackUp; begin self._previous_position := self._pos; end;
procedure KPositionable.StackDown; begin self._pos := self._previous_position; end;
procedure KPositionable.Zero; begin self._pos := _r3dp(0,0,0); end;
constructor KPositionable.Create();
begin
     self.Zero;
end;
procedure KPositionable.SetPosition(x,y,z: float); overload;
begin
     self._pos.x := x; self._pos.y := y; self._pos.z := z;
end;
procedure KPositionable.SetPosition(p: r3dp); overload;
begin
     self._pos := p;
end;
{----------------------------------------- KRotatable }
constructor KRotatable.Create();
begin
     Inherited;
     self.Zero;
end;
procedure KRotatable.StackUp;
begin
     Inherited;
     self._previous_crm := self._crm;
end;
procedure KRotatable.StackDown;
begin
     Inherited;
     self._crm := _previous_crm;
end;
procedure KRotatable.Zero;
begin
     Inherited;
     glPushMatrix();
     glLoadIdentity();
     glGetFloatv(GL_MODELVIEW_MATRIX, self._crm);
     glPopMatrix();
end;
procedure KRotatable.applyRotation(a: float; axis: r3dp);
begin
     glPushMatrix();
     glLoadIdentity();
     glRotatef(a, axis.x, axis.y, axis.z);
     glMultMatrixf(self._crm);
     glGetFloatv(GL_MODELVIEW_MATRIX, self._crm);
     glPopMatrix();
end;
function KRotatable.GetUp: r3dp;
begin
     result := _r3dp(self._crm[1], self._crm[5], self._crm[9]);
end;
function KRotatable.GetForward: r3dp;
begin
   result := _r3dp(self._crm[2], self._crm[6], self._crm[10]);
end;
procedure KRotatable.SetUp(a: r3dp);
begin
     r3dpNormalizel(a); self._crm[1] := a.x; self._crm[5] := a.y; self._crm[9] := a.z;
end;
procedure KRotatable.SetForward(a: r3dp);
begin
   r3dpNormalizel(a); self._crm[2] := a.x; self._crm[6] := a.y; self._crm[10] := a.z;
end;
procedure KRotatable.SetLookat(a: r3dp);
begin
     SetForward(a-self.position);
end;
procedure KRotatable.moveForward(n: float);
var
   fv: r3dp;
begin
     fv := self.Forward;
     self.position := self.position + (fv*n);
end;
procedure KRotatable.moveBack(n: float);
var
   fv: r3dp;
begin
     fv := self.Forward;
     self.position := self.position - (fv*n);
end;
procedure KRotatable.moveUp(n: float);
var
   fv: r3dp;
begin
     fv := self.Up;
     self.position := self.position + (fv*n);
end;
procedure KRotatable.moveDown(n: float);
var
   fv: r3dp;
begin
     fv := self.Up;
     self.position := self.position - (fv*n);
end;
end.

