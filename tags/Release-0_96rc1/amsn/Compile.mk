#
# some rules to compile stuff ...
#
# (c) 2002 Gerd Knorr <kraxel@bytesex.org>
#
# main features:
#  * autodependencies via "cpp -MD"
#  * fancy, non-verbose output
#
# This file is public domain.  No warranty.  If it breaks you keep
# both pieces.
#
########################################################################

# verbose yes/no
verbose		?= no

# dependency files

compile_c	= $(CC) $(CFLAGS)  -c -o $@ $<
compile_cc	= $(CXX) $(CXXFLAGS)  -c -o $@ $<

ifeq ($(FOUND_OS),mac)
SHARED	:= -dynamiclib -fno-common
else
SHARED	:= -shared
endif

link_app	= $(CC) $(LDFLAGS) -o $@  $^ $(LDLIBS)
link_so		= $(CC) $(LDFLAGS) $(SHARED) -o $@ $^ $(LDLIBS)
link_so_addlibs = $(link_so) $(ADDLIBS)
link_so_cpp	= $(CXX) $(LDFLAGS) $(SHARED) -o $@ $^ $(LDLIBS) $(CXX_LIB)
ar_lib		= rm -f $@ && ar -sr $@ $^ && ranlib $@


# non-verbose output
ifeq ($(verbose),no)
  echo_compile_c	= echo "  CC	 " $@
  echo_compile_cc	= echo "  CXX	 " $@
  echo_link_app		= echo "  LD	 " $@
  echo_link_so		= echo "  LD	 " $@
  echo_link_so_cpp	= echo "  LDX	 " $@
  echo_link_so_addlibs	= echo "  LD	 " $@
  echo_ar_lib		= echo "  AR	 " $@
else
  echo_compile_c	= echo $(compile_c)
  echo_compile_cc	= echo $(compile_cc)
  echo_link_app		= echo $(link_app)
  echo_link_so		= echo $(link_so)
  echo_link_so_addlibs	= echo $(link_so_addlibs)
  echo_link_so_cpp	= echo $(link_so_cpp)
  echo_ar_lib		= echo $(ar_lib)
endif

%.o: %.c
	@$(echo_compile_c)
	@$(compile_c)

%.cc.o: %.cc
	@$(echo_compile_cc)
	@$(compile_cc)

%.cpp.o: %.cpp
	@$(echo_compile_cc)
	@$(compile_cc)

%.cpp.so: %.cpp.o
	@$(echo_link_so_cpp)
	@$(link_so_cpp)

%.so: %.o
	@$(echo_link_so)
	@$(link_so)

%.a: %.o
	@$(echo_ar_lib)
	@$(ar_lib)

%: %.o
	@$(echo_link_app)
	@$(link_app)
