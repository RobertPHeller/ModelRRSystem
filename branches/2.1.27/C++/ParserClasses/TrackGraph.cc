/* 
 * ------------------------------------------------------------------
 * TrackGraph.cc - Track Graph
 * Created by Robert Heller on Mon Sep 23 21:39:17 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
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

static char rcsid[] = "$Id: TrackGraph.cc 624 2008-04-21 23:36:58Z heller $";

#include <math.h>
#include <limits.h>
#include <TrackGraph.h>
#include <vector>
#include <boost/graph/strong_components.hpp>
#include <boost/graph/circle_layout.hpp>
#include <boost/graph/kamada_kawai_spring_layout.hpp>
#include <boost/graph/kruskal_min_spanning_tree.hpp>
#include <boost/graph/prim_minimum_spanning_tree.hpp>

using namespace Parsers;

//const int TrackGraph::ElementCount = 512;

int TurnoutBodyElt::segCount = 0;

TrackGraph::TrackGraph()
{
	none = add_vertex(nodes);
	nodes[none].id = -1;
	nodes[none].type = Undefined;
	heads = NULL;
	valid_heads = false;
	c_roots = NULL;
	compressedP = false;
	circleLayoutP = false;
	KamadaKawaiSpringLayoutP = false;
}

TrackGraph::~TrackGraph()
{
	graph_traits<Graph>::vertex_iterator vi, vi_end;
	for (tie(vi, vi_end) = vertices(nodes); vi != vi_end; vi++) {
		Node n = *vi;
		nodes[n].Cleanup();
	}
	nodes.clear();
	IntegerList::CleanUpIntegerList(heads);
	IntegerList::CleanUpIntegerList(c_roots);
}

TrackGraph::Node TrackGraph::AddNewNode(int id, TrackGraph::NodeType type,
			    TurnoutGraphic *tgr, TurnoutRoutelist *tpo, 
			    float length)
{
	Node newNode;
#ifdef DEBUG
	cerr << "*** TrackGraph::AddNewNode(" << id << "," << type << "," << tgr << "," << tpo << "," << length << ")" << endl;
#endif
	// Unconnected trackage
	if (id < 0 && type == Undefined) return none; 
	// Error checking
	if (id < 0 && type != Undefined) {
		 cerr << "Illegal track index: " << id << "!" << endl;
		 return none;
	}
	if ((newNode = FindNode(id)) != none) {
		if (type != Undefined) {
			// Error checking
			if (nodes[newNode].type != Undefined) {
				cerr << "Duplicate track index: " << id
				     << ", " << newNode << "!" << endl;
				return none;
			}
			// Forward reference
			nodes[newNode].type   = type;
			nodes[newNode].tgr    = tgr;
			nodes[newNode].tpo    = tpo;
			nodes[newNode].length = length;
		}
#ifdef DEBUG
		cerr << "*** TrackGraph::AddNewNode(): old node: " << id << " at " << newNode << endl;
		cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].id = " << nodes[newNode].id << endl;
		cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].type = " << nodes[newNode].type << endl;
		cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].tgr = " << nodes[newNode].tgr << endl;
		cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].tpo = " << nodes[newNode].tpo << endl;
		cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].length = " << nodes[newNode].length << endl;
#endif
		return newNode;
	}
	newNode = add_vertex(NodeValues(id,type,tgr,tpo,length),nodes);
	idMap.insert(std::make_pair(id, newNode));
#ifdef DEBUG
	cerr << "*** TrackGraph::AddNewNode(): new node: " << id << " at " << newNode << endl;
	cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].id = " << nodes[newNode].id << endl;
	cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].type = " << nodes[newNode].type << endl;
	cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].tgr = " << nodes[newNode].tgr << endl;
	cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].tpo = " << nodes[newNode].tpo << endl;
	cerr << "*** TrackGraph::AddNewNode(): - nodes[" << newNode << "].length = " << nodes[newNode].length << endl;
#endif
	return newNode;	
}

void TrackGraph::InsertStraightTrack(int number,TrackBody *tb)
{
	IdNodeMap::iterator pos;
	bool inserted;
	Node newNode, connection;
	graph_traits < Graph >::edge_descriptor e;
	
	int i;

	newNode = AddNewNode(number,Track);
	
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		if (tb->element->index > 0)
			connection = AddNewNode(tb->element->index);
		else	connection = none;
		tie(e, inserted) = add_edge(newNode,connection,
					    EdgeValues(tb->element->index,
						       tb->element->x,
						       tb->element->y,
						       tb->element->a),nodes);
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	nodes[newNode].length = LengthOfStraight(EdgeX(number,0),
						 EdgeY(number,0),
						 EdgeX(number,1),
						 EdgeY(number,1));
	graph_traits<Graph>::out_edge_iterator ie, last;
	for (tie(ie,last) = out_edges(newNode,nodes); ie != last; ++ie) {
		nodes[*ie].length = nodes[newNode].length;
	}
}

static inline float square(float x) {return x*x;}

float TrackGraph::LengthOfStraight(float x1, float y1, float x2, float y2)
{
	float dx = x1 - x2,
	      dy = y1 - y2;
	return sqrt(square(dx)+square(dy));
}

void TrackGraph::InsertCurveTrack(int number,TrackBody *tb,float orgX,float orgY,float radius)
{
	float a1, a2;
	IdNodeMap::iterator pos;
	bool inserted;
	Node newNode, connection;
	graph_traits < Graph >::edge_descriptor e;
	
	int i;
	
	newNode = AddNewNode(number,Track);
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		if (tb->element->index > 0)
			connection = AddNewNode(tb->element->index);
		else	connection = none;
		tie(e, inserted) = add_edge(newNode,connection,
					    EdgeValues(tb->element->index,
						       tb->element->x,
						       tb->element->y,
						       tb->element->a),nodes);
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	a1 = atan2(EdgeY(number,0) - orgY,EdgeX(number,0) - orgX);
	a2 = atan2(EdgeY(number,1) - orgY,EdgeX(number,1) - orgX);
	nodes[newNode].length = LengthOfCurve(radius,a1,a2);
	graph_traits<Graph>::out_edge_iterator ie, last;
	for (tie(ie,last) = out_edges(newNode,nodes); ie != last; ++ie) {
		nodes[*ie].length = nodes[newNode].length;
	}
}

float TrackGraph::LengthOfCurve(float radius, float a1, float a2)
{
	float theta = fabs(a2 - a1),
	      result = theta  * fabs(radius);

	return result;
}

void TrackGraph::InsertJointTrack(int number,TrackBody *tb,float l0, float l1, float angle, float R, float L)
{
	IdNodeMap::iterator pos;
	bool inserted;
	Node newNode, connection;
	graph_traits < Graph >::edge_descriptor e;
	
	int i;
	
	newNode = AddNewNode(number,Track);
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		if (tb->element->index > 0)
			connection = AddNewNode(tb->element->index);
		else	connection = none;
		tie(e, inserted) = add_edge(newNode,connection,
					    EdgeValues(tb->element->index,
						       tb->element->x,
						       tb->element->y,
						       tb->element->a),nodes);
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	nodes[newNode].length = LengthOfJoint(l0,l1,angle,R,L);
	graph_traits<Graph>::out_edge_iterator ie, last;
	for (tie(ie,last) = out_edges(newNode,nodes); ie != last; ++ie) {
		nodes[*ie].length = nodes[newNode].length;
	}
}

float TrackGraph::LengthOfJoint(float l0, float l1, float angle, float R, float L)
{
	return l0+l1; // approximation...
}
void TrackGraph::InsertTurnOut(int number, float orgX, float orgY, float orient,
			   const char *name,TurnoutBody *trb)
{
	IdNodeMap::iterator pos;
	bool inserted;
	Node newNode, connection;
	graph_traits < Graph >::edge_descriptor e;
	
	int i;
	
	newNode = AddNewNode(number,Turnout);
	TrackBody *tb = trb->TurnoutEnds();
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		if (tb->element->index > 0)
			connection = AddNewNode(tb->element->index);
		else	connection = none;
		tie(e, inserted) = add_edge(newNode,connection,
					    EdgeValues(tb->element->index,
						       tb->element->x,
						       tb->element->y,
						       tb->element->a),nodes);
		//delete tb->element; (Memory freed elsewhere)
		ne = tb->next;
		delete tb;
	}
	nodes[newNode].tgr = MakeTurnoutGraphic(orgX,orgY,orient,trb);
	nodes[newNode].tpo = MakeTurnoutRouteList(trb,nodes[newNode].tgr,nodes[newNode].length);
	graph_traits<Graph>::out_edge_iterator ie, last;
	for (tie(ie,last) = out_edges(newNode,nodes); ie != last; ++ie) {
		nodes[*ie].length = nodes[newNode].length;
	}
	TurnoutBody::CleanUpTurnoutBody(trb);		
}

void TrackGraph::InsertTurnTable(int number, float orgX, float orgY, float radius,
			   TrackBody *tb)
{
	IdNodeMap::iterator pos;
	bool inserted;
	Node newNode, connection;
	graph_traits < Graph >::edge_descriptor e;
	
	int i;
	
	newNode = AddNewNode(number,Turntable);
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		if (tb->element->index > 0)
			connection = AddNewNode(tb->element->index);
		else	connection = none;
		tie(e, inserted) = add_edge(newNode,connection,
					    EdgeValues(tb->element->index,
						       tb->element->x,
						       tb->element->y,
						       tb->element->a),nodes);
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	nodes[newNode].length = radius * 2.0;
	graph_traits<Graph>::out_edge_iterator ie, last;
	for (tie(ie,last) = out_edges(newNode,nodes); ie != last; ++ie) {
		nodes[*ie].length = nodes[newNode].length;
	}
}

void TrackGraph::InsertBlock(int number, char * _name, char * _script, IntegerList *_tracklist)
{
	Node newNode;
	
	newNode = AddNewNode(number,Block);
	nodes[newNode].length = -1.0;
	nodes[newNode].name = _name;
	nodes[newNode].sensescript = _script;
	nodes[newNode].tracklist = _tracklist;

}

void TrackGraph::InsertSwitchMotor(int number, int turnout, char * _name, char * _normal, char * _reverse, char * _pointsense)
{
	Node newNode;
	
	newNode = AddNewNode(number,SwitchMotor);
	nodes[newNode].name = _name;
	nodes[newNode].turnoutnumber = turnout;
	nodes[newNode].sensescript = _pointsense;
	nodes[newNode].normalactionscript = _normal;
	nodes[newNode].reverseactionscript = _reverse;
	nodes[newNode].length = -1.0;
}

std::ostream& Parsers::operator << (ostream& stream,TrackGraph& graph)
{
	int jj;
	int nid,nedges,iedge;
	for (nid = graph.LowestNode(); nid < graph.HighestNode(); nid++) {
		if (graph.IsNone(graph.FindNode(nid))) continue;
		stream << "Node: " << nid << "[" << graph.TypeOfNode(nid) << "], " << (nedges = graph.NumEdges(nid)) << " edges:";
		for (iedge = 0; iedge < nedges; iedge++) {
			stream << " " << graph.EdgeIndex(nid,iedge) << ", (";
			stream << graph.EdgeX(nid,iedge) << ",";
			stream << graph.EdgeY(nid,iedge) << "), ";
			stream << graph.EdgeA(nid,iedge) << " degrees " ;
			stream << graph.EdgeLength(nid,iedge) << " long";
			if ((iedge+1) < nedges) stream << "; ";
			else			stream << ". ";
		}
		const TurnoutGraphic *tgr = graph.NodeTurnoutGraphic(nid);
		if (tgr != NULL) {
			for (jj = 0;jj < tgr->numSegments; jj++)
			{
				stream << jj+1 << ": ";
				switch (tgr->segments[jj].tgType) {
					case SegVector::S: stream << "S ";
						stream << "(" << tgr->segments[jj].gPos1.x << "," <<  tgr->segments[jj].gPos1.y << "), ";
						stream << "(" << tgr->segments[jj].gPos2.x << "," <<  tgr->segments[jj].gPos2.y << ")" << endl;
						break;
					case SegVector::C: stream << "C ";
						stream << tgr->segments[jj].radius;
						stream << " (" << tgr->segments[jj].gPos1.x << "," <<  tgr->segments[jj].gPos1.y << ") ";
						stream << tgr->segments[jj].ang0 << " " << tgr->segments[jj].ang1 << endl;
						break;
					case SegVector::J: stream << "J ";
						stream << " (" << tgr->segments[jj].gPos1.x << "," <<  tgr->segments[jj].gPos1.y << ") ";
						stream << tgr->segments[jj].angle << " " << tgr->segments[jj].len0 << " " << tgr->segments[jj].len1 << " " << tgr->segments[jj].R << " " << tgr->segments[jj].L << endl;
						break;
				}
				
			}
		}
		const TurnoutRoutelist *tpo = graph.NodeTurnoutRoutelist(nid);
		if (tpo != NULL) {
			for (jj = 0;jj < tpo->numRoutelists; jj++) {
				stream << "P \"" << tpo->routes[jj].positionName << "\" "<< tpo->routes[jj].posList << endl;
			}
		}
		stream << graph.LengthOfNode(nid) << " long." << endl;
		stream << endl;
	}
	return stream;
}

TrackGraph::Node TrackGraph::FindNode(int number) const
{
	IdNodeMap::const_iterator pos = idMap.find(number);
	if (pos == idMap.end()) return none;
	else return pos->second;
}

bool TrackGraph::IsNodeP(int nid) const
{
	if (FindNode(nid) == none) return false;
	else return true;
}

int TrackGraph::NumEdges(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return -1;
	else {
		graph_traits<Graph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,nodes); i != last; ++i) count++;
		return count;
	}
}

int TrackGraph::EdgeIndex(int nid, int edgenum) const
{
	Node n = FindNode(nid);
	if (n == none) return -2;
	else {
		graph_traits<Graph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,nodes); i != last; ++i) {
			if (count++ == edgenum) break;
		}
		if (i != last) return nodes[*i].index;
		else return -2;
	}
}
	
float TrackGraph::EdgeX(int nid, int edgenum) const
{
	Node n = FindNode(nid);
	if (n == none) return -2.0;
	else {
		graph_traits<Graph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,nodes); i != last; ++i) {
			if (count++ == edgenum) break;
		}
		if (i != last) return nodes[*i].x;
		else return -2.0;
	}
}

float TrackGraph::EdgeY(int nid, int edgenum) const
{
	Node n = FindNode(nid);
	if (n == none) return -2.0;
	else {
		graph_traits<Graph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,nodes); i != last; ++i) {
			if (count++ == edgenum) break;
		}
		if (i != last) return nodes[*i].y;
		else return -2.0;
	}
}

float TrackGraph::EdgeA(int nid, int edgenum) const
{
	Node n = FindNode(nid);
	if (n == none) return -2.0;
	else {
		graph_traits<Graph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,nodes); i != last; ++i) {
			if (count++ == edgenum) break;
		}
		if (i != last) return nodes[*i].a;
		else return -2.0;
	}
}

float TrackGraph::EdgeLength(int nid, int edgenum) const
{
	Node n = FindNode(nid);
	if (n == none) return -2.0;
	else {
		graph_traits<Graph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,nodes); i != last; ++i) {
			if (count++ == edgenum) break;
		}
		if (i != last) return nodes[*i].length;
		else return -2.0;
	}
}

TrackGraph::NodeType TrackGraph::TypeOfNode(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return Track;
	else return nodes[n].type;
}

const TurnoutGraphic *TrackGraph::NodeTurnoutGraphic(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return NULL;
	else return nodes[n].tgr;
}

const TurnoutRoutelist *TrackGraph::NodeTurnoutRoutelist(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return NULL;
	else return nodes[n].tpo;
}

float TrackGraph::LengthOfNode(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return 0.0;
	else return nodes[n].length;
}

const IntegerList *TrackGraph::TrackList(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return NULL;
	else return nodes[n].tracklist;
}

int TrackGraph::TurnoutNumber(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return 0;
	else return nodes[n].turnoutnumber;
}

const char * TrackGraph::NameOfNode(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return NULL;
	else return nodes[n].name;
}

const char * TrackGraph::SenseScript(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return NULL;
	else return nodes[n].sensescript;
}

const char * TrackGraph::NormalActionScript(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return NULL;
	else return nodes[n].normalactionscript;
}

const char * TrackGraph::ReverseActionScript(int nid) const
{
	Node n = FindNode(nid);
	if (n == none) return NULL;
	else return nodes[n].reverseactionscript;
}


int TrackGraph::LowestNode() const
{
	int ln;
	Node n;

	ln = INT_MAX;

	graph_traits < Graph >::vertex_iterator ii, end;
	for (tie(ii, end) = vertices(nodes);ii != end; ++ii) {
		n = *ii;
#ifdef DEBUG
		cerr << "*** TrackGraph::LowestNode(): n = " << n << endl;
#endif
		if (n == none) continue;
		if (nodes[n].id < ln) ln = nodes[n].id;
#ifdef DEBUG
		cerr << "*** TrackGraph::LowestNode(): nodes[" << n << "].id = " << nodes[n].id << endl;
#endif
	}
	if (ln == INT_MAX) return -1;
	else return ln;
}

int TrackGraph::HighestNode() const
{
	int ln;
	Node n;

	ln = -1;

	graph_traits < Graph >::vertex_iterator ii, end;
	for (tie(ii, end) = vertices(nodes);ii != end; ++ii) {
		n = *ii;
#ifdef DEBUG
		cerr << "*** TrackGraph::HighestNode(): n = " << n << endl;
#endif
		if (nodes[n].id > ln) ln = nodes[n].id;
#ifdef DEBUG
		cerr << "*** TrackGraph::HighestNode(): nodes[" << n << "].id = " << nodes[n].id << endl;
#endif
	}
	return ln;
}

TrackGraph::Transform2D::Transform2D()
{
  matrix[0][0] = 1.0;
  matrix[0][1] = 0.0;
  matrix[0][2] = 0.0;
  matrix[1][0] = 0.0;
  matrix[1][1] = 1.0;
  matrix[1][2] = 0.0;
  matrix[2][0] = 0.0;
  matrix[2][1] = 0.0;
  matrix[2][2] = 1.0;
}

TrackGraph::Transform2D::Transform2D(const TrackGraph::Transform2D* ts)
{
  for (int i=0;i < 3;i++) {
    for (int j=0;j < 3;j++) {
      matrix[i][j] = ts->matrix[i][j];
    }
  }
}

TrackGraph::Transform2D::Transform2D(float r11, float r12, float tx,
			 float r21, float r22, float ty,
			 float a0,  float a1,  float s)
{
  matrix[0][0] = r11;
  matrix[0][1] = r12;
  matrix[0][2] = tx;
  matrix[1][0] = r21;
  matrix[1][1] = r22;
  matrix[1][2] = ty;
  matrix[2][0] = a0;
  matrix[2][1] = a1;
  matrix[2][2] = s;
}

TrackGraph::Transform2D* Parsers::operator * (const TrackGraph::Transform2D& t1, const TrackGraph::Transform2D& t2)
{
  TrackGraph::Transform2D *new_t = new TrackGraph::Transform2D;

  for(int i=0; i < 3; i++)
    for(int j=0; j < 3; j++) {
      float sum = 0.0;
      for(int k=0; k < 3; k++) 
	sum += t1.matrix[j][k] * t2.matrix[k][i];
      new_t->matrix[j][i] = sum;
    }

  return new_t;
}

void TrackGraph::Transform2D::Apply(float x, float y, float s, float &tx, float &ty, float &ts) const
{
  tx = (matrix[0][0] * x) + (matrix[0][1] * y) + (matrix[0][2] * s);
  ty = (matrix[1][0] * x) + (matrix[1][1] * y) + (matrix[1][2] * s);
  ts = (matrix[2][0] * x) + (matrix[2][1] * y) + (matrix[2][2] * s);

  if (ts != 0.0) {
    tx /= ts;
    ty /= ts;
    ts = 1.0;
  }
}
      
int TrackGraph::Transform2D::Apply(float x, float y, float& tx, float &ty) const
{
  float s = 1.0;
  float ts;

  Apply(x, y, s, tx, ty, ts);
  if (ts == 0.0) return 0;
  else return 1;
}

float TrackGraph::Transform2D::Determinant() const
{
  return ((matrix[0][0] * matrix[1][1] * matrix[2][2]) +
	  (matrix[0][1] * matrix[1][2] * matrix[2][0]) +
	  (matrix[0][2] * matrix[1][0] * matrix[2][1]) -
	  (matrix[0][2] * matrix[1][1] * matrix[2][0]) -
	  (matrix[0][1] * matrix[1][0] * matrix[2][2]) -
	  (matrix[0][0] * matrix[1][2] * matrix[2][1]));
}

float TrackGraph::Transform2D::Minor(int row, int col) const
{
  float TwoByTwo[4];
  int ctr = 0, r, c;

  for (r=0; r < 3; r++) {
    if (r != row) {
      for (c=0; c < 3; c++) {
	if (c != col) 
	  TwoByTwo[ctr++] = matrix[r][c];
      }
    }
  }
  
  return ((TwoByTwo[0] * TwoByTwo[3]) - (TwoByTwo[1] * TwoByTwo[2]));
}

/* The method of matrix inversion used here is that the inverse of a matrix A
 * is 1/det(a) * adjunct(A).  Tha adjunct(a) is the transpose of the matrix of
 * cofactors of A; the matrix of cofactors is (-1)^(i+j) Mij, where Mij is the
 * Minor of A at ij (i.e. the determinant of the submatrix of A after row i and
 * col j are deleted). This is actually an efficient way to invert 3x3 matrices.
 */

TrackGraph::Transform2D *TrackGraph::Transform2D::Inverse() const
{
  TrackGraph::Transform2D *new_trans = new TrackGraph::Transform2D;
  int i, j;
  bool evenp = true;
  float det = Determinant();

  if (det == 0.0) return NULL;

  for (i=0; i < 3; i++) {
    for (j=0; j < 3; j++) {
      /* reversing the coordinates to the call to minor effectively
       * transposes the resulting matrix 
       */
      new_trans->matrix[i][j] = (Minor(j, i) / det);
      if (evenp == false) {
	new_trans->matrix[i][j] = -new_trans->matrix[i][j];
	evenp = true;
      }
      else evenp = false;
    }
  }

  return new_trans; } 

int TrackGraph::Transform2D::operator== (const TrackGraph::Transform2D& other) const
{
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			if (fabs(matrix[i][j] - other.matrix[i][j]) > FUZZ)
				return 0;
		}
	}
	return 1;
}

TrackGraph::Transform2D *TrackGraph::tr_translate(float x, float y)
{
  return new TrackGraph::Transform2D(1.0, 0.0, x, 0.0, 1.0, y);
}

TrackGraph::Transform2D *TrackGraph::tr_scale(float mag_factor)
{
  return new TrackGraph::Transform2D(mag_factor, 0.0, 0.0, 0.0, mag_factor, 0.0);
}

TrackGraph::Transform2D *TrackGraph::tr_scale(float xscale, float yscale)
{
  return new TrackGraph::Transform2D(xscale, 0.0, 0.0, 0.0, yscale, 0.0);
}

TrackGraph::Transform2D *TrackGraph::tr_rotate(float amount, RotationUnit measure)
{
  if (measure == Degrees) amount *= (M_PI/180.0);
  float c = cos(amount);
  float s = sin(amount);

  return new TrackGraph::Transform2D(c, -s, 0.0, s, c, 0.0);
}

static int QuandantOfA(float a)
{
	if (a >= 0 && a < M_PI_2) return 1;
	else if (a >= M_PI_2 && a < M_PI) return 2;
	else if (a >= M_PI && a < (M_PI + M_PI_2)) return 3;
	else return 4;
}

static void GetArcBBox(float x1,float y1,float x2,float y2,float a0,float a1,
		       float xc,float yc,float radius,
		       float &sMinX,float &sMinY,float &sMaxX,float &sMaxY)
{
	int Qa0 = QuandantOfA(a0),
	    Qa1 = QuandantOfA(a1),
	    Qn;
	float xx1, yy1, xx2, yy2;

	if (Qa0 == Qa1) {
		if (x1 < x2) {sMinX = x1; sMaxX = x2;}
		else {sMinX = x2; sMaxX = x2;}
		if (y1 < y2) {sMinY = y1; sMaxY = y2;}
		else {sMinY = y2; sMaxY = y2;}
		return;
	}
	xx2 = sMinX = sMaxX = xx1 = x1; yy2 = sMinY = sMaxY = yy1 = y1;
	Qn = Qa0+1;
	if (Qn > 4) Qn = 1;
	while (Qn < Qa1) {
		switch (Qn) {
			case 1: xx2 = xc + radius; yy2 = yc; Qn = 2; break;
			case 2: xx2 = xc; yy2 = yc + radius; Qn = 3; break;
			case 3: xx2 = xc - radius; yy2 = yc; Qn = 4; break;
			case 4: xx2 = xc; yy2 = yc - radius; Qn = 1; break;
		}
		if (xx2 < sMinX) sMinX = xx2;
		if (yy2 < sMinY) sMinY = yy2;
		xx1 = xx2;
		yy1 = yy2;
	}
	xx2 = x2; yy2 = y2;
	if (xx2 < sMinX) sMinX = xx2;
	if (yy2 < sMinY) sMinY = yy2;
}

TurnoutGraphic *TrackGraph::MakeTurnoutGraphic(float orgX, float orgY, float orient, TurnoutBody *trb)
{
	int iseg,segcount;
	float xc, yc, x1, y1, x2, y2, radius, a0, a1, l0, l1, L, R;
	float sMinX, sMaxX, sMinY, sMaxY;
	Transform2D *trans = tr_translate(orgX,orgY),
		    *rot   = tr_rotate(-orient,Degrees),
		    *transform = *trans *  *rot;
	TurnoutGraphic *newGr = new TurnoutGraphic();
	segcount = newGr->numSegments = trb->TurnoutSegmentCount();
	newGr->segments = new SegVector[segcount];
	TurnoutBody *p;
	for (p = trb; p != NULL; p = p->next) {
		const TurnoutBodyElt *e = p->Element();
		switch (e->TheType()) {
			case TurnoutBodyElt::TurnoutStraightSegment:
				iseg = e->GetTurnoutStraightSegment(x1,y1,x2,y2);
				if (iseg <= segcount) {
					newGr->segments[iseg-1].tgType = SegVector::S;
					newGr->segments[iseg-1].gPos1.x = x1;
					newGr->segments[iseg-1].gPos1.y = y1;
					newGr->segments[iseg-1].gPos2.x = x2;
					newGr->segments[iseg-1].gPos2.y = y2;
					transform->Apply(x1,y1,
					      newGr->segments[iseg-1].ePos1.x,
					      newGr->segments[iseg-1].ePos1.y);
					transform->Apply(x2,y2,
					      newGr->segments[iseg-1].ePos2.x,
					      newGr->segments[iseg-1].ePos2.y);
					newGr->segments[iseg-1].length =
						LengthOfStraight(x1,y1,x2,y2);
					if (x1 < x2) {sMinX = x1; sMaxX = x2;}
					else {sMinX = x2; sMaxX = x2;}
					if (y1 < y2) {sMinY = y1; sMaxY = y2;}
					else {sMinY = y2; sMaxY = y2;}
					if (p == trb) {
						newGr->minX = sMinX;
						newGr->minY = sMinY;
						newGr->maxX = sMaxX;
						newGr->maxY = sMaxY;
					} else {
						if (sMinX < newGr->minX) newGr->minX = sMinX;
						if (sMinY < newGr->minY) newGr->minY = sMinY;
						if (sMaxX > newGr->maxX) newGr->maxX = sMaxX;
						if (sMaxY > newGr->maxY) newGr->maxY = sMaxY;
					}
				}
				break;
			case TurnoutBodyElt::TurnoutCurveSegment:
				iseg = e->GetTurnoutCurveSegment(radius, xc, yc, a0, a1);
				if (iseg <= segcount) {
					newGr->segments[iseg-1].tgType = SegVector::C;
					newGr->segments[iseg-1].gPos1.x = xc;
					newGr->segments[iseg-1].gPos1.y = yc;
					newGr->segments[iseg-1].radius = radius;
					newGr->segments[iseg-1].ang0 = (a0-90) * (M_PI/180.0);
					newGr->segments[iseg-1].ang1 = (a1)    * (M_PI/180.0);
					//cerr << "*** MakeTGR: xc = " << xc << ", yc = " << yc << ", radius = " << radius << endl;
					//cerr << "*** -: a0 = " << a0 << ", newGr->segments[iseg-1].ang0 = " << newGr->segments[iseg-1].ang0 << endl;
					if (radius < 0) {
						x2 = xc - (radius * cos(newGr->segments[iseg-1].ang0));
						y2 = yc + (radius * sin(newGr->segments[iseg-1].ang0));
						x1 = xc - (radius * cos(newGr->segments[iseg-1].ang1+newGr->segments[iseg-1].ang0));
						y1 = yc + (radius * sin(newGr->segments[iseg-1].ang1+newGr->segments[iseg-1].ang0));
					} else {
						x1 = xc + (radius * cos(newGr->segments[iseg-1].ang0));
						y1 = yc - (radius * sin(newGr->segments[iseg-1].ang0));
						x2 = xc + (radius * cos(newGr->segments[iseg-1].ang1+newGr->segments[iseg-1].ang0));
						y2 = yc - (radius * sin(newGr->segments[iseg-1].ang1+newGr->segments[iseg-1].ang0));
					}
					//cerr << "*** -: x1 = " << x1 << ", y1 = " << y1 << endl;
					transform->Apply(x1, y1, 
						newGr->segments[iseg-1].ePos1.x,
						newGr->segments[iseg-1].ePos1.y);
					//cerr << "*** -: x2 = " << x2 << ", y2 = " << y2 << endl;
					transform->Apply(x2,y2,
						newGr->segments[iseg-1].ePos2.x,
						newGr->segments[iseg-1].ePos2.y);
					newGr->segments[iseg-1].length =
						LengthOfCurve(radius,
							0.0,newGr->segments[iseg-1].ang1);
					GetArcBBox(x1,y1,x2,y2,
						   newGr->segments[iseg-1].ang0,
						   newGr->segments[iseg-1].ang1+newGr->segments[iseg-1].ang0,
						   xc, yc, radius,
						   sMinX,sMinY,sMaxX,sMaxY);
					if (p == trb) {
						newGr->minX = sMinX;
						newGr->minY = sMinY;
						newGr->maxX = sMaxX;
						newGr->maxY = sMaxY;
					} else {
						if (sMinX < newGr->minX) newGr->minX = sMinX;
						if (sMinY < newGr->minY) newGr->minY = sMinY;
						if (sMaxX > newGr->maxX) newGr->maxX = sMaxX;
						if (sMaxY > newGr->maxY) newGr->maxY = sMaxY;
					}
				}
				break;
			case TurnoutBodyElt::TurnoutJointSegment:
				iseg = e->GetTurnoutJointSegment(x1,y1,a0,l0,l1,R,L);
				if (iseg <= segcount) {
					newGr->segments[iseg-1].tgType = SegVector::J;
					newGr->segments[iseg-1].gPos1.x = x1;
					newGr->segments[iseg-1].gPos1.y = y1;
					newGr->segments[iseg-1].length = LengthOfJoint(l0,l1,a0,R,L);
					newGr->segments[iseg-1].angle = (a0) * (M_PI/180.0);
					newGr->segments[iseg-1].len0 = l0;
					newGr->segments[iseg-1].len1 = l1;
					newGr->segments[iseg-1].R = R;
					newGr->segments[iseg-1].L = L;
					newGr->segments[iseg-1].length =
						LengthOfJoint(l0,l1,a0,R,L);
					transform->Apply(x1,y1,
					      newGr->segments[iseg-1].ePos1.x,
					      newGr->segments[iseg-1].ePos1.y);
					x2 = x1 + (newGr->segments[iseg-1].length * cos(newGr->segments[iseg-1].angle));
					y2 = y1 + (newGr->segments[iseg-1].length * sin(newGr->segments[iseg-1].angle));
					transform->Apply(x2,y2,
						newGr->segments[iseg-1].ePos2.x,
						newGr->segments[iseg-1].ePos2.y);
					if (x1 < x2) {sMinX = x1; sMaxX = x2;}
					else {sMinX = x2; sMaxX = x2;}
					if (y1 < y2) {sMinY = y1; sMaxY = y2;}
					else {sMinY = y2; sMaxY = y2;}
					if (p == trb) {
						newGr->minX = sMinX;
						newGr->minY = sMinY;
						newGr->maxX = sMaxX;
						newGr->maxY = sMaxY;
					} else {
						if (sMinX < newGr->minX) newGr->minX = sMinX;
						if (sMinY < newGr->minY) newGr->minY = sMinY;
						if (sMaxX > newGr->maxX) newGr->maxX = sMaxX;
						if (sMaxY > newGr->maxY) newGr->maxY = sMaxY;
					}
				}
				break;
			default: break;
		}
	}
	delete trans;
	delete rot;
	delete transform;	
	return newGr;
}

TurnoutRoutelist *TrackGraph::MakeTurnoutRouteList(TurnoutBody *trb,const TurnoutGraphic *tgr,float &length)
{
	int nRoutes, iroute;
	TurnoutRoutelist *newRouteList = new TurnoutRoutelist();
	nRoutes = newRouteList->numRoutelists = trb->TurnoutRouteCount();
	newRouteList->routes = new RouteVec[nRoutes];
	length = 0.0; iroute = 0;
	for (TurnoutBody *p = trb; p != NULL; p = p->next) {
		const TurnoutBodyElt *e = p->Element();
		if (e->TheType() != TurnoutBodyElt::TurnoutRoute) continue;
		if (iroute >= nRoutes) continue;
		e->GetTurnoutRoute(newRouteList->routes[iroute].positionName,
				   newRouteList->routes[iroute].posList);
		newRouteList->routes[iroute].routeLength =
			ComputeRouteLength(tgr,newRouteList->routes[iroute].posList);
		if (newRouteList->routes[iroute].routeLength > length)
			length = newRouteList->routes[iroute].routeLength;
		iroute++;
	}
	return newRouteList;
}

float TrackGraph::ComputeRouteLength(const TurnoutGraphic *tgr, const IntegerList *il)
{
	float savedLength = 0.0, currentLength = 0.0;
	const IntegerList *ip;
	for (ip = il; ip != NULL; ip = ip->Next()) {
		int segNum = ip->Element();
		if (segNum == 0) {
			if (currentLength > savedLength) savedLength = currentLength;
			currentLength = 0.0;
		} else if (segNum > 0  && segNum  <= tgr->numSegments) {
			currentLength += tgr->segments[segNum-1].length;
		}
	}
	if (currentLength > savedLength) savedLength = currentLength;
	return savedLength;
}

void TrackGraph::DeleteTurnoutGraphic(TurnoutGraphic *tgr)
{
	if (tgr != NULL) {
		if (tgr->segments != NULL) delete tgr->segments;
		delete tgr;
	}
}

void TrackGraph::DeleteTurnoutRouteList(TurnoutRoutelist *tpo)
{
	if (tpo != NULL) {
		if (tpo->routes != NULL) delete tpo->routes;
		delete tpo;
	}
}


void TrackGraph::CompressGraph()
{
	const IntegerList *h;
	if (!valid_heads) computeHeads();
	for (h = heads; h != NULL; h = h->Next())
	{
		Node head = FindNode(h->Element());
		if (backpointers.find(head) == backpointers.end())
		{
			CompressedNode newroot = insertCompressedNode(head);
			c_roots = IntegerList::IntAppend(c_roots,c_nodes[newroot].id);
		}
	}
	compressedP = true;
}

TrackGraph::CompressedNode TrackGraph::insertCompressedNode (Node rawnode)
{
#ifdef DEBUG
	cerr << "*** TrackGraph::insertCompressedNode (" << rawnode << " [" << nodes[rawnode].id << "])" << endl;
#endif
	if (backpointers.find(rawnode) != backpointers.end())
	{
		// error("Node already in graph: $rawnode")
		cerr << "*** TrackGraph::insertCompressedNode -- Node already in graph: " << rawnode << " [" << nodes[rawnode].id << "]" << endl;
	}
	int nodeId = nodes[rawnode].id;	
	CompressedNode newnode = add_vertex(CompressedNodeValues(nodeId),c_nodes);
	c_nodes[newnode].segments.push_back(nodeId);
	c_idMap.insert(std::make_pair(nodeId,newnode));
	backpointers.insert(std::make_pair(rawnode,newnode));
	int nEdges = NumEdges(nodeId);
#ifdef DEBUG
	cerr << "*** TrackGraph::insertCompressedNode(): nEdges = " << nEdges << endl;
#endif
	if (nEdges == 2)
	{
		/*float edgelength = 0;*/
		int rn0 = EdgeIndex(nodeId,0);
		int rn1 = EdgeIndex(nodeId,1);
#ifdef DEBUG
		cerr << "*** TrackGraph::insertCompressedNode(): rn0 = " << rn0 << endl;
		cerr << "*** TrackGraph::insertCompressedNode(): rn1 = " << rn1 << endl;
#endif
		while (rn0 >= 0 &&
			c_nodes[newnode].FindSegmentIndex(rn0) == (std::list<int>::size_type)-1 &&
			NumEdges(rn0) == 2)
		{
#ifdef DEBUG
			cerr << "*** TrackGraph::insertCompressedNode(): adding segment " << rn0 << endl;
#endif
			c_nodes[newnode].segments.push_front(rn0);
			backpointers.insert(std::make_pair(FindNode(rn0),newnode));
			if (c_nodes[newnode].FindSegmentIndex(EdgeIndex(rn0,0)) == 1)
			{
				rn0 = EdgeIndex(rn0,1);
			} else
			{
				rn0 = EdgeIndex(rn0,0);
			}
#ifdef DEBUG
			cerr << "*** TrackGraph::insertCompressedNode(): new rn0 = " << rn0 << endl;
#endif
		}
#ifdef DEBUG
		cerr << "*** TrackGraph::insertCompressedNode(): final rn0 = " << rn0 << endl;
#endif
		if (rn0 >= 0 && c_nodes[newnode].FindSegmentIndex(rn0) != (std::list<int>::size_type)-1) {rn0 = -1;}
		while (rn1 >= 0 &&
			c_nodes[newnode].FindSegmentIndex(rn1) == (std::list<int>::size_type)-1 &&
			NumEdges(rn1) == 2)
		{
#ifdef DEBUG
			cerr << "*** TrackGraph::insertCompressedNode(): adding segment " << rn1 << endl;
#endif
			c_nodes[newnode].segments.push_back(rn1);
			backpointers.insert(std::make_pair(FindNode(rn1),newnode));
			if (c_nodes[newnode].FindSegmentIndex(EdgeIndex(rn1,1)) ==
			    c_nodes[newnode].segments.size() - 2)
			{
				rn1 = EdgeIndex(rn1,0);
			} else
			{
				rn1 = EdgeIndex(rn1,1);
			}
#ifdef DEBUG
			cerr << "*** TrackGraph::insertCompressedNode(): new rn1 = " << rn1 << endl;
#endif
		}
#ifdef DEBUG
		cerr << "*** TrackGraph::insertCompressedNode(): final rn1 = " << rn1 << endl;
#endif
		if (rn1 >= 0 && c_nodes[newnode].FindSegmentIndex(rn1) != (std::list<int>::size_type)-1) {rn1 = -1;}
		float totalEdgeLength = 0.0;
		std::list<int>::const_iterator pos, last;
		last = c_nodes[newnode].segments.end();
		for (pos = c_nodes[newnode].segments.begin(); pos != last; ++pos)
		{
			totalEdgeLength += LengthOfNode(*pos);
		}
		std::map <Node, CompressedNode>::const_iterator bpos;
		Node edgeNode = FindNode(rn0);
#ifdef DEBUG
		cerr << "*** TrackGraph::insertCompressedNode(): edgeNode (rn0) = " << edgeNode << " [" << nodes[edgeNode].id << "]" << endl;
#endif
		if (edgeNode != none) {
			bpos = backpointers.find(edgeNode);
			if (bpos == backpointers.end())
			{
				add_edge(newnode,insertCompressedNode(edgeNode),CompressedEdgeValues(totalEdgeLength),c_nodes);
			} else
			{
				graph_traits < CompressedGraph >::edge_descriptor e;
				bool inserted;
				tie(e, inserted) = add_edge(newnode,bpos->second,CompressedEdgeValues(totalEdgeLength),c_nodes);
#ifdef DEBUG
				if (inserted) cerr << "*** TrackGraph::insertCompressedNode: added r0 edge to old node" << endl;
#endif
			}
		}
		edgeNode = FindNode(rn1);
#ifdef DEBUG
		cerr << "*** TrackGraph::insertCompressedNode(): edgeNode (rn1) = " << edgeNode << " [" << nodes[edgeNode].id << "]" << endl;
#endif
		if (edgeNode != none) {
			bpos = backpointers.find(edgeNode);
			if (bpos == backpointers.end())
			{
				add_edge(newnode,insertCompressedNode(edgeNode),CompressedEdgeValues(totalEdgeLength),c_nodes);
			} else
			{
				graph_traits < CompressedGraph >::edge_descriptor e;
				bool inserted;
				tie(e, inserted) = add_edge(newnode,bpos->second,CompressedEdgeValues(totalEdgeLength),c_nodes);
#ifdef DEBUG
				if (inserted) cerr << "*** TrackGraph::insertCompressedNode: added r1 edge to old node" << endl;
#endif
			}
		}
	} else
	{
		int ie;
		for (ie = 0; ie < nEdges; ie++)
		{
			int rn = EdgeIndex(nodeId,ie);
			float totalEdgeLength = EdgeLength(nodeId,ie);
			Node edgeNode = FindNode(rn);
#ifdef DEBUG
			cerr << "*** TrackGraph::insertCompressedNode(): edgeNode (rn" <<  ie << ") = " << edgeNode << " [" << nodes[edgeNode].id << "]" << endl;
#endif
			std::map <Node, CompressedNode>::const_iterator bpos;
			if (edgeNode != none) {
				bpos = backpointers.find(edgeNode);
				if (bpos == backpointers.end())
				{
					add_edge(newnode,insertCompressedNode(edgeNode),CompressedEdgeValues(totalEdgeLength),c_nodes);
				} else
				{
					
					graph_traits < CompressedGraph >::edge_descriptor e;
					bool inserted;
					tie(e, inserted) = add_edge(newnode,bpos->second,CompressedEdgeValues(totalEdgeLength),c_nodes);
#ifdef DEBUG
					if (inserted) cerr << "*** TrackGraph::insertCompressedNode: added r" << ie <<" edge to old node" << endl;
#endif
				}
			}
		}
	}
	return newnode;
}

bool TrackGraph::IsCompressedNode(int cnid) const
{
	if (!compressedP) return false;
	CompressedIdNodeMap::const_iterator pos = c_idMap.find(cnid);
	if (pos == c_idMap.end()) return false;
	else return true;
}

int TrackGraph::CompressedEdgeCount (int cnid) const
{
	if (!compressedP) return -1;
	CompressedIdNodeMap::const_iterator pos = c_idMap.find(cnid);
	if (pos == c_idMap.end()) return -1;
	else {
		CompressedNode n = pos->second;
		graph_traits<CompressedGraph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,c_nodes); i != last; ++i) count++;
		return count;
	}
}

int TrackGraph::CompressedEdgeNode (int cnid, int edgenum) const
{
	if (!compressedP) return -1;
	CompressedIdNodeMap::const_iterator pos = c_idMap.find(cnid);
	if (pos == c_idMap.end()) return -1;
	else {
		CompressedNode n = pos->second;
		graph_traits<CompressedGraph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,c_nodes); i != last; ++i) {
			if (count++ == edgenum) break;
		}
		if (i == last) return -1;
		else return c_nodes[target(*i,c_nodes)].id;
	}
}

float TrackGraph::CompressedEdgeLength (int cnid, int edgenum) const
{
	if (!compressedP) return -2.0;
	CompressedIdNodeMap::const_iterator pos = c_idMap.find(cnid);
	if (pos == c_idMap.end()) return -2.0;
	else {
		CompressedNode n = pos->second;
		graph_traits<CompressedGraph>::out_edge_iterator i, last;
		int count = 0;
		for (tie(i,last) = out_edges(n,c_nodes); i != last; ++i) {
			if (count++ == edgenum) break;
		}
		if (i != last) return c_nodes[*i].length;
		else return -2.0;
	}
}

IntegerList *TrackGraph::CompressedNodeSegments (int cnid) const
{
	if (!compressedP) return NULL;
	CompressedIdNodeMap::const_iterator pos = c_idMap.find(cnid);
	if (pos == c_idMap.end()) return NULL;
	else {
		CompressedNode n = pos->second;
		IntegerList *result = NULL;
		std::list<int>::const_iterator segpos;
		for (segpos =  c_nodes[n].segments.begin();
		     segpos != c_nodes[n].segments.end();
		      ++segpos)
		{
			result = IntegerList::IntAppend(result,*segpos);
		}
		return result;
	}
}

double TrackGraph::CompressedNodePositionX (int cnid) const
{
	if (!compressedP) return -999999.0;
	CompressedIdNodeMap::const_iterator pos = c_idMap.find(cnid);
	if (pos == c_idMap.end()) return  -999999.0;
	else {
		CompressedNode n = pos->second;
		return c_nodes[n].position.x;
	}
}

double TrackGraph::CompressedNodePositionY (int cnid) const
{
	if (!compressedP) return -999999.0;
	CompressedIdNodeMap::const_iterator pos = c_idMap.find(cnid);
	if (pos == c_idMap.end()) return  -999999.0;
	else {
		CompressedNode n = pos->second;
		return c_nodes[n].position.y;
	}
}



void TrackGraph::computeHeads()
{
	std::vector<int> component(num_vertices(nodes)), discover_time(num_vertices(nodes));
	std::vector<default_color_type> color(num_vertices(nodes));
	std::vector<Node> root(num_vertices(nodes));
	/*int num =*/ (void) strong_components(nodes, &component[0],
				    root_map(&root[0]).
				    color_map(&color[0]).
				    discover_time_map(&discover_time[0]));
#ifdef DEBUG
	cerr << "*** TrackGraph::computeHeads(): number of strong_components is " << num << endl;
#endif
	IntegerList::CleanUpIntegerList(heads);
	heads = NULL;
	IntegerList *donecomps = NULL;
	graph_traits < Graph >::vertex_iterator ii, end;
	for (tie(ii, end) = vertices(nodes);ii != end; ++ii) {
		Node n = *ii;
#ifdef DEBUG
		cerr << "*** TrackGraph::computeHeads(): node " << nodes[n].id << " is in component " << component[n] << endl;
#endif
		if (n == none) continue;
		if (donecomps == NULL || !donecomps->ElementP(component[n])) {
#ifdef DEBUG
			cerr << "*** TrackGraph::computeHeads(): adding " << nodes[n].id << " for component " << component[n] << endl;
#endif
			donecomps = IntegerList::IntAppend(donecomps,component[n]);
			heads = IntegerList::IntAppend(heads,nodes[n].id);
		}
	}
	IntegerList::CleanUpIntegerList(donecomps);
	valid_heads = true;
}



void TrackGraph::CompressedGraphCircleLayout(double radius)
{
	if (!compressedP) CompressGraph();
	circle_graph_layout(c_nodes,
			    get(&CompressedNodeValues::position, c_nodes), 
			    radius);
	circleLayoutP = true;
}


bool TrackGraph::CompressedGraphKamadaKawaiSpring(double sidelength)
{
	if (!compressedP) CompressGraph();
	if (!circleLayoutP) CompressedGraphCircleLayout(1000.0);
	return kamada_kawai_spring_layout(c_nodes,
					  get(&CompressedNodeValues::position, c_nodes),
					  get(&CompressedEdgeValues::length, c_nodes),
					  boost::side_length(sidelength));
}
        

TrackGraph::CompressedEdgePairVector TrackGraph::CompressedGraphKruskalMinimumSpanningTree()// const
{
	std::vector < graph_traits < CompressedGraph >::edge_descriptor > spanning_tree;

	kruskal_minimum_spanning_tree(c_nodes,
					std::back_inserter(spanning_tree),
					weight_map(get(&CompressedEdgeValues::length, c_nodes)) );

	CompressedEdgePairVector result;
	for (std::vector < graph_traits < CompressedGraph >::edge_descriptor >::iterator ei = spanning_tree.begin();
		ei != spanning_tree.end(); ++ei)
	{
		CompressedNode s = source(*ei, c_nodes),
			       t = target(*ei, c_nodes);
		result.push_back(std::make_pair(c_nodes[s].id,c_nodes[t].id));
	}
	return result;	
}


TrackGraph::CompressedEdgePairVector TrackGraph::CompressedGraphPrimMinimumSpanningTree()// const
{
	CompressedNodeVector parents(num_vertices(c_nodes));
	prim_minimum_spanning_tree(c_nodes,
				   &parents[0], 
				   weight_map(get(&CompressedEdgeValues::length, c_nodes)) );
	CompressedEdgePairVector result;
	for (std::size_t i = 0; i != parents.size(); ++i)
	{
#ifdef DEBUG
		cerr << "*** TrackGraph::CompressedGraphPrimMinimumSpanningTree: i = " << i << "[" << c_nodes[i].id << "]" << endl;
		cerr << "*** TrackGraph::CompressedGraphPrimMinimumSpanningTree: parents[" << i << "] = " << parents[i] << "[" << c_nodes[parents[i]].id << "]" << endl;
#endif
		if (parents[i] == i) {
			traversePrimMST(result,parents,(CompressedNode)i);
		}
	}
	return result;
}

void TrackGraph::traversePrimMST (TrackGraph::CompressedEdgePairVector &result,
				  TrackGraph::CompressedNodeVector     &parents,
				  TrackGraph::CompressedNode root) const
{
	for (std::size_t i = 0; i != parents.size(); ++i)
	{
		CompressedNode s = parents[i],
			       t = (CompressedNode)i;
		if (t != root && s == root) {
			result.push_back(std::make_pair(c_nodes[s].id,c_nodes[t].id));
			traversePrimMST(result,parents,t);
		}
	}
}
