#* 
#* ------------------------------------------------------------------
#* FCFCreTrains.tcl - Create the trains.dat file
#* Created by Robert Heller on Sat Nov 17 14:56:00 2007
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

namespace eval FCFCreTrains {
  variable TrainsPage
  variable TrainsPageFR
  variable TrainsListFR
  variable TrainsListIndex 0
  variable IsValidated no
  variable Trains 0
  variable TrainIndexList {}
}

proc FCFCreTrains::FCFCreTrains {notebook} {
  variable TrainsPage [ttk::frame $notebook.trains]
  $notebook insert end $TrainsPage \
				-text [_m "Tab|Trains File"]
  set TrainsPageSW [ScrolledWindow $TrainsPage.sw \
				-auto vertical -scrollbar vertical]
  pack $TrainsPageSW -expand yes -fill both
  variable TrainsPageFR  [ScrollableFrame $TrainsPageSW.fr \
						-constrainedwidth yes]
  $TrainsPageSW setwidget $TrainsPageFR
  set frame [$TrainsPageFR getframe]

  variable TrainsListFR [frame $frame.trainsListFR]
  pack $TrainsListFR -expand yes -fill both
  variable TrainsListIndex
  grid [ttk::label $TrainsListFR.numberHead -text {#}] \
	-row 0 -column 0 -sticky nw
  grid [ttk::label $TrainsListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [ttk::label $TrainsListFR.typeHead -text [_m "Label|TYPE"]] \
	-row 0 -column 2 -sticky nw
  grid [ttk::label $TrainsListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [ttk::label $TrainsListFR.shiftHead -text [_m "Label|SHIFT"]] \
	-row 0 -column 4 -sticky nw
  grid [ttk::label $TrainsListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [ttk::label $TrainsListFR.doneHead -text [_m "Label|DONE"]] \
	-row 0 -column 6 -sticky nw
  grid [ttk::label $TrainsListFR.commaDHead -text {,}] \
	-row 0 -column 7 -sticky nw
  grid [ttk::label $TrainsListFR.nameHead -text [_m "Label|NAME"]] \
	-row 0 -column 8 -sticky nw
  grid [ttk::label $TrainsListFR.commaEHead -text {,}] \
	-row 0 -column 9 -sticky nw
  grid [ttk::label $TrainsListFR.maxcarsHead -text [_m "Label|MAXCARS"]] \
	-row 0 -column 10 -sticky nw
  grid [ttk::label $TrainsListFR.commaFHead -text {,}] \
	-row 0 -column 11 -sticky nw
  grid [ttk::label $TrainsListFR.divisionsHead -text [_m "Label|DIVISIONS"]] \
	-row 0 -column 12 -sticky nw
  grid [ttk::label $TrainsListFR.commaGHead -text {,}] \
	-row 0 -column 13 -sticky nw
  grid [ttk::label $TrainsListFR.stopsHead -text [_m "Label|STOPS"]] \
	-row 0 -column 14 -sticky nws
  grid columnconfigure $TrainsListFR 14 -weight 1

  grid [ttk::label $TrainsListFR.padHead -text [_m "Label|PAD"]] \
	-row 1 -column 2 -sticky nw
  grid [ttk::label $TrainsListFR.commaIHead -text {,}] \
	-row 1 -column 3 -sticky nw
  grid [ttk::label $TrainsListFR.ondutyHead -text [_m "Label|ONDUTY"]] \
	-row 1 -column 4 -sticky nw
  grid [ttk::label $TrainsListFR.commaJHead -text {,}] \
	-row 1 -column 5 -sticky nw
  grid [ttk::label $TrainsListFR.printHead -text [_m "Label|PRINT"]] \
	-row 1 -column 6 -sticky nw
  grid [ttk::label $TrainsListFR.commaKHead -text {,}] \
	-row 1 -column 7 -sticky nw
  grid [ttk::label $TrainsListFR.mxclearHead -text [_m "Label|MXCLEAR"]] \
	-row 1 -column 8 -sticky nw
  grid [ttk::label $TrainsListFR.commaLHead -text {,}] \
	-row 1 -column 9 -sticky nw
  grid [ttk::label $TrainsListFR.mxweighHead -text [_m "Label|MXWEIGHT"]] \
	-row 1 -column 10 -sticky nw
  grid [ttk::label $TrainsListFR.commaMHead -text {,}] \
	-row 1 -column 11 -sticky nw
  grid [ttk::label $TrainsListFR.typesHead -text [_m "Label|TYPES"]] \
	-row 1 -column 12 -sticky nws -columnspan 3

  grid [ttk::label $TrainsListFR.mxlenHead -text [_m "Label|MXLEN"]] \
	-row 2 -column 2 -sticky nw
  grid [ttk::label $TrainsListFR.commaOHead -text {,}] \
	-row 2 -column 3 -sticky nw
  grid [ttk::label $TrainsListFR.descHead -text [_m "Label|DESC"]] \
	-row 2 -column 4 -sticky nws -columnspan 11
  grid [ttk::label $TrainsListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 2 -column 15 -sticky nw

  pack [ttk::button $frame.addTrain \
			-text [_m "Button|Add Train"] \
			-command FCFCreTrains::AddTrain] \
	-anchor w
}

proc FCFCreTrains::AddTrain {} {
  variable TrainsListFR
  variable TrainsListIndex
  variable IsValidated

  set lastrow [lindex [grid size $TrainsListFR] 1]

  grid [spinbox $TrainsListFR.number$TrainsListIndex \
				-from 1 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 0 -sticky nw
  grid [ttk::label $TrainsListFR.commaA$TrainsListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [ttk::combobox $TrainsListFR.type$TrainsListIndex -values {M W B} \
						-state readonly -width 2] \
	-row $lastrow -column 2 -sticky nw
  $TrainsListFR.type$TrainsListIndex set [lindex [$TrainsListFR.type$TrainsListIndex cget -values] 0]
  grid [ttk::label $TrainsListFR.commaB$TrainsListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [ttk::combobox $TrainsListFR.shift$TrainsListIndex -values {1 2 3 0} \
						-state readonly -width 2] \
	-row $lastrow -column 4 -sticky nw
  $TrainsListFR.shift$TrainsListIndex set [lindex [$TrainsListFR.shift$TrainsListIndex cget -values] 0]
  grid [ttk::label $TrainsListFR.commaC$TrainsListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [ttk::combobox $TrainsListFR.done$TrainsListIndex -values {N Y} \
						-state readonly -width 1] \
	-row $lastrow -column 6 -sticky nw
  $TrainsListFR.done$TrainsListIndex set [lindex [$TrainsListFR.done$TrainsListIndex cget -values] 0]
  grid [ttk::label $TrainsListFR.commaD$TrainsListIndex -text {,}] \
	-row $lastrow -column 7 -sticky nw
  grid [ttk::entry $TrainsListFR.name$TrainsListIndex -width 6] \
	-row $lastrow -column 8 -sticky nw
  grid [ttk::label $TrainsListFR.commaE$TrainsListIndex -text {,}] \
	-row $lastrow -column 9 -sticky nw
  grid [spinbox $TrainsListFR.maxcars$TrainsListIndex \
				-from 1 -to 999 -increment 1 -width 3] \
	-row $lastrow -column 10 -sticky nw
  grid [ttk::label $TrainsListFR.commaF$TrainsListIndex -text {,}] \
	-row $lastrow -column 11 -sticky nw
  grid [ttk::entry $TrainsListFR.divisions$TrainsListIndex -width 9] \
	-row $lastrow -column 12 -sticky nw
  grid [ttk::label $TrainsListFR.commaG$TrainsListIndex -text {,}] \
	-row $lastrow -column 13 -sticky nw
  grid [ttk::entry $TrainsListFR.stops$TrainsListIndex -text {}] \
	-row $lastrow -column 14 -sticky new

  grid [ttk::label $TrainsListFR.pad$TrainsListIndex -text {0}] \
	-row [expr {$lastrow + 1}] -column 2 -sticky nw
  grid [ttk::label $TrainsListFR.commaI$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 3 -sticky nw
  grid [ttk::entry $TrainsListFR.onduty$TrainsListIndex -width 4] \
	-row [expr {$lastrow + 1}] -column 4 -sticky nw
  grid [ttk::label $TrainsListFR.commaJ$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 5 -sticky nw
  grid [ttk::combobox $TrainsListFR.print$TrainsListIndex -values {N P} \
							-width 1] \
	-row [expr {$lastrow + 1}] -column 6 -sticky nw
  $TrainsListFR.print$TrainsListIndex set [lindex [$TrainsListFR.print$TrainsListIndex cget -values] 0]
  grid [ttk::label $TrainsListFR.commaK$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 7 -sticky nw
  grid [spinbox $TrainsListFR.mxclear$TrainsListIndex -from 1 -to 9 \
        -increment 1 -width 1] \
	-row [expr {$lastrow + 1}] -column 8 -sticky nw
  grid [ttk::label $TrainsListFR.commaL$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 9 -sticky nw
  grid [spinbox $TrainsListFR.mxweigh$TrainsListIndex -from 1 -to 9 -increment 1 \
						-width 1] \
	-row [expr {$lastrow + 1}] -column 10 -sticky nw
  grid [ttk::label $TrainsListFR.commaM$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 11 -sticky nw
  grid [ttk::entry $TrainsListFR.types$TrainsListIndex -width 9] \
	-row [expr {$lastrow + 1}] -column 12 -sticky new -columnspan 3

  grid [spinbox $TrainsListFR.mxlen$TrainsListIndex \
						-from 40 -to 4000 -increment 40 -width 4] \
	-row [expr {$lastrow + 2}] -column 2 -sticky nw
  grid [ttk::label $TrainsListFR.commaO$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 2}] -column 3 -sticky nw
  grid [ttk::entry $TrainsListFR.desc$TrainsListIndex] \
	-row [expr {$lastrow + 2}] -column 4 -sticky new -columnspan 11
  grid [ttk::button $TrainsListFR.delete$TrainsListIndex -text [_m "Button|Delete"] \
			-command "FCFCreTrains::DeleteTrain $TrainsListIndex"] \
	-row [expr {$lastrow + 2}] -column 15 -sticky nw

  incr TrainsListIndex
}

proc FCFCreTrains::DeleteTrain {index} {
  variable TrainsListFR
  variable IsValidated no

  if {![winfo exists $TrainsListFR.number$index]} {return}
  foreach f {number commaA type commaB shift commaC done commaD name commaE 
	     maxcars commaF divisions commaG stops pad commaI onduty commaJ 
	     print commaK mxclear commaL mxweigh commaM types mxlen 
	     commaO desc delete} {
    grid forget $TrainsListFR.$f$index
    destroy $TrainsListFR.$f$index
  }
}

proc FCFCreTrains::ResetForm {} {
  variable TrainsListIndex

  for {set T 0} {$T < $TrainsListIndex} {incr T} {
    DeleteTrain $T
  }
  set TrainsListIndex 0
}

proc FCFCreTrains::ValidateTrainsFile {} {
  variable TrainsListFR
  variable TrainsListIndex
  variable Trains
  variable IsValidated
  variable TrainIndexList

  if {$IsValidated} {return yes}
  set invalid 0

  for {set T 0} {$T < $TrainsListIndex} {incr T} {
    if {![winfo exists ${TrainsListFR}.number$T]} {continue}
    set trn [${TrainsListFR}.number$T cget -text]
    set typ [${TrainsListFR}.type$T cget -text]
    set nam "[${TrainsListFR}.name$T cget -text]"
    set div "[${TrainsListFR}.divisions$T cget -text]"
    set stp "[${TrainsListFR}.stops$T cget -text]"
    set odt "[${TrainsListFR}.onduty$T cget -text]"
    set cts "[${TrainsListFR}.types$T cget -text]"
    if {$trn < 1} {
      tk_messageBox -type ok -icon error -message [_ "Invalid index (%d < 1) for train %s!" $trn $nam]
      incr invalid
    }
    if {[lsearch $TrainIndexList $trn] >= 0} {
      tk_messageBox -type ok -icon error -message [_ "Duplicate index (%d) for Train %s!" $trn $nam]
      incr invalid
    }
    lappend TrainIndexList $trn
    if {[string equal "$div" {*}]} {
      set div {};# Wild card is OK
    } elseif {[string length "$div"] > 1 && [string equal [string range "$div" 0 1] {-}]} {
      set div [string range "$div" 1 end];# peel off - (NOT) sign
    }
    foreach ds [split "$div" {}] {
      if {![FCFCreSystem::ValidDivisionSymbol $ds]} {
	tk_messageBox -type ok -icon error -message [_ "Invalid Division Symbol (%s) for Train %s (%d)!" $ds $nam $trn]
        incr invalid
      }
    }
    switch $typ {
      M {
	foreach stop [split "$stp" { }] {
	  if {![FCFCreIndustries::ValidIndustry $stop]} {
	    tk_messageBox -type ok -icon error -message [_ "Invalid station stop (%d) for train %s (%d)!" $stop $nam $trn]
	    incr invalid
	  }
	}
      }
      W -
      B {
	foreach stop [split "$stp" { }] {
	  if {![FCFCreSystem::ValidStation $stop]} {
	    tk_messageBox -type ok -icon error -message [_ "Invalid industry stop (%d) for train %s (%d)!" $stop $nam $trn]
	    incr invalid
	  }
	}
      }
    }
    if {[regexp {^([012][0-9])([0-5][0-9])$} "$odt" -> hr min] < 1} {
      tk_messageBox -type ok -icon error -message [_ "Format error for On Duty time (%s) for train %s (%d)!" $odt $nam $trn]
      incr invalid
    } else {
      scan "$hr" "%02d" h
      scan "$min" "%02d" m
      if {$h > 23 || $m > 59} {
	tk_messageBox -type ok -icon error -message [_ "Invalid time for On Duty time (%s) for train %s (%d)!" $odt $nam $trn]
	incr invalid
      }
    }
    foreach ct [split "$cts" {}] {
      if {![FCFCreCars::ValidCarType "$ct"]} {
	tk_messageBox -type ok -icon error -message [_ "Invalid car type (%s) for train %s (%d)!" $ct $nam $trn]
	incr invalid
      }
    }
  }
  set TrainIndexList [lsort -integer $TrainIndexList]
  if {[llength $TrainIndexList] == 0} {
    tk_messageBox -type ok -icon error -message [_ "No Trains!"]
    set IsValidated no
    return false
  }
  set lastTrn [lindex $TrainIndexList end]
  set Trains [::RoundUp $lastTrn 10]
  if {$Trains == $lastTrn} {incr Trains 10}
  set IsValidated [expr {$invalid == 0}]
  return $IsValidated
}

proc FCFCreTrains::ValidTrain {trn} {
  variable TrainIndexList
  variable IsValidated

  if {!$IsValidated} {
    if {![ValidateTrainFile]} {return no}
  }
  if {[lsearch $TrainIndexList $trn] < 0} {
    return no
  } else {
    return yes
  }
}

proc FCFCreTrains::WriteTrains {directory filename} {
  variable TrainsListFR
  variable TrainsListIndex
  variable Trains
  variable IsValidated

  if {!$IsValidated} {
    if {![ValidateTrainsFile]} {return false}
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
  puts $ofp "Trains = $Trains"
  for {set T 0} {$T < $TrainsListIndex} {incr T} {
    if {![winfo exists ${TrainsListFR}.number$T]} {continue}
    puts -nonewline $ofp "[${TrainsListFR}.number$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.type$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.shift$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.done$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.name$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.maxcars$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.divisions$T cget -text],"
    puts            $ofp "[${TrainsListFR}.stops$T cget -text]"
    puts -nonewline $ofp {        }
    puts -nonewline $ofp "[${TrainsListFR}.pad$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.onduty$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.print$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.mxclear$T cget -text],"
    puts -nonewline $ofp "[${TrainsListFR}.mxweigh$T cget -text],"
    puts            $ofp "[${TrainsListFR}.types$T cget -text]"
    puts -nonewline $ofp {        }
    puts -nonewline $ofp "[${TrainsListFR}.mxlen$T cget -text],"
    puts            $ofp "\"[${TrainsListFR}.desc$T cget -text]\""
    puts            $ofp
  }
  puts $ofp "-1"
  close $ofp
  return true
}


package provide FCFCreTrains 1.0
