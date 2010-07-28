namespace eval ::p2p {

snit::type P2PSessionManager {

variable sessions -array {}
variable trsp_mgr ""
option -handlers {}

constructor {args} {

  $self configurelist $args
  ::Event::registerEvent p2pBlobReceived2 all [list $self On_blob_received]
  ::Event::registerEvent p2pBlobSent2 all [list $self On_blob_sent]
  ::Event::registerEvent p2pChunkTransferred2 all [list $self On_chunk_transferred]

}

method transport_manager { } {

  if { $trsp_mgr == "" } {
    set trsp_mgr [P2PTransportManager %AUTO%]
  }
  return $trsp_mgr

}

method register_handler { handler_class} {

  set options(-handlers) [lappend $options(-handlers) $handler_class]

}

method Register_session { session} {

  set sid [$session cget -id]
  if { ![info exists sessions($sid)] } { set sessions($sid) "" }
  set sessions($sid) [lappend $sessions($sid) $session]

}

method Unregister_session { session} {

  set sid [$session cget -id]
  array unset sessions $sid
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

  if { [lsearch [array names sessions] $sid ] >= 0 } {
    return $sessions($sid)
  }
  return ""

}

method Search_session_by_call { cid } {

  foreach session [array names sessions] {
    if { [$session cget -call_id] == $cid } {
      return session
    } 
  }
  return ""

}

method Search_session_by_peer { peer } {

  foreach session [array names sessions] {  
    if { [$session cget -peer] == $peer } {
      return session
    }
  }
  return ""

}

method On_blob_received { event blob } {

  puts "Received blob: $blob"
  #if { [catch {set session [$self Blob_to_session $blob]} res] } {
  #  puts "Error: $res"
  #  return 0
  #}
  set session [$self Blob_to_session $blob]
  if { $session == "" } {
    if { [$blob cget -session_id] != 0 } {
      #TODO: send TLP, RESET connection
      puts "No session!!!!!"
      return
    }
    set slp_data [$blob read_data]
    set msg [SLPMessage build $slp_data]
    $msg configure -application_id [$blob cget -application_id]
    set sid [[$msg body] cget -session_id]

    if { $sid == 0 } {
      status_log "SID shouldn't be 0!!!" black
      return
    }
  
    puts "Message is [$msg info type] and the body is [[$msg body] info type]"
    if { [$msg info type] == "::p2p::SLPRequestMessage" } {
      set peer [$msg cget -frm]
      puts "Received session request from $peer"
      foreach handler $options(-handlers) {
        puts "Trying $handler"
        if {[$handler Can_handle_message $msg] } {
          #@@@@@@ p2pv2: $guid!!!
          set session [$handler Handle_message $peer "" $msg]
          if { $session != "" } {
            puts "Got session $session"
            $self Register_session $session
            break
          }
        }
      }
      if { $session == "" } {
        status_log "Don't know how to handle [[$msg body] cget -euf_guid]"
        return ""
      }
    } elseif { [[$msg body] info type] == "::p2p::SLPSessionRequestBody" } {
      set session $sessions($sid)
    } else {
      puts "[$msg info type] : What is this type?"
      return ""
    }
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
    $message configure -application_id [$blob cget -application_id]
    set sid [[$message body] cget -session_id]
  }

  if { $sid == 0 } {
    return [$self Search_session_by_call [$message cget -call_id]]
  }
  return [$self Get_session $sid]

}

}

}
