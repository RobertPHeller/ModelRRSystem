// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Thu Apr 10 16:38:56 2014
//  Last Modified : <140423.1355>
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

#ifndef __GENERICTHROTTLEREFERENCE_H
#define __GENERICTHROTTLEREFERENCE_H

/** @page genericthrot Generic Throttle
 * 
 * The GenericThrottle program is a sample program that provides a "virtual" 
 * replacement for a hand-held DCC (or DC!) Throttle on your computer screen.
 * It has no "back-end", that is, it does not actually do anything.  It is
 * meant as a starting point for writing your own "virtual" throttle (and 
 * DCC programming) program.
 * 
 * @section genericthrot_maingui Main GUI
 * Its basic GUI in Throttle Mode is shown here:
 * @br
 * @image latex GenericThrottle_maingui.png "GenericThrottle Main GUI in Throttle Mode" width=4in
 * @image html  GenericThrottle_mainguiSmall.png
 * @br
 * On the left is a field to enter the locomotive's address, and buttons for
 * selecting the locomotive's direction and a slider for selecting the 
 * locomotive's speed.  On the right is an array of buttons to select the
 * locomotive's function bits.  By default, the locomotive address is set to 3
 * but you can enter a different address. The controls are pretty self 
 * explainitory.  
 * 
 * @section genericthrot_progmode Programming Mode
 * In programming mode, the Main GUI looks like this:
 * @br
 * @image latex GenericThrottle_progmode.png "GenericThrottle Main GUI in Programming Mode" width=4in
 * @image html  GenericThrottle_progmodeSmall.png
 * @br
 * The Manufacturer ID and Version number are fetched and filled in.  There is
 * a dropdown menu of standard (common) CVs or you can enter any other CV. The
 * existing value is displayed.  You can change it and press ENTER to update
 * the value of the CV register.
 * 
 */

#endif // __GENERICTHROTTLEREFERENCE_H

