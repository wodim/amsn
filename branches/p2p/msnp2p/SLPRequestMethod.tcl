namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPRequestMethod]} return
  ## 
  ## @class	SLPRequestMethod
  ## 
  class SLPRequestMethod {
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
    ## @var public common string INVITE
    ## 
    public common INVITE

    ## 
    ## @var public common string BYE
    ## 
    public common BYE

    ## 
    ## @var public common string ACK
    ## 
    public common ACK

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
