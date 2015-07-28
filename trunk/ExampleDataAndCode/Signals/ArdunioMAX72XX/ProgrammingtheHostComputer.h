// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Tue Jul 28 09:13:33 2015
//  Last Modified : <150728.1915>
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

#ifndef __PROGRAMMINGTHEHOSTCOMPUTER_H
#define __PROGRAMMINGTHEHOSTCOMPUTER_H
/** @page ProgrammingtheHostComputer Programming the Host Computer
 * 
 * The host interface to the Ardunio SignalDriverMax72xx is via a virtual
 * serial port over the USB interface.  The host computer sends text commands
 * down the serial port and the Ardunio in turn sends data down its SPI
 * interface to the MAX72XX, which in turn lights up the signal LEDs.  
 * 
 * I wrote a simple Tcl SNIT type (OO class) that implements this interface.
 * @htmlonly
 * The Tcl code is in the file 
 * <a href="SignalDriverMax72xx_Host.tcl">SignalDriverMax72xx_Host.tcl</a>.
 * @endhtmlonly
 * @latexonly
 * The Tcl code is in the file SignalDriverMax72xx\_Host.tcl.
 * @endlatexonly
 * The constructor connects to the Ardunio by opening the virtual serial port.
 * Then signals can then be lit with selected aspects with the instance method
 * @c set, which takes two arguments, a signal number (0 to 7 inclusive) and an
 * aspect string, which is one of:
 * 
 *    - g_r (Green over Red -- Clear)
 *    - y_r (Yellow over Red -- Approach)
 *    - r_r (Red over Red -- [Absolute] Stop)
 *    - r_g (Red over Green -- Slow Clear)
 *    - r_y (Red over Yellow -- Approach Limited)
 *    - dark (all lights off)
 * 
 * There is also an instance method, @c dark, which turns all of the signal LEDs
 * off.
 * 
 * Typical usage:
 * @code
 * # Load the code
 * package require SignalDriverMax72xx_Host
 * # Connect to the Ardunio on /dev/ttyACM0
 * SignalDriverMax72xx controlpoint1 -portname /dev/ttyACM0
 * # Define symbolic names for the signals
 * # East end (Westbound) of Control Point 1 on track 2
 * set CP1w2 0
 * # East end (Westbound) of Control Point 1 on track 1
 * set CP1w1 1
 * # West end (Eastbound) of Control Point 1 on track 2
 * set CP1e2 2
 * # West end (Eastbound) of Control Point 1 on track 1
 * set CP1e1 3
 * # West end (Eastbound) of Control Point 1 on siding
 * set CP1eS 4
 * # Set all signals to Red over Red
 * controlpoint1 set $CP1w2 r_r
 * controlpoint1 set $CP1w1 r_r
 * controlpoint1 set $CP1e2 r_r
 * controlpoint1 set $CP1e1 r_r
 * controlpoint1 set $CP1eS r_r
 * # Set Track 1 for clear (Green over Red) Eastbound
 * controlpoint1 set $CP1e1 g_r
 * # Set Track 2 for clear (Green over Red) Westbound
 * controlpoint1 set $CP1w2 g_r
 * @endcode
 * 
 * 
 */

#endif // __PROGRAMMINGTHEHOSTCOMPUTER_H

