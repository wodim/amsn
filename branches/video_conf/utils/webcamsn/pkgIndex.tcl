# Tcl package index file, version 1.0

if {[package vcompare [info tclversion] 8.4] < 0} return

if { [file exists [file join $dir webcamsn-av[info shared]]] } {
    package ifneeded webcamsn 0.2 "package require Tk; [list load [file join $dir webcamsn-av[info shared]] webcamsn];package provide webcamsn 0.2"
} else {
    package ifneeded webcamsn 0.2 "package require Tk; [list load [file join $dir webcamsn[info shared]] webcamsn];package provide webcamsn 0.2"
}
