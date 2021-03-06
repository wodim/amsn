package provide contentmanager 0.1
package require snit
package require scalable-bg
package require contentmanager

# o-------------------------------------------------------------------------------+
#  Name: contentmanager                                                           |
#  Description: Manager type                                       	          |
#  Function: Provide an easy-to-use API to groups and elements                    |
# o-------------------------------------------------------------------------------+
snit::type contentmanager {

	pragma -hasinstances no
	pragma -hastypeinfo no
	pragma -hastypedestroy no

	# -------------------------------------------------------------------------------
	#  Methods to create, destroy, configure and use groups and elements
	# -------------------------------------------------------------------------------
	typemethod getpath { args } {
		set path {}
		foreach name $args {
			# strings beginning with - are options, end getting path
			if { [string equal [string index $name 0] "-"] } {
				break
			}
			if { [string equal $path {}] } {
				set path $name
			} else {
				set path $path.$name
			}
		}
		return $path
	}

	typemethod gettree { args } {
		set tree {}
		foreach name $args {
			if { [string equal [string index $name 0] "-"] } {
				break
			} else {
				lappend tree $name
			}
		}
		return $tree
	}

	typemethod getopts { args } {
		set opts {}
		foreach opt $args {
			if { [string equal [string index $opt 0] "-"] } {
				set val [lindex $args [expr {[lsearch $args $opt] + 1}]]
				lappend opts $opt $val
				continue
			} else {
				continue
			}
		}
		return $opts
	}

	typemethod add { _type args } {
		set path [eval $type getpath $args]
		set opts [eval $type getopts $args]
		set tree [eval $type gettree $args]

		# Check item doesn't already exist
		if { [info command $path] != {} } {
			error "$_type '$path' already exists"
			return {}
		}

		switch $_type {
			group {
				eval group $path -tree [list $tree] $opts
				# If this isn't a toplevel group...
				if { [llength $tree] > 1 } {
					# ...set it's state to its parent's state and register with its parent
					set parent [eval $type getpath [lrange $tree 0 end-1]]
					$path configure -state [$parent cget -state]
					set id [lindex $tree end]
					$parent register $id
				} else {
					set id $tree
				}
			}
			element {
				eval element $path -tree [list $tree] $opts
				# If this isn't a toplevel element...
				if { [llength $tree] > 1 } {
					# ...set it's state to its parent's state and register with its parent
					set parent [eval $type getpath [lrange $tree 0 end-1]]
					$path configure -state [$parent cget -state]
					set id [lindex $tree end]
					$parent register $id
				} else {
					set id $tree
				}
			}
			attachment {
				eval element $path -tree [list $tree] $opts
				# Set it's state to its parent's state and attach it to its parent
				set parent [eval $type getpath [lrange $tree 0 end-1]]
				$path configure -state [$parent cget -state]
				set id [lindex $tree end]
				$parent attach $id
			}
			default {
				error "unknown item type '${_type}'"
			}
		}
		return $id
	}

	typemethod insert { index _type args } {
		# Check index is okay
		if { ![string is integer $index] && $index != "end" } {
			error "invalid insert index '$index'"
		}
		
		set path [eval $type getpath $args]
		set opts [eval $type getopts $args]
		set tree [eval $type gettree $args]

		# Check item doesn't already exist
		if { [info command $path] != {} } {
			error "$_type '$path' already exists"
			return {}
		}

		if { [string equal $_type "group"] } {
			set parent [eval $type getpath [lrange $tree 0 end-1]]
			eval group $path -tree [list $tree] $opts
			# If this isn't a toplevel group...
			if { [llength $tree] > 1 } {
				# ...set it's state to its parent's state and register with its parent
				set parent [eval $type getpath [lrange $tree 0 end-1]]
				$path configure -state [$parent cget -state]
				set id [lindex $tree end]
				$parent register $id $index
			} else {
				set id $tree
			}
		} elseif { [string equal $_type "element"] } {
			eval element $path -tree [list $tree] $opts
			# If this isn't a toplevel element...
			if { [llength $tree] > 1 } {
				# ...set it's state to its parent's state and register with its parent
				set parent [eval $type getpath [lrange $tree 0 end-1]]
				$path configure -state [$parent cget -state]
				set id [lindex $tree end]
				$parent register $id $index
			} else {
				set id $tree
			}
		}
		return $id
	}

	typemethod delete { args } {
		set path [eval $type getpath $args]
		set tree [eval $type gettree $args]
		$path destroy
	}

	typemethod configure { args } {
		set path [eval $type getpath $args]
		set opts [eval $type getopts $args]
		$path configurelist $opts
	}

	typemethod cget { args } {
		set tree [lrange $args 0 end-1]
		set opt [lindex $args end]
		set path [eval $type getpath $tree]
		return [$path cget $opt]
	}

	typemethod children { args } {
		set path [eval $type getpath $args]
		return [$path children]
	}

	typemethod coords { args } {
		set tree [lrange $args 0 end-2]
		set coords [lrange $args end-1 end]
		foreach ord $coords {
			if { ![string is integer $ord] } {
				error "cant user non-numeric '$ord' value as ordinate"
			}
		}
		set path [eval $type getpath $tree]
		eval $path coords $coords
	}

	typemethod getcoords { args } {
		set path [eval $type getpath $args]
		return [eval $path coords]
	}

	typemethod width { args } {
		set path [eval $type getpath $args]
		return [eval $path cget -width]
	}

	typemethod height { args } {
		set path [eval $type getpath $args]
		return [eval $path cget -height]
	}

	typemethod move { args } {
		set tree [lrange $args 0 end-2]
		set vector [lrange $args end-1 end]
		set path [eval $type getpath $tree]
		eval $path move $vector
	}

	typemethod bind { args } {
		set tree [lrange $args 0 end-2]
		set path [eval $type getpath $tree]
		set pattern [lindex $args end-1]
		set command [lindex $args end]
		eval $path bind $pattern [list $command]
	}

	typemethod show { args } {
		set path [eval $type getpath $args]
		set opts [eval $type getopts $args]
		eval $path show $opts
	}

	typemethod hide { args } {
		set path [eval $type getpath $args]
		set opts [eval $type getopts $args]
		eval $path hide $opts
	}

	typemethod toggle { args } {
		set path [eval $type getpath $args]
		eval $path toggle
	}

	typemethod sort { args } {
		set lvlopt [lsearch $args -level]
		if { $lvlopt == -1 } {
			set level r
		} else {
			set level [lindex $args [expr {$lvlopt + 1}]]
		}
		set path [eval $type getpath $args]
		eval $path sort $level
	}

	typemethod type { args } {
		set path [eval $type getpath $args]
		return [eval $path type]
	}

	typemethod register { args } {
		set tree [eval $type gettree $args]
		set path [eval $type getpath [lrange $args 0 end-1]]
		set id [lindex $tree end]
		$path register $id
	}

	typemethod unregister { args } {
		set tree [eval $type gettree $args]
		set path [eval $type getpath [lrange $args 0 end-1]]
		set id [lindex $tree end]
		$path unregister $id
	}
}


snit::type group {

	# Parent options
	option -widget -configuremethod SetWidget
	option -parent
	option -id
	option -tree

	# Dimension options
	option -align -default left
	option -orient -default vertical
	option -height -default 0 -configuremethod SetHeight
	option -valign -default top
	option -width -default 0 -configuremethod SetWidth

	# Padding options
	option -padx -default 0
	option -pady -default 0
	option -ipadx -default 0
	option -ipady -default 0

	# State options
	option -omnipresent -default no
	option -state -default normal -configuremethod SetState

	# Position variables
	variable xPos
	variable yPos

	# Children variables
	variable items
	variable hiddenitems
	variable bboxid

	# Attachment variables
	variable attachments

	# Afterid variables
	variable afterid

	# Binding variables
	variable havebinding

	constructor { args } {
		set xPos 0
		set yPos 0
		set items {}
		set bboxid {}
		set attachments {}
		array set afterid {sort {}}
		set havebinding 0
		$self configurelist $args
	}

	destructor {
		catch {
			foreach item $items {
				set tree $options(-tree)
				lappend tree $item
				eval contentmanager delete $tree
			}
		}
		catch { $options(-widget) delete $bboxid }
		catch { eval contentmanager unregister $options(-tree) }
	}

	method type { } {
		return "group"
	}

	method SetWidget { opt val } {
		set options(-widget) $val
		set bboxid [$val create rect 0 0 0 0 -fill "" -outline "" -state hidden]
	}

	method SetWidth { opt val } {
		set options(-width) $val
		if { ![string equal $bboxid ""] } {
			$options(-widget) coords $bboxid $xPos $yPos [expr {$xPos + $val}] [expr {$yPos + $options(-height)}]
		}
	}

	method SetHeight { opt val } {
		set options(-height) $val
		if { [$self GotWidget] } {
			$options(-widget) coords $bboxid $xPos $yPos [expr {$xPos + $options(-width)}] [expr {$yPos + $val}]
		}
	}

	method SetState { opt val } {
		set options(-state) $val
		switch $val {
			"partlyhidden" {
				$self hide
			}
			"hidden" {
				$self hide
			}
			"normal" {
				$self show
			}
		}
	}

	method GotWidget { } {
		if { ![string equal $bboxid ""] } {
			return 1
		} else {
			return 0
		}
	}

	method register { id {idx ""} } {
		if { [string equal $idx ""] } {
			lappend items $id
		} else {
			set items [linsert $items $idx $id]
		}
	}

	method unregister { id } {
		set idx [lsearch $items $id]
		set list1 [lrange $items 0 [expr {$idx - 1}]]
		set list2 [lrange $items [expr {$idx + 1}] end]
		set items [concat $list1 $list2]
	}

	method children { } {
		return $items
	}

	method attach { id } {
		lappend attachments $id
	}

	method bind { pat cmd {mode "bbox"} } {
		if { [string equal $cmd {}] } {
			set havebinding 0
			$options(-widget) itemconfigure $bboxid -state hidden
		} else {
			set havebinding 1
			if { $mode == "bbox" } {
				$options(-widget) itemconfigure $bboxid -state normal
			}
		}
		switch $mode {
			"bbox" {
				$options(-widget) bind $bboxid $pat $cmd
			}
			"components" {
				foreach item $items {
					set tree $options(-tree)
					lappend tree $item
					eval contentmanager bind $tree $pat [list $cmd]
				}
			}
		}
	}

	method coords { {x {}} {y {}} } {
		if { [string equal $x {}] } {
			return "$xPos $yPos"
		} elseif { $x == $xPos && $y == $yPos } {
			return
		}
		set dx [expr {$x - $xPos}]
		set dy [expr {$y - $yPos}]
		$self move $dx $dy
	}

	method move { dx {dy {}} } {
		if { $dx == 0 } {
			if { $dy == 0 || [string equal $dy {}] } {
				return
			}
		}
		incr xPos $dx
		if { [string equal $dy {}] } {
			foreach item $items {
				set tree $options(-tree)
				lappend tree $item
				eval contentmanager move $tree $dx
			}
			if { [$self GotWidget] } {
				$options(-widget) move $bboxid $dx
			}
		} else {
			incr yPos $dy
			foreach item $items {
				set tree $options(-tree)
				lappend tree $item
				eval contentmanager move $tree $dx $dy
			}
			if { [$self GotWidget] } {
				$options(-widget) move $bboxid $dx $dy
			}
		}
		$self PlaceAttachments
	}

	method show { args } {
		if { [string equal $args {}] } {
			set level r
		} else {
			set level [lindex $args 1]
		}
		foreach item $items {
			set tree $options(-tree)
			lappend tree $item
			if { [eval contentmanager cget $tree -omnipresent] } {
				continue
			}
			if { [string is integer $level] && $level > 0 } {
				eval contentmanager show $tree -level [expr {$level - 1}]
			} elseif { $level == "r" } {
				eval contentmanager show $tree
			}
		}
		foreach attachment $attachments {
			if { [eval contentmanager cget $tree -omnipresent] } {
				continue
			} else {
				set tree $options(-tree)
				lappend tree $attachment
				eval contentmanager show $tree
			}
		}
		set options(-state) normal
		if { $havebinding } {
			$options(-widget) itemconfigure $bboxid -state normal
		}
	}

	method hide { args } {
		if { [string equal $args {}] } {
			set force 0
		} else {
			set force [lindex $args 1]
		}
		set omnipresent 0
		foreach item $items {
			set tree $options(-tree)
			lappend tree $item
			if { [eval contentmanager cget $tree -omnipresent] && !$force } {
				set omnipresent 1
				continue
			}
			eval contentmanager hide $tree
		}
		foreach attachment $attachments {
			if { [eval contentmanager cget $tree -omnipresent] } {
				continue
			} else {
				set tree $options(-tree)
				lappend tree $attachment
				eval contentmanager hide $tree
			}
		}
		if { $omnipresent && !$force } {
			set options(-state) "partlyhidden"
		} else {
			set options(-state) "hidden"
		}
		$options(-widget) itemconfigure $bboxid -state hidden
	}

	method toggle { } {
		switch $options(-state) {
			"normal" {
				$self hide
			}
			"hidden" {
				$self show
			}
			"partlyhidden" {
				$self show
			}
		}
	}

	method sort { {level r} } {
		# Initial coords
		set x [expr {$xPos + $options(-ipadx)}]
		set y [expr {$yPos + $options(-ipady)}]
		set width 0
		set height 0

		# Which way are we sorting (horizontally or vertically)
		switch $options(-orient) {
			"horizontal" {
				set itempady 0
				foreach item $items {
					set tree $options(-tree)
					lappend tree $item
					# If the item is hidden, skip it
					if { [string equal [eval contentmanager cget $tree -state] "hidden"] } {
						continue
					}
					# Sort the item
					if { [string is integer $level] && $level > 0 } {
						eval contentmanager sort $tree -level [expr {$level - 1}]
					} elseif { [string equal $level r] } {
						eval contentmanager sort $tree -level r
					}

					set itempadx [eval contentmanager cget $tree -padx]
					set itempady [eval contentmanager cget $tree -pady]
					set itemwidth [eval contentmanager width $tree]
					set itemheight [eval contentmanager height $tree]

					incr x $itempadx
					incr y $itempady
					eval contentmanager coords $tree $x $y
					incr x $itempadx
					incr y -$itempady
					incr x $itemwidth

					# Is this the tallest item so far?
					if { $itemheight > $height } {
						set height $itemheight
					}
				}
				set width [expr {$x - $xPos + $options(-ipadx)}]
				incr height [expr {(2 * $options(-ipady)) + $itempady}]
				$self configure -height $height
				$self configure -width $width

				# Align the items with each other
				$self AlignItems
			}
			"vertical" {
				set itempadx 0
				foreach item $items {
					set tree $options(-tree)
					lappend tree $item
					# If the item is hidden, skip it
					if { [string equal [eval contentmanager cget $tree -state] "hidden"] } {
						continue
					}
					if { [string is integer $level] && $level > 0 } {
						eval contentmanager sort $tree -level [expr {$level - 1}]
					} elseif { [string equal $level r] } {
						eval contentmanager sort $tree -level r
					}

					set itempadx [eval contentmanager cget $tree -padx]
					set itempady [eval contentmanager cget $tree -pady]
					set itemwidth [eval contentmanager width $tree]
					set itemheight [eval contentmanager height $tree]

					incr x $itempadx
					incr y $itempady
					eval contentmanager coords $tree $x $y
					incr x -$itempadx
					incr y $itempady
					incr y $itemheight

					# Is this the widest item so far?
					if { $itemwidth > $width } {
						set width $itemwidth
					}
				}

				set height [expr {$y - $yPos + $options(-ipady)}]
				incr width [expr {(2 * $options(-ipadx)) + $itempadx}]
				$self configure -width $width
				$self configure -height $height

				# Align the elements with each other
				$self AlignItems
			}
		}
		$options(-widget) raise $bboxid
	}

	method AlignItems { } {
		set width $options(-width)
		set height $options(-height)

		switch $options(-orient) {
			"horizontal" {
				foreach item $items {
					set tree $options(-tree)
					lappend tree $item

					set valign [eval contentmanager cget $tree -valign]
					set h [eval contentmanager cget $tree -height]
					set pady [eval contentmanager cget $tree -pady]
					switch $valign {
						"center" {
							eval contentmanager move $tree 0 [expr {($height / 2) - ($h / 2) - $options(-ipady) - $pady}]
						}
						"middle" {
							eval contentmanager move $tree 0 [expr {($height / 2) - ($h / 2) - $options(-ipady) - $pady}]
						}
						"bottom" {
							eval contentmanager move $tree 0 [expr {$height - $h - $options(-ipady) - $pady}]
						}
					}
				}
			}
			"vertical" {	
				foreach item $items {
					set tree $options(-tree)
					lappend tree $item
					set align [eval contentmanager cget $tree -align]
					set w [eval contentmanager cget $tree -width]
					set padx [eval contentmanager cget $tree -padx]
					switch $align {
						"center" {
							eval contentmanager move $tree [expr {($width / 2) - ($w / 2) - $options(-ipadx) - $padx}] 0
						}
						"middle" {
							eval contentmanager move $tree [expr {($width / 2) - ($w / 2) - $options(-ipadx) - $padx}] 0
						}
						"right" {
							eval contentmanager move $tree [expr {$width - $w - $options(-ipadx) - $padx}] 0
						}
					}
				}
			}
		}
	}

	method PlaceAttachments { } {
		foreach attachment $attachments {
			set tree $options(-tree)
			lappend tree $attachment
			set attx [expr {$xPos + [eval contentmanager cget $tree -padx]}]
			set atty [expr {$yPos + [eval contentmanager cget $tree -pady]}]
			eval contentmanager coords $tree $attx $atty
		}
	}
}

snit::type element {

	# Parent options
	option -widget -configuremethod SetWidget
	option -tag -configuremethod SetTag
	option -tree

	# Dimension options
	option -align -default left
	option -height -default 0 -configuremethod SetHeight -cgetmethod GetHeight
	option -valign -default top
	option -width -default 0 -configuremethod SetWidth -cgetmethod GetWidth

	# Padding options
	option -padx -default 0
	option -pady -default 0
	option -ipadx -default 0 -configuremethod Sort
	option -ipady -default 0 -configuremethod Sort

	# State options
	option -omnipresent -default no
	option -state -default normal -configuremethod SetState

	# Children variables
	variable bboxid

	# Attachment variables
	variable attachments

	# Binding variables
	variable havebinding

	variable xPos
	variable yPos

	constructor { args } {
		set xPos 0
		set yPos 0
		set bboxid {}
		set attachments {}
		set havebinding 0
		$self configurelist $args
	}

	destructor {
		catch {
			$options(-widget) delete $bboxid
			eval contentmanager unregister $options(-tree)
		}
	}

	method type { } {
		return "element"
	}

	method attach { id } {
		lappend attachments $id
	}

	method SetWidget { opt val } {
		set options(-widget) $val
		set bboxid [$val create rect 0 0 0 0 -fill "" -outline "" -state normal]
	}

	method SetWidth { opt val } {
		set options(-width) $val
		if { [$self GotWidget] } {
			$options(-widget) coords $bboxid $xPos $yPos [expr {$xPos + $val}] [expr {$yPos + $options(-height)}]
		}
	}

	method GetWidth { opt } {
		if { [string equal $options(-state) "hidden"] } {
			return 0
		} else {
			return $options(-width)
		}
	}

	method SetHeight { opt val } {
		set options(-height) $val
		if { [$self GotWidget] } {
			$options(-widget) coords $bboxid $xPos $yPos [expr {$xPos + $options(-width)}] [expr {$yPos + $val}]
		}
	}

	method SetState { opt val } {
		set options(-state) $val
		switch $val {
			"partlyhidden" {
				$self hide
			}
			"hidden" {
				$self hide
			}
			"normal" {
				$self show
			}
		}
	}

	method GetHeight { opt } {
		if { [string equal $options(-state) "hidden"] } {
			return 0
		} else {
			return $options(-height)
		}
	}

	method GotWidget { } {
		if { [string equal $options(-widget) ""] } {
			return 0
		} else {
			return 1
		}
	}

	method bind { pat cmd {mode {bbox}} } {
		if { [string equal $cmd {}] } {
			set havebinding 0
		} else {
			set havebinding 1
		}
		if { [$self GotWidget] } {
			$options(-widget) bind $options(-tag) $pat $cmd
			$options(-widget) bind $bboxid $pat $cmd
			$options(-widget) itemconfigure $bboxid -state normal
		}
	}

	method coords { {x {}} {y {}} } {
		if { [string equal $x {}] } {
			return "$xPos $yPos"
		}
		set xPos $x
		set yPos $y
		set tagx [expr {$x + $options(-ipadx)}]
		set tagy [expr {$y + $options(-ipady)}]
		$options(-widget) coords $options(-tag) $tagx $tagy
		$options(-widget) coords $bboxid $xPos $yPos [expr {$xPos + $options(-width)}] [expr {$yPos + $options(-height)}]
		foreach tag $attachments {
			$options(-widget) coords $tag $xPos $yPos
		}
	}

	method move { dx {dy {}} } {
		#if { $dx == 0 } {
		#	if { $dy == 0 || [string equal $dy {}] } {
		#		return
		#	}
		#}

		if { [string equal $dy ""] } {
			$options(-widget) move $options(-tag) $dx
			$options(-widget) move $bboxid $dx
			incr xPos $dx
		} else {
			$options(-widget) move $options(-tag) $dx $dy
			$options(-widget) move $bboxid $dx $dy
			incr xPos $dx
			incr yPos $dy
		}
		$self PlaceAttachments
	}

	method show { args } {
		if { [$self GotWidget] } {
			set options(-state) "normal"
			$options(-widget) itemconfigure $options(-tag) -state normal
			if { $havebinding } {
				$options(-widget) itemconfigure $bboxid -state normal
			}
			foreach attachment $attachments {
				if { [eval contentmanager cget $tree -omnipresent] } {
					continue
				} else {
					set tree $options(-tree)
					lappend tree $attachment
					eval contentmanager show $tree
				}
			}
		}
	}

	method hide { args } {
		if { [$self GotWidget] } {
			if { !$options(-omnipresent) } {
				set options(-state) "hidden"
				$options(-widget) itemconfigure $options(-tag) -state hidden
				$options(-widget) itemconfigure $bboxid -state hidden
			}
			foreach attachment $attachments {
				if { [eval contentmanager cget $tree -omnipresent] } {
					continue
				} else {
					set tree $options(-tree)
					lappend tree $attachment
					eval contentmanager hide $tree
				}
			}
		}
	}

	method toggle { } {
		switch $options(-state) {
			"normal" {
				$self hide
			}
			"hidden" {
				$self show
			}
		}
	}

	method SetTag { opt val } {
		set options(-tag) $val
		$self sort
	}

	method Sort { {opt {}} {val {}} } {
		set options($opt) $val
		$self sort
	}

	method sort { {level {}} } {
		set bbox [$options(-widget) bbox $options(-tag)]
		$options(-widget) raise $bboxid

		# Catch empty items
		if { [string equal $bbox {}] } {
			$self configure -height 0 -width 0
			return
		}

		set bboxwidth [expr {[lindex $bbox 2] - [lindex $bbox 0] + (2 * $options(-ipadx))}]
		set bboxheight [expr {[lindex $bbox 3] - [lindex $bbox 1] + (2 * $options(-ipady))}]
		$self configure -height $bboxheight -width $bboxwidth
	}

	method PlaceAttachments { } {
		foreach attachment $attachments {
			set tree $options(-tree)
			lappend tree $attachment
			set attx [expr {$xPos + [eval contentmanager cget $tree -padx]}]
			set atty [expr {$yPos + [eval contentmanager cget $tree -pady]}]
			eval contentmanager coords $tree $attx $atty
		}
	}
}
