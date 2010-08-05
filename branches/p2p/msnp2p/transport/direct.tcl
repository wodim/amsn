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
  option -sock ""

  variable pending_size ""
  variable pending_chunk ""
  variable foo_sent 0
  variable foo_received 0
  variable nonce_sent 0
  variable nonce_received 0
  variable transport
  variable data_queue {}
  variable buffer ""
  variable bsize 0

  constructor { args } {

    install BaseP2PTransport using BaseP2PTransport %AUTO% -transport $self
    $self configurelist $args
    $BaseP2PTransport conf2

    if { [$self cget -ip] == "" } {
      $self configure -ip [::abook::getDemographicField localip]
    }

    if { [$self cget -port] == "" } {
      $self configure -port [config::getKey initialftport]
    }

    if { [$self cget -nonce] == "" } {
      $self configure -nonce [::p2p::generate_uuid]
    }

    #$self configure -peer [lindex $peers 0]

  }

  method open { } {

    set ip [$self cget -ip]
    set port [$self cget -port]
    status_log "Trying to connect to $ip $port"
    $self configure -listening 0
    $self configure -server 0

    if { [catch {set sock [socket -async $ip $port]} res] } {
      $self On_error
      status_log "Error!!!!!!!! $res"
      return 0
    }
    status_log "Connected: using $sock"
    fconfigure $sock -blocking 0 -translation {binary binary} -buffering none
    catch {fileevent $sock writable "$self handshake"}
    catch {fileevent $sock readable "$self On_data_received $sock"}
    $self configure -sock $sock

  }  

  method listen { } {

    $self configure -server 1
    $self configure -listening 0
    set sock [$self Open_listener]
    $self configure -sock $sock
    fconfigure $sock -blocking 0 -translation {binary binary}

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

    $self Send_data [$chunk toString] ""
    #@@@@@@@@ Cannot find out how to access blob here, so not calling event thatwill help FTProgress

  }

  method Write_raw_data { sock } {

    if { [eof $sock] } { 
      fileevent $sock readable ""
      fileevent $sock writable ""
      return
    }
    set data [lindex $data_queue 0]
    puts -nonewline $sock [binary format i [string length $data]]$data
    set data_queue [lreplace $data_queue 0 0]
    fileevent $sock writable ""
    if { [llength $data_queue] > 0 } {
      fileevent $sock writable [list $self Write_raw_data $sock ]
    }

  }

  method Send_data { data callback } {

    set sock $options(-sock)
    if { [eof $sock] } { 
      fileevent $sock readable ""
      fileevent $sock writable ""
      return
    }
    set data_queue [lappend data_queue $data]
    fileevent $sock writable [list $self Write_raw_data $sock ]
    if { $callback != "" } { eval $callback }

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
    status_log "$peer ($hostaddr:$hostport) connected to $ip:$port"
    fconfigure $sock -blocking 0 -buffering none -translation {binary binary}
    fileevent $sock readable [list $self On_data_received $sock]
    catch { close $options(-sock) }
    $self configure -sock $sock

  }

  method handshake { } {

    set sock $options(-sock)
    fconfigure $sock -blocking 0 -buffering none -translation {binary binary}
    $self Send_foo
    $self Send_nonce

  }

  method Send_foo { } {

    set foo_sent 1
    $self Send_data "foo\x00" ""

  }

  method Receive_foo { } {

    set foo_received 1

  }

  method Send_nonce { } {

    set nonce_sent 1
    #@@@@@@@@@@@@@ p2pv2
    set module 1
    set chunk [::p2pv${module}::MessageChunk %AUTO%]
    $chunk set_field blob_id [::p2p::generate_id]
    $chunk set_nonce $options(-nonce)
    $self Send_data [$chunk toString] ""

  }

  method Receive_nonce { chunk } {

    if { ![$chunk is_nonce_chunk] } {
      return
    }

    set nonce [string toupper [$chunk get_nonce]]
    set nonce \{$nonce\}
    status_log "Received nonce $nonce"
    if { [string toupper $options(-nonce)] != $nonce } {
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
      fileevent $sock readable ""
      $self On_failed
      #close $sock
      return
    }

    #set size $bsize
    #set data $buffer
    set size ""
    set data ""
    set tmpsize 0
    #if { $size == "" || $size == 0 } {
      set size ""
      while { $tmpsize < 4 && ![eof $sock] } {
        update idletasks
        set tmpdata [read $sock [expr {4 - $tmpsize}]]
        append size $tmpdata
        set tmpsize [string length $size]
      }
  
      if {$size == "" && [eof $sock] } {
        status_log "FT Socket $sock closed\n"
        close $sock
        return
      }
  
      if { $size == "" } {
        update idletasks
        return
      }
  
      binary scan $size i size
  
      set bsize $size
      set data ""
  
   #}

    #We get the data
    set tmpsize [string length $data]

    while { $tmpsize < $size } {
      set tmpdata [read $sock [expr {$size - $tmpsize}]]
      append data $tmpdata
      set tmpsize [string length $data]
    }
 
    if {$tmpsize >= $size } {
      #Data is complete we remove it from the buffer
      status_log "Received data of [string length $data] bytes"
      if { $tmpsize > $size } {
        set data [string range $data 0 [expr {$tmpsize - 1}]
        set buffer [string range $data $tmpsize end]
        puts "Kept buffer: $buffer"
      }

      if { $data == "" } {
        update idletasks
        return
      }
    
   
      #@@@@@@@@@@ p2pv2
      set module 1
      set chunk [MessageChunk parse $module $data]
      
      if { $nonce_received == 0 } {
        $self Receive_nonce $chunk
      } elseif { [$chunk cget -body] == "\x00\x00\x00\x00" } {
        status_log "Ignoring 0000 chunk"
      } else {
        $self On_chunk_received $options(-peer) "" $chunk
      }
      set size 0
      set buffer ""
    }

  }

}

}
