/* 
 * ------------------------------------------------------------------
 * RaildriverServer.cc - Rail driver server class implementation
 * Created by Robert Heller on Tue Mar 27 14:58:34 2007
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
#include <sys/poll.h>
#include <raildriver.tab.h>
#include <RaildriverServer.h>
#include <RaildriverIO.h>
#define BASEPORT  40990
#define PORTINCR    10

/*
 * Log functions, defined in main program.
 */
extern void log(const char* message);
extern void lperror(const char* prefix);
extern void logprintf(const char *format, ...);

/*
 * Static member initializations
 */
ServerList RaildriverServer::activeServers;
RaildriverIO * RaildriverServer::RailDriver = NULL;
bool RaildriverServer::terminate = false;
int RaildriverServer::listenSock = 0;

// Error output function.  Send error message to client.
// The response code is presumed to be included in the format spec.
void RaildriverServer::ErrFormat(const char *format, ...)
{
	size_t rlen;
	va_list ap;

	/*
	 * Format string
	 */
	va_start(ap,format);
	vsnprintf(writebuffer,sizeof(writebuffer)-1,format,ap);
	va_end(ap);
	/*
	 * Send to client
	 */
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	if (rlen < strlen(writebuffer)) {
		lperror("RaildriverServer::reader:send");
		close(sockfd);
		sockfd = 0;
	}
}

/*
 * Send Event data. For all on mask bits, set the corresponding values
 */
void RaildriverServer::SendEventData(RaildriverIO::Eventmask_bits sendmask)
{
	size_t len, wlen;
	char /* *ptr,*/ comma, *p;
	RaildriverIO::Eventmask_bits testMask;
	RaildriverIO::Eventcodes eventCode;
	
	// Start with response code...
	strcpy(writebuffer,"202 Events: ");
	len = strlen(writebuffer);
	comma = '\0';
#ifdef DEBUG
	logprintf("*** SendEventData(0x%08x)\n",(unsigned long)sendmask);
#endif
	/* Loop over event mask bits / event codes */
	for (testMask = RaildriverIO::REVERSER_M, eventCode=RaildriverIO::REVERSER;
	     eventCode <= RaildriverIO::DIGITAL6; 
	     testMask = (RaildriverIO::Eventmask_bits)(testMask << 1),
		eventCode = (RaildriverIO::Eventcodes)(eventCode + 1)) {
#ifdef DEBUG
		logprintf("*** SendEventData: testMask = 0x%08x, eventCode = %d\n",(unsigned long)testMask,eventCode);
		logprintf("*** SendEventData: (testMask & sendmask) = 0x%08x\n",(testMask & sendmask));
		logprintf("*** SendEventData: writebuffer = %s\n",writebuffer);
		logprintf("*** SendEventData: comma = %d\n",comma);
#endif
		if ((testMask & sendmask) != 0) { // Check for selected mask bit
			memset(workbuffer,'\0',sizeof(workbuffer));
			p = workbuffer;
			if (comma != '\0') *p++ = comma;
#ifdef DEBUG
			logprintf("*** SendEventData: workbuffer = '%s'\n",workbuffer);
#endif
			// Switch by event code
			switch (eventCode) {
				case RaildriverIO::REVERSER:
					sprintf(p,"REVERSER=%d",
						RailDriver->GetReverser());
					comma = ',';
					break;
				case RaildriverIO::THROTTLE:
					sprintf(p,"THROTTLE=%d",
						RailDriver->GetThrottle());
					comma = ',';
					break;
				case RaildriverIO::AUTOBRAKE:
					sprintf(p,"AUTOBRAKE=%d",
						RailDriver->GetAutoBrake());
					comma = ',';
					break;
				case RaildriverIO::INDEPENDBRK:
					sprintf(p,"INDEPENDBRK=%d",
						RailDriver->GetIndependBrake());
					comma = ',';
					break;
				case RaildriverIO::BAILOFF:
					sprintf(p,"BAILOFF=%d",
						RailDriver->GetBailOff());
					comma = ',';
					break;
				case RaildriverIO::HEADLIGHT:
					sprintf(p,"HEADLIGHT=%d",
						RailDriver->GetHeadlight());
					comma = ',';
					break;
				case RaildriverIO::WIPER:
					sprintf(p,"WIPER=%d",
						RailDriver->GetWiper());
					comma = ',';
					break;
				case RaildriverIO::DIGITAL1:
					strcpy(p,"DIGITAL1=("); 
					p += strlen(p);
					comma = '\0';
					if (RailDriver->GetBlueButton1()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB1");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton2()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB2");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton3()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB3");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton4()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB4");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton5()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB5");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton6()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB6");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton7()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB7");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton8()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB8");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RaildriverIO::DIGITAL2:
					strcpy(p,"DIGITAL2=(");
					p += strlen(p);
					comma = '\0';
					if (RailDriver->GetBlueButton9()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB9");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton10()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB10");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton11()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB11");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton12()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB12");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton13()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB13");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton14()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB14");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton15()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB15");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton16()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB16");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RaildriverIO::DIGITAL3:
					strcpy(p,"DIGITAL3=(");
					p += strlen(p);
					comma = '\0';
					if (RailDriver->GetBlueButton17()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB17");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton18()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB18");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton19()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB19");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton20()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB20");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton21()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB21");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton22()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB22");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton23()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB23");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton24()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB24");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RaildriverIO::DIGITAL4:
					strcpy(p,"DIGITAL4=(");
					p += strlen(p);
					comma = '\0';
					if (RailDriver->GetBlueButton25()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB25");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton26()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB26");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton27()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB27");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBlueButton28()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB28");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetZoomUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Zoom Up");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetZoopDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Zoom Down");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetPanUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Up");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetPanRight()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Right");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RaildriverIO::DIGITAL5:
					strcpy(p,"DIGITAL5=(");
					p += strlen(p);
					comma = '\0';
					if (RailDriver->GetPanDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Down");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetPanLeft()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Left");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetRangeUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Range Up");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetRangeDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Range Down");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetEBrakeUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Emergency Brake Up");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetEBrakeDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Emergency Brake Down");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetAlert()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Alert");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetSand()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Sand");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RaildriverIO::DIGITAL6:
					strcpy(p,"DIGITAL6=(");
					p += strlen(p);
					comma = '\0';
					if (RailDriver->GetPantograph()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pantograph");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetBell()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Bell");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetWhistleUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Whistle Up");
						p += strlen(p);
						comma = ';';
					}
					if (RailDriver->GetWhistleDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Whistle Down");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				default:	/* supress compiler warning */
					break;
			}
			workbuffer[sizeof(workbuffer)-1] = '\0';
#ifdef DEBUG
			logprintf("*** SendEventData: workbuffer = '%s'\n",workbuffer);
#endif
			// Write buffer full? Write it out/
			if (len+strlen(workbuffer) > sizeof(writebuffer)-2) {
				strcat(writebuffer,"\n");
				wlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
				if (wlen < strlen(writebuffer)) {
					lperror("RaildriverServer::writer:send");
					close(sockfd);
					sockfd = 0;
					break;
				}
				strcpy(writebuffer,"202 Events: ");
				len = strlen(writebuffer);
			}
			// Append work buffer to write buffer
			strcat(writebuffer,workbuffer);
			len = strlen(writebuffer);
		}
	}
	// Flush anything left.
	if (sockfd != 0) {
		strcat(writebuffer,"\n");
		wlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
		if (wlen < strlen(writebuffer)) {
			lperror("RaildriverServer::writer:send");
			close(sockfd);
			sockfd = 0;
		}			
	}
}


// Handle Exit command -- close connection (schedule our death).
void RaildriverServer::DoExit(void)
{
	size_t wlen;	// Write length.

#ifdef DEBUG
	log("RaildriverServer::DoExit(void)");
	logprintf("*** RaildriverServer::DoExit(void): listenSock = %d, sockfd = %d\n",listenSock,sockfd);
#endif
	strcpy(writebuffer,"299 GOODBYE\n");
	wlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	if (wlen < strlen(writebuffer)) {
		lperror("RaildriverServer::reader:send");
	}
	// And schedule our death.
	close(sockfd);
	sockfd = 0;
}

// Clear event mask.
void RaildriverServer::ClearMask(void)
{
	size_t rlen;

#ifdef DEBUG
	log("RaildriverServer::ClearMask(void)");
#endif
	// Clear mask.
	event_mask = RaildriverIO::NONE_M;
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	if (rlen < strlen(writebuffer)) {
		lperror("RaildriverServer::reader:send");
		close(sockfd);
		sockfd = 0;
	}
}

// Add Mask bits.
void RaildriverServer::AddMask(RaildriverIO::Eventmask_bits mask)
{
	size_t rlen;

#ifdef DEBUG
	log("RaildriverServer::AddMask(RaildriverIO::Eventmask_bits mask)");
#endif
	// Or in mask bits.
	event_mask = (RaildriverIO::Eventmask_bits) (mask | event_mask);
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	if (rlen < strlen(writebuffer)) {
		lperror("RaildriverServer::reader:send");
		close(sockfd);
		sockfd = 0;
	}
}


// Poll values command -- punt to send event data method.
void RaildriverServer::PollValues(RaildriverIO::Eventmask_bits mask)
{
#ifdef DEBUG
	log("RaildriverServer::PollValues(RaildriverIO::Eventmask_bits mask)");
#endif
	SendEventData(mask);
}

// Display LEDs.
void RaildriverServer::LedDisplay(char const * lstr)
{
	size_t rlen;

#ifdef DEBUG
	log("RaildriverServer::LedDisplay(char const * lstr)");
	log(lstr);
#endif
	// Display LEDs.
	RailDriver->SetLEDS(lstr);
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	if (rlen < strlen(writebuffer)) {
		lperror("RaildriverServer::reader:send");
		close(sockfd);
		sockfd = 0;
	}
}

// Speaker On.
void RaildriverServer::SpeakerOn(void)
{
	size_t rlen;

#ifdef DEBUG
	log("RaildriverServer::SpeakerOn(void)");
#endif
	// Turn speaker on.
	RailDriver->SpeakerOn();
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	if (rlen < strlen(writebuffer)) {
		lperror("RaildriverServer::reader:send");
		close(sockfd);
		sockfd = 0;
	}
}

// Speaker Off.
void RaildriverServer::SpeakerOff(void)
{
	size_t rlen;

#ifdef DEBUG
	log("RaildriverServer::SpeakerOff(void)");
#endif
	// Turn speaker off.
	RailDriver->SpeakerOff();
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	if (rlen < strlen(writebuffer)) {
		lperror("RaildriverServer::reader:send");
		close(sockfd);
		sockfd = 0;
	}
}


// Constructor -- set up all system resources needed for a new client connection
RaildriverServer::RaildriverServer(int sock, struct sockaddr_in *sockaddr,
			RaildriverParser *p)
{
#ifdef DEBUG
	logprintf("*** RaildriverServer::RaildriverServer(): this = 0x%08x, p = 0x%08x\n",(long)this,(long)p);
#endif
	sockfd = sock;		// Save our socket file descriptor.
	remotesockaddr = *sockaddr;	// And our client address.
	parser = p;		// And our parser.
	rblen=0;		// Setup our read buffer (empty)
	rboff=0;		// Offset into read buffer
	event_mask = RaildriverIO::NONE_M;	/* Initialize our mask. */
#ifdef DEBUG
	sprintf(writebuffer,"*** RaildriverServer::RaildriverServer(): remotesockaddr.sin_addr.s_addr = 0x%08x\n",remotesockaddr.sin_addr.s_addr);
	log(writebuffer);
#endif
	// Log out connection.
	sprintf(writebuffer,"Connection from %d.%d.%d.%d:%d accepted\n",
		((remotesockaddr.sin_addr.s_addr) >>  0) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >>  8) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 16) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 24) & 0x0ff,
		remotesockaddr.sin_port);
	log(writebuffer);
	// Add ourselves to the server list list.
	activeServers.push_back(this);
}


// Destructor -- free up all system resources.
RaildriverServer::~RaildriverServer()
{
#ifdef DEBUG
	logprintf("*** RaildriverServer::~RaildriverServer(): this = 0x%08x\n",(long)this);
#endif
	if (sockfd != 0) {
		close(sockfd);	// Close our socket.
	}
#ifdef DEBUG
	log("*** RaildriverServer::~RaildriverServer(), closed socket\n");
#endif
	// Take us off the active list.
	activeServers.remove(this);
#ifdef DEBUG
	log("*** RaildriverServer::~RaildriverServer(), removed from active list\n");
#endif
	// Log us closed.
	sprintf(writebuffer,"Connection from %d.%d.%d.%d:%d closed\n",
		((remotesockaddr.sin_addr.s_addr) >>  0) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >>  8) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 16) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 24) & 0x0ff,
		remotesockaddr.sin_port);
	log(writebuffer);
}


/*
 * Check for any input from the client and  then parse & process it.
 */
bool RaildriverServer::CheckEvent()
{
	bool done;
	struct pollfd pfds;
	int presult; size_t rlen;

	// Poll socket
	pfds.fd = sockfd;
	pfds.events = POLLIN;
	pfds.revents = 0;
	presult = poll(&pfds,1,10);
	// Data available?
	if (presult > 0) {
		// Read first line.
		if (Read()) {
			do {
				// Parse & process line
				parser->ResetPtr(linebuffer);
				if (parser->yyparse() != 0) {
					strcpy(writebuffer,"502 Parse error\n");
					rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
					if (rlen < strlen(writebuffer)) {
						lperror("RaildriverServer::CheckEvent(): send");
						close(sockfd);
						sockfd = 0;
						return false;
					}
				}
				// Check for more lines.
				done = rboff >= rblen;
				if (!done) {if (!Read()) return false;}
			} while (!done);
			return true;
		} else return false;
	} else if (presult == 0) return false;	// No data available (timeout).
	else {	// Some sort of error from Poll()
		int err = errno;
		if (err != EINTR) {
			lperror("RaildriverServer::CheckEvent(): poll");
			close(sockfd);
			sockfd = 0;
			return false;
		}
	}
	return true;
}

/*
 * Client read line.  Grab the next logical line from the read buffer.
 */
bool RaildriverServer::Read()
{
	char *p,*q;

	// If we are dead, just return false.  Dead is dead.
	if (sockfd == 0) return false;
#ifdef DEBUG
	logprintf("*** RaildriverServer::Read() (entry):  rboff = %d, rblen = %d\n",rboff,rblen);
#endif
	// Scan from the read buffer offset until we are done.
	for (q = &readbuffer[rboff], p=linebuffer; ; q++, p++, rboff++) {
		// If read buffer is exahusted, get more bytes from the client.
		if (rboff >= rblen) {
			int rlen = recv(sockfd,readbuffer,sizeof(readbuffer)-2,MSG_NOSIGNAL);
			// Check for errors.
			if (rlen <= 0 && errno > 0) {
				lperror("RaildriverServer::Read()");
				close(sockfd);
				sockfd = 0;
				return false;
			}
			// Insure an EOS.
			readbuffer[rlen] = '\0';
			rboff = 0;
			rblen = rlen;
			q = readbuffer;
#ifdef DEBUG
			logprintf("*** RaildriverServer::Read() (recv):  rboff = %d, rblen = %d\n",rboff,rblen);
#endif
		}
		// CR? Store NL
		if (*q == '\r') {
			*p = '\n';
		// NL? We're done. Mark EOS and return.
		} else if (*q == '\n') {
			*p = '\0';
			rboff++;
#ifdef DEBUG
			logprintf("*** RaildriverServer::Read(): linebuffer = '%s'\n",linebuffer);
#endif
			return true;
		// Else just copy the byte and continue.
		} else {*p = *q;}
	}
}

/***************************************************************************/
/* Static members -- Event loop setup / shutdown and the Event Loop itself */
/***************************************************************************/

/*
 * Global (static) listener.  Check for new client connections.
 */
bool RaildriverServer::ListenerEvent()
{
	int g, pstatus;
	struct sockaddr_in from;
	static struct pollfd ufd;

	socklen_t len = sizeof(from);
	// Poll for a connection.
	ufd.fd = listenSock;
	ufd.events = POLLIN;
	pstatus = poll(&ufd,1,10);
	if (pstatus > 0) {
		// Someone wants to talk -- get his/her info.
		g = accept(listenSock,(struct sockaddr*)&from,&len);
#ifdef DEBUG
		logprintf("*** RaildriverServer::ListenerEvent(): listenSock = %d, g = %d\n",listenSock,g);
#endif
		// Good connection?
		if (g > 0) {
			/* Yes, create a parser/server instance for the
			 * connection.
			 */
			new RaildriverParser(g,&from);
			return true;
		}
		// Error handling... (accept)
		if (g < 0) {
			int err = errno;
			switch (err) {
				case EINTR:
				/*case EWOULDBLOCK:*/
					break;
				default:
					lperror("accept");
			}
		}
		return true;
	// More error handling... (poll)
	} else if (pstatus < 0) {
		int err = errno;
		if (err != EINTR) {
			lperror("poll");
		}
		return true;
	}
	return false;
				                                        
}


/*
 * System initialization.
 * 1) Fade into the background
 * 2) Store our PID
 * 3) Open log file.
 * 4) Create listener socket.
 * 5) Connect to Rail Driver console.
 * 6) Establish signal handler.
 */
bool RaildriverServer::Initialize(int argc, char *argv[])
{
	pid_t childpid, mypid;
	FILE *pidfile;
	char *p;
	static char pidfilename[256];
	int port/*, binderror*/;
	struct sockaddr_in sin;
	struct hostent *hostentptr;
	static char localnode[256];
	static char message[1024];
	int status;
	
	// Fade into the background...
	childpid = fork();
	if (childpid != 0) exit(errno);

	// Store our PID
	p = strrchr(argv[0],'/');
	if (p == NULL) p = argv[0];
	sprintf(pidfilename,"/var/run/%s.pid",p);
	pidfile = fopen(pidfilename,"w");
	if (pidfile != NULL) {
		mypid = getpid();
		fprintf(pidfile,"%d\n",mypid);
		fclose(pidfile);
	}
	// Open Log file
	openlog("raildriverd",LOG_PID,LOG_DAEMON);
	// Log ourselves
	sprintf(message,"raildriverd starting\n");
	log(message);
	// Create listener
	if ((listenSock = socket(AF_INET,SOCK_STREAM,0)) < 0) {
		int err = errno;
		lperror("socket");
		exit(err);
	}
	if (fcntl(listenSock,F_SETFL,O_NONBLOCK) < 0) {
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
	status = 1;
	(void) setsockopt(listenSock, SOL_SOCKET, SO_REUSEADDR,
			  (char *) &status, sizeof(status));
	sin.sin_addr.s_addr = htonl(INADDR_ANY);
	while (true) {
		port += PORTINCR;
		sin.sin_port = htons(port);
		sin.sin_family = AF_INET;

		if (bind(listenSock,(const struct sockaddr*)&sin,sizeof(sin)) < 0) {
			int err = errno;
			if (err != EINVAL) {
				lperror("bind");
				exit(err);
			}
		} else {
			break;
		}
	}
	listen(listenSock,SOMAXCONN);
	// Connect to RailDriver
	RailDriver = new RaildriverIO(argv[1]);
	// Establish signal handler.
	terminate = false;
	signal(SIGTERM,signalHandler);
	return true;
}

/*
 * Shut everything down
 * 1) Log shutdown
 * 2) Close log file
 * 3) Close all client connections.
 * 4) Break off connection to the RailDriver
 * 5) Close listener socket
 */
bool RaildriverServer::Shutdown()
{
	static char message[1024];
	ServerList::iterator server;

	sprintf(message,"raildriverd stopping\n");
	log(message);
	closelog();
	for (server = FirstServer(); server != LastServer();
	     server = FirstServer()) {
		RaildriverServer *s = *server;
		delete s;
	}
	delete RailDriver;
	close(listenSock);
	return true;
}

/*
 * Event loop:  check for new events to process.
 */
void RaildriverServer::EventLoop()
{
	bool cont;
	RaildriverIO::Eventmask_bits mask, clientmask, sendmask;
	struct timespec sleeptime, remainder;
	
	ServerList::iterator serviter;
	while (true) {
		cont = false;		// Will nap by default
		/*
		 * 1) Check RailDriver for changes.  Then find servers looking
		 *    for those changes.
		 */  
		if (RailDriver->ReadInputs(mask)) {
			for (serviter = FirstServer();
			     serviter != LastServer(); serviter++) {
			     	clientmask = (*serviter)->GetMask();
			     	sendmask = (RaildriverIO::Eventmask_bits)
							(clientmask & mask);
			     	if (sendmask != RaildriverIO::NONE_M) {
					(*serviter)->SendEventData(sendmask);
				}
			}
			cont |= true;
		}
		/*
		 * 2) Check for new clients.
		 */
		if (ListenerEvent()) cont |= true;
		/*
		 * 3) Check each existing client for activity and process it.
		 *    Also check for dead clients.
		 */ 
		for (serviter = FirstServer(); serviter != LastServer();
		     serviter++) {
			RaildriverServer *serv = *serviter;
			cont |= serv->CheckEvent();
#ifdef DEBUG
			logprintf("*** RaildriverServer::EventLoop: serv = 0x%08x, serv->sockfd = %d\n",(long) serv,serv->sockfd);
#endif
			if (serv->sockfd == 0) {
				delete serv;
				break;
			}
		}
		/*
		 * 4) Check for SIGTERM.
		 */
		if (terminate) break;
		/*
		 * cont will be set if we did anything.  If so, we have no time
		 * for a nap!
		 */
		if (cont) continue;
		/*
		 * Nothing happened.  Nap time.
		 */
		sleeptime.tv_sec = 0;
		sleeptime.tv_nsec = 1000000000;
		nanosleep(&sleeptime,&remainder);
	}
}

void RaildriverServer::signalHandler(int signumber)
{
	terminate = true;
}
        
