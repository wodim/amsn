OBJS-aio := $(aio_dir)/src/aio.o
TARGETS-aio := $(aio_dir)/src/aio.$(SHLIB_EXTENSION) 

$(TARGETS-aio): $(OBJS-aio)

all:: $(TARGETS-aio)

clean:: clean-aio

clean-aio:: 
	rm -f $(TARGETS-aio) $(OBJS-aio)

