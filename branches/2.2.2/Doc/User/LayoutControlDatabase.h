// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Thu Mar 2 12:02:19 2023
//  Last Modified : <230302.1338>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2023  Robert Heller D/B/A Deepwoods Software
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

#ifndef __LAYOUTCONTROLDATABASE_H
#define __LAYOUTCONTROLDATABASE_H

/** @page LayoutControlDatabase Layout Control Database
 * This database is an XML file containing a mapping of Layout Control elements
 * and LCC Event Ids.  The database contains turnouts, blocks, signals, 
 * sensors, and controls.  The 
 * @ref LayoutDB2JMRITable "LayoutDB to JMRI Tables converter" program can 
 * convert a Layout Control Database to a JMRI Table file.
 * 
 * @section LCDBturnout Turnouts
 * The @c turnout tag describes a turnout.  Child tags include:
 * - @c name This holds the name of the turnout.
 * - @c motor This holds the motor event ids (consumed by the turnout).
 *   Under the motor tag are two child tags:
 *     - @c normal  This holds the normal event id.
 *     - @c reverse This holds the reverse event id.
 * - @c points This holds the points sense event ids (produced by the turnout).
 *   Under the points tag are two child tags:
 *     - @c normal  This holds the normal event id.
 *     - @c reverse This holds the reverse event id.
 * 
 * @section LCDBblock   Blocks
 * The @c block tag describes a block.  Child tags include:
 * - @c name This holds the name of the block.
 * - @c occupied This holds the (produced) occupied event id,
 * - @c clear    This holds the (produced) clear event id,
 * 
 * @section LCDBsignal  Signals
 * The @c signal tag describes a signal. Child tags include:
 * - @c name This holds the name of the signal.
 * - @c aspect This holds an aspect of the signal. A signal can have zero or 
 *      more of these tags. Child tags include:
 *     - @c name This holds the name of the aspect.
 *     - @c event This holds the (consumed) event id to set the aspect.
 *     - @c look This contains the look of the aspect, typicaly a list of 
 *          colors.
 *      
 * @section LCDBsensor  Sensors
 * The @c sensor tag describes a generic sensor. Child tags include:
 * - @c name This holds the name of the sensor.
 * - @c on This holds the (produced) event id when the sensor goes on (is
 *      activated).
 * - @c off This holds the (produced) event id when the sensor goes off (is
 * *      deactivated).
 * @section LCDBcontrol Controls
 * The @c control tag describes a generic control. Child tags include:
 * - @c name This holds the name of the sensor. 
 * - @c on This holds the (consumed) event id to turn the control on
 *      (activate).
 * - @c off  This holds the (consumed) event id to turn the control off
 *      (deactivated).
 */

#endif // __LAYOUTCONTROLDATABASE_H

