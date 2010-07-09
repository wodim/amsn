namespace eval ::p2p {

snit::type MSNObjectSession {

  delegate option * to P2PSession
  delegate method * to P2PSession

  option -session_manager ""
  option -peer ""
  option -application_id ""
  option -message ""

  variable data ""
  variable context ""

  constructor { args } {

    install P2PSession using P2PSession %AUTO% -application_id $::p2p::EugGuid::MSN_OBJECT

    if { $options(-message) != "" } {
      set options(-application_id) [[$message body] cget -application_id]
      set context [string trim [[$message body] cget -context] \x00 ]
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

  method invite { context } {
    $self Invite $context
    return 0
  }

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
