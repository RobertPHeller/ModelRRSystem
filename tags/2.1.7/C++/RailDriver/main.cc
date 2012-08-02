/* 
 * ------------------------------------------------------------------
 * main.cc - Main program for Rail Driver Daemon
 * Created by Robert Heller on Fri Jan 28 08:56:32 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2005/03/02 23:19:57  heller
 * Modification History: March 2 lock down
 * Modification History:
 * Modification History: Revision 1.2  2005/03/01 22:51:38  heller
 * Modification History: March 1 Lock down
 * Modification History:
 * Modification History: Revision 1.1  2005/02/12 22:19:23  heller
 * Modification History: Rail Driver code -- first lock down
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <pthread.h>
#include <raildriverthread.h>
#include <raildriver.tab.h>
#include <string.h>
#include <syslog.h>
#include <sys/poll.h>

#define BASEPORT 40990
#define PORTINCR    10

static void listener();
static void threaddatainit(const char *device);
static void makenewthreads(int sock, struct sockaddr_in *sockaddr);
static void checkdeadthreads();
static bool readhidevent();
static void broadcasthidevent();
static void deleteallthreads();
void log(const char* message);
void lperror(const char* prefix);
void logprintf(const char *format, ...);
static RD_Event *RailDriverEvents = NULL;

static pthread_t socketthread;

static bool running;

static void *socketthread_function(void *arg)
{
	int f = *((int *)arg);
	struct sockaddr_in from;
	static struct pollfd ufd;
	while (running) {
		int g, pstatus;
		socklen_t len = sizeof(from);
		ufd.fd = f;
		ufd.events = POLLIN;
		pstatus = poll(&ufd,1,5000);
		if (pstatus > 0) {
			g = accept(f,(struct sockaddr*)&from,&len);
			if (g > 0) {makenewthreads(g,&from);}
			if (g < 0) {
				int err = errno;
				switch (err) {
					case EINTR:
					case EAGAIN:
					/*case EWOULDBLOCK:*/
						break;
					default:
						lperror("accept");
				}	
			}
		} else if (pstatus < 0) {
			int err = errno;
			if (err != EINTR) {
				lperror("poll");
			}
		}
		pthread_testcancel();
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	pid_t childpid, mypid;
	FILE *pidfile;
	char *p;
	static char pidfilename[256];

	childpid = fork();
	if (childpid != 0) exit(errno);

	p = strrchr(argv[0],'/');
	if (p == NULL) p = argv[0];
	sprintf(pidfilename,"/var/run/%s.pid",p);
	pidfile = fopen(pidfilename,"w");
	if (pidfile != NULL) {
		mypid = getpid();
		fprintf(pidfile,"%d\n",mypid);
		fclose(pidfile);
	}	
	openlog("raildriverd",LOG_PID,LOG_DAEMON);
	//log(argv[1]);
	threaddatainit(argv[1]);
	listener();
	log("raildriverd shutdown\n");
	closelog();
	return (0);
}

static void shutdown(int sig)
{
	running = false;
}

static void listener()
{
	int f;
	int port/*, binderror*/;
	struct sockaddr_in sin;
	struct hostent *hostentptr;
	static char localnode[256];
	static char message[1024];
	void *result;
	

	sprintf(message,"raildriverd started\n");
	log(message);
	if ((f = socket(AF_INET,SOCK_STREAM,0)) < 0) {
		int err = errno;
		lperror("socket");
		exit(err);
	}
	if (fcntl(f,F_SETFL,O_NONBLOCK) < 0) {
		int err = errno;
		lperror("fcntl");
		exit(err);
	}
	port = BASEPORT-PORTINCR;
	gethostname(localnode,sizeof(localnode));
	hostentptr = gethostbyname(localnode);
	if (hostentptr == NULL) {
		int err = errno;
		lperror("gethostbyname");
		exit(err);
	}
	sin.sin_addr.s_addr = htonl(INADDR_ANY);
	while (true) {
		port += PORTINCR;
		sin.sin_port = htons(port);
		sin.sin_family = AF_INET;

		if (bind(f,(const struct sockaddr*)&sin,sizeof(sin)) < 0) {
			int err = errno;
			if (err != EINVAL) {
				lperror("bind");
				exit(err);
			}
		} else {
			break;
		}
	}
	listen(f,5);

	signal(SIGTERM,shutdown);
	
	running = true;
	pthread_create(&socketthread,NULL,socketthread_function,(void *)&f);
	while (running) {
		if (readhidevent()) {
			broadcasthidevent();
		}
		checkdeadthreads();
	}
	pthread_join(socketthread,&result);
	deleteallthreads();
}

static void threaddatainit(const char *device)
{
	RailDriverEvents = new RD_Event(device);
}

static void makenewthreads(int sock, struct sockaddr_in *sockaddr)
{
	//log("makenewthreads() start\n");
	RaildriverParser *newthread = new RaildriverParser(sock,sockaddr,
							   RailDriverEvents);
	if (newthread->KillMe()) delete newthread;
	//log("makenewthreads() end\n");
}

static void checkdeadthreads()
{
	RD_Threads *ptr = NULL, *nextptr = NULL;
	for (ptr = RD_Threads::First(); ptr != NULL;ptr = nextptr) {
		nextptr = ptr->Next();
		if (ptr->KillMe()) {
			delete ptr;
			nextptr = RD_Threads::First();
		}
	}
	
}

static void deleteallthreads()
{
	RD_Threads *ptr = NULL;
	while ((ptr = RD_Threads::First()) != NULL) {
		delete ptr;
	}
}

static bool readhidevent()
{
#ifdef DEBUG
	log("*** readhidevent()\n");
#endif
	bool result = RailDriverEvents->ReadInputs();
#ifdef DEBUG
	logprintf("*** readhidevent results %d\n",result);
#endif
	return result;
}

static void broadcasthidevent()
{
#ifdef DEBUG
	log("*** broadcasthidevent()\n");
#endif
	RailDriverEvents->BroadcastEvents();
}

void log(const char* message)
{
	syslog(LOG_NOTICE,message);
}

#define BUFFERSIZE 1024

void lperror(const char* prefix)
{
	int err = errno;
	syslog(LOG_NOTICE,"%s: error (%d): %s",prefix,err,strerror(err));
	errno = err;
}

#include <stdarg.h>

void logprintf(const char *format, ...)
{
	va_list ap;

	//fprintf(stderr,"*** logprintf(%s,...)\n",format);
	va_start(ap,format);
	vsyslog(LOG_NOTICE,format,ap);
	va_end(ap);
}
