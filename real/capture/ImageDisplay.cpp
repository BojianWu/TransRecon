#include "ImageDisplay.h"

#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"

void ImageDisplay::Show(const std::string &filename, ImageDisplayType type /* = ImageDisplayType::FULL_SCREEN */)
{
	if (filename.empty())
		return;

	cv::Mat img = cv::imread(filename, CV_LOAD_IMAGE_COLOR);

	cv::namedWindow("Capture", CV_WINDOW_NORMAL);
	cv::setWindowProperty("Capture", CV_WND_PROP_FULLSCREEN, CV_WINDOW_FULLSCREEN);
	cv::imshow("Capture", img);
	cv::waitKey(5000);
}