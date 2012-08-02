/* 
 * ------------------------------------------------------------------
 * xpressnet_Event.h - Event handling interface for XpressNet code
 * Created by Robert Heller on Sun May 29 09:08:41 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2005/11/14 20:28:45  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.3  2005/11/04 19:06:35  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/05/30 22:55:49  heller
 * Modification History: May 30, 2005 -- Lockdown 2
 * Modification History:
 * Modification History: Revision 1.1  2005/05/30 00:47:35  heller
 * Modification History: May 29 2005 Lock down
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

#ifndef _XPRESSNET_EVENT_H_
#define _XPRESSNET_EVENT_H_

#include <xpressnet.h>
#include <tcl.h>

/**  XPressNet C++ Tcl Event Interface.
 \TEX{\typeout{Generated from $Id$.}}
 This is the Tcl event interface layer for the XPressNet serial port
 interface.  This allows the Tcl programmer the ability to manage the
 XpressNet system via the Tcl event loop.

 */
//@{

///  \Label{Class:XpressNetEvent}
class XpressNetEvent : public XPressNet {
#ifndef SWIG
protected:
	/**   Default constructor (never called). */
	XpressNetEvent() {the_interp = NULL;XPressNet();}
#endif
public:
	/**   \Label{Class:XPressNetEvent:Constructor} The constructor
	  opens serial port and initializes the port, stashes the interpreter
	  and creates an event source.
	  @param interp The Tcl interpreter.
	  @param eventScript The event script.
	  @param port The serial port device file.
	  @param outmessage This holds a pointer to an error message, if any.*/
	XpressNetEvent (Tcl_Interp *interp,const char *eventScript,
		const char *port="/dev/ttyS0",char **outmessage=NULL);
	/**   \Label{Class:XPressNetEvent:Destructor} The destructor
	  closes the serial port and deletes the event source. */
	~XpressNetEvent();
#ifndef SWIG
private:
	///  The Tcl interpreter.
	Tcl_Interp *the_interp;
	///  The event script.
	char *event_script;
	/**  The Tcl event setup proc.
	  @param clientData The client data (class instance).
	  @param flags Flags. */
	static void tclEventSetup (ClientData clientData, int flags) {
		XpressNetEvent *instance = (XpressNetEvent *) clientData;
		instance->eventSetup(flags);
	}
	/**  The event setup proc.
	  @param flags Flags. */
	void eventSetup (int flags);
	/**  The Tcl event check proc.
	  @param clientData The client data (class instance).
	  @param flags Flags.*/
	static void tclEventCheck (ClientData clientData,int flags) {
		XpressNetEvent *instance = (XpressNetEvent *) clientData;
		instance->eventCheck(flags);
	}
	/**  The event check proc.
	  @param flags Flags.*/
	void eventCheck (int flags);
	///  Event structure.
	struct event {
		///  Tcl event structure.
		Tcl_Event tclEvent;
		///  Ourself.
		XpressNetEvent *xpressNetEvent;
	};
	/**  Tcl event proc.
	  @param evPtr Tcl event pointer.
	  @param flags Flags.*/
	static int tclEventProc (Tcl_Event *evPtr,int flags) {
		struct event * ePtr = (struct event *) evPtr;
		return ePtr->xpressNetEvent->eventProc(evPtr,flags);
	}
	/**  Event proc.
	  @param evPtr Tcl event pointer.
	  @param flags Flags.*/
	int eventProc(Tcl_Event *evPtr,int flags);
#endif	
};
//@} 

#endif // _XPRESSNET_EVENT_H_

