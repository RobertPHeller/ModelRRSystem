/* 
 * ------------------------------------------------------------------
 * FCFClasses.i - Freight Car Forwarder Tcl interface spec
 * Created by Robert Heller on Thu Aug 25 09:02:53 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/02/21 21:03:09  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.4  2007/02/21 19:13:52  heller
 * Modification History: SWIG Hackery
 * Modification History:
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
%module FCFClasses
%{
#include "config.h"
#include <System.h>
#include <TextPrinter.h>
#include <LQ24Printer.h>
#include <PostScriptPrinter.h>
#include <PDFPrinter.h>
#include "../gettext.h"
#include <assert.h>
static char rcsid[] = "$Id$";
using namespace FCFSupport;
#ifdef __cplusplus
    extern "C" {
#endif
#ifdef MAC_TCL
#pragma export on
#endif
SWIGEXPORT int Fcfclasses_SafeInit(Tcl_Interp *);
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
#define SWIG_name "Fcfclasses"
#undef SWIG_version
#define SWIG_version FCFCLASSES_VERSION
%}


#ifdef SWIGTCL8

%typemap(out) char {
	char temp[2];
	temp[0] = $1;
	temp[1] = '\0';
	Tcl_SetStringObj($result,temp,1);
}

%typemap(out) int MyTcl_Result {
	 return $1;
}

#endif

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



