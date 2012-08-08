/* 
 * ------------------------------------------------------------------
 * Turnout.cc - Turnout Class
 * Created by Robert Heller on Mon Aug  7 19:58:34 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
 * Modification History:
 * Modification History: Revision 2.5  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
// Revision 2.4  1995/09/09  23:03:25  heller
// Add in proper hasHandle usage
// cleanup use of Tcl_DeleteHashTable() in destructor
// write proper output functions
// add in Clean() method
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

#include <Turnout.h>
#include <Tree.h>
#include <strstream.h>

int Turnout::EvalScript(const char * script,const char *P)
{
#ifdef LATER
	char * Cmd = "";
	static const Regex Percent = "\\%"; 
	char * b = "", a = "", m = "",n = "";
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


ostream& operator << (ostream& stream,Turnout& to)
{
	if (to.ValidP)
	{
		stream << "define turnout " << to.name << " address ";
		stream.form("0x%08x",to.Address);
		if (to.Main2 == NULL)
		{
			stream << endl << "\t\tmain " << *(to.Main1) << " ";
		} else
		{
			stream << endl << "\t\tmain 1 " << *(to.Main1) ;
			stream << endl <<  "\t\tmain 2 " << *(to.Main2) << " ";
		}
		if (to.D2 == NULL)
		{
			stream << endl <<  "\t\tdivergence " << *(to.D1) << " ";
		} else
		{
			stream << endl <<  "\t\tdivergence 1 " << *(to.D1);
			stream << endl <<  "\t\tdivergence 2 " << *(to.D2) << " ";
		}
		stream << " " << to.Length << " : " << to.MainSpeed << " , "
		       << to.DivergenceSpeed << " ";
		stream << "\"" << MRRQuote(to.ReadStateScript()) << "\" ";
		stream << "\"" << MRRQuote(to.ActuateScript()) << "\""
		       << endl;
	}
	return stream;
}


ostream& operator << (ostream& stream,TurnoutTable& tt)
{
	for (Turnout* t = tt.FirstTurnout();t != NULL;t = tt.NextTurnout())
	{
		stream << *t;
	}
	return stream;
}

Turnout *TurnoutTable::FindTurnout(const char * key)
{
#ifdef LATER
	Turnout *result;
	int newP;
	Tcl_HashEntry *entry = Tcl_CreateHashEntry(&table,(char*)key,&newP);
	if (newP)
	{
		result = new Turnout;
		result->name = key;
		result->mytable = this;
		Tcl_SetHashValue(entry,result);
	} else
	{
		result = (Turnout*) Tcl_GetHashValue(entry);
	}
	return result;
#else
	return NULL;
#endif
}

bool TurnoutTable::DeleteTurnout(const char * key)
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&table,(char*)key);
	if (entry != NULL)
	{
		Turnout *result = (Turnout*) Tcl_GetHashValue(entry);
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

Turnout *TurnoutTable::FirstTurnout()
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Turnout*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}

Turnout *TurnoutTable::NextTurnout()
{
#ifdef LATER
	if (!searching) return NULL;
	searching = FALSE;
	Tcl_HashEntry *entry = Tcl_NextHashEntry(&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Turnout*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}	

TurnoutTable::~TurnoutTable()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Turnout *result = (Turnout*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
#endif
}

void TurnoutTable::Clean()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Turnout *result = (Turnout*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
	Tcl_InitHashTable(&table,TCL_STRING_KEYS);
#endif
}


 
