// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Apr 8 16:59:44 2018
//  Last Modified : <230418.0944>
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

#ifndef __BEZIERBODY_H
#define __BEZIERBODY_H

#include <TrackBody.h>
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
class BezierBody;

#define angle radius
#define len0 ang0
#define len1 ang1



/** Bezier Body elements: T, E, S, and C lines are collected. others are
 * discarded.
 * 
 * @author Robert Heller \<heller\@deepsoft.com\>
 * 
 */

class BezierBodyElt {
public:
    /**  Element types.
     */
    enum BezierBodyEltType {
        /**   Placeholder.
         */
        None,
              /**   T or E line.
               */
              BezierEnd,
              /**   S line.
               */
              BezierStraightSegment, 
              /**   C line.
               */
              BezierCurvedSegment
          };
private:
    /**  Counter for S and C segments.
     */
    static int segCount;
    /**  Element type.
     */
    BezierBodyEltType theType;
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
    BezierBodyElt() {theType = None;theEnd=NULL;}
    /** @brief Destructor. */
    ~BezierBodyElt() {}
    /**  Type accessor. */
    BezierBodyEltType TheType() const {return theType;}
    /**  Create an endpoint (T or E lines). */
    static inline BezierBodyElt *MakeTrackEnd(TrackBodyElt *tbe)
    {
        BezierBodyElt *result = new BezierBodyElt();
        result->theType = BezierEnd;
        result->theEnd = tbe;
        return result;
    }
    /**  Create a straight segment (S lines). */
    static inline BezierBodyElt *MakeStraightSegment(float x1,float y1,float x2,float y2)
    {
        BezierBodyElt *result = new BezierBodyElt();
        result->theType = BezierStraightSegment;
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
    static inline BezierBodyElt *MakeCurveSegment(float r,float x,float y,float a0,float a1)
    {
        BezierBodyElt *result = new BezierBodyElt();
        result->theType = BezierCurvedSegment;
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
    friend class BezierBody;
};

/** List of Bezier body lines (T, E, S, and C lines).
 *
 * @author Robert Heller \<heller\@deepsoft.com\>
 * 
 */

class BezierBody {
private:
    /**  Current element. */
    BezierBodyElt *element;
    /**  Next element. */
    BezierBody *next;
    /**  Free up memory. */
    inline void CleanUpElement()
    {
        switch (element->theType) {
        case BezierBodyElt::BezierEnd:
            delete element->theEnd;
            break;
        case BezierBodyElt::BezierStraightSegment:
        case BezierBodyElt::BezierCurvedSegment:
        case BezierBodyElt::None: break;
        }
    }
public:
    /** @brief Basic constructor. */
    BezierBody (BezierBodyElt *e, BezierBody*n) {element = e; next = n;}
    /**  Alternitive constructor function. */
    static inline BezierBody *ConsBezierBody(BezierBodyElt *trbe, BezierBody* trb)
    {
        BezierBody *result = new BezierBody(trbe,trb);
        return result;
    }
    friend class BezierBodyElt;
    /**  Create a track endpoint list.
     */
    inline TrackBody *BezierEnds()
    {
        TrackBody *result = NULL;
        BezierBody *trb;
        for (trb = this;trb != NULL;trb = trb->next) {
            if (trb->element->theType != BezierBodyElt::BezierEnd) continue;
            result = TrackBody::AppendTrackBodyElt(result,trb->element->theEnd);
        }
        return result;
    }
    /**  Count segments (S, C, and J lines).
     */
    inline int BezierSegmentCount()
    {
        int count = 0;
        BezierBody *trb;
        for (trb = this;trb != NULL;trb = trb->next) {
            if (trb->element->theType == BezierBodyElt::BezierStraightSegment ||
                trb->element->theType == BezierBodyElt::BezierCurvedSegment) count++;
        }
        return count;
    }
    /**  Free up memory.
     */
    static inline void CleanUpBezierBody(BezierBody *trb)
    {
        BezierBody *ne;
        BezierBodyElt *elt;
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
    const inline BezierBodyElt *Element() const {return element;}
    friend class TrackGraph;
};

#undef angle
#undef len0
#undef len1

};

/** @} */


    

#endif // __BEZIERBODY_H

