#* 
#* ------------------------------------------------------------------
#* SampleCodeInstrumentPanel.tcl - Sample Instrument Panel
#* Created by Robert Heller on Wed Nov 28 15:35:30 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/11/30 13:56:50  heller
#* Modification History: Novemeber 30, 2007 lockdown.
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

package require Instruments 2.0

namespace eval SampleCode {
}
proc SampleCode::ToggleInstrumentPanelSlide {} {
    variable InstrumentPanelSlideState
    variable Main
    $Main slideout $InstrumentPanelSlideState instrumentPanel
}
proc SampleCode::UpdateRTClock {} {
    variable Clock
    scan [::clock format [::clock scan now] -format %R] \
	 {%2d:%2d} hour minute
    $Clock settime $hour  $minute
    after 60000 SampleCode::UpdateRTClock
}
proc SampleCode::UpdateFastClock {} {
    variable fastHours
    variable fastMinutes
    variable realMillisecsPerFastMinute
    variable FastClock
    incr fastMinutes
    if {$fastMinutes > 59} {
      incr fastHours
      set fastMinutes 0
      if {$fastHours > 12} {
	set fastHours 1
      }
    }
    $FastClock settime $fastHours $fastMinutes
    after $realMillisecsPerFastMinute SampleCode::UpdateFastClock
}

proc SampleCode::SampleCodeInstrumentPanel {} {
  variable Main
  variable InstrumentPanelSlide [$Main slideout add instrumentPanel]
  variable InstrumentPanelSlideState hide
  $Main menu add view checkbutton -label "Instrument Panel" \
	-variable ::SampleCode::InstrumentPanelSlideState \
	-onvalue show -offvalue hide \
	-command ::SampleCode::ToggleInstrumentPanelSlide
  set sw [ScrolledWindow $InstrumentPanelSlide.sw \
		-scrollbar both -auto both]
  pack $sw -expand yes -fill both
  variable InstrumentPanelCanvas [canvas $sw.canvas \
					-width 200 \
					-height 500 \
					-borderwidth 0 \
					-relief flat \
					-background white]
  $sw setwidget $InstrumentPanelCanvas

  variable Voltmeter [Instruments::DialInstrument \
	create volts \
	$InstrumentPanelCanvas  -x 5 -y 5 -size 90 \
	-maxvalue 20 -label "Track Volts" \
	-scaleticksinterval 1]

  variable Ampmeter [Instruments::DialInstrument \
	create amps \
	$InstrumentPanelCanvas  -x 105 -y 5 -size 90 \
	-maxvalue 10 -label "Track Amps" \
	-scaleticksinterval 1]

  variable Clock [Instruments::AnalogClock \
	create clock $InstrumentPanelCanvas \
		-x 5 -y 125 -size 90 \
		-label {Real Time}]
  
  variable FastClock [Instruments::AnalogClock \
	create fastclock $InstrumentPanelCanvas \
		-x 105 -y 125 -size 90 \
		-label {Fast Clock}]

  UpdateRTClock
  variable fastHours 12
  variable fastMinutes 0
  variable FTFactor 8
  variable realMillisecsPerFastMinute [expr {(60*1000)/$FTFactor}]
  UpdateFastClock  
}

package provide SampleCodeInstrumentPanel 1.0
