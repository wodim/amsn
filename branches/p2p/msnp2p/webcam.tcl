namespace eval ::p2p::webcam {

snit::type WebcamSessionMessage {

option -id ""
option -producer ""
option -session ""
option -body ""

option -localip ""
option -localport ""
option -remoteip ""
option -remoteport ""
option -rid ""


constructor { args } {

  $self configurelist $args
  if { $options(-body) != "" } {
     $self Parse $options(-body)
  }

}

method Parse { body } {

  set body [string map { "\r\n" "" } $body]
  set options(-body) $body
  set list [xml2list $xml]
  if { $options(-producer) == 1 } {
    set type "viewer"
  } else {
    set type "producer"
  }
  set session [GetXmlEntry $list "$type:session"]
  set rid [GetXmlEntry $list "$type:rid"]
  set options(-session) $session
  set options(-rid) $rid
  #@@@ Ready to call modified ConnectSockets with ourselves as an arg!

}

method toString { } {

  set rid $options(-rid)
  if { $rid == "" } {
    set rid [myRand 100 199]
  }
  set options(-rid) $rid
  set sid $options(-id)

  set udprid [expr {$rid + 1}]
  set conntype [abook::getDemographicField conntype]
  set listening [abook::getDemographicField listening]
  set producer $options(-producer)

  set port [OpenCamPort [config::getKey initialftport] $sid]
  if { [info exists ::cam_mask_ip] } {
    set clientip $::cam_mask_ip
    set localip $::cam_mask_ip
  } else {
    set clientip [::abook::getDemographicField clientip]
    set localip [::abook::getDemographicField localip]
  }

  if { $producer } {
    set begin_type "<producer>"
    set end_type "</producer>"
  } else {
    set begin_type "<viewer>"
    set end_type "</viewer>"
  }

  set header "<version>2.0</version><rid>$rid</rid><session>$session</session><ctypes>0</ctypes><cpu>730</cpu>"
  set tcp "<tcp><tcpport>$port</tcpport>    <tcplocalport>$port</tcplocalport>  <tcpexternalport>$port</tcpexternalport><tcpipaddress1>$clientip</tcpipaddress1>"
  if { $clientip != $localip} {
    set tcp "${tcp}<tcpipaddress2>$localip</tcpipaddress2></tcp>"
  } else {
    set tcp "${tcp}</tcp>"
  }

  set udp "<udp><udplocalport>$port</udplocalport><udpexternalport>$port</udpexternalport><udpexternalip>$clientip</udpexternalip><a1_port>$port</a1_port><b1_port>$port</b1_port><b2_port>$port</b2_port><b3_port>$port</b3_port><symmetricallocation>0</symmetricallocation><symmetricallocationincrement>0</symmetricallocationincrement><udpinternalipaddress1>$localip</udpinternalipaddress1></udp>"
  set footer "<codec></codec><channelmode>1</channelmode>"

  set xml "${begin_type}${header}${tcp}${footer}${end_type}\r\n\r\n\x00"

  return $xml

}

snit::type WebcamSession {

delegate option * to p2pSession
delegate method * to p2pSession

option -producer 0

variable answered 0
variable sent_syn 0
option -session_id ""
option -session ""
variable xml_needed 1
variable message ""

constructor {args} {

  install p2pSession using P2PSession %AUTO% -application_id $::p2p::ApplicationID::WEBCAM
  $self configurelist $args
  $p2pSession conf2
  set options(-session_id) [$p2pSession cget -id]
  ::Event::registerEvent p2pTransreqReceived all [list $self On_transreq_received]

}

method invite { } {

  set answered 1
  set context "{B8BE70DE-E2CA-4400-AE03-88FF85B9F4E8}"
  set context [encoding convertto unicode $context]
  #@@@@@ TODO: WinWrite
  $p2pSession invite $context

}

method accept { } {

  set answered 1
  set temp_appid $options(-application_id)
  set options(-application_id) 0
  $p2pSession Respond 200
  set options(-application_id) $temp_appid
  $self send_binary_syn

}

method reject { } {

  set answered 1
  $p2pSession Respond 603

}

method end { } { 

  if { $answered == 0 } {
    $self reject
  } else {
    set context "\x74\x03\x00\x81"
    $self Close $context
  }
  destroy $self

}

destructor { } {

  ::Event::fireEvent p2pCallEnded p2pWebcamSession {}

}

method on_media_session_prepared { session } {

  if { $xml_needed == 1 } {
    $self Send_xml
  }

}

method On_invite_received { message } {

  #@@@@TODO: WinWrite

}

method On_transreq_received { event msg } {

  if { [[$msg body] cget -session_id] != $options(-session_id) } { return }

  #$self Switch_bridge $msg
  $p2pSession Decline_transreq $msg
  $self send_binary_syn

}

method On_bye_received { message } {

  destroy $self

}

method On_session_accepted {} {

  ::Event::fireEvent p2pCallAccepted p2pWebcamSession {}

}

method On_session_rejected { message } {

  ::Event::fireEvent p2pCallRejected p2pWebcamSession {}

}

method On_data_blob_received { blob } {

  set data [$blob cget -data]
  set data [string range $data 10 end]
  set data [encoding convertfrom unicode $data]
  set data [string trim $data "\x00"]

  if { $sent_syn == 0 } {
    #@@@@@@ TODO: really needed?
    $self send_binary_syn
  }
  if { $data == "syn" } {
    $self send_binary_ack
  } elseif { $data == "ack" && $producer == 1 } {
    $self Send_xml
  } elseif { [string first "<producer>" $data] >= 0 || [string first "<viewer>" $data] >= 0 } {
    $self Handle_xml $data
  } elseif { [string first "ReflData" $data] == 0 } {
    #@@@@@@@ send to aMSN
  } elseif { $data == "receivedViewerData" } {
    #@@@@@@@@ send to aMSN
  }

}

method send_data { data } {

  set h1 "\x80[binary format s [myRand 0 65000]]\x01\x08\x00"
  set h3 [ToUnicode "${data}\x00"]
  set h2 [binary format i [string length $syn]]
  set msg "${h1}${h2}${h3}"
  $session Send_p2p_data $msg

}

method send_binary_syn {} {

  $self send_data "syn"
  set sent_syn 1

}

method send_binary_ack {} {

  $self send_data "ack"

}

method send_binary_viewer_data {} {

  $self send_data "receivedViewerData"

}

method Send_xml {} {

  set xml_needed 0
  status_log "Sent XML for session $options(-session_id)"
  set message [WebcamSessionMessage -session $self -id $options(-session_id) -producer $producer]
  $self send_data [$message toString]

}

method Handle_xml { data } {}

  set message [WebcamSessionMessage -body $data -producer $producer]
  status_log "Received XML for session $options(-session_id)"
  if { $producer == 1 } {
    $self send_binary_viewer_data
  } else {
    $self Send_xml
  }

}

}

}
