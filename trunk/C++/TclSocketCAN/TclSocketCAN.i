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
 *  Last Modified : <170430.1647>
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


%module TclSocketCAN
%{
    static const char rcsid[] = "@(#) : $Id$";
    SWIGEXPORT int Tclsocketcan_SafeInit(Tcl_Interp *);
    int TclSocketCAN(Tcl_Interp *interp, const char *candev);
%}


%include typemaps.i


%{
#undef SWIG_name
#define SWIG_name "Tclsocketcan"
#undef SWIG_version
#define SWIG_version TCLSOCKETCAN_VERSIONLIB
%}

%apply int Tcl_Result { int TclSocketCAN };

int TclSocketCAN(Tcl_Interp *interp, const char *candev);

