/* 
 * ------------------------------------------------------------------
 * TimeTableSystem.cc - Time Table System class implememntation.
 * Created by Robert Heller on Tue Dec 20 00:34:14 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
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
 
#include <TimeTableSystem.h>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <math.h>

TimeTableSystem::TimeTableSystem(string filename,
				 char **outmessage)
{
	static char buffer[2048];
	int count;
	ifstream in;
	filepath = filename;
	in.open(filepath.FullPath().c_str());
	if (!in) {
		int err = errno;
		if (outmessage != NULL) {
			sprintf(buffer,"TimeTableSystem::TimeTableSystem: %s: %s",filepath.FullPath().c_str(),strerror(err));
			*outmessage = new char[strlen(buffer)+1];
			strcpy(*outmessage,buffer);
		}
		return;
	}
	in.getline(buffer,sizeof(buffer)-1,'\n');
	name = buffer;
	in >> timescale >> timeinterval;
	in >> count;
	while (count-- > 0) {
		Station station;
		station.Read(in);
		stations.push_back(station);
	}
	in >> count;
#ifdef DEBUG
	cerr << "*** TimeTableSystem::TimeTableSystem (cabs): count = " << count << endl;
#endif
	while (count-- > 0) {
		Cab *newcab = new Cab();
		newcab->Read(in);
		cabs[newcab->Name()] = newcab;
	}
	in >> count;
	while (count-- > 0) {
		Train *newtrain = new Train();
		newtrain->Read(in,cabs);
		trains[newtrain->Number()] = newtrain;
	}
	in >> count;
	while (count-- > 0) {
		notes.push_back(ReadNote(in));
	}
	count = 0;
	in >> count;
	while (count-- > 0) {
		string thekey = ReadNote(in);
		char *key = new char[thekey.size()+1];
		strcpy(key,thekey.c_str());
		printOptions[key] = ReadNote(in);
#ifdef DEBUG
		cerr << "*** TimeTableSystem::TimeTableSystem(): printOptions[" << key << "] = '" << printOptions[key] << "'" << endl;
#endif
	}
	in.close();
}

TimeTableSystem::TimeTableSystem(string name_,int timescale_,int timeinterval_)
{
	name = name_;
	timescale = timescale_;
	timeinterval = timeinterval_;
	filepath = string("");
}

TimeTableSystem::~TimeTableSystem()
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

Cab *TimeTableSystem::AddCab(string name, string color)
{
	Cab *newCab = FindCab(name);
	if (newCab == NULL) {
		newCab = new Cab(name,color);
		cabs[name] = newCab;
	}
	return newCab;
}

Train *TimeTableSystem::AddTrain(string name, string number,
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

Train *TimeTableSystem::AddTrainLongVersion(string name, string number,
					    int speed,int classnumber,
					    int departure,int start,int end,
					    const doubleVector layoverVector,
					    const stringVector cabnameVector,
					    const stringVector storageTrackVector,
					    char **outmessage)
{
	static char buffer[2048];
	int istop, i,inxt, nstops;
	double oldDepart,depart;
	double oldSmile,smile;
	double arrival;


	/*----------------------------------------------------------
	 * Duplicate train check.
	 *----------------------------------------------------------*/
	
	Train *newTrain = FindTrainByNumber(number);
	if (newTrain != NULL) {
	  if (outmessage != NULL) {
	    sprintf(buffer,"Duplicate train number (%s)!",number.c_str());
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	  return NULL;
	}
	if (start == end) {
	  if (outmessage != NULL) {
	    sprintf(buffer,"Train makes no stops!");
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
	if (start < end) {
		inxt = 1;
		nstops = (end-start)+1;
	} else {
		inxt = -1;
		nstops = (start-end)+1;
	}
	for (istop = start,i=0; i < nstops; istop += inxt,i++) {
	  double layover = layoverVector[i];
	  Station *station = IthStation(istop);
	  if (station == NULL) {
	    if (outmessage != NULL) {
	      sprintf(buffer,"Bad station index %d: no such station!",istop);
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
	  
	  string storageTrackName = storageTrackVector[i];
	  if (storageTrackName == "") continue;
	  StorageTrack *storage = station->FindStorageTrack(storageTrackName);
	  int rStationIndex = station->DuplicateStationIndex();
	  Station *rStation = NULL;
	  if (rStationIndex >= 0) rStation = IthStation(rStationIndex);
	  StorageTrack *rStorage = NULL;
	  if (rStation != NULL) {
	    rStorage = rStation->FindStorageTrack(storageTrackName);
	  }
	  if (istop == start) {
	    if (storage != NULL) {
	      const Occupied *occupied = storage->IncludesTime(departure);
	      if (occupied != NULL) {
	      	double from = occupied->From();
	      	double to   = occupied->Until();
	      	string tn2  = occupied->TrainNum2();
	      	if (tn2 != "") {
		  if (outmessage != NULL) {
		    sprintf(buffer,
			  "Duplicate storage track (%s) occupancy (%s) at %s",
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
	        double from = occupied->From();
	      	double to   = occupied->Until();
	      	string tn2  = occupied->TrainNum2();
	      	if (tn2 != "") {
	      	  if (outmessage != NULL) {
		    sprintf(buffer,
			"Duplicate storage track (%s) occupancy (%s) at %s",
			  storageTrackName.c_str(),tn2.c_str(),
			  rStation->Name());
		    *outmessage = new char[strlen(buffer)+1];
		    strcpy(*outmessage,buffer);
	          }
		  return NULL;
		}
	      }
	    }
	  } else if (istop == end) {
	    if (storage != NULL) {
	      const Occupied *occupied = storage->IncludesTime(arrival);
	      if (occupied != NULL) {
	      	double from = occupied->From();
	      	double to   = occupied->Until();
	      	string tn  = occupied->TrainNum();
	      	if (tn != "") {
		  if (outmessage != NULL) {
		    sprintf(buffer,
			  "Duplicate storage track (%s) occupancy (%s) at %s",
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
	        double from = occupied->From();
	        double to   = occupied->Until();
	        string tn  = occupied->TrainNum();
	        if (tn != "") {
	          if (outmessage != NULL) {
		    sprintf(buffer,
			"Duplicate storage track (%s) occupancy (%s) at %s",
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
		      "Duplicate storage track (%s) occupancy at %s",
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
		      "Duplicate storage track (%s) occupancy at %s",
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
	newTrain = new Train(this,name,number,speed,classnumber,departure,
			     start,end);
	trains[number] = newTrain;
	/*-------------------------------------------------------------
	 * Process the layovers, cabnames, and storage tracks.
	 *-------------------------------------------------------------*/
	oldDepart = -1;
	oldSmile =  -1;	
	for (istop = start,i=0; i < nstops; istop += inxt,i++) {
	  double layover = layoverVector[i];
	  newTrain->UpdateStopLayover(istop,layover);
	  string cabName = cabnameVector[i];
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
	  
	  string storageTrackName = storageTrackVector[i];
	  if (storageTrackName == "") continue;
	  StorageTrack *storage = station->FindStorageTrack(storageTrackName);
	  int rStationIndex = station->DuplicateStationIndex();
	  Station *rStation = NULL;
	  if (rStationIndex >= 0) rStation = IthStation(rStationIndex);
	  StorageTrack *rStorage = NULL;
	  if (rStation != NULL) {
	    rStorage = rStation->FindStorageTrack(storageTrackName);
	  }
	  if (istop == start) {
	    if (storage != NULL) {
	      newTrain->SetOriginStorageTrack(storageTrackName);
	      const Occupied *occupied = storage->IncludesTime(departure);
	      if (occupied == NULL) {
	      	storage->StoreTrain(number,departure,departure,number);
	      } else  {
	      	double from = occupied->From();
	      	double to   = occupied->Until();
		occupied = storage->UpdateStoredTrain2(from,to,number);
		occupied = storage->UpdateStoredTrainDeparture(from,to,departure);
	      }
	    }
	    if (rStorage != NULL) {
	      const Occupied *occupied = rStorage->IncludesTime(departure);
	      if (occupied == NULL) {
	      	rStorage->StoreTrain(number,departure,departure,number);
	      } else {
	        double from = occupied->From();
	      	double to   = occupied->Until();
		occupied = rStorage->UpdateStoredTrain2(from,to,number);
		occupied = rStorage->UpdateStoredTrainDeparture(from,to,departure);
	      }
	    }
	  } else if (istop == end) {
	    if (storage != NULL) {
	      newTrain->SetDestinationStorageTrack(storageTrackName);
	      const Occupied *occupied = storage->IncludesTime(arrival);
	      if (occupied == NULL) {
	      	storage->StoreTrain(number,arrival,arrival,number);
	      } else {
	      	double from = occupied->From();
	      	double to   = occupied->Until();
		occupied = storage->UpdateStoredTrain(from,to,number);
		occupied = storage->UpdateStoredTrainArrival(from,to,arrival);
	      }
	    }
	    if (rStorage != NULL) {
	      const Occupied *occupied = rStorage->IncludesTime(arrival);
	      if (occupied == NULL) {
	      	rStorage->StoreTrain(number,arrival,arrival,number);
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

bool TimeTableSystem::DeleteTrain(string number,char **outmessage)
{
	static char buffer[2048];
	int istop, istation;
	double departure, layover;
	double arrival;
	int speed;
	const Stop *stop;
	double oldDepart,oldSmile,depart,smile;
	const Occupied *occupied;
	
	Train *oldTrain = FindTrainByNumber(number);
	if (oldTrain == NULL) {
	  if (outmessage != NULL) {
	    sprintf(buffer,"Train does not exist (%s)!",number.c_str());
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
	      	  	  "Internal error: missing occupied storage track record at (%s)!",
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
	      	    	    "Internal error: missing occupied storage track record at (%s)!",
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
	      	  	  "Internal error: missing occupied storage track record at (%s)!",
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
	      	    	    "Internal error: missing occupied storage track record at (%s)!",
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
	      	    	    "Internal error: missing occupied storage track record at (%s)!",
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
	      	    	    "Internal error: missing occupied storage track record at (%s)!",
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

Cab *TimeTableSystem::FindCab(string name) const
{
	CabNameMap::const_iterator Cx;
	Cx = cabs.find(name);
	if (Cx == cabs.end()) {
		return NULL;
	} else {
		return Cx->second;
	}
}


Train *TimeTableSystem::FindTrainByNumber(string number) const
{
	TrainNumberMap::const_iterator Tx;
	Tx = trains.find(number);
	if (Tx == trains.end()) {
		return NULL;
	} else {
		return Tx->second;
	}
}

Train *TimeTableSystem::FindTrainByName(string name) const
{
	TrainNumberMap::const_iterator Tx;
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
		if ((Tx->second)->Name() == name) return Tx->second;
	}
	return NULL;
}



int TimeTableSystem::AddStation(string name,double smile)
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

int TimeTableSystem::FindStationByName(string name)
{
	int i;
	for (i = 0; i < stations.size(); i++) {
		if (stations[i].Name() == name) return i;
	}
	return -1;
}

bool TimeTableSystem::WriteNewTimeTableFile(string filename,
				bool setfilename,
				char **outmessage)
{
	static char buffer[2048];
	ofstream out;
	int i,n;
	out.open(filename.c_str());
	if (!out) {
		int err = errno;
		if (outmessage != NULL) {
			sprintf(buffer,"TimeTableSystem::WriteNewTimeTableFile: %s: %s",
				filename.c_str(),strerror(err));
			*outmessage = new char[strlen(buffer)+1];
			strcpy(*outmessage,buffer);
		}
		return false;
	}
	out << name << endl;
	out << timescale << " " << timeinterval << endl;
	out << stations.size() << endl;
        n = stations.size();
        for (i = 0; i < n; i++) {
        	stations[i].Write(out) << endl;
        }
	out << cabs.size() << endl;
	CabNameMap::const_iterator Cx;
	for (Cx = cabs.begin(); Cx != cabs.end(); Cx++) {
		(Cx->second)->Write(out) << endl;
	}
	out << trains.size() << endl;
	TrainNumberMap::const_iterator Tx;
	for (Tx = trains.begin(); Tx != trains.end(); Tx++) {
		(Tx->second)->Write(out) << endl;
	}
	out << notes.size() << endl;
	for (i = 0; i < notes.size(); i++) {
		WriteNote(out,notes[i]) << endl;
	}
	out << printOptions.size() << endl;
	OptionHashMap::const_iterator OptionIndex;
	for (OptionIndex = printOptions.begin(); OptionIndex != printOptions.end(); OptionIndex++) {
		WriteNote(out,OptionIndex->first) << " ";
		WriteNote(out,OptionIndex->second) << endl;
	}
	out.close();
	if (setfilename) {
		filepath = filename;
	}
	return true;
}



ostream & TimeTableSystem::WriteNote(ostream &out,string note) const
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

string TimeTableSystem::ReadNote(istream &stream) const
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


const char *StringListToString(const StringList &list)
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

bool StringListFromString(string strlinList,StringList &result)
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

