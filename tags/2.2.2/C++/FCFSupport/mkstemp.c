/* 
 * ------------------------------------------------------------------
 * mkstemp.c - Missing mkstemp function
 * Created by Robert Heller on Tue Jan  9 01:02:29 2007
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/10/15 19:56:33  heller
 * Modification History: variois vixes
 * Modification History:
 * Modification History: Revision 1.4  2007/10/13 19:43:31  heller
 * Modification History: C Code updates
 * Modification History:
 * Modification History: Revision 1.3  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.2  2007/01/09 06:03:17  heller
 * Modification History: Missing functions
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

#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
 
int mkstemp(char *temp)
{
	/* Quick and dirty mkstemp implementation */
	char *name = tmpnam(temp);
	if (name == NULL) return -1;
	return open(name,O_RDWR|O_CREAT);
}
