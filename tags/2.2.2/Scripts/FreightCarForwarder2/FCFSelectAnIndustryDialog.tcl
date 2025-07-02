#* 
#* ------------------------------------------------------------------
#* FCFSelectAnIndustryDialog.tcl - Select an Industry Dialog
#* Created by Robert Heller on Sun Feb 19 18:53:59 2006
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

package require Tk
package require tile
package require snit
package require Dialog
package require LabelFrames
package require ScrollWindow
package require ListBox

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
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .selectAnIndustryDialog \
		    -bitmap questhead -default 0 \
		    -cancel 2 -modal local -transient yes -parent . \
		    -side bottom -title [_ "Select An Industry"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add filter -text [_m "Button|Filter"] -command [mytypemethod _Filter]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] \
		    -command [list HTMLHelp::HTMLHelp help {Select An Industry Dialog}]
    set frame [$dialog getframe]
    set lwidth [_mx "Label|Industry Name Pattern:" "Label|Industry Name Selection:"]
    set patent [LabelEntry $frame.patent \
		    -label [_m "Label|Industry Name Pattern:"] \
		    -labelwidth $lwidth -text {*}]
    $patent bind <Return> "[mytypemethod _Filter];break"
    pack $patent -fill x
    set ilist [ScrolledWindow $frame.ilist -scrollbar both -auto both]
    pack $ilist -expand yes -fill both
    set ilistlist [ListBox $ilist.list -selectmode single]
    $ilist setwidget $ilistlist
    $ilistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $ilistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set selent [LabelEntry $frame.selent \
		    -label [_m "Label|Industry Name Selection:"] \
		    -labelwidth $lwidth]
    pack $selent -fill x
    $selent bind <Return> [mytypemethod _OK]
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title [from args -title [_ "Select An Industry"]]
    focus -force $patent
    wm transient [winfo toplevel $dialog] .
    $type _Filter
    return [$dialog draw]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog NULL]
  }
  typemethod _OK {} {
    set selectedIndustryName "[$selent cget -text]"
    set selectedIndustry [::TheSystem FindIndustryByName \
					"$selectedIndustryName"]
    $dialog withdraw
    return [ $dialog enddialog $selectedIndustry]
  }
  typemethod _Filter { } {
    set pattern "[$patent cget -text]"
    if {[regexp {[\*\?\[]} "$pattern"] < 1} {append pattern "*"}
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
    $dialog withdraw
    return [$dialog enddialog $result]
  }
  typemethod _BrowseFromList { selectedItem } {
    set lb $ilistlist
    set elt [$lb itemcget $selectedItem -data]
    $selent configure -text "[lindex $elt 1]"
  }
}


package provide FCFSelectAnIndustryDialog 1.0
