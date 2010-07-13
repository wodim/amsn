namespace eval ::p2p::transport {

snit::type DirectP2PTransport {

  delegate option * to BaseP2PTransport
  delegate method * to BaseP2PTransport

  option -name "direct"
  option -protocol "TCPv1"
  option -client ""
  option -peers ""
  option -ip ""
  option -port ""
  option -nonce ""
  option -server 0
  option -listening 0
  option -connected 0
  option -extern_port ""
  option -mapping_timeout_src ""
  option -connect_timeout_src ""

  variable pending_size ""
  variable pending_chunk ""
  variable foo_sent 0
  variable foo_received 0
  variable nonce_sent 0
  variable nonce_received 0
  variable transport

  constructor { args } {

    install BaseP2PTransport using BaseP2PTransport %AUTO%
    $self configurelist $args

    if { [$self cget -ip] == "" } {
      $self configure -ip [::abook::getDemographicField localip]
    }

    if { [$self cget -port] == "" } {
      $self configure -port [config::getKey initialftport]
    }

    if { [$self cget -nonce] == "" } {
      $self configure -nonce [::p2p::generate_uuid]
    }

    $self configure -peer [lindex $peers 0]

  }

  method open { } {

    set ip [$self configure -ip]
    set port [$self configure -port]
    $self configure -listening 0
    $self configure -server 0

    if { [catch {set transport [socket -async $ip $port]}] } {
      $self On_error
    } else {
      $self On_connected
    }

  }  

}

}
