/* 
 * ------------------------------------------------------------------
 * Industry.h - Industries
 * Created by Robert Heller on Sat Aug 27 15:18:45 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:20  heller
 * Modification History: April 19 Lock Down
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

#ifndef _INDUSTRY_H_
#define _INDUSTRY_H_

//#define NDEBUG 1

#ifndef SWIG
#include <Common.h>
#include <Station.h>
#include <Division.h>
#include <limits.h>
#include <iostream>
#include <assert.h>
#endif

/** @addtogroup FCFSupport
  * @{
  */

namespace FCFSupport {

#ifndef SWIG
class System;
class Car;
/** A vector of cars.
  */
typedef vector<Car *> CarVector;
#endif

/** @brief The Industry class represents an industry.
  *
  * There are several types of
  * industries, including yards, on line industries, and off line industries.
  * An industry has track where cars can be spotted for storage, loading, and
  * unloading.  On-line industries and yards have this trackage on the layout.
  * off line industries have this trackage either in the form of a hidden
  * staging yard or don't have any real trackage at all.
  *
   * An industry takes specific loaded and empty car types, has a maximum weight
  * and clearance plate, in at a specific station and has a division control
  * list.  Some industries are mirrors of others and some industries can re-load
  * cars.    
  *
  *	@author Robert Heller \<heller\@deepsoft.com\>
  */
class Industry {
public:
#ifndef SWIG
	/** Default constructor.  Fill all slots with default values.
	  */
	Industry() {station = NULL; mirror = NULL;
		    name = "Scrap Yard"; loadTypes = ""; emptyTypes = ""; 
		    divisionControlList = "";
		    trackLen = INT_MAX; assignLen = INT_MAX; priority = 0; plate = 0;
		    weightclass = 0; maxCarLen = 0 ; carsNum = 0; carsLen = 0 ;
		    statsLen = 0; usedLen = 0; remLen = 0; reload = false;
		    type = '\0'; hazard = '\0';}
	/** Copy constructor.  Initialize this industry from another existing industry.
	  *  @param other The other industry.
	  */
	Industry(Industry &other) {
		station = other.station;
		mirror = other.mirror;
		name = other.name;
		divisionControlList = other.divisionControlList;
		loadTypes = other.loadTypes;
		emptyTypes = other.emptyTypes;
		trackLen = other.trackLen;
		assignLen = other.assignLen;
		priority = other.priority;
		plate = other.plate;
		weightclass = other.weightclass;
		maxCarLen = other.maxCarLen;
		carsNum = other.carsNum;
		carsLen = other.carsLen;
		statsLen = other.statsLen;
		usedLen = other.usedLen;
		remLen = other.remLen;
		reload = other.reload;
		type = other.type;
		hazard = other.hazard;
		cars = other.cars;
	}
	/** Assignment operator.  Initialize this industry from another existing industry.
	  *  @param other The other industry.
	  */
	Industry & operator= (Industry &other) {
		station = other.station;
		mirror = other.mirror;
		name = other.name;
		divisionControlList = other.divisionControlList;
		loadTypes = other.loadTypes;
		emptyTypes = other.emptyTypes;
		trackLen = other.trackLen;
		assignLen = other.assignLen;
		priority = other.priority;
		plate = other.plate;
		weightclass = other.weightclass;
		maxCarLen = other.maxCarLen;
		carsNum = other.carsNum;
		carsLen = other.carsLen;
		statsLen = other.statsLen;
		usedLen = other.usedLen;
		remLen = other.remLen;
		reload = other.reload;
		type = other.type;
		hazard = other.hazard;
		cars = other.cars;
		return *this;
	}
#endif
	/** Full constructor.  Create a new industry from a full set of parameters.
	  *  @param t The type of industry ('Y' for yard, 'O' for offline, 'I' for online).
	  *  @param st Station this industry is at.
	  *  @param n The name of the industry.
	  *  @param tl The track length at this industry.
	  *  @param al The assignable length at this industry.
	  *  @param p Tnis industry's priority.
	  *  @param r Car reload flag.
	  *  @param h Hazard code.
	  *  @param m Mirror industry.
	  *  @param pl Maximum clearance plate.
	  *  @param c Maximum weight class.
	  *  @param dcl Division control list.
	  *  @param mcl Maximum car length.
	  *  @param lt Loaded car types accepted here.
	  *  @param et Empty car type accepted here.
	  */
	Industry(char t, Station *st, const char *n, int tl, int al, int p, 
		 bool r, char h, Industry *m, int pl, int c, const char *dcl,
		 int mcl, const char *lt, const char *et) {
		type = t;
		station = st;
		name = n;
		trackLen = tl;
		assignLen = al;
		priority = p;
		reload = r;
		hazard = h;
		mirror = m;
		plate = pl;
		weightclass = c;
		divisionControlList = dcl;
		maxCarLen = mcl;
		loadTypes = lt;
		emptyTypes = et;
		carsNum = 0;
		carsLen = 0;
		statsLen = 0;
		usedLen = 0; 
		remLen = 0;
	}
	/** Return the type of the industry.
	  */
	char Type() const {return type;}
	/** Return the industry's station.
	  */
	Station *MyStation() const {
	  return station;
	}
	/** Return the industry's name.
	  */
	const char *Name() const {return name.c_str();}
	/** Return the amount of track at this industry.
	  */
	int TrackLen() const {return trackLen;}
	/** Return the assignable amount of track at this industry.
	  */
	int AssignLen() const {return assignLen;}
	/** Return this industry's priority.
	  */
	int Priority() const {return priority;}
	/** Can this industry reload cars?
	  */
	bool Reload() const {return reload;}
	/** What sorts of hazardious material classes can this industry handle?
	  */
	char Hazard() const {return hazard;}
	/** This industry's mirror industry (if any).
	  */
	Industry *MyMirror() const {return mirror;}
	/** Maximum clearance plate this industry can handle.
	  */
	int MaxPlate() const {return plate;}
	/** Maximum weight class this industry can handle.
	  */
	int MaxWeightClass() const {return weightclass;}
	/** This indusry's division control list.
	  */
	const char *DivisionControlList() const {return divisionControlList.c_str();}
	/** The maximum car length this industry can handle.
	  */
	int MaxCarLen() const {return maxCarLen;}
	/** The types of loads this industry can handle.
	  */
	const char *LoadsAccepted() const {return loadTypes.c_str();}
	/** The types of empties this industry can handle.
	  */
	const char *EmptiesAccepted() const {return emptyTypes.c_str();}
	/** Return the indexed car at this industry.
	  *  @param i This car index.
	  */
	FCFSupport::Car *TheCar(int i) const {
		if (i < 0 || (unsigned)i >= cars.size()) return NULL;
		else return cars[i];
	}
	/** Return the number of cars at this industry.
	  */
	int NumberOfCars() const {return cars.size();}
	/** Increment the stats length.
	  */
	void IncrementStatsLen(int i = 1) { statsLen += i; }
	/** Return the number of cars.
	  */
	int CarsNum() const {return carsNum;}
	/** Return the length of all of the cars.
	  */
	int CarsLen() const {return carsLen;}
	/** Return the stats length.
	  */
	int StatsLen() const {return statsLen;}
#ifndef SWIG
	/** The System class is a friend.
	  */
	friend class System;
private:
	/** The vector of cars at this industry.
	  */
	CarVector cars;
	/** The station this industry is at.
	  */
	Station	 *station;
	/** The mirror industry or NULL if there is no mirror industry.
	  */
	Industry *mirror;
	/** The name of the industry.
	  */
	string    name;
	/** The vector of loaded car type charactes.
	  */
	string    loadTypes;
	/** The vector of empty car type characters.
	  */
	string	  emptyTypes;
	/** The division control list.
	  */
	string	  divisionControlList;
	/** The track length.
	  */
	int	  trackLen;
	/** The assignable length.
	  */
	int	  assignLen;
	/** The industry's priority.
	  */
	int	  priority;
	/** The industry's clearance plate.
	  */
	int	  plate;
	/** The industry's weight class.
	  */
	int	  weightclass;
	/** The maximum car length.
	  */
	int	  maxCarLen;
	/** The number of cars.
	  */
	int	  carsNum;
	/** The length of the cars.
	  */
	int	  carsLen;
	/** The stats length.
	  */
	int	  statsLen;
	/** The used length.
	  */
	int	  usedLen;
	/** The remaining length.
	  */
	int	  remLen;
	/** The reload flag.
	  */
	bool	  reload;
	/** The industry type.
	  */
	char	  type;
	/** The hazard type character.
	  */
	char	  hazard;
#endif
};

#ifndef SWIG
/** A map of industry pointers indexed by an integer.
  */
typedef map<int, Industry *, less<int> > IndustryMap;
/** A vector of industry pointers.
  */
typedef vector<Industry *> IndustryVector;
#endif

#ifdef DEBUG
#ifndef SWIG

/** @brief Output operator for an industry pointer.
  *
  * @param ostream The stream to write to.
  * @param Ix The industry to write.
  *
  *	@author Robert Heller \<heller\@deepsoft.com\>
  */ 
ostream& operator<<(ostream& stream,const Industry* Ix);

/** @brief Output operator for an industry reference.
  *
  * @param ostream The stream to write to.
  * @param Ix The industry to write.
  *
  *	@author Robert Heller \<heller\@deepsoft.com\>
  */ 

ostream& operator<<(ostream& stream,const Industry& Ix);
#endif
#endif

} // namespace FCFSupport

/** @} */

#endif // _INDUSTRY_H_

