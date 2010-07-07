namespace eval ::p2p::transport {

  snit::type SwitchboardP2PTransport {

    delegate option * to BaseP2PTransport
    delegate method * to BaseP2PTransport

    constructor { client contacts transport_manager} {}

    method close {} {}

    typemethod _can_handle_message { message switchboard_client} {}

    method peer {} {}

    method rating {} {}

    method max_chunk_size {} {}

    method Send_chunk { chunk peer peer_guid} {}

    method On_message_received { message} {}

    method On_contact_joined { contact} {}

    method On_contact_left { contact} {}

    typemethod handle_peer { client peer peer_guid transport_manager} {}

    typemethod handle_message { client switchboard message transport_manager} {}

    method peer_guid {} {}

    method can_send { peer peer_guid blob bootstrap} {}

  }

}
