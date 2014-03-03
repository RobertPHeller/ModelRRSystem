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

package require gettext
package require Tk
package require tile
package require LabelFrames
package require ScrollWindow
package require ScrollableFrame

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
  variable SystemPage [ttk::frame $notebook.system]
  $notebook insert end $SystemPage -text [_m "Tab|System File"]
  set SystemPageSW [ScrolledWindow $SystemPage.sw -auto vertical \
							-scrollbar vertical]
  pack $SystemPageSW -expand yes -fill both
  variable SystemPageFR [ScrollableFrame $SystemPageSW.fr \
							-constrainedwidth yes]
  pack $SystemPageFR -expand yes -fill both
  $SystemPageSW setwidget $SystemPageFR
  set frame [$SystemPageFR getframe]
  
  variable SystemNameLE [LabelEntry $frame.systemNameLE \
				-label [_m "Label|System Name:"]]
  pack $SystemNameLE -fill x
  set filesLF [ttk::labelframe $frame.filesTF -text [_m "Label|Files:"] \
               -labelanchor n]
  pack $filesLF -fill x

  set filesLFfr $filesLF
  set industriesLF [LabelFrame $filesLFfr.industriesLF \
						-text "indus.dat"]
  pack $industriesLF -fill x
  pack [ttk::button [$industriesLF getframe].button \
	-text [_m "Button|Create Industries"] -command "$notebook select \$FCFCreIndustries::IndustriesPage"] \
	-fill x
  set trainsLF [LabelFrame $filesLFfr.trainsLF -text "trains.dat"]
  pack $trainsLF -fill x
  pack [ttk::button [$trainsLF getframe].button \
	-text [_m "Button|Create Trains"] -command "$notebook select \$FCFCreTrains::TrainsPage"] \
	-fill x
  set ordersLF [LabelFrame $filesLFfr.ordersLF -text "orders.dat"]
  pack $ordersLF -fill x
  pack [ttk::button [$ordersLF getframe].button \
	-text [_m "Button|Create Orders"] -command "$notebook select \$FCFCreOrders::OrdersPage"] \
	-fill x
  set ownersLF [LabelFrame $filesLFfr.ownersLF -text "owners.dat"]
  pack $ownersLF -fill x -expand yes
  pack [ttk::button [$ownersLF getframe].button \
	-text [_m "Button|Create Owners"] -command "$notebook select \$FCFCreOwners::OwnersPage"] \
	-fill x
  set cartypesLF [ttk::labelframe $filesLFfr.cartypesLF \
					-text "cartypes.dat" -labelanchor n]
  pack $cartypesLF -fill x
  set ctFrame $cartypesLF
  variable CTFile stock
  variable CTDirectories [glob  -types d -directory $StockDataDir -tails *]
  grid [ttk::radiobutton $ctFrame.stockRB -text [_m "Label|Stock"] -value stock \
				   -variable FCFCreSystem::CTFile \
				   -command FCFCreSystem::ToggleCT] \
	-row 0 -column 0 -sticky nw
  grid [ttk::radiobutton $ctFrame.customRB -text [_m "Label|Custom"] -value custom \
				   -variable FCFCreSystem::CTFile \
				   -command FCFCreSystem::ToggleCT] \
	-row 1 -column 0 -sticky nw
  variable CTStockDirectoryCB [ttk::combobox $ctFrame.ctStockDirectoryCB \
				-values $CTDirectories -state readonly]
  $CTStockDirectoryCB set [lindex $CTDirectories 0]
  grid $CTStockDirectoryCB -row 0 -column 1 -sticky new
  variable CtCreateCustom [ttk::button $ctFrame.ctCreateCustom \
					-text [_m "Button|Create CarTypes"] \
					-command "$notebook select \$FCFCreCars::CarTypesPage" \
					-state disabled]
  grid  $CtCreateCustom -row 1 -column 1 -sticky neww
  grid columnconfigure $ctFrame 1 -weight 1
  set carsLF [LabelFrame $filesLFfr.carsLF -text "cars.dat"]
  pack $carsLF -fill x
  pack [ttk::button [$carsLF getframe].button \
	-text [_m "Button|Create Cars"] -command "$notebook select \$FCFCreCars::CarsPage"] \
	-fill x

  set divisionsLF [ttk::labelframe $frame.divisionsTF \
                   -text [_m "Label|Divisions:"] \
                   -labelanchor n]
  pack $divisionsLF -fill x
  set divisionsLFfr $divisionsLF
  variable DivisionsListFR [frame $divisionsLFfr.divisionsListFR]
  pack $DivisionsListFR -expand yes -fill both
  variable DivisionsListIndex 0
  grid [ttk::label $DivisionsListFR.numberHead -text {#   } -width 4] \
	-row 0 -column 0 -sticky nw
  grid [ttk::label $DivisionsListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [ttk::label $DivisionsListFR.symbolHead -text {S} -width 1] \
	-row 0 -column 2 -sticky nw
  grid [ttk::label $DivisionsListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [ttk::label $DivisionsListFR.homeHead \
	-text  [_m "Label|Home"] -width 4] \
	-row 0 -column 4 -sticky nw
  grid [ttk::label $DivisionsListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [ttk::label $DivisionsListFR.areaHead \
		-text {A} -width 1] \
	-row 0 -column 6 -sticky nw
  grid [ttk::label $DivisionsListFR.commaDHead -text {,}] \
	-row 0 -column 7 -sticky nw
  grid [ttk::label $DivisionsListFR.nameHead -text [_m "Label|Name"]] \
	-row 0 -column 8 -sticky nw
  grid columnconfigure $DivisionsListFR 8 -weight 1
  grid [ttk::label $DivisionsListFR.deleteHead \
	-text [_m "Label|Delete?"]] \
	-row 0 -column 9 -sticky nw
  
  pack [ttk::button $divisionsLFfr.addDivision \
				-text [_m "Button|Add Division"] \
				-command FCFCreSystem::AddDivision] \
	-anchor w
  set stationsLF [ttk::labelframe $frame.stationsTF \
                  -text [_m "Label|Stations:"] \
                  -labelanchor n]
  pack $stationsLF -fill x
  set stationsLFfr $stationsLF
  variable StationsListFR [frame $stationsLFfr.stationsListFR]
  variable StationsListIndex 0
  pack $StationsListFR -expand yes -fill both
  grid [ttk::label $StationsListFR.numberHead -text {#   } -width 4] \
	-row 0 -column 0 -sticky nw
  grid [ttk::label $StationsListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [ttk::label $StationsListFR.nameHead -text [_m "Label|Name"]] \
	-row 0 -column 2 -sticky nw
  grid [ttk::label $StationsListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [ttk::label $StationsListFR.divisionHead \
	-text  [_m "Label|Div"] -width 4] \
	-row 0 -column 4 -sticky nw
  grid [ttk::label $StationsListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [ttk::label $StationsListFR.commentHead -text [_m "Label|Comment"]] \
	-row 0 -column 6 -sticky nw
  grid columnconfigure $StationsListFR 6 -weight 1
  grid [ttk::label $StationsListFR.deleteHead \
	-text [_m "Label|Delete?"] ] \
	-row 0 -column 7 -sticky nw
  pack [ttk::button $stationsLFfr.addStation \
				-text [_m "Button|Add Station"] \
				-command FCFCreSystem::AddStation] \
	-anchor w
}

proc FCFCreSystem::AddDivision {} {
  variable DivisionsListFR
  variable DivisionsListIndex
  variable IsValidated no

  set lastrow [lindex [grid size $DivisionsListFR] 1]
  grid [spinbox $DivisionsListFR.number$DivisionsListIndex \
	-from 1 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 0 -sticky nw
  grid [ttk::label $DivisionsListFR.commaA$DivisionsListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [ttk::combobox $DivisionsListFR.symbol$DivisionsListIndex \
		-values [::AllAlphaNums] -state readonly -width 1] \
	-row $lastrow -column 2 -sticky nw
  $DivisionsListFR.symbol$DivisionsListIndex set [lindex [$DivisionsListFR.symbol$DivisionsListIndex cget -values] 0]
  grid [ttk::label $DivisionsListFR.commaB$DivisionsListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [spinbox $DivisionsListFR.home$DivisionsListIndex \
	-from 1 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 4 -sticky nw
  grid [ttk::label $DivisionsListFR.commaC$DivisionsListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [ttk::combobox $DivisionsListFR.area$DivisionsListIndex \
		-values [::AllAlphaNums] -state readonly -width 1] \
	-row $lastrow -column 6 -sticky nw
  $DivisionsListFR.area$DivisionsListIndex set [lindex [$DivisionsListFR.area$DivisionsListIndex cget -values] 0]
  grid [ttk::label $DivisionsListFR.commaD$DivisionsListIndex -text {,}] \
	-row $lastrow -column 7 -sticky nw
  grid [ttk::entry $DivisionsListFR.name$DivisionsListIndex] \
	-row $lastrow -column 8 -sticky new
  grid [ttk::button $DivisionsListFR.delete$DivisionsListIndex \
	-text [_m "Button|Delete"] \
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
  grid [spinbox $StationsListFR.number$StationsListIndex \
	-from  2 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 0 -sticky nw
  grid [ttk::label $StationsListFR.commaA$StationsListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [ttk::entry $StationsListFR.name$StationsListIndex] \
	-row $lastrow -column 2 -sticky nw
  grid [ttk::label $StationsListFR.commaB$StationsListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [spinbox $StationsListFR.division$StationsListIndex \
	-from 1 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 4 -sticky nw
  grid [ttk::label $StationsListFR.commaC$StationsListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [ttk::entry $StationsListFR.comment$StationsListIndex] \
	-row $lastrow -column 6 -sticky new
  grid [ttk::button $StationsListFR.delete$StationsListIndex \
	-text [_m "Button|Delete"] \
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
    tk_messageBox -type ok -icon error -message [_ "No system name!"]
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
      tk_messageBox -type ok -icon error -message [_ "Invalid division index (%d < 1) for division %s" $divNum $divName]
      incr invalid
      continue
    }
    if {[lsearch $DivisionIndexList $divNum] >= 0} {
      tk_messageBox -type ok -icon error -message [_ "Duplicate division index (%d) for division %s" $divNum $divName]
      incr invalid
      continue
    }
    if {[lsearch $DivisionSymbolList $divSym] >= 0} {
      tk_messageBox -type ok -icon error -message [_ "Duplicate division symbol (%s) for division %s" $divSym $divName]
      incr invalid
      continue
    }
    lappend DivisionIndexList $divNum
    lappend DivisionSymbolList $divSym
  }
  if {[llength $DivisionIndexList] < 1} {
    tk_messageBox -type ok -icon error -message [_ "No divisions!"]
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
      tk_messageBox -type ok -icon error -message [_ "Invalid station index (%d < 2) for station %s" $staNum $staName]
      incr invalid
      continue
    }
    if {[lsearch $StationIndexList $staNum] >= 0} {
      tk_messageBox -type ok -icon error -message [_ "Duplicate Station index (%d) for station %s" $staNum $staName]
      incr invalid
      continue
    }
    if {[lsearch $DivisionIndexList $staDiv] < 0} {
      tk_messageBox -type ok -icon error -message [_ "Station division is non-existant (%s) for station %s (%d)" $staDiv $staName $staNum]
      incr invalid
      continue
    }
    lappend StationIndexList $staNum
  }
  if {[llength $StationIndexList] < 1} {
    tk_messageBox -type ok -icon error -message [_ "No stations!"]
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
  $CTStockDirectoryCB set [lindex [$CTStockDirectoryCB cget -values] 0]
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
      $TheNoteBook tab $FCFCreCars::CarTypesPage -state disabled
      $CtCreateCustom configure -state disabled
      $CTStockDirectoryCB configure -state normal
    }
    custom {
      $TheNoteBook tab $FCFCreCars::CarTypesPage -state normal
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
    if {[tk_messageBox -type yesno -icon question -message [_ "Folder %s does not exist, create it?" $directory]]} {
      file mkdir "$directory"
    } else {
      return false
    }
  } elseif {![file isdirectory "$directory"]} {
    tk_messageBox -type ok -icon error -message [_ "File %s exists and is NOT a folder!" $directory]
    return false
  }
  set oFileName [file join "$directory" system.dat]
  if {[catch {open "$oFileName" w} ofp]} {
    tk_messageBox -type ok -icon error -message [_ "Could not open '%s': %s" $oFileName $ofp]
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
