/* 
 * ------------------------------------------------------------------
 * cmri.i - C/MRI interface wrapper
 * Created by Robert Heller on Sat Mar 13 10:58:14 2004
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.9  2007/02/21 20:48:21  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.8  2007/02/21 20:38:05  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.7  2007/02/21 20:21:20  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.6  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.3  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:34  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.4  2004/06/26 13:31:09  heller
 * Modification History: Update versioning for new release
 * Modification History:
 * Modification History: Revision 1.3  2004/03/16 14:49:28  heller
 * Modification History: Code comments added
 * Modification History:
 * Modification History: Revision 1.2  2004/03/16 02:37:39  heller
 * Modification History: Base class documentation
 * Modification History:
 * Modification History: Revision 1.1  2004/03/14 05:20:17  heller
 * Modification History: First Alpha Release Lockdown
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

%module Cmri
%{
#include <stdio.h>
#include <ctype.h>
#include <cmri.h>
static char rcsid[] = "$Id$";
%}

%include typemaps.i

%{
#undef SWIG_name
#define SWIG_name "Cmri"
#undef SWIG_version
#define SWIG_version CMRI_VERSION
%}


#if 0
%section "C/MRI C++ Serial Port Interface."
%text %{
  \typeout{Generated from $Id$.}
  This is a Linux implementation of Bruce Chubb's C/MRI\cite{Chubb89}
  QBASIC\cite{ChubbBAS04} serial port code ported to C++.  This code
  works (tested) with 2.2 kernels and GLIBC 2.1 (RedHat 6.2) and 2.4
  kernels and GLIBC 2.2 (RedHat 7.3). And it can use any serial port device
  supported by these kernels.  That is, in addition to the standard
  four COM ports, it can also use the various supported multi-port
  cards as well.
  
  The code is presently ``hardwired'' to use the Linux termios interface. I
  wanted to get the code up and running and presently I don't have any machines
  running other operating systems to test other low-level terminal I/O code.
  MS-Windows users do have access to Bruce Chubb's C/MRI QBasic and Visual 
  Basic code, so there is no rush at this point to support MS-Windows, although
  for MS-Windows who might want to use my forthcoming Tcl/Tk MRI code I'll
  probably want to port this code to run under MS-Windows.  This header and
  the class interface specification won't change much.  There will probably be
  lots of fun with ifdef in the C++ file.  Since this is open source code, I
  would hope that some enterprising MS-Windows C++ programmer will take up the
  ``gauntlet'' and do the MS-Windows port.  (Ditto for MacOSX and FreeBSD
  programmers.)

  Basically, the way this code works is to use a class (described on in
  \ref{Class:CMri}) to interface to the serial port, which may have 
  one or more serial port cards (a mix of USICs, SUSICs, and SMINIs).  A given 
  class instance interfaces to all of the cards on attached to a given serial 
  port.  There are three public member functions, one to initialize a given 
  board (described in \ref{Class:CMri:InitBoard}), one to set the 
  output ports (described in \ref{Class:CMri:Outputs}), and one to 
  poll the state of the input ports (described in
  \ref{Class:CMri:Inputs}).

  I was inspired to write this code after reading the four part series in 
  {\it Model
  Railroader}\cite{ChubbMRJan04,ChubbMRFeb04,ChubbMRMar04,ChubbMRApr04}
  and reading the download package for the SMINI card\cite{Chubb04}.  I
  already have a copy of Bruce Chubb's {\it Build Your Own Universal
  Computer Interface}, but the SMINI looks like a great option for
  small ``remote'' locations of a layout where there are a few turnouts
  and a some signals, such as a small junction, interchange yard, or
  isolated industrial spur.

%}
#endif

%include cmri.h
