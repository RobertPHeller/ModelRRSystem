/* 
 * ------------------------------------------------------------------
 * Station.cc - Station class implementation.
 * Created by Robert Heller on Tue Dec 20 23:08:32 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.8  2007/05/06 12:49:38  heller
 * Modification History: Lock down  for 2.1.8 release candidate 1
 * Modification History:
 * Modification History: Revision 1.7  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.6  2006/05/17 01:11:22  heller
 * Modification History: May 16, 2006 lock down II: Add in IDs
 * Modification History:
 * Modification History: Revision 1.5  2006/05/16 19:27:45  heller
 * Modification History: May162006 Lockdown
 * Modification History:
 * Modification History: Revision 1.4  2006/02/26 23:45:42  heller
 * Modification History: Lock Down 3
 * Modification History:
 * Modification History: Revision 1.2  2006/01/03 15:54:53  heller
 * Modification History: lockdown
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

#include <Station.h>
#include <ctype.h>

static char Id[] = "$Id$";


const Occupied * StorageTrack::IncludesTime(double time) const
{
#ifdef DEBUG
	cerr << "*** StorageTrack::IncludesTime(" << time << ")" << endl;
#endif
	OccupiedMap::const_iterator Ox;
#ifdef DEBUG
	cerr << "*** StorageTrack::IncludesTime: occupations.size() = " << occupations.size() << endl;
#endif
	for (Ox = occupations.begin(); Ox != occupations.end(); Ox++) {
#ifdef DEBUG
		cerr << "*** StorageTrack::IncludesTime: (Ox->first).To() = " << (Ox->first).To() << endl;
		cerr << "*** StorageTrack::IncludesTime: (Ox->first).From() = " << (Ox->first).From() << endl;
#endif
		if (time > (Ox->first).To()) continue;
		if ((Ox->first).ContainsTime(time)) return &(Ox->second);
	}
	return NULL;
}

        
StorageTrack *Station::AddStorageTrack(string name_)
{
	if (FindStorageTrack(name_) != NULL) return NULL;
	StorageTrack newtrack(name_);
	storageTracks[name_] = newtrack;
	return &(storageTracks[name_]);
}

bool StorageTrack::RemovedStoredTrain (double from, double to)
{
	TimeRange range(from,to);
	OccupiedMap::iterator Ox;
	Ox = occupations.find(range);
	if (Ox == occupations.end()) return false;
	occupations.erase(Ox);
	return true;
}

const Occupied * StorageTrack::StoreTrain (string train, double from, double to,string train2)
{
	cerr << "*** StorageTrack::StoreTrain(): calling UsedTimeRange()" << endl;
	if (UsedTimeRange(from,to)) return NULL;
	cerr << "*** StorageTrack::StoreTrain(): after UsedTimeRange() check" << endl;
	TimeRange range(from,to);
	Occupied  newOccupied(train,from,to,train2);
	cerr << "*** StorageTrack::StoreTrain(): after newOccupied" << endl;
	occupations[range] = newOccupied;
	cerr << "*** StorageTrack::StoreTrain(): after occupations update" << endl;
	return &(occupations[range]);
}

const Occupied * StorageTrack::UpdateStoredTrain(double from, double to,
						 string train) {
	TimeRange range(from,to);
	OccupiedMap::iterator Ox = occupations.find(range);
	if (Ox == occupations.end()) return NULL;
	Occupied  newOccupied(train,range.From(),range.To(),
				(Ox->second).TrainNum2());
	(Ox->second) = newOccupied;
	return &((Ox->second));
}

const Occupied * StorageTrack::UpdateStoredTrain2(double from, double to,
						  string train) {
	TimeRange range(from,to);
	OccupiedMap::iterator Ox = occupations.find(range);
	if (Ox == occupations.end()) return NULL;
	Occupied  newOccupied((Ox->second).TrainNum(),range.From(),range.To(),
				train);
	(Ox->second) = newOccupied;
	return &((Ox->second));
}

const Occupied * StorageTrack::UpdateStoredTrainArrival(double from, double to,
						  double newArrival) {
	TimeRange range(from,to);
	OccupiedMap::iterator Ox = occupations.find(range);
	if (Ox == occupations.end()) return NULL;
	string tn,tn2;
	tn = (Ox->second).TrainNum();
	tn2 = (Ox->second).TrainNum2();
	Occupied  newOccupied(tn,newArrival,range.To(),tn2);
	occupations.erase(Ox);
	occupations[range] = newOccupied;
	return &(occupations[range]);
}

const Occupied * StorageTrack::UpdateStoredTrainDeparture(double from, double to,
						    double newDeparture) {
	TimeRange range(from,to);
	OccupiedMap::iterator Ox = occupations.find(range);
	if (Ox == occupations.end()) return NULL;
	string tn,tn2;
	tn = (Ox->second).TrainNum();
	tn2 = (Ox->second).TrainNum2();
	Occupied  newOccupied(tn,range.From(),newDeparture,tn2);
	occupations.erase(Ox);
	occupations[range] = newOccupied;
	return &(occupations[range]);
}


bool StorageTrack::UsedTimeRange(double from, double to) const
{
	cerr << "*** StorageTrack::UsedTimeRange(" << from << "," << to << ")" << endl;
	OccupiedMap::const_iterator Ox;
	for (Ox = occupations.begin(); Ox != occupations.end(); Ox++) {
		cerr << "*** StorageTrack::UsedTimeRange(): (Ox->first).To() = " << (Ox->first).To() << endl;
		cerr << "*** StorageTrack::UsedTimeRange(): (Ox->first).From() = " << (Ox->first).To() << endl;
		if (from > (Ox->first).To()) break;
		if (to < (Ox->first).From()) continue;
		if ((Ox->first).ContainsTime(from) ||
		    (Ox->first).ContainsTime(to)) return true;
	}
	return false;	
}

StorageTrack *Station::FindTrackTrainIsStoredOn(string trainNumber,
						double fromtime,double totime)
{
	StorageTrackMap::iterator Sx;
	const Occupied *occupied;
#ifdef DEBUG
	cerr << "*** Station::FindTrackTrainIsStoredOn(" << trainNumber << "," << fromtime << "," << totime << ")" << endl;
#endif
	for (Sx = storageTracks.begin(); Sx != storageTracks.end(); Sx++) {
#ifdef DEBUG
		cerr << "*** Station::FindTrackTrainIsStoredOn: (Sx->first) = " << (Sx->first) << endl;
#endif
		occupied = (Sx->second).IncludesTime(fromtime);
#ifdef DEBUG
		if (occupied != NULL) {cerr << "*** Station::FindTrackTrainIsStoredOn: occupied = "; occupied->Write(cerr) << endl;}
#endif
		if (occupied != NULL && occupied->TrainNum() == trainNumber) {
			return &(Sx->second);
		}
		occupied = (Sx->second).IncludesTime(totime);
#ifdef DEBUG
		if (occupied != NULL) {cerr << "*** Station::FindTrackTrainIsStoredOn: occupied = ";  occupied->Write(cerr) << endl;}
#endif
		if (occupied != NULL && occupied->TrainNum2() == trainNumber) {
			return &(Sx->second);
		}
	}
	return NULL;
}

ostream & Station::Write(ostream & stream) const
{
	stream << "<Station \"" << name << "\" "
		<< smile << " " << duplicateStationIndex << " "
		<< storageTracks.size() << " " << endl;
	StorageTrackMap::const_iterator Sx;
	for (Sx = storageTracks.begin(); Sx != storageTracks.end(); Sx++) {
		(Sx->second).Write(stream) << endl;
	}
	stream << ">";
	return stream;
}

istream & Station::Read(istream & stream)
{
	char buffer[2048], ch, *p;
	int i, count;
	do {
	 	stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Station::Read (while (isspace(ch))): ch = '" << ch << "'" << endl; 
#endif
	} while (isspace(ch));
	stream.putback(ch);
	for (i = 0,p = "<Station \""; *p != '\0'; p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Station::Read (for (<Station...)): ch = '" << ch << "'" << endl;
#endif
		if (ch != *p) {
			stream.putback(ch);
			while (i > 0) stream.putback(buffer[--i]);
			stream.setstate(ios::failbit);
			return stream;
		}
		buffer[i] = ch;
	}
	for (i = 0,p = buffer;i < 2048;p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Station::Read (for (buffer)): ch = '" << ch << "'" << endl;
#endif
		if (ch == '"') break;
		*p = ch;
	}
	*p = '\0';
	name = buffer;
	stream >> smile;
	if (!stream) return stream;
	stream >> duplicateStationIndex;
	if (!stream) return stream;
	stream >> count;
	if (!stream) return stream;
#ifdef DEBUG
	cerr << "*** Station::Read: count = " << count << endl;
#endif
	while (count-- > 0) {
		StorageTrack temp;
		temp.Read(stream);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Station::Read (while (count-- > 0)): count = " << count << endl;
#endif
		storageTracks[temp.Name()] = temp;
	}
	do {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Station::Read (while (ch != '>')): ch = '" << ch << "'" << endl;
#endif
	} while (ch != '>');
	return stream;
}

ostream & StorageTrack::Write(ostream & stream) const
{
	stream << "<StorageTrack \"" << name << "\" "
		<< occupations.size() << " " << endl;
	OccupiedMap::const_iterator Ox;
	for (Ox = occupations.begin(); Ox != occupations.end(); Ox++) {
		(Ox->first).Write(stream) << " ";
		(Ox->second).Write(stream);
	}
	stream << ">";
	return stream;
}

istream & StorageTrack::Read(istream & stream)
{
	char buffer[2048], ch, *p;
	int i, count;
	do {
	 	stream.get(ch);
		if (!stream) return stream;
	} while (isspace(ch));
	stream.putback(ch);
	for (i = 0,p = "<StorageTrack \""; *p != '\0'; p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
		if (ch != *p) {
			stream.putback(ch);
			while (i > 0) stream.putback(buffer[--i]);
			stream.setstate(ios::failbit);
			return stream;
		}
		buffer[i] = ch;
	}
	for (i = 0,p = buffer;i < 2048;p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
		if (ch == '"') break;
		*p = ch;
	}
	*p = '\0';
	name = buffer;
	stream >> count;
	if (!stream) return stream;
	while (count-- > 0) {
		TimeRange key;
		Occupied temp;
		key.Read(stream);
		if (!stream) return stream;
		temp.Read(stream);
		if (!stream) return stream;
		occupations[key] = temp;
	}
	do {
		stream.get(ch);
		if (!stream) return stream;
	} while (ch != '>');
	return stream;
}

ostream & TimeRange::Write(ostream & stream) const
{
	stream << "<TimeRange " << from << ":" << to << ">";
	return stream;
}

istream & TimeRange::Read(istream & stream)
{
	char buffer[2048], ch, *p;
	int i, count;
	do {
	 	stream.get(ch);
	 	if (!stream) return stream;
	} while (isspace(ch));
	stream.putback(ch);
	for (i = 0,p = "<TimeRange "; *p != '\0'; p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
		if (ch != *p) {
			stream.putback(ch);
			while (i > 0) stream.putback(buffer[--i]);
			stream.setstate(ios::failbit);
			return stream;
		}
		buffer[i] = ch;
	}
	stream >> from;
	if (!stream) return stream;
	stream.get(ch);
	if (ch != ':') {
		stream.setstate(ios::failbit);
		return stream;
	}
	stream >> to;
	if (!stream) return stream;
	stream.get(ch);
	if (ch != '>') {
		stream.setstate(ios::failbit);
		return stream;
	}
	return stream;
}

ostream & Occupied::Write(ostream & stream) const
{
	stream << "<Occupied \"" << trainnum << "\" "
		<< from << ":" << until << " \"" << trainnum2 << "\">";
	return stream;
}

istream & Occupied::Read(istream & stream)
{
	char buffer[2048], ch, *p;
	int i, count;
	do {
	 	stream.get(ch);
		if (!stream) return stream;
	} while (isspace(ch));
	stream.putback(ch);
	for (i = 0,p = "<Occupied \""; *p != '\0'; p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
		if (ch != *p) {
			stream.putback(ch);
			while (i > 0) stream.putback(buffer[--i]);
			stream.setstate(ios::failbit);
			return stream;
		}
		buffer[i] = ch;
	}
	for (i = 0,p = buffer;i < 2048;p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
		if (ch == '"') break;
		*p = ch;
	}
	*p = '\0';
	trainnum = buffer;
	stream >> from;
	if (!stream) return stream;
	stream.get(ch);
	if (ch != ':') {
		stream.setstate(ios::failbit);
		return stream;
	}
	stream >> until;
	do {
		stream.get(ch);
		if (!stream) return stream;
	} while (ch != '"');
	for (i = 0,p = buffer;i < 2048;p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
		if (ch == '"') break;
		*p = ch;
	}
	*p = '\0';
	trainnum2 = buffer;
	stream.get(ch);
	if (ch != '>') stream.setstate(ios::failbit);
	return stream;
}

