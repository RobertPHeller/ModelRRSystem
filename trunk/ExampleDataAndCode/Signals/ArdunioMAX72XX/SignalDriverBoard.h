// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Jul 26 17:22:30 2015
//  Last Modified : <150726.2016>
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

#ifndef __SIGNALDRIVERBOARD_H
#define __SIGNALDRIVERBOARD_H
/** @page SignalDriverBoard Signal Driver board
 * The Signal Driver board is assembled on a piece of "strip board", 
 * specifically a 3.5 inch by 2.5 inch piece cut from a BusBoard Prototype 
 * Systems BPS-MAR-ST6U-001 (included in the Mouser project). After cutting 
 * this piece from the board some of the copper foil needs to be carefully 
 * removed. This is done with a sharp hobby knife and a soldering iron is used 
 * to heat the copper to make it easy to peel.  The PCB Layout/assembly Zip 
 * file includes a PostScript file named SignalDriverMax72xx.back.ps which is 
 * an actual sized drawing of what the foil should look like.  Here is a 
 * side-by-side view of an actual board and the SignalDriverMax72xx.back.ps 
 * drawing:
 * @image latex SignalDriverMax72xx_back-photo.jpg "Photo of the Signal Driver circuit board (foil side)" height=2.5in
 * @image html SignalDriverMax72xx_back-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_back.png "Signal Driver Foil side PCB layout" height=2.5in
 * @image html SignalDriverMax72xx_back-thumb.png
 * I cut the board to have two strip rows above and below the foil layout to 
 * provide a place to drill mounting holes that would not interfere with the 
 * circuit elements.
 * 
 * The next step is to run the vertical connections, using solid hookup wire. 
 * I used a different color for each "layer".  Staring with layer group2 
 * (ground) in black.
 * @image latex SignalDriverMax72xx_group2-photo.jpg "Photo of group2 (ground) wires in black" height=2.5in
 * @image html SignalDriverMax72xx_group2-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_group2.png "Group2 (ground) PCB Layout" height=2.5in
 * @image html SignalDriverMax72xx_group2-thumb.png
 * 
 * Then layer group3 (power) in red.
 * @image latex SignalDriverMax72xx_group3-photo.jpg "Group3 (power) with red wire" height=2.5in
 * @image html SignalDriverMax72xx_group3-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_group3.png "SignalDriverMax72xx_group3.png" height=2.5in
 * @image html SignalDriverMax72xx_group3-thumb.png
 * Then layer group4 (signal1) in yellow.
 * 
 * @image latex SignalDriverMax72xx_group4-photo.jpg "Group4 (signal1) in Yellow" height=2.5in
 * @image html SignalDriverMax72xx_group4-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_group4.png "Group4 (signal1) PCB Layout" height=2.5in
 * @image html SignalDriverMax72xx_group4-thumb.png
 * Then layer group5 (signal2) in green.
 * 
 * @image latex SignalDriverMax72xx_group5-photo.jpg "Group5 (signal 2) in green" height=2.5in
 * @image html SignalDriverMax72xx_group5-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_group5.png "PCB layer group5 (signal2)" height=2.5in
 * @image html SignalDriverMax72xx_group5-thumb.png
 * Then layer group6 (signal3) in blue.
 * 
 * @image latex SignalDriverMax72xx_group6-photo.jpg "Photo of group6 (signal3) in blue." height=2.5in
 * @image html SignalDriverMax72xx_group6-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_group6.png "PCB layer group6 (signal3)" height=2.5in
 * @image html SignalDriverMax72xx_group6-thumb.png
 * Then layer group7 (signal4) in white.
 * 
 * @image latex SignalDriverMax72xx_group7-photo.jpg "Photo of group 7 (signal 4) in white" height=2.5in
 * @image html SignalDriverMax72xx_group7-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_group7.png "PCB layout of  group7 (signal4)" height=2.5in
 * @image html SignalDriverMax72xx_group7-thumb.png
 * Finally, the headers, IC socket, and the passive components are installed. 
 * There is a trick to installing the IC socket and the headers: solder only 
 * one pin, then while pushing the socket or header against the board, reheat 
 * the solder to make it re-flow.  This should cause the socket or header to 
 * snap squarely to the board. You might have to push some of the wires to one 
 * side to install the IC socket and the 9-pin headers, but if you were 
 * careful about routing the wires, this should not be a problem.  The 
 * resistor needs to have one of its leads bent 180 degrees to allow it to be 
 * mounted on end.  The unbent pin should go next to the where the red wires 
 * are installed.  C2 (the larger electrolytic capacitor) is polarized.  The 
 * negative lead (the shorter one next to the stripe) goes towards the IC 
 * socket.  The resistor and the capacitors should be mounted as tightly to 
 * the board as possible.  You can solder one lead and the reheat the solder 
 * to carefully position them tight and square.
 * 
 * @image latex SignalDriverMax72xx_frontassembly-photo.jpg "Photo of front assembly" height=2.5in
 * @image html  SignalDriverMax72xx_frontassembly-photo-thumb.jpg
 * @image latex SignalDriverMax72xx_frontassembly.png "PCB layout of front assembly" height=2.5in
 * @image html  SignalDriverMax72xx_frontassembly-thumb.png
 * Here is another view of the completed circuit board. This angle view gives 
 * a better view of the assembly.  The next step is to carefully inspect the 
 * board, looking closely with a magnifier looking for solder bridges or bad 
 * solder joints.
 * 
 * @image latex SignalDriverMax72xx_frontassembly-angle-photo.jpg "Photo of front assembly at an angle" height=2.5in
 * @image html  SignalDriverMax72xx_frontassembly-angle-photo-thumb.jpg
 * Then you can use an Ohmmeter (or a multimeter in Ohmmeter mode) to check 
 * the circuit paths from each pin of the IC socket. The text file named 
 * @c SignalDriverMax72xx.pcb.u1 in the PCB Layout/assembly zip-file contains 
 * a listing of the connections to each pin of the IC socket. Here is a 
 * version of the front assembly diagram with the pin numbers indicated.
 *
 * @image latex SignalDriverMax72xx_frontassembly-wpinnos.png "PCB layout of the front assembly with pin numbers" height=2.5in
 * @image html  SignalDriverMax72xx_frontassembly-wpinnos-thumb.png
 * 
 */

#endif // __SIGNALDRIVERBOARD_H

