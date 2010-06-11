namespace eval :: {
  # Do not load twice
  if {[namespace exist SLPMessageBody]} return
  ## 
  ## @class	SLPMessageBody
  ## 
  class SLPMessageBody {
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
    ## @var public variable string content_type
    ## 
    public variable content_type

    # Operations
    ## 
    ## @fn public method __init__
    ## @param string content_type
    ## 
    ## @param string session_id
    ## 
    ## @param int s_channel_state
    ## 
    ## @param int capabilities_flags
    ## 
    ## 
    public method __init__ { content_type session_id s_channel_state capabilities_flags} {}

    ## 
    ## @fn public method session_id
    ## @return     int
    ## 
    public method session_id {} {}

    ## 
    ## @fn public method s_channel_state
    ## @return     string
    ## 
    public method s_channel_state {} {}

    ## 
    ## @fn public method capabilities_flags
    ## @return     int
    ## 
    public method capabilities_flags {} {}

    ## 
    ## @fn public method parse
    ## @param string data
    ## 
    ## 
    public method parse { data} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

    ## 
    ## @fn public proc register_content
    ## @param string content_type
    ## 
    ## @param string cls
    ## 
    ## 
    public proc register_content { content_type cls} {}

    ## 
    ## @fn public proc build
    ## @param string content_type
    ## 
    ## @param string content
    ## 
    ## 
    public proc build { content_type content} {}

    ## @method private initAttributes
    ## Initialize all internal variables
    private method initAttributes {}
  };# end of class
};# end of namespace
