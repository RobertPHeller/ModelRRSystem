#* 
#* ------------------------------------------------------------------
#* GetLensSpecDialog.tcl - Get Lens Specification Dialog
#* Created by Robert Heller on Sat Jan 13 16:48:44 2007
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

package require snit
package require BWidget

namespace eval GetLensSpecDialog {
  snit::type GetLensSpecDialog {
    pragma -hastypedestroy no
    pragma -hasinstances no
    pragma -hastypeinfo no

    typecomponent dialog
    typecomponent   lensLabelLE
    typecomponent   minFocusLF
    typecomponent     minFocusSB
    typecomponent   angleViewLF
    typecomponent     angleViewSB
    typevariable  _PI [expr {acos(0.0) * 2.0}]
    typeconstructor {
      set dialog {}
    }
    method createDialog {} {
      if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
      set dialog [Dialog::create .getLensSpecDialog \
			-class GetLensSpecDialog -bitmap questhead -default 0 \
			-cancel 1 -modal local -transient yes -parent . \
			-side bottom -title {Lens Specification}]
      $dialog add -name ok -text OK -command [mytypemethod _OK]
      $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
      $dialog add -name help -text Help \
		  -command [list BWHelp::HelpTopic GetLensSpecDialog]
      set frame [Dialog::getframe $dialog]
      set lw 21
      set lensLabelLE [LabelEntry::create $frame.lensLabelLE \
				-label "Lens Name:" -labelwidth $lw]
      pack $lensLabelLE -fill x
      set minFocusLF [LabelFrame::create $frame.minFocusLF \
				-text "Minimum Focus (feet):" -width $lw]
      pack $minFocusLF -fill x
      set minFocusSB [SpinBox::create [$minFocusLF getframe].sb \
			-range {.1 10.0 .1}]
      pack $minFocusSB -fill x
      set angleViewLF [LabelFrame::create $frame.angleViewLF \
				-text "View Angle (degrees):" -width $lw]
      pack $angleViewLF -fill x
      set angleViewSB [SpinBox::create [$angleViewLF getframe].sb \
			-range {0.0 180.0 1.0}]
      pack $angleViewSB -fill x
    }
    typemethod _OK {} {
      Dialog::withdraw $dialog
      return [Dialog::enddialog $dialog ok]
    }
    typemethod _Cancel {} {
      Dialog::withdraw $dialog
      return [Dialog::enddialog $dialog cancel]
    }
    typemethod draw {args} {
      $type createDialog
      switch [Dialog::draw $dialog] {
	cancel {return {}}
	ok {
	  return [list \
		"[$lensLabelLE cget -text]" \
		[$minFocusSB cget -text] \
		[expr {(double([$angleViewSB cget -text]) / 180.0) * $_PI}] \
		 ]
        }
      }
    }
  }
}



package provide GetLensSpecDialog 1.0
