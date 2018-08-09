#ifndef __IMAGE_CAPTURE_H__
#define __IMAGE_CAPTURE_H__

#include "Util.h"

class ImageCapture
{
public:

	ImageCapture(const int cameraID = 0, bool mono = true);
	~ImageCapture();

	void Record(const std::string &filename);
	void Stop();

private:

	void InitCamera();

private:

	Error _error;
	bool _mono;
	int _cameraID;
	std::unique_ptr<Camera> _camera;
};

#endif // __IMAGE_CAPTURE_H__