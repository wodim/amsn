namespace eval :: {
  # Do not load twice
  if {[namespace exist Error]} return
  ## 
  ## @class	Error
  ## 
  class Error {
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
    ## @param int code
    ## 
    ## @param string message
    ## 
    ## 
    public method __init__ { code message} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

  };# end of class
};# end of namespace
