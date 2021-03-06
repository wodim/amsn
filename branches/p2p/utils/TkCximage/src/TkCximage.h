/*
 * TkCximage Tk extension providing bindings to the CxImage library.
 *
 *    @author : The aMSN Team
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

#ifndef _TKCXIMAGE
#define _TKCXIMAGE

#include <list>
#include <vector>

// Include files, must include windows.h before tk.h and tcl.h before tk.h or else compiling errors
// So we will include ximage.h before everything else
#include <ximage.h>

#include <tcl.h>
#include <tk.h>


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
#define BUILD_CXIMAGE

#ifdef BUILD_CXIMAGE
#  undef TCL_STORAGE_CLASS
#  define TCL_STORAGE_CLASS DLLEXPORT
#endif

#ifdef __cplusplus
extern "C"
#endif



#define ENABLE_LOGS 0
#define ANIMATE_GIFS 1
#ifndef SMART_RESIZE
	#define SMART_RESIZE 1
#endif




EXTERN char currenttime[30];
EXTERN FILE * logfile;


#if ENABLE_LOGS == 1
#ifndef WINVER
#define LOGS_ENABLED
#include <time.h>

inline void timestamp() {
  time_t t;
  time(&t);
  strftime(currenttime, 29, "[%D %T]", localtime(&t));
};

#endif
#endif

#define LOGPATH "/tmp/TkCximage.log"

inline void LOG (const char * s) {
#ifdef LOGS_ENABLED
  if (logfile) {
    timestamp();
    fprintf(logfile,"\n%s  %s", currenttime, s);
    fflush(logfile);
  }
#endif
}
inline void LOG (const int i) {
#ifdef LOGS_ENABLED
  if (logfile) {
    timestamp();
    fprintf(logfile,"\n%s  %d", currenttime, i);
    fflush(logfile);
  }
#endif
}

inline void APPENDLOG (const char * s) {
#ifdef LOGS_ENABLED
  if (logfile) {
    fprintf(logfile," %s", s);
    fflush(logfile);
  }
#endif
}
inline void APPENDLOG (const int i) {
#ifdef LOGS_ENABLED
  if (logfile) {
    fprintf(logfile," %d", i);
    fflush(logfile);
  }
#endif
}

inline void APPENDLOG (const void * i) {
#ifdef LOGS_ENABLED
  if (logfile) {
    fprintf(logfile," %X", i);
    fflush(logfile);
  }
#endif
}


inline void INITLOGS () {
#ifdef LOGS_ENABLED
logfile = fopen(LOGPATH, "a");
#endif
}


#if ANIMATE_GIFS

typedef std::vector< CxMemFile *> GifBuffersArray;
typedef GifBuffersArray::iterator GifBuffersIterator;

typedef struct gif_info {
	CxImage * image;
	Tcl_Interp * interp;
	Tk_PhotoHandle Handle;
	Tk_ImageMaster ImageMaster;
	unsigned int NumFrames;
	unsigned int CurrentFrame;
	int CopiedFrame;
	bool Enabled;
	Tcl_TimerToken timerToken;
	GifBuffersArray buffers;
} GifInfo ;

EXTERN void AnimateGif(ClientData data);
EXTERN int AnimatedGifFrameToTk(Tcl_Interp *interp, GifInfo *Info, CxImage *frame, int blank);
EXTERN void PhotoDisplayProcHook(ClientData instanceData,Display *display,Drawable drawable,int imageX,int imageY,int width,int height,int drawableX,int drawableY);
EXTERN Tk_ImageDisplayProc *PhotoDisplayOriginal;

// Defines for compatibility with the list code..
#define g_list animated_gifs
#define data_item gif_info
#define list_element_type Tk_PhotoHandle
#define list_element_id Handle

typedef std::list< struct data_item * > ChainedList;
typedef ChainedList::iterator ChainedIterator;

//Get the iterator with the specified id
ChainedIterator TkCxImage_lstGetListItem(list_element_type list_element_id);
//Add the specified item if its id not already exists
struct data_item* TkCxImage_lstAddItem(struct data_item* item);
//Get the item with the specified id
struct data_item* TkCxImage_lstGetItem(list_element_type list_element_id);
//Delete the item with the specified id if exists
struct data_item* TkCxImage_lstDeleteItem(list_element_type list_element_id);

#endif // ANIMATE_GIFS




EXTERN int ChanMatch (Tcl_Channel chan, CONST char *fileName, Tcl_Obj *format,int *widthPtr,
					  int *heightPtr,Tcl_Interp *interp);
EXTERN int ObjMatch (Tcl_Obj *data, Tcl_Obj *format, int *widthPtr, int *heightPtr, Tcl_Interp *interp);
EXTERN int ChanRead (Tcl_Interp *interp, Tcl_Channel chan, CONST char *fileName, Tcl_Obj *format, Tk_PhotoHandle imageHandle,
					 int destX, int destY, int width, int height, int srcX, int srcY);
EXTERN int ObjRead (Tcl_Interp *interp, Tcl_Obj *data, Tcl_Obj *format, Tk_PhotoHandle imageHandle,
					int destX, int destY, int width, int height, int srcX, int srcY);
EXTERN int ChanWrite (Tcl_Interp *interp, CONST char *fileName, Tcl_Obj *format, Tk_PhotoImageBlock *blockPtr);
EXTERN int StringWrite (Tcl_Interp *interp, Tcl_Obj *format, Tk_PhotoImageBlock *blockPtr);
EXTERN int DataWrite (Tcl_Interp *interp, int Type, Tk_PhotoImageBlock *blockPtr);
EXTERN int GetFileTypeFromFileName(char * Filename);
EXTERN int GetFileTypeFromFormat(char * Format);
EXTERN int RGB2BGR(Tk_PhotoImageBlock *data, BYTE * pixelPtr);

EXTERN int LoadFromFile(Tcl_Interp *interp, CxImage * image, char * fileName, int Type);
EXTERN int SaveToFile(Tcl_Interp *interp, CxImage * image, char * fileName, int Type);

// External functions
EXTERN int Tkcximage_Init _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int Tkcximage_SafeInit _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int Tkcximage_Unload _ANSI_ARGS_((Tcl_Interp *interp, int flags));
EXTERN int Tkcximage_SafeUnload _ANSI_ARGS_((Tcl_Interp *interp, int flags));

EXTERN int Tk_Convert _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));
EXTERN int Tk_Resize _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));
EXTERN int Tk_Thumbnail _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));
EXTERN int Tk_Colorize _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));
EXTERN int Tk_IsAnimated _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));

EXTERN int Tk_EnableAnimation _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));

EXTERN int Tk_DisableAnimation _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));
EXTERN int Tk_JumpToFrame _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));

EXTERN int Tk_NumberOfFrames _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]));

EXTERN int CopyImageToTk(Tcl_Interp * inter, CxImage *image, Tk_PhotoHandle Photo, int width, int height, int black = true);


# undef TCL_STORAGE_CLASS
# define TCL_STORAGE_CLASS DLLIMPORT
#endif /* _TKCXIMAGE */
