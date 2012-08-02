#* 
#* ------------------------------------------------------------------
#* CTCPanel2.tcl - CTC Panel Code, Version 2.0
#* Created by Robert Heller on Mon Mar  6 19:12:00 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.4  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.3  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.2  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.1  2007/01/22 23:44:25  heller
#* Modification History: added files
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
#*  $Id$
#* 

package require BWidget
package require snit

## @addtogroup TclCommon
# @{

namespace eval CTCPanel {
##
# @brief CTC Panel code, Version 2.
#
# This version of the CTC Panel code uses BWidget and snit to implement CTC
# panels and the gadgets that populate CTC panels.
# The CTC Panel code is contained in this namespace.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#


snit::widget CTCPanel {
## @brief Main CTC Panel megawidget.  
#
# This megawidget implements two display areas, 
# each with a vertical (Y) scrollbar.  They share a horizontal (X) scrollbar.
# The upper display area contains schematic trackwork and the lower display 
# area contains various switches, buttons, and lamps that deal with trackage 
# control points.
#
# @param path Pathname of the widget.
# @param ... Options:
# @arg -schematicbackground The background color of the schematic display.
#           Defaults to black.
# @arg -controlbackground The background color of the control display.
#	    Defaults to darkgreen.
# @arg -width The total width of the megawidget.
# @arg -height The total height of the megawidget.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  widgetclass CTCPanel
  hulltype frame

  component schematic
  component schematicYscroll
  component xscroll
  component controls
  component controlsYscroll

  delegate option {-schematicbackground background Background} to schematic as -background
  delegate option {-controlbackground background Background} to controls as -background
  #delegate method {schematic *} to schematic except {yview xview}
  #delegate method {controls *}  to controls  except {yview xview}
  option -width  -default 768 -validatemethod _PosInteger
  option -height -default 532 -validatemethod _PosInteger
  method _PosInteger {option value} {
  ## Method to validate a positive non zero integer option.
  # @param option The option name.
  # @param value The value to validate.

    if {![string is integer -strict "$value"]} {
      error "$option takes an integer, got $value"
    } elseif {$value < 1} {
      error "$option takes a positive non-zero integer, got $value"
    } else {
      return $value
    }
  }

  variable scale 1.0
  ## The current scale value.
  variable CPList {}
  ## The list of control points.
  variable CPData -array {}
  ## The Control point data array.
  variable Objects -array {}
  ## The object array.

  constructor {args} {
  ## Build and install all component widgets and process configuration.
  # @param ... Argument list (option value pairs).  Gets passed to the
  # 	 implicitly defined configurelist method.
  
    set options(-height) [from args -height]
    set options(-width)  [from args -width]

    set canvasHeight [expr int(($options(-height) - 20) / 2)]

#    puts stderr "*** ${type}::constructor: win = $win, hull = $hull, self = $self"
    $hull configure -borderwidth 2

    pack [frame $win.schematic -borderwidth 2] -expand yes -fill both

    install schematic using canvas $win.schematic.schematicDisplay \
		-background black \
		-height $canvasHeight \
		-width $options(-width) \
		-scrollregion [list 0 0 $options(-width) $canvasHeight]
    pack $schematic -expand yes -fill both -side left
    bind $schematic <Configure> [mymethod updateSR %W %h %w]

    install schematicYscroll using scrollbar $win.schematic.yscroll \
		-command [list $schematic yview]
    
    pack $schematicYscroll -expand yes -fill y

    pack [frame $win.middle -borderwidth 2] -fill x

    install xscroll using scrollbar $win.middle.xscroll \
			     -command [mymethod _CtcMainHScroll2] \
			     -orient {horizontal}
    pack $xscroll -expand yes -fill x -side left
    pack [frame $win.middle.filler -borderwidth {2} -height {20} -width {20}] \
	-side right

    pack [frame $win.controls -borderwidth {2}] -expand yes -fill both

    install controls using canvas $win.controls.controlsDisplay \
		-background darkgreen \
		-height $canvasHeight \
		-width $options(-width) \
		-scrollregion [list 0 0 $options(-width) $canvasHeight]
    pack $controls -expand yes -fill both -side left
    bind $controls <Configure> [mymethod updateSR %W %h %w]
    install controlsYscroll using scrollbar $win.controls.yscroll \
		-command [list $controls yview]
    pack $controlsYscroll -expand yes -fill y
    $self configurelist $args
    $schematic configure \
		-xscrollcommand [mymethod _CtcMainSyncX $schematic $controls] \
		-yscrollcommand [list $schematicYscroll set]
    $controls configure \
		-xscrollcommand [mymethod _CtcMainSyncX $controls $schematic] \
		-yscrollcommand [list $controlsYscroll set]
  }

  method _CtcMainSyncX {this other first last} {
  ## Internal method to x scroll updates. Updates the scrolling for both
  # canvases, making sure that they are in sync.  The scrollbar is also
  # updated. This method is bound to the -xscrollcommands of the
  # schematic and controls canvases.
  # @param this The canvas whose scrolling changed.
  # @param other The other canvas, which needs to be syncronized.
  # @param first The coordinate of the first (left most) visible part of the 
  #	 canvas.  Passed from the canvas.
  # @param last The coordinate of the last (right most) visible part of the 
  #	 canvas.  Passed from the canvas.

    set thisSR [$this cget -scrollregion]
    if {[llength $thisSR] == 0} {
      update idle
      $this configure -scrollregion [list 0 0 \
					  [winfo width $this] \
					  [winfo height $this]]
      set thisSR [$this cget -scrollregion]
    }
    set thisSRWidth [expr [lindex $thisSR 2] - [lindex $thisSR 0]]
    set otherSR [$other cget -scrollregion]
    if {[llength $otherSR] == 0} {
      update idle
      $other configure -scrollregion [list 0 0 \
					   [winfo width $other] \
					   [winfo height $other]]
      set otherSR [$other cget -scrollregion]
    }
    set otherSRWidth [expr [lindex $otherSR 2] - [lindex $otherSR 0]]
    set vfraction [expr $last - $first]
    set thisVSR [expr double($vfraction) * $thisSRWidth]
    set otherVSR [expr double($vfraction) * $otherSRWidth]
    if {[expr abs($thisVSR - $otherVSR)] > .0006} {
      set gfract [expr $thisVSR / $otherVSR]
      set otherLeft [lindex $otherSR 0]
      set otherRight [expr $otherLeft + ($otherSRWidth * $gfract)]
      $other configure -scrollregion [list $otherLeft [lindex $otherSR 1] \
					   $otherRight [lindex $otherSR 3]]
    }
    $other xview moveto [lindex [$this xview] 0]
    $xscroll set $first $last
  }
  method updateSR {canvas newheight newwidth} {
  ## Method to update one of the canvases scroll region. Bound to the
  # Configure event of each of the canvases.
  # @param canvas	The canvas to update.
  # @param newheight The new height.
  # @param newwidth The new width.
  
#    puts stderr "*** ==============================================="
#    puts stderr "*** CTCPanel::UpdateSR $canvas $newheight $newwidth"
    set newSR 0
    set curSR [$canvas cget -scrollregion]
#    puts stderr "*** CTCPanel::UpdateSR: (init) curSR = $curSR"
#    set allelts  [$canvas find withtag {!All_CPs}]
#    set elts {}
#    foreach el $allelts {
#      if {[lsearch -glob [$canvas gettags $el] *_outline] < 0} {
#        lappend elts $el
#      }
#    }
#    foreach e $elts {
#      puts stderr "*** CTCPanel::UpdateSR: \[$canvas gettags $e\] = [$canvas gettags $e]"
#    }
#    if {[llength $elts] == 0} {
#      set bbox [list 0 0 0 0]
#    } else {
#      set bbox  [eval [concat $canvas bbox $elts]]
#    }
    set bbox  [$canvas bbox all]
#    puts stderr "*** CTCPanel::UpdateSR: bbox = $bbox"
  
    if {[lindex $bbox 2] != [lindex $curSR 2]} {
      set curSR [lreplace $curSR 2 2 [lindex $bbox 2]]
      set newSR 1
    }
    if {[lindex $curSR 2] < $newwidth} {
      set curSR [lreplace $curSR 2 2 $newwidth]
      set newSR 1
    } 

    if {[lindex $bbox 3] != [lindex $curSR 3]} {
      set curSR [lreplace $curSR 3 3 [lindex $bbox 3]]
      set newSR 1
    }
    if {[lindex $curSR 3] < $newheight} {
      set curSR [lreplace $curSR 3 3 $newheight]
      set newSR 1
    }

#    puts stderr "*** CTCPanel::UpdateSR: newSR = $newSR"
#    puts stderr "*** CTCPanel::UpdateSR: (updated) curSR = $curSR"
    if {$newSR} {
      $canvas configure -scrollregion $curSR
      foreach cpbox [$canvas find withtag All_CPs] {
        set bbox [$canvas bbox $cpbox]
        set bbox [lreplace $bbox 1 1 [lindex $curSR 1]]
        set bbox [lreplace $bbox 3 3 [lindex $curSR 3]]
        $canvas coords $cpbox $bbox
      }
    }
#    puts stderr "*** ==============================================="
  }
  method _CtcMainHScroll2 {args} {
  ## Internal method to scroll two canvases at the same time. Bound to
  # the horizontal scrollbar's -command.
  # @param ... The arguments passed from the scroll bar.
  
    eval [list $schematic xview] $args
    eval [list $controls xview] $args
  }

  method zoomBy {zoomFactor} {
  ## Method to zoom the display by a zoom factor.
  # @param zoomFactor The zoom factor.

    $schematic scale all 0 0 $zoomFactor $zoomFactor
    $controls  scale all 0 0 $zoomFactor $zoomFactor
    set scale [expr $scale * $zoomFactor]
    $self updateSR $schematic \
	[winfo height $schematic] \
	[winfo width $schematic]
    $self updateSR $controls\
	[winfo height $controls] \
	[winfo width  $controls]
  }
  method setZoom {zoomFactor} {
  ## Method to set the zoom factor to a specific factor.
  # @param zoomFactor The zoom factor.

    if {$scale != 1} {
      set inv [expr 1.0 / double($scale)]
      $schematic scale all 0 0 $inv $inv
      $controls  scale all 0 0 $inv $inv
    }
    $schematic scale all 0 0 $zoomFactor $zoomFactor
    $controls  scale all 0 0 $zoomFactor $zoomFactor
    set scale $zoomFactor
    $self updateSR $schematic \
	[winfo height $schematic] \
	[winfo width $schematic]
    $self updateSR $controls \
	[winfo height $controls] \
	[winfo width  $controls]
  }
  method getZoom {} {
  ## Return the zoom (scaling) factor.

    return $scale
  }
  method getv {name} {
  ## Method to get the value (or state) of an object.
  # @param name The name of the object to fetch the value of.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj getv]
  }
  method setv {name value} {
  ## Method to set the value (or state) of an object.
  # @param name The name of the object to update.
  # @param value The value to set it to. See the individual element
  # descriptions for valid values.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj setv $value]
  }
  method geti {name ind} {
  ## Method to get the indicator state of an object.
  # @param name The name of the object to fetch the indicator state of.
  # @param ind The indicator whose state is return. See the individual
  # element descriptions for valid indicator names.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj geti $ind]
  }
  method seti {name ind value} {
  ## Method to set the indicator state of an object.
  # @param name The name of the object whose indicator state is to be set.
  # @param ind The indicator to update. See the individual element
  # descriptions for valid indicator names.
  # @param value The new indicator value, generally on or off.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj seti $ind $value]
  }
  method itemcget {name option} {
  ## Method to get a configuration option from an object.
  # @param name The object whose configuration option is to be fetched from.
  # @param option The option to fetch. See the individual element
  # descriptions for valid options.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj cget $option]
  }
  method itemconfigure {name args} {
  ## Method to set a configuration option from an object.
  # @param name The object whose configuration option is to be configured.
  # @param ... The configuration arguments.
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [eval [list $obj configure] $args]
  }
  method exists {name} {
  ## Test if the named object exists.
  # @param name The object to test for.

    return [expr [lsearch -exact [array names Objects] $name] >= 0]
  }
  method delete {name} {
  ## Delete a named object.
  # @param name The name of the object to delete.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    set result [$obj destroy]
    unset Objects($name)
    return $result
  }
  method move {name x y} {
  ## Move a named object.
  # @param name The name of the object to be moved.
  # @param x The amount of the x movement.
  # @param y The amount of the y movement.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj move $x $y]
  }
  method class {name} {
  ## Return the class name of an object.
  # @param name The name of the object whose class name is to be fetched.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj class]
  }
  method invoke {name} {
  ## Method to invoke an object.  Returns true if the element is occupied.
  # @param name The name of the object to invoke.
  # 
  # See the individual object invoke methods for details.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj invoke]
  }
  method coords {name tname} {
  ## Method to fetch the coordinates of some part of an object.
  # @param name The name of the object to fetch coordinates from.
  # @param tname The name of the terminal of the object to fetch the
  # coordinates of.  See the individual element descriptions for valid
  # terminal names.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj coords $tname]
  }
  method print {name fp} {
  ## Method to print the named object to the specificied file channel.
  # @param name The object to print.
  # @param fp The file channel to print to.

    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    puts -nonewline $fp "[$obj class] $name"
    foreach opt [$obj configure] {
      foreach {option resource class default value} $opt {
	puts            $fp " \\"
        puts -nonewline $fp "\t"
	puts -nonewline $fp [list $option $value]
      }
    }
    puts $fp {}
  }
  method objectlist {{cp {}} {class {}}} {
  ## Method to return the list of objects.
  # @param cp (optional) The name of control point to return the object of.
  #      If cp is the empty string, return all objects.
  # @param class (optional) The class of objects to return.
  #      If class is the empty string, return all classes of objects.

    if {[string equal "$cp" {}] && [string equal "$class" {}]} {
      return [array names Objects]
    } elseif {[string equal "$class" {}]} {
      set result {}
      foreach slot [array names CPData "$cp,*"] {
	eval [list lappend result] $CPData($slot)
      }
      return $result
    } elseif {[string equal "$cp" {}]} {
      set result {}
      foreach slot [array names CPData "*,$class"] {
	eval [list lappend result] $CPData($slot)
      }
      return $result
    } else {
      return $CPData($cp,$class)
    }
  }
  method cplist {} {
  ## Method to return the list of controlpoints
    return $CPList
  }
  method {create SWPlate} {name args} {
  ## Method to create a switch plate object.
  # @param name The name of the new switch plate.
  # @param ... The argument list for the object constructor.
  # 
  # See SWPlate for details.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SWPlate create $name $self $controls] $args]]
  }
  method {create SIGPlate} {name args} {
  ## Method to create a signal plate object.
  # @param name The name of the new signal plate.
  # @param ... The argument list for the object constructor.
  # 
  # See SIGPlate for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SIGPlate create $name $self $controls] $args]]
  }
  method {create CodeButton} {name args} {
  ## Method to create a code button object.
  # @param name The name of the new code button.
  # @param ... The argument list for the object constructor.
  # 
  # See CodeButton for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::CodeButton create $name $self $controls] $args]]
  }
  method {create Toggle} {name args} {
  ## Method to create a toggle switch object.
  # @param name The name of the new toggle switch.
  # @param ... The argument list for the object constructor.
  # 
  # See Toggle for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Toggle create $name $self $controls] $args]]
  }
  method {create Lamp} {name args} {
  ## Method to create a lamp object.
  # @param name The name of the new lamp.
  # @param ... The argument list for the object constructor.
  # 
  # See Lamp for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Lamp create $name $self $controls] $args]]
  }
  method {create CTCLabel} {name args} {
  ## Method to create a CTC Label label object.
  # @param name The name of the new label.
  # @param ... The argument list for the object constructor.
  # 
  # See CTCLabel for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::CTCLabel create $name $self $controls] $args]]
  }
  method {create Switch} {name args} {
  ## Method to create a switch (turnout) object.
  # @param name The name of the new switch.
  # @param ... The argument list for the object constructor.
  # 
  # See Switch for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Switch create $name $self $schematic] $args]]
  }
  method {create SchLabel} {name args} {
  ## Method to create a schematic label object.
  # @param name The name of the new label.
  # @param ... The argument list for the object constructor.
  # 
  # See SchLabel for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SchLabel create $name $self $schematic] $args]]
  }
  method {create StraightBlock} {name args} {
  ## Method to create a straight block of track object.
  # @param name The name of the new track block.
  # @param ... The argument list for the object constructor.
  # 
  # See StraightBlock for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::StraightBlock create $name $self $schematic] $args]]
  }
  method {create CurvedBlock} {name args} {
  ## Method to create a curved block of track object.
  # @param name The name of the new track block.
  # @param ... The argument list for the object constructor.
  # 
  # See CurvedBlock for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::CurvedBlock create $name $self $schematic] $args]]
  }
  method {create ScissorCrossover} {name args} {
  ## Method to create a scissor crossover object.
  # @param name The name of the new crossover.
  # @param ... The argument list for the object constructor.
  # 
  # See ScissorCrossover for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::ScissorCrossover create $name $self $schematic] $args]]
  }
  method {create Crossing} {name args} {
  ## Method to create a track crossing object.
  # @param name The name of the new crossing.
  # @param ... The argument list for the object constructor.
  # 
  # See Crossing for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Crossing create $name $self $schematic] $args]]
  }
  method {create SingleSlip} {name args} {
  ## Method to create a single slip object.
  # @param name The name of the new switch.
  # @param ... The argument list for the object constructor.
  # 
  # See SingleSlip for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SingleSlip create $name $self $schematic] $args]]
  }
  method {create DoubleSlip} {name args} {
  ## Method to create a double slip object.
  # @param name The name of the new switch.
  # @param ... The argument list for the object constructor.
  # 
  # See DoubleSlip for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::DoubleSlip create $name $self $schematic] $args]]
  }
  method {create ThreeWaySW} {name args} {
  ## Method to create a three way switch object.
  # @param name The name of the new switch.
  # @param ... The argument list for the object constructor.
  # 
  # See ThreeWaySW for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::ThreeWaySW create $name $self $schematic] $args]]
  }
  method {create HiddenBlock} {name args} {
  ## Method to create a hidden block of track object.
  # @param name The name of the new track block.
  # @param ... The argument list for the object constructor.
  # 
  # See HiddenBlock for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::HiddenBlock create $name $self $schematic] $args]]
  }
  method {create StubYard} {name args} {
  ## Method to create a stub (deadend) yard object.
  # @param name The name of the new yard.
  # @param ... The argument list for the object constructor.
  # 
  # See StubYard for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::StubYard create $name $self $schematic] $args]]
  }
  method {create ThroughYard} {name args} {
  ## Method to create a through yard object.
  # @param name The name of the new yard.
  # @param ... The argument list for the object constructor.
  # 
  # See ThroughYard for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::ThroughYard create $name $self $schematic] $args]]
  }
  method {create PushButton} {name args} {
  ## Method to create a push button object.
  # @param name The name of the push button.
  # @param ... The argument list for the object constructor.
  # 
  # See PushButton for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::PushButton create $name $self $controls] $args]]
  }
  method {create Signal} {name args} {
  ## Method to create a signal object.
  # @param name The name of the signal.
  # @param ... The argument list for the object constructor.
  # 
  # See Signal for defails.

    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Signal create $name $self $schematic] $args]]
  }
  method checkInitCP {cp} {
  ## Method to check that a control point has been initialized.  Should
  # only be called from object constructors.
  # @param cp The name of the control point.

    if {[lsearch -exact $CPList $cp] < 0} {
      lappend CPList $cp
      set CPData($cp,SwitchPlates) {}
      set CPData($cp,CodeButtons) {}
      set CPData($cp,SignalPlates) {}
      set CPData($cp,Toggles) {}
      set CPData($cp,Lamps) {}
      set CPData($cp,Trackwork) {}
      set CPData($cp,CTCLabels) {}
      set CPData($cp,SchLabels) {}
      set CPData($cp,PushButtons) {}
      set CPData($cp,Signals) {}
      set bbox1 [$schematic bbox $cp]
      set bbox2 [$controls  bbox $cp]
      set sr1   [$schematic cget -scrollregion]
      set sr2   [$controls  cget -scrollregion]
      if {[llength $bbox1] == 0 && [llength $bbox2] == 0} {
        set bbox1 [list 0 [lindex $sr1 1] 0 [lindex $sr1 3]]
        set bbox2 [list 0 [lindex $sr2 1] 0 [lindex $sr2 3]]
      } elseif {[llength $bbox1] == 0} {
        set bbox1 [list [lindex $bbox2 0] [lindex $sr1 1] [lindex $bbox2 2] [lindex $sr1 3]]
        set bbox2 [lreplace $bbox2 1 1 [lindex $sr2 1]]
        set bbox2 [lreplace $bbox2 3 3 [lindex $sr2 3]]
      } elseif {[llength $bbox2] == 0} {
        set bbox2 [list [lindex $bbox1 0] [lindex $sr2 1] [lindex $bbox1 2] [lindex $sr2 3]]
        set bbox1 [lreplace $bbox1 1 1 [lindex $sr1 1]]
        set bbox1 [lreplace $bbox1 3 3 [lindex $sr1 3]]
      }
      if {[lindex $bbox2 0] < [lindex $bbox1 0]} {
        set bbox1 [lreplace $bbox1 0 0 [lindex $bbox2 0]]
      } elseif {[lindex $bbox1 0] < [lindex $bbox2 0]} {
        set bbox2 [lreplace $bbox2 0 0 [lindex $bbox1 0]]
      }
      if {[lindex $bbox2 2] > [lindex $bbox1 2]} {
        set bbox1 [lreplace $bbox1 2 2 [lindex $bbox2 2]]
      } elseif {[lindex $bbox1 2] > [lindex $bbox2 2]} {
        set bbox2 [lreplace $bbox2 2 2 [lindex $bbox1 2]]
      }
      if {0} {
        set color yellow
      } else {
        set color [$schematic cget -background]
      }    
      $schematic create rectangle $bbox1 -fill {} -outline $color -width 4 -tag [list $cp ${cp}_outline All_CPs]
      $schematic lower ${cp}_outline
      if {0} {
        set color blue
      } else {
        set color [$controls cget -background]
      }
      $controls create rectangle $bbox2 -fill {} -outline $color -width 4 -tag [list $cp ${cp}_outline All_CPs]
      $controls lower ${cp}_outline
    }
  }
  method updateAndSyncCP {cp} {
  ## Method to update and syncronize a control point. Should
  # only be called from object methods.
  # @param cp The name of the control point.

    set bbox1 [$schematic bbox $cp]
    set bbox2 [$controls  bbox $cp]
    if {[lindex $bbox2 0] < [lindex $bbox1 0]} {
      set bbox1 [lreplace $bbox1 0 0 [lindex $bbox2 0]]
    } elseif {[lindex $bbox1 0] < [lindex $bbox2 0]} {
      set bbox2 [lreplace $bbox2 0 0 [lindex $bbox1 0]]
    }
    if {[lindex $bbox2 2] > [lindex $bbox1 2]} {
      set bbox1 [lreplace $bbox1 2 2 [lindex $bbox2 2]]
    } elseif {[lindex $bbox1 2] > [lindex $bbox2 2]} {
      set bbox2 [lreplace $bbox2 2 2 [lindex $bbox1 2]]
    }
    $schematic coords ${cp}_outline $bbox1
    $controls  coords ${cp}_outline $bbox2
  }
  method lappendCP {cp slot what} {
  ## Method to lappend something to a slot in a control point's data.
  # Should only be called from object constructors.
  # @param cp The control point to update.
  # @param slot The slot to update.
  # @param what The object to add to the slot.

    lappend CPData($cp,$slot) $what
  }
  method lremoveCP {cp slot what} {
  ## Method to remove something from a slot in a control point's data.
  # Should only be called from object destructors.
  # @param cp The control point to update.
  # @param slot The slot to update.
  # @param what The object to remove from the slot.

    set index [lsearch -exact $CPData($cp,$slot) $what]
    if {$index == 0} {
      set CPData($cp,$slot) [lrange $CPData($cp,$slot) 1 end]
    } elseif {$index > 0} {
      set CPData($cp,$slot) [lreplace $CPData($cp,$slot) $index $index]
    }
  }
  method {schematic crosshair} {args} {
  ##

#    puts stderr "*** $self schematic crosshair $args"
    set bdown <ButtonPress-1>
    set motion <Motion>
#    puts stderr "*** $self schematic crosshair: enabling crosshairs"
    set xvar  [from args -xvar  {}]
    set yvar  [from args -yvar  {}]
    $self _crosshairStart $schematic $xvar $yvar
    bind $schematic $bdown [mymethod _crosshairEnd %W $xvar $yvar %x %y]
    bind $schematic $motion [mymethod _crosshairMove %W $xvar $yvar %x %y]
#    puts stderr "*** $self schematic crosshair: bindings are: [bind $schematic]"
#    foreach binding  [bind $schematic] {
#      puts stderr "*** $self schematic crosshair: bind $binding: [bind $schematic $binding]"
#    }
  }
  method {controls crosshair} {args} {
  ##

#    puts stderr "*** $self controls crosshair $args"
    set bdown <ButtonPress-1>
    set motion <Motion>
#    puts stderr "*** $self controls crosshair: enabling crosshairs"
    set xvar  [from args -xvar  {}]
    set yvar  [from args -yvar  {}]
    $self _crosshairStart $controls $xvar $yvar
    bind $controls $bdown [mymethod _crosshairEnd %W $xvar $yvar %x %y]
    bind $controls $motion [mymethod _crosshairMove %W $xvar $yvar %x %y]
  }
  # variable _lastCH -array {}
  variable _ch_oldgrab {}
  variable _ch_oldfocus {}
  method _crosshairStart {canvas xvar yvar} {
  ##

#    puts stderr "*** $self _crosshairStart $canvas $xvar $yvar"
    #set _lastCH($canvas,X) $cx
    #set _lastCH($canvas,Y) $cy
    upvar #0 $xvar x
    upvar #0 $yvar y
    set x 0
    set y 0
    set sr [$canvas cget -scrollregion]
    $canvas create line $x [lindex $sr 1] $x [lindex $sr 3] -fill white \
					-tag [list CROSSHAIR CROSSHAIRX]
#    puts stderr "*** $self _crosshairStart: coords CROSSHAIRX: [$canvas coords CROSSHAIRX]"
    $canvas create line [lindex $sr 0] $y [lindex $sr 2] $y -fill white \
					-tag [list CROSSHAIR CROSSHAIRY]
#    puts stderr "*** $self _crosshairStart: coords CROSSHAIRY: [$canvas coords CROSSHAIRY]"
#    puts stderr "*** $self _crosshairStart: crosshair items: [$canvas find withtag CROSSHAIR]"
    raise [winfo toplevel $canvas]
    set _ch_oldgrab "[grab current $canvas]"
    grab set $canvas
    set _ch_oldfocus "[focus]"
    focus $canvas    
  }
  method _crosshairMove  {canvas xvar yvar mx my} {
  ##

#    puts stderr "*** $self _crosshairMove $canvas $xvar $yvar $mx $my"
    set cx [$canvas canvasx $mx]
    set cy [$canvas canvasx $my]
    #set _lastCH($canvas,X) $cx
    #set _lastCH($canvas,Y) $cy
    upvar #0 $xvar x
    upvar #0 $yvar y
    set x $cx
    set y $cy
    set sr [$canvas cget -scrollregion]
#    puts stderr "*** $self _crosshairMove: CROSSHAIRX item [$canvas find withtag CROSSHAIRX]"
    $canvas coords CROSSHAIRX $x [lindex $sr 1] $x [lindex $sr 3]
#    puts stderr "*** $self _crosshairMove: coords CROSSHAIRX: [$canvas coords CROSSHAIRX]"
#    puts stderr "*** $self _crosshairMove: CROSSHAIRX item [$canvas find withtag CROSSHAIRY]"
    $canvas coords CROSSHAIRY [lindex $sr 0] $y [lindex $sr 2] $y
#    puts stderr "*** $self _crosshairMove: coords CROSSHAIRY: [$canvas coords CROSSHAIRY]"
  }
  method _crosshairEnd   {canvas xvar yvar mx my} {
  ##

#    puts stderr "*** $self _crosshairEnd $canvas $xvar $yvar $mx $my"
    set cx [$canvas canvasx $mx]
    set cy [$canvas canvasx $my]
    #unset _lastCH($canvas,X)
    #unset _lastCH($canvas,Y)
    upvar #0 $xvar x
    upvar #0 $yvar y
    set x $cx
    set y $cy
    $canvas delete CROSSHAIR
    bind $canvas <ButtonPress-1> {}
    bind $canvas <Motion> {}
    grab release $canvas
    if {[string length "$_ch_oldgrab"] > 0} {grab set $_ch_oldgrab}
    if {[string length "$_ch_oldfocus"] > 0} {focus $_ch_oldfocus}
  }
}


snit::macro CTCPanel::leverMethods {hasCenter} {
## Macro to add lever methods to object types.
# @param hasCenter Flag to indicate if there is a center position for this
#	 object's lever.

  typevariable _LeverPolygonL {
	    -16   -20
	    -16   -12
	     -6     0
	     -4     4
	      0     6
	      4     4
	      6     0
	      4    -4
	     -7   -18
  }
  typevariable _LeverPolygonR {
	     16   -20
	     16   -12
	      6     0
	      4     4
	      0     6
	     -4     4
	     -6     0
	     -4    -4
	      7   -18
  }
  if {$hasCenter} {
    typevariable _LeverPolygonC {
	      0   -24
	     -5   -18
	     -6     0
	     -4     4
	      0     6
	      4     4
	      6     0
	      5   -18
    }
    variable hasCenter 1
  } else {
    variable hasCenter 0
  }
  variable lever none
  method _AddLever {pos} {
  # Method to add (draw) a lever.
  # @param pos The lever's position (Left, Right, or Center).

    set tag $selfns
    set cp $options(-controlpoint)
    set xy [$canvas coords ${tag}_xy]
    set x [lindex $xy 0]
    set y [lindex $xy 1]      
    if {![string equal "$lever" {none}]} {
      $canvas delete ${tag}_Lever
      set lever none
    }
    if {!$hasCenter} {
      if {[string equal $pos Center]} {
	error "Can't add center position level: not allowed for $type"
      }
    }
    switch -exact -- $pos {
      Left {
        $canvas create polygon $_LeverPolygonL -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
        $canvas move   ${tag}_Lever $x $y
        $canvas scale  ${tag}_Lever 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
      }
      Right {
        $canvas create polygon $_LeverPolygonR -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
        $canvas move   ${tag}_Lever $x $y
        $canvas scale  ${tag}_Lever 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
      }
      Center {
        $canvas create polygon $_LeverPolygonC -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
        $canvas move   ${tag}_Lever $x $y
        $canvas scale  ${tag}_Lever 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
      }
    }
    set lever $pos
  }
  method _MoveLever {mx} {
  # Method to move an object's lever.
  # @param mx Mouse X coordinate.  The lever is moved to be near the mouse pointer.

    set tag $selfns
    set cp $options(-controlpoint)
    set xy [$canvas coords ${tag}_xy]
    set x  [lindex $xy 0]
    set y  [lindex $xy 1]
    set cx [$canvas canvasx $mx]

    if {$hasCenter} {
      set bbox [$canvas bbox ${tag}_CInd]
      if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
        $self _AddLever Center
        return
      }
    }
    set bbox [$canvas bbox ${tag}_LInd]
    if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
      $self _AddLever Left
      return
    }
    set bbox [$canvas bbox ${tag}_NInd]
    if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
      $self _AddLever Left
      return
    }
    set bbox [$canvas bbox ${tag}_RInd]
    if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
      $self _AddLever Right
      return
    }
  }
}

snit::macro CTCPanel::verifyDoubleMethod {} { 
## Macro to add a verify double method to a snit type.

  method _VerifyDouble {option value} {
  # Method to verify that the value for an option is a double.
  # @param option The name of the option.
  # @param value The value passed in.

    if {![string is double -strict "$value"]} {
      error "$option takes a double, got $value"
    } else {
      return $value"
    }
  }
}

snit::macro CTCPanel::verifyBoolMethod {} {
## Macro to add a verify boolean method to a snit type.

  method _VerifyBool {option value} {
  # Method to verify that the value for an option is a boolean.
  # @param option The name of the option.
  # @param value The value passed in.

    if {![string is boolean -strict "$value"]} {
      error "$option takes a boolean, got $value"
    } else {
      return $value"
    }
  }
}

snit::macro CTCPanel::verifyColorMethod {} {
## Macro to add a verify color method to a snit type.

  method _VerifyColor {option value} {
  # Method to verify that the value for an option is a valid color.
  # @param option The name of the option.
  # @param value The value passed in.

    if {[catch [list winfo rgb $ctcpanel "$value"] message]} {
      error "$option takes a color ($message), got $value"
    } else {
      return $value"
    }
  }
}

snit::macro CTCPanel::verifyOrientation8Method {} {
## Macro to add a verify 8-way orientation method to a snit type.

  set PI2 [expr {asin(1.0)}]
  typevariable _PI  [expr {$PI2 * 2.0}]
  # 
  set dtheta [expr {acos(-1) / 4.0}]
  typevariable _RotateAngles -array [list \
    0 [list [expr {cos(0)}]           [expr {sin(0)}]] \
    1 [list [expr {cos(1.0*$dtheta)}] [expr {sin(1.0*$dtheta)}]] \
    2 [list [expr {cos(2.0*$dtheta)}] [expr {sin(2.0*$dtheta)}]] \
    3 [list [expr {cos(3.0*$dtheta)}] [expr {sin(3.0*$dtheta)}]] \
    4 [list [expr {cos(4.0*$dtheta)}] [expr {sin(4.0*$dtheta)}]] \
    5 [list [expr {cos(5.0*$dtheta)}] [expr {sin(5.0*$dtheta)}]] \
    6 [list [expr {cos(6.0*$dtheta)}] [expr {sin(6.0*$dtheta)}]] \
    7 [list [expr {cos(7.0*$dtheta)}] [expr {sin(7.0*$dtheta)}]] \
  ]
  method _VerifyOrientation8 {option value} {
  # Method to verify that the value for an option is a valid orientation 
  # (8-way).
  # @param option The name of the option.
  # @param value The value passed in.

    if {[lsearch -exact [array names _RotateAngles] $value] < 0} {
      error "$option out of range, must be one of [array names _RotateAngles], got $value"
    } else {
      return $value"
    }
  }
}

snit::macro CTCPanel::verifyPositionMethod {} {
## Macro to add a verify position method to a snit type.

  method _VerifyPosition {option value} {
  # Method to verify that the value for an option is a valid position.
  # @param option The name of the option.
  # @param value The value passed in.

    if {[lsearch -exact {above below left right} $value] < 0} {
      error "$option must be one of above, below, left, or right, got $value"
    } else {
      return $value
    }
  }
}

snit::macro CTCPanel::standardMethods {} {
## Macro to add a standard set of methods to an object type.

  method coords {tname} {
  # Method to return the coordinates of a subobject.
  # @param tname The name of the subobject.

    return [$canvas coords ${selfns}_${tname}]
  }
  method move   {x y} {
  # Method to move an object.
  # @param x The amount of x movment.
  # @param y The amount of y movment.

    set result [$canvas move $selfns $x $y]
    $ctcpanel updateAndSyncCP $options(-controlpoint)
  }
  method class {} {
  # Method to return our class.

    return [namespace tail $type]
  }
}

snit::type SWPlate {
## @brief %Switch plate object type.
#
# These are on the control panel and represent levers for controlling track 
# switches (aka turnouts).  They have a lever that can be in two positions,
# normal (switch aligned for the main route) and reversed (switch aligned
# for the divergent route).
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The control panel canvas to draw the switch plate on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -label The label of the switch plate (default 1).
# @arg -controlpoint The name of the control point this switch is part of 
#	  (readonly, default CP1).
# @arg -normalcommand The Tcl script to run when switch is set to normal
#	  (default {}).
# @arg -reversecommand The Tcl script to run when switch is set to reverse
#	  (default {}).
# @par
# Defined coords terminals:
# @arg xy The base coords of the object.
# 
# Defined values (states):
# @arg N Normal.
# @arg R Reversed.
# 
# Defined indicators:
# @arg N Normal indicator (green if on).
# @arg R Reversed indicator (yellow if on).
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  typevariable _PlatePolygon {
	      -32  -32 
	      -11   0 
	      -7    6 
	      -3    8 
	       0   11
	       3    8
	       7    6
	       11   0
	      32    -32
	      14    -36
	      12    -44
	     -12    -44
	     -14    -36
  }
  ##

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -normalcommand  -default {}
  option -reversecommand -default {}
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
  ## Construct a SWPlate object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The control panel canvas to draw the switch plate on.
  # @param ... Option list.

#    puts stderr "*** $type create $self $_ctcpanel $_canvas $args"
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $canvas create polygon $_PlatePolygon -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
    $canvas create text -24 -32 -text {N} -anchor nw -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
    $canvas create text  24 -32 -text {R} -anchor ne -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
    $canvas create text   0 -30 -text {SWITCH} -anchor n -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp]
    $canvas create text   0 -32 -text $options(-label) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_label]
    $canvas create oval -26 -48 -18 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_NInd $cp]
    $canvas create oval  18 -48  26 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_RInd $cp]
    $canvas move   $tag $x $y
    $canvas create line $x $y $x $y -tag [list $tag ${tag}_xy $cp]
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    $self _AddLever Left
    $canvas bind $tag <1> "[mymethod _MoveLever] %x"
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) SwitchPlates [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) SwitchPlates [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (lever position).

    switch -exact -- $lever {
      Left {return Normal}
      Right {return Reverse}
      default {return {}}
    }
  }
  method setv  {state} {
  ## Method to set out value (level position).
  # @param state The new state to set.

    switch -exact -- $state {
      N {$self _AddLever Left}
      R {$self _AddLever Right}
    }
    return $state
  }
  method geti  {ind} {
  ## Method to get the state of one of our indicators.
  # @param ind The indicator to fetch state information for.
  
    set tag $selfns
    switch -exact -- $ind {
      N {
	  if {[string equal [$canvas itemcget ${tag}_NInd -fill] {black}]} {
	    return 0
	  } else {
	    return 1
	  }
      }
      R {
	  if {[string equal [$canvas itemcget ${tag}_RInd -fill] {black}]} {
	    return 0
	  } else {
	    return 1
	  }
      }
      default {return {}}
    }
  }
  method seti  {ind value} {
  ## Method to set an indicator's state.
  # @param ind The indicator to set.
  # @param value The state to set it to.

    set tag $selfns
    switch -exact -- $ind {
      N {
	if {$value} {
	  set color green
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_NInd -fill $color
	return $value
      }
      R {
	if {$value} {
	  set color yellow
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_RInd -fill $color
	return $value
      }
      default {return {}}
    }
  }
  CTCPanel::standardMethods
  method invoke {} {
  ## Method to invoke the switch plate. One of the command scripts is executed
  # depending on the lever position.

    switch -exact -- $lever {
      Left {set script "$options(-normalcommand)"}
      Right {set script "$options(-reversecommand)"}
      default {set script {}}
    }
#  puts stderr "*** -: script = '$script'"
    if {[string length "$script"] > 0} {
      uplevel #0 "$script"
    }
    return false ; #	Control elements are never 'occupied'.
  }
  CTCPanel::leverMethods no
}
  
snit::type SIGPlate {
## @brief %Signal plate object type.
#
# These are on the control panel and represent levers for controlling track 
# signals (control point signals).  They have a lever that can be in three
# positions, Left, Center, or Right.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The control panel canvas to draw the switch plate on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -label The label of the switch plate (default 1).
# @arg -controlpoint The name of the control point this switch is part of 
#	  (readonly, default CP1).
# @arg -leftcommand The Tcl script to run when switch is set to left
#	  (default {}).
# @arg -centercommand The Tcl script to run when switch is set to center
#	  (default {}).
# @arg -rightcommand The Tcl script to run when switch is set to right
#	  (default {}).
# @par
# Defined coords terminals:
# @arg xy The base coords of the object.
# 
# Defined values (states):
# @arg Left Left position.
# @arg Right Right position.
# @arg Center Center position.
# 
# Defined indicators:
# @arg L Left indicator, green if on.
# @arg C Center indicator, red if on.
# @arg R Right indicator, green if on.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  typevariable _PlatePolygon {
	      -32  -32 
	      -11   0 
	      -7    6 
	      -3    8 
	       0   11
	       3    8
	       7    6
	       11   0
	      32    -32
	      14    -36
	      12    -44
	     -12    -44
	     -14    -36
  }
  ##

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -leftcommand  -default {}
  option -centercommand -default {}
  option -rightcommand -default {}
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
  ## Construct a SIGPlate object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The control panel canvas to draw the switch plate on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $canvas create polygon $_PlatePolygon -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
    $canvas create text -24 -32 -text {L} -anchor nw -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
    $canvas create text  24 -32 -text {R} -anchor ne -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
    $canvas create text   0 -30 -text {SIGNAL} -anchor n -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp]
    $canvas create text   0 -32 -text $options(-label) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_label]
    $canvas create oval -26 -48 -18 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_LInd $cp]
    $canvas create oval  -4 -56   4 -48 -fill black -outline lightgrey -tag [list $tag ${tag}_CInd $cp]
    $canvas create oval  18 -48  26 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_RInd $cp]
    $canvas move   $tag $x $y
    $canvas create line $x $y $x $y -tag [list $tag ${tag}_xy $cp]
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    $self _AddLever Center
    $canvas bind $tag <1> "[mymethod _MoveLever] %x"
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) SignalPlates [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) SignalPlates [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (lever position).

    switch -exact -- $lever {
      Left {return Left}
      Right {return Right}
      Center {return Center}
      default {return {}}
    }
  }
  method setv  {state} {
  ## Method to set out value (level position).
  # @param state The new state to set.

    switch -exact -- $state {
      L {$self _AddLever Left}
      C {$self _AddLever Center}
      R {$self _AddLever Right}
    }
    return $state
  }
  method geti  {ind} {
  ## Method to get the state of one of out indicators.
  # @param ind The indicator to fetch state information for.
  
    set tag $selfns
    switch -exact -- $ind {
      L {
	  if {[string equal [$canvas itemcget ${tag}_LInd -fill] {black}]} {
	    return 0
	  } else {
	    return 1
	  }
      }
      C {
	  if {[string equal [$canvas itemcget ${tag}_CInd -fill] {black}]} {
	    return 0
	  } else {
	    return 1
	  }
      }
      R {
	  if {[string equal [$canvas itemcget ${tag}_RInd -fill] {black}]} {
	    return 0
	  } else {
	    return 1
	  }
      }
      default {return {}}
    }
  }
  method seti  {ind value} {
  ## Method to set an indicator's state.
  # @param ind The indicator to set.
  # @param value The state to set it to.

    set tag $selfns
    switch -exact -- $ind {
      L {
	if {$value} {
	  set color green
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_LInd -fill $color
	return $value
      }
      C {
	if {$value} {
	  set color red
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_CInd -fill $color
	return $value
      }
      R {
	if {$value} {
	  set color green
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_RInd -fill $color
	return $value
      }
      default {return {}}
    }
  }
  CTCPanel::standardMethods
  method invoke {} {
  ## Method to invoke the switch plate. One of the command scripts is executed
  # depending on the lever position.

    switch -exact -- $lever {
      Left {set script "$options(-leftcommand)"}
      Right {set script "$options(-rightcommand)"}
      Center {set script "$options(-centercommand)"}
      default {set script {}}
    }
#  puts stderr "*** -: script = '$script'"
    if {[string length "$script"] > 0} {
      uplevel #0 "$script"
    }
    return false ; #	Control elements are never 'occupied'.
  }
  CTCPanel::leverMethods yes
}

snit::type CodeButton {
## @brief Code button object type.
#
# These are on the control panel and represent buttons that enact the settings
# of the SWPlates and SIGPlates for a given control point.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The control panel canvas to draw the switch plate on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this switch is part of 
#	  (readonly, default CP1).
# @arg -command The Tcl script to run when the code button is invoked.
# @par
# Defined coords terminals: none.
# Defined values (states): none.
# Defined indicators: none.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -command -default {}
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
  ## Construct a Code Button object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The control panel canvas to draw the Code Button on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp ${tag}_Button]
    $canvas create text   0  16 -anchor n -text {Code} -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp]
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    $canvas bind   ${tag}_Button <1> [mymethod invoke]

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) CodeButtons [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) CodeButtons [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (none).

    return {}
  }
  method setv  {state} {
  ## Method to set our value (none).

    return {}
  }
  method geti {ind} {
  ## Method to get an indicator state (none).

    return {}
  }
  method seti {ind value} {
  ## Method to set an indicator state (none).
    return {}
  }
  CTCPanel::standardMethods
  method invoke {} {
  ## Method to invoke the code button.  The command script is executed.

    set script "$options(-command)"
    if {[string length "$script"] > 0} {
      uplevel #0 "$script"
    }
    return false ; # 	Control elements are never 'occupied'.
  }
}  

snit::type Toggle {
## @brief %Toggle switch object type.
#
# These are on the control panel and represent simple toggle switches.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The control panel canvas to draw the switch plate on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this switch is part of
#         (readonly, default CP1).
# @arg -orientation The orientation of the switch, either horizontal
#	   or vertical (readonly, default horizontal).
# @arg -leftlabel The label of the left or upper position (default "on").
# @arg -rightlabel The label of the right or lower position (default 
#		"off"). 
# @arg -centerlabel The label of the center position (default "off").
# @arg -hascenter Flag indicating if there is a center position or not 
#		(readonly, default no).
# @arg -leftcommand Script to run when the switch is in its left or upper 
#		position (default {}).
# @arg -rightcommand Script to run when the switch is in its right or 
#		lower position (default {}).
# @arg -centercommand Script to run when the switch is in its center 
#		position (default {}).
# @par
# Defined coords terminals:
# @arg xy The base position of the object.
# 
# Defined values (states):
# @arg Left Left position.
# @arg Center Center position.
# @arg Right Right position.
# 
# Defined indicators: none.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default horizontal \
	-validatemethod _VerifyOrientationHV
  method _VerifyOrientationHV {option value} {
  ## Method to validate an orientation option of horizontal or vertical.

    if {[lsearch -exact {horizontal vertical} $value] < 0} {
      error "$option must be horizontal or vertical, got $value"
    } else {
      return $value
    }
  }
  option -leftlabel -default "on" -configuremethod _configureLeftLabel
  method _configureLeftLabel  {option value} {
  ## Method to update the leftlabel option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_leftlabel -text "$value"
  }
  option -rightlabel -default "off" -configuremethod _configureRightLabel
  method _configureRightLabel  {option value} {
  ## Method to update the rightlabel option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_rightlabel -text "$value"
  }
  option -centerlabel -default "off" -configuremethod _configureCenterLabel
  method _configureCenterLabel  {option value} {
  ## Method to update the centerlabel option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_centerlabel -text "$value"
  }
  option -hascenter -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -leftcommand -default {}
  option -rightcommand -default {}
  option -centercommand -default {}
  component ctcpanel
  component canvas
  variable lever none
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a toggle switch object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The control panel canvas to draw the Code Button on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    switch -exact -- $options(-orientation) {
      horizontal {
        $canvas create rectangle -30 -10 30 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
        $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
        $canvas create text -30 -15 -text $options(-leftlabel) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_leftlabel]
        $canvas create text  30 -15 -text $options(-rightlabel) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_rightlabel]
        if {$options(-hascenter)} {
	  $canvas create text  0 -15 -text $options(-centerlabel) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_centerlabel]
        }
      }
      vertical {
        $canvas create rectangle -10 -30 10 30 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
        $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
        $canvas create text  15 -30 -text $options(-leftlabel) -anchor w -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_leftlabel]      
        $canvas create text  15  30 -text $options(-rightlabel) -anchor w -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_rightlabel]
        if {$options(-hascenter)} {
	  $canvas create text  15  0 -text $options(-centerlabel) -anchor w -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_centerlabel]
        }
      }
    }
    $canvas move   $tag $x $y
    $canvas create line $x $y $x $y -tag [list $tag ${tag}_xy $cp]
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    $self _AddTLever Left
    $canvas bind $tag <1> "[mymethod _MoveTLever] %x %y"
#    puts stderr "*** CTCPanel::Toggle_Create: bindings on $canvas $tag: [$canvas bind $tag]"

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Toggles [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Toggles [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method _AddTLever {pos} {
  ## Method to add (draw) a toggle switch lever.
  # @param pos The lever's position (Left, Right, or Center).

    set tag $selfns
    set cp $options(-controlpoint)
    set xy [$canvas coords ${tag}_xy]
    set x [lindex $xy 0]
    set y [lindex $xy 1]      
    if {![string equal "$lever" {none}]} {
      $canvas delete ${tag}_Lever
      set lever none
    }
    if {!$options(-hascenter)} {
      if {[string equal $pos Center]} {
	error "Can't add center position level: not allowed for $self"
      }
    }
    switch -exact -- $pos {
      Left {
	switch -exact -- $options(-orientation) {
	  horizontal {
	    $canvas create oval -35 -5 5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
	  }
	  vertical {
	    $canvas create oval -5 -35 5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
	  }
	}
	$canvas move   ${tag}_Lever $x $y
	$canvas scale  ${tag}_Lever 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
      }
      Right {
	switch -exact -- $options(-orientation) {
	  horizontal {
	    $canvas create oval  35 -5 -5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
	  }
	  vertical {
	    $canvas create oval -5 35 5 -5 -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
	  }
	}
	$canvas move   ${tag}_Lever $x $y
	$canvas scale  ${tag}_Lever 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
      }
      Center {
	$canvas create oval -5 -5 5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${tag}_Lever]
	$canvas move   ${tag}_Lever $x $y
	$canvas scale  ${tag}_Lever 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
      }
    }
    set lever $pos
  }
  method _MoveTLever {mx my} {
  ## Method to move an object's lever.
  # @param mx Mouse X coordinate.  The lever is moved to be near the mouse pointer.
  # @param my Mouse Y coordinate.  The lever is moved to be near the mouse pointer.

    set tag $selfns
    set cp $options(-controlpoint)
    set xy [$canvas coords ${tag}_xy]
    set x [lindex $xy 0]
    set y [lindex $xy 1]      

    set cx [$canvas canvasx $mx]
    set cy [$canvas canvasx $my]
    if {$options(-hascenter)} {
      set bbox [$canvas bbox ${tag}_centerlabel]
      switch -exact -- $options(-orientation) {
	horizontal {
	  if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
	    $self _AddTLever Center
	    return
	  }
	}
	vertical {
	  if {$cy >= [lindex $bbox 1] && $cy <= [lindex $bbox 3]} {
	    $self _AddTLever Center
	    return
	  }
	}
      }
    }
    set bbox [$canvas bbox ${tag}_leftlabel]
    switch -exact -- $options(-orientation) {
      horizontal {
	if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
	  $self _AddTLever Left
	  return
	}
      }
      vertical {
	if {$cy >= [lindex $bbox 1] && $cy <= [lindex $bbox 3]} {
	  $self _AddTLever Left
	  return
	}
      }
    }
    set bbox [$canvas bbox ${tag}_rightlabel]
    switch -exact -- $options(-orientation) {
      horizontal {
	if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
	  $self _AddTLever Right
	  return
	}
      }
      vertical {
	if {$cy >= [lindex $bbox 1] && $cy <= [lindex $bbox 3]} {
	  $self _AddTLever Right
	  return
	}
      }
    }
  }
  method getv  {} {
  ## Method to get our value (lever position).

    return $lever
  }
  method setv  {state} {
  ## Method to set out value (level position).
  # @param state The new state to set.

    $self _AddTLever $state
    return $state
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the toggle switch. One of the command scripts is executed
  # depending on the lever position.

    switch -exact -- $lever {
      Left {set script "$options(-leftcommand)"}
      Right {set script "$options(-rightcommand)"}
      Center {set script "$options(-centercommand)"}
      default {set script {}}
    }
#  puts stderr "*** -: script = '$script'"
    if {[string length "$script"] > 0} {
      uplevel #0 "$script"
    }
    return false ; # 	Control elements are never 'occupied'.
  }
}

snit::type Lamp {
## @brief %Lamp object type.
#
# These are on the control panel and represent simple single-color lamps.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The control panel canvas to draw the lamp on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this lamp is part of
#         (readonly, default CP1).
# @arg -color The color of the lamp (default white).
# @arg -label The label of the lamp (default "lamp").
# @par
# Defined coords terminals: none.
# Defined values (states):
# @arg on Lamp is on.
# @arg off Lamp is off.
# 
# Defined indicators: none.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -color -default white -validatemethod _VerifyColor \
		-configuremethod _configureColor
  CTCPanel::verifyColorMethod
  method _configureColor {option value} {
  ## Method to update the lamp color

    set tag $selfns
    set options($option) "$value"
    if {$state == "on"} {
      $canvas itemconfigure ${tag}_lamp -fill "$value"
    }
  } 
  option -label -default "lamp" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  component ctcpanel
  component canvas
  variable state off
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a Lamp object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The control panel canvas to draw the Lamp on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp ${tag}_lamp]
    $canvas create text   0  15 -text $options(-label) -anchor n -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_label]
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Lamps [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Lamps [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (lamp state).

    return $state
  }
  method setv  {newstate} {
  ## Method to set out value (lamp state).
  # @param newstate The new lamp state.

    set tag $selfns
    switch -exact -- $newstate {
      on {
	set state on
	$canvas itemconfigure ${tag}_lamp -fill $options(-color)
      }
      default {
	set state off
	$canvas itemconfigure ${tag}_lamp -fill black
      }
    }	
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the lamp.

    return false ; # 	Control elements are never 'occupied'.
  }
}

snit::type PushButton {
## @brief Push Button object type.
#
# These are on the control panel and represent simple push buttons.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The control panel canvas to draw the PushButton on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this PushButton is part of
#         (readonly, default CP1).
# @arg -color The color of the PushButton (default white).
# @arg -label The label of the PushButton (default "PushButton").
# @arg -command The Tcl script to run when the PushButton button is pushed.
# @par
# Defined coords terminals: none.
# Defined values (states): none.
# Defined indicators:
# @arg I -color if on.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#


  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -command -default {}
  option -color -default white -validatemethod _VerifyColor
  CTCPanel::verifyColorMethod
  option -label -default "PushButton" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
  ## Construct a PushButton object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The control panel canvas to draw the PushButton on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp ${tag}_Button]
    $canvas create oval  -8  -8  8  8 -fill black -outline {} -width 0  -tag [list $tag $cp ${tag}_Ind ${tag}_Button]
    $canvas create text   0  15 -text $options(-label) -anchor n -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_label]
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    $canvas bind   ${tag}_Button <1> [mymethod invoke]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) PushButtons [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) PushButtons [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (PushButton state).

    return {}
  }
  method setv  {newstate} {
  ## Method to set out value (PushButton state).
  # @param newstate The new PushButton state.
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators.

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    set tag $selfns
    switch -exact -- $ind {
      I {
	if {$value} {
	  set color $options(-color)
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_Ind -fill $color
	return $value
      }
      default {return {}}
    }
  }
  method invoke {} {
  ## Method to invoke the PushButton.

    set script "$options(-command)"
    if {[string length "$script"] > 0} {
      uplevel #0 "$script"
    }
    return false ; # 	Control elements are never 'occupied'.
  }
}

snit::type CTCLabel {
## @brief CTC Label object type.
#
# These are on the control panel and represent a label on the CTC Panel
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The control panel canvas to draw the label on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -color The color of the label (default white).
# @arg -label The label of the label (default "").
# @par
# Defined coords terminals: none.
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -color -default white -validatemethod _VerifyColor \
			       -configuremethod _configureColor
  CTCPanel::verifyColorMethod
  method _configureColor {option value} {
  ## Method to update the color of the label.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure $tag -fill "$value"
  }
  option -label -default "" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure $tag -text "$value"
  }
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
  ## Construct a Label object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The control panel canvas to draw the CTCLabel on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $canvas create text $x $y -text $options(-label) -anchor c -fill $options(-color) -font [list Courier -18 bold] -tag [list $tag $cp]
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) CTCLabels [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) CTCLabels [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (none).

    return {}
  }
  method setv  {state} {
  ## Method to set out value (level position).

  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the label.

    return false ; # 	Control elements are never 'occupied'.
  }
}

snit::type SchLabel {
## @brief Schematic Label object type.
#
# These are on the schematic and represent a label on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the label on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -color The color of the label (default white).
# @arg -label The label of the label (default "").
# @par
# Defined coords terminals: none.
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -color -default white -validatemethod _VerifyColor \
			       -configuremethod _configureColor
  CTCPanel::verifyColorMethod
  method _configureColor {option value} {
  ## Method to update the color of the label.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure $tag -fill "$value"
  }
  option -label -default "" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag} -text "$value"
  }

  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
  ## Construct a Label object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the SchLabel on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $canvas create text $x $y -text $options(-label) -anchor c -fill $options(-color) -font [list Courier -18 bold] -tag [list $tag $cp]
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) SchLabels [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) SchLabels [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (none).

    return {}
  }
  method setv  {state} {
  ## Method to set out value (level position).

  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the label.

    return false ; # 	Control elements are never 'occupied'.
  }
}

snit::macro CTCPanel::trackworkmethods {} {
## Macro to include trackwork drawing methods.

  typemethod _SchematicDrawLine {canvas x1 y1 x2 y2 flip orientation tags} {
  # Typemethod to draw a straight piece of trackwork.
  # @param canvas The canvas to draw on.
  # @param x1 The first X coordinate.
  # @param y1 The first Y coordinate.
  # @param x2 The second X coordinate.
  # @param y2 The second Y coordinate.
  # @param flip The flipped flag.
  # @param orientation The orientation (8-way).
  # @param tags The canvas tags to include.

    if {$flip} {
      set y1 [expr {$y1 * -1}]
      set y2 [expr {$y2 * -1}]
    }
    set cos_sin $_RotateAngles($orientation)
    set cos [lindex $cos_sin 0]
    set sin [lindex $cos_sin 1]
    set xx1 [expr {$x1 * $cos - $y1 * $sin}]
    set yy1 [expr {$x1 * $sin + $y1 * $cos}]
    set xx2 [expr {$x2 * $cos - $y2 * $sin}]
    set yy2 [expr {$x2 * $sin + $y2 * $cos}]

    $canvas create line $xx1 $yy1 $xx2 $yy2 -width 4 -fill white -capstyle round -tag "$tags"
  }
  typemethod _SchematicDrawPolygon {canvas pointlist flip orientation tags} {
  # Typemethod to draw a polygon trackwork object.
  # @param canvas The canvas to draw on.
  # @param pointlist The list of points (x1 y1 x2 y2 ...). 
  # @param flip The flipped flag.
  # @param orientation The orientation (8-way).
  # @param tags The canvas tags to include.

    set flipped {}
    if {$flip} {
      foreach {x y} $pointlist {
        lappend flipped $x [expr {$y * -1}]
      }
    } else {
      set flipped $pointlist
    }
    set cos_sin $_RotateAngles($orientation)
    set cos [lindex $cos_sin 0]
    set sin [lindex $cos_sin 1]

    set rotated {}
    foreach {x y} $flipped {
      lappend rotated [expr {$x * $cos - $y * $sin}] [expr {$x * $sin + $y * $cos}]
    }

    $canvas create polygon $rotated -width 4 -fill white -joinstyle round -tag "$tags"
  }
  typemethod _SchematicDrawCurve {canvas x1 y1 x2 y2 flip orientation tags} {
  # Typemethod to draw a curved piece of trackwork.
  # @param x1 The first X coordinate.
  # @param y1 The first Y coordinate.
  # @param x2 The second X coordinate.
  # @param y2 The second Y coordinate.
  # @param flip The flipped flag.
  # @param orientation The orientation (8-way).
  # @param tags The canvas tags to include.

    if {$flip} {
      set orientation [expr {($orientation + 4) % 8}]
    }

    switch -exact "$orientation" {
      0 {set start 45}
      1 {set start 90}
      2 {set start 135}
      3 {set start 180}
      4 {set start 225}
      5 {set start 270}
      6 {set start 315}
      7 {set start 0}
    }

    $canvas create arc $x1 $y1 $x2 $y2 -style arc -start $start -extent -90 -width 4 -outline white -tag "$tags"
  }
  typemethod _SchematicDrawDot {canvas x1 y1 flip orientation tags} {
  # Typemethod to draw an invisible dot on the trackwork.  Used as anchor
  # points to connect trackwork sections together.
  # @param x1 The first X coordinate.
  # @param y1 The first Y coordinate.
  # @param flip The flipped flag.
  # @param orientation The orientation (8-way).
  # @param tags The canvas tags to include.

    if {$flip} {
      set y1 [expr {$y1 * -1}]
    }
    set cos_sin $_RotateAngles($orientation)
    set cos [lindex $cos_sin 0]
    set sin [lindex $cos_sin 1]

    set xx1 [expr {$x1 * $cos - $y1 * $sin}]
    set yy1 [expr {$x1 * $sin + $y1 * $cos}]

    $canvas create line $xx1 $yy1 $xx1 $yy1 -width 1 -fill black -tag "$tags"
  }
}

snit::type Switch {
## @brief %Switch (turnout) object type.
#
# These are on the schematic and represent a switch on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the switch on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -label The label of the switch (default "1").
# @arg -orientation The orientation (8-way) of the switch (readonly, 
#		default 0).
# @arg -flipped Whether or not the switch is flipped (readonly, default no).
# @arg -statecommand A command to run to get the switch's state (default {}).
# @arg -occupiedcommand A command to run to find out if the switch is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg Common Common terminal (point end of switch).
# @arg Main Mainline terminal.
# @arg Divergence Branchline terminal.
# 
# Defined values (states):
# @arg Normal Points are aligned for the mainline.
# @arg Reverse Points are aligned for the branchline.
# @arg Unknown Point are not aligned for any route (eg points are in motion).
# 
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  variable state normal
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a Switch object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the Switch on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawDot  $canvas 0 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Common $cp]
    $type _SchematicDrawLine $canvas 0 0 20 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 20 0 28 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 20 0 28 8 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]
    $canvas itemconfigure ${tag}_Reverse -fill black
    $canvas raise ${tag}_Normal  ${tag}_Reverse
    $canvas lower ${tag}_Reverse ${tag}_Normal 
    $type _SchematicDrawDot  $canvas 40 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Main $cp]
    $type _SchematicDrawLine $canvas 28 0 40 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 28 8 40 20 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawDot  $canvas 40 20 $options(-flipped) $options(-orientation) [list $tag ${tag}_Divergence $cp]

    set bbox [$canvas bbox ${tag}]
    $canvas create text [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}] \
		      [expr {[lindex $bbox 3] + 5}] -text $options(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    switch -exact -- $state {
      normal {return Normal}
      reverse {return Reverse}
      unknown {return Unknown}
    }
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    set tag $selfns
    if {[$self invoke]} {
      set color red
    } else {
      set color white
    }
#    puts stderr "*** $self: value = $value"
    switch -exact -- $value {
      Normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill $color
	$canvas raise ${tag}_Normal  ${tag}_Reverse
	$canvas lower ${tag}_Reverse ${tag}_Normal
	set state normal
	return Normal
      }
      Reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill $color
	$canvas raise ${tag}_Reverse ${tag}_Normal
	$canvas lower ${tag}_Normal  ${tag}_Reverse
	set state reverse
	return Reverse
      }
      Unknown {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas lower ${tag}_Normal
	$canvas lower ${tag}_Reverse
	set state unknown
	return Unknown
      }
    }
    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the switch.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {[string length "$options(-statecommand)"] > 0} {
      set newstate [uplevel #0 "$options(-statecommand)"]
      set state $newstate
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
#    puts stderr "*** $self: state = $state"
    switch -exact -- $state {
      normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
      }
      reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
      }
      default -
      unknown {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill black
	set state unknown
      }
    }
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type Signal {
## @brief %Signal object type.
#
# These are on the schematic and represent a Signal on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the Signal on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -label The label of the Signal (default "1").
# @arg -orientation The orientation (8-way) of the Signal (readonly, 
#		default 0).
# @arg -heads The number of heads (1, 2, or 3) of the Signal (readonly, default 1)
# @par
# Defined coords terminals: none.
# Defined values: The signal's aspect.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -heads -readonly yes -default 1 -validatemethod _VerifyHeads
  method _VerifyHeads {option value} {
  ##
    if {[lsearch {1 2 3} $value] < 0} {
      error "Expected 1, 2, or 3 for $option, got $value!"
    }
    return $value
  }
  
  component ctcpanel
  component canvas

  typemethod _SchematicDrawThinLine {canvas x1 y1 x2 y2 orientation tags} {
  ## Typemethod to draw a thin line.
  # @param canvas The canvas to draw on.
  # @param x1 The first X coordinate.
  # @param y1 The first Y coordinate.
  # @param x2 The second X coordinate.
  # @param y2 The second Y coordinate.
  # @param orientation The orientation (8-way).
  # @param tags The canvas tags to include.

    set cos_sin $_RotateAngles($orientation)
    set cos [lindex $cos_sin 0]
    set sin [lindex $cos_sin 1]
    set xx1 [expr {$x1 * $cos - $y1 * $sin}]
    set yy1 [expr {$x1 * $sin + $y1 * $cos}]
    set xx2 [expr {$x2 * $cos - $y2 * $sin}]
    set yy2 [expr {$x2 * $sin + $y2 * $cos}]

    $canvas create line $xx1 $yy1 $xx2 $yy2 -width 1 -fill white -capstyle round -tag "$tags"
  }
  typemethod _SchematicDrawOval {canvas x1 y1 dia orientation tags} {
  ## Typemethod to draw an invisible dot on the trackwork.  Used as anchor
  # points to connect trackwork sections together.
  # @param x1 The first X coordinate.
  # @param y1 The first Y coordinate.
  # @param dia The diameter of the oval.
  # @param orientation The orientation (8-way).
  # @param tags The canvas tags to include.

    set cos_sin $_RotateAngles($orientation)
    set cos [lindex $cos_sin 0]
    set sin [lindex $cos_sin 1]

    set xx1 [expr {$x1 * $cos - $y1 * $sin}]
    set yy1 [expr {$x1 * $sin + $y1 * $cos}]
    set rad [expr {double($dia) / 2.0}]
    set x0  [expr {$xx1 - $rad}]
    set y0  [expr {$yy1 - $rad}]
    set x1  [expr {$xx1 + $rad}]
    set y1  [expr {$yy1 + $rad}]

    $canvas create oval $x0 $y0 $x1 $y1 -fill white -tag "$tags"
  }
  variable aspect dark
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a Signal object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the Signal on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawThinLine $canvas 0 -5 0 5 $options(-orientation) [list $tag $cp]
    $type _SchematicDrawThinLine $canvas 0 0 30 0 $options(-orientation) [list $tag $cp]
    $type _SchematicDrawOval     $canvas 35 0 8   $options(-orientation) [list $tag $cp]
    $type _SchematicDrawOval     $canvas 35 0 4   $options(-orientation) [list $tag $cp ${tag}_Head1]
    if {$options(-heads) > 1} {
      $type _SchematicDrawOval     $canvas 25 0 8   $options(-orientation) [list $tag $cp]
      $type _SchematicDrawOval     $canvas 25 0 4   $options(-orientation) [list $tag $cp ${tag}_Head2]
    }
    if {$options(-heads) > 2} {
      $type _SchematicDrawOval     $canvas 15 0 8   $options(-orientation) [list $tag $cp]
      $type _SchematicDrawOval     $canvas 15 0 4   $options(-orientation) [list $tag $cp ${tag}_Head3]
    }
    $self setv dark
    set cos_sin $_RotateAngles($options(-orientation))
    set cos [lindex $cos_sin 0]
    set sin [lindex $cos_sin 1]
    set xt [expr {45 * $cos - 0 * $sin}]
    set yt [expr {45 * $sin + 0 * $cos}]
    switch $options(-orientation) {
      0 {set anchor w}
      1 {set anchor nw}
      2 {set anchor n}
      3 {set anchor ne}
      4 {set anchor e}
      5 {set anchor se}
      6 {set anchor s}
      7 {set anchor sw}
    }
    $canvas create text $xt $yt -text $options(-label) -anchor $anchor \
		      -font [list Courier -10] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Signals [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Signals [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (aspect).

    return $aspect
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    set tag $selfns
    set aspect $value
    switch $options(-heads) {
      1 {
	if {[llength $aspect] > 1} {set aspect [lindex $aspect 0]}
	if {[string equal -nocase $aspect dark]} {
	  set color black
	} else {
	  set color $aspect
	}
	$canvas itemconfigure ${tag}_Head1 -fill $color
      }
      2 {
	if {[llength $aspect] < 2} {lappend aspect dark}
	if {[llength $aspect] > 2} {set aspect [lrange $aspect 0 1]}
	foreach h {1 2} a $aspect {
	  if {[string equal -nocase $a dark]} {
	    set color black
	  } else {
	    set color $a
	  }
	  $canvas itemconfigure ${tag}_Head$h -fill $color
	}
      }
      3 {
	while {[llength $aspect] < 3} {lappend aspect dark}
	if {[llength $aspect] > 3} {set aspect [lrange $aspect 0 2]}
	foreach h {1 2 3} a $aspect {
	  if {[string equal -nocase $a dark]} {
	    set color black
	  } else {
	    set color $a
	  }
	  $canvas itemconfigure ${tag}_Head$h -fill $color
	}
      }
    }
    return $value
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the Signal.

    return false
  }
}

snit::type StraightBlock {
## @brief Straight Block object type.
#
# These are on the schematic and represent a piece of track on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the StraightBlock on.
# @param ... Options:
# @arg -x1 The first x coordinate of the object (readonly, default 0).
# @arg -y1 The first y coordinate of the object (readonly, default 0).
# @arg -x2 The second x coordinate of the object (readonly, default 0).
# @arg -y2 The second y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default MainLine).
# @arg -label The label of the StraightBlock (default "").
# @arg -position The position of the label (readonly, default below).
# @arg -occupiedcommand A command to run to find out if the block is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg E1 First endpoint.
# @arg E2 Second endpoint.
# 
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#


  option -x1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -x2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y2 -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default MainLine
  option -label -default "" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  CTCPanel::verifyPositionMethod
  option -occupiedcommand -default {}

  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
  ## Construct a StraightBlock object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the StraightBlock on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x1 $options(-x1)
    set y1 $options(-y1)
    set x2 $options(-x2)
    set y2 $options(-y2)

    $canvas create line $x1 $y1 $x1 $y1 -width 1 -fill black -tag [list $tag $cp ${tag}_E1]
    $canvas create line $x2 $y2 $x2 $y2 -width 1 -fill black -tag [list $tag $cp ${tag}_E2]
    $canvas create line $x1 $y1 $x2 $y2 -width 4 -fill white -capstyle round -tag [list $tag $cp]
    set bbox [$canvas bbox ${tag}]
    switch -exact -- $options(-position) {
      above {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 1] - 5}]
        set at s
      }
      below {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 3] + 5}]
        set at n
      }
      left {
        set xt [expr {[lindex $bbox 0] - 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at e
      }
      right {
        set xt [expr {[lindex $bbox 2] + 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at w
      }
    }

    $canvas create text $xt \
		      $yt  -text $options(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    return {}
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the StraightBlock.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
    return $isoccupied
  }
}

snit::type CurvedBlock {
## @brief Curved Block object type.
#
# These are on the schematic and represent a piece of track on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the CurvedBlock on.
# @param ... Options:
# @arg -x1 The first x coordinate of the object (readonly, default 0).
# @arg -y1 The first y coordinate of the object (readonly, default 0).
# @arg -x2 The second x coordinate of the object (readonly, default 0).
# @arg -y2 The second y coordinate of the object (readonly, default 0).
# @arg -radius The radius of the curve (readonly, default 10).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default MainLine).
# @arg -label The label of the CurvedBlock (default "").
# @arg -position The position of the label (readonly, default below).
# @arg -occupiedcommand A command to run to find out if the block is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg E1 First endpoint.
# @arg E2 Second endpoint.
# 
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -x2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -radius -readonly yes -default 10 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -controlpoint -readonly yes -default MainLine
  option -label -default "" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  CTCPanel::verifyPositionMethod
  option -occupiedcommand -default {}

  component ctcpanel
  component canvas
  typemethod _square {x} {
  ## Typemethod to compute the square of a number.

    return [expr {$x * $x}]
  }
  typevariable _PI [expr {asin(1.0) * 2.0}]
  typemethod _RadiansToDegrees {rads} {
  ## Typemethod to convert from radians to degrees

    return [expr {double($rads / $_PI) * 180.0}]
  }
  constructor {_ctcpanel _canvas args} {
  ## Construct a CurvedBlock object.  See @FinnApr04@ for an explaination of 
  # the underlying math.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the CurvedBlock on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x1 $options(-x1) ; #  a
    set y1 $options(-y1) ; #  b
    set x2 $options(-x2) ; #  c
    set y2 $options(-y2) ; #  d
    set radius $options(-radius) ; #  r

    # Range checking:
    set dx [expr {$x2 - $x1}]
    set dy [expr {$y2 - $y1}]
    set l  [expr {hypot($dx,$dy)}]
    if {$l > [expr {$radius * 2.0}]} {
      error "Range error: radius too small for points: ($x1,$y1) -> ($x2,$y2) = $l > [expr $radius * 2.0]"
    }
    if {[expr {abs($dx - $l)}] < 1.0 || [expr {abs($dy - $l)}] < 1.0} {
      error "Range error: dx or dy too small for points: ($x1,$y1) -> ($x2,$y2)"
    }

    set a $x1
    set b $y1
    set c $x2
    set d $y2
    set r $radius

    set J [expr {2.0*($a-$c)}]
    set G [expr {2.0*($b-$d)}]
    set T [expr {double([$type _square $a]+[$type _square $b]) - \
	         double([$type _square $c]+[$type _square $d])}]

    set u [expr {(1.0 + ([$type _square $J] / [$type _square $G]))}]
    set v [expr {(-2.0*$a) - ((2.0*$J*$T)/[$type _square $G]) + ((2.0*$J*$b)/$G)}]
    set w [expr {[$type _square $a]+[$type _square $b] + [$type _square $T]/[$type _square $G] - 2*$b*$T/$G - [$type _square $r]}]

    set sqrt [expr {sqrt([$type _square $v]-4.0*$u*$w)}]

    set m1 [expr {(-$v + $sqrt)/(2.0*$u)}]
    set n1 [expr {($T-$J*$m1)/$G}]

    set m2 [expr {(-$v - $sqrt)/(2.0*$u)}]
    set n2 [expr {($T-$J*$m2)/$G}]

    set at1 [expr atan2($c-$m1,$d-$n1)]
    set at2 [expr atan2($a-$m1,$b-$n1)]



#  set a11 [RadiansToDegrees [expr -atan2($y1-$n1,$x1-$m1)]]
#  set a12 [RadiansToDegrees [expr -atan2($y1-$n2,$x1-$m2)]]
#  set a21 [RadiansToDegrees [expr -atan2($y2-$n1,$x2-$m1)]]
#  set a22 [RadiansToDegrees [expr -atan2($y2-$n2,$x2-$m2)]]
#
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a11 = $a11"
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a12 = $a12"
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a21 = $a21 ([expr $a21 - $a11])"
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a22 = $a22 ([expr $a22 - $a12])"



#  puts stderr "*** CTCPanel::CurvedBlock_Create: at1 = $at1, at2 = $at2"
    set sn [expr sin($at1 - $at2)]
#  puts stderr "*** CTCPanel::CurvedBlock_Create: sn = $sn"

    if {$sn > 0} {
      set m $m1
      set n $n1
    } else {
      set m $m2
      set n $n2
    }

    set xc $m
    set yc $n

    set a1 [$type _RadiansToDegrees [expr {-atan2($y1-$yc,$x1-$xc)}]]
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a1 = $a1"
    set a2 [$type _RadiansToDegrees [expr {-atan2($y2-$yc,$x2-$xc)}]]
#  puts stderr "*** CTCPanel::CurvedBlock_Create: (1) a2 = $a2 ([expr $a2 - $a1])"
    if {$a2 < 0} {set a2 [expr $a2 + 360]}
#  puts stderr "*** CTCPanel::CurvedBlock_Create: (2) a2 = $a2 ([expr $a2 - $a1])"

    $canvas create line $x1 $y1 $x1 $y1 -width 1 -fill black -tag [list $tag $cp ${tag}_E1]
    $canvas create line $x2 $y2 $x2 $y2 -width 1 -fill black -tag [list $tag $cp ${tag}_E2]

    $canvas create  arc [expr $xc - $radius] [expr $yc - $radius] \
		      [expr $xc + $radius] [expr $yc + $radius] \
		      -start $a1 -extent [expr $a2 - $a1] \
		 -style arc -width 4 -outline white -tag [list $tag $cp]

    set bbox [$canvas bbox ${tag}]
    switch -exact -- $options(-position) {
      above {
        set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
        set yt [expr [lindex $bbox 1] - 5]
        set at s
      }
      below {
        set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
        set yt [expr [lindex $bbox 3] + 5]
        set at n
      }
      left {
        set xt [expr [lindex $bbox 0] - 5]
        set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
        set at e
      }
      right {
        set xt [expr [lindex $bbox 2] + 5]
        set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
        set at w
      }
    }

    $canvas create text $xt \
		      $yt  -text $options(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  # Method to get our value (state).

    return {}
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the CurvedBlock.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
    return $isoccupied
  }
}

snit::type ScissorCrossover {
## @brief Scissor Crossover (turnout) object type.
#
# These are on the schematic and represent a Scissor Crossover on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the switch on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -label The label of the switch (default "1").
# @arg -orientation The orientation (8-way) of the switch (readonly, 
#		default 0).
# @arg -flipped Whether or not the switch is flipped (readonly, default no).
# @arg -statecommand A command to run to get the switch's state (default {}).
# @arg -occupiedcommand A command to run to find out if the switch is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg Main1L Upper left mainline.
# @arg Main2L Lower left mainline.
# @arg Main1R Upper right mainline.
# @arg Main2R Lower right mainline.
# 
# Defined values (states):
# @arg Normal Points are aligned for the mainline.
# @arg Reverse Points are aligned for the branchline.
# @arg Unknown Point are not aligned for any route (eg points are in motion).
# 
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  variable state normal
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a ScissorCrossover object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the ScissorCrossover on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawDot  $canvas  0  0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Main1L $cp]
    $type _SchematicDrawDot  $canvas  0 20 $options(-flipped) $options(-orientation) [list $tag ${tag}_Main2L $cp]

    $type _SchematicDrawLine $canvas  0  0 16  0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas  0 20 16 20 $options(-flipped) $options(-orientation) [list $tag $cp]

    $type _SchematicDrawLine $canvas 16  0 26  0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 16  0 26  6 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]

    $type _SchematicDrawLine $canvas 16 20 26 20 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 16 20 26 14 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]

    $type _SchematicDrawLine $canvas 26  0 40  0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 26 20 40 20 $options(-flipped) $options(-orientation) [list $tag $cp]

    $type _SchematicDrawLine $canvas 26  6 40 14 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 26 14 40  6 $options(-flipped) $options(-orientation) [list $tag $cp]

    $type _SchematicDrawLine $canvas 40  0 50  0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 40  6 50  0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]
    $type _SchematicDrawLine $canvas 40 20 50 20 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 40 14 50 20 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]

    $type _SchematicDrawLine $canvas 50  0 66  0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 50 20 66 20 $options(-flipped) $options(-orientation) [list $tag $cp]

    $type _SchematicDrawDot  $canvas 66  0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Main1R $cp]
    $type _SchematicDrawDot  $canvas 66 20 $options(-flipped) $options(-orientation) [list $tag ${tag}_Main2R $cp]
    $canvas itemconfigure ${tag}_Reverse -fill black
    $canvas raise ${tag}_Normal ${tag}_Reverse
    $canvas lower ${tag}_Reverse ${tag}_Normal
    set bbox [$canvas bbox ${tag}]
    $canvas create text [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}] \
		      [expr {[lindex $bbox 3] + 5}] -text $options(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    switch -exact -- $state {
      normal {return Normal}
      reverse {return Reverse}
      unknown {return Unknown}
    }
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    set tag $selfns
    if {[$self invoke]} {
      set color red
    } else {
      set color white
    }
    switch -exact -- $value {
      Normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill $color
	$canvas raise ${tag}_Normal  ${tag}_Reverse
	$canvas lower ${tag}_Reverse ${tag}_Normal
	set state normal
	return Normal
      }
      Reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill $color
	$canvas raise ${tag}_Reverse ${tag}_Normal
	$canvas lower ${tag}_Normal  ${tag}_Reverse
	set state reverse
	return Reverse
      }
      Unknown {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas lower ${tag}_Normal
	$canvas lower ${tag}_Reverse
	set state unknown
	return Unknown
      }
    }
    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the switch.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {[string length "$options(-statecommand)"] > 0} {
      set newstate [uplevel #0 "$options(-statecommand)"]
      set state $newstate
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
    switch -exact -- $state {
      normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
      }
      reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
      }
      default -
      unknown {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill black
	set state unknown
      }
    }
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type Crossing {
## @brief %Crossing object type.
#
# These are on the schematic and represent a piece of track on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the switch on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -label The label of the switch (default "1").
# @arg -orientation The orientation (8-way) of the switch (readonly, 
#		default 0).
# @arg -flipped Whether or not the switch is flipped (readonly, default no).
# @arg -type The type of crossing (x90 or x45) (readonly, default x90).
# @arg -occupiedcommand A command to run to find out if the switch is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg MainL Mainline left.
# @arg MainR Mainline right.
# @arg AltL Alternitive line left.
# @arg AltR Alternitive line right.
# 
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -type -readonly yes -default x90 -validatemethod _VerifyCrossingType
  method _VerifyCrossingType {option value} {
  ##
    if {[lsearch -exact {x90 x45} $value] < 0} {
      error "$option must be one of x90 or x45, got $value"
    } else {
      return $value
    }
  }
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  constructor {_ctcpanel _canvas args} {
  ## Construct a Crossing object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the Crossing on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawDot  $canvas  0 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_MainL $cp]
    $type _SchematicDrawDot  $canvas 40 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_MainR $cp]
    $type _SchematicDrawLine $canvas  0 0 40 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    switch -exact -- $options(-type) {
      x90 {
	$type _SchematicDrawDot  $canvas 20 -20 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltL $cp]
	$type _SchematicDrawDot  $canvas 20  20 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltR $cp]
	$type _SchematicDrawLine $canvas 20 -20 20  20 $options(-flipped) $options(-orientation) [list $tag $cp]
      }
      x45 {
	$type _SchematicDrawDot  $canvas 5.8578643763 -14.1421356237 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltL $cp]
	$type _SchematicDrawDot  $canvas 34.1421356237 14.1421356237 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltR $cp]
	$type _SchematicDrawLine $canvas 5.8578643763 -14.1421356237 34.1421356237 14.1421356237 $options(-flipped) $options(-orientation) [list $tag $cp]
      }
    }

    set bbox [$canvas bbox ${tag}]
    $canvas create text [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}] \
		      [expr {[lindex $bbox 3] + 5}] -text $options(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    return {}
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the switch.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type SingleSlip {
## @brief Single Slip (turnout) object type.
#
# These are on the schematic and represent a switch on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the switch on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -label The label of the switch (default "1").
# @arg -orientation The orientation (8-way) of the switch (readonly, 
#		default 0).
# @arg -flipped Whether or not the switch is flipped (readonly, default no).
# @arg -statecommand A command to run to get the switch's state (default {}).
# @arg -occupiedcommand A command to run to find out if the switch is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg MainL Mainline left.
# @arg MainR Mainline right.
# @arg AltL Alternitive line left.
# @arg AltR Alternitive line right.
# 
# Defined values (states):
# @arg Normal Points are aligned for the mainline.
# @arg Reverse Points are aligned for the branchline.
# @arg Unknown Point are not aligned for any route (eg the points are in 
#      motion).
# 
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  variable state normal
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a SingleSlip object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the SingleSlip on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawDot  $canvas  0 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_MainL $cp]
    $type _SchematicDrawDot  $canvas 40 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_MainR $cp]
    $type _SchematicDrawDot  $canvas 5.8578643763 -14.1421356237 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltL $cp]
    $type _SchematicDrawDot  $canvas 34.1421356237 14.1421356237 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltR $cp]
    $type _SchematicDrawLine $canvas  0 0 10 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 30 0 40 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 5.8578643763 -14.142135623 12.92893218815 -7.07106781115000 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 27.07106781255000 7.07106781115000  34.1421356237 14.1421356237 $options(-flipped) $options(-orientation) [list $tag $cp]

    $type _SchematicDrawLine $canvas 10 0 30 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 12.92893218815 -7.07106781115000 27.07106781255000 7.07106781115000 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]

    $type _SchematicDrawLine $canvas 10 0 27.07106781255000 7.07106781115000 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]

    $canvas itemconfigure ${tag}_Reverse -fill black
    $canvas raise ${tag}_Normal  ${tag}_Reverse
    $canvas lower ${tag}_Reverse ${tag}_Normal 

    set bbox [$canvas bbox ${tag}]
    $canvas create text [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}] \
		      [expr {[lindex $bbox 3] + 5}] -text $options(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    switch -exact -- $state {
      normal {return Normal}
      reverse {return Reverse}
      unknown {return Unknown}
    }
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    set tag $selfns
    if {[$self invoke]} {
      set color red
    } else {
      set color white
    }
    switch -exact -- $value {
      Normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill $color
	$canvas raise ${tag}_Normal  ${tag}_Reverse
	$canvas lower ${tag}_Reverse ${tag}_Normal
	set state normal
	return Normal
      }
      Reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill $color
	$canvas raise ${tag}_Reverse ${tag}_Normal
	$canvas lower ${tag}_Normal  ${tag}_Reverse
	set state reverse
	return Reverse
      }
      Unknown {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas lower ${tag}_Normal
	$canvas lower ${tag}_Reverse
	set state unknown
	return Unknown
      }
    }
    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the switch.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {[string length "$options(-statecommand)"] > 0} {
      set newstate [uplevel #0 "$options(-statecommand)"]
      set state $newstate
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
    switch -exact -- $state {
      normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
      }
      reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
      }
      default -
      unknown {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill black
	set state unknown
      }
    }
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type DoubleSlip {
## @brief Double Slip (turnout) object type.
#
# These are on the schematic and represent a switch on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the switch on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -label The label of the switch (default "1").
# @arg -orientation The orientation (8-way) of the switch (readonly, 
#		default 0).
# @arg -flipped Whether or not the switch is flipped (readonly, default no).
# @arg -statecommand A command to run to get the switch's state (default {}).
# @arg -occupiedcommand A command to run to find out if the switch is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg MainL Mainline left.
# @arg MainR Mainline right.
# @arg AltL Alternitive line left.
# @arg AltR Alternitive line right.
# 
# Defined values (states):
# @arg Normal Points are aligned for the mainline.
# @arg Reverse Points are aligned for the branchline.
# @arg Unknown Point are not aligned for any route (eg the points are in motion).
# 
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  variable state normal
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a DoubleSlip object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the DoubleSlip on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawDot  $canvas  0 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_MainL $cp]
    $type _SchematicDrawDot  $canvas 40 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_MainR $cp]
    $type _SchematicDrawDot  $canvas 5.8578643763 -14.1421356237 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltL $cp]
    $type _SchematicDrawDot  $canvas 34.1421356237 14.1421356237 $options(-flipped) $options(-orientation) [list $tag ${tag}_AltR $cp]
    $type _SchematicDrawLine $canvas  0 0 10 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 30 0 40 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 5.8578643763 -14.142135623 12.92893218815 -7.07106781115000 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 27.07106781255000 7.07106781115000 34.1421356237 14.1421356237 $options(-flipped) $options(-orientation) [list $tag $cp]

    $type _SchematicDrawLine $canvas 10 0 30 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 12.92893218815 -7.07106781115000 27.07106781255000 7.07106781115000 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]

    $type _SchematicDrawLine $canvas 10 0 27.07106781255000 7.07106781115000 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]
    $type _SchematicDrawLine $canvas 12.92893218815 -7.07106781115000 30 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Reverse $cp]

    $canvas itemconfigure ${tag}_Reverse -fill black
    $canvas raise ${tag}_Normal  ${tag}_Reverse
    $canvas lower ${tag}_Reverse ${tag}_Normal 

    set bbox [$canvas bbox ${tag}]
    $canvas create text [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}] \
		      [expr {[lindex $bbox 3] + 5}] -text $options(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    switch -exact -- $state {
      normal {return Normal}
      reverse {return Reverse}
      unknown {return Unknown}
    }
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    set tag $selfns
    if {[$self invoke]} {
      set color red
    } else {
      set color white
    }
    switch -exact -- $value {
      Normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill $color
	$canvas raise ${tag}_Normal  ${tag}_Reverse
	$canvas lower ${tag}_Reverse ${tag}_Normal
	set state normal
	return Normal
      }
      Reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill $color
	$canvas raise ${tag}_Reverse ${tag}_Normal
	$canvas lower ${tag}_Normal  ${tag}_Reverse
	set state reverse
	return Reverse
      }
      Unknown {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas lower ${tag}_Normal
	$canvas lower ${tag}_Reverse
	set state unknown
	return Unknown
      }
    }
    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the switch.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {[string length "$options(-statecommand)"] > 0} {
      set newstate [uplevel #0 "$options(-statecommand)"]
      set state $newstate
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
    switch -exact -- $state {
      normal {
	$canvas itemconfigure ${tag}_Reverse -fill black
      }
      reverse {
	$canvas itemconfigure ${tag}_Normal  -fill black
      }
      default -
      unknown {
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas itemconfigure ${tag}_Normal  -fill black
	set state unknown
      }
    }
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type ThreeWaySW {
## @brief Three Way %Switch (turnout) object type.
#
# These are on the schematic and represent a switch on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the switch on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default CP1).
# @arg -label The label of the switch (default "1").
# @arg -orientation The orientation (8-way) of the switch (readonly, 
#		default 0).
# @arg -flipped Whether or not the switch is flipped (readonly, default no).
# @arg -statecommand A command to run to get the switch's state (default {}).
# @arg -occupiedcommand A command to run to find out if the switch is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg Common Points.
# @arg Main Mainline.
# @arg LDivergence Left branch.
# @arg RDivergence Right branch.
# 
# Defined values (states):
# @arg Normal Points are aligned for the mainline.
# @arg Right Points are aligned for the Right branch.
# @arg Left Points are aligned for the Left branch.
# @arg Unknown Point are not aligned for any route (eg the points are in motion).
# 
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  variable state normal
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a ThreeWaySW object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the ThreeWaySW on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawDot  $canvas 0 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Common $cp]
    $type _SchematicDrawLine $canvas 0 0 20 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 20 0 28 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Normal $cp]
    $type _SchematicDrawLine $canvas 20 0 28 8 $options(-flipped) $options(-orientation) [list $tag ${tag}_Right $cp]
    $type _SchematicDrawLine $canvas 20 0 28 -8 $options(-flipped) $options(-orientation) [list $tag ${tag}_Left $cp]
    $canvas itemconfigure ${tag}_Left -fill black
    $canvas itemconfigure ${tag}_Right -fill black
    $canvas raise ${tag}_Normal  ${tag}_Left
    $canvas lower ${tag}_Left ${tag}_Normal 
    $canvas lower ${tag}_Right ${tag}_Left
    $type _SchematicDrawDot  $canvas 40 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Main $cp]
    $type _SchematicDrawLine $canvas 28 0 40 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 28 8 40 20 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawDot  $canvas 40 20 $options(-flipped) $options(-orientation) [list $tag ${tag}_LDivergence $cp]
    $type _SchematicDrawLine $canvas 28 -8 40 -20 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawDot  $canvas 40 -20 $options(-flipped) $options(-orientation) [list $tag ${tag}_RDivergence $cp]

    set bbox [$canvas bbox ${tag}]
    $canvas create text [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}] \
		      [expr {[lindex $bbox 3] + 5}] -text $options(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]
    
    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    switch -exact -- $state {
      normal {return Normal}
      right {return Right}
      left {return Left}
      unknown {return Unknown}
    }
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    set tag $selfns
    if {[$self invoke]} {
      set color red
    } else {
      set color white
    }
    switch -exact -- $value {
      Normal {
	$canvas itemconfigure ${tag}_Right -fill black
	$canvas itemconfigure ${tag}_Left -fill black
	$canvas itemconfigure ${tag}_Normal  -fill $color
	$canvas raise ${tag}_Normal  ${tag}_Right
	$canvas lower ${tag}_Right ${tag}_Normal
	$canvas lower ${tag}_Left ${tag}_Right
	set state normal
	return Normal
      }
      Right {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Left  -fill black
	$canvas itemconfigure ${tag}_Right -fill $color
	$canvas raise ${tag}_Right ${tag}_Normal
	$canvas lower ${tag}_Normal  ${tag}_Right
	$canvas lower ${tag}_Left  ${tag}_Normal
	set state right
	return Right
      }
      Left {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Right  -fill black
	$canvas itemconfigure ${tag}_Left -fill $color
	$canvas raise ${tag}_Left ${tag}_Normal
	$canvas lower ${tag}_Normal  ${tag}_Left
	$canvas lower ${tag}_Right  ${tag}_Normal
	set state left
	return Left
      }
      Unknown {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Reverse -fill black
	$canvas lower ${tag}_Normal
	$canvas lower ${tag}_Reverse
	set state unknown
	return Unknown
      }
    }
    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the switch.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {[string length "$options(-statecommand)"] > 0} {
      set newstate [uplevel #0 "$options(-statecommand)"]
      set state $newstate
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
    switch -exact -- $state {
      normal {
	$canvas itemconfigure ${tag}_Right -fill black
	$canvas itemconfigure ${tag}_Left -fill black
      }
      right {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Left -fill black
      }
      left {
	$canvas itemconfigure ${tag}_Normal  -fill black
	$canvas itemconfigure ${tag}_Right -fill black
      }
      default -
      unknown {
	$canvas itemconfigure ${tag}_Right -fill black
	$canvas itemconfigure ${tag}_Left -fill black
	$canvas itemconfigure ${tag}_Normal  -fill black
	set state unknown
      }
    }
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type HiddenBlock {
## @brief Hidden Block object type.
#
# These are on the schematic and represent a piece of track on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the HiddenBlock on.
# @param ... Options:
# @arg -x1 The first x coordinate of the object (readonly, default 0).
# @arg -y1 The first y coordinate of the object (readonly, default 0).
# @arg -x2 The second x coordinate of the object (readonly, default 0).
# @arg -y2 The second y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default MainLine).
# @arg -label The label of the HiddenBlock (default "").
# @arg -position The position of the label (readonly, default below).
# @arg -orientation The orientation of the bridge (8-way) (readonly, default 0).
# @arg -flipped Whether the bridge is flipped (readonly, default no).
# @arg -occupiedcommand A command to run to find out if the HiddenBlock is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg E1 First endpoint.
# @arg E2 Second endpoint.
# 
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -x2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y2 -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -controlpoint -readonly yes -default MainLine
  option -label -default "" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  CTCPanel::verifyPositionMethod
  option -occupiedcommand -default {}

  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  constructor {_ctcpanel _canvas args} {
  ## Construct a HiddenBlock object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the HiddenBlock on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x1 $options(-x1)
    set y1 $options(-y1)
    set x2 $options(-x2)
    set y2 $options(-y2)
    set borientation $options(-orientation)
    set flipped $options(-flipped)

    $canvas create line $x1 $y1 $x1 $y1 -width 1 -fill black -tag [list $tag $cp ${tag}_E1]
    $canvas create line $x2 $y2 $x2 $y2 -width 1 -fill black -tag [list $tag $cp ${tag}_E2]
    set dx [expr {$x2 - $x1}]
    set dy [expr {$y2 - $y1}]
    set fdx [expr {$dx * .1}]  
    set fdy [expr {$dy * .1}]
    set xc [expr {$x1 + $fdx}]
    set yc [expr {$y1 + $fdy}]
    $canvas create line $x1 $y1 $xc $yc -width 4 -fill white -capstyle round -tag [list $tag $cp]
    set cx1 [expr {$xc - 10}]
    set cx2 [expr {$xc + 10}]
    set cy1 [expr {$yc - 10}]
    set cy2 [expr {$yc + 10}]
    $type _SchematicDrawCurve $canvas $cx1 $cy1 $cx2 $cy2 $flipped $borientation [list $tag $cp]

    set xc [expr {$x2 - $fdx}]
    set yc [expr {$y2 - $fdy}]
    $canvas create line $xc $yc $x2 $y2 -width 4 -fill white -capstyle round -tag [list $tag $cp]
    set cx1 [expr {$xc - 10}]
    set cx2 [expr {$xc + 10}]
    set cy1 [expr {$yc - 10}]
    set cy2 [expr {$yc + 10}]
    $type _SchematicDrawCurve $canvas $cx1 $cy1 $cx2 $cy2 [expr !$flipped] $borientation [list $tag $cp]

    set bbox [$canvas bbox ${tag}]
    switch -exact -- $options(-position) {
      above {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 1] - 5}]
        set at s
      }
      below {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 3] + 5}]
        set at n
      }
      left {
        set xt [expr {[lindex $bbox 0] - 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at e
      }
      right {
        set xt [expr {[lindex $bbox 2] + 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at w
      }
    }

    $canvas create text $xt \
		      $yt  -text $options(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    return {}
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the HiddenBlock.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type StubYard {
## @brief Stub Yard object type.
#
# These are on the schematic and represent a piece of track on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the StubYard on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default Yard).
# @arg -label The label of the StubYard (default "1").
# @arg -position The position of the label (readonly, default below).
# @arg -orientation The orientation (8-way) (readonly, default 0).
# @arg -flipped Whether the yard is flipped (readonly, default no).
# @arg -occupiedcommand A command to run to find out if the StubYard is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg Entry Yard throat.
# 
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default Yard
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -occupiedcommand -default {}
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  CTCPanel::verifyPositionMethod
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  typevariable _StubYard_Poly {
     20   0
     40  20
     60  20
     60 -20
     40 -20
  }
  ##

  constructor {_ctcpanel _canvas args} {
  ## Construct a StubYard object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the StubYard on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $type _SchematicDrawDot  $canvas 0 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_Entry $cp]
    $type _SchematicDrawLine $canvas 0 0 20 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawPolygon $canvas $_StubYard_Poly $options(-flipped) $options(-orientation) [list $tag $cp]
    set bbox [$canvas bbox ${tag}]
    switch -exact -- $options(-position) {
      above {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 1] - 5}]
        set at s
      }
      below {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 3] + 5}]
        set at n
      }
      left {
        set xt [expr {[lindex $bbox 0] - 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at e
      }
      right {
        set xt [expr {[lindex $bbox 2] + 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at w
      }
    }

    $canvas create text $xt \
		      $yt  -text $options(-label) -anchor $at \
		      -font [list Courier -14 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  ## Method to get our value (state).

    return {}
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the StubYard.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

snit::type ThroughYard {
## @brief Through Yard object type.
#
# These are on the schematic and represent a piece of track on the Schematic.
# @param _ctcpanel The CTCPanel megawidget.
# @param _canvas The schematic canvas to draw the ThroughYard on.
# @param ... Options:
# @arg -x The x coordinate of the object (readonly, default 0).
# @arg -y The y coordinate of the object (readonly, default 0).
# @arg -controlpoint The name of the control point this label is part of
#         (readonly, default Yard).
# @arg -label The label of the ThroughYard (default "1").
# @arg -position The position of the label (readonly, default below).
# @arg -orientation The orientation (8-way) (readonly, default 0).
# @arg -flipped Whether the yard is flipped (readonly, default no).
# @arg -occupiedcommand A command to run to find out if the ThroughYard is
#		occupied (default {}).
# @par
# Defined coords terminals:
# @arg EntryL Left yard throat.
# @arg EntryR Right yard throat.
# 
# Defined values (states): none.
# Defined indicators: none.
# @par
# @author Robert Heller \<heller\@deepsoft.com\>
#

  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  CTCPanel::verifyDoubleMethod
  option -label -default "1" -configuremethod _configureLabel
  method _configureLabel {option value} {
  ## Method to update the label option.

    set tag $selfns
    set options($option) "$value"
    $canvas itemconfigure ${tag}_label -text "$value"
  }
  option -controlpoint -readonly yes -default Yard
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  CTCPanel::verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  CTCPanel::verifyBoolMethod
  option -occupiedcommand -default {}
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  CTCPanel::verifyPositionMethod
  
  component ctcpanel
  component canvas
  CTCPanel::trackworkmethods
  typevariable _ThroughYard_Poly {
     20   0
     40  20
     60  20
     80   0
     60 -20
     40 -20
  }
  ##
  constructor {_ctcpanel _canvas args} {
  ## Construct a ThroughYard object.
  # @param _ctcpanel The CTCPanel megawidget.
  # @param _canvas The schematic canvas to draw the ThroughYard on.
  # @param ... Option list.

    set ctcpanel $_ctcpanel
    set canvas $_canvas
    $self configurelist $args
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

#    puts stderr "*** $type create $self: x = $x, y = $y"

    $type _SchematicDrawDot  $canvas 0 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_EntryL $cp]
    $type _SchematicDrawDot  $canvas 100 0 $options(-flipped) $options(-orientation) [list $tag ${tag}_EntryR $cp]
    $type _SchematicDrawLine $canvas 0 0 20 0 $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawPolygon $canvas $_ThroughYard_Poly $options(-flipped) $options(-orientation) [list $tag $cp]
    $type _SchematicDrawLine $canvas 80 0 100 0 $options(-flipped) $options(-orientation) [list $tag $cp]

    set bbox [$canvas bbox ${tag}]
    switch -exact -- $options(-position) {
      above {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 1] - 5}]
        set at s
      }
      below {
        set xt [expr {double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0}]
        set yt [expr {[lindex $bbox 3] + 5}]
        set at n
      }
      left {
        set xt [expr {[lindex $bbox 0] - 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at e
      }
      right {
        set xt [expr {[lindex $bbox 2] + 5}]
        set yt [expr {double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0}]
        set at w
      }
    }

    $canvas create text $xt \
		      $yt  -text $options(-label) -anchor $at \
		      -font [list Courier -14 bold] -tag [list $tag $cp ${tag}_label] \
		      -fill white
    $canvas move   $tag $x $y
    $canvas scale  $tag 0 0 [$ctcpanel getZoom] [$ctcpanel getZoom]

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork [namespace tail $self]
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
  ## Clean up all data objects and free up all resources.

    catch {
	$canvas delete $selfns
	$ctcpanel updateAndSyncCP $options(-controlpoint)
	$ctcpanel lremoveCP $options(-controlpoint) Trackwork [namespace tail $self]    
	$ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
    }
  }
  method getv  {} {
  # Method to get our value (state).

    return {}
  }
  method setv  {value} {
  ## Method to set out value (state).
  # @param value The new state to set.

    return {}
  }
  CTCPanel::standardMethods
  method geti  {ind} {
  ## Method to get the state of one of our indicators (none).

    return {}
  }
  method seti  {ind value} {
  ## Method to set an indicator's state (none).

    return {}
  }
  method invoke {} {
  ## Method to invoke the ThroughYard.

    set tag $selfns
    set isoccupied 0
    if {[string length "$options(-occupiedcommand)"] > 0} {
      set isoccupied [uplevel #0 "$options(-occupiedcommand)"]
    }
    if {$isoccupied} {
      $canvas itemconfigure $tag -fill red
    } else {
      $canvas itemconfigure $tag -fill white
    }
    $canvas itemconfigure ${tag}_label -fill white
#  puts stderr "*** -: returning $isoccupied"
    return $isoccupied
  }
}

} ; #  Namespace

#pack [CTCPanel::CTCPanel .panel] -expand yes -fill both
#pack [button .exit -command exit -text Exit] -fill x
#.panel create SWPlate foo -x 100 -y 100 -label Foo
#.panel create Signal foo -x 100 -y 100 -label Foo -heads 3 -orientation 0
#.panel setv foo {red green yellow}
#.panel create SIGPlate foosw -x 100 -y 200 -label Foo
#foreach o [.panel objectlist] {
#  .panel print $o stdout
#}

## @}

package provide CTCPanel 2.0
