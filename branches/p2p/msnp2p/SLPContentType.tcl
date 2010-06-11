namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPContentType]} return
  ## 
  ## @class	SLPContentType
  ## 
  class SLPContentType {
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
    ## @var public common string SESSION_REQUEST
    ## 
    public common SESSION_REQUEST

    ## 
    ## @var public common string SESSION_FAILURE
    ## 
    public common SESSION_FAILURE

    ## 
    ## @var public common string SESSION_CLOSE
    ## 
    public common SESSION_CLOSE

    ## 
    ## @var public common string TRANSFER_REQUEST
    ## 
    public common TRANSFER_REQUEST

    ## 
    ## @var public common string TRANSFER_RESPONSE
    ## 
    public common TRANSFER_RESPONSE

    ## 
    ## @var public common string TRANS_UDP_SWITCH
    ## 
    public common TRANS_UDP_SWITCH

    ## 
    ## @var public common string NULL
    ## 
    public common NULL

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
