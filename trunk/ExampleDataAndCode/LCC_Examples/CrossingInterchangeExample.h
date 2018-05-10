// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Thu May 10 15:47:38 2018
//  Last Modified : <180510.1857>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2018  Robert Heller D/B/A Deepwoods Software
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

#ifndef __CROSSINGINTERCHANGEEXAMPLE_H
#define __CROSSINGINTERCHANGEEXAMPLE_H
/** @page CrossingInterchangeExample Crossing Interchange Controlled by a Raspberry Pi with HATs and LCC
 * This example illustrates how one might implement the control aspects of a 
 * simple interchange between two rail lines that meet at a level crossing.
 * The layout module is shown here:
 * @image html CrossingInterchange_Small.png
 * @image latex CrossingInterchange.png "Crossing Interchange Layout" height=3.25in
 * @latexonly
 * \footnote{There is an XTrkCAD file, named \texttt{CrossingInterchange.xtc},
 * and a PDF file, named \texttt{CrossingInterchange.pdf}, in the examples
 * distribution directory.}
 * @endlatexonly
 * @htmlonly
 * <h4 style="text-align:center;">Crossing Interchange Layout</h4>
 * <br clear="all" />
 * @endhtmlonly
 * 
 * We will control the two turnouts with a SMCSenseHAT.  This board uses 4
 * GPIO pins on the Raspberry Pi, two to set the motors and two to sense the
 * state of the switch motors.
 * 
 * Signaling will be with three color single head signals and with 
 * 3 over 2 double head signals at the point entrance to the turnouts.  There
 * is a total of twelve heads and we will use three QuadSignalCA HATs and
 * common anode LED signals.
 * 
 * We will be sensing occupancy of 8 blocks:
 *  -# @b OS1 Turnout SW1, at the northern entrance of the north-south rail line.
 *  -# @b OS2 Turnout SW2, at the eastern entrance of the east-west rail line.
 *  -# @b Crossing @b OS The level crossing itself.
 *  -# @b Interchange The interchange track connecting between the two 
 *  turnouts.
 *  -# @b Main @b One The east-west mainline between SW2 and the Crossing.
 *  -# @b Main @b Two The north-south mainline between SW1 and the Crossing.
 *  -# @b Main @b One @b West The east-west mainline west of the Crossing.
 *  -# @b Main @b Two @b South The north-south mainline south of the Crossing.
 * 
 * We can use a pair of Circuits 4 Tracks Quad Occupancy detector boards, with
 * their outputs wired to 8 of the Raspberry Pi's GPIO pins.
 * 
 * We will have a total of 5 HAT boards:
 *  - 1 @b SMCSenseHAT to manage the two turnouts.
 *  - 1 @b Adafruit @b Perma-Proto @b HAT to connect the occupancy detector 
 * boards.
 *  - 3 @b QuadSignalCA @b HATs to light the 12 signal heads.
 * 
 * The @b SMCSenseHAT is hardwired to use Wiring Pi pins 0, 1, 2, and 3 (BCM 
 * pins 17, 18, 27, and 22).  The PiGPIO XML file included with this example, 
 * maps Motor 1 (pin 0 for motor control and pind 2 for point sense) to SW1 
 * and motor 2 (pin 1 for motor control and pin 3 for point sense) to SW2.
 * 
 * The @b SMCSenseHAT is connected as shown here:
 * @image html CrossingInterchange_SMCSenseHAT_Small.png
 * @image latex CrossingInterchange_SMCSenseHAT.png "Connecting the SMCSenseHAT" height=3.5in
 * @htmlonly
 * <h4 style="text-align:center;">Connecting the SMCSenseHAT</h4>
 * <br clear="all" />
 * @endhtmlonly
 * 
 * The @b Adafruit @b Perma-Proto @b HAT is wired as shown below.  The only 
 * components installed on this board are a pair of 6 position screw terminals.
 * It is possible to use a board that simply has screw terminals for the GPIO
 * pins (like the Adafruit Pi-EzConnect Terminal Block Breakout HAT) instead 
 * of wiring up a board like this.  The PiGPIO XML file included with this 
 * example maps the GPIO pins like this:
 *  - WPi 4 (BCM 23) to OS2
 *  - WPi 5 (BCM 24) to Main One
 *  - WPi 6 (BCM 25) to Crossing OS
 *  - WPi 7 (BCM 4) to OS1
 *  - WPi 21 (BCM 5) to Interchange
 *  - WPi 22 (BCM 6) to Main Two
 *  - WPi 23 (BCM 13) to Main One West
 *  - WPi 26 (BCM 12) to Main Two South
 * 
 * This is how the GPIOs are wired:
 * @image html CrossingInterchange_OccupencyHAT_Small.jpg 
 * @image latex CrossingInterchange_OccupencyHAT.jpg "Wiring and connecting the Adafruit Perma-Proto HAT." height=3in
 * @htmlonly
 * <h4 style="text-align:center;">Wiring and connecting the Adafruit Perma-Proto HAT.</h4>
 * <br clear="all" />
 * @endhtmlonly
 * 
 * The QuadSignal XML files included with this example maps the signals like 
 * this:
 *  - First board (i2c address 0): 
 *    - S1S H1 and H2
 *    - S1MN H3
 *    - S1IN H4
 *  - Second board (i2c address 1):
 *    - S2ME H1
 *    - S2W  H2 and H3
 *    - S2IE H4
 *  - Third board (i2c address 2):
 *    - S3W  H1
 *    - S3N  H2
 *    - S3E  H3
 *    - S3S  H4
 *
 * This is how the @b QuadSignalCA @b HATs are wired (be sure to take note of 
 * the address jumpers):
 * @image html CrossingInterchange_CP1Signals_Small.png
 * @image latex CrossingInterchange_CP1Signals.png "Connecting the signals at Control Point 1." height=2.75in
 * @htmlonly
 * <h4 style="text-align:center;">Connecting the signals at Control Point 1.</h4>
 * <br clear=="all" />
 * @endhtmlonly
 * @image html CrossingInterchange_CP2Signals_Small.png
 * @image latex CrossingInterchange_CP2Signals.png "Connecting the signals at Control Point 2." height=2.75in
 * @htmlonly
 * <h4 style="text-align:center;">Connecting the signals at Control Point 3.</h4>
 * <br clear=="all" />
 * @endhtmlonly
 * @image html CrossingInterchange_CP3Signals_Small.png
 * @image latex CrossingInterchange_CP3Signals.png "Connecting the signals at Control Point 3." height=2.75in
 * @htmlonly
 * <h4 style="text-align:center;">Connecting the signals at Control Point 3.</h4>
 * <br clear=="all" />
 * @endhtmlonly
 *
 */

#endif // __CROSSINGINTERCHANGEEXAMPLE_H

