#* 
#* ------------------------------------------------------------------
#* FCFSelectATrainDialog.tcl - Select a Train dialog
#* Created by Robert Heller on Sun Feb 19 10:43:29 2006
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
package require snit

# SelectATrainDialog

snit::type SelectATrainDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent patent
  typecomponent tlist
  typecomponent tlistlist
  typecomponent selent

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .selectATrainDialog \
		    -bitmap questhead -default 0 \
		    -cancel 2 -modal local -transient yes -parent . \
		    -side bottom -title [_ "Select A Train"]]
    $dialog add -name ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add -name filter -text [_m "Button|Filter"] -command [mytypemethod _Filter]
    $dialog add -name cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text [_m "Button|Help"] \
			-command [list HTMLHelp::HTMLHelp help {Select A Train Dialog}]
    set frame [Dialog::getframe $dialog]
    set lwidth [_mx "Label|Train Name Pattern:" "Label|Train Name Selection:"]
    set patent [LabelEntry::create $frame.patent \
			-label [_m "Label|Train Name Pattern:"] -labelwidth $lwidth -text {*}]
    pack $patent -fill x
    set tlist [ScrolledWindow::create $frame.tlist \
			-scrollbar both -auto both]
    pack $tlist -expand yes -fill both
    set tlistlist [ListBox::create $tlist.list -selectmode single]
    pack $tlistlist -expand yes -fill both
    $tlist setwidget $tlistlist
    $tlistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $tlistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set selent [LabelEntry::create $frame.selent \
			-label [_m "Label|Train Name Selection:"] -labelwidth $lwidth]
    pack $selent -fill x
    $selent bind <Return> [mytypemethod _OK]
    $patent bind <Return> "[mytypemethod _Filter];break"
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title [from args -title [_ "Select A Train"]]
    BWidget::focus $patent 1
    wm transient [winfo toplevel $dialog] .
    $type _Filter
    return [Dialog::draw $dialog]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog NULL]
  }
  typemethod _OK {} {
    set selectedTrainName "[$selent cget -text]"
    set selectedTrain [::TheSystem FindTrainByName "$selectedTrainName"]
    Dialog::withdraw $dialog]
    return [Dialog::enddialog $dialog] $selectedTrain]
  }
  typemethod _Filter {} {
    set pattern "[$patent cget -text]"
    if {[regexp {[\*\?\[]} "$pattern"] < 1} {append pattern "*"}
    set indexes [::TheSystem SearchForTrainPattern "$pattern"]
#    puts stderr "*** $type _Filter: pattern = '$pattern', indexes = $indexes"
    set lb $tlistlist
    $lb delete [$lb items]
    foreach Tx $indexes {
      set train [::TheSystem FindTrainByIndex $Tx]
      if {[string equal "$train" {NULL}]} {continue}
      set trainName "[Train_Name $train]"
      $lb insert end $Tx \
	-text "$trainName" \
	-data [list "$train" "$trainName"]
    }
  }
  typemethod _OK {} {
    set selectedTrainName "[$selent cget -text]"
    set selectedTrain [::TheSystem FindTrainByName "$selectedTrainName"]
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog $selectedTrain]
  }
  typemethod _SelectFromList { selectedItem } {
    set lb $tlistlist
    set elt [$lb itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval Dialog::withdraw $dialog]
    return [Dialog::enddialog $dialog $result]
  }
  typemethod _BrowseFromList { selectedItem } {
    set lb $tlistlist
    set elt [$lb itemcget $selectedItem -data]
    $selent configure -text "[lindex $elt 1]"
  }
}

package provide FCFSelectATrainDialog 1.0
