unit KModels;

{$mode objfpc}{$H+}

interface

uses
  gl, KTypes, KClasses, KDrawLists{, KCollisions};

type
    KModel = class(KRotatable)
    public
          drawData: KDrawList;
          name: str;
          destructor Destroy();
          constructor Create();
          procedure SetDrawList(dl: KDrawList);
          procedure ResetDrawList;
          procedure Render;

//          collisioner: fCollidable;
    end;

    KModelSet = class (KRotatable)
    private
          items: array of KModel;
          items_len: ubMW;
          procedure SetModel(index: ubMW; mdl: KModel);
          function GetModel(index: ubMW): KModel;
    public
          property ModelCount: ubMW read items_len;
          constructor Create();
          procedure Render;
          property Models[index: ubMW]: KModel read GetModel write SetModel;

//          collisioner: fCollidable;     // uh-oh
    end;


implementation
{ ------------------------------------ KModelSet }
procedure KModelSet.Render;
var
   i: ubMW;
begin
     if items_len=0 then exit;
     glPushMatrix();
     glTranslatef(self.position.x, self.position.y, self.position.z);
     glMultMatrixf(self._crm);
     for i := 0 to items_len-1 do if items[i]<>nil then items[i].Render;
     glPopMatrix();
end;
function KModelSet.GetModel(index: ubMW): KModel;
begin
     if index >= items_len then result := nil else result := items[index];
end;
procedure KModelSet.SetModel(index: ubMW; mdl: KModel);
var
   i,sindex: ubMW;
begin
     if index >= items_len then
     	begin
            sindex := items_len;
            items_len := index+1;
      	    SetLength(items, items_len);
        end;

     for i := sindex to index do items[i] := nil;
     items[index] := mdl;

     if items_len>0 then
       while items[items_len-1]=nil do
       begin
             items_len -= 1;
             SetLength(items, items_len);
       end;
end;
constructor KModelSet.Create();
begin
     Inherited;
     items := nil;
     items_len := 0;
end;
{ ------------------------------------ KModel }
procedure KModel.ResetDrawList;
begin
     if not (self.drawData = nil) then
     begin
          self.drawData.Dec;
	  self.drawData := nil;
     end;
end;
destructor KModel.Destroy();
begin
     self.drawData.Dec;
     Inherited;
end;
constructor KModel.Create();
begin
     Inherited;
     drawData := nil;
//     collisioner := nil;
end;
procedure KModel.SetDrawList(dl: KDrawList);
begin
     dl.Inc;
     self.drawData := dl;
end;
procedure KModel.Render;
begin
     if self.drawData = nil then Exit;      { if nothing to render, just quit }
     glPushMatrix();
     glTranslatef(self.position.x, self.position.y, self.position.z);
     glMultMatrixf(self._crm);
     self.drawData.Render(0);
     glPopMatrix();
end;


end.

