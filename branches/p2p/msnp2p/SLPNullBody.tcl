namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPNullBody]} return
  # Source found and used class files and import class command if necessary
  source SLPMessageBody.tcl
  ## 
  ## @class	SLPNullBody
  ## 
  class SLPNullBody {
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
    ## 
    public method __init__ {} {}

  };# end of class
};# end of namespace
