namespace eval ::p2p {

snit::type P2PSession {

option -session_manager -default ""
option -peer -readonly no -default ""
option -euf_guid -default ""
option -application_id -default 0
option -message -default ""
option -id -default ""
option -call_id -default ""
option -cseq -default 0
option -branch -default ""
option -incoming -default 0
option -context -default ""

constructor {args} {

  $self configurelist $args

}

method conf2 { } {

  if { $options(-message) != "" } {
    set message $options(-message)
    set options(-id) [[$message body] cget -session_id]
    set options(-call_id) [$message cget -call_id]
    set options(-cseq) [$message cget -cseq]
    set options(-branch) [$message cget -branch]
    set options(-incoming) 1
  } else {
    set options(-id) [::p2p::generate_id]
    set options(-call_id) [::p2p::generate_uuid]
    set options(-branch) [::p2p::generate_uuid]
  }

  status_log "Session manager: [$self cget -session_manager]"
  [$self cget -session_manager] Register_session $self

}

method transport_manager { } {

  return [ [$self cget -session_manager] transport_manager]

}

method set_receive_data_buffer { buffer total_size} {

  set blob [MessageBlob %AUTO% -application_id [$self cget -application_id] -data $buffer -blob_size $total_size -sid [$self cget -id]]
  [$self transport_manager] register_writable_blob $blob

}

method invite { context } {
  status_log "Inviting for $context"

  set body [SLPSessionRequestBody %AUTO% -euf_guid $options(-euf_guid) -app_id $options(-application_id) -context $context -session_id $options(-id)]
  $body conf2
  set msg [SLPRequestMessage %AUTO% -method $::p2p::SLPRequestMethod::INVITE -resource [concat MSNMSGR:$options(-peer)] -to $options(-peer) -frm [::abook::getPersonal login] -branch $options(-branch) -cseq $options(-cseq) -call_id $options(-call_id)]
  $msg conf2
  $msg setBody $body
  puts [[$msg body] toString]
  $self Send_p2p_data $msg

}

method Transreq {} {

  set options(-cseq) 0
  set body [SLPTransferRequestBody %AUTO% -session_id $options(-id) -s_channel_state 0 -capabilities_flags 1 -bridges [[$self transport_manager] supported_transports] -conn_type [::abook::getDemographicField conntype]]
  set msg [SLPRequestMessage %AUTO% -method $::p2p::SLPRequestMethod::INVITE -resource [concat MSNMSGR:$options(-peer)] -to $options(-peer) -frm [::abook::getPersonal login] -branch $options(-branch) -cseq $options(-cseq) -call_id $options(-call_id)]
  $msg conf2
  $msg setBody $body
  $self Send_p2p_data $msg

}

method Respond { status_code} {

  set body [SLPSessionRequestBody %AUTO% -session_id $options(-id) -context $options(-context)]
  $body conf2
  incr options(-cseq)
  set resp [SLPResponseMessage %AUTO% -status $status_code -to $options(-peer) -frm [::abook::getPersonal login] -cseq $options(-cseq) -branch $options(-branch) -call_id $options(-call_id)]
  $resp setBody $body
  $self Send_p2p_data $resp

}

method Respond_transreq { transreq status body} {

  incr options(-cseq)
  set resp [SLPResponseMessage %AUTO% -status $status -to $options(-peer) -frm [::abook::getPersonal login] -cseq $options(-cseq) -branch $options(-branch) -call_id]
$options(-call_id)
  $resp setBody $body
  $self Send_p2p_data $resp

}

method Accept_transreq { transreq bridge listening nonce local_ip local_port extern_ip extern_port} {

  set conn_type [::abook::getDemographicField conntype]
  SLPTransferResponseBody body -bridge $bridge -listening $listening -nonce $nonce -local_ip $local_ip -local_port $local_port -extern_ip $extern_ip -extern_port $extern_port -conn_type $conn_type -session_id $options(-id) -s_channel_state 0 -capabilities_flags 1
  $self Respond_transreq 200 $body

}

method Decline_transreq { transreq} {

  SLPTransferResponseBody $body -session_id $options(-id) -peer $options(-peer)
  $self Respond_transreq 603 $body

}

method Select_address { transresp } {

  set client_ip [::abook::getDemographicField clientip]
  set local_ip [::abook::getDemographicField localip]
  set port [$transresp cget -external_port]
  set ips {}

  foreach ip [$transresp cget -external_ips] {
    if { $ip == $client_ip} { ;#same NAT
      set ips {}
      break
    }
    lappend $ips [list $ip $port]
  }

  if { [llength $ips] > 0 } {
    return [lindex $ips 0]
  }

  set port [$transresp cget -internal_port]
  set dot [string last "." $local_ip]
  set local_subnet [string range $local_ip 0 $dot]
  foreach ip [$transresp cget -internal_ips] {
    set dot [string last "." $ip
    set remote_subnet [string range $ip 0 $dot]
    if { $local_subnet == $remote_subnet} {
      return [list $ip $port]
    }
  }

  #Could not find any valid IPs
  return {"" ""}

}

method Bridge_listening { new_bridge external_ip external_port transreq } {

  #@@@@@@ TODO: add those to SB
  $self Accept_transreq $transreq [$new_bridge cget -protocol] 1 [$new_bridge cget -nonce] [$new_bridge cget -ip] [$new_bridge cget -port] $external_ip $external_port

}

method Bridge_switched { new_bridge } {

  $self On_bridge_selected

}

method Bridge_failed { new_bridge } {

  $self On_bridge_selected

}

method Close { context reason } {

  set body [SLPSessionCloseBody %AUTO% -context $context -session_id $options(-id) -s_channel_state 0]
  $body conf2
  set options(-cseq) 0
  set options(-branch) [::p2p::generate_uuid]
  set msg [SLPRequestMessage %AUTO% -method ::p2p::SLPRequestMethod::BYE -resource [concat "MSNMSGR:"$options(-peer) -frm [::abook::gerPersonal login] -branch $options(-branch) -cseq $options(-cseq) -call_id $options(-call_id)]]
  $msg conf2
  $msg setBody $body
  $self Send_p2p_data $msg
  destroy $self

}

method Send_p2p_data { data_or_file {is_file 0} } {
  status_log "Sending p2p data"

  if { [catch {$data_or_file is_SLP}] } {
    set session_id $options(-id)
    set data $data_or_file
    set total_size ""
  } else {
    set session_id 0
    set data [$data_or_file toString]
    set total_size [string length $data]
  }

  set blob [MessageBlob %AUTO% -application_id $options(-application_id) -data $data -blob_size $total_size -session_id $session_id -is_file $is_file]
  [$self transport_manager] send $options(-peer) "" $blob

}

method On_blob_sent { blob } {

  if { [$blob cget -session_id] == 0 } {
    return
  }

  set data [$blob read_data]
  if { [$blob cget -blob_size] == 4 && $data == "\x00\x00\x00\x00" } {
    $self On_data_preparation_blob_sent $blob
  } else {
    $self On_data_blob_sent $blob
  }

}

method On_blob_received { blob } {

  set data [$blob read_data]

  status_log "Received a new blob: $blob"
  if { [ $blob cget -session_id] == 0 } {
    set msg [SLPMessage build $data]
    $msg configure -application_id [$blob cget -application_id]
    status_log "Type: [$msg info type] and body: [[$msg body] info type]"
    if { [$msg info type] == "::p2p::SLPRequestMessage" } {
      status_log "It is SLPRequestMessage"
      if { [[$msg body] info type] == "::p2p::SLPSessionRequestBody" } {
        status_log "Received an invite"
        $self On_invite_received $msg
      } elseif { [[$msg body] info type] == "::p2p::SLPTransferRequestBody" } {
        status_log "Received a transfer request"
        $self Switch_bridge $msg
      } elseif { [[$msg body] info type] == "::p2p::SLPSessionCloseBody" } {
        status_log "Received a BYE"
        $self On_bye_received $msg
      } else {
        status_log "$msg : unknown signaling blob"
      }
    } elseif { [$msg info type] == "::p2p::SLPResponseMessage" } {
      status_log "Received a response"
      if { [[$msg body] info type] == "::p2p::SLPSessionRequestBody" } {
        status_log "Session request"
        if { [$msg cget -status] == 200 } {
          status_log "Our session got accepted"
          $self On_session_accepted
          ::Event::fireEvent p2pAccepted p2p {}
        } elseif { [$msg cget -status] == 603 } {
          status_log "Our session got rejected :("
          $self On_session_rejected $msg
        }
      } elseif { [[$msg body] info type] == "::p2p::SLPTransferResponseBody" } {
        status_log "Our transfer request got accepted"
        $self Transreq_accepted [$msg body]
      } else {
        status_log "$msg : unknown response blob"
      }
    }
    return
  }

  if { [$blob cget -blob_size] == 4 && $data == "\x00\x00\x00\x00" } {
    status_log "Received a data preparation blob"
    $self On_data_preparation_blob_received $blob
  } else {
    status_log "Received a data blob"
    $self On_data_blob_received $blob
  }

}

method On_data_chunk_transferred { chunk } {

  if { [$chunk has_progressed ] } {
    ::Event::fireEvent p2pProgressed p2p [string length [$chunk body]]
  }

}

method Switch_bridge { transreq } {

  set choices [[$transreq body] cget -bridges]
  set proto [[$self transport_manager] get_supported_transports $choices]
  set new_bridge [[$self transport_manager] create_transport [$self cget -peer] $proto]
  if { $new_bridge == "" || {$new_bridge connected} == 1 } {
    $self Bridge_selected
  } else {
    ::Event::registerEvent p2pListening all [list $self Bridge_listening $transreq]
    ::Event::registerEvent p2pConnected all [list $self Bridge_switched]
    ::Event::registerEvent p2pFailed all [list $self Bridge_failed]
  }

}

method Request_bridge { } {

  set bridge [[$self transport_manager] find_transport [$self cget -peer]]
  if { $options(-context) != "" } { ;#MSNObj exists
    set msnobj [::p2p::MSNObject parse [string trim [base64::decode $options(-context)]]]
    set type [$msnobj cget -type]
    if { $type == $::p2p::MSNObjectType::DISPLAY_PICTURE || $type == $::p2p::MSNObjectType::CUSTOM_EMOTICON } { ;#We MUST request a direct connection for files but not for DPs
      if { [info exists bridge] && $bridge != "" } { ;#Just get an existing bridge
        $self On_bridge_selected
	return
      }
    }
  }
  if { [info exists bridge] && $bridge != "" && [$bridge rating] > 0 } {
    $self On_bridge_selected
  } else {
    $self Transreq
  }

}

method On_data_blob_sent { blob } { 

  ::Event::fireEvent p2pIncomingCompleted p2p [$blob cget -data]
  destroy $blob
  destroy $self ;#Suicide????

}

method On_data_blob_received { blob } {

  ::Event::fireEvent p2pOutgoingSessionTransferCompleted p2p $self [$blob cget -data]
  destroy $blob
  destroy $self

}

method On_data_preparation_blob_received { blob } { }

method Transreq_accepted { transresp } {

  if { [$transresp cget -listening] != 1 } {
    $self Bridge_failed ""
    return
  }

  set ipport [$self Select_address $transresp]
  set ip [lindex $ipport 0]
  set port [lindex $ipport 1]

  set new_bridge [[$self transport_manager] create_transport $options(-peer) [$transresp cget -bridge] -ip $ip -port $port -nonce [$transresp cget -nonce] ]
  if { $new_bridge == "" || [$new_bridge connected] } {
    $self Bridge_selected
  } else {
    ::Event::registerEvent p2pConnected all [list $self Bridge_switched]
    ::Event::registerEvent p2pFailed all [list $self Bridge_failed]
    $new_bridge open
  }

}

method On_invite_received { msg } { }

method On_bye_received { msg } { }

method On_session_accepted { } { }

method On_session_rejected { msg } { }

method On_bridge_selected { } {

  ::Event::fireEvent p2pBridgeSelected p2pSession 

}

}

}
