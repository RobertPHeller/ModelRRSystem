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
//  Last Modified : <150725.1311>
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
 */

#endif // __MAIN_H

