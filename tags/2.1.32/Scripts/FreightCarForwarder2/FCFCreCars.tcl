#* 
#* ------------------------------------------------------------------
#* FCFCreCars.tcl - Create Cars and CarTypes files
#* Created by Robert Heller on Sat Nov 17 15:03:24 2007
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

namespace eval FCFCreCars {
  variable CarsPage
  variable CarsPageFR
  variable CarsListFR
  variable CarsListIndex 0
  variable IsValidated no
  variable IsCTValidated no
  variable Cars 0

  variable CarTypesPage
  variable CarTypesPageFR
  variable AllCarTypes {}
  for {set i 0} {$i < 128} {incr i} {
    set c [format {%c} $i]
    if {![string is print "$c"]} {continue}
    if {[string is space "$c"]} {continue}
    if {[string equal "$c" {,}]} {continue}
    if {[string equal "$c" {'}]} {continue}
    if {[string equal "$c" "\""]} {continue}
    append cartypes "$c"
  }
  set AllCarTypes [lsort -ascii [split "$cartypes" {}]]
  variable CarTypesListFR
  variable CarGroupsListFR
  variable CarGroupsListIndex 0
  variable CarGroups {}
  variable HazardListFR
  variable HazardListIndex 0
  variable WeightListFR
  variable WeightListIndex 0
  variable PlateListFR
  variable PlateListIndex 0
}

proc FCFCreCars::FCFCreCars {notebook} {
  variable CarsPage [$notebook insert end cars \
				-text [_m "Tab|Cars File"]]
  set CarsPageSW [ScrolledWindow::create $CarsPage.sw \
				-auto vertical -scrollbar vertical]
  pack $CarsPageSW -expand yes -fill both
  variable CarsPageFR  [ScrollableFrame::create $CarsPageSW.fr \
						-constrainedwidth yes]
  pack $CarsPageFR -expand yes -fill both
  $CarsPageSW setwidget $CarsPageFR
  set frame [$CarsPageFR getframe]
  variable CarsListFR [frame $frame.carsListFR]
  pack $CarsListFR -expand yes -fill both
  variable CarsListIndex 0

  grid [Label::create $CarsListFR.typeHead -text [_m "Label|T"]] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $CarsListFR.commaAHead -text ","] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $CarsListFR.marksHead -text [_m "Label|RR"]] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $CarsListFR.commaBHead -text ","] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $CarsListFR.numberHead -text [_m "Label|NUM"]] \
	-row 0 -column 4 -sticky nw
  grid [Label::create $CarsListFR.commaCHead -text ","] \
	-row 0 -column 5 -sticky nw
  grid [Label::create $CarsListFR.homedivHead -text [_m "Label|HOMEDIVS"]] \
	-row 0 -column 6 -sticky nw
  grid columnconfigure $CarsListFR 6 -weight 1
  grid [Label::create $CarsListFR.commaDHead -text ","] \
	-row 0 -column 7 -sticky nw
  grid [Label::create $CarsListFR.lenHead -text [_m "Label|LEN"]] \
	-row 0 -column 8 -sticky nw
  grid [Label::create $CarsListFR.commaEHead -text ","] \
	-row 0 -column 9 -sticky nw
  grid [Label::create $CarsListFR.clearHead -text [_m "Label|C"]] \
	-row 0 -column 10 -sticky nw
  grid [Label::create $CarsListFR.commaFHead -text ","] \
	-row 0 -column 11 -sticky nw
  grid [Label::create $CarsListFR.weightHead -text [_m "Label|W"]] \
	-row 0 -column 12 -sticky nw
  grid [Label::create $CarsListFR.commaGHead -text ","] \
	-row 0 -column 13 -sticky nw
  grid [Label::create $CarsListFR.ltwtHead -text [_m "Label|LTWT"]] \
	-row 0 -column 14 -sticky nw
  grid [Label::create $CarsListFR.commaHHead -text ","] \
	-row 0 -column 15 -sticky nw
  grid [Label::create $CarsListFR.ldlmtHead -text [_m "Label|LDLMT"]] \
	-row 0 -column 16 -sticky nw
  grid [Label::create $CarsListFR.commaIHead -text ","] \
	-row 0 -column 17 -sticky nw
  grid [Label::create $CarsListFR.statusHead -text [_m "Label|S"]] \
	-row 0 -column 18 -sticky nw
  grid [Label::create $CarsListFR.commaJHead -text ","] \
	-row 0 -column 19 -sticky nw
  grid [Label::create $CarsListFR.mirrorHead -text [_m "Label|M"]] \
	-row 0 -column 20 -sticky nw
  grid [Label::create $CarsListFR.commaKHead -text ","] \
	-row 0 -column 21 -sticky nw
  grid [Label::create $CarsListFR.fixedHead -text [_m "Label|F"]] \
	-row 0 -column 22 -sticky nw
  grid [Label::create $CarsListFR.commaLHead -text ","] \
	-row 0 -column 23 -sticky nw
  grid [Label::create $CarsListFR.ownHead -text [_m "Label|OWN"]] \
	-row 0 -column 24 -sticky nw
  grid [Label::create $CarsListFR.commaMHead -text ","] \
	-row 0 -column 25 -sticky nw
  grid [Label::create $CarsListFR.locHead -text [_m "Label|LOC"]] \
	-row 0 -column 26 -sticky nw
  grid [Label::create $CarsListFR.commaNHead -text ","] \
	-row 0 -column 27 -sticky nw
  grid [Label::create $CarsListFR.destHead -text [_m "Label|DEST"]] \
	-row 0 -column 28 -sticky nw
  grid [Label::create $CarsListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 29 -sticky nw

  pack [Button::create $frame.addCar -text [_m "Button|Add Car"] \
					-command FCFCreCars::AddCar] \
	-anchor w
}

proc FCFCreCars::AddCar {} {
  variable CarsListFR
  variable CarsListIndex
  variable AllCarTypes
  variable IsValidated no

  set lastrow [lindex [grid size $CarsListFR] 1]
  grid [ComboBox::create $CarsListFR.type$CarsListIndex \
		-values $AllCarTypes -editable no -width 1] \
	-row $lastrow -column 0 -sticky nw
  $CarsListFR.type$CarsListIndex setvalue first
  grid [Label::create $CarsListFR.commaA$CarsListIndex -text ","] \
	-row $lastrow -column 1 -sticky nw
  grid [Entry::create $CarsListFR.marks$CarsListIndex -width 9] \
	-row $lastrow -column 2 -sticky nw
  grid [Label::create $CarsListFR.commaB$CarsListIndex -text ","] \
	-row $lastrow -column 3 -sticky nw
  grid [Entry::create $CarsListFR.number$CarsListIndex -width 8] \
	-row $lastrow -column 4 -sticky nw
  grid [Label::create $CarsListFR.commaC$CarsListIndex -text ","] \
	-row $lastrow -column 5 -sticky nw
  grid [Entry::create $CarsListFR.homediv$CarsListIndex -width 10] \
	-row $lastrow -column 6 -sticky nw
  grid [Label::create $CarsListFR.commaD$CarsListIndex -text ","] \
	-row $lastrow -column 7 -sticky nw
  grid [SpinBox::create $CarsListFR.len$CarsListIndex -range {10 150 10} \
					-width 3] \
	-row $lastrow -column 8 -sticky nw
  grid [Label::create $CarsListFR.commaE$CarsListIndex -text ","] \
	-row $lastrow -column 9 -sticky nw
  grid [SpinBox::create $CarsListFR.clear$CarsListIndex -range {1 9 1} \
					-width 1] \
	-row $lastrow -column 10 -sticky nw
  grid [Label::create $CarsListFR.commaF$CarsListIndex -text ","] \
	-row $lastrow -column 11 -sticky nw
  grid [SpinBox::create $CarsListFR.weight$CarsListIndex -range {1 9 1} \
					-width 1] \
	-row $lastrow -column 12 -sticky nw
  grid [Label::create $CarsListFR.commaG$CarsListIndex -text ","] \
	-row $lastrow -column 13 -sticky nw
  grid [SpinBox::create $CarsListFR.ltwt$CarsListIndex -range {10 50 5} \
					-width 3] \
	-row $lastrow -column 14 -sticky nw
  grid [Label::create $CarsListFR.commaH$CarsListIndex -text ","] \
	-row $lastrow -column 15 -sticky nw
  grid [SpinBox::create $CarsListFR.ldlmt$CarsListIndex -range {10 200 5} \
					-width 3] \
	-row $lastrow -column 16 -sticky nw
  grid [Label::create $CarsListFR.commaI$CarsListIndex -text ","] \
	-row $lastrow -column 17 -sticky nw
  grid [ComboBox::create $CarsListFR.status$CarsListIndex -values {E L} \
					-editable no -width 1] \
	-row $lastrow -column 18 -sticky nw
  $CarsListFR.status$CarsListIndex setvalue first
  grid [Label::create $CarsListFR.commaJ$CarsListIndex -text ","] \
	-row $lastrow -column 19 -sticky nw
  grid [ComboBox::create $CarsListFR.mirror$CarsListIndex -values {N Y} \
					-editable no -width 1] \
	-row $lastrow -column 20 -sticky nw
  $CarsListFR.mirror$CarsListIndex setvalue first
  grid [Label::create $CarsListFR.commaK$CarsListIndex -text ","] \
	-row $lastrow -column 21 -sticky nw
  grid [ComboBox::create $CarsListFR.fixed$CarsListIndex -values {N Y} \
					-editable no -width 1] \
	-row $lastrow -column 22 -sticky nw
  $CarsListFR.fixed$CarsListIndex setvalue first
  grid [Label::create $CarsListFR.commaL$CarsListIndex -text ","] \
	-row $lastrow -column 23 -sticky nw
  grid [Entry::create $CarsListFR.own$CarsListIndex -width 3] \
	-row $lastrow -column 24 -sticky nw
  grid [Label::create $CarsListFR.commaM$CarsListIndex -text ","] \
	-row $lastrow -column 25 -sticky nw
  grid [SpinBox::create $CarsListFR.loc$CarsListIndex -range {0 999 1} \
					-width 3] \
	-row $lastrow -column 26 -sticky nw
  grid [Label::create $CarsListFR.commaN$CarsListIndex -text ","] \
	-row $lastrow -column 27 -sticky nw
  grid [SpinBox::create $CarsListFR.dest$CarsListIndex -range {0 999 1} \
					-width 3] \
	-row $lastrow -column 28 -sticky nw
  grid [Button::create $CarsListFR.delete$CarsListIndex -text [_m "Button|Delete"] \
			-command "FCFCreCars::DeleteCar $CarsListIndex"] \
	-row $lastrow -column 29 -sticky nw
  incr CarsListIndex
}

proc FCFCreCars::DeleteCar {index} {
  variable CarsListFR

  if {![winfo exists $CarsListFR.type$index]} {return}
  foreach f {type commaA marks commaB number commaC homediv commaD len commaE 
	     clear commaF weight commaG ltwt commaH ldlmt commaI status commaJ 
	     mirror commaK fixed commaL own commaM loc commaN dest delete} {
    grid forget $CarsListFR.$f$index
    destroy $CarsListFR.$f$index
  }
}

proc FCFCreCars::ResetForm {} {
  variable CarsListIndex

  for {set i 0} {$i < $CarsListIndex} {incr i} {DeleteCar $i}
  set CarsListIndex 0
}

proc FCFCreCars::ValidateCarsFile {} {
  variable CarsListFR
  variable CarsListIndex
  variable IsValidated
  variable Cars

  if {$IsValidated} {return yes}
  set invalid 0
  set Cars 0

  for {set i 0} {$i < $CarsListIndex} {incr i} {
    if {![winfo exists $CarsListFR.type$i]} {continue}
    set RR  "[$CarsListFR.marks$i cget -text]"
    set NUM "[$CarsListFR.number$i cget -text]"
    foreach ds [split "[$CarsListFR.homediv$i cget -text]" {}] {
      if {![FCFCreSystem::ValidDivisionSymbol "$ds"]} {
	tk_messageBox -type ok -icon error -message [_ "Invalid division symbol (%s) for car %s %s!" $ds $RR $NUM]
	incr invalid
      }
    }
    set loc [$CarsListFR.loc$i cget -text]
    if {![FCFCreIndustries::ValidIndustry $loc]} {
      tk_messageBox -type ok -icon error -message [_ "Invalid location (%d) for car %s %s!" $loc $RR $NUM]
      incr invalid
    }
    set dest [$CarsListFR.dest$i cget -text]
    if {![FCFCreIndustries::ValidIndustry $loc]} {
      tk_messageBox -type ok -icon error -message [_ "Invalid destination (%d) for car %s %s!" $dest $RR $NUM]
      incr invalid
    }
    incr Cars
  }
  set IsValidated [expr {$invalid == 0}]
  return $IsValidated
}

proc FCFCreCars::WriteCars {directory filename} {
  variable CarsListFR
  variable CarsListIndex
  variable IsValidated
  variable Cars

  if {!$IsValidated} {
    if {![ValidateCarsFile]} {return false}
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
  puts $ofp "0";#	shift
  puts $ofp "0";#	last completed session number
  puts $ofp [::RoundUp $Cars 10];#	The maximum number of cars in this database
  for {set i 0} {$i < $CarsListIndex} {incr i} {
    if {![winfo exists $CarsListFR.type$i]} {continue}
    puts -nonewline $ofp "[$CarsListFR.type$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.marks$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.number$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.homediv$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.len$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.clear$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.weight$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.ltwt$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.ldlmt$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.status$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.mirror$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.fixed$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.own$i cget -text],"
    puts -nonewline $ofp "N,0,0,";# Done, Last Train, Moves
    puts -nonewline $ofp "[$CarsListFR.loc$i cget -text],"
    puts -nonewline $ofp "[$CarsListFR.dest$i cget -text],"
    puts            $ofp "0,0";# Trips, Assigns
  }
  close $ofp
  return true
}

proc FCFCreCars::FCFCreCarTypes {notebook} {
  variable CarTypesPage [$notebook insert end cartypes \
				-text [_m "Tab|CarTypes File"] -state disabled]
  set CarTypesPageSW [ScrolledWindow::create $CarTypesPage.sw \
				-auto vertical -scrollbar vertical]
  pack $CarTypesPageSW -expand yes -fill both
  variable CarTypesPageFR  [ScrollableFrame::create $CarTypesPageSW.fr \
						-constrainedwidth yes]
  pack $CarTypesPageFR -expand yes -fill both
  $CarTypesPageSW setwidget $CarTypesPageFR
  set frame [$CarTypesPageFR getframe]

  set ctLF [LabelFrame::create $frame.ctLF -text [_m "Label|Car Types:"] -side top]
  pack $ctLF -fill x
  set ctLFfr [$ctLF getframe]
  variable CarTypesListFR [frame $ctLFfr.carTypesListFR]
  pack $CarTypesListFR -expand yes -fill both
  grid [Label::create $CarTypesListFR.typeHead -text [_m "Label|T"]] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $CarTypesListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $CarTypesListFR.groupHead -text [_m "Label|G"]] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $CarTypesListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $CarTypesListFR.descrHead -text [_m "Label|Description"]] \
	-row 0 -column 4 -sticky nw
  grid [Label::create $CarTypesListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [Label::create $CarTypesListFR.padHead -text {}] \
	-row 0 -column 6 -sticky nw
  grid [Label::create $CarTypesListFR.commaDHead -text {,}] \
	-row 0 -column 7 -sticky nw
  grid [Label::create $CarTypesListFR.commentHead -text [_m "Label|Comment"]] \
	-row 0 -column 8 -sticky nw
  grid columnconfigure $CarTypesListFR 8 -weight 1

  variable AllCarTypes
  set index 0
  set lastrow 1
  foreach ct $AllCarTypes {
    grid [Label::create $CarTypesListFR.type$index -text "$ct"] \
	-row $lastrow -column 0 -sticky nw
    grid [Label::create $CarTypesListFR.commaA$index -text {,}] \
	-row $lastrow -column 1 -sticky nw
    grid [ComboBox::create $CarTypesListFR.group$index \
			-values [::AllAlphaNums] -editable no -width 1] \
	-row $lastrow -column 2 -sticky nw
    $CarTypesListFR.group$index setvalue first
    grid [Label::create $CarTypesListFR.commaB$index -text {,}] \
	-row $lastrow -column 3 -sticky nw
    grid [Entry::create $CarTypesListFR.descr$index -width 16] \
	-row $lastrow -column 4 -sticky nw
    grid [Label::create $CarTypesListFR.commaC$index -text {,}] \
	-row $lastrow -column 5 -sticky nw
    grid [Label::create $CarTypesListFR.pad$index -text {0}] \
	-row $lastrow -column 6 -sticky nw
    grid [Label::create $CarTypesListFR.commaD$index -text {,}] \
	-row $lastrow -column 7 -sticky nw
    grid [Entry::create $CarTypesListFR.comment$index] \
	-row $lastrow -column 8 -sticky new
    incr lastrow
    incr index

  }
  set cgLF [LabelFrame::create $frame.cgLF -text [_m "Label|Car Groups:"] -side top]
  pack $cgLF -fill x
  set cgLFfr [$cgLF getframe]
  variable CarGroupsListFR [frame $cgLFfr.carGroupsListFR]
  pack $CarGroupsListFR -expand yes -fill both
  variable CarGroupsListIndex 0
  grid [Label::create $CarGroupsListFR.groupHead -text [_m "Label|G"]] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $CarGroupsListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $CarGroupsListFR.descHead -text [_m "Label|Description"]] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $CarGroupsListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $CarGroupsListFR.commentHead -text [_m "Label|Comment"]] \
	-row 0 -column 4 -sticky nw
  grid columnconfigure $CarGroupsListFR 4 -weight 1
  grid [Label::create $CarGroupsListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 5 -sticky nw
  pack [Button::create $cgLFfr.addCarGroup -text [_m "Button|Add Car Group"] \
					   -command FCFCreCars::AddCarGroup] \
	-anchor w

  set hzLF [LabelFrame::create $frame.hzLF -text [_m "Label|Hazard Classes:"] -side top]
  pack $hzLF -fill x
  set hzLFfr [$hzLF getframe]
  variable HazardListFR [frame $hzLFfr.hazardListFR]
  pack $HazardListFR -expand yes -fill both
  variable HazardListIndex 0
  grid [Label::create $HazardListFR.indexHead -text {#}] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $HazardListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $HazardListFR.descHead -text [_m "Label|Hazard"]] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $HazardListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $HazardListFR.cargoHead -text [_m "Label|Typical cargo"]] \
	-row 0 -column 4 -sticky nw
  grid [Label::create $HazardListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [Label::create $HazardListFR.commentHead -text [_m "Label|Comment"]] \
	-row 0 -column 6 -sticky nw
  grid columnconfigure $HazardListFR 6 -weight 1
  grid [Label::create $HazardListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 7 -sticky nw
  pack [Button::create $hzLFfr.addHazard -text [_m "Button|Add Hazard"] \
					   -command FCFCreCars::AddHazard] \
	-anchor w

  set wtLF [LabelFrame::create $frame.wtLF -text [_m "Label|Weight Classes:"] -side top]
  pack $wtLF -fill x
  set wtLFfr [$wtLF getframe]
  variable WeightListFR [frame $wtLFfr.weightListFR]
  pack $WeightListFR -expand yes -fill both
  variable WeightListIndex 0
  grid [Label::create $WeightListFR.indexHead -text {#}] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $WeightListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $WeightListFR.weightHead -text [_m "Label|Weight"]] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $WeightListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $WeightListFR.commentHead -text [_m "Label|Comment"]] \
	-row 0 -column 4 -sticky nw
  grid columnconfigure $WeightListFR 4 -weight 1
  grid [Label::create $WeightListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 5 -sticky nw
  pack [Button::create $wtLFfr.addWeight -text [_m "Button|Add Weight"] \
					   -command FCFCreCars::AddWeight] \
	-anchor w

  set ptLF [LabelFrame::create $frame.ptLF -text [_m "Label|Clearence Plate Classes:"] -side top]
  pack $ptLF -fill x
  set ptLFfr [$ptLF getframe]
  variable PlateListFR [frame $ptLFfr.plateListFR]
  pack $PlateListFR -expand yes -fill both
  variable PlateListIndex 0
  grid [Label::create $PlateListFR.indexHead -text {#}] \
	-row 0 -column 0 -sticky nw
  grid [Label::create $PlateListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [Label::create $PlateListFR.descHead -text [_m "Label|Plate Code"]] \
	-row 0 -column 2 -sticky nw
  grid [Label::create $PlateListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [Label::create $PlateListFR.commentHead -text [_m "Label|Comment"]] \
	-row 0 -column 4 -sticky nw
  grid columnconfigure $PlateListFR 4 -weight 1
  grid [Label::create $PlateListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 5 -sticky nw
  pack [Button::create $ptLFfr.addPlate -text [_m "Button|Add Plate"] \
					   -command FCFCreCars::AddPlate] \
	-anchor w

}

proc FCFCreCars::AddCarGroup {} {
  variable CarGroupsListFR
  variable CarGroupsListIndex
  variable IsCTValidated no

  set lastrow [lindex [grid size $CarGroupsListFR] 1]
  if {$lastrow >= 17} {
    tk_messageBox -type ok -icon warning -message [_ "16 Groups max!"]
    return
  }
  grid [ComboBox::create $CarGroupsListFR.group$CarGroupsListIndex \
			-values [::AllAlphaNums] -editable no -width 1] \
	-row $lastrow -column 0 -sticky nw
  grid [Label::create $CarGroupsListFR.commaA$CarGroupsListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [Entry::create $CarGroupsListFR.desc$CarGroupsListIndex] \
	-row $lastrow -column 2 -sticky nw
  grid [Label::create $CarGroupsListFR.commaB$CarGroupsListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [Entry::create $CarGroupsListFR.comment$CarGroupsListIndex] \
	-row $lastrow -column 4 -sticky new
  grid [Button::create $CarGroupsListFR.delete$CarGroupsListIndex \
		-text [_m "Button|Delete"] \
		-command "FCFCreCars::DeleteGroup $CarGroupsListIndex"] \
	-row $lastrow -column 5 -sticky nw
  incr CarGroupsListIndex
}

proc FCFCreCars::DeleteGroup {index} {
  variable CarGroupsListFR
  variable IsCTValidated no

  if {![winfo exists $CarGroupsListFR.group$index]} {return}
  set elementinfo [grid info $CarGroupsListFR.group$index]
  set therowIndex [expr {[lsearch $elementinfo -row] + 1}]
  set therow [lindex $elementinfo $therowIndex]
  foreach f {group commaA desc commaB comment delete} {
    grid forget $CarGroupsListFR.$f$index
    destroy $CarGroupsListFR.$f$index
  }
  set lastrow [lindex [grid size $CarGroupsListFR] 1]
#  puts stderr "*** FCFCreCars::DeleteGroup (1): lastrow = $lastrow, therow = $therow"
  while {$therow < $lastrow} {
    foreach s [grid slaves $CarGroupsListFR -row [expr {$therow + 1}]] {
      grid $s -row $therow
    }
    incr therow
  }
  set lastrow [lindex [grid size $CarGroupsListFR] 1]
#  puts stderr "*** FCFCreCars::DeleteGroup (2): lastrow = $lastrow, therow = $therow"
}

proc FCFCreCars::AddHazard {} {
  variable HazardListFR
  variable HazardListIndex

  set lastrow [lindex [grid size $HazardListFR] 1]
  if {$lastrow > 9} {
    tk_messageBox -type ok -icon warning -message [_ "9 Hazard types max!"]
    return
  }
  grid [Label::create $HazardListFR.index$HazardListIndex -text "$lastrow"] \
	-row $lastrow -column 0 -sticky nw
  grid [Label::create $HazardListFR.commaA$HazardListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [Entry::create $HazardListFR.desc$HazardListIndex] \
	-row $lastrow -column 2 -sticky nw
  grid [Label::create $HazardListFR.commaB$HazardListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [Entry::create $HazardListFR.cargo$HazardListIndex] \
	-row $lastrow -column 4 -sticky nw
  grid [Label::create $HazardListFR.commaC$HazardListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [Entry::create $HazardListFR.comment$HazardListIndex] \
	-row $lastrow -column 6 -sticky new
  grid [Button::create $HazardListFR.delete$HazardListIndex \
			-text [_m "Button|Delete"] \
			-command "FCFCreCars::DeleteHazard $HazardListIndex"] \
	-row $lastrow -column 7 -sticky nw
  incr HazardListIndex
}

proc FCFCreCars::DeleteHazard {index} {
  variable HazardListFR

  if {![winfo exists $HazardListFR.index$index]} {return}
  set elementinfo [grid info $HazardListFR.index$index]
  set therowIndex [expr {[lsearch $elementinfo -row] + 1}]
  set therow [lindex $elementinfo $therowIndex]
  foreach f {index commaA desc commaB cargo commaC comment delete} {
    grid forget $HazardListFR.$f$index
    destroy $HazardListFR.$f$index
  }
  set lastrow [lindex [grid size $HazardListFR] 1]
#  puts stderr "*** FCFCreCars::DeleteHazard (1): lastrow = $lastrow, therow = $therow"
  while {$therow < $lastrow} {
    foreach s [grid slaves $HazardListFR -row [expr {$therow + 1}]] {
      grid $s -row $therow
      if {[regexp "$HazardListFR\\.index\[0-9\]" "$s"] > 0} {
	$s configure -text $therow
      }
    }
    incr therow
  }
  set lastrow [lindex [grid size $HazardListFR] 1]
#  puts stderr "*** FCFCreCars::DeleteHazard (2): lastrow = $lastrow, therow = $therow"
}

proc FCFCreCars::AddWeight {} {
  variable WeightListFR
  variable WeightListIndex

  set lastrow [lindex [grid size $WeightListFR] 1]
  if {$lastrow > 9} {
    tk_messageBox -type ok -icon warning -message [_ "9 Weight Classes max!"]
    return
  }
  grid [Label::create $WeightListFR.index$WeightListIndex -text "$lastrow"] \
	-row $lastrow -column 0 -sticky nw
  grid [Label::create $WeightListFR.commaA$WeightListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [Entry::create $WeightListFR.weight$WeightListIndex] \
	-row $lastrow -column 2 -sticky nw
  grid [Label::create $WeightListFR.commaB$WeightListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [Entry::create $WeightListFR.comment$WeightListIndex -text] \
	-row $lastrow -column 4 -sticky new
  grid [Button::create $WeightListFR.delete$WeightListIndex \
			-text [_m "Button|Delete"] \
			-command "FCFCreCars::DeleteWeight $WeightListIndex"] \
	-row $lastrow -column 5 -sticky nw
  incr WeightListIndex
}

proc FCFCreCars::DeleteWeight {index} {
  variable WeightListFR

  if {![winfo exists $WeightListFR.index$index]} {return}
  set elementinfo [grid info $WeightListFR.index$index]
  set therowIndex [expr {[lsearch $elementinfo -row] + 1}]
  set therow [lindex $elementinfo $therowIndex]
  foreach f {index commaA weight commaB comment delete} {
    grid forget $WeightListFR.$f$index
    destroy $WeightListFR.$f$index
  }
  set lastrow [lindex [grid size $WeightListFR] 1]
#  puts stderr "*** FCFCreCars::DeleteWeight (1): lastrow = $lastrow, therow = $therow"
  while {$therow < $lastrow} {
    foreach s [grid slaves $WeightListFR -row [expr {$therow + 1}]] {
      grid $s -row $therow
      if {[regexp "$WeightListFR\\.index\[0-9\]" "$s"] > 0} {
	$s configure -text $therow
      }
    }
    incr therow
  }
  set lastrow [lindex [grid size $WeightListFR] 1]
#  puts stderr "*** FCFCreCars::DeleteWeight (2): lastrow = $lastrow, therow = $therow"
}

proc FCFCreCars::AddPlate {} {
  variable PlateListFR
  variable PlateListIndex

  set lastrow [lindex [grid size $PlateListFR] 1]
  if {$lastrow > 9} {
    tk_messageBox -type ok -icon warning -message [_ "9 Plate Classes max!"]
    return
  }
  grid [Label::create $PlateListFR.index$PlateListIndex -text "$lastrow"] \
	-row $lastrow -column 0 -sticky nw
  grid [Label::create $PlateListFR.commaA$PlateListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [Entry::create $PlateListFR.desc$PlateListIndex] \
	-row $lastrow -column 2 -sticky nw
  grid [Label::create $PlateListFR.commaB$PlateListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [Entry::create $PlateListFR.comment$PlateListIndex] \
	-row $lastrow -column 4 -sticky new
  grid [Button::create $PlateListFR.delete$PlateListIndex \
			-text [_m "Button|Delete"] \
			-command "FCFCreCars::DeletePlate $PlateListIndex"] \
	-row $lastrow -column 5 -sticky nw
  incr PlateListIndex
}

proc FCFCreCars::DeletePlate {index} {
  variable PlateListFR

  if {![winfo exists $PlateListFR.index$index]} {return}
  set elementinfo [grid info $PlateListFR.index$index]
  set therowIndex [expr {[lsearch $elementinfo -row] + 1}]
  set therow [lindex $elementinfo $therowIndex]
  foreach f {index commaA desc commaB comment delete} {
    grid forget $PlateListFR.$f$index
    destroy $PlateListFR.$f$index
  }
  set lastrow [lindex [grid size $PlateListFR] 1]
#  puts stderr "*** FCFCreCars::DeletePlate (1): lastrow = $lastrow, therow = $therow"
  while {$therow < $lastrow} {
    foreach s [grid slaves $PlateListFR -row [expr {$therow + 1}]] {
      grid $s -row $therow
      if {[regexp "$PlateListFR\\.index\[0-9\]" "$s"] > 0} {
	$s configure -text $therow
      }
    }
    incr therow
  }
  set lastrow [lindex [grid size $PlateListFR] 1]
#  puts stderr "*** FCFCreCars::DeletePlate (2): lastrow = $lastrow, therow = $therow"
}



proc FCFCreCars::ResetCarTypesForm {} {
  variable CarTypesListFR
  variable AllCarTypes
  variable CarGroupsListIndex
  variable HazardListIndex
  variable WeightListIndex
  variable PlateListIndex
  variable IsCTValidated no

  for {set index 0;set typeCount [llength $AllCarTypes]} {$index < $typeCount} {incr index} {
    $CarTypesListFR.group$index setvalue first
    $CarTypesListFR.descr$index configure -text {}
    $CarTypesListFR.comment$index configure -text {}
  }
  for {set index 0} {$index < $CarGroupsListIndex} {incr index} {
    DeleteGroup $index
  }
  set CarGroupsListIndex 0
  for {set index 0} {$index < $HazardListIndex} {incr index} {
    DeleteHazard $index
  }
  set HazardListIndex 0
  for {set index 0} {$index < $WeightListIndex} {incr index} {
    DeleteWeight $index
  }
  set WeightListIndex 0
  for {set index 0} {$index < $PlateListIndex} {incr index} {
    DeletePlate $index
  }
  set PlateListIndex 0
}

proc FCFCreCars::ValidateCarTypesFile {ctType ctTypeDir} {
  variable IsCTValidated
  switch $ctType {
    stock {
      set IsCTValidated yes
    }
    custom {
      if {$IsCTValidated} {break}
      variable CarTypesListFR
      variable CarGroupsListFR
      variable CarGroupsListIndex
      variable CarGroups {}
      variable AllCarTypes
      set invalid 0
      for {set GI 0} {$GI < $CarGroupsListIndex} {incr GI} {
	if {![winfo exists $CarGroupsListFR.group$GI]} {continue}
	lappend CarGroups [$CarGroupsListFR.group$GI cget -text]
      }
      if {[llength $CarGroups] == 0} {
	incr invalid
	tk_messageBox -type ok -icon error -message [_ "No car groups!"]
      }
      for {set index 0;set numcartype [llength $AllCarTypes]} {$index < $numcartype} {incr index} {
	if {[lsearch $CarGroups [$CarTypesListFR.group$index cget -text]] < 0} {
	  incr invalid
	  tk_messageBox -type ok -icon error -message [_ "Invalid group for car type %s: %s!" [$CarTypesListFR.type$index cget -text] [$CarTypesListFR.group$index cget -text]]
	}
      }
      variable HazardListFR
      if {[lindex [grid size $HazardListFR] 1] < 2} {
	incr invalid
	tk_messageBox -type ok -icon error -message ["_ No Hazard classes!"]
      }
      variable WeightListFR
      if {[lindex [grid size $WeightListFR] 1] < 2} {
	incr invalid
	tk_messageBox -type ok -icon error -message ["_ No Weight classes!"]
      }
      variable PlateListFR
      if {[lindex [grid size $PlateListFR] 1] < 2} {
	incr invalid
	tk_messageBox -type ok -icon error -message [_ "No Plate classes!"]
      }
      set IsCTValidated [expr {$invalid == 0}]
    }
  }
  return $IsCTValidated
}

proc FCFCreCars::WriteCarTypes {directory ctfilename hzfilename ptfilename 
				wtfilename ctType ctTypeDir} {

  variable IsCTValidated
  if {!$IsCTValidated} {
    if {![ValidateCarTypesFile $ctType $ctTypeDir]} {return false}
  }
  if {![file exists "$directory"] || ![file isdirectory "$directory"]} {
    tk_messageBox -type ok -icon error -message [_ "%s does not exist or is not a not a folder!" $directory]
    return false
  }
  switch $ctType {
    stock {
      foreach fn [list $ctfilename $hzfilename $ptfilename $wtfilename] {
	file copy -force [file join "$FCFCreSystem::StockDataDir" "$ctTypeDir" "$fn"] \
		    "$directory"
      }
      return true
    }
    custom {
      variable CarTypesListFR
      variable CarGroupsListFR
      variable CarGroupsListIndex
      variable CarGroups
      variable AllCarTypes
      variable HazardListFR
      variable HazardListIndex
      variable WeightListFR
      variable WeightListIndex
      variable PlateListFR
      variable PlateListIndex

      set oFileName [file join "$directory" "$ctfilename"]
      if {[catch {open "$oFileName" w} ofp]} {
	tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
	return false
      }
      puts -nonewline $ofp "'[$CarTypesListFR.typeHead cget -text],"
      puts -nonewline $ofp "[$CarTypesListFR.groupHead cget -text],"
      puts -nonewline $ofp "[$CarTypesListFR.descrHead cget -text],"
      puts -nonewline $ofp "[$CarTypesListFR.padHead cget -text],"
      puts            $ofp "[$CarTypesListFR.commentHead cget -text]"
      for {set index 0;set numcartype [llength $AllCarTypes]} {$index < $numcartype} {incr index} {
	puts -nonewline $ofp "[$CarTypesListFR.type$index cget -text],"
	puts -nonewline $ofp "[$CarTypesListFR.group$index cget -text],"
	puts -nonewline $ofp "[$CarTypesListFR.descr$index cget -text],"
	puts -nonewline $ofp "[$CarTypesListFR.pad$index cget -text],"
	puts            $ofp "[$CarTypesListFR.comment$index cget -text]"
      }
      puts -nonewline $ofp "'[$CarGroupsListFR.groupHead -text],"
      puts -nonewline $ofp "[$CarGroupsListFR.descHead -text],"
      puts            $ofp "[$CarGroupsListFR.commentHead -text]"
      for {set index 0} {$index < $CarGroupsListIndex} {incr index} {
	if {![winfo exists $CarGroupsListFR.group$index]} {continue}
	puts -nonewline $ofp "[$CarGroupsListFR.group$index -text],"
	puts -nonewline $ofp "[$CarGroupsListFR.desc$index -text],"
	puts            $ofp "[$CarGroupsListFR.comment$index -text]"
      }
      close $ofp
      set oFileName [file join "$directory" "$hzfilename"]
      if {[catch {open "$oFileName" w} ofp]} {
	tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
	return false
      }
      for {set index 0} {$index < $HazardListIndex} {incr index} {
	if {![winfo exists $HazardListFR.index$index]} {continue}
	puts -nonewline $ofp "[$HazardListFR.index$index cget -text],"
	puts -nonewline $ofp "[$HazardListFR.desc$index cget -text],"
	puts -nonewline $ofp "[$HazardListFR.cargo$index cget -text],"
	puts            $ofp "[$HazardListFR.icomment$index cget -text]"
      }
      close $ofp
      set oFileName [file join "$directory" "$wtfilename"]
      if {[catch {open "$oFileName" w} ofp]} {
	tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
	return false
      }
      for {set index 0} {$index < $WeightListIndex} {incr index} {
	if {![winfo exists $WeightListFR.index$index]} {continue}
	puts -nonewline $ofp "[$WeightListFR.index$index cget -text],"
	puts -nonewline $ofp "[$WeightListFR.weight$index cget -text],"
	puts            $ofp "[$WeightListFR.comment cget -text]"
      }
      close $ofp
      set oFileName [file join "$directory" "$ptfilename"]
      if {[catch {open "$oFileName" w} ofp]} {
	tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
	return false
      }
      for {set index 0} {$index < $PlateListIndex} {incr index} {
	if {![winfo exists $PlateListFR.index$index]} {continue}
	puts -nonewline $ofp "[$PlateListFR.index$index cget -text],"
	puts -nonewline $ofp "[$PlateListFR.desc$index cget -text],"
	puts            $ofp "[$PlateListFR.comment cget -text]"
      }
      close $ofp
      return true      
    }
  }
}

proc FCFCreCars::ValidCarType {ct} {
  variable AllCarTypes

  if {[lsearch $AllCarTypes "$ct"] < 0} {
    return no
  } else {
    return yes
  }
}

package provide FCFCreCars 1.0

