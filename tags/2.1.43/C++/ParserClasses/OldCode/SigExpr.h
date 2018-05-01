/* 
 * ------------------------------------------------------------------
 * SigExpr.h -  log message!
 * Created by Robert Heller on Sun Aug  6 15:47:08 1995
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
 * Revision 2.3  1995/09/09  23:00:26  heller
 * Add error stream hook.
 *
 * Revision 2.2  1995/08/09  00:12:56  heller
 * Minor fixes.
 *
 * Revision 2.1  1995/08/08  16:42:08  heller
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

#ifndef _SIGEXPR_H_
#define _SIGEXPR_H_

#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif

class Expr {
protected:
	Expr *left;
	Expr *right;
public:
	Expr() {left = NULL; right = NULL;}
	virtual bool eval() = 0;
	virtual void print(ostream& stream) = 0;
	virtual char* name() = 0;
	friend ostream& operator << (ostream& stream,Expr& ex);
};

class NotExpr : public Expr {
public:
	NotExpr(Expr* e) {left = e;}
	virtual bool eval() {return ((bool)!left->eval());}
	virtual void print(ostream& stream)
		{stream << "(NOT " << *left << ")";}
	friend ostream& operator << (ostream& stream,NotExpr& ex);
	virtual char* name() {return "NotExpr";}
};

class OrExpr : public Expr {
public:
	OrExpr(Expr *l,Expr *r) {left = l;right = r;}
	virtual bool eval() {return((bool)(left->eval() || right->eval()));}
	virtual void print(ostream& stream)
		{stream << "(" << *left << " OR " << *right << ")";}
	friend ostream& operator << (ostream& stream,OrExpr& ex);
	virtual char* name() {return "OrExpr";}
};

class AndExpr : public Expr {
public:
	AndExpr(Expr *l,Expr *r) {left = l;right = r;}
	virtual bool eval() {return((bool)(left->eval() && right->eval()));}
	virtual void print(ostream& stream)
		{stream << "(" << *left << " AND " << *right << ")";}
	friend ostream& operator << (ostream& stream,AndExpr& ex);
	virtual char* name() {return "AndExpr";}
};

class Turnout;
class Block;
class Table;

class TurnExpr : public Expr {
private:
	Turnout *turnout;
	int turnstate;
public:
	TurnExpr(Turnout *t,int ts) {turnout = t;turnstate = ts;}
	virtual bool eval();
	virtual void print(ostream& stream);
	friend ostream& operator << (ostream& stream,TurnExpr& ex);
	virtual char* name() {return "TurnExpr";}
};

class BlockExpr : public Expr {
private:
	Block *block;
public:
	BlockExpr(Block *b) {block = b;}
	virtual bool eval();
	virtual void print(ostream& stream);
	friend ostream& operator << (ostream& stream,BlockExpr& ex);
	virtual char* name() {return "BlockExpr";}
};

class TableExpr : public Expr {
private:
	Table *table;
	int pointnumber;
public:
	TableExpr(Table *t,int pn) {table = t;pointnumber = pn;}
	virtual bool eval();
	virtual void print(ostream& stream);
	friend ostream& operator << (ostream& stream,TableExpr& ex);
	virtual char* name() {return "TableExpr";}
};



class MRRSigExpr;

class SigExpr {
protected:
	MRRSigExpr *parser;
	ostream *errorstream;
	Expr *Result;
public:
	Expr *ReturnResult() {return Result;}
	int Parse();
	void ParseError(char *m);
	SigExpr (MRRSigExpr *p,ostream *es = NULL)
		{parser = p;Result = NULL;errorstream = es;}
	~SigExpr();
};



#endif // _SIGEXPR_H_

