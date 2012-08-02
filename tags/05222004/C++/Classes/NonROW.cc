/* 
 * ------------------------------------------------------------------
 * NonROW.cc - NonROW class
 * Created by Robert Heller on Tue Aug  8 12:54:06 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
 * Modification History:
 * Modification History: Revision 2.7  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
// Revision 2.6  1995/09/13  00:01:00  heller
// Add in missing handle table init for GrObject
//
// Revision 2.5  1995/09/12  23:35:17  heller
// small typo
//
// Revision 2.4  1995/09/12  23:32:05  heller
// add missing validp option
//
// Revision 2.3  1995/09/09  22:54:42  heller
// Add in proper hasHandle usage
// cleanup use of Tcl_DeleteHashTable() in destructor
// write proper output functions
// add in Clean() method
//
// Revision 2.2  1995/09/03  22:38:47  heller
// Merge in trees
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

#include <NonROW.h>
#include <Tree.h>
#include <strstream.h>
#include <stdlib.h>


ostream& operator << (ostream& stream,NonROW& to)
{
	if (to.ValidP)
	{
		stream << "define NonROW " << to.name << " " << *(to.Object);
		switch (to.Transparency)
		{
			case NonROW::Opaque: stream << " Opaque";break;
			case NonROW::Translucent: stream << " Translucent";break;
			case NonROW::Transparent: stream << " Transparent";break;
		}
		stream << " " << to.ZMin << " " << to.ZMax << endl ;
	}
	return stream;
}

ostream& operator << (ostream& stream,NonROWTable& tt)
{
	for (NonROW *r = tt.FirstNonROW(); r != NULL; r = tt.NextNonROW())
	{
		stream << *r;
	}
	return stream;
}

NonROW *NonROWTable::FindNonROW(const char * key)
{
#ifdef LATER
	int newP;
	NonROW *result;
	Tcl_HashEntry *entry = Tcl_CreateHashEntry(&table,(char*)key,&newP);
	if (newP)
	{
		result = new NonROW;
		result->name = key;
		result->mytable = this;
		Tcl_SetHashValue(entry,result);
	} else
	{
		result = (NonROW*) Tcl_GetHashValue(entry);
	}
	return result;
#else
	return NULL;
#endif
}

bool NonROWTable::DeleteNonROW(const char * key)
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&table,(char*)key);
	if (entry != NULL)
	{
		NonROW *result = (NonROW*) Tcl_GetHashValue(entry);
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

NonROW *NonROWTable::FirstNonROW()
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (NonROW*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}

NonROW *NonROWTable::NextNonROW()
{
#ifdef LATER
	if (!searching) return NULL;
	searching = FALSE;
	Tcl_HashEntry *entry = Tcl_NextHashEntry(&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (NonROW*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}	

NonROWTable::~NonROWTable()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		NonROW *result = (NonROW*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
#endif
}

void NonROWTable::Clean()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		NonROW *result = (NonROW*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
	Tcl_InitHashTable(&table,TCL_STRING_KEYS);
#endif
}


 


ostream& operator << (ostream& stream,GrObject& to)
{
	switch (to.type)
	{
		case GrObject::Rectangle:
			stream << "rectangle ( "
				<< to.coords[0].X << " , "
				<< to.coords[0].Y << " , "
				<< to.coords[1].X << " , "
				<< to.coords[1].Y << " , "
				<< "\"" << MRRQuote(to.fill) << "\" , "
				<< "\"" << MRRQuote(to.outline) << "\" )" << endl;
			break;				
		case GrObject::Oval: 
			stream << "oval ( "
				<< to.coords[0].X << " , "
				<< to.coords[0].Y << " , "
				<< to.coords[1].X << " , "
				<< to.coords[1].Y << " , "
				<< "\"" << MRRQuote(to.fill) << "\" , "
				<< "\"" << MRRQuote(to.outline) << "\" )" << endl;
			break;				
		case GrObject::Polygon:
			stream << "polygon ( " << to.numberOfCoords;
			{int i;
			 stream << " , [ ";
			 for (i = 0; i < to.numberOfCoords; i++)
			 {
			 	stream << to.coords[i].X;
			 	if ((i+1) < to.numberOfCoords) stream << " , ";
			 }
			 stream << " ] , [ ";
			 for (i = 0; i < to.numberOfCoords; i++)
			 {
			 	stream << to.coords[i].Y;
			 	if ((i+1) < to.numberOfCoords) stream << " , ";
			 }
			 stream << " ] , ";
			}
			stream << "\"" << MRRQuote(to.fill) << "\" )" << endl;
			break;
		case GrObject::Text: 
			stream << "text ( "
				<< to.coords[0].X << " , "
				<< to.coords[0].Y << " , "
				<< "\"" << MRRQuote(to.text) << "\" , "
				<< "\"" << MRRQuote(to.fill) << "\" )" << endl;
			break;				
	}
	return stream;
}

