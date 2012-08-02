#* 
#* ------------------------------------------------------------------
#* panelCode.tcl - Panel Main Window Creation Library
#* Created by Robert Heller on Sun Apr 13 18:27:24 2008
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

snit::type MainWindow {
  pragma -hastypeinfo    no
  pragma -hastypedestroy no
  pragma -hasinstances   no

  typecomponent main
  typecomponent swframe
  typecomponent ctcpanel

  delegate typemethod {ctcpanel *} to ctcpanel
  delegate typemethod {main *} to main
  typemethod createwindow {args} {
    set name [from args -name {}]
    set width [from args -width 800]
    set height [from args -height 800]
    wm protocol . WM_DELETE_WINDOW [mytypemethod CarefulExit]
    wm withdraw .
    wm title . "$name"
    set main [mainwindow .main]
    pack $main -expand yes -fill both
    $main menu entryconfigure file New -state disabled
    $main menu entryconfigure file Open... -state disabled
    $main menu entryconfigure file Save -state disabled
    $main menu entryconfigure file {Save As...} -state disabled
    $main menu entryconfigure file Print... -state disabled
    $main menu entryconfigure file Close -command [mytypemethod CarefulExit]
    $main menu entryconfigure file Exit -command [mytypemethod CarefulExit]
    set frame [$main scrollwindow getframe]
    set swframe [ScrollableFrame $frame.swframe \
			-constrainedheight yes -constrainedwidth yes \
			-width [expr {$width + 15}] -height $height]
    pack $swframe -expand yes -fill both
    $main scrollwindow setwidget $swframe
    set ctcpanel [::CTCPanel::CTCPanel [$swframe getframe].ctcpanel \
			-width $width -height $height]
    pack $ctcpanel -fill both -expand yes
    $main menu add view command \
		-label {Zoom In} \
		-accelerator {+} \
		-command "$ctcpanel zoomBy 2"
    set zoomMenu [menu [$main mainframe getmenu view].zoom -tearoff no]
    $main menu add view cascade \
		-label Zoom \
		-menu $zoomMenu
    $main menu add view command \
		-label {Zoom Out} \
		-accelerator {-} \
		-command "$ctcpanel zoomBy .5"
    $zoomMenu add command -label {16:1} -command "$ctcpanel setZoom 16"
    $zoomMenu add command -label {8:1} -command "$ctcpanel setZoom 8"
    $zoomMenu add command -label {4:1} -command "$ctcpanel setZoom 4"
    $zoomMenu add command -label {2:1} -command "$ctcpanel setZoom 2"
    $zoomMenu add command -label {1:1} -command "$ctcpanel setZoom 1"
    $zoomMenu add command -label {1:2} -command "$ctcpanel setZoom .5"
    $zoomMenu add command -label {1:4} -command "$ctcpanel setZoom .25"
    $zoomMenu add command -label {1:8} -command "$ctcpanel setZoom .125"
    $zoomMenu add command -label {1:16} -command "$ctcpanel setZoom .0625"

    $main showit
  }
  typemethod CarefulExit {{answer no}} {
    if {!$answer} {
      set answer [tk_messageBox -default no -icon question \
			-message {Really Quit?} -title {Careful Exit} \
			-type yesno -parent $main]
      if {$answer} {exit}
    }
  }  
}
