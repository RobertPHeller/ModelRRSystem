/* 
 * ------------------------------------------------------------------
 * TTClasses.i - Time Table Classes interface.
 * Created by Robert Heller on Tue Dec 20 11:09:14 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.3  2007/02/21 21:03:10  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.2  2007/02/21 20:19:22  heller
 * Modification History: SWIG Hackery
 * Modification History:
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

%module TTClasses
%{
#include <TimeTableSystem.h>
#include <string.h>
using namespace TTSupport;

static char Id[] = "$Id$";

%}

/*
 * Include standard typemaps.
 */

%include typemaps.i

/*
 * Set package name and version.
 */

%{
#undef SWIG_name
#define SWIG_name "Ttclasses"
#undef SWIG_version
#define SWIG_version TTCLASSES_VERSION
%}

#ifdef SWIGTCL8
/*
 * Typemap for native Tcl methods and functions.
 */

%typemap(out) int MyTcl_Result {
	return $1;
}

/*
 * Pass though actual Tcl Objects.
 */

%typemap(in) Tcl_Obj * {
	$1 = $input;
}
#endif
/*
 * Don't auto generate default constructors (some classes don't have default
 * constructors or have ones that should not be wrapped for direct Tcl access).
 */

%nodefault;

/*
 * Include class declaractions from C++ header files.
 */

%include TimeTableSystem.h

%include Station.h

%include Cab.h

%include Train.h
