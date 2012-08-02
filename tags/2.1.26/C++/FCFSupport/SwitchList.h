/* 
 * ------------------------------------------------------------------
 * SwitchList.h - SwitchList class
 * Created by Robert Heller on Tue Sep 27 14:51:44 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
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

#ifndef _SWITCHLIST_H_
#define _SWITCHLIST_H_

/** Switch List Support code.
  * These classes provide support to create switch lists for trains and
  * yards.
  */

#include <iostream>
#include <Common.h>
#include <Train.h>
#include <Industry.h>
#include <Car.h>
#include <Station.h>

/** @addtogroup FCFSupport
  * @{
  */

namespace FCFSupport {

class System;

/** @brief This class implements each switch list element.
 *
 * @author Robert Heller \<heller\@deepsoft.com\>
 *
 */ 
class SwitchListElement {
public:
	/** A const pointer to a train's stop, which can be either a station
	  *  or an industry, depending on what kind of train it is.
	  */
	union StationOrIndustry {
		/** A station stop, for Box Moves and Way Freights.
		  */
		const Station *station;
		/** An industry stop, for Manifest Freights.
		  */
		const Industry *industry;
	};
	/** Default constructor.  Initialise all slots to NULL.
	  */
	SwitchListElement () {
		pickLoc = NULL;
		pickCar = NULL;
		pickTrain = NULL;
		lastTrain = NULL;
		dropStop.industry = NULL;
	}
	/** Copy constructor.
	  * @param other The other switch list element. 
	  */
	SwitchListElement (const SwitchListElement &other) {
		pickLoc = other.pickLoc;
		pickCar = other.pickCar;
		pickTrain = other.pickTrain;
		lastTrain = other.lastTrain;
		dropStop.industry = other.dropStop.industry;
	}
	/** Assignment operator.
	  * @param other The other switch list element. 
	  */
	SwitchListElement & operator= (const SwitchListElement &other) {
		pickLoc = other.pickLoc;
		pickCar = other.pickCar;
		pickTrain = other.pickTrain;
		lastTrain = other.lastTrain;
		dropStop.industry = other.dropStop.industry;
		return *this;
	}
	/** Constructor, given a manifest freight's stop at an industry.
	  * @param pickloc Pickup location of car.
	  * @param pickcar Car being picked up by this train.
	  * @param picktrain Train picking this car up.
	  * @param lasttrain The last train this car was on.
	  * @param istop Where this train will drop this car.
	  */
	SwitchListElement (const Industry *pickloc, const Car *pickcar,
			   const Train *picktrain, const Train *lasttrain, 
			   const Industry *istop) {
		pickLoc = pickloc;
		pickCar = pickcar;
		pickTrain = picktrain;
		lastTrain = lasttrain;
		dropStop.industry = istop;
	}
	/** Constructor, given a local freight's stop at a station.
	  * @param pickloc Pickup location of car.
	  * @param pickcar Car being picked up by this train.
	  * @param picktrain Train picking this car up.
	  * @param lasttrain The last train this car was on.
	  * @param sstop Where this train will drop this car.
	  */
	SwitchListElement (const Industry *pickloc, const Car *pickcar,
			   const Train *picktrain, const Train *lasttrain, 
			   const Station *sstop) {
		pickLoc = pickloc;
		pickCar = pickcar;
		pickTrain = picktrain;
		lastTrain = lasttrain;
		dropStop.station = sstop;
	}
	/** Return the pickup location for this switch list element.
	  */
	const Industry *PickLocation() const {return pickLoc;}
	/** Return the car picked up for this switch list element.
	  */
	const Car      *PickCar() const {return pickCar;}
	/** Return the pickup train for this switch list element.
	  */
	const Train    *PickTrain() const {return pickTrain;}
	/** Return the train train for the car this switch list element is for.
	  */
	const Train    *LastTrain() const {return lastTrain;}
	/** Return the industry this switch list element is dropping off at.
	  */
	const Industry *DropStopIndustry() const {
		if (pickTrain == NULL) return NULL;
		if (pickTrain->Type() == Train::Manifest) {
			return dropStop.industry;
		} else {
			return NULL;
		}
	}
	/** Return the station this switch list element is dropping off at.
	  */
	const Station  *DropStopStation() const {
		if (pickTrain == NULL) return NULL;
		if (pickTrain->Type() == Train::Manifest) {
			return dropStop.industry->MyStation();
		} else {
			return dropStop.station;
		}
	}
	/** Is the drop stop at the stop number specified?
	  * @param Px The train's stop number we are checking against.
	  */
	bool DropStopEQ(int Px) const {
		if (pickTrain == NULL) return false;
		if (pickTrain->Type() == Train::Manifest) {
		  return dropStop.industry == pickTrain->IndustryStop(Px);
		} else {
		  return dropStop.station == pickTrain->StationStop(Px);
		}
	}
	/** The System class is a friend.
	  */
	friend class System;
private:
	/** The pickup industry.
	  */
	const Industry *pickLoc;
	/** The car picked up.
	  */
	const Car      *pickCar;
	/** The train picking this car up.
	  */
	const Train    *pickTrain;
	/** The train that previously handled this car.
	  */
	const Train	 *lastTrain;
	/** The station or industry where this car will be dropped off at.
	  */
	StationOrIndustry dropStop;
};	

/** @brief Output stream operator for SwitchListElements.
  * @param stream The output stream.
  * @param element The switch list element to output.
  */
ostream& operator<< (ostream& stream,const SwitchListElement& element);
/** A vector of switch list elements.
  */
typedef vector<SwitchListElement> SwitchListElementVector;

/** @brief The global switch list structure.
 *
 * @author Robert Heller \<heller\@deepsoft.com\>
 *
 */
class SwitchList {
public:
	/** Constructor.
	  */
	SwitchList();
	/** Destructor.
	  */
	~SwitchList();
	/** Reset the switch list pointer.
	  */
	void ResetSwitchList();
	/** Clobber the switch list.
	  */
	void DiscardSwitchList();
	/** Add a switch list element for a manifest freight (industry stop).
	  * @param pickloc Pickup location of car.
	  * @param pickcar Car being picked up by this train.
	  * @param picktrain Train picking this car up.
	  * @param lasttrain The last train this car was on.
	  * @param istop Where this train will drop this car.
	  */
	void AddSwitchListElement(const Industry *pickloc, const Car *pickcar,
				  const Train *picktrain, 
				  const Train *lasttrain, 
				  const Industry *istop);
	/** Add a switch list element for a local freight (station stop).
	  * @param pickloc Pickup location of car.
	  * @param pickcar Car being picked up by this train.
	  * @param picktrain Train picking this car up.
	  * @param lasttrain The last train this car was on.
	  * @param sstop Where this train will drop this car.
	  */
	void AddSwitchListElement(const Industry *pickloc, const Car *pickcar,
				  const Train *picktrain, 
				  const Train *lasttrain, 
				  const Station *sstop);
	/** Random index access to the switch list.
	  * @param ielement The index into the switch list.
	  */
	SwitchListElement & operator[] (int ielement);
	/** Random index access to the switch list, const version.
	  * @param ielement The index into the switch list.
	  */
	const SwitchListElement operator[] (int ielement) const;
	/** Return the next switch list list element for a selected car and
	  * industry.
	  * @param car The selected car.
	  * @param industry The selected industry.
	  */
	int NextSwitchListForCarAndIndustry(const Car *car,
					    const Industry *industry);
	/** Return the pick index.
	  */
	unsigned int PickIndex() const {return pickIndex;}
	/** Return the limit count.
	  */
	int LimitCars() const {return limitCars;}
	/** Reset the last index.
	  */
	void ResetLastIndex() {lastIndex = -1;}
	/** Is the selected element for the specificed industry?
	  * @param Gx The index to check.
	  * @param Ix The industry to check for.
	  */
	bool PickLocationEq(int Gx,const Industry *Ix) const;
	/** Is the selected element for the specificed car?
	  * @param Gx The index to check.
	  * @param Cx The car to check for.
	  */
	bool PickCarEq(int Gx,const Car *Cx) const;
	/** Is the selected element for the specificed train?
	  * @param Gx The index to check.
	  * @param Tx The train  to check for.
	  */
	bool PickTrainEq(int Gx,const Train *Tx) const;
	/** Output stream operator for switch lists.
	  * @param stream The stream to write to.
	  * @param list   The switch list to write out.
	  */
	friend ostream & operator << (ostream & stream,const SwitchList & list);
private:
	/** The switch list vector.
	  */
	SwitchListElementVector theList;
	/** The pick index.
	  */
	unsigned int pickIndex;
	/** The limit index.
	  */
	int limitCars;
	/** The last index.
	  */
	int lastIndex;
};

} // namespace FCFSupport

/** @} */

#endif // _SWITCHLIST_H_

