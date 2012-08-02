/* 
 * ------------------------------------------------------------------
 * Tree.h - Tree class
 * Created by Robert Heller on Sat Sep  2 17:25:47 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.8  2000/11/10 00:26:10  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Revision 2.7  1995/09/12  20:04:46  heller
 * Make Name() return a reference.
 *
 * Revision 2.6  1995/09/09  23:03:11  heller
 * Added in MRRQuote() global function
 *
 * Revision 2.4  1995/09/04  01:13:11  heller
 * Fix private member Name/name access
 *
 * Revision 2.3  1995/09/04  00:55:44  heller
 * Initialize currentTree to NULL!
 *
 * Revision 2.2  1995/09/04  00:16:24  heller
 * Update parsing to use tree table
 *
 * Revision 2.1  1995/09/03  22:40:45  heller
 * Initial revision
 *
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

#ifndef _TREE_H_
#define _TREE_H_

#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif

class Turnout;
class Block;
class Cross;
class Table;
class NonROW;
class Signal;

class TurnoutTable;
class BlockTable;
class CrossTable;
class TableTable;
class NonROWTable;
class SignalTable;

#ifdef LATER
struct MrrStandards {
	double maxMountGrade;
	double maxNormGrade;
	double maxFlyGrade;
	double minRadius;
	double minEasement;
	double minTFrog;
	double minXOFrog;
	double minLadFrog;
	double minTanTrackCenters;
	double minCurvTrackCenters;
	double minSCStraight;
	double minVClear;
	double normVClear;
//	Units  units;
	friend ostream& operator << (ostream& stream, MrrStandards& standards);
	MrrStandards()
	{
		maxMountGrade = maxNormGrade = maxFlyGrade = minRadius
			      = minEasement = minTFrog = minXOFrog
			      = minLadFrog = minTanTrackCenters
			      = minCurvTrackCenters = minSCStraight
			      = minVClear = normVClear = 0.0;
	}
};
#endif

class TreeTable;

class Tree {
private:
	char * name;
	TreeTable *mytable;
protected:
	TurnoutTable *turnouts;
	BlockTable *blocks;
	SignalTable *signals;
	CrossTable *crosses;
	TableTable *tables;
	NonROWTable *nonrows;
public:
	TreeTable *MyTable() {return mytable;}
	bool ValidP;
	Tree(const char * n = "noname");
	const char * Name() const {return name;}
	~Tree();
#ifdef LATER
	MrrStandards Standards;
#endif
	Turnout* lookupturnout(const char * name);
	Turnout* firstturnout();
	Turnout* nextturnout();
	bool deleteturnout(const char * name);
	Block*   lookupblock(const char * name);
	Block* firstblock();
	Block* nextblock();
	bool deleteblock(const char * name);
	Signal*  lookupsignal(const char * name);
	Signal* firstsignal();
	Signal* nextsignal();
	bool deletesignal(const char * name);
	Cross*  lookupcross(const char * name);
	Cross* firstcross();
	Cross* nextcross();
	bool deletecross(const char * name);
	Table*  lookuptable(const char * name);
	Table* firsttable();
	Table* nexttable();
	bool deletetable(const char * name);
	NonROW*  lookupnonrow(const char * name);
	NonROW* firstnonrow();
	NonROW* nextnonrow();
	bool deletenonrow(const char * name);
	void Clean();
	friend ostream& operator << (ostream& stream,Tree& t);
	friend class TreeTable;
};	
class LayoutFile;

class TreeTable {
private:
	bool searching;
protected:
	Tree *currentTree;
public:
	TreeTable()
		{searching = false;currentTree = NULL;}
	~TreeTable();
	Tree *FindTree(const char * key);
	bool DeleteTree(const char * key);
	Tree *FirstTree();
	Tree *NextTree();
	Tree *CurrentTree() {return currentTree;}
	Tree *SelectCurrentTree(const char * key)
		{return (currentTree = FindTree(key));}
#ifdef LATER
	MrrStandards Standards;
#endif
	Turnout* lookupturnout(const char * name);
	Block*   lookupblock(const char * name);
	Signal*  lookupsignal(const char * name);
	Cross*   lookupcross(const char * name);
	Table*   lookuptable(const char * name);
	NonROW*  lookupnonrow(const char * name);
	void Clean();
	friend ostream& operator << (ostream& stream,TreeTable& tt);
	friend class LayoutFile;
};	

extern const char * MRRQuote(const char * s);

#endif // _TREE_H_

