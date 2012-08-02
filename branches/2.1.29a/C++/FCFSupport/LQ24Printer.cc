/* 
 * ------------------------------------------------------------------
 * LQ24Printer.cc - Epson LQ 24 Printer
 * Created by Robert Heller on Sun Sep 18 12:00:02 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/04/19 17:23:20  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.3  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 05:52:08  heller
 * Modification History: Upgraded for G++ 3.2
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

#include <LQ24Printer.h>
#include "../gettext.h"

static char Id[] = "$Id$";

namespace FCFSupport {

LQ24PrinterDevice::LQ24PrinterDevice(const string filename,const string title,
				     PageSize pageSize_,char **outmessage)
{
	pageSize = pageSize_;
	if (filename != "") OpenPrinter(filename,pageSize_,outmessage);
}

bool LQ24PrinterDevice::OpenPrinter(const string filename,PageSize pageSize_,char **outmessage)
{
	static char messageBuffer[2048];
	isOpenP = false;
	printerStream.open(filename.c_str());
	if (!printerStream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,
		    _("Error opening %s for output (LQ24PrinterDevice)"),
		    filename.c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	printerStream << (char) DC2 << (char) ESC << "W0";
	currentSpacing = One;
	oneColumnWidthFraction = 1.0;
	printerStream << (char) ESC << 'F';
	currentWeight = Normal;
	printerStream << (char) ESC << '5';
	currentSlant = Roman;
	pageSize = pageSize_;
	isOpenP = true;
	currentColumn = 0;
	currentColumnFraction = 0;
	return true;
}

bool LQ24PrinterDevice::ClosePrinter(char **outmessage)
{
	if (!isOpenP) return true;
	printerStream.close();
	isOpenP = false;
	return true;
}

bool LQ24PrinterDevice::NewPage(const string heading)
{
	if (!isOpenP) return false;
	printerStream << endl << (char) FF;
	PutLine(heading);
	return true;
}

bool LQ24PrinterDevice::PutLine(const string line)
{
	string::size_type nl, lastnl = string::npos;
	if (!isOpenP) return false;
	while ((nl = line.find('\n',lastnl+1)) != string::npos) {
		printerStream << line.substr(lastnl+1,nl-lastnl-1) << endl;
		lastnl = nl;
	}
	if ((lastnl+1) < line.length()) {
		printerStream << line.substr(lastnl+1) << endl;
	} else printerStream << endl;
	currentColumn = 0;
	currentColumnFraction = 0;
	return true;
}

bool LQ24PrinterDevice::Put(const string text)
{
	string::size_type nl, lastnl = string::npos;
	if (!isOpenP) return false;
	while ((nl = text.find('\n',lastnl+1)) != string::npos) {
		printerStream << text.substr(lastnl+1,nl-lastnl-1) << endl;
		lastnl = nl;
		currentColumn = 0;
		currentColumnFraction = 0;
	}
	if ((lastnl+1) < text.length()) {
		printerStream << text.substr(lastnl+1);
		currentColumnFraction += (text.substr(lastnl+1).length() * oneColumnWidthFraction);
		currentColumn = (int) currentColumnFraction;
#ifdef DEBUG
		cerr << "*** LQ24PrinterDevice::Put: currentColumnFraction = " << currentColumnFraction << ", currentColumn = " << currentColumn << endl;
#endif
	}		
	return true;
}

bool LQ24PrinterDevice::Tab(int column)
{
	if (!isOpenP) return false;
	while (currentColumn < column) Put(" ");
	return true;
}

bool LQ24PrinterDevice::SetTypeSpacing(TypeSpacing spacing)
{
	if (!isOpenP) return false;
	if (currentSpacing == spacing) return true;
	switch (currentSpacing) {
		case One: break;
		case Half: printerStream << (char) DC2; break;
		case Double: printerStream << (char) ESC << "W0"; break;
	}
	currentSpacing = spacing;
	switch (currentSpacing) {
		case One: oneColumnWidthFraction = 1.0; break;
		case Half: oneColumnWidthFraction = 0.6;
		      printerStream << (char) SI; 
		      break;
		case Double: oneColumnWidthFraction = 2.0;
			printerStream << (char) ESC << "W1";
			break;
	}
	return true;
}

bool LQ24PrinterDevice::SetTypeWeight(TypeWeight weight)
{
	if (!isOpenP) return false;
	if (currentWeight == weight) return true;
	currentWeight = weight;
	switch (weight) {
		case Normal: printerStream << (char) ESC << 'F'; break;
		case Bold:   printerStream << (char) ESC << 'E'; break;
	}
	return true;
}

bool LQ24PrinterDevice::SetTypeSlant(TypeSlant slant)
{
	if (!isOpenP) return false;
	if (currentSlant == slant) return true;
	currentSlant = slant;
	switch (slant) {
		case Roman:  printerStream << (char) ESC << '5'; break;
		case Italic: printerStream << (char) ESC << '4'; break;
	}
	return true;
}





LQ24PrinterDevice::~LQ24PrinterDevice()
{
	ClosePrinter(NULL);
}


}
