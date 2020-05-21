unit KCameras;

{$mode objfpc}{$H+}
{$DEFINE DEBUG}

interface

uses
  KTypes, KConst, KClasses, gl, glu{$IFDEF DEBUG},KDebug{$ENDIF};

type
    KCamera = class (KRotatable)
    private
      _current: bool;
      procedure setCurrent(n: bool);
    public
      property current: bool read _current write SetCurrent;
      procedure fetchToGl;
      constructor Create();
      { reimplements }
      procedure SetPosition(x,y,z: float); overload;
      procedure SetPosition(p: r3dp); overload;
      procedure SetUp(a: r3dp);
      procedure SetForward(a: r3dp);
      procedure applyRotation(a: float; axis: r3dp);
      procedure SetLookat(a: r3dp);
      procedure moveForward(n: float);
      procedure moveBack(n: float);
      procedure moveUp(n: float);
      procedure moveDown(n: float);
      procedure Zero;
    end;


implementation
{ --------------------------------------------- KCamera }
procedure KCamera.SetCurrent(n: bool);
begin
     if n then
     begin
          self._current := true;
          self.fetchToGl;
     end else self._current := false;
end;
constructor KCamera.Create();
begin
     Inherited;
     self._current := false;
end;
procedure KCamera.fetchToGl;
var
   lookatv,upv: r3dp;
begin
     lookatv := self.Forward;
     upv := self.Up;
     glLoadIdentity();
     gluLookAt(self.position.x, self.position.y, self.position.z,
               self.position.x+lookatv.x, self.position.y+lookatv.y, self.position.z+lookatv.z,
               upv.x, upv.y, upv.z);
end;
{ -------- reimplements ------- }
procedure KCamera.SetPosition(x,y,z: float); overload; begin Inherited; if _current then fetchtogl; end;
procedure KCamera.SetPosition(p: r3dp); overload; begin Inherited; if _current then fetchtogl; end;
procedure KCamera.SetForward(a: r3dp); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.applyRotation(a: float; axis: r3dp); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.SetLookat(a: r3dp); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.SetUp(a: r3dp); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.moveForward(n: float); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.moveBack(n: float); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.moveUp(n: float); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.moveDown(n: float); begin Inherited; if _current then fetchtogl; end;
procedure KCamera.Zero; begin Inherited; if _current then fetchtogl; end;
end.

