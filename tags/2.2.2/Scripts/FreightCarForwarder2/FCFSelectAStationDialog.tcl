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

package require Tk
package require tile
package require Dialog
package require snit
package require HTMLHelp 2.0
package require ScrollWindow
package require ListBox
package require LabelFrames

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
    set dialog [Dialog .selectAStationDialog \
		    -bitmap questhead -default 0 \
		    -cancel 1 -modal local -transient yes -parent . \
		    -side bottom -title [_ "Select A Station"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] \
			-command [list HTMLHelp help {Select A Station Dialog}]
    set frame [$dialog getframe]
    set slist [ScrolledWindow $frame.slist \
			-scrollbar both -auto both]
    pack $slist -expand yes -fill both
    set slistlist [ListBox $slist.list -selectmode single]
    $slist setwidget $slistlist
    $slistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $slistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set selent [LabelEntry $frame.selent \
			-label [_m "Label|Station Name Selection:"]]
    pack $selent -fill x
    $selent bind <Return> [mytypemethod _OK]
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title [from args -title [_ "Select A Station"]]
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
    return [$dialog draw]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog NULL]
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
    $dialog withdraw]
    return [$dialog enddialog "$selectedStation"]
  }
  typemethod _SelectFromList { selectedItem } {
    set lb $slistlist
    set elt [$lb itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval $dialog withdraw]
    return [$dialog enddialog "$result"]
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

