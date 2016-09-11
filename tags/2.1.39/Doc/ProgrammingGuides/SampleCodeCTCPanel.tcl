#* 
#* ------------------------------------------------------------------
#* SampleCodeCTCPanel.tcl - Sample code -- CTC Panel
#* Created by Robert Heller on Sat Oct 13 13:53:51 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

package require CTCPanel 2.0;#	Include CTCPanel V2.0

namespace eval SampleCode::CTCPanel {}
  # Procedure bound to the switch plate commands.
  proc SampleCode::CTCPanel::SetSwitchSP1 {state} {
    variable CTCPanel
    # Just move the switch's points.
    $CTCPanel setv IndustrySwitch $state
    # And set the indicators.
    switch $state {
      Normal {
	$CTCPanel seti SP1Switch N on
	$CTCPanel seti SP1Switch R off
      }
      Reverse {
	$CTCPanel seti SP1Switch R on
	$CTCPanel seti SP1Switch N off
      }
    }
  }
  # Procedure bound to the signal plate commands
  proc SampleCode::CTCPanel::SetSignalSP1 {state} {
    variable CTCPanel
    # Set the signal indicator lamps.
    switch $state {
      Left {
	$CTCPanel seti SP1Signal L on
	$CTCPanel seti SP1Signal R off
	$CTCPanel seti SP1Signal C off
      }
      Right {
	$CTCPanel seti SP1Signal L off
	$CTCPanel seti SP1Signal R on
	$CTCPanel seti SP1Signal C off
      }
      Center {
	$CTCPanel seti SP1Signal L off
	$CTCPanel seti SP1Signal R off
	$CTCPanel seti SP1Signal C on
      }
    }
  }
  # Procedure bound to the code button
  proc SampleCode::CTCPanel::CodeSP1 {} {
    variable CTCPanel
    # Check if the switch is occupied 
    # (and fetch any state feedback).
    if {[$CTCPanel invoke IndustrySwitch]} {
      # Switch is occupied: controls are disabled.
      $CTCPanel setv SP1Signal Center
      $CTCPanel invoke SP1Signal
      return false
    } else {
      # If the switch is not occupied, invoke 
      # the switch and signal plates.
      $CTCPanel invoke SP1Switch
      $CTCPanel invoke SP1Signal
      return true
    }
  }
  # procedure to show the CTC Panel.
  proc SampleCode::CTCPanel::ShowCTCPanel {} {
    variable CTCPanelTL
    wm deiconify $CTCPanelTL
  }

proc SampleCode::CTCPanel::SampleCodeCTCPanel {} {
  
  $::SampleCode::Main menu add view command \
		-label CTCPanel \
		-command ::SampleCode::CTCPanel::ShowCTCPanel

  # Create the CTC Panel on a new, transient toplevel.
  # Toplevel where Sample CTCPanel lives
  variable CTCPanelTL ${::SampleCode::Main}.ctcPanelTop
  toplevel $CTCPanelTL
  wm withdraw $CTCPanelTL
  wm transient $CTCPanelTL [winfo toplevel ${::SampleCode::Main}]
  wm title $CTCPanelTL "Sample CTC Panel"
  wm protocol $CTCPanelTL WM_DELETE_WINDOW "wm withdraw $CTCPanelTL"
  # Create a main window
  set panelMain [MainFrame ${CTCPanelTL}.main]
  # With a toolbar
  set panelToolbar [$panelMain addtoolbar]
  # Close button
  pack [ttk::button $panelToolbar.close \
		-image CloseButtonImage \
		-command "wm withdraw $CTCPanelTL"] \
	-side  right
  pack $panelMain -fill both -expand yes
  # Create a CTC Panel
  variable CTCPanel [::CTCPanel::CTCPanel \
			[$panelMain getframe].panel \
			-width 400]
  pack $CTCPanel -fill both -expand yes

  # Populate the CTC Panel:

  # Control Point Block14:
  # Just a block of the main line to the west.
  $CTCPanel create StraightBlock MainWest \
		-x1 10 -x2 150 -y1 50 -y2 50 \
		-controlpoint Block14 \
		-label "Block 14" -position above

  # Control Point SP1:
  # The Switch itself.
  $CTCPanel create Switch IndustrySwitch \
		-x 150 -y 50 -controlpoint SP1 \
		-label "SP1"

  # The Switch Plate
  $CTCPanel create SWPlate SP1Switch \
	-x 150 -y 75 -controlpoint SP1 \
	-label "SP1" \
	-normalcommand \
	"::SampleCode::CTCPanel::SetSwitchSP1 Normal" \
	-reversecommand \
	"::SampleCode::CTCPanel::SetSwitchSP1 Reverse"

  # The signal plate
  $CTCPanel create SIGPlate SP1Signal -x 150 -y 150 \
	-controlpoint SP1 \
	-label "SP1" \
	-leftcommand \
	    "::SampleCode::CTCPanel::SetSignalSP1 Left" \
	-rightcommand \
	    "::SampleCode::CTCPanel::SetSignalSP1 Right" \
	-centercommand \
	    "::SampleCode::CTCPanel::SetSignalSP1 Center"
  
  # The code button
  $CTCPanel create CodeButton SP1Code -x 250 -y 150 \
	-controlpoint SP1 \
	-command "::SampleCode::CTCPanel::CodeSP1"

  # A label for the control point
  $CTCPanel create CTCLabel SP1Label -x 200 -y 200 \
	-controlpoint SP1 -label "SP1"

  # Initialize the control point
  ::SampleCode::CTCPanel::CodeSP1

  # Control Point Block15:
  # Just a block of the main line east.
  set me1 [$CTCPanel coords IndustrySwitch Main]
  set mex1 [lindex $me1 0]
  set mey  [lindex $me1 1]
  set mex2 [expr {$mex1 + 150}]
  $CTCPanel create StraightBlock MainEast \
		-x1 $mex1 -x2 $mex2 -y1 $mey -y2 $mey -controlpoint Block15 \
		-label "Block 15"  -position above


  # Control Point Spur1:
  # An industrial spur.
  set is1 [$CTCPanel coords IndustrySwitch Divergence]
  set isx1 [lindex $is1 0]
  set isy  [lindex $is1 1]
  set isx2 [expr {$isx1 + 150}]
  $CTCPanel create StraightBlock IndustrySpur \
		-x1 $isx1 -x2 $isx2 -y1 $isy -y2 $isy \
		-controlpoint Spur1 -label "Spur 1"

}

package provide SampleCodeCTCPanel 1.0
