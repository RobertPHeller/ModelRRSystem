/* 
 * ------------------------------------------------------------------
 * ParseFile.cc - File parsing classes
 * Created by Robert Heller on Mon Sep  4 00:57:47 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.4  2006/05/18 17:03:24  heller
 * Modification History: CentOS 4.3 updates
 * Modification History:
 * Modification History: Revision 1.3  2004/06/26 14:03:52  heller
 * Modification History: Remove unused header reference
 * Modification History:
 * Modification History: Revision 1.2  2002/09/24 04:20:18  heller
 * Modification History: MRRXtrkCad => TrackGraph
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.5  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.4  1995/09/17 21:04:43  heller
 * Modification History: Add in checkword option
 * Modification History:
 * Revision 2.3  1995/09/12  02:45:05  heller
 * Add in ClassFile and MRRClassFile code
 *
 * Revision 2.2  1995/09/09  22:57:32  heller
 * Add in Tcl code for ParseFile and MRRLayoutFile
 * Add in output method
 * Add in ProcessFile() member code
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

static char rcsid[] = "$Id: ParseFile.cc 483 2007-04-19 17:23:25Z heller $";

#include <ParseFile.h>
#include <TrackGraph.h>
//#include <MRRSigExpr.tab.h>
#include <MRRXtrkCad.tab.h>
#include <sstream>
#include <fstream>

/************************************************************************
 *									*
 * Constructor: save parser pointer and allocate an empty track graph	*
 *									*
 ************************************************************************/

LayoutFile::LayoutFile (const char * filename,MRRXtrkCad* p) : ParseFile(filename)
{
	parser = p;
	trackGraph = new TrackGraph;
}

/************************************************************************
 *									*
 * Destructor: delete the track graph structure.			*
 *									*
 ************************************************************************/

LayoutFile::~LayoutFile()
{
	delete trackGraph;
}

/************************************************************************
 *									*
 * Process the layout file.  The source file is opened and parsed.	*
 *									*
 ************************************************************************/

int ParseFile::ProcessFile(ostream& err)
{
	errorstream = &err;
	source_line = 0;
        if (source_file == NULL)
        {
		ParseError("NULL source file!");
        	return(1);
        }
	fp = fopen(source_file,"r");
	if (fp == NULL)
	{
		ParseError("could not open file");
		return(1);
	}
	int status = Parse();
	fclose(fp);
	return(status);
}


/************************************************************************
 *									*
 * Parse the file.  This method just calls the parser's yyparse() method*
 *									*
 ************************************************************************/

int LayoutFile::Parse() {return parser->yyparse();}

/************************************************************************
 *									*
 * Handle parse errors.  Just calls the parser's yyerror() method.	*
 *									*
 ************************************************************************/

void LayoutFile::ParseError(const char *m) {parser->yyerror((char *)m);}

/************************************************************************
 *									*
 * This method just writes the graph to the specified output stream.	*
 *									*
 ************************************************************************/

void LayoutFile::Emit(ostream& stream)
{
	stream << *trackGraph;
}


