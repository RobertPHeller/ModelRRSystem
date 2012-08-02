/* 
 * ------------------------------------------------------------------
 * raildriverd_main.cc - Main program
 * Created by Robert Heller on Tue Mar 27 16:55:59 2007
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
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

#include <stdio.h>
#include <errno.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <string.h>
#include <sys/time.h>
#include <syslog.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdarg.h>
#include <sys/poll.h>
#include <RaildriverServer.h>
#include <RaildriverIO.h>

/*
 * Log functions, defined below.
 */
void log(const char* message);
void lperror(const char* prefix);
void logprintf(const char *format, ...);

/*
 * Main program.
 *  1) Initialize everything.
 *  2) Enter event loop
 *  3) When event loop exits, shutdown everything.
 */
int main(int argc,char *argv[]) {
	RaildriverServer::Initialize(argc,argv);
	RaildriverServer::EventLoop();
	RaildriverServer::Shutdown();
}

/*
 * Send a log message
 */
void log(const char* message)
{
	syslog(LOG_NOTICE,message);
}

/*
 * Log and error message ala perror().
 */
void lperror(const char* prefix)
{
	int err = errno;
	syslog(LOG_NOTICE,"%s: error (%d): %s",prefix,err,strerror(err));
	errno = err;
}

/*
 * Send formatted log message
 */
void logprintf(const char *format, ...)
{
	va_list ap;

	//fprintf(stderr,"*** logprintf(%s,...)\n",format);
	va_start(ap,format);
	vsyslog(LOG_NOTICE,format,ap);
	va_end(ap);
}

