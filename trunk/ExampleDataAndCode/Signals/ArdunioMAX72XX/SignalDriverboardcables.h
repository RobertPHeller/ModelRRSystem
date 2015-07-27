// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Jul 26 21:18:28 2015
//  Last Modified : <150727.1019>
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

#ifndef __SIGNALDRIVERBOARDCABLES_H
#define __SIGNALDRIVERBOARDCABLES_H
/** @page SignalDriverboardcables Signal Driver board cables
 * 
 * Nine conductor ribbon cables (<a href="http://www.digikey.com/product-search/en?x=16&y=14&keywords=MC09G-25-ND" target="_blank">DigiKey part number MC09G-25-ND</a>) 
 * are used to connect between the Signal Driver Board and the signals.  One 
 * end gets a 9-pin header plug and the other end gets a small circuit board 
 * with small screw terminals.  The actual LEDs in the signals are connected 
 * to wire wrap wire, but wire wrap wire is too delicate to run long 
 * distances, but is needed to fit in the small brass tubes the signal targets 
 * are mounted on.  Once under the layout bench-work, the wire wrap wire gets 
 * connected with screw terminals to the much more robust ribbon cable.  The 
 * small circuit boards are again made from pieces of strip-board, with nine 
 * strips, eleven holes long. After cutting the boards, some of the copper is 
 * removed and four 1/8 inch (3.5mm) holes are drilled.
 * 
 * @image latex SignalConnectorBoard_bare.jpg "Signal Connector Board, bare" height=2in
 * @image html  SignalConnectorBoard_bare-thumb.jpg
 * @image latex SignalConnectorBoard_copperremoved.jpg "Signal Connector Board, copper removed" height=2in
 * @image html  SignalConnectorBoard_copperremoved-thumb.jpg
 * @image latex SignalConnectorBoard_holesdrilled.jpg "Signal Connector Board, holes drilled" height=2in
 * @image html  SignalConnectorBoard_holesdrilled-thumb.jpg
 * 
 * Next the screw terminal blocks are soldered to the board (this is actually 
 * a 4 position terminal block with a 5 position terminal block next to it -- 
 * Mouser does not stock the 9 position version of these terminal blocks).  
 * Then the conductors at one end of the cable is zipped back about a 3/4 inch 
 * (18mm) and about 1/4 inch (6mm) of the ends are stripped and tinned. These 
 * tinned conductors are then fed into holes in the circuit board and 
 * soldered. Finally a wire tie is used to secure the cable and act as a 
 * strain relief.
 * 
 * @image latex SignalConnectorBoard_terminalblocksinstalled.jpg "Signal Connector Board, terminal blocks installed" height=2in
 * @image html  SignalConnectorBoard_terminalblocksinstalled-thumb.jpg
 * @image latex SignalConnectorCable_wiresstripedandtinned.jpg "Signal Connector Cable, wires stripped and tinned" height=2in
 * @image html  SignalConnectorCable_wiresstripedandtinned-thumb.jpg
 * @image latex SignalConnectorBoard_cablesolderedon.jpg "Signal Connector Board, cable soldered on" height=2in
 * @image html  SignalConnectorBoard_cablesolderedon-thumb.jpg
 * @image latex SignalConnectorBoard_cablesecuredwithwiretie.jpg "Signal Connector Board, cable secured with wire tie" height=2in
 * @image html  SignalConnectorBoard_cablesecuredwithwiretie-thumb.jpg
 * 
 * Finally, a 9 position header plug is installed on the other end of the 
 * cable.
 * 
 * @image latex SignalConnectorCable_headerpluginstalled.jpg "Signal Connector Cable, header plug installed" height=2in
 * @image html  SignalConnectorCable_headerpluginstalled-thumb.jpg
 * 
 * About cable lengths: each cable should be long enough to reach from where 
 * the signal wire bundles emerge under the layout to where the Signal Driver 
 * Board is mounted.  It is always better to cut the ribbon cables longer than 
 * needed since excess cable can be managed in various ways, but a short cable 
 * is not useable. The length of the wire wrap wires should be as short as you 
 * can get away with, which means the terminal block ends should be as close 
 * as possible to the place where the signal wire bundles emerge under the 
 * layout.
 * @htmlonly
 * <div class="contents"><a class="el" href="Assemblingsignaltargets.html">Continuing with the Assembling signal targets</a></div>
 * @endhtmlonly
 */

#endif // __SIGNALDRIVERBOARDCABLES_H

