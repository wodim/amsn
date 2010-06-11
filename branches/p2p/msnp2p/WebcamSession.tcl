namespace eval :: {
  # Do not load twice
  if {[namespace exist WebcamSession]} return
  # Source found and used class files and import class command if necessary
  source P2PSession.tcl
  ## 
  ## @class	WebcamSession
  ## 
  class WebcamSession {
    inherit ::P2PSession
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
    ## @param bool producer
    ## 
    ## @param string session_manager
    ## 
    ## @param string peer
    ## 
    ## @param string euf_guid
    ## 
    ## @param string message
    ## 
    ## 
    public method __init__ { producer session_manager peer euf_guid message} {}

    ## 
    ## @fn public method invite
    ## 
    public method invite {} {}

    ## 
    ## @fn public method accept
    ## 
    public method accept {} {}

    ## 
    ## @fn public method reject
    ## 
    public method reject {} {}

    ## 
    ## @fn public method end
    ## 
    public method end {} {}

    ## 
    ## @fn public method dispose
    ## 
    public method dispose {} {}

    ## 
    ## @fn public method on_media_session_prepared
    ## @param string session
    ## 
    ## 
    public method on_media_session_prepared { session} {}

    ## 
    ## @fn public method _on_invite_received
    ## @param string message
    ## 
    ## 
    public method _on_invite_received { message} {}

    ## 
    ## @fn public method _on_bye_received
    ## @param string message
    ## 
    ## 
    public method _on_bye_received { message} {}

    ## 
    ## @fn public method _on_session_accepted
    ## 
    public method _on_session_accepted {} {}

    ## 
    ## @fn public method _on_session_rejected
    ## @param string message
    ## 
    ## 
    public method _on_session_rejected { message} {}

    ## 
    ## @fn public method _on_data_blob_received
    ## @param string blob
    ## 
    ## 
    public method _on_data_blob_received { blob} {}

    ## 
    ## @fn public method send_data
    ## @param string data
    ## 
    ## 
    public method send_data { data} {}

    ## 
    ## @fn public method send_binary_syn
    ## 
    public method send_binary_syn {} {}

    ## 
    ## @fn public method send_binary_ack
    ## 
    public method send_binary_ack {} {}

    ## 
    ## @fn public method send_binary_viewer_data
    ## 
    public method send_binary_viewer_data {} {}

    ## 
    ## @fn public method _send_xml
    ## 
    public method _send_xml {} {}

    ## 
    ## @fn public method _handle_xml
    ## @param string data
    ## 
    ## 
    public method _handle_xml { data} {}

    ## 
    ## @fn public method producer
    ## @return     bool
    ## 
    public method producer {} {}

  };# end of class
};# end of namespace
