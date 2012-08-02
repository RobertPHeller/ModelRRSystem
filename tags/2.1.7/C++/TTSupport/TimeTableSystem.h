/* 
 * ------------------------------------------------------------------
 * TimeTableSystem.h - Time Table System class definition
 * Created by Robert Heller on Mon Dec 19 21:01:00 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.4  2006/05/18 17:03:24  heller
 * Modification History: CentOS 4.3 updates
 * Modification History:
 * Modification History: Revision 1.3  2006/05/17 23:42:37  heller
 * Modification History: May 17, 2006 Lock down
 * Modification History:
 * Modification History: Revision 1.2  2006/05/16 19:27:46  heller
 * Modification History: May162006 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
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

#ifndef _TIMETABLESYSTEM_H_
#define _TIMETABLESYSTEM_H_

#ifndef SWIG
#include <Common.h>
#include <PathName.h>
#include <Station.h>
#include <Cab.h>
#include <Train.h>
#include <list>

#ifdef __GNUC__
#if __GNUC__ < 3
#include <hash_map.h>
        namespace Sgi { using ::hash_map; }; // inherit globals
#else
#include <ext/hash_map>
#if __GNUC_MINOR__ == 0
          namespace Sgi = std;               // GCC 3.0
#else
          namespace Sgi = ::__gnu_cxx;       // GCC 3.1 and later
#endif
#endif
#else      // ...  there are other compilers, right?
        namespace Sgi = std;
#endif


/** @name  Main Time Table class and support types.
    @doc  \TEX{\typeout{Generated from $Id$.}} */

//@{

/**  A Vector of doubles.  Used as a vector of layover times. */
typedef vector<double> doubleVector;

/** Equality structure.  Used with the hash map used for Print Options */
struct eqstr
{
	bool operator()(const char* s1, const char* s2) const
	{
		return strcmp(s1, s2) == 0;
	}
};

/** Option hash map, used for Print options. */
typedef Sgi::hash_map<const char*, string/*, hash<const char*>, eqstr*/> OptionHashMap;


/** List of trains. */
typedef list<Train*> TrainList;

/** Station times class, used by the \TEX{\LaTeX\ } generator method.*/
class StationTimes {
public:
	/** Constructor. */
	StationTimes(double a=-1,double d=-1,Stop::FlagType f=Stop::Transit) {
		arrival = a;
		departure = d;
		flag = f;
	}
	/** Copy constructor. */
	StationTimes(const StationTimes &other) {
		arrival = other.arrival;
		departure = other.departure;
		flag = other.flag;
	}
	/** Assignment operator. */
	StationTimes &operator= (const StationTimes &other) {
		arrival = other.arrival;
		departure = other.departure;
		flag = other.flag;
		return *this;
	}
	/// Access the arrival time.
	double Arrival() const {return arrival;}
	/// Access the departure time.
	double Departure() const {return departure;}
	/// Access the type of stop flag.
	Stop::FlagType Flag() const {return flag;}
private:
	/// The arrival time.
	double arrival;
	/// The departure time.
	double departure;
	/// The stop flag.
	Stop::FlagType flag;
};

/// Map of station times, indexed by train number.
typedef map<string,StationTimes,less<string> > TrainStationTimes;
/// Map of maps of station times, indexed by station index.
typedef map<int,TrainStationTimes,less<int> > TrainTimesAtStation;

/// List of strings.
typedef list<string> StringList;

/** Convert a list of strings to a flat string. */
const char *StringListToString(const StringList &list);

/** Convert a flat string to a list of strings. */
bool StringListFromString(string strlinList,StringList &result);

#endif


#ifdef SWIG
/*
 * Type map to handle error messages.  Hide this parameter from Tcl, but return
 * it as a second result, returning TCL_ERROR, if there is an error message.
 */

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%typemap(tcl8,ignore) char **outmessage {
	$target = new char*;
	*$target = NULL;
}
#else
%typemap(tcl8,in,numinputs=0) char **outmessage {
	$1 = new char*;
	*$1 = NULL;
}
#endif

%typemap(tcl8,argout) char **outmessage {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	if (*$source != NULL) {
		int mlen = strlen(*$source);
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewStringObj(*$source,mlen)) != TCL_OK) {
			delete *$source;
			delete $source;
			return TCL_ERROR;
		}
		delete *$source;
		delete $source;
		return TCL_ERROR;
	}
	delete $source;
#else
	Tcl_Obj * tcl_result = $result;
	if (*$1 != NULL) {
		int mlen = strlen(*$1);
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewStringObj(*$1,mlen)) != TCL_OK) {
			delete *$1;
			delete $1;
			return TCL_ERROR;
		}
		delete *$1;
		delete $1;
		return TCL_ERROR;
	}
	delete $1;
#endif
}

%typemap(tcl8,in) const doubleVector * {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	Tcl_Obj **objvPtr;
	int       objcPtr,i;
	double	  v;
	if (Tcl_ListObjGetElements(interp,$source,&objcPtr,&objvPtr) != TCL_OK)
		return(TCL_ERROR);
	$target = new doubleVector;
	for (i = 0; i < objcPtr; i++) {
		if (Tcl_GetDoubleFromObj(interp,objvPtr[i],&v) != TCL_OK) {
			if (strcmp(Tcl_GetString(objvPtr[i]),"-") != 0) {
				delete $target;
				return TCL_ERROR;
			}
			else v = 0.0;
		}
		$target->push_back(v);
	}
#else
	Tcl_Obj **objvPtr;
	int       objcPtr,i;
	double	  v;
	if (Tcl_ListObjGetElements(interp,$input,&objcPtr,&objvPtr) != TCL_OK)
		return(TCL_ERROR);
	$1 = new doubleVector;
	for (i = 0; i < objcPtr; i++) {
		if (Tcl_GetDoubleFromObj(interp,objvPtr[i],&v) != TCL_OK) {
			if (strcmp(Tcl_GetString(objvPtr[i]),"-") != 0) {
				delete $1;
				return TCL_ERROR;
			}
			else v = 0.0;
		}
		$1->push_back(v);
	}
#endif
}

%typemap(tcl8,freearg) const doubleVector * {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	delete $source;
#else
	delete $input;
#endif
}

%typemap(tcl8,in) const stringVector * {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	Tcl_Obj **objvPtr;
	int       objcPtr,i;
	if (Tcl_ListObjGetElements(interp,$source,&objcPtr,&objvPtr) != TCL_OK)
		return(TCL_ERROR);
	$target = new stringVector;
	for (i = 0; i < objcPtr; i++) {
		$target->push_back(string(Tcl_GetString(objvPtr[i])));
	}
#else
	Tcl_Obj **objvPtr;
	int       objcPtr,i;
	if (Tcl_ListObjGetElements(interp,$input,&objcPtr,&objvPtr) != TCL_OK)
		return(TCL_ERROR);
	$1 = new stringVector;
	for (i = 0; i < objcPtr; i++) {
		$1->push_back(string(Tcl_GetString(objvPtr[i])));
	}
#endif
}

%typemap(tcl8,freearg) const stringVector * {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	delete $source;
#else
	delete $input;
#endif
}

%apply int MyTcl_Result { int TimeTableSystem_TrainNumberList };
%apply int MyTcl_Result { int TimeTableSystem_CabNameList };


#endif
/**   \TEX{\typeout{Generated from $Id$}}
	This is the main Time Table Class.  It implements all of the basic data
	and algorithms used in the Time Table program.

	This class includes code to load one or more routes and the trains that
	run these routes.	
 */
class TimeTableSystem {
#ifndef SWIG
protected:
	/** The default constructor.  This is protected to prevent the
	  creation of an uninitialized class instance. */
	TimeTableSystem() {}
#endif
public:
#ifndef SWIG
	/** The constructor that creates a time table system from an existing
	  file.
	  @param filename The name of the file to load.
	  @param outmessage Pointer to a pointer to receive any error messages
		for any errors that might occur.*/
	TimeTableSystem(string filename,char **outmessage = NULL);
	/** The constructor that creates a new, empty time table system from
	  stratch.
	  @param name_ The name of the time table system.
	  @param timescale Number of time units per 24 hours.  There are
	  	1440 minutes in 24 hours.
	  @param timeinterval The tick frequency in time units.
	 */
	TimeTableSystem(string name,int timescale,int timeinterval);
#endif
	/** Destructor. */
	~TimeTableSystem();
#ifdef SWIG
	int AddStation(const char *name,double smile);
#else
	/** Add a new station to the system.
	  @param name The name of the station.
	 */
	int AddStation(string name,double smile);
#endif
#ifdef SWIG
	int FindStationByName(const char *name);
#else
	/** Find a station by name.
	  @param name The name of the station.
	 */
	int FindStationByName(string name);
#endif
	/// Number of stations.
	int NumberOfStations() const {return stations.size();}
	/// Return station object.
	Station *IthStation(int i) {
		if (i < 0 || i >= stations.size()) return NULL;
		else return &(stations[i]);
	}
	/// Return the Ith station name.
	const char *StationName(int i) const {
		if (i < 0 || i >= stations.size()) return NULL;
		else return stations[i].Name();
	}
	double SMile(int i) const {
		if (i < 0 || i >= stations.size()) return -1.0;
		else return stations[i].SMile();
	}
	double TotalLength() const {
		if (stations.size() == 0) return 0.0;
		else return stations[stations.size()-1].SMile();
	}
	int DuplicateStationIndex(int i) const {
		if (i < 0 || i >= stations.size()) return -1;
		else return stations[i].DuplicateStationIndex();
	}
	void SetDuplicateStationIndex(int i,int dup) {
		if (i < 0 || i >= stations.size()) return;
		else stations[i].SetDuplicateStationIndex(dup);
	}
#ifdef SWIG
	StorageTrack *AddStorageTrack(int i,const char *name);
#else
	StorageTrack *AddStorageTrack(int i,string name) {
		if (i < 0 || i >= stations.size()) return NULL;
		else return stations[i].AddStorageTrack(name);
	}
#endif
#ifdef SWIG
	StorageTrack *FindStorageTrack(int i,const char *name);
#else
	StorageTrack *FindStorageTrack(int i,string name) {
		if (i < 0 || i >= stations.size()) return NULL;
		else return stations[i].FindStorageTrack(name);
	}
#endif
#ifdef SWIG
	Cab *AddCab(const char *name, const char *color);
#else
	/** Add a new cab to the system.
	   @param name The name of the cab.
	   @param color The color of the cab.
	 */
	Cab *AddCab(string name, string color);
#endif
	/// The nymber of cabs.
	int NumberOfCabs() const {return cabs.size();}
#ifdef SWIG
	Train *AddTrain(const char *name, const char *number, int speed,
			int classnumber,int departure,
			int start=0,int end=-1);
#else
	/** Add a train to the system.
	   @param name The name of the train.
	   @param number The number (or symbol) of the train.
	   @param speed The trains maximum speed.
	   @param classnumber The class (inverse priority) of the train.
	   @param start The train's origin station index.
	   @param end The train's destination station index.
	 */
	Train *AddTrain(string name, string number, int speed, int classnumber,
			int departure,
			int start=0,int end=-1);
#endif
#ifdef SWIG
	Train *AddTrainLongVersion(const char *name, const char *number,
				   int speed, int classnumber,int departure,
				   int start,int end,
				   const doubleVector layoverVector,
				   const stringVector cabnameVector,
				   const stringVector storageTrackVector,
				   char **outmessage = NULL);
				   
#else
	/** Add a train to the system, long version (includes storage track
	 checking).
	  @param name The name of the train.
	  @param number The number (or symbol) of the train.
	  @param speed The trains maximum speed.
	  @param classnumber The class (inverse priority) of the train.
	  @param start The train's origin station index.
	  @param end The train's destination station index.
	  @param layoverVector The train's layover vector.
	  @param cabnameVector The train's departure cab name vector.
	  @param storageTrackVector The train's storage track name vector.
	  @param outmessage Pointer to a pointer to receive any error messages
	  	for any errors that might occur.
	 */
	Train *AddTrainLongVersion(string name, string number, int speed,
				   int classnumber,int departure,
				   int start,int end,
				   const doubleVector layoverVector,
				   const stringVector cabnameVector,
				   const stringVector storageTrackVector,
				   char **outmessage = NULL);
#endif
#ifdef SWIG
	bool DeleteTrain(const char *number,char **outmessage=NULL);
#else
	/**
	  Delete a train.
	  @param number The train number or symbol.
	  @param outmessage Pointer to a pointer to receive any error messages
	  	for any errors that might occur.
	 */
	bool DeleteTrain(string number,char **outmessage=NULL);
#endif
#ifdef SWIG
	Cab *FindCab(const char *name) const;
#else
	/** Find a cab (by name).
	   @param name The cab name to look for.
	 */
	Cab *FindCab(string name) const;
#endif
#ifdef SWIG
	Train *FindTrainByName(const char *name) const;
#else
	/** Find a train by name.
	   @param name The train name to look for.
	 */
	Train *FindTrainByName(string name) const;
#endif
#ifdef SWIG
	Train *FindTrainByNumber(const char *number) const;
#else
	/** Find a train by number (or symbol).
	   @param number The train number (or symbol) to look for.
	 */
	Train *FindTrainByNumber(string number) const;
#endif
	/// Return the number of trains.
	int NumberOfTrains() const {return trains.size();}
	/// Return the number of notes.
	int NumberOfNotes() const {return notes.size();}
	/// Return the ith notes (1-based!).
	const char *Note(int i) {
		if (i <= 0 || i > notes.size()) return NULL;
		else return notes[i-1].c_str();
	}
#ifdef SWIG
	int AddNote(const char *newnote);
#else
	/// Add a note.
	int AddNote(string newnote) {
		notes.push_back(newnote);
		return notes.size();
	}
#endif	
#ifdef SWIG
	bool SetNote(int i,const char *note);
#else
	/// Set the ith note (1-based!).
	bool SetNote(int i,string note) {
		if (i <= 0 || i > notes.size()) return false;
		else {
			notes[i-1] = note;
			return true;
		}
	}
#endif	
	/// Fetch a print option.
	const char *GetPrintOption(const char *key) const
	{
		OptionHashMap::const_iterator element = printOptions.find(key);
		if (element == printOptions.end()) return "";
		else return (element->second).c_str();
	}
#ifdef SWIG
	void SetPrintOption(const char *key,const char *value);
#else
	/// Set a print option;
	void SetPrintOption(const char *key,string value)
	{
		OptionHashMap::iterator element = printOptions.find(key);
		if (element == printOptions.end()) {
		  char *localKey = new char[strlen(key)+1];
		  strcpy(localKey,key);
		  printOptions[localKey] = value;
		} else {
		  element->second = value;
		}
	}
#endif
#ifdef SWIG
	bool WriteNewTimeTableFile(const char *filename = "",
				bool setfilename = false,
				char **outmessage = NULL);
#else
	/** Write out a Time Table System to a file.
	  @param filename_ The name of the file to write (if empty, use
		existing name, if available).
	  @param setfilename Change the filename if true.
	  @param outmessage Pointer to a pointer to receive any error messages
		for any errors that might occur.*/
	bool WriteNewTimeTableFile(string filename = "TimeTableFile.tt",
				bool setfilename = false,
				char **outmessage = NULL);
#endif
	/// Write an old time table file.
	bool WriteOldTimeTableFile(char **outmessage = NULL) {
		return WriteNewTimeTableFile(filepath.FullPath(),false,
					     outmessage);
	}
	/** Return time scale. */
	int TimeScale() const {return timescale;}
	/** Return time interval. */
	int TimeInterval() const {return timeinterval;}
	/** Return the name of the system. */
	const char * Name() const {return name.c_str();}
	/** Return file pathname. */
	const char * Filename() const {return filepath.FullPath().c_str();}
#ifdef SWIG
	bool CreateLaTeXTimetable(const char *filename_,
				  char **outmessage = NULL);
#else
	/** Create a LaTeX file for generating a (hard copy) Employee Timetable.
	  @param filename_ The name of the  LaTeXfile to create.
	  @param outmessage Pointer to a pointer to receive any error messages
	  	 for any errors that might occur.*/
	bool CreateLaTeXTimetable(string filename_,char **outmessage = NULL);
#endif
#ifdef SWIG
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	%addmethods 
#else
	%extend 
#endif
		{
		int CabNameList (Tcl_Interp *interp) {
			CabNameMap::const_iterator Sx;
			string indx;
			Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
			for (Sx = self->FirstCab(); Sx != self->LastCab(); Sx++) {
				if (Sx->second == NULL) continue;
				indx = Sx->first;
				if (Tcl_ListObjAppendElement(interp,tcl_result,
								Tcl_NewStringObj(indx.c_str(),-1))
					!= TCL_OK) return TCL_ERROR;
			}
			Tcl_SetObjResult(interp,tcl_result);
			return TCL_OK;
		}
		int TrainNumberList (Tcl_Interp *interp) {
			TrainNumberMap::const_iterator Sx;
			string indx;
			Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
			for (Sx = self->FirstTrain(); Sx != self->LastTrain(); Sx++) {
				if (Sx->second == NULL) continue;
				indx = Sx->first;
				if (Tcl_ListObjAppendElement(interp,tcl_result,
								Tcl_NewStringObj(indx.c_str(),-1))
					!= TCL_OK) return TCL_ERROR;
			}
			Tcl_SetObjResult(interp,tcl_result);
			return TCL_OK;
		}
	}
#else
	/// First cab.
	CabNameMap::const_iterator FirstCab() const {
		return cabs.begin();
	}
	/// Last cab.
	CabNameMap::const_iterator LastCab() const {
		return cabs.end();
	}
	/// First train.
	TrainNumberMap::const_iterator FirstTrain() const {
		return trains.begin();
	}
	/// Last train.
	TrainNumberMap::const_iterator LastTrain() const {
		return trains.end();
	}
	/// First Print option.
	OptionHashMap::const_iterator FirstPrintOption() const {
		return printOptions.begin();
	}
	/// Last Print option.
	OptionHashMap::const_iterator LastPrintOption() const {
		return printOptions.end();
	}
private:
	/// Read in a note.
	string ReadNote(istream &in) const;
	/// Write out a note.
	ostream & WriteNote(ostream &out,string note) const;
	/// Make a time table grouped by class.
	bool MakeTimeTableGroupByClass(ostream &out,TrainList &allTrains,
				       TrainList &forwardTrains,
				       TrainList &backwardTrains,
				       char **outmessage = NULL);
	/// Make a time table grouped manually.
	bool MakeTimeTableGroupManually(ostream &out,int maxTrains,
					TrainList &allTrains,
				        TrainList &forwardTrains,
				        TrainList &backwardTrains,
					char **outmessage = NULL);
	/// Make a time table as a single table.
	bool MakeTimeTableOneTable(ostream &out,TrainList &allTrains,
				   TrainList &forwardTrains,
				   TrainList &backwardTrains,
				   string header,string sectionTOP,
				   char **outmessage = NULL);
	/** Make a time table as a single table, with the stations on the
	    left (single direction trains). */
	bool MakeTimeTableOneTableStationsLeft(ostream &out,TrainList &trains,
					       string header,string sectionTOP,
					       char **outmessage = NULL);
	/** Make a time table as a single table, with the stations in the
	    center (bi-directional trains). */
	bool MakeTimeTableOneTableStationsCenter(ostream &out,
						 TrainList &forwardTrains,
						 TrainList &backwardTrains,
						 string header,
						 string sectionTOP,
						 char **outmessage = NULL);
	/// Precompute station times, given a list of trains.
	void ComputeTimes(TrainTimesAtStation &timesAtStations,
			  TrainList &trains);
	/// The name of the time table system.
	string name;
	/// The pathname of the file the system was loaded from.
	PathName filepath;
	/// Time scale.
	int timescale;
	/// Time interval.
	int timeinterval;
	/// Station stop vector.
	StationVector stations;
	/// Cap name map.
	CabNameMap cabs;
	/// Train number/symbol map.
	TrainNumberMap trains;
	/// Notes.
	vector<string> notes;
	/// Print option hash table.
	OptionHashMap printOptions;
	/// Table Of Contents?	Used by print functions.
	bool TOCP;
	/// Direction Name.  Used by print functions.
	string DirectionName;
#endif	
};

#ifdef SWIG

TimeTableSystem *NewCreateTimeTable(const char *name,int timescale,int timeinterval);
TimeTableSystem *OldCreateTimeTable(const char *filename,char **outmessage = NULL);

%{
static TimeTableSystem *NewCreateTimeTable(const char *name,int timescale,int timeinterval)
{
	return new TimeTableSystem(name,timescale,timeinterval);
}
static TimeTableSystem *OldCreateTimeTable(const char *filename,char **outmessage = NULL)
{
	return new TimeTableSystem(filename,outmessage);
}
%}

%apply int MyTcl_Result { int ForEveryStation };
%apply int MyTcl_Result { int ForEveryCab };
%apply int MyTcl_Result { int ForEveryTrain };
%apply int MyTcl_Result { int ForEveryNote };
%apply int MyTcl_Result { int ForEveryPrintOption };

int ForEveryStation(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);
int ForEveryCab(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);
int ForEveryTrain(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);
int ForEveryNote(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);
int ForEveryPrintOption(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);


%{
	
static int ForEveryStation(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	int istation;

	for (istation = 0; istation < timetable->NumberOfStations(); istation++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	  valuePtr = Tcl_NewObj();
	  SWIG_SetPointerObj(valuePtr,(void *) timetable->IthStation(istation),"_Station_p");
#else
	  valuePtr = SWIG_NewInstanceObj((void *) timetable->IthStation(istation),
					SWIGTYPE_p_Station,0);
#endif	  
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryStation\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryCab(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	CabNameMap::const_iterator Cx;

	for (Cx = timetable->FirstCab();Cx != timetable->LastCab(); Cx++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	  valuePtr = Tcl_NewObj();
	  SWIG_SetPointerObj(valuePtr,(void *) Cx->second,"_Cab_p");
#else
	  valuePtr = SWIG_NewInstanceObj((void *) Cx->second, SWIGTYPE_p_Cab,0);
#endif
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryCab\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryTrain(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	TrainNumberMap::const_iterator Tx;

	for (Tx = timetable->FirstTrain();Tx != timetable->LastTrain(); Tx++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	  valuePtr = Tcl_NewObj();
	  SWIG_SetPointerObj(valuePtr,(void *) Tx->second,"_Train_p");
#else
	  valuePtr = SWIG_NewInstanceObj((void *) Tx->second, SWIGTYPE_p_Train,0);
#endif
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryTrain\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryNote(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	int inote;

	for (inote = 0; inote < timetable->NumberOfNotes(); inote++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = Tcl_NewStringObj(timetable->Note(inote),-1);
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryNote\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryPrintOption(Tcl_Interp *interp,TimeTableSystem *timetable,
			Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	OptionHashMap::const_iterator Ox;

	for (Ox = timetable->FirstPrintOption();Ox != timetable->LastPrintOption(); Ox++) {
#ifdef DEBUG
	  cerr << "*** ForEveryPrintOption: Ox->first = '" << Ox->first << "', Ox->second = '" << Ox->second << "'" << endl;
#endif
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = Tcl_NewStringObj(Ox->first,-1);
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryPrintOption\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

%}

%apply int MyTcl_Result { int TT_ListToStringListString };

int TT_ListToStringListString(Tcl_Interp *interp,Tcl_Obj *list);

%{

static int TT_ListToStringListString(Tcl_Interp *interp,Tcl_Obj *list)
{
	int objc,iobj;
	Tcl_Obj **objv;
	StringList sl;
	int status = Tcl_ListObjGetElements(interp,list,&objc,&objv);
	if (status != TCL_OK) return status;
	for (iobj = 0; iobj < objc; iobj++) {
	  sl.push_back(Tcl_GetStringFromObj(objv[iobj],NULL));
	}
	string result = StringListToString(sl);
	Tcl_Obj *resultObj = Tcl_NewStringObj(result.c_str(),-1);
	Tcl_SetObjResult(interp,resultObj);
	return TCL_OK;	
}

%}

%apply int MyTcl_Result { int TT_StringListToList }

int TT_StringListToList(Tcl_Interp *interp,const char *stringList);

%{
static int TT_StringListToList(Tcl_Interp *interp,const char *stringList)
{
	StringList slist;
	StringList::const_iterator Sx;
	if (StringListFromString(stringList,slist)) {
	  Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
	  for (Sx = slist.begin(); Sx != slist.end(); Sx++) {
	    if (Tcl_ListObjAppendElement(interp,tcl_result,
	    				 Tcl_NewStringObj((*Sx).c_str(),-1))
	    	  != TCL_OK) return TCL_ERROR;
	  }
	  Tcl_SetObjResult(interp,tcl_result);
	  return TCL_OK;
	} else {
	  Tcl_ResetResult(interp);
	  Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
				 "Syntax error in string List: ",
				 stringList,NULL);
	  return TCL_ERROR;
	}
}
%}

#endif

//@}
	                    
#endif // _TIMETABLESYSTEM_H_

