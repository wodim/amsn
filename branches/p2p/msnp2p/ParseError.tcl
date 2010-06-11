namespace eval :: {
  # Do not load twice
  if {[namespace exist ParseError]} return
  # Source found and used class files and import class command if necessary
  source Error.tcl
  ## 
  ## @class	ParseError
  ## 
  class ParseError {
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
    ## @param string infos
    ## 
    ## 
    public method __init__ { message infos} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

  };# end of class
};# end of namespace
