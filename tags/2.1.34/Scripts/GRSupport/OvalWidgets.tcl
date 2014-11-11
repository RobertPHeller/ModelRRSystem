#* 
#* ------------------------------------------------------------------
#* OvalWidgets.tcl - Oval Widgets
#* Created by Robert Heller on Fri Sep 13 22:04:44 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.2  2005/11/04 19:06:38  heller
#* Modification History: Nov 4, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2002/09/14 03:02:49  heller
#* Modification History: Split up GR Support into several files. Include LCARS Corner Bitmaps
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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

#@Chapter:OvalWidgets.tcl -- Old (depreciated) Oval Widget Code.
# $Id$

package require grsupport 1.0

global HBar VBar

set HBar "@[file join [file dirname [info script]] HBar.xbm]"
set VBar "@[file join [file dirname [info script]] VBar.xbm]"

proc OvalButton {canvas name args} {
  upvar #0 $name data
  OvalButton_Config $canvas $name $args
  OvalButton_Create $name
}

proc OvalButton_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
	{-x          0 VerifyDouble}
	{-y          0 VerifyDouble}
	{-width	   200 VerifyDouble}
	{-height    40 VerifyDouble}
	{-background white}
	{-foreground black}
	{-fontfamily Courier}
	{-rightsquare 0}
	{-leftsquare 0}
	{-text {}}
	{-command {}}
  }

  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}
  
proc OvalButton_Create {name} {
  upvar #0 $name data

  set x $data(-x)
  set y $data(-y)
  set width $data(-width)  
  set height $data(-height)  
  set tag $name
  set canvas $data(canvas)

  catch [list $canvas delete $tag]
  if {!$data(-leftsquare)} {
    $canvas create arc $x $y [expr $x + $height] [expr $y + $height] \
		-outline {} -fill "$data(-background)" -start 90 -extent 180 \
		-style pieslice -tag $tag
    set bbox [$canvas bbox $tag]
    set rleft [expr [lindex $bbox 2] - 1]
    set rtop  [lindex $bbox 1]
    set rbot  [lindex $bbox 3]
    set deltaL [expr $rleft - $x]
  } else {
    set rleft $x
    set rtop $y
    set rbot [expr $y + $height]
    set deltaL 0
  }
  if {!$data(-rightsquare)} {
    set deltaR [expr double($height) / 2.0]
    set rright [expr $rleft + ($width - ($deltaL + $deltaR))]
  } else {
    set rright [expr $rleft + ($width - $deltaL)]
  }
  $canvas create rect $rleft $rtop $rright $rbot \
		      -outline {} -fill "$data(-background)" -tag $tag -width 0
  set bbox [$canvas bbox $tag]
  set otop  [lindex $bbox 1]
  set obot  [lindex $bbox 3]
  set oleft [expr [lindex $bbox 2] - ($obot - $otop) / 2.0 - 1]
  set oright [expr $oleft + ($obot - $otop) + 1]
  if {!$data(-rightsquare)} {
    $canvas create arc $oleft $otop $oright $obot \
		     -outline {} -fill "$data(-background)" -start 270 -extent 180 \
		     -style pieslice -tag $tag -width 0
  }
  $canvas create text [expr $x + (double($width) / 2.0)] \
		      [expr $y + ($height * .1)] \
		      -anchor n -text "$data(-text)" \
		      -fill "$data(-foreground)" \
		      -font [list "$data(-fontfamily)" -[expr int(ceil($height * .8))] bold] \
		      -tag [list $tag ${tag}Text]
  $canvas bind $tag <1> "OvalButton_Invoke $tag"
}

proc OvalButton_Invoke {name} {
  upvar #0 $name data

  set command "$data(-command)"
  if {[string length "$command"] > 0} {uplevel #0 "$command"}
}

proc OvalButton_ConfigText {name newtext} {
  upvar #0 $name data

  set canvas $data(canvas)
  set data(-text) "$newtext"
  
  $canvas itemconfigure ${name}Text -text "$data(-text)"
}

proc OvalButton_ConfigCommand {name newcommand} {
  upvar #0 $name data

  set canvas $data(canvas)
  set data(-command) "$newcommand"
  
}

proc OvalSrollBar {canvas name args} {
  upvar #0 $name data
  OvalSrollBar_Config $canvas $name $args
  OvalSrollBar_Create $name
}

proc OvalSrollBar_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
	{-x          0 VerifyDouble}
	{-y          0 VerifyDouble}
	{-width	    40 VerifyDouble}
	{-length   200 VerifyDouble}
	{-background black}
	{-foreground white}
	{-command {}}
	{-orientation {vertical}}
  }

  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}
  
proc OvalSrollBar_Create {name} {
  upvar #0 $name data

  set x $data(-x)
  set y $data(-y)
  set width $data(-width)
  set length $data(-length)
  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)

  catch [list $canvas delete $tag]
  switch -exact -- "$orientation" {
    vertical {
      array set baseRect \
	[list x1 $x y1 $y x2 [expr $x + $width] y2 [expr $y + $length]]
      array set initThumb \
	[list x1 $x \
	      y1 [expr $y + (double($length) / 2.0) - (double($width) / 2.0)] \
	      x2 [expr $x + $width] \
	      y2 [expr $y + (double($length) / 2.0) + (double($width) / 2.0)]]

    }
    horizontal {
      array set baseRect \
	[list x1 $x y1 $y x2 [expr $x + $length] y2 [expr $y + $width]]
      array set initThumb \
	[list x1 [expr $x + (double($length) / 2.0) - (double($width) / 2.0)] \
	      y1 $y \
	      x2 [expr $x + (double($length) / 2.0) + (double($width) / 2.0)] \
	      y2 [expr $y + $width]]

    }
    default {
      error "Not a valid orientation: $orientation"
    }
  }
  $canvas create rect $baseRect(x1) $baseRect(y1) $baseRect(x2) $baseRect(y2) \
	-fill "$data(-background)" -outline {} -tag [list $tag ${tag}BaseRect]
  $canvas create oval $initThumb(x1) $initThumb(y1) $initThumb(x2) $initThumb(y2) \
	-fill "$data(-foreground)" -outline {} -tag [list $tag ${tag}Thumb]
  $canvas bind ${tag}Thumb <Button1-Motion> [list OvalSrollBar_MoveThumb $tag %x %y]
  $canvas bind ${tag}BaseRect <1> [list OvalSrollBar_BaseRect $tag %x %y]

  OvalSrollBar_Command $name moveto .5
}

proc OvalSrollBar_MoveThumb {name mx my} {
  upvar #0 $name data

#  puts stderr "*** OvalSrollBar_MoveThumb $name $mx $my"
  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)
  set width $data(-width)
  set half_width [expr double($width) / 2.0]
#  puts stderr "*** half_width = $half_width"

  set cx [$canvas canvasx $mx]
  set cy [$canvas canvasy $my]

  set current [$canvas coords ${tag}Thumb]
  set max     [$canvas coords ${tag}BaseRect]
  set oldCenterX [expr double([lindex $current 0] + [lindex $current 2]) / 2.0]
  set oldCenterY [expr double([lindex $current 1] + [lindex $current 3]) / 2.0]
#  puts stderr "*** oldCenterX = $oldCenterX, oldCenterY = $oldCenterY"
  switch -exact -- "$orientation" {
    vertical {
      set miny [expr [lindex $max 1] + $half_width]
      set maxy [expr [lindex $max 3] - $half_width]

#      puts stderr "*** max = $max, miny = $miny, maxy = $maxy"

      if {[expr $cy - $half_width] < $miny} {set cy $miny}
      if {[expr $cy + $half_width] > $maxy} {set cy $maxy}

#      puts stderr "*** cy = $cy"

      set oldFract [expr double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)]
      set fraction [expr double($cy - $miny) / double(($maxy - $miny) + 1.0)]

#      puts stderr "*** oldFract = $oldFract, fraction = $fraction"

      $canvas coords ${tag}Thumb [lindex $current 0] [expr $cy - $half_width] \
				 [lindex $current 2] [expr $cy + $half_width]
    }
    horizontal {
      set minx [expr [lindex $max 0] + $half_width]
      set maxx [expr [lindex $max 2] - $half_width]

      if {[expr $cx - $half_width] < $minx} {set cx $minx}
      if {[exor $cx + $halt_width] > $maxx} {set cx $maxx}
      
      set oldFract [expr double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)]
      set fraction [expr double($cx - $minx) / double(($maxx - $minx) + 1.0)]

      $canvas coords ${tag}Thumb [expr $cx - $half_width] [lindex $current 1] \
				 [expr $cx + $half_width] [lindex $current 3] 
    }
  }

  if {[expr abs($oldFract - $fraction)] < .00001} {return}
  OvalSrollBar_Command $tag moveto $fraction  
}

proc OvalSrollBar_BaseRect {name mx my} {
  upvar #0 $name data

#  puts stderr "*** OvalSrollBar_BaseRect $name $mx $my"
  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)

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

  if {$dir != 0} {OvalSrollBar_Command $tag scroll $dir pages}
}

proc OvalSrollBar_Command {name args} {
  upvar #0 $name data

#  puts stderr "*** OvalSrollBar_Command $name $args"
  set tag $name
  if {[string length "$data(-command)"] > 0} {
    uplevel #0 [concat $data(-command) $args]
  }
}

proc OvalSrollBar_Set {name first last} {
  upvar #0 $name data

#  puts stderr "*** OvalSrollBar_Set $name $first $last"
  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)
  set width $data(-width)
  set length $data(-length)

  set half_width [expr double($width) / 2.0]

#  set fraction [expr double($first + $last) / 2.0]
  set fraction $first
#  puts stderr "*** fraction = $fraction"

  set current [$canvas coords ${tag}Thumb]
#  puts stderr "*** current = $current"
  set oldCenterX [expr double([lindex $current 0] + [lindex $current 2]) / 2.0]
  set oldCenterY [expr double([lindex $current 1] + [lindex $current 3]) / 2.0]
#  puts stderr "*** oldCenterX = $oldCenterX, oldCenterY = $oldCenterY"
  set max     [$canvas coords ${tag}BaseRect]
#  puts stderr "*** max = $max"
  switch -exact -- "$orientation" {
    vertical {
      set miny [expr [lindex $max 1] + $half_width]
      set maxy [expr [lindex $max 3] - $half_width]
      set newposO [expr double(($maxy - $miny) + 1.0) * $fraction]
#  puts stderr "*** newposO = $newposO"
      set oldFract [expr double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)]
#      puts stderr "*** oldFract = $oldFract"
      $canvas coords ${tag}Thumb [lindex $current 0] \
				 [expr $miny + $newposO - $half_width] \
				 [lindex $current 2] \
				 [expr $miny + $newposO + $half_width]
    }
    horizontal {
      set minx [expr [lindex $max 0] + $half_width]
      set maxx [expr [lindex $max 2] - $half_width]
      set newposO [expr double(($maxx - $minx) + 1.0) * $fraction]
      set oldFract [expr double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)]
      $canvas coords ${tag}Thumb [expr $minx + $newposO - $half_width] \
				 [lindex $current 1] \
				 [expr $minx + $newposO + $half_width] \
				 [lindex $current 3] 
    }
  }

#  puts stderr "*** oldFract = $oldFract, fraction = $fraction"
  if {[expr abs($oldFract - $fraction)] < .001} {return}
  OvalSrollBar_Command $tag moveto $fraction  
}
  
proc OvalSrollBar_ReSize {name newMin newMax} {
  upvar #0 $name data

  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)
  set width $data(-width)
  set length $data(-length)

  set current [$canvas coords ${tag}Thumb]
  set oldCenterX [expr double([lindex $current 0] + [lindex $current 2]) / 2.0]
  set oldCenterY [expr double([lindex $current 1] + [lindex $current 3]) / 2.0]
  set max     [$canvas coords ${tag}BaseRect]
  switch -exact -- "$orientation" {
    vertical {
      set miny [expr [lindex $max 1] + $half_width]
      set maxy [expr [lindex $max 3] - $half_width]
      set fraction [expr double($oldCenterY - $miny) / double($maxy - $miny)]
      $canvas coords ${tag}BaseRect [lindex $max 0] $newMin \
      				    [lindex $max 2] $newMax
      set $data(-length) [expr $newMax - $newMin]
    }
    horizontal {
      set minx [expr [lindex $max 0] + $half_width]
      set maxx [expr [lindex $max 2] - $half_width]
      set fraction [expr double($oldCenterX - $minx) / double($maxx - $minx)]
      $canvas coords ${tag}BaseRect $newMin [lindex $max 1] \
				    $newMax [lindex $max 3]
      set $data(-length) [expr $newMax - $newMin]
    }
  }

  OvalSrollBar_Command $tag moveto $fraction  
}
  
proc OvalScale {canvas name args} {
  upvar #0 $name data
  OvalScale_Config $canvas $name $args
  OvalScale_Create $name
}

proc OvalScale_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
	{-x          0 VerifyDouble}
	{-y          0 VerifyDouble}
	{-width	    40 VerifyDouble}
	{-length   200 VerifyDouble}
	{-background black}
	{-foreground white}
	{-command {}}
	{-orientation {horizontal}}
	{-from       0 VerifyDouble}
	{-to       100 VerifyDouble}
	{-digits     2}
	{-fontfamily Courier}
	{-label     {}}
	{-showvalue  1}
	{-variable  {}}
	{-bigincrement 0}
  }

  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}
  
proc OvalScale_Create {name} {
  upvar #0 $name data

  set x $data(-x)
  set y $data(-y)
  set width $data(-width)
  set length $data(-length)
  set canvas $data(canvas)
  set orientation $data(-orientation)
  set tag $name

  catch [list $canvas delete $tag]
  set lheight [expr int(ceil($width * .5))]
  set lfont [list "$data(-fontfamily)" -$lheight bold]
  set data(font) "$lfont"
  switch -exact -- "$orientation" {
    vertical {
      set lid [$canvas create text 0 0 -anchor nw -text "$data(-label)" \
		-font $lfont]
      update idle
      set lbbox [$canvas bbox $lid]
      $canvas delete $lid
      if {$data(-showvalue)} {
        set vid [$canvas create text 0 0 -anchor nw -text [format "%$data(-digits)f" 0] \
		-font $lfont]
	update idle
	set vbox [$canvas bbox $vid]
	$canvas delete $vid
      } else {
	set vbox [list 0 0 0 0]
      }
      set brx [expr $x + [lindex $vbox 2]]
      array set valuePos [list x $x y $y]
      array set baseRect \
	[list x1 [expr $x + $brx] y1 $y x2 [expr $x + $brx + $width] y2 [expr $y + $length]]
      array set initThumb \
	[list x1 [expt $x + $brx] \
	      y1 [expr $y + (double($length) / 2.0) - (double($width) / 2.0)] \
	      x2 [expr $x + $brx + $width] \
	      y2 [expr $y + (double($length) / 2.0) + (double($width) / 2.0)]]
      array set labelPos [list x [expr $brx + $width] y $y]
      
    }
    horizontal {
      set lid [$canvas create text 0 0 -anchor nw -text "$data(-label)" \
		-font $lfont]
      update idle
      set lbbox [$canvas bbox $lid]
#      puts stderr "*** OvalScale_Create: lbbox = $lbbox"
      $canvas delete $lid
      if {$data(-showvalue)} {
        set vid [$canvas create text 0 0 -anchor nw -text [format "%$data(-digits)d" 0] \
		-font $lfont]
	update idle
	set vbox [$canvas bbox $vid]
	$canvas delete $vid
      } else {
	set vbox [list 0 0 0 0]
      }
      array set labelPos [list x $x y $y]
#      puts stderr "*** OvalScale_Create: labelPos = [array get labelPos]"
      array set valuePos [list x $x y [expr $y + [lindex $lbbox 3]]]
      set bry [expr [lindex $lbbox 3] + [lindex $vbox 3]]
      array set baseRect \
	[list x1 $x y1 [expr $y + $bry] x2 [expr $x + $length] y2 [expr $y + $bry + $width]]
      array set initThumb \
	[list x1 [expr $x + (double($length) / 2.0) - (double($width) / 2.0)] \
	      y1 [expr $y + $bry] \
	      x2 [expr $x + (double($length) / 1.0) + (double($width) / 2.0)] \
	      y2 [expr $y + $bry + $width]]

    }
    default {
      error "Not a valid orientation: $orientation"
    }
  }
  if {$data(-bigincrement) == 0} {
    set data(-bigincrement) [expr .1 * ($data(-to) - $data(-from))]
  }
#  puts stderr "*** OvalScale_Create: baseRect = [array get baseRect], initThumb = [array get initThumb]"
  $canvas create rect $baseRect(x1) $baseRect(y1) $baseRect(x2) $baseRect(y2) \
	-fill "$data(-background)" -outline {} -tag [list $tag ${tag}BaseRect]
  $canvas create oval $initThumb(x1) $initThumb(y1) $initThumb(x2) $initThumb(y2) \
	-fill "$data(-foreground)" -outline {} -tag [list $tag ${tag}Thumb]
  if {[string length "$data(-label)"] > 0} {
    $canvas create text $labelPos(x) $labelPos(y) -anchor nw -text "$data(-label)" \
			-fill "$data(-foreground)" \
			-font $lfont -tag [list $tag ${tag}Label]
  }
  if {$data(-showvalue)} {
    $canvas create text $valuePos(x) $valuePos(y) -anchor nw \
		-text [format "%$data(-digits)f" 0] \
		-fill "$data(-foreground)" \
		-font $lfont -tag [list $tag ${tag}Value]
  }

  $canvas bind ${tag}Thumb <Button1-Motion> [list OvalScale_MoveThumb $tag %x %y]
  $canvas bind ${tag}BaseRect <1> [list OvalScale_BaseRect $tag %x %y]

  OvalScale_Set $name $data(-from)

}

proc OvalScale_Set {name value} {
  upvar #0 $name data

  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)
  set width $data(-width)
  set length $data(-length)
  
  if {$data(-from) < $data(-to)} {
    if {$value < $data(-from)} {set value $data(-from)}
    if {$value > $data(-to)} {set value $data(-to)}
    set fraction [expr double($value - $data(-from)) / double($data(-to) - $data(-from))]
  } else {
    if {$value > $data(-from)} {set value $data(-from)}
    if {$value < $data(-to)} {set value $data(-to)}
    set fraction [expr 1.0 - double($value - $data(-to)) / double($data(-from) - $data(-to))]
  }
  set data(value) $value
  if {[string length "$data(-variable)"] > 0} {
    upvar #0 $data(-variable) v
    set v $value
  }
  if {[string length "$data(-command)"] > 0} {
    uplevel #0 [list $data(-command) $value]
  }
  if {$data(-showvalue)} {
    $canvas itemconfigure ${tag}Value -text [format "%$data(-digits)f" $value]
  }
  set half_width [expr double($width) / 2.0]

  set current [$canvas coords ${tag}Thumb]
  set oldCenterX [expr double([lindex $current 0] + [lindex $current 2]) / 2.0]
  set oldCenterY [expr double([lindex $current 1] + [lindex $current 3]) / 2.0]
  set max     [$canvas coords ${tag}BaseRect]
  switch -exact -- "$orientation" {
    vertical {
      set miny [expr [lindex $max 1] + $half_width]
      set maxy [expr [lindex $max 3] - $half_width]
      set newposO [expr double(($maxy - $miny) + 1.0) * $fraction]
#  puts stderr "*** newposO = $newposO"
      set oldFract [expr double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)]
#      puts stderr "*** oldFract = $oldFract"
      $canvas coords ${tag}Thumb [lindex $current 0] \
				 [expr $miny + $newposO - $half_width] \
				 [lindex $current 2] \
				 [expr $miny + $newposO + $half_width]
    }
    horizontal {
      set minx [expr [lindex $max 0] + $half_width]
      set maxx [expr [lindex $max 2] - $half_width]
      set newposO [expr double(($maxx - $minx) + 1.0) * $fraction]
      set oldFract [expr double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)]
      $canvas coords ${tag}Thumb [expr $minx + $newposO - $half_width] \
				 [lindex $current 1] \
				 [expr $minx + $newposO + $half_width] \
				 [lindex $current 3] 
    }
  }
}

proc OvalScale_Get {name} {
  upvar #0 $name data

  return $data(value)
}
  
proc OvalScale_MoveThumb {name mx my} {
  upvar #0 $name data

#  puts stderr "*** OvalScale_MoveThumb $name $mx $my"
  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)
  set width $data(-width)
  set half_width [expr double($width) / 2.0]
#  puts stderr "*** half_width = $half_width"

  set cx [$canvas canvasx $mx]
  set cy [$canvas canvasy $my]

  set current [$canvas coords ${tag}Thumb]
  set max     [$canvas coords ${tag}BaseRect]
  set oldCenterX [expr double([lindex $current 0] + [lindex $current 2]) / 2.0]
  set oldCenterY [expr double([lindex $current 1] + [lindex $current 3]) / 2.0]
#  puts stderr "*** oldCenterX = $oldCenterX, oldCenterY = $oldCenterY"
  switch -exact -- "$orientation" {
    vertical {
      set miny [expr [lindex $max 1] + $half_width]
      set maxy [expr [lindex $max 3] - $half_width]

#      puts stderr "*** max = $max, miny = $miny, maxy = $maxy"

      if {[expr $cy - $half_width] < $miny} {set cy $miny}
      if {[expr $cy + $half_width] > $maxy} {set cy $maxy}

#      puts stderr "*** cy = $cy"

      set oldFract [expr double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)]
      set fraction [expr double($cy - $miny) / double(($maxy - $miny) + 1.0)]

#      puts stderr "*** oldFract = $oldFract, fraction = $fraction"

      $canvas coords ${tag}Thumb [lindex $current 0] [expr $cy - $half_width] \
				 [lindex $current 2] [expr $cy + $half_width]
    }
    horizontal {
      set minx [expr [lindex $max 0] + $half_width]
      set maxx [expr [lindex $max 2] - $half_width]

      if {[expr $cx - $half_width] < $minx} {set cx $minx}
      if {[exor $cx + $halt_width] > $maxx} {set cx $maxx}
      
      set oldFract [expr double($oldCenterX - $minx) / double(($maxx - $minx) + 1.0)]
      set fraction [expr double($cx - $minx) / double(($maxx - $minx) + 1.0)]

      $canvas coords ${tag}Thumb [expr $cx - $half_width] [lindex $current 1] \
				 [expr $cx + $half_width] [lindex $current 3] 
    }
  }

  if {[expr abs($oldFract - $fraction)] < .00001} {return}
  set newVal [expr $data(-from) + ( ($data(-to) - $data(-from)) * $fraction )]  
  OvalScale_Set $tag $newVal
}

proc OvalScale_BaseRect {name mx my} {
  upvar #0 $name data

#  puts stderr "*** OvalScale_BaseRect $name $mx $my"
  set orientation $data(-orientation)
  set tag $name
  set canvas $data(canvas)

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
    OvalScale_Set $tag [expr $data(value) + ($dir * $data(-bigincrement))]
  }
}


proc OvalSlider {canvas name args} { 
  upvar #0 $name data
  OvalSlider_Config $canvas $name $args
  OvalSlider_Create $name
}

proc OvalSlider_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
	{-x          0 VerifyDouble}
	{-y          0 VerifyDouble}
	{-width	   200 VerifyDouble}
	{-height    40 VerifyDouble}
	{-length   600 VerifyDouble}
	{-rightsquare 0}
	{-leftsquare 0}
	{-background black}
	{-foreground white}
	{-command {}}
	{-from       0 VerifyDouble}
	{-to       100 VerifyDouble}
	{-digits     2}
	{-fontfamily Courier}
	{-label     {}}
	{-showvalue  1}
	{-variable  {}}
	{-stipple   {}}
  }

  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}
  
proc OvalSlider_Create {name} {
  upvar #0 $name data

  set x $data(-x)
  set y $data(-y)
  set width $data(-width)
  set height $data(-height)
  set length $data(-length)
  set canvas $data(canvas)
  set tag $name

  if {[string length "$data(-stipple)"] == 0} {
    global HBar
    set data(-stipple) "$HBar"
  }
  catch [list $canvas delete $tag]
  if {$data(-showvalue)} {
    set lfont [list "$data(-fontfamily)" -[expr int(ceil($height * .35))] bold]
  } else {
    set lfont [list "$data(-fontfamily)" -[expr int(ceil($height * .8))] bold]
  }
  set data(font) "$lfont"
  if {!$data(-leftsquare)} {
    $canvas create arc $x $y [expr $x + $height] [expr $y + $height] \
		-outline {} -fill "$data(-background)" -start 90 -extent 180 \
		-style pieslice -tag [list $tag ${tag}Thumb]
    set bbox [$canvas bbox $tag]
    set rleft [expr [lindex $bbox 2] - 1]
    set rtop  [lindex $bbox 1]
    set rbot  [lindex $bbox 3]
    set deltaL [expr $rleft - $x]
  } else {
    set rleft $x
    set rtop $y
    set rbot [expr $y + $height]
    set deltaL 0
  }
  if {!$data(-rightsquare)} {
    set deltaR [expr double($height) / 2.0]
    set rright [expr $rleft + ($width - ($deltaL + $deltaR))]
  } else {
    set rright [expr $rleft + ($width - $deltaL)]
  }
  $canvas create rect $rleft $rtop $rright $rbot \
		      -outline {} -fill "$data(-background)" \
		      -tag [list $tag ${tag}Thumb ${tag}ThumbRect] -width 0
  set bbox [$canvas bbox $tag]
  set otop  [lindex $bbox 1]
  set obot  [lindex $bbox 3]
  set oleft [expr [lindex $bbox 2] - ($obot - $otop) / 2.0 - 1]
  set oright [expr $oleft + ($obot - $otop) + 1]
  if {!$data(-rightsquare)} {
    $canvas create arc $oleft $otop $oright $obot \
		     -outline {} -fill "$data(-background)" -start 270 -extent 180 \
		     -style pieslice -tag [list $tag ${tag}Thumb] -width 0
  }
  $canvas create text [expr $x + (double($width) / 2.0)] \
		      [expr $y + ($height * .1)] \
		      -anchor n -text "$data(-label)" \
		      -fill "$data(-foreground)" \
		      -font "$lfont" \
		      -tag [list $tag ${tag}Label ${tag}Thumb]
  if {$data(-showvalue)} {
    $canvas create text [expr $x + (double($width) / 2.0)] \
		      [expr $y + ($height * .5)] \
		      -anchor n -text [format "%$data(-digits)f" $data(-to)] \
		      -fill "$data(-foreground)" \
		      -font "$lfont" \
		      -tag [list $tag ${tag}Value ${tag}Thumb]
  }
  set bot [lindex [$canvas bbox ${tag}Thumb] 3]
  $canvas create rect $x $bot [expr $x + $width] [expr $bot + $length] \
		-outline {} -fill "$data(-foreground)" \
		-stipple "$data(-stipple)" -tag [list $tag ${tag}Bar]
  $canvas create rect $x $bot [expr $x + $width] [expr $bot + $length] \
		-outline {} -fill {} \
		-tag [list $tag ${tag}BaseRect]
  $canvas lower ${tag}BaseRect ${tag}Thumb
  $canvas bind ${tag}Thumb <Button1-Motion> [list OvalSlider_MoveThumb $tag %x %y]
#  set thumbElts [$canvas find withtag ${tag}Thumb]
#  puts stderr "*** items with ${tag}Thumb tag: $thumbElts"
#  foreach thelts $thumbElts {
#    puts stderr "***   $thelts: [$canvas type $thelts] [$canvas coords $thelts]"
#  }
  OvalSlider_Set $name $data(-from)
}

proc OvalSlider_Set {name value} {
#  puts stderr "*** OvalSlider_Set $name $value"

  upvar #0 $name data

  set tag $name
  set canvas $data(canvas)
  set width $data(-width)
  set height $data(-height)
  set length $data(-length)
  
  if {$data(-from) < $data(-to)} {
    if {$value < $data(-from)} {set value $data(-from)}
    if {$value > $data(-to)} {set value $data(-to)}
    set fraction [expr double($value - $data(-from)) / double($data(-to) - $data(-from))]
  } else {
    if {$value > $data(-from)} {set value $data(-from)}
    if {$value < $data(-to)} {set value $data(-to)}
    set fraction [expr 1.0 - double($value - $data(-to)) / double($data(-from) - $data(-to))]
  }
#  puts stderr "*** fraction = $fraction"
  set data(value) $value
  if {[string length "$data(-variable)"] > 0} {
    upvar #0 $data(-variable) v
    set v $value
  }
  if {[string length "$data(-command)"] > 0} {
    uplevel #0 [list $data(-command) $value]
  }
  if {$data(-showvalue)} {
    $canvas itemconfigure ${tag}Value -text [format "%$data(-digits)f" $value]
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
  set newposO [expr double(($maxy - $miny) + 1.0) * $fraction]
#  puts stderr "*** newposO = $newposO"
  set oldFract [expr double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)]
#  puts stderr "*** oldFract = $oldFract"
  $canvas move ${tag}Thumb 0 [expr ($miny + $newposO) - $oldCenterY]
  set bot [lindex [$canvas bbox ${tag}Thumb] 3]
  set BarCoords [$canvas coords ${tag}Bar]
  $canvas coords ${tag}Bar [list [lindex $BarCoords 0] $bot [lindex $BarCoords 2] [lindex $BarCoords 3]]  
}

proc OvalSlider_Get {name} {
  upvar #0 $name data

  return $data(value)
}
  
proc OvalSlider_MoveThumb {name mx my} {
  upvar #0 $name data

#  puts stderr "*** OvalSlider_MoveThumb $name $mx $my"
  set tag $name
  set canvas $data(canvas)
  set width $data(-width)
  set height $data(-height)
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

  set oldFract [expr double($oldCenterY - $miny) / double(($maxy - $miny) + 1.0)]
  set fraction [expr double($cy - $miny) / double(($maxy - $miny) + 1.0)]
  if {$fraction > 1.0} {set fraction 1.0}

#  puts stderr "*** oldFract = $oldFract, fraction = $fraction"

  $canvas move ${tag}Thumb 0 [expr ($miny + $cy) - $oldCenterY]
#  if {[expr abs($oldFract - $fraction)] < .00001} {return}
  set newVal [expr $data(-from) + ( ($data(-to) - $data(-from)) * $fraction )]  
  OvalSlider_Set $tag $newVal
}

proc OvalRoundCornerRectangle {canvas name args} {
  upvar #0 $name data
  OvalRoundCornerRectangle_Config $canvas $name $args
  OvalRoundCornerRectangle_Create $name
}

proc OvalRoundCornerRectangle_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
	{-x          0 VerifyDouble}
	{-y          0 VerifyDouble}
	{-width	   200 VerifyDouble}
	{-height    40 VerifyDouble}
	{-color     white}
  }
  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}

proc OvalRoundCornerRectangle_Create {name} {
  upvar #0 $name data

  set x $data(-x)
  set y $data(-y)
  set width $data(-width)
  set height $data(-height)
  set canvas $data(canvas)
  set tag $name

  catch [list $canvas delete $tag]

  set cornerW [expr $width * .25]
  set cornerH [expr $height * .25]
  if {$cornerW < $cornerH} {
    set cornerSize $cornerW
  } else {
    set cornerSize $cornerH
  }

  $canvas create arc $x $y \
	  [expr $x + $cornerSize + $cornerSize] \
	  [expr $y + $cornerSize + $cornerSize] \
	  -start 90 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$data(-color)"
  $canvas create arc [expr $x + $width - $cornerSize - $cornerSize] \
  	  $y \
	  [expr $x + $width] \
	  [expr $y + $cornerSize + $cornerSize] \
	  -start 0 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$data(-color)"
  $canvas create arc $x [expr $y + $height - $cornerSize - $cornerSize] \
	  [expr $x + $cornerSize + $cornerSize] \
	  [expr $y + $height] \
	  -start 180 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$data(-color)"
  $canvas create arc [expr $x + $width - $cornerSize - $cornerSize] \
  	  [expr $y + $height - $cornerSize - $cornerSize] \
	  [expr $x + $width] \
	  [expr $y + $height] \
	  -start 270 -extent 90 -style pieslice -tag $tag \
	  -outline {} -fill "$data(-color)"
  $canvas create rectangle $x [expr $y + $cornerSize] \
	  [expr $x + $width] \
	  [expr $y + $cornerSize + $height - $cornerSize - $cornerSize] \
	  -tag $tag -outline {} -fill "$data(-color)"
  $canvas create rectangle [expr $x + $cornerSize] $y \
  	  [expr $x + $width - $cornerSize] \
	  [expr $y + $cornerSize] \
	  -tag $tag -outline {} -fill "$data(-color)"
  $canvas create rectangle [expr $x + $cornerSize] \
	  [expr $y + $height - $cornerSize] \
  	  [expr $x + $width - $cornerSize] \
	  [expr $y + $height] \
	  -tag $tag -outline {} -fill "$data(-color)"
}

proc OvalLabel  {canvas name args} {
  upvar #0 $name data
  OvalLabel_Config $canvas $name $args
  OvalLabel_Create $name
}

proc OvalLabel_Config  {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
	{-x          0 VerifyDouble}
	{-y          0 VerifyDouble}
	{-font	     {Courier -12}}
	{-text       {}}
	{-under      {}}
	{-color     white}
	{-undercolor black}
  }
  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}


proc OvalLabel_Create {name} {
  upvar #0 $name data

  set x $data(-x)
  set y $data(-y)
  set tag $name
  set canvas $data(canvas)
  set text $data(-text)
  set under $data(-under)
  set font $data(-font)

  catch [list $canvas delete $tag]
  if {[string length "$under"] == 0 || $under < 0} {
    $canvas create text $x $y -anchor nw -text "$text" -tag $tag \
	-fill "$data(-color)" -font "$data(-font)"
  } else {
    set before "[string range $text 0 [expr $under - 1]]"
    set uchar  "[string index $text $under]"
    set after  "[string range $text [expr $under + 1] end]"
    if {[string length "$before"] > 0} {
      $canvas create text $x $y -anchor nw -text "$before" \
	-tag $tag -fill "$data(-color)" -font "$data(-font)"
      set x [lindex [$canvas bbox $tag] 2]
    }
    $canvas create text $x $y -anchor nw -text "$uchar" \
	-tag $tag -fill "$data(-undercolor)" -font "$data(-font)"
    set x [lindex [$canvas bbox $tag] 2]
    if {[string length "$after"] > 0} {
      $canvas create text $x $y -anchor nw -text "$after" \
	-tag $tag -fill "$data(-color)" -font "$data(-font)"
    }
  }
}



package provide OvalWidgets 1.0
