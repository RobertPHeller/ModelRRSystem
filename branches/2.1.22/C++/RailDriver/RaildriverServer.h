/* 
 * ------------------------------------------------------------------
 * RaildriverServer.h - Raildriver server class (event driven)
 * Created by Robert Heller on Tue Mar 27 11:58:06 2007
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

#ifndef _RAILDRIVERSERVER_H_
#define _RAILDRIVERSERVER_H_

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <signal.h>

#include <string>
#include <vector>
#include <list>
#include <map>

#if __GNUC__ < 3
typedef basic_string<char> string;
#else
using namespace std;
#endif

#include <RaildriverIO.h>
class RaildriverParser;
class RaildriverServer;

/** @name ServerList
  * A linked list of servers.
  */
typedef list<RaildriverServer*> ServerList;

/** \TEX{\typeout{Generated from $Id$.}}
  * This class implements the Raildriver Server.  The static members implement
  * global initialization, the listener, event loop, and global signal handler.
  * The class instances are client connections.
  */
class RaildriverServer {
public:
	/** Main constructor.  Gets the socket, socket address, and the #this#
	  * pointer from the created parser.  The socket and socket address
	  * come from the accept call when the connection is made. Basic
	  * initialization is performed and the server is added to the list
	  * of live connections.
	  *  @param sock The socket file discriptor from accept().
	  *  @param sockaddr The socket address from accept().
	  *  @param p The #this# pointer from the RaildriverParser instance.
	  */
	RaildriverServer(int sock, struct sockaddr_in *sockaddr,
			 RaildriverParser *p);
	/** Destructor.  Clean things up and removes ourself from the list of
	  * live connections.
	  */
	virtual ~RaildriverServer();
	/** Return our event mask.  This is the mask of events we are listening
	  * for.
	  */
	RaildriverIO::Eventmask_bits GetMask() {return event_mask;}
	/** Global static initialization.  Creates the listener, create a
	  * common RaildriverIO object for the Raildriver console that the
	  * Hotplug system detected and which caused the daemon to be started.
	  *   @param argc Count of command line args from main().
	  *   @param argv Vector of command line args from main().
	  */
	static bool Initialize(int argc, char* argv[]);
	/** Global shutdown.  Shutdown all server connections, dismis the
	  * common RaildriverIO object and generally perform process rundown.
	  */
	static bool Shutdown();
	/** Global event loop.  This implements the main processing loop of the
	  * daemon.
	  */
	static void EventLoop();
protected:
	/** Error function.  Used to report parse errors.  The message is
	  * formatted and sent to the client.  It is presumbed that the message
	  * starts with ``5xx '', as this method does not prefix the message
	  * with a three digit response code.
	  *  @param format The format string.
	  */
	void ErrFormat(const char *format, ...);
	/** Exit function.  Sends a ``299 GOODBYE'' message to the client and
	  * closes the connection.  The socket is closed and the socket 
	  * channel set to zero.  Later, the class instance will get reaped
	  * (garbage collected).
	  */
	void DoExit();
	/**  Clear Mask function.  Clears the event mask and sends a
	  * ``201 OK'' message to the client.  With a clear event mask, no
	  * ``202 Events:'' messages will be sent, unless a POLLVALUES command
	  * is issued or a MASK command is sent (to add bits to the event
	  * mask).
	  */
	void ClearMask();
	/**  Add Mask function.  Adds bits to the event mask and sends a
	  * ``201 OK'' message to the client.  When the event mask is not
	  * zero, the server will send periodic messages about changed events
	  * (state of the Raildriver console), but only for the events selected
	  * by the event mask.
	  *  @param mask Mask of bits to add to the event mask.
	  */
	void AddMask(RaildriverIO::Eventmask_bits mask);
	/**  Poll Values functions.  Reads the current Rail Driver state and
	  * calls SendEventData(), sending a ``202 Events:'' message to the 
	  * client. See {@link SendEventData SendEventData()}.  All of the
	  * selected events are sent, even if they have not changed.
	  *  @param mask Mask of bits to poll.
	  */
	void PollValues(RaildriverIO::Eventmask_bits mask);
	/** Led Display function.  Sends digits to the speedometer LEDS and
	  * sends a ``201 OK'' message to the client. The contents of the LED
	  * display are updated based on the passed string, which can contain
	  * the digits 0-9, dashes, underscores (which represent blanks), and
	  * periods (embeded decimal points).  The display is a seven segement
	  * display.
	  *  @param ledstring String to display.  Can contain upto 3 digits,
	  *	dashes, underbars, plus decimal points.
	  */
	void LedDisplay(const char *ledstring);
	/** Speaker on function.  Turns the speaker in the Rail Driver on and
	  * sends a ``201 OK'' message to the client.  This is just a speaker
	  * built into the RailDriver which can be turned on or off.
	  */
	void SpeakerOn();
	/** Speaker off function.  Turns the speaker in the Rail Driver off and
	  * sends a ``201 OK'' message to the client.This is just a speaker
	  * built into the RailDriver which can be turned on or off.
	  */
	void SpeakerOff();
private:
	/** Global listener event.  Checks for new inbound connections and
	  * creates new server instances to handle the new clients.  Called in
	  * the event loop.
	  */
	static bool ListenerEvent();
	/** Global signal handler.  Catches global signals.  The only signal
	  * caught is SIGTERM, used to terminate the deamon (when the Raildriver
	  * console is unpluged.  The signal handled just sets the termination
	  * flag, which is checked in the event loop.
	  *  @param signumber The signal number.
	  */
	static void signalHandler(int signumber);
	/** Return a const iterator for the first active server.  For looping
	  * over the server list.
	  */
	static ServerList::const_iterator ConstFirstServer() {
		return activeServers.begin();
	}
	/** Return a const iterator for the last active server.  For looping
	  * over the server list.
	  */
	static ServerList::const_iterator ConstLastServer() {
		return activeServers.end();
	}
	/** Return an iterator for the first active server.  For looping
	  * over the server list.
	  */
	static ServerList::iterator FirstServer() {
		return activeServers.begin();
	}
	/** Return an iterator for the last active server.  For looping
	  * over the server list.
	  */
	static ServerList::iterator LastServer() {
		return activeServers.end();
	}
	/** Termination flag (set by the signal handler).  This flag is set 
	  * when a SIGTERM signal is received and is checked in the event loop.
	  */
	static bool terminate;
	/** Raildriver object.  This is the class instance of the Raildriver
	  * class that connects us to the Raildriver console that we were
	  * started to serve.
	  */
	static RaildriverIO *RailDriver;
	/** Listen socket.  This is the socket we are listening for client
	  * connections on.  Incoming connections are processed by the 
	  * ListenerEvent() method which is called in the event loop.
	  */
	static int listenSock;
	/** List of all active servers.  This is used in the Event Loop to cycle
	  * through all available client connections.
	  */
	static ServerList activeServers;
	/** Default constructor.  Made private to prevent acidental use
	  * (the compiler will raise an error if it is referenced).
	  */
	RaildriverServer() {}
	/** Client event checker. Check for a message from our client and if
	  * there is a message from our client, parse it and process it and
	  * then send back to the client one (or more) messages:
	  *
	  * Error messages (parse errors from the parser):
	  *
	  * 502 Parse error
	  *
	  * 503 message
	  *
	  * 504 message: object 'object'
	  *
	  * Acknowledgement message (most action commands):
	  *
	  * 201 OK
	  *
	  * Data message in response to a POLLVALUES command:
	  *
	  * 202 Events: key=val,key=val,...
	  *
	  * See {@link SendEventData SendEventData()}
	  *
	  * Close down message in response to an EXIT command:
	  *
	  * 299 GOODBYE
	  */
	bool CheckEvent();
	/** Send Event Data.  One line of data is sent to the client,
	  * formatted like this:
	  *
	  * 202 Events: key=val,key=val,...
	  *
	  * Where key is one of: REVERSER, THROTTLE, AUTOBRAKE, INDEPENDBRK,
	  * BAILOFF, HEADLIGHT, WIPER, DIGITAL1, DIGITAL2, DIGITAL3, DIGITAL4,
	  * DIGITAL5, or DIGITAL6.  And val is either a small decimal number
	  * (in the range of 0 to 255) or a list of button or switch names
	  * enclosed in parenthisises.  Only the events specified by the
	  * supplied mask are sent.
	  *
	  * REVERSER is the state of the reverser lever, values (much) less
	  * than 128 are forward, a value at or near 128 is neutral and values
	  * (much) greater than 128 are reverse.
	  *
	  * THROTTLE is the state of the Throttle (and dynamic brake).  Values
	  * (much) greater than 128 are for throttle (maximum throttle is are
	  * values close to 255), values near 128 are at the center position
	  * (idle/coasting), and values (much) less than 128 are for dynamic
	  * braking, with values aproaching 0 for full dynamic braking.
	  *
	  * AUTOBRAKE is the state of the Automatic (trainline) brake.  Large
	  * values for no braking, small values for more braking.
	  *
	  * INDEPENDBRK is the state of the Independent (engine only) brake.
	  * Like the Automatic brake: large values for no braking, small
	  * values for more braking.
	  *
	  * BAILOFF is the Independent brake 'bailoff', this is the spring
	  * loaded right movement of the Independent brake lever.  Larger
	  * values mean the lever has been shifted right.
	  *
	  * HEADLIGHT is the state of the headlight switch.  A value below 128
	  * is off, a value near 128 is dim, and a number much larger than 128
	  * is full. This is an analog input w/detents, not a switch!
	  *
	  * WIPER is the state of the wiper switch.  Much like the headlight
	  * switch, this is also an analog input w/detents, not a switch!
	  * Small values (much less than 128) are off, values near 128 are
	  * slow, and larger values are full.
	  *
	  * DIGITAL1 is the leftmost eight blue buttons in the top row, BB1,
	  * BB2 BB3, BB4, BB5, BB6, BB7, and BB8.
	  *
	  * DIGITAL2 is the rightmost six blue buttons in the top row and the
	  * leftmost two buttons in the bottom row, BB9, BB10, BB11, BB12,
	  * BB13, BB14, BB15, and BB16.
	  *
	  * DIGITAL3 is the eight buttons on the bottom row, starting with the
	  * third from the left, BB17, BB18, BB19, BB20, BB21, BB22, BB23, and
	  * BB24. 
	  *
	  * DIGITAL4 is the rightmost four buttons on the bottom row, plus the
	  * zoom up and zoom down, plus the pan right and pan up buttons, named
	  * BB25, BB26, BB27, BB28, Zoom Up, Zoom Down, Pan Right, and Pan Up.
	  *
	  * DIGITAL5 is the pan left and pan down, range up and range down, and
	  * E-Stop up and E-Stop down switches, named Pan Left, Pan Down,
	  * Range Up, Range Down, Emergency Brake Up, Emergency Brake Down.
	  *
	  * DIGITAL6 is the whistle up and whistle down, Alert, Sand, P
	  * (Pantograph), and Bell buttons, named Whistle Up, Whistle Down,
	  * Alert, Sand, Pantograph, and Bell.
	  *
	  *  @param sendmask A mask of events to send event data about.  Only
	  *                  data for the matching events will be sent.
	  *	
	  */
	void SendEventData(RaildriverIO::Eventmask_bits sendmask);
	/** Read line function.  Reads a logical line of text from the read
	  * buffer to be parsed by the parser.  If there is not enough content
	  * in the read buffer, more is fetched from the client via a socket
	  * read.  This function is called in the CheckEvent() method after it
	  * has checked to see if there is data available on the client socket.
	  */
	bool Read();
	/** Our parser instance. Parses commands coming over the network socket.
	  * The parser is actually a subclass of this class and the parser
	  * instance should be the same as the #this# pointer.  The parser
	  * implements two important methods, ResetPtr() which sets the parse
	  * pointer and yyparse() which actually parses the (message) line.
	  * The parser actually calls various protected members to actually
	  * implement the various command actions.	  
	  */
	RaildriverParser *parser;
	/** The socket file discriptor.  This is what was returned by accept
	  * when the connection was first created.  It is used to communicate
	  * with the client process.  When the connection is shut down, this
	  * file discriptor is closed and sockfd set to zero to indicate a
	  * ``dead'' state.  The Event Loop procedure looks for dead server
	  * connections and reaps them.
	  */
	int sockfd;
	/** Socket address.  Holds the address of the client process.
	  */
	sockaddr_in remotesockaddr;
	/** Our event mask.  These are the events we are listening for.
	  */
	RaildriverIO::Eventmask_bits event_mask;
	/** Read buffer.  Holds the last thing read from the socket from
	  * the client.
	  */
	char readbuffer[4096];
	/** Read buffer length.  This is how much of the read buffer is
	  * currently in use.
	  */
	int  rblen;
	/** Read buffer offset.  This is the index of the next available
	  * input byte to use.  If equal or greater to #rblen#, there are
	  * no usable bytes in the read buffer, that is, a fresh read is
	  * needed.
	  */
	int  rboff;
	/** Line buffer.  This is the line buffer of the current line to
	  * be parsed.
	  */
	char linebuffer[4096];
	/** Write buffer.  This buffer is used to hold text ready to be
	  * sent to the client.
	  */
	char writebuffer[4096];
	/**  Working buffer. An intermediate, general purpose buffer.
	  */
	char workbuffer[256];
};	
	
	


#endif // _RAILDRIVERSERVER_H_

