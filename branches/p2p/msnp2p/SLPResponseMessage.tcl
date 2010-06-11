namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPResponseMessage]} return
  # Source found and used class files and import class command if necessary
  source SLPMessage.tcl
  ## 
  ## @class	SLPResponseMessage
  ## 
  class SLPResponseMessage {
    inherit ::SLPMessage
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
