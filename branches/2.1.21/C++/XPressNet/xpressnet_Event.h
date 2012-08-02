/* 
 * ------------------------------------------------------------------
 * xpressnet_Event.h - Event handling interface for XpressNet code
 * Created by Robert Heller on Sun May 29 09:08:41 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
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

/** @name XPressNet C++ Tcl Event Interface.
  * @doc \TEX{\typeout{Generated from $Id$.}}
  * This is the Tcl event interface layer for the XPressNet serial port
  * interface.  This allows the Tcl programmer the ability to manage the
  * XpressNet system via the Tcl event loop.
  */
//@{

/** @memo XPressNet Event class.
  * @doc This class implements the Tcl Event interface to the XPressNet
  * serial port interface.  A Tcl script is bound to XPressNet serial
  * port events.  This script is called from the event procedures when
  * XPressNet events occur.
  */
class XpressNetEvent : public XPressNet {
#ifndef SWIG
protected:
	/**   Default constructor (never called).
	  */
	XpressNetEvent() {the_interp = NULL;XPressNet();}
#endif
public:
	/** @memo Constructor.
	  * @doc The constructor opens serial port and initializes the port,
	  * stashes the interpreter and creates an event source.
	  * @param interp The Tcl interpreter. This parameter is not seen by
	  *	   the Tcl interface (the SWIG generated code passes it).
	  * @param eventScript The event script.
	  * @param port The serial port device file.
	  * @param outmessage This holds a pointer to an error message, if
	  * any. This parameter is not seen by the Tcl interface (the SWIG
	  * generated code passes it).
	  */
	XpressNetEvent (Tcl_Interp *interp,const char *eventScript,
		const char *port="/dev/ttyS0",char **outmessage=NULL);
	/** @memo Destructor. 
	  * @doc The destructor closes the serial port and deletes the event
	  * source. 
	  */
	~XpressNetEvent();
#ifndef SWIG
private:
	/** The Tcl interpreter.
	  */
	Tcl_Interp *the_interp;
	/**  The event script.
	  */
	char *event_script;
	/**  The Tcl event setup proc.
	  * @param clientData The client data (class instance).
	  * @param flags Flags. 
	  */
	static void tclEventSetup (ClientData clientData, int flags) {
		XpressNetEvent *instance = (XpressNetEvent *) clientData;
		instance->eventSetup(flags);
	}
	/**  The event setup proc.
	  * @param flags Flags. 
	  */
	void eventSetup (int flags);
	/**  The Tcl event check proc.
	  * @param clientData The client data (class instance).
	  * @param flags Flags.
	  */
	static void tclEventCheck (ClientData clientData,int flags) {
		XpressNetEvent *instance = (XpressNetEvent *) clientData;
		instance->eventCheck(flags);
	}
	/**  The event check proc.
	  * @param flags Flags.
	  */
	void eventCheck (int flags);
	/**  Event structure.
	  */
	struct event {
		/**  Tcl event structure.
		  */
		Tcl_Event tclEvent;
		/**  Ourself.
		  */
		XpressNetEvent *xpressNetEvent;
	};
	/**  Tcl event proc.
	  * @param evPtr Tcl event pointer.
	  * @param flags Flags.
	  */
	static int tclEventProc (Tcl_Event *evPtr,int flags) {
		struct event * ePtr = (struct event *) evPtr;
		return ePtr->xpressNetEvent->eventProc(evPtr,flags);
	}
	/**  Event proc.
	  * @param evPtr Tcl event pointer.
	  * @param flags Flags.
	  */
	int eventProc(Tcl_Event *evPtr,int flags);
#endif	
};

#ifdef SWIG
%{
Tcl_Obj* NewSWIGNormalOperationResumed(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_NormalOperationResumed,0);
}
Tcl_Obj* NewSWIGTrackPowerOff(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_TrackPowerOff,0);
}
Tcl_Obj* NewSWIGEmergencyStop(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_EmergencyStop,0);
}
Tcl_Obj* NewSWIGServiceModeEntry(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_ServiceModeEntry,0);
}
Tcl_Obj* NewSWIGProgrammingInfoShortCircuit(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_ProgrammingInfoShortCircuit,0);
}
Tcl_Obj* NewSWIGProgrammingInfoDataByteNotFound(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_ProgrammingInfoDataByteNotFound,0);
}
Tcl_Obj* NewSWIGProgrammingInfoCommandStationBusy(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_ProgrammingInfoCommandStationBusy,0);
}
Tcl_Obj* NewSWIGProgrammingInfoCommandStationReady(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_ProgrammingInfoCommandStationReady,0);
}
Tcl_Obj* NewSWIGServiceModeResponse(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_ServiceModeResponse,0);
}
Tcl_Obj* NewSWIGSoftwareVersion(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_SoftwareVersion,0);
}
Tcl_Obj* NewSWIGCommandStationStatus(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_CommandStationStatus,0);
}
Tcl_Obj* NewSWIGTransferErrors(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_TransferErrors,0);
}
Tcl_Obj* NewSWIGCommandStationBusy(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_CommandStationBusy,0);
}
Tcl_Obj* NewSWIGInstructionNotSupported(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_InstructionNotSupported,0);
}
Tcl_Obj* NewSWIGAccessoryDecoderInformation(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_AccessoryDecoderInformation,0);
}
Tcl_Obj* NewSWIGLocomotiveInformation(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_LocomotiveInformation,0);
}
Tcl_Obj* NewSWIGFunctionStatus(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_FunctionStatus,0);
}
Tcl_Obj* NewSWIGLocomotiveAddress(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_LocomotiveAddress,0);
}
Tcl_Obj* NewSWIGDoubleHeaderInformation(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_DoubleHeaderInformation,0);
}
Tcl_Obj* NewSWIGDoubleHeaderMuError(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_DoubleHeaderMuError,0);
}
Tcl_Obj* NewSWIGLI100Message(Tcl_Interp *interp,void * response) {
	return SWIG_NewInstanceObj(response,SWIGTYPE_p_LI100Message,0);
}
%}
#else
extern Tcl_Obj* NewSWIGNormalOperationResumed(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGTrackPowerOff(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGEmergencyStop(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGServiceModeEntry(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGProgrammingInfoShortCircuit(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGProgrammingInfoDataByteNotFound(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGProgrammingInfoCommandStationBusy(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGProgrammingInfoCommandStationReady(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGServiceModeResponse(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGSoftwareVersion(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGCommandStationStatus(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGTransferErrors(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGCommandStationBusy(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGInstructionNotSupported(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGAccessoryDecoderInformation(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGLocomotiveInformation(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGFunctionStatus(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGLocomotiveAddress(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGDoubleHeaderInformation(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGDoubleHeaderMuError(Tcl_Interp *interp,void * response);
extern Tcl_Obj* NewSWIGLI100Message(Tcl_Interp *interp,void * response);
#endif


//@} 

#endif // _XPRESSNET_EVENT_H_

