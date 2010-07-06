namespace eval ::p2p::webcam {

snit::type WebcamCandidateEncoder {

    constructor {args} {}

 method encode_candidates { desc local_candidates remote_candidates} {}

method decode_candidates { desc} {}

}

snit::type  WebcamSessionMessage {

constructor {args} {}

method id {} {}

method producer {} {}

method Create_stream_description { stream} {}

method Parse {body} {}

}

snit::type WebcamSession {
delegate option * from P2PSession
delegate method * from P2PSession

constructor {args} {}

method invite {} {}

method reject {} {}

method end {} {}

dispose {} {}

method on_media_session_prepared { session} {}

method On_invite_received { message} {}

method On_bye_received { message} {}

method On_session_accepted {} {}

method On_session_rejected { message} {}

method On_data_blob_received { blob} {}

method send_data { data} {}

method send_binary_syn {} {}

method send_binary_ack {} {}

method send_binary_viewer_data {} {}

method Send_xml {} {}

method Handle_xml { data} {}

method producer {}

}

snit::type WebcamStreamDescription {

constructor {args} {}

method candidate_encoder {} {}

method ips {} {}

method ports {} {}

method rid {} {}

method sid {} {}

}

}

}
