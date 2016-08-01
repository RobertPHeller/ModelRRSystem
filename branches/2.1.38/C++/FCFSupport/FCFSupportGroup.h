/* 
 * ------------------------------------------------------------------
 * Begin.h - Beginning of FCF Section
 * Created by Robert Heller on Sun Nov  6 11:23:31 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:20  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
 * 			51 Locke Hill Road
 * 			Wendell, MA 01379-9728
 * 
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 *  
 */

/** @defgroup FCFSupportModule FCFSupportModule
  * @brief Freight Car Forwarder C++ support classes.
  *
  *	These classes implement the low-level support code for my
  *	second port of Tim O'Connor's Freight Car Forwarder system.
  *
  *	The main class, System, implements a complete railroad system, which
  *	consists of one or more divisions with one or more stations and 
  *	industries.  Running over the trackage are one or more trains, pulling
  *	an assortment of cars (some loaded and some empty).  The cars are of
  *	various types, suitable for various types of loads.  The system class 
  *	collects the data for all of these items into one big data structure 
  *	and implements the various algorithms to create a freight car 
  *	forwarding system using switchlists.
  *
  *	The original system was written in QBASIC and was a mess of spaghetti
  *	code.  I first recoded it as a pure Tcl/Tk application and because Tcl
  *	completely lacks a 'goto' statement, I needed to unravel every
  *	strand of 'spaghetti'.  The Tcl code worked, but was somewhat slow.
  *	This C++ version puts the more computationaly intensive (mostly
  *	heavy data indexing logic) into C++, using the STL to implement the
  *	various aggregate collections of objects.  These objects are indexed
  *	and crossed indexed heavily and the forwarding algorithms traverses
  *	these collections frequently.
  *
  *	@author Robert Heller \<heller\@deepsoft.com\>
  */

