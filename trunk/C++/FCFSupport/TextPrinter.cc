/* 
 * ------------------------------------------------------------------
 * TextPrinter.cc - Text Printer
 * Created by Robert Heller on Sun Sep 18 11:58:06 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/05 05:52:08  heller
 * Modification History: Upgraded for G++ 3.2
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

#include <TextPrinter.h>
#include "../gettext.h"

static char Id[] = "$Id$";

namespace FCFSupport {

TextPrinterDevice::TextPrinterDevice(const string filename,const string title,
				     PageSize pageSize_,char **outmessage)
{
	pageSize = pageSize_;
	if (filename != "") OpenPrinter(filename,pageSize_,outmessage);
}

bool TextPrinterDevice::OpenPrinter(const string filename,PageSize pageSize_,char **outmessage)
{
	static char messageBuffer[2048];
	isOpenP = false;
	printerStream.open(filename.c_str());
	if (!printerStream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,
		    _("Error opening %s for output (TextPrinterDevice)"),
		    filename.c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	pageSize = pageSize_;
	isOpenP = true;
	currentColumn = 0;
	return true;
}

bool TextPrinterDevice::ClosePrinter(char **outmessage)
{
	if (!isOpenP) return true;
	printerStream.close();
	isOpenP = false;
	return true;
}

bool TextPrinterDevice::NewPage(const string heading)
{
	if (!isOpenP) return false;
	printerStream << endl << "\f";
	PutLine(heading);
	return true;
}

bool TextPrinterDevice::PutLine(const string line)
{
	string::size_type nl, lastnl = string::npos;
	if (!isOpenP) return false;
	while ((nl = line.find('\n',lastnl+1)) != string::npos) {
		printerStream << line.substr(lastnl+1,nl-lastnl-1) << endl;
		lastnl = nl;
	}
	if (lastnl+1 < line.length()) {
		printerStream << line.substr(lastnl+1) << endl;
	} else printerStream << endl;
	currentColumn = 0;
	return true;
}

bool TextPrinterDevice::Put(const string text)
{
	if (!isOpenP) return false;
	string::size_type nl, lastnl = string::npos;
	if (!isOpenP) return false;
	while ((nl = text.find('\n',lastnl+1)) != string::npos) {
		printerStream << text.substr(lastnl+1,nl-lastnl-1) << endl;
		lastnl = nl;
		currentColumn = 0;
	}
	if (lastnl+1 < text.length()) {
		printerStream << text.substr(lastnl+1);
		currentColumn += text.substr(lastnl+1).length();
	}		
	return true;
}

bool TextPrinterDevice::Tab(int column)
{
	if (!isOpenP) return false;
	while (currentColumn < column) Put(" ");
	return true;
}

TextPrinterDevice::~TextPrinterDevice()
{
	ClosePrinter(NULL);
}

}
