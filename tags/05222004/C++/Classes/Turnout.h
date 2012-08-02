/* 
 * ------------------------------------------------------------------
 * Turnout.h - Turnout Class
 * Created by Robert Heller on Mon Aug  7 18:51:52 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
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
 * Revision 2.4  1995/09/09  23:03:34  heller
 * add in Clean() method
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

#ifndef _TURNOUT_H_
#define _TURNOUT_H_

#include <iostream.h>
#include <Segment.h>

class TurnoutTable;
class TurnoutClass;

class Turnout {
private:
	char * name;
	char * readstatescript;
	char * actuatescript;
	TurnoutTable *mytable;
public:
	Segment *Main1, *Main2, *D1, *D2;
	enum {
		MAIN = 0,
		DIVERGENCE1 = 1,
		DIVERGENCE2 = 2};
	const char * Name() const {return name;}
	const char * ReadStateScript() const {return readstatescript;}
	const char * ActuateScript() const {return actuatescript;}
	long int Address;
	short int Length,MainSpeed,DivergenceSpeed;
	bool ValidP;
	Turnout() {
		ValidP = false;
		name = new char[1]; name[0] = '\0';
		Address = 0L;
		readstatescript = new char[1];readstatescript[0] = '\0';
		actuatescript = new char[1];actuatescript[0] = '\0';
		Length = 0;
		MainSpeed = 0;
		DivergenceSpeed = 0;
		mytable = NULL;
		Main1 = Main2 = D1 = D2 = NULL;
	}
        int EvalScript(const char * stript,const char* P);
	friend class TurnoutTable;
	TurnoutTable *MyTable() const {return mytable;}
	friend ostream& operator << (ostream& stream,Turnout& to);
	friend class NextElement;
	friend class TurnoutClass;
};

class Tree;
class TurnoutTable {
private:
	bool searching;
	Tree *mytree;
public:
	Tree *MyTree() const {return mytree;}
	friend class Tree;
	TurnoutTable()
		{searching = false;}
	~TurnoutTable();
	Turnout *FindTurnout(const char * key);
	bool DeleteTurnout(const char * key);
	Turnout *FirstTurnout();
	Turnout *NextTurnout();
	void Clean();
	friend ostream& operator << (ostream& stream,TurnoutTable& tt);
};	

#endif // _TURNOUT_H_

