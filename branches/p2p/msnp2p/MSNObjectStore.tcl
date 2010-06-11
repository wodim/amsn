namespace eval :: {
  # Do not load twice
  if {[namespace exist MSNObjectStore]} return
  ## 
  ## @class	MSNObjectStore
  ## 
  class MSNObjectStore {
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
    ## @fn public method _can_handle_message
    ## @param string message
    ## 
    ## @return     bool
    ## 
    public method _can_handle_message { message} {}

    ## 
    ## @fn public method _handle_message
    ## @param string peer
    ## 
    ## @param string message
    ## 
    ## 
    public method _handle_message { peer message} {}

    ## 
    ## @fn public method request
    ## @param string msn_object
    ## 
    ## @param string callback
    ## 
    ## @param string errback
    ## 
    ## @param string peer
    ## 
    ## 
    public method request { msn_object callback errback peer} {}

    ## 
    ## @fn public method publish
    ## @param string msn_object
    ## 
    ## 
    public method publish { msn_object} {}

    ## 
    ## @fn public method _outgoing_session_transfer_completed
    ## @param string session
    ## 
    ## @param string data
    ## 
    ## 
    public method _outgoing_session_transfer_completed { session data} {}

    ## 
    ## @fn public method _incoming_session_transfer_completed
    ## @param string session
    ## 
    ## @param string data
    ## 
    ## 
    public method _incoming_session_transfer_completed { session data} {}

  };# end of class
};# end of namespace
