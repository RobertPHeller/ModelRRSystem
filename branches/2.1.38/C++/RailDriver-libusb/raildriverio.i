%module Raildriverio
%{
#include "config.h"
#include <RaildriverIO.h>
#include "gettext.h"
static char rcsid[] = "$Id$";
/*using namespace raildriverio;*/
#ifdef __cplusplus
    extern "C" {
#endif
#ifdef MAC_TCL
#pragma export on
#endif
SWIGEXPORT int Raildriverio_SafeInit(Tcl_Interp *);
#ifdef MAC_TCL
#pragma export off
#endif
#ifdef __cplusplus
}
#endif
%}

%include typemaps.i

%{
#undef SWIG_name
#define SWIG_name "Raildriverio"
#undef SWIG_version
#define SWIG_version RAILDRIVERIO_VERSION
%}

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
#endif

%include RaildriverIO.h
