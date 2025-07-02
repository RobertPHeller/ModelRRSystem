// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Jul 12 15:21:38 2015
//  Last Modified : <150801.1436>
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

/**
 * @mainpage Block Abstract Types (Classes)
 * 
 * This folder contains a collection of Tcl code to implement block occupancy
 * detection, using various methods.  At the very least, block detection 
 * results in signal aspect updates. Code for managing signals is in in the
 * Signals folder.
 * 
 * There are two main ways to detect trains: using optical sensors or using
 * current sensors.  Optical sensors generally work via reflection (bouncing a
 * light beam off the bottom of the train), although an across-the-tracks 
 * type is possible too.  Current sensors work by sensing a current flow
 * when a locomotive, lighted passenger car, or a freight car with resistors
 * installed on its wheelsets passes onto an electrically isolated section of
 * track.  In any case, the sensor is connected to the computer somehow, either
 * via USB or via a direct or indirect I/O bit or port.
 * 
 * @section files Source Files
 * 
 * There are several Tcl source files in this directory.  Each contains a
 * SNIT @b Abstract data type (also known as a @e Class).  This abstract data
 * type encapsulates a single @e block.  All of these abstract data types
 * include a method named @c occupiedp, which returns a true or false result
 * indicating whether or not the block is occupied. The constructor for these
 * types include options or arguments that define the I/O device(s) that 
 * connect to whatever sensors are being used to detect block occupancy.
 * 
 * @subsection mrd2 MRD2U Sensor (USB connected optical sensor)
 * 
 * MRD2_Block.tcl contains an abstract data type (MRD2_Block) that implements
 * blocks using one Azatrax MRD2U Sensor for each block.
 * 
 * @subsection c4tsr4 Circuits4Tracks Quad Occupancy Detector with a SR4 (USB connected I/O board)
 * 
 * C4TSR4_Block.tcl contains an abstract data type (C4TSR4_Block) that
 * implements blocks using Circuits4Tracks Quad Occupancy Detectors connected
 * to Azatrax SR4 modules using SSRs.  One Circuits4Tracks Quad Occupancy
 * Detector and one SR4 will handle 4 blocks.
 * 
 * @subsection c4tsmini Circuits4Tracks Quad Occupancy Detector connected to a C/MRI SMINI board
 * 
 * C4TSMINI_Block.tcl contains an abstract data type (C4TSMINI_Block) that
 * implements blocks using Circuits4Tracks Quad Occupancy Detectors connected
 * to input pins of a Bruce Chubb C/MRI Super Mini (SMINI) board.  A Bruce
 * Chubb C/MRI Super Mini (SMINI) board has enough inputs to handle a number
 * of Circuits4Tracks Quad Occupancy Detectors.
 *
 * @subsection c4ttb Circuits4Tracks Quad Occupancy Detector connected to a CTI Train Brain
 * 
 * C4TTB_Block.tcl contains an abstract data type (C4TTB_Block) that
 * implements blocks using Circuits4Tracks Quad Occupancy Detectors connected
 * to the sensor inputs of a CTI Train Brain, Watchman, or Sentry board.Circuits4Tracks Quad Occupancy Detector connected to a
 *
 * @section Commmethods Common methods and functionality
 * 
 * All three types have a common structure.  The constructors take the form:
 * @code
 * typename objectname [optional options]
 * @endcode
 * Eg:
 * @code
 * MRD2_Block block2 -previousblock block1 -sensorsn 020001234 \
                     -forwardsignalobj signal2
 * @endcode
 * 
 * There are a pair of common options, @c -previousblock and @c -nextblock, 
 * which are the names of the previous block in the forward direction and the 
 * name of the previous block in the reverse direction.  Another pair of 
 * common options, @c -forwardsignalobj and @c -reversesignalobj, are the 
 * names of signal objects.  Also there is the option, @c -direction with sets 
 * the current operating direction for the block and can be @c forward or 
 * @c reverse. For blocks that only support traffic in one direction, use only
 * the @c -previousblock and @c -forwardsignalobj options.  The @c -direction 
 * defaults to @c forward. There are other object specific options that define 
 * how the sensor is accessed by the block object.
 * 
 * There are four common methods, two public and two private (the private
 * methods should not be used by external code).  The public methods are
 * @c occupiedp and @c propagate. The @c occupiedp method returns a true or 
 * false (logical) value that indicates whether the block is occupied or not. 
 * The @c propagate method takes a signal aspect to 'propagate' to the 
 * previous block. The @c occupiedp method is typically called from the
 * occupied command script associated with a piece of track work.
 * 
 * The two private methods, @c _entering and @c _exiting are used to implement
 * special handling when entering or leaving a block.  Presently, the 
 * @c _entering method sets the signal aspect and propagates signal aspects
 * down to previous blocks and the @c _exiting method does nothing. These
 * methods can be extended to add additional functionality, as needed.
 * 
 */


#endif // __MAIN_H

