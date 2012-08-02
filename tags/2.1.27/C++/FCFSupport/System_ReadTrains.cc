/* 
 * ------------------------------------------------------------------
 * System_ReadTrains.cc - System::ReadTrains
 * Created by Robert Heller on Sat Aug 27 20:15:06 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2006/02/26 23:09:23  heller
 * Modification History: Lockdown for machine xfer
 * Modification History:
 * Modification History: Revision 1.2  2005/11/04 20:19:45  heller
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

namespace FCFSupport {

//============================================================================
//
// Read trains from the SysFile
//
//============================================================================

bool System::ReadTrains(char **outmessage)
{
	ifstream trainstream;
	int TotalTrains,Gx;
	string line, trimline,buffer;
	vector<string> vlist;
	string vword;
	int /*val,*/ Tx;
	char TrnType;
	int  TrnShift, TrnMxCars, TrnOnDuty, TrnOnDutyH, TrnOnDutyM,
		TrnMxClear, TrnMxWeigh, TrnMxLen, TrnStop;
	bool TrnDone, TrnPrint;
	string TrnName, TrnDivList, TrnCarTypes, TrnDescr;
	vector<string> TrnStops;	
	
	trainstream.open(trainsFile.FullPath().c_str());
	if (!trainstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Error opening train file: %s",
		    trainsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}	    
	if (!ReadGroupLimit(trainstream,"TRAINS",TotalTrains,trainsFile.FullPath().c_str(),outmessage)) {return false;}
// Allocate memory for trains, and read in definitions
//
//    TrnType        "M"anifest "W"ayfreight "P"assenger "B"oxmove
//    TrnShift       shift number 1 or 2 or 3
//    TrnDone        "N" means cars "Car Done" is not set by move in train
//    TrnName$       symbolic name of the train
//    TrnMxCars      maximum number of cars in the train at once
//    TrnDivList$    "forwarding list" of divisions (MANIFESTS)
//    TrnStops       stops (industries, or stations)
//    TrnOnDuty      scheduled time of start
//    TrnPrint()     "P" means print the train order, else not
//    TrnMxClear     maximum clearance plate of cars in this train
//    TrnMxWeigh     maximum weight class of cars in this train
//    TrnCarTypes$   which car types are allowed in the train
//    TrnMxLen       maximum length of the train in feet
//    TrnDesc$       one line text description for train orders printout

	for (Gx = 1;Gx <= TotalTrains;Gx++) {
	  sprintf(messageBuffer,"Error reading %s -- short file (TRAINS)!",
	  			trainsFile.FullPath().c_str());
	  if (!SkipCommentsGets(trainstream,buffer,messageBuffer,outmessage)) {return false;}
	  line = trim(buffer);
	  if (line == "-1") break;
	  vlist = split(line,',');
	  while (vlist.size() < 16) {
	    if (!SkipCommentsGets(trainstream,buffer,messageBuffer,outmessage)) {return false;}
	    line = line + "," + trim(buffer);
	    vlist = split(line,',');
	  }
	  if (vlist.size() != 16) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Syntax error in trains file (%s) at %s",
	      		trainsFile.FullPath().c_str(),buffer.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  vword = trim(vlist[0]);
	  sprintf(messageBuffer,"Bad train number in trains file (%s): %s",
	      		trainsFile.FullPath().c_str(),vword.c_str());
	  if (!StringToIntRange(vword,Tx,1,TotalTrains,messageBuffer,outmessage)) return false;
	  if (trains[Tx] != NULL) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,
			"Error reading %s TRAINS entry syntax error, duplicated train number: %d!",
					trainsFile.FullPath().c_str(),Tx);
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  TrnType = vlist[1][0];
	  vword = trim(vlist[2]);
	  sprintf(messageBuffer,"Bad shift number in trains file (%s): %s",
	      		trainsFile.FullPath().c_str(),vword.c_str());
	  if (!StringToIntRange(vword,TrnShift,1,3,messageBuffer,outmessage)) return false;
	  vword = trim(vlist[3]);
	  if (vword[0] == 'Y' || vword[0] == 'y') TrnDone = true;
	  else if (vword[0] == 'N' || vword[0] == 'n') TrnDone = false;
	  else {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Bad done flag (not Y or N) in trains file (%s): %s",
	      		trainsFile.FullPath().c_str(),vword.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  TrnName = trim(vlist[4]);
	  vword = trim(vlist[5]);
	  sprintf(messageBuffer,"Bad train max cars in trains file (%s): %s at %s",
		  trainsFile.FullPath().c_str(),vword.c_str(),line.c_str());
	  if (!StringToIntRange(vword,TrnMxCars,0,INT_MAX,messageBuffer,outmessage)) return false;
	  TrnDivList = trim(vlist[6]);
	  TrnStops   = split(trim(vlist[7]),' ');
	  vword = trim(vlist[9]).substr(0,2);
	  sprintf(messageBuffer,"Bad train on duty hour value in trains file (%s): %s",
		  trainsFile.FullPath().c_str(),vlist[9].c_str());
	  if (!StringToIntRange(vword,TrnOnDutyH,0,23,messageBuffer,outmessage)) return false;
	  vword = trim(vlist[9]).substr(2,2);
	  sprintf(messageBuffer,"Bad train on duty minute value in trains file (%s): %s",
		  trainsFile.FullPath().c_str(),vlist[9].c_str());
	  if (!StringToIntRange(vword,TrnOnDutyM,0,59,messageBuffer,outmessage)) return false;
	  TrnOnDuty = 60 * TrnOnDutyH + TrnOnDutyM;
	  vword = trim(vlist[10]);
	  if (vword[0] == 'P' || vword[0] == 'p') TrnPrint = true;
	  else if (vword[0] == 'N' || vword[0] == 'n') TrnPrint = false;
	  else {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Bad print flag (not P or N) in trains file (%s): %s",
	      		trainsFile.FullPath().c_str(),vword.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  vword = trim(vlist[11]);
	  sprintf(messageBuffer,"Bad train max clearence in trains file (%s): %s",
	      		trainsFile.FullPath().c_str(),vword.c_str());
	  if (!StringToInt(vword,TrnMxClear,messageBuffer,outmessage)) return false;
	  vword = trim(vlist[12]);
	  sprintf(messageBuffer,"Bad train max weight in trains file (%s): %s",
		  trainsFile.FullPath().c_str(),vword.c_str());
	  if (!StringToIntRange(vword,TrnMxWeigh,1,INT_MAX,messageBuffer,outmessage)) return false;
	  TrnCarTypes = trim(vlist[13]);
	  vword = trim(vlist[14]);
	  sprintf(messageBuffer,"Bad train max length in trains file (%s): %s",
		  trainsFile.FullPath().c_str(),vword.c_str());
	  if (!StringToIntRange(vword,TrnMxLen,1,INT_MAX,messageBuffer,outmessage)) return false;
	  TrnDescr = trim(vlist[15]);
	  trains[Tx] = new Train(TrnName.c_str(),TrnDivList.c_str(),
				 TrnCarTypes.c_str(),TrnDescr.c_str(),TrnShift,
				 TrnMxCars,TrnMxClear,TrnMxWeigh,TrnMxLen,
				 TrnOnDuty,TrnPrint,TrnDone,(Train::TrainType)TrnType);
	  trainIndex[TrnName] = trains[Tx];
	  for (unsigned int Sx = 0; Sx < TrnStops.size(); Sx++) {
	    vword = trim(TrnStops[Sx]);
	    sprintf(messageBuffer,"Bad train stop number in trains file (%s): %s",
		    trainsFile.FullPath().c_str(),vword.c_str());
	    if (!StringToInt(vword,TrnStop,messageBuffer,outmessage)) return false;
	    if (TrnStop == 0) break;
	    Train::StationOrIndustry theStop;
	    switch (trains[Tx]->Type()) {
	    	case Train::Manifest:
	    		if (FindIndustryByIndex(TrnStop) == NULL) {
	    			if (outmessage != NULL) {
	    			  sprintf(messageBuffer,"Bad industry number in trains file (%s): %s (%d) in %s",
	    			  	  trainsFile.FullPath().c_str(),vword.c_str(),TrnStop,line.c_str());
	    			  *outmessage = new char[strlen(messageBuffer)+1];
	    			  strcpy(*outmessage,messageBuffer);
	    			}
	    			return false;
	    		} else {
	    			theStop.industry = industries[TrnStop];
	    		}
			break;
	    	default:
	    		theStop.station = stations[TrnStop];
	    }
	    (trains[Tx])->stops.push_back(theStop);
	  }	  
	}	
	trainstream.close();
	return true;
}


}
