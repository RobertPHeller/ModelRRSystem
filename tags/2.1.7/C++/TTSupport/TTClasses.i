/* 
 * ------------------------------------------------------------------
 * TTClasses.i - Time Table Classes interface.
 * Created by Robert Heller on Tue Dec 20 11:09:14 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.3  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2006/05/17 01:11:21  heller
 * Modification History: May 16, 2006 lock down II: Add in IDs
 * Modification History:
 * Modification History: Revision 1.1  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
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

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%title ""
#endif
%module TTClasses
%{
#include <TimeTableSystem.h>

static char Id[] = "$Id$";

%}

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%section "Time Table System Support classes"
#endif

%include typemaps.i

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%init %{
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
            return TCL_ERROR;
        }
        // Make it a proper Tcl package.
	Tcl_PkgProvide(interp, "Ttclasses", TTCLASSES_VERSION);
%}
#else
%{
#undef SWIG_name
#define SWIG_name "Ttclasses"
#undef SWIG_version
#define SWIG_version TTCLASSES_VERSION
%}
#endif

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%style before
#endif

%typemap(tcl8,out) int MyTcl_Result {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	return $source;
#else
	return $1;
#endif
}

%typemap(tcl8,in) Tcl_Obj * {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	$target = $source;
#else
	$1 = $input;
#endif
}

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
#else
%nodefault;
#endif

%include TimeTableSystem.h

%include Station.h

%include Cab.h

%include Train.h
