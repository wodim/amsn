namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPSessionCloseBody]} return
  # Source found and used class files and import class command if necessary
  source SLPMessageBody.tcl
  ## 
  ## @class	SLPSessionCloseBody
  ## 
  class SLPSessionCloseBody {
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
    ## @param string context
    ## 
    ## @param string session_id
    ## 
    ## @param int s_channel_state
    ## 
    ## @param int capabilities_flags
    ## 
    ## 
    public method __init__ { context session_id s_channel_state capabilities_flags} {}

    ## 
    ## @fn public method context
    ## @return     string
    ## 
    public method context {} {}

  };# end of class
};# end of namespace
