namespace eval ::p2p {

snit::type DirectP2PTransport {

  delegate option * to BaseP2PTransport
  delegate method * to BaseP2PTransport

  option -name "direct"
  option -protocol "TCPv1"
  option -client ""
  option -peer ""
  option -ip ""
  option -port ""
  option -nonce ""
  option -server 0
  option -listening 0
  option -connected 0
  option -extern_port ""
  option -mapping_timeout_src ""
  option -connect_timeout_src ""
  option -timeout 300000
  option -rating 1

  variable pending_size ""
  variable pending_chunk ""
  variable foo_sent 0
  variable foo_received 0
  variable nonce_sent 0
  variable nonce_received 0
  variable transport
  variable sock

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
    fileevent $sock writable "$self handshake"
    fileevent $sock readable "$self On_data_received $sock"
    $self configure -sock $sock

  }  

  method listen { } {

    $self configure -server 1
    $self configure -listening 0
    set sock [$self Open_listener]
    $self configure -sock $sock
    fconfigure $sock -blocking 0

  }

  method close { } {

    if { [info exists transport] && $transport != "" } {
      $transport close
    }

    $self Remove_connect_timeout

    set trsp [$self cget -transport_manager]
    list $trsp unregister_transport $self

  }

  method Open_listener { } {

    set port [$self cget -port]
    set p10 [expr {$port + 10} ]
    set found 0
    #Sanity check - we better not keep icnreasing ports to infinity
    while { $port <= $p10 } {
      if { [catch {set sock [socket -server [list $self On_listener_connected]]}] } {
        incr port
        continue
      } else {
        set found 1
        break
      }
    }
    if { $found == 0 } {
      return -code error "Could not allocate a socket"
    }
    $self configure -port $port
    $self Set_listening
    #TODO: UPnP

  }

  method Set_listening { } {
  
    set sock [$self configure -sock]
    after [$self cget -timeout] "catch {close $sock};$self On_connect_timeout"
    #fileevent $sock readable [list $self On_data_received]
    $self configure -listening 1
    ::Event::fireEvent p2pListening p2p $ip $port

  }

  method Send_chunk { peer peer_guid chunk } {

    $self Send_data [$chunk toString] [list $self On_chunk_sent $chunk] 

  }

  method Send_data { data callback } {

    fileevent $sock writable [list puts $sock $data]
    eval $callback

  }

  method Remove_connect_timeout { } {

    set sock $options(-sock)
    after cancel "catch {close $sock};$self On_connect_timeout"

  }

  method On_connect_timeout { } {
    $self On_failed
    return 0
  }

  method On_error { } {
    $self On_failed
  }

  method On_failed { } {
    ::Event::fireEvent p2pFailed p2p {}
    $self close
  }

  method On_listener_connected { sock hostaddr hostport } {

    set ip $options(-ip)
    set port $options(-port)
    set peer $options(-peer)
    puts "$peer ($hostaddr:$hostport) connected to $ip:$port"
    fconfigure $sock -blocking 0 -buffering none -translation {binary binary}
    fileevent $sock readable [list $self On_data_received $sock]
    catch { close $options(-sock) }
    $self configure -sock $sock

  }

  method handshake { } {

    fconfigure $sock -blocking 0 -buffering none -translation {binary binary}
    $self send_foo
    $self send_nonce

  }

  method Send_foo { } {

    set foo_sent 1
    $self Send_data "foo\x00"

  }

  method Receive_foo { } {

    set foo_received 1

  }

  method Send_nonce { } {

    $self configure -nonce_sent 1
    MessageChunk chunk
    $chunk set_field blob_id [::p2p::generate_id]
    $chunk set_nonce $options(-nonce)
    $self Send_data [list $chunk toString]

  }

  method Receive_nonce { chunk } {

    if { ![$chunk is_nonce_chunk] } {
      return
    }

    set nonce [string toupper [$chunk get_nonce]]
    puts "Received nonce $nonce"
    if { [string toupper $options(-nonce)] != $nonce } {
      puts "Received log $nonce doesn't match local $options(-nonce)!"
      $self On_failed
      return
    }

    set nonce_received 1
    if { $nonce_sent != 1 } {
      $self Send_nonce
    }
    set options(-connected) 1
    ::Event::fireEvent p2pConnected p2p {}

  }

  method On_data_received { sock } {

    if { [eof $sock] } {
      $self On_failed
    }

    gets $sockid chunk
    #TODO: For p2pv2, read first 4 bytes to get size and stack all packets on pending_chunk until we've reached the size
    if { $nonce_received == 0 } {
      $self Receive_nonce $chunk
    } elseif { [$chunk body] == "\x00\x00\x00\x00" } {
      #puts "Ignoring 0000 chunk"
    } else {
      #puts "Received chunk"
      $self On_chunk_received $chunk
    }

  }

}

}
