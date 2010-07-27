namespace eval ::p2p {

snit::type MSNObjectSession {

  delegate method * to P2PSession
  delegate option * to P2PSession

  option -guid ""
  option -context ""

  variable data ""

  constructor { args } {

    install P2PSession using P2PSession %AUTO% -euf_guid $::p2p::EufGuid::MSN_OBJECT
    $self configurelist $args

    $P2PSession conf2
    set msg [$P2PSession cget -message]
    if { $msg != "" } {
      set options(-application_id) [[$msg body] cget -application_id]
      set options(-context) [string trim [[$msg body] cget -context] \x00 ]
    }

  }

  method data { } {

    return $data

  }

  method setData { newData } {

    set data $newData

  }

  method accept { data_file } {
    set data $data_file
    $self Respond "200"
    $self Request_bridge
  }

  method reject { } {
    $self Respond "603"
  }

  #method invite { context } {
  #  $self Invite $context
  #  return 0
  #}

  method send { } {
    $self Send_p2p_data "\x00\x00\x00\x00"
    $self Send_p2p_data $data
  }

  method On_bridge_selected { } {
    if { $data != "" } {
      $self send
    }
  }

}

}
