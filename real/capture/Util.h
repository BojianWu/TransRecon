#ifndef __UTIL_H__
#define __UTIL_H__

#include <iostream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <string>
#include <memory>

#include "FlyCapture2.h"
using namespace FlyCapture2;

namespace FlyCapture2Util
{
	static BusManager BusMgr;

	static void PrintBuildInfo()
	{
		FC2Version version;
		Utilities::GetLibraryVersion(&version);

		std::ostringstream oss;
		oss << "FlyCapture2 library version: "
			<< version.major << "." << version.minor << "." << version.type  << "."
			<< version.build;
		std::cout << oss.str() << std::endl;

		std::cout << "Application build data: " << __DATE__ << " " << __TIME__;
		std::cout << std::endl;
	}

	static void PrintCameraInfo(CameraInfo *pCamInfo)
	{
		std::cout << std::endl;
		std::cout << "*** CAMERA INFORMATION ***" << std::endl;
		std::cout << "Serial number - "           << pCamInfo->serialNumber      << std::endl;
		std::cout << "Camera model - "            << pCamInfo->modelName         << std::endl;
		std::cout << "Camera vendor - "           << pCamInfo->vendorName        << std::endl;
		std::cout << "Sensor - "                  << pCamInfo->sensorInfo        << std::endl;
		std::cout << "Resolution - "              << pCamInfo->sensorResolution  << std::endl;
		std::cout << "Firmware version - "        << pCamInfo->firmwareVersion   << std::endl;
		std::cout << "Firmware build time - "     << pCamInfo->firmwareBuildTime << std::endl;
	}

	static void PrintErrorInfo(const Error &error)
	{
		error.PrintErrorTrace();
	}
}

namespace Params
{
	static const int RotationAngle = 45;
	static const std::string BkgPatternPath = "background";
	static const std::string SaveImagesPath = "please-set-this-path-manually";

	static const std::string RotationCmd = "path-to-rotation.exe " + std::to_string(RotationAngle);

	static std::string GetFilename(const std::string &absFilename, const char delim = '/')
	{
		std::vector<std::string> items;
		std::stringstream ss(absFilename);
		std::string item;
		while (std::getline(ss, item, delim)) {
			if (!item.empty())
				items.push_back(item);
		}
		return items.back();
	}
}

#endif // __UTIL_H__