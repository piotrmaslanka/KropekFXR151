unit KTexManager;

{$mode objfpc}{$H+}

interface

uses
    KTypes, KConst, gl, glut;

type
    KTexture = class
    protected
          res: lp;
          glID: ubMW;
    public
          constructor LoadFromRAW16BPP(path: str; width, height: ubMW);
    end;

implementation
{ --------------------------------------------- KTexture }
constructor KTexture.LoadFromRAW16BPP(path: str; width, height: ubMW);
var
   f: file;
begin
     AssignFile(f, path);
     Reset(f, 1);
     GetMem(res, width*height*2);
     BlockRead(f, res^, width*height*2);
     glGenTextures(1, @glID);
     glBindTexture(GL_TEXTURE_2D, glID);

     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT, res);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
     glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
end;

end.

