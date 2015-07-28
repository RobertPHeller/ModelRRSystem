// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Jul 26 21:20:26 2015
//  Last Modified : <150727.2121>
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

#ifndef __ASSEMBLINGSIGNALTARGETS_H
#define __ASSEMBLINGSIGNALTARGETS_H
/** @page Assemblingsignaltargets Assembling signal targets
 * The next step is to assemble the signal targets. @e I used 2mm x 1.25mm 
 * chip LEDs, made by Osram and sold by 
 * <a href="http://www.mouser.com" target="_blank">Mouser</a> (part numbers 
 * Green: <a href="https://www.mouser.com/Search/ProductDetail.aspx?R=LG_R971-KN-1virtualkey62510000virtualkey720-LGR971-KN-1" target="_blank">720-LGR971-KN-1</a>, 
 * Yellow: <a href="https://www.mouser.com/Search/ProductDetail.aspx?R=LY_R976-PS-36virtualkey62510000virtualkey720-LYR976-PS-36" target="_blank">720-LYR976-PS-36</a>, 
 * and Super Red: <a href="https://www.mouser.com/Search/ProductDetail.aspx?R=LS_R976-NR-1virtualkey62510000virtualkey720-LSR976-NR-1" target="_blank">720-LSR976-NR-1</a>).
 * These are $.10 each in single quantities and the price goes down to about 
 * five and a half cents each in quantities of 100.  If you decide to use chip 
 * LEDs instead of regular 3mm LEDs with leads, be sure to get some extras, 
 * because you will likely loose one or two.
 * 
 * @image latex ChipPhoto.jpg "Photo of a typical chip LED" width=3in
 * @image html  ChipPhoto.jpg "Photo of a typical chip LED"
 * @image latex ChipPackageOutline.png "Outline drawing of a typical chip LED" width=4.5in
 * @image html  ChipPackageOutline-thumb.png "Outline drawing of a typical chip LED"
 *
 * These devices come on a tape carrier.  This is something normally meant to 
 * go in a robot feeding device that places the chips on circuit boards in 
 * robotic factory. To handle these devices by hand you will need to make a 
 * tool to hold them.  I made a tool from a standard round toothpick.  I used 
 * a razor saw to cut one of the end points off, sanded cut flat and applied a 
 * dab of <a href="http://www.micromark.com/detail-tack-2-oz-applicator-bottle,9712.html" target="_blank">Detail Tack</a> 
 * (available from <a href="http://www.micromark.com" target="_blank">Micro-Mark</a> for $7.95). 
 * This stuff dries clear and remains tacky (sticky). This lets you pick up 
 * the chips from their tape carrier and hold them in place as you re-flow the 
 * solder to secure them to the circuit board.
 * 
 * @image latex SignalChipLEDInCarrier.jpg "Signal Chip LED In Carrier" width=3in
 * @image html  SignalChipLEDInCarrier-thumb.jpg "Signal Chip LED In Carrier"
 * @image latex ChipTape.png "Chip Tape specs (page 13 of the data sheet)" width=4.5in
 * @image html  ChipTape-thumb.png "Chip Tape specs (page 13 of the data sheet)"
 * 
 * You will also need a supply of wire wrap wire in a number of colors (this 
 * is available from <a href="http://www.digikey.com/product-search/en?pv77=223&FV=fff40019%2Cfff8006f%2Cfffc0028%2C1c001d&k=wire+wrap+wire&mnonly=0&newproducts=0&ColumnSort=0&page=1&stock=1&quantity=0&ptm=0&fid=0&pageSize=25" target="_blank">DigiKey</a>), 
 * a supply of cut off resistor leads (or really any small solid bare wired 
 * cut into pieces about 1/2 to 3/4 inches long), and a piece of Strip-board 
 * two foil strips wide (.2 inches / 5mm) that is long enough to make little 
 * circuit boards for your targets -- you will need 6 holes for 3 color 
 * targets, 4 holes for 2 color targets, and 2 holes for single color targets. 
 * I also used a block of foam as a work surface, since it let me push the 
 * resistor leads into it.
 * 
 * The first step is to remove some of the foil.  One side is the common side 
 * (cathode end) and the other is for one-of connections (anode).  The common 
 * / cathode is connected with a resistor lead that will be soldered to the 
 * brass tube the signal targets will be mounted to.  The anode side will be 
 * connected with wire wrap wire, one per chip and color coded (I used green, 
 * yellow, and red for the upper head and blue, white, and black for the lower 
 * head). Once the foil bits have been removed, strip and feed the wire wrap 
 * wire on one side and push the resistor lead through a hole on the other 
 * side and then solder the wires.  Be sure to spread a thin layer of solder 
 * down the length of the common side.
 * 
 * @image latex SignalTargetAndStripBoard.jpg "Signal Target And Strip Board" width=4in
 * @image html  SignalTargetAndStripBoard-thumb.jpg "Signal Target And Strip Board"
 * @image latex SignalCircuitBoard_WiresSoldered.jpg "Signal Circuit Board, Wires Soldered" width=4in
 * @image html  SignalCircuitBoard_WiresSoldered.jpg "Signal Circuit Board, Wires Soldered"
 * 
 * Now we can solder on the LED chips. The carrier tape has a clear cover 
 * strip over the top. @e Carefully peel this back (a hobby knife can help 
 * with this).  Only peel back @e one chip at a time.  Once the cover strip 
 * has been peeled back the chips can very easily bounce out and promptly 
 * vanish! Or at least become disorientated... It is important to remember 
 * that the side of the tape with the holes is the cathode end, so you should 
 * keep the hole side oriented to the same side as the common side of the 
 * circuit board.  Once you have peeled the cover off one chip, use your 
 * pickup tool (toothpick with flattened end with detail tack on it) to pick 
 * up the chip and being careful not to twist the toothpick position the chip 
 * on the circuit board.  Using a small electronics soldering iron briefly 
 * reheat the solder on each side to secure the chip.  You will want to wait 
 * for the solder to cool on the first side before reheating the second side.
 * Be sure to inspect your work and test the chip before continuing on to the 
 * next chip.  You will probably want to do all of chips of each color before 
 * moving on to the next color, since there is no obvious way to tell which 
 * color a chip is.
 * 
 * @image latex SignalChipLEDSoldered.jpg "Signal Chip LED Soldered" width=4in
 * @image html  SignalChipLEDSoldered.jpg "Signal Chip LED Soldered"
 * 
 * Once the chips have been soldered to the circuit board, each target's 
 * circuit board can be cut off the strip and that target's circuit board can 
 * be glued to the back of the target with a CA (superglue) adhesive. Finally, 
 * the circuit board can be covered with opaque black paint or 
 * <a href="http://www.micromark.com/liquid-electrical-tape,9836.html" target="_blank">LIQUID ELECTRICAL TAPE (available from Micro-Mark)</a>. 
 * The targets can now be assembled with their brackets to the signal masts 
 * (3/32 inch brass tubing).  Route the wire wrap wires inside the brass 
 * tubing (use a 1mm drill to drill holes near where the wires come off the 
 * circuit boards).  The common lead (the resistor lead wire) can be soldered 
 * to the brass tubing and an additional wire wrap wire soldered to the end of 
 * the tube.
 * @htmlonly
 * <div class="contents"><a class="el" href="ProgrammingtheArduino.html">Continuing with the Programming the Arduino</a></div>
 * @endhtmlonly
 */

#endif // __ASSEMBLINGSIGNALTARGETS_H

