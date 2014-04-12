// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:35:45 2014
//  Last Modified : <140411.1336>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2014 Deepwoods Software.
// 
//  All Rights Reserved.
// 
// This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
// reproduced,  translated,  or  reduced to any  electronic  medium or machine
// readable form without prior written consent from Deepwoods Software.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __RESISTORMANUAL_H
#define __RESISTORMANUAL_H

/** @page rest:Reference Resistor Program Reference
 * The Resistor Calculator program aids in calculating dropping resistors
for LEDs and low-voltage lamps commonly used on model railroads.  It
implements Ohm's Law\index{Ohm's Law}, shown in
Equations~\ref{eq:rest:OhmsLaw} and~\ref{eq:rest:VDrop} to perform the
calculation and then finds the nearest stock value and also displays
the color bands for typical carbon resistors.

\begin{eqnarray}
R_{drop} &=& \frac{V_{drop}}{I} \label{eq:rest:OhmsLaw} \\
V_{drop} &=& V_{supply} - V_{load} \label{eq:rest:VDrop}
\end{eqnarray}

The calculator takes three input values, the supply voltage
($V_{supply}$), the voltage across the load ($V_{load}$) (LED or lamp)
and the load current ($I$) the LED or lamp operates at.  These values
are entered along with the units they are in. Then the calculate button
is pushed and the results are displayed.  The results can also be saved
to a text file, which can be printed or otherwise referred to later.

\begin{figure}[hbpt]
\begin{centering}
\includegraphics[width=5in]{RestMain.png}
\caption{The main GUI screen of the Resistor Calculator program}
\label{fig:rest:Main}
\end{centering}
\end{figure}
The main GUI screen of the Resistor Calculator program is shown in
Figure~\ref{fig:rest:Main}.  

 */


#endif // __RESISTORMANUAL_H

