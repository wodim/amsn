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

  puts "Can I handle $message?"
  set euf_guid [[$message body] cget -euf_guid]
  if { $euf_guid == $::p2p::EufGuid::MSN_OBJECT } {
    return 1
  } else {
    return 0
  }

}

method Handle_message { peer guid message} {

  puts "Received message!!!"
  set session [MSNObjectSession %AUTO% -session_manager [$self cget -client] -peer $peer -guid $guid -application_id [[$message body] cget -application_id] -message $message]

  ::Event::registerEvent p2pCompleted all [list $self Incoming_session_transfer_completed]
  set incoming_sessions($session) {p2pCompleted Incoming_session_transfer_completed}
  set msnobj [MSNObject parse [$self cget -client] [$session cget -context]]
  foreach obj $published_objects {
    if {[$obj cget -shad] == [$msnobj cget -shad]} {
      $session accept [$obj cget -data]
      return $session
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
  puts "Context: $context"
  puts "Peer: $peer"
  set session [MSNObjectSession %AUTO% -session_manager [$self cget -client] -peer $peer -guid "" -application_id $application_id -context $context]
  puts "Session $session created with peer [$session cget -peer]"
  set handles [list {p2pOnSessionAnswered On_session_answered} {p2pOnSessionRejected On_session_rejected} {p2pOutgoingSessionTransferCompleted Outgoing_session_transfer_completed}]
  puts $handles
  foreach {event callback} $handles {
    ::Event::registerEvent $event all [list $self $callback]
  }
  set outgoing_sessions($session) [list $handles $callback $errback $msnobj]
  $session invite $context

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
  option -type ""
  option -location ""
  option -friendly ""
  option -shad ""
  option -shac ""
  option -data ""

constructor {args} {

  $self configurelist $args

  if { $options(-shad) == "" } {
    if { $options(-data) == "" } {
      return ""
    }
    $self configure -shad [Compute_data_hash $options(-data)]
  }

  if { $options(-shac) == "" } {
    $self configure -shac [Compute_checksum $options(-data)]
  }

}

method Set_data {data} {

  $self configure -size [string length $data]
  $self configure -data $data
  $self configure -shad [Compute_data_hash $data]
  $self configure -shac [Compute_checksum $data]

}

typemethod parse { xml_data } {

  set elements [split $xml_data " "]
  set creator [MSNObject retrieve $elements "Creator"]
  set size [MSNObject retrieve $elements "Size"]
  set type [MSNObject retrieve $elements "Type"]
  set location [encoding convertfrom utf-8 [MSNObject retrieve $elements "Location"]]
  set friendly [base64::decode [::sxml::replacexml [encoding convertfrom utf-8 [MSNObject retrieve $elements "Friendly"]]]]
  set shad ""
  set shad [MSNObject retrieve $elements "SHA1D"]
  #if { [info exists shad] && $shad != "" } {
  #  set shad [MSNObject Decode_shad $shad]
  #}
  set shac [MSNObject retrieve $elements "SHA1C"]
  if { [info exists shac] && $shac != "" } {
    set shac [base64::decode $shac]
  }

  set result [MSNObject %AUTO% -creator $creator -size $size -type $type -location $location -friendly $friendly -shad $shad -shac $shac]

  return $result

}

typemethod retrieve { elem data } {

  set idx [lsearch $elem [concat $data=*]]
  if { $idx < 0 } { return "" }
  set ret [lindex $elem $idx]
  set ret [string range $ret [expr { [string length $data]+1}] end]
  if { [string index $ret 0] == "\"" } { set ret [string range $ret 1 end] }
  if { [string index $ret end] == "\"" } { set ret [string range $ret 0 end-1] }
  return $ret

}

typemethod Decode_shad { shad } {

  set shad [base64::decode $shad]
  if { [string first " " $shad] >= 0 } {
    set parts [split $shad " "]
    set shad [Decode_shad [lindex $parts 0]]
    if { $shad == "" } {
      set shad [Decode_shad [lindex $parts 1]]
    }
  } else {
    set shad ""
  }
  return $shad

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

  set sha1d [base64::encode $sha1d]
  set friendly [base64::encode $friendly]

  return [::base64::encode [binary format H* [::sha1::sha1 "Creator${creator}Size${size}Type${type}Location${file}Friendly${friendly}SHA1D${sha1d}"]]]

}

method toString { } {

  set creator [$self cget -creator]
  set size [$self cget -size]
  set type [$self cget -type]
  set file [$self cget -location]
  set friendly [$self cget -friendly]
  set sha1d [$self cget -shad]
  set sha1c [$self cget -shac]

  set friendly [base64::encode $friendly]
  set file [encoding convertto utf-8 $file]
  set sha1c [base64::encode $sha1c]

  set msnobj "<msnobj Creator=\"$creator\" Size=\"$size\" Type=\"$type\" Location=\"$file\" Friendly=\"${friendly}\" SHA1D=\"$sha1d\" SHA1C=\"$sha1c\"/>\x00"
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
