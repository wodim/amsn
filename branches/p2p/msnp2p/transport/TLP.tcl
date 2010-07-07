namespace eval ::p2p::transport {

  snit::type ControlBlob {
    constructor { session_id flags dw1 dw2 qw1} {}
    method get_chunk { max_size} {}
    method is_control_blob {} {}
  };# end of class

 snit::type MessageBlob {
    constructor { application_id data total_size session_id blob_id is_file} {}
    method transferred {} {}
    method is_complete {} {}
    method is_data_blob {} {}
    method is_control_blob {} {}
    method read_data {} {}
    method get_chunk { int} {}
    method append_chunk { chunk} {}
  };# end of class

  snit::type MessageChunk {
    constructor {}
    typemethod parse { data} {}
    method create { version app_id session_id blob_id offset blob_size max_size sync} {}
  };# end of class

}
