namespace eval :: {
  # Do not load twice
  if {[namespace exist DLPParamType_2]} return
  ## 
  ## @class	DLPParamType_2
  ## 
  class DLPParamType_2 {
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
