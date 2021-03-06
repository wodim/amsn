#include "capture.h"


static struct list_ptr* opened_devices = NULL;
static int curentCaptureNumber = 0;
#ifdef DEBUG
static int debug = 1;
#else
static int debug = 0;
#endif

struct list_ptr {
	struct list_ptr* prev_item;
	struct list_ptr* next_item;
	struct data_item* element;
};

struct ng_video_buf* get_video_buf(void *handle, struct ng_video_fmt *fmt) {
  return ((struct capture_item*) handle)->rgb_buffer;
}

/////////////////////////////////////
// Functions to manage lists       //
/////////////////////////////////////

struct list_ptr* Capture_lstGetListItem(char *list_element_id){ //Get the list item with the specified name
  struct list_ptr* item = g_list;

  while(item && strcmp(item->element->list_element_id, list_element_id))
    item = item->next_item;

  return item;

}


struct data_item* Capture_lstAddItem(struct data_item* item) {
  struct list_ptr* newItem = NULL;

  if (!item) return NULL;
  if (Capture_lstGetListItem(item->list_element_id)) return NULL;

  newItem = (struct list_ptr *) malloc(sizeof(struct list_ptr));

  if(newItem) {
    memset(newItem,0,sizeof(struct list_ptr));
    newItem->element = item;

    newItem->next_item = g_list;

    if (g_list) {
      g_list->prev_item = newItem;
    }
    g_list = newItem;

    return newItem->element;
  } else
    return NULL;

}

struct data_item* Capture_lstGetItem(char *list_element_id){ //Get the item with the specified name
	struct list_ptr* listitem = Capture_lstGetListItem(list_element_id);
	if(listitem)
		return listitem->element;
	else
		return NULL;
}

struct data_item* Capture_lstDeleteItem(char *list_element_id){
	struct list_ptr* item = Capture_lstGetListItem(list_element_id);
	struct data_item* element = NULL;

	if(item) {
	  element = item->element;
	  if(item->prev_item==NULL) //The first item
	    g_list = item->next_item;
	  else
	    (item->prev_item)->next_item = item->next_item;

	  if (item->next_item)
	    (item->next_item)->prev_item = item->prev_item;

	  free(item);
	}

	return element;
}


int Capture_ListDevices _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{
	struct ng_devinfo *info = NULL;
	char name[50];
	int i = 0;
	Tcl_Obj* device[2]={NULL,NULL};
	Tcl_Obj* lstDevice=NULL;
	Tcl_Obj* lstAll=NULL;

	if( objc != 1) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Capture::ListDevices\"" , (char *) NULL);
		return TCL_ERROR;
	}

	lstAll=Tcl_NewListObj(0, NULL);

	// Probe for devices from the v4l driver
	info = ng_vid_probe("v4l");
	if (info) {
	  // loop on all found devices
	  for(i = 0;info[i].device[0] != 0; i++){
	    if(debug) fprintf(stderr, "Found %s at %s\n", info[i].name, info[i].device);
	    strcpy(name, "V4L: ");
	    strcat(name, info[i].name);
	    device[0]=Tcl_NewStringObj(info[i].device,-1);
	    device[1]=Tcl_NewStringObj(name,-1);
	    lstDevice=Tcl_NewListObj(2,device);
	    Tcl_ListObjAppendElement(interp,lstAll,lstDevice);
	  }
	}

	free(info);

	// Probe for devices from the v4l2 driver
	info = ng_vid_probe("v4l2");
	if (info) {
	  // loop on all found devices
	  for(i = 0;info[i].device[0] != 0; i++){
	    if(debug) fprintf(stderr, "Found %s at %s\n", info[i].name, info[i].device);
	    strcpy(name, "V4L-2: ");
	    strcat(name, info[i].name);
	    device[0]=Tcl_NewStringObj(info[i].device,-1);
	    device[1]=Tcl_NewStringObj(name,-1);
	    lstDevice=Tcl_NewListObj(2,device);
	    Tcl_ListObjAppendElement(interp,lstAll,lstDevice);
	  }
	}

	free(info);


	Tcl_SetObjResult(interp,lstAll);
	return TCL_OK;
}

int Capture_ListChannels _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{
	char * dev = NULL;
	struct video_capability vcap;
	struct video_channel    vc;
	int i;
	int fvideo;
	Tcl_Obj* channel[2]={NULL,NULL};
	Tcl_Obj* lstChannel=NULL;
	Tcl_Obj* lstAll=NULL;

	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Capture::ListChannels devicename\"" , (char *) NULL);
		return TCL_ERROR;
	}

	dev = Tcl_GetStringFromObj(objv[1], NULL);

	if ((fvideo = open(dev, O_RDONLY))==-1){
		Tcl_AppendResult (interp, "Error opening device" , (char *) NULL);
		return TCL_ERROR;
	}
	if (ioctl(fvideo, VIDIOCGCAP, &vcap) < 0) {
		Tcl_AppendResult (interp, "Error getting capabilities" , (char *) NULL);
		close(fvideo);
		return TCL_ERROR;
	}

	lstAll=Tcl_NewListObj(0, NULL);

	for(i=0; i<vcap.channels; i++) {
		vc.channel = i;
		if (ioctl(fvideo, VIDIOCGCHAN, &vc) < 0){
			Tcl_AppendResult (interp, "Error getting capabilities" , (char *) NULL);
			close(fvideo);
			return TCL_ERROR;
		}
		if(debug) {
		  fprintf(stderr,"Video Source (%d) Name : %s\n",i, vc.name);
		  fprintf(stderr, "channel %d: %s ", vc.channel, vc.name);
		  fprintf(stderr, "%d tuners, has ", vc.tuners);
		  if (vc.flags & VIDEO_VC_TUNER) fprintf(stderr, "tuner(s) ");
		  if (vc.flags & VIDEO_VC_AUDIO) fprintf(stderr, "audio ");
		  fprintf(stderr, "\ntype: ");
		  if (vc.type & VIDEO_TYPE_TV) fprintf(stderr, "TV ");
		  if (vc.type & VIDEO_TYPE_CAMERA) fprintf(stderr, "CAMERA ");
		  fprintf(stderr, "norm: %d\n", vc.norm);
		}

		channel[0]=Tcl_NewIntObj(vc.channel);
		channel[1]=Tcl_NewStringObj(vc.name,-1);
		lstChannel=Tcl_NewListObj(2,channel);
		Tcl_ListObjAppendElement(interp,lstAll,lstChannel);

	}

	close(fvideo);

	Tcl_SetObjResult(interp,lstAll);
	return TCL_OK;
}

int Capture_GetGrabber _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{
	char * dev = NULL;
	int channel;
	struct list_ptr* item = opened_devices;

	if( objc != 3) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Capture::Init device channel\"" , (char *) NULL);
		return TCL_ERROR;
	}

	dev = Tcl_GetStringFromObj(objv[1], NULL);

	if(Tcl_GetIntFromObj(interp, objv[2], &channel)==TCL_ERROR){
		return TCL_ERROR;
	}

	while(item){
		if((strcasecmp(dev,item->element->devicePath)==0) && (channel == item->element->channel)){
			Tcl_SetObjResult(interp, Tcl_NewStringObj(item->element->captureName,-1));
			break;
		}
		item = item->next_item;
	}
	return TCL_OK;

}


int Capture_ListGrabbers _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{
	struct list_ptr* item = opened_devices;
	Tcl_Obj* grabber[3]={NULL,NULL,NULL};
	Tcl_Obj* lstGrabber=NULL;
	Tcl_Obj* lstAll=NULL;

	if( objc != 1) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Capture::ListGrabbers\"" , (char *) NULL);
		return TCL_ERROR;
	}

	lstAll=Tcl_NewListObj(0, NULL);

	while(item){
		if(debug) 
		  fprintf(stderr, "Grabber : %s for device %s and channel %d\n", 
			  item->element->captureName, item->element->devicePath, item->element->channel);

		grabber[0]=Tcl_NewStringObj(item->element->captureName,-1);
		grabber[1]=Tcl_NewStringObj(item->element->devicePath,-1);
		grabber[2]=Tcl_NewIntObj(item->element->channel);
		lstGrabber=Tcl_NewListObj(3,grabber);
		Tcl_ListObjAppendElement(interp,lstAll,lstGrabber);
		item = item->next_item;
	}

	Tcl_SetObjResult(interp,lstAll);
	return TCL_OK;

}


int Capture_Open _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{

  char                        *device = NULL;
  
  struct ng_attribute *attr = NULL;
  int i;

  struct capture_item* captureItem = NULL;
  int found = 0;
  struct list_head *item;
 
  int channel;

  if( objc != 3) {
    Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Capture::Init device channel\"" , (char *) NULL);
    return TCL_ERROR;
  }
  
  device = Tcl_GetStringFromObj(objv[1], NULL);
  
  if(Tcl_GetIntFromObj(interp, objv[2], &channel)==TCL_ERROR){
    return TCL_ERROR;
  }

  captureItem = (struct capture_item *) malloc(sizeof(struct capture_item));
  memset(captureItem, 0, sizeof(struct capture_item));
  
  // init the device and let libng find the appropriate driver for it
  if (0 != ng_vid_init(&captureItem->dev,device)) {
    if(debug) fprintf(stderr,"no grabber device available\n");
    Tcl_AppendResult (interp, "no grabber device available\n" , (char *) NULL);
    return TCL_ERROR;
  }
  
  // Check if we can capture from it
  if (!(captureItem->dev.flags & CAN_CAPTURE)) {
    if(debug) fprintf(stderr,"device does'nt support capture\n");
    Tcl_AppendResult (interp, "device does'nt support capture\n" , (char *) NULL);
    ng_dev_fini(&captureItem->dev);
    free(captureItem);
    return TCL_ERROR;
  }


  // If all went well, we open the driver (it was only initialized, but not opened and ready to use...
  ng_dev_open(&captureItem->dev);
  
  // Search for the ATTR_ID_INPUT (channel) ng_attribute struct
  found = 0;
  list_for_each(item, &(captureItem->dev.attrs)) {
    attr = list_entry(item, struct ng_attribute, device_list);
    if (attr->id == ATTR_ID_INPUT) {
      found = 1;
      break;
    }
  }
  if (!found) attr = NULL;

  // Set the channel using ng_attribute->write function
  if(attr != NULL) {
    if (-1 != channel)
      attr->write(attr, channel);
  }

  
  // try native colorspace RGB24
  captureItem->fmt.fmtid  = VIDEO_RGB24;
  captureItem->fmt.width  = HIGH_RES_W;
  captureItem->fmt.height = HIGH_RES_H;
  if (0 == captureItem->dev.v->setformat(captureItem->dev.handle,&captureItem->fmt))
    goto create_fd_and_return;
  

  // If failed, try native BGR24 (mostly all webcams on LE systems)
  captureItem->fmt.fmtid  = VIDEO_BGR24;
  if (0 == captureItem->dev.v->setformat(captureItem->dev.handle,&captureItem->fmt))
    goto create_fd_and_return;

  // If it failed, try to find a converted to RGB24
  captureItem->fmt.fmtid  = VIDEO_RGB24;

  // check all available conversion functions
  captureItem->fmt.bytesperline = captureItem->fmt.width*ng_vfmt_to_depth[captureItem->fmt.fmtid]/8;
  for (i = 0;;) {
    // Find a converter to RGB24 
    captureItem->conv = ng_conv_find_to(captureItem->fmt.fmtid, &i);

    // converter exists
    if (NULL == captureItem->conv)
      break;

    if(debug) fprintf(stderr, "Trying converter from %s to %s\n",
		      ng_vfmt_to_desc[captureItem->conv->fmtid_in], ng_vfmt_to_desc[captureItem->conv->fmtid_out]);

    // Set the new capture format to the colorspace of the input from the converter
    captureItem->gfmt = captureItem->fmt;
    captureItem->gfmt.fmtid = captureItem->conv->fmtid_in;
    captureItem->gfmt.bytesperline = 0;
    // Check if webcam supports the input colorspace of that converter
    if (0 == captureItem->dev.v->setformat(captureItem->dev.handle,&captureItem->gfmt)) {
      captureItem->fmt.width  = captureItem->gfmt.width;
      captureItem->fmt.height = captureItem->gfmt.height;
      // Save the new width and height and initialize the converter
      captureItem->handle = ng_conv_init(captureItem->conv,&captureItem->gfmt,&captureItem->fmt);
      goto create_fd_and_return;
    }
  }

  // If no converter found, then we don't have any converting proc from the webcam's colorspace to RGB24
  if (debug)
    fprintf(stderr, "Your webcam uses a palette that this extension does not support yet");
  
  Tcl_AppendResult (interp, "Your webcam uses a palette that this extension does not support yet" , (char *) NULL);
  ng_dev_close(&captureItem->dev);
  ng_dev_fini(&captureItem->dev);
  free(captureItem);
  return TCL_ERROR;
  
  
 create_fd_and_return:
  
  if (Capture_lstAddItem(captureItem)==NULL){
    perror("lstAddItem");
    ng_dev_close(&captureItem->dev);
    ng_dev_fini(&captureItem->dev);
    free(captureItem);
    return TCL_ERROR;
  }
  
  
  sprintf(captureItem->captureName,"capture%d",curentCaptureNumber);
  curentCaptureNumber++;
  
  strcpy(captureItem->devicePath,device);
  captureItem->channel=channel;

  // If a converter was used, setup the converter and allocate a new rgb_buffer
  if(captureItem->handle) {
    // To setup the converter, you give it a proc and a handle, the proc is used to return to the converter the output buffer where to store the result...
    ng_process_setup(captureItem->handle, get_video_buf, (void *)captureItem);
    captureItem->rgb_buffer = ng_malloc_video_buf(&captureItem->dev, &captureItem->fmt);
  }
  
  Tcl_SetObjResult(interp, Tcl_NewStringObj(captureItem->captureName,-1));

  return TCL_OK;
}

int Capture_Close _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{
	char *captureDescriptor=NULL;
	struct capture_item *capItem=NULL;

	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Capture::Close capturedescriptor\"" , (char *) NULL);
		return TCL_ERROR;
	}

	captureDescriptor = Tcl_GetStringFromObj(objv[1], NULL);
	if((capItem=Capture_lstGetItem(captureDescriptor))==NULL) {
		Tcl_AppendResult (interp, "Invalid capture descriptor. Please call Open before." , (char *) NULL);
		return TCL_ERROR;
	}

	// If a converter was used, close the it and release the rgb_buffer
	if(capItem->handle) {
	  ng_process_fini(capItem->handle);
	  ng_release_video_buf(capItem->rgb_buffer);
	}
	
	
	// Close the device, and free the device structure
	ng_dev_close(&capItem->dev);
	ng_dev_fini(&capItem->dev);

	Capture_lstDeleteItem(captureDescriptor);
	free(capItem);
	return TCL_OK;
}

int Capture_Grab _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{

    struct ng_video_fmt         fmt;
    struct capture_item*    capItem = NULL;
    char *                  captureDescriptor = NULL;
    char *                  image_name = NULL;
    char * 			resolution = NULL;

    Tk_PhotoImageBlock	block;
    Tk_PhotoHandle          Photo;
    int width, height;
    int diff_high = 0, diff_low = 0;

    if( objc != 3 && objc != 4) {
      Tcl_AppendResult (interp, "Wrong number of args.\nShould be " 
			"\"::Capture::Grab capturedescriptor image_name ?resolution?\"" , (char *) NULL);
      return TCL_ERROR;
    }
    
    captureDescriptor = Tcl_GetStringFromObj(objv[1], NULL);
    image_name = Tcl_GetStringFromObj(objv[2], NULL);
    
    if (objc == 4) {
      resolution = Tcl_GetStringFromObj(objv[3], NULL);
      if ( strcmp(resolution, "LOW") && strcmp(resolution, "HIGH")) {
	Tcl_AppendResult(interp, "The resolution should be either \"LOW\" or \"HIGH\"", NULL);
	return TCL_ERROR;
      }
    }
    
    
    if ( (Photo = Tk_FindPhoto(interp, image_name)) == NULL) {
      Tcl_AppendResult(interp, "The image you specified is not a valid photo image", NULL);
      return TCL_ERROR;
    }
    
    if( (capItem=Capture_lstGetItem(captureDescriptor)) == NULL){
      Tcl_AppendResult (interp, "Invalid capture descriptor. Please call Open before." , (char *) NULL);
      return TCL_ERROR;
    }
    
    // Set the resolution
    if (resolution && !strcmp(resolution, "HIGH")) {
      width = HIGH_RES_W;
      height = HIGH_RES_H;
    } else if (resolution && !strcmp(resolution, "LOW")) {
      width = LOW_RES_W;
      height = LOW_RES_H;
    } else {
      width = capItem->fmt.width;
      height = capItem->fmt.height;
    }
    // If we use a converter, set the resolution depending on the converter's format
    if(capItem->conv) {
      fmt = capItem->gfmt;
    } else {
      // else, use the native format
      fmt = capItem->fmt;
    }

    fmt.width  = width;
    fmt.height = height;
    capItem->dev.v->setformat(capItem->dev.handle,&fmt);

    // Get the image using the vid_driver device
    if (NULL == (capItem->image_data = capItem->dev.v->getimage(capItem->dev.handle))) {
	if(debug) fprintf(stderr,"capturing image failed at %d, %d\n", fmt.width, fmt.height);
	fmt.height = HIGH_RES_W;
	fmt.width  = HIGH_RES_H;
	capItem->dev.v->setformat(capItem->dev.handle,&fmt);
	if (NULL == (capItem->image_data = capItem->dev.v->getimage(capItem->dev.handle))) {
	  if(debug) fprintf(stderr,"capturing image failed at %d, %d\n", fmt.width, fmt.height);
	  fmt.height = LOW_RES_W;
	  fmt.width  = LOW_RES_H;
	  capItem->dev.v->setformat(capItem->dev.handle,&fmt);
	  if (NULL == (capItem->image_data = capItem->dev.v->getimage(capItem->dev.handle))) {
	    if(debug) fprintf(stderr,"capturing image failed at %d, %d\n", fmt.width, fmt.height);
	    Tcl_AppendResult(interp, "Unable to capture from the device", (char *) NULL);
	    return TCL_ERROR;
	  }
	}
    }


   
    width = fmt.width;
    height = fmt.height;

    // if a converter was used, put the frame into the converter and get it, once converted
    if (capItem->conv) {
      ng_process_put_frame(capItem->handle,capItem->image_data);
      capItem->rgb_buffer = ng_process_get_frame(capItem->handle);
    } else {
      capItem->rgb_buffer = capItem->image_data;
    }
    	
    


    block.pixelPtr  = capItem->rgb_buffer->data;
    block.width = capItem->rgb_buffer->fmt.width;
    block.height = capItem->rgb_buffer->fmt.height;
    
    block.pitch = block.width*3;
    block.pixelSize = 3;
    
    block.offset[1] = 1;
    block.offset[3] = -1;

    // Check for RGB24 vs. BGR24
    if (capItem->fmt.fmtid == VIDEO_RGB24) {
      block.offset[0] = 0;
      block.offset[2] = 2;
    } else {
      block.offset[0] = 2;
      block.offset[2] = 0;    
    }

    

    Tk_PhotoBlank(Photo);
    
    Tk_PhotoSetSize(
#	if TK_MINOR_VERSION == 5
		    interp,
#	endif
		    Photo, block.width, block.height);


    Tk_PhotoPutBlock(
#if TK_MINOR_VERSION == 5
		     interp,
#endif
		     Photo, &block, 0, 0, block.width, block.height
#if TK_MINOR_VERSION > 3 
		     ,TK_PHOTO_COMPOSITE_OVERLAY
#endif
		     );
    
    capItem->fmt.width = width;
    capItem->fmt.height = height;
    
    Tcl_ResetResult(interp);
    diff_high = width - HIGH_RES_W;
    if (diff_high < 0) diff_high = -diff_high;
    diff_low = width - LOW_RES_W;
    if (diff_low < 0) diff_low = -diff_low;
    
    if (diff_high <= diff_low) {
      width = HIGH_RES_W;
      height = HIGH_RES_H;
      Tcl_AppendResult(interp, "HIGH", (char *) NULL);
    } else {
      width = LOW_RES_W;
      height = LOW_RES_H;
      Tcl_AppendResult(interp, "LOW", (char *) NULL);
    }


    Tk_PhotoSetSize(
#	if TK_MINOR_VERSION == 5
		    interp,
#	endif
		    Photo, width, height);

    // Make sure to release the rgb_buffer if no converter is used so the next grab will not wait unnecessarly
    if (!capItem->conv)
      ng_release_video_buf(capItem->rgb_buffer);
    
    return TCL_OK;
}

int Capture_AccessSettings _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{
  struct ng_attribute *attr;
  char *captureDescriptor = NULL;
  char *proc = NULL;
  struct capture_item *capItem = NULL;
  int new_value = 0;
  int set = 0;
  int attribute;
  int value;
  struct list_head *item;
  int found = 0;

  proc = Tcl_GetStringFromObj(objv[0], NULL);
  
  // Depending on the proc, set the correct attribute to get/set
  if (!strcmp(proc, "::Capture::SetBrightness")) {
    set = 1;
    attribute = ATTR_ID_BRIGHT;
  } else if (!strcmp(proc, "::Capture::SetContrast")) {
    set = 1;
    attribute = ATTR_ID_CONTRAST;
  } else if (!strcmp(proc, "::Capture::SetHue")) {
    set = 1;
    attribute = ATTR_ID_HUE;
  } else if (!strcmp(proc, "::Capture::SetColour")) {
    set = 1;
    attribute = ATTR_ID_COLOR;
  } else if (!strcmp(proc, "::Capture::GetBrightness")) {
    attribute = ATTR_ID_BRIGHT;
  } else if (!strcmp(proc, "::Capture::GetContrast")) {
    attribute = ATTR_ID_CONTRAST;
  } else if (!strcmp(proc, "::Capture::GetHue")) {
    attribute = ATTR_ID_HUE;
  } else if (!strcmp(proc, "::Capture::GetColour")) {
    attribute = ATTR_ID_COLOR;
  } else {
    Tcl_ResetResult(interp);
    Tcl_AppendResult (interp, "Wrong procedure name, should be either one of those : \n" , (char *) NULL);
    Tcl_AppendResult (interp, "::Capture::SetBrightness, ::Capture::SetContrast, ::Capture::SetHue, ::Capture::SetColour\n" , (char *) NULL);
    Tcl_AppendResult (interp, "::Capture::GetBrightness, ::Capture::GetContrast, ::Capture::GetHue, ::Capture::GetColour" , (char *) NULL);
    return TCL_ERROR;
  }
  
  if ( set && objc != 3) {
    Tcl_WrongNumArgs (interp, 1, objv, "capture_descriptor new_value");
    return TCL_ERROR;
  }
  if ( !set && objc != 2) {
    Tcl_WrongNumArgs (interp, 1, objv, "capture_descriptor");
    return TCL_ERROR;
  }
  
  captureDescriptor = Tcl_GetStringFromObj(objv[1], NULL);
  
  if((capItem=Capture_lstGetItem(captureDescriptor))==NULL){
    Tcl_AppendResult (interp, "Invalid capture descriptor. Please call Open before." , (char *) NULL);
    return TCL_ERROR;
  }
  
  if (set) {
    if(Tcl_GetIntFromObj(interp, objv[2], &new_value)==TCL_ERROR){
      return TCL_ERROR;
    }
    
    if (new_value>65535 || new_value < 0) {
      Tcl_AppendResult (interp, "Invalid value. should be between 0 and 65535" , (char *) NULL);
      return TCL_ERROR;
    }
  }
  

  Tcl_ResetResult(interp);

  // Get the ng_attribute struct from the attribute id
  found = 0;
  list_for_each(item, &(capItem->dev.attrs)) {
    attr = list_entry(item, struct ng_attribute, device_list);
    if (attr->id == attribute) {
        found = 1;
        break;
    }
  }
  if (!found) attr = NULL;

  // if we set, use attribute->write proc, else, use the attribute->read proc...
  if(attr != NULL) {
    if (set) {
      if (-1 != new_value)
	attr->write(attr, new_value);
    } else {
      value = attr->read(attr);
      Tcl_SetObjResult(interp, Tcl_NewIntObj(value));
    }
  } else {
      Tcl_SetObjResult(interp, Tcl_NewIntObj(0));
  }
  return TCL_OK;
}


int Capture_IsValid _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]))
{
	char *                  captureDescriptor=NULL;

	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Capture::IsValid capturedescriptor\"" , (char *) NULL);
		return TCL_ERROR;
	}

	captureDescriptor = Tcl_GetStringFromObj(objv[1], NULL);

	Tcl_SetObjResult(interp, Tcl_NewBooleanObj( Capture_lstGetItem(captureDescriptor) != NULL ) );

	return TCL_OK;

}

int Capture_Init (Tcl_Interp *interp ) {

	//Check Tcl version is 8.3 or higher
	if (Tcl_InitStubs(interp, "8.3", 0) == NULL) {
		return TCL_ERROR;
	}

	//Check TK version is 8.3 or higher
	if (Tk_InitStubs(interp, "8.3", 0) == NULL) {
		return TCL_ERROR;
	}

	Tcl_CreateObjCommand(interp, "::Capture::ListDevices", Capture_ListDevices,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::ListChannels", Capture_ListChannels,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::Open", Capture_Open,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::GetGrabber", Capture_GetGrabber,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::Close", Capture_Close,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::Grab", Capture_Grab,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

	Tcl_CreateObjCommand(interp, "::Capture::SetBrightness", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::SetContrast", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::SetHue", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::SetColour", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

	Tcl_CreateObjCommand(interp, "::Capture::GetBrightness", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::GetContrast", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::GetHue", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::GetColour", Capture_AccessSettings,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

	Tcl_CreateObjCommand(interp, "::Capture::IsValid", Capture_IsValid,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "::Capture::ListGrabbers", Capture_ListGrabbers,
			(ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
#ifdef DEBUG
	ng_debug = 1;
#else
	ng_debug = 0;
#endif
	ng_init();
	

	// end of Initialisation
	return TCL_OK;
}

int Capture_SafeInit (Tcl_Interp *interp ) {
	return Capture_Init(interp);
}
