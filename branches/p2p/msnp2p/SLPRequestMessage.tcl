namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPRequestMessage]} return
  # Source found and used class files and import class command if necessary
  source SLPMessage.tcl
  ## 
  ## @class	SLPRequestMessage
  ## 
  class SLPRequestMessage {
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
    # 
    # public variable attributes
    # 
    ## 
    ## @var public variable string to
    ## 
    public variable to

    ## 
    ## @var public variable string method
    ## 
    public variable method

    ## 
    ## @var public variable string resource
    ## 
    public variable resource

    # Operations
    ## 
    ## @fn public method __init__
    ## @param string method
    ## 
    ## @param string resource
    ## 
    ## 
    public method __init__ { method resource} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
