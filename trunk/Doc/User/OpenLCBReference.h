// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Mar 11 14:47:43 2016
//  Last Modified : <160312.2050>
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

#ifndef __OPENLCBREFERENCE_H
#define __OPENLCBREFERENCE_H
/** @page openlcb OpenLCB Program Reference
 * The OpenLCB Program is used for configuring OpenLCB nodes and for testing
 * an OpenLCB network.
 * @addindex OpenLCB
 * @addindex CAN
 * @addindex LCC
 * 
 * @section startup Start up
 * When the OpenLCB program starts it connects as a OpenLCB node to a network 
 * of OpenLCB nodes.  This network could be over a CAN bus network or it could
 * be over an Ethernet network using Tcp/Ip, or using some other form of 
 * networked interconnection.  It could also be be using several different 
 * interconnection network technologies.
 * @subsection cliopts Command Line Options
 * The OpenLCB program takes some command line options that define how it will 
 * connect to other OpenLCB nodes.  These command line options are:
 * @arg -transportname The name of the transport constructor.  A shell wildcard
 * is allowed (but needs to be quoted or escaped).
 * @arg -listconstructors Print a list of available constructors and exit.
 * @arg -help Print a short help message and exit.
 * @par
 * 
 * Additional options, specific to the transport constructor can also be 
 * specified.
 * @subsection guistart GUI Startup
 * If the command line options are not specified or not fully specified, the
 * program uses dialog boxes to gather the necessary options it needs to 
 * connect.  The first dialog box selects the transport constructor to use.
 * It looks like this:
 * @image latex OpenLCB_SelectTransport.png "OpenLCB Transport Selection Dialog" width=4in
 * @image html OpenLCB_SelectTransport.png
 * After selecting the transport constructor, the options for the transport 
 * constructor are selected with a constructor specific dialog box.  The dialog
 * box for the Grid Connect CAN over USBSerial one looks like this:
 * @image latex OpenLCB_CANGCUSB_Options.png "Grid Connect CAN over USBSerial Options Dialog" width=4in
 * @image html OpenLCB_CANGCUSB_Options.png
 * Once the transport constructor and its options are selected the program 
 * starts and displays the main windor.
 * @section maingui Main GUI Elements
 * The main window of the application contains a list of nodes on the 
 * network(s) it is connected to.  This looks like this:
 * @image latex OpenLCB_MainWindow.png "OpenLCB Main Window, with the node trees closed" width=5in
 * @image html OpenLCB_MainWindow.png
 * Each node is listed by Node ID.  The node trees can be opened to reveal 
 * both the simple node information as well as the supported protocols, as 
 * shown here:
 * @image latex OpenLCB_MainWindow_OpenTrees.png "OpenLCB Main Window, with the node trees opened" width=5in
 * @image html OpenLCB_MainWindow_OpenTrees.png
 * The Memory Configuration and CDI protocol items can be clicked to open up
 * configuration tools.
 * @subsection conf Configuration Tools
 * There are two configuration tools available.  A simple memory read/write 
 * tool and a structured configuration tool that uses a GUI generated from the
 * CDI information supplied by the node itself.
 * @subsubsection ConfigOptions Memory Configuration Options
 * The simple memory read/write tool provides a map of what sorts of memory
 * is available to be configured.  This dialog box looks like this:
 * @image latex OpenLCB_MemoryConfigOpts.png "Memory Configuration Options Display Dialog Box" width=4in
 * @image html  OpenLCB_MemoryConfigOpts.png
 * @subsubsection ConfigMemory Configuration R/W Tool
 * The  simple memory read/write tool is just a simple tool that reads and 
 * writes a block of up to 64 bytes of memory.  The tool looks like this:
 * @image latex OpenLCB_ReadWriteConfigMemory.png "Memory Read/Write Configuration tool" width=4in
 * @image html OpenLCB_ReadWriteConfigMemory.png
 * @subsubsection ConfigurationEditor CDI Configuration Tool
 * The other memory configuration tool uses the node supplied XML coded CDI to
 * define the structure of the node's configuration memory.  It creates a 
 * node specific configuration window.  Here is the one created for a 
 * RR-Cirkits Tower-LLC node:
 * @image latex OpenLCB_CDITool.png "A CDI-based configuration screen for a RR-Cirkits Tower-LLC node" width=5in
 * @image html OpenLCB_CDITool.png
 * @subsection event Event Tools
 * In addition to configuring memory, the OpenLCB can be used to manually 
 * insert event reports and to monitor the network for event production.
 * @subsubsection sendevent Send Event Tool
 * Under the @c File menu there is a @b Send @b Event menu item.  This menu 
 * item pops up the send event dialog box, which looks like:
 * @image latex OpenLCB_SendEvent.png "Send Event Dialog Box" width=4in
 * @image html OpenLCB_SendEvent.png
 * This dialog box can be used to send events manually to test node consumption
 * of the sent events.
 * @subsubsection receivedevent Received Events
 * Additionally, if a node on the network generates an event, the OpenLCB 
 * program will display the event in a dialog box like this:
 * @image latex OpenLCB_EventReceived.png "Event Received popup dialog box" width=4in
 * @image html OpenLCB_EventReceived.png
 */

#endif // __OPENLCBREFERENCE_H

