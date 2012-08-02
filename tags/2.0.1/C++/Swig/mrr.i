/* 
 * ------------------------------------------------------------------
 * mrr.i - 
 * Created by Robert Heller on Sun Jul 28 10:05:27 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.6  2004/06/26 13:31:09  heller
 * Modification History: Update versioning for new release
 * Modification History:
 * Modification History: Revision 1.5  2004/03/13 15:50:03  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 1.4  2002/10/17 00:02:07  heller
 * Modification History: Implement turnout body, track length, and turntable support, along with
 * Modification History: accessors.
 * Modification History:
 * Modification History: Revision 1.3  2002/09/25 01:55:14  heller
 * Modification History: Implement Tcl access to graph nodes.
 * Modification History:
 * Modification History: Revision 1.2  2002/07/28 14:06:34  heller
 * Modification History: Add it copyright notice headers
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
%title ""
%module Mrr
%{
#include <iostream.h>   
#include <strstream.h>
#include <fstream.h>
#include <ParseFile.h>
#include <TrackGraph.h>
/*#include <Tree.h>*/
/*#include <MRRSigExpr.tab.h>*/
#include <MRRXtrkCad.tab.h>
static char rcsid[] = "$Id$";
%}

%text %{
\newcommand{\MRRSubTitle}{Swig Internals}
\include{titlepage}
\tableofcontents%  %}

%include typemaps.i

%init %{
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
	    return TCL_ERROR;
	}
	Tcl_PkgProvide(interp,"Mrr",MRR_PATCH_LEVEL);
%}

%typemap(tcl,out) int MyTcl_Result {
 return $source;
}

%typemap(tcl,out) SegPos * {
	static char temp[32];
	Tcl_ResetResult(interp);
	sprintf(temp,"%f",$source->x);
	Tcl_AppendElement(interp,temp);
	sprintf(temp,"%f",$source->y);
	Tcl_AppendElement(interp,temp);
}


#ifdef NOCOMP
struct SegPos {
	float x; /* $X$ coordinate. */ 
	float y; /* $Y$ coordinate. */ 
}; // Segment position, endpoint or other coordinate.
#endif


%readonly
struct SegVector {
	enum GrType {
		S, /* Straight segment. */ 
		C, /* Curved (circular) segment. */ 
		J /* Curved (spiral easement) segment. */
	}; // Graphic types.
#ifdef NOCOMP
	GrType tgType;/* Segment type. */ 
#endif
	SegPos gPos1;/* First graphic position. */ 
	SegPos gPos2;/* Second graphic position. */ 
	SegPos ePos1;/* First end point position. */ 
	SegPos ePos2;/* Second end point position. */ 
	float radius;/* Radius value. */ 
	float ang0;/* First angle. */ 
	float ang1;/* Second angle. */
	float R;/* $R$ value. */ 
	float L;/* $L$ value. */ 
	float angle;/* An angle.. */ 
	float len0;/* First length parameter. */ 
	float len1;/* Second length parameter. */ 
	float length;/* Length of segment. */ 
}; // Segemnt structure.


%addmethods SegVector {
	const char *tgType() {
		switch (self->tgType) {
			case SegVector::S: return "SegVector::S"; break;
			case SegVector::C: return "SegVector::C"; break;
			case SegVector::J: return "SegVector::J"; break;
		}
		return NULL;
	}
};
	
struct TurnoutGraphic {
	float minX;/* Minimum $X$ coordinate. */ 
	float minY;/* Minimum $Y$ coordinate. */ 
	float maxX;/* Maximum $X$ coordinate. */ 
	float maxY;/* Maximum $Y$ coordinate. */ 
	int numSegments;/* Number of segments. */ 
#ifdef NOCOMP
	SegVector segments[]; 	// Segment vector.
#endif
}; /* Structure holding a turnout's graphical information. 	 */

%addmethods TurnoutGraphic {
	const SegVector *segmentI (int i) const {
		if (i < 0 || i >= self->numSegments) return NULL;
		else return &self->segments[i];
	}
};


%typemap(tcl,out) IntegerList * {
	static char temp[32];
	const IntegerList *p;
	Tcl_ResetResult(interp);
	for (p = $source; p != NULL; p = p->Next()) {
		sprintf(temp,"%d",p->Element());
		Tcl_AppendElement(interp,temp);
	}
}	

struct RouteVec {
	char *positionName;/* Name of route. */ 
	IntegerList *posList;/* List of segments used by the route. */ 
	float routeLength;/* Length of the route. */ 
}; // Route structure.



struct TurnoutRoutelist {
	int numRoutelists;/* Number of routes. */ 
#ifdef NOCOMP
	RouteVec routes[]; // Route vector.
#endif
}; // Turnout route list structure.

%addmethods TurnoutRoutelist {
	const RouteVec *routeI (int i) const {
		if (i < 0 || i >= self->numRoutelists) return NULL;
		else return &self->routes[i];
	}
};
%readwrite

class MRRXtrkCad {
public:
	MRRXtrkCad(const char *);
	~MRRXtrkCad();
	const char * SourceFile();
	bool IsNodeP(int nid);
	int NumEdges(int nid);
	int EdgeIndex(int nid, int edgenum);
	float EdgeX(int nid, int edgenum);
	float EdgeY(int nid, int edgenum);
	float EdgeA(int nid, int edgenum);
	float LengthOfNode(int nid);
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const;
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const;
	int LowestNode();
	int HighestNode();
};

%apply int MyTcl_Result { int MRRXtrkCad_Emit };
%apply int MyTcl_Result { int MRRXtrkCad_ProcessFile };

%addmethods MRRXtrkCad {
	int ProcessFile(Tcl_Interp *interp) {
		ostrstream error;
		if (self->ProcessFile(error) != 0) {
			_IO_ssize_t i = error.pcount();
			char *s = error.str();
			s[i] = '\0';
			Tcl_AppendResult(interp,s,(char*)NULL);
			error.freeze(0);
			return TCL_ERROR;
		} else return TCL_OK;
	}
	int Emit(Tcl_Interp *interp,const char * outfile) {
		Tcl_ResetResult(interp);
		ofstream output(outfile);
		self->Emit(output);
		return TCL_OK;
	}
	const char * TypeOfNode(int nid)
	{
		switch (self->TypeOfNode(nid))
		{
			case TrackGraph::Track: return("TrackGraph::Track"); break;
			case TrackGraph::Turnout: return("TrackGraph::Turnout"); break;
			case TrackGraph::Turntable: return("TrackGraph::Turntable"); break;
		}
		return NULL;
	}
}



%section "Socketpair"


%apply int MyTcl_Result { int tcl_socketpair };

%{
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <errno.h>
%}

%inline %{
int tcl_socketpair(Tcl_Interp *interp)
{
	static char name[16 + TCL_INTEGER_SPACE];
	int fds[2], i;
	Tcl_Channel chans[2];

	if (socketpair(AF_UNIX,SOCK_STREAM,0,fds) < 0) {
		Tcl_AppendResult(interp,strerror(errno),(char*)NULL);
		return TCL_ERROR;
	}
	Tcl_ResetResult(interp);
	for (i = 0; i < 2; i++) {
		chans[i] = Tcl_MakeTcpClientChannel((ClientData) fds[i]);
		Tcl_RegisterChannel(interp,chans[i]);
		sprintf(name,"sock%d",fds[i]);
		Tcl_AppendElement(interp,name);
	}
	return TCL_OK;
		
}
%}

