namespace eval :: {
  # Do not load twice
  if {[namespace exist WebcamCandidateEncoder]} return
  ## 
  ## @class	WebcamCandidateEncoder
  ## 
  class WebcamCandidateEncoder {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor {args} {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
    # Operations
    ## 
    ## @fn public method __init__
    ## 
    public method __init__ {} {}

    ## 
    ## @fn public method encode_candidates
    ## @param string desc
    ## 
    ## @param string local_candidates
    ## 
    ## @param string remote_candidates
    ## 
    ## 
    public method encode_candidates { desc local_candidates remote_candidates} {}

    ## 
    ## @fn public method decode_candidates
    ## @param string desc
    ## 
    ## 
    public method decode_candidates { desc} {}

  };# end of class
};# end of namespace
