/*
 * hello.c -- A minimal Tcl C extension.
 */
#include <tcl.h>
#include <stdlib.h>
#include <string.h>


#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#include <wspiapi.h>
#define inet_ntop inet_ntop_win32
#else
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#endif


#ifdef _WIN32
static const char *inet_ntop_win32(int af, const void *src, char *dst, socklen_t cnt)
{
        if (af == AF_INET) {
                struct sockaddr_in in;
                memset(&in, 0, sizeof(in));
                in.sin_family = AF_INET;
                memcpy(&in.sin_addr, src, sizeof(struct in_addr));
                getnameinfo((struct sockaddr *)&in, sizeof(struct sockaddr_in), dst, cnt, NULL, 0, NI_NUMERICHOST);
                return dst;
        }
        return NULL;
}

#endif



#ifdef _WIN32
static unsigned __stdcall
#else
static void
#endif
Resolver_Thread _ANSI_ARGS_((ClientData cdata));
static int Resolver_EventProc (Tcl_Event *evPtr, int flags);

typedef struct {
  char *host;
  char *ip;
  Tcl_Interp *callback_interp;
  Tcl_Obj *callback;
  Tcl_ThreadId main_tid;
} ResolverData;


typedef struct {
  Tcl_Event header;
  ResolverData *data;
} ResolverEvent;


static void
notify_callback(char *ip, Tcl_Interp *callback_interp, Tcl_Obj *callback)
{
  Tcl_Obj *ip_obj = Tcl_NewStringObj (ip, -1);
  Tcl_Obj *eval = Tcl_NewStringObj ("eval", -1);
  Tcl_Obj *command[] = {eval, callback, ip_obj};

  if (callback && callback_interp) {
    Tcl_IncrRefCount (eval);
    Tcl_IncrRefCount (ip_obj);

    if (Tcl_EvalObjv(callback_interp, 3,
		     command, TCL_EVAL_GLOBAL) == TCL_ERROR) {
      Tcl_BackgroundError(callback_interp);
    }
    Tcl_DecrRefCount (ip_obj);
    Tcl_DecrRefCount (eval);
  }
}

static int
Asyncresolve_Cmd(ClientData cdata,
		 Tcl_Interp *interp,
		 int objc,
		 Tcl_Obj * CONST objv[])
{
  ResolverData *data = NULL;
  Tcl_ThreadId tid;

  if (objc != 3) {
    Tcl_WrongNumArgs (interp, 1, objv, "callback host");
    return TCL_ERROR;
  }

  data = (ResolverData *) ckalloc(sizeof(ResolverData));
  data->callback = objv[1];
  Tcl_IncrRefCount (data->callback);
  data->callback_interp = interp;
  data->main_tid = Tcl_GetCurrentThread();
  data->host = strdup(Tcl_GetString(objv[2]));
  data->ip = strdup("");
  if (Tcl_CreateThread(&tid, Resolver_Thread, data,
		       TCL_THREAD_STACK_DEFAULT, TCL_THREAD_NOFLAGS) != TCL_OK) {

    notify_callback(data->host, data->callback_interp, data->callback);
    
    free(data->ip);
    free(data->host);
    Tcl_DecrRefCount (data->callback);

    ckfree(data);
  }

  return TCL_OK;
}

#ifdef _WIN32
static unsigned __stdcall 
#else
static void
#endif
Resolver_Thread _ANSI_ARGS_((ClientData cdata))
{

  ResolverData *data = (ResolverData*) cdata;
  ResolverEvent *evPtr;
  struct addrinfo * result;
  char * ret;
  char ip[30];
  int error;

  error = getaddrinfo(data->host, NULL, NULL, &result);
  if (error == 0 && result != NULL) {
    ret = inet_ntop (AF_INET,
		     &((struct sockaddr_in *) result->ai_addr)->sin_addr,
		     ip, INET_ADDRSTRLEN);
    if (ret != NULL) {
      free(data->ip);
      data->ip = strdup(ip);
    }
    freeaddrinfo(result);
  }

  evPtr = (ResolverEvent *)ckalloc(sizeof(ResolverEvent));
  evPtr->header.proc = Resolver_EventProc;
  evPtr->header.nextPtr = NULL;
  evPtr->data = data;

  Tcl_ThreadQueueEvent(data->main_tid, (Tcl_Event *)evPtr, TCL_QUEUE_TAIL);
  Tcl_ThreadAlert(data->main_tid);
}

static int Resolver_EventProc (Tcl_Event *evPtr, int flags)
{
  ResolverEvent *ev = (ResolverEvent*) evPtr;
  ResolverData *data = (ResolverData*) ev->data;

  notify_callback(data->ip, data->callback_interp, data->callback);

  free(data->ip);
  free(data->host);
  Tcl_DecrRefCount (data->callback);

  ckfree(data);

  return 1;
}


static int
Sockname_Cmd(ClientData cdata,
		 Tcl_Interp *interp,
		 int objc,
		 Tcl_Obj * CONST objv[])
{
#ifdef _WIN32
    SOCKET sock;
    SOCKADDR_IN sockname;
    LPSOCKADDR pSockname = (LPSOCKADDR) &sockname;
    int size = sizeof(SOCKADDR_IN);
#else
    int sock;
    struct sockaddr_in sockname;
    struct sockaddr * pSockname = (struct sockaddr *) &sockname;
    socklen_t size = sizeof(struct sockaddr_in);
#endif

    Tcl_Channel *channel = NULL;
    char *channelName = NULL;
    int mode;

    if (objc != 2) {
      Tcl_WrongNumArgs (interp, 1, objv, "socket");
      return TCL_ERROR;
    }

    channelName = Tcl_GetString (objv[1]);

    channel = Tcl_GetChannel (interp, channelName, &mode);

    if (channel == NULL) {
      return TCL_ERROR;
    }
    if (Tcl_GetChannelHandle (channel, mode, &sock) == TCL_OK) {
	if (getsockname(sock, pSockname, &size) >= 0) {
          Tcl_Obj *result = NULL;
          Tcl_Obj *ip = NULL;
          Tcl_Obj *port = NULL;

          result = Tcl_NewListObj (0, NULL);
          ip = Tcl_NewStringObj (inet_ntoa(sockname.sin_addr), -1);
          Tcl_ListObjAppendElement(interp, result, ip);

          port = Tcl_NewIntObj (ntohs(sockname.sin_port));
          Tcl_ListObjAppendElement(interp, result, port);

          Tcl_SetObjResult (interp, result);

          return TCL_OK;
	} else {
          Tcl_AppendResult(interp, "can't get sockname: ", Tcl_PosixError(interp), NULL);
          return TCL_ERROR;
	}
    } else {
      Tcl_AppendResult (interp, "Could not get channel handle", (char *) NULL);
      return TCL_ERROR;
    }

    return TCL_OK;
}


int DLLEXPORT
Asyncresolver_Init(Tcl_Interp *interp)
{
    if (Tcl_InitStubs(interp, "8.4", 0) == NULL) {
 	return TCL_ERROR;
    }
    /* changed this to check for an error - GPS */
    if (Tcl_PkgProvide(interp, "asyncresolver", "0.1") == TCL_ERROR) {
	return TCL_ERROR;
    }
    Tcl_CreateObjCommand(interp, "::asyncresolver::asyncresolve", Asyncresolve_Cmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "::asyncresolver::sockname", Sockname_Cmd, NULL, NULL);
    return TCL_OK;
 }
