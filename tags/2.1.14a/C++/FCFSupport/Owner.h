/* 
 * ------------------------------------------------------------------
 * Owner.h - Owners
 * Created by Robert Heller on Sun Aug 28 13:05:13 2005
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

#ifndef _OWNER_H_
#define _OWNER_H_

#ifndef SWIG
#include <Common.h>
#endif

/** \TEX{\typeout{Generated from $Id$.}}
  * The Owner class describes a car owner.  A car owned has a set of (three
  * letter) initials, a full name, and an (optional) comment.  This information
  * is just used for informational purposes.
  */
class Owner {
public:
#ifndef SWIG
	/** The default constructor initializes all fields to the empty string.
	  */
	Owner() {initials = "";name = ""; comment = "";}
	/** The copy constructor copies the contents of another Owner to this
	  * one.
	  *  @param other The other Owner object.
	  */
	Owner(Owner &other) {
		initials = other.initials;
		name = other.name;
		comment = other.comment;
	}
	/** The Assignment operator copies the contents of another Owner
	  * to this one.
	  *  @param other The other Owner object.
	  */
	Owner & operator= (Owner &other) {
		initials = other.initials;
		name = other.name;
		comment = other.comment;
		return *this;
	}
#endif
	/** The full constructor initalizes the class instance from user
	  * supplied parameters.
	  *  @param i The owner's initials.
	  *  @param n The owner's name.
	  *  @param c Commentary about this owner.
	  */
	Owner(const char *i,const char *n,const char *c) {
		initials = i;
		name = n;
		comment = c;
	}
	/** The destructor does nothing special.
	  */
	~Owner() {}
	/** Return this owner's initials.
	  */
	const char *Initials() const {return initials.c_str();}
	/** Return this owner's name.
	  */
	const char *Name() const {return name.c_str();}
	/** Return commentary about this owner.
	  */
	const char *Comment() const {return comment.c_str();}
#ifndef SWIG
private:
	/** This owner's initials.
	  */
	string initials;
	/** This owner's name.
	  */
	string name;
	/** Commentary about this owner.
	  */
	string comment;
#endif
};

#ifndef SWIG
/** @name OwnerMap
  * Map of owners, indexed by their initials.
  */
typedef map<string, Owner *, less<string> > OwnerMap;
#endif

#endif // _OWNER_H_

