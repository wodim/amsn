namespace eval :: {
  # Do not load twice
  if {[namespace exist TLPHeader_1]} return
  ## 
  ## @class	TLPHeader_1
  ## 
  class TLPHeader_1 {
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
    ## @param string header
    ## 
    ## 
    public method __init__ { header} {}

    ## 
    ## @fn public method parse
    ## @param string data
    ## 
    ## 
    public method parse { data} {}

  };# end of class
};# end of namespace
