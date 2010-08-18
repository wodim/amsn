namespace eval ::p2p {

	snit::type FileTransferSession {

		delegate option * to p2pSession
		delegate method * to p2pSession

		option -filename ""
		option -size 0
		option -has_preview 0
		option -preview ""
		option -data ""
		option -localpath ""
		variable outgoing_sessions -array {}
		variable sender 0
		#TODO: write intermediate files

		variable handlers {}

		constructor { args } {

			install p2pSession using P2PSession %AUTO% {*}$args -euf_guid $::p2p::EufGuid::FILE_TRANSFER -partof $self
			$p2pSession conf2
			$self configurelist $args
			set options(-localpath) [::config::getKey receiveddir]
			
			set message [$p2pSession cget -message]
			if { $message != "" } {

				$self parse_context [[$message body] cget -context]

			}
			
			set handlers { p2pBridgeSelected On_bridge_selected p2pOutgoingSessionTransferCompleted On_transfer_completed p2pChunkReceived2 On_chunk_received p2pAccepted On_session_accepted p2pChunkSent2 On_chunk_sent p2pTransreqReceived On_transreq_received }

			foreach { event callback } $handlers {
				::Event::registerEvent $event all [list $self $callback]
			}

		}

		method invite { filename size } {

			set options(-filename) $filename
			set options(-localpath) $filename
			set options(-size) $size
			set options(-context) [$self build_context]
			set sender 1

			set fd [open $filename r]
			fconfigure $fd -translation {binary binary}
			$p2pSession configure -fd $fd
			$p2pSession invite $options(-context)

		}

		method saveAs { } {

			set filename [tk_getSaveFile -initialfile $options(-localpath) -initialdir $options(-filename)]

			set origfile $filename
			set incompl "incomplete"

			set num 1
			while { [file exists $filename] || [file exists $filename.$incompl] } {
				set filename "[filenoext $origfile] $num[fileext $origfile]"
				incr num
			}
			set options(-localpath) $filename
			set fd [open $filename.$incompl a]
			fconfigure $fd -translation {binary binary}
			$p2pSession configure -fd $fd

			$self Respond "200"

		}

		method accept { } {

			$self configure -localpath [file join $options(-localpath) $options(-filename)]
			set filename $options(-localpath)
			set origfile $filename
			set incompl "incomplete"

			set num 1
			while { [file exists $filename] || [file exists $filename.$incompl] } {
				set filename "[filenoext $origfile] $num[fileext $origfile]"
				#set filename "$origfile.$num"
				incr num
			}
			set options(-localpath) $filename
			set fd [open $filename.$incompl a]
			fconfigure $fd -translation {binary binary}
			$p2pSession configure -fd $fd

			::amsn::FTProgress a $self $options(-localpath) ;#TODO: direct connection
			$self Respond "200"

		}

		method reject { } {

			foreach {event callback} $handlers {
				::Event::unregisterEvent $event all [list $self $callback]
			}
			$self Respond "603"

		}

		method cancel { } {

			foreach {event callback} $handlers {
				::Event::unregisterEvent $event all [list $self $callback]
			}
			$self Close [$self cget -context] ""
			::amsn::FTProgress ca $self $options(-localpath)

		}

		method send { } {

			$self Request_bridge

		}

		method build_context { } {

			global HOME
			
			set filename $options(-filename)
			set ext [string tolower [string range [fileext $filename] 1 end]]
			if { $ext == "jpg" || $ext == "gif" || $ext == "png" || $ext == "bmp" || $ext == "jpeg" || $ext == "tga" } {
				set haspreview 1
			} else {
				set haspreview 0
			}

			if {[::config::getKey noftpreview]} {
				set haspreview 0
			}

			set context "[binary format i 574][binary format i 2][binary format i $options(-size)][binary format i 0][binary format i [expr {!$haspreview}]]"

			set file [ToUnicode [getfilename $options(-filename)]]
			set file [binary format a550 $file]
			set context "${context}${file}\xFF\xFF\xFF\xFF"

			if { $haspreview == 1 } {
				create_dir [file join $HOME FT cache]
				if {[catch {set image [image create photo [TmpImgName] -file $filename]}]} {
					set image [::skin::getNoDisplayPicture]
				}
				if {[catch {::picture::ResizeWithRatio $image 96 96} res]} {
					status_log $res
				}
				set callid [$self cget -call_id]
				set file  "[file join $HOME FT cache ${callid}.png]"
				if {[catch {::picture::Save $image $file cxpng} res] } {
					status_log $res
				}
				if {$image != [::skin::getNoDisplayPicture]} {
					image delete $image
				}
				::skin::setPixmap ${callid}.png $file

				if { [catch { open $file} fd] == 0 } {
					fconfigure $fd -translation {binary binary }
					set context "$context[read $fd]"
					close $fd
				}
				#Show the preview picture in the window
				set chatid [$self cget -peer]
				if { [::skin::loadPixmap "${callid}.png"] != "" } {
					::amsn::WinWrite $chatid "\n" green
					::amsn::WinWriteIcon $chatid ${callid}.png 5 5
					::amsn::WinWrite $chatid "\n" green
				}
			}

			$self configure -has_preview $haspreview

			return $context

		}

		method getFilenameFromContext { context } {

			set fname [FromUnicode [string range $context 20 569]]

			set idx [string first "\x00" $fname]
			if {$idx != -1 } {
				set fname [string range $fname 0 [expr {$idx - 1}]]
			}

			return $fname

		}

		method getPreviewFromContext { context } {

			global HOME
			binary scan [string range $context 16 19] i noprev

			if { $noprev == 1 } { return 0 }

			binary scan [string range $context 0 3] i size
			set previewdata [string range $context $size end]
			set dir [file join $HOME FT cache]
			create_dir $dir
			set sid [$self cget -id]
			set fd [open "[file join $dir ${sid}.png ]" "w"]
			fconfigure $fd -translation binary
			puts -nonewline $fd $previewdata
			close $fd
			set file [file join $dir ${sid}.png]
			if { $file != "" && ![catch {set img [image create photo [TmpImgName] -file $file]} res]} {
				::skin::setPixmap FT_preview_${sid} "[file join $dir ${sid}.png]"
				#set options(-haspreview) 1
				#TODO: read file
			}
			catch {image delete $img}
			return 1

		}

		method parse_context { context } {

			global HOME

			binary scan [string range $context 8 11] i filesize
			binary scan [string range $context 16 19] i nopreview

			set filename [$self getFilenameFromContext $context]
			$self configure -filename $filename
			$self configure -has_preview [$self getPreviewFromContext $context]
			$self configure -size $filesize

			set idx [string first "\x00" $filename]
			if {$idx != -1 } {
				set filename [string range $filename 0 [expr {$idx - 1}]]
			}  

		}

		method On_session_accepted { event session } {

			if { $session != $p2pSession } { return }

			::Event::unregisterEvent p2pAccepted all [list $self On_session_accepted]
			::amsn::FTProgress a $self $options(-localpath)
			$self send

		}

		method On_transreq_received { event msg } {

			if { [$msg cget -call_id] != [$self cget -call_id] } { return }

			$p2pSession Accept_transreq $msg "TCPv1" [::abook::getDemographicField listening] [[$msg body] get_header Nonce] [::abook::getDemographicField localip] [config::getKey initialftport] [::abook::getDemographicField clientip] [config::getKey initialftport]
			#$p2pSession Switch_bridge $msg

		}

		method On_bridge_selected { event session } {

			if { $session != $p2pSession } { return }

			::Event::unregisterEvent p2pBridgeSelected all [list $self On_bridge_selected]

			if { $sender == 1 && [file exists $options(-localpath)] } {
				$self Send_p2p_data [file size $options(-localpath)] 1
			}

		}

		method On_chunk_received { event session chunk blob } {

			if { $session != $p2pSession && $session != $self } { return }

			if { [$blob cget -current_size] < [$blob cget -blob_size] } {
				::amsn::FTProgress r $self [$self cget -localpath] [$blob cget -current_size] [$blob cget -blob_size]
			}

		}

		method On_chunk_sent { event session chunk blob } {

			if { $session != $p2pSession && $session != $self } { return }

			if { [$blob cget -current_size] < [$blob cget -blob_size] } {
				::amsn::FTProgress s $self $options(-localpath) [$blob cget -current_size] [$blob cget -blob_size]
			} else {
				::amsn::FTProgress fs $self $options(-localpath)
				close [$p2pSession cget -fd]
			}

		}

		method On_transfer_completed { event session data } {

			if { $session != $p2pSession } { return }

			foreach {event callback} $handlers {
				::Event::unregisterEvent $event all [list $self $callback]
			}

			::amsn::FTProgress fr $self [$self cget -localpath]

			$self configure -data $data

			close [$p2pSession cget -fd]
			set filename [$self cget -localpath]
			file rename $filename.incomplete $filename

		}

	}

	snit::type FileTransferHandler {

		option -client ""

		variable incoming_sessions -array {}

		constructor { args } {

			$self configurelist $args

		}

		method Can_handle_message { message } {

			status_log "Can I handle $message with body [$message body]?"
			set euf_guid [[$message body] cget -euf_guid]
			if { $euf_guid == $::p2p::EufGuid::FILE_TRANSFER } {
				return 1
			} else {
				return 0
			}

		}

		method Handle_message { peer guid message } {

			set context [[$message body] cget -context]
			set session [FileTransferSession %AUTO% -session_manager [$self cget -client] -peer $peer -euf_guid $::p2p::EufGuid::FILE_TRANSFER -application_id [$message cget -application_id] -message $message -context $context ]
			$session conf2

			::Event::registerEvent p2pIncomingCompleted all [list $self Incoming_session_transfer_completed]
			set incoming_sessions($session) {p2pIncomingCompleted Incoming_session_transfer_completed}
			::amsn::GotFileTransferRequest $peer ${peer}\;$guid $session
			return $session

		}

		method request { peer filename size {callback ""} {errback ""} } {

			set session [FileTransferSession %AUTO% -session_manager [$self cget -client] -peer $peer -application_id $::p2p::ApplicationID::FILE_TRANSFER ]
			$session conf2

			set handles [list p2pOnSessionAnswered On_session_answered p2pOnSessionRejected On_session_rejected p2pOutgoingSessionTransferCompleted Outgoing_session_transfer_completed]
			foreach {event callb} $handles {
				::Event::registerEvent $event all [list $self $callb]
			}
			if { $callback != "" } {
				set outgoing_sessions([$session p2p_session]) [list $handles $callback $errback]
			}
			$session invite $filename $size

		}

		method Outgoing_session_transfer_completed { event session data } {

			status_log "Outgoing session transfer completed!!!!!!!"
			if { ![info exists outgoing_sessions($session)] } { return }
			set lst $outgoing_sessions($session)
			set handles [lindex $lst 0]
			set callback [lindex $lst 1]
			set errback [lindex $lst 2]
			status_log "Callback is $callback"

			foreach {event callb} $handles {
				::Event::unregisterEvent $event all [list $self $callb]
			}

			set method_name [lindex $callback 0]
			set args [lreplace $callback 0 0]
			eval $method_name $data $args
			
			array unset outgoing_sessions $session
			
		}

		method Incoming_session_transfer_completed { event session data } {

			if { ![info exists incoming_sessions($session)] } { return }
			set {event callback} $incoming_sessions($session)
			::Event::unregisterEvent $event all [list $self $callback]
			array unset incoming_sessions $session
			
		}

		method On_session_answered { answered_session } { }
		
		method On_session_rejected { session } { }
		
	}
}
