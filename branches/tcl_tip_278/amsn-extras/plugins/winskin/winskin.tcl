namespace eval ::winskin {
	variable config
	variable configlist
	variable skinned 0
	variable borderremoved 0
	variable dir
	variable dset 0

	proc Init { dir } {
		set ::winskin::dir $dir

		::plugins::RegisterPlugin winskin
		::plugins::RegisterEvent winskin ContactListColourBarDrawn draw
		::plugins::RegisterEvent winskin ContactListDrawn cldrawn
		::plugins::RegisterEvent winskin OnConnect connected
		::plugins::RegisterEvent winskin chatwininput buttonbarCreated
#		::plugins::RegisterEvent winskin chatmenu addMenuOption		

		array set ::winskin::config {
			usewinspecs {0}
			removeborder {1}
			addbuttons {1}
			resizetopright {1}
			hidescroll {0}
			hidemenu {1}
			removetop {0}
			removeicons {0}
			removespace {0}
			removestates {0}
			startskinned {0}
			topmost {0}
			titleheight {19}
			removechatbuttons {0}
		}

		set ::winskin::configlist [list \
			[list bool "Remove the titlebar and borders" removeborder] \
			[list bool "Add the buttons" addbuttons] \
			[list bool "Resize from 'top right'/'bottom right')" resizetopright] \
			[list bool "Make sure the scrollbar is always hidden" hidescroll] \
			[list bool "Hide the menu bar" hidemenu] \
			[list bool "Remove the top section" removetop] \
			[list bool "Remove the icons at the start of each line (0.95b or later only)" removeicons] \
			[list bool "Remove the extra space the start of each line (0.95b or later only)" removespace] \
			[list bool "Remove the state (in brackets) at the end of each line (0.95b or later only)" removestates] \
			[list bool "Start Skinned (on connection)" startskinned] \
			[list bool "Always On Top (only able to disable in windows)" topmost] \
			[list str "Height of titlebar in pixels (should not need to be changed)" titleheight] \
			[list bool "Remove the bar with action-buttons in chatwindows" removechatbuttons]\
		]

		if {$::tcl_platform(platform) == "windows"} {
			set ::winskin::config(usewinspecs) 1
			set ::winskin::configlist [linsert $::winskin::configlist 0 \
				[list bool "Use the windows specific code" usewinspecs] \
			]
		}

		if {[string equal $::version "0.94"]} {
			::skin::setPixmap winskin_move [file join $dir pixmaps winskin_move.gif]
			::skin::setPixmap winskin_remove [file join $dir pixmaps winskin_remove.gif]
			::skin::setPixmap winskin_replace [file join $dir pixmaps winskin_replace.gif]
			::skin::setPixmap winskin_resize [file join $dir pixmaps winskin_resize.gif]
			::skin::setPixmap winskin_resize2 [file join $dir pixmaps winskin_resize2.gif]
			::skin::setPixmap winskin_close [file join $dir pixmaps winskin_close.gif]
			::skin::setPixmap winskin_menu [file join $dir pixmaps winskin_menu.gif]
		} else {
			::skin::setPixmap winskin_move winskin_move.gif pixmaps [file join $dir pixmaps]
			::skin::setPixmap winskin_remove winskin_remove.gif pixmaps [file join $dir pixmaps]
			::skin::setPixmap winskin_replace winskin_replace.gif pixmaps [file join $dir pixmaps]
			::skin::setPixmap winskin_resize winskin_resize.gif pixmaps [file join $dir pixmaps]
			::skin::setPixmap winskin_resize2 winskin_resize2.gif pixmaps [file join $dir pixmaps]
			::skin::setPixmap winskin_close winskin_close.gif pixmaps [file join $dir pixmaps]
			::skin::setPixmap winskin_menu winskin_menu.gif pixmaps [file join $dir pixmaps]
		}

	}

	# ::winskin::switchskin
	# Description:
	#	Either removes the borders or replaces them
	#	force   -> Force to go to skinned mode
	proc switchskin { {force -1} } {
		variable skinned
		variable borderremoved
		variable contentsleft
		variable titleheight

		if { (($force == 1) && ($skinned == 1)) || (($force == 0) && ($skinned == 0)) } {
				return
		}

		if { $skinned == 0 } {
			set skinned 1

			if { $::winskin::config(topmost) == 1 } {
				#Some verions of tk don't support this
				catch { wm attributes . -topmost 1 }

				update idletasks
			}

			if { $::winskin::config(removeborder) == 1 } {
				scan [wm geometry .] "%dx%d%*1\[+-\]%d%*1\[+-\]%d" width height wx wy
				set contentsleft [expr {[winfo rootx .] - ($wx)}]
				set titlemenuheight [expr {[winfo rooty .] - ($wy)}]
				set titleheight $::winskin::config(titleheight)
				if { $::winskin::config(hidemenu) == 1 } {
					set menuheight [expr {$titlemenuheight - $titleheight - $contentsleft}]
				} else {
					set menuheight 0
				}
				set newwidth [expr {$width - (2 * $contentsleft)}]
				#contentsleft for bottom
				set newheight [expr {$height - $titleheight - $contentsleft}]
				set wx [expr {$wx + $contentsleft}]
				set wy [expr {$wy + $titleheight + $contentsleft}]

				if { $::winskin::config(usewinspecs) == 1 } {
					wm geometry . "${newwidth}x${newheight}+${wx}+${wy}"
					update idletasks

					if { [catch { plugins_log winskin [WinRemoveTitle . $menuheight] } ] } {
						#add catch incase someone tries to run on non windows platform
						catch {
							if {[string equal $::version "0.94"]} {
								load [file join $::winskin::dir winutils.dll]
							} else {
								package require WinUtils
							}
							plugins_log winskin [WinRemoveTitle . $menuheight]
						}
					}
				} else {
					variable movedheight
					set movedheight $menuheight
					set wy [expr {$wy + $movedheight}]
					wm geometry . "${width}x${height}+${wx}+${wy}"
					update idletasks
					wm state . withdrawn

#					if { $::winskin::config(topmost) == 1 } {
						wm overrideredirect . 1
#					}
					if { $::winskin::config(hidemenu) == 1 } {
						. conf -menu ""
					}
					wm state . normal
				}

				set borderremoved 1
			} else {
                                if { $::winskin::config(hidemenu) == 1 } {
					. conf -menu ""
                                }
			}
		} else {
			set skinned 0

			if { $borderremoved == 1 } {
				if { $::winskin::config(usewinspecs) == 1 } {
					catch { WinReplaceTitle . }
				} else {
					wm state . withdrawn
					wm overrideredirect . 0
					update idletasks
					. conf -menu .main_menu
					wm state . normal
				}

				update idletasks
				scan [wm geometry .] "%dx%d%*1\[+-\]%d%*1\[+-\]%d" width height wx wy
				set newwidth [expr {$width + (2 * $contentsleft)}]
				set newheight [expr {$height + $titleheight + $contentsleft}]
				set wx [expr {$wx - $contentsleft}]
				set wy [expr {$wy - $titleheight - $contentsleft}]
				if { $::winskin::config(usewinspecs) == 1 } {
					wm geometry . "${newwidth}x${newheight}+${wx}+${wy}"
				} else {
					variable movedheight
					set wy [expr {$wy - $movedheight}]
					wm geometry . "${width}x${height}+${wx}+${wy}"
				}

				set borderremoved 0
	                } elseif { $::winskin::config(usewinspecs) == 0 } {
               		        . conf -menu .main_menu

			}

			#Some verions of tk don't support this
			#Remove topmost
			catch { wm attributes . -topmost 0 }
		}

		::cmsn_draw_online
	}


	# ::winskin::connected
	# Description:
	#	On connection switches to skinned mode if set to start skinned
	# Arguments:
	#	event   -> The event wich runs the proc (Supplied by Plugins System)
	#     evPar   -> The array of parameters (Supplied by Plugins System)
	proc connected {event evPar} {
		if { $::winskin::config(startskinned) == 1 } {
			::winskin::switchskin 1
		}		
	}


	proc buttonbarCreated {event evPar} {
			upvar 2 $evPar newvar
		if {$::winskin::config(removechatbuttons)} {
			pack forget $newvar(buttons)
		}
			
	}



	# ::winskin::cldrawn
	# Description:
	#	Adds a line in the contact list and/or adds the buttons
	# Arguments:
	#	event   -> The event wich runs the proc (Supplied by Plugins System)
	#     evPar   -> The array of parameters (Supplied by Plugins System)
	proc cldrawn {event evPar} {		
		upvar 2 $evPar vars
		variable skinned

		catch { .main_menu clone .copy_of_main_menu }

		if { ($::winskin::config(removeicons) == 1) && ($skinned == 1) } {
			#remove icons
			foreach ic [$vars(text) window names] {
				if {     ([string first "$vars(text).img" "$ic"] == 0) \
					|| ([string first "$vars(text).contract" "$ic"] == 0) \
					|| ([string first "$vars(text).expand" "$ic"] == 0) \
					} {
					destroy $ic
				}
			}
		}

		if { ($::winskin::config(removespace) == 1) && ($skinned == 1) } {
			$vars(text) configure -state normal
			set pos 1.0
			while { [set pos [$vars(text) search -regexp "^    " $pos end]] != "" } {
				$vars(text) delete $pos $pos+4chars
			}
			$vars(text) configure -state disabled
		}

		if { ($::winskin::config(removestates) == 1) && ($skinned == 1) } {
			$vars(text) configure -state normal
			set x {}
			foreach a [set ::MSN::list_states] {lappend x (\\([trans [lindex $a 1]]\\)$)}
			lappend x (\\([trans mobile]\\)$)
			set x [join $x "|"]
			set start 1.0
			while { [set start [$::pgBuddy.text search -regexp $x $start end]] != "" } {
				set end [$::pgBuddy.text search -regexp "\\)" $start end]
				$vars(text) delete $start-1chars $end+1chars
			}
			$vars(text) configure -state disabled
		}

		if { ($::winskin::config(hidescroll) == 1) && ($skinned == 1) } {
			::Widget::getVariable $::pgBuddy data
			set data(vsb,present) 0
			set data(vsb,packed) 0
			grid remove $::pgBuddy.vscroll
		} else {
			::Widget::getVariable $::pgBuddy data
			set data(vsb,present) 1
		}

		if { $::winskin::config(addbuttons) == 1 } {
			set usedwidth 0

			set buttons $vars(text).winskinbuttons
			frame $buttons -class Amsn -relief solid \
					-width [winfo width $vars(text)]\
					-borderwidth 0 \
					-background [::skin::getKey contactlistbg]
			set statenow [$vars(text) cget -state]
			$vars(text) configure -state normal
			$vars(text) insert 1.0 "\n"
			$vars(text) configure -state $statenow
			$vars(text) window create 1.0 -window $buttons -padx 0 -pady 0

			set imag $buttons.skin
			set imagm $buttons.move
			set imagn $buttons.menu
			set imagr $buttons.rezise
			set imagc $buttons.close
			set filler $buttons.filler
			#destroy $imag $imagm $imagc
			if { $skinned == 1} {
				label $imag -image [::skin::loadPixmap winskin_replace] -background [::skin::getKey contactlistbg]
			} else {
				label $imag -image [::skin::loadPixmap winskin_remove] -background [::skin::getKey contactlistbg]
			}

			label $imagm -image [::skin::loadPixmap winskin_move] -background [::skin::getKey contactlistbg]
			label $imagn -image [::skin::loadPixmap winskin_menu] -background [::skin::getKey contactlistbg]

			if { $::winskin::config(resizetopright) == 1 } {
				label $imagr -image [::skin::loadPixmap winskin_resize] -background [::skin::getKey contactlistbg]
			} else {
				label $imagr -image [::skin::loadPixmap winskin_resize2] -background [::skin::getKey contactlistbg]
			}
			label $imagc -image [::skin::loadPixmap winskin_close] -background [::skin::getKey contactlistbg]

			$imag configure -cursor hand2 -borderwidth 0 -padx 0 -pady 0
			$imagm configure -cursor fleur -borderwidth 0 -padx 0 -pady 0
			$imagn configure -cursor hand2 -borderwidth 0 -padx 0 -pady 0
			if { $::winskin::config(resizetopright) == 1 } {
				$imagr configure -cursor top_right_corner -borderwidth 0 -padx 0 -pady 0
			} else {
				$imagr configure -cursor bottom_right_corner -borderwidth 0 -padx 0 -pady 0
			}
			$imagc configure -cursor hand2 -borderwidth 0 -padx 0 -pady 0

			pack $imagc -padx 5 -pady 0 -side right
			pack $imagr -padx 5 -pady 0 -side right
			if { $skinned == 1} {
				pack $imagn -padx 5 -pady 0 -side right
			}
			pack $imagm -padx 5 -pady 0 -side right
			pack $imag -padx 5 -pady 0 -side right
			incr usedwidth [image width [$imagc cget -image]]
			incr usedwidth 10
			incr usedwidth [image width [$imagr cget -image]]
			incr usedwidth 10
			if { $skinned == 1} {
				incr usedwidth [image width [$imagn cget -image]]
				incr usedwidth 10
			}
			incr usedwidth [image width [$imagm cget -image]]
			incr usedwidth 10
			incr usedwidth [image width [$imag cget -image]]
			incr usedwidth 10

			frame $filler -width [expr {[winfo width $vars(text)] - $usedwidth}] \
					-borderwidth 0 \
					-background [::skin::getKey contactlistbg]
			pack $filler -padx 0 -pady 0 -side right -expand true

			bind $imag <ButtonPress-1> "after 1 ::winskin::switchskin"
			bind $imagm <ButtonPress-1> "::winskin::buttondown"
			bind $imagm <B1-Motion> "::winskin::drag"
			bind $imagm <ButtonRelease-1> "::winskin::release"
			bind $imagn <ButtonPress-1> "tk_popup .copy_of_main_menu %X %Y"
			bind $imagr <ButtonPress-1> "::winskin::buttondown"
			bind $imagr <B1-Motion> "::winskin::resize"
			bind $imagr <ButtonRelease-1> "::winskin::release"
			bind $imagc <ButtonPress-1> "::amsn::closeOrDock [::config::getKey closingdocks]"
		}
	}

	proc buttondown { } {
		variable dset
		variable dx
		variable dy
		variable posx
		variable posy
		variable winxpos
		variable winypos
		variable width
		variable height
		variable skinned
		variable contentsleft

		set posx [winfo pointerx .]
		set posy [winfo pointery .]

		if { [info procs xxxxx] == ""} {
			bind . <Configure>
			rename ::cmsn_draw_online xxxxx
			proc ::cmsn_draw_online {{a ""}} {}
		}

		scan [wm geometry .] "%dx%d%*1\[+-\]%d%*1\[+-\]%d" width height wx wy
		set dset 1
		set dx [expr {$wx-$posx}]
		set dy [expr {$wy-$posy}]
		set winxpos $wx
		set winypos $wy

		#if skinned need to take borederwidth into account
		if { ($skinned == 1) && ($::winskin::config(usewinspecs) == 1)} {
			#set width [expr {$width - (2 * ([winfo rootx .] - ($wx)))}]
			set width [expr {$width - (2 * $contentsleft)}]
		}
	}

        # ::winskin::draw
        # Description: 
        #       Removes top section
        # Arguments:
        #       event   -> The event wich runs the proc (Supplied by Plugins System)
        #     evPar   -> The array of parameters (Supplied by Plugins System)
        proc draw {event evPar} {  
                upvar 2 $evPar vars
                variable skinned

                if { ($::winskin::config(removetop) == 1) && ($skinned == 1) } {
                        $vars(text) delete 1.0 end
                        #TODO: change postevent and dont hardcode location
                        catch { pack forget $::pgBuddyTop }
                }

	}

	proc release { } {
		variable dset
		set dset 0

		if { [info procs xxxxx] != ""} {
			rename ::cmsn_draw_online ""
			rename xxxxx ::cmsn_draw_online
			cmsn_draw_online
		}
	}

	proc drag { } {
		variable dset
		variable dx
		variable dy
		variable width
		variable height

		if { $dset } {
			set x [winfo pointerx .]
			set y [winfo pointery .]
			wm geometry . "${width}x${height}+[expr {$dx + $x}]+[expr {$dy + $y}]"
		}
	}

	proc resize { } {
		variable skinned
		variable borderremoved
		variable dset
		#variable dx
		variable dy
		variable posx
		variable posy
		variable winxpos
		variable winypos
		variable width
		variable height

		if { $dset } {
			set x [winfo pointerx .]
			set y [winfo pointery .]
			set newwidth [expr {$width - $posx + $x}]
			if { $newwidth < 10 } { set newwidth 10 }
			if { $::winskin::config(resizetopright) == 1 } {
				set newheight [expr {$height + $posy - $y}]
				set wy [expr {$dy + $y}]
			} else {
				set newheight [expr {$height - $posy + $y}]
				set wy $winypos
			}
			if { $newheight < 10 } { set newheight 10 }
			wm geometry . "${newwidth}x${newheight}+${winxpos}+${wy}"

			#need to reset the size of the encompassing box if using winspecs
			if { ($::winskin::config(usewinspecs) == 1) && ($borderremoved == 1)} {
				variable contentsleft

				update idletasks
				set titlemenuheight [expr {[winfo rooty .] - ($wy)}]
				if { $::winskin::config(hidemenu) == 1 } {
					set menuheight [expr {$titlemenuheight}]
				} else {
					set menuheight 0
				}

				if { [catch { plugins_log winskin [WinRemoveTitle . $menuheight] } ] } {
					#add catch incase someone tries to run on non windows platform
					catch {
						if {[string equal $::version "0.94"]} {
							load [file join $::winskin::dir winutils.dll]
						} else {
							package require WinUtils
						}
						plugins_log winskin [WinRemoveTitle . $menuheight]
					}
				}
			}
		}
	}
}
