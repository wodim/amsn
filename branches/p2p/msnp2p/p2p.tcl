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

  status_log "Can I handle $message with body [$message body]?"
  set euf_guid [[$message body] cget -euf_guid]
  if { $euf_guid == $::p2p::EufGuid::MSN_OBJECT } {
    return 1
  } else {
    return 0
  }

}

method Handle_message { peer guid message} {

  status_log "Received message of type [$message info type]!!!"
  set session [MSNObjectSession %AUTO% -session_manager [$self cget -client] -peer $peer -guid $guid -application_id [$message cget -application_id] -message $message -context [[$message body] cget -context]]
  $session conf2

  ::Event::registerEvent p2pIncomingCompleted all [list $self Incoming_session_transfer_completed]
  set incoming_sessions($session) {p2pIncomingCompleted Incoming_session_transfer_completed}
  set msnobj [MSNObject parse [$session cget -context]]
  foreach obj $published_objects {
    if {[$obj cget -shad] == [$msnobj cget -shad]} {
      $session accept [$obj cget -data]
      status_log "Returning session $session!!!!!!"
      return $session
    }
  }
  $session reject
  status_log "No such object, rejecting"
  return $session

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
  status_log "Context: $context"
  status_log "Peer: $peer"
  set session [MSNObjectSession %AUTO% -session_manager [$self cget -client] -peer $peer -guid "" -application_id $application_id -context $context]
  $session conf2
  status_log "Session $session created with peer [$session cget -peer]"
  set handles [list p2pOnSessionAnswered On_session_answered p2pOnSessionRejected On_session_rejected p2pOutgoingSessionTransferCompleted Outgoing_session_transfer_completed]
  foreach {event callb} $handles {
    ::Event::registerEvent $event all [list $self $callb]
  }
  set outgoing_sessions([$session p2p_session]) [list $handles $callback $errback $msnobj]
  $session invite $context

}

method publish { msnobj } {

  if { [$msnobj cget -data] != "" } {
    if { [lsearch $published_objects $msnobj] >= 0 } { return }
    set published_objects [lappend $published_objects $msnobj]
  }

}

method Outgoing_session_transfer_completed { event session data} {

  status_log "Outgoing session transfer completed!!!!!!!"
  set lst $outgoing_sessions($session)
  set handles [lindex $lst 0]
  set callback [lindex $lst 1]
  set errback [lindex $lst 2]
  set msnobj [lindex $lst 3]
  status_log "Callback is $callback"

  foreach {event callb} $handles {
    ::Event::unregisterEvent $event all [list $self $callb]
  }

  $msnobj configure -data $data

  set method_name [lindex $callback 0]
  set args [lreplace $callback 0 0]
  eval $method_name $msnobj $args

  array unset outgoing_sessions $session

}

method Incoming_session_transfer_completed { event session data } {

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
      ::Event::unregisterEvent $event all [list $self $callback]
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
    ::Event::unregisterEvent $event all [list $self $callback]
  }
  if { [info exists [lindex $errback 0]] } {
    eval [lindex $errback 0] $msnobj [lindex $errback 1]
  }
  array unset outgoing_sessions $session

}

}
snit::type WebcamHandler {
constructor {args} {}

method Can_handle_message { message} {}

#method Handle_message { peer message} {}

method Invite { peer producer} {}

option -gsignals session-created
}

}
