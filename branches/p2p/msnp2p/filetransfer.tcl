namespace eval ::p2p {

snit::type FileTransferSession {

delegate option * to p2pSession
delegate method * to p2pSession

option -filename ""
option -size 0
option -has_preview 0
option -preview ""
option -data ""

constructor { args } {

  install p2pSession using P2PSession %AUTO% -euf_guid $::p2p::EufGuid::FILE_TRANSFER
  $p2pSession conf2
  $self configurelist $args
  
  if { [$p2pSession cget -message] != "" } {

    $self parse_context [[$message body] cget -context]

  }
  ::Event::registerEvent p2pBridgeSelected all [$self On_bridge_selected]

}

method invite { filename size } {

  set options(-filename) $filename
  set options(-size) $size
  set options(-context) [$self build_context]
  $self Invite $context

}

method accept { } {

  $self Respond "200"

}

method reject { } {

  $self Respond "603"

}

method cancel { } {

  $self Close

}

method send { data } {

  set options(-data) $data
  $self Request_bridge

}

method build_context { } {

  global HOME

  set ext [string tolower [string range [fileext $filename] 1 end]
  if { $ext == "jpg" || $ext == "gif" || $ext == "png" || $ext == "bmp" || $ext == "jpeg" || $ext == "tga" } {
    set nopreview 0
  } else {
    set nopreview 1
  }

  #if {[::config::getKey noftpreview]} {
    set nopreview 1
  #}

  set context "[binary format i 574][binary format i 2][binary format i $options(-size)][binary format i 0][binary format i $nopreview]"

  set file [ToUnicode [getfilename $options(-filename)]]
  set file [binary format a550 $file]
  set context "${context}${file}\xFF\xFF\xFF\xFF"

  return $context

  #@@@@@@@ TODO: preview

}

method parse_context { context } {

  global HOME

  binary scan [string range $context 0 3] i size
  binary scan [string range $context 8 11] i filesize
  binary scan [string range $context 16 19] i nopreview

  set filename [FromUnicode [string range $context 20 569]]

  set idx [string first "\x00" $filename]
  if {$idx != -1 } {
    set filename [string range $filename 0 [expr {$idx - 1}]]
  }  

  if { $nopreview == 0 } {
    set previewdata [string range $context $size end]
    set dir [file join $HOME FT cache]
    create_dir $dir
    set sid $options(-id)
    set fd [open "[file join $dir ${sid}.png ]" "w"]
    fconfigure $fd -translation binary
    puts -nonewline $fd "$previewdata"
    close $fd
    set file [file join $dir ${sid}.png]
    if { $file != "" && ![catch {set img [image create photo [TmpImgName] -file $file]} res]} {
      ::skin::setPixmap FT_preview_${sid} "[file join $dir ${sid}.png]"
    }
    catch {image delete $img}
  }


}

method On_bridge_selected { } {

  if { options(-data) != "" } {

    $self Send_p2p_data \x00\x00\x00\x00
    $self Send_p2p_data $options(-data) 1

  }

}

}

}
