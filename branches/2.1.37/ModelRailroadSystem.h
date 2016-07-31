/* 
 * ------------------------------------------------------------------
 * ModelRailroadSystem.h - Master man 1 file
 * Created by Robert Heller on Fri Jan 28 16:48:32 2011
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

/** @defgroup ModelRailroadSystem ModelRailroadSystem
  * @brief Model Railroad System programs.
  *
  * @section SYNOPSIS
  *
  * UniversalTest [X11 Resource Options]
  *
  * LocoPull [X11 Resource Options]
  *
  * Resistor [X11 Resource Options]
  *
  * AnyDistance [X11 Resource Options]
  *
  * Closest [X11 Resource Options]
  *
  * Dispatcher [X11 Resource Options] [panel program files...]
  *
  * FCFCreate [X11 Resource Options]
  *
  * FCFMain [X11 Resource Options] [SystemFile]
  *
  * TimeTable [X11 Resource Options] -totaltime time -timeincrement timeincr
  *
  * TimeTable [X11 Resource Options] [timetablefile]
  *
  * TTChart2TT2 inputfile name outputfile
  *
  * raildriverd [-debug] busnum devnum
  *
  * @section DESCRIPTION
  *
  * These programs comprise the collection of main programs available
  * with the Model Railroad System.  The Model Railroad System also contains
  * several C++ class libraries along with a library of Tcl packages, both
  * of which provide support for coding programs to support the operation of
  * your model railroad.
  *
  * Be sure to view the man pages listed below for details on using each
  * of these programs.
  *
  * The C++ class libraries and library of Tcl packages are documented
  * in section 3 of the man pages. 
  *
  * @section SA SEE ALSO
  * <b>UniversalTest</b>(1), <b>LocoPull</b>(1), <b>Resistor</b>(1),
  * <b>AnyDistance</b>(1), <b>Closest</b>(1), <b>Dispatcher</b>(1),
  * <b>FCFCreate</b>(1),  <b>FCFMain</b>(1), <b>TimeTable</b>(1),
  * <b>TimeTableLaTeXOpts</b>(1), <b>TTChart2TT2</b>(1), <b>raildriverd</b>(8).
  *
  * Also:
  * <b>cmri</b>(3), <b>CmriSupport</b>(3), <b>CTCPanel</b>(3),
  * <b>FCFSupport</b>(3), <b>GRSupport</b>(3), <b>HTMLHelp</b>(3),
  * <b>Instruments</b>(3), <b>LabelComboBox</b>(3), <b>LabelSelectColor</b>(3),
  * <b>LabelSpinBox</b>(3), <b>LCARS</b>(3), <b>mainwindow</b>(3),
  * <b>OvalWidgets</b>(3), <b>PanedWindow</b>(3), <b>Parsers</b>(3),
  * <b>RaildriverIO</b>(3), <b>ReadConfiguration</b>(3), <b>splash</b>(3),
  * <b>TclCommon</b>(3), <b>TTSupport</b>(3), and <b>xpressnet</b>(3).
  *
  * @section AUTHOR
  * Robert Heller \<heller\@deepsoft.com\>
  */
