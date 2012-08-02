/* 
 * ------------------------------------------------------------------
 * TrackGraph.h - Track Graph
 * Created by Robert Heller on Mon Sep 23 21:36:11 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

#include <iostream.h>
#include <TrackBody.h>
#include <TurnoutBody.h>

//@ManDoc: Segment position, endpoint or other coordinate.
struct SegPos {
	/*@ManDoc: $X$ coordinate. */ float x;
	/*@ManDoc: $Y$ coordinate. */ float y;
};

//@ManDoc: Segemnt structure.
struct SegVector {
	//@ManDoc: Graphic types.
	enum GrType {
		/*@ManDoc: Straight segment. */ S, 
		/*@ManDoc: Curved (circular) segment. */ C, 
		/*@ManDoc: Curved (spiral easement) segment. */J
	};
	/*@ManDoc: Segment type. */ GrType tgType;
	/*@ManDoc: First graphic position. */ SegPos gPos1;
	/*@ManDoc: Second graphic position. */ SegPos gPos2;
	/*@ManDoc: First end point position. */ SegPos ePos1;
	/*@ManDoc: Second end point position. */ SegPos ePos2;
	/*@ManDoc: Radius value. */ float radius;
	/*@ManDoc: First angle. */ float ang0;
	/*@ManDoc: Second angle. */float ang1;
	/*@ManDoc: $R$ value. */ float R;
	/*@ManDoc: $L$ value. */ float L;
	/*@ManDoc: An angle.. */ float angle;
	/*@ManDoc: First length parameter. */ float len0;
	/*@ManDoc: Second length parameter. */ float len1;
	/*@ManDoc: Length of segment. */ float length;
};

/*@ManDoc:
  Structure holding a turnout's graphical information. 	 */
struct TurnoutGraphic {
	/*@ManDoc: Minimum $X$ coordinate. */ float minX;
	/*@ManDoc: Minimum $Y$ coordinate. */ float minY;
	/*@ManDoc: Maximum $X$ coordinate. */ float maxX;
	/*@ManDoc: Maximum $Y$ coordinate. */ float maxY;
	/*@ManDoc: Number of segments. */ int numSegments;
	//@ManDoc: Segment vector.
	SegVector *segments;
};

//@ManDoc: Route structure.
struct RouteVec {
	/*@ManDoc: Name of route. */ char *positionName;
	/*@ManDoc: List of segments used by the route. */ IntegerList *posList;
	/*@ManDoc: Length of the route. */ float routeLength;
};

//@ManDoc: Turnout route list structure.
struct TurnoutRoutelist {
	/*@ManDoc: Number of routes. */ int numRoutelists;
	//@ManDoc: Route vector.
	RouteVec *routes;
};

/*@ManDoc:
  Holds the track graph.  A simple hash table is used to hold the graph
  structure.  */
class TrackGraph {
public:
	/*@ManDoc:
	  Node types. */
	enum NodeType {
		/*@ManDoc: Plain trackage: straight, curved, or easement. */ Track, 
		/*@ManDoc: Turnout or crossing. */ Turnout, 
		/*@ManDoc: Turntable. */ Turntable
	};
private:
	//@ManDoc: Edge structure.
	struct Edge {
		/*@ManDoc: Index of edge. */ int index;
		/*@ManDoc: $X$ Coordinate of edge. */ float x;
		/*@ManDoc: $Y$ Coordinate of edge. */ float y;
		/*@ManDoc: Angle of edge. */ float a;
	};
	//@ManDoc: Node structure.
	struct Node {
		/*@ManDoc: Node Id. */ int nodeId;
		/*@ManDoc: Type of node. */ NodeType nodeType;
		/*@ManDoc: Number of edges. */ int numEdges;
		/*@ManDoc: Vector of edges. */ Edge *edges;
		/*@ManDoc: Graphic (turnouts only) of node. */ TurnoutGraphic *tgr;
		/*@ManDoc: Route list (turnouts only) of node. */ TurnoutRoutelist *tpo;
		/*@ManDoc: Next node in hash bucket list. */ Node *nextNode;
		/*@ManDoc: Length of node's trackage. */ float length;
	};
	//@ManDoc: Size of hash table.
	static const int ElementCount;
	//@ManDoc: The hash table itself.
	Node **nodeTable;
	//@ManDoc: Find a node in the hash table.
	Node *FindNode(int index) const;
	//@ManDoc: Free up the memory used by a turnout node's graphic.
	void DeleteTurnoutGraphic(TurnoutGraphic *tgr);
	//@ManDoc: Free up the memory used by a turnout node's route list.
	void DeleteTurnoutRouteList(TurnoutRoutelist *tpo);
	//@ManDoc: Generate a turnout node's graphic.
	TurnoutGraphic *MakeTurnoutGraphic(float orgX, float orgY, float orient, TurnoutBody *trb);
	//@ManDoc: Generate a turnout node's route list.
	TurnoutRoutelist *MakeTurnoutRouteList(TurnoutBody *trb,const TurnoutGraphic *tgr,float &length);
	//@ManDoc: Compute the length of a route.
	static float ComputeRouteLength(const TurnoutGraphic *tgr, const IntegerList *il);
public:
	//@ManDoc: Two dimensional transform class.
	class Transform2D {
	private:
		//@ManDoc: Transform matrix.
		float  matrix[3][3];
		//@ManDoc: Fuzz factor.
		const static float FUZZ = .00001;
	public:
		//@ManDoc: Matrix multiplication.
		friend Transform2D* operator * (const Transform2D& t1,const Transform2D& t2);
		//@ManDoc: Default constructor. Creates an identity tranform.
		Transform2D();   /* returns identity tranform */
		//@ManDoc: Full fledged constructor.
		Transform2D(float r11, float r12, float tx,
			    float r21, float r22, float ty,
			    float a0 = 0.0,  float a1 = 0.0,  float s = 1.0);
		//@ManDoc: Copy constructor.
		Transform2D(const Transform2D* ts);
		//@ManDoc: Return the determinant.
		float Determinant() const;
		//@ManDoc: Return the minor.
		float Minor(int, int) const;
		//@ManDoc: Return the inverse.
		Transform2D *Inverse() const;
		//@ManDoc: Apply a scaled transformation.
		void Apply(float x, float y, float s, float &tx, float &ty, float &ts) const;
		//@ManDoc: Apply a normal transformation/
		int Apply(float x, float y, float &tx, float &ty) const;
		//@ManDoc: Equality operator.
		int operator== (const Transform2D& other) const;
		//@ManDoc: Inequality operator.
		inline int operator!= (const Transform2D& other) const
			{return (!operator== (other));}
	};
private:
	//@ManDoc: Rotational units.
	enum RotationUnit {
		/*@ManDoc: Units are in degrees. */ Degrees, 
		/*@ManDoc: Units are in radians. */ Radians
	};
	//@ManDoc: Construct a translation transform.
	Transform2D *tr_translate(float x, float y);
	//@ManDoc: Construct a uniform scale transform.
	Transform2D *tr_scale(float mag_factor);
	//@ManDoc: Construct a non-uniform scale transform.
	Transform2D *tr_scale(float xscale, float yscale);
	//@ManDoc: Construct a rotational transform.
	Transform2D *tr_rotate(float amount, RotationUnit measure);
public:
	//@ManDoc: Constructor.
	TrackGraph();
	//@ManDoc: Destructor.
	~TrackGraph();
	//@ManDoc: Insert a (circular) curved piece of track.
	void InsertCurveTrack(int number,TrackBody *tb,float orgX,float orgY,float radius);
	//@ManDoc: Insert a straight piece of track.
	void InsertStraightTrack(int number,TrackBody *tb);
	//@ManDoc: Insert a (spiral) curved piece of track.
	void InsertJointTrack(int number,TrackBody *tb,float l0, float l1, float angle, float R, float L);
	//@ManDoc: Insert a turnout or crossing.
	void InsertTurnOut(int number, float orgX, float orgY, float orient,
			   const char *name,TurnoutBody *trb);
	//@ManDoc: Insert a turntable.
	void InsertTurnTable(int number, float orgX, float orgY, float radius,
			     TrackBody *tb);
	//@ManDoc: Compute the length of a piece of straight track.
	static float LengthOfStraight(float x1, float y1, float x2, float y2);
	//@ManDoc: Compute the length of a (circular) curved piece of track.
	static float LengthOfCurve(float radius, float a1, float a2);
	//@ManDoc: Compute the length of a (spiral) curved piece of track.
	static float LengthOfJoint(float l0, float l1, float angle, float R, float L);
	//@ManDoc: Output operator.
	friend ostream& operator << (ostream& stream,TrackGraph& graph);
	//@ManDoc: Tests if a node id exists in the graph.
	bool IsNodeP(int nid);
	//@ManDoc: Returns the number of edges for the specificed node id.
	int NumEdges(int nid);
	//@ManDoc: Returns the node id of the specificed edge of the node.
	int EdgeIndex(int nid, int edgenum);
	//@ManDoc: Returns the $X$ coordinate of the specificed edge of the node.
	float EdgeX(int nid, int edgenum);
	//@ManDoc: Returns the $Y$ coordinate of the specificed edge of the node.
	float EdgeY(int nid, int edgenum);
	//@ManDoc: Returns the angle of the specificed edge of the node.
	float EdgeA(int nid, int edgenum);
	//@ManDoc: Returns the type of the node.
	NodeType TypeOfNode(int nid);
	//@ManDoc: Returns the TurnoutGraphic of the node.
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const;
	//@ManDoc: Returns the TurnoutRoutelist of the node.
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const;
	//@ManDoc: Return the track length of a node.
	float LengthOfNode(int nid);
	//@ManDoc: Returns the lowest numbered node id.
	int LowestNode();
	//@ManDoc: Returns the highest numbered node id.
	int HighestNode();
};




#endif // _TRACKGRAPH_H_

