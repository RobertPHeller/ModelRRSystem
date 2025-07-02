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

package require gettext
package require Tk
package require tile

SplashWorkMessage "Loading Train code" 20

snit::widget LabelROScale {
    hulltype ttk::frame
    widgetclass LabelROScale
    option -style LabelROScale
    typeconstructor {
        ttk::style layout $type [ttk::style layout TLabelframe]
        ttk::style layout $type.Label [ttk::style layout TLabelframe.Label]
    }
    component label
    component scale
    delegate option -from to scale
    delegate option -to   to scale
    delegate option -label to label as -text
    delegate option -labelwidth to label as -width
    delegate option -labelimage to label as -image
    delegate option -labelcompound to label as -compound
    delegate option -labelanchor to label as -anchor
    delegate option -labelfont to label as -font
    delegate option -labeljustify to label as -justify
    delegate method set to scale
    constructor {args} {
        install label using ttk::label $win.label
        pack $label -side left
        install scale using ttk::scale $win.scale \
              -takefocus no -orient {horizontal}
        pack $scale -expand yes -fill x
        bindtags $scale [list $scale ROScale . all]
        $self configurelist $args
    }
}


proc CreateTrainDisplay {} {
  
  global Main ImageDir
  image create photo TrainDisplayImage \
		-file [file join $ImageDir traindisplay.gif]
  set theframe [$Main slideout add TrainDisplay]
  set trainLabel [$Main mainframe addindicator -relief sunken -borderwidth 4 \
			-image TrainDisplayImage]
  bind $theframe <Map> [list $trainLabel configure -relief raised]
  bind $theframe <Unmap> [list $trainLabel configure -relief sunken]
  ttk::label $theframe.title -relief flat -text {}
  pack $theframe.title -fill x;# -expand yes
  LabelEntry $theframe.currentStop \
	-label [_m "Label|Currently at:"] -text {} -editable no
  pack $theframe.currentStop -fill x
  LabelEntry $theframe.length \
	-label [_m "Label|Train Length:"]  -text {0} -editable no
  pack $theframe.length -fill x
  LabelEntry $theframe.numCars \
	-label [_m "Label|Number of Cars:"] -text {0} -editable no
  pack $theframe.numCars -fill x
  LabelEntry $theframe.numTons \
	-label [_m "Label|Train Tons:"] -text {0} -editable no
  pack $theframe.numTons -fill x
  LabelEntry $theframe.numLoads \
  	-label [_m "Label|Train Loads:"]  -text {0} -editable no
  pack $theframe.numLoads -fill x
  LabelEntry $theframe.numEmpties \
  	-label [_m "Label|Train Empties:"]  -text {0} -editable no
  pack $theframe.numEmpties -fill x
  LabelEntry $theframe.longest \
  	-label [_m "Label|Train Longest:"]  -text {0} -editable no
  pack $theframe.longest -fill x
  LabelROScale $theframe.stopScale \
	-label [_m "Label|Stop:"] \
        -from 1 -to 1
  pack $theframe.stopScale -fill x
  LabelROScale $theframe.lengthScale \
	-label [_m "Label|Current Length:"] \
        -from 0 -to 0
  pack $theframe.lengthScale -fill x
  LabelROScale $theframe.carScale \
	-label [_m "Label|Current Number of cars:"] \
        -from 0 -to 0
  pack $theframe.carScale -fill x
  ttk::button $theframe.close -text [_m "Button|Close"] \
	-command closeTrainDisplay
  pack $theframe.close -expand yes -fill x
#  bind $theframe <C> "$theframe.close invoke"
#  bind $theframe <c> "$theframe.close invoke"
  update idle
  return [winfo reqwidth $theframe]
}

proc initTrainDisplay {name stationCount maxLength maxCars} {
  global Main
  set theframe [$Main slideout getframe TrainDisplay]
  $theframe.title configure -text [_ "Running status of train %s" $name]
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
    set title [_ "Select a Train"]
  } else {
    set title [_ "Select a Train for %s" $titlestring]
  }

  set train [SelectATrainDialog draw -title "$title"]
#  puts "*** SelectATrain: train = $train"
  return $train
}

proc ShowTrainTotals {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  TheSystem ShowTrainTotals [Log cget -this] [Banner cget -this]
}

proc ListTrainNames {{Modes {ThisShift}} } {
  global LogWindow
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
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
  $LogWindow insert end [_ "\nTotal Trains: %d\n\n" $TrainCount]
  $LogWindow see end
}

proc ShowCarMovementsByTrain {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  set train [SelectATrain {Movements}]
#  puts stderr "*** ShowCarMovementsByTrain: train = $train"
  if {[string equal "$train" {NULL}]} {return}
  TheSystem ShowCarMovements 0 NULL $train [Log cget -this] [Banner cget -this]
}

proc ShowTrainCars {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  set train [SelectATrain {Cars}]
  TheSystem ShowTrainCars $train [Log cget -this] [Banner cget -this]
}

proc CreateManageTrainsPrintingMenu {main buttonname} {
  set m [menu $main.${buttonname}_menu -title [_ "Manage Trains/Printing Menu"]]
  $main buttons itemconfigure $buttonname -command [list PostMenuOnPointer $m $main]
  $m add command -label [_m "Menu|Manage trains/printing|Control Yard Lists"] -accelerator Y \
		 -command ControlYardLists
  $m add command -label [_m "Menu|Manage trains/printing|Print All Trains"] -accelerator P \
		 -command PrintAllTrains
  $m add command -label [_m "Menu|Manage trains/printing|Print NO Trains etc."] -accelerator N \
		 -command PrintNoTrains
  $m add command -label [_m "Menu|Manage trains/printing|Print Dispatcher Report"] -accelerator D \
		 -command PrintDispatcherReport
  $m add command -label [_m "Menu|Manage trains/printing|List Locals This Shift"] -accelerator L \
  		 -command ListLocalsThisShift
  $m add command -label [_m "Menu|Manage trains/printing|List Manifests This Shift"] -accelerator M \
  		 -command ListManifestsThisShift
  $m add command -label [_m "Menu|Manage trains/printing|List All Trains All Shifts"] -accelerator ? \
  		 -command ListAllTrainsAllShifts
  bind $m <question> {UnPostMenu %W;ListAllTrainsAllShifts}
  $m add command -label [_m "Menu|Manage trains/printing|Manage One Train"] -accelerator 1 \
		 -command ManageOneTrain
  bind $m 1 {UnPostMenu %W;ManageOneTrain}
  bind $m <Escape> {UnPostMenu %W;break}
  return $m
}

proc RunAllTrains {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  global Main
  set theframe [$Main slideout getframe TrainDisplay]
  $theframe.close configure -state disabled
  TheSystem RunAllTrains [WIP cget -this] \
			 [Log cget -this] \
			 [Banner cget -this] \
			 [Printer cget -this] \
			 [TrainDisplay cget -this]
  $theframe.close configure -state normal
}

proc RunBoxMoves {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
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
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
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
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
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
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
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
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
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
