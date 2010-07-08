namespace eval ::p2p {

snit::type P2PSessionManager {

option -client ""
option -sessions ""
option -handlers {}
option -transport_manager ""

constructor {args} {

#@@@@@@@@@@@@@@ TODO: events!!

  $self configurelist $args
  array set sessions {}
  $self configure -sessions $sessions
  P2PTransportManager mngr -client $options(-client)
  $self configure -transport_manager $mngr
  #self._transport_manager.connect("blob-received", lambda tr, blob: self._on_blob_received(blob))
  #self._transport_manager.connect("blob-sent", lambda tr, blob: self._on_blob_sent(blob))
  #self._transport_manager.connect("chunk-transferred", lambda tr, chunk: self._on_chunk_transferred(chunk))

}

method register_handler { handler_class} {

  lappend $options(-handlers) $handler_class

}

method Register_session { session} {

set sid [$session cget -id]
array set sessions $options(-sessions)
lappend $sessions($sid) $session
$self configure -sessions $session

}

method Unregister_session { session} {

  set sid [$session cget -id]
  array set sessions $options(-sessions)
  set ind [lsearch $sessions $sid]
  lreplace $sessions $ind $ind
  $self configure -sessions $session
  if { [$self Search_session_by_peer [$session cget -peer]] < 0 } {
    $options(-transport-manager) close_transport [$session cget -peer]
  }

}

method On_chunk_transferred { chunk} {

  set sid [$chunk get_field session_id]
  $self configure -session_id $sid
  if { $sid == 0 } {
    return
  }
  set session [$self Get_session $sid]
  if { $session == "" } {
    return
  }
  $session On_data_chunk_transferred $chunk

}

method Get_session { sid } {

  if { [lsearch [array names $options(-sessions)] $sid ] >= 0 } {
    array set sessions $options(-sessions)
    return $sessions($sid)
  }
  return ""

}

method Search_session_by_call { cid } {

  array set sessions $options(-sessions)
  foreach session [array names sessions] {
    if { [$session cget -call_id] == $cid } {
      return session
    } 
  }
  return ""

}

method Search_session_by_peer { peer } {

  array set sessions $options(-sessions)
  foreach session [array names sessions] {  
    if { [$session cget -peer] == $peer } {
      return session
    }
  }
  return ""

}

method On_blob_received { blob} {

  if { [catch {set session [$self Blob_to_session $blob]} ] res } {
    status_log $res
    return 0
  }
  if { $session == "" } {
    if { [$blob cget -session_id] != 0 } {
      #TODO: send TLP, RESET connection
      return
    }
  }
  set slp_data [$blob read_data]
  set msg [SLPMessage build $slp_data]
  set sid [[$msg body] cget -session_id]

  if { $sid == 0 } {
    status_log "SID shouldn't be 0!!!" black
    return
  }

  if { [$msg info type] == "::p2p::SLPSessionRequestMessage" } {
    set peer [$msg cget -frm]
    foreach handler $options(-handlers) {
      if {[$handler Can_handle_message $msg] } {
        set session [$handler Handle_message $peer $msg]
        if { $session != "" } {
          $self Register_session $session
          break
        }
      }
    }
    if { $session == "" } {
      status_log "Don't know how to handle [[$msg body] cget -euf_guid]"
      return ""
    }
  } elseif { [$msg info type] == "::p2p::TransferRequestBody" } {
    array set sessions [$self cget -sessions]
    set session $sessions($sid)
  } else {
    return ""
  }
  $session On_blob_received $blob

}

method On_blob_sent { blob} {

  set session [$self Blob_to_session $blob]
  if { $session == "" } {
  }
  $session On_blob_sent $blob

}

#method Find_contact { account} {}

method Blob_to_session { blob} {

  set sid [$blob cget -session_id]
  if { $sid == 0 } {
    set slp_data [$blob read_data]
    set message [SLPMessage build $slp_data]
    set sid [[$message body] cget -session_id]
  }

  if { $sid == 0 } {
    return [$self Search_session_by_call [$message cget -call_id]]
  }
  return [$self Get_session $sid]

}

}


