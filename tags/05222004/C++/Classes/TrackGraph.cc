/* 
 * ------------------------------------------------------------------
 * TrackGraph.cc - Track Graph
 * Created by Robert Heller on Mon Sep 23 21:39:17 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

static char rcsid[] = "$Id$";

#include <math.h>
#include <limits.h>
#include <TrackGraph.h>

const int TrackGraph::ElementCount = 512;

int TurnoutBodyElt::segCount = 0;

TrackGraph::TrackGraph()
{
	int i;
	nodeTable = new Node *[ElementCount];
	for (i = 0; i < ElementCount; i++) nodeTable[i] = NULL;
	
}

TrackGraph::~TrackGraph()
{
	int i;
	Node *n,*nn;
	for (i = 0; i < ElementCount; i++) {
		for (n = nodeTable[i]; n != NULL; n = nn) {
			nn = n->nextNode;
			delete [] n->edges;
			if (n->tgr != NULL) DeleteTurnoutGraphic(n->tgr);
			if (n->tpo != NULL) DeleteTurnoutRouteList(n->tpo);
			delete n;
		}
	}
	delete [] nodeTable;
}

void TrackGraph::InsertStraightTrack(int number,TrackBody *tb)
{
	if (FindNode(number) != NULL) return; // Error message !!!
	int i,hash = number % ElementCount;
	Node *newNode = new Node;
	newNode->nodeId = number;
	newNode->nodeType = Track;
	newNode->numEdges = TrackBody::TrackBodyLength(tb);
	newNode->edges = new Edge[newNode->numEdges];
	newNode->tgr = NULL; newNode->tpo = NULL;
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		newNode->edges[i].index = tb->element->index;
		newNode->edges[i].x = tb->element->x;
		newNode->edges[i].y = tb->element->y;
		newNode->edges[i].a = tb->element->a;
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	newNode->nextNode = nodeTable[hash];
	newNode->length = LengthOfStraight(newNode->edges[0].x,
					   newNode->edges[0].y,
					   newNode->edges[1].x,
					   newNode->edges[1].y);
	nodeTable[hash] = newNode;
	
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
	if (FindNode(number) != NULL) return; // Error message !!!
	int i,hash = number % ElementCount;
	Node *newNode = new Node;
	newNode->nodeId = number;
	newNode->nodeType = Track;
	newNode->numEdges = TrackBody::TrackBodyLength(tb);
	newNode->edges = new Edge[newNode->numEdges];
	newNode->tgr = NULL; newNode->tpo = NULL;
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		newNode->edges[i].index = tb->element->index;
		newNode->edges[i].x = tb->element->x;
		newNode->edges[i].y = tb->element->y;
		newNode->edges[i].a = tb->element->a;
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	newNode->nextNode = nodeTable[hash];
	a1 = atan2(newNode->edges[0].y - orgY,newNode->edges[0].x - orgX);
	a2 = atan2(newNode->edges[1].y - orgY,newNode->edges[1].x - orgX);
	newNode->length = LengthOfCurve(radius,a1,a2);
	nodeTable[hash] = newNode;
	
}

float TrackGraph::LengthOfCurve(float radius, float a1, float a2)
{
	float theta = fabs(a2 - a1),
	      result = theta  * fabs(radius);

	return result;
}

void TrackGraph::InsertJointTrack(int number,TrackBody *tb,float l0, float l1, float angle, float R, float L)
{
	if (FindNode(number) != NULL) return; // Error message !!!
	int i,hash = number % ElementCount;
	Node *newNode = new Node;
	newNode->nodeId = number;
	newNode->nodeType = Track;
	newNode->numEdges = TrackBody::TrackBodyLength(tb);
	newNode->edges = new Edge[newNode->numEdges];
	newNode->tgr = NULL; newNode->tpo = NULL;
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		newNode->edges[i].index = tb->element->index;
		newNode->edges[i].x = tb->element->x;
		newNode->edges[i].y = tb->element->y;
		newNode->edges[i].a = tb->element->a;
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	newNode->nextNode = nodeTable[hash];
	newNode->length = LengthOfJoint(l0,l1,angle,R,L);
	nodeTable[hash] = newNode;
	
}

float TrackGraph::LengthOfJoint(float l0, float l1, float angle, float R, float L)
{
	return l0+l1; // approximation...
}
void TrackGraph::InsertTurnOut(int number, float orgX, float orgY, float orient,
			   const char *name,TurnoutBody *trb)
{
	if (FindNode(number) != NULL) return; // Error message !!!
	int i,hash = number % ElementCount;
	Node *newNode = new Node;
	newNode->nodeId = number;
	newNode->nodeType = Turnout;
	TrackBody *tb = trb->TurnoutEnds();
	newNode->numEdges = TrackBody::TrackBodyLength(tb);
	newNode->edges = new Edge[newNode->numEdges];
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		newNode->edges[i].index = tb->element->index;
		newNode->edges[i].x = tb->element->x;
		newNode->edges[i].y = tb->element->y;
		newNode->edges[i].a = tb->element->a - orient;
		//delete tb->element; (Memory freed elsewhere)
		ne = tb->next;
		delete tb;
	}
	newNode->tgr = MakeTurnoutGraphic(orgX,orgY,orient,trb);
	newNode->tpo = MakeTurnoutRouteList(trb,newNode->tgr,newNode->length);
	TurnoutBody::CleanUpTurnoutBody(trb);		
	newNode->nextNode = nodeTable[hash];
	nodeTable[hash] = newNode;
}

void TrackGraph::InsertTurnTable(int number, float orgX, float orgY, float radius,
			   TrackBody *tb)
{
	if (FindNode(number) != NULL) return; // Error message !!!
	int i,hash = number % ElementCount;
	Node *newNode = new Node;
	newNode->nodeId = number;
	newNode->nodeType = Turntable;
	newNode->numEdges = TrackBody::TrackBodyLength(tb);
	newNode->edges = new Edge[newNode->numEdges];
	newNode->tgr = NULL; newNode->tpo = NULL;
	TrackBody *ne;
	for (i = 0; tb != NULL; tb = ne, i++) {
		newNode->edges[i].index = tb->element->index;
		newNode->edges[i].x = tb->element->x;
		newNode->edges[i].y = tb->element->y;
		newNode->edges[i].a = tb->element->a;
		delete tb->element;
		ne = tb->next;
		delete tb;
	}
	newNode->nextNode = nodeTable[hash];
	newNode->length = radius * 2.0;
	nodeTable[hash] = newNode;
}

ostream& operator << (ostream& stream,TrackGraph& graph)
{
	int i,ie,jj;
	TrackGraph::Node *n;
	for (i = 0; i < TrackGraph::ElementCount; i++) {
		n = graph.nodeTable[i];
		while (n != NULL) {
			stream << "Node: " << n->nodeId << ", " << n->numEdges << " edges:";
			for (ie = 0; ie < n->numEdges; ie++) {
				stream << " (" << n->edges[ie].index << ",";
				stream << n->edges[ie].x << ",";
				stream << n->edges[ie].y << ") ";
				stream << n->edges[ie].a << "degrees";
			}
			for (jj = 0;jj < n->tgr->numSegments; jj++)
			{
				stream << jj+1 << ": ";
				switch (n->tgr->segments[jj].tgType) {
					case SegVector::S: stream << "S ";
						stream << "(" << n->tgr->segments[jj].gPos1.x << "," <<  n->tgr->segments[jj].gPos1.y << "), ";
						stream << "(" << n->tgr->segments[jj].gPos1.x << "," <<  n->tgr->segments[jj].gPos1.y << ")" << endl;
						break;
					case SegVector::C: stream << "C ";
						stream << n->tgr->segments[jj].radius;
						stream << " (" << n->tgr->segments[jj].gPos1.x << "," <<  n->tgr->segments[jj].gPos1.y << ") ";
						stream << n->tgr->segments[jj].ang0 << " " << n->tgr->segments[jj].ang1 << endl;
						break;
					case SegVector::J: stream << "J ";
						stream << " (" << n->tgr->segments[jj].gPos1.x << "," <<  n->tgr->segments[jj].gPos1.y << ") ";
						stream << n->tgr->segments[jj].angle << " " << n->tgr->segments[jj].len0 << " " << n->tgr->segments[jj].len1 << " " << n->tgr->segments[jj].R << " " << n->tgr->segments[jj].L << endl;
						break;
				}
				
			}
			for (jj = 0;jj < n->tpo->numRoutelists; jj++) {
				stream << "P \"" << n->tpo->routes[jj].positionName << "\" "<< n->tpo->routes[jj].posList << endl;
			}
			stream << n->length << " long.";
			stream << endl;
			n = n->nextNode;
		}		
	}
	return stream;
}

TrackGraph::Node *TrackGraph::FindNode(int number) const
{
	int hash = number % ElementCount;
	Node * n = nodeTable[hash];
	while (n != NULL) {
		if (n->nodeId == number) return n;
		else n = n->nextNode;
	}
	return NULL;
}

bool TrackGraph::IsNodeP(int nid)
{
	if (FindNode(nid) == NULL) return false;
	else return true;
}

int TrackGraph::NumEdges(int nid)
{
	Node *n = FindNode(nid);
	if (n == NULL) return -1;
	else return n->numEdges;
}

int TrackGraph::EdgeIndex(int nid, int edgenum)
{
	Node *n = FindNode(nid);
	if (n == NULL) return -2;
	else {
		if (edgenum < n->numEdges) return n->edges[edgenum].index;
		else return -2;
	}
}
	
float TrackGraph::EdgeX(int nid, int edgenum)
{
	Node *n = FindNode(nid);
	if (n == NULL) return -2.0;
	else {
		if (edgenum < n->numEdges) return n->edges[edgenum].x;
		else return -2.0;
	}
}

float TrackGraph::EdgeY(int nid, int edgenum)
{
	Node *n = FindNode(nid);
	if (n == NULL) return -2.0;
	else {
		if (edgenum < n->numEdges) return n->edges[edgenum].y;
		else return -2.0;
	}
}

float TrackGraph::EdgeA(int nid, int edgenum)
{
	Node *n = FindNode(nid);
	if (n == NULL) return -2.0;
	else {
		if (edgenum < n->numEdges) return n->edges[edgenum].a;
		else return -2.0;
	}
}

TrackGraph::NodeType TrackGraph::TypeOfNode(int nid)
{
	Node *n = FindNode(nid);
	if (n == NULL) return Track;
	else return n->nodeType;
}

const TurnoutGraphic *TrackGraph::NodeTurnoutGraphic(int nid) const
{
	Node *n = FindNode(nid);
	if (n == NULL) return NULL;
	else return n->tgr;
}

const TurnoutRoutelist *TrackGraph::NodeTurnoutRoutelist(int nid) const
{
	Node *n = FindNode(nid);
	if (n == NULL) return NULL;
	else return n->tpo;
}

float TrackGraph::LengthOfNode(int nid)
{
	Node *n = FindNode(nid);
	if (n == NULL) return 0.0;
	else return n->length;
}

int TrackGraph::LowestNode()
{
	int i,ln;
	Node *n;

	ln = INT_MAX;

	for (i = 0; i < ElementCount; i++) {
		n = nodeTable[i];
		while (n != NULL) {
			if (n->nodeId < ln) ln = n->nodeId;
			n = n->nextNode;
		}
	}
	if (ln == INT_MAX) return -1;
	else return ln;
}

int TrackGraph::HighestNode()
{
	int i,ln;
	Node *n;

	ln = -1;

	for (i = 0; i < ElementCount; i++) {
		n = nodeTable[i];
		while (n != NULL) {
			if (n->nodeId > ln) ln = n->nodeId;
			n = n->nextNode;
		}
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

TrackGraph::Transform2D* operator * (const TrackGraph::Transform2D& t1, const TrackGraph::Transform2D& t2)
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
}

void TrackGraph::DeleteTurnoutRouteList(TurnoutRoutelist *tpo)
{
}


