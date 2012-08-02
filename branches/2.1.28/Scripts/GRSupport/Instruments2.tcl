#* 
#* ------------------------------------------------------------------
#* Instruments2.tcl - Instruments Version 2
#* Created by Robert Heller on Thu Jan 25 08:57:23 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/11/30 13:56:51  heller
#* Modification History: Novemeber 30, 2007 lockdown.
#* Modification History:
#* Modification History: Revision 1.2  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.1  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
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

package require grsupport 2.0
package require snit

## @addtogroup GRSupportModule
#  @{

namespace eval Instruments {
## @brief Namespace used for instruments code.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#



snit::macro Instruments::CommonOptions {defaultLabel} {
## Snit macro to define common options used by all instruments.
# @param defaultLabel Default value for the label.
# @param ... Options:
# @arg -x The X coordinate of the instrument (default 0).
# @arg -y The Y coordinate of the instrument (default 0).
# @arg -size The size of the instrument (default 100).
# @arg -label The label of the instrument.
# @arg -labelcolor The color of the label (default black).
# @arg -labelfont The font of the label (default {Times 14 bold}).
# @arg -background The background color of the instrument (default blue).
# @arg -outline The outline color of the instrument (default black).
# @arg -scaleback The background color of the scale (default white).
# @arg -scaleticks The color of the scale ticks (default black).
# @arg -fontfamily The font family used on the instrument (default Courier).

  method _ConfigureXY {option value} {
  ## Method to configure X or Y.
  # @param option The name of the option to configure.
  # @param value The new value.

    set oldx $options(-x)
    set oldy $options(-y)
    set options($option) $value
    set dx [expr {$oldx - $options(-x)}]
    set dy [expr {$oldy - $options(-y)}]
    $canvas move $selfns $dx $dy
    set x $options(-x)
    set y $options(-y)
    set size $options(-size)
    set sx [expr {$x + $size}]
    set sy [expr {$y + $size}]
    set centerX [expr {$x + ($size * 0.5)}]
    set centerY [expr {$y + ($size * 0.5)}]
  }
  method _ConfigureSize {option value} {
  ## Method to configure size.
  # @param option The name of the option to configure.
  # @param value The new value.

    set deltaSize [expr {double($value) / double($options($option))}]
    set options($option) $value
    $canvas scale $selfns $options(-x) $options(-y) $deltaSize $deltaSize
    set x $options(-x)
    set y $options(-y)
    set size $options(-size)
    set sx [expr {$x + $size}]
    set sy [expr {$y + $size}]
    set tenth [expr {double($size) / 10.0}]
    set tenth2 [expr {$tenth * 2.0}]
    set centerX [expr {$x + ($size * 0.5)}]
    set centerY [expr {$y + ($size * 0.5)}]
  }
  method _ConfigureLabel {option value} {
  ## Method to configure the label.
  # @param option The name of the option to configure.
  # @param value The new value.

    set options($option) $value
    set  tag $selfns
    switch -- $option {
      -label {$canvas itemconfigure ${tag}Label -text "$value"}
      -labelcolor {$canvas itemconfigure ${tag}Label -fill "$value"}
      -labelfont {$canvas itemconfigure ${tag}Label -font "$value"}
    }
  }
  method _ConfigureFillColor {option value} {
  ## Method to configure a fill color.
  # @param option The name of the option to configure.
  # @param value The new value.

    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -fill "$value"}
  }
  method _ConfigureOutlineColor {option value} {
  ## Method to configure an outline color.
  # @param option The name of the option to configure.
  # @param value The new value.

    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -outline "$value"}
  }
  method _ConfigureFontFamily {option value} {
  ## Method to configure a font family.
  # @param option The name of the option to configure.
  # @param value The new value.

    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}-fontfamily \
		-font [list "$options(-fontfamily)" \
			    -[expr {int(ceil($tenth))}] bold]}
  }
  GRSupport::VerifyDoubleMethod
  GRSupport::VerifyIntegerMethod
  GRSupport::VerifyColorMethod
  GRSupport::VerifyBooleanMethod
  option -x -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
  option -y -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
  option -size -default 100 -validatemethod _VerifyDouble -configuremethod _ConfigureSize
  option -label -default "$defaultLabel" -configuremethod _ConfigureLabel
  option {-labelcolor labelColor LabelColor} -default black -validatemethod _VerifyColor -configuremethod _ConfigureLabel
  option {-labelfont labelFont LabelFont} -default {Times 14 bold} -configuremethod _ConfigureLabel
  option -background  -default blue -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
  option -outline -default black -validatemethod _VerifyColor -configuremethod _ConfigureOutlineColor
  option {-scaleback scaleBack ScaleBack} -default white -validatemethod _VerifyColor -configuremethod _ConfigureOutlineColor
  option {-scaleticks scaleTicks ScaleTicks} -default black -validatemethod _VerifyColor -configuremethod _ConfigureOutlineColor
  option {-fontfamily fontFamily FontFamily} -default Courier -configuremethod _ConfigureFontFamily
  variable sx
  variable sy
  variable tenth
  variable tenth2
  variable extents
  variable centerX
  variable centerY
  variable canvas
}

  snit::type DialInstrument {
  ## Generic dial instrument.
  # @param _canvas The canvas to draw the dial instrument on.
  # @param ... Options:
  # @arg -x The X coordinate of the instrument (default 0).
  # @arg -y The Y coordinate of the instrument (default 0).
  # @arg -size The size of the instrument (default 100).
  # @arg -label The label of the instrument (default DialInstrument).
  # @arg -labelcolor The color of the label (default black).
  # @arg -labelfont The font of the label (default {Times 14 bold}).
  # @arg -background The background color of the instrument (default blue).
  # @arg -outline The outline color of the instrument (default black).
  # @arg -scaleback The background color of the scale (default white).
  # @arg -scaleticks The color of the scale ticks (default black).
  # @arg -fontfamily The font family used on the instrument (default 
  #		Courier).
  # @arg -maxvalue The maximum value (default 100).
  # @arg -minvalue The minimum value (default 0).
  # @arg -minat The pointer position, in degrees, of the minimum value 
  #			(default 225).
  # @arg -maxat The pointer position, in degrees, of the maximum value
  #			(default 315).
  # @arg -pointercolor The color of the pointer (default black).
  # @arg -secondpointerp Should a second pointer be drawn (default no)?
  # @arg -secondpointercolor The color of the second pointer (default red).
  # @arg -scaleticksinterval The interval of the scale ticks (default 10).
  # @arg -digitalp Should a digital display also be included (default yes)?
  # @arg -digits How many digits for the digital display (default 3).
  # @arg -digitalbackground The background color of the digital display 
  #		(default white).
  # @arg -digitaldigitcolor The foreground folor of the digital display
  #		(default black).
  # @par
  # @author Robert Heller \<heller\@deepsoft.com\>
  #

    Instruments::CommonOptions DialInstrument
    option {-maxvalue maxValue MaxValue} -default 100 -validatemethod _VerifyInteger -readonly yes
    option {-minvalue minValue MinValue} -default 0 -validatemethod _VerifyInteger -readonly yes
    option {-minat minAt MinAt} -default 225 -validatemethod _VerifyInteger -readonly yes
    option {-maxat maxAt MaxAt} -default 315 -validatemethod _VerifyInteger -readonly yes
    option {-pointercolor pointerColor PointerColor} -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    option {-secondpointerp secondPointerP SecondPointerP} -default no -validatemethod _VerifyBoolean -readonly yes
    option {-secondpointercolor secondPointerColor SecondPointerColor} -default red -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    option {-scaleticksinterval scaleTicksInterval ScaleTicksInterval} -default 10 -validatemethod _VerifyInteger -readonly  yes
    option {-digitalp digitalP DigitalP} -default yes -validatemethod _VerifyBoolean -readonly yes
    option -digits -default 3 -validatemethod _VerifyInteger -readonly yes
    option {-digitalbackground digitalBackground DigitalBackground} -default white -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    option {-digitaldigitcolor digitalDigitColor DigitalDigitColor} -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    variable ValueRange
    ## Value range.
    variable dTextX
    ## X position of the dial text.
    variable dTextY
    ## Y position of the dial text.
    constructor {_canvas args} {
    ##  Constructor -- initialize a DialInstrument.
    # @param _canvas The canvas to draw the DialInstrument on.
    # @param ... Option  list.

      set canvas $_canvas
      $self configurelist $args
      set tag $selfns
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)
      set sx [expr {$x + $size}]
      set sy [expr {$y + $size}]
      catch {$canvas delete $tag}
      $canvas create oval $x $y $sx $sy \
			-outline "$options(-outline)" \
			-fill    "$options(-background)" \
			-width   2 \
			-tag     [list $tag ${tag}-background ${tag}-outline]
      set tenth [expr {double($size) / 10.0}]
      set tenth2 [expr {$tenth * 2.0}]
      if {$options(-maxat) > 0} {
	set extents [expr {$options(-minat) + (360 - $options(-maxat))}]
      } else {
        set extents [expr {$options(-minat) - $options(-maxat)}]
      }
      $canvas create arc [expr {$x + $tenth}]  [expr {$y + $tenth}] \
			 [expr {$sx - $tenth}] [expr {$sy - $tenth}] \
			 -outline    "$options(-scaleback)" \
			 -fill {} -style arc \
			 -width $tenth2 \
			 -start $options(-maxat) \
			 -extent $extents \
			 -tag [list $tag ${tag}-scaleback]
      set centerX [expr {$x + ($size * 0.5)}]
      set centerY [expr {$y + ($size * 0.5)}]
      set hubsize $tenth
      set hubX    [expr {$centerX - ($hubsize / 2.0)}]
      set hubY    [expr {$centerY - ($hubsize / 2.0)}]
      set hubSX   [expr {$centerX + ($hubsize / 2.0)}]
      set hubSY   [expr {$centerY + ($hubsize / 2.0)}]
      $canvas create oval $hubX $hubY $hubSX $hubSY \
			-outline {} \
			-fill    "$options(-pointercolor)" \
			-tag    [list $tag ${tag}-pointercolor]

      set numticks [expr {int(ceil(double($options(-maxvalue) - \
					  $options(-minvalue)) / \
			      double($options(-scaleticksinterval))))}]
      set oldstart [expr {$options(-maxat) - 2}]
      set angle [expr {double($extents) / double($numticks)}]
      for {set i 0} {$i <= $numticks} {incr i} {
	$canvas create arc [expr {$x + $tenth}]  [expr {$y + $tenth}] \
			   [expr {$sx - $tenth}] [expr {$sy - $tenth}] \
			   -outline   "$options(-scaleticks)" \
			   -fill {} -style arc \
			   -start $oldstart -extent 4 \
			   -width $tenth2 \
			   -tag [list $tag ${tag}-scaleticks]
	set oldstart [expr {$oldstart + $angle}]
	if {$oldstart >= 360} {set oldstart [expr {$oldstart - 360}]}
      }
      set ValueRange  [expr {$options(-maxvalue) - $options(-minvalue)}]
      if {$options(-digitalp)} {  
	set tempid [$canvas create text 0 0 -anchor nw \
		-text [format "%0$options(-digits)d" 0] \
		-font [list "$options(-fontfamily)" \
			    -[expr {int(ceil($tenth))}] bold]]
	set digBBox [$canvas bbox $tempid]
	$canvas delete $tempid
	set digwidth  [expr {[lindex $digBBox 2] + 4.0}]
	set digheight [expr {[lindex $digBBox 3] + 4.0}]
	set db [$canvas create rectangle [expr {$centerX - ($digwidth / 2.0)}] \
					 [expr {$sy - $tenth - $digheight}] \
					 [expr {$centerX + ($digwidth / 2.0)}] \
					 [expr {$sy - $tenth}] \
					 -outline {} \
					 -fill "$options(-digitalbackground)" \
					 -tag [list $tag ${tag}-digitalbackground]]
	set DBBox [$canvas bbox $db]
	set dTextX [expr {[lindex $DBBox 0] + 2}]
	set dTextY [expr {[lindex $DBBox 1] + 2}]
      }

      $canvas create text $centerX [expr {$sy + 3}] -anchor n \
			  -text "$options(-label)" \
			  -fill "$options(-labelcolor)" \
			  -font "$options(-labelfont)"  \
			  -tag [list $tag ${tag}Label]

      set ValueOffset 0

      set relAngle [expr {(double($ValueOffset) / double($ValueRange)) * \
			  $extents}]
      set angle [expr {$options(-minat) + $relAngle}]
      if {$angle > 360} {set angle [expr {$angle - 360}]}

      if {[expr $angle - 90] < 0} {
	set radians [GRSupport::DegreesToRadians [expr {360 + ($angle - 90)}]]
      } else {
	set radians [GRSupport::DegreesToRadians [expr {$angle - 90}]]
      }
      set radius [expr {double($size - $tenth) / 2.0}]
      set psX [expr {$radius * cos($radians)}]
      set psY [expr {$radius * sin($radians)}]

      $canvas create line $centerX $centerY \
		[expr {$centerX + $psX}] [expr {$centerY + $psY}] \
		-fill "$options(-pointercolor)" \
		-width [expr {int(ceil(double($size)) / 100.0)}] \
		-arrow last \
		-tag [list $tag ${tag}Pointer ${tag}-pointercolor]

      if {$options(-secondpointerp)} {
	set ValueOffset 0

	set relAngle [expr {(double($ValueOffset) / double($ValueRange)) * \
			    $extents}]
	set angle [expr {$options(-minat) + $relAngle}]
	if {$angle > 360} {set angle [expr {$angle - 360}]}
	if {[expr {$angle - 90}] < 0} {
	  set radians [GRSupport::DegreesToRadians [expr {360 + ($angle - 90)}]]
	} else {
	  set radians [GRSupport::DegreesToRadians [expr {$angle - 90}]]
	}
	set radius [expr {double($size - $tenth) / 2.0}]
	set psX [expr {$radius * cos($radians)}]
	set psY [expr {$radius * sin($radians)}]

	$canvas create line $centerX $centerY \
		[expr {$centerX + $psX}] [expr {$centerY + $psY}] \
		-fill "$options(-secondpointercolor)" \
		-width [expr {int(ceil(double($size)) / 100.0)}] \
		-arrow last \
		-tag [list $tag ${tag}SecondPointer  ${tag}-secondpointercolor]

      }

      if {$options(-digitalp)} {
	$canvas create text $dTextX $dTextY \
    		   -text [format "%$options(-digits)d" 0] \
		   -font [list "$options(-fontfamily)" \
				-[expr {int(ceil($tenth))}] bold] \
		   -anchor nw \
		   -fill "$options(-digitaldigitcolor)" \
		   -tag [list $tag ${tag}DigitalDigits \
			      ${tag}-digitaldigitcolor ${tag}-fontfamily]
      }
    }
    destructor {
    ## Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
    method setvalue {value {value2 0}} {
    ## Method to set the value of the dial instrument.
    # @param value The value to set the instrument to.
    # @param value2 The value for the second pointer.

      set y $options(-y)
      set size $options(-size)
      set tag $selfns

      if {$value <  $options(-minvalue)} {set value $options(-minvalue)}
      if {$value >  $options(-maxvalue)} {set value $options(-maxvalue)}

      set ValueOffset  [expr {$value - $options(-minvalue)}]
      set relAngle [expr {(double($ValueOffset) / double($ValueRange)) \
			  * $extents}]
      set angle [expr {$options(-minat) + $relAngle}]
      if {$angle > 360} {set angle [expr {$angle - 360}]}
      if {[expr {$angle - 90}] < 0} {
	set radians [GRSupport::DegreesToRadians [expr {360 + ($angle - 90)}]]
      } else {
	set radians [GRSupport::DegreesToRadians [expr {$angle - 90}]]
      }
      set radius [expr {double($size - $tenth) / 2.0}]
      set psX [expr {$radius * cos($radians)}]
      set psY [expr {$radius * sin($radians)}]

      $canvas coords ${tag}Pointer $centerX $centerY \
			[expr {$centerX + $psX}] [expr {$centerY + $psY}]
      if {$options(-secondpointerp)} {
	if {$value2 <  $options(-minvalue)} {set value2 $options(-minvalue)}
	if {$value2 >  $options(-maxvalue)} {set value2 $options(-maxvalue)}
	set ValueOffset [expr {$value2 - $options(-minvalue)}]

	set relAngle [expr {(double($ValueOffset) / double($ValueRange)) * \
			    $extents}]
	set angle [expr {$options(-minat) + $relAngle}]
	if {$angle > 360} {set angle [expr {$angle - 360}]}
	if {[expr {$angle - 90}] < 0} {
	  set radians [GRSupport::DegreesToRadians [expr {360 + ($angle - 90)}]]
	} else {
	  set radians [GRSupport::DegreesToRadians [expr {$angle - 90}]]
	}
	set radius [expr {double($size - $tenth) / 2.0}]
	set psX [expr {$radius * cos($radians)}]
	set psY [expr {$radius * sin($radians)}]

	$canvas coords ${tag}SecondPointer $centerX $centerY \
		[expr {$centerX + $psX}] [expr {$centerY + $psY}]
      }

      if {$options(-digitalp)} {
	$canvas itemconfigure ${tag}DigitalDigits \
	   -text [format "%$options(-digits)d" [expr {int($value)}]]
      }
      set y $options(-y)
      set size $options(-size)
      set tag $selfns

      if {$value <  $options(-minvalue)} {set value $options(-minvalue)}
      if {$value >  $options(-maxvalue)} {set value $options(-maxvalue)}

      set ValueOffset  [expr {$value - $options(-minvalue)}]
      set relAngle [expr {(double($ValueOffset) / double($ValueRange)) \
			  * $extents}]
      set angle [expr {$options(-minat) + $relAngle}]
      if {$angle > 360} {set angle [expr {$angle - 360}]}
      if {[expr {$angle - 90}] < 0} {
	set radians [GRSupport::DegreesToRadians [expr {360 + ($angle - 90)}]]
      } else {
	set radians [GRSupport::DegreesToRadians [expr {$angle - 90}]]
      }
      set radius [expr {double($size - $tenth) / 2.0}]
      set psX [expr {$radius * cos($radians)}]
      set psY [expr {$radius * sin($radians)}]

      $canvas coords ${tag}Pointer $centerX $centerY \
			[expr {$centerX + $psX}] [expr {$centerY + $psY}]
      if {$options(-secondpointerp)} {
	if {$value2 <  $options(-minvalue)} {set value2 $options(-minvalue)}
	if {$value2 >  $options(-maxvalue)} {set value2 $options(-maxvalue)}
	set ValueOffset [expr {$value2 - $options(-minvalue)}]

	set relAngle [expr {(double($ValueOffset) / double($ValueRange)) * \
			    $extents}]
	set angle [expr {$options(-minat) + $relAngle}]
	if {$angle > 360} {set angle [expr {$angle - 360}]}
	if {[expr {$angle - 90}] < 0} {
	  set radians [GRSupport::DegreesToRadians [expr {360 + ($angle - 90)}]]
	} else {
	  set radians [GRSupport::DegreesToRadians [expr {$angle - 90}]]
	}
	set radius [expr {double($size - $tenth) / 2.0}]
	set psX [expr {$radius * cos($radians)}]
	set psY [expr {$radius * sin($radians)}]

	$canvas coords ${tag}SecondPointer $centerX $centerY \
		[expr {$centerX + $psX}] [expr {$centerY + $psY}]
      }

      if {$options(-digitalp)} {
	$canvas itemconfigure ${tag}DigitalDigits \
	   -text [format "%$options(-digits)d" [expr {int($value)}]]
      }
    }
  }
  snit::type AnalogClock {
  ## Analog clock instrument.
  # @param _canvas The canvas to draw the analog clock on.
  # @param ... Options:
  # @arg -x The X coordinate of the instrument (default 0).
  # @arg -y The Y coordinate of the instrument (default 0).
  # @arg -size The size of the instrument (default 100).
  # @arg -label The label of the instrument (default Clock).
  # @arg -labelcolor The color of the label (default black).
  # @arg -labelfont The font of the label (default {Times 14 bold}).
  # @arg -background The background color of the instrument (default blue).
  # @arg -outline The outline color of the instrument (default black).
  # @arg -scaleback The background color of the scale (default white).
  # @arg -scaleticks The color of the scale ticks (default black).
  # @arg -fontfamily The font family used on the instrument (default 
  #		Courier).
  # @arg -hubcolor The color of the hub (default black).
  # @arg -minutehandcolor The color of the  minute hand (default black).
  # @arg -hourhandcolor The color of the hour hand (default black).
  # @par
  # @author Robert Heller \<heller\@deepsoft.com\>
  #

    Instruments::CommonOptions Clock
    option {-hubcolor hubColor HubColor} -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    option {-minutehandcolor minuteHandColor MinuteHandColor} -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    option {-hourhandcolor hourHandColor HourHandColor} -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    constructor {_canvas args} {
    ## Constructor -- initialize an analog clock.
    # @param _canvas The canvas to draw the DialInstrument on.
    # @param ... Option  list.

      set canvas $_canvas
      $self configurelist $args
      set tag $selfns
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)
      set sx [expr {$x + $size}]
      set sy [expr {$y + $size}]
      catch {$canvas delete $tag}
      $canvas create oval $x $y $sx $sy \
		-outline "$options(-outline)" \
		-fill    "$options(-background)" \
		-width   2 \
		-tag     [list $tag  ${tag}-outline  ${tag}-background]
      set tenth [expr {double($size) / 10.0}]
      set tenth2 [expr {$tenth * 2.0}]
      set centerX [expr {$x + ($size * 0.5)}]
      set centerY [expr {$y + ($size * 0.5)}]
      set hubsize $tenth
      set hubX    [expr {$centerX - ($hubsize / 2.0)}]
      set hubY    [expr {$centerY - ($hubsize / 2.0)}]
      set hubSX   [expr {$centerX + ($hubsize / 2.0)}]
      set hubSY   [expr {$centerY + ($hubsize / 2.0)}]
      $canvas create oval $hubX $hubY $hubSX $hubSY \
	  		-outline {} \
			-fill    "$options(-hubcolor)" \
			-tag	[list $tag ${tag}-hubcolor]
      set oldstart -2
      set angle 30
      for {set i 0} {$i < 12} {incr i} {
	$canvas create arc [expr {$x + $tenth}] [expr {$y + $tenth}] \
	    		   [expr {$sx - $tenth}] [expr {$sy - $tenth}] \
			   -outline   "$options(-scaleticks)" \
			   -fill {} -style arc \
			   -start $oldstart -extent 4 \
			   -width $tenth2 \
			   -tag [list  $tag ${tag}-scaleticks]
	set oldstart [expr {$oldstart + $angle}]
      }

      $canvas create text $centerX [expr {$sy + 3}] -anchor n \
			  -text "$options(-label)" \
			  -fill "$options(-labelcolor)" \
			  -font "$options(-labelfont)" \
			  -tag [list $tag ${tag}Label]

      set hangle -90
      if {$hangle < 0} {set  hangle [expr {$hangle + 360}]}
      set mangle -90
      if {$mangle < 0} {incr mangle 360}

      set radius [expr {double($size - $tenth) / 2.0}]
      set hradians [GRSupport::DegreesToRadians $hangle]
      set hsX [expr {($radius * .75) * cos($hradians)}]
      set hsY [expr {($radius * .75) * sin($hradians)}]
      set mradians [GRSupport::DegreesToRadians $mangle]
      set msX [expr {$radius * cos($mradians)}]
      set msY [expr {$radius * sin($mradians)}]


      $canvas create line $centerX $centerY \
		[expr {$centerX + $hsX}] [expr {$centerY + $hsY}] \
		-fill "$options(-hourhandcolor)" \
		-width [expr {int(ceil(double($size)) / 100.0)}] \
		-arrow last \
		-tag [list $tag ${tag}Hour  ${tag}-hourhandcolor]

      $canvas create line $centerX $centerY \
	[expr {$centerX + $msX}] [expr {$centerY + $msY}] \
	-fill "$options(-minutehandcolor)" \
	-width [expr {int(ceil(double($size)) / 100.0)}] \
	-arrow last \
	-tag [list $tag ${tag}Minute ${tag}-minutehandcolor]

    }
    destructor {
    ## Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
    method settime {hour minute} {
    ## Method to set the time.
    # @param hour The hour, an integer between 1 and 12.
    # @param minute The minute, an integer between 0 and 59.

      set tag $selfns
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)

      while {$minute < 0} {
	set minute [expr {$minute + 60}]
	set hour [expr {$hour - 1}]
      }
      while {$minute > 59} {
        set minute [expr {$minute - 60}]
	set hour [expr {$hour + 1}]
      }
      if {$hour < 0} {set hour 0}
      while {$hour >= 12} {set hour [expr {$hour - 12}]}
      set hour [expr {$hour + (double($minute) / 60.0)}]
      set hangle [expr {($hour * 30) - 90}]
      if {$hangle < 0} {set  hangle [expr {$hangle + 360}]}
      set mangle [expr {($minute * 6) - 90}]
      if {$mangle < 0} {incr mangle 360}
      set radius [expr {double($size - $tenth) / 2.0}]
      set hradians [GRSupport::DegreesToRadians $hangle]
      set hsX [expr {($radius * .7) * cos($hradians)}]
      set hsY [expr {($radius * .7) * sin($hradians)}]
      set mradians [GRSupport::DegreesToRadians $mangle]
      set msX [expr {$radius * cos($mradians)}]
      set msY [expr {$radius * sin($mradians)}]

      $canvas coords ${tag}Hour $centerX $centerY \
	[expr {$centerX + $hsX}] [expr {$centerY + $hsY}]

      $canvas coords ${tag}Minute $centerX $centerY \
	[expr {$centerX + $msX}] [expr {$centerY + $msY}]

    }
  }
  snit::type DigitalInstrument {
  ## Digital instrument.
  # @param _canvas The canvas to draw the digital instrument on.
  # @param ... Options:
  # @arg -x The X coordinate of the instrument (default 0).
  # @arg -y The Y coordinate of the instrument (default 0).
  # @arg -size The size of the instrument (default 100).
  # @arg -label The label of the instrument (default DigitalInstrument).
  # @arg -labelcolor The color of the label (default black).
  # @arg -labelfont The font of the label (default {Times 14 bold}).
  # @arg -background The background color of the instrument (default blue).
  # @arg -outline The outline color of the instrument (default black).
  # @arg -scaleback The background color of the scale (default white).
  # @arg -scaleticks The color of the scale ticks (default black).
  # @arg -fontfamily The font family used on the instrument (default 
  #		Courier).
  # @arg -digitcolor The color of the digits (default black).
  # @arg -digits The number of digits (default 3).
  # @par
  # @author Robert Heller \<heller\@deepsoft.com\>
  #

    Instruments::CommonOptions DigitalInstrument
    option {-digitcolor digitColor DigitColor}  -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    option -digits -default 3 -validatemethod _VerifyInteger -readonly yes
    constructor {_canvas args} {
    ## Constructor -- initialize a digital instrument.
    # @param _canvas The canvas to draw the DialInstrument on.
    # @param ... Option  list.

      set canvas $_canvas
      $self configurelist $args
      set tag $selfns
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)
      catch [list $canvas delete $tag]
      set tempid [$canvas create text 0 0 -anchor nw \
		-text [format "%0$options(-digits)d" 0] \
		-font [list "$options(-fontfamily)" \
			     -[expr {int(ceil($size - 4.0))}] bold]]
      set digBBox [$canvas bbox $tempid]
      $canvas delete $tempid
      set digwidth [expr [lindex $digBBox 2] + 4.0]
      set digheight [expr [lindex $digBBox 3] + 4.0]
      set centerX [expr $x + ($digwidth * 0.5)]
      set centerY [expr $y + ($digheight * 0.5)]
      set sx [expr $x + $digwidth]
      set sy [expr $y + $digheight]
      set db [$canvas create rectangle $x $y \
		  [expr {$x + $digwidth}] [expr {$y + $digheight}] \
		  -outline "$options(-outline)" \
		  -fill    "$options(-background)" \
		  -tag     [list $tag ${tag}-outline ${tag}-background]]
      set DBBox [$canvas bbox $db]
      set dTextX [expr {[lindex $DBBox 0] + 2}]
      set dTextY [expr {[lindex $DBBox 1] + 2}]
  
      $canvas create text $dTextX $dTextY \
		-text [format "%$options(-digits)d" 0] \
		-font [list "$options(-fontfamily)" \
			    -[expr {int(ceil($size - 4.0))}] bold] \
		-anchor nw \
		-fill "$options(-digitcolor)" \
		-tag [list $tag ${tag}Value ${tag}-digitcolor \
			   ${tag}-fontfamily]

      $canvas create text $centerX [expr $sy + 3] -anchor n \
		-text "$options(-label)" \
		-fill "$options(-labelcolor)" -font "$options(-labelfont)" \
		-tag [list $tag ${tag}Label]

    }
    destructor {
    ## Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
    method setvalue {value} {
    ## Method to set the value of the digital instrument.
    # @param value The value to set the instrument to.
      set tag $selfns
      $canvas itemconfigure ${tag}Value \
		-text [format "%$options(-digits)d" [expr int($value)]]
    }
  }
  snit::type DigitalClock {
  ## Digital clock instrument.
  # @param _canvas The canvas to draw the digital clock instrument on.
  # @param ... Options:
  # @arg -x The X coordinate of the instrument (default 0).
  # @arg -y The Y coordinate of the instrument (default 0).
  # @arg -size The size of the instrument (default 100).
  # @arg -label The label of the instrument (default Clock).
  # @arg -labelcolor The color of the label (default black).
  # @arg -labelfont The font of the label (default {Times 14 bold}).
  # @arg -background The background color of the instrument (default blue).
  # @arg -outline The outline color of the instrument (default black).
  # @arg -scaleback The background color of the scale (default white).
  # @arg -scaleticks The color of the scale ticks (default black).
  # @arg -fontfamily The font family used on the instrument (default 
  #		Courier).
  # @arg -digitcolor The color of the digits (default black).
  # @par
  # @author Robert Heller \<heller\@deepsoft.com\>
  #

    Instruments::CommonOptions Clock
    option {-digitcolor digitColor DigitColor}  -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    constructor {_canvas args} {
    ## Constructor -- initialize a digital clock.
    # @param _canvas The canvas to draw the DialInstrument on.
    # @param ... Option  list.

      set canvas $_canvas
      $self configurelist $args
      set tag $selfns
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)
      catch [list $canvas delete $tag]

      set tempid [$canvas create text 0 0 -anchor nw \
		-text [format "%2d:%02d" 0 0] \
		-font [list "$options(-fontfamily)" \
			    -[expr {int(ceil($size - 4.0))}] bold]]
      set digBBox [$canvas bbox $tempid]
      $canvas delete $tempid
      set digwidth [expr {[lindex $digBBox 2] + 4.0}]
      set digheight [expr {[lindex $digBBox 3] + 4.0}]
      set centerX [expr {$x + ($digwidth * 0.5)}]
      set centerY [expr {$y + ($digheight * 0.5)}]
      set sx [expr {$x + $digwidth}]
      set sy [expr {$y + $digheight}]
      set db [$canvas create rectangle $x $y \
		  [expr {$x + $digwidth}] [expr {$y + $digheight}] \
		  -outline "$options(-outline)" \
		  -fill    "$options(-background)" \
		  -tag     [list $tag ${tag}-outline ${tag}-background]]
      set DBBox [$canvas bbox $db]
      set dTextX [expr {[lindex $DBBox 0] + 2}]
      set dTextY [expr {[lindex $DBBox 1] + 2}]
  
      $canvas create text $dTextX $dTextY \
		-text [format "%2d:%02d" 12 0] \
		-font [list "$options(-fontfamily)" \
			    -[expr {int(ceil($size - 4.0))}] bold] \
		-anchor nw \
		-fill "$options(-digitcolor)" \
		-tag [list $tag ${tag}Value ${tag}-digitcolor \
			   ${tag}-fontfamily]

      $canvas create text $centerX [expr {$sy + 3}] -anchor n \
		-text "$options(-label)" \
		-fill "$options(-labelcolor)" -font "$options(-labelfont)" \
		-tag [list $tag ${tag}Label]

    }
    destructor {
    ## Destructor -- free up all resources.

      catch {$canvas delete $selfns}
    }
    method settime {hour minute} {
    ## Method to set the time.
    # @param hour The hour, an integer between 1 and 12.
    # @param minute The minute, an integer between 0 and 59.

      set tag $selfns
      $canvas itemconfigure ${tag}Value \
		-text [format "%2d:%02d" \
				[expr {int($hour)}] [expr {int($minute)}]]
    }
  }
  snit::type CabSignalLamp {
  ## Cab signal lamp type.
  # @param _canvas The canvas to draw the cab signal lamp on.
  # @param ... Options:
  # @arg -x The X coordinate of the instrument (default 0).
  # @arg -y The Y coordinate of the instrument (default 0).
  # @arg -size The size of the instrument (default 100).
  # @arg -color The color of the lamp (default black).
  # @arg -outline The outline color of the instrument (default black).
  # @par
  # @author Robert Heller \<heller\@deepsoft.com\>
  #

    method _ConfigureXY {option value} {
    ## Method to configure X or Y.
    # @param option The name of the option to configure.
    # @param value The new value.

      set oldx $options(-x)
      set oldy $options(-y)
      set options($option) $value
      set dx [expr {$oldx - $options(-x)}]
      set dy [expr {$oldy - $options(-y)}]
      $canvas move $selfns $dx $dy
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)
      set sx [expr {$x + $size}]
      set sy [expr {$y + $size}]
      set centerX [expr {$x + ($size * 0.5)}]
      set centerY [expr {$y + ($size * 0.5)}]
    }
    method _ConfigureSize {option value} {
    ## Method to configure size.
    # @param option The name of the option to configure.
    # @param value The new value.

      set deltaSize [expr {$options($option) - $value}]
      set options($option) $value
      $canvas scale $selfns $options(-x) $options(-y) $deltaSize $deltaSize
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)
      set sx [expr {$x + $size}]
      set sy [expr {$y + $size}]
      set tenth [expr {double($size) / 10.0}]
      set tenth2 [expr {$tenth * 2.0}]
      set centerX [expr {$x + ($size * 0.5)}]
      set centerY [expr {$y + ($size * 0.5)}]
    }
    method _ConfigureFillColor {option value} {
    ## Method to configure a fill color.
    # @param option The name of the option to configure.
    # @param value The new value.

      set options($option) $value
      set  tag $selfns
      catch {$canvas itemconfigure ${tag}$option -fill "$value"}
    }
    method _ConfigureOutlineColor {option value} {
    ## Method to configure an outline color.
    # @param option The name of the option to configure.
    # @param value The new value.

      set options($option) $value
      set  tag $selfns
      catch {$canvas itemconfigure ${tag}$option -outline "$value"}
    }
    GRSupport::VerifyDoubleMethod
    GRSupport::VerifyColorMethod
    option -x -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    option -y -default 0 -validatemethod _VerifyDouble -configuremethod _ConfigureXY
    option -size -default 100 -validatemethod _VerifyDouble -configuremethod _ConfigureSize
    option -color  -default black -validatemethod _VerifyColor -configuremethod _ConfigureFillColor
    option -outline -default black -validatemethod _VerifyColor -configuremethod _ConfigureOutlineColor
    variable canvas
    variable sx
    variable sy
    constructor  {_canvas args} {
    ##  Constructor -- initialize a Cab Signal Lamp.
    # @param _canvas The canvas to draw the DialInstrument on.
    # @param ... Option  list.

      set canvas $_canvas
      $self configurelist $args
      set tag $selfns
      set x $options(-x)
      set y $options(-y)
      set size $options(-size)
      catch [list $canvas delete $tag]
      set sx [expr {$x + $size}]
      set sy [expr {$y + $size}]
      $canvas create oval $x $y $sx $sy \
		-outline $options(-outline) \
		-fill    $options(-color) \
		-width [expr {$size * .15}] \
		-tag [list $tag ${tag}-outline ${tag}-color]
    }
    destructor {
    ## Destructor -- free up all resources.
      catch {$canvas delete $selfns}
    }
  }
}

## @}

package provide Instruments 2.0
