#* 
#* ------------------------------------------------------------------
#* FCFSelectAnIndustryDialog.tcl - Select an Industry Dialog
#* Created by Robert Heller on Sun Feb 19 18:53:59 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2006/04/01 17:12:09  heller
#* Modification History: Lock Down APR012006
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

snit::type SelectAnIndustryDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent patent
  typecomponent ilist
  typecomponent ilistlist
  typecomponent selent

  typeconstructor {
    set dialog [Dialog::create .selectAnIndustryDialog \
		    -class SelectAnIndustryDialog -bitmap questhead -default 0 \
		    -cancel 2 -modal local -transient yes -parent . \
		    -side bottom -title {Select An Industry}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name filter -text Filter -command [mytypemethod _Filter]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    $dialog add -name help -text Help \
		    -command [list BWHelp::HelpTopic SelectAnIndustryDialog]
    set frame [Dialog::getframe $dialog]
    set patent [LabelEntry::create $frame.patent \
		    -label {Industry Name Pattern:} \
		    -labelwidth 22]
    $patent bind <Return> "[mytypemethod _Filter];break"
    pack $patent -fill x
    set ilist [ScrolledWindow::create $frame.ilist -scrollbar both -auto both]
    pack $ilist -expand yes -fill both
    set ilistlist [ListBox::create $ilist.list -selectmode single]
    pack $ilistlist -expand yes -fill both
    $ilist setwidget $ilistlist
    $ilistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $ilistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set selent [LabelEntry::create $frame.selent \
		    -label {Industry Name Selection:} \
		    -labelwidth 22]
    pack $selent -fill x
    $selent bind <Return> [mytypemethod _OK]
  }
  typemethod draw {args} {
    $dialog configure -title [from args -title {Select An Industry}]
    BWidget::focus $patent 1
    return [Dialog::draw $dialog]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog NULL]
  }
  typemethod _OK {} {
    set selectedIndustryName "[$selent cget -text]"
    set selectedIndustry [::TheSystem FindIndustryByName \
					"$selectedIndustryName"]
    Dialog::withdraw $dialog]
    return [Dialog::enddialog $dialog $selectedIndustry]
  }
  typemethod _Filter { } {
    set pattern "[$patent cget -text]"
    set indexes [::TheSystem SearchForIndustryPattern "$pattern"]
    set lb $ilistlist
    $lb delete [$lb items]
    foreach Ix $indexes {
      set industry [::TheSystem FindIndustryByIndex $Ix]
      if {[string equal "$industry" {NULL}]} {continue}
      set industryName "[Industry_Name $industry]"
      $lb insert end $Ix \
	-text "$industryName" \
	-data [list "$industry" "$industryName"]
    }
  }
  typemethod _SelectFromList { selectedItem } {
    set lb $ilistlist
    set elt [$lb itemcget $selectedItem -data]
    set result [lindex $elt 0]
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog $result]
  }
  typemethod _BrowseFromList { selectedItem } {
    set lb $ilistlist
    set elt [$lb itemcget $selectedItem -data]
    $selent configure -text "[lindex $elt 1]"
  }
}


package provide FCFSelectAnIndustryDialog 1.0
