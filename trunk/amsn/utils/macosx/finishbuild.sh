#!/bin/sh
# Based aMSN Build script by David Luyer (http://www.luyer.net/osx/).

# See if we are running the script from the amsn dir, or inside utils/macosx.
if [ -z $(pwd | grep utils) ]; then
	UTILS_PATH=`dirname $0`
else
	UTILS_PATH=".."
fi

# Copy the built in the files to the right places.
echo "Renaming built libraries to have correct extension."
mv ${UTILS_PATH}/webcamsn/webcamsn.so ${UTILS_PATH}/macosx/webcamsn/webcamsn.dylib
mv ${UTILS_PATH}/TkCximage/TkCximage.so ${UTILS_PATH}/macosx/TkCximage/TkCximage.dylib
mv ${UTILS_PATH}/tcl_siren/tcl_siren.so ${UTILS_PATH}/tcl_siren/tcl_siren.dylib

# Fix bindings to aMSN internal Tcl/Tk versions.
echo "Fixing bindings to use embedded tcltk & libpng & libjpeg."
for file in `find ${UTILS_PATH} -name *.dylib`
do
        install_name_tool -change /Library/Frameworks/Tk.framework/Versions/8.4/Tk \
                @executable_path/../Frameworks/Tk.framework/Versions/8.4/Tk "$file"
        install_name_tool -change /System/Library/Frameworks/Tk.framework/Versions/8.4/Tk \
                @executable_path/../Frameworks/Tk.framework/Versions/8.4/Tk "$file"
        install_name_tool -change /Library/Frameworks/Tcl.framework/Versions/8.4/Tcl \
                @executable_path/../Frameworks/Tcl.framework/Versions/8.4/Tcl "$file"
        install_name_tool -change /System/Library/Frameworks/Tcl.framework/Versions/8.4/Tcl \
                @executable_path/../Frameworks/Tcl.framework/Versions/8.4/Tcl "$file"
		install_name_tool -change  /usr/local/lib/libpng.3.dylib \
			@executable_path/../lib/libpng.3.dylib "$file"
		install_name_tool -change /usr/local/lib/libjpeg.62.dylib \
			@executable_path/../lib/libjpeg.62.dylib "$file"
done

echo "Done."
