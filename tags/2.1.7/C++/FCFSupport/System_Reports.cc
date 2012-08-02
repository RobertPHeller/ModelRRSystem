/* 
 * ------------------------------------------------------------------
 * System_Reports.cc - Report Generation functions
 * Created by Robert Heller on Sat Oct 15 10:25:01 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

#include <System.h>

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
	string divisionName, message;
	char buffer[64];
	
	PrintSystemBanner(printer);
	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(10);
	printer->PutLine("INDUSTRY Report");
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->PutLine();

	PrintIndustryHeader(printer);

	PrintDashedLine(printer);

	WIP->ProgressStart("Industry Report In Progress...");
	tenth = 10.0 / (double)(divisions.size());
	donePer = 0.0;
	WIP->ProgressUpdate(0,"0% Done");
	for (Dx = divisions.begin(); Dx != divisions.end(); Dx++) {
	  donePer += tenth*10.0;
	  sprintf(buffer,"%6.2f%% Done",donePer);
	  WIP->ProgressUpdate((int)donePer,buffer);
	  if ((Dx->second) == NULL) continue;
	  dx = Dx->second;
	  divisionName = dx->Name();
	  if (divisionName.size() == 0) continue;
	  message = "Division: ";
	  message += divisionName;
	  message += "\n";
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  carsToDiv = 0;
	  carsInDiv = 0;
	  lenInDiv  = 0;
	  for (Sx = dx->stations.begin(); Sx != dx->stations.end(); Sx++) {
	    if (*Sx == NULL) continue;
	    sx = *Sx;
	    for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
	      if (*Ix == NULL) continue;
	      ix = *Ix;
	      PrintOneIndustry(ix,lenInDiv,carsInDiv,carsToDiv,Log,printer);
	    }
	  }
	  printer->PutLine();
	  printer->Put("Totals for <"); printer->Put(dx->Symbol()); printer->Put("> "); printer->Put(dx->Name());
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
	WIP->ProgressDone("Done");
	PrintFormFeed(printer);
}

void System::PrintIndustryHeader(PrinterDevice *printer) const
{
  printer->Put("#");
  printer->Tab(5);
  printer->Put("City");
  printer->Tab(37);
  printer->Put("Industry");
  printer->Tab(66);
  printer->Put("Trk Len");
  printer->Tab(76);
  printer->Put("Cur Len");
  printer->Tab(86);
  printer->Put("Asn Len");
  printer->Tab(96);
  printer->Put("Cars Now");
  printer->Tab(106);
  printer->Put("Cars Dst");
  printer->Tab(116);
  printer->Put("Lds Avail");
  printer->Tab(128);
  printer->PutLine("Emp Avail");
}

void System::PrintOneIndustry(const Industry *ix,
			      int &lenInDiv,int &carsInDiv, int &carsToDiv,
			      const LogMessageCallback     *Log,
				    PrinterDevice          *printer) const
{
	string message;
	int ldsAvail, emtAvail, carsTo, carsIn, indLen;
	CarVector::const_iterator Cx;
	const Car *car;

	message  = "  Industry: ";
	message += ix->Name();
	message += "\n";

	carsTo = 0;
	carsIn = 0;
	indLen = 0;

	ldsAvail = 0;
	emtAvail = 0;

	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	  if (*Cx == NULL) continue;
	  car = *Cx;
	  if (ix == car->Destination()) carsTo++;
	  if (ix == car->Location()) {
	    carsIn++;
	    indLen += car->Length();
	  }
	  if (ix->loadTypes.find(car->Type()) != string::npos) ldsAvail++;
	  if (ix->emptyTypes.find(car->Type()) != string::npos) emtAvail++;
	}

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
               
void System::ReportTrains(const WorkInProgressCallback *WIP,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage) const
{
	double tenth, donePer;
	TrainMap::const_iterator Tx;
	const Train *tx;
	string message;
	char buffer[64];

	PrintSystemBanner(printer);

	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(10);
	printer->PutLine("TRAINS Report");
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->PutLine();

	PrintDashedLine(printer);

	WIP->ProgressStart("TRAINS Report In Progress...");
	tenth = 10.0 / (double)(trains.size());
	donePer = 0.0;
	WIP->ProgressUpdate(0,"0% Done");

	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
	  donePer += tenth*10;
	  sprintf(buffer,"%6.2f%% Done",donePer);
	  WIP->ProgressUpdate((int)donePer,buffer);
	  if ((Tx->second) == NULL) continue;
	  tx = Tx->second;
	  message  = tx->Name();
	  message += "\n";
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  printer->PutLine();
	  printer->SetTypeSpacing(PrinterDevice::One);
	  printer->SetTypeSpacing(PrinterDevice::Double);
	  printer->PutLine(tx->Name());
	  PrintTrainOrders(tx,printer);	  
	}
	WIP->ProgressDone("Done");
	PrintFormFeed(printer);
	
}	

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

	PrintSystemBanner(printer);

	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(10);
	printer->PutLine("CARS Report");
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->PutLine();

	totLines = 4;

	PrintCarHeading(printer);

	WIP->ProgressStart("CARS Report In Progress (Cars IN Service) ...");
	WIP->ProgressUpdate(0,"0% Done");
	tenth = 100.0 / (double)(cars.size());
	done=10;
	donePer = 0.0;
	for (Cx = cars.begin(); Cx != cars.end(); Cx++) {
	  donePer += tenth;
	  if (donePer > done) {
	    sprintf(buffer,"%f%% Done",donePer);
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
	totLines = 55;

	ncOnB = IndRipTrackConst()->cars.size();
	if (ncOnB == 0) {
	  WIP->ProgressDone("Done");
	  PrintFormFeed(printer);
	  return;
	}
	tenth = 100.0 / ((double)ncOnB);
	donePer = 0.0;
	done = 10;
	WIP->ProgressStart("CARS Report In Progress (Cars on workbench) ...");
	WIP->ProgressUpdate(0,"0% Done");
	for (Cx = IndRipTrackConst()->cars.begin(); Cx != IndRipTrackConst()->cars.end(); Cx++) {
	  donePer += tenth;
	  if (donePer > done) {
	    sprintf(buffer,"%f%% Done",donePer);
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
	WIP->ProgressDone("Done");
	PrintFormFeed(printer);
}

void System::PrintCarHeading(PrinterDevice *printer) const
{
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->Put("RR");
	printer->Tab(11);
	printer->Put("NUMBER");
	printer->Tab(20);
	printer->Put("LEN");
	printer->Tab(25);
	printer->Put("CAR TYPE");
	printer->Tab(56);
	printer->Put("L/E");
	printer->Tab(60);
	printer->Put("CUR STATION");
	printer->Tab(84);
	printer->Put("LOCATION");
	printer->Tab(110);
	printer->PutLine("DEST INDUSTRY");
	PrintDashedLine(printer);
}

void System::PrintOneCarInfo(const Car *car,PrinterDevice *printer) const
{
	CarTypeMap::const_iterator Ct;
	printer->Put(car->Marks());
	printer->Tab(11);
	printer->Put(car->Number());
	printer->Tab(20);
	printer->Put(car->Length());
	printer->Tab(25);
	Ct = carTypes.find(car->Type());
	if (Ct != carTypes.end() && (Ct->second) != NULL) {
		printer->Put((Ct->second)->Type());
	}
	printer->Tab(56);
	if (car->LoadedP()) printer->Put('L');
	else printer->Put('E');
	printer->Tab(60);
	printer->Put(car->Location()->MyStation()->Name());
	printer->Tab(84);
	printer->Put(car->Location()->Name());
	printer->Tab(110);
	printer->PutLine(car->Destination()->Name());
}


void System::ReportCarsNotMoved(const WorkInProgressCallback *WIP,
				const LogMessageCallback     *Log,
				      PrinterDevice          *printer,
				char **outmessage) const
{
	double tenth, donePer;
	int done, totLines,ncOnB;
	CarVector::const_iterator Cx;
	const Car *car;
	IndustryMap::const_iterator Ix;
	const Industry *ix;
	char buffer[64];

	PrintSystemBanner(printer);

	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(10);
	printer->PutLine("CARS NOT MOVED Report");
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->PutLine();

	totLines = 4;

	PrintCarHeading(printer);

	WIP->ProgressStart("CARS NOT MOVED Report In Progress ...");
	WIP->ProgressUpdate(0,"0% Done");
	tenth = 100.0 / (double)(industries.size());
	done=10;
	donePer = 0.0;
	for (Ix = industries.begin(); Ix != industries.end(); Ix++) {
	  donePer += tenth;
	  if (donePer > done) {
	    sprintf(buffer,"%f%% Done",donePer);
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
	WIP->ProgressDone("Done");
	PrintFormFeed(printer);
}

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
	    printer->Put(carType);
	    printer->Tab(6);
	    printer->Put(ct->Type());
	    printer->Tab(40);
	    printer->Put(ct->Comment());
	    printer->Tab(110);
	    printer->Put("Moves");
	    printer->Tab(120);
	    printer->PutLine("Assigns");
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

void System::PrintCarTypesHeader(PrinterDevice *printer) const
{
	PrintSystemBanner(printer);
	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(12);
	printer->PutLine("CAR TYPE Report");
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->PutLine();
}

void System::PrintAllCarTypes(bool totalsOnly,PrinterDevice *printer) const
{
	int Group,Gx,typeTotal;
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
	      printer->Put(cto);
	      printer->Tab(6);
	      printer->Put(carType->Type());
	      printer->Tab(40);
	      if (!totalsOnly) {
	      	printer->Put(carType->Comment());
		printer->Tab(110);
		printer->Put("Moves");
		printer->Tab(120);
		printer->PutLine("Assigns");
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
	printer->Put("Total cars = "); printer->Put((int)cars.size());

	tripsPerSession = ((double)allTotalMoves) / ((double) sessionNumber);

	printer->Tab(40);
	printer->Put("Total Moces/Session = "); printer->Put(tripsPerSession);
	printer->Tab(80);

	tripsPerSession = tripsPerSession / ((double) cars.size());
	sprintf(buffer,"Avg Moves/Session = %5.2f",tripsPerSession);
	printer->PutLine(buffer);

	PrintFormFeed(printer);
}

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
	    printer->Put("at "); printer->Put(car->Location()->Name());
	    printer->Tab(78);
	    printer->Put("dest "); printer->Put(car->Destination()->Name());
	    printer->Tab(110);
	    printer->Put(car->Trips());
	    printer->Tab(120);
	    printer->Put(car->Assignments()); printer->PutLine();
	  }
	}
	if (carsOfType > 0 && !totalsOnly) printer->PutLine();
	if (!totalsOnly) {
	  printer->Tab(8);
	  printer->Put("Cars of type: ");
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

void System::PrintCarTypesSummaryHeader(PrinterDevice *printer) const
{
	PrintCarTypesHeader(printer);

	printer->Tab(40);
	printer->Put("Total");
	printer->Tab(50);
	printer->Put("Shippers --------");
	printer->Tab(70);
	printer->Put("Receivers -------");
	printer->Tab(90);
	printer->Put("Moves");
	printer->Tab(102);
	printer->PutLine("Car Type");

	printer->Tab(6);
	printer->Put("Type");
	printer->Tab(40);
	printer->Put("of Type");
	printer->Tab(50);
	printer->Put("Online");
	printer->Tab(60);
	printer->Put("Offline");
	printer->Tab(70);
	printer->Put("Online");
	printer->Tab(80);
	printer->Put("Offline");
	printer->Tab(90);
	printer->Put("Per Session");
	printer->Tab(102);
	printer->PutLine("Comments");

	PrintDashedLine(printer);
}

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

void System::ReportLocIndustry(IndustryMap::const_iterator Ix,
			       const LogMessageCallback     *Log,
			             PrinterDevice          *printer,
			       char **outmessage)
{
	const Industry *ix;
	const Station *Sx;
	string name, message;
	bool firstOne;
	if (Ix == industries.end()) return;
	ix = Ix->second;
	Sx = ix->MyStation();
	if (Sx == NULL) return;
	name = ix->Name();
	if (name.size() == 0) return;
	message  = "Print all cars at ";
	message += name;
	message += "\n";
	Log->LogMessage(LogMessageCallback::Infomational,message);
	firstOne = true;
	PrintLocCommon(printer);
	PrintLocOneIndustry(ix,Sx,firstOne,printer);
	PrintFormFeed(printer);
}

void System::ReportLocStation(StationMap::const_iterator Sx,
			       const LogMessageCallback     *Log,
			             PrinterDevice          *printer,
			       char **outmessage)
{
	IndustryVector::const_iterator Ix;
	const Industry *ix;
	const Station *sx;
	string name, message;
	bool firstOne;

	if (Sx == stations.end()) return;
	if ((sx = Sx->second) == NULL) return;
	name = sx->Name();
	if (name.size() == 0) return;
	message  = "Print all cars at ";
	message += name;
	message += "\n";
	Log->LogMessage(LogMessageCallback::Infomational,message);
	PrintLocCommon(printer);
	firstOne = true;

	for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
	  if ((ix = *Ix) == NULL) continue;
	  PrintLocOneIndustry(ix,sx,firstOne,printer);
	}
	PrintFormFeed(printer);
}

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
	string name, message;
	bool firstOne;

	if (Dx == divisions.end()) return;
	if ((dx = Dx->second) == NULL) return;
	name = dx->Name();
	if (name.size() == 0) return;
	PrintLocCommon(printer);

	for (Sx = dx->stations.begin(); Sx != dx->stations.end(); Sx++) {
	  if ((sx = *Sx) == NULL) continue;
	  message  = "Print all cars at ";
	  message += sx->Name();
	  message += "\n";
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  firstOne = true;
	  for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
	    if ((ix = *Ix) == NULL) continue;
	    PrintLocOneIndustry(ix,sx,firstOne,printer);
	  }
	}
	PrintFormFeed(printer);
}

void System::ReportLocAll(bool printBench,
			  const LogMessageCallback     *Log,
			        PrinterDevice          *printer,
			       char **outmessage)
{
	IndustryVector::const_iterator Ix;
	const Industry *ix;
	StationMap::const_iterator Sx;
	const Station *sx;
	string name, message;
	bool firstOne;
	int forStart;

	if (printBench) forStart = 1;
	else forStart = 2;

	PrintLocCommon(printer);

	for (Sx = stations.find(forStart); Sx != stations.end(); Sx++) {
	  if ((sx = Sx->second) == NULL) continue;
	  message  = "Print all cars at ";
	  message += sx->Name();
	  message += "\n";
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  firstOne = true;
	  for (Ix = sx->industries.begin(); Ix != sx->industries.end(); Ix++) {
	    if ((ix = *Ix) == NULL) continue;
	    PrintLocOneIndustry(ix,sx,firstOne,printer);
	  }
	}
	PrintFormFeed(printer);
}

void System::PrintLocCommon(PrinterDevice          *printer)
{
	GetIndustryCarCounts();

	PrintSystemBanner(printer);
	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(10);
	printer->PutLine("CAR LOCATION Report");
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->PutLine();
}

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

void System::PrintOneCarLocation(const Car *car,PrinterDevice *printer) const
{
	string carTypeDescr;
	CarTypeMap::const_iterator Ct;
	const CarType *ct;
	Ct = carTypes.find(car->Type());
	if (Ct == carTypes.end()) {
	  carTypeDescr = "Unknown";
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
	string message;
	
	PrintSystemBanner(printer);

	printer->PutLine();
	PrintSystemBanner(printer);
	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(6);
	printer->PutLine("Industry Utilization Analysis");
	printer->SetTypeSpacing(PrinterDevice::One);
	printer->SetTypeSpacing(PrinterDevice::Double);
	printer->Tab(15);
	printer->Put("Shifts = "); printer->Put(statsPeriod);
	printer->PutLine();
	printer->PutLine();
	printer->SetTypeSpacing(PrinterDevice::Half);
	printer->PutLine();
	printer->PutLine();

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
	WIP->ProgressStart("INDUSTRY Utilization Analysis in progress");
	WIP->ProgressUpdate(0,"0% Done");
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
	      message  = "Analysis of ";
	      message += dname;
	      message += ":";
	      message += sx->Name();
	      message += ":";
	      message += ix->Name();
	      PrintOneAnalysys(ix,carsToDiv,Log,printer);
	      sprintf(buffer,"%f%% Done",donePer);
	      WIP->ProgressUpdate((int)donePer,buffer);
	    }
	  }
	  grandTotalCarsToDiv += carsToDiv;
	  printer->PutLine();
	  printer->Put("==========  <"); printer->Put(dx->Symbol());
	  	       printer->Put("> "); printer->Put(dname);
		       printer->Put(" local industries summary --------");
	  printer->Tab(76);
	  printer->Put(carsToDiv);
	  printer->Tab(85);
	  sprintf(buffer,"%7.2f",((double)carsToDiv)/((double)statsPeriod));
	  printer->Put(buffer);
	  printer->Tab(98);
	  printer->PutLine(string('-',28));
	}
	printer->PutLine();
	printer->Put("==========  Grand Total all divisions  ========================");
	printer->Tab(76);
	printer->Put(grandTotalCarsToDiv);
	printer->Tab(85);
	sprintf(buffer,"%7.2f",((double)grandTotalCarsToDiv)/((double)statsPeriod));
	printer->Put(buffer);
	printer->Tab(98);
	printer->PutLine(string('-',28));
	PrintFormFeed(printer);
	WIP->ProgressDone("Done");
}

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

	message  = "CAR OWNER Report -- ";
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
	    sprintf(buffer,"%f%% Done",donePer);
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
	      printer->SetTypeSpacing(PrinterDevice::Double);
	      printer->Tab(10);
	      printer->Put("CAR OWNER Report -- ");
	      printer->Put(ownerName);
	      printer->SetTypeSpacing(PrinterDevice::Half);
	      printer->PutLine();
	      printer->PutLine();
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
	      if (Ct == carTypes.end()) typeName = "Unknown";
	      else if ((Ct->second) == NULL) typeName = "Unknown";
	      else typeName = (Ct->second)->Type();
	      printer->Put(typeName);
	    }
	    printer->Tab(70);
	    printer->Put("at "); printer->Put(car->Location()->Name());
	    printer->Tab(96);
	    printer->Put("dest "); printer->PutLine(car->Destination()->Name());
	  }
	}
	if (carsOwned > 0) PrintFormFeed(printer);
	WIP->ProgressDone("Done");
}

void System::PrintAnalysisHeader(PrinterDevice *printer) const
{
// Eligible  Deliv  Cars Per  TrkLen/  CarsLen/  % Track
// Cars      Cars   Shift     Shift    Shift     Use/Shift
  printer->Tab(66);
  printer->Put("Eligible");
  printer->Tab(76);
  printer->Put("Deliv");
  printer->Tab(86);
  printer->Put("Cars Per");
  printer->Tab(96);
  printer->Put("TrkLen/");
  printer->Tab(107);
  printer->Put("CarsLen/");
  printer->Tab(118);
  printer->PutLine("% Track");

  printer->Put("#");
  printer->Tab(5);
  printer->Put("City");
  printer->Tab(37);
  printer->Put("Industry");
  printer->Tab(66);
  printer->Put("Cars");
  printer->Tab(76);
  printer->Put("Cars");
  printer->Tab(86);
  printer->Put("Shift");
  printer->Tab(96);
  printer->Put("Shifts");
  printer->Tab(107);
  printer->Put("Shifts");
  printer->Tab(118);
  printer->PutLine("Use/Shift");
}

void System::PrintOneAnalysys(const Industry *Ix,int &carsToDiv,
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
	string message;

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
	  message  = "Track length = 0 for ";
	  message += Ix->Name();
	  message += "\n";
	  Log->LogMessage(LogMessageCallback::Infomational,message);
	  percentUse = 0;
	}

	sprintf(buffer,"%6.2f",percentUse * 100.0);
	printer->PutLine(buffer);

	if (Ix->Type() == 'Y') carsToDiv += Ix->cars.size();
}


