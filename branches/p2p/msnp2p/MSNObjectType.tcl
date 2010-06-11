namespace eval :: {
  # Do not load twice
  if {[namespace exist MSNObjectType]} return
  ## 
  ## @class	MSNObjectType
  ## 
  class MSNObjectType {
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
    ## @var public common int CUSTOM_EMOTICON
    ## 
    public common CUSTOM_EMOTICON

    ## 
    ## @var public common int DISPLAY_PICTURE
    ## 
    public common DISPLAY_PICTURE

    ## 
    ## @var public common int BACKGROUND_PICTURE
    ## 
    public common BACKGROUND_PICTURE

    ## 
    ## @var public common int DYNAMIC_DISPLAY_PICTURE
    ## 
    public common DYNAMIC_DISPLAY_PICTURE

    ## 
    ## @var public common int WINK
    ## 
    public common WINK

    ## 
    ## @var public common int VOICE_CLIP
    ## 
    public common VOICE_CLIP

    ## 
    ## @var public common int SAVED_STATE_PROPERTY
    ## 
    public common SAVED_STATE_PROPERTY

    ## 
    ## @var public common int LOCATION
    ## 
    public common LOCATION

    # Operations
    ## 
    ## @fn public method __decode__shad
    ## @param string shad
    ## 
    ## @param bool warning
    ## 
    ## @return     string
    ## 
    public method __decode__shad { shad warning} {}

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
