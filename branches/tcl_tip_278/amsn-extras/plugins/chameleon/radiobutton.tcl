namespace eval ::chameleon::radiobutton {

   proc radiobutton_customParseConfArgs {w parsed_options args } {
     	array set options $args
	array set ttk_options $parsed_options

 	if { [info exists options(-bd)] } {
 	    set ttk_options(-padding) $options(-bd)
 	}
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
  
       if { ![info exists options(-variable)] } {
	       set options(-variable) "selectedButton"
       }
	   set varname [set options(-variable)]
	   set value ""
	   if { [info exists options(-value)] } {
		   set value $options(-value)
	   }
	   if { [string range $varname 0 1] != "::" } {
		   set varname "::$varname"
	   }

	   if { ![info exists $varname] } {
		   set $varname $value
	   }
	   set ttk_options(-variable) [set options(-variable)]
       return [array get ttk_options]
    }

    proc init_radiobuttonCustomOptions { } {
 	variable radiobutton_widgetOptions
 	variable radiobutton_widgetCommands 

 	array set radiobutton_widgetOptions {
	    -activebackground -styleOption
 	    -activeforeground -styleOption
 	    -anchor -ignore
 	    -background -styleOption
 	    -bg -styleOption
 	    -bitmap -ignore
 	    -borderwidth -styleOption
	    -border  -styleOption
 	    -bd -styleOption
 	    -compound -compound
 	    -cursor -cursor
 	    -disabledforeground -styleOption
 	    -font -styleOption
 	    -foreground -styleOption
 	    -fg -styleOption
 	    -highlightbackground -styleOption
 	    -highlightcolor -styleOption
 	    -highlightthickness -styleOption
 	    -image -image
 	    -justify -ignore
 	    -padx -toImplement
 	    -pady -toImplement
 	    -relief -styleOption
 	    -repeatdelay -ignore
 	    -repeatinterval -ignore
 	    -takefocus -takefocus
 	    -text -text
 	    -textvariable -textvariable
 	    -underline -underline
 	    -wraplength -ignore
 	    -command -command
 	    -height -ignore
 	    -indicatoron -ignore
 	    -selectcolor -styleOption
 	    -offrelief -styleOption
 	    -overrelief -styleOption
 	    -selectimage -ignore
 	    -state -state
 	    -value -value
 	    -variable -variable
 	    -width -toImplement
	}
	# ignoring -width because we need to map 0 to "" and "" to 0 in cget/configure
	
 	array set radiobutton_widgetCommands [list flash {1 {radiobutton_flash $w}} \
					     invoke {1 {$w invoke}} \
					     deselect {1 {radiobutton_deselect $w}} \
					     select {1 {radiobutton_select $w}} \
					     toggle {1 {radiobutton_toggle $w}}]
    
    }

    proc radiobutton_customCget { w option } {
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

	return ""
    }



     proc radiobutton_flash {w} {
 	if { [lsearch [$w state] active] != -1 } {
 	    set old_state "active"
 	} else {
 	    set old_state "!active"
 	}
	
 	radiobutton_flash_timer $w $old_state 0

     }
    
     proc radiobutton_flash_timer { w old_state i } {

 	if { $i >= $::chameleon::flash_count } {
 	    $w state $old_state
 	    return
 	}

 	if {[expr $i % 2] } {
 	    $w state active
 	} else {
 	    $w state !active
 	}
	
 	incr i
 	after 100 "::chameleon::radiobutton::radiobutton_flash_timer $w $old_state $i"
     }

     proc radiobutton_select {w} {
	upvar #0 [$w cget -variable] var
	set var [$w cget -onvalue]
     }

     proc radiobutton_deselect {w} {
	 upvar #0 [$w cget -variable] var
	 set var [$w cget -offline]
     }

     proc radiobutton_toggle {w} {
	  set on [w cget -onvalue]
	  set off [$w cget -offline]
	  set var [expr $var==$onvalue?$offvalue:$onvalue]
     }

}
