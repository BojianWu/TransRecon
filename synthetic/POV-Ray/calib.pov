/**
 * @brief Pairwise Camera Calibration
 *
 *
 *                      cam2 (reference)
 *
 *                             |
 *                             |
 *                             ~
 *
 *                               /
 *                              /
 *              cam1 (--->)    /
 *                (main)      /
 *                           /
 *
 */

#version 3.7;
global_settings { max_trace_level 40 }
global_settings { assumed_gamma  1.0 }

#include "colors.inc"

#macro DEG2RAD(deg)
    #local Result deg * pi / 180.0;
    Result
#end
                         
// --------------------------------------------------
/* auxiliary parameters */
                         
#declare bkg_width  = 1920;
#declare bkg_height = 1080;                         
#declare bkg_min    = < -20.0, -20.0, -10.0 >;
#declare bkg_max    = <  20.0,  20.0, -10.0 >;

#declare bkg_min    = < bkg_min.x, bkg_min.x * (bkg_height / bkg_width), bkg_min.z >;
#declare bkg_max    = < bkg_max.x, bkg_max.x * (bkg_height / bkg_width), bkg_max.z >;

// --------------------------------------------------
/* camera 1 (main camera) */

#declare cam_1_pos      = < 0.0, 0.0, 30.0 >;
#declare cam_1_lookat   = < 0.0, 0.0,  0.0 >;
#declare cam_1_up       = < 0.0, 1.0,  0.0 >;
#declare img_1_pos      = < 0.0, 0.0, 24.0 >;

/* camera 2 (reference camera, exactly same as camera 1) */

#declare cam_2_pos      = < 0.0, 30.0,  0.0 >;
#declare cam_2_lookat   = < 0.0,  0.0,  0.0 >;
#declare cam_2_up       = < 0.0,  0.0, -1.0 >;
#declare img_2_pos      = < 0.0, 24.0,  0.0 >;

/* calibration background */

#declare calib_prj_ratio = cam_1_pos.z / (cam_1_pos.z - bkg_max.z);   // only valid for x, y
#declare calib_bkg_min   = < calib_prj_ratio * bkg_min.x, calib_prj_ratio * bkg_min.y, 0.0 >;
#declare calib_bkg_max   = < calib_prj_ratio * bkg_max.x, calib_prj_ratio * bkg_max.y, 0.0 >;

// --------------------------------------------------
/* configuration */

#declare cameraZoom         = cam_1_pos.z - img_1_pos.z;
#declare cameraImgX         = 2 * calib_bkg_max.x * (cam_1_pos.z - img_1_pos.z) / (cam_1_pos.z - calib_bkg_max.z);
#declare cameraImgY         = 2 * calib_bkg_max.y * (cam_1_pos.z - img_1_pos.z) / (cam_1_pos.z - calib_bkg_max.z);;
#declare cameraAspectRatio  = cameraImgY / cameraImgX;

/* camera 1 */

#declare cameraSkyVec_1     = cam_1_up;
#declare cameraV_1          = vnormalize(cam_1_lookat - cam_1_pos);
#declare cameraN_1          = vnormalize(vcross(cameraSkyVec_1, cameraV_1));
#declare cameraU_1          = vnormalize(vcross(cameraV_1, cameraN_1));
#declare cameraDir_1        = cameraV_1 * cameraZoom;
#declare cameraRight_1      = cameraN_1 * cameraImgX;
#declare cameraUp_1         = cameraU_1 * cameraImgY;

/* camera 2 */
#declare cameraSkyVec_2     = cam_2_up;
#declare cameraV_2          = vnormalize(cam_2_lookat - cam_2_pos);
#declare cameraN_2          = vnormalize(vcross(cameraSkyVec_2, cameraV_2));
#declare cameraU_2          = vnormalize(vcross(cameraV_2, cameraN_2));
#declare cameraDir_2        = cameraV_2 * cameraZoom;
#declare cameraRight_2      = cameraN_2 * cameraImgX;
#declare cameraUp_2         = cameraU_2 * cameraImgY;

// --------------------------------------------------
/*
 * for calibration, we should set a box that is smaller than calib_bkg, because we need to
 * rotate the box and capture images from different angle
 */

#declare calibBoxMin        = < calib_bkg_min.y * 0.75, calib_bkg_min.y * 0.75,  0.0 >;
#declare calibBoxMax        = < calib_bkg_max.y * 0.75, calib_bkg_max.y * 0.75, -0.01 >;

#declare calibBoxPos        = calibBoxMin.z;
#declare texScaleX          = calibBoxMax.x - calibBoxMin.x;
#declare texScaleY          = calibBoxMax.y - calibBoxMin.y;
#declare texScaleZ          = calibBoxMax.z - calibBoxMin.z;

#macro Display(image)
	box {
		<0,0,0>, <texScaleX, texScaleY, texScaleZ>
        pigment {
            image_map {
                png image
                map_type 0
            }
            scale <texScaleX, texScaleY, texScaleZ>
        }                                          
        finish {
            ambient 1.0
        }
        translate < -texScaleX/2, -texScaleY/2, calibBoxPos >
    }
#end

// --------------------------------------------------
/* switch between camera 1 and camera 2 */

#if (0)
    camera {
        perspective
        location cam_1_pos
        up cameraUp_1
        right -cameraRight_1
        direction cameraDir_1
    }      
#else 
    camera {
        perspective
        location cam_2_pos
        up cameraUp_2
        right -cameraRight_2
        direction cameraDir_2
    }
#end

// --------------------------------------------------

#declare idx = clock / (1.0/72.0);
object {
    Display("chessboard_small.png")
    rotate <-90, -5 * idx, 0>
}