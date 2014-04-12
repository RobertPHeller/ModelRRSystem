// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 14:00:38 2014
//  Last Modified : <140412.1037>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2014 Deepwoods Software.
// 
//  All Rights Reserved.
// 
// This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
// reproduced,  translated,  or  reduced to any  electronic  medium or machine
// readable form without prior written consent from Deepwoods Software.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __AZATRAXPROGREFERENCE_H
#define __AZATRAXPROGREFERENCE_H

/** @page azatrax Azatrax Test Programs Reference
 * 
 * These programs can be used to test the various boards made by Azatrax. 
 * These include the MRD2-S and MRD2-U boards, which are infrared sensor units 
 * with USB interfaces.  The MRD2-S includes relays for operating switch 
 * motors, power relays, or signals. The MRD2-U contain just a pair of 
 * detectors. Azatrax also makes the SR4 board, which is a quad set of solid
 * state relays.  Also planned are boards to control stall motor type switch
 * machines and signal driver boards.
 * 
 * @section mrdtest MRD Test Program Reference
 * 
 * This program is the basic test program and can be used to test basic
 * functionality of either a MRD2-S or MRD2-U unit.  There are buttons for
 * each of the commands that can be sent, plus a display area showing the
 * current state data for the unit.
 * 
 * @subsection mrdtest_synopsis Synopsis
 * 
 * @code
 * MRDTest [X11 Resource Options]
 * @endcode
 * 
 * This program takes no parameters.
 * 
 * @section mrdsensorloop MRD Sensor Loop Reference
 * 
 * This program loops, reading the unit sense data at 500 millisecond
 * intervals, displaying the state of the Sense and Latch bits, plus
 * whether or not the stopwatch is ticking and the current stopwatch time
 * value. 
 * 
 * @subsection mrdsensorloop_synopsis Synopsis
 *
 * @code
 * MRDSensorLoop [X11 Resource Options] sensorSerialNumber
 * @endcode
 * 
 * This program takes one parameter, the serial number of the MRD2-S or
 * MRD2-U unit to test.  The program runs until exited or until the MRD2-S
 * MRD2-U unit is unplugged.
 * 
 * @section sr4test SR4 Test Program Reference
 * 
 * This program is the basic test program and can be used to test basic
 * functionality of a SR4 unit.  There are buttons for
 * each of the commands that can be sent, plus a display area showing the
 * current state data for the unit.
 * 
 * @subsection sr4test_synopsis Synopsis
 * 
 * @code
 * SR4Test [X11 Resource Options]
 * @endcode
 * 
 * This program takes no parameters.
 * 
 * @section sl2test SL2 Test Program Reference
 * 
 * This program is the basic test program and can be used to test basic
 * functionality of a SL4 unit.  There are buttons for
 * each of the commands that can be sent, plus a display area showing the
 * current state data for the unit.
 * 
 * @subsection sl2test_synopsis Synopsis
 * 
 * @code
 * SL2Test [X11 Resource Options]
 * @endcode
 * 
 * This program takes no parameters.
 * 
 * @section azatraxdevicemap Azatrax Device Map Reference
 * 
 * This program is a GUI program for mapping Azatrax units.
 * 
 * @subsection azatraxdevicemap_synopsis Synopsis
 * 
 * @code
 * AzatraxDeviceMap [X11 Resource Options] [mapfile]
 * @endcode
 * 
 * This program takes an optional mapfile as its sole parameter
 * 
 */

#endif // __AZATRAXPROGREFERENCE_H

