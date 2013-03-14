/* 
 * ------------------------------------------------------------------
 * System_ReadTrainOrders.cc - System::ReadTrainOrders
 * Created by Robert Heller on Sat Aug 27 20:29:15 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2005/11/04 20:23:43  heller
 * Modification History: Nov 4, 2005 lockdown
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
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <System.h>
#include <PathName.h>
#include <limits.h>
#include <ctype.h>
#include "../gettext.h"

namespace FCFSupport {

//============================================================================
//
// Read train orders from the OrderFile
//
//============================================================================
bool System::ReadTrainOrders(char **outmessage)
{
	ifstream trainorderstream;
	string line, trimline, buffer;
	vector<string> vlist;
	string trainname, trainorder;
	Train *train;

	trainorderstream.open(ordersFile.FullPath().c_str());
	if (!trainorderstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,_("Error opening orders file: %s"),
	    	    ordersFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	while (SkipCommentsGets(trainorderstream,line,"",NULL)) {
	  vlist = split(trim(line),',');
	  if (vlist.size() < 2) continue;
	  trainname = trim(vlist[0]);
	  trainorder = trim(vlist[1]);
	  train = trainIndex[trainname];
	  if (train == NULL) continue;
	  train->orders.push_back(trainorder);
	}
	trainorderstream.close();

	return true;
}


}
