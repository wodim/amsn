namespace eval ::p2p::transport {
  # Do not load twice
  if {[namespace exist TLPFlag_1]} return
  ## 
  ## @class	TLPFlag_1
  ## 
  class TLPFlag_1 {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
    # 
    # public common attributes
    # 
    ## 
    ## @var public common int NAK
    ## 
    public common NAK

    ## 
    ## @var public common int ACK
    ## 
    public common ACK

    ## 
    ## @var public common int RAK
    ## 
    public common RAK

    ## 
    ## @var public common int RST
    ## 
    public common RST

    ## 
    ## @var public common int FILE
    ## 
    public common FILE

    ## 
    ## @var public common int EACH
    ## 
    public common EACH

    ## 
    ## @var public common int CAN
    ## 
    public common CAN

    ## 
    ## @var public common int ERR
    ## 
    public common ERR

    ## 
    ## @var public common int KEY
    ## 
    public common KEY

    ## 
    ## @var public common int CRYPT
    ## 
    public common CRYPT

    ## 
    ## @var public common int UNKNOWN
    ## 
    public common UNKNOWN

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
