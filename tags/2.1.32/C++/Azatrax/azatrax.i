%module Azatrax
%{      
#include <Azatrax.h>
#include <mrd.h>
#include <sl2.h>
#include <sr4.h>
#include "gettext.h"
static char rcsid[] = "$Id$";
using namespace azatrax;
%}      
        
%include typemaps.i

%typemap(out) int MyTcl_Result {
         return $1;
}

          
%{         
#undef SWIG_name
#define SWIG_name "Azatrax"
#undef SWIG_version             
#define SWIG_version AZATRAX_VERSION
%}

/*
 * Type map to handle error messages.  Hide this parameter from Tcl, but return
 * it as a second result, returning TCL_ERROR, if there is an error message.
 */

namespace mrd {

#ifdef SWIGTCL8
%typemap(in,numinputs=0) char **outmessage {
	$1 = new char*;
	*$1 = NULL;
}

%typemap(argout) char **outmessage {
	Tcl_Obj * tcl_result = $result;
	if (*$1 != NULL) {
		int mlen = strlen(*$1);
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewStringObj(*$1,mlen)) != TCL_OK) {
			delete *$1;
			delete $1;
			return TCL_ERROR;
		}
		delete *$1;
		delete $1;
		return TCL_ERROR;
	}
	delete $1;
}

/*
 * Type maps for MRD::OperatingMode_Type (enumerated type).  Convert the
 * enumerated to a string representation.
 */

%typemap(out) MRD::OperatingMode_Type {
  Tcl_Obj * tcl_result = $result;
  switch ($1) {
    case MRD::NonTurnoutSeparate: Tcl_SetStringObj(tcl_result,_("NonTurnoutSeparate"),-1); break;
    case MRD::NonTurnoutDirectionSensing: Tcl_SetStringObj(tcl_result,_("NonTurnoutDirectionSensing"),-1); break;
    case MRD::TurnoutSolenoid: Tcl_SetStringObj(tcl_result,_("TurnoutSolenoid"),-1); break;
    case MRD::TurnoutMotor: Tcl_SetStringObj(tcl_result,_("TurnoutMotor"),-1); break;
  }
}

/*
 * Type maps for ErrorCode.  Returns the LIBUSB error code name w/ TCL_ERROR
 * if there is a LIBUSB error.  Otherwise an empty string and TCL_OK.
 */

%typemap(out) ErrorCode {
  Tcl_Obj * tcl_result = $result;
  switch ($1) {
    case LIBUSB_SUCCESS: Tcl_SetStringObj(tcl_result,"",-1); break;
    case LIBUSB_ERROR_IO: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_IO",-1); return TCL_ERROR;
    case LIBUSB_ERROR_INVALID_PARAM: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_INVALID_PARAM",-1); return TCL_ERROR;
    case LIBUSB_ERROR_ACCESS: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_ACCESS",-1); return TCL_ERROR;
    case LIBUSB_ERROR_NO_DEVICE: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_NO_DEVICE",-1); return TCL_ERROR;
    case LIBUSB_ERROR_NOT_FOUND: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_NOT_FOUND",-1); return TCL_ERROR;
    case LIBUSB_ERROR_BUSY: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_BUSY",-1); return TCL_ERROR;
    case LIBUSB_ERROR_TIMEOUT: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_TIMEOUT",-1); return TCL_ERROR;
    case LIBUSB_ERROR_OVERFLOW: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_OVERFLOW",-1); return TCL_ERROR;
    case LIBUSB_ERROR_PIPE: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_PIPE",-1); return TCL_ERROR;
    case LIBUSB_ERROR_INTERRUPTED: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_INTERRUPTED",-1); return TCL_ERROR;
    case LIBUSB_ERROR_NO_MEM: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_NO_MEM",-1); return TCL_ERROR;
    case LIBUSB_ERROR_NOT_SUPPORTED: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_NOT_SUPPORTED",-1); return TCL_ERROR;
    case LIBUSB_ERROR_OTHER: Tcl_SetStringObj(tcl_result,"LIBUSB_ERROR_OTHER",-1); return TCL_ERROR;
  }
}

%typemap(out) char ** {
  Tcl_Obj * tcl_result = $result;
  Tcl_SetListObj(tcl_result,0,NULL);
  if ($1 == NULL) return TCL_OK;
  for (char **p1 = $1; *p1 != NULL; p1++) {
    Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewStringObj(*p1,-1));
    delete *p1;
  }
  delete $1;
}
#endif
%apply unsigned int {uint8_t};

%apply unsigned int *OUTPUT {uint8_t &};

};

%include Azatrax.h
%include mrd.h
%include sl2.h
%include sr4.h

