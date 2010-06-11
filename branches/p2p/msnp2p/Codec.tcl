namespace eval :: {
  # Do not load twice
  if {[namespace exist Codec]} return
  ## 
  ## @class	Codec
  ## 
  class Codec {
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
    # public common attributes
    # 
    ## 
    ## @var public common string ML20
    ## 
    public common ML20

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
