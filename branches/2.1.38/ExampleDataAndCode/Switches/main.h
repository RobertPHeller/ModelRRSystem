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
//  Last Modified : <150816.1142>
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
/** @mainpage Switch (Turnout) Abstract Types (Classes)
 * 
 * This folder contain a collection of Tcl code to implement switches (aka 
 * turnouts), using various actuator hardware. Included is OS detection and
 * point position detection, along with code to operate switch motors.
 * 
 * @section files Source Files
 * 
 * There are several Tcl source files in this directory.  Each contains a
 * SNIT @b Abstract data type (also known as a @e Class).  This abstract data
 * type encapsulates a single @e switch (turnout). All of these abstract data 
 * types a method named @c occupiedp, which returns a true or false result
 * indicating whether or not the OS is occupied. Also included are a 
 * @c pointsense method which returns the state of the points and a @c motor 
 * method which operates the switch machine to move the points.
 * 
 * @subsection sr4_mrd2 SR4 as actuator and pointsense with a MRD2U for OS detection
 * 
 * SR4_MRD2_Switch.tcl contains an abstract data type (SR4_MRD2_Switch) that 
 * implements switches using one half of a Azatrax SR4 for the actuator and 
 * pointsense and a Azatrax MRD2U Sensor for OS detection.
 * 
 * @subsection sr4_c4tsr4 SR4 as actuator and pointsense with a Circuits4Tracks Quad Occupancy Detector with a SR4 (USB connected I/O board).
 * 
 * SR4_C4TSR4_Switch.tcl contains an abstract data type (SR4_C4TSR4_Switch)
 * that implements switches using one half of a Azatrax SR4 for the actuator 
 * and 1/4 of a Circuits4Tracks Quad Occupancy Detector connected to another 
 * Azatrax SR4 for OS detection.
 * 
 * @subsection smini_c4t Chubb SMINI board as actuator and pointsense with a Circuits4Tracks Quad OD as OS sensor
 * 
 * C4TSMINI_Switch.tcl contains an abstract data type (C4TSMINI_Switch) that
 * implements switches using a Chubb SMINI board as actuator and pointsense 
 * with a Circuits4Tracks Quad OD as OS sensor.
 * 
 * @subsection tb CTI Yardmaster as actuator and Train Brain as pointsense with a Circuits4Tracks Quad OD as OS sensor
 *
 * TB_Switch.tcl contains an abstract data type (TB_Switch) that implements 
 * switches using a CTI Yardmaster as actuator and a Train Brain for 
 * pointsense with a Circuits4Tracks Quad OD as OS sensor.
 * 
 * @section Commmethods Common methods and functionality
 * 
 * All three types have a common structure.  The constructors take the form:
 * @code
 * typename objectname [optional options]
 * @endcode
 * Eg:
 * @code
 * SR4_MRD2_Switch switch1 -motorobj turnoutControl1 -motorhalf lower \
 *                       -pointsenseobj turnoutControl1 \
 *                       -pointsensehalf lower -plate SwitchPlate1 \
 *                       -ossensorsn 0200001234
 * @endcode
 * 
 * There are a trio of common options, -previousblock, -nextmainblock, 
 * and -nextdivergentblock which are the names of the previous block in the 
 * forward direction and the name of the previous blocks in the reverse 
 * direction.  Another trio of common options, -forwardsignalobj,
 * -reversemainsignalobj, and -reversedivergentsignalobj are the 
 * names of signal objects.  Also there is the option, -direction with sets 
 * the current operating direction for the block and can be forward or 
 * reverse. For blocks that only support traffic in one direction, use only
 * the -previousblock and -forwardsignalobj options.  The -direction 
 * defaults to forward. There are other object specific options that define 
 * how the sensor is accessed by the block object.
 * 
 * There are six common methods, four public and two private (the private
 * methods should not be used by external code).  The public methods are
 * occupiedp, propagate, pointstate, and motor. The occupiedp 
 * method returns a true or false (logical) value that indicates whether the 
 * switch is occupied or not. The pointstate method returns the state if 
 * the points. The motor method activates the switch motor to move the 
 * points. The propagate method takes a signal aspect to 'propagate' to the 
 * previous block. The occupiedp method is typically called from the
 * occupied command script associated with a piece of track work.  The 
 * @c pointstate method is typically called from the state sense script 
 * associated with the switch track work. And the motor method is assocated
 * with the normal and reverse scripts for the switch's switch plate on the
 * CTC panel.
 * 
 * The two private methods, _entering and _exiting are used to implement
 * special handling when entering or leaving a block.  Presently, the 
 * _entering method sets the signal aspect and propagates signal aspects
 * down to previous blocks and the _exiting method does nothing. These
 * methods can be extended to add additional functionality, as needed.
 * 
 * 
 */

#endif // __MAIN_H

