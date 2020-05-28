
// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the PROXR_RELAYS_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// PROXR_RELAYS_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.

#ifdef PROXR_RELAYS_EXPORTS
#define PROXR_RELAYS_API __declspec(dllexport)
#else
#define PROXR_RELAYS_API __declspec(dllimport)
#endif

/*
// This class is exported from the proXR_relays.dll
class PROXR_RELAYS_API CProXR_relays {
public:
	CProXR_relays(void);
	// TODO: add your methods here.
};
*/

#ifdef CPLUSPLUS
	extern "C" {
#endif // CPLUSPLUS
PROXR_RELAYS_API int readSerial(int NumChars,unsigned char* buf);
PROXR_RELAYS_API int writeSerial(unsigned int NumChars,unsigned char* buf);

PROXR_RELAYS_API int switchToISI(int lr);
PROXR_RELAYS_API int switchToStim(int lr,int stim);
PROXR_RELAYS_API void allRelaysClear();

PROXR_RELAYS_API int allRelaysOff();

// extern PROXR_RELAYS_API int nProXR_relays;

// extern PROXR_RELAYS_API int fnProXR_relays(void);

extern PROXR_RELAYS_API void relayInit(int serialPort,int has4Banks);

extern PROXR_RELAYS_API void relayClose();

extern PROXR_RELAYS_API int relaySet(int relay);

extern PROXR_RELAYS_API int relayClear(int relay);

extern PROXR_RELAYS_API int commit();

// extern PROXR_RELAYS_API int relayToggle(int relay1, int relay2);

#ifdef CPLUSPLUS
	}
#endif // CPLUSPLUS

