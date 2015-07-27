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
//  Last Modified : <150726.2119>
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
 * [caption id="attachment_815" align="alignleft" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_bare.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_bare-150x150.jpg" alt="Signal Connector Board, bare" width="150" height="150" class="size-thumbnail wp-image-815" /></a> Signal Connector Board, bare[/caption][caption id="attachment_816" align="alignleft" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_copperremoved.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_copperremoved-150x150.jpg" alt="Signal Connector Board, copper removed" width="150" height="150" class="size-thumbnail wp-image-816" /></a> Signal Connector Board, copper removed[/caption][caption id="attachment_817" align="alignright" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_holesdrilled.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_holesdrilled-150x150.jpg" alt="Signal Connector Board, holes drilled" width="150" height="150" class="size-thumbnail wp-image-817" /></a> Signal Connector Board, holes drilled[/caption]<p>Nine conductor ribbon cables (<a href="http://www.digikey.com/product-search/en?x=16&y=14&keywords=MC09G-25-ND" target="_blank">DigiKey part number MC09G-25-ND</a>) is used to connect between the Signal Driver Board and the signals.  One end gets a 9-pin header plug and the other end gets a small circuit board with small screw terminals.  The actual LEDs in the signals are connected to wire wrap wire, but wire wrap wire is too delicate to run long distances, but is needed to fit in the small brass tubes the signal targets are mounted on.  Once under the layout bench-work, the wire wrap wire gets connected with screw terminals to the much more robust ribbon cable.  The small circuit boards are again made from pieces of strip-board, with nine strips, eleven holes long. After cutting the boards, some of the copper is removed and four 1/8 inch (3.5mm) holes are drilled.</p><br clear="all" />
 * [caption id="attachment_819" align="alignleft" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_terminalblocksinstalled.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_terminalblocksinstalled-150x150.jpg" alt="Signal Connector Board, terminal blocks installed" width="150" height="150" class="size-thumbnail wp-image-819" /></a> Signal Connector Board, terminal blocks installed[/caption][caption id="attachment_820" align="alignleft" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorCable_wiresstripedandtinned.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorCable_wiresstripedandtinned-150x150.jpg" alt="Signal Connector Cable, wires stripped and tinned" width="150" height="150" class="size-thumbnail wp-image-820" /></a> Signal Connector Cable, wires stripped and tinned[/caption][caption id="attachment_821" align="alignleft" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_cablesolderedon.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_cablesolderedon-150x150.jpg" alt="Signal Connector Board, cable soldered on" width="150" height="150" class="size-thumbnail wp-image-821" /></a> Signal Connector Board, cable soldered on[/caption][caption id="attachment_822" align="alignright" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_cablesecuredwithwiretie.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorBoard_cablesecuredwithwiretie-150x150.jpg" alt="Signal Connector Board, cable secured with wire tie" width="150" height="150" class="size-thumbnail wp-image-822" /></a> Signal Connector Board, cable secured with wire tie[/caption]<p>Next the screw terminal blocks are soldered to the board (this is actually a 4 position terminal block with a 5 position terminal block next to it -- Mouser does not stock the 9 position version of these terminal blocks).  Then the conductors at one end of the cable is zipped back about a 3/4 inch (18mm) and about 1/4 inch (6mm) of the ends are stripped and tinned. These tinned conductors are then fed into holes in the circuit board and soldered. Finally a wire tie is used to secure the cable and act as a strain relief.</p><br clear="all" />
 * [caption id="attachment_824" align="alignright" width="150"]<a href="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorCable_headerpluginstalled.jpg"><img src="http://www.deepsoft.com/~heller/wp-content/uploads/2015/02/SignalConnectorCable_headerpluginstalled-150x150.jpg" alt="Signal Connector Cable, header plug installed" width="150" height="150" class="size-thumbnail wp-image-824" /></a> Signal Connector Cable, header plug installed[/caption]<p>Finally, a 9 position header plug is installed on the other end of the cable.</p>
 * <p>About cable lengths: each cable should be long enough to reach from where the signal wire bundles emerge under the layout to where the Signal Driver Board is mounted.  It is always better to cut the ribbon cables longer than needed since excess cable can be managed in various ways, but a short cable is not useable. The length of the wire wrap wires should be as short as you can get away with, which means the terminal block ends should be as close as possible to the place where the signal wire bundles emerge under the layout.</p><br clear="all" />
 * <p>Continuing with <a href="http://www.deepsoft.com/~heller/2015/03/model-rr-signals-with-an-arduino-assembling-signal-targets/">Model RR signals with an Arduino, Assembling signal targets</a>.</p>
 */

#endif // __SIGNALDRIVERBOARDCABLES_H

