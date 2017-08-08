#* 
#* ------------------------------------------------------------------
#* Lens.tcl - Lens type
#* Created by Robert Heller on Sun Jan 14 10:21:35 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.1  2007/02/01 20:00:53  heller
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

package require gettext
package require Tk
package require snit
package require tile
package require Dialog
package require LabelFrames

namespace eval Lens {
  snit::type Lens {
    # SNIT Type that implements a lens.  A lens has three read-only options.
    # <option> -minimumfocus The minimum focus distance, a positive double.
    # <option> -viewangle The view angle of the lens, an angle in degrees.
    # <option> -name The name of the lens, a string.
    option -minimumfocus -readonly yes -default 1.48 -validatemethod CheckPositiveDouble
    option -viewangle    -readonly yes -default 47   -validatemethod CheckAngle
    option -name         -readonly yes -default {Minolta 50mm}
    method CheckPositiveDouble {option value} {
      if {![string is double -strict "$value"]} {
	error "Expected a positive double for $option, got $value"
      }
      if {$value < 0} {
	error "Expected a positive double for $option, got $value"
      }
      return $value
    }
    method CheckAngle {option value} {
      $self CheckPositiveDouble $option "$value"
      if {$value >= 180.0} {
	error [format [_ "Expected a positive double < 180.0 for $option, got %s"] $value]
      }
      return $value
    }
    # Constant PI.
    typevariable _PI [expr {acos(0.0)*2.0}]
    # View angle in Radians.
    method viewAngleRadians {} {
      return [expr {(double($options(-viewangle)) / 180.0) * $_PI}]
    }
    # All defined / loaded lenses.
    typevariable _allLenses -array {}
    # Constructor -- create a lens.
    constructor {args} {
      $self configurelist $args
      if {![catch {set _allLenses($options(-name))}]} {
	error [format [_ "Duplicate lens name: %s!"] $options(-name)]
      }
      set _allLenses($options(-name)) $self
    }
    # Destructor -- delete a lens.
    destructor {
      catch {unset _allLenses($options(-name))}
    }
    #************************************************
    # Get Lens Specification Dialog.
    #
    typecomponent dialog;#		Main dialog
    typecomponent   lensLabelLE;#	Lens name
    typecomponent   minFocusLF;#	Minimum focus
    typecomponent     minFocusSB
    typecomponent   angleViewLF;#	View angle
    typecomponent     angleViewSB
    typeconstructor {
      set dialog {}
    }
    typemethod createDialog {} {
      if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
      set dialog [Dialog .getLensSpecDialog \
			-class GetLensSpecDialog -bitmap questhead -default ok \
			-cancel cancel -modal local \
			-side bottom -title [_ "Lens Specification"]]
      $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
      $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
      $dialog add help -text [_m "Button|Help"] \
		  -command [list HTMLHelp HelpTopic GetLensSpecDialog]
      set frame [$dialog getframe]
      set lw 21
      set lensLabelLE [LabelEntry $frame.lensLabelLE \
				-label [_m "Label|Lens Name:"] -labelwidth $lw]
      pack $lensLabelLE -fill x
      set minFocusLF [LabelFrame $frame.minFocusLF \
				-text [_m "Label|Minimum Focus (feet):"] -width $lw]
      pack $minFocusLF -fill x
      set minFocusSB [spinbox [$minFocusLF getframe].sb \
			-from .1 -to 10.0 -increment .1]
      pack $minFocusSB -fill x
      set angleViewLF [LabelFrame $frame.angleViewLF \
				-text [_m "Label|View Angle (degrees):"] -width $lw]
      pack $angleViewLF -fill x
      set angleViewSB [spinbox [$angleViewLF getframe].sb \
			-from 0.0 -to 180.0 -increment 1.0]
      pack $angleViewSB -fill x
    }
    typemethod _OK {} {
      $dialog withdraw
      return [$dialog enddialog yes]
    }
    typemethod _Cancel {} {
       $dialog withdraw
      return [$dialog enddialog no]
    }
    typemethod getnewlensspec {args} {
      $type createDialog
      set parent [from args -parent .]
      $dialog configure -parent $parent
      wm transient [winfo toplevel $dialog] $parent
      if {[$dialog draw]} {
	$type create %AUTO% \
		-minimumfocus "[$minFocusSB get]" \
		-viewangle    "[$angleViewSB get]" \
		-name         "[$lensLabelLE get]"
	set updateScript [from args -updatescript {}]
	if {![string equal "$updateScript" {}]} {
	  uplevel #0 "$updateScript"
	}
      }
    }
    # Return all lenses.
    typemethod alllenses {} {
      return [lsort -dictionary [array names _allLenses]]
    }
    # Select a lens by name.
    typemethod selectlensbyname {name} {
      if {[catch {set _allLenses($name)} lens]} {
	error "No such lens:  $name!"
      } else {
	return $lens
      }
    }
    # Write lens to channel.
    method writelenstochanel {channel} {
      puts $channel [list "$options(-name)" $options(-minimumfocus) $options(-viewangle)]
    }
    # Write all lenses to channel.
    typemethod writealllensestochannel {channel} {
      foreach l [$type alllenses] {
	[$type selectlensbyname $l] writelenstochanel $channel
      }
    }
    # Read all lenses from a channel.
    typemethod readlensesfromchannel {channel} {
      while {[gets $channel lensspec] >= 0} {
	if {[llength $lensspec] != 3} {continue}
	foreach {name minimumfocus viewangle} $lensspec {
	  if {![catch {set _allLenses($name)} oldlens]} {
	    $oldlens destroy
	  }
	  $type create %AUTO% -minimumfocus $minimumfocus \
			      -viewangle $viewangle \
			      -name "$name"
	}
      }
    }
  }
  snit::widgetadaptor LensComboBox {
    
    delegate option * to hull except {-state}
    delegate method * to hull except {cget configure}
    constructor {args} {
      set lenslist [Lens::Lens alllenses]
      set w 0
      foreach l $lenslist {
	set len [string length "$l"]
	if {$len > $w} {set w $len}
      }
      installhull using ttk::combobox -state readonly -values $lenslist -width $w
      $hull set [lindex $lenslist 0]
      $self configurelist $args
    }
    method getselectedlens {} {
      return [Lens::Lens selectlensbyname "[$hull get]"]
    }
    method updatelenslist {} {
      set lenslist [Lens::Lens alllenses]
      set w 0
      foreach l $lenslist {
	set len [string length "$l"]
	if {$len > $w} {set w $len}
      }
      $hull configure -values $lenslist
      if {[$hull cget -width] < $w} {$hull configure -width $w}
      if {[string equal "[$hull get]" {}]} {
          $hull set [lindex [$hull cget -values] 0]
      }
    }
  }
}

package provide Lens 1.0
