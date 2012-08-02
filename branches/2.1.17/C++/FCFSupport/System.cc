/* 
 * ------------------------------------------------------------------
 * System.cc - System class implementation
 * Created by Robert Heller on Thu Aug 25 10:53:36 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.3  2006/02/26 23:09:23  heller
 * Modification History: Lockdown for machine xfer
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:33  heller
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
#include <algorithm>

/*************************************************************************
 *                                                                       *
 * This file contains a collection of helper methods that perform various*
 * chores for code elsewhere.						 *
 *                                                                       *
 *************************************************************************/



/*
 * Trim excess whitespace characters from both ends of a string.
 */
 
const string System::whitespace = " \t";

string System::trim(string line) const {
	string::size_type pos1, pos2;
	for (pos1 = 0; pos1 < line.size() &&
		       whitespace.find(line[pos1]) != string::npos;pos1++) ;
	for (pos2 = line.size();
	     pos2 > pos1 &&
	     whitespace.find(line[pos2-1]) != string::npos;pos2--) ;
	return line.substr(pos1,pos2-pos1);
}

/*
 * Read the next line from a datafile, skipping any intervening comment lines.
 * Save the line of text and return true if successfull.  If EOF reached,
 * generate and error and return false.
 * 
 */

bool System::SkipCommentsGets(istream &stream,string& buffer,const char *message, char **outmessage) {
#ifdef DEBUG
	cerr << "*** System::SkipCommentsGets()" << endl;
#endif
	string trimString;
	while (getline(stream,buffer,'\n')) {
#ifdef DEBUG
		cerr << "*** System::SkipCommentsGets: buffer = {" << buffer << "}" << endl;
#endif
		trimString = trim(buffer);
#ifdef DEBUG
		cerr << "*** System::SkipCommentsGets: trimString = {" << trimString << "}" << endl;
#endif
		if (trimString.size() > 0 && trimString[0] != '\'') return true;
	}
	if (outmessage != NULL) {
		*outmessage = new char[strlen(message)+1];
		strcpy(*outmessage,message);
	}
	return false;
}

/*
 * Read in a group limit.  This would be a line containing some word, an equal
 * sign, and an integer value.  Store the integer value and return true.
 * Generate an error and return false otherwise.
 */

bool System::ReadGroupLimit(istream &stream,const char *label, int &value,const char *filename,char **outmessage) {
	string line, name;
	string v;
	string::size_type equal;

	while (getline(stream,line)) {
		equal = line.find('=');
		if (equal != string::npos) {
			name = trim(line.substr(0,equal-1));
			v = trim(line.substr(equal+1));
			if (strcasecmp(name.c_str(),label) != 0) {
				if (outmessage != NULL) {
					sprintf(messageBuffer,
						"Wrong name error (%s) in %s!",label,filename);
					*outmessage = new char[strlen(messageBuffer)+1];
					strcpy(*outmessage,messageBuffer);
				}
				return false;
			}
			sprintf(messageBuffer,"Integer syntax error (%s), in %s!",
						label,filename);
			return StringToInt(v,value,messageBuffer,outmessage);
		}
	}
	if (outmessage != NULL) {
		sprintf(messageBuffer,"Error reading %s -- short file (%s limit)!",
			filename,label);
		*outmessage = new char[strlen(messageBuffer)+1];
		strcpy(*outmessage,messageBuffer);
	}
	return false;		                                
}

/*
 * Split a string on the specified delimeter and return a vector of strings.
 */

vector<string> System::split(string s,char delimiter) const
{
	vector<string> result;
	string::size_type start, end;
#ifdef DEBUG
	cerr << "*** System::split(" << s << "," << delimiter << ")" << endl;
#endif
	for (start = 0;start != string::npos;start = end+1) {
		end = s.find(delimiter,start);
#ifdef DEBUG
		cerr << "*** System::split: start = " << start << ", end = " << end << endl;
#endif
		if (end == string::npos) {
			result.push_back(s.substr(start));
			return result;
		} else {
			result.push_back(s.substr(start,end-start));
		}
	}
	return result;
}

/*
 * Parse a string to an integer.  Generate an error and return false if string
 * is not a proper integer.
 */

bool System::StringToInt(string str,int &result,const char *message,char **outmessage) const
{
	const char *sword;
	char *endptr;

	sword = str.c_str();
	result = strtol(sword,&endptr,10);
	if (endptr == sword || *endptr != '\0') {
		if (outmessage != NULL) {
			*outmessage = new char[strlen(message)+1];
			strcpy(*outmessage,message);
		}
		return false;
	}
	return true;
}

/*
 * Parse a string to an integer and perform a range check.  Generate an error
 * and return false if string is not a proper integer or it is out of range.
 */

bool System::StringToIntRange(string str,int &result,int minv,int maxv,const char *message,char **outmessage) const
{
	const char *sword;
	char *endptr;

	sword = str.c_str();
	result = strtol(sword,&endptr,10);
	if (endptr == sword || *endptr != '\0') {
		if (outmessage != NULL) {
			*outmessage = new char[strlen(message)+1];
			strcpy(*outmessage,message);
		}
		return false;
	}
	if (result < minv || result > maxv) {
		if (outmessage != NULL) {
			*outmessage = new char[strlen(message)+1];
			strcpy(*outmessage,message);
		}
		return false;
	}
	return true;
}

/*
 * Overall system constructor, given a system file.
 * Read in the system file and the other support files.
 * If there is a problem, build an error message.
 */

System::System(const char *systemfile,int seed,char **outmessage)
{
	ifstream systemFileStream;
	string line;

	// Initialize printing flags.
	printYards = false;
	printAlpha = false;
	printAtwice = false;
	printList = false;
	printLtwice = false;
	printDispatch = false;
	printem = false;
#ifdef DEBUG
	cerr << "*** System::System(\"" << systemfile << "\")" << endl;
#endif
	// Get name of system file.
	systemFile = PathName(systemfile);
	// Extract directory name.
	PathName systemDirectory = PathName(systemFile.Dirname());
	// Open system file.
	systemFileStream.open(systemFile.FullPath().c_str());
#ifdef DEBUG
	cerr << "*** System::System: systemFileStream.is_open() = " << systemFileStream.is_open() << endl;
#endif
	// Open failure?
	if (!systemFileStream) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,
				"Error opening %s!",
				systemFile.FullPath().c_str());
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		return;
	}
//============================================================================
//
// Read System and File names
//
//============================================================================
	sprintf(messageBuffer,"Error reading %s -- short file (RailSystem)!",
		systemFile.FullPath().c_str());
	// Get system name
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	systemName = trim(line);
	sprintf(messageBuffer,"Error reading %s -- short file (IndusFile)!",
			       systemFile.FullPath().c_str());
	// Get name of industries file.
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	industriesFile = systemDirectory + trim(line);
	sprintf(messageBuffer,"Error reading %s -- short file (TrainsFile)!",
				systemFile.FullPath().c_str());
	// Get name of trains file
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	trainsFile = systemDirectory + trim(line);
	sprintf(messageBuffer,"Error reading %s -- short file (OrdersFile)!",
				systemFile.FullPath().c_str());
	// Get name of Train Orders file.
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	ordersFile = systemDirectory + trim(line);
	sprintf(messageBuffer,"Error reading %s -- short file (OwnersFile)!",
				systemFile.FullPath().c_str());
	// Get name of owners file
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	ownersFile = systemDirectory + trim(line);
	sprintf(messageBuffer,"Error reading %s -- short file (CarTypesFile)!",
				systemFile.FullPath().c_str());
	// Get name of car types file
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	carTypesFile = systemDirectory + trim(line);
	sprintf(messageBuffer,"Error reading %s -- short file (CarsFile)!",
				systemFile.FullPath().c_str());
	// Get name of cars file
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	carsFile = systemDirectory + trim(line);
	sprintf(messageBuffer,"Error reading %s -- short file (StatsFile)!",
				systemFile.FullPath().c_str());
	// Get name of stats file
	if (!SkipCommentsGets(systemFileStream,line,messageBuffer,outmessage)) {return;}
	statsFile = systemDirectory + trim(line);
	map<int,int,less<int> > divhomemap;
	// Read in divisions
	if (!ReadDivisions(systemFileStream,divhomemap,outmessage)) {return;}
	// Read in stations.
	if (!ReadStations(systemFileStream,outmessage)) {return;}
	// Close system file.
	systemFileStream.close();
	// Read industries file
	if (!ReadIndustries(outmessage)) {return;}
	// Fill in division home yards (industries) 
	for (map<int,int,less<int> >::const_iterator idiv = divhomemap.begin();
	     idiv != divhomemap.end();
	     idiv++) {
	     	int Dx = idiv->first;
	     	int Sx = idiv->second;
		if (FindIndustryByIndex(Sx) == NULL) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,"Bad home yard for division, out of range %d: %d in %s",
					Dx,Sx,systemFile.FullPath().c_str());
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			return;
		} else if (industries[Sx]->Type() != 'Y') {
			if (outmessage != NULL) {
				sprintf(messageBuffer,"Bad home yard for division, not a yard %d: %d in %s",
					Dx,Sx,systemFile.FullPath().c_str());
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			return;
		}
	     	(divisions[Dx])->home = industries[Sx];
	}
	// Read in trains file
	if (!ReadTrains(outmessage)) {return;}
	// Read in Train Orders file
	if (!ReadTrainOrders(outmessage)) {return;}
	// Read in car types file
	if (!ReadCarTypes(outmessage)) {return;}
	// Read in owners file
	if (!ReadOwners(outmessage)) {return;}
	// Load in Cars file)
	if (!LoadCarFile(outmessage)) {return;}
	// Load in stats file.
	if (!LoadStatsFile(outmessage)) {return;}
	// Initialize assignment loop variables.
	RestartLoop();
	// Initialize random seed.
	Randomize(seed);
}

/*
 * Destructor -- free up all allocated storage.
 */

System::~System()
{
	DivisionMap::const_iterator div_i;
	Division *D;
	StationMap::const_iterator  sta_i;
	Station *S;
	TrainMap::const_iterator    train_i;
	Train *T;
	IndustryMap::const_iterator    indus_i;
	Industry *I;
	char ct;
	int  cg, cti;
	CarType *CT;
	CarGroup *CG;

 	// Free up all divisions
	for (div_i = FirstDivision(); div_i != LastDivision(); div_i++) {
		D = div_i->second;
		delete D;
	}
	// Free up all stations
	for (sta_i = FirstStation(); sta_i != LastStation(); sta_i++) {
		S = sta_i->second;
		delete S;
	}
	// Free up all trains
	for (train_i = FirstTrain(); train_i != LastTrain(); train_i++) {
		T = train_i->second;
		delete T;
	}
	// Free up all industries
	for (indus_i = FirstIndustry(); indus_i != LastIndustry(); indus_i++) {
		I = indus_i->second;
		delete I;
	}
	// Free up all car types
	for (cti = 0; cti < CarType::MaxCarTypes; cti++) {
	  ct = carTypesOrder[cti];
	  if (ct == ',') break;
	  CT = carTypes[ct];
	  if (CT != NULL) delete CT;
	}
	// Free up all car groups
	for (cg = 0; cg < CarGroup::MaxCarGroup; cg++) {
	  CG = carGroups[cg];
	  if (CG != NULL) delete CG;
	}
	// Delete all cars
	DeleteAllExistingCars();
}

/*
 * Helper function to delete all existing cars
 */
 
void System::DeleteAllExistingCars() {
	Car *car;

	while (cars.size() > 0) {
		car = *(cars.end()-1);
		cars.erase(cars.end()-1);
		delete car;
	}
}

/*
 * Return the train index, given a train object pointer
 */

int System::TrainIndex(const Train *train) const
{
	TrainMap::const_iterator Tx;
	if (train == NULL) return 0;
	else {
		// find() does not work (compile errors)
		for (Tx = FirstTrain(); Tx != LastTrain(); Tx++) {
			if (Tx->second == train) return Tx->first;
		}
		return 0;
	}
}

/*
 * Return the industry index, given an industry object pointer
 */

int System::IndustryIndex(const Industry *indus) const
{
	IndustryMap::const_iterator Ix;
	if (indus == NULL) return 0;
	else if (indus == IndScrapYard()) return 999;
	else {
		// find() does not work (compile errors)
		for (Ix = FirstIndustry(); Ix != LastIndustry(); Ix++) {
			if (Ix->second == indus) return Ix->first;
		}
		return 0;
	}
}

/*
 * Initialize car assignment loop variables.
 */

void System::RestartLoop() {
	carsMoved = 0;
	carsAtDest = 0;
	carsNotMoved = 0;
	carsMovedOnce = 0;
	carsMovedTwice = 0;
	carsMovedThree = 0;
	carsMovedMore = 0;
	carMovements = 0;
	carsInTransit = 0;
	carsAtWorkBench = 0;
	for (CarVector::iterator Cx = cars.begin(); Cx != cars.end(); Cx++) {
		Car *car = *Cx;
		if (car->Location() == IndRipTrack()) carsAtWorkBench++;
		else {
			if (car->Location() == car->Destination()) {
				carsAtDest++;
			} else {
				carsInTransit++;
			}
			carMovements += car->MovementsThisSession();
			if (car->MovementsThisSession() == 0) carsNotMoved++;
			if (car->MovementsThisSession() >  0) carsMoved++;
			if (car->MovementsThisSession() == 1) carsMovedOnce++;
			if (car->MovementsThisSession() == 2) carsMovedTwice++;
			if (car->MovementsThisSession() == 3) carsMovedThree++;
			if (car->MovementsThisSession() >  3) carsMovedMore++;
		}
	}
	carsAtDest_carsInTransit = carsAtDest + carsInTransit;
}

/*
 * Find a car in a vector of cars.
 */

CarVector::iterator System::FindCarInCarVector(CarVector& cvect,Car *car)
{
#ifdef DEBUG
	cerr << "*** System::FindCarInCarVector(<CarVector cvect>," << car << ")" << endl;
#endif
	CarVector::iterator Cx;
	for (Cx = cvect.begin(); Cx != cvect.end(); Cx++) {
#ifdef DEBUG
	  cerr << "*** System::FindCarInCarVector (in loop): Cx = " << Cx << ", *Cx = " << *Cx << endl;
#endif
	  if (*Cx == car) break;
	}
#ifdef DEBUG
	cerr << "*** System::FindCarInCarVector (returning): Cx = " << Cx << ", *Cx = " << *Cx << endl;	
#endif
	return Cx;
}

/*
 * Find an industry.
 */

IndustryMap::iterator System::FindIndustry(Industry *industry)
{
	IndustryMap::iterator Ix;
	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
		if (Ix->second == industry) break;
	}
	return Ix;
}

/*
 * Return car status (loaded or empty) and its car type descriptor.
 */
 
void System::GetCarStatus(const Car *car,string &status,string &carTypeDescr) const
{
	CarTypeMap::const_iterator Ct;
	const CarType *ct;
	Ct = carTypes.find(car->Type());
	if (Ct == carTypes.end()) {
	  carTypeDescr = "Unknown";
	} else {
	  ct = Ct->second;
	  carTypeDescr = ct->Type();
	}
	if (car->LoadedP()) {
	  status = "LOADED";
	} else {
	  status = "EMPTY";
	}
}

/*
 * Retrieve a car type index given a car type.
 */

int System::CarTypesOrderIndex(char type) const
{
	int i;
	for (i = 0; i < CarType::MaxCarTypes; i++) {
		if (carTypesOrder[i] == type) return i;
	}
	return CarType::MaxCarTypes;
}

/*
 * Glob string matcher (lifted from Tcl)
 */
 
bool System::GlobStringMatch(const string thestring, const string pattern) const
{
	return GlobStringMatchHelper(thestring.begin(),thestring.end(),
				     pattern.begin(),pattern.end());
}

/*
 * Glob string matcher helper function (recursive).
 */

bool System::GlobStringMatchHelper(string::const_iterator string_i,
				   string::const_iterator string_e,
				   string::const_iterator pattern_i,
				   string::const_iterator pattern_e) const
{
	char p, s, ch1, ch2;
	string::const_iterator pstart = pattern_i;

	while (true) {
	  p = *pattern_i;
	  s = *string_i;
	  
#ifdef DEBUG
	  cerr << "*** System::GlobStringMatchHelper: p = " << p << ", s = " << s << endl;
#endif
	  if (pattern_i == pattern_e) return (string_i == string_e);
	  if ((string_i == string_e) && p != '*') return false;

	  if (p == '*') {
	    pattern_i++;
	    if (pattern_i == pattern_e) return true;
	    while (true) {
	      if (GlobStringMatchHelper(string_i,string_e,pattern_i,pattern_e))
	      	return true;
	      if (string_i == string_e) return false;
	      string_i++;
	    }
	  }
	  if (p == '?') {
	    pattern_i++;
	    string_i++;
	    continue;
	  }
	  if (p == '[') {
	    char startChar, endChar;
	    pattern_i++;
	    ch1 = *string_i++;
	    ch1 = tolower(ch1);
	    while (true) {
	      if ((pattern_i == pattern_e) || (*pattern_i == ']')) return false;
	      startChar = *pattern_i++;
	      startChar = tolower(startChar);
	      if ((pattern_i != pattern_e) && (*pattern_i == '-')) {
	      	pattern_i++;
	      	if (pattern_i == pattern_e) return false;
	      	endChar = *pattern_i++;
	      	endChar = tolower(endChar);
	      	if (((startChar <= ch1) && (ch1 <= endChar))
	      		|| ((endChar <= ch1) && (ch1 <= startChar))) {
	      	  break;
	      	}
	      } else if (startChar == ch1) {
	      	break;
	      }
	    }
	    while (pattern_i != pattern_e && *pattern_i != ']') pattern_i++;
	    if (pattern_i == pattern_e) pattern_i = pstart;
	    pattern_i++;
	    continue;
	  }
	  if (p == '\\') {
	    pattern_i++;
	    if (pattern_i == pattern_e) return false;
	    p = *pattern_i;
	  }
	  ch1 = *string_i++;
	  ch2 = *pattern_i++;
	  ch1 = tolower(ch1);
	  ch2 = tolower(ch2);
	  if (ch1 != ch2) return false;
	}
	
}

#ifdef DEBUG

/* @name operator<<
    @type ostream&
    @doc  Output operator for an industry pointer.
  @param ostream The stream to write to.
  @param Ix The industry to write.
 */ 
ostream& operator<<(ostream& stream,const Industry* Ix) {
	if (Ix == NULL) {
		stream << "<Industry NULL>";
	} else {
		stream << "<Industry " << Ix->Name() << ">";
	}
	return stream;
}
/* @name operator<<
   @type ostream&
   @doc Output operator for an industry reference.
  @param ostream The stream to write to.
  @param Ix The industry to write.
 */ 

ostream& operator<<(ostream& stream,const Industry& Ix) {
	stream << "<Industry " << Ix.Name() << ">";
	return stream;
}

#endif
