namespace eval ::p2p {

snit::type MSNObjectStore {

  option -client ""
  variable outgoing_sessions -array {}
  variable incoming_sessions -array {}
  variable published_objects {}

constructor {args} {

  $self configurelist $args

}

method Can_handle_message { message} {

  set euf_guid [[$message body] cget -euf_guid]
  if { $euf_guid == $::p2p::EufGuid::MSN_OBJECT } {
    return 1
  } else {
    return 0
  }

}

method Handle_message { peer guid message} {

  set session [MSNObjectSession create %AUTO%]
  MSNObjectSession $session -session_manager [[$self cget -client] cget -p2p_session_manager] -peer $peer -guid $guid -application_id [[$message body] cget -application_id] -message $message

  ::Event::registerEvent p2pCompleted all [list $self Incoming_session_transfer_completed]
  set incoming_sessions($session) {p2pCompleted Incoming_session_transfer_completed}
  set msnobj [MSNObject parse [$self cget -client] [$session cget -context]]
  foreach obj $published_objects {
    if {[$obj cget -shad] == [$msnobj cget -shad]} {
      $session accept [$obj cget -data]
      return session
    }
  }
  $session reject

}

method request { msnobj callback {errback ""} {peer ""}} {

  if { [$msnobj cget -data] != "" } {
    eval [lindex $callback 0] $msnobj [lindex $callback 1]
  }

  if { $peer == "" } {
    set peer [$msnobj cget -creator]
  }

  if { [$msnobj cget -type] == $::p2p::MSNObjectType::CUSTOM_EMOTICON } {
    set application_id $::p2p::ApplicationID::CUSTOM_EMOTICON_TRANSFER
  } elseif { [$msnobj cget -type] == $::p2p::MSNObjectType::DISPLAY_PICTURE } {
    set application_id $::p2p::ApplicationID::DISPLAY_PICTURE_TRANSFER
#  } elseif { [$msnobj cget -type] == $::p2p::MSNObjectType::WINK } {
#    set application_id $::p2p::ApplicationID::WINK_TRANSFER
#  } elseif { [$msnobj cget -type] == $::p2p::MSNObjectType::VOICE_CLIP } {
#    set application_id $::p2p::ApplicationID::VOICE_CLIP_TRANSFER
  } else {
    return ""
  }

  # TODO: p2pv2:  send a request to all end points of the peer and cancel the other sessions when one of them answers
  set context [$msnobj toString]
  MSNObjectSession session -session_manager [[$self cget -client] cget -p2p_session_manager] -peer $peer -guid "" -application_id $application_id -context $context
  set handles [list {p2pOnSessionAnswered On_session_answered} {p2pOnSessionRejected On_session_rejected{ {p2pOutgoingSessionTransferCompleted Outgoing_session_transfer_completed}]
  foreach {event callback} $handles {
    ::Event::registerEvent $event all [list $self $handle]
  }
  set outgoing_sessions($session) [list $handles $callback $errback $msnobj]
  $session invite

}

method publish { msnobj } {

  if { [$msnobj cget -data] != "" } {
    lappend $published_objects $msnobj
  }

}

method Outgoing_session_transfer_completed { session data} {

  set lst $outgoing_sessions($session)
  set handles [lindex $lst 0]
  set callback [lindex $lst 1]
  set errback [lindex $lst 2]
  set msnobj [lindex $lst 3]

  foreach {event callback} $handles {
    ::Events::unregisterEvent $event all [list $self $callback]
  }

  $msnobj configure -data $data

  eval [lindex $callback 0] $msnobj [lindex $callback 1]

  array unset outgoing_sessions $session

}

method Incoming_session_transfer_completed { session data } {

  set {event callback} $incoming_sessions($session)
  ::Event::unregisterEvent $event all [list $self $callback]
  array unset incoming_sessions $session

}

method On_session_answered { answered_session } {

  foreach session [array names outgoing_sessions] {
    if { $session == $answered_session } { continue }
    if { [$session cget -peer] != [$answered_session cget -peer] } { continue }
    if { [$session cget -context] != [$answered_session cget -context] } { continue }
    set lst $outgoing_sessions($session)
    set handles [lindex $lst 0]
    set callback [lindex $lst 1]
    set errback [lindex $lst 2]
    set msnobj [lindex $lst 3]
    foreach {event callback} $handles {
      ::Events::unregisterEvent $event all [list $self $callback]
    }
    $session cancel
    array unset outgoing_sessions $session
    
  }

}

method On_session_rejected { session } {

  $self On_session_answered $session

  set lst $outgoing_sessions($session)
  set handles [lindex $lst 0]
  set callback [lindex $lst 1]
  set errback [lindex $lst 2]
  set msnobj [lindex $lst 3]
  foreach {event callback} $handles {
    ::Events::unregisterEvent $event all [list $self $callback]
  }
  if { [info exists [lindex $errback 0]] } {
    eval [lindex $errback 0] $msnobj [lindex $errback 1]
  }
  array unset outgoing_sessions $session

}

}

snit::type MSNObject {

  option -creator ""
  option -size 0
  option -typ ""
  option -location ""
  option -friendly ""
  option -shad ""
  option -shac ""
  option -data ""

constructor {args} {

  $self configurelist $args

  if { $shad == "" } {
    if { $data == "" } {
      return ""
    }
    $self configure -shad [Compute_data_hash $data]
  }

  if { $shac == "" } {
    $self configure -shac [Compute_checksum $data]
  }

}

method Set_data {data} {

  $self configure -size [string length $data]
  $self configure -data $data
  $self configure -shac [Compute_checksum $data]

}

typemethod parse { client xml_data } {

  set elements [split $xml_data " "]
  set creator [$self retrieve $elements "Creator"]
  set size [$self retrieve $elements "Size"]
  set type [$self retrieve $elements "Type"]
  set location [::sxml::replacexml [encoding convertfrom utf-8 [$self retrieve $elements "Location"]]]
  set friendly [base64::decode [::sxml::replacexml [encoding convertfrom utf-8 [$self retrieve $elements "Friendly"]]]]
  set shad [$self retrieve $elements "SHA1D"]
  if { [$shad] != "" } {
    set shad [Decode_shad [$shad]]
  }
  set shac [$self retrieve $elements "SHA1C"]
  if { [$shac] != "" } {
    set shac [base64::decode $shac]
  }

  MSNObject result -creator $creator -size $size -type $type -location $location -friendly $friendly -shad $shad -shac $shac

  return $result

}

typemethod retrieve { elem data } {

  set idx [lsearch $elem [concat $data=*]
  if { $idx < 0 } { return "" }
  set ret [lindex $elem $idx]
  set ret [string range $ret [expr { [string length $data]+1}] end]
  return $ret

}

method Compute_data_hash { data} {

  return [::base64::encode [binary format H* [::sha1::sha1 $data]]]

}

method Compute_checksum {} {

  set creator [$self cget -creator]
  set size [$self cget -size]
  set type [$self cget -type]
  set file [$self cget -location]
  set friendly [$self cget -friendly]
  set sha1d [$self cget -shad]

  return [::base64::encode [binary format H* [::sha1::sha1 "Creator${creator}Size${size}Type${type}Location${file}.tmpFriendly${friendly}SHA1D${sha1d}"]]]

}

method toString { } {

  set creator [$self cget -creator]
  set size [$self cget -size]
  set type [$self cget -type]
  set file [$self cget -location]
  set friendly [$self cget -friendly]
  set sha1d [$self cget -shad]
  set sha1c [$self cget -shac]

  set msnobj "<msnobj Creator=\"$Creator\" Size=\"$size\" Type=\"$type\" Location=\"[urlencode $file].tmp\" Friendly=\"${friendly}\" SHA1D=\"$sha1d\" SHA1C=\"$sha1c\"/>"
  return $msnobj

}

}

snit::type WebcamHandler {
constructor {args} {}

method Can_handle_message { message} {}

method Handle_message { peer message} {}

method Invite { peer producer} {}

option -gsignals session-created
}

}
