#* 
#* ------------------------------------------------------------------
#* FCFDivisions.tcl - Division Functions
#* Created by Robert Heller on Mon Oct 31 20:19:17 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.6  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.5  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.4  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.3  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:37  heller
#* Modification History: Nov 4, 2005 Lockdown
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

SplashWorkMessage "Loading Division code" 40

package require snit
package require BWidget

snit::type SelectADivisionDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent dlist
  typecomponent dlistlist
  typecomponent selent

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .selectADivisionDialog \
		-bitmap questhead -default 0 \
		-cancel 1 -modal local -transient yes -parent . \
		-side bottom -title {Select A Division}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help \
			-command [list BWHelp::HelpTopic SelectADivisionDialog]
    set frame [Dialog::getframe $dialog]
    set dlist [ScrolledWindow::create $dialog.dlist -scrollbar both -auto both]
    pack $dlist -expand yes -fill both
    set dlistlist [ListBox::create $dlist.list -selectmode single]
    pack $dlistlist -expand yes -fill both
    $dlist setwidget $dlistlist
    $dlistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $dlistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set selent [LabelEntry::create $frame.selent \
			-label {Division Symbol Selection:}]
    pack $selent -fill x
    $selent bind <Return> [mytypemethod _OK]
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title [from args -title "Select A Division"]
    $type _fillList
    BWidget::focus $selent 1
    wm transient [winfo toplevel $dialog] .
    return [eval [list Dialog::draw $dialog]]
  }
  typemethod _Cancel {} {
    eval [list Dialog::withdraw $dialog]]
    return [eval [list Dialog::enddialog $dialog] [list {NULL}]]
  }
  typemethod _OK {} {
    set selectedDivisionSymbol "[$selent cget -text]"
    set selectedDivision [TheSystem FindDivisionBySymbol "$selectedDivisionSymbol"]
    if {[string equal "$selectedDivision" {NULL}]} {
      tk_messageBox -icon warning -type ok -message "No such division symbol $data(selectedDivision)"
      return
    }
    eval [list Dialog::withdraw $dialog]
    return [eval [list Dialog::enddialog $dialog] [list "$selectedDivision"]]
  }
  typemethod _SelectFromList { selectedItem } {
    set lb $dlistlist
    set elt [$lb itemcget $selectedItem -data]
    set selectedDivisionSymbol [lindex $elt 0]
    set selectedDivision [TheSystem FindDivisionBySymbol "$selectedDivisionSymbol"]
    if {[string equal "$selectedDivision" {NULL}]} {
      tk_messageBox -icon warning -type ok -message "No such division symbol $data(selectedDivision)"
      return
    }
    eval [list Dialog::withdraw $dialog]
    return [eval [list Dialog::enddialog $dialog] [list "$selectedDivision"]]
  }
  typemethod _BrowseFromList { selectedItem } {
    set lb $dlistlist
    set elt [$lb itemcget $selectedItem -data]
    set selectedDivision "[lindex $elt 0]"
    $selent configure -text "$selectedDivision"
  }
  typemethod _fillList {} {
    set lb $dlistlist
    $lb delete [$lb items]
    foreach Dx [TheSystem DivisionIndexList] {
      set division [TheSystem FindDivisionByIndex $Dx]
      if {[string equal $division {NULL}]} {continue}
      $lb insert end $Dx \
	-data  [list [Division_Symbol $division] [Division_Name $division]] \
	-text  "[Division_Symbol $division] [Division_Name $division]"
    }
  }
}

proc SelectADivision {{title {Select A Division}}} {
  global TheSelectADivisionDialog

  return [SelectADivisionDialog draw -title "$title"]
}

package provide FCFDivisions 1.0
