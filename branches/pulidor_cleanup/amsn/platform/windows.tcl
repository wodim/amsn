if { [info exists env(USERPROFILE)] } {
    set HOME [file join $env(USERPROFILE) amsn]
} else {
    set HOME "[file join [pwd] amsn_config]"
}

lprepend auto_path [file join [pwd] utils windows]
