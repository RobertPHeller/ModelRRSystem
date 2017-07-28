/* 
 * ------------------------------------------------------------------
 * TimeTableSystem.cc - Time Table System class implememntation.
 * Created by Robert Heller on Tue Dec 20 00:34:14 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/09/03 14:39:28  heller
 * Modification History: Rev 2.1.9 Lockdown
 * Modification History:
 * Modification History: Revision 1.4  2007/05/06 12:49:38  heller
 * Modification History: Lock down  for 2.1.8 release candidate 1
 * Modification History:
 * Modification History: Revision 1.3  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2006/05/16 19:27:46  heller
 * Modification History: May162006 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
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
#include <TimeTableSystem.h>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <math.h>
#include "../gettext.h"

using namespace TTSupport;

/**********************************************************************
 * Constructor that initializes a TimeTableSystem from a file.        *
 * Read all of the time table information from a disk file and        *
 * initialize the instance from the data in the file.                 *
 **********************************************************************/

TTSupport::TimeTableSystem::TimeTableSystem(string filename,
				 char **outmessage)
{
	static char buffer[2048];	// Error message buffer.
	int count;			// Object counter.
	ifstream in;			// Input stream.

	bindmrrdomain();		// bind message catalogs

	filepath = filename;		// Save file pathname.
	in.open(filepath.FullPath().c_str()); // Open file.
	if (!in) {
		int err = errno;
		if (outmessage != NULL) {
			sprintf(buffer,_("TimeTableSystem::TimeTableSystem: Error opening file %s: %s"),filepath.FullPath().c_str(),strerror(err));
			*outmessage = new char[strlen(buffer)+1];
			strcpy(*outmessage,buffer);
		}
		return;
	}				// Read the name of the timetable.
	in.getline(buffer,sizeof(buffer)-1,'\n');
	name = buffer;
	in >> timescale >> timeinterval; // Read in time parameters.
	in >> count;			// Station count.
	while (count-- > 0) {		// Read in stations.
		Station station;
		station.Read(in);
		stations.push_back(station);
	}
	in >> count;			// Cab count.
#ifdef DEBUG
	cerr << "*** TimeTableSystem::TimeTableSystem (cabs): count = " << count << endl;
#endif
	while (count-- > 0) {		// Read in cabs.
		Cab *newcab = new Cab();
		newcab->Read(in);
		cabs[newcab->Name()] = newcab;
	}
	in >> count;			// Train count.
	while (count-- > 0) {		// Read in trains.
		Train *newtrain = new Train();
		newtrain->Read(in,cabs);
		trains[newtrain->Number()] = newtrain;
	}
	in >> count;			// Note count.
	while (count-- > 0) {		// Read in notes.
		notes.push_back(ReadNote(in));
	}
	count = 0;			
	in >> count;			// Print option count.
	while (count-- > 0) {		// Read in print options.
		string thekey = ReadNote(in);
		char *key = new char[thekey.size()+1];
		strcpy(key,thekey.c_str());
		printOptions[key] = ReadNote(in);
#ifdef DEBUG
		cerr << "*** TimeTableSystem::TimeTableSystem(): printOptions[" << key << "] = '" << printOptions[key] << "'" << endl;
#endif
	}
	in.close();			// Close file.
}

/**********************************************************************
 * Constructor that initializes a new TimeTableSystem from scratch.   *
 **********************************************************************/

TTSupport::TimeTableSystem::TimeTableSystem(string name_,int timescale_,int timeinterval_)
{
	bindmrrdomain();		// bind message catalogs
	name = name_;
	timescale = timescale_;
	timeinterval = timeinterval_;
	filepath = string("");
}

/**********************************************************************
 * Destructor: free up allocated space.				      *
 **********************************************************************/

TTSupport::TimeTableSystem::~TimeTableSystem()
{
	CabNameMap::const_iterator Cx;
	for (Cx = cabs.begin(); Cx != cabs.end(); Cx++) {
		delete Cx->second;
	}
	TrainNumberMap::const_iterator Tx;
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
		delete Tx->second;
	}
}

/**********************************************************************
 * Allocate and add a new cab to the system.  Checks for duplicate    *
 * cab names.							      *
 **********************************************************************/

TTSupport::Cab *TTSupport::TimeTableSystem::AddCab(string name, string color)
{
	Cab *newCab = FindCab(name);
	if (newCab == NULL) {
		newCab = new Cab(name,color);
		cabs[name] = newCab;
	}
	return newCab;
}

/**********************************************************************
 * Allocate and add a new train (short version).  Checks for duplicate*
 * train numbers.						      *
 **********************************************************************/

TTSupport::Train *TTSupport::TimeTableSystem::AddTrain(string name, string number,
				 int speed,int classnumber,
				 int departure,
				 int start, int end)
{
	Train *newTrain = FindTrainByNumber(number);
	if (newTrain == NULL) {
		if (end < 0) {
			end = NumberOfStations()-1;
			if (start == end) end = 0;
		}
		if (start == end) return NULL;
		newTrain = new Train(this,name,number,speed,classnumber,
					departure,start,end);
		trains[number] = newTrain;
	}
	return newTrain;
}

/**********************************************************************
 * Allocate and add a new train (long version).  Checks for duplicate *
 * train numbers. Also handles storage track assigments, with checks  *
 * conflicts.							      *
 **********************************************************************/

TTSupport::Train *TTSupport::TimeTableSystem::AddTrainLongVersion(string name, string number,
					    int speed,int classnumber,
					    int departure,int start,int end,
					    const doubleVector * layoverVector,
					    const stringVector * cabnameVector,
					    const stringVector * storageTrackVector,
					    char **outmessage)
{
	static char buffer[2048];
	unsigned int istop, i,inxt, nstops;
	double oldDepart,depart;
	double oldSmile,smile;
	double arrival;


	/*----------------------------------------------------------
	 * Duplicate train check.
	 *----------------------------------------------------------*/
	
#ifdef DEBUG
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): Duplicate train check." << endl;
#endif
	Train *newTrain = FindTrainByNumber(number);
	if (newTrain != NULL) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("Duplicate train number (%s)!"),number.c_str());
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return NULL;
	}

	/*----------------------------------------------------------
	 * Empty stop list  check.
	 *----------------------------------------------------------*/
	
#ifdef DEBUG
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): Empty stop list check." << endl;
#endif
	if (start == end) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("Train makes no stops!"));
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return NULL;
	}
		
	/*-----------------------------------------------------------
	 * Storage track occupancy check.  Traverse the train's 
	 * travel, making sure the storage tracks it will use are
	 * available.
	 *-----------------------------------------------------------*/

	oldDepart = -1;
	oldSmile =  -1;
#ifdef DEBUG
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): start = " << start << ", end = " << end << endl;
#endif
	if (start < end) {
		inxt = 1;
		nstops = (end-start)+1;
	} else {
		inxt = -1;
		nstops = (start-end)+1;
	}
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): nstops = " << nstops << ", inxt = " << inxt << endl;
	/*----------------------------------------------------------
	 * Range check: make sure the layover, cabname, and storage track
	 * vectors are the right size
	 *----------------------------------------------------------*/
#ifdef DEBUG
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): Range check." << endl;
#endif
        if (layoverVector->size() != nstops ||
            cabnameVector->size() != nstops ||
	    storageTrackVector->size() != nstops) {
	  if (outmessage != NULL) {
	    if (layoverVector->size() != nstops) {
 	      strcpy(buffer,_("Range Check: layover vector is the wrong size!"));
	    } else if (cabnameVector->size() != nstops) {
 	      strcpy(buffer,_("Range Check: cabname vector is the wrong size!"));
	    } else if (storageTrackVector->size() != nstops) {
 	      strcpy(buffer,_("Range Check: storage track vector is the wrong size!"));
 	    }
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return NULL;
	}

#ifdef DEBUG
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): Storage track occupancy check." << endl;
#endif
	for (istop = start,i=0; i < nstops; istop += inxt,i++) {
	  double layover = (*layoverVector)[i];
	  Station *station = IthStation(istop);
	  if (station == NULL) {
	    if (outmessage != NULL) {
	      sprintf(buffer,_("Bad station index %d: no such station!"),istop);
	      *outmessage = new char[strlen(buffer)+1];
	      strcpy(*outmessage,buffer);
	    }
	    return NULL;
	  }
	  smile = station->SMile();
	  if (oldDepart >= 0) {
	  	arrival = oldDepart + (fabs(smile - oldSmile) * (speed / 60.0));
	  } else {
	  	arrival = departure;
	  }
	  depart = arrival + layover;
	  oldDepart = depart;
	  oldSmile  = smile;
	  
	  string storageTrackName = (*storageTrackVector)[i];
	  if (storageTrackName == "") continue;
	  StorageTrack *storage = station->FindStorageTrack(storageTrackName);
	  int rStationIndex = station->DuplicateStationIndex();
	  Station *rStation = NULL;
	  if (rStationIndex >= 0) rStation = IthStation(rStationIndex);
	  StorageTrack *rStorage = NULL;
	  if (rStation != NULL) {
	    rStorage = rStation->FindStorageTrack(storageTrackName);
	  }
	  if (istop == (unsigned)start) {
	    if (storage != NULL) {
	      const Occupied *occupied = storage->IncludesTime(departure);
	      if (occupied != NULL) {
	      	//double from = occupied->From();
	      	//double to   = occupied->Until();
	      	string tn2  = occupied->TrainNum2();
	      	if (tn2 != "") {
		  if (outmessage != NULL) {
		    sprintf(buffer,
			  _("Duplicate storage track (%s) occupancy (%s) at %s"),
			  storageTrackName.c_str(),tn2.c_str(),
			  station->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
	          }
		  return NULL;
	        }
	      }
	    }
	    if (rStorage != NULL) {
	      const Occupied *occupied = rStorage->IncludesTime(departure);
	      if (occupied != NULL) {
	        //double from = occupied->From();
	      	//double to   = occupied->Until();
	      	string tn2  = occupied->TrainNum2();
	      	if (tn2 != "") {
	      	  if (outmessage != NULL) {
		    sprintf(buffer,
			_("Duplicate storage track (%s) occupancy (%s) at %s"),
			  storageTrackName.c_str(),tn2.c_str(),
			  rStation->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
	          }
		  return NULL;
		}
	      }
	    }
	  } else if (istop == (unsigned)end) {
	    if (storage != NULL) {
	      const Occupied *occupied = storage->IncludesTime(arrival);
	      if (occupied != NULL) {
	      	//double from = occupied->From();
	      	//double to   = occupied->Until();
	      	string tn  = occupied->TrainNum();
	      	if (tn != "") {
		  if (outmessage != NULL) {
		    sprintf(buffer,
			  _("Duplicate storage track (%s) occupancy (%s) at %s"),
			  storageTrackName.c_str(),tn.c_str(),
			  station->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
	          }
		  return NULL;
	        }
	      }
	    }
	    if (rStorage != NULL) {
	      const Occupied *occupied = rStorage->IncludesTime(arrival);
	      if (occupied != NULL) {
	        //double from = occupied->From();
	        //double to   = occupied->Until();
	        string tn  = occupied->TrainNum();
	        if (tn != "") {
	          if (outmessage != NULL) {
		    sprintf(buffer,
			_("Duplicate storage track (%s) occupancy (%s) at %s"),
			  storageTrackName.c_str(),tn.c_str(),
			  rStation->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
	          }
		  return NULL;
		}
	      }
	    }
	  } else if (layover > 0 && storage != NULL) {
	    const Occupied *o1 = storage->IncludesTime(arrival);
	    const Occupied *o2 = storage->IncludesTime(depart);
	    if (o1 != NULL || o2 != NULL) {
	      if (outmessage != NULL) {
		sprintf(buffer,
		      _("Duplicate storage track (%s) occupancy at %s"),
		       storageTrackName.c_str(),station->Name());
		*outmessage = new char[strlen(buffer)+1];
		strcpy(*outmessage,buffer);
	      }
	      return NULL;
	    }
	    if (rStorage != NULL) {
	      o1 = rStorage->IncludesTime(arrival);
	      o2 = rStorage->IncludesTime(depart);
	      if (o1 != NULL || o2 != NULL) {
		if (outmessage != NULL) {
		  sprintf(buffer,
		      _("Duplicate storage track (%s) occupancy at %s"),
		       storageTrackName.c_str(),rStation->Name());
		  *outmessage = new char[strlen(buffer)+1];
		  strcpy(*outmessage,buffer);
	        }
	        return NULL;
	      }
	    }
	  }

	  oldDepart = depart;
	  oldSmile  = smile;
	}
	/*-------------------------------------------------------------
	 * Create and store the train.
	 *-------------------------------------------------------------*/
#ifdef DEBUG
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): Create and store the train." << endl;
#endif
	newTrain = new Train(this,name,number,speed,classnumber,departure,
			     start,end);
	trains[number] = newTrain;
	/*-------------------------------------------------------------
	 * Process the layovers, cabnames, and storage tracks.
	 *-------------------------------------------------------------*/
#ifdef DEBUG
	cerr << "*** TimeTableSystem::AddTrainLongVersion(): Process the layovers, cabnames, and storage tracks." << endl;
#endif
	oldDepart = -1;
	oldSmile =  -1;	
	for (istop = start,i=0; i < nstops; istop += inxt,i++) {
#ifdef DEBUG
	  cerr << "*** TimeTableSystem::AddTrainLongVersion(): istop = " << istop << endl;
#endif
	  double layover = (*layoverVector)[i];
#ifdef DEBUG
	  cerr << "*** TimeTableSystem::AddTrainLongVersion(): layover = " << layover << endl;
#endif
	  newTrain->UpdateStopLayover(istop,layover);
	  string cabName = (*cabnameVector)[i];
#ifdef DEBUG
	  cerr << "*** TimeTableSystem::AddTrainLongVersion(): cabName = " << cabName << endl;
#endif
	  if (cabName != "") {
	    Cab * cab = FindCab(cabName);
	    newTrain->UpdateStopCab(istop,cab);
	  }
	  Station *station = IthStation(istop);
	  smile = station->SMile();
	  if (oldDepart >= 0) {
	  	arrival = oldDepart + (fabs(smile - oldSmile) * (speed / 60.0));
	  } else {
	  	arrival = departure;
	  }
	  depart = arrival + layover;
	  oldDepart = depart;
	  oldSmile  = smile;
	  
	  string storageTrackName = (*storageTrackVector)[i];
#ifdef DEBUG
	  cerr << "*** TimeTableSystem::AddTrainLongVersion(): storageTrackName = " << storageTrackName << endl;
#endif
	  if (storageTrackName == "") continue;
	  StorageTrack *storage = station->FindStorageTrack(storageTrackName);
	  int rStationIndex = station->DuplicateStationIndex();
	  Station *rStation = NULL;
	  if (rStationIndex >= 0) rStation = IthStation(rStationIndex);
	  StorageTrack *rStorage = NULL;
	  if (rStation != NULL) {
	    rStorage = rStation->FindStorageTrack(storageTrackName);
	  }
	  if (istop == (unsigned)start) {
	    if (storage != NULL) {
#ifdef DEBUG
	      cerr << "*** TimeTableSystem::AddTrainLongVersion(): SetOriginStorageTrack()" << endl;
#endif
	      newTrain->SetOriginStorageTrack(storageTrackName);
	      const Occupied *occupied = storage->IncludesTime(departure);
	      if (occupied == NULL) {
#ifdef DEBUG
		cerr << "*** TimeTableSystem::AddTrainLongVersion(): StoreTrain()" << endl;
#endif
	      	storage->StoreTrain("",0.0,departure,number);
#ifdef DEBUG
		cerr << "*** TimeTableSystem::AddTrainLongVersion(): after StoreTrain()" << endl;
#endif
	      } else  {
	      	double from = occupied->From();
	      	double to   = occupied->Until();
#ifdef DEBUG
		cerr << "*** TimeTableSystem::AddTrainLongVersion(): UpdateStoredTrain2() + UpdateStoredTrainDeparture()" << endl;
#endif
		occupied = storage->UpdateStoredTrain2(from,to,number);
		occupied = storage->UpdateStoredTrainDeparture(from,to,departure);
	      }
	    }
	    if (rStorage != NULL) {
	      const Occupied *occupied = rStorage->IncludesTime(departure);
	      if (occupied == NULL) {
	      	rStorage->StoreTrain("",0.0,departure,number);
	      } else {
	        double from = occupied->From();
	      	double to   = occupied->Until();
		occupied = rStorage->UpdateStoredTrain2(from,to,number);
		occupied = rStorage->UpdateStoredTrainDeparture(from,to,departure);
	      }
	    }
	  } else if (istop == (unsigned)end) {
	    if (storage != NULL) {
#ifdef DEBUG
	      cerr << "*** TimeTableSystem::AddTrainLongVersion(): SetDestinationStorageTrack()" << endl;
#endif
	      newTrain->SetDestinationStorageTrack(storageTrackName);
	      const Occupied *occupied = storage->IncludesTime(arrival);
	      if (occupied == NULL) {
#ifdef DEBUG
		cerr << "*** TimeTableSystem::AddTrainLongVersion(): StoreTrain()" << endl;
#endif
	      	storage->StoreTrain(number,arrival,(double)timescale,"");
#ifdef DEBUG
		cerr << "*** TimeTableSystem::AddTrainLongVersion(): after StoreTrain()" << endl;
#endif
	      } else {
	      	double from = occupied->From();
	      	double to   = occupied->Until();
#ifdef DEBUG
		cerr << "*** TimeTableSystem::AddTrainLongVersion(): UpdateStoredTrain2() + UpdateStoredTrainDeparture()" << endl;
#endif
		occupied = storage->UpdateStoredTrain(from,to,number);
		occupied = storage->UpdateStoredTrainArrival(from,to,arrival);
	      }
	    }
	    if (rStorage != NULL) {
	      const Occupied *occupied = rStorage->IncludesTime(arrival);
	      if (occupied == NULL) {
	      	rStorage->StoreTrain(number,arrival,(double)timescale,"");
	      } else {
	        double from = occupied->From();
	        double to   = occupied->Until();
		occupied = rStorage->UpdateStoredTrain(from,to,number);
		occupied = rStorage->UpdateStoredTrainArrival(from,to,arrival);
	      }
	    }
	  } else if (layover > 0 && storage != NULL) {		
	    newTrain->SetTransitStorageTrack(i,storageTrackName);
	    storage->StoreTrain(number,arrival,depart,number);
	    if (rStorage != NULL) {
	      rStorage->StoreTrain(number,arrival,depart,number);
	    }
	  }
	}
	return newTrain;
}

/**********************************************************************
 * Delete a train.  Free up the storage tracks the train might have   *
 * occupying.							      *
 **********************************************************************/

bool TTSupport::TimeTableSystem::DeleteTrain(string number,char **outmessage)
{
	static char buffer[2048];
	int istop, istation;
	double departure, layover;
	double arrival;
	int speed;
	const Stop *stop;
	double oldDepart,oldSmile,depart,smile;
	const Occupied *occupied = NULL;
	
	Train *oldTrain = FindTrainByNumber(number);
	if (oldTrain == NULL) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("Train does not exist (%s)!"),number.c_str());
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return false;
	}
	/*-----------------------------------------------------------
	 * Storage track occupancy cleanup.
	 *-----------------------------------------------------------*/

	departure = oldTrain->Departure();
	speed     = oldTrain->Speed();
	oldDepart = -1;
	oldSmile =  -1;	
	for (istop = 0; istop < oldTrain->NumberOfStops(); istop++) {
	  stop = oldTrain->StopI(istop);
	  istation = stop->StationIndex();
	  Station *station = IthStation(istation);
	  layover = stop->Layover();
	  smile   = station->SMile();
	  if (oldDepart < 0) {
	    arrival = departure;
	  } else {
	    arrival = oldDepart + ((smile - oldSmile) * (speed / 60.0));
	  }
	  depart = arrival + layover;
	  oldDepart = depart;
	  oldSmile  = smile;
	  string storageTrackName = stop->StorageTrackName();
	  if (storageTrackName == "") continue;
	  StorageTrack *storage = station->FindStorageTrack(storageTrackName);
	  int rStationIndex = station->DuplicateStationIndex();
	  Station *rStation = NULL;
	  if (rStationIndex >= 0) rStation = IthStation(rStationIndex);
	  StorageTrack *rStorage = NULL;
	  if (rStation != NULL) {
	    rStorage = rStation->FindStorageTrack(storageTrackName);
	  }
	  switch (stop->Flag()) {
	    case Stop::Origin:
	      occupied = storage->IncludesTime(departure);
	      if (occupied == NULL) {
	      	if (outmessage != NULL) {
	      	  sprintf(buffer,
	      	  	  _("Internal error: missing occupied storage track record at (%s)!"),
			  station->Name());
		  *outmessage = new char[strlen(buffer)+1];
		  strcpy(*outmessage,buffer);
		}
	      } else {
	      	if (occupied->From() == occupied->Until() &&
	      	    occupied->From() == departure &&
	      	    occupied->TrainNum() == number &&
	      	    occupied->TrainNum2() == number) {
	      	  storage->RemovedStoredTrain(occupied->From(),occupied->Until());
	      	} else {
	      	  double from = occupied->From();
	      	  double to   = occupied->Until();
	      	  occupied = storage->UpdateStoredTrain2(from,to,occupied->TrainNum());
	      	  occupied = storage->UpdateStoredTrainDeparture(from,to,from);
	      	}
	      }
	      if (rStorage != NULL) {
	      	occupied = rStorage->IncludesTime(departure);
	      	if (occupied == NULL) {
	      	  if (outmessage != NULL) {
	      	    sprintf(buffer,
	      	    	    _("Internal error: missing occupied storage track record at (%s)!"),
			    rStation->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
		  }
		} else {
		  if (occupied->From() == occupied->Until() &&
		      occupied->From() == departure &&
		      occupied->TrainNum() == number &&
		      occupied->TrainNum2() == number) {
		    rStorage->RemovedStoredTrain(occupied->From(),occupied->Until());
		  } else {
		    double from = occupied->From();
		    double to   = occupied->Until();
		    occupied = rStorage->UpdateStoredTrain2(from,to,occupied->TrainNum());
		    occupied = rStorage->UpdateStoredTrainDeparture(from,to,from);
		  }
		}
	      }
	      break;
	    case Stop::Terminate:
	      occupied = storage->IncludesTime(arrival);
	      if (occupied == NULL) {
	      	if (outmessage != NULL) {
	      	  sprintf(buffer,
	      	  	  _("Internal error: missing occupied storage track record at (%s)!"),
			  station->Name());
		  *outmessage = new char[strlen(buffer)+1];
		  strcpy(*outmessage,buffer);
		}
	      } else {
	      	if (occupied->From() == occupied->Until() &&
	      	    occupied->From() == arrival &&
	      	    occupied->TrainNum() == number &&
	      	    occupied->TrainNum2() == number) {
	      	  storage->RemovedStoredTrain(occupied->From(),occupied->Until());
	      	} else {
	      	  double from = occupied->From();
	      	  double to   = occupied->Until();
	      	  occupied = storage->UpdateStoredTrain(from,to,occupied->TrainNum2());
	      	  occupied = storage->UpdateStoredTrainArrival(from,to,to);
	      	}
	      }
	      if (rStorage != NULL) {
	      	occupied = rStorage->IncludesTime(arrival);
	      	if (occupied == NULL) {
	      	  if (outmessage != NULL) {
	      	    sprintf(buffer,
	      	    	    _("Internal error: missing occupied storage track record at (%s)!"),
			    rStation->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
		  }
		} else {
		  if (occupied->From() == occupied->Until() &&
		      occupied->From() == arrival &&
		      occupied->TrainNum() == number &&
		      occupied->TrainNum2() == number) {
		    rStorage->RemovedStoredTrain(occupied->From(),occupied->Until());
		  } else {
		    double from = occupied->From();
		    double to   = occupied->Until();
		    occupied = rStorage->UpdateStoredTrain(from,to,occupied->TrainNum2());
		    occupied = rStorage->UpdateStoredTrainArrival(from,to,to);
		  }
		}
	      }
	      break;
	    case Stop::Transit:
	      if (layover > 0 && storage != NULL) {
	      	const Occupied *o1 = storage->IncludesTime(arrival);
		const Occupied *o2 = storage->IncludesTime(depart);
		if (o1 != o2 || o1 == NULL || o2 == NULL) {
		  if (outmessage != NULL) {
	      	    sprintf(buffer,
	      	    	    _("Internal error: missing occupied storage track record at (%s)!"),
			    rStation->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
		  }
		} else {
		  storage->RemovedStoredTrain(o1->From(),occupied->Until());
		}
	      }
	      if (layover > 0 && rStorage != NULL) {
		const Occupied *o1 = rStorage->IncludesTime(arrival);
		const Occupied *o2 = rStorage->IncludesTime(depart);
		if (o1 != o2 || o1 == NULL || o2 == NULL) {
		  if (outmessage != NULL) {
	      	    sprintf(buffer,
	      	    	    _("Internal error: missing occupied storage track record at (%s)!"),
			    rStation->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
		  }
		} else {
		  rStorage->RemovedStoredTrain(o1->From(),occupied->Until());
		}
	      }
	      break;
	  }
	}
	/*
	 * Remove the train from the map.
	 */
	TrainNumberMap::iterator Tx = trains.find(number);
	trains.erase(Tx);
	/*
	 * Delete the train.
	 */
	delete oldTrain;
	return true;
}

/**********************************************************************
 * Find a cab by name.  Return NULL for non existent cab names.       *
 **********************************************************************/

TTSupport::Cab *TTSupport::TimeTableSystem::FindCab(string name) const
{
	CabNameMap::const_iterator Cx;
	Cx = cabs.find(name);
	if (Cx == cabs.end()) {
		return NULL;
	} else {
		return Cx->second;
	}
}


/**********************************************************************
 * Find train by number.					      *
 **********************************************************************/

TTSupport::Train *TTSupport::TimeTableSystem::FindTrainByNumber(string number) const
{
	TrainNumberMap::const_iterator Tx;
	Tx = trains.find(number);
	if (Tx == trains.end()) {
		return NULL;
	} else {
		return Tx->second;
	}
}

/**********************************************************************
 * Find train by name.						      *
 **********************************************************************/

TTSupport::Train *TTSupport::TimeTableSystem::FindTrainByName(string name) const
{
	TrainNumberMap::const_iterator Tx;
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
		if ((Tx->second)->Name() == name) return Tx->second;
	}
	return NULL;
}



/**********************************************************************
 * Add a station at a specified location.			      *
 **********************************************************************/

int TTSupport::TimeTableSystem::AddStation(string name,double smile)
{
	int istation = FindStationByName(name);
	if (istation >= 0) return istation;
	if (stations.size() == 0 || (stations.end()-1)->SMile() < smile) {
		stations.push_back(Station(name,smile));
	} else {
		return -1;
	}
	return stations.size()-1;
}

/**********************************************************************
 * Find station by name.					      *
 **********************************************************************/

int TTSupport::TimeTableSystem::FindStationByName(string name)
{
	size_t i;
	for (i = 0; i < stations.size(); i++) {
		if (stations[i].Name() == name) return i;
	}
	return -1;
}

/**********************************************************************
 * Write out a time table system to a file.			      *
 **********************************************************************/

bool TTSupport::TimeTableSystem::WriteNewTimeTableFile(string filename,
				bool setfilename,
				char **outmessage)
{
	static char buffer[2048];	// Error message buffer.
	ofstream out;			// Output stream.
	size_t i,n;
	out.open(filename.c_str());	// Open file.
	if (!out) {			// Error check.
		int err = errno;
		if (outmessage != NULL) {
			sprintf(buffer,_("TimeTableSystem::WriteNewTimeTableFile: Error creating file %s: %s"),
				filename.c_str(),strerror(err));
			*outmessage = new char[strlen(buffer)+1];
			strcpy(*outmessage,buffer);
		}
		return false;
	}
	out << name << endl;		// Write out the name.
	out << timescale << " " << timeinterval << endl; // Write time parameters.
	out << stations.size() << endl;	// Number of stations.
        n = stations.size();
        for (i = 0; i < n; i++) {	// Write out each station.
        	stations[i].Write(out) << endl;
        }
	out << cabs.size() << endl;	// Number of cabs.
	CabNameMap::const_iterator Cx;
	for (Cx = cabs.begin(); Cx != cabs.end(); Cx++) { // Write  out each cab.
		(Cx->second)->Write(out) << endl;
	}
	out << trains.size() << endl;	// Number of trains.
	TrainNumberMap::const_iterator Tx;
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) { // Write out each train.
		(Tx->second)->Write(out) << endl;
	}
	out << notes.size() << endl;	// Number of notes.
	for (i = 0; i < notes.size(); i++) {	// Write out each note.
		WriteNote(out,notes[i]) << endl;
	}
	out << printOptions.size() << endl;	// Number of print options.
	OptionHashMap::const_iterator OptionIndex;
	// Write out each print option.
	for (OptionIndex = printOptions.begin(); OptionIndex != printOptions.end(); OptionIndex++) {
		WriteNote(out,OptionIndex->first) << " ";
		WriteNote(out,OptionIndex->second) << endl;
	}
	out.close();			// Close the file.
	if (setfilename) {
		filepath = filename;
	}
	return true;
}



/**********************************************************************
 * Write out a note.  Make sure it is properly quoted!                *
 **********************************************************************/

ostream & TTSupport::TimeTableSystem::WriteNote(ostream &out,string note) const
{
	out.put('"');
	string::const_iterator ich;
	for (ich = note.begin(); ich != note.end(); ich++) {
		if (*ich == '"' || *ich == '\\') out.put('\\');
		out.put(*ich);
	}
	out.put('"');
	return out;
}

/**********************************************************************
 * Read in a note.  Mind the quoting!				      *
 **********************************************************************/

string TTSupport::TimeTableSystem::ReadNote(istream &stream) const
{
	char ch;
	string result;
	do {
		stream.get(ch);
		if (!stream) return result;
	} while (ch != '"');
	while (true) {
		stream.get(ch);
		if (!stream) return result;
		if (ch == '"') break;
		if (ch == '\\') {
			stream.get(ch);
			if (!stream) return result;
		}
		result += ch;
	}
	return result;
}


/**********************************************************************
 * Build a flat string from a list of strings, adding all necessary   *
 * quoting.                                                           *
 **********************************************************************/

const char *TTSupport::StringListToString(const TTSupport::StringList &list)
{
	StringList::const_iterator istring;
	string theString,result = "",comma = "";
	string::const_iterator ichar;
	for (istring = list.begin(); istring != list.end(); istring ++) {
	  theString = *istring;
	  result += comma;
	  result += '"';
	  for (ichar = theString.begin(); ichar != theString.end(); ichar++) {
	    char c = *ichar;
	    if (c == '"' || c == '\\') result += '\\';
	    result += c;
	  }
	  result += '"';
	  comma = ',';
	}
	return result.c_str();
}

/**********************************************************************
 * Break up a comma separated list of quoted strings, minding the     *
 * quoting.							      *
 **********************************************************************/

bool TTSupport::StringListFromString(string strlinList,TTSupport::StringList &result)
{
	string theString = "";
	string::const_iterator ichar;
	bool inString = false, expectcomma = false, expectquotes = true;
	result.empty();
	for (ichar = strlinList.begin(); ichar != strlinList.end(); ichar++) {
	  char c = *ichar;
	  if (inString) {
	    if (c == '"') {
	      result.push_back(theString);
	      theString = "";
	      inString = false;
	      expectcomma = true;
	      expectquotes = false;
	    } else if (c == '\\') {
	    	ichar++;
	    	if (ichar == strlinList.end()) return false;
	    	theString += *ichar;
	    } else {
	    	theString += c;
	    }
	  } else {
	    if (c == ',' && expectcomma) {
	      expectcomma = false;
	      expectquotes = true;
	    } else if (c == '"' && expectquotes) {
	      theString = "";
	      inString = true;
	    } else {
	      return false;
	    }
	  }
	}
	if (result.size() == 0 && !inString && expectquotes) return true;
	else return !inString && expectcomma;
}

