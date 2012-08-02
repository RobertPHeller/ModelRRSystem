#* 
#* ------------------------------------------------------------------
#* Instruments.tcl - Instrument Widgets
#* Created by Robert Heller on Fri Sep 13 22:01:32 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

# $Id$

package require grsupport 1.0

global PI PI2
set PI2 [expr acos(0.0)]
set PI  [expr $PI2 * 2]

proc DegreesToRadians {degrees} {
  global PI PI2
  return [expr (double($degrees) / 180.0) * $PI]
}

proc DialInstrument {canvas name args} {
  upvar #0 $name data
  DialInstrument_Config $canvas $name $args
  DialInstrument_Create $name
}

proc DialInstrument_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
      {-x          0 VerifyDouble}
      {-y	   0 VerifyDouble}
      {-size	 100 VerifyDouble}
      {-maxValue 100 tclVerifyInteger}
      {-minValue   0 tclVerifyInteger}
      {-minAt    225 tclVerifyInteger}
      {-maxAt    315 tclVerifyInteger}
      {-background blue}
      {-fontfamily Courier}
      {-outline    black}
      {-scaleBack  white}
      {-scaleTicks black}
      {-pointerColor black}
      {-secondPointerP 0 tclVerifyInteger}
      {-secondPointerColor red}
      {-scaleTicksInterval 10 tclVerifyInteger}
      {-digitalP  1 tclVerifyInteger}
      {-digits    3 tclVerifyInteger}
      {-digitalBackground white}
      {-digitalDigitColor black}
      {-label DialInstrument}
      {-labelColor black}
      {-labelFont {Times 14 bold}}
  }
  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}

proc DialInstrument_Create {name} {
  upvar #0 $name data

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  set size $data(-size)
  set tag $name

  set sx [expr $x + $size]
  set sy [expr $y + $size]
  set data(sx) $sx
  set data(sy) $sy
  catch [list $canvas delete $tag]
  $canvas create oval $x $y $sx $sy \
		-outline "$data(-outline)" \
		-fill    "$data(-background)" \
		-width   2 \
		-tag     $tag
  set tenth [expr double($size) / 10.0]
  set tenth2 [expr $tenth * 2.0]
  set data(tenth) $tenth
  set data(tenth2) $tenth2
  if {$data(-maxAt) > 0} {
    set extents [expr $data(-minAt) + (360 - $data(-maxAt))]
  } else {
    set extents [expr $data(-minAt) - $data(-maxAt)]
  }
  set data(extents) $extents
  $canvas create arc  [expr $x + $tenth] [expr $y + $tenth] \
		      [expr $sx - $tenth] [expr $sy - $tenth] \
  		-outline    "$data(-scaleBack)" \
		-fill {} -style arc \
		-width $tenth2 \
		-start $data(-maxAt) \
		-extent $extents \
		-tag  $tag
  set centerX [expr $x + ($size * 0.5)]
  set centerY [expr $y + ($size * 0.5)]
  set data(centerX) $centerX
  set data(centerY) $centerY
  set hubsize $tenth
  set hubX    [expr $centerX - ($hubsize / 2.0)]
  set hubY    [expr $centerY - ($hubsize / 2.0)]
  set hubSX   [expr $centerX + ($hubsize / 2.0)]
  set hubSY   [expr $centerY + ($hubsize / 2.0)]
  $canvas create oval $hubX $hubY $hubSX $hubSY \
  		-outline {} \
		-fill    "$data(-pointerColor)" \
		-tag	$tag
  set numticks [expr  int(ceil(double($data(-maxValue) - \
				  $data(-minValue)) / \
			   double($data(-scaleTicksInterval))))]

  set oldstart [expr $data(-maxAt) - 2]
  set angle [expr double($extents) / double($numticks)]
  for {set i 0} {$i <= $numticks} {incr i} {
     $canvas create arc [expr $x + $tenth] [expr $y + $tenth] \
		      [expr $sx - $tenth] [expr $sy - $tenth] \
  		-outline   "$data(-scaleTicks)" \
		-fill {} -style arc \
		-start $oldstart -extent 4 \
		-width $tenth2 \
		-tag $tag
     set oldstart [expr $oldstart + $angle]
     if {$oldstart >= 360} {set oldstart [expr $oldstart - 360]}
  }

  set data(ValueRange) [expr $data(-maxValue) - $data(-minValue)]

  if {$data(-digitalP)} {  
    set tempid [$canvas create text 0 0 -anchor nw \
	-text [format "%0$data(-digits)d" 0] \
	-font [list "$data(-fontfamily)" -[expr int(ceil($tenth))] bold]]
    set digBBox [$canvas bbox $tempid]
    $canvas delete $tempid
    set digwidth [expr [lindex $digBBox 2] + 4.0]
    set digheight [expr [lindex $digBBox 3] + 4.0]
    set db [$canvas create rectangle [expr $centerX - ($digwidth / 2.0)] [expr $sy - $tenth - $digheight] \
			     [expr $centerX + ($digwidth / 2.0)] [expr $sy - $tenth] \
			     -outline {} \
			     -fill "$data(-digitalBackground)" \
			     -tag $tag]
    set DBBox [$canvas bbox $db]
    set data(dTextX) [expr [lindex $DBBox 0] + 2]
    set data(dTextY) [expr [lindex $DBBox 1] + 2]
  }

  $canvas create text $centerX [expr $sy + 3] -anchor n -text "$data(-label)" \
	-fill "$data(-labelColor)" -font "$data(-labelFont)"

  set ValueRange $data(ValueRange)
  set ValueOffset 0

  set relAngle [expr (double($ValueOffset) / double($ValueRange)) * $extents]
  set angle [expr $data(-minAt) + $relAngle]
  if {$angle > 360} {set angle [expr $angle - 360]}

  if {[expr $angle - 90] < 0} {
    set radians [DegreesToRadians [expr 360 + ($angle - 90)]]
  } else {
    set radians [DegreesToRadians [expr $angle - 90]]
  }
  set radius [expr double($size - $tenth) / 2.0]
  set psX [expr $radius * cos($radians)]
  set psY [expr $radius * sin($radians)]

  $canvas create line $centerX $centerY \
	[expr $centerX + $psX] [expr $centerY + $psY] \
	-fill "$data(-pointerColor)" \
	-width [expr int(ceil(double($size)) / 100.0)] \
	-arrow last \
	-tag [list $tag ${tag}Pointer]

  if {$data(-secondPointerP)} {
    set ValueOffset 0

    set relAngle [expr (double($ValueOffset) / double($ValueRange)) * $extents]
    set angle [expr $data(-minAt) + $relAngle]
    if {$angle > 360} {set angle [expr $angle - 360]}
    if {[expr $angle - 90] < 0} {
      set radians [DegreesToRadians [expr 360 + ($angle - 90)]]
    } else {
      set radians [DegreesToRadians [expr $angle - 90]]
    }
    set radius [expr double($size - $tenth) / 2.0]
    set psX [expr $radius * cos($radians)]
    set psY [expr $radius * sin($radians)]

    $canvas create line $centerX $centerY \
	[expr $centerX + $psX] [expr $centerY + $psY] \
	-fill "$data(-secondPointerColor)" \
	-width [expr int(ceil(double($size)) / 100.0)] \
	-arrow last \
	-tag [list $tag ${tag}SecondPointer]

  }

  if {$data(-digitalP)} {
    $canvas create text $data(dTextX) $data(dTextY) \
    		   -text [format "%$data(-digits)d" 0] \
		   -font [list "$data(-fontfamily)" -[expr int(ceil($tenth))] bold] \
		   -anchor nw \
		   -fill "$data(-digitalDigitColor)" \
		   -tag [list $tag ${tag}DigitalDigits]
  }

}
proc SetDialInstrumentValue {name args} {
  upvar #0 $name data

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  set size $data(-size)
  set tag $name
  set extents $data(extents)
  set sx $data(sx)
  set sy $data(sy)
  set centerX $data(centerX)
  set centerY $data(centerY)
  set tenth $data(tenth)
  set tenth2 $data(tenth2)

  set ValueRange $data(ValueRange)
  set ValueOffset [expr [lindex $args 0] - $data(-minValue)]

  set relAngle [expr (double($ValueOffset) / double($ValueRange)) * $extents]
  set angle [expr $data(-minAt) + $relAngle]
  if {$angle > 360} {set angle [expr $angle - 360]}

  if {[expr $angle - 90] < 0} {
    set radians [DegreesToRadians [expr 360 + ($angle - 90)]]
  } else {
    set radians [DegreesToRadians [expr $angle - 90]]
  }
  set radius [expr double($size - $tenth) / 2.0]
  set psX [expr $radius * cos($radians)]
  set psY [expr $radius * sin($radians)]

  $canvas coords ${tag}Pointer $centerX $centerY \
		[expr $centerX + $psX] [expr $centerY + $psY]

  if {$data(-secondPointerP)} {
    set ValueOffset [expr [lindex $args 1] - $data(-minValue)]

    set relAngle [expr (double($ValueOffset) / double($ValueRange)) * $extents]
    set angle [expr $data(-minAt) + $relAngle]
    if {$angle > 360} {set angle [expr $angle - 360]}
    if {[expr $angle - 90] < 0} {
      set radians [DegreesToRadians [expr 360 + ($angle - 90)]]
    } else {
      set radians [DegreesToRadians [expr $angle - 90]]
    }
    set radius [expr double($size - $tenth) / 2.0]
    set psX [expr $radius * cos($radians)]
    set psY [expr $radius * sin($radians)]

    $canvas coords ${tag}SecondPointer $centerX $centerY \
	[expr $centerX + $psX] [expr $centerY + $psY]

  }

  if {$data(-digitalP)} {
    $canvas itemconfigure ${tag}DigitalDigits \
	   -text [format "%$data(-digits)d" [expr int([lindex $args 0])]]
  }

}

proc AnalogClock {canvas name args} {
  upvar #0 $name data
  AnalogClock_Config $canvas $name $args
  AnalogClock_Create $name
}

proc AnalogClock_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
      {-x          0 VerifyDouble}
      {-y	   0 VerifyDouble}
      {-size	 100 VerifyDouble}
      {-background white}
      {-outline    black}
      {-scaleBack  white}
      {-scaleTicks black}
      {-hubColor black}
      {-minuteHandColor black}
      {-hourHandColor black}
      {-label Clock}
      {-labelColor black}
      {-labelFont {Times 14 bold}}
  }
  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}

proc AnalogClock_Create {name} {
  upvar #0 $name data

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  set size $data(-size)
  set tag $name

  set sx [expr $x + $size]
  set sy [expr $y + $size]
  set data(sx) $sx
  set data(sy) $sy
  catch [list $canvas delete $tag]
  $canvas create oval $x $y $sx $sy \
		-outline "$data(-outline)" \
		-fill    "$data(-background)" \
		-width   2 \
		-tag     $tag
  set tenth [expr double($size) / 10.0]
  set tenth2 [expr $tenth * 2.0]
  set data(tenth) $tenth
  set data(tenth2) $tenth2
  set centerX [expr $x + ($size * 0.5)]
  set centerY [expr $y + ($size * 0.5)]
  set data(centerX) $centerX
  set data(centerY) $centerY
  set hubsize $tenth
  set hubX    [expr $centerX - ($hubsize / 2.0)]
  set hubY    [expr $centerY - ($hubsize / 2.0)]
  set hubSX   [expr $centerX + ($hubsize / 2.0)]
  set hubSY   [expr $centerY + ($hubsize / 2.0)]
  $canvas create oval $hubX $hubY $hubSX $hubSY \
  		-outline {} \
		-fill    "$data(-hubColor)" \
		-tag	$tag
  set oldstart -2
  set angle 30
  for {set i 0} {$i < 12} {incr i} {
    $canvas create arc [expr $x + $tenth] [expr $y + $tenth] \
    			[expr $sx - $tenth] [expr $sy - $tenth] \
			-outline   "$data(-scaleTicks)" \
			-fill {} -style arc \
			-start $oldstart -extent 4 \
			-width $tenth2 \
			-tag $tag
    set oldstart [expr $oldstart + $angle]
  }

  $canvas create text $centerX [expr $sy + 3] -anchor n -text "$data(-label)" \
	-fill "$data(-labelColor)" -font "$data(-labelFont)"

  set hangle [expr -90]
  if {$hangle < 0} {set  hangle [expr $hangle + 360]}
  set mangle [expr -90]
  if {$mangle < 0} {incr mangle 360}

  set radius [expr double($size - $tenth) / 2.0]
  set hradians [DegreesToRadians $hangle]
  set hsX [expr ($radius * .75) * cos($hradians)]
  set hsY [expr ($radius * .75) * sin($hradians)]
  set mradians [DegreesToRadians $mangle]
  set msX [expr $radius * cos($mradians)]
  set msY [expr $radius * sin($mradians)]


  $canvas create line $centerX $centerY \
	[expr $centerX + $hsX] [expr $centerY + $hsY] \
	-fill "$data(-hourHandColor)" \
	-width [expr int(ceil(double($size)) / 100.0)] \
	-arrow last \
	-tag [list $tag ${tag}Hour]

  $canvas create line $centerX $centerY \
	[expr $centerX + $msX] [expr $centerY + $msY] \
	-fill "$data(-minuteHandColor)" \
	-width [expr int(ceil(double($size)) / 100.0)] \
	-arrow last \
	-tag [list $tag ${tag}Minute]

}

proc SetAnalogClockTime {name hour minute} {
  upvar #0 $name data

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  set size $data(-size)
  set tag $name
  set sx $data(sx)
  set sy $data(sy)
  set centerX $data(centerX)
  set centerY $data(centerY)
  set tenth $data(tenth)
  set tenth2 $data(tenth2)

  if {$hour == 12} {set hour 0}
  set hour [expr $hour + (double($minute) / 60.0)]
  set hangle [expr ($hour * 30) - 90]
  if {$hangle < 0} {set  hangle [expr $hangle + 360]}
  set mangle [expr ($minute * 6) - 90]
  if {$mangle < 0} {incr mangle 360}

  set radius [expr double($size - $tenth) / 2.0]
  set hradians [DegreesToRadians $hangle]
  set hsX [expr ($radius * .7) * cos($hradians)]
  set hsY [expr ($radius * .7) * sin($hradians)]
  set mradians [DegreesToRadians $mangle]
  set msX [expr $radius * cos($mradians)]
  set msY [expr $radius * sin($mradians)]


  $canvas coords ${tag}Hour $centerX $centerY \
	[expr $centerX + $hsX] [expr $centerY + $hsY]

  $canvas coords ${tag}Minute $centerX $centerY \
	[expr $centerX + $msX] [expr $centerY + $msY]

}

proc DigitalInstrument {canvas name args} {
  upvar #0 $name data
  DigitalInstrument_Config $canvas $name $args
  DigitalInstrument_Create $name
}

proc DigitalInstrument_Config {canvas name argList} {
  upvar #0 $name data
  # 1: the configuration specs
  #
  set specs {
      {-x          0 VerifyDouble}
      {-y	   0 VerifyDouble}
      {-size	 100 VerifyDouble}
      {-background blue}
      {-outline    black}
      {-digits    3 tclVerifyInteger}
      {-fontfamily Courier}
      {-digitColor black}
      {-label DigitalInstrument}
      {-labelColor black}
      {-labelFont {Times 14 bold}}
  }
  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}

proc DigitalInstrument_Create {name} {
  upvar #0 $name data

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  set size $data(-size)
  set tag $name


  catch [list $canvas delete $tag]
  set tempid [$canvas create text 0 0 -anchor nw \
	-text [format "%0$data(-digits)d" 0] \
	-font [list "$data(-fontfamily)" -[expr int(ceil($size - 4.0))] bold]]
  set digBBox [$canvas bbox $tempid]
  $canvas delete $tempid
  set digwidth [expr [lindex $digBBox 2] + 4.0]
  set digheight [expr [lindex $digBBox 3] + 4.0]
  set centerX [expr $x + ($digwidth * 0.5)]
  set centerY [expr $y + ($digheight * 0.5)]
  set data(centerX) $centerX
  set data(centerY) $centerY
  set sx [expr $x + $digwidth]
  set sy [expr $y + $digheight]
  set data(sx) $sx
  set data(sy) $sy
  set db [$canvas create rectangle $x $y \
		  [expr $x + $digwidth] [expr $y + $digheight] \
		  -outline "$data(-outline)" \
		  -fill    "$data(-background)" \
		  -tag     $tag]
  set DBBox [$canvas bbox $db]
  set data(dTextX) [expr [lindex $DBBox 0] + 2]
  set data(dTextY) [expr [lindex $DBBox 1] + 2]
  
  $canvas create text $data(dTextX) $data(dTextY) \
	-text [format "%$data(-digits)d" 0] \
	-font [list "$data(-fontfamily)" -[expr int(ceil($size - 4.0))] bold] \
	-anchor nw \
	-fill "$data(-digitColor)" \
	-tag [list $tag ${tag}Value]

  $canvas create text $centerX [expr $sy + 3] -anchor n -text "$data(-label)" \
	-fill "$data(-labelColor)" -font "$data(-labelFont)"


}

proc SetDigitalInstrumentValue {name val} {
  upvar #0 $name data

  set canvas $data(canvas)
  set tag $name
  $canvas itemconfigure ${tag}Value \
	-text [format "%$data(-digits)d" [expr int($val)]]
}

proc DigitalClock {canvas name args} {
  upvar #0 $name data
  DigitalClock_Config $canvas $name $args
  DigitalClock_Create $name
}

proc DigitalClock_Config {canvas name argList} {
  upvar #0 $name data
  # 1: the configuration specs
  #
  set specs {
      {-x          0 VerifyDouble}
      {-y	   0 VerifyDouble}
      {-size	 100 VerifyDouble}
      {-background white}
      {-fontfamily Courier}
      {-outline    black}
      {-digitColor black}
      {-label Clock}
      {-labelColor black}
      {-labelFont {Times 14 bold}}
  }
  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}

proc DigitalClock_Create {name} {
  upvar #0 $name data
  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  set size $data(-size)
  set tag $name

  catch [list $canvas delete $tag]
  set tempid [$canvas create text 0 0 -anchor nw \
	-text [format "%2d:%02d" 0 0] \
	-font [list "$data(-fontfamily)" -[expr int(ceil($size - 4.0))] bold]]
  set digBBox [$canvas bbox $tempid]
  $canvas delete $tempid
  set digwidth [expr [lindex $digBBox 2] + 4.0]
  set digheight [expr [lindex $digBBox 3] + 4.0]
  set centerX [expr $x + ($digwidth * 0.5)]
  set centerY [expr $y + ($digheight * 0.5)]
  set data(centerX) $centerX
  set data(centerY) $centerY
  set sx [expr $x + $digwidth]
  set sy [expr $y + $digheight]
  set data(sx) $sx
  set data(sy) $sy
  set db [$canvas create rectangle $x $y \
		  [expr $x + $digwidth] [expr $y + $digheight] \
		  -outline "$data(-outline)" \
		  -fill    "$data(-background)" \
		  -tag     $tag]
  set DBBox [$canvas bbox $db]
  set data(dTextX) [expr [lindex $DBBox 0] + 2]
  set data(dTextY) [expr [lindex $DBBox 1] + 2]
  
  $canvas create text $data(dTextX) $data(dTextY) \
	-text [format "%2d:%02d" 12 0] \
	-font [list "$data(-fontfamily)" -[expr int(ceil($size - 4.0))] bold] \
	-anchor nw \
	-fill "$data(-digitColor)" \
	-tag [list $tag ${tag}Value]

  $canvas create text $centerX [expr $sy + 3] -anchor n -text "$data(-label)" \
	-fill "$data(-labelColor)" -font "$data(-labelFont)"


}
        
proc SetDigitalClockTime {name hour minute} {
  upvar #0 $name data

  set canvas $data(canvas)
  set tag $name
  $canvas itemconfigure ${tag}Value \
	-text [format "%2d:%02d" [expr int($hour)] [expr int($minute)]]
}

proc CabSignalLamp {canvas name args} {
  upvar #0 $name data
  CabSignalLamp_Config $canvas $name $args
  CabSignalLamp_Create $name
}

proc CabSignalLamp_Config {canvas name argList} {
  upvar #0 $name data

  # 1: the configuration specs
  #
  set specs {
      {-x          0 VerifyDouble}
      {-y	   0 VerifyDouble}
      {-size	 100 VerifyDouble}
  }

  # 2: parse the arguments
  #
  canvasItemParseConfigSpec $name $specs "" $argList
  set data(canvas) $canvas
}

proc CabSignalLamp_Create {name} {
  upvar #0 $name data

  set x $data(-x)
  set y $data(-y)
  set size $data(-size)
  set tag $name
  set canvas $data(canvas)

  set sx [expr $x + $size]
  set sy [expr $y + $size]
  set data(sx) $sx
  set data(sy) $sy
  catch [list $canvas delete $tag]
  $canvas create oval $x $y $sx $sy \
 	-outline black -fill black \
	-width [expr $size * .15] \
	-tag     $tag
}

proc SetCabSignalLampColor {name color} {
  upvar #0 $name data
  
  set canvas $data(canvas)
  set tag $name

  $canvas itemconfigure $tag -fill "$color"
}


package provide Instruments 1.0
