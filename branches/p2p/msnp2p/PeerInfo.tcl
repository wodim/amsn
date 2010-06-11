namespace eval :: {
  # Do not load twice
  if {[namespace exist PeerInfo]} return
  ## 
  ## @class	PeerInfo
  ## 
  class PeerInfo {
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
    ## @var public common int PROTOCOL_VERSION
    ## 
    public common PROTOCOL_VERSION

    ## 
    ## @var public common int IMPLEMENTATION_ID
    ## 
    public common IMPLEMENTATION_ID

    ## 
    ## @var public common int VERSION
    ## 
    public common VERSION

    ## 
    ## @var public common int CAPABILITIES
    ## 
    public common CAPABILITIES

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
