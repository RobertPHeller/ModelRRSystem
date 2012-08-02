/* 
 * ------------------------------------------------------------------
 * System.h - System Class
 * Created by Robert Heller on Thu Aug 25 09:58:32 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
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

#ifndef _SYSTEM_H_
#define _SYSTEM_H_

#ifndef SWIG
#include <Common.h>
#include <PathName.h>
#include <Station.h>
#include <Division.h>
#include <Train.h>
#include <Industry.h>
#include <CarType.h>
#include <Owner.h>
#include <Car.h>
#include <CallBack.h>
#include <Printer.h>
#include <SwitchList.h>
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


#include <string.h>
%typemap(tcl8,in) System::CarTypeReport {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	char *p;
	p = Tcl_GetString($source);
	if (p == NULL || strlen(p) < 1) {
	  Tcl_SetStringObj(tcl_result,"Missing CarTypeReport, should be one of all, type, or summary",-1);
	  return TCL_ERROR;
	} else if (strncasecmp("all",p,strlen(p)) == 0) {
	  $target = System::All;
	} else if (strncasecmp("type",p,strlen(p)) == 0) {
	  $target = System::Type;
	} else if (strncasecmp("summary",p,strlen(p)) == 0) {
	  $target = System::Summary;
	} else {
	  Tcl_SetStringObj(tcl_result,"Bad CarTypeReport, should be one of all, type, or summary",-1);
	  return TCL_ERROR;
	}
#else
	char *p;
	p = Tcl_GetString($input);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (p == NULL || strlen(p) < 1) {
	  Tcl_SetStringObj(tcl_result,"Missing CarTypeReport, should be one of all, type, or summary",-1);
	  return TCL_ERROR;
	} else if (strncasecmp("all",p,strlen(p)) == 0) {
	  $1 = System::All;
	} else if (strncasecmp("type",p,strlen(p)) == 0) {
	  $1 = System::Type;
	} else if (strncasecmp("summary",p,strlen(p)) == 0) {
	  $1 = System::Summary;
	} else {
	  Tcl_SetStringObj(tcl_result,"Bad CarTypeReport, should be one of all, type, or summary",-1);
	  return TCL_ERROR;
	}
#endif
}

%typemap(tcl8,in) System::CarLocationType {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	char *p;
	p = Tcl_GetString($source);
	if (p == NULL || strlen(p) < 1) {
	  Tcl_SetStringObj(tcl_result,"Missing CarLocationType, should be one of industry, station, division, or all",-1);
	  return TCL_ERROR;
	} else if (strncasecmp("industry",p,strlen(p)) == 0) {
	  $target = System::INDUSTRY;
	} else if (strncasecmp("station",p,strlen(p)) == 0) {
	  $target = System::STATION;
	} else if (strncasecmp("division",p,strlen(p)) == 0) {
	  $target = System::DIVISION;
	} else if (strncasecmp("all",p,strlen(p)) == 0) {
	  $target = System::ALL;
	} else {
	  Tcl_SetStringObj(tcl_result,"Bad CarLocationType, should be one of industry, station, division, or all",-1);
	  return TCL_ERROR;
	}
#else
	char *p;
	p = Tcl_GetString($input);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (p == NULL || strlen(p) < 1) {
	  Tcl_SetStringObj(tcl_result,"Missing CarLocationType, should be one of industry, station, division, or all",-1);
	  return TCL_ERROR;
	} else if (strncasecmp("industry",p,strlen(p)) == 0) {
	  $1 = System::INDUSTRY;
	} else if (strncasecmp("station",p,strlen(p)) == 0) {
	  $1 = System::STATION;
	} else if (strncasecmp("division",p,strlen(p)) == 0) {
	  $1 = System::DIVISION;
	} else if (strncasecmp("all",p,strlen(p)) == 0) {
	  $1 = System::ALL;
	} else {
	  Tcl_SetStringObj(tcl_result,"Bad CarLocationType, should be one of industry, station, division, or all",-1);
	  return TCL_ERROR;
	}
#endif
}

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
#else
%nodefault;
#endif

#endif
/**   \TEX{\typeout{Generated from $Id$.}}
	This is the main Freight Car Forwarder class.  It implements all of the
	basic data and algorithms used in the the Freight Car Forwarder system.

	This class includes code to load a model railroad ``system''
	(divisions, stations, industries, cars, and trains) along with code to
	assign cars to trains, run trains, generate yard switch lists, and
	various reports.  Basically everything you need run realistic trains
	on a layout.

	This is my second port of Tim O'Connors Freight Car Forwarding system,
	originally written in QBasic for use with the North Shore Model RR
	Club ``Chesapeake System''.
 */
class System {
#ifndef SWIG
protected:
	/**   The default constructor.  This is protected to prevent the
	  creation of an uninitialized class instance.  It simply makes no
	  sense to create a system without loading a system file. */
	System () {}
#endif

public:
	/**   The constructor for the system.  Takes the path to a system
	  file (typically #system.dat#) and loads the complete system.
	  The system file contains the names of the additional files, containing
	  the remaining system data.  All of the files are presumbed to exist in
	  the same directory as the system file.  All of the files are loaded
	  and a sanity check is made to insure that the data is sane.
	  @param systemfile Pathname to the system file.
	  @param seed Seed value for the random number generator.
	  @param outmessage Pointer to a pointer to receive any error messages
		  for any errors that might occur.*/
	System (const char *systemfile,int seed,char **outmessage = NULL);
	/**   The destructor frees all memory and generally cleans things
	  up. */
	~System();
	///  Return the system name.  This is read from the system file.
	const char *SystemName() const {return systemName.c_str();}
	///  Return the system file's full path name.
	const char *SystemFile() const {return systemFile.FullPath().c_str();}
	///  Return the industry file's full path name.
	const char *IndustriesFile() const {return industriesFile.FullPath().c_str();}
	///  Return the trains file's full path name.
	const char *TrainsFile() const {return trainsFile.FullPath().c_str();}
	///  Return the train orders file's full path name.
	const char *OrdersFile() const {return ordersFile.FullPath().c_str();}
	///  Return the Owners file's full path name.
	const char *OwnersFile() const {return ownersFile.FullPath().c_str();}
	///  Return the Car Types file's full path name.
	const char *CarTypesFile() const {return carTypesFile.FullPath().c_str();}
	///  Return the Cars file's full path name.
	const char *CarsFile() const {return carsFile.FullPath().c_str();}
	///  Return the Statistics file's full path name.
	const char *StatsFile() const {return statsFile.FullPath().c_str();}
	///  return the number of divisions loaded.
	int NumberOfDivisions() const {return divisions.size();}
	/**   Find a division by its index.  Returns either a pointer
	  to the division or NULL.
	  @param i The division index to look for.*/
	const Division *FindDivisionByIndex(int i) const {
		DivisionMap::const_iterator Dx = divisions.find(i);
		if (Dx == divisions.end()) return NULL;
		else return Dx->second;
	}
	/**   Find a division by its symbol. Returns either a pointer
	  to the division or NULL.
	  @param symbol The division symbol to look for.*/
	const Division *FindDivisionBySymbol(char symbol) const;
	/**   Division indexing function.  Warning: if the division at the
	  specificed index does not already exist, a new element is allocated
	  with a NULL pointer.
	  @param i The division index to access.*/
	Division *TheDivision(int i) {return divisions[i];}
	///  The number of stations loaded.
	int NumberOfStations() const {return stations.size();}
	/**   Station indexing function.  Warning: if the station at the
	  specificed index does not already exist, a new element is allocated
	  with a NULL pointer.
	  @param i The station index to access.*/
	Station *TheStation(int i) {return stations[i];}
	///  The number of trains loaded.
	int NumberOfTrains() const {return trains.size();}
	/**   Train indexing function.  Warning: if the train at the
	  specificed index does not already exist, a new element is allocated
	  with a NULL pointer.
	  @param i The train index to access.*/
	Train *TrainByIndex(int i) {return trains[i];}
	/**   Find a train by its index.  Returns either a pointer
	  to the train or NULL.
	  @param i The train index to look for.*/
	const Train *FindTrainByIndex(int i) const {
		TrainMap::const_iterator Tx = trains.find(i);
		if (Tx == trains.end()) return NULL;
		else return Tx->second;
	}
	/**   Train indexing (by name) function.  Warning: if the train
	  at the specificed index (name) does not already exist, a new
	  element is allocated with a NULL pointer.
	  @param name Train name to access.*/
	Train *TrainByName(const char *name) {return trainIndex[name];}
	/**   Find a train by its name.  Returns either a pointer
	  to the train or NULL.
	  @param name Train name to look for.*/
	const Train *FindTrainByName(const char *name) const {
		TrainNameMap::const_iterator Tx = trainIndex.find(name);
		if (Tx == trainIndex.end()) return NULL;
		else return Tx->second;
	}
	///  Return the number of industries loaded.
	int NumberOfIndustries() const {return industries.size();}
	/**   Industry indexing function.  Warning: if the industry at the
	  specificed index does not already exist, a new element is allocated
	  with a NULL pointer.
	  @param i The industry index to access.*/
	Industry *TheIndustry(int i) {return industries[i];}
	/**   Find an industry by its index. Returns either a pointer
	  to the industry or NULL.
	  @param i The industry index to look for.*/
	const Industry *FindIndustryByIndex(int i) const {
		IndustryMap::const_iterator Ix = industries.find(i);
		if (Ix == industries.end()) return NULL;
		else return Ix->second;
	}
#ifdef SWIG
	const Industry *FindIndustryByName(const char *name) const;
#else
	/**   Find an industry by its name. Returns either a pointer
	  to the industry or NULL.
	  @param name Industry name to look for.*/
	const Industry *FindIndustryByName(string name) const;
#endif
	/**   Access a car type by index.
	  @param i The car type index.*/
	char CarTypesOrder(int i) const {
		if (i < 0 || i >= CarType::MaxCarTypes) {
			return ',';
		} else {
			return carTypesOrder[i];
		}
	}
	/**   Car type order index.  Get the index of a car type.
	  @param type The car type to lookup.*/
	int CarTypesOrderIndex(char type) const;
	/**   Get a car type class instance pointer given a car type.
	  @param c The car type to lookup.*/
	CarType *TheCarType(char c) {return carTypes[c];}
	/**   Get a car class instance pointer given a car group index.
	  @param i The car group index.*/
	CarGroup *TheCarGroup(int i) const {
		if (i <0 || i >= CarGroup::MaxCarGroup) return NULL; 
		else return carGroups[i];
	}
	int NumberOfCars() const {return cars.size();}
	/**   Get a car owner class instance pointer given a car owner's
		   initials.
	  @param initials The car owner's initials.*/
	Owner *TheOwner(const char *initials) {return owners[initials];}
	/**   Create a new owner given a set of initials.
	  @param initials The new car owner's initials.*/
	void AddOwner(const char *initials) {
		if (owners[initials] == NULL) {
			owners[initials] = new Owner(initials,initials,"");
		}
	}
	/**   Get a car by index.
	  @param i The car's index.*/
	Car *TheCar(int i) const {
		if (i < 0 || i >= cars.size()) return NULL;
		else return cars[i];
	}
	/**   Add a new car to the array of cars.
	  @param newcar The new car.*/
	void AddCar(Car *newcar) {cars.push_back(newcar);}
	/**   Return the session number.*/
	int SessionNumber() const {return sessionNumber;}
	/**   Return the shift number.*/
	int ShiftNumber() const {return shiftNumber;}
	/**   Return the total number of shifts.*/
	int TotalShifts() const {return totalShifts;}
	/**   Increment the shift number.*/
	int NextShift() {
		shiftNumber++;
		totalShifts++;
		if (shiftNumber > 3) {
			sessionNumber++;
			shiftNumber = 1;
		}
		return shiftNumber;
	}
	/**   Return the total number of cars. */
	int TotalCars() const {return cars.size();}
	/**   Ran all trains? */
	int RanAllTrains() const {return ranAllTrains;}
	/**   Delete all existing cars. */
	void DeleteAllExistingCars();
	/**   (Re-)Load the car file.
	  @param outmessage Buffer pointer for error messages.*/
	bool LoadCarFile(char **outmessage = NULL);
	/**   Load the stats file.
	  @param outmessage Buffer pointer for error messages.*/
	bool LoadStatsFile(char **outmessage = NULL);
	/**   Save cars (and stats).
	  @param outmessage Buffer pointer for error messages.*/
	bool SaveCars(char **outmessage = NULL);
	/**   Return a pointer to the scrap yard.*/
	const Industry *IndScrapYard() const {return &indScrapYard;}
	/**   Return the current stats period.*/
	int StatsPeriod() const {return statsPeriod;}
	/**   Return a train's index.
	  @param train The train to lookup.*/
	int TrainIndex(const Train *train) const;
	/**   Return an industry's index.
	  @param indus The industry to lookup. */
	int IndustryIndex(const Industry *indus) const;
	///  Return the number of cars moved.
	int CarsMoved() const {return carsMoved;}
	///  Return the number of cars that are at their destinations.
	int CarsAtDest() const {return carsAtDest;}
	///  Return the number of cars not moved at all.
	int CarsNotMoved() const {return carsNotMoved;}
	///  Return the number of cars moved once.
	int CarsMovedOnce() const {return carsMovedOnce;}
	///  Return the number of cars moved twice.
	int CarsMovedTwice() const {return carsMovedTwice;}
	///  Return the number of cars moved three times.
	int CarsMovedThree() const {return carsMovedThree;}
	///  Return the number of cars moved more then three times.
	int CarsMovedMore() const {return carsMovedMore;}
	///  Return the total number of car movements.
	int CarMovements() const {return carMovements;}
	///  Return the number of cars still in transit.
	int CarsInTransit() const {return carsInTransit;}
	///  Return the number of cars on the RIP track (the workbench).
	int CarsAtWorkBench() const {return carsAtWorkBench;}
	/**   Return the number of cars at their destinations plus the
	  number of cars in transit. */
	int CarsAtDest_CarsInTransit() const {return carsAtDest_carsInTransit;}
	///  Print yard lists flag.
	bool PrintYards() const {return printYards;}
	/**  Set the print yard lists flag.
	  @param flag New value to set the flag to.*/
	void SetPrintYards(bool flag) {printYards = flag;}
	///  Print the alphabetical listing flag.
	bool PrintAlpha() const {return printAlpha;}
	/**  Set the print alphabetical listing flag.
	  @param flag New value to set the flag to.*/
	void SetPrintAlpha(bool flag) {printAlpha = flag;}
	///  Print second copy of the alphabetical listing flag.
	bool PrintAtwice() const {return printAtwice;}
	/** Set the print second copy of the alphabetical listing flag.
	  @param flag New value to set the flag to.*/
	void SetPrintAtwice(bool flag) {printAtwice = flag;}
	///  Print the switch list order flag.
	bool PrintList() const {return printList;}
	/**  Set the print switch list order flag.
	  @param flag New value to set the flag to.*/
	void SetPrintList(bool flag) {printList = flag;}
	///  Print a second copy of the switch list order flag.
	bool PrintLtwice() const {return printLtwice;}
	/**  Set the print a second copy of the switch list order flag.
	  @param flag New value to set the flag to.*/
	void SetPrintLtwice(bool flag) {printLtwice = flag;}
	///  Print dispatcher report sheet.
	bool PrintDispatch() const {return printDispatch;}
	/**  Set the print dispatcher report sheet.
	  @param flag New value to set the flag to.*/
	void SetPrintDispatch(bool flag) {printDispatch = flag;}
	///  Print train enroute switch list.
	bool Printem() const {return printem;}
	/**  Set the print train enroute switch list.
	  @param flag New value to set the flag to.*/
	void SetPrintem(bool flag) {printem = flag;}
	///  Return a pointer to the RIP track (workbench).
	const Industry *IndRipTrack() {return industries[0];}
	///  Const version of the pointer to the RIP track (workbench).
	const Industry *IndRipTrackConst() const {
		IndustryMap::const_iterator rt = industries.find(0);
		if (rt == industries.end()) return NULL;
		else return (rt->second);
	}
	///  Reset loop variables.
	void RestartLoop();
	/**  Set the random seed.
	  @param seed Seed value.*/
	void Randomize(int seed) {srand(seed);}
	///  Return a random number between 0.0 and 1.0.
	double Random() {return rand()/(RAND_MAX+1.0);}
	/**   Car assignment procedure.  The is one of the main workhorse
	  procedures.  It goes through all of the cars, finding ones that are
	  ready to be moved and determines where they could be moved to, based
	  on a number of critiera, such as whether they are loaded or empty,
	  whether they are in their home divisions or not, and so on. 
	  @param WIP Work in progress callback.
	  @param log Log message callback.
	  @param banner Show banner callback.
	  @param outmessage Buffer pointer for error messages.*/
	void CarAssignment(const WorkInProgressCallback *WIP,
		const LogMessageCallback *log,
		const ShowBannerCallback *banner,
		char **outmessage = NULL);
	/**   Run all trains procedure.  The is another workhorse 
	  procedure.  This procedure runs the initial box moves, then the
	  way freights and manifest trains.  It is necessary to run the box moves 
	  again after running this procedure, unless additional sections of
	  the way freights or manifest trains need to be run first.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	  @param printer Printer device.
	  @param traindisplay Train display callback.
	  */
	void RunAllTrains(const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner,
		PrinterDevice          *printer,
		const TrainDisplayCallback   *traindisplay);
	/**   Run all boxmove trains.  The is another workhorse
	  procedure.  This procedure runs all of the box moves.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	  @param printer Printer device.
	  @param traindisplay Train display callback.
	*/
	void RunBoxMoves(const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner,
		PrinterDevice          *printer,
		const TrainDisplayCallback   *traindisplay);
	/**  Print all of the various yard and switch lists.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	  @param printer Printer device.
	*/
	void PrintAllLists(const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner,
		PrinterDevice          *printer);
	/**   Run one single train.
	  @param train The train to run.
	  @param boxMove Is this a box move?
	  @param traindisplay Train display callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void RunOneTrain(Train *train,bool boxMove,
		const TrainDisplayCallback   *traindisplay,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Display cars not moved.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	*/
	void ShowCarsNotMoved(const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner) const;
	/**  Show all car movements.
	  @param showAll Show all movements?
	  @param Ix Show movements by industry.
	  @param Tx Show movements by train.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	*/
	void ShowCarMovements(bool showAll,const Industry *Ix,const Train *Tx,
		const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner) const;
	/**  Show cars moved by a specific train.
	  @param Tx The specific train.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	*/
	void ShowTrainCars(const Train *Tx,
		const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner) const;
#ifdef NOPE
	void CompileCarMovements(
		const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner
	) const;
#endif
	/**  Show cars in a specificed division.
	  @param division The specific division.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	*/
	void ShowCarsInDivision(const Division *division,
		const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner) const;
	/**  Show train totals.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	*/
	void ShowTrainTotals(const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner) const;
	/**  Show unassigned cars.
	  @param Log Log message callback.
	  @param banner Show banner callback.
	*/
	void ShowUnassignedCars(const LogMessageCallback     *Log,
		const ShowBannerCallback     *banner) const;
	/**  Reload car file.
	  @param outmessage Buffer pointer for error messages.*/
	void ReLoadCarFile(char **outmessage) {
	     if (!LoadCarFile(outmessage)) return;
	     if (!LoadStatsFile(outmessage)) return;
	     RestartLoop();
	}
	///  Reset industry statistics.
	void ResetIndustryStats();
	/**  Report on all industries.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportIndustries(const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL) const;
	/**  Report on all trains.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportTrains(const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL) const;
	/**  Report on all cars.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportCars(const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL) const;
	/**  Report on cars not moved.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportCarsNotMoved(const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL) const;
	///  Types of car type reports.
	enum CarTypeReport {
		///  Report on all car types.
		All,
		///  Report on one type.
		Type,
		///  Report summary.
		Summary
	};
	/**  Report on car types.
	  @param rtype Type of report to produce.
	  @param carType Car type to report on (only used when the report
		  type is for a single type).
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportCarTypes(CarTypeReport rtype,char carType,
		PrinterDevice          *printer,
		char **outmessage = NULL) const;
	///  Types of location report.
	enum CarLocationType {
		///  Report by industry.
		INDUSTRY,
		///  Report by station.
		STATION,
		///  Report by division.
		DIVISION,
		///  Report on all locations.
		ALL
	};
	/**  Car location report.
	  @param cltype Type of report.
	  @param index Index of thing to report by (industry, station, or
		  division).
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportCarLocations(CarLocationType cltype,int index,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL);
	/**  Industry analysis report.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportAnalysis(const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL) const;
#ifdef SWIG
	void ReportCarOwners(const char * ownerInitials,
			     const WorkInProgressCallback *WIP,
			     const LogMessageCallback     *Log,
				   PrinterDevice          *printer,
			     char **outmessage = NULL) const;
#else
	/**  Report on a specified car owner.
	  @param ownerInitials Car owner's initials to report on.
	  @param WIP Work in progress callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportCarOwners(string ownerInitials,
		const WorkInProgressCallback *WIP,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL) const;
#endif
	/**  Find an industry's index.
	  @param industry The industry to look for.
	*/
	int FindIndustryIndex(const Industry *industry) const;
	/**  Find a station's index.
	  @param station The station to look for.
	*/
	int FindStationIndex(const Station *station) const;
	/**  Find a division's index.
	  @param division The division to look for.
	*/
	int FindDivisionIndex(const Division *division) const;
#ifndef SWIG
	/**  Return car status information.
	  @param car The car to look up.
	  @param status Its status (loaded or empty).
	  @param carTypeDescr Its car type description.
	*/
	void GetCarStatus(const Car *car,string &status,string &carTypeDescr) const;
	///  Iterator of the first division in the division map.
	DivisionMap::const_iterator FirstDivision() const {return divisions.begin();}
	///  Iterator of one past the last division in the division map.
	DivisionMap::const_iterator LastDivision() const {return divisions.end();}
	///  Iterator of the first station in the station map.
	StationMap::const_iterator FirstStation() const {return stations.begin();}
	///  Iterator of one past the last station in the station map.
	StationMap::const_iterator LastStation() const {return stations.end();}
	///  Iterator of the first train in the train map.
	TrainMap::const_iterator FirstTrain() const {return trains.begin();}
	///  Iterator of one past the last train in the train map.
	TrainMap::const_iterator LastTrain() const {return trains.end();}
	///  Iterator of the first industry in the industry map.
	IndustryMap::const_iterator FirstIndustry() const {return industries.begin();}
	///  Iterator of one past the last industry in the industry map.
	IndustryMap::const_iterator LastIndustry() const {return industries.end();}
	///  Iterator of the first car type in the car type map.
	CarTypeMap::const_iterator FirstCarType() const {return carTypes.begin();}
	///  Iterator of one past the last car type in the car type map.
	CarTypeMap::const_iterator LastCarType() const {return carTypes.end();}
	///  Iterator of the first owner in the owner map.
	OwnerMap::const_iterator FirstOwner() const {return owners.begin();}
	///  Iterator of one past the last owner in the owner map.
	OwnerMap::const_iterator LastOwner() const {return owners.end();}
	/**  Search for cars with a specificed number.
	  @param number The number string to look for.
	  @param subStringP Match the whole number or only the last few digits.
	*/
	vector<int> SearchForCarIndexesByNumber(string number,bool subStringP) const;
	/**  Search for a train by name given a glob pattern.
	  @param trainNamePattern The name pattern.
	*/
	vector<int> SearchForTrainPattern(string trainNamePattern) const;
	/**  Search for an industry by name given a glob pattern.
	  @param industryNamePattern The name pattern.
	*/
	vector<int> SearchForIndustryPattern(string industryNamePattern) const;
private:
	///  Full pathname of the system file.
	PathName systemFile;
	///  The system name.
	string systemName;
	///  Full pathname of the industries file.
	PathName industriesFile;
	///  Full pathname of the trains file.
	PathName trainsFile;
	///  Full pathname of the train orders file.
	PathName ordersFile;
	///  Full pathname of the car owners file.
	PathName ownersFile;
	///  Full pathname of the car types file.
	PathName carTypesFile;
	///  Full pathname of the cars file.
	PathName carsFile;
	///  Full pathname of the stats file.
	PathName statsFile;
	///  Division map.
	DivisionMap divisions;
	///  Station map.
	StationMap stations;
	///  Train map.
	TrainMap trains;
	///  Train name map.
	TrainNameMap trainIndex;
	///  Industries map.
	IndustryMap industries;
	///  Car type order vector.
	char carTypesOrder[CarType::MaxCarTypes];
	///  Car type map.
	CarTypeMap carTypes;
	///  Car group vector.
	CarGroup *carGroups[CarGroup::MaxCarGroup];
	///  Car owner map.
	OwnerMap owners;
	///  Car vector.
	CarVector cars;
	///  Switch lists.
	SwitchList switchList;
	///  Current session number.
	int sessionNumber;
	///  Current shift number.
	int shiftNumber;
	///  The total number of shifts.
	int totalShifts;
	///  The ran all trains flag.
	int ranAllTrains;
	///  The total number of pickups.
	int totalPickups;
	///  The total number of loads.
	int totalLoads;
	///  The total number of tons.
	int totalTons;
	///  The total number of revenue tons.
	int totalRevenueTons;
	///  Train print flag.
	bool trainPrintOK;
	///  Way freight flag.
	bool wayFreight;
	///  Deliver flag.
	bool deliver;
	///  Train length.
	int trainLength;
	///  The number of cars on a train.
	int numberCars;
	///  The number of tons on a train.
	int trainTons;
	///  The number of loads on a train.
	int trainLoads;
	///  The number of empties on a train.
	int trainEmpties;
	///  The longest a train has been.
	int trainLongest;
	///  Current division.
	Division *curDiv;
	///  Origin Yard.
	Industry *originYard;
	///  A trains last location.
	Industry *trainLastLocation;
	///  A temporary for a car's location.
	Industry *carDest;
	///  The current stats period.
	int statsPeriod;
	///  The number of cars moved.
	int carsMoved;
	///  The number of cars at their destinations.
	int carsAtDest;
	///  The number of cars not moved.
	int carsNotMoved;
	///  The number of cars moved one time.
	int carsMovedOnce;
	///  The number of cars moved two times.
	int carsMovedTwice;
	///  The number of cars moved three times.
	int carsMovedThree;
	///  The number of cars moved more then three times.
	int carsMovedMore;
	///  The number of cars movements.
	int carMovements;
	///  The number of cars in transit.
	int carsInTransit;
	///  The number of cars at the workbench.
	int carsAtWorkBench;
	///  The number of cars at their destinations and still in transit.
	int carsAtDest_carsInTransit;
	///  Flag for printing yard switch lists.
	bool printYards;
	///  Flag for printing alphabetical lists.
	bool printAlpha;
	///  Flag for printing a second copy of alphabetical lists.
	bool printAtwice;
	///  Flag for printing train switch lists.
	bool printList;
	///  Flag for printing a second copy of train switch lists.
	bool printLtwice;
	///  Flag for printing a dispatcher's report.
	bool printDispatch;
	///  Flag for printing train movements.
	bool printem;
	///  Message buffer, used for error messages mostly.
	char messageBuffer[2048];
	/**   Helper utility function to trim white space off the ends of a
	  string.
	  @param line The string to trim.
	*/
	string trim(string line) const;
	///  String of white space characters.
	static const string whitespace;
	///  The pointer to the scrapyard.
	const Industry indScrapYard;
	/**  Helper utility to split a string into words.
	  @param s The string to split.
	  @param delimiter The delimiter character to split the string on.
	*/
	vector<string> split(string s,char delimiter) const;
	/**  Utility to get a line after skipping any intervening comments.
	  @param stream The input stream to read from.
	  @param buffer The result buffer.
	  @param message Error message to use if an error occurs.
	  @param outmessage Buffer pointer for error messages.*/
	bool SkipCommentsGets(istream &stream,string &buffer,
		const char *message, char **outmessage = NULL);
	/**  Utility to read a group limit.
	  @param stream The input stream to read from.
	  @param label The label for the group limit.
	  @param value The limit value read.
	  @param filename The filename being read from.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadGroupLimit(istream &stream,const char *label,int &value,
		const char *filename,char **outmessage = NULL);
	/**  Read in the division map.
	  @param stream The input stream to read from.
	  @param homemap The map of home yards.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadDivisions(istream &stream,map<int,int,less<int> > &homemap,
		char **outmessage = NULL);
	/**  Read in the station map.
	  @param stream The input stream to read from.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadStations(istream &stream,
		char **outmessage = NULL);
	/**  Read in the trains file.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadTrains(char **outmessage = NULL);
	/**  Read in the industries file.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadIndustries(char **outmessage = NULL);
	/**  Read in the train orders file.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadTrainOrders(char **outmessage = NULL);
	/**  Read in the car types file.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadCarTypes(char **outmessage = NULL);
	/**  Read in the owners file.
	  @param outmessage Buffer pointer for error messages.*/
	bool ReadOwners(char **outmessage = NULL);
	/**  Convert a string to an integer.
	  @param str The string to convert.
	  @param result The converted integer result buffer.
	  @param message The message to use in case there is an error.
	  @param outmessage Buffer pointer for error messages.*/
	bool StringToInt(string str,int &result,const char *message,
		char **outmessage = NULL) const;
	/**  Convert a string to an integer and check its range.
	  @param str The string to convert.
	  @param result The converted integer result buffer.
	  @param minv The permitted minimum value.
	  @param maxv The permitted maximum value.
	  @param message The message to use in case there is an error.
	  @param outmessage Buffer pointer for error messages.*/
	bool StringToIntRange(string str,int &result,int minv,int maxv,
		const char *message,char **outmessage = NULL) const;
	/**  Function to write one car to disk.
	  @param car The car to write.
	  @param stream The output stream to write to.
	*/
	bool WriteOneCarToDisk(Car *car,ostream &stream);
	/**  Check if an industry takes a certain car.
	  @param Ix The industry to check.
	  @param Cx The car to check.
	*/
	bool IndustryTakesCar(Industry *Ix,Car *Cx);
	/**   Check to see if a certain car can be mirrored on a fixed
	  route at a certain industry.
	  @param Cx The car to check.
	  @param Ix The industry to check.*/
	bool FixedRouteMirrorCheck(Car *Cx, Industry *Ix);
	/**  Find a car in a car vector.
	  @param cvect The car vector to search.
	  @param car The car to search for.
	*/
	CarVector::iterator FindCarInCarVector(CarVector &cvect,Car *car);
	/**  Find an industry in the industry map.
	  @param industry The industry to search for.
	*/
	IndustryMap::iterator FindIndustry(Industry *industry);
	///  Update industry car counts.
	void GetIndustryCarCounts();
	/**  Internal function to run a single train.
	  @param train The train to run.
	  @param boxMove Is this a box move?
	  @param traindisplay Train display callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void InternalRunOneTrain(Train *train,bool boxMove,
		const TrainDisplayCallback   *traindisplay,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  One one local train.
	  @param train The train to run.
	  @param boxMove Is this a box move?
	  @param consist The train's consist.
	  @param traindisplay Train display callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void RunOneLocal(Train *train, bool boxMove,CarVector &consist,
		const TrainDisplayCallback   *traindisplay,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  One one passenger train.
	  @param train The train to run.
	  @param boxMove Is this a box move?
	  @param traindisplay Train display callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void RunOnePassenger(Train *train,bool boxMove,
		const TrainDisplayCallback   *traindisplay,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Run one manifest freight train.
	  @param train The train to run.
	  @param boxMove Is this a box move?
	  @param consist The train's consist.
	  @param traindisplay Train display callback.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void RunOneManifest(Train *train, bool boxMove, CarVector &consist,
		const TrainDisplayCallback   *traindisplay,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Print a train's current location.
	  @param train The train to print.
	  @param Px The stop number that train is at. 
	  @param Log Log message callback.
	  @param traindisplay Train display callback.
	*/
	void PrintTrainLoc(Train *train,int Px,
		const LogMessageCallback     *Log,
		const TrainDisplayCallback   *traindisplay);
	/**  Make up a local train.
	  @param train The train to make up.
	  @param boxMove Is this a box move?
	  @param Px The stop number that train is at. 
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void TrainLocalOriginate(Train *train, bool boxMove,int Px,
		CarVector &consist,bool &didAction,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Log a car pickup in the switch list structure.
	  @param car The car picked up.
	  @param train The train that picked it up.
	  @param boxMove Is this a box move?
	*/
	void LogCarPickup(Car *car, Train *train,bool boxMove);
	/**  Drop cars from a local (box move or way freight).
	  @param train The train to drop cars from.
	  @param Px The stop number that train is at. 
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void TrainLocalDrops(Train *train,int Px, CarVector &consist,
		bool &didAction,const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Drop cars from a manifest freight.
	  @param train The train to drop cars from.
	  @param Px The stop number that train is at. 
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void TrainManifestDrops(Train *train, int Px, CarVector &consist,
		bool &didAction,const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Drop a single car.
	  @param car The car to drop.
	  @param train The train to drop the car from.
	  @param Lx The index of the car to drop.
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Px The stop number that train is at. 
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void TrainDropOneCar(Car *car,Train *train,CarVector::iterator Lx,
		CarVector &consist,bool &didAction,int Px,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**   Drop all cars from a train at the current stop (usually
	  the last stop). 
	  @param train The train to drop cars from.
	  @param Px The stop number that train is at. 
	  @param consist The train's consist.
	  @param Log Log message callback.
	  @param printer Printer device.
	  */
	void TrainDropAllCars(Train *train, int Px, CarVector &consist,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Pick up cars for a local train (box move or way freight).
	  @param train The train to pick up cars for.
	  @param boxMove Is this a box move?
	  @param Px The stop number that train is at. 
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void TrainLocalPickups(Train *train, bool boxMove,int Px,
		CarVector &consist,bool &didAction,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Pick up cars for a manifest freight train.
	  @param train The train to pick up cars for.
	  @param boxMove Is this a box move?
	  @param Px The stop number that train is at. 
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void TrainManifestPickups(Train *train, bool boxMove,int Px,
		CarVector &consist,bool &didAction,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Pick up one car.
	  @param car The car to possibly pick up.
	  @param train The train to pick up the car for.
	  @param boxMove Is this a box move?
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Px The stop number that train is at. 
	  @param Lx Place in the train to put the car if it is picked up.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void TrainPickupOneCar(Car *car,Train *train,bool boxMove,
		CarVector &consist,bool &didAction,int Px,
		CarVector::iterator Lx,const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Check to see if we can really pick up this car.
	  @param car The car to check.
	  @param train The train to pick up the car for.
	  @param boxMove Is this a box move?
	  @param consist The train's consist.
	  @param didAction Flag to set if something was done.
	  @param Px The stop number that train is at. 
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	bool TrainCarPickupCheck(Car *car, Train *train,bool boxMove,
		CarVector &consist,bool &didAction,int Px,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer);
	/**  Check to see if this other car can be picked up.
	  @param car The car to check.
	  @param train The train to check.
	*/
	bool OtherCarOkForTrain(Car *car, Train *train);
	/**  Print a train's consist summary.
	  @param train The train to print a summary for.
	  @param consist The train's consist.
	  @param printer Printer device.
	*/
	void TrainPrintConsistSummary(Train *train,CarVector &consist,
		PrinterDevice *printer);
	/**  Print a train's final summary.
	  @param train The train to print the final summary for.
	  @param printer Printer device.
	*/
	void TrainPrintFinalSummary(Train *train,PrinterDevice *printer);
	/**  Print the town a train is in.
	  @param train The train to print the town for.
	  @param curStation The current station.
	  @param printer Printer device.
	*/
	void TrainPrintTown(const Train *train,const Station *curStation,
		PrinterDevice *printer);
	/**  Print a train order header.
	  @param train The train to print a train order header for.
	  @param printer Printer device.
	*/
	void PrintTrainOrderHeader(const Train *train,PrinterDevice *printer);
	/**  Print a form feed.
	  @param printer Printer device.
	*/
	void PrintFormFeed(PrinterDevice *printer) const;
	/**  Print a system banner.
	  @param printer Printer device.
	*/
	void PrintSystemBanner(PrinterDevice *printer) const;
	/**  Print a dashed line.
	  @param printer Printer device.
	*/
	void PrintDashedLine(PrinterDevice *printer) const;
	/**  Print dispatcher report sheets.
	  @param banner System banner.
	  @param trainType Type of train.
	  @param printer Printer device.
	*/
	void PrintDispatcher(string banner,char trainType,
		PrinterDevice *printer) const;
	/**  Format the on duty time in a human readable format.
	  @param dutytimeminutes The duty time in minutes.*/
	const string FormatDutyTime(int dutytimeminutes) const;
	/**  Print the train orders for a selected train.
	  @param train The train to print trains orders for.
	  @param printer Printer device.
	*/
	void PrintTrainOrders(const Train *train,PrinterDevice *printer) const;
	///  Return today's date.
	const string Today() const;
	/**  Convert a string to all uppercase letters.
	  @param str The string to convert.*/
	const string UpperCase(const string str) const;
	/**  Print the industry header.
	  @param printer Printer device.
	*/
	void PrintIndustryHeader(PrinterDevice *printer) const;
	/**  Print one industry.
	  @param ix The industry.
	  @param lenInDiv The updated division length.
	  @param carsInDiv The updated cars in division count.
	  @param carsToDiv The updates cars headed to division count.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void PrintOneIndustry(const Industry *ix,int &lenInDiv,
		int &carsInDiv, int &carsToDiv,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer) const;
	/**  Print the car heading.
	  @param printer Printer device.
	*/
	void PrintCarHeading(PrinterDevice *printer) const;
	/**  Print one car's information.
	  @param car The car whose information to print.
	  @param printer Printer device.
	*/
	void PrintOneCarInfo(const Car *car,PrinterDevice *printer) const;
	/**  Print the car type header.
	  @param printer Printer device.
	*/
	void PrintCarTypesHeader(PrinterDevice *printer) const;
	/**  Print all car types.
	  @param totalsOnly Print only the totals?
	  @param printer Printer device.
	*/
	void PrintAllCarTypes(bool totalsOnly,PrinterDevice *printer) const;
	/**  Print one car type.
	  @param totalsOnly Print only the totals?
	  @param carType The car type character.
	  @param ct The car type object.
	  @param OnLineShippersOfType Updated online shippers of this car type.
	  @param OffLineShippersOfType Updated offline shippers of this car
		 type.
	  @param OnLineReceiversOfType Updated online receivers of this car
		 type.
	  @param OffLineReceiversOfType Updated offline receivers of this car
		 type.
	  @param allTotalMoves Update total moves.
	  @param allTotalAssigns Updated total assignments.
	  @param printer Printer device.
	*/
	void PrintOneCarType(bool totalsOnly,char carType,const CarType *ct,
		int &OnLineShippersOfType, int &OffLineShippersOfType, 
		int &OnLineReceiversOfType, int &OffLineReceiversOfType,
		int &allTotalMoves,int &allTotalAssigns,
		PrinterDevice *printer) const;
	/**  Print car type summary header.
	  @param printer Printer device.
	*/
	void PrintCarTypesSummaryHeader(PrinterDevice *printer) const;
	/**  Print a location report for one industry.
	  @param Ix The industry's index.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportLocIndustry(IndustryMap::const_iterator Ix,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL);
	/**  Print a location report for one station.
	  @param Sx The station's index.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportLocStation(StationMap::const_iterator Sx,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL);
	/**  Print a location report for one division.
	  @param Dx The division's index.
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportLocDivision(DivisionMap::const_iterator Dx,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL);
	/**  Print a location report for all locations.
	  @param printBench Print cars at the workbench?
	  @param Log Log message callback.
	  @param printer Printer device.
	  @param outmessage Buffer pointer for error messages.*/
	void ReportLocAll(bool printBench,
		const LogMessageCallback     *Log,
		PrinterDevice          *printer,
		char **outmessage = NULL);
	/**  Print a header for all location reports.
	  @param printer Printer device.
	*/
	void PrintLocCommon(PrinterDevice          *printer);
	/**  Print a location report for a single industry.
	  @param Ix The industry to print a report for.
	  @param Sx The station to print a report for.
	  @param firstOne Is this the first one?
	  @param printer Printer device.
	*/
	void PrintLocOneIndustry(const Industry *Ix,const Station *Sx,
		bool &firstOne,PrinterDevice *printer) const;
	/**  Print one car location report.
	  @param car The car to print location information for.
	  @param printer Printer device.
	*/
	void PrintOneCarLocation(const Car *car,PrinterDevice *printer) const;
	/**  Print one analysis report.
	  @param Ix The industry.
	  @param carsToDiv Updated cars headed for the current division.
	  @param Log Log message callback.
	  @param printer Printer device.
	*/
	void PrintOneAnalysys(const Industry *Ix,int &carsToDiv,
		const LogMessageCallback     *Log,
		PrinterDevice *printer) const;
	/**  Print an analysis header.
	  @param printer Printer device.
	*/
	void PrintAnalysisHeader(PrinterDevice *printer) const;
	/**  Glob style string match function.
	  @param thestring The string to match against.
	  @param pattern The glob pattern.
	*/
	bool GlobStringMatch(const string thestring,const string pattern) const;
	/**  Helper function for glob string matching.
	  @param string_i The current string index.
	  @param string_e The end of the string.
	  @param pattern_i The current pattern index.
	  @param pattern_e The end of the pattern.
	*/
	bool GlobStringMatchHelper(string::const_iterator string_i,
		string::const_iterator string_e,
		string::const_iterator pattern_i,
		string::const_iterator pattern_e) const;
#endif
};

#ifdef SWIG

%typemap(tcl8,out) int MyTcl_Result {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	 return $source;
#else
	 return $1;
#endif
}

%apply int MyTcl_Result { int System_DivisionIndexList };
%apply int MyTcl_Result { int System_StationIndexList };
%apply int MyTcl_Result { int System_TrainIndexList };
%apply int MyTcl_Result { int System_IndustryIndexList };
%apply int MyTcl_Result { int System_OwnerInitialsList };
%apply int MyTcl_Result { int System_SearchForCarIndexesByNumber };
%apply int MyTcl_Result { int System_SearchForTrainPattern };
%apply int MyTcl_Result { int System_SearchForIndustryPattern };

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%addmethods
#else
%extend
#endif
	System {
	int DivisionIndexList(Tcl_Interp *interp) {
		DivisionMap::const_iterator i;
		int indx;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		for (i = self->FirstDivision(); i != self->LastDivision(); i++) {
#ifdef DEBUG
			cerr << "*** System_DivisionIndexList: i->first = " << i->first << endl;
#endif
			if (i->second == NULL) continue;
			indx = i->first;
#ifdef DEBUG
			cerr << "*** System_DivisionIndexList: indx = " << indx << endl;
#endif
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewIntObj(indx))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
	int StationIndexList(Tcl_Interp *interp) {
		StationMap::const_iterator i;
		int indx;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		Tcl_SetListObj(tcl_result,0,NULL);
		for (i = self->FirstStation(); i != self->LastStation(); i++) {
			if (i->second == NULL) continue;
			indx = i->first;
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewIntObj(indx))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
	int TrainIndexList(Tcl_Interp *interp) {
		TrainMap::const_iterator i;
		int indx;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		Tcl_SetListObj(tcl_result,0,NULL);
		for (i = self->FirstTrain(); i != self->LastTrain(); i++) {
			if (i->second == NULL) continue;
			indx = i->first;
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewIntObj(indx))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
	int IndustryIndexList(Tcl_Interp *interp) {
		IndustryMap::const_iterator i;
		int indx;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		Tcl_SetListObj(tcl_result,0,NULL);
		for (i = self->FirstIndustry(); i != self->LastIndustry(); i++) {
			if (i->second == NULL) continue;
			indx = i->first;
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewIntObj(indx))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
	int OwnerInitialsList(Tcl_Interp *interp) {
		OwnerMap::const_iterator i;
		string indx;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		Tcl_SetListObj(tcl_result,0,NULL);
		for (i = self->FirstOwner(); i != self->LastOwner(); i++) {
			if (i->second == NULL) continue;
			indx = i->first;
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewStringObj(indx.c_str(),-1))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
	int SearchForCarIndexesByNumber(Tcl_Interp *interp,const char *number,bool subStringP) {
		vector<int> result = self->SearchForCarIndexesByNumber(number,subStringP);
		int indx;
		vector<int>::const_iterator i;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		Tcl_SetListObj(tcl_result,0,NULL);
		for (i = result.begin(); i != result.end(); i++) {
			indx = *i;
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewIntObj(indx))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
	int SearchForTrainPattern(Tcl_Interp *interp,const char *trainNamePattern) {
		vector<int> result = self->SearchForTrainPattern(trainNamePattern);
		int indx;
		vector<int>::const_iterator i;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		Tcl_SetListObj(tcl_result,0,NULL);
		for (i = result.begin(); i != result.end(); i++) {
			indx = *i;
#ifdef DEBUG
			cerr << "*** System_SearchForTrainPattern: indx = " << indx << endl;
#endif
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewIntObj(indx))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
	int SearchForIndustryPattern(Tcl_Interp *interp,const char *industryNamePattern) {
		vector<int> result = self->SearchForIndustryPattern(industryNamePattern);
		int indx;
		vector<int>::const_iterator i;
		Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
		Tcl_SetListObj(tcl_result,0,NULL);
		for (i = result.begin(); i != result.end(); i++) {
			indx = *i;
#ifdef DEBUG
			cerr << "*** System_SearchForIndustryPattern: indx = " << indx << endl;
#endif
			if (Tcl_ListObjAppendElement(interp,tcl_result,
						     Tcl_NewIntObj(indx))
				!= TCL_OK) return TCL_ERROR;
		}
		Tcl_SetObjResult(interp,tcl_result);
		return TCL_OK;
	}
};
#endif

#endif // _SYSTEM_H_

