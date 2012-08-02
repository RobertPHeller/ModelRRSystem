/* 
 * ------------------------------------------------------------------
 * System_CarEdit.cc - Car editing functions
 * Created by Robert Heller on Sat Oct 15 12:07:54 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:34  heller
 * Modification History: Nov 4, 2005 Lockdown
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

static char Id[] = "$Id$";

#include <System.h>

/*************************************************************************
 *                                                                       *
 * Returns a vector of car indexes that have matching number substrings. *
 *                                                                       *
 *************************************************************************/

vector<int> System::SearchForCarIndexesByNumber(string number,bool subStringP) const
{
	vector<int> result;
	CarVector::const_iterator Cx;
	const Car *car;

	/* For every car... */
	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	  if ((car = *Cx) == NULL) continue;	// Empty slot -- skip it.
	  /* Substring matching? */
	  if (subStringP) {
	    /* Match against the rightmost digits */
	    int off = car->number.size() - number.size();
	    if (off < 0) off = 0;
	    if (number == car->number.substr(off)) {	// Match?
	      result.push_back(Cx - cars.begin());	// Yes!
	    }
	  } else {		// Whole number matching
	    if (number == car->number) {		// Match?
	      result.push_back(Cx - cars.begin());	// Yes!
	    }
	  }
	}
	return result;
}
