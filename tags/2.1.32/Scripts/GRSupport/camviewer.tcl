#!/usr/bin/wish8.3 -f
#* 
#* ------------------------------------------------------------------
#* camviewer.tcl - loco control panel with virtual windshield view
#* Created by Robert Heller on Sun Jul 28 09:59:13 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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
# Program: camviewer
# Tcl version: 8.3 (Tcl/Tk/XF)
# Tk version: 8.3
# XF version: 4.0
#

lappend auto_path [file dirname [info script]]

package require Img 1.2

package require http 2.0

package require grsupport 1.0

# procedure to show window .
proc MainWindow {args} {# xf ignore me 7

  # Window manager configurations
  wm positionfrom . user
  wm sizefrom . ""
  wm resizable . 0 0
  wm overrideredirect . 1
  wm title . {VisCam}
  wm protocol . WM_DELETE_WINDOW {CleanExit}

  # build widget .frame0.frame1.frame3.canvas8
  canvas .view \
    -width 800 -height 600 \
    -background grey \
    -borderwidth 0

  menu .view.menu -tearoff 0 -type normal
  .view.menu add command -label {Change Camera}
  .view.menu add command -label {Change Resolution} -command {ChangeResolution}
  .view.menu add checkbutton -label {Split Screen Mode}
  .view.menu add command -label {Describe View} -command {DescribeView}
  .view.menu add command -label {Pause} -command {PauseResume}
  .view.menu add separator
  .view.menu add command -command {CleanExit} -label {Exit}

#  # build widget .quit
#  button .quit \
#    -command {CleanExit} \
#    -text {Quit}

  # pack master .
  pack configure .view \
    -expand 1 \
    -fill both
#  pack configure .quit \
#    -fill x

  if {"[info procs XFEdit]" != ""} {
    catch "XFMiscBindWidgetTree ."
    after 2 "catch {XFEditSetShowWindows}"
  }

  .view create image 0 0 -anchor nw -image viscam -tag image
  CabSignalLamp .view top      -x 670 -y  20 -size 100
  CabSignalLamp .view uppermid -x 670 -y 140 -size 100
  CabSignalLamp .view lowermid -x 670 -y 260 -size 100
  CabSignalLamp .view bottom   -x 670 -y 380 -size 100
  SetCabSignalLampColor top green
  SetCabSignalLampColor uppermid red
  SetCabSignalLampColor lowermid red
  SetCabSignalLampColor bottom red
  bind .view <1> {.view.menu post %X %Y}
  DialInstrument .view spedo -x 20 -y 500 -size 80 -label {Speed} 
#  DigitalInstrument .view spedo -x 20 -y 500 -size 50 -label {Speed} 
  DialInstrument .view airpres -x 150 -y 500 -size 80 \
		-maxValue 200 -secondPointerP 1 -digitalP 0 \
		-label {Air Pressure}
  SetDialInstrumentValue airpres 180 0
  AnalogClock .view clock -x 280 -y 500 -size 80 -label {Clock}
#  DigitalClock .view clock -x 280 -y 500 -size 50 -label {Clock}
  DialInstrument .view oil -x 410 -y 500 -size 80 -label {Oil Pressure} \
  	-maxValue 80 -digitalP 0
  DialInstrument .view temp -x 540 -y 500 -size 80 -label {Temp} \
  	-maxValue 220 -minValue 80 -digitalP 0
  

  wm withdraw .
  update idletasks
  set x [expr {[winfo screenwidth .]/2 - [winfo reqwidth .]/2 \
	  - [winfo vrootx .]}]
  set y [expr {[winfo screenheight .]/2 - [winfo reqheight .]/2 \
	  - [winfo vrooty .]}]
  wm geom . +$x+$y
  wm deiconify .
}

proc GetImage {} {
  global URL File
  if {[catch [list open $File w] fp]} {
    puts stderr "open $File w failed: $fp"
    return
  }
  set tok [::http::geturl "$URL"  -channel $fp \
		-headers {Authorization {Basic dmlzY2FtOnZpc2NhbQ==}}]
  close $fp
  if {[catch [list viscam read $File -format jpeg] error]} {
    puts stderr "viscam read failed: $error"
    return
  }
  catch [list file delete -force $File]
  set result [::http::status $tok]
  ::http::cleanup $tok
  return $result
}

image create photo viscam -height 480 -width 640

global SpeedCount AirCount AirIncr
set SpeedCount 0
set AirCount 180
set AirIncr -10

proc GetOneImage {} {
   global AfterId SpeedCount AirCount AirIncr
   GetImage
#   incr SpeedCount 5
#   incr AirCount $AirIncr
#   if {$SpeedCount > 100} {set SpeedCount 0}
#   if {$AirCount == 0} {set AirIncr 10}
#   if {$AirCount == 180} {set AirIncr -10}
#   SetDialInstrumentValue spedo $SpeedCount
#   SetDigitalInstrumentValue spedo $SpeedCount
#   SetDialInstrumentValue airpres $AirCount [expr 180 - $AirCount]
   set hm [clock format [clock scan now] -format {%I %M}]
   set h [lindex $hm 0]
   set m [lindex $hm 1]
   if {[string compare [string index $h 0] {0}] == 0} {set h [string range $h 1 1]}
   if {[string compare [string index $m 0] {0}] == 0} {set m [string range $m 1 1]}
   SetAnalogClockTime clock $h $m
#   SetDigitalClockTime clock $h $m
   set AfterId [after 125 GetOneImage]
}

global URL File
set URL "http://viscam.cs.umass.edu/cgi-bin/image640x480.jpg"
set File [file join /usr/tmp [pid].jpg]

proc CleanExit {} {
  global File
  catch [list file delete -force $File]
  exit
}

proc ChangeResolution {} {
  global URL NewResolution GetResolution

  regexp {cgi-bin/image([0-9]*)x([0-9]*)\.jpg$} "$URL" whole x y
  set currentRes ${x}x${y}
  set NewResolution $currentRes
  

# .getResolution
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.3 (Tcl/Tk/XF)
# Tk version: 8.3
# XF version: 4.0
#

  # build widget .getResolution
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .getResolution"
  } {
    catch "destroy .getResolution"
  }
  toplevel .getResolution 

  # Window manager configurations
  wm positionfrom .getResolution ""
  wm sizefrom .getResolution ""
  wm maxsize .getResolution 1265 994
  wm minsize .getResolution 1 1
  wm protocol .getResolution WM_DELETE_WINDOW {.getResolution.buttons.button7 invoke}
  wm title .getResolution {Select a Resolution}
  wm transient .getResolution .


  # build widget .getResolution.label1
  label .getResolution.label1 \
    -font {Helvetica -24 bold} \
    -text {Select Resolution}

  # build widget .getResolution.resolution
  frame .getResolution.resolution \
    -borderwidth {2} \
    -relief {ridge}

  # build widget .getResolution.resolution.radiobutton3
  radiobutton .getResolution.resolution.radiobutton3 \
    -relief {raised} \
    -text {640x480} \
    -value {640x480} \
    -variable {NewResolution}

  # build widget .getResolution.resolution.radiobutton4
  radiobutton .getResolution.resolution.radiobutton4 \
    -relief {raised} \
    -text {320x240} \
    -value {320x240} \
    -variable {NewResolution}

  # build widget .getResolution.buttons
  frame .getResolution.buttons \
    -borderwidth {2}

  # build widget .getResolution.buttons.button6
  button .getResolution.buttons.button6 \
    -command {global GetResolution;set GetResolution 1} \
    -text {OK}

  # build widget .getResolution.buttons.button7
  button .getResolution.buttons.button7 \
    -command {global GetResolution;set GetResolution 0} \
    -text {Cancel}

  # pack master .getResolution.resolution
  pack configure .getResolution.resolution.radiobutton3 \
    -expand 1 \
    -side left
  pack configure .getResolution.resolution.radiobutton4 \
    -expand 1 \
    -side right

  # pack master .getResolution.buttons
  pack configure .getResolution.buttons.button6 \
    -expand 1 \
    -side left
  pack configure .getResolution.buttons.button7 \
    -expand 1 \
    -side right

  # pack master .getResolution
  pack configure .getResolution.label1 \
    -fill x
  pack configure .getResolution.resolution \
    -expand 1 \
    -fill both
  pack configure .getResolution.buttons \
    -fill x
# end of widget tree

  set w .getResolution
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx [winfo parent $w]]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty [winfo parent $w]]}]
  wm geom $w +$x+$y
  wm deiconify $w

  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {[string compare $oldGrab ""]} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  focus $w

  set GetResolution -1
  tkwait variable GetResolution

  catch {focus $oldFocus}
  catch {
    # It's possible that the window has already been destroyed,
    # hence this "catch".  Delete the Destroy handler so that
    # tkPriv(button) doesn't get reset by it.

    bind $w <Destroy> {}
    destroy $w
  }
  if {[string compare $oldGrab ""]} {
    if {[string compare $grabStatus "global"]} {
      grab $oldGrab
    } else {
      grab -global $oldGrab
    }
  }

  if {$GetResolution > 0 && 
      [string compare "$NewResolution" "$currentRes"] != 0} {
    regsub "$currentRes" "$URL" "$NewResolution" URL
    .view delete image
    image delete viscam
    regexp {cgi-bin/image([0-9]*)x([0-9]*)\.jpg$} "$URL" whole x y
    image create photo viscam -height $y -width $x
    .view create image 0 0 -anchor nw -image viscam -tag image
  }
}    

global AfterId
set AfterId {}

proc PauseResume {} {
  global AfterId
  if {[string compare "$AfterId" {}] == 0} {
    .view.menu entryconfigure {Resume} -label {Pause}
    GetOneImage
  } else {
    catch {after cancel $AfterId}
    set AfterId {}
    .view.menu entryconfigure {Pause} -label {Resume}
  }
}

MainWindow

GetOneImage
