// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Thu Apr 10 15:31:29 2014
//  Last Modified : <170315.1147>
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

#ifndef __INTRODUCTION_H
#define __INTRODUCTION_H

/** @page Introduction Introduction
 * @section org How this manual is organized.
 *
 * This manual is broken up into chapters, one or two for each "main program".
 * @latexonly
 * \footnote{The various programming libraries are described in the programming
 * guides\cite{progguide}.} 
 * @endlatexonly
 * These chapters are:
 *   - Chapter @ref univtest documents the Universal Test program. This
 *     program is part of the CMR/I (Chubb) library and is used to test CMR/I
 *     nodes.
 *   - Chapter @ref openlcb documents the OpenLCB program.  This program 
 *     implements a dianostic program for LCC networks, and includes an
 *     event logger, event injector, and memory configuration tools (both raw
 *     hex and CDI).
 *   - Chapter @ref openlcbdaemons documents the OpenLCB daemon programs. This
 *     includes both the Hub Daemons and the Virtual Node Daemons.  The Hub 
 *     Daemons implement virtual networks over Tcp/Ip.  The Virtual Node 
 *     Daemons implement LCC nodes as processes running on a host computer.
 *   - Chapter @ref azatrax documents the Azatrax Test programs. These programs
 *     are part of the Azatrax library are are used to test Azatrax USB modules
 *   - Chapter @ref xpressnetthrot documents the XPressNet Throttle program.
 *     This program is part of the XPressNet library and is a simple GUI
 *     program that implements the functionallity of the DCC control unit
 *     (aka a throttle).
 *   - Chapter @ref genericthrot documents the Generic Throttle program.
 *     This program implements the functionallity of a generic throttle. It
 *     can be used as the basis for a DC or DCC control unit or throttle, using
 *     a specific control library.
 *   - Chapters @ref timetable_Tutorial and @ref timetable_ref document the 
 *     Time Table (V2) program. This program is used to create employee 
 *     timetables.
 *   - Chapters @ref fcf_Tutorial and @ref fcf_Reference document the Freight 
 *     Car Forwarder (V2) program. This program is used to create switch 
 *     lists for freight car forwarding.
 *   - Chapters @ref rest_Reference and @ref locopull_Reference document the 
 *     calculator scripts, Resistor and LocoPull, that are available to help 
 *     model railroaders perform some common calculations.
 *   - Chapter @ref camera_Reference documents the camera scripts. These scripts perform 
 *     various camera scene calculations that are useful for model 
 *     railroaders.
 *   - Chapters @ref dispatcher_Tutorial, @ref dispatcher_Reference, and 
 *     @ref dispatcher_Examples document the automated dispatcher program.
 *   - Chapter @ref SatelliteDaemon documents the daemon for using satellite 
 *     computers.
 *   - Chapter @ref raildriverd documents the daemon program for the 
 *     RailDriver control stand console.
 *   - Chapter @ref OpenLCBTcpHub documents the daemon program for the binary
 *     OpenLCB over Tcp Hub.
 *   - Chapter @ref OpenLCBGCTcpHub documents the daemon program for the 
 *     OpenLCB GridConnect over Tcp Hub.
 *   - Chapter @ref OpenLCB_MRD2 documents the daemon program for the OpenLCB
 *     interface to the Azatrax MRD2 USB connected IR detectors.
 *   - Chapter @ref OpenLCB_PiGPIO documents the daemon program for the OpenLCB
 *     interface to the Raspberry PI's GPIO pins.
 *   - Chapter @ref OpenLCB_TrackCircuits documents the daemon program for the
 *     OpenLCB Virtual Track Circuits.
 *   - Chapter @ref OpenLCB_Logic documents the daemon program for the 
 *     OpenLCB Logic module.
 *   - Chapter @ref OpenLCB_Acela documents the daemon program for the CTI
 *     Acela.
 */

#endif // __INTRODUCTION_H

