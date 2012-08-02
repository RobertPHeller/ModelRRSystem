/* 
 * ------------------------------------------------------------------
 * Introduction.h - Introduction to the Rail Driver Daemon interface
 * Created by Robert Heller on Sat Feb  5 14:09:44 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2005/11/14 20:28:45  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/02/12 22:19:23  heller
 * Modification History: Rail Driver code -- first lock down
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
 * 			51 Locke Hill Road
 * 			Wendell, MA 01379-9728
 * 
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 *  
 */

/** Rail Driver Daemon.
  * \TEX{\typeout{Generated from $Id$.}}
  *
  * This daemon allows multiple processes to share a Rail Driver Cab control
  * unit. Processes connect to the daemon via a Tcp/Ip port and then
  * communicate with the daemon by sending and receiving ASCII text messages.

  * The daemon is started from the hotplug USB agent.  The daemon uses
  * the libusb interface and detaches the HID driver from the device (with some
  * 2.4 kernels, it is necessary for the hotplug script to unload the HID
  * driver). Although the Rail Driver Cab Control {\bf is} a hid device, it 
  * isn't a ``pure'' hid device, so this code needs to go ``under'' the hid 
  * module and uses interrupt reads and writes using the libusb API.
  *
  * The device has two endpoints.  One is an input endpoint and retreives the
  * state of all of the levels, buttons, and switches.  The other is an
  * output endpoint and us used to set the speedometer LEDs and to turn the
  * speaker on and off.
  *
  * The RaildriverIO class (see {@link RaildriverIO}) handles the low-level
  * I/O to the Rail Driver Cab Control device.  The RaildriverServer class
  * (see {@RaildriverServer}) implements the higher level interface to client
  * connections.  The RaildriverParser class (see {@RaildriverParser}) is a
  * parser derived from the RaildriverServer class and implements the command 
  * protocol used by client programs to access the Rail Driver Cab Control 
  * device through this daemon.
  */
//@{
