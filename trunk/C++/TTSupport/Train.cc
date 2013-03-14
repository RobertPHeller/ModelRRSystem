/* 
 * ------------------------------------------------------------------
 * Train.cc - Train class implementation.
 * Created by Robert Heller on Thu Dec 22 13:18:33 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2006/05/17 01:11:22  heller
 * Modification History: May 16, 2006 lock down II: Add in IDs
 * Modification History:
 * Modification History: Revision 1.3  2006/05/16 19:27:46  heller
 * Modification History: May162006 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2006/02/26 23:45:42  heller
 * Modification History: Lock Down 3
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

#include "config.h"
#include <Train.h>
#include <Station.h>
#include <Cab.h>
#include <TimeTableSystem.h>

using namespace TTSupport;


static char Id[] = "$Id$";

Train::Train(TTSupport::TimeTableSystem *timetable,string name_, string number_,
		int speed_,int classnumber_,
	      int departure_,int start, int end)
{
	name = name_;
	number = number_;
	speed = speed_;
	classnumber = classnumber_;
	int istop,inext;
	departure = departure_;
	if (timetable == NULL) return;
	if (end < 0) {
		end = timetable->NumberOfStations()-1;
		if (start == end) end = 0;
	}
	if (end == start) return;
	if (end < start) {
		inext = -1;
	} else {
		inext = 1;
	}
	startSMile = timetable->SMile(start);
	Stop origin(start,Stop::Origin);
	stops.push_back(origin);
	for (istop = start + inext; istop != end; istop += inext) {
		Stop stop(istop,Stop::Transit);
		stops.push_back(stop);
	}
	Stop dest(end,Stop::Terminate);
	stops.push_back(dest);
}

void Train::UpdateStopLayover(int istop, double layover)
{
	if (istop < 0 || (unsigned)istop >= stops.size()) return;
	stops[istop].SetLayover(layover);
}

void Train::UpdateStopCab(int istop,Cab *cab)
{
	if (istop < 0 || (unsigned)istop >= stops.size()) return;
	stops[istop].SetCab(cab);
}



void Train::AddNoteToStop(int istop,int note) {
	if (istop < 0 || (unsigned)istop >= stops.size()) return;
	stops[istop].AddNote(note);
}

void Train::RemoveNoteFromStop(int istop,int note) {
	if (istop < 0 || (unsigned)istop >= stops.size()) return;
	stops[istop].RemoveNote(note);
}

void Train::SetOriginStorageTrack(string trackname)
{
	stops[0].SetStorageTrackName(trackname);
}

void Train::SetDestinationStorageTrack(string trackname)
{
	stops[stops.size()-1].SetStorageTrackName(trackname);
}

void Train::SetTransitStorageTrack(int istop,string trackname)
{
	stops[istop].SetStorageTrackName(trackname);
}




ostream & Train::Write(ostream & stream) const
{
	stream << "<Train \"" << name << "\" \"" << number << "\" "
		<< speed << " " << classnumber << " "
		<< departure << " " << startSMile << " " << notes.size() << " ";
	unsigned int i;
	for (i = 0; i <  notes.size(); i++) {
		stream << notes[i] << " ";
	}
	stream << stops.size() << endl;
	for (i = 0; i <  stops.size(); i++) {
		stops[i].Write(stream) << endl;
	}
	stream << ">";
	return stream;
}

istream & Train::Read(istream & stream,const CabNameMap cabs)
{
	char buffer[2048], ch, *p;
	int i, count;
	do {
	 	stream.get(ch);
		if (!stream) return stream;
	} while (isspace(ch));
	stream.putback(ch);
	for (i = 0,p = "<Train \""; *p != '\0'; p++,i++) {
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
	number = buffer;
	stream >> speed;
	if (!stream) return stream;
	stream >> classnumber;
	if (!stream) return stream;
	stream >> departure;
	if (!stream) return stream;
	stream >> startSMile;
	if (!stream) return stream;
	stream >> count;
	if (!stream) return stream;
	for (i = 0; i < count; i++) {
		int n;
		stream >> n;
		if (!stream) return stream;
		notes.push_back(n);
	}
	stream >> count;
	if (!stream) return stream;
	for (i = 0; i < count; i++) {
		Stop stop;
		stop.Read(stream,cabs);
		stops.push_back(stop);
	}
	do {
		stream.get(ch);
		if (!stream) return stream;
	} while (ch != '>');
	return stream;
}


ostream & Stop::Write(ostream & stream) const
{
	stream << "<Stop ";
	switch (flag) {
		case Origin: stream << "Origin "; break;
		case Terminate: stream << "Terminate "; break;
		case Transit: stream << "Transit "; break;
	}
	stream << layover << " \"" << storageTrackName << "\" ";
	stream << stationindex << " \"";
	if (cab != NULL) stream << cab->Name();
	stream << "\" " << notes.size();
	unsigned int i;
	for (i = 0; i < notes.size(); i++) {
		stream << " " << notes[i];
	}
	stream << ">";
	return stream;
}

istream & Stop::Read(istream & stream,const CabNameMap cabs)
{
	char buffer[2048], ch, *p;
	int i, count;
	do {
	 	stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Stop::Read() (while (isspace(ch))): ch = " << ch << endl;
#endif
	} while (isspace(ch));
	stream.putback(ch);
 	for (i = 0,p = "<Stop "; *p != '\0'; p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Stop::Read() (buffer1): ch = " << ch << endl;
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
		cerr << "*** Stop::Read() (while (flag): ch = " << ch << endl;
#endif
		if (isspace(ch)) break;
		*p = ch;
	}
	*p = '\0';
	if (strcmp(buffer,"Origin") == 0) {
		flag = Origin;
	} else if (strcmp(buffer,"Transit") == 0) {
		flag = Transit;
	} else if (strcmp(buffer,"Terminate") == 0) {
		flag = Terminate;
	}
#ifdef DEBUG
	cerr << "*** Stop::Read() buffer (flag) = " << buffer << endl;
#endif
	stream >> layover;
	if (!stream) return stream;
#ifdef DEBUG
	cerr << "*** Stop::Read() layover = " << smile << endl;
#endif
	do {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Stop::Read() (buffer2): ch = " << ch << endl;
#endif
	} while (ch != '"');
	for (i = 0,p = buffer;i < 2048;p++,i++) {
		stream.get(ch);
		if (!stream) return stream;
#ifdef DEBUG
		cerr << "*** Stop::Read() (storagetrack): ch = " << ch << endl;
#endif
		if (ch == '"') break;
		*p = ch;
	}
	*p = '\0';
	storageTrackName = buffer;
	stream >> stationindex;
#ifdef DEBUG
	cerr << "*** Stop::Read() buffer (cab) = " << buffer << endl;
#endif
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
	if (buffer[0] == '\0') cab = NULL;
	else {
		CabNameMap::const_iterator Cx = cabs.find(buffer);
		if (Cx == cabs.end()) {
			cab = NULL;
		} else {
			cab = Cx->second;
		}
	}
	stream >> count;
	if (!stream) return stream;
	for (i = 0; i < count; i++) {
		int n;
		stream >> n;
		if (!stream) return stream;
		notes.push_back(n);
	}
	do {
		stream.get(ch);
		if (!stream) return stream;
	} while (ch != '>');
#ifdef DEBUG
	cerr << "*** Stop::Read(): ";
	this->Write(cerr) << endl;
#endif
	return stream;
}

