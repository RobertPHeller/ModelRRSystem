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

namespace eval FCFCreTrains {
  variable TrainsPage
  variable TrainsPageFR
  variable TrainsListFR
  variable TrainsListIndex 0
  variable IsValidated no
  variable Trains 0
  variable TrainsIndexList {}
}

proc FCFCreTrains::FCFCreTrains {notebook} {
  variable TrainsPage [$notebook insert end trains \
				-text "Trains File"]
  set TrainsPageSW [ScrolledWindow::create $TrainsPage.sw \
				-auto vertical -scrollbar vertical]
  pack $TrainsPageSW -expand yes -fill both
  variable TrainsPageFR  [ScrollableFrame::create $TrainsPageSW.fr \
						-constrainedwidth yes]
  pack $TrainsPageFR -expand yes -fill both
  $TrainsPageSW setwidget $TrainsPageFR
  set frame [$TrainsPageFR getframe]

  variable TrainsListFR [frame $frame.trainsListFR]
  pack $TrainsListFR -expand yes -fill both
  variable TrainsListIndex 0
  grid [Label::create $TrainsListFR.numberHead -text {#}] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $TrainsListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $TrainsListFR.typeHead -text {TYPE}] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $TrainsListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $TrainsListFR.shiftHead -text {SHIFT}] \
	-row 0 -column 4 -sticky nw
  grid [Label::create $TrainsListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [Label::create $TrainsListFR.doneHead -text {DONE}] \
	-row 0 -column 6 -sticky nw
  grid [Label::create $TrainsListFR.commaDHead -text {,}] \
	-row 0 -column 7 -sticky nw
  grid [Label::create $TrainsListFR.nameHead -text {NAME}] \
	-row 0 -column 8 -sticky nw
  grid [Label::create $TrainsListFR.commaEHead -text {,}] \
	-row 0 -column 9 -sticky nw
  grid [Label::create $TrainsListFR.maxcarsHead -text {MAXCARS}] \
	-row 0 -column 10 -sticky nw
  grid [Label::create $TrainsListFR.commaFHead -text {,}] \
	-row 0 -column 11 -sticky nw
  grid [Label::create $TrainsListFR.divisionsHead -text {DIVISIONS}] \
	-row 0 -column 12 -sticky nw
  grid [Label::create $TrainsListFR.commaGHead -text {,}] \
	-row 0 -column 13 -sticky nw
  grid [Label::create $TrainsListFR.stopsHead -text {STOPS}] \
	-row 0 -column 14 -sticky nws
  grid columnconfigure $TrainsListFR 14 -weight 1

  grid [Label::create $TrainsListFR.padHead -text {PAD}] \
	-row 1 -column 2 -sticky nw
  grid [Label::create $TrainsListFR.commaIHead -text {,}] \
	-row 1 -column 3 -sticky nw
  grid [Label::create $TrainsListFR.ondutyHead -text {ONDUTY}] \
	-row 1 -column 4 -sticky nw
  grid [Label::create $TrainsListFR.commaJHead -text {,}] \
	-row 1 -column 5 -sticky nw
  grid [Label::create $TrainsListFR.printHead -text {PRINT}] \
	-row 1 -column 6 -sticky nw
  grid [Label::create $TrainsListFR.commaKHead -text {,}] \
	-row 1 -column 7 -sticky nw
  grid [Label::create $TrainsListFR.mxclearHead -text {MXCLEAR}] \
	-row 1 -column 8 -sticky nw
  grid [Label::create $TrainsListFR.commaLHead -text {,}] \
	-row 1 -column 9 -sticky nw
  grid [Label::create $TrainsListFR.mxweighHead -text {MXWEIGHT}] \
	-row 1 -column 10 -sticky nw
  grid [Label::create $TrainsListFR.commaMHead -text {,}] \
	-row 1 -column 11 -sticky nw
  grid [Label::create $TrainsListFR.typesHead -text {TYPES}] \
	-row 1 -column 12 -sticky nws -columnspan 3

  grid [Label::create $TrainsListFR.mxlenHead -text {MXLEN}] \
	-row 2 -column 2 -sticky nw
  grid [Label::create $TrainsListFR.commaOHead -text {,}] \
	-row 2 -column 3 -sticky nw
  grid [Label::create $TrainsListFR.descHead -text {DESC}] \
	-row 2 -column 4 -sticky nws -columnspan 11
  grid [Label::create $TrainsListFR.deleteHead -text {Delete?}] \
	-row 2 -column 15 -sticky nw

  pack [Button::create $frame.addTrain \
			-text "Add Train" \
			-command FCFCreTrains::AddTrain] \
	-anchor w
}

proc FCFCreTrains::AddTrain {} {
  variable TrainsListFR
  variable TrainsListIndex 0
  variable IsValidated no

  set lastrow [lindex [grid size $TrainsListFR] 1]

  grid [SpinBox::create $TrainsListFR.number$TrainsListIndex \
				-range {1 1000 1} -width 4] \
	-row $lastrow -column 0 -sticky nw
  grid [Label::create $TrainsListFR.commaA$TrainsListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [ComboBox::create $TrainsListFR.type$TrainsListIndex -values {M W B} \
						-editable no -width 2] \
	-row $lastrow -column 2 -sticky nw
  $TrainsListFR.type$TrainsListIndex setvalue first
  grid [Label::create $TrainsListFR.commaB$TrainsListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [ComboBox::create $TrainsListFR.shift$TrainsListIndex -values {1 2 3 0} \
						-editable no -width 2] \
	-row $lastrow -column 4 -sticky nw
  $TrainsListFR.shift$TrainsListIndex setvalue first
  grid [Label::create $TrainsListFR.commaC$TrainsListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [ComboBox::create $TrainsListFR.done$TrainsListIndex -values {N Y} \
						-editable no -width 1] \
	-row $lastrow -column 6 -sticky nw
  $TrainsListFR.done$TrainsListIndex setvalue first
  grid [Label::create $TrainsListFR.commaD$TrainsListIndex -text {,}] \
	-row $lastrow -column 7 -sticky nw
  grid [Entry::create $TrainsListFR.name$TrainsListIndex -width 6] \
	-row $lastrow -column 8 -sticky nw
  grid [Label::create $TrainsListFR.commaE$TrainsListIndex -text {,}] \
	-row $lastrow -column 9 -sticky nw
  grid [SpinBox::create $TrainsListFR.maxcars$TrainsListIndex \
				-range {1 999 1} -width 3] \
	-row $lastrow -column 10 -sticky nw
  grid [Label::create $TrainsListFR.commaF$TrainsListIndex -text {,}] \
	-row $lastrow -column 11 -sticky nw
  grid [Entry::create $TrainsListFR.divisions$TrainsListIndex -width 9] \
	-row $lastrow -column 12 -sticky nw
  grid [Label::create $TrainsListFR.commaG$TrainsListIndex -text {,}] \
	-row $lastrow -column 13 -sticky nw
  grid [Entry::create $TrainsListFR.stops$TrainsListIndex -text {}] \
	-row $lastrow -column 14 -sticky new

  grid [Label::create $TrainsListFR.pad$TrainsListIndex -text {0}] \
	-row [expr {$lastrow + 1}] -column 2 -sticky nw
  grid [Label::create $TrainsListFR.commaI$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 3 -sticky nw
  grid [Entry::create $TrainsListFR.onduty$TrainsListIndex -width 4] \
	-row [expr {$lastrow + 1}] -column 4 -sticky nw
  grid [Label::create $TrainsListFR.commaJ$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 5 -sticky nw
  grid [ComboBox::create $TrainsListFR.print$TrainsListIndex -values {N P} \
							-width 1] \
	-row [expr {$lastrow + 1}] -column 6 -sticky nw
  $TrainsListFR.print$TrainsListIndex setvalue first
  grid [Label::create $TrainsListFR.commaK$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 7 -sticky nw
  grid [SpinBox::create $TrainsListFR.mxclear$TrainsListIndex -range {1 9 1} \
						-width 1] \
	-row [expr {$lastrow + 1}] -column 8 -sticky nw
  grid [Label::create $TrainsListFR.commaL$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 9 -sticky nw
  grid [SpinBox::create $TrainsListFR.mxweigh$TrainsListIndex -range {1 9 1} \
						-width 1] \
	-row [expr {$lastrow + 1}] -column 10 -sticky nw
  grid [Label::create $TrainsListFR.commaM$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 1}] -column 11 -sticky nw
  grid [Entry::create $TrainsListFR.types$TrainsListIndex -width 9] \
	-row [expr {$lastrow + 1}] -column 12 -sticky new -columnspan 3

  grid [SpinBox::create $TrainsListFR.mxlen$TrainsListIndex \
						-range {40 4000 40} -width 4] \
	-row [expr {$lastrow + 2}] -column 2 -sticky nw
  grid [Label::create $TrainsListFR.commaO$TrainsListIndex -text {,}] \
	-row [expr {$lastrow + 2}] -column 3 -sticky nw
  grid [Entry::create $TrainsListFR.desc$TrainsListIndex] \
	-row [expr {$lastrow + 2}] -column 4 -sticky new -columnspan 11
  grid [Button::create $TrainsListFR.delete$TrainsListIndex -text {Delete} \
			-command "FCFCreTrains::DeleteTrain $TrainsListIndex"] \
	-row [expr {$lastrow + 2}] -column 15 -sticky nw


}

proc FCFCreTrains::DeleteTrain {index} {
  variable TrainsListFR
  variable IsValidated no

  if {![winfo exists $TrainsListFR.number$index]} {return}
  foreach f {number commaA type commaB shift commaC done commaD name commaE 
	     maxcars commaF divisions commaG stops pad commaI onduty commaJ 
	     print commaK mxclear commaL mxweigh commaM types commaN mxlen 
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
      tk_messageBox -type ok -icon error -message "Invalid index ($trn < 1) for train $nam!"
      incr invalid
    }
    if {[lsearch $TrainIndexList $trn] >= 0} {
      tk_messageBox -type ok -icon error -message "Duplicate index ($trn) for Train $nam!"
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
	tk_messageBox -type ok -icon error -message "Invalid Division Symbol ($ds) for Train $nam ($trn)!"
        incr invalid
      }
    }
    switch $typ {
      M {
	foreach stop [split "$stp" { }] {
	  if {![FCFCreIndustries::ValidIndustry $stop]} {
	    tk_messageBox -type ok -icon error -message "Invalid station stop ($stop) for train $nam ($trn)!"
	    incr invalid
	  }
	}
      }
      W -
      B {
	foreach stop [split "$stp" { }] {
	  if {![FCFCreSystem::ValidStation $stop]} {
	    tk_messageBox -type ok -icon error -message "Invalid industry stop ($stop) for train $nam ($trn)!"
	    incr invalid
	  }
	}
      }
    }
    if {[regexp {^([012][0-9])([0-5][0-9])$} "$odt" -> hr min] < 1} {
      tk_messageBox -type ok -icon error -message "Format error for On Duty time ($odt) for train $nam ($trn)!"
      incr invalid
    } else {
      scan "$hr" "%02d" h
      scan "$min" "%02d" m
      if {$h > 23 || $m > 59} {
	tk_messageBox -type ok -icon error -message "Invalid time for On Duty time ($odt) for train $nam ($trn)!"
	incr invalid
      }
    }
    foreach ct [split "$cts" {}] {
      if {![FCFCreCars::ValidCarType "$ct"]} {
	tk_messageBox -type ok -icon error -message "Invalid car type ($ct) for train $nam ($trn)!"
	incr invalid
      }
    }
  }
  set TrainIndexList [lsort -integer $TrainIndexList]
  if {[llength $TrainIndexList] == 0} {
    tk_messageBox -type ok -icon error -message "No Trains!"
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
    tk_messageBox -type ok -icon error -message "$directory does not exist or is not a not a folder!"
    return false
  }
  set oFileName [file join "$directory" "$filename"]
  if {[catch {open "$oFileName" w} ofp]} {
    tk_messageBox -type ok -icon error -message "Could not open \"$oFileName\": $ofp"
    return false
  }
  puts $ofp "Trains = $Trains"
  for {set T 0} {$T < $TrainsListIndex} {incr T} {
    if {![winfo exists ${TrainsListFR}.number$T]} {continue}
    puts -nonewline $ofp "[${TrainsListFR}.number$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.type$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.shift$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.done$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.name$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.maxcars$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.divisions$T -cget text],"
    puts            $ofp "[${TrainsListFR}.stops$T -cget text]"
    puts -nonewline $ofp {        }
    puts -nonewline $ofp "[${TrainsListFR}.pad$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.onduty$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.print$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.mxclear$T -cget text],"
    puts -nonewline $ofp "[${TrainsListFR}.mxweigh$T -cget text],"
    puts            $ofp "[${TrainsListFR}.types$T -cget text]"
    puts -nonewline $ofp {        }
    puts -nonewline $ofp "[${TrainsListFR}.mxlen$T -cget text],"
    puts            $ofp "\"[${TrainsListFR}.desc$T -cget text]\""
    puts            $ofp
  }
  puts $ofp "-1"
  close $ofp
  return true
}


package provide FCFCreTrains 1.0
