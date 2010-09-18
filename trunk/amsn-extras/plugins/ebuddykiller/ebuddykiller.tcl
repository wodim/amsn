namespace eval ::ebuddykiller {
	variable loaded

	proc Init { dir } {
		variable loaded

		if {[info exists loaded] && $loaded == 1} {
			return
		}

		if { [info commands ::NS::Snit_methodsetInitialNicknameCB] != "" && [info commands ::NS::Snit_methodsetInitialNicknameKilled] == "" } {
			rename ::NS::Snit_methodsetInitialNicknameCB ::NS::Snit_methodsetInitialNicknameKilled
		} else {
			return
		}

		::plugins::RegisterPlugin eBuddyKiller
		plugins_log "eBuddyKiller" "We are being executed"

		proc ::NS::Snit_methodsetInitialNicknameCB { type selfns win self newstate newstate_custom nickname last_modif psm fail } {
			plugins_log "eBuddyKiller" "Callback called"
			if { [string first " - on eBuddy Mobile Messenger http://get.ebuddy.com" $psm] >= 0 } {
				plugins_log "eBuddyKiller" "eBuddy PSM killed!!!"
				set psm [::abook::getPersonal PSM]
				set force 1
			}
			eval ::NS::Snit_methodsetInitialNicknameKilled [list $type $selfns $win $self $newstate $newstate_custom $nickname $last_modif $psm $fail]
			if { $force == 1 } {
				#We should force updating our PSM on the server
				::MSN::changePSM $psm [::MSN::myStatusIs] 1 1
			}
		}

		set loaded 1
	}


	proc DeInit { } {
		variable loaded
		
		status_log "Restoring previous proc body\n"
	
		;# this will return  the  list of arguments a command can take
		if { [info commands ::NS::Snit_methodsetInitialNicknameKilled] != "" } {
			rename ::NS::Snit_methodsetInitialNicknameCB ""
			rename ::NS::Snit_methodsetInitialNicknameKilled ::NS::Snit_methodsetInitialNicknameCB
		}
	
		set loaded 0
		
	}
}
