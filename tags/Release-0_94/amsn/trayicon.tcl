if { $initialize_amsn == 1 } {
    global statusicon mailicon systemtray_exist iconmenu ishidden

    set statusicon 0
    set mailicon 0
    set systemtray_exist 0
    set iconmenu 0
    set ishidden 0
}

proc iconify_proc {} {
	global statusicon systemtray_exist
	if { [focus] == "."} {
		wm iconify .
		wm state . withdrawn
	} else {
		wm deiconify .
		wm state . normal
		raise .
		focus -force .
	}
	#bind $statusicon <Button-1> deiconify_proc
}

proc taskbar_icon_handler { msg x y } {
	global iconmenu ishidden

	if { [winfo exists .bossmode] } {
		if { $msg=="WM_LBUTTONDBLCLK" } {
			wm state .bossmode normal
			focus -force .bossmode
		}
		return
	}

	if { $msg=="WM_RBUTTONUP" } {
		#tk_popup $iconmenu $x $y

		#workaround for bug with the popup not unposting
		wm state .trayiconwin normal
		wm geometry .trayiconwin "+0+[expr 2 * [winfo screenheight .]]"
		focus -force .trayiconwin

		tk_popup $iconmenu [expr "$x + 85"] [expr "$y - 11"] [$iconmenu index end]

		#workaround for bug with the popup not unposting
		wm state .trayiconwin withdrawn
	}
	if { $msg=="WM_LBUTTONDBLCLK" } {
		if { $ishidden == 0 } {
			#wm iconify .
			if { [wm state .] == "zoomed" } {
				set ishidden 2
			} else {
				set ishidden 1
			}
			wm state . withdrawn
			#set ishidden 1
		} else {
			#wm deiconify .
			#wm state . normal
			#raise .
			if { $ishidden == 2 } {
				wm state . zoomed
			} else {
				wm state . normal
			}
			focus -force .
			set ishidden 0
		}
	}
}

proc trayicon_init {} {
	global systemtray_exist password iconmenu wintrayicon statusicon

	if { [::config::getKey dock] == 4 } {
		#added to stop creation of more than 1 icon
		if { $statusicon != 0 } {
			return
		}
		set ext "[file join plugins winico05.dll]"
		if { [file exists $ext] != 1 } {
			msg_box "[trans needwinico]"
			close_dock
			::config::setKey dock 0
			return
		}
		if { [catch {load $ext winico}] }	{
			::config::setKey dock 0
			close_dock
			return
		}
		set systemtray_exist 1
		set wintrayicon [winico create [GetSkinFile winicons msn.ico]]
		winico taskbar add $wintrayicon -text "[trans offline]" -callback "taskbar_icon_handler %m %x %y"
		set statusicon 1
	} else {
		set ext "[file join plugins traydock libtray.so]"
		if { ![file exists $ext] } {
			::config::setKey dock 0
			msg_box "[trans traynotcompiled]"
			close_dock
			return
		}

		if { $systemtray_exist == 0 && [::config::getKey dock] == 3} {
			if { [catch {load $ext Tray}] }	{
				::config::setKey dock 0
				close_dock
				return
			}
	
			set  systemtray_exist [systemtray_exist]; #a system tray exist?
		}
	}

	#workaround for bug with the popup not unposting
	destroy .trayiconwin
	toplevel .trayiconwin -class Amsn
	wm geometry .trayiconwin "+0+[expr 2 * [winfo screenheight .]]"
	wm state .trayiconwin withdrawn
	destroy .trayiconwin.immain
	set iconmenu .trayiconwin.immain

	#destroy .immain
	#set iconmenu .immain
	menu $iconmenu -tearoff 0 -type normal

	menu $iconmenu.imstatus -tearoff 0 -type normal
	$iconmenu.imstatus add command -label [trans online] -command "ChCustomState NLN"
	$iconmenu.imstatus add command -label [trans noactivity] -command "ChCustomState IDL"
	$iconmenu.imstatus add command -label [trans busy] -command "ChCustomState BSY"
	$iconmenu.imstatus add command -label [trans rightback] -command "ChCustomState BRB"
	$iconmenu.imstatus add command -label [trans away] -command "ChCustomState AWY"
	$iconmenu.imstatus add command -label [trans onphone] -command "ChCustomState PHN"
	$iconmenu.imstatus add command -label [trans gonelunch] -command "ChCustomState LUN"
	$iconmenu.imstatus add command -label [trans appearoff] -command "ChCustomState HDN"

	$iconmenu add command -label "[trans offline]"
	$iconmenu add separator
	if { [string length [::config::getKey login]] > 0 } {
	     if {$password != ""} {
	        #$iconmenu add command -label "[trans login] [::config::getKey login]" -command "::MSN::connect" -state normal
	     } else {
	     	#$iconmenu add command -label "[trans login] [::config::getKey login]" -command cmsn_draw_login -state normal
	     }
	} else {
	     #$iconmenu add command -label "[trans login]" -command "::MSN::connect" -state disabled
	}
	#$iconmenu add command -label "[trans login]..." -command cmsn_draw_login
  	$iconmenu add command -label "[trans logout]" -command "::MSN::logout" -state disabled
	$iconmenu add command -label "[trans changenick]..." -command cmsn_change_name -state disabled
	$iconmenu add separator
   	$iconmenu add command -label "[trans sendmsg]..." -command  [list ::amsn::ShowSendMsgList [trans sendmsg] ::amsn::chatUser ] -state disabled
   	$iconmenu add command -label "[trans sendmail]..." -command [list ::amsn::ShowSendEmailList [trans sendmail] launch_mailer] -state disabled
   	#$iconmenu add command -label "[trans checkver]..." -command "check_version"
	$iconmenu add separator
#	$iconmenu add command -label "[trans mystatus]" -state disabled
#	$iconmenu add command -label "   [trans online]" -command "ChCustomState NLN" -state disabled
#	$iconmenu add command -label "   [trans noactivity]" -command "ChCustomState IDL" -state disabled
#	$iconmenu add command -label "   [trans busy]" -command "ChCustomState BSY" -state disabled
#	$iconmenu add command -label "   [trans rightback]" -command "ChCustomState BRB" -state disabled
#	$iconmenu add command -label "   [trans away]" -command "ChCustomState AWY" -state disabled
#	$iconmenu add command -label "   [trans onphone]" -command "ChCustomState PHN" -state disabled
#	$iconmenu add command -label "   [trans gonelunch]" -command "ChCustomState LUN" -state disabled
#	$iconmenu add command -label "   [trans appearoff]" -command "ChCustomState HDN" -state disabled
	$iconmenu add cascade -label "[trans mystatus]" -menu $iconmenu.imstatus -state disabled
	$iconmenu add separator
	$iconmenu add command -label "[trans close]" -command "close_cleanup;exit"
	CreateStatesMenu .my_menu

	## set icon to current status if added icon while already logged in
	if { [::MSN::myStatusIs] != "FLN" } {
		statusicon_proc [::MSN::myStatusIs]
		mailicon_proc [::hotmail::unreadMessages]
	}
}

proc statusicon_proc {status} {
	global systemtray_exist statusicon list_states iconmenu wintrayicon tcl_platform
	set cmdline ""

	if { [::config::getKey dock] != 4 } {

		set icon .si
		if { $systemtray_exist == 1 && $statusicon == 0 && [::config::getKey dock] == 3} {
			set pixmap "[GetSkinFile pixmaps doffline.xpm]"
			set statusicon [newti $icon -pixmap $pixmap -tooltip offline]
			bind $icon <Button1-ButtonRelease> iconify_proc
			bind $icon <Button3-ButtonRelease> "tk_popup $iconmenu %X %Y"
		}
	}

	set my_name [::abook::getPersonal nick]
   	
	if { $systemtray_exist == 1 && $statusicon != 0 && $status == "REMOVE" } {
		if {$tcl_platform(platform) == "windows"} {
			winico taskbar delete $wintrayicon
		} else {
			remove_icon $statusicon
		}
		set statusicon 0
	} elseif {$systemtray_exist == 1 && $statusicon != 0 && ( [::config::getKey dock] == 3 || [::config::getKey dock] == 4 ) && $status != "REMOVE"} {
		if { $status != "" } {
			if { $status == "FLN" } {
				$iconmenu entryconfigure 2 -state disabled
				$iconmenu entryconfigure 3 -state disabled
				$iconmenu entryconfigure 5 -state disabled
				$iconmenu entryconfigure 6 -state disabled
				$iconmenu entryconfigure 8 -state disabled
#				$iconmenu entryconfigure 9 -state disabled
#				$iconmenu entryconfigure 10 -state disabled
#				$iconmenu entryconfigure 11 -state disabled
#				$iconmenu entryconfigure 12 -state disabled
#				$iconmenu entryconfigure 13 -state disabled
#				$iconmenu entryconfigure 14 -state disabled
#				$iconmenu entryconfigure 15 -state disabled
#				$iconmenu entryconfigure 16 -state disabled 
#				
#				for {set id 17} {$id <= ([StateList size] + 16) } { incr id 1 } {
#					$iconmenu entryconfigure $id -state disabled
#					if { $id == 20 } { break }
#				}

			} else {
				$iconmenu entryconfigure 2 -state normal
				$iconmenu entryconfigure 3 -state normal
				$iconmenu entryconfigure 5 -state normal
				$iconmenu entryconfigure 6 -state normal
				$iconmenu entryconfigure 8 -state normal
#				$iconmenu entryconfigure 9 -state normal
#				$iconmenu entryconfigure 10 -state normal
#				$iconmenu entryconfigure 11 -state normal
#				$iconmenu entryconfigure 12 -state normal
#				$iconmenu entryconfigure 13 -state normal
#				$iconmenu entryconfigure 14 -state normal
#				$iconmenu entryconfigure 15 -state normal
#				$iconmenu entryconfigure 16 -state normal
#				
#				for {set id 17} {$id <= ([StateList size] + 16) } { incr id 1 } {
#					$iconmenu entryconfigure $id -state normal
#					if { $id == 20 } { break }
#				}
				
			}
				
			switch $status {
			  "FLN" {
				set pixmap "[GetSkinFile pixmaps doffline.xpm]"
				set tooltip "[trans offline]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons offline.ico]]
				}
			  }
			
			  "NLN" {
				set pixmap "[GetSkinFile pixmaps donline.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans online]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons online.ico]]
				}
			  }
			  
			  "IDL" {
				set pixmap "[GetSkinFile pixmaps dinactive.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans noactivity]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons inactive.ico]]
				}
			  }
			  "BSY" {
				set pixmap "[GetSkinFile pixmaps dbusy.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans busy]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons busy.ico]]
				}
			  }
			  "BRB" {
				set pixmap "[GetSkinFile pixmaps dbrb.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans rightback]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons brb.ico]]
				}
			  }
			  "AWY" {
				set pixmap "[GetSkinFile pixmaps daway.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans away]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons away.ico]]
				}
			  }
			  "PHN" {
				set pixmap "[GetSkinFile pixmaps dphone.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans onphone]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons phone.ico]]
				}
			  }
			  "LUN" {
				set pixmap "[GetSkinFile pixmaps dlunch.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans gonelunch]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons lunch.ico]]
				}
			  }
			  "HDN" {
				set pixmap "[GetSkinFile pixmaps dhidden.xpm]"
				set tooltip "$my_name ([::config::getKey login]): [trans appearoff]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons hidden.ico]]
				}
			  }
			  "BOSS" {   #for bossmode, only for win at the moment
				#set pixmap "[GetSkinFile pixmaps doffline.xpm]"
				set tooltip "[trans pass]"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons bossmode.ico]]
				}
			  }
			  default {
				set pixmap "null"
				if { [::config::getKey dock] == 4 } {
					set trayicon [winico create [GetSkinFile winicons msn.ico]]
				}
			  }
			}

			$iconmenu entryconfigure 0 -label "[::config::getKey login]"

			if { [::config::getKey dock] != 4 } {
				if { $pixmap != "null"} {
					configureti $statusicon -pixmap $pixmap -tooltip $tooltip
				}
			} else {
				if { ![winfo exists .bossmode] || $status == "BOSS" } {
					#skip if in bossmode and not setting to BOSS
					winico taskbar delete $wintrayicon
					set wintrayicon $trayicon
					winico taskbar add $wintrayicon -text $tooltip -callback "taskbar_icon_handler %m %x %y"
				}
			}

		}
	}
}

proc taskbar_mail_icon_handler { msg x y } {
	global password

	if { [winfo exists .bossmode] } {
		if { $msg=="WM_LBUTTONDBLCLK" } {
			wm state .bossmode normal
			focus -force .bossmode
		}
		return
	}

	if { $msg=="WM_LBUTTONUP" } {
		hotmail_login [::config::getKey login] $password
	}
}

proc mailicon_proc {num} {
	# Workaround for bug in the traydock-plugin - statusicon added - BEGIN
	global systemtray_exist mailicon statusicon password winmailicon tcl_platform
	# Workaround for bug in the traydock-plugin - statusicon added - END
	set icon .mi
	if {$systemtray_exist == 1 && $mailicon == 0 && ([::config::getKey dock] == 3 || [::config::getKey dock] == 4)  && $num >0} {
		set pixmap "[GetSkinFile pixmaps unread.gif]"
		if { $num == 1 } {
			set msg [trans onenewmail]
		} elseif { $num == 2 } {
			set msg [trans twonewmail 2]
		} else {
			set msg [trans newmail $num]
		}

		if { [::config::getKey dock] != 4 } {
			set mailicon [newti $icon -pixmap $pixmap -tooltip $msg]
			bind $icon <Button-1> [list hotmail_login [::config::getKey login] $password]
		} else {
			set winmailicon [winico create [GetSkinFile winicons unread.ico]]
			winico taskbar add $winmailicon -text $msg -callback "taskbar_mail_icon_handler %m %x %y"
			set mailicon 1
		}

	} elseif {$systemtray_exist == 1 && $mailicon != 0 && $num == 0} {
		if { $tcl_platform(platform) != "windows" } {
			remove_icon $mailicon
			set mailicon 0
		} else {
			winico taskbar delete $winmailicon
			set mailicon 0
		}
	} elseif {$systemtray_exist == 1 && $mailicon != 0 && ([::config::getKey dock] == 3 || [::config::getKey dock] == 4)  && $num > 0} {
		if { $num == 1 } {
			set msg [trans onenewmail]
		} elseif { $num == 2 } {
			set msg [trans twonewmail 2]
		} else {
			set msg [trans newmail $num]
		}
		if { [::config::getKey dock] != 4 } {
			configureti $mailicon -tooltip $msg
		} else {
			winico taskbar modify $winmailicon -text $msg
		}
	} 
}

proc remove_icon {icon} {
	global systemtray_exist
	if {$systemtray_exist == 1 && $icon != 0} {
		catch {removeti $icon}
#                destroy $icon
	}
}

proc restart_tray { } {

    puts "RESTARTING the traydock"

    statusicon_proc "REMOVE"
    statusicon_proc [::MSN::myStatusIs]
    
}
		
		
	
	
