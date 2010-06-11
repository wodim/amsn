namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPTransferRequestBody]} return
  # Source found and used class files and import class command if necessary
  source SLPMessageBody.tcl
  ## 
  ## @class	SLPTransferRequestBody
  ## 
  class SLPTransferRequestBody {
    inherit ::SLPMessageBody
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
    ## @param string session_id
    ## 
    ## @param string s_channel_state
    ## 
    ## @param int capabilities_flags
    ## 
    ## 
    public method __init__ { session_id s_channel_state capabilities_flags} {}

  };# end of class
};# end of namespace
