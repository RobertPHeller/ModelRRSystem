// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Apr 8 16:59:55 2018
//  Last Modified : <180409.1229>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2018  Robert Heller D/B/A Deepwoods Software
//			51 Locke Hill Road
//			Wendell, MA 01379-9728
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// 
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __CORNUBODY_H
#define __CORNUBODY_H

#include <TrackBody.h>
#include <IntegerList.h>
#include <string.h>
#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include <TrackBody.h>

/** @addtogroup ParserClasses
  * @{
  */

namespace Parsers {

class TrackGraph;
class CornuBody;

#define angle radius
#define len0 ang0
#define len1 ang1



/** Cornu Body elements: T, E, S, and C lines are collected. others are
 * discarded.
 * 
 * @author Robert Heller \<heller\@deepsoft.com\>
 * 
 */

class CornuBodyElt {
public:
    /**  Element types.
     */
    enum CornuBodyEltType {
        /**   Placeholder.
         */
        None,
              /**   T or E line.
               */
              CornuEnd,
              /**   S line.
               */
              CornuStraightSegment, 
              /**   C line.
               */
              CornuCurvedSegment
          };
private:
    /**  Counter for S and C segments.
     */
    static int segCount;
    /**  Element type.
     */
    CornuBodyEltType theType;
    /**  Pointer to T or E line data.
     */
    TrackBodyElt *theEnd;
    /**  Segment index (S or C lines).
     */
    int segmentId;
    /**  Position structure.
     * 
     * @author Robert Heller \<heller\@deepsoft.com\>
     */
    struct Pos {
        /**  $X$ coordinate. */
        float x;
        /**  $Y$ coordinate.*/
        float y;
    };
    /**  First position. */
    Pos pos1;
    /**  Second position. */
    Pos pos2;
    /**  A radius value. */
    float radius;
    /**  An angle value. */
    float ang0;
    /**  Another angle value. */
    float ang1;
public:
    /**  Segment count initializer. */
    static inline void InitTSegId() {segCount = 0;}
    /** @brief Constructor */
    CornuBodyElt() {theType = None;theEnd=NULL;}
    /** @brief Destructor. */
    ~CornuBodyElt() {}
    /**  Type accessor. */
    CornuBodyEltType TheType() const {return theType;}
    /**  Create an endpoint (T or E lines). */
    static inline CornuBodyElt *MakeTrackEnd(TrackBodyElt *tbe)
    {
        CornuBodyElt *result = new CornuBodyElt();
        result->theType = CornuEnd;
        result->theEnd = tbe;
        return result;
    }
    /**  Create a straight segment (S lines). */
    static inline CornuBodyElt *MakeStraightSegment(float x1,float y1,float x2,float y2)
    {
        CornuBodyElt *result = new CornuBodyElt();
        result->theType = CornuStraightSegment;
        result->segmentId = ++segCount;
        result->pos1.x = x1;
        result->pos1.y = y1;
        result->pos2.x = x2;
        result->pos2.y = y2;
        return result;
    }
    /**  Fetch straight segment data. */
    int GetStraightSegment(float &x1,float &y1,float &x2,float &y2) const
    {
        x1 = pos1.x; y1 = pos1.y;
        x2 = pos2.x; y2 = pos2.y;
        return segmentId;
    }
    /**  Create a curve segment (C lines).
     */
    static inline CornuBodyElt *MakeCurveSegment(float r,float x,float y,float a0,float a1)
    {
        CornuBodyElt *result = new CornuBodyElt();
        result->theType = CornuCurvedSegment;
        result->segmentId = ++segCount;
        result->radius = r;
        result->pos1.x = x;
        result->pos1.y = y;
        result->ang0 = a0;
        result->ang1 = a1;
        return result;
    }
    /**  Fetch curve segment data.
     */
    int GetCurveSegment(float &r,float &x,float &y,float &a0,float &a1) const
    {
        r = radius;
        x = pos1.x; y  = pos1.y;
        a0 = ang0; a1 = ang1;
        return segmentId;
    }
    friend class TrackGraph;
    friend class CornuBody;
};

/** List of Cornu body lines (T, E, S, and C lines).
 *
 * @author Robert Heller \<heller\@deepsoft.com\>
 * 
 */

class CornuBody {
private:
    /**  Current element. */
    CornuBodyElt *element;
    /**  Next element. */
    CornuBody *next;
    /**  Free up memory. */
    inline void CleanUpElement()
    {
        switch (element->theType) {
        case CornuBodyElt::CornuEnd:
            delete element->theEnd;
            break;
        case CornuBodyElt::CornuStraightSegment:
        case CornuBodyElt::CornuCurvedSegment:
        case CornuBodyElt::None: break;
        }
    }
public:
    /** @brief Basic constructor. */
    CornuBody (CornuBodyElt *e, CornuBody*n) {element = e; next = n;}
    /**  Alternitive constructor function. */
    static inline CornuBody *ConsCornuBody(CornuBodyElt *trbe, CornuBody* trb)
    {
        CornuBody *result = new CornuBody(trbe,trb);
        return result;
    }
    static inline CornuBody *ConcatCornuBody(CornuBody* trba, CornuBody* trb)
    {
        CornuBody *p, **tail;
        CornuBody *result = trba;
        if (result == NULL) return trb;
        for (p = result, tail = &(p->next); *tail != NULL; p = p->next, tail = &(p->next)) ;
        *tail = trb;
        return result;
    }
    friend class CornuBodyElt;
    /**  Create a track endpoint list.
     */
    inline TrackBody *CornuEnds()
    {
        TrackBody *result = NULL;
        CornuBody *trb;
        for (trb = this;trb != NULL;trb = trb->next) {
            if (trb->element->theType != CornuBodyElt::CornuEnd) continue;
            result = TrackBody::AppendTrackBodyElt(result,trb->element->theEnd);
        }
        return result;
    }
    /**  Count segments (S, C, and J lines).
     */
    inline int CornuSegmentCount()
    {
        int count = 0;
        CornuBody *trb;
        for (trb = this;trb != NULL;trb = trb->next) {
            if (trb->element->theType == CornuBodyElt::CornuStraightSegment ||
                trb->element->theType == CornuBodyElt::CornuCurvedSegment) count++;
        }
        return count;
    }
    /**  Free up memory.
     */
    static inline void CleanUpCornuBody(CornuBody *trb)
    {
        CornuBody *ne;
        CornuBodyElt *elt;
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
    const inline CornuBodyElt *Element() const {return element;}
    friend class TrackGraph;
};

#undef angle
#undef len0
#undef len1

};

/** @} */




#endif // __CORNUBODY_H

