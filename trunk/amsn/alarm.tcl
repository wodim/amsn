#!/usr/bin/wish
#########################################################
# alarm.tcl v 1.0	2002/07/21   BurgerMan
#########################################################


# Function that loads all alarm settings (usernames, paths and status) from a
# config file called alarms
proc load_alarms {} {
   global alarms HOME config


   if {([file readable "[file join ${HOME} alarms_${config(login)}]"] == 0) ||
       ([file isfile "[file join ${HOME}/alarms_${config(login)}]"] == 0)} {
	return 1
   }
   set file_id [open "${HOME}/alarms_${config(login)}" r]

   gets $file_id tmp_data
   if {$tmp_data != "amsn_alarm_version 1"} {	;# config version not supported!
      return 1
   }
   while {[gets $file_id tmp_data] != "-1"} {
      set var_data [split $tmp_data]
      set var_attribute [lindex $var_data 0]
      set var_value [lindex $var_data 1]
      set alarms($var_attribute) $var_value			
   }
   close $file_id
}

# Function that writes all alarm settings into a config file called alarms
proc save_alarms {} {
   global tcl_platform alarms HOME config

   if { ([info exists alarms]) && ([array size alarms] != 0) } {

	puts stdout [array size alarms]

	if {$tcl_platform(platform) == "unix"} {
		set file_id [open "[file join ${HOME} alarms_${config(login)}]" w 00600]
	} else {
	        set file_id [open "[file join ${HOME} alarms_${config(login)}]" w]
	}

	puts $file_id "amsn_alarm_version 1"

	set alarms_array [array get alarms]
	set items [llength $alarms_array]
	for {set idx 0} {$idx < $items} {incr idx 1} {
		set var_attribute [lindex $alarms_array $idx]; incr idx 1
		set var_value [lindex $alarms_array $idx]
		puts $file_id "$var_attribute $var_value"
	}
	close $file_id
	unset alarms 
   
   } else {
	catch { exec rm [file join ${HOME} alarms_${config(login)}] } res
   }
}

#Function that displays the Alarm configuration for the given user
proc alarm_cfg { user } {
   global alarms sounds_folder my_alarms images_folder 

   if { [ winfo exists .alarm_cfg ] } {
        return
   }

   if { [info exists alarms(${user})] } {
        set my_alarms(${user}) $alarms(${user})
	set my_alarms(${user}_sound) $alarms(${user}_sound)
	set my_alarms(${user}_sound_st) $alarms(${user}_sound_st)
	set my_alarms(${user}_pic) $alarms(${user}_pic)
	set my_alarms(${user}_pic_st) $alarms(${user}_pic_st)
	set my_alarms(${user}_loop) $alarms(${user}_loop)
   } else {
	set my_alarms(${user}) 1
	set my_alarms(${user}_sound) "${sounds_folder}/alarm.wav"
	set my_alarms(${user}_sound_st) 1
	set my_alarms(${user}_pic) "${images_folder}/alarm.gif"
	set my_alarms(${user}_pic_st) 1
   }

   toplevel .alarm_cfg
   wm title .alarm_cfg "[trans alarmpref] $user"
   wm iconname .alarm_cfg [trans alarmpref]   

   frame .alarm_cfg.sound
   LabelEntry .alarm_cfg.sound.entry "[trans soundfile]" my_alarms(${user}_sound) 30
   checkbutton .alarm_cfg.sound.button -text "[trans soundstatus]" -onvalue 1 -offvalue 0 -variable my_alarms(${user}_sound_st)
   checkbutton .alarm_cfg.sound.button2 -text "[trans soundloop]" -onvalue 1 -offvalue 0 -variable my_alarms(${user}_loop)
   pack .alarm_cfg.sound.entry .alarm_cfg.sound.button .alarm_cfg.sound.button2 -side left 
   pack .alarm_cfg.sound -side top -padx 4 -pady 4

   frame .alarm_cfg.pic
   LabelEntry .alarm_cfg.pic.entry "[trans picfile]" my_alarms(${user}_pic) 30
   checkbutton .alarm_cfg.pic.button -text "[trans picstatus]" -onvalue 1 -offvalue 0 -variable my_alarms(${user}_pic_st)
   pack .alarm_cfg.pic.entry .alarm_cfg.pic.button -side left
   pack .alarm_cfg.pic -side top -padx 4 -pady 4

   checkbutton .alarm_cfg.alarm -text "[trans alarmstatus]" -onvalue 1 -offvalue 0 -variable my_alarms(${user})
   pack .alarm_cfg.alarm

   frame .alarm_cfg.b -class Degt
   button .alarm_cfg.b.save -text [trans ok] -command "save_alarm_pref $user; destroy .alarm_cfg"
   button .alarm_cfg.b.cancel -text [trans close] -command "unset my_alarms; destroy .alarm_cfg" 
   button .alarm_cfg.b.delete -text [trans delete] -command "delete_alarm $user; destroy .alarm_cfg"
   pack .alarm_cfg.b.save .alarm_cfg.b.cancel .alarm_cfg.b.delete -side left
   pack .alarm_cfg.b -side top -padx 4 -pady 4
}

#Deletes variable settings for current user.
proc delete_alarm { user} {
   global alarms my_alarms
   if { [info exists alarms(${user})] } {
	unset alarms(${user}) alarms(${user}_sound) alarms(${user}_sound_st) alarms(${user}_pic) alarms(${user}_pic_st) alarms(${user}_loop)
   }
   unset my_alarms(${user}) my_alarms(${user}_sound) my_alarms(${user}_sound_st) my_alarms(${user}_pic) my_alarms(${user}_pic_st) my_alarms(${user}_loop)
}

#Saves alarm settings for current user on OK press.
proc save_alarm_pref { user } {
   global alarms my_alarms sounds_folder images_folder
   
   if { ($my_alarms(${user}_sound_st) == 1) && ([file exists "$my_alarms(${user}_sound)"] == 0) } {
	msg_box [trans invalidsound]
	return
   }

   if { ($my_alarms(${user}_pic_st) == 1) } {
	if { ([file exists "$my_alarms(${user}_pic)"] == 0) } {
		msg_box [trans invalidpic]
		return
   	} else {
		image create photo joanna -file $my_alarms(${user}_pic)
		if { ([image width joanna] > 300) && ([image height joanna] > 400) } {
	    		image delete joanna
	    		msg_box [trans invalidpicsize]
	    		return
		}
		image delete joanna
	}
   }

   set alarms(${user}) $my_alarms(${user})
   set alarms(${user}_loop) $my_alarms(${user}_loop)
   set alarms(${user}_sound_st) $my_alarms(${user}_sound_st)
   set alarms(${user}_pic_st) $my_alarms(${user}_pic_st)
   if { $my_alarms(${user}_sound) == "" } {
	set alarms(${user}_sound) "${sounds_folder}/alarm.wav"
   } else {
	set alarms(${user}_sound) $my_alarms(${user}_sound)
   }
   if { $my_alarms(${user}_pic) == "" } {
	set alarms(${user}_pic) "${sounds_folder}/alarm.wav"
   } else {
	set alarms(${user}_pic) $my_alarms(${user}_pic)
   }

   unset my_alarms
}

#Runs the alarm (sound and pic)
proc run_alarm {user name} {
   global alarms program_dir config
   
   toplevel .mainer
   wm title .mainer "[trans alarm] $user"
   label .mainer.txt -text "${name} [trans logsin]"
   pack .mainer.txt
   if { ($alarms(${user}_pic_st) == 1) } {
	image create photo joanna -file $alarms(${user}_pic)
	if { ([image width joanna] < 300) && ([image height joanna] < 400) } {
	label .mainer.jojo -image joanna
	pack .mainer.jojo
	}
   }

   if { $alarms(${user}_sound_st) == 1 } {
	if { $alarms(${user}_loop) == 1 } {
   	    button .mainer.stopmusic -text [trans stopalarm] -command { catch { eval exec killall jwakeup} res ; catch { eval exec killall $config(soundcommand) } res  ; destroy .mainer }
            pack .mainer.stopmusic -padx 2
	    catch { eval exec ${program_dir}/jwakeup $config(soundcommand) $alarms(${user}_sound) & } res
        } else {
	    catch { eval exec $config(soundcommand) $alarms(${user}_sound) & } res 
	    button .mainer.stopmusic -text [trans stopalarm] -command "catch { eval exec killall $config(soundcommand) } res ; destroy .mainer"
            pack .mainer.stopmusic -padx 2
  	}
      } else {
        button .mainer.stopmusic -text [trans stopalarm] -command "destroy .mainer"
        pack .mainer.stopmusic -padx 2
      }
 }
