namespace eval :: {
  # Do not load twice
  if {[namespace exist ControlBlob]} return
  ## 
  ## @class	ControlBlob
  ## 
  class ControlBlob {
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
    ## @param int session_id
    ## 
    ## @param int flags
    ## 
    ## @param int dw1
    ## 
    ## @param int dw2
    ## 
    ## @param int qw1
    ## 
    ## 
    public method __init__ { session_id flags dw1 dw2 qw1} {}

    ## 
    ## @fn public method __repr__
    ## @return     string
    ## 
    public method __repr__ {} {}

    ## 
    ## @fn public method get_chunk
    ## @param int max_size
    ## 
    ## @return     string
    ## 
    public method get_chunk { max_size} {}

    ## 
    ## @fn public method is_control_blob
    ## @return     bool
    ## 
    public method is_control_blob {} {}

  };# end of class
};# end of namespace
