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

package require gettext
package require Tk
package require tile
package require snit
package require snitStdMenuBar
package require HTMLHelp 2.0
package require MainWindow

catch {TimeTable::SplashWorkMessage [_ "Creating Main Window"]	 11}

snit::widgetadaptor ChartDisplay {
    delegate option * to hull \
          except {-background -borderwidth 
        -highlightthickness -relief 
        -scrollregion}
    delegate method xview to hull
    delegate method yview to hull
    option -timescale -readonly yes -type {snit::integer -min 50 -max 1440} \
          -default 1440
    option -timeinterval -readonly yes -type {snit::integer -min 1 -max 60} \
          -default 15
    option -labelsize -readonly yes -type {snit::integer -min 0} -default 100
    
    variable lheight
    variable topofcabs
    variable cabheight
    variable bottomofcabs
    variable numberofcabs
    variable cabarray -array {}
    variable topofchart
    variable chartheight
    variable bottomofchart
    variable totallength
    variable chartstationoffset
    variable topofstorage
    variable storagetrackheight
    variable bottomofstorage
    variable numberofstoragetracks
    variable storageoffset
    variable totallength
    variable stationarray -array {}
    variable storagearray -array {}
    variable totalLength
    
    constructor {args} {
        installhull using canvas -background white -borderwidth 0 -highlightthickness 0 -relief flat
        $self configurelist $args
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set numIncrs [expr {int((double($timescale)+($timeinterval-1)) / double($timeinterval))}]
        set cwidth [expr {($numIncrs * 20) + $options(-labelsize) + 20}]
        set canvas $hull
        set lab [$canvas create text 0 0 -text "T"]
        set lheight [expr {1.5 * [lindex [$canvas bbox $lab] 3]}]
        $hull delete $lab
    }
    method deleteWholeChart {} {
        $hull delete all
        catch {
            unset topofcabs
            unset cabheight
            unset bottomofcabs
            unset numberofcabs
            unset cabarray
            unset topofchart
            unset chartheight
            unset bottomofchart
            unset totallength
            unset chartstationoffset
            unset topofstorage
            unset storagetrackheight
            unset bottomofstorage
            unset numberofstoragetracks
            unset storageoffset
            unset totallength
            unset stationarray
            unset storagearray
            unset totalLength
        }
    }
    method _buildTimeLine {} {
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set numIncrs [expr {int((double($timescale)+($timeinterval-1)) / double($timeinterval))}]
        set cwidth [expr {($numIncrs * 20) + $options(-labelsize) + 20}]
        set scrollWidth $cwidth
        set canvas $hull
        set topOff 0
        set labelsize $options(-labelsize)
        for {set m 0} {$m <= $timescale} {incr m 60} { 
            set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0)) + 4}]
            $canvas create text $mx 0 -anchor n \
                  -text [format {%2d} [expr {$m / 60}]] -tag TimeLine
        }
        set scrollHeight [lindex [$canvas bbox TimeLine] 3]
        $canvas configure -scrollregion [list 0 0 $scrollWidth $scrollHeight]
    }
    method _buildCabs {} {
        set canvas $hull
        $canvas delete Cabs
        set topOff [lindex [$canvas bbox TimeLine] 3]
        set topofcabs [expr {$topOff + 10}]
        set cabheight 0
        set topofcabs [expr {$topOff + 10}]
        set bottomofcabs $topofcabs
        set numberofcabs 0
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)
        for {set m 0} {$m <= $timescale} {incr m $timeinterval} {
            set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0))}]
            set lw 1
            if {[expr {$m % 60}] == 0} {set lw 2}
            $canvas create line $mx $topofcabs $mx $bottomofcabs -width $lw -tag [list Cabs Cabs:Tick]
        }
        set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
        $canvas create line $labelsize $topofcabs $r $topofcabs -width 2 -tag [list Cabs Cabs:Hline]
        $canvas create line $labelsize $bottomofcabs $r $bottomofcabs -width 2 -tag [list Cabs Cabs:Bline]
        array unset cab "*,y"
    }
    method addACab {cab} {
        set canvas $hull
        if {$numberofcabs == 0} {
            set numberofcabs 1
            set cabheight [expr {(2 * $lheight) + 20}]
            set bottomofcabs [expr {$topofcabs + $cabheight}]
            set cabyoff [expr {$lheight * 1.75}]
        } else {
            incr numberofcabs
            set cabheight [expr {$cabheight + $lheight}]
            set bottomofcabs [expr {$bottomofcabs + $lheight}]
            set cabyoff [expr {$lheight * ($numberofcabs + .75)}]
        }
        $self _updateChart
        $self _updateStorageTracks
        $self _updateCabs
        set cabName [Cab_Name $cab]
        set cabColor [Cab_Color $cab]
        $canvas create text 0 [expr {$cabyoff + $topofcabs}] -text "$cabName" -fill "$cabColor" -tag [list Cabs "Cabs:Name:$cabName"] -anchor w
        set cabarray("$cabName,y") [expr {$cabyoff + $topofcabs}]
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)
        set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
        $canvas create line $labelsize $cabarray("$cabName,y") $r $cabarray("$cabName,y")  -tag [list Cabs "Cabs:Line:$cabName"] -width 4 -fill "$cabColor" -stipple gray50
    }      
    method _buildChart {} {
        set canvas $hull
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)

        $canvas delete Chart
        set topOff [lindex [$canvas bbox Cabs] 3]
        set topofchart [expr {$topOff + 10}]
        set chartheight 0
        set bottomofchart $topofchart
        set totallength 0
        #  puts stderr "*** chartDisplay:buildChart: topofchart = $topofchart"
        for {set m 0} {$m <= $timescale} {incr m $timeinterval} {
            set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0))}]
            set lw 1
            if {[expr {$m % 60}] == 0} {set lw 2}
            $canvas create line $mx $topofchart $mx $bottomofchart -width $lw -tag [list Chart Chart:Tick]
        }
        set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
        $canvas create line $labelsize $topofchart $r $topofchart -width 2 -tag [list Chart Chart:Hline]
        $canvas create line $labelsize $bottomofchart $r $bottomofchart -width 2 -tag [list Chart Chart:Bline]
        set chartstationoffset $topofchart
    }

    method _buildStorageTracks {} {
        set canvas $hull
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)
        
        $canvas delete Storage
        set topOff [lindex [$canvas bbox Chart] 3]
        set topofstorage [expr {$topOff + 10}]
        set storagetrackheight 0
        set bottomofstorage $topofstorage
        set numberofstoragetracks 0
        #puts stderr "*** chartDisplay:buildStorageTracks: topofstorage = $topofstorage"
        for {set m 0} {$m <= $timescale} {incr m $timeinterval} {
            set mx [expr {$labelsize + (((double($m) / double($timeinterval)) * 20.0))}]
            set lw 1
            if {[expr {$m % 60}] == 0} {set lw 2}
            $canvas create line $mx $topofstorage $mx $bottomofstorage -width $lw -tag [list Storage Storage:Tick]
        }
        set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
        $canvas create line $labelsize $topofstorage $r $topofstorage -width 2 -tag [list Storage Storage:Hline]
        $canvas create line $labelsize $bottomofstorage $r $bottomofstorage -width 2 -tag [list Storage Storage:Bline]
        array unset storage "*:*,y"
        set storageoffset $topofstorage
    }

    method addAStation { station sindex } {
        set canvas $hull
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)
        
        set name  [Station_Name  $station]
        #  puts stderr "*** ChartDisplay::addAStation: station = $station, sindex = $sindex"
        set smile [Station_SMile $station]
        if {$smile > $totallength} {
            set totallength $smile
        }
        $self _updateChart
        $self _updateStorageTracks
        #  puts stderr "*** chartDisplay:addAStation: topofchart = $topofchart"
        set offset [expr {$topofchart + 20.0}]
        set stationarray($sindex,y) [expr {$offset + ($smile * 20)}]
        set stationarray($sindex,smile) $smile
        set sl [$canvas create text 0 $stationarray($sindex,y) -text "$name" -tag [list Chart Station Station:$sindex] -anchor w]
        while {[expr {[lindex [$canvas bbox $sl] 2] + 5}] > $labelsize} {
            #    puts stderr "*** chartDisplay:addAStation: name = $name, $canvas bbox $sl = [$canvas bbox $sl]"
            $canvas delete $sl
            set name [string range "$name" 0 [expr {[string length "$name"] - 2}]]
            set sl [$canvas create text 0 $stationarray($sindex,y) -text "$name" -tag [list Chart Station Station:$sindex] -anchor w]
        }
        $canvas create rect [$canvas bbox Station:$sindex] -fill white -outline black -tag [list Chart Station Station:namebox:$sindex]
        $canvas lower Station:namebox:$sindex Station:$sindex
        set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
        $canvas create line $labelsize $stationarray($sindex,y) $r $stationarray($sindex,y)  -tag [list Chart Station Station:Line:$sindex] -width 2 -fill gray50
        $canvas bind Station:namebox:$sindex <1> [list TimeTable::displayOneStation draw -station $station]
        $canvas bind Station:line:$sindex <1> [list TimeTable::displayOneStation draw -station $station]
        $canvas bind Station:$sindex <1> [list TimeTable::displayOneStation draw -station $station]
        #puts stderr "*** $self addAStation: Adding Storage Tracks"
        ForEveryStorageTrack $station storage {
            $self addAStorageTrack $station $storage
        }
    }

    method addAStorageTrack { station track } {
        #puts stderr "*** $self addAStorageTrack $station $track"
        set canvas $hull
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)

        set topOff [lindex [$canvas bbox Chart] 3]
        set topofstorage [expr {$topOff + 10}]
        if {$numberofstoragetracks == 0} {
            set numberofstoragetracks 1
            set storagetrackheight [expr {(2 * $lheight) + 20}]
            set bottomofstorage [expr {$topofstorage + $storagetrackheight}]
            set storageyoff [expr {$lheight * 1.75}]
        } else {
            incr numberofstoragetracks
            set storagetrackheight [expr {$storagetrackheight + $lheight}]
            set bottomofstorage [expr {$bottomofstorage + $lheight}]
            set storageyoff [expr {$lheight * ($numberofstoragetracks + .75)}]
        }
        #puts stderr "*** $self addAStorageTrack: numberofstoragetracks = $numberofstoragetracks"
        #puts stderr "*** $self addAStorageTrack: storagetrackheight = $storagetrackheight"
        #puts stderr "*** $self addAStorageTrack: bottomofstorage = $bottomofstorage"
        #puts stderr "*** $self addAStorageTrack: storageyoff = $storageyoff"
        #puts stderr "*** $self addAStorageTrack: updating StorageTracks"
        $self _updateStorageTracks
        #puts stderr "*** $self addAStorageTrack: StorageTracks updated"
        set stationName [Station_Name $station]
        #puts stderr "*** $self addAStorageTrack: stationName is $stationName"
        set trackName   [StorageTrack_Name $track]
        #puts stderr "*** $self addAStorageTrack: trackName is $trackName"
        #set nameOnChart "${stationName}:${trackName}"
        set nameOnChart [$self _formNameOnChart $stationName $trackName]
        #puts stderr "*** $self addAStorageTrack: nameOnChart is $nameOnChart"
        set storagearray(${stationName}:${trackName},y) [expr {$storageyoff + $topofstorage}]
        #puts stderr "*** $self addAStorageTrack: storagearray(${stationName}:${trackName},y) = $storagearray(${stationName}:${trackName},y)"
        $canvas create text 0 $storagearray(${stationName}:${trackName},y) -text "$nameOnChart" -tag [list Storage Storage:track "Storage:${stationName}:${trackName}"] -anchor w
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)
        set r [expr {$labelsize + (((double($timescale) / double($timeinterval)) * 20.0))}]
        $canvas create line $labelsize $storagearray(${stationName}:${trackName},y) $r $storagearray(${stationName}:${trackName},y)  -tag [list Storage Storage:track "Storage:${stationName}:${trackName}"] -width 4 -stipple gray50
    }

    method _formNameOnChart {sn tn} {
        #puts stderr "*** $self _formNameOnChart $sn $tn"
        set canvas $hull
        set labelsize $options(-labelsize)
        #puts stderr "*** $self _formNameOnChart: labelsize = $labelsize"
        
        set i [$canvas create text 0 0 -anchor w -text "${sn}:${tn}"]
        set l1 [lindex [$canvas bbox $i] 2]
        $canvas delete $i
        #puts stderr "*** $self _formNameOnChart: l1 = $l1 (${sn}:${tn})"
        set i [$canvas create text 0 0 -anchor w -text "${sn}:"]
        set l2 [lindex [$canvas bbox $i] 2]
        $canvas delete $i
        #puts stderr "*** $self _formNameOnChart: l2 = $l2 (${sn}:)"
        set i [$canvas create text 0 0 -anchor w -text "$tn"]
        set l3 [lindex [$canvas bbox $i] 2]
        #puts stderr "*** $self _formNameOnChart: l3 = $l3 ($tn)"
        $canvas delete $i
        while {$l1 > $labelsize && $l2 > [expr {$labelsize / 2.0}]} {
            set sn [string trim [string range "$sn" 0 "end-1"]]
            set i [$canvas create text 0 0 -anchor w -text "${sn}:${tn}"]
            set l1 [lindex [$canvas bbox $i] 2]
            $canvas delete $i
            #puts stderr "*** $self _formNameOnChart: l1 = $l1 (${sn}:${tn})"
            set i [$canvas create text 0 0 -anchor w -text "${sn}:"] 
            set l2 [lindex [$canvas bbox $i] 2]
            $canvas delete $i
            #puts stderr "*** $self _formNameOnChart: l2 = $l2 (${sn}:)"
        }
        while {$l1 > $labelsize} {
            set tn [string trim [string range "$tn" 0 "end-1"]]
            set i [$canvas create text 0 0 -anchor w -text "${sn}:${tn}"]
            set l1 [lindex [$canvas bbox $i] 2]
            $canvas delete $i
            #puts stderr "*** $self _formNameOnChart: l1 = $l1 (${sn}:${tn})"
        }
        return "${sn}:${tn}"
    }

    method addATrain { timetable train} {
        set canvas $hull
        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)
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
                set newRStationY $stationarray($rSindex,y)
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
            set newStationY $stationarray($sindex,y)
            if {$oldDepart >= 0} {
                #      puts stderr "*** chartDisplay:addATrain: smile = $smile, oldSmile = $oldSmile, abs($smile - $oldSmile) = [expr {abs($smile - $oldSmile)}], speed = $speed, speed/60 = [expr {double($speed) / 60.0}]"
                set arrival [expr {$oldDepart + (abs($smile - $oldSmile) * (double($speed) / 60.0))}]
            } else {
                set arrival $departure
            }
            #    puts stderr "*** $self addATrain: ------------------------------------------"
            #    puts stderr "*** $self addATrain: Station is [Station_Name $station], Train is [Train_Number $train]"
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
            #    puts stderr "*** $self addATrain: storage = $storage, rstorage = $rstorage"
            if {![string equal "$storage" NULL]} {
                set stationName "[Station_Name $station]"
                set trackName "[StorageTrack_Name $storage]"
                set sy $storagearray(${stationName}:${trackName},y)
                set occupiedA [StorageTrack_IncludesTime $storage $arrival]
                set occupiedD [StorageTrack_IncludesTime $storage $departure]
                #      puts stderr "*** $self addATrain: occupiedA = $occupiedA, occupiedD = $occupiedD"
                #      if {![string equal $occupiedA NULL]} {
                #	puts stderr "*** $self addATrain: \[Occupied_TrainNum \$occupiedA\] = [Occupied_TrainNum $occupiedA]"
                #	puts stderr "*** $self addATrain: \[Occupied_From \$occupiedA\] = [Occupied_From $occupiedA]"
                #	puts stderr "*** $self addATrain: \[Occupied_Until \$occupiedA\] = [Occupied_Until $occupiedA]"
                #	puts stderr "*** $self addATrain: \[Occupied_TrainNum2 \$occupiedA\] = [Occupied_TrainNum2 $occupiedA]"
                #      }
                if {![string equal $occupiedA NULL] &&
                    [string equal "[Occupied_TrainNum $occupiedA]" "[Train_Number $train]"]} {
                    #	puts stderr "*** $self addATrain: using $occupiedA"
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
                #	puts stderr "*** $self addATrain: \[Occupied_TrainNum \$occupiedD\] = [Occupied_TrainNum $occupiedD]"
                #	puts stderr "*** $self addATrain: \[Occupied_From \$occupiedD\] = [Occupied_From $occupiedD]"
                #	puts stderr "*** $self addATrain: \[Occupied_Until \$occupiedD\] = [Occupied_Until $occupiedD]"
                #	puts stderr "*** $self addATrain: \[Occupied_TrainNum2 \$occupiedD\] = [Occupied_TrainNum2 $occupiedD]"
                #      }
                if {![string equal $occupiedD NULL] &&
                    [string equal "[Occupied_TrainNum2 $occupiedD]" "[Train_Number $train]"]} {
                    #	puts stderr "*** $self addATrain: using $occupiedD"
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
                set sy $storagearray(${stationName}:${trackName},y)
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
            #    puts stderr "*** $self addATrain: ------------------------------------------"
            set newTimeX [expr {$labelsize + ((double($arrival) / double($timeinterval) * 20.0)) + 4}]
            if {$timeX >= 0} {
                if {$newTimeX > $timeX} {
                    $canvas create line $timeX $stationY $newTimeX $newStationY \
                          -fill $color -width 4 -tags $trtags
                    if {$rStationY >= 0 && $newRStationY >= 0} {
                        $canvas create line $timeX $rStationY $newTimeX $newRStationY \
                              -fill $color -width 4 -tags $trtags
                    }
                    if {![catch {set cabarray("$cabName,y")} cy]} {
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
                    if {![catch {set cabarray("$cabName,y")} cy]} {
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
                set dontdrawcab [catch {set cabarray("$cabName,y")} cy]
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
                #      puts stderr "*** $self addATrain: Station is [Station_Name $station], Train is [Train_Number $train]"
                set storage [Station_FindTrackTrainIsStoredOn $station \
                             "[Train_Number $train]" $arrival $depart]
                #      puts stderr "*** $self addATrain: storage = $storage"
                if {![string equal "$storage" NULL]} {
                    set stationName "[Station_Name $station]"
                    set trackName "[StorageTrack_Name $storage]"	
                    set sy $storagearray(${stationName}:${trackName},y)
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
                        set sy $storagearray(${stationName}:${trackName},y)
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
        set script "TimeTable::displayOneTrain draw -train $train -minutes \[[mymethod mx2minutes %x]\]"
        #puts stderr "*** $self addATrain: script = $script"
        $canvas bind "Train:[Train_Number $train]" <1> "$script"
    }

    method mx2minutes { mx } {
        set canvas $hull
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)
  
        set cx [$canvas canvasx $mx]
        set time [expr {(double($cx - $labelsize - 4) / 20.0) * $timeinterval}]
        return $time
    }

    method deleteTrain { trainnumber} {
        Widget::getVariable $path data
        set canvas $hull

        $canvas delete "Train:$trainnumber"  
    }

    method _updateChart {} {
        set canvas $hull

        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)

        set topOff [lindex [$canvas bbox Cabs] 3]
        set topofchart [expr {$topOff + 10}]
        if {$totallength == 0} {
            set bottomofchart $topofchart
            set ty $topofchart
            set by $bottomofchart
            set chartheight 0
        } else {
            set chartheight [expr {($totallength * 20) + 20}]
            set bottomofchart [expr {$topofchart + $chartheight + 20}]
            set ty [expr {$topofchart + 10}]
            set by [expr {$bottomofchart - 10}]
        }
        foreach tick [$canvas find withtag Chart:Tick] {
            set coords [$canvas coords $tick]
            $canvas coords $tick [lindex $coords 0] $ty [lindex $coords 2] $by
        }
        set coords [$canvas coords Chart:Hline]
        $canvas coords Chart:Hline [lindex $coords 0] $ty [lindex $coords 2] $ty
        set coords [$canvas coords Chart:Bline]
        $canvas coords Chart:Bline [lindex $coords 0] $by [lindex $coords 2] $by
        set offset [expr {$topofchart + 20.0}]
        foreach stationIndex [array names station *,y] {
            regexp {(.*),y} "$stationIndex" -> sindex
            set smile $stationarray($sindex,smile)
            set stationarray($stationIndex) [expr {$offset + ($smile * 20)}]
            set coords [$canvas coords Station:$sindex]
            $canvas coords Station:$sindex [lindex $coords 0] $stationarray($stationIndex)
            set coords [$canvas coords Station:Line:$sindex]
            $canvas coords Station:Line:$sindex [lindex $coords 0] $stationarray($stationIndex) [lindex $coords 2] $stationarray($stationIndex)
            $canvas coords Station:namebox:$sindex [$canvas bbox Station:$sindex]
        }
        set ymove [expr {$offset - $chartstationoffset}]
        $canvas move Chart:Train 0 $ymove
        set chartstationoffset $offset
        set totalheight [lindex [$canvas bbox all] 3]
        if {[string equal "$totalheight" {}]} {set totalheight 0}
        set sr [$canvas cget -scrollregion]
        if {$totalheight > [lindex $sr 3]} {
            $canvas configure -scrollregion [lreplace $sr 3 3 $totalheight]
        }
    }

    method _updateStorageTracks {} {
        set canvas $hull

        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)

        set topOff [lindex [$canvas bbox Chart] 3]
        set topofstorage [expr {$topOff + 10}]
        set bottomofstorage [expr {$topofstorage + $storagetrackheight}]
        if {$numberofstoragetracks == 0} {
            set ty $topofstorage
            set by $bottomofstorage
        } else {
            set ty [expr {$topofstorage + 10}]
            set by [expr {$bottomofstorage - 10}]
        }
        foreach tick [$canvas find withtag Storage:Tick] {
            set coords [$canvas coords $tick]
            $canvas coords $tick [lindex $coords 0] $ty [lindex $coords 2] $by
        }
        set coords [$canvas coords Storage:Hline]
        $canvas coords Storage:Hline [lindex $coords 0] $ty [lindex $coords 2] $ty
        set coords [$canvas coords Storage:Bline]
        $canvas coords Storage:Bline [lindex $coords 0] $by [lindex $coords 2] $by
        if {$numberofstoragetracks == 0} {return}
        set offset [expr {$topofstorage + 20.0}]
        set ymove [expr {$offset - $storageoffset}]
        $canvas move Storage:track 0 $ymove
        foreach item [$canvas find withtag Storage:track] {
            if {[string equal [$canvas type $item] text]} {
                set sy [lindex [$canvas coords $item] 1]
                foreach t [$canvas itemcget $item -tags] {
                    if {[regexp {^Storage:([^:]*):([^:]*)$} "$t" -> stationName trackName] > 0} {
                        set storagearray(${stationName}:${trackName},y) $sy
                    }
                }
            }
        }
        set storageoffset $offset
        set totalheight [lindex [$canvas bbox all] 3]
        if {[string equal "$totalheight" {}]} {set totalheight 0}
        set sr [$canvas cget -scrollregion]
        if {$totalheight > [lindex $sr 3]} {
            $canvas configure -scrollregion [lreplace $sr 3 3 $totalheight]
        }
    }

    method _updateCabs {} {
        set canvas $hull

        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)

        if {$numberofcabs == 0} {
            set ty $topofcabs
            set by $bottomofcabs
        } else {
            set ty [expr {$topofcabs + 10}]
            set by [expr {$bottomofcabs - 10}]
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

    method buildWholeChart {timetable} {
        #puts stderr "*** $self buildWholeChart $timetable"
        set canvas $hull

        set timescale $options(-timescale)
        set timeinterval $options(-timeinterval)
        set labelsize $options(-labelsize)

        $self deleteWholeChart
        #puts stderr "*** $self buildWholeChart: chart deleted"
        set options(-timescale) [TimeTableSystem_TimeScale $timetable]
        set timescale $options(-timescale)
        #puts stderr "*** $self buildWholeChart: timescale is $timescale:"
        set options(-timeinterval) [TimeTableSystem_TimeInterval $timetable]
        set timeinterval $options(-timeinterval)
        #puts stderr "*** $self buildWholeChart: timeinterval is $timeinterval"

        set totalLength [TimeTableSystem_TotalLength $timetable]
        set chartheight [expr {($totalLength * 20) + 20}]
        #puts stderr "*** $self buildWholeChart: totalLength = $totalLength, chartheight = $chartheight"

        #puts stderr "*** $self buildWholeChart: building time line..."
        $self _buildTimeLine
        #puts stderr "*** $self buildWholeChart: building cabs..."
        $self _buildCabs
        #puts stderr "*** $self buildWholeChart: building chart..."
        $self _buildChart
        #puts stderr "*** $self buildWholeChart: building storage tracks..."
        $self _buildStorageTracks
        #puts stderr "*** $self buildWholeChart: Adding cabs ([$timetable NumberOfCabs])..."
        ForEveryCab $timetable cab {
            #puts stderr "*** $self buildWholeChart: adding cab $cab..."
            $self addACab $cab
        }
        set sindex 0
        #puts stderr "*** $self buildWholeChart: Adding stations([$timetable NumberOfStations])..."
        ForEveryStation $timetable station {
            #puts stderr "*** $self buildWholeChart: adding station $station ($sindex)..."
            $self addAStation $station $sindex
            incr sindex
        }
        #puts stderr "*** $self buildWholeChart: Adding trains ([$timetable NumberOfTrains])..."
        ForEveryTrain $timetable train {
            #puts stderr "*** $self buildWholeChart: adding adding train $train..."
            $self addATrain $timetable $train
        }
        
    }
}

namespace eval TimeTable {
  variable FocusNowhere
  variable Main
}
proc TimeTable::MainWindow {dontWithdraw} {

  variable FocusNowhere
  variable Main

  wm protocol . WM_DELETE_WINDOW {TimeTable::CarefulExit}
  wm title . "Time Table V2, using [package versions Ttclasses]  of Ttclasses"

  set FocusNowhere [canvas .focusNowhere]

  pack [set Main [mainwindow .main \
	-dontwithdraw $dontWithdraw -extramenus [list  \
	[_m "Menu|&Trains"] {trains:menu} {trains} 0 {} \
	[_m "Menu|&Stations"] {stations:menu} {stations} 0 {} \
	[_m "Menu|&Cabs"] {cabs:menu} {cabs} 0 {} \
        [_m "Menu|&Notes"]  {notes:menu} {notes} 0 {}]]] -expand yes -fill both
  $Main mainframe setmenustate trains:menu disabled
  $Main mainframe setmenustate stations:menu disabled
  $Main mainframe setmenustate cabs:menu disabled
  $Main mainframe setmenustate notes:menu disabled
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
  $Main menu entryconfigure file Close -command TimeTable::CarefulExit
  $Main menu entryconfigure file Exit -command TimeTable::CarefulExit
  variable SysConfigFile
  $Main menu add options command \
	-label {Edit System Configuration} \
	-command [list TimeTable::TimeTableConfiguration edit] \
	-dynamichelp "Edit the system configuration"
  $Main menu add options command \
	-label {Save System Configuration} \
	-command [list TimeTable::TimeTableConfiguration write "$SysConfigFile"] \
	-dynamichelp "Save the system configuration"
  $Main menu add options command \
	-label {Re-load System Configuration} \
	-command [list TimeTable::TimeTableConfiguration read "$SysConfigFile"] \
	-dynamichelp "Reload the system configuration"
  $Main toolbar add tools
  $Main toolbar show tools
  variable MainWindow 
  variable ChartDisplay
  set MainWindow [$Main scrollwindow getframe]
  set ChartDisplay [ChartDisplay $MainWindow.chart \
	-labelsize [TimeTable::TimeTableConfiguration getkeyoption chart labelwidth]]
  $Main scrollwindow setwidget $ChartDisplay

  $Main menu delete help "On Keys..."
  $Main menu delete help "Index..."
  $Main menu add help command \
	-label "Reference Manual" \
	-command "HTMLHelp help {Time Table (V2) Reference}"
  $Main menu entryconfigure help "On Help..." \
	-command "HTMLHelp help Help"
  $Main menu entryconfigure help "Tutorial..." \
	-command "HTMLHelp help {Time Table (V2) Tutorial}"
  $Main menu entryconfigure help "On Version" \
	-command "HTMLHelp help Version"
  $Main menu entryconfigure help "Copying" \
	-command "HTMLHelp help Copying"
  $Main menu entryconfigure help "Warranty" \
	-command "HTMLHelp help Warranty"

  variable HelpDir

  HTMLHelp setDefaults "$HelpDir" "TimeTableli1.html"
}



proc TimeTable::SetBusy {w flag} {
  variable FocusNowhere
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

proc TimeTable::SetWatchCursor {w} {
  variable WatchList
  catch [list set WatchList($w) [$w cget -cursor]]
  catch [list $w configure -cursor watch]
  foreach iw [winfo children $w] {
    SetWatchCursor $iw
  }
}

proc TimeTable::UnSetWatchCursor {} {
  variable WatchList
  foreach w [array names WatchList] {
    catch [list $w configure -cursor "$WatchList($w)"]
  }
}
	
proc TimeTable::WIPStart {{message {}}} {
  variable Main
  $Main wipmessage configure -text "$message"
  $Main setprogress 0
  $Main setstatus {}
  SetBusy $::Main on
  update idle
}

proc TimeTable::WIPUpdate {value {message {}}} {
  variable Main
  $Main setstatus "$message"
  $Main setprogress $value
  if {$value >= 100} {
    SetBusy $::Main off
  }
  update idle
}

proc TimeTable::WIPDone {{message {}}} {
  WIPUpdate 100 "$message"
  update idle
}

snit::type TimeTable::TtYesNo {
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
    set dialog [Dialog .ttYesNo -bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title [_ "Yes or No Question"]]
    $dialog add yes -text [_m "Button|Yes"] -command [mytypemethod _Yes]
    $dialog add no  -text [_m "Button|No"]  -command [mytypemethod _No]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _No]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Yes or No Question"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    option add *TtYesNo.msg.wrapLength 3i widgetDefault
    global tcl_platform
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtYesNo.msg.font system widgetDefault
    } else {
      option add *TtYesNo.msg.font {Times 18} widgetDefault
    }
    set message [ttk::label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _Yes {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list 1]]
  }
  typemethod _No {} {
    $dialog withdraw   
    return [eval [list $dialog enddialog] [list 0]]
  }
  typemethod draw {args} {
    $type createDialog
    set title "[from args -title {Yes or No Question}]"
    $headerlabel configure -text "$title"
    $dialog      configure -title "$title"
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list $dialog draw]]
  }
}

snit::type TimeTable::TtErrorMessage {
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
    set dialog [Dialog .ttErrorMessage \
			-bitmap error -default 0 -cancel 0 -modal local \
			-transient yes -parent . -side bottom \
			-title [_ "Error Message"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _OK]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Error Message"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    global tcl_platform
    option add *TtErrorMessage.msg.wrapLength 3i widgetDefault
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtErrorMessage.msg.font system widgetDefault
    } else {
      option add *TtErrorMessage.msg.font {Times 18} widgetDefault
    }
    set message [ttk::label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _OK {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list 1]]
  }
  typemethod draw {args} {
    $type createDialog
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog]  [$dialog cget -parent]
    return [eval [list $dialog draw]]
  }
}

snit::type TimeTable::TtWarningMessage {
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
    set dialog [Dialog .ttWarningMessage  \
			-bitmap warning -default 0 -cancel 0 -modal local \
			-transient yes -parent . -side bottom \
			-title [_ "Warning Message"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _OK]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Warning Message"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    option add *TtWarningMessage.msg.wrapLength 3i widgetDefault
    global tcl_platform
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtWarningMessage.msg.font system widgetDefault
    } else {
      option add *TtWarningMessage.msg.font {Times 18} widgetDefault
    }
    set message [ttk::label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _OK {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list 1]]
  }
  typemethod draw {args} {
    $type createDialog
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list $dialog draw]]
  }
}

snit::type TimeTable::TtInfoMessage {
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
    set dialog [Dialog .ttInfoMessage  \
			-bitmap info -default 0 -cancel 0 -modal local \
			-transient yes -parent . -side bottom \
			-title [_ "Informational Message"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _OK]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Informational Message"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    option add *TtInfoMessage.msg.wrapLength 3i widgetDefault
    global tcl_platform
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      option add *TtInfoMessage.msg.font system widgetDefault
    } else {
      option add *TtInfoMessage.msg.font {Times 18} widgetDefault
    }
    set message [ttk::label $frame.message -text {}]
    pack $message -expand yes -fill both
  }
  typemethod _OK {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list 1]]
  }
  typemethod draw {args} {
    $type createDialog
    $message     configure -text "[from args -message]"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list $dialog draw]]
  }
}

proc TimeTable::CarefulExit {{ask 1}} {
  if {$ask} {
    set ans [TtYesNo draw -title [_ "Really Exit"] -message [_ "Really Exit?"]]
  } else {
    set ans 1
  }
  if {!$ans} {return}
  variable IsSlave
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

snit::macro TimeTable::TtStdShell {dialogclass} {
  hulltype toplevel
  widgetclass $dialogclass

  component headerframe
  component iconimage
  component headerlabel
  component userframe
  component dismisbutton

#  option -title -default [_ "Time Table Dialog"] \
#		-configuremethod _SetTitle
  option -title -default {} -configuremethod _SetTitle

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
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    ttk::frame $userframe -borderwidth 0 -relief flat
    pack  $userframe -expand yes -fill both
    ttk::button $dismisbutton \
	-default active \
	-text [_m "Button|Dismis"] \
	-command [mymethod _Dismis]
    pack $dismisbutton -expand yes -fill x
    if {[catch [list $self constructtopframe $userframe] message]} {
      puts stderr "*** ${self}::constructor: constructtopframe failed: $message"
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
    if {"$options(-title)" eq ""} {
      $self configure -title [_ "Time Table Dialog"]
    }
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

