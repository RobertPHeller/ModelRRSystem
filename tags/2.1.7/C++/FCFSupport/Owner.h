/* 
 * ------------------------------------------------------------------
 * Owner.h - Owners
 * Created by Robert Heller on Sun Aug 28 13:05:13 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

///
class Owner {
public:
#ifndef SWIG
///
	Owner() {initials = "";name = ""; comment = "";}
///
	Owner(Owner &other) {
		initials = other.initials;
		name = other.name;
		comment = other.comment;
	}
///
	Owner & operator= (Owner &other) {
		initials = other.initials;
		name = other.name;
		comment = other.comment;
		return *this;
	}
#endif
///
	Owner(const char *i,const char *n,const char *c) {
		initials = i;
		name = n;
		comment = c;
	}
///
	~Owner() {}
///
	const char *Initials() const {return initials.c_str();}
///
	const char *Name() const {return name.c_str();}
///
	const char *Comment() const {return comment.c_str();}
#ifndef SWIG
private:
///
	string initials;
///
	string name;
///
	string comment;
#endif
};

#ifndef SWIG
///
typedef map<string, Owner *, less<string> > OwnerMap;
#endif

#endif // _OWNER_H_

