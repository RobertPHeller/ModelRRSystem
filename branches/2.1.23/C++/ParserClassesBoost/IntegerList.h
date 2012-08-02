/* 
 * ------------------------------------------------------------------
 * IntegerList.h - Integer List
 * Created by Robert Heller on Sat Sep 28 18:02:12 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.2  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2004/06/26 13:53:37  heller
 * Modification History: Add in additional files
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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

#ifndef _INTEGERLIST_H_
#define _INTEGERLIST_H_

#ifdef SERIALIZATION
#include <boost/config.hpp>
#include <boost/serialization/access.hpp>
#endif

/** @addtogroup ParserClassesBoost
  * @{
  */


namespace Parsers {

class TurnoutBodyElt;




/** The @c IntegerList class implements a linked list of integers,
  * used for turnout route lists.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */

class IntegerList {
private:
	/**  The current element.
	  */
	int iElt;
	/**  The pointer to the next element.
	  */
	IntegerList *next;
#ifdef SERIALIZATION
	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & ar, const unsigned int version)
	{
		ar & iElt;
		ar & next;
	}
#endif
public:
	/** @brief Base constructor.
	  */
	IntegerList(int car=0, IntegerList *cdr=NULL)
		{
			iElt = car;
			next = cdr;
		}
	/**  Add an element to the {\em end} of the list.
	  */
	static inline IntegerList* IntAppend(IntegerList *head, int newTail)
		{
			IntegerList **prev;
			if (head == NULL) return new IntegerList(newTail,NULL);
			for (prev = &head->next; *prev != NULL; prev = &((*prev)->next) ) ;
			*prev =  new IntegerList(newTail,NULL);
			return head;
		}
	/**  Free up used memory.
	  */
	static inline void CleanUpIntegerList(IntegerList *list)
		{
			IntegerList *ni;
			for (;list != NULL;list = ni) {
				ni = list->next;
				delete list;
			}
		}
	static inline IntegerList *CopyList(const IntegerList *src)
		{
			IntegerList *copy = NULL;
			while (src != NULL) {
				copy = IntAppend(copy,src->iElt);
				src = src->next;
			}
			return copy;
		}
	/**  Output operator.
	  */
	friend inline ostream& operator << (ostream& stream,IntegerList *list)
		{
			stream << list->iElt;
			if (list->next != NULL) stream << " " << list->next;
			return stream;
		}
	/**  Element accessor.
	  */
	int Element() const {return iElt;}
	/**  Next pointer accessor (Const version).
	  */
	const IntegerList* Next() const {return next;}
	/**  Next pointer accessor (non-Const version).
	  */
	IntegerList* Next() {return next;}
	friend class TurnoutBodyElt;
	/** Is value in the list?
	  */
	bool ElementP (int v) const {
		const IntegerList *p;
		for (p = this; p != NULL; p = p->next) {
			if (p->iElt == v) return true;
		}
		return false;
	}
};

};

/** @} */

#endif // _INTEGERLIST_H_

