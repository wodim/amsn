namespace eval ::p2p::transport {

  snit::type SwitchboardP2PTransport {

    delegate option * to BaseP2PTransport
    delegate method * to BaseP2PTransport

    option -name "switchboard"
    option -protocol "SBBridge"

    constructor { args } {

      install BaseP2PTransport using BaseP2PTransport %AUTO%
      $self configurelist $args

    }

    method close {} {

      BaseP2PTransport close $self
      ::MSN::CloseSB [::MSN::SBFor $peer]

    }

    typemethod Can_handle_message { message switchboard_client} {

      #could we have several content types?
      return [expr { [string first "application/x-msnmsgrp2p" [$message cget -content_type] >= 0} ]

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
      foreach key [array names headers] {
        set value $headers($key)
        if { $key == "P2P-Dest" && [string first ";" $key] >= 0 } {
          set version 2
          set semic [string first ";" $value]
          set dest_guid [string range $value [expr {$semic+1}] end]
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
      ::MSN::CloseSB [::MSN::SBFor $contact]
    }

    typemethod handle_peer { client transport_manager peer peer_guid } {
      return [SwitchboardP2PTransport trsp -client $client -peer $peer -peer_guid $peer_guid -transport_manager $transport_manager -contacts $client -switchboard ""]
    }

    typemethod handle_message { client switchboard message transport_manager} {

      array set headers [$message cget -headers]
      set guid ""
      set peer ""
      foreach key [array names headers] {
        set value $headers($key)
        if { $key == "P2P-Src"} {
          if { [lsearch $value ";"] > 0 } {
            set semic [string first ";" $value]
            set peer [string range $value 0 [expr {$semic - 1}]] ;#If that is our own address, check who is in the switchboard
            set guid [string range $value [expr {$semic + 1}] end]]
          } else {
            set peer $value
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
