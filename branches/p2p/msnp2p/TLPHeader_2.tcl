namespace eval :: {
  # Do not load twice
  if {[namespace exist TLPHeader_2]} return
  ## 
  ## @class	TLPHeader_2
  ## 
  class TLPHeader_2 {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor {args} {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
  };# end of class
};# end of namespace
