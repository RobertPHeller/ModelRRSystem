/* 
 * ------------------------------------------------------------------
 * CarType.h - Car Types and Car Type Groups
 * Created by Robert Heller on Sun Aug 28 10:34:12 2005
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

#ifndef _CARTYPE_H_
#define _CARTYPE_H_

#ifndef SWIG
#include <Common.h>
#endif

/** \TEX{\typeout{Generated from $Id$.}}
  * The CarType class represents a type of railroad car (rolling stock). Car
  * types are represented as a single printable character and have associated
  * with that printable character is a type name and possibly a short commentary.
  *
  * Car types are also collected into groups as well.  
  */
class CarType {
public:
#ifdef SWIG
	/* Some specific constants relating to car types.
	 */
	enum CarTypeConsts {
		// The number of usable car type characters.
		NumberOfCarTypes,
		// The maximum number of car types (based on 7-bit ASCII).
		MaxCarTypes
	};
#else
	/** Some specific constants relating to car types.
	  */
	enum CarTypeConsts {
	/** The number of usable car type characters.
	  */
		NumberOfCarTypes = 91,
	/** The maximum number of car types (based on 7-bit ASCII).
	  */
		MaxCarTypes = 128
	};
#endif
#ifndef SWIG
	/** Default constructor.  Create a default instance.
	  */
	CarType() {comment = ""; type = ""; group = '\0';}
	/** Copy constructor.  Copy a car type from another instance.
	  * @param other The other instance.
	  */
	CarType(CarType & other) {
		comment = other.comment;
		type    = other.type;
		group   = other.group;
	}
	/** Assignment operaror.  Copy a car type from another instance.
	  * @param other The other instance.
	  */
	CarType & operator= (CarType & other) {
		comment = other.comment;
		type    = other.type;
		group   = other.group;
		return *this;
	}
#endif
	/** Full constructor.  Create a fully quallified car type object.
	  * @param c The name of the car type.
	  * @param t The brief commentary about the car type.
	  * @param g The car type's group code.
	  */
	CarType(const char *c, const char *t, char g) {
		comment = c;
		type    = t;
		group   = g;
	}
	/** Destructor.
	  */
	~CarType() {}
	/** Return the car type's commentary.
	  */
	const char *Comment() const {return comment.c_str();}
	/** Return the car type name.
	  */
	const char *Type() const {return type.c_str();}
	/** Return the car type's group code.
	  */
	char  Group() const {return group;}
#ifndef SWIG
	/** The System class is a friend.
	  */	
	friend class System;
private:
	/** The commentary string.
	  */
	string comment;
	/** The type name.
	  */
	string type;
	/** The group code.
	  */
	char group;
#endif
};

#ifndef SWIG
/** @name CarTypeOrderVector
  * A vector of ordered car types.
  */
typedef vector<char> CarTypeOrderVector;
/** @name CarTypeMap
  * A map of car types indexed by type character.
  */
typedef map<char, CarType *, less<char> > CarTypeMap;
#endif

/** Car group class.  Not presently used.
 */
class CarGroup {
public:
#ifdef SWIG
	// Car group constants.
	enum CarGroupConsts {
	// The maximum number of car groups.
		MaxCarGroup
	};
#else
	/** Car group constants.
	  */
	enum CarGroupConsts {
	/** The maximum number of car groups.
	  */
		MaxCarGroup = 16
	};
#endif
#ifndef SWIG
	/** Default constructor.  Initialize all slots to me empty.
	  */
	CarGroup() {group = '\0'; description = "";}
	/** Copy constructor.  Create a car group that is a clone of another.
	  *   @param other The other car group instance.
	  */
	CarGroup(CarGroup &other) {
		group = other.group;
		description = other.description;
	}
	/** Assignment operator.  Create a car group that is a clone of another.
	  *   @param other The other car group instance.
	  */
	CarGroup & operator= (CarGroup &other) {
		group = other.group;
		description = other.description;
		return *this;
	}
#endif
	/** Full constructor.
	  * @param g Car group character code.
	  * @param d Description of this car group.
	  */
	CarGroup(char g, const char *d) {
		group = g;
		description = d;
	}
	/** Return the group code.
	  */
	char Group() const {return group;}
	/** Return the descrition string.
	  */
	const char *Description() const {return description.c_str();}
#ifndef SWIG
private:
	/** The description string.
	  */
	string description;
	/** The car group code.
	  */
	char group;
#endif
};


#endif // _CARTYPE_H_

