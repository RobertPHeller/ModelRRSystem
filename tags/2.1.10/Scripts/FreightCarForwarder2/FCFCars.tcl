#* 
#* ------------------------------------------------------------------
#* FCFCars.tcl - FCF2 -- Car related code
#* Created by Robert Heller on Tue Oct 25 14:20:47 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.4  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.3  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:37  heller
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

SplashWorkMessage "Loading Car code" 10

package require BWidget
package require BWLabelSpinBox
package require BWLabelComboBox

proc SaveCars {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem SaveCars  
}

proc LoadCars {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem ReLoadCarFile
}

if {0} {
proc SelectGroups {} {
}
}

package require FCFSearchForCarsDialog

proc SearchForCar {} {
  return "[SearchForCarsDialog draw]"
}

proc FillInViewCarDisplayValues {car} {
  global Main
  set theframe [$Main slideout getframe ViewCarDisplay]
  $theframe.values.rr     configure -text "[Car_Marks $car]"
  $theframe.values.number configure -text "[Car_Number $car]"
  $theframe.values.hdiv   configure -text  "[Car_Divisions $car]"
  $theframe.values.length configure -text [Car_Length $car]
  set type "[Car_Type $car]"
  set carType [TheSystem TheCarType "$type"]
  if {[string equal "$carType" {NULL}]} {
    set carTypeDescr {unknown}
  } else {
    set carTypeDescr "[CarType_Type $carType]"
  }
  $theframe.values.type   configure -text "$carTypeDescr"
  $theframe.values.plate configure -text [Car_Plate $car]
  $theframe.values.class configure -text [Car_WeightClass $car]
  $theframe.values.ltwt  configure -text [Car_LtWt $car]
  $theframe.values.ldlmt configure -text [Car_LdLmt $car]
  if {[Car_LoadedP $car]} {
    $theframe.values.status configure -text Loaded
  } else {
    $theframe.values.status configure -text Empty
  }
  $theframe.values.assigns configure -text [Car_Assignments $car]
  if {[Car_FixedRouteP $car]} {
    $theframe.values.fixedP configure -text Yes
  } else {
    $theframe.values.fixedP configure -text No
  }
  if {[Car_OkToMirrorP $car]} {
    $theframe.values.mirrorP  configure -text Yes
  } else {
    $theframe.values.mirrorP  configure -text No
  }
  set owner [Car_CarOwner $car]
  if {![string equal "$owner" {NULL}]} {
    $theframe.values.owner configure -text "[Owner_Initials $owner]"
  } else {
    $theframe.values.owner configure -text {}
  }
  set dest [Car_Destination $car]
  set loc  [Car_Location $car]
#  puts stderr "*** ViewCar: loc = $loc, dest = $dest"
#  puts stderr "*** ViewCar: TheSystem IndScrapYard = [TheSystem IndScrapYard]"
#  puts stderr "*** ViewCar: TheSystem IndRipTrack = [TheSystem IndRipTrack]"
  if {![string equal "$dest" {NULL}]} {
    if {[string equal "$dest" "[TheSystem IndScrapYard]"]} {
      $theframe.values.dest configure -text "Scrap Yard"
    } elseif {[string equal "$dest" "[TheSystem IndRipTrack]"]} {
      $theframe.values.dest configure -text "RIP Track"
    } elseif {![string equal "$loc" "$dest"]} {
      set indName "[Industry_Name $dest]"
      set station [Industry_MyStation $dest]
      if {![string equal "$station" {NULL}]} {
        set stationName "[Station_Name $station]"
      } else {
	set stationName "-"
      }
      $theframe.values.dest configure -text [format {%s at %s} "$indName" "$stationName"]
    } else {
      $theframe.values.dest configure -text  "- at -"
    }
  } else {
    $theframe.values.dest configure -text  "- at -"
  }
  if {![string equal "$loc" {NULL}]} {
    if {[string equal "$loc" "[TheSystem IndScrapYard]"]} {
      $theframe.values.loc configure -text "Scrap Yard"
    } elseif {[string equal "$loc" "[TheSystem IndRipTrack]"]} {
      $theframe.values.loc configure -text "RIP Track"
    } else {
      set indName "[Industry_Name $loc]"
      set station [Industry_MyStation $loc]
      if {![string equal "$station" {NULL}]} {
	set stationName "[Station_Name $station]"
      } else {
	set stationName "-"
      }
      $theframe.values.loc configure -text  [format {%s at %s} "$indName" "$stationName"]
    }
  } else {
    $theframe.values.loc configure -text  "- at -"
  }
}

proc FillInEditCarDisplayValues {car} {
  global Main
  global EditCarDisplayIndustryList

  set theframe [$Main slideout getframe EditCarDisplay]
  if {[string length "$car"] == 0} {
    $theframe.values.rr     configure -text {}
    $theframe.values.number configure -text {}
    $theframe.values.hdiv   configure -text {}
    $theframe.values.length configure -text 50
    $theframe.values.type   configure -text [lindex [$theframe.values.type cget -values] 0]
    $theframe.values.plate  configure -text 1
    $theframe.values.class  configure -text 1
    $theframe.values.ltwt   configure -text 20
    $theframe.values.ldlmt  configure -text 20
    $theframe.values.status configure -text Empty
    $theframe.values.fixedP  configure -text No
    $theframe.values.mirrorP configure -text No
    $theframe.values.owner   configure -text {}
    $theframe.values.dest    configure -text [lindex [$theframe.values.dest cget -values] $EditCarDisplayIndustryList(industry,[TheSystem IndScrapYard])]
    $theframe.values.loc     configure -text [lindex [$theframe.values.loc  cget -values] $EditCarDisplayIndustryList(industry,[TheSystem IndScrapYard])]
  } else {
    $theframe.values.rr     configure -text "[Car_Marks $car]"
    $theframe.values.number configure -text "[Car_Number $car]"
    $theframe.values.hdiv   configure -text "[Car_Divisions $car]"
    $theframe.values.length configure -text [Car_Length $car]
    set type "[Car_Type $car]"
    global EditCarDisplayTypeList
    if {[catch [list set EditCarDisplayTypeList("type,$type")] index]} {
      $theframe.values.type configure -text [lindex [$theframe.values.type cget -values] 0]
    } else {
      $theframe.values.type configure -text [lindex [$theframe.values.type cget -values] $index]
    }
    $theframe.values.plate configure -text [Car_Plate $car]
    $theframe.values.class configure -text [Car_WeightClass $car]
    $theframe.values.ltwt  configure -text [Car_LtWt $car]
    $theframe.values.ldlmt configure -text [Car_LdLmt $car]
    if {[Car_LoadedP $car]} {
      $theframe.values.status configure -text Loaded
    } else {
      $theframe.values.status configure -text Empty
    }
    if {[Car_FixedRouteP $car]} {
      $theframe.values.fixedP configure -text Yes
    } else {
      $theframe.values.fixedP configure -text No
    }
    if {[Car_OkToMirrorP $car]} {
      $theframe.values.mirrorP configure -text Yes
    } else {
      $theframe.values.mirrorP configure -text No
    }
    set owner [Car_CarOwner $car]
    if {![string equal "$owner" {NULL}]} {
      $theframe.values.owner   configure -text "[Owner_Initials $owner]"
    }
    set dest [Car_Destination $car]
    set loc  [Car_Location $car]
    if {[catch [list set EditCarDisplayIndustryList(industry,$dest)] destIndex]} {
      set destIndex $EditCarDisplayIndustryList(industry,[TheSystem IndScrapYard])
    }
    if {[catch [list set EditCarDisplayIndustryList(industry,$loc)] locIndex]} {
      set locIndex $EditCarDisplayIndustryList(industry,[TheSystem IndScrapYard])
    }
    $theframe.values.loc  configure -text [lindex [$theframe.values.loc cget -values]  $locIndex]
    $theframe.values.dest configure -text [lindex [$theframe.values.dest cget -values] $destIndex]
  }
}
    
    

proc ViewCar {} {
  set carIndex [SearchForCar]
  if {$carIndex < 0} {return}
  set car [TheSystem TheCar $carIndex]
  global Main
  set theframe [$Main slideout getframe ViewCarDisplay]
  FillInViewCarDisplayValues $car
  $theframe.buttons itemconfigure action \
	-text "OK" \
	-command "$theframe.buttons invoke cancel"
  $Main slideout show ViewCarDisplay
}

proc EditCar {} {
  set carIndex [SearchForCar]
  if {$carIndex < 0} {return}
  set car [TheSystem TheCar $carIndex]
  global Main
  set theframe [$Main slideout getframe EditCarDisplay]
  FillInEditCarDisplayValues $car
  $theframe.buttons itemconfigure action \
	-text "Update Car" \
	-command "EditCarHelper $car"
  $Main slideout show EditCarDisplay
}

proc EditCarHelper {car} {
  global Main

  set theframe [$Main slideout getframe EditCarDisplay]
  set typeDescr "[$theframe.values.type cget -text]"
  global EditCarDisplayTypeList
  if {[catch [list set EditCarDisplayTypeList("lb,$typeDescr")] type]} {
    tk_messageBox -icon warning -type ok -message "Please select a car type"
    return
  }
  global EditCarDisplayIndustryList
  set destLabel "[$theframe.values.dest cget -text]"
  if {[catch [list set EditCarDisplayIndustryList("lb,$destLabel")] dest]} {
    set dest NULL
  }
  set locLabel "[$theframe.values.loc cget -text]"
  if {[catch [list set EditCarDisplayIndustryList("lb,$locLabel")] loc]} {
    tk_messageBox -icon warning -type ok -message "Please select a car location"
    return
  }
  Car_SetMarks  $car "[$theframe.values.rr     cget -text]"
  Car_SetNumber $car "[$theframe.values.number cget -text]"
  Car_SetDivisions $car "[$theframe.values.hdiv cget -text]"
  Car_SetLength $car [$theframe.values.length cget -text]
  Car_SetType $car "$type"
  Car_SetPlate $car [$theframe.values.plate cget -text]
  Car_SetWeightClass $car [$theframe.values.class cget -text]
  Car_SetLtWt $car [$theframe.values.ltwt cget -text]
  Car_SetLdLmt $car [$theframe.values.ldlmt cget -text]
  set status [$theframe.values.status cget -text]
  switch $status {
    Empty {Car_UnLoad $car}
    Loaded {Car_Load $car}
  }
  switch [$theframe.values.fixedP cget -text] {
    Yes {Car_SetFixedRouteP $car 1}
    No  {Car_SetFixedRouteP $car 0}
  }
  switch [$theframe.values.mirrorP cget -text] {
    Yes {Car_SetOkToMirrorP $car 1}
    No  {Car_SetOkToMirrorP $car 0}
  }
  set ownerInitials "[$theframe.values.owner   cget -text]"
  set owner [TheSystem TheOwner "$ownerInitials"]
  if {[string equal "$owner" {NULL}]} {
     TheSystem AddOwner "$ownerInitials"
     set owner [TheSystem TheOwner "$ownerInitials"]
  }
  Car_SetCarOwner $car $owner
  Car_SetDestination $car $dest
  Car_SetLocation $car $loc
  $theframe.buttons invoke cancel
}

proc AddNewCar {} {
  global Main
  FillInEditCarDisplayValues {}
  set theframe [$Main slideout getframe EditCarDisplay]
  $theframe.buttons itemconfigure action \
	-text "Add New Car" \
	-command "AddCarHelper"
  $Main slideout show EditCarDisplay
}

proc AddCarHelper {} {
  global Main
  set theframe [$Main slideout getframe EditCarDisplay]
  set typeDescr "[$theframe.values.type cget -text]"
#  puts stderr "*** AddCarHelper: typeDescr = $typeDescr"
  global EditCarDisplayTypeList
  set type {,}
  if {[catch [list set EditCarDisplayTypeList("lb,$typeDescr")] type]} {
    tk_messageBox -icon warning -type ok -message "Please select a car type"
    return
  }
  if {[string equal "$type" {?}] || [string equal "$type" {,}]} {
    tk_messageBox -icon warning -type ok -message "Please select a car type"
    return
  }
#  puts stderr "*** AddCarHelper: type = $type"
  global EditCarDisplayIndustryList
  set destLabel "[$theframe.values.dest cget -text]"
#  puts stderr "*** AddCarHelper: destLabel = $destLabel"
  if {[catch [list set EditCarDisplayIndustryList("lb,$destLabel")] dest]} {
    set dest NULL
  }
#  puts stderr "*** AddCarHelper: dest = $dest"
  if {![string equal "$dest" {NULL}]} {
#    puts stderr "*** AddCarHelper: dest name is [Industry_Name $dest]"
    set station [Industry_MyStation $dest]
#    puts stderr "*** AddCarHelper: dest station is $station"
    if {[string equal "$station" {NULL}]} {
      set dest NULL
    } else {
#      puts stderr "*** AddCarHelper: dest station name is [Station_Name $station]"
    }
  }
  set locLabel "[$theframe.values.loc cget -text]"
#  puts stderr "*** AddCarHelper: locLabel = $locLabel"
  if {[catch [list set EditCarDisplayIndustryList("lb,$locLabel")] loc]} {
    tk_messageBox -icon warning -type ok -message "Please select a car location"
    return
  }
#  puts stderr "*** AddCarHelper: loc = $loc"
  if {![string equal "$loc" {NULL}]} {
#    puts stderr "*** AddCarHelper: loc name is [Industry_Name $loc]"
    set station [Industry_MyStation $loc]
#    puts stderr "*** AddCarHelper: loc station is $station"
    if {[string equal "$station" {NULL}]} {
      tk_messageBox -icon warning -type ok -message "Please select a car location"
      return
    } else {
#      puts stderr "*** AddCarHelper: loc station name is [Station_Name $station]"
    }
  }
  set marks [string trim "[$theframe.values.rr     cget -text]"]
  set number [string trim "[$theframe.values.number cget -text]"]
  if {[string length "$marks"] == 0 || [string length "$number"] == 0} {
    tk_messageBox -icon warning -type ok -message "Please set the reporting marks and car number first"
    return
  }
  set divisions [string trim "[$theframe.values.hdiv cget -text]"]
  set length [$theframe.values.length cget -text]
  set plate [$theframe.values.plate cget -text]
  set weightclass [$theframe.values.class cget -text]
  set lw [$theframe.values.ltwt cget -text]
  set ldw [$theframe.values.ldlmt cget -text]
  switch [$theframe.values.status cget -text] {
    Empty {set lp 0}
    Loaded {set lp 1}
  }
  switch [$theframe.values.fixedP cget -text] {
    Yes {set fp 1}
    No  {set fp 0}
  }
  switch [$theframe.values.mirrorP cget -text] {
    Yes {set mp 1}
    No  {set mp 0}
  }
  set ownerInitials "[$theframe.values.owner   cget -text]"
  set owner [TheSystem TheOwner "$ownerInitials"]
  if {[string equal "$owner" {NULL}]} {
     TheSystem AddOwner "$ownerInitials"
     set owner [TheSystem TheOwner "$ownerInitials"]
  }
  set car [new_Car "$type" "$marks" "$number" "$divisions" $length $plate \
		    $weightclass $lw $ldw $lp $mp $fp $owner 0 NULL 0 $loc $dest \
		    0 0]
  TheSystem AddCar $car
  $theframe.buttons invoke cancel
}

proc DeleteCar {} {
  set carIndex [SearchForCar]
  if {$carIndex < 0} {return}
  set car [TheSystem TheCar $carIndex]
  global Main
  set theframe [$Main slideout getframe ViewCarDisplay]
  FillInViewCarDisplayValues $car
  $theframe.buttons itemconfigure action \
	-text "Delete Car" \
	-command "DeleteCarHelper $car"
  $Main slideout show ViewCarDisplay
}

proc DeleteCarHelper {car} {
  global Main
  set theframe [$Main slideout getframe ViewCarDisplay]
  Car_SetDestination $car [TheSystem IndScrapYard]
  $theframe.buttons invoke cancel
}

proc ShowUnassignedCars {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
#  puts stderr "*** ShowUnassignedCars: Log cget -this = [Log cget -this]"
  TheSystem ShowUnassignedCars [Log cget -this] [Banner cget -this]
}

proc AssignCars {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem CarAssignment [WIP cget -this] [Log cget -this] [Banner cget -this]
  TheSystem RestartLoop
}

proc CreateShowCarsMenu {main buttonname} {
  global FCFTrainsLoaded FCFIndustriesLoaded FCFDivisionsLoaded
  set m [menu $main.${buttonname}_menu -title {Show Cars Menu}]
  $main buttons itemconfigure $buttonname -command [list PostMenuOnPointer $m $main]
  $m add command -label {Show Cars NOT Moved} -accelerator N \
		 -under [string first N {Show Cars NOT Moved}] \
		 -command ShowCarsNotMoved
  $m add command -label {Show Car Movements} -accelerator M \
		 -under [string first M {Show Car Movemens}] \
		 -command ShowCarMovements
  if {$FCFTrainsLoaded} {
    $m add command -label {Show Car Movements by Train} -accelerator T \
		 -under [string first T {Show Car Movements by Train}] \
		 -command ShowCarMovementsByTrain
  }
  if {$FCFIndustriesLoaded} {
    $m add command -label {Show Car Movements by Location} -accelerator L \
		 -under [string first L {Show Car Movements by Location}] \
		 -command ShowCarMovementsByLocation
  }
  $m add command -label {Show Cars Moved and NOT Moved} -accelerator E \
		 -under [string first e {Show Cars Moved and NOT Moved}] \
		 -command ShowCarsMovedAndNotMoved
  if {0} {
    $m add command -label {Compile Car Movements} -accelerator C \
	 -under 0 \
	 -command CompileCarMovements
  }
  if {$FCFDivisionsLoaded} {
    $m add command -label {Show Cars In Division} -accelerator D \
		 -under [string first D {Show Cars In Division}] \
		 -command ShowCarsInDivision
  }
  if {$FCFTrainsLoaded} {
    $m add command -label {Show Train Totals} -accelerator A \
		 -under [string first a {Show Train Totals}] \
		 -command ShowTrainTotals
  }
#  $m add command -label {Mark ALL Cars In Use} -accelerator U \
#		 -under [string first U {Mark ALL Cars In Use}] \
#		 -command MarkAllCarsInUse
  if {$FCFTrainsLoaded} {
    $m add command -label {List Train Names} -accelerator ? \
		 -command ListTrainNames
    bind $m <question> {UnPostMenu %W;ListTrainNames}
    $m add command -label {Show One Train's Cars} -accelerator 1 \
		 -command ShowTrainCars
    bind $m 1 {UnPostMenu %W;ShowTrainCars}
  }
  bind $m <Escape> {UnPostMenu %W;break}
  return $m
}



proc CreateCarDisplay {} {
#  puts stderr "*** CreateCarDisplay"
  global Main ImageDir
  set theframe [$Main slideout add ViewCarDisplay]
  set viewLabel [$Main mainframe addindicator -relief sunken -borderwidth 4 \
			-image ViewCarImage]
  bind $theframe <Map> [list $viewLabel configure -relief raised]
  bind $theframe <Unmap> [list $viewLabel configure -relief sunken]
  frame $theframe.values -borderwidth 0
  pack $theframe.values -expand yes -fill both
  LabelEntry $theframe.values.rr \
	-label "Railroad:" -side left -editable no -entrybg white
  pack $theframe.values.rr -fill x
  LabelEntry $theframe.values.number \
	-label "Car Number:" -side left -editable no -entrybg white
  pack $theframe.values.number -fill x
  LabelEntry $theframe.values.hdiv \
	-label "Home Divisions:" -side left -editable no -entrybg white
  pack $theframe.values.hdiv -fill x
  LabelEntry $theframe.values.length \
	-label "Car Length" -side left  -editable no -entrybg white
  pack $theframe.values.length -fill x
  LabelEntry $theframe.values.type \
	-label "Type:" -side left -editable no -entrybg white
  pack $theframe.values.type -fill x
  LabelEntry $theframe.values.plate \
	-label "Clearance" -side left -editable no -entrybg white
  pack  $theframe.values.plate -fill x
  LabelEntry $theframe.values.class \
	-label "Weight Class" -side left -editable no -entrybg white
  pack  $theframe.values.class -fill x
  LabelEntry $theframe.values.ltwt \
	-label "Empty Weight" -side left -editable no -entrybg white
  pack  $theframe.values.ltwt -fill x
  LabelEntry $theframe.values.ldlmt \
	-label "Loaded Weight" -side left -editable no -entrybg white
  pack  $theframe.values.ldlmt -fill x
  LabelEntry $theframe.values.status \
	-label "Car is:" -side left -editable no -entrybg white
  pack $theframe.values.status -fill x
  LabelEntry $theframe.values.assigns \
	-label "Assignments" -side left -editable no -entrybg white
  pack $theframe.values.assigns -fill x
  LabelEntry $theframe.values.fixedP \
	-label "Fixed Route" -side left -editable no -entrybg white
  pack $theframe.values.fixedP -fill x
  LabelEntry $theframe.values.mirrorP \
	-label "Ok to Mirror" -side left -editable no -entrybg white
  pack $theframe.values.mirrorP -fill x
  LabelEntry $theframe.values.owner \
	-label "Owner initials" -side left -editable no -entrybg white
  pack $theframe.values.owner -fill x
  LabelEntry $theframe.values.dest \
	-label "Destination" -side left -editable no -entrybg white
  pack $theframe.values.dest  -fill x
  LabelEntry $theframe.values.loc \
	-label "Location" -side left -editable no -entrybg white
  pack $theframe.values.loc -fill x
  ButtonBox $theframe.buttons -orient horizontal
  pack $theframe.buttons -expand yes -fill both
  $theframe.buttons add -name action -text "Action"
  $theframe.buttons add -name cancel -text "Cancel"\
	-command {
		global Main
		$Main slideout hide ViewCarDisplay
	}
  update idle

  set theframe [$Main slideout add EditCarDisplay]
  set editLabel [$Main mainframe addindicator -relief sunken -borderwidth 4 \
			-image EditCarImage]
  bind $theframe <Map> [list $editLabel configure -relief raised]
  bind $theframe <Unmap> [list $editLabel configure -relief sunken]
  frame $theframe.values -borderwidth 0
  pack $theframe.values -expand yes -fill both
  LabelEntry $theframe.values.rr \
	-label "Railroad:" -side left 
  pack $theframe.values.rr -fill x
  LabelEntry $theframe.values.number \
	-label "Car Number:" -side left
  pack $theframe.values.number -fill x
  LabelEntry $theframe.values.hdiv \
	-label "Home Divisions:" -side left
  pack $theframe.values.hdiv -fill x
  LabelSpinBox $theframe.values.length \
	-label "Car Length" -side left \
	-range [list 20 1000 10]
  pack $theframe.values.length -fill x
  LabelComboBox $theframe.values.type \
	-label "Type:" -side left -editable no -bwlistbox yes
  pack $theframe.values.type -fill x
  LabelSpinBox $theframe.values.plate \
	-label "Clearance" -side left \
	-range [list 1 10 1]
  pack  $theframe.values.plate -fill x
  LabelSpinBox $theframe.values.class \
	-label "Weight Class" -side left \
	-range [list 1 10 1]
  pack  $theframe.values.class -fill x
  LabelSpinBox $theframe.values.ltwt \
	-label "Empty Weight" -side left \
	-range [list 20 100 20]
  pack  $theframe.values.ltwt -fill x
  LabelSpinBox $theframe.values.ldlmt \
	-label "Loaded Weight" -side left \
	-range [list 20 1000 20]
  pack  $theframe.values.ldlmt -fill x
  LabelComboBox $theframe.values.status -editable no \
	-label "Car is:" -side left -values [list Empty Loaded]
  pack $theframe.values.status -fill x
  LabelComboBox $theframe.values.fixedP -editable no \
	-label "Fixed Route" -side left -values [list Yes No]
  pack $theframe.values.fixedP -fill x
  LabelComboBox $theframe.values.mirrorP -editable no \
	-label "Ok to Mirror" -side left -values [list Yes No]
  pack $theframe.values.mirrorP -fill x
  LabelEntry $theframe.values.owner \
	-label "Owner initials" -side left
  pack $theframe.values.owner -fill x
  LabelComboBox $theframe.values.dest \
	-label "Destination" -side left -editable no -bwlistbox yes
  pack $theframe.values.dest  -fill x
  LabelComboBox $theframe.values.loc \
	-label "Location" -side left -editable no -bwlistbox yes
  pack $theframe.values.loc -fill x
  ButtonBox $theframe.buttons -orient horizontal
  pack $theframe.buttons -expand yes -fill both
  $theframe.buttons add -name action -text "Action"
  $theframe.buttons add -name cancel -text "Cancel"\
	-command {
		global Main
		$Main slideout hide EditCarDisplay
	}
  update idle
}

proc UpdateCarDisplayOptionMenus {} {
  global Main CarType_MaxCarTypes EditCarDisplayTypeList
  catch {unset EditCarDisplayTypeList}
  set list {}
  set index -1
  for {set icarType 0} {$icarType < $CarType_MaxCarTypes} {incr icarType} {
    set type [TheSystem CarTypesOrder $icarType]
    if {[string equal "$type" {,}]} {continue}
    set carType [TheSystem TheCarType "$type"]
    if {[string equal "$carType" {NULL}]} {continue}
    set typeDescr "[CarType_Type $carType]"
#    puts stderr "*** UpdateCarDisplayOptionMenus: icarType = $icarType, type = $type, typeDescr = $typeDescr"
    lappend list "$typeDescr"
    incr index
    set EditCarDisplayTypeList("lb,$typeDescr") "$type"
    set EditCarDisplayTypeList("type,$type") $index
  }
  
  [$Main slideout getframe EditCarDisplay].values.type configure -values $list

  global EditCarDisplayIndustryList
  catch {unset EditCarDisplayIndustryList}
  set list {}
  set index -1
  foreach indIndex [TheSystem IndustryIndexList] {
    set ind [TheSystem TheIndustry $indIndex]
    if {[string equal "$ind" {NULL}]} {continue}
    set indName "[Industry_Name $ind]"
    set station [Industry_MyStation $ind]
    if {[string equal "$station" {NULL}]} {continue}
    set stationName "[Station_Name $station]"
    set label [format {%s at %s} "$indName" "$stationName"]
    incr index
    lappend list "$label"
    set EditCarDisplayIndustryList("lb,$label") $ind
    set EditCarDisplayIndustryList(industry,$ind) $index
  }
  set label "Scrap Yard"
  incr index
  lappend list "$label"
  set EditCarDisplayIndustryList("lb,$label") [TheSystem IndScrapYard]
  set EditCarDisplayIndustryList(industry,[TheSystem IndScrapYard]) $index
  set label "RIP Track"
  incr index
  lappend list "$label"
  set EditCarDisplayIndustryList("lb,$label") [TheSystem IndRipTrack]
  set EditCarDisplayIndustryList(industry,[TheSystem IndRipTrack]) $index
  [$Main slideout getframe EditCarDisplay].values.loc  configure -values "$list"
  [$Main slideout getframe EditCarDisplay].values.dest configure -values "$list"
}

proc ShowCarsNotMoved {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem ShowCarsNotMoved [Log cget -this] [Banner cget -this]
}

proc ShowCarMovements {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem ShowCarMovements 0 NULL NULL [Log cget -this] [Banner cget -this]
}

proc ShowCarMovementsByLocation {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  set location [SelectAnIndustry {Movements}]
  if {[string equal "$location" {NULL}]} {return}
  TheSystem ShowCarMovements 1 $location NULL [Log cget -this] [Banner cget -this]
}

proc ShowCarsMovedAndNotMoved {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  TheSystem ShowCarMovements 1 NULL NULL [Log cget -this] [Banner cget -this]
}

#proc CompileCarMovements {} {
#  if {[llength [info commands TheSystem]] == 0} {
#    tk_messageBox -icon error -type ok -message "Please load a system first"
#    return
#  }
#  TheSystem CompileCarMovements [Log cget -this] [Banner cget -this]
#}

#proc MarkAllCarsInUse {} {
#}

proc ShowCarsInDivision {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message "Please load a system first"
    return
  }
  set division [SelectADivision {Movements}]
  if {[string equal "$division" {NULL}]} {return}
  TheSystem ShowCarsInDivision $division [Log cget -this] [Banner cget -this]
}

package provide FCFCars 1.0
