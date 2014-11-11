/* 
 * ------------------------------------------------------------------
 * Signal.cc - Signal class
 * Created by Robert Heller on Tue Aug  8 12:53:49 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.7  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.6  1995/09/24 19:34:51  heller
 * Modification History: Add output code for X, Y, Z, and O fields
 * Modification History: Minor mods to ComputeSignal
 * Modification History:
// Revision 2.5  1995/09/24  04:24:28  heller
// Silly math error
//
// Revision 2.4  1995/09/24  03:41:40  heller
// Add in ComputeSignal
//
// Revision 2.3  1995/09/09  23:00:42  heller
// Break out Signal::CheckHeadCount to a global function.
// Add in proper hasHandle usage
// cleanup use of Tcl_DeleteHashTable() in destructor
// write proper output functions
// add in Clean() method
//
// Revision 2.2  1995/09/03  22:38:47  heller
// Merge in trees
// Add X,Y,Z, and O slots.
//
// Revision 2.1  1995/08/09  00:12:56  heller
// *** empty log message ***
//
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995  Robert Heller D/B/A Deepwoods Software
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

static char rcsid[] = "$Id$";

#include <Signal.h>
#include <Tree.h>
#include <strstream.h>
#include <stdlib.h>
#include <math.h>

#define DEGREES(x) (((x) / M_PI) * 180.0)

/* signal graphics sizes */

#define SIGHEIGHT 40
#define HALFBW 10
#define HEADRAD 10


ostream& operator << (ostream& stream,Signal& to)
{
	if (to.ValidP)
	{
		stream << "define signal " << to.name << " address ";
		stream.form("0x%08x",to.Address);
		stream << " heads " << to.headcount << '<' << endl;
		for (AspectList *l = to.aspects;l != NULL;l = l->next)
		{
			stream << "\t\t" << *l;
			if (l->next != NULL) stream << " ,";
			stream << endl;
		}
		stream << "\t> \"" << MRRQuote(to.LightScript()) << "\""
		       << " " << to.X << " " << to.Y << " " << to.Z 
		       << " " << DEGREES(to.O) << endl;
	}
	return stream;
}

bool MRRCheckHeadCount(int hc,AspectList *asp)
{
	int m,b;

	for (;asp != NULL;asp = asp->next)
	{
		m = (asp->aspect >> Signal::MiddleShift) & Signal::HeadMask;
		b = asp->aspect & Signal::HeadMask;
		switch (hc)
		{
			case 1: if (m != Signal::BLACK ||
				    b != Signal::BLACK) return(false); break;
			case 2: if (m == Signal::BLACK ||
				    b != Signal::BLACK) return(false); break;
			case 3: if (m == Signal::BLACK ||
				    b == Signal::BLACK) return(false); break;
		}
	}
	return(true);
}


ostream& operator << (ostream& stream,SignalTable& tt)
{
	for (Signal *s = tt.FirstSignal();s != NULL;s = tt.NextSignal())
	{
		stream << *s;
	}
	return stream;
}

Signal *SignalTable::FindSignal(const char * key)
{
#ifdef LATER
	int newP;
	Signal *result;
	Tcl_HashEntry *entry = Tcl_CreateHashEntry(&table,(char*)key,&newP);
	if (newP)
	{
		result = new Signal;
		result->name = key;
		result->mytable = this;
		Tcl_SetHashValue(entry,result);
	} else
	{
		result = (Signal*) Tcl_GetHashValue(entry);
	}
	return result;
#else
	return NULL;
#endif
}

bool SignalTable::DeleteSignal(const char * key)
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&table,(char*)key);
	if (entry != NULL)
	{
		Signal *result = (Signal*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
		Tcl_DeleteHashEntry(entry);
		return TRUE;
	} else return FALSE;
#else
	return false;
#endif
}

Signal *SignalTable::FirstSignal()
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Signal*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}

Signal *SignalTable::NextSignal()
{
#ifdef LATER
	if (!searching) return NULL;
	searching = FALSE;
	Tcl_HashEntry *entry = Tcl_NextHashEntry(&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Signal*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}	

SignalTable::~SignalTable()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Signal *result = (Signal*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
#endif
}

void SignalTable::Clean()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Signal *result = (Signal*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
	Tcl_InitHashTable(&table,TCL_STRING_KEYS);
#endif
}

ostream& operator << (ostream& stream,AspectList& al)
{
	switch (((al.aspect >> Signal::TopShift) & Signal::HeadMask))
	{
		case Signal::RED: stream << "red"; break;
		case Signal::GREEN: stream << "green"; break;
		case Signal::YELLOW: stream << "yellow"; break;
	}
	switch (((al.aspect >> Signal::MiddleShift) & Signal::HeadMask))
	{
		case Signal::RED: stream << "-red"; break;
		case Signal::GREEN: stream << "-green"; break;
		case Signal::YELLOW: stream << "-yellow"; break;
	}
	switch (((al.aspect >> Signal::BottomShift) & Signal::HeadMask))
	{
		case Signal::RED: stream << "-red"; break;
		case Signal::GREEN: stream << "-green"; break;
		case Signal::YELLOW: stream << "-yellow"; break;
	}
	stream << " = " << "\"" << *(al.expression) << "\"";
	return stream;
}



