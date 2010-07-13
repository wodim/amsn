namespace eval ::p2p::transport {

snit::type BaseP2PTransport {

  option -transport_manager
  option -name
  option -client
  option -local_chunk_id ""
  option -remote_chunk_id ""

  constructor { args } {
    $self configurelist $args

    $self configure -client [list $transport_manager cget -client]
    list $transport_manager register_transport $self

    $self reset

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
    variable data_blob_queue

    lappend data_blob_queue [list $peer peer_guid blob]
    $self process_send_queues
  }

  method close { } {
    set trsp [$self cget -transport_manager]
    list $trsp unregister_transport $self
  }

  method Reset { } {
    variable data_blob_queue
    variable pending_blob
    variable pending_ack
    variable signaling_blobs
    variable first

    set data_blob_queue {}
    array set pending_blob {}
    array set pending_ack {}
    array set signaling_blobs {}
    set first 1

  }

  method Add_pending_ack { blob_id {chunk_id 0} } {
    variable pending_ack

    if { [lsearch $blob_id [array names pending_ack]] < 0 } {
      set pending_ack($blob_id) {}
    }

    lappend pending_ack($blob_id) $chunk_id
  }

  method Add_pending_blob {ack_id blob} {
    
    variable pending_blob

    if { [$self version] == 1 } {
      set pending_blob($ack_id) $blob
    } else {
      #$self emit "blob-sent" $blob
    }

  }

  method Del_pending_blob { ack_id } {

    variable pending_blob

    if { [lsearch $ack_id [array names pending_blob]] < 0 } {
      return
    }
    set blob $pending_ack($blob_id)
    set pos [lsearch $chunk_id $blob]
    set blob [lreplace $blob $pos $pos]
    #$self emit "blob-sent" $blob

  }

  method Del_pending_ack {blob_id {chunk_id 0} } {
    variable pending_ack

    if { [lsearch $blob_id [array names pending_ack]] < 0 } {
      return
    }
    set blob $pending_ack($blob_id)
    set pos [lsearch $chunk_id $blob]
    set blob [lreplace $blob $pos $pos]

    if { llength $blob <= 0 } {
      array unset pending_ack $blob_id
    } else {
      set pending_ack($blob_id) $blob
    }
  }

  method On_chunk_received { chunk } {
    variable pending_blob
    variable pending_ack

    if { [$chunk require_ack] == 1 } {
      $self Send_ack $chunk
    }

    if { [$chunk is_ack_chunk] || [$chunk is_nak_chunk]} {
      $self Del_pending_ack [$chunk cget -acked_id]
      $self Del_pending_blob [$chunk cget -acked_id]
    }

    if { [$chunk is_control_chunk] == 0 } {
      if { [$chunk is_signaling_chunk] == 1 } {
        $self On_signaling_chunk_received $chunk
      } else {
        #$self emit "chunk-received" $chunk
      }
    }

    $self process_send_queues

  }

  method On_signaling_chunk_received { chunk } {

    variable signaling_blobs

    set blob_ib [$chunk cget -blob_id]

    if { [lsearch [array names $signaling_blobs] $blob_id] >= 0 } {
      set blob $signaling_blobs($blob_id)
    } else {
      MessageBlob blob -application_id [$chunk cget -application_id] -blob_size [$chunk cget -blob_size] -session_id [$chunk cget -session_id] -blob_id $blob_id
      set $signaling_blobs($blob_id) $blob
    }

    $blob AppendChunk $chunk
    if { [$blob is_complete] } {
      #$self emit "blob-received" blob
      array unset signaling_blobs $blob_id
    }

  }

  method On_chunk_sent { chunk } {

    #$self emit "chunk-sent" $chunk
    $self Process_send_queue

  }

  method Process_send_queue { } {
    variable data_blob_queue
    variable pending_blob
    variable first

    if { [llength $data_blob_queue] >= 0 } {
      set queue data_blob_queue
    } else {
      return 0
    }

    set first 0

    set blob [[lindex $queue 0] 2]
    set peer_guid [[lindex $queue 0] 1]
    set peer [[lindex $queue 0] 0]

    set chunk { [$blob get_chunk version max_chunk_size first] }
    Send_chunk peer peer_guid chunk

    if { [$blob is_complete] } {
      lreplace $queue 0 0
      Add_pending_blob [$chunk cget -ack_id] $blob
    }
    return 1

  }

method __Send_chunk {peer peer_guid chunk} {
  variable local_chunk_id

  if { ![info exists local_chunk_id] } {
    set local_chunk_id [expr {int(1000 + rand() * (1+65540-1000))}]
  }
  $chunk configure -id $local_chunk_id
  set local_chunk_id [$chunk next_id]

  if { [$chunk require_ack] == 1 } {
    $self add_pending_ack [$chunk cget -ack_id]
  }

  $self Send_chunk $peer $peer_guid $chunk

}

method Send_chunk { peer peer_guid chunk } {

  #Implemented in each transport on its own
  return ""

}

}

}
