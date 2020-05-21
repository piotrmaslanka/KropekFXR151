unit KropekFX;

{$mode objfpc}{$H+}
{$DEFINE TALKALOT}

interface

uses
  KClasses, KDrawLists, KModels, KFileReaders, KConst, KTypes, K3DSReaders, KInit,
  KFormats, KCameras, KOSInterface, {KCollisions,} KDebug, KTexManager;
type
    KDrawList = KDrawLists.KDrawList;
    KModel = KModels.KModel;
    KModelSet = KModels.KModelSet;
    KCamera = KCameras.KCamera;
    KSystemManager = KOSInterface.KSystemManager;
    KRotatable = KClasses.KRotatable;

//    fCollidable = KCollisions.fCollidable;
//    fCylinder = KCollisions.fCylinder;


function getDrawList3DS(path: str; scale: r3dp): KDrawList;
procedure Initialize(wndname: pchar; x,y,w,h: ubMW; fov,nearclip,farclip: float);
procedure KFXStartRender;
procedure KFXEndRender;
procedure KFXStartAccepts;
procedure KFXEndAccepts;
procedure SetMode(aspect, data: ubMW);
procedure SetParam(aspect: ubMW; data: lp);
procedure Finalize;

implementation
procedure Finalize; begin KInit.Finalize; end;
procedure Initialize(wndname: pchar; x,y,w,h: ubMW; fov,nearclip,farclip: float);
begin KInit.Initialize(wndname,x,y,w,h,fov,nearclip,farclip); end;
procedure SetParam(aspect: ubMW; data: lp); begin KInit.SetParam(aspect, data); end;
procedure SetMode(aspect, data: ubMW); begin KInit.SetMode(aspect, data); end;
function getDrawList3DS(path: str; scale: r3dp): KDrawList;
begin result := KFormats.getDrawList3DS(path,scale); end;
procedure KFXStartRender; begin KInit.KFXStartRender; end;
procedure KFXStartAccepts; begin end;
procedure KFXEndAccepts; begin end;
procedure KFXEndRender; begin KInit.KFXEndRender; end;



end.

