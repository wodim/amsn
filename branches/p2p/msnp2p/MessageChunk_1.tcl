namespace eval :: {
  # Do not load twice
  if {[namespace exist MessageChunk_1]} return
  ## 
  ## @class	MessageChunk_1
  ## 
  class MessageChunk_1 {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor {args} {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
    # Operations
    ## 
    ## @fn public method __init__
    ## @param string header
    ## 
    ## @param string body
    ## 
    ## @param string application_id
    ## 
    ## 
    public method __init__ { header body application_id} {}

    ## 
    ## @fn public method id
    ## @return     int
    ## 
    public method id {} {}

    ## 
    ## @fn public method next_id
    ## @return     int
    ## 
    public method next_id {} {}

    ## 
    ## @fn public method session_id
    ## @return     string
    ## 
    public method session_id {} {}

    ## 
    ## @fn public method blob_id
    ## @return     string
    ## 
    public method blob_id {} {}

    ## 
    ## @fn public method ack_id
    ## @return     string
    ## 
    public method ack_id {} {}

    ## 
    ## @fn public method acked_id
    ## @return     string
    ## 
    public method acked_id {} {}

    ## 
    ## @fn public method size
    ## @return     int
    ## 
    public method size {} {}

    ## 
    ## @fn public method blob_size
    ## @return     int
    ## 
    public method blob_size {} {}

    ## 
    ## @fn public method is_control_chunk
    ## @return     bool
    ## 
    public method is_control_chunk {} {}

    ## 
    ## @fn public method is_ack_chunk
    ## @return     bool
    ## 
    public method is_ack_chunk {} {}

    ## 
    ## @fn public method is_nak_chunk
    ## @return     bool
    ## 
    public method is_nak_chunk {} {}

    ## 
    ## @fn public method is_nonce_chunk
    ## @return     bool
    ## 
    public method is_nonce_chunk {} {}

    ## 
    ## @fn public method is_signaling_chunk
    ## @return     bool
    ## 
    public method is_signaling_chunk {} {}

    ## 
    ## @fn public method has_progressed
    ## @return     bool
    ## 
    public method has_progressed {} {}

    ## 
    ## @fn public method set_data
    ## @param string data
    ## 
    ## 
    public method set_data { data} {}

    ## 
    ## @fn public method require_ack
    ## @return     bool
    ## 
    public method require_ack {} {}

    ## 
    ## @fn public method create_ack_chunk
    ## @return     string
    ## 
    public method create_ack_chunk {} {}

    ## 
    ## @fn public method get_nonce
    ## @return     string
    ## 
    public method get_nonce {} {}

    ## 
    ## @fn public method set_nonce
    ## @param string nonce
    ## 
    ## 
    public method set_nonce { nonce} {}

    ## 
    ## @fn public proc create
    ## @param string app_id
    ## 
    ## @param string session_id
    ## 
    ## @param string blob_id
    ## 
    ## @param int offset
    ## 
    ## @param int blob_size
    ## 
    ## @param int max_size
    ## 
    ## @param string sync
    ## 
    ## @return     MessageChunk_1
    ## 
    public proc create { app_id session_id blob_id offset blob_size max_size sync} {}

    ## 
    ## @fn public proc parse
    ## @param string data
    ## 
    ## @return     MessageChunk_1
    ## 
    public proc parse { data} {}

    ## 
    ## @fn public method __repr__
    ## @return     string
    ## 
    public method __repr__ {} {}

  };# end of class
};# end of namespace
