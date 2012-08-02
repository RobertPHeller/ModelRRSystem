/* 
 * ------------------------------------------------------------------
 * ParseFile.h - File Parsing Super classes
 * Created by Robert Heller on Sun Aug  6 15:25:25 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
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

#include <iostream.h>
#include <string.h>
#include <stdio.h>
#include <Tree.h>

class MRRXtrkCad;

class ParseFile {
protected:
	char *lp;
	FILE *fp;
	int   source_line;
	static const int buffersize = 1024;
	char  line_buffer[buffersize];
	ostream *errorstream;
	virtual int Parse() = 0;
	virtual void ParseError(const char *) = 0;
	char * source_file;
public:
	const char * SourceFile() const {return source_file;}
	ParseFile(const char * filename)
		{source_file = new char[strlen(filename)+1];
		 strcpy(source_file,filename);
		 fp = NULL;source_line = 0;lp = NULL;
		 }
	virtual ~ParseFile() {delete source_file;}
	int ProcessFile(ostream &err);
};

class LayoutFile : public ParseFile {
protected:
	MRRXtrkCad* parser;
	virtual int Parse();
	virtual void ParseError(const char *m);
	double MinX,MaxX,MinY,MaxY;
	TreeTable *trees;
public:
	LayoutFile (const char * filename,MRRXtrkCad* p);
	virtual ~LayoutFile();
	void Emit(ostream& outstream);
};


#endif // _PARSEFILE_H_
 
