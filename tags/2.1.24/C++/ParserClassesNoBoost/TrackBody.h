/* 
 * ------------------------------------------------------------------
 * TrackBody.h - Track Body
 * Created by Robert Heller on Mon Sep 23 21:55:16 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.4  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.3  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
 * Modification History:
 * Modification History: Revision 1.2  2002/10/17 00:00:53  heller
 * Modification History: Add Documentation  (Doc++)
 * Modification History:
 * Modification History: Implement turnout body, track length, and turntable support.
 * Modification History:
 * Modification History: Revision 1.1  2002/09/24 04:20:18  heller
 * Modification History: MRRXtrkCad => TrackGraph
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

#ifndef _TRACKBODY_H_
#define _TRACKBODY_H_

#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif

/** @addtogroup ParserClasses
  * @{
  */

class TrackGraph;

/** Track endpoint elements (T and E lines).
  */
class TrackBodyElt {
private:
	/**  Index of connected track (T lines only).
	  */
	int index;
	/**  $X$ coordinate of track endpoint.
	  */
	float x;
	/**  $Y$ coordinate of track endpoint.
	  */
	float y;
	/**  Angle of track endpoint.
	  */
	float a;
public:
	/** @brief Constructor.
	  */
	TrackBodyElt(int ind=-1,float X=-1.0,float Y=-1.0,float A=0.0) {
		index = ind; x = X; y = Y;a = A;}
	/** @brief Destructor.
	  */
	~TrackBodyElt() {}
	/**  Create a connected track endpoint.
	  */
	static inline TrackBodyElt *ConnectedTrackEnd(int ind, float X, float Y,float A)
		{TrackBodyElt *result = new TrackBodyElt();
		 result->index = ind;
		 result->x = X;
		 result->y = Y;
		 result->a = A;
		 return result;
		}
	/**  Create a unconnected track endpoint.
	  */
	static inline TrackBodyElt *UnConnectedTrackEnd(float X, float Y,float A)
		{TrackBodyElt *result = new TrackBodyElt();
		 result->x = X;
		 result->y = Y;
		 result->a = A;
		 return result;
		}
	/**  Output operator.
	  */
	friend inline ostream& operator << (ostream& stream,TrackBodyElt& elt)
		{
			if (elt.index > 0) stream << "T " << elt.index << " ";
			else stream << "E ";
			stream << elt.x << " " << elt.y << endl;
			return stream;
		}
	friend class TrackGraph;
};

/** List of track endpoints (T and E lines).
  */
class TrackBody {
private:
	/**  Current element.
	  */
	TrackBodyElt *element;
	/**  Next element.
	  */
	TrackBody    *next;
public:
	/** @brief Constructor.
	  */
	TrackBody(TrackBodyElt* Element,TrackBody *Next) {
		element = Element; next = Next;}
	/** @brief Destructor.
	  */
	~TrackBody() {}
	/**  Prepend a track endpoint.
	  */
	static inline TrackBody *ConsTrackBody(TrackBodyElt* tbe,TrackBody *tb)
		{
			TrackBody *result = new TrackBody(tbe,tb);
			return result;
		}
	/**  Append a track endpoint.
	  */
	static inline TrackBody *AppendTrackBodyElt(TrackBody *tb,TrackBodyElt* tbe)
		{
			if (tb == NULL) return new TrackBody(tbe,tb);
			else {
				TrackBody **rptr = &tb->next;
				while (*rptr != NULL) {
					rptr = &((*rptr)->next);
				}
				*rptr = new TrackBody(tbe,NULL);
				return tb;
			}
		}
	/**  Output operator.
	  */
	friend inline ostream& operator << (ostream& stream,TrackBody& track)
		{
			stream << track.element;
			if (track.next == NULL) stream << "END" << endl;
			else stream << track.next;
			return stream;
		}
	/**  Compute the count of track endpoints.
	  */
	static inline int TrackBodyLength (const TrackBody *tb)
		{
			int count = 0;
			while (tb != NULL) {
				count++;
				tb = tb->next;
			}
			return count;
		}
	friend class TrackGraph;
};

/** @} */

#endif // _TRACKBODY_H_

