/* 
 * ------------------------------------------------------------------
 * System_Reports.cc - Report Generation functions
 * Created by Robert Heller on Sat Oct 15 10:25:01 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/10/22 17:17:27  heller
 * Modification History: 10222007
 * Modification History:
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 01:25:32  heller
 * Modification History: Nov 4, 2005 Lockdown
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

#include "config.h"
#include <System.h>
#include "../gettext.h"

namespace FCFSupport {

/**************************************************************************
 *                                                                        *
 * Print an industry report.                                              *
 *                                                                        *
 **************************************************************************/


void System::ReportIndustries(const WorkInProgressCallback *WIP,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage) const
{
    double tenth, donePer;
    DivisionMap::const_iterator Dx;
    const Division *dx;
    StationVector::const_iterator Sx;
    const Station *sx;
    IndustryVector::const_iterator Ix;
    const Industry *ix;
    int lenInDiv,carsInDiv,carsToDiv;
    string divisionName;
    static char message[256];
    char buffer[64];
	
    // Print system banner.
    PrintSystemBanner(printer);
    // Print report header
    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(10);
    printer->PutLine(_("INDUSTRY Report"));
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeWeight(PrinterDevice::Normal);

    // Print Industry header
    PrintIndustryHeader(printer);

    // Print a dashed line
    PrintDashedLine(printer);

    // Start the progress meter.
    WIP->ProgressStart(_("Industry Report In Progress..."));
    tenth = 10.0 / (double)(divisions.size());
    donePer = 0.0;
    WIP->ProgressUpdate(0,_("0% Done"));
    // For each division...
    for (Dx = divisions.begin(); Dx != divisions.end(); Dx++) {
        donePer += tenth*10.0;
        sprintf(buffer,_("%6.2f%% Done"),donePer);
        WIP->ProgressUpdate((int)donePer,buffer);
        if ((Dx->second) == NULL) continue;	// Skip empty division slots
        dx = Dx->second;
        // Get division name and log it.
        divisionName = dx->Name();
        if (divisionName.size() == 0) continue;
        sprintf(message,_("Division: %s\n"),divisionName.c_str());
        Log->LogMessage(LogMessageCallback::Infomational,message);
        // Zero division totals.
        carsToDiv = 0;
        carsInDiv = 0;
        lenInDiv  = 0;
        // For ever station in this division...
        for (Sx = dx->stations.begin(); Sx != dx->stations.end(); Sx++) {
	    if (*Sx == NULL) continue;
	    sx = *Sx;
	    // For every industry at this station...
	    for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
                if (*Ix == NULL) continue;
                ix = *Ix;
                // Print this industry's information.
                PrintOneIndustry(ix,lenInDiv,carsInDiv,carsToDiv,Log,printer);
	    }
        }
        // Print division summary.
        printer->PutLine();
        sprintf(message,_("Totals for <%c> %s"),dx->Symbol(),dx->Name());
        printer->Put(message);
        printer->Tab(44);
        printer->Put("=============================>");
        printer->Tab(76);
        printer->Put(lenInDiv);
        printer->Tab(96);
        printer->Put(carsInDiv);
        printer->Tab(106);
        printer->Put(carsToDiv);
        printer->PutLine();
        printer->PutLine();
    }
    // Done.
    WIP->ProgressDone(_("Done"));
    PrintFormFeed(printer);
}


/**************************************************************************
 *                                                                        *
 * Print an industry header.                                              *
 *                                                                        *
 **************************************************************************/

void System::PrintIndustryHeader(PrinterDevice *printer) const
{
  printer->Put("#");
  printer->Tab(5);
  printer->Put(_("City"));
  printer->Tab(37);
  printer->Put(_("Industry"));
  printer->Tab(66);
  printer->Put(_("Trk Len"));
  printer->Tab(76);
  printer->Put(_("Cur Len"));
  printer->Tab(86);
  printer->Put(_("Asn Len"));
  printer->Tab(96);
  printer->Put(_("Cars Now"));
  printer->Tab(106);
  printer->Put(_("Cars Dst"));
  printer->Tab(116);
  printer->Put(_("Lds Avail"));
  printer->Tab(128);
  printer->PutLine(_("Emp Avail"));
}

/**************************************************************************
 *                                                                        *
 * Print one industry's information.                                      *
 *                                                                        *
 **************************************************************************/

void System::PrintOneIndustry(const Industry *ix,
			      int &lenInDiv,int &carsInDiv, int &carsToDiv,
			      const LogMessageCallback     *Log,
				    PrinterDevice          *printer) const
{
	static char message[256];
	int ldsAvail, emtAvail, carsTo, carsIn, indLen;
	CarVector::const_iterator Cx;
	const Car *car;

	sprintf(message,_("  Industry: %s\n"),ix->Name());

	carsTo = 0;
	carsIn = 0;
	indLen = 0;

	ldsAvail = 0;
	emtAvail = 0;

	// Loop through all cars...
	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	  if (*Cx == NULL) continue;
	  car = *Cx;
	  // Count the cars headed to this industry.
	  if (ix == car->Destination()) carsTo++;
	  // Count the cars already here.
	  if (ix == car->Location()) {
	    carsIn++;
	    indLen += car->Length();
	  }
	  // Count how many loads and empties are available for this industry.
	  if (ix->loadTypes.find(car->Type()) != string::npos) ldsAvail++;
	  if (ix->emptyTypes.find(car->Type()) != string::npos) emtAvail++;
	}

	// Print this industry's information.
	printer->Put(FindIndustryIndex(ix));
	printer->Tab(5);
	printer->Put(FindStationIndex(ix->MyStation()));
	printer->Tab(9);
	printer->Put(ix->MyStation()->Name());
	printer->Tab(37);
	printer->Put(ix->Name());
	printer->Tab(66);
	printer->Put(ix->TrackLen());
	printer->Tab(76);
	printer->Put(ix->AssignLen());
	printer->Tab(86);
	printer->Put(indLen);
	printer->Tab(96);
	printer->Put(carsIn);
	printer->Tab(106);
	printer->Put(carsTo);
	printer->Tab(116);
	printer->Put(ldsAvail);
	printer->Tab(128);
	printer->Put(emtAvail);
	printer->PutLine();

	// Accumulate division totals.
	carsToDiv += carsTo;
	carsInDiv += carsIn;
	lenInDiv  += indLen;
}

int System::FindIndustryIndex(const Industry *industry) const
{
	IndustryMap::const_iterator Ix;
	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  if ((Ix->second) == industry) return Ix->first;
	}
	return -1;
}

int System::FindStationIndex(const Station *station) const
{
	StationMap::const_iterator Sx;
	for (Sx = stations.begin(); Sx != stations.end(); Sx++) {
	  if ((Sx->second) == station) return Sx->first;
	}
	return -1;
}
               
int System::FindDivisionIndex(const Division *division) const
{
	DivisionMap::const_iterator Dx;
	for (Dx = divisions.begin(); Dx != divisions.end(); Dx++) {
	  if ((Dx->second) == division) return Dx->first;
	}
	return -1;
}

/**************************************************************************
 *                                                                        *
 * Print train orders                                                     *
 *                                                                        *
 **************************************************************************/

               
void System::ReportTrains(const WorkInProgressCallback *WIP,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage) const
{
    double tenth, donePer;
    TrainMap::const_iterator Tx;
    const Train *tx;
    static char message[256];
    char buffer[64];
    
    // System banner.
    PrintSystemBanner(printer);
    
    // Heading
    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(10);
    printer->PutLine(_("TRAINS Report"));
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeWeight(PrinterDevice::Normal);
    
    PrintDashedLine(printer);
    
    // Start progress meter.
    WIP->ProgressStart(_("TRAINS Report In Progress..."));
    tenth = 10.0 / (double)(trains.size());
    donePer = 0.0;
    WIP->ProgressUpdate(0,_("0% Done"));
    
    // For every train...
    for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
        donePer += tenth*10;
        sprintf(buffer,_("%6.2f%% Done"),donePer);
        WIP->ProgressUpdate((int)donePer,buffer);
        if ((Tx->second) == NULL) continue;
        tx = Tx->second;
        sprintf(message,_("%s\n"),tx->Name());
        Log->LogMessage(LogMessageCallback::Infomational,message);
        printer->PutLine();
        printer->SetTypeSpacing(PrinterDevice::One);
        //printer->SetTypeSpacing(PrinterDevice::Double);
        printer->SetTypeWeight(PrinterDevice::Bold);
        printer->PutLine(tx->Name());
        printer->SetTypeWeight(PrinterDevice::Normal);
        PrintTrainOrders(tx,printer);	  
    }
    WIP->ProgressDone(_("Done"));
    PrintFormFeed(printer);
    
}	

/**************************************************************************
 *                                                                        *
 * Print a report on all cars.                                            *
 *                                                                        *
 **************************************************************************/

void System::ReportCars(const WorkInProgressCallback *WIP,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage) const
{
    double tenth, donePer;
    int done, totLines,ncOnB;
    CarVector::const_iterator Cx;
    const Car *car;
    char buffer[64];

    // System banner
    PrintSystemBanner(printer);

    // Car report header
    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(10);
    printer->PutLine(_("CARS Report"));
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeWeight(PrinterDevice::Normal);

    totLines = 4;

    // Car heading
    PrintCarHeading(printer);

    // Start progress meter.
    WIP->ProgressStart(_("CARS Report In Progress (Cars IN Service) ..."));
    WIP->ProgressUpdate(0,_("0% Done"));
    tenth = 100.0 / (double)(cars.size());
    done=10;
    donePer = 0.0;
    // For every car...
    for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
        donePer += tenth;
        if (donePer > done) {
	    sprintf(buffer,_("%f%% Done"),donePer);
	    // Update progress meter.
	    WIP->ProgressUpdate((int)donePer,buffer);
	    done += 10;
        }
        if (*Cx != NULL) {
	    // For non null car slots...
	    car = *Cx;
	    totLines++;
	    // Check page overflow
	    if (totLines > 55) {
                totLines = 0;
                PrintFormFeed(printer);
                PrintCarHeading(printer);
	    }
	    // Print this car's information
	    PrintOneCarInfo(car,printer);
        }
    }
    totLines = 55;
    
    // Process RIP track (workbench)
    ncOnB = IndRipTrackConst()->cars.size();
    if (ncOnB == 0) {
        WIP->ProgressDone(_("Done"));
        PrintFormFeed(printer);
        return;
    }
    tenth = 100.0 / ((double)ncOnB);
    donePer = 0.0;
    done = 10;
    WIP->ProgressStart(_("CARS Report In Progress (Cars on workbench) ..."));
    WIP->ProgressUpdate(0,"0% Done");
    for (Cx = IndRipTrackConst()->cars.begin(); Cx != IndRipTrackConst()->cars.end(); Cx++) {
        donePer += tenth;
        if (donePer > done) {
	    sprintf(buffer,_("%f%% Done"),donePer);
	    WIP->ProgressUpdate((int)donePer,buffer);
	    done += 10;
        }
        if (*Cx != NULL) {
	    car = *Cx;
	    totLines++;
	    if (totLines > 55) {
                totLines = 0;
                PrintFormFeed(printer);
                PrintCarHeading(printer);
	    }
	    PrintOneCarInfo(car,printer);
        }
    }
    WIP->ProgressDone(_("Done"));
    PrintFormFeed(printer);
}

/**************************************************************************
 *                                                                        *
 * Print car page heading                                                 *
 *                                                                        *
 **************************************************************************/

void System::PrintCarHeading(PrinterDevice *printer) const
{
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->Put(_("RR"));
    printer->Tab(11);
    printer->Put(_("NUMBER"));
    printer->Tab(20);
    printer->Put(_("LEN"));
    printer->Tab(25);
    printer->Put(_("CAR TYPE"));
    printer->Tab(56);
    printer->Put(_("L/E"));
    printer->Tab(60);
    printer->Put(_("CUR STATION"));
    printer->Tab(84);
    printer->Put(_("LOCATION"));
    printer->Tab(110);
    printer->PutLine(_("DEST INDUSTRY"));
    PrintDashedLine(printer);
}

/**************************************************************************
 *                                                                        *
 * Print one car's information.                                           *
 *                                                                        *
 **************************************************************************/

void System::PrintOneCarInfo(const Car *car,PrinterDevice *printer) const
{
    CarTypeMap::const_iterator Ct;
    // Reporting marks
    printer->Put(car->Marks());
    printer->Tab(11);
    // Car number
    printer->Put(car->Number());
    printer->Tab(20);
    // Car length
    printer->Put(car->Length());
    printer->Tab(25);
    // Car type
    Ct = carTypes.find(car->Type());
    if (Ct != carTypes.end() && (Ct->second) != NULL) {
        printer->Put((Ct->second)->Type());
    }
    printer->Tab(56);
    // Loaded or empty?
    if (car->LoadedP()) printer->Put('L');
    else printer->Put('E');
    // Where the car is
    printer->Tab(60);
    printer->Put(car->Location()->MyStation()->Name());
    printer->Tab(84);
    printer->Put(car->Location()->Name());
    printer->Tab(110);
    // Where it is going.
    printer->PutLine(car->Destination()->Name());
}


/**************************************************************************
 *                                                                        *
 * Print cars not moved.                                                  *
 *                                                                        *
 **************************************************************************/

void System::ReportCarsNotMoved(const WorkInProgressCallback *WIP,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage) const
{
    double tenth, donePer;
    int done, totLines/*,ncOnB*/;
    CarVector::const_iterator Cx;
    const Car *car;
    IndustryMap::const_iterator Ix;
    const Industry *ix;
    char buffer[64];

    PrintSystemBanner(printer);

    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(10);
    printer->PutLine("CARS NOT MOVED Report");
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeWeight(PrinterDevice::Normal);
    
    totLines = 4;
    
    PrintCarHeading(printer);
    
    WIP->ProgressStart(_("CARS NOT MOVED Report In Progress ..."));
    WIP->ProgressUpdate(0,_("0% Done"));
    tenth = 100.0 / (double)(industries.size());
    done=10;
    donePer = 0.0;
    for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
        donePer += tenth;
        if (donePer > done) {
	    sprintf(buffer,_("%f%% Done"),donePer);
	    WIP->ProgressUpdate((int)donePer,buffer);
	    done += 10;
        }
        if (Ix->second == NULL) continue;
        if (Ix->first  == 0) continue;
        ix = Ix->second;
        for (Cx = ix->cars.begin(); Cx != ix->cars.end(); Cx++) {
	    if (*Cx == NULL) continue;
	    car = *Cx;
	    if (car->MovementsThisSession() == 0) {
                totLines++;
                if (totLines > 55) {
                    totLines = 0;
                    PrintFormFeed(printer);
                    PrintCarHeading(printer);
                }
                PrintOneCarInfo(car,printer);
	    }
        }
    }
    WIP->ProgressDone(_("Done"));
    PrintFormFeed(printer);
}

/**************************************************************************
 *                                                                        *
 * Report car types                                                       *
 *                                                                        *
 **************************************************************************/

void System::ReportCarTypes(CarTypeReport rtype, char carType,
				      PrinterDevice          *printer,
				char **outmessage) const
{
	switch (rtype) {
	  case All:
	    PrintCarTypesHeader(printer);
	    PrintDashedLine(printer);
	    PrintAllCarTypes(false,printer);
	    break;
	  case Type: {
	    CarTypeMap::const_iterator Ct = carTypes.find(carType);
	    if (Ct == carTypes.end()) break;
	    const CarType *ct = Ct->second;
	    PrintCarTypesHeader(printer);
	    PrintDashedLine(printer);
	    printer->PutLine();
	    char ctemp[2];
	    ctemp[0] = carType;
	    ctemp[1] = '\0';
	    printer->Put(ctemp);
	    printer->Tab(6);
	    printer->Put(ct->Type());
	    printer->Tab(40);
	    printer->Put(ct->Comment());
	    printer->Tab(110);
	    printer->Put(_("Moves"));
	    printer->Tab(120);
	    printer->PutLine(_("Assigns"));
	    printer->PutLine();

	    int dumm1,dummy2,dummy3,dummy4,dummy5,dummy6;
	    
	    PrintOneCarType(false,carType,ct,dumm1,dummy2,dummy3,dummy4,dummy5,
			    dummy6,printer);

	    PrintFormFeed(printer);
	    break;
	  }
	  case Summary:
	    PrintCarTypesSummaryHeader(printer);
	    PrintAllCarTypes(true,printer);
	    break;
	}
}

/**************************************************************************
 *                                                                        *
 * Print car types header                                                 *
 *                                                                        *
 **************************************************************************/

void System::PrintCarTypesHeader(PrinterDevice *printer) const
{
    PrintSystemBanner(printer);
    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(12);
    printer->PutLine(_("CAR TYPE Report"));
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeWeight(PrinterDevice::Normal);
}

/**************************************************************************
 *                                                                        *
 * Print all car types                                                    *
 *                                                                        *
 **************************************************************************/

void System::PrintAllCarTypes(bool totalsOnly,PrinterDevice *printer) const
{
	int Group,Gx,typeTotal = 0;
	bool groupFound;
	char groupCode, cto;
	const CarGroup *carGroup;
	const CarType *carType;
	CarTypeMap::const_iterator Ct;
	int OnLineShippersOfType, OffLineShippersOfType,
	    OnLineReceiversOfType, OffLineReceiversOfType;
	int allTotalMoves, allTotalAssigns;
	double tripsPerSession;
	char buffer[64];
	char ctemp[2];


	allTotalMoves = 0;
	allTotalAssigns = 0;
	for (Group = 0; Group < CarGroup::MaxCarGroup; Group++) {
	  groupFound = false;
	  carGroup = carGroups[Group];
	  if (carGroup != NULL && (groupCode = carGroup->Group()) != '\0') {
	    for (Gx = 0; Gx < CarType::MaxCarTypes; Gx++) {
	      cto = carTypesOrder[Gx];
	      if (cto == '\0' || cto == ',') continue;
	      Ct = carTypes.find(cto);
	      if (Ct->second == NULL) continue;
	      carType = Ct->second;
	      if (carType->Group() != groupCode) continue;
	      typeTotal++;
	      if (typeTotal == 52 && totalsOnly) {
	      	PrintFormFeed(printer);
	      	PrintCarTypesSummaryHeader(printer);
	      }
	      if (!totalsOnly) printer->PutLine();
	      ctemp[0] = cto;
	      ctemp[1] = '\0';
	      printer->Put(ctemp);
	      printer->Tab(6);
	      printer->Put(carType->Type());
	      printer->Tab(40);
	      if (!totalsOnly) {
	      	printer->Put(carType->Comment());
		printer->Tab(110);
		printer->Put(_("Moves"));
		printer->Tab(120);
		printer->PutLine(_("Assigns"));
		printer->PutLine();
	      }
	      if (totalsOnly) {
	      	IndustryMap::const_iterator Ix;
	      	const Industry *ix;
	      	char typeSymbol;
	      	OnLineShippersOfType = 0;
		OffLineShippersOfType = 0;
		OnLineReceiversOfType = 0;
		OffLineReceiversOfType = 0;

		for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
		  if (Ix->second == NULL) continue;
		  if (Ix->first  == 0) continue;
		  typeSymbol = cto;
		  ix = Ix->second;
		  if (ix->loadTypes.find(typeSymbol) != string::npos) {
		    if (ix->Type() == 'I') OnLineReceiversOfType++;
		    if (ix->Type() == 'O') OffLineReceiversOfType++;
		  }
		  if (ix->emptyTypes.find(typeSymbol) != string::npos) {
		    if (ix->Type() == 'I') OnLineShippersOfType++;
		    if (ix->Type() == 'O') OffLineShippersOfType++;
		  }
		}
	      }
	      PrintOneCarType(totalsOnly,cto,carType,OnLineShippersOfType,
			      OffLineShippersOfType,
			      OnLineReceiversOfType,
			      OffLineReceiversOfType,
			      allTotalMoves,
			      allTotalAssigns,printer);
	    }	    
	  }
	}

	printer->PutLine();

	PrintDashedLine(printer);

	printer->PutLine();

	printer->Tab(10);
	printer->Put(_("Total cars = ")); printer->Put((int)cars.size());

	tripsPerSession = ((double)allTotalMoves) / ((double) sessionNumber);

	printer->Tab(40);
	printer->Put(_("Total Moces/Session = ")); printer->Put(tripsPerSession);
	printer->Tab(80);

	tripsPerSession = tripsPerSession / ((double) cars.size());
	sprintf(buffer,_("Avg Moves/Session = %5.2f"),tripsPerSession);
	printer->PutLine(buffer);

	PrintFormFeed(printer);
}

/**************************************************************************
 *                                                                        *
 * Print one car type                                                     *
 *                                                                        *
 **************************************************************************/

void System::PrintOneCarType(bool totalsOnly,char carType,const CarType *ct,
			     int &OnLineShippersOfType,
			     int &OffLineShippersOfType,
			     int &OnLineReceiversOfType,
			     int &OffLineReceiversOfType,
			     int &allTotalMoves,
			     int &allTotalAssigns,
			     PrinterDevice *printer) const
{
	int carsOfType, totalMoves, totalAssigns;
	CarVector::const_iterator Cx;
	const Car *car;
	string status, carTypeDescr;
	double tripsPerSession;
	char buffer[8];

	if (carType == ',') return;

	carsOfType = 0;
	totalMoves = 0;
	totalAssigns = 0;

	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	  if (*Cx == NULL) continue;
	  car = *Cx;
	  if (car->Type() != carType) continue;
	  carsOfType++;
	  totalMoves += car->Trips();
	  allTotalMoves += car->Trips();
	  totalAssigns += car->Assignments();
	  allTotalAssigns += car->Assignments();
	  GetCarStatus(car,status,carTypeDescr);
	  if (!totalsOnly) {
	    printer->Tab(8);
	    printer->Put(car->Marks());
	    printer->Tab(20);
	    printer->Put(car->Number());
	    printer->Tab(30);
	    printer->Put(car->Length()); printer->Put("ft");
	    printer->Tab(40);
	    printer->Put(status);
	    printer->Tab(50);
	    printer->Put(_("at ")); printer->Put(car->Location()->Name());
	    printer->Tab(78);
	    printer->Put(_("dest ")); printer->Put(car->Destination()->Name());
	    printer->Tab(110);
	    printer->Put(car->Trips());
	    printer->Tab(120);
	    printer->Put(car->Assignments()); printer->PutLine();
	  }
	}
	if (carsOfType > 0 && !totalsOnly) printer->PutLine();
	if (!totalsOnly) {
	  printer->Tab(8);
	  printer->Put(_("Cars of type: "));
	  printer->Tab(30);
	  printer->Put(ct->Type());
	  printer->Tab(64);
	  printer->Put(" = "); printer->Put(carsOfType); printer->PutLine();
	} else {
	  if (carsOfType > 0) {
	    tripsPerSession = ((double)totalMoves) / ((double)sessionNumber);
	    tripsPerSession /= ((double)carsOfType);
	  } else {
	    tripsPerSession = 0;
	  }
	  printer->Tab(40);
	  printer->Put(carsOfType);
	  printer->Tab(50);
	  printer->Put(OnLineShippersOfType);
	  printer->Tab(60);
	  printer->Put(OffLineShippersOfType);
	  printer->Tab(70);
	  printer->Put(OnLineReceiversOfType);
	  printer->Tab(80);
	  printer->Put(OffLineReceiversOfType);
	  printer->Tab(90);
	  sprintf(buffer,"%5.2f",tripsPerSession);
	  printer->Put(buffer);
	  printer->Tab(102);
	  printer->PutLine(ct->comment.substr(0,34));
	}
}

/**************************************************************************
 *                                                                        *
 * Print car type summary                                                 *
 *                                                                        *
 **************************************************************************/

void System::PrintCarTypesSummaryHeader(PrinterDevice *printer) const
{
	PrintCarTypesHeader(printer);

	printer->Tab(40);
	printer->Put(_("Total"));
	printer->Tab(50);
	printer->Put(_("Shippers --------"));
	printer->Tab(70);
	printer->Put(_("Receivers -------"));
	printer->Tab(90);
	printer->Put(_("Moves"));
	printer->Tab(102);
	printer->PutLine(_("Car Type"));

	printer->Tab(6);
	printer->Put(_("Type"));
	printer->Tab(40);
	printer->Put(_("of Type"));
	printer->Tab(50);
	printer->Put(_("Online"));
	printer->Tab(60);
	printer->Put(_("Offline"));
	printer->Tab(70);
	printer->Put(_("Online"));
	printer->Tab(80);
	printer->Put(_("Offline"));
	printer->Tab(90);
	printer->Put(_("Per Session"));
	printer->Tab(102);
	printer->PutLine(_("Comments"));

	PrintDashedLine(printer);
}

/**************************************************************************
 *                                                                        *
 * Report car locations						          *
 *                                                                        *
 **************************************************************************/

void System::ReportCarLocations(CarLocationType cltype, int index,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage)
{
	switch (cltype) {
	  case INDUSTRY: ReportLocIndustry(industries.find(index),Log,printer,outmessage); break;
	  case STATION:  ReportLocStation(stations.find(index),Log,printer,outmessage); break;
	  case DIVISION: ReportLocDivision(divisions.find(index),Log,printer,outmessage); break;
	  case ALL:	 ReportLocAll(index != 0,Log,printer,outmessage); break;
	}
}

/**************************************************************************
 *                                                                        *
 * Report locations by industry                                           *
 *                                                                        *
 **************************************************************************/

void System::ReportLocIndustry(IndustryMap::const_iterator Ix,
			       const LogMessageCallback     *Log,
			             PrinterDevice          *printer,
			       char **outmessage)
{
	const Industry *ix;
	const Station *Sx;
	string name;
	static char message[256];
	bool firstOne;
	if (Ix == industries.end()) return;
	ix = Ix->second;
	Sx = ix->MyStation();
	if (Sx == NULL) return;
	name = ix->Name();
	if (name.size() == 0) return;
	sprintf(message,_("Print all cars at %s\n"),name.c_str());
	Log->LogMessage(LogMessageCallback::Infomational,message);
	firstOne = true;
	PrintLocCommon(printer);
	PrintLocOneIndustry(ix,Sx,firstOne,printer);
	PrintFormFeed(printer);
}

/**************************************************************************
 *                                                                        *
 * Report locations by station                                            *
 *                                                                        *
 **************************************************************************/

void System::ReportLocStation(StationMap::const_iterator Sx,
			       const LogMessageCallback     *Log,
			             PrinterDevice          *printer,
			       char **outmessage)
{
	IndustryVector::const_iterator Ix;
	const Industry *ix;
	const Station *sx;
	string name;
	static char message[256];
	bool firstOne;

	if (Sx == stations.end()) return;
	if ((sx = Sx->second) == NULL) return;
	name = sx->Name();
	if (name.size() == 0) return;
	sprintf(message,_("Print all cars at %s\n"),name.c_str());
	Log->LogMessage(LogMessageCallback::Infomational,message);
	PrintLocCommon(printer);
	firstOne = true;

	for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
	  if ((ix = *Ix) == NULL) continue;
	  PrintLocOneIndustry(ix,sx,firstOne,printer);
	}
	PrintFormFeed(printer);
}

/**************************************************************************
 *                                                                        *
 * Report locations by division                                           *
 *                                                                        *
 **************************************************************************/

void System::ReportLocDivision(DivisionMap::const_iterator Dx,
			       const LogMessageCallback     *Log,
			             PrinterDevice          *printer,
			       char **outmessage)
{
	const Division *dx;
	IndustryVector::const_iterator Ix;
	const Industry *ix;
	StationVector::const_iterator Sx;
	const Station *sx;
	string name;
	static char message[256];
	bool firstOne;

	if (Dx == divisions.end()) return;
	if ((dx = Dx->second) == NULL) return;
	name = dx->Name();
	if (name.size() == 0) return;
	PrintLocCommon(printer);

	for (Sx = dx->stations.begin(); Sx != dx->stations.end(); Sx++) {
	  if ((sx = *Sx) == NULL) continue;
	  sprintf(message,_("Print all cars at %s\n"),sx->Name());
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  firstOne = true;
	  for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
	    if ((ix = *Ix) == NULL) continue;
	    PrintLocOneIndustry(ix,sx,firstOne,printer);
	  }
	}
	PrintFormFeed(printer);
}

/**************************************************************************
 *                                                                        *
 * Report all locations                                                   *
 *                                                                        *
 **************************************************************************/

void System::ReportLocAll(bool printBench,
			  const LogMessageCallback     *Log,
			        PrinterDevice          *printer,
			       char **outmessage)
{
	IndustryVector::const_iterator Ix;
	const Industry *ix;
	StationMap::const_iterator Sx;
	const Station *sx;
	string name;
	static char message[256];
	bool firstOne;
	int forStart;

	if (printBench) forStart = 1;
	else forStart = 2;

	PrintLocCommon(printer);

	for (Sx = stations.find(forStart); Sx != stations.end(); Sx++) {
	  if ((sx = Sx->second) == NULL) continue;
	  sprintf(message,_("Print all cars at %s\n"),sx->Name());
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  firstOne = true;
	  for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
	    if ((ix = *Ix) == NULL) continue;
	    PrintLocOneIndustry(ix,sx,firstOne,printer);
	  }
	}
	PrintFormFeed(printer);
}

/**************************************************************************
 *                                                                        *
 * Print common location information                                      *
 *                                                                        *
 **************************************************************************/

void System::PrintLocCommon(PrinterDevice          *printer)
{
    GetIndustryCarCounts();
    
    PrintSystemBanner(printer);
    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(10);
    printer->PutLine(_("CAR LOCATION Report"));
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeWeight(PrinterDevice::Normal);
    printer->SetTypeSpacing(PrinterDevice::One);
}

/**************************************************************************
 *                                                                        *
 * Print location for one industry                                        *
 *                                                                        *
 **************************************************************************/

void System::PrintLocOneIndustry(const Industry *Ix,const Station *Sx,
				 bool &firstOne,PrinterDevice *printer) const
{
	CarVector::const_iterator Cx;
	const Car *car;
	int carsAtIndustry;
	char buffer[64];

	if (Ix->MyStation() != Sx) return;

	carsAtIndustry = Ix->cars.size();

	if (firstOne) {
	  PrintDashedLine(printer);
	  firstOne = false;
	  printer->Put(Sx->Name());
	}

	printer->Tab(27);
	printer->Put(Ix->Name());
	printer->Tab(52);
	sprintf(buffer,"<%d> (%d/%d)",FindIndustryIndex(Ix),Ix->usedLen,
		Ix->TrackLen());
	printer->Put(buffer);
	printer->Tab(77);
	printer->Put("Total cars");
	printer->Tab(97);
	printer->Put(carsAtIndustry); printer->PutLine();

	if (printYards || Ix->Type() != 'Y') {
	  if (carsAtIndustry > 0) {
	    printer->PutLine();
	    for (Cx = Ix->cars.begin(); Cx != Ix->cars.end(); Cx++) {
	      if ((car = *Cx) == NULL) continue;
	      PrintOneCarLocation(car,printer);
	    }
	  }
	}
	printer->PutLine();
	
}

/**************************************************************************
 *                                                                        *
 * Print one car at one location                                          *
 *                                                                        *
 **************************************************************************/

void System::PrintOneCarLocation(const Car *car,PrinterDevice *printer) const
{
	string carTypeDescr;
	CarTypeMap::const_iterator Ct;
	const CarType *ct;
	Ct = carTypes.find(car->Type());
	if (Ct == carTypes.end()) {
	  carTypeDescr = _("Unknown");
	} else {
	  ct = Ct->second;
	  carTypeDescr = ct->Type();
	}
	printer->Tab(27);
	printer->Put(car->Marks());
	printer->Tab(40);
	printer->Put(car->Number());
	printer->Tab(51);
	printer->Put(carTypeDescr);
	printer->Tab(87);
	printer->Put(car->Destination()->MyStation()->Name());
	printer->Tab(113);
	printer->Put(car->Destination()->Name());
	printer->PutLine();
}

/**************************************************************************
 *                                                                        *
 * Analysis report                                                        *
 *                                                                        *
 **************************************************************************/

void System::ReportAnalysis(const WorkInProgressCallback *WIP,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage) const
{
    int grandTotalCarsToDiv, icount, analysisIndustriesCount;
    int carsToDiv;
    DivisionMap::const_iterator Dx;
    const Division *dx;
    IndustryVector::const_iterator Ix;
    const Industry *ix;
    StationVector::const_iterator Sx;
    const Station *sx;
    string dname;
    double tenth, donePer;
    char buffer[64];
    static char message[256];
    
    PrintSystemBanner(printer);
    
    printer->PutLine();
    PrintSystemBanner(printer);
    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(6);
    printer->PutLine(_("Industry Utilization Analysis"));
    printer->SetTypeSpacing(PrinterDevice::One);
    //printer->SetTypeSpacing(PrinterDevice::Double);
    printer->SetTypeWeight(PrinterDevice::Bold);
    printer->Tab(15);
    printer->Put(_("Shifts = ")); printer->Put(statsPeriod);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeSpacing(PrinterDevice::Half);
    printer->PutLine();
    printer->PutLine();
    printer->SetTypeWeight(PrinterDevice::Normal);              
    
    PrintAnalysisHeader(printer);

    PrintDashedLine(printer);

    grandTotalCarsToDiv = 0;

    icount = 0;

    analysisIndustriesCount = 0;

    for (Dx = divisions.begin(); Dx != divisions.end(); Dx++) {
        if ((dx = Dx->second) == NULL) continue;
        if ((dname=dx->Name()).size() == 0) continue;
        for (Sx = dx->stations.begin(); Sx != dx->stations.end(); Sx++) {
	    if ((sx = *Sx) == NULL) continue;
	    analysisIndustriesCount += sx->industries.size();
        }
    }
    tenth = 100.0 / ((double)analysisIndustriesCount);
    WIP->ProgressStart(_("INDUSTRY Utilization Analysis in progress"));
    WIP->ProgressUpdate(0,_("0% Done"));
    for (Dx = divisions.begin(); Dx != divisions.end(); Dx++) {
        if ((dx = Dx->second) == NULL) continue;
        if ((dname=dx->Name()).size() == 0) continue;
        carsToDiv = 0;
        printer->PutLine();
        for (Sx = dx->stations.begin(); Sx != dx->stations.end(); Sx++) {
	    if ((sx = *Sx) == NULL) continue;
	    for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
                icount++;
                donePer = icount * tenth;
                if ((ix = *Ix) == NULL) continue;
                //sprintf(message,_("Analysis of %s: %s: %s"),dname.c_str(),sx->Name(),ix->Name());
                PrintOneAnalysis(ix,carsToDiv,Log,printer);
                sprintf(buffer,_("%f%% Done"),donePer);
                WIP->ProgressUpdate((int)donePer,buffer);
	    }
        }
        grandTotalCarsToDiv += carsToDiv;
        printer->PutLine();
        sprintf(message,_("==========  <%c> %s local industries summary --------"),dx->Symbol(),dname.c_str());
        printer->Put(message);
        printer->Tab(76);
        printer->Put(carsToDiv);
        printer->Tab(85);
        sprintf(buffer,"%7.2f",((double)carsToDiv)/((double)statsPeriod));
        printer->Put(buffer);
        printer->Tab(98);
        printer->PutLine(string('-',28));
    }
    printer->PutLine();
    printer->Put(_("==========  Grand Total all divisions  ========================"));
    printer->Tab(76);
    printer->Put(grandTotalCarsToDiv);
    printer->Tab(85);
    sprintf(buffer,"%7.2f",((double)grandTotalCarsToDiv)/((double)statsPeriod));
    printer->Put(buffer);
    printer->Tab(98);
    printer->PutLine(string('-',28));
    PrintFormFeed(printer);
    WIP->ProgressDone(_("Done"));
}

/**************************************************************************
 *                                                                        *
 * Report car owners                                                      *
 *                                                                        *
 **************************************************************************/

void System::ReportCarOwners(string ownerInitials,
			     const WorkInProgressCallback *WIP,
			     const LogMessageCallback     *Log,
				   PrinterDevice          *printer,
			     char **outmessage) const
{
    OwnerMap::const_iterator Ox;
    Owner *ox;
    int done;
    double tenth, donePer;
    CarVector::const_iterator Cx;
    const Car *car;
    int carsOwned;
    char buffer[32];
    string message;
    string ownerName = ownerInitials;
    
    Ox = owners.find(ownerInitials);
    if (Ox == owners.end()) return;
    if ((ox = Ox->second) == NULL) return;
    ownerName = ox->Name();
    carsOwned = 0;
    
    message  = _("CAR OWNER Report -- ");
    message += ownerInitials;
    message += "\n(";
    message += ownerName;
    message += ")";
    WIP->ProgressStart(message);
    tenth = 100.0 / (double)(cars.size());
    done  = 10;
    donePer = 0;
    for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
        donePer += tenth;
        if (donePer > done) {
	    sprintf(buffer,_("%f%% Done"),donePer);
	    WIP->ProgressUpdate((int)donePer,buffer);
	    done += 10;
        }
        if ((car = *Cx) == NULL) continue;
        if (car->owner == ox) {
	    carsOwned++;
	    if (carsOwned == 1) {
                PrintSystemBanner(printer);
                printer->PutLine();
                printer->SetTypeSpacing(PrinterDevice::One);
                //printer->SetTypeSpacing(PrinterDevice::Double);
                printer->SetTypeWeight(PrinterDevice::Bold);
                printer->Tab(10);
                printer->Put(_("CAR OWNER Report -- "));
                printer->Put(ownerName);
                printer->SetTypeSpacing(PrinterDevice::Half);
                printer->PutLine();
                printer->PutLine();
                printer->SetTypeWeight(PrinterDevice::Normal);
                PrintDashedLine(printer);
	    }
	    printer->Put(carsOwned);
	    printer->Tab(8);
	    printer->Put(car->Marks());
	    printer->Tab(18);
	    printer->Put(car->Number());
	    printer->Tab(28);
	    if (car->LoadedP()) printer->Put('L');
	    else printer->Put('E');
	    printer->Tab(31);
	    printer->Put(car->Length());
	    printer->Tab(37);
	    {
                string typeName;
                CarTypeMap::const_iterator Ct = carTypes.find(car->Type());
                if (Ct == carTypes.end()) typeName = _("Unknown");
                else if ((Ct->second) == NULL) typeName = _("Unknown");
                else typeName = (Ct->second)->Type();
                printer->Put(typeName);
	    }
	    printer->Tab(70);
	    printer->Put(_("at ")); printer->Put(car->Location()->Name());
	    printer->Tab(96);
	    printer->Put(_("dest ")); printer->PutLine(car->Destination()->Name());
        }
    }
    if (carsOwned > 0) PrintFormFeed(printer);
    WIP->ProgressDone(_("Done"));
}

/**************************************************************************
 *                                                                        *
 * Print analysis header                                                  *
 *                                                                        *
 **************************************************************************/

void System::PrintAnalysisHeader(PrinterDevice *printer) const
{
// Eligible  Deliv  Cars Per  TrkLen/  CarsLen/  % Track
// Cars      Cars   Shift     Shift    Shift     Use/Shift
  printer->Tab(66);
  printer->Put(_("Eligible"));
  printer->Tab(76);
  printer->Put(_("Deliv"));
  printer->Tab(86);
  printer->Put(_("Cars Per"));
  printer->Tab(96);
  printer->Put(_("TrkLen/"));
  printer->Tab(107);
  printer->Put(_("CarsLen/"));
  printer->Tab(118);
  printer->PutLine(_("% Track"));

  printer->Put("#");
  printer->Tab(5);
  printer->Put(_("City"));
  printer->Tab(37);
  printer->Put(_("Industry"));
  printer->Tab(66);
  printer->Put(_("Cars"));
  printer->Tab(76);
  printer->Put(_("Cars"));
  printer->Tab(86);
  printer->Put(_("Shift"));
  printer->Tab(96);
  printer->Put(_("Shifts"));
  printer->Tab(107);
  printer->Put(_("Shifts"));
  printer->Tab(118);
  printer->PutLine(_("Use/Shift"));
}

/**************************************************************************
 *                                                                        *
 * Print one analysis                                                     *
 *                                                                        *
 **************************************************************************/

void System::PrintOneAnalysis(const Industry *Ix,int &carsToDiv,
				const LogMessageCallback     *Log,
			      PrinterDevice *printer) const
{
	int carsAvail = 0;
	int trackLen, carsLen;
	CarVector::const_iterator Cx;
	const Car *car;
	int carsNum, period;
	double carsPerSession, percentUse;
	char buffer[64];
	static char message[256];

	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	  if ((car = *Cx) == NULL) continue;
	  if (Ix->loadTypes.find(car->Type()) != string::npos) {
	    carsAvail++;
	    continue;
	  }
	  if (Ix->emptyTypes.find(car->Type()) != string::npos) {
	    carsAvail++;
	    continue;
	  }
	}
	printer->Put(FindIndustryIndex(Ix));
	printer->Tab(5);
	printer->Put(FindStationIndex(Ix->MyStation()));
	printer->Tab(9);
	printer->Put(Ix->MyStation()->Name());
	printer->Tab(37);
	printer->Put(Ix->Name());
	printer->Tab(66);
	printer->Put(carsAvail);
	printer->Tab(76);
	printer->Put(Ix->CarsNum());
	printer->Tab(86);

	carsNum = Ix->CarsNum();
	period = statsPeriod;
	carsPerSession = ((double)carsNum) / ((double)period);

	sprintf(buffer,"%6.2f",carsPerSession);
	printer->Put(buffer);
	printer->Tab(96);
	sprintf(buffer,"%7.1f",((double)(Ix->statsLen)) / ((double)statsPeriod));
	printer->Put(buffer);   
	printer->Tab(107);
	sprintf(buffer,"%7.1f",((double)(Ix->CarsLen())) / ((double)statsPeriod));
	printer->Put(buffer);
	printer->Tab(118);

	carsLen = Ix->CarsLen();
	trackLen = Ix->TrackLen();

	if (trackLen > 0) {
	  percentUse = ((double)carsLen) / ((double) trackLen);
	} else {
	  sprintf(message,_("Track length = 0 for %s\n"),Ix->Name());
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  percentUse = 0;
	}

	sprintf(buffer,"%6.2f",percentUse * 100.0);
	printer->PutLine(buffer);

	if (Ix->Type() == 'Y') carsToDiv += Ix->cars.size();
}


}
