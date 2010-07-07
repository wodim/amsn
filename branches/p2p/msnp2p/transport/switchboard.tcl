namespace eval ::p2p::transport {

  snit::type SwitchboardP2PTransport {

    delegate option * to BaseP2PTransport
    delegate method * to BaseP2PTransport

    constructor { args } {

      install BaseP2PTransport using BaseP2PTransport %AUTO%
      $self configurelist $args

    }

    method close {} {

      BaseP2PTransport close $self
      #@@@@@@ Actually close switchboard

    }

    typemethod Can_handle_message { message switchboard_client} {

      #could we have several content types?
      return [expr { [$message cget -content_type] == "application/x-msnmsgrp2p" } ]

    }

    method rating {} {
      return 0
    }

    method max_chunk_size {} {
      return 1250
    }

    method Send_chunk { peer peer_guid chunk } {

      if { [$self version] == 1 } {
        set headers(P2P-Dest) $peer
      } else {
        set headers(P2P-Src) [concat [::abook::getPersonal login]\;[::config::getGlobalKey machineguid]]
        set headers(P2P-Src) [concat $peer\;$peer_guid]
      }  
      set content_type "application/x-msnmsgrp2p"
      binary scan [$chunk cget -application_id] iu appid
      set body $chunk$appid
      set head [$headers toString]
      set data $head$body
      ::MSN::WriteSBNoNL $peer $data
    }

    method On_message_received { message} {

      set version 1
      set headers [$message headers]
      foreach type [array names $headers] {
        set msg $headers($type)
        if { $type == "P2P-Dest" && [string first ";" $type] >= 0 } {
          set version 2
          set semic [string first ";" $msg]
          set dest_guid [string range $msg [expr {$semic+1}] end]
          if { $dest_guid != [::config::getGlobalKey machineguid] } {
            #this chunk is for our other self
            return
          }
        }
        set chunk [MessageChunk parse $version [string range [$message body] 0 end-4]]
        binary scan [string range [$message body] end-4 end] iu appid
        $message configure -application_id $appid
        $self On_chunk_received $options(-peer) $options(-peer_guid) $chunk
      }

    }

    method On_contact_joined { contact} {
      #Do nothing?
    }

    method On_contact_left { contact} {
      #@@@@@@@@@@@@@Close SB: needed?
    }

    typemethod handle_peer { client transport_manager peer peer_guid } {
      return [SwitchboardP2PTransport trsp -client $client -peer $peer -peer_guid $peer_guid -transport_manager $transport_manager -contacts $client -switchboard ""]
    }

    typemethod handle_message { client switchboard message transport_manager} {

      set guid ""
      set peer ""
      foreach type [array names $headers] {
        set msg $headers($type)
        if { $type == "P2P-Src"} {
          if { [lsearch $msg ";"] > 0 } {
            set semic [string first ";" $msg] ;#Or is there no chance we'll get a second semicolon in there?
            set peer [string range $msg 0 [expr {$semic - 1}]] ;#Or should we make sure the peer is actually in the SB?
            # Strip { } 's : not needed?
            set guid [string range $msg [expr {$semic + 1}] end]]
          } else {
            set peer $msg
          }
        } 
      }
      return [SwitchboardP2PTransport trsp -client $client -switchboard $switchboard -peer $peer -guid $guid -transport_manager $transport_manager]

    }

    method peer_guid {} {}

    method can_send { peer peer_guid blob bootstrap} {
      return [expr { $options(-peer)==$peer && $options(-peer_guid)==peer_guid } ]
    }

  }

}
