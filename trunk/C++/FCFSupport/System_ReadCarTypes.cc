/* 
 * ------------------------------------------------------------------
 * System_ReadCarTypes.cc - System::ReadCarTypes
 * Created by Robert Heller on Sat Aug 27 20:30:30 2005
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
// Read car types from the TypesFile
//
//============================================================================
bool System::ReadCarTypes(char **outmessage)
{
	ifstream cartypesstream;
	int Gx, CarTypeCount, CarGroupCount;
	char symbol, group;
	string type, comment;
	string line;
	vector<string> vlist;

	for (Gx = 0;Gx < CarType::MaxCarTypes;Gx++) carTypesOrder[Gx] = ',';
	for (Gx = 0;Gx < CarGroup::MaxCarGroup; Gx++) carGroups[Gx] = NULL;
	
	cartypesstream.open(carTypesFile.FullPath().c_str());
	if (!cartypesstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,_("Error opening car types file: %s"),
		    carTypesFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	return false;
	}
	for (CarTypeCount = 0; CarTypeCount < CarType::NumberOfCarTypes;CarTypeCount++) {
	  sprintf(messageBuffer,_("Error reading %s -- short file (CARTYPES)!"),
		  carTypesFile.FullPath().c_str());
	  if (!SkipCommentsGets(cartypesstream,line,messageBuffer,outmessage)) return false;
	  vlist = split(trim(line),',');
	  if (vlist.size() != 5) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,_("Syntax error in cartypes (%1$s) at %2$s"),
		      carTypesFile.FullPath().c_str(),line.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  symbol = vlist[0][0];
	  group  = vlist[1][0];
	  type   = vlist[2];
	  //pad  = vlist[3];
	  comment= vlist[4];
	  carTypesOrder[CarTypeCount] = symbol;
	  carTypes[symbol] = new CarType(comment.c_str(),type.c_str(),group);
	}
	for (CarGroupCount = 0; CarGroupCount < CarGroup::MaxCarGroup; CarGroupCount++) {
#ifdef DEBUG
	  cerr << "System::ReadCarTypes: CarGroupCount = " << CarGroupCount << endl;
#endif
	  if (!SkipCommentsGets(cartypesstream,line,"",NULL)) break;
#ifdef DEBUG
	  cerr << "System::ReadCarTypes: line = \"" << line << "\"" << endl;
#endif
	  vlist = split(trim(line),',');
	  if (vlist.size() < 2) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,_("Syntax error in cartypes (%1$s) at %2$s"),
		      carTypesFile.FullPath().c_str(),line.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  symbol  = vlist[0][0];
	  comment = vlist[1];
	  //pad   = vlist[2];
	  carGroups[CarGroupCount] = new CarGroup(symbol,comment.c_str());
	}	
	cartypesstream.close();
	return true;
}


}
