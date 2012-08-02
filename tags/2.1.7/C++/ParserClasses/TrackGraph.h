/* 
 * ------------------------------------------------------------------
 * TrackGraph.h - Track Graph
 * Created by Robert Heller on Mon Sep 23 21:36:11 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.10  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.9  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.8  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
 * Modification History:
 * Modification History: Revision 1.7  2005/11/05 06:21:23  heller
 * Modification History: Final Sync
 * Modification History:
 * Modification History: Revision 1.6  2005/11/04 19:06:33  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.5  2004/03/13 15:49:49  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 1.4  2002/10/17 00:00:53  heller
 * Modification History: Add Documentation  (Doc++)
 * Modification History:
 * Modification History: Implement turnout body, track length, and turntable support.
 * Modification History:
 * Modification History: Revision 1.3  2002/09/25 23:56:50  heller
 * Modification History: Add in support for block gaps and turntables
 * Modification History:
 * Modification History: Revision 1.2  2002/09/25 01:54:53  heller
 * Modification History: Implement Tcl access to graph nodes.
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

#ifndef _TRACKGRAPH_H_
#define _TRACKGRAPH_H_

#include <iostream>
#ifndef SWIG
#if __GNUC__ > 2
using namespace std;
#endif
#endif
#include <TrackBody.h>
#include <TurnoutBody.h>

#ifdef SWIG
%typemap(tcl8,out) SegPos * {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	tcl_result = Tcl_GetObjResult(interp);
	Tcl_SetListObj(tcl_result,0,NULL);
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$source->x)) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$source->y)) != TCL_OK)
		return TCL_ERROR;
#else
	Tcl_Obj *tcl_result = $result
	Tcl_SetListObj(tcl_result,0,NULL);
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$1->x)) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$1->y)) != TCL_OK)
		return TCL_ERROR;
#endif
}

#else
///  Segment position, endpoint or other coordinate.
struct SegPos {
	/**   $X$ coordinate. */ float x;
	/**   $Y$ coordinate. */ float y;
};
#endif

#ifdef SWIG
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%readonly
#else
%immutable;
#endif
#endif
///  Segemnt structure.
struct SegVector {
	///  Graphic types.
	enum GrType {
		/**   Straight segment. */ S, 
		/**   Curved (circular) segment. */ C, 
		/**   Curved (spiral easement) segment. */J
	};
#ifndef SWIG
	/**   Segment type. */ GrType tgType;
#endif
	/**   First graphic position. */ SegPos gPos1;
	/**   Second graphic position. */ SegPos gPos2;
	/**   First end point position. */ SegPos ePos1;
	/**   Second end point position. */ SegPos ePos2;
	/**   Radius value. */ float radius;
	/**   First angle. */ float ang0;
	/**   Second angle. */float ang1;
	/**   $R$ value. */ float R;
	/**   $L$ value. */ float L;
	/**   An angle.. */ float angle;
	/**   First length parameter. */ float len0;
	/**   Second length parameter. */ float len1;
	/**   Length of segment. */ float length;
};

#ifdef SWIG
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%addmethods
#else
%extend
#endif
	 SegVector {
	const char *tgType() {
		switch (self->tgType) {
			case SegVector::S: return "SegVector::S"; break;
			case SegVector::C: return "SegVector::C"; break;
			case SegVector::J: return "SegVector::J"; break;
		}
		return NULL;
	}
};
#endif

/**  
  Structure holding a turnout's graphical information. 	 */
struct TurnoutGraphic {
	/**   Minimum $X$ coordinate. */ float minX;
	/**   Minimum $Y$ coordinate. */ float minY;
	/**   Maximum $X$ coordinate. */ float maxX;
	/**   Maximum $Y$ coordinate. */ float maxY;
	/**   Number of segments. */ int numSegments;
#ifndef SWIG
	///  Segment vector.
	SegVector *segments;
#endif
};

#ifdef SWIG
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%addmethods
#else
%extend
#endif
	 TurnoutGraphic {
	const SegVector *segmentI (int i) const {
		if (i < 0 || i >= self->numSegments) return NULL;
		else return &self->segments[i];
	}
};

%typemap(tcl8,out) IntegerList * {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	const IntegerList *p;
	tcl_result = Tcl_GetObjResult(interp);
	Tcl_SetListObj(tcl_result,0,NULL);
	for (p = $source; p != NULL; p = p->Next()) {
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewIntObj(p->Element())) != TCL_OK)
			return TCL_ERROR;
	}
#else
	const IntegerList *p;
	Tcl_Obj * tcl_result = $result;
	Tcl_SetListObj(tcl_result,0,NULL);
	for (p = $1; p != NULL; p = p->Next()) {
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewIntObj(p->Element())) != TCL_OK)
			return TCL_ERROR;
	}
#endif
}	
#endif

///  Route structure.
struct RouteVec {
	/**   Name of route. */ char *positionName;
	/**   List of segments used by the route. */ IntegerList *posList;
	/**   Length of the route. */ float routeLength;
};

///  Turnout route list structure.
struct TurnoutRoutelist {
	/**   Number of routes. */ int numRoutelists;
#ifndef SWIG
	///  Route vector.
	RouteVec *routes;
#endif
};

#ifdef SWIG
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%addmethods
#else
%extend
#endif
	 TurnoutRoutelist {
	const RouteVec *routeI (int i) const {
		if (i < 0 || i >= self->numRoutelists) return NULL;
		else return &self->routes[i];
	}
};
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%readwrite
#else
%mutable;
#endif
#endif

#ifndef SWIG
/**  
  Holds the track graph.  A simple hash table is used to hold the graph
  structure.  */
class TrackGraph {
public:
	/**  
	  Node types. */
	enum NodeType {
		/**   Plain trackage: straight, curved, or easement. */ Track, 
		/**   Turnout or crossing. */ Turnout, 
		/**   Turntable. */ Turntable
	};
private:
	///  Edge structure.
	struct Edge {
		/**   Index of edge. */ int index;
		/**   $X$ Coordinate of edge. */ float x;
		/**   $Y$ Coordinate of edge. */ float y;
		/**   Angle of edge. */ float a;
	};
	///  Node structure.
	struct Node {
		/**   Node Id. */ int nodeId;
		/**   Type of node. */ NodeType nodeType;
		/**   Number of edges. */ int numEdges;
		/**   Vector of edges. */ Edge *edges;
		/**   Graphic (turnouts only) of node. */ TurnoutGraphic *tgr;
		/**   Route list (turnouts only) of node. */ TurnoutRoutelist *tpo;
		/**   Next node in hash bucket list. */ Node *nextNode;
		/**   Length of node's trackage. */ float length;
	};
	///  Size of hash table.
	static const int ElementCount;
	///  The hash table itself.
	Node **nodeTable;
	///  Find a node in the hash table.
	Node *FindNode(int index) const;
	///  Free up the memory used by a turnout node's graphic.
	void DeleteTurnoutGraphic(TurnoutGraphic *tgr);
	///  Free up the memory used by a turnout node's route list.
	void DeleteTurnoutRouteList(TurnoutRoutelist *tpo);
	///  Generate a turnout node's graphic.
	TurnoutGraphic *MakeTurnoutGraphic(float orgX, float orgY, float orient, TurnoutBody *trb);
	///  Generate a turnout node's route list.
	TurnoutRoutelist *MakeTurnoutRouteList(TurnoutBody *trb,const TurnoutGraphic *tgr,float &length);
	///  Compute the length of a route.
	static float ComputeRouteLength(const TurnoutGraphic *tgr, const IntegerList *il);
public:
	///  Two dimensional transform class.
	class Transform2D {
	private:
		///  Transform matrix.
		float  matrix[3][3];
		///  Fuzz factor.
		const static float FUZZ = .00001;
	public:
		///  Matrix multiplication.
		friend Transform2D* operator * (const Transform2D& t1,const Transform2D& t2);
		///  Default constructor. Creates an identity tranform.
		Transform2D();   /* returns identity tranform */
		///  Full fledged constructor.
		Transform2D(float r11, float r12, float tx,
			    float r21, float r22, float ty,
			    float a0 = 0.0,  float a1 = 0.0,  float s = 1.0);
		///  Copy constructor.
		Transform2D(const Transform2D* ts);
		///  Return the determinant.
		float Determinant() const;
		///  Return the minor.
		float Minor(int, int) const;
		///  Return the inverse.
		Transform2D *Inverse() const;
		///  Apply a scaled transformation.
		void Apply(float x, float y, float s, float &tx, float &ty, float &ts) const;
		///  Apply a normal transformation/
		int Apply(float x, float y, float &tx, float &ty) const;
		///  Equality operator.
		int operator== (const Transform2D& other) const;
		///  Inequality operator.
		inline int operator!= (const Transform2D& other) const
			{return (!operator== (other));}
	};
private:
	///  Rotational units.
	enum RotationUnit {
		/**   Units are in degrees. */ Degrees, 
		/**   Units are in radians. */ Radians
	};
	///  Construct a translation transform.
	Transform2D *tr_translate(float x, float y);
	///  Construct a uniform scale transform.
	Transform2D *tr_scale(float mag_factor);
	///  Construct a non-uniform scale transform.
	Transform2D *tr_scale(float xscale, float yscale);
	///  Construct a rotational transform.
	Transform2D *tr_rotate(float amount, RotationUnit measure);
public:
	///  Constructor.
	TrackGraph();
	///  Destructor.
	~TrackGraph();
	///  Insert a (circular) curved piece of track.
	void InsertCurveTrack(int number,TrackBody *tb,float orgX,float orgY,float radius);
	///  Insert a straight piece of track.
	void InsertStraightTrack(int number,TrackBody *tb);
	///  Insert a (spiral) curved piece of track.
	void InsertJointTrack(int number,TrackBody *tb,float l0, float l1, float angle, float R, float L);
	///  Insert a turnout or crossing.
	void InsertTurnOut(int number, float orgX, float orgY, float orient,
			   const char *name,TurnoutBody *trb);
	///  Insert a turntable.
	void InsertTurnTable(int number, float orgX, float orgY, float radius,
			     TrackBody *tb);
	///  Compute the length of a piece of straight track.
	static float LengthOfStraight(float x1, float y1, float x2, float y2);
	///  Compute the length of a (circular) curved piece of track.
	static float LengthOfCurve(float radius, float a1, float a2);
	///  Compute the length of a (spiral) curved piece of track.
	static float LengthOfJoint(float l0, float l1, float angle, float R, float L);
	///  Output operator.
	friend ostream& operator << (ostream& stream,TrackGraph& graph);
	///  Tests if a node id exists in the graph.
	bool IsNodeP(int nid);
	///  Returns the number of edges for the specificed node id.
	int NumEdges(int nid);
	///  Returns the node id of the specificed edge of the node.
	int EdgeIndex(int nid, int edgenum);
	///  Returns the $X$ coordinate of the specificed edge of the node.
	float EdgeX(int nid, int edgenum);
	///  Returns the $Y$ coordinate of the specificed edge of the node.
	float EdgeY(int nid, int edgenum);
	///  Returns the angle of the specificed edge of the node.
	float EdgeA(int nid, int edgenum);
	///  Returns the type of the node.
	NodeType TypeOfNode(int nid);
	///  Returns the TurnoutGraphic of the node.
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const;
	///  Returns the TurnoutRoutelist of the node.
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const;
	///  Return the track length of a node.
	float LengthOfNode(int nid);
	///  Returns the lowest numbered node id.
	int LowestNode();
	///  Returns the highest numbered node id.
	int HighestNode();
};

#endif


#endif // _TRACKGRAPH_H_

