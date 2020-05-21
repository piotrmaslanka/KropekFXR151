program project1;

{$mode objfpc}{$H+}

uses
  Windows, KropekFX, KTypes, KConst;
var
  mapdl: KDrawList;
  sysman: KSystemManager;
  cam: KCamera;

  map: KModel;
begin
   Initialize('KropekFX Release 152 Interface 1.5',100,100,800,600,45,1,1000000);
   SetMode(KINIT_LIGHT, KINIT_ENABLE);
   sysman := KSystemManager.Create();

                                             // Set some nice background

   mapdl := KropekFX.getDrawList3DS('mapka.3ds',_r3dp(0.5,0.5,0.5));
   map := KModel.Create(); map.SetDrawList(mapdl);

   cam := KCamera.Create();

   cam.position := map.position + _r3dp(0,40,-5);
   cam.Lookat := map.position;
   cam.current := true;


   sysman.SetTimer(5);

   while True do
   begin
        sysman.refreshinput;
        with sysman.Keyboard do
        begin
             if isKeyDown(VK_DOWN) then cam.moveBack(0.5);
             if isKeyDown(VK_UP) then cam.moveForward(0.5);
             if isKeyDown(VK_LEFT) then map.applyRotation(1,AXIS_X);
             if isKeyDown(VK_RIGHT) then map.applyRotation(-1,AXIS_X);
        end;

        if sysman.userRequestedQuit then
           begin
                KropekFX.Finalize;
           	halt;
           end;

        KFXStartRender;
           KFXStartAccepts;
              map.Render;
           KFXEndAccepts;
        KFXEndRender;

       sysman.SystemBusyLoop; sysman.perfmgr.RegisterTime;
   end;
end.

