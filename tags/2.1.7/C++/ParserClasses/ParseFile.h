/* 
 * ------------------------------------------------------------------
 * ParseFile.h - File Parsing Super classes
 * Created by Robert Heller on Sun Aug  6 15:25:25 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

#include <iostream>
#include <string.h>
#include <stdio.h>
#include <TrackGraph.h>

class MRRXtrkCad;

/**  
  Virtual base class for file-based parsers.  Contains all of the base level
  input and error output support members.
 */
class ParseFile {
protected:
	///  Input line buffer pointer.
	char *lp;
	///  Input file pointer.
	FILE *fp;
	///  Source line number.  Used for error reporting.
	int   source_line;
	///  Size of line buffer.
	static const int buffersize = 1024;
	///  Input line buffer.
	char  line_buffer[buffersize];
	///  Stream for error reporting.
	ostream *errorstream;
	///  The parser itself, supplied by derived classes.
	virtual int Parse() = 0;
	///  The parser's error handler, supplied by derived classes.
	virtual void ParseError(const char *) = 0;
	///  Name of the source file.
	char * source_file;
public:
	///  Return the name of the source file.
	const char * SourceFile() const {return source_file;}
	/**  
          Constructor.  Make a local copy of the source file name,
	  Other members are initialized.
	 */
	ParseFile(const char * filename)
		{source_file = new char[strlen(filename)+1];
		 strcpy(source_file,filename);
		 fp = NULL;source_line = 0;lp = NULL;
		 }
	///  Destructor, free up memory.
	virtual ~ParseFile() {delete source_file;}
	///  open file and parse it.
	int ProcessFile(ostream &err);
};

/**  
  File to parse an XTrkCad layout file and create a track graph.
 */
class LayoutFile : public ParseFile {
protected:
	///  Parser.
	MRRXtrkCad* parser;
	///  Parseer function.
	virtual int Parse();
	///  Parse error handler.
	virtual void ParseError(const char *m);
	/**   Track graph, a graph of all of the trackwork in the layput
	  file. */
	TrackGraph *trackGraph;
public:
	///  Constructor.
	LayoutFile (const char * filename,MRRXtrkCad* p);
	///  Destructor.
	virtual ~LayoutFile();
	///  Function to Emit a track graph to a file.
	void Emit(ostream& outstream);
	///  Tests if a node id exists in the graph.
	bool IsNodeP(int nid) {return trackGraph->IsNodeP(nid);}
	///  Returns the number of edges for the specificed node id.
	int NumEdges(int nid) {return trackGraph->NumEdges(nid);}
	///  Returns the node id of the specificed edge of the node.
	int EdgeIndex(int nid, int edgenum) {return trackGraph->EdgeIndex(nid, edgenum);}
	///  Returns the $X$ coordinate of the specificed edge of the node.
	float EdgeX(int nid, int edgenum) {return trackGraph->EdgeX(nid, edgenum);}
	///  Returns the $Y$ coordinate of the specificed edge of the node.
	float EdgeY(int nid, int edgenum) {return trackGraph->EdgeY(nid, edgenum);}
	///  Returns the angle of the specificed edge of the node.
	float EdgeA(int nid, int edgenum) {return trackGraph->EdgeA(nid, edgenum);}
	///  Returns the type of the node.
	TrackGraph::NodeType TypeOfNode(int nid) {return trackGraph->TypeOfNode(nid);}
	///  Returns the TurnoutGraphic of the node.
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const
		{return trackGraph->NodeTurnoutGraphic(nid);}
	///  Returns the TurnoutRoutelist of the node.
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const
		{return trackGraph->NodeTurnoutRoutelist(nid);}
	///  Return the track length of a node.
	float LengthOfNode(int nid) {return trackGraph->LengthOfNode(nid);}
	///  Returns the lowest numbered node id.
	int LowestNode() {return trackGraph->LowestNode();}
	///  Returns the highest numbered node id.
	int HighestNode() {return trackGraph->HighestNode();}
};


#endif // _PARSEFILE_H_
 
