/* 
 * ------------------------------------------------------------------
 * Cross.cc - Cross class
 * Created by Robert Heller on Tue Aug  8 12:53:27 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.5  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
// Revision 2.4  1995/09/09  22:53:12  heller
// make real use of hasHandle member
// remove Tcl_DeleteHashEntry() from in search look
// write a proper output function
// Add in Clean() member.
//
// Revision 2.3  1995/09/03  22:38:47  heller
// Merge in trees
//
// Revision 2.2  1995/09/02  19:08:54  heller
// Added Segments
//
// Revision 2.1  1995/08/08  17:33:49  heller
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

#include <Cross.h>
#include <Tree.h>
#include <strstream.h>

ostream& operator << (ostream& stream,Cross& to)
{
	if (to.ValidP)
	{
		stream << "define cross " << to.name << endl
		       << "\t\tleg 1 " << *(to.Leg1) << endl
		       << "\t\tleg 2 " << *(to.Leg2)
		       << " " << to.Length << " : " << to.Speed << endl;
	}
	return stream;
}


ostream& operator << (ostream& stream,CrossTable& tt)
{
	for (Cross *c = tt.FirstCross();c != NULL;c = tt.NextCross())
	{
		stream << *c;
	}
	return stream;
}

Cross *CrossTable::FindCross(const char * key)
{
#ifdef LATER
	int newP;
	Cross *result;
	Tcl_HashEntry *entry = Tcl_CreateHashEntry(&table,(char*)key,&newP);
	if (newP)
	{
		result = new Cross;
		result->name = key;
		result->mytable = this;
		Tcl_SetHashValue(entry,result);
	} else
	{
		result = (Cross*) Tcl_GetHashValue(entry);
	}
	return result;
#else
	return NULL;
#endif
}

bool CrossTable::DeleteCross(const char * key)
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&table,(char*)key);
	if (entry != NULL)
	{
		Cross *result = (Cross*) Tcl_GetHashValue(entry);
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

Cross *CrossTable::FirstCross()
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Cross*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}

Cross *CrossTable::NextCross()
{
#ifdef LATER
	if (!searching) return NULL;
	searching = FALSE;
	Tcl_HashEntry *entry = Tcl_NextHashEntry(&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Cross*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}	

CrossTable::~CrossTable()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Cross *result = (Cross*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
#endif
}

void CrossTable::Clean()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Cross *result = (Cross*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
	Tcl_InitHashTable(&table,TCL_STRING_KEYS);
#endif
}



 

