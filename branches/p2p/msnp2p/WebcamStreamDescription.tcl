namespace eval :: {
  # Do not load twice
  if {[namespace exist WebcamStreamDescription]} return
  ## 
  ## @class	WebcamStreamDescription
  ## 
  class WebcamStreamDescription {
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
    ## @param string stream
    ## 
    ## @param string sid
    ## 
    ## @param bool producer
    ## 
    ## 
    public method __init__ { stream sid producer} {}

    ## 
    ## @fn public method candidate_encoder
    ## @return     string
    ## 
    public method candidate_encoder {} {}

    ## 
    ## @fn public method ips
    ## @return     string
    ## 
    public method ips {} {}

    ## 
    ## @fn public method ports
    ## @return     string
    ## 
    public method ports {} {}

    ## 
    ## @fn public method rid
    ## @return     string
    ## 
    public method rid {} {}

    ## 
    ## @fn public method sid
    ## @return     string
    ## 
    public method sid {} {}

  };# end of class
};# end of namespace
