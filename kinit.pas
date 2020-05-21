unit KInit;

{$mode objfpc}{$H+}

interface
uses
  KConst, Windows, gl, glu, KTypes;
var
   hdc: dword;
   wnd: wndClass;
   whnd: hwnd;
   lpszAppName: PChar;
   message: msg;
   hrc: dword;
   pfd: pixelformatdescriptor;
   ipfd: ub32;
   vkeys: array[0..65535] of bool;
   vkeypressed: array[0..65535] of bool;
   isTimerTicked: bool;
   userRequiredQuit: bool;
   mouseX, mouseY: ub16;
   LMB, RMB, SMB: bool;
   buf_clear_color: crgb;

   winX, winY: bMW;
   sizeX, sizeY: bMW;

procedure ProcessSingleMessage;
procedure SetMode(aspect, data: ubMW);
procedure Initialize(wndname: pchar; x,y,w,h: ubMW; fov,nearclip,farclip: float);
procedure Finalize;
procedure SetParam(aspect: ubMW; data: lp);
procedure KFXStartRender;
procedure KFXEndRender;
implementation

const
     className: pchar = 'kropekfxopenglwindow';
procedure Finalize;
begin

end;
procedure KFXStartRender;
begin
   with buf_clear_color do glClearColor(r,g,b,1);
   glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;
procedure KFXEndRender;
var
   i: integer;
begin
     glFinish();
     swapbuffers(KInit.hdc);
end;
procedure SetParam(aspect: ubMW; data: lp);
begin
     case aspect of
          KINIT_CLEARBUFFER: buf_clear_color := lpcrgb(data)^;
     end;
end;
procedure SetMode(aspect, data: ubMW);
begin
     case aspect of
       KINIT_FILLMODE: if data=KINIT_ENABLE then glPolygonMode(GL_FRONT_AND_BACK, GL_FILL) else glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
       KINIT_LIGHT: if data=KINIT_ENABLE then glEnable(GL_LIGHTING) else glDisable(GL_LIGHTING);
       KINIT_CULLING: if data=KINIT_ENABLE then glEnable(GL_CULL_FACE) else glDisable(GL_CULL_FACE);
       KINIT_ZBUFFER: if data=KINIT_ENABLE then glEnable(GL_DEPTH_TEST) else glDisable(GL_DEPTH_TEST);
       KINIT_COLOR_MODELS: if data=KINIT_ENABLE then glEnable(GL_COLOR_MATERIAL) else glDisable(GL_COLOR_MATERIAL);
     end;

end;
procedure ProcessSingleMessage;
begin
     if PeekMessage(message, 0, 0, 0, PM_REMOVE) then
     begin
     //    TranslateMessage(message);
         DispatchMessage(message);
     end;
end;
procedure pmouse(lparam: lparam; wparam: wparam);
begin
   mouseY := lparam>>16;  mouseX := lparam and 65535; LMB := (wParam and MK_LBUTTON) <> 0;
   RMB := (wParam and MK_RBUTTON) <> 0; SMB := (wParam and MK_MBUTTON) <> 0;
end;
function WndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam; lParam: LParam):LRESULT; stdcall;
var
   WPos: ^WindowPos;
begin
     case uMsg of
          WM_WINDOWPOSCHANGED:
                              begin
                                   WPos := pointer(lParam);
                                   WinX := WPos^.x; WinY := WPos^.y;
                                   sizeX := WPos^.cx; sizeY := WPos^.cy;
                                   result := 0;
                              end;
          WM_MOUSEMOVE: pmouse(lparam,wparam);
          WM_MBUTTONDOWN: pmouse(lparam,wparam);
          WM_MBUTTONUP: pmouse(lparam,wparam);
          WM_TIMER: isTimerTicked := true;
          WM_DESTROY:
                     begin
                          PostQuitMessage(0);
                          userRequiredQuit := true;
                     end;
          WM_CLOSE:
                     begin
                          userRequiredQuit := true;
                     end;
          WM_KEYDOWN: vkeys[dword(wparam)] := true;
          WM_KEYUP:
                   begin
                        vkeys[dword(wparam)] := false;
                        vkeypressed[dword(wparam)] := true;
                    end;
     else
         Result := DefWindowProc(ahwnd, umsg, wparam, lparam);
     end;
end;
procedure Initialize(wndname: pchar; x,y,w,h: ubMW; fov,nearclip,farclip: float);
var
   pos: TPoint;
   dupa: array[0..3] of float;
begin
    winX := X;
    winY := Y;
    sizeX := w;
    sizeY := h;
    wnd.lpfnWndProc := @WndCallback;
    wnd.hInstance := hInstance;
    wnd.lpszClassName := classname;
    wnd.hbrBackground := COLOR_WINDOW;
    RegisterClass(wnd);
    whnd := CreateWindow(classname, wndname, WS_VISIBLE or WS_TILEDWINDOW
             , x, y, w, h, 0, 0, hInstance, nil);
    hDC := GetDC(whnd);
    pfd.nSize := sizeof(pixelformatdescriptor);
    pfd.nVersion := 1;
    pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    pfd.iPixelType :=PFD_TYPE_RGBA;
    pfd.cColorBits := 16;
    pfd.cDepthBits := 16;
    pfd.iLayerType := PFD_MAIN_PLANE;
    ipfd := ChoosePixelFormat(hDC, @pfd);
    SetPixelFormat(hDC, ipfd, @pfd);

    hRC := wglCreateContext(hDC);
    wglMakeCurrent(hDC, hRC);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(fov, w/h, NearClip, FarClip);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
    GetCursorPos(pos);
    mouseX := pos.x;
    GetCursorPos(pos);
    mouseY := pos.y;

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_COLOR_MATERIAL);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    glEnable(GL_LIGHT0);
end;

end.

