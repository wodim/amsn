namespace eval ::p2p::transport {

  snit::type P2PTransportManager {

    option -default_transport "SBBridge"
    option -transports {}
    variable -transport_signals -array {}
    variable -supported_transports -array {}
    variable -data_blobs -array {}

    constructor {args} {

      $self configurelist $args

      set supported_transports("SBBridge") SwitchboardP2PTransport
      set supported_transports("TCPv1") DirectP2PTransport
      #@@@@@@@@@@@@@@@@@@ register NS
      #$self configure -uun_transport [list NotificationP2PTransport [$self cget -client] $self]
            

    }

    method Register_transport { transport} {

      set transports [$self cget -transports]

      if { [lsearch $transport $transports] >= 0 } {
        return
      }

      lappend $transports $transport

      if { [info exists transport_signals($transport)] } {
        set trsign $transport_signals($transport)
      } else {
        set trsign {}
      }
      lappend $trsign [list p2pChunkReceived [list $self On_chunk_received]]
      lappend $trsign [list p2pChunkSent [list $self On_chunk_sent]]
      lappend $trsign [list p2pBlobSent [list $self On_blob_sent]]
      lappend $trsign [list p2pBlobReceived [list $self On_blob_received]]
      foreach {event callback} $trsign {
        ::Event::registerEvent $event p2pTransportManager $callback
      }
      set transport_signals($transport) $trsign

    }

    method Unregister_transport { transport} {
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
      $supported_transports($proto) transport {*}$args
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

      set best ""
      foreach transport [$self cget -transports] {
        if { [$transport cget -peer] == $peer && [$transport cget -connected] == 1 } {
          if { $best == "" } {
            set best $transport
          } elseif { [$transport cget -rating] == [$best cget -rating] } {
            set best $transport
          }
        }
      }
      return $best

    }

    method Get_transport { peer peer_guid blob } {

      set transports [$self cget -transports]

      foreach transport $transports {
        if { [ $transport can_send $peer $peer_guid blob ] } {
          return $supported_transports($transport)
        }
      }

      set transport [$self cget -default_transport]
      return $supported_transports($transport)

    }

    method On_chunk_received { transport chunk} {

      ::Event::fireEvent p2pChunkTransferred p2pTransportManager $chunk
      set session_id [$chunk cget -session_id]
      set blob_id [$blob cget -blob_id]

      if { [lsearch $session_id [array names data_blobs]] >= 0 } {
        set blob $data_blobs($session_id)
        if { [$blob transferred] == 0 } {
          $blob configure -id [$chunk cget -blob_id]
        }
      } else {
        MessageBlob blob -application_id [$chunk cget -application_id] -total_size [$chunk cget -blob_size] -session_id $session_id -blob_id $blob_id
        set data_blobs($session_id) $blob
      }

      $blob append_chunk $chunk
      if { [$blob is_complete] == 1 } {
        ::Event::fireEvent p2pBlobReceived p2pTransportManager $blob
        array unset data_blobs $session_id
      }

    }

    method On_chunk_sent { transport chunk} {
      ::Event::fireEvent p2pChunkTransferred p2pTransportManager $chunk
    }

    method On_blob_sent { transport blob} {
      ::Event::fireEvent p2pBlobSent p2pTransportManager $blob
    }

    method On_blob_received { transport blob} {
      ::Event::fireEvent p2pBlobReceived p2pTransportManager $blob
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

    method register_data_buffer { session_id2 buffer size} {
      if { [lsearch $session_id2 [array names data_blobs]] } {
        #status_log
        return
      }
      MessageBlob blob -application_id 0 -string $buffer -total_size $size -session_id $session_id2
      set data_blobs($session_id2) $blob
  }

}

}
