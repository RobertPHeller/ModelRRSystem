/* 
 * ------------------------------------------------------------------
 * TrackGraph.h - Track Graph
 * Created by Robert Heller on Mon Sep 23 21:36:11 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.3  2007/02/21 21:03:10  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.2  2007/02/21 20:25:28  heller
 * Modification History: SWIG Hackery
 * Modification History:
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
#include <boost/config.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <list>
using namespace boost;
#endif
#include <TrackBody.h>
#include <TurnoutBody.h>

/** @addtogroup ParserClasses
  * @{
  */

namespace Parsers {

#ifdef SWIG
%typemap(tcl8,out) SegPos * {
	Tcl_Obj *tcl_result = $result;
	Tcl_SetListObj(tcl_result,0,NULL);
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$1->x)) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$1->y)) != TCL_OK)
		return TCL_ERROR;
}
%typemap(tcl8,out) SegPos {
	Tcl_Obj *tcl_result = $result;
	Tcl_SetListObj(tcl_result,0,NULL);
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$1.x)) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewDoubleObj((double)$1.y)) != TCL_OK)
		return TCL_ERROR;
}

#else
/**  Segment position, endpoint or other coordinate.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
struct SegPos {
	/**   $X$ coordinate.
	  */
	float x;
	/**   $Y$ coordinate.
	  */
	float y;
};
#endif

#ifdef SWIG
%immutable SegVector::gPos1;
%immutable SegVector::gPos2;
%immutable SegVector::ePos1;
%immutable SegVector::ePos2;
%immutable SegVector::radius;
%immutable SegVector::ang0;
%immutable SegVector::ang1;
%immutable SegVector::R;
%immutable SegVector::L;
%immutable SegVector::angle;
%immutable SegVector::len0;
%immutable SegVector::len1;
%immutable SegVector::length;
#endif
/**  Segemnt structure.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
struct SegVector {
	/**  Graphic types.
	  */
	enum GrType {
		/**   Straight segment.
		  */
		S, 
		/**   Curved (circular) segment.
		  */
		C, 
		/**   Curved (spiral easement) segment.
		*/
		J
	};
#ifndef SWIG
	/**   Segment type.
	  */
	GrType tgType;
#endif
	/**   First graphic position.
	  */
	SegPos gPos1;
	/**   Second graphic position.
	  */
	SegPos gPos2;
	/**   First end point position.
	  */
	SegPos ePos1;
	/**   Second end point position.
	  */ 
	SegPos ePos2;
	/**   Radius value.
	  */
	float radius;
	/**   First angle.
	  */
	float ang0;
	/**   Second angle.
	  */
	float ang1;
	/**   $R$ value.
	  */
	float R;
	/**   $L$ value.
	  */
	float L;
	/**   An angle.
	  */
	float angle;
	/**   First length parameter.
	  */
	float len0;
	/**   Second length parameter.
	  */
	float len1;
	/**   Length of segment.
	  */
	float length;
#ifdef SWIG
	%extend {
		/** @brief Segment type accessor for Tcl.
		  * Returns the segment type.
		  */
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
};

#ifdef SWIG
%immutable TurnoutGraphic::minX;
%immutable TurnoutGraphic::minY;
%immutable TurnoutGraphic::maxX;
%immutable TurnoutGraphic::maxY;
%immutable TurnoutGraphic::numSegments;
#endif

/**  Structure holding a turnout's graphical information.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
struct TurnoutGraphic {
	/**   Minimum $X$ coordinate.
	  */
	float minX;
	/**   Minimum $Y$ coordinate.
	  */
	float minY;
	/**   Maximum $X$ coordinate.
	  */
	float maxX;
	/**   Maximum $Y$ coordinate.
	  */
	float maxY;
	/**   Number of segments.
	  */
	int numSegments;
#ifndef SWIG
	/**  Segment vector.
	  */
	SegVector *segments;
#else
	%extend {
		/** @brief Tcl SegVector indexed accessor.
		  * Returns the ith segment from the vector of segments.
		  * @param i The segment index.
		  */
		const SegVector *segmentI (int i) const {
			if (i < 0 || i >= self->numSegments) return NULL;
			else return &self->segments[i];
		}
	};
#endif		
};

#ifdef SWIG
%typemap(tcl8,out) IntegerList * {
	const IntegerList *p;
	Tcl_Obj * tcl_result = $result;
	Tcl_SetListObj(tcl_result,0,NULL);
	for (p = $1; p != NULL; p = p->Next()) {
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewIntObj(p->Element())) != TCL_OK)
			return TCL_ERROR;
	}
}	
#endif
#ifdef SWIG
%immutable RouteVec::positionName;
%immutable RouteVec::posList;
%immutable RouteVec::routeLength;
#endif

/**  Route structure.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
struct RouteVec {
	/**   Name of route.
	  */
	char *positionName;
	/**   List of segments used by the route.
	  */
	IntegerList *posList;
	/**   Length of the route.
	  */
	float routeLength;
};

#ifdef SWIG
%immutable TurnoutRoutelist::numRoutelists;
#endif

/**  Turnout route list structure.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
struct TurnoutRoutelist {
	/**   Number of routes.
	  */
	int numRoutelists;
#ifndef SWIG
	/**  Route vector.
	  */
	RouteVec *routes;
#else
	%extend {
		/** @brief Tcl RouteVec indexed accessor.
		  * Returns the ith RouteVec from the vector of routes.
		  * @param i The route index.
		  */
		const RouteVec *routeI (int i) const {
			if (i < 0 || i >= self->numRoutelists) return NULL;
			else return &self->routes[i];
		}
	};
#endif
};

#ifndef SWIG

#ifdef SERIALIZATION
namespace boost {
namespace serialization {

template<class Archive>
void serialize(Archive & ar, SegPos & seg, const unsigned int version)
{
	ar & seg.x;
	ar & seg.y;
}

template<class Archive>
void serialize(Archive & ar, SegVector & segvec, const unsigned int version)
{
	ar & segvec.tgType;
	ar & segvec.gPos1;
	ar & segvec.gPos2;
	ar & segvec.ePos1;
	ar & segvec.ePos2;
	ar & segvec.radius;
	ar & segvec.ang0;
	ar & segvec.ang1;
	ar & segvec.R;
	ar & segvec.L;
	ar & segvec.angle;
	ar & segvec.len0;
	ar & segvec.len1;
	ar & segvec.length;	
}

template<class Archive>
void serialize(Archive & ar, TurnoutGraphic & tgr, const unsigned int version)
{
	ar & tgr.minX;
	ar & tgr.minY;
	ar & tgr.maxX;
	ar & tgr.maxY;
	ar & tgr.numSegments;
	ar & tgr.segments;
}

template<class Archive>
void serialize(Archive & ar, RouteVec & routevec, const unsigned int version)
{
	ar & routevec.positionName;
	ar & routevec.posList;
	ar & routevec.routeLength;
}

template<class Archive>
void serialize(Archive & ar, TurnoutRoutelist & trl, const unsigned int version)
{
	ar & trl.numRoutelists;
	ar & trl.routes;
}

} // namespace serialization
} // namespace boost

#endif

#ifdef SWIG
%typemap(tcl8,out) TrackGraph::CompressedEdgePairVector {
	TrackGraph::CompressedEdgePairVector::const_iterator p;
	Tcl_Obj * tcl_result = $result;
	Tcl_SetListObj(tcl_result,0,NULL);
	for (p = $1->begin(); p != $1->end(); ++p)
	{
		Tcl_Obj * pair = Tcl_NewListObj(0,NULL);
		if (Tcl_ListObjAppendElement(interp,pair,Tcl_NewIntObj(p->first)) != TCL_OK)
			return TCL_ERROR;
		if (Tcl_ListObjAppendElement(interp,pair,Tcl_NewIntObj(p->second)) != TCL_OK)
			return TCL_ERROR;
		if (Tcl_ListObjAppendElement(interp,tcl_result,pair) != TCL_OK)
			return TCL_ERROR;
	}
}
#endif

/** @brief Track Graph class, which encapsulates the track graphs.
  *
  * Holds the two track graphs, an uncompressed, directed graph built
  * from the layout file and a compressed, undirected graph where successive
  * segments of plain trackage are collasped into a single node. Both graphs
  * use the Boost Graph Library adjacency_list template class as the basic graph
  * implementation class.  All nodes in both graphs have a unique node id,
  * which is the XTrkCad layout object number.
  *
  * Several of the Boost Graph Library graph algorithms are implemented,
  * including circle_graph_layout(), kamada_kawai_spring_layout(),
  * kruskal_minimum_spanning_tree() and prim_minimum_spanning_tree(). In
  * addition, the strong_components() algorithm is used to gather nodes into 
  * one or more connected groups, since sometimes model train layouts have 
  * disjoint sections of track.  An example would be a regular main line and an
  * isolated mining or logging railroad.  Another example would be a regular
  * main line and one (or more) mass transit (eg trolley) line(s). The head
  * nodes of the collected groups are accessed with the member function Heads(),
  * which returns a list of nodes that are the heads of each of the connected
  * groups. The CompressGraph() function will compress each connected group
  * into a separately compressed graph, with its own root node.  The root nodes
  * of each of the compressed sub-graphs are returned with the Roots() member
  * function.
  *
  * The compuation of connected groups and graph compression are implemented
  * using a lazy eval methodolgy.  The connected group collection process is
  * not run until the member function Heads() is called to actually access the
  * list of group heads.  And the graph compression is not called until the
  * member function Roots() is called.  Calling the CompressGraph() member
  * function (or the Roots() member function), will also call the connected
  * group collection process if it is needed.
  *
  * To help discover possible mainlines, two minimum spanning tree (MST)
  * algorithms are provided, Kruskal's and Prim's, via the member functions
  * CompressedGraphKruskalMinimumSpanningTree() and
  * CompressedGraphPrimMinimumSpanningTree(), respectively.  Both of these
  * function return a list of edge pairs: a STL vector of STL pairs of compressed
  * nodes.
  *
  * Two graphical layout algorithms are also provided, circle graph layout and
  * kamada kawai spring layout, via the two member functions,
  * CompressedGraphCircleLayout() and CompressedGraphKamadaKawaiSpring(),
  * respectively.  Both set or update a pair of double values $(x,y)$ associated
  * with every compressed node and which are accessed with the
  * CompressedNodePositionX() and CompressedNodePositionY() member functions.
  * CompressedGraphCircleLayout() sets these files and
  * CompressedGraphKamadaKawaiSpring() updates them. 
  * CompressedGraphCircleLayout() should be called before
  * CompressedGraphKamadaKawaiSpring().  CompressedGraphKamadaKawaiSpring()
  * returns a boolean flag indicating if it was able to create a layout.
  * Returning a false value indicates that the graph was disjoint --
  * CompressedGraphKamadaKawaiSpring() cannot be used with a disjoint
  * graph.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class TrackGraph {
public:
	/** Node types.
	  */
	enum NodeType {
		/**   Undefined type
		  */
		Undefined = -1,
		/**   Plain trackage: straight, curved, or easement.
		  */
		Track = 0, 
		/**   Turnout or crossing.
	          */ 
		Turnout, 
		/**   Turntable.
		  */
		Turntable,
		/**   Block.
		  */
		Block,
		/**   Switch Motor.
		  */
		SwitchMotor
	};

	typedef std::pair < int, int > CompressedEdgePair;
	typedef std::vector < CompressedEdgePair > CompressedEdgePairVector;
	
private:
	/** Uncompressed graph edge values.
	  *
	  * @author Robert Heller \<heller\@deepsoft.com\>
	  *
	  */
	struct EdgeValues {
		/** Index of next segment.
		  */
		int index;
		/** X value of edge.
		  */
		float x;
		/** Y value of edge.
		  */
		float y;
		/** A value of edge.
		  */
		float a;
		/** Track length from opposite edge.
		  */
		float length;
		/** Default constructor.
		  */
		EdgeValues(int _index = -1, float _x = 0.0, float _y = 0.0,
			   float _a = 0.0,float _length = 0.0)
		{ index = _index; x = _x; y = _y; a = _a; length = _length; }
#ifdef SERIALIZATION
		friend class boost::serialization::access;
		template<class Archive>
		void serialize(Archive & ar, const unsigned int version)
		{
			ar & index;
			ar & x;
			ar & y;
			ar & a;
			ar & length;
		}
#endif		    
	};
	/** Uncompressed graph node values.
	  *
	  * @author Robert Heller \<heller\@deepsoft.com\>
	  *
	  */
	struct NodeValues {
		/** Node number.
		  */
		int id;
		/** Type of node.
		  */
		NodeType type;
		/** Turnout graphic (if type is turnout).
		  */
		TurnoutGraphic *tgr;
		/** Turnout route list (if type is turnout).
		  */
		TurnoutRoutelist *tpo;
		/** Length of track.
		  */
		float length;
		/**   Track segments in block.
		  */
		IntegerList *tracklist;
		/**   Number of the turnout.
		  */
		int turnoutnumber;
		/**   Name of block or switch motor.
		  */
		char * name;
		/**   Sense Script (occupation / point).
		  */
		char * sensescript;
		/**   Normal action script.
		  */
		char * normalactionscript;
		/**   Reverse action script.
		  */
		char * reverseactionscript;
		/** Default constructor.
		  */
		NodeValues (int _id = -1, NodeType _type = Undefined,
			    TurnoutGraphic *_tgr = NULL,
			    TurnoutRoutelist *_tpo = NULL, float _length = 0.0,
			    IntegerList *_tracklist = NULL, 
			    int _turnoutnumber = 0, char *_name = NULL,
			    char * _sensescript = NULL, 
			    char * _normalactionscript = NULL,
			    char * _reverseactionscript = NULL)
		{ id = _id; type = _type; tgr = _tgr; tpo = _tpo;
		  length = _length; tracklist = _tracklist; 
		  turnoutnumber = _turnoutnumber; name = _name;
		  sensescript =  _sensescript; 
		  normalactionscript = _normalactionscript;
		  reverseactionscript =  _reverseactionscript;}
		/** Cleanup member function.
		  */
		void Cleanup()
		{
			if (tgr != NULL) DeleteTurnoutGraphic(tgr);
			tgr = NULL;
			if (tpo != NULL) DeleteTurnoutRouteList(tpo);
			tpo = NULL;
			if (tracklist != NULL) IntegerList::CleanUpIntegerList(tracklist);
			tracklist = NULL;
			if (name != NULL) delete name;
			name = NULL;
			if (sensescript != NULL) delete sensescript;
			sensescript = NULL;
			if (normalactionscript != NULL) delete normalactionscript;
			normalactionscript = NULL;
			if (reverseactionscript != NULL) delete reverseactionscript;
			reverseactionscript = NULL;
		}
#ifdef SERIALIZATION
		friend class boost::serialization::access;
		template<class Archive>
		void serialize(Archive & ar, const unsigned int version)
		{
			ar & id;
			ar & type;
			ar & tgr;
			ar & tpo;
			ar & length;
		}
#endif
	};

	/** Boost Graph type (adjacency_list).
	  */
	typedef adjacency_list < vecS, vecS, directedS, NodeValues , EdgeValues > Graph;
	/** Vertex type.
	  */
	typedef graph_traits < Graph >::vertex_descriptor Node;
	/** Type of Node Id map.
	  */
	typedef std::map < int, Node > IdNodeMap;

	/** Graph adjacency_list.
	  */
	Graph nodes;
	/** Node Id map.
	  */
	IdNodeMap idMap;
	/** Uncompressed graph heads (strong components).
	  */
	IntegerList *heads;
	/** Flag to indicate if heads is valid.
	  */
	bool valid_heads;
	/** Special node that is nowhere (where all unconnected trackage goes).
	  */
	Node none;
	/** Helper function to create a new node.
	  */
	Node AddNewNode(int id, NodeType _type = Undefined,
			TurnoutGraphic *_tgr = NULL, 
			TurnoutRoutelist *_tpo = NULL, float _length = 0.0);
	/** Compute uncompressed graph heads (calls strong_components).
	  */
	void computeHeads();
	/** Compressed graph edge values.
	  */
	struct CompressedEdgeValues {
		/** Track length from opposite edge.
		  *
		  * @author Robert Heller \<heller\@deepsoft.com\>
		  *
		  */
		float length;
		/** Default constructor.
		  */
		CompressedEdgeValues (float _length = 0.0)
		{ length = _length; }
	};
	/** Position structure.
	  *
	  * @author Robert Heller \<heller\@deepsoft.com\>
	  *
	  */
	struct Point {
		/** X coordinate.
		  */
		double x;
		/** Y coordinate.
		  */
		double y;
	};
	/** Compressed graph node values.
	  *
	  * @author Robert Heller \<heller\@deepsoft.com\>
	  *
	  */
	struct CompressedNodeValues {
		/** Node number.
		  */
		int id;
		/** Uncompressed head node for this compressed node.
		  */
		Node rawnode;
		/** Node's graphical position.
		  */
		Point position;
		/** List of uncompressed node ids.
		  */
		std::list<int> segments;
		/** Return the segment index for a given segment.
		  */
		int FindSegmentIndex(int segment) const
		{
			int result = 0;
			std::list<int>::const_iterator pos;
			for (pos = segments.begin();
			     pos != segments.end(); 
			     ++pos, ++result)
			{
				if (*pos == segment) return result;
			}
			return -1;
		}
		/** Default constructor.
		  */
		CompressedNodeValues (int _id = -1)
		{
			id = _id;
			position.x = 0.0;
			position.y = 0.0;
		}
	};
	/** Boost Compressed Graph type (adjacency_list).
	  */
	typedef adjacency_list < setS, vecS, undirectedS, CompressedNodeValues , CompressedEdgeValues > CompressedGraph;
	/** Compressed Graph Vertex type.
	  */
	typedef graph_traits < CompressedGraph >::vertex_descriptor CompressedNode;
	/** Type of Node Id map.
	  */
	typedef std::map < int, CompressedNode > CompressedIdNodeMap;

	/** Compressed Graph adjacency_list.
	  */
	CompressedGraph c_nodes;
	/** Node Id map.
	  */
	CompressedIdNodeMap c_idMap;
	/** Compressed Graph Roots.
	  */
	IntegerList *c_roots;
	/** Is graph compressed?
	  */
	bool compressedP;
	/** Has CompressedGraphCircleLayout been run?
	  */
	bool circleLayoutP;
	/** Has CompressedGraphKamadaKawaiSpring been run?
	  */
	bool KamadaKawaiSpringLayoutP;
	/** Backpointer map.
	  */
	std::map <Node, CompressedNode> backpointers;
	/** Insert a compressed graph node.
	  */
	CompressedNode insertCompressedNode (Node rawnode);
	typedef std::vector < graph_traits < CompressedGraph >::vertex_descriptor > CompressedNodeVector;
	/** Check if node is the none node;
	  */
	bool IsNone(Node node) {return node == none;}
	/** Traverse a PrimMST, starting at root r, inserting EdgePairs into
	    result.
	  */
	void traversePrimMST(CompressedEdgePairVector &result, CompressedNodeVector &parents, CompressedNode r) const;
	/**  Find a node in the hash table.
	  */
	Node FindNode(int index) const;
	/**  Free up the memory used by a turnout node's graphic.
	  */
	static void DeleteTurnoutGraphic(TurnoutGraphic *tgr);
	/**  Free up the memory used by a turnout node's route list.
	  */
	static void DeleteTurnoutRouteList(TurnoutRoutelist *tpo);
	/**  Generate a turnout node's graphic.
	  */
	TurnoutGraphic *MakeTurnoutGraphic(float orgX, float orgY, float orient, TurnoutBody *trb);
	/**  Generate a turnout node's route list.
	  */
	TurnoutRoutelist *MakeTurnoutRouteList(TurnoutBody *trb,const TurnoutGraphic *tgr,float &length);
	/**  Compute the length of a route.
	  */
	static float ComputeRouteLength(const TurnoutGraphic *tgr, const IntegerList *il);
public:
	/**  Two dimensional transform class.
	  *
	  * @author Robert Heller \<heller\@deepsoft.com\>
	  *
	  */
	class Transform2D {
	private:
		/**  Transform matrix.
		  */
		float  matrix[3][3];
		/**  Fuzz factor.
		  */
		const static float FUZZ = .00001;
	public:
		/**  Matrix multiplication.
		  */
		friend Transform2D* operator * (const Transform2D& t1,const Transform2D& t2);
		/**  Default constructor. Creates an identity tranform.
		  */
		Transform2D();   /* returns identity tranform */
		/**  Full fledged constructor.
		  */
		Transform2D(float r11, float r12, float tx,
			    float r21, float r22, float ty,
			    float a0 = 0.0,  float a1 = 0.0,  float s = 1.0);
		/**  Copy constructor.
		  */
		Transform2D(const Transform2D* ts);
		/**  Return the determinant.
		  */
		float Determinant() const;
		/**  Return the minor.
		  */
		float Minor(int, int) const;
		/**  Return the inverse.
		  */
		Transform2D *Inverse() const;
		/**  Apply a scaled transformation.
		  */
		void Apply(float x, float y, float s, float &tx, float &ty, float &ts) const;
		/**  Apply a normal transformation/
		  */
		int Apply(float x, float y, float &tx, float &ty) const;
		/**  Equality operator.
		  */
		int operator== (const Transform2D& other) const;
		/**  Inequality operator.
		  */
		inline int operator!= (const Transform2D& other) const
			{return (!operator== (other));}
	};
private:
	/**  Rotational units.
	  */
	enum RotationUnit {
		/**   Units are in degrees. */ Degrees, 
		/**   Units are in radians. */ Radians
	};
	/**  Construct a translation transform.
	  */
	Transform2D *tr_translate(float x, float y);
	/**  Construct a uniform scale transform.
	  */
	Transform2D *tr_scale(float mag_factor);
	/**  Construct a non-uniform scale transform.
	  */
	Transform2D *tr_scale(float xscale, float yscale);
	/**  Construct a rotational transform.
	  */
	Transform2D *tr_rotate(float amount, RotationUnit measure);
public:
	/** @brief Constructor.
	  */
	TrackGraph();
	/** @brief Destructor.
	  */
	~TrackGraph();
	/**  Insert a (circular) curved piece of track.
	  */
	void InsertCurveTrack(int number,TrackBody *tb,float orgX,float orgY,float radius);
	/**  Insert a straight piece of track.
	  */
	void InsertStraightTrack(int number,TrackBody *tb);
	/**  Insert a (spiral) curved piece of track.
	  */
	void InsertJointTrack(int number,TrackBody *tb,float l0, float l1, float angle, float R, float L);
	/**  Insert a turnout or crossing.
	  */
	void InsertTurnOut(int number, float orgX, float orgY, float orient,
			   const char *name,TurnoutBody *trb);
	/**  Insert a turntable.
	  */
	void InsertTurnTable(int number, float orgX, float orgY, float radius,
			     TrackBody *tb);
	/**  Insert a Block.
	  */
	void InsertBlock(int number, char * _name, char * _script, IntegerList *_tracklist);
	/**  Insert a switch motor.
	  */
	void InsertSwitchMotor(int number, int turnout, char * _name, char * _normal, char * _reverse, char * _pointsense);
	/**  Compute the length of a piece of straight track.
	  */
	static float LengthOfStraight(float x1, float y1, float x2, float y2);
	/**  Compute the length of a (circular) curved piece of track.
	  */
	static float LengthOfCurve(float radius, float a1, float a2);
	/**  Compute the length of a (spiral) curved piece of track.
	  */
	static float LengthOfJoint(float l0, float l1, float angle, float R, float L);
	/**  Output operator.
	  */
	friend std::ostream& operator << (ostream& stream,TrackGraph& graph);
	/**  Tests if a node id exists in the graph.
	  */
	bool IsNodeP(int nid) const;
	/**  Returns the number of edges for the specificed node id.
	  */
	int NumEdges(int nid) const;
	/**  Returns the node id of the specificed edge of the node.
	  */
	int EdgeIndex(int nid, int edgenum) const;
	/**  Returns the $X$ coordinate of the specificed edge of the node.
	  */
	float EdgeX(int nid, int edgenum) const;
	/**  Returns the $Y$ coordinate of the specificed edge of the node.
	  */
	float EdgeY(int nid, int edgenum) const;
	/**  Returns the angle of the specificed edge of the node.
	  */
	float EdgeA(int nid, int edgenum) const;
	/** Returns the length of an edge.
	  */
	float EdgeLength(int nid, int edgenum) const;
	/**  Returns the type of the node.
	  */
	NodeType TypeOfNode(int nid) const;
	/**  Returns the TurnoutGraphic of the node.
	  */
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const;
	/**  Returns the TurnoutRoutelist of the node.
	  */
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const;
	/**  Return the track length of a node.
	  */
	float LengthOfNode(int nid) const;
	/**  Return a block's tracklist.
	  */
	const IntegerList *TrackList(int nid) const;
	/**  Return a switchmotor's turnout number.
	  */
	int TurnoutNumber(int nid) const;
	/**  Return a block's or switchmotor's name.
	  */
	const char * NameOfNode(int nid) const;
	/**  Return a block's or switchmotor's sense script.
	  */
	const char * SenseScript(int nid) const;
	/**  Return a switchmotor's normal action script.
	  */
	const char * NormalActionScript(int nid) const;
	/**  Return a block's or switchmotor's reverse action script.
	  */
	const char * ReverseActionScript(int nid) const;
	/**  Returns the lowest numbered node id.
	  */
	int LowestNode() const;
	/**  Returns the highest numbered node id.
	  */
	int HighestNode() const;
	/** Create a compressed graph.
	  */
	void CompressGraph();
	/** Is cid a node in the compressed graph?
	  */
	bool IsCompressedNode(int cnid) const;
	/** Number of compressed graph edges for node cnid.
	  */
	int CompressedEdgeCount (int cnid) const;
	/** Length of a compressed graph edge.
	  */
	float CompressedEdgeLength (int cnid, int edgenum) const;
	/** Next Edge node.
	  */
	int CompressedEdgeNode (int cnid, int edgenum) const;
	/** Raw nodes in a compressed graph node.
	  */
	IntegerList *CompressedNodeSegments (int cnid) const;
	/** X Coordinate of a Compressed Node position.
	  */
	double CompressedNodePositionX (int cnid) const;
	/** X Coordinate of a Compressed Node position.
	  */
	double CompressedNodePositionY (int cnid) const;
	/** Uncompressed graph heads.
	  */
	const IntegerList *Heads()
	{
		if (!valid_heads) computeHeads();
		return heads;
	}
	/** Compressed graph roots.
	  */
	const IntegerList *Roots()
	{
		if (!compressedP) CompressGraph();
		return c_roots;
	}
	/** Run the BGL circle_graph_layout for a given radius.
	  */
	void CompressedGraphCircleLayout(double radius);
	/** Run the BGL kamada_kawai_spring_layout for a given side length.
	  */
	bool CompressedGraphKamadaKawaiSpring(double sidelength);
	/** Run the kruskal_minimum_spanning_tree algorithm and return a vector of edge pairs.
	  */
	CompressedEdgePairVector CompressedGraphKruskalMinimumSpanningTree();// const;
	/** Run the prim_minimum_spanning_tree algorithm and return a Parent Vector.
	  */
	CompressedEdgePairVector CompressedGraphPrimMinimumSpanningTree();
};

#endif

};

/** @} */

#endif // _TRACKGRAPH_H_

