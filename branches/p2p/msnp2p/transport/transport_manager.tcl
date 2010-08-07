namespace eval ::p2p {

  snit::type P2PTransportManager {

    option -default_transport SBBridge
    option -transports {}
    variable transport_signals -array {}
    variable supported_transports -array {}
    variable data_blobs -array {}

    constructor {args} {

      $self configurelist $args

      status_log "Configured P2PTransportManager $self"
      set supported_transports(SBBridge) SwitchboardP2PTransport
      set supported_transports(TCPv1) DirectP2PTransport
      #@@@@@@@@@@@@@@@@@@ register NS
      #$self configure -uun_transport [list NotificationP2PTransport [$self cget -client] $self]
      set trsign {}
      set trsign [lappend trsign p2pChunkReceived On_chunk_received]
      set trsign [lappend trsign p2pBlobSent On_blob_sent]
      set trsign [lappend trsign p2pBlobReceived On_blob_received]
      foreach {event callback} $trsign {
        ::Event::registerEvent $event all [list $self $callback]
      }

    }

    method get_default_transport { } {

      return $supported_transports($options(-default_transport))

    }

    method supported_transports { } {

      return [array get supported_transports]

    }

    method Register_transport { transport } {

      status_log "@@@@@@@@@@@@@@@@@@ Registering $transport"
      set transports [$self cget -transports]

      if { [lsearch $transport $transports] >= 0 } {
        return
      }

      lappend transports $transport
      $self configure -transports $transports

      if { [info exists transport_signals($transport)] } {
        set trsign $transport_signals($transport)
      } else {
        set trsign {}
      }
      #set trsign [lappend trsign p2pChunkReceived On_chunk_received]
      #set trsign [lappend trsign p2pBlobSent On_blob_sent]
      #set trsign [lappend trsign p2pBlobReceived On_blob_received]
      foreach {event callback} $trsign {
        ::Event::registerEvent $event all [list $self $callback]
      }
      set transport_signals($transport) $trsign

    }

    method Unregister_transport { transport } {
      set transports [$self cget -transports]

      if { [lsearch $transport $transports] < 0 } {
        return
      }

      set signals $transport_signals($transport)
      foreach {event callback} $signals {
        ::Event::unregisterEvent $event p2pTransportManager $callback
      }

      array unset transport_signals $transport

    }

    method get_supported_transport { choices } {

      foreach choice $choices {
        if { [info exists supported_transports($choice)] } {
          return $choice
        }
      }
      return ""

    }

    method create_transport { peer proto args } {

      if { $proto == "" || ![info exists supported_transports($proto)] } {
        return ""
      }
      set transport [$supported_transports($proto) %AUTO% -peer $peer -transport_manager $self {*}$args]
      return $transport

    }

    method close_transport { peer } {
     
      set transports [$self cget -transports]
      foreach transport $transports {
        if { [$transport cget -peer] == $peer } {
          $transport close
        }
      }

    }

    method find_transport { peer } {

      status_log "$self actually trying to find a transport!"
      set best ""
      foreach transport [$self cget -transports] {
        if { [$transport cget -peer] == $peer } {
          if { $best == "" } {
            set best $transport
          } elseif { [$transport cget -rating] >= [$best cget -rating] } {
            set best $transport
          }
        }
      }
      return $best

    }

    method Get_transport { peer peer_guid blob } {

      set best [$self find_transport $peer]
      if { $best != "" } {
        return $best
      }
      return [$self create_transport $peer $options(-default_transport)]

    }

    method On_chunk_received { transport chunk } {

      status_log "Transport manager received $chunk"
      set session_id [$chunk session_id]
      set blob_id [$chunk blob_id]

      if { [lsearch $session_id [array names data_blobs]] >= 0 } {
        set blob $data_blobs($session_id)
        if { [$blob transferred] == 0 } {
          $blob configure -id [$chunk blob_id]
        }
      } else {
        set blob [MessageBlob %AUTO% -application_id [$chunk cget -application_id] -blob_size [$chunk blob_size] -session_id $session_id -blob_id $blob_id]
	::Event::fireEvent p2pNewBlob p2pTransportManager $blob
        set data_blobs($session_id) $blob
      }

      $blob append_chunk $chunk
      ::Event::fireEvent p2pChunkTransferred p2pTransportManager $chunk $blob
      if { [$blob is_complete] == 1 } {
        status_log "Blob $blob is complete"
        ::Event::fireEvent p2pBlobReceived p2pTransportManager $blob
        array unset data_blobs $session_id
      } else {
        status_log "$blob size is [$blob cget -blob_size] and we have [$blob transferred] so not complete"
      }

    }

   method On_blob_sent { transport blob} {
      ::Event::fireEvent p2pBlobSent2 p2pTransportManager $blob
    }

    method On_blob_received { transport blob} {
      ::Event::fireEvent p2pBlobReceived2 p2pTransportManager $blob
    }

    method send_slp_message { peer peer_guid application_id msg} {
      $self send_data $peer $peer_guid $application_id 0 $msg
    }

    method send { peer peer_guid blob } {

      set transport [$self Get_transport $peer $peer_guid $blob]
      status_log "Using transport $transport to send $blob to $peer"
      $transport send $peer $peer_guid $blob

    }

    method send_data { peer peer_guid application_id session_id data} {
      set blob [MessageBlob %AUTO% -application_id $application_id -data $data -session_id $session_id]
      set transport [$self Get_transport $peer $peer_guid $blob]
      $transport send $peer $peer_guid $blob
    }

    method register_data_buffer { session_id2 buffer size} {
      if { [lsearch $session_id2 [array names data_blobs]] } {
        #status_log
        return
      }
      set blob [MessageBlob %AUTO% -application_id 0 -string $buffer -total_size $size -session_id $session_id2]
      set data_blobs($session_id2) $blob
  }

}

}
