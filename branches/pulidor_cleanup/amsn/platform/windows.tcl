if { [info exists env(USERPROFILE)] } {
    set HOME [file join $env(USERPROFILE) amsn]
} else {
    set HOME "[file join [pwd] amsn_config]"
}
