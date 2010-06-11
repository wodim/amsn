namespace eval :: {
  # Do not load twice
  if {[namespace exist SwitchboardP2PTransport]} return
  # Source found and used class files and import class command if necessary
  source BaseP2PTransport.tcl
  ## 
  ## @class	SwitchboardP2PTransport
  ## 
  class SwitchboardP2PTransport {
    inherit ::BaseP2PTransport
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
    ## @param Class client
    ## 
    ## @param Class contacts
    ## 
    ## @param P2PTransportManager transport_manager
    ## 
    ## 
    public method __init__ { client contacts transport_manager} {}

    ## 
    ## @fn public method close
    ## 
    public method close {} {}

    ## 
    ## @fn public proc _can_handle_message
    ## @param string message
    ## 
    ## @param Class switchboard_client
    ## 
    ## @return     string
    ## 
    public proc _can_handle_message { message switchboard_client} {}

    ## 
    ## @fn public method peer
    ## @return     string
    ## 
    public method peer {} {}

    ## 
    ## @fn public method rating
    ## @return     int
    ## 
    public method rating {} {}

    ## 
    ## @fn public method max_chunk_size
    ## @return     int
    ## 
    public method max_chunk_size {} {}

    ## 
    ## @fn public method _send_chunk
    ## @param string chunk
    ## 
    ## @param string peer
    ## 
    ## @param string peer_guid
    ## 
    ## 
    public method _send_chunk { chunk peer peer_guid} {}

    ## 
    ## @fn public method _on_message_received
    ## @param string message
    ## 
    ## 
    public method _on_message_received { message} {}

    ## 
    ## @fn public method _on_contact_joined
    ## @param string contact
    ## 
    ## 
    public method _on_contact_joined { contact} {}

    ## 
    ## @fn public method _on_contact_left
    ## @param string contact
    ## 
    ## 
    public method _on_contact_left { contact} {}

    ## 
    ## @fn public proc handle_peer
    ## @param string client
    ## 
    ## @param string peer
    ## 
    ## @param string peer_guid
    ## 
    ## @param string transport_manager
    ## 
    ## 
    public proc handle_peer { client peer peer_guid transport_manager} {}

    ## 
    ## @fn public proc handle_message
    ## @param string client
    ## 
    ## @param string switchboard
    ## 
    ## @param string message
    ## 
    ## @param string transport_manager
    ## 
    ## 
    public proc handle_message { client switchboard message transport_manager} {}

    ## 
    ## @fn public method peer_guid
    ## @return     string
    ## 
    public method peer_guid {} {}

    ## 
    ## @fn public method can_send
    ## @param string peer
    ## 
    ## @param string peer_guid
    ## 
    ## @param string blob
    ## 
    ## @param bool bootstrap
    ## 
    ## 
    public method can_send { peer peer_guid blob bootstrap} {}

  };# end of class
};# end of namespace
