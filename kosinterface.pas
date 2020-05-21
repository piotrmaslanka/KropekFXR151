unit KOSInterface;

{$mode objfpc}{$H+}

interface

uses
  KTypes, KInit, Windows, KConst, gl;

type
     KPerformanceManager = class
     private
            lastTime: ubMW;
            curTime: ubMW;
     public
           procedure setAntialiasing(aa: ubMW);
           function GetCallPerSecond: float;
           procedure RegisterTime;
           constructor Create();
     end;

    KMouse = class
    private
           lastX, lastY: ubMW;
    public
          dX, dY: bMW;
          X,Y: ubMW;
          mode: ubMW;
          mbuttons: MouseButtonStatuses;
          procedure Refresh;
          procedure SetPosition(nx,ny: bMW);
          procedure Center;
          constructor Create();
    end;

    KKeyboard = class
    public
          function isKeyDown(key: ub16): bool;
          function isKeyPressed(key: ub16): bool;
    end;

    KSystemManager = class
    private
           timerDelay: ubMW;
           cTimerID: ubMW;
    public
      PerfMgr: KPerformanceManager;
      Mouse: KMouse;
      Keyboard: KKeyboard;
      constructor Create();
      destructor Destroy();
      procedure SystemBusyLoop;
      procedure RefreshInput;
      procedure setTimer(ms: ubMW);
      function userRequestedQuit: bool;
      function GetValue(val: ubMW): ubMW;
    end;

implementation
{----------------------------------------------------------------- KPerformanceManager }
function KPerformanceManager.GetCallPerSecond: float;           { returns RegisterTime() calls per second }
begin
   if self.curTime=self.lastTime then    self.curTime += 1;          { omfg, thats really fast}

   result := 1000 / (self.curTime - self.lastTime);
end;
procedure KPerformanceManager.RegisterTime;
begin
   self.lastTime := self.curTime;
   self.curTime := Windows.GetTickCount();
end;
constructor KPerformanceManager.Create();
begin
     Inherited;
     self.lastTime := Windows.GetTickCount()-1;
     self.curTime := self.lastTime+1;
end;
procedure KPerformanceManager.setAntialiasing(aa: ubMW);
begin
     case aa of
     KPERFMGR_ANTIALIASING_NONE:
                                begin
                                     glDisable(GL_LINE_SMOOTH);
                                     glDisable(GL_POLYGON_SMOOTH);
                                end;
     KPERFMGR_ANTIALIASING_LOW:
                                begin
                                     glEnable(GL_POLYGON_SMOOTH);
                                     glEnable(GL_LINE_SMOOTH);
                                     glHint(GL_POLYGON_SMOOTH_HINT, GL_FASTEST);
                                     glHint(GL_LINE_SMOOTH_HINT, GL_FASTEST);
                                end;
     KPERFMGR_ANTIALIASING_HIGH:
                                begin
                                     glEnable(GL_LINE_SMOOTH);
                                     glEnable(GL_POLYGON_SMOOTH);
                                     glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
                                     glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
                                end;
     end;
end;
{---------------------------------------------------- KKeyboard }
function KKeyboard.isKeyDown(key: ub16): bool;
begin
     result := vkeys[key];
end;
function KKeyboard.isKeyPressed(key: ub16): bool;
begin
     result := vkeypressed[key];
end;
{---------------------------------------------------- KMouse }
constructor KMouse.Create();
begin
     self.Center;
end;
procedure KMouse.Refresh;
begin
     self.mbuttons := [];
     if kinit.lmb then Include(self.mbuttons, kmbLeft);
     if kinit.smb then Include(self.mbuttons, kmbLeft);
     if kinit.rmb then Include(self.mbuttons, kmbLeft);
     case self.mode of
     KMOUSEMODE_FREE:
      begin
         X := mouseX;
         Y := mouseY;
      end;
     KMOUSEMODE_DELTA:
      begin
       dX := (KInit.sizeX div 2) - mouseX;
       dY := (KInit.sizeY div 2) - mouseY - GetSystemMetrics(SM_CYCAPTION);
       self.Center();
      end;
     end;
end;
procedure KMouse.SetPosition(nx,ny: bMW);
begin
     Windows.SetCursorPos(nx+KInit.WinX,ny+KInit.WinY);
end;
procedure KMouse.Center;
begin
     Windows.SetCursorPos(KInit.WinX + (KInit.sizeX div 2), KInit.WinY + (KInit.sizeY div 2));
end;
{--------------------------------------------- KSystemManager }
procedure KSystemManager.RefreshInput;
begin
     self.Mouse.Refresh;
end;
function KSystemManager.GetValue(val: ubMW): ubMW;
begin
     case val of
     KGETVAL_RC: result := KInit.hrc;
     KGETVAL_DC: result := KInit.hdc;
     KGETVAL_HWND: result := KInit.whnd;
     KGETVAL_HINST: result := hInstance;
     end;
end;
function KSystemManager.userRequestedQuit: bool;
begin
     result := KInit.userRequiredQuit;
end;
procedure KSystemManager.SystemBusyLoop;
begin
     FillChar(vkeypressed, sizeof(boolean)*65535, 0);
     isTimerTicked := false;
     if self.timerDelay <> 0 then repeat ProcessSingleMessage until isTimerTicked else
     while PeekMessage(KInit.message, KInit.whnd, 0, 0, Windows.PM_REMOVE) do
     begin
  //        TranslateMessage(KInit.message);
          DispatchMessage(KInit.message);
     end;
end;
procedure KSystemManager.setTimer(ms: ubMW);
begin
     if (self.timerDelay=0) and (ms=0) then exit else
     if self.timerDelay = 0 then
     begin
          self.cTimerID := windows.setTimer(whnd, 1, ms, nil);
          self.timerDelay := ms;
     end else if ms = 0 then
     begin
          if self.timerDelay <> 0 then windows.KillTimer(whnd,self.cTimerID);
          self.timerDelay := 0;
          exit;
     end else
     begin
          windows.KillTimer(whnd, self.cTimerID);
          self.cTimerID := windows.SetTimer(whnd, 1, ms, nil);
          self.timerDelay := ms;
     end;
end;
destructor KSystemManager.Destroy();
begin
     self.Mouse.Destroy();
     self.Keyboard.Destroy();
     self.PerfMgr.Destroy();
     Inherited;
end;
constructor KSystemManager.Create();
begin
     Inherited;
     self.timerDelay := 0;
     self.PerfMgr := KPerformanceManager.Create();
     self.Mouse := KMouse.Create();
     self.Keyboard := KKeyboard.Create();
end;
end.

