// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Thu Apr 10 16:36:46 2014
//  Last Modified : <140423.1403>
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

#ifndef __XPRESSNETTHROTTLEREFERENCE_H
#define __XPRESSNETTHROTTLEREFERENCE_H

/** @page xpressnetthrot XPressNet Throttle
 * 
 * The XPressNetThrottle program is a simple program that provides a 
 * "virtual" replacement for a LM50 or LM100 on your computer screen. 
 * 
 * @section xpressnetthrot_maingui Main GUI
 * Its basic GUI in Throttle Mode is shown here:
 * @br
 * @image latex XPressNetThrottle_maingui.png "XPressNetThrottle Main GUI in Throttle Mode" width=4in
 * @image html  XPressNetThrottle_mainguiSmall.png
 * @br
 * On the left is a field to enter the locomotive's address, and buttons for
 * selecting the locomotive's direction and a slider for selecting the 
 * locomotive's speed.  On the right is an array of buttons to select the
 * locomotive's function bits.  By default, the locomotive address is set to 3
 * but you can enter a different address. The controls are pretty self 
 * explainitory.  
 * 
 * @section xpressnetthrot_progmode Programming Mode
 * In programming mode, the Main GUI looks like this:
 * @br
 * @image latex XPressNetThrottle_progmode.png "XPressNetThrottle Main GUI in Programming Mode" width=4in
 * @image html  XPressNetThrottle_progmodeSmall.png
 * @br
 * The Manufacturer ID and Version number are fetched and filled in.  There is
 * a dropdown menu of standard (common) CVs or you can enter any other CV. The
 * existing value is displayed.  You can change it and press ENTER to update
 * the value of the CV register.
 * 
 * @section xpressnetthrot_openport Open Port
 * The Open Port dialog, shown below, selects the serial port to use to connect
 * to the XPressNet bus.
 * @image latex XPressNetThrottle_openport.png "XPressNetThrottle Open Port dialog"
 * @image html  XPressNetThrottle_openport.png
 * @br
 */

#endif // __XPRESSNETTHROTTLEREFERENCE_H

