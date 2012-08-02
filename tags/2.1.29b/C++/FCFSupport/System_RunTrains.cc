/* 
 * ------------------------------------------------------------------
 * System_RunTrains.cc - Run Trains (RunAllTrains, RunOneTrain, and support code)
 * Created by Robert Heller on Sat Oct  1 11:46:59 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.6  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.5  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.4  2007/01/08 22:33:30  heller
 * Modification History: Win32 Build Issues
 * Modification History:
 * Modification History: Revision 1.2  2006/03/06 18:46:20  heller
 * Modification History: March 6 lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:34  heller
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
#include <limits.h>
#include <ctype.h>
#include <algorithm>
#include "../gettext.h"

namespace FCFSupport {

#ifdef DEBUG
ostream& operator << (ostream& stream, CarVector& vect) {
	stream << "<CarVector " << vect.size() << " elements: ";
	CarVector::const_iterator Cx;
	string comma("");
	for (Cx = vect.begin(); Cx != vect.end(); Cx++) {
		if (*Cx == NULL) {
			stream << comma << "(nil)";
		} else {
			stream << comma << *Cx;
		}
		comma = ", ";
	}
	stream << ">";
	return stream;
}
#endif

/*************************************************************************
 *                                                                       *
 * Run all of the trains in an operating session.  This simulates all    *
 * movements.  Assuming the session went smoothly, the results of this   *
 * will mirror what actually happens on the layout and all cars that were*
 * moved this session will be at whereever they would be after the       *
 * session.								 *
 * We can then save the car state and/or run the car assignment for the  *
 * next session.  In practice, what will happen is after running this    *
 * code (and manually run the box moves afterward), some of the cars will*
 * be edited to reflect mistakes and problems encounted durring the      *
 * the operating system.  That is, the car data will be fixed to reflect *
 * what really happened.  Presumably a large part of what happened was   *
 * was supposed to happen.						 *
 * This code also creates information about things like switch lists     *
 * relating to switching that the train crew(s) will perform durring the *
 * operating session.							 *
 *                                                                       *
 *************************************************************************/

void System::RunAllTrains(const WorkInProgressCallback *WIP,
			  const LogMessageCallback     *Log,
			  const ShowBannerCallback     *banner,
			        PrinterDevice          *printer,
			  const TrainDisplayCallback   *traindisplay)
{
	bool boxMove;
	TrainMap::iterator Tx;

	// Get the initial car counts.
	GetIndustryCarCounts();
	// Reset the switch lists.
	switchList.ResetSwitchList();
	// Flag that we were called.
	ranAllTrains++;

	// Display our banner.
	banner->ShowBanner();
	// First runn all of the box moves (yard locals).
	RunBoxMoves(WIP,Log,banner,printer,traindisplay);
	boxMove=false;			// These are not box moves.
	// For every train...
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
#ifdef DEBUG
		cerr << "*** System::RunAllTrains: (Manifests) Tx->second = " << Tx->second << endl;
#endif
		if (Tx->second == NULL) continue;
		// Run manifest and way freights.
		if ((Tx->second)->Type() == Train::Manifest ||
		    (Tx->second)->Type() == Train::Wayfreight) {
		    // Only this shift.
		    if ((Tx->second)->Shift() == shiftNumber) {
		    	InternalRunOneTrain(Tx->second,boxMove,
						 traindisplay,Log,printer);
		    }
		}
	}
}

/*************************************************************************
 *                                                                       *
 * Run all 'box moves' -- these are yard locals that travel from the yard*
 * to local industries and back.  They are run at the start and end of   *
 * every shift.								 *
 *                                                                       *
 *************************************************************************/

void System::RunBoxMoves(const WorkInProgressCallback *WIP,
			 const LogMessageCallback     *Log,
			 const ShowBannerCallback     *banner,
			       PrinterDevice          *printer,
			 const TrainDisplayCallback   *traindisplay)
{
	bool boxMove;
	TrainMap::iterator Tx;

	// These are box moves.
	boxMove = true;
	// For every train...
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
#ifdef DEBUG
		cerr << "*** System::RunAllTrains (BoxMove 1): Tx->second = " << Tx->second << endl;
#endif
		if (Tx->second == NULL) continue;
		// Only box move trains.
		if ((Tx->second)->Type() == Train::BoxMove) {
			InternalRunOneTrain(Tx->second,boxMove,
						 traindisplay,Log,printer);
		}
	}
	return;
}

/*************************************************************************
 *                                                                       *
 * Print all switch lists.						 *
 *                                                                       *
 *************************************************************************/

void System::PrintAllLists(const LogMessageCallback     *Log,
			  const ShowBannerCallback     *banner,
			        PrinterDevice          *printer)
{
	int forend, copies;
	IndustryMap::const_iterator Ix;
	TrainMap::const_iterator Tx;
	const Industry *ix;
	const Train *tx;
	int pageNum, lineNum, tmpTotalCars, listCon = 8;
	/* string tempMessage; */
	static char tempBuffer[2048];
	CarVector::const_iterator Cx;
	const Car *car;
	unsigned int Gx;
	string status, carTypeDescr;

	// Switch List Reports...

	// YARD Switch Lists
	
	banner->ShowBanner();

	forend = 0;
	// Print alphabetical list(s).
	if (printAlpha) {
	  forend = 1;
	  if (printAtwice) forend = 2;
	  for (copies = 0; copies < forend; copies++) {
	    Log->LogMessage(LogMessageCallback::Infomational,_("Printing Yard Switchlist -- by Car\n"));
	    for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	      if ((Ix->second) == NULL) continue;
	      ix = Ix->second;
	      if (ix->Type() == 'Y' && ix->divisionControlList.find('A') != string::npos) {
		if (ix->Priority() < (copies+1)) continue;
#ifdef DEBUG
		cerr << "*** PrintAllLists: ix is " << ix->Name() << endl;
#endif
		pageNum = 1;
		lineNum = -1;
		tmpTotalCars = 0;
		sprintf(tempBuffer,_("Cars List for %s\n"),ix->Name());
		Log->LogMessage(LogMessageCallback::Infomational,tempBuffer);
		switchList.ResetLastIndex();
		for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
		  if (*Cx == NULL) continue;
		  car = *Cx;
		  Gx = switchList.NextSwitchListForCarAndIndustry(car,ix);
#ifdef DEBUG
		  cerr << "*** PrintAllLists: car = <Car " << car->Marks() << " " << car->Number() << ">, Gx = " << Gx << endl;
#endif
		  if (Gx < 0) continue;
		  if (lineNum < 0) {
		    if (pageNum > 1) PrintFormFeed(printer);
		    PrintSystemBanner(printer);
		    printer->SetTypeSpacing(PrinterDevice::One);
		    printer->Put(_("YARD SWITCH LIST BY CAR FOR -- "));
		    printer->Put(ix->Name());
		    printer->Tab(72);
		    printer->Put(_("Page ")); printer->Put(pageNum); printer->PutLine("");
		    printer->SetTypeSpacing(PrinterDevice::Half);
		    printer->Tab(4);
		    printer->Put(_("Car"));
		    printer->Tab(24);
		    printer->Put(_("Length"));
		    printer->Tab(34);
		    printer->Put(_("Train"));
		    printer->Tab(50);
		    printer->Put(_("Car Type"));
		    printer->Tab(86);
		    printer->PutLine(_("Destination"));
		    printer->PutLine("");
		    listCon = 8;
		    pageNum++;
		    lineNum = 50;
		  }
		  if (listCon == 0) {
		    printer->PutLine("");
		    lineNum--;
		    listCon = 8;
		  }
		  GetCarStatus(car,status,carTypeDescr);
		  printer->SetTypeSpacing(PrinterDevice::Half);
		  printer->Tab(4);
		  printer->Put(car->Marks());
		  printer->Tab(14);
		  printer->Put(car->Number());
		  printer->Tab(24);
		  printer->Put(car->Length()); printer->Put(_("ft"));
		  printer->Tab(34);
		  printer->Put(switchList[Gx].PickTrain()->Name());
		  printer->Tab(50);
		  printer->Put(carTypeDescr);
		  printer->Tab(86);
		  printer->PutLine(car->Destination()->Name());
		  listCon--;
		  lineNum--;
		  tmpTotalCars++;
//		This silliness will cause a car to be printed twice, if
//		it is picked up twice from the same location!
		  Cx--;
		}
		if (lineNum < 0) {
		  if (pageNum > 1) PrintFormFeed(printer);
		  PrintSystemBanner(printer);
		  printer->SetTypeSpacing(PrinterDevice::One);
		  printer->Put(_("YARD SWITCH LIST BY CAR FOR -- "));
		  printer->Put(ix->Name());
		  printer->Tab(72);
		  printer->Put(_("Page ")); printer->Put(pageNum); printer->PutLine("");
		  printer->PutLine("");
		  printer->PutLine("");
		  listCon = 8;
		  pageNum++;
		  lineNum = 50;
		}
	        printer->SetTypeSpacing(PrinterDevice::One);
	        printer->Tab(10);
	        printer->Put(_("Total cars for pickup "));
	        printer->Put(tmpTotalCars);
	        printer->PutLine("");
	        PrintFormFeed(printer);
	      }
	    }
	  }
	}

	// TRAIN PICKUP Switch Lists

	banner->ShowBanner();

	bool exp1, exp2;
        string theStation;
	if (printList) {
	  forend = 1;
	  if (printLtwice) forend = 2;
	  for (copies = 0; copies < forend; copies++) {
	    Log->LogMessage(LogMessageCallback::Infomational,_("Printing Yard Pickups -- by Train\n"));
	    for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	      if ((Ix->second) == NULL) continue;
	      ix = Ix->second;
	      if (ix->Type() == 'Y') {
	      	if (ix->divisionControlList.find('P') == string::npos) continue;
	      	if (ix->Priority() < (copies+1)) continue;
	      	pageNum = 1;
	      	int lineRem = -1;
	      	sprintf(tempBuffer,_("Check Train Pickups List for %s\n"),ix->Name());
	      	Log->LogMessage(LogMessageCallback::Infomational,tempBuffer);
		for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
		  if ((Tx->second) == NULL) continue;
		  tx = Tx->second;
		  if (tx->Type() == 'B') continue;
		  if (!tx->Print()) continue;
		  if (tx->Shift() != shiftNumber) continue;
		  tmpTotalCars = 0;
		  for (Gx = 0; Gx < switchList.PickIndex(); Gx++) {
		    exp1 = switchList.PickLocationEq(Gx,ix);
		    exp2 = switchList.PickTrainEq(Gx,tx);
		    if (exp1 && exp2) {
		      tmpTotalCars++;
		    }
		  }
		  if (tmpTotalCars > 0) {
		    if (lineRem < (tmpTotalCars+5)) {
		      if (pageNum > 1) PrintFormFeed(printer);
		      PrintSystemBanner(printer);
		      printer->SetTypeSpacing(PrinterDevice::One);
		      printer->Put(_("YARD PICKUPS LIST BY TRAIN FOR -- "));
		      printer->Put(ix->Name());
		      printer->Tab(72);
		      printer->Put(_("Page "));
		      printer->Put(pageNum);
		      printer->PutLine("");
		      printer->SetTypeSpacing(PrinterDevice::Half);
		      lineRem = 50;
		      pageNum++;
		    }
		    sprintf(tempBuffer,_("Pickup Report for Train %s\n"),tx->Name());
		    Log->LogMessage(LogMessageCallback::Infomational,tempBuffer);
		    printer->SetTypeSpacing(PrinterDevice::One);
		    printer->SetTypeSpacing(PrinterDevice::Double);
		    printer->Put(tx->Name());
		    printer->Tab(12);
		    printer->Put(_("pickups = "));
		    printer->Put(tmpTotalCars);
		    printer->PutLine("");
		    printer->SetTypeSpacing(PrinterDevice::Half);
		    printer->Tab(6); printer->Put(_("Car"));
		    printer->Tab(26); printer->Put(_("Length"));
		    printer->Tab(34); printer->Put(_("Type"));
		    printer->Tab(64); printer->Put(_("Next Stop"));
		    printer->Tab(94); printer->Put(_("Last Train"));
		    printer->Tab(106); printer->PutLine(_("Destination"));
		    printer->PutLine("");
		    lineRem -= 5;
//		 Print cars in train-block order!!
//		----------------------------------
		    int LastPx = tx->NumberOfStops() -1;
		    int Px;
		    for (Px = 1;Px <= LastPx; Px++) {
		      theStation = tx->StationStop(Px)->Name();
		      for (Gx = 0; Gx < switchList.PickIndex(); Gx++) {
		      	SwitchListElement SWE = switchList[Gx];
		      	if (SWE.PickTrain() == tx) {
		      	  if (SWE.PickLocation() == ix) {
		      	    if (SWE.DropStopEQ(Px)) {
		      	      car = SWE.PickCar();
		      	      string lastTrain;
		      	      if (SWE.LastTrain() == NULL) {
		      	      	lastTrain = "-";
		      	      } else {
		      	      	lastTrain = SWE.LastTrain()->Name();
		      	      }
		      	      GetCarStatus(car,status,carTypeDescr);
		      	      printer->SetTypeSpacing(PrinterDevice::Half);
		      	      printer->Tab(6); printer->Put(car->Marks());
		      	      printer->Tab(16); printer->Put(car->Number());
		      	      printer->Tab(26); printer->Put(car->Length());
		      	      			printer->Put(_("ft"));
			      printer->Tab(34); printer->Put(carTypeDescr);
			      printer->Tab(64); printer->Put(theStation);
			      printer->Tab(94); printer->Put(lastTrain);
			      printer->Tab(106); printer->PutLine(car->Destination()->Name());

			      lineRem--;

			      tmpTotalCars--;
		      	    }
		      	  }
		      	}
		      	if (tmpTotalCars <= 0) break;
		      }
		      if (tmpTotalCars <= 0) break;
		    }
		    printer->SetTypeSpacing(PrinterDevice::One);
		    printer->PutLine("");
		    lineRem -= 2;
//	           TmpTotalCars% > 0
		  }
		}
		PrintFormFeed(printer);
	      }
	    }
	  }
	  printer->SetTypeSpacing(PrinterDevice::One);
	}

	// TRAIN DROP Switch Lists

	banner->ShowBanner();

	if (printList) {
	  forend = 1;
	  if (printLtwice) forend = 2;
	  for (copies = 0; copies < forend; copies++) {
	    Log->LogMessage(LogMessageCallback::Infomational,_("Printing Yard Drop Offs -- by Train\n"));
	    for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	      if ((Ix->second) == NULL) continue;
	      ix = Ix->second;
	      if (ix->Type() == 'Y') {
		if (ix->divisionControlList.find('D') == string::npos) continue;
	      	if (ix->Priority() < (copies+1)) continue;
	      	pageNum = 1;
	      	int lineRem = -1;
	      	sprintf(tempBuffer,_("Check Train Dropoffs List for %s"),ix->Name());
	      	Log->LogMessage(LogMessageCallback::Infomational,tempBuffer);
		for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
		  if ((Tx->second) == NULL) continue;
		  tx = Tx->second;
		  if (tx->Type() == 'B') continue;
		  if (!tx->Print()) continue;
		  if (tx->Shift() != shiftNumber) continue;
		  tmpTotalCars = 0;
		  for (Gx = 0; Gx < switchList.PickIndex(); Gx++) {
		    if (tx->Type() == 'M') {
		      exp1 = switchList[Gx].DropStopIndustry() == ix;
		    } else {
		      exp1 = switchList[Gx].DropStopStation() == ix->MyStation();
		    }
		    exp2 = switchList.PickTrainEq(Gx,tx);
		    if (exp1 && exp2) {
		      tmpTotalCars++;
		    }
		  }
		  if (tmpTotalCars > 0) {
		    if (lineRem < (tmpTotalCars+5)) {
		      if (pageNum > 1) PrintFormFeed(printer);
		      PrintSystemBanner(printer);
		      printer->SetTypeSpacing(PrinterDevice::One);
		      printer->Put(_("YARD DROPOFFS LIST BY TRAIN FOR -- "));
		      printer->Put(ix->Name());
		      printer->Tab(72);
		      printer->Put(_("Page "));
		      printer->Put(pageNum);
		      printer->PutLine("");
		      printer->SetTypeSpacing(PrinterDevice::Half);
		      lineRem = 50;
		      pageNum++;
		    }
		    sprintf(tempBuffer,_("Drop Report for Train %s\n"),tx->Name());
		    Log->LogMessage(LogMessageCallback::Infomational,tempBuffer);
		    printer->SetTypeSpacing(PrinterDevice::One);
		    printer->SetTypeSpacing(PrinterDevice::Double);
		    printer->Put(tx->Name());
		    printer->Tab(12);
		    printer->Put(_("dropoffs = "));
		    printer->Put(tmpTotalCars);
		    printer->PutLine("");
		    printer->SetTypeSpacing(PrinterDevice::Half);
		    printer->Tab(6); printer->Put(_("Car"));
		    printer->Tab(26); printer->Put(_("Length"));
		    printer->Tab(34); printer->Put(_("Type"));
		    printer->Tab(64); printer->Put(_("Destination"));
		    printer->Tab(92); printer->PutLine(_("Next Train -- this session!"));
		    printer->PutLine("");
		    lineRem -= 5;
//		 Print cars in alphabetical order!!
//		-----------------------------------
		    for (Gx = 0; Gx < switchList.PickIndex(); Gx++) {
		      if (tx->Type() == 'M') {
		        exp1 = switchList[Gx].DropStopIndustry() == ix;
		      } else {
		        exp1 = switchList[Gx].DropStopStation() == ix->MyStation();
		      }
		      exp2 = switchList.PickTrainEq(Gx,tx);
		      if (exp1 && exp2) {
			SwitchListElement SWE = switchList[Gx];
		      	car = SWE.PickCar();
		      	if (tx->Type() == 'M') {
		      	  theStation = SWE.DropStopIndustry()->Name();
		      	} else {
		          theStation = SWE.DropStopStation()->Name();
		        }
//			See whether this car is picked up again!
			string nextTrain = "-";
			unsigned int NextGx;
			for (NextGx = Gx + 1; NextGx < switchList.PickIndex(); NextGx++) {
			  if (switchList[NextGx].PickCar() == car) {
			    nextTrain = switchList[NextGx].PickTrain()->Name();
			    break;
			  }
			}
			GetCarStatus(car,status,carTypeDescr);
					      	      printer->SetTypeSpacing(PrinterDevice::Half);
		      	printer->Tab(6); printer->Put(car->Marks());
		      	printer->Tab(16); printer->Put(car->Number());
		      	printer->Tab(26); printer->Put(car->Length());
		      	      		  printer->Put(_("ft"));
			printer->Tab(34); printer->Put(carTypeDescr);
			printer->Tab(64); printer->Put(theStation);
			printer->Tab(92); printer->PutLine(nextTrain);

			lineRem--;

			tmpTotalCars--;
			if (tmpTotalCars <= 0) break;
		      }
		    }
		    printer->SetTypeSpacing(PrinterDevice::One);
		    printer->PutLine("");
		    lineRem -= 2;
		  }
//	          TmpTotalCars% > 0
		}
		// Next Tx
		PrintFormFeed(printer);
	      }
	    }
	  }
	  printer->SetTypeSpacing(PrinterDevice::One);
	}

	if (printDispatch) {
	  PrintDispatcher(_("Manifests"),'M',printer);
	  PrintDispatcher(_("Locals"),'W',printer);
	}

	// Reset the SwitchList index after printing all reports
	switchList.ResetSwitchList();
}

/*************************************************************************
 *                                                                       *
 * Compute industry car counts.						 *
 *                                                                       *
 *************************************************************************/

void System::GetIndustryCarCounts() 
{
	IndustryMap::iterator Ix;
	CarVector::iterator   Cx;
	Car *car;
	Industry *location;

	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
		if (Ix->second == NULL) continue;
		(Ix->second)->usedLen = 0;
	}
	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
		if (*Cx == NULL) continue;
		car = *Cx;
		if (car->Location() == NULL) continue;
		if (car->Location() == &indScrapYard) continue;
		location = car->Location();
		location->usedLen += car->Length();
	}
}

/*************************************************************************
 *                                                                       *
 * Internal function to run a single train.				 *
 *                                                                       *
 *************************************************************************/

void System::InternalRunOneTrain(Train *train, bool boxMove,
				 const TrainDisplayCallback   *traindisplay,
				 const LogMessageCallback     *Log,
				       PrinterDevice          *printer) 
{
	IndustryMap::iterator Ix;
	CarVector consist;

	// Initialize counters
	totalPickups = 0;
	totalLoads = 0;
	totalTons = 0;
	totalRevenueTons = 0;
	trainLength = 0;
	numberCars = 0;
	trainTons = 0;
	trainLoads = 0;
	trainEmpties = 0;
	trainLongest = 0;

	// Initialize train status display,
	traindisplay->InitializeTrainDisplay(train->Name(),
					     train->NumberOfStops(),
					     train->MaxLength(),
					     train->MaxCars());
	traindisplay->GrabTrainDisplay();	// Grab the train display

	trainPrintOK = false;
	if (printem && train->Print()) trainPrintOK = true;

	if (boxMove) trainPrintOK = false;

	// Make sure the industry remaining lengths are up to date.
	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
		if (Ix->second == NULL) continue;
		(Ix->second)->remLen = (Ix->second)->TrackLen() - (Ix->second)->usedLen;
	}

	// Fan out based on train type.
	switch (train->Type()) {
		// Way freights are a flavor of local
		case Train::Wayfreight:
			RunOneLocal(train,boxMove,consist,traindisplay,Log,printer);
			break;
		// As are box moves
		case Train::BoxMove:
			RunOneLocal(train,boxMove,consist,traindisplay,Log,printer);
			break;
		// Passenger trains.
		case Train::Passenger:
			RunOnePassenger(train,boxMove,traindisplay,Log,printer);
			break;
		// Manifest freights.
		case Train::Manifest:
			RunOneManifest(train,boxMove,consist,traindisplay,Log,printer);
			break;
		default:	/* Shut the compiler up */
			break;
	}
	// Release the train status display.
	traindisplay->ReleaseTrainDisplay();
	return;
}

/*************************************************************************
 *                                                                       *
 * A local train runs YARD to STATION(S) to YARD			 *
 *                                                                       *
 *************************************************************************/

void System::RunOneLocal(Train *train, bool boxMove, CarVector &consist,
				 const TrainDisplayCallback   *traindisplay,
				 const LogMessageCallback     *Log,
				       PrinterDevice          *printer) 
{
	// Declare and initialize local variables.
	int Px;
	bool didAction = false;
	wayFreight = true;
	deliver = true;
	curDiv = train->StationStop(0)->MyDivision();
	originYard = curDiv->Home();
	trainLastLocation =
	      train->StationStop(train->NumberOfStops()-1)->MyDivision()->Home();

	// Print and display our starting location.
	PrintTrainLoc(train,0,Log,traindisplay);
	// Originate the train, picking up all of the cars at the originating
	// yard.
	TrainLocalOriginate(train,boxMove,0,consist,didAction,Log,printer);
	// Display our summary if anything happened
	if (didAction) TrainPrintConsistSummary(train,consist,printer);
	// For each stop...
	for (Px = 1; Px < train->NumberOfStops()-1; Px++) {
	  didAction = false;
	  // Print and display our new location
	  PrintTrainLoc(train,Px,Log,traindisplay);
	  // Do our local drops
	  TrainLocalDrops(train,Px,consist,didAction,Log,printer);
	  // Do our local pickups
	  TrainLocalPickups(train,boxMove,Px,consist,didAction,Log,printer);
	  // If anything happened, print/display our summary.
	  if (didAction) TrainPrintConsistSummary(train,consist,printer);
	}
	// Print our final location.
	PrintTrainLoc(train,train->NumberOfStops()-1,Log,traindisplay);
	// Drop all of the remaining cars.
	TrainDropAllCars(train,train->NumberOfStops()-1,consist,Log,printer);
	// Print our final summary.
	if (totalPickups > 0) TrainPrintFinalSummary(train,printer);
	return;
}

/*************************************************************************
 *                                                                       *
 * Run a passenger train.  Not much happens -- passenger trains are not  *
 * involved in freight forwarding...					 *
 *                                                                       *
 *************************************************************************/

void System::RunOnePassenger(Train *train, bool boxMove,
				 const TrainDisplayCallback   *traindisplay,
				 const LogMessageCallback     *Log,
				       PrinterDevice          *printer) 
{
	int Px;
	if (!trainPrintOK) {return;}
	printer->PutLine(_("Station stop for passengers, mail, express"));
	printer->PutLine(" ");
	for (Px = 0; Px < train->NumberOfStops(); Px++) {
	  printer->PutLine(" ");
	  printer->Tab(8);
	  printer->Put(train->StationStop(Px)->Name());
	}
	printer->PutLine(" ");
	printer->NewPage();
	return;
}

/*************************************************************************
 *                                                                       *
 * A manifest runs from INDUSTRY/YARD to INDUSTRY/YARD			 *
 *                                                                       *
 *************************************************************************/

void System::RunOneManifest(Train *train, bool boxMove, CarVector &consist,
				 const TrainDisplayCallback   *traindisplay,
				 const LogMessageCallback     *Log,
				       PrinterDevice          *printer) 
{
	int Px=0;
	bool didAction = false;
	wayFreight = false;
	deliver = false;
	// Originating location
	PrintTrainLoc(train,0,Log,traindisplay);
	trainLastLocation = train->IndustryStop(train->NumberOfStops()-1);
	// Pick up cars at our origin.
	TrainManifestPickups(train,boxMove,Px,consist,didAction,Log,printer);
	if (didAction) TrainPrintConsistSummary(train,consist,printer);
	// For each stop...
	for (++Px;Px < train->NumberOfStops()-1; Px++) {
	  didAction = false;
	  // Print location
	  PrintTrainLoc(train,Px,Log,traindisplay);
	  // Drop cars
	  TrainManifestDrops(train,Px,consist,didAction,Log,printer);
	  // Pickup cars
	  TrainManifestPickups(train,boxMove,Px,consist,didAction,Log,printer);
	  if (didAction) TrainPrintConsistSummary(train,consist,printer);
	}
	didAction = false;
	// Final location
	PrintTrainLoc(train,Px,Log,traindisplay);
	// Drop all cars
	TrainDropAllCars(train,train->NumberOfStops()-1,consist,Log,printer);
	if (totalPickups > 0) TrainPrintFinalSummary(train,printer);
	return;
}

/*************************************************************************
 *                                                                       *
 * Print/display our current location and status			 *
 *                                                                       *
 *************************************************************************/

void System::PrintTrainLoc(Train *train, int Px,
			   const LogMessageCallback     *Log,
			   const TrainDisplayCallback   *traindisplay) 
{
	string CurrentStopName = "(";
	if (wayFreight) {
		CurrentStopName += train->StationStop(Px)->Name();
	} else {
		CurrentStopName += train->IndustryStop(Px)->Name();
	}
	CurrentStopName += ")";
	// Update trains status
	traindisplay->UpdateTrainDisplay(train->StationStop(Px)->Name(),
					 CurrentStopName,trainLength,
					 numberCars,trainTons,trainLoads,
					 trainEmpties,trainLongest,Px);
	// Log our movement.
	string trainMessage = train->Name();
	trainMessage += " is now at station ";
	trainMessage += train->StationStop(Px)->Name();
	trainMessage += "\n";
	Log->LogMessage(LogMessageCallback::Infomational,trainMessage);
}

/*************************************************************************
 *                                                                       *
 * Basically, starting from the origin, to the next to last stop, pick   *
 * up every car in the origin yard that is destined for an industry at   *
 * that particular stop -- IF possible.                                  *
 *									 *
 * A car may not necessarily be picked up - if the destination already   *
 * has too many cars, or the train cannot handle this type of car, etc.  *
 *                                                                       *
 *************************************************************************/

void System::TrainLocalOriginate(Train *train, bool boxMove, int Px,
				CarVector &consist,bool &didAction,
				 const LogMessageCallback     *Log,
				       PrinterDevice          *printer) 
{
	int FuturePx;
	IndustryMap::iterator Ix;
	CarVector::iterator Cx;
	/*bool wasPickedUp;*/

	for (FuturePx = Px+1;FuturePx < train->NumberOfStops()-1;FuturePx++) {
	  if ((numberCars + 1) > train->MaxCars()) return;
	  for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	    if (Ix->second == NULL) continue;
	    if ((Ix->second)->MyStation() != train->StationStop(FuturePx))
		continue;
	    for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	      if ((*Cx) == NULL) continue;
	      if ((numberCars + 1) > train->MaxCars()) return;
	      if ((*Cx)->Destination() == (Ix->second) && (*Cx)->Location() == originYard) {
	      	carDest = (Ix->second);
	      	TrainCarPickupCheck(*Cx,train,boxMove,consist,didAction,Px,Log,printer);
	      }
	    }
	  }
	}
// KLUDGE CITY --
//
//  Allow local trains to forward cars under the control of a forwarding
//  division list.
	if (train->divList.size() > 0) {
	  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
//	    If this car is at the train's origin yard
//	    -----------------------------------------
	    if (*Cx == NULL || (*Cx)->Location() != originYard) continue;
	    if ((numberCars+1) > train->MaxCars()) return;
	    Division *carDestDiv = (*Cx)->Destination()->MyStation()->MyDivision();
	    Division *carLocDiv  = (*Cx)->Location()->MyStation()->MyDivision();
	    if (carDestDiv->Home() == carLocDiv->Home()) continue;
//	    The train division list can be exclusive
//	    ----------------------------------------
	    if (train->divList[0] == '-') {
	      if (train->divList.find(carDestDiv->Symbol()) == string::npos) {
	      	carDest = trainLastLocation;
	      	TrainCarPickupCheck(*Cx,train,boxMove,consist,didAction,Px,Log,printer);
	      } else {
//		The train division list can include everything - *
//
//		otherwise it specifies which divisions for forwarding
//		-------------------------------------------------------
		if (train->divList == "*" ||
		    train->divList.find(carDestDiv->Symbol()) != string::npos) {
		  carDest = trainLastLocation;
		  TrainCarPickupCheck(*Cx,train,boxMove,consist,didAction,Px,Log,printer);
		}
	      }
	    }
	  }
	}

	return;
}

/*************************************************************************
 *                                                                       *
 * Drop cars destined for the current (local) industry.			 *
 *                                                                       *
 *************************************************************************/

void System::TrainLocalDrops(Train *train, int Px, CarVector &consist,
				bool &didAction,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer) 
{
	IndustryMap::iterator Ix;
	CarVector::iterator Lx,index;
	Car *Cx;
	const Station *curStation = train->StationStop(Px);

	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  if (Ix->second == NULL) continue;
	  if ((Ix->second)->MyStation() == curStation) {
	    for (Lx = consist.begin(); Lx != consist.end(); Lx++) {
	      Cx = *Lx;
	      if (Cx == NULL) continue;
//	      If this car has reached it's final destination, drop it!
	      if ((Ix->second) == Cx->Destination()) {
	      	/*Industry *ix = Ix->second;*/
	      	index = FindCarInCarVector(Cx->Location()->cars,Cx);
	      	if (index != Cx->Location()->cars.end()) {
	      	  Cx->Location()->cars.erase(index);
	      	}
	      	Cx->SetLocation(Cx->Destination());
	      	Cx->Location()->cars.push_back(Cx);
	      	TrainDropOneCar(Cx,train,Lx,consist,didAction,Px,Log,printer);
	      }
	    }
	  }
	}
//	CHANGE 6/24/96 -- Drop at intermediate yard -- this works only as
//	long as the final destination for this car is not at a later stop
//	-----------------------------------------------------------------
	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  if (Ix->second == NULL) continue;
	  if ((Ix->second)->MyStation() == curStation) {
	    Industry *ix = Ix->second;
	    if (ix->Type() == 'Y') {
	      for (Lx = consist.begin(); Lx != consist.end(); Lx++) {
	        Cx = *Lx;
	        if (Cx == NULL) continue;
//		If this car has reached it's destination's home yard, we
//		drop it in the yard.
		Division *carsDestDiv = Cx->Destination()->MyStation()->MyDivision();
		if (ix == carsDestDiv->Home()) {
		  index = FindCarInCarVector(Cx->Location()->cars,Cx);
		  if (index != Cx->Location()->cars.end()) {
		    Cx->Location()->cars.erase(index);
	      	  }
		  Cx->SetLocation(Cx->Destination());
		  Cx->Location()->cars.push_back(Cx);
		  TrainDropOneCar(Cx,train,Lx,consist,didAction,Px,Log,printer);
		}
	      }
	    }
	  }
	}
}

/*************************************************************************
 *                                                                       *
 * General helper to drop a car.					 *
 *                                                                       *
 *************************************************************************/

void System::TrainDropOneCar(Car *car, Train *train,CarVector::iterator Lx,
				CarVector &consist,
				bool &didAction,int Px,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer) 
{
#ifdef DEBUG
	cerr << "*** TrainDropOneCar(" << car->Marks() << ":" << car->Number() <<
		"," << train->Name() << "," << Lx << "," << consist.size() <<
		" cars," << didAction << "," << Px << ",-log-,-printer-)" << endl;
#endif
	string status, carTypeDescr;
	if (trainPrintOK) {
	  if (!didAction) {
	    TrainPrintTown(train,train->StationStop(Px),printer);
	  }
	  GetCarStatus(car,status,carTypeDescr);
	  printer->Put(_(" DROP ")); printer->Put(car->Marks());
	  printer->Tab(19);
	  printer->Put(car->Number());
	  printer->Tab(28);
	  printer->Put(car->Length()); printer->Put(_("ft"));
	  printer->Tab(36);
	  printer->Put(status);
	  printer->Tab(44);
	  printer->Put(carTypeDescr);
	  printer->Tab(84);
	  printer->Put("for "); printer->Put(car->Destination()->Name());
	  if (deliver) {
	    printer->Tab(110);
	    printer->Put("in "); printer->Put(car->Destination()->MyStation()->Name());
	  }
	  printer->PutLine("");
	}
#ifdef DEBUG
	cerr << "*** TrainDropOneCar: erasing car" << endl;
#endif
	//consist.erase(Lx);
	*Lx = NULL;
#ifdef DEBUG
	cerr << "*** TrainDropOneCar: decrementing various counters" << endl;
#endif
	numberCars--;
	trainLength -= car->Length();
	if (car->EmptyP()) {
	  trainEmpties--;
	  trainTons -= car->LtWt();
	} else {
	  trainLoads--;
	  trainTons -= car->LdLmt();
	}
#ifdef DEBUG
	cerr << "*** TrainDropOneCar: setting didAction to true" << endl;
#endif
	didAction = true;
	if (car->Location()->Type() == 'Y' && train->Type() == Train::BoxMove) {
	  return;
	}
	
	Industry *loc = car->Location();
	loc->carsNum++;
	loc->carsLen += car->Length();
	static char message[2048];
	sprintf(message,_("Drop %s %s is %s dest= %s\n"),car->Marks(),
		car->Number(),TheCarType(car->Type())->Type(),
		car->Destination()->Name());
	Log->LogMessage(LogMessageCallback::Infomational,message);
}


/*************************************************************************
 *                                                                       *
 * General helper to pickup a car.					 *
 *                                                                       *
 *************************************************************************/

void System::TrainPickupOneCar(Car *car, Train *train, bool boxMove,
				CarVector &consist,bool &didAction,int Px,
				CarVector::iterator Lx,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer) 
{
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar(" << car << "," << train->Name() <<
		"," << boxMove << "," << consist << "," << didAction <<
		"," << Px << ",-Log-,-printer-)" << endl;
#endif
	static char  message[2048];
	sprintf(message,_("Pickup %s %s is %s dest = %s\n"),
		car->Marks(),car->Number(),
		TheCarType(car->Type())->Type(),
		car->Destination()->Name());
	Log->LogMessage(LogMessageCallback::Infomational,message);
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: message = '" << message << "'" << endl;
#endif

	trainLength += car->Length();
	if (car->EmptyP()) {
	  trainEmpties++;
	  trainTons += car->LtWt();
	  totalTons += car->LtWt();
	} else {
	  trainLoads++;
	  trainTons += car->LdLmt();
	  totalTons += car->LdLmt();
	  totalLoads++;
	  totalRevenueTons += car->LdLmt() - car->LtWt();
	}
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: counts updated." << endl;
#endif
// This was the old way of counting only loaded trips -- whenever the car
// was picked up loaded at an industry.
//
//    IF IndsType(CrsLoc%(Cx%)) <> "Y" THEN
//
//       CrsLoads%(Cx%) = CrsLoads%(Cx%) + 1
//
//    END IF
	if (Lx == consist.end()) consist.push_back(car);
	else *Lx = car;
	numberCars++;
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: consist updated." << endl;
#endif
	if (!boxMove) {
	  car->IncrmentMovementsThisSession();
	  car->IncrementTrips();
	  if (train->Done()) car->SetDone();
	  else car->SetNotDone();
	}
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: movements updated." << endl;
#endif
// The car length is subtracted from where it is and added to where it
// is going.
	car->Location()->usedLen -= car->Length();
	car->Destination()->usedLen += car->Length();
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: industries updated." << endl;
#endif
	if (numberCars > trainLongest) trainLongest = numberCars;
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: trainLongest updated." << endl;
#endif
	if (trainPrintOK) {
	  if (!didAction) {
	    TrainPrintTown(train,train->StationStop(Px),printer);
	  }
#ifdef DEBUG
	  cerr << "*** TrainPickupOneCar: Town printed." << endl;
#endif
	  string status, carTypeDescr;
	  GetCarStatus(car,status,carTypeDescr);
#ifdef DEBUG
	  cerr << "*** TrainPickupOneCar: status = " << status << ", carTypeDescr = " << carTypeDescr << endl;
#endif
	  printer->Put(_(" PICKUP ")); printer->Put(car->Marks());
	  printer->Tab(19);
	  printer->Put(car->Number());
	  printer->Tab(28);
	  printer->Put(car->Length()); printer->Put("ft");
	  printer->Tab(36);
	  printer->Put(status);
	  printer->Tab(44);
	  printer->Put(carTypeDescr);
	  printer->Tab(74);
	  string trainName;
	  if (car->LastTrain() == NULL) {
	    trainName = "-";
	  } else {
	    trainName = car->LastTrain()->Name();
	  }
	  printer->Put(trainName.substr(0,6));
	  printer->Tab(84);
	  if (wayFreight) {
	    printer->Put(_("at ")); printer->Put(car->Location()->Name());
	    printer->Tab(110);
	    printer->Put(_("for ")); printer->PutLine(car->Destination()->MyStation()->Name());
	  } else {
	    printer->Put(_("to ")); printer->Put(car->Location()->Name());
	    printer->Tab(110);
	    printer->Put(_("dest ")); printer->PutLine(car->Destination()->MyStation()->Name());
	  }
	}
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: printouts done." << endl;
#endif
	// Log this pickup for later reports
	LogCarPickup(car,train,boxMove);
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar: pickup logged." << endl;
#endif
	totalPickups++;
	didAction = true;
#ifdef DEBUG
	cerr << "*** TrainPickupOneCar returns" << endl;
#endif
}

/*************************************************************************
 *                                                                       *
 * Log a car pickup.						 	 *
 *                                                                       *
 *************************************************************************/

void System::LogCarPickup(Car *car, Train *train,bool boxMove) 
{
	if (boxMove) return;
	if (train->Type() == 'M') {
	  switchList.AddSwitchListElement(car->Location(),car,train,car->LastTrain(),carDest);
	} else {
	  switchList.AddSwitchListElement(car->Location(),car,train,car->LastTrain(),carDest->MyStation());
	}
	car->SetLastTrain(train);	
}


/*************************************************************************
 *                                                                       *
 * Basically, look at each industry at the current station. For each	 *
 * car at the industry, see if there is a logical place to take that	 *
 * car -- i.e. a stop where we can drop the car.			 *
 *                                                                       *
 *************************************************************************/

void System::TrainLocalPickups(Train *train, bool boxMove, int Px,
				CarVector &consist,bool &didAction,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer) 
{
	const Station *curStation = train->StationStop(Px);
	IndustryMap::iterator Ix;
	Industry *ix;
	CarVector::iterator   Cx;
	Car *car;
	int FuturePx;
	bool wasPickedUp = false;

	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  ix = Ix->second;
	  if (ix == NULL) continue;
//	  The reason to check for OriginYard% is if this local serves a
//	  station that has both industries AND a yard. When the train  
//	  originated, it picked up cars from the yard. But subsequently
//	  it wants to pick up cars from industries at that same station,
//	  and needs to ignore cars still in the yard.
//	  --------------------------------------------------------------
	  if (ix->MyStation() == curStation && ix != originYard) {
	    for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	      car = *Cx;
	      if (car == NULL || car->Location() != ix) continue;
	      if (numberCars + 1 > train->MaxCars()) return;
//	      The usual place to take a car is to the final stop. But it
//	      is possible that this local train can deliver the car to a
//	      final destination -- that's what this is checking for.
//	      if {$Ix == $CrsLoc($Cx)} {}
//	      CHANGE 6/24/96 -- Check for an intermediate yard. We can
//	      pick up the car here - but ONLY if the final destination
//	      station (and hence industry) is served by this train.
//	      --------------------------------------------------------
	      if (ix->Type() == 'Y') {
	      	for (FuturePx = Px+1;FuturePx < train->NumberOfStops();FuturePx++) {
	      	  if (car->Destination()->MyStation() == train->StationStop(FuturePx)) {
	      	    carDest = car->Destination();
	      	    if ((wasPickedUp = TrainCarPickupCheck(car,train,boxMove,
							   consist,didAction,
							   Px,
							   Log,printer))) break;
	      	  }
	      	}
	      	continue;
	      }
//	      END CHANGE 6/24/96
//	      ------------------
	      carDest = trainLastLocation;
	      for (FuturePx = Px+1;FuturePx < train->NumberOfStops();FuturePx++) {
	      	if (car->Destination()->MyStation() == train->StationStop(FuturePx)) {
		  carDest = car->Destination();
	          if ((wasPickedUp = TrainCarPickupCheck(car,train,boxMove,
							     consist,didAction,
							     Px,
							     Log,printer))) break;
		  carDest = trainLastLocation;
		}
	      }
	      if (wasPickedUp) continue;
	      wasPickedUp = TrainCarPickupCheck(car,train,boxMove,consist,
						didAction,Px,
					        Log,printer);
	    }
	  }
	}
}

/*************************************************************************
 *                                                                       *
 * Walk backwards from the furthest destination -- so we move the cars	 *
 * travelling farthest first ...					 *
 *                                                                       *
 *************************************************************************/

void System::TrainManifestPickups(Train *train, bool boxMove, int Px,
				CarVector &consist,bool &didAction,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer) 
{
	int FuturePx, SoonerPx;
	Industry *FutureInd, *SoonerInd;
	CarVector::iterator   Cx;
	Car *car;
	bool exp1, exp2;

	for (FuturePx = train->NumberOfStops()-1;FuturePx > Px;FuturePx--) {
	  if (numberCars+1 > train->MaxCars()) return;
	  FutureInd = train->IndustryStop(FuturePx);
	  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	    car = *Cx;
	    if (car == NULL || car->Location() != train->IndustryStop(Px)) continue;
//	    If this car is at the train's current stop ...
	    Division *carLocDiv = car->Location()->MyStation()->MyDivision();
	    Division *carDestDiv = car->Destination()->MyStation()->MyDivision();
//	    If the train's future stop is ...
//
//	    (1) the car's final destination industry
	    if (FutureInd->Type() != 'Y') {
	      exp1 = car->Destination() == FutureInd;
//	      AND if the car is not already there!
	      exp2 = car->Location() != FutureInd;
	    } else {
//	      Future Stop is a YARD
//	      If the train's future stop is ...
//	      (2) the car's final destination home yard
	      exp1 = carDestDiv->Home() == FutureInd;
//	      AND if the car is not already there!
//	      This expression doesn't work if a car needs to move on a
//	      manifest from one industry to another, and the industries
//	      share a common home yard!
//	      ---------------------------------------------------------
	      exp2 = carLocDiv->Home() != FutureInd;
//	      HOWEVER!! Now I may have confusion if a car's FINAL dest
//	      is an earlier stop. So check for this case. Aaargghh!
//	      --------------------------------------------------------
	      for (SoonerPx = Px + 1;SoonerPx < FuturePx; SoonerPx++) {
	      	SoonerInd = train->IndustryStop(SoonerPx);
	      	if (car->Destination() == SoonerInd) {
	      	  exp2 = false;
//		  Short circuit loop (save time)
		  break;
	      	}
	      }
	    }
	    if (exp1 && exp2) {
	      carDest = FutureInd;
	      TrainCarPickupCheck(car,train,boxMove,consist,didAction,Px,
				  Log,printer);
	    }
	  }
	}
//	The rationale here is that forwarding cars are used to fill out the
//	train's consist.
//
//	I should make this a per-train option ( i.e. whether the forwarding
//	cars have higher priority than other cars )
//	-------------------------------------------------------------------
	if (train->divList.size() > 0) {
	  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	    car = *Cx;
	    if (car == NULL || car->Location() != train->IndustryStop(Px)) continue;
	    if (numberCars+1 > train->MaxCars()) return;
//	    If this car is at the train's current stop
//	    ------------------------------------------
	    Division *carDestDiv = car->Destination()->MyStation()->MyDivision();
//	    The car must not already be at the home yard for its final
//	    destination, or at an industry that has the same home yard
//	    ----------------------------------------------------------
	    Division *carLocDiv = car->Location()->MyStation()->MyDivision();
	    if (carDestDiv->Home() == carLocDiv->Home()) continue;
//	    The train division list can be exclusive
//	    ----------------------------------------
	    if (train->divList[0] == '-') {
	      if (train->divList.find(carDestDiv->Symbol(),1) == string::npos) {
	      	carDest = trainLastLocation;
	      	TrainCarPickupCheck(car,train,boxMove,consist,didAction,Px,
				    Log,printer);
	      	continue;
	      }
	    } else {
//	      The train division list can include all - *
//
//	      otherwise it specifies which divisions for forwarding
//	      -------------------------------------------------------
	      if (train->divList == "*" ||
	          train->divList.find(carDestDiv->Symbol(),1) != string::npos) {
		carDest = trainLastLocation;
	      	TrainCarPickupCheck(car,train,boxMove,consist,didAction,Px,Log,
				    printer);
	      	continue;
	      }
	    }
	  }
	}
}

/*************************************************************************
 *                                                                       *
 * Check if we really can pick this car up.				 *
 *                                                                       *
 *************************************************************************/

bool System::TrainCarPickupCheck(Car *car, Train *train,bool boxMove,
				CarVector &consist,bool &didAction,int Px,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer)
{
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck(" <<
		car->Marks() << ":" << car->Number() << "," <<
		train->Name() << "," << boxMove << "," <<
		consist.size() << " cars," << didAction << "," <<
		Px << ",-log-,-printer-)" << endl;
#endif
//  Check for obvious things that prevent the car from being picked up!
//	Has the car already been picked up?
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: Has the car already been picked up?" << endl;
#endif
	CarVector::iterator index = FindCarInCarVector(consist,car);
	if (index != consist.end()) return false;
//      Has the car already finished moving ?
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: Has the car already finished moving ?" << endl;
#endif
	if (!boxMove) {
	  if (car->IsDoneP()) return false;
	}
//      Is car already at its destination ?
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: Is car already at its destination ?" << endl;
#endif
	if (car->Location() == car->Destination()) return false;
//	Is the car too long for this train ?
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: Is the car too long for this train ?" << endl;
#endif
	if (trainLength + car->Length() > train->MaxLength()) return false;
//	Is the car too large, or too heavy for the train ?
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: Is the car too large, or too heavy for the train ?" << endl;
#endif
	if (car->Plate() > train->MaxClear()) return false;
	if (car->WeightClass() > train->MaxWeight()) return false;
//	Is the car too large, or too heavy for the destination ?
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: Is the car too large, or too heavy for the destination ?" << endl;
#endif
	if (car->Length() > carDest->MaxCarLen()) return false;
	if (car->Plate() > carDest->MaxPlate()) return false;
	if (car->WeightClass() > carDest->MaxWeightClass()) return false;
//	Can the train move this type of car ?
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: Can the train move this type of car ?" << endl;
	cerr << "*** TrainCarPickupCheck: car->Type() = '" << car->Type() << "', train->carTypes = '" << train->carTypes << "'" << endl;
#endif
	if (train->carTypes.size() > 0) {
	  if (train->carTypes[0] == '-') {
	    if (train->carTypes.find(car->Type(),1) != string::npos) return false;
	  } else {
	    if (train->carTypes.find(car->Type()) == string::npos) return false;
	  }
	}
//	That's it for MANIFEST trains -- this car is Ok!
//	-----------------------------------------------
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: That's it for MANIFEST trains -- this car is Ok!" << endl;
	cerr << "*** TrainCarPickupCheck: wayFreight = " << wayFreight << endl;
#endif
	if (!wayFreight) {
	  carDest->remLen -= car->Length();
	  CarVector::iterator Lx = FindCarInCarVector(consist,NULL);
	  TrainPickupOneCar(car,train,boxMove,consist,didAction,Px,Lx,Log,printer);
#ifdef DEBUG
	  cerr << "*** Train CarPickupCheck: Car picked up" << endl;
#endif
	  return true;
	}
//	A WAYFREIGHT needs to have some space available - unless it's a yard
//	-----------------------------------------------
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: A WAYFREIGHT needs to have some space available - unless it's a yard" << endl;
#endif
	bool exp1 = (carDest->usedLen + car->Length()) <= carDest->TrackLen();
	if (exp1 || carDest->Type() == 'Y') {
#ifdef DEBUG
	  cerr << "*** TrainCarPickupCheck: carDest->remLen = " << carDest->remLen << endl;
#endif
	  carDest->remLen -= car->Length();
#ifdef DEBUG
	  cerr << "*** TrainCarPickupCheck: carDest->remLen (updated) = " << carDest->remLen << endl;
#endif
	  CarVector::iterator Lx = FindCarInCarVector(consist,NULL);
	  TrainPickupOneCar(car,train,boxMove,consist,didAction,Px,Lx,Log,printer);
#ifdef DEBUG
	  cerr << "*** TrainCarPickupCheck: Car picked up" << endl;
#endif
	  return true;
	}
//============================================================================
// Oops! Now for some fancy footwork -- we look ahead to see whether
// this train will REMOVE another car from the destination, to create
// an opening for this car.
//============================================================================
#ifdef DEBUG
	cerr << "*** TrainCarPickupCheck: fancy footwork" << endl;
#endif
	CarVector::iterator OtherCx;
	Car *otherCar;
	for (OtherCx = cars.begin(); OtherCx != cars.end(); OtherCx++) {
	  otherCar = *OtherCx;
	  if (otherCar != NULL && !otherCar->Peek() && otherCar->Location() == carDest) {
//	    Exp1 means the other car has a new destination, and is able to move
	    bool exp1a = otherCar->Destination() != carDest;
	    bool exp1b = !otherCar->IsDoneP();
	    bool exp1  = exp1a && exp1b;
//	    Exp2 means the removal of the other car will make room for this one	    
	    bool exp2 = (otherCar->Length() + carDest->remLen) >= car->Length();
//	    Exp3 was used to test to see if removal of this car from its YARD
//	    would make room for the other car to replace it -- but this makes
//	    no sense in some cases so I deleted this test.
//	    bool exp3 = car->Location()->TrackLength() >= ( car->Location()->usedLen - car->Length() + otherCar->Length() );
	    if (exp1 && exp2) {
	      if (OtherCarOkForTrain(otherCar,train)) {
	      	otherCar->SetPeek(true);
		carDest->remLen -= car->Length();
		CarVector::iterator Lx = FindCarInCarVector(consist,NULL);
		TrainPickupOneCar(car,train,boxMove,consist,didAction,Px,Lx,Log,printer);
#ifdef DEBUG
		cerr << "*** TrainCarPickupCheck: Car picked up" << endl;
#endif
		return true;
	      }
	    }
	  }
	}
	return false;
}

/*************************************************************************
 *                                                                       *
 * Can we pickup an other car?						 *
 *                                                                       *
 *************************************************************************/

bool System::OtherCarOkForTrain(Car *car, Train *train)
{
	//      Is the car too large, or too heavy for the train ?
	if (car->Plate() > train->MaxClear()) return false;
	if (car->WeightClass() > train->MaxWeight()) return false;
//	Can the train move this type of car ?
	if (train->carTypes.size() > 0) {
	  if (train->carTypes[0] == '-') {
	    if (train->carTypes.find(car->Type(),1) != string::npos) return false;
	  } else {
	    if (train->carTypes.find(car->Type()) == string::npos) return false;
	  }
	}
	return true;
}

/*************************************************************************
 *                                                                       *
 * Print the town we are in.						 *
 *                                                                       *
 *************************************************************************/

void System::TrainPrintTown(const Train *train,const Station *curStation,PrinterDevice *printer)
{
	if (!trainPrintOK) return;
	if (totalPickups == 0) {PrintTrainOrderHeader(train,printer);}

	printer->PutLine("");
	printer->Put(curStation->Name());
	int nameLen = strlen(curStation->Name());
	printer->Put(" ");
	if (nameLen < 36) printer->Put(string(36-nameLen,'_'));
	printer->PutLine("");
}

/*************************************************************************
 *                                                                       *
 * Handle drops from a manifest freight.				 *
 *                                                                       *
 *************************************************************************/

void System::TrainManifestDrops(Train *train, int Px, CarVector &consist,
				bool &didAction,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer) 
{
	IndustryMap::iterator Ix;
	int FuturePx;
	CarVector::iterator Lx,index;
	Car *Cx;
	Industry *curInd = train->IndustryStop(Px), *FutureInd;
	Station  *curStation = curInd->MyStation();
	Division *curDiv = curStation->MyDivision();

	for (Lx = consist.begin(); Lx != consist.end(); Lx++) {
	  if (*Lx != NULL) {
	    Cx = *Lx;
//	    If this stop is an industry rather than a yard, check whether it's
//	    the car's final destination. If it is, then drop it -- Notice that
//	    a manifest does NOT CHECK for space available at the destination !
	    if (curInd->Type() != 'Y'  && Cx->Destination() == curInd) {
	      index = FindCarInCarVector(Cx->Location()->cars,Cx);
	      if (index != Cx->Location()->cars.end()) {
	      	Cx->Location()->cars.erase(index);
	      }
	      Cx->SetLocation(curInd);
	      Cx->Location()->cars.push_back(Cx);
	      TrainDropOneCar(Cx,train,Lx,consist,didAction,Px,Log,printer);
	      continue;
	    }
//	    If this stop is a yard, check whether it is the home yard for the
//	    car's final destination. If it is, then drop it.
//
//	    Note that a train that carries a car to its final destination AND
//	    stops at the home yard of that destination, may deliver the car to
//	    the yard rather than the industry.
//
//	    To avoid the above scenario, look ahead to see if any of the stops
//	    down the line really -IS- the final destination!
	    Industry *curDivHome = curDiv->Home();
	    Division *destDiv = Cx->Destination()->MyStation()->MyDivision();
	    bool nextCarInManifest = false;
	    if (curInd->Type() == 'Y' && curDivHome == destDiv->Home()) {
	      for (FuturePx = train->NumberOfStops()-1; FuturePx > Px; FuturePx--) {
	        FutureInd = train->IndustryStop(FuturePx);
	        if (FutureInd == Cx->Destination()) {
	      	  nextCarInManifest = true;
	      	  break;
	        }
	      }
	      if (nextCarInManifest) continue;
	      index = FindCarInCarVector(Cx->Location()->cars,Cx);
	      if (index != Cx->Location()->cars.end()) {
	        Cx->Location()->cars.erase(index);
	      }
	      Cx->SetLocation(curInd);
	      Cx->Location()->cars.push_back(Cx);
	      TrainDropOneCar(Cx,train,Lx,consist,didAction,Px,Log,printer);
	    }
	  }
	}
}

/*************************************************************************
 *                                                                       *
 * Drop all cars from a train.  This happens when we get to our final    *
 * location.								 *
 *                                                                       *
 *************************************************************************/

void System::TrainDropAllCars(Train *train, int Px, CarVector &consist,
			     const LogMessageCallback     *Log,
			           PrinterDevice          *printer) 
{
	CarVector::iterator Lx,index;
	Car *Cx;
	bool didAction = false;

#ifdef DEBUG
	cerr << "*** TrainDropAllCars(" << train->Name() << "," << Px <<
		"," << consist << ",-log-,-printer-)" << endl;
#endif
	for (Lx = consist.begin(); Lx != consist.end(); Lx++) {
	  if (*(Lx) != NULL) {
#ifdef DEBUG
	    cerr << "*** TrainDropAllCars: *(Lx) = " << *(Lx) << endl;
#endif
	    Cx = *(Lx);
#ifdef DEBUG
	    cerr << "*** TrainDropAllCars: Cx->Location() = " << Cx->Location()->Name() << endl;
	    cerr << "*** TrainDropAllCars: Cx->Location()->cars = " << Cx->Location()->cars << endl;
#endif
	    index = FindCarInCarVector(Cx->Location()->cars,Cx);
	    if (index != Cx->Location()->cars.end()) {
	      Cx->Location()->cars.erase(index);
	    }
	    Cx->SetLocation(trainLastLocation);
	    Cx->Location()->cars.push_back(Cx);
	    TrainDropOneCar(Cx,train,Lx,consist,didAction,Px,Log,printer);
	  }
	}
}

/*************************************************************************
 *                                                                       *
 * Print a train's final summary.					 *
 *                                                                       *
 *************************************************************************/

void System::TrainPrintFinalSummary(Train *train,PrinterDevice *printer) 
{
	if (!trainPrintOK) return;

	printer->PutLine("");
	printer->Tab(4);
	printer->PutLine(_("Train Termination Report"));
	printer->PutLine("");
	printer->Tab(11);
	printer->Put(_(" Total cars handled  = ")); 
	printer->Put(totalPickups); 
	printer->PutLine("");
	printer->Tab(11);
	printer->Put(_(" Total loads handled = ")); 
	printer->Put(totalLoads); 
	printer->PutLine("");
	printer->Tab(11);
	printer->Put(_(" Total gross tons    = ")); 
	printer->Put(totalTons); 
	printer->PutLine("");
	printer->Tab(11);
	printer->Put(_(" Total revenue tons  = ")); 
	printer->Put(totalRevenueTons);
	printer->PutLine("");

	PrintFormFeed(printer);
}


/*************************************************************************
 *                                                                       *
 * Print a train's consist summary.					 *
 *                                                                       *
 *************************************************************************/

void System::TrainPrintConsistSummary(Train *train,CarVector &consist,
				      PrinterDevice *printer)
{
	if (!trainPrintOK) return;

	printer->PutLine("");
	printer->Tab(7);
	printer->Put(_(" Current cars = "));
	printer->Put(numberCars);
	printer->Put(_(" Empties = "));
	printer->Put(trainEmpties);
	printer->Put(_(" Loads = "));
	printer->Put(trainLoads);
	printer->Put(_(" Tons = "));
	printer->Put(trainTons);
	printer->Put(_(" Length = "));
	printer->Put(trainLength);
	printer->PutLine(_("ft"));
}

/*************************************************************************
 *                                                                       *
 * Print a train order header.						 *
 *                                                                       *
 *************************************************************************/

void System::PrintTrainOrderHeader(const Train *train,PrinterDevice *printer)
{
	PrintSystemBanner(printer);

	printer->Put(_("TRAIN #"));
	printer->Put(TrainIndex(train));
	printer->Put(" -- ");
	printer->Put(train->Name());
	printer->Put(_(" pick up on Yard Track ______ Departure "));
	printer->PutLine(FormatDutyTime(train->OnDuty()));
	printer->PutLine("");
	printer->Tab(12);
	printer->PutLine(train->Description());

	PrintTrainOrders(train,printer);
	printer->SetTypeSpacing(PrinterDevice::Half);
}

/*************************************************************************
 *                                                                       *
 * Print a form feed (new page).					 *
 *                                                                       *
 *************************************************************************/

void System::PrintFormFeed(PrinterDevice *printer) const
{
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->NewPage("");
}

/*************************************************************************
 *                                                                       *
 * Print the system banner.						 *
 *                                                                       *
 *************************************************************************/

void System::PrintSystemBanner(PrinterDevice *printer) const
{
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Put(UpperCase(systemName));
	int strLen = systemName.size();
	if (strLen < 18) printer->Put(string(18-strLen,' '));
	printer->Put(_(" Session "));
	printer->Put(sessionNumber);
	printer->Put(": ");
	printer->Put(shiftNumber);
	printer->Put("  ");
	printer->PutLine(Today());
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->PutLine("");	
}

/*************************************************************************
 *                                                                       *
 * Format our on-duty time.						 *
 *                                                                       *
 *************************************************************************/

const string System::FormatDutyTime(int dutytimeminutes) const
{
	static char buffer[6];
	sprintf(buffer,"%02d%02d",dutytimeminutes / 60, dutytimeminutes % 60);
	return string(buffer);
}

/*************************************************************************
 *                                                                       *
 * Print a train's orders.						 *
 *                                                                       *
 *************************************************************************/

void System::PrintTrainOrders(const Train *train,PrinterDevice *printer) const
{
	vector<string>::const_iterator Ox;
	
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->PutLine("");
	for (Ox = train->orders.begin(); Ox != train->orders.end(); Ox++) {
	  printer->PutLine(*Ox);
	}
}

#include <time.h>
#if !HAVE_LOCALTIME_R
extern "C" struct tm *localtime_r(const time_t *, struct tm *);
#endif
#if !HAVE_ASCTIME_R
extern "C" char *asctime_r(const struct tm *, char *);
#endif

/*************************************************************************
 *                                                                       *
 * Print todays date and time.						 *
 *                                                                       *
 *************************************************************************/

const string System::Today() const
{
	struct tm thetime;
	time_t seconds;
	char buffer[30];

	time(&seconds);
	localtime_r(&seconds,&thetime);
	return asctime_r(&thetime,buffer);	
}

#include <ctype.h>

/*************************************************************************
 *                                                                       *
 * Convert a string to all uppercase.					 *
 *                                                                       *
 *************************************************************************/

const string System::UpperCase(const string str) const
{
	string result("");
	string::const_iterator cx;

	for (cx = str.begin(); cx != str.end(); cx++) {
	  if (isalpha(*cx)) {
	    result += toupper(*cx);
	  } else {
	    result += *cx;
	  }
	}
	return result;
}

/*************************************************************************
 *                                                                       *
 * Print a dashed line.							 *
 *                                                                       *
 *************************************************************************/

void System::PrintDashedLine(PrinterDevice *printer) const
{
	printer->PutLine(string(136,'-'));
}

/*************************************************************************
 *                                                                       *
 * Print the dispatcher report.						 *
 *                                                                       *
 *************************************************************************/

void System::PrintDispatcher(string banner,char trainType,PrinterDevice *printer) const
{
	TrainMap::const_iterator Tx;
	Train *tx;
	unsigned int Gx;
	int total;
	
	PrintSystemBanner(printer);
	printer->PutLine("");
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(6);
	printer->Put(_("DISPATCHER Report - "));printer->PutLine(banner);
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine("");
	printer->PutLine("");
	printer->Put("name");
	printer->Tab(26);
	printer->Put(_("engine"));
	printer->Tab(50);
	printer->Put(_("cab"));
	printer->Tab(60);
	printer->Put(_("engineer"));
	printer->Tab(82);
	printer->Put(_("depart"));
	printer->Tab(102);
	printer->Put(_("arrive"));
	printer->Tab(122);
	printer->PutLine(_("total cars"));

	PrintDashedLine(printer);

	printer->PutLine("");

	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
	  if ((Tx->second) == NULL) continue;
	  tx = Tx->second;
	  if (tx->Shift() == shiftNumber) {
	    if (tx->Type() == trainType) {
	      total = 0;
	      for (Gx = 0; Gx < switchList.PickIndex(); Gx++) {
	      	if (switchList.PickTrainEq(Gx,tx)) total++;
	      }
	      if (total == 0) continue;

	      printer->SetTypeSpacing(PrinterDevice::One);
	      printer->SetTypeSpacing(PrinterDevice::Double);
	      printer->Put(tx->Name());
	      printer->Tab(8);
	      printer->Put("______ __ _____ __/__ __/__  ");
	      printer->Put(total);
	      printer->PutLine("");
	      printer->PutLine("");
	    }
	  }
	}
	PrintFormFeed(printer);
}


/*************************************************************************
 *                                                                       *
 * Run a single train.							 *
 *                                                                       *
 *************************************************************************/

void System::RunOneTrain(Train *train,bool boxMove,
			 const TrainDisplayCallback   *traindisplay,
			 const LogMessageCallback     *Log,
			       PrinterDevice          *printer)
{
	InternalRunOneTrain(train,boxMove,traindisplay,Log,printer);
}

/*************************************************************************
 *                                                                       *
 * Display cars not moved.						 *
 *                                                                       *
 *************************************************************************/

void System::ShowCarsNotMoved(const LogMessageCallback     *Log,
			      const ShowBannerCallback     *banner) const
{
  int Total, CarCount;
  CarVector::const_iterator Cx;
  const Car *car;
  char buffer[256];
  string status, carTypeDescr;
  const char *LocName, *DestName;
  const Industry *Loc, *Dest;

  Total = 0;
  CarCount = 0;
  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
    if ((car = *Cx) == NULL) continue;
    if (car->MovementsThisSession() == 0 && !car->IsDoneP() &&
	car->Location() != IndScrapYard() && 
	car->Location() != IndRipTrackConst()) {
      if (Total == 0) {
      	banner->ShowBanner();
      	sprintf(buffer,"%-20s%-18s%-29s %s\n",_("Cars Not Moved"),_("Car type"),
		_("Status  Location"),_("Destination"));
	Log->LogMessage(LogMessageCallback::Infomational,buffer);
	Log->LogMessage(LogMessageCallback::Infomational,string(78,'-')+"\n");
      }
      GetCarStatus(car,status,carTypeDescr);
      Loc = car->Location();
      if (Loc != NULL) {
      	LocName = Loc->Name();
      } else {
      	LocName = "-";
      }
      Dest = car->Destination();
      if (Dest == Loc) {
      	DestName = "-";
      } else if (Dest != NULL) {
      	DestName = Dest->Name();
      } else {
      	DestName = "-";
      }
      sprintf(buffer,"%-11s%-9s%-18s%-8s%-21s %s\n",car->Marks(),car->Number(),
      	      carTypeDescr.c_str(),status.c_str(),LocName,DestName);
      Log->LogMessage(LogMessageCallback::Infomational,buffer);
      Total++;
      CarCount++;
      if (Total == 18) Total = 0;
    }
  }
  if (CarCount == 0) return;
  sprintf(buffer,_("\n                                                    Cars subtotal: %d\n"),CarCount);
  Log->LogMessage(LogMessageCallback::Infomational,buffer);    
}
        
/*************************************************************************
 *                                                                       *
 * Display car movements.						 *
 *                                                                       *
 *************************************************************************/

void System::ShowCarMovements(bool showAll,const Industry *Ix, const Train *Tx,
			      const LogMessageCallback     *Log,
			      const ShowBannerCallback     *banner) const
{
  int Total, CarCount, Count;
  CarVector::const_iterator Cx;
  const Car *car;
  char buffer[256];
  string status, carTypeDescr;
  string DestName;
  const Industry *Dest;
  string typeName, carid, prev, trains[3];
  int Gx;

  Total = 0;
  CarCount = 0;
  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
    if ((car = *Cx) == NULL) continue;
    if (car->Location() == IndScrapYard() ||
	car->Location() == IndRipTrackConst()) continue;
    if (!showAll) {
      if (car->MovementsThisSession() == 0) continue;
    }
    if (Tx != NULL) { // By Train
      // Only show moves if the car travelled in this train!
      for (Gx = 0; Gx < switchList.LimitCars(); Gx++) {
      	if (switchList.PickCarEq(Gx,car) &&
	    switchList.PickTrainEq(Gx,Tx)) break;
      }
      if (Gx >= switchList.LimitCars()) continue;
    } else if (Ix != NULL) { // By Industry
      // Only show moves if the car is in this location
      if (Ix != car->Location()) continue;
    }
    if (Total == 0) {
      banner->ShowBanner();
      sprintf(buffer,"%-21s%-7s%-8s%-8s%-8s%-8s%s\n%s\n",_("Cars Moved"),_("Type"),
		_("Prv"),_("1st"),_("2nd"),_("3rd"),_("Destination"),string(79,'-').c_str());
	Log->LogMessage(LogMessageCallback::Infomational,buffer);
    }
    GetCarStatus(car,status,carTypeDescr);
    Dest = car->Destination();
    if (Dest != NULL) {
      DestName = Dest->Name();
    } else {
      DestName = "-";
    }
    carid = car->Marks();
    while (carid.size() < 11) carid += ' ';
    carid += car->Number();
    while (carid.size() < 21) carid += ' ';
    typeName = carTypeDescr.substr(0,5);
    while (typeName.size() < 7) typeName += ' ';
    if (car->PrevTrain() != NULL) {
      prev = string(car->PrevTrain()->Name()).substr(0,7);
      while(prev.size() < 8) prev += ' ';
    } else {
      prev = "-";
      while(prev.size() < 8) prev += ' ';
    }
    Count = 0;
    for (Gx = 0; Gx < switchList.LimitCars(); Gx++) {
      if (switchList.PickCarEq(Gx,car)) {
      	trains[Count] = string(switchList[Gx].PickTrain()->Name()).substr(0,7);
      	while (trains[Count].size() < 8) trains[Count] += ' ';
      	Count++;
      	if (Count == 3) break;
      }
    }
    while (Count < 3) {
      trains[Count] = "-";
      while (trains[Count].size() < 8) trains[Count] += ' ';
      Count++;
    }
    Dest = car->Destination();
    if (Dest != NULL) {
      DestName = string(Dest->Name()).substr(0,19);
    } else {
      DestName = "-";
    }
    Log->LogMessage(LogMessageCallback::Infomational,
    	carid+typeName+prev+trains[0]+trains[1]+trains[2]+DestName+"\n");
    Total++;
    CarCount++;
    if (Total == 18) Total = 0;
  }
  if (CarCount == 0) return;
  sprintf(buffer,_("\n                                                    Cars subtotal: %d\n"),CarCount);
  Log->LogMessage(LogMessageCallback::Infomational,buffer);    
}
        
#ifdef NOPE
/*************************************************************************
 *                                                                       *
 * This function is not implemented.					 *
 *                                                                       *
 *************************************************************************/

void System::CompileCarMovements(const LogMessageCallback     *Log,
				const ShowBannerCallback     *banner) const
{
}
#endif

/*************************************************************************
 *                                                                       *
 * Show cars in a specified division.					 *
 *                                                                       *
 *************************************************************************/

void System::ShowCarsInDivision(const Division * division,
			 	const LogMessageCallback     *Log,
				const ShowBannerCallback     *banner) const
{
  int Total, CarCount;
  CarVector::const_iterator Cx;
  const Car *car;
  char buffer[256];
  string status, carTypeDescr;
  const char *LocName, *DestName;
  const Industry *Loc, *Dest;
  const Station *istation;

  Total = 0;
  CarCount = 0;
  for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
    if ((car = *Cx) == NULL) continue;
    Loc = car->Location();
    if (Loc != NULL) {
      LocName = Loc->Name();
      istation = Loc->MyStation();
    } else {
      continue;
    }
    if (istation->MyDivision() == division) {
      if (Total == 0) {
      	banner->ShowBanner();
      	sprintf(buffer,"%-18s%c %-18s%-29s %s\n",_("Cars In Div"),
		division->Symbol(),_("Car type"),
		_("Status  Location"),_("Destination"));
	Log->LogMessage(LogMessageCallback::Infomational,buffer);
	Log->LogMessage(LogMessageCallback::Infomational,string(78,'-')+"\n");
      }
      GetCarStatus(car,status,carTypeDescr);
      Dest = car->Destination();
      if (Dest == Loc) {
      	DestName = "-";
      } else if (Dest != NULL) {
      	DestName = Dest->Name();
      } else {
      	DestName = "-";
      }
      sprintf(buffer,"%-11s%-9s%-18s%-8s%-21s %s\n",car->Marks(),car->Number(),
      	      carTypeDescr.c_str(),status.c_str(),LocName,DestName);
      Log->LogMessage(LogMessageCallback::Infomational,buffer);
      Total++;
      CarCount++;
      if (Total == 18) Total = 0;
    }
  }
  if (CarCount == 0) return;
  sprintf(buffer,"\n                                                    Cars subtotal: %d\n",CarCount);
  Log->LogMessage(LogMessageCallback::Infomational,buffer);    
}

/*************************************************************************
 *                                                                       *
 * Display train totals.						 *
 *                                                                       *
 *************************************************************************/

void System::ShowTrainTotals(const LogMessageCallback     *Log,
				const ShowBannerCallback     *banner) const
{
  int Count, TrainCount, Gx, z;
  TrainMap::const_iterator Tx;
  const Train *train;
  char buffer[8];
  string line, halfLine;

  banner->ShowBanner();

  line  = _("Train");
  while (line.size() < 11) line += ' ';
  line += _("Cars");
  while (line.size() < 31) line += ' ';
  line += _("Train");
  while (line.size() < 41) line += ' ';
  line += _("Cars\n");
  line += string(78,'-');
  line += '\n';
  Log->LogMessage(LogMessageCallback::Infomational,line);  
  
  TrainCount = 0;

  for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
    if ((train = Tx->second) == NULL) continue;
    if (train->Shift() == shiftNumber) {
      Count = 0;
      TrainCount++;
      for (Gx = 0; Gx < switchList.LimitCars(); Gx++) {
      	if (switchList.PickTrainEq(Gx,train)) Count++;
      }
      z = TrainCount & 1;
      halfLine = train->Name();
      while (halfLine.size() < 11) halfLine += ' ';
      sprintf(buffer,"%d",Count);
      halfLine += buffer;
      while (halfLine.size() < 31) halfLine += ' ';
      if (z == 1) {
      	line  = halfLine;
      } else {
      	line += halfLine;
      	line += '\n';
      	Log->LogMessage(LogMessageCallback::Infomational,line);
      }
    }
  }
}

#ifdef DEBUG
ostream & operator<< (ostream & stream, vector<int> vi)
{
	stream << "<vector<int>:";
	for (vector<int>::const_iterator i = vi.begin(); i != vi.end(); i++) {
		stream << " " << *i;
	}
	stream << ">";
	return stream;
}
#endif

/*************************************************************************
 *                                                                       *
 * Search for a train name pattern.					 *
 *                                                                       *
 *************************************************************************/

vector<int> System::SearchForTrainPattern(string trainNamePattern) const
{
	TrainMap::const_iterator Tx;
	const Train *train;
	vector<int> result;
	string trainName;

#ifdef DEBUG
	cerr << "*** System::SearchForTrainPattern(" << trainNamePattern << ")" << endl;
#endif
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
	  if ((train = Tx->second) == NULL) continue;
	  trainName = train->name;
#ifdef DEBUG
	  cerr << "*** System::SearchForTrainPattern: Tx->first = " << Tx->first << endl;
	  cerr << "*** System::SearchForTrainPattern: trainName = " << trainName << endl;
#endif
	  if (GlobStringMatch(trainName,trainNamePattern)) {
#ifdef DEBUG
	    cerr << "*** System::SearchForTrainPattern: pushing back " << Tx->first << endl;
#endif
	    result.push_back(Tx->first);
	  }
	}
#ifdef DEBUG
	cerr << "*** System::SearchForTrainPattern: returning " << result << endl;
#endif
	return result;
}

/*************************************************************************
 *                                                                       *
 * Show the cars current in a train.					 *
 *                                                                       *
 *************************************************************************/

void System::ShowTrainCars(const Train *Tx,
			   const LogMessageCallback     *Log,
			   const ShowBannerCallback     *banner) const
{
  int Total, CarCount;
  unsigned int Gx;
  CarVector::const_iterator Cx;
  const Car *car;
  char buffer[256];
  string status, carTypeDescr;
  const char *LocName, *DestName;
  const Industry *Loc, *Dest;
	
  Total = 0;
  CarCount = 0;

  for (Gx = 0; Gx < switchList.PickIndex(); Gx++) {
    if (switchList.PickTrainEq(Gx,Tx)) {
      car = switchList[Gx].PickCar();
      if (Total == 0) {
      	sprintf(buffer,"%-10s%-10s%-18s%-29s %s\n",Tx->Name(),_(" pickups"),
		_("Car type"),_("Status  Location"),_("Destination"));
	Log->LogMessage(LogMessageCallback::Infomational,buffer);
	Log->LogMessage(LogMessageCallback::Infomational,string(78,'-')+"\n");
      }
      GetCarStatus(car,status,carTypeDescr);
      Loc = car->Location();
      if (Loc != NULL) {
      	LocName = Loc->Name();
      } else {
      	LocName = "-";
      }
      Dest = car->Destination();
      if (Dest == Loc) {
      	DestName = "-";
      } else if (Dest != NULL) {
      	DestName = Dest->Name();
      } else {
      	DestName = "-";
      }
      sprintf(buffer,"%-11s%-9s%-18s%-8s%-21s %s\n",car->Marks(),car->Number(),
      	      carTypeDescr.c_str(),status.c_str(),LocName,DestName);
      Log->LogMessage(LogMessageCallback::Infomational,buffer);
      Total++;
      CarCount++;
      if (Total == 18) Total = 0;
    }
  }
  if (CarCount == 0) return;
  sprintf(buffer,_("\n                                                    Cars subtotal: %d\n"),CarCount);
  Log->LogMessage(LogMessageCallback::Infomational,buffer);    
      	
}

}
