#include <iostream>

#define NEWDLL

#ifdef NEWDLL
#using "MCC4DLL.dll"
#else
#using "MCCDLL.dll"
#endif

using namespace SerialPortLibrary;

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

public ref class Globals abstract sealed {
public:
    static SerialPortLibrary::SPLibClass Mccard;
};

int main(int argc, char **argv)
{
	if (argc != 2)
		return -1;

	// Control
	{
		float deg = atof(argv[1]);

		int res = -1;
		res = Globals::Mccard.MoCtrCard_Initial("COM1");

		// Clear
		res = Globals::Mccard.MoCtrCard_ResetCoordinate(0, 0);

		// Get run state
		array<int, 1> ^state = gcnew array<int, 1>(1);
		res = Globals::Mccard.MoCtrCard_GetRunState(state);

		// Set parameters
		res = Globals::Mccard.MoCtrCard_SendPara(0, 0, deg * 2);
		res = Globals::Mccard.MoCtrCard_SendPara(0, 2, 20.0);
		res = Globals::Mccard.MoCtrCard_SendPara(0, 3, 0.5);
		res = Globals::Mccard.MoCtrCard_MCrlAxisMove(0, 0);

		// Unload
		res = Globals::Mccard.MoCtrCard_Unload();
	}

    return 0;
}