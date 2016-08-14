// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Aug 14 14:40:15 2016
//  Last Modified : <160814.1531>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
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

#ifndef __OPENLCBDAEMONS_H
#define __OPENLCBDAEMONS_H

/** @page openlcbdaemons OpenLCB Daemons (Hubs and Virtual nodes)
 * A number of OpenLCB daemons are provided by the Model Railroad System.
 * These daemons provide operational OpenLCB functionallity, including 
 * providing hubs and gateways for both real physical nodes and virtual nodes,
 * along with several virtual nodes.
 * 
 * @section hubs Hub Daemons
 * There are two hub daemons that implement a OpenLCB network over Tcp/Ip and
 * connect CAN busses connected to different host computers connected via 
 * Tcp/Ip over Ethernet.  These daemons are:
 *   - \ref OpenLCBTcpHub
 *     The OpenLCBTcpHub daemon implememts the binary OpenLCB messaging 
 *     protocol over Tcp/Ip.
 *   - \ref OpenLCBGCTcpHub
 *     The OpenLCBGCTcpHub daemon implememts the OpenLCB messaging using the
 *     GridConnect protocol over both Tcp/Ip and using the CAN Bus over a 
 *     USB/Serial connection.
 * 
 * @section vnodes Virtual Nodes
 * There are three virtual nodes that implement OpenLCB nodes to provide
 * useful functions.  There daemons are:
 *   - \ref OpenLCB_MRD2
 *     The OpenLCB_MRD2 daemon implememts an OpenLCB node that implements
 *     the EventExchange protocol for Azatrax MRD2 boards.
 *   - \ref OpenLCB_PiGPIO
 *     The OpenLCB_PiGPIO daemon implememts an OpenLCB node that implements
 *     the EventExchange protocol for Raspberry Pi GPIO pins.
 *   - \ref OpenLCB_TrackCircuits
 *     The OpenLCB_TrackCircuits daemon implememts an OpenLCB node that 
 *     implements virtual track circuit messaging logic using OpenLCB Events.
 * 
 * 
 */

#endif // __OPENLCBDAEMONS_H

