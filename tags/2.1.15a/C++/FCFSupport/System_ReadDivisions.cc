/* 
 * ------------------------------------------------------------------
 * System_ReadDivisions.cc - System::ReadStations
 * Created by Robert Heller on Sat Aug 27 20:11:50 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2005/11/04 20:00:57  heller
 * Modification History: Nov 4, 2005 lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:34  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
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

static char Id[] = "$Id$";

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <System.h>
#include <PathName.h>
#include <limits.h>
#include <ctype.h>

//============================================================================
//
// Read divisions from the SysFile
//
//============================================================================
bool System::ReadDivisions(istream &stream,map<int,int,less<int> > &homemap,char **outmessage)
{
	string line,trimline;
	int Gx;
	vector<string> vlist;
	string vword;
	int val,Dx;
	int TotalDivisions;

	if (!ReadGroupLimit(stream,"DIVISIONS",TotalDivisions,systemFile.FullPath().c_str(),outmessage)) {return false;}
// Allocate memory for divisions, and read in definitions
//
//    Basically, a division has a numeric identifier, a symbolic name, and
//    a "home" -- which can be a YARD or an INDUSTRY.
//
//    The purpose of a division is that cars destined for industries are
//    routed --> to the industry's station --> to the station's division
//    --> to the division's home. It's just a way of clumping industries
//    together into a logical unit.
//
//    #          Numeric identifier
//    Symbol     Symbolic alphanumeric identifier (A-Z a-z 0-9)
//    Home       Numeric Home yard of the division
//    Area       Symbolic alphanumeric Area identifier
//    Name       Text name of the division
	if (TotalDivisions < 1) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,
				"Bad value (%d) for DIVISIONS in %s!",
				TotalDivisions,systemFile.FullPath().c_str());
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		return false;
	}
#ifdef DEBUG
	cerr << "*** System::ReadDivisions: TotalDivisions = " << TotalDivisions << endl;
#endif
	for (Gx = 1; Gx <= TotalDivisions; Gx++) {
		sprintf(messageBuffer,
			"Error reading %s -- short file (DIVISIONS)!",
			systemFile.FullPath().c_str());
		if (!SkipCommentsGets(stream,line,messageBuffer,outmessage)) {
			return false;
		}
#ifdef DEBUG
		cerr << "*** System::ReadDivisions: i = " << i << ", line = '" << line << "'" << endl;
#endif
		trimline = trim(line);
#ifdef DEBUG
		cerr << "*** System::ReadDivisions: trimline = '" << trimline << "'" << endl;
#endif
		if (trimline == "-1") break;
		vlist = split(trimline,',');
#ifdef DEBUG
		cerr << "*** System::ReadDivisions: vlist.size() = " << vlist.size() << endl;
		for (int iv = 0; iv < vlist.size(); iv++) {
			cerr << "*** System::System: vlist[" << iv << "] = '" << vlist[iv] << "'" << endl;
		}
#endif
		if (vlist.size() != 5) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,
					"Error reading %s DIVISIONS entry syntax error, expected 5 values, got \"%s\"!",
					systemFile.FullPath().c_str(),trimline.c_str());
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			return false;
		}
		vword = trim(vlist[0]);
		sprintf(messageBuffer,"Error reading %s DIVISIONS entry syntax error, expected division number, got \"%s\"!",
					systemFile.FullPath().c_str(),vword.c_str());
		if (!StringToIntRange(vword,Dx,1,TotalDivisions,messageBuffer,outmessage)) return false;
		if (divisions[Dx] != NULL) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,
					"Error reading %s DIVISIONS entry syntax error, duplicated division number: %d!",
					systemFile.FullPath().c_str(),val);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			return false;
		}
		vword = trim(vlist[2]);
		sprintf(messageBuffer,"Error reading %s DIVISIONS entry syntax error, expected home station number, got \"%s\"!",
					systemFile.FullPath().c_str(),vword.c_str());
		if (!StringToInt(vword,val,messageBuffer,outmessage)) return false;
		divisions[Dx] = new Division(trim(vlist[1])[0],NULL,
					     trim(vlist[3])[0],
					     trim(vlist[4]).c_str());
		homemap[Dx] = val;
#ifdef DEBUG
		cerr << "*** System::ReadDivisions: divisions[" << Dx << "] = " << divisions[Dx] << endl;
		cerr << "*** System::ReadDivisions: i = " << i << endl;
#endif
	}
	return true;
}

const Division *System::FindDivisionBySymbol(char symbol) const
{
	DivisionMap::const_iterator Dx;
	const Division *division;

	for (Dx = divisions.begin(); Dx != divisions.end(); Dx++) {
		if ((division = Dx->second) == NULL) continue;
		if (division->Symbol() == symbol) return division;
	}
	return NULL;	
}
