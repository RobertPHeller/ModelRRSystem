/* 
 * ------------------------------------------------------------------
 * Train.h - Train class definitions
 * Created by Robert Heller on Wed Dec 21 23:36:04 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
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

#ifndef _TRAIN_H_
#define _TRAIN_H_

#ifndef SWIG
#include <Common.h>
#include <Cab.h>
class TimeTableSystem;
#endif

/** @name  Train and support classes.
    @doc  \TEX{\typeout{Generated from $Id$.}} */

//@{

#ifdef SWIG
#include <string.h>
%typemap(tcl8,in) Stop::FlagType {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	char *p = Tcl_GetString($source);
	if (p == NULL || strlen(p) < 1) {
	  Tcl_SetStringObj(tcl_result,"Missing FlagType, should be one of origin, terminate, or transit",-1);
	  return TCL_ERROR;
	} else if (strncasecmp("origin",p,strlen(p)) == 0) {
	  $target = Stop::Origin;
	} else if (strncasecmp("terminate",p,strlen(p)) == 0) {
	  $target = Stop::Terminate;
	} else if (strncasecmp("transit",p,strlen(p)) == 0) {
	  $target = Stop::Transit;
	} else {
	  Tcl_SetStringObj(tcl_result,"Bad FlagType, should be one of origin, terminate, or transit",-1);
	  return TCL_ERROR;
	}
#else
	Tcl_Obj * tcl_result = Tcl_GetObjResult(interp);
	char *p = Tcl_GetString($input);
	if (p == NULL || strlen(p) < 1) {
	  Tcl_SetStringObj(tcl_result,"Missing FlagType, should be one of origin, terminate, or transit",-1);
	  return TCL_ERROR;
	} else if (strncasecmp("origin",p,strlen(p)) == 0) {
	  $1 = Stop::Origin;
	} else if (strncasecmp("terminate",p,strlen(p)) == 0) {
	  $1 = Stop::Terminate;
	} else if (strncasecmp("transit",p,strlen(p)) == 0) {
	  $1 = Stop::Transit;
	} else {
	  Tcl_SetStringObj(tcl_result,"Bad FlagType, should be one of origin, terminate, or transit",-1);
	  return TCL_ERROR;
	}
#endif
}

%typemap(tcl8,out) Stop::FlagType {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
  tcl_result = Tcl_GetObjResult(interp);
  switch ($source) {
    case Stop::Origin: Tcl_SetStringObj(tcl_result,"Origin",-1); break;
    case Stop::Terminate: Tcl_SetStringObj(tcl_result,"Terminate",-1); break;
    case Stop::Transit: Tcl_SetStringObj(tcl_result,"Transit",-1); break;
  }
#else
  Tcl_Obj * tcl_result = $result;
  switch ($1) {
    case Stop::Origin: Tcl_SetStringObj(tcl_result,"Origin",-1); break;
    case Stop::Terminate: Tcl_SetStringObj(tcl_result,"Terminate",-1); break;
    case Stop::Transit: Tcl_SetStringObj(tcl_result,"Transit",-1); break;
  }
#endif
}

#endif

/// This class implements a stop.
class Stop {
public:
	/// Type of stop.
	enum FlagType {Origin, Terminate, Transit};
	/// Create a stop;
	Stop(int stationindex_= 0,FlagType flag_=Origin) {
		layover = 0;
		stationindex = stationindex_;
		flag = flag_;
		cab = NULL;
		storageTrackName = "";
	}
#ifndef SWIG
	/// Copy constructor.
	Stop(const Stop & other) {
		layover = other.layover;
		stationindex = other.stationindex;
		cab = other.cab;
		notes = other.notes;
		flag = other.flag;
		storageTrackName = other.storageTrackName;
	}
	/// Copy constructor.
	Stop & operator= (const Stop & other) {
		layover = other.layover;
		stationindex = other.stationindex;
		cab = other.cab;
		notes = other.notes;
		flag = other.flag;
		storageTrackName = other.storageTrackName;
		return *this;
	}
#endif
	/// Cleanup.
	~Stop() {}
	/// Return layover period.
	double Layover() const {return layover;}
	/// Update layover period.
	void SetLayover(double period) {layover = period;}
	/// Return departure time;
	double Departure(double arrival) const {return arrival+layover;}
	/// Return the station.
	int StationIndex() const {return stationindex;}
	/// Return the cab.
	Cab *TheCab() const {return cab;}
	/// Update the cab.
	void SetCab(Cab *newcab) {cab = newcab;}
	/// Return the number of notes.
	int NumberOfNotes() const {return notes.size();}
	/// Return the ith note;
	int Note(int i) const {
		if (i < 0 || i >= notes.size()) return -1;
		else return notes[i];
	}
	/// Add a note.
	void AddNote(int note) {
		int i;
		for (i = 0; i < notes.size(); i++) {
			if (notes[i] == note) return;
		}
		notes.push_back(note);
	}
	/// Remove note.
	void RemoveNote(int note) {
		vector<int>::iterator ix;
		for (ix = notes.begin();ix != notes.end(); ix++) {
			if (*ix == note) {
				notes.erase(ix);
				return;
			}
		}
		return;
	}
	/// Return the flag.
	FlagType Flag() const {return flag;}
	/// Return storage track name;
	const char *StorageTrackName() const {return storageTrackName.c_str();}
#ifdef SWIG
	void SetStorageTrackName(const char *name);
#else
	/// Update storage track name.
	void SetStorageTrackName(string name) {storageTrackName = name;}
#endif	
#ifndef SWIG
	ostream & Write(ostream & stream) const;
	istream & Read(istream & stream,const CabNameMap cabs);
private:
	double layover;
	int stationindex;
	Cab *cab;
	vector<int> notes;
	FlagType flag;
	string storageTrackName;
#endif
};

#ifndef SWIG
/// A vector of stops.
typedef vector<Stop> StopVector;
#endif


/// This class implements a train.
class Train {
public:
#ifdef SWIG
	Train(TimeTableSystem *timetable = NULL,const char *name = "",
		const char *number = "",int speed = 0,
		int classnumber = 0,
	      int departure = 0,
		int start=0, int end=-1);
#else
	/// Create a train.
	Train(TimeTableSystem *timetable = NULL,string name = "",
		string number = "", int speed = 0,
		int classnumber = 0,
	        int departure = 0,
		int start=0, int end=-1);
#endif
	/// Return the name of the train.
	const char *Name() const {return name.c_str();}
	/// Return the number of the train.
	const char *Number() const {return number.c_str();}
	/// Return the departure time.
	int Departure() const {return departure;}
	/// Update departure departure.
	void SetDeparture(int depart) {departure = depart;}
	/// Return the train's speed.
	int Speed() const {return speed;}
	/// Return the class number.
	int ClassNumber() const {return classnumber;}
	/// Number of notes.
	int NumberOfNotes() const {return notes.size();}
	/// Return the ith note.
	int Note(int i) const {
		if (i < 0 || i >= notes.size()) return  -1;
		else return notes[i];
	}
	/// Add a note.
	void AddNoteToTrain(int note) {
		int i;
		for (i = 0; i < notes.size(); i++) {
			if (notes[i] == note) return;
		}
		notes.push_back(note);
	}
	/// Remove a note.
	void RemoveNoteFromTrain(int note) {
		vector<int>::iterator ix;
		for (ix = notes.begin();ix != notes.end(); ix++) {
			if (*ix == note) {
				notes.erase(ix);
				return;
			}
		}
	}
	/// Update stop layover.
	void UpdateStopLayover(int istop,double layover);
	/// Update the cab.
	void UpdateStopCab(int istop,Cab *cab);
	/// Add a note to a stop.
	void AddNoteToStop(int istop,int note);
	/// Remove a note from a stop.
	void RemoveNoteFromStop(int istop,int note);
#ifdef SWIG
	void SetOriginStorageTrack(const char *trackname);
#else
	/// Set the origin storage track.
	void SetOriginStorageTrack(string trackname);
#endif
#ifdef SWIG
	void SetDestinationStorageTrack(const char *trackname);
#else
	/// Set the destination storage track.
	void SetDestinationStorageTrack(string trackname);
#endif
#ifdef SWIG
	void SetTransitStorageTrack(int istop,const char *trackname);
#else
	/// Set an intermediate storage track.
	void SetTransitStorageTrack(int istop,string trackname);
#endif
	/// Return the number of stops.
	int NumberOfStops() const {return stops.size();}
	/// Return the ith stop.
	const Stop *StopI(int i) const {
		if (i < 0 || i >= stops.size()) return NULL;
		else return &stops[i];
	}
	/// Return the start SMile.
	double StartSMile() const {return startSMile;}
#ifndef SWIG
	ostream & Write(ostream & stream) const;
	istream & Read(istream & stream,const CabNameMap cabs);
private:
	/// Name of the train.
	string name;
	/// Number or symbol of the train;
	string number;
	/// The train's speed.
	int speed;
	/// The train's class.
	int classnumber;
	/// Notes about the train.
	vector<int> notes;
	/// Departure time.
	int departure;
	/// The train's stops.
	StopVector stops;
	/// Start smile.
	double startSMile;
#endif
};

#ifdef SWIG

%apply int MyTcl_Result { int ForEveryStop };

int ForEveryStop (Tcl_Interp *interp,Train *train,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);

%{
int ForEveryStop (Tcl_Interp *interp,Train *train,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	int istop;

	for (istop = 0; istop < train->NumberOfStops(); istop++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	  valuePtr = Tcl_NewObj();
	  SWIG_SetPointerObj(valuePtr,(void *) train->StopI(istop),"_Stop_p");
#else
	  valuePtr = SWIG_NewInstanceObj((void *) train->StopI(istop), SWIGTYPE_p_Stop,0);
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
	      sprintf(msg, "\n    (\"ForEveryStop\" body line %d)",
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

#endif

#ifndef SWIG
/// Train number map.
typedef map<string, Train *, less<string> > TrainNumberMap;
#endif

//@}
	                    
#endif // _TRAIN_H_

