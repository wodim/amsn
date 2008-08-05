set HOME [file join $env(HOME) Library/Application\ Support/amsn]

proc GetPlatformModifier {} {
	if {[OnMac]} {
		return "Command"
	} else {
		return "Control"
	}
}


#///////////////////////////////////////////////////////////////////////////////
# if a button has a -image, -relief flat but not -overrelief, it will actually be created as a label
# this is a workaround for platforms like macos and tileqt which have a problem with buttons (like
# not honouring "-relief flat" (tileqt) or not supporting alpha transparancy(macos))
# TODO: add a bind that works as -command on a button (mousebutton press, move away, release does not trigger)
proc buttons2labels { } {
	if { [info commands ::tk::button2] == "" } { rename button ::tk::button2 }
	proc button { pathName args } {
		array set options $args
		if { [info exists options(-image)] && [info exists options(-relief)] && $options(-relief) == "flat" } {
			if { [info exists options(-command)] } {
				set command $options(-command)
				unset options(-command)
			}
			if { [info exists options(-overrelief)] } { unset options(-overrelief) }
			set ret [eval label [list $pathName] [array get options]]
			if { [info exists command] } {
				puts $command
				bind $pathName <<Button1>> "$command"
			}
		} else {
			set ret [eval ::tk::button2 [list $pathName] $args]
		}
		return $ret
	}
}

# apply buttons2labels on Mac, because there seem to be problems with buttons there
# TODO: as soon as it is fixed in tk on mac, make it version-conditional
if { [OnMac] } {
	buttons2labels
}
