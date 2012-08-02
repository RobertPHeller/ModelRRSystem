/* 
 * ------------------------------------------------------------------
 * System_LoadStats.cc - System::LoadStatsFile
 * Created by Robert Heller on Sat Aug 27 21:30:01 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/10/15 19:56:33  heller
 * Modification History: variois vixes
 * Modification History:
 * Modification History: Revision 1.2  2006/02/26 23:09:23  heller
 * Modification History: Lockdown for machine xfer
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


namespace FCFSupport {

//============================================================================
//
// Read industry data from the Stats file
//
//============================================================================
bool System::LoadStatsFile(char **outmessage)
{
	int Gx,Ix,cn,cl,sl;
	IndustryMap::iterator IIx;
	ifstream statsfilestream;
	string line,Ixword,cnword,clword,slword;
	bool newformat = false;
	
	statsfilestream.open(statsFile.FullPath().c_str());
	if (!statsfilestream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not open stats file (read) %s",
	    	    statsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  statsPeriod = 1;
	  return false;
	}
	if (!getline(statsfilestream,line)) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not read stats file (Stats Period) %s",
	    	    statsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  statsPeriod = 1;
	  return false;
	}
	if (line.find(',') != string::npos) {
	  newformat = true;
	  line = line.substr(0,line.find(','));
#ifdef DEBUG
          cerr << "*** LoadStats: line = '" << line << "'" << endl;
#endif
	} else {
	  newformat = false;
	}
	sprintf(messageBuffer,"Number syntax error (Stats Period) in %s at %s",
		statsFile.FullPath().c_str(),line.c_str());
	if (!StringToInt(trim(line),statsPeriod,messageBuffer,outmessage)) return false;
	if (statsPeriod <= 0) statsPeriod = 1;
	Gx = 0;
	while (getline(statsfilestream,line)) {
	  Gx++;
	  if (newformat) {
	    vector<string> vlist = split(line,',');
	    Ixword = vlist[0];
	    cnword = vlist[1];
	    clword = vlist[2];
	    slword = vlist[3];
	  } else {
	    Ixword = line.substr(0,4);
	    cnword = line.substr(4,3);
	    clword = line.substr(7,3);
	    slword = line.substr(10,6);
	  }
	  sprintf(messageBuffer,"Syntax error in stats file (%s) at %s (%s)",
		  statsFile.FullPath().c_str(),line.c_str(),Ixword.c_str());
	  if (!StringToInt(trim(Ixword),Ix,messageBuffer,outmessage)) return(false);
	  sprintf(messageBuffer,"Syntax error in stats file (%s) at %s (%s)",
		  statsFile.FullPath().c_str(),line.c_str(),cnword.c_str());
	  if (!StringToInt(trim(cnword),cn,messageBuffer,outmessage)) return(false);
	  sprintf(messageBuffer,"Syntax error in stats file (%s) at %s (%s)",
		  statsFile.FullPath().c_str(),line.c_str(),clword.c_str());
	  if (!StringToInt(trim(clword),cl,messageBuffer,outmessage)) return(false);
	  sprintf(messageBuffer,"Syntax error in stats file (%s) at %s (%s)",
		  statsFile.FullPath().c_str(),line.c_str(),slword.c_str());
	  if (!StringToInt(trim(slword),sl,messageBuffer,outmessage)) return(false);
#ifdef DEBUG
	  cerr << "*** System::LoadStatsFile: line = '" << line << "', Ix = " << Ix << ", cn = " << cn << ", cl = " << cl << ", sl = " << sl << endl;
#endif
	  Gx++;
	  if (FindIndustryByIndex(Ix) == NULL) continue;
	  industries[Ix]->carsNum = cn;
	  industries[Ix]->carsLen = cl;
	  industries[Ix]->statsLen = sl;
	}
	statsfilestream.close();
	for (IIx = industries.begin(); IIx != industries.end(); IIx++) {
	  if (IIx->second == NULL) continue;
	  if (statsPeriod == 1) {
	    (IIx->second)->carsNum = 0;
	    (IIx->second)->carsLen = 0;
	    (IIx->second)->statsLen = 0;
	  }
#ifdef DEBUG
	  cerr << "*** System::LoadStatsFile: IIx->first = " << IIx->first << endl;
#endif
	  (IIx->second)->IncrementStatsLen((IIx->second)->TrackLen());
	}
	return true;
}


void System::ResetIndustryStats()
{
	IndustryMap::iterator Ix;
	Industry *ix;

	statsPeriod = 1;

	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  if ((Ix->second) == NULL) continue;
	  ix = Ix->second;
	  ix->carsNum = 0;
	  ix->carsLen = 0;
	  ix->statsLen = ix->TrackLen();
	}	
}

}
