#!/usr/bin/wish -f
# Program: FreightCarForwarder
# Tcl version: 7.4 (Tcl/Tk/XF)
# Tk version: 4.0
# XF version: 2.3
#
#* 
#* ------------------------------------------------------------------
#* FreightCarForwarder.tcl - Freight Car Forwarder Version
#* Created by Robert Heller on Mon Aug  5 18:14:52 1996
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2004/05/30 19:00:25  heller
#* Modification History: Added in Tcl port of Freight Car Forwarder.
#* Modification History:
#* Modification History: Revision 1.3  1996/08/14 23:03:29  heller
#* Modification History: Small typo
#* Modification History:
#* Modification History: Revision 1.2  1996/08/13 02:49:24  heller
#* Modification History: Fixed a few logic bugs in the train operations code.
#* Modification History: These bugs were discovered after (finally!) running the BASIC version
#* Modification History: and getting *very* different results.
#* Modification History:
#* Modification History: Revision 1.1  1996/08/06 19:04:35  heller
#* Modification History: Initial revision
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995  Robert Heller D/B/A Deepwoods Software
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
#
# $Id$
#
# module inclusion
global env
global xfLoadPath
global xfLoadInfo
set xfLoadInfo 0
if {[info exists env(XF_LOAD_PATH)]} {
  if {[string first $env(XF_LOAD_PATH) /usr/local/lib/] == -1} {
    set xfLoadPath $env(XF_LOAD_PATH):/usr/local/lib/
  } {
    set xfLoadPath /usr/local/lib/
  }
} {
  set xfLoadPath /usr/local/lib/
}

global argc
global argv
global tk_version
set tmpArgv ""
for {set counter 0} {$counter < $argc} {incr counter 1} {
  case [string tolower [lindex $argv $counter]] in {
    {-xfloadpath} {
      incr counter 1
      set xfLoadPath "[lindex $argv $counter]:$xfLoadPath"
    }
    {-xfstartup} {
      incr counter 1
      source [lindex $argv $counter]
    }
    {-xfbindfile} {
      incr counter 1
      set env(XF_BIND_FILE) "[lindex $argv $counter]"
    }
    {-xfcolorfile} {
      incr counter 1
      set env(XF_COLOR_FILE) "[lindex $argv $counter]"
    }
    {-xfcursorfile} {
      incr counter 1
      set env(XF_CURSOR_FILE) "[lindex $argv $counter]"
    }
    {-xffontfile} {
      incr counter 1
      set env(XF_FONT_FILE) "[lindex $argv $counter]"
    }
    {-xfmodelmono} {
      if {$tk_version >= 3.0} {
        tk colormodel . monochrome
      }
    }
    {-xfmodelcolor} {
      if {$tk_version >= 3.0} {
        tk colormodel . color
      }
    }
    {-xfloading} {
      set xfLoadInfo 1
    }
    {-xfnoloading} {
      set xfLoadInfo 0
    }
    {default} {
      lappend tmpArgv [lindex $argv $counter]
    }
  }
}
set argv $tmpArgv
set argc [llength $tmpArgv]
unset counter
unset tmpArgv


# procedure to show window .
proc ShowWindow. {args} {# xf ignore me 7

  # Window manager configurations
  global tk_version
  wm positionfrom . user
  wm sizefrom . ""
  wm maxsize . 1009 738
  wm minsize . 1 1
  if {$tk_version >= 3.0} {
    wm protocol . WM_DELETE_WINDOW {CarefulExit}
  }
  wm title . {Freight Car Forwarder}


  # build widget .frame0
  frame .frame0 \
    -borderwidth {2} \
    -relief {raised}

  # build widget .frame0.menubutton1
  menubutton .frame0.menubutton1 \
    -menu {.frame0.menubutton1.m} \
    -padx {4} \
    -pady {3} \
    -text {File} \
    -underline {0}

  # build widget .frame0.menubutton1.m
  menu .frame0.menubutton1.m \
    -tearoff {0}
  .frame0.menubutton1.m add command \
    -command {OpenPrinter} \
    -label {Open Printer}
  .frame0.menubutton1.m add command \
    -command {ClosePrinter} \
    -label {Close Printer}
  .frame0.menubutton1.m add command \
    -command {CarefulExit} \
    -label {Quit} \
    -underline {0}

  # build widget .frame0.menubutton2
  menubutton .frame0.menubutton2 \
    -menu {.frame0.menubutton2.m} \
    -padx {4} \
    -pady {3} \
    -text {Help} \
    -underline {0}

  # build widget .frame0.menubutton2.m
  menu .frame0.menubutton2.m \
    -tearoff {0}
  .frame0.menubutton2.m add command \
    -command {
      global NewCopyright
      global OldCopyright
      TextBox "$NewCopyright\nTranslated from cle.bas:\n$OldCopyright"  {} {600x350} {About Freight Car Forwarder}
    } \
    -label {About Freight Car Forwarder} \
    -underline {0}
  .frame0.menubutton2.m add command \
    -command {
      global History
      TextBox "$History" {} {600x450} {History of Freight Car Forwarder}
    } \
    -label {History}
  .frame0.menubutton2.m add command \
    -command {
      global COPYING
      TextBox "$COPYING" {} {600x450} {License}
    } \
    -label {COPYING}
  .frame0.menubutton2.m add command \
    -command {
      global WARRANTY
      TextBox "$WARRANTY" {} {600x450} {NO WARRANTY}
    } \
    -label {WARRANTY}

  # build widget .mainMenu
  frame .mainMenu \
    -borderwidth {2}

  # build widget .mainMenu.left
  frame .mainMenu.left \
    -borderwidth {2}

  # build widget .mainMenu.left.button1
  button .mainMenu.left.button1 \
    -anchor {w} \
    -command {ReLoadCarFile} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Load the disk car file} \
    -underline {0}

  # build widget .mainMenu.left.button2
  button .mainMenu.left.button2 \
    -anchor {w} \
    -command {SaveCars} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Save current cars to disk} \
    -underline {0}

  # build widget .mainMenu.left.button3
  button .mainMenu.left.button3 \
    -anchor {w} \
    -command {ManagePrintTrains} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Manage printing and trains} \
    -underline {0}

  # build widget .mainMenu.left.button4
  button .mainMenu.left.button4 \
    -anchor {w} \
    -command {ViewCarInfo} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {View car information} \
    -underline {0}

  # build widget .mainMenu.left.button5
  button .mainMenu.left.button5 \
    -anchor {w} \
    -command {EditCarInfo;RestartLoop} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Edit car information} \
    -underline {0}

  # build widget .mainMenu.left.button6
  button .mainMenu.left.button6 \
    -anchor {w} \
    -command {AddNewCar;RestartLoop} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Add a New car} \
    -underline {6}

  # build widget .mainMenu.left.button7
  button .mainMenu.left.button7 \
    -anchor {w} \
    -command {DeleteExistingCar;RestartLoop} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Delete an existing car} \
    -underline {0}

  # build widget .mainMenu.right
  frame .mainMenu.right \
    -borderwidth {2}

  # build widget .mainMenu.right.button8
  button .mainMenu.right.button8 \
    -anchor {w} \
    -command {ShowUnassignedCars} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Show Unassigned cars} \
    -underline {5}


  # build widget .mainMenu.right.button9
  button .mainMenu.right.button9 \
    -anchor {w} \
    -command {CarAssignmentProcedure;RestartLoop} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Run the car Assignment procedure} \
    -underline {12}

  # build widget .mainMenu.right.button10
  button .mainMenu.right.button10 \
    -anchor {w} \
    -command {RunAllTrains;RestartLoop} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Run all Trains in Operating session} \
    -underline {18}

  # build widget .mainMenu.right.button11
  button .mainMenu.right.button11 \
    -anchor {w} \
    -command {RunOneTrain;RestartLoop} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Run Trains one at a time} \
    -underline {4}

  # build widget .mainMenu.right.button12
  button .mainMenu.right.button12 \
    -anchor {w} \
    -command {ShowCarsNotMoved;RestartLoop} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Show Cars not moved} \
    -underline {5}

  # build widget .mainMenu.right.menubutton13
  menubutton .mainMenu.right.menubutton13 \
    -menu {.mainMenu.right.menubutton13.m} \
    -anchor {w} \
    -relief {raised} \
    -padx {9} \
    -pady {4} \
    -takefocus {0} \
    -highlightthickness 2 \
    -text {Popup Reports Menu} \
    -underline {6}

  # build widget .mainMenu.right.menubutton13.m
  menu .mainMenu.right.menubutton13.m  -tearoff {0}
  .mainMenu.right.menubutton13.m add command \
     -label {All Industries} \
     -underline {4} \
     -command {MenuReportIndustries}
  .mainMenu.right.menubutton13.m add command \
     -label {All Trains} \
     -underline {4} \
     -command {MenuReportTrains}
  .mainMenu.right.menubutton13.m add command \
     -label {All Cars} \
     -underline {4} \
     -command {MenuReportCars}
  .mainMenu.right.menubutton13.m add command \
     -label {Cars that did not Moved} \
     -underline {18} \
     -command {MenuReportCarsNotMoved}
  .mainMenu.right.menubutton13.m add cascade \
     -label {Car type reports} \
     -underline {5} \
     -menu {.mainMenu.right.menubutton13.m.ctrMenu}
  menu .mainMenu.right.menubutton13.m.ctrMenu -tearoff {0}
  .mainMenu.right.menubutton13.m.ctrMenu add command \
     -label {Print all cars} \
     -underline {6} \
     -command {MenuReportCarTypes All}
  .mainMenu.right.menubutton13.m.ctrMenu add command \
     -label {Print a specific type} \
     -underline {17} \
     -command {MenuReportCarTypes Type}
  .mainMenu.right.menubutton13.m.ctrMenu add command \
     -label {Print only a summary} \
     -command {MenuReportCarTypes Summary}  
  .mainMenu.right.menubutton13.m add cascade \
     -label {Car location reports} \
     -underline {4} \
     -menu {.mainMenu.right.menubutton13.m.clMenu}
   menu .mainMenu.right.menubutton13.m.clMenu -tearoff {0}
   .mainMenu.right.menubutton13.m.clMenu add command \
     -label {Print by INDUSTRY} \
     -underline {9} \
     -command {MenuReportCarLocations INDUSTRY}
   .mainMenu.right.menubutton13.m.clMenu add command \
     -label {Print by STATION} \
     -underline {9} \
     -command {MenuReportCarLocations STATION}
   .mainMenu.right.menubutton13.m.clMenu add command \
     -label {Print by DIVISION} \
     -underline {9} \
     -command {MenuReportCarLocations DIVISION}
   .mainMenu.right.menubutton13.m.clMenu add command \
     -label {Print all locations} \
     -command {MenuReportCarLocations ALL}
  .mainMenu.right.menubutton13.m add cascade \
     -label {Car owner reports} \
     -underline {4} \
     -menu {.mainMenu.right.menubutton13.m.owners}
  menu .mainMenu.right.menubutton13.m.owners -tearoff 0
  .mainMenu.right.menubutton13.m add command \
     -label {Industry Analysis} \
     -underline {9} \
     -command {MenuReportAnalysis}

  # build widget .mainMenu.right.button14
  button .mainMenu.right.button14 \
    -anchor {w} \
    -command {ResetIndustryStats} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Reset Industry statistics} \
    -underline {6}

  # build widget .mainMenu.right.button15
  button .mainMenu.right.button15 \
    -anchor {w} \
    -command {CarefulExit} \
    -padx {9} \
    -pady {3} \
    -takefocus {0} \
    -text {Quit -- exit NOW} \
    -underline {0}

  # build widget .label1
  label .label1 \
    -anchor {w} \
    -highlightthickness {2} \
    -padx {9} \
    -pady {3} \
    -relief {raised} \
    -takefocus {1} \
    -text {Choose a letter above}
  # bindings
  bind .label1 <Button-1> {focus %W}
  bind .label1 a {CarAssignmentProcedure;RestartLoop}
  bind .label1 A {CarAssignmentProcedure;RestartLoop}
  bind .label1 c {ShowCarsNotMoved;RestartLoop}
  bind .label1 C {ShowCarsNotMoved;RestartLoop}
  bind .label1 d {DeleteExistingCar;RestartLoop}
  bind .label1 D {DeleteExistingCar;RestartLoop}
  bind .label1 e {EditCarInfo;RestartLoop}
  bind .label1 E {EditCarInfo;RestartLoop}
  bind .label1 i {ResetIndustryStats}
  bind .label1 I {ResetIndustryStats}
  bind .label1 l {ReLoadCarFile}
  bind .label1 L {ReLoadCarFile}
  bind .label1 m {ManagePrintTrains}
  bind .label1 M {ManagePrintTrains}
  bind .label1 n {AddNewCar;RestartLoop}
  bind .label1 N {AddNewCar;RestartLoop}
  bind .label1 o {RunAllTrains;RestartLoop}
  bind .label1 O {RunAllTrains;RestartLoop}
  bind .label1 q {CarefulExit}
  bind .label1 Q {CarefulExit}
  bind .label1 r {ReportsMenu}
  bind .label1 R {ReportsMenu}
  bind .label1 s {SaveCars}
  bind .label1 S {SaveCars}
  bind .label1 t {RunOneTrain;RestartLoop}
  bind .label1 T {RunOneTrain;RestartLoop}
  bind .label1 u {ShowUnassignedCars}
  bind .label1 U {ShowUnassignedCars}
  bind .label1 v {ViewCarInfo}
  bind .label1 V {ViewCarInfo}

  # build widget .logTotals
  frame .logTotals \
    -borderwidth {2}

  # build widget .logTotals.frame
  frame .logTotals.frame \
    -relief {raised}

  # build widget .logTotals.frame.scrollbar1
  scrollbar .logTotals.frame.scrollbar1 \
    -command {.logTotals.frame.text2 yview} \
    -relief {raised} \
    -takefocus {0}

  # build widget .logTotals.frame.text2
  text .logTotals.frame.text2 \
    -height {10} \
    -relief {raised} \
    -takefocus {0} \
    -wrap {word} \
    -yscrollcommand {.logTotals.frame.scrollbar1 set}
  # bindings
  bind .logTotals.frame.text2 <Button-1> {
    tkTextButton1-nofocus %W %x %y
    %W tag remove sel 0.0 end
    break
  }
  bind .logTotals.frame.text2 <Key-Tab> {
    focus [tk_focusNext %W]
    break
  }
  bind .logTotals.frame.text2 <Key> {NoFunction;break}
  bind .logTotals.frame.text2 <Shift-Key-Tab> {
    focus [tk_focusPrev %W]
    break
  }

  # build widget .logTotals.carTotals
  frame .logTotals.carTotals \
    -borderwidth {2}

  # build widget .logTotals.carTotals.frame1
  frame .logTotals.carTotals.frame1 \
    -borderwidth {2}

  # build widget .logTotals.carTotals.frame1.frame0
  frame .logTotals.carTotals.frame1.frame0 \
    -height {14}

  # build widget .logTotals.carTotals.frame1.label10
  label .logTotals.carTotals.frame1.label10 \
    -text {Moved Once :}

  # build widget .logTotals.carTotals.frame1.label11
  label .logTotals.carTotals.frame1.label11 \
    -text {Moved Twice :}

  # build widget .logTotals.carTotals.frame1.label12
  label .logTotals.carTotals.frame1.label12 \
    -text {Moved Three :}

  # build widget .logTotals.carTotals.frame1.label13
  label .logTotals.carTotals.frame1.label13 \
    -text {Moved Four or More :}

  # build widget .logTotals.carTotals.frame1.label14
  label .logTotals.carTotals.frame1.label14 \
    -text {Total Movements :}

  # build widget .logTotals.carTotals.frame1.label3
  label .logTotals.carTotals.frame1.label3 \
    -text {Total Cars :}

  # build widget .logTotals.carTotals.frame1.label4
  label .logTotals.carTotals.frame1.label4 \
    -text {At Destination :}

  # build widget .logTotals.carTotals.frame1.label5
  label .logTotals.carTotals.frame1.label5 \
    -text {Still in Transit :}

  # build widget .logTotals.carTotals.frame1.label6
  label .logTotals.carTotals.frame1.label6 \
    -text {In Service :}

  # build widget .logTotals.carTotals.frame1.label7
  label .logTotals.carTotals.frame1.label7 \
    -text {At Workbench :}

  # build widget .logTotals.carTotals.frame1.label8
  label .logTotals.carTotals.frame1.label8 \
    -text {Not Yet Moved :}

  # build widget .logTotals.carTotals.frame1.label9
  label .logTotals.carTotals.frame1.label9 \
    -text {Cars Moved :}

  # build widget .logTotals.carTotals.frame2
  frame .logTotals.carTotals.frame2 \
    -borderwidth {2}

  # build widget .logTotals.carTotals.frame2.frame0
  frame .logTotals.carTotals.frame2.frame0 \
    -height {14}

  # build widget .logTotals.carTotals.frame2.label15
  label .logTotals.carTotals.frame2.label15 \
    -text {0} \
    -textvariable {TotalCars}

  # build widget .logTotals.carTotals.frame2.label16
  label .logTotals.carTotals.frame2.label16 \
    -text {0} \
    -textvariable {CarsAtDest}

  # build widget .logTotals.carTotals.frame2.label17
  label .logTotals.carTotals.frame2.label17 \
    -text {0} \
    -textvariable {CarsInTransit}

  # build widget .logTotals.carTotals.frame2.label18
  label .logTotals.carTotals.frame2.label18 \
    -textvariable {CarsAtDest_CarsInTransit}

  # build widget .logTotals.carTotals.frame2.label19
  label .logTotals.carTotals.frame2.label19 \
    -text {0} \
    -textvariable {CarsAtWorkBench}

  # build widget .logTotals.carTotals.frame2.label20
  label .logTotals.carTotals.frame2.label20 \
    -text {0} \
    -textvariable {CarsNotMoved}

  # build widget .logTotals.carTotals.frame2.label21
  label .logTotals.carTotals.frame2.label21 \
    -text {0} \
    -textvariable {CarsMoved}

  # build widget .logTotals.carTotals.frame2.label22
  label .logTotals.carTotals.frame2.label22 \
    -text {0} \
    -textvariable {CarsMovedOnce}

  # build widget .logTotals.carTotals.frame2.label23
  label .logTotals.carTotals.frame2.label23 \
    -text {0} \
    -textvariable {CarsMovedTwice}

  # build widget .logTotals.carTotals.frame2.label24
  label .logTotals.carTotals.frame2.label24 \
    -text {0} \
    -textvariable {CarsMovedThree}

  # build widget .logTotals.carTotals.frame2.label25
  label .logTotals.carTotals.frame2.label25 \
    -text {0} \
    -textvariable {CarsMovedMore}

  # build widget .logTotals.carTotals.frame2.label26
  label .logTotals.carTotals.frame2.label26 \
    -text {0} \
    -textvariable {CarMovements}

  # pack master .frame0
  pack configure .frame0.menubutton1 \
    -side left
  pack configure .frame0.menubutton2 \
    -side right

  # pack master .mainMenu.left
  pack configure .mainMenu.left.button1 \
    -anchor w \
    -fill x
  pack configure .mainMenu.left.button2 \
    -anchor w \
    -fill x
  pack configure .mainMenu.left.button3 \
    -anchor w \
    -fill x
  pack configure .mainMenu.left.button4 \
    -anchor w \
    -fill x
  pack configure .mainMenu.left.button5 \
    -anchor w \
    -fill x
  pack configure .mainMenu.left.button6 \
    -anchor w \
    -fill x
  pack configure .mainMenu.left.button7 \
    -anchor w \
    -fill x

  # pack master .mainMenu.right
  pack configure .mainMenu.right.button8 \
    -anchor w \
    -fill x
  pack configure .mainMenu.right.button9 \
    -anchor w \
    -fill x
  pack configure .mainMenu.right.button10 \
    -anchor w \
    -fill x
  pack configure .mainMenu.right.button11 \
    -anchor w \
    -fill x
  pack configure .mainMenu.right.menubutton13 \
    -anchor w \
    -fill x
  pack configure .mainMenu.right.button14 \
    -anchor w \
    -fill x
  pack configure .mainMenu.right.button15 \
    -anchor w \
    -fill x

  # pack master .mainMenu
  pack configure .mainMenu.left \
    -side left \
    -fill both \
    -expand 1
  pack configure .mainMenu.right \
    -side right \
    -fill both \
    -expand 1

  # pack master .logTotals
  pack configure .logTotals.frame \
    -fill both \
    -side left
  pack configure .logTotals.carTotals \
    -expand 1 \
    -fill both \
    -side right

  # pack master .logTotals.frame
  pack configure .logTotals.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .logTotals.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .logTotals.carTotals
  pack configure .logTotals.carTotals.frame1 \
    -expand 1 \
    -fill both \
    -side left
  pack configure .logTotals.carTotals.frame2 \
    -expand 1 \
    -fill both \
    -side left

  # pack master .logTotals.carTotals.frame1
  pack configure .logTotals.carTotals.frame1.label3 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label4 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label5 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label6 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label7 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.frame0 \
    -expand 1 \
    -fill both
  pack configure .logTotals.carTotals.frame1.label8 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label9 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label10 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label11 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label12 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label13 \
    -anchor e
  pack configure .logTotals.carTotals.frame1.label14 \
    -anchor e

  # pack master .logTotals.carTotals.frame2
  pack configure .logTotals.carTotals.frame2.label15 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label16 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label17 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label18 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label19 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.frame0 \
    -expand 1 \
    -fill both
  pack configure .logTotals.carTotals.frame2.label20 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label21 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label22 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label23 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label24 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label25 \
    -anchor w
  pack configure .logTotals.carTotals.frame2.label26 \
    -anchor w

  # pack master .
  pack configure .frame0 \
    -fill x
  pack configure .mainMenu \
    -expand 1 \
    -fill x
  pack configure .label1 \
    -anchor w \
    -fill x
  pack configure .logTotals

  global tk_version
  if {$tk_version >= 3.0} {
    tk_menuBar .frame0 .frame0.menubutton1 .frame0.menubutton2
  } {
    tk_menus . .frame0.menubutton1 .frame0.menubutton2
  }

  .logTotals.frame.text2 insert end {


}



  if {"[info procs XFEdit]" != ""} {
    catch "XFMiscBindWidgetTree ."
    after 2 "catch {XFEditSetShowWindows}"
  }
}


# User defined procedures


# Procedure: AlertBox
proc AlertBox { {alertBoxMessage "Alert message"} {alertBoxCommand ""} {alertBoxGeometry "350x150"} {alertBoxTitle "Alert box"} args} {
# xf ignore me 5
##########
# Procedure: AlertBox
# Description: show alert box
# Arguments: {alertBoxMessage} - the text to display
#            {alertBoxCommand} - the command to call after ok
#            {alertBoxGeometry} - the geometry for the window
#            {alertBoxTitle} - the title for the window
#            {args} - labels of buttons
# Returns: The number of the selected button, ot nothing
# Sideeffects: none
# Notes: there exist also functions called:
#          AlertBoxFile - to open and read a file automatically
#          AlertBoxFd - to read from an already opened filedescriptor
##########
#
# global alertBox(activeBackground) - active background color
# global alertBox(activeForeground) - active foreground color
# global alertBox(after) - destroy alert box after n seconds
# global alertBox(anchor) - anchor for message box
# global alertBox(background) - background color
# global alertBox(font) - message font
# global alertBox(foreground) - foreground color
# global alertBox(justify) - justify for message box
# global alertBox(toplevelName) - the toplevel name

  global alertBox

  # show alert box
  if {[llength $args] > 0} {
    eval AlertBoxInternal "\{$alertBoxMessage\}" "\{$alertBoxCommand\}" "\{$alertBoxGeometry\}" "\{$alertBoxTitle\}" $args
  } {
    AlertBoxInternal $alertBoxMessage $alertBoxCommand $alertBoxGeometry $alertBoxTitle
  }

  if {[llength $args] > 0} {
    # wait for the box to be destroyed
    update idletask
    grab $alertBox(toplevelName)
    tkwait window $alertBox(toplevelName)

    return $alertBox(button)
  }
}


# Procedure: AlertBoxFd
proc AlertBoxFd { {alertBoxInFile ""} {alertBoxCommand ""} {alertBoxGeometry "350x150"} {alertBoxTitle "Alert box"} args} {
# xf ignore me 5
##########
# Procedure: AlertBoxFd
# Description: show alert box containing a filedescriptor
# Arguments: {alertBoxInFile} - a filedescriptor to read. The descriptor
#                               is closed after reading
#            {alertBoxCommand} - the command to call after ok
#            {alertBoxGeometry} - the geometry for the window
#            {alertBoxTitle} - the title for the window
#            {args} - labels of buttons
# Returns: The number of the selected button, ot nothing
# Sideeffects: none
# Notes: there exist also functions called:
#          AlertBox - to display a passed string
#          AlertBoxFile - to open and read a file automatically
##########
#
# global alertBox(activeBackground) - active background color
# global alertBox(activeForeground) - active foreground color
# global alertBox(after) - destroy alert box after n seconds
# global alertBox(anchor) - anchor for message box
# global alertBox(background) - background color
# global alertBox(font) - message font
# global alertBox(foreground) - foreground color
# global alertBox(justify) - justify for message box
# global alertBox(toplevelName) - the toplevel name

  global alertBox

  # check file existance
  if {"$alertBoxInFile" == ""} {
    puts stderr "No filedescriptor specified"
    return
  }

  set alertBoxMessage [read $alertBoxInFile]
  close $alertBoxInFile

  # show alert box
  if {[llength $args] > 0} {
    eval AlertBoxInternal "\{$alertBoxMessage\}" "\{$alertBoxCommand\}" "\{$alertBoxGeometry\}" "\{$alertBoxTitle\}" $args
  } {
    AlertBoxInternal $alertBoxMessage $alertBoxCommand $alertBoxGeometry $alertBoxTitle
  }

  if {[llength $args] > 0} {
    # wait for the box to be destroyed
    update idletask
    grab $alertBox(toplevelName)
    tkwait window $alertBox(toplevelName)

    return $alertBox(button)
  }
}


# Procedure: AlertBoxFile
proc AlertBoxFile { {alertBoxFile ""} {alertBoxCommand ""} {alertBoxGeometry "350x150"} {alertBoxTitle "Alert box"} args} {
# xf ignore me 5
##########
# Procedure: AlertBoxFile
# Description: show alert box containing a file
# Arguments: {alertBoxFile} - filename to read
#            {alertBoxCommand} - the command to call after ok
#            {alertBoxGeometry} - the geometry for the window
#            {alertBoxTitle} - the title for the window
#            {args} - labels of buttons
# Returns: The number of the selected button, ot nothing
# Sideeffects: none
# Notes: there exist also functions called:
#          AlertBox - to display a passed string
#          AlertBoxFd - to read from an already opened filedescriptor
##########
#
# global alertBox(activeBackground) - active background color
# global alertBox(activeForeground) - active foreground color
# global alertBox(after) - destroy alert box after n seconds
# global alertBox(anchor) - anchor for message box
# global alertBox(background) - background color
# global alertBox(font) - message font
# global alertBox(foreground) - foreground color
# global alertBox(justify) - justify for message box
# global alertBox(toplevelName) - the toplevel name

  global alertBox

  # check file existance
  if {"$alertBoxFile" == ""} {
    puts stderr "No filename specified"
    return
  }

  if {[catch [list open "$alertBoxFile" r] alertBoxInFile]} {
    puts stderr "$alertBoxInFile"
    return
  }

  set alertBoxMessage [read $alertBoxInFile]
  close $alertBoxInFile

  # show alert box
  if {[llength $args] > 0} {
    eval AlertBoxInternal "\{$alertBoxMessage\}" "\{$alertBoxCommand\}" "\{$alertBoxGeometry\}" "\{$alertBoxTitle\}" $args
  } {
    AlertBoxInternal $alertBoxMessage $alertBoxCommand $alertBoxGeometry $alertBoxTitle
  }

  if {[llength $args] > 0} {
    # wait for the box to be destroyed
    update idletask
    grab $alertBox(toplevelName)
    tkwait window $alertBox(toplevelName)

    return $alertBox(button)
  }
}


# Procedure: AlertBoxInternal
proc AlertBoxInternal { alertBoxMessage alertBoxCommand alertBoxGeometry alertBoxTitle args} {
# xf ignore me 6
  global alertBox

  set tmpButtonOpt ""
  set tmpFrameOpt ""
  set tmpMessageOpt ""
  if {"$alertBox(activeBackground)" != ""} {
    append tmpButtonOpt "-activebackground \"$alertBox(activeBackground)\" "
  }
  if {"$alertBox(activeForeground)" != ""} {
    append tmpButtonOpt "-activeforeground \"$alertBox(activeForeground)\" "
  }
  if {"$alertBox(background)" != ""} {
    append tmpButtonOpt "-background \"$alertBox(background)\" "
    append tmpFrameOpt "-background \"$alertBox(background)\" "
    append tmpMessageOpt "-background \"$alertBox(background)\" "
  }
  if {"$alertBox(font)" != ""} {
    append tmpButtonOpt "-font \"$alertBox(font)\" "
    append tmpMessageOpt "-font \"$alertBox(font)\" "
  }
  if {"$alertBox(foreground)" != ""} {
    append tmpButtonOpt "-foreground \"$alertBox(foreground)\" "
    append tmpMessageOpt "-foreground \"$alertBox(foreground)\" "
  }

  # start build of toplevel
  if {"[info commands XFDestroy]" != ""} {
    catch {XFDestroy $alertBox(toplevelName)}
  } {
    catch {destroy $alertBox(toplevelName)}
  }
  toplevel $alertBox(toplevelName)  -borderwidth 0
  catch "$alertBox(toplevelName) config $tmpFrameOpt"
  if {[catch "wm geometry $alertBox(toplevelName) $alertBoxGeometry"]} {
    wm geometry $alertBox(toplevelName) 350x150
  }
  wm title $alertBox(toplevelName) $alertBoxTitle
  wm maxsize $alertBox(toplevelName) 1000 1000
  wm minsize $alertBox(toplevelName) 100 100
  # end build of toplevel

  message $alertBox(toplevelName).message1  -anchor "$alertBox(anchor)"  -justify "$alertBox(justify)"  -relief raised  -text "$alertBoxMessage"
  catch "$alertBox(toplevelName).message1 config $tmpMessageOpt"

  set xfTmpWidth  [string range $alertBoxGeometry 0 [expr [string first x $alertBoxGeometry]-1]]
  if {"$xfTmpWidth" != ""} {
    # set message size
    catch "$alertBox(toplevelName).message1 configure  -width [expr $xfTmpWidth-10]"
  } {
    $alertBox(toplevelName).message1 configure  -aspect 1500
  }

  frame $alertBox(toplevelName).frame1  -borderwidth 0  -relief raised
  catch "$alertBox(toplevelName).frame1 config $tmpFrameOpt"

  set alertBoxCounter 0
  set buttonNum [llength $args]
  if {$buttonNum > 0} {
    while {$alertBoxCounter < $buttonNum} {
      button $alertBox(toplevelName).frame1.button$alertBoxCounter  -text "[lindex $args $alertBoxCounter]"  -command "
          global alertBox
          set alertBox(button) $alertBoxCounter
          if {\"\[info commands XFDestroy\]\" != \"\"} {
            catch {XFDestroy $alertBox(toplevelName)}
          } {
            catch {destroy $alertBox(toplevelName)}
          }"
      catch "$alertBox(toplevelName).frame1.button$alertBoxCounter config $tmpButtonOpt"

      pack append $alertBox(toplevelName).frame1  $alertBox(toplevelName).frame1.button$alertBoxCounter {left fillx expand}

      incr alertBoxCounter
    }
  } {
    button $alertBox(toplevelName).frame1.button0  -text "OK"  -command "
        global alertBox
        set alertBox(button) 0
        if {\"\[info commands XFDestroy\]\" != \"\"} {
          catch {XFDestroy $alertBox(toplevelName)}
        } {
          catch {destroy $alertBox(toplevelName)}
        }
        $alertBoxCommand"
    catch "$alertBox(toplevelName).frame1.button0 config $tmpButtonOpt"

    pack append $alertBox(toplevelName).frame1  $alertBox(toplevelName).frame1.button0 {left fillx expand}
  }

  # packing
  pack append $alertBox(toplevelName)  $alertBox(toplevelName).frame1 {bottom fill}  $alertBox(toplevelName).message1 {top fill expand}

  if {$alertBox(after) != 0} {
    after [expr $alertBox(after)*1000]  "catch \"$alertBox(toplevelName).frame1.button0 invoke\""
  }
}


# Procedure: CarefulExit
proc CarefulExit {} {
  global InitComplete
  if {$InitComplete == 0} {return}
  if {[YesNoBox "Really Quit?"]} {
    ClosePrinter
    exit
  }
}


# Procedure: FSBox
proc FSBox { {fsBoxMessage "Select file:"} {fsBoxFileName ""} {fsBoxActionOk ""} {fsBoxActionCancel ""}} {
# xf ignore me 5
##########
# Procedure: FSBox
# Description: show file selector box
# Arguments: fsBoxMessage - the text to display
#            fsBoxFileName - a file name that should be selected
#            fsBoxActionOk - the action that should be performed on ok
#            fsBoxActionCancel - the action that should be performed on cancel
# Returns: the filename that was selected, or nothing
# Sideeffects: none
##########
# 
# global fsBox(activeBackground) - active background color
# global fsBox(activeForeground) - active foreground color
# global fsBox(background) - background color
# global fsBox(font) - text font
# global fsBox(foreground) - foreground color
# global fsBox(extensions) - scan directory for extensions
# global fsBox(scrollActiveForeground) - scrollbar active background color
# global fsBox(scrollBackground) - scrollbar background color
# global fsBox(scrollForeground) - scrollbar foreground color
# global fsBox(scrollSide) - side where scrollbar is located

  global fsBox

  set tmpButtonOpt ""
  set tmpFrameOpt ""
  set tmpMessageOpt ""
  set tmpScaleOpt ""
  set tmpScrollOpt ""
  if {"$fsBox(activeBackground)" != ""} {
    append tmpButtonOpt "-activebackground \"$fsBox(activeBackground)\" "
  }
  if {"$fsBox(activeForeground)" != ""} {
    append tmpButtonOpt "-activeforeground \"$fsBox(activeForeground)\" "
  }
  if {"$fsBox(background)" != ""} {
    append tmpButtonOpt "-background \"$fsBox(background)\" "
    append tmpFrameOpt "-background \"$fsBox(background)\" "
    append tmpMessageOpt "-background \"$fsBox(background)\" "
  }
  if {"$fsBox(font)" != ""} {
    append tmpButtonOpt "-font \"$fsBox(font)\" "
    append tmpMessageOpt "-font \"$fsBox(font)\" "
  }
  if {"$fsBox(foreground)" != ""} {
    append tmpButtonOpt "-foreground \"$fsBox(foreground)\" "
    append tmpMessageOpt "-foreground \"$fsBox(foreground)\" "
  }
  if {"$fsBox(scrollActiveForeground)" != ""} {
    append tmpScrollOpt "-activeforeground \"$fsBox(scrollActiveForeground)\" "
  }
  if {"$fsBox(scrollBackground)" != ""} {
    append tmpScrollOpt "-background \"$fsBox(scrollBackground)\" "
  }
  if {"$fsBox(scrollForeground)" != ""} {
    append tmpScrollOpt "-foreground \"$fsBox(scrollForeground)\" "
  }

  if {[file exists [file tail $fsBoxFileName]] &&
      [IsAFile [file tail $fsBoxFileName]]} {
    set fsBox(name) [file tail $fsBoxFileName]
  } {
    set fsBox(name) ""
  }
  if {[file exists $fsBoxFileName] && [IsADir $fsBoxFileName]} {
    set fsBox(path) $fsBoxFileName
  } {
    if {"[file rootname $fsBoxFileName]" != "."} {
      set fsBox(path) [file rootname $fsBoxFileName]
    }
  }
  if {$fsBox(showPixmap)} {
    set fsBox(path) [string trimleft $fsBox(path) @]
  }
  if {"$fsBox(path)" != "" && [file exists $fsBox(path)] &&
      [IsADir $fsBox(path)]} {
    set fsBox(internalPath) $fsBox(path)
  } {
    if {"$fsBox(internalPath)" == "" ||
        ![file exists $fsBox(internalPath)]} {
      set fsBox(internalPath) [pwd]
    }
  }
  # build widget structure

  # build widget .fsbox
  catch "destroy .fsbox"

  toplevel .fsbox
  catch ".fsBox config $tmpFrameOpt"
  # Window manager configurations
  global tk_version
  wm sizefrom .fsbox program
  wm maxsize .fsbox 1000 1000
  wm minsize .fsbox 100 100
  wm title .fsbox {File Select Box}


  # build widget .fsbox.filter
  entry .fsbox.filter -relief {sunken}
  catch ".fsbox.filter config $tmpMessageOpt"

  # build widget .fsbox.selection
  entry .fsbox.selection -relief {sunken}
  catch ".fsbox.selection config $tmpMessageOpt"

  # build widget .fsbox.frame3
  frame .fsbox.frame3 -relief {raised}
  catch ".fsbox.frame3 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7
  frame .fsbox.frame3.frame7 -borderwidth {2}
  catch ".fsbox.frame3.frame7 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0
  frame .fsbox.frame3.frame7.frame0 -borderwidth {2}
  catch ".fsbox.frame3.frame7.frame0 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0.frame1
  frame .fsbox.frame3.frame7.frame0.frame1 
  catch ".fsbox.frame3.frame7.frame0.frame1 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0.frame1.frame3
  frame .fsbox.frame3.frame7.frame0.frame1.frame3 -borderwidth {2}
  catch ".fsbox.frame3.frame7.frame0.frame1.frame3 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0.frame1.frame3.listbox8
  listbox .fsbox.frame3.frame7.frame0.frame1.frame3.listbox8  -width 20 -height 10  -relief {sunken} -selectmode single -xscrollcommand {.fsbox.frame3.frame7.frame0.frame2.frame5.scrollbar10 set} -yscrollcommand {.fsbox.frame3.frame7.frame0.frame1.frame4.scrollbar9 set}
  catch ".fsbox.frame3.frame7.frame0.frame1.frame3.listbox8 config $tmpMessageOpt"

  # pack widget .fsbox.frame3.frame7.frame0.frame1.frame3
  pack append .fsbox.frame3.frame7.frame0.frame1.frame3  .fsbox.frame3.frame7.frame0.frame1.frame3.listbox8 {left frame center expand fill} 

  # build widget .fsbox.frame3.frame7.frame0.frame1.frame4
  frame .fsbox.frame3.frame7.frame0.frame1.frame4 -borderwidth {2}
  catch ".fsbox.frame3.frame7.frame0.frame1.frame4 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0.frame1.frame4.scrollbar9
  scrollbar .fsbox.frame3.frame7.frame0.frame1.frame4.scrollbar9  -command {.fsbox.frame3.frame7.frame0.frame1.frame3.listbox8 yview} -relief {sunken} -width {13}
  catch ".fsbox.frame3.frame7.frame0.frame1.frame4.scrollbar9 config $tmpScrollOpt"

  # pack widget .fsbox.frame3.frame7.frame0.frame1.frame4
  pack append .fsbox.frame3.frame7.frame0.frame1.frame4  .fsbox.frame3.frame7.frame0.frame1.frame4.scrollbar9 {top frame center expand filly} 

  # pack widget .fsbox.frame3.frame7.frame0.frame1
  pack append .fsbox.frame3.frame7.frame0.frame1  .fsbox.frame3.frame7.frame0.frame1.frame3 {left frame center expand fill}  .fsbox.frame3.frame7.frame0.frame1.frame4 {right frame center filly} 

  # build widget .fsbox.frame3.frame7.frame0.frame2
  frame .fsbox.frame3.frame7.frame0.frame2 -borderwidth {1}
  catch ".fsbox.frame3.frame7.frame0.frame2 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0.frame2.frame5
  frame .fsbox.frame3.frame7.frame0.frame2.frame5  -borderwidth {2}
  catch ".fsbox.frame3.frame7.frame0.frame2.frame5 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0.frame2.frame5.scrollbar10
  scrollbar .fsbox.frame3.frame7.frame0.frame2.frame5.scrollbar10  -command {.fsbox.frame3.frame7.frame0.frame1.frame3.listbox8 xview} -orient {horizontal} -relief {sunken} -width {13}
  catch ".fsbox.frame3.frame7.frame0.frame2.frame5.scrollbar10 config $tmpScrollOpt"

  # pack widget .fsbox.frame3.frame7.frame0.frame2.frame5
  pack append .fsbox.frame3.frame7.frame0.frame2.frame5  .fsbox.frame3.frame7.frame0.frame2.frame5.scrollbar10 {left frame center expand fillx} 

  # build widget .fsbox.frame3.frame7.frame0.frame2.frame6
  frame .fsbox.frame3.frame7.frame0.frame2.frame6 -borderwidth {2}
  catch ".fsbox.frame3.frame7.frame0.frame2.frame6 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame7.frame0.frame2.frame6.frame11
  frame .fsbox.frame3.frame7.frame0.frame2.frame6.frame11  -borderwidth {2} -height {13} -width {16}
  catch ".fsbox.frame3.frame7.frame0.frame2.frame6.frame11 config $tmpFrameOpt"

  # pack widget .fsbox.frame3.frame7.frame0.frame2.frame6
  pack append .fsbox.frame3.frame7.frame0.frame2.frame6  .fsbox.frame3.frame7.frame0.frame2.frame6.frame11 {top frame center expand fill} 

  # pack widget .fsbox.frame3.frame7.frame0.frame2
  pack append .fsbox.frame3.frame7.frame0.frame2  .fsbox.frame3.frame7.frame0.frame2.frame5 {left frame center expand fill}  .fsbox.frame3.frame7.frame0.frame2.frame6 {right frame center filly} 

  # pack widget .fsbox.frame3.frame7.frame0
  pack append .fsbox.frame3.frame7.frame0  .fsbox.frame3.frame7.frame0.frame1 {top frame center expand fill}  .fsbox.frame3.frame7.frame0.frame2 {bottom frame center fillx} 

  # build widget .fsbox.frame3.frame7.label9
  label .fsbox.frame3.frame7.label9  -text {Directories:}
  catch ".fsbox.frame3.frame7.label9 config $tmpMessageOpt"

  # pack widget .fsbox.frame3.frame7
  pack append .fsbox.frame3.frame7  .fsbox.frame3.frame7.label9 {top frame w}  .fsbox.frame3.frame7.frame0 {top frame center expand fill} 

  # build widget .fsbox.frame3.frame8
  frame .fsbox.frame3.frame8 -borderwidth {2}
  catch ".fsbox.frame3.frame8 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0
  frame .fsbox.frame3.frame8.frame0 -borderwidth {2}
  catch ".fsbox.frame3.frame8.frame0 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0.frame1
  frame .fsbox.frame3.frame8.frame0.frame1 
  catch ".fsbox.frame3.frame8.frame0.frame1 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0.frame1.frame3
  frame .fsbox.frame3.frame8.frame0.frame1.frame3 -borderwidth {2}
  catch ".fsbox.frame3.frame8.frame0.frame1.frame3 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0.frame1.frame3.listbox8
  listbox .fsbox.frame3.frame8.frame0.frame1.frame3.listbox8  -width 20 -height 10  -relief {sunken} -selectmode single  -xscrollcommand {.fsbox.frame3.frame8.frame0.frame2.frame5.scrollbar10 set} -yscrollcommand {.fsbox.frame3.frame8.frame0.frame1.frame4.scrollbar9 set}
  catch ".fsbox.frame3.frame8.frame0.frame1.frame3.listbox8 config $tmpMessageOpt"

  # pack widget .fsbox.frame3.frame8.frame0.frame1.frame3
  pack append .fsbox.frame3.frame8.frame0.frame1.frame3  .fsbox.frame3.frame8.frame0.frame1.frame3.listbox8 {left frame center expand fill} 

  # build widget .fsbox.frame3.frame8.frame0.frame1.frame4
  frame .fsbox.frame3.frame8.frame0.frame1.frame4 -borderwidth {2}
  catch ".fsbox.frame3.frame8.frame0.frame1.frame4 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0.frame1.frame4.scrollbar9
  scrollbar .fsbox.frame3.frame8.frame0.frame1.frame4.scrollbar9  -command {.fsbox.frame3.frame8.frame0.frame1.frame3.listbox8 yview} -relief {sunken} -width {13}
  catch ".fsbox.frame3.frame8.frame0.frame1.frame4.scrollbar9 config $tmpScrollOpt"

  # pack widget .fsbox.frame3.frame8.frame0.frame1.frame4
  pack append .fsbox.frame3.frame8.frame0.frame1.frame4  .fsbox.frame3.frame8.frame0.frame1.frame4.scrollbar9 {top frame center expand filly} 

  # pack widget .fsbox.frame3.frame8.frame0.frame1
  pack append .fsbox.frame3.frame8.frame0.frame1  .fsbox.frame3.frame8.frame0.frame1.frame3 {left frame center expand fill}  .fsbox.frame3.frame8.frame0.frame1.frame4 {right frame center filly} 

  # build widget .fsbox.frame3.frame8.frame0.frame2
  frame .fsbox.frame3.frame8.frame0.frame2 -borderwidth {1}
  catch ".fsbox.frame3.frame8.frame0.frame2 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0.frame2.frame5
  frame .fsbox.frame3.frame8.frame0.frame2.frame5 -borderwidth {2}
  catch ".fsbox.frame3.frame8.frame0.frame2.frame5 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0.frame2.frame5.scrollbar10
  scrollbar .fsbox.frame3.frame8.frame0.frame2.frame5.scrollbar10  -command {.fsbox.frame3.frame8.frame0.frame1.frame3.listbox8 xview} -orient {horizontal} -relief {sunken} -width {13}
  catch ".fsbox.frame3.frame8.frame0.frame2.frame5.scrollbar10 config $tmpScrollOpt"

  # pack widget .fsbox.frame3.frame8.frame0.frame2.frame5
  pack append .fsbox.frame3.frame8.frame0.frame2.frame5  .fsbox.frame3.frame8.frame0.frame2.frame5.scrollbar10 {left frame center expand fillx} 

  # build widget .fsbox.frame3.frame8.frame0.frame2.frame6
  frame .fsbox.frame3.frame8.frame0.frame2.frame6 -borderwidth {2}
  catch ".fsbox.frame3.frame8.frame0.frame2.frame6 config $tmpFrameOpt"

  # build widget .fsbox.frame3.frame8.frame0.frame2.frame6.frame11
  frame .fsbox.frame3.frame8.frame0.frame2.frame6.frame11  -borderwidth {2} -height {13} -width {16}
  catch ".fsbox.frame3.frame8.frame0.frame2.frame6.frame11 config $tmpFrameOpt"

  # pack widget .fsbox.frame3.frame8.frame0.frame2.frame6
  pack append .fsbox.frame3.frame8.frame0.frame2.frame6  .fsbox.frame3.frame8.frame0.frame2.frame6.frame11 {top frame center expand fill} 

  # pack widget .fsbox.frame3.frame8.frame0.frame2
  pack append .fsbox.frame3.frame8.frame0.frame2  .fsbox.frame3.frame8.frame0.frame2.frame5 {left frame center expand fill}  .fsbox.frame3.frame8.frame0.frame2.frame6 {right frame center filly} 

  # pack widget .fsbox.frame3.frame8.frame0
  pack append .fsbox.frame3.frame8.frame0  .fsbox.frame3.frame8.frame0.frame1 {top frame center expand fill}  .fsbox.frame3.frame8.frame0.frame2 {bottom frame center fillx} 

  # build widget .fsbox.frame3.frame8.label10
  label .fsbox.frame3.frame8.label10 -text {Files:}
  catch ".fsbox.frame3.frame8.label10 config $tmpMessageOpt"

  # pack widget .fsbox.frame3.frame8
  pack append .fsbox.frame3.frame8  .fsbox.frame3.frame8.label10 {top frame w}  .fsbox.frame3.frame8.frame0 {top frame center expand fill} 

  if {$fsBox(showPixmap)} {
    # build widget .fsbox.frame3.frame9
    frame .fsbox.frame3.frame9 -borderwidth {2}
    catch ".fsbox.frame3.frame9 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0
    frame .fsbox.frame3.frame9.frame0 -borderwidth {2}
    catch ".fsbox.frame3.frame9.frame0 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0.frame1
    frame .fsbox.frame3.frame9.frame0.frame1 
    catch ".fsbox.frame3.frame9.frame0.frame1 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0.frame1.frame3
    frame .fsbox.frame3.frame9.frame0.frame1.frame3 -borderwidth {2}
    catch ".fsbox.frame3.frame9.frame0.frame1.frame3 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0.frame1.frame3.canvas
    canvas .fsbox.frame3.frame9.frame0.frame1.frame3.canvas  -confine {true}  -width {100}  -relief {sunken} -borderwidth 2  -scrollregion {0c 0c 20c 20c}  -xscrollcommand {.fsbox.frame3.frame9.frame0.frame2.frame5.scrollbar10 set} -yscrollcommand {.fsbox.frame3.frame9.frame0.frame1.frame4.scrollbar9 set}
    catch ".fsbox.frame3.frame9.frame0.frame1.frame3.canvas config $tmpFrameOpt"
    .fsbox.frame3.frame9.frame0.frame1.frame3.canvas addtag currentBitmap withtag [.fsbox.frame3.frame9.frame0.frame1.frame3.canvas create bitmap 5 5 -anchor nw]

    # pack widget .fsbox.frame3.frame9.frame0.frame1.frame3
    pack append .fsbox.frame3.frame9.frame0.frame1.frame3  .fsbox.frame3.frame9.frame0.frame1.frame3.canvas {left frame center expand fill} 

    # build widget .fsbox.frame3.frame9.frame0.frame1.frame4
    frame .fsbox.frame3.frame9.frame0.frame1.frame4 -borderwidth {2}
    catch ".fsbox.frame3.frame9.frame0.frame1.frame4 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0.frame1.frame4.scrollbar9
    scrollbar .fsbox.frame3.frame9.frame0.frame1.frame4.scrollbar9  -command {.fsbox.frame3.frame9.frame0.frame1.frame3.canvas yview} -relief {sunken} -width {13}
    catch ".fsbox.frame3.frame9.frame0.frame1.frame4.scrollbar9 config $tmpScrollOpt"

    # pack widget .fsbox.frame3.frame9.frame0.frame1.frame4
    pack append .fsbox.frame3.frame9.frame0.frame1.frame4  .fsbox.frame3.frame9.frame0.frame1.frame4.scrollbar9 {top frame center expand filly} 

    # pack widget .fsbox.frame3.frame9.frame0.frame1
    pack append .fsbox.frame3.frame9.frame0.frame1  .fsbox.frame3.frame9.frame0.frame1.frame3 {left frame center expand fill}  .fsbox.frame3.frame9.frame0.frame1.frame4 {right frame center filly} 

    # build widget .fsbox.frame3.frame9.frame0.frame2
    frame .fsbox.frame3.frame9.frame0.frame2 -borderwidth {1}
    catch ".fsbox.frame3.frame9.frame0.frame2 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0.frame2.frame5
    frame .fsbox.frame3.frame9.frame0.frame2.frame5 -borderwidth {2}
    catch ".fsbox.frame3.frame9.frame0.frame2.frame5 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0.frame2.frame5.scrollbar10
    scrollbar .fsbox.frame3.frame9.frame0.frame2.frame5.scrollbar10  -command {.fsbox.frame3.frame9.frame0.frame1.frame3.canvas xview} -orient {horizontal} -relief {sunken} -width {13}
    catch ".fsbox.frame3.frame9.frame0.frame2.frame5.scrollbar10 config $tmpScrollOpt"

    # pack widget .fsbox.frame3.frame9.frame0.frame2.frame5
    pack append .fsbox.frame3.frame9.frame0.frame2.frame5  .fsbox.frame3.frame9.frame0.frame2.frame5.scrollbar10 {left frame center expand fillx} 

    # build widget .fsbox.frame3.frame9.frame0.frame2.frame6
    frame .fsbox.frame3.frame9.frame0.frame2.frame6 -borderwidth {2}
    catch ".fsbox.frame3.frame9.frame0.frame2.frame6 config $tmpFrameOpt"

    # build widget .fsbox.frame3.frame9.frame0.frame2.frame6.frame11
    frame .fsbox.frame3.frame9.frame0.frame2.frame6.frame11  -borderwidth {2} -height {13} -width {16}
    catch ".fsbox.frame3.frame9.frame0.frame2.frame6.frame11 config $tmpFrameOpt"

    # pack widget .fsbox.frame3.frame9.frame0.frame2.frame6
    pack append .fsbox.frame3.frame9.frame0.frame2.frame6  .fsbox.frame3.frame9.frame0.frame2.frame6.frame11 {top frame center expand fill} 

    # pack widget .fsbox.frame3.frame9.frame0.frame2
    pack append .fsbox.frame3.frame9.frame0.frame2  .fsbox.frame3.frame9.frame0.frame2.frame5 {left frame center expand fill}  .fsbox.frame3.frame9.frame0.frame2.frame6 {right frame center filly} 

    # pack widget .fsbox.frame3.frame9.frame0
    pack append .fsbox.frame3.frame9.frame0  .fsbox.frame3.frame9.frame0.frame1 {top frame center expand fill}  .fsbox.frame3.frame9.frame0.frame2 {bottom frame center fillx} 

    # build widget .fsbox.frame3.frame9.label10
    label .fsbox.frame3.frame9.label10 -text {Pixmap:}
    catch ".fsbox.frame3.frame9.label10 config $tmpMessageOpt"

    # pack widget .fsbox.frame3.frame9
    pack append .fsbox.frame3.frame9  .fsbox.frame3.frame9.label10 {top frame w}  .fsbox.frame3.frame9.frame0 {top frame center expand fill} 

    # pack widget .fsbox.frame3
    pack append .fsbox.frame3  .fsbox.frame3.frame7 {left frame center expand fill}  .fsbox.frame3.frame8 {left frame center expand fill}  .fsbox.frame3.frame9 {right frame center expand fill} 
  } else {
    # pack widget .fsbox.frame3
    pack append .fsbox.frame3  .fsbox.frame3.frame7 {left frame center expand fill}  .fsbox.frame3.frame8 {right frame center expand fill} 
  }

  # build widget .fsbox.buttons
  frame .fsbox.buttons -relief {raised}
  catch ".fsbox.buttons config $tmpFrameOpt"

  # build widget .fsbox.buttons.filter
  button .fsbox.buttons.filter -text {Filter} -command {FSBoxFilter .fsbox}
  catch ".fsbox.buttons.filter config $tmpButtonOpt"

  # build widget .fsbox.buttons.ok
  button .fsbox.buttons.ok -text {OK} -command {FSBoxOk .fsbox}
  catch ".fsbox.buttons.ok config $tmpButtonOpt"

  # build widget .fsbox.buttons.cancel
  button .fsbox.buttons.cancel -text {Cancel} -command {FSBoxCancel .fsbox}
  catch ".fsbox.buttons.cancel config $tmpButtonOpt"

  # build widget .fsbox.buttons.help
  button .fsbox.buttons.help -text {Help} -command {FSBoxHelp .fsbox}
  catch ".fsbox.buttons.help config $tmpButtonOpt"

  # pack widget .fsbox.buttons
  pack append .fsbox.buttons  .fsbox.buttons.filter {left frame center expand}  .fsbox.buttons.ok {left frame center expand}  .fsbox.buttons.cancel {left frame center expand}  .fsbox.buttons.help {right frame center expand} 

  # build widget .fsbox.label1
  label .fsbox.label1 -text {Filter:}
  catch ".fsbox.label1 config $tmpMessageOpt"

  # build widget .fsbox.label4
  label .fsbox.label4 -text {Selection:}
  catch ".fsbox.label4 config $tmpMessageOpt"

  # pack widget .fsbox
  pack append .fsbox  .fsbox.label1 {top frame w}  .fsbox.filter {top frame center expand fillx}  .fsbox.frame3 {top frame center expand fill}  .fsbox.label4 {top frame w expand}  .fsbox.selection {top frame center expand fillx}  .fsbox.buttons {top frame center expand fill} 

  .fsbox.filter insert end "$fsBox(internalPath)/$fsBox(pattern)"

  FSBoxFilter .fsbox
  bindtags .fsbox.frame3.frame7.frame0.frame1.frame3.listbox8 {Listbox .fsbox.frame3.frame7.frame0.frame1.frame3.listbox8}
  bind .fsbox.frame3.frame7.frame0.frame1.frame3.listbox8 <ButtonRelease-1> {FSBoxSingle1Directories .fsbox %W}
  bindtags .fsbox.frame3.frame8.frame0.frame1.frame3.listbox8 {Listbox .fsbox.frame3.frame8.frame0.frame1.frame3.listbox8}
  bind .fsbox.frame3.frame8.frame0.frame1.frame3.listbox8 <ButtonRelease-1> {FSBoxSingle1Files .fsbox %W}

  bind .fsbox.filter <Return> {FSBoxFilter .fsbox;break}
  bind .fsbox.selection <Return> {.fsbox.buttons.ok invoke;break}

# end of widget tree

  update idletask
  grab .fsbox
  tkwait window .fsbox
  if {"[string trim $fsBox(path)]" != "" ||
      "[string trim $fsBox(name)]" != ""} {
    if {"[string trimleft [string trim $fsBox(name)] /]" == ""} {
      return [string trimright [string trim $fsBox(path)] /]
    } {
      return [string trimright [string trim $fsBox(path)] /]/[string trimleft [string trim $fsBox(name)] /]
    }
  }
}


# Procedure: FSBoxCancel
proc FSBoxCancel { toplevel} {
  global fsBox
  set fsBox(name) ""
  catch "destroy $toplevel"
}


# Procedure: FSBoxFilter
proc FSBoxFilter { toplevel} {
  global fsBox
  set filter "[$toplevel.filter get]"
  set fsBox(internalPath) [file dirname $filter]
  set fsBox(pattern) [file tail $filter]
  set files "[lsort [glob -nocomplain -- $filter]]"
  $toplevel.frame3.frame7.frame0.frame1.frame3.listbox8 delete 0 end
  $toplevel.frame3.frame8.frame0.frame1.frame3.listbox8 delete 0 end
  foreach f "$files" {
    set tail "[file tail $f]"
    set isdir "[file isdir $f]"
    if {$isdir} {
      if {$fsBox(typeMask) != "Regular"} {
	$toplevel.frame3.frame8.frame0.frame1.frame3.listbox8 insert end "$tail"
      }
    } else {
      if {$fsBox(typeMask) != "Directory"} {
	$toplevel.frame3.frame8.frame0.frame1.frame3.listbox8 insert end "$tail"
      }
    }
  }
  set dirs "$fsBox(internalPath)/.. [lsort [glob -nocomplain -- $fsBox(internalPath)/*]]"
  foreach d "$dirs" {
    set tail "[file tail $d]"
    set isdir "[file isdir $d]"
    if {$isdir} {
      $toplevel.frame3.frame7.frame0.frame1.frame3.listbox8 insert end "$tail/"
    }
  }
  $toplevel.selection delete 0 end
  $toplevel.selection insert end "$fsBox(internalPath)/$fsBox(name)"
}


# Procedure: FSBoxHelp
proc FSBoxHelp { toplevel} {
  global fsBox
}


# Procedure: FSBoxOk
proc FSBoxOk { toplevel} {
  global fsBox
  set result "[$toplevel.selection get]"
  set fsBox(path) "[file dirname $result]"
  set fsBox(name) "[file tail $result]"
  catch "destroy $toplevel"
}


# Procedure: FSBoxSingle1Directories
proc FSBoxSingle1Directories { toplevel listbox} {
  global fsBox
  set selection "[string trimright [$listbox get active] {/}]"
  if {[string compare {..} "$selection"] == 0} {
    set temp "[file dirname $fsBox(internalPath)]/$fsBox(pattern)"
    $toplevel.filter delete 0 end
    $toplevel.filter insert end "$temp"
  } else {
    set temp "$fsBox(internalPath)/$selection/$fsBox(pattern)"
    $toplevel.filter delete 0 end
    $toplevel.filter insert end "$temp"
  }
}


# Procedure: FSBoxSingle1Files
proc FSBoxSingle1Files { toplevel listbox} {
  global fsBox
  set selection "[$listbox get active]"
  set temp "$fsBox(internalPath)/$selection"
  $toplevel.selection delete 0 end
  $toplevel.selection insert end "$temp"
  if {$fsBox(showPixmap) && ![file isdir $temp]} {
    catch "$toplevel.frame3.frame9.frame0.frame1.frame3.canvas itemconfigure currentBitmap -bitmap \"@$temp\""
  }
}


# Procedure: InputBoxInternal
proc InputBoxInternal { inputBoxMessage inputBoxCommandOk inputBoxCommandCancel inputBoxGeometry inputBoxTitle lineNum} {
# xf ignore me 6
  global inputBox

  set tmpButtonOpt ""
  set tmpFrameOpt ""
  set tmpMessageOpt ""
  set tmpScaleOpt ""
  set tmpScrollOpt ""
  if {"$inputBox(activeBackground)" != ""} {
    append tmpButtonOpt "-activebackground \"$inputBox(activeBackground)\" "
  }
  if {"$inputBox(activeForeground)" != ""} {
    append tmpButtonOpt "-activeforeground \"$inputBox(activeForeground)\" "
  }
  if {"$inputBox(background)" != ""} {
    append tmpButtonOpt "-background \"$inputBox(background)\" "
    append tmpFrameOpt "-background \"$inputBox(background)\" "
    append tmpMessageOpt "-background \"$inputBox(background)\" "
  }
  if {"$inputBox(font)" != ""} {
    append tmpButtonOpt "-font \"$inputBox(font)\" "
    append tmpMessageOpt "-font \"$inputBox(font)\" "
  }
  if {"$inputBox(foreground)" != ""} {
    append tmpButtonOpt "-foreground \"$inputBox(foreground)\" "
    append tmpMessageOpt "-foreground \"$inputBox(foreground)\" "
  }
  if {"$inputBox(scrollActiveForeground)" != ""} {
    append tmpScrollOpt "-activeforeground \"$inputBox(scrollActiveForeground)\" "
  }
  if {"$inputBox(scrollBackground)" != ""} {
    append tmpScrollOpt "-background \"$inputBox(scrollBackground)\" "
  }
  if {"$inputBox(scrollForeground)" != ""} {
    append tmpScrollOpt "-foreground \"$inputBox(scrollForeground)\" "
  }

  # start build of toplevel
  if {"[info commands XFDestroy]" != ""} {
    catch {XFDestroy $inputBox(toplevelName)}
  } {
    catch {destroy $inputBox(toplevelName)}
  }
  toplevel $inputBox(toplevelName)  -borderwidth 0
  catch "$inputBox(toplevelName) config $tmpFrameOpt"
  if {[catch "wm geometry $inputBox(toplevelName) $inputBoxGeometry"]} {
    wm geometry $inputBox(toplevelName) 350x150
  }
  wm title $inputBox(toplevelName) $inputBoxTitle
  wm maxsize $inputBox(toplevelName) 1000 1000
  wm minsize $inputBox(toplevelName) 100 100
  # end build of toplevel

  message $inputBox(toplevelName).message1  -anchor "$inputBox(anchor)"  -justify "$inputBox(justify)"  -relief raised  -text "$inputBoxMessage"
  catch "$inputBox(toplevelName).message1 config $tmpMessageOpt"

  set xfTmpWidth  [string range $inputBoxGeometry 0 [expr [string first x $inputBoxGeometry]-1]]
  if {"$xfTmpWidth" != ""} {
    # set message size
    catch "$inputBox(toplevelName).message1 configure  -width [expr $xfTmpWidth-10]"
  } {
    $inputBox(toplevelName).message1 configure  -aspect 1500
  }

  frame $inputBox(toplevelName).frame0  -borderwidth 0  -relief raised
  catch "$inputBox(toplevelName).frame0 config $tmpFrameOpt"

  frame $inputBox(toplevelName).frame1  -borderwidth 0  -relief raised
  catch "$inputBox(toplevelName).frame1 config $tmpFrameOpt"

  if {$lineNum == 1} {
    scrollbar $inputBox(toplevelName).frame1.hscroll  -orient "horizontal"  -relief raised  -command "$inputBox(toplevelName).frame1.input view"
    catch "$inputBox(toplevelName).frame1.hscroll config $tmpScrollOpt"

    entry $inputBox(toplevelName).frame1.input  -relief raised  -scrollcommand "$inputBox(toplevelName).frame1.hscroll set"
    catch "$inputBox(toplevelName).frame1.input config $tmpMessageOpt"

    $inputBox(toplevelName).frame1.input insert 0  $inputBox($inputBox(toplevelName),inputOne)
    
    # bindings
    bind $inputBox(toplevelName).frame1.input <Return> "
      global inputBox
      set inputBox($inputBox(toplevelName),inputOne) \[$inputBox(toplevelName).frame1.input get\]
      if {\"\[info commands XFDestroy\]\" != \"\"} {
        catch {XFDestroy $inputBox(toplevelName)}
      } {
        catch {destroy $inputBox(toplevelName)}
      }
      $inputBoxCommandOk"
    
    # packing
    pack append $inputBox(toplevelName).frame1  $inputBox(toplevelName).frame1.hscroll {bottom fill}  $inputBox(toplevelName).frame1.input {top fill expand}
  } {
    text $inputBox(toplevelName).frame1.input  -relief raised  -wrap none  -borderwidth 2  -yscrollcommand "$inputBox(toplevelName).frame1.vscroll set"
    catch "$inputBox(toplevelName).frame1.input config $tmpMessageOpt"

    scrollbar $inputBox(toplevelName).frame1.vscroll  -relief raised  -command "$inputBox(toplevelName).frame1.input yview"
    catch "$inputBox(toplevelName).frame1.vscroll config $tmpScrollOpt"

    $inputBox(toplevelName).frame1.input insert 1.0  $inputBox($inputBox(toplevelName),inputMulti)

    # bindings
    bind $inputBox(toplevelName).frame1.input <Control-Return> "
      global inputBox
      set inputBox($inputBox(toplevelName),inputMulti) \[$inputBox(toplevelName).frame1.input get 1.0 end\]
      if {\"\[info commands XFDestroy\]\" != \"\"} {
        catch {XFDestroy $inputBox(toplevelName)}
      } {
        catch {destroy $inputBox(toplevelName)}
      }
      $inputBoxCommandOk"
    bind $inputBox(toplevelName).frame1.input <Meta-Return> "
      global inputBox
      set inputBox($inputBox(toplevelName),inputMulti) \[$inputBox(toplevelName).frame1.input get 1.0 end\]
      if {\"\[info commands XFDestroy\]\" != \"\"} {
        catch {XFDestroy $inputBox(toplevelName)}
      } {
        catch {destroy $inputBox(toplevelName)}
      }
      $inputBoxCommandOk"

    # packing
    pack append $inputBox(toplevelName).frame1  $inputBox(toplevelName).frame1.vscroll "$inputBox(scrollSide) filly"  $inputBox(toplevelName).frame1.input {left fill expand}
  }
  
  button $inputBox(toplevelName).frame0.button0  -text "OK"  -command "
      global inputBox
      if {$lineNum == 1} {
        set inputBox($inputBox(toplevelName),inputOne) \[$inputBox(toplevelName).frame1.input get\]
      } {
        set inputBox($inputBox(toplevelName),inputMulti) \[$inputBox(toplevelName).frame1.input get 1.0 end\]
      }
      if {\"\[info commands XFDestroy\]\" != \"\"} {
        catch {XFDestroy $inputBox(toplevelName)}
      } {
        catch {destroy $inputBox(toplevelName)}
      }
      $inputBoxCommandOk"
  catch "$inputBox(toplevelName).frame0.button0 config $tmpButtonOpt"

  button $inputBox(toplevelName).frame0.button1  -text "Cancel"  -command "
      global inputBox
      if {$lineNum == 1} {
        set inputBox($inputBox(toplevelName),inputOne) \"\"
      } {
        set inputBox($inputBox(toplevelName),inputMulti) \"\"
      }
      if {\"\[info commands XFDestroy\]\" != \"\"} {
        catch {XFDestroy $inputBox(toplevelName)}
      } {
        catch {destroy $inputBox(toplevelName)}
      }
      $inputBoxCommandCancel"
  catch "$inputBox(toplevelName).frame0.button1 config $tmpButtonOpt"

  pack append $inputBox(toplevelName).frame0  $inputBox(toplevelName).frame0.button0 {left fill expand}  $inputBox(toplevelName).frame0.button1 {left fill expand}

  pack append $inputBox(toplevelName)  $inputBox(toplevelName).frame0 {bottom fill}  $inputBox(toplevelName).frame1 {bottom fill expand}  $inputBox(toplevelName).message1 {top fill}
}


# Procedure: InputBoxMulti
proc InputBoxMulti { {inputBoxMessage "Input box:"} {inputBoxCommandOk ""} {inputBoxCommandCancel ""} {inputBoxGeometry "350x150"} {inputBoxTitle "Input box"}} {
# xf ignore me 5
##########
# Procedure: InputBoxMulti
# Description: show input box with one text line
# Arguments: {inputBoxMessage} - message to display
#            {inputBoxCommandOk} - the command to call after ok
#            {inputBoxCommandCancel} - the command to call after cancel
#            {inputBoxGeometry} - the geometry for the window
#            {inputBoxTitle} - the title for the window
# Returns: The entered text
# Sideeffects: none
# Notes: there exist also a function called:
#          InputBoxOne - to enter one line text
##########
#
# global inputBox(activeBackground) - active background color
# global inputBox(activeForeground) - active foreground color
# global inputBox(anchor) - anchor for message box
# global inputBox(background) - background color
# global inputBox(erase) - erase previous text
# global inputBox(font) - message font
# global inputBox(foreground) - foreground color
# global inputBox(justify) - justify for message box
# global inputBox(scrollActiveForeground) - scrollbar active background color
# global inputBox(scrollBackground) - scrollbar background color
# global inputBox(scrollForeground) - scrollbar foreground color
# global inputBox(scrollSide) - side where scrollbar is located
# global inputBox(toplevelName) - the toplevel name
# global inputBox(toplevelName,inputMulti) - the text in the text widget

  global inputBox

  if {"$inputBoxGeometry" == ""} {
    set inputBoxGeometry 350x150
  }
  if {$inputBox(erase)} {
    set inputBox($inputBox(toplevelName),inputMulti) ""
  } {
    if {![info exists inputBox($inputBox(toplevelName),inputMulti)]} {
      set inputBox($inputBox(toplevelName),inputMulti) ""
    }
  }
  InputBoxInternal $inputBoxMessage $inputBoxCommandOk $inputBoxCommandCancel $inputBoxGeometry $inputBoxTitle 2

  # wait for the box to be destroyed
  update idletask
  grab $inputBox(toplevelName)
  tkwait window $inputBox(toplevelName)

  return $inputBox($inputBox(toplevelName),inputMulti)
}


# Procedure: InputBoxOne
proc InputBoxOne { {inputBoxMessage "Input box:"} {inputBoxCommandOk ""} {inputBoxCommandCancel ""} {inputBoxGeometry "350x150"} {inputBoxTitle "Input box"}} {
# xf ignore me 5
##########
# Procedure: InputBoxOne
# Description: show input box with one text line
# Arguments: {inputBoxMessage} - message to display
#            {inputBoxCommandOk} - the command to call after ok
#            {inputBoxCommandCancel} - the command to call after cancel
#            {inputBoxGeometry} - the geometry for the window
#            {inputBoxTitle} - the title for the window
# Returns: The entered text
# Sideeffects: none
# Notes: there exist also a function called:
#          InputBoxMulti - to enter multiline text
##########
#
# global inputBox(activeBackground) - active background color
# global inputBox(activeForeground) - active foreground color
# global inputBox(anchor) - anchor for message box
# global inputBox(background) - background color
# global inputBox(erase) - erase previous text
# global inputBox(font) - message font
# global inputBox(foreground) - foreground color
# global inputBox(justify) - justify for message box
# global inputBox(scrollActiveForeground) - scrollbar active background color
# global inputBox(scrollBackground) - scrollbar background color
# global inputBox(scrollForeground) - scrollbar foreground color
# global inputBox(scrollSide) - side where scrollbar is located
# global inputBox(toplevelName) - the toplevel name
# global inputBox(toplevelName,inputOne) - the text in the entry widget

  global inputBox

  if {$inputBox(erase)} {
    set inputBox($inputBox(toplevelName),inputOne) ""
  } {
    if {![info exists inputBox($inputBox(toplevelName),inputOne)]} {
      set inputBox($inputBox(toplevelName),inputOne) ""
    }
  }
  InputBoxInternal $inputBoxMessage $inputBoxCommandOk $inputBoxCommandCancel $inputBoxGeometry $inputBoxTitle 1

  # wait for the box to be destroyed
  update idletask
  grab $inputBox(toplevelName)
  tkwait window $inputBox(toplevelName)

  return $inputBox($inputBox(toplevelName),inputOne)
}


# Procedure: IsADir
proc IsADir { pathName} {
# xf ignore me 5
##########
# Procedure: IsADir
# Description: check if name is a directory (including symbolic links)
# Arguments: pathName - the path to check
# Returns: 1 if its a directory, otherwise 0
# Sideeffects: none
##########

  if {[file isdirectory $pathName]} {
    return 1
  } {
    catch "file type $pathName" fileType
    if {"$fileType" == "link"} {
      if {[catch "file readlink $pathName" linkName]} {
        return 0
      }
      catch "file type $linkName" fileType
      while {"$fileType" == "link"} {
        if {[catch "file readlink $linkName" linkName]} {
          return 0
        }
        catch "file type $linkName" fileType
      }
      return [file isdirectory $linkName]
    }
  }
  return 0
}


# Procedure: IsAFile
proc IsAFile { fileName} {
# xf ignore me 5
##########
# Procedure: IsAFile
# Description: check if filename is a file (including symbolic links)
# Arguments: fileName - the filename to check
# Returns: 1 if its a file, otherwise 0
# Sideeffects: none
##########

  if {[file isfile $fileName]} {
    return 1
  } {
    catch "file type $fileName" fileType
    if {"$fileType" == "link"} {
      if {[catch "file readlink $fileName" linkName]} {
        return 0
      }
      catch "file type $linkName" fileType
      while {"$fileType" == "link"} {
        if {[catch "file readlink $linkName" linkName]} {
          return 0
        }
        catch "file type $linkName" fileType
      }
      return [file isfile $linkName]
    }
  }
  return 0
}


# Procedure: IsASymlink
proc IsASymlink { fileName} {
# xf ignore me 5
##########
# Procedure: IsASymlink
# Description: check if filename is a symbolic link
# Arguments: fileName - the path/filename to check
# Returns: none
# Sideeffects: none
##########

  catch "file type $fileName" fileType
  if {"$fileType" == "link"} {
    return 1
  }
  return 0
}


# Procedure: LoadCarFile
proc LoadCarFile {} {
  global COMMA
  global CarsFile
#============================================================================
#
# Read (and optionally reload) cars from the CarsFile
#
#============================================================================
  WIP_Start "Loading Cars File"
  if {[catch [list open "$CarsFile" r] fp4]} {
    puts stderr "Error opening $CarsFile: $fp4"
    exit 61
  }
  global SessionNumber
  global ShiftNumber
  global TotalCars
  if {[SkipCommentsGets $fp4 line] < 0} {
    ErrorBadCarsFile {Session number missing}
  }
  set SessionNumber [string trim $line]
  if {[SkipCommentsGets $fp4 line] < 0} {
    ErrorBadCarsFile  {Shift number missing}
  }
  set ShiftNumber [string trim $line]
  if {[SkipCommentsGets $fp4 line] < 0} {
    ErrorBadCarsFile {Total Car Count Missing}
  }
  set TotalCars [string trim $line]
  global TotalShifts
  set TotalShifts [expr $SessionNumber * 3]
  incr ShiftNumber
  if {$ShiftNumber > 3} {
    set ShiftNumber 1
    incr SessionNumber
  }
  incr SessionNumber $ShiftNumber
  global LimitCars
  global SwitchListLimitCars
  set LimitCars [expr $TotalCars + 10]
  set SwitchListLimitCars [expr $LimitCars * 2]
  [SN LogWindow] insert end "\nCurrent session = $SessionNumber"
  [SN LogWindow] insert end " Shift = $ShiftNumber Cars = $TotalCars\n"
  [SN LogWindow] see end
# Allocate memory for cars, and read in definitions
#
#   CrsType        car type from TypesFile
#   CrsRR          railroad reporting mark symbols or lessor/lessee string
#   CrsNum         car number or car number/units -- a string not a number
#   CrsDivList     division assignment list for empty -- or no restriction
#   CrsLen         extreme car (or multi-car) length over couplers
#   CrsPlate       clearance plate -- see PLATE.TXT file
#   CrsClass       car weight class -- see WEIGHT.TXT file
#   CrsLtWt        car light weight in tons
#   CrsLdLmt       car load limit in tons
#   CrsStatus      loaded or empty status is "L" or "E"
#   CrsOkToMirror  Y means car may be mirrored
#   CrsFixedRoute  Y means car can only be routed to home divisions
#   CrsOwner       car owner's initials -- see OWNERS.TXT
#   CrsDone        car is done moving -- receives TrnDone value
#   CrsTrain       last train to move this car
#   CrsMoves       number of times car was moved this session
#   CrsLoc         car's current location
#   CrsDest        car's destination
#   CrsTrips       number of moves for this car
#   CrsAssigns     number of assignments for this car
#
#   CrsPeek        temporary look-ahead array for car handling
#   CrsTmpStatus   status during assignment
#
#   SwitchListPickCar   which car was picked up
#   SwitchListPickLoc   where was car when picked up
#   SwitchListPickTrain which train picked up car
#   SwitchListLastTrain last train that picked up this car
#   SwitchListDropStop  which location car shall be dropped
  global CrsType
  global CrsRR
  global CrsNum
  global CrsDivList
  global CrsLen
  global CrsPlate
  global CrsClass
  global CrsLtWt
  global CrsLdLmt
  global CrsStatus
  global CrsOkToMirror
  global CrsFixedRoute
  global CrsTmpStatus
  global CrsOwner
  global CrsDone
  global CrsTrain
  global CrsMoves
  global CrsLoc
  global CrsDest
  global CrsTrips
  global CrsAssigns
  global CrsPeek
  global SwitchListPickCar
  global SwitchListPickLoc
  global SwitchListPickTrain
  global SwitchListLastTrain
  global SwitchListDropStop
  global PickIndex
  global IndsCarsIndexes
  for {set Cx 0} {$Cx <= $LimitCars} {incr Cx} {
    set CrsOwner($Cx) "UNK"
  }
  set Cx 0
  set Tenth [expr 10.0 / double($LimitCars)]
  set Done 0 
  WIP 0 {0% Done}
  while {[SkipCommentsGets $fp4 line] >= 0} {
    incr Cx
    if {[expr $Cx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Cx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    set vlist [split $line $COMMA]
    set CarTypeSymbol "[lindex $vlist 0]"

    set CrsType($Cx) "$CarTypeSymbol"
    set CrsRR($Cx) "[string trim [lindex $vlist 1]]"
    set CrsNum($Cx) "[string trim [lindex $vlist 2]]"
    set CrsDivList($Cx) "[string trim [lindex $vlist 3]]"
    set CrsLen($Cx) "[string trim [lindex $vlist 4]]"
    set CrsPlate($Cx) "[string trim [lindex $vlist 5]]"
    set CrsClass($Cx) "[string trim [lindex $vlist 6]]"
    set CrsLtWt($Cx) "[string trim [lindex $vlist 7]]"
    set CrsLdLmt($Cx) "[string trim [lindex $vlist 8]]"
    set CrsStatus($Cx) "[string trim [lindex $vlist 9]]"
    set CrsOkToMirror($Cx) "[string trim [lindex $vlist 10]]"
    set CrsFixedRoute($Cx) "[string trim [lindex $vlist 11]]"
    set CrsOwner($Cx) "[string toupper [string trim [lindex $vlist 12]]]"
    set CrsDone($Cx) "[string trim [lindex $vlist 13]]"
    set CrsTrain($Cx) "[string trim [lindex $vlist 14]]"
    set CrsMoves($Cx) "[string trim [lindex $vlist 15]]"
    set CrsLoc($Cx) "[string trim [lindex $vlist 16]]"
    set CrsDest($Cx) "[string trim [lindex $vlist 17]]"
    set CrsTrips($Cx) "[string trim [lindex $vlist 18]]"
    set CrsAssigns($Cx) "[string trim [lindex $vlist 19]]"
    if {$Cx == $LimitCars} {break}
#    puts stderr "Car #$Cx: $CrsRR($Cx) $CrsNum($Cx) type $CrsType($Cx) dest $CrsDest($Cx)"
  }
  WIP 100 {100% Done}
  close $fp4
  if {$Cx == 0} {ErrorBadCarsFile {No Cars!}}
  set TotalCars $Cx
  set Tenth [expr 10.0 / double($LimitCars)]
  set Done 0
  WIP_Start "Shift Adjusting..."
  WIP 0 {0% Done}
  for {set Cx 1} {$Cx <= $LimitCars} {incr Cx} {
    if {[expr $Cx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Cx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    set CrsDone($Cx) {N}
    set CrsTrain($Cx) 0
    if {$SessionNumber == 1 && $ShiftNumber == 1} {
      set CrsTrips($Cx) 0
      set CrsAssigns($Cx) 0
    }
    global TotalIndustries
    if {[catch "set CrsLoc($Cx)" l]} {set CrsLoc($Cx) 0}
    if {$CrsLoc($Cx) > $TotalIndustries} {set CrsLoc($Cx) 0}
    if {[catch "set CrsDest($Cx)" l]} {set CrsDest($Cx) 0}
    if {$CrsDest($Cx) > $TotalIndustries} {set CrsDest($Cx) $CrsLoc($Cx)}
    if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
    lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
  }
  WIP 100 {100% Done}
}


# Procedure: LoadStatsFile
proc LoadStatsFile {} {
  global COMMA
  global StatsFile
#============================================================================
#
# Read industry data from the Stats file
#
#============================================================================
  WIP_Start "Reading the Stats file"
  global StatsPeriod
  set StatsFileEof 0
  global TotalIndustries
  global IndsCarsNum
  global IndsCarsLen
  global IndsStatsLen
  if {[catch [list open "$StatsFile" r] fp6]} {
    set StatsPeriod 1
    set StatsFileEof 1
  }
  if {$StatsFileEof == 0} {
    if {[gets $fp6 line] < 0} {
      set StatsPeriod 1
      set StatsFileEof 1
    } else {
      set StatsPeriod [string trim $line]
      if {$StatsPeriod <= 0} {set StatsPeriod 1}
    }
    set Tenth [expr 10.0 / double($TotalIndustries)]
    set Done 0
    set Gx 0
    WIP 0 {0% Done}
    while {[gets $fp6 line] >= 0} {
      incr Gx
      if {[expr $Gx * $Tenth] >= [expr $Done + 1]} {
	set Done [expr $Gx * $Tenth]
	set DonePer [expr $Done * 10]
	WIP $DonePer "[format {%f%% Done} $DonePer]"
	set Done [expr int($Done)]
      }
      if {[scan "$line" {%4d%3d%3d%6d} Ix cn cl sl] == 4} {
	if {$Ix < 0 || $Ix > $TotalIndustries} {set Ix 0}
	set IndsCarsNum($Ix) $cn
	set IndsCarsLen($Ix) $cl
	set IndsStatsLen($Ix) $sl
      }
    }
  }
  catch "close $fp6"
  global IndsTrackLen
  set Tenth [expr 10.0 / double($TotalIndustries)]
  set Done 0
  WIP_Start "Adjusting Industry Stats"
  WIP 0 {0% Done}
  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    if {[expr $Ix * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Ix * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {$StatsPeriod == 1} {
      set IndsCarsNum($Ix) 0
      set IndsCarsLen($Ix) 0
      set IndsStatsLen($Ix) 0
    } else {
      if {[catch [list set IndsCarsNum($Ix)]]}  {set IndsCarsNum($Ix) 0}
      if {[catch [list set IndsCarsLen($Ix)]]}  {set IndsCarsLen($Ix) 0}
      if {[catch [list set IndsStatsLen($Ix)]]} {set IndsStatsLen($Ix) 0}
    }
    if {[catch "set IndsTrackLen($Ix)" l]} {
#      puts stderr "*** IndsTrackLen($Ix) not set: $l, reseting to 0"
      set IndsTrackLen($Ix) 0
    }
    incr IndsStatsLen($Ix) $IndsTrackLen($Ix)
  }
  WIP 100 {100% Done}
}


# Procedure: LoadSystemFile
proc LoadSystemFile {} {
  global COMMA
  [SN LogWindow] insert end "Loading system file...\n"
  if {[catch [list open system.dat r] fp1]} {
    puts stderr "Error opening system.dat: $fp1"
    exit 1
  }
#============================================================================
#
# Read System and File names
#
#============================================================================
  global RailSystem
  global IndusFile
  global TrainFile
  global OrderFile
  global OwnerFile
  global CarTypesFile
  global CarsFile
  global StatsFile
  if {[gets $fp1 RailSystem] < 0} {
    puts stderr "Error reading system.dat -- short file (RailSystem)!"
    exit 2
  }
  if {[string length $RailSystem] > 23} {
    set RailSystem [string range "$RailSystem" 0 22]
  }
  gets $fp1 Pad
  if {[gets $fp1 IndusFile] < 0} {
    puts stderr "Error reading system.dat -- short file (IndusFile)!"
    exit 3
  }
  if {[gets $fp1 TrainFile] < 0} {
    puts stderr "Error reading system.dat -- short file (TrainFile)!"
    exit 4
  }
  if {[gets $fp1 OrderFile] < 0} {
    puts stderr "Error reading system.dat -- short file (OrderFile)!"
    exit 5
  }
  if {[gets $fp1 OwnerFile] < 0} {
    puts stderr "Error reading system.dat -- short file (OwnerFile)!"
    exit 6
  }
  if {[gets $fp1 CarTypesFile] < 0} {
    puts stderr "Error reading system.dat -- short file (CarTypesFile)!"
    exit 7
  }
  if {[gets $fp1 CarsFile] < 0} {
    puts stderr "Error reading system.dat -- short file (CarsFile)!"
    exit 8
  }
  if {[gets $fp1 StatsFile] < 0} {
    puts stderr "Error reading system.dat -- short file (StatsFile)!"
    exit 9
  }
  [SN LogWindow] insert end "$RailSystem\n\n"
  [SN LogWindow] insert end "Industry file   = $IndusFile"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] 40
  [SN LogWindow] insert end "Trains file     = $TrainFile\n"
  [SN LogWindow] insert end "Orders file     = $OrderFile"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] 40
  [SN LogWindow] insert end "Owners file     = $OwnerFile\n"
  [SN LogWindow] insert end "Car Types file  = $CarTypesFile"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] 40
  [SN LogWindow] insert end "Cars file       = $CarsFile\n"
  [SN LogWindow] insert end "\n"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  [SN LogWindow] see end
#============================================================================
#
# Read divisions from the SysFile
#
#============================================================================
  global TotalDivisions
  global DivsSymbol
  global DivsHome
  global DivsArea
  global DivsName
  set TotalDivisions [ReadGroupLimit $fp1 "DIVISIONS"]
# Allocate memory for divisions, and read in definitions
#
#    Basically, a division has a numeric identifier, a symbolic name, and
#    a "home" -- which can be a YARD or an INDUSTRY.
#
#    The purpose of a division is that cars destined for industries are
#    routed --> to the industry's station --> to the station's division
#    --> to the division's home. It's just a way of clumping industries
#    together into a logical unit.
#
#    #          Numeric identifier
#    Symbol     Symbolic alphanumeric identifier (A-Z a-z 0-9)
#    Home       Numeric Home yard of the division
#    Area       Symbolic alphanumeric Area identifier
#    Name       Text name of the division
  for {set Dx 1} {$Dx <= $TotalDivisions} {incr Dx} {
    set DivsSymbol($Dx) {}
    set DivsHome($Dx) 0
    set DivsArea($Dx) {}
    set DivsName($Dx) {}
  }
  set Tenth [expr 10.0 / double($TotalDivisions)]
  WIP 0 {0% Done}
  set Done 0
  for {set Gx 1} {$Gx <= $TotalDivisions} {incr Gx} {
    if {[expr $Gx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Gx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {[SkipCommentsGets $fp1 line] < 0} {
      puts stderr "Error reading system.dat -- short file (Divisions)!"
      exit 10
    }
    if {$line == -1} {break}
    set vlist [split $line $COMMA]
    if {[llength $vlist] != 5} {
      ErrorDivisionFormat "$line"
    }
    set Dx [string trim [lindex $vlist 0]]
    if {$Dx < 1 || $Dx > $TotalDivisions} {
      ErrorBadDataOrder $TotalDivisions DIVISIONS
    }
    if {![catch "set DivsName($Dx)" val]} {
      if {[string trim $val] != {}} {
	ErrorDivisionDuplicate $val
      }
    }
    set DivsSymbol($Dx) [lindex $vlist 1]
    set DivsHome($Dx) [string trim [lindex $vlist 2]]
    set DivsArea($Dx) [lindex $vlist 3]
    set DivsName($Dx) [lindex $vlist 4]
#    puts stderr "Division $Dx: $DivsSymbol($Dx)$COMMA$DivsHome($Dx)$COMMA$DivsArea($Dx)$COMMA$DivsName($Dx)"
  }
  WIP 100 {100% Done}
  global TotalStations
  global StnsName
  global StnsDiv
  global StnsIndus
  global DivsStns
#============================================================================
#
# Read stations from the SysFile
#
#============================================================================
  set TotalStations [ReadGroupLimit $fp1 "STATIONS"]
# Allocate memory for stations, and read in definitions
#
#    Basically, a station has a symbolic name, and is based in a "division".
#    This means that freight cars destined for an industry at this station
#    are usually routed to the "division yard" (see below) first. Then the
#    wayfreight (or boxmove) takes the car from the yard to the station and
#    then to the industry.
#
#    Note you are free to create several "stations" with the same name, and
#    yet with different "divisions". The purpose of this flexibility is to
#    allow you to serve industries on your layout in a flexible manner - so
#    the same physical "layout station" may be represented by several of the
#    "logical stations" in the database.
#
#    Another trick is to define "trailing point" sidings in one direction as
#    one station, and then trailing point sidings in the opposite direction
#    as another station (with the same name, I mean). Then an "out and back"
#    wayfreight can then be set up to serve only trailing point sidings, as
#    it travels out, turns, and returns thru the same area.
  for {set Sx 1} {$Sx <= $TotalStations} {incr Sx} {
    set StnsName($Sx) {}
    set StnsDiv($Sx) 0
    set StnsIndus($Sx) {}
  }
  set Tenth [expr 10.0 / double($TotalStations)]
  WIP 0 {0% Done}
  set Done 0
  set StnsName(0) {NOPLACE}
  for {set Gx 1} {$Gx <= $TotalStations} {incr Gx} {
    if {[expr $Gx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Gx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {[SkipCommentsGets $fp1 line] < 0} {
      puts stderr "Error reading system.dat -- short file (Divisions)!"
      exit 10
    }
    if {$line == -1} {break}
    set vlist [split $line $COMMA]
    if {[llength $vlist] != 4} {
      ErrorStationFormat "$line"
    }
    set Sx [string trim [lindex $vlist 0]]
    if {$Sx < 1 || $Sx > $TotalStations} {
      ErrorBadDataOrder $TotalStations STATIONS
    }
    if {![catch "set StnsName($Sx)" val]} {
      if {[string trim $val] != {}} {
	ErrorStationDuplicate $val
      }
    }
    set StnsName($Sx) "[lindex $vlist 1]"
    set StnsDiv($Sx) [string trim [lindex $vlist 2]]
    set D $StnsDiv($Sx)
    if {[catch "set DivsStns($D)"]} {set DivsStns($D) {}}
    lappend DivsStns($D) $Sx
    set StnComment [lindex $vlist 3]
#    puts stderr "Station: $StnsName($Sx) ..comment.. $StnComment"
  }
  WIP 100 {100% Done}
  close $fp1
#============================================================================
#
# Read trains from the SysFile
#
#============================================================================
  if {[catch [list open "$TrainFile" r] fp1]} {
    puts stderr "Error opening $TrainFile: $fp1"
    exit 11
  }
  global TotalTrains
  set TotalTrains [ReadGroupLimit $fp1 "TRAINS"]
# Allocate memory for trains, and read in definitions
#
#    TrnType        "M"anifest "W"ayfreight "P"assenger "B"oxmove
#    TrnShift       shift number 1 or 2 or 3
#    TrnDone        "N" means cars "Car Done" is not set by move in train
#    TrnName$       symbolic name of the train
#    TrnMxCars      maximum number of cars in the train at once
#    TrnDivList$    "forwarding list" of divisions (MANIFESTS)
#    TrnStops       stops (industries, or stations)
#    TrnOnDuty      scheduled time of start
#    TrnPrint()     "P" means print the train order, else not
#    TrnMxClear     maximum clearance plate of cars in this train
#    TrnMxWeigh     maximum weight class of cars in this train
#    TrnCarTypes$   which car types are allowed in the train
#    TrnMxLen       maximum length of the train in feet
#    TrnDesc$       one line text description for train orders printout
  global TrnType
  global TrnShift
  global TrnDone
  global TrnName
  global TrnMxCars
  global TrnDivList
  global TrnStops
  global TrnOnDuty
  global TrnPrint
  global TrnMxClear
  global TrnMxWeigh
  global TrnCarTypes
  global TrnMxLen
  global TrnDesc
  global TrnIndex
  global MaxTrainStops
# These are the text lines for train orders from OrderFile
  global TrnOrdLen
  global TrnOrder
  set Tenth [expr 10.0 / double($TotalTrains)]
  WIP 0 {0% Done}
  set Done 0

  for {set Gx 1} {$Gx <= $TotalTrains} {incr Gx} {
    if {[expr $Gx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Gx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
  
    if {[SkipCommentsGets $fp1 line] < 0} {
      puts stderr "Error reading $TrainFile -- short file (Trains)!"
      exit 12
    }
    if {$line == -1} {break}
    set vlist [split $line $COMMA]
    while {[llength $vlist] < 14} {
      if {[SkipCommentsGets $fp1 line1] < 0} {
      	puts stderr "Error reading $TrainFile -- short file (Trains)!"
      	exit 10
      }
      set line "$line [string trim $line1]"
      set vlist [split $line $COMMA]
    }
    if {[llength $vlist] != 14} {
      ErrorTrainFormat "$line"
    }
#    puts stderr "*** line = '$line'"
#    puts stderr "*** vlist = \{$vlist\}"
    set Tx [string trim [lindex $vlist 0]]
#    puts stderr "*** Tx (1) = $Tx"
    set Tx [string trimleft $Tx {0}]
#    puts stderr "*** Tx (2) = $Tx"
    if {"$Tx" == {}} {set Tx 0}
#    puts stderr "*** Tx (3) = $Tx"
    if {$Tx < 1 || $Tx > $TotalTrains} {
      ErrorBadDataOrder $TotalTrains TRAINS
    }
    if {![catch "set TrnName($Tx)" val]} {
      if {[string trim $val] != {}} {
	ErrorTrainDuplicate $val
      }
    }
    set TrnType($Tx) "[lindex $vlist 1]"
    set TrnShift($Tx) [string trim [lindex $vlist 2]]
    set TrnDone($Tx) "[lindex $vlist 3]"
    set TrnName($Tx) "[string trim [lindex $vlist 4]]"
    set TrnIndex($TrnName($Tx)) $Tx
    set TrnMxCars($Tx) "[string trim [lindex $vlist 5]]"
    set TrnDivList($Tx) "[lindex $vlist 6]"
    set stops [split [string trim [lindex $vlist 7]] { }]
#    puts stderr "*** stops = $stops"
    for {set Px 1} {$Px <= $MaxTrainStops} {incr Px} {
      set TrnStops($Tx,$Px) "[string trim [lindex $stops [expr $Px - 1]]]"
    }
    set TrnOnDuty($Tx) "[lindex $vlist 8]"
    set TrnPrint($Tx) "[lindex $vlist 9]"
    set TrnMxClear($Tx) "[string trim [lindex $vlist 10]]"
    set TrnMxWeigh($Tx) "[string trim [lindex $vlist 11]]"
    set x1 "[split [string trim [lindex $vlist 12]]]"
#    puts stderr "*** x1 = $x1"
    if {[llength $x1] == 1} {
      set TrnCarTypes($Tx) {}
      set TrnMxLen($Tx) "[string trim [lindex $vlist 12]]"
    } else {
      set TrnCarTypes($Tx) "[string trim [lindex $x1 0]]"
      set TrnMxLen($Tx) "[string trim [lindex $x1 1]]"
    }
    set TrnDesc($Tx) "[lindex $vlist 13]"
#    puts stderr "Read Train Name: $TrnName($Tx)"
#    puts stderr "       Div List: $TrnDivList($Tx)"
#    puts stderr "          Print: $TrnPrint($Tx)"
#    puts stderr "      Car Types: $TrnCarTypes($Tx)"
#    puts stderr "        Max Len: $TrnMxLen($Tx)"
#    puts stderr "    Description: $TrnDesc($Tx)"
    set TrnOrdLen($Tx) 0
  }
  WIP 100 {100% Done}
  close $fp1
#============================================================================
#
# Read industries from the SysFile
#
#============================================================================
  if {[catch [list open "$IndusFile" r] fp1]} {
    puts stderr "Error opening $IndusFile: $fp1"
    exit 21
  }
  global TotalIndustries
  set TotalIndustries [ReadGroupLimit $fp1 "INDUSTRIES"]
# Allocate memory for industries, and read in definitions
#
#   IndsType        type of location
#
#                      "Y"   Yard
#                      "S"   Stage
#                      "I"   Industry Online
#                      "O"   Industry Offline
#
#   IndsStation     station location of this yard or industry
#   IndsName        symbolic name (may be duplicated)
#   IndsTrackLen    physical track space available
#
#   IndsAssignLen   assignable length -- the combined length of all the cars
#                     destinated for an industry at one time - often larger
#                     than TrackLen
#
#   IndsPriority    priority of car assignment to this industry -- 1 is the
#                     highest priority, while MaxPriority is the lowest --
#                     this assures car supply to more important customers
#
#   IndsReload      "Y" means cars delivered as loads, may leave as loads --
#                     provided the industry accepts the car type as empty
#
#   IndsMirror      the identity of the industry that "mirrors" this one --
#                     a car delivered to this industry will be "relocated"
#                     immediately to the "mirror" location
#
#                     Typical mirrors: power plant --> coal mine (loads)
#                                      coal mine --> power plant (empties)
#
#   IndsPlate       maximum clearance plate of cars for this industry
#   IndsClass       maximum weight class of cars for this industry
#   IndsDivList     where this industry will ship its loads
#   IndsCarLen      maximum car length of cars for this industry
#   IndsLoadTypes   what CarTypes are accepted as loads
#   IndsEmptyTypes  what CarTypes are accepted as empties
  global IndsType
  global IndsStation
  global StnsIndus
  global IndsName
  global IndsTrackLen
  global IndsAssignLen
  global IndsPriority
  global IndsReload
  global IndsMirror
  global IndsPlate
  global IndsClass
  global IndsDivList
  global IndsCarLen
  global IndsLoadTypes
  global IndsEmptyTypes
  global IndsCarsIndexes
# Industry statistics
#
#   IndsCarsNum     number of cars delivered to industry
#   IndsCarsLen     length of all cars delivered to industry
#   IndsStatsLen    sum of track length over stats period
  global IndsCarsNum
  global IndsCarsLen
  global IndsStatsLen
# These are temporary arrays used in assignment & routing
  global IndsUsedLen
  global IndsRemLen
  set Tenth [expr 10.0 / double($TotalIndustries)]
  WIP 0 {0% Done}
  set Done 0
  for {set Gx 1} {$Gx <= $TotalIndustries} {incr Gx} {
    if {[expr $Gx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Gx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
  
    if {[SkipCommentsGets $fp1 line] < 0} {
      puts stderr "Error reading $IndusFile -- short file (Industries)!"
      exit 22
    }
    if {$line == -1} {break}
    set vlist [split $line $COMMA]
    while {[llength $vlist] < 16} {
      if {[SkipCommentsGets $fp1 line1] < 0} {
      	puts stderr "Error reading $IndusFile -- short file (Industries)!"
      	exit 10
      }
      set line "$line,[string trim $line1]"
      set vlist [split $line $COMMA]
    }
    if {[llength $vlist] != 16} {
      ErrorIndustryFormat "$line"
    }
    set Ix  [string trim [lindex $vlist 0]]
    if {$Ix < 0 || $Ix > $TotalIndustries} {
      ErrorBadDataOrder $TotalIndustries INDUSTRIES
    }
    if {![catch "set IndsName($Ix)" val]} {
      if {[string trim $val] != {}} {   
	ErrorIndustryDuplicate $val
      }
    }
    set IndsType($Ix)      [string toupper [lindex $vlist 1]]
    set IndsStation($Ix)   [string trim [lindex $vlist 2]]
    lappend StnsIndus($IndsStation($Ix)) $Ix
    set IndsName($Ix)      "[string trim [lindex $vlist 3]]"
    set IndsTrackLen($Ix)  [string trim [lindex $vlist 4]]
    set IndsAssignLen($Ix) [string trim [lindex $vlist 5]]
    set IndsPriority($Ix)  [string trim [lindex $vlist 6]]
    set IndsReload($Ix)    "[string toupper [lindex $vlist 7]]"
    set IndsHazard($Ix)    "[string toupper [string trim [lindex $vlist 8]]]"
    set IndsMirror($Ix)    [string trim [lindex $vlist 9]]
    set IndsPlate($Ix)     [string trim [lindex $vlist 10]]
    set IndsClass($Ix)     [string trim [lindex $vlist 11]]
    set IndsDivList($Ix)   [string trim [lindex $vlist 12]]
    set IndsCarLen($Ix)    [string trim [lindex $vlist 13]]
    set IndsLoadTypes($Ix) [string trim [lindex $vlist 14]]
    set IndsEmptyTypes($Ix) [string trim [lindex $vlist 15]]
    set IndsCarsIndexes($Ix) {}
#    if {"$IndsName($Ix)" != {}} {
#      puts stderr "Read Industry: $IndsName($Ix)"
#      puts stderr "  Max car len: $IndsCarLen($Ix)"
#      puts stderr "   Load types: $IndsLoadTypes($Ix)"
#      puts stderr "  Empty types: $IndsEmptyTypes($Ix)"
#    }
  }
  WIP 100 {100% Done}
  close $fp1
#============================================================================
#
# SANITY CHECK -- make sure the Industry-->Station-->Division-->Industry
#                 loop of pointers or references are consistent. This is
#                 to save a whole lot of grief if they are not!
#
#============================================================================

  WIP_Start "SANITY CHECK..."
  WIP 0 {0% Done}
  for {set Dx 1} {$Dx <= $TotalDivisions} {incr Dx} {
    if {$DivsHome($Dx) != 0} {
      if {$DivsHome($Dx) > $TotalIndustries} {
	puts stderr "\nDivision definition error $DivsName($Dx)"
	puts stderr   " --> #$Dx has an out of range home\n"
	ErrorBadInputFile
      }
      if {"$IndsType($DivsHome($Dx))" != "Y"} {
	puts stderr "\nDivision ($Dx) $DivsName($Dx) has invalid Home Yard ($DivsHome($Dx))\n"
	ErrorBadInputFile
      }
    }
  }
  [SN WIP_Message] configure -text "[[SN WIP_Message] cget -text]Divisions..."
  WIP 33 {33% Done}
  for {set Sx 1} {$Sx <= $TotalStations} {incr Sx} {
    if {"$StnsName($Sx)" != {} && $StnsDiv($Sx) != 0} {
      if {$StnsDiv($Sx) > $TotalDivisions} {
	puts stderr "\nStation definition error $StnsName($Sx)"
	puts stderr   " --> # $Sx has an out of range division\n"
	ErrorBadInputFile
      }
      if {$DivsHome($StnsDiv($Sx)) == 0} {
	puts stderr "\nStation: $StnsName($Sx)'s division $StnsDiv($Sx) has no home yard\n"
	ErrorBadInputFile
      }
    }
  }
  [SN WIP_Message] configure -text "[[SN WIP_Message] cget -text]Stations..."
  WIP 66 {66% Done}
  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    if {[catch "set IndsStation($Ix)" val]} {
      set IndsStation($Ix) 0
      continue
    }
    if {$IndsStation($Ix) != 0} {
      if {$IndsStation($Ix) > $TotalStations} {
	puts stderr "\nIndustry ($Ix) $IndsName($Ix) has out of range station = "
	puts stderr   "$IndsStation($Ix)\n"
	ErrorBadInputFile
      }
    } 
  }
  [SN WIP_Message] configure -text "[[SN WIP_Message] cget -text]Industries"
  WIP 100 {100% Done}
#============================================================================
#
# Read train orders from the OrderFile
#
#============================================================================
  WIP_Start "Reading train orders"
  WIP 0 {0% Done}
  if {[catch [list open "$OrderFile" r] fp2]} {
    puts stderr "Error opening $OrderFile: $fp2"
    exit 31
  }
  while {[SkipCommentsGets $fp2 line] >= 0} {
    set vlist [split [string trim "$line"] $COMMA]
    set Train "[lindex $vlist 0]"
    set Order "[lindex $vlist 1]"
    if {![catch "set TrnIndex($Train)" Tx]} {
      set TrnOrder($Tx,[expr $TrnOrdLen($Tx) + 1]) "$Order"
      incr TrnOrdLen($Tx)
#      puts stderr "$Train,$Order"
    }
  }
  WIP 100 {100% Done}
  close $fp2
#============================================================================
#
# Read car types from the TypesFile
#
#============================================================================
  WIP_Start "Reading the Car Types file"
  WIP 0 {0% Done}
  if {[catch [list open "$CarTypesFile" r] fp3]} {
    puts stderr "Error opening $CarTypesFile: $fp3"
    exit 41
  }
  global MaxCarTypes
  global CarTypes
  global CarTypeGroup
  global CarTypeComment
  global CarTypesOrder
  set CarTypes(NULL) "Unspecified Type"
  for {set Gx 1} {$Gx <= $MaxCarTypes} {incr Gx} {
    set CarTypesOrder($Gx) {,}
  }
  set Tenth [expr 10.0 / 91.0]
  set Done 0
  for {set CarTypeCount 0} {$CarTypeCount < 91} {} {
    if {[expr $CarTypeCount * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $CarTypeCount * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {[SkipCommentsGets $fp3 line] < 0} {
      ErrorCarTypesFileShort
    }
    set vlist "[split $line $COMMA]"
    set CarTypeSymbol "[lindex $vlist 0]"
    if {![catch "set CarTypes($CarTypeSymbol)" val]} {
      ErrorCarTypesFileDuplicate
    }
    set CarTypeGroup($CarTypeSymbol) "[lindex $vlist 1]"
    set CarTypes($CarTypeSymbol) "[lindex $vlist 2]"
    set Pad "[string trim [lindex $vlist 3]]"
    set CarTypeComment($CarTypeSymbol) "[string trim [lindex $vlist 4]]"
    incr CarTypeCount
    set CarTypesOrder($CarTypeCount) "$CarTypeSymbol"
#    puts stderr "Car type symbol $CarTypeSymbol"
#    puts stderr "   group       = $CarTypeGroup($CarTypeSymbol)"
#    puts stderr "   pad         = $Pad"
#    puts stderr "   description = $CarTypes($CarTypeSymbol)"
#    puts stderr "   comment     = $CarTypeComment($CarTypeSymbol)"
#    puts stderr $CarTypeCount
  }
  WIP 100 {100% Done}
  global MaxCarGroup
  global CarGroup
  global CarGroupDesc
  set Tenth [expr 10.0 / $MaxCarGroup]
  set Done 0
  WIP_Start "Reading Car Groups"
  WIP 0 {0% Done}
  for {set CarGroupCount 0} {$CarGroupCount < $MaxCarGroup} {} {
    if {[expr $CarGroupCount * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $CarGroupCount * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {[SkipCommentsGets $fp3 line] < 0} {break}
    set vlist "[split $line $COMMA]"
    set CarGroupSymbol "[lindex $vlist 0]"
    incr CarGroupCount
    set CarGroup($CarGroupCount) "[lindex $vlist 0]"
    set CarGroupDesc($CarGroupCount) "[lindex $vlist 1]"
#    puts stderr "Car group symbol = $CarGroupSymbol"
#    puts stderr "     description = $CarGroupDesc($CarGroupCount)"
#    puts stderr "     group count = $CarGroupCount"
  }
  WIP 100 {100% Done}
  close $fp3
#============================================================================
#
# Read owners from the OwnerFile
#
#============================================================================
  WIP_Start "Reading the Owners file"
  if {[catch [list open "$OwnerFile" r] fp5]} {
    puts stderr "Error opening $OwnerFile: $fp5"
    exit 51
  }
  global TotalOwners
  global OwnerInitials
  global OwnerNames
  if {[SkipCommentsGets $fp5 line] < 0} {
    ErrorBadOwnerFile
  }
  set TotalOwners [string trim $line]
  set Tenth [expr 10.0 / $TotalOwners]
  set Done 0
  WIP 0 {0% Done}
  for {set Ox 1} {$Ox <= $TotalOwners} {incr Ox} {
    set OwnerInitials($Ox) {}
  }
  global OwnerCount
  set OwnerCount 0
  while {[SkipCommentsGets $fp5 line] >= 0} {
    incr OwnerCount
    if {[expr $OwnerCount * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $OwnerCount * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    set vlist [split $line $COMMA]
    set OwnerInitials($OwnerCount) "[string toupper [lindex $vlist 0]]"
    AddCarOwnerToMenu "$OwnerInitials($OwnerCount)" $OwnerCount
    set OwnerNames($OwnerCount) "[lindex $vlist 1]"
    set OwnComment "[lindex $vlist 2]"
  }
  close $fp5
  WIP 100 {100% Done}
  set TotalOwners $OwnerCount
}

proc ErrorBadInputFile {} {
  exit 999
}

proc ErrorBadDataOrder {Total what} {
  puts stderr "*** Error $what out of range ($Total)"
  exit 997
}

proc ErrorDivisionFormat {line} {
  puts stderr "*** Error Division format error: $line"
  exit 996
}

proc ErrorDivisionDuplicate {dupl} {
  puts stderr "*** Error duplicate Division: $dupl"
  exit 995
}

proc ErrorStationFormat {line} {
  puts stderr "*** Error Station format error: $line"
  exit 994
}

proc ErrorStationDuplicate {dupl} {
  puts stderr "*** Error duplicate Station: $dupl"
  exit 993
}

proc ErrorTrainFormat {line} {
  puts stderr "*** Error Train format error: $line"
  exit 992
}

proc ErrorTrainDuplicate {dupl} {
  puts stderr "*** Error duplicate Train: $dupl"
  exit 991
}

proc ErrorIndustryFormat {line} {
  puts stderr "*** Error Industry format error: $line"
  exit 990
}

proc ErrorIndustryDuplicate {dupl} {
  puts stderr "*** Error duplicate Industry: $dupl"
  exit 989
}

proc ErrorCarTypesFileShort {} {
  exit 988
}

proc ErrorCarTypesFileDuplicate {} {
  exit 987
}

proc ErrorBadOwnerFile {} {
  exit 986
}

proc ErrorBadDataGroup {lab what} {
  puts stderr "*** Bad data group: $lab, $what"
  exit 985
}

proc ErrorBadCarsFile {what} {
  puts stderr "*** Bad Cars File: $what"
  exit 984
}

# Procedure: ManagePrintTrains
proc ManagePrintTrains {} {
  # build widget .managePrintTrains
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .managePrintTrains"
  } {
    catch "destroy .managePrintTrains"
  }
  toplevel .managePrintTrains   -relief {raised}

  # Window manager configurations
  global tk_version
  wm maxsize .managePrintTrains 1009 738
  wm minsize .managePrintTrains 1 1
  wm title .managePrintTrains {Manage Printing And Trains}


  # build widget .managePrintTrains.button3
  button .managePrintTrains.button3  \
	-padx {9}  -pady {3}  -text {Control Yard Lists}  \
	-command {ManagePrintYard;grab .managePrintTrains}

  # build widget .managePrintTrains.button4
  button .managePrintTrains.button4  -padx {9}  -pady {3}  \
	-text {Print All Trains}  \
	-command {
	  global TotalTrains
	  global TrnPrint
	  global TrnType
	  global Printem
	  set Printem 1
	  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
	    if {![catch "set TrnType($Tx)" type]} {
	      if {"$type" != "B"} {set TrnPrint($Tx) P}
	    }
	  }
	}

  # build widget .managePrintTrains.button5
  button .managePrintTrains.button5  -padx {9}  -pady {3}  \
	-text {Print No Trains}  \
	-command {
	  global TotalTrains
	  global TrnPrint
	  global Printem
	  global PrintAlpha
	  global PrintATwice
	  global PrintList
	  global PrintLTwice
	  global PrintDispatch
	  set Printem 0
	  set PrintAlpha 0
	  set PrintATwice 0
	  set PrintList 0
	  set PrintLTwice 0
	  set PrintDispatch 0
	  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
	    set TrnPrint($Tx) N
	  }
	}
  global PrintDispatch
  # build widget .managePrintTrains.button6
  checkbutton .managePrintTrains.button6  -padx {9}  -pady {3} \
	-text {Print Dispatcher Report}  \
	-offvalue 0 -onvalue 1 -relief {raised} \
	-variable PrintDispatch

  # build widget .managePrintTrains.button7
  button .managePrintTrains.button7  -padx {9}  -pady {3}  \
	-text {List Trains} \
	-command {ListTrains;grab .managePrintTrains}

  # build widget .managePrintTrains.button8
  button .managePrintTrains.button8  -padx {9}  -pady {3}  -text {Exit (return to main menu)}  -command  {if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .managePrintTrains"
  } {
    catch "destroy .managePrintTrains"
  }}

  # build widget .managePrintTrains.frame9
  frame .managePrintTrains.frame9  -borderwidth {2}

  # build widget .managePrintTrains.frame9.label10
  label .managePrintTrains.frame9.label10  -relief {flat}  -text {Enter Train Name to manage}

  # build widget .managePrintTrains.frame9.entry11
  entry .managePrintTrains.frame9.entry11
  bind .managePrintTrains.frame9.entry11 <Return> {ManageOneTrain [%W get];grab .managePrintTrains}

  # build widget .managePrintTrains.frame10
  frame .managePrintTrains.frame10 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .managePrintTrains.frame10.frame1
  frame .managePrintTrains.frame10.frame1 \
    -borderwidth {2}

  global PrinterType
  # build widget .managePrintTrains.frame10.frame1.label3
  label .managePrintTrains.frame10.frame1.label3 \
    -text "$PrinterType"

  # build widget .managePrintTrains.frame10.frame1.label4
  label .managePrintTrains.frame10.frame1.label4 \
    -text {Printer is}

  global Printer
  if {"$Printer" == {}} {
    set openClose "Closed"
  } else {
    set openClose "Open"
  }
  # build widget .managePrintTrains.frame10.frame1.label5
  label .managePrintTrains.frame10.frame1.label5 \
    -text "$openClose"

  # build widget .managePrintTrains.frame10.frame2
  frame .managePrintTrains.frame10.frame2 \
    -borderwidth {2}

  # build widget .managePrintTrains.frame10.frame2.button6
  button .managePrintTrains.frame10.frame2.button6 \
    -command {
	OpenPrinter
	global PrinterType
	.managePrintTrains.frame10.frame1.label3 configure -text "$PrinterType"
	global Printer
	if {"$Printer" == {}} { 
	  set openClose "Closed"
	} else {
	  set openClose "Open"
	}
	.managePrintTrains.frame10.frame1.label5 configure -text "$openClose"
    } \
    -padx {9} \
    -pady {3} \
    -text {Open Printer}

  # build widget .managePrintTrains.frame10.frame2.button7
  button .managePrintTrains.frame10.frame2.button7 \
    -command {
	ClosePrinter
	global PrinterType
	.managePrintTrains.frame10.frame1.label3 configure -text "$PrinterType"
	global Printer
	if {"$Printer" == {}} { 
	  set openClose "Closed"
	} else {
	  set openClose "Open"
	}
	.managePrintTrains.frame10.frame1.label5 configure -text "$openClose"
    } \
    -padx {9} \
    -pady {3} \
    -text {Close Printer}
 


  # pack master .managePrintTrains.frame9
  pack configure .managePrintTrains.frame9.label10  -side left
  pack configure .managePrintTrains.frame9.entry11  -expand 1  -fill x  -side left

  # pack master .managePrintTrains.frame10.frame1
  pack configure .managePrintTrains.frame10.frame1.label3 \
    -expand 1 \
    -fill x \
    -side left
  pack configure .managePrintTrains.frame10.frame1.label4 \
    -side left
  pack configure .managePrintTrains.frame10.frame1.label5 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side left

  # pack master .managePrintTrains.frame10.frame2
  pack configure .managePrintTrains.frame10.frame2.button6 \
    -expand 1 \
    -side left
  pack configure .managePrintTrains.frame10.frame2.button7 \
    -expand 1 \
    -side left

  # pack master .managePrintTrains.frame10
  pack configure .managePrintTrains.frame10.frame1 \
    -fill x
  pack configure .managePrintTrains.frame10.frame2 \
    -fill x

  # pack master .managePrintTrains
  pack configure .managePrintTrains.button3  -anchor w  -expand 1  -fill x
  pack configure .managePrintTrains.button4  -expand 1  -fill x
  pack configure .managePrintTrains.button5  -expand 1  -fill x
  pack configure .managePrintTrains.button6  -expand 1  -fill x
  pack configure .managePrintTrains.button7  -expand 1  -fill x
  pack configure .managePrintTrains.button8  -expand 1  -fill x
  pack configure .managePrintTrains.frame9  -expand 1  -fill x
  pack configure .managePrintTrains.frame10 -expand 1  -fill x

  .managePrintTrains.frame9.entry11 insert end {}

  update idletasks
  grab .managePrintTrains
  tkwait window .managePrintTrains
}


# Procedure: ManagePrintYard
proc ManagePrintYard {} {

  global PrintAlphaButton
  set PrintAlphaButton 0
  global PrintATwiceButton
  set PrintATwiceButton 0
  global PrintListButton
  set PrintListButton 0
  global PrintLTwiceButton
  set PrintLTwiceButton 0

  # build widget .yardPrintDialog
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .yardPrintDialog"
  } {
    catch "destroy .yardPrintDialog"
  }
  toplevel .yardPrintDialog 

  # Window manager configurations
  global tk_version
  wm positionfrom .yardPrintDialog ""
  wm sizefrom .yardPrintDialog ""
  wm maxsize .yardPrintDialog 1009 738
  wm minsize .yardPrintDialog 1 1
  wm title .yardPrintDialog {Yard Print Dialog}


  # build widget .yardPrintDialog.frame1
  frame .yardPrintDialog.frame1  -borderwidth {2}  -relief {ridge}

  # build widget .yardPrintDialog.frame1.label4
  label .yardPrintDialog.frame1.label4  -anchor {w}  -text {Alphabetical Listing?}

  # build widget .yardPrintDialog.frame1.frame5
  frame .yardPrintDialog.frame1.frame5  -borderwidth {2}

  # build widget .yardPrintDialog.frame1.frame5.radiobutton7
  radiobutton .yardPrintDialog.frame1.frame5.radiobutton7  -text {Yes}  -value {1}  -variable {PrintAlphaButton}

  # build widget .yardPrintDialog.frame1.frame5.radiobutton8
  radiobutton .yardPrintDialog.frame1.frame5.radiobutton8  -text {No}  -value {0}  -variable {PrintAlphaButton}

  # build widget .yardPrintDialog.frame1.frame6
  frame .yardPrintDialog.frame1.frame6  -borderwidth {2}

  # build widget .yardPrintDialog.frame1.frame6.radiobutton9
  radiobutton .yardPrintDialog.frame1.frame6.radiobutton9  -text {Print One Copy}  -value {0}  -variable {PrintATwiceButton}

  # build widget .yardPrintDialog.frame1.frame6.radiobutton10
  radiobutton .yardPrintDialog.frame1.frame6.radiobutton10  -text {Print Two Copies}  -value {1}  -variable {PrintATwiceButton}

  # build widget .yardPrintDialog.frame2
  frame .yardPrintDialog.frame2  -borderwidth {2}  -relief {ridge}

  # build widget .yardPrintDialog.frame2.label11
  label .yardPrintDialog.frame2.label11  -anchor {w}  -text {List by Train?}

  # build widget .yardPrintDialog.frame2.frame12
  frame .yardPrintDialog.frame2.frame12  -borderwidth {2}

  # build widget .yardPrintDialog.frame2.frame12.radiobutton14
  radiobutton .yardPrintDialog.frame2.frame12.radiobutton14  -text {Yes}  -value {1}  -variable {PrintListButton}

  # build widget .yardPrintDialog.frame2.frame12.radiobutton15
  radiobutton .yardPrintDialog.frame2.frame12.radiobutton15  -text {No}  -value {0}  -variable {PrintListButton}

  # build widget .yardPrintDialog.frame2.frame13
  frame .yardPrintDialog.frame2.frame13  -borderwidth {2}

  # build widget .yardPrintDialog.frame2.frame13.radiobutton16
  radiobutton .yardPrintDialog.frame2.frame13.radiobutton16  -text {Print One Copy}  -value {0}  -variable {PrintLTwiceButton}

  # build widget .yardPrintDialog.frame2.frame13.radiobutton17
  radiobutton .yardPrintDialog.frame2.frame13.radiobutton17  -text {Print Two Copies}  -value {1}  -variable {PrintLTwiceButton}

  # build widget .yardPrintDialog.frame3
  frame .yardPrintDialog.frame3  -borderwidth {2}

  # build widget .yardPrintDialog.frame3.button18
  button .yardPrintDialog.frame3.button18  -text {Apply}  -command {
	global PrintAlpha
	set PrintAlpha $PrintAlphaButton
	global PrintAtwice
	set PrintAtwice $PrintATwiceButton
	global PrintList
	set PrintList $PrintListButton
	global PrintLtwice
	set PrintLtwice $PrintLTwiceButton
	if {"[info procs XFEdit]" != ""} {
	  catch "XFDestroy .yardPrintDialog"
	} {
	  catch "destroy .yardPrintDialog"
	}
  }
  

  # build widget .yardPrintDialog.frame3.button19
  button .yardPrintDialog.frame3.button19  -text {Cancel}  -command {
	if {"[info procs XFEdit]" != ""} {
	  catch "XFDestroy .yardPrintDialog"
	} {
	  catch "destroy .yardPrintDialog"
	}
  }

  # pack master .yardPrintDialog.frame1
  pack configure .yardPrintDialog.frame1.label4  -expand 1  -fill x
  pack configure .yardPrintDialog.frame1.frame5  -expand 1  -fill both
  pack configure .yardPrintDialog.frame1.frame6  -expand 1  -fill both

  # pack master .yardPrintDialog.frame1.frame5
  pack configure .yardPrintDialog.frame1.frame5.radiobutton7  -anchor w  -expand 1  -side left
  pack configure .yardPrintDialog.frame1.frame5.radiobutton8  -anchor w  -expand 1  -side left

  # pack master .yardPrintDialog.frame1.frame6
  pack configure .yardPrintDialog.frame1.frame6.radiobutton9  -anchor w  -expand 1  -side left
  pack configure .yardPrintDialog.frame1.frame6.radiobutton10  -anchor w  -expand 1  -side left

  # pack master .yardPrintDialog.frame2
  pack configure .yardPrintDialog.frame2.label11  -expand 1  -fill x
  pack configure .yardPrintDialog.frame2.frame12  -fill both  -expand 1
  pack configure .yardPrintDialog.frame2.frame13  -fill both  -expand 1

  # pack master .yardPrintDialog.frame2.frame12
  pack configure .yardPrintDialog.frame2.frame12.radiobutton14  -anchor w  -expand 1  -side left
  pack configure .yardPrintDialog.frame2.frame12.radiobutton15  -anchor w  -expand 1  -side left

  # pack master .yardPrintDialog.frame2.frame13
  pack configure .yardPrintDialog.frame2.frame13.radiobutton16  -anchor w  -expand 1  -side left
  pack configure .yardPrintDialog.frame2.frame13.radiobutton17  -anchor w  -expand 1  -side left

  # pack master .yardPrintDialog.frame3
  pack configure .yardPrintDialog.frame3.button18  -expand 1  -side left
  pack configure .yardPrintDialog.frame3.button19  -expand 1  -side left

  # pack master .yardPrintDialog
  pack configure .yardPrintDialog.frame1  -expand 1  -fill both
  pack configure .yardPrintDialog.frame2  -expand 1  -fill both
  pack configure .yardPrintDialog.frame3  -expand 1  -fill both
# end of widget tree

  update idletasks
  grab .yardPrintDialog
  tkwait window .yardPrintDialog
}

# Procedure: ListTrains
proc ListTrains {} {
  ShowAvailableTrains 1
}

# Procedure: ShowAvailableTrains
proc ShowAvailableTrains {ShowAllTrains} {
  ShowBanner
  [SN LogWindow] insert end "\nList of available trains\n\n"
  set TrainCount 0
  global TotalTrains
  global TrnName
  global TrnType
  global TrnShift
  global ShiftNumber
  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
    set show 1
    if {[catch "set TrnName($Tx)" name]} {
      set show 0
    } elseif {"$name" == {}} {
      set show 0
    }
    if {[catch "set TrnType($Tx)" type]} {
      set show 0
    } elseif {"$type" == {B}} {
      set show 0
    }
    if {$show && $ShowAllTrains == 0 && $TrnShift($Tx) != $ShiftNumber} {
      set show 0
    }
    if {$show} {
      incr TrainCount
      set z [expr $TrainCount % 4]
      if {$z == 1} {
	[SN LogWindow] insert end "$TrnName($Tx)"
      } elseif {$z == 2} {
	[SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
	TabText [SN LogWindow] 21
	[SN LogWindow] insert end "$TrnName($Tx)"
      } elseif {$z == 3} {
	[SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
	TabText [SN LogWindow] 41
	[SN LogWindow] insert end "$TrnName($Tx)"
      } elseif {$z == 0} {
	[SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
	TabText [SN LogWindow] 61
	[SN LogWindow] insert end "$TrnName($Tx)\n"
      }
      set z [expr $TrainCount % 40]
      if {$z == 0} {
	[SN LogWindow] see end
	update
      }
    }
  }
  [SN LogWindow] see end
}



# Procedure: ManageOneTrain
proc ManageOneTrain {train} {
  global TrnIndex
  global TrnMxCars
  global TrnPrint
  set train "[string toupper [string trim $train]]"
  if {[catch "set TrnIndex($train)" Tx]} {
    [SN LogWindow] insert end "No such train: $train\n"
    [SN LogWindow] see end
    return
  }
  global TrnPrintButton
  set TrnPrintButton $TrnPrint($Tx)
  # build widget .manageOneTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .manageOneTrain"
  } {
    catch "destroy .manageOneTrain"
  }
  toplevel .manageOneTrain 

  # Window manager configurations
  global tk_version
  wm maxsize .manageOneTrain 1009 738
  wm minsize .manageOneTrain 1 1
  wm title .manageOneTrain "Manage train $train"


  # build widget .manageOneTrain.maxCars
  frame .manageOneTrain.maxCars \
    -borderwidth {2} \
    -relief {groove}

  # build widget .manageOneTrain.maxCars.frame4
  frame .manageOneTrain.maxCars.frame4 \
    -borderwidth {2}

  # build widget .manageOneTrain.maxCars.frame4.label6
  label .manageOneTrain.maxCars.frame4.label6 \
    -text {Current Maxcars = }

  # build widget .manageOneTrain.maxCars.frame4.label7
  label .manageOneTrain.maxCars.frame4.label7 \
    -text {New Maxcars = }

  # build widget .manageOneTrain.maxCars.values
  frame .manageOneTrain.maxCars.values \
    -borderwidth {2}

  # build widget .manageOneTrain.maxCars.values.label8
  label .manageOneTrain.maxCars.values.label8 \
    -text "$TrnMxCars($Tx)"

  # build widget .manageOneTrain.maxCars.values.newMaxcars
  entry .manageOneTrain.maxCars.values.newMaxcars

  # build widget .manageOneTrain.printTrain
  frame .manageOneTrain.printTrain \
    -borderwidth {2} \
    -relief {groove}

  # build widget .manageOneTrain.printTrain.radiobutton10
  radiobutton .manageOneTrain.printTrain.radiobutton10 \
    -text {Print Train} \
    -value {P} \
    -variable {TrnPrintButton}

  # build widget .manageOneTrain.printTrain.radiobutton11
  radiobutton .manageOneTrain.printTrain.radiobutton11 \
    -text {Do Not Print Train} \
    -value {N} \
    -variable {TrnPrintButton}

  # build widget .manageOneTrain.frame3
  frame .manageOneTrain.frame3 \
    -borderwidth {2}

  # build widget .manageOneTrain.frame3.button12
  button .manageOneTrain.frame3.button12 \
    -command "ManageOneTrainApply $Tx"\
    -padx {9} \
    -pady {3} \
    -text {Apply}

  # build widget .manageOneTrain.frame3.button13
  button .manageOneTrain.frame3.button13 \
    -command {if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .manageOneTrain"
  } {
    catch "destroy .manageOneTrain"
  }} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # pack master .manageOneTrain.maxCars
  pack configure .manageOneTrain.maxCars.frame4 \
    -side left
  pack configure .manageOneTrain.maxCars.values \
    -side right

  # pack master .manageOneTrain.maxCars.frame4
  pack configure .manageOneTrain.maxCars.frame4.label6 \
    -anchor e
  pack configure .manageOneTrain.maxCars.frame4.label7 \
    -anchor e

  # pack master .manageOneTrain.maxCars.values
  pack configure .manageOneTrain.maxCars.values.label8 \
    -anchor w
  pack configure .manageOneTrain.maxCars.values.newMaxcars \
    -anchor w

  # pack master .manageOneTrain.printTrain
  pack configure .manageOneTrain.printTrain.radiobutton10
  pack configure .manageOneTrain.printTrain.radiobutton11

  # pack master .manageOneTrain.frame3
  pack configure .manageOneTrain.frame3.button12 \
    -expand 1 \
    -side left
  pack configure .manageOneTrain.frame3.button13 \
    -expand 1 \
    -side right

  # pack master .manageOneTrain
  pack configure .manageOneTrain.maxCars \
    -fill both
  pack configure .manageOneTrain.printTrain \
    -fill both
  pack configure .manageOneTrain.frame3 \
    -fill both

  .manageOneTrain.maxCars.values.newMaxcars insert end "$TrnMxCars($Tx)"


# end of widget tree
 
  update idletasks
  grab .manageOneTrain
  tkwait window .manageOneTrain
   
}

# Procedure: ManageOneTrainApply
proc ManageOneTrainApply {Tx} {
  global TrnMxCars
  global TrnPrint
  global TrnPrintButton
  global MaxCarsInTrain
  set TrnPrint($Tx) $TrnPrintButton
  set NewMax "[string trim [.manageOneTrain.maxCars.values.newMaxcars get]]"
  if {[catch "expr int($NewMax)" x]} {set NewMax 0}\
  if {$NewMax >= 0 && $NewMax <= $MaxCarsInTrain} {
    set TrnMxCars($Tx) $NewMax
  }
  set TrnPrint($Tx) $TrnPrintButton
} 

# Procedure: Random
proc Random { {N "0.0"}} {
  global RanVar   
  set RanVar [expr int($RanVar * 4676) % 414971]
  set random [expr $RanVar / 414971.0] 
  if {$N == 0.0} {
    return $random
  } else {
    return [expr int($random * $N) + 1]
  }
}


# Procedure: Randomize
proc Randomize {} {
  global RanVar
  global tcl_version
  if {$tcl_version > 7.4} {
# if Tcl 7.5, use builting clock command.  Nice and portable
    set dtlist [split [clock format [clock seconds] -format {%y %m %d %H %M %S}] " "]
  } else {
# assumes standard UNIX "date" command is available
    set dtlist [split [exec date "+%y %m %d %H %M %S"] " "]
  }
  set sum 0
  foreach i $dtlist {
    set ii "[string trimleft $i {0}]"
    if {"$ii" == {}} {set ii 0}
    incr sum $ii
  }
  set RanVar $sum
}


# Procedure: ReLoadCarFile
proc ReLoadCarFile {} {
  LoadCarFile
  LoadStatsFile
  RestartLoop
}


# Procedure: ReadGroupLimit
proc ReadGroupLimit { fp label} {
  WIP_Start "Loading DataGroup ($label)"
  while {[gets $fp l] >= 0} {
    set equal [string first {=} $l]
    if {$equal >= 0} {
      set name [string toupper [string trim [string range "$l" 0 [expr $equal - 1]]]]
      set value [string trim [string range "$l" [expr $equal + 1] end]]
      if {[string compare $name [string toupper $label]] == 0 && $value > 0} {
	return $value
      } else {
	ErrorBadDataGroup $label "$l"
      }
    }
  }
  ErrorBadDataGroup $label "%%EOF%%"
}


# Procedure: RestartLoop
proc RestartLoop {} {
  global CarsMoved
  set CarsMoved 0
  global CarsAtDest
  set CarsAtDest 0
  global CarsNotMoved
  set CarsNotMoved 0
  global CarsMovedOnce
  set CarsMovedOnce 0
  global CarsMovedTwice
  set CarsMovedTwice 0
  global CarsMovedThree
  set CarsMovedThree 0
  global CarsMovedMore
  set CarsMovedMore 0
  global CarMovements
  set CarMovements 0
  global CarsInTransit
  set CarsInTransit 0
  global CarsAtWorkBench
  set CarsAtWorkBench 0
  global TotalCars
  global CrsLoc
  global CrsMoves
  global CrsDest
  global IndRipTrack
  WIP_Start "(Re-)Computing car counts"
  set Tenth [expr 10.0 / double($TotalCars)]
  set Done 0
  WIP 0 {0% Done}
  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    if {[expr $Cx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Cx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {$CrsLoc($Cx) == $IndRipTrack} {
      incr CarsAtWorkBench
    } else {
#      if {[catch "set CrsDest($Cx)" x]} {set CrsDest($Cx) 0}
      if {$CrsDest($Cx) == $CrsLoc($Cx)} {
	incr CarsAtDest
      } else {
	incr CarsInTransit
      }
#      if {[catch "set CrsMoves($Cx)" x]} {set CrsMoves($Cx) 0}
      incr CarMovements $CrsMoves($Cx)
      if {$CrsMoves($Cx) == 0} {incr CarsNotMoved}
      if {$CrsMoves($Cx) > 0} {incr CarsMoved}
      if {$CrsMoves($Cx) == 1} {incr CarsMovedOnce}
      if {$CrsMoves($Cx) == 2} {incr CarsMovedTwice}
      if {$CrsMoves($Cx) == 3} {incr CarsMovedThree}
      if {$CrsMoves($Cx) > 3} {incr CarsMovedMore}
    }
  }
  global CarsAtDest_CarsInTransit
  set CarsAtDest_CarsInTransit [expr $CarsAtDest + $CarsInTransit]
  WIP_Done
}


# Procedure: SaveCars
proc SaveCars {} {
#============================================================================
#
# This procedure uses 3 files to update 1 file, and create 1 backup.
#
# The result: a new car file, a backup of the original file.
  global CarsFile
  set JunkFile "junk.dat"
  set BackupFile "oldcars.dat"
  if {[catch [list open "$CarsFile" r] fp1]} {
    ErrorPopup "Error opening $CarsFile: $fp1"
    return
  }
  if {[catch [list open "$JunkFile" w] fp2]} {
    ErrorPopup "Error opening $JunkFile: $fp2"
    catch "close $fp1"
    return
  }
  if {[catch [list open "$BackupFile" w] fp3]} {
    ErrorPopup "Error opening $BackupFile: $fp3"
    catch "close $fp2"
    catch "close $fp1"
    return
  }
  global SessionNumber
  global ShiftNumber
  global TotalCars
  gets $fp1 line
  set OldSessionNumber [string trim $line]
  gets $fp1 line
  set OldShiftNumber [string trim $line]
  gets $fp1 line
  set OldTotalCars [string trim $line]
  global RanAllTrains
  if {$RanAllTrains == 0} {
    set SessionNumber $OldSessionNumber
    set ShiftNumber $OldShiftNumber
  }
  puts $fp2 " $SessionNumber"
  puts $fp2 " $ShiftNumber"
  puts $fp2 " $TotalCars"

  puts $fp3 " $OldSessionNumber"
  puts $fp3 " $OldShiftNumber"
  puts $fp3 " $OldTotalCars"

  global TotalShifts
  incr TotalShifts
  incr ShiftNumber
  if {$ShiftNumber > 3} {
    set ShiftNumber 1
    incr SessionNumber
  }

  set Cx 0
  global CrsLen
  global CrsDest
  global IndScrapYard
  WIP_Start "Writing New Cars File"
  set Tenth [expr 10.0 / double($TotalCars)]
  set Done 0
  WIP 0 {0% Done}
#      Read in the original car file's line
  while {[gets $fp1 Data] >= 0} {
#     and write it to the backup file
    puts $fp3 "$Data"
#     Comments from the old file are written to the new file
    set line "[string trim $Data]"
    if {"$line" == {} || "[string index "$line" 0]" == "'"} {
      puts $fp2 "$Data"
    } else {
#       Notice we follow the numbers of the original file
      incr Cx
      if {[expr $Cx * $Tenth] >= [expr $Done + 1]} {
	set Done [expr $Cx * $Tenth]
	set DonePer [expr $Done * 10]
	WIP $DonePer "[format {%f%% Done} $DonePer]"
	set Done [expr int($Done)]
      }
      if {$CrsLen($Cx) > 0} {
	if {$CrsDest($Cx) != $IndScrapYard} {
	  WriteOneCarToDisk $Cx $fp2
	}
      }
    }
  }
# Now write out any additional, new cars.
  for {set Cx [expr $OldTotalCars + 1]} {$Cx <= $TotalCars} {incr Cx} {
    if {[expr $Cx * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Cx * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {$CrsDest($Cx) != $IndScrapYard} {
      WriteOneCarToDisk $Cx $fp2
    }
  }
  WIP 100 {100% Done}
  close $fp3
  close $fp2
  close $fp1
# Now copy the new data onto the original file
  if {[catch [list open "$JunkFile" r] fp1]} {
    ErrorPopup "Error opening $JunkFile: $fp1"
    return
  }
  if {[catch [list open "$CarsFile" w] fp2]} {
    ErrorPopup "Error opening $CarsFile: $fp2"
    catch "close $fp1"
    return
  }
  set buffer "[read $fp1 4096]"
  while {"$buffer" != {}} {
    puts -nonewline $fp2 "$buffer"
    set buffer "[read $fp1 4096]"
  }
  close $fp1
  close $fp2
# unlink $JunkFile
  global StatsFile
# unlink $StatsFile
  if {[catch [list open "$StatsFile" w] fp6]} {
    ErrorPopup "Error opening $StatsFile: $fp6"
    return
  }
  global StatsPeriod
  global RanAllTrains
  incr StatsPeriod $RanAllTrains
  puts $fp6 " $StatsPeriod"
  global TotalIndustries
  global IndsCarsNum
  global IndsCarsLen
  global IndsStatsLen
  global IndsTrackLen
  WIP_Start "Writing New Stats file"
  set Tenth [expr 10.0 / double($TotalIndustries)]
  set Done 0
  WIP 0 {0% Done}
  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    if {[expr $Ix * $Tenth] >= [expr $Done + 1]} {
      set Done [expr $Ix * $Tenth]
      set DonePer [expr $Done * 10]
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      set Done [expr int($Done)]
    }
    if {![catch "set IndsTrackLen($Ix)" tl]} {
#      puts stderr "*** IndsTrackLen($Ix) = $tl"
      if {$tl > 0} {
        puts $fp6 "[format {%4d%3d%3d%6d} $Ix $IndsCarsNum($Ix) $IndsCarsLen($Ix) $IndsStatsLen($Ix)]"
	incr IndsStatsLen($Ix) $IndsTrackLen($Ix)
      }
    }
  }
  close $fp6
  set RanAllTrains 0
  WIP_Done
}


# Procedure: ShowBanner
proc ShowBanner {} {
  global RailSystem
  global SessionNumber
  global ShiftNumber
  [SN LogWindow] insert end "\n$RailSystem"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] 36
  [SN LogWindow] insert end " Session $SessionNumber  Shift $ShiftNumber"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] 70
  [SN LogWindow] insert end "[Today]\n\n"
  [SN LogWindow] see end
}


# Procedure: SkipCommentsGets
proc SkipCommentsGets { fp linevar} {
  upvar $linevar line
  while {[gets $fp l] >= 0} {
    if {[string length [string trim $l]] == 0 ||  [string index [string trim $l] 0] == {'}} {continue}
    set line "$l"
    return [string length "$l"]
  }
  return -1
}


# Procedure: TabText
proc TabText { text tabcol} {
  set col [lindex [split [$text index insert] {.}] 1]
  while {$col < $tabcol} {
    $text insert insert { }
    set col [lindex [split [$text index insert] {.}] 1]
  }
}


# Procedure: TextBox
proc TextBox { {textBoxMessage "Text message"} {textBoxCommand ""} {textBoxGeometry "350x150"} {textBoxTitle "Text box"} args} {
# xf ignore me 5
##########
# Procedure: TextBox
# Description: show text box
# Arguments: {textBoxMessage} - the text to display
#            {textBoxCommand} - the command to call after ok
#            {textBoxGeometry} - the geometry for the window
#            {textBoxTitle} - the title for the window
#            {args} - labels of buttons
# Returns: The number of the selected button, or nothing
# Sideeffects: none
# Notes: there exist also functions called:
#          TextBoxFile - to open and read a file automatically
#          TextBoxFd - to read from an already opened filedescriptor
##########
#
# global textBox(activeBackground) - active background color
# global textBox(activeForeground) - active foreground color
# global textBox(background) - background color
# global textBox(font) - text font
# global textBox(foreground) - foreground color
# global textBox(scrollActiveForeground) - scrollbar active background color
# global textBox(scrollBackground) - scrollbar background color
# global textBox(scrollForeground) - scrollbar foreground color
# global textBox(scrollSide) - side where scrollbar is located

  global textBox

  # show text box
  if {[llength $args] > 0} {
    eval TextBoxInternal "\{$textBoxMessage\}" "\{$textBoxCommand\}" "\{$textBoxGeometry\}" "\{$textBoxTitle\}" $args
  } {
    TextBoxInternal $textBoxMessage $textBoxCommand $textBoxGeometry $textBoxTitle
  }

  if {[llength $args] > 0} {
    # wait for the box to be destroyed
    update idletask
    grab $textBox(toplevelName)
    tkwait window $textBox(toplevelName)

    return $textBox(button)
  }
}


# Procedure: TextBoxFd
proc TextBoxFd { {textBoxInFile ""} {textBoxCommand ""} {textBoxGeometry "350x150"} {textBoxTitle "Text box"} args} {
# xf ignore me 5
##########
# Procedure: TextBoxFd
# Description: show text box containing a filedescriptor
# Arguments: {textBoxInFile} - a filedescriptor to read. The descriptor
#                              is closed after reading
#            {textBoxCommand} - the command to call after ok
#            {textBoxGeometry} - the geometry for the window
#            {textBoxTitle} - the title for the window
#            {args} - labels of buttons
# Returns: The number of the selected button, ot nothing
# Sideeffects: none
# Notes: there exist also functions called:
#          TextBox - to display a passed string
#          TextBoxFile - to open and read a file automatically
##########
#
# global textBox(activeBackground) - active background color
# global textBox(activeForeground) - active foreground color
# global textBox(background) - background color
# global textBox(font) - text font
# global textBox(foreground) - foreground color
# global textBox(scrollActiveForeground) - scrollbar active background color
# global textBox(scrollBackground) - scrollbar background color
# global textBox(scrollForeground) - scrollbar foreground color
# global textBox(scrollSide) - side where scrollbar is located

  global textBox

  # check file existance
  if {"$textBoxInFile" == ""} {
    puts stderr "No filedescriptor specified"
    return
  }

  set textBoxMessage [read $textBoxInFile]
  close $textBoxInFile

  # show text box
  if {[llength $args] > 0} {
    eval TextBoxInternal "\{$textBoxMessage\}" "\{$textBoxCommand\}" "\{$textBoxGeometry\}" "\{$textBoxTitle\}" $args
  } {
    TextBoxInternal $textBoxMessage $textBoxCommand $textBoxGeometry $textBoxTitle
  }

  if {[llength $args] > 0} {
    # wait for the box to be destroyed
    update idletask
    grab $textBox(toplevelName)
    tkwait window $textBox(toplevelName)

    return $textBox(button)
  }
}


# Procedure: TextBoxFile
proc TextBoxFile { {textBoxFile ""} {textBoxCommand ""} {textBoxGeometry "350x150"} {textBoxTitle "Text box"} args} {
# xf ignore me 5
##########
# Procedure: TextBoxFile
# Description: show text box containing a file
# Arguments: {textBoxFile} - filename to read
#            {textBoxCommand} - the command to call after ok
#            {textBoxGeometry} - the geometry for the window
#            {textBoxTitle} - the title for the window
#            {args} - labels of buttons
# Returns: The number of the selected button, ot nothing
# Sideeffects: none
# Notes: there exist also functions called:
#          TextBox - to display a passed string
#          TextBoxFd - to read from an already opened filedescriptor
##########
#
# global textBox(activeBackground) - active background color
# global textBox(activeForeground) - active foreground color
# global textBox(background) - background color
# global textBox(font) - text font
# global textBox(foreground) - foreground color
# global textBox(scrollActiveForeground) - scrollbar active background color
# global textBox(scrollBackground) - scrollbar background color
# global textBox(scrollForeground) - scrollbar foreground color
# global textBox(scrollSide) - side where scrollbar is located

  global textBox

  # check file existance
  if {"$textBoxFile" == ""} {
    puts stderr "No filename specified"
    return
  }

  if {[catch [list open "$textBoxFile" r] textBoxInFile]} {
    puts stderr "$textBoxInFile"
    return
  }

  set textBoxMessage [read $textBoxInFile]
  close $textBoxInFile

  # show text box
  if {[llength $args] > 0} {
    eval TextBoxInternal "\{$textBoxMessage\}" "\{$textBoxCommand\}" "\{$textBoxGeometry\}" "\{$textBoxTitle\}" $args
  } {
    TextBoxInternal $textBoxMessage $textBoxCommand $textBoxGeometry $textBoxTitle
  }

  if {[llength $args] > 0} {
    # wait for the box to be destroyed
    update idletask
    grab $textBox(toplevelName)
    tkwait window $textBox(toplevelName)

    return $textBox(button)
  }
}


# Procedure: TextBoxInternal
proc TextBoxInternal { textBoxMessage textBoxCommand textBoxGeometry textBoxTitle args} {
# xf ignore me 6
  global textBox

  set tmpButtonOpt ""
  set tmpFrameOpt ""
  set tmpMessageOpt ""
  set tmpScrollOpt ""
  if {"$textBox(activeBackground)" != ""} {
    append tmpButtonOpt "-activebackground \"$textBox(activeBackground)\" "
  }
  if {"$textBox(activeForeground)" != ""} {
    append tmpButtonOpt "-activeforeground \"$textBox(activeForeground)\" "
  }
  if {"$textBox(background)" != ""} {
    append tmpButtonOpt "-background \"$textBox(background)\" "
    append tmpFrameOpt "-background \"$textBox(background)\" "
    append tmpMessageOpt "-background \"$textBox(background)\" "
  }
  if {"$textBox(font)" != ""} {
    append tmpButtonOpt "-font \"$textBox(font)\" "
    append tmpMessageOpt "-font \"$textBox(font)\" "
  }
  if {"$textBox(foreground)" != ""} {
    append tmpButtonOpt "-foreground \"$textBox(foreground)\" "
    append tmpMessageOpt "-foreground \"$textBox(foreground)\" "
  }
  if {"$textBox(scrollActiveForeground)" != ""} {
    append tmpScrollOpt "-activeforeground \"$textBox(scrollActiveForeground)\" "
  }
  if {"$textBox(scrollBackground)" != ""} {
    append tmpScrollOpt "-background \"$textBox(scrollBackground)\" "
  }
  if {"$textBox(scrollForeground)" != ""} {
    append tmpScrollOpt "-foreground \"$textBox(scrollForeground)\" "
  }

  # start build of toplevel
  if {"[info commands XFDestroy]" != ""} {
    catch {XFDestroy $textBox(toplevelName)}
  } {
    catch {destroy $textBox(toplevelName)}
  }
  toplevel $textBox(toplevelName)  -borderwidth 0
  catch "$textBox(toplevelName) config $tmpFrameOpt"
  if {[catch "wm geometry $textBox(toplevelName) $textBoxGeometry"]} {
    wm geometry $textBox(toplevelName) 350x150
  }
  wm title $textBox(toplevelName) $textBoxTitle
  wm maxsize $textBox(toplevelName) 1000 1000
  wm minsize $textBox(toplevelName) 100 100
  # end build of toplevel

  frame $textBox(toplevelName).frame0  -borderwidth 0  -relief raised
  catch "$textBox(toplevelName).frame0 config $tmpFrameOpt"

  text $textBox(toplevelName).frame0.text1  -relief raised  -wrap none  -borderwidth 2  -yscrollcommand "$textBox(toplevelName).frame0.vscroll set"
  catch "$textBox(toplevelName).frame0.text1 config $tmpMessageOpt"

  scrollbar $textBox(toplevelName).frame0.vscroll  -relief raised  -command "$textBox(toplevelName).frame0.text1 yview"
  catch "$textBox(toplevelName).frame0.vscroll config $tmpScrollOpt"

  frame $textBox(toplevelName).frame1  -borderwidth 0  -relief raised
  catch "$textBox(toplevelName).frame1 config $tmpFrameOpt"

  set textBoxCounter 0
  set buttonNum [llength $args]

  if {$buttonNum > 0} {
    while {$textBoxCounter < $buttonNum} {
      button $textBox(toplevelName).frame1.button$textBoxCounter  -text "[lindex $args $textBoxCounter]"  -command "
          global textBox
          set textBox(button) $textBoxCounter
          set textBox(contents) \[$textBox(toplevelName).frame0.text1 get 1.0 end\]
          if {\"\[info commands XFDestroy\]\" != \"\"} {
            catch {XFDestroy $textBox(toplevelName)}
          } {
            catch {destroy $textBox(toplevelName)}
          }"
      catch "$textBox(toplevelName).frame1.button$textBoxCounter config $tmpButtonOpt"

      pack append $textBox(toplevelName).frame1  $textBox(toplevelName).frame1.button$textBoxCounter {left fillx expand}

      incr textBoxCounter
    }
  } {
    button $textBox(toplevelName).frame1.button0  -text "OK"  -command "
        global textBox
        set textBox(button) 0
        set textBox(contents) \[$textBox(toplevelName).frame0.text1 get 1.0 end\]
        if {\"\[info commands XFDestroy\]\" != \"\"} {
          catch {XFDestroy $textBox(toplevelName)}
        } {
          catch {destroy $textBox(toplevelName)}
        }
        $textBoxCommand"
    catch "$textBox(toplevelName).frame1.button0 config $tmpButtonOpt"

    pack append $textBox(toplevelName).frame1  $textBox(toplevelName).frame1.button0 {left fillx expand}
  }

  $textBox(toplevelName).frame0.text1 insert end "$textBoxMessage"

  $textBox(toplevelName).frame0.text1 config  -state $textBox(state)

  # packing
  pack append $textBox(toplevelName).frame0  $textBox(toplevelName).frame0.vscroll "$textBox(scrollSide) filly"  $textBox(toplevelName).frame0.text1 {left fill expand}
  pack append $textBox(toplevelName)  $textBox(toplevelName).frame1 {bottom fill}  $textBox(toplevelName).frame0 {top fill expand}
}


# Procedure: Today
proc Today {} {
  global tcl_version
  if {$tcl_version > 7.4} {
# if Tcl 7.5, use builting clock command.  Nice and portable
    return "[clock format [clock seconds] -format %D]"
  } else {
# assumes standard UNIX "date" command is available
    return "[exec date +%D]"
  }
}


# Procedure: WIP
proc WIP { value label} {
  [SN WorkInProgress] configure -label "$label"
  [SN WorkInProgress] set $value
  update
}


# Procedure: WIP_Done
proc WIP_Done {} {
  if {"[info procs XFEdit]" != ""} {
    if {"[info commands .wip]" != ""} {
      global xfShowWindow.wip
      set xfShowWindow.wip 0
      XFEditSetPath .
      after 2 "XFSaveAsProc .wip; XFEditSetShowWindows"
    }
  } {
    catch "destroy .wip"
    update
  }
}


# Procedure: WIP_Start
proc WIP_Start { Message} {
  if {[winfo exists .wip.message1]} {
    .wip.message1 configure -text "$Message"
    raise .wip
    update
    grab .wip
    return
  }

  # build widget .wip
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .wip"
  } {
    catch "destroy .wip"
  }
  toplevel .wip

  # Window manager configurations
  global tk_version
  wm maxsize .wip 1000 1000
  wm minsize .wip 10 10
  wm positionfrom . program
  set x [expr ([winfo screenwidth .] / 2) - 200]
  set y [expr ([winfo screenheight .] / 2) - 75]
  wm geometry .wip "400x150+$x+$y"
  wm transient .wip .
  wm protocol .wip WM_DELETE_WINDOW {wm withdraw .wip}
  wm title .wip {Work In Progress}


  # build widget .wip.message1
  message .wip.message1  -width {400}  -padx {5}  -pady {2}  -relief {raised}  -text "$Message"

  # build widget .wip.scale0
  scale .wip.scale0  -label { }  -orient {horizontal}  -showvalue {0}  -takefocus {0}
  # bindings
  bind .wip.scale0 <B1-Motion> {NoFunction;break}
  bind .wip.scale0 <B2-Motion> {NoFunction;break}
  bind .wip.scale0 <Button-1> {NoFunction;break}
  bind .wip.scale0 <Button-2> {NoFunction;break}
  bind .wip.scale0 <ButtonRelease-1> {NoFunction;break}
  bind .wip.scale0 <Control-Button-1> {NoFunction;break}
  bind .wip.scale0 <Enter> {NoFunction;break}
  bind .wip.scale0 <Key-Down> {NoFunction;break}
  bind .wip.scale0 <Key-End> {NoFunction;break}
  bind .wip.scale0 <Key-Home> {NoFunction;break}
  bind .wip.scale0 <Key-Left> {NoFunction;break}
  bind .wip.scale0 <Key-Right> {NoFunction;break}
  bind .wip.scale0 <Key-Up> {NoFunction;break}
  bind .wip.scale0 <Leave> {NoFunction;break}
  bind .wip.scale0 <Motion> {NoFunction;break}

  # pack master .wip
  pack configure .wip.message1  -expand 1  -fill both
  pack configure .wip.scale0  -fill x

  if {"[info procs XFEdit]" != ""} {
    catch "XFMiscBindWidgetTree .wip"
    after 2 "catch {XFEditSetShowWindows}"
  }

  update
  grab .wip
}


# Procedure: WriteOneCarToDisk
proc WriteOneCarToDisk { Cx fp} {
  global COMMA
#  Car TYPE
  global CrsType
  puts -nonewline $fp "$CrsType($Cx)$COMMA"
#  Car RR
  global CrsRR
  set StrLen [string length $CrsRR($Cx)]
  puts -nonewline $fp "[format {%-9s,} $CrsRR($Cx)]"
#  Car NUMBER
  global CrsNum
  puts -nonewline $fp "[format {%8s,} $CrsNum($Cx)]"
#  Car HOMEDIVS
  global CrsDivList
  puts -nonewline $fp "$CrsDivList($Cx)$COMMA"
  set StrLen [string length "$CrsDivList($Cx)"]
  for {set Pad $StrLen} {$Pad <= 18} {incr Pad} {puts -nonewline $fp { }}
#  Car LEN
  global CrsLen
  puts -nonewline $fp "[format {%5d,} $CrsLen($Cx)]"
#  Car CLEARANCE PLATE
  global CrsPlate
  puts -nonewline $fp "[format {%1d,} $CrsPlate($Cx)]"
#  Car WEIGHT CLASS
  global CrsClass
  puts -nonewline $fp "[format {%1d,} $CrsClass($Cx)]"
#  Car LIGHT WEIGHT
  global CrsLtWt
  puts -nonewline $fp "[format {%4d,} $CrsLtWt($Cx)]"
#  Car LOAD LIMIT
  global CrsLdLmt
  puts -nonewline $fp "[format {%5d,} $CrsLdLmt($Cx)]"
#  Car STATUS
  global CrsStatus
  puts -nonewline $fp "$CrsStatus($Cx)$COMMA"
#  Car OK TO MIRROR
  global CrsOkToMirror
  puts -nonewline $fp "$CrsOkToMirror($Cx)$COMMA"
#  Car FIXED ROUTE INDICATOR
  global CrsFixedRoute
  puts -nonewline $fp "$CrsFixedRoute($Cx)$COMMA"
#  Car OWNER INITIALS
  global CrsOwner
  puts -nonewline $fp "[format {%-3s,} $CrsOwner($Cx)]"
#  Car DONE INDICATOR
  global CrsDone
  puts -nonewline $fp "$CrsDone($Cx)$COMMA"
#  Car LAST TRAIN
  global CrsTrain
  puts -nonewline $fp "[format {%3d,} $CrsTrain($Cx)]"
#  Car MOVES
  global CrsMoves
  puts -nonewline $fp "$CrsMoves($Cx)$COMMA"
#  Car LOCATION
  global CrsLoc
  puts -nonewline $fp "[format {%3d,} $CrsLoc($Cx)]"
#  Car DESTINATION
  global CrsDest
  puts -nonewline $fp "[format {%4d,} $CrsDest($Cx)]"
#  Car TRIPS
  global CrsTrips
  puts -nonewline $fp "[format {%4d,} $CrsTrips($Cx)]"
#  Car ASSIGNMENTS
  global CrsAssigns
  puts $fp "[format {%4d} $CrsAssigns($Cx)]"
}


# Procedure: YesNoBox
proc YesNoBox { {yesNoBoxMessage "Yes/no message"} {yesNoBoxGeometry "350x150"}} {
# xf ignore me 5
##########
# Procedure: YesNoBox
# Description: show yesno box
# Arguments: {yesNoBoxMessage} - the text to display
#            {yesNoBoxGeometry} - the geometry for the window
# Returns: none
# Sideeffects: none
##########
#
# global yesNoBox(activeBackground) - active background color
# global yesNoBox(activeForeground) - active foreground color
# global yesNoBox(anchor) - anchor for message box
# global yesNoBox(background) - background color
# global yesNoBox(font) - message font
# global yesNoBox(foreground) - foreground color
# global yesNoBox(justify) - justify for message box
# global yesNoBox(afterNo) - destroy yes-no box after n seconds.
#                            The no button is activated
# global yesNoBox(afterYes) - destroy yes-no box after n seconds.
#                             The yes button is activated

  global yesNoBox

  set tmpButtonOpt ""
  set tmpFrameOpt ""
  set tmpMessageOpt ""
  if {"$yesNoBox(activeBackground)" != ""} {
    append tmpButtonOpt "-activebackground \"$yesNoBox(activeBackground)\" "
  }
  if {"$yesNoBox(activeForeground)" != ""} {
    append tmpButtonOpt "-activeforeground \"$yesNoBox(activeForeground)\" "
  }
  if {"$yesNoBox(background)" != ""} {
    append tmpButtonOpt "-background \"$yesNoBox(background)\" "
    append tmpFrameOpt "-background \"$yesNoBox(background)\" "
    append tmpMessageOpt "-background \"$yesNoBox(background)\" "
  }
  if {"$yesNoBox(font)" != ""} {
    append tmpButtonOpt "-font \"$yesNoBox(font)\" "
    append tmpMessageOpt "-font \"$yesNoBox(font)\" "
  }
  if {"$yesNoBox(foreground)" != ""} {
    append tmpButtonOpt "-foreground \"$yesNoBox(foreground)\" "
    append tmpMessageOpt "-foreground \"$yesNoBox(foreground)\" "
  }

  # start build of toplevel
  if {"[info commands XFDestroy]" != ""} {
    catch {XFDestroy .yesNoBox}
  } {
    catch {destroy .yesNoBox}
  }
  toplevel .yesNoBox  -borderwidth 0
  catch ".yesNoBox config $tmpFrameOpt"
  if {[catch "wm geometry .yesNoBox $yesNoBoxGeometry"]} {
    wm geometry .yesNoBox 350x150
  }
  wm title .yesNoBox {Alert box}
  wm maxsize .yesNoBox 1000 1000
  wm minsize .yesNoBox 100 100
  # end build of toplevel

  message .yesNoBox.message1  -anchor "$yesNoBox(anchor)"  -justify "$yesNoBox(justify)"  -relief raised  -text "$yesNoBoxMessage"
  catch ".yesNoBox.message1 config $tmpMessageOpt"

  set xfTmpWidth  [string range $yesNoBoxGeometry 0 [expr [string first x $yesNoBoxGeometry]-1]]
  if {"$xfTmpWidth" != ""} {
    # set message size
    catch ".yesNoBox.message1 configure  -width [expr $xfTmpWidth-10]"
  } {
    .yesNoBox.message1 configure  -aspect 1500
  }

  frame .yesNoBox.frame1  -borderwidth 0  -relief raised
  catch ".yesNoBox.frame1 config $tmpFrameOpt"

  button .yesNoBox.frame1.button0  -text "Yes"  -command "
      global yesNoBox
      set yesNoBox(button) 1
      if {\"\[info commands XFDestroy\]\" != \"\"} {
        catch {XFDestroy .yesNoBox}
      } {
        catch {destroy .yesNoBox}
      }"
  catch ".yesNoBox.frame1.button0 config $tmpButtonOpt"

  button .yesNoBox.frame1.button1  -text "No"  -command "
      global yesNoBox
      set yesNoBox(button) 0
      if {\"\[info commands XFDestroy\]\" != \"\"} {
        catch {XFDestroy .yesNoBox}
      } {
        catch {destroy .yesNoBox}
      }"
  catch ".yesNoBox.frame1.button1 config $tmpButtonOpt"

  pack append .yesNoBox.frame1  .yesNoBox.frame1.button0 {left fillx expand}  .yesNoBox.frame1.button1 {left fillx expand}

  # packing
  pack append .yesNoBox  .yesNoBox.frame1 {bottom fill}  .yesNoBox.message1 {top fill expand}

  if {$yesNoBox(afterYes) != 0} {
    after [expr $yesNoBox(afterYes)*1000]  "catch \".yesNoBox.frame1.button0 invoke\""
  }
  if {$yesNoBox(afterNo) != 0} {
    after [expr $yesNoBox(afterNo)*1000]  "catch \".yesNoBox.frame1.button1 invoke\""
  }

  # wait for the box to be destroyed
  update idletask
  grab .yesNoBox
  tkwait window .yesNoBox

  return $yesNoBox(button)
}


# Procedure: tkTextButton1-nofocus
proc tkTextButton1-nofocus { w x y} {
    global tkPriv

    set tkPriv(selectMode) char
    set tkPriv(mouseMoved) 0
    set tkPriv(pressX) $x
    $w mark set insert @$x,$y
    $w mark set anchor insert
}

# Procedure: ViewCarInfo
proc ViewCarInfo {} {
  set NewCx [SearchForCar]
  if {$NewCx == {}} {return}

  global SessionNumber
  global ShiftNumber
  [SN LogWindow] insert end \
	"View car information -- Session $SessionNumber : $ShiftNumber\n"
  ShowCarInfo $NewCx
}

# Procedure: ShowCarInfo
proc ShowCarInfo {NewCx} {
  global CrsRR
  global CrsNum
  global CrsDivList
  global CrsLen
  global CrsType
  global CarTypes
  global CrsStatus
  global CrsPlate
  global CrsClass
  global CrsLtWt
  global CrsLdLmt
  global CrsAssigns
  global CrsFixedRoute
  global CrsOkToMirror
  global CrsOwner
  global CrsDest
  global IndScrapYard
  global IndsName
  global StnsName
  global IndsStation
  global CrsLoc
  global CxCol

  [SN LogWindow] insert end "Railroad       :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsRR($NewCx)\n"
  [SN LogWindow] insert end "Car Number     :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsNum($NewCx)\n"
  [SN LogWindow] insert end "Home Divisions :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsDivList($NewCx)\n"
  [SN LogWindow] insert end "Car Length     :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsLen($NewCx) ft\n"
  [SN LogWindow] insert end "Car Type       :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  if {[catch "set CarTypes($CrsType($NewCx))" type]} {
    [SN LogWindow] insert end "$CarTypes(NULL)\n"
  } else {
    [SN LogWindow] insert end "$CrsType($NewCx) $type\n"
  }

  if {"$CrsStatus($NewCx)" == "E"} {set Status "EMPTY"}
  if {"$CrsStatus($NewCx)" == "L"} {set Status "LOADED"}

  [SN LogWindow] insert end "Clearance      :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsPlate($NewCx)\n"
  [SN LogWindow] insert end "Weight Class   :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsClass($NewCx)\n"
  [SN LogWindow] insert end "Empty Weight   :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsLtWt($NewCx)\n"
  [SN LogWindow] insert end "Loaded Weight  :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsLdLmt($NewCx)\n"
  [SN LogWindow] insert end "Car Status     :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$Status\n"
  [SN LogWindow] insert end "Assignments    :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsAssigns($NewCx)\n"
  [SN LogWindow] insert end "Fixed Route    :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsFixedRoute($NewCx)\n"
  [SN LogWindow] insert end "Ok to Mirror   :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsOkToMirror($NewCx)\n"
  [SN LogWindow] insert end "Owner initials :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "$CrsOwner($NewCx)\n"
  [SN LogWindow] insert end "Destination    :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "<$CrsDest($NewCx)>"
  if {$CrsDest($NewCx) == $IndScrapYard} {
    [SN LogWindow] insert end "Destined for Scrap!\n"
  } else {
    [SN LogWindow] insert end "$IndsName($CrsDest($NewCx)) at $StnsName($IndsStation($CrsDest($NewCx)))\n"
  }
  [SN LogWindow] insert end "Location       :"
  [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
  TabText [SN LogWindow] $CxCol
  [SN LogWindow] insert end "<$CrsLoc($NewCx)>"
  [SN LogWindow] insert end "$IndsName($CrsLoc($NewCx)) at $StnsName($IndsStation($CrsLoc($NewCx)))\n"
  [SN LogWindow] see end
}

# Procedure: EditCarInfo
proc EditCarInfo {} {
  set NewCx [SearchForCar]
  if {$NewCx == {}} {return}
  global LastEditCx
  set LastEditCx $NewCx
  EditACar $NewCx
}

# Procedure: AddNewCar
proc AddNewCar {} {
  global TotalCars
  set Cx [expr $TotalCars + 1]
  global CrsDone
  global CrsTrain
  global CrsMoves
  global CrsTrips
  global CrsAssigns
  set CrsDone($Cx) {N}
  set CrsTrain($Cx) 0
  set CrsMoves($Cx) 0
  set CrsTrips($Cx) 0
  set CrsAssigns($Cx) 0
  EditACar $Cx
}

# Procedure: EditACar
proc EditACar {Cx} {

  global TotalCars
  global LastEditCx
  global CrsRR
  global CrsNum
  global CrsDivList
  global CrsLen
  global CrsType
  global CarTypes
  global CrsStatus
  global CrsPlate
  global CrsClass
  global CrsLtWt
  global CrsLdLmt
  global CrsAssigns
  global CrsFixedRoute
  global CrsOkToMirror
  global CrsOwner
  global CrsDest
  global IndScrapYard
  global IndsName
  global StnsName
  global IndsStation
  global CrsLoc
  global CrsTrips
  global CarTypes
  set NewCx 0

  set CrsType($NewCx) "$CrsType($LastEditCx)"
  set CrsRR($NewCx) "$CrsRR($LastEditCx)"
  set CrsNum($NewCx) "$CrsNum($LastEditCx)"
  set CrsDivList($NewCx) "$CrsDivList($LastEditCx)"
  set CrsLen($NewCx) $CrsLen($LastEditCx)
  set CrsPlate($NewCx) $CrsPlate($LastEditCx)
  set CrsClass($NewCx) $CrsClass($LastEditCx)
  set CrsLtWt($NewCx) $CrsLtWt($LastEditCx)
  set CrsLdLmt($NewCx) $CrsLdLmt($LastEditCx)
  set CrsStatus($NewCx) "$CrsStatus($LastEditCx)"
  set CrsTrips($NewCx) $CrsTrips($LastEditCx)
  set CrsOwner($NewCx) "$CrsOwner($LastEditCx)"
  set CrsLoc($NewCx) $CrsLoc($LastEditCx)
  set CrsDest($NewCx) $CrsDest($LastEditCx)
  set CrsOkToMirror($NewCx) "$CrsOkToMirror($LastEditCx)"
  set CrsFixedRoute($NewCx) "$CrsFixedRoute($LastEditCx)"

  if {$Cx <= $TotalCars} {
    if {![catch "set CrsDone($LastEditCx)" d]} {
      set CrsDone($NewCx) "$d"
    } else {
      set CrsDone($NewCx) {N}
    }
    if {![catch "set CrsTrain($LastEditCx)" d]} {
      set CrsTrain($NewCx) $d
    } else {
      set CrsTrain($NewCx) 0
    }
    if {![catch "set CrsMoves($LastEditCx)" d]} {
      set CrsMoves($NewCx) $d
    } else {
      set CrsMoves($NewCx) 0
    }
  }


  # build widget .editCarDialog
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .editCarDialog"
  } {
    catch "destroy .editCarDialog"
  }
  toplevel .editCarDialog 

  # Window manager configurations
  wm maxsize .editCarDialog 1024 768
  wm minsize .editCarDialog 0 0
  wm title .editCarDialog "Edit Car $Cx"


  # build widget .editCarDialog.frame1
  frame .editCarDialog.frame1 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame1.label18
  label .editCarDialog.frame1.label18 \
    -font {fixed} \
    -text {Railroad       :}

  # build widget .editCarDialog.frame1.entry20
  entry .editCarDialog.frame1.entry20 \
    -textvariable CrsRR($NewCx)

  # build widget .editCarDialog.frame2
  frame .editCarDialog.frame2 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame2.label18
  label .editCarDialog.frame2.label18 \
    -font {fixed} \
    -text {Car Number     :}

  # build widget .editCarDialog.frame2.entry20
  entry .editCarDialog.frame2.entry20 \
    -textvariable CrsNum($NewCx)

  # build widget .editCarDialog.frame3
  frame .editCarDialog.frame3 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame3.label18
  label .editCarDialog.frame3.label18 \
    -font {fixed} \
    -text {Home Divisions :}

  # build widget .editCarDialog.frame3.entry20
  entry .editCarDialog.frame3.entry20 \
    -textvariable CrsDivList($NewCx)

  # build widget .editCarDialog.frame4
  frame .editCarDialog.frame4 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame4.label18
  label .editCarDialog.frame4.label18 \
    -font {fixed} \
    -text {Car Length     :}

  # build widget .editCarDialog.frame4.entry20
  entry .editCarDialog.frame4.entry20 \
    -textvariable CrsLen($NewCx)

  # build widget .editCarDialog.frame5
  frame .editCarDialog.frame5 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame5.label18
  label .editCarDialog.frame5.label18 \
    -font {fixed} \
    -text {Car Type       :}

  # build widget .editCarDialog.frame5.label19
  label .editCarDialog.frame5.label19 \
    -relief {sunken} \
    -anchor w \
    -text "$CrsType($NewCx) $CarTypes($CrsType($NewCx))"

  # build widget .editCarDialog.frame5.button1
  button .editCarDialog.frame5.button1 \
    -text {Select Type From a List} \
    -command "EditCarSelectCarType $NewCx .editCarDialog.frame5.label19;grab .editCarDialog"

  # build widget .editCarDialog.frame6
  frame .editCarDialog.frame6 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame6.label18
  label .editCarDialog.frame6.label18 \
    -font {fixed} \
    -text {Clearance      :}

  # build widget .editCarDialog.frame6.entry20
  entry .editCarDialog.frame6.entry20 \
    -textvariable CrsPlate($NewCx)

  # build widget .editCarDialog.frame7
  frame .editCarDialog.frame7 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame7.label18
  label .editCarDialog.frame7.label18 \
    -font {fixed} \
    -text {Weight Class   :}

  # build widget .editCarDialog.frame7.entry20
  entry .editCarDialog.frame7.entry20 \
    -textvariable CrsClass($NewCx)

  # build widget .editCarDialog.frame8
  frame .editCarDialog.frame8 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame8.label18
  label .editCarDialog.frame8.label18 \
    -font {fixed} \
    -text {Empty Weight   :}

  # build widget .editCarDialog.frame8.entry20
  entry .editCarDialog.frame8.entry20 \
    -textvariable CrsLtWt($NewCx)

  # build widget .editCarDialog.frame9
  frame .editCarDialog.frame9 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame9.label18
  label .editCarDialog.frame9.label18 \
    -font {fixed} \
    -text {Loaded Weight  :}

  # build widget .editCarDialog.frame9.entry20
  entry .editCarDialog.frame9.entry20 \
    -textvariable CrsLdLmt($NewCx)

  # build widget .editCarDialog.frame10
  frame .editCarDialog.frame10 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame10.label18
  label .editCarDialog.frame10.label18 \
    -font {fixed} \
    -text {Car Status     :}

  # build widget .editCarDialog.frame10.radio1
  radiobutton .editCarDialog.frame10.radio1 \
    -text {EMPTY} \
    -value {E} \
    -variable CrsStatus($NewCx)

  # build widget .editCarDialog.frame10.radio2
  radiobutton .editCarDialog.frame10.radio2 \
    -text {LOADED} \
    -value {L} \
    -variable CrsStatus($NewCx)

  # build widget .editCarDialog.frame11
  frame .editCarDialog.frame11 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame11.label18
  label .editCarDialog.frame11.label18 \
    -font {fixed} \
    -text {Assignments    :}

  # build widget .editCarDialog.frame11.label17
  label .editCarDialog.frame11.label17 \
    -relief {sunken} \
    -anchor w \
    -textvariable CrsAssigns($NewCx)

  # build widget .editCarDialog.frame12
  frame .editCarDialog.frame12 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame12.label18
  label .editCarDialog.frame12.label18 \
    -font {fixed} \
    -text {Fixed Route    :}

  # build widget .editCarDialog.frame12.radio1
  radiobutton .editCarDialog.frame12.radio1 \
    -text {Yes} \
    -value {Y} \
    -variable CrsFixedRoute($NewCx)

  # build widget .editCarDialog.frame12.radio2
  radiobutton .editCarDialog.frame12.radio2 \
    -text {No} \
    -value {N} \
    -variable CrsFixedRoute($NewCx)

  # build widget .editCarDialog.frame13
  frame .editCarDialog.frame13 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame13.label18
  label .editCarDialog.frame13.label18 \
    -font {fixed} \
    -text {Ok to Mirror   :}

  # build widget .editCarDialog.frame13.radio1
  radiobutton .editCarDialog.frame13.radio1 \
    -text {Yes} \
    -value {Y} \
    -variable CrsOkToMirror($NewCx)

  # build widget .editCarDialog.frame13.radio2
  radiobutton .editCarDialog.frame13.radio2 \
    -text {No} \
    -value {N} \
    -variable CrsOkToMirror($NewCx)

  # build widget .editCarDialog.frame14
  frame .editCarDialog.frame14 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame14.label18
  label .editCarDialog.frame14.label18 \
    -font {fixed} \
    -text {Owner initials :}

  # build widget .editCarDialog.frame14.entry20
  entry .editCarDialog.frame14.entry20 \
    -textvariable CrsOwner($NewCx)

  # build widget .editCarDialog.frame0
  frame .editCarDialog.frame0 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame0.label18
  label .editCarDialog.frame0.label18 \
    -font {fixed} \
    -text {Destination    :}

  if {$CrsDest($Cx) == $IndScrapYard} {
    set deststring "Destined for Scrap!"
  } else {
    set deststring "$IndsName($CrsDest($NewCx)) at $StnsName($IndsStation($CrsDest($NewCx)))"
  }
  # build widget .editCarDialog.frame0.label19
  label .editCarDialog.frame0.label19 \
    -relief {sunken} \
    -anchor w \
    -text "<$CrsDest($NewCx)> $deststring"

  # build widget .editCarDialog.frame0.button1
  button .editCarDialog.frame0.button1 \
    -text {Select Destination From a List} \
    -command "EditCarSelectLocOrDestination CrsDest $NewCx .editCarDialog.frame0.label19 1;grab .editCarDialog"

  # build widget .editCarDialog.frame16
  frame .editCarDialog.frame16 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .editCarDialog.frame16.label18
  label .editCarDialog.frame16.label18 \
    -font {fixed} \
    -text {Location       :}

  # build widget .editCarDialog.frame16.label19
  label .editCarDialog.frame16.label19 \
    -relief {sunken} \
    -anchor w \
    -text "<$CrsLoc($NewCx)> $IndsName($CrsLoc($NewCx)) at $StnsName($IndsStation($CrsLoc($NewCx)))"

  # build widget .editCarDialog.frame16.button1
  button .editCarDialog.frame16.button1 \
    -text {Select Location From a List} \
    -command "EditCarSelectLocOrDestination CrsLoc $NewCx .editCarDialog.frame16.label19 0;grab .editCarDialog"

  # build widget .editCarDialog.frame15
  frame .editCarDialog.frame15 \
    -borderwidth {2}

  # build widget .editCarDialog.frame15.button18
  button .editCarDialog.frame15.button18 \
    -command "EditCarOk $NewCx $Cx .editCarDialog" \
    -padx {9} \
    -pady {3} \
    -text {Ok}

  # build widget .editCarDialog.frame15.button19
  button .editCarDialog.frame15.button19 \
    -command {if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .editCarDialog"
  } {
    catch "destroy .editCarDialog"
  }} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # pack master .editCarDialog.frame1
  pack configure .editCarDialog.frame1.label18 \
    -side left
  pack configure .editCarDialog.frame1.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame2
  pack configure .editCarDialog.frame2.label18 \
    -side left
  pack configure .editCarDialog.frame2.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame3
  pack configure .editCarDialog.frame3.label18 \
    -side left
  pack configure .editCarDialog.frame3.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame4
  pack configure .editCarDialog.frame4.label18 \
    -side left
  pack configure .editCarDialog.frame4.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame5
  pack configure .editCarDialog.frame5.label18 \
    -side left
  pack configure .editCarDialog.frame5.label19 \
    -expand 1 \
    -fill x \
    -side left
  pack configure .editCarDialog.frame5.button1 \
    -side left

  # pack master .editCarDialog.frame6
  pack configure .editCarDialog.frame6.label18 \
    -side left
  pack configure .editCarDialog.frame6.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame7
  pack configure .editCarDialog.frame7.label18 \
    -side left
  pack configure .editCarDialog.frame7.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame8
  pack configure .editCarDialog.frame8.label18 \
    -side left
  pack configure .editCarDialog.frame8.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame9
  pack configure .editCarDialog.frame9.label18 \
    -side left
  pack configure .editCarDialog.frame9.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame10
  pack configure .editCarDialog.frame10.label18 \
    -side left
  pack configure .editCarDialog.frame10.radio1 \
    -expand 1 \
    -side left
  pack configure .editCarDialog.frame10.radio2 \
    -expand 1 \
    -side left

  # pack master .editCarDialog.frame11
  pack configure .editCarDialog.frame11.label18 \
    -side left
  pack configure .editCarDialog.frame11.label17 \
    -fill x

  # pack master .editCarDialog.frame12
  pack configure .editCarDialog.frame12.label18 \
    -side left
  pack configure .editCarDialog.frame12.radio1 \
    -expand 1 \
    -side left
  pack configure .editCarDialog.frame12.radio2 \
    -expand 1 \
    -side left

  # pack master .editCarDialog.frame13
  pack configure .editCarDialog.frame13.label18 \
    -side left
  pack configure .editCarDialog.frame13.radio1 \
    -expand 1 \
    -side left
  pack configure .editCarDialog.frame13.radio2 \
    -expand 1 \
    -side left

  # pack master .editCarDialog.frame14
  pack configure .editCarDialog.frame14.label18 \
    -side left
  pack configure .editCarDialog.frame14.entry20 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .editCarDialog.frame15
  pack configure .editCarDialog.frame15.button18 \
    -expand 1 \
    -side left
  pack configure .editCarDialog.frame15.button19 \
    -expand 1 \
    -side left

  # pack master .editCarDialog.frame0
  pack configure .editCarDialog.frame0.label18 \
    -side left
  pack configure .editCarDialog.frame0.label19 \
    -expand 1 \
    -fill x \
    -side left
  pack configure .editCarDialog.frame0.button1 \
    -side left

  # pack master .editCarDialog.frame16
  pack configure .editCarDialog.frame16.label18 \
    -side left
  pack configure .editCarDialog.frame16.label19 \
    -expand 1 \
    -fill x \
    -side left
  pack configure .editCarDialog.frame16.button1 \
    -side left

  # pack master .editCarDialog
  pack configure .editCarDialog.frame1 \
    -fill both
  pack configure .editCarDialog.frame2 \
    -fill both
  pack configure .editCarDialog.frame3 \
    -fill both
  pack configure .editCarDialog.frame4 \
    -fill both
  pack configure .editCarDialog.frame5 \
    -fill both
  pack configure .editCarDialog.frame6 \
    -fill both
  pack configure .editCarDialog.frame7 \
    -fill both
  pack configure .editCarDialog.frame8 \
    -fill both
  pack configure .editCarDialog.frame9 \
    -fill both
  pack configure .editCarDialog.frame10 \
    -fill both
  pack configure .editCarDialog.frame11 \
    -fill both
  pack configure .editCarDialog.frame12 \
    -fill both
  pack configure .editCarDialog.frame13 \
    -fill both
  pack configure .editCarDialog.frame14 \
    -fill both
  pack configure .editCarDialog.frame0 \
    -fill both
  pack configure .editCarDialog.frame16 \
    -fill both
  pack configure .editCarDialog.frame15 \
    -fill both

# end of widget tree

  update idletasks
  grab .editCarDialog
  tkwait window .editCarDialog

}

# Procedure: EditCarSelectCarType
proc EditCarSelectCarType {Cx label} {
  global CrsType
  global CarTypes

# .editCarSelectType
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 7.4 (Tcl/Tk/XF)
# Tk version: 4.0
# XF version: 2.4
#

  # build widget .editCarSelectType
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .editCarSelectType"
  } {
    catch "destroy .editCarSelectType"
  }
  toplevel .editCarSelectType 

  # Window manager configurations
  wm maxsize .editCarSelectType 1024 768
  wm minsize .editCarSelectType 0 0
  wm title .editCarSelectType {Select A Car Type}


  # build widget .editCarSelectType.frame
  frame .editCarSelectType.frame

  # build widget .editCarSelectType.frame.scrollbar2
  scrollbar .editCarSelectType.frame.scrollbar2 \
    -command {.editCarSelectType.frame.listbox1 yview} \
    -relief {raised}

  # build widget .editCarSelectType.frame.listbox1
  listbox .editCarSelectType.frame.listbox1 \
    -height {20} \
    -relief {raised} \
    -width {40} \
    -yscrollcommand {.editCarSelectType.frame.scrollbar2 set}

  # build widget .editCarSelectType.frame1
  frame .editCarSelectType.frame1 \
    -borderwidth {2}

  # build widget .editCarSelectType.frame1.button2
  button .editCarSelectType.frame1.button2 \
    -command "EditCarSelectCarTypeOk $Cx $label .editCarSelectType" \
    -padx {9} \
    -pady {3} \
    -text {Ok}

  # build widget .editCarSelectType.frame1.button3
  button .editCarSelectType.frame1.button3 \
    -command {if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .editCarSelectType"
  } {
    catch "destroy .editCarSelectType"
  }} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # pack master .editCarSelectType.frame
  pack configure .editCarSelectType.frame.scrollbar2 \
    -fill y \
    -side right
  pack configure .editCarSelectType.frame.listbox1 \
    -expand 1 \
    -fill both

  # pack master .editCarSelectType.frame1
  pack configure .editCarSelectType.frame1.button2 \
    -expand 1 \
    -side left
  pack configure .editCarSelectType.frame1.button3 \
    -expand 1 \
    -side left

  # pack master .editCarSelectType
  pack configure .editCarSelectType.frame \
    -fill both
  pack configure .editCarSelectType.frame1 \
    -fill both
# end of widget tree

  foreach ct [lsort [array names CarTypes]] {
    if {"$ct" == {,}} {continue}
    .editCarSelectType.frame.listbox1 insert end "$ct $CarTypes($ct)"
  }
  update idletasks
  grab .editCarSelectType
  tkwait window .editCarSelectType
}

# Procedure: EditCarSelectCarTypeOk
proc EditCarSelectCarTypeOk {Cx label toplevel} {
  if {"[selection own]" == "$toplevel.frame.listbox1"} {
    set le "[selection get]"
    set ct "[string index $le 0]"
    global CrsType
    global CarTypes
    set CrsType($Cx) "$ct"
    $label configure -text "$CrsType($Cx) $CarTypes($CrsType($Cx))"
  }
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy $toplevel"
  } {
    catch "destroy $toplevel"
  }
}

# Procedure: EditCarSelectLocOrDestination
proc EditCarSelectLocOrDestination {slot Cx label IncludeScrap} {

  # build widget .editCarSelectLocOrDestination
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .editCarSelectLocOrDestination"
  } {
    catch "destroy .editCarSelectLocOrDestination"
  }
  toplevel .editCarSelectLocOrDestination 

  # Window manager configurations
  wm maxsize .editCarSelectLocOrDestination 1024 768
  wm minsize .editCarSelectLocOrDestination 0 0
  wm title .editCarSelectLocOrDestination {Select A Location}


  # build widget .editCarSelectLocOrDestination.frame
  frame .editCarSelectLocOrDestination.frame

  # build widget .editCarSelectLocOrDestination.frame.scrollbar2
  scrollbar .editCarSelectLocOrDestination.frame.scrollbar2 \
    -command {.editCarSelectLocOrDestination.frame.listbox1 yview} \
    -relief {raised}

  # build widget .editCarSelectLocOrDestination.frame.listbox1
  listbox .editCarSelectLocOrDestination.frame.listbox1 \
    -height {20} \
    -relief {raised} \
    -width {60} \
    -yscrollcommand {.editCarSelectLocOrDestination.frame.scrollbar2 set}

  # build widget .editCarSelectLocOrDestination.frame1
  frame .editCarSelectLocOrDestination.frame1 \
    -borderwidth {2}

  # build widget .editCarSelectLocOrDestination.frame1.button2
  button .editCarSelectLocOrDestination.frame1.button2 \
    -command "EditCarSelectLocOrDestinationOk $slot $Cx $label .editCarSelectLocOrDestination" \
    -padx {9} \
    -pady {3} \
    -text {Ok}

  # build widget .editCarSelectLocOrDestination.frame1.button3
  button .editCarSelectLocOrDestination.frame1.button3 \
    -command {if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .editCarSelectLocOrDestination"
  } {
    catch "destroy .editCarSelectLocOrDestination"
  }} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # pack master .editCarSelectLocOrDestination.frame
  pack configure .editCarSelectLocOrDestination.frame.scrollbar2 \
    -fill y \
    -side right
  pack configure .editCarSelectLocOrDestination.frame.listbox1 \
    -expand 1 \
    -fill both

  # pack master .editCarSelectLocOrDestination.frame1
  pack configure .editCarSelectLocOrDestination.frame1.button2 \
    -expand 1 \
    -side left
  pack configure .editCarSelectLocOrDestination.frame1.button3 \
    -expand 1 \
    -side left

  # pack master .editCarSelectLocOrDestination
  pack configure .editCarSelectLocOrDestination.frame \
    -fill both
  pack configure .editCarSelectLocOrDestination.frame1 \
    -fill both
# end of widget tree

  global IndScrapYard
  global IndsName
  global StnsName
  global IndsStation
  foreach dest [lsort [array names IndsName]] {
    if {$IndsStation($dest) == 0} {continue}
    .editCarSelectLocOrDestination.frame.listbox1 insert end "$dest $IndsName($dest) at $StnsName($IndsStation($dest))"
  }
  if {$IncludeScrap} {
    .editCarSelectLocOrDestination.frame.listbox1 insert end "$IndScrapYard (Scrapyard)"
  }

  update idletasks
  grab .editCarSelectLocOrDestination
  tkwait window .editCarSelectLocOrDestination
}

# Procedure: EditCarSelectLocOrDestinationOk
proc EditCarSelectLocOrDestinationOk {slot Cx label toplevel} {
  if {"[selection own]" == "$toplevel.frame.listbox1"} {
    set le "[selection get]"
    set loc "[string trim [lindex [split $le { }] 0]]"
    global $slot
    global IndsName
    global StnsName
    global IndsStation
    global IndScrapYard
    set ${slot}($Cx) $loc
    if {$loc == $IndScrapYard} {
      $label configure -text "<$loc> Destined for Scrap!"
    } else {
      $label configure -text "<$loc> $IndsName($loc) at $StnsName($IndsStation($loc))"
    }
  }
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy $toplevel"
  } {
    catch "destroy $toplevel"
  }
}

# Procedure: EditCarOk
proc EditCarOk {NewCx Cx toplevel} {
  global TotalCars
  global CrsRR
  global CrsNum
  global CrsType
  global CrsLen
  global CrsDone
  global CrsLoc
  global CrsDest
  global CrsLtWt
  global CrsOwner
  global CrsTrips
  global CrsPlate
  global CrsClass
  global CrsLdLmt
  global CrsStatus
  global CrsTrain
  global CrsMoves
  global CrsDivList
  global CrsOkToMirror
  global CrsFixedRoute
  global LastEditCx

  if {$Cx > $TotalCars} {
    set TotalCars $Cx
  }
  set CrsRR($Cx) "[string toupper $CrsRR($NewCx)]"
  set CrsNum($Cx) "$CrsNum($NewCx)"
  set CrsType($Cx) "$CrsType($NewCx)"
  set CrsLen($Cx) $CrsLen($NewCx)
  set CrsDone($Cx) $CrsDone($NewCx)
  global IndsCarsIndexes
  if {[catch "set IndsCarsIndexes($CrsLoc($NewCx))"]} {set IndsCarsIndexes($CrsLoc($NewCx)) {}}
  if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
  set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
  if {$index >= 0} {
    set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
  }
  set CrsLoc($Cx) $CrsLoc($NewCx)
  lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
  set CrsDest($Cx) $CrsDest($NewCx)
  set CrsLtWt($Cx) $CrsLtWt($NewCx)
  set CrsOwner($Cx) "[string toupper $CrsOwner($NewCx)]"
  set CrsTrips($Cx) $CrsTrips($NewCx)
  set CrsPlate($Cx) $CrsPlate($NewCx)
  set CrsClass($Cx) $CrsClass($NewCx)
  set CrsLdLmt($Cx) $CrsLdLmt($NewCx)
  set CrsStatus($Cx) "$CrsStatus($NewCx)"
  set CrsTrain($Cx) $CrsTrain($NewCx)
  set CrsMoves($Cx) $CrsMoves($NewCx)
  set CrsDivList($Cx) "$CrsDivList($NewCx)"
  set CrsOkToMirror($Cx) "$CrsOkToMirror($NewCx)"
  set CrsFixedRoute($Cx) "$CrsFixedRoute($NewCx)"

  set LastEditCx $Cx

  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy $toplevel"
  } {
    catch "destroy $toplevel"
  }

}

# Procedure: DeleteExistingCar
proc DeleteExistingCar {} {
  set NewCx [SearchForCar]
  if {$NewCx == {}} {return}
  ShowCarInfo $NewCx
  if {[YesNoBox "Delete the displayed car?"]} {
    global CrsDest
    global IndScrapYard
    set CrsDest($NewCx) $IndScrapYard
  }
}

# Procedure: SearchForCar
proc SearchForCar {} {

  global SearchForCarResults
  set SearchForCarResults {}

  # build widget .searchForCar
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .searchForCar"
  } {
    catch "destroy .searchForCar"
  }
  toplevel .searchForCar 

  # Window manager configurations
  global tk_version
  wm maxsize .searchForCar 1009 738
  wm minsize .searchForCar 1 1
  wm title .searchForCar {Search for a Car}


  # build widget .searchForCar.frame
  frame .searchForCar.frame

  # build widget .searchForCar.frame.scrollbar2
  scrollbar .searchForCar.frame.scrollbar2 \
    -command {.searchForCar.frame.listbox1 yview} \
    -relief {raised}

  # build widget .searchForCar.frame.listbox1
  listbox .searchForCar.frame.listbox1 \
    -height {20} \
    -relief {raised} \
    -width {80} \
    -font {fixed} \
    -selectmode {single} \
    -yscrollcommand {.searchForCar.frame.scrollbar2 set}
  bind .searchForCar.frame.listbox1 <Double-1> {
	tkListboxBeginSelect %W [%W index @%x,%y]
	%W activate @%x,%y
	SearchForCarOk .searchForCar
	break}

  # build widget .searchForCar.frame16
  frame .searchForCar.frame16 \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .searchForCar.frame16.label18
  label .searchForCar.frame16.label18 \
    -text {Search for car number or partial (last digits):}

  # build widget .searchForCar.frame16.entry19
  entry .searchForCar.frame16.entry19
  bind .searchForCar.frame16.entry19 <Return> {SearchForCarSearchAgain .searchForCar}

  # build widget .searchForCar.frame17
  frame .searchForCar.frame17 \
    -borderwidth {2}

  # build widget .searchForCar.frame17.button20
  button .searchForCar.frame17.button20 \
    -command {SearchForCarOk .searchForCar} \
    -padx {9} \
    -pady {3} \
    -text {OK}

  # build widget .searchForCar.frame17.button21
  button .searchForCar.frame17.button21 \
    -command {SearchForCarSearchAgain .searchForCar} \
    -padx {9} \
    -pady {3} \
    -text {Search}

  # build widget .searchForCar.frame17.button22
  button .searchForCar.frame17.button22 \
    -command {if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .searchForCar"
  } {
    catch "destroy .searchForCar"
  }} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # pack master .searchForCar.frame
  pack configure .searchForCar.frame.scrollbar2 \
    -fill y \
    -side right
  pack configure .searchForCar.frame.listbox1 \
    -expand 1 \
    -fill both

  # pack master .searchForCar.frame16
  pack configure .searchForCar.frame16.label18 \
    -side left
  pack configure .searchForCar.frame16.entry19 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .searchForCar.frame17
  pack configure .searchForCar.frame17.button20 \
    -expand 1 \
    -side left
  pack configure .searchForCar.frame17.button21 \
    -expand 1 \
    -side left
  pack configure .searchForCar.frame17.button22 \
    -expand 1 \
    -side left

  # pack master .searchForCar
  pack configure .searchForCar.frame \
    -fill both
  pack configure .searchForCar.frame16 \
    -fill both
  pack configure .searchForCar.frame17 \
    -fill both

  .searchForCar.frame16.entry19 insert end {}

# end of widget tree

  update idletasks
  grab .searchForCar
  tkwait window .searchForCar

  return "$SearchForCarResults"

}

# Procedure: SearchForCarSearchAgain
proc SearchForCarSearchAgain {toplevel} {
  set entry "$toplevel.frame16.entry19"
  set list  "$toplevel.frame.listbox1"

  $list delete 0 end

  set SearchFor "[$entry get]"
  set SearchForLength [string length "$SearchFor"]

  global TotalCars
  global CrsNum
  global CrsRR
  global CarTypes
  global CrsType
  global IndsName
  global CrsLoc
  global CrsDest

  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    set cn $CrsNum($Cx)
    set cns [expr [string length $cn] - $SearchForLength]
    if {[string compare "$SearchFor" "[string range $cn $cns end]"] == 0} {
      if {$CrsLoc($Cx) == $CrsDest($Cx)} {
	set dest "- none -"
      } else {
	set dest "$IndsName($CrsDest($Cx))"
      }
      $list insert end "[format {%-3d %-9s %-8s %-16s %-18s %-18s} \
				$Cx [string range $CrsRR($Cx) 0 8]\
				[string range $CrsNum($Cx) 0 7]\
				[string range $CarTypes($CrsType($Cx)) 0 15]\
				[string range $IndsName($CrsLoc($Cx)) 0 17]\
				[string range $dest 0 17]]"
    }
  }
}

# Procedure: SearchForCarOk
proc SearchForCarOk {toplevel} {
  set list  "$toplevel.frame.listbox1"
  if {"[selection own]" == "$list"} {
    set line "[split [selection get] { }]"
    set Cx [lindex $line 0]
    global SearchForCarResults
    set SearchForCarResults $Cx
  }
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy $toplevel"
  } {
    catch "destroy $toplevel"
  }
}

# Procedure: ShowUnassignedCars
proc ShowUnassignedCars {} {
  global TotalCars
  global CrsLoc
  global CrsDest
  global CrsRR
  global CrsNum
  global CarTypes
  global CrsType
  global IndsName

  set Total 0
  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    if {$CrsLoc($Cx) == $CrsDest($Cx)} {
      if {$Total == 0} {      
	ShowBanner
	[SN LogWindow] insert end "Cars Without Assignments"
	[SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
	TabText [SN LogWindow] 50
	[SN LogWindow] insert end "Location\n\n"
      }
      [SN LogWindow] insert end "$CrsRR($Cx)"
      [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
      TabText [SN LogWindow] 10
      [SN LogWindow] insert end "$CrsNum($Cx)"
      [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
      TabText [SN LogWindow] 19
      [SN LogWindow] insert end "$CarTypes($CrsType($Cx))"
      [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
      TabText [SN LogWindow] 50
      [SN LogWindow] insert end "$IndsName($CrsLoc($Cx))\n"
      incr Total
      if {$Total == 18} {
	[SN LogWindow] see end
	update
	set Total 0
      }
    }
  }
  [SN LogWindow] see end
}

# Procedure: CarAssignmentProcedure
proc CarAssignmentProcedure {} {
  set RouteCars 0
  set LastIx 0

  global TotalIndustries
  global IndsUsedLen
  global IndScrapYard
  global IndRipTrack
  global IndsMirror
  global IndsType
  global IndsReload
  global IndsName
  global IndsPriority
  global IndsAssignLen
  global IndsPlate
  global IndsClass
  global IndsCarLen
  global IndsStation
  global IndsDivList
  global IndsEmptyTypes

  global TotalCars
  global CrsDone
  global CrsMoves
  global CrsTrain
  global CrsRR
  global CrsNum
  global CrsDest
  global CrsOkToMirror
  global CrsStatus
  global CrsTmpStatus
  global CrsPlate
  global CrsClass
  global CrsLen
  global CrsFixedRoute
  global CrsDivList
  global CrsLoc
  global CrsAssigns
  global CrsType

  global CarTypes

  global StnsDiv
  global DivsSymbol
  global DivsArea

  for {set AssignLoop 1} {$AssignLoop <= 2} {incr AssignLoop} {
    ShowBanner
#         ----------- Outer Loop Initialization --------------
    for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
      set IndsUsedLen($Ix) 0
    }
    WIP_Start "Car Assignment In Progress\nOuter Loop Initialization: $AssignLoop"
    set Tenth [expr 100.0 / double($TotalCars)]
    set Done 10
    WIP 0 {0% Done}
    for {set Cx 0} {$Cx <= $TotalCars} {incr Cx} {
#      puts stderr "*** CarAssignmentProcedure: Cx = $Cx"
      set DonePer [expr $Cx * $Tenth]
      if {$DonePer >= $Done} {
	WIP $DonePer "[format {%f%% Done} $DonePer]"
	incr Done 10
      }
      if {$CrsDest($Cx) == $IndScrapYard} {continue}
      if {$CrsLoc($Cx) == $IndRipTrack} {continue}
      if {$CrsDest($Cx) == 0} {set CrsDest($Cx) $CrsLoc($Cx)}
# ========================================================================
      if {$CrsLoc($Cx) == $CrsDest($Cx)} {
#	This marks the car for assignment
	set CrsDest($Cx) 0
#       --------------------------------------------------------------
#	If this is a MIRROR industry, the car moves to a new location,
#	but it does not change its status - if it was loaded then the
#	mirror target must load such cars, and so on.
#       --------------------------------------------------------------
	set CarWasMirrored 0
	if {$IndsMirror($CrsLoc($Cx)) > 0} {
	  if {$CrsOkToMirror($Cx) == {Y}} {
	    set Ix $IndsMirror($CrsLoc($Cx))
#	    -----------------------------------------------------------
#	    First check to see that the industry would receive this car
#	    in its mirrored loaded or empty state ...  
#	    -----------------------------------------------------------
	    if {$CrsStatus($Cx) == {E}} {set CrsTmpStatus($Cx) {L}}
	    if {$CrsStatus($Cx) == {L}} {set CrsTmpStatus($Cx) {E}}
	    if {[IndustryTakesCar $Cx $Ix]} {
#	      -----------------------------------------------------------
#	      Fixed route check then uses the car state that will be used
#	      for making an assignment from the mirrored industry ...
#	      -----------------------------------------------------------
	      set CrsTmpStatus($Cx) $CrsStatus($Cx)
	      if {[FixedRouteMirrorCheck $Cx $Ix]} {
#		Success! This car can in fact be mirrored! It will soon
#		be assigned from this new location.
		global IndsCarsIndexes
	        if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
		set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
		if {$index >= 0} {
		  set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
		}
		set CrsLoc($Cx) $Ix
		if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
		lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
		set CarWasMirrored 1
	      }
	    }
	  }
	}
	if {$CarWasMirrored == 0} {
	  if {$CrsStatus($Cx) == {E}} {
#	    ---------------------------------------------------------
#	    An empty car in a yard, will remain empty for purpose of
#	    finding an assignment. Otherwise this car becomes a load.
#	    ---------------------------------------------------------
	    if {$IndsType($CrsLoc($Cx)) != {Y}} {
	      set CrsTmpStatus($Cx) {L}
	    } else {
	      set CrsTmpStatus($Cx) {E}
	    }
	  } else {
#	    ---------------------------------------------------------
#	    If this is a RELOAD industry, the car is loaded again,
#	    but only if the industry ships out this type of car.
#	    ---------------------------------------------------------
	    set CrsTmpStatus($Cx) {E}
	    if {$IndsReload($CrsLoc($Cx)) == {Y}} {
	      if {[string first "$CrsType($Cx)" "$IndsEmptyTypes($CrsLoc($Cx))"] != -1} {
		set CrsTmpStatus($Cx) {L}
	      }
	    }
	  }
	}
      }
#     Car has no assignment
#     ========================================================================
#     If the car has a destination then add this car's
#     length to the destination's assigned track space
      if {$CrsDest($Cx) != 0} {
	incr IndsUsedLen($CrsDest($Cx)) $CrsLen($Cx)
      }
    }
    WIP 100 {100% Done}
#   ----------- Set Search Direction --------------
    if {[Random] < 0.5} {
      set ForEnd [expr $TotalCars + 1]
      set Forstart 1
      set ForStep 1
    } else {
      set Forstart $TotalCars
      set ForStep -1
      set ForEnd 0
    }
    [SN LogWindow] insert end "Checking cars from $Forstart to $ForEnd\n"
    [SN LogWindow] see end
    update
#   ----------- Outer Loop --------------
    set CountCars 0
    WIP_Start "Car Assignment In Progress\nOuter Loop: $AssignLoop"
    set Tenth [expr (100.0 / double($TotalCars))]
    if {$ForStep > 0} {
      set Done 10
      set DoneIncr 10
      set DoneCompare {>=}
    } else {
      set Done 90
      set DoneIncr -10
      set DoneCompare {<=}
    }
    WIP 0 {0% Done}
    for {set Cx $Forstart} {$Cx != $ForEnd} {incr Cx $ForStep} {
      set HaveDest 0
      set DonePer [expr $Cx * $Tenth]
      if {[eval [list expr $DonePer $DoneCompare $Done]]} {
	if {$ForStep < 0} {
	  WIP [expr 100 - $DonePer] "[format {%f%% Done} [expr 100 - $DonePer]]"
	} else {
	  WIP $DonePer "[format {%f%% Done} $DonePer]"
	}
	incr Done $DoneIncr
      }
      set CrsDone($Cx) {N}
      set CrsMoves($Cx) 0
      set CrsTrain($Cx) 0
      if {$CrsDest($Cx) != 0} {continue}
      if {$CrsLoc($Cx) == $IndRipTrack} {continue}
      incr CountCars
      [SN LogWindow] insert end "\n==================\n"
      [SN LogWindow] insert end "Processing car $Cx\n"
      [SN LogWindow] insert end "Cars inspected $CountCars\n"
      [SN LogWindow] insert end "Cars Assigned  $RouteCars\n"
      [SN LogWindow] insert end "Last Industry  $LastIx\n\n\n"
      [SN LogWindow] insert end "$CrsTmpStatus($Cx) $CrsRR($Cx) $CrsNum($Cx) at $IndsName($CrsLoc($Cx))\n"
      [SN LogWindow] see end
      update
      set Ix $LastIx
      for {set IndPriorityLoop 1} {$IndPriorityLoop <= 4} {incr IndPriorityLoop} {
#	----------- Inner Loop --------------
#	The purpose of the PassLoop is to try to reload cars in the
#	same division where they are, whether they are "offline" or
#	are "online"
	for {set PassLoop 1} {$PassLoop <= 2} {incr PassLoop} {
	  for {set IndLoop 1} {$IndLoop <= $TotalIndustries} {incr IndLoop} {
	    incr Ix
	    if {$Ix > $TotalIndustries} {set Ix 1}
	    if {[catch "set IndsPriority($Ix)"]} {continue}
	    if {$IndsPriority($Ix) != $IndPriorityLoop} {continue}
	    if {[catch "set IndsAssignLen($Ix)"]} {continue}
	    if {$IndsAssignLen($Ix) == 0} {continue}
#	    Cars are never assigned to yards
#	    --------------------------------
	    if {[catch "set IndsType($Ix)"]} {continue}
	    if {$IndsType($Ix) == {Y}} {continue}
#	    If the car is at an industry that mirrors, never route
#	    the car to the mirror itself. This does not apply when
#	    the car is not allowed to mirror.
#	    ------------------------------------------------------
	    if {$IndsMirror($CrsLoc($Cx)) > 0} {
	      if {$IndsMirror($CrsLoc($Cx)) == $Ix} {
		if {$CrsOkToMirror($Cx) == {Y}} {continue}
	      }
	    }
#	    Does industry accept this car ?
#	    -------------------------------
	    if {![IndustryTakesCar $Cx $Ix]} {continue}
#	    Eliminate incompatible industries for this car
#           ----------------------------------------------
	    if {$CrsPlate($Cx) > $IndsPlate($Ix)} {continue}
	    if {$CrsClass($Cx) > $IndsClass($Ix)} {continue}
	    if {$CrsLen($Cx) > $IndsCarLen($Ix)} {continue}
#	    Is there space available for this car ?
#	    -------------------------------------
	    if {[expr $IndsUsedLen($Ix) + $CrsLen($Cx)] > $IndsAssignLen($Ix)} {continue}
	    set CarDivI $StnsDiv($IndsStation($CrsLoc($Cx)))
	    set CarDivS $DivsSymbol($CarDivI)
	    set IndDivI $StnsDiv($IndsStation($Ix))
	    set IndDivS $DivsSymbol($IndDivI)
#	    -------------------------------------------------
#	    If the car has a fixed route then the destination
#	    must be in the car's home list.
#	    -------------------------------------------------
	    if {$CrsFixedRoute($Cx) == {Y}} {
	      if {[string first "$IndDivS" "$CrsDivList($Cx)"] < 0} {continue}
#	      AND the destination ALSO must be in the current car
#	      location's destination list - regardless of whether
#	      the car is loaded/empty -- unless the list is empty.
#	      ---------------------------------------------------
	      if {"$IndsDivList($CrsLoc($Cx))" != {}} {
		if {[string first "$IndDivS" "$IndsDivList($CrsLoc($Cx))"] < 0} {continue}
	      }
	    }
#	    Car has a FIXED route
#	    ===========================================================
#           EMPTY CARS
#           ===========================================================
	    if {$CrsTmpStatus($Cx) == {E}} {
	      if {$IndsType($Ix) == {O} && $IndsType($CrsLoc($Cx)) != {I}} {
		set LastIx $Ix
		global IndsCarsIndexes
		if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
		set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
		if {$index >= 0} {
		  set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
		}
		set CrsLoc($Cx) $Ix
		lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
#		puts stderr "*** CarAssignmentProcedure: Cx: $Cx, IndsType($Ix): $IndsType($Ix)"
		set HaveDest 1
		break
	      }
#	      ----------------------------------------------------
#
#	      Ok! The Car and Industry -ARE- in the same area.
#	      The empty car will travel a shorter distance to
#	      be reloaded.
#
#	      NOTE a key assumption is that from this area, it is
#	      possible to route the car back to its HOME division
#	      when the industry is not in a home div.
#
#	      ----------------------------------------------------
	      if {$CrsDivList($Cx) != {} && $IndsDivList($Ix) != {}} {
#		If the car is in a home division, we're ok
		if {[string first "$CarDivS" "$CrsDivList($Cx)"] < 0} {
		  set YesNo 0
		  foreach PxDiv [split "$IndsDivList($Ix)" {}] {
		    if {[string first "$PxDiv" "$CrsDivList($Cx)"] >= 0} {
		      set YesNo 1
		      break
		    }
		  }
		  if {!$YesNo} {continue}
		}
	        set LastIx $Ix
	        incr RouteCars
#	        puts stderr "*** CarAssignmentProcedure: Cx: $Cx, Ix: $Ix"
	        set HaveDest 1
	        break
	      }
#	      Car and Industry are in SAME AREA
#	      -------------------------------------------------
#
#	      On the first pass for empty cars, skip industries
#	      that are outside the car's present AREA.
#
#	      -------------------------------------------------
	      if {$PassLoop == 1 && $CrsFixedRoute($Cx) != {Y}} {continue}
#	      ------------------------------------------------------
#
#	      The EMPTY and an Industry are not in the same area, so
#	      check the Car's Division List to see whether it can be
#	      routed to the Industry for loading.
#
#	      ------------------------------------------------------
	      if {$CrsDivList($Cx) == {} || \
		  [string first "$IndDivS" "$CrsDivList($Cx)"] >= 0} {
		set LastIx $Ix
		incr RouteCars
#	        puts stderr "*** CarAssignmentProcedure: Cx: $Cx, Ix: $Ix"
		set HaveDest 1
		break
	      }
	      if {$CrsFixedRoute($Cx) == {Y}} {continue}
#	      ------------------------------------------------------
#
#	      Last chance for an empty -- if the car is offline then
#	      we let it go to any destination where it can be loaded.
#	      
#	      ------------------------------------------------------
	      if {$AssignLoop == 2 && $PassLoop == 2} {
		if {$IndsType($CrsLoc($Cx)) == {O}} {
		  set LastIx $Ix
		  incr RouteCars
#	          puts stderr "*** CarAssignmentProcedure: Cx: $Cx, Ix: $Ix"
		  set HaveDest 1
		  break
		}
	      }
#	      END of Empty Car case
#	      ===========================================================
#	      LOADED CARS
#	      ===========================================================
	    } else {
#	      $CrsTmpStatus($Cx) == {L}
#	      If the Car and the Industry are in the same area AND
#	      the Industry is Offline and the Car is Offline, then
#	      do not assign the Car to the Industry.
#	      --------------------------------------------------------
	      if {$DivsArea($CarDivI) == $DivsArea($IndDivI)} {
		if {$IndsType($Ix) == {O} && $IndsType($CrsLoc($Cx)) != {I}} {continue}
	      }
#	      When the Car is loaded where it can go is under control
#	      of the Industry's Division List
#	      -------------------------------------------------------
	      set DestList "$IndsDivList($CrsLoc($Cx))"
#
#	      CHANGE 6/24/96 -- As a last resort, use the car's list
#	      of home divisions as possible destinations. Usually we
#	      got this far because the car is at an industry outside
#	      of its home divisions, that does NOT ship to the car's
#	      home divisions.
#	      ------------------------------------------------------
	      if {$AssignLoop == 2 && $PassLoop == 2} {
#		Oops! Since I allow an offline car to be routed to
#		any destination of the shipper, I do not use a car
#		home division list in that case.
#		--------------------------------------------------
#		if {$IndsType($CrsLoc($Cx)) == {I}} {}
		  set DestList "$CrsDivList($Cx))"
#		{}
	      }
#	      END CHANGE 6/24/96
#	      ------------------
	      if {"$DestList" == {} || \
		  [string first "$IndDivS" "$DestList"] >= 0} {
#		----------------------------------------------------
#
#		The car's current industry can ship to this industry
#
#		Normally if the car itself is NOT in a home division
#		then it must be routed BACK to a home division
#
#		Now I make an exception -- if the car is offline, it
#		may be routed to any valid destination division from
#		the current industry.
#
#		The reason for this is that cars at offline industry
#		may be "relocated" somewhere in the same area, and I
#		don't check home divisions when I do it (see above).
#
#		----------------------------------------------------
		if {$AssignLoop == 2 && $PassLoop == 2} {
		  if {$IndsType($CrsLoc($Cx)) == {O}} {
#		    GOTO IndustryIsOk
		    set LastIx $Ix
		    incr RouteCars
#	   	    puts stderr "*** CarAssignmentProcedure: Cx: $Cx, Ix: $Ix"
		    set HaveDest 1
		    break
		  }
		}
		if {"$CrsDivList($Cx)" != {}} {
#		  If the car is not now in a home division ..
#		  -------------------------------------------
		  if {[string first "$CarDivS" "$CrsDivList($Cx)"] < 0} {
#		    ANd the industry is not in a home division ..
#		    ---------------------------------------------
		    if {[string first "$IndDivS" "$CrsDivList($Cx)"] < 0} {
#		      This industry cannot receive this car
		      continue
		    }
		  }
		}
		set LastIx $Ix
		incr RouteCars
#	        puts stderr "*** CarAssignmentProcedure: Cx: $Cx, Ix: $Ix"
		set HaveDest 1
		break
	      }
#	      If you get here you have failed
	    }
#	    Loaded Car case
	  }
#	  IndLoop
	  if {$HaveDest} {break}
	}
#	PassLoop
	if {$HaveDest} {break}
      }
#     IndPriorityLoop
      if {!$HaveDest} {
#	We failed to find a destination. If the car is EMPTY and if the
#	car is sitting at an ONLINE industry, then assign this car just
#	to move to the industry's home yard.
#	IF AssignLoop% = 2 THEN
#
#	  IF CrsTmpStatus(Cx%) = "E" AND IndsType(CrsLoc%(Cx%)) = "I" THEN
#
#	    Ix% = DivsHome%(StnsDiv%(IndsStation%(CrsLoc%(Cx%))))
#
#	    GOTO HaveDest
#
#	  END IF
#
#	END IF ' AssignLoop% = 2 i.e. last chance
#
#	If we fall into this code, then we have failed to find any
#	destination for this car -- so just leave it alone for now.
	set Ix $CrsLoc($Cx)
	set CrsTmpStatus($Cx) $CrsStatus($Cx)
      }
#HaveDest:
#      puts stderr "*** CarAssignmentProcedure: Cx = $Cx, Ix = $Ix, HaveDest = $HaveDest"
      set CrsDest($Cx) $Ix
      set CrsStatus($Cx) $CrsTmpStatus($Cx)
#     Adjust the used assignment space for this industry -
#     Should I do this only if the car is not at its dest?
#     ----------------------------------------------------
      incr IndsUsedLen($Ix) $CrsLen($Cx)
      if {$Ix != $CrsLoc($Cx)} {
#	Whenever a car receives an assignment to move somewhere else
#	we count this as 1 assignment for our statistics.
	incr CrsAssigns($Cx)
	[SN LogWindow] insert end "Assign $CrsRR($Cx) $CrsNum($Cx) $CarTypes($CrsType($Cx)) is "
  	GetCarStatus $Cx Status CarTypeDesc
	[SN LogWindow] insert end "$Status"
	[SN LogWindow] insert end " Now at $IndsName($CrsLoc($Cx))"
	[SN LogWindow] insert end " Send to $IndsName($CrsDest($Cx))"
	[SN LogWindow] insert end " IndsAssignLen = $IndsAssignLen($CrsDest($Cx))"
	[SN LogWindow] insert end " IndsUsedLen = $IndsUsedLen($CrsDest($Cx))\n"
	update
      }
#CarLoopNext:
#      set HaveDest 0
    }
  WIP 100 {100% Done}
  }
  set Total 0
  set hflag 1
  WIP_Start "Car Assignment In Progress\nCars without assignments"
  set Tenth [expr (100.0 / double($TotalCars))]
  set Done 10
  WIP 0 {0% Done}
  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    set DonePer [expr $Cx * $Tenth]
    if {$DonePer >= $Done} {
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      incr Done 10
    }
    if {$CrsLoc($Cx) == $CrsDest($Cx)} {
      if {$hflag} {
	[SN LogWindow] insert end "\n\nCars without assignments --\n"
	set hflag 0
      }
      [SN LogWindow] insert end "$CrsRR($Cx) $CrsNum($Cx)"
      [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
      TabText [SN LogWindow] 20
      [SN LogWindow] insert end "$CarTypes($CrsType($Cx))"
      [SN LogWindow] mark set insert [[SN LogWindow] index end-1c]
      TabText [SN LogWindow] 48
      [SN LogWindow] insert end " @ $IndsName($CrsLoc($Cx))\n"
      incr Total
      if {$Total == 20} {
	update
	set Total 0
      }
    }
  }
  if {$Total > 0} {
    [SN LogWindow] insert end "\n"
  }
  WIP_Done  
}

# Procedure: IndustryTakesCar
proc IndustryTakesCar {Cx Ix} {

#  puts stderr "*** IndustryTakesCar $Cx $Ix"

  global CrsTmpStatus
  global IndsLoadTypes
  global IndsEmptyTypes
  global CrsType
#  puts stderr "*** IndustryTakesCar: CrsTmpStatus($Cx): $CrsTmpStatus($Cx)"
#  puts stderr "*** IndustryTakesCar: CrsType($Cx): $CrsType($Cx)"
#  puts stderr "*** IndustryTakesCar: IndsEmptyTypes($Ix): $IndsEmptyTypes($Ix)"
#  puts stderr "*** IndustryTakesCar: IndsLoadTypes($Ix): $IndsLoadTypes($Ix)"
  if {$CrsTmpStatus($Cx) == {E}} {
    if {[string first "$CrsType($Cx)" "$IndsEmptyTypes($Ix)"] >= 0} {
      return 1
    }
  } elseif {"$CrsTmpStatus($Cx)" == {L}} {
    if {[string first "$CrsType($Cx)" "$IndsLoadTypes($Ix)"] >= 0} {
      return 1
    }
  }
  return 0
}

# Procedure: FixedRouteMirrorCheck
proc FixedRouteMirrorCheck {Cx Ix} {
# --------------------------------------------------------
# ENHANCEMENT -- Check for fixed route cars being mirrored
# --------------------------------------------------------
  global CrsFixedRoute
  global StnsDiv
  global IndsStation
  global DivsSymbol
  global CrsTmpStatus
  global CrsDivList
  global IndsDivList
# (Note that YesNo% is assumed to be TRUE ...)
  if {$CrsFixedRoute($Cx) != {Y}} {return 1}
  set MirrorDivI $StnsDiv($IndsStation($Ix))
  set MirrorDivS "$DivsSymbol($MirrorDivI)"
# if  the car is loaded --
#
#  Make sure the industry's division is included in this car's home list.
  if {$CrsTmpStatus($Cx) == {L}} {
    if {[string first "$MirrorDivS" "$CrsDivList($Cx)"] < 0} {
      return 0
    }
  }
# If the car is empty --
#
#  The industry's division list (normally only applicable to loaded cars)
#  must have a division in common with the car's home division list. When
#  an assignment is made (later), this empty fixed route car is directed
#  by the industry's division list and it's own home list.
  if {$CrsTmpStatus($Cx) == {E}} {
    foreach PxDiv [split "$IndsDivList($Ix)" {}] {
      if {[string first "$PxDiv" "$CrsDivList($Cx)"] >= 0} {return 1}
    }
    return 0
  }
  return 1
}

# Procedure: RunOneTrain
proc RunOneTrain {} {
  GetIndustryCarCounts
  global LimitCars
  global SwitchListPickLoc
  global SwitchListPickCar
  global SwitchListPickTrain
  global SwitchListLastTrain
  global SwitchListDropStop
  for {set Cx 1} {$Cx <= $LimitCars} {incr Cx} {
    set SwitchListPickLoc($Cx) -1
    set SwitchListPickCar($Cx) 0
    set SwitchListPickTrain($Cx) 0
  }

# .selectTrain
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 7.4 (Tcl/Tk/XF)
# Tk version: 4.0
# XF version: 2.4
#

  # build widget .selectTrain
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .selectTrain"
  } {
    catch "destroy .selectTrain"
  }
  toplevel .selectTrain 

  # Window manager configurations
  wm maxsize .selectTrain 1024 768
  wm minsize .selectTrain 0 0
  set x [expr ([winfo screenwidth .] / 2) - 200]
  set y [expr ([winfo screenheight .] / 2) - 75]
  wm geometry .selectTrain "500x250+$x+$y"
  wm transient .selectTrain .
  wm title .selectTrain {Select Train To Run}


  # build widget .selectTrain.frame
  frame .selectTrain.frame

  # build widget .selectTrain.frame.scrollbar3
  scrollbar .selectTrain.frame.scrollbar3 \
    -command {.selectTrain.frame.listbox1 xview} \
    -orient {horizontal} \
    -relief {raised}

  # build widget .selectTrain.frame.scrollbar2
  scrollbar .selectTrain.frame.scrollbar2 \
    -command {.selectTrain.frame.listbox1 yview} \
    -relief {raised}

  # build widget .selectTrain.frame.listbox1
  listbox .selectTrain.frame.listbox1 \
    -relief {raised} \
    -selectmode {single} \
    -xscrollcommand {.selectTrain.frame.scrollbar3 set} \
    -yscrollcommand {.selectTrain.frame.scrollbar2 set}
  # bindings
  bind .selectTrain.frame.listbox1 <1> {
    if {![catch "%W get [%W index @%x,%y]" line]} {
      .selectTrain.frame1.label3 configure -text "[lindex [split $line { }] 1]"
    }
  }

  # build widget .selectTrain.frame1
  frame .selectTrain.frame1 \
    -borderwidth {2}

  # build widget .selectTrain.frame1.button2
  button .selectTrain.frame1.button2 \
    -command {
	if {"[selection own]" == {.selectTrain.frame.listbox1}} {
	  set line "[selection get]"
	  set Tx [lindex [split $line { }] 0]
	  InternalRunOneTrain $Tx
	}} \
    -padx {9} \
    -pady {3} \
    -text {Run:}

  # build widget .selectTrain.frame1.label3
  label .selectTrain.frame1.label3 \
    -relief {raised}

  # build widget .selectTrain.frame1.button4
  button .selectTrain.frame1.button4 \
    -command {if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .selectTrain"
  } {
    catch "destroy .selectTrain"
  }} \
    -padx {9} \
    -pady {3} \
    -text {Done}

  # pack master .selectTrain.frame
  pack configure .selectTrain.frame.scrollbar2 \
    -fill y \
    -side right
  pack configure .selectTrain.frame.listbox1 \
    -expand 1 \
    -fill both
  pack configure .selectTrain.frame.scrollbar3 \
    -fill x \
    -side bottom

  # pack master .selectTrain.frame1
  pack configure .selectTrain.frame1.button2 \
    -side left
  pack configure .selectTrain.frame1.label3 \
    -expand 1 \
    -fill both \
    -side left
  pack configure .selectTrain.frame1.button4 \
    -side right

  # pack master .selectTrain
  pack configure .selectTrain.frame \
    -fill both
  pack configure .selectTrain.frame1 \
    -fill x
# end of widget tree

  global TotalTrains
  global TrnName
  global TrnType
  global TrnShift
  global ShiftNumber
  global TrnDesc
  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
    set show 1
    if {[catch "set TrnName($Tx)" name]} {
      set show 0
    } elseif {"$name" == {}} {
      set show 0
    }
    if {[catch "set TrnType($Tx)" type]} {
      set show 0
    } elseif {"$type" == {B}} {
      set show 0
    }
    if {$show && $TrnShift($Tx) != $ShiftNumber} {
      set show 0
    }
    if {$show} {
      .selectTrain.frame.listbox1 insert end "$Tx $name $TrnType($Tx) $TrnDesc($Tx)"
    }
  }

  update idletasks
  grab .selectTrain
  tkwait window .selectTrain

  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .trainRunStatus"
  } {
    catch "destroy .trainRunStatus"
  }
}

# Procedure: RunAllTrains
proc RunAllTrains {} {
  GetIndustryCarCounts
  global LimitCars
  global SwitchListPickLoc
  global SwitchListPickCar
  global SwitchListPickTrain
  global SwitchListLastTrain
  global SwitchListDropStop
  for {set Cx 1} {$Cx <= $LimitCars} {incr Cx} {
    set SwitchListPickLoc($Cx) -1
    set SwitchListPickCar($Cx) 0
    set SwitchListPickTrain($Cx) 0
    set SwitchListDropStop($Cx) 0
  }
  global RanAllTrains
  incr RanAllTrains

# First run the boxmoves. These will pick up cars from various industries
# and deliver them to yards. From there manifests and locals will move the
# cars as part of the op session.

  global TotalTrains
  global TrnType
  global TrnShift
  global ShiftNumber

  global BoxMove
  set BoxMove 1

  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
    if {[catch "set TrnType($Tx)" x]} {set TrnType($Tx) {}}
    if {"$TrnType($Tx)" == {B}} {
      InternalRunOneTrain $Tx
    }
  }

  set BoxMove 0

  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
    if {"$TrnType($Tx)" == {M} || "$TrnType($Tx)" == {W}} {
      if {$TrnShift($Tx) == $ShiftNumber} {
	InternalRunOneTrain $Tx
      }
    }
  }

# Lastly, run the box moves a second time. This will move cars from yards
# to their final destinations.

  set BoxMove 1

  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
    if {"$TrnType($Tx)" == {B}} {
      InternalRunOneTrain $Tx
    }
  }

  set BoxMove 0

# Pause before we continue

  AlertBox {Trains have all run, about to generate printouts...} {} {350x150} {Alert Box} {Continue}

  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .trainRunStatus"
  } {
    catch "destroy .trainRunStatus"
  }

#============================================================================
#
# All trains have run -- check for YARD switchlists
#
#============================================================================

  ShowBanner

  global PrintAlpha
  global PrintAtwice
  global PrintList
  global PrintLtwice
  global PrintDispatch
  global TotalIndustries
  global IndsType
  global IndsDivList
  global IndsPriority
  global IndsName
  global IndsStation
  global StnsName
  global TotalCars
  global CrsRR
  global CrsNum
  global CrsLen
  global CrsDest
  global TrnName
  global PickIndex
  global TrnPrint
  global TrnStops

  global MaxTrainStops

  set Forend 0

  if {$PrintAlpha} {
    set Forend 1
    if {$PrintAtwice} {set Forend 2}
    for {set Copies 1} {$Copies <= $Forend} {incr Copies} {
      [SN LogWindow] insert end "Printing Yard Switchlist -- by Car\n"
      [SN LogWindow] see end
      update
      for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
	if {[catch "set IndsType($Ix)"]} {continue}
	if {"$IndsType($Ix)" == {Y} && [string first {A} "$IndsDivList($Ix)"] >= 0} {
	  if {$IndsPriority($Ix) < $Copies} {continue}

	  set PageNum 1
	  set LineNum -1
	  set TmpTotalCars 0
#	  set Listcon 0

	  [SN LogWindow] insert end "Cars List for $IndsName($Ix)\n"
	  [SN LogWindow] see end
	  update

	  set LastIndex 0
	  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
	    for {set Gx [expr $LastIndex + 1]} {$Gx <= $PickIndex} {incr Gx} {
	      set Exp1 [expr $SwitchListPickCar($Gx) == $Cx]
	      set Exp2 [expr $SwitchListPickLoc($Gx) == $Ix]
	      if {$Exp1 && $Exp2} {break}
	    }
	    if {$Gx > $PickIndex} {
	      set LastIndex 0
	      continue
	    }
	    if {$LineNum < 0} {
	      if {$PageNum > 1} {PrintFormFeed}
	      PrintSystemBanner
	      putPrinterNormal
	      putPrinterString "YARD SWITCH LIST BY CAR FOR -- $IndsName($Ix)"
	      putPrinterTab 72
	      putPrinterLine "Page $PageNum"
	      putPrinterNarrow
	      putPrinterTab 4
	      putPrinterString {Car}
	      putPrinterTab 24
	      putPrinterString {Length}
	      putPrinterTab 34
	      putPrinterString {Train}
	      putPrinterTab 50
	      putPrinterString {Car Type}
	      putPrinterTab 86
	      putPrinterLine {Destination}
	      putPrinterLine {}
	      set Listcon 8
	      incr PageNum
	      set LineNum 53
	    }
	    if {$Listcon == 0} {
	      putPrinterLine {}
	      incr LineNum -1
	      set Listcon 8 
	    }
	    GetCarStatus $Cx Status CarTypeDesc
	    putPrinterNarrow
	    putPrinterTab 4
	    putPrinterString "$CrsRR($Cx)"
	    putPrinterTab 14
	    putPrinterString "$CrsNum($Cx)"
	    putPrinterTab 24
	    putPrinterString "$CrsLen($Cx)ft"
	    putPrinterTab 34
	    putPrinterString "$TrnName($SwitchListPickTrain($Gx))"
	    putPrinterTab 50
	    putPrinterString "$CarTypeDesc"
	    putPrinterTab 86
	    putPrinterLine "$IndsName($CrsDest($Cx))"
	    incr Listcon -1
	    incr LineNum -1
	    incr TmpTotalCars
#		This silliness will cause a car to be printed twice, if
#		it is picked up twice from the same location!
	    set LastIndex $Gx
	    incr Cx -1
	  }
	  putPrinterNormal
	  putPrinterTab 10
	  putPrinterLine "Total cars for pickup $TmpTotalCars"
	  PrintFormFeed
	}
      }
    }
  }

#============================================================================
#
# All trains have run -- check for TRAIN PICKUP switchlists
#
#============================================================================

  ShowBanner

  if {$PrintList} {
    set Forend 1
    if {$PrintLtwice} {set Forend 2}
    for {set Copies 1} {$Copies <= $Forend} {incr Copies} {
      [SN LogWindow] insert end "Printing Yard Pickups -- by Train\n"
      [SN LogWindow] see end
      update
      for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
	if {[catch "set IndsType($Ix)"]} {continue}
	if {"$IndsType($Ix)" == {Y}} {
	  if {[string first {P} "$IndsDivList($Ix)"] == -1} {continue}
	  if {$IndsPriority($Ix) < $Copies} {continue}

	  set PageNum 1
	  set LineRem 0

	  [SN LogWindow] insert end "Check Train Pickups List for $IndsName($Ix)\n"
	  [SN LogWindow] see end
	  update

	  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
	    if {[catch "set TrnType($Tx)"]} {continue}
	    if {[catch "set TrnPrint($Tx)"]} {continue}
	    if {"$TrnType($Tx)" == {B}} {continue}
	    if {"$TrnPrint($Tx)" == {N}} {continue}
	    if {$TrnShift($Tx) != $ShiftNumber} {continue}
	    set TmpTotalCars 0
	    for {set Gx 1} {$Gx <= $PickIndex} {incr Gx} {
	      set Exp1 [expr $SwitchListPickLoc($Gx) == $Ix]
	      set Exp2 [expr $SwitchListPickTrain($Gx) == $Tx]
	      if {$Exp1 && $Exp2} {
		incr TmpTotalCars
	      }
	    }
	    if {$TmpTotalCars > 0} {
	      if {$LineRem < [expr $TmpTotalCars + 5]} {
		if {$PageNum > 1} {PrintFormFeed}
		PrintSystemBanner
		putPrinterNormal
		putPrinterString "YARD PICKUPS LIST BY TRAIN FOR -- $IndsName($Ix)"
		putPrinterTab 72
		putPrinterLine "Page $PageNum"
	 	putPrinterNarrow

		set LineRem 58
		incr PageNum
	      }

	      [SN LogWindow] insert end "Pickup Report for Train $TrnName($Tx)\n"
	      [SN LogWindow] see end
	      update

	      putPrinterNormal
	      putPrinterDouble
	      putPrinterString "$TrnName($Tx)"
	      putPrinterTab 12
	      putPrinterLine "pickups = $TmpTotalCars"
	      putPrinterNarrow
	      putPrinterTab 6
	      putPrinterString {Car}
	      putPrinterTab 26
	      putPrinterString {Length}
	      putPrinterTab 34
	      putPrinterString {Type}
	      putPrinterTab 64
	      putPrinterString {Next Stop}
	      putPrinterTab 94
	      putPrinterString {Last Train}
	      putPrinterTab 106
	      putPrinterLine {Destination}
	      putPrinterLine {}

	      incr LineRem -5

#		 Print cars in train-block order!!
#		----------------------------------
	      set LastPx 0
	      for {set Px 2} {$Px <= $MaxTrainStops} {incr Px} {
		set StopList($Px) $TrnStops($Tx,$Px)
		if {$StopList($Px) > 0} {set LastPx $Px}
	      }
	      for {set Px 2} {$Px <= $LastPx} {incr Px} {
		if {"$TrnType($Tx)" == {M}} {
		  set Station "$StnsName($IndsStation($StopList($Px)))"
		} else {
		  set Station "$StnsName($StopList($Px))"
		}
		for {set Gx 1} {$Gx <= $PickIndex} {incr Gx} {
		  if {$SwitchListPickTrain($Gx) == $Tx} {
		    set Exp1 [expr $SwitchListPickLoc($Gx) == $Ix]
		    if {$Exp1} {
		      set Exp2 [expr $SwitchListDropStop($Gx) == $StopList($Px)]
		      if {$Exp2} {
			set Cx $SwitchListPickCar($Gx)
			if {$SwitchListLastTrain($Gx) == 0} {
			  set LastTrain {-}
			} else {
			  set LastTrain "$TrnName($SwitchListLastTrain($Gx))"
			}

			GetCarStatus $Cx Status CarTypeDesc

			putPrinterNarrow
			putPrinterTab 6
			putPrinterString "$CrsRR($Cx)"
			putPrinterTab 16
			putPrinterString "$CrsNum($Cx)"
			putPrinterTab 26
			putPrinterString "$CrsLen($Cx)ft"
			putPrinterTab 34
			putPrinterString "$CarTypeDesc"
			putPrinterTab 64
			putPrinterString "$Station"
			putPrinterTab 94
			putPrinterString "$LastTrain"
			putPrinterTab 106
			putPrinterLine "$IndsName($CrsDest($Cx))"

			incr LineRem -1

			incr TmpTotalCars -1
		      }
		    }
		  }
		  if {$TmpTotalCars <= 0} {break}
		}
		if {$TmpTotalCars <= 0} {break}
	      }
	      putPrinterNormal
	      putPrinterLine {}
	      incr LineRem -2
#	    TmpTotalCars% > 0
	    }
	  }
	  PrintFormFeed
        }
      }
    }
    putPrinterNormal
  }

#============================================================================
#
# All trains have run -- check for TRAIN DROP switchlists
#
#============================================================================

  ShowBanner

  if {$PrintList} {
    set Forend 1
    if {$PrintLtwice} {set Forend 2}
    for {set Copies 1} {$Copies <= $Forend} {incr Copies} {
      [SN LogWindow] insert end "Printing Yard Drop Offs -- by Train\n"
      [SN LogWindow] see end
      update
      for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
	if {[catch "set IndsType($Ix)"]} {continue}
	if {"$IndsType($Ix)" == {Y}} {
	  if {[string first {D} "$IndsDivList($Ix)"] == -1} {continue}
	  if {$IndsPriority($Ix) < $Copies} {continue}

	  set PageNum 1
	  set LineRem 0

	  [SN LogWindow] insert end "Check Train Dropoffs List for $IndsName($Ix)\n"
	  [SN LogWindow] see end
	  update

	  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
	    if {[catch "set TrnType($Tx)"]} {continue}
	    if {[catch "set TrnPrint($Tx)"]} {continue}
	    if {"$TrnType($Tx)" == {B}} {continue}
	    if {"$TrnPrint($Tx)" == {N}} {continue}
	    if {$TrnShift($Tx) != $ShiftNumber} {continue}
	    set TmpTotalCars 0
	    for {set Gx 1} {$Gx <= $PickIndex} {incr Gx} {
	      if {"$TrnType($Tx)" == {M}} {
		set Exp1 [expr $SwitchListDropStop($Gx) == $Ix]
	      } else {
		set Exp1 [expr $SwitchListDropStop($Gx) == $IndsStation($Ix)]
	      }
	      set Exp2 [expr $SwitchListPickTrain($Gx) == $Tx]
	      if {$Exp1 && $Exp2} {
		incr TmpTotalCars  
	      }
	    }
	    if {$TmpTotalCars > 0} {
	      if {$LineRem < [expr $TmpTotalCars + 5]} {
		if {$PageNum > 1} {PrintFormFeed}
		PrintSystemBanner
		putPrinterNormal
		putPrinterString "YARD DROPOFFS LIST BY TRAIN FOR -- $IndsName($Ix)"
		putPrinterTab 72
		putPrinterLine "Page $PageNum"
	 	putPrinterNarrow

		set LineRem 58
		incr PageNum
	      }
	      [SN LogWindow] insert end "Drop Report for Train $TrnName($Tx)\n"
	      [SN LogWindow] see end
	      update

	      putPrinterNormal
	      putPrinterDouble
	      putPrinterString "$TrnName($Tx)"
	      putPrinterTab 12
	      putPrinterLine "dropoffs = $TmpTotalCars"
	      putPrinterNarrow
	      putPrinterTab 6
	      putPrinterString {Car}
	      putPrinterTab 26
	      putPrinterString {Length}
	      putPrinterTab 34
	      putPrinterString {Type}
	      putPrinterTab 64
	      putPrinterString {Destination}
	      putPrinterTab 92
	      putPrinterLine {Next Train -- this session!}
	      putPrinterLine {}

	      incr LineRem -5

#		       Print cars in alphabetical order!!
#		      -----------------------------------

	      for {set Gx 1} {$Gx <= $PickIndex} {incr Gx} {
		if {"$TrnType($Tx)" == {M}} {
		   set Exp1 [expr $SwitchListDropStop($Gx) == $Ix]
		} else {
		   set Exp1 [expr $SwitchListDropStop($Gx) == $IndsStation($Ix)]
		}
		set Exp2 [expr $SwitchListPickTrain($Gx) == $Tx]
		if {$Exp1 && $Exp2} {
		  set Cx $SwitchListPickCar($Gx)
#		  See whether this car is picked up again!
		  set NextTrain {-}
		  for {set NextGx [expr $Gx + 1]} {$NextGx <= $PickIndex} {incr NextGx} {
		    if {$SwitchListPickCar($NextGx) == $Cx} {
		      set NextTrain "$TrnName($SwitchListPickTrain($NextGx))"
		      break
		    }
		  }

		  GetCarStatus $Cx Status CarTypeDesc

		  putPrinterNarrow
		  putPrinterTab 6 
		  putPrinterString "$CrsRR($Cx)"
		  putPrinterTab 16
		  putPrinterString "$CrsNum($Cx)"
		  putPrinterTab 26
		  putPrinterString "$CrsLen($Cx)ft"
		  putPrinterTab 34
		  putPrinterString "$CarTypeDesc"
		  putPrinterTab 64
		  putPrinterString "$Station"
		  putPrinterTab 92
		  putPrinterLine "$NextTrain"

		  incr LineRem -1

		  incr TmpTotalCars -1
		  if {$TmpTotalCars <= 0} {break}
		}
	      }
	      # Next Gx
	      putPrinterNormal
	      putPrinterLine {}
	      incr LineRem -2
	    }
	    # TmpTotalCars > 0
	  }
	  # next Tx
	  PrintFormFeed
	}
      }
    }
    # copes
    putPrinterNormal
  }

# Reset the SwitchList index after printing all reports
  
  set PickIndex 0

#==================================================================
#
#    Print the dispatcher's train sheets
#
#==================================================================

  if {$PrintDispatch} {
    PrintDispatcher {Manifests} {M}
    PrintDispatcher {Locals} {W}
  }
}

# Procedure: PrintDispatcher
proc PrintDispatcher {Banner TrainType} {

  PrintSystemBanner
  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 6
  putPrinterLine "DISPATCHER Report - $Banner"
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}
  putPrinterString {name}
  putPrinterTab 26
  putPrinterString {engine}
  putPrinterTab 50
  putPrinterString {cab}
  putPrinterTab 60
  putPrinterString {engineer}
  putPrinterTab 82
  putPrinterString {depart}
  putPrinterTab 102
  putPrinterString {arrive}
  putPrinterTab 122
  putPrinterLine {total cars}

  PrintDashedLine

  putPrinterLine {}

  global TotalTrains
  global ShiftNumber
  global TrnShift
  global TrnName
  global TrnType
  global SwitchListPickTrain

  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
    if {[catch "set TrnShift($Tx)"]} {continue}
    if {$TrnShift($Tx) == $ShiftNumber} {
      if {"$TrnType($Tx)" == "$TrainType"} {
	set Total 0
	foreach Gx [array names SwitchListPickTrain] {
	  if {$SwitchListPickTrain($Gx) == $Tx} {incr Total}
	}
	if {$Total == 0} {continue}

	putPrinterNormal
	putPrinterDouble
	putPrinterString "$TrnName($Tx)"
	putPrinterTab 8
	putPrinterLine "______ __ _____ __/__ __/__  $Total"
	putPrinterLine {}
      }
    }
  }

  PrintFormFeed

}

# Procedure: GetIndustryCarCounts
proc GetIndustryCarCounts {} {
  global IndsUsedLen
  global CrsLoc
  global CrsLen
  global TotalIndustries
  global TotalCars

  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    set IndsUsedLen($Ix) 0
  }

  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    if {$CrsLoc($Cx) > -1 && $CrsLoc($Cx) <= $TotalIndustries} {
      incr IndsUsedLen($CrsLoc($Cx)) $CrsLen($Cx)
    }
  }
}


# Procedure: InternalRunOneTrain
proc InternalRunOneTrain {Tx} {
  global MaxTrainStops
  global TrnStops
  global MaxCarsInTrain
  global TrnCarTypes
  global TrnMxLen
  global TrnMxCars
  global TrnMxWeigh
  global TrnMxClear
  global TrnName
  global Printem
  global TrnPrint
  global TotalIndustries
  global IndsRemLen
  global IndsTrackLen
  global IndsUsedLen
  global TrnType
  global Consist
  global StopList
  global LastPx

  set LastPx 0
  for {set Px 1} {$Px <= $MaxTrainStops} {incr Px} {
    set StopList($Px) $TrnStops($Tx,$Px)
    if {$StopList($Px) > 0} {set LastPx $Px}
  }

  for {set Lx 1} {$Lx <= $MaxCarsInTrain} {incr Lx} {
    set Consist($Lx) 0
  }

  global CarTypesList
  set CarTypesList "$TrnCarTypes($Tx)"
  global TrainLen
  set TrainLen 0
  global TrainCars
  set TrainCars 0
  global TrainTons
  set TrainTons 0
  global TrainLoads
  set TrainLoads 0
  global TrainEmpties
  set TrainEmpties 0
  global TrainLongest
  set TrainLongest 0

  global TotalPickups
  set TotalPickups 0
  global TotalLoads
  set TotalLoads 0
  global TotalTons
  set TotalTons 0
  global TotalRevenueTons
  set TotalRevenueTons 0

  global TrainMaxLen
  set TrainMaxLen $TrnMxLen($Tx)
  global TrainMaxCars
  set TrainMaxCars $TrnMxCars($Tx)
  global TrainClass
  set TrainClass $TrnMxWeigh($Tx)
  global TrainPlate
  set TrainPlate $TrnMxClear($Tx)

  InitStatusBox $Tx

  set CurrentGrab "[grab current .]"
  catch "grab .trainRunStatus"


  global TrainPrintOK
  set TrainPrintOK 0

  if {$Printem && "$TrnPrint($Tx)" == {P}} {set TrainPrintOK 1}
  global BoxMove
  if {$BoxMove} {set TrainPrintOK 0}

  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    set IndsRemLen($Ix) [expr $IndsTrackLen($Ix) - $IndsUsedLen($Ix)]
  }

  if {"$TrnType($Tx)" == {W}} {RunOneLocal $Tx}
  if {"$TrnType($Tx)" == {B}} {RunOneLocal $Tx}
  if {"$TrnType($Tx)" == {P}} {RunOnePassenger $Tx}
  if {"$TrnType($Tx)" == {M}} {RunOneManifest $Tx}

  
  if {"$CurrentGrab" != {}} {
    catch "grab $CurrentGrab"
    raise $CurrentGrab
  } else {
    grab release .trainRunStatus
  }

}

# Procedure: InitStatusBox
proc InitStatusBox {Tx} {

  global TrnName
  global LastPx
  global TrainMaxLen
  global TrainMaxCars

  if {[winfo exists .trainRunStatus]} {
    wm title .trainRunStatus "Running status of train $TrnName($Tx)"
    .trainRunStatus.scale4 config -to $LastPx
    .trainRunStatus.scale5 config -to $TrainMaxLen
    .trainRunStatus.scale6 config -to $TrainMaxCars
    return
  }


# .trainRunStatus
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 7.4 (Tcl/Tk/XF)
# Tk version: 4.0
# XF version: 2.4
#

  # build widget .trainRunStatus
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .trainRunStatus"
  } {
    catch "destroy .trainRunStatus"
  }
  toplevel .trainRunStatus 

  # Window manager configurations
  wm maxsize .trainRunStatus 1024 768
  wm minsize .trainRunStatus 0 0
  set x [expr ([winfo screenwidth .] / 2) - 200]
  set y [expr ([winfo screenheight .] / 2) - 75]
  wm geometry .trainRunStatus "250x350+$x+$y"
  wm transient .trainRunStatus .
  wm title .trainRunStatus "Running status of train $TrnName($Tx)"


  # build widget .trainRunStatus.frame1
  frame .trainRunStatus.frame1 \
    -borderwidth {2}

  # build widget .trainRunStatus.frame1.label2
  label .trainRunStatus.frame1.label2 \
    -text {Currently at:}

  # build widget .trainRunStatus.frame1.label3
  label .trainRunStatus.frame1.label3 \
    -textvariable {CurrentStationName} -anchor e

  # build widget .trainRunStatus.label1
  label .trainRunStatus.label1 \
    -textvariable {CurrentStopName}

  # build widget .trainRunStatus.frame2
  frame .trainRunStatus.frame2 \
    -borderwidth {2}

  # build widget .trainRunStatus.frame2.label2
  label .trainRunStatus.frame2.label2 \
    -text {Train Length:}

  # build widget .trainRunStatus.frame1.label3
  label .trainRunStatus.frame2.label3 \
    -textvariable {TrainLen} -anchor e

  # build widget .trainRunStatus.frame3
  frame .trainRunStatus.frame3 \
    -borderwidth {2}

  # build widget .trainRunStatus.frame3.label2
  label .trainRunStatus.frame3.label2 \
    -text {Number of Cars:}

  # build widget .trainRunStatus.frame3.label3
  label .trainRunStatus.frame3.label3 \
    -textvariable {TrainCars} -anchor e

  # build widget .trainRunStatus.frame4
  frame .trainRunStatus.frame4 \
    -borderwidth {2}

  # build widget .trainRunStatus.frame4.label2
  label .trainRunStatus.frame4.label2 \
    -text {Train Tons:}

  # build widget .trainRunStatus.frame4.label3
  label .trainRunStatus.frame4.label3 \
    -textvariable {TrainTons} -anchor e

  # build widget .trainRunStatus.frame5
  frame .trainRunStatus.frame5 \
    -borderwidth {2}

  # build widget .trainRunStatus.frame5.label2
  label .trainRunStatus.frame5.label2 \
    -text {Train Loads:}

  # build widget .trainRunStatus.frame5.label3
  label .trainRunStatus.frame5.label3 \
    -textvariable {TrainLoads} -anchor e

  # build widget .trainRunStatus.frame6
  frame .trainRunStatus.frame6 \
    -borderwidth {2}

  # build widget .trainRunStatus.frame6.label2
  label .trainRunStatus.frame6.label2 \
    -text {Train Empties:}

  # build widget .trainRunStatus.frame6.label3
  label .trainRunStatus.frame6.label3 \
    -textvariable {TrainEmpties} -anchor e

  # build widget .trainRunStatus.frame7
  frame .trainRunStatus.frame7 \
    -borderwidth {2}

  # build widget .trainRunStatus.frame7.label2
  label .trainRunStatus.frame7.label2 \
    -text {Train Longest:}

  # build widget .trainRunStatus.frame7.label3
  label .trainRunStatus.frame7.label3 \
    -textvariable {TrainLongest} -anchor e

  # build widget .trainRunStatus.scale4
  scale .trainRunStatus.scale4 \
    -label {Stop:} \
    -takefocus 0\
    -orient {horizontal} \
    -showvalue {0} \
    -variable {CurrentStop} \
    -from 1 -to $LastPx
  # bindings
  bind .trainRunStatus.scale4 <B1-Motion> {NoFunction;break}
  bind .trainRunStatus.scale4 <B2-Motion> {NoFunction;break}
  bind .trainRunStatus.scale4 <Button-1> {NoFunction;break}
  bind .trainRunStatus.scale4 <Button-2> {NoFunction;break}
  bind .trainRunStatus.scale4 <ButtonRelease-1> {NoFunction;break}
  bind .trainRunStatus.scale4 <Control-Button-1> {NoFunction;break}
  bind .trainRunStatus.scale4 <Enter> {NoFunction;break}
  bind .trainRunStatus.scale4 <Key-Down> {NoFunction;break}
  bind .trainRunStatus.scale4 <Key-End> {NoFunction;break}
  bind .trainRunStatus.scale4 <Key-Home> {NoFunction;break}
  bind .trainRunStatus.scale4 <Key-Left> {NoFunction;break}
  bind .trainRunStatus.scale4 <Key-Right> {NoFunction;break}
  bind .trainRunStatus.scale4 <Key-Up> {NoFunction;break}
  bind .trainRunStatus.scale4 <Leave> {NoFunction;break}
  bind .trainRunStatus.scale4 <Motion> {NoFunction;break}
  
  # build widget .trainRunStatus.scale5
  scale .trainRunStatus.scale5 \
    -label {Current Length:} \
    -takefocus 0\
    -orient {horizontal} \
    -showvalue {0} \
    -variable {TrainLen} \
    -from 0 -to $TrainMaxLen
  # bindings
  bind .trainRunStatus.scale5 <B1-Motion> {NoFunction;break}
  bind .trainRunStatus.scale5 <B2-Motion> {NoFunction;break}
  bind .trainRunStatus.scale5 <Button-1> {NoFunction;break}
  bind .trainRunStatus.scale5 <Button-2> {NoFunction;break}
  bind .trainRunStatus.scale5 <ButtonRelease-1> {NoFunction;break}
  bind .trainRunStatus.scale5 <Control-Button-1> {NoFunction;break}
  bind .trainRunStatus.scale5 <Enter> {NoFunction;break}
  bind .trainRunStatus.scale5 <Key-Down> {NoFunction;break}
  bind .trainRunStatus.scale5 <Key-End> {NoFunction;break}
  bind .trainRunStatus.scale5 <Key-Home> {NoFunction;break}
  bind .trainRunStatus.scale5 <Key-Left> {NoFunction;break}
  bind .trainRunStatus.scale5 <Key-Right> {NoFunction;break}
  bind .trainRunStatus.scale5 <Key-Up> {NoFunction;break}
  bind .trainRunStatus.scale5 <Leave> {NoFunction;break}
  bind .trainRunStatus.scale5 <Motion> {NoFunction;break}
  
  # build widget .trainRunStatus.scale6
  scale .trainRunStatus.scale6 \
    -label {Current Number of cars:} \
    -takefocus 0\
    -orient {horizontal} \
    -showvalue {0} \
    -variable {TrainCars} \
    -from 0 -to $TrainMaxCars
  # bindings
  bind .trainRunStatus.scale6 <B1-Motion> {NoFunction;break}
  bind .trainRunStatus.scale6 <B2-Motion> {NoFunction;break}
  bind .trainRunStatus.scale6 <Button-1> {NoFunction;break}
  bind .trainRunStatus.scale6 <Button-2> {NoFunction;break}
  bind .trainRunStatus.scale6 <ButtonRelease-1> {NoFunction;break}
  bind .trainRunStatus.scale6 <Control-Button-1> {NoFunction;break}
  bind .trainRunStatus.scale6 <Enter> {NoFunction;break}
  bind .trainRunStatus.scale6 <Key-Down> {NoFunction;break}
  bind .trainRunStatus.scale6 <Key-End> {NoFunction;break}
  bind .trainRunStatus.scale6 <Key-Home> {NoFunction;break}
  bind .trainRunStatus.scale6 <Key-Left> {NoFunction;break}
  bind .trainRunStatus.scale6 <Key-Right> {NoFunction;break}
  bind .trainRunStatus.scale6 <Key-Up> {NoFunction;break}
  bind .trainRunStatus.scale6 <Leave> {NoFunction;break}
  bind .trainRunStatus.scale6 <Motion> {NoFunction;break}
  
  # pack master .trainRunStatus.frame1
  pack configure .trainRunStatus.frame1.label2 \
    -side left
  pack configure .trainRunStatus.frame1.label3 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .trainRunStatus.frame2
  pack configure .trainRunStatus.frame2.label2 \
    -side left
  pack configure .trainRunStatus.frame2.label3 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .trainRunStatus.frame3
  pack configure .trainRunStatus.frame3.label2 \
    -side left
  pack configure .trainRunStatus.frame3.label3 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .trainRunStatus.frame4
  pack configure .trainRunStatus.frame4.label2 \
    -side left
  pack configure .trainRunStatus.frame4.label3 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .trainRunStatus.frame5
  pack configure .trainRunStatus.frame5.label2 \
    -side left
  pack configure .trainRunStatus.frame5.label3 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .trainRunStatus.frame6
  pack configure .trainRunStatus.frame6.label2 \
    -side left
  pack configure .trainRunStatus.frame6.label3 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .trainRunStatus.frame7
  pack configure .trainRunStatus.frame7.label2 \
    -side left
  pack configure .trainRunStatus.frame7.label3 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .trainRunStatus
  pack configure .trainRunStatus.frame1 \
    -fill x 
  pack configure .trainRunStatus.label1 \
    -fill x
  pack configure .trainRunStatus.frame2 \
    -fill x
  pack configure .trainRunStatus.frame3 \
    -fill x
  pack configure .trainRunStatus.frame4 \
    -fill x
  pack configure .trainRunStatus.frame5 \
    -fill x
  pack configure .trainRunStatus.frame6 \
    -fill x
  pack configure .trainRunStatus.frame7 \
    -fill x
  pack configure .trainRunStatus.scale4 \
    -fill x
  pack configure .trainRunStatus.scale5 \
    -fill x
  pack configure .trainRunStatus.scale6 \
    -fill x
# end of widget tree

}

# Procedure: RunOneLocal
proc RunOneLocal {Tx} {
# A local train runs YARD to STATION(S) to YARD
  global CrsPeek
  global TotalCars
  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    set CrsPeek($Cx) 0
  }
  global TotalPickups
  global Wayfreight
  global Deliver
  global CurStation
  global StopList
  global StnsDiv
  global DivsHome
  global LastPx
  global DidAction
  global OriginYard
  global TrainLastLocation
  global CurDiv

  set Wayfreight 1
  set Deliver 1
  set Px 1
  set CurStation $StopList($Px)
  set CurDiv $StnsDiv($CurStation)
  set OriginYard $DivsHome($CurDiv)
  set TrainLastLocation $DivsHome($StnsDiv($StopList($LastPx)))
  set DidAction 0

  PrintTrainLoc $Tx $CurStation $Px

  TrainLocalOriginate $Tx $Px
  if {$DidAction} {update;TrainPrintConsistSummary $Tx}

  for {set Px 2} {$Px < $LastPx} {incr Px} {
    set CurStation $StopList($Px)
    set CurDiv $StnsDiv($CurStation)
    set DidAction 0

    PrintTrainLoc $Tx $CurStation $Px

    TrainLocalDrops $Tx $Px
    TrainLocalPickups $Tx $Px

    if {$DidAction} {update;TrainPrintConsistSummary $Tx}
  }
  set Deliver 0
  set CurStation $StopList($LastPx)
  set CurDiv $StnsDiv($CurStation)
  set DidAction 0

  PrintTrainLoc $Tx $CurStation $LastPx

  TrainDropAllCars $Tx $Px $TrainLastLocation

  if {$TotalPickups > 0} {TrainPrintFinalSummary $Tx}  
}

# Procedure: PrintTrainLoc
proc PrintTrainLoc {Tx CurStation Px} {
  global Wayfreight
  global TrnName
  global StnsName
  global StopList
  global IndsName
  global CurrentStationName
  global CurrentStop
  global CurrentStopName
  set CurrentStop $Px
  set CurrentStationName "$StnsName($CurStation)"
  if {$Wayfreight} {
    set CurrentStopName "($StnsName($CurStation))"
  } else {
    set CurrentStopName "($IndsName($StopList($Px)))"
  }
  [SN LogWindow] insert end "$TrnName($Tx) is now at station $StnsName($CurStation) and stop = $StopList($Px)\n"
  [SN LogWindow] see end
  update
}

# Procedure: RunOnePassenger
proc RunOnePassenger {Tx} {
  global TrainPrintOK
  global StnsName
  global StopList
  global LastPx

  if {!$TrainPrintOK} {return}

  putPrinterLine {Station stop for passengers, mail, express}
  putPrinterLine {------------------------------------------}
  for {set Px 1} {$Px <= $LastPx} {incr Px} {
    putPrinterLine {}
    putPrinterTab 8
    putPrinterString "$StnsName($StopList($Px))"
  }
  putPrinterLine {}
  PrintFormFeed
}

# Procedure: RunOneManifest
proc RunOneManifest {Tx} {
# A manifest runs from INDUSTRY/YARD to INDUSTRY/YARD
  global Wayfreight
  global Deliver
  global StopList
  global CurInd
  global CurDiv
  global StnsDiv
  global DivsHome
  global LastPx
  global DidAction
  global CurStation
  global IndsStation
  global TotalPickups

  set Wayfreight 0
  set Deliver 0
  set Px 1
  set CurInd $StopList($Px)
  set CurStation $IndsStation($CurInd)
  set CurDiv $StnsDiv($CurStation)
  set TrainLastLocation $StopList($LastPx)
  set DidAction 0

  PrintTrainLoc $Tx $CurStation $Px

  TrainManifestPickups $Tx $Px
  if {$DidAction} {update;TrainPrintConsistSummary $Tx}

  for {set Px 2} {$Px < $LastPx} {incr Px} {
    set CurInd $StopList($Px)
    set CurStation $IndsStation($CurInd)
    set CurDiv $StnsDiv($CurStation)
    set DidAction 0

    PrintTrainLoc $Tx $CurStation $Px

    TrainManifestDrops $Tx $Px
    TrainManifestPickups $Tx $Px
    if {$DidAction} {update;TrainPrintConsistSummary $Tx}
  }
  set Deliver 0
  set CurInd $StopList($LastPx)
  set CurStation $IndsStation($CurInd)
  set CurDiv $StnsDiv($CurStation)
  set DidAction 0

  PrintTrainLoc $Tx $CurStation $LastPx

  TrainDropAllCars $Tx $Px $TrainLastLocation
  if {$TotalPickups > 0} {TrainPrintFinalSummary $Tx}  
}

# Procedure: TrainDropAllCars
proc TrainDropAllCars {Tx Px TrainLastLocation} {
  global Consist
  global TrainMaxCars
  global CrsLoc

  for {set Lx 1} {$Lx <= $TrainMaxCars} {incr Lx} {
    if {$Consist($Lx) != 0} {
      set Cx $Consist($Lx)
      if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
      set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
      if {$index >= 0} {
	set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
      }
      set CrsLoc($Cx) $TrainLastLocation
      lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
      TrainDropOneCar $Cx $Tx $TrainLastLocation
    }
  }
}

# Procedure: TrainManifestDrops
proc TrainManifestDrops {Tx Px} {
  global TrainMaxCars
  global Consist
  global IndsType
  global CrsDest
  global CurInd
  global CurDiv
  global CrsLoc
  global StnsDiv
  global IndsStation
  global DivsHome
  global LastPx
  global StopList
  
  for {set Lx 1} {$Lx <= $TrainMaxCars} {incr Lx} {
    if {$Consist($Lx) != 0} {
      set Cx $Consist($Lx)
#	 If this stop is an industry rather than a yard, check whether it's
#	 the car's final destination. If it is, then drop it -- Notice that
#	 a manifest does NOT CHECK for space available at the destination !
      if {"$IndsType($CurInd)" != {Y} && $CrsDest($Cx) == $CurInd} {
      if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
	set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
	if {$index >= 0} {
	  set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
	}
	set CrsLoc($Cx) $CurInd
	lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
	TrainDropOneCar $Cx $Tx $Lx
      }
#	If this stop is a yard, check whether it is the home yard for the
#	car's final destination. If it is, then drop it.
#
#	Note that a train that carries a car to its final destination AND
#	stops at the home yard of that destination, may deliver the car to
#	the yard rather than the industry.
#
#	To avoid the above scenario, look ahead to see if any of the stops
#	down the line really -IS- the final destination!
      set CurDivHome $DivsHome($CurDiv)
      set DestDiv $StnsDiv($IndsStation($CrsDest($Cx)))
      set NextCarInManifest 0
      if {"$IndsType($CurInd)" == {Y} && $CurDivHome == $DivsHome($DestDiv)} {
	for {set FuturePx $LastPx} {$FuturePx > $Px} {incr FuturePx -1} {
	  set FutureInd $StopList($FuturePx)
	  if {$FutureInd == $CrsDest($Cx)} {
	    set NextCarInManifest 1
	    break
	  }
	}
	if {$NextCarInManifest} {continue}
	if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
	set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
	if {$index >= 0} {
	  set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
	}
	set CrsLoc($Cx) $CurInd
	lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
	TrainDropOneCar $Cx $Tx $Lx
      }
    }
  }
}
# Procedure: TrainLocalDrops
proc TrainLocalDrops {Tx Px} {
  global TrainMaxCars
  global Consist
  global IndsType
  global CrsDest
  global CurInd
  global CrsLoc
  global StnsDiv
  global IndsStation
  global DivsHome
  global LastPx
  global StopList
  global CurStation
  global TotalIndustries

  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    if {$IndsStation($Ix) == $CurStation} {
      for {set Lx 1} {$Lx <= $TrainMaxCars} {incr Lx} {
	if {$Consist($Lx) != 0} {
	  set Cx $Consist($Lx)
#	  If this car has reached it's final destination, drop it!
	  if {$Ix == $CrsDest($Cx)} {
	    if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
	    set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
	    if {$index >= 0} {
	      set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
	    }
	    set CrsLoc($Cx) $CrsDest($Cx)
	    lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
	    TrainDropOneCar $Cx $Tx $Lx
	  }
	}
      }
    }
  }
# CHANGE 6/24/96 -- Drop at intermediate yard -- this works only as
# long as the final destination for this car is not at a later stop
# -----------------------------------------------------------------
  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    if {$IndsStation($Ix) == $CurStation} {
      if {"$IndsType($Ix)" == {Y}} {
	for {set Lx 1} {$Lx <= $TrainMaxCars} {incr Lx} {
	  if {$Consist($Lx) != 0} {
	    set Cx $Consist($Lx)
#	    If this car has reached it's destination's home yard, we
#	    drop it in the yard.
	    set CarsDestDiv $StnsDiv($IndsStation($CrsDest($Cx)))
	    if {$Ix == $DivsHome($CarsDestDiv)} {
	      if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
	      set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
	      if {$index >= 0} {
		set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
	      }
	      set CrsLoc($Cx) $CrsDest($Cx)
	      lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
	      TrainDropOneCar $Cx $Tx $Lx
	    }
	  }
	}
      }
    }
  }
# END CHANGE 6/24/96
# ------------------
}

# Procedure: TrainDropOneCar
proc TrainDropOneCar {Cx Tx Lx} {
  global TrainPrintOK
  global DidAction
  global Deliver
  global TrainCars
  global TrainLen
  global TrainEmpties
  global TrainTons
  global TrainLoads
  global CrsRR
  global CrsNum
  global CrsLen
  global CrsDest
  global CrsLen
  global CrsStatus
  global CrsLtWt
  global CrsLdLmt
  global CrsType
  global CrsLoc
  global CarTypes
  global StnsName
  global IndsStation
  global IndsName
  global IndsType
  global IndsCarsNum
  global IndsCarsLen
  global Consist
  global TrnType

  if {$TrainPrintOK} {
    if {!$DidAction} {
      TrainPrintTown $Tx
    }

    GetCarStatus $Cx Status CarTypeDesc

    putPrinterString " DROP   $CrsRR($Cx)"
    putPrinterTab 19
    putPrinterString "$CrsNum($Cx)"
    putPrinterTab 28
    putPrinterString "$CrsLen($Cx)ft"
    putPrinterTab 36
    putPrinterString "$Status"
    putPrinterTab 44
    putPrinterString "$CarTypeDesc"
    putPrinterTab 84 
    putPrinterString "for  $IndsName($CrsDest($Cx))"
    if {$Deliver} {
      putPrinterTab 110
      putPrinterString "in   $StnsName($IndsStation($CrsDest($Cx)))"
    }
    putPrinterLine {}
  }
  set Consist($Lx) 0
  incr TrainCars -1
  incr TrainLen [expr 0 - $CrsLen($Cx)]
  if {"$CrsStatus($Cx)" == {E}} {
    incr TrainEmpties -1
    incr TrainTons [expr 0 - $CrsLtWt($Cx)]
  } else {
    incr TrainLoads -1
    incr TrainTons [expr 0 - $CrsLdLmt($Cx)]
  }

  set DidAction 1

  if {"$IndsType($CrsLoc($Cx))" == {Y} && "$TrnType($Tx)" == {B}} {return}

  incr IndsCarsNum($CrsLoc($Cx))
  incr IndsCarsLen($CrsLoc($Cx)) $CrsLen($Cx)

  [SN LogWindow] insert end "Drop $CrsRR($Cx) $CrsNum($Cx) is $CarTypes($CrsType($Cx)) dest = $IndsName($CrsDest($Cx))\n"
  [SN LogWindow] see end
#  update

}
    
# Procedure: TrainPickupOneCar
proc TrainPickupOneCar {Cx Tx Lx} {
  global TrainPrintOK
  global DidAction
  global Deliver
  global BoxMove
  global Wayfreight
  global CarDest
  global ScreenOn
  global TrainCars
  global TrainLen
  global TrainEmpties
  global TrainTons
  global TrainLoads
  global TrainLongest
  global TotalTons
  global TotalTons
  global TotalLoads
  global TotalRevenueTons
  global TotalPickups
  global CrsRR
  global CrsNum
  global CrsLen
  global CrsDest
  global CrsLen
  global CrsStatus
  global CrsLtWt
  global CrsLdLmt
  global CrsType
  global CrsMoves
  global CrsTrips
  global CrsDone
  global CrsLoc
  global CrsTrain
  global CarTypes
  global StnsName
  global IndsStation
  global IndsName
  global IndsType
  global IndsCarsNum
  global IndsCarsLen
  global IndsUsedLen
  global Consist
  global TrnType
  global TrnDone
  global TrnName

  [SN LogWindow] insert end "Pickup $CrsRR($Cx) $CrsNum($Cx) is $CarTypes($CrsType($Cx)) dest = $IndsName($CrsDest($Cx))\n"
  [SN LogWindow] see end
#  update

  incr TrainCars
  incr TrainLen $CrsLen($Cx)
  if {"$CrsStatus($Cx)" == {E}} {
    incr TrainEmpties
    incr TrainTons $CrsLtWt($Cx)
    incr TotalTons $CrsLtWt($Cx)
  } else {
    incr TrainLoads
    incr TrainTons $CrsLdLmt($Cx)
    incr TotalTons $CrsLdLmt($Cx)
    incr TotalLoads
    incr TotalRevenueTons [expr $CrsLdLmt($Cx) - $CrsLtWt($Cx)]
  }
# This was the old way of counting only loaded trips -- whenever the car
# was picked up loaded at an industry.
#
#    IF IndsType(CrsLoc%(Cx%)) <> "Y" THEN
#
#       CrsLoads%(Cx%) = CrsLoads%(Cx%) + 1
#
#    END IF
  set Consist($Lx) $Cx
  if {!$BoxMove} {
    incr CrsMoves($Cx)
    incr CrsTrips($Cx)
    set CrsDone($Cx) $TrnDone($Tx)
  }
# The car length is subtracted from where it is and added to where it
# is going.
  incr IndsUsedLen($CrsLoc($Cx)) [expr 0 - $CrsLen($Cx)]
  incr IndsUsedLen($CarDest) $CrsLen($Cx)
  if {$TrainCars > $TrainLongest} {set TrainLongest $TrainCars}
  if {$TrainPrintOK} {
    if {!$DidAction} {
      TrainPrintTown $Tx
    }
    GetCarStatus $Cx Status CarTypeDesc
    putPrinterString " PICKUP $CrsRR($Cx)"
    putPrinterTab 19
    putPrinterString "$CrsNum($Cx)"
    putPrinterTab 28
    putPrinterString "$CrsLen($Cx)ft"
    putPrinterTab 36
    putPrinterString "$Status"
    putPrinterTab 44
    putPrinterString "$CarTypeDesc"
    putPrinterTab 74
    if {$CrsTrain($Cx) == 0} {
      set TrainName {-}
    } else {
      set TrainName "$TrnName($CrsTrain($Cx))"
    }
    putPrinterString "[string range $TrainName 0 6]"
    putPrinterTab 84
    if {$Wayfreight} {
      putPrinterString "at   $IndsName($CrsLoc($Cx))"
      putPrinterTab 110
      putPrinterLine "for  $StnsName($IndsStation($CrsDest($Cx)))"
    } else {
      putPrinterString "to   $IndsName($CrsLoc($Cx))"
      putPrinterTab 110
      putPrinterLine "dest $StnsName($IndsStation($CrsDest($Cx)))"
   }
  }
# Log this pickup for later reports
  LogCarPickup $Cx $Tx
  incr TotalPickups
  set DidAction 1
  if {[catch "set IndsCarsIndexes($CrsLoc($Cx))"]} {set IndsCarsIndexes($CrsLoc($Cx)) {}}
  set index [lsearch -exact $IndsCarsIndexes($CrsLoc($Cx)) $Cx]
  if {$index >= 0} {
    set IndsCarsIndexes($CrsLoc($Cx)) [lreplace $IndsCarsIndexes($CrsLoc($Cx)) $index $index]
  }
  set CrsLoc($Cx) -1
  lappend IndsCarsIndexes($CrsLoc($Cx)) $Cx
}    

# Procedure: LogCarPickup
proc LogCarPickup {Cx Tx} {
  global BoxMove
  global PickIndex
  global CarDest
  global CarDest
  global SwitchListLimitCars
  global SwitchListPickCar
  global SwitchListPickLoc
  global SwitchListPickTrain
  global SwitchListLastTrain
  global SwitchListDropStop
  global CrsLoc
  global CrsTrain
  global TrnType
  global IndsStation

  if {$BoxMove} {return}

  incr PickIndex
  set SwitchListPickCar($PickIndex) $Cx
  set SwitchListPickLoc($PickIndex) $CrsLoc($Cx)
  set SwitchListPickTrain($PickIndex) $Tx
  set SwitchListLastTrain($PickIndex) $CrsTrain($Cx)

  set CrsTrain($Tx) $Tx

  if {"$TrnType($Tx)" == {M}} {
    set SwitchListDropStop($PickIndex) $CarDest
  } else {
    set SwitchListDropStop($PickIndex) $IndsStation($CarDest)
  }  
}

# Procedure: TrainLocalOriginate
proc TrainLocalOriginate {Tx Px} {
# Basically, starting from the origin, to the next to last stop, pick
# up every car in the origin yard that is destined for an industry at
# that particular stop -- IF possible.
#
# A car may not necessarily be picked up - if the destination already
# has too many cars, or the train cannot handle this type of car, etc.
  global LastPx
  global TrainCars
  global TrainMaxCars
  global TotalIndustries
  global TotalCars
  global IndsStation
  global StopList
  global CrsDest
  global CrsLoc
  global OriginYard
  global CarDest
  global TrnDivList
  global CarDestDiv
  global StnsDiv
  global IndsStation
  global DivsHome
  global CarLocDiv
  global CarDestDiv
  global DivsSymbol
  global TrainLastLocation
  global StnsIndus
  global IndsCarsIndexes

#  puts stderr "*** TrainLocalOriginate $Tx $Px"

  for {set FuturePx [expr $Px + 1]} {$FuturePx < $LastPx} {incr FuturePx} {
#    puts stderr "*** -: FuturePx = $FuturePx, TrainCars = $TrainCars, TrainMaxCars = $TrainMaxCars"
    if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
    foreach Ix [array names IndsStation] {
      if {$IndsStation($Ix) != $StopList($FuturePx)} {continue}
      if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
#      puts stderr "*** -: Ix = $Ix, IndsStation($Ix) = $IndsStation($Ix), StopList($FuturePx) = $StopList($FuturePx)"
      foreach Cx [array names CrsLoc] {
	if {$Cx == 0} {continue}
	if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
#	puts stderr "*** -: CrsDest($Cx) = $CrsDest($Cx), CrsLoc($Cx) = $CrsLoc($Cx), OriginYard = $OriginYard"
	if {$CrsDest($Cx) == $Ix && $CrsLoc($Cx) == $OriginYard} {
#	  puts stderr "*** -: Cx = $Cx, Ix = $Ix"
	  set CarDest $Ix
	  TrainCarPickupCheck $Cx $Tx
	}
      }
    }
  }
# KLUDGE CITY --
#
#  Allow local trains to forward cars under the control of a forwarding
#  division list.
#  puts stderr "*** TrainLocalOriginate: TrnDivList($Tx) = \{$TrnDivList($Tx)\}"
  if {"$TrnDivList($Tx)" != {}} {
    foreach Cx [array names CrsLoc] {
     if {$Cx == 0 || $CrsLoc($Cx) != $OriginYard} {continue}
#    for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {}
      if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
#     If this car is at the train's origin yard
#     -----------------------------------------
#      puts stderr "*** TrainLocalOriginate: CrsLoc($Cx) = $CrsLoc($Cx), OriginYard = $OriginYard"
#     if {$CrsLoc($Cx) == $OriginYard} {}
      set CarDestDiv $StnsDiv($IndsStation($CrsDest($Cx)))
#      The car must not already be at the home yard for its final
#      destination, or at an industry that has the same home yard
#      ----------------------------------------------------------^
      set CarLocDiv $StnsDiv($IndsStation($CrsLoc($Cx)))
#      puts stderr "*** -: CarDestDiv = $CarDestDiv, CarLocDiv = $CarLocDiv"
      if {$DivsHome($CarLocDiv) == $DivsHome($CarDestDiv)} {continue}
#      The train division list can be exclusive
#      ----------------------------------------
      if {[string first {-} "$TrnDivList($Tx)"] == 0} {
#	puts stderr "*** -: DivsSymbol($CarDestDiv) = $DivsSymbol($CarDestDiv)"
	if {[string first "$DivsSymbol($CarDestDiv)" "$TrnDivList($Tx)"] < 0} {
	  set CarDest $TrainLastLocation
#	  puts stderr "*** -: Cx = $Cx, TrainLastLocation = $TrainLastLocation"
	  TrainCarPickupCheck $Cx $Tx
	} else {
#	  The train division list can include everything - *
#
#	    otherwise it specifies which divisions for forwarding
#	  -------------------------------------------------------
	  if {"$TrnDivList($Tx)" == {*} || \
	      [string first "$DivsSymbol($CarDestDiv)" "$TrnDivList($Tx)"]} {
	    set CarDest $TrainLastLocation
#	    puts stderr "*** -: Cx = $Cx, TrainLastLocation = $TrainLastLocation"
	    TrainCarPickupCheck $Cx $Tx
	  }
	}
      }
    }
  }
}

# Procedure: TrainLocalPickups
proc TrainLocalPickups {Tx Px} {
# Basically, look at each industry at the current station. For each
# car at the industry, see if there is a logical place to take that
# car -- i.e. a stop where we can drop the car.
  global TotalIndustries
  global TrainCars
  global TrainMaxCars
  global IndsStation
  global CurStation
  global OriginYard
  global TotalCars
  global CrsLoc
  global IndsType
  global LastPx
  global CrsDest
  global StopList
  global CarDest
  global TrainLastLocation
  global StnsIndus
  global IndsCarsIndexes

#  puts stderr "*** TrainLocalPickups: $Tx $Px"

  foreach Ix [array names IndsStation] {
    if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
#   The reason to check for OriginYard% is if this local serves a
#   station that has both industries AND a yard. When the train  
#   originated, it picked up cars from the yard. But subsequently
#   it wants to pick up cars from industries at that same station,
#   and needs to ignore cars still in the yard.
#   --------------------------------------------------------------
    if {$IndsStation($Ix) == $CurStation && $Ix != $OriginYard} {
#      puts stderr "*** -: Ix == $Ix"
      foreach Cx [array names CrsLoc] {
        if {$Cx == 0 || $CrsLoc($Cx) != $Ix} {continue}
#	puts stderr "*** -: CrsLoc($Cx) = $CrsLoc($Cx)"
	if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
#	The usual place to take a car is to the final stop. But it
#	is possible that this local train can deliver the car to a
#	final destination -- that's what this is checking for.
#	if {$Ix == $CrsLoc($Cx)} {}
#	CHANGE 6/24/96 -- Check for an intermediate yard. We can
#	pick up the car here - but ONLY if the final destination
#	station (and hence industry) is served by this train.
#	--------------------------------------------------------
#	puts stderr "*** -: IndsType($Ix) $IndsType($Ix)"
	if {"$IndsType($Ix)" == {Y}} {
	  for {set FuturePx [expr $Px + 1]} {$FuturePx <= $LastPx} {incr FuturePx} {
	    if {$IndsStation($CrsDest($Cx)) == $StopList($FuturePx)} {
	      set CarDest $CrsDest($Cx)
	      TrainCarPickupCheck $Cx $Tx 
	      if {$CrsLoc($Cx) == -1} {break}
	    }
	  }
	  continue
	}
#	END CHANGE 6/24/96
#	------------------
	set CarDest $TrainLastLocation
	for {set FuturePx [expr $Px + 1]} {$FuturePx <= $LastPx} {incr FuturePx} {
	  if {$IndsStation($CrsDest($Cx)) == $StopList($FuturePx)} {
	    set CarDest $CrsDest($Cx)
	    TrainCarPickupCheck $Cx $Tx
	    if {$CrsLoc($Cx) == -1} {break}
	    set CarDest $TrainLastLocation
	  }
	}
	if {$CrsLoc($Cx) == -1} {continue}
	TrainCarPickupCheck $Cx $Tx
      }
    }
  }
}

# Procedure: TrainManifestPickups
proc TrainManifestPickups {Tx Px} {
# Walk backwards from the furthest destination -- so we move the cars
# travelling farthest first ...
  global StnsIndus
  global IndsCarsIndexes
  global LastPx
  global TrainCars
  global TrainMaxCars
  global TrainMaxCars
  global CurInd
  global StnsDiv
  global IndsStation
  global CrsLoc
  global CrsDest
  global CarDest
  global StopList
  global TotalCars
  global DivsHome
  global TrnDivList
  global TrainLastLocation
  global IndsType
  global DivsSymbol

  for {set FuturePx $LastPx} {$FuturePx > $Px} {incr FuturePx -1} {
    if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
    set FutureInd $StopList($FuturePx)
#    for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {}
    foreach Cx [array names CrsLoc] {
      if {$Cx == 0 || $CrsLoc($Cx) != $CurInd} {continue}
#     If this car is at the train's current stop ...
#     if {$CrsLoc($Cx) == $CurInd} {}
      set CarLocDiv $StnsDiv($IndsStation($CrsLoc($Cx)))
      set CarDestDiv $StnsDiv($IndsStation($CrsDest($Cx)))
#     If the train's future stop is ...
#
#      (1) the car's final destination industry
      if {"$IndsType($FutureInd)" != {Y}} {
	set Exp1 [expr $CrsDest($Cx) == $FutureInd]
#	 AND if the car is not already there!
	set Exp2 [expr $CrsLoc($Cx) != $FutureInd]
      } else {
#	Future Stop is a YARD
#	If the train's future stop is ...
#	 (2) the car's final destination home yard
	set Exp1 [expr $DivsHome($CarDestDiv) == $FutureInd]
#	 AND if the car is not already there!
#	set Exp2 [expr $CrsLoc($Cx) != $FutureInd]
#	 This expression doesn't work if a car needs to move on a
#	 manifest from one industry to another, and the industries
#	 share a common home yard!
#	 ---------------------------------------------------------
	set Exp2 [expr $DivsHome($CarLocDiv) != $FutureInd]
#	 HOWEVER!! Now I may have confusion if a car's FINAL dest
#	 is an earlier stop. So check for this case. Aaargghh!
#	 --------------------------------------------------------
	for {set SoonerPx [expr $Px + 1]} {$SoonerPx < $FuturePx} {incr SoonerPx} {
	  set SoonerInd $StopList($SoonerPx)
	  if {$CrsDest($Cx) == $SoonerInd} {
	    set Exp2 0
#	    Short circuit loop (save time)
	    break
	  }
	}
      }
      if {$Exp1 && $Exp2} {
      set CarDest $FutureInd
#       IF FutureInd% = 138 OR FutureInd% = 139 THEN
#
#         IF CrsDest%(Cx%) = 138 OR CrsDest%(Cx%) = 139 THEN
#
#           CALL WipeScreen(20,78)
#	    PRINT "Train len = "; TrainLen%; " Car len = "; CrsLen%(Cx%);
#	    CALL WipeScreen(21,78)
#	    PRINT "Exp1% = "; Exp1%; " Exp2% = "; Exp2%;
#	    CALL WipeScreen(22,78)
#	    PRINT TrnName$(Tx%); " tried to pick up ";
#	    PRINT RTRIM$(CrsRR(Cx%)); " "; RTRIM$(CrsNum(Cx%));
#	    CALL WipeScreen(23,78)
#	    PRINT " from current location "; IndsName$(CrsLoc%(Cx%));
#	    PRINT " to "; IndsName$(FutureInd%);
#	    SLEEP 1
#
#	  END IF
#
#	END IF
	TrainCarPickupCheck $Cx $Tx
      } else {
#	IF FutureInd% = 138 OR FutureInd% = 139 THEN
#
#	  IF CrsDest%(Cx%) = 138 OR CrsDest%(Cx%) = 139 THEN
#
#	    CALL WipeScreen(20,78)
#	    PRINT "Industry Type = "; IndsType(FutureInd%);
#	    PRINT " CrsDest%(Cx%) = "; CrsDest%(Cx%);
#	    PRINT " FutureInd% = "; FutureInd%;
#	    CALL WipeScreen(21,78)
#	    PRINT "Exp1% = "; Exp1%; " Exp2% = "; Exp2%;
#	    CALL WipeScreen(22,78)
#	    PRINT TrnName$(Tx%); " does not pick up ";
#	    PRINT RTRIM$(CrsRR(Cx%)); " "; RTRIM$(CrsNum(Cx%));
#	    CALL WipeScreen(23,78)
#	    PRINT " from current location "; IndsName$(CrsLoc%(Cx%));
#	    PRINT " to "; IndsName$(FutureInd%);
#
#	  END IF
#
#	END IF
      }
    }
  }
# The rationale here is that forwarding cars are used to fill out the
# train's consist.
#
# I should make this a per-train option ( i.e. whether the forwarding
# cars have higher priority than other cars )
# -------------------------------------------------------------------
  if {"$TrnDivList($Tx)" != {}} {
#   CALL WipeScreen(20,78)
#   PRINT "Train forward list = "; TrnDivList$(Tx%)
#   SLEEP 1
#    for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {}
     foreach Cx [array names CrsLoc] {
      if {$Cx == 0 || $CrsLoc($Cx) != $CurInd} {continue}
      if {[expr $TrainCars + 1] > $TrainMaxCars} {return}
#     If this car is at the train's current stop
#     ------------------------------------------
#     if {$CrsLoc($Cx) == $CurInd} {}
#      CALL WipeScreen(22,78)
#      PRINT "Look at "; LTRIM$(CrsRR(Cx%))
#      PRINT LTRIM$(CrsNum(Cx%)); " destination = "
#      PRINT RTRIM$(StnsName(IndsStation%(CrsLoc%(Cx%))))
#      SLEEP 1
      set CarDestDiv $StnsDiv($IndsStation($CrsDest($Cx)))
#	The car must not already be at the home yard for its final
#	destination, or at an industry that has the same home yard
#	----------------------------------------------------------
      set CarLocDiv $StnsDiv($IndsStation($CrsLoc($Cx)))
      if {$DivsHome($CarDestDiv) == $DivsHome($CarLocDiv)} {continue}
#	The train division list can be exclusive
#	----------------------------------------
      if {"[string index $TrnDivList($Tx) 0]" == {-}} {
#	  CALL WipeScreen(22,78)
#	  PRINT " which is an EXCLUSIVE list"
#	  SLEEP 1
	if {[string first "$DivsSymbol($CarDestDiv)" "[string range $TrnDivList($Tx) 1 end]"] == -1} {
	  set CarDest $TrainLastLocation
#	    CALL WipeScreen(23,78)
#	    PRINT " and we will TRY to pick this one up"
#	    SLEEP 1
	    TrainCarPickupCheck $Cx $Tx
	    continue
	}
#	  CALL WipeScreen(23,78)
#	  PRINT " and the car's dest ("; DivsSymbol(CarDestDiv%)
#	  PRINT ") is excluded"
#	  SLEEP 1
      } else {
#	  CALL WipeScreen(22,78)
#	  PRINT " which is an INCLUSIVE list
#	  SLEEP 1
#	  The train division list can include all - *
#
#	    otherwise it specifies which divisions for forwarding
#	  -------------------------------------------------------
	if {"TrnDivList($Tx)" == {*} || \
	      [string first "$DivsSymbol($CarDestDiv)" "TrnDivList($Tx)"] >= 0} {
	  set CarDest $TrainLastLocation
#	    CALL WipeScreen(23,78)
#	    PRINT " and we will TRY to pick this one up"
#	    SLEEP 1
	    TrainCarPickupCheck $Cx $Tx
	    continue
	}
#	  CALL WipeScreen(23,78)
#	  PRINT " and the car's dest ("; DivsSymbol(CarDestDiv%)
#	  PRINT ") is excluded"
#	  SLEEP 1
      }
    }
  }
}

# Procedure: TrainCarPickupCheck
proc TrainCarPickupCheck {Cx Tx} {
  global BoxMove
  global Wayfreight
  global TotalCars
  global CarDest
  global CarTypesList
  global TrainLen
  global TrainMaxLen
  global TrainMaxCars
  global TrainPlate
  global TrainClass
  global CrsDone
  global CrsLoc
  global CrsDest
  global CrsLen
  global CrsPlate
  global CrsClass
  global CrsType
  global CrsPeek
  global IndsCarLen
  global IndsPlate
  global IndsClass
  global IndsRemLen
  global IndsUsedLen
  global IndsTrackLen
  global IndsType
  global Consist


#  puts stderr "*** TrainCarPickupCheck $Cx $Tx"

#  Check for obvious things that prevent the car from being picked up!

#    Has the car already finished moving ?

#  puts stderr "*** -: BoxMove = $BoxMove, CrsDone($Cx) = $CrsDone($Cx)"

  if {!$BoxMove} {
    if {"$CrsDone($Cx)" == {Y}} {return}
  }

#    Is car already at its destination ?

#  puts stderr "*** -: CrsLoc($Cx) = $CrsLoc($Cx), CrsDest($Cx) = $CrsDest($Cx)"

  if {$CrsLoc($Cx) == $CrsDest($Cx)} {return}

#    Is the car too long for this train ?

#  puts "*** -: TrainLen = $TrainLen, CrsLen($Cx) = $CrsLen($Cx), TrainMaxLen = $TrainMaxLen"

  if {[expr $TrainLen + $CrsLen($Cx)] > $TrainMaxLen} {return}

#    Is the car too large, or too heavy for the train ?

#  puts stderr "*** -: CrsPlate($Cx) = $CrsPlate($Cx), TrainPlate = $TrainPlate"
#  puts stderr "*** -: CrsClass($Cx) = $CrsClass($Cx), TrainClass = $TrainClass"
  

  if {$CrsPlate($Cx) > $TrainPlate} {return}
  if {$CrsClass($Cx) > $TrainClass} {return}

#    Is the car too large, or too heavy for the destination ?

  if {$CrsLen($Cx) > $IndsCarLen($CarDest)} {return}
  if {$CrsPlate($Cx) > $IndsPlate($CarDest)} {return}
  if {$CrsClass($Cx) > $IndsClass($CarDest)} {return}

#    Can the train move this type of car ?

  if {"$CarTypesList" != {}} {
    if {"[string index $CarTypesList 0]" == {-}} {
      if {[string first "$CrsType($Cx)" "[string range $CarTypesList 1 end]"] >= 0} {return}
    } elseif {[string first "$CrsType($Cx)" "$CarTypesList"] < 0} {return}
  }

#   That's it for MANIFEST trains -- this car is Ok!
#   -----------------------------------------------

  if {!$Wayfreight} {
    for {set Lx 1} {$Lx <= $TrainMaxCars} {incr Lx} {
      if {$Consist($Lx) == 0} {
	incr IndsRemLen($CarDest) [expr 0 - $CrsLen($Cx)]
	TrainPickupOneCar $Cx $Tx $Lx
	return
      }
    }
    return
  }

#   A WAYFREIGHT needs to have some space available - unless it's a yard
#   -----------------------------------------------

  set Exp1 [expr ($IndsUsedLen($CarDest) + $CrsLen($Cx)) <= $IndsTrackLen($CarDest)]
  if {$Exp1 || "$IndsType($CarDest)" == {Y}} {
    for {set Lx 1} {$Lx <= $TrainMaxCars} {incr Lx} {
      if {$Consist($Lx) == 0} {
	incr IndsRemLen($CarDest) [expr 0 - $CrsLen($Cx)]
	TrainPickupOneCar $Cx $Tx $Lx
	return
      }
    }
  }

#============================================================================
# Oops! Now for some fancy footwork -- we look ahead to see whether
# this train will REMOVE another car from the destination, to create
# an opening for this car.
#============================================================================
  foreach OtherCx [array names CrsPeek] {
    if {$OtherCx != 0 && $CrsPeek($OtherCx) == 0 && $CrsLoc($OtherCx) == $CarDest} {
#      Exp1 means the other car has a new destination, and is able to move
      set Exp1a [expr $CrsDest($OtherCx) != $CarDest]
      set Exp1b [expr [string compare "$CrsDone($OtherCx)" {N}] == 0]
      set Exp1  [expr $Exp1a && $Exp1b]
#      set Exp1 [expr ($CrsDest($OtherCx) != $CarDest) && ("$CrsDone($OtherCx)" == {N})]
#      Exp2 means the removal of the other car will make room for this one
      set Exp2 [expr ($CrsLen($OtherCx) + $IndsRemLen($CarDest)) >= $CrsLen($Cx)]
#      Exp3 was used to test to see if removal of this car from its YARD
#      would make room for the other car to replace it -- but this makes
#      no sense in some cases so I deleted this test.
#     set Exp3 [expr $IndsTrackLen($CrsLoc($Cx)) >= ( $IndsUsedLen($CrsLoc($Cx)) - $CrsLen($Cx) + $CrsLen($OtherCx) )]
      if {$Exp1 && $Exp2} {
	if {[OtherCarOkForTrain $OtherCx]} {
	  set CrsPeek($OtherCx) 1
	  incr IndsRemLen($CarDest) [expr $CrsLen($OtherCx) - $CrsLen($Cx)]
	  for {set Lx 1} {$Lx <= $TrainMaxCars} {incr Lx} {
	    if {$Consist($Lx) == 0} {
	      TrainPickupOneCar $Cx $Tx $Lx
	      return
	    }
	  }
	}
      }
    }
  }
  return
}

# Procedure: OtherCarOkForTrain
proc OtherCarOkForTrain {OtherCx} {
  global CrsPlate
  global CrsClass
  global CrsType
  global TrainPlate
  global TrainClass
  global CarTypesList

  if {$CrsPlate($OtherCx) > $TrainPlate} {return 0}
  if {$CrsClass($OtherCx) > $TrainClass} {return 0}

  if {"$CarTypesList" != {}} {
    if {"[string index $CarTypesList 0]" == {-}} {
      if {[string first "$CrsType($OtherCx)" "[string range $CarTypesList 1 end]"] >= 0} {return 0}
    } elseif {[string first "$CrsType($OtherCx)" "$CarTypesList"] < 0} {return 0}
  }
  return 1
}

# Procedure: TrainPrintTown
proc TrainPrintTown {Tx} {
  global TrainPrintOK
  global TotalPickups
  global StnsName
  global CurStation

  if {!$TrainPrintOK} {return}
  if {$TotalPickups == 0} {PrintTrainOrderHeader $Tx}

  putPrinterLine {}
  putPrinterString "$StnsName($CurStation)"
  set NameLen [string length "$StnsName($CurStation)"]
  putPrinterString { }
  putPrinterLine "[StringDup [expr 36 - $NameLen] {_}]"
  putPrinterLine {}
}

# Procedure: StringDup
proc StringDup {len str} {
  set result {}
  for {set i 0} {$i < $len} {incr i} {
    set result "$result$str"
  }
  return "$result"
}

# Procedure: PrintTrainOrderHeader
proc PrintTrainOrderHeader {Tx} {
  global TrnName
  global TrnOnDuty
  global TrnDesc

  PrintSystemBanner

  putPrinterLine "TRAIN #$Tx -- $TrnName($Tx) pick up on Yard Track ______ Departure $TrnOnDuty($Tx)"
  putPrinterLine {}
  putPrinterTab 12
  putPrinterLine "$TrnDesc($Tx)"

  PrintTrainOrders $Tx

  putPrinterNarrow
}

# Procedure: TrainPrintConsistSummary
proc TrainPrintConsistSummary {Tx} {
  global TrainPrintOK
  global TrainCars
  global TrainEmpties
  global TrainLoads
  global TrainTons
  global TrainLen

  if {!$TrainPrintOK} {return}

  putPrinterLine {}
  putPrinterTab 7
  putPrinterLine " Current cars = $TrainCars Empties = $TrainEmpties Loads = $TrainLoads Tons = $TrainTons Length = $TrainLen ft"

}

# Procedure: TrainPrintFinalSummary
proc TrainPrintFinalSummary {Tx} {
  global TrainPrintOK
  global TotalPickups
  global TotalLoads
  global TotalTons
  global TotalRevenueTons

  if {!$TrainPrintOK} {return}

  putPrinterLine {}
  putPrinterTab 4
  putPrinterLine {Train Termination Report}
  putPrinterLine {}
  putPrinterTab 11
  putPrinterLine " Total cars handled  = $TotalPickups"
  putPrinterTab 11
  putPrinterLine " Total loads handled = $TotalLoads"
  putPrinterTab 11
  putPrinterLine " Total gross tons    = $TotalTons"
  putPrinterTab 11
  putPrinterLine " Total revenue tons  = $TotalRevenueTons"

  PrintFormFeed
}

# Procedure: PrintFormFeed
proc PrintFormFeed {} {
  putPrinterNormal
  putPrinterNewPage
}

# Procedure: GetCarStatus
proc GetCarStatus {Cx StatusVar CarTypeDescVar} {
  global CrsType
  global CarTypes
  global CrsStatus
  global EmptyTypes
  upvar $StatusVar Status
  upvar $CarTypeDescVar xCarTypeDesc

  set xCarTypeDesc "$CarTypes($CrsType($Cx))"
  if {"$CrsStatus($Cx)" == {E}} {
    set Status {EMPTY}
#   set xCarTypeDesc "$EmptyTypes($CrsType($Cx))"
  }
  if {"$CrsStatus($Cx)" == {L}} {
    set Status {LOADED}
#   set xCarTypeDesc "$CarTypes($CrsType($Cx))"
  }
}


# Procedure: ClosePrinter
proc ClosePrinter {} {
  global Printer
  if {"$Printer" == {}} {return}
  putPrinterTrailer
  close $Printer
  set Printer {}
}


# Procedure: OpenPrinter
proc OpenPrinter {} {

  global Printer
  if {"$Printer" != {}} {
    if {[YesNoBox {Printer is already open, close it and re-open it?}]} {
      ClosePrinter
    } else {return}
  }


# .selectPrinter
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 7.4 (Tcl/Tk/XF)
# Tk version: 4.0
# XF version: 2.4
#

  # build widget .selectPrinter
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .selectPrinter"
  } {
    catch "destroy .selectPrinter"
  }
  toplevel .selectPrinter 

  # Window manager configurations
  wm positionfrom .selectPrinter ""
  wm sizefrom .selectPrinter ""
  wm maxsize .selectPrinter 1000 900
  wm minsize .selectPrinter 10 10
  wm title .selectPrinter {Select Printer}


  # build widget .selectPrinter.frame
  frame .selectPrinter.frame

  # build widget .selectPrinter.frame.scrollbar2
  scrollbar .selectPrinter.frame.scrollbar2  -command {.selectPrinter.frame.listbox1 yview}  -relief {raised} -takefocus 0

  # build widget .selectPrinter.frame.scrollbar3
  scrollbar .selectPrinter.frame.scrollbar3  -command {.selectPrinter.frame.listbox1 xview}  -orient {horizontal}  -relief {raised} -takefocus 0

  # build widget .selectPrinter.frame.listbox1
  listbox .selectPrinter.frame.listbox1  -relief {raised}  -selectmode {single}  -xscrollcommand {.selectPrinter.frame.scrollbar3 set}  -yscrollcommand {.selectPrinter.frame.scrollbar2 set}
  bind .selectPrinter.frame.listbox1 <1> {
    global PrinterType
    set value [%W get [%W index @%x,%y]]
    if {"$value" != {}} {
      set PrinterType "[lindex [split $value { }] 0]"
    }
  }      

  # build widget .selectPrinter.askNewPrinter
  frame .selectPrinter.askNewPrinter  -borderwidth {2}

  # build widget .selectPrinter.askNewPrinter.button4
  button .selectPrinter.askNewPrinter.button4  -padx {9}  -pady {3}  -command {
	global fsBox
	set fsBox(pattern) "Printer*.tcl"
	set newPrinterFile [FSBox {Select a printer defination file}]
	if {"$newPrinterFile" != {}} {
	  .selectPrinter.askNewPrinter.printerFile delete 0 end
	  .selectPrinter.askNewPrinter.printerFile insert end "$newPrinterFile"
	}
	grab .selectPrinter
    } -text {Browse} -takefocus 0

  # build widget .selectPrinter.askNewPrinter.label2
  button .selectPrinter.askNewPrinter.label2  -text {Load Printer File:} \
    -command {
    if {[catch "source [.selectPrinter.askNewPrinter.printerFile get]" error]} {
      ErrorPopup "Error in [.selectPrinter.askNewPrinter.printerFile get]:\n$error"
    } else {
      global PrinterTypes
      .selectPrinter.frame.listbox1 delete 0 end
      foreach p [lsort [array names PrinterTypes]] {
	.selectPrinter.frame.listbox1 insert end "$p $PrinterTypes($p)"
      }
      global PrinterType
      set PrinterType {}
    }
  }

  # build widget .selectPrinter.askNewPrinter.printerFile
  entry .selectPrinter.askNewPrinter.printerFile
  bind .selectPrinter.askNewPrinter.printerFile <Return> {
    if {[catch "source [%W get]" error]} {
      ErrorPopup "Error in [%W get]:\n$error"
    } else {
      global PrinterTypes
      .selectPrinter.frame.listbox1 delete 0 end
      foreach p [lsort [array names PrinterTypes]] {
	.selectPrinter.frame.listbox1 insert end "$p $PrinterTypes($p)"
      }
      global PrinterType
      set PrinterType {}
    }
  }

  # build widget .selectPrinter.filenameFrame
  frame .selectPrinter.filenameFrame  -borderwidth {2}

  # build widget .selectPrinter.filenameFrame.button8
  button .selectPrinter.filenameFrame.button8  -padx {9}  -pady {3}  -command {
	global fsBox
	set fsBox(pattern) "*"
	set OutputFile [FSBox {Select an outputfile}]
	if {"$OutputFile" != {}} {
	  .selectPrinter.filenameFrame.filename delete 0 end
	  .selectPrinter.filenameFrame.filename insert end "$OutputFile"
	}
	grab .selectPrinter
    } -text {Browse} -takefocus 0

  # build widget .selectPrinter.filenameFrame.filename
  entry .selectPrinter.filenameFrame.filename
  bind .selectPrinter.filenameFrame.filename <Return> {.selectPrinter.frame9.button10 invoke}

  # build widget .selectPrinter.filenameFrame.label6
  label .selectPrinter.filenameFrame.label6  -text {Output File or Pipe:}

  # build widget .selectPrinter.frame9
  frame .selectPrinter.frame9  -borderwidth {2}

  # build widget .selectPrinter.frame9.button10
  button .selectPrinter.frame9.button10  -padx {9}  -pady {3}  -command {
	global PrinterType
	set printerFile "[.selectPrinter.filenameFrame.filename get]"
	if {"$printerFile" != {} && "$PrinterType" != {}} {OpenPrinter1 $printerFile}
	if {"[info procs XFEdit]" != ""} {
	  catch "XFDestroy .selectPrinter"
	} {
	  catch "destroy .selectPrinter"
	}
    }  -text {Open Printer} -takefocus 0

  # build widget .selectPrinter.frame9.button11
  button .selectPrinter.frame9.button11  -padx {9}  -pady {3}  -command {
	if {"[info procs XFEdit]" != ""} {
	  catch "XFDestroy .selectPrinter"
	} {
	  catch "destroy .selectPrinter"
	}
    }  -text {Cancel} -takefocus 0

  # build widget .selectPrinter.frame9.button12
  button .selectPrinter.frame9.button12  -padx {9}  -pady {3}  -text {Help} -takefocus 0

  # pack master .selectPrinter.askNewPrinter
  pack configure .selectPrinter.askNewPrinter.label2  -side left
  pack configure .selectPrinter.askNewPrinter.printerFile  -expand 1  -fill x  -side left
  pack configure .selectPrinter.askNewPrinter.button4  -side right

  # pack master .selectPrinter.filenameFrame
  pack configure .selectPrinter.filenameFrame.label6  -side left
  pack configure .selectPrinter.filenameFrame.filename  -expand 1  -fill x  -side left
  pack configure .selectPrinter.filenameFrame.button8  -side right

  # pack master .selectPrinter.frame
  pack configure .selectPrinter.frame.scrollbar2  -fill y  -side right
  pack configure .selectPrinter.frame.listbox1  -expand 1  -fill both
  pack configure .selectPrinter.frame.scrollbar3  -fill x  -side bottom

  # pack master .selectPrinter.frame9
  pack configure .selectPrinter.frame9.button10  -expand 1  -side left
  pack configure .selectPrinter.frame9.button11  -expand 1  -side left
  pack configure .selectPrinter.frame9.button12  -expand 1  -side right

  # pack master .selectPrinter
  pack configure .selectPrinter.frame  -fill both
  pack configure .selectPrinter.askNewPrinter  -fill both
  pack configure .selectPrinter.filenameFrame  -fill both
  pack configure .selectPrinter.frame9  -fill both

  .selectPrinter.askNewPrinter.printerFile insert end {}
  .selectPrinter.filenameFrame.filename insert end {Output.txt}


# end of widget tree

  global PrinterTypes
  foreach p [lsort [array names PrinterTypes]] {
    .selectPrinter.frame.listbox1 insert end "$p $PrinterTypes($p)"
  }
  global PrinterType
  set PrinterType {}

  update idletasks
  grab .selectPrinter
  tkwait window .selectPrinter
}


# Procedure: OpenPrinter1
proc OpenPrinter1 { filename} {
  global PrinterType
  global Printer

  if {[catch [list open "$filename" w] fp]} {
    ErrorPopup "Could not open output file $filename:\n$fp"
    return
  } else {
    set Printer $fp
    putPrinterInit
  }
}

# Procedure: putPrinterDouble
proc putPrinterDouble {} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterDouble$PrinterType
}


# Procedure: putPrinterDoubleNONE
proc putPrinterDoubleNONE {} {

}


# Procedure: putPrinterInit
proc putPrinterInit {} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterInit$PrinterType
}


# Procedure: putPrinterInitNONE
proc putPrinterInitNONE {} {

}


# Procedure: putPrinterLine
proc putPrinterLine { string} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterLine$PrinterType "$string"
}


# Procedure: putPrinterLineNONE
proc putPrinterLineNONE { string} {

}


# Procedure: putPrinterNarrow
proc putPrinterNarrow {} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterNarrow$PrinterType
}


# Procedure: putPrinterNarrowNONE
proc putPrinterNarrowNONE {} {

}


# Procedure: putPrinterNewPage
proc putPrinterNewPage {} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterNewPage$PrinterType
}


# Procedure: putPrinterNewPageNONE
proc putPrinterNewPageNONE {} {

}


# Procedure: putPrinterNormal
proc putPrinterNormal {} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterNormal$PrinterType
}


# Procedure: putPrinterNormalNONE
proc putPrinterNormalNONE {} {

}


# Procedure: putPrinterString
proc putPrinterString { string} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterString$PrinterType "$string"
}


# Procedure: putPrinterStringNONE
proc putPrinterStringNONE { string} {

}


# Procedure: putPrinterTab
proc putPrinterTab { column} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterTab$PrinterType $column
}


# Procedure: putPrinterTabNONE
proc putPrinterTabNONE { column} {

}


# Procedure: putPrinterTrailer
proc putPrinterTrailer {} {
  global Printer
  global PrinterType
  if {"$Printer" == {}} {OpenPrinter}
  if {"$Printer" == {}} {return}

  putPrinterTrailer$PrinterType
}


# Procedure: putPrinterTrailerNONE
proc putPrinterTrailerNONE {} {

}

# Procedure: ReportsMenu
proc ReportsMenu {} {
  tkMbPost .mainMenu.right.menubutton13
}

# Procedure: PrintSystemBanner
proc PrintSystemBanner {} {
  global RailSystem
  global SessionNumber
  global ShiftNumber

  putPrinterNormal
  putPrinterDouble
  putPrinterString "[string toupper $RailSystem]"
  set StrLen [string length $RailSystem]
  for {set Pad $StrLen} {$Pad <= 18} {incr Pad} {putPrinterString { }}
  putPrinterLine " Ses $SessionNumber: $ShiftNumber  [Today]"
  putPrinterNormal
  putPrinterLine {}
}

# Procedure: PrintDashedLine
proc PrintDashedLine {} {
  putPrinterLine [StringDup 136 {-}]
}

# Procedure: MenuReportIndustries
proc MenuReportIndustries {} {
  global TotalDivisions
  global DivsName
  global TotalStations
  global StnsDiv
  global TotalIndustries
  global IndsStation
  global DivsSymbol
  global StnsIndus
  global DivsStns

  PrintSystemBanner
  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 10
  putPrinterLine {INDUSTRY Report}
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}

  PrintIndustryHeader

  PrintDashedLine

  WIP_Start {Industry Report In Progress...}
  set Tenth [expr 10.0 / double($TotalDivisions)]
  WIP 0 {0% Done}
  for {set Dx 1} {$Dx <= $TotalDivisions} {incr Dx} {
    set DonePer [expr $Dx * $Tenth * 10]
    WIP $DonePer "[format {%f%% Done} $DonePer]"
    if {[catch "set DivsName($Dx)" dn]} {continue}
    if {"$dn" == {}} {continue}
    [SN LogWindow] insert end "Division: $DivsName($Dx)\n"
    [SN LogWindow] see end
    set CarsToDiv 0
    set CarsInDiv 0
    set LenInDiv 0
    foreach Sx [lsort -integer $DivsStns($Dx)] {
      foreach Ix [lsort -integer $StnsIndus($Sx)] {
	PrintOneIndustry $Ix LenInDiv CarsInDiv CarsToDiv
      }
    }
    putPrinterLine {}
    putPrinterString "Totals for <$DivsSymbol($Dx)> $DivsName($Dx)"
    putPrinterTab 44
    putPrinterString {=============================>}
    putPrinterTab 76
    putPrinterString "$LenInDiv"
    putPrinterTab 96
    putPrinterString "$CarsInDiv"
    putPrinterTab 106
    putPrinterLine "$CarsToDiv"
    putPrinterLine {}
  }
  WIP_Done
}

# Procedure: PrintIndustryHeader
proc PrintIndustryHeader {} {
  putPrinterString {#}
  putPrinterTab 5
  putPrinterString {City}
  putPrinterTab 37
  putPrinterString {Industry}
  putPrinterTab 66
  putPrinterString {Trk Len}
  putPrinterTab 76
  putPrinterString {Cur Len}
  putPrinterTab 86
  putPrinterString {Asn Len}
  putPrinterTab 96
  putPrinterString {Cars Now}
  putPrinterTab 106
  putPrinterString {Cars Dst}
  putPrinterTab 116
  putPrinterString {Lds Avail}
  putPrinterTab 128
  putPrinterLine {Emp Avail}
}

# Procedure: PrintOneIndustry
proc PrintOneIndustry {Ix LIDiv CIDiv CTDiv} {
  upvar $LIDiv LenInDiv
  upvar $CIDiv CarsInDiv
  upvar $CTDiv CarsToDiv

  global TotalCars
  global CrsDest
  global CrsLoc
  global CrsLen
  global CrsType
  global IndsEmptyTypes
  global IndsLoadTypes
  global IndsStation
  global IndsName
  global IndsTrackLen
  global IndsAssignLen
  global StnsName

  [SN LogWindow] insert end "  Industry: $IndsName($Ix)\n"
  [SN LogWindow] see end
  update

  set CarsTo 0
  set CarsIn 0
  set IndLen 0

  set LdsAvail 0
  set EmtAvail 0

  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    if {$Ix == $CrsDest($Cx)} {incr CarsTo}
    if {$Ix == $CrsLoc($Cx)} {
      incr CarsIn
      incr IndLen $CrsLen($Cx)
    }

    if {[string first "$CrsType($Cx)" "$IndsLoadTypes($Ix)"] >= 0} {incr LdsAvail}
    if {[string first "$CrsType($Cx)" "$IndsEmptyTypes($Ix)"] >= 0} {incr EmtAvail}
  }

  putPrinterString "$Ix"
  putPrinterTab 5
  putPrinterString "$IndsStation($Ix)"
  putPrinterTab 9
  putPrinterString "$StnsName($IndsStation($Ix))"
  putPrinterTab 37
  putPrinterString "$IndsName($Ix)"
  putPrinterTab 66
  putPrinterString "$IndsTrackLen($Ix)"
  putPrinterTab 76
  putPrinterString "$IndsAssignLen($Ix)"
  putPrinterTab 86
  putPrinterString "$IndLen"
  putPrinterTab 96
  putPrinterString "$CarsIn"
  putPrinterTab 106
  putPrinterString "$CarsTo"
  putPrinterTab 116
  putPrinterString "$LdsAvail"
  putPrinterTab 128
  putPrinterLine "$EmtAvail"

  incr CarsToDiv $CarsTo
  incr CarsInDiv $CarsIn
  incr LenInDiv $IndLen
}

# Procedure: MenuReportTrains
proc MenuReportTrains {} {
  global TotalTrains
  global TrnName

  PrintSystemBanner

  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 10 
  putPrinterLine {TRAINS Report}
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}

  PrintDashedLine

  WIP_Start {TRAINS Report In Progress...}
  set Tenth [expr 10.0 / double($TotalTrains)]
  WIP 0 {0% Done}

  for {set Tx 1} {$Tx <= $TotalTrains} {incr Tx} {
    if {[catch "set TrnName($Tx)"]} {continue}
    [SN LogWindow] insert end "$TrnName($Tx)\n"
    [SN LogWindow] see end
    set DonePer [expr $Tx * $Tenth * 10]
    WIP $DonePer "[format {%f%% Done} $DonePer]"
    putPrinterLine {}
    putPrinterNormal
    putPrinterDouble
    putPrinterLine "$TrnName($Tx)"

    PrintTrainOrders $Tx
  }
  WIP_Done

  PrintFormFeed  
}

# Procedure: PrintTrainOrders
proc PrintTrainOrders {Tx} {
  global TrnOrdLen
  global TrnOrder

  putPrinterNormal
  putPrinterLine {}
  for {set Ox 1} {$Ox <= $TrnOrdLen($Tx)} {incr Ox} {
    putPrinterLine "$TrnOrder($Tx,$Ox)"
  }
}

# Procedure: MenuReportCars
proc MenuReportCars {} {
  global TotalCars
  global CrsLoc
  global IndsCarsIndexes

  PrintSystemBanner

  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 10
  putPrinterLine {CARS Report}
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}

  set Totlines 4

  PrintCarHeading

  WIP_Start {CARS Report In Progress (Cars IN service) ...}
  WIP 0 {0% Done}
  set Tenth [expr 100.0 / double($TotalCars)]
  set Done 10
  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    set DonePer [expr $Cx * $Tenth]
    if {$DonePer > $Done} {
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      incr Done 10
    }
    if {$CrsLoc($Cx) > 0} {
      incr Totlines
      if {$Totlines > 58} {
	set Totlines 0
	PrintFormFeed
	PrintCarHeading
      }
      PrintOneCarInfo $Cx
    }
  }

  set Totlines 58

  if {[catch "set IndsCarsIndexes(0)" CarsOnBench]} {
    PrintFormFeed
    WIP_Done
    return
  }
  set ncOnB [llength $CarsOnBench]
  if {$ncOnB == 0} {
    PrintFormFeed
    WIP_Done
    return
  }
  set cc 0
  WIP_Start {CARS Report In Progress (Cars On Workbench)}
  WIP 0 {0% Done}
  set Tenth [expr 100.0 / double($ncOnB)]
  set Done 10
  foreach Cx [lsort -integer $CarsOnBench] {
    incr cc
    set DonePer [expr $cc * $Tenth]
    if {$DonePer > $Done} {
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      incr Done 10
    }
    if {$Cx < 1 || $Cx > $TotalCars} {continue}
    incr Totlines
    if {$Totlines > 58} {
      set Totlines 0
      PrintFormFeed
      PrintCarHeading
    }
    PrintOneCarInfo $Cx
  }
  WIP_Done
  PrintFormFeed
}

# Procedure: PrintOneCarInfo
proc PrintOneCarInfo {Cx} {
  global CrsRR
  global CrsNum
  global CrsLen
  global CrsType
  global CrsStatus
  global CrsLoc
  global CrsDest
  global CarTypes
  global IndsStation
  global StnsName
  global IndsName

  putPrinterString "$CrsRR($Cx)"
  putPrinterTab 11
  putPrinterString "$CrsNum($Cx)"
  putPrinterTab 20
  putPrinterString "$CrsLen($Cx)"
  putPrinterTab 25
  putPrinterString "$CarTypes($CrsType($Cx))"
  putPrinterTab 56
  putPrinterString "$CrsStatus($Cx)"
  putPrinterTab 60
  putPrinterString "$StnsName($IndsStation($CrsLoc($Cx)))"
  putPrinterTab 84
  putPrinterString "$IndsName($CrsLoc($Cx))"
  putPrinterTab 110
  putPrinterLine "$IndsName($CrsDest($Cx))"
}

# Procedure: PrintCarHeading
proc PrintCarHeading {} {
  putPrinterNarrow
  putPrinterLine {}
  putPrinterString {RR}
  putPrinterTab 11
  putPrinterString {NUMBER}
  putPrinterTab 20
  putPrinterString {LEN}
  putPrinterTab 25
  putPrinterString {CAR TYPE}
  putPrinterTab 56
  putPrinterString {L/E}
  putPrinterTab 60
  putPrinterString {CUR STATION}
  putPrinterTab 84
  putPrinterString {LOCATION}
  putPrinterTab 110
  putPrinterLine {DEST INDUSTRY}
  PrintDashedLine
}


# Procedure: MenuReportCarsNotMoved
proc MenuReportCarsNotMoved {} {
  global TotalCars
  global CrsMoves
  global IndsCarsIndexes
  global TotalIndustries

  PrintSystemBanner

  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 10
  putPrinterLine {CARS NOT MOVED Report}
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}

  set Totlines 4

  PrintCarHeading

  WIP_Start {CARS NOT MOVED Report In Progress}
  WIP 0 {0% Done}
  set Tenth [expr 100.0 / double($TotalIndustries)]
  set Done 10
  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    set DonePer [expr $Ix * $Tenth]
    if {$DonePer > $Done} {
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      incr Done 10
    }
    if {[catch "set IndsCarsIndexes($Ix)"]} {continue}
    foreach Cx [lsort -integer $IndsCarsIndexes($Ix)] {
      if {$CrsMoves($Cx) == 0} {
	incr Totlines
	if {$Totlines > 58} {
	  set Totlines 0
	  PrintFormFeed
	  PrintCarHeading
	}
	PrintOneCarInfo $Cx
      }
    }
  }
  WIP_Done
  PrintFormFeed
}

# Procedure: MenuReportCarTypes
proc MenuReportCarTypes {ReportType} {
  global TotalsOnly
  switch -exact "$ReportType" {
    All {
	  set TotalsOnly 0
	  PrintCarTypesHeader
	  PrintDashedLine
	  PrintAllCarTypes
	}
    Type {
	    set TotalsOnly 0
	    global CarTypes
	    # build widget .selectCarType
	    if {"[info procs XFEdit]" != ""} {
	      catch "XFDestroy .selectCarType"
	    } {
	      catch "destroy .selectCarType"
	    }
	    toplevel .selectCarType
	    # Window manager configurations
	    global tk_version
	    wm maxsize .selectCarType 1009 738
	    wm minsize .selectCarType 1 1
	    wm title .selectCarType {Select Car Type}

	    set ict 0
	    foreach ct [lsort [array names CarTypes]] {
	      if {"$ct" == {,}} {continue}
	      if {"$ct" == {NULL}} {continue}
	      set frame [expr int($ict / 10)]
	      set rb    [expr $ict % 10]
	      set fp .selectCarType.f$frame
	      if {![winfo exists $fp]} {
		frame $fp
		pack configure $fp -side top -fill x
	      }
	      set rbp $fp.rb$rb
	      radiobutton $rbp -text "$ct" -value "$ct" -variable {CarTypeRb} \
		-command {MenuReportCar1TypeRb} -takefocus 0
	      pack configure $rbp -side left
	      incr ict
	    }
	    set frame [expr int($ict / 10)]
	    set label [expr $ict % 10]
	    set fp .selectCarType.f$frame
	    if {![winfo exists $fp]} {
	      frame $fp
	      pack configure $fp -side top -fill x
	    }
	    set labelp $fp.l$label
	    label $labelp -anchor {w} -highlightthickness {2} -relief {raised} \
		-takefocus {1} -text {Enter Car Type Here}
	    pack configure $labelp -side left -fill x -expand 1
	    bind $labelp <KeyPress> {MenuReportCar1TypeKey "%A"}
	    button .selectCarType.cancel -text {Cancel} \
		-command {
	    if {"[info procs XFEdit]" != ""} {
	      catch "XFDestroy .selectCarType"
	    } {
	      catch "destroy .selectCarType"
	    }}
	    pack configure .selectCarType.cancel -side top -expand 1
	    update idletasks
	    focus $labelp
	    grab .selectCarType
	    tkwait window .selectCarType
	  }
    Summary {
	      set TotalsOnly 1
	      PrintCarTypesSummaryHeader
	      PrintAllCarTypes
	    }
	    
  }
}




# Procedure: MenuReportCar1TypeRb
proc MenuReportCar1TypeRb {} {
  global TotalsOnly
  global CarTypeComment
  global CarTypes
  global CarTypeRb

  set ct "$CarTypeRb"

  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .selectCarType"
  } {
    catch "destroy .selectCarType"
  }

  set TotalsOnly 0

  global TypeTotal
  global AllTotalMoves
  global AllTotalAssigns
  set TypeTotal 0
  set AllTotalMoves 0
  set AllTotalAssigns 0

  PrintCarTypesHeader
  PrintDashedLine

  putPrinterLine {}
  putPrinterString "$ct"
  putPrinterTab 6
  putPrinterString "$CarTypes($ct)"
  putPrinterTab 40
  putPrinterString "$CarTypeComment($ct)"
  putPrinterTab 110
  putPrinterString {Moves}
  putPrinterTab 120
  putPrinterLine {Assigns}
  putPrinterLine {}

  PrintOneCarType "$ct"

  PrintFormFeed
  
  WIP_Done

}

# Procedure: MenuReportCar1TypeKey
proc MenuReportCar1TypeKey {key} {

  global TotalsOnly
  global CarTypeComment
  global CarTypes

  if {"$key" == {}} {return}

  if {"$key" == {,}} {return}
  if {[catch "set CarTypes($key)" ctype]} {
    if {[catch "set CarTypes(\\$key)" ctype]} {
      return
    }
  }

  set ct "$key"

  set TotalsOnly 0

  global TypeTotal
  global AllTotalMoves
  global AllTotalAssigns
  set TypeTotal 0
  set AllTotalMoves 0
  set AllTotalAssigns 0

  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .selectCarType"
  } {
    catch "destroy .selectCarType"
  }

  set TotalsOnly 0

  PrintCarTypesHeader
  PrintDashedLine

  putPrinterLine {}
  putPrinterString "$ct"
  putPrinterTab 6
  putPrinterString "$CarTypes($ct)"
  putPrinterTab 40
  putPrinterString "$CarTypeComment($ct)"
  putPrinterTab 110
  putPrinterString {Moves}
  putPrinterTab 120
  putPrinterLine {Assigns}
  putPrinterLine {}

  PrintOneCarType "$ct"

  PrintFormFeed
  
  WIP_Done
}

# Procedure: PrintCarTypesHeader
proc PrintCarTypesHeader {} {
  PrintSystemBanner
  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 12
  putPrinterLine {CAR TYPE Report}
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}
}

# Procedure: PrintCarTypesSummaryHeader
proc PrintCarTypesSummaryHeader {} {
  PrintCarTypesHeader

  putPrinterTab 40
  putPrinterString {Total}
  putPrinterTab 50
  putPrinterString {Shippers --------}
  putPrinterTab 70
  putPrinterString {Receivers -------}
  putPrinterTab 90
  putPrinterString {Moves}
  putPrinterTab 102
  putPrinterLine {Car Type}

  putPrinterTab 6
  putPrinterString {Type}
  putPrinterTab 40
  putPrinterString {of Type}
  putPrinterTab 50
  putPrinterString {Online}
  putPrinterTab 60
  putPrinterString {Offline}
  putPrinterTab 70
  putPrinterString {Online}
  putPrinterTab 80
  putPrinterString {Offline}
  putPrinterTab 90
  putPrinterString {Per Session}
  putPrinterTab 102
  putPrinterLine {Comments}

  PrintDashedLine

}  

# Procedure: PrintAllCarTypes
proc PrintAllCarTypes {} {
  global MaxCarGroup
  global CarGroup
  global MaxCarTypes
  global CarTypesOrder
  global CarTypes
  global CarTypeGroup
  global TotalsOnly
  global CarTypeComment
  global TotalIndustries
  global IndsLoadTypes
  global IndsType
  global IndsEmptyTypes

  global TypeTotal
  global AllTotalMoves
  global AllTotalAssigns
  set TypeTotal 0
  set AllTotalMoves 0
  set AllTotalAssigns 0

  for {set Group 1} {$Group <= $MaxCarGroup} {incr Group} {
    set GroupFound 0
    if {[catch "set CarGroup($Group)" groupCode]} {set groupCode {}}
    if {"$groupCode" != {}} {
      for {set Gx 1} {$Gx <= $MaxCarTypes} {incr Gx} {
	if {[catch "set CarTypesOrder($Gx)" cto]} {continue}
	if {"$cto" == {} || "$cto" == {,}} {continue}
	if {"$CarTypeGroup($cto)" != "$groupCode"} {continue}
	incr TypeTotal
	if {$TypeTotal == 53 && $TotalsOnly} {
	  PrintFormFeed
	  PrintCarTypesSummaryHeader
	}
	if {!$TotalsOnly} {putPrinterLine {}}
	putPrinterString "$cto"
	putPrinterTab 6
	putPrinterString "$CarTypes($cto)"
	putPrinterTab 40
	if {!$TotalsOnly} {
	  putPrinterString "$CarTypeComment($cto)"
	  putPrinterTab 110
	  putPrinterString {Moves}
	  putPrinterTab 120
	  putPrinterLine {Assigns}
	  putPrinterLine {}
	}
	if {$TotalsOnly} {
	  global OnlineReceiversOfType
	  global OfflineReceiversOfType
	  global OnlineShippersOfType
	  global OfflineShippersOfType
	  set OnlineReceiversOfType 0
	  set OfflineReceiversOfType 0
	  set OnlineShippersOfType 0
	  set OfflineShippersOfType 0

	  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {

	    set TypeSymbol "$cto"

	    if {[catch "set IndsLoadTypes($Ix)" loadtypes]} {continue}

	    if {[string first "$TypeSymbol" "$loadtypes"] != -1} {
	      if {"$IndsType($Ix)" == {I}} {incr OnlineReceiversOfType}
	      if {"$IndsType($Ix)" == {O}} {incr OfflineReceiversOfType}
	    }

	    if {[string first "$TypeSymbol" "$IndsEmptyTypes($Ix)"] != -1} {
	      if {"$IndsType($Ix)" == {I}} {incr OnlineShippersOfType}
	      if {"$IndsType($Ix)" == {O}} {incr OfflineShippersOfType}
	    }
	  }
	}

	PrintOneCarType "$cto"
      }
    }
  }

  putPrinterLine {}

  PrintDashedLine

  putPrinterLine {}

  global TotalCars
  global SessionNumber

  putPrinterTab 10
  putPrinterString "Total cars = $TotalCars"

  set TripsPerSession [expr $AllTotalMoves / double($SessionNumber)]

  putPrinterTab 40
  putPrinterString "Total Moves/Session = $TripsPerSession"
  putPrinterTab 80

  set TripsPerSession [expr $TripsPerSession / double($TotalCars)]
  putPrinterLine "[format {Avg Moves/Session = %5.2f} $TripsPerSession]"

  PrintFormFeed

  WIP_Done
}

# Procedure: PrintOneCarType
proc PrintOneCarType {ct} {
  global CarTypes
  global CarTypeComment
  global CarTypeGroup
  global TotalCars
  global CrsType
  global CrsTrips
  global CrsAssigns
  global CrsRR
  global CrsNum
  global CrsLen
  global CrsLoc
  global CrsDest
  global IndsName
  global AllTotalMoves
  global AllTotalAssigns
  global TotalsOnly
  global TripsPerSession
  global OnlineShippersOfType
  global OfflineShippersOfType
  global OnlineReceiversOfType
  global OfflineReceiversOfType
  global SessionNumber

  if {"$ct" == {,}} {return}
  if {[catch "set CarTypes($ct)" ctype]} {
    if {[catch "set CarTypes(\\$ct)" ctype]} {
      return
    }
  }
  if {"$ctype" == {}} {return}

  set CarsOfType 0
  set TotalMoves 0
  set TotalAssigns 0
  WIP_Start "CAR TYPES Report in progress:\n Group $CarTypeGroup($ct), Type $ct $CarTypes($ct)\n($CarTypeComment($ct))"
  WIP 0 {0% Done}
  set Tenth [expr 100.0 / double($TotalCars)]
  set Done 10
  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    set DonePer [expr $Cx * $Tenth]
    if {$DonePer > $Done} {   
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      incr Done 10
    }
    if {"$CrsType($Cx)" != "$ct"} {continue}

    incr CarsOfType

    incr TotalMoves $CrsTrips($Cx)
    incr AllTotalMoves $CrsTrips($Cx)
    incr TotalAssigns $CrsAssigns($Cx)
    incr AllTotalAssigns $CrsAssigns($Cx)

    GetCarStatus $Cx status carTypeDesc

#   PRINT "Now print car "; LTRIM$(STR$(Cx%)); " TotalsOnly% = "; TotalsOnly%
    if {!$TotalsOnly} {
      putPrinterTab 8
      putPrinterString "$CrsRR($Cx)"
      putPrinterTab 20
      putPrinterString "$CrsNum($Cx)"
      putPrinterTab 30
      putPrinterString "$CrsLen($Cx)ft"
      putPrinterTab 40
      putPrinterString "$status"
      putPrinterTab 50
      putPrinterString "at $IndsName($CrsLoc($Cx))"
      putPrinterTab 78
      putPrinterString "dest $IndsName($CrsDest($Cx))"
      putPrinterTab 110 
      putPrinterString "$CrsTrips($Cx)"
      putPrinterTab 120
      putPrinterLine "$CrsAssigns($Cx)"
    }
  }
  WIP 100 {100% Done}
  if {$CarsOfType > 0 && !$TotalsOnly} {putPrinterLine {}}
  if {!$TotalsOnly} {
    putPrinterTab 8
    putPrinterString {Cars of type:}
    putPrinterTab 30
    putPrinterString "CarTypes($ct)"
    putPrinterTab 64
    putPrinterLine " = $CarsOfType"
  } else {
    if {$CarsOfType > 0} {
      set TripsPerSession [expr $TotalMoves / double($SessionNumber)]
      set TripsPerSession [expr $TripsPerSession / double($CarsOfType)]
    } else {
      set TripsPerSession 0
    }
    putPrinterTab 40
    putPrinterString "$CarsOfType"
    putPrinterTab 50
    putPrinterString "$OnlineShippersOfType"
    putPrinterTab 60
    putPrinterString "$OfflineShippersOfType"
    putPrinterTab 70
    putPrinterString "$OnlineReceiversOfType"
    putPrinterTab 80
    putPrinterString "$OfflineReceiversOfType"
    putPrinterTab 90
    putPrinterString "[format %5.2f $TripsPerSession]"
    putPrinterTab 102
    putPrinterLine "[string range $CarTypeComment($ct) 0 34]"
  }
}
    
# Procedure: MenuReportCarLocations
proc MenuReportCarLocations {ReportType} {
  switch -exact "$ReportType" {
    INDUSTRY {ReportLocIndustry}
    STATION  {ReportLocStation}
    DIVISION {ReportLocDivision}
    ALL      {ReportLocAll}
  }
}

# Procedure: SelectANumber
proc SelectANumber {Label Lower Upper} {

  global SelectANumberResult
  set SelectANumberResult {}  

  # build widget .getIntegerRange
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getIntegerRange"
  } {
    catch "destroy .getIntegerRange"
  }
  toplevel .getIntegerRange 

  # Window manager configurations
  wm maxsize .getIntegerRange 1024 768
  wm minsize .getIntegerRange 0 0
  wm title .getIntegerRange {Select an integer value}


  # build widget .getIntegerRange.message1
  message .getIntegerRange.message1 \
    -aspect {1500} \
    -justify {center} \
    -padx {5} \
    -pady {2} \
    -text "$Label ($Lower to $Upper)"

  # build widget .getIntegerRange.scale2
  scale .getIntegerRange.scale2 \
    -orient {horizontal} -from $Lower -to $Upper

  # build widget .getIntegerRange.frame3
  frame .getIntegerRange.frame3 \
    -borderwidth {2}

  # build widget .getIntegerRange.frame3.button4
  button .getIntegerRange.frame3.button4 \
    -command {
      global SelectANumberResult
      set SelectANumberResult [.getIntegerRange.scale2 get]
      if {"[info procs XFEdit]" != ""} {
        catch "XFDestroy .getIntegerRange"
      } {
        catch "destroy .getIntegerRange"
      }} \
    -padx {9} \
    -pady {3} \
    -text {OK}

  # build widget .getIntegerRange.frame3.button5
  button .getIntegerRange.frame3.button5 \
    -command {
      global SelectANumberResult
      set SelectANumberResult {}
      if {"[info procs XFEdit]" != ""} {
        catch "XFDestroy .getIntegerRange"
      } {
        catch "destroy .getIntegerRange"
      }} \
    -padx {9} \
    -pady {3} \
    -text {Cancel}

  # pack master .getIntegerRange.frame3
  pack configure .getIntegerRange.frame3.button4 \
    -expand 1 \
    -side left
  pack configure .getIntegerRange.frame3.button5 \
    -expand 1 \
    -side left

  # pack master .getIntegerRange
  pack configure .getIntegerRange.message1 \
    -fill x
  pack configure .getIntegerRange.scale2 \
    -fill x
  pack configure .getIntegerRange.frame3 \
    -fill x
# end of widget tree

  update idletasks
  grab .getIntegerRange
  tkwait window .getIntegerRange

  return $SelectANumberResult

}

# Procedure: ReportLocIndustry
proc ReportLocIndustry {} {
  global TotalIndustries
  set TempIx [SelectANumber Industry 1 $TotalIndustries]
  if {"$TempIx" == {}} {return}
  if {$TempIx < 1 || $TempIx > $TotalIndustries} {return}
  global IndsStation
  global IndsName
  global FirstOne

  if {[catch "set IndsStation($TempIx)" Sx]} {return}
  if {$Sx == 0} {return}

  if {[catch "set IndsName($TempIx)" name]} {return}
  if {"$name" == {}} {return}

  [SN LogWindow] insert end "Print all cars at $name\n"
  [SN LogWindow] see end
  update

  set FirstOne 1

  PrintLocCommon

  PrintLocOneIndus $TempIx $Sx

  PrintFormFeed
}

# Procedure: ReportLocStation
proc ReportLocStation {} {
  global TotalStations
  set TempSx [SelectANumber Station 1 $TotalStations]
  if {"$TempSx" == {}} {return}
  if {$TempSx < 1 || $TempSx > $TotalStations} {return}
  global StnsName
  global StnsIndus
  if {[catch "set StnsName($TempSx)" name]} {return}
  if {"$name" == {}} {return}

  PrintLocCommon

  [SN LogWindow] insert end "Print all cars at $name\n"
  [SN LogWindow] see end
  update

  global FirstOne
  set FirstOne 1

  foreach Ix [lsort -integer $StnsIndus($TempSx)] {
    PrintLocOneIndus $Ix $TempSx
  }

  PrintFormFeed  
}

# Procedure: ReportLocDivision
proc ReportLocDivision {} {
  global TotalDivisions
  set TempDx [SelectANumber Division 1 $TotalDivisions]
  if {"$TempDx" == {}} {return}
  if {$TempDx < 1 || $TempDx > $TotalDivisions} {return}

  global FirstOne
  global DivsName
  global DivsStns
  global StnsName
  global StnsIndus

  if {[catch "set DivsName($TempDx)" name]} {return}
  if {"$name" == {}} {return}

  PrintLocCommon

  foreach Sx [lsort -integer $DivsStns($TempDx)] {
    [SN LogWindow] insert end "Print all cars at $StnsName($Sx)\n"
    [SN LogWindow] see end
    update

    set FirstOne 1

    foreach Ix [lsort -integer $StnsIndus($Sx)] {
      PrintLocOneIndus $Ix $Sx
    }
  }

  PrintFormFeed 
}

# Procedure: ReportLocAll
proc ReportLocAll {} {

  PrintLocCommon

# The "workbench" station is always 1. If we're skipping the workbench
# then start with station number 2.

  global PrintBench

  if {$PrintBench} {
    set ForStart 1
  } else {
    set ForStart 2
  }

  global TotalStations
  global StnsName
  global StnsIndus

  global FirstOne

  for {set Sx $ForStart} {$Sx <= $TotalStations} {incr Sx} {
    if {[catch "set StnsName($Sx)" name]} {continue}
    if {"$name" == {}} {continue}

    [SN LogWindow] insert end "Print all cars at $name\n"
    [SN LogWindow] see end
    update

    set FirstOne 1 

    foreach Ix [lsort -integer $StnsIndus($Sx)] {
      PrintLocOneIndus $Ix $Sx
    }
  }

  PrintFormFeed
}

# Procedure: PrintLocOneIndus
proc PrintLocOneIndus {Ix Sx} {

  global IndsStation
  if {$IndsStation($Ix) != $Sx} {return}

  global IndsCarsIndexes
  global StnsName
  global IndsName
  global IndsUsedLen
  global IndsTrackLen
  global IndsType
  global PrintYards
  global FirstOne

  set CarsAtIndus [llength $IndsCarsIndexes($Ix)]

# print the name of the station just once

  if {$FirstOne} {
    PrintDashedLine
    set FirstOne 0
    putPrinterString "$StnsName($Sx)"
  }

# print the name, length and car count for this industry

  putPrinterTab 27
  putPrinterString "$IndsName($Ix)"
  putPrinterTab 52
  putPrinterString "<$Ix> ($IndsUsedLen($Ix)/$IndsTrackLen($Ix))"
  putPrinterTab 77
  putPrinterString "Total cars"
  putPrinterTab 97
  putPrinterLine "$CarsAtIndus"

# don't print the contents of yards unless PrintYards% = TRUE%

  if {$PrintYards || "$IndsType($Ix)" != {Y}} {
    if {$CarsAtIndus > 0} {
      putPrinterLine {}
      foreach Cx [lsort -integer $IndsCarsIndexes($Ix)] {
	PrintOneCarLocation $Cx
      }
    }
  }

  putPrinterLine {}
}

# Procedure: PrintLocCommon
proc PrintLocCommon {} {
  GetIndustryCarCounts

  PrintSystemBanner

  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 10
  putPrinterLine {CAR LOCATION Report}
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}
}

# Procedure: PrintOneCarLocation
proc PrintOneCarLocation {Cx} {
  global CrsRR
  global CrsNum
  global CrsType
  global CrsDest
  global CarTypes
  global IndsStation
  global IndsName
  global StnsName

  putPrinterTab 27
  putPrinterString "$CrsRR($Cx)"
  putPrinterTab 40
  putPrinterString "$CrsNum($Cx)"
  putPrinterTab 51
  putPrinterString "$CarTypes($CrsType($Cx))"
  putPrinterTab 87
  putPrinterString "$StnsName($IndsStation($CrsDest($Cx)))"
  putPrinterTab 113
  putPrinterLine "$IndsName($CrsDest($Cx))"
}

# Procedure: AddCarOwnerToMenu
proc AddCarOwnerToMenu {OwnInitials Ox} {
  [SN ReportOwnersMenu] add command \
    -label "$OwnInitials" \
    -command "MenuReportCarOwners $OwnInitials $Ox"
}

# Procedure: MenuReportCarOwners
proc MenuReportCarOwners {OwnInitials Ox} {
  global TotalCars
  global CrsOwner
  global OwnerNames

  global CrsRR
  global CrsNum
  global CrsStatus
  global CrsLen
  global CrsType
  global CrsDest
  global CrsLoc
  global IndsName
  global CarTypes

  set CarsOwned 0

  WIP_Start "CAR OWNER Report -- $OwnInitials\n($OwnerNames($Ox))"
  WIP 0 {0% Done}
  set Tenth [expr 100.0 / double($TotalCars)]
  set Done 10
  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    set DonePer [expr $Cx * $Tenth]
    if {$DonePer > $Done} {
      WIP $DonePer "[format {%f%% Done} $DonePer]"
      incr Done 10
    }
    if {[string compare "$CrsOwner($Cx)" "[string toupper $OwnInitials]"] == 0} {
      incr CarsOwned
      if {$CarsOwned == 1} {
	PrintSystemBanner
	putPrinterLine {}
	putPrinterNormal
	putPrinterDouble
	putPrinterTab 10
	putPrinterString {CAR OWNER Report -- }
	if {$Ox == 0} {
	  putPrinterLine "$OwnInitials"
	} else {
	  putPrinterLine "$OwnerNames($Ox)"
	}
	putPrinterNarrow
	putPrinterLine {}
	putPrinterLine {}
	PrintDashedLine
      }
      putPrinterString "$CarsOwned"
      putPrinterTab 8
      putPrinterString "$CrsRR($Cx)"
      putPrinterTab 18
      putPrinterString "$CrsNum($Cx)"
      putPrinterTab 28
      putPrinterString "$CrsStatus($Cx)"
      putPrinterTab 31
      putPrinterString "$CrsLen($Cx)"
      putPrinterTab 37
      putPrinterString "$CarTypes($CrsType($Cx))"
      putPrinterTab 70
      putPrinterString "at $IndsName($CrsLoc($Cx))"
      putPrinterTab 96
      putPrinterLine " dest $IndsName($CrsDest($Cx))"
    }
  }
  if {$CarsOwned > 0} {PrintFormFeed}
  WIP_Done
}

# Procedure: MenuReportAnalysis
proc MenuReportAnalysis {} {

  global StatsPeriod
  global TotalDivisions
  global DivsName
  global DivsStns
  global DivsSymbol
  global TotalStations
  global StnsDiv
  global StnsIndus
  global StnsName
  global TotalIndustries
  global IndsStation
  global IndsName

  PrintSystemBanner

  putPrinterLine {}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 6
  putPrinterLine {INDUSTRY Utilization Analysis}
  putPrinterNormal
  putPrinterDouble
  putPrinterTab 15
  putPrinterLine "Shifts = $StatsPeriod"
  putPrinterLine {}
  putPrinterNarrow
  putPrinterLine {}
  putPrinterLine {}

  PrintAnalysisHeader

  PrintDashedLine

  set GrandTotalCarsToDiv 0

  set iCount 0

  set AnalysisIndustriesCount 0

  for {set Dx 1} {$Dx <= $TotalDivisions} {incr Dx} {

    if {[catch "set DivsName($Dx)" dname]} {continue}
    if {"$dname" == {}} {continue}

    foreach Sx $DivsStns($Dx) {
      incr AnalysisIndustriesCount [llength $StnsIndus($Sx)]
    }
  }

  set Tenth [expr 100.0 / double($AnalysisIndustriesCount)]
  WIP_Start {INDUSTRY Utilization Analysis in progress}
  WIP 0 {0% Done}

  for {set Dx 1} {$Dx <= $TotalDivisions} {incr Dx} {

    if {[catch "set DivsName($Dx)" dname]} {continue}
    if {"$dname" == {}} {continue}

    set CarsToDiv 0

    putPrinterLine {}

    foreach Sx [lsort -integer $DivsStns($Dx)] {
      foreach Ix [lsort -integer $StnsIndus($Sx)] {
	[SN WIP_Message] configure -text "INDUSTRY Utilization Analysis in progress\n$DivsName($Dx):$StnsName($Sx):$IndsName($Ix)"
	PrintOneAnalysis $Ix CarsToDiv
	incr iCount
	set DonePer [expr $iCount * $Tenth]
	WIP $DonePer "[format {%f%% Done} $DonePer]"
      }
    }
    incr GrandTotalCarsToDiv $CarsToDiv
    putPrinterLine {}
    putPrinterString "==========  <$DivsSymbol($Dx)> $DivsName($Dx) local industries summary --------"
    putPrinterTab 76
    putPrinterString $CarsToDiv
    putPrinterTab 85
    putPrinterString "[format %7.2f [expr double($CarsToDiv) / double($StatsPeriod)]]"
    putPrinterTab 98
    putPrinterLine [StringDup 28 {-}]  
  }
  putPrinterLine {}
  putPrinterString {==========  Grand Total all divisions  ========================}
  putPrinterTab 76
  putPrinterString $GrandTotalCarsToDiv
  putPrinterTab 85
  putPrinterString "[format %7.2f [expr double($GrandTotalCarsToDiv) / double($StatsPeriod)]]"
  putPrinterTab 98
  putPrinterLine [StringDup 28 {-}]

  PrintFormFeed
  WIP_Done
}

# Procedure: PrintAnalysisHeader
proc PrintAnalysisHeader {} {
# Eligible  Deliv  Cars Per  TrkLen/  CarsLen/  % Track
# Cars      Cars   Shift     Shift    Shift     Use/Shift
  putPrinterTab 66
  putPrinterString {Eligible}
  putPrinterTab 76
  putPrinterString {Deliv}
  putPrinterTab 86
  putPrinterString {Cars Per}
  putPrinterTab 96
  putPrinterString {TrkLen/}
  putPrinterTab 107
  putPrinterString {CarsLen/}
  putPrinterTab 118
  putPrinterLine {% Track}

  putPrinterString {#}
  putPrinterTab 5
  putPrinterString {City}
  putPrinterTab 37
  putPrinterString {Industry}
  putPrinterTab 66
  putPrinterString {Cars}
  putPrinterTab 76
  putPrinterString {Cars}
  putPrinterTab 86
  putPrinterString {Shift}
  putPrinterTab 96
  putPrinterString {Shifts}
  putPrinterTab 107
  putPrinterString {Shifts}
  putPrinterTab 118
  putPrinterLine {Use/Shift}
}

# Procedure: PrintOneAnalysis
proc PrintOneAnalysis {Ix CarsToDivVar} {
  upvar $CarsToDivVar CarsToDiv

  global TotalCars
  global CrsType
  global IndsLoadTypes
  global IndsEmptyTypes
  global IndsStation
  global IndsName
  global IndsCarsNum
  global IndsStatsLen
  global IndsCarsLen
  global IndsType
  global StnsName
  global StatsPeriod

  set CarsAvail 0

  for {set Cx 1} {$Cx <= $TotalCars} {incr Cx} {
    if {[string first "$CrsType($Cx)" "$IndsLoadTypes($Ix)"] >= 0} {
      incr CarsAvail
      continue
    }
    if {[string first "$CrsType($Cx)" "$IndsEmptyTypes($Ix)"] >= 0} {
      incr CarsAvail
      continue
    }
  }

  putPrinterString $Ix
  putPrinterTab 5
  putPrinterString "$IndsStation($Ix)"
  putPrinterTab 9
  putPrinterString "$StnsName($IndsStation($Ix))"
  putPrinterTab 37
  putPrinterString "$IndsName($Ix)"
  putPrinterTab 66
  putPrinterString $CarsAvail
  putPrinterTab 76
  putPrinterString $IndsCarsNum($Ix)
  putPrinterTab 86

  set CarsNum $IndsCarsNum($Ix)
  set Period $StatsPeriod
  set CarsPerSession [expr double($CarsNum) / double($Period)]

  putPrinterString "[format %6.2f $CarsPerSession]"
  putPrinterTab 96
  putPrinterString "[format %7.1f [expr double($IndsStatsLen($Ix)) / double($StatsPeriod)]]"
  putPrinterTab 107
  putPrinterString "[format %7.1f [expr double($IndsCarsLen($Ix)) / double($StatsPeriod)]]"
  putPrinterTab 118

  set CarsLen $IndsCarsLen($Ix)
  set TrackLen $IndsStatsLen($Ix)

  if {$TrackLen > 0} {
    set PercentUse [expr double($CarsLen) / double($TrackLen)]
  } else {
    [SN LogWindow] insert end "Track length = 0 for $IndsName($Ix)\n"
    [SN LogWindow] see end
    update
    set PercentUse 0
  }

  putPrinterLine "[format %6.2f [expr 100.0 * $PercentUse]]"

  if {"$IndsType($Ix)" != {Y}} {
    incr CarsToDiv $IndsCarsNum($Ix)
  }
}

# Procedure: ResetIndustryStats
proc ResetIndustryStats {} {
  global StatsPeriod
  global TotalIndustries
  global IndsCarsNum
  global IndsCarsLen
  global IndsStatsLen
  global IndsTrackLen

  set StatsPeriod 1

  for {set Ix 1} {$Ix <= $TotalIndustries} {incr Ix} {
    set IndsCarsNum($Ix) 0
    set IndsCarsLen($Ix) 0
    set IndsStatsLen($Ix) $IndsTrackLen($Ix)
  }
}

# User defined images


# Internal procedures


# Procedure: Alias
if {"[info procs Alias]" == ""} {
proc Alias { args} {
# xf ignore me 7
##########
# Procedure: Alias
# Description: establish an alias for a procedure
# Arguments: args - no argument means that a list of all aliases
#                   is returned. Otherwise the first parameter is
#                   the alias name, and the second parameter is
#                   the procedure that is aliased.
# Returns: nothing, the command that is bound to the alias or a
#          list of all aliases - command pairs. 
# Sideeffects: internalAliasList is updated, and the alias
#              proc is inserted
##########
  global internalAliasList

  if {[llength $args] == 0} {
    return $internalAliasList
  } {
    if {[llength $args] == 1} {
      set xfTmpIndex [lsearch $internalAliasList "[lindex $args 0] *"]
      if {$xfTmpIndex != -1} {
        return [lindex [lindex $internalAliasList $xfTmpIndex] 1]
      }
    } {
      if {[llength $args] == 2} {
        eval "proc [lindex $args 0] {args} {#xf ignore me 4
return \[eval \"[lindex $args 1] \$args\"\]}"
        set xfTmpIndex [lsearch $internalAliasList "[lindex $args 0] *"]
        if {$xfTmpIndex != -1} {
          set internalAliasList [lreplace $internalAliasList $xfTmpIndex $xfTmpIndex "[lindex $args 0] [lindex $args 1]"]
        } {
          lappend internalAliasList "[lindex $args 0] [lindex $args 1]"
        }
      } {
        error "Alias: wrong number or args: $args"
      }
    }
  }
}
}


# Procedure: GetSelection
if {"[info procs GetSelection]" == ""} {
proc GetSelection {} {
# xf ignore me 7
##########
# Procedure: GetSelection
# Description: get current selection
# Arguments: none
# Returns: none
# Sideeffects: none
##########

  # the save way
  set xfSelection ""
  catch "selection get" xfSelection
  if {"$xfSelection" == "selection doesn't exist or form \"STRING\" not defined"} {
    return ""
  } {
    return $xfSelection
  }
}
}


# Procedure: MenuPopupAdd
if {"[info procs MenuPopupAdd]" == ""} {
proc MenuPopupAdd { xfW xfButton xfMenu {xfModifier ""} {xfCanvasTag ""}} {
# xf ignore me 7
# the popup menu handling is from (I already gave up with popup handling :-):
#
# Copyright 1991,1992 by James Noble.
# Everyone is granted permission to copy, modify and redistribute.
# This notice must be preserved on all copies or derivates.
#
##########
# Procedure: MenuPopupAdd
# Description: attach a popup menu to widget
# Arguments: xfW - the widget
#            xfButton - the button we use
#            xfMenu - the menu to attach
#            {xfModifier} - a optional modifier
#            {xfCanvasTag} - a canvas tagOrId
# Returns: none
# Sideeffects: none
##########
  global tk_popupPriv

  set tk_popupPriv($xfMenu,focus) ""
  set tk_popupPriv($xfMenu,grab) ""
  if {"$xfModifier" != ""} {
    set press "$xfModifier-"
    set motion "$xfModifier-"
    set release "Any-"
  } {
    set press ""
    set motion ""
    set release ""
  }

  bind $xfMenu "<${motion}B${xfButton}-Motion>"  "MenuPopupMotion $xfMenu %W %X %Y"
  bind $xfMenu "<${release}ButtonRelease-${xfButton}>"  "MenuPopupRelease $xfMenu %W"
  if {"$xfCanvasTag" == ""} {
    bind $xfW "<${press}ButtonPress-${xfButton}>"  "MenuPopupPost $xfMenu %X %Y"
    bind $xfW "<${release}ButtonRelease-${xfButton}>"  "MenuPopupRelease $xfMenu %W"
  } {
    $xfW bind $xfCanvasTag "<${press}ButtonPress-${xfButton}>"  "MenuPopupPost $xfMenu %X %Y"
    $xfW bind $xfCanvasTag "<${release}ButtonRelease-${xfButton}>"  "MenuPopupRelease $xfMenu %W"
  }
}
}


# Procedure: MenuPopupMotion
if {"[info procs MenuPopupMotion]" == ""} {
proc MenuPopupMotion { xfMenu xfW xfX xfY} {
# xf ignore me 7
##########
# Procedure: MenuPopupMotion
# Description: handle the popup menu motion
# Arguments: xfMenu - the topmost menu
#            xfW - the menu
#            xfX - the root x coordinate
#            xfY - the root x coordinate
# Returns: none
# Sideeffects: none
##########
  global tk_popupPriv

  if {"[info commands $xfW]" != "" && [winfo ismapped $xfW] &&
      "[winfo class $xfW]" == "Menu" &&
      [info exists tk_popupPriv($xfMenu,focus)] &&
      "$tk_popupPriv($xfMenu,focus)" != "" &&
      [info exists tk_popupPriv($xfMenu,grab)] &&
      "$tk_popupPriv($xfMenu,grab)" != ""} {
    set xfPopMinX [winfo rootx $xfW]
    set xfPopMaxX [expr $xfPopMinX+[winfo width $xfW]]
    if {$xfX >= $xfPopMinX && $xfX <= $xfPopMaxX} {
      $xfW activate @[expr $xfY-[winfo rooty $xfW]]
      if {![catch "$xfW entryconfig @[expr $xfY-[winfo rooty $xfW]] -menu" result]} {
        if {"[lindex $result 4]" != ""} {
          foreach binding [bind $xfMenu] {
            bind [lindex $result 4] $binding [bind $xfMenu $binding]
          }
        }
      }
    } {
      $xfW activate none
    }
  }
}
}


# Procedure: MenuPopupPost
if {"[info procs MenuPopupPost]" == ""} {
proc MenuPopupPost { xfMenu xfX xfY} {
# xf ignore me 7
##########
# Procedure: MenuPopupPost
# Description: post the popup menu
# Arguments: xfMenu - the menu
#            xfX - the root x coordinate
#            xfY - the root x coordinate
# Returns: none
# Sideeffects: none
##########
  global tk_popupPriv

  if {"[info commands $xfMenu]" != ""} {
    if {![info exists tk_popupPriv($xfMenu,focus)]} {
      set tk_popupPriv($xfMenu,focus) [focus]
    } {
      if {"$tk_popupPriv($xfMenu,focus)" == ""} {
        set tk_popupPriv($xfMenu,focus) [focus]
      }
    }
    set tk_popupPriv($xfMenu,grab) $xfMenu

    catch "$xfMenu activate none"
    catch "$xfMenu post $xfX $xfY"
    catch "focus $xfMenu"
    catch "grab -global $xfMenu"
  }
}
}


# Procedure: MenuPopupRelease
if {"[info procs MenuPopupRelease]" == ""} {
proc MenuPopupRelease { xfMenu xfW} {
# xf ignore me 7
##########
# Procedure: MenuPopupRelease
# Description: remove the popup menu
# Arguments: xfMenu - the topmost menu widget
#            xfW - the menu widget
# Returns: none
# Sideeffects: none
##########
  global tk_popupPriv
  global tk_version

  if {"[info commands $xfW]" != "" && [winfo ismapped $xfW] &&
      "[winfo class $xfW]" == "Menu" &&
      [info exists tk_popupPriv($xfMenu,focus)] &&
      "$tk_popupPriv($xfMenu,focus)" != "" &&
      [info exists tk_popupPriv($xfMenu,grab)] &&
      "$tk_popupPriv($xfMenu,grab)" != ""} {
    if {$tk_version >= 3.0} {
      catch "grab release $tk_popupPriv($xfMenu,grab)"
    } {
      catch "grab none"
    }
    catch "focus $tk_popupPriv($xfMenu,focus)"
    set tk_popupPriv($xfMenu,focus) ""
    set tk_popupPriv($xfMenu,grab) ""
    if {"[$xfW index active]" != "none"} {
      $xfW invoke active; catch "$xfMenu unpost"
    }
  }
  catch "$xfMenu unpost"
}
}


# Procedure: NoFunction
if {"[info procs NoFunction]" == ""} {
proc NoFunction { args} {
# xf ignore me 7
##########
# Procedure: NoFunction
# Description: do nothing (especially with scales and scrollbars)
# Arguments: args - a number of ignored parameters
# Returns: none
# Sideeffects: none
##########
}
}


# Procedure: SN
if {"[info procs SN]" == ""} {
proc SN { {xfName ""}} {
# xf ignore me 7
##########
# Procedure: SN
# Description: map a symbolic name to the widget path
# Arguments: xfName
# Returns: the symbolic name
# Sideeffects: none
##########

  SymbolicName $xfName
}
}


# Procedure: SymbolicName
if {"[info procs SymbolicName]" == ""} {
proc SymbolicName { {xfName ""}} {
# xf ignore me 7
##########
# Procedure: SymbolicName
# Description: map a symbolic name to the widget path
# Arguments: xfName
# Returns: the symbolic name
# Sideeffects: none
##########

  global symbolicName

  if {"$xfName" != ""} {
    set xfArrayName ""
    append xfArrayName symbolicName ( $xfName )
    if {![catch "set \"$xfArrayName\"" xfValue]} {
      return $xfValue
    } {
      if {"[info commands XFProcError]" != ""} {
        XFProcError "Unknown symbolic name:\n$xfName"
      } {
        puts stderr "XF error: unknown symbolic name:\n$xfName"
      }
    }
  }
  return ""
}
}


# Procedure: Unalias
if {"[info procs Unalias]" == ""} {
proc Unalias { aliasName} {
# xf ignore me 7
##########
# Procedure: Unalias
# Description: remove an alias for a procedure
# Arguments: aliasName - the alias name to remove
# Returns: none
# Sideeffects: internalAliasList is updated, and the alias
#              proc is removed
##########
  global internalAliasList

  set xfIndex [lsearch $internalAliasList "$aliasName *"]
  if {$xfIndex != -1} {
    rename $aliasName ""
    set internalAliasList [lreplace $internalAliasList $xfIndex $xfIndex]
  }
}
}



# application parsing procedure
proc XFLocalParseAppDefs {xfAppDefFile} {
  global xfAppDefaults

  # basically from: Michael Moore
  if {[file exists $xfAppDefFile] &&
      [file readable $xfAppDefFile] &&
      "[file type $xfAppDefFile]" == "link"} {
    catch "file type $xfAppDefFile" xfType
    while {"$xfType" == "link"} {
      if {[catch "file readlink $xfAppDefFile" xfAppDefFile]} {
        return
      }
      catch "file type $xfAppDefFile" xfType
    }
  }
  if {!("$xfAppDefFile" != "" &&
        [file exists $xfAppDefFile] &&
        [file readable $xfAppDefFile] &&
        "[file type $xfAppDefFile]" == "file")} {
    return
  }
  if {![catch [list open "$xfAppDefFile" r] xfResult]} {
    set xfAppFileContents [read $xfResult]
    close $xfResult
    foreach line [split $xfAppFileContents "\n"] {
      # backup indicates how far to backup.  It applies to the
      # situation where a resource name ends in . and when it
      # ends in *.  In the second case you want to keep the *
      # in the widget name for pattern matching, but you want
      # to get rid of the . if it is the end of the name. 
      set backup -2  
      set line [string trim $line]
      if {[string index $line 0] == "#" || "$line" == ""} {
        # skip comments and empty lines
        continue
      }
      set list [split $line ":"]
      set resource [string trim [lindex $list 0]]
      set i [string last "." $resource]
      set j [string last "*" $resource]
      if {$j > $i} { 
        set i $j
        set backup -1
      }
      incr i
      set name [string range $resource $i end]
      incr i $backup
      set widname [string range $resource 0 $i]
      set value [string trim [lindex $list 1]]
      if {"$widname" != "" && "$widname" != "*"} {
        # insert the widget and resourcename to the application
        # defaults list.
        if {![info exists xfAppDefaults]} {
          set xfAppDefaults ""
        }
        lappend xfAppDefaults [list $widname [string tolower $name] $value]
      }
    }
  }
}

# application loading procedure
proc XFLocalLoadAppDefs {{xfClasses ""} {xfPriority "startupFile"} {xfAppDefFile ""}} {
  global env

  if {"$xfAppDefFile" == ""} {
    set xfFileList ""
    if {[info exists env(XUSERFILESEARCHPATH)]} {
      append xfFileList [split $env(XUSERFILESEARCHPATH) :]
    }
    if {[info exists env(XAPPLRESDIR)]} {
      append xfFileList [split $env(XAPPLRESDIR) :]
    }
    if {[info exists env(XFILESEARCHPATH)]} {
      append xfFileList [split $env(XFILESEARCHPATH) :]
    }
    append xfFileList " /usr/lib/X11/app-defaults"
    append xfFileList " /usr/X11/lib/X11/app-defaults"

    foreach xfCounter1 $xfClasses {
      foreach xfCounter2 $xfFileList {
        set xfPathName $xfCounter2
        if {[regsub -all "%N" "$xfPathName" "$xfCounter1" xfResult]} {
          set xfPathName $xfResult
        }
        if {[regsub -all "%T" "$xfPathName" "app-defaults" xfResult]} {
          set xfPathName $xfResult
        }
        if {[regsub -all "%S" "$xfPathName" "" xfResult]} {
          set xfPathName $xfResult
        }
        if {[regsub -all "%C" "$xfPathName" "" xfResult]} {
          set xfPathName $xfResult
        }
        if {[file exists $xfPathName] &&
            [file readable $xfPathName] &&
            ("[file type $xfPathName]" == "file" ||
             "[file type $xfPathName]" == "link")} {
          catch "option readfile $xfPathName $xfPriority"
          if {"[info commands XFParseAppDefs]" != ""} {
            XFParseAppDefs $xfPathName
          } {
            if {"[info commands XFLocalParseAppDefs]" != ""} {
              XFLocalParseAppDefs $xfPathName
            }
          }
        } {
          if {[file exists $xfCounter2/$xfCounter1] &&
              [file readable $xfCounter2/$xfCounter1] &&
              ("[file type $xfCounter2/$xfCounter1]" == "file" ||
               "[file type $xfCounter2/$xfCounter1]" == "link")} {
            catch "option readfile $xfCounter2/$xfCounter1 $xfPriority"
            if {"[info commands XFParseAppDefs]" != ""} {
              XFParseAppDefs $xfCounter2/$xfCounter1
            } {
              if {"[info commands XFLocalParseAppDefs]" != ""} {
                XFLocalParseAppDefs $xfCounter2/$xfCounter1
              }
            }
          }
        }
      }
    }
  } {
    # load a specific application defaults file
    if {[file exists $xfAppDefFile] &&
        [file readable $xfAppDefFile] &&
        ("[file type $xfAppDefFile]" == "file" ||
         "[file type $xfAppDefFile]" == "link")} {
      catch "option readfile $xfAppDefFile $xfPriority"
      if {"[info commands XFParseAppDefs]" != ""} {
        XFParseAppDefs $xfAppDefFile
      } {
        if {"[info commands XFLocalParseAppDefs]" != ""} {
          XFLocalParseAppDefs $xfAppDefFile
        }
      }
    }
  }
}

# application setting procedure
proc XFLocalSetAppDefs {{xfWidgetPath "."}} {
  global xfAppDefaults

  if {![info exists xfAppDefaults]} {
    return
  }
  foreach xfCounter $xfAppDefaults {
    if {"$xfCounter" == ""} {
      break
    }
    set widname [lindex $xfCounter 0]
    if {[string match $widname ${xfWidgetPath}] ||
        [string match "${xfWidgetPath}*" $widname]} {
      set name [string tolower [lindex $xfCounter 1]]
      set value [lindex $xfCounter 2]
      # Now lets see how many tcl commands match the name
      # pattern specified.
      set widlist [info command $widname]
      if {"$widlist" != ""} {
        foreach widget $widlist {
          # make sure this command is a widget.
          if {![catch "winfo id $widget"] &&
              [string match "${xfWidgetPath}*" $widget]} {
            catch "$widget configure -$name $value" 
          }
        }
      }
    }
  }
}

# initialize bindings for all widgets
proc XFInitAllBindings {} {
  # bindings
  bind all <Alt-Key> {
    tkTraverseToMenu %W %A
}
  bind all <Key-F10> {
    tkFirstMenu %W
}
  bind all <Key-Tab> {focus [tk_focusNext %W]}
  bind all <Shift-Key-Tab> {focus [tk_focusPrev %W]}
}


# end source
proc EndSrc {} {
  focus [SN ChooseLabel]
  if {![winfo exists .xfLoading] && ![winfo exists .xfEdit]} {
    update
    LoadSystemFile
    LoadCarFile
    LoadStatsFile
    RestartLoop
    Randomize
    global InitComplete
    set InitComplete 1
    ShowBanner
  }
}

# prepare auto loading
global auto_path
global tk_library
global xfLoadPath
foreach xfElement [eval list [split $xfLoadPath :] $auto_path] {
  if {[file exists $xfElement/tclIndex]} {
    lappend auto_path $xfElement
  }
}
catch "unset auto_index"

catch "unset auto_oldpath"

catch "unset auto_execs"


# initialize global variables
proc InitGlobals {} {
  global {Printer}
  set {Printer} {}
  global {PrinterType}
  set {PrinterType} {}
  global {PrinterTypes}
  set {PrinterTypes(NONE)} {No Printer}
  global {AllTotalMoves}
  set {AllTotalMoves} {0}
  global {AssignLoop}
  set {AssignLoop} {0}
  global {BoxMove}
  set {BoxMove} {0}
  global {COMMA}
  set {COMMA} {,}
  global {COPYING}
  set {COPYING} {
		    GNU GENERAL PUBLIC LICENSE
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
}
  global {CarDestDiv}
  set {CarDestDiv} {0}
  global {CarDiv}
  set {CarDiv} {}
  global {CarGroup}
  set {CarGroup(0)} {}
  global {CarGroupDesc}
  set {CarGroupDesc(0)} {}
  global {CarMatches}
  set {CarMatches(0)} {0}
  global {CarMovements}
  set {CarMovements} {0}
  global {CarTypeComment}
  set {CarTypeComment(0)} {}
  global {CarTypeDesc}
  set {CarTypeDesc} {}
  global {CarTypeGroup}
  set {CarTypeGroup(0)} {}
  global {CarTypes}
  set {CarTypes(,)} {}
  global {CarTypesFile}
  set {CarTypesFile} {}
  global {CarTypesList}
  set {CarTypesList} {}
  global {CarTypesOrder}
  set {CarTypesOrder(0)} {}
  global {CarsAtDest}
  set {CarsAtDest} {0}
  global {CarsAtDest_CarsInTransit}
  set {CarsAtDest_CarsInTransit} {0}
  global {CarsAtWorkBench}
  set {CarsAtWorkBench} {0}
  global {CarsFile}
  set {CarsFile} {}
  global {CarsInTransit}
  set {CarsInTransit} {0}
  global {CarsMoved}
  set {CarsMoved} {0}
  global {CarsMovedMore}
  set {CarsMovedMore} {0}
  global {CarsMovedOnce}
  set {CarsMovedOnce} {0}
  global {CarsMovedThree}
  set {CarsMovedThree} {0}
  global {CarsMovedTwice}
  set {CarsMovedTwice} {0}
  global {CarsNotMoved}
  set {CarsNotMoved} {0}
  global {CarsOfType}
  set {CarsOfType} {0}
  global {Consist}
  set {Consist(0)} {0}
  global {CrsAssigns}
  set {CrsAssigns(0)} {0}
  global {CrsClass}
  set {CrsClass(0)} {0}
  global {CrsDest}
  set {CrsDest(0)} {0}
  global {CrsDivList}
  set {CrsDivList(0)} {}
  global {CrsDone}
  set {CrsDone(0)} {}
  global {CrsFixedRoute}
  set {CrsFixedRoute(0)} {}
  global {CrsLdLmt}
  set {CrsLdLmt(0)} {0}
  global {CrsLen}
  set {CrsLen(0)} {0}
  global {CrsLoc}
  set {CrsLoc(0)} {0}
  global {CrsLtWt}
  set {CrsLtWt(0)} {0}
  global {CrsMoves}
  set {CrsMoves(0)} {0}
  global {CrsNum}
  set {CrsNum(0)} {}
  global {CrsOkToMirror}
  set {CrsOkToMirror(0)} {}
  global {CrsOwner}
  set {CrsOwner(0)} {}
  global {CrsPeek}
  set {CrsPeek(0)} {0}
  global {CrsPlate}
  set {CrsPlate(0)} {0}
  global {CrsRR}
  set {CrsRR(0)} {}
  global {CrsStatus}
  set {CrsStatus(0)} {E}
  global {CrsTmpStatus}
  set {CrsTmpStatus(0)} {}
  global {CrsTrain}
  set {CrsTrain(0)} {0}
  global {CrsTrips}
  set {CrsTrips(0)} {0}
  global {CrsType}
  set {CrsType(0)} {NULL}
  global {CurCol}
  set {CurCol} {0}
  global {CurDiv}
  set {CurDiv} {0}
  global {CurInd}
  set {CurInd} {0}
  global {CurLine}
  set {CurLine} {0}
  global {CurLineLoc}
  set {CurLineLoc} {0}
  global {CurLineMan}
  set {CurLineMan} {0}
  global {CurStation}
  set {CurStation} {0}
  global {CxCol}
  set {CxCol} {18}
  global {CxInCol}
  set {CxInCol} {48}
  global {DateStamp}
  set {DateStamp} {}
  global {Deliver}
  set {Deliver} {0}
  global {DestList}
  set {DestList} {}
  global {DidAction}
  set {DidAction} {0}
  global {DivsArea}
  set {DivsArea(0)} {}
  global {DivsHome}
  set {DivsHome(0)} {0}
  global {DivsName}
  set {DivsName(0)} {}
  global {DivsSymbol}
  set {DivsSymbol(0)} {}
  global {DivsStns}
  set {DivsStns(0)} {}
  global {GroupLimit}
  set {GroupLimit} {0}
  global {History}
  set {History} {
$Log$
Revision 1.1  2004/05/30 19:00:25  heller
Added in Tcl port of Freight Car Forwarder.

Revision 1.3  1996/08/14 23:03:29  heller
Small typo

Revision 1.2  1996/08/13 02:49:24  heller
Fixed a few logic bugs in the train operations code.
These bugs were discovered after (finally!) running the BASIC version
and getting *very* different results.

Revision 1.1  1996/08/06 19:04:35  heller
Initial revision

}
  global {IndRipTrack}
  set {IndRipTrack} {0}
  global {IndScrapYard}
  set {IndScrapYard} {999}
  global {IndsAssignLen}
  set {IndsAssignLen(0)} {0}
  global {IndsCarLen}
  set {IndsCarLen(0)} {0}
  global {IndsCarsLen}
  set {IndsCarsLen(0)} {0}
  global {IndsCarsNum}
  set {IndsCarsNum(0)} {0}
  global {IndsCarsIndexes}
  set {IndsCarsIndexes(0)} {}
  global {IndsClass}
  set {IndsClass(0)} {0}
  global {IndsDivList}
  set {IndsDivList(0)} {}
  global {IndsEmptyTypes}
  set {IndsEmptyTypes(0)} {}
  global {IndsHazard}
  set {IndsHazard(0)} {}
  global {IndsLoadTypes}
  set {IndsLoadTypes(0)} {}
  global {IndsMirror}
  set {IndsMirror(0)} {0}
  global {IndsName}
  set {IndsName(0)} {}
  global {IndsPlate}
  set {IndsPlate(0)} {0}
  global {IndsPriority}
  set {IndsPriority(0)} {0}
  global {IndsReload}
  set {IndsReload(0)} {}
  global {IndsRemLen}
  set {IndsRemLen(0)} {0}
  global {IndsStation}
  set {IndsStation(0)} {0}
  global {IndsStatsLen}
  set {IndsStatsLen(0)} {0}
  global {IndsTrackLen}
  set {IndsTrackLen(0)} {0}
  global {IndsType}
  set {IndsType(0)} {}
  global {IndsUsedLen}
  set {IndsUsedLen(0)} {0}
  global {IndusFile}
  set {IndusFile} {}
  global {InitComplete}
  set {InitComplete} {0}
  global {LastEditCx}
  set {LastEditCx} {0}
  global {LastPx}
  set {LastPx} {0}
  global {LimitCars}
  set {LimitCars} {0}
  global {MaxCarGroup}
  set {MaxCarGroup} {16}
  global {MaxCarTypes}
  set {MaxCarTypes} {128}
  global {MaxCarsInTrain}
  set {MaxCarsInTrain} {60}
  global {MaxMatches}
  set {MaxMatches} {15}
  global {MaxOrdersLength}
  set {MaxOrdersLength} {8}
  global {MaxTrainStops}
  set {MaxTrainStops} {14}
  global {NewCopyright}
  set {NewCopyright} {$Id$
Freight Car Forwarder Version 1.0 Copyright (C) 1996 Robert Heller
Freight Car Forwarder comes with ABSOLUTELY NO WARRANTY; for details
select Warranty under the Help menu.
This is free software, and you are welcome to redistribute it
under certain conditions; select Copying uner the help menu
for details.}
  global {NewCx}
  set {NewCx} {0}
  global {OfflineReceiversOfType}
  set {OfflineReceiversOfType} {0}
  global {OfflineShippersOfType}
  set {OfflineShippersOfType} {0}
  global {OldCopyright}
  set {OldCopyright} {============================================================================
+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
============================================================================

 COPYRIGHT (c) 1992-1996 Timothy B. O'Connor

============================================================================


   YARDMEISTER                 


       Author: Timothy O'Connor

               enhancements    -- complex car assignment rules
                               -- complex car pickup rules for trains
                               -- soft (assumptionless) car types
                               -- car attributes like length, weight, size
                               -- fancy reports, analysis, statistics
                               -- yard lists for pickups and dropoffs
                               -- support for same-shift connections
                               -- breakup of database into multiple files
                               -- database files allow unlimited comments
                               -- many many bug fixes
                               -- improvements to user interface
                               -- documentation (original program used
                                    variable names like "A(x)" and "J")

       Earlier contributors:

               Mark Hanslip    original WAYBILL program
               Paul Diamond    original menu oriented user interface

       Date:   June 24, 1996

============================================================================
+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
============================================================================


 This comes from a program called WAYBILL originally written by, I think,
 Mark Hanslip. It has been modified so much that it hardly resembles the
 original. But Mark gets credit for the basic concepts embodied here.

 I have successfully tested with about 800 freight cars and 80 trains. The
 BASIC environment has memory restrictions but it's a mystery to me how to
 explain, much less alter them. Good luck. Perhaps Microsoft will do a 32-
 bit BASIC and end our pain.

 This software is COPYRIGHT (c) 1992-1996 -- You may alter it, pass it on,
 and generally do anything you wish EXCEPT sell it for profit. Nor may you
 include any part of it in other for-profit software or literature. And if
 you violate this, good luck in getting anyone to pay you for it, since it
 will render any copyright of your own as null and void.
 
 The above copyright statement must be included with every source copy of
 this software, or any portion thereof. Failure to do so will result in a
 severe spanking, or worse.

============================================================================}
  global {OnlineReceiversOfType}
  set {OnlineReceiversOfType} {0}
  global {OnlineShippersOfType}
  set {OnlineShippersOfType} {0}
  global {OrderFile}
  set {OrderFile} {}
  global {OriginYard}
  set {OriginYard} {0}
  global {OwnerFile}
  set {OwnerFile} {}
  global {OwnerInitials}
  set {OwnerInitials(0)} {}
  global {OwnerNames}
  set {OwnerNames(0)} {}
  global {PassLoop}
  set {PassLoop} {0}
  global {PickIndex}
  set {PickIndex} {0}
  global {PrintAlpha}
  set {PrintAlpha} {0}
  global {PrintAtwice}
  set {PrintAtwice} {0}
  global {PrintBench}
  set {PrintBench} {0}
  global {PrintBox}
  set {PrintBox} {0}
  global {PrintDispatch}
  set {PrintDispatch} {1}
  global {PrintList}
  set {PrintList} {1}
  global {PrintLtwice}
  set {PrintLtwice} {0}
  global {PrintYards}
  set {PrintYards} {0}
  global {Printem}
  set {Printem} {0}
  global {RailSystem}
  set {RailSystem} {}
  global {RanAllTrains}
  set {RanAllTrains} {0}
  global {RanVar}
  set {RanVar} {1}
  global {ScreenOn}
  set {ScreenOn} {0}
  global {SessionNumber}
  set {SessionNumber} {0}
  global {ShiftNumber}
  set {ShiftNumber} {0}
  global {StatsFile}
  set {StatsFile} {}
  global {StatsPeriod}
  set {StatsPeriod} {0}
  global {Status}
  set {Status} {}
  global {StnsDiv}
  set {StnsDiv(0)} {0}
  global {StnsName}
  set {StnsName(0)} {}
  global {StnsIndus}
  set {StnsIndus(0)} {}
  global {StopList}
  set {StopList(0)} {0}
  global {SwitchListDropStop}
  set {SwitchListDropStop(0)} {0}
  global {SwitchListLastTrain}
  set {SwitchListLastTrain(0)} {0}
  global {SwitchListLimitCars}
  set {SwitchListLimitCars} {0}
  global {SwitchListPickCar}
  set {SwitchListPickCar(0)} {0}
  global {SwitchListPickLoc}
  set {SwitchListPickLoc(0)} {0}
  global {SwitchListPickTrain}
  set {SwitchListPickTrain(0)} {0}
  global {TotalAssigns}
  set {TotalAssigns} {0}
  global {TotalCars}
  set {TotalCars} {0000}
  global {TotalDivisions}
  set {TotalDivisions} {0}
  global {TotalIndustries}
  set {TotalIndustries} {0}
  global {TotalMoves}
  set {TotalMoves} {0}
  global {TotalOwners}
  set {TotalOwners} {0}
  global {TotalPickups}
  set {TotalPickups} {0}
  global {TotalRevenueTons}
  set {TotalRevenueTons} {0}
  global {TotalShifts}
  set {TotalShifts} {0}
  global {TotalTons}
  set {TotalTons} {0}
  global {TotalTrains}
  set {TotalTrains} {0}
  global {TrainCars}
  set {TrainCars} {0}
  global {TrainClass}
  set {TrainClass} {0}
  global {TrainEmpties}
  set {TrainEmpties} {0}
  global {TrainFile}
  set {TrainFile} {}
  global {TrainLastLocation}
  set {TrainLastLocation} {0}
  global {TrainLen}
  set {TrainLen} {0}
  global {TrainLoads}
  set {TrainLoads} {0}
  global {TrainLongest}
  set {TrainLongest} {0}
  global {TrainMaxCars}
  set {TrainMaxCars} {0}
  global {TrainMaxLen}
  set {TrainMaxLen} {0}
  global {TrainPlate}
  set {TrainPlate} {0}
  global TrainPrintOK
  set TrainPrintOK 0
  global {TrainTons}
  set {TrainTons} {0}
  global {TrnCarTypes}
  set {TrnCarTypes(0)} {}
  global {TrnDesc}
  set {TrnDesc(0)} {}
  global {TrnDivList}
  set {TrnDivList(0)} {}
  global {TrnDone}
  set {TrnDone(0)} {}
  global {TrnIndex}
  set {TrnIndex(.)} {}
  global {TrnMxCars}
  set {TrnMxCars(0)} {0}
  global {TrnMxClear}
  set {TrnMxClear(0)} {0}
  global {TrnMxLen}
  set {TrnMxLen(0)} {0}
  global {TrnMxWeigh}
  set {TrnMxWeigh(0)} {0}
  global {TrnName}
  set {TrnName(0)} {}
  global {TrnOnDuty}
  set {TrnOnDuty(0)} {}
  global {TrnOrdLen}
  set {TrnOrdLen(0)} {0}
  global {TrnOrder}
  set {TrnOrder(0,0)} {}
  global {TrnPrint}
  set {TrnPrint(0)} {}
  global {TrnShift}
  set {TrnShift(0)} {0}
  global {TrnStops}
  set {TrnStops(0,0)} {0}
  global {TrnType}
  set {TrnType(0)} {}
  global {WARRANTY}
  set {WARRANTY} {
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
}
  global {Wayfreight}
  set {Wayfreight} {0}
  global {YesNo}
  set {YesNo} {0}
  global {alertBox}
  set {alertBox(activeBackground)} {}
  set {alertBox(activeForeground)} {}
  set {alertBox(after)} {0}
  set {alertBox(anchor)} {nw}
  set {alertBox(background)} {}
  set {alertBox(button)} {0}
  set {alertBox(font)} {}
  set {alertBox(foreground)} {}
  set {alertBox(justify)} {center}
  set {alertBox(toplevelName)} {.alertBox}
  global {fsBox}
  set {fsBox(activeBackground)} {}
  set {fsBox(activeForeground)} {}
  set {fsBox(background)} {}
  set {fsBox(button)} {0}
  set {fsBox(extensions)} {0}
  set {fsBox(font)} {}
  set {fsBox(foreground)} {}
  set {fsBox(internalPath)} {}
  set {fsBox(name)} {}
  set {fsBox(path)} {}
  set {fsBox(pattern)} {*}
  set {fsBox(scrollActiveForeground)} {}
  set {fsBox(scrollBackground)} {}
  set {fsBox(scrollForeground)} {}
  set {fsBox(scrollSide)} {left}
  set {fsBox(showPixmap)} {0}
  set {fsBox(typeMask)} {Regular}
  global {inputBox}
  set {inputBox(activeBackground)} {}
  set {inputBox(activeForeground)} {}
  set {inputBox(anchor)} {n}
  set {inputBox(background)} {}
  set {inputBox(erase)} {1}
  set {inputBox(font)} {}
  set {inputBox(foreground)} {}
  set {inputBox(justify)} {center}
  set {inputBox(scrollActiveForeground)} {}
  set {inputBox(scrollBackground)} {}
  set {inputBox(scrollForeground)} {}
  set {inputBox(scrollSide)} {left}
  set {inputBox(toplevelName)} {.inputBox}
  global {menuTearoff}
  set {menuTearoff} {0}
  global {textBox}
  set {textBox(activeBackground)} {}
  set {textBox(activeForeground)} {}
  set {textBox(background)} {}
  set {textBox(button)} {0}
  set {textBox(contents)} {}
  set {textBox(font)} {}
  set {textBox(foreground)} {}
  set {textBox(scrollActiveForeground)} {}
  set {textBox(scrollBackground)} {}
  set {textBox(scrollForeground)} {}
  set {textBox(scrollSide)} {left}
  set {textBox(state)} {disabled}
  set {textBox(toplevelName)} {.textBox}
  global {yesNoBox}
  set {yesNoBox(activeBackground)} {}
  set {yesNoBox(activeForeground)} {}
  set {yesNoBox(afterNo)} {0}
  set {yesNoBox(afterYes)} {0}
  set {yesNoBox(anchor)} {n}
  set {yesNoBox(background)} {}
  set {yesNoBox(button)} {0}
  set {yesNoBox(font)} {*times-bold-r-normal*24*}
  set {yesNoBox(foreground)} {}
  set {yesNoBox(justify)} {center}

  # please don't modify the following
  # variables. They are needed by xf.
  global {autoLoadList}
  set {autoLoadList(FreightCarForwarder.tcl)} {0}
  global {internalAliasList}
  set {internalAliasList} {}
  global {moduleList}
  set {moduleList(FreightCarForwarder.tcl)} {}
  global {preloadList}
  set {preloadList(xfInternal)} {}
  global {symbolicName}
  set {symbolicName(ChooseLabel)} {.label1}
  set {symbolicName(LogWindow)} {.logTotals.frame.text2}
  set {symbolicName(WIP_Message)} {.wip.message1}
  set {symbolicName(WorkInProgress)} {.wip.scale0}
  set {symbolicName(ReportOwnersMenu)} {.mainMenu.right.menubutton13.m.owners}
  set {symbolicName(root)} {.}
  global {xfWmSetPosition}
  set {xfWmSetPosition} {}
  global {xfWmSetSize}
  set {xfWmSetSize} {}
  global {xfAppDefToplevels}
  set {xfAppDefToplevels} {}
}

# initialize global variables
InitGlobals

# display/remove toplevel windows.
ShowWindow.

# load default bindings.
if {[info exists env(XF_BIND_FILE)] &&
    "[info procs XFShowHelp]" == ""} {
  source $env(XF_BIND_FILE)
}

# initialize bindings for all widgets.
XFInitAllBindings


# parse and apply application defaults.
XFLocalLoadAppDefs FreightCarForwarder
XFLocalSetAppDefs

# end source
EndSrc

# eof
#

