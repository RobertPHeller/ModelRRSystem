// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 14:00:38 2014
//  Last Modified : <140411.1401>
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

#ifndef __AZATRAXPROGREFERENCE_H
#define __AZATRAXPROGREFERENCE_H

/** @page azatrax:Reference Azatrax Test Programs Reference
 * 
 * These programs can be used to test MRD2-S and MRD2-U units made by
Azatrax. These are infrared sensor units with USB interfaces.  The
MRD2-S include relays for operating switch motors, power relays, or
signals. The MRD2-U contain just a pair of detectors.

\section{MRD Test}

This program is the basic test program and can be used to test basic
functionality of either a MRD2-S or MRD2-U unit.  There are buttons for
each of the commands that can be sent, plus a display area showing the
current state data for the unit.

\subsection{Synopsis}

\begin{verbatim}
MRDTest [X11 Resource Options]
\end{verbatim}

This program takes no parameters.

\section{MRD Sensor Loop}

This program loops, reading the unit sense data at 500 millisecond
intervals, displaying the state of the Sense and Latch bits, plus
whether or not the stopwatch is ticking and the current stopwatch time
value. 

\subsection{Synopsis}

\begin{verbatim}
MRDSensorLoop [X11 Resource Options] sensorSerialNumber
\end{verbatim}

This program takes one parameter, the serial number of the MRD2-S or
MRD2-U unit to test.  The program runs until exited or until the MRD2-S
MRD2-U unit is unplugged.

 */

#endif // __AZATRAXPROGREFERENCE_H

