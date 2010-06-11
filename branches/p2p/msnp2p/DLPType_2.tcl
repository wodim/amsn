namespace eval :: {
  # Do not load twice
  if {[namespace exist DLPType_2]} return
  ## 
  ## @class	DLPType_2
  ## 
  class DLPType_2 {
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
