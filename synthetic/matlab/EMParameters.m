%% EMParameters
% All these parameters and settings are strictly consistent with POV-Ray.
% If not necessary, please do not touch these settings.
%% camera parameters
bkg_width  = 1920;
bkg_height = 1080;

cam_pos    = [   0.0,   0.0,  30.0];
cam_lookat = [   0.0,   0.0,   0.0];
cam_up     = [   0.0,   1.0,   0.0];

img_pos      = [   0.0,   0.0,  24.0];
bkg_min_init = [ -20.0, -20.0, -10.0];
bkg_max_init = [  20.0,  20.0, -10.0];

bkg_min = [bkg_min_init(1), bkg_min_init(1) * bkg_height / bkg_width, bkg_min_init(3)];
bkg_max = [bkg_max_init(1), bkg_max_init(1) * bkg_height / bkg_width, bkg_max_init(3)];

img_bkg_ratio = (cam_pos(3) - img_pos(3)) / (cam_pos(3) - bkg_max(3));
img_min = [bkg_min(1) * img_bkg_ratio, bkg_min(2) * img_bkg_ratio, img_pos(3)];
img_max = [bkg_max(1) * img_bkg_ratio, bkg_max(2) * img_bkg_ratio, img_pos(3)];

%% ray/ray correspondence
plane_z_mov = 2;

plane_1_min = bkg_min;
plane_1_max = bkg_max;

plane_2_min = plane_1_min + [0, 0, plane_z_mov];
plane_2_max = plane_1_max + [0, 0, plane_z_mov];

%% auxiliary
camPos = cam_pos;

imgLUCorner = [ img_min(1), img_max(2), img_max(3) ];
imgXDir     = [ img_max(1) - img_min(1), 0, 0 ];
imgYDir     = [ 0, img_min(2) - img_max(2), 0 ];

plane1LUCorner = [ plane_1_min(1), plane_1_max(2), plane_1_max(3)];
plane2LUCorner = [ plane_2_min(1), plane_2_max(2), plane_2_max(3) ];
planeXDir      = [ plane_1_max(1) - plane_1_min(1), 0, 0 ];
planeYDir      = [ 0, plane_1_min(2) - plane_1_max(2), 0 ];
planeX         = plane_1_max(1) - plane_1_min(1);
planeY         = plane_1_max(2) - plane_1_min(2);