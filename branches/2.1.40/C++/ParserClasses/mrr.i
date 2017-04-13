/* 
 * ------------------------------------------------------------------
 * mrr.i - 
 * Created by Robert Heller on Sun Jul 28 10:05:27 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/10/22 17:17:27  heller
 * Modification History: 10222007
 * Modification History:
 * Modification History: Revision 1.4  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.3  2007/02/21 21:03:10  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.2  2007/02/21 20:25:28  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.10  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.9  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.8  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
 * Modification History:
 * Modification History: Revision 1.7  2005/11/04 19:06:35  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.6  2004/06/26 13:31:09  heller
 * Modification History: Update versioning for new release
 * Modification History:
 * Modification History: Revision 1.5  2004/03/13 15:50:03  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 1.4  2002/10/17 00:02:07  heller
 * Modification History: Implement turnout body, track length, and turntable support, along with
 * Modification History: accessors.
 * Modification History:
 * Modification History: Revision 1.3  2002/09/25 01:55:14  heller
 * Modification History: Implement Tcl access to graph nodes.
 * Modification History:
 * Modification History: Revision 1.2  2002/07/28 14:06:34  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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
%module Mrr
#if 0
%section "Model Railroad"
#endif
%{
#include <iostream>   
#include <fstream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include "config.h"
#include <ParseFile.h>
#include <TrackGraph.h>
/*#include <Tree.h>*/
/*#include <MRRSigExpr.tab.h>*/
#include <MRRXtrkCad.tab.h>
#include "../gettext.h"
static char rcsid[] = "$Id: mrr.i 624 2008-04-21 23:36:58Z heller $";

#include <sstream>

using namespace Parsers;

#ifdef __cplusplus
    extern "C" {
#endif
#ifdef MAC_TCL
#pragma export on
#endif
SWIGEXPORT int Mrr_SafeInit(Tcl_Interp *);
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
#define SWIG_name "Mrr"
#undef SWIG_version
#define SWIG_version MRR_PATCH_LEVELLIB
%}

#ifdef SWIGTCL8
%typemap(out) int MyTcl_Result {
 return $1;
}
#endif

%include TrackGraph.h
%include ParseFile.h
%include SocketPair.h
