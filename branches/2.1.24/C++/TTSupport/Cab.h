/* 
 * ------------------------------------------------------------------
 * Cab.h - Cab class definitions
 * Created by Robert Heller on Wed Dec 21 12:34:49 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2006/05/17 23:42:36  heller
 * Modification History: May 17, 2006 Lock down
 * Modification History:
 * Modification History: Revision 1.1  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
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
#ifndef _CAB_H_
#define _CAB_H_

#ifndef SWIG
#include <Common.h>
#include <iostream>
#endif

/** @addtogroup TimeTableSystem
  * @{
  */

namespace TTSupport {
  
/** @defgroup Cab  Cab
  * @brief Cab class and support types.
  *
  * This only really important for pure DC systems, but it useful for DCC
  * systems as a way define crew(s).
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  * @{
  */


/** This class maintains information about cabs.
  * A cab has a color and a name.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class Cab {
public:
#ifdef SWIG
	Cab(const char *name = "",const char *color = "");
#else
	/** Construct a new cab.
	  *  @param name_ The name of the new cab.
	  *  @param color_ The color of the cab.
	  */
	Cab(string name_ = "", string color_ = "") {
		name = name_;
		color = color_;
	}
#endif
	/** Clean things up.
	  */
	~Cab() {}
	/** Return the name of the cab.
	  */
	const char *Name() const {return name.c_str();}
	/** Return the color of the cab.
	  */
	const char *Color() const {return color.c_str();}
#ifndef SWIG
	/** Copy constructor.  Create a new cab as a copy of an existing cab.
	  *   @param other The other cab.
	  */
	Cab(const Cab &other) {
		name = other.name;
		color = other.color;
	}
	/** Assignment operator.  Assign one cab to another cab.
	  *   @param other The other cab.
	  */
	Cab & operator = (const Cab &other) {
		name = other.name;
		color = other.color;
	}
	/** Write object to a stream.
	  *   @param stream Stream to write to.
	  */
	ostream & Write(ostream & stream) const;
	/** Read an object from a stream.
	  *   @param stream Stream to read from.
	  */
	istream & Read(istream & stream);
private:
	/** The name of the cab.
	  */
	string name;
	/** The color of the cab.
	  */
	string color;
#endif
};

#ifndef SWIG
/** Cab name map, cabs indexed by name.
  */
typedef map<string, Cab *, less<string> > CabNameMap;
#endif


/** @} */

};

/** @} */
	                    
#endif // _CAB_H_

