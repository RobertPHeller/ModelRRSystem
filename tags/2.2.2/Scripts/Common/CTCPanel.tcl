#* 
#* ------------------------------------------------------------------
#* CTCPanel.tcl - CTC Panel code
#* Created by Robert Heller on Mon Mar 29 18:53:46 2004
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.12  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.11  2004/07/04 11:06:01  heller
#* Modification History: Minor update
#* Modification History:
#* Modification History: Revision 1.10  2004/06/26 13:30:40  heller
#* Modification History: Partial documentation done
#* Modification History:
#* Modification History: Revision 1.9  2004/06/06 13:59:07  heller
#* Modification History: Added code to install target.
#* Modification History: Added documentation.
#* Modification History:
#* Modification History: Revision 1.8  2004/04/27 21:59:14  heller
#* Modification History: Started with documentation.
#* Modification History:
#* Modification History: Revision 1.7  2004/04/24 21:52:22  heller
#* Modification History: Updated CurvedBlock:
#* Modification History:   Range checking, misc. other changes.
#* Modification History: Updated ThreeWaySW:
#* Modification History:   Fixed Left and Right tags.
#* Modification History:
#* Modification History: Revision 1.6  2004/04/22 23:22:39  heller
#* Modification History: Finn's code for CurvedBlock
#* Modification History:
#* Modification History: Revision 1.5  2004/04/20 14:18:36  heller
#* Modification History: Added Yards.
#* Modification History:
#* Modification History: Revision 1.3  2004/04/19 21:39:19  heller
#* Modification History: Additional trackwork elements.
#* Modification History:
#* Modification History: Revision 1.2  2004/04/18 02:29:42  heller
#* Modification History: Added slip switches.
#* Modification History:
#* Modification History: Revision 1.1  2004/04/14 23:10:17  heller
#* Modification History: Added CTC panel graphics and logic
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
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

#@Chapter:CTCPanel.tcl -- CTC Panel code
#@Label:CTCPanel.tcl
#$Id$
# This is the original version and uses the older (funkier) tclParseConfigSpec
# option handling mechanism.  New code should NOT be using this code.  Look
# at the V2 package, which uses snit to implement the various gadgets as
# snit types.


package require grsupport 1.0

namespace eval CTCPanel {
# The CTC Panel code is contained in this namespace.
# [index] CTCPanel!namespace|(

  namespace export CTCPanel
# Exported megawidget function. See ?proc:CTCPanel? for this procedure's 
# documentation.

  namespace export ZoomBy 
# Exported zoom function. See ?proc:ZoomBy? for this procedure's 
# documentation.

  namespace export SetZoom
# Exported set zoom function. See ?proc:SetZoom? for this procedure's 
# documentation.

  namespace export GetZoom
# Exported get zoom function. See ?proc:GetZoom? for this procedure's 
# documentation.

  namespace export SWPlate 
# Exported switch plate function. See ?proc:SWPlate? for this procedure's 
# documentation.

  namespace export SIGPlate 
# Exported signal plate function. See ?proc:SIGPlate? for this procedure's 
# documentation.

  namespace export CodeButton
# Exported code button function. See ?proc:CodeButton? for this procedure's 
# documentation.

  namespace export Toggle 
# Exported toggle switch function. See ?proc:Toggle? for this procedure's 
# documentation.

  namespace export Lamp 
# Exported lamp function. See ?proc:Lamp? for this procedure's 
# documentation.

  namespace export CTCLabel
# Exported CTC label function. See ?proc:CTCLabel? for this procedure's 
# documentation.

  namespace export getv 
# Exported get value function. See ?proc:getv? for this procedure's 
# documentation.

  namespace export setv 
# Exported set value function. See ?proc:setv? for this procedure's 
# documentation.

  namespace export cget 
# Exported cget function. See ?proc:cget? for this procedure's 
# documentation.

  namespace export configure 
# Exported configure function. See ?proc:configure? for this procedure's 
# documentation.

  namespace export exists 
# Exported existance test function. See ?proc:exists? for this procedure's 
# documentation.

  namespace export destroy 
# Exported destroy function. See ?proc:destroy? for this procedure's 
# documentation.

  namespace export move 
# Exported move function. See ?proc:move? for this procedure's 
# documentation.

  namespace export seti 
# Exported set indicator function. See ?proc:seti? for this procedure's 
# documentation.

  namespace export geti 
# Exported get indicator function. See ?proc:geti? for this procedure's 
# documentation.

  namespace export class 
# Exported class function. See ?proc:class? for this procedure's 
# documentation.

  namespace export invoke 
# Exported invoke function. See ?proc:invoke? for this procedure's 
# documentation.

  namespace export coords
# Exported coordinates function. See ?proc:coords? for this procedure's 
# documentation.

  namespace export Switch 
# Exported plain switch function. See ?proc:Switch? for this procedure's 
# documentation.

  namespace export ScissorCrossover 
# Exported scissor crossover function. See ?proc:ScissorCrossover? for this procedure's 
# documentation.

  namespace export Crossing 
# Exported crossing function. See ?proc:Crossing? for this procedure's 
# documentation.

  namespace export SingleSlip 
# Exported single slip function. See ?proc:SingleSlip? for this procedure's 
# documentation.

  namespace export DoubleSlip 
# Exported double slip function. See ?proc:DoubleSlip? for this procedure's 
# documentation.

  namespace export ThreeWaySW 
# Exported three way switch function. See ?proc:ThreeWaySW? for this procedure's 
# documentation.

  namespace export StraightBlock 
# Exported straight block function. See ?proc:StraightBlock? for this procedure's 
# documentation.

  namespace export CurvedBlock 
# Exported curved block function. See ?proc:CurvedBlock? for this procedure's 
# documentation.

  namespace export HiddenBlock 
# Exported hidden block function. See ?proc:HiddenBlock? for this procedure's 
# documentation.

  namespace export StubYard 
# Exported stub yard function. See ?proc:StubYard? for this procedure's 
# documentation.

  namespace export ThroughYard 
# Exported through yard function. See ?proc:ThroughYard? for this procedure's 
# documentation.

  namespace export SchLabel
# Exported schematic label function. See ?proc:SchLabel? for this procedure's 
# documentation.


  variable CTCPanel_Specs
# [index] CTCPanel Control Objects!variables|(
# This variable contains the specs for a CTCPanel.  Used in 
# CTCPanel::CTCPanel_Config (?proc:CTCPanel_Config?) to process configuration
# of CTCPanels.
# [index] CTCPanel::CTCPanel_Specs!variable
  set CTCPanel_Specs {
    {-width width Width 768 tclVerifyInteger}
    {-height height Height 532 tclVerifyInteger}
    {-schematicbackground schematicBackground SchematicBackground black}
    {-controlbackground controlBackground ControlBackground darkgreen}
  }

  variable PlatePolygon
# This variable contains the polygon coords used by CTCPanel::SWPlate_Create 
# (?proc:SWPlate_Create?) and TCPanel::SIGPlate_Create (?proc:SIGPlate_Create?)
# to draw CTC Panel switch plates.
# [index] CTCPanel::PlatePolygon!variable
  set PlatePolygon {
      -32  -32 
      -11   0 
      -7    6 
      -3    8 
       0   11
       3    8
       7    6
       11   0
      32    -32
      14    -36
      12    -44
     -12    -44
     -14    -36
   }

  variable LeverPolygonC 
# This variable contains the polygon coords used by CTCPanel::AddLever 
# (?proc:AddLever?) to add a centrally positioned level to a (signal)
# switch plate.
# [index] CTCPanel::LeverPolygonC!variable
  variable LeverPolygonR 
# This variable contains the polygon coords used by CTCPanel::AddLever 
# (?proc:AddLever?) to add a right positioned level to a switch plate.
# [index] CTCPanel::LeverPolygonR!variable
  variable LeverPolygonL
# This variable contains the polygon coords used by CTCPanel::AddLever 
# (?proc:AddLever?) to add a left positioned level to a switch plate.
# [index] CTCPanel::LeverPolygonL!variable
  set LeverPolygonC {
      0   -24
     -5   -18
     -6     0
     -4     4
      0     6
      4     4
      6     0
      5   -18
   }
   set LeverPolygonL {
    -16   -20
    -16   -12
     -6     0
     -4     4
      0     6
      4     4
      6     0
      4    -4
     -7   -18
   }
   set LeverPolygonR {
     16   -20
     16   -12
      6     0
      4     4
      0     6
     -4     4
     -6     0
     -4    -4
      7   -18
   }

  variable SWPlate_Specs
# This variable contains the specs for Switch Plates.  It is used by 
# SWPlate_Create (?proc:SWPlate_Create?) to process configuration of
# SWPlate objects.
# [index] CTCPanel::SWPlate_Specs!variable
  variable SWPlate_Switches
# This variable contains the switches for Switch Plates.  It is used by the
# cget (?proc:cget?) method of Switch Plate to fetch configuration values 
# from Switch Plates.
# [index] CTCPanel::SWPlate_Switches!variable
  variable SWPlate_UCSpecs
# This variable contains the specs for Switch Plates.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# SWPlate objects.
# [index] CTCPanel::SWPlate_UCSpecs!variable

  set SWPlate_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {CP1}}
    {-normalcommand {}}
    {-reversecommand {}}
  }
  set SWPlate_Switches {-x -y -label -controlpoint -normalcommand 
			-reversecommand}
  set SWPlate_UCSpecs {
    {-label      {1}}
    {-normalcommand {}}
    {-reversecommand {}}
  }

  variable SIGPlate_Specs 
# This variable contains the specs for Signal Plates.  It is used by 
# SIGPlate_Create (?proc:SIGPlate_Create?) to process configuration of
# SIGPlate objects.
# [index] CTCPanel::SWPlate_Specs!variable
  variable SIGPlate_Switches 
# This variable contains the switches for Signal Plates.  It is used by the
# cget (?proc:cget?) method of Signal Plate to fetch configuration values 
# from Signal Plates.
# [index] CTCPanel::SIGPlate_Switches!variable
  variable SIGPlate_UCSpecs
# This variable contains the specs for Signal Plates.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# SIGPlate objects.
# [index] CTCPanel::SIGPlate_UCSpecs!variable

  set SIGPlate_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {2}}
    {-controlpoint {CP1}}
    {-leftcommand {}}
    {-centercommand {}}
    {-rightcommand {}}
  }
  set SIGPlate_Switches {-x -y -label -controlpoint -normalcommand 
			 -centercommand -reversecommand}
  set SIGPlate_UCSpecs {
    {-label      {2}}
    {-leftcommand {}}
    {-centercommand {}}
    {-rightcommand {}}
  }
  variable CodeButton_Specs 
# This variable contains the specs for Code Buttons.  It is used by 
# CodeButton_Create (?proc:CodeButton_Create?) to process configuration of
# CodeButton objects.
# [index] CTCPanel::CodeButton_Specs!variable
  variable CodeButton_Switches 
# This variable contains the switches for Code Buttons.  It is used by the
# cget (?proc:cget?) method of Code Button to fetch configuration values 
# from Code Buttons.
# [index] CTCPanel::CodeButton_Switches!variable
  variable CodeButton_UCSpecs
# This variable contains the specs for Code Buttons.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# CodeButton objects.
# [index] CTCPanel::CodeButton_UCSpecs!variable

  set CodeButton_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-controlpoint {CP1}}
    {-command {}}
  }
  set CodeButton_Switches {-x -y -controlpoint -command}
  set CodeButton_UCSpecs {
    {-command {}}
  }
  
  variable Toggle_Specs 
# This variable contains the specs for Toggle switches.  It is used by 
# Toggle_Create (?proc:Toggle_Create?) to process configuration of
# Toggle objects.
# [index] CTCPanel::Toggle_Specs!variable
  variable Toggle_Switches 
# This variable contains the switches for Toggle switches.  It is used by the
# cget (?proc:cget?) method of Toggle to fetch configuration values 
# from Toggle switches.
# [index] CTCPanel::Toggle_Switches!variable
  variable Toggle_UCSpecs
# This variable contains the specs for Toggle switches.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# Toggle objects.
# [index] CTCPanel::Toggle_UCSpecs!variable

  set Toggle_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-controlpoint {CP1}}
    {-orientation horizontal VerifyOrientationHV}
    {-leftlabel on}
    {-rightlabel off}
    {-centerlabel off}
    {-hascenter 0 VerifyBool}
    {-leftcommand {}}
    {-rightcommand {}}
    {-centercommand {}}
  }
  set Toggle_Switches {-x -y -controlpoint -orientation -leftlabel -rightlabel
		       -centerlabel -hascenter -leftcommand -rightcommand 
		       -centercommand}
  set Toggle_UCSpecs {
    {-leftlabel off}
    {-rightlabel on}
    {-centerlabel off}
    {-leftcommand {}}
    {-rightcommand {}}
    {-centercommand {}}
  }
  variable Lamp_Specs 
# This variable contains the specs for Lamps.  It is used by 
# Lamp_Create (?proc:Lamp_Create?) to process configuration of
# Lamp objects.
# [index] CTCPanel::Lamp_Specs!variable
  variable Lamp_Switches 
# This variable contains the switches for Lamps.  It is used by the
# cget (?proc:cget?) method of Lamp to fetch configuration values 
# from Lamp switches.
# [index] CTCPanel::Lamp_Switches!variable
  variable Lamp_UCSpecs
# This variable contains the specs for Lamps.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# Lamp objects.
# [index] CTCPanel::Lamp_UCSpecs!variable

  set Lamp_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-controlpoint {CP1}}
    {-color white VerifyColor}
    {-label lamp}
  }
  set Lamp_Switches {-x -y -controlpoint -color -label}
  set Lamp_UCSpecs {
    {-color white VerifyColor}
    {-label lamp}
  }

  variable CTCLabel_Specs 
# This variable contains the specs for Control Panel Labels.  It is used by 
# CTCLabel_Create (?proc:CTCLabel_Create?) to process configuration of
# CTCLabel objects.
# [index] CTCPanel::CTCLabel_Specs!variable
  variable CTCLabel_Switches 
# This variable contains the switches for Control Panel Labels.  It is used by the
# cget (?proc:cget?) method of CTCLabel to fetch configuration values 
# from CTCLabel switches.
# [index] CTCPanel::CTCLabel_Switches!variable
  variable CTCLabel_UCSpec
# This variable contains the specs for Control Panel Labels.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# CTCLabel objects.
# [index] CTCPanel::CTCLabel_UCSpecs!variable
# [index] CTCPanel Control Objects!variables|)

  set CTCLabel_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-controlpoint {CP1}}
    {-color white VerifyColor}
    {-label {}}
  }
  set CTCLabel_Switches {-x -y -controlpoint -color -label}
  set CTCLabel_UCSpecs {
    {-color white VerifyColor}
    {-label {}}
  }

  variable Switch_Specs 
# [index] CTCPanel Schematic Trackwork Objects!variables|(
# This variable contains the specs for Switchs.  It is used by 
# Switch_Create (?proc:Switch_Create?) to process configuration of
# Switch objects.
# [index] CTCPanel::Switch_Specs!variable
  variable Switch_Switches 
# This variable contains the switches for Switchs.  It is used by the
# cget (?proc:cget?) method of Switch to fetch configuration values 
# from Switch switches.
# [index] CTCPanel::Switch_Switches!variable
  variable Switch_UCSpecs
# This variable contains the specs for Switchs.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# Switch objects.
# [index] CTCPanel::Switch_UCSpecs!variable

  set Switch_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {CP1}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-statecommand {}}
    {-occupiedcommand {}}
  }
  set Switch_Switches {-x -y -label -controlpoint -orientation -flipped\
		       -occupiedcommand -statecommand}
  set Switch_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
    {-statecommand {}}
  }

  variable ScissorCrossover_Specs 
# This variable contains the specs for Scissor Crossovers.  It is used by 
# ScissorCrossover_Create (?proc:ScissorCrossover_Create?) to process configuration of
# ScissorCrossover objects.
# [index] CTCPanel::ScissorCrossover_Specs!variable
  variable ScissorCrossover_Switches 
# This variable contains the switches for Scissor Crossovers.  It is used by the
# cget (?proc:cget?) method of ScissorCrossover to fetch configuration values 
# from ScissorCrossover switches.
# [index] CTCPanel::ScissorCrossover_Switches!variable
  variable ScissorCrossover_UCSpecs
# This variable contains the specs for ScissorCrossovers.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# ScissorCrossover objects.
# [index] CTCPanel::ScissorCrossover_UCSpecs!variable

  set ScissorCrossover_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {CP1}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-statecommand {}}
    {-occupiedcommand {}}
  }
  set ScissorCrossover_Switches {-x -y -label -controlpoint -orientation \
				 -flipped -occupiedcommand -statecommand}
  set ScissorCrossover_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
    {-statecommand {}}
  }

  variable StraightBlock_Specs 
# This variable contains the specs for Straight Blocks.  It is used by 
# StraightBlock_Create (?proc:StraightBlock_Create?) to process configuration of
# StraightBlock objects.
# [index] CTCPanel::StraightBlock_Specs!variable
  variable StraightBlock_Switches 
# This variable contains the switches for Straight Blocks.  It is used by the
# cget (?proc:cget?) method of StraightBlock to fetch configuration values 
# from StraightBlock switches.
# [index] CTCPanel::StraightBlock_Switches!variable
  variable StraightBlock_UCSpec
# This variable contains the specs for StraightBlocks.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# StraightBlock objects.
# [index] CTCPanel::StraightBlock_UCSpecs!variable

  set StraightBlock_Specs {
    {-x1          0 VerifyDouble}
    {-y1          0 VerifyDouble}
    {-x2          0 VerifyDouble}
    {-y2          0 VerifyDouble}
    {-controlpoint {MainLine}}
    {-label      {}}
    {-position   below CTCPanel::VerifyPosition}
    {-occupiedcommand {}}
  }
  set StraightBlock_Switches {-x1 -y1 -x2 -y2 -controlpoint -label 
			      -occupiedcommand -position}
  set StraightBlock_UCSpecs {
    {-label      {}}
    {-occupiedcommand {}}
  }

  variable CurvedBlock_Specs 
# This variable contains the specs for Curved Blocks.  It is used by 
# CurvedBlock_Create (?proc:CurvedBlock_Create?) to process configuration of
# CurvedBlock objects.
# [index] CTCPanel::CurvedBlock_Specs!variable
  variable CurvedBlock_Switches 
# This variable contains the switches for Curved Blocks.  It is used by the
# cget (?proc:cget?) method of CurvedBlock to fetch configuration values 
# from CurvedBlock switches.
# [index] CTCPanel::CurvedBlock_Switches!variable
  variable CurvedBlock_UCSpec
# This variable contains the specs for CurvedBlocks.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# CurvedBlock objects.
# [index] CTCPanel::CurvedBlock_UCSpecs!variable

  set CurvedBlock_Specs {
    {-x1          0 VerifyDouble}
    {-y1          0 VerifyDouble}
    {-x2          0 VerifyDouble}
    {-y2          0 VerifyDouble}
    {-radius     10 VerifyDouble}
    {-controlpoint {MainLine}}
    {-label      {}}
    {-position   below CTCPanel::VerifyPosition}
    {-occupiedcommand {}}
  }
  set CurvedBlock_Switches {-x1 -y1 -x2 -y2 -radius 
			    -controlpoint -label -occupiedcommand -position}
  set CurvedBlock_UCSpecs {
    {-label      {}}
    {-occupiedcommand {}}
  }

  variable HiddenBlock_Specs 
# This variable contains the specs for Hidden Blocks.  It is used by 
# HiddenBlock_Create (?proc:HiddenBlock_Create?) to process configuration of
# HiddenBlock objects.
# [index] CTCPanel::HiddenBlock_Specs!variable
  variable HiddenBlock_Switches 
# This variable contains the switches for Hidden Blocks.  It is used by the
# cget (?proc:cget?) method of HiddenBlock to fetch configuration values 
# from HiddenBlock switches.
# [index] CTCPanel::HiddenBlock_Switches!variable
  variable HiddenBlock_UCSpec
# This variable contains the specs for HiddenBlocks.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# HiddenBlock objects.
# [index] CTCPanel::HiddenBlock_UCSpecs!variable

  set HiddenBlock_Specs {
    {-x1          0 VerifyDouble}
    {-y1          0 VerifyDouble}
    {-x2          0 VerifyDouble}
    {-y2          0 VerifyDouble}
    {-bridgeorientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-controlpoint {MainLine}}
    {-label      {}}
    {-position   below CTCPanel::VerifyPosition}
    {-occupiedcommand {}}
  }
  set HiddenBlock_Switches {-x1 -y1 -x2 -y2 -controlpoint -label 
			    -flipped -bridgeorientation -occupiedcommand 
			    -position}
  set HiddenBlock_UCSpecs {
    {-label      {}}
    {-occupiedcommand {}}
  }

  variable Crossing_Specs 
# This variable contains the specs for Crossings.  It is used by 
# Crossing_Create (?proc:Crossing_Create?) to process configuration of
# Crossing objects.
# [index] CTCPanel::Crossing_Specs!variable
  variable Crossing_Switches 
# This variable contains the switches for Crossings.  It is used by the
# cget (?proc:cget?) method of Crossing to fetch configuration values 
# from Crossing switches.
# [index] CTCPanel::Crossing_Switches!variable
  variable Crossing_UCSpecs
# This variable contains the specs for Crossings.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# Crossing objects.
# [index] CTCPanel::Crossing_UCSpecs!variable

  set Crossing_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {CP1}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-type	  x90 CTCPanel::VerifyCrossingType}
    {-flipped    0 VerifyBool}
    {-occupiedcommand {}}
  }
  set Crossing_Switches {-x -y -label -controlpoint -orientation -flipped\
		       -occupiedcommand -type}
  set Crossing_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
  }

  variable StubYard_Specs 
# This variable contains the specs for Stub Yards.  It is used by 
# StubYard_Create (?proc:StubYard_Create?) to process configuration of
# StubYard objects.
# [index] CTCPanel::StubYard_Specs!variable
  variable StubYard_Switches 
# This variable contains the switches for Stub Yards.  It is used by the
# cget (?proc:cget?) method of StubYard to fetch configuration values 
# from StubYard switches.
# [index] CTCPanel::StubYard_Switches!variable
  variable StubYard_UCSpecs
# This variable contains the specs for Stub Yards.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# StubYard objects.
# [index] CTCPanel::StubYard_UCSpecs!variable

  set StubYard_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {Yard}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-position   below CTCPanel::VerifyPosition}
    {-occupiedcommand {}}
  }
  set StubYard_Switches {-x -y -label -controlpoint -orientation -flipped\
		       -occupiedcommand -position}
  set StubYard_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
  }
 
  variable StubYard_Poly
# This variable contains the polygon points for a stub yard.  Used by 
# StubYard_Create (?proc:StubYard_Create?) to draw a stub yard.
# [index] CTCPanel::StubYard_Poly!variable
  set StubYard_Poly {
     20   0
     40  20
     60  20
     60 -20
     40 -20
  }

  variable ThroughYard_Specs 
# This variable contains the specs for Through Yards.  It is used by 
# ThroughYard_Create (?proc:ThroughYard_Create?) to process configuration of
# ThroughYard objects.
# [index] CTCPanel::ThroughYard_Specs!variable
  variable ThroughYard_Switches 
# This variable contains the switches for Through Yards.  It is used by the
# cget (?proc:cget?) method of ThroughYard to fetch configuration values 
# from ThroughYard switches.
# [index] CTCPanel::ThroughYard_Switches!variable
  variable ThroughYard_UCSpecs
# This variable contains the specs for Through Yards.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# ThroughYard objects.
# [index] CTCPanel::ThroughYard_UCSpecs!variable

  set ThroughYard_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {Yard}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-occupiedcommand {}}
    {-position   below CTCPanel::VerifyPosition}
  }
  set ThroughYard_Switches {-x -y -label -controlpoint -orientation -flipped\
		       -occupiedcommand -position}
  set ThroughYard_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
  }

  variable ThroughYard_Poly
# This variable contains the polygon points for a through yard.  Used by 
# ThroughYard_Create (?proc:ThroughYard_Create?) to draw a stub yard.
# [index] CTCPanel::ThroughYard_Poly!variable
  set ThroughYard_Poly {
     20   0
     40  20
     60  20
     80   0
     60 -20
     40 -20
  }

  variable SingleSlip_Specs 
# This variable contains the specs for Single Slips.  It is used by 
# SingleSlip_Create (?proc:SingleSlip_Create?) to process configuration of
# SingleSlip objects.
# [index] CTCPanel::SingleSlip_Specs!variable
  variable SingleSlip_Switches 
# This variable contains the switches for Single Slips.  It is used by the
# cget (?proc:cget?) method of SingleSlip to fetch configuration values 
# from SingleSlip switches.
# [index] CTCPanel::SingleSlip_Switches!variable
  variable SingleSlip_UCSpecs
# This variable contains the specs for Single Slips.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# SingleSlip objects.
# [index] CTCPanel::SingleSlip_UCSpecs!variable

  set SingleSlip_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {CP1}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-statecommand {}}
    {-occupiedcommand {}}
  }
  set SingleSlip_Switches {-x -y -label -controlpoint -orientation -flipped\
		       -occupiedcommand -statecommand}
  set SingleSlip_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
    {-statecommand {}}
  }

  variable DoubleSlip_Specs 
# This variable contains the specs for Double Slips.  It is used by 
# DoubleSlip_Create (?proc:DoubleSlip_Create?) to process configuration of
# DoubleSlip objects.
# [index] CTCPanel::DoubleSlip_Specs!variable
  variable DoubleSlip_Switches 
# This variable contains the switches for Double Slips.  It is used by the
# cget (?proc:cget?) method of DoubleSlip to fetch configuration values 
# from DoubleSlip switches.
# [index] CTCPanel::DoubleSlip_Switches!variable
  variable DoubleSlip_UCSpecs
# This variable contains the specs for Double Slips.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# DoubleSlip objects.
# [index] CTCPanel::DoubleSlip_UCSpecs!variable

  set DoubleSlip_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {CP1}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-statecommand {}}
    {-occupiedcommand {}}
  }
  set DoubleSlip_Switches {-x -y -label -controlpoint -orientation -flipped\
		       -occupiedcommand -statecommand}
  set DoubleSlip_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
    {-statecommand {}}
  }

  variable ThreeWaySW_Specs 
# This variable contains the specs for Three Way Switches.  It is used by 
# ThreeWaySW_Create (?proc:ThreeWaySW_Create?) to process configuration of
# ThreeWaySW objects.
# [index] CTCPanel::ThreeWaySW_Specs!variable
  variable ThreeWaySW_Switches 
# This variable contains the switches for Three Way Switches.  It is used by the
# cget (?proc:cget?) method of ThreeWaySW to fetch configuration values 
# from ThreeWaySW switches.
# [index] CTCPanel::ThreeWaySW_Switches!variable
  variable ThreeWaySW_UCSpecs
# This variable contains the specs for Three Way Switches.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# ThreeWaySW objects.
# [index] CTCPanel::ThreeWaySW_UCSpecs!variable

  set ThreeWaySW_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-label      {1}}
    {-controlpoint {CP1}}
    {-orientation 0 CTCPanel::VerifyOrientation8}
    {-flipped    0 VerifyBool}
    {-statecommand {}}
    {-occupiedcommand {}}
  }
  set ThreeWaySW_Switches {-x -y -label -controlpoint -orientation -flipped\
		       -occupiedcommand -statecommand}
  set ThreeWaySW_UCSpecs {
    {-label      {1}}
    {-occupiedcommand {}}
    {-statecommand {}}
  }

  variable SchLabel_Specs 
# This variable contains the specs for Schematic Labels.  It is used by 
# SchLabel_Create (?proc:SchLabel_Create?) to process configuration of
# SchLabel objects.
# [index] CTCPanel::SchLabel_Specs!variable
  variable SchLabel_Switches 
# This variable contains the switches for Schematic Labels.  It is used by the
# cget (?proc:cget?) method of SchLabel to fetch configuration values 
# from SchLabel switches.
# [index] CTCPanel::SchLabel_Switches!variable
  variable SchLabel_UCSpec
# This variable contains the specs for Schematic Labels.  It is used by 
# the configure (?proc:configure?) to process reconfiguration of
# SchLabel objects.
# [index] CTCPanel::SchLabel_UCSpecs!variable
# [index] CTCPanel Schematic Trackwork Objects!variables|)

  set SchLabel_Specs {
    {-x          0 VerifyDouble}
    {-y          0 VerifyDouble}
    {-controlpoint {CP1}}
    {-color white VerifyColor}
    {-label {}}
  }
  set SchLabel_Switches {-x -y -controlpoint -color -label}
  set SchLabel_UCSpecs {
    {-color white VerifyColor}
    {-label {}}
  }

  variable PI
# This variable contains the constant pi.
# [index] CTCPanel::PI!variable

  set PI2 [expr asin(1.0)]
#  puts stderr "*** PI2 = $PI2"
  set PI [expr $PI2 * 2.0]
#  puts stderr "*** PI = $PI"

  set dtheta [expr acos(-1) / 4.0]
  variable RotateAngles
# This variable contains the eight orientation multipliers.
# [index] CTCPanel::RotateAngles!variable
# [index] CTCPanel!namespace|)
  array set RotateAngles [list \
    0 [list [expr cos(0)] [expr sin(0)]] \
    1 [list [expr cos(1.0*$dtheta)] [expr sin(1.0*$dtheta)]] \
    2 [list [expr cos(2.0*$dtheta)] [expr sin(2.0*$dtheta)]] \
    3 [list [expr cos(3.0*$dtheta)] [expr sin(3.0*$dtheta)]] \
    4 [list [expr cos(4.0*$dtheta)] [expr sin(4.0*$dtheta)]] \
    5 [list [expr cos(5.0*$dtheta)] [expr sin(5.0*$dtheta)]] \
    6 [list [expr cos(6.0*$dtheta)] [expr sin(6.0*$dtheta)]] \
    7 [list [expr cos(7.0*$dtheta)] [expr sin(7.0*$dtheta)]] \
  ]


}

proc CTCPanel::VerifyOrientation8 {x} {
# [label] proc:VerifyOrientation8
# This procedure verifies its argument is one of the array indexes for the
# array RotateAngles.
# [index] CTCPanel::VerifyOrientation8!procedure

  variable RotateAngles
  if {[lsearch -exact [array names RotateAngles] $x] < 0} {
    error "Orientation out of range: must be [tclListValidFlags RotateAngles]"
  }
}

proc CTCPanel::VerifyPosition {x} {
# [label] proc:VerifyPosition
# This procedure verifies its argument is a valid position name.
# [index] CTCPanel::VerifyPosition!procedure

  array set pos {above {} below {} left {} right {}}
  if {[lsearch -exact {above below left right} $x] < 0} {
    error "Position out of range: must be [tclListValidFlags pos]"
  }
}

proc CTCPanel::VerifyCrossingType {x} {
# [label] proc:VerifyCrossingType
# This procedure verifies its argument is a valid crossing type.
# [index] CTCPanel::VerifyCrossingType!procedure

  array set type {x90 {} x45 {}}
  if {[lsearch -exact {x90 x45} $x] < 0} {
    error "Type out of range: must be [tclListValidFlags type]"
  }
}

proc CTCPanel::CTCPanel {w args} {
# [label] proc:CTCPanel
# This procedure creates a CTCPanel megawidget named w.
# <in> w -- The widget path of the new CTCPanel megawidget.
# <in> args -- The various parameter settinging for the CTCPanel megawidget.
# [index] CTCPanel::CTCPanel!procedure

  global $w
  upvar #0 $w data

  CTCPanel_Config $w $args
  CTCPanel_Create $w
}

proc CTCPanel::CTCPanel_Config {w argList} {
# [label] proc:CTCPanel_Config
# This procedure processes the configuration for a CTCPanel megawidget.
# <in> w -- The widget path of the new CTCPanel megawidget.
# <in> aargList -- The various parameter settinging for the CTCPanel megawidget.
# [index] CTCPanel::CTCPanel_Config!procedure

  upvar #0 $w data
  variable CTCPanel_Specs

  tclParseConfigSpec $w $CTCPanel_Specs "" $argList
}

proc CTCPanel::CTCPanel_Create {w} {
# [label] proc:CTCPanel_Create
# This procedure actually creates the elements of the CTCPanel megawidget.
# A CTCPanel megawidget is a frame containing two canvas widgets and three
# scrollbars (one shared horizontal scrollbar and two vertical scrollbars).
# <in> w -- The widget path of the new CTCPanel megawidget.
# [index] CTCPanel::CTCPanel_Create!procedure

  upvar #0 $w data

  set data(scale) 1.0
  set data(CPList) {}

  set canvasHeight [expr int(($data(-height) - 20) / 2)]

  # build widget $w
  frame $w \
    -borderwidth {2}

  # build widget $w.schematic
  frame $w.schematic \
    -borderwidth {2}

  # build widget $w.schematic.schematicDisplay
  canvas $w.schematic.schematicDisplay \
    -background "$data(-schematicbackground)" \
    -height $canvasHeight \
    -width $data(-width) \
    -xscrollcommand [list CTCPanel::CtcMainSyncX $w.schematic.schematicDisplay $w.controls.controlsDisplay $w.middle.xscroll] \
    -yscrollcommand [list $w.schematic.yscroll set] \
    -scrollregion [list 0 0 $data(-width) $canvasHeight]
  bind $w.schematic.schematicDisplay <Configure> {CTCPanel::UpdateSR %W %h %w}

  # build widget $w.schematic.yscroll
  scrollbar $w.schematic.yscroll \
    -command [list $w.schematic.schematicDisplay yview]

  # build widget $w.middle
  frame $w.middle \
    -borderwidth {2}

  # build widget $w.middle.xscroll
  scrollbar $w.middle.xscroll \
    -command [list CTCPanel::CtcMainHScroll2 $w.schematic.schematicDisplay $w.controls.controlsDisplay] \
    -orient {horizontal}

  # build widget $w.middle.filler
  frame $w.middle.filler \
    -borderwidth {2} \
    -height {20} \
    -width {20}

  # build widget $w.controls
  frame $w.controls \
    -borderwidth {2}

  # build widget $w.controls.controlsDisplay
  canvas $w.controls.controlsDisplay \
    -background "$data(-controlbackground)" \
    -height $canvasHeight \
    -width $data(-width) \
    -xscrollcommand [list CTCPanel::CtcMainSyncX $w.controls.controlsDisplay $w.schematic.schematicDisplay $w.middle.xscroll] \
    -yscrollcommand [list $w.controls.yscroll set] \
    -scrollregion [list 0 0 $data(-width) $canvasHeight]
  bind $w.controls.controlsDisplay <Configure> {CTCPanel::UpdateSR %W %h %w}

  # build widget $w.controls.yscroll
  scrollbar $w.controls.yscroll \
    -command [list $w.controls.controlsDisplay yview]

  # pack master $w.schematic
  pack configure $w.schematic.schematicDisplay \
    -expand 1 \
    -fill both \
    -side left
  pack configure $w.schematic.yscroll \
    -expand 1 \
    -fill y

  # pack master $w.middle
  pack configure $w.middle.xscroll \
    -expand 1 \
    -fill x \
    -side left
  pack configure $w.middle.filler \
    -side right

  # pack master $w.controls
  pack configure $w.controls.controlsDisplay \
    -expand 1 \
    -fill both \
    -side left
  pack configure $w.controls.yscroll \
    -expand 1 \
    -fill y

  # pack master $w
  pack configure $w.schematic \
    -expand 1 \
    -fill both
  pack configure $w.middle \
    -fill x
  pack configure $w.controls \
    -expand 1 \
    -fill both

}

proc CTCPanel::CtcMainHScroll2 {c1 c2 args} {
# [label] proc:CtcMainHScroll2
# This procedure is bound to the shared horizontal scrollbar.  Moving this
# scrollbar updates both canvas widgets at the same time.
# <in> c1 -- one of the canvas widgets.
# <in> c2 -- the other canvas widget.
# <in> args -- additional arguments.
# [index] CTCPanel::CtcMainHScroll2!procedure

  eval [concat $c1 xview $args]
  eval [concat $c2 xview $args]
}

proc CTCPanel::CtcMainSyncX {this other xbar first last} {
# [label] proc:CtcMainSyncX
# This procedure is syncronizes the scroll regions of the two canvas widgets,
# updating the shared scrollbar if necessary.  Bound to the xscrollcommand of
# both canvas widgets.
# <in> this -- this canvas widget.
# <in> other -- the other canvas widget.
# <in> xbar -- the scrollbar.
# <in> first -- left side scrolled off fraction.
# <in> last -- right side visible fraction.
# [index] CTCPanel::CtcMainSyncX!procedure

#  puts stderr "*** CtcMainSyncX $this $other $xbar $first $last"
  set thisSR [$this cget -scrollregion]
  if {[llength $thisSR] == 0} {
    update idle
    $this configure -scrollregion [list 0 0 [winfo width $this] [winfo height $this]]
    set thisSR [$this cget -scrollregion]
  }
  set thisSRWidth [expr [lindex $thisSR 2] - [lindex $thisSR 0]]
#  puts stderr "*** CtcMainSyncX: thisSRWidth = $thisSRWidth"
  set otherSR [$other cget -scrollregion]
  if {[llength $otherSR] == 0} {
    update idle
    $other configure -scrollregion [list 0 0 [winfo width $other] [winfo height $other]]
    set otherSR [$other cget -scrollregion]
  }
  set otherSRWidth [expr [lindex $otherSR 2] - [lindex $otherSR 0]]
#  puts stderr "*** CtcMainSyncX: otherSRWidth = $otherSRWidth"
  set vfraction [expr $last - $first]
#  puts stderr "*** CtcMainSyncX: vfraction = $vfraction"
  set thisVSR [expr double($vfraction) * $thisSRWidth]
  set otherVSR [expr double($vfraction) * $otherSRWidth]
#  puts stderr "*** CtcMainSyncX: thisVSR = $thisVSR, otherVSR = $otherVSR"
  if {[expr abs($thisVSR - $otherVSR)] > .0006} {
    set gfract [expr $thisVSR / $otherVSR]
    set otherLeft [lindex $otherSR 0]
    set otherRight [expr $otherLeft + ($otherSRWidth * $gfract)]
    $other configure -scrollregion [list $otherLeft [lindex $otherSR 1] \
					 $otherRight [lindex $otherSR 3]]
  }
  $other xview moveto [lindex [$this xview] 0]
  $xbar set $first $last
}

proc CTCPanel::UpdateSR {canvas newheight newwidth} {
# [label] proc:UpdateSR
# This procedure updates the scrollregion for canvas.  Bound to the configure
# event and also called when something is drawn on canvas.
# <in> canvas -- canvas to update.
# <in> newheight -- the canvas's new height.
# <in> newwidth -- the canvas's new width.
# [index] CTCPanel::UpdateSR!procedure

#  puts stderr "*** ==============================================="
#  puts stderr "*** CTCPanel::UpdateSR $canvas $newheight $newwidth"
  set newSR 0
  set curSR [$canvas cget -scrollregion]
#  puts stderr "*** CTCPanel::UpdateSR: (init) curSR = $curSR"
#  set allelts  [$canvas find withtag {!All_CPs}]
#  set elts {}
#  foreach el $allelts {
#    if {[lsearch -glob [$canvas gettags $el] *_outline] < 0} {
#      lappend elts $el
#    }
#  }
#  foreach e $elts {
#    puts stderr "*** CTCPanel::UpdateSR: \[$canvas gettags $e\] = [$canvas gettags $e]"
#  }
#  if {[llength $elts] == 0} {
#    set bbox [list 0 0 0 0]
#  } else {
#    set bbox  [eval [concat $canvas bbox $elts]]
#  }
  set bbox  [$canvas bbox all]
#  puts stderr "*** CTCPanel::UpdateSR: bbox = $bbox"
  
  if {[lindex $bbox 2] != [lindex $curSR 2]} {
    set curSR [lreplace $curSR 2 2 [lindex $bbox 2]]
    set newSR 1
  }
  if {[lindex $curSR 2] < $newwidth} {
    set curSR [lreplace $curSR 2 2 $newwidth]
    set newSR 1
  } 

  if {[lindex $bbox 3] != [lindex $curSR 3]} {
    set curSR [lreplace $curSR 3 3 [lindex $bbox 3]]
    set newSR 1
  }
  if {[lindex $curSR 3] < $newheight} {
    set curSR [lreplace $curSR 3 3 $newheight]
    set newSR 1
  }

#  puts stderr "*** CTCPanel::UpdateSR: newSR = $newSR"
#  puts stderr "*** CTCPanel::UpdateSR: (updated) curSR = $curSR"
  if {$newSR} {
    $canvas configure -scrollregion $curSR
    foreach cpbox [$canvas find withtag All_CPs] {
      set bbox [$canvas bbox $cpbox]
      set bbox [lreplace $bbox 1 1 [lindex $curSR 1]]
      set bbox [lreplace $bbox 3 3 [lindex $curSR 3]]
      $canvas coords $cpbox $bbox
    }
  }
#  puts stderr "*** ==============================================="
}

proc CTCPanel::SWPlate {ctcpanel n args} {
# [label] proc:SWPlate
# [index] CTCPanel Control Objects!procs|(
# This procedure configures and creates a switch control plate.  These lever
# plates are used to set the state of track switches.
# <in> ctcpanel -- the CTC Pannel the switch plate is to be on.
# <in> n -- the symbolic name of the switch plate.
# <in> args -- optional configuration arguments.
# [index] CTCPanel::SWPlate!procedure

  set name ${ctcpanel}_cp_${n}
  upvar #0 $name data
  SWPlate_Config $ctcpanel $name $args
  SWPlate_Create $name
  return $name
}

proc CTCPanel::SWPlate_Config {ctcpanel name argList} {
# [label] proc:SWPlate_Config
# This procedure configures a new switch control plate.
# <in> ctcpanel -- the CTC Pannel the switch plate is to be on.
# <in> name -- the symbolic name of the switch plate.
# <in> argList -- optional configuration arguments.
# [index] CTCPanel::SWPlate_Config!procedure

  upvar #0 $name data
  variable SWPlate_Specs
  set canvas $ctcpanel.controls.controlsDisplay

  canvasItemParseConfigSpec $name $SWPlate_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(lever) none
  set data(centerAllowed) 0
  set data(class) SWPlate
  set data(getv) SWPlate_getv
  set data(setv) SWPlate_setv
  set data(geti) SWPlate_geti
  set data(seti) SWPlate_seti
  set data(cget) SWPlate_cget
  set data(configure) SWPlate_configure
  set data(destroy) SWPlate_destroy
  set data(move) SWPlate_move
  set data(invoke) SWPlate_invoke
}

proc CTCPanel::SWPlate_getv {name} {
# [label] proc:SWPlate_getv
# This procedure gets the value of a switch control plate.
# <in> name -- the symbolic name of the switch plate.
# [index] CTCPanel::SWPlate_getv!procedure

  upvar #0 $name data
  switch -exact -- $data(lever) {
    Left {return Normal}
    Right {return Reverse}
    default {return {}}
  }
}

proc CTCPanel::SWPlate_invoke {name} {
# [label] proc:SWPlate_invoke
# This procedure invokes the command of a switch control plate.
# <in> name -- the symbolic name of the switch plate.
# [index] CTCPanel::SWPlate_invoke!procedure

  upvar #0 $name data

#  puts stderr "*** CTCPanel::SWPlate_invoke $name"

#  puts stderr "*** -: data(lever) = $data(lever)"
  switch -exact -- $data(lever) {
    Left {set script "$data(-normalcommand)"}
    Right {set script "$data(-reversecommand)"}
    default {set script {}}
  }
#  puts stderr "*** -: script = '$script'"
  if {[string length "$script"] > 0} {
    uplevel #0 "$script"
  }
} 

proc CTCPanel::SWPlate_geti {name ind} {
# [label] proc:SWPlate_geti
# This procedure gets the indicator state of a switch control plate.
# <in> name -- the symbolic name of the switch plate.
# [index] CTCPanel::SWPlate_geti!procedure

  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  switch -exact -- $ind {
    N {
	if {[string equal [$canvas itemcget ${tag}_NInd -fill] {black}]} {
	  return 0
	} else {
	  return 1
	}
    }
    R {
	if {[string equal [$canvas itemcget ${tag}_RInd -fill] {black}]} {
	  return 0
	} else {
	  return 1
	}
    }
    default {return {}}
  }
}

proc CTCPanel::SWPlate_seti {name ind value} {
# [label] proc:SWPlate_seti
# This procedure sets the indicator state of a switch control plate.
# <in> name -- the symbolic name of the switch plate.
# <in> ind -- the indicator name (N or R).
# <in> value -- the value of the indicator: 1 for on, 0 for off.
# [index] CTCPanel::SWPlate_seti!procedure

  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  switch -exact -- $ind {
    N {
	if {$value} {
	  set color green
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_NInd -fill $color
	return $value
    }
    R {
	if {$value} {
	  set color yellow
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_RInd -fill $color
	return $value
    }
    default {return {}}
  }
}


proc CTCPanel::SWPlate_setv {name state} {
# [label] proc:SWPlate_setv
# This procedure sets the state of a switch control plate.
# <in> name -- the symbolic name of the switch plate.
# <in> state -- the new state of the switch plate.
# [label] proc:SWPlate_setv
  upvar #0 $name data
  switch -exact -- $state {
    N {AddLever $data(ctcpanel) $name Left}
    R {AddLever $data(ctcpanel) $name Right}
  }
}

proc CTCPanel::SWPlate_cget {name switches} {
# [label] proc:SWPlate_cget
  upvar #0 $name data
  variable SWPlate_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $SWPlate_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::SWPlate_configure {name args} {
# [label] proc:SWPlate_configure
  upvar #0 $name data
  variable SWPlate_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $SWPlate_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_label -text $data(-label)
}

proc CTCPanel::SWPlate_destroy {name} {
# [label] proc:SWPlate_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SWPlate_move {name x y} {
# [label] proc:SWPlate_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SWPlate_Create {name} {
# [label] proc:SWPlate_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  variable PlatePolygon

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  $canvas create polygon $PlatePolygon -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
  $canvas create text -24 -32 -text {N} -anchor nw -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
  $canvas create text  24 -32 -text {R} -anchor ne -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
  $canvas create text   0 -30 -text {SWITCH} -anchor n -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp]
  $canvas create text   0 -32 -text $data(-label) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_label]
  $canvas create oval -26 -48 -18 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_NInd $cp]
  $canvas create oval  18 -48  26 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_RInd $cp]
  $canvas move   $tag $x $y
  $canvas create line $x $y $x $y -tag [list $tag ${tag}_xy $cp]
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  AddLever $data(ctcpanel) $name Left
  $canvas bind $tag <1> [list CTCPanel::MoveLever $name %x]
#  puts stderr "*** CTCPanel::SWPlate_Create: bindings on $canvas $tag: [$canvas bind $tag]"

  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),SwitchPlates) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::CodeButton {ctcpanel n args} {
# [label] proc:CodeButton
  set name ${ctcpanel}_cp_${n}
  upvar #0 $name data
  CodeButton_Config $ctcpanel $name $args
  CodeButton_Create $name
  return $name
}

proc CTCPanel::CodeButton_Config {ctcpanel name argList} {
# [label] proc:CodeButton_Config
  upvar #0 $name data
  variable CodeButton_Specs
  set canvas $ctcpanel.controls.controlsDisplay

  canvasItemParseConfigSpec $name $CodeButton_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) CodeButton
  set data(getv) CodeButton_getv
  set data(setv) CodeButton_setv
  set data(geti) CodeButton_geti
  set data(seti) CodeButton_seti
  set data(cget) CodeButton_cget
  set data(configure) CodeButton_configure
  set data(destroy) CodeButton_destroy
  set data(move) CodeButton_move
  set data(invoke) CodeButton_invoke
}

proc CTCPanel::CodeButton_getv {name} {
# [label] proc:CodeButton_getv
  return {}
}

proc CTCPanel::CodeButton_setv {name state} {
# [label] proc:CodeButton_setv
  return {}
}

proc CTCPanel::CodeButton_geti {name ind} {
# [label] proc:CodeButton_geti
  return {}
}

proc CTCPanel::CodeButton_seti {name ind value} {
# [label] proc:CodeButton_seti
  return {}
}

proc CTCPanel::CodeButton_cget {name switches} {
# [label] proc:CodeButton_cget
  upvar #0 $name data
  variable CodeButton_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $CodeButton_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::CodeButton_configure {name args} {
# [label] proc:CodeButton_configure
  upvar #0 $name data
  variable CodeButton_UCSpecs

#  puts stderr "*** CodeButton_configure $name $args"
  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $CodeButton_UCSpecs "" $args
}

proc CTCPanel::CodeButton_destroy {name} {
# [label] proc:CodeButton_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::CodeButton_move {name x y} {
# [label] proc:CodeButton_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::CodeButton_invoke {name} {
# [label] proc:CodeButton_invoke
  upvar #0 $name data

  set script "$data(-command)"
  if {[string length "$script"] > 0} {
    uplevel #0 "$script"
  }
} 


proc CTCPanel::CodeButton_Create {name} {
# [label] proc:CodeButton_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp ${tag}_Button]
  $canvas create text   0  16 -anchor n -text {Code} -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp]
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  $canvas bind   ${tag}_Button <1> [list CTCPanel::invoke $name]
#  puts stderr "*** CTCPanel::CodeButton_Create: bindings on $canvas $tag: [$canvas bind $tag]"

  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),CodeButtons) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::SIGPlate {ctcpanel n args} {
# [label] proc:SIGPlate
  set name ${ctcpanel}_cp_${n}
  upvar #0 $name data
  SIGPlate_Config $ctcpanel $name $args
  SIGPlate_Create $name
  return $name
}

proc CTCPanel::SIGPlate_Config {ctcpanel name argList} {
# [label] proc:SIGPlate_Config
  upvar #0 $name data
  variable SIGPlate_Specs
  set canvas $ctcpanel.controls.controlsDisplay

  canvasItemParseConfigSpec $name $SIGPlate_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(lever) none
  set data(centerAllowed) 1
  set data(class) SIGPlate
  set data(getv) SIGPlate_getv
  set data(setv) SIGPlate_setv
  set data(geti) SIGPlate_geti
  set data(seti) SIGPlate_seti
  set data(cget) SIGPlate_cget
  set data(configure) SIGPlate_configure
  set data(destroy) SIGPlate_destroy
  set data(move) SIGPlate_move
  set data(invoke) SIGPlate_invoke
}

proc CTCPanel::SIGPlate_getv {name} {
# [label] proc:SIGPlate_getv
  upvar #0 $name data
  switch -exact -- $data(lever) {
    Left {return Left}
    Right {return Right}
    Center {return Center}
    default {return {}}
  }
}

proc CTCPanel::SIGPlate_invoke {name} {
# [label] proc:SIGPlate_invoke
  upvar #0 $name data
  switch -exact -- $data(lever) {
    Left {set script "$data(-leftcommand)"}
    Right {set script "$data(-rightcommand)"}
    Center {set script "$data(-centercommand)"}
    default {set script {}}
  }
  if {[string length "$script"] > 0} {
    uplevel #0 "$script"
  }
} 

proc CTCPanel::SIGPlate_geti {name ind} {
# [label] proc:SIGPlate_geti
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  switch -exact -- $ind {
    L {
	if {[string equal [$canvas itemcget ${tag}_LInd -fill] {black}]} {
	  return 0
	} else {
	  return 1
	}
    }
    C {
	if {[string equal [$canvas itemcget ${tag}_CInd -fill] {black}]} {
	  return 0
	} else {
	  return 1
	}
    }
    R {
	if {[string equal [$canvas itemcget ${tag}_RInd -fill] {black}]} {
	  return 0
	} else {
	  return 1
	}
    }
    default {return {}}
  }
}

proc CTCPanel::SIGPlate_seti {name ind value} {
# [label] proc:SIGPlate_seti
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  switch -exact -- $ind {
    L {
	if {$value} {
	  set color green
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_LInd -fill $color
	return $value
    }
    C {
	if {$value} {
	  set color red
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_CInd -fill $color
	return $value
    }
    R {
	if {$value} {
	  set color green
	} else {
	  set color black
	}
	$canvas itemconfigure ${tag}_RInd -fill $color
	return $value
    }
    default {return {}}
  }
}


proc CTCPanel::SIGPlate_setv {name state} {
# [label] proc:SIGPlate_setv
  upvar #0 $name data
  switch -exact -- $state {
    L {AddLever $data(ctcpanel) $name Left}
    C {AddLever $data(ctcpanel) $name Center}
    R {AddLever $data(ctcpanel) $name Right}
  }
}

proc CTCPanel::SIGPlate_cget {name switches} {
# [label] proc:SIGPlate_cget
  upvar #0 $name data
  variable SIGPlate_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $SIGPlate_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::SIGPlate_configure {name args} {
# [label] proc:SIGPlate_configure
  upvar #0 $name data
  variable SIGPlate_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $SIGPlate_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_label -text $data(-label)
}

proc CTCPanel::SIGPlate_destroy {name} {
# [label] proc:SIGPlate_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SIGPlate_move {name x y} {
# [label] proc:SIGPlate_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SIGPlate_Create {name} {
# [label] proc:SIGPlate_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  variable PlatePolygon

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  $canvas create polygon $PlatePolygon -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
  $canvas create text -24 -32 -text {L} -anchor nw -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
  $canvas create text  24 -32 -text {R} -anchor ne -fill lightgrey -font [list Courier -12 bold] -tag [list $tag $cp]
  $canvas create text   0 -30 -text {SIGNAL} -anchor n -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp]
  $canvas create text   0 -32 -text $data(-label) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_label]
  $canvas create oval -26 -48 -18 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_LInd $cp]
  $canvas create oval  -4 -56   4 -48 -fill black -outline lightgrey -tag [list $tag ${tag}_CInd $cp]
  $canvas create oval  18 -48  26 -40 -fill black -outline lightgrey -tag [list $tag ${tag}_RInd $cp]
  $canvas move   $tag $x $y
  $canvas create line $x $y $x $y -tag [list $tag ${tag}_xy $cp]
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  AddLever $data(ctcpanel) $name Center
  $canvas bind $tag <1> [list CTCPanel::MoveLever $name %x]
#  puts stderr "*** CTCPanel::SIGPlate_Create: bindings on $canvas $tag: [$canvas bind $tag]"

  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),SignalPlates) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}


proc CTCPanel::Toggle {ctcpanel n args} {
# [label] proc:Toggle
  set name ${ctcpanel}_cp_${n}
  upvar #0 $name data
  Toggle_Config $ctcpanel $name $args
  Toggle_Create $name
  return $name
}

proc CTCPanel::Toggle_Config {ctcpanel name argList} {
# [label] proc:Toggle_Config
  upvar #0 $name data
  variable Toggle_Specs
  set canvas $ctcpanel.controls.controlsDisplay

  canvasItemParseConfigSpec $name $Toggle_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(lever) none
  set data(class) Toggle
  set data(getv) Toggle_getv
  set data(setv) Toggle_setv
  set data(geti) Toggle_geti
  set data(seti) Toggle_seti
  set data(cget) Toggle_cget
  set data(configure) Toggle_configure
  set data(destroy) Toggle_destroy
  set data(move) Toggle_move
  set data(invoke) Toggle_invoke
}

proc CTCPanel::Toggle_getv {name} {
# [label] proc:Toggle_getv
  upvar #0 $name data
  switch -exact -- $data(lever) {
    Left {return Left}
    Right {return Right}
    Center {return Center}
    default {return {}}
  }
}

proc CTCPanel::Toggle_setv {name state} {
# [label] proc:Toggle_setv
  upvar #0 $name data
  switch -exact -- $state {
    L {AddTLever $data(ctcpanel) $name Left}
    C {if {$data(-hascenter)} {AddTLever $data(ctcpanel) $name Center}}
    R {AddTLever $data(ctcpanel) $name Right}
  }
}

proc CTCPanel::Toggle_invoke {name} {
# [label] proc:Toggle_invoke
  upvar #0 $name data
  switch -exact -- $data(lever) {
    Left {set script "$data(-leftcommand)"}
    Right {set script "$data(-rightcommand)"}
    Center {set script "$data(-centercommand)"}
    default {set script {}}
  }
  if {[string length "$script"] > 0} {
    uplevel #0 "$script"
  }
} 

proc CTCPanel::Toggle_geti {name ind} {
# [label] proc:Toggle_geti
  return {}
}

proc CTCPanel::Toggle_seti {name ind value} {
# [label] proc:Toggle_seti
  return {}
}

proc CTCPanel::Toggle_cget {name switches} {
# [label] proc:Toggle_cget
  upvar #0 $name data
  variable Toggle_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $Toggle_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::Toggle_configure {name args} {
# [label] proc:Toggle_configure
  upvar #0 $name data
  variable Toggle_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $Toggle_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_leftlabel -text $data(-leftlabel)
  $data(canvas) itemconfigure ${tag}_rightlabel -text $data(-rightlabel)
  if {$data(-hascenter)} {
    $data(canvas) itemconfigure ${tag}_centerlabel -text $data(-centerlabel)
  }
}

proc CTCPanel::Toggle_destroy {name} {
# [label] proc:Toggle_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Toggle_move {name x y} {
# [label] proc:Toggle_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Toggle_Create {name} {
# [label] proc:Toggle_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  switch -exact -- $data(-orientation) {
    horizontal {
      $canvas create rectangle -30 -10 30 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
      $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
      $canvas create text -30 -15 -text $data(-leftlabel) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_leftlabel]
      $canvas create text  30 -15 -text $data(-rightlabel) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_rightlabel]
      if {$data(-hascenter)} {
	$canvas create text  0 -15 -text $data(-centerlabel) -anchor s -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_centerlabel]
      }
    }
    vertical {
      $canvas create rectangle -10 -30 10 30 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
      $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp]
      $canvas create text  15 -30 -text $data(-leftlabel) -anchor w -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_leftlabel]      
      $canvas create text  15  30 -text $data(-rightlabel) -anchor w -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_rightlabel]
      if {$data(-hascenter)} {
	$canvas create text  15  0 -text $data(-centerlabel) -anchor w -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_centerlabel]
      }
    }
  }
  $canvas move   $tag $x $y
  $canvas create line $x $y $x $y -tag [list $tag ${tag}_xy $cp]
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  AddTLever $data(ctcpanel) $name Left
  $canvas bind $tag <1> [list CTCPanel::MoveTLever $name %x %y]
#  puts stderr "*** CTCPanel::Toggle_Create: bindings on $canvas $tag: [$canvas bind $tag]"

  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Toggles) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::AddTLever {ctcpanel name pos} {
# [label] proc:AddTLever
  upvar #0 $name data

  set canvas $data(canvas)
  set tag $name
  set cp $data(-controlpoint)
  set xy [$canvas coords ${tag}_xy]
#  puts stderr "*** CTCPanel::AddTLever xy = '$xy'"
  set x [lindex $xy 0]
  set y [lindex $xy 1]
  upvar #0 $data(ctcpanel) ctcdata

  if {[catch [list set data(lever)] curlever]} {
    error "Can't add lever: not allowed for $name of $ctcpanel"
  }
  if {[string equal $pos Center] && !$data(-hascenter)} {
    error "Can't add center position level: not allowed for $name of $ctcpanel"
  } 

  if {![string equal "$curlever" {none}]} {
    $canvas delete ${name}_Lever
    set data(lever) none
  }
  switch -exact -- $pos {
    Left {
      switch -exact -- $data(-orientation) {
	horizontal {
	  $canvas create oval -35 -5 5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
	}
	vertical {
	  $canvas create oval -5 -35 5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
	}
      }
      $canvas move   ${name}_Lever $x $y
      $canvas scale  ${name}_Lever 0 0 $ctcdata(scale) $ctcdata(scale)
    }
    Right {
      switch -exact -- $data(-orientation) {
	horizontal {
	  $canvas create oval  35 -5 -5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
	}
	vertical {
	  $canvas create oval -5 35 5 -5 -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
	}
      }
      $canvas move   ${name}_Lever $x $y
      $canvas scale  ${name}_Lever 0 0 $ctcdata(scale) $ctcdata(scale)
    }
    Center {
      $canvas create oval -5 -5 5 5 -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
      $canvas move   ${name}_Lever $x $y
      $canvas scale  ${name}_Lever 0 0 $ctcdata(scale) $ctcdata(scale)
    }
  }
  set data(lever) $pos
}

proc CTCPanel::MoveTLever {name mx my} {
# [label] proc:MoveTLever
  upvar #0 $name data

#  puts stderr "*** CTCPanel::MoveTLever $name $mx $my"
  set canvas $data(canvas)
  set tag $name
  set cp $data(-controlpoint)
  set x $data(-x)
  set y $data(-y)
  upvar #0 $data(ctcpanel) ctcdata

  set cx [$canvas canvasx $mx]
  set cy [$canvas canvasx $my]

  if {$data(-hascenter)} {
    set bbox [$canvas bbox ${tag}_centerlabel]
    switch -exact -- $data(-orientation) {
      horizontal {
	if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
	  AddTLever $data(ctcpanel) $name Center
	  return
	}
      }
      vertical {
	if {$cy >= [lindex $bbox 1] && $cy <= [lindex $bbox 3]} {
	  AddTLever $data(ctcpanel) $name Center
	  return
	}
      }
    }
  }
  set bbox [$canvas bbox ${tag}_leftlabel]
  switch -exact -- $data(-orientation) {
    horizontal {
      if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
	AddTLever $data(ctcpanel) $name Left
	return
      }
    }
    vertical {
      if {$cy >= [lindex $bbox 1] && $cy <= [lindex $bbox 3]} {
	AddTLever $data(ctcpanel) $name Left
	return
      }
    }
  }
  set bbox [$canvas bbox ${tag}_rightlabel]
  switch -exact -- $data(-orientation) {
    horizontal {
      if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
	AddTLever $data(ctcpanel) $name Right
	return
      }
    }
    vertical {
      if {$cy >= [lindex $bbox 1] && $cy <= [lindex $bbox 3]} {
	AddTLever $data(ctcpanel) $name Right
	return
      }
    }
  }
}

  
proc CTCPanel::Lamp {ctcpanel n args} {
# [label] proc:Lamp
  set name ${ctcpanel}_cp_${n}
  upvar #0 $name data
  Lamp_Config $ctcpanel $name $args
  Lamp_Create $name
  return $name
}

proc CTCPanel::Lamp_Config {ctcpanel name argList} {
# [label] proc:Lamp_Config
  upvar #0 $name data
  variable Lamp_Specs
  set canvas $ctcpanel.controls.controlsDisplay

  canvasItemParseConfigSpec $name $Lamp_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(state) off
  set data(class) Lamp
  set data(getv) Lamp_getv
  set data(setv) Lamp_setv
  set data(geti) Lamp_geti
  set data(seti) Lamp_seti
  set data(cget) Lamp_cget
  set data(configure) Lamp_configure
  set data(destroy) Lamp_destroy
  set data(move) Lamp_move
  set data(invoke) Lamp_invoke
}
  
proc CTCPanel::Lamp_getv {name} {
# [label] proc:Lamp_getv
  upvar #0 $name data

  return $data(state)
}

proc CTCPanel::Lamp_setv {name state} {
# [label] proc:Lamp_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  switch -exact -- $state {
    on {
      set $data(state) on
      $canvas itemconfigure ${name}_lamp -fill $data(-color)
    }
    default {
      set $data(state) off
      $canvas itemconfigure ${name}_lamp -fill black
    }
  }
}

proc CTCPanel::Lamp_invoke {name} {
# [label] proc:Lamp_invoke
  return {}
}

proc CTCPanel::Lamp_geti {name ind} {
# [label] proc:Lamp_geti
  return {}
}

proc CTCPanel::Lamp_seti {name ind value} {
# [label] proc:Lamp_seti
  return {}
}

proc CTCPanel::Lamp_cget {name switches} {
# [label] proc:Lamp_cget
  upvar #0 $name data
  variable Lamp_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $Lamp_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::Lamp_configure {name args} {
# [label] proc:Lamp_configure
  upvar #0 $name data
  variable Lamp_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $Lamp_UCSpecs "" $args
  set tag $name
  if {[string equal $data(state) on]} {
    $canvas itemconfigure ${name}_lamp -fill $data(-color)
  }
  $canvas itemconfigure ${name}_label -text $data(-label)
}

proc CTCPanel::Lamp_destroy {name} {
# [label] proc:Lamp_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Lamp_move {name x y} {
# [label] proc:Lamp_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Lamp_Create {name} {
# [label] proc:Lamp_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  $canvas create oval -10 -10 10 10 -fill black -outline lightgrey -width 2 -tag [list $tag $cp ${tag}_lamp]
  $canvas create text   0  15 -text $data(-label) -anchor n -fill lightgrey -font [list Courier -8 normal] -tag [list $tag $cp ${tag}_label]
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Lamps) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}


proc CTCPanel::CTCLabel {ctcpanel n args} {
# [label] proc:CTCLabel
  set name ${ctcpanel}_cp_${n}
  upvar #0 $name data
  CTCLabel_Config $ctcpanel $name $args
  CTCLabel_Create $name
  return $name
}

proc CTCPanel::CTCLabel_Config {ctcpanel name argList} {
# [label] proc:CTCLabel_Config
  upvar #0 $name data
  variable CTCLabel_Specs
  set canvas $ctcpanel.controls.controlsDisplay

  canvasItemParseConfigSpec $name $CTCLabel_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) CTCLabel
  set data(getv) CTCLabel_getv
  set data(setv) CTCLabel_setv
  set data(geti) CTCLabel_geti
  set data(seti) CTCLabel_seti
  set data(cget) CTCLabel_cget
  set data(configure) CTCLabel_configure
  set data(destroy) CTCLabel_destroy
  set data(move) CTCLabel_move
  set data(invoke) CTCLabel_invoke
}
  
proc CTCPanel::CTCLabel_getv {name} {
# [label] proc:CTCLabel_getv
  upvar #0 $name data
  return {}
}

proc CTCPanel::CTCLabel_setv {name state} {
# [label] proc:CTCLabel_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  return {}
}

proc CTCPanel::CTCLabel_invoke {name} {
# [label] proc:CTCLabel_invoke
  return {}
}

proc CTCPanel::CTCLabel_geti {name ind} {
# [label] proc:CTCLabel_geti
  return {}
}

proc CTCPanel::CTCLabel_seti {name ind value} {
# [label] proc:CTCLabel_seti
  return {}
}

proc CTCPanel::CTCLabel_cget {name switches} {
# [label] proc:CTCLabel_cget
  upvar #0 $name data
  variable CTCLabel_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $CTCLabel_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::CTCLabel_configure {name args} {
# [label] proc:CTCLabel_configure
  upvar #0 $name data
  variable CTCLabel_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $CTCLabel_UCSpecs "" $args
  set tag $name
  $canvas itemconfigure ${name} -text $data(-label) -fill $data(-color)
}

proc CTCPanel::CTCLabel_destroy {name} {
# [label] proc:CTCLabel_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::CTCLabel_move {name x y} {
# [label] proc:CTCLabel_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::CTCLabel_Create {name} {
# [label] proc:CTCLabel_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  $canvas create text $x $y -text $data(-label) -anchor c -fill $data(-color) -font [list Courier -18 bold] -tag [list $tag $cp]
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),CTCLabels) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}


proc CTCPanel::AddLever {ctcpanel name pos} {
# [label] proc:AddLever
  upvar #0 $name data

  set canvas $data(canvas)
  set tag $name
  set cp $data(-controlpoint)
  set xy [$canvas coords ${tag}_xy]
#  puts stderr "*** CTCPanel::AddLever xy = '$xy'"
  set x [lindex $xy 0]
  set y [lindex $xy 1]
  upvar #0 $data(ctcpanel) ctcdata

  if {[catch [list set data(lever)] curlever]} {
    error "Can't add lever: not allowed for $name of $ctcpanel"
  }
  if {[string equal $pos Center] && !$data(centerAllowed)} {
    error "Can't add center position level: not allowed for $name of $ctcpanel"
  } 

  if {![string equal "$curlever" {none}]} {
    $canvas delete ${name}_Lever
    set data(lever) none
  }
  switch -exact -- $pos {
    Left {
      variable LeverPolygonL
      $canvas create polygon $LeverPolygonL -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
      $canvas move   ${name}_Lever $x $y
      $canvas scale  ${name}_Lever 0 0 $ctcdata(scale) $ctcdata(scale)
    }
    Right {
      variable LeverPolygonR
      $canvas create polygon $LeverPolygonR -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
      $canvas move   ${name}_Lever $x $y
      $canvas scale  ${name}_Lever 0 0 $ctcdata(scale) $ctcdata(scale)
    }
    Center {
      variable LeverPolygonC
      $canvas create polygon $LeverPolygonC -fill lightgrey -outline {} -tag [list $tag $cp ${name}_Lever]
      $canvas move   ${name}_Lever $x $y
      $canvas scale  ${name}_Lever 0 0 $ctcdata(scale) $ctcdata(scale)
    }
  }
  set data(lever) $pos
}

proc CTCPanel::MoveLever {name mx} {
# [label] proc:MoveLever
# [index] CTCPanel Control Objects!procs|)
  upvar #0 $name data

#  puts stderr "*** CTCPanel::MoveLever $name $mx"
  set canvas $data(canvas)
  set tag $name
  set cp $data(-controlpoint)
  set x $data(-x)
  set y $data(-y)
  upvar #0 $data(ctcpanel) ctcdata

  set cx [$canvas canvasx $mx]

  if {$data(centerAllowed)} {
    set bbox [$canvas bbox ${tag}_CInd]
    if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
      AddLever $data(ctcpanel) $name Center
      return
    }
  }
  set bbox [$canvas bbox ${tag}_LInd]
  if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
    AddLever $data(ctcpanel) $name Left
    return
  }
  set bbox [$canvas bbox ${tag}_NInd]
  if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
    AddLever $data(ctcpanel) $name Left
    return
  }
  set bbox [$canvas bbox ${tag}_RInd]
  if {$cx >= [lindex $bbox 0] && $cx <= [lindex $bbox 2]} {
    AddLever $data(ctcpanel) $name Right
    return
  }
}

proc CTCPanel::SchematicDrawLine {canvas x1 y1 x2 y2 flip orientation tags} {
# [index] CTCPanel Schematic Trackwork Objects!procs|(
# [label] proc:SchematicDrawLine
  variable RotateAngles

  if {$flip} {
    set y1 [expr $y1 * -1]
    set y2 [expr $y2 * -1]
  }
  set cos_sin $RotateAngles($orientation)
  set cos [lindex $cos_sin 0]
  set sin [lindex $cos_sin 1]

  set xx1 [expr $x1 * $cos - $y1 * $sin]
  set yy1 [expr $x1 * $sin + $y1 * $cos]
  set xx2 [expr $x2 * $cos - $y2 * $sin]
  set yy2 [expr $x2 * $sin + $y2 * $cos]

  $canvas create line $xx1 $yy1 $xx2 $yy2 -width 4 -fill white -capstyle round -tag "$tags"
}

proc CTCPanel::SchematicDrawPolygon {canvas pointlist flip orientation tags} {
# [label] proc:SchematicDrawPolygon
  variable RotateAngles

  set flipped {}
  if {$flip} {
    foreach {x y} $pointlist {
      lappend flipped $x [expr $y * -1]
    }
  }
  set cos_sin $RotateAngles($orientation)
  set cos [lindex $cos_sin 0]
  set sin [lindex $cos_sin 1]

  set rotated {}
  foreach {x y} $flipped {
    lappend rotated [expr $x * $cos - $y * $sin] [expr $x * $sin + $y * $cos]
  }

  $canvas create polygon $rotated -width 4 -fill white -capstyle round -tag "$tags"
}

proc CTCPanel::SchematicDrawCurve {canvas x1 y1 x2 y2 flip orientation tags} {
# [label] proc:SchematicDrawCurve
  variable RotateAngles

  if {$flip} {
    set orientation [expr ($orientation + 4) % 8]
  }

  switch -exact "$orientation" {
    0 {set start 45}
    1 {set start 90}
    2 {set start 135}
    3 {set start 180}
    4 {set start 225}
    5 {set start 270}
    6 {set start 315}
    7 {set start 0}
  }

  $canvas create arc $x1 $y1 $x2 $y2 -style arc -start $start -extent -90 -width 4 -outline white -tag "$tags"
}

proc CTCPanel::SchematicDrawDot {canvas x1 y1 flip orientation tags} {
# [label] proc:SchematicDrawDot
  variable RotateAngles

  if {$flip} {
    set y1 [expr $y1 * -1]
  }
  set cos_sin $RotateAngles($orientation)
  set cos [lindex $cos_sin 0]
  set sin [lindex $cos_sin 1]

  set xx1 [expr $x1 * $cos - $y1 * $sin]
  set yy1 [expr $x1 * $sin + $y1 * $cos]

  $canvas create line $xx1 $yy1 $xx1 $yy1 -width 1 -fill black -tag "$tags"
}

proc CTCPanel::Switch {ctcpanel n args} {
# [label] proc:Switch
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  Switch_Config $ctcpanel $name $args
  Switch_Create $name
  return $name
}

proc CTCPanel::Switch_Config {ctcpanel name argList} {
# [label] proc:Switch_Config
  upvar #0 $name data
  variable Switch_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $Switch_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(state) normal
  set data(class) Switch
  set data(getv) Switch_getv
  set data(setv) Switch_setv
  set data(geti) Switch_geti
  set data(seti) Switch_seti
  set data(cget) Switch_cget
  set data(configure) Switch_configure
  set data(destroy) Switch_destroy
  set data(move) Switch_move
  set data(invoke) Switch_invoke
}

proc CTCPanel::Switch_Create  {name} {
# [label] proc:Switch_Create 
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  SchematicDrawDot  $canvas 0 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Common $cp]
  SchematicDrawLine $canvas 0 0 20 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 20 0 28 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 20 0 28 8 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]
  $canvas itemconfigure ${tag}_Reverse -fill black
  $canvas raise ${tag}_Normal  ${tag}_Reverse
  $canvas lower ${tag}_Reverse ${tag}_Normal 
  SchematicDrawDot  $canvas 40 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Main $cp]
  SchematicDrawLine $canvas 28 0 40 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 28 8 40 20 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawDot  $canvas 40 20 $data(-flipped) $data(-orientation) [list $tag ${tag}_Divergence $cp]
  set bbox [$canvas bbox ${tag}]
  $canvas create text [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0] \
		      [expr [lindex $bbox 3] + 5] -text $data(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::Switch_getv {name} {
# [label] proc:Switch_getv
  upvar #0 $name data
  return $data(state)
}

proc CTCPanel::Switch_setv {name value} {
# [label] proc:Switch_setv
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  if {[Switch_invoke $name]} {
    set color red
  } else {
    set color white
  }
  switch -exact -- $value {
    Normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill $color
      $canvas raise ${tag}_Normal  ${tag}_Reverse
      $canvas lower ${tag}_Reverse ${tag}_Normal 
      set data(state) normal
      return Normal
    }
    Reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill $color
      $canvas raise ${tag}_Reverse ${tag}_Normal
      $canvas lower ${tag}_Normal  ${tag}_Reverse
      set data(state) reverse
      return Reverse
    }
    Unknown {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas lower ${tag}_Normal
      $canvas lower ${tag}_Reverse
      set data(state) unknown
      return Unknown
    }
  }
  return {}
}

proc CTCPanel::Switch_geti {name ind} {
# [label] proc:Switch_geti
  return {}
}

proc CTCPanel::Switch_seti {name ind value} {
# [label] proc:Switch_seti
  return {}
}

proc CTCPanel::Switch_cget {name switches} { 
# [label] proc:Switch_cget
  upvar #0 $name data
  variable Switch_Switches
  set result {}
  foreach sw $switches { 
    if {[lsearch -exact $Switch_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::Switch_configure {name args} {
# [label] proc:Switch_configure
  upvar #0 $name data
  variable Switch_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $Switch_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_Label -text $data(-label)
}

proc CTCPanel::Switch_destroy {name} {
# [label] proc:Switch_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Switch_move {name x y} {
# [label] proc:Switch_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Switch_invoke {name} {
# [label] proc:Switch_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::Switch_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
#    puts stderr "*** -: $data(-occupiedcommand) returns $isoccupied"
  }
  if {[string length "$data(-statecommand)"] > 0} {
    set newstate [uplevel #0 "$data(-statecommand)"]
#    puts stderr "*** -: $data(-statecommand) returns $newstate"
    if {[lsearch -exact {normal reverse} $newstate] < 0} {set newstate unknown}
    set data(state) $newstate
  }

  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  switch -exact -- $data(state) {
    normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
    }
    reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
    unknown {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
  }
#  puts stderr "*** -: returning $isoccupied"
  return $isoccupied
}

proc CTCPanel::SchLabel {ctcpanel n args} {
# [label] proc:SchLabel
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  SchLabel_Config $ctcpanel $name $args
  SchLabel_Create $name
  return $name
}

proc CTCPanel::SchLabel_Config {ctcpanel name argList} {
# [label] proc:SchLabel_Config
  upvar #0 $name data
  variable SchLabel_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $SchLabel_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) SchLabel
  set data(getv) SchLabel_getv
  set data(setv) SchLabel_setv
  set data(geti) SchLabel_geti
  set data(seti) SchLabel_seti
  set data(cget) SchLabel_cget
  set data(configure) SchLabel_configure
  set data(destroy) SchLabel_destroy
  set data(move) SchLabel_move
  set data(invoke) SchLabel_invoke
}
  
proc CTCPanel::SchLabel_getv {name} {
# [label] proc:SchLabel_getv
  upvar #0 $name data
  return {}
}

proc CTCPanel::SchLabel_setv {name state} {
# [label] proc:SchLabel_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  return {}
}

proc CTCPanel::SchLabel_invoke {name} {
# [label] proc:SchLabel_invoke
  return {}
}

proc CTCPanel::SchLabel_geti {name ind} {
# [label] proc:SchLabel_geti
  return {}
}

proc CTCPanel::SchLabel_seti {name ind value} {
# [label] proc:SchLabel_seti
  return {}
}

proc CTCPanel::SchLabel_cget {name switches} {
# [label] proc:SchLabel_cget
  upvar #0 $name data
  variable SchLabel_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $SchLabel_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::SchLabel_configure {name args} {
# [label] proc:SchLabel_configure
  upvar #0 $name data
  variable SchLabel_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $SchLabel_UCSpecs "" $args
  set tag $name
  $canvas itemconfigure ${name} -text $data(-label) -fill $data(-color)
}

proc CTCPanel::SchLabel_destroy {name} {
# [label] proc:SchLabel_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SchLabel_move {name x y} {
# [label] proc:SchLabel_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SchLabel_Create {name} {
# [label] proc:SchLabel_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  $canvas create text $x $y -text $data(-label) -anchor c -fill $data(-color) -font [list Courier -18 bold] -tag [list $tag $cp]
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),SchLabels) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::StraightBlock {ctcpanel n args} {
# [label] proc:StraightBlock
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  StraightBlock_Config $ctcpanel $name $args
  StraightBlock_Create $name
  return $name
}

proc CTCPanel::StraightBlock_Config {ctcpanel name argList} {
# [label] proc:StraightBlock_Config
  upvar #0 $name data
  variable StraightBlock_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $StraightBlock_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) StraightBlock
  set data(getv) StraightBlock_getv
  set data(setv) StraightBlock_setv
  set data(geti) StraightBlock_geti
  set data(seti) StraightBlock_seti
  set data(cget) StraightBlock_cget
  set data(configure) StraightBlock_configure
  set data(destroy) StraightBlock_destroy
  set data(move) StraightBlock_move
  set data(invoke) StraightBlock_invoke
}

proc CTCPanel::StraightBlock_getv {name} {
# [label] proc:StraightBlock_getv
  upvar #0 $name data
  return {}
}

proc CTCPanel::StraightBlock_setv {name state} {
# [label] proc:StraightBlock_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  return {}
}

proc CTCPanel::StraightBlock_geti {name ind} {
# [label] proc:StraightBlock_geti
  return {}
}

proc CTCPanel::StraightBlock_seti {name ind value} {
# [label] proc:StraightBlock_seti
  return {}
}

proc CTCPanel::StraightBlock_cget {name switches} {
# [label] proc:StraightBlock_cget
  upvar #0 $name data
  variable StraightBlock_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $StraightBlock_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::StraightBlock_configure {name args} {
# [label] proc:StraightBlock_configure
  upvar #0 $name data
  variable StraightBlock_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $StraightBlock_UCSpecs "" $args
  set tag $name
  $canvas itemconfigure ${name}_Label -text $data(-label)
}

proc CTCPanel::StraightBlock_destroy {name} {
# [label] proc:StraightBlock_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::StraightBlock_move {name} {
# [label] proc:StraightBlock_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::StraightBlock_invoke {name} {
# [label] proc:StraightBlock_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::Switch_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  return $isoccupied
}

proc CTCPanel::StraightBlock_Create {name} {
# [label] proc:StraightBlock_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x1 $data(-x1)
  set y1 $data(-y1)
  set x2 $data(-x2)
  set y2 $data(-y2)

  $canvas create line $x1 $y1 $x1 $y1 -width 1 -fill black -tag [list $tag $cp ${tag}_E1]
  $canvas create line $x2 $y2 $x2 $y2 -width 1 -fill black -tag [list $tag $cp ${tag}_E2]
  $canvas create line $x1 $y1 $x2 $y2 -width 4 -fill white -capstyle round -tag [list $tag $cp]
  set bbox [$canvas bbox ${tag}]
  switch -exact -- $data(-position) {
    above {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 1] - 5]
      set at s
    }
    below {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 3] + 5]
      set at n
    }
    left {
      set xt [expr [lindex $bbox 0] - 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at e
    }
    right {
      set xt [expr [lindex $bbox 2] + 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at w
    }
  }

  $canvas create text $xt \
		      $yt  -text $data(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
  
}

proc CTCPanel::CurvedBlock {ctcpanel n args} {
# [label] proc:CurvedBlock
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  CurvedBlock_Config $ctcpanel $name $args
  CurvedBlock_Create $name
  return $name
}

proc CTCPanel::CurvedBlock_Config {ctcpanel name argList} {
# [label] proc:CurvedBlock_Config
  upvar #0 $name data
  variable CurvedBlock_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $CurvedBlock_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) CurvedBlock
  set data(getv) CurvedBlock_getv
  set data(setv) CurvedBlock_setv
  set data(geti) CurvedBlock_geti
  set data(seti) CurvedBlock_seti
  set data(cget) CurvedBlock_cget
  set data(configure) CurvedBlock_configure
  set data(destroy) CurvedBlock_destroy
  set data(move) CurvedBlock_move
  set data(invoke) CurvedBlock_invoke
}

proc CTCPanel::CurvedBlock_getv {name} {
# [label] proc:CurvedBlock_getv
  upvar #0 $name data
  return {}
}

proc CTCPanel::CurvedBlock_setv {name state} {
# [label] proc:CurvedBlock_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  return {}
}

proc CTCPanel::CurvedBlock_geti {name ind} {
# [label] proc:CurvedBlock_geti
  return {}
}

proc CTCPanel::CurvedBlock_seti {name ind value} {
# [label] proc:CurvedBlock_seti
  return {}
}

proc CTCPanel::CurvedBlock_cget {name switches} {
# [label] proc:CurvedBlock_cget
  upvar #0 $name data
  variable CurvedBlock_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $CurvedBlock_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::CurvedBlock_configure {name args} {
# [label] proc:CurvedBlock_configure
  upvar #0 $name data
  variable CurvedBlock_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $CurvedBlock_UCSpecs "" $args
  set tag $name
  $canvas itemconfigure ${name}_Label -text $data(-label)
}

proc CTCPanel::CurvedBlock_destroy {name} {
# [label] proc:CurvedBlock_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::CurvedBlock_move {name} {
# [label] proc:CurvedBlock_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::CurvedBlock_invoke {name} {
# [label] proc:CurvedBlock_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::Switch_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  return $isoccupied
}

proc CTCPanel::square {x} {
# [label] proc:square
  return [expr $x * $x]
}

proc CTCPanel::RadiansToDegrees {rads} {
# [label] proc:RadiansToDegrees
  variable PI
#  puts stderr "*** RadiansToDegrees: PI = $PI"
  return [expr double($rads / $PI) * 180.0]
}

proc CTCPanel::CurvedBlock_Create {name} {
# [label] proc:CurvedBlock_Create
# This procedure creates a curved block.  See @FinnApr04@ for an 
# explaination of the underlying math.
# <in> name -- the name of the object (names the object database).
# [index] CTCPanel::CurvedBlock_Create!procedure


  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x1 $data(-x1);# a
  set y1 $data(-y1);# b
  set x2 $data(-x2);# c
  set y2 $data(-y2);# d
  set radius $data(-radius);# r

  set dx [expr $x2 - $x1]
  set dy [expr $y2 - $y1]
  set l [expr sqrt([square $dx] + [square $dy])]
  if {$l > [expr $radius * 2.0]} {
    error "Range error: radius too small for points: ($x1,$y1) -> ($x2,$y2) = $l > [expr $radius * 2.0]"
  }

  set a $x1
  set b $y1
  set c $x2
  set d $y2
  set r $radius

  set J [expr 2.0*($a-$c)]
  set G [expr 2.0*($b-$d)]
  set T [expr double([square $a]+[square $b]) - \
	      double([square $c]+[square $d])]

  set u [expr (1.0 + ([square $J] / [square $G]))]
  set v [expr (-2.0*$a) - ((2.0*$J*$T)/[square $G]) + ((2.0*$J*$b)/$G)  ]
  set w [expr [square $a]+[square $b] + [square $T]/[square $G] - 2*$b*$T/$G - [square $r]]

  set sqrt [expr sqrt([square $v]-4.0*$u*$w)]

  set m1 [expr (-$v + $sqrt)/(2.0*$u)]
  set n1 [expr ($T-$J*$m1)/$G]

  set m2 [expr (-$v - $sqrt)/(2.0*$u)]
  set n2 [expr ($T-$J*$m2)/$G]

  set at1 [expr atan2($c-$m1,$d-$n1)]
  set at2 [expr atan2($a-$m1,$b-$n1)]



#  set a11 [RadiansToDegrees [expr -atan2($y1-$n1,$x1-$m1)]]
#  set a12 [RadiansToDegrees [expr -atan2($y1-$n2,$x1-$m2)]]
#  set a21 [RadiansToDegrees [expr -atan2($y2-$n1,$x2-$m1)]]
#  set a22 [RadiansToDegrees [expr -atan2($y2-$n2,$x2-$m2)]]
#
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a11 = $a11"
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a12 = $a12"
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a21 = $a21 ([expr $a21 - $a11])"
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a22 = $a22 ([expr $a22 - $a12])"



#  puts stderr "*** CTCPanel::CurvedBlock_Create: at1 = $at1, at2 = $at2"
  set sn [expr sin($at1 - $at2)]
#  puts stderr "*** CTCPanel::CurvedBlock_Create: sn = $sn"

  if {$sn > 0} {
    set m $m1
    set n $n1
  } else {
    set m $m2
    set n $n2
  }

  set xc $m
  set yc $n

  set a1 [RadiansToDegrees [expr -atan2($y1-$yc,$x1-$xc)]]
#  puts stderr "*** CTCPanel::CurvedBlock_Create: a1 = $a1"
  set a2 [RadiansToDegrees [expr -atan2($y2-$yc,$x2-$xc)]]
#  puts stderr "*** CTCPanel::CurvedBlock_Create: (1) a2 = $a2 ([expr $a2 - $a1])"
  if {$a2 < 0} {set a2 [expr $a2 + 360]}
#  puts stderr "*** CTCPanel::CurvedBlock_Create: (2) a2 = $a2 ([expr $a2 - $a1])"


  $canvas create line $x1 $y1 $x1 $y1 -width 1 -fill black -tag [list $tag $cp ${tag}_E1]
  $canvas create line $x2 $y2 $x2 $y2 -width 1 -fill black -tag [list $tag $cp ${tag}_E2]
#  puts stderr "CTCPanel::CurvedBlock_Create: x1 = $x1, y1 = $y1, x2 = $x2, y2 = $y2"
#  puts stderr "CTCPanel::CurvedBlock_Create: xc = $xc, yc = $yc, radius = $radius"
#  puts stderr "CTCPanel::CurvedBlock_Create: a1 = $a1, a2 = $a2"
#  $canvas create line $x1 $y1  $x2 $y2 -width 2 -fill orange  -tag [list $tag $cp ${tag}_L] -arrow last
  $canvas create  arc [expr $xc - $radius] [expr $yc - $radius] \
		      [expr $xc + $radius] [expr $yc + $radius] \
		      -start $a1 -extent [expr $a2 - $a1] \
		 -style arc -width 4 -outline white -tag [list $tag $cp]

  set bbox [$canvas bbox ${tag}]
  switch -exact -- $data(-position) {
    above {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 1] - 5]
      set at s
    }
    below {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 3] + 5]
      set at n
    }
    left {
      set xt [expr [lindex $bbox 0] - 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at e
    }
    right {
      set xt [expr [lindex $bbox 2] + 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at w
    }
  }

  $canvas create text $xt \
		      $yt  -text $data(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
  
}

proc CTCPanel::ScissorCrossover {ctcpanel n args} {
# [label] proc:ScissorCrossover
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  ScissorCrossover_Config $ctcpanel $name $args
  ScissorCrossover_Create $name
  return $name
}

proc CTCPanel::ScissorCrossover_Config {ctcpanel name argList} {
# [label] proc:ScissorCrossover_Config
  upvar #0 $name data
  variable ScissorCrossover_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $ScissorCrossover_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(state) normal
  set data(class) ScissorCrossover
  set data(getv) ScissorCrossover_getv
  set data(setv) ScissorCrossover_setv
  set data(geti) ScissorCrossover_geti
  set data(seti) ScissorCrossover_seti
  set data(cget) ScissorCrossover_cget
  set data(configure) ScissorCrossover_configure
  set data(destroy) ScissorCrossover_destroy
  set data(move) ScissorCrossover_move
  set data(invoke) ScissorCrossover_invoke
}

proc CTCPanel::ScissorCrossover_Create  {name} {
# [label] proc:ScissorCrossover_Create 
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  SchematicDrawDot  $canvas  0  0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Main1L $cp]
  SchematicDrawDot  $canvas  0 20 $data(-flipped) $data(-orientation) [list $tag ${tag}_Mail2L $cp]

  SchematicDrawLine $canvas  0  0 16  0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas  0 20 16 20 $data(-flipped) $data(-orientation) [list $tag $cp]

  SchematicDrawLine $canvas 16  0 26  0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 16  0 26  6 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]

  SchematicDrawLine $canvas 16 20 26 20 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 16 20 26 14 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]

  SchematicDrawLine $canvas 26  0 40  0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 26 20 40 20 $data(-flipped) $data(-orientation) [list $tag $cp]

  SchematicDrawLine $canvas 26  6 40 14 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 26 14 40  6 $data(-flipped) $data(-orientation) [list $tag $cp]

  SchematicDrawLine $canvas 40  0 50  0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 40  6 50  0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]
  SchematicDrawLine $canvas 40 20 50 20 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 40 14 50 20 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]

  SchematicDrawLine $canvas 50  0 66  0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 50 20 66 20 $data(-flipped) $data(-orientation) [list $tag $cp]

  SchematicDrawDot  $canvas 66  0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Main1R $cp]
  SchematicDrawDot  $canvas 66 20 $data(-flipped) $data(-orientation) [list $tag ${tag}_Mail2R $cp]
  $canvas itemconfigure ${tag}_Reverse -fill black
  $canvas raise ${tag}_Normal ${tag}_Reverse
  $canvas lower ${tag}_Reverse ${tag}_Normal
  set bbox [$canvas bbox ${tag}]
  $canvas create text [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0] \
		      [expr [lindex $bbox 3] + 5] -text $data(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::ScissorCrossover_getv {name} {
# [label] proc:ScissorCrossover_getv
  upvar #0 $name data
  return $data(state)
}

proc CTCPanel::ScissorCrossover_setv {name value} {
# [label] proc:ScissorCrossover_setv
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  if {[ScissorCrossover_invoke $name]} {
    set color red
  } else {
    set color white
  }
  switch -exact -- $value {
    Normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill $color
      $canvas raise ${tag}_Normal  ${tag}_Reverse
      $canvas lower ${tag}_Reverse ${tag}_Normal
      set data(state) normal
      return Normal
    }
    Reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill $color
      $canvas raise ${tag}_Reverse ${tag}_Normal
      $canvas lower ${tag}_Normal  ${tag}_Reverse 
      set data(state) reverse
      return Reverse
    }
    Unknown {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas lower ${tag}_Normal
      $canvas lower ${tag}_Reverse
      set data(state) unknown
      return Unknown
    }
  }
  return {}
}

proc CTCPanel::ScissorCrossover_geti {name ind} {
# [label] proc:ScissorCrossover_geti
  return {}
}

proc CTCPanel::ScissorCrossover_seti {name ind value} {
# [label] proc:ScissorCrossover_seti
  return {}
}

proc CTCPanel::ScissorCrossover_cget {name ScissorCrossoveres} { 
# [label] proc:ScissorCrossover_cget
  upvar #0 $name data
  variable ScissorCrossover_ScissorCrossoveres
  set result {}
  foreach sw $ScissorCrossoveres { 
    if {[lsearch -exact $ScissorCrossover_ScissorCrossoveres "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::ScissorCrossover_configure {name args} {
# [label] proc:ScissorCrossover_configure
  upvar #0 $name data
  variable ScissorCrossover_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $ScissorCrossover_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_Label -text $data(-label)
}

proc CTCPanel::ScissorCrossover_destroy {name} {
# [label] proc:ScissorCrossover_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::ScissorCrossover_move {name x y} {
# [label] proc:ScissorCrossover_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::ScissorCrossover_invoke {name} {
# [label] proc:ScissorCrossover_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::ScissorCrossover_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {[string length "$data(-statecommand)"] > 0} {
    set newstate [uplevel #0 "$data(-statecommand)"]
    if {[lsearch -exact {normal reverse} $newstate] < 0} {set newstate unknown}
    set data(state) $newstate
  }

  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  switch -exact -- $data(state) {
    normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
    }
    reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
    unknown {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
  }
  return 0
}

proc CTCPanel::Crossing {ctcpanel n args} {
# [label] proc:Crossing
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  Crossing_Config $ctcpanel $name $args
  Crossing_Create $name
  return $name
}

proc CTCPanel::Crossing_Config {ctcpanel name argList} {
# [label] proc:Crossing_Config
  upvar #0 $name data
  variable Crossing_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $Crossing_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(state) normal
  set data(class) Crossing
  set data(getv) Crossing_getv
  set data(setv) Crossing_setv
  set data(geti) Crossing_geti
  set data(seti) Crossing_seti
  set data(cget) Crossing_cget
  set data(configure) Crossing_configure
  set data(destroy) Crossing_destroy
  set data(move) Crossing_move
  set data(invoke) Crossing_invoke
}

proc CTCPanel::Crossing_Create  {name} {
# [label] proc:Crossing_Create 
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  SchematicDrawDot  $canvas  0 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_MainL $cp]
  SchematicDrawDot  $canvas 40 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_MainR $cp]
  SchematicDrawLine $canvas  0 0 40 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  switch -exact -- $data(-type) {
    x90 {
      SchematicDrawDot  $canvas 20 -20 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltL $cp]
      SchematicDrawDot  $canvas 20  20 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltR $cp]
      SchematicDrawLine $canvas 20 -20 20  20 $data(-flipped) $data(-orientation) [list $tag $cp]
    }
    x45 {
      SchematicDrawDot  $canvas 5.8578643763 -14.1421356237 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltL $cp]
      SchematicDrawDot  $canvas 34.1421356237 14.1421356237 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltR $cp]
      SchematicDrawLine $canvas 5.8578643763 -14.1421356237 34.1421356237 14.1421356237 $data(-flipped) $data(-orientation) [list $tag $cp]
    }
  }

  set bbox [$canvas bbox ${tag}]
  $canvas create text [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0] \
		      [expr [lindex $bbox 3] + 5] -text $data(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::Crossing_getv {name} {
# [label] proc:Crossing_getv
  upvar #0 $name data
  return $data(state)
}

proc CTCPanel::Crossing_setv {name value} {
# [label] proc:Crossing_setv
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  return {}
}

proc CTCPanel::Crossing_geti {name ind} {
# [label] proc:Crossing_geti
  return {}
}

proc CTCPanel::Crossing_seti {name ind value} {
# [label] proc:Crossing_seti
  return {}
}

proc CTCPanel::Crossing_cget {name switches} { 
# [label] proc:Crossing_cget
  upvar #0 $name data
  variable Crossing_Switches
  set result {}
  foreach sw $switches { 
    if {[lsearch -exact $Crossing_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::Crossing_configure {name args} {
# [label] proc:Crossing_configure
  upvar #0 $name data
  variable Crossing_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $Crossing_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_Label -text $data(-label)
}

proc CTCPanel::Crossing_destroy {name} {
# [label] proc:Crossing_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Crossing_move {name x y} {
# [label] proc:Crossing_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::Crossing_invoke {name} {
# [label] proc:Crossing_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::Crossing_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  return 0
}

proc CTCPanel::SingleSlip {ctcpanel n args} {
# [label] proc:SingleSlip
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  SingleSlip_Config $ctcpanel $name $args
  SingleSlip_Create $name
  return $name
}

proc CTCPanel::SingleSlip_Config {ctcpanel name argList} {
# [label] proc:SingleSlip_Config
  upvar #0 $name data
  variable SingleSlip_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $SingleSlip_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(state) normal
  set data(class) SingleSlip
  set data(getv) SingleSlip_getv
  set data(setv) SingleSlip_setv
  set data(geti) SingleSlip_geti
  set data(seti) SingleSlip_seti
  set data(cget) SingleSlip_cget
  set data(configure) SingleSlip_configure
  set data(destroy) SingleSlip_destroy
  set data(move) SingleSlip_move
  set data(invoke) SingleSlip_invoke
}

proc CTCPanel::SingleSlip_Create  {name} {
# [label] proc:SingleSlip_Create 
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  SchematicDrawDot  $canvas  0 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_MainL $cp]
  SchematicDrawDot  $canvas 40 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_MainR $cp]
  SchematicDrawDot  $canvas 5.8578643763 -14.1421356237 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltL $cp]
  SchematicDrawDot  $canvas 34.1421356237 14.1421356237 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltR $cp]
  SchematicDrawLine $canvas  0 0 10 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 30 0 40 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 5.8578643763 -14.142135623 12.92893218815 -7.07106781115000 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 27.07106781255000 7.07106781115000  34.1421356237 14.1421356237 $data(-flipped) $data(-orientation) [list $tag $cp]

  SchematicDrawLine $canvas 10 0 30 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 12.92893218815 -7.07106781115000 27.07106781255000 7.07106781115000 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]

  SchematicDrawLine $canvas 10 0 27.07106781255000 7.07106781115000 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]

  $canvas itemconfigure ${tag}_Reverse -fill black
  $canvas raise ${tag}_Normal  ${tag}_Reverse
  $canvas lower ${tag}_Reverse ${tag}_Normal 

  set bbox [$canvas bbox ${tag}]
  $canvas create text [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0] \
		      [expr [lindex $bbox 3] + 5] -text $data(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::SingleSlip_getv {name} {
# [label] proc:SingleSlip_getv
  upvar #0 $name data
  return $data(state)
}

proc CTCPanel::SingleSlip_setv {name value} {
# [label] proc:SingleSlip_setv
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  if {[Switch_invoke $name]} {
    set color red
  } else {
    set color white
  }
  switch -exact -- $value {
    Normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill $color
      $canvas raise ${tag}_Normal  ${tag}_Reverse
      $canvas lower ${tag}_Reverse ${tag}_Normal 
      set data(state) normal
      return Normal
    }
    Reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill $color
      $canvas raise ${tag}_Reverse ${tag}_Normal
      $canvas lower ${tag}_Normal  ${tag}_Reverse
      set data(state) reverse
      return Reverse
    }
    Unknown {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas lower ${tag}_Normal
      $canvas lower ${tag}_Reverse
      set data(state) unknown
      return Unknown
    }
  }
  return {}
}

proc CTCPanel::SingleSlip_geti {name ind} {
# [label] proc:SingleSlip_geti
  return {}
}

proc CTCPanel::SingleSlip_seti {name ind value} {
# [label] proc:SingleSlip_seti
  return {}
}

proc CTCPanel::SingleSlip_cget {name switches} { 
# [label] proc:SingleSlip_cget
  upvar #0 $name data
  variable SingleSlip_Switches
  set result {}
  foreach sw $switches { 
    if {[lsearch -exact $SingleSlip_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::SingleSlip_configure {name args} {
# [label] proc:SingleSlip_configure
  upvar #0 $name data
  variable SingleSlip_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $SingleSlip_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_Label -text $data(-label)
}

proc CTCPanel::SingleSlip_destroy {name} {
# [label] proc:SingleSlip_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SingleSlip_move {name x y} {
# [label] proc:SingleSlip_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::SingleSlip_invoke {name} {
# [label] proc:SingleSlip_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::SingleSlip_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {[string length "$data(-statecommand)"] > 0} {
    set newstate [uplevel #0 "$data(-statecommand)"]
    if {[lsearch -exact {normal reverse} $newstate] < 0} {set newstate unknown}
    set data(state) $newstate
  }

  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  switch -exact -- $data(state) {
    normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
    }
    reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
    unknown {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
  }
  return 0
}

proc CTCPanel::DoubleSlip {ctcpanel n args} {
# [label] proc:DoubleSlip
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  DoubleSlip_Config $ctcpanel $name $args
  DoubleSlip_Create $name
  return $name
}

proc CTCPanel::DoubleSlip_Config {ctcpanel name argList} {
# [label] proc:DoubleSlip_Config
  upvar #0 $name data
  variable DoubleSlip_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $DoubleSlip_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(state) normal
  set data(class) DoubleSlip
  set data(getv) DoubleSlip_getv
  set data(setv) DoubleSlip_setv
  set data(geti) DoubleSlip_geti
  set data(seti) DoubleSlip_seti
  set data(cget) DoubleSlip_cget
  set data(configure) DoubleSlip_configure
  set data(destroy) DoubleSlip_destroy
  set data(move) DoubleSlip_move
  set data(invoke) DoubleSlip_invoke
}

proc CTCPanel::DoubleSlip_Create  {name} {
# [label] proc:DoubleSlip_Create 
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  SchematicDrawDot  $canvas  0 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_MainL $cp]
  SchematicDrawDot  $canvas 40 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_MainR $cp]
  SchematicDrawDot  $canvas 5.8578643763 -14.1421356237 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltL $cp]
  SchematicDrawDot  $canvas 34.1421356237 14.1421356237 $data(-flipped) $data(-orientation) [list $tag ${tag}_AltR $cp]
  SchematicDrawLine $canvas  0 0 10 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 30 0 40 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 5.8578643763 -14.142135623 12.92893218815 -7.07106781115000 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 27.07106781255000 7.07106781115000 34.1421356237 14.1421356237 $data(-flipped) $data(-orientation) [list $tag $cp]

  SchematicDrawLine $canvas 10 0 30 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 12.92893218815 -7.07106781115000 27.07106781255000 7.07106781115000 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]

  SchematicDrawLine $canvas 10 0 27.07106781255000 7.07106781115000 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]
  SchematicDrawLine $canvas 12.92893218815 -7.07106781115000 30 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Reverse $cp]

  $canvas itemconfigure ${tag}_Reverse -fill black
  $canvas raise ${tag}_Normal  ${tag}_Reverse
  $canvas lower ${tag}_Reverse ${tag}_Normal 


  set bbox [$canvas bbox ${tag}]
  $canvas create text [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0] \
		      [expr [lindex $bbox 3] + 5] -text $data(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::DoubleSlip_getv {name} {
# [label] proc:DoubleSlip_getv
  upvar #0 $name data
  return $data(state)
}

proc CTCPanel::DoubleSlip_setv {name value} {
# [label] proc:DoubleSlip_setv
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  if {[Switch_invoke $name]} {
    set color red
  } else {
    set color white
  }
  switch -exact -- $value {
    Normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill $color
      $canvas raise ${tag}_Normal  ${tag}_Reverse
      $canvas lower ${tag}_Reverse ${tag}_Normal 
      set data(state) normal
      return Normal
    }
    Reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill $color
      $canvas raise ${tag}_Reverse ${tag}_Normal
      $canvas lower ${tag}_Normal  ${tag}_Reverse
      set data(state) reverse
      return Reverse
    }
    Unknown {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas lower ${tag}_Normal
      $canvas lower ${tag}_Reverse
      set data(state) unknown
      return Unknown
    }
  }
  return {}
}

proc CTCPanel::DoubleSlip_geti {name ind} {
# [label] proc:DoubleSlip_geti
  return {}
}

proc CTCPanel::DoubleSlip_seti {name ind value} {
# [label] proc:DoubleSlip_seti
  return {}
}

proc CTCPanel::DoubleSlip_cget {name switches} { 
# [label] proc:DoubleSlip_cget
  upvar #0 $name data
  variable DoubleSlip_Switches
  set result {}
  foreach sw $switches { 
    if {[lsearch -exact $DoubleSlip_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::DoubleSlip_configure {name args} {
# [label] proc:DoubleSlip_configure
  upvar #0 $name data
  variable DoubleSlip_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $DoubleSlip_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_Label -text $data(-label)
}

proc CTCPanel::DoubleSlip_destroy {name} {
# [label] proc:DoubleSlip_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::DoubleSlip_move {name x y} {
# [label] proc:DoubleSlip_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::DoubleSlip_invoke {name} {
# [label] proc:DoubleSlip_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::DoubleSlip_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {[string length "$data(-statecommand)"] > 0} {
    set newstate [uplevel #0 "$data(-statecommand)"]
    if {[lsearch -exact {normal reverse} $newstate] < 0} {set newstate unknown}
    set data(state) $newstate
  }

  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  switch -exact -- $data(state) {
    normal {
      $canvas itemconfigure ${tag}_Reverse -fill black
    }
    reverse {
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
    unknown {
      $canvas itemconfigure ${tag}_Reverse -fill black
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
  }
  return 0
}

proc CTCPanel::ThreeWaySW {ctcpanel n args} {
# [label] proc:ThreeWaySW
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  ThreeWaySW_Config $ctcpanel $name $args
  ThreeWaySW_Create $name
  return $name
}

proc CTCPanel::ThreeWaySW_Config {ctcpanel name argList} {
# [label] proc:ThreeWaySW_Config
  upvar #0 $name data
  variable ThreeWaySW_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $ThreeWaySW_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(state) normal
  set data(class) ThreeWaySW
  set data(getv) ThreeWaySW_getv
  set data(setv) ThreeWaySW_setv
  set data(geti) ThreeWaySW_geti
  set data(seti) ThreeWaySW_seti
  set data(cget) ThreeWaySW_cget
  set data(configure) ThreeWaySW_configure
  set data(destroy) ThreeWaySW_destroy
  set data(move) ThreeWaySW_move
  set data(invoke) ThreeWaySW_invoke
}

proc CTCPanel::ThreeWaySW_Create  {name} {
# [label] proc:ThreeWaySW_Create 
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)

  SchematicDrawDot  $canvas 0 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Common $cp]
  SchematicDrawLine $canvas 0 0 20 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 20 0 28 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Normal $cp]
  SchematicDrawLine $canvas 20 0 28 8 $data(-flipped) $data(-orientation) [list $tag ${tag}_Right $cp]
  SchematicDrawLine $canvas 20 0 28 -8 $data(-flipped) $data(-orientation) [list $tag ${tag}_Left $cp]
  $canvas itemconfigure ${tag}_Left -fill black
  $canvas itemconfigure ${tag}_Right -fill black
  $canvas raise ${tag}_Normal  ${tag}_Left
  $canvas lower ${tag}_Left ${tag}_Normal 
  $canvas lower ${tag}_Right ${tag}_Left
  SchematicDrawDot  $canvas 40 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Main $cp]
  SchematicDrawLine $canvas 28 0 40 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 28 8 40 20 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawDot  $canvas 40 20 $data(-flipped) $data(-orientation) [list $tag ${tag}_LDivergence $cp]
  SchematicDrawLine $canvas 28 -8 40 -20 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawDot  $canvas 40 -20 $data(-flipped) $data(-orientation) [list $tag ${tag}_RDivergence $cp]
  set bbox [$canvas bbox ${tag}]
  $canvas create text [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0] \
		      [expr [lindex $bbox 3] + 5] -text $data(-label) -anchor n \
		      -font [list Courier -18 bold] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
}

proc CTCPanel::ThreeWaySW_getv {name} {
# [label] proc:ThreeWaySW_getv
  upvar #0 $name data
  return $data(state)
}

proc CTCPanel::ThreeWaySW_setv {name value} {
# [label] proc:ThreeWaySW_setv
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name
  if {[ThreeWaySW_invoke $name]} {
    set color red
  } else {
    set color white
  }
  switch -exact -- $value {
    Normal {
      $canvas itemconfigure ${tag}_Right -fill black
      $canvas itemconfigure ${tag}_Left -fill black
      $canvas itemconfigure ${tag}_Normal  -fill $color
      $canvas raise ${tag}_Normal  ${tag}_Right
      $canvas lower ${tag}_Right ${tag}_Normal 
      $canvas lower ${tag}_Left ${tag}_Right
      set data(state) normal
      return Normal
    }
    Right {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Left -fill black
      $canvas itemconfigure ${tag}_Right -fill $color
      $canvas raise ${tag}_Right ${tag}_Normal
      $canvas lower ${tag}_Normal  ${tag}_Right
      $canvas lower ${tag}_Left ${tag}_Normal
      set data(state) right
      return Reverse
    }
    Left {
      $canvas itemconfigure ${tag}_Right -fill black
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Left -fill $color
      $canvas raise ${tag}_Left ${tag}_Normal
      $canvas lower ${tag}_Normal  ${tag}_Left
      $canvas lower ${tag}_Right ${tag}_Normal
      set data(state) left
      return Reverse
    }
    Unknown {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Right -fill black
      $canvas itemconfigure ${tag}_Left -fill black
      $canvas lower ${tag}_Normal
      $canvas lower ${tag}_Right
      $canvas lower ${tag}_Left
      set data(state) unknown
      return Unknown
    }
  }
  return {}
}

proc CTCPanel::ThreeWaySW_geti {name ind} {
# [label] proc:ThreeWaySW_geti
  return {}
}

proc CTCPanel::ThreeWaySW_seti {name ind value} {
# [label] proc:ThreeWaySW_seti
  return {}
}

proc CTCPanel::ThreeWaySW_cget {name switches} { 
# [label] proc:ThreeWaySW_cget
  upvar #0 $name data
  variable ThreeWaySW_Switches
  set result {}
  foreach sw $switches { 
    if {[lsearch -exact $ThreeWaySW_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::ThreeWaySW_configure {name args} {
# [label] proc:ThreeWaySW_configure
  upvar #0 $name data
  variable ThreeWaySW_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $ThreeWaySW_UCSpecs "" $args
  set tag $name
  $data(canvas) itemconfigure ${tag}_Label -text $data(-label)
}

proc CTCPanel::ThreeWaySW_destroy {name} {
# [label] proc:ThreeWaySW_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::ThreeWaySW_move {name x y} {
# [label] proc:ThreeWaySW_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::ThreeWaySW_invoke {name} {
# [label] proc:ThreeWaySW_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::ThreeWaySW_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {[string length "$data(-statecommand)"] > 0} {
    set newstate [uplevel #0 "$data(-statecommand)"]
    if {[lsearch -exact {normal left right} $newstate] < 0} {set newstate unknown}
    set data(state) $newstate
  }

  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
#  puts stderr "*** -: data(state) = $data(state)"
  switch -exact -- $data(state) {
    normal {
      $canvas itemconfigure ${tag}_Right -fill black
      $canvas itemconfigure ${tag}_Left -fill black
    }
    right {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Left -fill black
    }
    left {
      $canvas itemconfigure ${tag}_Normal  -fill black
      $canvas itemconfigure ${tag}_Right -fill black
    }
    unknown {
      $canvas itemconfigure ${tag}_Right -fill black
      $canvas itemconfigure ${tag}_Left -fill black
      $canvas itemconfigure ${tag}_Normal  -fill black
    }
  }
  return 0
}

proc CTCPanel::HiddenBlock {ctcpanel n args} {
# [label] proc:HiddenBlock
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  HiddenBlock_Config $ctcpanel $name $args
  HiddenBlock_Create $name
  return $name
}

proc CTCPanel::HiddenBlock_Config {ctcpanel name argList} {
# [label] proc:HiddenBlock_Config
  upvar #0 $name data
  variable HiddenBlock_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $HiddenBlock_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) HiddenBlock
  set data(getv) HiddenBlock_getv
  set data(setv) HiddenBlock_setv
  set data(geti) HiddenBlock_geti
  set data(seti) HiddenBlock_seti
  set data(cget) HiddenBlock_cget
  set data(configure) HiddenBlock_configure
  set data(destroy) HiddenBlock_destroy
  set data(move) HiddenBlock_move
  set data(invoke) HiddenBlock_invoke
}

proc CTCPanel::HiddenBlock_getv {name} {
# [label] proc:HiddenBlock_getv
  upvar #0 $name data
  return {}
}

proc CTCPanel::HiddenBlock_setv {name state} {
# [label] proc:HiddenBlock_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  return {}
}

proc CTCPanel::HiddenBlock_geti {name ind} {
# [label] proc:HiddenBlock_geti
  return {}
}

proc CTCPanel::HiddenBlock_seti {name ind value} {
# [label] proc:HiddenBlock_seti
  return {}
}

proc CTCPanel::HiddenBlock_cget {name switches} {
# [label] proc:HiddenBlock_cget
  upvar #0 $name data
  variable HiddenBlock_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $HiddenBlock_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::HiddenBlock_configure {name args} {
# [label] proc:HiddenBlock_configure
  upvar #0 $name data
  variable HiddenBlock_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $HiddenBlock_UCSpecs "" $args
  set tag $name
  $canvas itemconfigure ${name}_Label -text $data(-label)
}

proc CTCPanel::HiddenBlock_destroy {name} {
# [label] proc:HiddenBlock_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::HiddenBlock_move {name} {
# [label] proc:HiddenBlock_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::HiddenBlock_invoke {name} {
# [label] proc:HiddenBlock_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::Switch_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  return $isoccupied
}

proc CTCPanel::HiddenBlock_Create {name} {
# [label] proc:HiddenBlock_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x1 $data(-x1)
  set y1 $data(-y1)
  set x2 $data(-x2)
  set y2 $data(-y2)
  set borientation $data(-bridgeorientation)
  set flipped $data(-flipped)

  $canvas create line $x1 $y1 $x1 $y1 -width 1 -fill black -tag [list $tag $cp ${tag}_E1]
  $canvas create line $x2 $y2 $x2 $y2 -width 1 -fill black -tag [list $tag $cp ${tag}_E2]
  set dx [expr $x2 - $x1]
  set dy [expr $y2 - $y1]
  set fdx [expr $dx * .1]  
  set fdy [expr $dy * .1]
  set xc [expr $x1 + $fdx]
  set yc [expr $y1 + $fdy]
  $canvas create line $x1 $y1 $xc $yc -width 4 -fill white -capstyle round -tag [list $tag $cp]
  set cx1 [expr $xc - 10]
  set cx2 [expr $xc + 10]
  set cy1 [expr $yc - 10]
  set cy2 [expr $yc + 10]
  SchematicDrawCurve $canvas $cx1 $cy1 $cx2 $cy2 $flipped $borientation [list $tag $cp]

  set xc [expr $x2 - $fdx]
  set yc [expr $y2 - $fdy]
  $canvas create line $xc $yc $x2 $y2 -width 4 -fill white -capstyle round -tag [list $tag $cp]
  set cx1 [expr $xc - 10]
  set cx2 [expr $xc + 10]
  set cy1 [expr $yc - 10]
  set cy2 [expr $yc + 10]
  SchematicDrawCurve $canvas $cx1 $cy1 $cx2 $cy2 [expr !$flipped] $borientation [list $tag $cp]

  set bbox [$canvas bbox ${tag}]
  switch -exact -- $data(-position) {
    above {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 1] - 5]
      set at s
    }
    below {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 3] + 5]
      set at n
    }
    left {
      set xt [expr [lindex $bbox 0] - 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at e
    }
    right {
      set xt [expr [lindex $bbox 2] + 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at w
    }
  }

  $canvas create text $xt \
		      $yt  -text $data(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
  
}

proc CTCPanel::StubYard {ctcpanel n args} {
# [label] proc:StubYard
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  StubYard_Config $ctcpanel $name $args
  StubYard_Create $name
  return $name
}

proc CTCPanel::StubYard_Config {ctcpanel name argList} {
# [label] proc:StubYard_Config
  upvar #0 $name data
  variable StubYard_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $StubYard_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) StubYard
  set data(getv) StubYard_getv
  set data(setv) StubYard_setv
  set data(geti) StubYard_geti
  set data(seti) StubYard_seti
  set data(cget) StubYard_cget
  set data(configure) StubYard_configure
  set data(destroy) StubYard_destroy
  set data(move) StubYard_move
  set data(invoke) StubYard_invoke
}

proc CTCPanel::StubYard_getv {name} {
# [label] proc:StubYard_getv
  upvar #0 $name data
  return {}
}

proc CTCPanel::StubYard_setv {name state} {
# [label] proc:StubYard_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  return {}
}

proc CTCPanel::StubYard_geti {name ind} {
# [label] proc:StubYard_geti
  return {}
}

proc CTCPanel::StubYard_seti {name ind value} {
# [label] proc:StubYard_seti
  return {}
}

proc CTCPanel::StubYard_cget {name switches} {
# [label] proc:StubYard_cget
  upvar #0 $name data
  variable StubYard_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $StubYard_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::StubYard_configure {name args} {
# [label] proc:StubYard_configure
  upvar #0 $name data
  variable StubYard_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $StubYard_UCSpecs "" $args
  set tag $name
  $canvas itemconfigure ${name}_Label -text $data(-label)
}

proc CTCPanel::StubYard_destroy {name} {
# [label] proc:StubYard_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::StubYard_move {name} {
# [label] proc:StubYard_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::StubYard_invoke {name} {
# [label] proc:StubYard_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::Switch_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  return $isoccupied
}

proc CTCPanel::StubYard_Create {name} {
# [label] proc:StubYard_Create
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  variable StubYard_Poly
  SchematicDrawDot  $canvas 0 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_Entry $cp]
  SchematicDrawLine $canvas 0 0 20 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawPolygon $canvas $StubYard_Poly $data(-flipped) $data(-orientation) [list $tag $cp]
  set bbox [$canvas bbox ${tag}]
  switch -exact -- $data(-position) {
    above {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 1] - 5]
      set at s
    }
    below {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 3] + 5]
      set at n
    }
    left {
      set xt [expr [lindex $bbox 0] - 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at e
    }
    right {
      set xt [expr [lindex $bbox 2] + 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at w
    }
  }

  $canvas create text $xt \
		      $yt  -text $data(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
  
}
proc CTCPanel::ThroughYard {ctcpanel n args} {
# [label] proc:ThroughYard
  set name ${ctcpanel}_sc_${n}
  upvar #0 $name data
  ThroughYard_Config $ctcpanel $name $args
  ThroughYard_Create $name
  return $name
}

proc CTCPanel::ThroughYard_Config {ctcpanel name argList} {
# [label] proc:ThroughYard_Config
  upvar #0 $name data
  variable ThroughYard_Specs
  set canvas $ctcpanel.schematic.schematicDisplay

  canvasItemParseConfigSpec $name $ThroughYard_Specs "" $argList
  set data(canvas) $canvas
  set data(ctcpanel) $ctcpanel
  set data(class) ThroughYard
  set data(getv) ThroughYard_getv
  set data(setv) ThroughYard_setv
  set data(geti) ThroughYard_geti
  set data(seti) ThroughYard_seti
  set data(cget) ThroughYard_cget
  set data(configure) ThroughYard_configure
  set data(destroy) ThroughYard_destroy
  set data(move) ThroughYard_move
  set data(invoke) ThroughYard_invoke
}

proc CTCPanel::ThroughYard_getv {name} {
# [label] proc:ThroughYard_getv
  upvar #0 $name data
  return {}
}

proc CTCPanel::ThroughYard_setv {name state} {
# [label] proc:ThroughYard_setv
  upvar #0 $name data
  set canvas $data(canvas)
  
  return {}
}

proc CTCPanel::ThroughYard_geti {name ind} {
# [label] proc:ThroughYard_geti
  return {}
}

proc CTCPanel::ThroughYard_seti {name ind value} {
# [label] proc:ThroughYard_seti
  return {}
}

proc CTCPanel::ThroughYard_cget {name switches} {
# [label] proc:ThroughYard_cget
  upvar #0 $name data
  variable ThroughYard_Switches
  set result {}
  foreach sw $switches {
    if {[lsearch -exact $ThroughYard_Switches "$sw"] < 0} {continue}
    lappend result $data($sw)
  }
  return $result
}

proc CTCPanel::ThroughYard_configure {name args} {
# [label] proc:ThroughYard_configure
  upvar #0 $name data
  variable ThroughYard_UCSpecs

  set canvas $data(canvas)
  canvasItemParseConfigSpec $name $ThroughYard_UCSpecs "" $args
  set tag $name
  $canvas itemconfigure ${name}_Label -text $data(-label)
}

proc CTCPanel::ThroughYard_destroy {name} {
# [label] proc:ThroughYard_destroy
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::ThroughYard_move {name} {
# [label] proc:ThroughYard_move
  upvar #0 $name data

  error "Not implemented yet"
}

proc CTCPanel::ThroughYard_invoke {name} {
# [label] proc:ThroughYard_invoke
  upvar #0 $name data
  set canvas $data(canvas)
  set tag $name

#  puts stderr "*** CTCPanel::Switch_invoke $name"

  set isoccupied 0

  if {[string length "$data(-occupiedcommand)"] > 0} {
    set isoccupied [uplevel #0 "$data(-occupiedcommand)"]
  }
  if {$isoccupied} {
    $canvas itemconfigure $tag -fill red
  } else {
    $canvas itemconfigure $tag -fill white
  }
  $canvas itemconfigure ${tag}_Label -fill white
  return $isoccupied
}

proc CTCPanel::ThroughYard_Create {name} {
# [label] proc:ThroughYard_Create
# [index] CTCPanel Schematic Trackwork Objects!procs|)
  upvar #0 $name data
  upvar #0 $data(ctcpanel) ctcdata

  set tag $name
  set cp  $data(-controlpoint)

  set canvas $data(canvas)
  set x $data(-x)
  set y $data(-y)
  variable ThroughYard_Poly
  SchematicDrawDot  $canvas 0 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_EntryL $cp]
  SchematicDrawDot  $canvas 100 0 $data(-flipped) $data(-orientation) [list $tag ${tag}_EntryR $cp]
  SchematicDrawLine $canvas 0 0 20 0 $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawPolygon $canvas $ThroughYard_Poly $data(-flipped) $data(-orientation) [list $tag $cp]
  SchematicDrawLine $canvas 80 0 100 0 $data(-flipped) $data(-orientation) [list $tag $cp]

  set bbox [$canvas bbox ${tag}]
  switch -exact -- $data(-position) {
    above {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 1] - 5]
      set at s
    }
    below {
      set xt [expr double([lindex $bbox 0] + [lindex $bbox 2]) / 2.0]
      set yt [expr [lindex $bbox 3] + 5]
      set at n
    }
    left {
      set xt [expr [lindex $bbox 0] - 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at e
    }
    right {
      set xt [expr [lindex $bbox 2] + 5]
      set yt [expr double([lindex $bbox 1] + [lindex $bbox 3]) / 2.0]
      set at w
    }
  }

  $canvas create text $xt \
		      $yt  -text $data(-label) -anchor $at \
		      -font [list Courier -14 normal] -tag [list $tag $cp ${tag}_Label] \
		      -fill white
  $canvas move   $tag $x $y
  $canvas scale  $tag 0 0 $ctcdata(scale) $ctcdata(scale)
  CheckInitCP $data(ctcpanel) $data(-controlpoint)
  UpdateAndSyncCP $data(ctcpanel) $data(-controlpoint)

  lappend ctcdata($data(-controlpoint),Trackwork) $name
  UpdateSR $canvas [winfo height $canvas] [winfo width $canvas]
  
}

proc CTCPanel::ZoomBy {w zoomFactor} {
# [label] proc:ZoomBy
  upvar #0 $w data

  $w.schematic.schematicDisplay scale all 0 0 $zoomFactor $zoomFactor
  $w.controls.controlsDisplay   scale all 0 0 $zoomFactor $zoomFactor
  set data(scale) [expr $data(scale) * $zoomFactor]
  UpdateSR $w.schematic.schematicDisplay \
	[winfo height $w.schematic.schematicDisplay] \
	[winfo width $w.schematic.schematicDisplay]
  UpdateSR $w.controls.controlsDisplay \
	[winfo height $w.controls.controlsDisplay] \
	[winfo width  $w.controls.controlsDisplay]
}

proc CTCPanel::SetZoom {w zoomFactor} {
# [label] proc:SetZoom
  upvar #0 $w data

  if {$data(scale) != 1} {
    set inv [expr 1.0 / double($data(scale))]
    $w.schematic.schematicDisplay scale all 0 0 $inv $inv
    $w.controls.controlsDisplay   scale all 0 0 $inv $inv
  }
  $w.schematic.schematicDisplay scale all 0 0 $zoomFactor $zoomFactor
  $w.controls.controlsDisplay   scale all 0 0 $zoomFactor $zoomFactor
  set data(scale) $zoomFactor
  UpdateSR $w.schematic.schematicDisplay \
	[winfo height $w.schematic.schematicDisplay] \
	[winfo width $w.schematic.schematicDisplay]
  UpdateSR $w.controls.controlsDisplay \
	[winfo height $w.controls.controlsDisplay] \
	[winfo width  $w.controls.controlsDisplay]
}

proc CTCPanel::GetZoom {w} {
# [label] proc:GetZoom
  upvar #0 $w data

  return $data(scale)
}

proc CTCPanel::CheckInitCP {ctcpanel cp} {
# [label] proc:CheckInitCP
  upvar #0 $ctcpanel ctcdata
  if {[lsearch -exact $ctcdata(CPList) $cp] < 0} {
    lappend ctcdata(CPList) $cp
    set ctcdata($cp,SwitchPlates) {}
    set ctcdata($cp,CodeButtons) {}
    set ctcdata($cp,SignalPlates) {}
    set ctcdata($cp,Toggles) {}
    set ctcdata($cp,Lamps) {}
    set ctcdata($cp,Trackwork) {}
    set ctcdata($cp,CTCLabels) {}
    set ctcdata($cp,SchLabels) {}
    set bbox1 [$ctcpanel.schematic.schematicDisplay bbox $cp]
    set bbox2 [$ctcpanel.controls.controlsDisplay   bbox $cp]
    set sr1   [$ctcpanel.schematic.schematicDisplay cget -scrollregion]
    set sr2   [$ctcpanel.controls.controlsDisplay cget -scrollregion]
    if {[llength $bbox1] == 0 && [llength $bbox2] == 0} {
      set bbox1 [list 0 [lindex $sr1 1] 0 [lindex $sr1 3]]
      set bbox2 [list 0 [lindex $sr2 1] 0 [lindex $sr2 3]]
    } elseif {[llength $bbox1] == 0} {
      set bbox1 [list [lindex $bbox2 0] [lindex $sr1 1] [lindex $bbox2 2] [lindex $sr1 3]]
      set bbox2 [lreplace $bbox2 1 1 [lindex $sr2 1]]
      set bbox2 [lreplace $bbox2 3 3 [lindex $sr2 3]]
    } elseif {[llength $bbox2] == 0} {
      set bbox2 [list [lindex $bbox1 0] [lindex $sr2 1] [lindex $bbox1 2] [lindex $sr2 3]]
      set bbox1 [lreplace $bbox1 1 1 [lindex $sr1 1]]
      set bbox1 [lreplace $bbox1 3 3 [lindex $sr1 3]]
    }
    if {[lindex $bbox2 0] < [lindex $bbox1 0]} {
      set bbox1 [lreplace $bbox1 0 0 [lindex $bbox2 0]]
    } elseif {[lindex $bbox1 0] < [lindex $bbox2 0]} {
      set bbox2 [lreplace $bbox2 0 0 [lindex $bbox1 0]]
    }
    if {[lindex $bbox2 2] > [lindex $bbox1 2]} {
      set bbox1 [lreplace $bbox1 2 2 [lindex $bbox2 2]]
    } elseif {[lindex $bbox1 2] > [lindex $bbox2 2]} {
      set bbox2 [lreplace $bbox2 2 2 [lindex $bbox1 2]]
    }
    if {0} {
      set color yellow
    } else {
      set color [$ctcpanel.schematic.schematicDisplay cget -background]
    }    
    $ctcpanel.schematic.schematicDisplay create rectangle $bbox1 -fill {} -outline $color -width 4 -tag [list $cp ${cp}_outline All_CPs]
    $ctcpanel.schematic.schematicDisplay lower ${cp}_outline
    if {0} {
      set color blue
    } else {
      set color [$ctcpanel.controls.controlsDisplay cget -background]
    }
    $ctcpanel.controls.controlsDisplay   create rectangle $bbox2 -fill {} -outline $color -width 4 -tag [list $cp ${cp}_outline All_CPs]
    $ctcpanel.controls.controlsDisplay   lower ${cp}_outline
  }
}

proc CTCPanel::UpdateAndSyncCP {ctcpanel cp} {
# [label] proc:UpdateAndSyncCP
  upvar #0 $ctcpanel ctcdata
  set bbox1 [$ctcpanel.schematic.schematicDisplay bbox $cp]
  set bbox2 [$ctcpanel.controls.controlsDisplay   bbox $cp]
  if {[lindex $bbox2 0] < [lindex $bbox1 0]} {
    set bbox1 [lreplace $bbox1 0 0 [lindex $bbox2 0]]
  } elseif {[lindex $bbox1 0] < [lindex $bbox2 0]} {
    set bbox2 [lreplace $bbox2 0 0 [lindex $bbox1 0]]
  }
  if {[lindex $bbox2 2] > [lindex $bbox1 2]} {
    set bbox1 [lreplace $bbox1 2 2 [lindex $bbox2 2]]
  } elseif {[lindex $bbox1 2] > [lindex $bbox2 2]} {
    set bbox2 [lreplace $bbox2 2 2 [lindex $bbox1 2]]
  }
  $ctcpanel.schematic.schematicDisplay coords ${cp}_outline $bbox1
  $ctcpanel.controls.controlsDisplay   coords ${cp}_outline $bbox2
}

proc CTCPanel::getv {name} {
# [label] proc:getv
  upvar #0 $name data
  return [$data(getv) $name]
}

proc CTCPanel::setv {name value} {
# [label] proc:setv
  upvar #0 $name data
  return [$data(setv) $name $value]
}

proc CTCPanel::geti {name ind} {
# [label] proc:geti
  upvar #0 $name data
  return [$data(geti) $name $ind]
}

proc CTCPanel::seti {name ind value} {
# [label] proc:seti
  upvar #0 $name data
  return [$data(seti) $name $ind $value]
}

proc CTCPanel::cget {name args} {
# [label] proc:cget
  upvar #0 $name data
  return [eval [concat $data(cget) $name $args]]
}

proc CTCPanel::configure {name args} {
# [label] proc:configure
  upvar #0 $name data
  return [eval [concat $data(configure) $name $args]]
}

proc CTCPanel::exists {name} {
# [label] proc:exists
#  puts stderr "*** CTCPanel::exists $name"
  upvar #0 $name data
#  puts stderr "*** CTCPanel::exists: \[info globals $name\] = [info globals $name]"
  if {[llength [info globals $name]] == 0} {return 0}
#  puts stderr "*** CTCPanel::exists: \[info exists data(ctcpanel)\] = [info exists data(ctcpanel)]"
  if {![info exists data(ctcpanel)]} {return 0}
  set ctcpanel $data(ctcpanel)
#  puts stderr "*** CTCPanel::exists: ctcpanel = $ctcpanel"
#  puts stderr "*** CTCPanel::exists: \[info exists data(canvas)\] = [info exists data(canvas)]"
  if {![info exists data(canvas)]} {return 0}
  set canvas $data(canvas)
#  puts stderr "*** CTCPanel::exists: canvas = $canvas"
  set items [$canvas find withtag $name]
#  puts stderr "*** CTCPanel::exists: items = '$items'"
  if {[llength $items] == 0} {return 0}
  return 1
}

proc CTCPanel::destroy {name} {
# [label] proc:destroy
  upvar #0 $name data
  return [$data(destroy) $name]
}

proc CTCPanel::move {name x y} {
# [label] proc:move
  upvar #0 $name data
  return [$data(destroy) $name $x $y]
}

proc CTCPanel::class {name} {
# [label] proc:class
  upvar #0 $name data
  return $data(class)
}

proc CTCPanel::invoke {name} {
# [label] proc:invoke
  upvar #0 $name data
#  puts stderr "*** CTCPanel::invoke $name"
  return [$data(invoke) $name]
}

proc CTCPanel::coords {name tname} {
# [label] proc:coords
  upvar #0 $name data

  set canvas $data(canvas)
  return "[$canvas coords ${name}_${tname}]" 

}


package provide CTCPanel 1.0
