namespace eval ::p2p::transport {

  snit::type P2PTransportManager {

    option -switchboard_manager
    option -default_transport "SBBridge"
    option -transports {}
    option -transport_signals -array {}
    option -supported_transports -array {}
    option -data_blobs -array {}
    option -client ""

    constructor {args} {

      $self configurelist $args

      $self configure -switchboard_manager [[$self cget -client] cget -switchboard_manager]
      $self configure -supported_transports("SBBridge") SwitchboardP2PTransport
      $self configure -supported_transports("TCPv1") DirectP2PTransport
      #@@@@@@@@@@@@@@@@@@ register NS
      #$self configure -uun_transport [list NotificationP2PTransport [$self cget -client] $self]
            

    }

    method Register_transport { transport} {

      set transports [$self cget -transports]

      if { [lsearch $transport $transports] >= 0 } {
        return
      }

      lappend $transports $transport

      set transport_signals [$self cget -transport_signals]
      lappend $transport_signals [list p2pChunkReceived [list $self On_chunk_received]]
      lappend $transport_signals [list p2pChunkSent [list $self On_chunk_sent]]
      lappend $transport_signals [list p2pBlobSent [list $self On_blob_sent]]
      lappend $transport_signals [list p2pBlobReceived [list $self On_blob_received]]
      foreach {event callback} $transport_signals {
        ::Event::registerEvent $event p2pTransportManager $callback
      }
      set transport_signals($transport) $transport_signals

    }

    method Unregister_transport { transport} {
      set transports [$self cget -transports]

      if { [lsearch $transport $transports] < 0 } {
        return
      }

      set transport_signals [$self cget -transport_signals]
      set signals $transport_signals($transport)
      foreach {event callback} $signals {
        ::Event::unregisterEvent $event p2pTransportManager $callback
      }

      array unset transport_signals $transport

      $self configure -transport_signals $transport_signals
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
      array set supported_transports [$self cget -supported_transports]

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
        ::Event::fireEvent p2pBlobReceived p2pTransportManager $blob
        array unset blobs $session_id
        $self configure -data_blobs $blobs
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
