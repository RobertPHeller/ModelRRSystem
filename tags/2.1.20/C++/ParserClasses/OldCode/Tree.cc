/* 
 * ------------------------------------------------------------------
 * Tree.cc - Tree class
 * Created by Robert Heller on Sun Sep  3 10:39:55 1995
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
// Revision 2.4  1995/09/09  23:02:33  heller
// write proper output functions
// Added in MRRQuote() global function
//
// Revision 2.3  1995/09/04  04:42:40  heller
// Add Tcl hook to CurrentTree()
//
// Revision 2.2  1995/09/04  01:13:11  heller
// Fix private member Name/name access
//
// Revision 2.1  1995/09/03  22:40:45  heller
// Initial revision
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

#include <Tree.h>
#include <Turnout.h>
#include <Block.h>
#include <Signal.h>
#include <Cross.h>
#include <Table.h>
#include <NonROW.h>
#include <strstream.h>
#include <string.h>
#include <regex.h>

#ifdef LATER
#define MrrStandardsOffset(field) \
	((unsigned int)&(((MrrStandards *)NULL)->field))
static struct _MrrStandardsFields
	{
		const char * fname;
		unsigned int offset;
		_MrrStandardsFields(const char* n,unsigned int o)
			{fname = n;offset = o;}
	} MrrStandardsFields[] = {
		{"maxMountGrade",MrrStandardsOffset(maxMountGrade)},
		{"maxNormGrade",MrrStandardsOffset(maxNormGrade)},
		{"maxFlyGrade",MrrStandardsOffset(maxFlyGrade)},
		{"minRadius",MrrStandardsOffset(minRadius)},
		{"minEasement",MrrStandardsOffset(minEasement)},
		{"minTFrog",MrrStandardsOffset(minTFrog)},
		{"minXOFrog",MrrStandardsOffset(minXOFrog)},
		{"minLadFrog",MrrStandardsOffset(minLadFrog)},
		{"minTanTrackCenters",MrrStandardsOffset(minTanTrackCenters)},
		{"minCurvTrackCenters",MrrStandardsOffset(minCurvTrackCenters)},
		{"minSCStraight",MrrStandardsOffset(minSCStraight)},
		{"minVClear",MrrStandardsOffset(minVClear)},
		{"normVClear",MrrStandardsOffset(normVClear)},
	};
static const NumMrrStandardsFields =
	sizeof(MrrStandardsFields) / sizeof(MrrStandardsFields[0]);

ostream& operator << (ostream& stream,MrrStandards &standards)
{
	stream << "set standards " << endl;
	for (int i=0;i<NumMrrStandardsFields;i++)
	{
		stream << "\t" << MrrStandardsFields[i].fname << " "
		       << *((double*)(((char*)(&standards))+MrrStandardsFields[i].offset))
		       << endl;
	}
	return stream;
}
#endif
	
ostream& operator << (ostream& stream,Tree& t)
{
	stream << "use tree " << t.name << endl;
#ifdef LATER
	stream << t.Standards;
#endif
	stream << *(t.turnouts);
	stream << *(t.blocks);
	stream << *(t.signals);
	stream << *(t.crosses);
	stream << *(t.tables);
	stream << *(t.nonrows);
	return stream;
}




ostream& operator << (ostream& stream,TreeTable& tt)
{
#ifdef LATER
	stream << tt.Standards;
#endif
	for (Tree* t = tt.FirstTree(); t != NULL; t = tt.NextTree())
	{
		stream << *t;
	}
	return stream;
}

Tree *TreeTable::FindTree(const char * key)
{
#ifdef LATER
	int newP;
	Tree *result;
	Tcl_HashEntry *entry = Tcl_CreateHashEntry(&table,(char*)key,&newP);
	if (newP)
	{
		result = new Tree;
		result->name = key;
		result->mytable = this;
		result->Standards = Standards;
		Tcl_SetHashValue(entry,result);
	} else
	{
		result = (Tree*) Tcl_GetHashValue(entry);
	}
	return result;
#else
	return NULL;
#endif
}

bool TreeTable::DeleteTree(const char * key)
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&table,(char*)key);
	if (entry != NULL)
	{
		Tree *result = (Tree*) Tcl_GetHashValue(entry);
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

Tree *TreeTable::FirstTree()
{
#ifdef LATER
	Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Tree*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}

Tree *TreeTable::NextTree()
{
#ifdef LATER
	if (!searching) return NULL;
	searching = FALSE;
	Tcl_HashEntry *entry = Tcl_NextHashEntry(&search);
	if (entry == NULL) return NULL;
	searching = TRUE;
	return (Tree*) Tcl_GetHashValue(entry);
#else
	return NULL;
#endif
}	

TreeTable::~TreeTable()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Tree *result = (Tree*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
#endif
}

void TreeTable::Clean()
{
#ifdef LATER
	for (Tcl_HashEntry *entry = Tcl_FirstHashEntry(&table,&search);
	     entry != NULL;
	     entry = Tcl_NextHashEntry(&search))
	{
		Tree *result = (Tree*) Tcl_GetHashValue(entry);
		result->mytable = NULL;
		result->ValidP = FALSE;
		if (result->hasHandle == FALSE) delete result;
	}
	Tcl_DeleteHashTable(&table);
	Tcl_InitHashTable(&table,TCL_STRING_KEYS);
	Standards = MrrStandards();
#endif
}

Turnout* Tree::lookupturnout(const char * name)
{ return (turnouts->FindTurnout(name)); }
Turnout* Tree::firstturnout()
{ return (turnouts->FirstTurnout()); }
Turnout* Tree::nextturnout()
{ return (turnouts->NextTurnout()); }
bool Tree::deleteturnout(const char * name)
{ return (turnouts->DeleteTurnout(name)); }
Block*   Tree::lookupblock(const char * name)
{ return (blocks->FindBlock(name)); }
Block* Tree::firstblock()
{ return (blocks->FirstBlock()); }
Block* Tree::nextblock()
{ return (blocks->NextBlock()); }
bool Tree::deleteblock(const char * name)
{ return (blocks->DeleteBlock(name)); }
Signal*  Tree::lookupsignal(const char * name)
{ return (signals->FindSignal(name)); }
Signal* Tree::firstsignal()
{ return (signals->FirstSignal()); }
Signal* Tree::nextsignal()
{ return (signals->NextSignal()); }
bool Tree::deletesignal(const char * name)
{ return (signals->DeleteSignal(name)); }
Cross*  Tree::lookupcross(const char * name)
{ return (crosses->FindCross(name)); }
Cross* Tree::firstcross()
{ return (crosses->FirstCross()); }
Cross* Tree::nextcross()
{ return (crosses->NextCross()); }
bool Tree::deletecross(const char * name)
{ return (crosses->DeleteCross(name)); }
Table*  Tree::lookuptable(const char * name)
{ return (tables->FindTable(name)); }
Table* Tree::firsttable()
{ return (tables->FirstTable()); }
Table* Tree::nexttable()
{ return (tables->NextTable()); }
bool Tree::deletetable(const char * name)
{ return (tables->DeleteTable(name)); }
NonROW*  Tree::lookupnonrow(const char * name)
{ return (nonrows->FindNonROW(name)); }
NonROW* Tree::firstnonrow()
{ return (nonrows->FirstNonROW()); }
NonROW* Tree::nextnonrow()
{ return (nonrows->NextNonROW()); }
bool Tree::deletenonrow(const char * name)
{ return (nonrows->DeleteNonROW(name)); }

//static const char * TwoColons = "::";
static regex_t TwoColonString;
static bool TwoColonString_inited = false;
static regmatch_t TwoColonString_offs[3];

static bool HasTreeName(const char * s)
{
	if (!TwoColonString_inited)
	{
		regcomp(&TwoColonString,"^([^:]+)(::)([^:]+)$",0);
		TwoColonString_inited = true;
	}
	int status = regexec(&TwoColonString,s,3,TwoColonString_offs,0);
	if (status == 0) return(true);
	else return(false);
}

static const char * TreeName(const char * s)
{
	static char temp[4096];
	if (HasTreeName(s))
	{
		int len = TwoColonString_offs[0].rm_eo+1;
		strncpy(temp,s,len);
		temp[len] = '\0';
		return (temp);
	} else	return "";
}

static const char * ElementName(const char * s)
{
	if (HasTreeName(s))
	{
		return (s+TwoColonString_offs[2].rm_so);
	} else	return s;
}


Turnout* TreeTable::lookupturnout(const char * name)
{
	const char * tree = TreeName(name),
	       * element = ElementName(name);
	if (tree == "")
	{
		if (currentTree == NULL) return(NULL);
		else return (currentTree->lookupturnout(element));
	} else
	{
		Tree *t = FindTree(tree);
		if (t == NULL) return(NULL);
		else return (t->lookupturnout(element));
	}
	
}

Block*   TreeTable::lookupblock(const char * name)
{
	const char * tree = TreeName(name),
	      * element = ElementName(name);
	if (tree == "")
	{
		if (currentTree == NULL) return(NULL);
		else return (currentTree->lookupblock(element));
	} else
	{
		Tree *t = FindTree(tree);
		if (t == NULL) return(NULL);
		else return (t->lookupblock(element));
	}
	
}

Signal*  TreeTable::lookupsignal(const char * name)
{
	const char * tree = TreeName(name),
	      * element = ElementName(name);
	if (tree == "")
	{
		if (currentTree == NULL) return(NULL);
		else return (currentTree->lookupsignal(element));
	} else
	{
		Tree *t = FindTree(tree);
		if (t == NULL) return(NULL);
		else return (t->lookupsignal(element));
	}
	
}

Cross*   TreeTable::lookupcross(const char * name)
{
	const char * tree = TreeName(name),
	      * element = ElementName(name);
	if (tree == "")
	{
		if (currentTree == NULL) return(NULL);
		else return (currentTree->lookupcross(element));
	} else
	{
		Tree *t = FindTree(tree);
		if (t == NULL) return(NULL);
		else return (t->lookupcross(element));
	}
	
}

Table*   TreeTable::lookuptable(const char * name)
{
	const char * tree = TreeName(name),
	      * element = ElementName(name);
	if (tree == "")
	{
		if (currentTree == NULL) return(NULL);
		else return (currentTree->lookuptable(element));
	} else
	{
		Tree *t = FindTree(tree);
		if (t == NULL) return(NULL);
		else return (t->lookuptable(element));
	}
	
}

NonROW*  TreeTable::lookupnonrow(const char * name)
{
	const char * tree = TreeName(name),
	      * element = ElementName(name);
	if (tree == "")
	{
		if (currentTree == NULL) return(NULL);
		else return (currentTree->lookupnonrow(element));
	} else
	{
		Tree *t = FindTree(tree);
		if (t == NULL) return(NULL);
		else return (t->lookupnonrow(element));
	}
	
}


Tree::Tree(const char * n)
{
	name = new char[strlen(n)+1]; strcpy(name,n);
	mytable = NULL;
	turnouts = new TurnoutTable;
	turnouts->mytree = this;
	blocks = new BlockTable;
	blocks->mytree = this;
	signals = new SignalTable;
	signals->mytree = this;
	crosses = new CrossTable;
	crosses->mytree = this;
	tables = new TableTable;
	tables->mytree = this;
	nonrows = new NonROWTable;
	nonrows->mytree = this;
	ValidP = false;
}

Tree::~Tree()
{
	if (mytable != NULL)
	{
		mytable->DeleteTree(name);
	}
	delete turnouts;
	delete blocks;
	delete signals;
	delete crosses;
	delete tables;
	delete nonrows;
}	

void Tree::Clean()
{
	turnouts->Clean();
	blocks->Clean();
	signals->Clean();
	crosses->Clean();
	tables->Clean();
	nonrows->Clean();
#ifdef LATER
	Standards = MrrStandards();
#endif
}

const char * MRRQuote(const char * source)
{
	return source;
#ifdef LATER
	static const Regex PSQChars = "[\\\\\"\n]";
	char * b = "", *a = "", *m = "";
	static const char * result;
	result = "";
	for (const char * temp = source;temp != "";temp = a)
	{
		b = temp.before(PSQChars);
		m = temp.at(PSQChars);
		a = temp.after(PSQChars);
		result += b;
		if (m != "")
		{
			result += "\\";
			result += m;
		} else  result += temp;
	}
	return result;
#endif
}

