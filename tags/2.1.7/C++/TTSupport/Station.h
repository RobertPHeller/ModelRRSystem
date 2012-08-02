/* 
 * ------------------------------------------------------------------
 * Station.h - Station class declaration.
 * Created by Robert Heller on Tue Dec 20 21:06:49 2005
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
#ifndef _STATION_H_
#define _STATION_H_

#ifndef SWIG
#include <Common.h>
#include <iostream>
#include <fstream>
#endif

/** @name  Station and support classes.
    @doc  \TEX{\typeout{Generated from $Id$.}} */

//@{

#ifdef SWIG
%apply int MyTcl_Result { int Station_StorageTrackNameList };
#endif

/// Train occupies a storage track.
class Occupied {
public:
#ifdef SWIG
	Occupied(const char * trainnum_="",double from_=0.0,double until_=0.0,const char * trainnum2__ = "");
#else
	/// Construct an occupied instance.
	Occupied(string trainnum_="",double from_=0.0,double until_=0.0,string trainnum2_ = "") {
		trainnum = trainnum_;
		from  = from_;
		until = until_;
		trainnum2 = trainnum2_;
	}
#endif
	/// Return the train that arrives.
	const char *TrainNum() const {return trainnum.c_str();}
	/// Return the train that departs.
	const char  *TrainNum2() const {return trainnum2.c_str();}
	/// Return the start time;
	double From() const {return from;}
	/// Return the end time.
	double Until() const {return until;}
#ifndef SWIG
	/// Copy an Occupied instance.
	Occupied(const Occupied &other) {
		trainnum = other.trainnum;
		trainnum2 = other.trainnum2;
		from  = other.from;
		until = other.until;
	}
	/// Assignment operator.
	Occupied & operator= (const Occupied &other) {
		trainnum = other.trainnum;
		trainnum2 = other.trainnum2;
		from  = other.from;
		until = other.until;
		return *this;
	}
	friend class TimeTableSystem;
	ostream & Write(ostream & stream) const;
	istream & Read(istream & stream);
private:
	/// The train that arrived.
	string trainnum;
	/// The train that departs.
	string trainnum2;
	/// The start time of the occupation.
	double from;
	/// The end time of the occupation.
	double until;
#endif
};


#ifndef SWIG
/// A range of times.
class TimeRange {
public:
	/// Construct a time range.
	TimeRange(double from_ = 0.0, double to_ = 0.0) {
		from = from_;
		to = to_;
	}
	/// Return the low end of the range.
	double From () const {return from;}
	/// Return the high end of the range.
	double To () const {return to;}
	/// Does this interval contain the specified time.
	bool ContainsTime( double time ) const {
		return (time >= from && time <= to);
	}
	/// Less than operator.
	bool operator < (const TimeRange &other) const {
		return to <= other.from;
	}
	/// Greater than operator.
	bool operator > (const TimeRange &other) const {
		return from >= other.to;
	}
	/// Equal to operator.
	bool operator == (const TimeRange &other) const {
		return (to == other.to && from == other.from);
	}
	/// Less than or equal operator.
	bool operator <= (const TimeRange &other) const {
		return (*this < other || *this == other);
	}
	/// Greater than or equal operator.
	bool operator >= (const TimeRange &other) const {
		return (*this > other || *this == other);
	}
	/// Create a clone of a TimeRange.
	TimeRange (const TimeRange &other) {
		from = other.from;
		to   = other.to;
	}
	/// Assign a TimeRange to another TimeRange.
	TimeRange & operator= (const TimeRange &other) {
		from = other.from;
		to   = other.to;
		return *this;
	}
	ostream & Write(ostream & stream) const;
	istream & Read(istream & stream);
private:
	/// Start time.
	double from;
	/// End time.
	double to;
};

/// The Occupied Map type.
typedef map<TimeRange, Occupied, less<TimeRange> > OccupiedMap;
#endif


/// The StorageTrack class implements a storage track.
class StorageTrack {
public:
#ifdef SWIG
	StorageTrack(const char *name = "Track 0");
#else
	/// Construct a storage track.
	StorageTrack(string name_ = "Track 0") {
		name = name_;
	}
#endif
	~StorageTrack() {}
	/// Return the name of the storage track.
	const char *Name() const {return name.c_str();}
#ifdef SWIG
	void SetName(const char *name);
#else
	/// Set the storage track's name.
	void SetName(string name_) {
		name = name_;
	}
#endif
	/// Return the occupation that includes the specified time;
	const Occupied * IncludesTime(double time) const;
#ifdef SWIG
	const Occupied * StoreTrain (const char *train, double from, double to,const char *train2);
#else
	/// Insert train onto storage track for a time.
	const Occupied * StoreTrain (string train, double from, double to,string train2);
#endif
	/// Remove stored train.
	bool RemovedStoredTrain (double from, double to);
	/// Return true if the time range is in use.
	bool UsedTimeRange(double from, double to) const;
	/// Return occupication structure for a given time tange.
	const Occupied *FindOccupied(double from, double to) const {
		TimeRange range(from,to);
		OccupiedMap::const_iterator Ox = occupations.find(range);
		if (Ox == occupations.end()) return NULL;
		else return &(Ox->second);
	}
#ifdef SWIG
	const Occupied * UpdateStoredTrain(double from, double to,const char *train);
#else
	/// Replace a stored arrrival train.
	const Occupied * UpdateStoredTrain(double from, double to,string train);
#endif
#ifdef SWIG
	const Occupied * UpdateStoredTrain2(double from, double to,const char *train);
#else
	/// Replace a stored departure train.
	const Occupied * UpdateStoredTrain2(double from, double to,string train);
#endif
	/// Update a train's arrival time.
	const Occupied * UpdateStoredTrainArrival(double from, double to,
						  double newArrival);
	/// Update a train's departure time.
	const Occupied * UpdateStoredTrainDeparture(double from, double to,
						    double newDeparture);
#ifndef SWIG
	/// Clone a StorageTrack.
	StorageTrack(const StorageTrack& other) {
		name = other.name;
		OccupiedMap::const_iterator Ox;
		for (Ox = other.occupations.begin(); Ox != other.occupations.end(); Ox++) {
			occupations[Ox->first] = Ox->second;
		}
	}
	/// Assign a StorageTrack.
	StorageTrack &operator=(const StorageTrack& other) {
		name = other.name;
		OccupiedMap::const_iterator Ox;
		for (Ox = other.occupations.begin(); Ox != other.occupations.end(); Ox++) {
			occupations[Ox->first] = Ox->second;
		}
		return *this;
	}
	ostream & Write(ostream & stream) const;
	istream & Read(istream & stream);
	OccupiedMap::const_iterator FirstOccupied() const {return occupations.begin();}
	OccupiedMap::const_iterator LastOccupied() const {return occupations.end();}
private:
	/// Name of the storage track.
	string name;
	/// Map of occupations.
	OccupiedMap occupations;
#endif
};

#ifdef SWIG

%apply int MyTcl_Result { int ForEveryOccupied };

int ForEveryOccupied(Tcl_Interp *interp,StorageTrack *storageTrack,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);

%{
int ForEveryOccupied(Tcl_Interp *interp,StorageTrack *storageTrack,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	OccupiedMap::const_iterator Ox;

	for (Ox = storageTrack->FirstOccupied();Ox != storageTrack->LastOccupied(); Ox++) {
	  Tcl_Obj *valuePtr, *varValuePtr, *tempPtr, *rangeListPtr, *dobjPtr;
	  valuePtr = Tcl_NewObj();
	  rangeListPtr = Tcl_NewObj();
	  dobjPtr = Tcl_NewDoubleObj((Ox->first).From());
	  if (Tcl_ListObjAppendElement(interp,rangeListPtr,dobjPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
	  dobjPtr = Tcl_NewDoubleObj((Ox->first).To());
	  if (Tcl_ListObjAppendElement(interp,rangeListPtr,dobjPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
	  if (Tcl_ListObjAppendElement(interp,valuePtr,rangeListPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	  tempPtr = Tcl_NewObj();
	  SWIG_SetPointerObj(tempPtr,(void *) &(Ox->second),"_Occupied_p");
#else
	  tempPtr = SWIG_NewInstanceObj((void *) &(Ox->second),SWIGTYPE_p_Occupied,0);
#endif
	  if (Tcl_ListObjAppendElement(interp,valuePtr,tempPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
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
	      sprintf(msg, "\n    (\"ForEveryOccupied\" body line %d)",
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
/// Storage track map.
typedef map<string, StorageTrack, less<string> > StorageTrackMap;
#endif

/** The Station class implements a station. */
class Station {
public:
#ifdef SWIG
	Station(const char * name,double smile);
#else
	Station(string name_ = "Unknown",double smile_ = 0) {
		name = name_;
		smile = smile_;
		duplicateStationIndex = -1;
	}
	Station(const Station &other) {
		name = other.name;
		smile = other.smile;
		StorageTrackMap::const_iterator Sx;
		for (Sx = other.storageTracks.begin(); Sx != other.storageTracks.end(); Sx++) {
			storageTracks[Sx->first] = Sx->second;
		}
		duplicateStationIndex = other.duplicateStationIndex;
	}
	Station &operator =(const Station &other) {
		name = other.name;
		smile = other.smile;
		StorageTrackMap::const_iterator Sx;
		for (Sx = other.storageTracks.begin(); Sx != other.storageTracks.end(); Sx++) {
			storageTracks[Sx->first] = Sx->second;
		}
		duplicateStationIndex = other.duplicateStationIndex;
		return *this;
	}
#endif
	~Station() {}
	const char *Name() const {return name.c_str();}
	double SMile() const {return smile;}
	int DuplicateStationIndex() const {return duplicateStationIndex;}
	void SetDuplicateStationIndex(int index) {duplicateStationIndex = index;}
#ifdef SWIG
	StorageTrack *AddStorageTrack(const char *name);
#else
	StorageTrack *AddStorageTrack(string name_);		
#endif
#ifdef SWIG
	StorageTrack *FindStorageTrack(const char *name);
#else
	StorageTrack *FindStorageTrack(string name) {
		StorageTrackMap::iterator Sx;
		Sx = storageTracks.find(name);
		if (Sx == storageTracks.end()) {
			return NULL;
		} else {
			return &(Sx->second);
		}
	}
#endif
#ifdef SWIG
	StorageTrack *FindTrackTrainIsStoredOn(const char *trainNumber,
					       double fromtime,double totime);
#else
	StorageTrack *FindTrackTrainIsStoredOn(string trainNumber,
					       double fromtime,double totime);
#endif
	/// Number of storage tracks.
	int NumberOfStorageTracks() const {return storageTracks.size();}
#ifdef SWIG
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	%addmethods 
#else
	%extend 
#endif
	{
		int StorageTrackNameList (Tcl_Interp *interp) {
			StorageTrackMap::const_iterator Sx;
			string indx;
			Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
			for (Sx = self->FirstStorageTrack(); Sx != self->LastStorageTrack(); Sx++) {
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
	StorageTrackMap::const_iterator FirstStorageTrack() const {
		return storageTracks.begin();
	}
	StorageTrackMap::const_iterator LastStorageTrack() const {
		return storageTracks.end();
	}
	ostream & Write(ostream & stream) const;
	istream & Read(istream & stream);
private:
	/// Station name.
	string name;
	/// Storage track map.
	StorageTrackMap storageTracks;
	/// Scale Mile.
	double smile;
	/// Duplicate station index.
	int duplicateStationIndex;
#endif
};

#ifdef SWIG
%apply int MyTcl_Result { int ForEveryStorageTrack };

int ForEveryStorageTrack(Tcl_Interp *interp,Station *station,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);

%{
int ForEveryStorageTrack(Tcl_Interp *interp,Station *station,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	StorageTrackMap::const_iterator Sx;

	for (Sx = station->FirstStorageTrack();Sx != station->LastStorageTrack(); Sx++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	  valuePtr = Tcl_NewObj();
	  SWIG_SetPointerObj(valuePtr,(void *) &(Sx->second),"_StorageTrack_p");
#else
	  valuePtr = SWIG_NewInstanceObj((void *) &(Sx->second),SWIGTYPE_p_StorageTrack,0);
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
	      sprintf(msg, "\n    (\"ForEveryStorageTrack\" body line %d)",
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
/// Station Vector.
typedef vector<Station> StationVector;
#endif

//@}
	                    
#endif // _STATION_H_

