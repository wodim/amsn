namespace eval ::p2p::sessionmanager {

snit::type P2PSessionManager {

constructor {args} {}

method register_handler { handler_class} {}

method Register_session { session} {}

method Unregister_session { session} {}

method On_chunk_transferred { chunk} {}

method Get_session { session_id} {}

method Search_session_by_call { call_id} {}

method On_blob_received { blob} {}

method On_blob_sent { blob} {}

method Find_contact { account} {}

method Blob_to_session { blob} {}

}


