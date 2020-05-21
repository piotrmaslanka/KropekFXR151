unit K3DSReaders;

{$mode objfpc}{$H+}
{$DEFINE TALKALOT}

interface

uses
  KConst, KFileReaders, KTypes, KDrawLists;

type
    KParser3DS = class(KFileReader)
        procedure readIn;
    end;

implementation
const
     default3DSColor: crgb = (r:1;g:1;b:1);

     soFromBeginning = 0;
     soFromCurrent = 1;
     soFromEnd = 2;

     MAIN_CHUNK = $4D4D;
     EDITOR_3D_CHUNK = $3D3D;
     OBJECT_CHUNK = $4000;
     VERTICES_LIST = $4110;
     TRIANGULAR_MESH = $4100;
     FACES_DESCRIPTION = $4120;
type
    T3DSTriangle = packed record
       v1,v2,v3: ub16;
    end;

    T3DSObject = class
    private
           Vertices, Faces: ubMW;
           VertexList: array of r3dp;
           FaceList: array of T3DSTriangle;
           VertexNorms: array of r3dp;
           FaceNorms: array of r3dp;
           objectname: str;
           dlist: KDrawList;
    public
          destructor Destroy;
          procedure AddVertex(v: r3dp);
          procedure AddFace(v: T3DSTriangle);
          constructor Create(name: str; drawList: KDrawList);
    end;
    TChunkHeader = packed record
       ID: ub16;
       Size: ub32;
    end;
function _3dst(v1,v2,v3: ub16): T3DSTriangle;
begin
     result.v1 := v1; result.v2 := v2; result.v3 := v3;
end;
{---------------------------------------------- T3DSObject }
procedure T3DSObject.AddVertex(v: r3dp);
begin
     self.Vertices += 1;
     SetLength(self.VertexList, self.Vertices);
     self.VertexList[self.Vertices-1] := v;
     SetLength(self.VertexNorms, self.Vertices);
     self.VertexNorms[self.Vertices-1] := _r3dp(0,0,0);
end;
procedure T3DSObject.AddFace(v: T3DSTriangle);
begin
     self.Faces += 1;
     SetLength(self.FaceList, self.Faces);
     self.FaceList[self.Faces-1] := v;
     SetLength(self.FaceNorms, self.Faces);
     self.FaceNorms[self.Faces-1] := _r3dp(0,0,0);
end;
destructor T3DSObject.Destroy;
var
   d,b: ub16;
   tri: triangle_item;
   facenorm: r3dp;
begin
     for d := 0 to self.Faces-1 do                { calculate face normals }
     begin
          facenorm := self.VertexList[self.FaceList[d].v2] * self.VertexList[self.FaceList[d].v1];
          self.VertexNorms[self.FaceList[d].v1] := self.VertexNorms[self.FaceList[d].v1] + facenorm;
          self.VertexNorms[self.FaceList[d].v2] := self.VertexNorms[self.FaceList[d].v2] + facenorm;
          self.VertexNorms[self.FaceList[d].v3] := self.VertexNorms[self.FaceList[d].v3] + facenorm;
     end;


     for d := 0 to self.Vertices-1 do                           { normalize vertex normal vectors }
         self.VertexNorms[d] := r3dpNormalize(self.VertexNorms[d]);

     { end of pathetic processing, now lets get it done! }
     for d := 0 to self.Faces-1 do
     begin
          tri.position[0].x := self.VertexList[self.FaceList[d].v1].x;
          tri.position[0].y := self.VertexList[self.FaceList[d].v1].y;
          tri.position[0].z := self.VertexList[self.FaceList[d].v1].z;
          tri.position[1].x := self.VertexList[self.FaceList[d].v2].x;
          tri.position[1].y := self.VertexList[self.FaceList[d].v2].y;
          tri.position[1].z := self.VertexList[self.FaceList[d].v2].z;
          tri.position[2].x := self.VertexList[self.FaceList[d].v3].x;
          tri.position[2].y := self.VertexList[self.FaceList[d].v3].y;
          tri.position[2].z := self.VertexList[self.FaceList[d].v3].z;
          tri.color := default3DSColor;
          tri.normals[0] := self.VertexNorms[self.FaceList[d].v1];
          tri.normals[1] := self.VertexNorms[self.FaceList[d].v2];
          tri.normals[2] := self.VertexNorms[self.FaceList[d].v3];
          self.dlist.addTriangle(tri);
     end;

     { cleanup }
     SetLength(self.VertexList,0);
     SetLength(self.FaceList,0);
     SetLength(self.VertexNorms,0);
     SetLength(self.FaceNorms,0);
     Inherited;
end;
constructor T3DSObject.Create(name: str; drawlist: KDrawList);
begin
     self.vertices := 0; self.faces := 0;
     self.objectname := name;
     self.dlist := drawList;
     self.VertexList := nil; self.FaceList := nil; self.VertexNorms := nil; self.FaceNorms := nil;
     {$IFDEF TALKALOT} Writeln('3ds: Reading in object "',name,'"'); {$ENDIF}
end;
{---------------------------------------------- KParser3DS }
procedure KParser3DS.readIn;
var
   cobj: T3DSObject;
   cchunk: TChunkHeader;
   currentState: ubMW;
   name: str;
   c: ub8;
   i,vn: ub16;
   Vert: r3dp; Face: t3dstriangle;
begin
     self.m.newFrame;
     cobj := nil;

     while not (self.fhandle.Size=self.fhandle.Position) do
     begin
          self.fhandle.ReadBuffer(cchunk, sizeof(TChunkHeader));
          cchunk.size -= 6;
          case cchunk.id of
          MAIN_CHUNK: begin end;
          EDITOR_3D_CHUNK: begin end;
          OBJECT_CHUNK:
                       begin
                            if cobj<>nil then begin cobj.Destroy; cobj := nil; end;
                            name := '';
                            repeat
                                if c<>0 then name:=pchar(string(name)+ chr(c));
                                                  { ^ this is gonna hurt... A LOT! }
                                self.fhandle.Read(c, 1);
                            until c=0;
                            cobj := T3DSObject.Create(name,self.m);
                       end;
          TRIANGULAR_MESH: begin end;
          VERTICES_LIST:
                        begin
                           self.fhandle.Read(vn,2);
                           for i := 0 to vn-1 do
                               begin
                                    self.fhandle.Read(Vert, sizeof(r3dp));
                                    cobj.AddVertex(_r3dp(Vert.x*self.scale.x, Vert.y*self.scale.y, Vert.z*self.scale.z));
                               end;
                        end;
          FACES_DESCRIPTION:
                        begin
                             self.fhandle.Read(vn, 2);
                             for i := 0 to vn-1 do
                             begin
                                  self.fhandle.Read(Face, sizeof(T3DSTriangle));
                                  self.fhandle.Read(vn, 2);                {face flags}
                                  cobj.AddFace(Face);
                             end;
                        end;
          else     { if I don't know the chunks, skip them along with their subchunks }
              self.fhandle.Seek(cchunk.Size, soFromCurrent);
          end;
     end;
    if cobj <> nil then cobj.Destroy;
    Writeln('Polys: ',m.drawList[0].length);
end;

end.


