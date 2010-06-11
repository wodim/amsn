namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPTransferResponseBody]} return
  # Source found and used class files and import class command if necessary
  source SLPMessageBody.tcl
  ## 
  ## @class	SLPTransferResponseBody
  ## 
  class SLPTransferResponseBody {
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
    ## @param string bridge
    ## 
    ## @param string listening
    ## 
    ## @param string nonce
    ## 
    ## @param string internal_ips
    ## 
    ## @param string internal_port
    ## 
    ## @param string external_ips
    ## 
    ## @param string external_port
    ## 
    ## @param string session_id
    ## 
    ## @param int channel_state
    ## 
    ## @param int capabilities_flags
    ## 
    ## 
    public method __init__ { bridge listening nonce internal_ips internal_port external_ips external_port session_id channel_state capabilities_flags} {}

    ## 
    ## @fn public method bridge
    ## @return     string
    ## 
    public method bridge {} {}

    ## 
    ## @fn public method listening
    ## @return     string
    ## 
    public method listening {} {}

    ## 
    ## @fn public method nonce
    ## @return     string
    ## 
    public method nonce {} {}

    ## 
    ## @fn public method internal_ips
    ## @return     string
    ## 
    public method internal_ips {} {}

    ## 
    ## @fn public method internal_port
    ## @return     string
    ## 
    public method internal_port {} {}

    ## 
    ## @fn public method external_ips
    ## @return     string
    ## 
    public method external_ips {} {}

    ## 
    ## @fn public method external_port
    ## @return     string
    ## 
    public method external_port {} {}

  };# end of class
};# end of namespace
