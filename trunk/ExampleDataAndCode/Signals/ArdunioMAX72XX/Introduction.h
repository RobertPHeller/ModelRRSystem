// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Jul 26 16:31:52 2015
//  Last Modified : <150727.1151>
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

#ifndef __INTRODUCTION_H
#define __INTRODUCTION_H

/** @page Introduction Introduction
 * I will be building an interlocking plant module with 5 two-headed signals. 
 * To drive all of these signals I will be using an Arduino and a Max72XX Led 
 * driver (see http://playground.arduino.cc/Main/MAX72XXHardware
 * for more information about general uses for the Arduino and the Max72XX 
 * chips). This article describes the hardware involved, the firmware 
 * (software on the Arduino) and the host computer software (using the 
 * Dispatcher program from my Model Railroad System).
 * 
 * @section layoutmodule The layout module
 * 
 * @image latex Xover-WithSiding.png "Crossover with siding" width=5in
 * @image html  Xover-WithSiding-small.png
 * The layout module is a simple double track main line with a single 
 * crossover and an industrial siding, as shown here. There will be a 
 * two-track signal bridge (Oregon Rail Supply #151) at the east (right) end 
 * of the interlocking plant and a three-track signal bridge (Oregon Rail 
 * Supply #154, cut down to three tracks) at the west (left) end of the 
 * interlocking plant. At the east end will be a 3 over 2 on track 1 
 * (upper/north main line) and a 3 over 3 on track 2 (lower/south main line).
 * At the west end will be a 1 over 3 on the siding exit, a 3 over 3 on track 
 * 1 (upper/north main line) and a 3 over 1 on track 2 (lower/south main 
 * line).
 * 
 * @section HardwareUsed Hardware being used
 * 
 * I will be using <a href="http://www.oregonrail.com/new.html" target="_blank">Oregon Rail Supply</a>
 * signal bridges, one 2-track (#151) and one 4-track (#154, cut down to 
 * 3-tracks).  I will be using 2mm x 1.25mm chip LEDs (
 * <a href="http://www.mouser.com" target="_blank">Mouser</a> part numbers 
 * <a href="https://www.mouser.com/Search/ProductDetail.aspx?R=LG_R971-KN-1virtualkey62510000virtualkey720-LGR971-KN-1" target="_blank">720-LGR971-KN-1</a>, 
 * <a href="https://www.mouser.com/Search/ProductDetail.aspx?R=LY_R976-PS-36virtualkey62510000virtualkey720-LYR976-PS-36" target="_blank">720-LYR976-PS-36</a>, 
 * and <a href="https://www.mouser.com/Search/ProductDetail.aspx?R=LS_R976-NR-1virtualkey62510000virtualkey720-LSR976-NR-1" target="_blank">720-LSR976-NR-1</a>) 
 * on small circuit boards to light these signals. There will be an Arduino 
 * Uno (<a href="http://www.mouser.com" target="_blank">Mouser</a> part number 
 * <a href="https://www.mouser.com/Search/ProductDetail.aspx?R=A000066virtualkey24200000virtualkey782-A000066" target="_blank">782-A000066</a>) 
 * and a home built board (based on the Arduino Playground circuit) containing 
 * a Max7221 (Mouser Parts: <a href="https://www.mouser.com/ProjectManager/ProjectDetail.aspx?AccessID=982ba0c79b" target="_blank">Mouser Project</a> 
 * and see also <a href="SignalDriverMax72xx.zip">SignalDriverMax72xx.zip</a>, 
 * which contains the PCB Layout/assembly files). This manual describes how I 
 * built these signals and how I will control them from my Linux computer, 
 * using a CTC panel created with my Model Railroad System Dispatcher program.
 * @htmlonly
 * <div class="contents"><a class="el" href="SignalDriverBoard.html">Continuing with the Signal Driver board</a></div>
 * @endhtmlonly
 */

#endif // __INTRODUCTION_H

