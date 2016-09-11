/* 
 * ------------------------------------------------------------------
 * Table.h - Table (turn and transfer) class
 * Created by Robert Heller on Tue Aug  8 10:58:21 1995
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
 * Revision 2.6  1995/09/10  15:02:09  heller
 * Make friends with trackwork classes
 *
 * Revision 2.5  1995/09/10  02:00:55  heller
 * Fix use of delete operator
 *
 * Revision 2.4  1995/09/09  23:02:10  heller
 * add in Clean() method
 * Add in Segment allocator
 *
 * Revision 2.3  1995/09/03  22:38:47  heller
 * Merge in trees
 *
 * Revision 2.2  1995/09/02  20:58:18  heller
 * Added Segments
 *
 * Revision 2.1  1995/08/08  16:41:10  heller
 * *** empty log message ***
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

#ifndef _TABLE_H_
#define _TABLE_H_

#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include <Segment.h>

class TableTable;
class TableClass;

class Table {
private:
	TableTable *mytable;
	char * name;
	char * readstatescript;
	char * actuatescript;
	short int numberofsegments;
	Segment **Segments;
public:
	void AllocateSegments(int Num,Segment **Segs)
		{if (numberofsegments != 0) delete Segments;
		 Segments = new Segment*[Num];
		 for (int i=0;i<Num;i++) Segments[i] = Segs[i];
		 numberofsegments = Num;
		}
	short int numberofpoints;
	const char * Name() const {return name;}
	const char * ReadStateScript() const {return readstatescript;}
	const char * ActuateScript() const {return actuatescript;}
	long int Address;
	short int Length,Speed;
	short int NumberOfPoints() {return numberofpoints;}
	short int NumberOfSegments() {return numberofsegments;}
	bool ValidP;
	Table() {
		ValidP = false;
		name = new char[1];name[0] = '\0';
		Address = 0L;
		readstatescript = new char[1];readstatescript[0] = '\0';
		actuatescript = new char[1];actuatescript[0] = '\0';
		Length = 0;
		Speed = 0;
		numberofpoints = 0;
		numberofsegments = 0;
		Segments = NULL;
		mytable = NULL;
	}
	~Table() {if (numberofsegments > 0)delete Segments;}
	friend class TableTable;
	TableTable *MyTable() const {return mytable;}
	int EvalScript(const char * stript,const char* P);
	friend ostream& operator << (ostream& stream,Table& to);
	friend class NextElement;
	friend class TableClass;
};

class Tree;

class TableTable {
private:
	bool searching;
	Tree *mytree;
public:
	Tree *MyTree() const {return mytree;}
	friend class Tree;
	TableTable()
		{searching = false;}
	~TableTable();
	Table *FindTable(const char * key);
	bool DeleteTable(const char * key);
	Table *FirstTable();
	Table *NextTable();
	void Clean();
	friend ostream& operator << (ostream& stream,TableTable& tt);
};	

#endif // _TABLE_H_

