namespace eval :: {
  # Do not load twice
  if {[namespace exist P2PSession]} return
  ## 
  ## @class	P2PSession
  ## 
  class P2PSession {
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
    ## @param string session_manager
    ## 
    ## @param string peer
    ## 
    ## @param string euf_guid
    ## 
    ## @param int application_id
    ## 
    ## @param string message
    ## 
    ## 
    public method __init__ { session_manager peer euf_guid application_id message} {}

    ## 
    ## @fn public method _generate_id
    ## @param int max (default=MAX_INT32) 
    ## 
    ## 
    public method _generate_id { {max MAX_INT32} } {}

    ## 
    ## @fn public method id
    ## @return     string
    ## 
    public method id {} {}

    ## 
    ## @fn public method incoming
    ## @return     string
    ## 
    public method incoming {} {}

    ## 
    ## @fn public method call_id
    ## @return     string
    ## 
    public method call_id {} {}

    ## 
    ## @fn public method peer
    ## @return     string
    ## 
    public method peer {} {}

    ## 
    ## @fn public method set_receive_data_buffer
    ## @param string buffer
    ## 
    ## @param int total_size
    ## 
    ## 
    public method set_receive_data_buffer { buffer total_size} {}

    ## 
    ## @fn public method _invite
    ## @param string context
    ## 
    ## 
    public method _invite { context} {}

    ## 
    ## @fn public method _transreq
    ## 
    public method _transreq {} {}

    ## 
    ## @fn public method _respond
    ## @param int status_code
    ## 
    ## 
    public method _respond { status_code} {}

    ## 
    ## @fn public method _respond_transreq
    ## @param string transreq
    ## 
    ## @param int status
    ## 
    ## @param string body
    ## 
    ## 
    public method _respond_transreq { transreq status body} {}

    ## 
    ## @fn public method _accept_transreq
    ## @param string transreq
    ## 
    ## @param string bridge
    ## 
    ## @param bool listening
    ## 
    ## @param string nonce
    ## 
    ## @param string local_ip
    ## 
    ## @param int local_port
    ## 
    ## @param string extern_ip
    ## 
    ## @param int extern_port
    ## 
    ## 
    public method _accept_transreq { transreq bridge listening nonce local_ip local_port extern_ip extern_port} {}

    ## 
    ## @fn public method _decline_transreq
    ## @param string transreq
    ## 
    ## 
    public method _decline_transreq { transreq} {}

    ## 
    ## @fn public method _close
    ## @param string context
    ## 
    ## @param string reason
    ## 
    ## 
    public method _close { context reason} {}

    ## 
    ## @fn public method _dispose
    ## 
    public method _dispose {} {}

    ## 
    ## @fn public method _send_p2p_data
    ## @param string _data_or_file
    ## 
    ## @param bool is_file
    ## 
    ## @return     deprecated
    ## 
    public method _send_p2p_data { _data_or_file is_file} {}

    ## 
    ## @fn public method _on_blob_sent
    ## @param string blob
    ## 
    ## 
    public method _on_blob_sent { blob} {}

    ## 
    ## @fn public method _on_blob_received
    ## @param string blob
    ## 
    ## 
    public method _on_blob_received { blob} {}

    ## 
    ## @fn public method peer_guid
    ## @return     string
    ## 
    public method peer_guid {} {}

    ## 
    ## @fn public method local_id
    ## @return     string
    ## 
    public method local_id {} {}

    ## 
    ## @fn public method remote_id
    ## @return     string
    ## 
    public method remote_id {} {}

    ## 
    ## @fn public method _close_end_points
    ## @param string status
    ## 
    ## 
    public method _close_end_points { status} {}

    ## 
    ## @fn public method _close_end_point
    ## @param string end_point
    ## 
    ## @param string status
    ## 
    ## 
    public method _close_end_point { end_point status} {}

    ## 
    ## @fn public method _send_slp_message
    ## @param string message
    ## 
    ## 
    public method _send_slp_message { message} {}

    ## 
    ## @fn public method _send_data
    ## @param string data
    ## 
    ## 
    public method _send_data { data} {}

  };# end of class
};# end of namespace
