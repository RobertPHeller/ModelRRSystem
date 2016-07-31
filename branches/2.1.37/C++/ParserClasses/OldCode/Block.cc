/* 
 * ------------------------------------------------------------------
 * Block.cc - Block Class
 * Created by Robert Heller on Mon Aug  7 23:31:23 1995
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
// Revision 2.4  1995/09/09  22:51:14  heller
// make real use of hasHandle member
// remove Tcl_DeleteHashEntry() from in search look
// write a proper output function
//
// Revision 2.3  1995/09/03  22:38:47  heller
// Merge in trees
//
// Revision 2.2  1995/09/02  19:08:54  heller
// Added Segments
//
// Revision 2.1  1995/08/08  16:41:10  heller
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

#include <Block.h>
#include <Tree.h>
#include <math.h>
#include <strstream.h>

int Block::EvalScript(const char * script,const char *C)
{
#ifdef LATER
	static char myhandle[32];
	MyHandle(interp,myhandle);
	String Cmd = "";
	static const Regex Percent = "\\%"; 
	String b = "", a = "", m = "",n = "";
	for (String temp = stript;temp != "";temp = a)
	{
		b = temp.before(Percent);
		m = temp.at(Percent);
		a = temp.after(Percent);
		Cmd += b;
		if (m != "")
		{
			n = a.at(0,1);
			a = a.after(0);
			switch (((char*)n)[0]) 
			{
				case '%': Cmd += "%"; break;
				case 'H': Cmd += myhandle; break;
				case 'C': Cmd += C; break;
				default : Cmd += "%"; Cmd += n; break;
			}
		} else  Cmd += temp;
	}
	char *cmd = (char*) Cmd;
	return Tcl_GlobalEval(interp,cmd);
#else
	return 0;
#endif
}

ostream& operator << (ostream& stream,Block& bl)
{
	if (bl.ValidP)
	{
		stream << "define block " << bl.name << " address ";
		stream.form("0x%08x",bl.Address);
		stream << " segment ";
		stream << '{' << endl << "\t\t";
		Segment *s;
		for (s = bl.SegList;s->N2->NextSegment() != NULL;s = s->N2->NextSegment())
		{
			stream << *s << endl << "\t\t";
		}
		stream << *s << endl << "\t\t";
		stream << '}';
		stream << " " << bl.Length << " : " << bl.Speed;
		stream << " \"" << MRRQuote(bl.OccupiedScript()) << "\" ";
		stream << "\"" << MRRQuote(bl.SelectCabScript()) << "\"" << endl;
	}
	return stream;
}

ostream& operator << (ostream& stream,BlockTable& tt)
{
	for (Block *b = tt.FirstBlock();b != NULL;b = tt.NextBlock())
	{
		stream << *b;
	}
	return stream;
}

Block *BlockTable::FindBlock(const char * key)
{
#ifdef LATER
	int newP;
	Block *result;
	Tcl_HashEntry *entry = Tcl_CreateHashEntry(&table,(char*)key,&newP);
	if (newP)
	{
		result = new Block;
		result->name = key;
		result->mytable = this;
		Tcl_SetHashValue(entry,result);
	} else
	{
		result = (Block*) Tcl_GetHashValue(entry);
	}
	return result;
#else
	return NULL;
#endif
}

bool BlockTable::DeleteBlock(const char * key)
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&table,(char*)key);
	if (entry != NULL)
	{
		Block *result = (Block*) Tcl_GetHashValue(entry);
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

Block *BlockTable::FirstBlock()
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Block*) Tcl_GetHashValue(entry);
#else
        return NULL;
#endif
}

Block *BlockTable::NextBlock()
{
#ifdef LATER
	if (!searching) return NULL;
	searching = FALSE;
	Tcl_HashEntry *entry = Tcl_NextHashEntry(&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Block*) Tcl_GetHashValue(entry);
#else
        return NULL;
#endif
}	

BlockTable::~BlockTable()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Block *result = (Block*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
#endif
}

void BlockTable::Clean()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Block *result = (Block*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
	Tcl_InitHashTable(&table,TCL_STRING_KEYS);
#endif
}

