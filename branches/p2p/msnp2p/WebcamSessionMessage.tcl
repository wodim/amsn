namespace eval :: {
  # Do not load twice
  if {[namespace exist WebcamSessionMessage]} return
  ## 
  ## @class	WebcamSessionMessage
  ## 
  class WebcamSessionMessage {
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
    ## @param string session
    ## 
    ## @param string body
    ## 
    ## @param int id
    ## 
    ## @param bool producer
    ## 
    ## 
    public method __init__ { session body id producer} {}

    ## 
    ## @fn public method id
    ## @return     string
    ## 
    public method id {} {}

    ## 
    ## @fn public method producer
    ## @return     bool
    ## 
    public method producer {} {}

    ## 
    ## @fn public method _create_stream_description
    ## @param string stream
    ## 
    ## 
    public method _create_stream_description { stream} {}

    ## 
    ## @fn public method _parse
    ## @param string body
    ## 
    ## 
    public method _parse { body} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

  };# end of class
};# end of namespace
