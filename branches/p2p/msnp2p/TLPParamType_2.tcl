namespace eval :: {
  # Do not load twice
  if {[namespace exist TLPParamType_2]} return
  ## 
  ## @class	TLPParamType_2
  ## 
  class TLPParamType_2 {
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
