OBJS-TkCximage := $(tkcximage_dir)/src/TkCximage.cpp.o $(tkcximage_dir)/src/PhotoFormat.cpp.o \
		  $(tkcximage_dir)/src/procs.cpp.o $(tkcximage_dir)/src/CxImage/libCxImage.a

ifeq ($(STATIC),yes)
OBJS-TkCximage += libstdc++.a
endif

ifeq ($(FOUND_OS),mac)
  EXTRAOBJS-TkCximage := $(prefix)/lib/libpng.a $(prefix)/lib/libjpeg.a
endif

TARGETS-TkCximage := $(tkcximage_dir)/src/TkCximage.cpp.$(SHLIB_EXTENSION)

$(TARGETS-TkCximage):: $(OBJS-TkCximage) $(EXTRAOBJS-TkCximage)

all:: $(TARGETS-TkCximage)

clean:: clean-tkcximage

clean-tkcximage::
	rm -f $(TARGETS-TkCximage) $(OBJS-TkCximage)
