/* 
 * ------------------------------------------------------------------
 * MainWindow.hh - Main Window Help
 * Created by Robert Heller on Mon Jan 22 13:06:57 2007
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:53  heller
 * Modification History: Lock down for Release 2.1.7
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

0 Keys
The following accelerator keys are available:

   Ctrl-n -- Define a new lens.  See <New>.
   Ctrl-o -- Open and load a set of lenses. See <Open...>.
   Ctrl-s -- Save the current set of defined lenses. See <Save>.
   Ctrl-p -- Print the current diagram. See <Print...>.
   Ctrl-q -- Exit the program. See <Exit>.
0 tlMain.tcl
Main window.  Consists of:
  <tlMain.tcl.#menubar> -- Menu bar
  <tlMain.tcl.main.frame.canvasSW.lensCanvas> -- Lens viewing area diagram.
  <tlMain.tcl.main.frame.bottom> -- Input area.
  <tlMain.tcl.main.status> -- Status area.
1 tlMain.tcl.#menubar
This is the menubar of the application.  Only the <File> and <Help> menus
contain useful menu items.
2 File
The [File] menu contains these menu items:

  <New>         -- Define a new lens.  See <GetLensSpecDialog>.
  <Open...>     -- Open and load a lens database file.
  <Save>        -- Save the currently defined lenses.
  [Save As...]  -- Save the currently defined lenses (same as <Save>).
  <Print...>    -- Print the current lens view diagram. See
                   <PrintCanvasDialog>. 
  [Close]       -- Close the application (same as <Exit>).
  <Exit>        -- Close the application.
3 New
Defines a new lens.  Opens a <GetLensSpecDialog> to gather information
about the new lens.
3 Open...
Opens and loads a lens database file.  A file selection dialog is
displayed and the selected file is opened and loaded.
3 Save
Saves the current set of lenses to a lens database file.  A file
selection dialog is displayed and the lenses are saved to the selected file.
3 Print...
The current lens view diagram is printed or saved to a Postscript file.
A <PrintCanvasDialog> is displayed to gather information about printing
the diagram.
3 Exit
The program exits.  A exit confirmation dialog is displayed.
2 Help
The [Help] menu contains the standard help menu items.
1 tlMain.tcl.main.frame.canvasSW.lensCanvas
This is where the lens view diagram is drawn.
1 tlMain.tcl.main.frame.bottom
This is where user input is gathered.  These inputs are gathered:
  <Distance>        -- The distance between the camera and the scene being
                       photographed. Only appears with AnyDistance.  Closest
                       uses the closest focus distance of the lens.
  <Lens>            -- The lens being used.
  <Scale>           -- The model scale.
  <Film Image Size> -- The size of the imaging plane.
2 Distance
This is the distance in inches between the camera and the scene.
2 Lens
This is the lens used to take the picture.
2 Scale
This is the scale being modeled.
2 Film Image Size
This is the width of the imaging plane.  That is, the size of the film
or the CCD chip.
1 tlMain.tcl.main.status
This is where status messages are displayed.
