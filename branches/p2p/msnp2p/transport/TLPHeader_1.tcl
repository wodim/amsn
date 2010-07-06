namespace eval ::p2p::transport {
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
    constructor { header} {}

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

    ## 
    ## @fn public method parse
    ## @param string data
    ## 
    ## 
    public method parse { data} {}

  };# end of class
};# end of namespace
