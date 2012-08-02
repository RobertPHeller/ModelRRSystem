#* 
#* ------------------------------------------------------------------
#* FCFManageOneTrainDialog.tcl - Manage one train dialog
#* Created by Robert Heller on Sun Feb 19 10:48:18 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.5  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.4  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.3  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.2  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.1  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
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

# $Id$

package require BWidget
package require BWLabelSpinBox
package require snit

snit::type ManageOneTrainDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent printP
  typecomponent maxLength
  typecomponent shiftNo

  typevariable train
  typevariable printP_value
  typevariable shiftNo_value

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    set dialog [Dialog::create .manageOneTrainDialog \
	-bitmap questhead -default 0 \
	-cancel 2 -modal local -transient yes -parent . \
	-side bottom -title {Train Management Dialog}]
    $dialog add -name ok -text OK -command [mytypemethod  _OK]
    $dialog add -name apply -text Apply -command  [mytypemethod _Apply]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help \
			-command  [list BWHelp::HelpTopic ManageOneTrainDialog]
    set frame [Dialog::getframe $dialog]
    set printP [LabelFrame::create $frame.printP \
		-text {Print Train?} -width 13]
    pack $printP -fill x
    set ppframe [LabelFrame::getframe $printP]
    pack [radiobutton $ppframe.yes -text Yes -value 1 \
	-variable [mytypevar printP_value]] -side left
    pack [radiobutton $ppframe.no -text No -value 0 \
	-variable [mytypevar printP_value]] -side left
    set maxLength [LabelSpinBox::create $frame.maxLength \
				-label {Max Length:} \
				-labelwidth 13 -range {1 1000 1}]
    pack $maxLength -fill x
    set shiftNo [LabelFrame::create $frame.shiftNo \
			-text {Shift Number:} -width 13]
    pack $shiftNo -fill x
    set snframe [$shiftNo getframe]
    pack [radiobutton $snframe.s1 -text 1 -value 1 \
    	-variable [mytypevar shiftNo_value]] -side left
    pack [radiobutton $snframe.s2 -text 2 -value 2 \
    	-variable [mytypevar shiftNo_value]] -side left
    pack [radiobutton $snframe.s3 -text 3 -value 3 \
    	-variable [mytypevar shiftNo_value]] -side left
    set printP_value 0
    set shiftNo_value 1
    wm transient [winfo toplevel $dialog] .
  }
  typemethod _CheckTrain {value} {
    if {[string equal "$value" {}]} {
      return NULL
    } elseif {![string equal "$value" NULL] &&
	 [regexp {^_[0-9a-z]*_p_Train$} "$value"] < 1} {
      error "Not a pointer to a train: $value"
    } else {
      return $value
    }
  }
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title "[from args -title {Train Management Dialog}]"
    set train [from args -train NULL]
    set train [$type _CheckTrain $train]
    if {[llength [info commands TheSystem]] > 0 &&
	![string equal "$train" NULL]} {
      set printP_value [::Train_Print $train]
      set shiftNo_value [::Train_Shift $train]
      $maxLength configure -text [::Train_MaxLength $train]
    } else {
      set printP_value 0
      set shiftNo_value 1
      $maxLength configure -text 1
    }
    wm transient [winfo toplevel $dialog] .
    return [eval [list Dialog::draw $dialog]]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list Cancel]]
  }
  typemethod _OK {} {
    $type _Apply
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list OK]]
  }
  typemethod _Apply {} {
    if {[llength [info commands TheSystem]] > 0 &&
	![string equal "$train" NULL]} {
      ::Train_SetPrint $train $printP_value
      ::Train_SetShift $train $shiftNo_value
      ::Train_SetMaxLength $train [$maxLength cget -text]
    }
  }
}

package provide FCFManageOneTrainDialog 1.0
