#version 3.7;
global_settings { max_trace_level 40 }
global_settings { assumed_gamma  1.0 }

#include "colors.inc"
#include "kitten.inc"

#macro DEG2RAD(deg)
    #local Result deg * pi / 180.0;
    Result
#end

// --------------------------------------------------
// parameters                                   

#declare bkg_width  = 1920;
#declare bkg_height = 1080;

#declare cam_pos    = <   0.0,    0.0,   30.0 >;
#declare cam_lookat = <   0.0,    0.0,    0.0 >;
#declare cam_up     = <   0.0,    1.0,    0.0 >;
#declare img_pos    = <   0.0,    0.0,   24.0 >;
#declare bkg_min    = < -20.0 , -20.0 , -10.0 >;
#declare bkg_max    = <  20.0 ,  20.0 , -10.0 >;
                                     
#declare bkg_min    = <bkg_min.x, bkg_min.x * (bkg_height / bkg_width), bkg_min.z>;
#declare bkg_max    = <bkg_max.x, bkg_max.x * (bkg_height / bkg_width), bkg_max.z>;

#if (bkg_min.z != bkg_max.z)
    #error "Error: background min/max should in same depth"
#end

// --------------------------------------------------
// camera settings

#declare cameraPos          = cam_pos;
#declare cameraZoom         = cam_pos.z - img_pos.z;
#declare cameraImgX         = 2 * bkg_max.x * (cam_pos.z - img_pos.z) / (cam_pos.z - bkg_max.z);
#declare cameraImgY         = 2 * bkg_max.y * (cam_pos.z - img_pos.z) / (cam_pos.z - bkg_max.z);

#declare cameraAspectRatio  = cameraImgY / cameraImgX;
#declare cameraLookAt       = cam_lookat;
#declare cameraSkyVec       = cam_up;
#declare cameraV            = vnormalize(cameraLookAt - cameraPos);
#declare cameraN            = vnormalize(vcross(cameraSkyVec, cameraV));
#declare cameraU            = vnormalize(vcross(cameraV, cameraN));

#declare cameraDir          = cameraV * cameraZoom;
#declare cameraRight        = cameraN * cameraImgX;
#declare cameraUp           = cameraU * cameraImgY;

// --------------------------------------------------
// background settings

#declare bkgBoxMin          = bkg_min;
#declare bkgBoxMax          = bkg_max - <0, 0, 0.1>;

#declare bkgPos             = bkgBoxMin.z;
#declare texScaleX          = bkgBoxMax.x - bkgBoxMin.x;
#declare texScaleY          = bkgBoxMax.y - bkgBoxMin.y;
#declare texScaleZ          = bkgBoxMax.z - bkgBoxMin.z;

#declare texScaleX = texScaleX;
#declare texScaleY = texScaleY;
#declare texScaleZ = texScaleZ;

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
        translate <-texScaleX/2, -texScaleY/2, bkgPos>
    }
#end

// --------------------------------------------------

camera {
    perspective
    location cameraPos
    up cameraUp
    right -cameraRight
    direction cameraDir
}

// --------------------------------------------------

#declare idx = clock / (1.0/22.0) + 1;
object {
    Display(concat("ref_alpha/alpha_", str(idx,-2,0), ".png"))
}                              


object {
    kitten
    pigment {
        color White filter 1.0
    }
	finish {
		ambient 0.0
		diffuse 0.0
		specular 0.0
		reflection {0.0}
	}
    interior {
        ior 1.15
    }
    //rotate <0, -45, 0>
}