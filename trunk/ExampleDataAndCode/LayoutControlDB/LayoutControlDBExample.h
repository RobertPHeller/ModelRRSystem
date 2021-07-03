// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sat Jul 3 10:34:34 2021
//  Last Modified : <210703.1318>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2021  Robert Heller D/B/A Deepwoods Software
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

#ifndef __LAYOUTCONTROLDBEXAMPLE_H
#define __LAYOUTCONTROLDBEXAMPLE_H

/** @page LayoutControlDBExample Layout Control DB Example
 * This example illustrates how to use the Layout Control DB to create a CTC
 * panel node program using Dispatcher to control a turnout controled from
 * I/O lines of a Tower-LCC using a "hands off" approach to the LCC Event IDs.
 * 
 * The turnout uses three I/O lines of a Tower-LCC:
 *  - Line 1 controls the switch motor and is an output (Consumer)
 *  - Line 2 provides the point sense and is an input (Producer)
 *  - Line 9 provides the occupancy detection of the OS section (Producer)
 *
 * @section capture Capturing the eventids from the Tower-LCC
 * 
 * The first step is to capture the event ids and create a database (in an
 * XML file) of the turnout.  The database we will create will only have just
 * one turnout for this example, but the database could be much more extensive,
 * 
 * First we start up OpenLCB and open the CDI Configuration tool.  Line 1 looks
 * like this:
 * @image html Initial.png
 * @image latex Initial.png "Initial line1 tab" width=5in
 *
 * The first thing to do is copy the name:
 * @image html NameCopied.png
 * @image latex  NameCopied.png "Copied the name of the turnout" width=5in
 * 
 * Then the turnout motor drive events are copied:
 * @image html CopiedMotorEvent1.png
 * @image latex CopiedMotorEvent1.png "Copied motor event 1" width=5in
 * @image html CopiedMotorEvent2.png
 * @image latex CopiedMotorEvent2.png "Copied motor event 2" width=5in
 * 
 * Next the point sense events from line 2 are copied:
 * @image html CopiedPointSense1.png
 * @image latex CopiedPointSense1.png "Copied point sense 1" width=5in
 * @image html CopiedPointSense2.png
 * @image latex CopiedPointSense2.png "Copied point sense 2" width=5in
 * 
 * After hitting the Add button, we repeat the process for the OS section 
 * block:
 * 
 * @image html NameCopied2.png
 * @image latex NameCopied2.png "Copy OS block name" width=5in
 * @image html CopiedOccupied.png
 * @image latex CopiedOccupied.png "Copy occupied event" width=5in
 * @image html CopiedClear.png
 * @image latex CopiedClear.png "Copy clear event" width=5in
 * 
 * After hitting the Add button, we can look at the Layout Control database:
 * 
 * @image html LayoutDB.png
 * @image latex LayoutDB.png "Layout Control DB, showing two elements" width=5in
 * 
 * @section panel Next we use the layout control DB to build a CTC Panel
 * 
 * After loading the layout control database, we create a new CTC Panel:
 * @image html CreatingCTCPanel.png
 * @image latex CreatingCTCPanel.png "Create new CTC Panel" width=5in
 * 
 * Then we create the switch:
 * @image html CreateTurnout1-Start.png
 * @image latex CreateTurnout1-Start.png "Start creating the  turnout" width=5in
 * 
 * Next we select the turnout from the layout control dropdown, fix the name 
 * (delete the disallowed spaces), add in the control point.
 * @image html CreateTurnout1Initialized.png
 * @image latex CreateTurnout1Initialized.png "Turnout1 started"  width=5in
 * 
 * Now we need to capture the OS block detection, using the event context menu:
 * @image html EventContextMenu.png
 * @image latex EventContextMenu.png "Event context menu" width=5in
 * @image html OSFilled.png
 * @image latex OSFilled.png "OS block detection filled in"  width=5in
 * 
 * We use the cross hairs to position the turnout and then move on to the 
 * switch plate and then the code button.
 * @image html CreatePlate1.png
 * @image latex CreatePlate1.png "Create the switch plate"  width=5in
 * 
 * @image html CreateCodeButton.png
 * @image latex CreateCodeButton.png "Create the Code button"  width=5in
 * 
 * Now we can save the panel.  The panel file and the layout db XML file are
 * included in this example directory.
 * 
 */

#endif // __LAYOUTCONTROLDBEXAMPLE_H

