
if { $initialize_amsn == 1 } {
    global lang_list langenc langlong

    set lang_list [list]
    set langenc "iso8859-1"
    set langlong "English"
}

proc scan_languages {} {
   global lang_list
   set lang_list [list]

   set file_id [open "langlist" r]
   fconfigure $file_id -encoding utf-8


   while {[gets $file_id tmp_data] != "-1"} {
      set pos [string first " " $tmp_data]
      set langshort [string range $tmp_data 0 [expr {$pos -1}]]
      set pos [expr {$pos + 1}]
      set pos2 [string first " " $tmp_data $pos]
      set langenc [string range $tmp_data $pos [expr {$pos2 -1}]]
      set langlong [string range $tmp_data [expr {$pos2 +1}] [string length $tmp_data]]
      lappend lang_list "{$langshort} {$langlong} {$langenc}"
   }
   close $file_id

}

proc detect_language { {default "en"} } {
	global env
	if { ![info exists env(LANG)] } {
		status_log "No LANG environment variable. Using $default\n"
		return $default
	}
	
	set system_language [string tolower $env(LANG)]
	set idx [string first "@" $system_language]
	status_log "System language is $system_language\n"
	#Remove @euro thing or similar
	if { $idx != -1 } {
		incr idx -1
		set system_language [string range $system_language 0 $idx]
		status_log "Removed @ thing. Now system language is $system_language\n"
	}
	
	set language [language_in_list $system_language]
	if { $language != 0 } {
		status_log "Matching language $language!\n"
		return $language
	}
	
	set idx [string first "_" $system_language]
	#Remove _variant thing, like BR in pt_BR
	if { $idx != -1 } {
		incr idx -1
		set system_language [string range $system_language 0 $idx]
		status_log "Removed _ variant. Now system language is $system_language\n"
	}
	
	set language [language_in_list $system_language]
	if { $language != 0 } {
		status_log "Matching language $language!\n"
		return $language
	}
	status_log "NO matching language. Defaulting to $default\n"	
	return $default
}

proc language_in_list { lang_name } {
	global lang_list
	
	if {![info exists lang_list]} {
		scan_languages
	}
	
	foreach lang_desc $lang_list {
		set lang_short [string tolower [lindex $lang_desc 0]]
		if {[string compare $lang_short $lang_name] == 0 } {
			status_log "Language \"$lang_name\" is in available languages, using it\n" blue
			return [lindex $lang_desc 0]
		}
		
	}
	
	return 0
}

proc trans {msg args} {
	global lang
	for {set i 1} {$i <= [llength $args]} {incr i} {
		set $i [lindex $args [expr {$i-1}]]
	}
	if {[ catch {
			if { [string length $lang($msg)] > 0 } {
				return [subst -nocommands $lang($msg)]
			} else {
				if {[llength $args]>0} {
					return "$msg $args"
				} else {
					return "$msg"
				}
			}
		}  res] == 1} {
		if {[llength $args]>0} {
			return "$msg $args"
		} else {
			return "$msg"
		}
	} else {
		return $res
	}

}


#Lectura del idioma
proc load_lang { {langcode "en"} {plugindir ""} } {
   global lang lang_list langenc langlong

   if {[string equal $plugindir ""]} { set plugindir "lang" }
   if { [catch {set file_id [open "[file join $plugindir lang$langcode]" r]}] } {
   	return 0
   }

   set langenc ""

   foreach langdata $lang_list {
   	if { [string compare [lindex $langdata 0] $langcode] == 0 } {
	  set langenc [lindex $langdata 2]
	  set langlong [lindex $langdata 1]
	}
   }

   fconfigure $file_id -encoding $langenc

   gets $file_id tmp_data
   if {$tmp_data != "amsn_lang_version 2"} {	;# config version not supported!
      return 1
   }

   while {[gets $file_id tmp_data] != "-1"} {
      #If line is a comment, skip
      if {[string range $tmp_data 0 0] == "#"} {
          continue
      }
      set pos [string first " " $tmp_data]
      
      #Remove comments at end of line
      set posend [string first "#" $tmp_data]
      if { $posend == -1 } {
          set posend [expr {[string length $tmp_data]-1}]
      } else {
         incr posend -1
	  while {[string range $tmp_data $posend $posend] == " "} {
	  	incr posend -1
	  }
      }
      set l_msg [string range $tmp_data 0 [expr {$pos -1}]]
      set l_trans [string range $tmp_data [expr {$pos +1}] $posend]
      if { ![info exists lang($l_msg)] && ![string equal $plugindir "lang"] } {
      	  set lang($l_msg) $l_trans
      } elseif { [string equal $plugindir "lang"] } {
      	  set lang($l_msg) $l_trans
      }
   }
   close $file_id
   return 0
}

proc get_language_encodage { lang } {

	global lang_list

	foreach langdata $lang_list {
		if { "lang[lindex $langdata 0]" == $lang } {
			set langenc [lindex $langdata 2]
		}
	}

	return $langenc

}

proc get_available_language {} {

	global lang_list

	set dir "[pwd]/lang"

	set available [list]

	foreach lang $lang_list {
		set file [lindex $lang 0]
		if { [file exists "$dir/lang$file"] } {
			lappend available $file
		}
	}

	set available_lang_list $available
}


proc getlanguage { lang selection } {

	global lang_list weburl

	set dir "[pwd]/lang"

	set fid [open "[file join ${dir} $lang]" w]

	fconfigure $fid -encoding "[get_language_encodage $lang]"

	set token [::http::geturl "http://cvs.sourceforge.net/viewcvs.py/*checkout*/amsn/msn/lang/$lang?rev=HEAD&content-type=text" -timeout 10000]
	set content [::http::data $token]

	puts -nonewline $fid "$content"

	close $fid

	catch {
		.langmanager.selection.box itemconfigure $selection -background #DDF3FE
		language_manager_selected
	}
	

}


proc deletelanguage { lang selection } {
	
	set dir "[pwd]/lang"

	file delete "$dir/$lang"

	catch {
		.langmanager.selection.box itemconfigure $selection -background #FFFFFF
		language_manager_selected
	}
}


proc language_manager { } {

	global lang_list

	set available [get_available_language]

	set w ".langmanager"
	
	if {[winfo exists $w]} {
		raise $w
		return
	}

	toplevel $w
	wm title $w "[trans langmanager]"
	wm geometry $w 260x200+30+30

	label $w.text -text "[trans selectlanguage] :"

	pack configure $w.text -side top

	frame $w.selection -relief sunken -borderwidth 3
	listbox $w.selection.box -yscrollcommand "$w.selection.ys set" -font splainf -background white -relief flat -highlightthickness 0 -height 10
	scrollbar $w.selection.ys -command "$w.selection.box yview" -highlightthickness 0 -borderwidth 1 -elementborderwidth 2
	pack $w.selection.ys -side right -fill y
	pack $w.selection.box -side left -expand true -fill both
	
	foreach lang $lang_list {
		set langcode [lindex $lang 0]
		set langname [lindex $lang 1]
		$w.selection.box insert end "$langname"
		if { [lsearch $available $langcode] != -1 } {
			$w.selection.box itemconfigure end -background #DDF3FE
		} else {
			$w.selection.box itemconfigure end -background #FFFFFF
		}
	}

	bind $w.selection.box <<ListboxSelect>> "language_manager_selected"

	frame $w.command
	button $w.command.load -text "[trans load]" -command "language_manager_load" -state disabled
	button $w.command.close -text "[trans close]" -command "destroy $w"
	pack configure $w.command.load -side top
	pack configure $w.command.close -side bottom

	pack configure $w.selection -side left -fill y
	pack configure $w.command -side right
}	

proc language_manager_selected { } {

	global lang_list

	set w ".langmanager"

	set selection [$w.selection.box curselection]
	set langcode [lindex [lindex $lang_list $selection] 0]

	set available [get_available_language]

	if {[lsearch $available $langcode] != -1 } {
		$w.command.load configure -state normal -text "[trans unload]" -command "[list deletelanguage "lang$langcode" $selection]"
	} else {
		$w.command.load configure -state normal -text "[trans load]" -command "[list getlanguage "lang$langcode" $selection]"
	}

}

