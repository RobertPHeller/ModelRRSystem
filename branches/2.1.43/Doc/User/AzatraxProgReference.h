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
//  Last Modified : <140428.1945>
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
 * @addindex MRD2-S
 * @addindex MRD2-U
 * with USB interfaces.  The MRD2-S includes relays for operating switch 
 * motors, power relays, or signals. The MRD2-U contain just a pair of 
 * detectors. Azatrax also makes the SR4 board, which is a quad set of solid
 * @addindex SR4
 * state relays.  Also planned are boards to control stall motor type switch
 * machines and signal driver boards.
 * 
 * @section mrdtest MRD Test Program Reference
 * 
 * This program is the basic test program and can be used to test basic
 * functionality of either a MRD2-S or MRD2-U unit.  There are buttons for
 * @addindex MRD2-S
 * @addindex MRD2-U
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
 * @subsection mrdtest_gui Main GUI Screen
 * 
 * The MRDTest main GUI is shown here:
 * @image latex Azatrax_MRDTestGUI.png "MRDTest Main GUI Screen" width=4in
 * @image html  Azatrax_MRDTestGUI.png
 * @n
 * The upper half contains buttons to invoke each of the commands that the
 * MRD-2 unit understands and the lower half displays the unit's sense data.
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
 * @addindex MRD2-S
 * @addindex MRD2-U
 * 
 * @subsection mrdsensorloop_gui Main GUI Screen
 * 
 * The MRDSensorLoop main GUI is shown here:
 * @image latex Azatrax_MRDSensorLoop.png "MRDSensorLoop Main GUI Screen" width=4in
 * @image html  Azatrax_MRDSensorLoop.png
 * @n
 * This screen shows the current state of the MRD2 unit.  It is updated every 
 * 500 miliseconds (.5 seconds).
 *  
 * @section sr4test SR4 Test Program Reference
 * 
 * This program is the basic test program and can be used to test basic
 * functionality of a SR4 unit.  There are buttons for
 * @addindex SR4
 * each of the commands that can be sent, plus a display area showing the
 * current state data for the unit.
 * 
 * @subsection sr4test_synopsis Synopsis
 * 
 * @code
 * SR4Test [X11 Resource Options]
 * @endcode
 * 
 * Th9iis program takes no parameters.
 * 
 * @subsection sr4test_gui Main GUI Screen
 * 
 * The SR4Test main GUI is shown here:
 * @image latex Azatrax_SR4TestGUI.png "SR4Test Main GUI Screen" width=4in
 * @image html  Azatrax_SR4TestGUISmall.png
 * @n
 * The upper half contains buttons to invoke each of the commands that the
 * SR4 unit understands and the lower half displays the unit's sense data.
 *  
 * @section sl2test SL2 Test Program Reference
 * 
 * This program is the basic test program and can be used to test basic
 * functionality of a SL2 unit.  There are buttons for
 * @addindex SL2
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
 * @subsection sl2test_gui Main GUI Screen
 * 
 * The SL2Test main GUI is shown here:
 * @image latex Azatrax_SL2TestGUI.png "SL2Test Main GUI Screen" width=4in
 * @image html  Azatrax_SL2TestGUISmall.png
 * @n
 * The upper half contains buttons to invoke each of the commands that the
 * SL2 unit understands and the lower half displays the unit's sense data.
 *  
 * @section azatraxdevicemap Azatrax Device Map Reference
 * 
 * This program is a GUI program for mapping Azatrax units.  It creates and
 * updates a text file that maps device serial numbers to names and 
 * descriptions.  This file can be used as a reference when writing scripts
 * and programs that use these devices.
 * 
 * @subsection azatraxdevicemap_synopsis Synopsis
 * 
 * @code
 * AzatraxDeviceMap [X11 Resource Options] [mapfile]
 * @endcode
 * 
 * This program takes an optional mapfile as its sole parameter
 * 
 * @subsection azatraxdevicemap_gui Main GUI Screen
 * 
 * The AzatraxDeviceMap main GUI is shown here:
 * @image latex Azatrax_AzatraxDeviceMapGUI.png "AzatraxDeviceMap Main GUI Screen" width=4in
 * @image html  Azatrax_AzatraxDeviceMapGUISmall.png
 * @n
 * At the top is a pulldown list of discovered Azatrax unit serial numbers, 
 * which can be selected.  The LEDs on the selected unit can be flashed to
 * identify which unit it is.  The unit can be given a name and a description
 * in the fields supplied.
 * 
 */

#endif // __AZATRAXPROGREFERENCE_H

