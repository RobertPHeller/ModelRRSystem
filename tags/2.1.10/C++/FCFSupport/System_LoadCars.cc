/* 
 * ------------------------------------------------------------------
 * System_LoadCars.cc - System::LoadCarFile and System::SaveCars
 * Created by Robert Heller on Sat Aug 27 21:29:40 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.8  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.7  2007/01/08 22:26:38  heller
 * Modification History: Win32 Build Issues
 * Modification History:
 * Modification History: Revision 1.5  2006/05/18 17:03:24  heller
 * Modification History: CentOS 4.3 updates
 * Modification History:
 * Modification History: Revision 1.4  2006/02/26 23:09:23  heller
 * Modification History: Lockdown for machine xfer
 * Modification History:
 * Modification History: Revision 1.3  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 05:52:08  heller
 * Modification History: Upgraded for G++ 3.2
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
#include <errno.h>
#include <unistd.h>

#if !HAVE_MKSTEMP
extern "C" int mkstemp(char *);
#endif
       
#if __GNUC__ >= 3
#include <ext/stdio_filebuf.h>
using namespace __gnu_cxx;
typedef stdio_filebuf<char> char_filebuf;
#endif


//============================================================================
//
// Read (and optionally reload) cars from the CarsFile
//
//============================================================================
bool System::LoadCarFile(char **outmessage)
{
	ifstream carsstream;
	int Cx, Gx;
	char CrsType;
	string CrsRR, CrsNum, CrsDivList, line, vword;
	int CrsLen, CrsPlate, CrsClass, CrsLtWt, CrsLdLmt, CrsMoves, CrsTrips,
	    CrsAssigns, val, totalCars;
	bool CrsStatus, CrsOkToMirror, CrsFixedRoute, CrsDone;
	const Owner *CrsOwner;
	vector<string> vlist;
	Car *newCar;
	CarVector::iterator Cxx;
	const Train *CrsTrain;
	Industry *CrsLoc, *CrsDest;
	
	carsstream.open(carsFile.FullPath().c_str());
	if (!carsstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Error opening %s for input (CARS)!",
	    	    carsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	sprintf(messageBuffer,"Read error -- short file %s (missing Session Number)",
		carsFile.FullPath().c_str());
	if (!SkipCommentsGets(carsstream,line,messageBuffer,outmessage)) return false;
	sprintf(messageBuffer,"Number syntax or range error in %s at %s: Session Number",
		carsFile.FullPath().c_str(),line.c_str());
	if (!StringToIntRange(trim(line),sessionNumber,0,INT_MAX,messageBuffer,outmessage)) return false;
	sprintf(messageBuffer,"Read error -- short file %s (missing Shift Number)",
		carsFile.FullPath().c_str());
	if (!SkipCommentsGets(carsstream,line,messageBuffer,outmessage)) return false;
	sprintf(messageBuffer,"Number syntax or range error in %s at %s: Shift Number",
		carsFile.FullPath().c_str(),line.c_str());
	if (!StringToIntRange(trim(line),shiftNumber,1,INT_MAX,messageBuffer,outmessage)) return false;
	sprintf(messageBuffer,"Read error -- short file %s (missing Total Car Count)",
		carsFile.FullPath().c_str());
	if (!SkipCommentsGets(carsstream,line,messageBuffer,outmessage)) return false;
	sprintf(messageBuffer,"Number syntax or range error in %s at %s: Total Car Count",
		carsFile.FullPath().c_str(),line.c_str());
	if (!StringToIntRange(trim(line),totalCars,1,INT_MAX,messageBuffer,outmessage)) return false;
	totalShifts = sessionNumber * 3;
	NextShift();
	sessionNumber += shiftNumber;
// Allocate memory for cars, and read in definitions
//
//   CrsType        car type from TypesFile
//   CrsRR          railroad reporting mark symbols or lessor/lessee string
//   CrsNum         car number or car number/units -- a string not a number
//   CrsDivList     division assignment list for empty -- or no restriction
//   CrsLen         extreme car (or multi-car) length over couplers
//   CrsPlate       clearance plate -- see PLATE.TXT file
//   CrsClass       car weight class -- see WEIGHT.TXT file
//   CrsLtWt        car light weight in tons
//   CrsLdLmt       car load limit in tons
//   CrsStatus      loaded or empty status is "L" or "E"
//   CrsOkToMirror  Y means car may be mirrored
//   CrsFixedRoute  Y means car can only be routed to home divisions
//   CrsOwner       car owner's initials -- see OWNERS.TXT
//   CrsDone        car is done moving -- receives TrnDone value
//   CrsTrain       last train to move this car
//   CrsMoves       number of times car was moved this session
//   CrsLoc         car's current location
//   CrsDest        car's destination
//   CrsTrips       number of moves for this car
//   CrsAssigns     number of assignments for this car
//
//   CrsPeek        temporary look-ahead array for car handling
//   CrsTmpStatus   status during assignment
//
//   SwitchListPickCar   which car was picked up
//   SwitchListPickLoc   where was car when picked up
//   SwitchListPickTrain which train picked up car
//   SwitchListLastTrain last train that picked up this car
//   SwitchListDropStop  which location car shall be dropped
	DeleteAllExistingCars();
	Cx = 0;
	while (SkipCommentsGets(carsstream,line,"",NULL)) {
	  Cx++;
	  vlist = split(trim(line),',');
	  if (vlist.size() != 20) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Syntax error in cars file (%s) at %s",
		      carsFile.FullPath().c_str(),line.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  CrsType = vlist[0][0];
	  CrsRR   = trim(vlist[1]);
	  CrsNum  = trim(vlist[2]);
	  CrsDivList = trim(vlist[3]);
	  // ints
	  sprintf(messageBuffer,"Number syntax or range error in %s at %s: Car Length (%s)",
	  	  carsFile.FullPath().c_str(),line.c_str(),vlist[4].c_str());
	  if (!StringToIntRange(trim(vlist[4]),CrsLen,1,INT_MAX,messageBuffer,outmessage)) return false;
	  sprintf(messageBuffer,"Number syntax in %s at %s: Car Plate (%s)",
	  	  carsFile.FullPath().c_str(),line.c_str(),vlist[5].c_str());
	  if (!StringToInt(trim(vlist[5]),CrsPlate,messageBuffer,outmessage)) return false;
	  sprintf(messageBuffer,"Number syntax in %s at %s: Car Weight Class (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[6].c_str());
	  if (!StringToInt(trim(vlist[6]),CrsClass,messageBuffer,outmessage)) return false;
	  sprintf(messageBuffer,"Number syntax in %s at %s: Car Light Weight (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[7].c_str());
	  if (!StringToInt(trim(vlist[7]),CrsLtWt,messageBuffer,outmessage)) return false;
	  sprintf(messageBuffer,"Number syntax in %s at %s: Car Load Limit (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[8].c_str());
	  if (!StringToInt(trim(vlist[8]),CrsLdLmt,messageBuffer,outmessage)) return false;
	  // bools
	  if (vlist[9][0] == 'L' || vlist[9][0] == 'l') {
	    CrsStatus = true;
	  } else if (vlist[9][0] == 'E' || vlist[9][0] == 'e') {
	    CrsStatus = false;
	  } else {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Expected L or E in %s at %s for load status (%s)",
	      	      carsFile.FullPath().c_str(),line.c_str(),vlist[9].c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  if (vlist[10][0] == 'Y' || vlist[10][0] == 'y') {
	    CrsOkToMirror = true;
	  } else if (vlist[10][0] == 'N' || vlist[10][0] == 'n') {
	    CrsOkToMirror = false;
	  } else {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Expected Y or N in %s at %s for ok to mirror? (%s)",
	      	      carsFile.FullPath().c_str(),line.c_str(),vlist[10].c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  if (vlist[11][0] == 'Y' || vlist[11][0] == 'y') {
	    CrsFixedRoute = true;
	  } else if (vlist[11][0] == 'N' || vlist[11][0] == 'n') {
	    CrsFixedRoute = false;
	  } else {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Expected Y or N in %s at %s for fixed route? (%s)",
	      	      carsFile.FullPath().c_str(),line.c_str(),vlist[11].c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  // Owner *
	  vword = trim(vlist[12]);
	  if (owners.find(vword) == owners.end()) {
	    owners[vword] = new Owner(vword.c_str(),vword.c_str(),"");
	  }
	  CrsOwner = owners[vword];
	  // bool
	  if (vlist[13][0] == 'Y' || vlist[13][0] == 'y') {
	    CrsDone = true;
	  } else if (vlist[13][0] == 'N' || vlist[13][0] == 'n') {
	    CrsDone = false;
	  } else {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Expected Y or N in %s at %s for done? (%s)",
	      	      carsFile.FullPath().c_str(),line.c_str(),vlist[11].c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  // Train * (from int)
	  sprintf(messageBuffer,"Number syntax in %s at %s: last train (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[14].c_str());
	  if (!StringToInt(trim(vlist[14]),val,messageBuffer,outmessage)) return false;
	  CrsTrain = trains[val];
	  // int
	  sprintf(messageBuffer,"Number syntax in %s at %s: moves (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[15].c_str());
	  if (!StringToInt(trim(vlist[15]),CrsMoves,messageBuffer,outmessage)) return false;
	  // Industry *s (from int)
	  sprintf(messageBuffer,"Number syntax in %s at %s: location (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[16].c_str());
	  if (!StringToInt(trim(vlist[16]),val,messageBuffer,outmessage)) return false;
#ifdef DEBUG
	  cerr << "*** System::LoadCarFile: (location) val = " << val << endl;
#endif
	  if (val < 0) val = 0;
	  if (FindIndustryByIndex(val) == NULL) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Bad location industry number in in %s at %s: %d",
	      	      carsFile.FullPath().c_str(),line.c_str(),val);
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  CrsLoc = industries[val];
	  sprintf(messageBuffer,"Number syntax in %s at %s: destination (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[17].c_str());
	  if (!StringToInt(trim(vlist[17]),val,messageBuffer,outmessage)) return false;
#ifdef DEBUG
	  cerr << "*** System::LoadCarFile: (destination) val = " << val << endl;
#endif
	  if (val < 0) val = 0;
	  if (FindIndustryByIndex(val) == NULL) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,"Bad destination industry number in in %s at %s: %d",
	      	      carsFile.FullPath().c_str(),line.c_str(),val);
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  CrsDest = industries[val];
	  // Ints
	  sprintf(messageBuffer,"Number syntax in %s at %s: trips (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[18].c_str());
	  if (!StringToInt(trim(vlist[18]),CrsTrips,messageBuffer,outmessage)) return false;
	  sprintf(messageBuffer,"Number syntax in %s at %s: assigments (%s)",
		  carsFile.FullPath().c_str(),line.c_str(),vlist[19].c_str());
	  if (!StringToInt(trim(vlist[19]),CrsAssigns,messageBuffer,outmessage)) return false;
	  newCar = new Car(CrsType,CrsRR.c_str(),CrsNum.c_str(),
			   CrsDivList.c_str(),CrsLen,CrsPlate,CrsClass,
			   CrsLtWt,CrsLdLmt,CrsStatus,CrsOkToMirror,
			   CrsFixedRoute,CrsOwner,CrsDone,CrsTrain,
			   CrsMoves,CrsLoc,CrsDest,CrsTrips,CrsAssigns);
	  cars.push_back(newCar);
	  //if (Cx == limitCars) break;	// ???
	}
	carsstream.close();
	for (Cxx = cars.begin(); Cxx != cars.end(); Cxx++) {
	  newCar = *Cxx;
	  newCar->SetNotDone();
	  newCar->SetLastTrain(NULL);
	  if (sessionNumber == 1 && shiftNumber == 1) {
	    newCar->ClearTrips();
	    newCar->ClearAssignments();
	  }
	  if (newCar->Location() == NULL) newCar->SetLocation(industries[0]);
	  CrsLoc = (Industry *) newCar->Location();
	  if (newCar->Destination() == NULL) newCar->SetDestination(CrsLoc);
	  if (CrsLoc != NULL) {
	    CrsLoc->cars.push_back(newCar);
	  }
	}
	return true;
}


//============================================================================
//
// This procedure uses 3 files to update 1 file, and create 1 backup.
//
// The result: a new car file, a backup of the original file.
//============================================================================
bool System::SaveCars(char **outmessage)
{
	int tempfd;
	char *tname;
	string backupfilename, line, trimline;
	PathName backupfile, tempfile;
	int dot, err, Cx;
	int oldSessionNumber, oldShiftNumber, oldTotalCars, totalCars;
	ifstream oldcarsstream;
	ofstream newcarsstream, backupcarsstream, statsstream;
	IndustryMap::const_iterator Ix;
	static char buffer[20];

	backupfile = carsFile.Dirname();
	backupfilename = carsFile.Tail();
	dot = backupfilename.rfind('.');
	if (dot == string::npos) backupfilename += ".bak";
	else backupfilename.replace(dot,backupfilename.size()-dot,".bak");
	backupfile += backupfilename;
	tempfile = carsFile.Dirname();
	tempfile += string("CARSXXXXXX");
	tname = new char[tempfile.FullPath().size()+1];
	strcpy(tname,tempfile.FullPath().c_str());
	tempfd = mkstemp(tname);
	if (tempfd < 0) {
	  if (outmessage != NULL) {
	    err = errno;
	    sprintf(messageBuffer,"mkstemp(%s) failed: %s",tname,strerror(err));
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
#if __GNUC__ < 3
	fstream junkfilestream(tempfd);
#else
#if __GNUC_MINOR__ == 0
	char_filebuf fdfilebuf(tempfd,ios_base::in | ios_base::out,true,BUFSIZ);
#else
	char_filebuf fdfilebuf(tempfd,ios_base::in | ios_base::out,BUFSIZ);
#endif
	iostream junkfilestream(&fdfilebuf);
#endif
	if (!junkfilestream) {
	  if (outmessage != NULL) {
	    strcpy(messageBuffer,"Could not open junk file stream!");
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	oldcarsstream.open(carsFile.FullPath().c_str());
	if (!oldcarsstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not open cars file (reading) %s",
		    carsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	backupcarsstream.open(backupfile.FullPath().c_str());
	if (!backupcarsstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not open backup file (write) %s",
		    backupfile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	if (!getline(oldcarsstream,line)) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not read cars file (Session Number) %s",
		    carsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	sprintf(messageBuffer,"Number syntax error (Session Number) in %s at %s",
		carsFile.FullPath().c_str(),line.c_str());
	if (!StringToInt(line,oldSessionNumber,messageBuffer,outmessage)) return false;
	if (!getline(oldcarsstream,line)) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not read cars file (Shift Number) %s",
		    carsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	sprintf(messageBuffer,"Number syntax error (Shift Number) in %s at %s",
		carsFile.FullPath().c_str(),line.c_str());
	if (!StringToInt(line,oldShiftNumber,messageBuffer,outmessage)) return false;
	if (!getline(oldcarsstream,line)) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not read cars file (Total Cars) %s",
		    carsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	sprintf(messageBuffer,"Number syntax error (Total Cars) in %s at %s",
		carsFile.FullPath().c_str(),line.c_str());
	if (!StringToInt(line,oldTotalCars,messageBuffer,outmessage)) return false;
	if (ranAllTrains == 0) {
	  sessionNumber = oldSessionNumber;
	  shiftNumber = oldShiftNumber;
	}

	totalCars = cars.size() + 10;
	
	junkfilestream   << " " << sessionNumber    << endl;
	junkfilestream   << " " << shiftNumber      << endl;
	junkfilestream   << " " << totalCars        << endl;

	backupcarsstream << " " << oldSessionNumber << endl;
	backupcarsstream << " " << oldShiftNumber   << endl;
	backupcarsstream << " " << oldTotalCars     << endl;

	totalShifts++;
	NextShift();

	Cx = 0;

	while(getline(oldcarsstream,line)) {
	  backupcarsstream << line << endl;
	  trimline = trim(line);
	  if (trimline.size() == 0 || trimline[0] == '\'') {
	    junkfilestream << line << endl;
	  } else {
	    Car *car = cars[Cx++];
	    if (car->Length() > 0) {
	      if (car->Destination() != IndScrapYard()) {
	      	if (!WriteOneCarToDisk(car,junkfilestream)) {
		  if (outmessage != NULL) {
		    sprintf(messageBuffer,"Could not write onr car to %s",
			    tname);
		    *outmessage = new char[strlen(messageBuffer)+1];
		    strcpy(*outmessage,messageBuffer);
		  }
		  return false;
		}
	      }
	    }
	  }
	}
	while (Cx < cars.size()) {
	  Car *car = cars[Cx++];
	  if (car->Length() > 0) {
	    if (car->Destination() != IndScrapYard()) {
	      if (!WriteOneCarToDisk(car,junkfilestream)) {
		if (outmessage != NULL) {
		  sprintf(messageBuffer,"Could not write onr car to %s",
			  tname);
		  *outmessage = new char[strlen(messageBuffer)+1];
		  strcpy(*outmessage,messageBuffer);
		}
		return false;
	      }
	    }
	  }
	}
	oldcarsstream.close();
	backupcarsstream.close();
	junkfilestream.seekp(0L);

	newcarsstream.open(carsFile.FullPath().c_str());
	if (!newcarsstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not open cars file (write) %s",
		    carsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	while (getline(junkfilestream,line)) {
	  newcarsstream << line << endl;
	}
#if __GNUC__ < 3
	junkfilestream.close();
#else
	fdfilebuf.close();
#endif
	newcarsstream.close();

	statsstream.open(statsFile.FullPath().c_str());
	if (!statsstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,"Could not open stats file (write) %s",
		    statsFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	statsPeriod += ranAllTrains;
	statsstream << " " << statsPeriod << "," << endl;
	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  Industry *ind = Ix->second;
	  statsstream << Ix->first << "," << ind->CarsNum() << "," <<
	  		 ind->CarsLen() << "," << ind->StatsLen() << endl;
	  ind->IncrementStatsLen(ind->TrackLen());
	}	
	statsstream.close();
	ranAllTrains = 0;

	unlink(tname);
	delete tname;
	return true;
}





bool System::WriteOneCarToDisk(Car *car,ostream &stream)
{
	int StrLen;
	static char buffer[256];
	char *p;
	
//  Car TYPE
	p = buffer;
	*p++ = car->Type();
	*p++ = ',';
//  Car RR
	sprintf(p,"%-9s,",car->Marks());
	p += strlen(p);
//  Car NUMBER
	sprintf(p,"%8s,",car->Number());
	p += strlen(p);
//   Car HOMEDIVS
	strcpy(p,car->Divisions());
	StrLen = strlen(car->Divisions());
	p += strlen(p);
	for (int Pad = StrLen; Pad <= 18; Pad++) *p++ = ' ';
//  Car LEN
	sprintf(p,"%5d,",car->Length());
	p += strlen(p);
//  Car CLEARANCE PLATE
	sprintf(p,"%1d,",car->Plate());
	p += strlen(p);
//  Car WEIGHT CLASS
	sprintf(p,"%1d,",car->WeightClass());
	p += strlen(p);
//  Car LIGHT WEIGHT
	sprintf(p,"%4d,",car->LtWt());
	p += strlen(p);
//  Car LOAD LIMIT
	sprintf(p,"%5d,",car->LdLmt());
	p += strlen(p);
//  Car STATUS
	if (car->LoadedP()) {
		*p++ = 'L';
	} else {
		*p++ = 'E';
	}
	*p++ = ',';
//  Car OK TO MIRROR
	if (car->OkToMirrorP()) {
		*p++ = 'Y';
	} else {
		*p++ = 'N';
	}
	*p++ = ',';
//  Car FIXED ROUTE INDICATOR
	if (car->FixedRouteP()) {
		*p++ = 'Y';
	} else {
		*p++ = 'N';
	}
	*p++ = ',';
//  Car OWNER INITIALS
	const Owner *owner = car->CarOwner();
	if (owner == NULL) {
		strcpy(p,"UNK");
	} else {
		sprintf(p,"%-3s,",owner->Initials());
	}
	p += strlen(p);
//  Car DONE INDICATOR
	if (car->IsDoneP()) {
		*p++ = 'Y';
	} else {
		*p++ = 'N';
	}
	*p++ = ',';
//  Car LAST TRAIN
	sprintf(p,"%3d,",TrainIndex(car->LastTrain()));
	p += strlen(p);
//  Car MOVES
	sprintf(p,"%3d,",car->MovementsThisSession());
	p += strlen(p);
//  Car LOCATION
	sprintf(p,"%3d,",IndustryIndex(car->Location()));
	p += strlen(p);
//  Car DESTINATION
	sprintf(p,"%3d,",IndustryIndex(car->Destination()));
	p += strlen(p);
//  Car TRIPS
	sprintf(p,"%4d,",car->Trips());
	p += strlen(p);
//  Car ASSIGNMENTS
	sprintf(p,"%4d",car->Assignments());
	p += strlen(p);
	stream << buffer << endl;
	return true;
}
