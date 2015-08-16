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
//  Last Modified : <150816.1431>
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
/** @mainpage Signal Abstract Types (Classes)
 * 
 * This folder contains a collection of Tcl code to implement signals, using 
 * various methods.
 * 
 * @section SourceFiles Source files
 * 
 * Using Azatrax's SR4's to control signals is illustrated in the file
 * Azatrax_Signals.tcl.  One or two SR4's can control one, two, or three headed
 * signals, either common anode to common cathode.
 * 
 * Using an Ardunio with a MAX72XX LED Driver to control signals is 
 * illustrated in the file ArdunioMAX72XX_Signals.tcl. Upto eight LEDs per 
 * signal is possible, although the code assumes a maximum of six LEDs in
 * a three over three two headed signal.
 * 
 * Using Dr. Bruce Chubb's SMINI or SUSIC/USIC to control signals is 
 * illustrated in the file Chubb_Signals.tcl.  Output ports on these nodes can
 * control one, two, or three headed signals.
 * 
 * Using CTI's Acela Network Bridge with CTI controler boards to control 
 * signals is illustrated in the file CTI_Signals.tcl.
 * 
 * @section common Common methods and functionality
 * 
 * All of the signal type constructors have a common structure. The 
 * constructors take the form:
 *
 * @code
 * typename objectname [optional options]
 * @endcode
 *
 * Eg:
 * 
 * @code
 * azatrax_signals::OneHead3Color cp27w -signalname CP27W -signalsn 040001234
 * @endcode
 * 
 * There is one common option, @c -signalname.  This is the name of the signal
 * object on the track work schematic.  When the signal aspect is changed,
 * the track work symbol is changed to display the signal's new aspect.
 * 
 * There is one common method, @c setaspect, which is used to set the signal's
 * aspect.  For a one headed signal, this method takes a single word (eg a 
 * single element list) that is the signal aspect.  This will be one of the
 * colors red, yellow, green, or dark.  For a two headed signal, this method 
 * takes a list of two elements, each of which is one of the colors red, 
 * yellow, green, or dark.  A three headed signal will take a a list of three
 * elements, each of which is one of the colors red, yellow, green, or dark.
 * It should be noted that not all possible combinations are allowed, only 
 * those aspects that make sense.  This usually means that only one head will 
 * display a color other than red, with the other heads displaying red. That is
 * {red yellow} or {green red} or {red red yellow} are allowed, but not 
 * {green yellow} or {green red yellow}.
 * 
 */

#endif // __MAIN_H

