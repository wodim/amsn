namespace eval ::p2p::transport {
  # Do not load twice
  if {[namespace exist TLPFlag_2]} return
  ## 
  ## @class	TLPFlag_2
  ## 
  class TLPFlag_2 {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
  };# end of class
};# end of namespace
