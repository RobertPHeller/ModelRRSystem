/* 
 * ------------------------------------------------------------------
 * SwitchList.cc - SwitchList code
 * Created by Robert Heller on Sat Oct  1 12:27:40 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 05:52:08  heller
 * Modification History: Upgraded for G++ 3.2
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:33  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
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

static char Id[] = "$Id$";

#include <SwitchList.h>

namespace FCFSupport {

/*************************************************************************
 *                                                                       *
 * Initialize indexes to an empty switch list.				 *
 *                                                                       *
 *************************************************************************/

SwitchList::SwitchList()
{
	pickIndex = 0;
	lastIndex = -1;
	limitCars = 0;
}


SwitchList::~SwitchList()
{
}

/*************************************************************************
 *                                                                       *
 * Reset the switch list indexes.                                        *
 *                                                                       *
 *************************************************************************/

void SwitchList::ResetSwitchList() 
{
	pickIndex = 0;
	lastIndex = -1;
}

/*************************************************************************
 *                                                                       *
 * Reinitialize the switch list.				         *
 *                                                                       *
 *************************************************************************/

void SwitchList::DiscardSwitchList()
{
	ResetSwitchList();
	limitCars = 0;
}

/*************************************************************************
 *                                                                       *
 * Add a pickup at an industry    					 *
 *                                                                       *
 *************************************************************************/

void SwitchList::AddSwitchListElement(const Industry *pickloc, const Car *pickcar,
				      const Train *picktrain, const Train *lasttrain, 
				      const Industry *istop) 
{
	SwitchListElement newele(pickloc,pickcar,picktrain,lasttrain,istop);
	if (pickIndex >= theList.size()) {
	  theList.push_back(newele);
	  pickIndex = theList.size();
	} else {
	  theList[pickIndex++] = newele;
	}
	limitCars = pickIndex;	   
}

/*************************************************************************
 *                                                                       *
 * Add a pickup at a station						 (
 *                                                                       *
 *************************************************************************/

void SwitchList::AddSwitchListElement(const Industry *pickloc, const Car *pickcar,
				      const Train *picktrain, const Train *lasttrain, 
				      const Station *sstop) 
{
	SwitchListElement newele(pickloc,pickcar,picktrain,lasttrain,sstop);
	if (pickIndex >= theList.size()) {
	  theList.push_back(newele);
	  pickIndex = theList.size();
	} else {
	  theList[pickIndex++] = newele;
	}
	limitCars = pickIndex;	   
}

/*************************************************************************
 *                                                                       *
 * Indexing operator.	Performs a range check.				 *
 *                                                                       *
 *************************************************************************/

SwitchListElement & SwitchList::operator[] (int ielement) 
{
	static SwitchListElement dummy;
	if (ielement < 0 || (unsigned)ielement >= pickIndex) return dummy;
	else return theList[ielement];
}

/*************************************************************************
 *                                                                       *
 * Const indexing operator.   Performs a range check.			 *
 *                                                                       *
 *************************************************************************/

const SwitchListElement SwitchList::operator[] (int ielement) const
{
	static SwitchListElement dummy;
	if (ielement < 0 || ielement >= limitCars) return dummy;
	else return theList[ielement];
}

/*************************************************************************
 *                                                                       *
 * Find the next switch list element for the selected car and industry.  *
 *                                                                       *
 *************************************************************************/

int SwitchList::NextSwitchListForCarAndIndustry(const Car *car,
						const Industry *industry)
{
	unsigned int Gx;
#ifdef DEBUG
	cerr << "*** SwitchList::NextSwitchListForCarAndIndustry(" <<
		car->Marks() << " " << car->Number() << "," <<
		industry->Name() << ")" << endl;
	cerr << "*** SwitchList::NextSwitchListForCarAndIndustry: lastIndex = " << lastIndex << ", pickIndex = " << pickIndex << endl;
#endif
	for (Gx = lastIndex+1; Gx < pickIndex; Gx++) {
#ifdef DEBUG
	  cerr << "*** SwitchList::NextSwitchListForCarAndIndustry: Gx = " <<
		  Gx << ", theList[" << Gx << "].PickCar() == " <<
		  theList[Gx].PickCar()->Marks() << " " <<
		  theList[Gx].PickCar()->Number() << ", theList[" << Gx << 
		  "].PickLocation() == " <<
		  theList[Gx].PickLocation()->Name() << endl; 
#endif
	  if (theList[Gx].PickCar() == car &&
	      theList[Gx].PickLocation() ==  industry) {
	    lastIndex = Gx;
	    return Gx;
	  }
	}
	lastIndex = -1;
	return -1;
}


/*************************************************************************
 *                                                                       *
 * Write out a SwitchListElement to an output stream.                    *
 *                                                                       *
 *************************************************************************/

ostream & operator << (ostream & stream,const SwitchListElement & element)
{
	stream << "<SwitchListElement ";
	const Industry *pl = element.PickLocation();
	const Car      *pc = element.PickCar();
	const Train    *pt = element.PickTrain();
	const Station  *dss = element.DropStopStation();


	if (pl == NULL || pc == NULL || pt == NULL || dss == NULL) {
	  stream << "empty>";
	} else {
	  stream << "Location:" << pl->Name() << ",";
	  stream << "Car:" << pc->Marks() << " " << pc->Number() << ",";
	  stream << "Train:" << pt->Name() << ",";
	  stream << "Station:" << dss->Name() << ">";
	}
	return stream;
}

/*************************************************************************
 *                                                                       *
 * Write out a SwitchList to an output stream.				 *
 *                                                                       *
 *************************************************************************/

ostream & operator << (ostream & stream,const SwitchList & list)
{
	stream << "<SwitchList ";
	stream << list.theList.size() << "elements, " <<
		  list.pickIndex << " in use, LastIndex is " << 
		  list.lastIndex << ">";
	return stream;
}

/*************************************************************************
 *                                                                       *
 * Is the pick location equal to the specificed industry?		 *
 *                                                                       *
 *************************************************************************/

bool SwitchList::PickLocationEq(int Gx,const Industry *Ix) const
{
	if (Gx < 0 || (unsigned)Gx >= pickIndex) return false;
	else return theList[Gx].PickLocation() == Ix;
}

/*************************************************************************
 *                                                                       *
 * Is the pick car equal to the specificed car?				 *
 *                                                                       *
 *************************************************************************/

bool SwitchList::PickCarEq(int Gx,const Car *Cx) const
{
	if (Gx < 0 || (unsigned)Gx >= pickIndex) return false;
	else return theList[Gx].PickCar() == Cx;
}

/*************************************************************************
 *                                                                       *
 * Is the pick train equal to the specificed train?			 *
 *                                                                       *
 *************************************************************************/

bool SwitchList::PickTrainEq(int Gx,const Train *Tx) const
{
	if (Gx < 0 || (unsigned)Gx >= pickIndex) return false;
	else return theList[Gx].PickTrain() == Tx;
}

}
