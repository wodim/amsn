namespace eval :: {
  # Do not load twice
  if {[namespace exist string_]} return
  ## 
  ## @class	string_
  ## 
  class string_ {
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
