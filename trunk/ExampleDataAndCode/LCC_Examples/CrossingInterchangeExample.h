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
//  Last Modified : <180510.1702>
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
 * @image latex CrossingInterchange.png "Crossing Interchange Layout" width=4in
 * @latexonly
 * \footnote{There is an XTrkCAD file, named \texttt{CrossingInterchange.xtc},
 * and a PDF file, named \texttt{CrossingInterchange.pdf}, in the examples
 * distribution directory.}
 * @endlatexonly
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
 * The @b SMCSenseHAT is connected as shown here:
 * @image html CrossingInterchange_SMCSenseHAT_Small.png
 * @image latex CrossingInterchange_SMCSenseHAT.png "Connecting the SMCSenseHAT" width=4in
 * 
 * The @b Adafruit @b Perma-Proto @b HAT is wired as shown below.  The only 
 * components installed on this board are a pair of 6 position screw terminals.
 * It is possible to use a board that simply has screw terminals for the GPIO
 * pins (like the Adafruit Pi-EzConnect Terminal Block Breakout HAT) instead 
 * of wiring up a board like this.
 * @image html CrossingInterchange_OccupencyHAT_Small.jpg 
 * @image latex CrossingInterchange_OccupencyHAT.jpg "Wiring and connecting the @b Adafruit @b Perma-Proto @b HAT." width=4in
 * 
 * The 3 @b QuadSignalCA @b HATs are wired as shown below. Be sure to note the
 * address jumpers on these boards.
 * @image html CrossingInterchange_CP1Signals_Small.png
 * @image latex CrossingInterchange_CP1Signals.png "Connecting the signals at Control Point 1." width=4in
 * @image html CrossingInterchange_CP2Signals_Small.png
 * @image latex CrossingInterchange_CP2Signals.png "Connecting the signals at Control Point 2." width=4in
 * @image html CrossingInterchange_CP3Signals_Small.png
 * @image latex CrossingInterchange_CP3Signals.png "Connecting the signals at Control Point 3." width=4in
 *
 */

#endif // __CROSSINGINTERCHANGEEXAMPLE_H

