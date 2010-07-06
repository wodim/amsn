namespace eval ::p2p::transport {
  # Do not load twice
  if {[namespace exist MessageChunk]} return
  ## 
  ## @class	MessageChunk
  ## 
  class MessageChunk {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
    # Operations
    ## 
    ## @fn public proc parse
    ## @param string data
    ## 
    ## @return     MessageChunk
    ## 
    public proc parse { data} {}

    ## 
    ## @fn public method create
    ## @param string version
    ## 
    ## @param int app_id
    ## 
    ## @param string session_id
    ## 
    ## @param int blob_id
    ## 
    ## @param int offset
    ## 
    ## @param int blob_size
    ## 
    ## @param int max_size
    ## 
    ## @param string sync
    ## 
    ## 
    public method create { version app_id session_id blob_id offset blob_size max_size sync} {}

  };# end of class
};# end of namespace
