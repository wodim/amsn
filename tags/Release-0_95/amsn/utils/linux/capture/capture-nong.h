/*
		File : webcamsn.h

		Description : Header file for the webcamsn extension for tk. A wrapper for libmimdec

		Author : Youness El Alaoui ( KaKaRoTo - kakaroto@user.sourceforge.net)

  */

#ifndef _WEBCAMSN
#define _WEBCAMSN

// Include files, must include windows.h before tk.h and tcl.h before tk.h or else compiling errors
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/time.h>

#include <linux/videodev.h>

#include <tcl.h>
#include <tk.h>

#include <tkPlatDecls.h>


// Defined as described in tcl.tk compiling extension help
#ifndef STATIC_BUILD

#if defined(_MSC_VER)
#   define EXPORT(a,b) __declspec(dllexport) a b
#   define DllEntryPoint DllMain
#else
#   if defined(__BORLANDC__)
#       define EXPORT(a,b) a _export b
#   else
#       define EXPORT(a,b) a b
#   endif
#endif
#endif


#define DLL_BUILD
#define BUILD_CAPTURE

#ifdef BUILD_CAPTURE
#  undef TCL_STORAGE_CLASS
#  define TCL_STORAGE_CLASS DLLEXPORT
#endif

#ifdef __cplusplus
extern "C"
#endif

typedef unsigned char  BYTE;

#define SETTINGS_SET 1
#define SETTINGS_GET 2

#define SETTINGS_BRIGHTNESS 4
#define SETTINGS_HUE 8
#define SETTINGS_COLOUR 16
#define SETTINGS_CONTRAST 32

#define SETTINGS_SET_BRIGHTNESS (SETTINGS_SET | SETTINGS_BRIGHTNESS)
#define SETTINGS_SET_HUE (SETTINGS_SET | SETTINGS_HUE)
#define SETTINGS_SET_COLOUR (SETTINGS_SET | SETTINGS_COLOUR)
#define SETTINGS_SET_CONTRAST (SETTINGS_SET | SETTINGS_CONTRAST)

#define SETTINGS_GET_BRIGHTNESS (SETTINGS_GET | SETTINGS_BRIGHTNESS)
#define SETTINGS_GET_HUE (SETTINGS_GET | SETTINGS_HUE)
#define SETTINGS_GET_COLOUR (SETTINGS_GET | SETTINGS_COLOUR)
#define SETTINGS_GET_CONTRAST (SETTINGS_GET | SETTINGS_CONTRAST)

#define HIGH_RES_W 320
#define HIGH_RES_H 240
#define LOW_RES_W 160
#define LOW_RES_H 120


#define CLAMP(value) (value < 0 ? 0 : value > 255 ? 255 : value)

// Structures for the list

struct capture_item {
  char captureName[32];
  char devicePath[32];
  int channel;
  int fvideo;
  int width;
  int height;
  float bpp;
  char *mmbuf; 
  struct video_mbuf       mb;
  int frame;
  int palette;
  BYTE *image_data;
  BYTE *rgb_buffer;
};


// Defines for compatibility with the list code..
#define g_list opened_devices
#define data_item capture_item
#define list_element_id captureName

EXTERN struct list_ptr* Capture_lstGetListItem(char *list_element_id);
EXTERN struct data_item* Capture_lstAddItem(struct data_item* item);
EXTERN struct data_item* Capture_lstGetItem(char *list_element_id);
EXTERN struct data_item* Capture_lstDeleteItem(char *list_element_id);

EXTERN void InitConvtTbl(void);
EXTERN void YUV2RGB(BYTE y, BYTE u, BYTE v, BYTE *r, BYTE *g, BYTE *b);
EXTERN void YUV_to_RGB24 (const BYTE *input,
			  BYTE* output_rgb,
			  int width,
			  int height,
			  int uv_odd, int uv_even, int planar);

EXTERN int GetGoodSize(int min, int max, int prefered);
EXTERN int Capture_ListDevices _ANSI_ARGS_((ClientData clientData,
					    Tcl_Interp *interp,
					    int objc,
					    Tcl_Obj *CONST objv[]));
EXTERN int Capture_ListChannels _ANSI_ARGS_((ClientData clientData,
					     Tcl_Interp *interp,
					     int objc,
					     Tcl_Obj *CONST objv[]));
EXTERN int Capture_GetGrabber _ANSI_ARGS_((ClientData clientData,
					   Tcl_Interp *interp,
					   int objc,
					   Tcl_Obj *CONST objv[]));
EXTERN int Capture_ListGrabbers _ANSI_ARGS_((ClientData clientData,
					     Tcl_Interp *interp,
					     int objc,
					     Tcl_Obj *CONST objv[]));

// External functions
EXTERN int Capture_Init _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int Capture_SafeInit _ANSI_ARGS_((Tcl_Interp *interp));


EXTERN int Capture_Open _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));

EXTERN int Capture_Close _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));

EXTERN int Capture_Grab _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));

EXTERN int Capture_AccessSettings _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));


EXTERN int Capture_IsValid _ANSI_ARGS_((ClientData clientData,
					Tcl_Interp *interp,
					int objc,
					Tcl_Obj *CONST objv[]));


# undef TCL_STORAGE_CLASS
# define TCL_STORAGE_CLASS DLLIMPORT
#endif /* _TKCXIMAGE */
