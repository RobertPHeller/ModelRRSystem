// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Mar 11 14:43:58 2016
//  Last Modified : <230302.1210>
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

#ifndef __OPENLCB_H
#define __OPENLCB_H
/** @mainpage Table Of Contents
 * @anchor toc
 * @htmlonly
 * <div class="contents">
 * <div class="textblock"><ol type="1">
 * <li><a class="el" href="openlcb.html">OpenLCB Reference</a><ol type="1">
 * <li><a class="el" href="openlcb.html#startup">Start up</a><ol type="1">
 * <li><a class="el" href="openlcb.html#cliopts">Command Line Options</a></li>
 * <li><a class="el" href="openlcb.html#guistart">GUI Startup</a></li>
 * </ol></li><!-- Start up -->
 * <li><a class="el" href="openlcb.html#maingui">Main GUI Elements</a><ol type="1">
 * <li><a class="el" href="openlcb.html#conf">Configuration Tools</a><ol type="1">
 * <li><a class="el" href="openlcb.html#ConfigOptions">Memory Configuration Options</a></li>
 * <li><a class="el" href="openlcb.html#ConfigMemory">Configuration R/W Tool</a></li>
 * <li><a class="el" href="openlcb.html#ConfigurationEditor">CDI Configuration Tool</a></li>
 * </ol></li><!-- Configuration Tools -->
 * <li><a class="el" href="openlcb.html#event">Event Tools</a><ol type="1">
 * <li><a class="el" href="openlcb.html#sendevent">Send Event Tool</a></li>
 * <li><a class="el" href="openlcb.html#receivedevent">Received Events</a></li>
 * </ol></li><!-- Event Tools -->
 * </ol></li><!-- Main GUI Elements -->
 * </ol></li><!-- OpenLCB Reference -->
 * <li><a class="el" href="openlcbdaemons.html">OpenLCB Daemons</a><ol type="1">
 * <li><a class="el" href="openlcbdaemons.html#hubs">Hub Daemons</a></li>
 * <li><a class="el" href="openlcbdaemons.html#vnodes">Virtual Nodes</a><ol type="1">
 * <li><a class="el" href="openlcbdaemons.html#CommonNodeConfiguration">Common Node Configuration</a></li>
 * <li><a class="el" href="openlcbdaemons.html#MRD2">EventExchange node for Azatrax MRD2 boards</a></li>
 * <li><a class="el" href="openlcbdaemons.html#PiGPIO">EventExchange node for Raspberry Pi GPIO pins</a></li>
 * <li><a class="el" href="openlcbdaemons.html#PiMCP23008">EventExchange node for MCP23008 GPIO pins</a></li>
 * <li><a class="el" href="openlcbdaemons.html#PiMCP23017">EventExchange node for MCP23017 GPIO pins</a></li>
 * <li><a class="el" href="openlcbdaemons.html#PiSPIMax7221">EventExchange node for a SPI connected MAX7221 Signal Driver</a></li>
 * <li><a class="el" href="openlcbdaemons.html#TrackCircuits">EventExchange node for virtual track circuits</a></li>
 * <li><a class="el" href="openlcbdaemons.html#Logic">EventExchange node for logic blocks</a></li>
 * <li><a class="el" href="openlcbdaemons.html#Acela">EventExchange node for a CTI Acela network</a></li>
 * </ol></li><!-- Virtual Nodes -->
 * </ol></li><!-- OpenLCB Daemons -->
 * <a class="anchor" id="offlineedit"></a>
 * <li><a class="el" href="openlcbofflineeditor.html">Offline LCC Node Editor Reference</a><ol type="1">
 * <li><a class="el" href="openlcbofflineeditor.html#cliparsopts">Command Line Parameter and Options</a><ol type="1">
 * <li><a class="el" href="openlcbofflineeditor.html#offopts">Command Line Options</a></li>
 * <li><a class="el" href="openlcbofflineeditor.html#offpars">Command Line Parameters</a></li>
 * </ol></li><!-- Command Line Parameters and Options -->
 * <li><a class="el" href="openlcbofflineeditor.html#mainguioffline">Main GUI Elements</a><ol type="1">
 * </ol></li><!-- Main GUI Elements -->
 * </ol></li><!-- Offline LCC Node Editor Reference -->
 * <a class="anchor" id="layoutcontroldb"></a>
 * <li><a class="el" href="LayoutControlDatabase.html">Layout Control Database</a><ol type="1">
 * <li><a class="el" href="LayoutControlDatabase.html#LCDBturnout">Turnouts</a></li>
 * <li><a class="el" href="LayoutControlDatabase.html#LCDBblock">Blocks</a></li>
 * <li><a class="el" href="LayoutControlDatabase.html#LCDBsignal">Signals</a></li>
 * <li><a class="el" href="LayoutControlDatabase.html#LCDBsensor">Sensors</a></li>
 * <li><a class="el" href="LayoutControlDatabase.html#LCDBcontrol">Controls</a></li>
 * </ol></li><!-- Layout Control Database -->
 * <li><a class="el" href="help.html">Help</a></li>
 * <li><a class="el" href="Version.html">Version</a></li>
 * <li><a class="el" href="Copying.html">Copying</a><ol type="a">
 * <li><a class="el" href="Copying.html#Warranty">Warranty</a></li>
 * </ol></li><!-- Copying -->
 * </ol></div></div><!-- Contents -->
 * @endhtmlonly
 */

#endif // __OPENLCB_H

