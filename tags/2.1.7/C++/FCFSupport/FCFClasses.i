/* 
 * ------------------------------------------------------------------
 * FCFClasses.i - Freight Car Forwarder Tcl interface spec
 * Created by Robert Heller on Thu Aug 25 09:02:53 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.3  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:34  heller
 * Modification History: Nov 4, 2005 Lockdown
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
%module FCFClasses
%{
#include <System.h>
#include <TextPrinter.h>
#include <LQ24Printer.h>
#include <PostScriptPrinter.h>
#include <PDFPrinter.h>
static char rcsid[] = "$Id$";
%}

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%section "Freight Car Forwarder 2 Support Classes"
#endif

%include typemaps.i

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%init %{
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
            return TCL_ERROR;
        }
        // Make it a proper Tcl package.
	Tcl_PkgProvide(interp, "Fcfclasses", FCFCLASSES_VERSION);
%}
#else
%{
#undef SWIG_name
#define SWIG_name "Fcfclasses"
#undef SWIG_version
#define SWIG_version FCFCLASSES_VERSION
%}
#endif

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%style before
#endif

%typemap(tcl8,out) char {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
	char temp[2];
	tcl_result = Tcl_GetObjResult(interp);
	temp[0] = $source;
	temp[1] = '\0';
	Tcl_SetStringObj(tcl_result,temp,1);
#else
	char temp[2];
	temp[0] = $1;
	temp[1] = '\0';
	Tcl_SetStringObj($result,temp,1);
#endif
}

%include Division.h

%include Station.h

%include Train.h

%include Industry.h

%include CarType.h

%include Owner.h

%include Car.h

%include System.h

%include CallBack.h

%include Printer.h

%include TextPrinter.h
%include LQ24Printer.h
%include PostScriptPrinter.h
%include PDFPrinter.h
/*%include PCLPrinter.h*/

