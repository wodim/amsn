namespace eval ::p2p {

snit::type Message {

variable headers -array {}
variable body ""
variable headernames {}
variable found 0
option -content_type
option -application_id \x00\x00\x00\x00

constructor { args } {
  $self configurelist $args
  $self clear
}

method set_body { newbody } {
  set body $newbody
}

method get_body { } {
  return $body
}

method headers { } {
  return [array get headers]
}

method add_header { key value } {

  set headers($key) $value
  if { [lsearch $headernames $key] < 0 } {
    set headernames [lappend headernames $key]
  }
  if { $key == "Content-Type" } {
    set options(-content_type) $value
  }

}

method clear { } {
  array set headers {}
  set body ""
}

method parse { chunk } {

  set lines [split $chunk "\n"]
  foreach line $lines {
    set line [string trim $line]
    if { $found == 1 } {
      if { $body == "" } { 
        set body $line 
      } else {
        set body [join [list $body $line] "\r\n"]
      }
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
  set options(-content_type) $content_type
}

method toString { } {

  set str ""
  set newl \r\n
  #content-length
  foreach key $headernames {
    set value $headers($key)
    set str [join [list $str $key ": " $value $newl] ""] ;#concat strips newlines
  }
  set str [join [list $str $newl $body $options(-application_id)] ""]
  return $str

}

}

}
