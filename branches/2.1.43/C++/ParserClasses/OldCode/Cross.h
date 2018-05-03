/* 
 * ------------------------------------------------------------------
 * Cross.h - Cross class
 * Created by Robert Heller on Tue Aug  8 12:52:24 1995
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
 * Modification History: Revision 2.7  2000/11/10 00:26:10  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Revision 2.6  1995/09/12  20:04:46  heller
 * Make Name() return a reference.
 *
 * Revision 2.5  1995/09/10  15:02:09  heller
 * Make friends with trackwork classes
 *
 * Revision 2.4  1995/09/09  22:53:44  heller
 * Add in Clean() member.
 *
 * Revision 2.3  1995/09/03  22:38:47  heller
 * Merge in trees
 *
 * Revision 2.2  1995/09/02  19:08:54  heller
 * Added Segments
 *
 * Revision 2.1  1995/08/08  17:33:49  heller
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

#ifndef _CROSS_H_
#define _CROSS_H_

#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include <Segment.h>

class CrossTable;
class CrossClass;

class Cross {
private:
	CrossTable *mytable;
	char * name;
public:
	Segment *Leg1,*Leg2;
	const char * Name() const {return name;}
	short int Length,Speed;
	bool ValidP;
	Cross() {
		ValidP = false;
		name = new char[1]; name[0] = '\0';
		Length = 0;
		Speed = 0;
		Leg1 = Leg2 = NULL;
		mytable = NULL;
	}
	friend class CrossTable;
	CrossTable *MyTable() const {return mytable;}
	friend ostream& operator << (ostream& stream,Cross& to);
	friend class NextElement;
	friend class CrossClass;
};

class Tree;

class CrossTable {
private:
	bool searching;
	Tree *mytree;
public:
	Tree *MyTree() const {return mytree;}
	friend class Tree;
	CrossTable()
		{searching = false;}
	~CrossTable();
	Cross *FindCross(const char * key);
	bool DeleteCross(const char * key);
	Cross *FirstCross();
	Cross *NextCross();
	void Clean();
	friend ostream& operator << (ostream& stream,CrossTable& tt);
};	

#endif // _CROSS_H_

