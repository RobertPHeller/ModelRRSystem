#* 
#* ------------------------------------------------------------------
#* SampleCodeMain.tcl - Sample code -- Main window
#* Created by Robert Heller on Sat Oct 13 13:51:28 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2007/11/30 13:56:50  heller
#* Modification History: Novemeber 30, 2007 lockdown.
#* Modification History:
#* Modification History: Revision 1.1  2007/10/22 17:45:41  heller
#* Modification History: 10222007
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

package require Tk
package require BWidget
package require snit
package require BWStdMenuBar;#	Standard Menu Bar
package require BWHelp;#	Help package
package require DWpanedw;#	Modified paned window
package require MainWindow;#	Main Window package

namespace eval SampleCode {

  wm protocol . WM_DELETE_WINDOW {SampleCode::CarefulExit}
  wm title . "Sample Code"

  variable Main;#		Main window
  variable MainWindow;#		Main display area
  variable CanvasWindow;#	Canvas  window	

  # Create the main window
  pack [set Main [mainwindow .main -dontwithdraw no]] \
	-expand yes -fill both
  # Create and show a toolbar -- 
  #	this toolbar will mirror the File menu
  $Main toolbar add tools
  $Main toolbar show tools
  # Disable the unused File menu items
  $Main menu entryconfigure file New -state disabled
  $Main menu entryconfigure file Open... -state disabled
  $Main menu entryconfigure file Save -state disabled
  $Main menu entryconfigure file {Save As...} -state disabled
  $Main menu entryconfigure file Print... -state disabled
  # Bind Close and Exit menu items to the exit function 
  # and create an exit button.
  $Main menu entryconfigure file Close -command SampleCode::CarefulExit
  $Main menu entryconfigure file Exit -command SampleCode::CarefulExit
  $Main toolbar addbutton tools close -image CloseButtonImage \
				-command SampleCode::CarefulExit
  set MainWindow [$Main scrollwindow getframe]
  # Create a canvas window
  pack [set CanvasWindow [canvas $MainWindow.canvas -background white]] -fill both -expand yes
  $Main scrollwindow setwidget $CanvasWindow
  # Add a 'slideout'
  variable Slideout [$Main slideout add sampleslide]
  # Add some buttons to the Button box
  $Main buttons add -name showslide \
		    -text "Show Slideout" \
		    -helptext "Show the sample slideout" \
		    -command "$Main slideout show sampleslide"
  $Main buttons add -name hideslide \
		    -text "Hide Slideout" \
		    -helptext "Hide the sample slideout" \
		    -command "$Main slideout hide sampleslide"
  $Main buttons add -name testB1 \
		    -text "Test Button 1" \
		    -helptext "Just a test button" \
		    -command {tk_messageBox -type ok \
					    -icon info \
					    -message "Testing"}
}

proc SampleCode::CarefulExit {{ask 1}} {
  if {$ask} {
    set ans [tk_messageBox -type yesno -icon question -message {Really Exit?}]
  } else {
    set ans 1
  }
  if {!$ans} {return}
  exit
}

package provide SampleCodeMain 1.0
