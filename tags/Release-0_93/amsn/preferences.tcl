
package require AMSN_BWidget



if { $initialize_amsn == 1 } {
	global myconfig proxy_server proxy_port proxy_user proxy_pass rbsel rbcon pgc
	
	###################### Preferences Window ###########################
	array set myconfig {}   ; # configuration backup
	set proxy_server ""
	set proxy_port ""
	set proxy_pass ""
	set proxy_user ""
    	
	set pgc 1
}

proc PreferencesCopyConfig {} {
	global myconfig proxy_server proxy_port
	
	array set myconfig [::config::getAll]
	
	# Now process certain exceptions. Should be reverted
	# in the RestorePreferences procedure
	set proxy_data $myconfig(proxy)
	set proxy_server [lindex $proxy_data 0]
	set proxy_port [lindex $proxy_data 1]
}

## Function that makes the group list in the preferences ##
proc MakeGroupList { lfgroup lfcontact } {
	
	array set groups [::abook::getContactData contactlist groups]
	
	frame $lfgroup.lbgroup.fix
	pack $lfgroup.lbgroup.fix -side left -anchor n -expand 1 -fill x -padx 5 -pady 5
	label $lfgroup.lbgroup.fix.l -text \"[trans groups]\" -font sboldf
	pack $lfgroup.lbgroup.fix.l -side top -anchor w -pady 5
	
	frame $lfgroup.lbgroup.fix.list
	## create the listbox ##
	listbox $lfgroup.lbgroup.fix.list.lb -background white -yscrollcommand "$lfgroup.lbgroup.fix.list.sb set"
	scrollbar $lfgroup.lbgroup.fix.list.sb -command "$lfgroup.lbgroup.fix.list.lb yview" -highlightthickness 0 \
		-borderwidth 1 -elementborderwidth 2

	pack $lfgroup.lbgroup.fix.list.lb -side left -anchor w -pady 0 -padx 0 -expand true -fill both
	pack $lfgroup.lbgroup.fix.list.sb -side left -anchor w -pady 0 -padx 0 -fill y
	pack $lfgroup.lbgroup.fix.list -side top -expand true -fill both
	

	## entries ##
	$lfgroup.lbgroup.fix.list.lb insert end "[trans nogroup]"
	foreach gr [lsort [array names groups]] {
		if { $groups($gr) != "Individuals" } {
			$lfgroup.lbgroup.fix.list.lb insert end $groups($gr)
		}
	}
	## make binding ##
	bind $lfgroup.lbgroup.fix.list.lb <<ListboxSelect>> "GroupSelectedIs $lfgroup $lfcontact"
}

## Function to be called when <<ListboxSelect>> event occurs to change rbsel value ##
proc GroupSelectedIs { lfgroup lfcontact } {
	global rbsel
	if {[$lfgroup.lbgroup.fix.list.lb curselection] != "" } {
		set rbsel [$lfgroup.lbgroup.fix.list.lb curselection]
		#Get the rbsel-th group. Note that groups must be inserted same order
		array set groups [::abook::getContactData contactlist groups]
		set rbsel [lindex [lsort [array names groups]] $rbsel]
		MakeContactList $lfcontact 
	}
}

## Function to be called after pressing delete/rename/add group button ##
proc RefreshGroupList { lfgroup lfcontact } {
	global pgc pgcd
	if { $pgc == 1 } {
		vwait pgc
	}
	set pgc 1
	destroy $lfgroup.lbgroup.fix
	MakeGroupList $lfgroup $lfcontact
}

## Function to be called when a group is selected ##
proc MakeContactList { lfcontact } {
	global rbsel rbcon
	catch {DeleteContactList $lfcontact}
	
	if {![info exists rbsel]} { return; }
	if { ![::groups::Exists [::groups::GetName $rbsel]] || $rbsel == 0 } {
		if { $rbsel == 0 } {
			## fix the name of the group ##
			label $lfcontact.lbcontact.fix.l -text "[trans nogroup]" -font sboldf
			pack $lfcontact.lbcontact.fix.l -side top -pady 5 -padx 5  -anchor w
			frame $lfcontact.lbcontact.fix.list
			
			## create the listbox ##
			listbox $lfcontact.lbcontact.fix.list.lb -background white -yscrollcommand "$lfcontact.lbcontact.fix.list.sb set"
			scrollbar $lfcontact.lbcontact.fix.list.sb -command "$lfcontact.lbcontact.fix.list.lb yview" -highlightthickness 0 \
				-borderwidth 1 -elementborderwidth 2
			
			pack $lfcontact.lbcontact.fix.list.lb -side left -anchor w -expand true -fill both
			pack $lfcontact.lbcontact.fix.list.sb -side left -anchor w -fill y
			pack $lfcontact.lbcontact.fix.list -side top -anchor w -pady 5 -padx 5 -expand true -fill both
			## list contacts that don't have a group ##
			set contacts [::MSN::getList FL]
			set i 0
			while { $i < [llength $contacts] } {
				set contact [lindex $contacts $i]
				set g [::abook::getGroups $contact]
				if { [lindex $g 0] == 0 } {
					$lfcontact.lbcontact.fix.list.lb insert end $contact
				}
				incr i
			}
		## make the binding ##
		bind $lfcontact.lbcontact.fix.list.lb <<ListboxSelect>> "ContactSelectedIs $lfcontact"
		}
	} else {
		label $lfcontact.lbcontact.fix.l -text "[::groups::GetName $rbsel]" -font sboldf
		pack $lfcontact.lbcontact.fix.l -side top -pady 5 -padx 5 -anchor w
		frame $lfcontact.lbcontact.fix.list
		
		## create the listbox ##
		listbox $lfcontact.lbcontact.fix.list.lb -background white -yscrollcommand "$lfcontact.lbcontact.fix.list.sb set"
		scrollbar $lfcontact.lbcontact.fix.list.sb -command "$lfcontact.lbcontact.fix.list.lb yview" -highlightthickness 0 \
			-borderwidth 1 -elementborderwidth 2

		pack $lfcontact.lbcontact.fix.list.lb -side left -anchor w -expand true -fill both
		pack $lfcontact.lbcontact.fix.list.sb -side left -anchor w -fill y
		pack $lfcontact.lbcontact.fix.list -side top -anchor w -pady 5 -padx 5 -expand true -fill both

		set groups [::abook::getContactData contactlist groups]
		set contacts [::MSN::getList FL]
		set i 0
		while { $i < [llength $contacts] } {
			set contact [lindex $contacts $i]
			set group [::abook::getGroups $contact]
			set j 0
			while { $j < [llength $group] } {
				set g [lindex $group $j]
				if { $g == $rbsel } {
					$lfcontact.lbcontact.fix.list.lb insert end $contact
				}
				incr j
			}
			incr i
		}
		## make the binding ##
		bind $lfcontact.lbcontact.fix.list.lb <<ListboxSelect>> "ContactSelectedIs $lfcontact"
	}
}

## Function to be called when <<ListboxSelect>> event occurs to change rbsel value ##
proc ContactSelectedIs { lfcontact } {
	global rbcon
	if {[$lfcontact.lbcontact.fix.list.lb curselection] != "" } {
		set rbcon [$lfcontact.lbcontact.fix.list.lb get [$lfcontact.lbcontact.fix.list.lb curselection]]
	} else {
		set rbcon ""
	}
}

## Function to be called when the selected group becomes unvalid ##
proc DeleteContactList { lfcontact } {
	destroy $lfcontact.lbcontact.fix
	frame $lfcontact.lbcontact.fix
	pack $lfcontact.lbcontact.fix -side left -anchor n -expand 1 -fill x
}

## Function to be called when the selected group is deleted/renamed or a contact deleted/moved/copied/added ##
proc RefreshContactList { lfcontact } {
	global pcc
	if { $pcc == 1 } {
		vwait pcc
	}
	set pcc 1
	DeleteContactList $lfcontact
	MakeContactList $lfcontact
}

proc dlgMoveUser {} {
	global rbcon rbsel gsel pcc
	if {![info exists rbcon]} {return;}
	if {![info exists rbsel]} {return;}
	## check if window exists ##
	if { [winfo exists .dlgmu] } {
		set pcc 0
		return 0
	}
	## if no contact is selected -- return ##
	if { $rbcon == "" } {
		set pcc 0
		return 0
	}
	## calculate oldgid - now we get the first group int the group list - we have to improve it ##
	set oldgid [::abook::getGroups $rbcon]
	set oldgid [lindex $oldgid 0]
	## variable for the selected group -- we set to oldgid to avoid bugs ##
	set gsel $oldgid
	
	set bgcol2 #ABC8D2
	toplevel .dlgmu -highlightcolor $bgcol2
	wm title .dlgmu "[trans moveuser]"
	## radiobuttons for newgid ##
	frame .dlgmu.d
	array set groups [::abook::getContactData contactlist groups]
	foreach gr [array names groups] {
		if { $groups($gr) != "Individuals" } {
			radiobutton .dlgmu.d.$gr -text "$groups($gr)" -value $gr -variable gsel
			pack .dlgmu.d.$gr -side left
		}
	}
	pack .dlgmu.d -side top -pady 3 -padx 5
	## button options ##
	frame .dlgmu.b 
	button .dlgmu.b.ok -text "[trans ok]"  -font sboldf \
		-command " if {![info exists gsel]} {return;}; \
			::MSN::moveUser \$rbcon $oldgid \$gsel; \
			unset gsel; \
			destroy .dlgmu; "
	button .dlgmu.b.cancel -text "[trans cancel]"  -font sboldf \
		-command "destroy .dlgmu; set pcc 0;"
	pack .dlgmu.b.ok .dlgmu.b.cancel -side right -padx 5
	pack .dlgmu.b  -side top -anchor e -pady 3
}

proc dlgCopyUser {} {
	global rbcon rbsel gsel pcc
	if {![info exists rbcon]} {return;}
	if {![info exists rbsel]} {return;}
	if { [winfo exists .dlgcu] } {
		set pcc 0
		return 0
	}
	## if no contact is selected -- return ##
	if { $rbcon == "" } {
		set pcc 0
		return 0
	}
	## calculate oldgid - now we get the first group int the group list - we have to improve it ##
	set oldgid [::abook::getGroups $rbcon]
	set oldgid [lindex $oldgid 0]
	## protection --> the contacts who are in 'nogroup' will be moved, not copied ##
	set move 0
	if { $oldgid == 0 } {
		set move 1
	}
	## variable for the selected group -- we set to oldgid to avoid bugs ##
	set gsel $oldgid
	
	set bgcol2 #ABC8D2
	toplevel .dlgcu -highlightcolor $bgcol2
	wm title .dlgcu "[trans moveuser]"
	## radiobuttons for newgid ##
	frame .dlgcu.d
	array set groups [::abook::getContactData contactlist groups]
	foreach gr [array names groups] {
		if { $groups($gr) != "Individuals" } {
			radiobutton .dlgcu.d.$gr -text "$groups($gr)" -value $gr -variable gsel
			pack .dlgcu.d.$gr -side left
		}
	}
	pack .dlgcu.d -side top -pady 3 -padx 5
	## button options ##
	frame .dlgcu.b 
	if { $move == 0 } {
		button .dlgcu.b.ok -text "[trans ok]"  -font sboldf \
			-command " if {![info exists gsel]} {return;}; \
				::MSN::copyUser \$rbcon \$gsel; \
				unset gsel; \
				destroy .dlgcu; "
	}
	if { $move == 1 } {
		button .dlgcu.b.ok -text "[trans ok]" -font sboldf \
			-command " if {![info exists gsel]} {return;}; \
				::MSN::moveUser \$rbcon $oldgid \$gsel; \
				unset gsel; \
				destroy .dlgcu; "
	}
	button .dlgcu.b.cancel -text "[trans cancel]"  -font sboldf \
		-command "destroy .dlgcu; set pcc 0;"
	pack .dlgcu.b.ok .dlgcu.b.cancel -side right -padx 5
	pack .dlgcu.b  -side top -anchor e -pady 3
}

## This is used to move all the contacts from a group to nogroup ##
proc BuidarGrup { lfcontact } {
	global rbsel
	if {![info exists rbsel]} {return;}
	set answer [tk_messageBox -title "[trans confirm]" -message "[trans confirmeg]" -type yesno -icon question \
		-parent .cfg]
	if { $answer == "no" } { return; }
	if { $rbsel == 0 } { return; }
	set contacts [::MSN::getList FL]
	set i 0
	while { $i < [llength $contacts] } {
		set contact [lindex $contacts $i]
		foreach gp [::abook::getContactData $contact group] {
			if { $gp == $rbsel } {
				::MSN::deleteUser $contact $rbsel
				RefreshContactList $lfcontact
			}
		}
		incr i
	}
}

## This is used to delete a group in preferences ##
proc dlgDelGroup { lfgroup lfcontact } {
	global rbsel
	if {![info exists rbsel]} {return;}
	set answer [tk_messageBox -title "[trans confirm]" -message "[trans confirmdg]" -type yesno -icon question \
		-parent .cfg]
	if { $answer == "no" } { return; }
	::groups::Delete $rbsel dlgMsg
	RefreshGroupList $lfgroup $lfcontact
}

## This is used to rename a group in preferences ##
proc dlgRenGroup { lfgroup lfcontact } {
	global rbsel
	if {![info exists rbsel]} {return;}
	::groups::dlgRenameThis $rbsel
	tkwait window .dlgthis
	RefreshGroupList $lfgroup $lfcontact
}

## This is used when we remove contact from list in preferences ##
proc dlgRFL { lfcontact } {
	global rbsel rbcon
	if {![info exists rbcon]} {return;}
	if {![info exists rbsel]} {return;}
	set answer [tk_messageBox -title "[trans confirm]" -message "[trans confirmrfl]" -type yesno -icon question \
		-parent .cfg]
	if { $answer == "no" } { return; }
	if { $rbsel != -1 } {
		::MSN::deleteUser $rbcon $rbsel
		RefreshContactList $lfcontact
	}
}

## This is used to delete a user in preferences ##
proc dlgDelUser { lfcontact } {
	global rbcon
	if {![info exists rbcon]} {return;}
	set answer [tk_messageBox -title "[trans confirm]" -message "[trans confirmdu]" -type yesno -icon question \
		-parent .cfg]
	if { $answer == "no" } { return; }
	::MSN::deleteUser $rbcon
	RefreshContactList $lfcontact
}

proc Preferences { { settings "personal"} } {
    global myconfig proxy_server proxy_port temp_BLP list_BLP Preftabs libtls_temp libtls proxy_user proxy_pass rbsel rbcon

    set temp_BLP $list_BLP
    set libtls_temp $libtls

    if {[ winfo exists .cfg ]} {
    	raise .cfg
        return
    }

    PreferencesCopyConfig	;# Load current configuration

    toplevel .cfg
    wm state .cfg withdraw

    if { [LoginList exists 0 [::config::getKey login]] == 1 } {
	wm title .cfg "[trans preferences] - [trans profiledconfig] - [::config::getKey login]"
    } else {
	wm title .cfg "[trans preferences] - [trans defaultconfig] - [::config::getKey login]"
    }

    wm iconname .cfg [trans preferences]

    # Frame to hold the preferences tabs/notebook
    frame .cfg.notebook -class Degt

    #set nb .cfg.notebook.nn
    set nb .cfg.notebook

	# Preferences Notebook
	# Modified Rnotebook to translate automaticly those keys in -tabs {}
	#Rnotebook:create $nb -tabs {personal appearance session privacy loging connection others advanced} -borderwidth 2
        #set Preftabs(personal) 1
        #set Preftabs(appearance) 2
        #set Preftabs(session) 3
        #set Preftabs(privacy) 4
        #set Preftabs(loging) 5
        ##BLOCKING
	#set Preftabs(blocking) 6
        #set Preftabs(connection) 6 
        #set Preftabs(others) 7 
        #set Preftabs(advanced) 8 
	NoteBook $nb.nn
	$nb.nn insert end personal -text [trans personal]
	$nb.nn insert end appearance -text [trans appearance]
	$nb.nn insert end session -text [trans session]
	$nb.nn insert end groups -text [trans groups]
	$nb.nn insert end privacy -text [trans privacy]
	$nb.nn insert end loging -text [trans loging]
	$nb.nn insert end connection -text [trans connection]
	$nb.nn insert end others -text [trans others]
	$nb.nn insert end advanced -text [trans advanced]


	#  .----------.
	# _| Personal |________________________________________________
	::skin::setPixmap prefpers prefpers.gif
	::skin::setPixmap prefprofile prefprofile.gif
	::skin::setPixmap preffont preffont.gif
	::skin::setPixmap prefphone prefphone.gif
	#set frm [Rnotebook:frame $nb $Preftabs(personal)]
	set frm [$nb.nn getframe personal]
	#Scrollable frame that will contain options
	ScrolledWindow $frm.sw
	ScrollableFrame $frm.sw.sf -constrainedwidth 1
	$frm.sw setwidget $frm.sw.sf
	pack $frm.sw -anchor n -side top -expand true -fill both
	set frm [$frm.sw.sf getframe]	

	## Nickname Selection Entry Frame ##
	set lfname [LabelFrame:create $frm.lfname -text [trans prefname] -font splainf]
	pack $frm.lfname -anchor n -side top -expand 1 -fill x
	frame $lfname.1 -class Degt
	label $lfname.pname -image [::skin::loadPixmap prefpers]
	frame $lfname.1.name -class Degt
	label $lfname.1.name.label -text "[trans enternick] :" -font sboldf -padx 10
	entry $lfname.1.name.entry -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 45
	frame $lfname.1.p4c -class Degt
	label $lfname.1.p4c.label -text "[trans friendlyname] :" -font sboldf -padx 10
	entry $lfname.1.p4c.entry -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 45
	pack $lfname.pname -anchor nw -side left
	pack $lfname.1 -side top -padx 0 -pady 3 -expand 1 -fill both
	pack $lfname.1.name.label $lfname.1.name.entry -side left
	pack $lfname.1.p4c.label $lfname.1.p4c.entry -side left
	pack $lfname.1.name $lfname.1.p4c -side top -anchor nw

	## Public Profile Frame ##
	#set lfname [LabelFrame:create $frm.lfname2 -text [trans prefprofile]]
	#pack $frm.lfname2 -anchor n -side top -expand 1 -fill x
	#label $lfname.pprofile -image [::skin::loadPixmap prefprofile]
	#label $lfname.lprofile -text [trans prefprofile2] -padx 10
	#button $lfname.bprofile -text [trans editprofile] -font sboldf -command "" -state disabled
	#pack $lfname.pprofile $lfname.lprofile -side left
	#pack $lfname.bprofile -side right -padx 15

	## Chat Font Frame ##
	set lfname [LabelFrame:create $frm.lfname3 -text [trans preffont]]
	pack $frm.lfname3 -anchor n -side top -expand 1 -fill x
	label $lfname.pfont -image [::skin::loadPixmap preffont]
	label $lfname.lfont -text [trans preffont2] -padx 10
	button $lfname.bfont -text [trans changefont] -font sboldf -command "change_myfont cfg"
	pack $lfname.pfont $lfname.lfont -side left
	pack $lfname.bfont -side right -padx 15

	## Phone Numbers Frame ##
	set lfname [LabelFrame:create $frm.lfname4 -text [trans prefphone]]
	pack $frm.lfname4 -anchor n -side top -expand 1 -fill x 
	frame $lfname.1 -class Degt
	frame $lfname.2 -class Degt
	label $lfname.1.pphone -image [::skin::loadPixmap prefphone]
	pack $lfname.1.pphone -side left -anchor nw
	label $lfname.1.lphone -text [trans prefphone2] -padx 10
	pack $lfname.1.lphone -fill both -side left
	label $lfname.2.lphone1 -text "[trans countrycode] :" -padx 10 -font sboldf
	entry $lfname.2.ephone1 -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 5
	label $lfname.2.lphone21 -text "[trans areacode]" -pady 3
	label $lfname.2.lphone22 -text "[trans phone]" -pady 3
	label $lfname.2.lphone3 -text "[trans myhomephone] :" -padx 10 -font sboldf
	entry $lfname.2.ephone31 -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 5	
	entry $lfname.2.ephone32 -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 20
	label $lfname.2.lphone4 -text "[trans myworkphone] :" -padx 10 -font sboldf
	entry $lfname.2.ephone41 -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 5	
	entry $lfname.2.ephone42 -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 20
	label $lfname.2.lphone5 -text "[trans mymobilephone] :" -padx 10 -font sboldf
	entry $lfname.2.ephone51 -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 5	
	entry $lfname.2.ephone52 -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 20
	pack $lfname.1 -expand 1 -fill both -side top
	pack $lfname.2 -expand 1 -fill both -side top
	grid $lfname.2.lphone1 -row 1 -column 1 -sticky w -columnspan 2
	grid $lfname.2.ephone1 -row 1 -column 3 -sticky w
	grid $lfname.2.lphone21 -row 2 -column 2 -sticky e
	grid $lfname.2.lphone22 -row 2 -column 3 -sticky e
	grid $lfname.2.lphone3 -row 3 -column 1 -sticky w
	grid $lfname.2.ephone31 -row 3 -column 2 -sticky w
	grid $lfname.2.ephone32 -row 3 -column 3 -sticky w
	grid $lfname.2.lphone4 -row 4 -column 1 -sticky w
	grid $lfname.2.ephone41 -row 4 -column 2 -sticky w
	grid $lfname.2.ephone42 -row 4 -column 3 -sticky w
	grid $lfname.2.lphone5 -row 5 -column 1 -sticky w
	grid $lfname.2.ephone51 -row 5 -column 2 -sticky w
	grid $lfname.2.ephone52 -row 5 -column 3 -sticky w
		
	
	$nb.nn compute_size
	[$nb.nn getframe personal].sw.sf compute_size
	
	#  .------------.
	# _| Appearance |________________________________________________
	::skin::setPixmap preflook preflook.gif
	::skin::setPixmap prefemotic prefemotic.gif
	::skin::setPixmap prefalerts prefalerts.gif
	#set frm [Rnotebook:frame $nb $Preftabs(appearance)]
	set frm [$nb.nn getframe appearance]
	#Scrollable frame that will contain options
	ScrolledWindow $frm.sw
	ScrollableFrame $frm.sw.sf -constrainedwidth 1
	$frm.sw setwidget $frm.sw.sf
	pack $frm.sw -anchor n -side top -expand true -fill both
	set frm [$frm.sw.sf getframe]	
	
	## General aMSN Look Options (Encoding, BGcolor, General Font, Clock Format)
	set lfname [LabelFrame:create $frm.lfname -text [trans preflook]]
	pack $frm.lfname -anchor n -side top -expand 0 -fill x
	label $lfname.plook -image [::skin::loadPixmap preflook]
	frame $lfname.1 -class Degt
#	frame $lfname.2 -class Degt
	frame $lfname.3 -class Degt
	frame $lfname.4 -class Degt
	label $lfname.1.llook -text "[trans encoding2]" -padx 10
	button $lfname.1.bencoding -text [trans encoding] -font sboldf -command "show_encodingchoose"
	pack $lfname.plook -anchor nw -side left
	pack $lfname.1 -side top -padx 0 -pady 0 -expand 1 -fill both
	pack $lfname.1.llook -side left
	pack $lfname.1.bencoding -side right -padx 15
#	label $lfname.2.llook -text "[trans bgcolor]" -padx 10
#	button $lfname.2.bbgcolor -text [trans choosebgcolor] -font sboldf -command "choose_theme"
#	pack $lfname.2 -side top -padx 0 -pady 0 -expand 1 -fill both
#	pack $lfname.2.llook -side left	
#	pack $lfname.2.bbgcolor -side right -padx 15
	label $lfname.3.llook -text "[trans preffont3]" -padx 10
	button $lfname.3.bfont -text [trans changefont] -font sboldf -command "choose_basefont"
	pack $lfname.3 -side top -padx 0 -pady 0 -expand 1 -fill both
	pack $lfname.3.llook -side left
	pack $lfname.3.bfont -side right -padx 15
	label $lfname.4.llook -text "[trans dateformat]" -padx 10
	pack $lfname.4 -side top -padx 0 -pady 0 -expand 1 -fill both
	pack $lfname.4.llook -anchor w -side top -padx 10
	radiobutton $lfname.4.mdy -text "[trans month]/[trans day]/[trans year]" -value MDY -variable [::config::getVar dateformat]
	radiobutton $lfname.4.dmy -text "[trans day]/[trans month]/[trans year]" -value DMY -variable [::config::getVar dateformat]
	radiobutton $lfname.4.ymd -text "[trans year]/[trans month]/[trans day]" -value YMD -variable [::config::getVar dateformat]
	pack $lfname.4.mdy $lfname.4.dmy $lfname.4.ymd -side left -padx 10


	## Emoticons Frame ##
	set lfname [LabelFrame:create $frm.lfname2 -text [trans prefemotic]]
	pack $frm.lfname2 -anchor n -side top -expand 0 -fill x
	label $lfname.pemotic -image [::skin::loadPixmap prefemotic]
	pack $lfname.pemotic -side left -anchor nw
	frame $lfname.1 -class Degt
	pack $lfname.1 -side left -padx 0 -pady 0 -expand 1 -fill x
	checkbutton $lfname.1.chat -text "[trans chatsmileys2]" -onvalue 1 -offvalue 0 -variable [::config::getVar chatsmileys]
	checkbutton $lfname.1.list -text "[trans listsmileys2]" -onvalue 1 -offvalue 0 -variable [::config::getVar listsmileys]
        checkbutton $lfname.1.sound -text "[trans emotisounds]" -onvalue 1 -offvalue 0 -variable [::config::getVar emotisounds]
        checkbutton $lfname.1.animated -text "[trans animatedsmileys]" -onvalue 1 -offvalue 0 -variable [::config::getVar animatedsmileys]
	#checkbutton $lfname.1.log -text "[trans logsmileys]" -onvalue 1 -offvalue 0 -variable [::config::getVar logsmileys] -state disabled
	#pack $lfname.1.chat $lfname.1.list $lfname.1.sound  $lfname.1.animated $lfname.1.log -anchor w -side top -padx 10
	pack $lfname.1.chat $lfname.1.list $lfname.1.sound  $lfname.1.animated -anchor w -side top -padx 10 -pady 0

	## Alerts and Sounds Frame ##
	set lfname [LabelFrame:create $frm.lfname3 -text [trans prefalerts]]
	pack $frm.lfname3 -anchor n -side top -expand 0 -fill x
	label $lfname.palerts -image [::skin::loadPixmap prefalerts]
	pack $lfname.palerts -side left -anchor nw
	frame $lfname.1 -class Degt
	checkbutton $lfname.1.alert1 -text "[trans shownotify]" -onvalue 1 -offvalue 0 -variable [::config::getVar shownotify]
	checkbutton $lfname.1.sound -text "[trans sound2]" -onvalue 1 -offvalue 0 -variable [::config::getVar sound]
	pack $lfname.1 -anchor w -side top -padx 0 -pady 5 -expand 1 -fill both
	pack $lfname.1.alert1 $lfname.1.sound -anchor w -side top -padx 10 -pady 0
	#Bounce icon in the dock preference for Mac OS X
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
		label $lfname.1.bouncedock -text "[trans bouncedock]" -padx 10
		pack $lfname.1.bouncedock -anchor w -side top -padx 10
		radiobutton $lfname.1.unlimited -text "[trans continuously]" -value unlimited -variable [::config::getVar dockbounce]
		radiobutton $lfname.1.once -text "[trans justonce]" -value once -variable [::config::getVar dockbounce]
		radiobutton $lfname.1.never -text "[trans never]" -value never -variable [::config::getVar dockbounce]
		pack $lfname.1.unlimited $lfname.1.once $lfname.1.never -side left -padx 10
	}
	$nb.nn compute_size
	[$nb.nn getframe appearance].sw.sf compute_size
	

	#  .---------.
	# _| Session |________________________________________________
	::skin::setPixmap prefstatus prefstatus.gif
	::skin::setPixmap prefaway prefaway.gif
	::skin::setPixmap prefmsg prefmsg.gif

	#set frm [Rnotebook:frame $nb $Preftabs(session)]
	set frm [$nb.nn getframe session]
	#Scrollable frame that will contain options
	ScrolledWindow $frm.sw
	ScrollableFrame $frm.sw.sf -constrainedwidth 1
	$frm.sw setwidget $frm.sw.sf
	pack $frm.sw -anchor n -side top -expand true -fill both
	set frm [$frm.sw.sf getframe]	
	
	## Sign In and AutoStatus Options Frame ##
	set lfname [LabelFrame:create $frm.lfname -text [trans prefsession]]
	pack $frm.lfname -anchor n -side top -expand 1 -fill x
	label $lfname.psession -image [::skin::loadPixmap prefstatus]
	pack $lfname.psession -anchor nw -side left
	frame $lfname.1 -class Degt
	frame $lfname.2 -class Degt
	frame $lfname.3 -class Degt
	checkbutton $lfname.1.lautonoact -text "[trans autonoact]" -onvalue 1 -offvalue 0 -variable [::config::getVar autoidle] -command UpdatePreferences
	entry $lfname.1.eautonoact -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0  -width 3 -textvariable [::config::getVar idletime]
	label $lfname.1.lmins -text "[trans mins]" -padx 5
	pack $lfname.1 -side top -padx 0 -expand 1 -fill both
	pack $lfname.1.lautonoact $lfname.1.eautonoact $lfname.1.lmins -side left
	checkbutton $lfname.2.lautoaway -text "[trans autoaway]" -onvalue 1 -offvalue 0 -variable [::config::getVar autoaway] -command UpdatePreferences
	entry $lfname.2.eautoaway -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0  -width 3 -textvariable [::config::getVar awaytime]
	label $lfname.2.lmins -text "[trans mins]" -padx 5
	pack $lfname.2 -side top -padx 0 -expand 1 -fill both
	pack $lfname.2.lautoaway $lfname.2.eautoaway $lfname.2.lmins -side left
	checkbutton $lfname.3.lreconnect -text "[trans reconnect2]" -onvalue 1 -offvalue 0 -variable [::config::getVar reconnect]
	checkbutton $lfname.3.lonstart -text "[trans autoconnect2]" -onvalue 1 -offvalue 0 -variable [::config::getVar autoconnect]
	checkbutton $lfname.3.lstrtoff -text "[trans startoffline2]" -onvalue 1 -offvalue 0 -variable [::config::getVar startoffline]
	pack $lfname.3 -side top -padx 0 -expand 1 -fill both
	pack $lfname.3.lreconnect $lfname.3.lonstart $lfname.3.lstrtoff -anchor w -side top

	## Away Messages Frame ##
	set lfname [LabelFrame:create $frm.lfname2 -text [trans prefawaymsg]]
	pack $frm.lfname2 -anchor n -side top -expand 1 -fill x
	label $lfname.psession -image [::skin::loadPixmap prefaway]
	pack $lfname.psession -anchor nw -side left
	frame $lfname.statelist -relief sunken -borderwidth 3
	listbox $lfname.statelist.box -yscrollcommand "$lfname.statelist.ys set" -font splainf -background \
	white -relief flat -highlightthickness 0 -height 4
	scrollbar $lfname.statelist.ys -command "$lfname.statelist.box yview" -highlightthickness 0 \
         -borderwidth 1 -elementborderwidth 2
	pack $lfname.statelist.ys -side right -fill y
	pack $lfname.statelist.box -side left -expand true -fill both
	frame $lfname.buttons -borderwidth 0
	button $lfname.buttons.add -text [trans addstate] -font sboldf -command "EditNewState 0" -width 20
	button $lfname.buttons.del -text [trans delete] -font sboldf -command "DeleteStateListBox \[$lfname.statelist.box curselection\] $lfname.statelist.box" -width 20
	button $lfname.buttons.edit -text [trans edit] -font sboldf -command "EditNewState 2 \[$lfname.statelist.box curselection\]" -width 20
	pack $lfname.buttons.add -side top
	pack $lfname.buttons.del -side top
	pack $lfname.buttons.edit -side top
	pack $lfname.statelist -anchor w -side left -padx 10 -pady 10 -expand 1 -fill both
	pack $lfname.buttons -anchor w -side right -padx 10 -pady 10 -expand 1 -fill both

	## Messaging Interface Frame ##
	set lfname [LabelFrame:create $frm.lfname3 -text [trans prefmsging]]
	pack $frm.lfname3 -anchor n -side top -expand 1 -fill x
	label $lfname.pmsging -image [::skin::loadPixmap prefmsg]
	pack $lfname.pmsging -anchor nw -side left
	frame $lfname.1 -class Degt
	frame $lfname.2 -class Degt
	frame $lfname.3 -class Degt
	
	label $lfname.1.lchatmaxmin -text [trans chatmaxmin] -padx 10
	radiobutton $lfname.1.max -text [trans raised] -value 0 -variable [::config::getVar newchatwinstate]
	
	#Don't show the minimised option on Mac OS X because that does'nt work in TkAqua
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
		#Empty 
	} else {
		radiobutton $lfname.1.min -text [trans minimised] -value 1 -variable [::config::getVar newchatwinstate]
	}
	
	radiobutton $lfname.1.no -text [trans dontshow] -value 2 -variable [::config::getVar newchatwinstate]
	pack $lfname.1.lchatmaxmin -anchor w -side top -padx 10
	
	#Don't pack the minimised option on Mac OS X because that does'nt work in TkAqua
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
		pack $lfname.1.max $lfname.1.no -side left -padx 10
	} else {
		pack $lfname.1.max $lfname.1.min $lfname.1.no -side left -padx 10
	}
	
	#Don't enable this option on Mac OS X because we can't minimized window this way with TkAqua
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
		#empty
	} else {
		label $lfname.2.lmsgmaxmin -text [trans msgmaxmin] -padx 10
		radiobutton $lfname.2.max -text [trans raised] -value 0 -variable [::config::getVar newmsgwinstate]
		radiobutton $lfname.2.min -text [trans minimised] -value 1 -variable [::config::getVar newmsgwinstate]
		pack $lfname.2.lmsgmaxmin -anchor w -side top -padx 10
		pack $lfname.2.max $lfname.2.min -side left -padx 10
	}
	
	#label $lfname.3.lmsgmode -text [trans msgmode] -padx 10
	#radiobutton $lfname.3.normal -text [trans normal] -value 1 -variable [::config::getVar msgmode] -state disabled
	#radiobutton $lfname.3.tabbed -text [trans tabbed] -value 2 -variable [::config::getVar msgmode] -state disabled
	checkbutton $lfname.winflicker -text "[trans msgflicker]" -onvalue 1 -offvalue 0 -variable [::config::getVar flicker]
	checkbutton $lfname.showdisplaypic -text "[trans showdisplaypic2]" -onvalue 1 -offvalue 0 -variable [::config::getVar showdisplaypic]

	#pack $lfname.3.lmsgmode -anchor w -side top -padx 10
	#pack $lfname.3.normal $lfname.3.tabbed -side left -padx 10

	pack $lfname.1 $lfname.2 $lfname.3 $lfname.winflicker $lfname.showdisplaypic -anchor w -side top

	$nb.nn compute_size
	[$nb.nn getframe session].sw.sf compute_size

	
	#  .------------------.
	# _| Group Management |_______________________________________
	
	::skin::setPixmap prefpersc prefpers.gif
	::skin::setPixmap prefprofilec prefprofile.gif
		
	set frm [$nb.nn getframe groups]
	ScrolledWindow $frm.sw
	ScrollableFrame $frm.sw.sf -constrainedwidth 1
	$frm.sw setwidget $frm.sw.sf
	pack $frm.sw -anchor n -side top -expand true -fill both
	set frm [$frm.sw.sf getframe]

	## frames ##
	set lfgroup [LabelFrame:create $frm.lfgroup -text [trans groups] -font splainf]
	pack $frm.lfgroup -anchor n -side top -expand 1 -fill x
	set lfcontact [LabelFrame:create $frm.lfcontact -text [trans contactlist] -font splainf]
	pack $frm.lfcontact -anchor n -side top -expand 1 -fill x

	## Group Selection Frame ##
	label $lfgroup.group -image [::skin::loadPixmap prefpersc]
	pack $lfgroup.group -side left
	frame $lfgroup.lbgroup
	pack $lfgroup.lbgroup -side left -anchor n -expand true -fill both -padx 10
	MakeGroupList $lfgroup $lfcontact
	frame $lfgroup.lbgroup.b
	pack $lfgroup.lbgroup.b -side right -anchor n -expand false
	label $lfgroup.lbgroup.b.op -text "[trans options]" -font sboldf
	pack $lfgroup.lbgroup.b.op -side top -pady 3
	
	button $lfgroup.lbgroup.b.bdel -text [trans groupdelete] -width 25 -justify right \
		-command "dlgDelGroup $lfgroup $lfcontact;"
	button $lfgroup.lbgroup.b.bren -text [trans grouprename] -width 25 -justify right \
		-command "dlgRenGroup $lfgroup $lfcontact;"
	button $lfgroup.lbgroup.b.badd -text [trans groupadd] -width 25 -justify right \
		-command "::groups::dlgAddGroup; tkwait window .dlgag; RefreshGroupList $lfgroup $lfcontact;"
	pack $lfgroup.lbgroup.b.badd -side top -pady 2 -anchor w
	pack $lfgroup.lbgroup.b.bren -side top -pady 2 -anchor w
	pack $lfgroup.lbgroup.b.bdel -side top -pady 2 -anchor w

	## Contact Selection Frame ##
	label $lfcontact.contact -image [::skin::loadPixmap prefprofilec]
	pack $lfcontact.contact -side left
	frame $lfcontact.lbcontact 
	pack $lfcontact.lbcontact -side left -anchor n -expand 1 -fill x -padx 10
	frame $lfcontact.lbcontact.fix
	pack $lfcontact.lbcontact.fix -side left -anchor n -expand 1 -fill x
	
	frame $lfcontact.lbcontact.b
	pack $lfcontact.lbcontact.b -side right -anchor n -expand 0
	label $lfcontact.lbcontact.b.op -text "[trans options]" -font sboldf
	pack $lfcontact.lbcontact.b.op -side top -pady 3
	
	button $lfcontact.lbcontact.b.badd -text [trans addacontact] -width 25 -justify right \
		-command "cmsn_draw_addcontact; tkwait window .addcontact; RefreshContactList $lfcontact;"
	button $lfcontact.lbcontact.b.bmov -text [trans movetogroup] -width 25 -justify right \
		-command "dlgMoveUser; \
			if {[winfo exists .dlgmu]} {tkwait window .dlgmu;}; \
			RefreshContactList $lfcontact;"
	button $lfcontact.lbcontact.b.bcopy -text [trans copytogroup] -width 25 -justify right \
		-command "dlgCopyUser; \
			if {[winfo exists .dlgmu]} {tkwait window .dlgmu;};"
	button $lfcontact.lbcontact.b.brfg -text [trans removefromlist] -width 25 -justify right \
		-command "dlgRFL $lfcontact;"
	button $lfcontact.lbcontact.b.bdel -text [trans delete] -width 25 -justify right \
		-command "dlgDelUser $lfcontact;"
	button $lfcontact.lbcontact.b.bdal -text [trans emptygroup] -width 25 -justify right \
		-command "BuidarGrup $lfcontact;"
	pack $lfcontact.lbcontact.b.badd -side top -pady 2 -anchor w
	pack $lfcontact.lbcontact.b.bmov -side top -pady 2 -anchor w
	pack $lfcontact.lbcontact.b.bcopy -side top -pady 2 -anchor w
	pack $lfcontact.lbcontact.b.brfg -side top -pady 2 -anchor w
	pack $lfcontact.lbcontact.b.bdal -side top -pady 2 -anchor w
	pack $lfcontact.lbcontact.b.bdel -side top -pady 2 -anchor w
	
	#compute_size
	$nb.nn compute_size
	[$nb.nn getframe groups].sw.sf compute_size


	#  .--------.
	# _| Loging |________________________________________________
	::skin::setPixmap prefhist prefhist.gif
	::skin::setPixmap prefhist2 prefhist2.gif
#	::skin::setPixmap prefhist3 prefhist3.gif

	#set frm [Rnotebook:frame $nb $Preftabs(loging)]
	set frm [$nb.nn getframe loging]

	## Loging Options Frame ##
	set lfname [LabelFrame:create $frm.lfname -text [trans preflog1]]
	pack $frm.lfname -anchor n -side top -expand 0 -fill x
	label $lfname.plog1 -image [::skin::loadPixmap prefhist]
	pack $lfname.plog1 -anchor nw -side left
	checkbutton $lfname.log -text "[trans keeplog2]" -onvalue 1 -offvalue 0 -variable [::config::getVar keep_logs]
	checkbutton $lfname.date -text "[trans logsbydate]" -onvalue 1 -offvalue 0 -variable [::config::getVar logsbydate]
	pack $lfname.log -anchor w
	pack $lfname.date -anchor w


#/////////TODO Add style log feature
#	frame $lfname.2 -class Degt
#	label $lfname.2.lstyle -text "[trans stylelog]" -padx 10
#	radiobutton $lfname.2.hist -text [trans stylechat] -value 1 -variable [::config::getVar logstyle] -state disabled
#	radiobutton $lfname.2.chat -text [trans stylehist] -value 2 -variable [::config::getVar logstyle] -state disabled
#	pack $lfname.2.lstyle -anchor w -side top -padx 10
#	pack $lfname.2.hist $lfname.2.chat -side left -padx 10
#	pack $lfname.2 -anchor w -side top -expand 1 -fill x
	
	## Clear All Logs Frame ##
	set lfname [LabelFrame:create $frm.lfname2 -text [trans clearlog]]
	pack $frm.lfname2 -anchor n -side top -expand 0 -fill x
	label $lfname.plog1 -image [::skin::loadPixmap prefhist2]
	pack $lfname.plog1 -anchor nw -side left
	frame $lfname.1 -class Degt
	label $lfname.1.lclear -text "[trans clearlog2]" -padx 10
	button $lfname.1.bclear -text [trans clearlog3] -font sboldf -command "::log::ClearAllLogs"
	pack $lfname.1.lclear -side left	
	pack $lfname.1.bclear -side right -padx 15
	pack $lfname.1 -anchor w -side top -expand 0 -fill x
#////////TODO: Add logs expiry feature
	## Logs Expiry Frame ##
#	set lfname [LabelFrame:create $frm.lfname3 -text [trans logfandexp]]
#	pack $frm.lfname3 -anchor n -side top -expand 1 -fill x
#	label $lfname.plog1 -image [::skin::loadPixmap prefhist3]
#	pack $lfname.plog1 -anchor nw -side left
#	frame $lfname.1 -class Degt
#	checkbutton $lfname.1.lolder -text "[trans logolder]" -onvalue 1 -offvalue 0 -variable [::config::getVar logexpiry] -state disabled
#	entry $lfname.1.eolder -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0  -width 3 -state disabled
#	label $lfname.1.ldays -text "[trans days]" -padx 5
#	pack $lfname.1 -side top -padx 0 -expand 1 -fill both
#	pack $lfname.1.lolder $lfname.1.eolder $lfname.1.ldays -side left
#	frame $lfname.2 -class Degt
#	checkbutton $lfname.2.lbigger -text "[trans logbigger]" -onvalue 1 -offvalue 0 -variable [::config::getVar logmaxsize] -state disabled
#	entry $lfname.2.ebigger -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0  -width 3 -state disabled
#	label $lfname.2.lmbs -text "MBs" -padx 5
#	pack $lfname.2 -side top -padx 0 -expand 1 -fill both
#	pack $lfname.2.lbigger $lfname.2.ebigger $lfname.2.lmbs -side left


	## Eventlogging frame ## ***
	set lfname [LabelFrame:create $frm.lfname3 -text [trans preflogevent]]
	pack $frm.lfname3 -anchor n -side top -expand 0 -fill x
	label $lfname.plog1
	grid $lfname.plog1 -columnspan 2
	checkbutton $lfname.displayconnect -text "[trans displayeventconnect]" -onvalue 1 -offvalue 0 -variable [::config::getVar display_event_connect]
	checkbutton $lfname.displaydisconnect -text "[trans displayeventdisconnect]" -onvalue 1 -offvalue 0 -variable [::config::getVar display_event_disconnect]
	checkbutton $lfname.displayemail -text "[trans displayeventemail]" -onvalue 1 -offvalue 0 -variable [::config::getVar display_event_email]
	checkbutton $lfname.displaystate -text "[trans displayeventstate]" -onvalue 1 -offvalue 0 -variable [::config::getVar display_event_state]
	checkbutton $lfname.logconnect -text "[trans logeventconnect]" -onvalue 1 -offvalue 0 -variable [::config::getVar log_event_connect]
	checkbutton $lfname.logdisconnect -text "[trans logeventdisconnect]" -onvalue 1 -offvalue 0 -variable [::config::getVar log_event_disconnect]
	checkbutton $lfname.logemail -text "[trans logeventemail]" -onvalue 1 -offvalue 0 -variable [::config::getVar log_event_email]
	checkbutton $lfname.logstate -text "[trans logeventstate]" -onvalue 1 -offvalue 0 -variable [::config::getVar log_event_state]
	grid $lfname.displayconnect -row 0 -column 0 -sticky w
	grid $lfname.displaydisconnect -row 1 -column 0 -sticky w
	grid $lfname.displayemail -row 2 -column 0 -sticky w
	grid $lfname.displaystate -row 3 -column 0 -sticky w
	grid $lfname.logconnect -row 0 -column 1 -sticky w
	grid $lfname.logdisconnect -row 1 -column 1 -sticky w
	grid $lfname.logemail -row 2 -column 1 -sticky w
	grid $lfname.logstate -row 3 -column 1 -sticky w


	#  .------------.
	# _| Connection |________________________________________________
	
	::skin::setPixmap prefnat prefnat.gif
	::skin::setPixmap prefproxy prefproxy.gif
	::skin::setPixmap prefremote prefpers.gif

	#set frm [Rnotebook:frame $nb $Preftabs(connection)]
	set frm [$nb.nn getframe connection]
	#Scrollable frame that will contain options
	ScrolledWindow $frm.sw
	ScrollableFrame $frm.sw.sf -constrainedwidth 1
	$frm.sw setwidget $frm.sw.sf
	pack $frm.sw -anchor n -side top -expand true -fill both
	set frm [$frm.sw.sf getframe]	
	
	## Connection Frame ##
	set lfname [LabelFrame:create $frm.lfnameconnection -text [trans prefconnection]]
	pack $frm.lfnameconnection -anchor n -side top -expand 1 -fill x
	label $lfname.pshared -image [::skin::loadPixmap prefproxy]
	pack $lfname.pshared -side left -anchor nw	
	
	frame $lfname.1 -class Degt
	frame $lfname.2 -class Degt
	frame $lfname.3 -class Degt
	frame $lfname.4 -class Degt
	frame $lfname.5 -class Degt
	radiobutton $lfname.1.direct -text "[trans directconnection]" -value direct -variable [::config::getVar connectiontype] -command UpdatePreferences
	pack $lfname.1.direct -anchor w -side top -padx 10
	radiobutton $lfname.2.http -text "[trans httpconnection]" -value http -variable [::config::getVar connectiontype] -command UpdatePreferences
	pack $lfname.2.http -anchor w -side top -padx 10
	radiobutton $lfname.3.proxy -text "[trans proxyconnection]" -value proxy -variable [::config::getVar connectiontype] -command UpdatePreferences
	pack $lfname.3.proxy -anchor w -side top -padx 10

	#checkbutton $lfname.1.proxy -text "[trans proxy]" -onvalue 1 -offvalue 0 -variable [::config::getVar withproxy]
	#pack $lfname.1.proxy -anchor w -side top -padx 10

	#radiobutton $lfname.2.http -text "HTTP" -value http -variable [::config::getVar proxytype]
	#radiobutton $lfname.2.socks5 -text "SOCKS5" -value socks -variable [::config::getVar proxytype] -state disabled
	#pack $lfname.2.http $lfname.2.socks5 -anchor w -side left -padx 10

	pack $lfname.1 $lfname.2 $lfname.3 $lfname.4 $lfname.5 -anchor w -side top -padx 0 -pady 0 -expand 1 -fill both

	radiobutton $lfname.4.post -text "HTTP (POST method)" -value http -variable [::config::getVar proxytype] -command UpdatePreferences
	radiobutton $lfname.4.ssl -text "SSL (CONNECT method)" -value ssl -variable [::config::getVar proxytype] -command UpdatePreferences
	radiobutton $lfname.4.socks5 -text "SOCKS5" -value socks5 -variable [::config::getVar proxytype] -command UpdatePreferences 

	grid $lfname.4.post -row 1 -column 1 -sticky w -pady 5 -padx 10
	grid $lfname.4.ssl -row 1 -column 2 -sticky w -pady 5 -padx 10
	grid $lfname.4.socks5 -row 1 -column 3 -sticky w -pady 5 -padx 10

		
	label $lfname.5.lserver -text "[trans server] :" -padx 5 -font sboldf
	entry $lfname.5.server -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 20 -textvariable proxy_server
	label $lfname.5.lport -text "[trans port] :" -padx 5 -font sboldf
	entry $lfname.5.port -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 5 -textvariable proxy_port
	label $lfname.5.luser -text "[trans user] :" -padx 5 -font sboldf
	entry $lfname.5.user -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 20 -textvariable proxy_user
	label $lfname.5.lpass -text "[trans pass] :" -padx 5 -font sboldf
	entry $lfname.5.pass -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 20 -show "*" -textvariable proxy_pass
	grid $lfname.5.lserver -row 2 -column 1 -sticky e
	grid $lfname.5.server -row 2 -column 2 -sticky w -pady 5
	grid $lfname.5.lport -row 2 -column 3 -sticky e
	grid $lfname.5.port -row 2 -column 4 -sticky w -pady 5
	grid $lfname.5.luser -row 3 -column 1 -sticky e
	grid $lfname.5.user -row 3 -column 2 -sticky w
	grid $lfname.5.lpass -row 3 -column 3 -sticky e
	grid $lfname.5.pass -row 3 -column 4 -sticky w

	## NAT (or similar) Frame ##
	set lfname [LabelFrame:create $frm.lfname -text [trans prefft]]
	pack $frm.lfname -anchor n -side top -expand 1 -fill x
	label $lfname.pshared -image [::skin::loadPixmap prefnat]
	pack $lfname.pshared -side left -anchor nw
	frame $lfname.1 -class Degt
	pack $lfname.1 -side left -padx 0 -pady 5 -expand 1 -fill both
    
        checkbutton $lfname.1.autoaccept -text "[trans autoacceptft]" -onvalue 1 -offvalue 0 -variable [::config::getVar autoaccept]
	frame $lfname.1.ftport -class Deft
	label $lfname.1.ftport.text -text "[trans ftportpref] :" -padx 5 -font splainf
	entry $lfname.1.ftport.entry -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 5 -textvariable [::config::getVar initialftport]
	grid $lfname.1.ftport.text -row 1 -column 1 -sticky w -pady 5 -padx 0
	grid $lfname.1.ftport.entry -row 1 -column 2 -sticky w -pady 5 -padx 3

        checkbutton $lfname.1.autoip -text "[trans autodetectip]" -onvalue 1 -offvalue 0 -variable [::config::getVar autoftip] -command UpdatePreferences
	frame $lfname.1.ipaddr -class Deft
	label $lfname.1.ipaddr.text -text "[trans ipaddress] :" -padx 5 -font splainf
	entry $lfname.1.ipaddr.entry -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 15 -textvariable [::config::getVar manualip]
	grid $lfname.1.ipaddr.text -row 1 -column 1 -sticky w -pady 5 -padx 0
	grid $lfname.1.ipaddr.entry -row 1 -column 2 -sticky w -pady 5 -padx 3	
		
	pack $lfname.1.autoaccept $lfname.1.ftport $lfname.1.autoip $lfname.1.ipaddr -anchor w -side top -padx 10
	
	    
        ## Remote Control Frame ##
        set lfname [LabelFrame:create $frm.lfname3 -text [trans prefremote]]
        pack $frm.lfname3 -anchor n -side top -expand 1 -fill x
	label $lfname.pshared -image [::skin::loadPixmap prefremote]
	pack $lfname.pshared -side left -anchor nw
	frame $lfname.1 -class Degt
        frame $lfname.2 -class Degt
	pack $lfname.1 -side left -padx 0 -pady 5 -expand 1 -fill both
	checkbutton $lfname.1.eremote -text "[trans enableremote]" -onvalue 1 -offvalue 0 -variable [::config::getVar enableremote] -command UpdatePreferences
	pack $lfname.1.eremote  -anchor w -side top -padx 10
	pack $lfname.1 $lfname.2  -anchor w -side top -padx 0 -pady 0 -expand 1 -fill both
	label $lfname.2.lpass -text "[trans pass] :" -padx 5 -font sboldf
	entry $lfname.2.pass -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0 -width 20 -show "*"
	grid $lfname.2.lpass -row 2 -column 3 -sticky e
	grid $lfname.2.pass -row 2 -column 4 -sticky w

	$nb.nn compute_size
	[$nb.nn getframe connection].sw.sf compute_size

	#  .--------------.
	# _| Others |________________________________________________
	::skin::setPixmap prefapps prefpers.gif

	#set frm [Rnotebook:frame $nb $Preftabs(others)]
	set frm [$nb.nn getframe others]
	
	#Scrollable frame that will contain options
	ScrolledWindow $frm.sw
	ScrollableFrame $frm.sw.sf -constrainedwidth 1
	$frm.sw setwidget $frm.sw.sf
	pack $frm.sw -anchor n -side top -expand true -fill both
	set frm [$frm.sw.sf getframe]	
	
	## Delete Profiles Frame ##
	set lfname [LabelFrame:create $frm.lfname3 -text [trans prefprofile3]]
	pack $frm.lfname3 -anchor n -side top -expand 1 -fill x
	label $lfname.pprofile -image [::skin::loadPixmap prefapps]
	pack $lfname.pprofile -side left -anchor nw
	frame $lfname.1 -class Degt
	label $lfname.1.ldelprofile -text "[trans delprofile2]" -font sboldf -padx 5
	combobox::combobox $lfname.1.profile -editable true -highlightthickness 0 -width 22 -bg #FFFFFF -font splainf
	button $lfname.1.bdel -text [trans delprofile] -command "DeleteProfile \[${lfname}.1.profile get\] $lfname.1.profile"
	grid $lfname.1.ldelprofile -row 1 -column 1 -sticky w
	grid $lfname.1.profile -row 1 -column 2 -sticky w
	grid $lfname.1.bdel -row 1 -column 3 -padx 5 -sticky w
	pack $lfname.1 -anchor w -side top -expand 0 -fill none
		
	## Applications Frame ##
	set lfname [LabelFrame:create $frm.lfname -text [trans prefapps]]
	pack $frm.lfname -anchor n -side top -expand 1 -fill x
	label $lfname.pshared -image [::skin::loadPixmap prefapps]
	pack $lfname.pshared -side left -anchor nw
	frame $lfname.1 -class Degt
	pack $lfname.1 -anchor w -side left -padx 0 -pady 5 -expand 0 -fill both
	label $lfname.1.lbrowser -text "[trans browser] :" -padx 5 -font sboldf
	entry $lfname.1.browser -bg #FFFFFF -bd 1 -highlightthickness 0 -width 40 -textvariable [::config::getVar browser]
	label $lfname.1.lbrowserex -text "[trans browserexample]" -font examplef
	label $lfname.1.lfileman -text "[trans fileman] :" -padx 5 -font sboldf
	entry $lfname.1.fileman -bg #FFFFFF -bd 1 -highlightthickness 0 -width 40 -textvariable [::config::getVar filemanager]
	label $lfname.1.lfilemanex -text "[trans filemanexample]" -font examplef
	label $lfname.1.lmailer -text "[trans mailer] :" -padx 5 -font sboldf
	entry $lfname.1.mailer -bg #FFFFFF -bd 1 -highlightthickness 0 -width 40 -textvariable [::config::getVar mailcommand]
	label $lfname.1.lmailerex -text "[trans mailerexample]" -font examplef
	
	#aMSN for Mac OS X always use "QuickTimeTCL" (except in Alarms) so don't let mac user choose sound player
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
	#Empty
	} else {
		label $lfname.1.lsound -text "[trans soundserver] :" -padx 5 -font sboldf
		frame $lfname.1.sound -class Degt
	
		radiobutton $lfname.1.sound.snack -text "[trans usesnack]" -value 1 -variable [::config::getVar usesnack] -command UpdatePreferences
		pack $lfname.1.sound.snack -anchor w -side top -padx 10
		radiobutton $lfname.1.sound.other -text "[trans useother]" -value 0 -variable [::config::getVar usesnack] -command UpdatePreferences
		pack $lfname.1.sound.other -anchor w -side top -padx 10
		entry $lfname.1.sound.sound -bg #FFFFFF -bd 1 -highlightthickness 0 -width 40 -textvariable [::config::getVar soundcommand]
		pack $lfname.1.sound.sound -anchor w -side top -padx 10
		label $lfname.1.sound.lsoundex -text "[trans soundexample]" -font examplef
		pack $lfname.1.sound.lsoundex -anchor w -side top -padx 10
	}
	
	grid $lfname.1.lbrowser -row 1 -column 1 -sticky w
	grid $lfname.1.browser -row 1 -column 2 -sticky w
	grid $lfname.1.lbrowserex -row 2 -column 2 -columnspan 1 -sticky w
	grid $lfname.1.lfileman -row 3 -column 1 -sticky w
	grid $lfname.1.fileman -row 3 -column 2 -sticky w
	grid $lfname.1.lfilemanex -row 4 -column 2 -columnspan 1 -sticky w
	grid $lfname.1.lmailer -row 5 -column 1 -sticky w
	grid $lfname.1.mailer -row 5 -column 2 -sticky w
	grid $lfname.1.lmailerex -row 6 -column 2 -columnspan 1 -sticky w
	
	#aMSN for Mac OS X always use "QuickTimeTCL" (except in Alarms) so don't let mac user choose sound player
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
	#Empty
	} else {
		grid $lfname.1.lsound -row 7 -column 1 -sticky nw
		grid $lfname.1.sound -row 7 -column 2 -sticky w
		#grid $lfname.1.lsoundex -row 8 -column 2 -columnspan 1 -sticky w
	}
	

	## Library directories frame ##
	set lfname [LabelFrame:create $frm.lfname2 -text [trans preflibs]]
	pack $frm.lfname2 -anchor n -side top -expand 1 -fill x
	label $lfname.pshared -image [::skin::loadPixmap prefapps]
	pack $lfname.pshared -side left -anchor nw

	frame $lfname.1 -class Degt
	pack $lfname.1 -anchor w -side left -padx 0 -pady 5 -fill none
	label $lfname.1.llibtls -text "TLS" -padx 5 -font sboldf
	entry $lfname.1.libtls -bg #FFFFFF -bd 1 -width 45 -highlightthickness 0 -textvariable libtls_temp
	label $lfname.1.llibtlsexp -text [trans tlsexplain] -justify left -font examplef
	button $lfname.1.browsetls -text [trans browse] -command "Browse_Dialog_dir libtls_temp"

	label $lfname.1.lconvertpath -text "CONVERT" -padx 5 -font sboldf
	entry $lfname.1.convertpath -bg #FFFFFF -bd 1 -width 45 -highlightthickness 0 -textvariable [::config::getVar convertpath]
	label $lfname.1.lconvertpathexp -text [trans convertexplain] -justify left -font examplef
	button $lfname.1.browseconv -text [trans browse] -command "Browse_Dialog_file [::config::getVar convertpath]"



	grid $lfname.1.llibtls -row 1 -column 1 -sticky w
	grid $lfname.1.libtls  -row 1 -column 2 -sticky w
	grid $lfname.1.browsetls  -row 1 -column 3 -padx 5 -sticky w
	grid $lfname.1.llibtlsexp  -row 2 -column 2 -columnspan 3 -sticky w
	grid $lfname.1.lconvertpath -row 3 -column 1 -sticky w
	grid $lfname.1.convertpath  -row 3 -column 2 -sticky w
	grid $lfname.1.browseconv  -row 3 -column 3 -padx 5 -sticky w
	grid $lfname.1.lconvertpathexp  -row 4 -column 2 -columnspan 3 -sticky w


	$nb.nn compute_size
	[$nb.nn getframe others].sw.sf compute_size

	#  .----------.
	# _| Advanced |________________________________________________

	#set frm [Rnotebook:frame $nb $Preftabs(advanced)]
	set frm [$nb.nn getframe advanced]
	
	set lfname [LabelFrame:create $frm.lfname -text [trans advancedprefs]]
	pack $frm.lfname -anchor n -side top -expand true -fill both
	
	#Scrollable frame that will contain advanced optoins
	ScrolledWindow $lfname.sw
	ScrollableFrame $lfname.sw.sf -constrainedwidth 1
	$lfname.sw setwidget $lfname.sw.sf
	set path [$lfname.sw.sf getframe]	
	pack $lfname.sw -anchor n -side top -expand true -fill both
	
	reload_advanced_options $path

	frame $path.2 -class Degt

	label $path.2.delimiters -text "[trans delimiters]" -padx 5
	entry $path.2.ldelimiter -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0  -width 3 -textvariable [::config::getVar leftdelimiter]
	label $path.2.example -text "HH:MM:SS" -padx 5
	entry $path.2.rdelimiter -bg #FFFFFF -bd 1 -font splainf -highlightthickness 0  -width 3 -textvariable [::config::getVar rightdelimiter]
	pack $path.2 -side top -padx 0 -fill x
	pack $path.2.delimiters $path.2.ldelimiter $path.2.example $path.2.rdelimiter -side left

	$nb.nn compute_size
	$lfname.sw.sf compute_width
	
	
	#  .----------.
	# _| Privacy |________________________________________________
	#set frm [Rnotebook:frame $nb $Preftabs(privacy)]
	set frm [$nb.nn getframe privacy]

         # Allow/Block lists
	set lfname [LabelFrame:create $frm.lfname -text [trans prefprivacy]]
	pack $frm.lfname -anchor n -side top -expand 1 -fill both
	label $lfname.pprivacy -image [::skin::loadPixmap prefapps]
	pack $lfname.pprivacy -anchor nw -side left

	frame $lfname.allowlist -relief sunken -borderwidth 3
        label $lfname.allowlist.label -text "[trans allowlist]"
	listbox $lfname.allowlist.box -yscrollcommand "$lfname.allowlist.ys set" -font splainf -background \
	white -relief flat -highlightthickness 0  -height 5
	scrollbar $lfname.allowlist.ys -command "$lfname.allowlist.box yview" -highlightthickness 0 \
         -borderwidth 1 -elementborderwidth 2
        pack $lfname.allowlist.label $lfname.allowlist.box -side top -expand false
	pack $lfname.allowlist.ys -side right -fill y
        pack $lfname.allowlist.box -side left -expand true -fill both


        frame $lfname.blocklist -relief sunken -borderwidth 3
        label $lfname.blocklist.label -text "[trans blocklist]"
	listbox $lfname.blocklist.box -yscrollcommand "$lfname.blocklist.ys set" -font splainf -background \
	white -relief flat -highlightthickness 0  -height 5
	scrollbar $lfname.blocklist.ys -command "$lfname.blocklist.box yview" -highlightthickness 0 \
         -borderwidth 1 -elementborderwidth 2
        pack $lfname.blocklist.label $lfname.blocklist.box -side top -expand false
	pack $lfname.blocklist.ys -side right -fill y
	pack $lfname.blocklist.box -side left -expand true -fill both


	frame $lfname.buttons -borderwidth 0
	button $lfname.buttons.right -text "[trans move] -->" -font sboldf -command "Allow_to_Block $lfname" -width 10
	button $lfname.buttons.left -text "<-- [trans move]" -font sboldf -command "Block_to_Allow $lfname" -width 10
	pack $lfname.buttons.right $lfname.buttons.left  -side top

        label $lfname.status -text ""
	frame $lfname.allowframe
        radiobutton $lfname.allowframe.allowallbutbl -text "[trans allowallbutbl]" -value 1 -variable temp_BLP
	radiobutton $lfname.allowframe.allowonlyinal -text "[trans allowonlyinal]" -value 0 -variable temp_BLP
	grid $lfname.allowframe.allowallbutbl -row 1 -column 1 -sticky w
	grid $lfname.allowframe.allowonlyinal -row 2 -column 1 -sticky w
        pack $lfname.status $lfname.allowframe -side bottom -anchor w -fill x
	pack $lfname.allowlist $lfname.buttons $lfname.blocklist -anchor w -side left -padx 10 -pady 10 -expand 1 -fill both

        bind $lfname.allowlist.box <Button3-ButtonRelease> "create_users_list_popup $lfname \"allow\" %X %Y"
        bind $lfname.blocklist.box <Button3-ButtonRelease> "create_users_list_popup $lfname \"block\" %X %Y"


        # Contact/Reverse lists
	set lfname [LabelFrame:create $frm.lfname2 -text [trans prefprivacy2]]
	pack $frm.lfname2 -anchor n -side top -expand 1 -fill both
	label $lfname.pprivacy -image [::skin::loadPixmap prefapps]
	pack $lfname.pprivacy -anchor nw -side left

	frame $lfname.contactlist -relief sunken -borderwidth 3
        label $lfname.contactlist.label -text "[trans contactlist]"
	listbox $lfname.contactlist.box -yscrollcommand "$lfname.contactlist.ys set" -font splainf -background \
	white -relief flat -highlightthickness 0 -height 5
	scrollbar $lfname.contactlist.ys -command "$lfname.contactlist.box yview" -highlightthickness 0 \
         -borderwidth 1 -elementborderwidth 2
        pack $lfname.contactlist.label $lfname.contactlist.box -side top -expand false
	pack $lfname.contactlist.ys -side right -fill y
	pack $lfname.contactlist.box -side left -expand true -fill both
  
	frame $lfname.reverselist -relief sunken -borderwidth 3
        label $lfname.reverselist.label -text "[trans reverselist]"
	listbox $lfname.reverselist.box -yscrollcommand "$lfname.reverselist.ys set" -font splainf -background \
	white -relief flat -highlightthickness 0  -height 5
	scrollbar $lfname.reverselist.ys -command "$lfname.reverselist.box yview" -highlightthickness 0 \
         -borderwidth 1 -elementborderwidth 2
        pack $lfname.reverselist.label $lfname.reverselist.box -side top -expand false
	pack $lfname.reverselist.ys -side right -fill y
	pack $lfname.reverselist.box -side left -expand true -fill both

        frame $lfname.adding
        entry $lfname.adding.enter -bg white
        button $lfname.adding.addal -text "[trans addto AL]" -command "Add_To_List $lfname AL"
        button $lfname.adding.addbl -text "[trans addto BL]" -command "Add_To_List $lfname BL"
        button $lfname.adding.addfl -text "[trans addto FL]" -command "Add_To_List $lfname FL" 
        pack $lfname.adding.addal $lfname.adding.addbl $lfname.adding.addfl -side left
        pack $lfname.adding.enter -side top


	frame $lfname.buttons -borderwidth 0
	button $lfname.buttons.right -text "[trans delete] -->" -font sboldf -command "Remove_Contact $lfname" -width 10
	button $lfname.buttons.left -text "<-- [trans copy]" -font sboldf -command "Reverse_to_Contact $lfname" -width 10
	pack $lfname.adding  $lfname.buttons.right $lfname.buttons.left -side top


 #       pack $lfname.addal $lfname.addbl $lfname.addfl -side left

 #    	grid $lfname.enter -row 3 -column 1 -sticky w 
 #	grid $lfname.addal -row 4 -column 1 -sticky w 
 #	grid $lfname.addbl -row 4 -column 2 -sticky w 
 #	grid $lfname.addfl -row 4 -column 3 -sticky w 

        label $lfname.status -text ""

        pack $lfname.status -side bottom  -anchor w  -fill x
	pack $lfname.contactlist $lfname.buttons $lfname.reverselist -anchor w -side left -padx 10 -pady 10 -expand 1 -fill both

        bind $lfname.contactlist.box <Button3-ButtonRelease> "create_users_list_popup $lfname \"contact\" %X %Y"
        bind $lfname.reverselist.box <Button3-ButtonRelease> "create_users_list_popup $lfname \"reverse\" %X %Y"
	
  

	#  .----------.
	# _| Blocking |________________________________________________
	#set frm [Rnotebook:frame $nb $Preftabs(blocking)]
	
	## Check on disconnect ##
	#set lfname [LabelFrame:create $frm.lfname -text [trans prefblock1]]
	#pack $frm.lfname -anchor n -side top -expand 1 -fill x
	#label $lfname.ppref1 -image [::skin::loadPixmap prefapps]
	#pack $lfname.ppref1 -side left -padx 5 -pady 5 
	#checkbutton $lfname.enable -text "[trans checkonfln]" -onvalue 1 -offvalue 0 -variable [::config::getVar checkonfln]
	#pack $lfname.enable  -anchor w -side left -padx 0 -pady 5 

	## "You have been blocked" group ##
	#set lfname [LabelFrame:create $frm.lfname3 -text [trans prefblock3]]
	#pack $frm.lfname3 -anchor n -side top -expand 1 -fill x
	#label $lfname.ppref3 -image [::skin::loadPixmap prefapps]
	#pack $lfname.ppref3 -side left -padx 5 -pady 5 
	#checkbutton $lfname.group -text "[trans blockedyougroup]" -onvalue 1 -offvalue 0 -variable [::config::getVar showblockedgroup]
	#pack $lfname.group  -anchor w -side left -padx 0 -pady 5 

	## Continuously check ##
	#set lfname [LabelFrame:create $frm.lfname2 -text [trans prefblock2]]
	#pack $frm.lfname2 -anchor n -side top -expand 1 -fill x
	#label $lfname.ppref2 -image [::skin::loadPixmap prefapps]
	#pack $lfname.ppref2 -side left -padx 5 -pady 5 

	#frame $lfname.enable -class Degt
	#pack $lfname.enable -anchor w -side left 
	#checkbutton $lfname.enable.cb -text "[trans checkblocking]" -onvalue 1 -offvalue 0 -variable [::config::getVar checkblocking] -command UpdatePreferences
	#grid $lfname.enable.cb -row 1 -column 1 -sticky w

	#frame $lfname.check -class Degt
	#pack $lfname.check -anchor w -side left -padx 0 -pady 5 

        #label $lfname.check.linter1 -text "[trans blockinter1]"
        #label $lfname.check.linter2 -text "[trans blockinter2]"
        #label $lfname.check.linter3 -text "[trans blockinter3]"
        #label $lfname.check.linter4 -text "[trans blockinter4]"
        #label $lfname.check.lusers -text "[trans blockusers]"
        #entry $lfname.check.inter1 -validate all -vcmd "BlockValidateEntry %W %P 1" -invcmd "BlockValidateEntry %W %P 0 15" -width 4 -textvariable [::config::getVar blockinter1]
        #entry $lfname.check.inter2 -validate all -vcmd "BlockValidateEntry %W %P 2" -invcmd "BlockValidateEntry %W %P 0 30"  -width 4 -textvariable [::config::getVar blockinter2]
        #entry $lfname.check.inter3 -validate all -vcmd "BlockValidateEntry %W %P 3" -invcmd "BlockValidateEntry %W %P 0 2" -width 4 -textvariable [::config::getVar blockinter3]
        #entry $lfname.check.users -validate all -vcmd "BlockValidateEntry %W %P 4" -invcmd "BlockValidateEntry %W %P 0 5" -width 4 -textvariable [::config::getVar blockusers]

        #grid $lfname.check.linter1 -row 1 -column 1 -sticky w
        #grid $lfname.check.linter2 -row 1 -column 3 -sticky w
        #grid $lfname.check.linter3 -row 2 -column 3 -sticky w
        #grid $lfname.check.linter4 -row 2 -column 5 -sticky w
        #grid $lfname.check.lusers -row 2 -column 1 -sticky w
        #grid $lfname.check.inter1 -row 1 -column 2 -sticky w
        #grid $lfname.check.inter2 -row 1 -column 4 -sticky w
        #grid $lfname.check.inter3 -row 2 -column 4 -sticky w
        #grid $lfname.check.users -row 2 -column 2 -sticky w

	#pack $lfname.enable $lfname.check -anchor w -side top 

	#frame $frm.dummy -class Degt
	#pack $frm.dummy -anchor n -side top -expand 1 -fill both -pady 150

    # Frame for common buttons (all preferences)
    frame .cfg.buttons -class Degt
    button .cfg.buttons.save -text [trans save] -font sboldf -command "SavePreferences; destroy .cfg"
    button .cfg.buttons.cancel -text [trans close] -font sboldf -command "destroy .cfg"
    bind .cfg <<Escape>> "destroy .cfg"
    pack .cfg.buttons.save .cfg.buttons.cancel -side right -padx 10 -pady 5
    pack .cfg.buttons -side bottom -fill x

    
    #Rnotebook:totalwidth $nb
    $nb.nn raise personal
    $nb.nn compute_size
    pack $nb.nn -expand true -fill both
    #pack $nb -fill both -expand 1 -padx 10 -pady 10

    pack .cfg.notebook -side bottom -fill both -expand true -padx 5 -pady 5
    
    
    InitPref 1
    UpdatePreferences

    #wm geometry .cfg [expr [Rnotebook:totalwidth $nb] + 50]x595

    #catch { Rnotebook:raise $nb $Preftabs($settings) }

    
    bind .cfg <Destroy> "RestorePreferences %W"

    wm state .cfg normal

    moveinscreen .cfg 30
    
}

#check if a window is outside the screen and move it in
proc moveinscreen {window {mindist 0}} {
	update

	set winx [winfo width $window]
	set winy [winfo height $window]
	set scrx [winfo screenwidth .]
	set scry [winfo screenheight .]
	set winpx [winfo x $window]
	set winpy [winfo y $window]

	#check if the window is too large to fit on the screen
	if { [expr "$winx > ($scrx-(2*$mindist))"] } {
		set winx [expr "$scrx-(2*$mindist)"]
	}
	if { [expr "$winy > ($scry-(2*$mindist))"] } {
		set winy [expr "$scry-(2*$mindist)"]
	}
	
	#check if the window is positioned off the screen
	if { [expr "$winpx + $winx > ($scrx-$mindist)"] } {
		set winpx [expr "$scrx-$mindist-$winx"]
	}
	if { [expr "$winpx < $mindist"] } {
		set winpx $mindist
	}
	if { [expr "$winpy + $winy > ($scry-$mindist)"] } {
		set winpy [expr "$scry-$mindist-$winy"]
	}
	if { [expr "$winpy < $mindist"] } {
		set winpy $mindist
	}

	wm geometry $window "${winx}x${winy}+${winpx}+${winpy}"
}

proc reload_advanced_options {path} {
	global advanced_options

	set i 0
	foreach opt $advanced_options {
		incr i	
		#For each advanced option, check if it's a title, it's local config, or global configs
		if {[lindex $opt 0] == "title" } {
			if { $i != 1 } {
				label $path.sp$i -font bboldf
				label $path.l$i -font bboldf -text "[trans [lindex $opt 1]]"
				pack $path.sp$i $path.l$i -side top -anchor w -pady 4
			} else {
				label $path.l$i -font bboldf -text "[trans [lindex $opt 1]]"
				pack $path.l$i -side top -anchor w -pady 4
			}
		} else {
			if {[lindex $opt 0] == "local"} {
				set config_var [::config::getVar [lindex $opt 1]]
			} elseif {[lindex $opt 0] == "global"} {
				set config_var [::config::getGlobalVar [lindex $opt 1]]
			} else {
				label $path.l$i -text "ERROR: Unknown advanced option type: \"[lindex $opt 0]\""
				pack $path.l$i -side top -anchor w
				continue
			}
			
			switch [lindex $opt 2] {
				bool {
					checkbutton $path.cb$i -text [trans [lindex $opt 3]] -font splainf -variable $config_var
					pack $path.cb$i -side top -anchor w
				}
				folder {
					frame $path.fr$i
					button $path.fr$i.browse -text [trans browse] -command "Browse_Dialog_dir [::config::getVar [lindex $opt 1]]"
					LabelEntry $path.fr$i.le "[trans [lindex $opt 3]]:" $config_var 20
					pack $path.fr$i.le -side left -anchor w -expand true -fill x
					pack $path.fr$i.browse -side left
					pack $path.fr$i -side top -anchor w -expand true -fill x
				}
				int {
					LabelEntry $path.le$i "[trans [lindex $opt 3]]:" $config_var 20
					$path.le$i.ent configure -validate focus -validatecommand "check_int %W" -invalidcommand "$path.le$i.ent delete 0 end; $path.le$i.ent insert end [set $config_var]"
					pack $path.le$i -side top -anchor w -expand true -fill x
				}
				default {
					LabelEntry $path.le$i "[trans [lindex $opt 3]]:" $config_var 20
					pack $path.le$i -side top -anchor w -expand true -fill x
				}
			}
			
			if { [lindex $opt 4] != "" } {
				label $path.exp$i -text "[trans [lindex $opt 4]]\n" -font examplef
				pack $path.exp$i -side top -anchor w -padx 15
			}
			
		}

	}

}



proc check_int {text} {
	set int_val "0"
	catch { expr {int([$text get])} } int_val
	if { $int_val != [$text get] } {
		status_log "Bad!!\n"
		return false
	}
	status_log "Good!!\n"
	return true
}

# This is where we fill in the Entries of the Preferences
proc InitPref { {fullinit 0} } {
	global Preftabs proxy_user proxy_pass
	set nb .cfg.notebook

	if { $fullinit } {
		set proxy_user [::config::getKey proxyuser]
		set proxy_pass [::config::getKey proxypass]
	
		# Insert nickname if online, disable if offline
		#set lfname [Rnotebook:frame $nb $Preftabs(personal)]
		set lfname [$nb.nn getframe personal]
		set lfname [$lfname.sw.sf getframe]
		if { [::MSN::myStatusIs] == "FLN" } {
			$lfname.lfname.f.f.1.name.entry configure -state disabled
		} else {
			$lfname.lfname.f.f.1.name.entry configure -state normal
			$lfname.lfname.f.f.1.name.entry delete 0 end
			$lfname.lfname.f.f.1.name.entry insert 0 [::abook::getPersonal nick]
		}
	
		$lfname.lfname.f.f.1.p4c.entry delete 0 end
		$lfname.lfname.f.f.1.p4c.entry insert 0 [::config::getKey p4c_name]
	
		
		# Get My Phone numbers and insert them
		set lfname "$lfname.lfname4.f.f"
		if { [::MSN::myStatusIs] == "FLN" } {
			$lfname.2.ephone1 configure -state disabled
			$lfname.2.ephone31 configure -state disabled
			$lfname.2.ephone32 configure -state disabled
			$lfname.2.ephone41 configure -state disabled
			$lfname.2.ephone42 configure -state disabled
			$lfname.2.ephone51 configure -state disabled
			$lfname.2.ephone52 configure -state disabled
		} else {
			$lfname.2.ephone1 configure -state normal
			$lfname.2.ephone31 configure -state normal
			$lfname.2.ephone32 configure -state normal
			$lfname.2.ephone41 configure -state normal
			$lfname.2.ephone42 configure -state normal
			$lfname.2.ephone51 configure -state normal
			$lfname.2.ephone52 configure -state normal
			$lfname.2.ephone1 delete 0 end
			$lfname.2.ephone31 delete 0 end
			$lfname.2.ephone32 delete 0 end
			$lfname.2.ephone41 delete 0 end
			$lfname.2.ephone42 delete 0 end
			$lfname.2.ephone51 delete 0 end
			$lfname.2.ephone52 delete 0 end
			
			$lfname.2.ephone1 insert 0 [lindex [split [::abook::getPersonal PHH] " "] 0]
			$lfname.2.ephone31 insert 0 [lindex [split [::abook::getPersonal PHH] " "] 1]
			$lfname.2.ephone32 insert 0 [join [lrange [split [::abook::getPersonal PHH] " "] 2 end]]
			$lfname.2.ephone41 insert 0 [lindex [split [::abook::getPersonal PHW] " "] 1]
			$lfname.2.ephone42 insert 0 [join [lrange [split [::abook::getPersonal PHW] " "] 2 end]]
			$lfname.2.ephone51 insert 0 [lindex [split [::abook::getPersonal PHM] " "] 1]
			$lfname.2.ephone52 insert 0 [join [lrange [split [::abook::getPersonal PHM] " "] 2 end]]
		}
		
		# Init remote preferences
		#set lfname [Rnotebook:frame $nb $Preftabs(connection)]
		set lfname [$nb.nn getframe connection]	
		set lfname [$lfname.sw.sf getframe]
		$lfname.lfname3.f.f.2.pass delete 0 end
		$lfname.lfname3.f.f.2.pass insert 0 "[::config::getKey remotepassword]"
		
	}
		
	# Lets fill our profile combobox
	#set lfname [Rnotebook:frame $nb $Preftabs(others)]
	set lfname [$nb.nn getframe others]
	set lfname "[$lfname.sw.sf getframe].lfname3.f.f"
   	set idx 0
   	set tmp_list ""
	$lfname.1.profile list delete 0 end
   	while { [LoginList get $idx] != 0 } {
		lappend tmp_list [LoginList get $idx]
		incr idx
	}
   	eval $lfname.1.profile list insert end $tmp_list
	$lfname.1.profile insert 0 [lindex $tmp_list 0]
   	unset idx
   	unset tmp_list
	$lfname.1.profile configure -editable false

	# Lets disable loging if on default profile
	if { [LoginList exists 0 [::config::getKey login]] == 0 } {
		#set lfname [Rnotebook:frame $nb $Preftabs(loging)]
		set lfname [$nb.nn getframe loging]
		set lfname "$lfname.lfname.f.f"
		$lfname.log configure -state disabled
	}

	# Let's fill our list of States
	#set lfname [Rnotebook:frame $nb $Preftabs(session)]
	set lfname [$nb.nn getframe session]
	set lfname [$lfname.sw.sf getframe]
	$lfname.lfname2.f.f.statelist.box delete 0 end
	for { set idx 0 } { $idx < [StateList size] } {incr idx } {
		$lfname.lfname2.f.f.statelist.box insert end [lindex [StateList get $idx] 0]
	}

        # Fill the user's lists
        #set lfname [Rnotebook:frame $nb $Preftabs(privacy)]
	set lfname [$nb.nn getframe privacy]
        Fill_users_list "$lfname.lfname.f.f" "$lfname.lfname2.f.f"

}


# This is where the preferences entries get enabled disabled
proc UpdatePreferences {} {
	global Preftabs

	set nb .cfg.notebook
	
	# autoaway checkbuttons and entries
	#set lfname [Rnotebook:frame $nb $Preftabs(session)]
	set lfname [$nb.nn getframe session]
	set lfname [$lfname.sw.sf getframe]
	set lfname "${lfname}.lfname.f.f"
	if { [::config::getKey autoidle] == 0 } {
		$lfname.1.eautonoact configure -state disabled
	} else {
		$lfname.1.eautonoact configure -state normal
	}
	if { [::config::getKey autoaway] == 0 } {
		$lfname.2.eautoaway configure -state disabled
	} else {
		$lfname.2.eautoaway configure -state normal
	}

	# proxy connection entries and checkbuttons
	#set lfname [Rnotebook:frame $nb $Preftabs(connection)]
	set lfname [$nb.nn getframe connection]
	set lfname [$lfname.sw.sf getframe]
	set lfname "${lfname}.lfnameconnection.f.f"
	if { [::config::getKey connectiontype] == "proxy" } {
		$lfname.4.post configure -state normal
		$lfname.4.ssl configure -state disable
		$lfname.4.socks5 configure -state disabled
		$lfname.5.server configure -state normal
		$lfname.5.port configure -state normal
		if { [::config::getKey proxytype] == "socks5" || [::config::getKey proxytype] == "http"} {
			$lfname.5.user configure -state normal
			$lfname.5.pass configure -state normal
		} else {
			$lfname.5.user configure -state disabled
			$lfname.5.pass configure -state disabled
		}
	} else {
		$lfname.4.post configure -state disabled
		$lfname.4.ssl configure -state disabled
		$lfname.4.socks5 configure -state disabled
		$lfname.5.server configure -state disabled
		$lfname.5.port configure -state disabled
		$lfname.5.user configure -state disabled
		$lfname.5.pass configure -state disabled
	}
	#set lfname [Rnotebook:frame $nb $Preftabs(connection)]
	set lfname [$nb.nn getframe connection]
	set lfname [$lfname.sw.sf getframe]
	set lfname "${lfname}.lfname.f.f"
	if { [::config::getKey autoftip] } {
		$lfname.1.ipaddr.entry configure -textvariable "" -text "Hola"
		$lfname.1.ipaddr.entry delete 0 end
		$lfname.1.ipaddr.entry insert end [::config::getKey myip]
		$lfname.1.ipaddr.entry configure -state disabled
	} else {
		$lfname.1.ipaddr.entry configure -state normal -textvariable [::config::getVar manualip]
	}

	# remote control
	#set lfname [Rnotebook:frame $nb $Preftabs(connection)]
	set lfname [$nb.nn getframe connection]
	set lfname [$lfname.sw.sf getframe]
	set lfname "${lfname}.lfname3.f.f"
	if { [::config::getKey enableremote] == 1 } {
		$lfname.2.pass configure -state normal
	} else {
		$lfname.2.pass configure -state disabled 
	}

	# sound
	set lfname [$nb.nn getframe others]
	set lfname [$lfname.sw.sf getframe]
	set lfname "${lfname}.lfname.f.f"
	#Disabled that if we are on Mac OS X because we can't choose Snack
	if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
		#Empty
	} else {
		if { [::config::getKey usesnack] == 1 } {
			#load Snack when being used
			if {![catch {package require snack}]} {
				$lfname.1.sound.sound configure -state disabled
				snack::audio playLatency 750
			} else {
				::config::setKey usesnack 0
				$lfname.1.sound.sound configure -state normal
				msg_box [trans snackfailed]
			}
		} else {
			$lfname.1.sound.sound configure -state normal 
		}
	}

}
	

# This function sets all fonts to plain instead of bold,
# excluding the ones that are set to sboldf or examplef
proc setCfgFonts {path value} {
	catch {set res [$path cget -font]}
	if { [info exists res] } {
		if { $res != "sboldf" && $res != "examplef" && $res != "bboldf"} {
		    catch { $path config -font $value }
		}
	}
        foreach child [winfo children $path] {
            setCfgFonts $child $value
        }
}



proc SavePreferences {} {
	global myconfig proxy_server proxy_port list_BLP temp_BLP Preftabs libtls libtls_temp proxy_user proxy_pass

	set nb .cfg.notebook
	
	# I. Data Validation & Metavariable substitution
	# Proxy settings
	set p_server [string trim $proxy_server]
	set p_port [string trim $proxy_port]
	set p_user [string trim $proxy_user]
	set p_pass [string trim $proxy_pass]

	::config::setKey proxy [list $p_server $p_port]

	if { ($p_pass != "") && ($p_user != "")} {
		::config::setKey proxypass $p_pass
		::config::setKey proxyuser $p_user
		::config::setKey proxyauthenticate 1
	} else {
		::config::setKey proxypass ""
		::config::setKey proxyuser ""
		::config::setKey proxyauthenticate 0
	}

	if {![string is digit [::config::getKey initialftport]] || [string length [::config::getKey initialftport]] == 0 } {
		::config::setKey initialftport 6891
	}

	if { [::config::getKey getdisppic] != 0 } {
		check_imagemagick
	}


	# Make sure entries x and y offsets and idle time are digits, if not revert to old values
	if { [string is digit [::config::getKey notifyXoffset]] == 0 } {
		::config::setKey notifyXoffset $myconfig(notifyXoffset)
	}
	if { [string is digit [::config::getKey notifyYoffset]] == 0 } {
		::config::setKey notifyYoffset $myconfig(notifyYoffset)
	}
	if { [string is digit [::config::getKey idletime]] == 0 } {
		::config::setKey idletime $myconfig(idletime)
	}
	if { [string is digit [::config::getKey awaytime]] == 0 } {
		::config::setKey awaytime $myconfig(awaytime)
	}
	if { [::config::getKey idletime] >= [::config::getKey awaytime] } {
		::config::setKey awaytime $myconfig(awaytime)
		::config::setKey idletime $myconfig(idletime)
	}

	# Check and save phone numbers
	if { [::MSN::myStatusIs] != "FLN" } {
		#set lfname [Rnotebook:frame $nb $Preftabs(personal)]
		set lfname [$nb.nn getframe personal]
		set lfname [$lfname.sw.sf getframe]
		set lfname "$lfname.lfname4.f.f"
	
		set cntrycode [$lfname.2.ephone1 get]
		if { [string is digit $cntrycode] == 0 } {
			set cntrycode [lindex [split [::abook::getPersonal PHH] " "] 0]
		}
	
		append home [$lfname.2.ephone31 get] " " [$lfname.2.ephone32 get]
		if { [string is digit [$lfname.2.ephone31 get]] == 0 } {
			set home [join [lrange [split [::abook::getPersonal PHH] " "] 1 end]]
		}
		append work [$lfname.2.ephone41 get] " " [$lfname.2.ephone42 get]
		if { [string is digit [$lfname.2.ephone41 get]] == 0 } {
			set work [join [lrange [split [::abook::getPersonal PHW] " "] 1 end]]
		}
		append mobile [$lfname.2.ephone51 get] " " [$lfname.2.ephone52 get]
		if { [string is digit [$lfname.2.ephone51 get]] == 0 } {
			set mobile [join [lrange [split [::abook::getPersonal PHM] " "] 1 end]]
		}
	
		set home [urlencode [set home "$cntrycode $home"]]
		set work [urlencode [set work "$cntrycode $work"]]
		set mobile [urlencode [set mobile "$cntrycode $mobile"]]
		if { $home != [::abook::getPersonal PHH] } {
			::abook::setPhone home $home
		}
		if { $work != [::abook::getPersonal PHW] } {
			::abook::setPhone work $work
		}
		if { $work != [::abook::getPersonal PHM] } {
			::abook::setPhone mobile $mobile
		}
		if { $home != [::abook::getPersonal PHH] || $work != [::abook::getPersonal PHW] || $work != [::abook::getPersonal PHM] } {
			::abook::setPhone pager N
		}
	}

	# Change name
	#set lfname [Rnotebook:frame $nb $Preftabs(personal)]
	set lfname [$nb.nn getframe personal]
	set lfname [$lfname.sw.sf getframe]
	set lfname "$lfname.lfname.f.f.1"
	set new_name [$lfname.name.entry get]
	if {$new_name != "" && $new_name != [::abook::getPersonal nick] && [::MSN::myStatusIs] != "FLN"} {
		::MSN::changeName [::config::getKey login] $new_name
	}
	::config::setKey p4c_name [$lfname.p4c.entry get]

	#Check if convertpath was left blank, set it to "convert"
	if { [::config::getKey convertpath] == "" } {
		::config::setKey convertpath "convert"
	}

	# Get remote controlling preferences
	#set lfname [Rnotebook:frame $nb $Preftabs(connection)]
	set lfname [$nb.nn getframe connection]
	set lfname [$lfname.sw.sf getframe]
	set myconfig(remotepassword) "[$lfname.lfname3.f.f.2.pass get]"
	::config::setKey remotepassword $myconfig(remotepassword)

	#Copy to myconfig array, because when the window is closed, these will be restored (RestorePreferences)
	array set myconfig [::config::getAll]

	# Save configuration of the BLP ( Allow all other users to see me online )
	if { $list_BLP != $temp_BLP } {
		AllowAllUsers $temp_BLP
	}


	# Save tls package configuration
	if { $libtls_temp != $libtls } {
		set libtls $libtls_temp
		global auto_path HOME2 tlsinstalled
		if { $libtls != "" && [lsearch $auto_path $libtls] == -1 } {
			lappend auto_path $libtls
		}
	
		if { $tlsinstalled == 0 && [catch {package require tls}] } {
			# Either tls is not installed, or $auto_path does not point to it.
			# Should now never happen; the check for the presence of tls is made
			# before this point.
			status_log "Could not find the package tls on this system.\n"
			set tlsinstalled 0
		} else {
			set tlsinstalled 1
		}
	
		set fd [open [file join $HOME2 tlsconfig.tcl] w]
		puts $fd "set libtls [list $libtls]"
		close $fd
	}


	# Blocking
	#if { [::config::getKey blockusers] == "" } { ::config::setKey blockusers 1}
	#if { [::config::getKey checkblocking] == 1 } {
		#BeginVerifyBlocked [::config::getKey blockinter1] [::config::getKey blockinter2] [::config::getKey blockusers] [::config::getKey blockinter3]
	#} else {
		#StopVerifyBlocked
	#}

	# Save configuration.
	save_config
	::MSN::contactListChanged
	::config::saveGlobal

	if { [::MSN::myStatusIs] != "FLN" } {
		cmsn_draw_online
	}
    
	#Reset the banner incase the option changed
	resetBanner

}

proc RestorePreferences { {win ".cfg"} } {
	
	if { $win != ".cfg" } { return }

	global myconfig proxy_server proxy_port
	

	set nb .cfg.notebook.nn


	::config::setAll [array get myconfig]

	# Save configuration.
	save_config
	::MSN::contactListChanged
	::config::saveGlobal

	if { [::MSN::myStatusIs] != "FLN" } {
		cmsn_draw_online
	}	
	
	#::MSN::WriteSB ns "SYN" "0"

	# Save configuration.
	#save_config

}

###################### Other Features     ###########################
proc ChooseFilename { twn title } {

    # TODO File selection box, use nickname as filename (caller)
    set w .form$title
	 if {[winfo exists $w]} {
	 	raise $w
		return
	 }
    toplevel $w
    wm title $w [trans savetofile]
     label $w.msg -justify center -text [trans enterfilename]
     pack $w.msg -side top

     frame $w.buttons -class Degt
     pack $w.buttons -side bottom -fill x -pady 2m
      button $w.buttons.dismiss -text [trans cancel] -command "destroy $w"
      button $w.buttons.save -text [trans save] \
        -command "save_text_file $twn $w.filename.entry; destroy $w"
      pack $w.buttons.save $w.buttons.dismiss -side left -expand 1

    frame $w.filename -bd 2 -class Degt
     entry $w.filename.entry -relief sunken -width 40
     label $w.filename.label -text "[trans filename]:"
     pack $w.filename.entry -side right
     pack $w.filename.label -side left
    pack $w.msg $w.filename -side top -fill x
    focus $w.filename.entry

    chooseFileDialog "Untitled" "" $w $w.filename.entry save
}

proc save_text_file { w ent } {

    set dstfile [ $ent get ]

	 if { [catch { open $dstfile w }] } {
	 	msg_box "[trans invalidfile2 $dstfile]"
		return
	 }

    set content ""
    set dump [$w  dump  -text 0.0 end]
    foreach { text output index } $dump {
	set content "${content}${output}"
    }

    set f [ open $dstfile w ]
    puts $f $content
    close $f
    #puts "Saved $dstfile"
    #puts "Content $content"
}


# Usage: LabelEntry .mypath.mailer "Label:" config(mailcommand) 20
proc LabelEntry { path lbl variable width } {
    

    frame $path -class Degt
	label $path.lbl -text $lbl -justify left \
	    -font splainf
	entry $path.ent -textvariable $variable -relief sunken \
	    -width $width -font splainf -background #FFFFFF
	pack $path.lbl -side left -anchor e
	pack $path.ent -side left -anchor e -expand 1 -fill x -padx 3
#	pack $path.ent $path.lbl -side right -anchor e -expand 1 -fill x
}

proc LabelEntryGet { path } {
    return [$path.ent get]
}

#/////////////////////////////////////////////////////////////
# A Labeled Frame widget for Tcl/Tk
#
# Copyright (C) 1998 D. Richard Hipp
#
# Author contact information:
#   drh@acm.org
#   http://www.hwaci.com/drh/
proc LabelFrame:create {w args} {
  frame $w -bd 0
  label $w.l
  frame $w.f -bd 2 -relief groove
  frame $w.f.f
  pack $w.f.f
  set text {}
  set font {}
  set padx 3
  set pady 7
  set ipadx 2
  set ipady 9
  foreach {tag value} $args {
    switch -- $tag {
      -font  {set font $value}
      -text  {set text $value}
      -padx  {set padx $value}
      -pady  {set pady $value}
      -ipadx {set ipadx $value}
      -ipady {set ipady $value}
      -bd     {$w.f config -bd $value}
      -relief {$w.f config -relief $value}
    }
  }
  if {"$font"!=""} {
    $w.l config -font $font
  }
  $w.l config -text $text
  pack $w.f -padx $padx -pady $pady -fill both -expand 1
  place $w.l -x [expr {$padx+10}] -y $pady -anchor w
  pack $w.f.f -padx $ipadx -pady $ipady -fill both -expand 1
  raise $w.l
  return $w.f.f
}



proc BlockValidateEntry { widget data type {correct 0} } {

    switch  $type  {
	0 {
	    if { [string is integer  $data] } {
		$widget delete 0 end
		$widget insert 0 "$correct" 
		after idle "$widget config -validate all"
	    }    
	}
	1 {
	    if { [string is integer  $data] } {
		if { $data < 15 } {
		    return 0
		}
		return 1
	    } else {return 0}
	}
	2 {    
	    if { [string is integer $data] } {
		if { $data < 30 } {
		    return 0
		}
		return 1
	    } else {return 0}
	}
	3 {    
	    if { [string is integer   $data] } {
		if { $data < 2 } {
		    return 0
		}
		return 1
	    } else {return 0}
	}
	4 {    
	    if { [string is integer  $data] } {
		if { $data > 5 } {
		    return 0
		} 
		return 1 
	    } else {return 0}
	}
    }
	
}


#proc Browse_Dialog {}
#Browse dialog function (used in TLS directory and convert file), first show the dialog (choose folder or choose file), after check if user choosed something, if yes, set the new variable
proc Browse_Dialog_dir {configitem {initialdir ""}} {
	global libtls_temp
	
	if { $initialdir == "" } {
		set initialdir [set $configitem]
	}
	
	if { ![file isdirectory $initialdir]} {
		set initialdir [pwd]
	}
	
	set browsechoose [tk_chooseDirectory -parent [focus] -initialdir $initialdir]
	if { $browsechoose !="" } {
		set $configitem $browsechoose
	}
}

proc Browse_Dialog_file {configitem {initialfile ""}} {
	global libtls_temp
	if { $initialfile == "" } {
		set initialfile [set $configitem]
	}

	if { ![file exists $initialfile] } {
		set initialfile ""
	}
	set browsechoose [tk_getOpenFile -parent [focus] -initialfile $initialfile]
	if { $browsechoose !="" } {
		set $configitem $browsechoose
	}
}

#///////////////////////////////////////////////////////////////////////
proc choose_basefont { } {
	if { [winfo exists .basefontsel] } {
		raise .basefontsel
		return
	}

	
	if { [catch {
			set font [SelectFont .basefontsel -parent .cfg -title [trans choosebasefont] -font [::config::getGlobalKey basefont] -styles [list]]
		}]} {
		
		set font [SelectFont .basefontsel -parent .cfg -title [trans choosebasefont] -font [list "helvetica" 12 [list]] -styles [list]]
		
	}

	set family [lindex $font 0]
	set size [lindex $font 1]
			
	if { $family == "" || $size == ""} {
		return
	}

	set newfont [list $family $size normal]

	if { $newfont != [::config::getGlobalKey basefont]} {
		::config::setGlobalKey basefont $newfont
		focus .cfg
		msg_box [trans mustrestart]
	}

}
#///////////////////////////////////////////////////////////////////////
