#!/bin/sh
# \
exec tclsh $0 $@

lappend ::auto_path utils
package require tcl_siren

if { [llength $argv] != 2 } {
   puts "Usage : $argv0 input_file output_prefix"
   puts ""
   puts "This will demux the input_file and create 3 files :"
   puts "\$output_prefix.siren : The siren audio data"
   puts "\$output_prefix.raw : The raw audio data"
   puts "\$output_prefix.wmv3 : The WMV3 video data"
   puts ""
   puts "Use wmv3_dec to decode the wmv3 data"
   puts "Use 'cat \$output_prefix.raw | ./stream_audio.tcl' to play the audio data"
   exit
}

set fd [open [lindex $argv 0]]
set a_fd [open "[lindex $argv 1].siren" w]
set r_fd [open "[lindex $argv 1].raw" w]
set v_fd [open "[lindex $argv 1].wmv3" w]

fconfigure $fd -translation binary
fconfigure $a_fd -translation binary
fconfigure $r_fd -translation binary
fconfigure $v_fd -translation binary

set dec [::Siren::NewDecoder]

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
		puts -nonewline $r_fd [::Siren::Decode $dec [string range $data 6 end]]
		
	} else {
		#puts "Unknown code $code"
	}
}

close $fd
close $a_fd
close $r_fd
close $v_fd

::Siren::Close $dec

puts "Total : $total"
