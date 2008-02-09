
set fd [open [lindex $argv 0]]
set a_fd [open "[lindex $argv 1].siren" w]
set v_fd [open "[lindex $argv 1].wmv3" w]

fconfigure $fd -translation binary
fconfigure $a_fd -translation binary
fconfigure $v_fd -translation binary

set total 0
while { ![eof $fd] } {
	set header [read $fd 2]
	binary scan $header cc size code
	if { ![info exists code] } {
		break
	}
	# signed to unsigned 8bit int
	set size [expr {$size & 0xff}]

	set data [read $fd $size]
	if { [string length $data] != $size } {
		break
	}

	
	#puts "Received $size payload"
	if {$code == 00 } {
		# Video frame
		# TODO handle WMV3 video frames
		puts "It's a video frame! [string length $data]" 
		incr total [string length $data]
		puts -nonewline $v_fd $data
	} elseif {$code == 32 } {
		# Audio frame
		#puts "It's an audio frame!"
		puts -nonewline $a_fd [string range $data 6 end]
	} else {
		#puts "Unknown code $code"
	}
}

close $fd
close $a_fd
close $v_fd

puts "Total : $total"