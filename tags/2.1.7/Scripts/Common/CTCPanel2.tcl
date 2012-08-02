#* 
#* ------------------------------------------------------------------
#* CTCPanel2.tcl - CTC Panel Code, Version 2.0
#* Created by Robert Heller on Mon Mar  6 19:12:00 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
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
#*  
#* 

#@Chapter:CTCPanel2.tcl -- CTC Panel code, Version 2
#@Label:CTCPanel2.tcl
#$Id$

package require BWidget
package require snit

namespace eval CTCPanel {

snit::widget CTCPanel {
  widgetclass CTCPanel
  hulltype frame

  component schematic
  component schematicYscroll
  component xscroll
  component controls
  component controlsYscroll

  option {-schematicbackground background Background} \
	-default black \
	-cgetmethod _CgetSchematicBackground \
	-configuremethod _ConfigureSchematicBackground
  method _CgetSchematicBackground {option} {
    return [$schematic cget -background]
  }
  method _ConfigureSchematicBackground {option value} {
    return [$schematic configure -background $value]
  }
  option {-controlbackground background Background} \
	-default darkgreen \
	-cgetmethod _CgetControlBackground \
	-configuremethod _ConfigureControlBackground
  method _CgetControlBackground {option} {
    return [$controls cget -background]
  }
  method _ConfigureControlBackground {option value} {
    return [$controls configure -background $value]
  }
  option -width  -default 768 -validatemethod _PosInteger
  option -height -default 532 -validatemethod _PosInteger
  method _PosInteger {option value} {
    if {![string is integer -strict "$value"]} {
      error "$option takes an integer, got $value"
    } elseif {$value < 1} {
      error "$option takes a positive non-zero integer, got $value"
    } else {
      return $value
    }
  }

  variable scale 1.0
  variable CPList {}
  variable CPData -array {}
  variable Objects -array {}

  constructor {args} {
    set schematic $win.schematic.schematicDisplay
    set schematicYscroll $win.schematic.yscroll
    set xscroll $win.middle.xscroll
    set controls $win.controls.controlsDisplay
    set controlsYscroll $win.controls.yscroll
    set options(-height) [from args -height]
    set options(-width)  [from args -width]

    set canvasHeight [expr int(($options(-height) - 20) / 2)]

#    puts stderr "*** ${type}::constructor: win = $win, hull = $hull, self = $self"
    $hull configure -borderwidth 2

    pack [frame $win.schematic -borderwidth 2] -expand yes -fill both

    pack [canvas $schematic \
		-background "[from args -schematicbackground]" \
		-height $canvasHeight \
		-width $options(-width) \
		-xscrollcommand "[mymethod _CtcMainSyncX] $schematic $controls" \
		-yscrollcommand [list $schematicYscroll set] \
		-scrollregion [list 0 0 $options(-width) $canvasHeight]] \
	  -expand yes -fill both -side left
    bind $schematic <Configure> "[mymethod updateSR] %W %h %w"

    pack [scrollbar $schematicYscroll -command [list $schematic yview]] \
	-expand yes -fill y

    pack [frame $win.middle -borderwidth 2] -fill x

    pack [scrollbar $xscroll -command [mymethod _CtcMainHScroll2] \
			     -orient {horizontal}] \
	-expand yes -fill x -side left
    pack [frame $win.middle.filler -borderwidth {2} -height {20} -width {20}] \
	-side right

    pack [frame $win.controls -borderwidth {2}] -expand yes -fill both

    pack [canvas $controls \
		-background [from args -controlbackground] \
		-height $canvasHeight \
		-width $options(-width) \
		-xscrollcommand "[mymethod _CtcMainSyncX] $controls $schematic" \
		-yscrollcommand [list $controlsYscroll set] \
		-scrollregion [list 0 0 $options(-width) $canvasHeight]] \
	-expand yes -fill both -side left
    bind $controls <Configure> "[mymethod updateSR] %W %h %w"
    pack [scrollbar $controlsYscroll -command [list $controls yview]] \
	-expand yes -fill y
    $self configurelist $args
  }

  method _CtcMainSyncX {this other first last} {
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
    eval [list $schematic xview] $args
    eval [list $controls xview] $args
  }

  method zoomBy {zoomFactor} {
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
    if {$scale != 1} {
      set inv [expr 1.0 / double($scale)]
      $schematic scale all 0 0 $inv $inv
      $controls  scale all 0 0 $inv $inv
    }
    $schematic scale all 0 0 $zoomFactor $zoomFactor
    $controls  scale all 0 0 $zoomFactor $zoomFactor
    set scale $zoomFactor
    $self updateSR $w.schematic.schematicDisplay \
	[winfo height $w.schematic.schematicDisplay] \
	[winfo width $w.schematic.schematicDisplay]
    $self updateSR $w.controls.controlsDisplay \
	[winfo height $w.controls.controlsDisplay] \
	[winfo width  $w.controls.controlsDisplay]
  }
  method getZoom {} {
    return $scale
  }
  method getv {name} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj getv]
  }
  method setv {name value} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj setv $value]
  }
  method geti {name ind} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj geti $ind]
  }
  method seti {name ind value} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj seti $ind $value]
  }
  method itemcget {name option} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj cget $option]
  }
  method itemconfigure {name args} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [eval [list $obj configure] $args]
  }
  method exists {name} {
    return [expr [lsearch -exact [array names Objects] $name] >= 0]
  }
  method delete {name} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    set result [$obj destroy]
    unset Objects($name)
    return $result
  }
  method move {name x y} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj move $x $y]
  }
  method class {name} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj class]
  }
  method invoke {name} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj invoke]
  }
  method coords {name tname} {
    if {[catch [list set Objects($name)] obj]} {
      error "No such object: $name"
    }
    return [$obj coords $tname]
  }
  method print {name fp} {
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

  method objectlist {} {
    return [array names Objects]
  }

  method {create SWPlate} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SWPlate create $name $self $controls] $args]]
  }
  method {create SIGPlate} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SIGPlate create $name $self $controls] $args]]
  }
  method {create CodeButton} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::CodeButton create $name $self $controls] $args]]
  }
  method {create Toggle} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Toggle create $name $self $controls] $args]]
  }
  method {create Lamp} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Lamp create $name $self $controls] $args]]
  }
  method {create CTCLabel} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::CTCLabel create $name $self $controls] $args]]
  }
  method {create Switch} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Switch create $name $self $schematic] $args]]
  }
  method {create SchLabel} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SchLabel create $name $self $schematic] $args]]
  }
  method {create StraightBlock} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::StraightBlock create $name $self $schematic] $args]]
  }
  method {create CurvedBlock} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::CurvedBlock create $name $self $schematic] $args]]
  }
  method {create ScissorCrossover} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::ScissorCrossover create $name $self $schematic] $args]]
  }
  method {create Crossing} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::Crossing create $name $self $schematic] $args]]
  }
  method {create SingleSlip} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::SingleSlip create $name $self $schematic] $args]]
  }
  method {create DoubleSlip} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::DoubleSlip create $name $self $schematic] $args]]
  }
  method {create ThreeWaySW} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::ThreeWaySW create $name $self $schematic] $args]]
  }
  method {create HiddenBlock} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::HiddenBlock create $name $self $schematic] $args]]
  }
  method {create StubYard} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::StubYard create $name $self $schematic] $args]]
  }
  method {create ThroughYard} {name args} {
    if {![catch [list set Objects($name)] obj]} {
      error "Object name in use: $name!"
    }
    return [set Objects($name) [eval [list CTCPanel::ThroughYard create $name $self $schematic] $args]]
  }
  method checkInitCP {cp} {
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
    lappend CPData($cp,$slot) $what
  }
  method lremoveCP {cp slot what} {
    set index [lsearch -exact $CPData($cp,$slot) $what]
    if {$index == 0} {
      set CPData($cp,$slot) [lrange $CPData($cp,$slot) 1 end]
    } elseif {$index > 0} {
      set CPData($cp,$slot) [lreplace $CPData($cp,$slot) $index $index]
    }
  }
}


snit::macro leverMethods {hasCenter} {
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
  method _AddLever {pos} {
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

snit::macro verifyDoubleMethod {} { 
  method _VerifyDouble {option value} {
    if {![string is double -strict "$value"]} {
      error "$option takes a double, got $value"
    } else {
      return $value"
    }
  }
}

snit::macro verifyBoolMethod {} {
  method _VerifyBool {option value} {
    if {![string is boolean -strict "$value"]} {
      error "$option takes a boolean, got $value"
    } else {
      return $value"
    }
  }
}

snit::macro verifyColorMethod {} {
  method _VerifyColor {option value} {
    if {[catch [list winfo rgb $ctcpanel "$value"] message]} {
      error "$option takes a color ($message), got $value"
    } else {
      return $value"
    }
  }
}

snit::macro verifyOrientation8Method {} {
  set PI2 [expr asin(1.0)]
  typevariable _PI  [expr $PI2 * 2.0]
  set dtheta [expr acos(-1) / 4.0]
  typevariable _RotateAngles -array [list \
    0 [list [expr cos(0)] [expr sin(0)]] \
    1 [list [expr cos(1.0*$dtheta)] [expr sin(1.0*$dtheta)]] \
    2 [list [expr cos(2.0*$dtheta)] [expr sin(2.0*$dtheta)]] \
    3 [list [expr cos(3.0*$dtheta)] [expr sin(3.0*$dtheta)]] \
    4 [list [expr cos(4.0*$dtheta)] [expr sin(4.0*$dtheta)]] \
    5 [list [expr cos(5.0*$dtheta)] [expr sin(5.0*$dtheta)]] \
    6 [list [expr cos(6.0*$dtheta)] [expr sin(6.0*$dtheta)]] \
    7 [list [expr cos(7.0*$dtheta)] [expr sin(7.0*$dtheta)]] \
  ]
  method _VerifyOrientation8 {option value} {
    if {[lsearch -exact [array names _RotateAngles] $value] < 0} {
      error "$option out of range, must be one of [array names _RotateAngles], got $value"
    } else {
      return $value"
    }
  }
}

snit::macro verifyPositionMethod {} {
  method _VerifyPosition {option value} {
    if {[lsearch -exact {above below left right} $value] < 0} {
      error "$option must be one of above, below, left, or right, got $value"
    } else {
      return $value
    }
  }
}

snit::macro standardMethods {} {
  method coords {tname} {
    return [$canvas coords ${selfns}_${tname}]
  }
  method move   {x y} {
    return [$canvas move $selfns $x $y]
  }
}

snit::type SWPlate {
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
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -normalcommand  -default {}
  option -reversecommand -default {}
  variable lever none
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
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
    $ctcpanel lappendCP $options(-controlpoint) SwitchPlates $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) SwitchPlates $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  method class {} {return SWPlate}
  method getv  {} {
    switch -exact -- $lever {
      Left {return Normal}
      Right {return Reverse}
      default {return {}}
    }
  }
  method setv  {state} {
    switch -exact -- $state {
      N {$self _AddLever Left}
      R {$self _AddLever Right}
    }
    return $state
  }
  method geti  {ind} {
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
  standardMethods
  method invoke {} {
    switch -exact -- $lever {
      Left {set script "$options(-normalcommand)"}
      Right {set script "$options(-reversecommand)"}
      default {set script {}}
    }
#  puts stderr "*** -: script = '$script'"
    if {[string length "$script"] > 0} {
      uplevel #0 "$script"
    }
  }
  leverMethods no
}
  
snit::type SIGPlate {
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
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -leftcommand  -default {}
  option -centercommand -default {}
  option -rightcommand -default {}
  variable lever none
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
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
    $ctcpanel lappendCP $options(-controlpoint) SignalPlates $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) SignalPlates $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  method class {} {return SIGPlate}
  method getv  {} {
    switch -exact -- $lever {
      Left {return Left}
      Right {return Right}
      Center {return Center}
      default {return {}}
    }
  }
  method setv  {state} {
    switch -exact -- $state {
      L {$self _AddLever Left}
      C {$self _AddLever Center}
      R {$self _AddLever Right}
    }
    return $state
  }
  method geti  {ind} {
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
  standardMethods
  method invoke {} {
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
  }
  leverMethods yes
}

snit::type CodeButton {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -command -default {}
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
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
    $ctcpanel lappendCP $options(-controlpoint) CodeButtons $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) CodeButtons $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  method class {} {return CodeButton}
  method getv  {} {
    return {}
  }
  method setv  {state} {
    return {}
  }
  method geti {ind} {
    return {}
  }
  method seti {ind value} {
    return {}
  }
  standardMethods
  method invoke {} {
    set script "$options(-command)"
    if {[string length "$script"] > 0} {
      uplevel #0 "$script"
    }
  }
}  

snit::type Toggle {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default horizontal \
	-validatemethod _VerifyOrientationHV
  method _VerifyOrientationHV {option value} {
    if {[lsearch -exact {horizontal vertical} $value] < 0} {
      error "$option must be horizontal or vertical, got $value"
    } else {
      return $value
    }
  }
  option -leftlabel -default "on"
  option -rightlabel -default "off"
  option -centerlabel -default "off"
  option -hascenter -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -leftcommand -default {}
  option -rightcommand -default {}
  option -centercommand -default {}
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
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
    $ctcpanel lappendCP $options(-controlpoint) Toggles $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Toggles $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  
}

snit::type Lamp {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -color -default white -validatemethod _VerifyColor
  verifyColorMethod
  option -label -default "lamp"
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Lamps $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Lamps $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type CTCLabel {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -color -default white -validatemethod _VerifyColor
  verifyColorMethod
  option -label -default "lamp"
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) CTCLabels $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) CTCLabels $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type Switch {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type SchLabel {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -controlpoint -readonly yes -default CP1
  option -color -default white -validatemethod _VerifyColor
  verifyColorMethod
  option -label -default ""

  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) SchLabels $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) SchLabels $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type StraightBlock {
  option -x1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -x2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y2 -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -controlpoint -readonly yes -default MainLine
  option -label -default ""
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  verifyPositionMethod
  option -occupiedcommand -default {}

  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x1 $options(-x1)
    set y1 $options(-y1)
    set x2 $options(-x2)
    set y2 $options(-y2)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type CurvedBlock {
  option -x1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -x2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -radius -readonly yes -default 10 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -controlpoint -readonly yes -default MainLine
  option -label -default ""
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  verifyPositionMethod
  option -occupiedcommand -default {}

  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x1 $options(-x1)
    set y1 $options(-y1)
    set x2 $options(-x2)
    set y2 $options(-y2)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type ScissorCrossover {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type Crossing {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -type -readonly yes -default x90 -validatemethod _VerifyCrossingType
  method _VerifyCrossingType {option value} {
    if {[lsearch -exact {x90 x45} $value] < 0} {
      error "$option must be one of x90 or x45, got $value"
    } else {
      return $value
    }
  }
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type SingleSlip {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type DoubleSlip {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type ThreeWaySW {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default CP1
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -statecommand  -default {}
  option -occupiedcommand -default {}
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type HiddenBlock {
  option -x1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y1 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -x2 -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y2 -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -bridgeorientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -controlpoint -readonly yes -default MainLine
  option -label -default ""
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  verifyPositionMethod
  option -occupiedcommand -default {}

  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x1 $options(-x1)
    set y1 $options(-y1)
    set x2 $options(-x2)
    set y2 $options(-y2)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type StubYard {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default Yard
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -occupiedcommand -default {}
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  verifyPositionMethod
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

snit::type ThroughYard {
  option -x -readonly yes -default 0 -validatemethod _VerifyDouble
  option -y -readonly yes -default 0 -validatemethod _VerifyDouble
  verifyDoubleMethod
  option -label -default "1"
  option -controlpoint -readonly yes -default Yard
  option -orientation -readonly yes -default 0 -validatemethod _VerifyOrientation8
  verifyOrientation8Method
  option -flipped -readonly yes -default no -validatemethod _VerifyBool
  verifyBoolMethod
  option -occupiedcommand -default {}
  option -position -readonly yes -default below -validatemethod _VerifyPosition
  verifyPositionMethod
  
  component ctcpanel
  component canvas
  constructor {_ctcpanel _canvas args} {
    $self configurelist $args
    set ctcpanel $_ctcpanel
    set canvas $_canvas
    set tag $selfns
    set cp $options(-controlpoint)
    set x $options(-x)
    set y $options(-y)

    $ctcpanel checkInitCP $options(-controlpoint)
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lappendCP $options(-controlpoint) Trackwork $selfns
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
  destructor {
    $canvas delete $selfns
    $ctcpanel updateAndSyncCP $options(-controlpoint)
    $ctcpanel lremoveCP $options(-controlpoint) Trackwork $selfns    
    $ctcpanel updateSR $canvas [winfo height $canvas] [winfo width $canvas]
  }
}

}

#pack [CTCPanel::CTCPanel .panel] -expand yes -fill both
#pack [button .exit -command exit -text Exit] -fill x
#.panel create SWPlate foo -x 100 -y 100 -label Foo
#.panel create SIGPlate foosw -x 100 -y 200 -label Foo
#foreach o [.panel objectlist] {
#  .panel print $o stdout
#}

package provide CTCPanel 2.0
