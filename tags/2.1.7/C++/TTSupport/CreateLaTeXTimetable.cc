/* 
 * ------------------------------------------------------------------
 * CreateLaTeXTimetable.cc - Code to generate a LaTex Employee Timetable.
 * Created by Robert Heller on Thu May 11 12:11:58 2006
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2006/05/16 19:27:45  heller
 * Modification History: May162006 Lockdown
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
 
#include <TimeTableSystem.h>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <math.h>

#define backslash '\\'
#define openbrace '{'
#define closebrace '}'

static string lowercase(string source)
{
	string::const_iterator schar;
	string result = "";
	for (schar = source.begin(); schar != source.end(); schar++) {
		if (isupper(*schar)) result += tolower(*schar);
		else result += *schar;
	}
	return result;
}

static bool getbool(string word,bool defaultValue = false)
{
	word = lowercase(word);
	if (word == "true" ||
	    word == "yes"  ||
	    word == "t"    ||
	    word == "1") return true;
	else if (word == "false" ||
		 word == "no"    ||
		 word == "nil"	 ||
		 word == "0") return false;
	else return defaultValue;
}

static double getdouble(string word,double defaultValue = 0.0)
{
	if (word == "") return defaultValue;
	return strtod(word.c_str(),NULL);
}

static int getint(string word,int defaultValue = 0)
{
	if (word == "") return defaultValue;
	return strtol(word.c_str(),NULL,10);
}

bool TimeTableSystem::CreateLaTeXTimetable(string filename_,char **outmessage)
{
	static char buffer[2048];
	string NSides;
	string GroupBy;
	if (NumberOfTrains() == 0) {
	  if (outmessage != NULL) {
	    sprintf(buffer,"No Trains!");
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return false;
	}
	double StationColWidth = getdouble(GetPrintOption("StationColWidth"),1.5);
	double TimeColWidth    = getdouble(GetPrintOption("TimeColWidth"),0.5);
	int maxTrains = (int)((7 - StationColWidth - TimeColWidth) /
			      TimeColWidth);
	bool UseMultipleTables;
	if (NumberOfTrains() >= maxTrains) {
	  UseMultipleTables = getbool(GetPrintOption("UseMultipleTables"),true);
	  TOCP = getbool(GetPrintOption("TOCP"),true);
	  GroupBy = GetPrintOption("GroupBy");
	  if (GroupBy == "") GroupBy = "Class";
	} else {
	  UseMultipleTables = getbool(GetPrintOption("UseMultipleTables"),false);
	  TOCP = getbool(GetPrintOption("TOCP"),UseMultipleTables);
	  if (UseMultipleTables) {
	    GroupBy = GetPrintOption("GroupBy");
	    if (GroupBy == "") GroupBy = "Class";
	  }
	}
	DirectionName = GetPrintOption("DirectionName");
	if (DirectionName == "") DirectionName = "Northbound";
	NSides = GetPrintOption("NSides");
	if (NSides == "") NSides = "single";
	string TimeFormat = GetPrintOption("TimeFormat");
	if (TimeFormat == "") TimeFormat = "24";
	string AMPMFormat = GetPrintOption("AMPMFormat");
	if (AMPMFormat == "") AMPMFormat = "a";
	string Title = GetPrintOption("Title");
	if (Title == "") Title = "My Model Railroad Timetable";
	string SubTitle = GetPrintOption("SubTitle");
	if (SubTitle == "") SubTitle = "Employee Timetable Number 1";
	string Date = GetPrintOption("Date");
	if (Date == "") Date = "\\today";
	string BeforeTOC = GetPrintOption("BeforeTOC");
	if (BeforeTOC == "") {
		BeforeTOC = "%\
% Insert Pre TOC material here.  Cover graphic, logo, etc.\
%";
	}
	string NotesTOP = GetPrintOption("NotesTOP");
	if (NotesTOP == "") {
		NotesTOP = "%\
% Insert notes prefix info here.\
%";
	}

	TrainList allTrains, forwardTrains, backwardTrains;
	
	TrainNumberMap::const_iterator tr;
	for (tr = trains.begin(); tr != trains.end(); tr++) {
	  Train *train = tr->second;
	  allTrains.push_back(train);
	  const Stop *s1 = train->StopI(0), *s2 = train->StopI(1);
	  if (s1->StationIndex() < s2->StationIndex()) {
	    forwardTrains.push_back(train);
	  } else {
	    backwardTrains.push_back(train);
	  }
	}
	ofstream out(filename_.c_str());
	if (!out) {
	  int err = errno;
	  if (outmessage != NULL) {
	    sprintf(buffer,"TimeTableSystem::CreateLaTeXTimetable: %s: %s",
		    filename_.c_str(),strerror(err));
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return false;
	}	
	out <<  backslash << "nonstopmode" << endl;
	if (NSides == "double") {
	  out <<  backslash << "documentclass[notitlepage,twoside]{article}";
	} else {
	  out <<  backslash << "documentclass[notitlepage]{article}";
	}
	out << endl;
	out <<  backslash << "usepackage{TimeTable}" << endl;
	out <<  backslash << "usepackage{supertabular}" << endl;
	out <<  backslash << "usepackage{graphicx}" << endl;
	if (!TOCP) out <<  backslash << "nofiles" << endl;
	if (TimeFormat == "24") {
	  out <<  backslash << "newcommand{" << backslash << "shtime}{" << backslash << "rrtimetwentyfour}";
	} else {
	  out <<  backslash << "newcommand{" << backslash << "shtime}{" << backslash << "rrtimetwelve" << AMPMFormat << "}";
	}
	out << endl;
	if (StationColWidth != 1.5) {
	  out <<  backslash << "setlength{" << backslash << "stationwidth}{" << StationColWidth << "in}"
	      << endl;
	  out <<  backslash << "setlength{" << backslash << "stationwidthonear}{" << backslash << "stationwidth}" << endl;
	  out <<  backslash << "advance" << backslash << "stationwidthonear by -.25in" << endl;
	  out <<  backslash << "setlength{" << backslash << "stationwidthtwoar}{" << backslash << "stationwidth}" << endl;
	  out <<  backslash << "advance" << backslash << "stationwidthtwoar by -.25in" << endl;
	}
	if (TimeColWidth != .5) {
	  out <<  backslash << "setlength{" << backslash << "timecolumnwidth}{" << TimeColWidth << "in}"
	      << endl;
	}
	out <<  backslash << "title{" << Title << "}" << endl;
	out <<  backslash << "author{" << SubTitle << "}" << endl;
	out <<  backslash << "date{" << Date << "}" << endl;
	out <<  backslash << "begin{document}" << endl;
	out <<  backslash << "maketitle" << endl;

	out << BeforeTOC << endl;

	if (TOCP) {
	  out <<  backslash << "tableofcontents" << endl;
	}

	if (UseMultipleTables && GroupBy == "Class") {
	  if (!MakeTimeTableGroupByClass(out,allTrains,forwardTrains,
					 backwardTrains,outmessage)) {
	    out.close();
	    return false;
	  }
	} else if (NumberOfTrains() > maxTrains) {
	  if (!MakeTimeTableGroupManually(out,maxTrains,allTrains,
					  forwardTrains,backwardTrains,
					  outmessage)) {
	    out.close();
	    return false;
	  }
	} else {
	  string header = GetPrintOption("AllTrainsHeader");
	  if (header == "") header = "All Trains";
	  string sectionTOP = GetPrintOption("AllTrainsSectionTOP");
	  if (!MakeTimeTableOneTable(out,allTrains,forwardTrains,
					 backwardTrains,header,sectionTOP,
					 outmessage)) {
	    out.close();
	    return false;
	  }
	}

	if (NumberOfNotes() > 0) {
	  out <<  backslash << "clearpage" << endl;
	  out << NotesTOP << endl;
	  out << backslash << "section*{Notes}" << endl;
	  if (TOCP) {
	    out <<  backslash << "addcontentsline{toc}{section}{Notes}" << endl;
	  }
	  out << backslash << "begin{description}" << endl;
	  for (int nt=0; nt < NumberOfNotes(); nt++) {
	    string note = notes[nt];
	    string period = "";
	    if (strchr(".?!",*(note.end()-1)) == NULL) {
	      period = ".";
	    }
	    out << backslash << "item[" << nt+1 << "] " << note << period << endl;
	  }
	  out <<  backslash << "end{description}" << endl;
	}
	out <<  backslash << "end{document}" << endl;
	out.close();
	return true;
}

bool TimeTableSystem::MakeTimeTableGroupByClass(ostream &out,
						TrainList &allTrains,
						TrainList &forwardTrains,
						TrainList &backwardTrains,
						char **outmessage)
{
	static  char buffer[2048];
	list<int> classlist;
	TrainList::const_iterator tr;
	for (tr = allTrains.begin(); tr != allTrains.end(); tr++) {
	  const Train *train = *tr;
	  int classnumber = train->ClassNumber();
	  list<int>::const_iterator cl = find(classlist.begin(),
					      classlist.end(),classnumber);
	  if (cl == classlist.end()) classlist.push_back(classnumber);
	}
	classlist.sort();
	list<int>::const_iterator classI;
	for (classI = classlist.begin(); classI != classlist.end(); classI++) {
	  int classnumber = *classI;
	  TrainList fcl, bcl, acl;
	  for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	    Train *train = *tr;
	    int classnumber = train->ClassNumber();
	    if (*classI == classnumber) {fcl.push_back(train);}
	  }
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    Train *train = *tr;
	    int classnumber = train->ClassNumber();
	    if (*classI == classnumber) {bcl.push_back(train);}
	  }
	  for (tr = allTrains.begin(); tr != allTrains.end(); tr++) {
	    Train *train = *tr;
	    int classnumber = train->ClassNumber();
	    if (*classI == classnumber) {acl.push_back(train);}
	  }
	  sprintf(buffer,"Group,%d,ClassHeader",*classI);
	  string classHeader = GetPrintOption(buffer);
	  if (classHeader == "") {
	    sprintf(buffer,"Class %d trains",*classI);
	    classHeader = buffer;
	  }
	  sprintf(buffer,"Group,%d,SectionTOP",*classI);
	  string sectionTOP = GetPrintOption(buffer);
	  if (!MakeTimeTableOneTable(out,acl,fcl,bcl,classHeader,sectionTOP,
		outmessage)) return false;
	}
	return true;
}

bool TimeTableSystem::MakeTimeTableGroupManually(ostream &out,int maxTrains,
						 TrainList &allTrains,
						 TrainList &forwardTrains,
						 TrainList &backwardTrains,
						 char **outmessage)
{
	static  char buffer[2048];
	int igroup;
	for (igroup = 1; allTrains.size() > 0; igroup++) {
	  StringList listOfTrains;
	  sprintf(buffer,"Group,%d,ClassHeader",igroup);
	  string classHeader = GetPrintOption(buffer);
	  if (classHeader == "") {
	    sprintf(buffer,"Class %d trains",igroup);
	    classHeader = buffer;
	  }
	  sprintf(buffer,"Group,%d,SectionTOP",igroup);
	  string sectionTOP = GetPrintOption(buffer);
	  sprintf(buffer,"Group,%d,Trains",igroup);
	  string trainlist = GetPrintOption(buffer);
	  if (!StringListFromString(trainlist,listOfTrains)) {
	    if (outmessage != NULL) {
	      sprintf(buffer,"\"Group,%d,Trains\" print option has a syntax error (\"%s\")!",
	      		     igroup,trainlist.c_str());
	      *outmessage = new char[strlen(buffer)+1];
	      strcpy(*outmessage,buffer);
	    }
	    return false;
	  }
	  if (listOfTrains.size() == 0 && allTrains.size() > 0) {
	    if (outmessage != NULL) {
	      sprintf(buffer,"\"Group,%d,Trains\" print option is empty, but there are remaining trains!",
	      	      igroup);
	      *outmessage = new char[strlen(buffer)+1];
	      strcpy(*outmessage,buffer);
	    }
	    return false;
	  }
	  TrainList fcl, bcl, acl;
	  TrainList::const_iterator tr;
	  for (tr = allTrains.begin(); tr != allTrains.end(); tr++) {
	    Train *train = *tr;
	    StringList::const_iterator tn = find(listOfTrains.begin(),
	    					 listOfTrains.end(),
						 train->Number());
	    if (tn == listOfTrains.end()) continue;
	    acl.push_back(train);
	  }
	  for (tr = acl.begin(); tr != acl.end(); tr++) {
	    Train *train = *tr;
	    allTrains.remove(train);
	  }
	  for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	    Train *train = *tr;
	    StringList::const_iterator tn = find(listOfTrains.begin(),
						 listOfTrains.end(),
						 train->Number());
	    if (tn == listOfTrains.end()) continue;
	    fcl.push_back(train);
	  }
	  for (tr = fcl.begin(); tr != fcl.end(); tr++) {
	    Train *train = *tr;
	    forwardTrains.remove(train);
	  }
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    Train *train = *tr;
	    StringList::const_iterator tn = find(listOfTrains.begin(),
						 listOfTrains.end(),
						 train->Number());
	    if (tn == listOfTrains.end()) continue;
	    bcl.push_back(train);
	  }
	  for (tr = bcl.begin(); tr != bcl.end(); tr++) {
	    Train *train = *tr;
	    backwardTrains.remove(train);
	  }
	  if (!MakeTimeTableOneTable(out,acl,fcl,bcl,classHeader,sectionTOP,
				     outmessage)) return false;
	}
	return true;
}

bool TimeTableSystem::MakeTimeTableOneTable(ostream &out,TrainList &allTrains,
					    TrainList &forwardTrains,
					    TrainList &backwardTrains,
					    string header,string sectionTOP,
					    char **outmessage)
{
	if (backwardTrains.empty()) {
	  return MakeTimeTableOneTableStationsLeft(out,forwardTrains,header,
						   sectionTOP,outmessage);
	} else {
	  return MakeTimeTableOneTableStationsCenter(out,forwardTrains,
						     backwardTrains,header,
						     sectionTOP,outmessage);
	}
}

bool TimeTableSystem::MakeTimeTableOneTableStationsLeft(ostream &out,
							TrainList &trains,
							string header,
							string sectionTOP,
							char **outmessage)
{
	static  char buffer[2048];
	TrainTimesAtStation timesAtStations;
	ComputeTimes(timesAtStations,trains);
	TrainList::const_iterator tr;
	int ntrains = trains.size();
	int itr,inote,numnotes,istation,numstations;

	out <<  backslash << "clearpage" << endl;
	out <<  backslash << "section*{" << header << "}" << endl;
	if (TOCP) {
	  out <<  backslash << "addcontentsline{toc}{section}{" << header << "}" << endl;
	  for (tr = trains.begin(); tr != trains.end(); tr++) {
	    out <<  backslash << "addcontentsline{toc}{subsection}{" << (*tr)->Number()
		<< "}" << endl;
	  }
	}
	out << sectionTOP << endl;
	out << endl <<  backslash << "begin{supertabular}{|r|p{" << backslash << "stationwidth}|";
	for (itr = 0; itr < ntrains; itr++) {
	  out << "r|";
	}
	out << "}" << endl;
	out <<  backslash << "hline" << endl;
	out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{Train number:" << backslash <<  backslash << "name:" << backslash <<  backslash << "class:}";
	for (tr = trains.begin(); tr != trains.end(); tr++) {
	  const Train *train = *tr;
	  string number = train->Number();
	  string name   = train->Name();
	  int classnumer = train->ClassNumber();
	  out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{" << number <<  backslash <<  backslash <<  name
	      << backslash <<  backslash <<  classnumer << "}";
	}
	out <<  backslash <<  backslash <<  endl;
	out <<  backslash << "hline" << endl;
	out << "&Notes:";
	for (tr = trains.begin(); tr != trains.end(); tr++) {
	  const Train *train = *tr;
	  out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{";
	  numnotes = train->NumberOfNotes();
	  for (inote = 0; inote < numnotes; inote++) {
	    out << train->Note(inote) << " ";
	  }
	  out << "}";
	}
	out <<  backslash <<  backslash <<  endl;
	out <<  backslash << "hline" << endl;
	out << "Mile&Station&" << backslash << "multicolumn{" << ntrains
	    << "}{|c|}{" << DirectionName << " (Read Down)}" << backslash 
	    <<  backslash <<  endl;
	out <<  backslash << "hline" << endl;
	numstations = NumberOfStations();
	for (istation = 0; istation < numstations; istation++) {
	  TrainTimesAtStation::const_iterator tas =
		timesAtStations.find(istation);
	  if (tas == timesAtStations.end()) continue;
	  const Station *station = IthStation(istation);
	  double smile = station->SMile();
	  out << "&" << backslash << "parbox[t]{" << backslash
	      << "stationwidthonear}{" << station->Name() << "}"
	      << backslash << "hfill AR";
	  for (tr = trains.begin(); tr != trains.end(); tr++) {
	    const Train *train = *tr;
	    out << "&";
	    TrainStationTimes::const_iterator tst =
	    	(tas->second).find(train->Number());
	    if (tst == (tas->second).end()) continue;
	    StationTimes st = tst->second;
	    if (st.Flag() != Stop::Origin) {
	      out <<  backslash << "shtime{" << ((int)(st.Arrival()+.5)) << "}";
	    } else {
	      const Stop *origStop = train->StopI(0);
	      string strack = origStop->StorageTrackName();
	      if (strack != "") {out << "Tr " << strack;}
	    }	    
	  }
	  out <<  backslash << backslash <<  endl;
	  out << ((int)(smile + .5)) << "&";
	  for (tr = trains.begin(); tr != trains.end(); tr++) {
	    const Train *train = *tr;
	    out << "&";
	    TrainStationTimes::const_iterator tst =
	    	(tas->second).find(train->Number());
	    if (tst == (tas->second).end()) continue;
	    int nstops = train->NumberOfStops(), istop;
	    for (istop = 0; istop < nstops; istop++) {
	      const Stop *stop = train->StopI(istop);
	      if (stop->StationIndex() == istation) {
		out <<  backslash << "parbox{" << backslash << "timecolumnwidth}{";
		const Cab *cab = stop->TheCab();
		if (cab != NULL) {
		  string cname = cab->Name();
		  if (cname != "") {
		    out << cname <<  backslash << backslash;
		  }
		}
		int nnotes = stop->NumberOfNotes(), inote;
		for (inote = 0; inote < nnotes; inote++) {
		  out << stop->Note(inote) << " ";
		}
		out << "}";
		break;
	      }
	    }
	  }
	  out <<  backslash << backslash <<  endl;
	  out << "&" << backslash << "hfill LV";
	  for (tr = trains.begin(); tr != trains.end(); tr++) {
	    const Train *train = *tr;
	    out << "&";
	    TrainStationTimes::const_iterator tst =
	    	(tas->second).find(train->Number());
	    if (tst == (tas->second).end()) continue;
	    StationTimes st = tst->second;
	    if (st.Flag() != Stop::Terminate) {
	      out <<  backslash << "shtime{" << ((int)(st.Departure()+.5)) << "}";
	    } else {
	      const Stop *destStop = train->StopI(train->NumberOfStops()-1);
	      string strack = destStop->StorageTrackName();
	      if (strack != "") {out << "Tr " << strack;}
	    }	    
	  }
	  out << backslash << backslash <<  endl;
	  out << backslash << "hline" << endl;
	}
	out <<  backslash << "end{supertabular}" << endl;
	out << endl;
	out <<  backslash << "vfill" << endl;
	out << endl;
	return true;
}

bool TimeTableSystem::MakeTimeTableOneTableStationsCenter(ostream &out,
							  TrainList &forwardTrains,
							  TrainList &backwardTrains,
							  string header,
							  string sectionTOP,
							  char **outmessage)
{
	static  char buffer[2048];
	string rev;
	if (DirectionName == "Northbound") rev = "Southbound";
	else if (DirectionName == "Southbound") rev = "Northbound";
	else if (DirectionName == "Eastbound") rev = "Westbound";
	else if (DirectionName == "Westbound") rev = "Eastbound";
	TrainTimesAtStation timesAtStationsForward,timesAtStationsBackward;
	ComputeTimes(timesAtStationsForward,forwardTrains);
	ComputeTimes(timesAtStationsBackward,backwardTrains);
	TrainList::const_iterator tr;
	int nFtrains = forwardTrains.size(), nBtrains = backwardTrains.size();
	int itr,inote,numnotes,istation,numstations;

	out <<  backslash << "clearpage" << endl;
	out <<  backslash << "section*{" << header << "}" << endl;
	if (TOCP) {
	  out <<  backslash << "addcontentsline{toc}{section}{" << header << "}" << endl;
	  for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	    out <<  backslash << "addcontentsline{toc}{subsection}{" << (*tr)->Number()
		<< "}" << endl;
	  }
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    out <<  backslash << "addcontentsline{toc}{subsection}{" << (*tr)->Number()
		<< "}" << endl;
	  }
	}
	out << sectionTOP << endl;
	out << endl <<  backslash << "begin{supertabular}{|";
	for (itr = 0; itr < nFtrains; itr++) {
	  out << "r|";
	}
	out << "|r|p{" << backslash << "stationwidth}|";
	for (itr = 0; itr < nBtrains; itr++) {
	  out << "r|";
	}
	out << "}" << endl;
	out <<  backslash << "hline" << endl;
	for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	  const Train *train = *tr;
	  string number = train->Number();
	  string name   = train->Name();
	  int classnumer = train->ClassNumber();
	  out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{" << number <<  backslash <<  backslash <<  name
	      <<  backslash <<  backslash <<  classnumer << "}";
	}
	out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{Train number:" << backslash <<  backslash << "name:" << backslash <<  backslash << "class:}";
	for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	  const Train *train = *tr;
	  string number = train->Number();
	  string name   = train->Name();
	  int classnumer = train->ClassNumber();
	  out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{" << number <<  backslash <<  backslash <<  name
	      <<  backslash <<  backslash << classnumer << "}";
	}
	out << backslash << backslash << endl;
	out << backslash << "hline" << endl;
	for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	  const Train *train = *tr;
	  out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{";
	  numnotes = train->NumberOfNotes();
	  for (inote = 0; inote < numnotes; inote++) {
	    out << train->Note(inote) << " ";
	  }
	  out << "}";
	}
	out << "&Notes:";
	for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	  const Train *train = *tr;
	  out << "&" << backslash << "parbox{" << backslash << "timecolumnwidth}{";
	  numnotes = train->NumberOfNotes();
	  for (inote = 0; inote < numnotes; inote++) {
	    out << train->Note(inote) << " ";
	  }
	  out << "}";
	}
	out <<  backslash <<  backslash <<  endl;
	out <<  backslash << "hline" << endl;
	out << backslash << "multicolumn{" << nFtrains<< "}{|c|}{"
	    << DirectionName << " (Read Down)}&Mile&Station&" << backslash 
	    << "multicolumn{" << nBtrains << "}{|c|}{" << rev 
	    << " (Read up)}" << backslash <<  backslash <<  endl;
	out <<  backslash << "hline" << endl;
	out <<  backslash << "hline" << endl;
	numstations = NumberOfStations();
	for (istation = 0; istation < numstations; istation++) {
	  TrainTimesAtStation::const_iterator tasF =
		timesAtStationsForward.find(istation),
	    tasB = timesAtStationsBackward.find(istation);
	  if (tasF == timesAtStationsForward.end() &&
	      tasB == timesAtStationsBackward.end()) continue;
	  const Station *station = IthStation(istation);
	  double smile = station->SMile();
	  for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	    	(tasF->second).find(train->Number());
	    if (tst != (tasF->second).end()) {
	      StationTimes st = tst->second;
	      if (st.Flag() != Stop::Origin) {
	        out <<  backslash << "shtime{" << ((int)(st.Arrival()+.5)) << "}";
	      } else {
	        const Stop *origStop = train->StopI(0);
	        string strack = origStop->StorageTrackName();
	        if (strack != "") {out << "Tr " << strack;}
	      }
	    }	    
	    out << "&";
	  }
	  out << "&AR" << backslash << "hfill" << backslash << "parbox[t]{"
	      << backslash << "stationwidthtwoar}{" << station->Name() << "}"
	      << backslash << "hfill AR";
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    out << "&";
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	    	(tasF->second).find(train->Number());
	    if (tst != (tasF->second).end()) {
	      StationTimes st = tst->second;
	      if (st.Flag() != Stop::Origin) {
	        out << backslash << "shtime{" << ((int)(st.Arrival()+.5)) << "}";
	      } else {
	        const Stop *origStop = train->StopI(0);
	        string strack = origStop->StorageTrackName();
	        if (strack != "") {out << "Tr " << strack;}
	      }
	    }	    
	  }
	  out << backslash << backslash << endl;
	  for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	    	(tasF->second).find(train->Number());
	    if (tst != (tasF->second).end()) {
	      int nstops = train->NumberOfStops(), istop;
	      for (istop = 0; istop < nstops; istop++) {
	        const Stop *stop = train->StopI(istop);
	        if (stop->StationIndex() == istation) {
		  out <<  backslash << "parbox{" << backslash << "timecolumnwidth}{";
		  const Cab *cab = stop->TheCab();
		  if (cab != NULL) {
		    string cname = cab->Name();
		    if (cname != "") {
		      out << cname <<  backslash << backslash;
		    }
		  }
		  int nnotes = stop->NumberOfNotes(), inote;
		  for (inote = 0; inote < nnotes; inote++) {
		    out << stop->Note(inote) << " ";
		  }
		  out << "}";
		  break;
		}
	      }
	    }
	    out << "&";
	  }
	  out << ((int)(smile + .5)) << "&";	  
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    out << "&";
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	        (tasB->second).find(train->Number());
	    if (tst != (tasF->second).end()) {
	      int nstops = train->NumberOfStops(), istop;
	      for (istop = 0; istop < nstops; istop++) {
	        const Stop *stop = train->StopI(istop);
	        if (stop->StationIndex() == istation) {
		  out <<  backslash << "parbox{" << backslash << "timecolumnwidth}{";
		  const Cab *cab = stop->TheCab();
		  if (cab != NULL) {
		    string cname = cab->Name();
		    if (cname != "") {
		      out << cname <<  backslash << backslash;
		    }
		  }
		  int nnotes = stop->NumberOfNotes(), inote;
		  for (inote = 0; inote < nnotes; inote++) {
		    out << stop->Note(inote) << " ";
		  }
		  out << "}";
		  break;
		}
	      }
	    }
	  }
	  out << backslash << backslash << endl;	  
	  for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	    	(tasF->second).find(train->Number());
	    if (tst != (tasF->second).end()) {
	      StationTimes st = tst->second;
	      if (st.Flag() != Stop::Terminate) {
	        out <<  backslash << "shtime{" << ((int)(st.Departure()+.5)) << "}";
	      } else {
	        const Stop *destStop = train->StopI(train->NumberOfStops()-1);
	        string strack = destStop->StorageTrackName();
	        if (strack != "") {out << "Tr " << strack;}
	      }    
	    }
	    out << "&";
	  }
	  out << "&LV" << backslash << "hfill LV";
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    out << "&";
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	        (tasB->second).find(train->Number());
	    if (tst != (tasF->second).end()) {
	      StationTimes st = tst->second;
	      if (st.Flag() != Stop::Terminate) {
	        out <<  backslash << "shtime{" << ((int)(st.Departure()+.5)) << "}";
	      } else {
	        const Stop *destStop = train->StopI(train->NumberOfStops()-1);
	        string strack = destStop->StorageTrackName();
	        if (strack != "") {out << "Tr " << strack;}
	      }    
	    }
	  }
	  out << backslash << backslash << endl;	  
	  out << backslash << "hline" << endl;
	}
	out <<  backslash << "end{supertabular}" << endl;
	out << endl;
	out <<  backslash << "vfill" << endl;
	out << endl;
	return true;
}

void TimeTableSystem::ComputeTimes(TrainTimesAtStation &timesAtStations,
				   TrainList &trains)
{
	int istop, i, nstops;
	double oldDepart,depart;
	double oldSmile,smile;
	double arrival,departure;
	int speed;
	TrainList::const_iterator tr;

	for (tr = trains.begin(); tr != trains.end(); tr++) {
	  const Train *train = *tr;
	  departure = train->Departure();
	  speed = train->Speed();
	  oldDepart = -1;
	  oldSmile =  -1;
	  nstops = train->NumberOfStops();
	  for (i=0; i < nstops; i++) {
	    const Stop *stop = train->StopI(i);
	    istop = stop->StationIndex();
	    const Station *station = IthStation(istop);
	    smile = station->SMile();
	    if (oldDepart >= 0) {
	      arrival = oldDepart + (fabs(smile - oldSmile) * (speed / 60.0));
	    } else {
	      arrival = departure;
	    }
	    depart = stop->Departure(arrival);
	    StationTimes st(arrival,depart,stop->Flag());
	    timesAtStations[istop][train->Number()] = st;
	    oldDepart = depart;
	    oldSmile  = smile;
	  }
	}
}
