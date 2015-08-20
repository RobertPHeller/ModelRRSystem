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
//  Last Modified : <150820.1602>
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
/** @mainpage Example Yard CTC Panels
 * 
 * The Chubb_FoxYard.tcl file contains part of the layout shown in Chapters 12
 * (Figure 12-11 on page 12-27) and 14 (Figure 14-3 on page 14-7) of The 
 * Computer/Model Railroad Interface User's Manual Version 3.
 * 
 * @dontinclude Chubb_FoxYard.tcl
 * 
 * First we will connect to the Chubb CmriNet via a USB serial port (a USB <=>
 * RS485 adaptor).
 * @skip # Add User code after this line
 * @skipline ## Connect to the Chubb CmriNet
 * @until openport
 * Then we will initialize the two SMINI nodes
 * @until Donaldson
 * Then we will create abstract objects for all trackwork.
 * @until BK18
 * Then we will initialize the Direction Of Travel to no direction.
 * @until DOT3
 * Then in the main loop we will Invoke all trackwork and get occupicency.
 * @until BK17
 * And then activate the switch motors.
 * @until TG11Plate
 * We will then compute the direction of travel.
 * @until set DOT3 nodirection
 * @line }
 * We will then set the aspects of the Eastbound signals from west to east.
 * @until SIG16RA setaspect green
 * @line }
 * @line }
 * @line }
 * Then the aspects of the Westbound signals east to west.
 * @until SIG20LA setaspect
 * @until SIG20LA setaspect
 * @line }
 * @line }
 * @line }
 * @line }
 * @line }
 * Then we light the Direction Of Travel lamps
 * @until ctcpanel setv DOT3-West on
 * @line }
 * Finally, the main loop ends.
 * @until }
 * 
 */

#endif // __MAIN_H

