/* 
 * ------------------------------------------------------------------
 * Division.h - Division class
 * Created by Robert Heller on Thu Aug 25 09:04:00 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:20  heller
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

#ifndef _DIVISION_H_
#define _DIVISION_H_

#ifndef SWIG
#include <Common.h>
#include <Station.h>
#endif

/** @addtogroup FCFSupport
  * @{
  */

namespace FCFSupport {

#ifndef SWIG
class System;
class Industry;
#endif

/** @brief The Division class implements a single division, which contains a number of
  *  contigious stations.
  *
  * A division has a name, a symbol, an area, a home yard,and a list of 
  * stations.
  *
  *	@author Robert Heller \<heller\@deepsoft.com\>
  */
class Division {
public:
#ifndef SWIG
	/** Default constructor.  All fields are initialized to empty or NULL
	  * values.
	  */
	Division() {name = (char *)""; home = NULL; symbol = '\0'; area = '\0';}
	/** Copy constructor.  A new division is created as a copy of an
	  * existing division.
	  * @param other The other division.
	  */
	Division(Division &other) {
		name = other.name;
		home = other.home;
		symbol = other.symbol;
		area = other.area;
		stations = other.stations;
	}
	/** Assignment operator.  Copy one division to another.
	  * @param other The other division.
	  */
	Division & operator= (Division & other) {
		name = other.name;
		home = other.home;
		symbol = other.symbol;
		area = other.area;
		stations = other.stations;
		return *this;
	}
#endif
	/** Constructor given a set of field values.
	  *  @param s The division's symbol.
	  *  @param h The division's home yard.
	  *  @param a The division's area.
	  *  @param n The division's name.
	  */
	Division(char s,FCFSupport::Industry * h,char a, const char *n)
	{
		name = n;
		home = h;
		symbol = s;
		area = a;
	}
	/** Destructor.
	  */
	~Division() {}
	/** Return the division's name.
	  */
	const char *Name() const {return name.c_str();}
	/** Return the division's home yard.
	  */
	FCFSupport::Industry * Home() const {return home;}
	/** Return the division's Symbol.
	  */
	char Symbol() const {return symbol;}
	/** Return the division's area.
	  */
	char Area() const {return area;}
	/** Return the number of stations in this division.
	  */
	int NumberOfStations () const {return stations.size();}
	/** Return a selected station in the division.
	  *  @param i The station index.
	  */
	const FCFSupport::Station *TheStation(int i) const {
		if ((unsigned)i < stations.size() && i >= 0) return stations[i];
		else return NULL;
	}
	/** Append an additional station to this division.
	  *  @param station The station to append.
	  */
	void AppendStation (FCFSupport::Station *station) {
		stations.push_back(station);
	}
#ifndef SWIG
	/** The System class is a friend.
	  */
	friend class System;
private:
	/** The name of the division.
	  */
	string name;
	/** The vector of stations in the division.
	  */
	StationVector stations;
	/** The division's home yard.
	  */
	Industry *home;
	/** The division's symbol.
	  */
	char symbol;
	/** The division's area.
	  */
	char area;
#endif
};

#ifndef SWIG
/** A vector of divisions.
  */
typedef vector<Division *> DivisionVector;
/** A map of divisions, by integer index (division index).
  */
typedef map<int, Division *, less<int> > DivisionMap;
/** A map of divisions, by division symbol (a character).
  */
typedef map<char, Division *, less<char> > DivisionSymbolMap;
#endif

} // namespace FCFSupport

/** @} */

#endif // _DIVISION_H_

