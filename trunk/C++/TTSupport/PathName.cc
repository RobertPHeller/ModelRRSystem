/* 
 * ------------------------------------------------------------------
 * PathName.cc - Pathname implementation
 * Created by Robert Heller on Thu Aug 25 11:09:30 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:33  heller
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
 
#include "config.h"
#include <PathName.h>

using namespace TTSupport;

#if defined(__WIN32__)
#define PATHSEPARATORS "\\/"
#endif

#if defined(__unix__)
#define PATHSEPARATORS "/"
#endif

char PathName::PathSeparator() const {
	string::size_type seploc = pathname.size(), newloc;
	char      sep = '\0';
	const char *seps;
	for (seps = PATHSEPARATORS; *seps != '\0'; seps++) {
		newloc = pathname.find(*seps);
		if (newloc != string::npos && newloc < seploc) {
			seploc = newloc;
			sep    = *seps;
		}
	}
	if (sep == '\0') return PATHSEPARATORS[0];
	else return sep;
}

stringVector PathName::Split() const {
	stringVector result;
	string::size_type newloc, curloc;
	char      sep = PathSeparator();

	if (sep == '\0') {
		result.push_back(pathname);
	} else {
		for (curloc = 0;curloc < pathname.size();curloc = newloc) {
			newloc = pathname.find(sep,curloc);
			if (newloc == string::npos) newloc = pathname.size()-1;
			if (newloc == curloc) {
				newloc++;
				continue;
			}
			result.push_back(pathname.substr(curloc,newloc-curloc));
			newloc++;
		}
	}
	return result;
}

string PathName::Tail() const {
	char      sep = PathSeparator();
	string::size_type lastsep = pathname.rfind(sep);
	if (lastsep == string::npos) return pathname;
	else return pathname.substr(lastsep+1);
}

string PathName::Dirname() const {
	char      sep = PathSeparator();
	string::size_type lastsep;
	if (sep == '\0') lastsep = 0;
	else lastsep = pathname.rfind(sep);
	return pathname.substr(0,lastsep);
}

string PathName::Extension() const {
	string::size_type dot = pathname.rfind('.');
	if (dot == string::npos) dot = pathname.size()-1;
	return pathname.substr(dot+1);
}

PathName  PathName::operator+ (const PathName other) {
	PathName result;
	if (pathname.size() == 0) result = other;
	else {
		result = PathName(pathname + PathSeparator() + other.FullPath());
	}
	return result;
}

PathName & PathName::operator+= (const PathName other) {
	if (pathname.size() == 0) {
		pathname = other.FullPath();
	} else {
		pathname += PathSeparator();
		pathname += other.FullPath();
	}
	return *this;
}


PathName  PathName::operator+ (string tail) {
	PathName result;
	if (pathname.size() == 0) result = PathName(tail);
	else {
		result = PathName(pathname + PathSeparator() + tail);
	}
	return result;
}	

PathName & PathName::operator+= (string tail) {
	if (pathname.size() == 0) {
		pathname = tail;
	} else {
		pathname += PathSeparator();
		pathname += tail;
	}
	return *this;
}


