unit KTypes;
{ Part of KropekFX engine; Licensed under latest GNU GPL }
{$mode objfpc}{$H+}
{$DEFINE DEBUG}

interface
type
    { bases }
    ubMW = DWORD;
    bMW = INTEGER;
    ub8 = byte;
    ub16 = word;
    ub32  = dword;
    b8 = shortint;
    b16 = smallint;
    b32 = integer;
    float = single;
    lp = pointer;
    str = string;
    bool = boolean;
    { pointers to bases }
    lpubMW = ^ubMW;
    lpbMW = ^bMW;
    lpub8 = ^ub8;
    lpub16 = ^ub16;
    lpub32 = ^ub32;
    lpb8 = ^b8;
    lpb16 = ^b16;
    lpb32 = ^b32;
    lpfloat = ^float;
    lplp = ^lp;
    lpstr = ^str;
    lpbool = ^bool;
    { some graphic types }
    r2dp = record x,y: float; end;
    r2dpf = record x,z: float; end;     { flat representation }
    r3dp = record x,y,z: float; end;
    r4dp = record x,y,z,w: float end;
    crgb = record r,g,b: float; end;
    crgba = record r,g,b,a: float; end;
    glmatrix = array[0..15] of float;
    { pointers to some graphic types }
    lpr2dp = ^r2dp;
    lpr2dpf = ^r2dpf;
    lpr3dp = ^r3dp;
    lpcrgb = ^crgb;
    lpcrgba = ^crgba;
    lpglmatrix = ^glmatrix;
    { more advanced stuff }
    line = array[0..1] of r3dp;
    triangle = array[0..2] of r3dp;
    quad = array[0..3] of r3dp;

    triangle_item = record
          position: triangle;
          normals: triangle;
          color: crgb;
          tag: ubMW;
    end;
    { pointers to more advanced stuff }
    lpline = ^line;
    lptriangle = ^triangle;
    lpquad = ^quad;
    lptriangle_item = ^triangle_item;
    { different enums }
    MouseButtonStatus = (kmbLeft, kmbMiddle, kmbRight);
    MouseButtonStatuses = set of MouseButtonStatus;
    { lists }
    lpSLLNode = ^SLLNode;
    SLLNode = record
             Next: lpSLLNode;
             Data: lp;
    end;
{------------------------------------------------------------------- SLL management }
procedure sllPush(var list: lpSLLNode; value: lp);            { Places as the first item }
function sllPop(var list: lpSLLNode): lp;                     { Takes first item from list }
function sllNext(var l: lpSLLNode): bool;   { bool if l not nil. l=l^.next }
{------------------------------------------------------------------- constructors }
function _r3dp(x,y,z: float): r3dp;
function _r2dpf(x,z: float): r2dpf; overload;
function _r2dpf(a: r3dp): r2dpf; overload;
function _crgb(r,g,b: float): crgb;
function _crgba(r,g,b,a: float): crgba;
{------------------------------------------------------------------- operator overloading }
operator + (a,b: r3dp) c: r3dp;                               { Vector Addition }
operator - (a,b: r3dp) c: r3dp;                               { Vector Substraction }
operator * (a: r3dp; b: float) c: r3dp;                       { Vector-By-Scalar }
operator * (a,b: r3dp) c: r3dp;                               { Cross Product }
operator **(a,b: r3dp) c: float;                              { Dot Product }
operator = (a,b: r3dp) c: bool;                               { Vector equality }
{------------------------------------------------------------------- useful functions }
{----------- r3dp --------}
procedure r3dpNormalizel(var a: r3dp); overload;
function r3dpNormalize(a: r3dp): r3dp; overload;              { Vector normalization }
function r3dpDistance(a,b: r3dp): float;                      { Distance between two points }
function r3dpLength(a: r3dp): float;                          { Point distance from (0,0,0) }
{----------- r2dpf --------}
function r2dpfDistance(a,b: r2dpf): float;
function r2dpfLength(a: r2dpf): float;
implementation
{------------------------------------------------------------------- constructors }
function _r3dp(x,y,z: float): r3dp;
begin
     result.x := x; result.y := y; result.z := z;
end;
function _r2dpf(x,z: float): r2dpf; overload;
begin
     result.x := x; result.z := z;
end;
function _r2dpf(a: r3dp): r2dpf; overload;
begin
     result.x := a.x; result.z := a.z;
end;
function _crgb(r,g,b: float): crgb;
begin
     result.r := r; result.g := g; result.b := b;
end;
function _crgba(r,g,b,a: float): crgba;
begin
     result.r := r; result.g := g; result.b := b; result.a := a;
end;
{------------------------------------------------------------------- operator overloading }
operator + (a,b: r3dp) c: r3dp;
begin
     c.x := a.x+b.x; c.y := a.y+b.y; c.z := a.z+b.z;
end;
operator - (a,b: r3dp) c: r3dp;
begin
     c.x := a.x-b.x; c.y := a.y-b.y; c.z := a.z-b.z;
end;
operator * (a: r3dp; b: float) c: r3dp;
begin
     c.x := a.x*b; c.y := a.y*b; c.z := a.z*b;
end;
operator * (a,b: r3dp) c: r3dp;
begin
     c.x := a.y*b.z - a.z*b.y; c.y := a.z*b.x - a.x*b.z; c.z := a.x*b.y - a.y*b.x;
end;
operator ** (a,b: r3dp) c: float;
begin
     c := a.x*b.x + a.y*b.y + a.z*b.z;
end;
operator = (a,b: r3dp) c: bool;
begin
     result := (a.x=b.x) and (a.y=b.y) and (a.z=b.z);
end;
{------------------------------------------------------------------- useful functions }
procedure r3dpNormalizel(var a: r3dp); overload;                     { HTOS: r3dp-Normalize-Local }
var
   len: float;
begin
    len := sqrt((a.x)*(a.x) + (a.y)*(a.y) + (a.z)*(a.z));
    a.x := a.x/len; a.y := a.y/len; a.z := a.z/len;
end;
function r3dpNormalize(a: r3dp): r3dp; overload;
var
   len: float;
begin
    len := sqrt((a.x)*(a.x) + (a.y)*(a.y) + (a.z)*(a.z));
    result.x := a.x/len; result.x := a.x/len; result.z := a.z/len;
end;
function r3dpDistance(a,b: r3dp): float;
begin
     result := sqrt((a.x-b.x)*(a.x-b.x)+
                    (a.y-b.y)*(a.y-b.y)+
                    (a.z-b.z)*(a.z-b.z));
end;
function r3dpLength(a: r3dp): float;
begin
     result := sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
end;
function r2dpfDistance(a,b: r2dpf): float;
begin
     result := sqrt((a.x-b.x)*(a.x-b.x)+
                    (a.z-b.z)*(a.z-b.z));
end;
function r2dpfLength(a: r2dpf): float;
begin
     result := sqrt((a.x)*(a.x)+(a.z)*(a.z));
end;
{------------------------------------------------------------------- SLL management }
procedure sllPush(var list: lpSLLNode; value: lp);
var
   tmp: lpSLLNode;
begin
     GetMem(tmp, sizeof(SLLNode)); tmp^.Data := value;
     tmp^.Next := list;
     list := tmp;
end;
function sllPop(var list: lpSLLNode): lp;
var
   tmp: lpSLLNode;
begin
     {$IFDEF DEBUG}if list=nil then begin Writeln('sllPop: cannot pop from an empty list'); readln; halt; end; {$ENDIF}
     tmp := list;
     if list^.Next = nil then list := nil else list := list^.Next;
     result := tmp^.Data;
     FreeMem(tmp);
end;
function sllNext(var l: lpSLLNode): bool;
begin
     l := l^.Next;
     result := not (l=nil);
end;
end.

