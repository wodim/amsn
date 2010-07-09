namespace eval ::p2p::transport {

 proc generate_id {{max 2147483647}} {
   set min 1000
   return [expr {int($min + rand() * (1+$max-$min))}]
 }

 snit::type MessageBlob {

    option -application_id ""
    option -data ""
    option -total_size ""
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
          set total_size [expr {[string length $data] - 2}]
        }
      }

      if { $session_id == "" } {
        set session_id [::p2p::transport::generate_id]
      }

      if { $blob_id == "" } {
        set blob_id [::p2p::transport::generate_id]
      }
      set id $blob_id

    }

    method transferred {} {

      return $options(-current_size)

    }

    method is_complete {} {

      return [expr {$options(-total_size) == $options(-transferred)}]

    }

    method read_data { } {

      return $options(-data)

    }

    method get_chunk { version max_size {sync 0} } {
      set chunk [MessageChunk create $version $options(-application_id) $options(-session_id) $options(-id) $options(-transferred) $options(-total_size) $max_size $sync]
      if { $options(-data) != "" } {
        set newsize [expr {$options(-current_size) + [$chunk cget -size]
        if { $newsize > $options(-total_size) } {
          set data [string range $data $options(-current_size) $newsize]
        } else {
          set data [string range $data $options(-current_size) end]
        }
        $chunk configure -data $data
        $self configure -current_size $newsize
        return $chunk
        
      }
    }

    method append_chunk { chunk} {

      if { $options(-session_id) != $chunk cget -session_id || $options(-id) != $chunk cget -blob_id } { return }
      set body [$chunk cget -body]
      set data [concat $data$body]
      set current_size [string length $data]

    }

  };# end of class

  snit::type MessageChunk {

    typemethod parse {version data} {

      set module ::p2pv$version
      return [$module MessageChunk parse $data]

    }

    typemethod create { version app_id session_id blob_id offset blob_size max_size sync} {

      set module ::p2pv$version
      return [$module MessageChunk create $app_id $session_id $blob_id $offset $blob_size $max_size $sync]

    }
  };# end of class

}
