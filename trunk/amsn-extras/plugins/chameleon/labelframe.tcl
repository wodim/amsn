namespace eval ::chameleon::labelframe {
    proc labelframe_customParseConfArgs {w parsed_options args } {
	array set options $args
	array set ttk_options $parsed_options
	
  	set padx 0
 	if { [info exists options(-padx)] &&
 	     [string is digit -strict $options(-padx)]  } {
 	    set padx $options(-padx)
 	}
 	set pady 0
 	if { [info exists options(-pady)] &&
 	     [string is digit -strict $options(-pady)] } {
 	    set pady $options(-pady)
 	}
 	if {$padx == 0 && $pady == 0 && 
 	    [info exists options(-bd)] } {
 	    set ttk_options(-padding) $options(-bd)
 	} else {
 	    if {$padx == 0 && $pady != 0 } {
 		set ttk_options(-padding) [list 2 $pady]
 	    } elseif {$padx != 0 && $pady == 0 } {
 		set ttk_options(-padding) [list $padx 2]
 	    } elseif {$padx != 0 && $pady != 0 } {
 		set ttk_options(-padding) [list $padx $pady]
 	    }
 	}
	
	if { [info exists options(-width)] } {
	    if {$options(-width) == 0} {
		set ttk_options(-width) [list]
	    } else {
		set ttk_options(-width) $options(-width)
	    }
	}
	if { [info exists options(-height)] } {
	   if {$options(-height) == 0} {
	       set ttk_options(-height) [list]
	   } else {
	       set ttk_options(-height) $options(-height)
	   }
	}
	
	return [array get ttk_options]
    }

    proc init_labelframeCustomOptions { } {
	variable labelframe_widgetOptions
	
 	array set labelframe_widgetOptions {
	    -background -styleOption
	    -bg -styleOption
	    -bd -styleOption
	    -borderwidth -styleOption
	    -border  -styleOption
	    -class -class
	    -colormap -ignore
	    -container -ignore
	    -cursor -cursor
	    -fg -styleOption
	    -font -styleOption
	    -foreground -styleOption
	    -height -toImplement
	    -highlightbackground -ignore
	    -highlightcolor  -ignore
	    -highlightthickness  -ignore
	    -labelanchor -labelanchor 
	    -labelwidget -labelwidget 
	    -padx -toImplement
	    -pady -toImplement
	    -relief -styleOption
	    -takefocus -takefocus
	    -text -text
	    -visual -ignore
	    -width -toImplement
	}
    }

    proc labelframe_customCget { w option } {
	set padding [$w cget -padding]
	if { [llength $padding] > 0 } {
 	    set padx [lindex $padding 0]
 	    set pady [lindex $padding 1]
	}
	if { $option == "-padx" && [info exists padx] } {
	    return $padx
	}
	if { $option == "-pady" && [info exists pady] } {
	    return $pady
	}

	if {$option == "-width"} {
	    set width [$w cget -width]
	    if {![string is digit -strict $width]} {
		return 0
	    } else {
		return $width
	    }
	}

	if {$option == "-height"} {
	    set height [$w cget -height]
	    if {![string is digit -strict $height]} {
		return 0
	    } else {
		return $height
	    }
	}


	return ""

    }

}