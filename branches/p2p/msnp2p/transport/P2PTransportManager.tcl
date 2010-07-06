namespace eval ::p2p::transport {
  # Do not load twice
  if {[namespace exist P2PTransportManager]} return
  ## 
  ## @class	P2PTransportManager
  ## 
  class P2PTransportManager {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor { client} {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
    # Operations
    ## 
    ## @fn public method __init__
    ## @param string client
    ## 
    ## 

    ## 
    ## @fn public method _register_transport
    ## @param string transport
    ## 
    ## 
    public method _register_transport { transport} {}

    ## 
    ## @fn public method _unregister_transport
    ## @param string transport
    ## 
    ## 
    public method _unregister_transport { transport} {}

    ## 
    ## @fn public method _get_transport
    ## @param string peer
    ## 
    ## 
    public method _get_transport { peer} {}

    ## 
    ## @fn public method _on_chunk_received
    ## @param string transport
    ## 
    ## @param string chunk
    ## 
    ## 
    public method _on_chunk_received { transport chunk} {}

    ## 
    ## @fn public method _on_chunk_sent
    ## @param string transport
    ## 
    ## @param string chunk
    ## 
    ## 
    public method _on_chunk_sent { transport chunk} {}

    ## 
    ## @fn public method _on_blob_sent
    ## @param string transport
    ## 
    ## @param string blob
    ## 
    ## 
    public method _on_blob_sent { transport blob} {}

    ## 
    ## @fn public method _on_blob_received
    ## @param string transport
    ## 
    ## @param string blob
    ## 
    ## 
    public method _on_blob_received { transport blob} {}

    ## 
    ## @fn public method send_slp_message
    ## @param string peer
    ## 
    ## @param string peer_guid
    ## 
    ## @param string application_id
    ## 
    ## @param string message
    ## 
    ## 
    public method send_slp_message { peer peer_guid application_id message} {}

    ## 
    ## @fn public method send_data
    ## @param string peer
    ## 
    ## @param string peer_guid
    ## 
    ## @param string application_id
    ## 
    ## @param string session_id
    ## 
    ## @param string data
    ## 
    ## 
    public method send_data { peer peer_guid application_id session_id data} {}

    ## 
    ## @fn public method register_data_buffer
    ## @param string session_id
    ## 
    ## @param string buffer
    ## 
    ## @param int size
    ## 
    ## 
    public method register_data_buffer { session_id buffer size} {}

  };# end of class
};# end of namespace
