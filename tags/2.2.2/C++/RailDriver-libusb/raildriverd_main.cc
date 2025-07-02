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
#include <cstdarg>
using ::va_list;
#include <sys/poll.h>
#include <RaildriverServer.h>
#include <RaildriverIO.h>
#include "../gettext.h"

/** @defgroup raildriverd raildriverd
  * @brief Raildriver USB Hotplug Daemon
  *
  * @section SYNOPSIS
  * raildriverd usbdevicefile
  *
  * @section DESCRIPTION
  *
  * This is the deamon program for the Rail Driver.  It is started by the
  * USB Hotplug code. See \ref HotplugScripts for details. It should not
  * be started or stopped by hand!
  *
  * The API to use this deamon is described in <em>Model Railroad System
  * Programming Guides</em>, Part I.  User programs connect to this deamon
  * through a Tcp/Ip port.  It allows multiple programs to access a single
  * Raildriver device.  These programs can then in turn implement various
  * functionallity for the various levers, knobs, switches, and buttons on the
  * Raildriver device.
  *
  * @section PARAMETERS
  *
  * @arg usbdevicefile This is the USB device info file from the USB Hotplug
  *	 script.  This is in the form /proc/bus/usb/BBB/NNN, where BBB is the
  *	 bus number and NNN is the device number.
  * @par
  *
  * @section HotplugScripts Hotplugging scripts and setup.
  *
  * There are two ways to set up auto starting of this daemon.
  *
  *  -# Using the Hotplug daemon.
  *     Copy the raildriverd.hotplug script to /etc/hotplug/usb/ as raildriverd
  *	Use the print-usb-usermap stript to append a line to
  *	/etc/hotplug/usb.usermap.
  *  -# Using udev.
  *     Copy 90-raildriver.rules to /etc/udev/rules.d/ and copy
  *	raildriverd.udev to /lib/udev/ as raildriverd
  *
  *
  * @section AUTHOR
  * Robert Heller \<heller\@deepsoft.com\>
  */


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
	bindmrrdomain();	// Bind message catalog domain
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
	syslog(LOG_NOTICE,_("%s: error (%d): %s"),prefix,err,strerror(err));
	errno = err;
}

/*
 * Send formatted log message
 */
void logprintf(const char *format, ...)
{
	va_list ap;


//#ifdef DEBUG
//	fprintf(stderr,"*** logprintf(%s,...)\n",format);
//#else
	va_start(ap,format);
	vsyslog(LOG_NOTICE,format,ap);
	va_end(ap);
	
//#endif
}

