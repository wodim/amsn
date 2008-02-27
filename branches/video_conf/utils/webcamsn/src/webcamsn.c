/*
  File : Webcamsn.c

  Description :	Contains all functions for the Webcamsn extension

  Author : Youness El Alaoui (KaKaRoTo - kakaroto@users.sourceforge.net)
*/


// Include the header file
#include "webcamsn.h"
#include "kidhash.h"


#define ML20_FOURCC 0x30324C4D
#define WMV3_FOURCC 0x33564D57

int encoder_counter = 0;
int decoder_counter = 0;

struct list_ptr *Codecs = NULL;


#ifdef HAVE_LIBAVCODEC
AVCodec * wmv3_avdecoder = NULL;
#endif


struct list_ptr {
	struct list_ptr* prev_item;
	struct list_ptr* next_item;
	struct data_item* element;
};


/////////////////////////////////////
// Functions to manage lists       //
/////////////////////////////////////

struct list_ptr* Webcamsn_lstGetListItem(char *list_element_id){ //Get the list item with the specified name
  struct list_ptr* item = g_list;

  while(item && strcmp(item->element->list_element_id, list_element_id))
    item = item->next_item;
  
  return item;

}

int Webcamsn_lstListSize(){ 
  struct list_ptr* item = g_list;
  int ret = 0;

  while(item) {
    item = item->next_item;
    ret = ret + 1;
  }
  
  return ret;

}

struct data_item* Webcamsn_lstAddItem(struct data_item* item) {
  struct list_ptr* newItem;

  if (!item) return NULL;
  if (Webcamsn_lstGetListItem(item->list_element_id)) return NULL;

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

struct data_item* Webcamsn_lstGetItem(char *list_element_id){ //Get the item with the specified name
	struct list_ptr* listitem = Webcamsn_lstGetListItem(list_element_id);
	if(listitem)
		return listitem->element;
	else
		return NULL;
}

struct data_item* Webcamsn_lstDeleteItem(char *list_element_id){
	struct list_ptr* item = Webcamsn_lstGetListItem(list_element_id);
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


BYTE * RGBA2RGB(Tk_PhotoImageBlock data) {
	int i;
	int size = data.height * data.width * data.pixelSize;
	BYTE * FrameData = (BYTE *) malloc(data.height * data.width * 3);
	BYTE * pixelPtr = FrameData;

	for (i = 0; i < size; i+= data.pixelSize) {
		*(pixelPtr++) = *(data.pixelPtr + i + data.offset[0]);
		*(pixelPtr++) = *(data.pixelPtr + i + data.offset[1]);
		*(pixelPtr++) = *(data.pixelPtr + i + data.offset[2]);
	}

	return FrameData;
} 

#ifdef HAVE_LIBAVCODEC
static void destroy_wmv3_codec(CodecInfo *codec) {
  if (codec->wmv3_codec->codec) {
    avcodec_close(codec->wmv3_codec);
  }
  free(codec->wmv3_codec->extradata);
  codec->wmv3_codec->extradata = NULL;
  codec->wmv3_codec->extradata_size = 0;
  av_free(codec->wmv3_codec);
  codec->wmv3_codec = NULL;
  av_free(codec->wmv3_frame);
  codec->wmv3_frame = NULL;
  av_free(codec->wmv3_rgb_frame);
  codec->wmv3_rgb_frame = NULL;
  free (codec->rgb_buffer);
  codec->rgb_buffer = NULL;

}
#endif

static int init_decoder(Tcl_Interp *interp, CodecInfo *decoder, int fcc, int width, int height) {
  char *reason = NULL;
  int buffer_size = 0;

  if (decoder->type != DECODER_UNINITIALIZED) {
    Tcl_ResetResult(interp);
    Tcl_AppendResult(interp, "Object is encoder or is already initialized decoder", NULL);
    return TCL_ERROR;
  }

#ifdef HAVE_LIBAVCODEC
  buffer_size = avpicture_get_size (PIX_FMT_RGB24, width, height);
#else
  buffer_size = width * height * 3;
#endif
  decoder->rgb_buffer = malloc (buffer_size);
  if (!decoder->rgb_buffer) {
    Tcl_AppendResult(interp, "Unable to allocate RGB buffer", NULL);
    return TCL_ERROR;
  }

  if (fcc == ML20_FOURCC) {
    decoder->ml20_codec = mimic_open();
    decoder->type = DECODER_ML20_UNINITIALIZED;
  } else if (fcc == WMV3_FOURCC) {
#ifdef HAVE_LIBAVCODEC
    const static uint8_t sequence_layer[] = { 0x0f, 0xf1, 0x80, 0x01};

    decoder->wmv3_codec = avcodec_alloc_context2(CODEC_TYPE_VIDEO);
    if (!decoder->wmv3_codec) {
      reason = "Couldn't allocate context";
      goto wmv3_error;
    }
    decoder->wmv3_frame = avcodec_alloc_frame();
    if (!decoder->wmv3_frame) {
      reason = "Couldn't allocate frame";
      goto wmv3_error;
    }
    decoder->wmv3_rgb_frame = avcodec_alloc_frame();
    if (!decoder->wmv3_rgb_frame) {
      reason = "Couldn't allocate RGB frame";
      goto wmv3_error;
    }

    avpicture_fill ((AVPicture *) decoder->wmv3_rgb_frame,
		    decoder->rgb_buffer, PIX_FMT_RGB24, width, height);

    decoder->wmv3_codec->extradata = malloc (sizeof(sequence_layer));
    if (!decoder->wmv3_codec->extradata) {
      reason = "Couldn't allocate sequence layer";
      goto wmv3_error;
    }
    decoder->wmv3_codec->extradata_size = sizeof(sequence_layer);
    memcpy (decoder->wmv3_codec->extradata, sequence_layer, sizeof(sequence_layer));

    decoder->wmv3_codec->width = width;
    decoder->wmv3_codec->height = height;
    decoder->wmv3_codec->bits_per_sample = 0x18;

    if (avcodec_open(decoder->wmv3_codec, wmv3_avdecoder) < 0) {
      reason = "Couldn't open codec";
      goto wmv3_error;
    }
    decoder->type = DECODER_WMV3_INITIALIZED;
#else
    Tcl_AppendResult(interp, "Cannot create WMV3 decoder. Must compile with libavcodec", NULL);
    return TCL_ERROR;
#endif
  } else {
    Tcl_AppendResult(interp, "Unknwon FCC. Expected 'ML20' or 'WMV3'", NULL);
    return TCL_ERROR;
  }

  return TCL_OK;

#ifdef HAVE_LIBAVCODEC
 wmv3_error:
	
  destroy_wmv3_codec(decoder);

  Tcl_ResetResult(interp);
  Tcl_AppendResult(interp, "Error creating WMV3 decoder. ", reason, NULL);
  return TCL_ERROR;
#endif
}

int Webcamsn_NewDecoder _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[])) 
{
	CodecInfo *new_decoder;
	char name[30];
	char *req_name = NULL;
	char *fcc = NULL;

	// We verify the arguments
	if( objc < 1 || objc > 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::NewDecoder ?name?\"" , (char *) NULL);
		return TCL_ERROR;
	} 

	new_decoder = (struct CodecInfo *) malloc(sizeof(struct CodecInfo));

	memset(new_decoder, 0, sizeof(struct CodecInfo));

	if ( objc == 3) {
	  // Set the requested name and see if it exists...
	  req_name = Tcl_GetStringFromObj(objv[1], NULL);
	  if (Webcamsn_lstGetItem(req_name) == NULL) {
	    strcpy(name, req_name );
	  }else {
	    sprintf(name, "decoder%d", ++decoder_counter);
	  }
	} else {
	  sprintf(name, "decoder%d", ++decoder_counter);
	}

	new_decoder->type = DECODER_UNINITIALIZED;
	strcpy(new_decoder->name, name);
	new_decoder->frames = 0;

	Webcamsn_lstAddItem(new_decoder);

	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, name, NULL);

	return TCL_OK;

}

int Webcamsn_NewEncoder _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[])) 
{

	CodecInfo *new_encoder;
	MimCtx * encoder = NULL;
	char name[15];
	char * req_name = NULL;
	char * strResolution = NULL;
	MimicResEnum resolution;


	// We verify the arguments
	if( objc < 2 || objc > 3) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::NewEncoder resolution ?name?\" " ,
			"where the resolution is either \"LOW\" or \"HIGH\"", (char *) NULL);
		return TCL_ERROR;
	}

	strResolution = Tcl_GetStringFromObj(objv[1], NULL);

	if (!strcmp(strResolution, "LOW")) {
		resolution = MIMIC_RES_LOW;
	} else if (!strcmp(strResolution, "HIGH")) {
		resolution = MIMIC_RES_HIGH;
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult (interp, "Invalid resolution. The resolution is either \"LOW\" or \"HIGH\"", (char *) NULL);
		return TCL_ERROR;

	}

	new_encoder = (struct CodecInfo *) malloc(sizeof(struct CodecInfo));

	memset(new_encoder, 0, sizeof(struct CodecInfo));

	if ( objc == 3) {
	  // Set the requested name and see if it exists...
	  req_name = Tcl_GetStringFromObj(objv[2], NULL);
	  if (Webcamsn_lstGetItem(req_name) == NULL) {
	    strcpy(name, req_name);
	  }else {
	    sprintf(name, "encoder%d", ++encoder_counter);
	  }
	} else {
	  sprintf(name, "encoder%d", ++encoder_counter);
	}


	new_encoder->ml20_codec = mimic_open();
	strcpy(new_encoder->name, name);
	new_encoder->type = ENCODER;
	new_encoder->frames = 0;

	mimic_encoder_init(new_encoder->ml20_codec, resolution);


	Webcamsn_lstAddItem(new_encoder);

	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, name, NULL);

	return TCL_OK;
	
}

int Webcamsn_Decode _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]))
{
	char * name = NULL;
	CodecInfo * decoder;
	
	char * image_name = NULL;
	Tk_PhotoHandle Photo;
	Tk_PhotoImageBlock block;

	VideoHeader *header;
	BYTE * buffer = NULL;
	BYTE * FrameData = NULL;
	BYTE * output = NULL;
	int got_picture = 0;
	int length = 0;
	int width = 0;
	int height = 0;

	// We verify the arguments
	if( objc != 4) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::Decode decoder to_image data\"" , (char *) NULL);
		return TCL_ERROR;
	} 

	name = Tcl_GetStringFromObj(objv[1], NULL);

	decoder = Webcamsn_lstGetItem(name);

	if (!decoder) {
		Tcl_AppendResult (interp, "Invalid decoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	if (decoder->type == ENCODER) {
		Tcl_AppendResult (interp, name, " is an encoder, not a decoder" , (char *) NULL);
		return TCL_ERROR;
	}

	image_name = Tcl_GetStringFromObj(objv[2], NULL);

	if ( (Photo = Tk_FindPhoto(interp, image_name)) == NULL) {
		Tcl_AppendResult(interp, "The image you specified is not a valid photo image", NULL);
		return TCL_ERROR;
	}
    
	buffer = Tcl_GetByteArrayFromObj(objv[3], &length);

	header = (VideoHeader *) buffer;

	header->header_size = GUINT16_FROM_LE(header->header_size);
	header->fourcc = GUINT32_FROM_LE(header->fourcc);
	header->payload_size = GUINT32_FROM_LE(header->payload_size);

	if (header->header_size != 24 ||
	    length < (header->header_size + header->payload_size)) {
		Tcl_AppendResult(interp, "Not enough data", NULL);
		return TCL_ERROR;
	}
	
	FrameData = buffer + header->header_size;

	if (decoder->type == DECODER_UNINITIALIZED) {
	  if (init_decoder(interp, decoder, header->fourcc,
			   header->width, header->height) != TCL_OK) {
	    return TCL_ERROR;
	  }
	  if (decoder->type == DECODER_ML20_UNINITIALIZED) {
	    if (!mimic_decoder_init(decoder->ml20_codec, FrameData)) {
	      Tcl_AppendResult(interp, "Unable to initialize the decoder, the data you supplied is not valid", (char *) NULL);
	      return TCL_ERROR;
	    } else {
	      decoder->type = DECODER_ML20_INITIALIZED;
	    }
	  }
	}

	if (decoder->type == DECODER_ML20_INITIALIZED) {
	  if (header->fourcc == ML20_FOURCC) {
	    mimic_get_property(decoder->ml20_codec, "width", &width);
	    mimic_get_property(decoder->ml20_codec, "height", &height);

	    got_picture = mimic_decode_frame(decoder->ml20_codec, FrameData, decoder->rgb_buffer);
	  } else {
	      Tcl_AppendResult(interp, "ML20 decoder received WMV3 frame", (char *) NULL);
	      return TCL_ERROR;
	  }
	} else if (decoder->type == DECODER_WMV3_INITIALIZED) {
#ifdef HAVE_LIBAVCODEC
	  if (header->fourcc == WMV3_FOURCC) {
	    int ret;
	    ret = avcodec_decode_video (decoder->wmv3_codec, decoder->wmv3_frame,
					&got_picture, FrameData, header->payload_size);
	    if (ret < 0) {
	      got_picture = 0;
	    }

	    if (got_picture) {
	      img_convert ((AVPicture *) decoder->wmv3_rgb_frame, PIX_FMT_RGB24,
			   (AVPicture *) decoder->wmv3_frame, decoder->wmv3_codec->pix_fmt,
			   decoder->wmv3_codec->width, decoder->wmv3_codec->height);
	      width = decoder->wmv3_codec->width;
	      height = decoder->wmv3_codec->height;
	    }
	  } else {
	      Tcl_AppendResult(interp, "WMV3 decoder received ML20 frame", (char *) NULL);
	      return TCL_ERROR;
	  }
#endif

	}

	if (got_picture) {
		decoder->frames++;

		Tk_PhotoSetSize(
		#if TK_MINOR_VERSION == 5
			interp, 
		#endif
			Photo, width, height);


		block.pixelPtr  = decoder->rgb_buffer;		// pixel ptr
		block.width = width;
		block.height = height;
		block.pitch = width*3;
		block.pixelSize = 3;

		block.offset[0] = 0;
		block.offset[1] = 1;
		block.offset[2] = 2;
		block.offset[3] = -1;

		Tk_PhotoPutBlock(
			#if TK_MINOR_VERSION == 5
			interp, 
			#endif
				Photo, &block, 0, 0, width, height
			#if TK_MINOR_VERSION > 3 
				,TK_PHOTO_COMPOSITE_OVERLAY
			#endif 
			);
	
		return TCL_OK;
	} else {
		Tcl_AppendResult(interp, "Unable to decode current frame, the data you supplied is not valid", (char *) NULL);
		return TCL_ERROR;
	}
	
}

int Webcamsn_Encode _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[])) 
{
	char * name = NULL;
	CodecInfo * encoder;
	
	char * image_name = NULL;
	Tk_PhotoHandle Photo;
	Tk_PhotoImageBlock photoData;

	BYTE * buffer = NULL;
	BYTE * FrameData = NULL;
	BYTE * output = NULL;
	int length = 0;
	int width = 0;
	int height = 0;

	// We verify the arguments
	if( objc != 3) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::Encode encoder from_image\"" , (char *) NULL);
		return TCL_ERROR;
	} 

	name = Tcl_GetStringFromObj(objv[1], NULL);

	encoder = Webcamsn_lstGetItem(name);

	if (!encoder) {
		Tcl_AppendResult (interp, "Invalid encoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	if (encoder->type != ENCODER) {
		Tcl_AppendResult (interp, name, " is a decoder, not an encoder" , (char *) NULL);
		return TCL_ERROR;
	}

	image_name = Tcl_GetStringFromObj(objv[2], NULL);

	if ( (Photo = Tk_FindPhoto(interp, image_name)) == NULL) {
		Tcl_AppendResult(interp, "The image you specified is not a valid photo image", NULL);
		return TCL_ERROR;
	}
      
	Tk_PhotoGetImage(Photo, &photoData);

	mimic_get_property(encoder->ml20_codec, "buffer_size", &length);
	mimic_get_property(encoder->ml20_codec, "width", &width);
	mimic_get_property(encoder->ml20_codec, "height", &height);

	output = (BYTE *) malloc(length*5);
	FrameData = RGBA2RGB(photoData);
	

	if (mimic_encode_frame(encoder->ml20_codec, FrameData, output, 
		&length, ((encoder->frames % MAX_INTERFRAMES) == 0? TRUE : FALSE) )) {
		
		encoder->frames++;

		Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(output, length));
		free(output);
		free(FrameData);
	
		return TCL_OK;
	} else {
		free(output);
		free(FrameData);
		Tcl_AppendResult(interp, "Unable to encode the image", (char *) NULL);
		return TCL_ERROR;
	}
		
}

int Webcamsn_SetQuality _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[])) 
{
	int quality = 0;
	char * name = NULL;
	CodecInfo * encoder;

	// We verify the arguments
	if( objc != 3) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::SetQuality encoder quality\"" , (char *) NULL);
		return TCL_ERROR;
	} 

	name = Tcl_GetStringFromObj(objv[1], NULL);

	encoder = Webcamsn_lstGetItem(name);

	if (!encoder) {
		Tcl_AppendResult (interp, "Invalid encoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	if (encoder->type != ENCODER) {
		Tcl_AppendResult (interp, name, " is a decoder, not an encoder" , (char *) NULL);
		return TCL_ERROR;
	}
	

	if( Tcl_GetIntFromObj(interp, objv[2], &quality) == TCL_ERROR)
		return TCL_ERROR;

	if (mimic_set_property(encoder->ml20_codec, "quality", &quality)) {
		return TCL_OK;
	} else {
		Tcl_AppendResult(interp, "unable to change quality of encoder : ", name, (char *) NULL);
		return TCL_ERROR;
	}
	
}

int Webcamsn_GetWidth _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]))
{
	int width = 0;

	char * name = NULL;
	CodecInfo * codec;

	// We verify the arguments
	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::GetWidth codec\"" , (char *) NULL);
		return TCL_ERROR;
	} 


	name = Tcl_GetStringFromObj(objv[1], NULL);
	codec = Webcamsn_lstGetItem(name);

	if (!codec) {
		Tcl_AppendResult (interp, "Invalid encoder/decoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	if(codec->type == DECODER_ML20_UNINITIALIZED) {
		Tcl_AppendResult (interp, "Before requesting this data, the decoder must have been initialized ", 
			"with at least one chunk of data" , (char *) NULL);
		return TCL_ERROR;
	} else if (codec->type != DECODER_ML20_INITIALIZED && codec->type != ENCODER ) {
		Tcl_AppendResult (interp, "This method can only be called on an ML20 decoder or encoder" , (char *) NULL);
		return TCL_ERROR;
	}

	if (mimic_get_property(codec->ml20_codec, "width", &width)) {
		Tcl_SetObjResult(interp, Tcl_NewIntObj(width));
		return TCL_OK;
	} else {
		Tcl_AppendResult(interp, "unable to get width for codec : ", name, (char *) NULL);
		return TCL_ERROR;
	}	
}

int Webcamsn_GetHeight _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]))
{
	int height = 0;

	char * name = NULL;
	CodecInfo * codec;

	// We verify the arguments
	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::GetHeight codec\"" , (char *) NULL);
		return TCL_ERROR;
	} 


	name = Tcl_GetStringFromObj(objv[1], NULL);
	codec = Webcamsn_lstGetItem(name);

	if (!codec) {
		Tcl_AppendResult (interp, "Invalid encoder/decoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	if(codec->type == DECODER_ML20_UNINITIALIZED) {
		Tcl_AppendResult (interp, "Before requesting this data, the decoder must have been initialized ", 
			"with at least one chunk of data" , (char *) NULL);
		return TCL_ERROR;
	} else if (codec->type != DECODER_ML20_INITIALIZED && codec->type != ENCODER) {
		Tcl_AppendResult (interp, "This method can only be called on an ML20 decoder or encoder" , (char *) NULL);
		return TCL_ERROR;
	}

	if (mimic_get_property(codec->ml20_codec, "height", &height)) {
		Tcl_SetObjResult(interp, Tcl_NewIntObj(height));
		return TCL_OK;
	} else {
		Tcl_AppendResult(interp, "unable to get height for codec : ", name, (char *) NULL);
		return TCL_ERROR;
	}

	return TCL_OK;
	
}

int Webcamsn_GetQuality _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]))
{
	int quality = 0;

	char * name = NULL;
	CodecInfo * codec;

	// We verify the arguments
	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::GetQuality codec\"" , (char *) NULL);
		return TCL_ERROR;
	} 


	name = Tcl_GetStringFromObj(objv[1], NULL);
	codec = Webcamsn_lstGetItem(name);

	if (!codec) {
		Tcl_AppendResult (interp, "Invalid encoder/decoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	if(codec->type == DECODER_ML20_UNINITIALIZED) {
		Tcl_AppendResult (interp, "Before requesting this data, the decoder must have been initialized ", 
			"with at least one chunk of data" , (char *) NULL);
		return TCL_ERROR;
	} else if (codec->type != DECODER_ML20_INITIALIZED && codec->type != ENCODER) {
		Tcl_AppendResult (interp, "This method can only be called on an ML20 decoder" , (char *) NULL);
		return TCL_ERROR;
	}

	if (mimic_get_property(codec->ml20_codec, "quality", &quality)) {
		Tcl_SetObjResult(interp, Tcl_NewIntObj(quality));
		return TCL_OK;
	} else {
		Tcl_AppendResult(interp, "Unable to get the quality of the codec : ", name, (char *) NULL);
		return TCL_ERROR;
	}

	return TCL_OK;
	
}

int Webcamsn_Close _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]))
{
	char * name = NULL;
	CodecInfo * codec;

	// We verify the arguments
	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::Close codec\"" , (char *) NULL);
		return TCL_ERROR;
	} 


	name = Tcl_GetStringFromObj(objv[1], NULL);
	codec = Webcamsn_lstGetItem(name);

	if (!codec) {
		Tcl_AppendResult (interp, "Invalid encoder/decoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}
 

	if (codec->ml20_codec) {
	  mimic_close(codec->ml20_codec);
	  codec->ml20_codec = NULL;
	}
#ifdef HAVE_LIBAVCODEC
	if (codec->wmv3_codec) {
	  destroy_wmv3_codec(codec);
	}
#endif

	Webcamsn_lstDeleteItem(name);
	free(codec);

	return TCL_OK;
	
}


int Webcamsn_Count _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]))
{

	Tcl_SetObjResult(interp, Tcl_NewIntObj(Webcamsn_lstListSize()));
	return TCL_OK;
}

int Webcamsn_Frames _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
								Tcl_Obj *CONST objv[]))
{

	char * name = NULL;
	CodecInfo * codec;

	// We verify the arguments
	if( objc != 2) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"::Webcamsn::NbFrames codec\"" , (char *) NULL);
		return TCL_ERROR;
	} 


	name = Tcl_GetStringFromObj(objv[1], NULL);
	codec = Webcamsn_lstGetItem(name);

	if (!codec) {
		Tcl_AppendResult (interp, "Invalid encoder/decoder : " , name, (char *) NULL);
		return TCL_ERROR;
	}

	
	Tcl_SetObjResult(interp, Tcl_NewIntObj((int) codec->frames));

	return TCL_OK;
	
}

int Webcamsn_KidHash _ANSI_ARGS_((ClientData clientData,
								Tcl_Interp *interp,
								int objc,
				  Tcl_Obj *CONST objv[])) {


	char * sid = NULL;
	char * key = NULL;
	int kid;
	char a[30];
	int a_size = 30;


	// We verify the arguments
	if( objc != 3) {
		Tcl_AppendResult (interp, "Wrong number of args.\nShould be " 
				  "\"::Webcamsn::CreateHashFromKid kid sid\"" , (char *) NULL);
		return TCL_ERROR;
	} 

	Tcl_GetIntFromObj(interp, objv[1], &kid);
	sid = Tcl_GetStringFromObj(objv[2], NULL);
	
	key = (char *) malloc (strlen(sid) + 10);
	sprintf(key, "sid=%s", sid);

	if (MakeKidHash(a, &a_size, kid, key)) {
	  Tcl_ResetResult(interp);
	  Tcl_AppendResult (interp, a, (char *) NULL);
	  free(key);
	  
	  return TCL_OK;	  
	} else {
	  Tcl_ResetResult(interp);
	  free(key);
	  
	  return TCL_OK;
	}
}


/*
  Function : Webcamsn_Init

  Description :	The Init function that will be called when the extension is loaded to your tk shell

  Arguments   :	Tcl_Interp *interp    :	This is the interpreter from which the load was made and to 
  which we'll add the new command


  Return value : TCL_OK in case everything is ok, or TCL_ERROR in case there is an error (Tk version < 8.3)

  Comments     : hummmm... not much, it's simple :)

*/
int Webcamsn_Init (Tcl_Interp *interp ) {
	

  //Check Tcl version is 8.3 or higher
  if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
    return TCL_ERROR;
  }

  //Check TK version is 8.3 or higher
  if (Tk_InitStubs(interp, TK_VERSION, 0) == NULL) {
    return TCL_ERROR;
  }

#ifdef HAVE_LIBAVCODEC
  /* Init livavcodec */
  av_log_set_level (AV_LOG_ERROR);

  avcodec_register_all ();

  avcodec_init();

  wmv3_avdecoder = avcodec_find_decoder_by_name("wmv3");

#endif

  // Create the wrapping commands in the Webcamsn namespace linked to custom functions with a NULL clientdata and 
  // no deleteproc inside the current interpreter
  Tcl_CreateObjCommand(interp, "::Webcamsn::NewEncoder", Webcamsn_NewEncoder,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Webcamsn::NewDecoder", Webcamsn_NewDecoder,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Webcamsn::Decode", Webcamsn_Decode,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL); 
  Tcl_CreateObjCommand(interp, "::Webcamsn::Encode", Webcamsn_Encode,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Webcamsn::SetQuality", Webcamsn_SetQuality,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Webcamsn::GetWidth", Webcamsn_GetWidth,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL); 
  Tcl_CreateObjCommand(interp, "::Webcamsn::GetHeight", Webcamsn_GetHeight,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Webcamsn::GetQuality", Webcamsn_GetQuality,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "::Webcamsn::Close", Webcamsn_Close,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL); 
  Tcl_CreateObjCommand(interp, "::Webcamsn::NumberOfOpenCodecs", Webcamsn_Count,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL); 
  Tcl_CreateObjCommand(interp, "::Webcamsn::NbFrames", Webcamsn_Frames,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL); 

  Tcl_CreateObjCommand(interp, "::Webcamsn::CreateHashFromKid", Webcamsn_KidHash,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL); 

  // end of Initialisation
  return TCL_OK;
}

int Webcamsn_SafeInit (Tcl_Interp *interp) {
  return Webcamsn_Init(interp);
}

