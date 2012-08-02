#* 
#* ------------------------------------------------------------------
#* OvalWidget2.tcl - Oval Widgets Version 2
#* Created by Robert Heller on Fri Jan 26 10:52:40 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/02/02 04:13:52  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 

package require Tk
package require snit
package require grsupport 2.0

namespace eval OvalWidgets {}

snit::macro OvalWidgets::XYWH {width height} {
  method _ConfigureXY {option value} {
    set oldx $options(-x)
    set oldy $options(-y)
    set options($option) $value
    set dx [expr {$oldx - $options(-x)}]
    set dy [expr {$oldy - $options(-y)}]
    $canvas move $selfns $dx $dy
  }
  method _CondifureWH {option value} {
    set oldWidth $options(-width)
    set oldHeight $options(-height)
    set options($option) $value
    set scalex [expr {double($options(-width)) / double($oldWidth)}]
    set scaley [expr {double($options(-height)) / double($oldHeight)}]
    $canvas scale $selfns $options(-x) $options(-y) $scalex $scaley
  }
  option -x -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
  option -y -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
  option -width -default $width -validatemethod _VerifyDouble -configuremethod _ConfigureWH
  option -height -default $height -validatemethod _VerifyDouble -configuremethod _ConfigureWH
}

snit::macro OvalWidgets::ColorOptionMethods {} {
  method _ConfigureFillColor {option value} {
    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -fill "$value"}
  }
  method _ConfigureOutlineColor {option value} {
    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -outline "$value"}
  }
}

snit::macro OvalWidgets::CommonValidateMethods {} {
  GRSupport::VerifyDoubleMethod
  GRSupport::VerifyIntegerMethod
  GRSupport::VerifyColorMethod
  GRSupport::VerifyBooleanMethod
}

snit::macro OvalWidgets::ColorFillOption {optspec default} {
  option "$optspec" -default "$default" -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
}

snit::macro OvalWidgets::ColorOutlineOption {optspec default} {
  option "$optspec" -default "$default" -validatemethod _VerifyColor -configuremethod _ConfigureOutlineColor
}

snit::macro OvalWidgets::FontFamily {default} {
  method _ConfigureFontFamily {option value} {
    set options($option) $value
    set tag $selfns
    set height $options(-height)
    catch {$canvas itemconfigure ${tag}-fontfamily \
		-font [list "$options(-fontfamily)" \
			    -$_textHeight bold]}
  }
  option {-fontfamily fontFamily FontFamily} -default $default -configuremethod _ConfigureFontFamily
  variable _textHeight
}  

snit::macro OvalWidgets::SquareEndOptions {} {
  method _SquareEndConfigure {option value} {
    set options($option) $value
    set tag $selfns
    set ctype  [$canvas type ${tag}${option}]
    if {[string equal "$ctype" {}]} {return}
    if {$value && [string equal [$canvas type ${tag}${option}] rectangle]} {return}
    if {!$value && [string equal [$canvas type ${tag}${option}] arc]} {return}
    set coords [$canvas coords ${tag}${option}]
    $canvas delete ${tag}${option}
    switch -- $option {
      -leftsquare {set start 90}
      -rightsquare {set start 270}
    }
    if {$value} {
      $canvas create rectangle $coords \
				-outline {} \
				-fill "$options(-background)" \
				-tag [list $tag ${tag}${option} \
					   ${tag}-background] -width 0
    } else {
      $canvas create arc $coords \
				-outline {} -fill "$options(-background)" \
				-start $start -extent 180 -width 0 \
				-style pieslice -tag [list $tag \
							   ${tag}${option} \
							   ${tag}-background]
    }
  }
  option {-rightsquare rightSquare RightSquare} -default no -validatemethod _VerifyBoolean -configuremethod _SquareEndConfigure
  option {-leftsquare leftSquare LeftSquare} -default no -validatemethod _VerifyBoolean -configuremethod _SquareEndConfigure
}

namespace eval OvalWidgets {

  variable HBar "@[file join [file dirname [info script]] HBar.xbm]"
  variable VBar "@[file join [file dirname [info script]] VBar.xbm]"

  snit::type OvalButton {
    variable canvas
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    OvalWidgets::XYWH 200 40
    OvalWidgets::ColorFillOption -background white
    OvalWidgets::ColorFillOption -foreground black
    OvalWidgets::FontFamily Courier
    OvalWidgets::SquareEndOptions
    option -text -default {} -configuremethod _ConfigureText
    option -command -default {}
    constructor {_canvas args} {
      set canvas $_canvas
      $self configurelist $args
      set x $options(-x)
      set y $options(-y)
      set width $options(-width)
      set height $options(-height)
      set tag $selfns
      catch [list $canvas delete $tag]
      if {$options(-leftsquare)} {
	$canvas create rectangle $x $y \
				 [expr {$x + $height}] [expr {$y + $height}] \
				 -outline {} -fill "$options(-background)" \
				 -tag [list $tag ${tag}-leftsquare \
					    ${tag}-background] -width 0
      } else {
	$canvas create arc $x $y [expr {$x + $height}] [expr {$y + $height}] \
		-outline {} -fill "$options(-background)" \
		-start 90 -extent 180 -width 0 \
		-style pieslice -tag [list $tag ${tag}-leftsquare \
					   ${tag}-background]
      }
      set bbox [$canvas bbox ${tag}-leftsquare]
      set rleft [expr {[lindex $bbox 2] - 1}]
      set rtop  [lindex $bbox 1]
      set rbot  [lindex $bbox 3]
      set deltaL [expr $rleft - $x]
      set deltaR [expr {double($height) / 2.0}]
      set rright [expr {$rleft + ($width - ($deltaL + $deltaR))}]
      $canvas create rect $rleft $rtop $rright $rbot \
		      -outline {} -fill "$options(-background)" \
		      -tag [list $tag ${tag}-background ${tag}-main] -width 0
      set bbox [$canvas bbox ${tag}-main]
      set otop  [lindex $bbox 1]
      set obot  [lindex $bbox 3]
      set oleft [expr {[lindex $bbox 2] - ($obot - $otop) / 2.0 - 1}]
      set oright [expr {$oleft + ($obot - $otop) + 1}]
      if {$options(-rightsquare)} {
	$canvas create rectangle $oleft $otop $oright $obot \
			-outline {} -fill "$options(-background)" \
			-tag [list $tag ${tag}-background ${tag}-rightsquare] \
			-width 0
      } else {
	$canvas create arc $oleft $otop $oright $obot \
			   -outline {} -fill "$options(-background)" \
			   -start 270 -extent 180 \
			   -style pieslice -width 0 \
			   -tag [list $tag ${tag}-background ${tag}-rightsquare]
      }
      set _textHeight [expr {int(ceil($height * .8))}]
      $canvas create text [expr {$x + (double($width) / 2.0)}] \
		      [expr {$y + ($height * .1)}] \
		      -anchor n -text "$options(-text)" \
		      -fill "$options(-foreground)" \
		      -font [list "$options(-fontfamily)" \
				  -$_textHeight bold] \
		      -tag [list $tag ${tag}Text ${tag}-foreground \
				      ${tag}-fontfamily]
      $canvas bind $tag <1> [mymethod invoke]
    }
    method invoke {} {
      set command "$options(-command)"
      if {[string length "$command"] > 0} {uplevel #0 "$command"}
    }
    method _ConfigureText {option value} {
      set options($option) "$value"
      set tag $selfns
      catch {$canvas itemconfigure ${tag}Text -text "$value"}
    }
    destructor {
      catch {$canvas delete $selfns}
    }
  }  
  snit::type OvalSrollBar {
    variable canvas
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    OvalWidgets::ColorFillOption -background white
    OvalWidgets::ColorFillOption -foreground black
    method _ConfigureXY {option value} {
      set oldx $options(-x)
      set oldy $options(-y)
      set options($option) $value
      set dx [expr {$oldx - $options(-x)}]
      set dy [expr {$oldy - $options(-y)}]
      $canvas move $selfns $dx $dy
    }
    option -x -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    option -y -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    method _ConfigureWL {option value} {
      set oldWidth $options(-width)
      set oldLength $options(-length)
      set options($option) $value
      set scalew [expr {double($options(-width)) / double($oldWidth)}]
      set scalel [expr {double($options(-length)) / double($oldLength)}]
      switch $options(-orientation) {
	horizontal {
	  $canvas scale $selfns $options(-x) $options(-y) $scalel $scalew
	}
	vertical {
	  $canvas scale $selfns $options(-x) $options(-y) $scalew $scalel
	}
      }
    }
    option -width -default 40 -validatemethod _VerifyDouble -configuremethod _ConfigureWL  
    option -length -default 100 -validatemethod _VerifyDouble -configuremethod _ConfigureWL  
    GRSupport::VerifyOrientationHVMethod
    option -orientation -default vertical -validatemethod _VerifyOrientationHV -readonly yes
    option -command -default {}
    variable canvas
    constructor {_canvas args} {
      set canvas $_canvas
      $self configurelist $args
      set x $options(-x)
      set y $options(-y)
      set width $options(-width)
      set length $options(-length)
      set orientation $options(-orientation)
      set tag $selfns
      catch [list $canvas delete $tag]
      switch -exact -- "$orientation" {
	vertical {
	  array set baseRect \
		[list x1 $x y1 $y x2 [expr {$x + $width}] y2 [expr {$y + $length}]]
	  array set initThumb \
		[list x1 $x \
		      y1 [expr {$y + (double($length) / 2.0) - (double($width) / 2.0)}] \
		      x2 [expr {$x + $width}] \
		      y2 [expr {$y + (double($length) / 2.0) + (double($width) / 2.0)}]]

	}
	horizontal {
	      array set baseRect \
		[list x1 $x y1 $y x2 [expr {$x + $length}] y2 [expr {$y + $width}]]
	      array set initThumb \
		[list x1 [expr {$x + (double($length) / 2.0) - (double($width) / 2.0)}] \
		      y1 $y \
		      x2 [expr {$x + (double($length) / 2.0) + (double($width) / 2.0)}] \
		      y2 [expr {$y + $width}]]
	
	}
      }
      $canvas create rect $baseRect(x1) $baseRect(y1) \
			$baseRect(x2) $baseRect(y2) \
			-fill "$options(-background)" -outline {} -width 0\
			-tag [list $tag ${tag}BaseRect ${tag}-background]
      $canvas create oval $initThumb(x1) $initThumb(y1) \
			$initThumb(x2) $initThumb(y2) \
			-fill "$options(-foreground)" -outline {} -width 0\
			-tag [list $tag ${tag}Thumb ${tag}-foreground]
      $canvas bind ${tag}Thumb <Button1-Motion> [mymethod _MoveThumb %x %y]
      $canvas bind ${tag}BaseRect <1> [mymethod _BaseRect %x %y]
      $self _Command moveto .5
    }
    destructor {
      catch {$canvas delete $selfns}
    }
    method _MoveThumb {mx my} {
      set orientation $options(-orientation)
      set tag $selfns
      set width $options(-width)
      set half_width [expr {double($width) / 2.0}]
      set cx [$canvas canvasx $mx]
      set cy [$canvas canvasy $my]

      set current [$canvas coords ${tag}Thumb]
      set max     [$canvas coords ${tag}BaseRect]
      set oldCenterX [expr {double([lindex $current 0] + [lindex $current 2]) / 2.0}]
      set oldCenterY [expr {double([lindex $current 1] + [lindex $current 3]) / 2.0}]
#  puts stderr "*** oldCenterX = $oldCenterX, oldCenterY = $oldCenterY"
      switch -exact -- "$orientation" {
	vertical {
	  set miny [expr {[lindex $max 1] + $half_width}]
	  set maxy [expr {[lindex $max 3] - $half_width}]

#      puts stderr "*** max = $max, miny = $miny, maxy = $maxy"

	  if {[expr {$cy - $half_width}] < $miny} {set cy $miny}
	  if {[expr {$cy + $half_width}] > $maxy} {set cy $maxy}

#      puts stderr "*** cy = $cy"

	  set oldFract [expr {double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)}]
	  set fraction [expr {double($cy - $miny) / double(($maxy - $miny) + 1.0)}]

#      puts stderr "*** oldFract = $oldFract, fraction = $fraction"

	  $canvas coords ${tag}Thumb [lindex $current 0] \
				     [expr {$cy - $half_width}] \
				     [lindex $current 2] \
				     [expr {$cy + $half_width}]
	}
	horizontal {
	  set minx [expr {[lindex $max 0] + $half_width}]
	  set maxx [expr {[lindex $max 2] - $half_width}]

	  if {[expr $cx - {$half_width}] < $minx} {set cx $minx}
	  if {[exor $cx + {$halt_width}] > $maxx} {set cx $maxx}
      
	  set oldFract [expr {double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)}]
	  set fraction [expr {double($cx - $minx) / double(($maxx - $minx) + 1.0)}]

	  $canvas coords ${tag}Thumb [expr {$cx - $half_width}] \
				     [lindex $current 1] \
				     [expr {$cx + $half_width}] \
				     [lindex $current 3]
	}
      }

      if {[expr {abs($oldFract - $fraction)}] < .00001} {return}
      $self _Command moveto $fraction  
    }
    method _BaseRect {mx my} {
#  puts stderr "*** OvalSrollBar_BaseRect $name $mx $my"
      set orientation $options(-orientation)
      set tag $selfns

      set cx [$canvas canvasx $mx]
      set cy [$canvas canvasy $my]
      set current [$canvas coords ${tag}Thumb]
      set dir 0
      switch -exact -- "$orientation" {
	vertical {
	  set miny [lindex $current 1]
	  set maxy [lindex $current 3]

	  if {$cy < $miny} {set dir -1}
	  if {$cy > $maxy} {set dir +1}
      
	}
	horizontal {
	  set minx [lindex $current 0]
	  set maxx [lindex $current 2]

	  if {$cx < $minx} {set dir -1}
	  if {$cx > $maxx} {set dir +1}
      
	}
      }

      if {$dir != 0} {$self _Command scroll $dir pages}
    }
    method _Command {args} {
      set tag $selfns
      if {[string length "$options(-command)"] > 0} {
	uplevel #0 "$options(-command) $args"
      }
    }
    method resize {newMin newMax} {
      set orientation $options(-orientation)
      set tag $selfns
      set width $options(-width)
      set length $options(-length)

      set current [$canvas coords ${tag}Thumb]
      set oldCenterX [expr {double([lindex $current 0] + [lindex $current 2]) / 2.0}]
      set oldCenterY [expr {double([lindex $current 1] + [lindex $current 3]) / 2.0}]
      set max     [$canvas coords ${tag}BaseRect]
      switch -exact -- "$orientation" {
	vertical {
	  set miny [expr {[lindex $max 1] + $half_width}]
	  set maxy [expr {[lindex $max 3] - $half_width}]
	  set fraction [expr {double($oldCenterY - $miny) / double($maxy - $miny)}]
	  $canvas coords ${tag}BaseRect [lindex $max 0] $newMin \
      				    [lindex $max 2] $newMax
	  set $options(-length) [expr {$newMax - $newMin}]
	}
	horizontal {
	  set minx [expr {[lindex $max 0] + $half_width}]
	  set maxx [expr {[lindex $max 2] - $half_width}]
	  set fraction [expr {double($oldCenterX - $minx) / double($maxx - $minx)}]
	  $canvas coords ${tag}BaseRect $newMin [lindex $max 1] \
				    $newMax [lindex $max 3]
	  set $options(-length) [expr {$newMax - $newMin}]
	}
      }
      $self _Command moveto $fraction
    }
    method delta {deltaX deltaY} {
      set orientation $options(-orientation)
      set tag $selfns
      set length $options(-length)
      set width $options(-width)
      set ll [expr {$length - $width}]
      switch -exact -- "$orientation" {
	vertical {
	  return [expr {double($deltaY) / $ll}]
	}
	horizontal {
	  return [expr {double($deltaX) / $ll}]
	}
      }	
    }
    method fraction {x y} {
      set orientation $options(-orientation)
      set tag $selfns
      set length $options(-length)
      set width $options(-width)
      set ll [expr {$length - $width}]
      switch -exact -- "$orientation" {
	vertical {
	  if {$y < 0} {set y 0}
	  if {$y > $ll} {set y $ll}
	  return [expr {double($y) / $ll}]
	}
	horizontal {
	  if {$x < 0} {set x 0}
	  if {$x > $ll} {set x $ll}
	  return [expr {double($x) / $ll}]
	}
      }	
    }
    variable _lastSet {0.0 1.0}
    method get {} {
      return $_lastSet
    }
    method identify {x y} {
      set tag $selfns
      set bbox [$canvas bbox $tag]
      set xx [expr {$x + [lindex $bbox 0]}]
      set yy [expr {$y + [lindex $bbox 1]}]
      if {$xx < [lindex $bbox 0] || $xx > [lindex $bbox 2]} {return {}}
      if {$yy < [lindex $bbox 1] || $yy > [lindex $bbox 3]} {return {}}
      set item [$canvas find closest $xx $yy]
      set tags [$canvas gettags $item]
      if {[lsearch -exact $tags ${tag}Thumb] >= 0} {return Thumb}
      if {[lsearch -exact $tags ${tag}BaseRect >= 0} {return Trough}
      return {}
    }
    method set {first last} {
      set orientation $options(-orientation)
      set tag $selfns
      set width $options(-width)
      set length $options(-length)

      set half_width [expr double($width) / 2.0]

#  set fraction [expr double($first + $last) / 2.0]
      set fraction $first
#  puts stderr "*** fraction = $fraction"

      set current [$canvas coords ${tag}Thumb]
#  puts stderr "*** current = $current"
      set oldCenterX [expr {double([lindex $current 0] + [lindex $current 2]) / 2.0}]
      set oldCenterY [expr {double([lindex $current 1] + [lindex $current 3]) / 2.0}]
#  puts stderr "*** oldCenterX = $oldCenterX, oldCenterY = $oldCenterY"
      set max     [$canvas coords ${tag}BaseRect]
#  puts stderr "*** max = $max"
      switch -exact -- "$orientation" {
	vertical {
	  set miny [expr {[lindex $max 1] + $half_width}]
	  set maxy [expr {[lindex $max 3] - $half_width}]
	  set newposO [expr {double(($maxy - $miny) + 1.0) * $fraction}]
#  puts stderr "*** newposO = $newposO"
	  set oldFract [expr {double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)}]
#      puts stderr "*** oldFract = $oldFract"
	  $canvas coords ${tag}Thumb [lindex $current 0] \
				 [expr {$miny + $newposO - $half_width}] \
				 [lindex $current 2] \
				 [expr {$miny + $newposO + $half_width}]
	}
	horizontal {
	  set minx [expr {[lindex $max 0] + $half_width}]
	  set maxx [expr {[lindex $max 2] - $half_width}]
	  set newposO [expr {double(($maxx - $minx) + 1.0) * $fraction}]
	  set oldFract [expr {double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)}]
	  $canvas coords ${tag}Thumb [expr {$minx + $newposO - $half_width}] \
				 [lindex $current 1] \
				 [expr {$minx + $newposO + $half_width}] \
				 [lindex $current 3] 
	}
      }
      set _lastSet [list $first $last]
#  puts stderr "*** oldFract = $oldFract, fraction = $fraction"
      if {[expr {abs($oldFract - $fraction)}] < .001} {return}
      $self _Command moveto $fraction  
    }
  }
  snit::type OvalScale {
    variable canvas
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    OvalWidgets::ColorFillOption -background white
    OvalWidgets::ColorFillOption -foreground black
    method _ConfigureXY {option value} {
      set oldx $options(-x)
      set oldy $options(-y)
      set options($option) $value
      set dx [expr {$oldx - $options(-x)}]
      set dy [expr {$oldy - $options(-y)}]
      $canvas move $selfns $dx $dy
    }
    option -x -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    option -y -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    method _ConfigureWL {option value} {
      set oldWidth $options(-width)
      set oldLength $options(-length)
      set options($option) $value
      set scalew [expr {double($options(-width)) / double($oldWidth)}]
      set scalel [expr {double($options(-length)) / double($oldLength)}]
      switch $options(-orientation) {
	horizontal {
	  $canvas scale $selfns $options(-x) $options(-y) $scalel $scalew
	}
	vertical {
	  $canvas scale $selfns $options(-x) $options(-y) $scalew $scalel
	}
      }
    }
    option -width -default 40 -validatemethod _VerifyDouble -configuremethod _ConfigureWL  
    option -length -default 100 -validatemethod _VerifyDouble -configuremethod _ConfigureWL  
    GRSupport::VerifyOrientationHVMethod
    option -orientation -default horizontal -validatemethod _VerifyOrientationHV -readonly yes
    option -command -default {}
    option -from -default   0 -validatemethod _VerifyDouble -readonly yes
    option -to   -default 100 -validatemethod _VerifyDouble -readonly yes
    option -digits -default 2 -validatemethod _VerifyInteger -readonly yes
    OvalWidgets::FontFamily Courier
    option -text -default {} -configuremethod _ConfigureText
    method _ConfigureText {option value} {
      set options($option) "$value"
      set tag $selfns
      catch {$canvas itemconfigure ${tag}Text -text "$value"}
    }
    option {-showvalue showValue ShowValue} -default yes -validatecommand _VerifyBoolean -readonly yes
    option -variable -default {}
    option {-bigincrement bigIncrement BigIncrement} -default 0 --validatecommand _VerifyDouble -readonly yes
    variable canvas
    variable _textHeight
    variable _value 0
    constructor {_canvas args} {
      set canvas $args
      $self configurelist $args
      set x $options(-x)
      set y $options(-y)
      set width $options(-width)
      set length $options(-length)
      set orientation $options(-orientation)
      set tag $selfns

      catch [list $canvas delete $tag]
      set _textHeight [expr {int(ceil($width * .5))}]
      set lfont [list "$options(-fontfamily)" -$_textHeight bold]
      switch -exact -- "$orientation" {
	vertical {
	  set lid [$canvas create text 0 0 -anchor nw -text "$options(-text)" \
		-font $lfont]
	  set lbbox [$canvas bbox $lid]
	  $canvas delete $lid
	  if {$options(-showvalue)} {
	    set vid [$canvas create text 0 0 -anchor nw \
			-text [format "%$options(-digits)f" 0] \
			-font $lfont]
	    set vbox [$canvas bbox $vid]
	    $canvas delete $vid
	  } else {
	    set vbox [list 0 0 0 0]
	  }
	  set brx [expr {$x + [lindex $vbox 2]}]
	  array set valuePos [list x $x y $y]
	  array set baseRect \
		[list x1 [expr {$x + $brx}] y1 $y \
		      x2 [expr {$x + $brx + $width}] y2 [expr {$y + $length}]]
	  array set initThumb \
		[list x1 [expt {$x + $brx}] \
		      y1 [expr {$y + (double($length) / 2.0) - (double($width) / 2.0)}] \
		      x2 [expr {$x + $brx + $width}] \
		      y2 [expr {$y + (double($length) / 2.0) + (double($width) / 2.0)}]]
	  array set labelPos [list x [expr {$brx + $width}] y $y]
	}
	horizontal {
	  set lid [$canvas create text 0 0 -anchor nw -text "$options(-text)" \
		-font $lfont]
	  set lbbox [$canvas bbox $lid]
#      puts stderr "*** OvalScale_Create: lbbox = $lbbox"
	  $canvas delete $lid
	  if {$options(-showvalue)} {
	    set vid [$canvas create text 0 0 -anchor nw -text [format "%$options(-digits)d" 0] \
		-font $lfont]
	    set vbox [$canvas bbox $vid]
	    $canvas delete $vid
	  } else {
	    set vbox [list 0 0 0 0]
	  }
	  array set labelPos [list x $x y $y]
#      puts stderr "*** OvalScale_Create: labelPos = [array get labelPos]"
	  array set valuePos [list x $x y [expr {$y + [lindex $lbbox 3]}]]
	  set bry [expr [lindex $lbbox 3] + [lindex $vbox 3]]
	  array set baseRect \
		[list x1 $x y1 [expr {$y + $bry}] x2 [expr {$x + $length}] y2 [expr {$y + $bry + $width}]]
	  array set initThumb \
		[list x1 [expr {$x + (double($length) / 2.0) - (double($width) / 2.0)}] \
	      y1 [expr {$y + $bry}] \
	      x2 [expr {$x + (double($length) / 1.0) + (double($width) / 2.0)}] \
	      y2 [expr {$y + $bry + $width}]]

	}
      }
      if {$options(-bigincrement) == 0} {
	set options(-bigincrement) [expr {.1 * ($options(-to) - $options(-from))}]
      }
#  puts stderr "*** OvalScale_Create: baseRect = [array get baseRect], initThumb = [array get initThumb]"
      $canvas create rect $baseRect(x1) $baseRect(y1) $baseRect(x2) $baseRect(y2) \
	-fill "$options(-background)" -outline {} \
	-tag [list $tag ${tag}BaseRect ${tag}-background]
      $canvas create oval $initThumb(x1) $initThumb(y1) $initThumb(x2) $initThumb(y2) \
	-fill "$options(-foreground)" -outline {} \
	-tag [list $tag ${tag}Thumb ${tag}-foreground]
      $canvas create text $labelPos(x) $labelPos(y) -anchor nw -text "$options(-text)" \
			-fill "$options(-foreground)" \
			-font $lfont -tag [list $tag ${tag}Label \
						${tag}-foreground \
						${tag}-fontfamily]
      }
      if {$options(-showvalue)} {
	$canvas create text $valuePos(x) $valuePos(y) -anchor nw \
		-text [format "%$options(-digits)f" 0] \
		-fill "$options(-foreground)" \
		-font $lfont -tag [list $tag ${tag}Value ${tag}-foreground ${tag}-fontfamily]
      }

      $canvas bind ${tag}Thumb <Button1-Motion> [mymethod _MoveThumb %x %y]
      $canvas bind ${tag}BaseRect <1> [mymethod _BaseRect %x %y]

      $self set $options(-from)

    }
    destructor {
      catch {$canvas delete $selfns}
    }
    method set {value} {
      set tag $selfns
      set orientation $options(-orientation)
      set width $options(-width)
      set length $options(-length)

      if {$options(-from) < $options(-to)} {
	if {$value < $options(-from)} {set value $options(-from)}
	if {$value > $options(-to)} {set value $options(-to)}
	set fraction [expr {double($value - $options(-from)) / double($options(-to) - $options(-from))}]
      } else {
	if {$value > $options(-from)} {set value $options(-from)}
	if {$value < $options(-to)} {set value $options(-to)}
	set fraction [expr {1.0 - double($value - $options(-to)) / double($options(-from) - $options(-to))}]
      }
      set _value $value
      if {[string length "$options(-variable)"] > 0} {
	upvar #0 $options(-variable) v
	set v $value
      }
      if {[string length "$options(-command)"] > 0} {
	uplevel #0 "$options(-command) $value"
      }
      if {$options(-showvalue)} {
	$canvas itemconfigure ${tag}Value -text [format "%$options(-digits)f" $value]
      }
      set half_width [expr {double($width) / 2.0}]

      set current [$canvas coords ${tag}Thumb]
      set oldCenterX [expr {double([lindex $current 0] + [lindex $current 2]) / 2.0}]
      set oldCenterY [expr {double([lindex $current 1] + [lindex $current 3]) / 2.0}]
      set max     [$canvas coords ${tag}BaseRect]
      switch -exact -- "$orientation" {
	vertical {
	  set miny [expr {[lindex $max 1] + $half_width}]
	  set maxy [expr {[lindex $max 3] - $half_width}]
	  set newposO [expr {double(($maxy - $miny) + 1.0) * $fraction}]
#  puts stderr "*** newposO = $newposO"
	  set oldFract [expr {double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)}]
#      puts stderr "*** oldFract = $oldFract"
	  $canvas coords ${tag}Thumb [lindex $current 0] \
				 [expr {$miny + $newposO - $half_width}] \
				 [lindex $current 2] \
				 [expr {$miny + $newposO + $half_width}]
	}
	horizontal {
	  set minx [expr {[lindex $max 0] + $half_width}]
	  set maxx [expr {[lindex $max 2] - $half_width}]
	  set newposO [expr {double(($maxx - $minx) + 1.0) * $fraction}]
	  set oldFract [expr {double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)}]
	  $canvas coords ${tag}Thumb [expr {$minx + $newposO - $half_width}] \
				 [lindex $current 1] \
				 [expr {$minx + $newposO + $half_width}] \
				 [lindex $current 3] 
	}
      }
    }
    method get {} {
      return $_value
    }
    method _MoveThumb {mx my} {
      set orientation $options(-orientation)
      set tag $selfns
      set width $options(-width)
      set half_width [expr {double($width) / 2.0}]
#  puts stderr "*** half_width = $half_width"

      set cx [$canvas canvasx $mx]
      set cy [$canvas canvasy $my]

      set current [$canvas coords ${tag}Thumb]
      set max     [$canvas coords ${tag}BaseRect]
      set oldCenterX [expr {double([lindex $current 0] + [lindex $current 2]) / 2.0}]
      set oldCenterY [expr {double([lindex $current 1] + [lindex $current 3]) / 2.0}]
#  puts stderr "*** oldCenterX = $oldCenterX, oldCenterY = $oldCenterY"
      switch -exact -- "$orientation" {
	vertical {
	  set miny [expr {[lindex $max 1] + $half_width}]
	  set maxy [expr {[lindex $max 3] - $half_width}]

#      puts stderr "*** max = $max, miny = $miny, maxy = $maxy"

	  if {[expr {$cy - $half_width}] < $miny} {set cy $miny}
	  if {[expr {$cy + $half_width}] > $maxy} {set cy $maxy}

#      puts stderr "*** cy = $cy"

	  set oldFract [expr {double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)}]
	  set fraction [expr {double($cy - $miny) / double(($maxy - $miny) + 1.0)}]

#      puts stderr "*** oldFract = $oldFract, fraction = $fraction"

	  $canvas coords ${tag}Thumb [lindex $current 0] [expr {$cy - $half_width}] \
				 [lindex $current 2] [expr {$cy + $half_width}]
	}
	horizontal {
	  set minx [expr {[lindex $max 0] + $half_width}]
	  set maxx [expr {[lindex $max 2] - $half_width}]

	  if {[expr {$cx - $half_width}] < $minx} {set cx $minx}
	  if {[exor {$cx + $halt_width}] > $maxx} {set cx $maxx}
      
	  set oldFract [expr {double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)}]
	  set fraction [expr {double($cx - $minx) / double(($maxx - $minx) + 1.0)}]

	  $canvas coords ${tag}Thumb [expr {$cx - $half_width}] [lindex $current 1] \
				 [expr {$cx + $half_width}] [lindex $current 3] 
	}
      }

      if {[expr {abs($oldFract - $fraction)}] < .00001} {return}
      set newVal [expr {$options(-from) + ( ($options(-to) - $options(-from)) * $fraction )}]  
      $self set $newVal
    }
    method _BaseRect {mx my} {
      set orientation $options(-orientation)
      set tag $selfns

      set cx [$canvas canvasx $mx]
      set cy [$canvas canvasy $my]
      set current [$canvas coords ${tag}Thumb]
      set dir 0
      switch -exact -- "$orientation" {
	vertical {
	  set miny [lindex $current 1]
	  set maxy [lindex $current 3]

	  if {$cy < $miny} {set dir -1}
	  if {$cy > $maxy} {set dir +1}
      
	}
	horizontal {
	  set minx [lindex $current 0]
	  set maxx [lindex $current 2]

	  if {$cx < $minx} {set dir -1}
	  if {$cx > $maxx} {set dir +1}
      
	}
      }

      if {$dir != 0} {
        $self set [expr {$options(value) + ($dir * $options(-bigincrement))}]
      }
    }
  }
  snit::type OvalSlider {
  }
  snit::type OvalRoundCornerRectangle {
  }
  snit::type OvalLabel {
  }



}


package provide OvalWidgets 2.0

