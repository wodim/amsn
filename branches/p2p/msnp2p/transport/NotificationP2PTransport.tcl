namespace eval ::p2p::transport {
  # Do not load twice
  if {[namespace exist NotificationP2PTransport]} return
  ## 
  ## @class	NotificationP2PTransport
  ## 
  class NotificationP2PTransport {
    ## 
    ## @func constructor
    ## @par args contain all configuration parameters
    ## 
    constructor { client transport_manager} {}

    ## 
    ## @func destructor
    ## 
    destructor {} {}
    # Operations
    ## 
    ## @fn public method __init__
    ## @param string client
    ## 
    ## @param string transport_manager
    ## 
    ## 

    ## 
    ## @fn public method close
    ## 
    public method close {} {}

    ## 
    ## @fn public method rating
    ## @return     int
    ## 
    public method rating {} {}

    ## 
    ## @fn public method max_chunk_size
    ## @return     string
    ## 
    public method max_chunk_size {} {}

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

    ## 
    ## @fn public method send
    ## @param string peer
    ## 
    ## @param string peer_guid
    ## 
    ## @param string blob
    ## 
    ## 
    public method send { peer peer_guid blob} {}

    ## 
    ## @fn public method _on_notification_received
    ## @param int protocol
    ## 
    ## @param string peer
    ## 
    ## @param string peer_guid
    ## 
    ## @param string type
    ## 
    ## @param string data
    ## 
    ## 
    public method _on_notification_received { protocol peer peer_guid type data} {}

    ## 
    ## @fn public method on_notification_sent
    ## @param string data
    ## 
    ## 
    public method on_notification_sent { data} {}

  };# end of class
};# end of namespace
