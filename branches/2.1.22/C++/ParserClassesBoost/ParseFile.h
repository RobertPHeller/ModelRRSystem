/* 
 * ------------------------------------------------------------------
 * ParseFile.h - File Parsing Super classes
 * Created by Robert Heller on Sun Aug  6 15:25:25 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.6  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.5  2005/11/05 05:52:08  heller
 * Modification History: Upgraded for G++ 3.2
 * Modification History:
 * Modification History: Revision 1.4  2002/10/17 00:00:53  heller
 * Modification History: Add Documentation  (Doc++)
 * Modification History:
 * Modification History: Implement turnout body, track length, and turntable support.
 * Modification History:
 * Modification History: Revision 1.3  2002/09/25 01:54:53  heller
 * Modification History: Implement Tcl access to graph nodes.
 * Modification History:
 * Modification History: Revision 1.2  2002/09/24 04:20:18  heller
 * Modification History: MRRXtrkCad => TrackGraph
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.4  2000/11/10 00:26:10  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.3  1995/09/12 02:45:22  heller
 * Modification History: Add in ClassFile and MRRClassFile code
 * Modification History:
 * Revision 2.2  1995/09/09  22:58:38  heller
 * Add in trees member
 * Move constructor to cc file
 *
 * Revision 2.1  1995/08/06  19:37:49  heller
 * *** empty log message ***
 *
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995  Robert Heller D/B/A Deepwoods Software
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

#ifndef _PARSEFILE_H_
#define _PARSEFILE_H_

#ifdef SWIG

/** This is a file-based parser for XTrkCAD layout files.  It reads and parses
  * the trackwork elements of an XTrkCAD layout file and builds a track graph
  * structure, implemented using the Boost Graph Library.  See the documentation
  * for class TrackGraph in this section for details.
  * @args : public LayoutFile
  */
class MRRXtrkCad {
public:
	/** @memo Constructor.
	  * @doc This is the public constructor.  All internal structures are
	  * allocated and initialized and the source file is stored.
	  * @param filename The layout file to parse.
	  */
	MRRXtrkCad(const char *filename);
	/** @memo Destructor.
	  * @doc All allocated internal structures are freed and cleaned up.
	  */
	~MRRXtrkCad();
	/*+ Return the name of the source file.
	  */
	const char * SourceFile();
	/*+ Checks to see if the specified node number is in fact an allocated
	  * node.  Returns true if the node number is a node and false otherwise.
	  * @param nid The node id to check.
	  */
	bool IsNodeP(int nid) const;
	/*+ Return the number of edges for the specified node.
	  * @param nid The node id to return the number of edges for.
	  */
	int NumEdges(int nid) const;
	/*+ Return the node the edge number is connected to.
	  * @param nid The node whose edge list to look at.
	  * @param edgenum The index of the edge to check.
	  */
	int EdgeIndex(int nid, int edgenum) const;
	/*+ Return the $x$ coordinate of the selected edge number.
	  * @param nid The node whose edge list to look at.
	  * @param edgenum The index of the edge to check.
	  */
	float EdgeX(int nid, int edgenum) const;
	/*+ Return the $y$ coordinate of the selected edge number.
	  * @param nid The node whose edge list to look at.
	  * @param edgenum The index of the edge to check.
	  */
	float EdgeY(int nid, int edgenum) const;
	/*+ Return the angle of the selected edge number.
	  * @param nid The node whose edge list to look at.
	  * @param edgenum The index of the edge to check.
	  */
	float EdgeA(int nid, int edgenum) const;
	/*+ Returns the length of an edge.
	  */
	float EdgeLength(int nid, int edgenum) const;
	/*+ Return the length of the specified node.
	  * @param nid The node whose edge list to look at.
	  */
	float LengthOfNode(int nid) const;
	/*+ Return the turnout graphic structure for a given node.
	  * @param nid The node whose edge list to look at.
	  */
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const;
	/*+ Return the turnout route list for a given node.
	  * @param nid The node whose edge list to look at.
	  */
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const;
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
	/*+ Return the highest node number.
	  */
	int LowestNode() const;
	/*+ Return the lowest node number.
	  */
	int HighestNode() const;
	/*+ Create a compressed graph.
	  */
	void CompressGraph();
	/*+ Number of compressed graph edges.
	  */
	int CompressedEdgeCount (int cnid) const;
	/*+ Length of a compressed graph edge.
	  */
	float CompressedEdgeLength (int cnid, int edgenum) const;
	/*+ Next Edge node.
	  */
	int CompressedEdgeNode (int cnid, int edgenum) const;
	/*+ Uncompressed graph heads.
	  */
	const IntegerList *Heads();
	/*+ Compressed graph roots.
	  */
	const IntegerList *Roots();
	/*+ Is cid a node in the compressed graph?
	  */
	bool IsCompressedNode(int cnid) const;
	/*+ X Coordinate of a Compressed Node position.
	  */
	double CompressedNodePositionX (int cnid) const;
	/*+ X Coordinate of a Compressed Node position.
	  */
	double CompressedNodePositionY (int cnid) const;
	/*+ Run the BGL circle_graph_layout for a given radius.
	  */
	void CompressedGraphCircleLayout(double radius);	
	/*+ Run the BGL kamada_kawai_spring_layout for a given side length.
	  */
	bool CompressedGraphKamadaKawaiSpring(double sidelength);
	%extend {
		%apply int MyTcl_Result { int ProcessFile };
		/*+ @memo Process the source file.
		  * @args (ostream &err)
		  * @type int
		  * @doc The source file is processed. Returns zero on
		  * success and a non-zero value on error.  The Tcl interface
		  * takes no arguments and returns an empty string on success
		  * and an error is raised on failure.
		  * @param err Output string to write error messages to.
		  */
		int ProcessFile(Tcl_Interp *interp) {
			std::ostringstream error;
			if (self->ProcessFile(error) != 0) {
				const std::string bytes = error.str();
				int i = bytes.size();
				Tcl_Obj * tcl_result = (Tcl_GetObjResult(interp));
				Tcl_AppendToObj(tcl_result,bytes.c_str(),i);
				return TCL_ERROR;
			} else return TCL_OK;
		}
		%apply int MyTcl_Result { int Emit };
		/*+ @args (ostream& outstream)
		  * @type void
		  * @doc The contents of the track graph are written to the
		  * specified output stream.  The Tcl interface takes the
		  * name of a file to write to.
		  * @param outstream The output stream to write to.
		  */
		int Emit(Tcl_Interp *interp,const char * outfile) {
			Tcl_ResetResult(interp);
			ofstream output(outfile);
			self->Emit(output);
			return TCL_OK;
		}
		%apply int MyTcl_Result { int CompressedNodeSegments };
		/*+ Raw nodes in a compressed graph node.
		  */
		int CompressedNodeSegments (Tcl_Interp *interp, int cnid)
		{
			IntegerList *segments = self->CompressedNodeSegments(cnid);
			IntegerList *p;
			Tcl_Obj * tcl_result = Tcl_NewListObj(0,NULL);
			for (p = segments; p != NULL; p = p->Next()) {
				if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewIntObj(p->Element())) != TCL_OK)
				return TCL_ERROR;
			}
			Tcl_SetObjResult(interp,tcl_result);
			IntegerList::CleanUpIntegerList(segments);
			return TCL_OK;
		}
		%apply int MyTcl_Result { int CompressedGraphKruskalMinimumSpanningTree };
		/*+ Run the kruskal_minimum_spanning_tree algorithm and return a vector of edge pairs.
		  */
		int CompressedGraphKruskalMinimumSpanningTree(Tcl_Interp *interp)// const
		{
			TrackGraph::CompressedEdgePairVector vect =
				self->CompressedGraphKruskalMinimumSpanningTree();
			TrackGraph::CompressedEdgePairVector::const_iterator p;
			Tcl_Obj * tcl_result = Tcl_NewListObj(0,NULL);
			for (p = vect.begin(); p != vect.end(); ++p)
			{
				Tcl_Obj * pair = Tcl_NewListObj(0,NULL);
				if (Tcl_ListObjAppendElement(interp,pair,Tcl_NewIntObj(p->first)) != TCL_OK)
					return TCL_ERROR;
				if (Tcl_ListObjAppendElement(interp,pair,Tcl_NewIntObj(p->second)) != TCL_OK)
					return TCL_ERROR;
				if (Tcl_ListObjAppendElement(interp,tcl_result,pair) != TCL_OK)
					return TCL_ERROR;
			}
			Tcl_SetObjResult(interp,tcl_result);
			return TCL_OK;
		}
		%apply int MyTcl_Result { int CompressedGraphPrimMinimumSpanningTree };
		/*+ Run the prim_minimum_spanning_tree algorithm and return a vector of edge pairs.
		  */
		int CompressedGraphPrimMinimumSpanningTree(Tcl_Interp *interp)// const
		{
			TrackGraph::CompressedEdgePairVector vect =
				self->CompressedGraphPrimMinimumSpanningTree();
			TrackGraph::CompressedEdgePairVector::const_iterator p;
			Tcl_Obj * tcl_result = Tcl_NewListObj(0,NULL);
			for (p = vect.begin(); p != vect.end(); ++p)
			{
				Tcl_Obj * pair = Tcl_NewListObj(0,NULL);
				if (Tcl_ListObjAppendElement(interp,pair,Tcl_NewIntObj(p->first)) != TCL_OK)
					return TCL_ERROR;
				if (Tcl_ListObjAppendElement(interp,pair,Tcl_NewIntObj(p->second)) != TCL_OK)
					return TCL_ERROR;
				if (Tcl_ListObjAppendElement(interp,tcl_result,pair) != TCL_OK)
					return TCL_ERROR;
			}
			Tcl_SetObjResult(interp,tcl_result);
			return TCL_OK;
		}
		/*+ Return the type of node.  The Tcl interface returns a
		  * string representing the type of the node.
		  * @type TrackGraph::NodeType
		  * @param nid Node index to fetch the type of.
		  */
		const char * TypeOfNode(int nid)
		{
			switch (self->TypeOfNode(nid))
			{
				case TrackGraph::Track: return("TrackGraph::Track"); break;
				case TrackGraph::Turnout: return("TrackGraph::Turnout"); break;
				case TrackGraph::Turntable: return("TrackGraph::Turntable"); break;
				case TrackGraph::Block: return("TrackGraph::Block"); break;
				case TrackGraph::SwitchMotor: return("TrackGraph::SwitchMotor"); break;
				case TrackGraph::Undefined: return("TrackGraph::Undefined"); break;
			}
			return NULL;
		}
	}		
};

#else
#include <iostream>
#include <string.h>
#include <stdio.h>
#include <TrackGraph.h>

class MRRXtrkCad;

/**  Virtual base class for file-based parsers.  Contains all of the base level
  * input and error output support members.
  */
class ParseFile {
protected:
	/**  Input line buffer pointer.
	  */
	char *lp;
	/**  Input file pointer.
	  */
	FILE *fp;
	/**  Source line number.  Used for error reporting.
	  */
	int   source_line;
	/**  Size of line buffer.
	  */
	static const int buffersize = 1024;
	/**  Input line buffer.
	  */
	char  line_buffer[buffersize];
	/**  Stream for error reporting.
	  */
	ostream *errorstream;
	/**  The parser itself, supplied by derived classes.
	  */
	virtual int Parse() = 0;
	/**  The parser's error handler, supplied by derived classes.
	  */
	virtual void ParseError(const char *) = 0;
	/**  Name of the source file.
	  */
	char * source_file;
public:
	/**  Return the name of the source file.
	  */
	const char * SourceFile() const {return source_file;}
	/** @memo Constructor.
	  * @doc Make a local copy of the source file name,
	  * Other members are initialized.
	  */
	ParseFile(const char * filename)
		{source_file = new char[strlen(filename)+1];
		 strcpy(source_file,filename);
		 fp = NULL;source_line = 0;lp = NULL;
		 }
	/** @memo Destructor.
	  * @doc Free up memory.
	  */
	virtual ~ParseFile() {delete source_file;}
	/**  open file and parse it.
	  * @param err Output string to write error messages to.
	  */
	int ProcessFile(ostream &err);
};

/** File to parse an XTrkCad layout file and create a track graph.
  */
class LayoutFile : public ParseFile {
protected:
	/**  Parser.
	  */
	MRRXtrkCad* parser;
	/**  Parseer function.
	  */
	virtual int Parse();
	/**  Parse error handler.
	  */
	virtual void ParseError(const char *m);
	/**   Track graph, a graph of all of the trackwork in the layput
	  file. */
	TrackGraph *trackGraph;
public:
	/** @memo Constructor.
	  */
	LayoutFile (const char * filename,MRRXtrkCad* p);
	/** @memo Destructor.
	  */
	virtual ~LayoutFile();
	/**  Function to Emit a track graph to an output stream.
	  *  @param outstream The output stream to write the graph to.
	  */
	void Emit(ostream& outstream);
	/**  Tests if a node id exists in the graph.
	  */
	bool IsNodeP(int nid) const {return trackGraph->IsNodeP(nid);}
	/**  Returns the number of edges for the specificed node id.
	  */
	int NumEdges(int nid) const {return trackGraph->NumEdges(nid);}
	/**  Returns the node id of the specificed edge of the node.
	  */
	int EdgeIndex(int nid, int edgenum) const {return trackGraph->EdgeIndex(nid, edgenum);}
	/**  Returns the $X$ coordinate of the specificed edge of the node.
	  */
	float EdgeX(int nid, int edgenum) const {return trackGraph->EdgeX(nid, edgenum);}
	/**  Returns the $Y$ coordinate of the specificed edge of the node.
	  */
	float EdgeY(int nid, int edgenum) const {return trackGraph->EdgeY(nid, edgenum);}
	/**  Returns the angle of the specificed edge of the node.
	  */
	float EdgeA(int nid, int edgenum) const {return trackGraph->EdgeA(nid, edgenum);}
	/** Returns the length of an edge.
	  */
	float EdgeLength(int nid, int edgenum) const {return trackGraph->EdgeLength(nid,edgenum);}
	/**  Returns the type of the node.
	  */
	TrackGraph::NodeType TypeOfNode(int nid) const {return trackGraph->TypeOfNode(nid);}
	/**  Returns the TurnoutGraphic of the node.
	  */
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const
		{return trackGraph->NodeTurnoutGraphic(nid);}
	/**  Returns the TurnoutRoutelist of the node.
	  */
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const
		{return trackGraph->NodeTurnoutRoutelist(nid);}
	/**  Return the track length of a node.
	  */
	float LengthOfNode(int nid) const {return trackGraph->LengthOfNode(nid);}
	/**  Return a block's tracklist.
	  */
	const IntegerList *TrackList(int nid) const {return trackGraph->TrackList(nid);}
        /**  Return a switchmotor's turnout number.
          */
        int TurnoutNumber(int nid) const {return trackGraph->TurnoutNumber(nid);}
	/**  Return a block's or switchmotor's name.
	  */
	const char * NameOfNode(int nid) const {return trackGraph->NameOfNode(nid);}
	/**  Return a block's or switchmotor's sense script.
	  */
	const char * SenseScript(int nid) const {return trackGraph->SenseScript(nid);}
	/**  Return a switchmotor's normal action script.
	  */
	const char * NormalActionScript(int nid) const {return trackGraph->NormalActionScript(nid);}
	/**  Return a block's or switchmotor's reverse action script.
	  */
	const char * ReverseActionScript(int nid) const {return trackGraph->ReverseActionScript(nid);}
	/**  Returns the lowest numbered node id.
	  */
	int LowestNode() const {return trackGraph->LowestNode();}
	/**  Returns the highest numbered node id.
	  */
	int HighestNode() const {return trackGraph->HighestNode();}
	/** Create a compressed graph.
	  */
	void CompressGraph() {trackGraph->CompressGraph();}
	/** Number of compressed graph edges.
	  */
	int CompressedEdgeCount (int cnid) const
	{
		return trackGraph->CompressedEdgeCount (cnid);
	}
	/** Length of a compressed graph edge.
	  */
	float CompressedEdgeLength (int cnid, int edgenum) const
	{
		return trackGraph->CompressedEdgeLength( cnid, edgenum );
	}
	/** Next Edge node.
	  */
	int CompressedEdgeNode (int cnid, int edgenum) const
	{
		return trackGraph->CompressedEdgeNode (cnid, edgenum);
	}
	/** Raw nodes in a compressed graph node.
	  */
	IntegerList *CompressedNodeSegments (int cnid) const
	{
		return trackGraph->CompressedNodeSegments (cnid);
	}
	const IntegerList *Heads() {return trackGraph->Heads();}
	/** Is cid a node in the compressed graph?
	  */
	bool IsCompressedNode(int cnid) const
	{
		return trackGraph->IsCompressedNode(cnid);
	}
	/** Compressed graph roots.
	  */
	const IntegerList *Roots() {return trackGraph->Roots();}
	/** X Coordinate of a Compressed Node position.
	  */
	double CompressedNodePositionX (int cnid) const {return trackGraph->CompressedNodePositionX(cnid);}
	/** X Coordinate of a Compressed Node position.
	  */
	double CompressedNodePositionY (int cnid) const {return trackGraph->CompressedNodePositionY(cnid);}
	/** Run the BGL circle_graph_layout for a given radius.
	  */
	void CompressedGraphCircleLayout(double radius) {trackGraph->CompressedGraphCircleLayout(radius);}
	/** Run the BGL kamada_kawai_spring_layout for a given side length.
	  */
	bool CompressedGraphKamadaKawaiSpring(double sidelength)
	{
		return trackGraph->CompressedGraphKamadaKawaiSpring(sidelength);
	}
	/** Run the kruskal_minimum_spanning_tree algorithm and return a vector of edge pairs.
	  */
	TrackGraph::CompressedEdgePairVector CompressedGraphKruskalMinimumSpanningTree()// const
	{
		return trackGraph->CompressedGraphKruskalMinimumSpanningTree();
	}
	/** Run the prim_minimum_spanning_tree algorithm and return a vector of edge pairs.
	  */
	TrackGraph::CompressedEdgePairVector CompressedGraphPrimMinimumSpanningTree()// const
	{
		return trackGraph->CompressedGraphPrimMinimumSpanningTree();
	}
};

#endif
#endif // _PARSEFILE_H_
 
