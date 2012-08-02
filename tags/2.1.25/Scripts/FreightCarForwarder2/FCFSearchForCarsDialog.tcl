#* 
#* ------------------------------------------------------------------
#* FCFSearchForCarsDialog.tcl - Search for cars dialog
#* Created by Robert Heller on Sat Feb 18 14:19:54 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.6  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.5  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.4  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
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

snit::type SearchForCarsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent patent
  typecomponent clist
  typecomponent clistlist
  typecomponent selent

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .searchForCarsDialog \
		    -bitmap questhead -default 0 \
		    -cancel 2 -modal local -transient yes -parent . \
		    -side bottom -title {Search For Cars}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name filter -text Filter -command [mytypemethod _Filter]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help \
			-command [list HTMLHelp::HTMLHelp help {Search For Cars Dialog}]
    set frame [Dialog::getframe $dialog]
    set patent [LabelEntry::create $frame.patent \
			-label {Car Number Pattern:} -labelwidth 22]
    pack $patent -fill x
    set clist [ScrolledWindow::create $frame.clist \
			-scrollbar both -auto both]
    pack $clist -expand yes -fill both
    set clistlist [ListBox::create $clist.list -selectmode single]
    pack $clistlist -expand yes -fill both
    $clist setwidget $clistlist
    $clistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $clistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set selent [LabelEntry::create $frame.selent \
			-label {Car Number Selection:} -labelwidth 22]
    pack $selent -fill x
    $selent bind <Return> [mytypemethod _OK]
    $patent bind <Return> "[mytypemethod _Filter];break"
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {} {
    $type createDialog
    BWidget::focus $patent 1
    wm transient [winfo toplevel $dialog] .
    $type _Filter
    return [Dialog::draw $dialog]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog -1]
  }
  typemethod _OK {} {
    set selectedNumber "[$selent cget -text]"
    set indexes [TheSystem SearchForCarIndexesByNumber "$selectedNumber" 0]
#    puts stderr "*** $type _OK: indexes = $indexes"
    set lb $clistlist
    $lb delete [$lb items]
    foreach Cx $indexes { 
      set car [TheSystem TheCar $Cx]
      set carRR "[Car_Marks $car]"
      set carNumber "[Car_Number $car]"
      set carType "[Car_Type $car]"
      set ct [TheSystem TheCarType "$carType"]
      set carTypeDescr "[CarType_Type $ct]"
      $lb insert end $Cx \
	-text "[format {%-10s %-10s %s} $carRR $carNumber $carTypeDescr]" \
	-data [list $Cx "$carRR" "$carNumber"]
    }
    if {[llength [$lb items]] == 1} {
      set item [lindex [$lb items] 0]
      set result [lindex [$lb itemcget $item -data] 0]
#      puts stderr "*** $type _OK: result = $result"
      Dialog::withdraw $dialog
      return [Dialog::enddialog $dialog "$result"]
    }
  }
  typemethod _Filter {} {
    set pattern "[$patent cget -text]"
    set indexes [TheSystem SearchForCarIndexesByNumber "$pattern" 1]
    set lb $clistlist 
    $lb delete [$lb items]
    foreach Cx $indexes {
      set car [TheSystem TheCar $Cx]
      set carRR "[Car_Marks $car]"
      set carNumber "[Car_Number $car]"
      set carType "[Car_Type $car]"
      set ct [TheSystem TheCarType "$carType"]
      if {![string equal "$ct" NULL]} {
        set carTypeDescr "[CarType_Type $ct]"
      } else {
        set carTypeDescr "unknown"
      }
      $lb insert end $Cx \
	-text "[format {%-10s %-10s %s} $carRR $carNumber $carTypeDescr]" \
	-data [list $Cx "$carRR" "$carNumber"]
    }
  }
  typemethod _SelectFromList { selectedItem } {
    set lb $clistlist
    set elt [$lb itemcget $selectedItem -data]
    set result [lindex $elt 0]
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog "$result"]
  }
  typemethod _BrowseFromList { selectedItem } {
    set lb $clistlist
    set elt [$lb itemcget $selectedItem -data]
    $selent configure -text "[lindex $elt 2]"
  }
}


package provide FCFSearchForCarsDialog 1.0
