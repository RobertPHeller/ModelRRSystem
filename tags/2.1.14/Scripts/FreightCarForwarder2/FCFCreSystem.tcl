#* 
#* ------------------------------------------------------------------
#* FCFCreSystem.tcl - Create System file
#* Created by Robert Heller on Thu Nov 15 15:28:48 2007
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

package require BWidget
package require BWLabelSpinBox

namespace eval FCFCreSystem {
  variable SystemPage
  variable SystemPageFR
  variable SystemNameLE
  variable CTFile stock
  variable CTDirectories {}
  variable CTStockDirectoryCB
  variable DivisionsListFR
  variable DivisionsListIndex 0
  variable StationsListFR
  variable StationsListIndex 0
  variable Divisions 0
  variable Stations 0
  variable IsValidated no
  variable DivisionIndexList {}
  variable DivisionSymbolList {}
  variable StationIndexList {}
  variable TheNoteBook
  variable StockDataDir [file join [file dirname [file dirname \
							   [file dirname \
							     [info script]]]] \
						    Data]
}

proc FCFCreSystem::FCFCreSystem {notebook} {
  variable StockDataDir
  variable TheNoteBook $notebook
  variable SystemPage [$notebook insert end system -text "System File"]
  set SystemPageSW [ScrolledWindow::create $SystemPage.sw -auto vertical \
							-scrollbar vertical]
  pack $SystemPageSW -expand yes -fill both
  variable SystemPageFR [ScrollableFrame::create $SystemPageSW.fr \
							-constrainedwidth yes]
  pack $SystemPageFR -expand yes -fill both
  $SystemPageSW setwidget $SystemPageFR
  set frame [$SystemPageFR getframe]
  
  variable SystemNameLE [LabelEntry::create $frame.systemNameLE \
				-label "System Name:" -side top]
  pack $SystemNameLE -fill x
  set filesLF [LabelFrame::create $frame.filesTF -text "Files:" -side top]
  pack $filesLF -fill x

  set filesLFfr [$filesLF getframe]
  set industriesLF [LabelFrame::create $filesLFfr.industriesLF \
						-text "indus.dat" -side left]
  pack $industriesLF -fill x
  pack [Button::create [$industriesLF getframe].button \
	-text "Create Industries" -command "$notebook raise industries"] \
	-fill x
  set trainsLF [LabelFrame::create $filesLFfr.trainsLF -text "trains.dat" \
						-side left]
  pack $trainsLF -fill x
  pack [Button::create [$trainsLF getframe].button \
	-text "Create Trains" -command "$notebook raise trains"] \
	-fill x
  set ordersLF [LabelFrame::create $filesLFfr.ordersLF -text "orders.dat" \
						-side left]
  pack $ordersLF -fill x
  pack [Button::create [$ordersLF getframe].button \
	-text "Create Orders" -command "$notebook raise orders"] \
	-fill x
  set ownersLF [LabelFrame::create $filesLFfr.ownersLF -text "owners.dat" \
							-side left]
  pack $ownersLF -fill x -expand yes
  pack [Button::create [$ownersLF getframe].button \
	-text "Create Owners" -command "$notebook raise owners"] \
	-fill x
  set cartypesLF [LabelFrame::create $filesLFfr.cartypesLF \
					-text "cartypes.dat" -side left]
  pack $cartypesLF -fill x
  set ctFrame [$cartypesLF getframe]
  variable CTFile stock
  variable CTDirectories [glob  -types d -directory $StockDataDir -tails *]
  grid [radiobutton $ctFrame.stockRB -text Stock -value stock \
				   -variable FCFCreSystem::CTFile \
				   -command FCFCreSystem::ToggleCT] \
	-row 0 -column 0 -sticky nw
  grid [radiobutton $ctFrame.customRB -text Custom -value custom \
				   -variable FCFCreSystem::CTFile \
				   -command FCFCreSystem::ToggleCT] \
	-row 1 -column 0 -sticky nw
  variable CTStockDirectoryCB [ComboBox::create $ctFrame.ctStockDirectoryCB \
				-values $CTDirectories -editable no]
  $CTStockDirectoryCB setvalue first
  grid $CTStockDirectoryCB -row 0 -column 1 -sticky new
  variable CtCreateCustom [Button::create $ctFrame.ctCreateCustom \
					-text "Create CarTypes" \
					-command "$notebook raise cartypes" \
					-state disabled]
  grid  $CtCreateCustom -row 1 -column 1 -sticky neww
  grid columnconfigure $ctFrame 1 -weight 1
  set carsLF [LabelFrame::create $filesLFfr.carsLF -text "cars.dat" -side left]
  pack $carsLF -fill x
  pack [Button::create [$carsLF getframe].button \
	-text "Create Cars" -command "$notebook raise cars"] \
	-fill x

  set divisionsLF [LabelFrame::create $frame.divisionsTF -text "Divisions:" \
							-side top]
  pack $divisionsLF -fill x
  set divisionsLFfr [$divisionsLF getframe]
  variable DivisionsListFR [frame $divisionsLFfr.divisionsListFR]
  pack $DivisionsListFR -expand yes -fill both
  variable DivisionsListIndex 0
  grid [Label::create $DivisionsListFR.numberHead -text {#   } -width 4] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $DivisionsListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $DivisionsListFR.symbolHead -text {S} -width 1] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $DivisionsListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $DivisionsListFR.homeHead \
	-text  {Home} -width 4] \
	-row 0 -column 4 -sticky nw
  grid [Label::create $DivisionsListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [Label::create $DivisionsListFR.areaHead \
		-text {A} -width 1] \
	-row 0 -column 6 -sticky nw
  grid [Label::create $DivisionsListFR.commaDHead -text {,}] \
	-row 0 -column 7 -sticky nw
  grid [Label::create $DivisionsListFR.nameHead -text Name] \
	-row 0 -column 8 -sticky nw
  grid columnconfigure $DivisionsListFR 8 -weight 1
  grid [Label::create $DivisionsListFR.deleteHead \
	-text "Delete?"] \
	-row 0 -column 9 -sticky nw
  
  pack [Button::create $divisionsLFfr.addDivision \
				-text "Add Division" \
				-command FCFCreSystem::AddDivision] \
	-anchor w
  set stationsLF [LabelFrame::create $frame.stationsTF -text "Stations:" \
								-side top]
  pack $stationsLF -fill x
  set stationsLFfr [$stationsLF getframe]
  variable StationsListFR [frame $stationsLFfr.stationsListFR]
  variable StationsListIndex 0
  pack $StationsListFR -expand yes -fill both
  grid [Label::create $StationsListFR.numberHead -text {#   } -width 4] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $StationsListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $StationsListFR.nameHead -text {Name}] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $StationsListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $StationsListFR.divisionHead \
	-text  {Div} -width 4] \
	-row 0 -column 4 -sticky nw
  grid [Label::create $StationsListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [Label::create $StationsListFR.commentHead -text {Comment}] \
	-row 0 -column 6 -sticky nw
  grid columnconfigure $StationsListFR 6 -weight 1
  grid [Label::create $StationsListFR.deleteHead \
	-text "Delete?" ] \
	-row 0 -column 7 -sticky nw
  pack [Button::create $stationsLFfr.addStation \
				-text "Add Station" \
				-command FCFCreSystem::AddStation] \
	-anchor w
}

proc FCFCreSystem::AddDivision {} {
  variable DivisionsListFR
  variable DivisionsListIndex
  variable IsValidated no

  set lastrow [lindex [grid size $DivisionsListFR] 1]
  grid [SpinBox::create $DivisionsListFR.number$DivisionsListIndex \
	-range  {1 1000 1} -width 4] \
	-row $lastrow -column 0 -sticky nw
  grid [Label::create $DivisionsListFR.commaA$DivisionsListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [ComboBox::create $DivisionsListFR.symbol$DivisionsListIndex \
		-values [::AllAlphaNums] -editable no -width 1] \
	-row $lastrow -column 2 -sticky nw
  $DivisionsListFR.symbol$DivisionsListIndex setvalue first
  grid [Label::create $DivisionsListFR.commaB$DivisionsListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [SpinBox::create $DivisionsListFR.home$DivisionsListIndex \
	-range  {1 1000 1} -width 4] \
	-row $lastrow -column 4 -sticky nw
  grid [Label::create $DivisionsListFR.commaC$DivisionsListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [ComboBox::create $DivisionsListFR.area$DivisionsListIndex \
		-values [::AllAlphaNums] -editable no -width 1] \
	-row $lastrow -column 6 -sticky nw
  $DivisionsListFR.area$DivisionsListIndex setvalue first
  grid [Label::create $DivisionsListFR.commaD$DivisionsListIndex -text {,}] \
	-row $lastrow -column 7 -sticky nw
  grid [Entry::create $DivisionsListFR.name$DivisionsListIndex] \
	-row $lastrow -column 8 -sticky new
  grid [Button::create $DivisionsListFR.delete$DivisionsListIndex \
	-text "Delete" \
	-command "FCFCreSystem::DeleteDivision $DivisionsListIndex"] \
	-row $lastrow -column 9 -sticky nw
  incr DivisionsListIndex
}

proc FCFCreSystem::DeleteDivision {index} {
  variable DivisionsListFR
  variable IsValidated no

#  puts stderr "*** FCFCreSystem::DeleteDivision: \[grid info $DivisionsListFR.number$index\] = [grid info $DivisionsListFR.number$index]"
  if {![winfo exists ${DivisionsListFR}.number$index]} {return}
  foreach f {number commaA symbol commaB  home commaC area commaD name delete} {
    grid forget ${DivisionsListFR}.${f}$index
    destroy ${DivisionsListFR}.${f}$index
  }
}

proc ::AllAlphaNums {} {
  set result {0 1 2 3 4 5 6 7 8 9}
  for {set i 0} {$i < 26} {incr i} {
    set letter [format %c [expr {65 + $i}]]
    lappend result [string tolower "$letter"] "$letter"
  }
  return [lsort -ascii $result]
}

proc FCFCreSystem::AddStation {} {
  variable StationsListFR
  variable StationsListIndex
  variable IsValidated no

  set lastrow [lindex [grid size $StationsListFR] 1]
  grid [SpinBox::create $StationsListFR.number$StationsListIndex \
	-range  {2 1000 1} -width 4] \
	-row $lastrow -column 0 -sticky nw
  grid [Label::create $StationsListFR.commaA$StationsListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [Entry::create $StationsListFR.name$StationsListIndex] \
	-row $lastrow -column 2 -sticky nw
  grid [Label::create $StationsListFR.commaB$StationsListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [SpinBox::create $StationsListFR.division$StationsListIndex \
	-range  {1 1000 1} -width 4] \
	-row $lastrow -column 4 -sticky nw
  grid [Label::create $StationsListFR.commaC$StationsListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [Entry::create $StationsListFR.comment$StationsListIndex] \
	-row $lastrow -column 6 -sticky new
  grid [Button::create $StationsListFR.delete$StationsListIndex \
	-text "Delete" \
	-command "FCFCreSystem::DeleteStation $StationsListIndex"] \
	-row $lastrow -column 7 -sticky nw
  incr StationsListIndex
}

proc FCFCreSystem::DeleteStation {index} {
  variable StationsListFR
  variable IsValidated no

  if {![winfo exists ${StationsListFR}.number$index]} {return}
  foreach f {number commaA name commaB division commaC comment delete} {
    grid forget ${StationsListFR}.${f}$index
    destroy ${StationsListFR}.${f}$index
  }
}

proc FCFCreSystem::ValidateSystemFile {} {
  variable SystemNameLE
  variable DivisionsListFR
  variable DivisionsListIndex
  variable StationsListFR
  variable StationsListIndex
  variable IsValidated

  if {$IsValidated} {return yes}
  set invalid 0

  if {[string length "[$SystemNameLE cget -text]"] == 0} {
    tk_messageBox -type ok -icon error -message "No system name!"
    incr invalid
  }
  variable DivisionIndexList {}
  variable DivisionSymbolList {}
  variable StationIndexList {}


  for {set di 0} {$di < $DivisionsListIndex} {incr di} {
    if {![winfo exists $DivisionsListFR.number$di]} {continue}
    set divNum [$DivisionsListFR.number$di cget -text]
    set divSym [$DivisionsListFR.symbol$di cget -text]
    set divName "[$DivisionsListFR.name$di cget -text]"
    if {$divNum < 1} {
      tk_messageBox -type ok -icon error -message "Invalid division index ($divNum < 1) for division $divName"
      incr invalid
      continue
    }
    if {[lsearch $DivisionIndexList $divNum] >= 0} {
      tk_messageBox -type ok -icon error -message "Duplicate division index ($divNum) for division $divName"
      incr invalid
      continue
    }
    if {[lsearch $DivisionSymbolList $divSym] >= 0} {
      tk_messageBox -type ok -icon error -message "Duplicate division symbol ($divSym) for division $divName"
      incr invalid
      continue
    }
    lappend DivisionIndexList $divNum
    lappend DivisionSymbolList $divSym
  }
  if {[llength $DivisionIndexList] < 1} {
    tk_messageBox -type ok -icon error -message "No divisions!"
    incr invalid
    set IsValidated no
    return false
  }
  set DivisionIndexList [lsort -integer $DivisionIndexList]
  set lastDivIndex [lindex $DivisionIndexList end]
  variable Divisions [::RoundUp $lastDivIndex 10]
  if {$Divisions == $lastDivIndex} {incr Divisions 10}

  for {set si 0} {$si < $StationsListIndex} {incr si} {
    if {![winfo exists $StationsListFR.number$si]} {continue}
    set staNum [$StationsListFR.number$si cget -text]
    set staDiv [$StationsListFR.division$si cget -text]
    set staName [$StationsListFR.name$si cget -text]
    if {$staNum < 2} {
      tk_messageBox -type ok -icon error -message "Invalid station index ($staNum < 2) for station $staName"
      incr invalid
      continue
    }
    if {[lsearch $StationIndexList $staNum] >= 0} {
      tk_messageBox -type ok -icon error -message "Duplicate Station index ($staNum) for station $staName"
      incr invalid
      continue
    }
    if {[lsearch $DivisionIndexList $staDiv] < 0} {
      tk_messageBox -type ok -icon error -message "Station division is non-existant ($staDiv) for station $staName ($staNum)"
      incr invalid
      continue
    }
    lappend StationIndexList $staNum
  }
  if {[llength $StationIndexList] < 1} {
    tk_messageBox -type ok -icon error -message "No stations!"
    incr invalid
    set IsValidated no
    return false
  }
  set StationIndexList [lsort -integer $StationIndexList]
  set lastStation [lindex $StationIndexList end]
  variable Stations [::RoundUp $lastStation 10]
  if {$Stations == $lastStation} {incr Stations 10}
  set IsValidated [expr {$invalid == 0}]
  return $IsValidated
}

proc FCFCreSystem::ValidStation {index} {
  variable IsValidated
  variable StationIndexList

  if {!$IsValidated} {
    if {![ValidateSystemFile]} {
      return no
    }
  }
  if {[lsearch $StationIndexList $index] >= 0} {
    return yes
  } else {
    return no
  }
}

proc FCFCreSystem::ValidDivisionSymbol {symbol} {
  variable IsValidated
  variable DivisionSymbolList

  if {!$IsValidated} {
    if {![ValidateSystemFile]} {
      return no
    }
  }
  if {[lsearch $DivisionSymbolList $symbol] >= 0} {
    return yes
  } else {
    return no
  }
}

proc ::RoundUp {val {multiple 1}} {
  return [expr {int(ceil(double($val) / double($multiple)))*$multiple}]
}

proc FCFCreSystem::ResetForm {} {
  variable IsValidated no
  variable SystemNameLE
  $SystemNameLE configure -text {}
  variable CTFile
  set CTFile stock
  ToggleCT
  variable CTStockDirectoryCB
  $CTStockDirectoryCB setvalue first
  variable DivisionsListIndex
  for {set dli 0} {$dli < $DivisionsListIndex} {incr dli} {
    DeleteDivision $dli
  }
  set DivisionsListIndex 0
  variable StationsListIndex
  for {set sli 0} {$sli < $StationsListIndex} {incr sli} {
    DeleteStation $sli
  }
  set StationsListIndex 0
}

proc FCFCreSystem::ToggleCT {} {
  variable CTFile
  variable TheNoteBook
  variable CtCreateCustom
  variable CTStockDirectoryCB

  switch $CTFile {
    stock {
      $TheNoteBook itemconfigure cartypes -state disabled
      $CtCreateCustom configure -state disabled
      $CTStockDirectoryCB configure -state normal
    }
    custom {
      $TheNoteBook itemconfigure cartypes -state normal
      $CtCreateCustom configure -state normal
      $CTStockDirectoryCB configure -state disabled
    }
  }
}

proc FCFCreSystem::WriteSystemFile {directory} {
  variable SystemNameLE
  variable CTFile
  variable CTStockDirectoryCB
  variable DivisionsListFR
  variable DivisionsListIndex
  variable StationsListFR
  variable StationsListIndex
  variable Divisions
  variable Stations

  if {![ValidateSystemFile]} {return false}
  if {![FCFCreIndustries::ValidateIndustriesFile]} {return false}
  if {![FCFCreTrains::ValidateTrainsFile]} {return false}
  if {![FCFCreOrders::ValidateOrdersFile]} {return false}
  if {![FCFCreOwners::ValidateOwnersFile]} {return false}
  if {![FCFCreCars::ValidateCarTypesFile $CTFile "[$CTStockDirectoryCB cget -text]"]} {return false}
  if {![FCFCreCars::ValidateCarsFile]} {return false}

  if {![file exists "$directory"]} {
    if {[tk_messageBox -type yesno -icon question -message "Folder $directory does not exist, create it?"]} {
      file mkdir "$directory"
    } else {
      return false
    }
  } elseif {![file isdirectory "$directory"]} {
    tk_messageBox -type ok -icon error -message "File $directory exists and is NOT a folder!"
    return false
  }
  set oFileName [file join "$directory" system.dat]
  if {[catch {open "$oFileName" w} ofp]} {
    tk_messageBox -type ok -icon error -message "Could not open \"$oFileName\": $ofp"
    return false
  }
  puts $ofp "[$SystemNameLE cget -text]"
  puts $ofp {}
  puts $ofp indus.dat
  puts $ofp trains.dat
  puts $ofp orders.dat
  puts $ofp owners.dat
  puts $ofp cartypes.dat
  puts $ofp cars.dat
  puts $ofp stats.dat
  puts $ofp {}  
  puts $ofp "Divisions = $Divisions"
  for {set di 0} {$di < $DivisionsListIndex} {incr di} {
    if {![winfo exists $DivisionsListFR.number$di]} {continue}
    set divNum [$DivisionsListFR.number$di cget -text]
    set divSym [$DivisionsListFR.symbol$di cget -text]
    set divHome [$DivisionsListFR.home$di cget -text]
    set divArea [$DivisionsListFR.area$di cget -text]
    set divName "[$DivisionsListFR.name$di cget -text]"
    puts $ofp "$divNum,$divSym,$divHome,$divArea,$divName"
  }
  puts $ofp "-1"
  puts $ofp "Stations = $Stations"
  for {set si 0} {$si < $StationsListIndex} {incr si} {
    if {![winfo exists $StationsListFR.number$si]} {continue}
    set staNum [$StationsListFR.number$si cget -text]
    set staName "[$StationsListFR.name$si cget -text]"
    set staDiv [$StationsListFR.division$si cget -text]
    set staComm "[$StationsListFR.comment$si cget -text]"
    puts $ofp "$staNum,$staName,$staDiv,$staComm"
  }
  puts $ofp "-1"
  close $ofp
  if {![FCFCreIndustries::WriteIndustriesFile "$directory" indus.dat]} {return false}
  if {![FCFCreTrains::WriteTrains "$directory" trains.dat]} {return false}
  if {![FCFCreOrders::WriteOrders "$directory" orders.dat]} {return false}
  if {![FCFCreOwners::WriteOwners "$directory" owners.dat]} {return false}
  if {![FCFCreCars::WriteCarTypes "$directory" cartypes.dat hazard.dat plate.dat \
					weight.dat $CTFile \
					"[$CTStockDirectoryCB cget -text]"]} {return false}
  if {![FCFCreCars::WriteCars "$directory" cars.dat]} {return false}
  if {![FCFCreIndustries::WriteStats "$directory" stats.dat]} {return false}
  return true
}

package provide FCFCreSystem 1.0
