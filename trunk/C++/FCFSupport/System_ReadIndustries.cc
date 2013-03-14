/* 
 * ------------------------------------------------------------------
 * System_ReadIndustries.cc - System::ReadIndustries
 * Created by Robert Heller on Sat Aug 27 20:16:02 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2005/11/04 20:22:14  heller
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

#include "config.h"
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
// Read industries from the SysFile
//
//============================================================================
bool System::ReadIndustries(char **outmessage)
{
	ifstream indusstream;
	int TotalIndustries,Gx;
	string line, trimline,buffer;
	vector<string> vlist;
	string vword;
	int val, Ix;
	char IndsType,IndsHazard;
	string IndsName,IndsDivList,IndsLoadTypes,IndsEmptyTypes;
	int IndsStation,IndsTrackLen,IndsAssignLen,IndsPriority,
	    /*IndsMirror,*/IndsClass,IndsPlate,IndsCarLen;
	bool IndsReload;
	map<int, int, less<int> > IndsMirrorMap;
	Station *IStation;
	indusstream.open(industriesFile.FullPath().c_str());
	if (!indusstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,_("Error opening industry file: %s"),
		    industriesFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}	    
	if (!ReadGroupLimit(indusstream,"INDUSTRIES",TotalIndustries,industriesFile.FullPath().c_str(),outmessage)) {return false;}
// Allocate memory for industries, and read in definitions
//
//   IndsType        type of location
//
//                      "Y"   Yard
//                      "S"   Stage
//                      "I"   Industry Online
//                      "O"   Industry Offline
//
//   IndsStation     station location of this yard or industry
//   IndsName        symbolic name (may be duplicated)
//   IndsTrackLen    physical track space available
//
//   IndsAssignLen   assignable length -- the combined length of all the cars
//                     destinated for an industry at one time - often larger
//                     than TrackLen
//
//   IndsPriority    priority of car assignment to this industry -- 1 is the
//                     highest priority, while MaxPriority is the lowest --
//                     this assures car supply to more important customers
//
//   IndsReload      "Y" means cars delivered as loads, may leave as loads --
//                     provided the industry accepts the car type as empty
//
//   IndsMirror      the identity of the industry that "mirrors" this one --
//                     a car delivered to this industry will be "relocated"
//                     immediately to the "mirror" location
//
//                     Typical mirrors: power plant --> coal mine (loads)
//                                      coal mine --> power plant (empties)
//
//   IndsPlate       maximum clearance plate of cars for this industry
//   IndsClass       maximum weight class of cars for this industry
//   IndsDivList     where this industry will ship its loads
//   IndsCarLen      maximum car length of cars for this industry
//   IndsLoadTypes   what CarTypes are accepted as loads
//   IndsEmptyTypes  what CarTypes are accepted as empties
	for (Gx = 1; Gx <= TotalIndustries; Gx++) {
	  sprintf(messageBuffer,_("Error reading %s -- short file (INDUSTRIES)!"),
	  			industriesFile.FullPath().c_str());
	  if (!SkipCommentsGets(indusstream,buffer,messageBuffer,outmessage)) {return false;}
	  line = trim(buffer);
//	  cerr << "*** System::ReadIndustries: line = '" << line << "'" << endl;
	  if (line == "-1") break;
	  vlist = split(line,',');
//	  cerr << "*** System::ReadIndustries: vlist.size() = " << vlist.size() << endl;
	  while (vlist.size() < 16) {
	    if (!SkipCommentsGets(indusstream,buffer,messageBuffer,outmessage)) {return false;}
//	    cerr << "*** System::ReadIndustries: trim(buffer) = '" << trim(buffer) << "'" << endl;
	    line = line + "," + trim(buffer);
	    /*line += ","+trim(buffer);*/
//	    cerr << "*** System::ReadIndustries: line = '" << line << "'" << endl;
	    vlist = split(line,',');
//	    cerr << "*** System::ReadIndustries: vlist.size() = " << vlist.size() << endl;
	  }
	  if (vlist.size() != 16) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,_("Error reading %1$s -- syntax error at %2$s file (INDUSTRIES)!"),
	  	      industriesFile.FullPath().c_str(),buffer.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  vword = trim(vlist[0]);
//	  cerr << "*** System::ReadIndustries: vword = '" << vword << "'" << endl;
	  sprintf(messageBuffer,"Industry number syntax or out of range in file (%s): %s",
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToIntRange(vword,Ix,0,TotalIndustries,messageBuffer,outmessage)) return false;
	  if (industries[Ix] != NULL) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,
			_("Error reading %1$s INDUSTRIES entry syntax error, duplicated industry number: %2$d!"),
					industriesFile.FullPath().c_str(),Ix);
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  vword = trim(vlist[1]);
	  IndsType = vword[0];
	  if (islower(IndsType)) {IndsType = toupper(IndsType);}
	  vword = trim(vlist[2]);
	  sprintf(messageBuffer,_("Industry station number syntax in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,IndsStation,messageBuffer,outmessage)) return false;
	  if (IndsStation == 0) continue;
	  else if (IndsStation == 1) IStation = NULL;
	  else {
	    if (stations.find(IndsStation) != stations.end()) IStation = stations[IndsStation];
	    else IStation = NULL;
	    if (IStation == NULL) {
	      if (outmessage != NULL) {
	        sprintf(messageBuffer,_("Industry station number out of range in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	        *outmessage = new char[strlen(messageBuffer)+1];
	        strcpy(*outmessage,messageBuffer);
	      }
	      return false;
	    }
	  }
	  IndsName =  trim(vlist[3]);
	  vword = trim(vlist[4]);
	  sprintf(messageBuffer,_("Industry track length syntax error in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,IndsTrackLen,messageBuffer,outmessage)) return false;vword = trim(vlist[2]);
	  vword = trim(vlist[5]);
	  sprintf(messageBuffer,_("Industry assignable track length syntax error in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,IndsAssignLen,messageBuffer,outmessage)) return false;vword = trim(vlist[2]);
	  vword = trim(vlist[6]);
	  sprintf(messageBuffer,_("Industry Priority syntax error in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,IndsPriority,messageBuffer,outmessage)) return false;vword = trim(vlist[2]);
	  vword = trim(vlist[7]);
	  if (vword[0] == 'Y' || vword[0] == 'y') IndsReload = true;
	  else if (vword[0] == 'N' || vword[0] == 'n') IndsReload = false;
	  else {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,_("Bad value for industry reload value: %1$s in %2$s"),
	      	      vword.c_str(), industriesFile.FullPath().c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  vword = trim(vlist[8]);
	  if (vword.size() > 0) IndsHazard = vword[0];
	  else IndsHazard = ' ';
	  vword = trim(vlist[9]);
	  sprintf(messageBuffer,_("Industry mirror number syntax in file (%1$s): %2$s at %3$s"),
		  industriesFile.FullPath().c_str(),vword.c_str(),line.c_str());
	  if (!StringToInt(vword,val,messageBuffer,outmessage)) return false;
	  if (val != 0) {IndsMirrorMap[Ix] = val;}
	  vword = trim(vlist[10]);
	  sprintf(messageBuffer,_("Industry plate number syntax in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,IndsPlate,messageBuffer,outmessage)) return false;
	  vword = trim(vlist[11]);
	  sprintf(messageBuffer,_("Industry weight class syntax in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,IndsClass,messageBuffer,outmessage)) return false;
	  IndsDivList = trim(vlist[12]);
	  vword = trim(vlist[13]);
	  sprintf(messageBuffer,_("Industry car length syntax in file (%1$s): %2$s"),
		  industriesFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,IndsCarLen,messageBuffer,outmessage)) return false;
	  IndsLoadTypes = trim(vlist[14]);
	  IndsEmptyTypes = trim(vlist[15]);
	  industries[Ix] = new Industry(IndsType,IStation,IndsName.c_str(),
					IndsTrackLen,IndsAssignLen,IndsPriority,
					IndsReload,IndsHazard,NULL,IndsPlate,
					IndsClass,IndsDivList.c_str(),
					IndsCarLen,IndsLoadTypes.c_str(),
					IndsEmptyTypes.c_str());
//	  cerr << "*** System::ReadIndustries: industries[" << Ix << "] = " << industries[Ix] << endl;
	  if (IStation != NULL) IStation->AppendIndustry(industries[Ix]);
	}
	for (map<int, int, less<int> >::const_iterator imirror = IndsMirrorMap.begin();
	     imirror != IndsMirrorMap.end();
	     imirror++) {
	  Ix = imirror->first;
	  val = imirror->second;
	  if (industries[val] == NULL) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,_("Bad industry mirror number for industry #%1$d syntax in file (%2$s): %3$d"),
		  Ix,industriesFile.FullPath().c_str(),val);
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  industries[Ix]->mirror = industries[val];
	}	     
	indusstream.close();
	return true;
}


const Industry *System::FindIndustryByName(string name) const
{
	IndustryMap::const_iterator Ix;
	const Industry *industry;

	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
		if ((industry = Ix->second) == NULL) continue;
		if (name == industry->name) return industry;
	}
	return NULL;
}

vector<int> System::SearchForIndustryPattern(string industryNamePattern) const
{
	IndustryMap::const_iterator Ix;
	const Industry *industry;
	vector<int> result;
	string industryName;

	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  if ((industry = Ix->second) == NULL) continue;
	  industryName = industry->name;
	  if (GlobStringMatch(industryName,industryNamePattern)) {
	    result.push_back(Ix->first);
	  }
	}
	return result;
}

}
