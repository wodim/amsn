namespace eval :: {
  # Do not load twice
  if {[namespace exist EufGuid]} return
  ## 
  ## @class	EufGuid
  ## 
  class EufGuid {
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
    ## @var public common string MSN_OBJECT
    ## 
    public common MSN_OBJECT

    ## 
    ## @var public common string FILE_TRANSFER
    ## 
    public common FILE_TRANSFER

    ## 
    ## @var public common string MEDIA_RECEIVE_ONLY
    ## 
    public common MEDIA_RECEIVE_ONLY

    ## 
    ## @var public common string MEDIA_SESSION
    ## 
    public common MEDIA_SESSION

    ## 
    ## @var public common string SHARE_PHOTO
    ## 
    public common SHARE_PHOTO

    ## 
    ## @var public common string ACTIVITY
    ## 
    public common ACTIVITY

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
