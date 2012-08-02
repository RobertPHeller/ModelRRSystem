/* 
 * ------------------------------------------------------------------
 * Cab.h - Cab class definitions
 * Created by Robert Heller on Wed Dec 21 12:34:49 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

/** @name  Cab class and support types.
    @doc  \TEX{\typeout{Generated from $Id$.}} */

//@{

/// This class maintains information about cabs.
class Cab {
public:
#ifdef SWIG
	Cab(const char *name = "",const char *color = "");
#else
	/// Construct a new cab.
	Cab(string name_ = "", string color_ = "") {
		name = name_;
		color = color_;
	}
#endif
	/// Clean things up.
	~Cab() {}
	/// Return the name of the cab.
	const char *Name() const {return name.c_str();}
	/// Return the color of the cab.
	const char *Color() const {return color.c_str();}
#ifndef SWIG
	/// Copy a cab.
	Cab(const Cab &other) {
		name = other.name;
		color = other.color;
	}
	/// Assignment operator.
	Cab & operator = (const Cab &other) {
		name = other.name;
		color = other.color;
	}
	ostream & Write(ostream & stream) const;
	istream & Read(istream & stream);
private:
	/// The name of the cab.
	string name;
	/// The color of the cab.
	string color;
#endif
};

#ifndef SWIG
/// Cab name map.
typedef map<string, Cab *, less<string> > CabNameMap;
#endif


//@}
	                    
#endif // _CAB_H_

