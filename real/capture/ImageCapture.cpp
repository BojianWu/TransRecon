#include "ImageCapture.h"

ImageCapture::ImageCapture(const int cameraID /* = 0 */, bool mono /* = true */)
	: _cameraID(cameraID), _mono(mono)
{
	InitCamera();
}

ImageCapture::~ImageCapture()
{

}

void ImageCapture::Record(const std::string &filename)
{
	Image rawImage;
	_error = _camera->RetrieveBuffer(&rawImage);
	if (_error != PGRERROR_OK) {
		std::cout << "Error grabbing image" << std::endl;
		return;
	}
	else {
		if (_mono) {
			Image grayImage;
			rawImage.Convert(PIXEL_FORMAT_MONO8, &grayImage);
			grayImage.Save(filename.c_str());
		}
		else
			rawImage.Save(filename.c_str());
		std::cout << "Save Image: " << filename << std::endl;
	}
}

void ImageCapture::Stop()
{
	std::cout << "Camera #" << _cameraID << ", Stop Capturing" << std::endl;
	if (_camera->IsConnected()) {
		_error = _camera->StopCapture();
		if (_error != PGRERROR_OK) {
			FlyCapture2Util::PrintErrorInfo(_error);
			return;
		}
		_camera->Disconnect();
	}
}

void ImageCapture::InitCamera()
{
	PGRGuid guid;
	_error = FlyCapture2Util::BusMgr.GetCameraFromIndex(_cameraID, &guid);
	if (_error != PGRERROR_OK) {
		FlyCapture2Util::PrintErrorInfo(_error);
		return;
	}

	std::cout << "Running Camera #" << _cameraID << std::endl;

	// connect to the camera
	_camera.reset(new Camera());
	_error = _camera->Connect(&guid);
	if (_error != PGRERROR_OK) {
		FlyCapture2Util::PrintErrorInfo(_error);
		return;
	}

	// settings and properties
	{
		/* settings */
		FC2Config config;
		_camera->GetConfiguration(&config);
		config.grabMode = DROP_FRAMES;
		config.numBuffers = 64;
		_camera->SetConfiguration(&config);

#if 0
		/* saturation */
		if (_mono) {
			Property sat_property(PropertyType::SATURATION);
			_camera->GetProperty(&sat_property);
			if (sat_property.present) {
				sat_property.autoManualMode = false;     // manually
				sat_property.absValue = 0.0;             // mono
				_error = _camera->SetProperty(&sat_property);
				if (_error != PGRERROR_OK) {
					FlyCapture2Util::PrintErrorInfo(_error);
					return;
				}
			}
		}
#endif

#if 1
		/* gain property */
		Property gain_property(PropertyType::GAIN);
		_camera->GetProperty(&gain_property);
		if (gain_property.present) {
			gain_property.autoManualMode = false;    // manually
			_error = _camera->SetProperty(&gain_property);
			if (_error != PGRERROR_OK) {
				FlyCapture2Util::PrintErrorInfo(_error);
				return;
			}
		}

		/* shutter property */
		Property shutter_property(PropertyType::SHUTTER);
		_camera->GetProperty(&shutter_property);
		if (shutter_property.present) {
			shutter_property.autoManualMode = false; // manually
			_error = _camera->SetProperty(&shutter_property);
			if (_error != PGRERROR_OK) {
				FlyCapture2Util::PrintErrorInfo(_error);
				return;
			}
		}

		/* white-balance property */
		Property wb_property(PropertyType::WHITE_BALANCE);
		_camera->GetProperty(&wb_property);
		if (wb_property.present) {
			wb_property.autoManualMode = false;      // manually
			_error = _camera->SetProperty(&wb_property);
			if (_error != PGRERROR_OK) {
				FlyCapture2Util::PrintErrorInfo(_error);
				return;
			}
		}
#endif
	}

	// get the camera information
	CameraInfo cameraInfo;
	_error = _camera->GetCameraInfo(&cameraInfo);
	if (_error != PGRERROR_OK) {
		FlyCapture2Util::PrintErrorInfo(_error);
		return;
	}
	FlyCapture2Util::PrintCameraInfo(&cameraInfo);

	// start capturing images
	std::cout << "Camera #" << _cameraID << ", Start Capturing" << std::endl;
	_error = _camera->StartCapture();
	if (_error != PGRERROR_OK) {
		FlyCapture2Util::PrintErrorInfo(_error);
		return;
	}
}