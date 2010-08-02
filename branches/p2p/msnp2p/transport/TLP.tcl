namespace eval ::p2p {

 snit::type MessageBlob {

    option -application_id ""
    option -data ""
    option -blob_size ""
    option -session_id ""
    option -blob_id ""
    option -current_size 0
    option -id ""
    option -fd ""

    constructor { args } {

      $self configurelist $args
      set data $options(-data)
      if { $data != "" } {
        if { [string length $data] > 0 } {
          set blob_size [string length $data]
	  if { $options(-fd) == "" } {
            set options(-blob_size) $blob_size
          }
        }
      }

      if { $options(-session_id) == "" } {
        $self configure -session_id [::p2p::generate_id]
      }

      if { $options(-blob_id) == "" } {
        $self configure -blob_id [::p2p::generate_id]
      }
      $self configure -id [$self cget -blob_id]

    }

    method transferred {} {

      return $options(-current_size)

    }

    method is_complete {} {

      status_log "Size is $options(-blob_size) and we have $options(-current_size)"
      return [expr {$options(-blob_size) <= [$self transferred]}]

    }

    method read_data { } {

      return $options(-data)

    }

    method get_chunk { version max_size {sync 0} } {
      set module ::p2pv$version
      set offset [$self transferred]
      set sendme ""
      set csize 0
      set data $options(-data)
      if { $data != "" } {
        set newsize [expr {$options(-current_size) + $max_size - [${module}::TLPHeader size]}]
        if { $newsize >= [string length $data] } { set newsize [string length $data] }
        set csize [expr { $newsize - $options(-current_size) } ]
        set sendme [string range $data $options(-current_size) [expr { $newsize - 1 }] ]
      } elseif { $options(-fd) != "" } { ;#data in memory
        set fd $options(-fd)
        set newsize [expr {$options(-current_size) + $max_size - [${module}::TLPHeader size]}]
        set csize [expr { $newsize - $options(-current_size) } ]
        set sendme [read $fd $csize]
        #Maybe we actually read less data (in EOF) so let's calculate again
        set csize [string length $sendme]
        set newsize [expr { $options(-current_size) + $csize } ]
      }
      set chunk [${module}::MessageChunk createMsg $options(-application_id) $options(-session_id) $options(-id) $offset $options(-blob_size) $max_size $sync $csize]
      status_log "Chunk of $self is of size [$chunk size] from $options(-current_size) to $newsize"
      $chunk set_data $sendme
      set options(-current_size) $newsize
      return $chunk
        
    }

    method append_chunk { chunk} {

      if { ($options(-session_id) != [$chunk session_id]) || ($options(-id) != [$chunk blob_id]) } { return }
      set body [$chunk cget -body]
      if { $options(-fd) == "" } { ;#Data in memory
        set options(-data) [join [list $options(-data) $body] ""]
      } else { ;#File descriptor exists, let's write there
        puts -nonewline $options(-fd) $body
      }
      set options(-current_size) [expr { $options(-current_size) + [string length $body] } ]

    }

  };# end of class

  snit::type MessageChunk {

    typemethod parse {version data} {

      set module ::p2pv$version
      return [${module}::MessageChunk parse $data]

    }

    typemethod createMsg { version app_id session_id blob_id offset blob_size max_size sync} {

      set module ::p2pv$version
      return [${module}::MessageChunk createMsg $app_id $session_id $blob_id $offset $blob_size $max_size $sync]

    }
  };# end of class

}
