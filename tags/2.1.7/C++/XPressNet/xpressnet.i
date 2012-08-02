/* 
 * ------------------------------------------------------------------
 * xpressnet.i - XPressNet interface wrapper
 * Created by Robert Heller on Wed May 25 21:16:53 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/02/01 20:00:53  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.3  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:35  heller
 * Modification History: Nov 4, 2005 Lockdown
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

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%title ""
#endif
%module Xpressnet
%{
#include <stdio.h>
#include <ctype.h>
#include <xpressnet.h>
#include <xpressnet_Event.h>
static char rcsid[] = "$Id$";
%}

%include typemaps.i

%init %{
        // Make the module Stubs aware.
        if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
            return TCL_ERROR;
        }
        // Make it a proper Tcl package.
        Tcl_PkgProvide(interp,"Xpressnet",XPRESSNET_VERSION);
%}

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%style before
#endif

/*
 * Type map to handle error messages.  Hide this parameter from Tcl, but return
 * it as a second result, returning TCL_ERROR, if there is an error message.
 */

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%typemap(tcl8,ignore) char **outmessage {
	$target = new char*;
	*$target = NULL;
}
#else
%typemap(tcl8,in,numinputs=0) char **outmessage {
	$1 = new char*;
	*$1 = NULL;
}
#endif

%typemap(tcl8,argout) char **outmessage {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	if (*$source != NULL) {
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewStringObj(*$source,-1)) != TCL_OK) {
			delete *$source;
			delete $source;
			return TCL_ERROR;
		}
		delete *$source;
		delete $source;
		return TCL_ERROR;
	}
	delete $source;
#else
	Tcl_Obj * tcl_result = Tcl_GetObjResult(interp);
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
#endif
}
%typemap(tcl8,out) const struct timeval & {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	/* Return a timeval struct as a list of two integers. */
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewLongObj($source->tv_sec)) != TCL_OK) 
		return TCL_ERROR;
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewLongObj($source->tv_usec)) != TCL_OK)
		return TCL_ERROR;
#else
	Tcl_Obj * tcl_result = Tcl_GetObjResult(interp);
	/* Return a timeval struct as a list of two integers. */
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewLongObj($1->tv_sec)) != TCL_OK) 
		return TCL_ERROR;
	if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewLongObj($1->tv_usec)) != TCL_OK)
		return TCL_ERROR;
#endif
}
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%section "Lenz XPressNet Interface"
#endif

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
#else
%nodefault;
#endif

%include xpressnet.h

%include xpressnet_Event.h

