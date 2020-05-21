unit KFileReaders;

{$mode objfpc}{$H+}

interface

uses
  KTypes, KDrawLists, Classes, KConst;

type
  KFileReader = class               { file readin class }
  public
        scale: r3dp;
        fhandle: TFileStream;
        m: KDrawList;
        constructor Create();
        procedure setDrawList(d: KDrawList);
        procedure OpenFile(path: str);
        procedure CloseFile();
        procedure readIn; virtual; abstract;
        procedure passParameter(ptype: ubMW; param: lp);
  end;

implementation
{---------------------------------------------------- KFileReader }
procedure KFileReader.passParameter(ptype: ubMW; param: lp);
begin
     case ptype of
     KFILEREADER_SCALE: self.scale := lpr3dp(param)^;
     end;
end;
constructor KFileReader.Create();
begin
     Inherited;
end;
procedure KFileReader.setDrawList(d: KDrawList);
begin
     self.m := d;
end;
procedure KFileReader.OpenFile(path: str);
begin
     self.fhandle := TFileStream.Create(path, fmOpenRead);
end;
procedure KFileReader.CloseFile;
begin
     self.fhandle.Destroy();
end;
end.

