/* 
 * ------------------------------------------------------------------
 * Cab.cc - Cab class implementation.
 * Created by Robert Heller on Thu Dec 22 23:05:10 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2006/05/17 01:11:22  heller
 * Modification History: May 16, 2006 lock down II: Add in IDs
 * Modification History:
 * Modification History: Revision 1.2  2006/02/26 23:45:42  heller
 * Modification History: Lock Down 3
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


#include <Cab.h>
#include <iostream>

static char Id[] = "$Id$";

ostream & Cab::Write(ostream & stream) const
{
	stream << "<Cab \"" << name << "\" \"" << color << "\">";
	return stream;
}

istream & Cab::Read(istream & stream)
{
	char buffer[2048], ch, *p;
	int i, count;
	do {
	 	stream.get(ch);
		if (!stream) return stream;
	} while (isspace(ch));
	stream.putback(ch);
	for (i = 0,p = "<Cab \""; *p != '\0'; p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DBUG
		cerr << "*** Cab::Read: (for <Cab...) ch = '" << ch << "'" << endl;
#endif
		if (ch != *p) {
			stream.putback(ch);
			while (i > 0) stream.putback(buffer[--i]);
			stream.setstate(ios::failbit);
			return stream;
		}
		buffer[i] = ch;
	}
	for (i = 0,p = buffer;i < 2048;p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Cab::Read: for (...buffer...): ch = '" << ch << "'" << endl;
#endif
		if (ch == '"') break;
		*p = ch;
	}
	*p = '\0';
	name = buffer;
	do {
	 	stream.get(ch);
		if (!stream) return stream;
	} while (isspace(ch));
	if (ch != '"') {
		stream.setstate(ios::failbit);
		return stream;
	}
	for (i = 0,p = buffer;i < 2048;p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
		if (ch == '"') break;
		*p = ch;
	}
	*p = '\0';
	color = buffer;
	stream.get(ch);
	if (ch != '>') stream.setstate(ios::failbit);
	return stream;
}

