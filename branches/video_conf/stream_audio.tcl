#!/bin/sh
# \
exec wish $0 $@

wm withdraw .


package require snack

fconfigure stdin -translation binary

proc finished { } {
    puts "finished... why?"
    exit
}

set snd [sound -channel stdin -fileformat RAW -rate 16000 -channels 1]
$snd play -command finished -blocking yes -nopeeping 1


