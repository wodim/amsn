namespace eval ::p2p {

	snit::type BaseP2PTransport {

		option -transport_manager -default ""
		option -name
		option -local_chunk_id ""
		option -remote_chunk_id ""
		option -transport ""
		option -connected 1
		option -peer ""
		option -peer_guid ""

		variable data_blob_queue {}
		variable pending_blob -array {}
		variable pending_ack -array {}
		variable signaling_blobs -array {}
		variable first 1


		constructor { args } {

			$self configurelist $args
			::Event::registerEvent p2pSessionClosed all [list $self On_session_closed]

		}

		method conf2 { } {

			$options(-transport_manager) Register_transport $options(-transport)

			$self Reset

		}

		destructor {

			catch {::Event::unregisterEvent p2pSessionClosed all [list $self On_session_closed]}
			catch {after cancel [list $self Process_send_queue]}
			catch {$options(-transport_manager) Unregister_transport $options(-transport)}
			#$options(-transport) destroy

		}

		method version { } {
			#@@@@@@@@@@@@@@@@@ amsn doesn't support p2pv2 yet.
			#now, about finding whether remote peer supports p2pv2... TODO later
			#if { [[[[$self cget -client] cget -profile] cget -client_id] supports_p2pv2] && [[[[$self cget -peer] cget -client] cget -capabilities] supports_p2pv2]} {
			#  return 2
			#} else {
			return 1
			#}
		}

		method send {peer peer_guid blob} {

			lappend data_blob_queue [list $peer $peer_guid $blob]
			$self Process_send_queue
		}

		method close { } {
			#set trsp [$self cget -transport_manager]
			#list $trsp unregister_transport $options(-transport)
			#catch {$options(-transport) destroy}
			#destructor will take care of the above
			after idle [list catch [list $options(-transport) destroy]]
		}

		method Reset { } {

			set data_blob_queue {}
			set first 1

		}

		method Add_pending_ack { blob_id {chunk_id 0} } {

			if { ![info exists pending_ack($blob_id)] } {
				set pending_ack($blob_id) {}
			}

			lappend pending_ack($blob_id) $chunk_id
		}

		method Add_pending_blob {ack_id blob} {

			if { [$self version] == 1 } {
				set pending_blob($ack_id) $blob
			} else {
				::Event::fireEvent p2pBlobSent p2pBaseTransport $blob
				catch {$blob destroy}
			}

		}

		method Del_pending_blob { ack_id } {

			if { ![info exists pending_blob($ack_id)] } {
				return
			}
			set blob $pending_blob($ack_id)
			array unset pending_blob $ack_id
			::Event::fireEvent p2pBlobSent p2pBaseTransport $blob
			catch {$blob destroy}

		}

		# Unused
		method Del_blobs_of_session { sid } {

			foreach ack_id [array names pending_blob] {
				set blob $pending_blob($ack_id)
				if { [$blob cget -session_id] == $sid } {
					array unset pending_blob $ack_id
					if { [info exists pending_ack([$blob cget -id])] } {
						array unset pending_ack [$blob cget -id]
					}
					$blob destroy
				}
			}
	
		}

		method Del_pending_ack {blob_id {chunk_id 0} } {

			if { ![info exists pending_ack($blob_id)] } {
				return
			}
			set blob $pending_ack($blob_id)
			set pos [lsearch $blob $chunk_id]
			set blob [lreplace $blob $pos $pos]

			if { [info exists pending_ack($blob_id)] } {
				array unset pending_ack $blob_id
			} else {
				set pending_ack($blob_id) $blob
			}
		}

		method On_chunk_received { peer peer_guid chunk } {
			
			status_log "base.tcl received $chunk"
			if { [$chunk require_ack] == 1 } {
				status_log "Will send ACK"
				set ack_chunk [$chunk create_ack_chunk]
				$self __Send_chunk $peer $peer_guid $ack_chunk
				$ack_chunk destroy
			}

			if { [$chunk is_control_chunk] == 0 } {
				status_log "It is not a control chunk"
				if { [$chunk is_signaling_chunk] == 1 } {
					status_log "It is a signaling chunk"
					$self On_signaling_chunk_received $chunk
				} else {
					status_log "It is not a signaling chunk either"
					::Event::fireEvent p2pChunkReceived p2pBaseTransport $chunk
				}
			}

			if { [$chunk is_ack_chunk] || [$chunk is_nak_chunk]} {
				$self Del_pending_ack [$chunk acked_id]
				$self Del_pending_blob [$chunk acked_id]
			}


			$self Process_send_queue

		}

		method On_signaling_chunk_received { chunk } {

			set blob_id [$chunk blob_id]

			if { [info exists signaling_blobs($blob_id)] } {
				set blob $signaling_blobs($blob_id)
			} else {
				set blob [MessageBlob %AUTO% -application_id [$chunk cget -application_id] -blob_size [$chunk blob_size] -session_id [$chunk session_id] -blob_id $blob_id]
				set signaling_blobs($blob_id) $blob
			}

			$blob append_chunk $chunk
			if { [$blob is_complete] } {
				status_log "The blob $blob is complete"
				::Event::fireEvent p2pBlobReceived p2pBaseTransport $blob
				array unset signaling_blobs $blob_id
				catch {$blob destroy}
			} else {
				status_log "Waiting for more data"
			}

		}

		method On_chunk_sent { chunk blob } {

			::Event::fireEvent p2pChunkSent p2pBaseTransport $chunk $blob
			#$self Process_send_queue

		}

		method On_session_closed { event sid } {

			set queue $data_blob_queue
			set i 0
			foreach item $queue {
				set blob [lindex $item 2]
				if { [$blob cget -session_id] == $sid } {
					set queue [lreplace $queue $i $i]
					set data_blob_queue $queue
					#$blob destroy
				} else {
					incr i
				}
			}

		}

		method Process_send_queue { } {

			if { [llength $data_blob_queue] > 0 } {
				set queue $data_blob_queue
			} else {
				return 0
			}

			set first 0

			set blob [lindex [lindex $queue 0] 2]
			set peer_guid [lindex [lindex $queue 0] 1]
			set peer [lindex [lindex $queue 0] 0]
			status_log "Blob $blob for $peer"

			set chunk [$blob get_chunk [$self version] [$self max_chunk_size] $first] 
			status_log "Sending $chunk"
			$self __Send_chunk $peer $peer_guid $chunk

			if { [$blob is_complete] } {
				status_log "Queue says blob $blob is complete"
				set queue [lreplace $queue 0 0]
				set data_blob_queue $queue
				$self Add_pending_blob [$chunk ack_id] $blob
			} else {
				status_log "Blob size is [$blob cget -blob_size] and we have [$blob transferred]"
				after 10 [list $self Process_send_queue]
			}
			$self On_chunk_sent $chunk $blob
			catch {$chunk destroy}
			return 1

		}

		method max_chunk_size { } {

			return 1200

		}

		method __Send_chunk {peer peer_guid chunk} {
			variable local_chunk_id
			status_log "Sending chunk $chunk to $peer"

			if { ![info exists local_chunk_id] } {
				set local_chunk_id [expr {int(1000 + rand() * (1+65540-1000))}]
			}
			if { [$chunk is_ack_chunk] == 0 } {
				$chunk set_id $local_chunk_id
			}
			set local_chunk_id [$chunk next_id]

			if { [$chunk require_ack] == 1 } {
				$self Add_pending_ack [$chunk ack_id]
			}

			$options(-transport) Send_chunk $peer $peer_guid $chunk
			#catch {$chunk destroy}

		}

		#method Send_chunk { peer peer_guid chunk } {

		#Implemented in each transport on its own
		#  return ""

		#}

	}

}
