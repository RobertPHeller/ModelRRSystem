#* 
#* ------------------------------------------------------------------
#* SampleCode.tcl - Sample Code for programming guide listings and figures.
#* Created by Robert Heller on Tue Oct  9 12:03:49 2007
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

set argv0 [info nameofexecutable]

package require Tk;#		Include Tk
package require BWidget;#	Include BWidget
package require snit;#		Include Snit
package require Splash;#	Splash screen module

global CommonImageDir;#		Common Images
set CommonImageDir [file join [file dirname [file dirname [info script]]] \
			Common]
global HelpDir;#		Help directory
set HelpDir [file join [file dirname [file dirname [file dirname \
						[info script]]]] Help]

image create photo CloseButtonImage -file [file join $CommonImageDir close.gif]
# Close button image (used on toolbar)

image create photo DeepwoodsBanner -format gif \
        -file [file join $CommonImageDir DeepwoodsBanner.gif]
# Deepwoods banner image.  Used in the splash screen.
# [index] DeepwoodsBanner!image

proc SplashScreen {} {
  # Build the ``Splash Screen'' -- A popup window that tells the user what 
  # we are all about.  It gives the version and brief copyright information.
  #
  # The upper part of the splash screen gives the brief information, with
  # directions on how to get detailed information.  The lower part contains
  # an image banner for Deepwoods Software.
  # [index] SplashScreen!procedure

  splash .mrrSplash \
	-title {Sample Code Program -- sample code for Programming Guide, Copyright (C) 2005 R
obert Heller D/B/A Deepwoods Software Model Railroad Timetable Chart Program com
es with ABSOLUTELY NO WARRANTY; for details select 'Warranty...' under the Help 
menu.  This is free software, and you are welcome to redistribute it under certa
in conditions; select 'Copying...' under the Help menu.} \
        -image DeepwoodsBanner -background {#2ba2bf} \
        -titleforeground white -statusforeground {black}
}

proc SplashWorkMessage {message percent} {
  .mrrSplash update "$message" $percent
  update idle
}

wm withdraw .
SplashScreen
update idle

catch {SplashWorkMessage {Creating Main Window} 11}

package require SampleCodeMain

catch {SplashWorkMessage {Create CTC Panel} 22}

package require SampleCodeCTCPanel

catch {SplashWorkMessage {Create Configutation} 33}

package require SampleCodeRC

catch {SplashWorkMessage {Populate Slideout} 44}

package require SampleCodeSlideout 

catch {SplashWorkMessage {LoadCircle Code} 55}

package require SampleCodeCircle

Circle bindtocanvas $SampleCode::CanvasWindow <1> {
  set sr [$SampleCode::CanvasWindow cget -scrollregion]
  if {[llength $sr] < 4} {set sr [list 0 0 0 0]}
  set bbox [$SampleCode::CanvasWindow bbox all]
  if {[llength $bbox] < 4} {set bbox [list 0 0 0 0]}
  if {[lindex $bbox 0] < [lindex $sr 0]} {lset sr 0 [lindex $bbox 0]}
  if {[lindex $bbox 1] < [lindex $sr 1]} {lset sr 1 [lindex $bbox 1]}
  if {[lindex $bbox 2] > [lindex $sr 2]} {lset sr 2 [lindex $bbox 2]}
  if {[lindex $bbox 3] > [lindex $sr 3]} {lset sr 3 [lindex $bbox 3]}
  $SampleCode::CanvasWindow configure -scrollregion $sr
}

catch {SplashWorkMessage {Create Instrument Panel} 66}

package require SampleCodeInstrumentPanel

catch {SplashWorkMessage {Done} 100}

$SampleCode::Main showit
