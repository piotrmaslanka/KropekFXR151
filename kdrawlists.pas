unit KDrawLists;

{$mode objfpc}{$H+}

interface

uses
  KTypes, KClasses, KConst, gl;


type
    TDrawListData = record
                  length: ubMW;
                  drawList: array of triangle_item;
                  glID: ubMW;
                  phID: ubMW;
    end;
    PDrawListData = ^TDrawListData;
    KDrawList = class(KRefCounter)
    private
           length: ubMW;
    public
    	   drawList: array of TDrawListData;
           property Frames: ubMW read length;
           boundingSphereRadius: float;          { distance from (0,0,0) to furthest vertex }
           flatRadius: float;                    { distance from r3dpf(0,0) to furthest r3dpf vertex }
           topY, bottomY: float;                 { max Y and min Y }
           topX, bottomX: float;                 { max X and min X }
           topZ, bottomZ: float;                 { max Z and min Z }
           destructor Destroy();
           procedure newFrame;
           procedure addTriangle(t: triangle_item);
           procedure render(frame: ubMW);
           constructor Create();
    end;
implementation
{------------------------------------ KDrawList }
procedure KDrawList.newFrame();
begin
    length += 1;
    SetLength(drawList, length);
end;
procedure KDrawList.addTriangle(t: triangle_item);
var
   len: lpubMW;
begin
     len := @drawList[length-1].length;
     len^ += 1;
     SetLength(drawList[length-1].drawList, len^);
     drawList[length-1].drawList[len^-1] := t;
end;
procedure KDrawList.render(frame: ubMW);
var
   i,j: ubMW;
begin
     glBegin(GL_TRIANGLES);
     for i := 0 to length-1 do
         for j := 0 to drawList[i].length-1 do
           with drawList[i].drawList[j] do
           begin
                glColor3f(color.r,color.g,color.b);
                glNormal3f(normals[0].x, normals[0].y, normals[0].z);
                glVertex3f(position[0].x, position[0].y, position[0].z);
                glColor3f(color.r,color.g,color.b);
                glNormal3f(normals[1].x, normals[1].y, normals[1].z);
                glVertex3f(position[1].x, position[1].y, position[1].z);
                glColor3f(color.r,color.g,color.b);
                glNormal3f(normals[2].x, normals[2].y, normals[2].z);
                glVertex3f(position[2].x, position[2].y, position[2].z);
           end;
     glEnd();
end;
destructor KDrawList.Destroy();
var
   i: ubMW;
begin
     for i := 0 to length-1 do SetLength(self.drawList[i].drawList, 0);
     SetLength(self.drawList, 0);
end;
constructor KDrawList.Create();
begin
     self.drawList := nil;
     self.length := 0;
     self.boundingSphereRadius := 0;
     self.flatRadius := 0;
     self.topY := -INFINITY;
     self.bottomY := INFINITY;
     self.topX := -INFINITY;
     self.bottomX := INFINITY;
     self.topZ := -INFINITY;
     self.bottomZ := INFINITY;
end;


end.

