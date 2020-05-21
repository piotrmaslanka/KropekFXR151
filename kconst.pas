unit KConst;

{$mode objfpc}{$H+}

interface

uses
    KTypes;

const
     INFINITY = float(10E+10);
     INFINITESMAL = 0.000000001;
     PI = 3.141592;

     KFILEREADER_SCALE = 1;


     KINIT_ENABLE = 1;
     KINIT_DISABLE = 2;

     KINIT_FILLMODE = 1;                { wireframe if disabled }
     KINIT_LIGHT = 2;
     KINIT_CULLING = 3;
     KINIT_ZBUFFER = 4;
     KINIT_COLOR_MODELS = 5;

     KINIT_CLEARBUFFER = 0;

     KPERFMGR_ANTIALIASING_NONE = 0;
     KPERFMGR_ANTIALIASING_LOW = 1;
     KPERFMGR_ANTIALIASING_HIGH = 2;

     KCOLLIDABLE_CYLINDER = 0;
     KCOLLIDABLE_TRIMESH = 1;

     KGETVAL_RC = 0;
     KGETVAL_DC = 1;
     KGETVAL_HWND = 2;
     KGETVAL_HINST = 3;

     KMOUSEMODE_FREE = 0;
     KMOUSEMODE_DELTA = 1;

     AXIS_X: r3dp = (x:1;y:0;z:0);
     AXIS_Y: r3dp = (x:0;y:1;z:0);
     AXIS_Z: r3dp = (x:0;y:0;z:1);


implementation

end.

