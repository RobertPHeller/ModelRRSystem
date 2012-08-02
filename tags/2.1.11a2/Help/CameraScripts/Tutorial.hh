* 
* ------------------------------------------------------------------
* Tutorial.hh - Camera scripts tutorial
* Created by Robert Heller on Mon Jan 22 12:34:33 2007
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
*

0 Tutorial
AnyDistance and Closest compute the view angle in both real and scale
units. It also computes the effective scale of the imaging plane, such
as the size of a 35mm slide, which might be used as a transparency for
model window panes or locomotive number boards.

Both programs work the same. The only difference is that Closest uses
the closest effectly focus of the lens and AnyDistance uses a user
specificed focus distance.  Given the input parameters, the distance,
the lens, the scale, and the film size, a diagram is displayed with the
dimensions of the view.  This diagram can be printed using the <Print...>
menu item under the <File> menu.

New lenses can be entered with the <New> menu item under the <File>
menu. The <Open...> and <Save..> menu items can load and save the set of
available lenses.
