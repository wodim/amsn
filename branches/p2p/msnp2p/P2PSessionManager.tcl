namespace eval :: {
  # Do not load twice
  if {[namespace exist P2PSessionManager]} return
  ## 
  ## @class	P2PSessionManager
  ## 
  class P2PSessionManager {
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
    ## @param string client
    ## 
    ## 
    public method __init__ { client} {}

    ## 
    ## @fn public method register_handler
    ## @param string handler_class
    ## 
    ## 
    public method register_handler { handler_class} {}

    ## 
    ## @fn public method _register_session
    ## @param string session
    ## 
    ## 
    public method _register_session { session} {}

    ## 
    ## @fn public method _unregister_session
    ## @param string session
    ## 
    ## 
    public method _unregister_session { session} {}

    ## 
    ## @fn public method _on_chunk_transferred
    ## @param string chunk
    ## 
    ## 
    public method _on_chunk_transferred { chunk} {}

    ## 
    ## @fn public method _get_session
    ## @param string session_id
    ## 
    ## 
    public method _get_session { session_id} {}

    ## 
    ## @fn public method _search_session_by_call
    ## @param string call_id
    ## 
    ## 
    public method _search_session_by_call { call_id} {}

    ## 
    ## @fn public method _on_blob_received
    ## @param string blob
    ## 
    ## 
    public method _on_blob_received { blob} {}

    ## 
    ## @fn public method _on_blob_sent
    ## @param string blob
    ## 
    ## 
    public method _on_blob_sent { blob} {}

    ## 
    ## @fn public method _find_contact
    ## @param string account
    ## 
    ## 
    public method _find_contact { account} {}

    ## 
    ## @fn public method _blob_to_session
    ## @param string blob
    ## 
    ## 
    public method _blob_to_session { blob} {}

  };# end of class
};# end of namespace
