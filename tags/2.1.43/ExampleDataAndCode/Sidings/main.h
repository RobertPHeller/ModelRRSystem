// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Tue Jul 14 12:40:17 2015
//  Last Modified : <150725.1534>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2015  Robert Heller D/B/A Deepwoods Software
//			51 Locke Hill Road
//			Wendell, MA 01379-9728
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// 
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __MAIN_H
#define __MAIN_H
/** @mainpage Example Siding CTC Panels
 * 
 * This folder contains a collection of example siding CTC panels
 * 
 * The Azatrax_Siding.tcl file contains a simple passing siding using Azatrax
 * devices for block occupancy detection, turnout activation, and turnout
 * point state detection.  It uses code from MRD2_Block.tcl and 
 * SR4_MRD2_Switch.tcl.
 * 
 * @image html Azatrax_Siding_schematic.png
 * @image latex Azatrax_Siding_schematic.png "Schematic of the track work" width=4in
 * This is the Schematic of the track work, which is a simple siding with a 
 * passing siding.
 * @image html Azatrax_Siding_controls.png
 * @image latex Azatrax_Siding_controls.png "CTC Panel for the siding" width=4in
 * This is the CTC Panel for the siding, which is simply a switch plate and code
 * button for each of the turnouts.
 *
 * @dontinclude Azatrax_Siding.tcl
 * Using the Abstract Data Types (Classes) MRD2_Block and SR4_MRD2_Switch 
 * almost all of the code is embeded in these Abstract Data Types, which makes 
 * the code here very simple.  Specificly, we create a MRD2_Block object for 
 * the main and siding tracks:
 * @skipline # Two straight
 * @until siding
 * Then create a connection to the SR4 for use by the two turnouts:
 * @skipline # One SR4
 * @until ]
 * Then we create a SR4_MRD2_Switch object for each turnout, linking them to 
 * the main and siding tracks.
 * @skipline # Two turnouts
 * @until -plate SwitchPlate2
 * Then connect the main and siding MRD2_Block objects to the SR4_MRD2_Switch 
 * objects.
 * @skipline # Connect the siding
 * @until siding configure
 * Finally, we create a pair of CodeButton objects for the code buttons.
 * @skipline # Two Code buttons
 * @until -cpname CP2
 * When we assembled the track work and control panel, we set the scripts to 
 * run the various callback methods:
 * For the Main straight block, the "Occupied Script" would be 
 * "main occupiedp". For the Siding it would be "siding occupiedp".
 * For Switches, "State Script" would be set to "switchN pointstate" and
 * "Occupied Script" would be set to "switchN occupiedp". For the switch
 * plates, the "Normal Script" would be "switchN motor normal" and the
 * "Reverse Script" would be "switchN motor reverse". Finally the code
 * buttons would have an "Action Script" of "codeN code". Thus everything is 
 * tied together.  The main loop 'invokes' the track work elements, which runs 
 * the occupency methods.
 * @skipline # Main Loop Start
 * @until # Main Loop End
 * The code buttons will run the switch plate functions which in turn 
 * will activate the switch machines.
 * 
 */

#endif // __MAIN_H

