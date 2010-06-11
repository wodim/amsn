namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPStatus]} return
  ## 
  ## @class	SLPStatus
  ## 
  class SLPStatus {
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
    ## @var public common int ACCEPTED
    ## 
    public common ACCEPTED

    ## 
    ## @var public common int ERROR
    ## 
    public common ERROR

    ## 
    ## @var public common int DECLINED
    ## 
    public common DECLINED

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
