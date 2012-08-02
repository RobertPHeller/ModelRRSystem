/* 
 * ------------------------------------------------------------------
 * CreateLaTeXTimetable.cc - Code to generate a LaTex Employee Timetable.
 * Created by Robert Heller on Thu May 11 12:11:58 2006
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/05/06 12:49:38  heller
 * Modification History: Lock down  for 2.1.8 release candidate 1
 * Modification History:
 * Modification History: Revision 1.2  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
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

using namespace TTSupport;

/*
 * Common LaTeX characters.
 */

#define backslash '\\'
#define openbrace '{'
#define closebrace '}'

/*
 * Convert string to lower case.
 */

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

/*
 * Convert a word to a boolean value, with a default value.
 */

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

/*
 * Convert a word to a double float value, with a default value.
 */

static double getdouble(string word,double defaultValue = 0.0)
{
	if (word == "") return defaultValue;
	return strtod(word.c_str(),NULL);
}

#ifdef UNNEEDED
/*
 * Convert a word to an integer value, with a default value.
 */

static int getint(string word,int defaultValue = 0)
{
	if (word == "") return defaultValue;
	return strtol(word.c_str(),NULL,10);
}
#endif
/**********************************************************************
 * Main Time Table Creation method. This is the public method that is *
 * called from Tcl.  All of the parameter settings, except the output *
 * filename, are passed though the print options database (saved with *
 * the rest of the time table data).                                  *
 **********************************************************************/

bool TimeTableSystem::CreateLaTeXTimetable(string filename_,char **outmessage)
{
	static char buffer[2048];	// Scratch buffer for error messages
	string NSides;			// Single or two sided printing
	string GroupBy;			// Grouping mode
	// If there are no trains, there is nothing to do!
	if (NumberOfTrains() == 0) {
	  if (outmessage != NULL) {
	    sprintf(buffer,"No Trains!");
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return false;
	}
	// Get formatting sizes (column widths).
	double StationColWidth = getdouble(GetPrintOption("StationColWidth"),1.5);
	double TimeColWidth    = getdouble(GetPrintOption("TimeColWidth"),0.5);
	// Figure out how many trains will fit across a page.
	int maxTrains = (int)((7 - StationColWidth - TimeColWidth) /
			      TimeColWidth);
	bool UseMultipleTables;			// Use multiple tables???
	// If there are more trains than will fit on a page, default to using
	// multiple tables, otherwise default to using a single table.
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
	// Get the logical direction name.
	DirectionName = GetPrintOption("DirectionName");
	if (DirectionName == "") DirectionName = "Northbound";
	// Single or double sided formatting?
	NSides = GetPrintOption("NSides");
	if (NSides == "") NSides = "single";
	// Time format.
	string TimeFormat = GetPrintOption("TimeFormat");
	if (TimeFormat == "") TimeFormat = "24";
	string AMPMFormat = GetPrintOption("AMPMFormat");
	if (AMPMFormat == "") AMPMFormat = "a";
	// Title, subtitle, and date of the time table.
	string Title = GetPrintOption("Title");
	if (Title == "") Title = "My Model Railroad Timetable";
	string SubTitle = GetPrintOption("SubTitle");
	if (SubTitle == "") SubTitle = "Employee Timetable Number 1";
	string Date = GetPrintOption("Date");
	if (Date == "") Date = "\\today";
	// LaTeX code to include in the preamble.
	string ExtraPreamble = GetPrintOption("ExtraPreamble");
	// LaTeX code to put before the table of contents (eg on the title
	// page).  Typically this will be a cover (logo) graphic or other
	// such content.
	string BeforeTOC = GetPrintOption("BeforeTOC");
	if (BeforeTOC == "") {
		BeforeTOC = "%\
% Insert Pre TOC material here.  Cover graphic, logo, etc.\
%";
	}
	// LaTeX code to put a the start of the Notes section.
	string NotesTOP = GetPrintOption("NotesTOP");
	if (NotesTOP == "") {
		NotesTOP = "%\
% Insert notes prefix info here.\
%";
	}

	// Get lists of trains.

	TrainList allTrains, forwardTrains, backwardTrains;

	// Loop through train map, collecting all trains, forward moving
	// trains (assending station indexes) and backward moving trains
	// (decending station indexes).
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
	// Open LaTeX output file.
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
	// Output LaTeX preamble.
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
	if (ExtraPreamble != "") {out << ExtraPreamble << endl;}
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

	// Generate title.
	out <<  backslash << "maketitle" << endl;

	// User supplied title page material.
	out << BeforeTOC << endl;

	// Table of contents.
	if (TOCP) {
	  out <<  backslash << "tableofcontents" << endl;
	}

	// Branch off depending on how many tables and how the tables are
	// grouped.
	if (UseMultipleTables && GroupBy == "Class") {
	  // Multiple tables, grouped by class.
	  if (!MakeTimeTableGroupByClass(out,allTrains,forwardTrains,
					 backwardTrains,outmessage)) {
	    out.close();
	    return false;
	  }
	} else if (NumberOfTrains() > maxTrains) {
	  // Multiple tables, grouped manually.
	  if (!MakeTimeTableGroupManually(out,maxTrains,allTrains,
					  forwardTrains,backwardTrains,
					  outmessage)) {
	    out.close();
	    return false;
	  }
	} else {
	  // Single table for all trains.
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

	// Generate notes section if there are any notes.
	if (NumberOfNotes() > 0) {
	  // Fresh page.
	  out <<  backslash << "clearpage" << endl;
	  // Section heading.
	  out << backslash << "section*{Notes}" << endl;
	  if (TOCP) {
	    out <<  backslash << "addcontentsline{toc}{section}{Notes}" << endl;
	  }
	  // User supplied content.
	  out << NotesTOP << endl;
	  // Output notes as a LaTeX description environment.
	  out << backslash << "begin{description}" << endl;
	  for (int nt=0; nt < NumberOfNotes(); nt++) {
	    string note = notes[nt];
	    // Make sure we have proper punctuation (we don't want to be 
	    // busted by the Grammar Police).
	    string period = "";
	    if (strchr(".?!",*(note.end()-1)) == NULL) {
	      period = ".";
	    }
	    // Put out the note.
	    out << backslash << "item[" << nt+1 << "] " << note << period << endl;
	  }
	  // End of notes.
	  out <<  backslash << "end{description}" << endl;
	}
	// End of document.
	out <<  backslash << "end{document}" << endl;
	out.close();
	return true;
}

/**********************************************************************
 * Create a series of time tables, one for each class of train.       *
 * This private method loops over the set of train classes generating *
 * one table for each class of train.				      *
 **********************************************************************/

bool TimeTableSystem::MakeTimeTableGroupByClass(ostream &out,
						TrainList &allTrains,
						TrainList &forwardTrains,
						TrainList &backwardTrains,
						char **outmessage)
{
	static  char buffer[2048];	// Error message buffer
	list<int> classlist;		// (Sorted) list of classes.
	TrainList::const_iterator tr;	// Train list iterator.
	// Loop over all trains, collecting unique class numbers.
	for (tr = allTrains.begin(); tr != allTrains.end(); tr++) {
	  const Train *train = *tr;
	  int classnumber = train->ClassNumber();
	  list<int>::const_iterator cl = find(classlist.begin(),
					      classlist.end(),classnumber);
	  if (cl == classlist.end()) classlist.push_back(classnumber);
	}
	// Sort the class list.
	classlist.sort();
	list<int>::const_iterator classI; // Class list iterator.
	// For each class, collect the trains for that class as three lists
	// (all, forward, backward).  Generate a table for each class.
	for (classI = classlist.begin(); classI != classlist.end(); classI++) {
	  int classnumber = *classI;		// Class number.
	  TrainList fcl, bcl, acl;		// Class train lists.
	  // Collect train lists.
	  for (tr = forwardTrains.begin(); tr != forwardTrains.end(); tr++) {
	    Train *train = *tr;
	    classnumber = train->ClassNumber();
	    if (*classI == classnumber) {fcl.push_back(train);}
	  }
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    Train *train = *tr;
	    classnumber = train->ClassNumber();
	    if (*classI == classnumber) {bcl.push_back(train);}
	  }
	  for (tr = allTrains.begin(); tr != allTrains.end(); tr++) {
	    Train *train = *tr;
	    classnumber = train->ClassNumber();
	    if (*classI == classnumber) {acl.push_back(train);}
	  }
	  // Get or create group header
	  sprintf(buffer,"Group,%d,ClassHeader",*classI);
	  string classHeader = GetPrintOption(buffer);
	  if (classHeader == "") {
	    sprintf(buffer,"Class %d trains",*classI);
	    classHeader = buffer;
	  }
	  // Get or create user content.
	  sprintf(buffer,"Group,%d,SectionTOP",*classI);
	  string sectionTOP = GetPrintOption(buffer);
	  // Call helper method to generate the table.
	  if (!MakeTimeTableOneTable(out,acl,fcl,bcl,classHeader,sectionTOP,
		outmessage)) return false;
	}
	return true;
}

/**********************************************************************
 * Create a series of time tables, one for each manually selected     *
 * group of trains. This private method loops over the set of manually*
 * selected group of trains.                                          *
 **********************************************************************/

bool TimeTableSystem::MakeTimeTableGroupManually(ostream &out,int maxTrains,
						 TrainList &allTrains,
						 TrainList &forwardTrains,
						 TrainList &backwardTrains,
						 char **outmessage)
{
	static  char buffer[2048];	// Error message buffer
	int igroup;			// Group index
	// Loop over groups until all trains have been printed.
	for (igroup = 1; allTrains.size() > 0; igroup++) {
	  StringList listOfTrains;	// List of train numbers in this group.
	  // Get class header
	  sprintf(buffer,"Group,%d,ClassHeader",igroup);
	  string classHeader = GetPrintOption(buffer);
	  if (classHeader == "") {
	    sprintf(buffer,"Class %d trains",igroup);
	    classHeader = buffer;
	  }
	  // Get user content for this group.
	  sprintf(buffer,"Group,%d,SectionTOP",igroup);
	  string sectionTOP = GetPrintOption(buffer);
	  // Get list of train numbers in this group.
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
	  // If we have exhausted the groups but have not printed all trains
	  // report a problem.
	  if (listOfTrains.size() == 0 && allTrains.size() > 0) {
	    if (outmessage != NULL) {
	      sprintf(buffer,"\"Group,%d,Trains\" print option is empty, but there are remaining trains!",
	      	      igroup);
	      *outmessage = new char[strlen(buffer)+1];
	      strcpy(*outmessage,buffer);
	    }
	    return false;
	  }
	  // Collect trains for this group.
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
	  // Print out this group of trains.
	  if (!MakeTimeTableOneTable(out,acl,fcl,bcl,classHeader,sectionTOP,
				     outmessage)) return false;
	}
	return true;
}

/**********************************************************************
 * Create one time table, given a list of trains.                     *
 * If there are only forward moving trains (typical of loop layouts)  *
 * generate a table with stations listed in the left column, otherwise*
 * generate a table with the stations in the center column.           *
 **********************************************************************/

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

/**********************************************************************
 * Make a table with the stations listed on the left (all trains      *
 * in a single (logical) direction).                                  *
 **********************************************************************/

bool TimeTableSystem::MakeTimeTableOneTableStationsLeft(ostream &out,
							TrainList &trains,
							string header,
							string sectionTOP,
							char **outmessage)
{
	//static  char buffer[2048];		// Error message buffer.
	TrainTimesAtStation timesAtStations;	// Time cells.
	ComputeTimes(timesAtStations,trains);	// Compute time cells.
	TrainList::const_iterator tr;		// Train iterator
	int ntrains = trains.size();		// Number of trains.
	int itr,inote,numnotes,istation,numstations; // Other local variables.

	// Start on a fresh page.
	out <<  backslash << "clearpage" << endl;
	// Output section header.
	out <<  backslash << "section*{" << header << "}" << endl;
	// Include TOC information.
	if (TOCP) {
	  out <<  backslash << "addcontentsline{toc}{section}{" << header << "}" << endl;
	  for (tr = trains.begin(); tr != trains.end(); tr++) {
	    out <<  backslash << "addcontentsline{toc}{subsection}{" << (*tr)->Number()
		<< "}" << endl;
	  }
	}
	// Output user content.
	out << sectionTOP << endl;
	// The table will be generated as a supertabular environment.
	out << endl <<  backslash << "begin{supertabular}{|r|p{" << backslash << "stationwidth}|";
	for (itr = 0; itr < ntrains; itr++) {
	  out << "r|";
	}
	out << "}" << endl;
	out <<  backslash << "hline" << endl;
	// Column headings.
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
	// Second line of column headings.
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
	// Third line of column headings.
	out << "Mile&Station&" << backslash << "multicolumn{" << ntrains
	    << "}{|c|}{" << DirectionName << " (Read Down)}" << backslash 
	    <<  backslash <<  endl;
	out <<  backslash << "hline" << endl;
	// Output 3 rows for each station (even ones where no trains stop).
	numstations = NumberOfStations();
	for (istation = 0; istation < numstations; istation++) {
	  // Three rows per station:
	  //    station name AR | train1 arrival/track | train2 arrival/track | ... trainN arrival/track |
	  //    scale mile      | train1 cab+notes     | train2 cab+notes     | ... trainN cab+notes     |
	  //                 LV | train1 depart/track  | train2 depart/track  | ... trainN depart/track  |
	  // Station column.
	  TrainTimesAtStation::const_iterator tas =
		timesAtStations.find(istation);
	  if (tas == timesAtStations.end()) continue;
	  const Station *station = IthStation(istation);
	  double smile = station->SMile();
	  // Train Arival time row
	  // Station name and AR in station column.
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
	  // Train Cab and notes row
	  // Scale Mile in station column.
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
	  // Train departure times.
	  // LV in station column.
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

/**********************************************************************
 * Make a table with the stations listed in the center. Traffic is    *
 * bidirectional, with forward traveling trains on the left and       *
 * reverse traveling trains on the right.                             *
 **********************************************************************/

bool TimeTableSystem::MakeTimeTableOneTableStationsCenter(ostream &out,
							  TrainList &forwardTrains,
							  TrainList &backwardTrains,
							  string header,
							  string sectionTOP,
							  char **outmessage)
{
	//static  char buffer[2048];		// Error buffer
	string rev;				// Reverse direction.
	if (DirectionName == "Northbound") rev = "Southbound";
	else if (DirectionName == "Southbound") rev = "Northbound";
	else if (DirectionName == "Eastbound") rev = "Westbound";
	else if (DirectionName == "Westbound") rev = "Eastbound";
	// Time cell matrixes
	TrainTimesAtStation timesAtStationsForward,timesAtStationsBackward;
	ComputeTimes(timesAtStationsForward,forwardTrains);
	ComputeTimes(timesAtStationsBackward,backwardTrains);
	// Train iterator.
	TrainList::const_iterator tr;
	// Numbers of trains.
	int nFtrains = forwardTrains.size(), nBtrains = backwardTrains.size();
	int itr,inote,numnotes,istation,numstations;

        // Start on a fresh page.
	out <<  backslash << "clearpage" << endl;
        // Output section header.
	out <<  backslash << "section*{" << header << "}" << endl;
        // Include TOC information.
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
        // Output user content.
	out << sectionTOP << endl;
        // The table will be generated as a supertabular environment.
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
        // Column headings.
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
	// Second line of column headings.
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
	// Third line of column headings.
	out <<  backslash << "hline" << endl;
	out << backslash << "multicolumn{" << nFtrains<< "}{|c|}{"
	    << DirectionName << " (Read Down)}&Mile&Station&" << backslash 
	    << "multicolumn{" << nBtrains << "}{|c|}{" << rev 
	    << " (Read up)}" << backslash <<  backslash <<  endl;
	out <<  backslash << "hline" << endl;
	out <<  backslash << "hline" << endl;
	numstations = NumberOfStations();
	// Output 3 rows for each station (even ones where no trains stop).
	for (istation = 0; istation < numstations; istation++) {
	  // Three rows per station:
	  //    | train arrivals/tracks | AR station name LV | train departs/tracks  |
	  //    | train cabs+notes      |    scale mile      | train cabs+notes      |
	  //    | train departs/tracks  | LV              AR | train arrivals/tracks |
	  TrainTimesAtStation::const_iterator tasF =
		timesAtStationsForward.find(istation),
	    tasB = timesAtStationsBackward.find(istation);
	  if (tasF == timesAtStationsForward.end() &&
	      tasB == timesAtStationsBackward.end()) continue;
	  const Station *station = IthStation(istation);
	  double smile = station->SMile();
	  // Left side (forward train arrivals).
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
	  // Center (station name).
	  out << "&AR" << backslash << "hfill" << backslash << "parbox[t]{"
	      << backslash << "stationwidthtwoar}{" << station->Name() << "}"
	      << backslash << "hfill LV";
	  // Right side (backward trains).
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    out << "&";
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	    	(tasB->second).find(train->Number());
	    if (tst != (tasB->second).end()) {
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
	  // Second row: cabs and notes + scale miles.
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
	    if (tst != (tasB->second).end()) {
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
	  // Third row: departures / tracks.	  
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
	  out << "&LV" << backslash << "hfill AR";
	  for (tr = backwardTrains.begin(); tr != backwardTrains.end(); tr++) {
	    out << "&";
	    const Train *train = *tr;
	    TrainStationTimes::const_iterator tst =
	        (tasB->second).find(train->Number());
	    if (tst != (tasB->second).end()) {
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
	  out << backslash << "hline" << endl;
	}
	out <<  backslash << "end{supertabular}" << endl;
	out << endl;
	out <<  backslash << "vfill" << endl;
	out << endl;
	return true;
}

/**********************************************************************
 * Helper method to compute station times.                            *
 * Iterates over trains and then iterates over the stations the train *
 * passes or stops at.  For each stop of each train, fill in a cell in*
 * the TrainTimesAtStation matrix, with the arrival and departure     *
 * times.                                                             *
 **********************************************************************/

void TimeTableSystem::ComputeTimes(TrainTimesAtStation &timesAtStations,
				   TrainList &trains)
{
	int istop, i, nstops;
	double oldDepart,depart;
	double oldSmile,smile;
	double arrival,departure;
	int speed;
	TrainList::const_iterator tr;

	// Loop over trains...
	for (tr = trains.begin(); tr != trains.end(); tr++) {
	  const Train *train = *tr;
	  departure = train->Departure();
	  speed = train->Speed();
	  oldDepart = -1;
	  oldSmile =  -1;
	  nstops = train->NumberOfStops();
	  // Loop over stops...
	  for (i=0; i < nstops; i++) {
	    const Stop *stop = train->StopI(i);
	    istop = stop->StationIndex();
	    const Station *station = IthStation(istop);
	    smile = station->SMile();
	    // compute arrival and departure times.
	    if (oldDepart >= 0) {
	      // Travel time at speed from previous station.
	      arrival = oldDepart + (fabs(smile - oldSmile) * (speed / 60.0));
	    } else {
	      // Originating departure.
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
