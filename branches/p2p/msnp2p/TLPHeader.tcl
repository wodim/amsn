namespace eval :: {
  # Do not load twice
  if {[namespace exist TLPHeader]} return
  ## 
  ## @class	TLPHeader
  ## 
  class TLPHeader {
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
    ## @param string[] header
    ## 
    ## 
    public method __init__ { header} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

    ## 
    ## @fn public proc parse
    ## @param string header_data
    ## 
    ## @return     TLPHeader
    ## 
    public proc parse { header_data} {}

  };# end of class
};# end of namespace
