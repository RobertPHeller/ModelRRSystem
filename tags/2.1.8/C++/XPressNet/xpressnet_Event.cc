/* 
 * ------------------------------------------------------------------
 * xpressnet_Event.cc - Event handling code for XpressNet code
 * Created by Robert Heller on Sun May 29 09:09:34 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.3  2005/05/30 22:55:49  heller
 * Modification History: May 30, 2005 -- Lockdown 2
 * Modification History:
 * Modification History: Revision 1.2  2005/05/30 18:47:52  heller
 * Modification History: May 30, 2005 Lockdown.  Code complete and compiles, but untested.
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

static char rcsid[] = "$Id$";

#include <xpressnet_Event.h>
#include <stdarg.h>

/************************************************************************
 *									*
 * Constructor -- initialize port (call parent constructor), and setup	*
 * the Tcl Event handler by calling Tcl_CreateEventSource.		*
 *									*
 ************************************************************************/

XpressNetEvent::XpressNetEvent(Tcl_Interp *interp,const char *eventScript,const char *port,char **outmessage)
{
	XPressNet(port,outmessage);
	if (outmessage != NULL && *outmessage != NULL) return;
	the_interp = interp;
	event_script = Tcl_Alloc(strlen(eventScript));
	strcpy(event_script,eventScript);
	Tcl_CreateEventSource(XpressNetEvent::tclEventSetup,
			      XpressNetEvent::tclEventCheck,
			      (ClientData) this);
}

/************************************************************************
 *									*
 * Destructor -- remove event source and free up resources.		*
 *									*
 ************************************************************************/

XpressNetEvent::~XpressNetEvent()
{
	Tcl_DeleteEventSource(XpressNetEvent::tclEventSetup,
			      XpressNetEvent::tclEventCheck,
			      (ClientData) this);
	Tcl_Free(event_script);
}

/************************************************************************
 *									*
 * Event setup method.  Check for an XPressnet response.		*
 *									*
 ************************************************************************/

void XpressNetEvent::eventSetup(int flags)
{
	Tcl_Time blockTime = { 0, 0 };

	if (!(flags & TCL_FILE_EVENTS)) {
		return;
	}
	if (CheckForResponse() != CommandStationResponse::NO_RESPONSE_AVAILABLE) {
		Tcl_SetMaxBlockTime(&blockTime);
	}
}

/************************************************************************
 *									*
 * Event check -- check for an XPressnet response and if there was one,	*
 * insert the event into the event queue.				*
 *									*
 ************************************************************************/

void XpressNetEvent::eventCheck(int flags)
{
	if (!(flags & TCL_FILE_EVENTS)) {
		return;
	}
	if (CheckForResponse() != CommandStationResponse::NO_RESPONSE_AVAILABLE) {
		struct event *evPtr =
			(struct event *) Tcl_Alloc(sizeof(struct event));
		evPtr->tclEvent.proc = tclEventProc;
		evPtr->xpressNetEvent = this;
		Tcl_QueueEvent((Tcl_Event *) evPtr, TCL_QUEUE_TAIL);
	}
}



/************************************************************************
 *									*
 * Process an XPressnet event.  Grab the top event and pass it to the   *
 * Tcl event script for processing.					*
 *									*
 ************************************************************************/

int XpressNetEvent::eventProc(Tcl_Event *evPtr,int flags)
{
	if (!(flags & TCL_FILE_EVENTS)) {
		return 0;
	}
	Tcl_Obj *striptObj = Tcl_NewObj();
	Tcl_Obj *responseObj = NULL;
	Tcl_SetStringObj(striptObj,event_script,-1);
	Tcl_AppendToObj(striptObj," ",1);
	if (CheckForResponse() != CommandStationResponse::NO_RESPONSE_AVAILABLE) {
		CommandStationResponse *response = GetNextCommandStationResponse();
		Tcl_AppendToObj(striptObj,(char *)CommandStationResponse::TypeCodeString(response->ResponseType()),-1);
		Tcl_AppendToObj(striptObj," ",1);
		switch (response->ResponseType()) {
			case CommandStationResponse::NO_RESPONSE_AVAILABLE:
				return 1;
			case CommandStationResponse::NORMAL_OPERATION_RESUMED:
				responseObj = NewSWIGNormalOperationResumed(the_interp,(void *)response);
				break;
			case CommandStationResponse::TRACK_POWER_OFF:
				responseObj = NewSWIGTrackPowerOff(the_interp,(void *)response);
				break;
			case CommandStationResponse::EMERGENCY_STOP:
				responseObj = NewSWIGEmergencyStop(the_interp,(void *)response);
				break;
			case CommandStationResponse::SERVICE_MODE_ENTRY:
				responseObj = NewSWIGServiceModeEntry(the_interp,(void *)response);
				break;
			case CommandStationResponse::PROGRAMMING_INFO_SHORT_CIRCUIT:
				responseObj = NewSWIGProgrammingInfoShortCircuit(the_interp,(void *)response);
				break;
			case CommandStationResponse::PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND:
				responseObj = NewSWIGProgrammingInfoDataByteNotFound(the_interp,(void *)response);
				break;
			case CommandStationResponse::PROGRAMMING_INFO_COMMAND_STATION_BUSY:
				responseObj = NewSWIGProgrammingInfoCommandStationBusy(the_interp,(void *)response);
				break;
			case CommandStationResponse::PROGRAMMING_INFO_COMMAND_STATION_READY:
				responseObj = NewSWIGProgrammingInfoCommandStationReady(the_interp,(void *)response);
				break;
			case CommandStationResponse::SERVICE_MODE_RESPONSE:
				responseObj = NewSWIGServiceModeResponse(the_interp,(void *)response);
				break;
			case CommandStationResponse::SOFTWARE_VERSION:
				responseObj = NewSWIGSoftwareVersion(the_interp,(void *)response);
				break;
			case CommandStationResponse::COMMAND_STATION_STATUS:
				responseObj = NewSWIGCommandStationStatus(the_interp,(void *)response);
				break;
			case CommandStationResponse::TRANSFER_ERRORS:
				responseObj = NewSWIGTransferErrors(the_interp,(void *)response);
				break;
			case CommandStationResponse::COMMAND_STATION_BUSY:
				responseObj = NewSWIGCommandStationBusy(the_interp,(void *)response);
				break;
			case CommandStationResponse::INSTRUCTION_NOT_SUPPORTED:
				responseObj = NewSWIGInstructionNotSupported(the_interp,(void *)response);
				break;
			case CommandStationResponse::ACCESSORY_DECODER_INFORMATION:
				responseObj = NewSWIGAccessoryDecoderInformation(the_interp,(void *)response);
				break;
			case CommandStationResponse::LOCOMOTIVE_INFORMATION:
				responseObj = NewSWIGLocomotiveInformation(the_interp,(void *)response);
				break;
			case CommandStationResponse::FUNCTION_STATUS:
				responseObj = NewSWIGFunctionStatus(the_interp,(void *)response);
				break;
			case CommandStationResponse::LOCOMOTIVE_ADDRESS:
				responseObj = NewSWIGLocomotiveAddress(the_interp,(void *)response);
				break;
			case CommandStationResponse::DOUBLE_HEADER_INFORMATION:
				responseObj = NewSWIGDoubleHeaderInformation(the_interp,(void *)response);
				break;
			case CommandStationResponse::DOUBLE_HEADER_MU_ERROR:
				responseObj = NewSWIGDoubleHeaderMuError(the_interp,(void *)response);
				break;
			case CommandStationResponse::LI100_MESSAGE:
				responseObj = NewSWIGLI100Message(the_interp,(void *)response);
				break;
			default:
				return 1;
		}			
		Tcl_AppendObjToObj(striptObj,responseObj);
		int result = Tcl_EvalObjEx(the_interp,striptObj,TCL_EVAL_GLOBAL);
		if (result != TCL_OK) Tcl_BackgroundError(the_interp);
		delete response;
	}
	return 1;
}
