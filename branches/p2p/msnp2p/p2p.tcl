namespace eval ::p2p {
snit::type MSNObjectStore {
constructor {args} {
}

method Can_handle_message { message} {}

method Handle_message { peer message} {}

method request { msn_object callback errback peer} {}

method publish { msn_object} {}

method Outgoing_session_transfer_completed { session data} {}

method Incoming_session_transfer_completed { session data} {}

}

snit::type MSNObject {
constructor {args} {}
method Set_data {data} {}

typemethod parse { client xml_data} {}

method Compute_data_hash { data} {}

method Compute_checksum {} {}

}

snit::type WebcamHandler {
constructor {args} {}

method Can_handle_message { message} {}

method Handle_message { peer message} {}

method Invite { peer producer} {}

option -gsignals session-created
}

}
