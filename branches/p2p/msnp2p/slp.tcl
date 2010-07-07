namespace eval ::p2p {

package require snit

source constants.tcl

::snit::type SLPMessage {

option -to ""
option -frm ""
option -branch ""
option -cseq 0
option -call_id ""
option -max_forwards 0

variable headers
variable body

constructor { args } {
  $self configurelist $args
  set headers ""
  lappend $headers "To" [join [list "<msnmsgr:" $options(-to) ">"] ""]
  lappend $headers "From" [join [list "<msnmsgr:" $options(-frm) ">"] ""]
  if { $options(-branch) != "" } {
    lappend $headers "Via" [join [list "MSNSLP/1.0/TLP ;branch=" $options(-branch)] ""]
  }
  lappend $headers "CSeq" $options(-cseq)
  if { $options(-call_id) != "" } {
    lappend $headers "Call-ID" $options(-call_id)
  }
  lappend $headers "Max-Forwards" $options(-max_forwards)

  set body [SLPNullBody nullbody]
}

method parse { chunk } {
  variable found 0

  set lines [split $chunk "\n"]
  foreach line $lines {
    set line [trim $line]
    if { $found == 1 } {
      set raw_body [join [list $body $line] "\r\n"]
    } else {
      if { $line == "" } {
         set found 1
      } else {
        set name_value [split $line ":"]
        lappend headers [lindex $name_value 0] [lindex $name_value 1]
      }
    }
  }

  set content_type ""
  foreach {type msg} $headers {
    if { $type == "Content-Type"} {
      set content_type $msg
      break
    }
  }

  set body [SLPMessageBody $build $content_type $raw_body]
}



typemethod build {raw_message} {

  if { [string first "MSNSLP/1.0" $raw_message] < 0 } {
    return -code error {"Message doesn't seem to be an MSNSLP/1.0 message"}
  }
  set content [split $raw_message "\n"]
  set start_line [lindex $content 0]
  set content [lreplace $content 0 0]

  set start_line [split [string trim $start_line] " "]
  set i 0
  foreach line $content {
    set line [string trim $line]
    lreplace $content i i $line
    incr i
  }

  if { [string trim [lindex $start_line 0]] == "MSNSLP/1.0" } {
    set status [string trim [lindex $start_line 1]]
    set reason [string trim [lindex $start_line 2]]
    SLPResponseMessage slp_message $status $reason
  } else {
    set method [string trim [lindex $start_line 0]]
    set resource [string trim [lindex $start_line 1]]
    SLPRequestMessage slp_message $method $resource
  }
  slp_message parse $content
}
}

::snit::type SLPRequestMessage {
delegate option * to SLPMessage
delegate method * to SLPMessage

option -to ""

constructor { args } {
  $self configurelist $args
  set colon [string first ":" $options(-resource)]
  if {  $options(-to) != "" } {
    $self configure -to [string range $options(-resource) 0 [expr {$colon - 1}]]
  }
}
}

::snit::type SLPResponseMessage {
delegate option * to SLPMessage
delegate method * to SLPMessage

typevariable STATUS_MESSAGE { {200 OK} {404 "Not Found"} {500 "Internal Error"} {603 "Decline"} {606 "Unacceptable"}}
option -status
option -reason

}

::snit::type SLPMessageBody {

option -content_type ""
variable content_classes ""
option -headers ""
option -body ""
option -session_id ""
option -s_channel_state ""
option -capabilities_flags ""

constructor { args } {
  $self configurelist $args
  set headers ""
  if { $options(-session_id) != "" } {
    lappend $headers "SessionID" $options(-session_id)
  }
  if { $options(-s_channel_state) != "" } {
    lappend $headers "SChannelState" $options(-s_channel_state)
  }
  if { $options(-capabilities_flags) != "" } {
    lappend $headers "Capabilities-Flags" $options(-capabilities_flags)
  }
  $self configure -headers $headers
}

method parse { data } {
  variable found 0

  set headers [$self cget -headers]
  if { [string length $data] == 0 } {
    return
  }
  set data [string strip $data "\x00"]
  set lines [split $data "\n"]
  foreach line $lines {
    set line [trim $line]
    if { $found == 0 } {
      if { $line == "" } {
         set found 1
      } else {
        set name_value [split $line ":"]
        lappend headers [lindex $name_value 0] [lindex $name_value 1]
      }
    }
  }
  $self configure -headers $headers
}

typemethod build {content_type content} {
  if { [array names content_classes -exact $content_type] == "" } {
    SLPMessageBody msgbody -content_type $content_type
  } else {
    set cls $content_classes($content_type)
    $cls %AUTO%
  }
}

typemethod register_content { content_type cls } {
  set content_classes($content_type) $cls
} 
}

snit::type SLPNullBody {

delegate option * to SLPMessageBody
delegate method * to SLPMessageBody

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -content_type $::p2p::SLPContentType::NULL
  
  SLPMessageBody register_content $::p2p::SLPContentType::NULL SLPNullBody
}
}

snit::type SLPSessionRequestBody {

delegate option * to SLPMessageBody
delegate method * to SLPMessageBody

option -euf_guid ""
option -app_id ""
option -context ""
option -session_id ""
option -s_channel_state 0
option -capabilities_flags 1

constructor { args } {
  $self configurelist $args
  set euf_guid [$self cget -euf_guid]
  set app_id [$self cget -app_id]
  set context [$self cget -context]

  set headers {}
  if { $euf_guid != "" } {
    lappend $headers "EUF-GUID" $euf_guid
  }
  if { $app_id != "" } {
    lappend $headers "AppID" $app_id
  }
  if { $capabilities_flags != 1 } {
    lappend $headers "Context" [base64::encode $context]
  }

  $self configure -headers $headers
}

typeconstructor {
  SLPMessageBody register_content $::p2p::SLPContentType::SESSION_REQUEST SLPSessionRequestBody
}
}

snit::type SLPTransferRequestBody {

  delegate option * to SLPMessageBody
  delegate method * to SLPMessageBody

  option -session_id ""
  option -s_channel_state ""
  option -capabilities_flags ""

  variable headers

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -content_type $::p2p::SLPContentType::TRANSFER_REQUEST 
  $self configurelist $args
  lappend $headers "NetID" -1388627126
  lappend $headers "Bridges" "TCPv1 SBBridge"
  lappend $headers "Conn-Type" "Port-Restrict-NAT"
  lappend $headers "TCP-Conn-Type" "Symmetric-NAT"
  lappend $headers "UPnPNat" "false"
  lappend $headers "ICF" "false"
  lappend $headers "Nonce" "[format %X [myRand 4369 65450]][format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]][format %X [myRand 4369 65450]][format %X [myRand 4369 65450]]"
  lappend $headers "Nat-Trav-Msg-Type" "WLX-Nat-Trav-Msg-Direct-Connect-Req"
}
}

snit::type SLPTransferResponseBody {
  delegate option * to SLPMessageBody
  delegate method * to SLPMessageBody

  option -bridge ""
  option -listening ""
  option -nonce ""
  option -internal_ips ""
  option -internal_port ""
  option -external_ips ""
  option -external_port ""
  option -session_id ""
  option -channel_state ""
  option -capabilities_flags ""

  variable headers

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -content_type $::p2p::SLPContentType::TRANSFER_RESPONSE

  $self configurelist $args

  if { $options($bridge) != "" } {
    lappend $headers "Bridge" $options($bridge)
  }
  if { $options($listening) == 1 } {
    lappend $headers "Listening" "true"
  } elseif { $options($listening) == 0} {
    lappend $headers "Listening" "false"
  }
  if { $options($nonce) != "" } {
    lappend $headers "Nonce" [string toupper $options($nonce)]
  }
  if { $options($internal_ips) != "" } {
    lappend $headers "IPv4Internal-Addrs" $options($internal_ips)
  }
  if { $options($internal_port) != "" } {
    lappend $headers "IPv4Internal-Port" $options($internal_port)
  }
  if { $options($external_ips) != "" } {
    lappend $headers "IPv4External-Addrs" $options($external_ips)
  }
  if { $options($external_port) != "" } {
    lappend $headers "IPv4External-Port" $options($external_port)
  }

  lappend $headers "Nat-Trav-Msg-Type" "WLX-Nat-Trav-Msg-Direct-Connect-Req"
  lappend $headers "Conn-Type" "Port-Restrict-NAT"
  lappend $headers "TCP-Conn-Type" "Symmetric-NAT"
  lappend $headers "IPv6-global" ""

}
}

snit::type SLPSessionCloseBody {

delegate method * to SLPMessageBody
delegate option * to SLPMessageBody

option -context ""
variable headers

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -content_type $::p2p::SLPContentType::SESSION_CLOSE
  $self configurelist $args

  if { $context != "" } {
    lappend $headers "Context" [base64::encode $context]
  }

}

typeconstructor {
  SLPMessageBody register_content $::p2p::SLPContentType::SESSION_CLOSE SLPSessionCloseBody
}

}

snit::type SLPSessionFailureResponseBody {

delegate method * to SLPMessageBody
delegate option * to SLPMessageBody

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO%
}
}
::p2p::SLPMessage msg1 -frm sender@hotmail.com -to receiver@hotmail.com
}
