/* 
 * ------------------------------------------------------------------
 * Station.h - Station class declaration.
 * Created by Robert Heller on Tue Dec 20 21:06:49 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.7  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.6  2007/02/21 20:19:22  heller
 * Modification History: SWIG Hackery
 * Modification History:
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
  * @doc  \TEX{\typeout{Generated from $Id$.}}
  * This class and its support classes implement information about stations
  * and station stops.  This includes where a station is along the line (its
  * scale mile), what storage tracks it has, and what trains are being stored
  * on the storage tracks during what times.  Stations are places where trains
  * stop or just important junctions or mile post locations that trains pass
  * by -- they might only be used for time keeping checks.  Note: the
  * classification tracks at a yard are not storage tracks.  Nor are RIP or 
  * service or other special purpose tracks.  Storage tracks are only for 
  * storing whole, complete trains (they might be without engines).  
  */

//@{

/** This class records a train sitting on a storage track during a specified 
  * time frame.  The train number (symbol) might change when the train leaves 
  * the storage track.
  */
class Occupied {
public:
#ifdef SWIG
	Occupied(const char * trainnum_="",double from_=0.0,double until_=0.0,const char * trainnum2__ = "");
#else
	/** Constructor: record a train occupying a storage track.
	  *   @param trainnum_ The arriving train number (symbol).
	  *   @param from_ The arrival time.
	  *   @param until_ The departure time.
	  *   @param trainnum2_ The departing train number (symbol).  If it is
	  *          the empty string, the departing train has the same number
	  *          (symbol) as the arriving train.
	  */
	Occupied(string trainnum_="",double from_=0.0,double until_=0.0,string trainnum2_ = "") {
		trainnum = trainnum_;
		from  = from_;
		until = until_;
		trainnum2 = trainnum2_;
	}
#endif
	/** Return the train that arrives.
	  */
	const char *TrainNum() const {return trainnum.c_str();}
	/** Return the train that departs.
	  */
	const char  *TrainNum2() const {return trainnum2.c_str();}
	/** Return the start time;
	  */
	double From() const {return from;}
	/** Return the end time.
	  */
	double Until() const {return until;}
#ifndef SWIG
	/** Copy constructor -- create an instance from another Occupied
	  * instance.
	  *    @param other The other instance.
	  */
	Occupied(const Occupied &other) {
		trainnum = other.trainnum;
		trainnum2 = other.trainnum2;
		from  = other.from;
		until = other.until;
	}
	/** Assignment operator.  Assign an Occupied instance to another
 	  * Occupied instance.
	  *    @param other The other instance.
	  */
	Occupied & operator= (const Occupied &other) {
		trainnum = other.trainnum;
		trainnum2 = other.trainnum2;
		from  = other.from;
		until = other.until;
		return *this;
	}
	/** We are best buddies with the TimeTableSystem class.
	  */
	friend class TimeTableSystem;
	/** Write ourselves to an output stream.
	  *    @param stream The stream to write to.
	  */
	ostream & Write(ostream & stream) const;
	/** Read ourselves from an input stream.
	  *    @param stream The stream to read from.
	  */
	istream & Read(istream & stream);
private:
	/** The train that arrived.
	  */
	string trainnum;
	/** The train that departs.
	  */
	string trainnum2;
	/** The start time of the occupation.
	  */
	double from;
	/** The end time of the occupation.
	  */
	double until;
#endif
};


#ifndef SWIG
/** The TimeRange implements a range of times.
  */
class TimeRange {
public:
	/** Construct a time range, from a start and end time.
	  *   @param from_ The start time.
	  *   @param to_ The end time.
	  */
	TimeRange(double from_ = 0.0, double to_ = 0.0) {
		from = from_;
		to = to_;
	}
	/** Return the low end of the range.
	  */
	double From () const {return from;}
	/** Return the high end of the range.
	  */
	double To () const {return to;}
	/** Does this interval contain the specified time?
	  *  @param time The time to check for.
	  */
	bool ContainsTime( double time ) const {
		return (time >= from && time <= to);
	}
	/** Less than operator.
	  *   @param other The time range to compare to.
	  */
	bool operator < (const TimeRange &other) const {
		return to <= other.from;
	}
	/** Greater than operator.
	  *   @param other The time range to compare to.
	  */
	bool operator > (const TimeRange &other) const {
		return from >= other.to;
	}
	/** Equality to operator.
	  *   @param other The time range to compare to.
	  */
	bool operator == (const TimeRange &other) const {
		return (to == other.to && from == other.from);
	}
	/** Less than or equal operator.
	  *   @param other The time range to compare to.
	  */
	bool operator <= (const TimeRange &other) const {
		return (*this < other || *this == other);
	}
	/** Greater than or equal operator.
	  *   @param other The time range to compare to.
	  */
	bool operator >= (const TimeRange &other) const {
		return (*this > other || *this == other);
	}
	/** Copy constructor:  create a clone of a TimeRange.
	  *  @param other The other TimeRange object.
	  */
	TimeRange (const TimeRange &other) {
		from = other.from;
		to   = other.to;
	}
	/** Assign a TimeRange to another TimeRange.
	  *  @param other The other TimeRange object.
	  */
	TimeRange & operator= (const TimeRange &other) {
		from = other.from;
		to   = other.to;
		return *this;
	}
	/** Write ourselves to an output stream.
	  *    @param stream The stream to write to.
	  */
	ostream & Write(ostream & stream) const;
	/** Read ourselves from an input stream.
	  *    @param stream The stream to read from.
	  */
	istream & Read(istream & stream);
private:
	/** Start time.
	  */
	double from;
	/** End time.
	  */
	double to;
};

/** The Occupied Map type, ordered by time ranges.
  */
typedef map<TimeRange, Occupied, less<TimeRange> > OccupiedMap;
#endif


/** The StorageTrack class implements a storage track.
  * Storage tracks store trains at stations.  Each storage track can only
  * store one train at a given time.  No checks are made to determing if
  * the track is actually long enough for the train.
  *
  * Each storage track has a name.
  */
class StorageTrack {
public:
#ifdef SWIG
	StorageTrack(const char *name = "Track 0");
#else
	/** Construct a storage track.  The name of the track is initialized.
	  *   @param name_ The name of the storage track.
	  */
	StorageTrack(string name_ = "Track 0") {
		name = name_;
	}
#endif
	/** Destructor.
	  */
	~StorageTrack() {}
	/** Return the name of the storage track.
	  */
	const char *Name() const {return name.c_str();}
#ifdef SWIG
	void SetName(const char *name);
#else
	/** Set the storage track's name.
	  *   @param name_ The new name of the storage track.
	  */
	void SetName(string name_) {
		name = name_;
	}
#endif
	/** Return the occupation that includes the specified time;
	  *   @param time The time to check for.
	  */
	const Occupied * IncludesTime(double time) const;
#ifdef SWIG
	const Occupied * StoreTrain (const char *train, double from, double to,const char *train2);
#else
	/** Insert train onto storage track for a time.
	  *   @param train  The arriving train.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  *   @param train2 The departing train.
	  */
	const Occupied * StoreTrain (string train, double from, double to,string train2);
#endif
	/** Remove stored train.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  */
	bool RemovedStoredTrain (double from, double to);
	/** Return true if the time range is in use.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  */
	bool UsedTimeRange(double from, double to) const;
	/** Return occupication structure for a given time tange.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  */
	const Occupied *FindOccupied(double from, double to) const {
		TimeRange range(from,to);
		OccupiedMap::const_iterator Ox = occupations.find(range);
		if (Ox == occupations.end()) return NULL;
		else return &(Ox->second);
	}
#ifdef SWIG
	const Occupied * UpdateStoredTrain(double from, double to,const char *train);
#else
	/** Replace a stored arrrival train.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  *   @param train  The new arriving train.
	  */
	const Occupied * UpdateStoredTrain(double from, double to,string train);
#endif
#ifdef SWIG
	const Occupied * UpdateStoredTrain2(double from, double to,const char *train);
#else
	/** Replace a stored departure train.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  *   @param train  The new departing train.
	  */
	const Occupied * UpdateStoredTrain2(double from, double to,string train);
#endif
	/** Update a train's arrival time.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  *   @param newArrival The new arrival time.
	  */
	const Occupied * UpdateStoredTrainArrival(double from, double to,
						  double newArrival);
	/** Update a train's departure time.
	  *   @param from   The arrival time.
	  *   @param to     The departure time.
	  *   @param newDeparture The new departure time.
	  */
	const Occupied * UpdateStoredTrainDeparture(double from, double to,
						    double newDeparture);
#ifndef SWIG
	/** Clone a StorageTrack -- copy constructor.
	  *  @param other The other StorageTrack.
	  */
	StorageTrack(const StorageTrack& other) {
		name = other.name;
		OccupiedMap::const_iterator Ox;
		for (Ox = other.occupations.begin(); Ox != other.occupations.end(); Ox++) {
			occupations[Ox->first] = Ox->second;
		}
	}
	/** Assign a StorageTrack to another StorageTrack.
	  *  @param other The other StorageTrack.
	  */
	StorageTrack &operator=(const StorageTrack& other) {
		name = other.name;
		OccupiedMap::const_iterator Ox;
		for (Ox = other.occupations.begin(); Ox != other.occupations.end(); Ox++) {
			occupations[Ox->first] = Ox->second;
		}
		return *this;
	}
	/** Write method.  Write object to a stream.
	  *   @param stream Stream to write to.
	  */
	ostream & Write(ostream & stream) const;
	/** Read Method.  Read object from a stream.
	  *   @param stream Stream to read from.
	  */
	istream & Read(istream & stream);
	/** Return a const iterator for the first occupation.
	  */
	OccupiedMap::const_iterator FirstOccupied() const {return occupations.begin();}
	/** Return a const iterator for the last occupation.
	  */
	OccupiedMap::const_iterator LastOccupied() const {return occupations.end();}
private:
	/** Name of the storage track.
	  */
	string name;
	/** Map of occupations.
	  */
	OccupiedMap occupations;
#endif
};

#ifdef SWIG

%apply int MyTcl_Result { int ForEveryOccupied };


/** @name ForEveryOccupied
  * @args storageTrack variable body
  * @type empty string
  * Tcl looping construct for trains occupying a storage track.
  * Iterate over the occupations map, evaluating the loop body for each 
  * occupation.
  *   @param storageTrack The StorageTrack object.
  *   @param variable The loop variable.
  *   @param body The loop body.
  */

int ForEveryOccupied(Tcl_Interp *interp,StorageTrack *storageTrack,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);

%{
int ForEveryOccupied(Tcl_Interp *interp,StorageTrack *storageTrack,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	OccupiedMap::const_iterator Ox;

	// Loop over occupations...
	for (Ox = storageTrack->FirstOccupied();Ox != storageTrack->LastOccupied(); Ox++) {
	  Tcl_Obj *valuePtr, *varValuePtr, *tempPtr, *rangeListPtr, *dobjPtr;
	  // Allocate a value object and range list object.
	  valuePtr = Tcl_NewObj();
	  rangeListPtr = Tcl_NewObj();
	  // Get from time.
	  dobjPtr = Tcl_NewDoubleObj((Ox->first).From());
	  // Append to range.
	  if (Tcl_ListObjAppendElement(interp,rangeListPtr,dobjPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
	  // Get to time.
	  dobjPtr = Tcl_NewDoubleObj((Ox->first).To());
	  // Append to range.
	  if (Tcl_ListObjAppendElement(interp,rangeListPtr,dobjPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
	  // Append range to value.
	  if (Tcl_ListObjAppendElement(interp,valuePtr,rangeListPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
	  // Get occupied object.
	  tempPtr = SWIG_NewInstanceObj((void *) &(Ox->second),SWIGTYPE_p_Occupied,0);
	  // Append to value.
	  if (Tcl_ListObjAppendElement(interp,valuePtr,tempPtr) != TCL_OK) {
	  	return TCL_ERROR;
	  }
	  // Set loop variable
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
	  // Evaluate the body script.
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  // Handle errors and other things (continue, break, return, etc.).
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {// continue
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {// break
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {// error
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryOccupied\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {// Other status values: return, etc.
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
/** Storage track map. Indexed by name.
  */
typedef map<string, StorageTrack, less<string> > StorageTrackMap;
#endif

/** The Station class implements a station.  Stations are not specifically
  * passenger stations, but are any place where trains stop or meet or might
  * just be important mile post locations used for time keeping checks.  They
  * also can be just sidings.
  */
class Station {
public:
#ifdef SWIG
	Station(const char * name,double smile);
#else
	/** Construct a station object, given a name and a scale mile location.
	  *  @param name_ The name of the station.
	  *  @param smile_ The scale mile location of the station.
	  */
	Station(string name_ = "Unknown",double smile_ = 0) {
		name = name_;
		smile = smile_;
		duplicateStationIndex = -1;
	}
	/** Copy constructor.  Copy one station to another.
	  *  @param other The other station.
	  */
	Station(const Station &other) {
		name = other.name;
		smile = other.smile;
		StorageTrackMap::const_iterator Sx;
		for (Sx = other.storageTracks.begin(); Sx != other.storageTracks.end(); Sx++) {
			storageTracks[Sx->first] = Sx->second;
		}
		duplicateStationIndex = other.duplicateStationIndex;
	}
	/** Assignment operator.  Assign one station to another.
	  *  @param other The other station.
	  */
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
	/** Destructor.
	  */
	~Station() {}
	/** Return the name of the station.
	  */
	const char *Name() const {return name.c_str();}
	/** Return the scale mile of the station.
	  */
	double SMile() const {return smile;}
	/** Return the  duplicate station index.  This is the index of another
	  * station that is the physical duplicate of this one.  Only meaningful
	  * on out-and-back type layouts or other layout configurations where 
	  * stations are logically duplicated due to trackage having dual 
	  * meaning.
	  */
	int DuplicateStationIndex() const {return duplicateStationIndex;}
	/** Set the duplication station index.
	  *   @param index The index of the duplicate station.
	  */
	void SetDuplicateStationIndex(int index) {duplicateStationIndex = index;}
#ifdef SWIG
	StorageTrack *AddStorageTrack(const char *name);
#else
	/** Add a storage track.
	  *   @param name_ The name of the storage track.
	  */
	StorageTrack *AddStorageTrack(string name_);		
#endif
#ifdef SWIG
	StorageTrack *FindStorageTrack(const char *name);
#else
	/** Find a storage track by name.
	  *   @param name_ The name of the storage track.
	  */
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
	/** Find track a train is stored on.
	  *  @param trainNumber The train number (symbol) to search for.
	  *  @param fromtime The from time to check.
	  *  @param totime The to time to check.
	  */
	StorageTrack *FindTrackTrainIsStoredOn(string trainNumber,
					       double fromtime,double totime);
#endif
	/// Number of storage tracks.
	int NumberOfStorageTracks() const {return storageTracks.size();}
#ifdef SWIG
	/*
	 * Class extensions for Tcl: return lists of map elements.
	 */
	%extend 
	{
		%apply int MyTcl_Result { int StorageTrackNameList };
		/** @memo Returns the list of storage track names.
		  * @args none
		  * @type list
		  * Returns the list of storage track names.  Only
		  * available to Tcl code. C++ code should iterate with
		  * FirstStorageTrack() and LastStorageTrack().
		  */
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
	/** Return a const_iterator for the first element in the storage track
	  * map.
	  */
	StorageTrackMap::const_iterator FirstStorageTrack() const {
		return storageTracks.begin();
	}
	/** Return a const_iterator for the last element in the storage track
	  * map.
	  */
	StorageTrackMap::const_iterator LastStorageTrack() const {
		return storageTracks.end();
	}
	/** Write object to a stream.
	  *   @param stream Stream to write to.
	  */
	ostream & Write(ostream & stream) const;
	/** Read an object from a stream.
	  *   @param stream Stream to read from.
	  */
	istream & Read(istream & stream);
private:
	/** Station name.
	  */
	string name;
	/** Storage track map.
	  */
	StorageTrackMap storageTracks;
	/** Scale Mile.
	  */
	double smile;
	/** Duplicate station index.
	  */
	int duplicateStationIndex;
#endif
};

#ifdef SWIG

/*
 * foreach clone for storage tracks.
 * Loop over storage tracks, setting loop variable to the name of the
 * storage track.
 */
 
%apply int MyTcl_Result { int ForEveryStorageTrack };

/** @name ForEveryStorageTrack
  * @args station variable body
  * @type empty string
  * Tcl looping construct for storage tracks at a station.  Iterate over the
  * storage track map, evaluating the loop body for each storage track.
  *   @param station The Station object.
  *   @param variable The loop variable.
  *   @param body The loop body.
  */

int ForEveryStorageTrack(Tcl_Interp *interp,Station *station,Tcl_Obj *variableName,Tcl_Obj *bodyPtr);

%{
int ForEveryStorageTrack(Tcl_Interp *interp,Station *station,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	StorageTrackMap::const_iterator Sx;

	for (Sx = station->FirstStorageTrack();Sx != station->LastStorageTrack(); Sx++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = SWIG_NewInstanceObj((void *) &(Sx->second),SWIGTYPE_p_StorageTrack,0);
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
/** Station Vector.
  */
typedef vector<Station> StationVector;
#endif

//@}
	                    
#endif // _STATION_H_

