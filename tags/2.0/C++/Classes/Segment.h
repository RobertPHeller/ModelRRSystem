/* 
 * ------------------------------------------------------------------
 * Segment.h - Segemnt and successor Class
 * Created by Robert Heller on Tue Aug 29 08:46:22 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
 * Modification History:
 * Modification History: Revision 2.6  2000/11/10 00:26:10  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.5  1995/09/10 15:04:59  heller
 * Modification History: Minor typos
 * Modification History:
 * Revision 2.4  1995/09/10  15:01:49  heller
 * Make friends with trackwork classes
 *
 * Revision 2.3  1995/09/10  14:48:54  heller
 * Add copy constructors for NextElement and Segment
 *
 * Revision 2.2  1995/09/09  23:00:08  heller
 * Add in proper hasHandle usage
 *
 * Revision 2.1  1995/09/02  19:08:54  heller
 * Initial version
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

#ifndef _SEGMENT_H_
#define _SEGMENT_H_

#include <iostream.h>

class Turnout;
class Block;
class Table;
class Segment;
class Cross;

class TurnoutClass;
class TableClass;
class CrossClass;

class NextElement {
public:
	enum NextType {_Turnout, _Block, _Table, _Segment, _Cross, None};
private:
	union {
		Turnout *turnout;
		Block   *block;
		Table   *table;
		Cross   *cross;
		Segment *segment;
	} nptr;
	enum NextType nextType;
public:
	NextElement(Turnout *t) {nptr.turnout = t;nextType=_Turnout;}
	NextElement(Block   *b) {nptr.block   = b;nextType=_Block;}
	NextElement(Table   *t) {nptr.table   = t;nextType=_Table;}
	NextElement(Segment *s) {nptr.segment = s;nextType=_Segment;}
	NextElement(Cross   *c) {nptr.cross   = c;nextType=_Cross;}
	NextElement() {nextType = None;}
	NextElement(NextElement& NE) {nptr.turnout = NE.nptr.turnout;
				      nextType=NE.nextType;}
	inline NextType TypeOfNext() {return nextType;}
	inline Turnout *NextTurnout()
		{if (nextType == _Turnout) return nptr.turnout;else return NULL;}
	inline Block   *NextBlock()
		{if (nextType == _Block) return nptr.block;else return NULL;}
	inline Table *NextTable()
		{if (nextType == _Table) return nptr.table;else return NULL;}
	inline Segment *NextSegment()
		{if (nextType == _Segment) return nptr.segment;else return NULL;}
	inline Cross *NextCross()
		{if (nextType == _Cross) return nptr.cross;else return NULL;}
	friend ostream& operator << (ostream& stream,NextElement& nxsg);
	friend class Segment;
};

class Segment {
private:
public:
	double X1,Y1,Z1;
	double X2,Y2,Z2;
	double Tan;
	NextElement *N1,*N2;
	Segment(double x1 = 0,double y1 = 0,double z1 = 0,NextElement *n1 = NULL,
		double x2 = 0,double y2 = 0,double z2 = 0,NextElement *n2 = NULL,
		double tan = 0)
		{
			X1 = x1;
			Y1 = y1;
			Z1 = z1;
			X2 = x2;
			Y2 = y2;
			Z2 = z2;
			Tan = tan;
			N1 = n1;
			N2 = n2;
		}
	Segment(Segment& s)
		{
			X1 = s.X1;
			Y1 = s.Y1;
			Z1 = s.Z1;
			X2 = s.X2;
			Y2 = s.Y2;
			Z2 = s.Z2;
			Tan = s.Tan;
			if (s.N1 == NULL) N1 = NULL;
			else N1 = new NextElement(*(s.N1));
			if (s.N2 == NULL) N2 = NULL;
			else N2 = new NextElement(*(s.N2));
		}
	bool ComputeCurve(double &radius, double &Xc, double &Yc,
			  double &Alpha1,double &Alpha2, 
			  double &Xx, double &Yy,
			  double &w, double &h, 
			  double &NewTheta);
	void Elevate(double dz1,double dz2) {Z1 += dz1;Z2 += dz2;}
	inline double Grade() {return ((Z2-Z1)/Length()) * 100;}
	void Rotate(double angle);
	void Rotate(double angle,double ax,double ay);
	inline void Translate(double dx,double dy)
		{X1 += dx;X2 += dx;Y1 += dy;Y2 += dy;}
	double Length();
	friend ostream& operator << (ostream& stream,Segment& sg);
	friend class NextElement;
	friend class Turnout;
	friend class Block;
	friend class Table;
	friend class Cross;
	friend class TurnoutClass;
	friend class TableClass;
	friend class CrossClass;
};

#endif // _SEGMENT_H_

