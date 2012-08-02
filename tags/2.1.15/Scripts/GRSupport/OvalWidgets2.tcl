#* 
#* ------------------------------------------------------------------
#* OvalWidget2.tcl - Oval Widgets Version 2
#* Created by Robert Heller on Fri Jan 26 10:52:40 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
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

#@Chapter:OvalWidgets2.tcl -- Oval Widgets code (snit version).
#$Id$
# These oval shaped widgets are much like the Star Trek NG computer screens.

namespace eval OvalWidgets {
# Namespace where these widgets reside.
# [index] OvalWidgets!namespace
}

snit::macro OvalWidgets::XYWH {width height} {
# Defines the options for position (-x,-y) and size (-width,-height).
# <in> width Default width.
# <in> height Default height.
# [index] OvalWidgets::XYWH!macro

  method _ConfigureXY {option value} {
  # Method to configure an x or y coordinate.
  # <in> option The name of the option to configure.
  # <in> value The value of the option.
  
    set oldx $options(-x)
    set oldy $options(-y)
    set options($option) $value
    set dx [expr {$oldx - $options(-x)}]
    set dy [expr {$oldy - $options(-y)}]
    $canvas move $selfns $dx $dy
  }
  method _ConfigureWH {option value} {
  # Method to configure a width or height option.
  # <in> option The name of the option to configure.
  # <in> value The value of the option.
  
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
# Snit macro to default color option methods.
# [index] OvalWidgets::ColorOptionMethods!macro

  method _ConfigureFillColor {option value} {
  # Method to configure a fill color.
  # <in> option The name of the option to configure.
  # <in> value The value of the option.

    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -fill "$value"}
  }
  method _ConfigureOutlineColor {option value} {
  # Method to configure an outline color.
  # <in> option The name of the option to configure.
  # <in> value The value of the option.

    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -outline "$value"}
  }
}

snit::macro OvalWidgets::CommonValidateMethods {} {
# Macro to include the common validation methods.
# [index] OvalWidgets::CommonValidateMethods!macro

  GRSupport::VerifyDoubleMethod
  GRSupport::VerifyIntegerMethod
  GRSupport::VerifyColorMethod
  GRSupport::VerifyBooleanMethod
}

snit::macro OvalWidgets::ColorFillOption {optspec default} {
# Method to define a fill color option.
# <in> optspec The option specification
# <in> default The default value.
# [index] OvalWidgets::ColorFillOption!macro

  option "$optspec" -default "$default" -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
}

snit::macro OvalWidgets::ColorOutlineOption {optspec default} {
# Method to define an outline color option.
# <in> optspec The option specification
# <in> default The default value.
# [index] OvalWidgets::ColorOutlineOption!macro

  option "$optspec" -default "$default" -validatemethod _VerifyColor -configuremethod _ConfigureOutlineColor
}

snit::macro OvalWidgets::FontFamily {default} {
# Macro to define the -fontfamily option.
# <in> default The default font family.
# [index] OvalWidgets::FontFamily!macro

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
# Macro  to define the square end options (-rightsquare, -leftsquare).
# [index] OvalWidgets::SquareEndOptions!macro

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
# Namespace for oval widgets
# [index] OvalWidgets!namespace

  variable HBar 
  # Holds the horizontal bar bitmap.

  set HBar "@[file join [file dirname [info script]] HBar.xbm]"

  variable VBar 
  # Holds the vertical bar bitmap.

  set VBar "@[file join [file dirname [info script]] VBar.xbm]"

  snit::type OvalButton {
  # Oval button.  Works just like a normal button widget.
  # <option> -x The X coordinate (default 0).
  # <option> -y The Y coordinate (default 0).
  # <option> -width The width of the button (default 200).
  # <option> -height The height of the button (default 40).
  # <option> -background The background color (default white).
  # <option> -foreground The foreground color (default black).
  # <option> -fontfamily The font family (default Courier).
  # <option> -rightsquare Should the right end be square (default no)?
  # <option> -leftsquare Should the left end be square (default no)?
  # <option> -text The text of the button (default {}).
  # <option> -command The command of the button (default {}).
  # [index] OvalWidgets::OvalButton!snit type

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
    # Construct an oval button.
    # <in> _canvas The canvas to draw the button on.
    # <in> args The option value list.

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
      set deltaL [expr {$rleft - $x}]
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
    # Method for invoking the button.

      set command "$options(-command)"
      if {[string length "$command"] > 0} {uplevel #0 "$command"}
    }
    method _ConfigureText {option value} {
    # Method to configure the text of the button.
    # <in> option The name of the option to configure.
    # <in> value The value to configure it to.

      set options($option) "$value"
      set tag $selfns
      catch {$canvas itemconfigure ${tag}Text -text "$value"}
    }
    destructor {
    # Destructor, free up all resources.

      catch {$canvas delete $selfns}
    }
  }  
  snit::type OvalSrollBar {
  # Oval SrollBar.  Works just like a normal scrollbar widget.
  # <option> -x The X coordinate (default 0).
  # <option> -y The Y coordinate (default 0).
  # <option> -width The width of the scrollbar (default 40).
  # <option> -length The length of the scrollbar (default 100).
  # <option> -background The background color (default white).
  # <option> -foreground The background color (default black).
  # <option> -orientation The orientation of the scrollbar, horizontal or 
  #			vertical (readonly, default vertical).
  # <option> -command The command of the scrollbar (default {}).
  # [index] OvalWidgets::OvalSrollBar!snit type

    variable canvas
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    OvalWidgets::ColorFillOption -background white
    OvalWidgets::ColorFillOption -foreground black
    method _ConfigureXY {option value} {
    # Method to configure an x or y coordinate.
    # <in> option The name of the option to configure.
    # <in> value The value of the option.
  
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
    # Method to configure a width or length option.
    # <in> option The name of the option to configure.
    # <in> value The value of the option.
  
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
    constructor {_canvas args} {
    # Constructor -- initialize and build an Oval Scrollbar.
    # <in> _canvas The canvas to draw the scrollbar on.
    # <in> args The option value list.

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
    # Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
    method _MoveThumb {mx my} {
    # Method bound to button1 motion -- move the thumb.
    # <in> mx -- Mouse X coordinate.
    # <in> my -- Mouse Y coordinate.

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

	  if {[expr {$cx - $half_width}] < $minx} {set cx $minx}
	  if {[expr {$cx + $half_width}] > $maxx} {set cx $maxx}
      
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
    # Method bound to button 1 presses
    # <in> mx -- Mouse X coordinate.
    # <in> my -- Mouse Y coordinate.

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
    # Method used to invoke the command as the thumb is moved.
    # <in> args -- passed to -command option.

      set tag $selfns
      if {[string length "$options(-command)"] > 0} {
	uplevel #0 "$options(-command) $args"
      }
    }
    method resize {newMin newMax} {
    # Resize method.  Method update the range of the scroll region.
    # <in> newMin -- new minimum of the scroll region.
    # <in> newMax -- new maximum of the scroll region.

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
    # Method to return a real number indicating the fractional change in  the
    # scrollbar  setting that corresponds to a given change in slider position.
    # For example, if the  scrollbar  is  horizontal,  the result  indicates 
    # how much the scrollbar setting must change to move the slider deltaX 
    # pixels to the right (deltaY  is  ignored in  this case).  If the 
    # scrollbar is vertical, the result indicates how much the scrollbar 
    # setting must change  to  move  the slider deltaY pixels down.  The 
    # arguments and the result may be zero or negative.
    # <in> deltaX -- Amount of movement if scrollbar  is  horizontal.
    # <in> deltaY -- Amount of movement if scrollbar  is  vertical.

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
    # Method to return a real number between 0  and  1  indicating  where  the
    # point  given  by x and y lies in the trough area of the scrollbar.  The 
    # value 0 corresponds to the top or left of the trough, the value 1 
    # corresponds to the bottom or right, 0.5 corresponds to the middle, and 
    # so on.  X and y must  be  pixel  coordinates relative  to the scrollbar 
    # widget.  If x and y refer to a point outside the trough, the closest 
    # point in the trough is used.
    # <in> x -- The X coordinate to check.
    # <in> y -- The Y coordinate to check.

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
    # Method to return the scrollbar settings in the form of a list whose 
    # elements  are the arguments to the most recent set widget command.

      return $_lastSet
    }
    method identify {x y} {
    # Method to return the name of the element under the point given by x  and
    # y  (such  as  arrow1), or an empty string if the point does not lie in 
    # any element of the scrollbar.  X and  y  must  be  pixel coordinates 
    # relative to the scrollbar widget.
    # <in> x -- The X coordinate to check.
    # <in> y -- The Y coordinate to check.

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
    # This method is invoked by the scrollbar’s associated widget to
    # tell the scrollbar about the current view in the  widget.   The
    # command  takes  two arguments, each of which is a real fraction
    # between 0 and 1.  The fractions describe the range of the document 
    # that is visible in the associated widget.  For example, if first is 
    # 0.2 and last is 0.4, it means that the first  part  of the  document  
    # visible  in the window is 20\% of the way through the document, and the 
    # last visible  part  is  40\%  of  the  way through.
    # <in> first -- First visible fraction.
    # <in> last -- Last visible fraction.

      set orientation $options(-orientation)
      set tag $selfns
      set width $options(-width)
      set length $options(-length)

      set half_width [expr {double($width) / 2.0}]

#  set fraction [expr {double($first + $last) / 2.0}]
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
  # An oval scale widget, much like a standard Tk scale widget.
  # <option> -x The X coordinate (default 0).
  # <option> -y The Y coordinate (default 0).
  # <option> -width The width of the scale (default 40).
  # <option> -length The length of the scale (default 100).
  # <option> -background The background color (default white).
  # <option> -foreground The background color (default black).
  # <option> -orientation The orientation of the scrollbar, horizontal or 
  #			vertical (readonly, default vertical).
  # <option> -from Start value of the scale (readonly, default 0).
  # <option> -to End value of the scale (readonly, defalut 100).
  # <option> -digits Number of digits to display (readonly, default 2).
  # <option> -text Scale label (default "").
  # <option> -showvalue Flag to indicate if the value should be displayed 
  #		(readonly, default yes).
  # <option> -variable Variable name to hold the value (default {}).
  # <option> -bigincrement Large increment value (readonly, default 0).
  # <option> -command The command of the scrollbar (default {}).
  # [index] OvalWidgets::OvalScale!snit type

    variable canvas
    variable _value 0
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    OvalWidgets::ColorFillOption -background white
    OvalWidgets::ColorFillOption -foreground black
    method _ConfigureXY {option value} {
    # Method to configure an x or y coordinate.
    # <in> option The name of the option to configure.
    # <in> value The value of the option.
  
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
    # Method to configure a width or length option.
    # <in> option The name of the option to configure.
    # <in> value The value of the option.
  
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
    # Method to configure the text of the button.
    # <in> option The name of the option to configure.
    # <in> value The value to configure it to.

      set options($option) "$value"
      set tag $selfns
      catch {$canvas itemconfigure ${tag}Text -text "$value"}
    }
    option {-showvalue showValue ShowValue} -default yes -validatemethod _VerifyBoolean -readonly yes
    option -variable -default {}
    option {-bigincrement bigIncrement BigIncrement} -default 0 -validatemethod _VerifyDouble -readonly yes
    constructor {_canvas args} {
    # Constructor -- initialize and build an Oval Scale.
    # <in> _canvas The canvas to draw the scrollbar on.
    # <in> args The option value list.

      set canvas $_canvas
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
#	  puts stderr "*** $type create $self (orientation is vertical)"
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
		      x2 [expr {$x + $brx + $width}] y2 [exprB {$y + $length}]]
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
#	  puts stderr "*** $type create $self (orientation is horizontal)"
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
#      puts stderr "*** $type create $self (not in switch?)"
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
    # Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
    method set {value} {
    # Method to set the value of the scale.
    # <in> value -- The value to set the scale to.

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
    # Method to get the value of the scale.

      return $_value
    }
    method _MoveThumb {mx my} {
    # Method bound to button1 motion -- move the thumb.
    # <in> mx -- Mouse X coordinate.
    # <in> my -- Mouse Y coordinate.

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
	  if {[expr {$cx + $half_width}] > $maxx} {set cx $maxx}
      
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
    # Method bound to button 1 presses
    # <in> mx -- Mouse X coordinate.
    # <in> my -- Mouse Y coordinate.

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
        $self set [expr {$_value + ($dir * $options(-bigincrement))}]
      }
    }
  }
  snit::type OvalSlider {
  # Oval Slider.  This is like the activation control for the Star Trek NG 
  # Transporter.
  # <option> -x The X coordinate (default 0).
  # <option> -y The Y coordinate (default 0).
  # <option> -width The width of the slider button (default 200).
  # <option> -height The height of the slider button (default 40).
  # <option> -length The length of the slider (default 600).
  # <option> -background The background color (default white).
  # <option> -foreground The background color (default black).
  # <option> -fontfamily The font family (default Courier).
  # <option> -rightsquare Should the right end be square (default no)?
  # <option> -leftsquare Should the left end be square (default no)?
  # <option> -text The text of the button (default {}).
  # <option> -command The command of the button (default {}).
  # <option> -from Start value of the scale (readonly, default 0).
  # <option> -to End value of the scale (readonly, defalut 100).
  # <option> -digits Number of digits to display (readonly, default 2).
  # <option> -showvalue Flag to indicate if the value should be displayed 
  #		(readonly, default yes).
  # <option> -variable Variable name to hold the value (default {}).
  # <option> -stipple Stipple bitmap to use (readonly, default HBar).
  # [index] OvalWidgets::OvalSlider!snit type

    variable canvas
    variable _value 0
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    OvalWidgets::XYWH 200 40
    method _ConfigureL {option value} {
    # Method to configure the length option.
    # <in> option The name of the option to configure.
    # <in> value The value of the option.

      set oldLength $options(-length)
      set options($option) $value
      set scalel [expr {double($options(-length)) / double($oldLength)}]
      $canvas scale $selfns $options(-x) $options(-y) 1.0 $scalel
    }
    option -length -default 600  -validatemethod _VerifyDouble -configuremethod _ConfigureL  
    OvalWidgets::ColorFillOption -background white
    OvalWidgets::ColorFillOption -foreground black
    OvalWidgets::FontFamily Courier
    OvalWidgets::SquareEndOptions
    method _ConfigureText {option value} {
    # Method to configure the text of the button.
    # <in> option The name of the option to configure.
    # <in> value The value to configure it to.

      set options($option) "$value"
      set tag $selfns
      catch {$canvas itemconfigure ${tag}Text -text "$value"}
    }
    option -text -default {} -configuremethod _ConfigureText
    option -command -default {}
    option -from -default   0 -validatemethod _VerifyDouble -readonly yes
    option -to   -default 100 -validatemethod _VerifyDouble -readonly yes
    option -digits -default 2 -validatemethod _VerifyInteger -readonly yes
    option {-showvalue showValue ShowValue} -default yes -validatemethod _VerifyBoolean -readonly yes
    option -variable -default {}
    option -stipple -default {} -readonly yes -validatemethod _VerifyBitmap
    method _VerifyBitmap {option value} {
    # Method to validate a bitmap option.
    # <in> option The name of the option to validate.
    # <in> value The value to validate.

      if {[catch {$canvas create bitmap 0 0 -bitmap "$value"} id]} {
	error "Expected a bitmap for option $option, got $value"
      } else {
	$canvas delete $id
	return $value
      }
    }
    constructor {_canvas args} {
    # Construct an oval button.
    # <in> _canvas The canvas to draw the button on.
    # <in> args The option value list.

      set canvas $_canvas
      $self configurelist $args
      set x $options(-x)
      set y $options(-y)
      set width $options(-width)
      set height $options(-height)
      set length $options(-length)
      set tag $selfns
      catch [list $canvas delete $tag]

      if {[string equal "$options(-stipple)" {}]} {
	set options(-stipple) $::OvalWidgets::HBar
      }
      if {$options(-showvalue)} {
	set _textHeight [expr {int(ceil($height * .35))}]
      } else {
	set _textHeight [expr {int(ceil($height * .8))}]
      }
      if {!$options(-leftsquare)} {
	$canvas create arc $x $y [expr {$x + $height}] [expr {$y + $height}] \
		-outline {} -fill "$options(-background)" -start 90 \
		-extent 180 -style pieslice -tag [list $tag ${tag}Thumb]
	set bbox [$canvas bbox $tag]
	set rleft [expr {[lindex $bbox 2] - 1}]
	set rtop  [lindex $bbox 1]
	set rbot  [lindex $bbox 3]
	set deltaL [expr {$rleft - $x}]
      } else {
	set rleft $x
	set rtop $y
	set rbot [expr {$y + $height}]
	set deltaL 0
      }
      if {!$options(-rightsquare)} {
	set deltaR [expr {double($height) / 2.0}]
	set rright [expr {$rleft + ($width - ($deltaL + $deltaR))}]
      } else {
	set rright [expr {$rleft + ($width - $deltaL)}]
      }
      $canvas create rect $rleft $rtop $rright $rbot \
		      -outline {} -fill "$options(-background)" \
		      -tag [list $tag ${tag}Thumb ${tag}ThumbRect] -width 0
      set bbox   [$canvas bbox $tag]
      set otop   [lindex $bbox 1]
      set obot   [lindex $bbox 3]
      set oleft  [expr {[lindex $bbox 2] - ($obot - $otop) / 2.0 - 1}]
      set oright [expr {$oleft + ($obot - $otop) + 1}]
      if {!$options(-rightsquare)} {
	$canvas create arc $oleft $otop $oright $obot \
		     -outline {} -fill "$options(-background)" -start 270 \
		     -extent 180 -style pieslice -tag [list $tag ${tag}Thumb] \
		     -width 0
      }
      $canvas create text [expr {$x + (double($width) / 2.0)}] \
		      [expr {$y + ($height * .1)}] \
		      -anchor n -text "$options(-text)" \
		      -fill "$options(-foreground)" \
		      -font [list "$options(-fontfamily)" -$_textHeight bold] \
		      -tag [list $tag ${tag}Text ${tag}Thumb]
      if {$options(-showvalue)} {
	$canvas create text [expr {$x + (double($width) / 2.0)}] \
		      [expr {$y + ($height * .5)}] \
		      -anchor n \
		      -text [format "%$options(-digits)f" $options(-to)] \
		      -fill "$options(-foreground)" \
		      -font [list "$options(-fontfamily)" -$_textHeight bold] \
		      -tag [list $tag ${tag}Value ${tag}Thumb]
      }
      set bot [lindex [$canvas bbox ${tag}Thumb] 3]
      $canvas create rect $x $bot [expr {$x + $width}] [expr {$bot + $length}] \
		-outline {} -fill "$options(-foreground)" \
		-stipple "$options(-stipple)" -tag [list $tag ${tag}Bar]
      $canvas create rect $x $bot [expr {$x + $width}] [expr {$bot + $length}] \
		-outline {} -fill {} \
		-tag [list $tag ${tag}BaseRect]
      $canvas lower ${tag}BaseRect ${tag}Thumb
      $canvas bind ${tag}Thumb <Button1-Motion> [mymethod _MoveThumb %x %y]
#  set thumbElts [$canvas find withtag ${tag}Thumb]
#  puts stderr "*** items with ${tag}Thumb tag: $thumbElts"
#  foreach thelts $thumbElts {
#    puts stderr "***   $thelts: [$canvas type $thelts] [$canvas coords $thelts]"
#  }
      $self set $options(-from)
    }
    method set {value} {
    # Method to set the value of the slider.
    # <in> value The value to set.

      set tag $selfns
      set width $options(-width)
      set height $options(-height)
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
	set v $_value
      }
      if {[string length "$options(-command)"] > 0} {
	uplevel #0 [list $options(-command) $_value]
      }
      if {$options(-showvalue)} {
	$canvas itemconfigure ${tag}Value -text [format "%$options(-digits)f" $_value]
      }
      set half_width [expr double($height) / 2.0]

      set current [$canvas coords ${tag}ThumbRect]
#  puts stderr "*** current = $current"
##  set oldCenterX [expr double([lindex $current 0] + [lindex $current 2]) / 2.0]
      set oldCenterY [lindex $current 3]
      set max     [$canvas coords ${tag}BaseRect]
#  puts stderr "*** max = $max"
      set miny [lindex $max 1]
      set maxy [lindex $max 3]
      set newposO [expr {double(($maxy - $miny) + 1.0) * $fraction}]
#  puts stderr "*** newposO = $newposO"
      set oldFract [expr {double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)}]
#  puts stderr "*** oldFract = $oldFract"
      $canvas move ${tag}Thumb 0 [expr {($miny + $newposO) - $oldCenterY}]
      set bot [lindex [$canvas bbox ${tag}Thumb] 3]
      set BarCoords [$canvas coords ${tag}Bar]
      $canvas coords ${tag}Bar [list [lindex $BarCoords 0] $bot [lindex $BarCoords 2] [lindex $BarCoords 3]]  
    }
    method get {} {
    # Method to get  the current value.

      return $_value
    }
    method _MoveThumb {mx my} {
    # Method bound to  the button 1 motion on the thumb.
    # <in> mx Mouse X value.
    # <in> my Mouse Y value.

#  puts stderr "*** OvalSlider_MoveThumb $name $mx $my"
      set tag $selfns
      set width $options(-width)
      set height $options(-height)
      set half_width [expr double($height) / 2.0]
#  puts stderr "*** half_width = $half_width"

      set cx [$canvas canvasx $mx]
      set cy [$canvas canvasy $my]
#  puts stderr "*** my = $my: cy = $cy"

      set current [$canvas coords ${tag}ThumbRect]
#  puts stderr "*** current = $current"
##  set oldCenterX [expr double([lindex $current 0] + [lindex $current 2]) / 2.0]
      set oldCenterY [lindex $current 3]
#  puts stderr "*** oldCenterY = $oldCenterY"
      set max     [$canvas bbox ${tag}BaseRect]
      set miny [lindex $max 1]
      set maxy [lindex $max 3]

#  puts stderr "*** max = $max, miny = $miny, maxy = $maxy"

      if {$cy < $miny} {set cy $miny}
      if {$cy > $maxy} {set cy $maxy}

#  puts stderr "*** cy = $cy"

      set oldFract [expr {double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)}]
      set fraction [expr {double($cy - $miny) / double(($maxy - $miny) + 1.0)}]
      if {$fraction > 1.0} {set fraction 1.0}

#  puts stderr "*** oldFract = $oldFract, fraction = $fraction"

      $canvas move ${tag}Thumb 0 [expr {($miny + $cy) - $oldCenterY}]
#  if {[expr abs($oldFract - $fraction)] < .00001} {return}
      set newVal [expr {$options(-from) + ( ($options(-to) - $options(-from)) * $fraction )}]  
      $self set $newVal
    }
  }
  snit::type OvalRoundCornerRectangle {
  # Oval Round Corner Rectangle.  Just a rectangle with rounded corners.
  # <option> -x The X coordinate (default 0).
  # <option> -y The Y coordinate (default 0).
  # <option> -width The width of the button (default 200).
  # <option> -height The height of the button (default 40).
  # <option> -color The color of the rectangle (default white).
  # [index] OvalWidgets::OvalRoundCornerRectangle!snit type

    variable canvas
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    OvalWidgets::XYWH 200 40
    OvalWidgets::ColorFillOption -color white
    constructor {_canvas args} {
    # Construct an oval round corner rectangle.
    # <in> _canvas The canvas to draw the oval round corner rectangle on.
    # <in> args The option value list.

      set canvas $_canvas
      $self configurelist $args
      set x $options(-x)
      set y $options(-y)
      set width $options(-width)
      set height $options(-height)
      set tag $selfns
      catch [list $canvas delete $tag]

      set cornerW [expr $width * .25]
      set cornerH [expr $height * .25]
      if {$cornerW < $cornerH} {
        set cornerSize $cornerW
      } else {
        set cornerSize $cornerH
      }

      $canvas create arc $x $y \
	  [expr {$x + $cornerSize + $cornerSize}] \
	  [expr {$y + $cornerSize + $cornerSize}] \
	  -start 90 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$options(-color)"
      $canvas create arc [expr {$x + $width - $cornerSize - $cornerSize}] \
  	  $y \
	  [expr {$x + $width}] \
	  [expr {$y + $cornerSize + $cornerSize}] \
	  -start 0 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$options(-color)"
      $canvas create arc $x [expr {$y + $height - $cornerSize - $cornerSize}] \
	  [expr {$x + $cornerSize + $cornerSize}] \
	  [expr {$y + $height}] \
	  -start 180 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$options(-color)"
      $canvas create arc [expr {$x + $width - $cornerSize - $cornerSize}] \
  	  [expr {$y + $height - $cornerSize - $cornerSize}] \
	  [expr {$x + $width}] \
	  [expr {$y + $height}] \
	  -start 270 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$options(-color)"
      $canvas create rectangle $x [expr {$y + $cornerSize}] \
	  [expr {$x + $width}] \
	  [expr {$y + $cornerSize + $height - $cornerSize - $cornerSize}] \
	  -tag $tag -outline {} -fill "$options(-color)"
      $canvas create rectangle [expr {$x + $cornerSize}] $y \
  	  [expr {$x + $width - $cornerSize}] \
	  [expr {$y + $cornerSize}] \
	  -tag $tag -outline {} -fill "$options(-color)"
      $canvas create rectangle [expr {$x + $cornerSize}] \
	  [expr {$y + $height - $cornerSize}] \
  	  [expr {$x + $width - $cornerSize}] \
	  [expr {$y + $height}] \
	  -tag $tag -outline {} -fill "$options(-color)"
    }
    destructor {
    # Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
  }
  snit::type OvalLabel {
  # Oval label.  Works just like a normal label widget.
  # <option> -x The X coordinate (default 0).
  # <option> -y The Y coordinate (default 0).
  # <option> -font The font to use (default {Courier -12}).
  # <option> -text The text of the label (default {}).
  # <option> -under The underscored character of the text (default {}).
  # <option> -color The color of the text (default white).
  # <option> -undercolor The color of the underscored part of the text 
  #			(default black).
  # [index] OvalWidgets::OvalLabel!snit type

    variable canvas
    OvalWidgets::ColorOptionMethods
    OvalWidgets::CommonValidateMethods
    method _ConfigureXY {option value} {
    # Method to configure an x or y coordinate.
    # <in> option The name of the option to configure.
    # <in> value The value of the option.
  
      set oldx $options(-x)
      set oldy $options(-y)
      set options($option) $value
      set dx [expr {$oldx - $options(-x)}]
      set dy [expr {$oldy - $options(-y)}]
      $canvas move $selfns $dx $dy
    }
    option -x -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    option -y -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    method _VerifyFont {option value} {
    # Method to validate a font value.
    # <in> option The name of the option to validate.
    # <in> value The value of the option.
  
      if {[catch {font actual "$value"}]} {
	error "Expected a font specification for $option, but got $value"
      } else {
	return $value
      }    
    }
    method _ConfigureFont {option value} {
    # Method to configure a font value.
    # <in> option The name of the option to configure.
    # <in> value The value of the option.

      set options($option) "$value"
      set tag $selfns
      $canvas itemconfigure ${tag} -font "$value"
    }
    option -font -default {Courier -12} -validatemethod _VerifyFont -configuremethod _ConfigureFont
    method _ConfigureText {option value} {
    # Method to configure the text of the button.
    # <in> option The name of the option to configure.
    # <in> value The value to configure it to.

      set options($option) "$value"
      set tag $selfns
      $self _UnderSplit before under after
      catch {
	$canvas itemconfigure ${tag}Before -text "$before"
	$canvas itemconfigure ${tag}Under -text "$under"
	$canvas itemconfigure ${tag}After -text "$after"
      }
    }
    option -text -default {} -configuremethod _ConfigureText
    method _VerifyIntegerOrEmpty {option value} {
    # Method to validate an integer or empty string option.
    # <in> option The name of the option to validate.
    # <in> value The value of the option.

      if {[string is integer "$value"]} {
	return "$value"
      } else {
	 error "Expected a integer for $option, but got $value!"
      }
    }
    option -under -default {} -configuremethod _ConfigureText \
			      -validatemethod _VerifyIntegerOrEmpty
    OvalWidgets::ColorFillOption -color white
    OvalWidgets::ColorFillOption -undercolor black
    constructor {_canvas args} {
    # Construct some text.
    # <in> _canvas The canvas to draw the text on.
    # <in> args The option value list.

      set canvas $_canvas
      $self configurelist $args
      set x $options(-x)
      set y $options(-y)
      set tag $selfns
      catch [list $canvas delete $tag]

      $self _UnderSplit before under after
      $canvas create text $x $y -anchor nw -text "$before" \
	-tag [list $tag ${tag}Before] -fill "$options(-color)" \
	-font "$options(-font)"
      set x [lindex [$canvas bbox ${tag}Before] 2]
      $canvas create text $x $y -anchor nw -text "$under" \
	-tag [list $tag ${tag}Under] -fill "$options(-undercolor)" \
	-font "$options(-font)"
      set x [lindex [$canvas bbox ${tag}Under] 2]
      $canvas create text $x $y -anchor nw -text "$after" \
	-tag [list $tag ${tag}After] -fill "$options(-color)" \
	-font "$options(-font)"
    }
    destructor {
    # Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
    method _UnderSplit {beforevar undervar aftervar} {
    # Method to split label text into before, under, and after segments.
    # <out> beforevar -- The name of the before variable.
    # <out> undervar -- The name of the under variable.
    # <out> aftervar -- The name of the after variable.

      upvar $beforevar before
      upvar $undervar under
      upvar $aftervar after

      if {[string length "$options(-under)"] == 0 || $options(-under) < 0} {
	set before {}
	set under {}
	set after "$options(-text)"
      } else {
	set before "[string range $options(-text) 0 [expr {$options(-under) - 1}]]"
	set under  "[string index $options(-text) $options(-under)]"
	set after  "[string range $options(-text) [expr {$options(-under) + 1}] end]"
      }
    }
  }
}


package provide OvalWidgets 2.0

