/* 
 * ------------------------------------------------------------------
 * Signal.h - Signal class
 * Created by Robert Heller on Tue Aug  8 12:52:44 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
 * Modification History:
 * Modification History: Revision 2.5  2000/11/10 00:26:10  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.4  1995/09/12 20:04:46  heller
 * Modification History: Make Name() return a reference.
 * Modification History:
 * Revision 2.3  1995/09/09  23:01:25  heller
 * Add in proper hasHandle usage
 * Make MRRLayoutFile friendly with AspectList
 * add in Clean() method
 *
 * Revision 2.2  1995/09/03  22:38:47  heller
 * Merge in trees
 * Add X,Y,Z, and O slots.
 *
 * Revision 2.1  1995/08/09  00:12:56  heller
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

#ifndef _SIGNAL_H_
#define _SIGNAL_H_

#include <iostream.h>
#include <SigExpr.h>

class SignalTable;
class Signal;

class AspectList {
private:
	Expr *expression;
	unsigned char aspect;
public:
	AspectList *next;
	AspectList(unsigned char a,Expr *e,AspectList *n = NULL)
		{aspect = a; expression = e; next = n;}
	~AspectList() {if (expression != NULL) delete expression;}
	friend ostream& operator << (ostream& stream,AspectList& al);
	friend class Signal;
	friend bool MRRCheckHeadCount(int hc,AspectList *asp);
};

class MRRLayoutFile;

class Signal {
private:
	SignalTable *mytable;
	char * name;
	short int headcount;
	AspectList *aspects;
	char * lightscript;
public:
	const char * LightScript() const {return lightscript;}
	void SetLightScript(const char *ls);
	double X,Y,Z,O;
	const char * Name() const {return name;}
	short int HeadCount() const {return headcount;}
	long int Address;
	enum HeadValues {
		BLACK = 0,
		RED   = 1,
		YELLOW = 2,
		GREEN = 3 };
	enum HeadFields {
		TopShift = 4,
		MiddleShift = 2,
		BottomShift = 0};
	enum {HeadMask = 0x3};
	const AspectList *Aspects() const {return aspects;}
	bool ValidP;
	Signal() {
		ValidP = false;
		name = new char[1];
		name[0] = '\0';
		Address = 0;
		mytable = NULL;
		headcount = 0;
		aspects = NULL;
		lightscript = NULL;
		X = Y = Z = O = 0.0;
	}
	~Signal() {
		if (name != NULL) delete name;
		if (aspects != NULL) delete aspects;
		if (lightscript != NULL) delete lightscript;
	}
	friend class SignalTable;
	const SignalTable *MyTable() const {return mytable;}
	inline bool EvalAspect(AspectList *aspect)
	{
		return aspect->expression->eval();
	}
	friend ostream& operator << (ostream& stream,Signal& to);
	friend class MRRLayoutFile;
};

class Tree;

class SignalTable {
private:
	bool searching;
	Tree *mytree;
public:
	Tree *MyTree() const {return mytree;}
	friend class Tree;
	SignalTable()
		{mytree=NULL;searching = false;}
	~SignalTable();
	Signal *FindSignal(const char * key);
	bool DeleteSignal(const char * key);
	Signal *FirstSignal();
	Signal *NextSignal();
	void Clean();
	friend ostream& operator << (ostream& stream,SignalTable& tt);
};	

#endif // _SIGNAL_H_

