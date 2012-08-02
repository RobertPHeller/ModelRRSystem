/* 
 * ------------------------------------------------------------------
 * xpressnet.h - XPressNet Interface Class
 * Created by Robert Heller on Thu May 26 20:04:20 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.10  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.9  2007/02/21 21:03:10  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.8  2007/02/21 20:24:47  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.7  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.6  2005/11/14 20:28:45  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.5  2005/11/04 19:06:35  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.4  2005/05/30 23:09:42  heller
 * Modification History: May 30, 2005 -- Lockdown 3
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

#ifndef _XPRESSNET_H_
#define _XPRESSNET_H_

#include <termios.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#else
#include <sys/types.h>
#include <unistd.h>
#endif
#include <sys/time.h>

/** @addtogroup XPressNetModule
  * @{
  */

namespace xpressnet {
  
/** @defgroup XPressNetSerialPort XPressNet C++ Serial Port Interface.
  *
  * This is a Linux implementation the XPressNet serial port interface.
  * Based on documentation provided by Lenz Elektronik
  * GMBH (6/2003 third edition). This code
  * works with 2.2 kernels and GLIBC 2.1 (RedHat 6.2), 2.4 kernels and
  * GLIBC 2.2 (RedHat 7.3), and 2.6 kernels and GLIBC 2.3 (CentOS 4.4/RHEL 4).
  * And it can use any serial port device supported by these kernels.  That is,
  * in addition to the standard four COM ports, it can also use the various
  * supported multi-port cards as well.
  *
  * The code is presently ``hardwired'' to use the Linux termios interface. I
  * wanted to get the code up and running and presently I don't have any machines
  * running other operating systems to test other low-level terminal I/O code.
  * For MS-Windows who might want to use my forthcoming Tcl/Tk MRI code I'll
  * probably want to port this code to run under MS-Windows.  This header and
  * the class interface specification won't change much.  There will probably be
  * lots of fun with ifdef in the C++ file.  Since this is open source code, I
  * would hope that some enterprising MS-Windows C++ programmer will take up the
  * ``gauntlet'' and do the MS-Windows port.  (Ditto for MacOSX and FreeBSD
  * programmers.)
  *
  * Basically, the way this code works is to use a class to interface to the
  * serial port attached to one of Lenz's serial port adapters (LI100, LI100F,
  * or LI101).
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  * @{
  */

#ifdef SWIGTCL8
%typemap(out) CommandStationResponse::TypeCode {
	Tcl_SetStringObj($result,(char *) CommandStationResponse::TypeCodeString((CommandStationResponse::TypeCode)$1),-1);
}
#endif

/** @brief Base response class.
  *
  * All responses are derived from this class.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Default constructor.
	  */
	CommandStationResponse() {
		Response_Type = NO_RESPONSE_AVAILABLE;
		gettimeofday(&Time_Stamp,NULL);
		next_response = NULL;
	}
	/** @brief Default destructor (never called).
	  */
	virtual ~CommandStationResponse() {};
#endif
	/**  Response types.
	  */
	enum TypeCode {
		/**  No response available.
		  */
		NO_RESPONSE_AVAILABLE = 0,
		/**  Normal operation resumed.
		  */
		NORMAL_OPERATION_RESUMED,
		/**  Track power off.
		  */
		TRACK_POWER_OFF,
		/**  Emergency stop.
		  */
		EMERGENCY_STOP,
		/**  Service mode entry.
		  */
		SERVICE_MODE_ENTRY,
		/**  Programming info. ``short-circuit''.
		  */
		PROGRAMMING_INFO_SHORT_CIRCUIT,
		/**  Programming info. ``data byte not found''.
		  */
		PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND,
		/**  Programming info. ``command station busy''.
		  */
		PROGRAMMING_INFO_COMMAND_STATION_BUSY,
		/**  Programming info. ``command station ready''.
		  */
		PROGRAMMING_INFO_COMMAND_STATION_READY,
		/**  Service mode response.
		  */
		SERVICE_MODE_RESPONSE,
		/**  Software version.
		  */
		SOFTWARE_VERSION,
		/**  Command station status.
		  */
		COMMAND_STATION_STATUS,
		/**  Transfer errors.
		  */
		TRANSFER_ERRORS,
		/**  Command station busy.
		  */
		COMMAND_STATION_BUSY,
		/**  Instruction not supported by command station.
		  */
		INSTRUCTION_NOT_SUPPORTED,
		/**  Accessory decoder information.
		  */
		ACCESSORY_DECODER_INFORMATION,
		/**  Locomotive information.
		  */
		LOCOMOTIVE_INFORMATION,
		/**  Function status.
		  */
		FUNCTION_STATUS,
		/**  Locomotive address.
		  */
		LOCOMOTIVE_ADDRESS,
		/**  Double header information.
		  */
		DOUBLE_HEADER_INFORMATION,
		/**  Double header or MU error.
		  */
		DOUBLE_HEADER_MU_ERROR,
		/**  LI100 Messages.
		  */
		LI100_MESSAGE
	};
#ifndef SWIG
	/**  Convert a TypeCode to a pointer of type const char.
	  *  @param code Type code to convert.
          */
	static const char *TypeCodeString (TypeCode code) {
		switch (code) {
			case NO_RESPONSE_AVAILABLE:
				return "NO_RESPONSE_AVAILABLE";
			case NORMAL_OPERATION_RESUMED:
				return "NORMAL_OPERATION_RESUMED";
			case TRACK_POWER_OFF:
				return "TRACK_POWER_OFF";
			case EMERGENCY_STOP:
				return "EMERGENCY_STOP";
			case SERVICE_MODE_ENTRY:
				return "SERVICE_MODE_ENTRY";
			case PROGRAMMING_INFO_SHORT_CIRCUIT:
				return "PROGRAMMING_INFO_SHORT_CIRCUIT";
			case PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND:
				return "PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND";
			case PROGRAMMING_INFO_COMMAND_STATION_BUSY:
				return "PROGRAMMING_INFO_COMMAND_STATION_BUSY";
			case PROGRAMMING_INFO_COMMAND_STATION_READY:
				return "PROGRAMMING_INFO_COMMAND_STATION_READY";
			case SERVICE_MODE_RESPONSE:
				return "SERVICE_MODE_RESPONSE";
			case SOFTWARE_VERSION:
				return "SOFTWARE_VERSION";
			case COMMAND_STATION_STATUS:
				return "COMMAND_STATION_STATUS";
			case TRANSFER_ERRORS:
				return "TRANSFER_ERRORS";
			case COMMAND_STATION_BUSY:
				return "COMMAND_STATION_BUSY";
			case INSTRUCTION_NOT_SUPPORTED:
				return "INSTRUCTION_NOT_SUPPORTED";
			case ACCESSORY_DECODER_INFORMATION:
				return "ACCESSORY_DECODER_INFORMATION";
			case LOCOMOTIVE_INFORMATION:
				return "LOCOMOTIVE_INFORMATION";
			case FUNCTION_STATUS:
				return "FUNCTION_STATUS";
			case LOCOMOTIVE_ADDRESS:
				return "LOCOMOTIVE_ADDRESS";
			case DOUBLE_HEADER_INFORMATION:
				return "DOUBLE_HEADER_INFORMATION";
			case DOUBLE_HEADER_MU_ERROR:
				return "DOUBLE_HEADER_MU_ERROR";
			case LI100_MESSAGE:
				return "LI100_MESSAGE";
			default: return "";
		}
	}
#endif
	/**  Append to list.
	  * @param list The list to append to.
	  */
	CommandStationResponse * AppendToList (
		CommandStationResponse *list
	) {
		if (list == NULL) return this;
		CommandStationResponse **p = &list->next_response;
		while (*p != NULL) {
			p = &((*p)->next_response);
		}
		*p = this;
		return list;
	}		
#ifdef SWIG
	 static CommandStationResponse *PopTopOffList (CommandStationResponse *list);
#else
	/** Pop top element off list.
	  *  @param list List to pop from.
	  */
	static CommandStationResponse *PopTopOffList (CommandStationResponse *&list) {
		if (list == NULL) return NULL;
		CommandStationResponse *head = list;
		list = list->next_response;
		return head;
	}
#endif
	/**
	  * Return the response type.
	  */
	TypeCode ResponseType() const {return Response_Type;}
	/** Return the time stamp of the response.
	  */
	const struct timeval & TimeStamp() const { return Time_Stamp; }
#ifndef SWIG
protected:
	/**  Response type.
	  */
	TypeCode Response_Type;
	/**  Time stamp.
	  */
	struct timeval Time_Stamp;
	/**  Next response in the list.
	  */
	CommandStationResponse *next_response;
#endif
};

/** Normal operation resumed.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class NormalOperationResumed : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	NormalOperationResumed() {
		Response_Type = NORMAL_OPERATION_RESUMED;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~NormalOperationResumed() {}
};

/** Track power off.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class TrackPowerOff : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	TrackPowerOff() {
		Response_Type = TRACK_POWER_OFF;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~TrackPowerOff() {}
};

/** Emergency stop.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class EmergencyStop : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	EmergencyStop() {
		Response_Type = EMERGENCY_STOP;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~EmergencyStop() {}
};

/** Service mode entry.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class ServiceModeEntry : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	ServiceModeEntry() {
		Response_Type = SERVICE_MODE_ENTRY;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~ServiceModeEntry() {}
};

/** @brief Programming info.
  *
  *  A ``short-circuit'' was detected.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class ProgrammingInfoShortCircuit : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	ProgrammingInfoShortCircuit() {
		Response_Type = PROGRAMMING_INFO_SHORT_CIRCUIT;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~ProgrammingInfoShortCircuit() {}
};

/** @brief Programming info.
  *
  * The ``data byte not was not found''.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class ProgrammingInfoDataByteNotFound : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	ProgrammingInfoDataByteNotFound() {
		Response_Type = PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~ProgrammingInfoDataByteNotFound() {}
};

/** @brief Programming info.
  *
  * The ``command station is busy''.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class ProgrammingInfoCommandStationBusy : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	ProgrammingInfoCommandStationBusy() {
		Response_Type = PROGRAMMING_INFO_COMMAND_STATION_BUSY;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~ProgrammingInfoCommandStationBusy() {}
};

/** @brief Programming info.
  *
  * The ``command station is ready''.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class ProgrammingInfoCommandStationReady : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	ProgrammingInfoCommandStationReady() {
		Response_Type = PROGRAMMING_INFO_COMMAND_STATION_READY;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~ProgrammingInfoCommandStationReady() {}
};

#ifdef SWIGTCL8
%typemap(out) ServiceModeResponse::ServiceModeType {
	Tcl_SetStringObj($result, (char *) ServiceModeResponse::ServiceModeTypeString((ServiceModeResponse::ServiceModeType)$1),-1);
}
#endif

/** @brief Service mode response.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class ServiceModeResponse : public CommandStationResponse {
public:
	/**  Service mode type.
	  */
	enum ServiceModeType {
		/**  Register or Paged mode.
		  */
		RegisterPaged,
		/**  Direct CV mode.
		  */
		DirectCV
	};
#ifndef SWIG
	/**  Convert service mode to a string.
	  *  @param mode The mode to convert.
	  */
	static const char *ServiceModeTypeString(ServiceModeType mode) {
		switch (mode) {
			case RegisterPaged: return "RegisterPaged";
			case DirectCV: return "DirectCV";
			default: return "";
		}
	}
private:
	/**  The service mode.
	  */
	ServiceModeType service_mode;
	/**  The CV value.
	  */
	unsigned char cv;
	/**  The data value.
	  */
	unsigned char data;
public:
	/** @brief Constructor.
	  *  @param modebits First data byte (contains mode bit).
	  *  @param CE Second data byte (contains C or E value).
	  *  @param D Third data byte (contains D value).
	  */
	ServiceModeResponse(unsigned char modebits,unsigned char CE,
		unsigned char D) {
		Response_Type = SERVICE_MODE_RESPONSE;
		if (modebits == 0x10) service_mode = RegisterPaged;
		else service_mode = DirectCV;
		cv = CE;
		data = D;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~ServiceModeResponse() {}
	/**  Return the service mode.
	  */
	ServiceModeType ServiceMode() const { return service_mode; }
	/**  Return the CV value.
	  */
	unsigned char CV() const { return cv; }
	/**  Return the data value.
	  */
	unsigned char Data() const {return data; } 
};


#ifdef SWIGTCL8
%typemap(out) SoftwareVersion::CommandStationTypeCode {
	Tcl_SetStringObj($result, (char *) SoftwareVersion::CommandStationTypeCodeString((SoftwareVersion::CommandStationTypeCode)$1),-1);
}
#endif

/** @brief Software version.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class SoftwareVersion : public CommandStationResponse {
public:
	/**  Type of command station.
	  */
	enum CommandStationTypeCode {
		/**  Unknown command station (X-Bus V1 or V2).
		  */
		Unknown = -1,
		/**  LZ100 command station.
		  */
		LZ100 = 0,
		/**  LH200 command station.
		  */
		LH200 = 1,
		/**  DPC command station.
		  */
		DPC = 2
	};
#ifndef SWIG
	/**  Return the type code as a string.
	  *  @param code Code to convert.
	  */
	static const char * CommandStationTypeCodeString (CommandStationTypeCode code) {
		switch (code) {
			case Unknown: return "Unknown";
			case LZ100:   return "LZ100";
			case LH200:   return "LH200";
			case DPC:     return "DPC";
			default:      return "";
		}
	}
	/** @brief Constructor.
	  *  @param majornibble Major version number.
	  *  @param minornibble Minor version number.
	  *  @param cst Command station type.
	  */
	SoftwareVersion(unsigned char majornibble,unsigned char minornibble,
		unsigned char cst = 0xff) {
		Response_Type = SOFTWARE_VERSION;
		major = majornibble;
		minor = minornibble;
		switch (cst) {
			case 0x00: command_station_type = LZ100; break;
			case 0x01: command_station_type = LH200; break;
			case 0x02: command_station_type = DPC; break;
			default:   command_station_type = Unknown;
		}
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~SoftwareVersion() {}
	/**  Return major version number.
	  */
	unsigned char Major() const {return major;}
	/**  Return minor version number.
	  */
	unsigned char Minor() const {return minor;}
	/**  Return command station type.
	  */
	CommandStationTypeCode CommandStationType() const {return command_station_type;}
#ifndef SWIG
private:
	/**  Major version number.
	  */
	unsigned char major;
	/**  Minor version number.
	  */
	unsigned char minor;
	/**  Command station type.
	  */
	CommandStationTypeCode command_station_type;
#endif
};	

#ifdef SWIGTCL8
%typemap(out) CommandStationStatus::StartModeType {
	Tcl_SetStringObj($result, (char *) CommandStationStatus::StartModeTypeString(( CommandStationStatus::StartModeType)$1),-1);
}

%typemap(in) CommandStationStatus::StartModeType {
	int l;
	char *s = Tcl_GetStringFromObj($input,&l);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (strncasecmp(s,"manual",l) == 0) {
		$1 = CommandStationStatus::Manual;
	} else if (strncasecmp(s,"automatic",l) == 0) {
		$1 = CommandStationStatus::Automatic;
	} else {
		Tcl_SetStringObj(tcl_result,"Unknown start mode type: '",-1);
		Tcl_AppendToObj(tcl_result, s, l);
		Tcl_AppendToObj(tcl_result,"', should be one of {manual automatic}",-1);
		return TCL_ERROR;
	}
}
#endif

/** Command station status.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class CommandStationStatus : public CommandStationResponse {
public:
	/**  Start mode.
	  */
	enum StartModeType {
		/**  Manual mode.
		  */
		Manual,
		/**  Automatic mode.
		  */
		Automatic
	};
#ifndef SWIG
	/**  Convert a start mode to a string.
	  * @param mode The mode value to convert.
	  */
	static const char *StartModeTypeString (StartModeType mode) {
		switch (mode) {
			case Manual: return "Manual";
			case Automatic: return "Automatic";
			default: return "";
		}
	}
	/** @brief Constructor.
	  * @param statusbyte Status byte.
	  */
	CommandStationStatus(unsigned char statusbyte) {
		Response_Type = COMMAND_STATION_STATUS;
		emergency_off = false;
		emergency_stop = false;
		start_mode = Manual;
		service_mode = false;
		poweringup = false;
		RAM_check_error = false;
		if ((statusbyte & 0x01) != 0) emergency_off = true;
		if ((statusbyte & 0x02) != 0) emergency_stop = true;
		if ((statusbyte & 0x04) != 0) start_mode = Automatic;
		if ((statusbyte & 0x08) != 0) service_mode = true;
		if ((statusbyte & 0x40) != 0) poweringup = true;
		if ((statusbyte & 0x080) != 0) RAM_check_error = true;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~CommandStationStatus() {}
	/**  Return emergency off flag.
	  */
	bool EmergencyOff () const {return emergency_off;}
	/**  Return emergency stop flag.
	  */
	bool EmergencyStop () const {return emergency_stop;}
	/**  Return start mode.
	  */
	StartModeType StartMode () const {return start_mode;}
	/**  Return service mode.
	  */
	bool ServiceMode () const {return service_mode;}
	/**  Return powering up flag.
	  */
	bool PoweringUp () const {return poweringup;}
	/**  Return RAM check error flag.
	  */
	bool RAMCheckError () const {return RAM_check_error;}
#ifndef SWIG
private:
	/**  Emergency off flag.
	  */
	bool emergency_off;
	/**  Emergency stop flag.
	  */
	bool emergency_stop;
	/**  Start mode.
	  */
	StartModeType start_mode;
	/**  Service mode flag.
	  */
	bool service_mode;
	/**  Powering up flag.
	  */
	bool poweringup;
	/**  RAM check error flag.
	  */
	bool RAM_check_error;
#endif
};

/** Transfer errors.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class TransferErrors : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	TransferErrors() {
		Response_Type = TRANSFER_ERRORS;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~TransferErrors() {}
};

/** Command station busy.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class CommandStationBusy : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	CommandStationBusy() {
		Response_Type = COMMAND_STATION_BUSY;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~CommandStationBusy() {}
};
	
/** Instruction not supported by command station.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class InstructionNotSupported : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  */
	InstructionNotSupported() {
		Response_Type = INSTRUCTION_NOT_SUPPORTED;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~InstructionNotSupported() {}
};

#ifdef SWIGTCL8
%typemap(out) AccessoryDecoderInformation::AccessoryTypeCode {
	Tcl_SetStringObj($result, (char *) AccessoryDecoderInformation::AccessoryTypeCodeString((AccessoryDecoderInformation::AccessoryTypeCode)$1),-1);
}

%typemap(out) AccessoryDecoderInformation::TurnoutStatusCode {
	Tcl_SetStringObj($result, (char *) AccessoryDecoderInformation::TurnoutStatusCodeString((AccessoryDecoderInformation::TurnoutStatusCode)$1),-1);
}

%typemap(out) AccessoryDecoderInformation::NibbleCode {
	Tcl_SetStringObj($result, (char *) AccessoryDecoderInformation::NibbleCodeString((AccessoryDecoderInformation::NibbleCode)$1),-1);
}

%typemap(in) AccessoryDecoderInformation::NibbleCode {
	int l;
	char *s = Tcl_GetStringFromObj($input,&l);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (strncasecmp(s,"lower",l) == 0) {
		$1 = AccessoryDecoderInformation::Lower;
	} else if (strncasecmp(s,"upper",l) == 0) {
		$1 = AccessoryDecoderInformation::Upper;
	} else {
		Tcl_SetStringObj(tcl_result,"Unknown nibble code: '",-1);
		Tcl_AppendToObj(tcl_result, s, l);
		Tcl_AppendToObj(tcl_result,"', should be one of {lower upper}",-1);
		return TCL_ERROR;
	}
}
#endif

/** Accessory decoder information.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class AccessoryDecoderInformation : public CommandStationResponse {
public:
	/**  Type of accessory.
	  */
	enum AccessoryTypeCode {
		/**  Decoder without feedback.
		  */
		AccessoryWithoutFeedback,
		/**  Decoder with feedback.
		  */
		AccessoryWithFeedback,
		/**  Feedback module.
		  */
		FeedbackModule,
		/**  Reserved.
		  */
		Reserved
	};
#ifndef SWIG
	/**  Convert AccessoryTypeCode to a string.
	  * @param code Code to convert.
	  */
	static char const *AccessoryTypeCodeString (AccessoryTypeCode code) {
		switch (code) {
			case AccessoryWithoutFeedback: return "AccessoryWithoutFeedback";
			case AccessoryWithFeedback:    return "AccessoryWithFeedback";
			case FeedbackModule:           return "FeedbackModule";
			case Reserved:                 return "Reserved";
			default: return "";
		}
	}
#endif
	/**  Turnout status.
	  */
	enum TurnoutStatusCode {
		/**  Not controlled during operating session.
		  */
		NotControlled,
		/**  Last command sent was 0 (left).
		  */
		Left,
		/**  Last command sent was 1 (right).
		  */
		Right,
		/**  Invalid.
		  */
		Invalid
	};
#ifndef SWIG
	/**  Convert TurnoutStatusCode to a string.
	  * @param code Code to convert.
	  */
	static char const *TurnoutStatusCodeString (TurnoutStatusCode code) {
		switch (code) {
			case NotControlled: return "NotControlled";
			case Left: return "Left";
			case Right: return "Right";
			case Invalid: return "Invalid";
			default: return "";
		}
	}
#endif
	/**  Nibble code.
	  */
	enum NibbleCode {
		/**  Lower nibble.
		  */
		Lower,
		/**  Upper nibble.
		  */
		Upper
	};
#ifndef SWIG
	/**  ConvertNibbleCode  to a string.
	  * @param code Code to convert.
	  */
	static char const *NibbleCodeString (NibbleCode code) {
		switch (code) {
			case Lower: return "Lower";
			case Upper: return "Upper";
			default: return "";
		}
	}
	/** @brief Constructor.
	  * @param count Number of Accessory Decoder feedback elements
	  *		   (1 through 7).
	  * @param a First address byte.
	  * @param d First packed data byte.
	  * @param ... Remaining addresses and datas.
	  */
	AccessoryDecoderInformation (unsigned int count,unsigned char a,
		unsigned char d,...);
#endif
	/** @brief Destructor.
	  */
	virtual ~AccessoryDecoderInformation () {}
	/**  Return the number of feedback elements.
	  */
	int NumberOfFeedbackElements() const {
		return numberOfFeedbackElements;
	}
	/**  Return address.
	  *  @param index Element index.
	  */
	unsigned char Address(int index) const {
		if (index >= 0 || index < numberOfFeedbackElements)
			return address[index];
		else	return 0;
	}
	/**  Return completed flag.
	  * @param index Element index.
	  */
	bool Completed(int index) const {
		if (index >= 0 || index < numberOfFeedbackElements)
			return completed[index];
		else	return false;
	}
	/**  Return accessory type.
	  * @param index Element index.
	  */
	AccessoryTypeCode AccessoryType(int index) const {
		if (index >= 0 || index < numberOfFeedbackElements)
			return accessory_type[index];
		else	return Reserved;
	}
	/**  Return nibble code.
	  * @param index Element index.
	  */
	NibbleCode Nibble(int index) const {
		if (index >= 0 || index < numberOfFeedbackElements)
			return nibble[index];
		else return Lower;
	}
	/**  Return turnout status.
	  *  @param index Element index.
	  *  @param nibble Which turnout?
	  */
	TurnoutStatusCode TurnoutStatus(int index,NibbleCode nibble) const {
		if (index >= 0 || index < numberOfFeedbackElements) {
			switch (nibble) {
				case Lower: return t1[index];
				case Upper: return t2[index];
				default: return Invalid;
			}
		} else return Invalid;
	}
#ifndef SWIG
private:
	/**  Number of Accessory Decoder feedback elements.
	  */
	int numberOfFeedbackElements;
	/**  Address value.
	  */
	unsigned char address[7];
	/**  Completion flag.
	  */
	bool completed[7];
	/**  Accessory type.
	  */
	AccessoryTypeCode accessory_type[7];
	/**  Nibble value.
	  */
	NibbleCode nibble[7];
	/**  Lower nibble turnout status.
	  */
	TurnoutStatusCode t1[7];
	/**  Upper nibble turnout status.
	  */
	TurnoutStatusCode t2[7];
#endif
};

#ifdef SWIGTCL8
%typemap(out) LocomotiveInformation::SpeedStepModeCode {
	Tcl_SetStringObj($result, (char *) LocomotiveInformation::SpeedStepModeCodeString((LocomotiveInformation::SpeedStepModeCode)$1),-1);

}

%typemap(in)  LocomotiveInformation::SpeedStepModeCode {
	int l;
	char *s = Tcl_GetStringFromObj($input,&l);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (strncasecmp(s,"s14",l) == 0) {
		$1 = LocomotiveInformation::S14;
	} else if (strncasecmp(s,"s27",l) == 0) {
		$1 = LocomotiveInformation::S27;
	} else if (strncasecmp(s,"s28",l) == 0) {
		$1 = LocomotiveInformation::S28;
	} else if (strncasecmp(s,"s128",l) == 0) {
		$1 = LocomotiveInformation::S128;
	} else {
		Tcl_SetStringObj(tcl_result,"Unknown speed step mode code: '",-1);
		Tcl_AppendToObj(tcl_result, s, l);
		Tcl_AppendToObj(tcl_result,"', should be one of {s14 s27 s28 s128}",-1);
		return TCL_ERROR;
	}
}

%typemap(out) LocomotiveInformation::DirectionCode {
	Tcl_SetStringObj($result, (char *) LocomotiveInformation::DirectionCodeString((LocomotiveInformation::DirectionCode)$1),-1);
}

%typemap(in) LocomotiveInformation::DirectionCode {
	int l;
	char *s = Tcl_GetStringFromObj($input,&l);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (strncasecmp(s,"forward",l) == 0) {
		$1 = LocomotiveInformation::Forward;
	} else if (strncasecmp(s,"reverse",l) == 0) {
		$1 = LocomotiveInformation::Reverse;
	} else {
		Tcl_SetStringObj(tcl_result,"Unknown direction code: '",-1);
		Tcl_AppendToObj(tcl_result, s, l);
		Tcl_AppendToObj(tcl_result,"', should be one of {forward reverse}",-1);
		return TCL_ERROR;
	}
}
#endif

/** Locomotive information.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class LocomotiveInformation : public CommandStationResponse {
public:
	/**  Speed step mode code.
	  */
	enum SpeedStepModeCode {
		/**  14 speed step mode.
		  */
		S14,
		/**  27 speed step mode.
		  */
		S27,
		/**  28 speed step mode.
		  */
		S28,
		/**  128 speed step mode.
		  */
		S128
	};
#ifndef SWIG
	/**  Convert Speed step mode code to a string.
	  * @param code Code to convert.
	  */
	static char *SpeedStepModeCodeString(SpeedStepModeCode code) {
		switch (code) {
			case S14: return "S14";
			case S27: return "S27";
			case S28: return "S28";
			case S128: return "S128";
			default: return "";
		}
	}
#endif
	/**  Direction flag.
	  */
	enum DirectionCode {
		/**  Forward.
		  */
		Forward,
		/**  Reverse.
		  */
		Reverse
	};
#ifndef SWIG
	/**  Convert direction flag code to string.
	  * @param code Direction flag code to convert.
	  */
	static const char *DirectionCodeString(DirectionCode code) {
		switch (code) {
			case Forward: return "Forward";
			case Reverse: return "Reverse";
			default: return "";
		}
	}
	/** @brief Constructor.
	  * @param a Locomotive address.
	  * @param avail Available flag.
	  * @param dir Direction.
	  * @param ssm Speed step mode.
	  * @param s Locomotive speed.
	  * @param f0 Function 0 status.
	  * @param f1 Function 1 status.
	  * @param f2 Function 2 status.
	  * @param f3 Function 3 status.
	  * @param f4 Function 4 status.
	  * @param f5 Function 5 status.
	  * @param f6 Function 6 status.
	  * @param f7 Function 7 status.
	  * @param f8 Function 8 status.
	  * @param f9 Function 9 status.
	  * @param f10 Function 10 status.
	  * @param f11 Function 11 status.
	  * @param f12 Function 12 status.
	  * @param mtraddr MTR address.
	  * @param addr2 Double header address.
	  */
	LocomotiveInformation(unsigned short int a,bool avail,DirectionCode dir,
		SpeedStepModeCode ssm,unsigned char s,bool f0,bool f1,bool f2,
		bool f3,bool f4,bool f5 = false,bool f6 = false,bool f7 = false,
		bool f8 = false,bool f9 = false,bool f10 = false,
		bool f11 = false,bool f12 = false,unsigned char mtraddr = 0,
		unsigned short int addr2 = 0xffff) {
		Response_Type = LOCOMOTIVE_INFORMATION;
		address = a;
		available = avail;
		direction = dir;
		speedstep = ssm;
		speed = s;
		function0 = f0;
		function1 = f1;
		function2 = f2;
		function3 = f3;
		function4 = f4;
		function5 = f5;
		function6 = f6;
		function7 = f7;
		function8 = f8;
		function9 = f9;
		function10 = f10;
		function11 = f11;
		function12 = f12;
		mtraddress = mtraddr;
		address2 = addr2;
	}
	/** @brief Constructor.
	  * @param a Locomotive address.
	  */
	LocomotiveInformation(unsigned short int a) {
		Response_Type = LOCOMOTIVE_INFORMATION;
		address = a;
		available = false;
	}
	/** @brief Constructor.
	  * @param a Locomotive address.
	  * @param avail Available flag.
	  * @param dir Direction.
	  * @param ssm Speed step mode.
	  * @param s Locomotive speed.
	  */
	LocomotiveInformation(unsigned short int a,bool avail,DirectionCode dir,
		SpeedStepModeCode ssm,unsigned char s) {
		Response_Type = LOCOMOTIVE_INFORMATION;
		address = a;
		available = avail;
		direction = dir;
		speedstep = ssm;
		speed = s;
		mtraddress = a;
	}	
#endif
	/** @brief Destructor.
	  */
	virtual ~LocomotiveInformation() {};
	/**  Return address.
	  */
	unsigned short int Address() const {return address;}
	/**  Return available flag.
	  */
	bool Available() const {return available;}
	/**  Return direction.
	  */
	DirectionCode Direction() const {return direction;}
	/**  Return speed step mode.
	  */
	SpeedStepModeCode SpeedStepMode() const {return speedstep;}
	/**  Return speed.
	  */
	unsigned char Speed() const {return speed;}
	/**  Return function status.
	  * @param f Function whose status to return.
	  */
	bool Function(int f) const {
		switch (f) {
			case 0: return function0;
			case 1: return function1;
			case 2: return function2;
			case 3: return function3;
			case 4: return function4;
			case 5: return function5;
			case 6: return function6;
			case 7: return function7;
			case 8: return function8;
			case 9: return function9;
			case 10: return function10;
			case 11: return function11;
			case 12: return function12;
			default: return false;
		}
	}
	/**  Return Muti-unit address.
	  */
	unsigned char MTR() const {return mtraddress;}
	/**  Return the address of second unit in double header.
	  */
	unsigned short int Address2() const {return address2;}
#ifndef SWIG
private:
	/**  Locomotive address.
	  */
	unsigned short int address;
	/**  Locomotive is available.
	  */
	bool available;
	/**  Locomotive direction.
	  */
	DirectionCode direction;
	/**  Locomotive speed step mode.
	  */
	SpeedStepModeCode speedstep;
	/**  Locomotive speed.
	  */
	unsigned char speed;
	/**  Function 0.
	  */
	bool function0;
	/**  Function 1.
	  */
	bool function1;
	/**  Function 2.
	  */
	bool function2;
	/**  Function 3.
	  */
	bool function3;
	/**  Function 4.
	  */
	bool function4;
	/**  Function 5.
	  */
	bool function5;
	/**  Function 6.
	  */
	bool function6;
	/**  Function 7.
	  */
	bool function7;
	/**  Function 8.
	  */
	bool function8;
	/**  Function 9.
	  */
	bool function9;
	/**  Function 10.
	  */
	bool function10;
	/**  Function 11.
	  */
	bool function11;
	/**  Function 12.
	  */
	bool function12;
	/**  Multi-unit address.
	  */
	unsigned char mtraddress;
	/**  Double header address.
	  */
	unsigned short int address2;
#endif
};

/** Function status.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class FunctionStatus : public CommandStationResponse {
public:
#ifndef SWIG
	/** @brief Constructor.
	  * @param s0 Function 0 is monemtary flag.
	  * @param s1 Function 1 is monemtary flag.
	  * @param s2 Function 2 is monemtary flag.
	  * @param s3 Function 3 is monemtary flag.
	  * @param s4 Function 4 is monemtary flag.
	  * @param s5 Function 5 is monemtary flag.
	  * @param s6 Function 6 is monemtary flag.
	  * @param s7 Function 7 is monemtary flag.
	  * @param s8 Function 8 is monemtary flag.
	  * @param s9 Function 9 is monemtary flag.
	  * @param s10 Function 10 is monemtary flag.
	  * @param s11 Function 11 is monemtary flag.
	  * @param s12 Function 12 is monemtary flag.
	  */
	FunctionStatus(bool s0,bool s1,bool s2,bool s3,bool s4,bool s5,
		bool s6,bool s7,bool s8,bool s9,bool s10,bool s11,bool s12) {
		Response_Type = FUNCTION_STATUS;
		status0 = s0;
		status1 = s1;
		status2 = s2;
		status3 = s3;
		status4 = s4;
		status5 = s5;
		status6 = s6;
		status7 = s7;
		status8 = s8;
		status9 = s9;
		status10 = s10;
		status11 = s11;
		status12 = s12;
	}
#endif
	/** @brief Descructor.
	  */
	virtual ~FunctionStatus() {}
	/**  Return selected status flag.
	  * @param f  Function whose status to return.
	  */
	bool Status(int f) const {
		switch (f) {
			case 0: return status0;
			case 1: return status1;
			case 2: return status2;
			case 3: return status3;
			case 4: return status4;
			case 5: return status5;
			case 6: return status6;
			case 7: return status7;
			case 8: return status8;
			case 9: return status9;
			case 10: return status10;
			case 11: return status11;
			case 12: return status12;
			default: return false;
		}
	}
#ifndef SWIG
private:
	/**  Status 0.
	  */
	bool status0;
	/**  Status 1.
	  */
	bool status1;
	/**  Status 2.
	  */
	bool status2;
	/**  Status 3.
	  */
	bool status3;
	/**  Status 4.
	  */
	bool status4;
	/**  Status 5.
	  */
	bool status5;
	/**  Status 6.
	  */
	bool status6;
	/**  Status 7.
	  */
	bool status7;
	/**  Status 8.
	  */
	bool status8;
	/**  Status 9.
	  */
	bool status9;
	/**  Status 10.
	  */
	bool status10;
	/**  Status 11.
	  */
	bool status11;
	/**  Status 12.
	  */
	bool status12;
#endif
};

#ifdef SWIGTCL8
%typemap(out) LocomotiveAddress::AddressTypeCode {
	Tcl_SetStringObj($result, (char *) LocomotiveAddress::AddressTypeCodeString((LocomotiveAddress::AddressTypeCode)$1),-1);
}
#endif

/** Locomotive address.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class LocomotiveAddress : public CommandStationResponse {
public:
	/**  Address type code.
	  */
	enum AddressTypeCode {
		/**  Normal locomotive address.
		  */
		Normal,
		/**  Double header address.
		  */
		DoubleHeader,
		/**  Multi-unit base address.
		  */
		MultiUnitBase,
		/**  Multi-unit address.
		  */
		MultiUnit,
		/**  Other or no such locomotive.
		  */
		OtherOrNone
	};
#ifndef SWIG
	/**  Convert a address type code to a string.
	  * @param code The code to convert. 
	  */
	static const char *AddressTypeCodeString(AddressTypeCode code) {
		switch (code) {
			case Normal: return "Normal";
			case DoubleHeader: return "DoubleHeader";
			case MultiUnitBase: return "MultiUnitBase";
			case MultiUnit: return "MultiUnit";
			case OtherOrNone: return "OtherOrNone";
			default: return "";
		}
	}
#endif
	/**  Return address type.
	  */
	AddressTypeCode AddressType () const {return addressType;}
	/**  Return address.
	  */
	unsigned short int Address () const {return address;}
#ifndef SWIG
	/** @brief Constructor.
	  * @param k K (address type code).
	  * @param a Address.
	  */
	LocomotiveAddress(unsigned char k,unsigned short int a) {
		Response_Type = LOCOMOTIVE_ADDRESS;
		switch (k) {
			case 0: addressType = Normal; break;
			case 1: addressType = DoubleHeader; break;
			case 2: addressType = MultiUnitBase; break;
			case 3: addressType = MultiUnit; break;
			case 4: addressType = OtherOrNone; break;
			default: addressType = OtherOrNone;
		}
		address = a;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~LocomotiveAddress() {}
#ifndef SWIG
private:
	/**  Address type.
	  */
	AddressTypeCode addressType;
	/**  Address.
	  */
	unsigned short int address;
#endif
};

#ifdef SWIGTCL8
%typemap(out) DoubleHeaderInformation::SpeedStepModeCode {
	Tcl_SetStringObj($result, (char *) DoubleHeaderInformation::SpeedStepModeCodeString((DoubleHeaderInformation::SpeedStepModeCode)$1),-1);
}

%typemap(in)  DoubleHeaderInformation::SpeedStepModeCode {
	int l;
	char *s = Tcl_GetStringFromObj($input,&l);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (strncasecmp(s,"s14",l) == 0) {
		$1 = DoubleHeaderInformation::S14;
	} else if (strncasecmp(s,"s27",l) == 0) {
		$1 = DoubleHeaderInformation::S27;
	} else if (strncasecmp(s,"s28",l) == 0) {
		$1 = DoubleHeaderInformation::S28;
	} else if (strncasecmp(s,"s128",l) == 0) {
		$1 = DoubleHeaderInformation::S128;
	} else {
		Tcl_SetStringObj(tcl_result,"Unknown speed step mode code: '",-1);
		Tcl_AppendToObj(tcl_result, s, l);
		Tcl_AppendToObj(tcl_result,"', should be one of {s14 s27 s28 s128}",-1);
		return TCL_ERROR;
	}
}

%typemap(out) DoubleHeaderInformation::DirectionCode {
	Tcl_SetStringObj($result, (char *) DoubleHeaderInformation::DirectionCodeString((DoubleHeaderInformation::DirectionCode)$1),-1);
}

%typemap(in) DoubleHeaderInformation::DirectionCode {
	int l;
	char *s = Tcl_GetStringFromObj($input,&l);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (strncasecmp(s,"forward",l) == 0) {
		$1 = DoubleHeaderInformation::Forward;
	} else if (strncasecmp(s,"reverse",l) == 0) {
		$1 = DoubleHeaderInformation::Reverse;
	} else {
		Tcl_SetStringObj(tcl_result,"Unknown direction code: '",-1);
		Tcl_AppendToObj(tcl_result, s, l);
		Tcl_AppendToObj(tcl_result,"', should be one of {forward reverse}",-1);
		return TCL_ERROR;
	}
}
#endif

/** Double header information.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class DoubleHeaderInformation : public CommandStationResponse {
public:
	/**  Speed step mode code.
	  */
	enum SpeedStepModeCode {
		/**  14 speed step mode.
		  */
		S14,
		/**  27 speed step mode.
		  */
		S27,
		/**  28 speed step mode.
		  */
		S28,
		/**  128 speed step mode.
		  */
		S128
	};
#ifndef SWIG
	/**  Convert Speed step mode code to a string.
	  * @param code Code to convert.
	  */
	static char *SpeedStepModeCodeString(SpeedStepModeCode code) {
		switch (code) {
			case S14: return "S14";
			case S27: return "S27";
			case S28: return "S28";
			case S128: return "S128";
			default: return "";
		}
	}
#endif
	/**  Direction flag.
	  */
	enum DirectionCode {
		/**  Forward.
		  */
		Forward,
		/**  Reverse.
		  */
		Reverse
	};
#ifndef SWIG
	/**  Convert direction flag code to string.
	  * @param code Direction flag code to convert.
	  */
	static const char *DirectionCodeString(DirectionCode code) {
		switch (code) {
			case Forward: return "Forward";
			case Reverse: return "Reverse";
			default: return "";
		}
	}
	/** @brief Constructor.
	  * @param a Locomotive address.
	  * @param addr2 Double header address.
	  * @param avail Available flag.
	  * @param dir Direction.
	  * @param ssm Speed step mode.
	  * @param s Locomotive speed.
	  * @param f0 Function 0 status.
	  * @param f1 Function 1 status.
	  * @param f2 Function 2 status.
	  * @param f3 Function 3 status.
	  * @param f4 Function 4 status.
	  * @param f5 Function 5 status.
	  * @param f6 Function 6 status.
	  * @param f7 Function 7 status.
	  * @param f8 Function 8 status.
	  * @param f9 Function 9 status.
	  * @param f10 Function 10 status.
	  * @param f11 Function 11 status.
	  * @param f12 Function 12 status.
	  */
	DoubleHeaderInformation(unsigned short int a,unsigned short int addr2,
		bool avail,DirectionCode dir,SpeedStepModeCode ssm,
		unsigned char s,bool f0,bool f1,bool f2,bool f3,bool f4,
		bool f5 = false,bool f6 = false,bool f7 = false,bool f8 = false,
		bool f9 = false,bool f10 = false,bool f11 = false,
		bool f12 = false) {
		Response_Type = DOUBLE_HEADER_INFORMATION;
		address = a;
		address2 = addr2;
		available = avail;
		direction = dir;
		speedstep = ssm;
		speed = s;
		function0 = f0;
		function1 = f1;
		function2 = f2;
		function3 = f3;
		function4 = f4;
		function5 = f5;
		function6 = f6;
		function7 = f7;
		function8 = f8;
		function9 = f9;
		function10 = f10;
		function11 = f11;
		function12 = f12;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~DoubleHeaderInformation() {}
	/**  Return address.
	  */
	unsigned short int Address() const {return address;}
	/**  Return available flag.
	  */
	bool Available() const {return available;}
	/**  Return direction.
	  */
	DirectionCode Direction() const {return direction;}
	/**  Return speed step mode.
	  */
	SpeedStepModeCode SpeedStepMode() const {return speedstep;}
	/**  Return speed.
	  */
	unsigned char Speed() const {return speed;}
	/**  Return function status.
	  * @param f Function whose status to return.
	  */
	bool Function(int f) const {
		switch (f) {
			case 0: return function0;
			case 1: return function1;
			case 2: return function2;
			case 3: return function3;
			case 4: return function4;
			case 5: return function5;
			case 6: return function6;
			case 7: return function7;
			case 8: return function8;
			case 9: return function9;
			case 10: return function10;
			case 11: return function11;
			case 12: return function12;
			default: return false;
		}
	}
	/**  Return the address of second unit in double header.
	  */
	unsigned short int Address2() const {return address2;}
#ifndef SWIG
private:
	/**  Locomotive address.
	  */
	unsigned short int address;
	/**  Locomotive is available.
	  */
	bool available;
	/**  Locomotive direction.
	  */
	DirectionCode direction;
	/**  Locomotive speed step mode.
	  */
	SpeedStepModeCode speedstep;
	/**  Locomotive speed.
	  */
	unsigned char speed;
	/**  Function 0.
	  */
	bool function0;
	/**  Function 1.
	  */
	bool function1;
	/**  Function 2.
	  */
	bool function2;
	/**  Function 3.
	  */
	bool function3;
	/**  Function 4.
	  */
	bool function4;
	/**  Function 5.
	  */
	bool function5;
	/**  Function 6.
	  */
	bool function6;
	/**  Function 7.
	  */
	bool function7;
	/**  Function 8.
	  */
	bool function8;
	/**  Function 9.
	  */
	bool function9;
	/**  Function 10.
	  */
	bool function10;
	/**  Function 11.
	  */
	bool function11;
	/**  Function 12.
	  */
	bool function12;
	/**  Double header address.
	  */
	unsigned short int address2;
#endif
};

#ifdef SWIGTCL8
%typemap(out) DoubleHeaderMuError::ErrorTypeCode {
	Tcl_SetStringObj($result, (char *) DoubleHeaderMuError::ErrorTypeCodeString((DoubleHeaderMuError::ErrorTypeCode)$1),-1);
}
#endif

/** Double header or MU error.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class DoubleHeaderMuError : public CommandStationResponse {
public:
	/**  Error type code.
	  */
	enum ErrorTypeCode {
		/**   One of the locomotives has not been operated by
		  *	   the XpressNet device assembling the Double 
		  *	   Header/Multi Unit or locomotive 0 was selected. 
		  */
		NotOperatedOr0,
		/**   One of the locomotives of the Double Header/Multi
		  *	   Unit is being used by another XpressNet device.
		  */
		UsedByAnotherDevice,
		/**   One of the locomotives is already in another
		  *	   Double Header/Multi Unit. 
		  */
		UsedInANotherDHMU,
		/**  The speed of one of the locomotives is not zero.
		  */
		SpeedNotZero,
		/**  The locomotive is not a multi-unit.
		  */
		NotMU,
		/**  The locomotive is not a multi-unit base address.
		  */
		NotMUBaseAddress,
		/**  It is not possible to delete the locomotive.
		  */
		CantDelete,
		/**  The command station stack is full.
		  */
		StackFull
	};
#ifndef SWIG
	/**  Convert the error type code to a string.
	  * @param code Error type.
	  */
	static const char *ErrorTypeCodeString (ErrorTypeCode code) {
		switch (code) {
			case NotOperatedOr0: return "NotOperatedOr0";
			case UsedByAnotherDevice: return "UsedByAnotherDevice";
			case UsedInANotherDHMU: return "UsedInANotherDHMU";
			case SpeedNotZero: return "SpeedNotZero";
			case NotMU: return "NotMU";
			case NotMUBaseAddress: return "NotMUBaseAddress";
			case CantDelete: return "CantDelete";
			case StackFull: return "StackFull";
			default: return "";
		}
	}
	/** @brief Constructor.
	  * @param e Error type.
	  */
	DoubleHeaderMuError(ErrorTypeCode e) {
		Response_Type = DOUBLE_HEADER_MU_ERROR;
		error = e;
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~DoubleHeaderMuError() {}
	/**  Return error type code.
	  */
	ErrorTypeCode Error() const { return error; }
#ifndef SWIG
private:
	/**  Error type.
	  */
	ErrorTypeCode error;
#endif
};

#ifdef SWIGTCL8
%typemap(out) LI100Message::MessageTypeCode {
	Tcl_SetStringObj($result, (char *) LI100Message::MessageTypeCodeString((LI100Message::MessageTypeCode)$1),-1);
}
#endif

/** LI100 messages.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class LI100Message : public CommandStationResponse {
public:
	/**  Message type code.
	  */
	enum MessageTypeCode {
		/**   Error occured between the interface and the PC.
		  *	(Timeout durring data communication with the PC.) 
		  */
		ErrorBetweenLI100AndPC,
		/**   Error occured between the interface and the
		  *	command station. (Timeout durring data 
		  *	communication with the command station.)
		  */
		ErrorBetweenLI100AndCommandStation,
		/**   Unknown communication error. (Command station
		  *	addressed the LI100 with request for 
		  *	acknowledgement.) 
		  */
		UnknownCommunicationsError,
		/**   Instruction was successfully sent to the command
		  *	station or normal operations have resumed after a 
		  *	timeout. 
		  */
		Success,
		/**   The command station is no longer providing the
		  *	LI100 a timeslot for communication.
		  */
		NoTimeslot,
		/**   Buffer overflow in the LI100.
		  */
		BufferOverflow,
		/**   Other messages (undefined).
		  */
		Other
	};
#ifndef SWIG
	/**  Convert the message type code to a string.
	  * @param code Message type code to convert.
	  */
	static const char *MessageTypeCodeString(MessageTypeCode code) {
		switch (code) {
			case ErrorBetweenLI100AndPC:
				return "ErrorBetweenLI100AndPC";
			case ErrorBetweenLI100AndCommandStation:
				return "ErrorBetweenLI100AndCommandStation";
			case UnknownCommunicationsError:
				return "UnknownCOmmunicationsError";
			case Success:
				return "Success";
			case NoTimeslot:
				return "NoTimeslot";
			case BufferOverflow:
				return "BufferOverflow";
			case Other:
				return "Other";
			default: return "";
		}
	}
	/** @brief Constructor.
	  * @param mbyte Message byte.
	  */
	LI100Message(unsigned char mbyte) {
		Response_Type = LI100_MESSAGE;
		switch (mbyte) {
			case 1: message_type = ErrorBetweenLI100AndPC; break;
			case 2: message_type = ErrorBetweenLI100AndCommandStation; break;
			case 3: message_type = UnknownCommunicationsError; break;
			case 4: message_type = Success; break;
			case 5: message_type = NoTimeslot; break;
			case 6: message_type = BufferOverflow; break;
			default: message_type = Other; break;
		}
	}
#endif
	/** @brief Destructor.
	  */
	virtual ~LI100Message() {}
	/**  Return the message type.
	  */
	MessageTypeCode MessageType() const {return message_type;}
#ifndef SWIG
private:
	/**  The message type.
	  */
	MessageTypeCode message_type;
#endif
};


/** @brief Main XPressNet interface class.
  *
  * This class implements the interface logic
  *  to connect a Linux PC to an XpressNet.
  *
  *  Some of the public member functions can take a pointer to a place to store
  * an allocated (with @c new()) string containing an error message.  If 
  * @c NULL is passed, no error reporting is done--error checking is still 
  * done, just that the calling program gets no indication of it, except that 
  * the @c Inputs() function will return @c NULL.  If the message 
  * pointer is non @c NULL, a @c char array is allocated with 
  * @c new() and this array is filled with an error message. The calling 
  * program should delete this memory when it is done with it, otherwise
  * the calling program will leak memory.  If there are no errors, this pointer
  * is not changed.  The calling program should initialize this pointer to
  * @c NULL and then test for a non @c NULL value as an indication of
  * a possible error.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */
class XPressNet {
public:
#ifdef SWIGTCL8
	%typemap(default) const char *port {$1 = "/dev/ttyS0";}
	XPressNet(const char *port,char **outmessage);
#else
	/**  The constructor opens
	  * the serial port and initializes the port.
	  * @param port The serial port device file.
	  * @param outmessage This holds a pointer to an error message, if any.
	  */
	XPressNet(const char *port="/dev/ttyS0",char **outmessage=NULL);
#endif
	/** The destructor restores
	  * the serial port's state and closes it.
	  */
	~XPressNet();
#ifdef SWIGTCL8
	CommandStationResponse::TypeCode CheckForResponse(char **outmessage);
#else
	/**  Check for a response from the command station.
	  */
	CommandStationResponse::TypeCode CheckForResponse(char **outmessage=NULL);
#endif
#ifdef SWIGTCL8
	CommandStationResponse *GetNextCommandStationResponse(char **outmessage);
#else
	/**  Return the next response from the command station.
	  */
	CommandStationResponse *GetNextCommandStationResponse(char **outmessage=NULL);
#endif
	/**  Resume operations request.
	  */
	void ResumeOperations();
	/**  Stop operations request.
	  */
	void StopOperations();
	/**  Emergency stop all locomotives.
	  */
	void EmergencyStopAllLocomotives();
	/**  Emergency stop a locomotive.
	  * @param la Address of the locomotive to stop.
	  */
	void EmergencyStopALocomotive(unsigned short la);
	/**  Register mode read.
	  * @param r Register to read.
	  */
	void RegisterModeRead(unsigned char r);
	/**  Direct mode CV read.
	  * @param cv CV to read.
	  */
	void DirectModeCVRead(unsigned char cv);
	/**  Paged mode CV read.
	  * @param cv CV to read.
	  */
	void PagedModeCVRead(unsigned char cv);
	/**  Request for service mode results.
	  */
	void RequestForServiceModeResults();
	/**  Register mode write.
	  * @param r Register to write to.
	  * @param d Data to write.
	  */
	void RegisterModeWrite(unsigned char r,unsigned char d);
	/**  Direct mode CV write.
	  * @param cv CV to write to.
	  * @param d Data to write.
	  */
	void DirectModeCVWrite(unsigned char cv,unsigned char d);
	/**  Paged mode CV write.
	  * @param cv CV to write to.
	  * @param d Data to write.
	  */
	void PagedModeCVWrite(unsigned char cv,unsigned char d);
	/**  Command station software version request.
	  */
	void CommandStationSoftwareVersion();
	/**  Command station status request.
	  */
	void CommandStationStatusRequest();
	/**  Set command station power up mode.
	  * @param mode Mode to set.
	  */
	void SetCommandStationPowerUpMode(
		CommandStationStatus::StartModeType mode);
	/**  Accessory decoder information request.
	  * @param address Address of decoder.
	  * @param nibble Which nibble.
	  */
	void AccessoryDecoderInformationRequest(unsigned char address,
		AccessoryDecoderInformation::NibbleCode nibble);
	/**  Accessory decoder operation request.
	  * @param groupaddr Address of decoder.
	  * @param elementaddr Address of element.
	  * @param activateOutput Set or clear output.
	  * @param useOutput2 Use output 2?
	  */
	void AccessoryDecoderOperation(unsigned char groupaddr,
		unsigned char elementaddr,bool activateOutput,
		bool useOutput2);
	/**  Locomotive information request.
	  * @param address Address of locomotive.
	  */
	void LocomotiveInformationRequest(unsigned short int address);
	/**  Function status request.
	  * @param address Address of locomotive.
	  */
	void FunctionStatusRequest(unsigned short int address);
	/**  Set locomotive speed and direction.
	  * @param address Address of locomotive.
	  * @param ssm Speed step mode to use.
	  * @param dir Desired direction.
	  * @param speed Desired speed.
	  */
	void SetLocomotiveSpeedAndDirection(unsigned short int address,
		LocomotiveInformation::SpeedStepModeCode ssm,
		LocomotiveInformation::DirectionCode dir,
		unsigned char speed);
	/**  Set locomotive functions, group 1.
	  * @param address Locomotive address.
	  * @param f0 Function 0.
	  * @param f1 Function 1.
	  * @param f2 Function 2.
	  * @param f3 Function 3.
	  * @param f4 Function 4.
	  */
	void SetLocomotiveFunctionsGroup1(unsigned short int address,bool f0,
		bool f1,bool f2,bool f3,bool f4);
	/**  Set locomotive functions, group 2.
	  * @param address Locomotive address.
	  * @param f5 Function 5.
	  * @param f6 Function 6.
	  * @param f7 Function 7.
	  * @param f8 Function 8.
	  */
	void SetLocomotiveFunctionsGroup2(unsigned short int address,bool f5,
		bool f6,bool f7,bool f8);
	/**  Set locomotive functions, group 3.
	  * @param address Locomotive address.
	  * @param f9 Function 9.
	  * @param f10 Function 10.
	  * @param f11 Function 11.
	  * @param f12 Function 12.
	  */
	void SetLocomotiveFunctionsGroup3(unsigned short int address,bool f9,
		bool f10,bool f11,bool f12);
	/**  Set locomotive function state, group 1.
	  * @param address Locomotive address.
	  * @param f0 Function 0.
	  * @param f1 Function 1.
	  * @param f2 Function 2.
	  * @param f3 Function 3.
	  * @param f4 Function 4.
	  */
	void SetFunctionStateGroup1(unsigned short int address,bool f0,
		bool f1,bool f2,bool f3,bool f4);
	/**  Set locomotive function state, group 2.
	  * @param address Locomotive address.
	  * @param f5 Function 5.
	  * @param f6 Function 6.
	  * @param f7 Function 7.
	  * @param f8 Function 8.
	  */
	void SetFunctionStateGroup2(unsigned short int address,	bool f5,
		bool f6,bool f7,bool f8);
	/**  Set locomotive function state, group 3.
	  * @param address Locomotive address.
	  * @param f9 Function 9.
	  * @param f10 Function 10.
	  * @param f11 Function 11.
	  * @param f12 Function 12.
	  */
	void SetFunctionStateGroup3(unsigned short int address,bool f9,
		bool f10,bool f11,bool f12);
	/**  Establish a double header.
	  * @param address1 Locomotive address1.
	  * @param address2 Locomotive address2.
	  */
	void EstablishDoubleHeader(unsigned short int address1,
		unsigned short int address2);
	/**  Dissolve a double header.
	  * @param address1 Locomotive address1.
	  */
	void DissolveDoubleHeader(unsigned short int address1) {
		EstablishDoubleHeader(address1,0);
	}
	/**  Operating mode programming byte mode write.
	  * @param address Locomotive address.
	  * @param cv CV to set.
	  * @param data Data to set.
	  */
	void OperatingModeProgrammingByteModeWrite(unsigned short int address,
		unsigned short int cv,unsigned char data);
	/**  Operating mode programming bit mode write.
	  * @param address Locomotive address.
	  * @param cv CV to set.
	  * @param bitnum Bit number.
	  * @param value Value to set.
	  */
	void OperatingModeProgrammingBitModeWrite(unsigned short int address,
		unsigned short int cv,unsigned char bitnum,bool value);
	/**  Add locomotive to Multi-Unit.
	  * @param address Locomotive address.
	  * @param mtr Multi-Unit address.
	  * @param samedirection The locomotive direction is the same as the
	  *	 consist direction.
	  */
	void AddLocomotiveToMultiUnit(unsigned short int address,
		unsigned char mtr,bool samedirection);
	/**  Remove locomotive to Multi-Unit.
	  * @param address Locomotive address.
	  * @param mtr Multi-Unit address.
	  */
	void RemoveLocomotiveFromMultiUnit(unsigned short int address,
		unsigned char mtr);
	/**  Address inquire next MU member.
	  * @param mtr Multi-Unit address.
	  * @param address Locomotive address.
	  */
	void AddressInquiryNextMUMember(unsigned char mtr,
		unsigned short int address);
	/**  Address inquire previous MU member.
	  * @param mtr Multi-Unit address.
	  * @param address Locomotive address.
	  */
	void AddressInquiryPreviousMUMember(unsigned char mtr,
		unsigned short int address);
	/**  Address inquire next MU.
	  * @param mtr Multi-Unit address.
	  */
	void AddressInquiryNextMU(unsigned char mtr);
	/**  Address inquire previous MU.
	  * @param mtr Multi-Unit address.
	  */
	void AddressInquiryPreviousMU(unsigned char mtr);
	/**  Address inquire next stack.
	  * @param address Locomotive address.
	  */
	void AddressInquiryNextStack(unsigned short int address);
	/**  Address inquire previous stack.
	  * @param address Locomotive address.
	  */
	void AddressInquiryPreviousStack(unsigned short int address);
	/**  Delete locomotive from stack.
	  * @param address Locomotive address.
	  */
	void DeleteLocomotiveFromStack(unsigned short int address);
	/**  Return hardware version.
	  */
	unsigned char LI100HardwareVersion() const {return hardware_version;}
	/**  Return software version.
	  */
	unsigned char LI100SoftwareVersion() const {return software_version;}
#ifndef SWIG
private:
	/**  Terminal file descriptor.
	  */
	int ttyfd;
	/** Saved serial port settings.
	  */
	struct termios savedtermios;
	/** Current serial port settings.
	  */
	struct termios currenttermios;
	/**  Response list.
	  */
	CommandStationResponse *responseList;
	/**  Hardware version.
	  */
	unsigned char hardware_version;
	/**  Software version.
	  */
	unsigned char software_version;
#endif
};

/** @} */

};

/** @} */
 
#endif // _XPRESSNET_H_

