#* 
#* ------------------------------------------------------------------
#* FCFTrains.tcl - Train related procedures
#* Created by Robert Heller on Sat Oct 29 13:12:23 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

SplashWorkMessage "Loading Train code" 20

proc CreateTrainDisplay {} {
  
  global Main ImageDir
  image create photo TrainDisplayImage \
		-file [file join $ImageDir traindisplay.gif]
  set theframe [$Main slideout add TrainDisplay]
  set trainLabel [$Main mainframe addindicator -relief sunken -borderwidth 4 \
			-image TrainDisplayImage]
  bind $theframe <Map> [list $trainLabel configure -relief raised]
  bind $theframe <Unmap> [list $trainLabel configure -relief sunken]
  label $theframe.title -relief flat -text {}
  pack $theframe.title -fill x;# -expand yes
  LabelEntry $theframe.currentStop \
	-label {Currently at:} -side left -text {} -editable no
  pack $theframe.currentStop -fill x
  LabelEntry $theframe.length \
	-label {Train Length:} -side left -text {0} -editable no
  pack $theframe.length -fill x
  LabelEntry $theframe.numCars \
	-label {Number of Cars:} -side left -text {0} -editable no
  pack $theframe.numCars -fill x
  LabelEntry $theframe.numTons \
	-label {Train Tons:} -side left -text {0} -editable no
  pack $theframe.numTons -fill x
  LabelEntry $theframe.numLoads \
  	-label {Train Loads:} -side left -text {0} -editable no
  pack $theframe.numLoads -fill x
  LabelEntry $theframe.numEmpties \
  	-label {Train Empties:} -side left -text {0} -editable no
  pack $theframe.numEmpties -fill x
  LabelEntry $theframe.longest \
  	-label {Train Longest:} -side left -text {0} -editable no
  pack $theframe.longest -fill x
  scale $theframe.stopScale \
	-label {Stop:} \
    -takefocus no\
    -orient {horizontal} \
    -showvalue no \
    -from 1 -to 1
  pack $theframe.stopScale -fill x
  bindtags $theframe.stopScale "$theframe.stopScale ROScale . all"
  scale $theframe.lengthScale \
	-label {Current Length:} \
    -takefocus no\
    -orient {horizontal} \
    -showvalue no \
    -from 0 -to 0
  pack $theframe.lengthScale -fill x
  bindtags $theframe.lengthScale "$theframe.lengthScale ROScale . all"
  scale $theframe.carScale \
	-label {Current Number of cars:} \
    -takefocus no\
    -orient {horizontal} \
    -showvalue no \
    -from 0 -to 0
  pack $theframe.carScale -fill x
  bindtags $theframe.carScale "$theframe.carScale ROScale . all"
  Button $theframe.close -text "Close" -underline 0 \
	-command closeTrainDisplay
  pack $theframe.close -expand yes -fill x
  bind $theframe <C> "$theframe.close invoke"
  bind $theframe <c> "$theframe.close invoke"
  update idle
  return [winfo reqwidth $theframe]
}

proc initTrainDisplay {name stationCount maxLength maxCars} {
  global Main
  set theframe [$Main slideout getframe TrainDisplay]
  $theframe.title configure -text "Running status of train $name"
  $theframe.stopScale configure -to $stationCount
  $theframe.lengthScale configure -to $maxLength
  $theframe.carScale configure -to $maxCars
  $Main slideout show TrainDisplay
  update;# idle
}

proc closeTrainDisplay {} {
  global Main
  $Main slideout hide TrainDisplay
}

proc grabTrainDisplay {} {}
proc releaseTrainDisplay {} {}

proc updateTrainDisplay {currentStationName currentStopName trainLength 
			 numberCars trainTons trainLoads trainEmpties 
			 trainLongest currentStop} {
  global Main
  set theframe [$Main slideout getframe TrainDisplay]
  $theframe.currentStop configure -text "$currentStationName $currentStopName"
  $theframe.length      configure -text $trainLength
  $theframe.lengthScale set $trainLength
  $theframe.numCars configure -text $numberCars
  $theframe.carScale set $numberCars
  $theframe.numTons configure -text $trainTons
  $theframe.numLoads configure -text $trainLoads
  $theframe.numEmpties configure -text $trainEmpties
  $theframe.longest configure -text $trainLongest
  $theframe.stopScale set $currentStop
  update idle
}

Tcl8TrainDisplayCallback TrainDisplay initTrainDisplay closeTrainDisplay \
			 grabTrainDisplay releaseTrainDisplay \
			 updateTrainDisplay


package require FCFSelectATrainDialog

proc SelectATrain {{titlestring {}}} {

  if {[string equal "$titlestring" {}]} {
    set title "Select a Train"
  } else {
    set title "Select a Train for $titlestring"
  }

  set train [SelectATrainDialog draw -title "$title"]
#  puts "*** SelectATrain: train = $train"
  return $train
}

proc ShowTrainTotals {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem ShowTrainTotals [Log cget -this] [Banner cget -this]
}

proc ListTrainNames {{Modes {ThisShift}} } {
  global LogWindow
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
#  TheSystem ListTrainNames [Log cget -this] [Banner cget -this]
  set TrainCount 0
  ShowBanner
  $LogWindow insert end "$Modes\n\n"
  foreach Tx [TheSystem TrainIndexList] {
    set train [TheSystem FindTrainByIndex $Tx]
    if {[string equal "$train" {NULL}]} {continue}
    set trainName "[Train_Name $train]"
    if {[string equal "$trainName" {}]} {continue}
#    puts stderr "*** ListTrainNames: Train_Type $train = [Train_Type $train]"
    if {[string equal "[Train_Type $train]" {BoxMove}]} {continue}
    set trainShift [Train_Shift $train]
    if {[lsearch "$Modes" ThisShift] >= 0 && 
	$trainShift != [TheSystem ShiftNumber]} {continue}
    if {[lsearch "$Modes" Locals] >= 0 &&
	![string equal "[Train_Type $train]" {Wayfreight}]} {continue}
    if {[lsearch "$Modes" Manifests] >= 0 &&
	![string equal "[Train_Type $train]" {Manifest}]} {continue}
    incr TrainCount
    set z [expr $TrainCount / 4.0]
    set z [expr $z - int($z)]
    set z [expr $z * 4]
    set buffer $trainName
    while {[string length "$buffer"] < 11} {
      append buffer { }
    }
    append buffer "<$trainShift>"
    while {[string length "$buffer"] < 21} {
      append buffer { }
    }
    $LogWindow insert end "$buffer"
    if {$z == 0} {
      $LogWindow insert end "\n"
    }
  }
  $LogWindow insert end "\nTotal Trains: $TrainCount\n\n"
  $LogWindow see end
}

proc ShowCarMovementsByTrain {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  set train [SelectATrain {Movements}]
#  puts stderr "*** ShowCarMovementsByTrain: train = $train"
  if {[string equal "$train" {NULL}]} {return}
  TheSystem ShowCarMovements 0 NULL $train [Log cget -this] [Banner cget -this]
}

proc ShowTrainCars {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  set train [SelectATrain {Cars}]
  TheSystem ShowTrainCars $train [Log cget -this] [Banner cget -this]
}

proc CreateManageTrainsPrintingMenu {main buttonname} {
  set m [menu $main.${buttonname}_menu -title {Manage Trains/Printing Menu}]
  $main buttons itemconfigure $buttonname -command [list PostMenuOnPointer $m $main]
  $m add command -label {Control Yard Lists} -accelerator Y \
		 -under [string first Y {Control Yard Lists}] \
		 -command ControlYardLists
  $m add command -label {Print All Trains} -accelerator P \
		 -under 0 -command PrintAllTrains
  $m add command -label {Print NO Trains etc.} -accelerator N \
		 -under [string first N {Print NO Trains etc.}] \
		 -command PrintNoTrains
  $m add command -label {Print Dispatcher Report} -accelerator D \
		 -under [string first D {Print Dispatcher Report}] \
		 -command PrintDispatcherReport
  $m add command -label {List Locals This Shift} -accelerator L \
  		 -under 5 -command ListLocalsThisShift
  $m add command -label {List Manifests This Shift} -accelerator M \
  		 -under 5 -command ListManifestsThisShift
  $m add command -label {List All Trains All Shifts} -accelerator ? \
  		 -command ListAllTrainsAllShifts
  bind $m <question> {UnPostMenu %W;ListAllTrainsAllShifts}
  $m add command -label {Manage One Train} -accelerator 1 \
		 -command ManageOneTrain
  bind $m 1 {UnPostMenu %W;ManageOneTrain}
  bind $m <Escape> {UnPostMenu %W;break}
  return $m
}

proc RunAllTrains {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message "Please open a printer first"
    return
  }
  global Main
  set theframe [$Main slideout getframe TrainDisplay]
  $theframe.close configure -state disabled
  TheSystem RunAllTrains [WIP cget -this] [Log cget -this] \
			 [Banner cget -this] [Printer cget -this] \
			 [TrainDisplay cget -this]
  $theframe.close configure -state normal
}

proc RunBoxMoves {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message "Please open a printer first"
    return
  }
  global Main
  set theframe [$Main slideout getframe TrainDisplay]
  $theframe.close configure -state disabled
  TheSystem RunBoxMoves [WIP cget -this] [Log cget -this] \
			[Banner cget -this] [Printer cget -this] \
			[TrainDisplay cget -this]
  $theframe.close configure -state normal
}

proc RunOneTrain {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message "Please open a printer first"
    return
  }
  set train [SelectATrain {Run One Train}]
  if {[string equal "$train" {NULL}]} {return}
  global Main
  set theframe [$Main slideout getframe TrainDisplay]
  $theframe.close configure -state disabled
  TheSystem RunOneTrain $train [string equal [Train_Type $train] {BoxMove}] \
			[TrainDisplay cget -this] [Log cget -this] \
			[Printer cget -this]
			
  $theframe.close configure -state normal
}

package require FCFControlYardListsDialog

proc ControlYardLists {} {

  ControlYardListsDialog draw
}

proc PrintAllTrains {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem SetPrintem 1
  foreach Tx [TheSystem TrainIndexList] {
    set train [TheSystem TrainByIndex $Tx]
    if {[string equal "$train" {NULL}]} {continue}
    Train_SetPrint $train 1
  }  
}

proc PrintNoTrains {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem SetPrintem 0
  foreach Tx [TheSystem TrainIndexList] {
    set train [TheSystem TrainByIndex $Tx]
    if {[string equal "$train" {NULL}]} {continue}
    Train_SetPrint $train 0
  }  
}

proc PrintDispatcherReport {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem SetPrintDispatch 1
}

proc ListLocalsThisShift {} {
  ListTrainNames [list Locals ThisShift]
}

proc ListManifestsThisShift {} {
  ListTrainNames [list Manifests ThisShift]
}

proc ListAllTrainsAllShifts {} {
  ListTrainNames {All}
}

package require FCFManageOneTrainDialog

proc ManageOneTrain {} {
  global TheManageOneTrainDialog

  set train [SelectATrain]
  if {[string equal $train {NULL}]} {return}
  ManageOneTrainDialog draw -train $train
}


package provide FCFTrains 1.0
