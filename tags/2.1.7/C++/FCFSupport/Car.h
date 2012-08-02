/* 
 * ------------------------------------------------------------------
 * Car.h - Car structure
 * Created by Robert Heller on Sun Aug 28 14:28:24 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

/** This class holds all of the information for a single car. Including its
    reporting marks, car number, type, division list, owner, length, weight,
    and so on.
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
  @param other The originating instance.
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
  @param other The right hand operand.
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
  @param t Car type.
  @param m Reporting marks (railroad).
  @param n Number.
  @param d Division symbol list.
  @param l Length.
  @param p Plate.
  @param wc Weight class.
  @param lw Light (empty) weight.
  @param ldw Load limit (loaded weight).
  @param lp Is the car loaded?
  @param mp Can the car be mirrored?
  @param fp Does it have a fixed route?
  @param own Car owner.
  @param dp Is it done moving?
  @param lt The last train to handle this car.
  @param mvs The number of times this car has been moved this session.
  @param loc The car's current location.
  @param dest The car's destination.
  @param trps The number of trips this car has made.
  @param asgns The number of times this car has been assigned.
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
/// Return the car type.
	char Type() const {return type;}
/** Set the car type.
  @param t The new car type.
  */
	void SetType(char t) {type = t;}
/// Return the car's reporting marks (railroad).
	const char *Marks() const {return marks.c_str();}
#ifdef SWIG
	void SetMarks(const char *m);
#else
///
	void SetMarks(string m) {marks = m;}
#endif	
///
	const char *Number() const {return number.c_str();}
#ifdef SWIG
	void SetNumber(const char *n);
#else
///
	void SetNumber(string n) {number = n;}
#endif
///
	const char *Divisions() const {return divisions.c_str();}
#ifdef SWIG
	void SetDivisions(const char *d);
#else
///
	void SetDivisions(string d) {divisions = d;}
#endif
///
	int Length() const {return length;}
///
	void SetLength(int l) {length = l;}
///
	int Plate() const {return plate;}
///
	void SetPlate(int p) {plate = p;}
///
	int WeightClass() const {return weightclass;}
///
	void SetWeightClass(int wc) {weightclass = wc;}
///
	int LtWt() const {return ltwt;}
///
	void SetLtWt(int lw) {ltwt = lw;}
///
	int LdLmt() const {return ldlmt;}
///
	void SetLdLmt(int ldw) {ldlmt = ldw;}
///
	bool LoadedP() const {return loadedP;}
///
	bool EmptyP() const {return !loadedP;}
///
	void Load() {loadedP = true;}
///
	void UnLoad() {loadedP = false;}
///
	bool OkToMirrorP() const {return mirrorP;}
///
	void SetOkToMirrorP(bool m) {mirrorP = m;}
///
	bool FixedRouteP() const {return fixedP;}
///
	void SetFixedRouteP(bool f) {fixedP = f;}
///
	const Owner *CarOwner() const {return owner;}
///
	void SetCarOwner(const Owner *o) {owner = o;}
///
	bool IsDoneP() const {return doneP;}
///
	void SetDone() {doneP = true;}
///
	void SetNotDone() {doneP = false;}
///
	const Train *LastTrain() const {return lasttrain;}
///
	void SetLastTrain(const Train *lt) {lasttrain = lt;}
///
	const Train *PrevTrain() const {return prevtrain;}
///
	void SetPrevTrain(const Train *lt) {prevtrain = lt;}
///
	int MovementsThisSession() const {return moves;}
///
	void ClearMovementsThisSession() {moves = 0;}
///
	void IncrmentMovementsThisSession() {moves++;}
///
	Industry *Location() const {return location;}
///
	void SetLocation(Industry *newloc) {location = newloc;}
///
	Industry *Destination() const {return destination;}
///
	void SetDestination(Industry *newdest) {destination = newdest;}
///
	int Trips() const {return trips;}
///
	void ClearTrips() {trips = 0;}
///
	void IncrementTrips() {trips++;}
///
	int Assignments() const {return assignments;}
///
	void SetAssignments(int a) {assignments = a;}
///
	void ClearAssignments() {assignments = 0;}
///
	void IncrementAssignments() {assignments++;}
///
	bool Peek() const {return peek;}
///
	void SetPeek(bool p = false) {peek = p;}
#ifndef SWIG
	friend class System;
/** 
*/
	friend ostream & operator << (ostream & stream, Car *car) {
		if (car == NULL) stream << "<Car (nil)>";
		else stream << "<Car " << car->Marks() << ":" << car->Number() << ">"; 
		return stream;
	}
private:
///
	const Owner *owner;
///
	const Train *lasttrain;
///
	const Train *prevtrain;
///
	Industry *location;
///
	Industry *destination;
///
	string marks;
///
	string number;
///
	string divisions;
///
	int length;
///
	int plate;
///
	int weightclass;
///
	int ltwt;
///
	int ldlmt;
///
	int trips;
///
	int moves;
///
	int assignments;
///
	bool loadedP;
///
	bool mirrorP;
///
	bool fixedP;
///
	bool doneP;
///
	bool peek;
///
	bool tmpStatus;
///
	char type;
#endif
};

#ifndef SWIG
///
typedef vector<Car *> CarVector;
#endif

#endif // _CAR_H_

