/* 
 * ------------------------------------------------------------------
 * System_CarAssignment.cc - Car Assignment
 * Created by Robert Heller on Thu Sep  1 16:47:50 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.4  2007/02/21 17:50:54  heller
 * Modification History: Updated Makefile.am for C++
 * Modification History:
 * Modification History: Revision 1.3  2006/02/26 23:09:23  heller
 * Modification History: Lockdown for machine xfer
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 01:25:32  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:33  heller
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


static char Id[] = "$Id$";

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <System.h>
#include <PathName.h>
#include <limits.h>
#include <ctype.h>
#include <algorithm>
#include "../gettext.h"

namespace FCFSupport {

/*************************************************************************
 *                                                                       *
 * Main car assignment function.  Loops through all cars looking for cars*
 * that are unassigned and trys to find assignments for those cars.      *
 * Assignments are based on things like car type and whether it is loaded*
 * or empty.  Loaded cars are forwarded to industries that consume the   *
 * type of load and empty cars are forwarded either to their home yards  *
 * or to industries that produce loads for that sort of car.		 *
 * Checks are made to be sure that an industry does not get more cars    *
 * than it can handle and so on.					 *
 *                                                                       *
 *************************************************************************/

void System::CarAssignment(const WorkInProgressCallback *WIP,
			   const LogMessageCallback *log,
			   const ShowBannerCallback *banner,
			   char **outmessage)
{
#ifdef DEBUG
	cerr << "*** System::CarAssignment: industries.size() = " << industries.size() << endl;
#endif
	IndustryMap::iterator Ix, LastIx = industries.begin(), IndLoop;
#ifdef DEBUG
	cerr << "*** System::CarAssignment: LastIx set." << endl;
#endif
	CarVector::iterator Cx, ForEnd, ForStart;
	int ForStep, CountCars, RouteCars = 0, IndPriorityLoop, PassLoop;
	int AssignLoop, donepercent;
	double donefract, dfincr;
	bool CarWasMirrored = false;
	bool HaveDest;
	Car *car;
	Division *CarDivI, *IndDivI;
	char CarDivS, IndDivS;
	
	for (AssignLoop = 1; AssignLoop <= 2; AssignLoop++) {
	  banner->ShowBanner();
	  // ----------- Outer Loop Initialization --------------
	  for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
#ifdef DEBUG
	    cerr << "*** System::CarAssignment: Ix->first = " << Ix->first << ", Ix->second = " << Ix->second << endl;
#endif
	    if ((Ix->second) == NULL) continue;
	    (Ix->second)->usedLen = 0;
	  }
	  donefract = 0.0;
	  donepercent = 0;
	  dfincr = 100.0 / ((double)cars.size());
#ifdef DEBUG
	  cerr << "*** System::CarAssignment: dfincr = " << dfincr << endl;
#endif
	  sprintf(messageBuffer,_("Car Assignment in Progress\nOuter Loop Initialization: %d"),AssignLoop);
#ifdef DEBUG
	  cerr << "*** System::CarAssignment: messageBuffer = '" << messageBuffer << "'" << endl;
#endif
	  WIP->ProgressStart(messageBuffer);
	  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	    donefract += dfincr;
#ifdef DEBUG
	    cerr << "*** System::CarAssignment: donefract = " << donefract << endl;
#endif
	    if ((int)donefract != donepercent) {
	      donepercent = (int)donefract;
	      sprintf(messageBuffer,_("%6.2f%% Done"),donefract);
	      
	      WIP->ProgressUpdate(donepercent,messageBuffer);
	    }
	    car = *Cx;
#ifdef DEBUG
	    cerr << "*** System::CarAssignment: Cx = " << Cx << endl;
#endif
	    if (car->Destination() == IndScrapYard()) continue;
	    if (car->Location() == IndRipTrack()) continue;
#ifdef DEBUG
	    cerr << "*** System::CarAssignment: car->Destination() = " << car->Destination() << endl;
#endif
	    if (car->Destination() == IndRipTrack()) car->SetDestination(car->Location());
	    //===================================================================
	    car->tmpStatus = car->loadedP;
	    if (car->Location() == car->Destination()) {
	      // This marks the car for assignment
	      car->SetDestination((Industry *)IndRipTrack());
	      // --------------------------------------------------------------
	      // If this is a MIRROR industry, the car moves to a new location,
	      // but it does not change its status - if it was loaded then the
	      // mirror target must load such cars, and so on.
	      // --------------------------------------------------------------
	      CarWasMirrored = false;
	      Industry *LocInd = car->Location();
#ifdef DEBUG
	      cerr << "*** System::CarAssignment: LocInd = " << LocInd << ", LocInd->MyMirror() = " << LocInd->MyMirror() << endl;
#endif
	      if (LocInd != IndRipTrack() && LocInd->MyMirror() != NULL) {
#ifdef DEBUG
		cerr << "*** System::CarAssignment: car->OkToMirrorP() = " << car->OkToMirrorP() << endl;
#endif
	      	if (car->OkToMirrorP()) {
	      	  Industry *MirrorInd = LocInd->MyMirror();
		  // -----------------------------------------------------------
		  // First check to see that the industry would receive this car
		  // in its mirrored loaded or empty state ...  
		  // -----------------------------------------------------------
		  car->tmpStatus = !car->LoadedP();
		  if (IndustryTakesCar(MirrorInd,car)) {
		    // ------------------------------------------------------
		    // Fixed route check then uses the car state that will be
		    // used for making an assignment from the mirrored 
		    // industry ...
		    // ------------------------------------------------------
		    car->tmpStatus = car->LoadedP();
		    if (FixedRouteMirrorCheck(car,MirrorInd)) {
		      // Success! This car can in fact be mirrored! It will soon
		      // be assigned from this new location.
#ifdef DEBUG
		      cerr << "*** System::CarAssignment: Handling a fixed route, mirrored car: " << car->Marks() << " " << car->Number() << endl;
#endif
		      CarVector::iterator index = FindCarInCarVector(LocInd->cars,car);
#ifdef DEBUG
		      Car *temp = *index;
		      cerr << "*** System::CarAssignment: temp = " << temp << ", car = " << car << endl;
#endif
		      if (index != LocInd->cars.end()) {
#ifdef DEBUG
		      	cerr << "*** System::CarAssignment: erasing the car..." << endl;
#endif
		      	LocInd->cars.erase(index);
		      }
		      car->SetLocation(MirrorInd);
		      MirrorInd->cars.push_back(car);
		      CarWasMirrored = true;
		    }
		  }
	      	}
	      }
	      if (!CarWasMirrored) {
#ifdef DEBUG
	      	cerr << "*** System::CarAssignment: Car was not Mirrored" << endl;
#endif
	      	if (car->EmptyP()) {
#ifdef DEBUG
		  cerr << "*** System::CarAssignment: Car is empty" << endl;
#endif
		  // ---------------------------------------------------------
		  // An empty car in a yard, will remain empty for purpose of
		  // finding an assignment. Otherwise this car becomes a load.
		  // ---------------------------------------------------------
		  if (car->Location()->Type() != 'Y') {
		    car->tmpStatus = true;
		  } else {
		    car->tmpStatus = false;
		  }
#ifdef DEBUG
		  cerr << "*** System::CarAssignment: car->tmpStatus = " << car->tmpStatus << endl;
#endif
		} else {
#ifdef DEBUG
		  cerr << "*** System::CarAssignment: Car is loaded" << endl;
#endif
		  // ---------------------------------------------------------
		  // If this is a RELOAD industry, the car is loaded again,
		  // but only if the industry ships out this type of car.
		  //  ---------------------------------------------------------
		  car->tmpStatus = false;
		  if (car->Location()->Reload()) {
#ifdef DEBUG
		    cerr << "*** System::CarAssignment: car->Location()->emptyTypes = " << car->Location()->emptyTypes << ", car->Type() = " << car->Type() << endl;
#endif
		    if (car->Location()->emptyTypes.find(car->Type()) != string::npos) {
		      car->tmpStatus = true;
		    }
		  }
#ifdef DEBUG
		  cerr << "*** System::CarAssignment: car->tmpStatus = " << car->tmpStatus << endl;
#endif
	        }
	      }
	    }
	    // Car has no assignment
	    // ========================================================================
	    // If the car has a destination then add this car's
	    // length to the destination's assigned track space
	    if (car->Destination() != IndRipTrack()) {
	      car->Destination()->usedLen += car->Length();
	    }
#ifdef DEBUG
	    cerr << "*** System::CarAssignment: " << car->Marks() << " " << car->Number() << ": tmpStatus is " << car->tmpStatus << endl;
#endif
	  }
	  WIP->ProgressDone("Done");
	  // ----------- Set Search Direction --------------
	  if (Random() < 0.5) {
	    ForEnd = cars.end();
	    ForStart = cars.begin();
	    ForStep = 1;
	    sprintf(messageBuffer,_("Checking cars from 0 to %lu\n"),cars.size()-1);
	  } else {
	    ForEnd = cars.begin()-1;
	    ForStart = cars.end()-1;
	    ForStep = -1;
	    sprintf(messageBuffer,_("Checking cars from %lu to 0\n"),cars.size()-1);
	  }
	  log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	  CountCars = 0;
	  sprintf(messageBuffer,_("Car Assignment in Progress\nOuter Loop: %d"),AssignLoop);
	  WIP->ProgressStart(messageBuffer);
	  donefract = 0.0;
	  donepercent = 0;
	  dfincr = 100.0 / ((double)cars.size());
	  WIP->ProgressUpdate(0,"  0.00% Done");
	  for (Cx = ForStart;Cx != ForEnd;Cx += ForStep) {
	    HaveDest = false;
	    donefract += dfincr;
	    if ((int)donefract != donepercent) {
	      donepercent = (int)donefract;
	      sprintf(messageBuffer,_("%6.2f%% Done"),donefract);
	      
	      WIP->ProgressUpdate(donepercent,messageBuffer);
	    }
	    car = *Cx;
	    car->SetNotDone();
	    car->ClearMovementsThisSession();
	    car->SetLastTrain(NULL);
	    if (car->Destination() != IndRipTrack()) {continue;}
	    if (car->Location() == IndRipTrack()) {continue;}
	    CountCars++;
	    log->LogMessage(LogMessageCallback::Infomational,"\n==================\n");
	    sprintf(messageBuffer,_("Processing car %s %s\n"),car->Marks(),car->Number());
	    log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	    sprintf(messageBuffer,_("Cars inspected %d\n"),CountCars);
	    log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	    sprintf(messageBuffer,_("Cars Assigned  %d\n"),RouteCars);
	    log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	    sprintf(messageBuffer,_("Last Industry  %d\n\n\n"),LastIx->first);
	    log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	    sprintf(messageBuffer,"%s %s %s at %s\n",
	    	    (car->tmpStatus?_("Loaded"):_("Empty")),
		    car->Marks(),car->Number(),car->Location()->Name());
	    log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	    Ix = LastIx;
	    for (IndPriorityLoop=1; IndPriorityLoop <= 4; IndPriorityLoop++) {
	      // ----------- Inner Loop --------------
	      // The purpose of the PassLoop is to try to reload cars in the
	      // same division where they are, whether they are "offline" or
	      // are "online"
	      for (PassLoop=1; PassLoop <= 2; PassLoop++) {
	      	
	      	for (IndLoop = industries.begin(),IndLoop++;IndLoop != industries.end(); IndLoop++) {
	      	  Ix++;
	      	  if (Ix == industries.end()) {
			Ix = industries.begin();
			Ix++;
		  }
	      	  if (Ix->second == NULL) continue;
	      	  if ((Ix->second)->Priority() != IndPriorityLoop) continue;
	      	  if ((Ix->second)->AssignLen() == 0) continue;
		  // Cars are never assigned to yards
		  //  --------------------------------
		  if ((Ix->second)->Type() == 'Y') continue;
		  // If the car is at an industry that mirrors, never route
		  // the car to the mirror itself. This does not apply when
		  // the car is not allowed to mirror.
		  // ------------------------------------------------------
		  if (car->Location()->MyMirror() != NULL) {
		    if (car->Location()->MyMirror() == Ix->second) {
		      if (car->OkToMirrorP()) continue;
		    }
		  }
		  // Does industry accept this car ?
		  // -------------------------------
		  if (!IndustryTakesCar(Ix->second,car)) continue;
		  // Eliminate incompatible industries for this car
		  // ----------------------------------------------
		  if (car->Plate() > (Ix->second)->MaxPlate()) continue;
		  if (car->WeightClass() > (Ix->second)->MaxWeightClass()) continue;
		  if (car->Length() > (Ix->second)->MaxCarLen()) continue;
		  // Is there space available for this car ?
		  // -------------------------------------
		  if (((Ix->second)->usedLen + car->Length()) > (Ix->second)->AssignLen()) continue;
		  CarDivI = car->Location()->MyStation()->MyDivision();
		  CarDivS = CarDivI->Symbol();
		  IndDivI = (Ix->second)->MyStation()->MyDivision();
		  IndDivS = IndDivI->Symbol();
		  // -------------------------------------------------
		  // If the car has a fixed route then the destination
		  // must be in the car's home list.
		  // -------------------------------------------------
		  if (car->FixedRouteP()) {
		    // AND the destination ALSO must be in the current car
		    // location's destination list - regardless of whether
		    // the car is loaded/empty -- unless the list is empty.
		    // ---------------------------------------------------
		    if (car->Location()->divisionControlList.size() > 0) {
		      if (car->Location()->divisionControlList.find(IndDivS) == string::npos) continue;
		    }
		  }
		  // Car has a FIXED route
		  // ===========================================================
		  // EMPTY CARS
		  // ===========================================================
		  if (!car->tmpStatus) {
		    if ((Ix->second)->Type() == 'O' &&
		    	car->Location()->Type() != 'I') {
		      LastIx = Ix;
		      CarVector::iterator index = FindCarInCarVector(car->Location()->cars,car);
		      if (index != car->Location()->cars.end()) {
		      	car->Location()->cars.erase(index);
		      }
		      car->SetLocation(Ix->second);
		      (Ix->second)->cars.push_back(car);
		      HaveDest = true;
		      break;
		    }
		    // ----------------------------------------------------
		    //
		    // Ok! The Car and Industry -ARE- in the same area.
		    // The empty car will travel a shorter distance to
		    // be reloaded.
		    //
		    // NOTE a key assumption is that from this area, it is
		    // possible to route the car back to its HOME division
		    // when the industry is not in a home div.
		    //
		    // ----------------------------------------------------
		    if (car->divisions.size() > 0 &&
		        (Ix->second)->divisionControlList.size() > 0) {
		      // If the car is in a home division, we're ok
		      bool YesNo;
		      if (car->divisions.find(CarDivS) == string::npos) {
		      	YesNo = false;
		        for (string::const_iterator PxDiv = (Ix->second)->divisionControlList.begin();
		             PxDiv != (Ix->second)->divisionControlList.end();
		             PxDiv++) {
		          if (car->divisions.find(*PxDiv) != string::npos) {
		            YesNo = true;
		            break;
		          }
		        }
		        if (YesNo) continue;
		      }
		      LastIx = Ix;
		      RouteCars++;
		      HaveDest = true;
		      break;
		    }
		    // Car and Industry are in SAME AREA
		    // -------------------------------------------------
		    // On the first pass for empty cars, skip industries
		    // that are outside the car's present AREA.
		    // -------------------------------------------------
		    if (PassLoop == 1 && car->FixedRouteP()) continue;
		    // ------------------------------------------------------
		    //
		    // The EMPTY and an Industry are not in the same area, so
		    // check the Car's Division List to see whether it can be
		    // routed to the Industry for loading.
		    //
		    // ------------------------------------------------------
		    if (car->divisions.size() == 0 ||
		        car->divisions.find(IndDivS) != string::npos) {
		      LastIx = Ix;
		      RouteCars++;
		      HaveDest = true;
		      break;
		    }
		    if (car->FixedRouteP()) continue;
		    // ------------------------------------------------------
		    //
		    // Last chance for an empty -- if the car is offline then
		    // we let it go to any destination where it can be loaded.
		    // 
		    // ------------------------------------------------------
		    if (AssignLoop == 2 && PassLoop == 2) {
		      if (car->Location()->Type() == 'O') {
		      	LastIx = Ix;
			RouteCars++;
			HaveDest = true;
			break;
		      }
		      
	            }
		    // END of Empty Car case
		    // ===========================================================
		    // LOADED CARS
		    // ===========================================================
	          } else {
		    // (*Cx)->tmpStatus == true (loaded)
		    // If the Car and the Industry are in the same area AND
		    // the Industry is Offline and the Car is Offline, then
		    // do not assign the Car to the Industry.
		    // --------------------------------------------------------
		    if (CarDivI->Area() == IndDivI->Area()) {
		      if ((Ix->second)->Type() == 'O' &&
		          car->Location()->Type() != 'I') continue;
		    }
		    // When the Car is loaded where it can go is under control
		    // of the Industry's Division List
		    // -------------------------------------------------------
		    string DestList = car->Location()->divisionControlList;
		    // 
		    // CHANGE 6/24/96 -- As a last resort, use the car's list
		    // of home divisions as possible destinations. Usually we
		    // got this far because the car is at an industry outside
		    // of its home divisions, that does NOT ship to the car's
		    // home divisions.
		    // ------------------------------------------------------
		    if (AssignLoop == 2 && PassLoop == 2) {
		      // Oops! Since I allow an offline car to be routed to
		      // any destination of the shipper, I do not use a car
		      // home division list in that case.
		      // --------------------------------------------------
		      // if (car->Location()->Type() == 'I') {
		        DestList = car->Divisions();
		      // }
		    }
		    // END CHANGE 6/24/96
		    // ------------------
		    if (DestList.size() == 0 || \
		        DestList.find(IndDivS) != string::npos) {
		      // ----------------------------------------------------
		      //
		      // The car's current industry can ship to this industry
		      //
		      // Normally if the car itself is NOT in a home division
		      // then it must be routed BACK to a home division
		      //
		      // Now I make an exception -- if the car is offline, it
		      // may be routed to any valid destination division from
		      // the current industry.
		      //
		      // The reason for this is that cars at offline industry
		      // may be "relocated" somewhere in the same area, and I
		      // don't check home divisions when I do it (see above).
		      //
		      // ----------------------------------------------------
		      if (AssignLoop == 2 && PassLoop == 2) {
		      	if (car->Location()->Type() == 'O') {
		      	  // GOTO IndustryIsOk
		      	  LastIx = Ix;
			  RouteCars++;
			  HaveDest = true;
			  break;
			}
		      }
		      if (car->divisions.size() > 0) {
		      	// If the car is not now in a home division ..
		      	// -------------------------------------------
		      	if (car->divisions.find(CarDivS) == string::npos) {
		      	  // ANd the industry is not in a home division ..
		      	  // ---------------------------------------------
		      	  if (car->divisions.find(IndDivS) == string::npos) {
		      	    // This industry cannot receive this car
		      	    continue;
		      	  }
		      	}
		      }
		      LastIx = Ix;
		      RouteCars++;
		      HaveDest = true;
		      break;
		    }
		    // If you get here you have failed
		  }
		  // Loaded Car case
		}
		// IndLoop
		if (HaveDest) break;
	      }
	      // PassLoop
	      if (HaveDest) break;
	    }
	    // IndPriorityLoop
	    if (!HaveDest) {
	      // We failed to find a destination. If the car is EMPTY and if the
	      // car is sitting at an ONLINE industry, then assign this car just
	      // to move to the industry's home yard.
	      // IF AssignLoop% = 2 THEN
	      //   IF CrsTmpStatus(Cx%) = "E" AND IndsType(CrsLoc%(Cx%)) = "I" THEN
	      //     Ix% = DivsHome%(StnsDiv%(IndsStation%(CrsLoc%(Cx%))))
	      //     GOTO HaveDest
	      //   END IF
	      // END IF ' AssignLoop% = 2 i.e. last chance
	      //
	      // If we fall into this code, then we have failed to find any
	      // destination for this car -- so just leave it alone for now.
	      Ix = FindIndustry(car->Location());
	      car->tmpStatus = car->loadedP;
	    }
	    // HaveDest:
	    car->SetDestination(Ix->second);
	    car->loadedP = car->tmpStatus;
	    // Adjust the used assignment space for this industry -
	    // Should I do this only if the car is not at its dest?
	    // ----------------------------------------------------
#ifdef DEBUG
	    cerr << "*** System::CarAssignment (before): (Ix->second)->usedLen = " <<
			(Ix->second)->usedLen << ", car->Length() = " << 
			car->Length() << endl;
#endif
	    (Ix->second)->usedLen += car->Length();
#ifdef DEBUG
	    cerr << "*** System::CarAssignment (after): (Ix->second)->usedLen = " << 
	    		(Ix->second)->usedLen << endl;
#endif
	    if ((Ix->second) != car->Location()) {
	      // Whenever a car receives an assignment to move somewhere else
	      // we count this as 1 assignment for our statistics.
	      car->IncrementAssignments();
	      string Status,CarTypeDesc;
	      GetCarStatus(car,Status,CarTypeDesc);
	      sprintf(messageBuffer,_("Assign %s %s %s is %s\n"),
			car->Marks(),car->Number(),
			carTypes[car->Type()]->Type(),Status.c_str());
	      log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	      sprintf(messageBuffer,_(" Now at %s\n"),car->Location()->Name());
	      log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	      sprintf(messageBuffer,_(" Send to %s\n"),car->Destination()->Name());
	      log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
//	      sprintf(messageBuffer,_(" IndsAssignLen = %d IndsUsedLen = %d\n"),
//			car->Destination()->AssignLen(),
//			car->Destination()->usedLen);
//	      log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
            }
	  }
	  WIP->ProgressDone(_("Done"));
	}
	bool hflag = true;
	WIP->ProgressStart(_("Car Assignment In Progress\nCars without assignments"));
	donefract = 0.0;
	donepercent = 0;
	WIP->ProgressUpdate(0,_("  0.00% Done"));
	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	  donefract += dfincr;
	  if ((int)donefract != donepercent) {
	    donepercent = (int)donefract;
	    sprintf(messageBuffer,_("%6.2f%% Done"),donefract);
	    WIP->ProgressUpdate(donepercent,messageBuffer);
	  }
	  car = *Cx;
	  if (car->Location() == car->Destination()) {
	    if (hflag) {
	      log->LogMessage(LogMessageCallback::Infomational,_("\n\nCars without assignments\n"));
	      hflag = false;
	    }
	    sprintf(messageBuffer,"%s %s %s @ %s\n",car->Marks(),car->Number(),
	    	    TheCarType(car->Type())->Type(),car->Location()->Name());
	    log->LogMessage(LogMessageCallback::Infomational,messageBuffer);
	  }
	}
	WIP->ProgressDone(_("Done"));
}

/*************************************************************************
 *                                                                       *
 * Does this industry take this type of car?				 *
 *                                                                       *
 *************************************************************************/

bool System::IndustryTakesCar(Industry *Ix, Car *Cx)
{
	bool result;
	if (Cx->tmpStatus) {
	  result = Ix->loadTypes.find(Cx->Type()) != string::npos;
#ifdef DEBUG
	  cerr << "***  System::IndustryTakesCar: result = " << result << " (" << Cx->Type() << ":" << Ix->loadTypes << ")" << endl;
#endif
	} else {
	  result = Ix->emptyTypes.find(Cx->Type()) != string::npos; 
#ifdef DEBUG
	  cerr << "*** System::IndustryTakesCar: result = " << result << " (" << Cx->Type() << ":" << Ix->emptyTypes << ")" << endl;
#endif
	}
	return result;
}

/*************************************************************************
 *                                                                       *
 * --------------------------------------------------------		 *
 * ENHANCEMENT -- Check for fixed route cars being mirrored		 *
 * --------------------------------------------------------		 *
 *                                                                       *
 *************************************************************************/

bool System::FixedRouteMirrorCheck(Car *Cx, Industry *Ix)
{
#ifdef DEBUG
	cerr << "*** System::FixedRouteMirrorCheck(" << Cx->Marks() << ":" << Cx->Number() << "," << Ix->Name() << ")" << endl;
	cerr << "*** System::FixedRouteMirrorCheck: Cx->FixedRouteP() == " << Cx->FixedRouteP() << endl;
#endif
	if (!Cx->FixedRouteP()) return true;
	Division *MirrorDivI = Ix->MyStation()->MyDivision();
#ifdef DEBUG
	cerr << "*** System::FixedRouteMirrorCheck: MirrorDivI->Name() = " << MirrorDivI->Name() << endl;
#endif
	char MirrorDivS = MirrorDivI->Symbol();
#ifdef DEBUG
	cerr << "*** System::FixedRouteMirrorCheck: MirrorDivS = " << MirrorDivS << endl;
#endif
// if  the car is loaded --
//
//  Make sure the industry's division is included in this car's home list.
	if (Cx->tmpStatus) {
	  if (Cx->divisions.find(MirrorDivS) == string::npos) {
#ifdef DEBUG
	    cerr << "*** System::FixedRouteMirrorCheck: returning false for a loaded car" << endl;
#endif
	    return false;
	  }
	} else {
// If the car is empty --
//
//  The industry's division list (normally only applicable to loaded cars)
//  must have a division in common with the car's home division list. When
//  an assignment is made (later), this empty fixed route car is directed
//  by the industry's division list and it's own home list.
	  string::const_iterator PxDiv;
	  for (PxDiv = Ix->divisionControlList.begin();
	       PxDiv != Ix->divisionControlList.end();
	       PxDiv++) {
	    if (Cx->divisions.find(*PxDiv) != string::npos) return true;
	  }
#ifdef DEBUG
	    cerr << "*** System::FixedRouteMirrorCheck: returning false for an empty car" << endl;
#endif
	  return false;
	}
#ifdef DEBUG
	cerr << "*** System::FixedRouteMirrorCheck: returning true" << endl;
#endif
	return true;
}

/*************************************************************************
 *                                                                       *
 * Show cars without assignments.					 *
 *                                                                       *
 *************************************************************************/

void System::ShowUnassignedCars(const LogMessageCallback     *Log,
			        const ShowBannerCallback     *banner) const
{
  int Total;
  CarVector::const_iterator Cx;
  const Car *car;
  char buffer[256];
  string status, carTypeDescr;

  Total = 0;
  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
    if ((car = *Cx) == NULL) continue;
    if (car->Location() == car->Destination()) {
      if (Total == 0) {
      	banner->ShowBanner();
      	sprintf(buffer,"%-50s%s\n\n",_("Cars Without Assignments"),_("Location"));
      	Log->LogMessage(LogMessageCallback::Infomational,buffer);
      }
      GetCarStatus(car,status,carTypeDescr);
      sprintf(buffer,"%-10s%-9s%-31s%s\n",car->Marks(),car->Number(),
	      carTypeDescr.c_str(),car->Location()->Name());
      Log->LogMessage(LogMessageCallback::Infomational,buffer);
      Total++;
      if (Total == 18) Total = 0;
    }
  }
}

}
