#!/usr/bin/wish -f
#* 
#* ------------------------------------------------------------------
#* Model Railroad System by Deepwoods Software
#* ------------------------------------------------------------------
#* mrrTimeTable.tcl - Time Table generator
#* Created by Robert Heller on Thu Feb 14 15:50:09 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2004/04/14 23:25:18  heller
#* Modification History: Various updates: slave option, additional LaTeX code inclusion.
#* Modification History:
#* Modification History: Revision 1.1  2002/11/10 14:27:46  heller
#* Modification History: Updated for Time Table scripts
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994-2002  Robert Heller D/B/A Deepwoods Software
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

#@Chapter:mrrTimeTable.tcl -- Main program file.
#@Label:chapt:mrrTimeTable.tcl
#$Id$

global SrcDir
# Global containing the source directory.
# [index] SrcDir!global

set SrcDir [file dirname [info script]]
if {[string compare "$SrcDir" {.}] == 0} {set SrcDir [pwd]}

global CommonSrcDir
# Global containing the Common source directory.
# [index] CommonSrcDir!global

set CommonSrcDir [file join [file dirname $SrcDir] Common]

global HasCabP
# Flag that indicates if the Cab bar has been drawn.
# [index] HasCabP!global

set HasCabP 0

global HasTrackP 
# Flag that indicates if the Storage Track bar has been drawn.
# [index] HasTrackP!global

set HasTrackP 0

global HasChartP
# Flag that indicates if the main chart has been drawn.
# [index] HasChartP!global

set HasChartP 0

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

global argc
# Count of command line arguments.
# [index] argc!global

global argv
# List of command line arguments.
# [index] argv!global

global argv0
# Pathname we were invoked with.
# [index] argv0!global

lappend auto_path $CommonSrcDir $SrcDir

package require StdMenuBar 1.0

package require MakeTimeTable 1.0

image create photo banner -file [file join $SrcDir banner.gif]
# Image used as a banner for all dialog boxes.
# [index] banner!image

image create photo DeepwoodsBanner -format gif -file [file join $SrcDir DeepwoodsBanner.gif]
# Deepwoods banner image.  Used in the splash screen.
# [index] DeepwoodsBanner!image


# Process command line options.

set argcTest 0
set IsSlave 0

for {set ia 0} {$ia < $argc} {incr ia} {
  switch -glob -- "[lindex $argv $ia]" {
    -totaltime {
	incr ia
	set t "[lindex $argv $ia]"
	if {[catch [list expr int($t)] time]} {
	  puts stderr "$argv0: -totaltime: not a number: $t"
	  exit 99
	}
	if {$t != $time} {
	  puts stderr "$argv0: -totaltime: not a whole number: $t"
	  exit 99
	}
	if {$time < 1 || $time > [expr 24 * 60]} {
	  puts stderr "$argv0: -totaltime: value out of range (1 to [expr 24 * 60]): $time"
	  exit 99
	}
	set TotalTime $time
	incr HasSetTimeInfoP
    }
    -timeincr* {
    	incr ia
    	set t "[lindex $argv $ia]"
    	if {[catch [list expr int($t)] time]} {
    	  puts stderr "$argv0: -timeincrement: not a number: $t"
    	  exit 98
    	}
    	if {$t != $time} {
    	  puts stderr "$argv0: -timeincrement: not a whole number: $t"
    	  exit 98
    	}
    	if {$time < 1 || $time > $TotalTime} {
    	  puts stderr "$argv0: -timeincrement: value out of range (1 to $TotalTime): $time"
    	  exit 98
    	}
    	set TimeIncrement $time
    	incr HasSetTimeInfoP
    }
    -cab* {
    	incr ia
    	set file "[lindex $argv $ia]"
    	if {[file readable "$file"]} {
    	  set CabFile "$file"
	  incr HasCabFileP
	} else {
	  puts stderr "$argv0: -cabfile: file not readable: $file"
	  exit 97
	}
    }
    -nocab* {
	set HasCabFileP -1
    }
    -station* {
    	incr ia
    	set file "[lindex $argv $ia]"
    	if {[file readable "$file"]} {
    	  set StationsFile "$file"
	  incr HasStationsFileP
	} else {
	  puts stderr "$argv0: -stationfile: file not readable: $file"
	  exit 97
	}
    }
    -track* {
    	incr ia
    	set file "[lindex $argv $ia]"
    	if {[file readable "$file"]} {
    	  set TracksFile "$file"
	  incr HasTracksFileP
	} else {
	  puts stderr "$argv0: -trackfile: file not readable: $file"
	  exit 97
	}
    }
    -notrack* {
 	set HasTracksFileP -1
    }
    -isslave* {
      set IsSlave 1
      incr argcTest
      fconfigure stdin -buffering line
      fconfigure stdout -buffering line
    }
    -* {
    	puts stderr "usage: $argv0 \[wish options\] -- \[-totaltime time\] \[-timeincrement time\] \[-cabfile file\] \[-nocabfile\] \[-stationfile file\] \[-trackfile file\] \[-notrackfile\] \[chartfile\]"
	exit 96
    }
    default {
    	set file "[lindex $argv $ia]"
	if {[file readable "$file"]} {
	  set ChartFile "$file"
	  incr HasChartFileP
	} else {
	  puts stderr "$argv0: chartfile: file not readable: $file"
	  exit 95
	}
    }
  }
}

proc SplashScreen {} {
  # Build the ``Splash Screen'' -- A popup window that tells the user what 
  # we are all about.  It gives the version and brief copyright information.
  #
  # The upper part of the splash screen gives the brief information, with
  # directions on how to get detailed information.  The lower part contains
  # an image banner for Deepwoods Software.
  # [index] SplashScreen!procedure

  #global help_tips
  # build widget .mrrSplash
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .mrrSplash"
  } {
    catch "destroy .mrrSplash"
  }
  toplevel .mrrSplash 

  # Window manager configurations
  wm positionfrom .mrrSplash program
  wm sizefrom .mrrSplash program
  wm resizable .mrrSplash 0 0
  wm geometry .mrrSplash "+[expr ([winfo screenwidth .] / 2) - 254]+[expr ([winfo screenheight .] / 2) - 92]"
  wm title .mrrSplash {Model Railroad Timetable Chart Program V0.1}
  wm overrideredirect .mrrSplash 1

  bind .mrrSplash <1> {
      if {"[info procs XFEdit]" != ""} {
        catch "XFDestroy .mrrSplash"
      } {
        catch "destroy .mrrSplash"
      }
    }
  #enable_balloon .mrrSplash
  #set help_tips(.mrrSplash) {Click anywhere to dismiss splash window.}

  # build widget .mrrSplash.frame0
  frame .mrrSplash.frame0 \
    -background {#2ba2bf} -relief ridge -borderwidth 5

  # build widget .mrrSplash.frame0.frame1
  frame .mrrSplash.frame0.frame1 \
    -background {#2ba2bf}

  # build widget .mrrSplash.frame0.frame1.label4
  label .mrrSplash.frame0.frame1.label4 \
    -background {#2ba2bf} \
    -image banner

  # build widget .mrrSplash.frame0.frame1.message5
  message .mrrSplash.frame0.frame1.message5 \
    -background {#2ba2bf} \
    -foreground {white} \
    -aspect {800} \
    -font {-adobe-times-medium-r-*-*-*-100-*-*-*-*-*-*} \
    -padx {5} \
    -pady {2} \
    -text {Model Railroad Timetable Chart Program 0.1, Copyright (C) 2002 Robert Heller D/B/A Deepwoods Software Model Railroad Timetable Chart Program comes with ABSOLUTELY NO WARRANTY; for details select 'Warranty...' under the Help menu.  This is free software, and you are welcome to redistribute it under certain conditions; select 'Copying...' under the Help menu.}

  # build widget .mrrSplash.frame0.frame2
  frame .mrrSplash.frame0.frame2 \
    -background {#2ba2bf}

  # build widget .mrrSplash.frame0.frame2.label3
  label .mrrSplash.frame0.frame2.label3 \
    -background {#2ba2bf} \
    -image {DeepwoodsBanner}

  update
  wm withdraw .mrrSplash
  set bwidth [winfo reqwidth .mrrSplash.frame0.frame2.label3]
  set iwidth [winfo reqwidth .mrrSplash.frame0.frame1.label4]
  set mwidth [expr $bwidth - $iwidth]
  .mrrSplash.frame0.frame1.message5 configure -width $mwidth

  # pack master .mrrSplash.frame0.frame1
  pack configure .mrrSplash.frame0.frame1.label4 \
    -side left
  pack configure .mrrSplash.frame0.frame1.message5 \
    -side right

  # pack master .mrrSplash.frame0.frame2
  pack configure .mrrSplash.frame0.frame2.label3

  # pack master .mrrSplash.frame0
  pack configure .mrrSplash.frame0.frame1 \
    -fill y
  pack configure .mrrSplash.frame0.frame2 \
    -fill x
# end of widget tree

  # pack master .mrrSplash
  pack configure .mrrSplash.frame0

  wm deiconify .mrrSplash
}

if {!$IsSlave} {

  SplashScreen

  update

  set splashAfterId [after 60000 {catch [list destroy .mrrSplash]}]
}

proc MainWindow {args} {
# This function creates the main toplevel window, which is where the main
# GUI lives, containing the chart itself and a set of mail function buttons.
# [index] MainWindow!procedure

  # Window manager configurations
  wm positionfrom . user
  wm sizefrom . ""
  wm maxsize . 1265 994
  wm minsize . 1 1
  wm protocol . WM_DELETE_WINDOW {.buttons.button33 invoke}
  wm title . {Model Railroad Timetable Chart Program}


  MakeStandardMenuBar
  set fm [GetMenuByName File]
  $fm entryconfigure Exit -command {.buttons.button33 invoke}
  $fm entryconfigure Close -command {.buttons.button33 invoke}
  $fm entryconfigure Save -command {.buttons.button28 invoke}
  $fm entryconfigure {Save As...} -command {SaveChartAs}
  $fm entryconfigure New -command {NewChart}
  $fm entryconfigure {Open...} -command {OpenChart}
  $fm entryconfigure {Print...} -command {.buttons.button29 invoke}

  set vm [GetMenuByName View]
  $vm add command -label {Single Train} -command {ViewATrain}
  $vm add command -label {All Trains} -command {ViewTrains}
  $vm add command -label {Stations} -command {ViewStations}
  $vm add command -label {Cabs} -command {ViewCabs} -state disabled
  $vm add command -label {Storage Tracks} -command {ViewStorageTracks} -state disabled

  set em [GetMenuByName Edit]
  for {set i 0} {$i <= [$em index end]} {incr i} {
    $em entryconfigure $i -state disabled
  }

  set hm [GetMenuByName Help]
  for {set i 0} {$i <= [$hm index end]} {incr i} {
    $hm entryconfigure $i -state disabled
  }
  $hm entryconfigure {Warranty...} -state normal -command {HelpWarranty}
  $hm entryconfigure {Copying...} -state normal -command {HelpCopying}

  AddExtraMenuButton Notes

  set nm [GetMenuByName Notes]  
  $nm add command -label {View All Notes} -command {ViewAllNotes}
  $nm add command -label {Create New Note} -command {CreateNote}
  $nm add command -label {Delete Note} -command {DeleteNote}
  $nm add command -label {Edit Note} -command {EditNote}
  $nm add command -label {Add Note To Train} -command {AddNoteToTrain}
  $nm add command -label {Add Note To Train at Station} -command {AddNoteToTrainAtStation}
  $nm add command -label {Remove Note From Train} -command {RemoveNoteFromTrain}
  $nm add command -label {Remove Note From Train at Station} -command {RemoveNoteFromTrainAtStation}

  # build widget .wholeChart
  frame .wholeChart \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .wholeChart.chartCanvas
  canvas .wholeChart.chartCanvas \
    -height {400} \
    -width {700} \
    -scrollregion {0 0 700 400} \
    -xscrollcommand {.wholeChart.chartCanvasHScroll set} -background white
  bind .wholeChart.chartCanvas <Configure> {MRRTTCGeometryManager %W %h %w}

  # build widget .wholeChart.chartCanvasHScroll
  scrollbar .wholeChart.chartCanvasHScroll \
    -command {.wholeChart.chartCanvas xview} \
    -orient {horizontal}

  # build widget .buttons
  frame .buttons \
    -borderwidth {2}

  # build widget .buttons.button25
  button .buttons.button25 \
    -padx {9} \
    -pady {3} \
    -text {New Train} \
    -command {AddNewTrain}

  # build widget .buttons.button26
  button .buttons.button26 \
    -padx {9} \
    -pady {3} \
    -text {Delete Train} \
    -command {DeleteATrain}

  # build widget .buttons.button27
  button .buttons.button27 \
    -padx {9} \
    -pady {3} \
    -text {Edit Train} \
    -command {EditATrain}

  # build widget .buttons.button28
  button .buttons.button28 \
    -padx {9} \
    -pady {3} \
    -text {Save} \
    -command {SaveChart}

  # build widget .buttons.button29
  button .buttons.button29 \
    -padx {9} \
    -pady {3} \
    -text {Make Time Table} \
    -command {MakeTimeTable}

  # build widget .buttons.button33
  button .buttons.button33 \
    -padx {9} \
    -pady {3} \
    -text {Quit} \
    -command {CarefulExit}

  # pack master .wholeChart
  pack configure .wholeChart.chartCanvas \
    -expand 1 \
    -fill both
  pack configure .wholeChart.chartCanvasHScroll \
    -fill x

  # pack master .buttons
  pack configure .buttons.button25 \
    -expand 1 \
    -side left
  pack configure .buttons.button26 \
    -expand 1 \
    -side left
  pack configure .buttons.button27 \
    -expand 1 \
    -side left
  pack configure .buttons.button28 \
    -expand 1 \
    -side left
  pack configure .buttons.button29 \
    -expand 1 \
    -side left
  pack configure .buttons.button33 \
    -expand 1 \
    -side right

  # pack master .
  pack configure .wholeChart \
    -expand 1 \
    -fill both
  pack configure .buttons \
    -fill x

  # build canvas items .wholeChart.chartCanvas



  if {"[info procs XFEdit]" != ""} {
    catch "XFMiscBindWidgetTree ."
    after 2 "catch {XFEditSetShowWindows}"
  }

  global IsSlave
  if {!$IsSlave} {
    set w .
    wm withdraw $w
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
    set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
    wm geom $w +$x+$y
    set bWidth 8
    foreach b [winfo children .buttons] {
      incr bWidth [winfo reqwidth $b]
    }
    wm minsize . $bWidth [expr [winfo reqheight $w] + [winfo reqheight .menuBar]]
  }
}

proc MRRTTCGeometryManager {canvas height width} {
# Procedure to update the geometry of the chart canvas and its children.
# Invoked from a Configure event binding on the chart canvas.
# <in> canvas -- chart canvas.
# <in> height -- new height.
# <in> width -- new width.
# [index] MRRTTCGeometryManager!procedure

  global HasCabP HasTrackP HasChartP

  if {!$HasChartP} {return}

  set topOff [lindex [.wholeChart.chartCanvas bbox Header] 3]

  if {$HasTrackP} {
    set trBBox [.wholeChart.chartCanvas bbox TrackFrame]
    set trTop  [expr $height - ([lindex $trBBox 3] - [lindex $trBBox 1])]
    .wholeChart.chartCanvas coords TrackFrame 0 $trTop
  } else {
    set trTop $height
  }
  set ch [expr ($trTop - $topOff) - 8]
  $canvas.chartFrame.theChart configure -height $ch
}

proc CarefulExit {} {
# Procedure to carefully exit.
# [index] CarefulExit!procedure

  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Quit?} \
		-title {Careful Exit} -type yesno] {yes}] == 0} {
    global IsSlave
    #puts stderr "*** CarefulExit: IsSlave = $IsSlave"
    flush stderr
    if {$IsSlave} {
      puts stdout "101 Exit"
      flush stdout
      set ans [gets stdin]
      #puts stderr "*** CarefulExit: ans = '$ans'"
    }
    exit
  }
}

proc GetStations {} {
# Procedure to get the station list from the user.
# [index] GetStations!procedure

  global Stations TotalLength
  set TotalLength 0
  catch {unset Stations}

# .getStationList
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getStationList
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getStationList"
  } {
    catch "destroy .getStationList"
  }
  toplevel .getStationList 

  # Window manager configurations
  wm positionfrom .getStationList ""
  wm sizefrom .getStationList ""
  wm maxsize .getStationList 1265 994
  wm minsize .getStationList 1 1
  wm protocol .getStationList WM_DELETE_WINDOW {.getStationList.buttons.button13 invoke}
  wm title .getStationList {Station List}


  # build widget .getStationList.banner
  frame .getStationList.banner \
    -borderwidth {2}

  # build widget .getStationList.banner.label5
  label .getStationList.banner.label5 -image banner

  # build widget .getStationList.banner.label6
  label .getStationList.banner.label6 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Get Station List}

  # build widget .getStationList.listSoFar
  frame .getStationList.listSoFar \
    -borderwidth {2} \
    -relief {groove}

  # build widget .getStationList.listSoFar.stationList
  listbox .getStationList.listSoFar.stationList \
    -exportselection {0} \
    -font {Courier -12 bold} \
    -relief {flat} \
    -width {60} -height 20 -selectmode none \
    -yscrollcommand {.getStationList.listSoFar.stationListVScroll set}

  # build widget .getStationList.listSoFar.stationListVScroll
  scrollbar .getStationList.listSoFar.stationListVScroll \
    -command {.getStationList.listSoFar.stationList yview}

  # build widget .getStationList.newStation
  frame .getStationList.newStation \
    -borderwidth {2} \
    -relief {groove}

  # build widget .getStationList.newStation.label9
  label .getStationList.newStation.label9 \
    -text {Station:}

  # build widget .getStationList.newStation.stationName
  entry .getStationList.newStation.stationName

  # build widget .getStationList.newStation.label11
  label .getStationList.newStation.label11 \
    -text {, Distance to next station:}

  # build widget .getStationList.newStation.distance
  entry .getStationList.newStation.distance \
    -width {10}

  # build widget .getStationList.buttons
  frame .getStationList.buttons \
    -borderwidth {2}

  # build widget .getStationList.buttons.button13
  button .getStationList.buttons.button13 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {CancelStations}

  # build widget .getStationList.buttons.button14
  button .getStationList.buttons.button14 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {AddStation}

  # build widget .getStationList.buttons.button15
  button .getStationList.buttons.button15 \
    -padx {9} \
    -pady {3} \
    -text {Done} \
    -command {FinishStations}

  # pack master .getStationList.banner
  pack configure .getStationList.banner.label5 \
    -side left
  pack configure .getStationList.banner.label6 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getStationList.listSoFar
  pack configure .getStationList.listSoFar.stationList \
    -expand 1 \
    -fill both \
    -side left
  pack configure .getStationList.listSoFar.stationListVScroll \
    -fill y \
    -side right

  # pack master .getStationList.newStation
  pack configure .getStationList.newStation.label9 \
    -side left
  pack configure .getStationList.newStation.stationName \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getStationList.newStation.label11 \
    -side left
  pack configure .getStationList.newStation.distance \
    -side right

  # pack master .getStationList.buttons
  pack configure .getStationList.buttons.button13 \
    -anchor w \
    -side left
  pack configure .getStationList.buttons.button15 \
    -side right
  pack configure .getStationList.buttons.button14 \
    -side right

  # pack master .getStationList
  pack configure .getStationList.banner \
    -fill x
  pack configure .getStationList.listSoFar \
    -fill both
  pack configure .getStationList.newStation \
    -fill x
  pack configure .getStationList.buttons \
    -fill x

  .getStationList.newStation.stationName insert end {}
  .getStationList.newStation.distance insert end {}


# end of widget tree

  set w .getStationList
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

  tkwait window $w
}

proc CancelStations {} {
# Procedure cancel getting the station list. Bound to the Cancel button.
# [index] CancelStations!procedure

  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Cancel Station?} \
		-title {Cancel Stations} -type yesno] {yes}] == 0} {
    global Stations TotalLength
    set TotalLength 0
    catch {unset Stations}
    destroy .getStationList
  }
}

proc AddStation {} {
# Procedure to add a station to the station list.  Bound to the Next Station
# button.
# [index] AddStation!procedure

  global TotalLength Stations
  set newStation [string trim "[.getStationList.newStation.stationName get]"]
  if {[string length "$newStation"] == 0} {
    tk_messageBox -icon error -message "No station name!" -type ok
    return
  }
  if {[catch [list array names Stations "$newStation"] match]} {
    set match {}
  }
  if {[HasForbiddenCharsP "$newStation" {%|=+}]} {
    tk_messageBox -icon error -message "Station name contains forbidden charactors (%|=+): $newStation!" -type ok
    return
  }
  if {[llength $match] == 0} {
    set dist [string trim "[.getStationList.newStation.distance get]"]
    if {[catch [list expr double($dist)] diatance]} {
      tk_messageBox -icon error -message "Not a number: $dist!" -type ok
      return
    }
    set Stations($newStation) $TotalLength
    .getStationList.listSoFar.stationList insert end "[format {%-50s %9.3f} $newStation $TotalLength]"
    set TotalLength [expr $TotalLength + $diatance]
  } else {
    tk_messageBox -icon error -message "Duplicate station: $newStation" -type ok
    return
  }
}

proc FinishStations {} {
# Procedure to finish getting stations.  Bound to the Done button.
# [index] FinishStations!procedure

  global TotalLength Stations
  if {$TotalLength == 0 || [catch {array names Stations}]} {
    CancelStations
  } else {
    set lastStation [string trim "[.getStationList.newStation.stationName get]"]
    if {[string length "$lastStation"] == 0} {
      tk_messageBox -icon error -message "No station name!" -type ok
      return
    }
    if {[HasForbiddenCharsP "$lastStation" {%|=}]} {
      tk_messageBox -icon error -message "Station name contains forbidden charactors (%|=): $lastStation!" -type ok
      return
    }
    if {[catch [list array names Stations "$lastStation"] match]} {
      set match {}
    }
    if {[llength $match] == 0} {
      set Stations($lastStation) $TotalLength
      .getStationList.listSoFar.stationList insert end "[format {%-50s %9.3f} $lastStation $TotalLength]"
      tk_messageBox -icon info -message "Continue?" -type ok
      destroy .getStationList
    } else {
      tk_messageBox -icon error -message "Duplicate station: $lastStation" -type ok
      return
    }
  }
}  
  
proc StationDistanceComp {a b} {
# Procedure to compare the distances of two stations.
# <in> a -- one station.
# <in> b -- another station.
# [index] StationDistanceComp!procedure

  global Stations
  set comp [expr $Stations($a) - $Stations($b)]
  if {$comp < 0} {
    return -1
  } elseif {$comp > 0} {
    return 1
  } else {
    return 0
  }
}

proc LoadStations {{filename {}}} {
# Procedure to load a station list from a file.
# <in> filename (optional) -- file to load from.
# [index] LoadStations!procedure

  global Stations TotalLength StationFileTypes DuplicateTrackMap
  if {[string length "$filename"] == 0} {
    set filename "[tk_getOpenFile -defaultextension .stations \
				-filetypes $StationFileTypes \
				-title {Station File To Load}]"
  }
  if {[string length "$filename"] == 0} {return}
  if {[catch [list open "$filename" r] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening station file $filename for input: $sfp" \
		  -type ok
    return
  }
  catch {unset Stations}
  set TotalLength [gets $sfp]
  while {[gets $sfp Line] >= 0} {
    if {[string compare "$Line" {%%% Duplicate Trackage Map}] == 0} {break}
    set sd [split "$Line" {|}]
    if {[llength $sd] == 2} {set Stations([lindex $sd 0]) [lindex $sd 1]}
  }
  catch {unset DuplicateTrackMap}
  while {[gets $sfp Line] >= 0} {
    set dd [split "$Line" {|}]
    if {[llength $dd] == 2} {set DuplicateTrackMap([lindex $dd 0]) [lindex $dd 1]}
  }
  close $sfp
}

proc SaveStations {{filename {}}} {
# Procedure to save a station list to a file.
# <in> filename (optional) -- file to save to.
# [index] SaveStations!procedure

  global Stations TotalLength StationFileTypes DuplicateTrackMap
  if {[string length "$filename"] == 0} {
    set filename "[tk_getSaveFile -defaultextension .stations \
				-filetypes $StationFileTypes \
				-initialfile Stations.stations \
				-title {Station File To Save Stations To}]"
  }
  if {[string length "$filename"] == 0} {return}
  if {[catch [list open "$filename" w] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening station file $filename for output: $sfp" \
		  -type ok
    return
  }
  puts $sfp $TotalLength
  foreach s [lsort -command StationDistanceComp [array names Stations]] {
    puts $sfp "$s|$Stations($s)"
  }
  puts $sfp {%%% Duplicate Trackage Map}
  if {[catch {array names DuplicateTrackMap} dupnames] == 0} {
    foreach d $dupnames {
      puts $sfp "$d|$DuplicateTrackMap($d)"
    }
  }
  close $sfp
}

proc StationOptionMenu {w var} {
# Procedure to generate an option menu of stations.
# <in> w -- widget name to create.
# <in> var -- variable to bind the selection to.
# [index] StationOptionMenu!procedure

  global Stations
  eval [concat tk_optionMenu $w $var [lsort -command StationDistanceComp [array names Stations]]]
}

proc GetDuplicateTrackMap {} {
# Procedure to get the duplicate track map.
# [index] GetDuplicateTrackMap!procedure

  global DuplicateTrackMap
  catch {unset DuplicateTrackMap}
# .getDuplicateTrackage
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getDuplicateTrackage
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getDuplicateTrackage"
  } {
    catch "destroy .getDuplicateTrackage"
  }
  toplevel .getDuplicateTrackage 

  # Window manager configurations
  wm positionfrom .getDuplicateTrackage ""
  wm sizefrom .getDuplicateTrackage ""
  wm maxsize .getDuplicateTrackage 1009 738
  wm minsize .getDuplicateTrackage 1 1
  wm protocol .getDuplicateTrackage WM_DELETE_WINDOW {.getDuplicateTrackage.buttons.button16 invoke}
  wm title .getDuplicateTrackage {Get Duplicate Trackage}


  # build widget .getDuplicateTrackage.banner
  frame .getDuplicateTrackage.banner \
    -borderwidth {2}

  # build widget .getDuplicateTrackage.banner.label6
  label .getDuplicateTrackage.banner.label6 -image banner

  # build widget .getDuplicateTrackage.banner.label7
  label .getDuplicateTrackage.banner.label7 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Get Duplicate Trackage}

  # build widget .getDuplicateTrackage.infoFrame
  frame .getDuplicateTrackage.infoFrame \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .getDuplicateTrackage.infoFrame.from
  StationOptionMenu .getDuplicateTrackage.infoFrame.from SourceFrom

  # build widget .getDuplicateTrackage.infoFrame.label9
  label .getDuplicateTrackage.infoFrame.label9 \
    -text {to}

  # build widget .getDuplicateTrackage.infoFrame.to
  StationOptionMenu .getDuplicateTrackage.infoFrame.to SourceTo

  # build widget .getDuplicateTrackage.infoFrame.label11
  label .getDuplicateTrackage.infoFrame.label11 \
    -text {(reverse) duplicates}

  # build widget .getDuplicateTrackage.infoFrame.dupfrom
  StationOptionMenu .getDuplicateTrackage.infoFrame.dupfrom DestFrom

  # build widget .getDuplicateTrackage.infoFrame.label13
  label .getDuplicateTrackage.infoFrame.label13 \
    -text {to}

  # build widget .getDuplicateTrackage.infoFrame.dupto
  StationOptionMenu .getDuplicateTrackage.infoFrame.dupto DestTo

  # build widget .getDuplicateTrackage.listSoFar
  frame .getDuplicateTrackage.listSoFar \
    -borderwidth {2} \
    -relief {groove}

  # build widget .getDuplicateTrackage.listSoFar.stationList
  listbox .getDuplicateTrackage.listSoFar.stationList \
    -exportselection {0} \
    -font {Courier -12 bold} \
    -height {20} \
    -relief {flat} \
    -selectmode {none} \
    -width {60} \
    -yscrollcommand {.getDuplicateTrackage.listSoFar.stationListVScroll set}

  # build widget .getDuplicateTrackage.listSoFar.stationListVScroll
  scrollbar .getDuplicateTrackage.listSoFar.stationListVScroll \
    -command {.getDuplicateTrackage.listSoFar.stationList yview}

  # build widget .getDuplicateTrackage.buttons
  frame .getDuplicateTrackage.buttons \
    -borderwidth {2}

  # build widget .getDuplicateTrackage.buttons.button16
  button .getDuplicateTrackage.buttons.button16 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {CancelDuplicateTrackage}

  # build widget .getDuplicateTrackage.buttons.button17
  button .getDuplicateTrackage.buttons.button17 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {AddDuplicateTrackage}

  # build widget .getDuplicateTrackage.buttons.button18
  button .getDuplicateTrackage.buttons.button18 \
    -padx {9} \
    -pady {3} \
    -text {Finish} \
    -command {FinishDuplicateTrackage}

  # pack master .getDuplicateTrackage.banner
  pack configure .getDuplicateTrackage.banner.label6 \
    -side left
  pack configure .getDuplicateTrackage.banner.label7 \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getDuplicateTrackage.infoFrame
  pack configure .getDuplicateTrackage.infoFrame.from \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getDuplicateTrackage.infoFrame.label9 \
    -side left
  pack configure .getDuplicateTrackage.infoFrame.to \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getDuplicateTrackage.infoFrame.label11 \
    -side left
  pack configure .getDuplicateTrackage.infoFrame.dupfrom \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getDuplicateTrackage.infoFrame.label13 \
    -fill x \
    -side left
  pack configure .getDuplicateTrackage.infoFrame.dupto \
    -expand 1 \
    -fill x \
    -side left

  # pack master .getDuplicateTrackage.listSoFar
  pack configure .getDuplicateTrackage.listSoFar.stationList \
    -expand 1 \
    -fill both \
    -side left
  pack configure .getDuplicateTrackage.listSoFar.stationListVScroll \
    -fill y \
    -side right

  # pack master .getDuplicateTrackage.buttons
  pack configure .getDuplicateTrackage.buttons.button16 \
    -side left
  pack configure .getDuplicateTrackage.buttons.button18 \
    -side right
  pack configure .getDuplicateTrackage.buttons.button17 \
    -side right

  # pack master .getDuplicateTrackage
  pack configure .getDuplicateTrackage.banner \
    -fill x
  pack configure .getDuplicateTrackage.listSoFar \
    -fill both
  pack configure .getDuplicateTrackage.infoFrame \
    -fill x
  pack configure .getDuplicateTrackage.buttons \
    -fill x
# end of widget tree

  set w .getDuplicateTrackage
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

  tkwait window $w
}

proc CancelDuplicateTrackage {} {
# Procedure to cancel getting the duplicate track map. Bound to the Cancel button.
# [index] CancelDuplicateTrackage!procedure

  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Cancel Duplicate Trackage?} \
		-title {Cancel Duplicate Trackage} -type yesno] {yes}] == 0} {
    global DuplicateTrackMap
    catch {unset DuplicateTrackMap}
    destroy .getDuplicateTrackage
  }
}

proc AddDuplicateTrackage {} {
# Procedure to add to the duplicate track map. Bound to the Next button.
# [index] AddDuplicateTrackage!procedure

  global DuplicateTrackMap
  global SourceFrom SourceTo DestFrom DestTo

  set DuplicateTrackMap(${SourceFrom}=${SourceTo}) ${DestTo}=${DestFrom}
  .getDuplicateTrackage.listSoFar.stationList insert end "${SourceFrom}=${SourceTo} ${DestTo}=${DestFrom}"
}

proc FinishDuplicateTrackage {} {
# Procedure to finish adding to the duplicate track map. Bound to the Done button.
# [index] FinishDuplicateTrackage!procedure

  global DuplicateTrackMap
  global SourceFrom SourceTo DestFrom DestTo

  set DuplicateTrackMap(${SourceFrom}=${SourceTo}) ${DestTo}=${DestFrom}
  .getDuplicateTrackage.listSoFar.stationList insert end "${SourceFrom}=${SourceTo} ${DestTo}=${DestFrom}"
  tk_messageBox -icon info -message "Continue?" -type ok
  destroy .getDuplicateTrackage
}

proc AcquireStations {{filename {}}} {
# Procedure to acquire the station list. 
# <in> filename (optional) -- A possible file to load the stations from.
# [index] AcquireStations!procedure

  global Stations TotalLength
  if {[string length "$filename"] > 0} {
    LoadStations "$filename"
    return
  }
  set ans [tk_messageBox -icon question -default no -type yesnocancel \
		-message {Load Stations from a file?}]
  switch -exact -- "$ans" {
    yes {
	  LoadStations
	  if {$TotalLength == 0 || [catch {array names Stations}]} {
	    tk_messageBox -icon error -message {No stations!} -title {No stations} -type ok
	    exit
	  }
        }
    no  {
	  GetStations
	  if {$TotalLength == 0 || [catch {array names Stations}]} {
	    tk_messageBox -icon error -message {No stations!} -title {No stations} -type ok
	    exit
	  }
	  GetDuplicateTrackMap
	  set ans [tk_messageBox -icon question -default no -type yesno \
		-message {Save Stations to a file?}]
	  if {[string compare "$ans" {yes}] == 0} {SaveStations}
	  }
    cancel -
    default {exit}
  }
}

proc GetTimeInfo {} {
# Procedure to get time information.
# [index] GetTimeInfo!procedure

  global TotalTime TimeIncrement
# .getTimeInfo
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getTimeInfo
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getTimeInfo"
  } {
    catch "destroy .getTimeInfo"
  }
  toplevel .getTimeInfo 

  # Window manager configurations
  wm positionfrom .getTimeInfo ""
  wm sizefrom .getTimeInfo ""
  wm maxsize .getTimeInfo 1265 994
  wm minsize .getTimeInfo 1 1
  wm protocol .getTimeInfo WM_DELETE_WINDOW {.getTimeInfo.buttons.button49 invoke}
  wm title .getTimeInfo {Get Time Info}


  # build widget .getTimeInfo.banner
  frame .getTimeInfo.banner \
    -borderwidth {2}

  # build widget .getTimeInfo.banner.label38
  label .getTimeInfo.banner.label38 -image banner

  # build widget .getTimeInfo.banner.label39
  label .getTimeInfo.banner.label39 \
    -font {Helvetica -24 bold} \
    -text {Get Time Information}

  # build widget .getTimeInfo.info
  frame .getTimeInfo.info \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .getTimeInfo.info.totalTime
  frame .getTimeInfo.info.totalTime \
    -borderwidth {2}

  # build widget .getTimeInfo.info.totalTime.label42
  label .getTimeInfo.info.totalTime.label42 \
    -anchor {w} \
    -text {Total (Scale) Time:}

  # build widget .getTimeInfo.info.totalTime.hours
  entry .getTimeInfo.info.totalTime.hours \
    -width {2}

  # build widget .getTimeInfo.info.totalTime.label44
  label .getTimeInfo.info.totalTime.label44 \
    -text {:}

  # build widget .getTimeInfo.info.totalTime.minutes
  entry .getTimeInfo.info.totalTime.minutes \
    -width {2}

  # build widget .getTimeInfo.info.timeIncrement
  frame .getTimeInfo.info.timeIncrement \
    -borderwidth {2}

  # build widget .getTimeInfo.info.timeIncrement.label46
  label .getTimeInfo.info.timeIncrement.label46 \
    -anchor {w} \
    -text {Time Increment (scale): }

  # build widget .getTimeInfo.info.timeIncrement.minutes
  entry .getTimeInfo.info.timeIncrement.minutes \
    -width {2}

  # build widget .getTimeInfo.buttons
  frame .getTimeInfo.buttons \
    -borderwidth {2}

  # build widget .getTimeInfo.buttons.button48
  button .getTimeInfo.buttons.button48 \
    -padx {9} \
    -pady {3} \
    -text {Ok} \
    -command {SetTimeInfo}

  # build widget .getTimeInfo.buttons.button49
  button .getTimeInfo.buttons.button49 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {CancelTimeInfo}

#  # build widget .getTimeInfo.buttons.button50
#  button .getTimeInfo.buttons.button50 \
#    -padx {9} \
#    -pady {3} \
#    -text {Help}

  # pack master .getTimeInfo.banner
  pack configure .getTimeInfo.banner.label38 \
    -side left
  pack configure .getTimeInfo.banner.label39 \
    -fill x \
    -side right

  # pack master .getTimeInfo.info
  pack configure .getTimeInfo.info.totalTime \
    -fill x
  pack configure .getTimeInfo.info.timeIncrement \
    -fill x

  # pack master .getTimeInfo.info.totalTime
  pack configure .getTimeInfo.info.totalTime.label42 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getTimeInfo.info.totalTime.hours \
    -side left
  pack configure .getTimeInfo.info.totalTime.label44 \
    -side left
  pack configure .getTimeInfo.info.totalTime.minutes \
    -side left

  # pack master .getTimeInfo.info.timeIncrement
  pack configure .getTimeInfo.info.timeIncrement.label46 \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getTimeInfo.info.timeIncrement.minutes \
    -side right

  # pack master .getTimeInfo.buttons
  pack configure .getTimeInfo.buttons.button48 \
    -side right
  pack configure .getTimeInfo.buttons.button49 \
    -side left
#  pack configure .getTimeInfo.buttons.button50 \
#    -expand 1 \
#    -side right

  # pack master .getTimeInfo
  pack configure .getTimeInfo.banner
  pack configure .getTimeInfo.info \
    -expand 1 \
    -fill both
  pack configure .getTimeInfo.buttons \
    -expand 1 \
    -fill x

  .getTimeInfo.info.totalTime.hours insert end [format {%2d} [expr $TotalTime / 60]]
  .getTimeInfo.info.totalTime.minutes insert end [format {%02d} [expr $TotalTime % 60]]
  .getTimeInfo.info.timeIncrement.minutes insert end [format {%2d} $TimeIncrement]


# end of widget tree

  set w .getTimeInfo
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

  tkwait window $w
  
}

proc SetTimeInfo {} {
# Procedure to set the time information.  Bound to the OK button.
# [index] SetTimeInfo!procedure

  global TotalTime TimeIncrement
  set hours [string trim "[.getTimeInfo.info.totalTime.hours get]"]
  if {[regexp {^0*([0-9]+)$} "$hours" whole h] <= 0} {
    tk_messageBox -icon error -type ok \
		-message "Not a proper number of hours: $hours"
    return
  }
  set minutes [string trim "[.getTimeInfo.info.totalTime.minutes get]"]
  if {[regexp {^0*([0-9]+)$} "$minutes" whole m] <= 0} {
    tk_messageBox -icon error -type ok \
		-message "Not a proper number of minutes: $minutes"
    return
  }
  set incrmins [string trim "[.getTimeInfo.info.timeIncrement.minutes get]"]
  if {[regexp {^0*([1-9][0-9]*)$} "$incrmins" whole im] <= 0} {
    tk_messageBox -icon error -type ok \
	-message "Not a proper number of incremental minutes: $incrmins"
    return
  }
  set TotalTime [expr ($h * 60) + $m]
  set TimeIncrement $im
  destroy .getTimeInfo  
}

proc CancelTimeInfo {} {
# Procedure to cancel getting the time.  Bound to the Cancel button.
# [index] CancelTimeInfo!procedure

  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Cancel Get Time Info?} \
		-title {Cancel Time Info} -type yesno] {yes}] == 0} {
    destroy .getTimeInfo
  }
}

proc MakeChart {} {
# Procedure make the base chart area.
# [index] MakeChart!procedure

  global TotalTime TimeIncrement
  global Stations TotalLength
  global HasCabP HasTrackP HasChartP
  global StationYMap

  set numIncrs [expr int((double($TotalTime)+($TimeIncrement-1)) / double($TimeIncrement))]
  set cwidth   [expr ($numIncrs * 20) + 100 + 20]

  if {$HasCabP} {
    set topOff [lindex [.wholeChart.chartCanvas bbox CabFrame] 3]
  } else {
    set topOff 0
  }

  for {set m 0} {$m <= $TotalTime} {incr m 60} {
    set mx [expr 100 + (((double($m) / double($TimeIncrement)) * 20.0)) + 4]
    .wholeChart.chartCanvas create text $mx $topOff -anchor n \
			-text [format {%2d} [expr $m / 60]] -tag Header
  }
  set topOff [lindex [.wholeChart.chartCanvas bbox Header] 3]
  

  set cheight [expr [winfo reqheight .wholeChart.chartCanvas] - ($topOff + 2)]
  set cscrollreg [list 0 0 $cwidth [expr ($TotalLength * 20) + 20]]

  frame .wholeChart.chartCanvas.chartFrame -borderwidth {4} -relief {ridge}
  canvas .wholeChart.chartCanvas.chartFrame.theChart \
	-width $cwidth -height $cheight -scrollregion $cscrollreg \
	-yscrollcommand {.wholeChart.chartCanvas.chartFrame.theChartVScroll set} \
	-background white
  scrollbar .wholeChart.chartCanvas.chartFrame.theChartVScroll \
  	-command {.wholeChart.chartCanvas.chartFrame.theChart yview} \
	-orient {vertical}
  pack configure .wholeChart.chartCanvas.chartFrame.theChart -expand 1 \
	-fill both -side left
  pack configure .wholeChart.chartCanvas.chartFrame.theChartVScroll -fill y \
	-side right
  .wholeChart.chartCanvas create window 0 $topOff -anchor nw \
	-window .wholeChart.chartCanvas.chartFrame -tag ChartFrame
  update idletasks
  set oldscrollreg [.wholeChart.chartCanvas cget -scrollregion]
  set newscrollreg [lreplace $oldscrollreg 2 2 [winfo reqwidth .wholeChart.chartCanvas.chartFrame]]
  .wholeChart.chartCanvas configure -scrollregion $newscrollreg
  for {set m 0} {$m <= $TotalTime} {incr m $TimeIncrement} {
    set mx [expr 100 + (((double($m) / double($TimeIncrement)) * 20.0))]
    set lw 1
    if {[expr $m % 60] == 0} {set lw 2}
    .wholeChart.chartCanvas.chartFrame.theChart create \
	line $mx 10 $mx [expr ($TotalLength * 20) + 10] -width $lw
  }
  foreach s [lsort -command StationDistanceComp [array names Stations]] {
    set dist $Stations($s)
    set sy [expr ($dist * 20) + 10]
    set StationYMap($s) $sy
    set lab [TruncateToFit "$s" 100 .wholeChart.chartCanvas.chartFrame.theChart]
    .wholeChart.chartCanvas.chartFrame.theChart create text 0 $sy \
	-anchor w -text "$lab"
    .wholeChart.chartCanvas.chartFrame.theChart create line \
	100 $sy \
	[expr 100 + (((double($TotalTime) / double($TimeIncrement)) * 20.0))] $sy \
	-width $lw
  }
  set HasChartP 1
}

proc TruncateToFit {s wid canvas} {
# Procedure to truncate a string to fit a certain pixel width.  Used to 
# generate labels on the chart.
# <in> s -- string to truncate.
# <in> wid -- pixel width available.
# <in> canvas -- the canvas the label will be drawn on.
# [index] TruncateToFit!procedure

  while {1} {
    set i [$canvas create text 0 0 -anchor nw -text "$s"]
    set width [lindex [$canvas bbox $i] 2]
    $canvas delete $i
    if {$width <= $wid} {return "$s"}
    set s [string range "$s" 0 [expr [string length "$s"] - 2]]
  }
}

proc GetCabInfo {} {
# Procedure to get cab info.
# [index] GetCabInfo!procedure

  global HasCabP CabColors

# .getCabInfo
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getCabInfo
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getCabInfo"
  } {
    catch "destroy .getCabInfo"
  }
  toplevel .getCabInfo 

  # Window manager configurations
  wm positionfrom .getCabInfo ""
  wm sizefrom .getCabInfo ""
  wm maxsize .getCabInfo 1009 738
  wm minsize .getCabInfo 1 1
  wm protocol .getCabInfo WM_DELETE_WINDOW {.getCabInfo.buttons.button11 invoke}
  wm title .getCabInfo {Get Cab Info}


  # build widget .getCabInfo.banner
  frame .getCabInfo.banner \
    -borderwidth {2}

  # build widget .getCabInfo.banner.label4
  label .getCabInfo.banner.label4  -image banner

  # build widget .getCabInfo.banner.label5
  label .getCabInfo.banner.label5 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Get Cab Info}

  # build widget .getCabInfo.listSoFar
  frame .getCabInfo.listSoFar \
    -borderwidth {2} \
    -relief {groove}

  # build widget .getCabInfo.listSoFar.stationList
  listbox .getCabInfo.listSoFar.stationList \
    -exportselection {0} \
    -font {Courier -12 bold} \
    -height {20} \
    -relief {flat} \
    -selectmode {none} \
    -width {60} \
    -yscrollcommand {.getCabInfo.listSoFar.stationListVScroll set}

  # build widget .getCabInfo.listSoFar.stationListVScroll
  scrollbar .getCabInfo.listSoFar.stationListVScroll \
    -command {.getCabInfo.listSoFar.stationList yview}

  # build widget .getCabInfo.newCabInfo
  frame .getCabInfo.newCabInfo \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .getCabInfo.newCabInfo.label6
  label .getCabInfo.newCabInfo.label6 \
    -text {Cab Name:}

  # build widget .getCabInfo.newCabInfo.name
  entry .getCabInfo.newCabInfo.name

  # build widget .getCabInfo.newCabInfo.label8
  label .getCabInfo.newCabInfo.label8 \
    -text {Cab Color:}

  # build widget .getCabInfo.newCabInfo.color
  entry .getCabInfo.newCabInfo.color

  # build widget .getCabInfo.newCabInfo.button10
  button .getCabInfo.newCabInfo.button10 \
    -padx {9} \
    -pady {3} \
    -text {Browse} \
    -command {
	set newColor [tk_chooseColor -initialcolor "[.getCabInfo.newCabInfo.color get]" -parent .getCabInfo -title {Choose a Cab Color}]
	if {[string length "$newColor"] > 0} {
	  .getCabInfo.newCabInfo.color delete 0 end
	  .getCabInfo.newCabInfo.color insert end "$newColor"
	}
    }

  # build widget .getCabInfo.buttons
  frame .getCabInfo.buttons \
    -borderwidth {2}

  # build widget .getCabInfo.buttons.button11
  button .getCabInfo.buttons.button11 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {CancelGetCabInfo}

  # build widget .getCabInfo.buttons.button12
  button .getCabInfo.buttons.button12 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {AddCabInfo}

  # build widget .getCabInfo.buttons.button13
  button .getCabInfo.buttons.button13 \
    -padx {9} \
    -pady {3} \
    -text {Finish} \
    -command {FinishCabInfo}

  # pack master .getCabInfo.banner
  pack configure .getCabInfo.banner.label4 \
    -side left
  pack configure .getCabInfo.banner.label5 \
    -anchor w \
    -expand 1 \
    -side right

  # pack master .getCabInfo.listSoFar
  pack configure .getCabInfo.listSoFar.stationList \
    -expand 1 \
    -fill both \
    -side left
  pack configure .getCabInfo.listSoFar.stationListVScroll \
    -fill y \
    -side right

  # pack master .getCabInfo.newCabInfo
  pack configure .getCabInfo.newCabInfo.label6 \
    -side left
  pack configure .getCabInfo.newCabInfo.name \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getCabInfo.newCabInfo.label8 \
    -side left
  pack configure .getCabInfo.newCabInfo.color \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getCabInfo.newCabInfo.button10 \
    -side right

  # pack master .getCabInfo.buttons
  pack configure .getCabInfo.buttons.button11 \
    -side left
  pack configure .getCabInfo.buttons.button13 \
    -side right
  pack configure .getCabInfo.buttons.button12 \
    -side right

  # pack master .getCabInfo
  pack configure .getCabInfo.banner \
    -fill x
  pack configure .getCabInfo.listSoFar \
    -fill both
  pack configure .getCabInfo.newCabInfo \
    -expand 1 \
    -fill x
  pack configure .getCabInfo.buttons \
    -fill x

  .getCabInfo.newCabInfo.name insert end {}
  .getCabInfo.newCabInfo.color insert end {}


# end of widget tree

  set w .getCabInfo
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

  tkwait window $w

}

proc CancelGetCabInfo {} {
# Procedure to cancel getting the cab info.  Bound to the Cancel button.
# [index] CancelGetCabInfo!procedure

  global HasCabP CabColors

  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Cancel Get Cab Info?} \
		-title {Cancel Cab Info} -type yesno] {yes}] == 0} {
    set HasCabP 0
    catch {unset CabColors}
    destroy .getCabInfo
  }
}

proc AddCabInfo {} {
# Procedure to add a cab.  Bound to the Next button.
# [index] AddCabInfo!procedure

  global HasCabP CabColors

  set Cname "[string trim [.getCabInfo.newCabInfo.name get]]"
  set Ccolor "[string trim [.getCabInfo.newCabInfo.color get]]"

  if {[string length "$Cname"] == 0} {
    tk_messageBox -icon error -type ok \
	-message "Missing Cab name!"
    return
  }
  if {[HasForbiddenCharsP "$Cname" {%|}]} {
    tk_messageBox -icon error -message "Cab name contains forbidden charactors (%|): $Cname!" -type ok
    return
  }
  if {[string length "$Ccolor"] == 0} {
    tk_messageBox -icon error -type ok \
	-message "Missing Cab color!"
    return
  }
  if {[NotLegalColor $Ccolor]} {
    tk_messageBox -icon error -type ok -message "Not a legal color: $Ccolor!"
    return
  }
  if {[catch [list array names CabColors "$Cname"] match]} {
    set match {}
  }
  if {[llength $match] == 0} {
    set CabColors($Cname) "$Ccolor"
    .getCabInfo.listSoFar.stationList insert end "[format {%-30s %30s} $Cname $Ccolor]"
    return
  } else {
    tk_messageBox -icon error -message "Duplicate Cab: $Cname" -type ok
    return
  }
  
}

proc FinishCabInfo {} {
# Procedure to finish adding cabs.  Bound to the Done button.
# [index] FinishCabInfo!procedure

  global HasCabP CabColors

  set Cname "[string trim [.getCabInfo.newCabInfo.name get]]"
  set Ccolor "[string trim [.getCabInfo.newCabInfo.color get]]"

  if {[string length "$Cname"] == 0} {
    tk_messageBox -icon error -type ok \
	-message "Missing Cab name!"
    return
  }
  if {[HasForbiddenCharsP "$Cname" {%|}]} {
    tk_messageBox -icon error -message "Cab name contains forbidden charactors (%|): $Cname!" -type ok
    return
  }
  if {[string length "$Ccolor"] == 0} {
    tk_messageBox -icon error -type ok \
	-message "Missing Cab color!"
    return
  }
  if {[catch [list array names CabColors "$Cname"] match]} {
    set match {}
  }
  if {[llength $match] == 0} {
    set CabColors($Cname) "$Ccolor"
    .getCabInfo.listSoFar.stationList insert end "[format {%-30s %30s} $Cname $Ccolor]"
    tk_messageBox -icon info -message "Continue?" -type ok
    destroy .getCabInfo
  } else {
    tk_messageBox -icon error -message "Duplicate Cab: $Cname" -type ok
    return
  }
}

proc MakeCabs {} {
# Procedure to create the cab section of the chart.
# [index] MakeCabs!procedure

  global HasCabP CabColors CabYMap
  global TotalTime TimeIncrement

  if {[catch [list array names CabColors] CabNames]} {return}
  if {[llength "$CabNames"] == 0} {return}

  set numIncrs [expr int((double($TotalTime)+($TimeIncrement-1)) / double($TimeIncrement))]
  set cwidth   [expr ($numIncrs * 20) + 100 + 20]

  set CabNames [lsort -dictionary $CabNames]
  set cheight 100
  set cscrollreg  [list 0 0 $cwidth [expr ([llength $CabNames] * 25) + 5]]

  frame .wholeChart.chartCanvas.cabFrame -borderwidth {4} -relief {ridge}
  canvas .wholeChart.chartCanvas.cabFrame.theCabs \
  	-width $cwidth -height $cheight -scrollregion $cscrollreg \
	-yscrollcommand {.wholeChart.chartCanvas.cabFrame.theCabVScroll set} \
	-background grey
  scrollbar .wholeChart.chartCanvas.cabFrame.theCabVScroll \
	-command {.wholeChart.chartCanvas.cabFrame.theCabs yview} \
	-orient {vertical}
  pack configure .wholeChart.chartCanvas.cabFrame.theCabs -expand 1 \
	-fill both -side left
  pack configure .wholeChart.chartCanvas.cabFrame.theCabVScroll -fill y \
	-side right
  .wholeChart.chartCanvas create window 0 0 -anchor nw \
	-window .wholeChart.chartCanvas.cabFrame -tag CabFrame
  update idletasks
  set yoffTop 5
  foreach c $CabNames {
    set ty [expr $yoffTop + 10]
    set CabYMap($c) $ty
    set lab [TruncateToFit "$c" 100 .wholeChart.chartCanvas.cabFrame.theCabs]
    .wholeChart.chartCanvas.cabFrame.theCabs create text 0 $ty \
    	-anchor w -text "$lab" -fill $CabColors($c)
    .wholeChart.chartCanvas.cabFrame.theCabs create rectangle \
	100 $yoffTop \
	[expr 100 + (((double($TotalTime) / double($TimeIncrement)) * 20.0))] \
	[expr $yoffTop + 20] -fill {} -outline black -width 2
    incr yoffTop 25
  }  
  set HasCabP 1
  set vm [GetMenuByName View]
  $vm entryconfigure {Cabs} -state normal
}

proc LoadCabs {{filename {}}} {
# Procedure to load cab colors from a file.
# <in> filename (optional) -- name of a file to load cab colors from.
# [index] LoadCabs!procedure

  global CabColors CabFileTypes
  if {[string length "$filename"] == 0} {
    set filename "[tk_getOpenFile -defaultextension .cabs \
				-filetypes $CabFileTypes \
				-title {Cab File To Load}]"
  }
  if {[string length "$filename"] == 0} {return}
  if {[catch [list open "$filename" r] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening cab file $filename for input: $sfp" \
		  -type ok
    return
  }
  catch {unset CabColors}
  while {[gets $sfp Line] >= 0} {
    set sd [split "$Line" {|}]
    if {[llength $sd] == 2} {set CabColors([lindex $sd 0]) [lindex $sd 1]}
  }
  close $sfp
}

proc SaveCabs {{filename {}}} {
# Procedure to save cab colors to a file.
# <in> filename (optional) -- name of a file to save cab colors to.
# [index] SaveCabs!procedure

  global CabColors CabFileTypes
  if {[string length "$filename"] == 0} {
    set filename "[tk_getSaveFile -defaultextension .cabs \
				-filetypes $CabFileTypes \
				-initialfile Cabs.cabs \
				-title {Cab File To Save Cabs To}]"
  }
  if {[string length "$filename"] == 0} {return}
  if {[catch [list open "$filename" w] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening cab file $filename for output: $sfp" \
		  -type ok
    return
  }
  foreach s [lsort -dictionary [array names CabColors]] {
    puts $sfp "$s|$CabColors($s)"
  }
  close $sfp
}

proc AcquireCabInfo {{filename {}}} {
# Procedure to acquire cab info.
# <in> filename (optional) -- name of a file to load cab colors from.
# [index] AcquireCabInfo!procedure

  global CabColors
  if {[string length "$filename"] > 0} {
    LoadCabs "$filename"
    return
  }
  set ans [tk_messageBox -icon question -default no -type yesnocancel \
	-message {Load Cabs from a file?}]
  switch -exact -- "$ans" {
    yes {LoadCabs}
    no {
	GetCabInfo
	if {[catch [list array names CabColors] CabNames]} {return}
	if {[llength "$CabNames"] == 0} {return}
	set ans [tk_messageBox -icon question -default no -type yesno \
		-message {Save Cab Info to a file?}]
	if {[string compare "$ans" {yes}] == 0} {SaveCabs}
	}
    cancel -
    default {}
  }
}

proc GetStorageTracks {} {
# Procedure to get storage tracks.
# [index] GetStorageTracks!procedure

# .getStorageTracks
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getStorageTracks
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getStorageTracks"
  } {
    catch "destroy .getStorageTracks"
  }
  toplevel .getStorageTracks 

  # Window manager configurations
  wm positionfrom .getStorageTracks ""
  wm sizefrom .getStorageTracks ""
  wm maxsize .getStorageTracks 1009 738
  wm minsize .getStorageTracks 1 1
  wm protocol .getStorageTracks WM_DELETE_WINDOW {.getStorageTracks.buttons.button22 invoke}
  wm title .getStorageTracks {Get Storage Tracks}


  # build widget .getStorageTracks.banner
  frame .getStorageTracks.banner \
    -borderwidth {2}

  # build widget .getStorageTracks.banner.label18
  label .getStorageTracks.banner.label18  -image banner

  # build widget .getStorageTracks.banner.label19
  label .getStorageTracks.banner.label19 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Get Storage Tracks}

  # build widget .getStorageTracks.listSoFar
  frame .getStorageTracks.listSoFar \
    -borderwidth {2} \
    -relief {groove}

  # build widget .getStorageTracks.listSoFar.stationList
  listbox .getStorageTracks.listSoFar.stationList \
    -exportselection {0} \
    -font {Courier -12 bold} \
    -height {20} \
    -relief {flat} \
    -selectmode {none} \
    -width {60} \
    -yscrollcommand {.getStorageTracks.listSoFar.stationListVScroll set}

  # build widget .getStorageTracks.listSoFar.stationListVScroll
  scrollbar .getStorageTracks.listSoFar.stationListVScroll \
    -command {.getStorageTracks.listSoFar.stationList yview}

  # build widget .getStorageTracks.trackInfo
  frame .getStorageTracks.trackInfo \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .getStorageTracks.trackInfo.label20
  label .getStorageTracks.trackInfo.label20 \
    -text {Track Identification:}

  # build widget .getStorageTracks.trackInfo.station
  global StorageTrackStation
  StationOptionMenu .getStorageTracks.trackInfo.station StorageTrackStation

  # build widget .getStorageTracks.trackInfo.name
  entry .getStorageTracks.trackInfo.name

  # build widget .getStorageTracks.buttons
  frame .getStorageTracks.buttons \
    -borderwidth {2}

  # build widget .getStorageTracks.buttons.button22
  button .getStorageTracks.buttons.button22 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {CancelGetStorageTracks}

  # build widget .getStorageTracks.buttons.button23
  button .getStorageTracks.buttons.button23 \
    -padx {9} \
    -pady {3} \
    -text {Finish} \
    -command {FinishStorageTracks}

  # build widget .getStorageTracks.buttons.button24
  button .getStorageTracks.buttons.button24 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {AddStorageTrack}

  # pack master .getStorageTracks.banner
  pack configure .getStorageTracks.banner.label18 \
    -side left
  pack configure .getStorageTracks.banner.label19 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getStorageTracks.listSoFar
  pack configure .getStorageTracks.listSoFar.stationList \
    -expand 1 \
    -fill both \
    -side left
  pack configure .getStorageTracks.listSoFar.stationListVScroll \
    -fill y \
    -side right

  # pack master .getStorageTracks.trackInfo
  pack configure .getStorageTracks.trackInfo.label20 \
    -side left
  pack configure .getStorageTracks.trackInfo.station \
    -side left
  pack configure .getStorageTracks.trackInfo.name \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getStorageTracks.buttons
  pack configure .getStorageTracks.buttons.button22 \
    -side left
  pack configure .getStorageTracks.buttons.button23 \
    -side right
  pack configure .getStorageTracks.buttons.button24 \
    -side right

  # pack master .getStorageTracks
  pack configure .getStorageTracks.banner \
    -fill x
  pack configure .getStorageTracks.listSoFar \
    -fill both
  pack configure .getStorageTracks.trackInfo \
    -fill x
  pack configure .getStorageTracks.buttons \
    -fill x

  .getStorageTracks.trackInfo.name insert end {}


# end of widget tree

  set w .getStorageTracks
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

  tkwait window $w

}

proc CancelGetStorageTracks {} {
# Procedure to cancel getting storage tracks.  Bound to the Cancel button.
# [index] CancelGetStorageTracks!procedure

  global TrackList
  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Cancel Get Storage Tracks?} \
		-title {Cancel Storage Tracks} -type yesno] {yes}] == 0} {
    catch {unset TrackList}
    destroy .getStorageTracks
  }
}

proc FinishStorageTracks {} {
# Procedure to finush getting storage tracks.  Bound to the Done button.
# [index] FinishStorageTracks!procedure

  global TrackList StorageTrackStation
  set trackname [string trim "[.getStorageTracks.trackInfo.name get]"]
  if {[string length "$trackname"] == 0} {
    tk_messageBox -icon error -type ok \
	-message "Missing Track name!"
    return
  }
  if {[HasForbiddenCharsP "$trackname" {%|}]} {
    tk_messageBox -icon error -message "Track name contains forbidden charactors (%|): $trackname!" -type ok
    return
  }
  if {[llength [array names TrackList $StorageTrackStation]] > 0} {
    if {[lsearch -exact "$TrackList($StorageTrackStation)" "$trackname"] >= 0} {
      tk_messageBox -icon error -message "Duplicate Track: $trackname" -type ok
      return
    }
    lappend TrackList($StorageTrackStation) "$trackname"
  } else {
    set TrackList($StorageTrackStation) [list "$trackname"]
  }
  .getStorageTracks.listSoFar.stationList insert end "[format {%-30s %28s} $StorageTrackStation $trackname]"
  tk_messageBox -icon info -message "Continue?" -type ok
  destroy .getStorageTracks  
}

proc AddStorageTrack {} {
# Procedure to add a storage track.  Bound to the Next button.
# [index] AddStorageTracks!procedure

  global TrackList StorageTrackStation

  set trackname [string trim "[.getStorageTracks.trackInfo.name get]"]
  if {[string length "$trackname"] == 0} {
    tk_messageBox -icon error -type ok \
	-message "Missing Track name!"
    return
  }
  if {[HasForbiddenCharsP "$trackname" {%|}]} {
    tk_messageBox -icon error -message "Track name contains forbidden charactors (%|): $trackname!" -type ok
    return
  }
  if {[llength [array names TrackList $StorageTrackStation]] > 0} {
    if {[lsearch -exact "$TrackList($StorageTrackStation)" "$trackname"] >= 0} {
      tk_messageBox -icon error -message "Duplicate Track: $trackname" -type ok
      return
    }
    lappend TrackList($StorageTrackStation) "$trackname"
  } else {
    set TrackList($StorageTrackStation) [list "$trackname"]
  }
  .getStorageTracks.listSoFar.stationList insert end "[format {%-30s %28s} $StorageTrackStation $trackname]"
}

proc LoadStorageTracks {{filename {}}} {
# Procedure to load a storage track map.
# <in> filename (optional) -- file to load storage track map from.
# [index] LoadStorageTracks!procedure

  global TrackList StorageTrackFileTypes
  if {[string length "$filename"] == 0} {
    set filename "[tk_getOpenFile -defaultextension .tracks \
				-filetypes $StorageTrackFileTypes \
				-title {Storage Track File To Load}]"
  }
  if {[string length "$filename"] == 0} {return}
  if {[catch [list open "$filename" r] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening storage track file $filename for input: $sfp" \
		  -type ok
    return
  }
  catch {unset TrackList}
  while {[gets $sfp Line] >= 0} {
    set st [split "$Line" {|}]
    if {[llength $st] == 2} {set TrackList([lindex $st 0]) [lindex $s 1]}
  }
  close $sfp
}

proc SaveStorageTracks {{filename {}}} {
# Procedure to save a storage track map.
# <in> filename (optional) -- file to save storage track map to.
# [index] SaveStorageTracks!procedure

  global TrackList StorageTrackFileTypes
  if {[string length "$filename"] == 0} {
    set filename "[tk_getSaveFile -defaultextension .tracks \
				-filetypes $StorageTrackFileTypes \
				-initialfile Tracks.tracks \
				-title {Storage Track To Save Storage Tracks To}]"
  }
  if {[string length "$filename"] == 0} {return}
  if {[catch [list open "$filename" w] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening storage track file $filename for output: $sfp" \
		  -type ok
    return
  }
  foreach t [lsort -dictionary [array names TrackList]] {
    puts $sfp "$t|$TrackList($t)"
  }
  close $sfp
}

proc AcquireTracks {{filename {}}} {
# Procedure to acquire a storage track map.
# <in> filename (optional) -- file to load storage track map from.
# [index] AcquireTracks!procedure

  global TrackList
  if {[string length "$filename"] > 0} {
    LoadStorageTracks "$filename"
    return
  }
  set ans [tk_messageBox -icon question -default no -type yesnocancel \
	-message {Load Storage Tracks from a file?}]
  switch -exact -- "$ans" {
    yes {LoadStorageTracks}
    no {
	GetStorageTracks
	if {[llength [array names TrackList]] > 0} {
	  set ans [tk_messageBox -icon question -default no -type yesno \
			-message {Save Storage Tracks to a file?}]
	  if {[string compare "$ans" {yes}] == 0} {SaveStorageTracks}
	}
    }
    cancel -
    default {}
  }
}

proc MakeTracks {} {
# Procedure to draw the storage track map usage map.
# [index] MakeTracks!procedure

  global HasTrackP TrackList TrackYMap
  global TotalTime TimeIncrement
  
  if {[llength [array names TrackList]] == 0} {return}

  set numIncrs [expr int((double($TotalTime)+($TimeIncrement-1)) / double($TimeIncrement))]
  set cwidth   [expr ($numIncrs * 20) + 100 + 20]

  set trackListStations [lsort -dictionary [array names TrackList]]
  set numTracks 0
  foreach st $trackListStations {incr numTracks [llength $TrackList($st)]}
  set cheight 100
  set cscrollreg  [list 0 0 $cwidth [expr ($numTracks * 25) + 5]]

  set trackOff [expr [winfo height .wholeChart.chartCanvas] - $cheight]
  .wholeChart.chartCanvas.chartFrame.theChart configure -height \
	[expr [winfo height .wholeChart.chartCanvas.chartFrame.theChart] - $cheight]

  frame .wholeChart.chartCanvas.trackFrame -borderwidth {4} -relief {ridge}
  canvas .wholeChart.chartCanvas.trackFrame.theTracks \
	-width $cwidth -height $cheight -scrollregion $cscrollreg \
	-yscrollcommand {.wholeChart.chartCanvas.trackFrame.theTrackVScroll set} \
	-background grey
  scrollbar .wholeChart.chartCanvas.trackFrame.theTrackVScroll \
	-command {.wholeChart.chartCanvas.trackFrame.theTracks yview} \
	-orient {vertical}
  pack configure .wholeChart.chartCanvas.trackFrame.theTracks -expand 1 \
	-fill both -side left
  pack configure .wholeChart.chartCanvas.trackFrame.theTrackVScroll -fill y \
	-side right
  .wholeChart.chartCanvas create window 0 $trackOff -anchor nw \
	-window .wholeChart.chartCanvas.trackFrame -tag TrackFrame
  update idletasks
  set yoffTop 5
  foreach str $trackListStations {
    foreach xtr [lsort -dictionary $TrackList($str)] {
      set tr "$xtr @ $str"
      set ty [expr $yoffTop + 10]
      set TrackYMap($str,$xtr) $ty
      set lab [TruncateToFit "$tr" 100 .wholeChart.chartCanvas.trackFrame.theTracks]
      .wholeChart.chartCanvas.trackFrame.theTracks create text 0 $ty \
	-anchor w -text "$lab"
      .wholeChart.chartCanvas.trackFrame.theTracks create rectangle \
	100 $yoffTop \
	[expr 100 + (((double($TotalTime) / double($TimeIncrement)) * 20.0))] \
	[expr $yoffTop + 20] -fill {} -outline black -width 2
      incr yoffTop 25
    }
  }
  set HasTrackP 1
  set vm [GetMenuByName View]
  $vm entryconfigure {Storage Tracks} -state normal
}

proc SaveChart {} {
# Procedure to save the current chart. Bound to the Save button and menu item.
# [index] SaveChart!procedure

  global HasChartFileP ChartFile
  if {!$HasChartFileP} {
    SaveChartAs
  } else {
    SaveCompleteChart "$ChartFile"
  }
}

proc SaveChartAs {} {
# Procedure to save the current chart. Bound to the Save As menu item.
# [index] SaveAsChart!procedure

  global HasChartFileP ChartFile ChartFileTypes

  if {$HasChartFileP} {
    set initFile "$ChartFile"
  } else {
    set initFile "Chart.chart"
  }

  set filename "[tk_getSaveFile -defaultextension .chart \
				-filetypes $ChartFileTypes \
				-initialfile "$initFile" \
				-title {Chart File to save chart to} \
				-parent .]"
  if {[string length "$filename"] == 0} {return}
  set ChartFile "$filename"
  set HasChartFileP 1
  SaveCompleteChart "$ChartFile"
}

proc SaveCompleteChart {{filename {}}} {
# Procedure to save a complete chart. Workhorse function under Save and Save As.
# <in> filename (optional) -- name of a file to save chart data to.
# [index] SaveCompleteChart!procedure

  global ChartFileTypes
  if {[string length "$filename"] == 0} {
    set filename "[tk_getSaveFile -defaultextension .chart \
				-filetypes $ChartFileTypes \
				-initialfile "$initFile" \
				-title {Chart File to save chart to} \
				-parent .]"
  }
  if {[string length "$filename"] == 0} {return}
  global CabColors TrackList
  global HasCabP HasTrackP
  global Stations TotalLength DuplicateTrackMap
  global TotalTime TimeIncrement
  global Trains
  global StorageTrackMap
  global Notes

  if {[catch [list open "$filename" w] chfp]} {
    tk_messageBox -icon error \
	-message "Error opening chart file $filename for for output: $chfp" \
	-type ok
    return
  }

  puts $chfp [list %%%TIMESCALE: $TotalTime $TimeIncrement]
  puts $chfp "%%%CABCOLORS:"
  foreach s [lsort -dictionary [array names CabColors]] {
    puts $chfp "$s|$CabColors($s)"
  }

  puts $chfp [list %%%STATIONTOTALLENGTH:$TotalLength]
  foreach s [lsort -command StationDistanceComp [array names Stations]] {
    puts $chfp "$s|$Stations($s)"
  }

  puts $chfp "%%%DUPLICATETRACKMAP:"
  foreach d [array names DuplicateTrackMap] {
    puts $chfp "$d|$DuplicateTrackMap($d)"
  }

  puts $chfp "%%%STORAGETRACKS:"
  foreach t [lsort -dictionary [array names TrackList]] {
    puts $chfp "$t|$TrackList($t)"
  }
  puts $chfp "%%%TRAINS:"
  foreach s [lsort [array names Trains]] {
    puts $chfp "$s|$Trains($s)"
  }

  puts $chfp "%%%STORAGETRACKMAP:"
  foreach s [lsort [array names StorageTrackMap]] {
    puts $chfp "$s|$StorageTrackMap($s)"
  }
  puts $chfp "%%%NOTES:"
  foreach n [lsort -integer [array names Notes]] {
    puts $chfp "$n|[QuoteNL $Notes($n)]"
  }
  close $chfp
}

proc QuoteNL {s} {
# Procedure to quote newlines.
# <in> s -- string possibly containing newline characters.
# [index] QuoteNL!procedure

  regsub -all "\n" "$s" {\\n} s
  return "$s"
}

proc UnQuoteNL {s} {
# Procedure to unquote newlines.
# <in> s -- string possibly containing backquoted n sequences.
# [index] UnQuoteNL!procedure

  regsub -all {\\n} "$s" "\n" s
  return "$s"
}

proc LoadCompleteChart {{filename {}}} {
# Procedure to load a complete chart.  Workhorse behind the Open menu item.
# <in> filename (optional) -- name of a file containing a complete chart.
# [index] LoadCompleteChart!procedure

  global ChartFileTypes
  if {[string length "$filename"] == 0} {
    set filename "[tk_getOpenFile -defaultextension .chart \
				-filetypes $ChartFileTypes \
				-title {Chart File To Load}]"
  }
  if {[string length "$filename"] == 0} {return}
  global CabColors TrackList
  global HasCabP HasTrackP HasChartP 
  global Stations TotalLength DuplicateTrackMap
  global TotalTime TimeIncrement
  global Trains
  global StorageTrackMap
  global Notes
  set TotalTime [expr 24 * 60]
  set TimeIncrement 15
  .wholeChart.chartCanvas delete all
  catch {unset CabColors}
  catch {destroy .wholeChart.chartCanvas.cabFrame}
  set HasCabP 0
  catch {unset TrackList}
  catch {destroy .wholeChart.chartCanvas.trackFrame}  
  set HasTrackP 0
  set TotalLength 0
  catch {unset Stations}
  catch {unset DuplicateTrackMap}
  catch {unset Trains}
  catch {unset StorageTrackMap}
  catch {unset Notes}
  catch {destroy .wholeChart.chartCanvas.chartFrame}
  set HasChartP 0  

  if {[catch [list open "$filename" r] chfp]} {
    tk_messageBox -icon error \
		  -message "Error opening chart file $filename for input: $chfp" \
		  -type ok
    return
  }

  set Line "[gets $chfp]"
  set ll [split $Line]
  if {[string compare "[lindex $ll 0]" {%%%TIMESCALE:}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%TIMESCALE:!" \
	-type ok
    return 0
  }
  set TotalTime [lindex $ll 1]
  set TimeIncrement [lindex $ll 2]
  set Line "[gets $chfp]"
  if {[string compare "$Line" {%%%CABCOLORS:}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%CABCOLORS:!" \
	-type ok
    return 0
  }
  set sd {}
  while {[gets $chfp Line] >= 0} {
    set sd [split "$Line" {:}]
    if {[string compare "[lindex $sd 0]" {%%%STATIONTOTALLENGTH}] == 0} {break}
    if {[llength $sd] == 2} {set CabColors([lindex $sd 0]) [lindex $sd 1]}
  }
  if {[string compare "[lindex $sd 0]" {%%%STATIONTOTALLENGTH}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%STATIONTOTALLENGTH:!" \
	-type ok
    return 0
  }
  set TotalLength [lindex $sd 1]
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%DUPLICATETRACKMAP:}] == 0} {break}
    set sd [split "$Line" {|}]
    if {[llength $sd] == 2} {set Stations([lindex $sd 0]) [lindex $sd 1]}
  }
  if {[string compare "$Line" {%%%DUPLICATETRACKMAP:}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%DUPLICATETRACKMAP:!" \
	-type ok
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%STORAGETRACKS:}] == 0} {break}
    set dd [split "$Line" {|}]   
    if {[llength $dd] == 2} {set DuplicateTrackMap([lindex $dd 0]) [lindex $dd 1]}
  }
  if {[string compare "$Line" {%%%STORAGETRACKS:}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%STORAGETRACKS:!" \
	-type ok
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%TRAINS:}] == 0} {break}
    set st [split "$Line" {|}]
    if {[llength $st] == 2} {set TrackList([lindex $st 0]) [lindex $s 1]}
  }
  if {[string compare "$Line" {%%%TRAINS:}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%TRAINS:!" \
	-type ok
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%STORAGETRACKMAP:}] == 0} {break}
    set dd [split "$Line" {|}]
    if {[llength $dd] == 2} {set Trains([lindex $dd 0]) [lindex $dd 1]}
  }
  if {[string compare "$Line" {%%%STORAGETRACKMAP:}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%STORAGETRACKMAP:!" \
	-type ok
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    if {[string compare "$Line" {%%%NOTES:}] == 0} {break}
    set dd [split "$Line" {|}]
    if {[llength $dd] == 2} {set StorageTrackMap([lindex $dd 0]) [lindex $dd 1]}
  }
  if {[string compare "$Line" {%%%NOTES:}] != 0} {
    tk_messageBox -icon error \
	-message "Syntax error in $filename: expected %%%NOTES:!" \
	-type ok
    return 0
  }
  while {[gets $chfp Line] >= 0} {
    set dd [split "$Line" {|}]
    if {[llength $dd] == 2} {
      set Notes([lindex $dd 0]) "[UnQuoteNL [lindex $dd 1]]"
    }
  }
  close $chfp
  MakeCabs
  MakeChart
  MakeTracks
  foreach tr [lsort -integer [array names Trains]] {
    DrawTrain $tr
  }
  foreach tk [array names StorageTrackMap] {
    DrawStorageTrack $tk
  }
  return 1
}

proc NewChart {{ask 1}} {
# Procedure to create a new empty chart.  Workhorse behind New menu item.
# <in> ask (optional, default 1) -- flag to indicate whether the user should be asked first.
# [index] NewChart!procedure

  if {$ask} {
    set ans [tk_messageBox -icon question -default cancel -type okcancel \
		-message {Really clear off your chart?}]
    if {[string compare "$ans" {cancel}] == 0} {return}
  }
  wm withdraw .
  global CabColors TrackList
  global HasCabP HasTrackP HasChartP 
  global Stations TotalLength DuplicateTrackMap
  global TotalTime TimeIncrement
  global Trains
  global StorageTrackMap
  set TotalTime [expr 24 * 60]
  set TimeIncrement 15
  .wholeChart.chartCanvas delete all
  catch {unset CabColors}
  catch {destroy .wholeChart.chartCanvas.cabFrame}
  set HasCabP 0
  set TrackList {}
  catch {destroy .wholeChart.chartCanvas.trackFrame}  
  set HasTrackP 0
  set TotalLength 0
  catch {unset Stations}
  catch {unset DuplicateTrackMap}
  catch {unset Trains}
  catch {unset StorageTrackMap}
  catch {destroy .wholeChart.chartCanvas.chartFrame}
  set HasChartP 0  
  GetTimeInfo
  AcquireCabInfo
  MakeCabs
  AcquireStations
  MakeChart
  AcquireTracks
  MakeTracks
  global HasChartFileP ChartFile
  set HasChartFileP 0
  catch {unset ChartFile}  
  global IsSlave
  if {!$IsSlave} {wm deiconify .}
}

proc OpenChart {} {
# Procedure to open a chart.  Bound to the Open... menu item.
# [index] OpenChart!procedure

  set ans [tk_messageBox -icon question -default cancel -type okcancel \
		-message {Really clear off your chart and load another?}]
  if {[string compare "$ans" {cancel}] == 0} {return}
  global HasChartFileP ChartFile ChartFileTypes

  if {$HasChartFileP} {
    set initFile "$ChartFile"
  } else {
    set initFile "Chart.chart"
  }

  set filename "[tk_getOpenFile -defaultextension .chart \
				-filetypes $ChartFileTypes \
				-initialfile "$initFile" \
				-title {Chart File to load chart from} \
				-parent .]"
  if {[string length "$filename"] == 0} {return}
  set ChartFile "$filename"
  set HasChartFileP 1
  if {[LoadCompleteChart "$ChartFile"] == 0} {NewChart 0}
}

proc AddNewTrain {} {
# Procedure to add a new train to the chart.  Bound to the New Train button.
# [index] AddNewTrain!procedure

# .newTrain
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .newTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .newTrain"
  } {
    catch "destroy .newTrain"
  }
  toplevel .newTrain 

  # Window manager configurations
  wm positionfrom .newTrain ""
  wm sizefrom .newTrain ""
  wm maxsize .newTrain 1009 738
  wm minsize .newTrain 1 1
  wm protocol .newTrain WM_DELETE_WINDOW {.newTrain.buttons.button41 invoke}
  wm title .newTrain {Create New Train}
  wm transient .newTrain .


  # build widget .newTrain.banner
  frame .newTrain.banner \
    -borderwidth {2}

  # build widget .newTrain.banner.label27
  label .newTrain.banner.label27 \
    -image {banner}

  # build widget .newTrain.banner.label28
  label .newTrain.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Create New Train}

  # build widget .newTrain.info
  frame .newTrain.info \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .newTrain.info.nameNumber
  frame .newTrain.info.nameNumber \
    -borderwidth {2}

  # build widget .newTrain.info.nameNumber.label33
  label .newTrain.info.nameNumber.label33 \
    -text {Number:}

  # build widget .newTrain.info.nameNumber.number
  entry .newTrain.info.nameNumber.number \
    -width {4}

  # build widget .newTrain.info.nameNumber.label34
  label .newTrain.info.nameNumber.label34 -text {Section:}

  # build widget .newTrain.info.nameNumber.section
  entry .newTrain.info.nameNumber.section \
    -width {4}

  # build widget .newTrain.info.nameNumber.label35
  label .newTrain.info.nameNumber.label35 \
    -text {, Name:}

  # build widget .newTrain.info.nameNumber.name
  entry .newTrain.info.nameNumber.name

  # build widget .newTrain.info.nameNumber.label36
  label .newTrain.info.nameNumber.label36 \
    -text {, Class:}

  global NewTrainStatus

  # build widget .newTrain.info.nameNumber.class
  tk_optionMenu .newTrain.info.nameNumber.class NewTrainStatus(class) 1 2 3 4 5 6 7 8 9 10

  # build widget .newTrain.info.nameNumber.label37
  label .newTrain.info.nameNumber.label37 \
    -text {. Speed:}

  # build widget .newTrain.info.nameNumber.speed
  entry .newTrain.info.nameNumber.speed \
    -width {3}

  # build widget .newTrain.info.route
  frame .newTrain.info.route \
    -borderwidth {2}

  # build widget .newTrain.info.route.from
  StationOptionMenu .newTrain.info.route.from NewTrainStatus(from)

  # build widget .newTrain.info.route.l1
  label .newTrain.info.route.l1 -font {Helvetica -20 bold} -text {=>}

  # build widget .newTrain.info.route.to
  StationOptionMenu .newTrain.info.route.to NewTrainStatus(to)

  # build widget .newTrain.buttons
  frame .newTrain.buttons \
    -borderwidth {2}

  # build widget .newTrain.buttons.button41
  button .newTrain.buttons.button41 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global NewTrainStatus;set NewTrainStatus(button) 0}

  # build widget .newTrain.buttons.button42
  button .newTrain.buttons.button42 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {CreateNewTrain}

  # pack master .newTrain.banner
  pack configure .newTrain.banner.label27 \
    -side left
  pack configure .newTrain.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .newTrain.info
  pack configure .newTrain.info.nameNumber
  pack configure .newTrain.info.route \
    -fill x

  # pack master .newTrain.info.nameNumber
  pack configure .newTrain.info.nameNumber.label33 \
    -side left
  pack configure .newTrain.info.nameNumber.number \
    -side left
  pack configure .newTrain.info.nameNumber.label34 \
    -side left
  pack configure .newTrain.info.nameNumber.section \
    -side left
  pack configure .newTrain.info.nameNumber.label35 \
    -side left
  pack configure .newTrain.info.nameNumber.name \
    -expand 1 \
    -fill x \
    -side left
  pack configure .newTrain.info.nameNumber.label36 \
    -side left
  pack configure .newTrain.info.nameNumber.class \
    -side left
  pack configure .newTrain.info.nameNumber.label37 \
    -side left
  pack configure .newTrain.info.nameNumber.speed \
    -side right

  # pack master .newTrain.info.route
  pack configure .newTrain.info.route.from \
    -expand 1 \
    -fill x \
    -side left
  pack configure .newTrain.info.route.l1 \
    -side left
  pack configure .newTrain.info.route.to \
    -expand 1 \
    -fill x \
    -side right

  # pack master .newTrain.buttons
  pack configure .newTrain.buttons.button41 \
    -side left
  pack configure .newTrain.buttons.button42 \
    -side right

  # pack master .newTrain
  pack configure .newTrain.banner \
    -fill x
  pack configure .newTrain.info \
    -expand 1 \
    -fill both
  pack configure .newTrain.buttons \
    -fill x

  .newTrain.info.nameNumber.number insert end {}
  .newTrain.info.nameNumber.name insert end {}
  .newTrain.info.nameNumber.speed insert end {}


# end of widget tree

  set w .newTrain
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  focus $w.info.nameNumber.number

  global NewTrainStatus
  set NewTrainStatus(button) -1
  tkwait variable NewTrainStatus(button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .newTrain}

  if {$NewTrainStatus(button) == 0} {
    catch {unset NewTrainStatus}
    return
  }

  global Trains Stations
  if {$Stations($NewTrainStatus(from)) < $Stations($NewTrainStatus(to))} {
    set SList [lsort -increasing -command StationDistanceComp [array names Stations]]
  } else {
    set SList [lsort -decreasing -command StationDistanceComp [array names Stations]]
  }
  while {[string compare "[lindex $SList 0]" "$NewTrainStatus(from)"] != 0} {
    set SList [lrange $SList 1 end]
  }
  while {[string compare "[lindex $SList end]" "$NewTrainStatus(to)"] != 0} {
    set butend [expr [llength $SList] - 2]
    set SList [lrange $SList 0 $butend]
  }


# .getTrainSchedule
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getTrainSchedule
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getTrainSchedule"
  } {
    catch "destroy .getTrainSchedule"
  }
  toplevel .getTrainSchedule 

  # Window manager configurations
  wm positionfrom .getTrainSchedule ""
  wm sizefrom .getTrainSchedule ""
  wm maxsize .getTrainSchedule 1009 738
  wm minsize .getTrainSchedule 1 1
  wm protocol .getTrainSchedule WM_DELETE_WINDOW {.getTrainSchedule.buttons.button50 invoke}
  wm title .getTrainSchedule {Get Train Schedule}
  wm transient .getTrainSchedule .

  # build widget .getTrainSchedule.banner
  frame .getTrainSchedule.banner \
    -borderwidth {2}

  # build widget .getTrainSchedule.banner.label27
  label .getTrainSchedule.banner.label27 \
    -image {banner}

  # build widget .getTrainSchedule.banner.label28
  label .getTrainSchedule.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Get Train Schedule}

  # build widget .getTrainSchedule.schedFrame
  frame .getTrainSchedule.schedFrame \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .getTrainSchedule.schedFrame.sched
  canvas .getTrainSchedule.schedFrame.sched \
    -height {300} \
    -width {400} \
    -yscrollcommand {.getTrainSchedule.schedFrame.schedVScroll set}

  # build widget .getTrainSchedule.schedFrame.schedVScroll
  scrollbar .getTrainSchedule.schedFrame.schedVScroll \
    -command {.getTrainSchedule.schedFrame.sched yview}

  # build widget .getTrainSchedule.buttons
  frame .getTrainSchedule.buttons \
    -borderwidth {2}

  # build widget .getTrainSchedule.buttons.button50
  button .getTrainSchedule.buttons.button50 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global NewTrainStatus;set NewTrainStatus(button) 0}

  # build widget .getTrainSchedule.buttons.button51
  button .getTrainSchedule.buttons.button51 \
    -padx {9} \
    -pady {3} \
    -text {Finish} \
    -command {FinishTrain}

  # pack master .getTrainSchedule.banner
  pack configure .getTrainSchedule.banner.label27 \
    -side left
  pack configure .getTrainSchedule.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrainSchedule.schedFrame
  pack configure .getTrainSchedule.schedFrame.sched \
    -expand 1 \
    -fill both \
    -side left
  pack configure .getTrainSchedule.schedFrame.schedVScroll \
    -fill y \
    -side right

  # pack master .getTrainSchedule.buttons
  pack configure .getTrainSchedule.buttons.button50 \
    -side left
  pack configure .getTrainSchedule.buttons.button51 \
    -side right

  # pack master .getTrainSchedule
  pack configure .getTrainSchedule.banner \
    -fill x
  pack configure .getTrainSchedule.schedFrame \
    -expand 1 \
    -fill both
  pack configure .getTrainSchedule.buttons \
    -fill x

  # build canvas items .getTrainSchedule.schedFrame.sched

  global HasCabP

  frame .getTrainSchedule.schedFrame.sched.sframe -borderwidth 0

  label .getTrainSchedule.schedFrame.sched.sframe.arrival0 -text {Arival} -anchor e
  label .getTrainSchedule.schedFrame.sched.sframe.station0 -text {Station} -anchor w
  label .getTrainSchedule.schedFrame.sched.sframe.depart0  -text {Depart} -anchor e
  if {$HasCabP} {
    set lcab {Cab Name}
  } else {
    set lcab {Color}
  }
  label .getTrainSchedule.schedFrame.sched.sframe.color0 -text "$lcab" -anchor w
  label .getTrainSchedule.schedFrame.sched.sframe.update0 -text {}

  grid configure .getTrainSchedule.schedFrame.sched.sframe.arrival0 \
	-column 0 -row 0 -sticky e
  grid configure .getTrainSchedule.schedFrame.sched.sframe.station0 \
	-column 1 -row 0 -sticky w
  grid configure .getTrainSchedule.schedFrame.sched.sframe.depart0 \
	-column 2 -row 0 -sticky e -columnspan 3
  grid configure .getTrainSchedule.schedFrame.sched.sframe.color0 \
	-column 5 -row 0 -sticky w
  grid configure .getTrainSchedule.schedFrame.sched.sframe.update0 \
  	-column 6 -row 0 -sticky w


  set NewTrainStatus(row,1) [lindex $SList 0]
  label .getTrainSchedule.schedFrame.sched.sframe.arrival1 -text {Origin} -anchor e
  set NewTrainStatus([lindex $SList 0],arrival) -1
  label .getTrainSchedule.schedFrame.sched.sframe.station1 -text "[lindex $SList 0]" -anchor w
  entry .getTrainSchedule.schedFrame.sched.sframe.departh1 -width 2
  .getTrainSchedule.schedFrame.sched.sframe.departh1 insert end { 0}
  label .getTrainSchedule.schedFrame.sched.sframe.departC1 -text {:}
  entry .getTrainSchedule.schedFrame.sched.sframe.departm1 -width 2
  .getTrainSchedule.schedFrame.sched.sframe.departm1 insert end {00}
  set NewTrainStatus([lindex $SList 0],depart) 0
  if {$HasCabP} {
    CabOptionMenu .getTrainSchedule.schedFrame.sched.sframe.color1 NewTrainStatus([lindex $SList 0],cab)
  } else {
    entry .getTrainSchedule.schedFrame.sched.sframe.color1 -textvariable NewTrainStatus([lindex $SList 0],color)
    set NewTrainStatus([lindex $SList 0],color) black
  }
  button .getTrainSchedule.schedFrame.sched.sframe.update1 -text {Update} \
	-command {UpdateTrainSchedule 1}


  foreach w {arrival station departh departC departm color update} \
	  c {0 1 2 3 4 5 6} \
	  sk {e w e e e e e} {	  
    grid configure .getTrainSchedule.schedFrame.sched.sframe.${w}1 \
	-column $c -row 1 -sticky $sk
  }


  set indx 2
  set location $Stations([lindex $SList 0])
  set orgTime 0
  set daymins [expr 24 * 60]
  set speed double($NewTrainStatus(speed))
  foreach s [lrange $SList 1 end] {
    set NewTrainStatus(row,$indx) $s
    set dist [expr abs($Stations($s) - $location)]
    set location $Stations($s)
    set arrival [expr $orgTime + (($dist * 60) / $speed)]
    while {$arrival > $daymins} {set arrival [expr $arrival - $daymins]}
    set NewTrainStatus($s,arrival) $arrival
    set orgTime $arrival
    set orgText "[format {%2d:%02d} [expr int($orgTime) / 60] [expr int($orgTime) % 60]]"
    label .getTrainSchedule.schedFrame.sched.sframe.arrival$indx -text "$orgText" -anchor e
    label .getTrainSchedule.schedFrame.sched.sframe.station$indx -text "$s" -anchor w
    if {[string compare "$s" "[lindex $SList end]"] == 0} {
      label .getTrainSchedule.schedFrame.sched.sframe.term$indx -text {Terminate}
      grid configure .getTrainSchedule.schedFrame.sched.sframe.arrival$indx \
      		-column 0 -row $indx -sticky e
      grid configure .getTrainSchedule.schedFrame.sched.sframe.station$indx \
		-column 1 -row $indx -sticky w
      grid configure .getTrainSchedule.schedFrame.sched.sframe.term$indx \
      		-column 2 -columnspan 4 -row $indx -sticky w
      set NewTrainStatus($s,depart) -1
      if {$HasCabP} {
        set NewTrainStatus($s,cab) {}
      } else {
	set NewTrainStatus($s,color) {}
      }      
    } else {
      entry .getTrainSchedule.schedFrame.sched.sframe.departh$indx -width 2
      label .getTrainSchedule.schedFrame.sched.sframe.departC$indx -text {:}
      entry .getTrainSchedule.schedFrame.sched.sframe.departm$indx -width 2
      .getTrainSchedule.schedFrame.sched.sframe.departh$indx insert end "[format {%2d} [expr int($orgTime) / 60]]"
      .getTrainSchedule.schedFrame.sched.sframe.departm$indx insert end "[format {%02d} [expr int($orgTime) % 60]]"
      set NewTrainStatus($s,depart) $arrival
      if {$HasCabP} {
        CabOptionMenu .getTrainSchedule.schedFrame.sched.sframe.color$indx NewTrainStatus($s,cab)
      } else {
        entry .getTrainSchedule.schedFrame.sched.sframe.color$indx -textvariable NewTrainStatus($s,color)
        set NewTrainStatus($s,color) black
      }
      button .getTrainSchedule.schedFrame.sched.sframe.update$indx -text {Update} \
		-command "UpdateTrainSchedule $indx"
      foreach w {arrival station departh departC departm color update} \
	      c {0 1 2 3 4 5 6}  \
	      sk {e w e e e e e} {
        grid configure .getTrainSchedule.schedFrame.sched.sframe.${w}$indx \
		-column $c -row $indx -sticky $sk
      }
    }
    incr indx
  }
  label .getTrainSchedule.schedFrame.sched.sframe.arrival$indx -text {Arival} -anchor e
  label .getTrainSchedule.schedFrame.sched.sframe.station$indx -text {Station} -anchor w
  label .getTrainSchedule.schedFrame.sched.sframe.depart$indx  -text {Depart} -anchor e
  label .getTrainSchedule.schedFrame.sched.sframe.color$indx -text "$lcab" -anchor w
  label .getTrainSchedule.schedFrame.sched.sframe.update$indx -text {}

  grid configure .getTrainSchedule.schedFrame.sched.sframe.arrival$indx \
	-column 0 -row $indx -sticky e
  grid configure .getTrainSchedule.schedFrame.sched.sframe.station$indx \
	-column 1 -row $indx -sticky w
  grid configure .getTrainSchedule.schedFrame.sched.sframe.depart$indx \
	-column 2 -row $indx -sticky e -columnspan 3
  grid configure .getTrainSchedule.schedFrame.sched.sframe.color$indx \
	-column 5 -row $indx -sticky w
  grid configure .getTrainSchedule.schedFrame.sched.sframe.update$indx \
  	-column 6 -row $indx -sticky w

  update idletasks
  .getTrainSchedule.schedFrame.sched create window 0 0 -anchor nw \
	-window .getTrainSchedule.schedFrame.sched.sframe
  set sr [grid bbox .getTrainSchedule.schedFrame.sched.sframe]
  .getTrainSchedule.schedFrame.sched configure -scrollregion $sr -width [lindex $sr 2]

# end of widget tree

  set w .getTrainSchedule
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

    set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  focus $w.schedFrame.sched.sframe.departh1

  global NewTrainStatus
  set NewTrainStatus(button) -1
  tkwait variable NewTrainStatus(button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .getTrainSchedule}

  if {$NewTrainStatus(button) == 0} {
    catch {unset NewTrainStatus}
    return
  }
#  parray NewTrainStatus

  global TrackList StorageTrackMap
  set TrainStruct [list [list "$NewTrainStatus(name)" "$NewTrainStatus(speed)" $NewTrainStatus(class) {}]]
  if {[string length "$NewTrainStatus(name)"] > 0} {
    set trainId "$NewTrainStatus(number) ($NewTrainStatus(name))"
  } else {
    set trainId "$NewTrainStatus(number)"
  }
  set DPattern {}
  set APattern {}
  foreach st $SList {
    if {$HasCabP} {
      set cc $NewTrainStatus($st,cab)
    } else {
      set cc $NewTrainStatus($st,color)
    }
    if {$NewTrainStatus($st,arrival) < 0} {
      if {[llength [array names TrackList $st]] > 0} {
	set OrgTrack [list Origin [GetTrack "Departure track at $st for $trainId" $st 0 $NewTrainStatus($st,depart) $trainId]]
      } else {
	set OrgTrack [list Origin N/A]
      }
      set dTrack "[lindex $OrgTrack 1]"
      if {[string compare "$dTrack" {N/A}] != 0} {
	set DPattern ${st}+${dTrack}*-$NewTrainStatus($st,depart)
      }
      lappend TrainStruct [list $OrgTrack $st $NewTrainStatus($st,depart) $cc {}]
    } elseif {$NewTrainStatus($st,depart) < 0} {
      if {[llength [array names TrackList $st]] > 0} {
	set StorTrack [list Storage [GetTrack "Storage track at $st for $trainId" $st 1 $NewTrainStatus($st,arrival) $trainId]]
      } else {
	set StorTrack [list Storage N/A] 
      }
      set aTrack "[lindex $StorTrack 1]"
      if {[string compare "$aTrack" {N/A}] != 0} {
	set APattern ${st}+${aTrack}$NewTrainStatus($st,arrival)-*
      }
      lappend TrainStruct [list $NewTrainStatus($st,arrival) $st $StorTrack $cc {}]
    } else {
      lappend TrainStruct [list $NewTrainStatus($st,arrival) $st $NewTrainStatus($st,depart) $cc {}]
    }
  }

  set Trains($NewTrainStatus(number)) "$TrainStruct"
  DrawTrain $NewTrainStatus(number)
  if {[string length "$DPattern"] > 0} {
    DrawStorageTrack [array names StorageTrackMap $DPattern]
  }
  if {[string length "$APattern"] > 0} {
    DrawStorageTrack [array names StorageTrackMap $APattern]
  }
#  catch {parray Trains}
  catch {unset NewTrainStatus}

}

proc CabOptionMenu {w var} {
# Procedure to create a cab option menu.
# <in> w -- widget path (menu button) to create.
# <in> var -- variable to bind the selection to.
# [index] CabOptionMenu!procedure

  global CabColors
  eval [concat tk_optionMenu $w $var [lsort -dictionary [array names CabColors]]]
}

proc CreateNewTrain {} {
# Procedure to create a new train.  Bound to the Next button.
# [index] CreateNewTrain!procedure

  global NewTrainStatus
  global Trains

  set num [string trim "[.newTrain.info.nameNumber.number get]"]
  if {[catch [list expr int($num)] number]} {
    tk_messageBox -icon error -message "Not a number (train number): $num!" -type ok
    return
  }
  if {$num != $number} {
    tk_messageBox -icon error -message "Not a whole number (train number): $num!" -type ok
    return
  }
  set sec [string trim "[.newTrain.info.nameNumber.section get]"]
  if {[string length "$sec"] > 0} {
    if {[catch [list expr int($sec)] section]} {
      tk_messageBox -icon error -message "Not a number (train section): $sec!" -type ok
      return
    }
    if {$sec != $section} {
      tk_messageBox -icon error -message "Not a whole number (train section): $sec!" -type ok
      return
    }
    set number "$number-$section"
  }
  if {[catch [list array names Trains $number] match]} {
    set match {}
  }
  if {[llength $match] > 0} {
    tk_messageBox -icon error -message "Duplicate train number: $number!" -type ok
    return
  }
  set NewTrainStatus(number) $number
  set NewTrainStatus(name) [string trim "[.newTrain.info.nameNumber.name get]"]
  if {[HasForbiddenCharsP "$NewTrainStatus(name)" {%|}]} {
    tk_messageBox -icon error -message "Train name contains forbidden charactors (%|): $NewTrainStatus(name)!" -type ok
    return
  }
  set sp [string trim "[.newTrain.info.nameNumber.speed get]"]
  if {[catch [list expr int($sp)] speed]} {
    tk_messageBox -icon error -message "Not a number (speed): $sp!" -type ok
    return
  }
  if {$sp != $speed} {
    tk_messageBox -icon error -message "Not a whole number (speed): $sp!" -type ok
    return
  }
  set NewTrainStatus(speed) $speed
  if {[string compare "$NewTrainStatus(from)" "$NewTrainStatus(to)"] == 0} {
    tk_messageBox -icon error -message "Train endpoints are the same!"
    return
  }
  set NewTrainStatus(button) 1
}

proc FinishTrain {} {
# Procedure to finish creating a new train.  Bound to the Finish button.
# [index] FinishTrain!procedure

  global NewTrainStatus
  set NewTrainStatus(button) 1
}

proc UpdateTrainSchedule {rowIndx} {
# Procedure to update a train's schedule.  Bound to the Update buttons.
# <in> rowIndx -- the button's row index.
# [index] UpdateTrainSchedule!procedure

  global NewTrainStatus HasCabP

  set s $NewTrainStatus(row,$rowIndx)
  set deph "[.getTrainSchedule.schedFrame.sched.sframe.departh$rowIndx get]"
  set depm "[.getTrainSchedule.schedFrame.sched.sframe.departm$rowIndx get]"
  if {[regexp {^[0 ]*([0-9]+)$} "$deph" whole h] <= 0} {
    tk_messageBox -icon error -type ok -message "Not a proper hour (syntax): $deph"
    return
  }
  if {[regexp {^[0 ]*([0-9]+)$} "$depm" whole m] <= 0} {
    tk_messageBox -icon error -type ok -message "Not a proper minute (syntax): $depm"
    return
  }
  if {$h > 23} {
    tk_messageBox -icon error -type ok -message "Not a proper hour (range): $deph"
    return
  }
  if {$m > 59} {
    tk_messageBox -icon error -type ok -message "Not a proper minute (range): $depm"
    return
  }
  if {!$HasCabP} {
    if {[NotLegalColor $NewTrainStatus($s,color)]} {
      tk_messageBox -icon error -type ok -message "Not a legal color: $NewTrainStatus($s,color)!"
      return
    }
  }
  set newdepart [expr ($h * 60) + $m]
  set NewTrainStatus($s,depart) $newdepart
  PropagateTrainSchedule $rowIndx
}

proc PropagateTrainSchedule {startIndex} {
# Procedure to propagate a train's schedule.
# <in> startIndex -- row index to begin propagation from.
# [index] PropagateTrainSchedule!procedure

  global NewTrainStatus HasCabP Stations

  set startStation $NewTrainStatus(row,$startIndex)
  set location $Stations($startStation)
  set currentTime  $NewTrainStatus($startStation,depart)
  set index [expr $startIndex + 1]
  set speed double($NewTrainStatus(speed))
  set daymins [expr 24 * 60]
  while {1} {
    if {[catch [list set NewTrainStatus(row,$index)] nextStation]} {break}
    flush stdout
    set dist [expr abs($Stations($nextStation) - $location)]
    set arrival [expr $currentTime + (($dist * 60) / $speed)]
    set location $Stations($nextStation)
    while {$arrival > $daymins} {set arrival [expr $arrival - $daymins]}
    set currentTime $arrival
    set orgText "[format {%2d:%02d} [expr int($currentTime) / 60] [expr int($currentTime) % 60]]"
    .getTrainSchedule.schedFrame.sched.sframe.arrival$index configure -text "$orgText" -anchor e
    if {[string compare "$nextStation" "$NewTrainStatus(to)"] != 0} {
      set layover [expr $NewTrainStatus($nextStation,depart) - $NewTrainStatus($nextStation,arrival)]
      set currentTime [expr $currentTime + $layover]
      set NewTrainStatus($nextStation,depart) $currentTime    
      .getTrainSchedule.schedFrame.sched.sframe.departh$index delete 0 end
      .getTrainSchedule.schedFrame.sched.sframe.departh$index insert end "[format {%2d} [expr int($currentTime) / 60]]"
      .getTrainSchedule.schedFrame.sched.sframe.departm$index delete 0 end
      .getTrainSchedule.schedFrame.sched.sframe.departm$index insert end "[format {%02d} [expr int($currentTime) % 60]]"
      if {$HasCabP} {
        set NewTrainStatus($nextStation,cab)  $NewTrainStatus($startStation,cab)
      } else {
        set NewTrainStatus($nextStation,color)  $NewTrainStatus($startStation,color)
      }
    }
    set NewTrainStatus($nextStation,arrival) $arrival
    incr index
  }
}

proc DrawStorageTrack {element} {
# Procedure to draw a storage track.
# <in> element -- array element key.
# [index] DrawStorageTrack!procedure

  global StorageTrackMap TrackYMap HasTrackP HasCabP CabColors Trains TimeIncrement

  if {!$HasTrackP} {return}
  if {[llength $element] != 1} {return}

  if {[regexp {^([^+]+)\+([0-9]+),([0-9.]*)-([0-9.]*)$} "$element" whole station track Arrive Depart] < 1} {
    error "Internal error in DrawStorageTrack: time key malformed: $element"
  }
  if {[regexp {^([0-9-]*)>([0-9-]*)$} "$StorageTrackMap($element)" whole train1 train2] < 1} {
    error "Internal error in DrawStorageTrack: malformed data at $element: $StorageTrackMap($element)"
  }
  if {[string length "$Arrive"] == 0} {
    set Arrive [expr $Depart - 15]
  }    
  if {[string length "$Depart"] == 0} {
    set Depart [expr $Arrive + 15]
  }
  set color white
  set outline black
  if {[string length "$train1"] > 0} {
    set ts $Trains($train1)
    if {$HasCabP} {
      set cab [lindex [lindex $ts end] 3]
      set color $CabColors($cab)
    } else {
      set color [lindex [lindex $ts end] 3]
    }
    set outline {}
  } elseif {[string length "$train2"] > 0} {
    set ts $Trains($train2)
    if {$HasCabP} {
      set cab [lindex [lindex $ts 1] 3]
      set color $CabColors($cab)
    } else {
      set color [lindex [lindex $ts 1] 3]
    }
    set outline {}
  }
  set Y $TrackYMap($station,$track)
  set mA $Arrive
  set mD $Depart
  .wholeChart.chartCanvas.trackFrame.theTracks create rectangle \
      [expr 100 + (((double($mA) / double($TimeIncrement)) * 20.0)) + 4] \
      $Y \
      [expr 100 + (((double($mD) / double($TimeIncrement)) * 20.0)) + 4] \
      [expr $Y + 20] \
      -fill $color -outline $outline -tag $element
  set center [expr 100 + ((((double($mA+$mD)/2.0) / double($TimeIncrement)) * 20.0)) + 4]
  .wholeChart.chartCanvas.trackFrame.theTracks create text \
	$center $Y -anchor n -text "$StorageTrackMap($element)" -tag $element
}

proc DrawTrain {trainNumber} {
# Procedure to draw a train.
# <in> trainNumber -- train number to draw.
# [index] DrawTrain!procedure

  global Trains TrackYMap CabYMap TrackList CabColors HasCabP HasTrackP 
  global StationYMap TimeIncrement

  set chartCanvas .wholeChart.chartCanvas.chartFrame.theChart
  set tag Train$trainNumber

  set TrainStruct $Trains($trainNumber)

  set stationList [lrange $TrainStruct 1 end]
  set timeX -1
  set stationY -1
  set rStationY -1
  set color {}
  foreach stInfo $stationList {
    set arrival [lindex $stInfo 0]
    set station [lindex $stInfo 1]
    set depart  [lindex $stInfo 2]
    if {$HasCabP} {
      set cab [lindex $stInfo 3]
      set newColor $CabColors($cab)
    } else {
      set newColor [lindex $stInfo 3]
    }
    set newStationY $StationYMap($station)
    set dupStation "[FindDuplicateStation $station]"
    if {[string length "$dupStation"] > 0} {
      set newRStationY $StationYMap($dupStation)
    } else {
      set newRStationY -1
    }
    if {[llength $arrival] < 2} {
      set mA $arrival
      set newTimeX [expr 100 + (((double($mA) / double($TimeIncrement)) * 20.0)) + 4]
      $chartCanvas create line $timeX $stationY $newTimeX $newStationY \
	-fill $color -width 4 -tags $tag
      if {$rStationY >= 0 && $newRStationY >= 0} {
	$chartCanvas create line $timeX $rStationY $newTimeX $newRStationY \
		-fill $color -width 4 -tags $tag
      }
      if {$HasCabP} {
	set cy1 [expr $CabYMap($cab) + 2]
	set cy2 [expr $cy1 + 16]
	$chartCanvas create rectangle $timeX $cy1 $newTimeX $cy2 \
		-fill $color -outline {} -tags $tag
      }
      set timeX $newTimeX
    }
    if {[llength $depart] < 2} {
      set mD $depart
      set newTimeX [expr 100 + (((double($mD) / double($TimeIncrement)) * 20.0)) + 4]
    }
    set color $newColor
    set stationY $newStationY
    set rStationY $newRStationY
    if {[llength $arrival] < 2 && [llength $depart] < 2 && $arrival != $depart} {
      $chartCanvas create line $timeX $stationY $newTimeX $stationY \
	-fill $color -width 4 -tags $tag
      if {$rStationY >= 0} {
	$chartCanvas create line $timeX $rStationY $newTimeX $rStationY \
		-fill $color -width 4 -tags $tag
      }
    }
    if {$HasCabP} {
      set cy1 [expr $CabYMap($cab) + 2]
      set cy2 [expr $cy1 + 16]
      $chartCanvas create rectangle $timeX $cy1 $newTimeX $cy2 \
		-fill $color -outline {} -tags $tag
    }
    set timeX $newTimeX
  }
}  

proc FindDuplicateStation {station} {
# Procedure to find a duplicated station (due to duplicated trackage).
# <in> station -- station to find mirror of.
# [index] FindDuplicateStation!procedure

  global Stations DuplicateTrackMap

  set stVect [lsort -command StationDistanceComp -increasing [array names Stations]]
  set stRVect [lsort -command StationDistanceComp -decreasing [array names Stations]]
  foreach dt [array names DuplicateTrackMap] {
    set this [split $dt {=}]
    set that [split $DuplicateTrackMap($dt) {=}]
    set thisS [lsearch -exact $stVect [lindex $this 0]]
    set thisE [lsearch -exact $stVect [lindex $this 1]]
    set thatS [lsearch -exact $stRVect [lindex $that 0]]
    set thatE [lsearch -exact $stRVect [lindex $that 1]]
    set theseStaions [lrange $stVect $thisS $thisE]
    set thoseStaions [lrange $stRVect $thatS $thatE]
    set theStation [lsearch -exact $theseStaions $station]
    if {$theStation >= 0} {return "[lindex $thoseStaions $theStation]"}
    set theStation [lsearch -exact $thoseStaions $station]
    if {$theStation >= 0} {return "[lindex $theseStaions $theStation]"}
  }
  return {}
}

proc HasForbiddenCharsP {string forbchars} {
# Procedure to check for illegal characters in a string.
# <in> string -- string to check.
# <in> forbchars -- string a disallowed characters.
# [index] HasForbiddenCharsP!oricedure

  foreach c [split $forbchars {}] {
    if {[string first "$c" "$string"] >= 0} {return 1}
  }
  return 0
}

proc NotLegalColor {color} {
# Procedure to check for illegal colors.
# <in> color -- color to check.
# [index] NotLegalColor!procedure

  return [catch [list winfo rgb . $color]]
}

proc TimeSort {aKey bKey} {
# Procedure to sort storage track map elements by time.
# <in> aKey -- a storage track map key.
# <in> bKey -- another storage track map key.
# [index] TimeSort!procedure

  if {[regexp {\+[0-9]+,([0-9.]*)-([0-9.]*)$} "$aKey" whole aArrive aDepart] < 1} {
    error "Internal error in TimeSort: aKey malformed: $aKey"
  }
  if {[regexp {\+[0-9]+,([0-9.]*)-([0-9.]*)$} "$bKey" whole bArrive bDepart] < 1} {
    error "Internal error in TimeSort: bKey malformed: $bKey"
  }
  if {[string length "$aArrive"] == 0 && [string length "$bArrive"] == 0} {
    if {$aDepart < $bDepart} {
      return -1
    } elseif {$aDepart > $bDepart} {
      return 1
    } else {
      return 0
    }
  }
  if {[string length "$aDepart"] == 0 && [string length "$bDepart"] == 0} {
    if {$aArrive < $bArrive} {
      return -1
    } elseif {$aArrive > $bArrive} {
      return 1
    } else {
      return 0
    }
  }
  if {[string length "$aArrive"] == 0} {return -1}
  if {[string length "$bArrive"] == 0} {return 1}
  if {[string length "$aDepart"] == 0} {return 1}
  if {[string length "$bDepart"] == 0} {return -1}
  if {$aDepart <= $bArrive} {return -1}
  if {$aArrive >= $bDepart} {return 1}
  return 0
}

proc AllocateStorageTrack {station track arrivetime train} {
# Procedure to allocate a storage track for an arriving train.
# <in> station -- arrival station.
# <in> track -- desired track.
# <in> arrivetime -- time of arrival
# <in> train -- arriving train.
# [index] AllocateStorageTrack!procedure

  global StorageTrackMap

  set baseKey "${station}+${track},"
  set timeKeys [lsort -command TimeSort [array names StorageTrackMap "${baseKey}*-*"]]

  foreach tk $timeKeys {
    if {[regexp {\+[0-9]+,([0-9.]*)-([0-9.]*)$} "$tk" whole Arrive Depart] < 1} {
      error "Internal error in AllocateStorageTrack: time key malformed: $tk"
    }
    if {[string length "$Arrive"] == 0 && $arrivetime < $Depart} {
      if {[regexp {^>([0-9-]*)$} "$StorageTrackMap($tk)" whole departingTrain] < 1} {
	error "Internal error in AllocateStorageTrack: malformed data at $tk: $StorageTrackMap($tk)"
      }
      catch ".wholeChart.chartCanvas.trackFrame.theTracks delete $tk"
      catch "unset StorageTrackMap($tk)"
      set newKey "${station}+${track},${arrivetime}-${Depart}"
      set StorageTrackMap($newKey) "${train}>${departingTrain}"
      return 1
    } elseif {[string length "$Depart"] == 0} {
      if {$arrivetime < $Arrive} {
        continue
      } else {
        return 0
      }
    } elseif {$Arrive <= $arrivetime && $arrivetime <= $Depart} {
      return 0
    }
  }
  set newKey "${station}+${track},${arrivetime}-"
  set StorageTrackMap($newKey) "${train}>"
  return 1
}

proc CanAllocateStorageTrackP {station track arrivetime} {
# Procedure to check if a storage track is available for an arriving train.
# <in> station -- arrival station.
# <in> track -- desired track.
# <in> arrivetime -- time of arrival
# [index] CanAllocateStorageTrackP!procedure

  global StorageTrackMap

  set baseKey "${station}+${track},"
  set timeKeys [lsort -command TimeSort [array names StorageTrackMap "${baseKey}*-*"]]

  foreach tk $timeKeys {
    if {[regexp {\+[0-9]+,([0-9.]*)-([0-9.]*)$} "$tk" whole Arrive Depart] < 1} {
      error "Internal error in CanAllocateStorageTrackP: time key malformed: $tk"
    }
    if {[string length "$Arrive"] == 0 && $arrivetime < $Depart} {
      if {[regexp {^>([0-9-]*)$} "$StorageTrackMap($tk)" whole departingTrain] < 1} {
	error "Internal error in CanAllocateStorageTrackP: malformed data at $tk: $StorageTrackMap($tk)"
      }
      return 1
    } elseif {[string length "$Depart"] == 0} {
      if {$arrivetime < $Arrive} {
        continue
      } else {
        return 0
      }
    } elseif {$Arrive <= $arrivetime && $arrivetime <= $Depart} {
      return 0
    }
  }
  return 0
}

proc DeallocateStorageTrack {station track departtime train} {
# Procedure to deallocate a storage track for a departing train.
# <in> station -- departure station.
# <in> track -- desired track.
# <in> arrivetime -- time of departure
# <in> train -- departing train.
# [index] DeallocateStorageTrack!procedure

  global StorageTrackMap

  set baseKey "${station}+${track},"
  set timeKeys [lsort -command TimeSort [array names StorageTrackMap "${baseKey}*-*"]]

  foreach tk $timeKeys {
    if {[regexp {\+[0-9]+,([0-9.]*)-([0-9.]*)$} "$tk" whole Arrive Depart] < 1} {
      error "Internal error in DeallocateStorageTrack: time key malformed: $tk"
    }
    if {[string length "$Depart"] == 0 && $departtime > $Arrive} {
      if {[regexp {^([0-9-]*)>$} "$StorageTrackMap($tk)" whole arrivingTrain] < 1} {
	error "Internal error in DeallocateStorageTrack: malformed data at $tk: $StorageTrackMap($tk)"
      }
      catch ".wholeChart.chartCanvas.trackFrame.theTracks delete $tk"
      catch "unset StorageTrackMap($tk)"
      set newKey "${station}+${track},${Arrive}-${departtime}"
      set StorageTrackMap($newKey) "${arrivingTrain}>${train}"
      return 1
    } elseif {[string length "$Arrive"] == 0} {
      continue
    } elseif {$Arrive <= $departtime && $departtime <= $Depart} {
      return 0
    }
  }
  set newKey "${station}+${track},-${departtime}"
  set StorageTrackMap($newKey) ">${train}"
  return 1
}  
  
proc CanDeallocateStorageTrackP {station track departtime} {
# Procedure to check to see if a storage track can hold a departing train.
# <in> station -- departure station.
# <in> track -- desired track.
# <in> arrivetime -- time of departure
# [index] CanDeallocateStorageTrackP!procedure

  global StorageTrackMap

  set baseKey "${station}+${track},"
  set timeKeys [lsort -command TimeSort [array names StorageTrackMap "${baseKey}*-*"]]

  foreach tk $timeKeys {
    if {[regexp {\+[0-9]+,([0-9.]*)-([0-9.]*)$} "$tk" whole Arrive Depart] < 1} {
      error "Internal error in CanDeallocateStorageTrackP: time key malformed: $tk"
    }
    if {[string length "$Depart"] == 0 && $departtime > $Arrive} {
      if {[regexp {^([0-9-]*)>$} "$StorageTrackMap($tk)" whole arrivingTrain] < 1} {
	error "Internal error in CanDeallocateStorageTrackP: malformed data at $tk: $StorageTrackMap($tk)"
      }
      return 1
    } elseif {[string length "$Arrive"] == 0} {
      continue
    } elseif {$Arrive <= $departtime && $departtime <= $Depart} {
      return 0
    }
  }
  return 1
}  
  
proc FindUsedStorage {station track time} {
# Procedure to find out if the specificed track is in use at the time specified.
# <in> station -- station where track is.
# <in> track -- track to check.
# <in> time -- time to check.
# [index] FindUsedStorage!procedure

  global StorageTrackMap

  set baseKey "${station}+${track},"
  set timeKeys [lsort -command TimeSort [array names StorageTrackMap "${baseKey}*-*"]]

  set lastFree {}
  foreach tk $timeKeys {
    if {[regexp {\+[0-9]+,([0-9.]*)-([0-9.]*)$} "$tk" whole Arrive Depart] < 1} {
      error "Internal error in FindUsedStorage: time key malformed: $tk"
    }
    if {[string length "$Depart"] == 0 && $time >= $Arrive} {
      return $tk
    } elseif {[string length "$Arrive"] == 0 && $time <= $Depart} {
      set lastFree $tk
    } elseif {$Arrive <= $time && $time <= $Depart} {
      return $tk
    }
  }
  return "$lastFree"
}

proc FindTrainInStorage {station track train} {
# Procedure to find when a train is in storage on a given track at a given station.
# <in> station -- station to check at.
# <in> track -- track to check on.
# <in> train -- train to check for.
# [index] FindTrainInStorage!procedure

  global StorageTrackMap

  set baseKey "${station}+${track},"
  set timeKeys [lsort -command TimeSort [array names StorageTrackMap "${baseKey}*-*"]]

  set keys {}
  foreach tk $timeKeys {
    if {[regexp {^([0-9-]*)>([0-9-]*)$} "$StorageTrackMap($tk)" whole train1 train2] < 1} {
      error "Internal error in FindTrainInStorage: malformed data at $tk: $StorageTrackMap($tk)"
    }
    if {[string compare "$train1" "$train"] == 0 ||
        [string compare "$train2" "$train"] == 0} {lappend keys "$tk"}
  }
  return $keys
}

proc GetTrack {message station arrivalP time train} {
# Procedure to get a storage track for an arriving or departing train.
# <in> message -- message to display.
# <in> station -- arrival or departure station.
# <in> arrivalP -- flag to indicate if arriving or departing.
# <in> time -- time of arrival or departure.
# <in> train -- train in question.
# [index] GetTrack!procedure

  global TrackList HasTrackP GetTrackStatus StorageTrackMap

  if {!$HasTrackP} {return {N/A}}
  if {[llength [array names TrackList $station]] == 0} {return {N/A}}
  set availableTracks {}
  if {$arrivalP} {
    foreach tr $TrackList($station) {
      if {[CanAllocateStorageTrackP "$station" $tr $time]} {lappend availableTracks $tr}
    }
  } else {
    foreach tr $TrackList($station) {
      if {[CanDeallocateStorageTrackP "$station" $tr $time]} {lappend availableTracks $tr}
    }
  }
  if {[llength $availableTracks] == 0} {return {N/A}}

# .getTrack
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getTrack
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getTrack"
  } {
    catch "destroy .getTrack"
  }
  toplevel .getTrack 

  # Window manager configurations
  wm positionfrom .getTrack ""
  wm sizefrom .getTrack ""
  wm maxsize .getTrack 1009 738
  wm minsize .getTrack 1 1
  wm protocol .getTrack WM_DELETE_WINDOW {.getTrack.buttons.button6 invoke}
  wm title .getTrack {Get Track}
  wm transient .getTrack .


  # build widget .getTrack.banner
  frame .getTrack.banner \
    -borderwidth {2}

  # build widget .getTrack.banner.label27
  label .getTrack.banner.label27 \
    -image {banner}

  # build widget .getTrack.banner.label28
  label .getTrack.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Get Track}

  # build widget .getTrack.info
  frame .getTrack.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .getTrack.info.theMessage
  message .getTrack.info.theMessage \
    -aspect {1500} \
    -padx {5} \
    -pady {2} \
    -text "$message"

  # build widget .getTrack.info.answer
  eval [concat tk_optionMenu .getTrack.info.answer GetTrackStatus(theTrack) {N/A} $availableTracks]

  # build widget .getTrack.buttons
  frame .getTrack.buttons \
    -borderwidth {2}

  # build widget .getTrack.buttons.button6
  button .getTrack.buttons.button6 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global GetTrackStatus;set GetTrackStatus(button) 0}

  # build widget .getTrack.buttons.button7
  button .getTrack.buttons.button7 \
    -padx {9} \
    -pady {3} \
    -text {OK} \
    -command {global GetTrackStatus;set GetTrackStatus(button) 1}

  # pack master .getTrack.banner
  pack configure .getTrack.banner.label27 \
    -side left
  pack configure .getTrack.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrack.info
  pack configure .getTrack.info.theMessage \
    -expand 1 \
    -fill x \
    -side left
  pack configure .getTrack.info.answer \
    -side right

  # pack master .getTrack.buttons
  pack configure .getTrack.buttons.button6 \
    -side left
  pack configure .getTrack.buttons.button7 \
    -side right

  # pack master .getTrack
  pack configure .getTrack.banner \
    -fill x
  pack configure .getTrack.info \
    -expand 1 \
    -fill both
  pack configure .getTrack.buttons \
    -fill x
# end of widget tree

  set w .getTrack
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set GetTrackStatus(button) -1
  tkwait variable GetTrackStatus(button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .getTrack}

  if {$GetTrackStatus(button) == 0} {
    return {N/A}
  } else {
    if {$arrivalP} {
      AllocateStorageTrack "$station" $GetTrackStatus(theTrack) $time $train
    } else {
      DeallocateStorageTrack "$station" $GetTrackStatus(theTrack) $time $train
    }
    return $GetTrackStatus(theTrack)
  }

}

proc ViewATrain {{number {}}} {
# Procedure to view a train.  Bound to Train menu item on the View menu.
# <in> number (optional) -- train number to view.
# [index] ViewATrain!procedure

  global Trains ViewATrainStatus Stations HasCabP Notes

  catch {unset ViewATrainStatus}
  set trList [lsort -command TrainComp [array names Trains]]
  if {[llength $trList] == 0} {return}

  if {[string length "$number"] > 0 &&
      [llength [array names Trains "$number"]] > 0} {
    set ViewATrainStatus(Train) "$number"
    set ViewATrainStatus(Button) 1
  }

  if {[string length "$number"] == 0 ||
      [llength [array names Trains "$number"]] == 0} {
# .getTrainNumber
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getTrainNumber
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getTrainNumber"
  } {
    catch "destroy .getTrainNumber"
  }
  toplevel .getTrainNumber 

  # Window manager configurations
  wm positionfrom .getTrainNumber ""
  wm sizefrom .getTrainNumber ""
  wm maxsize .getTrainNumber 1009 738
  wm minsize .getTrainNumber 1 1
  wm protocol .getTrainNumber WM_DELETE_WINDOW {.getTrainNumber.buttons.button5 invoke}
  wm title .getTrainNumber {Get Train Number}
  wm transient .getTrainNumber .


  # build widget .getTrainNumber.banner
  frame .getTrainNumber.banner \
    -borderwidth {2}

  # build widget .getTrainNumber.banner.label27
  label .getTrainNumber.banner.label27 \
    -image {banner}

  # build widget .getTrainNumber.banner.label28
  label .getTrainNumber.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Train Number to View}

  # build widget .getTrainNumber.info
  frame .getTrainNumber.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .getTrainNumber.info.label3
  label .getTrainNumber.info.label3 \
    -text {Train:}

  # build widget .getTrainNumber.info.number
  eval [concat tk_optionMenu .getTrainNumber.info.number ViewATrainStatus(Train) $trList]

  # build widget .getTrainNumber.buttons
  frame .getTrainNumber.buttons \
    -borderwidth {2}

  # build widget .getTrainNumber.buttons.button5
  button .getTrainNumber.buttons.button5 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global ViewATrainStatus; set ViewATrainStatus(Button) 0}

  # build widget .getTrainNumber.buttons.button6
  button .getTrainNumber.buttons.button6 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {global ViewATrainStatus; set ViewATrainStatus(Button) 1}

  # pack master .getTrainNumber.banner
  pack configure .getTrainNumber.banner.label27 \
    -side left
  pack configure .getTrainNumber.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrainNumber.info
  pack configure .getTrainNumber.info.label3 \
    -side left
  pack configure .getTrainNumber.info.number \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrainNumber.buttons
  pack configure .getTrainNumber.buttons.button5 \
    -side left
  pack configure .getTrainNumber.buttons.button6 \
    -side right

  # pack master .getTrainNumber
  pack configure .getTrainNumber.banner \
    -fill x
  pack configure .getTrainNumber.info \
    -expand 1 \
    -fill both
  pack configure .getTrainNumber.buttons \
    -fill x
# end of widget tree

  set w .getTrainNumber
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set ViewATrainStatus(Button) -1
  tkwait variable ViewATrainStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .getTrainNumber}
  }  
  if {$ViewATrainStatus(Button) == 0} {
    return
  } else {

    set TrainStruct $Trains($ViewATrainStatus(Train))
# .viewTrain
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .viewTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .viewTrain"
  } {
    catch "destroy .viewTrain"
  }
  toplevel .viewTrain 

  # Window manager configurations
  wm positionfrom .viewTrain ""
  wm sizefrom .viewTrain ""
  wm maxsize .viewTrain 1000 768
  wm minsize .viewTrain 10 10
  wm protocol .viewTrain WM_DELETE_WINDOW {.viewTrain.button9 invoke}
  wm title .viewTrain {View Train}


  # build widget .viewTrain.banner
  frame .viewTrain.banner \
    -borderwidth {2}

  # build widget .viewTrain.banner.label27
  label .viewTrain.banner.label27 \
    -image {banner}

  # build widget .viewTrain.banner.label28
  label .viewTrain.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Train}

  # build widget .viewTrain.info
  frame .viewTrain.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .viewTrain.info.heading
  frame .viewTrain.info.heading \
    -borderwidth {2}

  # build widget .viewTrain.info.heading.number
  label .viewTrain.info.heading.number -text $ViewATrainStatus(Train)

  # build widget .viewTrain.info.heading.name 
  label .viewTrain.info.heading.name -text "[lindex [lindex $TrainStruct 0] 0]"

  # build widget .viewTrain.info.heading.class
  label .viewTrain.info.heading.class -text "Class: [lindex [lindex $TrainStruct 0] 2]"

  # build widget .viewTrain.info.heading.speed
  label .viewTrain.info.heading.speed -text "Speed: [lindex [lindex $TrainStruct 0] 1] smph"

  set notes "[lindex [lindex $TrainStruct 0] 3]"

  # build widget .viewTrain.info.schedFrame
  frame .viewTrain.info.schedFrame \
    -borderwidth {2}

  # build widget .viewTrain.info.schedFrame.sched
  canvas .viewTrain.info.schedFrame.sched \
    -height {207} \
    -width {295} \
    -yscrollcommand {.viewTrain.info.schedFrame.schedVScroll set}

  # build widget .viewTrain.info.schedFrame.schedVScroll
  scrollbar .viewTrain.info.schedFrame.schedVScroll \
    -command {.viewTrain.info.schedFrame.sched yview}

  # build widget .viewTrain.info.notesFrame
  frame .viewTrain.info.notesFrame \
    -borderwidth {2}

  # build widget .viewTrain.info.notesFrame.scrollbar1
  scrollbar .viewTrain.info.notesFrame.scrollbar1 \
    -command {.viewTrain.info.notesFrame.notes yview}

  # build widget .viewTrain.info.notesFrame.notes
  text .viewTrain.info.notesFrame.notes \
    -height {6} \
    -relief {flat} \
    -width {60} \
    -wrap {word} \
    -yscrollcommand {.viewTrain.info.notesFrame.scrollbar1 set}
  # bindings
  bind .viewTrain.info.notesFrame.notes <Key> {break}

  # build widget .viewTrain.info.label11
  label .viewTrain.info.label11 \
    -anchor {w} \
    -relief {ridge} \
    -text {Notes:}

  # build widget .viewTrain.button9
  button .viewTrain.button9 \
    -command {destroy .viewTrain} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .viewTrain.banner
  pack configure .viewTrain.banner.label27 \
    -side left
  pack configure .viewTrain.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .viewTrain.info
  pack configure .viewTrain.info.heading \
    -fill x
  pack configure .viewTrain.info.schedFrame \
    -expand 1 \
    -fill both
  pack configure .viewTrain.info.label11 \
    -anchor w \
    -fill x
  pack configure .viewTrain.info.notesFrame \
    -fill both -expand 1

  # pack master .viewTrain.info.heading
  pack configure .viewTrain.info.heading.number \
    -side left
  pack configure .viewTrain.info.heading.name \
    -expand 1 \
    -fill x \
    -side left
  pack configure .viewTrain.info.heading.class \
    -side left
  pack configure .viewTrain.info.heading.speed \
    -side right

  # pack master .viewTrain.info.schedFrame
  pack configure .viewTrain.info.schedFrame.sched \
    -expand 1 \
    -fill both \
    -side left
  pack configure .viewTrain.info.schedFrame.schedVScroll \
    -fill y \
    -side right

  # pack master .viewTrain.info.notesFrame
  pack configure .viewTrain.info.notesFrame.scrollbar1 \
    -fill y \
    -side right
  pack configure .viewTrain.info.notesFrame.notes \
    -expand 1 \
    -fill both

  # pack master .viewTrain
  pack configure .viewTrain.banner \
    -fill x
  pack configure .viewTrain.info \
    -expand 1 \
    -fill both
  pack configure .viewTrain.button9 \
    -fill x

  # build canvas items .viewTrain.info.schedFrame.sched

  frame .viewTrain.info.schedFrame.sched.sframe -borderwidth 0

  label .viewTrain.info.schedFrame.sched.sframe.mile0 -text {Mile} -anchor e
  label .viewTrain.info.schedFrame.sched.sframe.arrival0 -text {Arival} -anchor w
  label .viewTrain.info.schedFrame.sched.sframe.station0 -text {Station} -anchor w
  label .viewTrain.info.schedFrame.sched.sframe.depart0  -text {Depart} -anchor e
  label .viewTrain.info.schedFrame.sched.sframe.notes0 -text {Notes} -anchor w

  foreach w  {mile arrival station depart notes} \
	  c  {0    1       2       3      4} \
	  sk {e    e       w       e      w} {
    grid configure .viewTrain.info.schedFrame.sched.sframe.${w}0 \
    	-column $c -row 0 -sticky $sk
  }

  set index 1
  set mileOffset $Stations([lindex [lindex $TrainStruct 1] 1])
  foreach stInfo [lrange $TrainStruct 1 end] {
    set arrival [lindex $stInfo 0]
    set station [lindex $stInfo 1]
    set depart  [lindex $stInfo 2]
    if {$HasCabP} {
      set cab [lindex $stInfo 3]
    }
    set snotes [lindex $stInfo 4]
    foreach sn $snotes {
      if {[lsearch -exact $notes $sn] < 0} {lappend notes $sn}
    }
    set mile [expr abs(int(($Stations($station) - $mileOffset)+.5))]
    label .viewTrain.info.schedFrame.sched.sframe.mile$index \
	-text "$mile" -anchor e
    if {[llength $arrival] == 1} {
      label .viewTrain.info.schedFrame.sched.sframe.arrival$index \
	-text "[format {%2d:%02d} [expr int($arrival) / 60] [expr int($arrival) % 60]]" \
	-anchor e
    } else {
      set track [lindex $arrival 1]
      if {[string compare "$track" {N/A}] == 0} {
	set atext {}
      } else {
	set atext "Tr: $track"
      }
      label .viewTrain.info.schedFrame.sched.sframe.arrival$index \
	-text "$atext" \
	-anchor w
    }
    label .viewTrain.info.schedFrame.sched.sframe.station$index -text "$station" -anchor w
    if {[llength $depart] == 1} {
    label .viewTrain.info.schedFrame.sched.sframe.depart$index \
	-text "[format {%2d:%02d} [expr int($depart) / 60] [expr int($depart) % 60]]" \
	-anchor e
    } else {
      set track [lindex $depart 1]
      if {[string compare "$track" {N/A}] == 0} {
	set dtext {}
      } else {
	set dtext "Tr: $track"
      }
      label .viewTrain.info.schedFrame.sched.sframe.depart$index \
	-text "$dtext" \
	-anchor w
    }
    label .viewTrain.info.schedFrame.sched.sframe.notes$index \
	-text "[lsort -integer $snotes]" -anchor w
    foreach w  {mile arrival station depart notes} \
	    c  {0    1       2       3      4} \
	    sk {e    e       w       e      w} {
      grid configure .viewTrain.info.schedFrame.sched.sframe.${w}$index \
    	-column $c -row $index -sticky $sk
    }
    incr index
  }
  set index [llength $TrainStruct]

  label .viewTrain.info.schedFrame.sched.sframe.mile$index -text {Mile} -anchor e
  label .viewTrain.info.schedFrame.sched.sframe.arrival$index -text {Arival} -anchor w
  label .viewTrain.info.schedFrame.sched.sframe.station$index -text {Station} -anchor w
  label .viewTrain.info.schedFrame.sched.sframe.depart$index  -text {Depart} -anchor e
  label .viewTrain.info.schedFrame.sched.sframe.notes$index -text {Notes} -anchor w

  foreach w  {mile arrival station depart notes} \
	  c  {0    1       2       3      4} \
	  sk {e    e       w       e      w} {
    grid configure .viewTrain.info.schedFrame.sched.sframe.${w}$index \
    	-column $c -row $index -sticky $sk
  }
  update idletasks
  .viewTrain.info.schedFrame.sched create window 0 0 -anchor nw \
	-window .viewTrain.info.schedFrame.sched.sframe
   set sr [grid bbox .viewTrain.info.schedFrame.sched.sframe]
   .viewTrain.info.schedFrame.sched configure -scrollregion $sr -width [lindex $sr 2]

  .viewTrain.info.notesFrame.notes insert end {}
  foreach n [lsort -integer $notes] {
    .viewTrain.info.notesFrame.notes insert end "$n. $Notes($n)\n\n"
  }

# end of widget tree

  set w .viewTrain
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    

  }
}

proc TrainComp {trA trB} {
# Procedure to compare train keys.  Trains are sorted by class, number, and section.
# <in> trA -- a train.
# <in> trB -- another train.
# [index] TrainComp!procedure

  global Trains

  if {[regexp {^([0-9]+)-([0-9]+)$} "$trA" whole trAN trAS] < 1} {
    set trAN $trA
    set trAS 0
  }
  if {[regexp {^([0-9]+)-([0-9]+)$} "$trB" whole trBN trBS] < 1} {
    set trBN $trB
    set trBS 0
  }
  set trAC [lindex [lindex $Trains($trA) 0] 2]
  set trBC [lindex [lindex $Trains($trB) 0] 2]

  if {$trAC < $trBC} {
    return -1
  } elseif {$trAC > $trBC} {
    return 1
  } else {
    if {$trAN < $trBN} {
      return -1
    } elseif {$trAN > $trBN} {
      return 1
    } elseif {$trAS < $trBS} {
      return -1
    } elseif {$trAS > $trBS} {
      return 1
    } else {
      return 0
    }
  }
}

proc ViewTrains {} {
# Procedure to view all trains.  Bound to All Trains menu item on the View menu.
# [index] ViewTrains!procedure

  global Trains ViewATrainStatus Stations HasCabP Notes

  set trList [lsort -command TrainComp [array names Trains]]
  if {[llength $trList] == 0} {
    tk_messageBox -type ok -icon info -message "No trains!"
    return
  }

# .viewAllTrains
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .viewAllTrains
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .viewAllTrains"
  } {
    catch "destroy .viewAllTrains"
  }
  toplevel .viewAllTrains 

  # Window manager configurations
  wm positionfrom .viewAllTrains ""
  wm sizefrom .viewAllTrains ""
  wm maxsize .viewAllTrains 1000 768
  wm minsize .viewAllTrains 10 10
  wm protocol .viewAllTrains WM_DELETE_WINDOW {.viewAllTrains.button9 invoke}
  wm title .viewAllTrains {View All Trains}


  # build widget .viewAllTrains.banner
  frame .viewAllTrains.banner \
    -borderwidth {2}

  # build widget .viewAllTrains.banner.label27
  label .viewAllTrains.banner.label27 \
    -image {banner}

  # build widget .viewAllTrains.banner.label28
  label .viewAllTrains.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View All Trains}

  # build widget .viewAllTrains.info
  frame .viewAllTrains.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .viewAllTrains.info.schedFrame
  frame .viewAllTrains.info.schedFrame \
    -borderwidth {2}

  # build widget .viewAllTrains.info.schedFrame.sched
  canvas .viewAllTrains.info.schedFrame.sched \
    -height {207} \
    -width {295} \
    -yscrollcommand {.viewAllTrains.info.schedFrame.schedVScroll set}

  # build widget .viewAllTrains.info.schedFrame.schedVScroll
  scrollbar .viewAllTrains.info.schedFrame.schedVScroll \
    -command {.viewAllTrains.info.schedFrame.sched yview}

  # build widget .viewAllTrains.button9
  button .viewAllTrains.button9 \
    -command {destroy .viewAllTrains} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .viewAllTrains.banner
  pack configure .viewAllTrains.banner.label27 \
    -side left
  pack configure .viewAllTrains.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .viewAllTrains.info
  pack configure .viewAllTrains.info.schedFrame \
    -expand 1 \
    -fill both

  # pack master .viewAllTrains.info.schedFrame
  pack configure .viewAllTrains.info.schedFrame.sched \
    -expand 1 \
    -fill both \
    -side left
  pack configure .viewAllTrains.info.schedFrame.schedVScroll \
    -fill y \
    -side right

  # pack master .viewAllTrains
  pack configure .viewAllTrains.banner \
    -fill x
  pack configure .viewAllTrains.info \
    -expand 1 \
    -fill both
  pack configure .viewAllTrains.button9 \
    -fill x

  # build canvas items .viewAllTrains.info.schedFrame.sched

  frame .viewAllTrains.info.schedFrame.sched.sframe -borderwidth 0

  label .viewAllTrains.info.schedFrame.sched.sframe.number0 -text {Number} -anchor e
  label .viewAllTrains.info.schedFrame.sched.sframe.name0 -text {Name} -anchor w
  label .viewAllTrains.info.schedFrame.sched.sframe.speed0 -text {Speed} -anchor e    
  label .viewAllTrains.info.schedFrame.sched.sframe.orig0 -text {Origin} -anchor w
  label .viewAllTrains.info.schedFrame.sched.sframe.dest0 -text {Destination} -anchor w
  label .viewAllTrains.info.schedFrame.sched.sframe.length0 -text {Miles} -anchor e
  label .viewAllTrains.info.schedFrame.sched.sframe.time0 -text {Running Time}  -anchor e

  foreach w  {number name speed orig dest length time} \
	  c  {0      1    2     3    4    5      6} \
	  sk {e      w    e     w    w    e      e} {
    grid configure .viewAllTrains.info.schedFrame.sched.sframe.${w}0 \
	-column $c -row 0 -sticky $sk
  }

  set index 1
  foreach trnum $trList {
    button .viewAllTrains.info.schedFrame.sched.sframe.number$index \
	-text $trnum -anchor e -command "ViewATrain $trnum"
    set TrainStruct $Trains($trnum)
    label .viewAllTrains.info.schedFrame.sched.sframe.name$index -text "[lindex [lindex $TrainStruct 0] 0]" -anchor w
    label .viewAllTrains.info.schedFrame.sched.sframe.speed$index -text [lindex [lindex $TrainStruct 0] 1] -anchor e
    set oStation [lindex [lindex $TrainStruct 1] 1]
    set dStation [lindex [lindex $TrainStruct end] 1]
    set sTime    [lindex [lindex $TrainStruct 1] 2]
    set eTime    [lindex [lindex $TrainStruct end] 0]
    set dist     [expr int(abs($Stations($dStation)-$Stations($oStation))+.5)]
    set rTime    [expr int(($eTime-$sTime)+.5)]
    set rTimeFmt "[format {%2d:%02d} [expr $rTime / 60] [expr $rTime % 60]]"
    label .viewAllTrains.info.schedFrame.sched.sframe.orig$index -text "$oStation" -anchor w
    label .viewAllTrains.info.schedFrame.sched.sframe.dest$index -text "$dStation" -anchor w
    label .viewAllTrains.info.schedFrame.sched.sframe.length$index -text $dist -anchor e
    label .viewAllTrains.info.schedFrame.sched.sframe.time$index -text "$rTimeFmt" -anchor e
    foreach w  {number name speed orig dest length time} \
	    c  {0      1    2     3    4    5      6} \
	    sk {e      w    e     w    w    e      e} {
      grid configure .viewAllTrains.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky $sk
    }
    incr index
  }
  label .viewAllTrains.info.schedFrame.sched.sframe.number$index -text {Number} -anchor e
  label .viewAllTrains.info.schedFrame.sched.sframe.name$index -text {Name} -anchor w
  label .viewAllTrains.info.schedFrame.sched.sframe.speed$index -text {Speed} -anchor e    
  label .viewAllTrains.info.schedFrame.sched.sframe.orig$index -text {Origin} -anchor w
  label .viewAllTrains.info.schedFrame.sched.sframe.dest$index -text {Destination} -anchor w
  label .viewAllTrains.info.schedFrame.sched.sframe.length$index -text {Miles} -anchor e
  label .viewAllTrains.info.schedFrame.sched.sframe.time$index -text {Running Time}  -anchor e

  foreach w  {number name speed orig dest length time} \
	  c  {0      1    2     3    4    5      6} \
	  sk {e      w    e     w    w    e      e} {
    grid configure .viewAllTrains.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky $sk
  }
  update idletasks
  .viewAllTrains.info.schedFrame.sched create window 0 0 -anchor nw \
	-window .viewAllTrains.info.schedFrame.sched.sframe
   set sr [grid bbox .viewAllTrains.info.schedFrame.sched.sframe]
   .viewAllTrains.info.schedFrame.sched configure -scrollregion $sr -width [lindex $sr 2]


# end of widget tree

  set w .viewAllTrains
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    
}

proc ViewStations {} {
# Procedure to view all stations.  Bound to Stations menu item on the View menu.
# [index] ViewStations!procedure

  global Stations TotalLength DuplicateTrackMap

  set stList [lsort -command StationDistanceComp [array names Stations]]

# .viewStations
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .viewStations
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .viewStations"
  } {
    catch "destroy .viewStations"
  }
  toplevel .viewStations 

  # Window manager configurations
  wm positionfrom .viewStations ""
  wm sizefrom .viewStations ""
  wm maxsize .viewStations 1000 768
  wm minsize .viewStations 10 10
  wm protocol .viewStations WM_DELETE_WINDOW {.viewStations.button9 invoke}
  wm title .viewStations {View Stations}


  # build widget .viewStations.banner
  frame .viewStations.banner \
    -borderwidth {2}

  # build widget .viewStations.banner.label27
  label .viewStations.banner.label27 \
    -image {banner}

  # build widget .viewStations.banner.label28
  label .viewStations.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Stations}

  # build widget .viewStations.info
  frame .viewStations.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .viewStations.info.schedFrame
  frame .viewStations.info.schedFrame \
    -borderwidth {2}

  # build widget .viewStations.info.schedFrame.sched
  canvas .viewStations.info.schedFrame.sched \
    -height {207} \
    -width {295} \
    -yscrollcommand {.viewStations.info.schedFrame.schedVScroll set}

  # build widget .viewStations.info.schedFrame.schedVScroll
  scrollbar .viewStations.info.schedFrame.schedVScroll \
    -command {.viewStations.info.schedFrame.sched yview}

  # build widget .viewStations.button9
  button .viewStations.button9 \
    -command {destroy .viewStations} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .viewStations.banner
  pack configure .viewStations.banner.label27 \
    -side left
  pack configure .viewStations.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .viewStations.info
  pack configure .viewStations.info.schedFrame \
    -expand 1 \
    -fill both

  # pack master .viewStations.info.schedFrame
  pack configure .viewStations.info.schedFrame.sched \
    -expand 1 \
    -fill both \
    -side left
  pack configure .viewStations.info.schedFrame.schedVScroll \
    -fill y \
    -side right

  # pack master .viewStations
  pack configure .viewStations.banner \
    -fill x
  pack configure .viewStations.info \
    -expand 1 \
    -fill both
  pack configure .viewStations.button9 \
    -fill x

  # build canvas items .viewStations.info.schedFrame.sched

  if {[llength [array names DuplicateTrackMap]] > 0} {
    set hasDupP 1
    set wids {name smile rname}    
    set cols {0 1 2}
    set sticks {w e w}
  } else {
    set hasDupP 0
    set wids {name smile}
    set cols {0 1}
    set sticks {w e}
  }

  frame .viewStations.info.schedFrame.sched.sframe -borderwidth 0

  label .viewStations.info.schedFrame.sched.sframe.name0 -text {Name} -anchor w
  label .viewStations.info.schedFrame.sched.sframe.smile0 -text {Smiles} -anchor e
  if {$hasDupP} {
    label .viewStations.info.schedFrame.sched.sframe.rname0 -text {Reverse Name} -anchor w
  }

  foreach w $wids c $cols sk $sticks {
    grid configure .viewStations.info.schedFrame.sched.sframe.${w}0 \
	-column $c -row 0 -sticky $sk
  }

  set index 1
  foreach station $stList {
    label .viewStations.info.schedFrame.sched.sframe.name$index -text "$station" -anchor w
    label .viewStations.info.schedFrame.sched.sframe.smile$index -text "[format {%6.3f} $Stations($station)]" -anchor e
    if {$hasDupP} {
      label .viewStations.info.schedFrame.sched.sframe.rname$index -text "[FindDuplicateStation $station]" -anchor w
    }
    foreach w $wids c $cols sk $sticks {
      grid configure .viewStations.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky $sk
    }
    incr index
  }
  
  label .viewStations.info.schedFrame.sched.sframe.name$index -text {Name} -anchor w
  label .viewStations.info.schedFrame.sched.sframe.smile$index -text {Smiles} -anchor e
  if {$hasDupP} {
    label .viewStations.info.schedFrame.sched.sframe.rname$index -text {Reverse Name} -anchor w
  }

  foreach w $wids c $cols sk $sticks {
    grid configure .viewStations.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky $sk
  }

  update idletasks
  .viewStations.info.schedFrame.sched create window 0 0 -anchor nw \
	-window .viewStations.info.schedFrame.sched.sframe
   set sr [grid bbox .viewStations.info.schedFrame.sched.sframe]
   .viewStations.info.schedFrame.sched configure -scrollregion $sr -width [lindex $sr 2]


# end of widget tree

  set w .viewStations
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    
}

proc ViewCabs {} {
# Procedure to view all cabs.  Bound to Cabs menu item on the View menu.
# [index] ViewCabs!procedure

  global CabColors HasCabP

  if {!$HasCabP} {return}
  set cablist [lsort -dictionary [array names CabColors]]
  if {[llength $cablist] == 0} {
    tk_messageBox -type ok -icon info -message {No Cabs!}
    return
  }

# .viewCabs
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .viewCabs
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .viewCabs"
  } {
    catch "destroy .viewCabs"
  }
  toplevel .viewCabs 

  # Window manager configurations
  wm positionfrom .viewCabs ""
  wm sizefrom .viewCabs ""
  wm maxsize .viewCabs 1000 768
  wm minsize .viewCabs 10 10
  wm protocol .viewCabs WM_DELETE_WINDOW {.viewCabs.button9 invoke}
  wm title .viewCabs {View Cabs}


  # build widget .viewCabs.banner
  frame .viewCabs.banner \
    -borderwidth {2}

  # build widget .viewCabs.banner.label27
  label .viewCabs.banner.label27 \
    -image {banner}

  # build widget .viewCabs.banner.label28
  label .viewCabs.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Cabs}

  # build widget .viewCabs.info
  frame .viewCabs.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .viewCabs.info.schedFrame
  frame .viewCabs.info.schedFrame \
    -borderwidth {2}

  # build widget .viewCabs.info.schedFrame.sched
  canvas .viewCabs.info.schedFrame.sched \
    -height {207} \
    -width {295} \
    -yscrollcommand {.viewCabs.info.schedFrame.schedVScroll set}

  # build widget .viewCabs.info.schedFrame.schedVScroll
  scrollbar .viewCabs.info.schedFrame.schedVScroll \
    -command {.viewCabs.info.schedFrame.sched yview}

  # build widget .viewCabs.button9
  button .viewCabs.button9 \
    -command {destroy .viewCabs} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .viewCabs.banner
  pack configure .viewCabs.banner.label27 \
    -side left
  pack configure .viewCabs.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .viewCabs.info
  pack configure .viewCabs.info.schedFrame \
    -expand 1 \
    -fill both

  # pack master .viewCabs.info.schedFrame
  pack configure .viewCabs.info.schedFrame.sched \
    -expand 1 \
    -fill both \
    -side left
  pack configure .viewCabs.info.schedFrame.schedVScroll \
    -fill y \
    -side right

  # pack master .viewCabs
  pack configure .viewCabs.banner \
    -fill x
  pack configure .viewCabs.info \
    -expand 1 \
    -fill both
  pack configure .viewCabs.button9 \
    -fill x

  # build canvas items .viewCabs.info.schedFrame.sched

  frame .viewCabs.info.schedFrame.sched.sframe -borderwidth 0

  label .viewCabs.info.schedFrame.sched.sframe.cab0 -text {Cab Name} -anchor w
  label .viewCabs.info.schedFrame.sched.sframe.color0 -text {Cab Color} -anchor w

  foreach w {cab color} c {0 1} {
    grid configure .viewCabs.info.schedFrame.sched.sframe.${w}0 \
	-column $c -row 0 -sticky w
  }

  set index 1
  foreach cab $cablist {
    label .viewCabs.info.schedFrame.sched.sframe.cab$index -text "$cab" -anchor w
    label .viewCabs.info.schedFrame.sched.sframe.color$index -text "$CabColors($cab)" -anchor w
    foreach w {cab color} c {0 1} {
      grid configure .viewCabs.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky w
    }
    incr index
  }
  
  label .viewCabs.info.schedFrame.sched.sframe.cab$index -text {Cab Name} -anchor w
  label .viewCabs.info.schedFrame.sched.sframe.color$index -text {Cab Color} -anchor w

  foreach w {cab color} c {0 1} {
    grid configure .viewCabs.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky w
  }

  update idletasks
  .viewCabs.info.schedFrame.sched create window 0 0 -anchor nw \
	-window .viewCabs.info.schedFrame.sched.sframe
   set sr [grid bbox .viewCabs.info.schedFrame.sched.sframe]
   .viewCabs.info.schedFrame.sched configure -scrollregion $sr -width [lindex $sr 2]


# end of widget tree

  set w .viewCabs
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    

}

proc ViewStorageTracks {} {
# Procedure to view storage tracks.  Bound to Storage Tracks menu item on the View menu.
# [index] ViewStorageTracks!procedure

  global TrackList HasTrackP

  if{!$HasTrackP} {return}
  set stlist [lsort -command StationDistanceComp [array names TrackList]]
  if {[llength $stlist] == 0} {
    tk_messageBox -type ok -icon info -message {No Storage Tracks!}
    return
  }

# .viewStorageTracks
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .viewStorageTracks
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .viewStorageTracks"
  } {
    catch "destroy .viewStorageTracks"
  }
  toplevel .viewStorageTracks 

  # Window manager configurations
  wm positionfrom .viewStorageTracks ""
  wm sizefrom .viewStorageTracks ""
  wm maxsize .viewStorageTracks 1000 768
  wm minsize .viewStorageTracks 10 10
  wm protocol .viewStorageTracks WM_DELETE_WINDOW {.viewStorageTracks.button9 invoke}
  wm title .viewStorageTracks {View Storage Tracks}


  # build widget .viewStorageTracks.banner
  frame .viewStorageTracks.banner \
    -borderwidth {2}

  # build widget .viewStorageTracks.banner.label27
  label .viewStorageTracks.banner.label27 \
    -image {banner}

  # build widget .viewStorageTracks.banner.label28
  label .viewStorageTracks.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Storage Tracks}

  # build widget .viewStorageTracks.info
  frame .viewStorageTracks.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .viewStorageTracks.info.schedFrame
  frame .viewStorageTracks.info.schedFrame \
    -borderwidth {2}

  # build widget .viewStorageTracks.info.schedFrame.sched
  canvas .viewStorageTracks.info.schedFrame.sched \
    -height {207} \
    -width {295} \
    -yscrollcommand {.viewStorageTracks.info.schedFrame.schedVScroll set}

  # build widget .viewStorageTracks.info.schedFrame.schedVScroll
  scrollbar .viewStorageTracks.info.schedFrame.schedVScroll \
    -command {.viewStorageTracks.info.schedFrame.sched yview}

  # build widget .viewStorageTracks.button9
  button .viewStorageTracks.button9 \
    -command {destroy .viewStorageTracks} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .viewStorageTracks.banner
  pack configure .viewStorageTracks.banner.label27 \
    -side left
  pack configure .viewStorageTracks.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .viewStorageTracks.info
  pack configure .viewStorageTracks.info.schedFrame \
    -expand 1 \
    -fill both

  # pack master .viewStorageTracks.info.schedFrame
  pack configure .viewStorageTracks.info.schedFrame.sched \
    -expand 1 \
    -fill both \
    -side left
  pack configure .viewStorageTracks.info.schedFrame.schedVScroll \
    -fill y \
    -side right

  # pack master .viewStorageTracks
  pack configure .viewStorageTracks.banner \
    -fill x
  pack configure .viewStorageTracks.info \
    -expand 1 \
    -fill both
  pack configure .viewStorageTracks.button9 \
    -fill x

  # build canvas items .viewStorageTracks.info.schedFrame.sched

  frame .viewStorageTracks.info.schedFrame.sched.sframe -borderwidth 0

  label .viewStorageTracks.info.schedFrame.sched.sframe.station0 -text {Station} -anchor w
  label .viewStorageTracks.info.schedFrame.sched.sframe.tracks0 -text {Tracks} -anchor w

  foreach w {name tracks} c {0 1} {
    grid configure .viewStorageTracks.info.schedFrame.sched.sframe.${w}0 \
	-column $c -row 0 -sticky w
  }

  set index 1
  foreach station $stList {
    label .viewStorageTracks.info.schedFrame.sched.sframe.station$index -text "$station" -anchor w
    label .viewStorageTracks.info.schedFrame.sched.sframe.tracks$index -text "$TrackList($station)]" -anchor w
    foreach w {name tracks} c {0 1} {
      grid configure .viewStorageTracks.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky w
    }
    incr index
  }
  
  label .viewStorageTracks.info.schedFrame.sched.sframe.station$index -text {Station} -anchor w
  label .viewStorageTracks.info.schedFrame.sched.sframe.tracks$index -text {Tracks} -anchor w

  foreach w {name tracks} c {0 1} {
    grid configure .viewStorageTracks.info.schedFrame.sched.sframe.${w}$index \
	-column $c -row $index -sticky w
  }

  update idletasks
  .viewStorageTracks.info.schedFrame.sched create window 0 0 -anchor nw \
	-window .viewStorageTracks.info.schedFrame.sched.sframe
   set sr [grid bbox .viewStorageTracks.info.schedFrame.sched.sframe]
   .viewStorageTracks.info.schedFrame.sched configure -scrollregion $sr -width [lindex $sr 2]


# end of widget tree

  set w .viewStorageTracks
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    

}

proc ViewAllNotes {} {
# Procedure to view all notes.  Bound to View All Nores menu item on the Notes menu.
# [index] ViewAllNotes!procedure

  global Notes

  set ntList [lsort -integer [array names Notes]]

  if {[llength $ntList] == 0} {
    tk_messageBox -type ok -icon info -message {No Notes!}
    return
  }

# .viewNotes
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .viewNotes
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .viewNotes"
  } {
    catch "destroy .viewNotes"
  }
  toplevel .viewNotes 

  # Window manager configurations
  wm positionfrom .viewNotes ""
  wm sizefrom .viewNotes ""
  wm maxsize .viewNotes 1000 768
  wm minsize .viewNotes 10 10
  wm protocol .viewNotes WM_DELETE_WINDOW {.viewNotes.button15 invoke}
  wm title .viewNotes {View Notes}
  wm transient .viewNotes .


  # build widget .viewNotes.banner
  frame .viewNotes.banner \
    -borderwidth {2}

  # build widget .viewNotes.banner.label27
  label .viewNotes.banner.label27 \
    -image {banner}

  # build widget .viewNotes.banner.label28
  label .viewNotes.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View All Notes}

  # build widget .viewNotes.frame
  frame .viewNotes.frame \
    -relief {raised}

  # build widget .viewNotes.frame.scrollbar1
  scrollbar .viewNotes.frame.scrollbar1 \
    -command {.viewNotes.frame.text2 yview}

  # build widget .viewNotes.frame.text2
  text .viewNotes.frame.text2 \
    -wrap {word} \
    -yscrollcommand {.viewNotes.frame.scrollbar1 set}
  # bindings
  bind .viewNotes.frame.text2 <Key> {break}

  # build widget .viewNotes.button15
  button .viewNotes.button15 \
    -command {catch {destroy .viewNotes}} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .viewNotes.banner
  pack configure .viewNotes.banner.label27 \
    -side left
  pack configure .viewNotes.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .viewNotes.frame
  pack configure .viewNotes.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .viewNotes.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .viewNotes
  pack configure .viewNotes.banner \
    -fill x
  pack configure .viewNotes.frame \
    -expand 1 \
    -fill both
  pack configure .viewNotes.button15 \
    -expand 1 \
    -fill x

  .viewNotes.frame.text2 insert end {}

  foreach n $ntList {
    .viewNotes.frame.text2 insert end "[format {%4d. } $n]"
    .viewNotes.frame.text2 insert end "$Notes($n)\n\n"
  }

# end of widget tree

  set w .viewNotes
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
}

proc CreateNote {} {
# Procedure to create a new note.  Bound to the Create New Note menu item
# on the Notes menu.
# [index] CreateNote!procedure

  global Notes CreateNoteStatus

  set lastNote [lindex [lsort -integer -decreasing [array names Notes]] 0]
  if {[string compare "$lastNote" {}] == 0} {set lastNote 0}
  set CreateNoteStatus(number) [expr $lastNote + 1]

# .createNote
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .createNote
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .createNote"
  } {
    catch "destroy .createNote"
  }
  toplevel .createNote 

  # Window manager configurations
  wm positionfrom .createNote ""
  wm sizefrom .createNote ""
  wm maxsize .createNote 1000 768
  wm minsize .createNote 10 10
  wm protocol .createNote WM_DELETE_WINDOW {.createNote.buttons.button19 invoke}
  wm title .createNote {Create a New Note}
  wm transient .createNote .


  # build widget .createNote.banner
  frame .createNote.banner \
    -borderwidth {2}

  # build widget .createNote.banner.label27
  label .createNote.banner.label27 \
    -image {banner}

  # build widget .createNote.banner.label28
  label .createNote.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Create New Note}

  # build widget .createNote.info
  frame .createNote.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .createNote.info.number
  frame .createNote.info.number \
    -borderwidth {2}

  # build widget .createNote.info.number.label22
  label .createNote.info.number.label22 \
    -text {Number:}

  # build widget .createNote.info.number.number
  entry .createNote.info.number.number \
    -textvariable {CreateNoteStatus(number)}

  # build widget .createNote.info.frame
  frame .createNote.info.frame \
    -relief {raised}

  # build widget .createNote.info.frame.scrollbar1
  scrollbar .createNote.info.frame.scrollbar1 \
    -command {.createNote.info.frame.text2 yview}

  # build widget .createNote.info.frame.text2
  text .createNote.info.frame.text2 \
    -wrap {word} \
    -yscrollcommand {.createNote.info.frame.scrollbar1 set}

  # build widget .createNote.buttons
  frame .createNote.buttons \
    -borderwidth {2}

  # build widget .createNote.buttons.button19
  button .createNote.buttons.button19 \
    -command {global CreateNoteStatus;set CreateNoteStatus(Button) 0} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # build widget .createNote.buttons.button20
  button .createNote.buttons.button20 \
    -command {CreateNoteHelper} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .createNote.banner
  pack configure .createNote.banner.label27 \
    -side left
  pack configure .createNote.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .createNote.info
  pack configure .createNote.info.number \
    -fill x
  pack configure .createNote.info.frame \
    -expand 1 \
    -fill both

  # pack master .createNote.info.number
  pack configure .createNote.info.number.label22 \
    -side left
  pack configure .createNote.info.number.number \
    -expand 1 \
    -fill x \
    -side right

  # pack master .createNote.info.frame
  pack configure .createNote.info.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .createNote.info.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .createNote.buttons
  pack configure .createNote.buttons.button19 \
    -side left
  pack configure .createNote.buttons.button20 \
    -side right

  # pack master .createNote
  pack configure .createNote.banner \
    -fill x
  pack configure .createNote.info \
    -expand 1 \
    -fill both
  pack configure .createNote.buttons \
    -fill x

  .createNote.info.frame.text2 insert end {}


# end of widget tree

  set w .createNote
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  focus .createNote.info.number.number

  set CreateNoteStatus(Button) -1
  tkwait variable CreateNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .createNote}

}

proc CreateNoteHelper {} {
# Procedure to finalize note creation.  Bound to the Done button.
# [index] CreateNoteHelper!procedure

  global CreateNoteStatus Notes

  if {[catch [list expr int($CreateNoteStatus(number))] number]} {
    tk_messageBox -type ok -icon warning -message "Not a number: $CreateNoteStatus(number)!"
    return
  }
  if {$number != $CreateNoteStatus(number)} {
    tk_messageBox -type ok -icon warning -message "Not a whole number: $CreateNoteStatus(number)!"
    return
  }
  if {[llength [array names Notes "$number"]] > 0} {
    tk_messageBox -type ok -icon warning -message "Duplicate note number: $CreateNoteStatus(number)!"
    return
  }

  set Notes($number) "[string trim [.createNote.info.frame.text2 get 1.0 end]]"
  set CreateNoteStatus(Button) 1
}

proc DeleteNote {} {
# Procedure to delete a note.  Bound to the Delete Note menu item
# on the Notes menu.
# [index] DeleteNote!procedure

  global Notes DeleteNoteStatus Trains

  catch {unset DeleteNoteStatus}
  set allNotes [lsort -integer [array names Notes]]

  set ntList {}
  foreach n $allNotes {
    set found 0
    foreach t [array names Trains] {
      set TrainStruct $Trains($t)
      if {[lsearch -exact [lindex [lindex $TrainStruct 0] 3] $n] >= 0} {
	incr found
	break
      }
      foreach stop [lrange $TrainStruct 1 end] {
        if {[lsearch -exact [lindex $stop 4] $n] >= 0} {
	  incr found
	  break
	}
      }
      if {$found} {break}
    }
    if {!$found} {lappend ntList $n}
  }      

  if {[llength $ntList] == 0} {
    tk_messageBox -type ok -icon info -message {No Deletable Notes!}
    return
  }
 
# .deleteNote
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .deleteNote
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .deleteNote"
  } {
    catch "destroy .deleteNote"
  }
  toplevel .deleteNote 

  # Window manager configurations
  wm positionfrom .deleteNote ""
  wm sizefrom .deleteNote ""
  wm maxsize .deleteNote 1000 768
  wm minsize .deleteNote 10 10
  wm protocol .deleteNote WM_DELETE_WINDOW {.deleteNote.buttons.button29 invoke}
  wm title .deleteNote {Delete Note}
  wm transient .deleteNote .


  # build widget .deleteNote.banner
  frame .deleteNote.banner \
    -borderwidth {2}

  # build widget .deleteNote.banner.label27
  label .deleteNote.banner.label27 \
    -image {banner}

  # build widget .deleteNote.banner.label28
  label .deleteNote.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Delete Note}

  # build widget .deleteNote.info
  frame .deleteNote.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .deleteNote.info.label27
  label .deleteNote.info.label27 \
    -text {Delete Note Number:}

  # build widget .deleteNote.info.number
  eval [concat tk_optionMenu .deleteNote.info.number DeleteNoteStatus(Number) $ntList]

  # build widget .deleteNote.buttons
  frame .deleteNote.buttons \
    -borderwidth {2}

  # build widget .deleteNote.buttons.button29
  button .deleteNote.buttons.button29 \
    -command {
	global DeleteNoteStatus
	set DeleteNoteStatus(Button) 0} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # build widget .deleteNote.buttons.button30
  button .deleteNote.buttons.button30 \
    -command {global DeleteNoteStatus
set DeleteNoteStatus(Button) 1} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .deleteNote.banner
  pack configure .deleteNote.banner.label27 \
    -side left
  pack configure .deleteNote.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .deleteNote.info
  pack configure .deleteNote.info.label27 \
    -side left
  pack configure .deleteNote.info.number \
    -expand 1 \
    -side right

  # pack master .deleteNote.buttons
  pack configure .deleteNote.buttons.button29 \
    -side left
  pack configure .deleteNote.buttons.button30 \
    -side right

  # pack master .deleteNote
  pack configure .deleteNote.banner \
    -fill x
  pack configure .deleteNote.info \
    -expand 1 \
    -fill both
  pack configure .deleteNote.buttons \
    -fill x
# end of widget tree

  set w .deleteNote
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set DeleteNoteStatus(Button) -1
  tkwait variable DeleteNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  if {$DeleteNoteStatus(Button) == 1} {
    catch {unset Notes($DeleteNoteStatus(Number))}
  }
  catch {destroy .deleteNote}
  
}

proc EditNote {} {
# Procedure to edit a note.  Bound to the Edit Note menu item
# on the Notes menu.
# [index] EditNote!procedure

  global Notes EditNoteStatus


  set ntList [lsort -integer [array names Notes]]

  if {[llength $ntList] == 0} {
    tk_messageBox -type ok -icon info -message {No Notes to edit!}
    return
  }
 

# .editNote
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .editNote
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .editNote"
  } {
    catch "destroy .editNote"
  }
  toplevel .editNote 

  # Window manager configurations
  wm positionfrom .editNote ""
  wm sizefrom .editNote ""
  wm maxsize .editNote 1000 768
  wm minsize .editNote 10 10
  wm protocol .editNote WM_DELETE_WINDOW {.editNote.buttons.button19 invoke}
  wm title .editNote {Edit A Note}
  wm transient .editNote .


  # build widget .editNote.banner
  frame .editNote.banner \
    -borderwidth {2}

  # build widget .editNote.banner.label27
  label .editNote.banner.label27 \
    -image {banner}

  # build widget .editNote.banner.label28
  label .editNote.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Edit A Note}

  # build widget .editNote.info
  frame .editNote.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .editNote.info.number
  frame .editNote.info.number \
    -borderwidth {2}

  # build widget .editNote.info.number.label22
  label .editNote.info.number.label22 \
    -text {Number:}

  # build widget .editNote.info.number.number
  eval [concat tk_optionMenu .editNote.info.number.number EditNoteStatus(number) $ntList]

  # build widget .editNote.info.number.edit
  button .editNote.info.number.edit \
    -text {Edit} \
    -command {
      global Notes EditNoteStatus
      .editNote.info.frame.text2 configure -state normal
      .editNote.info.frame.text2 delete 1.0 end
      .editNote.info.frame.text2 insert end "$Notes($EditNoteStatus(number))"
      .editNote.info.number.edit configure -state disabled
      .editNote.buttons.next configure -state normal
      .editNote.buttons.done configure -state disabled
    }

  # build widget .editNote.info.frame
  frame .editNote.info.frame \
    -relief {raised}

  # build widget .editNote.info.frame.scrollbar1
  scrollbar .editNote.info.frame.scrollbar1 \
    -command {.editNote.info.frame.text2 yview}

  # build widget .editNote.info.frame.text2
  text .editNote.info.frame.text2 \
    -wrap {word} \
    -yscrollcommand {.editNote.info.frame.scrollbar1 set} \
    -state disabled

  # build widget .editNote.buttons
  frame .editNote.buttons \
    -borderwidth {2}

  # build widget .editNote.buttons.button19
  button .editNote.buttons.button19 \
    -command {global EditNoteStatus;set EditNoteStatus(Button) 0} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # build widget .editNote.buttons.next
  button .editNote.buttons.next \
    -command {
      global EditNoteStatus Notes
      set Notes($EditNoteStatus(number)) "[string trim [.editNote.info.frame.text2 get 1.0 end]]"
      .editNote.info.frame.text2 delete 1.0 end
      .editNote.info.frame.text2 configure -state disabled
      .editNote.buttons.next configure -state disabled
      .editNote.info.number.edit configure -state normal
      .editNote.buttons.done configure -state normal
    } \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -state disabled

  # build widget .editNote.buttons.done
  button .editNote.buttons.done \
    -command {global EditNoteStatus;set EditNoteStatus(Button) 1} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .editNote.banner
  pack configure .editNote.banner.label27 \
    -side left
  pack configure .editNote.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .editNote.info
  pack configure .editNote.info.number \
    -fill x
  pack configure .editNote.info.frame \
    -expand 1 \
    -fill both

  # pack master .editNote.info.number
  pack configure .editNote.info.number.label22 \
    -side left
  pack configure .editNote.info.number.number \
    -expand 1 \
    -fill x \
    -side left
  pack configure .editNote.info.number.edit \
    -side right

  # pack master .editNote.info.frame
  pack configure .editNote.info.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .editNote.info.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .editNote.buttons
  pack configure .editNote.buttons.button19 \
    -side left
  pack configure .editNote.buttons.next \
    -side right
  pack configure .editNote.buttons.done \
    -side right

  # pack master .editNote
  pack configure .editNote.banner \
    -fill x
  pack configure .editNote.info \
    -expand 1 \
    -fill both
  pack configure .editNote.buttons \
    -fill x

# end of widget tree

  set w .editNote
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set EditNoteStatus(Button) -1
  tkwait variable EditNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .editNote}

}

proc AddNoteToTrain {} {
# Procedure to add a note to a train.  Bound to the Add Note To Train menu item
# on the Notes menu.
# [index] AddNoteToTrain!procedure

  global Notes Trains AddNoteStatus

  catch {unset AddNoteStatus}
  set ntList [lsort -integer [array names Notes]]
  if {[llength $ntList] == 0} {
    tk_messageBox -type ok -icon info -message {No Notes!}
    return
  }
  set trList [lsort -command TrainComp [array names Trains]]
  if {[llength $trList] == 0} {
    tk_messageBox -type ok -icon info -message "No trains!"
    return
  }

# .addNoteToTrain
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .addNoteToTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .addNoteToTrain"
  } {
    catch "destroy .addNoteToTrain"
  }
  toplevel .addNoteToTrain 

  # Window manager configurations
  wm positionfrom .addNoteToTrain ""
  wm sizefrom .addNoteToTrain ""
  wm maxsize .addNoteToTrain 1009 738
  wm minsize .addNoteToTrain 1 1
  wm protocol .addNoteToTrain WM_DELETE_WINDOW {.addNoteToTrain.buttons.button7 invoke}
  wm title .addNoteToTrain {Add Note to Train}
  wm transient .addNoteToTrain .


  # build widget .addNoteToTrain.banner
  frame .addNoteToTrain.banner \
    -borderwidth {2}

  # build widget .addNoteToTrain.banner.label27
  label .addNoteToTrain.banner.label27 \
    -image {banner}

  # build widget .addNoteToTrain.banner.label28
  label .addNoteToTrain.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Add Note to Train}

  # build widget .addNoteToTrain.info
  frame .addNoteToTrain.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .addNoteToTrain.info.label3
  label .addNoteToTrain.info.label3 \
    -text {Note: }

  # build widget .addNoteToTrain.info.note
  eval [concat tk_optionMenu .addNoteToTrain.info.note AddNoteStatus(Note) $ntList]

  # build widget .addNoteToTrain.info.label5
  label .addNoteToTrain.info.label5 \
    -text {Train:}

  # build widget .addNoteToTrain.info.train
  eval [concat tk_optionMenu .addNoteToTrain.info.train AddNoteStatus(Train) $trList]

  # build widget .addNoteToTrain.buttons
  frame .addNoteToTrain.buttons \
    -borderwidth {2}

  # build widget .addNoteToTrain.buttons.button7
  button .addNoteToTrain.buttons.button7 \
    -command {global AddNoteStatus;set AddNoteStatus(Button) 0} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # build widget .addNoteToTrain.buttons.button8
  button .addNoteToTrain.buttons.button8 \
    -command {global AddNoteStatus Trains;set AddNoteStatus(Button) 1} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .addNoteToTrain.banner
  pack configure .addNoteToTrain.banner.label27 \
    -side left
  pack configure .addNoteToTrain.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .addNoteToTrain.info
  pack configure .addNoteToTrain.info.label3 \
    -side left
  pack configure .addNoteToTrain.info.note \
    -expand 1 \
    -fill x \
    -side left
  pack configure .addNoteToTrain.info.label5 \
    -side left
  pack configure .addNoteToTrain.info.train \
    -expand 1 \
    -fill x \
    -side right

  # pack master .addNoteToTrain.buttons
  pack configure .addNoteToTrain.buttons.button7 \
    -side left
  pack configure .addNoteToTrain.buttons.button8 \
    -side right

  # pack master .addNoteToTrain
  pack configure .addNoteToTrain.banner \
    -fill x
  pack configure .addNoteToTrain.info \
    -expand 1 \
    -fill both
  pack configure .addNoteToTrain.buttons \
    -fill x
# end of widget tree

  set w .addNoteToTrain
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set AddNoteStatus(Button) -1
  tkwait variable AddNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .addNoteToTrain}

  if {$AddNoteStatus(Button) == 0} {return}
  set TrainStruct $Trains($AddNoteStatus(Train))
  set trHead [lindex $TrainStruct 0]
  set trNotes [lindex $trHead 3]
  if {[lsearch -exact $trNotes $AddNoteStatus(Note)] < 0} {
    lappend trNotes $AddNoteStatus(Note)
    set trHead [lreplace $trHead 3 3 $trNotes]
    set Trains($AddNoteStatus(Train)) [lreplace $TrainStruct 0 0 $trHead]
  }
}

proc AddNoteToTrainAtStation {} {
# Procedure to add a note to a train at a station.  Bound to the Add Note To 
# Train at Station menu item on the Notes menu.
# [index] AddNoteToTrainAtStation!procedure

  global Notes Trains AddNoteStatus

  catch {unset AddNoteStatus}
  set ntList [lsort -integer [array names Notes]]
  if {[llength $ntList] == 0} {
    tk_messageBox -type ok -icon info -message {No Notes!}
    return
  }
  set trList [lsort -command TrainComp [array names Trains]]
  if {[llength $trList] == 0} {
    tk_messageBox -type ok -icon info -message "No trains!"
    return
  }

# .getTrainNumber
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getTrainNumber
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getTrainNumber"
  } {
    catch "destroy .getTrainNumber"
  }
  toplevel .getTrainNumber 

  # Window manager configurations
  wm positionfrom .getTrainNumber ""
  wm sizefrom .getTrainNumber ""
  wm maxsize .getTrainNumber 1009 738
  wm minsize .getTrainNumber 1 1
  wm protocol .getTrainNumber WM_DELETE_WINDOW {.getTrainNumber.buttons.button5 invoke}
  wm title .getTrainNumber {Get Train Number}
  wm transient .getTrainNumber .


  # build widget .getTrainNumber.banner
  frame .getTrainNumber.banner \
    -borderwidth {2}

  # build widget .getTrainNumber.banner.label27
  label .getTrainNumber.banner.label27 \
    -image {banner}

  # build widget .getTrainNumber.banner.label28
  label .getTrainNumber.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Train Number to Add note to}

  # build widget .getTrainNumber.info
  frame .getTrainNumber.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .getTrainNumber.info.label3
  label .getTrainNumber.info.label3 \
    -text {Train:}

  # build widget .getTrainNumber.info.number
  eval [concat tk_optionMenu .getTrainNumber.info.number AddNoteStatus(Train) $trList]

  # build widget .getTrainNumber.buttons
  frame .getTrainNumber.buttons \
    -borderwidth {2}

  # build widget .getTrainNumber.buttons.button5
  button .getTrainNumber.buttons.button5 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global AddNoteStatus; set AddNoteStatus(Button) 0}

  # build widget .getTrainNumber.buttons.button6
  button .getTrainNumber.buttons.button6 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {global AddNoteStatus; set AddNoteStatus(Button) 1}

  # pack master .getTrainNumber.banner
  pack configure .getTrainNumber.banner.label27 \
    -side left
  pack configure .getTrainNumber.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrainNumber.info
  pack configure .getTrainNumber.info.label3 \
    -side left
  pack configure .getTrainNumber.info.number \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrainNumber.buttons
  pack configure .getTrainNumber.buttons.button5 \
    -side left
  pack configure .getTrainNumber.buttons.button6 \
    -side right

  # pack master .getTrainNumber
  pack configure .getTrainNumber.banner \
    -fill x
  pack configure .getTrainNumber.info \
    -expand 1 \
    -fill both
  pack configure .getTrainNumber.buttons \
    -fill x
# end of widget tree

  set w .getTrainNumber
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set AddNoteStatus(Button) -1
  tkwait variable AddNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .getTrainNumber}

  if {$AddNoteStatus(Button) == 0} {
    return
  }

  set stList {}
  set TrainStruct $Trains($AddNoteStatus(Train))

  foreach s [lrange $TrainStruct 1 end] {
    lappend stList [lindex $s 1]
  }

# .addNoteToTrain
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .addNoteToTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .addNoteToTrain"
  } {
    catch "destroy .addNoteToTrain"
  }
  toplevel .addNoteToTrain 

  # Window manager configurations
  wm positionfrom .addNoteToTrain ""
  wm sizefrom .addNoteToTrain ""
  wm maxsize .addNoteToTrain 1009 738
  wm minsize .addNoteToTrain 1 1
  wm protocol .addNoteToTrain WM_DELETE_WINDOW {.addNoteToTrain.buttons.button7 invoke}
  wm title .addNoteToTrain {Add Note to Train}
  wm transient .addNoteToTrain .


  # build widget .addNoteToTrain.banner
  frame .addNoteToTrain.banner \
    -borderwidth {2}

  # build widget .addNoteToTrain.banner.label27
  label .addNoteToTrain.banner.label27 \
    -image {banner}

  # build widget .addNoteToTrain.banner.label28
  label .addNoteToTrain.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Add Note to Train At Station}

  # build widget .addNoteToTrain.info
  frame .addNoteToTrain.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .addNoteToTrain.info.label3
  label .addNoteToTrain.info.label3 \
    -text {Note: }

  # build widget .addNoteToTrain.info.note
  eval [concat tk_optionMenu .addNoteToTrain.info.note AddNoteStatus(Note) $ntList]

  # build widget .addNoteToTrain.info.label5
  label .addNoteToTrain.info.label5 \
    -text {Station:}

  # build widget .addNoteToTrain.info.station
  eval [concat tk_optionMenu .addNoteToTrain.info.station AddNoteStatus(Station) $stList]

  # build widget .addNoteToTrain.buttons
  frame .addNoteToTrain.buttons \
    -borderwidth {2}

  # build widget .addNoteToTrain.buttons.button7
  button .addNoteToTrain.buttons.button7 \
    -command {global AddNoteStatus;set AddNoteStatus(Button) 0} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # build widget .addNoteToTrain.buttons.button8
  button .addNoteToTrain.buttons.button8 \
    -command {global AddNoteStatus Trains;set AddNoteStatus(Button) 1} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .addNoteToTrain.banner
  pack configure .addNoteToTrain.banner.label27 \
    -side left
  pack configure .addNoteToTrain.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .addNoteToTrain.info
  pack configure .addNoteToTrain.info.label3 \
    -side left
  pack configure .addNoteToTrain.info.note \
    -expand 1 \
    -fill x \
    -side left
  pack configure .addNoteToTrain.info.label5 \
    -side left
  pack configure .addNoteToTrain.info.station \
    -expand 1 \
    -fill x \
    -side right

  # pack master .addNoteToTrain.buttons
  pack configure .addNoteToTrain.buttons.button7 \
    -side left
  pack configure .addNoteToTrain.buttons.button8 \
    -side right

  # pack master .addNoteToTrain
  pack configure .addNoteToTrain.banner \
    -fill x
  pack configure .addNoteToTrain.info \
    -expand 1 \
    -fill both
  pack configure .addNoteToTrain.buttons \
    -fill x
# end of widget tree

  set w .addNoteToTrain
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set AddNoteStatus(Button) -1
  tkwait variable AddNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .addNoteToTrain}

  if {$AddNoteStatus(Button) == 0} {return}
  set station $AddNoteStatus(Station)
  set stlen [llength $stList]
  for {set ist 1} {$ist < $stlen} {incr ist} {
    if {[string compare "[lindex [lindex $TrainStruct $ist] 1]" "$station"] == 0} {break}
  }
  if {$ist >= $stlen} {return}
  set stElt [lindex $TrainStruct $ist]
  set stNotes [lindex $stElt 4]
  if {[lsearch -exact $stNotes $AddNoteStatus(Note)] < 0} {
    lappend stNotes $AddNoteStatus(Note)
    set stElt [lreplace $stElt 4 4 $stNotes]
    set Trains($AddNoteStatus(Train)) [lreplace $TrainStruct $ist $ist $stElt]
  }
}

proc RemoveNoteFromTrain {} {
# Procedure to remove a note from a train.  Bound to the Remove Note From Train menu item
# on the Notes menu.
# [index] RemoveNoteFromTrain!procedure

  global Notes Trains RemoveNoteStatus

  catch {unset RemoveNoteStatus}
  set ntList [lsort -integer [array names Notes]]
  if {[llength $ntList] == 0} {
    tk_messageBox -type ok -icon info -message {No Notes!}
    return
  }
  set trList [lsort -command TrainComp [array names Trains]]
  if {[llength $trList] == 0} {
    tk_messageBox -type ok -icon info -message "No trains!"
    return
  }

# .removeNoteFromTrain
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .removeNoteFromTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .removeNoteFromTrain"
  } {
    catch "destroy .removeNoteFromTrain"
  }
  toplevel .removeNoteFromTrain 

  # Window manager configurations
  wm positionfrom .removeNoteFromTrain ""
  wm sizefrom .removeNoteFromTrain ""
  wm maxsize .removeNoteFromTrain 1009 738
  wm minsize .removeNoteFromTrain 1 1
  wm protocol .removeNoteFromTrain WM_DELETE_WINDOW {.removeNoteFromTrain.buttons.button7 invoke}
  wm title .removeNoteFromTrain {Remove Note from Train}
  wm transient .removeNoteFromTrain .


  # build widget .removeNoteFromTrain.banner
  frame .removeNoteFromTrain.banner \
    -borderwidth {2}

  # build widget .removeNoteFromTrain.banner.label27
  label .removeNoteFromTrain.banner.label27 \
    -image {banner}

  # build widget .removeNoteFromTrain.banner.label28
  label .removeNoteFromTrain.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Remove Note from Train}

  # build widget .removeNoteFromTrain.info
  frame .removeNoteFromTrain.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .removeNoteFromTrain.info.label3
  label .removeNoteFromTrain.info.label3 \
    -text {Note: }

  # build widget .removeNoteFromTrain.info.note
  eval [concat tk_optionMenu .removeNoteFromTrain.info.note RemoveNoteStatus(Note) $ntList]

  # build widget .removeNoteFromTrain.info.label5
  label .removeNoteFromTrain.info.label5 \
    -text {Train:}

  # build widget .removeNoteFromTrain.info.train
  eval [concat tk_optionMenu .removeNoteFromTrain.info.train RemoveNoteStatus(Train) $trList]

  # build widget .removeNoteFromTrain.buttons
  frame .removeNoteFromTrain.buttons \
    -borderwidth {2}

  # build widget .removeNoteFromTrain.buttons.button7
  button .removeNoteFromTrain.buttons.button7 \
    -command {global RemoveNoteStatus;set RemoveNoteStatus(Button) 0} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # build widget .removeNoteFromTrain.buttons.button8
  button .removeNoteFromTrain.buttons.button8 \
    -command {global RemoveNoteStatus Trains;set RemoveNoteStatus(Button) 1} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .removeNoteFromTrain.banner
  pack configure .removeNoteFromTrain.banner.label27 \
    -side left
  pack configure .removeNoteFromTrain.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .removeNoteFromTrain.info
  pack configure .removeNoteFromTrain.info.label3 \
    -side left
  pack configure .removeNoteFromTrain.info.note \
    -expand 1 \
    -fill x \
    -side left
  pack configure .removeNoteFromTrain.info.label5 \
    -side left
  pack configure .removeNoteFromTrain.info.train \
    -expand 1 \
    -fill x \
    -side right

  # pack master .removeNoteFromTrain.buttons
  pack configure .removeNoteFromTrain.buttons.button7 \
    -side left
  pack configure .removeNoteFromTrain.buttons.button8 \
    -side right

  # pack master .removeNoteFromTrain
  pack configure .removeNoteFromTrain.banner \
    -fill x
  pack configure .removeNoteFromTrain.info \
    -expand 1 \
    -fill both
  pack configure .removeNoteFromTrain.buttons \
    -fill x
# end of widget tree

  set w .removeNoteFromTrain
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set RemoveNoteStatus(Button) -1
  tkwait variable RemoveNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .removeNoteFromTrain}

  if {$RemoveNoteStatus(Button) == 0} {return}
  set TrainStruct $Trains($RemoveNoteStatus(Train))
  set trHead [lindex $TrainStruct 0]
  set trNotes [lindex $trHead 3]
  set trIndex [lsearch -exact $trNotes $RemoveNoteStatus(Note)]
  if {$trIndex >= 0} {
    set trNotes [lreplace $trNotes $trIndex $trIndex]
    set trHead [lreplace $trHead 3 3 $trNotes]
    set Trains($RemoveNoteStatus(Train)) [lreplace $TrainStruct 0 0 $trHead]
  }
}

proc RemoveNoteFromTrainAtStation {} {
# Procedure to remove a note from a train at a station.  Bound to the Remove Note From 
# Train at Station menu item on the Notes menu.
# [index] RemoveNoteFromTrainAtStation!procedure

  global Notes Trains RemoveNoteStatus

  catch {unset RemoveNoteStatus}
  set ntList [lsort -integer [array names Notes]]
  if {[llength $ntList] == 0} {
    tk_messageBox -type ok -icon info -message {No Notes!}
    return
  }
  set trList [lsort -command TrainComp [array names Trains]]
  if {[llength $trList] == 0} {
    tk_messageBox -type ok -icon info -message "No trains!"
    return
  }

# .getTrainNumber
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .getTrainNumber
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getTrainNumber"
  } {
    catch "destroy .getTrainNumber"
  }
  toplevel .getTrainNumber 

  # Window manager configurations
  wm positionfrom .getTrainNumber ""
  wm sizefrom .getTrainNumber ""
  wm maxsize .getTrainNumber 1009 738
  wm minsize .getTrainNumber 1 1
  wm protocol .getTrainNumber WM_DELETE_WINDOW {.getTrainNumber.buttons.button5 invoke}
  wm title .getTrainNumber {Get Train Number}
  wm transient .getTrainNumber .


  # build widget .getTrainNumber.banner
  frame .getTrainNumber.banner \
    -borderwidth {2}

  # build widget .getTrainNumber.banner.label27
  label .getTrainNumber.banner.label27 \
    -image {banner}

  # build widget .getTrainNumber.banner.label28
  label .getTrainNumber.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Train Number to remove note from}

  # build widget .getTrainNumber.info
  frame .getTrainNumber.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .getTrainNumber.info.label3
  label .getTrainNumber.info.label3 \
    -text {Train:}

  # build widget .getTrainNumber.info.number
  eval [concat tk_optionMenu .getTrainNumber.info.number RemoveNoteStatus(Train) $trList]

  # build widget .getTrainNumber.buttons
  frame .getTrainNumber.buttons \
    -borderwidth {2}

  # build widget .getTrainNumber.buttons.button5
  button .getTrainNumber.buttons.button5 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global RemoveNoteStatus; set RemoveNoteStatus(Button) 0}

  # build widget .getTrainNumber.buttons.button6
  button .getTrainNumber.buttons.button6 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {global RemoveNoteStatus; set RemoveNoteStatus(Button) 1}

  # pack master .getTrainNumber.banner
  pack configure .getTrainNumber.banner.label27 \
    -side left
  pack configure .getTrainNumber.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrainNumber.info
  pack configure .getTrainNumber.info.label3 \
    -side left
  pack configure .getTrainNumber.info.number \
    -expand 1 \
    -fill x \
    -side right

  # pack master .getTrainNumber.buttons
  pack configure .getTrainNumber.buttons.button5 \
    -side left
  pack configure .getTrainNumber.buttons.button6 \
    -side right

  # pack master .getTrainNumber
  pack configure .getTrainNumber.banner \
    -fill x
  pack configure .getTrainNumber.info \
    -expand 1 \
    -fill both
  pack configure .getTrainNumber.buttons \
    -fill x
# end of widget tree

  set w .getTrainNumber
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set RemoveNoteStatus(Button) -1
  tkwait variable RemoveNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .getTrainNumber}

  if {$RemoveNoteStatus(Button) == 0} {
    return
  }

  set stList {}
  set TrainStruct $Trains($RemoveNoteStatus(Train))

  foreach s [lrange $TrainStruct 1 end] {
    lappend stList [lindex $s 1]
  }

# .remoteNoteToTrain
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .remoteNoteToTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .remoteNoteToTrain"
  } {
    catch "destroy .remoteNoteToTrain"
  }
  toplevel .remoteNoteToTrain 

  # Window manager configurations
  wm positionfrom .remoteNoteToTrain ""
  wm sizefrom .remoteNoteToTrain ""
  wm maxsize .remoteNoteToTrain 1009 738
  wm minsize .remoteNoteToTrain 1 1
  wm protocol .remoteNoteToTrain WM_DELETE_WINDOW {.remoteNoteToTrain.buttons.button7 invoke}
  wm title .remoteNoteToTrain {Remove Note to Train at Station}
  wm transient .remoteNoteToTrain .


  # build widget .remoteNoteToTrain.banner
  frame .remoteNoteToTrain.banner \
    -borderwidth {2}

  # build widget .remoteNoteToTrain.banner.label27
  label .remoteNoteToTrain.banner.label27 \
    -image {banner}

  # build widget .remoteNoteToTrain.banner.label28
  label .remoteNoteToTrain.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Remove Note from Train at Station}

  # build widget .remoteNoteToTrain.info
  frame .remoteNoteToTrain.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .remoteNoteToTrain.info.label3
  label .remoteNoteToTrain.info.label3 \
    -text {Note: }

  # build widget .remoteNoteToTrain.info.note
  eval [concat tk_optionMenu .remoteNoteToTrain.info.note RemoveNoteStatus(Note) $ntList]

  # build widget .remoteNoteToTrain.info.label5
  label .remoteNoteToTrain.info.label5 \
    -text {Station:}

  # build widget .remoteNoteToTrain.info.station
  eval [concat tk_optionMenu .remoteNoteToTrain.info.station RemoveNoteStatus(Station) $stList]

  # build widget .remoteNoteToTrain.buttons
  frame .remoteNoteToTrain.buttons \
    -borderwidth {2}

  # build widget .remoteNoteToTrain.buttons.button7
  button .remoteNoteToTrain.buttons.button7 \
    -command {global RemoveNoteStatus;set RemoveNoteStatus(Button) 0} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # build widget .remoteNoteToTrain.buttons.button8
  button .remoteNoteToTrain.buttons.button8 \
    -command {global RemoveNoteStatus Trains;set RemoveNoteStatus(Button) 1} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .remoteNoteToTrain.banner
  pack configure .remoteNoteToTrain.banner.label27 \
    -side left
  pack configure .remoteNoteToTrain.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .remoteNoteToTrain.info
  pack configure .remoteNoteToTrain.info.label3 \
    -side left
  pack configure .remoteNoteToTrain.info.note \
    -expand 1 \
    -fill x \
    -side left
  pack configure .remoteNoteToTrain.info.label5 \
    -side left
  pack configure .remoteNoteToTrain.info.station \
    -expand 1 \
    -fill x \
    -side right

  # pack master .remoteNoteToTrain.buttons
  pack configure .remoteNoteToTrain.buttons.button7 \
    -side left
  pack configure .remoteNoteToTrain.buttons.button8 \
    -side right

  # pack master .remoteNoteToTrain
  pack configure .remoteNoteToTrain.banner \
    -fill x
  pack configure .remoteNoteToTrain.info \
    -expand 1 \
    -fill both
  pack configure .remoteNoteToTrain.buttons \
    -fill x
# end of widget tree

  set w .remoteNoteToTrain
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set RemoveNoteStatus(Button) -1
  tkwait variable RemoveNoteStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .remoteNoteToTrain}

  if {$RemoveNoteStatus(Button) == 0} {return}
  set station $RemoveNoteStatus(Station)
  set stlen [llength $stList]
  for {set ist 1} {$ist < $stlen} {incr ist} {
    if {[string compare "[lindex [lindex $TrainStruct $ist] 1]" "$station"] == 0} {break}
  }
  if {$ist >= $stlen} {return}
  set stElt [lindex $TrainStruct $ist]
  set stNotes [lindex $stElt 4]
  set stIndex [lsearch -exact $stNotes $RemoveNoteStatus(Note)]
  if {$stIndex >= 0} {
    set stNotes [lreplace $stNotes $stIndex $stIndex]
    set stElt [lreplace $stElt 4 4 $stNotes]
    set Trains($RemoveNoteStatus(Train)) [lreplace $TrainStruct $ist $ist $stElt]
  }
}

proc DeleteATrain {} {
# Procedure to delete a train.  Not presently implemented.
# [index] DeleteATrain!procedure

  global Trains

  tk_messageBox -type ok -icon warning -message {Not implemented yet!}
}

proc EditATrain {} {
# Procedure to edit a train.  Not presently implemented.
# [index] EditATrain!procedure

  global Trains

  tk_messageBox -type ok -icon warning -message {Not implemented yet!}
}

proc HelpWarranty {} {
# Procedure to display Warranty information.
# [index] HelpWarranty!procedure

# .helpWarranty
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .helpWarranty
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .helpWarranty"
  } {
    catch "destroy .helpWarranty"
  }
  toplevel .helpWarranty 

  # Window manager configurations
  wm positionfrom .helpWarranty ""
  wm sizefrom .helpWarranty ""
  wm maxsize .helpWarranty 1000 768
  wm minsize .helpWarranty 10 10
  wm protocol .helpWarranty WM_DELETE_WINDOW {.helpWarranty.button15 invoke}
  wm title .helpWarranty {View Warranty}
  wm transient .helpWarranty .


  # build widget .helpWarranty.banner
  frame .helpWarranty.banner \
    -borderwidth {2}

  # build widget .helpWarranty.banner.label27
  label .helpWarranty.banner.label27 \
    -image {banner}

  # build widget .helpWarranty.banner.label28
  label .helpWarranty.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Warranty}

  # build widget .helpWarranty.frame
  frame .helpWarranty.frame \
    -relief {raised}

  # build widget .helpWarranty.frame.scrollbar1
  scrollbar .helpWarranty.frame.scrollbar1 \
    -command {.helpWarranty.frame.text2 yview}

  # build widget .helpWarranty.frame.text2
  text .helpWarranty.frame.text2 \
    -wrap {word} \
    -yscrollcommand {.helpWarranty.frame.scrollbar1 set}
  # bindings
  bind .helpWarranty.frame.text2 <Key> {break}

  # build widget .helpWarranty.button15
  button .helpWarranty.button15 \
    -command {catch {destroy .helpWarranty}} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .helpWarranty.banner
  pack configure .helpWarranty.banner.label27 \
    -side left
  pack configure .helpWarranty.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .helpWarranty.frame
  pack configure .helpWarranty.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .helpWarranty.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .helpWarranty
  pack configure .helpWarranty.banner \
    -fill x
  pack configure .helpWarranty.frame \
    -expand 1 \
    -fill both
  pack configure .helpWarranty.button15 \
    -expand 1 \
    -fill x

  .helpWarranty.frame.text2 insert end {			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.
}

# end of widget tree

  set w .helpWarranty
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

}

proc HelpCopying {} {
# Procedure to display Copying information.
# [index] HelpCopying!procedure

# .helpCopying
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .helpCopying
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .helpCopying"
  } {
    catch "destroy .helpCopying"
  }
  toplevel .helpCopying 

  # Window manager configurations
  wm positionfrom .helpCopying ""
  wm sizefrom .helpCopying ""
  wm maxsize .helpCopying 1000 768
  wm minsize .helpCopying 10 10
  wm protocol .helpCopying WM_DELETE_WINDOW {.helpCopying.button15 invoke}
  wm title .helpCopying {View Copying}
  wm transient .helpCopying .


  # build widget .helpCopying.banner
  frame .helpCopying.banner \
    -borderwidth {2}

  # build widget .helpCopying.banner.label27
  label .helpCopying.banner.label27 \
    -image {banner}

  # build widget .helpCopying.banner.label28
  label .helpCopying.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Copying}

  # build widget .helpCopying.frame
  frame .helpCopying.frame \
    -relief {raised}

  # build widget .helpCopying.frame.scrollbar1
  scrollbar .helpCopying.frame.scrollbar1 \
    -command {.helpCopying.frame.text2 yview}

  # build widget .helpCopying.frame.text2
  text .helpCopying.frame.text2 \
    -wrap {word} \
    -yscrollcommand {.helpCopying.frame.scrollbar1 set}
  # bindings
  bind .helpCopying.frame.text2 <Key> {break}

  # build widget .helpCopying.button15
  button .helpCopying.button15 \
    -command {catch {destroy .helpCopying}} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .helpCopying.banner
  pack configure .helpCopying.banner.label27 \
    -side left
  pack configure .helpCopying.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .helpCopying.frame
  pack configure .helpCopying.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .helpCopying.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .helpCopying
  pack configure .helpCopying.banner \
    -fill x
  pack configure .helpCopying.frame \
    -expand 1 \
    -fill both
  pack configure .helpCopying.button15 \
    -expand 1 \
    -fill x

  .helpCopying.frame.text2 insert end {		    GNU GENERAL PUBLIC LICENSE
		       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.
                          675 Mass Ave, Cambridge, MA 02139, USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

			    Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.




		    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)




These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.




  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.




  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

		     END OF TERMS AND CONDITIONS




	Appendix: How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
convey the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    [<one line to give the program's name and a brief idea of what it does.>]
    Copyright (C) 19yy  [<name of author>]

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this
when it starts in an interactive mode:

    Gnomovision version 69, Copyright (C) 19yy name of author
    Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, the commands you use may
be called something other than `show w' and `show c'; they could even be
mouse-clicks or menu items--whatever suits your program.

You should also get your employer (if you work as a programmer) or your
school, if any, to sign a "copyright disclaimer" for the program, if
necessary.  Here is a sample; alter the names:

  Yoyodyne, Inc., hereby disclaims all copyright interest in the program
  `Gnomovision' (which makes passes at compilers) written by James Hacker.

  [<signature of Ty Coon>], 1 April 1989
  Ty Coon, President of Vice

This General Public License does not permit incorporating your program into
proprietary programs.  If your program is a subroutine library, you may
consider it more useful to permit linking proprietary applications with the
library.  If this is what you want to do, use the GNU Library General
Public License instead of this License.
}

# end of widget tree

  set w .helpCopying
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

}

# Main program.

# Construct the main window (not displayed yet).

MainWindow

# Initialize everything.  Use command line arguments if available, otherwise
# pop up dialog boxes to acquire base information.


if {$HasChartFileP > 0} {
  if {[LoadCompleteChart "$ChartFile"] == 0} {
    exit 90
  }
} elseif {$argc == $argcTest} {

  if {!$IsSlave} {
    catch {
      after cancel $splashAfterId
      destroy .mrrSplash
    }
  }

  set ans [tk_messageBox -icon question -default no -type yesnocancel \
		-message {Load existing Time Table Chart from file?}]
  switch -exact -- "$ans" {
    yes {
	  LoadCompleteChart
	}
    no {
	GetTimeInfo
	AcquireCabInfo
	MakeCabs
	AcquireStations
	MakeChart
	AcquireTracks
	MakeTracks
       }
    cancel -
    default {exit}
  }
} else {
  if {$HasSetTimeInfoP < 2} {
    GetTimeInfo
  }
  if {$HasCabFileP > 0} {
    AcquireCabInfo "$CabFile"
  } elseif {$HasCabFileP == 0} {
    AcquireCabInfo
  }
  MakeCabs
  if {$HasStationsFileP} {
    AcquireStations "$StationsFile"
  } else {
    AcquireStations
  }
  MakeChart
  if {$HasTracksFileP > 0} {
    AcquireTracks "$TracksFile"
  } elseif {$HasTracksFileP == 0} {
    AcquireTracks
  }
  MakeTracks
}

# Display main window.

if {!$IsSlave} {
  wm deiconify .
  catch {raise .mrrSplash .}
} else {
  fileevent stdin readable {
    if {[gets stdin line] < 0} {CarefulExit}
#    puts stderr "*** main: line = '$line'"
    switch -- "$line" {
      {201 Exit} {CarefulExit}
      default {}
    }
  }
}
