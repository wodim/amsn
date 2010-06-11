namespace eval :: {
  # Do not load twice
  if {[namespace exist MessageChunk_2]} return
  ## 
  ## @class	MessageChunk_2
  ## 
  class MessageChunk_2 {
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
