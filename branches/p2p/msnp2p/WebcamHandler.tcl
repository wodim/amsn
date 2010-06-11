namespace eval :: {
  # Do not load twice
  if {[namespace exist WebcamHandler]} return
  ## 
  ## @class	WebcamHandler
  ## 
  class WebcamHandler {
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
    ## @param string client
    ## 
    ## 
    public method __init__ { client} {}

    ## 
    ## @fn public method _can_handle_message
    ## @param string message
    ## 
    ## 
    public method _can_handle_message { message} {}

    ## 
    ## @fn public method _handle_message
    ## @param string peer
    ## 
    ## @param string message
    ## 
    ## 
    public method _handle_message { peer message} {}

    ## 
    ## @fn public method invite
    ## @param string peer
    ## 
    ## @param bool producer
    ## 
    ## 
    public method invite { peer producer} {}

    # 
    # private variable attributes
    # 
    ## 
    ## @var private variable string __gsignals__
    ## 
    private variable __gsignals__

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
