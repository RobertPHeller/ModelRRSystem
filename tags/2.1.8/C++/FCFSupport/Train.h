/* 
 * ------------------------------------------------------------------
 * Train.h - Train class
 * Created by Robert Heller on Sat Aug 27 08:57:12 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.6  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.5  2007/02/21 21:03:10  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.4  2007/02/21 20:15:48  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.3  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:41:57  heller
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

#ifndef _TRAIN_H_
#define _TRAIN_H_

#ifndef SWIG
#include <Common.h>
#include <Station.h>
#include <Division.h>
#include <Industry.h>

class System;
#endif

#ifdef SWIG
/*
 * Typemap for the TrainType enum.  Return a string that represents the value
 * of the enum.
 */

%typemap(tcl8,out) Train::TrainType {
	switch ($1) {
		case Train::Unknown:
			Tcl_SetStringObj($result,"Unknown",-1);
			break;
		case Train::Wayfreight:
			Tcl_SetStringObj($result,"Wayfreight",-1);
			break;
		case Train::BoxMove:
			Tcl_SetStringObj($result,"BoxMove",-1);
			break;
		case Train::Manifest:
			Tcl_SetStringObj($result,"Manifest",-1);
			break;
		case Train::Passenger:
			Tcl_SetStringObj($result,"Passenger",-1);
			break;
	}
}
#endif

/** The Train class represents a train.  A train has a name, a type, a
  * description, a list of divisions it operates in, it takes a specific 
  * set of car types, operates during a specific shift (or possibly all 
  * shifts if it is a box movement), a set of stops it makes, an on
  * duty time, a maximum number of cars, a maximum clearance plate,
  * a maximum weight class, a maximum length and several flags.
  */
class Train {
public:
#ifdef SWIG	
	/*+ Types of trains (sanitized for SWIG).
	  */
	enum TrainType {
		// An unknown type of train.
		Unknown,
		// A Way Freight train.
		Wayfreight,
		// A Box Move train.
		BoxMove,
		// A Manifest Freight train.
		Manifest,
		// A Passenger train.
		Passenger
	};
#else
	/** Types of trains. 
	  */
	enum TrainType {
		/** An unknown type of train.
		  */
		Unknown = 0,
		/** A Way Freight train.
		  */
		Wayfreight = 'W',
		/** A Box Move train.
		  */
		BoxMove = 'B',
		/** A Manifest Freight train.
		  */
		Manifest = 'M',
		/** A Passenger train.
		  */
		Passenger = 'P'
	};
#endif
#ifndef SWIG
	/** Default constructor.  Initialize all slots to empty values.
	  */
	Train() {name = "";divList = "";carTypes = "";description = "";
		 shift = 0;maxcars = 0;maxclear = 0;maxweight = 0;
		 maxlength = 0;print = false;done = false;type = Unknown;
		 onduty = -1;}
	/** Copy construtor.  Copy initial values from another instance.
	  * @param other The other Train instance.
	  */
	Train(Train &other) {
		orders = other.orders;
		stops = other.stops;
		name = other.name;
		divList = other.divList;
		carTypes = other.carTypes;
		description = other.description;
		shift = other.shift;
		maxcars = other.maxcars;
		maxclear = other.maxclear;
		maxweight = other.maxweight;
		maxlength = other.maxlength;
		onduty = other.onduty;
		print = other.print;
		done = other.done;
		type = other.type;
		}
	/** Assignment operator.  Copy values from another instance.
	  *  @param other The other Train instance.
	  */
	Train & operator= (Train &other) {
		orders = other.orders;
		stops = other.stops;
		name = other.name;
		divList = other.divList;
		carTypes = other.carTypes;
		description = other.description;
		shift = other.shift;
		maxcars = other.maxcars;
		maxclear = other.maxclear;
		maxweight = other.maxweight;
		maxlength = other.maxlength;
		onduty = other.onduty;
		print = other.print;
		done = other.done;
		type = other.type;
		return *this;
	}
#endif
	/** Full constructor.  Initialize the class instance from a set of parameters.
	  *  @param n The new train's name.
	  *  @param dl The new train's division list.
	  *  @param ct The new train's car type list.
	  *  @param descr The New train's description.
	  *  @param sh The new train's shift.
	  *  @param mc The new train's maximum car limit.
	  *  @param mcl The new train's maximum clearance plate.
	  *  @param mw The new train's maximum weight class.
	  *  @param ml The new train's maximum length.
	  *  @param od The new train's on duty time (in minutes since midnight).
	  *  @param p A flag to indicate if a pickup / dropoff sheet should be 
	  *	printed for this train.
	  *  @param d A flag to indicate if this train is done.
	  *  @param t The new train's type.
	  */
	Train(const char *n,const char *dl,const char *ct,const char *descr,
	      int sh,int mc,int mcl,int mw,int ml,int od,bool p,bool d,
	      TrainType t) {
		name = n; divList = dl; carTypes = ct; description = descr;
		shift = sh; maxcars = mc; maxclear = mcl; maxweight = mw;
		maxlength = ml; onduty = od,print = p; done = d; type = t;}
	/** Descructor.
	  */
	~Train() {}
	/** Return the train's name.
	  */
	const char *Name() const {return name.c_str();}
	/** Return the train's division list (string of symbols).
	  */
	const char *DivisionList() const {return divList.c_str();}
	/** Return the train's car type list (string of char type characters).
	  */
	const char *CarTypes() const {return carTypes.c_str();}
	/** Return the train's description.
	  */
	const char *Description() const {return description.c_str();}
	/** Return the train's shift.
	  */
	int Shift() const {return shift;}
	/** Set the train's shift.
	  * @param newshift The new shift.
	  */

	void SetShift(int newshift) {if (shift >= 1 && shift <= 3) shift = newshift;}
	/** Return the train's maximum number of cars.
	  */
	int MaxCars() const {return maxcars;}
	/** Return the train's maximum clearance plate.
	  */
	int MaxClear() const {return maxclear;}
	/** Return the train's maximum weight class.
	  */
	int MaxWeight() const {return maxweight;}
	/** Set the train's maximum weight class.
	  *  @param newmaxweight New maximum weight class.
	  */
	void SetMaxWeight(int newmaxweight) {if (newmaxweight > 0) maxweight = newmaxweight;}
	/** Return the train's maximum length.
	  */
	int MaxLength() const {return maxlength;}
	/** Set the train's maximum length.
	  *  @param newmaxlength New maximum length.
	  */
	void SetMaxLength(int newmaxlength) {if (newmaxlength > 0) maxlength = newmaxlength;}
	/** Return the train's on duty time, in minutes since midnight.
	  */
	int OnDuty() const {return onduty;}
	/** Return the train's print flag.
	  */
	bool Print() const {return print;}
	/** Set the train's print flag.
	  *  @param flag The new flag value.
	  */
	void SetPrint(bool flag) {print = flag;}
	/** Return the train's done flag.
	  */
	bool Done() const {return done;}
	/** Return the train's type.
	  */
	TrainType Type() const {return type;}
	/** Return the number of train orders for this train.
	  */
	int NumberOfOrders() const {return orders.size();}
	/** Return the Ith order.
	  *  @param index The index of the order to retrieve.
	  */
	const char *Order(int index) const {
		if (index < 0 || index >= orders.size()) return NULL;
		else return orders[index].c_str();
	}
	/** Return the number of stops this train makes.
	  */
	int NumberOfStops() const {return stops.size();}
	/** Return the Ith industry stop this train makes.
	  *  @param index The index of the the stop to retrieve.
	  */
	Industry *IndustryStop(int index) const {
		if (index < 0 || index >= stops.size()) return NULL;
		switch (type) {
			case Manifest:
				return stops[index].industry;
				break;
			default:
				return NULL;
				break;
		}
	}
	/** Return the Ith station stop this train makes.
	  *  @param index The index of the the stop to retrieve.
	  */
	Station *StationStop(int index) const {
		if (index < 0 || index >= stops.size()) return NULL;
		switch (type) {
			case Manifest:
				return stops[index].industry->MyStation();
				break;
			default:
				return stops[index].station;
		}
	}
#ifndef SWIG
	/** The System class is a friend.
	  */
	friend class System;
	/** Union of stations or industries, used for stops.
	  */
	union StationOrIndustry {
		/** Station, for other then Manifest freights.
		  */
		Station *station;
		/** Industry, for Manifest freights.
		  */
		Industry *industry;
	};
private:
	/** List of train orders.
	  */
	vector<string> orders;
	/** List of stops.
	  */
	vector<StationOrIndustry> stops;
	/** Name of the train.
	  */
	string name;
	/** The list of division symbols for this train.
	  */
	string divList;
	/** The list of car type charactes.
	  */
	string carTypes;
	/** The description of the train.
	  */
	string description;
	/** The train's shift.
	  */
	int shift;
	/** The maximum number of cars on this train.
	  */
	int maxcars;
	/** The maximum clearance plate for this train.
	  */
	int maxclear; 
	/** The maximum weight class for this train.
	  */
	int maxweight;
	/** The maximum length for this train.
	  */
	int maxlength;
	/** The onduty time for this train, in minutes since midnight.
	  */
	int onduty;
	/** The print flag for this train.
	  */
	bool print;
	/** The done flag for this train.
	  */
	bool done;
	/** The type of this train.
	  */
	TrainType type;
#endif
};

#ifndef SWIG
/** @name TrainMap
  * A map of trains, indexed by integer (train index).
  */
typedef map<int, Train *, less<int> > TrainMap;
/** @name TrainNameMap
  * A map of trains, indexed by string (Train name).
  */
typedef map<string, Train *, less<string> > TrainNameMap;
#endif

#endif // _TRAIN_H_

