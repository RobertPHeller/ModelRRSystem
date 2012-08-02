/* 
 * ------------------------------------------------------------------
 * System_ReadStations.cc - System::ReadStations
 * Created by Robert Heller on Sat Aug 27 20:12:48 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/10/22 21:10:05  heller
 * Modification History: 10221007
 * Modification History:
 * Modification History: Revision 1.2  2005/11/04 20:18:45  heller
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
#include "../gettext.h"

namespace FCFSupport {

//============================================================================
//
// Read stations from the SysFile
//
//============================================================================
bool System::ReadStations(istream &stream,char **outmessage)
{
	string line,trimline;
	int Gx;
	vector<string> vlist;
	string vword;
	int val /*,Dx*/, Sx;
	int TotalStations;
	Division *D;

	if (!ReadGroupLimit(stream,"STATIONS",TotalStations,systemFile.FullPath().c_str(),outmessage)) {return false;}
// Allocate memory for stations, and read in definitions
//
//    Basically, a station has a symbolic name, and is based in a "division".
//    This means that freight cars destined for an industry at this station
//    are usually routed to the "division yard" (see below) first. Then the
//    wayfreight (or boxmove) takes the car from the yard to the station and
//    then to the industry.
//
//    Note you are free to create several "stations" with the same name, and
//    yet with different "divisions". The purpose of this flexibility is to
//    allow you to serve industries on your layout in a flexible manner - so
//    the same physical "layout station" may be represented by several of the
//    "logical stations" in the database.
//
//    Another trick is to define "trailing point" sidings in one direction as
//    one station, and then trailing point sidings in the opposite direction
//    as another station (with the same name, I mean). Then an "out and back"
//    wayfreight can then be set up to serve only trailing point sidings, as
//    it travels out, turns, and returns thru the same area.
	if (TotalStations < 1) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,
				_("Bad value (%1$d) for STATIONS in %2$s!"),
				TotalStations,systemFile.FullPath().c_str());
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		return false;
	}
	for (Gx = 1; Gx <= TotalStations; Gx++) {
		sprintf(messageBuffer,
			_("Error reading %s -- short file (STATIONS)!"),
			systemFile.FullPath().c_str());
		if (!SkipCommentsGets(stream,line,messageBuffer,outmessage)) {
			return false;
		}
#ifdef DEBUG
		cerr << "*** System::ReadStations: i = " << i << ", line = '" << line << "'" << endl;
#endif
		trimline = trim(line);
#ifdef DEBUG
		cerr << "*** System::ReadStations: trimline = '" << trimline << "'" << endl;
#endif
		if (trimline == "-1") break;
		vlist = split(trimline,',');
#ifdef DEBUG
		cerr << "*** System::ReadStations: vlist.size() = " << vlist.size() << endl;
		for (int iv = 0; iv < vlist.size(); iv++) {
			cerr << "*** System::System: vlist[" << iv << "] = '" << vlist[iv] << "'" << endl;
		}
#endif
		if (vlist.size() != 4) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,
					_("Error reading %1$s STATIONS entry syntax error, expected 4 values, got '%2$s'!"),
					systemFile.FullPath().c_str(),trimline.c_str());
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			return false;
		}
		vword = trim(vlist[0]);
		sprintf(messageBuffer,_("Error reading %1$s STATIONS entry syntax error or station number out of range, expected station number from 2 to %2$d, got '%3$s'!"),
					systemFile.FullPath().c_str(),TotalStations,vword.c_str());
		/* Minimum actual station number changed to 2 -- station #1 is reserved! (Bug #2) */
		if (!StringToIntRange(vword,Sx,2,TotalStations,messageBuffer,outmessage)) return false;
		if (stations[Sx] != NULL) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,
					_("Error reading %1$s STATIONS entry syntax error, duplicated station number: %2$d in line '%3$s'!"),
					systemFile.FullPath().c_str(),Sx,line.c_str());
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			return false;
		}
		vword = trim(vlist[2]);
		sprintf(messageBuffer,_("Error reading %1$s STATIONS entry syntax error, expected Division number, got '%2$s'!"),
					systemFile.FullPath().c_str(),vword.c_str());
		if (!StringToInt(vword,val,messageBuffer,outmessage)) return false;
		if (val == 0) continue;
		else {
			if (divisions.find(val) != divisions.end()) D = divisions[val];
			else D = NULL;
			if (D == NULL) {
				if (outmessage != NULL) {
					sprintf(messageBuffer,
						_("Bad Division number for Station #%1$d (%2$s): %3$d!"),
						Sx,vlist[1].c_str(),val);
					*outmessage = new char[strlen(messageBuffer)+1];
					strcpy(*outmessage,messageBuffer);
				}
				return false;
			}
		}
		stations[Sx] = new Station(trim(vlist[1]).c_str(),D,trim(vlist[3]).c_str());
		if (D != NULL) D->AppendStation(stations[Sx]);
	}
	return true;
}


const Station *System::FindStationByName(string name,string comment) const
{
	StationMap::const_iterator Sx;
	const Station *station;

	for (Sx = stations.begin(); Sx != stations.end(); Sx++) {
		if ((station = Sx->second) == NULL) continue;
		if (name == station->Name()) {
		    if (comment == "") return station;
		    else if (comment == station->Comment()) return station;
		}
	}
	return NULL;
}
        
}
