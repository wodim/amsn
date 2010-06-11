namespace eval :: {
  # Do not load twice
  if {[namespace exist MSNObject]} return
  ## 
  ## @class	MSNObject
  ## 
  class MSNObject {
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
    ## @param bool creator
    ## 
    ## @param int size
    ## 
    ## @param int typ
    ## 
    ## @param string location
    ## 
    ## @param string friendly
    ## 
    ## @param string shad
    ## 
    ## @param string shac
    ## 
    ## @param string data
    ## 
    ## 
    public method __init__ { creator size typ location friendly shad shac data} {}

    ## 
    ## @fn public method __ne__
    ## @param string other
    ## 
    ## @return     bool
    ## 
    public method __ne__ { other} {}

    ## 
    ## @fn public method __eq__
    ## @param string other
    ## 
    ## @return     bool
    ## 
    public method __eq__ { other} {}

    ## 
    ## @fn public method __hash__
    ## @return     string
    ## 
    public method __hash__ {} {}

    ## 
    ## @fn public method __set_data
    ## @param string data
    ## 
    ## 
    public method __set_data { data} {}

    ## 
    ## @fn public proc parse
    ## @param string client
    ## 
    ## @param string xml_data
    ## 
    ## 
    public proc parse { client xml_data} {}

    ## 
    ## @fn public method __compute_data_hash
    ## @param string data
    ## 
    ## @return     string
    ## 
    public method __compute_data_hash { data} {}

    ## 
    ## @fn public method __compute_checksum
    ## @return     string
    ## 
    public method __compute_checksum {} {}

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

  };# end of class
};# end of namespace
