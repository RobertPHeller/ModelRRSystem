// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:38:47 2014
//  Last Modified : <140411.1339>
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

#ifndef __CAMERAMANUAL_H
#define __CAMERAMANUAL_H

/** @page camera:Reference Camera Programs Reference
 * AnyDistance and Closest compute the view angle in both real and scale
units. It also computes the effective scale of the imaging plane, such
as the size of a 35mm slide, which might be used as a transparency for
model window panes or locomotive number boards.

Both programs work the same. The only difference is that Closest uses
the closest effective focus of the lens and AnyDistance uses a user
specified focus distance.  Given the input parameters, the distance,
the lens, the scale, and the film size, a diagram is displayed with the
dimensions of the view.  This diagram can be printed using the \verb=Print...=
menu item under the \verb=File= menu.

New lenses can be entered with the \verb=New= menu item under the
\verb=File= menu. The \verb=Open...= and \verb=Save..= menu items can
load and save the set of available lenses.

Both programs solve Equation~\ref{eq:camera:viewWidth} and display a
diagram illustrating the solution.  AnyDistance uses a user entered
value for $D$ and Closest uses the closest focusing distance for the
selected lens.

\begin{equation}
W_{view} = (D S) 2 \tan(\frac{\theta}{2}) \label{eq:camera:viewWidth}
\end{equation}

Where:

\begin{eqnarray*}
W_{view} &=& \mbox{The scale view width.}\\
D &=& \mbox{The distance from the scene and the camera lens.}\\
S &=& \mbox{The model scale factor.}\\
\mbox{and} \\
\theta &=& \mbox{The lens view angle.}
\end{eqnarray*}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics[width=5in]{CameraAnyDist.png}
\caption{The main GUI screen of the AnyDistance program}
\label{fig:camera:anydist}
\end{centering}
\end{figure}
The main GUI screen of the AnyDistance program is shown in
Figure~\ref{fig:camera:anydist}. The Closest program is much the same,
except that the distance parameter is omitted.
   
 */

#endif // __CAMERAMANUAL_H

