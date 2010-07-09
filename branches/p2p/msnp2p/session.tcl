namespace eval ::p2p {

snit::type P2PSession {

variable MAX_INT32 0x7fffffff
variable MAX_INT16 0x7fff

option -session_manager ""
option -peer ""
option -euf_guid ""
option -application_id 0
option -message ""
option -id ""
option -call_id ""
option -cseq 0
option -branch ""
option -incoming 0

constructor {args} {

  $self configurelist $args

  if { $message != "" } {
    set options(-id) [[$message body] cget -session_id]
    set options(-call_id) [$message cget -call_id]
    set options(-cseq) [$message cget -cseq]
    set options(-branch) [$message cget -branch]
    set options(-incoming) 0
  } else {
    set options(-id) [$self generate_id]
    set options(-call_id) [$self generate_uuid]
    set options(-branch) [$self generate_uuid]
  }

  $options(-session_manager) Register_session $self

}

method generate_uuid { } {

#  package require uuid
#
#  set uuid [::uuid::generate]
#  binary scan $uuid  H2H2H2H2H2H2H2H2H4H* n1 n2 n3 n4 n5 n6 n7 n8 n9 n10
#  set uuid [string toupper "$n4$n3$n2$n1-$n6$n5-$n8$n7-$n9-$n10"]
#  return $uuid
  set uuid "[format %X [myRand 4369 65450]][format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [expr { int([expr {rand() * 1000000}])%65450 } ] + 4369]-[format %X [myRand 4369 65450]][format %X [myRand 4369 65450]][format %X [myRand 4369 65450]]"
  return $uuid

}

method Generate_id { {max $MAX_INT32} } {

   return [expr {int($min + rand() * (1+$max-$min))}]

}

method set_receive_data_buffer { buffer total_size} {

  MessageBlob blob -application_id [$self cget -application_id] -data $buffer -total_size $total_size -sid [$self cget -id]
  [$self cget -transport_manager] register_writable_blob $blob

}

method Invite { context } {

  SLPSessionRequestBody body -euf_guid $options(-euf_guid) -app_id $options(-application_id) -context $context -session_id $options(-id)
  SLPRequestMessage msg -method $::p2p::SLPRequestMethod::INVITE -resource [concat "MSNMSGR:"$options(-peer) -to $options(-peer) -frm [::abook::getPersonal login] -branch $options(-branch) -cseq $options(-cseq) -call_id $options(-call_id)
  $msg setBody $body
  $self Send_p2p_data $msg

}

method Transreq {} {

  set options(-cseq) 0
  SLPTransferRequestBody body -session_id $options(-id) -s_channel_state 0 -capabilities_flags 1 -bridges [[$self cget -transport_manager] cget -supported_transports] -conn_type [::abook::getDemographicField conntype]
  $msg setBoy $body
  $self Send_p2p_data $msg

}

method Respond { status_code} {

  SLPSessionRequestBody body -session_id $options(-id)
  incr options(-cseq)
  SLPResponseMessage resp -status $status_code -peer $options(-peer) -frm [::abook::getPersonal login] -cseq $options(-cseq) -branch $options(-branch) -call_id $options(-call_id)
  $resp setBody $body
  $self Send_p2p_data $resp

}

method Respond_transreq { transreq status body} {

  incr options(-cseq)
  SLPResponseMessage resp -status $status -peer $options(-peer) -frm [::abook::getPersonal login] -cseq $options(-cseq) -branch $options(-branch) -call_id
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

  SLPTransferResponseBody $body -session_id $options(-id)
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

  SLPSessionCloseBody body -context $context -session_id $options(-id) -s_channel_state 0
  set options(-cseq) 0
  set options(-branch) [$self generate_uuid]
  SLPRequestMessage msg -method ::p2p::SLPRequestMethod::BYE -resource [concat "MSNMSGR:"$options(-peer) -frm [::abook::gerPersonal login] -branch $options(-branch) -cseq $options(-cseq) -call_id $options(-call_id)
  $msg setBody $body
  $self Send_p2p_data $msg
  destroy $self

}

method Send_p2p_data { data_or_file {is_file 0} } {

  if { catch {[$data_or_file is_SLP]} } {
    set session_id $options(-id)
    set data $data_or_file
    set total_size ""
  } else {
    set session_id 0
    set data [$data_or_file toString]
    set total_size [string length $data]
  }

  MessageBlob blob -application_id $application_id -data $data -total_size $total_size -session_id $session_id -is_file $is_file
  $options(-transport_manager) send $options(-peer) $blob

}

method On_blob_sent { blob } {

  if { [$blob cget -session_id] == 0 } {
    return
  }

  set data [$blob read_data]
  if { [$blob cget -total_size] == 4 && $data == "\x00\x00\x00\x00" } {
    $self On_data_preparation_blob_sent $blob
  } else {
    $self On_data_blob_sent $blob
  }

}

method On_blob_received { blob} {

  set data [$blob read_data]

  if [ $blob cget -session_id] == 0 } {
    set msg [SLPMessage build $data]
    if { [$msg info type] == SLPRequestMessage } {
      if { [[$msg body] info type] == SLPSessionRequestBody } {
        $self On_invite_received $msg
      } elseif { [[$msg body] info type] == SLPTransferRequestBody } {
        $self Switch_bridge $msg
      } elseif { [[$msg body] info type] == SLPSessionCloseBody } {
        $self On_bye_received $msg
      } else {
        status_log "$msg : unknown signaling blob"
      }
    } elseif { [$msg info type] == SLPResponseMessage] } {
      if { [[$msg body] info type] == SLPSessionRequestBody } {
        if { [$msg cget -status] == 200 } {
          $self On_session_accepted
          #$self emit "accepted"
        } elseif { [$msg cget -status] == 603 } {
          $self On_session_rejected $msg
        }
      } elseif { [[$msg body] info type] == SLPTransferResponseBody } {
        $self Transreq_accepted [$msg body]
      } else {
        status_log "$msg : unknown response blob"
      }
    }
    return
  }

  if { [$blob cget -total_size] == 4 && $data == "\x00\x00\x00\x00" } {
    $self On_data_preparation_blob_received $blob
  } else {
    $self On_data_blob_received $blob
  }

}

method On_data_chunk_transferred { chunk } {

  if { [$chunk has_progressed ] } {
    #$self emit "progressed" [string length [$chunk body]]
  }

}

method On_data_blob_sent { blob } { 

  $self close
  #$self emit "completed" [$blob data]

}

method On_data_blob_received { blob } {

  $self close
  #$self emit "completed" [$blob data]

}

method On_invite_received { msg } { }

method On_bye_received { msg } { }

method On_session_accepted { } { }

method On_session_rejected { msg } { }

method On_bridge_selected { } { }

}

}
