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
//  Last Modified : <140420.1455>
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

/** @page rest_Reference Resistor Program Reference
 * 
 * The Resistor Calculator program aids in calculating dropping resistors
 * for LEDs and low-voltage lamps commonly used on model railroads.  It
 * implements Ohm's Law, shown in the equations below
 * @addindex "Ohm's Law"
 * to perform the calculation and then finds the nearest stock value and also 
 * displays the color bands for typical carbon resistors.
 * 
 * @f{eqnarray}{
 * R_{drop} &=& \frac{V_{drop}}{I}  \\
 * V_{drop} &=& V_{supply} - V_{load}
 * @f}   
 * 
 * The calculator takes three input values, the supply voltage
 * (@f$V_{supply}@f$), the voltage across the load (@f$V_{load}@f$) (LED or 
 * lamp) and the load current (@f$I@f$) the LED or lamp operates at.  These 
 * values are entered along with the units they are in. Then the calculate
 * button is pushed and the results are displayed.  The results can also be 
 * saved to a text file, which can be printed or otherwise referred to later.
 * 
 * The main GUI screen of the Resistor Calculator program is shown here:
 * 
 * @image latex RestMain.png "The main GUI screen of the Resistor Calculator program" width=5in
 * @image html  RestMainSmall.png
 * 
 */


#endif // __RESISTORMANUAL_H

