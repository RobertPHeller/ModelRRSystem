/* 
 * ------------------------------------------------------------------
 * Dialogs.hh - Dialog box help
 * Created by Robert Heller on Mon Jan 22 13:10:35 2007
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:53  heller
 * Modification History: Lock down for Release 2.1.7
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

0 GetLensSpecDialog
This dialog box is used to gather information about a lens.  Three pieces
of information are collected:

  [Lens Name]        -- The name of the lens.
  [Minimum Focus]    -- The minimum focus of the lens in feet.
  [View Angle]       -- The view angle of the lens, in degrees.

The [Minimum Focus] and [View Angle] are generally part of a lens's
specifications. Be sure to convert to the proper units!
0 PrintCanvasDialog
This dialog box is used to gether information to print a lens view
diagram. First there is the selection of output, to a specified printer
or to a file. Then there is the color mode, the view of the canvas to
print and the position on the page.
