namespace eval ::p2pv1 {

  snit::type TLPHeader {

    constructor { header} {}

    method parse { data} {}

  }

  snit::type MessageChunk {
    constructor { header body application_id} {}
    method id {} {}
    method next_id {} {}
    method session_id {} {}
    method blob_id {} {}
    method ack_id {} {}
    method acked_id {} {}
    method size {} {}
    method blob_size {} {}
    method is_control_chunk {} {}
    method is_ack_chunk {} {}
    method is_nak_chunk {} {}
    method is_nonce_chunk {} {}
    method is_signaling_chunk {} {}
    method has_progressed {} {}
    method set_data { data} {}
    method require_ack {} {}
    method create_ack_chunk {} {}
    method get_nonce {} {}
    method set_nonce { nonce} {}
    typemethod create { app_id session_id blob_id offset blob_size max_size sync} {}
    typemethod parse { data} {}
  }



}
