/*	
		File : tcl_farsight.h

		Description : Header file for the tcl_farsight extension for tcl.

		Author : Youness El Alaoui ( KaKaRoTo - kakaroto@user.sourceforge.net)

  */

#ifndef _TCL_FARSIGHT
#define _TCL_FARSIGHT

// Include files, must include windows.h before tk.h and tcl.h before tk.h or else compiling errors
#include <stdlib.h>


#ifdef WIN32
#include <windows.h>
#endif


#include <tcl.h>


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
#define BUILD_TCL_SIREN

#ifdef BUILD_TCL_SIREN
#  undef TCL_STORAGE_CLASS
#  define TCL_STORAGE_CLASS DLLEXPORT
#endif

#ifdef __cplusplus
extern "C"
#endif

// External functions
EXTERN int Tcl_farsight_Init _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int Tcl_farsight_SafeInit _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int Farsight_Init _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int Farsight_SafeInit _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN int Farsight_Prepare _ANSI_ARGS_((ClientData clientData,
        Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
EXTERN int Farsight_Start _ANSI_ARGS_((ClientData clientData,
        Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
EXTERN int Farsight_InUse _ANSI_ARGS_((ClientData clientData,
        Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
EXTERN int Farsight_Stop _ANSI_ARGS_((ClientData clientData,
        Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));


# undef TCL_STORAGE_CLASS
# define TCL_STORAGE_CLASS DLLIMPORT
#endif /* _TCL_FARSIGHT */
