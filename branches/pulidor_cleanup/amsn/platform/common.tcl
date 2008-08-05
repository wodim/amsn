

################################################
# Functions to know which platform we're on    #
################################################

#Test for Aqua GUI
proc OnMac {} {
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
		return 1
	} else {
		return 0
	}
}

#Test for Darwin OS
#Will return 1 for X11 on Mac, OnMac returns 0 in that case
proc OnDarwin {} {
	global tcl_platform
	if { $tcl_platform(os) == "Darwin" } {
		return 1
	} else {
		return 0
	}
}

#Test for Windows
proc OnWin {} {
	global tcl_platform
	if { $tcl_platform(platform) == "windows" } {
		return 1
	} else {
		return 0
	}
}

#Test for Windows Vista
proc OnWinVista {} {
	global tcl_platform
	if { [OnWin] && $tcl_platform(os) == "Windows NT" && $tcl_platform(osVersion) == "6.0" } {
		return 1
	} else {
		return 0
	}
}

#Test for BSD
proc OnBSD {} {
	global tcl_platform
	if { $tcl_platform(os) == "OpenBSD" || 
             $tcl_platform(os) == "FreeBSD" ||
             $tcl_platform(os) == "NetBSD"} {
		return 1
	} else {
		return 0
	}
}

#Test for Linux
proc OnLinux {} {
	global tcl_platform
	if { $tcl_platform(os) == "Linux" } {
		return 1
	} elseif { $tcl_platform(os) == "SunOS" } {
		# Really not correct at all, but closer than BSD.
		return 1
	} else {
		return 0
	}
}

#Test for Unix platform (Linux/Mac/*BSD/etc.)
proc OnUnix {} {
	global tcl_platform
	if { $tcl_platform(platform) == "unix" } {
		return 1
	} else {
		return 0
	}
}

#Test for X11 windowing system
proc OnX11 {} {
	if { ![catch {tk windowingsystem} wsystem] && $wsystem  == "x11" } {
		return 1
	} else {
		return 0
	}
}


#####################################################
# Functions and variables that could be replaced    #
#####################################################

proc GetPlatformModifier {} {
	return "Control"
}

#Set default HOME path
set HOME [file join [pwd] amsn_config]
