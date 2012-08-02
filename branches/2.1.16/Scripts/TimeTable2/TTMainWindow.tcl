#* 
#* ------------------------------------------------------------------
#* TTMainWindow.tcl - Time Table Main window display widgets.
#* Created by Robert Heller on Mon Dec 26 14:58:13 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.6  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.5  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.4  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.3  2006/03/06 18:46:21  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:25  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2006/01/03 15:30:22  heller
#* Modification History: Lockdown
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
package require BWStdMenuBar
package require DWpanedw
package require BWHelp
package require MainWindow

catch {SplashWorkMessage {Creating Main Window} 11}

namespace eval ChartDisplay {
  Widget::define ChartDisplay TTMainWindow

  Widget::declare ChartDisplay {
        {-width             Int        0  0 {%d > 0}}
        {-height            Int        0  0 {%d > 0}}
        {-xscrollcommand    TkResource "" 0 canvas}
        {-yscrollcommand    TkResource "" 0 canvas}
        {-xscrollincrement  TkResource "" 0 canvas}
        {-yscrollincrement  TkResource "" 0 canvas}
	{-timescale         Int        1440 0 {%d >= 60 && %d <= 1440}}
	{-timeinterval	    Int	       15   0 {%d >= 1  && %d <= 60}}
	{-labelsize 	    Int	       100  0 {%d > 0}}
   }

    Widget::addmap ChartDisplay "" :cmd {
        -width {} -height {} 
        -xscrollcommand {} -yscrollcommand {}
        -xscrollincrement {} -yscrollincrement {}
    }

    bind BwChartDisplay <Destroy>   [list Widget::destroy %W]
}

proc ChartDisplay::create { path args } {
  Widget::init ChartDisplay $path $args

  Widget::getVariable $path data
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set numIncrs [expr {int((double($timescale)+($timeinterval-1)) / double($timeinterval))}]
  set cwidth [expr {($numIncrs * 20) + [Widget::getoption $path -labelsize] + 20}]
  set canvas [eval [list canvas $path] [Widget::subcget $path :cmd] \
	-background white -borderwidth 0 -highlightthickness 0 -relief flat]
  $canvas configure -scrollregion [list 0 0 $cwidth 20]
  set lab [$canvas create text 0 0 -text "T"]
  set data(lheight) [expr {1.5 * [lindex [$canvas bbox $lab] 3]}]
  $canvas delete $lab

  bindtags $path [list $path BwChartDisplay [winfo toplevel $path] all]
  return [Widget::create ChartDisplay $path]
}

proc ChartDisplay::configure { path args } {
  return [Widget::configure $path $args]
}

proc ChartDisplay::cget { path option } {
  return [Widget::cget $path $option]
}

# ----------------------------------------------------------------------------
#  Command ChartDisplay::xview
# ----------------------------------------------------------------------------
proc ChartDisplay::xview { path args } {
    return [eval [list $path:cmd xview] $args]
}


# ----------------------------------------------------------------------------
#  Command ChartDisplay::yview
# ----------------------------------------------------------------------------
proc ChartDisplay::yview { path args } {
    return [eval [list $path:cmd yview] $args]
}

proc ChartDisplay::deleteWholeChart { path } {
  $path:cmd delete all
  Widget::getVariable $path data
  set lheight $data(lheight)
  array unset data
  set data(lheight) $lheight
}

proc ChartDisplay::_buildTimeLine { path } {
  Widget::getVariable $path data

  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set numIncrs [expr {int((double($timescale)+($timeinterval-1)) / double($timeinterval))}]
  set cwidth [expr {($numIncrs * 20) + [Widget::getoption $path -labelsize] + 20}]
  set scrollWidth $cwidth
  set canvas $path:cmd
  set topOff 0
  set labelsize [Widget::getoption $path -labelsize]
  for {set m 0} {$m <= $timescale} {incr m 60} { 
    set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0)) + 4}]
    $canvas create text $mx 0 -anchor n \
	-text [format {%2d} [expr {$m / 60}]] -tag TimeLine
  }
  set scrollHeight [lindex [$canvas bbox TimeLine] 3]
  $canvas configure -scrollregion [list 0 0 $scrollWidth $scrollHeight]  
}

proc ChartDisplay::_buildCabs { path } {
  Widget::getVariable $path data
  set canvas $path:cmd
  $canvas delete Cabs
  set topOff [lindex [$canvas bbox TimeLine] 3]
  set data(topofcabs) [expr {$topOff + 10}]
  set data(cabheight) 0
  set data(topofcabs) [expr {$topOff + 10}]
  set data(bottomofcabs) $data(topofcabs)
  set data(numberofcabs) 0
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]
  for {set m 0} {$m <= $timescale} {incr m $timeinterval} {
    set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0))}]
    set lw 1
    if {[expr {$m % 60}] == 0} {set lw 2}
    $canvas create line $mx $data(topofcabs) $mx $data(bottomofcabs) -width $lw -tag [list Cabs Cabs:Tick]
  }
  set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
  $canvas create line $labelsize $data(topofcabs) $r $data(topofcabs) -width 2 -tag [list Cabs Cabs:Hline]
  $canvas create line $labelsize $data(bottomofcabs) $r $data(bottomofcabs) -width 2 -tag [list Cabs Cabs:Bline]
  array unset data "cab,*,y"
}
	

proc ChartDisplay::addACab { path cab } {
  Widget::getVariable $path data
  set canvas $path:cmd
  if {$data(numberofcabs) == 0} {
    set data(numberofcabs) 1
    set data(cabheight) [expr {(2 * $data(lheight)) + 20}]
    set data(bottomofcabs) [expr {$data(topofcabs) + $data(cabheight)}]
    set cabyoff [expr {$data(lheight) * 1.75}]
  } else {
    incr data(numberofcabs)
    set data(cabheight) [expr {$data(cabheight) + $data(lheight)}]
    set data(bottomofcabs) [expr {$data(bottomofcabs) + $data(lheight)}]
    set cabyoff [expr {$data(lheight) * ($data(numberofcabs) + .75)}]
  }
  _updateChart $path
  _updateStorageTracks $path
  _updateCabs $path
  set cabName [Cab_Name $cab]
  set cabColor [Cab_Color $cab]
  $canvas create text 0 [expr {$cabyoff + $data(topofcabs)}] -text "$cabName" -fill "$cabColor" -tag [list Cabs "Cabs:Name:$cabName"] -anchor w
  set data("cab,$cabName,y") [expr {$cabyoff + $data(topofcabs)}]
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]
  set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
  $canvas create line $labelsize $data("cab,$cabName,y") $r $data("cab,$cabName,y")  -tag [list Cabs "Cabs:Line:$cabName"] -width 4 -fill "$cabColor" -stipple gray50
}

proc ChartDisplay::_buildChart { path } {
  Widget::getVariable $path data
  set canvas $path:cmd
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  $canvas delete Chart
  set topOff [lindex [$canvas bbox Cabs] 3]
  set data(topofchart) [expr {$topOff + 10}]
  set data(chartheight) 0
  set data(bottomofchart) $data(topofchart)
  set data(totallength) 0
#  puts stderr "*** chartDisplay:buildChart: data(topofchart) = $data(topofchart)"
  for {set m 0} {$m <= $timescale} {incr m $timeinterval} {
    set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0))}]
    set lw 1
    if {[expr {$m % 60}] == 0} {set lw 2}
    $canvas create line $mx $data(topofchart) $mx $data(bottomofchart) -width $lw -tag [list Chart Chart:Tick]
  }
  set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
  $canvas create line $labelsize $data(topofchart) $r $data(topofchart) -width 2 -tag [list Chart Chart:Hline]
  $canvas create line $labelsize $data(bottomofchart) $r $data(bottomofchart) -width 2 -tag [list Chart Chart:Bline]
  set data(chartstationoffset) $data(topofchart)
}

proc ChartDisplay::_buildStorageTracks { path } {
  Widget::getVariable $path data
  set canvas $path:cmd
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  $canvas delete Storage
  set topOff [lindex [$canvas bbox Chart] 3]
  set data(topofstorage) [expr {$topOff + 10}]
  set data(storagetrackheight) 0
  set data(bottomofstorage) $data(topofstorage)
  set data(numberofstoragetracks) 0
#  puts stderr "*** chartDisplay:buildStorageTracks: data(topofstorage) = $data(topofstorage)"
  for {set m 0} {$m <= $timescale} {incr m $timeinterval} {
    set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0))}]
    set lw 1
    if {[expr {$m % 60}] == 0} {set lw 2}
    $canvas create line $mx $data(topofstorage) $mx $data(bottomofstorage) -width $lw -tag [list Storage Storage:Tick]
  }
  set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
  $canvas create line $labelsize $data(topofstorage) $r $data(topofstorage) -width 2 -tag [list Storage Storage:Hline]
  $canvas create line $labelsize $data(bottomofstorage) $r $data(bottomofstorage) -width 2 -tag [list Storage Storage:Bline]
  array unset data "storage,*:*,y"
  set data(storageoffset) $data(topofstorage)
}

proc ChartDisplay::addAStation { path station sindex } {
  Widget::getVariable $path data
  set canvas $path:cmd
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  set name  [Station_Name  $station]
  set smile [Station_SMile $station]
  if {$smile > $data(totallength)} {
    set data(totallength) $smile
  }
  _updateChart $path
  _updateStorageTracks $path
#  puts stderr "*** chartDisplay:addAStation: data(topofchart) = $data(topofchart)"
  set offset [expr {$data(topofchart) + 20.0}]
  set data(station,$sindex,y) [expr {$offset + ($smile * 20)}]
  set data(station,$sindex,smile) $smile
  set sl [$canvas create text 0 $data(station,$sindex,y) -text "$name" -tag [list Chart Station Station:$sindex] -anchor w]
  while {[expr {[lindex [$canvas bbox $sl] 2] + 5}] > $labelsize} {
#    puts stderr "*** chartDisplay:addAStation: name = $name, $canvas bbox $sl = [$canvas bbox $sl]"
    $canvas delete $sl
    set name [string range "$name" 0 [expr {[string length "$name"] - 2}]]
    set sl [$canvas create text 0 $data(station,$sindex,y) -text "$name" -tag [list Chart Station Station:$sindex] -anchor w]
  }
  $canvas create rect [$canvas bbox Station:$sindex] -fill white -outline black -tag [list Chart Station Station:namebox:$sindex]
  $canvas lower Station:namebox:$sindex Station:$sindex
  set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
  $canvas create line $labelsize $data(station,$sindex,y) $r $data(station,$sindex,y)  -tag [list Chart Station Station:Line:$sindex] -width 2 -fill gray50
  $canvas bind Station:namebox:$sindex <1> [list displayOneStation draw -station $station]
  $canvas bind Station:line:$sindex <1> [list displayOneStation draw -station $station]
  $canvas bind Station:$sindex <1> [list displayOneStation draw -station $station]
  ForEveryStorageTrack $station storage {
    addAStorageTrack $path $station $storage
  }
}

proc ChartDisplay::addAStorageTrack { path station track } {
  Widget::getVariable $path data
  set canvas $path:cmd
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  set topOff [lindex [$canvas bbox Chart] 3]
  set data(topofstorage) [expr {$topOff + 10}]
  if {$data(numberofstoragetracks) == 0} {
    set data(numberofstoragetracks) 1
    set data(storagetrackheight) [expr {(2 * $data(lheight)) + 20}]
    set data(bottomofstorage) [expr {$data(topofstorage) + $data(storagetrackheight)}]
    set storageyoff [expr {$data(lheight) * 1.75}]
  } else {
    incr data(numberofstoragetracks)
    set data(storagetrackheight) [expr {$data(storagetrackheight) + $data(lheight)}]
    set data(bottomofstorage) [expr {$data(bottomofstorage) + $data(lheight)}]
    set storageyoff [expr {$data(lheight) * ($data(numberofstoragetracks) + .75)}]
  }
  _updateStorageTracks $path
  set stationName [Station_Name $station]
  set trackName   [StorageTrack_Name $track]
  set nameOnChart [_formNameOnChart $path "$stationName" "$trackName"]
  set data("storage,${stationName}:${trackName},y") [expr {$storageyoff + $data(topofstorage)}]
  $canvas create text 0 $data("storage,${stationName}:${trackName},y") -text "$nameOnChart" -tag [list Storage Storage:track "Storage:${stationName}:${trackName}"] -anchor w
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]
  set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
  $canvas create line $labelsize $data("storage,${stationName}:${trackName},y") $r $data("storage,${stationName}:${trackName},y")  -tag [list Storage Storage:track "Storage:${stationName}:${trackName}"] -width 4 -stipple gray50
}

proc ChartDisplay::_formNameOnChart {path sn tn} {
#  puts stderr "*** ChartDisplay::_formNameOnChart $path $sn $tn"
  Widget::getVariable $path data
  set canvas $path:cmd
  set labelsize [Widget::getoption $path -labelsize]
#  puts stderr "*** ChartDisplay::_formNameOnChart: labelsize = $labelsize"

  set i [$canvas create text 0 0 -anchor w -text "${sn}:${tn}"]
  set l1 [lindex [$canvas bbox $i] 2]
  $canvas delete $i
#  puts stderr "*** ChartDisplay::_formNameOnChart: l1 = $l1 (${sn}:${tn})"
  set i [$canvas create text 0 0 -anchor w -text "${sn}:"]
  set l2 [lindex [$canvas bbox $i] 2]
  $canvas delete $i
#  puts stderr "*** ChartDisplay::_formNameOnChart: l2 = $l2 (${sn}:)"
  set i [$canvas create text 0 0 -anchor w -text "$tn"]
  set l3 [lindex [$canvas bbox $i] 2]
#  puts stderr "*** ChartDisplay::_formNameOnChart: l3 = $l3 ($tn)"
  $canvas delete $i
  while {$l1 > $labelsize && $l2 > [expr {$labelsize / 2.0}]} {
    set sn [string trim [string range "$sn" 0 "end-1"]]
    set i [$canvas create text 0 0 -anchor w -text "${sn}:${tn}"]
    set l1 [lindex [$canvas bbox $i] 2]
    $canvas delete $i
#    puts stderr "*** ChartDisplay::_formNameOnChart: l1 = $l1 (${sn}:${tn})"
    set i [$canvas create text 0 0 -anchor w -text "${sn}:"] 
    set l2 [lindex [$canvas bbox $i] 2]
    $canvas delete $i
#    puts stderr "*** ChartDisplay::_formNameOnChart: l2 = $l2 (${sn}:)"
  }
  while {$l1 > $labelsize} {
    set tn [string trim [string range "$tn" 0 "end-1"]]
    set i [$canvas create text 0 0 -anchor w -text "${sn}:${tn}"]
    set l1 [lindex [$canvas bbox $i] 2]
    $canvas delete $i
#    puts stderr "*** ChartDisplay::_formNameOnChart: l1 = $l1 (${sn}:${tn})"
  }
  return "${sn}:${tn}"
}

proc ChartDisplay::addATrain { path timetable train} {
  Widget::getVariable $path data
  set canvas $path:cmd
  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]
  set lastX  [expr {$labelsize + ((double($timescale) / double($timeinterval) * 20.0)) + 4}]
  set firstX [expr {$labelsize + 4}]

  set timeX -1
  set stationY -1
  set rStationY -1
  set color {}
  set cabName {}
  set departure [Train_Departure $train]
  set oldDepart -1
  set oldSmile -1
  set speed  [Train_Speed $train]
  set trtags [list Chart Chart:Train "Chart:Train:[Train_Number $train]" "Train:[Train_Number $train]"]
  set cabtags [list Cabs Cabs:Train "Cabs:Train:[Train_Number $train]" "Train:[Train_Number $train]"]
  set stortags [list Storage Storage:track Storage:Train "Storage:Train:[Train_Number $train]" "Train:[Train_Number $train]"]
  ForEveryStop $train stop {
    set sindex [Stop_StationIndex $stop]
    set station [TimeTableSystem_IthStation $timetable $sindex]
    set smile [Station_SMile $station]
    set rSindex [Station_DuplicateStationIndex $station]
    if {$rSindex < 0} {
      set rStation NULL
      set rsmile -1
      set newRStationY -1
    } else {
      set rStation [TimeTableSystem_IthStation $timetable $rSindex]
      set rsmile [Station_SMile $rStation]
      set newRStationY $data(station,$rSindex,y)
    }
    set departcab [Stop_TheCab $stop]
#    puts stderr "*** chartDisplay:addATrain: departcab = $departcab"
    if {![string equal $departcab NULL]} {
      set newColor "[Cab_Color $departcab]"
      set newCabName "[Cab_Name $departcab]"
    } else {
      set newColor black
      set newCabName {}
    }
    set newStationY $data(station,$sindex,y)
    if {$oldDepart >= 0} {
#      puts stderr "*** chartDisplay:addATrain: smile = $smile, oldSmile = $oldSmile, abs($smile - $oldSmile) = [expr {abs($smile - $oldSmile)}], speed = $speed, speed/60 = [expr {double($speed) / 60.0}]"
      set arrival [expr {$oldDepart + (abs($smile - $oldSmile) * (double($speed) / 60.0))}]
    } else {
      set arrival $departure
    }
#    puts stderr "*** ChartDisplay::addATrain: ------------------------------------------"
#    puts stderr "*** ChartDisplay::addATrain: Station is [Station_Name $station], Train is [Train_Number $train]"
    switch -exact -- [Stop_Flag $stop] {
      Origin {
	set storage [Station_FindTrackTrainIsStoredOn $station \
					"[Train_Number $train]" \
					$departure $departure]
        if {![string equal $rStation NULL]} {
	  set rstorage [Station_FindTrackTrainIsStoredOn $rStation \
					"[Train_Number $train]" \
					$departure $departure]
	} else {set rstorage NULL}
      }
      Terminate {
	set storage [Station_FindTrackTrainIsStoredOn $station \
					"[Train_Number $train]" \
					$arrival $arrival]
        if {![string equal $rStation NULL]} {
	  set rstorage [Station_FindTrackTrainIsStoredOn $rStation \
					"[Train_Number $train]" \
					$arrival $arrival]
	} else {set rstorage NULL}
      }
      Transit {
	set storage NULL
	set rstorage NULL
      }
    }
#    puts stderr "*** chartDisplay::addATrain: storage = $storage, rstorage = $rstorage"
    if {![string equal "$storage" NULL]} {
      set stationName "[Station_Name $station]"
      set trackName "[StorageTrack_Name $storage]"
      set sy $data("storage,${stationName}:${trackName},y")
      set occupiedA [StorageTrack_IncludesTime $storage $arrival]
      set occupiedD [StorageTrack_IncludesTime $storage $departure]
#      puts stderr "*** chartDisplay::addATrain: occupiedA = $occupiedA, occupiedD = $occupiedD"
#      if {![string equal $occupiedA NULL]} {
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_TrainNum \$occupiedA\] = [Occupied_TrainNum $occupiedA]"
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_From \$occupiedA\] = [Occupied_From $occupiedA]"
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_Until \$occupiedA\] = [Occupied_Until $occupiedA]"
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_TrainNum2 \$occupiedA\] = [Occupied_TrainNum2 $occupiedA]"
#      }
      if {![string equal $occupiedA NULL] &&
	  [string equal "[Occupied_TrainNum $occupiedA]" "[Train_Number $train]"]} {
#	puts stderr "*** chartDisplay::addATrain: using $occupiedA"
	set from [Occupied_From  $occupiedA]
	set to   [Occupied_Until $occupiedA]
	set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	if {$toX > $fromX} {
	  $canvas create line $fromX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	} else {
	  $canvas create line $fromX $sy $lastX $sy \
		-fill $newColor   -width 8 -tags $stortags
	  $canvas create line $firstX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	}
      }
#      if {![string equal $occupiedD NULL]} {
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_TrainNum \$occupiedD\] = [Occupied_TrainNum $occupiedD]"
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_From \$occupiedD\] = [Occupied_From $occupiedD]"
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_Until \$occupiedD\] = [Occupied_Until $occupiedD]"
#	puts stderr "*** chartDisplay::addATrain: \[Occupied_TrainNum2 \$occupiedD\] = [Occupied_TrainNum2 $occupiedD]"
#      }
      if {![string equal $occupiedD NULL] &&
	  [string equal "[Occupied_TrainNum2 $occupiedD]" "[Train_Number $train]"]} {
#	puts stderr "*** chartDisplay::addATrain: using $occupiedD"
	set from [Occupied_From  $occupiedD]
	set to   [Occupied_Until $occupiedD]
	set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	if {$toX > $fromX} {
	  $canvas create line $fromX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	} else {
	  $canvas create line $fromX $sy $lastX $sy \
		-fill $newColor   -width 8 -tags $stortags
	  $canvas create line $firstX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	}
      }
    }
    if {![string equal "$rstorage" NULL]} {
      set stationName "[Station_Name $rStation]"
      set trackName "[StorageTrack_Name $rstorage]"
      set sy $data("storage,${stationName}:${trackName},y")
      set occupiedA [StorageTrack_IncludesTime $rstorage $arrival]
      set occupiedD [StorageTrack_IncludesTime $rstorage $departure]
      if {![string equal $occupiedA NULL] &&
	  [string equal "[Occupied_TrainNum $occupiedA]" "[Train_Number $train]"]} {
	set from [Occupied_From  $occupiedA]
	set to   [Occupied_Until $occupiedA]
	set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	if {$toX > $fromX} {
	  $canvas create line $fromX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	} else {
	  $canvas create line $fromX $sy $lastX $sy \
		-fill $newColor   -width 8 -tags $stortags
	  $canvas create line $firstX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	}
      }
      if {![string equal $occupiedD NULL] &&
	  [string equal "[Occupied_TrainNum2 $occupiedD]" "[Train_Number $train]"]} {
	set from [Occupied_From  $occupiedD]
	set to   [Occupied_Until $occupiedD]
	set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	if {$toX > $fromX} {
	  $canvas create line $fromX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	} else {
	  $canvas create line $fromX $sy $lastX $sy \
		-fill $newColor   -width 8 -tags $stortags
	  $canvas create line $firstX $sy $toX $sy \
		-fill $newColor   -width 8 -tags $stortags
	}
      }
    }
#    puts stderr "*** ChartDisplay::addATrain: ------------------------------------------"
    set newTimeX [expr {$labelsize + ((double($arrival) / double($timeinterval) * 20.0)) + 4}]
    if {$timeX >= 0} {
      if {$newTimeX > $timeX} {
        $canvas create line $timeX $stationY $newTimeX $newStationY \
	  -fill $color -width 4 -tags $trtags
        if {$rStationY >= 0 && $newRStationY >= 0} {
	  $canvas create line $timeX $rStationY $newTimeX $newRStationY \
	    -fill $color -width 4 -tags $trtags
        }
        if {![catch {set data("cab,$cabName,y")} cy]} {
          $canvas create line $timeX $cy $newTimeX $cy \
	     -fill $color   -width 8 -tags $cabtags
	}
      } else {
	set unwrapNX [expr {$newTimeX + $lastX}]
	set slope [expr {double($newStationY - $stationY) / double($unwrapNX - $timeX)}]
	set midY  [expr {$stationY + ($slope * ($lastX - $timeX))}]
	$canvas create line $timeX $stationY $lastX $midY \
	  -fill $color -width 4 -tags $trtags
	$canvas create line $firstX $midY $newTimeX $newStationY \
	  -fill $color -width 4 -tags $trtags
	if {$rStationY >= 0 && $newRStationY >= 0} {
	  set slope [expr {double($newRStationY - $rStationY) / double($unwrapNX - $timeX)}]
	  set midY  [expr {$rStationY + ($slope * ($lastX - $timeX))}]
	  $canvas create line $timeX $rStationY $lastX $midY \
	    -fill $color -width 4 -tags $trtags
	  $canvas create line $firstX $midY $newTimeX $newRStationY \
	    -fill $color -width 4 -tags $trtags
	}
	if {![catch {set data("cab,$cabName,y")} cy]} {
	  $canvas create line $timeX $cy $lastX $cy \
	    -fill $color   -width 8 -tags $cabtags
	  $canvas create line $firstX $cy $newTimeX $cy \
	    -fill $color   -width 8 -tags $cabtags
	}
      }
    }
    set timeX $newTimeX
    set cabName "$newCabName"
    set color "$newColor"
    set stationY $newStationY
    set rStationY $newRStationY
    set depart [Stop_Departure $stop $arrival]
    if {$depart > $arrival} {
      set dontdrawcab [catch {set data("cab,$cabName,y")} cy]
      set newTimeX [expr {$labelsize + ((double($depart) / double($timeinterval) * 20.0)) + 4}]
      if {$newTimeX > $timeX} {
	$canvas create line $timeX $stationY $newTimeX $stationY \
	  -fill $color -width 4 -tags $trtags
	if {$rStationY >= 0} {
	  $canvas create line $timeX $rStationY $newTimeX $rStationY \
	    -fill $color -width 4 -tags $trtags
	
	}
	if {!$dontdrawcab} {
	  $canvas create line $timeX $cy $newTimeX $cy \
	    -fill $color   -width 8 -tags $cabtags
	}
      } else {
	$canvas create line $timeX $stationY $lastX $stationY \
	  -fill $color -width 4 -tags $trtags
	$canvas create line $firstX $stationY $newTimeX $stationY \
	  -fill $color -width 4 -tags $trtags
	if {$rStationY >= 0} {
	  $canvas create line $timeX $rStationY $lastX $rStationY \
	    -fill $color -width 4 -tags $trtags
	  $canvas create line $firstX $rStationY $newTimeX $rStationY \
	    -fill $color -width 4 -tags $trtags
	}
	if {!$dontdrawcab} {
	  $canvas create line $timeX $cy $lastX $cy \
	    -fill $color   -width 8 -tags $cabtags
	  $canvas create line $firstX $cy $newTimeX $cy \
	    -fill $color   -width 8 -tags $cabtags
	}
      }
#      puts stderr "*** ChartDisplay::addATrain: Station is [Station_Name $station], Train is [Train_Number $train]"
      set storage [Station_FindTrackTrainIsStoredOn $station \
			"[Train_Number $train]" $arrival $depart]
#      puts stderr "*** ChartDisplay::addATrain: storage = $storage"
      if {![string equal "$storage" NULL]} {
        set stationName "[Station_Name $station]"
	set trackName "[StorageTrack_Name $storage]"	
	set sy $data("storage,${stationName}:${trackName},y")
	set occupiedA [StorageTrack_IncludesTime $storage $arrival]
	set occupiedD [StorageTrack_IncludesTime $storage $depart]
	if {![string equal $occupiedA NULL] &&
	    [string equal "[Occupied_TrainNum $occupiedA]" "[Train_Number $train]"]} {
	  set from [Occupied_From  $occupiedA]
	  set to   [Occupied_Until $occupiedA]
	  set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	  set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	  if {$toX > $fromX} {
	    $canvas create line $fromX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	  } else {
	    $canvas create line $fromX $sy $lastX $sy \
		-fill $color   -width 8 -tags $stortags
	    $canvas create line $firstX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	  }
	}
	if {![string equal "$occupiedA" "$occupiedD"] &&
	    ![string equal $occupiedD NULL] &&
	    [string equal "[Occupied_TrainNum $occupiedD]" "[Train_Number $train]"]} {
	  set from [Occupied_From  $occupiedD]
	  set to   [Occupied_Until $occupiedD]
	  set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	  set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	  if {$toX > $fromX} {
	    $canvas create line $fromX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	  } else {
	    $canvas create line $fromX $sy $lastX $sy \
		-fill $color   -width 8 -tags $stortags
	    $canvas create line $firstX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	  }
	}
      }
      if {![string equal "$rStation" NULL]} {
        set storage [Station_FindTrackTrainIsStoredOn $rStation \
			"[Train_Number $train]" $arrival $depart]
        if {![string equal "$storage" NULL]} {
          set stationName "[Station_Name $rstation]"
	  set trackName "[StorageTrack_Name $storage]"
	  set sy $data("storage,${stationName}:${trackName},y")
	  set occupiedA [StorageTrack_IncludesTime $storage $arrival]
	  set occupiedD [StorageTrack_IncludesTime $storage $depart]
	  if {![string equal $occupiedA NULL] &&
	      [string equal "[Occupied_TrainNum $occupiedA]" \
			  "[Train_Number $train]"]} {
	    set from [Occupied_From  $occupiedA]
	    set to   [Occupied_Until $occupiedA]
	    set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	    set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	    if {$toX > $fromX} {
	      $canvas create line $fromX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	    } else {
	      $canvas create line $fromX $sy $lastX $sy \
		-fill $color   -width 8 -tags $stortags
	      $canvas create line $firstX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	    }
	  }
	  if {![string equal "$occupiedA" "$occupiedD"] &&
	      ![string equal $occupiedD NULL] &&
	      [string equal "[Occupied_TrainNum $occupiedD]" \
			  "[Train_Number $train]"]} {
	    set from [Occupied_From  $occupiedD]
	    set to   [Occupied_Until $occupiedD]
	    set fromX [expr {$labelsize + ((double($from) / double($timeinterval) * 20.0)) + 4}]
	    set toX   [expr {$labelsize + ((double($to)   / double($timeinterval) * 20.0)) + 4}]
	    if {$toX > $fromX} {
	      $canvas create line $fromX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	    } else {
	      $canvas create line $fromX $sy $lastX $sy \
		-fill $color   -width 8 -tags $stortags
	      $canvas create line $firstX $sy $toX $sy \
		-fill $color   -width 8 -tags $stortags
	    }
	  }
	}
      }
      set timeX $newTimeX
    }
    set oldDepart $depart
    set oldSmile  $smile
  }
  set script "displayOneTrain draw -train $train -minutes \[ChartDisplay::mx2minutes $path %x\]"
#  puts stderr "*** ChartDisplay::addATrain: script = $script"
  $canvas bind "Train:[Train_Number $train]" <1> "$script"
}

proc ChartDisplay::mx2minutes { path mx } {
  Widget::getVariable $path data
  set canvas $path:cmd
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]
  
  set cx [$canvas canvasx $mx]
  set time [expr {(double($cx - $labelsize - 4) / 20.0) * $timeinterval}]
  return $time
}

proc ChartDisplay::deleteTrain { path trainnumber} {
  Widget::getVariable $path data
  set canvas $path:cmd

  $canvas delete "Train:$trainnumber"  
}

proc ChartDisplay::_updateChart { path} {
  Widget::getVariable $path data
  set canvas $path:cmd

  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  set topOff [lindex [$canvas bbox Cabs] 3]
  set data(topofchart) [expr {$topOff + 10}]
  if {$data(totallength) == 0} {
    set data(bottomofchart) $data(topofchart)
    set ty $data(topofchart)
    set by $data(bottomofchart)
    set data(chartheight) 0
  } else {
    set data(chartheight) [expr {($data(totallength) * 20) + 20}]
    set data(bottomofchart) [expr {$data(topofchart) + $data(chartheight) + 20}]
    set ty [expr {$data(topofchart) + 10}]
    set by [expr {$data(bottomofchart) - 10}]
  }
  foreach tick [$canvas find withtag Chart:Tick] {
    set coords [$canvas coords $tick]
    $canvas coords $tick [lindex $coords 0] $ty [lindex $coords 2] $by
  }
  set coords [$canvas coords Chart:Hline]
  $canvas coords Chart:Hline [lindex $coords 0] $ty [lindex $coords 2] $ty
  set coords [$canvas coords Chart:Bline]
  $canvas coords Chart:Bline [lindex $coords 0] $by [lindex $coords 2] $by
  set offset [expr {$data(topofchart) + 20.0}]
  foreach stationIndex [array names data station,*,y] {
    regexp {station,(.*),y} "$stationIndex" -> sindex
    set smile $data(station,$sindex,smile)
    set data($stationIndex) [expr {$offset + ($smile * 20)}]
    set coords [$canvas coords Station:$sindex]
    $canvas coords Station:$sindex [lindex $coords 0] $data($stationIndex)
    set coords [$canvas coords Station:Line:$sindex]
    $canvas coords Station:Line:$sindex [lindex $coords 0] $data($stationIndex) [lindex $coords 2] $data($stationIndex)
    $canvas coords Station:namebox:$sindex [$canvas bbox Station:$sindex]
  }
  set ymove [expr {$offset - $data(chartstationoffset)}]
  $canvas move Chart:Train 0 $ymove
  set data(chartstationoffset) $offset
  set totalheight [lindex [$canvas bbox all] 3]
  if {[string equal "$totalheight" {}]} {set totalheight 0}
  set sr [$canvas cget -scrollregion]
  if {$totalheight > [lindex $sr 3]} {
    $canvas configure -scrollregion [lreplace $sr 3 3 $totalheight]
  }
}

proc ChartDisplay::_updateStorageTracks { path} {
  Widget::getVariable $path data
  set canvas $path:cmd

  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  set topOff [lindex [$canvas bbox Chart] 3]
  set data(topofstorage) [expr {$topOff + 10}]
  set data(bottomofstorage) [expr {$data(topofstorage) + $data(storagetrackheight)}]
  if {$data(numberofstoragetracks) == 0} {
    set ty $data(topofstorage)
    set by $data(bottomofstorage)
  } else {
    set ty [expr {$data(topofstorage) + 10}]
    set by [expr {$data(bottomofstorage) - 10}]
  }
  foreach tick [$canvas find withtag Storage:Tick] {
    set coords [$canvas coords $tick]
    $canvas coords $tick [lindex $coords 0] $ty [lindex $coords 2] $by
  }
  set coords [$canvas coords Storage:Hline]
  $canvas coords Storage:Hline [lindex $coords 0] $ty [lindex $coords 2] $ty
  set coords [$canvas coords Storage:Bline]
  $canvas coords Storage:Bline [lindex $coords 0] $by [lindex $coords 2] $by
  if {$data(numberofstoragetracks) == 0} {return}
  set offset [expr {$data(topofstorage) + 20.0}]
  set ymove [expr {$offset - $data(storageoffset)}]
  $canvas move Storage:track 0 $ymove
  foreach item [$canvas find withtag Storage:track] {
    if {[string equal [$canvas type $item] text]} {
      set sy [lindex [$canvas coords $item] 1]
      foreach t [$canvas itemcget $item -tags] {
	if {[regexp {^Storage:([^:]*):([^:]*)$} "$t" -> stationName trackName] > 0} {
	  set data("storage,${stationName}:${trackName},y") $sy
	}
      }
    }
  }
  set data(storageoffset) $offset
  set totalheight [lindex [$canvas bbox all] 3]
  if {[string equal "$totalheight" {}]} {set totalheight 0}
  set sr [$canvas cget -scrollregion]
  if {$totalheight > [lindex $sr 3]} {
    $canvas configure -scrollregion [lreplace $sr 3 3 $totalheight]
  }
}

proc ChartDisplay::_updateCabs { path} {
  Widget::getVariable $path data
  set canvas $path:cmd

  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  if {$data(numberofcabs) == 0} {
    set ty $data(topofcabs)
    set by $data(bottomofcabs)
  } else {
    set ty [expr {$data(topofcabs) + 10}]
    set by [expr {$data(bottomofcabs) - 10}]
  }
  foreach tick [$canvas find withtag Cabs:Tick] {
    set coords [$canvas coords $tick]
    $canvas coords $tick [lindex $coords 0] $ty [lindex $coords 2] $by
  }
  set coords [$canvas coords Cabs:Hline]
  $canvas coords Cabs:Hline [lindex $coords 0] $ty [lindex $coords 2] $ty
  set coords [$canvas coords Cabs:Bline]
  $canvas coords Cabs:Bline [lindex $coords 0] $by [lindex $coords 2] $by
  set totalheight [lindex [$canvas bbox all] 3]
  if {[string equal "$totalheight" {}]} {set totalheight 0}
  set sr [$canvas cget -scrollregion]
  if {$totalheight > [lindex $sr 3]} {
    $canvas configure -scrollregion [lreplace $sr 3 3 $totalheight]
  }
}

proc ChartDisplay::buildWholeChart { path timetable} {
  Widget::getVariable $path data
  set canvas $path:cmd

  set timescale [Widget::getoption $path -timescale]
  set timeinterval [Widget::getoption $path -timeinterval]
  set labelsize [Widget::getoption $path -labelsize]

  $canvas delete all
  set lheight $data(lheight)
  array unset data
  set data(lheight) $lheight

  Widget::setoption $path -timescale [TimeTableSystem_TimeScale $timetable]
  set timescale [Widget::getoption $path -timescale]
  Widget::setoption $path -timeinterval [TimeTableSystem_TimeInterval $timetable]
  set timeinterval [Widget::getoption $path -timeinterval]

  set data(totalLength) [TimeTableSystem_TotalLength $timetable]
  set data(chartheight) [expr {($data(totalLength) * 20) + 20}]

  _buildTimeLine $path
  _buildCabs $path
  _buildChart $path
  _buildStorageTracks $path
  ForEveryCab $timetable cab {
    $path addACab $cab
  }
  set sindex 0
  ForEveryStation $timetable station {
    $path addAStation $station $sindex
    incr sindex
  }
  ForEveryTrain $timetable train {
    $path addATrain $timetable $train
  }

}

proc MainWindow {dontWithdraw} {

  wm protocol . WM_DELETE_WINDOW {CarefulExit}
  wm title . "Time Table V2, using [package versions Ttclasses]  of Ttclasses"

  global FocusNowhere Main
  set FocusNowhere [canvas .focusNowhere]

  pack [set Main [mainwindow .main \
	-dontwithdraw $dontWithdraw -extramenus { \
	"&Trains" {trains:menu} {trains} 0 {} \
	"&Stations" {stations:menu} {stations} 0 {} \
	"&Cabs" {cabs:menu} {cabs} 0 {} \
        "&Notes"  {notes:menu} {notes} 0 {}}]] -expand yes -fill both
  $Main menu sethelpvar view
  $Main menu sethelpvar options
  $Main menu sethelpvar trains
  $Main menu sethelpvar stations
  $Main menu sethelpvar cabs
  $Main menu sethelpvar notes
  $Main menu entryconfigure file New -state disabled
  $Main menu entryconfigure file Open... -state disabled
  $Main menu entryconfigure file Save -state disabled
  $Main menu entryconfigure file {Save As...} -state disabled
  $Main menu entryconfigure file Print... -state disabled
  $Main menu entryconfigure file Close -command CarefulExit
  $Main menu entryconfigure file Exit -command CarefulExit
  global SysConfigFile
  $Main menu add options command \
	-label {Edit System Configuration} \
	-command [list TimeTableConfiguration edit] \
	-dynamichelp "Edit the system configuration"
  $Main menu add options command \
	-label {Save System Configuration} \
	-command [list TimeTableConfiguration write "$SysConfigFile"] \
	-dynamichelp "Save the system configuration"
  $Main menu add options command \
	-label {Re-load System Configuration} \
	-command [list TimeTableConfiguration read "$SysConfigFile"] \
	-dynamichelp "Reload the system configuration"
  $Main toolbar add tools
  $Main toolbar show tools
  global MainWindow ChartDisplay
  set MainWindow [$Main scrollwindow getframe]
  set ChartDisplay [ChartDisplay $MainWindow.chart \
	-labelsize [TimeTableConfiguration getkeyoption chart labelwidth]]
  pack $ChartDisplay -expand yes -fill both
  $Main scrollwindow setwidget $ChartDisplay
}



proc SetBusy {w flag} {
  global FocusNowhere
  switch [string tolower "$flag"] {
    1 -
    on -
    yes {
        if {[string equal [grab current $w] $FocusNowhere]} {return}
	catch {array unset ::WatchList}
	SetWatchCursor [winfo toplevel $w]
	grab $FocusNowhere
    }
    0 -
    off -
    no {
	if {![string equal [grab current $w] $FocusNowhere]} {return}
	UnSetWatchCursor
	grab release $FocusNowhere
    }
  }
}

proc SetWatchCursor {w} {
  global WatchList
  catch [list set WatchList($w) [$w cget -cursor]]
  catch [list $w configure -cursor watch]
  foreach iw [winfo children $w] {
    SetWatchCursor $iw
  }
}

proc UnSetWatchCursor {} {
  global WatchList
  foreach w [array names WatchList] {
    catch [list $w configure -cursor "$WatchList($w)"]
  }
}
	
proc WIPStart {{message {}}} {
  global Main
  $Main wipmessage configure -text "$message"
  $Main setprogress 0
  $Main setstatus {}
  SetBusy $::Main on
  update idle
}

proc WIPUpdate {value {message {}}} {
  global Main
  $Main setstatus "$message"
  $Main setprogress $value
  if {$value >= 100} {
    SetBusy $::Main off
  }
  update idle
}

proc WIPDone {{message {}}} {
  WIPUpdate 100 "$message"
  update idle
}

snit::type TtYesNo {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent message
  typecomponent headerlabel

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .ttYesNo -bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title {Yes or No Question}]
    $dialog add -name yes -text Yes -command [mytypemethod _Yes]
    $dialog add -name no  -text No  -command [mytypemethod _No]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _No]
    set frame [Dialog::getframe $dialog]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Yes or No Question}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    option add *TtYesNo.msg.wrapLength 3i widgetDefault
    global tcl_platform
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtYesNo.msg.font system widgetDefault
    } else {
      option add *TtYesNo.msg.font {Times 18} widgetDefault
    }
    set message [label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _Yes {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list 1]]
  }
  typemethod _No {} {
    Dialog::withdraw $dialog   
    return [eval [list Dialog::enddialog $dialog] [list 0]]
  }
  typemethod draw {args} {
    $type createDialog
    set title "[from args -title {Yes or No Question}]"
    $headerlabel configure -text "$title"
    $dialog      configure -title "$title"
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }
}

snit::type TtErrorMessage {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent message
  typecomponent headerlabel

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .ttErrorMessage \
			-bitmap error -default 0 -cancel 0 -modal local \
			-transient yes -parent . -side bottom \
			-title {Error Message}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _OK]
    set frame [Dialog::getframe $dialog]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Error Message}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    global tcl_platform
    option add *TtErrorMessage.msg.wrapLength 3i widgetDefault
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtErrorMessage.msg.font system widgetDefault
    } else {
      option add *TtErrorMessage.msg.font {Times 18} widgetDefault
    }
    set message [label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _OK {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list 1]]
  }
  typemethod draw {args} {
    $type createDialog
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog]  [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }
}

snit::type TtWarningMessage {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent message
  typecomponent headerlabel

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .ttWarningMessage  \
			-bitmap warning -default 0 -cancel 0 -modal local \
			-transient yes -parent . -side bottom \
			-title {Warning Message}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _OK]
    set frame [Dialog::getframe $dialog]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Warning Message}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    option add *TtWarningMessage.msg.wrapLength 3i widgetDefault
    global tcl_platform
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtWarningMessage.msg.font system widgetDefault
    } else {
      option add *TtWarningMessage.msg.font {Times 18} widgetDefault
    }
    set message [label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _OK {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list 1]]
  }
  typemethod draw {args} {
    $type createDialog
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }
}

snit::type TtInfoMessage {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent message
  typecomponent headerlabel

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .ttInfoMessage  \
			-bitmap info -default 0 -cancel 0 -modal local \
			-transient yes -parent . -side bottom \
			-title {Informational Message}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _OK]
    set frame [Dialog::getframe $dialog]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Informational Message}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    option add *TtInfoMessage.msg.wrapLength 3i widgetDefault
    global tcl_platform
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtInfoMessage.msg.font system widgetDefault
    } else {
      option add *TtInfoMessage.msg.font {Times 18} widgetDefault
    }
    set message [label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _OK {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list 1]]
  }
  typemethod draw {args} {
    $type createDialog
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }
}

proc CarefulExit {{ask 1}} {
  if {$ask} {
    set ans [TtYesNo draw -title {Really Exit} -message {Really Exit?}]
  } else {
    set ans 1
  }
  if {!$ans} {return}
  global IsSlave
  flush stderr
  if {$IsSlave} {
    puts stdout "101 Exit"
    flush stdout
    set ans [gets stdin]
  }
  if {[llength [info commands TheSystem]] > 0} {
    rename TheSystem {}
  }
  if {[llength [info commands CurrentPrinter]] > 0} {
    if {[CurrentPrinter IsOpenP]} {
      CurrentPrinter ClosePrinter
    }
    rename CurrentPrinter {}
  }
  exit
}

snit::macro TtStdShell {dialogclass} {
  hulltype toplevel
  widgetclass $dialogclass

  component headerframe
  component iconimage
  component headerlabel
  component userframe
  component dismisbutton

  option -title -default {Time Table Dialog} \
		-configuremethod _SetTitle

  method _SetTitle {option value} {
    wm title $win "$value"
    $headerlabel configure -text "$value"
    set options($option) "$value"
  }

  option {-activebackground activeBackground Foreground} -default #ececec \
		-configuremethod _SetWidgetOption
  option {-activeforeground activeForeground Background} -default Black \
		-configuremethod _SetWidgetOption
  option {-anchor anchor Anchor} -default center \
		-configuremethod _SetWidgetOption
  option {-background background Background} -default #d9d9d9 \
		-configuremethod _SetWidgetOption
  option {-borderwidth borderWidth BorderWidth} -default 2 \
		-configuremethod _SetWidgetOption
  option {-cursor cursor Cursor} -default {} \
		-configuremethod _SetWidgetOption
  option {-disabledforeground disabledForeground DisabledForeground} -default #a3a3a3 \
		-configuremethod _SetWidgetOption
  option {-foreground foreground Foreground} -default Black \
		-configuremethod _SetWidgetOption
  option {-highlightbackground highlightBackground HighlightBackground} -default #d9d9d9 \
		-configuremethod _SetWidgetOption
  option {-highlightcolor highlightColor HighlightColor} -default Black \
		-configuremethod _SetWidgetOption
  option {-highlightthickness highlightThickness HighlightThickness} -default 0 \
		-configuremethod _SetWidgetOption
  option {-padx padX Pad} -default 1 \
		-configuremethod _SetWidgetOption
  option {-pady padY Pad} -default 1 \
		-configuremethod _SetWidgetOption
  option {-takefocus takeFocus TakeFocus} -default 0 \
		-configuremethod _SetWidgetOption

  method _SetWidgetOption {option value} {
    catch [list $win configure $option "$value"]
    catch [list $iconimage configure $option "$value"]
    catch [list $headerlabel configure $option "$value"]
    catch [list $self settopframeoption $userframe $option "$value"]
    catch [list $dismisbutton configure $option "$value"]
    set options($option) "$value"
  }

  constructor {args} {
    wm withdraw $win
    wm transient $win .
    set headerframe $win.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    set userframe $win.userframe
    set dismisbutton $win.dismisbutton
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    label $iconimage -image banner
    pack  $iconimage -side left
    label $headerlabel -anchor w -font {Helvetica -24 bold}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    frame $userframe -bd 0 -relief flat
    pack  $userframe -expand yes -fill both
    Button::create $dismisbutton \
	-default active \
	-text Dismis \
	-command [mymethod _Dismis]
    pack $dismisbutton -expand yes -fill x
    if {[catch [list $self constructtopframe $userframe] message]} {
#      puts stderr "*** ${self}::constructor: constructtopframe failed: $message"
    }
    $self configurelist $args
    $type push availlist $self
    bind <Return> $win [list $dismisbutton invoke]
    bind <Esc> $win [list $dismisbutton invoke]
    wm protocol $win WM_DELETE_WINDOW [list $dismisbutton invoke]
  }

  method _Dismis {} {
    wm withdraw $win
    $type remove inuselist $self
    $type push   availlist $self
  }

  method draw {args} {
    catch [concat $self initializetopframe $userframe $args] message
#    puts stderr "*** $self draw: $self initializetopframe returned: $message"
    update idle
    set x [expr {[winfo screenwidth $win]/2 - ([winfo reqwidth $win])/2 \
	    - [winfo vrootx $win]}]
    set y [expr {[winfo screenheight $win]/2 - [winfo reqheight $win]/2 \
	    - [winfo vrooty $win]}]
    if {$x < 0} {set x 0}
    if {$y < 0} {set y 0}
    wm geom $win +$x+$y
    wm deiconify $win
    $type push inuselist $self
  }

  typemethod draw {args} {
    if {[$type length availlist] == 0} {
      $type create .[string tolower [lindex [split $type :] end]]%AUTO%
    }
    set object [$type pop availlist]
#    puts stderr "*** ${type}::typemethod draw: object = $object"
    eval [list $object draw] $args
    return $object
  }

  destructor {
    $type remove availlist $self
    $type remove inuselist $self
  }

  typevariable availlist {}
  typevariable inuselist {}

  typemethod _CheckList {list} {
    if {[lsearch -exact {availlist inuselist} $list] < 0} {
      error "No such list: $list"
    }
  }

  typemethod push {list object} {
    $type _CheckList $list
    if {![$type member $list $object]} {
      lappend $list $object
    }
  }

  typemethod pop {list} {
    $type _CheckList $list
    if {[$type length $list] > 0} {
#      puts stderr "*** ${type}::typemethod pop: list = $list ([set [set list]])"
      set object [lindex [set [set list]] 0]
#      puts stderr "*** ${type}::typemethod pop: object = $object"
      set $list  [lrange [set [set list]] 1 end]
#      puts stderr "*** ${type}::typemethod pop: list = $list ([set [set list]])"
    } else {
      set object {}
    }
    return $object
  }

  typemethod member {list object} {
    $type _CheckList $list 
    if {[lsearch -exact [set [set list]] $object] < 0} {
      return 0
    } else {
      return 1
    }
  }

  typemethod length {list} {
    $type _CheckList $list 
    return [llength [set [set list]]]
  }

  typemethod remove {list object} {
    $type _CheckList $list 
    set index [lsearch -exact [set [set list]] $object]
    if {$index < 0} {
      # nothing
    } elseif {$index == 0} {
      set $list [lrange [set [set list]] 1 end]
    } else {
      set $list [lreplace [set [set list]] $index $index]
    }
  }
}


package provide TTMainWindow 1.0

