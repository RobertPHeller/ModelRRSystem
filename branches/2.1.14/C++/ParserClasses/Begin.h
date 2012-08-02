/* 
 * ------------------------------------------------------------------
 * Begin.h - Beginning of internals documentation.
 * Created by Robert Heller on Sun Nov  6 11:06:11 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
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
 * $Id$
 *  
 */

/** @name File-based parser classes.
  * @doc
  * \TEX{\typeout{Generated from $Id$.}}
  *
  * These are file-based parser classes.  Right now only one parser for XTrkCAD
  * layout files.  Other classes might be added later.
  *
  * Included are classes used by the XTrkCAD parser.  These classes are used to
  * store the track plan information in an XTrkCAD layout file, specificly
  * as it relates to operating issues, such as dispatching and signaling.
  *
  * The track plan is loaded into a directed graph representation, where each
  * node is one logical piece of trackwork.  From this graph representation
  * a schematic display could be created in a semi-automated way.
  */
 
//@{
