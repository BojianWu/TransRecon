#ifndef __IMAGE_DISPLAY_H__
#define __IMAGE_DISPLAY_H__

#include <string>

enum ImageDisplayType { AUTO_FIT, FULL_SCREEN };
class ImageDisplay
{
public:

	static void Show(const std::string &filename, ImageDisplayType type = ImageDisplayType::FULL_SCREEN);
};

#endif // __IMAGE_DISPLAY_H__