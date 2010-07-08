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

method Respond_transreq { transreq status body} {}

method Accept_transreq { transreq bridge listening nonce local_ip local_port extern_ip extern_port} {}

method Decline_transreq { transreq} {}

method Close { context reason} {}

method Send_p2p_data { _data_or_file is_file} {}

method On_blob_sent { blob} {}

method On_blob_received { blob} {}

method peer_guid {} {}

method local_id {} {}

method remote_id {} {}

method Close_end_points { status} {}

method Close_end_point { end_point status} {}

method Send_slp_message { msg} {}

method Send_data { data} {}
