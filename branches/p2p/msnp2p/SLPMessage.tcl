namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPMessage]} return
  ## 
  ## @class	SLPMessage
  ## 
  class SLPMessage {
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
    ## @param string to
    ## 
    ## @param string frm
    ## 
    ## @param string branch
    ## 
    ## @param int cseq
    ## 
    ## @param string call_id
    ## 
    ## @param int max_forwards
    ## 
    ## 
    public method __init__ { to frm branch cseq call_id max_forwards} {}

    ## 
    ## @fn public method to
    ## @return     string
    ## 
    public method to {} {}

    ## 
    ## @fn public method frm
    ## @return     string
    ## 
    public method frm {} {}

    ## 
    ## @fn public method branch
    ## @return     string
    ## 
    public method branch {} {}

    ## 
    ## @fn public method cseq
    ## @return     int
    ## 
    public method cseq {} {}

    ## 
    ## @fn public method call_id
    ## @return     string
    ## 
    public method call_id {} {}

    ## 
    ## @fn public method parse
    ## @param string chunk
    ## 
    ## @return     string
    ## 
    public method parse { chunk} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

    ## 
    ## @fn public proc build
    ## @param string raw_message
    ## 
    ## @return     SLPMessage
    ## 
    public proc build { raw_message} {}

  };# end of class
};# end of namespace
