/*
  File : aio.c

  Description :	Contains all functions for accessing the libao/libai library

  Author : Youness El Alaoui (KaKaRoTo - kakaroto@users.sourceforge.net)
*/


// Include the header file
#include "aio.h"

int device_counter = 0;
Tcl_HashTable  *devices = NULL;

int Aio_Open  _ANSI_ARGS_((ClientData clientData,
			   Tcl_Interp *interp,
			   int objc,
			   Tcl_Obj *CONST objv[])) 
{

	int driver;
	ao_device *device = NULL;
	ao_sample_format format;
	char name[15];
	char * req_name = NULL;
	static char device_prefix[] = "device";
	Tcl_HashEntry *hPtr = NULL;
	int newHash;

	// We verify the arguments
	if( objc > 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "?name?");
		return TCL_ERROR;
	}

	if ( objc == 2) {
	  // Set the requested name and see if it exists...
	  req_name = Tcl_GetStringFromObj(objv[2], NULL);
	  if (Tcl_FindHashEntry(devices, req_name) == NULL) {
	    strcpy(name, req_name);
	  }else {
	    sprintf(name, "%s%d", device_prefix, ++device_counter);
	  }
	} else {
	  sprintf(name, "%s%d", device_prefix, ++device_counter);
	}

	driver = ao_driver_id("alsa09");
	//driver = ao_default_driver_id();

	format.bits = 16;
	format.channels = 1;
	format.rate = 16000;
	format.byte_format = AO_FMT_LITTLE;
	
	/* -- Open driver -- */
	device = ao_open_live(driver, &format, NULL /* no options */);

	if (device == NULL) {
	  driver = ao_driver_id("oss");
	  device = ao_open_live(driver, &format, NULL /* no options */);
	  if (device == NULL) {
	    Tcl_AppendResult(interp, "Unable to open device", NULL);	    
	    return TCL_ERROR;
	  }
	  
	}

	hPtr = Tcl_CreateHashEntry(devices, name, &newHash);
	Tcl_SetHashValue(hPtr, (ClientData) device);

	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, name, NULL);

	return TCL_OK;
	
}


int Aio_Play _ANSI_ARGS_((ClientData clientData,
			  Tcl_Interp *interp,
			  int objc,
			  Tcl_Obj *CONST objv[])) 
{
	char * name = NULL;
	ao_device *device = NULL;
	Tcl_HashEntry *hPtr = NULL;
	unsigned char* input = NULL;
	int dataSize;

	// We verify the arguments
	if( objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "name data");
		return TCL_ERROR;
	} 

	name = Tcl_GetStringFromObj(objv[1], NULL);


	hPtr = Tcl_FindHashEntry(devices, name);
	if (hPtr != NULL) {
	  device = (ao_device *) Tcl_GetHashValue(hPtr);
	}

	if (!device) {
		Tcl_AppendResult (interp, "Invalid device : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	input = Tcl_GetByteArrayFromObj(objv[2], &dataSize);

	ao_play(device, input, dataSize);

	return TCL_OK;
}


int Aio_Record _ANSI_ARGS_((ClientData clientData,
			     Tcl_Interp *interp,
			     int objc,
			     Tcl_Obj *CONST objv[])) 
{

  Tcl_AppendResult (interp, "Not Implemented" , (char *) NULL);
  return TCL_ERROR;
}

int Aio_PlayWav _ANSI_ARGS_((ClientData clientData,
			     Tcl_Interp *interp,
			     int objc,
			     Tcl_Obj *CONST objv[])) 
{

  Tcl_AppendResult (interp, "Not Implemented" , (char *) NULL);
  return TCL_ERROR;
}


int Aio_Close _ANSI_ARGS_((ClientData clientData,
			   Tcl_Interp *interp,
			   int objc,
			   Tcl_Obj *CONST objv[]))
{
	char * name = NULL;
	ao_device *device = NULL;
	Tcl_HashEntry *hPtr = NULL;
 
	// We verify the arguments
	if ( objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "name");
		return TCL_ERROR;
	} 

	name = Tcl_GetStringFromObj(objv[1], NULL);

	hPtr = Tcl_FindHashEntry(devices, name);
	if (hPtr != NULL) {
	  device = (ao_device *) Tcl_GetHashValue(hPtr);
	}

	if (!device) {
	  Tcl_AppendResult (interp, "Invalid device : " , name, (char *) NULL);
	  return TCL_ERROR;
	}

	ao_close(device);
	
	Tcl_DeleteHashEntry(hPtr);

	return TCL_OK;
	
}


int Aio_Init (Tcl_Interp *interp ) {
	

  //Check Tcl version is 8.3 or higher
  if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
    return TCL_ERROR;
  }

  ao_initialize();

  devices = (Tcl_HashTable *) ckalloc(sizeof(Tcl_HashTable));
  Tcl_InitHashTable(devices, TCL_STRING_KEYS);
   

  // Create the wrapping commands in the AIO namespace linked to custom functions with a NULL clientdata and 
  // no deleteproc inside the current interpreter
  Tcl_CreateObjCommand(interp, "::Aio::Open", Aio_Open,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Aio::Play", Aio_Play,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Aio::PlayWav", Aio_PlayWav,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Aio::Record", Aio_Record,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Aio::Close", Aio_Close,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL); 

  // end of Initialisation
  return TCL_OK;
}
int Aio_SafeInit (Tcl_Interp *interp) {
  return Aio_Init(interp);
}
