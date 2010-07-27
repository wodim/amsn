namespace eval ::p2p {

package require snit

::snit::type SLPMessage {

option -to ""
option -frm ""
option -branch ""
option -cseq 0
option -call_id ""
option -max_forwards 0

variable headers -array {}
variable headernames {}
variable body

constructor { args } {

  $self configurelist $args

}

method conf2 { } {

  puts "From $options(-frm) to $options(-to)"
  $self add_header To [join [list "<msnmsgr:" $options(-to) ">"] ""]
  $self add_header From [join [list "<msnmsgr:" $options(-frm) ">"] ""]
  if { $options(-branch) != "" } {
    $self add_header Via [join [list "MSNSLP/1.0/TLP ;branch={" $options(-branch) "}"] ""]
  }
  $self add_header CSeq $options(-cseq)
  if { $options(-call_id) != "" } {
    $self add_header Call-ID [join [list "{" $options(-call_id) "}"] ""]
  }
  $self add_header Max-Forwards $options(-max_forwards)

  set body [SLPNullBody %AUTO%]
  $self add_header Content-Type [$body cget -content_type]
  $self add_header Content-Length [expr [string length $body]]
  
}

method add_header { key value } {
  set headers($key) $value
  if { [lsearch $headernames $key] < 0 } {
    set headernames [lappend headernames $key]
  }

}

method setBody { data } {
  set body $data
  $self add_header Content-Type [$body cget -content_type]
  $self add_header Content-Length [string length $body]
}

method headers { } {
  return [array get headers]
}

method setHeader { key val } {

  $self add_header $key $val

}

method is_SLP { } {
  return 1
}

method body { } {
  return $body
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
        $self add_header [lindex $name_value 0] [lindex $name_value 1]
      }
    }
  }

  if { [lsearch [array names headers] "Content-Type"] >= 0 } {
    set content_type $headers(Content-Type)
  } else {
    set content_type ""
  }
  setBody [SLPMessageBody build $content_type $raw_body]
}

method toString { } {

  set str ""
  set newl \r\n
  #content-length
  foreach key $headernames {
    puts "Processing header $key"
    set value $headers($key)
    set str [join [list $str $key ": " $value $newl] ""] ;#concat strips newlines
  }
  set bodyStr [$body toString]
  set str [join [list $str $newl $bodyStr] ""]
  return $str

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
    lreplace $content $i $i $line
    incr i
  }

  if { [string trim [lindex $start_line 0]] == "MSNSLP/1.0" } {
    set status [string trim [lindex $start_line 1]]
    set reason [string trim [lindex $start_line 2]]
    set slp_message [SLPResponseMessage %AUTO% -status $status -reason $reason]
  } else {
    set method [string trim [lindex $start_line 0]]
    set resource [string trim [lindex $start_line 1]]
    set slp_message [SLPRequestMessage %AUTO% -method $method -resource $resource]
    $slp_message conf2
  }
  $slp_message parse $content
}
}

::snit::type SLPRequestMessage {
delegate option * to SLPMessage
delegate method * to SLPMessage

#option -to ""
option -resource ""
option -method ""

constructor { args } {
  install SLPMessage using SLPMessage %AUTO%
  $self configurelist $args
}

method conf2 { } {
  $SLPMessage conf2
  set colon [string first ":" $options(-resource)]
  if {  [SLPMessage cget -to] == "" } {
    $SLPMessage configure -to [string range $options(-resource) 0 [expr {$colon - 1}]]
  }
}

method toString { } {

  set msg [$SLPMessage toString]
  set start_line [concat $options(-method) $options(-resource) MSNSLP/1.0]
  return [join [list $start_line \r\n $msg] ""]

}

}

::snit::type SLPResponseMessage {
delegate option * to SLPMessage
delegate method * to SLPMessage

typevariable STATUS_MESSAGE { {200 OK} {404 "Not Found"} {500 "Internal Error"} {603 Decline} {606 Unacceptable}}
option -status ""
option -reason ""

constructor { args } {

  install SLPMessage using SLPMessage %AUTO%
  $self configurelist $args
  $SLPMessage conf2

}

method toString { } {

  set msg [$SLPMessage toString]
  if { $options(-reason) == "" } {
    foreach stat $STATUS_MESSAGE { if { [lindex $stat 1] == $options(-status) } { set reason [lindex $status 0] } }
  } else {
    set reason $options(-reason)
  }

  set start_line [concat MSNSLP/1.0 $options(-status) $reason
  return [join [list $start_line \r\n $msg] ""]

}

}

::snit::type SLPMessageBody {

option -content_type ""
variable content_classes ""
variable headers -array {}
variable headernames {}
variable body ""
option -euf_guid ""
option -session_id ""
option -s_channel_state ""
option -capabilities_flags ""

constructor { args } {
  $self configurelist $args
}

method conf2 { } {
  if { $options(-euf_guid) != "" } {
    $self setHeader EUF-GUID [join [list "{" $options(-euf_guid) "}"] ""]
  }
  if { $options(-session_id) != "" } {
    $self setHeader SessionID $options(-session_id)
  }
  if { $options(-s_channel_state) != "" } {
    $self setHeader SChannelState $options(-s_channel_state)
  }
  if { $options(-capabilities_flags) != "" } {
    $self setHeader Capabilities-Flags $options(-capabilities_flags)
  }
}

method headers { } {
  return [array get headers]
}

method body { } {
  return $body
}

method setBody { newBody } {
  set body $newBody
}

method setHeaders { headers } {
  $self configure -headers $headers
}

method setHeader { key val } {
  set headers($key) $val
  puts "Processing header $key"
  if { [lsearch $headernames $key] < 0 } {
    set headernames [lappend headernames $key]
  }
  puts "New headers: $headernames"

}

method toString { } {

  set str ""
  set newl \r\n
  #content-length
  foreach key $headernames {
    set value $headers($key)
    set str [join [list $str $key ": " $value $newl] ""] ;#concat strips newlines
  }
  set str [join [list $str $newl $body \x00] ""]
  return $str

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
        $self addHeader [lindex $name_value 0] [lindex $name_value 1]
      }
    }
  }
}

typemethod build {content_type content} {
  if { [array names content_classes -exact $content_type] == "" } {
    set returnme [SLPMessageBody %AUTO% -content_type $content_type]
    $returnme conf2
    return $returnme
  } else {
    set cls $content_classes($content_type)
    return [$cls %AUTO%]
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
  $SLPMessageBody conf2
  
  SLPMessageBody register_content $::p2p::SLPContentType::NULL SLPNullBody
}
}

snit::type SLPSessionRequestBody {

delegate option * to SLPMessageBody
delegate method * to SLPMessageBody

option -app_id ""
option -context ""

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -session_id 0 -s_channel_state 0 -capabilities_flags 1 -content_type $::p2p::SLPContentType::SESSION_REQUEST
  $self configurelist $args
}

method conf2 { } {
  $SLPMessageBody conf2
  set euf_guid [$self cget -euf_guid]
  set app_id [$self cget -app_id]
  set context [$self cget -context]

  set headers {}
  if { $app_id != "" } {
    $SLPMessageBody setHeader AppID $app_id
  }
  if { $context != 1 } {
    $SLPMessageBody setHeader Context [base64::encode $context]
  }

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
  option -bridges {}
  option -conn_type "Unknown-Connect"
  option -upnp 0
  option -firewall 0

  variable headers -array {}

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -content_type $::p2p::SLPContentType::TRANSFER_REQUEST 
  $self configurelist $args
  $SLPMessageBody conf2
  $SLPMessageBody setHeader NetID -1388627126
  $SLPMessageBody setHeader Bridges "TCPv1 SBBridge"
  $SLPMessageBody setHeader Conn-Type "Port-Restrict-NAT"
  $SLPMessageBody setHeader TCP-Conn-Type "Symmetric-NAT"
  $SLPMessageBody setHeader UPnPNat "false"
  $SLPMessageBody setHeader ICF "false"
  $SLPMessageBody setHeader Nonce "[format %X [myRand 4369 65450]][format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]]-[format %X [myRand 4369 65450]][format %X [myRand 4369 65450]][format %X [myRand 4369 65450]]"
  $SLPMessageBody setHeader Nat-Trav-Msg-Type "WLX-Nat-Trav-Msg-Direct-Connect-Req"
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
  option -s_channel_state ""
  option -capabilities_flags ""
  option -conn_type "Port-Restrict-NAT"

  variable headers -array {}

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -content_type $::p2p::SLPContentType::TRANSFER_RESPONSE

  $self configurelist $args

  $SLPMessageBody conf2

  if { $options($bridge) != "" } {
    $SLPMessageBody setHeader Bridge $options($bridge)
  }
  if { $options($listening) == 1 } {
    $SLPMessageBody setHeader Listening "true"
  } elseif { $options($listening) == 0} {
    $SLPMessageBody setHeader Listening "false"
  }
  if { $options($nonce) != "" } {
    $SLPMessageBody setHeader Nonce [string toupper $options($nonce)]
  }
  if { $options($internal_ips) != "" } {
    $SLPMessageBody setHeader IPv4Internal-Addrs $options($internal_ips)
  }
  if { $options($internal_port) != "" } {
    $SLPMessageBody setHeader IPv4Internal-Port $options($internal_port)
  }
  if { $options($external_ips) != "" } {
    $SLPMessageBody setHeader IPv4External-Addrs $options($external_ips)
  }
  if { $options($external_port) != "" } {
    $SLPMessageBody setHeader IPv4External-Port $options($external_port)
  }

  $SLPMessageBody setHeader Nat-Trav-Msg-Type "WLX-Nat-Trav-Msg-Direct-Connect-Req"
  $SLPMessageBody setHeader Conn-Type $options(-conn_type)
  $SLPMessageBody setHeader TCP-Conn-Type "Symmetric-NAT"
  $SLPMessageBody setHeader IPv6-global ""

}
}

snit::type SLPSessionCloseBody {

delegate method * to SLPMessageBody
delegate option * to SLPMessageBody

option -context ""
variable headers -array {}

constructor { args } {
  install SLPMessageBody using SLPMessageBody %AUTO% -content_type $::p2p::SLPContentType::SESSION_CLOSE
  $self configurelist $args
  $SLPMessageBody conf2

  if { $context != "" } {
    set headers(Context) [base64::encode $context]
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
  $SLPMessageBody conf2
}
}
#::p2p::SLPRequestMessage msg1 -frm sender@hotmail.com -to receiver@hotmail.com
}
