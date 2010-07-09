namespace eval ::p2p {

snit::type Message {

variable headers -array {}
variable body ""
option -content_type

constructor { args } {
  $self configurelist $args
  $self clear
}

method add_header { key value } {

  set headers($key) $value
  if { $key == "Content-Type" } {
    set options(-content_type) $value
  }

}

method clear { } {
  array set headers {}
  set body ""
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
        set headers([lindex $name_value 0]) [lindex $name_value 1]
      }
    }
  }

  if { [lsearch [array names headers] "Content-Type"] >= 0 } {
    set content_type $headers(Content-Type)
  } else {
    set content_type ""
  }
  set options(-content_type) $content_type
}

method toString { } {

  set str ""
  set newl \r\n
  #content-length
  foreach key [array names headers] {
    set value $headers($key)
    set str [join [list $str $key : $value $newl] ""] ;#concat strips newlines
  }
  set str [join [list $str $newl] ""]
  return $str

}

}

}
