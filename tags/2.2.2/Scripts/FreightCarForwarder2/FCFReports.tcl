#* 
#* ------------------------------------------------------------------
#* FCFReports.tcl - Report Menu support
#* Created by Robert Heller on Mon Oct 31 23:12:35 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/10/22 21:10:05  heller
#* Modification History: 10221007
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
#* Modification History: Revision 1.1  2005/11/04 19:06:38  heller
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

package require gettext
package require snit
package require Tk
package require tile
package require FCFSelectAStationDialog
package require Dialog
package require HTMLHelp 2.0
package require LabelFrames

SplashWorkMessage [_ "Loading Report code"] 50

proc CreateReportsMenu {main buttonname} {
  set m [menu $main.${buttonname}_menu -title [_ "Reports available for printing"]]
  $main buttons itemconfigure $buttonname -command [list PostMenuOnPointer $m $main]
  $m add command -label [_m "Menu|Reports Menu|All Industries"] -accelerator I \
		 -command ReportIndustries
  $m add command -label [_m "Menu|Reports Menu|All Trains"] -accelerator T \
		 -command ReportTrains
  $m add command -label [_m "Menu|Reports Menu|All Cars"] -accelerator C \
		 -command ReportCars
  $m add command -label [_m "Menu|Reports Menu|Cars That Did Not Move"] -accelerator M \
		 -command ReportCarsNotMoved
  menu $m.carTypeReports
  $m add cascade -label [_m "Menu|Reports Menu|Car Type Reports"] -accelerator y \
		 -menu $m.carTypeReports
  $m.carTypeReports add command -label [_m "Menu|Reports Menu|Car Type Reports|All"] -accelerator A \
		-command {ReportCarTypes All}
  $m.carTypeReports add command -label [_m "Menu|Reports Menu|Car Type Reports|Type"] -accelerator T \
		-command {ReportCarTypes Type}
  $m.carTypeReports add command -label [_m "Menu|Reports Menu|Car Type Reports|Summary"] -accelerator S \
		-command {ReportCarTypes Summary}
  menu $m.locationReports
  $m add cascade -label [_m "Menu|Reports Menu|Car Location Reports"] -under 4 -accelerator L \
		 -menu $m.locationReports
  $m.locationReports add command -label [_m "Menu|Reports Menu|Car Location Reports|Industry"] -accelerator I \
			-command "ReportCarLocations INDUSTRY"
  $m.locationReports add command -label [_m "Menu|Reports Menu|Car Location Reports|Station"] -accelerator S \
			-command "ReportCarLocations STATION"
  $m.locationReports add command -label [_m "Menu|Reports Menu|Car Location Reports|Division"] -accelerator D \
			-command "ReportCarLocations DIVISION"
  $m.locationReports add command -label [_m "Menu|Reports Menu|Car Location Reports|All"] -accelerator A \
			-command "ReportCarLocations ALL"
  $m add command -label [_m "Menu|Reports Menu|Car Owner Reports"] -accelerator O \
		 -command ReportCarOwners
  $m add command -label [_m "Menu|Reports Menu|Industry Analysis"] -accelerator A \
		 -command ReportAnalysis
  bind $m <Escape> {UnPostMenu %W;break}
  return $m
}

proc ReportIndustries {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  TheSystem ReportIndustries [WIP cget -this] [Log cget -this] \
			     [Printer cget -this]
}

proc ReportTrains {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  TheSystem ReportTrains [WIP cget -this] [Log cget -this] [Printer cget -this]
}

proc ReportCars {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  TheSystem ReportCars [WIP cget -this] [Log cget -this] [Printer cget -this]
}

proc ReportCarsNotMoved {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  TheSystem ReportCarsNotMoved [WIP cget -this] [Log cget -this] \
			       [Printer cget -this]
}
snit::type SelectCarType {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent ctLC

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .selectCarTypeDialog \
		    -bitmap questhead \
		    -default 0 -cancel 1 -modal local -transient yes -parent . \
		    -side bottom -title [_ "Select Car Type"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add cancel -text [_m "Button|Cancel" -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] \
		-command [list HTMLHelp help {Select Car Type}]
    set frame [$dialog getframe]
    set ctLC [LabelComboBox $frame.ctLC -label [_m "Label|Car Type:"] -editable no]
    pack $ctLC  -fill x
    wm transient [winfo toplevel $dialog] .
  }
  typevariable carTypeIndexes
  typevariable carTypeNames
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title [from args -title [_ "Select Car Type"]]
    set carTypeIndexes {}
    set carTypeNames {}
    foreach ct [TheSystem CarTypeList] {
      foreach {index name} $ct {
	lappend carTypeIndexes "$index"
	lappend carTypeNames   "$name"
      }
    }
    $ctLC configure -values $carTypeNames
    $ctLC setvalue first
    wm transient [winfo toplevel $dialog] .
    return [$dialog draw]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog {}]
  }
  typemethod _OK {} {
    set elt "[$ctLC getvalue]"
    set result "[lindex $carTypeIndexes $elt]"
    $dialog withdraw
    return [$dialog enddialog "$result"]
  }
}

proc ReportCarTypes {reportType} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  if {[string equal "$reportType" Type]} {
    set carType [SelectCarType draw]
    if {[string equal "$carType" {}]} {return}
  } else {
    set carType {}
  }
  TheSystem ReportCarTypes $reportType "$carType" [Printer cget -this]
}

proc ReportCarLocations {reportType} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  case $reportType {
    INDUSTRY {
      set industry [SelectAnIndustry "Report Car Locations"]
      if {[string equal $industry {NULL}]} {return}
      set index    [TheSystem FindIndustryIndex $industry]
      if {$index < 0} {return}
    }
    STATION {
      set station [SelectAStation "Report Car Locations"]
      if {[string equal $station {NULL}]} {return}
      set index    [TheSystem FindStationIndex $station]
      if {$index < 0} {return}
    }
    DIVISION {
      set division [SelectADivision "Report Car Locations"]
      if {[string equal $division {NULL}]} {return}
      set index    [TheSystem FindDivisionIndex $division]
      if {$index < 0} {return}
    }
    ALL {set index 0}
  }
  TheSystem ReportCarLocations $reportType $index \
			       [Log cget -this] [Printer cget -this]
}

snit::type EnterOwnerInitialsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent ownerinitials

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .enterOwnerInitialsDialog \
		    -bitmap questhead \
		    -default 0 -cancel 1 -modal local -transient yes -parent . \
		    -side bottom -title [_ "Enter Owner's Initials"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] \
		-command [list HTMLHelp help {Enter Owner Initials Dialog}]
    set frame [$dialog getframe]
    set ownerinitials [LabelEntry $frame.ownerinitials \
		-label [_m "Label|Owner Initials:"]]
    pack $ownerinitials -fill x
    $ownerinitials bind <Return> [mytypemethod _OK]
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {args} {
    $type createDialog
    $dialog configure -title [from args -title [_ "Enter Owner's Initials"]]
    focus -force $ownerinitials
    wm transient [winfo toplevel $dialog] .
    return [$dialog draw]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog {}]
  }
  typemethod _OK {} {
    set result "[$ownerinitials cget -text]"
    $dialog withdraw
    return [$dialog enddialog "$result"]
  }
}

proc EnterOwnerInitials {{title {}}} {

  if {[string equal "$title" {}]} {
    set thetitle [_ "Enter Owner's Initials"]
  } else {
    set thetitle [_ "Enter Owner's Initials for %s" $title]
  }

  return [EnterOwnerInitialsDialog draw -title "$thetitle"]
}



proc ReportCarOwners {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  set ownerInitials [EnterOwnerInitials "Car Owner Report"]
  TheSystem ReportCarOwners $ownerInitials [WIP cget -this] [Log cget -this] \
			       [Printer cget -this]
}

proc ReportAnalysis {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  TheSystem ReportAnalysis [WIP cget -this] [Log cget -this] \
				[Printer cget -this]
}

package provide FCFReports 1.0
