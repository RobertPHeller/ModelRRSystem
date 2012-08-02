/* 
 * ------------------------------------------------------------------
 * Station.h - Station class
 * Created by Robert Heller on Thu Aug 25 09:04:50 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:41:57  heller
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

#ifndef _STATION_H_
#define _STATION_H_

#ifndef SWIG
#include <Common.h>

class Division;
class Industry;
#endif

/** The Station class implements a single station, which exists within a
  * division and contains a number of industries.  A Station has a name,
  * a comment, it belongs to a division, and has a list of industries.
  */
class Station {
public:
#ifndef SWIG
	/** Default constructor.  Initialize all slots to empty values.
	  */
	Station() {name = ""; comment = ""; division = NULL;}
	/** Copy constructor, copy from another station instance.
	  *  @param other The other station instance.
	  */
	Station(const Station &other) {
		name = other.name;
		comment = other.comment;
		industries = other.industries;
		division = other.division;
	}
	/** Assignment operator, copy from another station instance.
	  * @param other The other station instance.
	  */
	Station & operator= (Station &other) {
		name = other.name;
		comment = other.comment;
		industries = other.industries;
		division = other.division;
		return *this;
	}	
#endif	
	/** Full constructor.  Create a fresh station instance, given a name, division,
	  * and a comment.  Initially, the industry list is empty.
	  * @param n The new station's name.
	  * @param d The division the station belongs to.
	  * @param c A comment string.
	  */
	Station(const char *n, Division *d, const char *c) {
		name = n;
		division = d;
		comment = c;
	}
	/** Destructor.
	  */
	~Station() {}
	/** Return the station's name.
	  */
	const char *Name() const {return name.c_str();}
	/** Return the station's division.
	  */
	Division *MyDivision() const {return division;}
	/** Return the station's comment.
	  */
	const char *Comment() {return comment.c_str();}
	/** Return the number of industries at this station.
	  */
	int NumberOfIndustries() const {return industries.size();}
	/** Return the Ith industry at this station.
	  * @param i The industry index.
	  */
	Industry *TheIndustry(int i) const
	{
		if (i < 0 || i >= industries.size()) return NULL;
		else return industries[i];
	}
	/** Append an industry to this station's list of industries.
	  * @param industry The industry to append.
	  */
	int AppendIndustry(Industry * industry) {
		industries.push_back(industry);
		return industries.size()-1;
	}
#ifndef SWIG
	/** The System class is a friend.
	  */
	friend class System;
private:
	/** The station's name.
	  */
	string name;
	/** The station's comment.
	  */
	string comment;
	/** The station's division.
	  */
	Division *division;
	/** The list of industries at this station.
	  */
	vector<Industry *> industries;
#endif
};


#ifndef SWIG
/** @name StationVector
  * A station vector.
  */
typedef vector<Station *> StationVector;
/** @name StationMap
  * A station map by integer index.
  */
typedef map<int, Station *, less<int> > StationMap;
#endif

#endif // _STATION_H_

