namespace eval ::p2p::session {

snit::type P2PSession {

constructor {args} {}

method _generate_id { {max MAX_INT32} } {}

method id {} {}

method incoming {} {}

method call_id {} {}

method peer {} {}

method set_receive_data_buffer { buffer total_size} {}

method Invite { context} {}

method Transreq {} {}

method Respond { status_code} {}

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
