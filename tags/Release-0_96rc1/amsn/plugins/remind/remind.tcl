#######################################################
#                  REMIND PLUGIN                      #
#######################################################
# Maintainer: Frederic Diaz (gadget_boy@users.sf.net) #
#######################################################


namespace eval ::remind {
	variable config
	variable configlist
	variable language


##############################
# ::remind::InitPlugin dir   #
# ---------------------------#
# Load proc of Remind Plugin #
##############################

proc InitPlugin { dir } {

	global version

	::plugins::RegisterPlugin remind
	source [file join $dir remind.tcl]
	::plugins::RegisterEvent remind new_conversation Remind

	array set ::remind::config [list beginend {1} daysnumber {7} filetransfert {1} nbline {10} checknote {1} when {1}]

	# Loads langs if aMSN version is upper than 0.95
	if { $version == "0.94"  | ![file isdirectory "$dir/lang"] } {

		array set ::remind::language [list always {Always} beginendconversation {Display begin and end of conversation} checknote {Display if there are notes} daysnumber {Number of days} filetransfert {Display file transfers} lastsentence {Last sentences in the previous conversations} nbdisplay {Number of line displayed} noteswritten {You have written notes about this contact} talklast {If we have talk in the last x days} talkwinthin {If we have not talk within x days}]

		set ::remind::configlist [list \
			[list str "$::remind::language(nbdisplay)" nbline] \
			[list bool "$::remind::language(beginendconversation)" beginend] \
			[list bool "$::remind::language(filetransfert)" filetransfert] \
		]

	} else {

		set langdir [file join $dir "lang"]
		set lang [::config::getGlobalKey language]
		load_lang en $langdir
		load_lang $lang $langdir
		array set ::remind::language [list always "[trans always]" beginendconversation "[trans beginendconversation]" checknote "[trans checknote]" daysnumber "[trans daysnumber]" filetransfert "[trans filetransfert]" lastsentence "[trans lastsentence]" nbdisplay "[trans nbdisplay]" noteswritten "[trans noteswritten]" talklast "[trans talklast]" talkwithin "[trans talkwithin]"]

		set ::remind::configlist [list \
			[list str "$::remind::language(nbdisplay)" nbline] \
			[list rbt "$::remind::language(always)" "$::remind::language(talklast)" "$::remind::language(talkwithin)" when] \
			[list str "$::remind::language(daysnumber)" daysnumber] \
			[list bool "$::remind::language(beginendconversation)" beginend] \
			[list bool "$::remind::language(filetransfert)" filetransfert] \
			[list bool "$::remind::language(checknote)" checknote] \
		]
 	
	}

}


################################################################
# ::remind::Remind event epvar                                 #
# ------------------------------------------------------------ #
# Tell the other procs what to do according to the preferences #
################################################################

proc Remind { event evpar } {

	global version

	upvar 2 $evpar parameters
	set chatid $parameters(chatid)
	set email $parameters(usr_name)
		
	if { $version == "0.94" } {
	
		::remind::ShowLastSentences $chatid $email
		
	} else {
	
		
		set lastmessage [string range [::abook::getContactData $email last_msgedme] 0 7]
		set date [clock format [clock seconds] -format "%D"]
		
		set lastmessage [clock scan $lastmessage]
		set date [clock scan $date]
		set timeline [expr { $::remind::config(daysnumber) * 86400 }]

		if { $::remind::config(when) == 1
			|| ( $::remind::config(when) == 2 && [expr { $date - $lastmessage }] <= $timeline )
			|| ( $::remind::config(when) == 3 && [expr { $date - $lastmessage }] >= $timeline )
		} {
			::remind::ShowLastSentences $chatid $email
		}

		if { $::remind::config(checknote) == 1 } {
			::remind::CheckNote $chatid $email
		}

	}
	
}
	

################################################
# ::remind::ShowLastSentences chatid email     #
# -------------------------------------------- #
# Display the last sentences in the chatwindow #
################################################

proc ShowLastSentences { chatid email } {

	global version

	# Get the last sentences of the contact
	set loglines [::remind::GetLastSentences $email]

	set tagname "black"
	set font [lindex [::config::getGlobalKey basefont] 0]
	if { $font == "" } { set font "Helvetica" }		
	set fontformat [list "" "" ""]

	set win_name [::ChatWindow::For $chatid]

	# Allow something to be written into the chat window
	if { $version == "0.94" } {
		${win_name}.f.out.text configure -state normal -font bplainf -foreground black
	} else {
		[::ChatWindow::GetOutText ${win_name}] configure -state normal -font bplainf -foreground black
	}

	::remind::WinWrite "$chatid" "$::remind::language(lastsentence) :" blue

	foreach line $loglines {

		# If the line doesn't begin with |"L
		if { [string range $line 0 2] != "\|\"L" & $line != ""} {
			::remind::WinWrite $chatid "\n$line" $tagname $fontformat
		} else {

			set color [string range $line 3 5]

			switch $color {

				GRA { # If the line is a message...

					set aidx [string first "\|\"L" $line 16]

					set color2 [string range $line [expr {$aidx + 3}] [expr {$aidx + 5}]]

					switch $color2 {

					    ITA {

						# Check if the time must be displayed or not
						if { [::config::getKey showtimestamps] } {
							set tstamp [string range $line 6 15]
						} else {
							set tstamp ""
						}

						set aidx [string first "\|\"L" $line 19]
						set nick [string range $line 23 [expr {$aidx - 2}]]

						# Look at the style used in chatwindows
						switch [::config::getKey chatstyle] {
						    msn {::config::setKey customchatstyle "\$tstamp [trans says \$nick]:\n"}
						    irc {::config::setKey customchatstyle "\$tstamp <\$nick> "}
						    - { }
						}

						set customchat [string map {"\\" "\\\\" "\$" "\\\$" "\(" "\\\(" } [::config::getKey customchatstyle]]
						set customchat [string map { "\\\$nick" "\${nick}" "\\\$tstamp" "\${tstamp}" } $customchat]
						set customchat [string map {"\\\$newline" "\n" } $customchat]
						set customchat [subst -nocommands $customchat]

						# Look if there is a color information in the message
						if {[string index $line [expr {$aidx + 3}]] == "C"} {
							set color [string range $line [expr {$aidx + 4}] [expr {$aidx + 9}]]
							set fontformat [list "$font" "" "$color"]
							set tagname "user"
							set string [string range $line [expr {$aidx + 11}] end]
						} else {
							set fontformat [list "$font" "" ""]
							set tagname black
							set string [string range $line [expr {$aidx + 8}] end]
						}

						::remind::WinWrite $chatid "\n$customchat" gray
						::remind::WinWrite $chatid "$string" $tagname $fontformat
				
					    }

					    GRE { #... or a filetransfert

						if { $::remind::config(filetransfert) == 1 } {
							set string "\n[string range $line [expr {$aidx + 6}] end]"
							set tagname green
							::remind::WinWrite $chatid "$string" green
						}

					    }

					    - { }

					}

				}

				RED { #If the line is an information (e.g. conversation closed)

					if { $::remind::config(beginend) == 1 } {
						set string "\n[string range $line 6 end]"
						set tagname red
						::remind::WinWrite $chatid "$string" red
					}
				}

				- { }
			}

		}

	}

	::remind::WinWrite $chatid "\n" black
	::amsn::WinWriteIcon $chatid greyline 3	

	if { $version == "0.94" } {
		${win_name}.f.out.text yview end
		${win_name}.f.out.text configure -state disabled
	} else {
		[::ChatWindow::GetOutText $win_name] yview end
		[::ChatWindow::GetOutText ${win_name}] configure -state normal -font bplainf -foreground black
	}

}


#############################################
# ::remind::GetLastSentence email           #
# ----------------------------------------- #
# It gets the last sentences of the contact #
#############################################

proc GetLastSentences { email } {

	global log_dir

	# Select the last logging file, and cancel the proc if there is no log file yet
	if { [file exists [file join ${log_dir} ${email}.log]] == 1 } {
		set id [open "[file join ${log_dir} ${email}.log]" r]
		set size [file size [file join ${log_dir} ${email}.log]]
	} elseif {[::config::getKey logsbydate] == 1} {
		set date_list [list]
		set erdate_list [list]
		foreach date [glob -nocomplain -types f [file join ${log_dir} * ${email}.log]] {
			set date [getfilename [file dirname $date]]
			if { [catch { clock scan "1 $date"}] == 0 } {
				lappend date_list  [clock scan "1 $date"]
			} else {
				lappend erdate_list $date
			}
		}
		set sorteddate_list [lsort -integer -decreasing $date_list]

		set date [lindex $sorteddate_list 0]
		set date "[clock format $date -format "%B"] [clock format $date -format "%Y"]"

		set id [open [file join ${log_dir} ${date} ${email}.log] r]

	} else {
		return
	}

	fconfigure $id -encoding utf-8
	set logvar [read $id]
	close $id

	# Select the $nbline last lines
	set loglines [split $logvar "\n"]
	set nbline [expr {int($::remind::config(nbline))}]
	set begin [expr {[llength $loglines] - $nbline}]
	set loglines [lrange $loglines $begin end]

	return $loglines

}


##############################################
# ::remind::CheckNote email                  #
# ------------------------------------------ #
# Check if there are notes about the contact #
##############################################

proc CheckNote { chatid email } {

	global HOME

	set file [file join $HOME notes ${email}_note.xml]
	
	if { [file exists $file] } {
		status_log "REMIND : OK\n" red
		::remind::WinWrite "$chatid" "\n$::remind::language(noteswritten)\n" blue

	}
	
}


####################################################
# ::remind::WinWrite chatid txt tagname fontformat #
# ------------------------------------------------ #
# Light version of ::amsn::WinWrite (faster)       #
####################################################

proc WinWrite {chatid txt tagname {fontformat ""}} {

	global version

	set win_name [::ChatWindow::For $chatid]

	if { [::ChatWindow::For $chatid] == 0} {
		return 0
	}

	set fontname [lindex $fontformat 0]
	set fontstyle [lindex $fontformat 1]      
	set fontcolor [lindex $fontformat 2]

	#Store position for later smiley
	if { $version == "0.94" } {
		set text_start [${win_name}.f.out.text index end]
	} else {
		set text_start [[::ChatWindow::GetOutText ${win_name}] index end]
	}
	set posyx [split $text_start "."]
	set text_start "[expr {[lindex $posyx 0]-1}].[lindex $posyx 1]"

	set tagid $tagname

	if { $tagid == "user" } {
		set size [expr {[lindex [::config::getGlobalKey basefont] 1]+[::config::getKey textsize]}]
		set font "\"$fontname\" $size $fontstyle"
		set tagid [::md5::md5 "$font$fontcolor"]

		if { $version == "0.94" } {
			${win_name}.f.out.text tag configure $tagid -foreground #$fontcolor -font $font
		} else {
			[::ChatWindow::GetOutText ${win_name}] tag configure $tagid -foreground #$fontcolor -font $font
		}
	}

	if { $version == "0.94" } {
		${win_name}.f.out.text insert end "$txt" $tagid
	} else {
		[::ChatWindow::GetOutText ${win_name}] insert end "$txt" $tagid
	}

	if {[::config::getKey chatsmileys]} {
		if { $version == "0.94" } {
			custom_smile_subst $chatid ${win_name}.f.out.text $text_start end
			::smiley::substSmileys ${win_name}.f.out.text $text_start end 0
		} else {
			custom_smile_subst $chatid [::ChatWindow::GetOutText ${win_name}] $text_start end
			::smiley::substSmileys [::ChatWindow::GetOutText ${win_name}] $text_start end 0 0
		}
	}

}


}
