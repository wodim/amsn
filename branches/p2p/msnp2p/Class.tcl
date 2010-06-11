namespace eval :: {
  # Do not load twice
  if {[namespace exist Class]} return
  ## 
  ## @class	Class
  ## 
  class Class {
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
