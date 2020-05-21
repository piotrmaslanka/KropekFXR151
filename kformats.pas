unit KFormats;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, KDrawLists, KTypes, K3DSReaders, KConst;
function getDrawList3DS(path: str; scale: r3dp): KDrawList;

implementation
function getDrawList3DS(path: str; scale: r3dp): KDrawList;
var
   reader: KParser3DS;
begin
     result := KDrawList.Create();
     reader := KParser3DS.Create();
     reader.setDrawList(result);
     reader.passParameter(KFILEREADER_SCALE, @scale);
     reader.OpenFile(path);
     reader.readIn;
     reader.CloseFile();
     reader.Destroy();
end;


end.

