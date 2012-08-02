/* 
 * ------------------------------------------------------------------
 * Car.h - Car structure
 * Created by Robert Heller on Sun Aug 28 14:28:24 2005
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

#ifndef _CAR_H_
#define _CAR_H_

#ifndef SWIG
#include <Common.h>
class Owner;
class Train;
class Industry;
#endif

/** \TEX{\typeout{Generated from $Id$.}}
  * This class holds all of the information for a single car. Including its
  *  reporting marks, car number, type, division list, owner, length, weight,
  *  and so on.
  */
class Car {
public:
#ifndef SWIG
	/** Default constructor.  All slots are initialized to default values.
	  */
	Car () {type = '\0'; marks = ""; number = ""; divisions = "";
		length = 0; plate = 0; weightclass = 0; ltwt = 0; ldlmt = 0;
		loadedP = false; mirrorP = false; fixedP  = false;
		owner = NULL; doneP = false; lasttrain = NULL; prevtrain = NULL;
		moves = 0; location = NULL; destination = NULL; trips = 0;
		assignments = 0; peek = false; tmpStatus = false;
	}
	/** Copy constructor.  All slots are copied.
	  * @param other The originating instance.
	  */
	Car (Car &other) {
		type = other.type;
		marks = other.marks;
		number = other.number;
		divisions = other.divisions;
		length = other.length;
		plate = other.plate;
		weightclass = other.weightclass;
		ltwt = other.ltwt;
		ldlmt = other.ldlmt;
		loadedP = other.loadedP;
		mirrorP = other.mirrorP;
		fixedP = other.fixedP;
		owner = other.owner;
		doneP = other.doneP;
		lasttrain = other.lasttrain;
		prevtrain = other.prevtrain;
		moves = other.moves;
		location = other.location;
		destination = other.destination;
		trips = other.trips;
		assignments = other.assignments;
		peek = other.peek;
		tmpStatus = other.tmpStatus;
	}
	/** Assignment operator.  All slots are copied.
	  * @param other The right hand operand.
	  */
	Car & operator= (Car &other) {
		type = other.type;
		marks = other.marks;
		number = other.number;
		divisions = other.divisions;
		length = other.length;
		plate = other.plate;
		weightclass = other.weightclass;
		ltwt = other.ltwt;
		ldlmt = other.ldlmt;
		loadedP = other.loadedP;
		mirrorP = other.mirrorP;
		fixedP = other.fixedP;
		owner = other.owner;
		doneP = other.doneP;
		lasttrain = other.lasttrain;
		prevtrain = other.prevtrain;
		moves = other.moves;
		location = other.location;
		destination = other.destination;
		trips = other.trips;
		assignments = other.assignments;
		peek = other.peek;
		tmpStatus = other.tmpStatus;
		return *this;
	}
#endif
	/** Full constructor.  Fill all slots from the argument list.
	  * @param t Car type.
	  * @param m Reporting marks (railroad).
	  * @param n Number.
	  * @param d Division symbol list.
	  * @param l Length.
	  * @param p Plate.
	  * @param wc Weight class.
	  * @param lw Light (empty) weight.
	  * @param ldw Load limit (loaded weight).
	  * @param lp Is the car loaded?
	  * @param mp Can the car be mirrored?
	  * @param fp Does it have a fixed route?
	  * @param own Car owner.
	  * @param dp Is it done moving?
	  * @param lt The last train to handle this car.
	  * @param mvs The number of times this car has been moved this session.
	  * @param loc The car's current location.
	  * @param dest The car's destination.
	  * @param trps The number of trips this car has made.
	  * @param asgns The number of times this car has been assigned.
	  */
	Car (char t, const char *m, const char *n, const char *d, int l, int p,
	     int wc, int lw, int ldw, bool lp, bool mp, bool fp,
	     const Owner *own, bool dp,const Train *lt,int mvs,Industry *loc,
	     Industry *dest,int trps, int asgns) {
	     	type = t; marks = m; number = n; divisions = d; length = l;
		plate = p; weightclass = wc; ltwt = lw; ldlmt = ldw;
		loadedP = lp; mirrorP = mp; fixedP = fp; owner = own;
		doneP = dp; prevtrain = lasttrain = lt; moves = mvs; 
		location = loc; destination = dest; trips = trps; 
		assignments = asgns;
	}
	/** Return the car type.
	  */
	char Type() const {return type;}
	/** Set the car type.
	  *  @param t The new car type.
	  */
	void SetType(char t) {type = t;}
	/** Return the car's reporting marks (railroad).
	  */
	const char *Marks() const {return marks.c_str();}
#ifdef SWIG
	void SetMarks(const char *m);
#else
	/** Set the car's reporting marks.
	  */
	void SetMarks(string m) {marks = m;}
#endif	
	/** Return the car's number.
	  */
	const char *Number() const {return number.c_str();}
#ifdef SWIG
	void SetNumber(const char *n);
#else
	/** Set the car's number.
	  */
	void SetNumber(string n) {number = n;}
#endif
	/** Return the car's division list.
	  */
	const char *Divisions() const {return divisions.c_str();}
#ifdef SWIG
	void SetDivisions(const char *d);
#else
	/** Set the car's division list.
	  */
	void SetDivisions(string d) {divisions = d;}
#endif
	/** Return the car's length.
	  */
	int Length() const {return length;}
	/** Set the car's length.
	  */
	void SetLength(int l) {length = l;}
	/** Return the car's clearence plate.
	  */
	int Plate() const {return plate;}
	/** Set the car's clearence plate.
	  */
	void SetPlate(int p) {plate = p;}
	/** Return the car's weight class.
	  */
	int WeightClass() const {return weightclass;}
	/** Set the car's weight class.
	  */
	void SetWeightClass(int wc) {weightclass = wc;}
	/** Return the car's empty weight.
	  */
	int LtWt() const {return ltwt;}
	/** Set the car's empty weight.
	  */
	void SetLtWt(int lw) {ltwt = lw;}
	/** Return the car's load limit.
	  */
	int LdLmt() const {return ldlmt;}
	/** Set the car's load limit.
	  */
	void SetLdLmt(int ldw) {ldlmt = ldw;}
	/** Is the car loaded?
	  */
	bool LoadedP() const {return loadedP;}
	/** Is the car empty?
	  */
	bool EmptyP() const {return !loadedP;}
	/** Load the car.
	  */
	void Load() {loadedP = true;}
	/** Unload the car.
	  */
	void UnLoad() {loadedP = false;}
	/** Is it OK to mirror this car?
	  */
	bool OkToMirrorP() const {return mirrorP;}
	/** Set this car's mirror status.
	  */
	void SetOkToMirrorP(bool m) {mirrorP = m;}
	/** Is this car on a fixed route?
	  */
	bool FixedRouteP() const {return fixedP;}
	/** Set whether this car is on a fixed route.
	  */
	void SetFixedRouteP(bool f) {fixedP = f;}
	/** Return the car's owner.
	  */
	const Owner *CarOwner() const {return owner;}
	/** Set the car's owner.
	  */
	void SetCarOwner(const Owner *o) {owner = o;}
	/** Is this car done?
	  */
	bool IsDoneP() const {return doneP;}
	/** Flag this car as done.
	  */
	void SetDone() {doneP = true;}
	/** Flag this car as not done.
	  */
	void SetNotDone() {doneP = false;}
	/** Return the last train to move this car.
	  */
	const Train *LastTrain() const {return lasttrain;}
	/** Set the last train to move this car.
	  */
	void SetLastTrain(const Train *lt) {lasttrain = lt;}
	/** Return the previous train to move this car.
	  */
	const Train *PrevTrain() const {return prevtrain;}
	/** Set the previous train to move this car.
	  */
	void SetPrevTrain(const Train *lt) {prevtrain = lt;}
	/** Return the number of movements this session.
	  */
	int MovementsThisSession() const {return moves;}
	/** Clear the number of movements this session.
	  */
	void ClearMovementsThisSession() {moves = 0;}
	/** Increment the number of movements this session.
	  */
	void IncrmentMovementsThisSession() {moves++;}
	/** Return the location of this car.
	  */
	Industry *Location() const {return location;}
	/** Set the location of this car.
	  */
	void SetLocation(Industry *newloc) {location = newloc;}
	/** Return the destination of this car.
	  */
	Industry *Destination() const {return destination;}
	/** Set the destination of this car.
	  */
	void SetDestination(Industry *newdest) {destination = newdest;}
	/** Return the number of trips this car has had.
	  */
	int Trips() const {return trips;}
	/** Clear the number of trips this car has had.
	  */
	void ClearTrips() {trips = 0;}
	/** Increment the number of trips this car has had.
	  */ 
	void IncrementTrips() {trips++;}
	/** Return the number of assignments this car has had.
	  */
	int Assignments() const {return assignments;}
	/** Set the number of assignments this car has had.
	  */
	void SetAssignments(int a) {assignments = a;}
	/** Clear the number of assignments this car has had.
	  */
	void ClearAssignments() {assignments = 0;}
	/** Increment the number of assignments this car has had.
	  */
	void IncrementAssignments() {assignments++;}
	/** Return the peek flag.
	  */
	bool Peek() const {return peek;}
	/** Set or clear the peek flag.
	  */
	void SetPeek(bool p = false) {peek = p;}
#ifndef SWIG
	/** The System class is a friend.
	  */
	friend class System;
private:
	/** The owner of this car. 
	  */
	const Owner *owner;
	/** The last train to handle this car.
	  */
	const Train *lasttrain;
	/** The previous train to handle this car.
	  */
	const Train *prevtrain;
	/** This car's location.
	  */
	Industry *location;
	/** This car's destination.
	  */
	Industry *destination;
	/** This car's reporting marks.
	  */
	string marks;
	/** This car's number.
	  */
	string number;
	/** This car's division list.
	  */
	string divisions;
	/** This car's length.
	  */
	int length;
	/** This car's clearance plate.
	  */
	int plate;
	/** This car's weight class.
	  */
	int weightclass;
	/** This car's empty weight.
	  */
	int ltwt;
	/** This car's loaded weight.
	  */
	int ldlmt;
	/** The number of trips this car has made.
	  */
	int trips;
	/** The number of moves this car has made.
	  */
	int moves;
	/** The number of assignments this car has had.
	  */
	int assignments;
	/** This car's loaded flag.
	  */
	bool loadedP;
	/** This car's mirror flag.
	  */
	bool mirrorP;
	/** This car's fixed route flag.
	  */
	bool fixedP;
	/** This car's done flag.
	  */
	bool doneP;
	/** This car's peel flak.
	  */
	bool peek;
	/** Temp status flag.
	  */
	bool tmpStatus;
	/** This car's type.
	  */
	char type;
#endif
};

#ifndef SWIG
#ifdef DEBUG
ostream& operator<< (ostream& stream, Car* car)
{
	if (car == NULL) stream << "<Car (nil)>";
	else stream << "<Car " << car->Marks() << ":" << car->Number() << ">"; 
	return stream;
}
#endif

/** @name CarVector
  * A vector of cars.
  */
typedef vector<Car *> CarVector;
#endif

#endif // _CAR_H_

