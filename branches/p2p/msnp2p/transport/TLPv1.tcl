namespace eval ::p2pv1 {

  snit::type TLPHeader {

    option -size 48
    option -header ""
    option -session_id 0
    option -blob_id 0
    option -blob_offset 0
    option -blob_size 0
    option -chunk_size 0
    option -flags 0
    option -dw1 0
    option -dw2 0
    option -qw1 0

    constructor { args } {

      #Gotta luv tcl
      $self configurelist $args
      $self configure -header [list $options(-session_id) $options(-blob_id) $options(-blob_offset) $options(-blob_size) $options(-chunk_size) $options(-flags) $options(-dw1) $options(-dw2) $options(-qw1)]

    }

    method parse { data} {

      set ret [binary scan [string range $data 0 48] iiiiiiiiiiii $options(-session_id) $options(-blob_id) $options(-blob_offset) $options(-blob_size) $options(-chunk_size) $options(-flags) $options(-dw1) $options(-dw2) $options(-qw1)]
      if {$ret != 12} {
         error "Not enough data to scan header"
      }

    }

  }

  snit::type MessageChunk {

    option -header ""
    option -body ""
    option -application_id 0

    constructor { args } {

      $self configurelist $args
      if { $options(-header) == "" } {
        TLPHeader header
        set options(-header) $header
      }

    }

    method id {} {

      return [$self get_field dw1]

    }

    method set_id { val } {

      $self set_field dw1 $cal

    }

    method next_id {} {

      if { [expr { $options(-id) + 1 }] == 2147483647 } {
        return 1
      }
        return [expr { $options(-id) + 1 }]

    }

    method session_id {} {

      return [$self get_field session_id]

    }

    method blob_id {} {

      return [$self get_field blob_id]

    }

    method ack_id {} {

      return [concat [$self get_field blob_id] [$self get_field dw1]]

    }

    method acked_id {} {

      return [concat [$self get_field dw1] [$self get_field dw2]]

    }

    method size {} {

      return [$self get_field chunk_size]

    }

    method blob_size {} {

      return [$self get_field blob_size]

    }

    method is_control_chunk {} {

      return [$self get_field flags] & 0xCF

    }

    method is_ack_chunk {} {

      return [$self get_field flags] & $::p2p::TLPFlag::ACK

    }

    method is_nak_chunk {} {

      return [$self get_field flags] & $::p2p::TLPFlag::NAK

    }

    method is_nonce_chunk {} {

      return [$self get_field flags] & $::p2p::TLPFlag::KEY

    }

    method is_signaling_chunk {} {

      return [$self get_field session_id] == 0}]

    }

    method has_progressed {} {

      return [$self get_field flags] & $::p2p::TLPFlag::EACH

    }

    method set_data { data } {

      $self configure -body $data

      [$self set_field chunk_size [string length $data]]

      if { [$self get_field session_id] != 0 && [$self get_field blob_size] != 4 && $data != "\x00\x00\x00\x00" } {
        [$self get_field flags $::p2p::TLPFlag::EACH
        if { $options(-application_id) == $::p2p::ApplicationID::FILE_TRANSFER } {
          set flags [$self get_field flags]
          [$self get_field flags ( $flags | $::TLPFlag::FILE )]
        }
      }

    }

    method require_ack {} {

      if { $self is_ack_chunk } {
        return 0
      }

      # chunk_size + blob_offset == blob_size : chunk is over and we need to ACK
      if { [expr [$self get_field chunk_size] + [$self get_field blob_offset] == [$self get_field blob_size] } {
        return 1
      }

      return 0 ;#Chunk not over yet

    }

    method create_ack_chunk {} {

      set flags $::p2p::TLPFlag::ACK
      if { [$self set_field flags & $::p2p::TLPFlag::RAK } {
        set flags {expr [$flags | $::p2p::TLPFlag::RAK }
      }

      set blob_id [ ::p2p::generate_id ]
      TLPHeader header -session_id [$self get_field session_id] -blob_id [$self get_field blob_id] -flags $flags -dw1 [$self Get_Field blob_id] dw2 [$self get_field dw1] -qw1 [$self get_field size]
      return [MessageChunk chunk -header $header]

    }

    method get_nonce {} {

      return ::msn::GetNonceFromData [$self cget -body]

    }

    method set_nonce { nonce} {

       set n1 [string range $nonce 6 7]
       set n2 [string range $nonce 4 5]
       set n3 [string range $nonce 2 3]
       set n4 [string range $nonce 0 1]
       set n5 [string range $nonce 11 12]
       set n6 [string range $nonce 9 10]
       set n7 [string range $nonce 16 17]
       set n8 [string range $nonce 14 15]
       set n9 [string range $nonce 19 22]
       set n10 [string range $nonce 24 end]

       set nonce [string toupper "$n4$n3$n2$n1-$n6$n5-$n8$n7-$n9-$n10"]

       set bnonce [binary format H2H2H2H2H2H2H2H2H4H* $n1 $n2 $n3 $n4 $n5 $n6 $n7 $n8 $n9 $n10]

       $self set_field dw1 [binary format H2H2H2H2 $n1 $n2 $n3 $n4]
       $self set_field dw2 [binary format H2H2H2H2 $n5 $n6 $n7 $n8]
       $self set_field qw1 [binary format H4H* $n9 $n10]
       $self set_field flags [$self get_field flags | $::p2p::TLPFlag::KEY]

    }

    method get_field { arg } {

      return [[$self cget -header] cget -$arg]

    }

    method set_field { arg val } {

      return [[$self cget -header] configure -$arg $val]

    }

    typemethod create { app_id session_id blob_id offset blob_size max_size sync } {

      TLPHeader header
      $header configure -session_id $session_id
      $header configure -blob_id $blob_id
      $header configure -blob_offset $blob_offset
      $header configure -blob_size $blob_size
      $header configure -chunk_size [expr min(

    }

    typemethod parse { data} {

      TLPHeader header
      header parse [string range $data 0 47]
      MessageChunk chunk -header $header -body [string range $data 48 end]
      return chunk

    }

  }

}
