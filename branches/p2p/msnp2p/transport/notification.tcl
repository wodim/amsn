namespace eval ::p2p::transport {

  snit::type NotificationP2PTransport {

    constructor { client transport_manager} {}

    method close {} {}

    method rating {} {}

    method max_chunk_size {} {}

    method can_send { peer peer_guid blob bootstrap} {}

    method send { peer peer_guid blob} {}

    method On_notification_received { protocol peer peer_guid type data} {}

    method on_notification_sent { data} {}
  };

}
