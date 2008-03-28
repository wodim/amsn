OBJS-webcamsn := $(webcamsn_dir)/src/webcamsn.o $(webcamsn_dir)/src/kidhash.o \
		 $(webcamsn_dir)/src/libmimic.a
TARGETS-webcamsn := $(webcamsn_dir)/src/webcamsn.$(SHLIB_EXTENSION) 

OBJS-ffmpeg += $(webcamsn_dir)/src/ffmpeg/libavcodec/libavcodec.a \
		 $(webcamsn_dir)/src/ffmpeg/libavutil/libavutil.a

OBJS-wmv3_dec := $(webcamsn_dir)/src/wmv3_dec.o  
TARGETS-wmv3_dec := $(webcamsn_dir)/src/wmv3_dec

OBJS-wmv3_enc := $(webcamsn_dir)/src/wmv3_enc.o  
TARGETS-wmv3_enc := $(webcamsn_dir)/src/wmv3_enc


ifeq ($(HAVE_LIBAVCODEC),yes)

wmv3_dec : $(TARGETS-wmv3_dec)
	
$(TARGETS-wmv3_dec): $(OBJS-wmv3_dec) $(OBJS-ffmpeg)
	@$(echo_link_app)
	@$(link_app)

clean-wmv3_dec::
	rm -f $(TARGETS-wmv3_dec) $(OBJS-wmv3_dec)


wmv3_enc : $(TARGETS-wmv3_enc)
	
$(TARGETS-wmv3_enc): $(OBJS-wmv3_enc) $(OBJS-ffmpeg)
	@$(echo_link_app)
	@$(link_app)

clean-wmv3_enc::
	rm -f $(TARGETS-wmv3_enc) $(OBJS-wmv3_enc)

clean:: clean-wmv3_dec clean-wmv3_enc

DEPS-webcamsn := $(OBJS-webcamsn) $(OBJS-ffmpeg)
else
DEPS-webcamsn := $(OBJS-webcamsn)
endif

OBJS-mimic := 	$(webcamsn_dir)/src/bitstring.o  $(webcamsn_dir)/src/deblock.o  $(webcamsn_dir)/src/encode.o \
		$(webcamsn_dir)/src/idct_dequant.o $(webcamsn_dir)/src/mimic.o \
		$(webcamsn_dir)/src/vlc_decode.o  $(webcamsn_dir)/src/colorspace.o  $(webcamsn_dir)/src/decode.o   \
		$(webcamsn_dir)/src/fdct_quant.o  $(webcamsn_dir)/src/vlc_common.o  $(webcamsn_dir)/src/vlc_encode.o

TARGETS-mimic := $(webcamsn_dir)/src/libmimic.a


$(TARGETS-mimic): $(OBJS-mimic)
	@$(echo_ar_lib)
	@$(ar_lib)


$(TARGETS-webcamsn): $(DEPS-webcamsn)

all:: $(TARGETS-webcamsn)

clean:: clean-webcamsn

clean-webcamsn::
	rm -f $(TARGETS-webcamsn) $(OBJS-webcamsn)

