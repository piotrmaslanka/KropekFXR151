unit KDebug;
{ internal shit so that the engine can debug itself actually. Phew }

{$mode objfpc}{$H+}

interface

uses
  SysUtils, KTypes;

function r3dpToString(a: r3dp): str;
function glmatrixToString(a: glmatrix): str;

procedure drawr3dp(title: str; a: r3dp);
procedure drawglmatrix(title: str; a: glmatrix);
implementation
procedure drawr3dp(title: str; a: r3dp);
begin
     Writeln(title+': ',r3dptostring(a));
end;
procedure drawglmatrix(title: str; a: glmatrix);
begin
     Writeln(title+': '#13#10,glmatrixtostring(a));
end;
function r3dpToString(a: r3dp): str;
begin
     result := Format('(%f|%f|%f)', [a.x,a.y,a.z]);
end;
function glmatrixToString(a: glmatrix): str;
begin
     result := Format('[%f|%f|%f|%f]'#13#10'[%f|%f|%f|%f]'#13#10'[%f|%f|%f|%f]'#13#10'[%f|%f|%f|%f]',
                      [a[0], a[4], a[8], a[12],
                       a[1], a[5], a[9], a[13],
                       a[2], a[6], a[10],a[14],
                       a[3], a[7], a[11],a[15]]);
end;

end.

