unit KCollisions;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}

// Buggy! Do not include!

interface

uses
  KTypes, KConst, KClasses, KDrawLists;

type
    { -------------------------------------------------------- Collidables }
    fCollidable = class
    protected
          parent: KPositionable;
          internalType: ubMW;
    public
           constructor Create(p: KPositionable);
           function CollideAgainst(n: fCollidable): bool;
    end;
    fCylinder = class (fCollidable)
    protected
             Height, Radius: float;
    public
          constructor Create(p: KPositionable);
          procedure FromDrawList(p: KDrawList);
    end;
    fTriangleMesh = class (fCollidable)
    public
          data: KDrawList;
          constructor Create(p: KPositionable);
          procedure FromDrawList(p: KDrawList);
          function Raycast(l: line; var i: r3dp): bool;
    end;

{ collision operators, return True on collision }
operator and (a,b: fCylinder) c: bool;
implementation
{ --------------------------------------- collision operators }
operator and (a,b: fCylinder) c: bool;
begin
     if a.parent.position.y > b.parent.position.y + b.height then c:=false else                   { B far below A}
     if b.parent.position.y > a.parent.position.y + a.height then c:=false else                   { A far below B}
     if r2dpfDistance(_r2dpf(a.parent.position), _r2dpf(b.parent.position)) > a.Radius+b.Radius then c:=false else
                                                         c := true;
end;
{ --------------------------------------- fTriangleMesh }
function TriangleRaycast(ray: line; tri: triangle; var p: r3dp): bool; forward;
function fTriangleMesh.Raycast(l: line; var i: r3dp): bool;
var
   k: ubMW;
begin
     result := false;
     for k := 0 to self.data.drawlist[0].length-1 do
     begin
          if TriangleRaycast(l, self.data.drawlist[0].drawList[k].position, i) then
             begin
                  result := true;
                  break;
             end;
     end;
end;
procedure fCylinder.FromDrawlist(p: KDrawList);
begin
     //     self.data := p;
     // TODO: Unimplemented!
end;
{ --------------------------------------- fCollidable }
constructor fCollidable.Create(p: KPositionable);
begin
     self.internalType := KCOLLIDABLE_TRIMESH;
     self.parent := p;
end;
function fCollidable.CollideAgainst(n: fCollidable): bool;
begin
     case self.internalType of
     KCOLLIDABLE_CYLINDER:
                          case n.internalType of
                          KCOLLIDABLE_CYLINDER: result := fCylinder(n) and fCylinder(self);
                          end;
     end;
end;
{ --------------------------------------- fCylinder }
constructor fCylinder.Create(p: KPositionable);
begin
     Inherited; self.Height := 0; self.Radius := 0;
     self.internalType := KCOLLIDABLE_CYLINDER;
end;
procedure fCylinder.FromDrawlist(p: KDrawList);
begin
     self.Height := p.topY - p.bottomY;
     self.Radius := p.flatRadius;
end;
function TriangleRaycast(ray: line; tri: triangle; var p: r3dp): bool;
var
   u,v,n,dir,w0,w: r3dp;
   r,a,b: float;
   uu,uv,vv,wu, wv, d: float;
   s,t: float;
begin
     u := tri[1] - tri[0];
     v := tri[2] - tri[1];
     n := u*v;
     if (n=_r3dp(0,0,0)) then begin result := false; exit; end;
     dir := ray[1] - ray[0];
     w0 := ray[0] - tri[0];
     a := -n**w0;
     b := n**dir;
     if abs(b)<INFINITESMAL then
        begin
             if (a=0) then result := true else result := false;
             exit;
        end;
     r := a/b;
     if(r<0) then begin result := false; exit; end;
     p := ray[0] + dir*r;

     uu := u**u; uv := u**v; vv := v**v; w := p - tri[0]; wu := w**u; wv := w**v;
     d := uv * uv - uu * vv;
     s := (uv * wv - vv*wu)/d;
     if (s<0) and (s>1) then begin result := false; exit; end;
     t := (uv*wu - uu*wv)/d;
     if (t<0) and (s+t)>1 then begin result := false; exit; end;
     result := true;
end;
end.

