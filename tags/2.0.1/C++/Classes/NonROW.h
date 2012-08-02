/* 
 * ------------------------------------------------------------------
 * NonROW.h - NonROW class
 * Created by Robert Heller on Tue Aug  8 12:53:03 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
 * Modification History:
 * Modification History: Revision 2.5  2000/11/10 00:26:10  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Revision 2.4  1995/09/12  20:04:46  heller
 * Make Name() return a reference.
 *
 * Revision 2.3  1995/09/09  22:56:32  heller
 *  add in Clean() method
 *
 * Revision 2.2  1995/09/03  22:38:47  heller
 * Merge in trees
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

#ifndef _NONROW_H_
#define _NONROW_H_

#include <iostream.h>

class NonROW;

class GrObject {
public:
	enum ObjectTypes {Rectangle, Oval, Polygon, Text};
	struct Coords {double X,Y;};
private:
	ObjectTypes type;
	Coords *coords;
	short int numberOfCoords;
	char * text;
	char * fill, * outline;
public:
	GrObject(bool rectP,double x1,double y1,double x2,double y2,const char * f,const char * o)
	{
		if (rectP) type = Rectangle;
		else type = Oval;
		numberOfCoords = 2;
		coords = new Coords[2];
		coords[0].X = x1; coords[0].Y = y1;
		coords[1].X = x2; coords[1].Y = y2;
		fill = new char[strlen(f)+1];strcpy(fill,f);
		outline = new char[strlen(o)+1];strcpy(outline,o);
		text = NULL;
	}
	GrObject(double x1,double y1,const char * t,const char * f)
	{
		type = Text;
		numberOfCoords = 1;
		coords = new Coords[1];
		coords[0].X = x1; coords[0].Y = y1;
		fill = new char[strlen(f)+1];strcpy(fill,f);
		text = new char[strlen(t)+1];strcpy(text,t);
		outline = NULL;
	}
	GrObject(int n,double *x1,double *y1,const char * f)
	{
		type = Polygon;
		numberOfCoords = n;
		coords = new Coords[n];
		for (int i=0;i<n;i++)
		{
			coords[i].X = x1[i]; 
			coords[i].Y = y1[i];
		}
		fill = new char[strlen(f)+1];strcpy(fill,f);
		text = NULL;
		outline = NULL;
	}
	~GrObject() {if (coords != NULL) delete coords;
		     if (fill != NULL) delete fill;
		     if (outline != NULL) delete outline;
		     if (text != NULL) delete text;}
	const char * Type()
	{
		switch (type)
		{
			case Rectangle: return "rectangle";
			case Oval: return "oval";
			case Polygon: return "polygon";
			case Text: return "text";
		}
		return "";
	}
	const char * Fill() {return fill;}
	const char * Outline() {return outline;}
	const char * TextString() {return text;}
	short int NumberOfCoords() {return numberOfCoords;}
	bool Coord(int n,double &x,double &y)
	{
		if (n < 0 || n >= numberOfCoords) return false;
		x = coords[n].X;
		y = coords[n].Y;
		return true;
	}
	friend ostream& operator << (ostream& stream,GrObject& to);
	friend class NonROW;
};

class NonROWTable;

class NonROW {
private:
	NonROWTable *mytable;
	char * name;
	bool hasHandle;
public:
	enum TransparencyType {Opaque, Translucent, Transparent} Transparency;
	double ZMin, ZMax;
	const char * Name() const {return name;}
	GrObject *Object;
	bool ValidP;
	NonROW() {
		ValidP = false;
		name = new char[1]; name[0] = '\0';
		Object = NULL;
		mytable = NULL;
		ZMin = ZMax = 0.0;
		Transparency = Transparent;
	}
	friend class NonROWTable;
	NonROWTable *MyTable() const {return mytable;}
	friend ostream& operator << (ostream& stream,NonROW& to);
};

class Tree;

class NonROWTable {
private:
	bool searching;
	Tree *mytree;
public:
	Tree *MyTree() const {return mytree;}
	friend class Tree;
	NonROWTable()
		{searching = false;}
	~NonROWTable();
	NonROW *FindNonROW(const char * key);
	bool DeleteNonROW(const char * key);
	NonROW *FirstNonROW();
	NonROW *NextNonROW();
	void Clean();
	friend ostream& operator << (ostream& stream,NonROWTable& tt);
};	

#endif // _NONROW_H_

