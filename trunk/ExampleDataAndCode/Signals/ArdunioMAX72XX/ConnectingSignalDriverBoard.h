// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Jul 26 21:13:07 2015
//  Last Modified : <150727.2119>
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

#ifndef __CONNECTINGSIGNALDRIVERBOARD_H
#define __CONNECTINGSIGNALDRIVERBOARD_H
/** @page ConnectingSignalDriverBoard Connecting the Signal Driver Board
 * 
 * The Signal Driver board is connected with a home made connector cable.  The 
 * cable is a six conductor ribbon cable (<a href="http://www.digikey.com/product-search/en?x=16&y=14&keywords=MC06G-25-ND" target="_blank">DigiKey part number MC06G-25-ND</a>). 
 * One end of the cable is attached to a 6-pin .1 inch (2.54mm) IDC header 
 * plug and the other end connected to a "plug" made from a small piece of 
 * strip-board and a couple of pieces of .1 inch (2.54mm) pitch breakaway 
 * headers, 2 pins at the power and ground end and 3 pins at the digital I/O 
 * end. Some of foil should be removed (this prevents possible shorts). The 
 * cable is soldered to the foil side and the headers are mounted on the 
 * component side.  The cable is secured with a wire tie and some hot glue. 
 * This connector fits on top of the Arduino Uno as shown.  Make sure the pins 
 * are in the correct header position!
 * 
 * @image latex ComponentsideofUnoconnector.jpg "Component side of Uno connector" width=4in
 * @image html  ComponentsideofUnoconnector-thumb.jpg "Component side of Uno connector"
 * @image latex UnoConnector_FoilSide.jpg "Uno Connector, Foil Side" width=4in
 * @image html  UnoConnector_FoilSide-thumb.jpg "Uno Connector, Foil Side"
 * @image latex connector_on_Uno.jpg "Connector on Uno" width=4.5in
 * @image html  connector_on_Uno-thumb.jpg "Connector on Uno"
 * 
 * The IDC plug is attached to the other end and I used an Exacto Knife to 
 * press the wires into the IDC slots.  Mouser sells a 
 * <a href="http://www.mouser.com/Search/ProductDetail.aspx?R=59803-1virtualkey57100000virtualkey571-598031" target="_blank">$30 tool</a> 
 * to do this, if you prefer.
 * 
 * @image latex ConnectorPlug_Installed.jpg "Connector Plug, Installed" width=3in
 * @image html  ConnectorPlug_Installed-thumb.jpg "Connector Plug, Installed"
 * @image latex InstallingConnectorPlugs.jpg "Installing Connector Plugs" width=3in
 * @image html  InstallingConnectorPlugs-thumb.jpg "Installing Connector Plugs"
 * @htmlonly
 * <div class="contents"><a class="el" href="SignalDriverboardcables.html">Continuing with the Signal Driver board cables</a></div>
 * @endhtmlonly
 */

#endif // __CONNECTINGSIGNALDRIVERBOARD_H

