namespace eval ::p2p::transport {

  snit::type P2PTransportManager {

    option -switchboard_manager
    option -default_transport
    option -transports
    option -transport_signals
    option -data_blobs
    option -client ""

    constructor {args} {

      $self configurelist $args

      $self configure -switchboard_manager [[$self cget -client] cget -switchboard_manager]
      $self configure -default_transport [list SwitchboardP2PTransport handle_peer [$self cget -client] $self]
      $self configure -transports {}
      $self configure -transport_signals [array set transport_signals {}]
      $self configure -data_blobs [array set data_blobs {}]
      #@@@@@@@@@@@@@@@@@@
      #$self configure -uun_transport [list NotificationP2PTransport [$self cget -client] $self]
            

    }

    method Register_transport { transport} {

      set transports [$self cget -transports]

      if { [lsearch $transport $transports] >= 0 } {
        return
      }

      lappend $transports $transport

      set transport_signals [$self cget -transport_signals]
      lappend $transport_signals [list "chunk-received" [list $self On_chunk_received]]
      lappend $transport_signals [list "chunk-sent" [list $self On_chunk_sent]]
      lappend $transport_signals [list "blob-sent" [list $self On_blob_sent]]
      lappend $transport_signals [list "blob-received" [list $self On_blob_received]]
      set transport_signals($transport) $transport_signals

    }

    method Unregister_transport { transport} {
      set transports [$self cget -transports]

      if { [lsearch $transport $transports] < 0 } {
        return
      }

      set transport_signals [$self cget -transport_signals]
      set signals $transport_signals($transport)
      foreach signal $signals {
        $transport disconnect $signal
      }

      array unset transport_signals $transport

      $self configure -transport_signals $transport_signals
    }

    method Get_transport { peer peer_guid blob } {

      set transports [$self cget -transports]

      foreach transport $transports {
        if { [ $transport can_send $peer $peer_guid blob ] } {
          return transport
        }
      }

      set transport [$self cget -default_transport]
      return [list $transport $peer $peer_guid]

    }

    method On_chunk_received { transport chunk} {

      #$self emit "chunk-transferred" $chunk
      set session_id [$chunk cget -session_id]
      set blob_id [$blob cget -blob_id]
      set blobs [$self cget -data_blobs]

      if { [lsearch $session_id [array names blobs]] >= 0 } {
        set blob $blobs($session_id)
        if { [$blob transferred] == 0 } {
          $blob configure -id [$chunk cget -blob_id]
        }
      } else {
        MessageBlob blob -application_id [$chunk cget -application_id] -total_size [$chunk cget -blob_size] -session_id $session_id -blob_id $blob_id
        set blobs($session_id) $blob
        $self configure -data_blobs $blobs
      }

      $blob append_chunk $chunk
      if { [$blob is_complete] == 1 } {
        #$self emit "blob-received" $blob
        array unset blobs $session_id
        $self configure -data_blobs $blobs
      }

    }

    method On_chunk_sent { transport chunk} {
      #$self emit "chunk-transferred" $chunk
    }

    method On_blob_sent { transport blob} {
      #$self emit "blob-sent" $blob
    }

    method On_blob_received { transport blob} {
      #$self emit "blob-received" $blob
    }

    #@@@@@@@@@@@@@@ $msg toString?
    method send_slp_message { peer peer_guid application_id msg} {
      $self send_data $peer $peer_guid $application_id 0 $msg
    }

    method send_data { peer peer_guid application_id session_id data} {
      MessageBlob blob -application_id $application_id -data $data -session_id $session_id
      set transports [$self cget -transports]
      set transport [$self Get_transport $peer $peer_guid $blob]
      $transport send $peer $peer_guid $blob
    }

    method register_data_buffer { session_id buffer size} {}
      set blobs [$self cget -data_blobs]
      if { [lsearch $session_id [array names blobs] } {
        #status_log
        return
      }
      MessageBlob blob -application_id 0 -string $buffer -total_size $size -session_id $session_id
      set blobs($session_id) $blob
      $self configure -data_blobs $blobs
  }

}
