#include <string>
#include <iostream>
#include <stdlib.h>

#include "Util.h"
#include "Directory.h"
#include "ImageCapture.h"
#include "ImageDisplay.h"

#include "boost/format.hpp"
#include "boost/filesystem.hpp"
namespace fs = boost::filesystem;

int main(int argc, char **argv)
{
	FlyCapture2Util::PrintBuildInfo();

	unsigned int numCameras;
	FlyCapture2Util::BusMgr.GetNumOfCameras(&numCameras);

	if (numCameras != 2) {
		std::cout << "Connection with cameras fails" << std::endl;
		return -1;
	}

	std::unique_ptr<ImageCapture> captureT(new ImageCapture(0, true));
	std::unique_ptr<ImageCapture> captureF(new ImageCapture(1, true));

	std::string calibPath = Params::SaveImagesPath + "/calib/pairwise";
	fs::create_directories(calibPath);

	std::string objAlphaPath = Params::SaveImagesPath + "/obj_alpha";
	fs::create_directories(objAlphaPath);

	std::string objGrayPath  = Params::SaveImagesPath + "/obj_gray";
	fs::create_directories(objGrayPath);

	int RotationCount = static_cast<int>(360 / Params::RotationAngle);
	for (int i = 0; i < RotationCount; ++i) {
		if (i != 0) {
			system(Params::RotationCmd.c_str());
			_sleep(5000);    // 5 seconds
		}

		// pairwise calibration
		std::string calibImgName = calibPath + "/pairwise_calib_" + std::to_string(i+1) + ".png";
		captureT->Record(calibImgName);

		// alphamatte
		std::string objAlphaSubPath = objAlphaPath + "/obj_alpha_" + std::to_string(i+1);
		fs::create_directory(objAlphaSubPath);

		std::vector<std::string> refAlphaNames = Directory::GetListFiles(
			Params::BkgPatternPath + "/ref_alpha", "*.png"
		);
		for (unsigned int i = 0; i < refAlphaNames.size(); ++i) {
			ImageDisplay::Show(refAlphaNames[i], ImageDisplayType::FULL_SCREEN);
			std::string filename = Params::GetFilename(refAlphaNames[i]);
			captureF->Record(objAlphaSubPath + "/" + filename);
		}

		// Gray code
		std::string objGraySubPath = objGrayPath + "/obj_gray_" + std::to_string(i+1);
		fs::create_directory(objGraySubPath);

		std::vector<std::string> refGrayNames = Directory::GetListFiles(
			Params::BkgPatternPath + "/ref_gray", "*.png"
		);
		for (unsigned int i = 0; i < refGrayNames.size(); ++i) {
			ImageDisplay::Show(refGrayNames[i], ImageDisplayType::FULL_SCREEN);
			std::string filename = Params::GetFilename(refGrayNames[i]);
			captureF->Record(objGraySubPath + "/" + filename);
		}
	}

	captureF->Stop();
	captureT->Stop();

	return 0;
}