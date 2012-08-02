#* 
#* ------------------------------------------------------------------
#* FCFSelectAStationDialog.tcl - Select a station dialog
#* Created by Robert Heller on Mon Oct 22 15:11:31 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/10/22 21:10:05  heller
#* Modification History: 10221007
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

# SelectAStationDialog

snit::type SelectAStationDialog  {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent slist
  typecomponent slistlist
  typecomponent selent

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .selectAStationDialog \
		    -bitmap questhead -default 0 \
		    -cancel 1 -modal local -transient yes -parent . \
		    -side bottom -title {Select A Station}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help \
			-command [list BWHelp::HelpTopic SelectAStationDialog]
    set frame [Dialog::getframe $dialog]
    set slist [ScrolledWindow::create $frame.slist \
			-scrollbar both -auto both]
    pack $slist -expand yes -fill both
    set slistlist [ListBox::create $slist.list -selectmode single]
    pack $slistlist -expand yes -fill both
    $slist setwidget $slistlist
    $slistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $slistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set selent [LabelEntry::create $frame.selent \
			-label {Station Name Selection:} -labelwidth 22]
    pack $selent -fill x
    $selent bind <Return> [mytypemethod _OK]
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title [from args -title {Select A Station}]
    wm transient [winfo toplevel $dialog] .
    $slistlist delete [$slistlist items]
    foreach Sx [::TheSystem StationIndexList] {
      set station [::TheSystem TheStation $Sx]
      if {[string equal "$station" NULL]} {continue}
      set stationName "[Station_Name $station]"
      set stationComment "[Station_Comment $station]"
      set NC "${stationName}::${stationComment}"
      $slistlist insert end $Sx \
	-text "$NC" -data [list $station "$NC"]
    }
    return [Dialog::draw $dialog]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog NULL]
  }
  typemethod _OK {} {
    set selectedStationNC "[$selent cget -text]"
    if {[regexp {^(.*)::(.*)$} "$selectedStationNC" -> selectedStationName selectedStationComment] < 1} {
      set selectedStationName "$selectedStationNC"
      set selectedStationComment {}
    }
    set selectedStationName [string trim "$selectedStationName"]
    set selectedStationComment [string trim "$selectedStationComment"]
    set selectedStation [::TheSystem FindStationByName "$selectedStationName" "$selectedStationComment"]
    Dialog::withdraw $dialog]
    return [Dialog::enddialog $dialog "$selectedStation"]
  }
  typemethod _SelectFromList { selectedItem } {
    set lb $slistlist
    set elt [$lb itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval Dialog::withdraw $dialog]
    return [Dialog::enddialog $dialog "$result"]
  }
  typemethod _BrowseFromList { selectedItem } {
    set lb $slistlist
    set elt [$lb itemcget $selectedItem -data]
    $selent configure -text "[lindex $elt 1]"
  }
}

proc SelectAStation {title} {
  return [SelectAStationDialog draw -title "$title"]
}

package provide FCFSelectAStationDialog 1.0

