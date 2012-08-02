/* 
 * ------------------------------------------------------------------
 * Table.cc - Table (turn and trabsfer) class
 * Created by Robert Heller on Tue Aug  8 10:58:56 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
 * Modification History:
 * Modification History: Revision 2.6  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
// Revision 2.5  1995/09/09  23:01:59  heller
// Add in proper hasHandle usage
// cleanup use of Tcl_DeleteHashTable() in destructor
// write proper output functions
// add in Clean() method
//
// Revision 2.4  1995/09/03  22:38:47  heller
// Merge in trees
//
// Revision 2.3  1995/09/02  20:58:18  heller
// Added Segments
//
// Revision 2.2  1995/08/08  17:28:23  heller
// fix points index handling
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

#include <Table.h>
#include <Tree.h>
#include <strstream.h>

int Table::EvalScript(const char * script,const char *P)
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
				case 'P': Cmd += P; break;
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


ostream& operator << (ostream& stream,Table& to)
{
	if (to.ValidP)
	{
		stream << "define table " << to.name << " address ";
		stream.form("0x%08x",to.Address);
		stream << " points " << to.numberofpoints << endl;
		stream << "\tsegments " << to.numberofsegments << '[' << endl;
		for (int i = 0;i < to.numberofsegments;i++)
		{
			stream << "\t\t" << *(to.Segments[i]) << endl;
		}
		stream << "\t] " << to.Length << " : " << to.Speed << " ";
		stream << "\"" << MRRQuote(to.ReadStateScript()) << "\" ";
		stream << "\"" << MRRQuote(to.ActuateScript()) << "\"" << endl;
	}
	return stream;
}


ostream& operator << (ostream& stream,TableTable& tt)
{
	for (Table *t = tt.FirstTable();t != NULL;t = tt.NextTable())
	{
		stream << *t;
	}
	return stream;
}

Table *TableTable::FindTable(const char * key)
{
#ifdef LATER
	int newP;
	Table *result;
	Tcl_HashEntry *entry = Tcl_CreateHashEntry(&table,(char*)key,&newP);
	if (newP)
	{
		result = new Table;
		result->name = key;
		result->mytable = this;
		Tcl_SetHashValue(entry,result);
	} else
	{
		result = (Table*) Tcl_GetHashValue(entry);
	}
	return result;
#else
	return NULL;
#endif
}

bool TableTable::DeleteTable(const char * key)
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&table,(char*)key);
	if (entry != NULL)
	{
		Table *result = (Table*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		Tcl_DeleteHashEntry(entry);
		if (result->hasHandle == FALSE) delete result;
		return TRUE;
	} else return FALSE;
#else
	return false;
#endif
}

Table *TableTable::FirstTable()
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Table*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}

Table *TableTable::NextTable()
{
#ifdef LATER
	if (!searching) return NULL;
	searching = FALSE;
	Tcl_HashEntry *entry = Tcl_NextHashEntry(&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Table*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}	

TableTable::~TableTable()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Table *result = (Table*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
#endif
}

void TableTable::Clean()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Table *result = (Table*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
	Tcl_InitHashTable(&table,TCL_STRING_KEYS);
#endif
}


