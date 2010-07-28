namespace eval ::p2p {

 snit::type MessageBlob {

    option -application_id ""
    option -data ""
    option -blob_size ""
    option -session_id ""
    option -blob_id ""
    option -current_size 0
    option -id ""
    option -is_file ""

    constructor { args } {

      $self configurelist $args
      set data $options(-data)
      if { $data != "" } {
        if { [string length $data] > 0 } {
          set blob_size [expr {[string length $data] - 2}]
	  if { $options(-blob_size) == "" } {
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

      puts "Size is $options(-blob_size) and we have [$self transferred]"
      return [expr {$options(-blob_size) == [$self transferred]}]

    }

    method read_data { } {

      return $options(-data)

    }

    method get_chunk { version max_size {sync 0} } {
      set module ::p2pv$version
      set chunk [${module}::MessageChunk createMsg $options(-application_id) $options(-session_id) $options(-id) [$self transferred] $options(-blob_size) $max_size $sync]
      set data $options(-data)
      puts "Data of $self !!!!!!!!!! $data"
      if { $data != "" } {
        set newsize [expr {$options(-current_size) + [$chunk size]}]
        if { $newsize > $options(-blob_size) } {
          set data [string range $data $options(-current_size) $newsize]
        } else {
          set data [string range $data $options(-current_size) end]
        }
	puts "Chunk of $self is of size [$chunk size] from $options(-current_size) to $newsize"
	puts "Chunk: $data"
        $chunk set_data $data
        $self configure -current_size $newsize
        return $chunk
        
      }
    }

    method append_chunk { chunk} {

      if { ($options(-session_id) != [$chunk session_id]) || ($options(-id) != [$chunk blob_id]) } { return }
      set body [$chunk cget -body]
      set options(-data) [concat $options(-data)$body]
      set options(-current_size) [string length $options(-data)]

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
