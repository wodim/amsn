namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPError]} return
  # Source found and used class files and import class command if necessary
  source Error.tcl
  ## 
  ## @class	SLPError
  ## 
  class SLPError {
    inherit ::Error
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
    ## @param string message
    ## 
    ## 
    public method __init__ { message} {}

  };# end of class
};# end of namespace
