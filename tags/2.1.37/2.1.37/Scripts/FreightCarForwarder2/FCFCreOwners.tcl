#* 
#* ------------------------------------------------------------------
#* FCFCreOwners.tcl - Create owners file
#* Created by Robert Heller on Sat Nov 17 15:00:26 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/11/30 13:56:51  heller
#* Modification History: Novemeber 30, 2007 lockdown.
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
package require Tk
package require tile
package require LabelFrames
package require ScrollWindow
package require ScrollableFrame

namespace eval FCFCreOwners {
  variable OwnersPage
  variable OwnersPageFR
  variable OwnersListFR
  variable OwnersListIndex 0
  variable IsValidated no
  variable Owners 0
  variable OwnersInitialsList {}
}

proc FCFCreOwners::FCFCreOwners {notebook} {
  variable OwnersPage [ttk::frame $notebook.owners]
  $notebook insert end $OwnersPage -text [_m "Tab|Owners File"]
  set OwnersPageSW [ScrolledWindow $OwnersPage.sw \
				-auto vertical -scrollbar vertical]
  pack $OwnersPageSW -expand yes -fill both
  variable OwnersPageFR  [ScrollableFrame $OwnersPageSW.fr \
						-constrainedwidth yes]
  $OwnersPageSW setwidget $OwnersPageFR
  set frame [$OwnersPageFR getframe]

  variable OwnersListFR [frame $frame.ownersListFR]
  pack $OwnersListFR -expand yes -fill both
  variable OwnersListIndex 0
  grid [ttk::label $OwnersListFR.initialsHead -text [_m "Label|Initials"]] \
	-row 0 -column 0 -sticky nw
  grid [ttk::label $OwnersListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [ttk::label $OwnersListFR.nameHead -text [_m "Label|Name"]] \
	-row 0 -column 2 -sticky nws
  grid columnconfigure $OwnersListFR 2 -weight 1
  grid [ttk::label $OwnersListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [ttk::label $OwnersListFR.descrHead -text [_m "Label|Description"]] \
	-row 0 -column 4 -sticky nws
  grid columnconfigure $OwnersListFR 4 -weight 2
  grid [ttk::label $OwnersListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 5 -sticky nw
  pack [ttk::button $frame.addOwner -text [_m "Button|Add Owner"] \
					-command FCFCreOwners::AddOwner] \
	-anchor w
}

proc FCFCreOwners::AddOwner {} {
  variable OwnersListFR
  variable OwnersListIndex
  variable IsValidated 0

  set lastrow [lindex [grid size $OwnersListFR] 1]
  grid [ttk::entry $OwnersListFR.initials$OwnersListIndex -width 3] \
	-row $lastrow -column 0 -sticky nw
  grid [ttk::label $OwnersListFR.commaA$OwnersListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [ttk::entry $OwnersListFR.name$OwnersListIndex] \
	-row $lastrow -column 2 -sticky new
  grid [ttk::label $OwnersListFR.commaB$OwnersListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [ttk::entry $OwnersListFR.descr$OwnersListIndex] \
	-row $lastrow -column 4 -sticky new
  grid [ttk::button $OwnersListFR.delete$OwnersListIndex -text [_m "Button|Delete"] \
			-command "FCFCreOwners::DeleteOwner $OwnersListIndex"] \
	-row $lastrow -column 5 -sticky nw
  incr OwnersListIndex
}

proc FCFCreOwners::DeleteOwner {index} {
  variable OwnersListFR
  variable IsValidated 0

  if {![winfo exists $OwnersListFR.initials$index]} {return}
  foreach f {initials commaA name commaB descr delete} {
    grid forget $OwnersListFR.$f$index
    destroy $OwnersListFR.$f$index
  }
}

proc FCFCreOwners::ResetForm {} {
  variable IsValidated 0
  variable OwnersListIndex

  for {set i 0} {$i < $OwnersListIndex} {incr i} {
    DeleteOwner $i
  }
  set OwnersListIndex 0
}

proc FCFCreOwners::ValidateOwnersFile {} {
  variable IsValidated
  variable OwnersListFR
  variable OwnersListIndex
  variable OwnersInitialsList
  variable Owners

  if {$IsValidated} {return yes}
  set invalid 0
  set OwnersInitialsList {}
  for {set i 0} {$i < $OwnersListIndex} {incr i} {
    if {![winfo exists $OwnersListFR.initials$i]} {continue}
    set initials [string trim "[$OwnersListFR.initials$i cget -text]"]
    if {[string length "$initials"] < 1 || [string length "$initials"] > 3} {
      tk_messageBox -type ok -icon error -message [_ "Invalid initials (%s): too long or too short!" $initials]
      incr invalid
    }
    set initials [string toupper "$initials"]
    if {[lsearch $OwnersInitialsList $initials] >= 0} {
      tk_messageBox -type ok -icon error -message [_ "Duplicate initials (%s)!" $initials]
      incr invalid
    }
    lappend OwnersInitialsList $initials
  }
  set Owners [llength $OwnersInitialsList]
  if {$Owners == 0} {
    tk_messageBox -type ok -icon error -message [_ "No owners!"]
    incr invalid
  }
  set IsValidated [expr {$invalid == 0}]
  return $IsValidated
}

proc FCFCreOwners::ValidOwner {initials} {
  variable IsValidated
  variable OwnersInitialsList

  if {!$IsValidated} {
    if {![FCFCreOwners::ValidateOwnersFile]} {return no}
  }
  if {[lsearch $OwnersInitialsList $initials] < 0} {
    return no
  } else {
    return yes
  }
}

proc FCFCreOwners::WriteOwners {directory filename} {
  variable IsValidated
  variable OwnersListFR
  variable OwnersListIndex
  variable Owners

  if {!$IsValidated} {
    if {![ValidateOwnersFile]} {return}
  }

  if {![file exists "$directory"] || ![file isdirectory "$directory"]} {
    tk_messageBox -type ok -icon error -message [_ "%s does not exist or is not a not a folder!" $directory]
    return false
  }
  set oFileName [file join "$directory" "$filename"]
  if {[catch {open "$oFileName" w} ofp]} {
    tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
    return false
  }
  puts $ofp "$Owners"
  for {set i 0} {$i < $OwnersListIndex} {incr i} {
    if {![winfo exists $OwnersListFR.initials$i]} {continue}
    set initials [string toupper [string trim "[$OwnersListFR.initials$i cget -text]"]]
    set name     [string trim "[$OwnersListFR.name$i cget -text]"]
    set descr    [string trim "[$OwnersListFR.descr$i cget -text]"]
    puts -nonewline $ofp "$initials,"
    puts -nonewline $ofp "\"$name\","
    puts            $ofp "\"$descr\""
  }
  close $ofp
  return true  
}

package provide FCFCreOwners 1.0

