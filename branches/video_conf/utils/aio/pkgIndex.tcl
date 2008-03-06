# Tcl package index file

if {[package vcompare [info tclversion] 8.4] < 0} return

package ifneeded aio 0.1 "[list load [file join $dir aio[info shared]]];package provide aio 0.1"
