/* -*- C -*- ****************************************************************
 *
 *  System        : 
 *  Module        : 
 *  Object Name   : $RCSfile$
 *  Revision      : $Revision$
 *  Date          : $Date$
 *  Author        : $Author$
 *  Created By    : Robert Heller
 *  Created       : Sun Apr 30 15:58:40 2017
 *  Last Modified : <170508.1231>
 *
 *  Description	
 *
 *  Notes
 *
 *  History
 *	
 ****************************************************************************
 *
 *    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
 *			51 Locke Hill Road
 *			Wendell, MA 01379-9728
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * 
 *
 ****************************************************************************/

/** @defgroup TclSocketCANModule TclSocketCANModule
 * @brief     Tcl Channel for CAN Sockets.
 * 
 * This module defines a Tcl Channel type for CAN Sockets.  These are much like
 * TCP Sockets, except the read/write code translates CAN frames to/from 
 * GridConnect messages.  This module is only available under Linux, since only
 * Linux has kernel support for the CAN socket family (AF_CAN).
 * 
 * @author Robert Heller \<heller\@deepsoft.com\>
 * 
 * @{
 * 
 */


%module TclSocketCAN
%{
    static const char rcsid[] = "@(#) : $Id$";
    SWIGEXPORT int Tclsocketcan_SafeInit(Tcl_Interp *);
    int SocketCAN(Tcl_Interp *interp, const char *candev);
%}


%include typemaps.i


%{
#undef SWIG_name
#define SWIG_name "Tclsocketcan"
#undef SWIG_version
#define SWIG_version TCLSOCKETCAN_VERSIONLIB
%}

%apply int Tcl_Result { int SocketCAN };

/** @brief Open a CAN Socket.
 * 
 * This function opens a read/write connection to a CAN socket to the named
 * interface.  The result of this function is the name of a Tcl Channel and
 * can be used as an argument to any Tcl Channel function (such as gets,
 * puts, or fileevent).
 * 
 * @param candev The name of the CAN interface to connect to.
 * @return The name of a Tcl Channel.
 */ 

int SocketCAN(Tcl_Interp *interp, const char *candev);

/** @} */
