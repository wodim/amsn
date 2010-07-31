namespace eval ::p2p {

snit::type FileTransferSession {

delegate option * to p2pSession
delegate method * to p2pSession

option -filename ""
option -size 0
option -has_preview 0
option -preview ""
option -data ""
option -localpath ""
#TODO: write intermediate files

variable handlers {}

constructor { args } {

  install p2pSession using P2PSession %AUTO% {*}$args -euf_guid $::p2p::EufGuid::FILE_TRANSFER -partof $self
  $p2pSession conf2
  $self configurelist $args
  set options(-localpath) [::config::getKey receiveddir]
  
  set message [$p2pSession cget -message]
  if { $message != "" } {

    $self parse_context [base64::decode [[$message body] cget -context]]

  }
  
  set handlers { p2pBridgeSelected On_bridge_selected p2pOutgoingSessionTransferCompleted On_transfer_completed p2pChunkReceived2 On_chunk_received }

  foreach { event callback } $handlers {
    ::Event::registerEvent $event all [list $self $callback]
  }

}

method invite { filename size } {

  set options(-filename) $filename
  set options(-size) $size
  set options(-context) [$self build_context]
  $self invite $context

}

method saveAs { } {

  set filename [tk_getSaveFile -initialfile $options(-localpath) -initialdir $options(-filename)]

  set origfile $filename
  set incompl "incomplete"

  set num 1
  while { [file exists $filename] || [file exists $filename.$incompl] } {
    set filename "[filenoext $origfile] $num[fileext $origfile]"
    #set filename "$origfile.$num"
    incr num
  }
  set options(-localpath) $filename

  $self Respond "200"

}

method accept { } {

  $self configure -localpath [file join $options(-localpath) $options(-filename)]
  set filename $options(-localpath)
  set origfile $filename
  set incompl "incomplete"

  set num 1
  while { [file exists $filename] || [file exists $filename.$incompl] } {
    set filename "[filenoext $origfile] $num[fileext $origfile]"
    #set filename "$origfile.$num"
    incr num
  }
  set options(-localpath) $filename

  ::amsn::FTProgress a $self $options(-localpath) ;#TODO: direct connection
  $self Respond "200"

}

method reject { } {

  foreach {event callback} $handlers {
    ::Event::unregisterEvent $event all [list $self $callback]
  }
  $self Respond "603"

}

method cancel { } {

  foreach {event callback} $handlers {
    ::Event::unregisterEvent $event all [list $self $callback]
  }
  $self Close [$self cget -context] ""
  ::amsn::FTProgress ca $self $options(-localpath)

}

method send { data } {

  set options(-data) $data
  $self Request_bridge

}

method build_context { } {

  global HOME

  set ext [string tolower [string range [fileext $filename] 1 end]
  if { $ext == "jpg" || $ext == "gif" || $ext == "png" || $ext == "bmp" || $ext == "jpeg" || $ext == "tga" } {
    set haspreview 1
  } else {
    set haspreview 0
  }

  #if {[::config::getKey noftpreview]} {
    set haspreview 0
  #}
  $self configure -has_preview $haspreview

  set context "[binary format i 574][binary format i 2][binary format i $options(-size)][binary format i 0][binary format i $nopreview]"

  set file [ToUnicode [getfilename $options(-filename)]]
  set file [binary format a550 $file]
  set context "${context}${file}\xFF\xFF\xFF\xFF"

  return $context

  #@@@@@@@ TODO: preview

}

method getFilenameFromContext { context } {

  set fname [FromUnicode [string range $context 20 569]]

  set idx [string first "\x00" $fname]
  if {$idx != -1 } {
    set fname [string range $fname 0 [expr {$idx - 1}]]
  }

  return $fname

}

method getPreviewFromContext { context } {

  global HOME
  binary scan [string range $context 16 19] i noprev

  if { $noprev == 1 } { return 0 }

  binary scan [string range $context 0 3] i size
  set previewdata [string range $context $size end]
  set dir [file join $HOME FT cache]
  create_dir $dir
  set sid [$self cget -id]
  set fd [open "[file join $dir ${sid}.png ]" "w"]
  fconfigure $fd -translation binary
  puts -nonewline $fd "$previewdata"
  close $fd
  set file [file join $dir ${sid}.png]
  if { $file != "" && ![catch {set img [image create photo [TmpImgName] -file $file]} res]} {
    ::skin::setPixmap FT_preview_${sid} "[file join $dir ${sid}.png]"
      #set options(-haspreview) 1
      #TODO: read file
  }
  catch {image delete $img}
  return 1

}

method parse_context { context } {

  global HOME

  binary scan [string range $context 8 11] i filesize
  binary scan [string range $context 16 19] i nopreview

  set filename [$self getFilenameFromContext $context]
  $self configure -filename $filename
  $self configure -has_preview [$self getPreviewFromContext $context]
  $self configure -size $filesize

  set idx [string first "\x00" $filename]
  if {$idx != -1 } {
    set filename [string range $filename 0 [expr {$idx - 1}]]
  }  

}

method On_bridge_selected { event session } {

  if { $session != $p2pSession } { return }

  ::Event::unregisterEvent p2pBridgeSelected all [list $self On_bridge_selected]

  if { options(-data) != "" } {

    $self Send_p2p_data \x00\x00\x00\x00
    $self Send_p2p_data $options(-data) 1

  }

}

method On_chunk_received { event session chunk blob } {

  if { $session != $p2pSession && $session != $self } { return }

  if { [$blob cget -current_size] < [$blob cget -blob_size] } {
    ::amsn::FTProgress r $self $options(-localpath) [$blob cget -current_size] [$blob cget -blob_size]
  }

}

method On_transfer_completed { event session data } {

  if { $session != $p2pSession } { return }

  foreach {event callback} $handlers {
    ::Event::unregisterEvent $event all [list $self $callback]
  }

  ::amsn::FTProgress fr $self $options(-localpath)

  $self configure -data $data

  set filename [$self cget -localpath]

  set fd [open $filename w]
  fconfigure $fd -translation {binary binary}
  puts -nonewline $fd $data
  close $fd

}

}

snit::type FileTransferHandler {

option -client ""

variable incoming_sessions -array {}

constructor { args } {

  $self configurelist $args

}

method Can_handle_message { message } {

  status_log "Can I handle $message with body [$message body]?"
  set euf_guid [[$message body] cget -euf_guid]
  if { $euf_guid == $::p2p::EufGuid::FILE_TRANSFER } {
    return 1
  } else {
    return 0
  }

}

method Handle_message { peer guid message } {

  set context [[$message body] cget -context]]
  set session [FileTransferSession %AUTO% -session_manager [$self cget -client] -peer $peer -euf_guid $::p2p::EufGuid::FILE_TRANSFER -application_id [$message cget -application_id] -message $message -context $context]
  $session conf2

  ::Event::registerEvent p2pIncomingCompleted all [list $self Incoming_session_transfer_completed]
  set incoming_sessions($session) {p2pIncomingCompleted Incoming_session_transfer_completed}
  #@@@@ TODO: print data on aMSN CW, wait until they are accepted
  ::amsn::GotFileTransferRequest $peer ${peer}\;$guid $session
  return $session

}

method request { peer filename size callback {errback ""} } {

  set session [FileTransferSession %AUTO% -session_manager [$self cget -client] -peer $peer -application_id $::p2p::ApplicationID::FILE_TRANSFER -message $message 
  $session conf2

  set handles [list p2pOnSessionAnswered On_session_answered p2pOnSessionRejected On_session_rejected p2pOutgoingSessionTransferCompleted Outgoing_session_transfer_completed]
  foreach {event callb} $handles {
    ::Event::registerEvent $event all [list $self $callb]
  }
  set outgoing_sessions([$session p2p_session]) [list $handles $callback $errback]
  $session invite $filename $size

}

method Outgoing_session_transfer_completed { event session data } {

  status_log "Outgoing session transfer completed!!!!!!!"
  set lst $outgoing_sessions($session)
  set handles [lindex $lst 0]
  set callback [lindex $lst 1]
  set errback [lindex $lst 2]
  status_log "Callback is $callback"

  foreach {event callb} $handles {
    ::Event::unregisterEvent $event all [list $self $callb]
  }

  set method_name [lindex $callback 0]
  set args [lreplace $callback 0 0]
  eval $method_name $data $args

  array unset outgoing_sessions $session

}

method Incoming_session_transfer_completed { session data } {

  set {event callback} $incoming_sessions($session)
  ::Event::unregisterEvent $event all [list $self $callback]
  array unset incoming_sessions $session

}

method On_session_answered { answered_session } { }

method On_session_rejected { session } { }

}

}
