// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Feb 26 10:30:10 2023
//  Last Modified : <230302.1355>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2023  Robert Heller D/B/A Deepwoods Software
//			51 Locke Hill Road
//			Wendell, MA 01379-9728
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// 
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __OFFLINELCCNODEEDITOR_H
#define __OFFLINELCCNODEEDITOR_H

/** @page openlcbofflineeditor Offline LCC Node Editor Reference
 * This program makes use of the @ref ConfigurationEditor to edit LCC Node
 * backup configuration files without being connected to a LCC network.
 * @section cliparsopts Command Line Parameters and Options
 * This program takes some optional options and at least one required
 * parameter.
 * @subsection offopts Options
 * @subsection offx11opts  X11 Resource Options
 * @arg -colormap: Colormap for main window
 * @arg -display:  Display to use
 * @arg -geometry: Initial geometry for window
 * @arg -name:     Name to use for application
 * @arg -sync:     Use synchronous mode for display server
 * @arg -visual:   Visual for main window
 * @arg -use:      Id of window in which to embed application
 * @par
 * 
 * @subsubsection offotheropts Other options
 * 
 * @arg -help Print a short help message and exit.
 * @arg -debug Turn on debug output.
 * @par
 * 
 * @subsection offpars Parameters
 * 
 * There is one required parameter, the file containing the CDI XML for the
 * nodes to be edited. Additional parameters are the config files to be
 * edited.
 * 
 * @section mainguioffline Main GUI Elements
 * In addition to editing LCC Node backup config files, this program also can
 * manage a @ref LayoutControlDatabase "Layout Control Database", just like 
 * the OpenLCB (see @ref openlcb) 
 * and Dispatcher (see @ref dispatcher_Reference "Dispatcher Reference") programs.  Its @c File menu contains items to
 * load and save a layout control database, and its @c Edit menu contains
 * items to create layout control elements.  See the @ref openlcb documentation
 * for info on these menu items.  Additionally, the @c Open item on the
 * @c File menu will open additional config files to edit.
 * 
 * The main GUI contains the table of Layout Control elements in the currently
 * loaded layout control database, along with edit boxes for these elements.
 */

#endif // __OFFLINELCCNODEEDITOR_H

