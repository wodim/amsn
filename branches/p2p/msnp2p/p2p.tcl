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

  MSNObjectSession session -session_manager [[$self cget -client] cget -p2p_session_manager] -peer $peer -guid $guid -application_id [[$message body] cget -application_id] -message $message

  #session.connect("completed", self._incoming_session_transfer_completed)
  set incoming_sessions($session) 1
  set msnobj [MSNObject parse [$self cget -client] [$session cget -context]]
  foreach obj $published_objects {
    if {[$obj cget -shad] == [$msnobj cget -shad]} {
      $session accept [$obj cget -data]
      return session
    }
  }
  $session reject

}

method request { msn_object callback errback peer} {}

method publish { msn_object} {}

method Outgoing_session_transfer_completed { session data} {}

method Incoming_session_transfer_completed { session data} {}

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
