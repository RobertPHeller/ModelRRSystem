/* 
 * ------------------------------------------------------------------
 * Begin.h - Beginning of TT Section
 * Created by Robert Heller on Sun Nov  6 11:23:31 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
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


/** @defgroup TimeTableSystem TimeTableSystem
  * @brief Time Table C++ support class library.
  *
  * This class library handles all of the low-level data structures and
  * processing for the TimeTable (V2) program.  This includes the representation
  * of scheduled trains, the stations they stop at (or go by), and the data
  * needed to generated formatted and printed timetables.
  * 
  * A time table system consists of a vector of stations, which are in the
  * order that the stations exist along the track. There is a map of cabs,
  * a map of trains, a vector of notes, and a hash table of print options
  * also stored in a train system.  In addition, there are some system wide
  * scalar parameter settings.
  * 
  * The Time Table class includes code to read and write itself to a specially
  * formatted text file for storage between editing or processing sessions.
  * The class includes a method to generate a LaTeX file, which can
  * be processed by LaTeX to create a formatted timetable which can
  * be printed.  It is assumed that the @c TimeTable.sty is available for
  * inclusion by the LaTeX system.
  *
  * The ideas and structure of this code was heavily influenced by Bruce
  * Chubb's Kalmbach book, 
  * How to Operate Your Model Railroad.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */

/** Time Table Support Namespace.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */

namespace TTSupport {
};
