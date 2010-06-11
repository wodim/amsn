namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPSessionRequestBody]} return
  # Source found and used class files and import class command if necessary
  source SLPMessageBody.tcl
  ## 
  ## @class	SLPSessionRequestBody
  ## 
  class SLPSessionRequestBody {
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
    ## @param string euf_guid
    ## 
    ## @param string app_id
    ## 
    ## @param string context
    ## 
    ## @param string session_id
    ## 
    ## @param int s_channel_state
    ## 
    ## @param int capabilities_flags
    ## 
    ## 
    public method __init__ { euf_guid app_id context session_id s_channel_state capabilities_flags} {}

    ## 
    ## @fn public method euf_guid
    ## @return     string
    ## 
    public method euf_guid {} {}

    ## 
    ## @fn public method context
    ## @return     string
    ## 
    public method context {} {}

    ## 
    ## @fn public method string
    ## 
    public method string {} {}

  };# end of class
};# end of namespace
