// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Jul 26 21:22:14 2015
//  Last Modified : <150727.2122>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2015  Robert Heller D/B/A Deepwoods Software
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

#ifndef __PROGRAMMINGTHEARDUINO_H
#define __PROGRAMMINGTHEARDUINO_H
/** @page ProgrammingtheArduino Programming the Arduino
 * @htmlonly
 * The code to download to the Arduino is in available for download as 
 * <a href="SignalDriverMax72xx.ino">SignalDriverMax72xx.ino</a>.
 * @endhtmlonly
 * @latexonly
 * The source code for the Arduino is in the file SignalDriverMax72xx.ino.
 * @endlatexonly
 * It uses the @e LedControl library, so the code starts by including the 
 * header file:
 * @dontinclude SignalDriverMax72xx.ino
 * @line LedControl
 * 
 * Then since it is using scanf() and various string function, it includes 
 * stdio.h and string.h:
 * @line stdio
 * @until string
 * 
 * Then it allocates a <strong>LedControl</strong> object:
 * @skipline Create a new LedControl.
 * @until lc1=LedControl
 * 
 * Next the setup function initializes the MAX72xx chip and sends an 
 * announcement to the host computer over the serial port:
 * @skipline setup
 * @until }
 * 
 * Next the signal aspects are defined.  These values assuming that the signal 
 * heads are wired bottom to top, with the LEDs wired from bit 0 to 5 as: 
 * lower red, lower yellow, lower green, upper red, upper yellow, and upper 
 * green. (See @ref wiring Wiring the signals below.)
 * @skipline Signal Aspects
 * @until DARK
 * 
 * Next we have a helper function to convert from an aspect name sent from the 
 * host computer to the Arduino.
 * @until }
 *
 * Next comes the main loop function.  Here we read a one line command from 
 * the host computer and decide what to do.  There are only three commands 
 * defined:
 *  - One to turn all of the LEDs off.
 *  - One to set the aspect of one signal.
 *  - And a final command to initiate a test sequence.
 *
 * @until End of Main loop
 * 
 * @section wiring Wiring the signals.
 * I used this color coding for the signal LEDs when I wired them:
 *
 * <dl><dt>Green</dt><dd>The upper target head's green LED (uppermost LED of the upper target).</dd>
 * <dt>Yellow</dt><dd>The upper target head's yellow LED (middle LED of the upper target).</dd>
 * <dt>Red</dt><dd>The upper target head's red LED (bottom LED of the upper target).</dd>
 * <dt>Blue</dt><dd>The lower target head's green LED (uppermost LED of the lower target).</dd>
 * <dt>White</dt><dd>The lower target head's yellow LED (middle LED of the lower target).</dd>
 * <dt>Black</dt><dd>The lower target head's red LED (bottom LED of the lower target).</dd>
 * </dl>
 *
 * Thus the connections to the terminal blocks at the ends of the signal 
 * cables are made as shown here. If a target has fewer than three LEDs, then 
 * the wires for the missing LEDs are also missing.
 *
 * @image latex SignalConnectorBoard_ColorCodes.jpg "Signal Connector Board, Wiring Color Codes" width=4in
 * @image html  SignalConnectorBoard_ColorCodes-thumb.jpg "Signal Connector Board, Wiring Color Codes"
 *
 * Once you have entered the code and verified that it compiles and uploaded 
 * it to the Arduino, you can test the code with the Serial Monitor tool on 
 * the Arduino IDE.  Be sure to set the baud rate to 115200. You can then type 
 * commands into the Serial Monitor tool's send bar, as shown here.
 *
 * @image latex SerialMonitor_TestSketch.png "Serial Monitor, Test Sketch" width=4.5in
 * @image html  SerialMonitor_TestSketch.png "Serial Monitor, Test Sketch"
 * @htmlonly
 * <div class="contents"><a class="el" href="ProgrammingtheHostComputer.html">Continuing with the Programming the Host Computer</a></div>
 * @endhtmlonly
 */

#endif // __PROGRAMMINGTHEARDUINO_H

