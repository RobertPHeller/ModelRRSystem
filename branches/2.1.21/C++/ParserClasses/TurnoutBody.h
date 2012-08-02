/* 
 * ------------------------------------------------------------------
 * TurnoutBody.h - Turnout Body elements
 * Created by Robert Heller on Sat Sep 28 18:08:41 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.3  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
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

#ifndef _TURNOUTBODY_H_
#define _TURNOUTBODY_H_

#include <TrackBody.h>
#include <IntegerList.h>
#include <string.h>
#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include <TrackBody.h>

class TrackGraph;
class TurnoutBody;

#define angle radius
#define len0 ang0
#define len1 ang1

/** Turnout body elements: T, E, P, S, C, and J lines are collected. others are
  *  discarded.
   */
class TurnoutBodyElt {
public:
	/**  Element types.
	  */
	enum TurnoutBodyEltType {
		/**   Placeholder.
		  */
		None, 
		/**   T or E line.
		  */
		TurnoutEnd, 
		/**   P line.
		  */
		TurnoutRoute, 
		/**   S line.
		  */
		TurnoutStraightSegment, 
		/**   C line.
		  */
		TurnoutCurveSegment, 
		/**   J Line.
		  */
		TurnoutJointSegment 
	};
private:
	/**  Counter for S, C, and J segments.
	  */
	static int segCount;
	/**  Element type.
	  */
	TurnoutBodyEltType theType;
	/**  Pointer to T or E line data.
	  */
	TrackBodyElt *theEnd;
	/** Route name (P lines).
	  */
	char *RouteName;
	/**  Segment list (P Lines).
	  */
	IntegerList *routeList;
	/**  Segment index (S, C, or J lines).
	  */
	int segmentId;
	/**  Position structure.
	  */
	struct Pos {
		/**  $X$ coordinate.
		  */
		float x;
		/**  $Y$ coordinate.
		  */
		float y;
	};
	/**  First position.
	  */
	Pos pos1;
	/**  Second position.
	  */
	Pos pos2;
	/**  A radius value.
	  */
	float radius;
	/**  An angle value.
	  */
	float ang0;
	/**  Another angle value.
	  */
	float ang1;
	/**  $R$ value (for J lines).
	  */
	float R;
	/**  $L$ value (for J lines).
	  */
	float L;
public:
	/**  Segment count initializer.
	  */
	static inline void InitTSegId() {segCount = 0;}
	/** @memo Constructor.
	  */
	TurnoutBodyElt()
		{theType = None;theEnd=NULL;RouteName=NULL;routeList=NULL;}
	/** @memo Destructor.
	  */
	~TurnoutBodyElt() {}
	/**  Type accessor.
	  */
	TurnoutBodyEltType TheType() const {return theType;}
	/**  Create an endpoint (T or E lines).
	  */
	static inline TurnoutBodyElt *MakeTurnoutEnd(TrackBodyElt *tbe)
		{
			TurnoutBodyElt *result = new TurnoutBodyElt();
			result->theType = TurnoutEnd;
			result->theEnd = tbe;
			return result;
		}
	/**  Create a turnout route (P lines).
	  */
	static inline TurnoutBodyElt *MakeTurnoutRoute(char *pName, IntegerList *cList)
		{
			TurnoutBodyElt *result = new TurnoutBodyElt();
			result->theType = TurnoutRoute;
			result->RouteName = pName;
			result->routeList = cList;
			return result;
		}
	/**  Fetch turnout route data.
	  */
	void GetTurnoutRoute(char *&pName, IntegerList *&cList) const
		{
			pName = RouteName;
			cList = routeList;
		}
	/**  Create a turnout straight segment (S lines).
	  */
	static inline TurnoutBodyElt *MakeTurnoutStraightSegment(float x1,float y1,float x2,float y2)
		{
			TurnoutBodyElt *result = new TurnoutBodyElt();
			result->theType = TurnoutStraightSegment;
			result->segmentId = ++segCount;
			result->pos1.x = x1;
			result->pos1.y = y1;
			result->pos2.x = x2;
			result->pos2.y = y2;
			return result;
		}
	/**  Fetch turnout straight segment data.
	  */
	int GetTurnoutStraightSegment(float &x1,float &y1,float &x2,float &y2) const
		{
			x1 = pos1.x; y1 = pos1.y;
			x2 = pos2.x; y2 = pos2.y;
			return segmentId;
		}
	/**  Create a turnout curve segment (C lines).
	  */
	static inline TurnoutBodyElt *MakeTurnoutCurveSegment(float r,float x,float y,float a0,float a1)
		{
			TurnoutBodyElt *result = new TurnoutBodyElt();
			result->theType = TurnoutCurveSegment;
			result->segmentId = ++segCount;
			result->radius = r;
			result->pos1.x = x;
			result->pos1.y = y;
			result->ang0 = a0;
			result->ang1 = a1;
			return result;
		}
	/**  Fetch turnout curve segment data.
	  */
	int GetTurnoutCurveSegment(float &r,float &x,float &y,float &a0,float &a1) const
		{
			r = radius;
			x = pos1.x; y  = pos1.y;
			a0 = ang0; a1 = ang1;
			return segmentId;
		}
	/**  Create a turnout joint segment (J lines).
	  */
	static inline TurnoutBodyElt *MakeTurnoutJointSegment(float x, float y,float a, float l0, float l1, float r, float l)
		{
			TurnoutBodyElt *result = new TurnoutBodyElt();
			result->theType = TurnoutJointSegment;
			result->segmentId = ++segCount;
			result->pos1.x = x;
			result->pos1.y = y;
			result->angle = a;
			result->len0 = l0;
			result->len1 = l1;
			result->R = r;
			result->L = l;
			return result;
		}
	/**  Fetch turnout joint segment data.
	  */
	int GetTurnoutJointSegment(float &x, float &y,float &a, float &l0, float &l1, float &r, float &l) const
		{
			x = pos1.x;
			y = pos1.y;
			a = angle;
			l0 = len0;
			l1 = len1;
			r = R;
			l = L;
			return segmentId;
		}
	friend class TrackGraph;
	friend class TurnoutBody;
};

/** List of turnout body lines (T, E, P, S, C, and J lines).
  */
class TurnoutBody {
private:
	/**  Current element.
	  */
	TurnoutBodyElt *element;
	/**  Next element.
	  */
	TurnoutBody    *next;
	/**  Free up memory.
	  */
	inline void CleanUpElement()
	{
		switch (element->theType) {
			case TurnoutBodyElt::TurnoutEnd:
				delete element->theEnd;
				break;
			case TurnoutBodyElt::TurnoutRoute:
			case TurnoutBodyElt::TurnoutStraightSegment:
			case TurnoutBodyElt::TurnoutCurveSegment:
			case TurnoutBodyElt::TurnoutJointSegment:
			case TurnoutBodyElt::None: break;
		}
	}
public:
	/** @memo Basic constructor.
	  */
	TurnoutBody (TurnoutBodyElt *e, TurnoutBody *n) {element = e; next = n;}
	/**  Alternitive constructor function.
	  */
	static inline TurnoutBody *ConsTurnoutBody(TurnoutBodyElt *trbe, TurnoutBody* trb)
		{
			TurnoutBody *result = new TurnoutBody(trbe,trb);
			return result;
		}
	friend class TurnoutBodyElt;
	/**  Create a track endpoint list.
	  */
	inline TrackBody *TurnoutEnds()
		{
			TrackBody *result = NULL;
			TurnoutBody *trb;
			for (trb = this;trb != NULL;trb = trb->next) {
				if (trb->element->theType != TurnoutBodyElt::TurnoutEnd) continue;
				result = TrackBody::AppendTrackBodyElt(result,trb->element->theEnd);
			}
			return result;
		}
	/**  Count segments (S, C, and J lines).
	  */
	inline int TurnoutSegmentCount()
		{
			int count = 0;
			TurnoutBody *trb;
			for (trb = this;trb != NULL;trb = trb->next) {
				if (trb->element->theType == TurnoutBodyElt::TurnoutStraightSegment ||
				    trb->element->theType == TurnoutBodyElt::TurnoutCurveSegment ||
				    trb->element->theType == TurnoutBodyElt::TurnoutJointSegment) count++;
			}
			return count;
		}
	/**  Count routes (P lines).
	  */
	inline int TurnoutRouteCount()
		{
			int count = 0;
			TurnoutBody *trb;
			for (trb = this;trb != NULL;trb = trb->next) {
				if (trb->element->theType == TurnoutBodyElt::TurnoutRoute) count++;
			}
			return count;
		}
	/**  Free up memory.
	  */
	static inline void CleanUpTurnoutBody(TurnoutBody *trb)
		{
			TurnoutBody *ne;
			TurnoutBodyElt *elt;
			for (;trb != NULL;trb = ne) {
				ne = trb->next;
				trb->CleanUpElement();
				elt = trb->element;
				delete elt;
				delete trb;
			}
		}
	/**  Return current element.
	  */
	const inline TurnoutBodyElt *Element() const {return element;}
	friend class TrackGraph;
};

#undef angle
#undef len0
#undef len1
#endif // _TURNOUTBODY_H_

