/* 
 * ------------------------------------------------------------------
 * Block.h - Block class
 * Created by Robert Heller on Mon Aug  7 23:22:10 1995
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
 * Modification History: Revision 2.6  2000/11/10 00:26:10  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Revision 2.5  1995/09/12  20:04:46  heller
 * Make Name() return a reference.
 *
 * Revision 2.4  1995/09/09  22:52:49  heller
 * Add in Clean() member.
 *
 * Revision 2.3  1995/09/03  22:38:47  heller
 * Merge in trees
 *
 * Revision 2.2  1995/09/02  19:08:54  heller
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

#ifndef _BLOCK_H_
#define _BLOCK_H_

#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include <Segment.h>

class BlockTable;

class Block {
private:
	BlockTable *mytable;
	char * name;
	char * occupiedscript;
	char * selectcabscript;
public:
	Segment *SegList;
	const char * Name() const {return name;}
	const char * OccupiedScript() const {return occupiedscript;}
	const char * SelectCabScript() const {return selectcabscript;}
	long int Address;
	short int Length,Speed;
	bool ValidP;
	Block() {
		ValidP = false;
		name = new char[1]; name[0] = '\0';
		Address = 0L;
		occupiedscript = new char[1]; occupiedscript[0] = '\0';
		selectcabscript = new char[1]; selectcabscript[0] = '\0';
		Length = 0;
		Speed = 0;
		SegList = NULL;
		mytable = NULL;
	}
	friend class BlockTable;
	BlockTable *MyTable() const {return mytable;}
	int EvalScript(const char * script,const char* C);
	friend ostream& operator << (ostream& stream,Block& to);
	friend class NextElement;
};

class Tree;

class BlockTable {
private:
	bool searching;
	Tree *mytree;
public:
	Tree *MyTree() const {return mytree;}
	friend class Tree;
	BlockTable()
		{searching = false;}
	~BlockTable();
	Block *FindBlock(const char * key);
	bool DeleteBlock(const char * key);
	Block *FirstBlock();
	Block *NextBlock();
	void Clean();
	friend ostream& operator << (ostream& stream,BlockTable& tt);
};	

#endif // _BLOCK_H_

