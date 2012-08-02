#* 
#* ------------------------------------------------------------------
#* ReadOldTT.tcl - Read an old TT Chart file.
#* Created by Robert Heller on Fri Dec 23 12:58:55 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

#* $Id$

global Stations
# Global containing the smile distance for each of the stations on the line.
# [index] Stations!global

global TotalLength
# Global containing the total smile length of the railroad.
# [index] TotalLength!global

global DuplicateTrackMap
# Global containing the duplicate station map.
# [index] DuplicateTrackMap!global

set TotalLength 0

global StationFileTypes
# Contains the file type list for Station files.
# [index] StationFileTypes!procedure

set StationFileTypes {
	{{Station Files}  {.stations} TEXT}
	{{All Text Files} *           TEXT}
}

global TotalTime 
# Total time frame of the schedule.  Default is 24 shours (TotalTime is in sminutes).
# [index] TotalTime!global

set TotalTime [expr 24 * 60]

global TimeIncrement
# Time increment.  This is the units of the small time lines.  Default is 15 sminutes.
# [index] TimeIncrement!global

set TimeIncrement 15

global StationYMap
# Holds the Y coordinate of stations on the chart.
# [index] StationYMap!global


global CabColors
# Array containing the Cab colors.
# [index] CabColors!global

global CabYMap
# Holds cab Y coordincates.
# [index] CabYMap!global

global CabFileTypes
# Holds cab file type list.
# [index] CabFileTypes!global

set CabFileTypes {
	{{Cab Files}  {.cabs} TEXT}
	{{All Text Files} *           TEXT}
}

global TrackList
# List of storage tracks.
# [index] TrackList!global

global StorageTrackFileTypes
# Storage track file types.
# [index] StorageTrackFileTypes!global

set StorageTrackFileTypes {
	{{Storage Track Files} {.tracks} TEXT}
	{{All Text Files}      *         TEXT}
}

global TrackYMap
# Holds Y coordinates of storage tracks.
# [index] TrackYMap!global

global ChartFileTypes
# Holds the chart file type list.
# [index] ChartFileTypes!global

set ChartFileTypes {
	{{Chart Files}    {.chart} TEXT}
	{{All Text Files} *        TEXT}
}

global Trains
# Holds all trains.
# [index] Trains!global
 
global StorageTrackMap
# Holds storage track usage map.
# [index] StorageTrackMap!global

global ChartFile
# Holds the name of the current chart file.
# [index] ChartFile!global

global HasChartFileP
# Flag to tell the validity of ChartFile.
# [index] HasChartFileP!global

set HasChartFileP 0

global CabFile
# Holds the name of the cab file.
# [index] CabFile!global

global HasCabFileP
# Flag to tell the validity of CabFile.
# [index] HasCabFileP!global

set HasCabFileP 0

global StationsFile
# Holds the name of the StationsFile.
# [index] StationsFile!global

global HasStationsFileP
# Flag to tell the validity of StationsFile.
# [index] HasStationsFileP!global

set HasStationsFileP 0

global TracksFile
# Holds the name of the TracksFile.
# [index] TracksFile!global

global HasTracksFileP
# Flag to tell the validity of TracksFile.
# [index] HasTracksFileP!global

set HasTracksFileP 0

global HasSetTimeInfoP
# Flag to tell if the time info has been set from the command line.
# [index] HasSetTimeInfoP!global

set HasSetTimeInfoP 0

proc UnQuoteNL {s} {
# Procedure to unquote newlines.
# <in> s -- string possibly containing backquoted n sequences.
# [index] UnQuoteNL!procedure

  regsub -all {\\n} "$s" "\n" s
  return "$s"
}

proc LoadCompleteChart {filename} {
# Procedure to load a complete chart.  Workhorse behind the Open menu item.
# <in> filename (optional) -- name of a file containing a complete chart.
# [index] LoadCompleteChart!procedure

  global ChartFileTypes
  global CabColors TrackList
  global HasCabP HasTrackP HasChartP 
  global Stations TotalLength DuplicateTrackMap
  global TotalTime TimeIncrement
  global Trains
  global StorageTrackMap
  global Notes
  set TotalTime [expr 24 * 60]
  set TimeIncrement 15
  catch {unset CabColors}
  set HasCabP 0
  catch {unset TrackList}
  set HasTrackP 0
  set TotalLength 0
  catch {unset Stations}
  catch {unset DuplicateTrackMap}
  catch {unset Trains}
  catch {unset StorageTrackMap}
  catch {unset Notes}
  set HasChartP 0  

  if {[catch [list open "$filename" r] chfp]} {
    error  "Error opening chart file $filename for input: $chfp"
    return
  }

  set Line "[gets $chfp]"
  set ll [split $Line]
  if {[string compare "[lindex $ll 0]" {%%%TIMESCALE:}] != 0} {
    error  "Syntax error in $filename: expected %%%TIMESCALE:!"
    return 0
  }
  set TotalTime [lindex $ll 1]
  set TimeIncrement [lindex $ll 2]
  set Line "[gets $chfp]"
  if {[string compare "$Line" {%%%CABCOLORS:}] != 0} {
    error "Syntax error in $filename: expected %%%CABCOLORS:!"
    return 0
  }
  set sd {}
  while {[gets $chfp Line] >= 0} {
    set sd [split "$Line" {:}]
    if {[string compare "[lindex $sd 0]" {%%%STATIONTOTALLENGTH}] == 0} {break}
    if {[llength $sd] == 2} {set CabColors([lindex $sd 0]) [lindex $sd 1]}
  }
  if {[string compare "[lindex $sd 0]" {%%%STATIONTOTALLENGTH}] != 0} {
    error "Syntax error in $filename: expected %%%STATIONTOTALLENGTH:!"
    return 0
  }
  set TotalLength [lindex $sd 1]
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%DUPLICATETRACKMAP:}] == 0} {break}
    set sd [split "$Line" {|}]
    if {[llength $sd] == 2} {set Stations([lindex $sd 0]) [lindex $sd 1]}
  }
  if {[string compare "$Line" {%%%DUPLICATETRACKMAP:}] != 0} {
    error "Syntax error in $filename: expected %%%DUPLICATETRACKMAP:!"
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%STORAGETRACKS:}] == 0} {break}
    set dd [split "$Line" {|}]   
    if {[llength $dd] == 2} {set DuplicateTrackMap([lindex $dd 0]) [lindex $dd 1]}
  }
  if {[string compare "$Line" {%%%STORAGETRACKS:}] != 0} {
    error "Syntax error in $filename: expected %%%STORAGETRACKS:!"
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%TRAINS:}] == 0} {break}
    set st [split "$Line" {|}]
    if {[llength $st] == 2} {set TrackList([lindex $st 0]) [lindex $s 1]}
  }
  if {[string compare "$Line" {%%%TRAINS:}] != 0} {
    error "Syntax error in $filename: expected %%%TRAINS:!"
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%STORAGETRACKMAP:}] == 0} {break}
    set dd [split "$Line" {|}]
    if {[llength $dd] == 2} {set Trains([lindex $dd 0]) [lindex $dd 1]}
  }
  if {[string compare "$Line" {%%%STORAGETRACKMAP:}] != 0} {
    error "Syntax error in $filename: expected %%%STORAGETRACKMAP:!"
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%NOTES:}] == 0} {break}
    set dd [split "$Line" {|}]
    if {[llength $dd] == 2} {set StorageTrackMap([lindex $dd 0]) [lindex $dd 1]}
  }
  if {[string compare "$Line" {%%%NOTES:}] != 0} {
    error "Syntax error in $filename: expected %%%NOTES:!"
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    set dd [split "$Line" {|}]
    if {[llength $dd] == 2} {
      set Notes([lindex $dd 0]) "[UnQuoteNL [lindex $dd 1]]"
    }
  }
  close $chfp
  return 1
}



package provide ReadOldTT 1.0
