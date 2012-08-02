%module Raildriverio
%{
#include <RaildriverIO.h>
#include "gettext.h"
static char rcsid[] = "$Id$";
/*using namespace raildriverio;*/
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
