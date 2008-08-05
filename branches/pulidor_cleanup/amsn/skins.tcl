########################################################################
##             skins.tcl - aMSN Skins System (0.95B)                  ##
##  ----------------------------------------------------------------  ##
##   If you want to add any option to skins system, please, be sure   ##
##    of commenting out your code and keep your values in a proper    ##
##      section of settings.xml, so the system remains coherent       ##
########################################################################

::Version::setSubversionId {$Id$}

namespace eval ::skin {

	variable preview_skin_change 0

	################################################################
	# ::skin::getKey (key, [default])
	# This procedure get the value of a skin's configuration key
	# supplied by $key and returns it. If the given key doesn't
	# exists, it will return $default if supplied, or "" if not.
	# Arguments:
	#  - key => The requested skin's configurarion key.
	#  - default => [NOT REQUIRED] the fallback value.
	proc getKey {key {default ""}} {
		if { [info exists ::skin_setting($key)] } {
			return [::set ::skin_setting($key)]
		} else {
			return $default
		}
	}


	################################################################
	# ::skin::setKey (key, value)
	# This procedure assigns a value (supplied by $value) to a 
	# skin's configuration key supplied by $key. It returns nothing.
	# Arguments:
	#  - key => The name of the skin's configurarion key.
	#  - value => The data assigned to $key
	proc setKey {key value} {
		::set ::skin_setting($key) $value
	}


	################################################################
	# ::skin::InitSkinDefaults ()
	# Here we set every data wich depends on skins to default, so we
	# can load a skin without problems.
	proc InitSkinDefaults { } {
		global emoticon_number emotions emotions_data
		set emoticon_number 0
		if { [info exists emotions] } {unset emotions}
		if { [info exists emotions_data] } {unset emotions_data}

		::skin::setKey bigstate_xpad 0
		::skin::setKey bigstate_ypad 3
		
		::skin::setKey mystatus_xpad 5
		::skin::setKey mystatus_ypad 0
		
		::skin::setKey mailbox_xpad 5
		::skin::setKey mailbox_ypad 0
		
		::skin::setKey contract_xpad 5
		::skin::setKey contract_ypad 0
		
		::skin::setKey expand_xpad 5
		::skin::setKey expand_ypad 0

		::skin::setKey contactlist_xpad 10
		::skin::setKey contactlist_ypad 10
		
		::skin::setKey mydp_hoverimage 0
		
		#set the null image transparent
		[::skin::loadPixmap null] blank
		
	}
	
	proc GetSkinImageName { location image } {
		return "skin_${location}_${image}"
	}



	################################################################
	# ::skin::loadPixmap (pixmap_name [, location])
	# Checks if the image was previously loaded, or we need to load
	# it. This way, the pixmaps will be loaded first time they're 
	# used, on demand. It returns the image resource to be used.
	# Arguments:
	#  - pixmap_name => Name of the image resource to be used in amsn
	#  - location => [NOT REQUIRED, defaults to pixmaps]
	#                Which folder in the skins folder the file is under (eg pixmaps or smileys)
	proc loadPixmap {pixmap_name {location pixmaps} {fblocation ""}} {
		
		variable fb_locations
		
		set image_name [GetSkinImageName $location $pixmap_name]
		#Check if image already loaded, or load it
		if { [catch { image inuse $image_name }] } {
			
			#If the loading pixmap is corrupted (like someone stupid trying
			#to change the smileys by himself and is doing something bad),
			#just show a null picture
			if { [catch {
				image create photo $image_name \
					-file [::skin::GetSkinFile ${location} $pixmap_name "" $fblocation] \
					-format cximage
			} res ] } {
			 	status_log "Error while loading pixmap $res" red
			 	image create photo $image_name
			}
			
			#Store fallback location, if specified, for use on reloading
			if { $fblocation != "" } {
				set fb_locations($image_name) $fblocation
			}
		}
		return $image_name
	}

	################################################################
	# ::skin::newFont
	# Creates a new font based on values from the settings.xml file.
	proc newFont {cstack cdata saved_data cattr saved_attr args} {
		upvar $saved_data sdata
		
		#Check if no important fields are missing.
		#The name field must be present.
		if { ! [info exists sdata(${cstack}:name)] } { return 0 }

		set font_name ""
		set font_family [lindex [::config::getGlobalKey basefont] 0]
		set font_size [lindex [::config::getGlobalKey basefont] 1]
		set font_weight "normal"
		set font_slant "roman"
		set font_underline "false"

		foreach field [array names sdata] {
			# Iterate the data.
			switch [string replace $field 0 15] {
				name {
					if {[string trim $sdata($field)] != "default"} {
						set font_name [string trim $sdata($field)]
					}
				}
				family {
					if {[string trim $sdata($field)] != "default"} {
						set font_family [string trim $sdata($field)]
					}
				}
				size {
					if {[string trim $sdata($field)] != "default"} {
						set font_size [string trim $sdata($field)]
					}
				}
				weight {
					set font_weight [string trim $sdata($field)]
				}
				slant {
					if {[string trim $sdata($field)] == "none"} {
						set font_slant "roman"
					} else {
						set font_slant [string trim $sdata($field)]
					}
				}
				underline {
					set font_underline [string trim $sdata($field)]
				}
				default {
					status_log "::skin::newFont => Illegal argument: [string replace $field 0 15]. Value: [string trim $sdata($field)]."
				}
			}
		}
		
		if {[lsearch [font names] $font_name] != "-1"} {
			font delete $font_name
		}
		
		#puts "$font_name \"$font_family\" $font_size $font_weight $font_slant $font_underline"
		font create "$font_name" -family "$font_family" -size "$font_size" -weight "$font_weight" -slant "$font_slant" -underline "$font_underline"
		
		# This is required by sxml.
		return 0
	}
	
	################################################################
	# ::skin::getFont (fontname [, default_font])
	# Looks for the font requested, and if it isn't there it returns the default font given.
	# Arguments:
	#  - fontname => The name of the font to load from the skins config file.
	#  - default => The name of the font to load if the font isn't available from the skin.
	proc getFont {fontname {default "bplainf"}} {
		if {[lsearch [font names] $fontname] != "-1"} {
			return $fontname
		} else {
			return $default
		}	
	}

	################################################################
	# ::skin::getNoDisplayPicture ([skin_name])
	# Checks if the image was previously loaded, or we need to load
	# it. This way, the displaypicture_std_none will be loaded first time it's used.
	# It always returns 'displaypicture_std_none', is always the same name (static).
	# Arguments:
	#  - skin_name => [NOT REQUIRED] Overrides the current skin.
	proc getNoDisplayPicture { {skin_name ""} } {
		if {[catch {image inuse displaypicture_std_none}]} {
			image create photo displaypicture_std_none -file [::skin::GetSkinFile displaypic nopic.gif $skin_name] -format cximage
		}
		return displaypicture_std_none
	}

	proc getDisplayPicture { email {force 0}} {
		global HOME
				
		set picName displaypicture_std_$email
		#@@@@@@@@@ webMSN display picture (thanx to majinsoftware)
		if { [::abook::getContactData $email client] == "Webmessenger" } { 
			return [::skin::loadPixmap webmsn_dp]
		}
		if {[catch {image width $picName}] == 0  && $force == 0} {
			return $picName
		}

		if { [::abook::getContactData $email customdp] != "" } {
			set filename [::abook::getContactData $email customdp ""]
			# As custom DP can also be stored outside the cache folder,
			# customdp stores the full path to the image
			set file $filename
		} else {
			set filename [::abook::getContactData $email displaypicfile ""]
			set file "[file join $HOME displaypic cache $email ${filename}].png"
		}
		
		if { $filename != "" && [file readable "$file"] } {
			catch {image create photo $picName -file "$file" -format cximage}
		} else {
			# We do like that to have a better update of the image when switching from no pic to another
			#image create photo $picName -file [::skin::GetSkinFile displaypic nopic.gif] -format cximage
			image create photo $picName
			$picName copy [::skin::getNoDisplayPicture]
			set file [::skin::GetSkinFile displaypic nopic.gif]
		}
		
		if {[catch {image width $picName} res]} {
			#status_log "Error while loading $picName: $res"
			image create photo $picName
			$picName copy [::skin::getNoDisplayPicture]
			set file [::skin::GetSkinFile displaypic nopic.gif]
		}
		
		if { [catch {::picture::GetPictureSize $file} cursize] } {
			#Corrupted image.. might as well delete it and redownload it some other time..
			status_log "Error opening $file: $cursize\n"
			catch {file delete $file}
		} elseif { [::config::getKey autoresizedp] && ![::picture::IsAnimated $file] && $cursize != "96x96"} {
			::picture::Resize $picName 96 96
		}
		if { [catch {image height displaypicture_tny_$email} height] == 0} {
			#Little DP exists so we have to update it
			::skin::getLittleDisplayPicture $email $height 1
		}
		return $picName
	}
	proc getLittleDisplayPictureName { email } {
		return "displaypicture_tny_$email"
	}


	proc getLittleDisplayPicture { email { height 20 } {force 0}} {
		global HOME

		set picName [getLittleDisplayPictureName $email]

		#@@@@@@@@@@ WebMSN Patch again by majinsoftware
		if { [::abook::getContactData $email client] == "Webmessenger" } { 
			set picName [::skin::loadPixmap webmsn_dp]
			::picture::ResizeWithRatio $picName $height $height
			return $picName
		}
		
		set imagetype ""

		if {[catch {image type $picName} imagetype] == 0 && $imagetype != "" && $force == 0} {
			return $picName
		}

		if { [::abook::getContactData $email customdp] != "" } {
			set filename [::abook::getContactData $email customdp ""]
			# As custom DP can also be stored outside the cache folder,
			# customdp stores the full path to the image
			set file $filename
		} else {
			set filename [::abook::getContactData $email displaypicfile ""]
			set file "[file join $HOME displaypic cache $email ${filename}].png"
		}
		
		if { $filename != "" && [file readable $file] } {
			catch {image create photo $picName -file "$file" -format cximage}
		} else {
			image create photo $picName
			$picName copy [::skin::getNoDisplayPicture]
			set file [::skin::GetSkinFile displaypic nopic.gif]
		}
		
		if {[catch {image type $picName} imagetype] != 0 || $imagetype == ""} {
			status_log "Error while loading $picName: $imagetype"
			image create photo $picName
			$picName copy [::skin::getNoDisplayPicture]
			set file [::skin::GetSkinFile displaypic nopic.gif]
		}

		set animated [::picture::IsAnimated $file]

		if { $animated == 0 } {
			::picture::ResizeWithRatio $picName $height $height
			return $picName
		} else {
			set tmpPic [image create photo [TmpImgName]]  ;#gets destroyed
			$tmpPic copy $picName
			image delete $picName
			image create photo $picName
			$picName copy $tmpPic
			image delete $tmpPic
			::picture::ResizeWithRatio $picName $height $height
			return $picName
		}
		return ""
	}

	#Convert a display picture from a user to another size
	proc ConvertDPSize {user width height} {
		if {[catch {
			::picture::Resize [getDisplayPicture $user] $width $height
		} res]} {
			msg_box $res
		}
	}



	################################################################
	# ::skin::getColorBar ([skin_name])
	# Creates the special image that is placed below of the nickname
	# in the contacts' list. It returns the image resource.
	# Arguments:
	#  - skin_name => [NOT REQUIRED] Overrides the current skin.
	proc getColorBar { {skin_name ""} } {
		# Get the contact list width
		global pgBuddyTop
		global pgbuddy_colorbar_width

		set win_width [winfo width [winfo parent $pgBuddyTop]]

		# Avoid deleting/recreating the colorbar every CL refresh!
		if { [info exists pgbuddy_colorbar_width] && $pgbuddy_colorbar_width == $win_width } {
			return uiDynamicElement_mainbar
		}

		set width $win_width
		# Delete old uiDynamicElement_mainbar, and load colorbar
		# The colorbar will be loaded as follows:
		# [first 10 px][11th px repeating to fill][the rest of the colorbar]
		catch {image delete uiDynamicElement_mainbar}

		set barheight [image height [loadPixmap colorbar]]
		set barwidth [image width [loadPixmap colorbar]]
		set barendwidth [expr {$barwidth - 11}]
		if { $width < $barwidth } {
			set width $barwidth
		}
		set barendstart [expr {$width - $barendwidth}]


		# Create the color bar copying from the pixmap
		image create photo uiDynamicElement_mainbar -width $width -height $barheight
		uiDynamicElement_mainbar blank
		uiDynamicElement_mainbar copy [loadPixmap colorbar] -from 0 0 10 $barheight
		uiDynamicElement_mainbar copy [loadPixmap colorbar] -from 10 0 11 $barheight -to 10 0 $barendstart $barheight
		uiDynamicElement_mainbar copy [loadPixmap colorbar] -from [expr {$barwidth - $barendwidth}] 0 $barwidth $barheight -to $barendstart 0 $width $barheight

		set pgbuddy_colorbar_width $win_width
		return uiDynamicElement_mainbar
	}


	################################################################
	# ::skin::loadSound (sound_name)
	# Checks if sound_name is loaded and loads it if it isn't.
	# This function is for the Snack Library.
	# Arguments:
	#  - sound_name => The filename of the desired sound.
	proc loadSound {sound_name absolute_path} {
		variable loaded_sounds

		if { [info exists loaded_sounds($sound_name)] } {
			return snd_$sound_name
		}

		if { $absolute_path == 1 } {
			snack::sound snd_$sound_name -file $sound_name
		} else {
			snack::sound snd_$sound_name -file [::skin::GetSkinFile sounds $sound_name]			
		}
		set loaded_sounds($sound_name) $absolute_path

		return snd_$sound_name
	}


	################################################################
	# ::skin::reloadSkin (skin_name)
	# This procedure reloads everything that depends on skins.
	# Arguments:
	#  - skin_name => The new skin to switch on.
	proc reloadSkin { skin_name } {
		
		reloadSkinSettings $skin_name
		variable fb_locations 

		# Reload all pixmaps

		#Foreach type of image, delete current image and delete
		foreach location [list pixmaps smileys images] {
			
			variable fb_locations
			set prefix [GetSkinImageName $location ""]
			variable fb
			
			foreach image_name [image names] {
				
				if {[string first $prefix $image_name] != 0} {
					continue
				}
				
				set file_name [string range $image_name [string length $prefix] end]
				
				image delete $image_name
				
				#If fallback locations were specified on loading, use them on reload
				if {[info exists fb_locations($image_name)] && $fb_locations($image_name) != "" } {
					set fb_location $fb_locations($image_name)
				} else {
					set fb_location ""
				}
				 			 
				if { [catch {
					image create photo $image_name \
						-file [::skin::GetSkinFile ${location} $file_name $skin_name $fb_location ] \
						-format cximage				
				} res] } {
					status_log "skins::reloadSkin:: Error while loading pixmap $res" red
					image create photo $image_name -file [::skin::GetSkinFile pixmaps null \
				 -format cximage]	
				}
				
			}
			
		}
		
		# Now reload special images that need special treatment
		if {![catch { image delete displaypicture_std_none } ]} {
			::skin::getNoDisplayPicture $skin_name
		}
		
		if {![catch { image delete colorbar } ]} {
			::skin::getColorBar $skin_name
		}

		# Reload sounds
		variable loaded_sounds
		foreach name [array names loaded_sounds] {
			if { [set loaded_sounds($name)] == 1 } {
				snd_$name configure -file $name
			} else {
				snd_$name configure -file [::skin::GetSkinFile sounds $name]
			}
		}
		
		# Change frame color
		catch {.main configure -background [::skin::getKey mainwindowbg]}
		
		#TODO AIM: Move this to Mac specific platform/darwin.tcl, and run on changedSkin event
		if { ![OnMac] } {
			#We are not using pixmapscroll on Mac OS X
			# Reload pixmapscroll's images
			set psdir [LookForExtFolder $skin_name "pixmapscroll"]
			if {$psdir != 0 && [info proc ::pixmapscrollbar::reloadimages] != ""} {
				::pixmapscrollbar::reloadimages $psdir
				status_log "skin $skin_name 's scrollbar loaded"
			}	
		}

		::Event::fireEvent changedSkin gui


	}


	################################################################
	# ::skin::reloadSkinSettings (skin_name)
	# This procedure loads the XML file of the new skin and applies
	# its changes.
	# Arguments:
	#  - skin_name => The new skin to switch on.
	proc reloadSkinSettings { skin_name } {
		# Set defaults
		::skin::InitSkinDefaults
	
		# Load smileys info from default skin first
		set skin_id [sxml::init [::skin::GetSkinFile "" settings.xml default]]
		sxml::register_routine $skin_id "skin:smileys:emoticon" ::smiley::newEmoticon
		sxml::register_routine $skin_id "skin:smileys:size" ::skin::SetEmoticonSize
		sxml::parse $skin_id
		sxml::end $skin_id

		catch { unset ::emotions_cleared }
		
		# Then reload the real skin
		set skin_id [sxml::init [::skin::GetSkinFile "" settings.xml $skin_name]]

		if { $skin_id == -1 } {
			#If someone upgraded from 0.94 and he used another skin, we will use the default skin instead
			set skin_id [sxml::init [::skin::GetSkinFile "" settings.xml default]]
			
			if { $skin_id == -1 } {
				::amsn::errorMsg "[trans noskins]"
				exit
			}
		}

		set ::loading_skin $skin_name
		sxml::register_routine $skin_id "skin:Information" ::skin::SetSkinInfo
		sxml::register_routine $skin_id "skin:General:Colors" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:General:Geometry" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:General:Options" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:Login:Colors" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:Login:Geometry" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:Login:Options" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:ContactList:Colors" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:ContactList:Geometry" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:ContactList:Options" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:ChatWindow:Colors" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:ChatWindow:Geometry" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:ChatWindow:Options" ::skin::SetConfigKeys
		sxml::register_routine $skin_id "skin:smileys:emoticon" ::smiley::newEmoticon
		sxml::register_routine $skin_id "skin:smileys:size" ::skin::SetEmoticonSize
		sxml::register_routine $skin_id "skin:Fonts:Font" ::skin::newFont
		sxml::parse $skin_id
		sxml::end $skin_id
		unset ::loading_skin

		if { [winfo exists .smile_selector]} {destroy .smile_selector}
	}


	################################################################
	# ::skin::SetEmoticonSize (cstack cdata saved_data cattr saved_attr args)
	# Sets the default smiley size for this skin. Arguments supplied
	# by the XML parser.
	proc SetEmoticonSize {cstack cdata saved_data cattr saved_attr args} {
		upvar $saved_data sdata

		if { [info exists sdata(${cstack}:smilew)] } { ::skin::setKey smilew [string trim $sdata(${cstack}:smilew)] }
		if { [info exists sdata(${cstack}:smileh)] } { ::skin::setKey smileh [string trim $sdata(${cstack}:smileh)] }

		return 0
	}


	################################################################
	# ::skin::GetSkinFile (type, filename, [skin_override])
	# Forms the path to the desired filename and returns it.
	# Arguments:
	#  - type => The subdir in skins/ (pixmaps, sounds, smileys...)
	#  - filename => The desired filename (for example, online.gif)
	#  - skin_override => [NOT REQUIRED] Use this skin instead of current
	#  - fblocation => [NOT REQUIRED] Directory to check if file not found in the skins (for plugins)
	proc GetSkinFile { type filename {skin_override ""} {fblocation ""} } {
		global HOME2 HOME

		if { [catch { set skin "[::config::getGlobalKey skin]" } ] != 0 } {
			set skin "default"
		}
		if { $skin_override != "" } {
			set skin $skin_override
		}
		set defaultskin "default"
		#Get filename before .ext extension
		set filename_noext [::skin::filenoext $filename]
		#Get extension of the file
		set ext [string tolower [string range [::skin::fileext $filename] 1 end]]
		
		#If the extension is a picture, or no extension, look in 4 formats
		if { $ext == "" || $ext == "png" || $ext == "gif" || $ext == "jpg" || $ext == "bmp"} {
			#List the 4 formats we support (in order of priority to check)
			set ext [list png gif jpg bmp]
		}

		set locations [list]
		#Get file using global path
		if { "[string range $filename 0 0]" == "/" || "[string range $filename 1 2]" == ":/" } {
			lappend locations ""
		}
		#Get from personal profile folder (needed for displaypics)
		lappend locations [file join $HOME $type]
		#Get file from program dir skins folder
		lappend locations [file join [set ::program_dir] skins $skin $type]
		#Get file from ~/.amsn/skins folder
		lappend locations [file join $HOME2 skins $skin $type]
		#Get file from ~/.amsn/profile/skins folder
		lappend locations [file join $HOME skins $skin $type]
		#Get file from ~/.amsn/amsn-extras/skins folder
		lappend locations [file join $HOME2 amsn-extras skins $skin $type]
		#Get file from default skin
		if { [::skin::getKey ignoredefaultsmileys] != 1 || $type != "smileys" } {
			lappend locations [file join [set ::program_dir] skins $defaultskin $type]
			#Get file from fallback location
			if { ($fblocation != "") } {
				lappend locations [file join $fblocation]
			}
		}

		foreach location $locations {
			foreach extension $ext {
				if { [file readable [file join $location $filename_noext.$extension]] } {
					return "[file join $location $filename_noext.$extension]"
				}
			}
		}
				
		#If we didn't find anything...use null file
		set path [file join [set ::program_dir] skins $defaultskin $type null]
		return $path
	}

	#Proc used to find out where to get pixmaps for extra skinnable widgets
	proc LookForExtFolder { skin folder } {
		global HOME2 HOME
		
		#Get file from program dir skins folder
		if { [file readable [file join [set ::program_dir] skins $skin $folder]] } {
			return "[file join [set ::program_dir] skins $skin $folder]"
		#Get file from ~/.amsn/skins folder
		} elseif { [file readable [file join $HOME2 skins $skin $folder]] } {
			return "[file join $HOME2 skins $skin $folder]"
		#Get file from ~/.amsn/profile/skins folder
		} elseif { [file readable [file join $HOME skins $skin $folder]] } {
			return "[file join $HOME skins $skin $folder]"
		#Get file from ~/.amsn/amsn-extras/skins folder
		} elseif { [file readable [file join $HOME2 amsn-extras skins $skin $folder]] } {
			return "[file join $HOME2 amsn-extras skins $skin $folder]"
		#Get file from default skin
		} elseif { [file readable [file join [set ::program_dir] skins $skin $folder]] } {
			return "[file join [set ::program_dir] skins $skin $folder]"
		} elseif { [file readable [file join [set ::program_dir] utils $folder]] } {
			return "[file join [set ::program_dir] utils $folder]"
		} else {
			return 0
		}
	}


	#We already have theses 2 procs in protocol.tcl but skins.tcl is loaded before protocol.tcl 
	#And I didn't want to change the order and fucked up something
	#Theses 2 procs are used in ::skin::GetSkinFile
	proc filenoext { filename } {
		if {[string last . $filename] != -1 } {
			return "[string range $filename 0 [expr {[string last . $filename] - 1}]]"
		} else {
			return $filename
		}
	}
	
	proc fileext { filename } {
		if {[string last . $filename] != -1 } {
			return "[string range $filename [string last . $filename] end]"
		} else {
			return ""
		}
	}
	################################################################
	# ::skin::SetSkinInfo (cstack cdata saved_data cattr saved_attr args)
	# Gets the information of the skin from the XML file and puts it
	# in global variable $skin. Arguments supplied by the XML parser.
	proc SetSkinInfo {cstack cdata saved_data cattr saved_attr args} {
		global skin
		upvar $saved_data sdata

		foreach key [array names sdata] {
			set skin([string range $key [expr {[string length $cstack] + 1}] [string length $key]]) [string trim $sdata($key)]
		}

		return 0
	}


	################################################################
	# ::skin::FindSkins ()
	# It looks for all the skins with a settings.xml file that it can
	# find and adds them to a list. When it finish, it returns the list.
	proc FindSkins { } {
		global HOME HOME2

		set skins [glob -directory skins */settings.xml]
		set skins_in_home [glob -nocomplain -directory [file join $HOME skins] */settings.xml]
		set skins_in_home2 [glob -nocomplain -directory [file join $HOME2 skins] */settings.xml]
		set skins_in_extras [glob -nocomplain -directory [file join $HOME2 amsn-extras skins] */settings.xml]
		set skins [concat $skins $skins_in_home2 $skins_in_extras]
		if { $HOME != $HOME2 } {
			set skins [concat $skins $skins_in_home]
		}
		set skinlist [list]

		foreach skin $skins {
			set dir [file dirname $skin]
			set desc ""

			if { [file readable [file join $dir desc.txt] ] } {
				set fd [open [file join $dir desc.txt]]
				set desc [string trim [read $fd]]
				close $fd
			}

			set lastslash [expr {[string last "/" $dir]+1}]
			set skinname [list [string range $dir $lastslash end]]
			status_log "Skin: $skin. Dir is: $dir. Skinname: $skinname. Desc: $desc\n" white
			lappend skinname $desc
			lappend skinlist $skinname
		}

		return [lsort -dictionary $skinlist ]
	}


	################################################################
	# ::skin::SetConfigKeys (cstack cdata saved_data cattr saved_attr args)
	# This procedure loads the skin's data from settings.xml into
	# the proper variables. Arguments supplied by the XML parser.
	proc SetConfigKeys {cstack cdata saved_data cattr saved_attr args} {
		upvar $saved_data sdata
		foreach key [array names sdata] {
			::skin::setKey [string range $key [expr {[string length $cstack] + 1}] [string length $key]] [string trim $sdata($key)]
		}

		# This bits are used to override certain keys loaded before with specific values for MacOS X (TkAqua)
	#	if { [OnMac] } {
	#		if { [info exists sdata(${cstack}:chatwindowbg)] } { ::skin::setKey buttonbarbg [string trim $sdata(${cstack}:chatwindowbg)] }
	#			::skin::setKey chat_top_border 0
	#			::skin::setKey chat_output_border 0
	#			::skin::setKey chat_buttons_border 0
	#			::skin::setKey chat_input_border 0
	#			::skin::setKey chat_status_border 0
	#			
	#			::skin::setKey chat_paned_padx 0
	#			::skin::setKey chat_paned_pady 0
	#			
	#			::skin::setKey chat_status_padx 0
	#			::skin::setKey chat_status_pady 0
	#			
	#			::skin::setKey chat_top_padx 0
	#			::skin::setKey chat_top_pady 0
	#			
	#			::skin::setKey chat_output_padx 0
	#			::skin::setKey chat_output_pady 0
	#			
	#			::skin::setKey chat_sendbutton_padx 0
	#			::skin::setKey chat_sendbutton_pady 0
	#	}

		# Procedures binded to the XML parser must ALWAYS return 0
		return 0
	}
	
	
	#TODO AIM: From time to time, call this, and remove unused images
	#from memory. Need to fix some thigs before, though
	proc clearUnusedImages { } {
		#puts "Cleaning images"
		return

		foreach img [image names] {
			if { ![image inuse $img] } {
				puts "  Deleting: $img"
				image delete $img
			}
		}
		#after 500 ::skin::clearUnusedImages
	}
	
}

namespace eval ::skinsGUI {


	################################################################
	# ::skinsGUI::SelectSkin ()
	# This procedure creates the skins selector window and shows it.
	proc SelectSkin { } {
		set w .skin_selector

		if { [winfo exists $w] } {
			focus $w
			raise $w
			return
		}

#TODO: the preview pane should be fixed size and scrollable so the window doesn't get overpopulated or too big

		toplevel $w
#		if {[OnMac]} {
			wm resizable $w 1 1
#		} else {
#			wm resizable $w 0 0
#		}
		wm title $w "[trans chooseskin]"
		wm geometry $w +100+100

		label $w.choose -text "[trans chooseskin]" -font bboldf
		pack $w.choose -side top

		label $w.restart -text "[trans restartforskin]"
                pack $w.restart -side top

		frame $w.main
		frame $w.main.left
		frame $w.main.right
		frame $w.main.left.images
		text $w.main.left.desc -height 6 -width 40 -relief sunken \
			-font sboldf -wrap word
		listbox $w.main.right.box -yscrollcommand "$w.main.right.ys set" -height 8 -width 30
		scrollbar $w.main.right.ys -command "$w.main.right.box yview" -highlightthickness 0 \
			-borderwidth 1 -elementborderwidth 2

		bind $w <<Escape>> "::skinsGUI::SelectSkinCancel $w"

		pack $w.main.left.images -in $w.main.left -side top -expand 0 -fill both
		pack $w.main.left.desc -in $w.main.left -side bottom -expand 1 -fill both
		pack $w.main.left -in $w.main -side left -expand 1 -fill both
		pack $w.main.right.ys -side right -fill both
		pack $w.main.right.box -side left -expand 0 -fill both
		pack $w.main.right -side right -expand 1 -fill both
		pack $w.main -expand 1 -fill both

		label $w.status -text ""
		pack $w.status -side bottom

#		image create photo blank -width 1 -height 75
#		label $w.main.left.images.blank -image blank

#		image create photo blank2 -width 400 -height 1
#		label $w.main.left.images.blank2 -image blank2

		set select -1
		set idx 0

		label $w.getmore -text "[trans getmoreskins]"  -font splainf \
			-bg [::skin::getKey extrastdwindowcolor] -fg [::skin::getKey extralinkcolor]
		bind $w.getmore <Enter> "$w.getmore configure -font sunderf -cursor hand2 \
			-bg [::skin::getKey extralinkbgcoloractive] -fg [::skin::getKey extralinkcoloractive]"
		bind $w.getmore <Leave> "$w.getmore configure -font splainf -cursor left_ptr \
			-background [::skin::getKey extrastdwindowcolor] -foreground [::skin::getKey extralinkcolor]"
		bind $w.getmore <ButtonRelease> "launch_browser $::weburl/skins.php"

		button $w.ok -text "[trans ok]" -command "::skinsGUI::SelectSkinOk $w"
		button $w.cancel -text "[trans cancel]" -command "::skinsGUI::SelectSkinCancel $w"
		checkbutton $w.preview -text "[trans preview]" -variable ::skin::preview_skin_change -onvalue 1 -offvalue 0		

		pack $w.getmore -side left -padx 5	
		pack $w.ok  $w.cancel $w.preview -side right -pady 5 -padx 5

		set the_skins [::skin::FindSkins]

		foreach skin $the_skins {
			if { [lindex $skin 0] == [::config::getGlobalKey skin] } { set select $idx } 
			$w.main.right.box insert end "[lindex $skin 0]"
			incr idx
		}

		set ::skin::skin_reloaded_needs_reset 0
		if { $select == -1 } {
			set select 0
			status_log "selecy = 0 --- didn't find current skin defaulting to first"

			$w.main.right.box selection set $select
	 		$w.main.right.box itemconfigure $select \
				-bg [::skin::getKey extralistboxselectedbg] -fg [::skin::getKey extralistboxselected] \
				-selectforeground [::skin::getKey extralistboxselected]

			set currentskin [lindex [lindex $the_skins 0] 0]
			if { $::skin::preview_skin_change == 1 } {
				set ::skin::skin_reloaded_needs_reset 1
				::skin::reloadSkin $currentskin
			}
		} else {
			status_log "select = $select --- [::config::getGlobalKey skin]\n"

			$w.main.right.box selection set $select
			$w.main.right.box itemconfigure $select \
				-bg [::skin::getKey extralistboxselectedbg] -fg [::skin::getKey extralistboxselected] \
				-selectforeground [::skin::getKey extralistboxselected]
		}
	
		::skinsGUI::DoPreview 1
		bind $w <Destroy> "grab release $w"
		bind $w.main.right.box <Button1-ButtonRelease> "::skinsGUI::DoPreview"

		moveinscreen $w 30
	}


	################################################################
	# ::skinsGUI::DoPreview ([skip_reload])
	# Updates the preview images (or skin if selected) when changing
	# the skin selection.
	# Arguments:
	#  - skip_reload => Don't reload the skin for preview.
	proc DoPreview { {skip_reload 0} } {
		set w .skin_selector
		set the_skins [::skin::FindSkins]
		set currentskin [lindex [lindex $the_skins [$w.main.right.box curselection]] 0]
		set currentdesc [lindex [lindex $the_skins [$w.main.right.box curselection]] 1]

		::skinsGUI::ClearPreview

		# If our skin hasn't the example images, take them from the default one
		image create photo preview1 -file [::skin::GetSkinFile pixmaps prefpers.gif $currentskin] -format cximage
		image create photo preview2 -file [::skin::GetSkinFile pixmaps bonline.gif $currentskin] -format cximage
		image create photo preview3 -file [::skin::GetSkinFile pixmaps offline.gif $currentskin] -format cximage
		image create photo preview4 -file [::skin::GetSkinFile pixmaps baway.gif $currentskin] -format cximage
		image create photo preview5 -file [::skin::GetSkinFile pixmaps amsnicon.gif $currentskin] -format cximage
		image create photo preview6 -file [::skin::GetSkinFile pixmaps butblock.gif $currentskin] -format cximage
		image create photo preview7 -file [::skin::GetSkinFile pixmaps butsmile.gif $currentskin] -format cximage
		image create photo preview8 -file [::skin::GetSkinFile pixmaps butsend.gif $currentskin] -format cximage
	
		label $w.main.left.images.1 -image preview1
		label $w.main.left.images.2 -image preview2
		label $w.main.left.images.3 -image preview3
		label $w.main.left.images.4 -image preview4
		label $w.main.left.images.5 -image preview5
		label $w.main.left.images.6 -image preview6
		label $w.main.left.images.7 -image preview7
		label $w.main.left.images.8 -image preview8

		grid $w.main.left.images.1 -in $w.main.left.images -row 1 -column 1
		grid $w.main.left.images.2 -in $w.main.left.images -row 1 -column 2
		grid $w.main.left.images.3 -in $w.main.left.images -row 1 -column 3
		grid $w.main.left.images.4 -in $w.main.left.images -row 1 -column 4
		grid $w.main.left.images.5 -in $w.main.left.images -row 1 -column 5
		grid $w.main.left.images.6 -in $w.main.left.images -row 1 -column 6
		grid $w.main.left.images.7 -in $w.main.left.images -row 1 -column 7
		grid $w.main.left.images.8 -in $w.main.left.images -row 1 -column 8
#		grid $w.main.left.images.blank -in $w.main.left.images -row 1 -column 10
#		grid $w.main.left.images.blank2 -in $w.main.left.images -row 2 -column 1 -columnspan 8

		$w.main.left.desc configure -state normal
		$w.main.left.desc delete 0.0 end
		$w.main.left.desc insert end "[trans description]\n\n$currentdesc"
		$w.main.left.desc configure -state disabled
	
		if { (!$skip_reload) && $::skin::preview_skin_change == 1 } {
			set ::skin::skin_reloaded_needs_reset 1
			::skin::reloadSkin $currentskin
		}
	}


	################################################################
	# ::skinsGUI::ClearPreview ()
	# Destroys every preview image on the skin selector.
	proc ClearPreview { } {
		if {[winfo exists .skin_selector.main.left.images]} {
			destroy .skin_selector.main.left.images.1
			destroy .skin_selector.main.left.images.2
			destroy .skin_selector.main.left.images.3
			destroy .skin_selector.main.left.images.4
			destroy .skin_selector.main.left.images.5
			destroy .skin_selector.main.left.images.6
			destroy .skin_selector.main.left.images.7
			destroy .skin_selector.main.left.images.8
		}
		catch {
#TODO the destruction of the images should be binded to the destruction of the widget they're in
			image delete preview1
			image delete preview2
			image delete preview3
			image delete preview4
			image delete preview5
			image delete preview6
			image delete preview7
			image delete preview8
		}
	}


	################################################################
	# ::skinsGUI::SelectSkinOk (w)
	# Checks if your selection is valid, if it is, it applies changes.
	# This procedure is called when OK in skin selector is pressed.
	# Arguments:
	#  - w => Path of the widget skin selector.
	proc SelectSkinOk { w } {
		if { [$w.main.right.box curselection] == "" } {
			$w.status configure -text "[trans selectskin]"
		} else {
			$w.status configure -text ""
			set skinidx [$w.main.right.box curselection]
			set skin [lindex [lindex [::skin::FindSkins] $skinidx] 0]
			status_log "Chose skin No $skinidx : $skin\n"
			config::setGlobalKey skin $skin
			save_config
			::config::saveGlobal
			unset ::skin::skin_reloaded_needs_reset
			::skin::reloadSkin $skin
			destroy $w
			ClearPreview
		}
	}


	################################################################
	# ::skinsGUI::SelectSkinCancel (w)
	# Checks if we need to reload current skin and destroys the selector.
	# This procedure is called when Cancel in skin selector is pressed.
	# Arguments:
	#  - w => Path of the widget skin selector.
	proc SelectSkinCancel { w } {
		if { $::skin::skin_reloaded_needs_reset } {
			::skin::reloadSkin [::config::getGlobalKey skin]
		}
		unset ::skin::skin_reloaded_needs_reset
		destroy $w
		ClearPreview
	}
	
	
}

 #::skin::clearUnusedImages
