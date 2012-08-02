/* 
 * ------------------------------------------------------------------
 * asctime_r.c - Missing asctime_r function
 * Created by Robert Heller on Tue Jan  9 01:01:54 2007
 * ------------------------------------------------------------------
 * Modification History: $Log$
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
 *     Copyright (C) 2007  Robert Heller D/B/A Deepwoods Software
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

#include <time.h>

/*
 * The code below was lifted from the man pages...
 */

char *asctime_r(const struct tm *timeptr, char *buf)
{
	static char wday_name[7][3] = {
            "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
	};
	static char mon_name[12][3] = {
	    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
	    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	};

	sprintf(buf, "%.3s %.3s%3d %.2d:%.2d:%.2d %d\n",
	     wday_name[timeptr->tm_wday],
	     mon_name[timeptr->tm_mon],
	     timeptr->tm_mday, timeptr->tm_hour,
	     timeptr->tm_min, timeptr->tm_sec,1900 + timeptr->tm_year);
	return buf;
}
