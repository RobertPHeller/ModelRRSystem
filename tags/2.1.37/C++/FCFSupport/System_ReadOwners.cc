/* 
 * ------------------------------------------------------------------
 * System_ReadOwners.cc - System::ReadOwners
 * Created by Robert Heller on Sat Aug 27 20:31:42 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2005/11/04 20:24:51  heller
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

bool System::ReadOwners(char **outmessage)
{
	ifstream ownersstream;
	string initials, name, comment, line;
	vector<string> vlist;
	int TotalOwners,Ox;

	ownersstream.open(ownersFile.FullPath().c_str());
	if (!ownersstream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,_("Error opening owners file: %s"),
		    ownersFile.FullPath().c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	return false;
	}
	sprintf(messageBuffer,_("Error reading owners file: %s"),
		ownersFile.FullPath().c_str());
	if (!SkipCommentsGets(ownersstream,line,messageBuffer,outmessage)) return false;
	sprintf(messageBuffer,_("TotalOwners number syntax error in %1$s at %2$s"),
		ownersFile.FullPath().c_str(),line.c_str());
	if (!StringToInt(trim(line),TotalOwners,messageBuffer,outmessage)) return false;
	for (Ox = 0; Ox < TotalOwners; Ox++) {
	  if (!SkipCommentsGets(ownersstream,line,"",NULL)) break;
	  vlist = split(trim(line),',');
	  if (vlist.size() < 3) {
	    if (outmessage != NULL) {
	      sprintf(messageBuffer,_("Syntax error in owners file (%1$s) at %2$s"),
		      ownersFile.FullPath().c_str(),line.c_str());
	      *outmessage = new char[strlen(messageBuffer)+1];
	      strcpy(*outmessage,messageBuffer);
	    }
	    return false;
	  }
	  initials = trim(vlist[0]);
	  name     = trim(vlist[1]);
	  comment  = trim(vlist[2]);
	  owners[initials] = new Owner(initials.c_str(),name.c_str(),
					comment.c_str());
	}
	ownersstream.close();
	return true;
}


}
