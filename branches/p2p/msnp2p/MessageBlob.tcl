namespace eval :: {
  # Do not load twice
  if {[namespace exist MessageBlob]} return
  ## 
  ## @class	MessageBlob
  ## 
  class MessageBlob {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor {args} {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
    # Operations
    ## 
    ## @fn public method __init__
    ## @param string application_id
    ## 
    ## @param string data
    ## 
    ## @param int total_size
    ## 
    ## @param int session_id
    ## 
    ## @param int blob_id
    ## 
    ## @param bool is_file
    ## 
    ## 
    public method __init__ { application_id data total_size session_id blob_id is_file} {}

    ## 
    ## @fn public method __del__
    ## 
    public method __del__ {} {}

    ## 
    ## @fn public method __str__
    ## @return     string
    ## 
    public method __str__ {} {}

    ## 
    ## @fn public method __repr__
    ## @return     string
    ## 
    public method __repr__ {} {}

    ## 
    ## @fn public method transferred
    ## @return     int
    ## 
    public method transferred {} {}

    ## 
    ## @fn public method is_complete
    ## @return     bool
    ## 
    public method is_complete {} {}

    ## 
    ## @fn public method is_data_blob
    ## @return     bool
    ## 
    public method is_data_blob {} {}

    ## 
    ## @fn public method is_control_blob
    ## @return     bool
    ## 
    public method is_control_blob {} {}

    ## 
    ## @fn public method read_data
    ## @return     string
    ## 
    public method read_data {} {}

    ## 
    ## @fn public method get_chunk
    ## @param max_size int
    ## 
    ## @return     string
    ## 
    public method get_chunk { int} {}

    ## 
    ## @fn public method append_chunk
    ## @param string chunk
    ## 
    ## 
    public method append_chunk { chunk} {}

  };# end of class
};# end of namespace
